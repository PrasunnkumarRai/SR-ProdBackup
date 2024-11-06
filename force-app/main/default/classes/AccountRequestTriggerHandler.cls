/* 
    Customer/Project:   Spectrum Reach 
    Class name:          AccountRequestTriggerHandler
    Author/Date:        John King    5/31/2017
    Release:             TBD
    Purpose:            Provides handler methods for the AccountRequest Trigger

  // This should be used in conjunction with the ApexTriggerComprehensive.trigger template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

*/


// SRSF-190 -- changed to "without" sharing to have class run as System user
public without sharing class AccountRequestTriggerHandler {


  private boolean m_isExecuting = false;
  private integer BatchSize = 0;

  public AccountRequestTriggerHandler(boolean isExecuting, integer size){
    m_isExecuting = isExecuting;
    BatchSize = size;
  }

  public void OnBeforeInsert(Account_Request__c[] newAccountRequests){
    System.debug('AR: OnBeforeInsert');

    if(newAccountRequests != null) {
        User usrProfileName = [select u.Profile.Name, u.userRole.Name, u.Team_Role__c from User u where u.id = :Userinfo.getUserId()];
        map<Id,User> mapUser = new map<Id,User>();
        mapUser.put(Userinfo.getUserId(),null);
        for(Account_Request__c accReq : newAccountRequests) {
            if(accReq.Account_Executive__c!=null)
                mapUser.put(accReq.Account_Executive__c,null);
        }
        for(User obj : [SELECT Id,Approving_Manager__c FROM User WHERE Id IN :mapUser.keyset()]){
            mapUser.put(obj.Id,obj);
        }
        for(Account_Request__c accReq : newAccountRequests) {
/*            if(accReq.Advertiser_Agency_Rep_Firm__c != null) {
                for(Account acc : [Select Id, Name, OwnerId, RecordTypeId from Account where Id = :accReq.Advertiser_Agency_Rep_Firm__c LIMIT 1]) {
                    System.debug('AR: For Loop');
                    if(acc.RecordTypeId != AccountUtils.accountRequestRtId && accReq.RecordTypeId == AccountRequestUtils.billingRequestRtId) {
                        acc.RecordTypeId = AccountUtils.accountRequestRtId;
                        try {
                            update acc;
                        } catch(DMLException e) {
                            accReq.addError('You do not have the appropriate permissions to update the selected Account\'s Record Type. (Make sure you have Read/Write access on the Account Team)');
                        }
                    }
                }
            } */
            
            /*//Added logic for SRSF-1935
            if(accReq.WideOrbit_Account__c == 'YES' && 
               (accReq.Wide_Orbit_Client_ID__c==null || accReq.Wide_Orbit_Client_ID__c=='') && 
                accReq.status__c=='Completed'){
                accReq.addError('You must set Wide Orbit Client ID before making an Account Request.');
            }//End of SRSF-1935*/
            
            if(accReq.RecordTypeId == AccountRequestUtils.teamMemberRequestRtId) {
              if(accReq.Account_Executive__c == null) {
                // user is LSM or AE:
                if(usrProfileName.Profile.Name == 'Account Executive' ||  usrProfileName.Profile.Name == 'Local Sales Manager' || usrProfileName.Team_Role__c == 'Local Sales Manager' || usrProfileName.Team_Role__c == 'Sales Manager' || usrProfileName.Team_Role__c == 'LSM' || usrProfileName.Team_Role__c == 'AE' ||  usrProfileName.Team_Role__c == 'Account Executive' ||  usrProfileName.Profile.Name == 'Master - Account Executive') {
                   accReq.Account_Executive__c = Userinfo.getUserId();
                }
              }
              //User aeUser = [SELECT Approving_Manager__c FROM User WHERE Id = :accReq.Account_Executive__c];
              //accReq.Account_Executive_Approving_Manager__c = aeUser.Approving_Manager__c;
            }
            if(accReq.RecordTypeId != AccountRequestUtils.accApprovalRtId) {            
              if(accReq.Account_Executive__c == null) {
                accReq.Account_Executive__c = Userinfo.getUserId();
              }
              //User aeUser = [SELECT Approving_Manager__c FROM User WHERE Id = :accReq.Account_Executive__c];
              User aeUser = mapUser.get(accReq.Account_Executive__c);
              accReq.Account_Executive_Approving_Manager__c = aeUser.Approving_Manager__c;
            }
        }
    }

    //when User_Manager__c is null, assigns it:
    System.debug('1');
    if(newAccountRequests != null) {
        System.debug('2');
        for(Account_Request__c accReq : newAccountRequests) {
            System.debug('3');
            if(accReq.User_Manager__c == null) {// && accReq.Client_Name__c != null) {
                accReq.User_Manager__c = accReq.Account_Owner_Manager_Id__c;
                if(accReq.Account_Owner_Manager_Id__c == null) {
                    try {
                        throw new DmlException('User has no Manager set.');
                    } catch(DMLException e) {
                        accReq.addError('You must set an Approving Manager on your User account before making an Account Request.');
                    }
                }
            }
        }
    }
  }

  public void OnAfterInsert(Account_Request__c[] newAccountRequests){
    //SyncplicitySRUtils.CreateSyncplicityFolders(new List<Id>(new Map<Id, Account_Request__c>(newAccountRequests).keySet()));
  }

  @future public static void OnAfterInsertAsync(Set<ID> newAccountRequestIDs){
    //Example usage
    //List<Account_Request__c> newAccountRequests = [select Id, Name from Account_Request__c where Id IN :newAccountRequestIDs];
  }

  public void OnBeforeUpdate(Account_Request__c[] oldAccountRequests, Account_Request__c[] updatedAccountRequests, Map<ID, Account_Request__c> AccountRequestMap){
    //Example Map usage
    //Map<ID, Contact> contacts = new Map<ID, Contact>( [select Id, FirstName, LastName, Email from Contact where AccountRequestId IN :AccountRequestMap.keySet()] );
    
    //Added logic for SRSF-1935
      for(integer i=0;i<updatedAccountRequests.size();i++){
          Account_Request__c accReq = updatedAccountRequests[i];
          Account_Request__c oldaccReq = oldAccountRequests[i];
          
          if(accReq.WideOrbit_Account__c != oldaccReq.WideOrbit_Account__c && !isFBOUser(Userinfo.getUserId())){
              accReq.addError('Only FBO Queue members can edit the WideOrbit Account.');
          }
          
          if(accReq.WideOrbit_Account__c == 'YES' && 
             (accReq.Wide_Orbit_Client_ID__c==null || accReq.Wide_Orbit_Client_ID__c=='') && 
             accReq.status__c != oldaccReq.status__c && oldaccReq.status__c=='Submitted to Credit' && accReq.status__c=='Completed'){
             accReq.addError('You must set Wide Orbit Client ID before making an Account Request.');
          }
          
      }//end of SRSF-1935
      
      
  }

  public void OnAfterUpdate(Account_Request__c[] oldAccountRequests, Account_Request__c[] updatedAccountRequests, Map<ID, Account_Request__c> AccountRequestMap){
    AssignAccountExecutives(oldAccountRequests, updatedAccountRequests);

    //logic for former "ChangeAccountOwner()":
    //When Account Switch Request is Approved do the following: 1. Account Owner Change 2. Account Team Switch 3. Switch ownership on all open opportunities tied to account.
    try{
        System.debug('inside After ');
        string ROLE = 'Account Executive';  //team member role
        map<string,string> mapAccIdsToOwner = new map<string,string> ();        //Holds Account ID and owner id
        Map<Id, Account_Request__c> accReqOld = new Map<Id, Account_Request__c>(oldAccountRequests);
        ID rectypeid = AccountRequestUtils.accountSwitchRequestRtId; // Schema.SObjectType.Account_Request__c.getRecordTypeInfosByName().get('Account Switch Request').getRecordTypeId();
        ID accReqRecTypeId = Schema.SObjectType.Account_Request__c.getRecordTypeInfosByName().get('Account Approval Request').getRecordTypeId();
        Map<string, List<string>> mapAccAE = new Map<String, List<string>>();
        Set<Id> accsApproved = new Set<Id>();
        Set<Id> accsNotApproved = new Set<Id>();
        Set<Id> accsInProcess = new Set<Id>();
        List<Account> accToUpdate = new List<Account>();
        
        //get approved account requests
        for(Account_Request__c objAR : updatedAccountRequests)
        {
            for(Account_Request__c objAROld : oldAccountRequests) {
                if( objAR != null &&
                    objAR.id == objAROld.id &&
                    objAR.Status__c != null &&
                    /*objAR.RecordTypeId == rectypeid &&*/
                    objAR.Status__c == 'Completed' &&
                    objAROld.Status__c != objAR.Status__c)
                {
                    mapAccIdsToOwner.put(objAR.Advertiser_Agency_Rep_Firm__c,objAR.New_Account_Owner__c);
                }
            }
            if(objAR.RecordTypeId == accReqRecTypeId){
                //List<id> accIds = new List<id>();
                if(objAR.Status__c == 'Completed' || objAR.Status__c == 'Approved'){
                    accsApproved.add(objAR.Advertiser_Agency_Rep_Firm__c);
                    //accIds.add(objAR.Advertiser_Agency_Rep_Firm__c);
                    // if(!accIds.isEmpty()){
                    //   list<Account> acc = [Select id, Approval_Status__c from Account WHERE Id in :accIds AND Approval_Status__c != 'Approved'];
                    //   if(!acc.isEmpty()){
                    //       for(Account objAcc: acc){
                    //           objAcc.Approval_Status__c = 'Approved';  
                    //       }
                    //       update acc; 
                    //   }
                    
                	// }
            	}
                if(objAR.Status__c == 'Denied'){
                    accsNotApproved.add(objAR.Advertiser_Agency_Rep_Firm__c);
                    // accIds.add(objAR.Advertiser_Agency_Rep_Firm__c);
                    // if(!accIds.isEmpty()){
                    //   list<Account> acc = [Select id, Approval_Status__c from Account WHERE Id in :accIds AND Approval_Status__c != 'Not Approved'];
                    //   if(!acc.isEmpty()){
                    //       for(Account objAcc: acc){
                    //           objAcc.Approval_Status__c = 'Not Approved';  
                    //       }
                    //       update acc; 
                    //   }
                    
                	// }
            	}
                if(objAR.Status__c == 'Submitted to Sales Management' || objAR.Status__c == 'In Approval Process' || objAR.Status__c == 'Submitted to Director of Sales'|| objAR.Status__c == 'Submitted to Credit'){
                    accsInProcess.add(objAR.Advertiser_Agency_Rep_Firm__c);
                    // System.debug('Status ::' +objAR.Status__c);
                    // accIds.add(objAR.Advertiser_Agency_Rep_Firm__c);
                    // if(!accIds.isEmpty()){
                    //   list<Account> acc = [Select id, Approval_Status__c from Account WHERE Id in :accIds AND Approval_Status__c != 'In-Process'];
                    //   if(!acc.isEmpty()){
                    //       for(Account objAcc: acc){
                    //           objAcc.Approval_Status__c = 'In-Process';  
                    //           System.debug('objAcc.Approval_Status__c'+ objAcc.Approval_Status__c);
                    //       }  
                    //       update acc; 
                    //   }
                    
                	// }
            	}
        	}
        }

        if(!accsApproved.isEmpty()){
          list<Account> acc = [Select id, Approval_Status__c from Account WHERE Id in :accsApproved AND Approval_Status__c != 'Approved'];
          if(!acc.isEmpty()){
              for(Account objAcc: acc){
                  objAcc.Approval_Status__c = 'Approved';  
              }
              accToUpdate.addAll(acc); 
          }
        }

        if(!accsNotApproved.isEmpty()){
            list<Account> acc = [Select id, Approval_Status__c from Account WHERE Id in :accsNotApproved AND Approval_Status__c != 'Not Approved'];
            if(!acc.isEmpty()){
                for(Account objAcc: acc){
                    objAcc.Approval_Status__c = 'Not Approved';  
                }
                accToUpdate.addAll(acc); 
            }
        }

        if(!accsInProcess.isEmpty()){
            list<Account> acc = [Select id, Approval_Status__c from Account WHERE Id in :accsInProcess AND Approval_Status__c != 'In-Process'];
            if(!acc.isEmpty()){
                for(Account objAcc: acc){
                        objAcc.Approval_Status__c = 'In-Process';  
                   }  
                    accToUpdate.addAll(acc); 
                }
            }
        
        if(!accToUpdate.isEmpty()){
            update accToUpdate;
        }

        // if(updatedAccountRequests[0].RecordTypeId == Schema.SObjectType.Account_Request__c.getRecordTypeInfosByName().get('Remove Account Team Member').getRecordTypeId() && updatedAccountRequests[0].Status__c == 'Approved'){
        //   List<AccountTeamMember> atmRecs = [SELECT ID FROM AccountTeamMember WHERE UserId =: updatedAccountRequests[0].Account_Executive__c AND AccountId =: updatedAccountRequests[0].Advertiser_Agency_Rep_Firm__c];
        //   Delete atmRecs;
        // }
        
        if(!mapAccIdsToOwner.isEmpty())
        {
            list<AccountTeamMember> lstNewAE = new list<AccountTeamMember> ();  //To hold new team members with role AE
            
            //1.Change Account owner to new owner
            list<Account> lstAcc = [select Id, OwnerId from Account WHERE Id IN: mapAccIdsToOwner.keyset()];
            for(Account objAcc : lstAcc)
            {
                objAcc.OwnerId = mapAccIdsToOwner.get(objAcc.Id);
            }
            update lstAcc;
            
            //2.a. remove old owner from team as AE
            list<AccountTeamMember> lstTM = [select Id, AccountId from AccountTeamMember 
                                                WHERE AccountId IN: mapAccIdsToOwner.keyset() and TeamMemberRole =: ROLE];
          //  delete lstTM;

            // Issue #230 from UAT - don't delete them, change their role to Other
            for (AccountTeamMember atm : lstTM) {
                atm.TeamMemberRole = 'Other';
                lstNewAE.add(atm);
            }
            
            //2.b. add new owner to team with role AE
            for(string strId : mapAccIdsToOwner.keyset())       
            {
                AccountTeamMember objTM = new AccountTeamMember ();
                objTM.AccountId = strId;
                objTM.TeamMemberRole = ROLE;
                objTM.UserId = mapAccIdsToOwner.get(strId);
                lstNewAE.add(objTM);
            }       
            // insert lstNewAE;    issue 230 - change insert to upsert because we may have existing AEs in the list
            upsert lstNewAE;    
            
            //3. get all opportunities tied to the account and change owner to new owner
            list<Opportunity> lstOpps = [select Id, OwnerId, AccountId from Opportunity WHERE AccountId IN: mapAccIdsToOwner.keyset()];
            for(Opportunity objOpp : lstOpps)
            {
                objOpp.OwnerId = mapAccIdsToOwner.get(objOpp.AccountId);
            }
            update lstOpps;
        }
        Id RecordTypeId = Schema.SObjectType.Account_Request__c.getRecordTypeInfosByName().get('Multi Market Approval').getRecordTypeId();
        List<id> lstaccid = new List<id>();
          for(Account_Request__c accreqrec : updatedAccountRequests ){
              if(accreqrec.Status__c=='Approved' && accreqrec.RecordTypeId == RecordTypeId){
                  lstaccid.add(accreqrec.Advertiser_Agency_Rep_Firm__c);
              }
          }
          if(!lstaccid.isEmpty()){
              list<Account> acc = [Select id, Multi_Market__c from Account where Multi_Market__c = False AND Id in :lstaccid];
              if(!acc.isEmpty()){
                  for(Account objAcc: acc){
                      objAcc.Multi_Market__c = true;  
                  }
                  update acc; 
              }   
     	 }
    }
    catch(exception ex)
    {
        system.debug('Exception line number..'+ex.getLineNumber());
    }
  }

  @future public static void OnAfterUpdateAsync(Set<ID> updatedAccountRequestIDs){
    //List<Account_Request__c> updatedAccountRequests = [select Id, Name from Account_Request__c where Id IN :updatedAccountRequestIDs];
  }

  public void OnBeforeDelete(Account_Request__c[] AccountRequestsToDelete, Map<ID, Account_Request__c> AccountRequestMap){

  }

  public void OnAfterDelete(Account_Request__c[] deletedAccountRequests, Map<ID, Account_Request__c> AccountRequestMap){

  }

  @future public static void OnAfterDeleteAsync(Set<ID> deletedAccountRequestIDs){

  }

  public void OnUndelete(Account_Request__c[] restoredAccountRequests){

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

  //adds: AE and AE default team to account & all open opportunities teams for Account Request type "Team Member Request"
    private static void AssignAccountExecutives(List<Account_Request__c> accountRequestOld, List<Account_Request__c> accountRequestNew) {
        String teamMemberRole = 'Account Executive';
        String accountAccessLevel = 'Edit', opportunityAccessLevel = 'Edit';
        List<AccountTeamMember> accountTeamMembers = new list<AccountTeamMember>();
        List<AccountShare> sharingRules = new list<AccountShare>();
        List<OpportunityTeamMember> opportunityTeamMembers = new list<OpportunityTeamMember>();
        List<OpportunityShare> sharingRulesOpportunity = new list<OpportunityShare>();
        List<Opportunity> opportunities = new List<Opportunity>();
        Map<Id, Account_Request__c> agenciesMap= new Map<Id, Account_Request__c>();
        if(accountRequestNew != null) {
            for(Account_Request__c accReq : accountRequestNew) {
                if(accReq.Team_Member_Approved__c == 'Approved' && accReq.RecordTypeId == AccountRequestUtils.teamMemberRequestRtId) {
                    Id accReqNewID = accReq.Id;
                    String oldApprovedVal = null;
                    if(accountRequestOld != null) {
                        for(Account_Request__c accReqOld : accountRequestOld) {
                            
                            if(accReqNewID == accReqOld.Id) {
                                oldApprovedVal = accReqOld.Team_Member_Approved__c;

                        }
                    }

                    // value wasn't Approved before, but it is now -- proceed with logic:
                    if(oldApprovedVal != 'Approved') {
/*      
  START: "Commented for SRSF-190"
                            boolean isUserSalesManager = false;
                            boolean isUserAlreadyOnAccountTeam = false;
                            User usrProfileName = [select Team_Role__c from User where Id = :Userinfo.getUserId()];
                            if(usrProfileName.Team_Role__c == 'Sales Manager') {
                              isUserSalesManager = true;
                            }
                            System.debug('Current user: ' + Userinfo.getUserId());
                            System.debug('bool isUserSalesManager: ' + isUserSalesManager);
                            for(AccountTeamMember atm : [Select UserId, TeamMemberRole, Id, AccountAccessLevel, AccountId From AccountTeamMember where AccountID = :accReq.Advertiser_Agency_Rep_Firm__c AND TeamMemberRole = :teamMemberRole]){

                              if(atm.UserId == Userinfo.getUserId()) {
                                isUserAlreadyOnAccountTeam = true;
                              }                  
                              System.debug('ATM User: ' + atm);
                              System.debug('bool isUserOnTeam: ' + isUserAlreadyOnAccountTeam);
                            }
                            System.debug('FINAL bool isUserOnTeam: ' + isUserAlreadyOnAccountTeam);
  END: "Commented for SRSF-190"
*/

/*                            if(isUserSalesManager && !isUserAlreadyOnAccountTeam) {
                                accountTeamMembers.add(
                                        New AccountTeamMember(
                                                AccountId = accReq.Advertiser_Agency_Rep_Firm__c,
                                                TeamMemberRole = teamMemberRole,
                                                AccountAccessLevel = accountAccessLevel,
                                                UserId = Userinfo.getUserId()
                                        )
                                );
                            }
*/
                            agenciesMap.put(accReq.Advertiser_Agency_Rep_Firm__c,accReq);
                        }
                    }
                }
           }

           Id accountId = null;
           // SRMSUC-172 Dev/Conf Task 4: query for Account team using Account Request owner's ID, add AE to Team Member
           for(Account acc : [Select Id, OwnerId from Account where Id = :agenciesMap.keySet() LIMIT 1]) {

               accountId = acc.Id;
               accountTeamMembers.add(
                       New AccountTeamMember(
                               AccountId = acc.id,
                               TeamMemberRole = teamMemberRole,
                               UserId = agenciesMap.get(acc.Id).Account_Executive__c // accReq.Account_Executive__c
                       )
               );
               // SRSF-190: removed Sales Manager check as well as check if user is already on team before adding the sharing rule
               //if(acc.OwnerId != accReq.Account_Executive__c && (!isUserSalesManager || isUserAlreadyOnAccountTeam)) {
               if(acc.OwnerId != agenciesMap.get(acc.Id).Account_Executive__c) { //} && (!isUserSalesManager || isUserAlreadyOnAccountTeam)) {
                   sharingRules.add(
                         New AccountShare(
                                 AccountId = acc.id,
                                 AccountAccessLevel = accountAccessLevel,
                                 OpportunityAccessLevel = opportunityAccessLevel,
                                 UserOrGroupId = agenciesMap.get(acc.Id).Account_Executive__c
                         )
                   );
               }
           }
           if(accountTeamMembers.size() > 0) {
           System.debug('----> accountTeamMembers: '+accountTeamMembers);
               insert accountTeamMembers;
           }
           if(sharingRules.size() > 0) {
               insert sharingRules;
           }

        }
    }
    
    //Checks whether the current user is in FBO Queue / System Admin
    public static boolean isFBOUser(Id curUser){
        boolean isFBOUser = false;
        User usrProfileName = [select Profile.Name, userRole.Name, Team_Role__c from User where id = :curUser];
        if(usrProfileName.Profile.Name == 'Integration User' || usrProfileName.Profile.Name == 'System Administrator'){
            isFBOUser = true;
            return isFBOUser;
        }
            
        list<Group> lstGroup = [select Id from Group where Type = 'Queue' AND NAME = 'FBO Queue'];
        if(!lstGroup.isEmpty()){
            list<GroupMember> lstGM = [Select UserOrGroupId From GroupMember where GroupId =:lstGroup[0].Id and UserOrGroupId=:curUser];
            if(!lstGM.isEmpty())
                isFBOUser = true;
        }
        return isFBOUser;
    }
}