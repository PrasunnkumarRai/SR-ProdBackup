/* 
    Customer/Project:   Spectrum Reach 
    Class name:          AccountTriggerHandler
    Author/Date:        John King    5/31/2017
    Release:             TBD
    Purpose:            Provides handler methods for the Account Trigger
    Modifications:      Brett Ballantyne  6/14/17  added code to OnBeforeInsert to set account OwnerId
                        Brett Ballantyne  6/15/18 - SRSF-1071

  // This should be used in conjunction with the ApexTriggerComprehensive.trigger template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

*/

public with sharing class AccountTriggerHandler {
  // This should be used in conjunction with the ApexTriggerComprehensive.trigger template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx
  private boolean m_isExecuting = false;
  private Integer BatchSize = 0;
  public static Boolean isFirstTime = true; //SRSF-4341

  public AccountTriggerHandler(boolean isExecuting, integer size){
    m_isExecuting = isExecuting;
    BatchSize = size;
  }

  public void OnBeforeInsert(Account[] newAccounts){
    try{
        List<String> aeList = new List<String>();
        for(Account acc: newAccounts){
          //START - 12MAR2019 - Added below code for Account Physical Address validation
          acc.Is_Address_Validation_Pending__c = true;
          acc.ShippingAddrLastRetryDate__c =null;
          //END
            if(String.isNotBlank(acc.AE__c)){
              aeList.add(acc.AE__c);
            }
        }
        Map<String,UserConnection__c> ucMap = new Map<String,UserConnection__c>();
        for (UserConnection__c uc:[SELECT User__c,AE_Id__c,TIM_System__c FROM UserConnection__c WHERE AE_Id__c IN :aeList]){
            ucMap.put(uc.AE_Id__c +uc.TIM_System__c,uc);
        }
        for(Account acc: newAccounts){
            if(ucMap!=null && ucMap.containsKey(acc.AE__c+acc.TIM_System__c) && String.isNotBlank(acc.AE__c)){
                acc.OwnerId=ucMap.get(acc.AE__c+acc.TIM_System__c).User__c;
            }
            acc.Name = acc.Source__c == 'SPP' ? 'SPP_'+acc.Name : acc.Name; // SRSF-3951
        }
    }
    catch(Exception ex){
        System.debug('Exception in AE to owner mapping: ' + ex + ex.getLineNumber());
    }
  }

  public void OnAfterInsert(Account[] newAccounts){
      System.debug(loggingLevel.WARN, '=================>> in OnAfterInsert!');
      //SyncplicitySRUtils.CreateSyncplicityFolders(new List<Id>(new Map<Id, Account>(newAccounts).keySet()));

  ////    addUserToAcctTeam(newAccounts);
/*      system.debug(loggingLevel.WARN, '==============================>> before addOriginalOwnerToAcctTeam');
      try{
        ChangeAccountOwner.addOriginalOwnerToAcctTeam(newAccounts);
      }
      catch(Exception ex){
        system.debug(loggingLevel.ERROR, '==============================>> exception in addOriginalOwnerToAcctTeam' + ex);
      }
*/      

      System.debug(loggingLevel.WARN, '==============================>> before ChangeAccountOwner');
      ChangeAccountOwner.ChangeOwner(System.Label.Account_Create_Owner_Id, newAccounts);
      
      System.debug(loggingLevel.WARN, '==============================>> before addUserToAcctTeam');
      ChangeAccountOwner.addAccountTeamMembers(newAccounts);    // SRSF-1071


   //   system.debug(loggingLevel.WARN, '==============================>> before addUserToAcctTeam');
     // ChangeAccountOwner.addUserToAcctTeam(newAccounts);

      //START: SRSF-4341      
      Set<Id> accIds = new Set<Id>();
      for(Account acc: newAccounts)
      {
        Id accRTId = acc.RecordTypeId;
        
        //SRSF-5136: Removed of Credit Status check: Credit_Status__c != 'Past Due/Denied'        
        if( (accRTId == AccountUtils.agencyAccountRtId || accRTId == AccountUtils.repFirmRtId || accRTId == AccountUtils.inHouseAgencyAccountRtId) 
          && acc.Credit_Status__c != NULL && CommonUtilities.isStringNullOrEmpty(acc.AOS_Account_Id__c) ) 
        {
          accIds.add(acc.Id);
        }
      }
      System.debug('OnAfterInsert accIds>>>>>'+accIds.Size());
      if(accIds.size()>0){
        AOSWebServiceHelper.sendReqToUpsertAOSAccount(accIds);
      }
      //END: SRSF-4341     
  }

  /*public static void OnAfterInsertAsync(Set<ID> newAccountIDs){
    //Example usage
    //List<Account> newAccounts = [select Id, Name from Account where Id IN :newAccountIDs];
  }*/

  public void OnBeforeUpdate(Account[] oldAccounts, Account[] updatedAccounts, Map<ID, Account> AccountMap){

 //// SRSF-668      // SRSF-668
    
    //Restrict Boomi sync from switching rep firm to agency record type
    List<Id> updatedAccountIDs = new List<Id>();
    Set<Id> agencyToAdvertiser = new Set<Id>();

    Id agencyRT = AccountUtils.agencyAccountRtId;
    Id advertiserRT = AccountUtils.localAdvertiserAccountRtId;
    Id repFirmRT = AccountUtils.repFirmRtId;
    Id inHouseAgencyRT = AccountUtils.inHouseAgencyAccountRtId;

    for(Account acc: oldAccounts)
    {
      Account updatedAccount = AccountMap.get(acc.Id);      
      //Start: SRSF-2668     
      if (acc.RecordTypeId != updatedAccount.RecordTypeId) {
          System.debug('Updating from Agency::'+(acc.RecordTypeId == agencyRT));
          System.debug('Updating to Advertiser::'+(updatedAccount.RecordTypeId == advertiserRT));
          if(acc.RecordTypeId == agencyRT && updatedAccount.RecordTypeId == advertiserRT){
              agencyToAdvertiser.add(acc.Id);
          }
          // Start: SRSF-3744
          if((acc.RecordTypeId == agencyRT || acc.RecordTypeId == repFirmRT || acc.RecordTypeId == inHouseAgencyRT) && updatedAccount.RecordTypeId == advertiserRT){
              updatedAccount.Discount_Percentage__c = null; 
          }
          if((updatedAccount.RecordTypeId == agencyRT || updatedAccount.RecordTypeId == repFirmRT || updatedAccount.RecordTypeId == inHouseAgencyRT) && acc.RecordTypeId == advertiserRT && updatedAccount.Discount_Percentage__c==null){
              updatedAccount.Discount_Percentage__c = 15; 
          }
          // End: SRSF-3744
      }
      //End: SRSF-2668

      if(UserInfo.getUserName() == Label.BoomiUser && acc.RecordTypeId == AccountUtils.repFirmRtId
         && AccountMap.get(acc.Id).RecordTypeId == AccountUtils.agencyAccountRtId){
          AccountMap.get(acc.Id).RecordTypeId = AccountUtils.repFirmRtId;   
      }

      // Billing Sync Logic  (pre SRSF-668)
      //Account updatedAccount = AccountMap.get(acc.ID); -- commented for SRSF-2668
      //SRSF-4236 - TIM Billing Sync is not needed.
       // if(acc.Billing_Change_Status__c != updatedAccount.Billing_Change_Status__c && updatedAccount.Billing_Change_Status__c == System.Label.TimBillingSyncApproval_Status)
      //{
      //      updatedAccountIDs.add(updatedAccount.Id);            
      //  }
        //**** SRSF-945 : IB : START *****
        // Brett commenting this out for the 1071 deployment
        //Uncommented Again
        if (acc.RecordTypeId != updatedAccount.RecordTypeId) {
            if (AccountUtils.repFirmRtId == AccountMap.get(acc.Id).RecordTypeId) {
                //updatedAccount.UpdateOppFromAccount__c = AccountUtils.ACC_REC_TYPE_CHANGED;
                updatedAccount.UpdateOppFromAccount__c = AccountUtils.ACC_REC_TYPE_AGENCY_TO_REP_FIRM;
            }
            else if (UserInfo.getUserName() != Label.BoomiUser && AccountUtils.agencyAccountRtId == AccountMap.get(acc.Id).RecordTypeId) {
                //updatedAccount.UpdateOppFromAccount__c = AccountUtils.ACC_REC_TYPE_CHANGED;
                updatedAccount.UpdateOppFromAccount__c = AccountUtils.ACC_REC_TYPE_REP_FIRM_TO_AGENCY;
            }
        }
        //**** SRSF-945 : IB : END *****

        //START - 12MAR2019 - Added below code for Account Physical Address validation
        if(AccountMap.get(acc.Id).ShippingStreet != acc.ShippingStreet || 
            AccountMap.get(acc.Id).ShippingCity != acc.ShippingCity ||
            AccountMap.get(acc.Id).ShippingState != acc.ShippingState ||
            AccountMap.get(acc.Id).ShippingCountry != acc.ShippingCountry ||
            AccountMap.get(acc.Id).ShippingPostalCode != acc.ShippingPostalCode){ 
             
              updatedAccount.ShippingAddrLastRetryDate__c =null;
              updatedAccount.Address_Validation_Retry_Count__c = 0;
              if(AccountMap.get(acc.Id).Is_Address_Validation_Pending__c == false){ 
                updatedAccount.Is_Address_Validation_Pending__c = true;
              }   
        }
        //END - 12MAR2019 
    }

    //Start SRSF-2632/SRSF-2668
    if(!agencyToAdvertiser.isEmpty()){
          for(AggregateResult groupedResults : [SELECT Agency__c, COUNT(Id) tot FROM Account WHERE Agency__c!=NULL AND Agency__c IN :agencyToAdvertiser GROUP BY Agency__c HAVING COUNT(Id) > 0]){
                Integer tot = (Integer)(groupedResults.get('tot'));
                System.debug(groupedResults.get('Agency__c')+'**'+tot);
              if(tot > 0)
              {
                  String errMesg = String.format(System.Label.Cannot_Convert_Account_Record_Type, new List<String> {'advertiser(s)'});               
                  updatedAccounts[0].addError(errMesg); 
              }
          }
    } 
    isRecordTypeChangeAllowed(oldAccounts, updatedAccounts, AccountMap, advertiserRT, agencyRT, repFirmRT, inHouseAgencyRT);
    //END SRSF-2632/SRSF-2668
    //SRSF-4236 - TIM Billing Sync is not needed.
    //if(updatedAccountIDs.size() > 0 && Boolean.valueOf(Label.Account_Billing_Sync_Enablement)){
    //  AccountBillingSync.syncAccounts(updatedAccountIDs);
    //} 
        
/*
    //Billing Sync Logic  (SRSF-668)
    Account updatedAccount = AccountMap.get(acc.ID);
        if(acc.Billing_Change_Status__c != updatedAccount.Billing_Change_Status__c && updatedAccount.Billing_Change_Status__c == System.Label.TimBillingSyncApproval_Status)
        {
            updatedAccountIDs.add(updatedAccount.Id)
         //   AccountBillingSync.syncAccounts(updatedAccount.id);
        }
    }
    if (updatedAccountIDs.size() > 0) {
        AccountBillingSync.syncAccounts(updatedAccountIDs);
    }
    // end of SRSF-668 updates
    */
    
    //Example Map usage
    //Map<ID, Contact> contacts = new Map<ID, Contact>( [select Id, FirstName, LastName, Email from Contact where AccountId IN :AccountMap.keySet()] );
  }

  public void OnAfterUpdate(Account[] oldAccounts, Account[] updatedAccounts, Map<ID, Account> AccountMap){
      /*List<Id> accountIds = new List<Id>();
      List<Id> accountOppIds = new List<Id>();
      commenting re: SRSF-947
      */
	  //SRSF - 4804 prevent Account team member records from creation when any user creates or edits a task.
      // Whenever the task is created a process Builder updates the Custom Field on Account for Last Activity Updated Date
      List<Account> accListToBeUpdated = new List<Account>();
      for(Account acc: oldAccounts)
      {
        if(accountMap.containskey(acc.ID) && acc.Last_Updated_or_Activity__c == accountMap.get(acc.ID).Last_Updated_or_Activity__c )
          accListToBeUpdated.add(accountMap.get(acc.ID));
      }
     // ChangeAccountOwner.addAccountTeamMembers(updatedAccounts); // SRSF-1125
      ChangeAccountOwner.addAccountTeamMembers(accListToBeUpdated); // SRSF-1125

      //START: SRSF-4705 
      Set<Id> accIds = new Set<Id>();      
      Id advRT = AccountUtils.localAdvertiserAccountRtId;
      Id agencyRT = AccountUtils.agencyAccountRtId;
      Id repFirmRT = AccountUtils.repFirmRtId;
      Id inHouseAgencyRT = AccountUtils.inHouseAgencyAccountRtId;

      for(Account oldAcc: oldAccounts)
      { 
        Account updatedAcc =  AccountMap.get(oldAcc.Id);

        Id accRT = updatedAcc.RecordTypeId;

        //SRSF-4341 : If Credit Status is updated for Account send req to AOS
        //SRSF-5136: Removal of Credit Status check: Credit_Status__c != 'Past Due/Denied'               
        if( oldAcc.Credit_Status__c == NULL  
          && oldAcc.Credit_Status__c != updatedAcc.Credit_Status__c          
          && CommonUtilities.isStringNullOrEmpty(updatedAcc.AOS_Account_Id__c)
          && (accRT == advRT || accRT == agencyRT || accRT == repFirmRT || accRT == inHouseAgencyRT)) 
        {    
            accIds.add(updatedAcc.Id);
        }
        //SRSF-4705 : If Name/Credit Status is updated for Advertiser/Agency/Repfirm/Inhouse Agency, send req to AOS
        //SRSF-5136 : Updated below logic to remove a check on Credit_Status__c != 'Past Due/Denied'
        else if( (oldAcc.Name != updatedAcc.Name      
          || oldAcc.Credit_Status__c != updatedAcc.Credit_Status__c) 
          && !CommonUtilities.isStringNullOrEmpty(updatedAcc.AOS_Account_Id__c)
          && (advRT == accRT || agencyRT == accRT || repFirmRT == accRT || inHouseAgencyRT == accRT)) 
        {    
            accIds.add(updatedAcc.Id); 
        }
      }
      System.debug('sendReqToUpsertAOSAccount accIds--->>>>>'+accIds.Size());
          
      // SRSF-4705: Added if condition to upsert all the Accounts in AOS 
      if(accIds.size()>0){  
         AOSWebServiceHelper.sendReqToUpsertAOSAccount(accIds);
      } 
      /* 
      START  commenting re: SRSF-947
      NOTES: this section no longer does anything:
      - as noted below in SRSF-945 comment notes, the recordTypeId is now handled in UpdateOpportunityFromAccountBatch batch
      for(Account accountOld: oldAccounts) {
        for(Account accountNew: updatedAccounts) {
          if(accountOld != null && accountNew != null && accountOld.Id == accountNew.Id && accountOld.Name != accountNew.Name) {
            accountIds.add(accountNew.Id);
          }
          
          if(accountOld.recordTypeId != accountNew.recordTypeId){
            system.debug(loggingLevel.WARN, '=====================>> record types are different!');
            accountOppIds.add(accountNew.id);     
          }
        }
      }
      END:   commenting re: SRSF-947
      */

      //**** SRSF-945 : IB : START *****
      /*Commenting as below code has been transferred to UpdateOpportunityFromAccountBatch batch 
      //Update Opportunity AgencyAccount and RepFirm fields based on current Account record type
      if(accountOppIds.size() > 0){ 
        List<String> opptyJSONList = new List<String>();
        List<Opportunity> updateOppList = new List<Opportunity>();   
        system.debug(loggingLevel.WARN, '============================>> accountOppIds = ' + accountOppIds);   
        for(Opportunity opp: [Select id, agency_account__c, rep_firm__c,agency_account__r.recordtype.name,stageName,Number_of_Linear_Proposals__c,recordtypeId from Opportunity where agency_account__c in: accountOppIds]){
          system.debug(loggingLevel.WARN, '============================>> opp = ' + opp);
          //if Opp.AgencyAccount is changed to RepFirm Account and Opp.RepFirm is blank, update RepFirm with AgencyAccount value
          if(opp.agency_account__r.recordtype.name == 'Rep Firm'){
            system.debug(loggingLevel.WARN, '============================>>  account is Rep Firm!!!');
            if(String.isBlank(opp.rep_firm__c)){
              system.debug(loggingLevel.WARN, '============================>> Setting opp.rep_firm__c to: ' + opp.agency_account__c);
              opp.rep_firm__c = opp.agency_account__c;
            }
            //if Opp.AgencyAccount is changed to RepFirm Account, clear value in that field
            opp.agency_account__c = null;
            
            if(opp.Number_of_Linear_Proposals__c > 0){
              opp.recordtypeId = OpportunityUtils.nationalLockedOpportunityRtId;
            }
            else{
              opp.recordtypeId = OpportunityUtils.nationalOpportunityRtId;
            }
            opptyJSONList.add(JSON.serialize(opp));
            if (opptyJSONList.size() >= 9000) {    // DML limit is 10,000, however using chunks of 9000 because We don't know what other DML opertaions may be happening in this execution context
                AccountTriggerHandler.updateOpportunities(opptyJSONList);
                opptyJSONList.clear();    // reset list for the next batch of 9000
            }
          }
        }
        if (opptyJSONList.size() > 0) {       // this will get called unless there's an even multiple of 9000 opprtunities or no opptys
            AccountTriggerHandler.updateOpportunities(opptyJSONList);
        }
      }*/
      //**** SRSF-945 : IB : END *****       
  }

  //START SRSF-2632
  public static void isRecordTypeChangeAllowed(Account[] oldAccounts, Account[] updatedAccounts, Map<ID, Account> AccountMap, Id advRTId, Id agencyRTId, Id repFirmRTId, Id inHouseAgencyRT) 
  {
      Map<Id, Account> advertiserIds = new Map<Id, Account>();    
      Map<Id, Account> agencyIds = new Map<Id, Account>();
      Map<Id, Account> repfirmIds = new Map<Id, Account>();    
      Map<Id, Account> inHouseIds = new Map<Id, Account>();

      for(Account acc: oldAccounts)
      {
        if(acc.RecordTypeId != AccountMap.get(acc.Id).RecordTypeId)
        {
           if(acc.RecordTypeId == advRTId ) {
              advertiserIds.put(acc.Id, acc);
           }
           else if(acc.RecordTypeId == agencyRTId ) {
              agencyIds.put(acc.Id, acc);
           } 
           else if(acc.RecordTypeId == repFirmRTId ){
              repfirmIds.put(acc.Id, acc); 
           }
           else if(acc.RecordTypeId == inHouseAgencyRT){
              inHouseIds.put(acc.Id, acc);
           }
        }
      }
      System.debug('advertiserIds---->'+advertiserIds.keySet());
      System.debug('agencyIds---->'+agencyIds.keySet());
      System.debug('repfirmIds---->'+repfirmIds.keySet());
      

      //Check If Advertiser/Agency/Repfirm Accounts associated with any Opportunity/proposal, then do not allow record type change
      String skipLogic = System.Label.Skip_Account_Trigger_RecordType_Validation;
      
      if( skipLogic != 'Yes' && !Test.isRunningTest() && (advertiserIds.size()>0 || agencyIds.size() > 0 || repfirmIds.size()>0 || inHouseIds.size()>0))        
      {
        Integer oppCnt = [SELECT count() FROM Opportunity WHERE AccountId IN :advertiserIds.keySet() OR Agency_account__c IN :agencyIds.keySet() OR Agency_account__c IN :inHouseIds.keySet() OR Rep_firm__c IN :repfirmIds.keySet()]; 
        System.debug('oppcnt---->'+oppcnt);
          if(oppCnt > 0)
          {
              String errMesg = String.format(System.Label.Cannot_Convert_Account_Record_Type, new List<String> {'Opportunities'});               
              updatedAccounts[0].addError(errMesg);       
          } 

          if(oppCnt == 0) 
          {
              Integer propCnt = [SELECT count() FROM Proposal__c WHERE Advertiser__c IN :advertiserIds.keySet() OR Agency__c IN :agencyIds.keySet() OR Agency__c IN :inHouseIds.keySet() OR Rep_Firm__c IN :repfirmIds.keySet()];
              System.debug('propCnt---->'+propCnt);
              if(propCnt > 0)
              {
               String errMesg = String.format(System.Label.Cannot_Convert_Account_Record_Type, new List<String> {'Proposals'});               
               updatedAccounts[0].addError(errMesg);        
              }
          }
      }
  }
  //END SRSF-2632

  /*public static void OnAfterUpdateAsync(Set<ID> updatedAccountIDs){
    //List<Account> updatedAccounts = [select Id, Name from Account where Id IN :updatedAccountIDs];
  }*/

  public void OnBeforeDelete(Account[] AccountsToDelete, Map<Id, Account> AccountMap){

  }

  public void OnAfterDelete(Account[] deletedAccounts, Map<Id, Account> AccountMap){
    List<Account_Merge_Event__e> accEvents = new List<Account_Merge_Event__e> ();
    for (Account acc : deletedAccounts)
    {
        accEvents.add(new Account_Merge_Event__e(Merged_Account_ID__c = acc.Id));
    }


    // Call method to publish events
    List<Database.SaveResult> results = EventBus.publish(accEvents);

    // Inspect publishing result for each event
    for (Database.SaveResult sr : results) {
        if (sr.isSuccess()) {
            System.debug('Successfully published event.');
        } else {
            for (Database.Error err : sr.getErrors()) {
                Log4SF.logMessage('AccountTriggerHandler', 'AfterDelete', err.getStatusCode() + ' - ' + err.getMessage(), null, UserInfo.getUserId(), null, '');
                System.debug('Error returned: ' +
                             err.getStatusCode() +
                             ' - ' +
                             err.getMessage());
            }
        }
    }
  }

  /*public static void OnAfterDeleteAsync(Set<ID> deletedAccountIDs){

  }*/

  public void OnUndelete(Account[] restoredAccounts){

  }

  public boolean IsTriggerContext{
    get{ return m_isExecuting;}
  }

  public boolean IsVisualforcePageContext{
    get{ return !IsTriggerContext;}
  }

  public boolean IsWebServiceContext{
    get{ return !IsTriggerContext;}
  }

  public boolean IsExecuteAnonymousContext{
    get{ return !IsTriggerContext;}
  }
/*  not used.  noticed this during coding of 1071
  // SRMSUC-528 - add user creating the account as an account team member
  @TestVisible private static void addUserToAcctTeam(List<Account> accounts) {
    List<AccountTeamMember> atms = new List<AccountTeamMember>();
    List<AccountShare> sharingRules = new list<AccountShare>();

    User currentUser = [select Id, Name, Team_Role__c from User where Id = :UserInfo.getUserId()];
    if (currentUser.Team_Role__c == null || currentUser.Team_Role__c == '') {
      currentUser.Team_Role__c = 'Other';
    }

    system.debug(loggingLevel.WARN, '=========>> currentUser = ' + currentUser);
    for(Account acc : accounts) {
      String teamRole = (acc.Spectrum_Reach_Preferred__c == true) ? 'Preferred' : currentUser.Team_Role__c;
      system.debug(loggingLevel.WARN, '=========>> acc.Id = ' + acc.Id);
      System.debug('@@teamRole '+teamRole);

      if (teamRole == 'Preferred' || Trigger.isInsert) {
        System.debug('@@entered ');
        atms.add(new AccountTeamMember( AccountId = acc.Id,
                        TeamMemberRole = teamRole,
                        UserId = currentUser.Id)
        );
        sharingRules.add(new AccountShare(AccountId = acc.Id,
                          AccountAccessLevel = 'Edit',
                          OpportunityAccessLevel = 'Edit',
                          UserOrGroupId = currentUser.Id)
        );
      }

    }
    if (atms.size() > 0) {
      try {
        insert atms;
        insert sharingRules;
      } catch (Exception ex) {
        system.debug(loggingLevel.Error, 'Error in AccountTriggerHandler.addUserToAcctTeam: ' + ex.getMessage());
      }
    }
  } */
      /* 
      START  commenting re: SRSF-947
      NOTES: this section no longer does anything:

  @TestVisible @future private static void updateOpportunities(List<String> opptyList) {
    system.debug(loggingLevel.WARN, '------------------------->> in updateOpportunities!!!');
      if (opptyList != null && opptyList.size() > 0) {
          List<Opportunity> opptyUpdateList = new List<Opportunity>();
          for (String opptyStr : opptyList) {
              opptyUpdateList.add((Opportunity) JSON.deserialize(opptyStr, Opportunity.class));
          }
          try {
              update opptyUpdateList;
          } catch(Exception ex) {
              system.debug ('===============>> AccountTriggerHandler.updateOpportunities: Error updating opportunities: ' + ex.getMessage());
          }
      }
  }
  */
}