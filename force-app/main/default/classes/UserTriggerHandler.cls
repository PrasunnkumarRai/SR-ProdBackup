/*###########################################################################
# File..................: UserTriggerHandler.apxc
# Version...............: 1
# Created by............: Sanchit Singhal   
# Created Date..........: 26-Feb-2018
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: Helper class for User Trigger
# TAO Ref#..............: 
# Change Log:               
#
#
############################################################################*/
public with sharing class UserTriggerHandler {

	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	public List<User> Users;
  
	public UserTriggerHandler(boolean isExecuting, integer size){
	  m_isExecuting = isExecuting;
	  BatchSize = size;
	  Users = new List<User>();
	}
  
	public void OnAfterInsert(User[] newUsers){
		createApexManagedSharing(newUsers,new Map<ID, User>());
	}
  
	public void OnAfterUpdate(User[] oldUsers, User[] updatedUsers, Map<ID, User> oldUserMap){  
	  createApexManagedSharing(updatedUsers,oldUserMap);

	}
	
	public void OnBeforeUpdate(User[] oldUsers, User[] updatedUsers, Map<ID, User> oldUserMap){  
	  //Commntted as per discussion with Greg on Jan-31-2020
	  /*Boolean woValToUpdate = false;
	  if(updatedUsers != null && updatedUsers.size() == 1) { //} && newAccountRequests[0].RecordTypeId == AccountRequestUtils.accountIdCreditRequestRtId) {
		for(GroupMember gm : [SELECT Id FROM GroupMember where group.Name = 'WO LA Sales' AND UserOrGroupId = :updatedUsers[0].Id LIMIT 1]) {
		  woValToUpdate = true;
		}
		if(updatedUsers[0].WideOrbit_Account__c != woValToUpdate) {
					updatedUsers[0].WideOrbit_Account__c = woValToUpdate;
		}
	  }*/
	  Map<Id, UserLogin> mapFrozenUsers = new Map<Id, UserLogin>();
	  List<UserLogin> lstFrozenUsers = [SELECT ID, IsFrozen, UserId From UserLogin WHERE UserId IN: oldUserMap.keyset() And IsFrozen = true];
	  for(UserLogin ul: lstFrozenUsers){
		  mapFrozenUsers.put(ul.UserId, ul);
	  }
	  
		for(User u: updatedUsers){
		  if(mapFrozenUsers.containsKey(u.Id)){
			  u.EmailActiveUsers__c = u.HR_Email__c + ':' + 'InActive';
		  }
		  else{
				u.EmailActiveUsers__c = u.EmailActiveUsersFormula__c;
		  }
		}

	 updateIsFrozen(updatedUsers);

	}
	  
	public void OnBeforeInsert(User[] newUsers){  
	  for(User u: newUsers){
			u.EmailActiveUsers__c = u.HR_Email__c +':'+ (u.IsActive==true? 'Active':'InActive');
		}
	}
	
	public string createApexManagedSharing(List<User> uList, Map<Id,User> uOldMap){
		Map<Id,String> jobShareUserIds = new Map<Id,String>();
		List<Id> OppIdList = new List<Id>();
	  List<Id> OppuserOrGroupIdList = new List<Id>();
	  List<Id> BudIdList = new List<Id>();
	  List<Id> BuduserOrGroupIdList = new List<Id>();
	  List<Id> RevIdList = new List<Id>();
	  List<Id> REvuserOrGroupIdList = new List<Id>();
	  
		for(User u: uList){
			if(u.Job_Share_User__c != null && (uOldMap.size() == 0 || uOldMap.get(u.id).Job_Share_User__c != u.Job_Share_User__c)){
				if(jobShareUserIds.containsKey(u.Job_Share_User__c)){
					jobShareUserIds.put(u.Job_Share_User__c,jobShareUserIds.get(u.Job_Share_User__c) + ',' + u.id);
				}
				else{
					jobShareUserIds.put(u.Job_Share_User__c,u.id);
				}
			}
		}
		
		System.debug('jobShareUserIds: ' + jobShareUserIds);
		
		for(Opportunity opp:[Select id,ownerId from Opportunity where ownerId in: jobShareUserIds.keyset()]){
			for(String o:jobShareUserIds.get(opp.OwnerId).split(',')){
				OppIdList.add(opp.Id);
				OppuserOrGroupIdList.add(o);
			}
		}
		System.debug('OppuserOrGroupIdList: ' + OppuserOrGroupIdList);
		
		for(Budget__c bud:[Select id,ownerId from Budget__c where ownerId in: jobShareUserIds.keyset()]){
			for(String o:jobShareUserIds.get(bud.OwnerId).split(',')){
				BudIdList.add(bud.Id);
				BuduserOrGroupIdList.add(o);
			}  		
		}
		System.debug('BuduserOrGroupIdList: ' + BuduserOrGroupIdList);
		
		for(Revenue__c rev:[Select id,ownerId from Revenue__c where ownerId in: jobShareUserIds.keyset()]){  		
			for(String o:jobShareUserIds.get(rev.OwnerId).split(',')){
				RevIdList.add(rev.Id);
				RevuserOrGroupIdList.add(o);
			}
		}
		System.debug('RevuserOrGroupIdList: ' + RevuserOrGroupIdList);
		
		if(OppIdList.size()>0){
			UtilityClass.asyncApexSharing(OppIdList,OppuserOrGroupIdList,'Opportunity','Edit');
		}
		
		if(BudIdList.size()>0){
			UtilityClass.asyncApexSharing(BudIdList,BuduserOrGroupIdList,'Budget','Edit');
		}
		
		if(RevIdList.size()>0){
			UtilityClass.asyncApexSharing(RevIdList,RevuserOrGroupIdList,'Revenue','Edit');
		}
		return 'Success';
	}
	public static void updateIsFrozen(List<User> userList) {
        // Collect the Ids of the updated Users
        Set<Id> userIds = new Set<Id>();
        for (User user : userList) {
            userIds.add(user.Id);
        }
		System.debug('User IDs: ' + userIds);
        // Map to store UserLogin information
        Map<Id, UserLogin> userLoginMap = new Map<Id, UserLogin>();

        // Query the UserLogin object to get the IsFrozen field for the updated users
        for (UserLogin ul : [SELECT UserId, IsFrozen FROM UserLogin WHERE UserId IN :userIds]) {
            userLoginMap.put(ul.UserId, ul);
        }
		System.debug('UserLogin Map: ' + userLoginMap);
        // List to hold users to be updated
        List<User> usersToBeUpdated = new List<User>();

        // Iterate over the userList to set the Is_Frozen__c field
        for (User user : userList) {
            UserLogin ul = userLoginMap.get(user.Id);
            if (ul != null) {
				user.Is_Frozen__c = ul.IsFrozen;      
            }
        }
		
    }
 }