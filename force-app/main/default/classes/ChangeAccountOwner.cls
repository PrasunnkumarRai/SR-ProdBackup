/* 
    Customer/Project:   Spectrum Reach 
    Class name:          ChangeAccountOwner
    Author/Date:        Brett Ballantyne    6/14/2017
    Release:             TBD
    Purpose:            Provides method to change ownerId on Account
    Modifications:      Brett Ballantyne 6/15/18 - SRSF-1071 - fixed logic error in ChangeOwner, 
                        and merged addAccountTeamMembers and addOriginalOwnerToAcctTeam into one method
                        Brett Ballantyne 6/29/19 - SRSF-1125

*/

public without sharing class ChangeAccountOwner {

//addAccountTeamMembers
public static Group preferredGroup;
public static  User currentUser;
//ChangeOwner
public static List<Account> currentAccts;
    public ChangeAccountOwner() {
        
    }

    // 
    public static void addAccountTeamMembers(List<Account> accounts) {
        // SRMSUC-528 - add user creating the account as an account team member
        List<AccountTeamMember> atms = new List<AccountTeamMember>();
        List<AccountShare> sharingRules = new list<AccountShare>();
        
        // Start - SRSF-2662
        Set<Id> acctIds = new Set<Id>();
        Set<String> atmExists = new Set<String>();
        for (Account acct : accounts) {
            acctIds.add(acct.Id);
        }
        List<AccountTeamMember> atmList = [SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMember WHERE UserId =: UserInfo.getUserId() AND AccountId IN :acctIds]; // SRSF-3889 : Removed filter - TeamMemberRole = 'Interim AE'  
        if(!CommonUtilities.isListNullOrEmpty(atmList) && atmList.Size()>0){
            for(AccountTeamMember atm : atmList)
            {
                atmExists.add(atm.AccountId+'_'+atm.UserId);
            }
        }    
        // End - SRSF-2662    

        if(currentUser==null)
        	currentUser = [select Id, Name, Team_Role__c, Division__c from User where Id = :UserInfo.getUserId()];
        if (currentUser.Team_Role__c == null || currentUser.Team_Role__c == '') {
            currentUser.Team_Role__c = 'Other';
        }
        
        if(currentUser.Division__c!=null){
			String strDiv = currentUser.Division__c;
            if(strDiv!=null)
                strDiv = strDiv.replace(' ', '_');//'North East' is replacing as 'North_East'
            list<Group> lstPreferredGroup = [select Id,DeveloperName,(select UserOrGroupId from GroupMembers) from Group where DeveloperName =: strDiv];
            if(lstPreferredGroup!=null && !lstPreferredGroup.isEmpty()){
                preferredGroup = lstPreferredGroup[0];//Only one Group for Division
            }
		}//else if(!Test.isRunningTest())
            //accounts[0].addError('Division should not be empty for User : \''+UserInfo.getName()+'\'');
		
        List<Id> prefUserIds = new List<Id>();
        if(preferredGroup!=null){
            for (GroupMember gm : preferredGroup.GroupMembers) {
                prefUserIds.add(gm.UserOrGroupId);
            }
        }
        system.debug(loggingLevel.WARN, '=========>> currentUser = ' + currentUser);
        for(Account acc : accounts) {
            // SRSF-1125  String teamRole = (acc.Spectrum_Reach_Preferred__c == true) ? 'Preferred' : currentUser.Team_Role__c;
            system.debug(loggingLevel.WARN, '=========>> acc.Id = ' + acc.Id);
            //// if (teamRole == 'Preferred' || Trigger.isInsert) {
                
            if (!atmExists.contains (acc.Id+'_'+currentUser.Id)){  // SRSF-2662 / SRSF-3889 : Added If condition to avoid  adding ATM if already exists with any Role 
                atms.add(new AccountTeamMember( AccountId = acc.Id,
                        TeamMemberRole = currentUser.Team_Role__c,
                        UserId = currentUser.Id)
                );                
            } // SRSF-2662

                sharingRules.add(new AccountShare(AccountId = acc.Id,
                        AccountAccessLevel = 'Edit',
                        OpportunityAccessLevel = 'Edit',
                        UserOrGroupId = currentUser.Id)
                );
            
            if (acc.Spectrum_Reach_Preferred__c == true) {
                for (Id prefUserId : prefUserIds) {
                    atms.add(new AccountTeamMember( AccountId = acc.Id,
                                    TeamMemberRole = 'Preferred',
                                    UserId = prefUserId)
                    );
                    sharingRules.add(new AccountShare(AccountId = acc.Id,
                                      AccountAccessLevel = 'Edit',
                                      OpportunityAccessLevel = 'Edit',
                                      UserOrGroupId = prefUserId)
                    );

                }
            }
        }
////        }

        /* SRSF-1125
        // Now add the AE from the userConnection table to the account team
        //Map<String,userconnection__c> userConnMap = populateUserConnectionMap(accounts); //populate UserConnection
        //if (!userConnMap.isEmpty()) {
            List<Id> ownerIds = new list<Id>();
        
            for(Account acc : accounts){
                //if (userConnMap.containsKey(acc.ae__c+acc.TIM_System__c)) {
                    //String accOwnerId = userConnMap.get(acc.ae__c+acc.TIM_System__c).user__c;
                    //Instead od using account owner use userconnection Map
                    ownerIds.add(acc.ownerId);
                    //if (String.isNotBlank(accOwnerId)) ownerIds.add(accOwnerId);
                //}
            }
      
            Map<Id,User> userMap = new Map<Id,User>();
            for(User u: [select Id, Name, Team_Role__c from User where Id in :ownerIds]){
                if (u.Team_Role__c == null || u.Team_Role__c == '') {
                    u.Team_Role__c = 'Other';
                }
                userMap.put(u.Id,u);
            }
        
            system.debug(loggingLevel.WARN, '=========>> userMap = ' + userMap);
            for(Account acc : accounts) {
                //Instead of using account owner use userconnection Map
                String accOwnerId = acc.ownerId;
                /*if (userConnMap.containsKey(acc.ae__c+acc.TIM_System__c)) {
                    if (String.isNotBlank(userConnMap.get(acc.ae__c+acc.TIM_System__c).user__c))
                        accOwnerId = userConnMap.get(acc.ae__c+acc.TIM_System__c).user__c;
                }
                if (String.isBlank(accOwnerId)) continue; * /
                if (accOwnerId == String.valueOf(currentUser.Id)) continue;     // don't want to add currentUser twice if currentUser == ae__c
                                                                                // don't know if this would ever happen, but the check won't hurt
                
                String teamRole = (acc.Spectrum_Reach_Preferred__c == true) ? 'Preferred' : userMap.get(accOwnerId).Team_Role__c;
                system.debug(loggingLevel.WARN, '=========>> acc.Id = ' + acc.Id);
                if (teamRole == 'Preferred' || Trigger.isInsert) {
                    atms.add(new AccountTeamMember( AccountId = acc.Id,
                                    TeamMemberRole = teamRole,
                                    UserId = accOwnerId)
                    );
                    sharingRules.add(new AccountShare(AccountId = acc.Id,
                                      AccountAccessLevel = 'Edit',
                                      OpportunityAccessLevel = 'Edit',
                                      UserOrGroupId = accOwnerId)
                    );
                }
                
            } */ 
        //}

        if (atms.size() > 0) {
            try {
              insert atms;
              insert sharingRules;
            } catch (Exception ex) {
              system.debug(loggingLevel.Error, 'Error in AccountTriggerHandler.addOriginalOwnerToAcctTeam: ' + ex.getMessage());
            }
        }

    }
/*  commenting out for 1071
  // SRMSUC-528 - add user creating the account as an account team member
  public static void addUserToAcctTeam(List<Account> accounts) {
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
      if (teamRole == 'Preferred' || Trigger.isInsert) {
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
  }
*/
    public static boolean ChangeOwner(String ownerId, List<Account> accounts) {
        if (ownerId == null || ownerId == '' || ownerId.length() < 15 || ownerId.length() > 18 || accounts == null || accounts.size() == 0) 
            return false;

       List<Id> acctIds = new List<Id>();

        for (Account acc: accounts) {
            acctIds.add(acc.Id);
        }
        if(currentAccts==null)
        currentAccts = [select ownerId, recordTypeId from Account where Id in :acctIds];
        System.debug('currentAccts' + currentAccts);

        List<Account> updateList = new List<Account>();

        for (Account acc : currentAccts) {
            if(acc.recordTypeId != AccountUtils.affiliateRtId) {   // SRSF-669
              acc.ownerId = Id.Valueof(ownerId);
              updateList.add(acc);
          }
        }
        if (updateList.size() > 0) {
            try {
                update updateList;
            } catch (Exception ex) {
                system.debug(loggingLevel.Error, 'ChangeAccountOwner.ChangeOwner Error updating Accounts : ' + ex.getMessage());
                return false;
            }
        }
        return true;        
    }

    //IB : SRSF-909 : Created this method to populate userConnection map
    //IB : SRSF-909 : **** START ****
    public static Map<String,userconnection__c> populateUserConnectionMap(Account[] newAccounts) {
        Map<String,userconnection__c> ucMap = new Map<String,userconnection__c>();
        try{
            Set<String> aeSet = new Set<String>();
            for(Account acc: newAccounts){
                if(String.isNotBlank(acc.AE__c)){
                  aeSet.add(acc.AE__c);
                }
            }
          
            for (userconnection__c uc:[Select user__c,ae_id__c,TIM_System__c  from userconnection__c where ae_id__c in :aeSet]){
                ucMap.put(uc.ae_id__c +uc.TIM_System__c,uc);
            }
            /*for(Account acc: newAccounts){
                if(ucMap!=null && ucMap.containsKey(acc.ae__c+acc.TIM_System__c) && String.isNotBlank(acc.AE__c)){
                    acc.ownerId=ucMap.get(acc.ae__c+acc.TIM_System__c).user__c;
                }
            }*/
        }
        catch(Exception ex){
            System.debug('Exception in AE to owner mapping: ' + ex + ex.getLineNumber());
        }
        return ucMap;
    }
    //IB : SRSF-909 : **** END ****
/*  commenting out for 1071
    public static void addOriginalOwnerToAcctTeam(List<Account> accounts) {
        system.debug(loggingLevel.WARN, '==============>> in addOriginalOwnerToAcctTeam');
        Map<String,userconnection__c> userConnMap = populateUserConnectionMap(accounts); //populate UserConnection
        if (!userConnMap.isEmpty()) {
            List<AccountTeamMember> atms = new List<AccountTeamMember>();
            List<AccountShare> sharingRules = new list<AccountShare>();
            List<Id> ownerIds = new list<Id>();
        
            for(Account acc : accounts){
                if (userConnMap.containsKey(acc.ae__c+acc.TIM_System__c)) {
                    String accOwnerId = userConnMap.get(acc.ae__c+acc.TIM_System__c).user__c;
                    //Instead od using account owner use userconnection Map
                    //ownerIds.add(acc.ownerId);
                    if (String.isNotBlank(accOwnerId)) ownerIds.add(accOwnerId);
                }
            }
      
            Map<Id,User> userMap = new Map<Id,User>();
            for(User u: [select Id, Name, Team_Role__c from User where Id in :ownerIds]){
                if (u.Team_Role__c == null || u.Team_Role__c == '') {
                    u.Team_Role__c = 'Other';
                }
                userMap.put(u.Id,u);
            }
      
            system.debug(loggingLevel.WARN, '=========>> userMap = ' + userMap);
            for(Account acc : accounts) {
                //Instead of using account owner use userconnection Map
                String accOwnerId = '';
                if (userConnMap.containsKey(acc.ae__c+acc.TIM_System__c)) {
                    if (String.isNotBlank(userConnMap.get(acc.ae__c+acc.TIM_System__c).user__c))
                        accOwnerId = userConnMap.get(acc.ae__c+acc.TIM_System__c).user__c;
                }
                if (String.isBlank(accOwnerId)) continue;
                
                //String teamRole = (acc.Spectrum_Reach_Preferred__c == true) ? 'Preferred' : userMap.get(acc.ownerId).Team_Role__c;
                String teamRole = (acc.Spectrum_Reach_Preferred__c == true) ? 'Preferred' : userMap.get(accOwnerId).Team_Role__c;
                system.debug(loggingLevel.WARN, '=========>> acc.Id = ' + acc.Id);
                if (teamRole == 'Preferred' || Trigger.isInsert) {
                    atms.add(new AccountTeamMember( AccountId = acc.Id,
                                    TeamMemberRole = teamRole,
                                    UserId = accOwnerId)
                    );
                    sharingRules.add(new AccountShare(AccountId = acc.Id,
                                      AccountAccessLevel = 'Edit',
                                      OpportunityAccessLevel = 'Edit',
                                      UserOrGroupId = accOwnerId)
                    );
                } 
            }
      
            if (atms.size() > 0) {
                try {
                  insert atms;
                  insert sharingRules;
                } catch (Exception ex) {
                  system.debug(loggingLevel.Error, 'Error in AccountTriggerHandler.addOriginalOwnerToAcctTeam: ' + ex.getMessage());
                }
            }
        }
    }

    */
}