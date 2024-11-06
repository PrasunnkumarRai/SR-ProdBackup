/*
    Customer/Project:   Spectrum Reach 
    Class name:         OpportunityTriggerHandler
    Author/Date:        Brett Ballantyne    5/1/2017
    Release:            TBD
    Related US:         264
    Purpose:            Provides handler methods for the Opportunity Trigger
    Modification History : B Ballantyne - added call to ChangOpptyOwner.insertOpptyTeam - 06-02-2017
                           Brett Ballantyne - 6/29/18 - SRSF-1125
                           Brett Ballantyne - 7/5/18  - SRSF-1131

  // This should be used in conjunction with the ApexTriggerComprehensive.trigger template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx
  // Brett's note - I'm a believer in trigger frameworks, and I've implemented more complex and capable frameworks than this before,
  // but this is a start and should be sufficient for now.  If we end up doing a lot more oppty trigger work, I would recommend
  // we go with something more comprehensive

*/

public with sharing class OpportunityTriggerHandler {

  public static boolean isOppTrendRecordAlreadyInserted = false;
  public static boolean isOppUpdateForStageChange = false;
  public static Integer oppTrendCount = 0;
  private boolean m_isExecuting = false;
  private Integer BatchSize = 0;
  public static Map<Id, Account> oppAcctsMap; // SRSF-3744
  public static List<Id> opptyAccts; // SRSF-3744
  //OnBeforeInsert
  public static Account acc;
  public static List<UserConnection__c> lstUC;
  // public static User currentUser;  // Commented for SRSF-3150
  public static List<Account> myNetWrkAcc;
  public static List<Account> myAccLst;
  //InsertDefaultOpptyTeam
  public static User currentUser1;
  public static List<UserTeamMember> defaultOpptyTeam; 
  public static List<Proposal__c> myPropsalTr;
  //OnBeforeUpdate
  public static List<User> usrProfileId1;
  public static Map<Id, User> userMap;
  public static Map<ID,Account> accMap;
  
  public static List<Opportunity> oppAfteInse;
  //OnAfterUpdate
  public static List<Opportunity> lstNewOpp;
  Public static List<Account> allAccounts;

  public OpportunityTriggerHandler(boolean isExecuting, integer size){
    m_isExecuting = isExecuting;
    BatchSize = size;
  }

  public void OnBeforeInsert(Opportunity[] newOpportunitys)
  {
    System.debug('new opportunity are :::: ' + newOpportunitys);
    List<Id> lstOppOwner = new List<Id>();
    Map<Id, Account> mapOppToAccount = new Map<Id,Account>(); // SRSF-2675
    try{
        List<String> aeList = new List<String>();
        List<Id> allAccountIds = new List<Id>();        
        Map<Id,Id> mapOppToAcc = new Map<Id,Id>();
        opptyAccts = new List<Id>(); // SRSF-3744
        for(Opportunity opp: newOpportunitys){
            if(opp.AccountId != null){
                allAccountIds.add(opp.AccountId);                
                mapOppToAcc.put(opp.Id,opp.AccountId);
                opptyAccts.add(opp.AccountId); // SRSF-3744
            }
            System.debug('allAccounts Ids are ::::: ' + allAccountIds);
            //Start: SRSF-3744
            if(opp.Agency_Account__c != null){                
                opptyAccts.add(opp.Agency_Account__c); 
            } 
            if(opp.Rep_Firm__c != null){                
                opptyAccts.add(opp.Rep_Firm__c); 
            } 
            //End: SRSF-3744          
            if(String.isNotBlank(opp.AE_Id__c )){
                aeList.add(opp.AE_Id__c );
            }
            System.debug('opp Owner>>>>'+opp.OwnerId);
            lstOppOwner.add(opp.OwnerId);
        }
        System.debug('lstOppOwner ::: ' + lstOppOwner);
        
        //SRSF-2675: Added Co_Op_Customer__c in SOQL
        if(allAccountIds.size()>0){
            System.debug('going in if');
                 System.debug('lstOppOwner in if ::: ' + lstOppOwner);
            System.debug('allAccounts Ids in ifare ::::: ' + allAccountIds);

           allAccounts = [SELECT Id,Name,OwnerId,RecordTypeId,Networks_to_Avoid__c,AE_of_First_Opportunity__c,Count_of_Opportunities__c, Co_Op_Customer__c, 
                           (SELECT Id,User__c,Tier_Designation__c,Account__c,SAM_Designation__c FROM Account_SAM_Mappings__r WHERE Account__c IN :allAccountIds)
                           FROM Account WHERE Id IN:allAccountIds];
            System.debug('allAccounts ::: ' + allAccounts);
        }
        System.debug('allAccounts :::: ' + allAccounts);
        //Added logic for SRSF-2550 start
        Map<Id,Id> mapAccidToSAMUserid = new Map<Id,Id>();
        Map<Id,List<Account_SAM_Mapping__c>> mapAccidToSAMList = new Map<Id,List<Account_SAM_Mapping__c>>();
        if(!allAccounts.isEmpty()){
            for(Account objAcc : allAccounts){
                mapAccidToSAMList.put(objAcc.Id,objAcc.Account_SAM_Mappings__r);
                mapOppToAccount.put(objAcc.Id, objAcc); //SRSF-2675
            }
        }
        oppAcctsMap = new Map<Id, Account> ([Select Id, Name, Discount_Percentage__c FROM Account WHERE Id IN :opptyAccts]); // SRSF-3744
        for(Opportunity opp: newOpportunitys){
            boolean isTierfound = false;
            boolean isSAMfound = false;
            String tierDesignation;
            String samdesignation;
            if(opp.AccountId!=null && mapAccidToSAMList.containsKey(opp.AccountId)){
                List<Account_SAM_Mapping__c> lstSAM = mapAccidToSAMList.get(opp.AccountId);
                if(!lstSAM.isEmpty()){
                    for(Account_SAM_Mapping__c objSAM : lstSAM){
                        if(opp.AccountId == objSAM.Account__c && objSAM.Tier_Designation__c != null){
                            isTierfound = true;
                            tierDesignation = objSAM.Tier_Designation__c;
                            break;
                        }
                    }
                    if(System.label.SAMDesignationShutDown == 'FALSE'){
                      for(Account_SAM_Mapping__c objSAM : lstSAM){
                        if(opp.ownerid == objSAM.User__c){
                            isSAMfound = true;
                            samdesignation = objSAM.SAM_Designation__c;
                            break;
                        }
                      }
                    }
                }
            }
            opp.Tier_Designation__c = (isTierfound==true)? tierDesignation : null;
            opp.SAM_Designation__c = (isSAMfound==true)? samdesignation : null;
            //opp.Account_SAM_Mapping_User__c = (isfound==true)? opp.ownerId : null;            
            opp.Discount_Percentage__c =populateDiscountPercentage (opp, oppAcctsMap);  //SRSF-3744
            opp.Discount_Code__c = populateDiscountCode (opp, oppAcctsMap); //SRSF-4957
        }
        //logic for SRSF-2550 end
        
        //system.debug(loggingLevel.WARN, '==========>> before the if, newOpportunitys = ' + newOpportunitys);
        if (newOpportunitys.size() == 1 && newOpportunitys[0].Created_By_Account_Executive__c == true) {
            System.debug(loggingLevel.WARN, '===========>> in the if!!!');
            Opportunity opp = newOpportunitys[0];
            if (opp.AccountId != null && opp.Temp_AE_Id__c != null ) {            
               if(acc== null)
                acc = allAccounts[0];
                //acc = [SELECT Id, AE_of_First_Opportunity__c, Count_of_Opportunities__c FROM Account WHERE Id = :opp.AccountId];
                //system.debug(loggingLevel.WARN, '------->>OnBeforeInsert, acc = ' + acc);
                if (acc.Count_of_Opportunities__c <= 1 ) {
                  acc.AE_of_First_Opportunity__c = opp.Temp_AE_Id__c;
                  try {
                    UPDATE acc;
                  } catch (Exception ex) {
                      System.debug(loggingLevel.ERROR, 'OpportunityTriggerHandler.OnBeforeInser: error updating Account: ' + ex.getMessage());
                  }
                }
            }
        }
        
        Map<String,UserConnection__c> ucMap = new Map<String,UserConnection__c>();
        
        if(lstUC==null && aeList.size()>0)
        lstUC=[SELECT User__c,AE_Id__c,TIM_System__c FROM UserConnection__c WHERE AE_Id__c IN :aeList];
        if(lstUC!=null){
            for (UserConnection__c uc:lstUC){        
              if(String.isNotBlank(uc.AE_Id__c)||String.isNotBlank(uc.TIM_System__c))
                ucMap.put(uc.AE_Id__c+uc.TIM_System__c,uc);
            }        
            
            for(Opportunity opp: newOpportunitys){
                if(!ucMap.isEmpty() && ucMap.containsKey(opp.AE_Id__c + opp.TIM_System__c ) && String.isNotBlank(opp.AE_Id__c )){
                    opp.OwnerId=ucMap.get(opp.AE_Id__c +opp.TIM_System__c).User__c;
                }
            }
        }        
    }
    catch(Exception ex){
        System.debug('Exception in Opportunity.AE to owner mapping: ' + ex + ex.getLineNumber());
    }

    // Commented for SRSF-3150
    /*
    if(currentUser==null)
        currentUser = [SELECT Id, Name, Sales_Office__c, Region__c, Division__c FROM User WHERE Id = :UserInfo.getUserId()];
    */    
    
    List<Id> accountIds = new List<Id>();
    Set<Id> setAE = new Set<Id>();
    for(Opportunity opp: newOpportunitys) {
      accountIds.add(opp.AccountId);
      setAE.add(opp.OwnerId);
    }
    Map<Id,String> accNetworksToAvoid = new Map<Id,String>();
    // the code commented out is a misunderstanding of SRSF-382.  Leaving here in case requirements morph
    //  Map<Id, Account> accountMap = new Map<Id, Account>();
    if(!CommonUtilities.isListNullOrEmpty(allAccounts) && allAccounts.size() > 0) {
       //myNetWrkAcc= [SELECT Id, Networks_to_Avoid__c FROM Account WHERE Id IN :accountIds];
    //    for(Account acc : [SELECT Id, Networks_to_Avoid__c, AE_of_First_Opportunity__c, Count_of_Opportunities__c FROM Account WHERE Id IN :accountIds]) {
        for(Account acc : allAccounts) {
            accNetworksToAvoid.put(acc.Id, acc.Networks_to_Avoid__c);
        //     if (acc.Count_of_Opportunities__c == 0) {
        //         accountMap.put(acc.Id, acc);
        //     }
        }
    }
    String recTypeStr = SObjectLookupController.getOpportunityRecordType();   

    // Start: SRSF-3150 : 14-07-2021
    System.debug('setAE>>>>'+setAE);
    Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name, Sales_Office__c, Region__c, Division__c FROM User WHERE Id IN :setAE]); 
    // End: SRSF-3150 : 14-07-2021

    // Set<Account> acctsToUpdate = new Set<Account>();
    for(Opportunity oppty : newOpportunitys) {
      // SRSF-1131 - set system probablity field to custom probability field value
    oppty.Sales_Probability__c = (oppty.Probability == null) ? '10' : String.valueOf(Integer.valueOf(oppty.Probability));

      // SRSF - 196 - populate these fields from the User object
      /* // Commented for SRSF-3150
      oppty.Owner_Sales_Office__c = currentUser.Sales_Office__c;
      oppty.Owner_Region__c = currentUser.Region__c;
      oppty.Owner_Division__c = currentUser.Division__c;*/

      // Start: SRSF-3150 : 14-07-2021 : Populating from Opp Owner now      
      System.debug('userMap>>>>'+userMap);
      System.debug('userMap details>>>>'+userMap.get(oppty.OwnerId));
      oppty.Owner_Sales_Office__c = userMap.get(oppty.OwnerId).Sales_Office__c;
      oppty.Owner_Region__c = userMap.get(oppty.OwnerId).Region__c;
      oppty.Owner_Division__c = userMap.get(oppty.OwnerId).Division__c;
      // End: SRSF-3150 : 14-07-2021

      /*
      Account acct = accountMap.get(oppty.AccountId);
      if (acct != null) {
          acct.AE_of_First_Opportunity__c = String.valueOf(oppty.OwnerId);
          acctsToUpdate.add(acct);
      }
      */
      if(accNetworksToAvoid.get(oppty.AccountId) != null) {
        oppty.Networks_to_Avoid__c = accNetworksToAvoid.get(oppty.AccountId);
      }
      System.debug('==========>> oppty.Created_By_Account_Executive__c = ' + oppty.Created_By_Account_Executive__c);
      if (oppty.Created_By_Account_Executive__c == true) {
        if(oppty.recordTypeId != OpportunityUtils.nationalOpportunityRtId) {
        //  String recTypeStr = SObjectLookupController.getOpportunityRecordType();
          oppty.recordTypeId = Id.valueOf(recTypeStr);
        }
        // this is a select in a for loop, which is normally a no-no, but this will only execute when an oppty
        // is created by a user in the GUI, so for simplicity I'm putting it here.  Should never exceed governor limits
        
        //If(accountIds.size()>0 &&  myAccLst== null)
        // myAccLst = [Select Id, Name, OwnerId, RecordTypeId from Account where Id IN :accountIds];
        
        for(Account acc : allAccounts) {
          System.debug('==========>> acc.RecordTypeId = ' + acc.RecordTypeId);
          if(acc.RecordTypeId == AccountUtils.agencyAccountRtId) {
            oppty.recordTypeId = OpportunityUtils.agencyOpportunityRtId;
            System.debug('==========>> oppty.recordTypeId = ' + oppty.recordTypeId);
            oppty.Agency_Account__c = acc.Id;
          }

          // START: SRSF-4392
          if(acc.RecordTypeId == AccountUtils.holdingAccountRtId) {
            oppty.recordTypeId = OpportunityUtils.holdingAcctOpportunityRtId;
            System.debug('==========>> oppty.recordTypeId = ' + oppty.recordTypeId);
            oppty.Holding_Account__c = acc.Id;
          }
          // END: SRSF-4392
        }
      }
    }

    //Changes for the Boomi User to switch the Agency/RepFirm to the appropiate fields.
    CheckForAgencyAndRepFirm(newOpportunitys);
           
      //Added by Madhusudhan on Oct 22-2018 for SRSF-1322
      Set<String> setAcc = new Set<String>();//Holds Advertiser/Agency
      for(Opportunity opp: newOpportunitys){
          if(opp.AccountId !=null)
              setAcc.add(opp.AccountId);
          if(opp.Agency_Account__c !=null)
              setAcc.add(opp.Agency_Account__c);
      }
      if(!setAcc.isEmpty()){
          Map<String,Boolean> mapAccPref = new Map<String,Boolean>();
          for(Account objAcc : [SELECT Id,Spectrum_Reach_Preferred__c FROM Account WHERE Id IN : setAcc]){
            mapAccPref.put(objAcc.Id,objAcc.Spectrum_Reach_Preferred__c);
          }
          for(Opportunity opp: newOpportunitys){
            if(opp.AccountId !=null || opp.Agency_Account__c !=null){
              boolean isAdvPref = false;
              if(mapAccPref.containskey(opp.AccountId))
                isAdvPref = mapAccPref.get(opp.AccountId);
              boolean isAgencyPref = false;
              if(mapAccPref.containskey(opp.Agency_Account__c))
                isAgencyPref = mapAccPref.get(opp.Agency_Account__c);
              if(isAdvPref==true || isAgencyPref==true)
                opp.Spectrum_Reach_Preferred__c = true;
            }
          }
      }// end of SRSF-1322

      //SAM Designation Mapping
      if(System.label.SAMDesignationShutDown == 'FALSE'){
        Map<String,String> mapAdvAEToSAM = new Map<String,String>();
        if(!accountIds.isEmpty()){
            for(Account_SAM_Mapping__c objAcc : [SELECT Id,SAM_Designation__c,User__c,Account__c FROM Account_SAM_Mapping__c WHERE Account__c IN :accountIds OR User__c IN :setAE]){
                  mapAdvAEToSAM.put(String.valueOf(objAcc.Account__c)+String.valueOf(objAcc.User__c), objAcc.SAM_Designation__c);
            }
        }
        for (Opportunity opp : newOpportunitys) {
              if(String.isNotBlank(opp.accountId) && String.isNotBlank(opp.OwnerId) && mapAdvAEToSAM.containsKey(String.valueOf(opp.accountId)+String.valueOf(opp.OwnerId))){
                if(mapAdvAEToSAM.get(String.valueOf(opp.accountId)+String.valueOf(opp.OwnerId)) == 'Key'){
                    opp.Key_Account_Opportunity__c = true;
                }
              }else{
                opp.Key_Account_Opportunity__c = false;
              }
        } 
      }
      

      //Start : SRSF-2675
      for (Opportunity opp : newOpportunitys) 
      {        
        Account acct = mapOppToAccount.get(opp.AccountId);
          System.debug('what is acct :::: ' + acct);
          System.debug('opp.AccountId ::: ' + opp.AccountId);
          System.debug('opp.CoOp__c ::: ' + opp.CoOp__c);
        //  System.debug('acct.RecordTypeId ::: ' + acct.RecordTypeId);
          System.debug('AccountUtils.localAdvertiserAccountRtId ::::: '+ AccountUtils.localAdvertiserAccountRtId);
        //if (!Test.isRunningTest()) {  
        if(opp.AccountId !=null && !opp.CoOp__c && acct.RecordTypeId == AccountUtils.localAdvertiserAccountRtId) {
            opp.CoOp__c = acct.Co_Op_Customer__c;
        //} 
        
        System.debug('Tier Designation: '+ opp.Tier_Designation__c);
      }
      }
      //End : SRSF-2675      
  }


  public static void InsertDefaultOpptyTeam(Opportunity[] opptys) {
      if(currentUser1==null)
      currentUser1 = [SELECT Id, Name, Team_Role__c FROM User WHERE Id = :UserInfo.getUserId()];
    if(defaultOpptyTeam==null)
      defaultOpptyTeam = [SELECT Id, OpportunityAccessLevel, TeamMemberRole, UserId FROM UserTeamMember WHERE Ownerid = :currentUser1.Id];
      if (defaultOpptyTeam.size() == 0) 
        return;
      List<OpportunityTeamMember> otms = new List<OpportunityTeamMember>();
      for (Opportunity opp : opptys) {
        if (opp.Created_By_Account_Executive__c == true) {
          for (UserTeamMember utm : defaultOpptyTeam) {
            otms.add(new OpportunityTeamMember(UserId = utm.UserId,
                        OpportunityId = opp.Id,
                        OpportunityAccessLevel = utm.OpportunityAccessLevel,
                        TeamMemberRole = utm.TeamMemberRole));
          }            
        }
      }
      if (otms.size() > 0)
        ChangeOpptyOwner.insertOpptyTeam(otms);
  }


  /*
    Author : MAndS 
    Date   : 11/05/2017
    Description : When a user's Opportunity Value reaches a certain threshold, then their manager should receive a notification.
  */    
  public void OnAfterInsert(Opportunity[] newOpportunitys){
   try{
        List<Opportunity> lstOpps = new List<Opportunity> ();
        Map<String,Id> mapUserRole = new Map<String,Id> ();
        Set<Id> acctIds = new Set<Id>();
        if(oppAfteInse==null)
        oppAfteInse=[SELECT Id, AccountId, Total_Forecast_Amount__c, OwnerId, Owner.UserRoleId FROM Opportunity WHERE Id IN: newOpportunitys];
        
        //SyncplicitySRUtils.CreateSyncplicityFolders(new List<Id>(new Map<Id, Opportunity>(newOpportunitys).keySet()));

        for(Opportunity objOpp :oppAfteInse )
        {
          acctIds.add(objOpp.AccountId);
          if( objOpp.Total_Forecast_Amount__c != null) 
          {
            lstOpps.add(objOpp);
            mapUserRole.put(objOpp.OwnerId,objOpp.Owner.UserRoleId);
          }
        }
        //SRSF-1741
        if(!acctIds.isEmpty()){
            List<Account> lstOpenAccounts = [SELECT Id,Open_Account__c,Open_Account_DMA__c FROM Account WHERE Id IN:acctIds AND Open_Account__c=true];
            for(Account obj : lstOpenAccounts){
                obj.Open_Account__c = false;
                obj.Open_Account_DMA__c = null;
            }
            if(!lstOpenAccounts.isEmpty())
                UPDATE lstOpenAccounts;
        }
        //ChangeOpptyOwner.addPreferredTeamMembers(newOpportunitys);  // SRSF-1125

        /*if(!mapUserRole.isEmpty())
            OppThresholdController.notifyUsersOnThresExceed(lstOpps,mapUserRole);*/
    }
    catch(exception ex)
    {
      System.debug('Exception..'+ex);
    }
  }

  @future 
  public static void OnAfterInsertAsync(String newOppList){
        //Example usage
        //List<Opportunity> newOpportunitys = [select Id, Name from Opportunity where Id IN :newOpportunityIDs];
        //IB: START ** Commenting the Big object code for now as it is failing because of issues at Salesforce end
        //SRSF-3592 - Commenting this Line of Code - As opportunity trends is no longer tracked on Wave Analytics.
        //processOppTrends(newOppList, NULL, true);
        //IB: END ** Commenting the Big object code for now as it is failing because of issues at Salesforce end*/
  }

  public void OnBeforeUpdate(Opportunity[] oldOpportunitys, Opportunity[] updatedOpportunitys, Map<ID, Opportunity> oldOpptyMap, Map<ID, Opportunity> OpportunityMap){
    //Example Map usage
    //Map<ID, Contact> contacts = new Map<ID, Contact>( [select Id, FirstName, LastName, Email from Contact where OpportunityId IN :OpportunityMap.keySet()] );
    List<String> NatRecIds = ((System.Label.National_Profile_IDs).split(','));
    Set<String> NatRecIdSet = new Set<String>();
    NatRecIdSet.addAll(NatRecIds);
    String userProfile = UserInfo.getProfileId().substring(0,15);    

    Set<Id> opprtOwner = new Set<Id>();
    Map<Id,Id> oppOwnerMap = new Map<Id,Id>();
    Set<Id> lostOppIds = new Set<Id>();

    for (Opportunity opp : updatedOpportunitys) {
        opprtOwner.add(opp.OwnerId);
    }

    if(usrProfileId1==null && opprtOwner.size()>0) {
      usrProfileId1 = [SELECT Id,ProfileId FROM User WHERE Id IN :(opprtOwner)];
    }
      
    for(User eachUsr : usrProfileId1 ) {
      oppOwnerMap.put(eachUsr.Id,eachUsr.ProfileId);
    }

    Set<Id> ownerIdSet = new Set<Id>();

    for (Opportunity opp : updatedOpportunitys) {
        // SRSF-1131 - set system probablity field to custom probability field value
        
       try{
       if (opp.StageName == 'Closed Won') {
            opp.Sales_Probability__c = '100';
            opp.Probability = 100.0;
        } else if (opp.StageName.startsWith('Closed Lost')) {
            opp.Sales_Probability__c = '0';
            opp.Probability = 0.0;
        } else {
            if(oldOpptyMap.containsKey(opp.id))
            {
              system.debug('Opp Probability ' + oldOpptyMap.get(opp.Id).Sales_Probability__c);
              system.debug('Opp Probability ' + opp.Probability);
              system.debug('Opp Probability ' + Decimal.valueOf(opp.Sales_Probability__c));
              if(oldOpptyMap.get(opp.Id).Sales_Probability__c != opp.Sales_Probability__c && Decimal.valueOf(opp.Sales_Probability__c) > 0  )
                opp.probability = Decimal.valueOf(opp.Sales_Probability__c);
              else
                opp.Sales_Probability__c = (opp.Probability == null) ? '10' : String.valueOf(Integer.valueOf(opp.Probability));
            
            }
            
            if (opp.Sales_Probability__c == null) opp.Sales_Probability__c = '10';
        }
        }catch(System.NullPointerException e){
        
        
        }

        ownerIdSet.add(opp.OwnerId);
        Opportunity oldOpp = oldOpptyMap.get(opp.Id);
        System.debug(loggingLevel.WARN, '==================>> in OnBeforeUpdate, oldOpp.AccountId = ' + oldOpp.AccountId);
        System.debug(loggingLevel.WARN, '==================>> in OnBeforeUpdate, opp.AccountId    = ' + opp.AccountId);

        if (opp.CreatedDate < Datetime.now().addSeconds(-7) && (oldOpp.AccountId != opp.AccountId)) {       // Don't set record type back if the Oppty was created in the last 7 seconds 
          System.debug('================>> updating record type!');                                                                                                  // and accountId hasn't changed
          if (opp.recordTypeId == OpportunityUtils.agencyOpportunityRtId) {
              System.debug('================>> updating Agency__c to: ' + oldOpp.AccountId);
              opp.Agency_Account__c = oldOpp.AccountId;                 // Set the agency account to the old (agency account) accountId

            //  User usrProfileId = [select ProfileId from User where id = :opp.OwnerId][0];
             // String ownerProfile = ((String)usrProfileId.ProfileId).substring(0,15);    
             String ownerProfile = ((String)oppOwnerMap.get(opp.OwnerId)).substring(0,15);  
             
//              if (NatRecIdSet.contains(userProfile)) {
              if (NatRecIdSet.contains(ownerProfile)) {
                  opp.recordTypeId = OpportunityUtils.nationalOpportunityRtId;
              } else {
                  opp.recordTypeId = OpportunityUtils.opportunityRtId;
              }
          }          
        }

    }
     if(userMap==null && ownerIdSet.size()>0)
      userMap = new Map<Id, User>([SELECT Id, Name, Sales_Office__c, Region__c, Division__c FROM User WHERE Id IN :ownerIdSet]);
    for (Opportunity opp : updatedOpportunitys) {
         if(userMap.containsKey(opp.OwnerId)){
            User userRec = userMap.get(opp.OwnerId);
            System.debug(loggingLevel.WARN, '---------->> opp.OwnerId = ' + opp.OwnerId);
            System.debug(loggingLevel.WARN, '---------->> userRec.Sales_Office__c = ' + userRec.Sales_Office__c);
            System.debug(loggingLevel.WARN, '---------->> userRec.Region__c = ' + userRec.Region__c);
            System.debug(loggingLevel.WARN, '---------->> userRec.Division__c = ' + userRec.Division__c);
            opp.Owner_Sales_Office__c = userRec.Sales_Office__c;
            opp.Owner_Region__c = userRec.Region__c;
            opp.Owner_Division__c = userRec.Division__c;
        }
    }
    CheckForAgencyAndRepFirm(updatedOpportunitys);
    
    //New SAM Designation mapping based on Account SAM Mapping object
    Set<Id> accountIds = new Set<Id>();
    Set<Id> setAE = new Set<Id>();    
    for (Opportunity opp : updatedOpportunitys) {
         accountIds.add(opp.AccountId);
         setAE.add(opp.OwnerId);
        
    }    
    System.debug(accountIds); 
    Map<String,String> mapAdvAEToSAM = new Map<String,String>();
    if(!accountIds.isEmpty()){
        List<Account_SAM_Mapping__c> lstSAM = new List<Account_SAM_Mapping__c>();
        Map<Id,Id> mapAccidToSAMUserid = new Map<Id,Id>();
        for(Account_SAM_Mapping__c objAcc : [SELECT Id,Tier_Designation__c,User__c,Account__c,SAM_Designation__c FROM Account_SAM_Mapping__c WHERE Account__c IN :accountIds]){
            if(System.label.SAMDesignationShutDown == 'FALSE'){
              mapAdvAEToSAM.put(String.valueOf(objAcc.Account__c)+String.valueOf(objAcc.User__c), objAcc.SAM_Designation__c);
            }
            lstSAM.add(objAcc);
        }
        
        //Added logic for 2500
        for (Opportunity opp : updatedOpportunitys) {
            boolean isTierfound=false;
            boolean isSamfound = false;
            String tierDesignation;
            String samDesignation;
            if(!lstSAM.isEmpty()){
                for(Account_SAM_Mapping__c objSAM : lstSAM){
                    if(opp.AccountId==objSAM.Account__c && objSAM.Tier_Designation__c != null){
                        isTierfound = true;
                        tierDesignation = objSAM.Tier_Designation__c;
                        break;
                    }
                }

                if(System.label.SAMDesignationShutDown == 'FALSE'){
                  for(Account_SAM_Mapping__c objSAM : lstSAM){
                    if(opp.AccountId==objSAM.Account__c && opp.OwnerId==objSAM.User__c){
                        isSamfound = true;
                        samdesignation = objSAM.SAM_Designation__c;
                        break;
                    }
                  }
                }
            }
            opp.Tier_Designation__c = (isTierfound==true)? tierDesignation : null;
            opp.SAM_Designation__c = (isSamfound==true)? samdesignation : null;
            //opp.Account_SAM_Mapping_User__c = (isfound==true)? opp.ownerId : null;                           
        }
        
        System.debug(mapAdvAEToSAM);
        if(System.label.SAMDesignationShutDown == 'FALSE'){
          for (Opportunity opp : updatedOpportunitys) {
            if(String.isNotBlank(opp.accountId) && String.isNotBlank(opp.ownerId) && mapAdvAEToSAM.containsKey(String.valueOf(opp.accountId)+String.valueOf(opp.OwnerId))){
      
                if(mapAdvAEToSAM.get(String.valueOf(opp.accountId)+String.valueOf(opp.OwnerId)) == 'Key'){
                    opp.Key_Account_Opportunity__c = true;
                    System.debug(opp.Key_Account_Opportunity__c);
                }
            }else{
                opp.Key_Account_Opportunity__c = false;
                System.debug(opp.Key_Account_Opportunity__c);
            }
          }
        }
    }
    
      Map<Id,Opportunity> mapSRPref = new Map<Id,Opportunity>();
      for(Integer i=0;i<updatedOpportunitys.size();i++){
          /*if((updatedOpportunitys[i].ownerId != oldOpportunitys[i].ownerId) || Test.isRunningTest()){
              mapSRPref.put(updatedOpportunitys[i].Id,updatedOpportunitys[i]);
          }
          if(updatedOpportunitys[i].Spectrum_Reach_Preferred__c || Test.isRunningTest()){
              if(SObjectLookupController.acctExecForOppTrg==null)
                mapSRPref.put(updatedOpportunitys[i].Id,updatedOpportunitys[i]);
          }*/
          if(updatedOpportunitys[i].Spectrum_Reach_Preferred__c == true){
              if(SObjectLookupController.acctExecForOppTrg!=null && updatedOpportunitys[i].OwnerId!=Userinfo.getUserId())
                 mapSRPref.put(updatedOpportunitys[i].Id,updatedOpportunitys[i]);
              if(SObjectLookupController.acctExecForOppTrg==null)
                  mapSRPref.put(updatedOpportunitys[i].Id,updatedOpportunitys[i]);
          }
      }
      System.debug('mapSRPref-->'+mapSRPref.values());
      if(!mapSRPref.isEmpty()){
          ChangeOpptyOwner.addPreferredTeamMembers(mapSRPref.values());  // SRSF-1125
      }  
      
  }

  /*
    Author : MAndS 
    Date   : 11/05/2017
    Description : When a user's Opportunity Value reaches a certain threshold, then their manager should receive a notification.
    Modification History : 
  */
  public void OnAfterUpdate(Opportunity[] oldOpportunitys, Opportunity[] updatedOpportunitys, Map<ID, Opportunity> OpportunityMap) {
      OnAftrUpdt( oldOpportunitys,updatedOpportunitys,OpportunityMap,null);
  }

  public void OnAftrUpdt(Opportunity[] oldOpportunitys, Opportunity[] updatedOpportunitys, Map<ID, Opportunity> OpportunityMap , Map<ID, Opportunity> oldOpptyMap) {
        try{
            System.debug('OnAftrUpdt: ' + updatedOpportunitys);
            
             /*//SRSF-1741
              set<string> acctIds = new set<string>();
              for(Opportunity objOpp : updatedOpportunitys){
                  acctIds.add(objOpp.AccountId);
              }
              System.debug('acctIds::'+acctIds);
              if(!acctIds.isEmpty()){
                  list<Account> lstOpenAccounts = [SELECT Id,Open_Account__c FROM Account WHERE Id IN:acctIds and Open_Account__c!=true];
                  for(Account obj : lstOpenAccounts){
                      obj.Open_Account__c = true;
                  }
                  if(!lstOpenAccounts.isEmpty())
                      update lstOpenAccounts;
              }*/

            List<Opportunity> lstOpps = new List<Opportunity> ();
            Map<String,Id> mapUserRole = new Map<String,Id> ();
            set<string> oppIds = new set<string>(); 
            if(lstNewOpp==null)
            lstNewOpp = [SELECT Id, Total_Forecast_Amount__c, OwnerId, Owner.UserRoleId FROM Opportunity WHERE Id IN: updatedOpportunitys];
            for(integer i=0;i<lstNewOpp.size();i++){
                Opportunity objOpp = lstNewOpp[i];
                Opportunity objOppOld = oldOpptyMap.get(lstNewOpp[i].id);
                if(objOpp.ownerId!= objOppOld.ownerId){  //Added by khushboo
                  oppIds.add(objOpp.id);
                }
                Decimal totFAmt = (objOppOld.Total_Forecast_Amount__c==null)? 0 : objOppOld.Total_Forecast_Amount__c;
                Decimal totNewFAmt = (OpportunityMap.get(lstNewOpp[i].id).Total_Forecast_Amount__c==null)? 0 : OpportunityMap.get(lstNewOpp[i].id).Total_Forecast_Amount__c;
                objOpp.Total_Forecast_Amount__c = totNewFAmt;
                System.debug('totFAmt: ' + totFAmt);
                System.debug('totNewFAmt: ' +  totNewFAmt);
                
                if( (totNewFAmt != null
                    && totFAmt != totNewFAmt
                    && totFAmt < totNewFAmt))
                {
                    lstOpps.add(objOpp);
                    mapUserRole.put(objOpp.OwnerId,objOpp.Owner.UserRoleId);
                }
            }//SRSF- 4556 Added by khushboo
            
            //Digital Campaign Id Set
            Set<Id> dcIds = new Set<Id>();
            
            // Update Digital Campaign "Account_Executive__c" field with opportunity owner id. 
            List<Digital_Campaign__c> dcList = new List<Digital_Campaign__c>();
            for(Digital_Campaign__c dc : [SELECT Id, Account_Executive__c,Opportunity__r.OwnerId,OwnerId, Opportunity__c FROM Digital_Campaign__c WHERE Opportunity__c IN:oppIds]){
           			dc.Account_Executive__c = dc.Opportunity__r.OwnerId;
                 dc.OwnerId = dc.Opportunity__r.OwnerId;
                	dcIds.add(dc.Id);
            		dcList.add(dc);
            }
            System.debug('dcList:'+dcList);
            if(dcList.size()>0){
            	UPDATE dcList;
            }
            
            System.debug('dcIds:::'+dcIds);
            /// Update Digital Creative "Account_Executive__c" field with opportunity owner id.
             List<Digital_Creative__c> dccList = new List<Digital_Creative__c>();

            // Query Digital Creative records based on Digital Campaign IDs
            for (Digital_Creative__c dcc : [SELECT Id,Digital_Campaign__r.Opportunity__r.OwnerId, Digital_Campaign__c,OwnerID FROM Digital_Creative__c WHERE Digital_Campaign__c IN :dcIds]) {
          	  dcc.Account_Executive__c = dcc.Digital_Campaign__r.Opportunity__r.OwnerId; 
              //dcc.OwnerId = dcc.Opportunity__r.OwnerId;
              dccList.add(dcc);
          }
          System.debug('dccList:::'+dccList);

          System.debug('dccList size:::'+dccList.size());
          if (dccList.size() > 0) {
              System.debug('dccList:::'+dccList);
              update dccList;
          }
            
            
            /*if(!mapUserRole.isEmpty())
                //System.debug('mapUserRole: ' + mapUserRole);
                OppThresholdController.notifyUsersOnThresExceed(lstOpps,mapUserRole);*/ 
        }
        catch(exception ex)
        {
            System.debug('Exception..'+ex);
        }
        
        //Update Opportunity Owner Info on related proposal records
        Set<Id> oppIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>(); //SRSF-4706
        for(Opportunity opp: oldOpportunitys){
            Opportunity updatedOppty =  OpportunityMap.get(opp.Id); //SRSF-4706            
            /* //Commented to use updatedOppty
            if((opp.ownerId != OpportunityMap.get(opp.Id).OwnerId) || Test.isRunningTest()){
                System.debug(opp.OwnerId+'#####'+OpportunityMap.get(opp.Id).OwnerId);
                oppIds.add(opp.Id);
            }*/
            if((opp.ownerId != updatedOppty.OwnerId) || Test.isRunningTest()){
                System.debug(opp.OwnerId+'#####'+updatedOppty.OwnerId);
                oppIds.add(opp.Id);
            }

            //START : SRSF-4706            
            if(opp.Enterprise_Account_Type__c != updatedOppty.Enterprise_Account_Type__c) {
              opportunityIds.add(updatedOppty.Id);
            }
            //END : SRSF-4706
        }

        //SRSF-4706: Added if condition to update all the Deals associated to the Opportunities
        if(opportunityIds.size()>0){
           AOSWebServiceHelper.sendReqToUpdateAOSDealsOfOpportunity(opportunityIds);
        }
      
        if(oppIds.size() > 0){
            List<Proposal__c> updateProposalList = new List<Proposal__c>();
            
             myPropsalTr= [SELECT Id, Division__c, Region__c, Sales_Office__c, Opportunity__c, 
                                         Opportunity__r.Owner.Division__c, Opportunity__r.Owner.Region__c,Opportunity__r.Owner.Sales_Office__c 
                                  FROM Proposal__c 
                                  WHERE Opportunity__c IN: oppIds];
            for(Proposal__c pro: myPropsalTr ){
                updateProposalList.add(new Proposal__c (Id=pro.Id, Division__c=pro.Opportunity__r.Owner.Division__c, Region__c=pro.Opportunity__r.Owner.Region__c,
                  Sales_Office__c=pro.Opportunity__r.Owner.Sales_Office__c));
            }
            
            if(updateProposalList.size() > 0){
            if( !Test.isRunningTest() ){
                UPDATE updateProposalList;
            }
            }
        }

      //SRSF - 1252 Code Added by Abhilash : 19 Sep 2018
      if(!OpportunityTriggerHandler.isOppUpdateForStageChange && oldOpptyMap!=NULL){
        Set<Id> lostOppIds = new Set<Id>();
        OpportunityTriggerHandler.isOppUpdateForStageChange = TRUE;
        System.debug('In Update');
        /*
        for (Opportunity opp : updatedOpportunitys) {
           if(oldOpptyMap.get(opp.Id).StageName != opp.StageName && opp.IsClosed && !opp.IsWon){
              lostOppIds.add(opp.Id);
           }
        }

        System.debug('lostOppIds::::'+lostOppIds);
        if(lostOppIds.size()>0){
            List<UserConnection__c> userConnectionList = [SELECT Id,TIM_System__c,AE_Id__c,User__c,Username__c FROM UserConnection__c WHERE User__c=:UserInfo.getUserId() AND TIM_System__c!=NULL ORDER BY Createddate];
            if(userConnectionList.size()>0){
              Map<String,UserConnection__c> userConnMap = new Map<String,UserConnection__c>();
              for(UserConnection__c userConn : userConnectionList){
                  userConnMap.put(userConn.TIM_System__c,userConn);
              }
              List<Id> lisOfIds = new List<Id>(lostOppIds);
              String queryStr = 'SELECT Id,Active__c,TIM_System__c,Recordtype.Name,TIM_Id__c,(Select Id from Proposal_Zones__r) FROM Proposal__c WHERE Active__c = TRUE AND Opportunity__c  IN ' + '(\'' + String.join(lisOfIds,'\',\'') + '\')';
              Integer batchSize = String.isNotBlank(Label.InactiveProposalsBatch_Size)? Integer.valueOf(Label.InactiveProposalsBatch_Size) : 5;
              InactiveProposalsBatch propBatch = new InactiveProposalsBatch(queryStr ,userConnMap);
               //Id jobId = Database.executeBatch(propBatch,batchSize);
            }
        }
    */
      }
      //SRSF - 1252 Code Ends Here
  }
    //IB: START ** Commenting the Big object code for now as it is failing because of issues at Salesforce end
    /*private static void processOppTrends(String oldOppList, String newOppMap, boolean is_Insert) {
        try {
            List<Opportunity> oppList = (List<Opportunity>)JSON.deserialize(oldOppList, List<Opportunity>.class);
            if(is_Insert) {
                trackOppotunityTrends(oppList, NULL, true);
            }
            else {
                //System.debug('newOppMap : ' + newOppMap);
                Map<Id,Opportunity> oppMap_New = (Map<Id,Opportunity>)JSON.deserialize(newOppMap, Map<Id,Opportunity>.class);
                trackOppotunityTrends(oppList, oppMap_New, false);
            }
        }
        catch (Exception ex) {
          Log4SF.logMessage('OpportunityTriggerHandler', 'trackOppotunityTrends', 'Opportunity Trend Big Object Error',ex, UserInfo.getUserId(),'NA');
        }
    }

    // track fields updates in Big Object
    private static void trackOppotunityTrends(List<Opportunity> listOldOpportunities, map<Id, Opportunity> mapNewOpportunities, boolean isInsert) {
        BigObjectSettings__c oppTrendBO = BigObjectSettings__c.getInstance('OpportunityTrend__b');
        //System.debug('oppTrendBO : ' + oppTrendBO);
        if (Test.isRunningTest()) isOppTrendRecordAlreadyInserted = false;
        if (NULL != oppTrendBO && oppTrendBO.IsActive__c && !isOppTrendRecordAlreadyInserted) {
            List<OpportunityTrend__b> lstOpptyTrends = new List<OpportunityTrend__b>();
            Integer rollingCount = Integer.valueOf(oppTrendBO.Rolling_Index__c);
            for (Opportunity oldOppty : listOldOpportunities) {
                Opportunity oppty = (NULL != mapNewOpportunities) ? mapNewOpportunities.get(oldOppty.Id) : NULL;
                if (isInsert || oppty == NULL) oppty = oldOppty;
                OpportunityTrend__b opptyTrend = new OpportunityTrend__b(Opportunity__c = oppty.Id, Snapshot_Date_Time__c = System.now(),Opportunity_Trend_Name__c = oppty.Name, TIM_System__c = oppty.TIM_System__c);
                // Amount Changed? 
                //System.debug('oldOppty ---> '+oldOppty);
                //System.debug('oppty ---> '+oppty);
                if(isInsert || (!isInsert && NULL != oppty && ((oppty.StageName != oldOppty.StageName) || (oppty.Probability != oldOppty.Probability) || (oppty.Closed_Gross_Amount__c != oldOppty.Closed_Gross_Amount__c) || (oppty.Closed_Net_Amount__c != oldOppty.Closed_Net_Amount__c) || (oppty.Pending_Gross_Amount__c != oldOppty.Pending_Gross_Amount__c) || (oppty.Pending_Net_Amount__c != oldOppty.Pending_Net_Amount__c) || oppty.Projected_Gross_Amount__c != oldOppty.Projected_Gross_Amount__c || (oppty.Projected_Net_Amount__c != oldOppty.Projected_Net_Amount__c)))) {
                    opptyTrend.Amount__c = oppty.Amount;
                    opptyTrend.StageName__c = oppty.StageName;
                    opptyTrend.Probability__c = oppty.Probability;
                    opptyTrend.Closed_Gross_Amount__c = oppty.Closed_Gross_Amount__c;
                    opptyTrend.Closed_Net_Amount__c = oppty.Closed_Net_Amount__c;
                    opptyTrend.Pending_Gross_Amount__c = oppty.Pending_Gross_Amount__c;
                    opptyTrend.Pending_Net_Amount__c = oppty.Pending_Net_Amount__c;
                    opptyTrend.Projected_Gross_Amount__c = oppty.Projected_Gross_Amount__c;
                    opptyTrend.Projected_Net_Amount__c = oppty.Projected_Net_Amount__c;
                    decimal TotalGross = oppty.Closed_Gross_Amount__c + oppty.Pending_Gross_Amount__c + oppty.Projected_Gross_Amount__c;
                    opptyTrend.TotalGross__c = '$' + TotalGross;
                    decimal TotalNet = oppty.Closed_Net_Amount__c + oppty.Pending_Net_Amount__c + oppty.Projected_Net_Amount__c;
                    opptyTrend.TotalNet__c = '$' + TotalNet;
                    opptyTrend.GrossRevenueInfo__c = String.format(System.Label.BO_GrossRevenueInfo, new List<String>{opptyTrend.TotalGross__c,'$' + opptyTrend.Closed_Gross_Amount__c,'$' + opptyTrend.Pending_Gross_Amount__c,'$' + opptyTrend.Projected_Gross_Amount__c});
                    opptyTrend.NetRevenueInfo__c = String.format(System.Label.BO_NetRevenueInfo, new List<String>{opptyTrend.TotalNet__c,'$' + opptyTrend.Closed_Net_Amount__c,'$' + opptyTrend.Pending_Net_Amount__c,'$' + opptyTrend.Projected_Net_Amount__c});
                    //System.debug('BO opptyTrend ---> '+opptyTrend);
                    lstOpptyTrends.add(opptyTrend);
                    isOppTrendRecordAlreadyInserted = true;
                    rollingCount++;
                    opptyTrend.Rolling_Index__c = rollingCount;
                    if (Integer.valueOf(oppTrendBO.Threshold_Index__c) <= rollingCount) rollingCount = 0;
                }
            }
            // Big Object save required? 
            if(!lstOpptyTrends.isEmpty()) {
                insertOppTrends(lstOpptyTrends, rollingCount, oppTrendBO.Id);
            }
        }
    }

    private static void insertOppTrends(List<OpportunityTrend__b> oppTrendRecords, Integer newRollingIndex, Id customSettingId) {
        List<Database.saveResult> results = NULL;
        if(!Test.isRunningTest()) results = Database.insertImmediate(oppTrendRecords);
        boolean incrementRollingIndex = true;
        if (NULL != results) {
            for (Database.saveResult saveRes : results) {
                if (!saveRes.isSuccess()) {
                    incrementRollingIndex = false;
                    break;
                }
            }
        }
        if(incrementRollingIndex) {
            BigObjectSettings__c setting_BO = new BigObjectSettings__c(Id = customSettingId);
            setting_BO.Rolling_Index__c = newRollingIndex;
            UPDATE setting_BO;
        }
    }*/
    //IB: END ** Commenting the Big object code for now as it is failing because of issues at Salesforce end*/
  @future 
  public static void OnAfterUpdateAsync(String oldOppList, String newOppMap, boolean is_Insert) {
      //List<Opportunity> updatedOpportunitys = [select Id, Name from Opportunity where Id IN :updatedOpportunityIDs];
      //IB: START ** Commenting the Big object code for now as it is failing because of issues at Salesforce end
      //SRSF-3867
		//processOppTrends(oldOppList, newOppMap, is_Insert);
      //IB: END ** Commenting the Big object code for now as it is failing because of issues at Salesforce end*/
  }

  public void OnBeforeDelete(Opportunity[] OpportunitysToDelete, Map<ID, Opportunity> OpportunityMap){

  }

  public void OnAfterDelete(Opportunity[] deletedOpportunitys, Map<ID, Opportunity> OpportunityMap){
 
  }

  @future 
  public static void OnAfterDeleteAsync(Set<ID> deletedOpportunityIDs){

  }

  public void OnUndelete(Opportunity[] restoredOpportunitys){

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

  //SRSF - 984 - Aditi : 11th April,2018 : Code changes to check for Opportunity status : closed-lost change proposal recordType to linear for Inventory and Trade
  /*public void updateRecordTypeforProposals(Map<id,Opportunity> newoppIdMap , Map<id,Opportunity> oldoppIdMap){
    Set<String> setOppId = new Set<String>();
    RecordType rtObj = new RecordType();
    for(String oppId : newoppIdMap.keySet()){
      if(newoppIdMap.get(oppId).StageName != oldoppIdMap.get(oppId).StageName && newoppIdMap.get(oppId).StageName == Label.Oppoertunity_CloseLost){
        setOppId.add(oppId);
      }
    }
    System.debug('setOppId'+setOppId);
    if(null != setOppId && setOppId.size() >0){
      //To fetch those proposal having recordType as Inventory or Trade{
      //List<Proposal__c> proposalList = [Select RecordTypeId, RecordType.Name, Opportunity__r.Political_Opportunity__c ,Opportunity__c from Proposal__c where Opportunity__c IN:setOppId and Opportunity__r.Political_Opportunity__c = false];
      List<Proposal__c> proposalList = [Select RecordTypeId, RecordType.Name, Opportunity__r.Political_Opportunity__c ,Opportunity__c from Proposal__c where Opportunity__c IN:setOppId and Opportunity__r.Political_Opportunity__c = false];
      System.debug('proposalList'+proposalList);
      if(null != proposalList && proposalList.size() >0){
        String recordQuery = 'Select id, DeveloperName, Name, Description from RecordType where SobjectType =\'Proposal__c\' AND IsActive = true AND DeveloperName = \''+Label.Linear_RT+'\' limit 1';
        System.debug('query'+recordQuery);
        rtObj = Database.query(recordQuery); 
        for(Proposal__c prop : proposalList){
          prop.RecordTypeId = rtObj.Id;
        }
        Update proposalList;
      }
    }
  }*/

  // Changes for SRSF-1014
  private void CheckForAgencyAndRepFirm(List<Opportunity> oppList)
  {
    if(UserInfo.getUserName() == Label.BoomiUser || Test.isRunningTest())
    {
      Set<Id> oppAccountIds = new Set<Id>();
      for(Opportunity opp: oppList)
      {
        if(String.isNotBlank(opp.Agency_Account__c))
          oppAccountIds.add(opp.Agency_Account__c);
        else if(String.isNotBlank(opp.Rep_Firm__c))
          oppAccountIds.add(opp.Rep_Firm__c);
      }
      
      if(accMap ==null && oppAccountIds.size()>0 )
       accMap = new Map<ID, Account>([SELECT Id, Name, OwnerId, RecordTypeId FROM Account WHERE Id IN :oppAccountIds]);
        
      for(Opportunity Opp : oppList)
      {
        if(String.isNotBlank(opp.Agency_Account__c))
        {
          if(accMap.containsKey(opp.Agency_Account__c))
          {
            if(accMap.get(opp.Agency_Account__c).RecordTypeId == AccountUtils.repFirmRtId)
            {
              opp.Rep_Firm__c = opp.Agency_Account__c;
              opp.Agency_Account__c = null; 
            }                  
          }
        }
        else if(String.isNotBlank(opp.Rep_Firm__c))
        {
          if(accMap.containsKey(opp.Rep_Firm__c))
          {
            if(accMap.get(opp.Rep_Firm__c).RecordTypeId == AccountUtils.agencyAccountRtId)
            {
              opp.Agency_Account__c = opp.Rep_Firm__c;
              opp.Rep_Firm__c = null; 
            }                  
          }
        }  
      }
    }
  }

  //}
  //Code changes ends
    // Start: SRSF-3744
    public Decimal populateDiscountPercentage (Opportunity opp, Map<Id, Account> oppAcctsMap) {        
        Decimal discountValue = 0.0;                    
        if(opp.Agency_Account__c != null && opp.Rep_Firm__c != null){ 
            if (oppAcctsMap.get(opp.Agency_Account__c).Discount_Percentage__c >= oppAcctsMap.get(opp.Rep_Firm__c).Discount_Percentage__c){
                discountValue = oppAcctsMap.get(opp.Agency_Account__c).Discount_Percentage__c;
            } else {
                discountValue = oppAcctsMap.get(opp.Rep_Firm__c).Discount_Percentage__c;
            }                                    
        } else if(opp.Agency_Account__c != null && opp.Rep_Firm__c == null){ 
            discountValue = oppAcctsMap.get(opp.Agency_Account__c).Discount_Percentage__c;             
        } else if(opp.Agency_Account__c == null && opp.Rep_Firm__c != null){   
            discountValue = oppAcctsMap.get(opp.Rep_Firm__c).Discount_Percentage__c;             
        } else if (opp.Agency_Account__c == null && opp.Rep_Firm__c == null){ 
            discountValue = oppAcctsMap.get(opp.AccountId).Discount_Percentage__c;
        }
        discountValue = discountValue != NULL ? discountValue : 0.0;    
        return discountValue;        
    }
    // End: SRSF-3744

    //START : SRSF-4957
    public String populateDiscountCode(Opportunity opp, Map<Id, Account> oppAcctsMap)
    {
        String discountCode;        
        if(opp.Agency_Account__c!=NULL && opp.Rep_Firm__c == NULL)
        {
          if(oppAcctsMap.get(opp.Agency_Account__c).Name == 'Agency 100') //SRSF-5183 : Added IF condition
          {
            discountCode = Label.Default_NCC_RepFirm_DiscCode;
          } 
          else if(oppAcctsMap.get(opp.Agency_Account__c).Name == 'Stellantis Dealer MarketCenter') //SRSF-5206 : Added ELSE IF condition
          {
            discountCode = Label.Default_Zero_Percent_Agency_Discount_Code;
          } 
          else
          {
            discountCode = Label.Default_Agency_Discount_Code;
          }
        } 
        if(opp.Rep_Firm__c!=NULL && oppAcctsMap.get(opp.Rep_Firm__c).Name == 'AMPERSAND')
        {
            discountCode = Label.Default_Ampersand_RepFirm_DiscCode;
        } 
        if(opp.Rep_Firm__c!=NULL && oppAcctsMap.get(opp.Rep_Firm__c).Name == 'NCC/100% DISCOUNT AGENCY')
        {
            discountCode = Label.Default_NCC_RepFirm_DiscCode;
        }
        if(opp.Rep_Firm__c!=NULL && oppAcctsMap.get(opp.Rep_Firm__c).Name == 'NYI NCC Agency')
        {
            discountCode = Label.Default_NYI_NCC_RepFirm_DiscCode;
        }       
        System.debug('discountCode>>>'+discountCode);
    return discountCode;
    }
    //END : SRSF-4957
}