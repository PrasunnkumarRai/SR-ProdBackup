/* test for clark*/
public without sharing class atmAdminController {
	static Database.SaveResult[] results;
	static Map<Id, Sales_Budget__c> sbMap;
	static Map<Id, Account_Transfer_Mapping__c> atmMap;
     public string transferStatus{get;set;}

	@AuraEnabled
	public Static List<map<String, Object>> showAccountTeamMembers(Id AccId) {
		System.debug('In showAccountTeamMembers() AccId before isValidUser ' + AccId);
		Boolean isOnOpptyTeam = isValidUser();
		if (!isOnOpptyTeam) {
			System.debug('********** Returning !isOnOpptyTeam');
			return null;
		}

		System.debug('In showAccountTeamMembers() AccId after isValidUser' + AccId);
		map<String, object> data = new map<String, object> ();
		String atmInformation;
		list<map<String, Object>> atmList = new list<map<String, Object>> ();

		List<AccountTeamMember> atmRS = [SELECT Id, UserId, Title, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel, AccountId FROM AccountTeamMember WHERE AccountId = :AccId order by TeamMemberRole desc];
		System.debug('AccountTeamMember list Size:::' + atmRS.size());

		List<Id> atmUsers = new List<Id> ();
		for (AccountTeamMember atm : atmRS) {
			atmUsers.add(atm.UserId);
		}
		map<string, User> mapUser = new map<string, User> ();
		if (!atmUsers.isEmpty()) {
			for (User objUser :[SELECT Id, Name, Sales_Office__c, Division__c, Region__c FROM User WHERE Id in :atmUsers]) {
				mapUser.put(objUser.Id, objUser);
			}
		}
		sbMap = new Map<Id, Sales_Budget__c> ();
		atmMap = new Map<Id, Account_Transfer_Mapping__c> ();
		Integer currentBudgetYear = Integer.valueof(Label.BudgetCurrentYear);
		for (Sales_Budget__c sb :[Select budget_user__c from Sales_Budget__c
		     where budget_user__c in :atmUsers and advertiser__c = :AccId and amount__c >= 1
		     and Type__c = 'Data'
		     and CALENDAR_YEAR(Broadcast_Month_Date__c) = :currentBudgetYear limit 45000]) {
			sbMap.put(sb.budget_user__c, sb);
		}
		for (Account_Transfer_Mapping__c sb :[Select Id, From_User__c, To_User__c, Account__c from Account_Transfer_Mapping__c where(From_User__c in :atmUsers Or To_User__c in :atmUsers) and Account__c = :AccId and Account_Transfer_Simulation__r.Status__c != 'Completed' limit 45000]) {
			atmMap.put(sb.Account__c, sb);
		}
		for (AccountTeamMember atm : atmRS) {

			map<String, object> defaultValues = new map<String, object> ();
			User u = mapUser.get(atm.UserId);
			defaultValues.put('Name', u.Name);
			defaultValues.put('TeamMemberRole', atm.TeamMemberRole);
			defaultValues.put('AccountAccessLevel', atm.AccountAccessLevel);
			defaultValues.put('OpportunityAccessLevel', atm.OpportunityAccessLevel);
			defaultValues.put('atmId', atm.Id);
			defaultValues.put('atmAccountId', atm.AccountId);
			atmInformation = atm.AccountId + ':::' + atm.UserId;
			defaultValues.put('atmInformation', atmInformation);
			defaultValues.put('HasSalesBudget', String.valueOf(sbMap.containsKey(atm.UserId)).toUpperCase());
			defaultValues.put('HasAccountTransfer', String.valueOf(atmMap.containsKey(atm.AccountId)).toUpperCase());
			atmList.add(defaultValues);
		}
		return atmList;
	}

	//Code Added for SRSF-1741 Starts Here
	@AuraEnabled
	public static List<String> getDMAValue() {
		List<String> DmaValues = new List<String> ();
		DmaValues.add('--None--');
		for (Schema.PicklistEntry pickVal : Opportunity.DMA__c.getDescribe().getPicklistValues()) {
			DmaValues.add(pickVal.getValue());
		}
		System.debug('DmaValues::' + DmaValues);
		return DmaValues;
	}

	@AuraEnabled
	public Static String deleteSelectedAtm(boolean isUpdateOpenAccDMA, string strDMA, string accId, String[] AccountIds) {
		System.debug('In deleteSelectedAtm() size ' + AccountIds);
		Set<Accountteammember> acctmDeleteList = new Set<Accountteammember> ();
		List<AccountShare> accShareDeleteList = new List<AccountShare> ();
		List<Account_SAM_Mapping__c> samDeleteList = new List<Account_SAM_Mapping__c> ();
		List<String> UserId = new List<String> ();
		List<String> atmAccountIds = new List<String> ();

		for (String atmId : AccountIds) {
			String[] args = atmId.split(':::');
			String atmAccountId = args[0];
            System.debug('atmAccountId '+ atmAccountId);
			String atmUserId = args[1];
            System.debug('atmUserId '+ atmUserId);
			UserId.add(atmUserId);
			atmAccountIds.add(atmAccountId);
		}
        System.debug('Account Ids '+ UserId);
		List<Sales_Budget__c> sbList = new List<Sales_Budget__c> ();

		sbList = [Select budget_user__c from Sales_Budget__c where budget_user__c In :UserId
		          and advertiser__c = :atmAccountIds and amount__c > 1
		          and Type__c = 'Data'
		          and CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueof(Label.BudgetCurrentYear) limit 1];
		List<Accountteammember> at = new List<Accountteammember>();
		at = [Select Id from Accountteammember where AccountId In :atmAccountIds and UserId In :UserId];
			System.debug('at '+ at);
		List<AccountShare> accShare = new List<AccountShare> ();
		accShare = [Select Id from AccountShare where AccountId In :atmAccountIds and UserOrGroupId In :UserId and RowCause = 'Manual' Limit 1];

		List<Account_SAM_Mapping__c> samObjects = [SELECT Id FROM Account_SAM_Mapping__c WHERE Account__c In :atmAccountIds and User__c In :UserId];
        Set<String> AccountIdSet = new set<String>();
            for (String atm : AccountIds) {
                AccountIdSet.add(atm);
            }
        System.debug('Account Id Set '+ AccountIdSet);
		for (String atm : AccountIdSet) {
			System.debug('deleteSelectedAtm atm ' + atm);
			String[] args = atm.split(':::');
			String atmAccount = args[0];
			String atmUser = args[1];

			sbMap = new Map<Id, Sales_Budget__c> ();
			try {

				System.debug('sb: ' + sbList);
				if (sbList.size() > 0) {
					return 'Error';
				}
			}
			catch(Exception ex) {
				System.debug('deleteSelectedAtm ' + ex);
			}
			atmMap = new Map<Id, Account_Transfer_Mapping__c> ();
			try {
				Account_Transfer_Mapping__c atsMapp = new Account_Transfer_Mapping__c();
				atsMapp = [Select Id, From_User__c, To_User__c, Account__c from Account_Transfer_Mapping__c where(From_User__c In :UserId) and Account__c = :AccId and Account_Transfer_Simulation__r.Status__c NOT IN :System.Label.Transfer_Status.split(',') limit 1];
				System.debug('atm: ' + atsMapp);
				if (atsMapp != null) {
					return 'Error';
				}
			}
			catch(Exception ex) {
				System.debug('deleteSelectedAtm  ' + ex);
			}
			System.debug('deleteSelectedAtm atmAccount ' + atmAccount);
			System.debug('deleteSelectedAtm atmUser ' + atmUser);
			try {
                //acctmDeleteList = [Select Id from Accountteammember where AccountId In :atmAccountIds and UserId In :UserId];
				 acctmDeleteList.AddAll(at);
                 System.debug('at List '+ acctmDeleteList);
			}
           
			catch(Exception e) {
				System.debug('********** Error deleteSelectedAtm Records: acctmDeleteList.Add ' + e);
			}

			try {
				if (accShare.size() > 0)
				accShareDeleteList.Add(accShare[0]);
			}
			catch(Exception e) {
				System.debug('********** Error deleteSelectedAtm Records: accShareDeleteList.Add ' + e);
			}

			//SRSF-1327

			System.debug('samObjects ' + samObjects.size());

			for (Account_SAM_Mapping__c sam : samObjects) {
				System.debug('Adding to SAM list');
				samDeleteList.add(sam);
			}
		}

		Savepoint spAtmDelete = Database.setSavepoint();
		try {
			System.debug('deleteSelectedAtm ********** Inside try Delete ');
			System.debug('deleteSelectedAtm ********** Try Teammember:acctmDeleteList ' + acctmDeleteList.size());
			System.debug('deleteSelectedAtm ********** Try Teammember:accShareDeleteList ' + accShareDeleteList.size());
			System.debug('deleteSelectedAtm ********** Try Teammember:samDeleteList ' + samDeleteList.size());

			if (acctmDeleteList.size() > 0) {
				System.debug('Inside delete acctmDeleteList.size() > 0 ' + acctmDeleteList.size());
				System.debug('acctmDeleteList: ' + acctmDeleteList);
                List<Accountteammember> lStAccountsDelete = new List<Accountteammember>(acctmDeleteList);
				delete lStAccountsDelete;
			}

			if (accShareDeleteList.size() > 0) {
				System.debug('Inside delete accShareDeleteList.size() > 0 ' + accShareDeleteList.size());
			}

			if (samDeleteList.size() > 0) {
				System.debug('Inside delete samDeleteList.size() > 0 ' + samDeleteList.size());
				delete samDeleteList;
			}

			//updating Account object based on SRSF-1741
			if (isUpdateOpenAccDMA) {
				Account objAcc = [select id, Open_Account__c, Open_Account_DMA__c from Account where id = :accId];
				objAcc.Open_Account__c = true;
				objAcc.Open_Account_DMA__c = strDMA;
				update objAcc;
			}
		} catch(Exception e) {
			Database.rollback(spAtmDelete);
			System.debug('********** Rollback Error Deleting Records: ' + e + ' Line Number: ' + e.getLineNumber());
		}

		return 'Success';
	}

	public Static boolean isValidUser() {
		System.debug('********** Inside isValidUser()');
		User usrProfileName = [select Profile.Name, userRole.Name, Team_Role__c from User where id = :Userinfo.getUserId()];
		System.debug('********** Inside isValidUser() ' + usrProfileName.Profile.Name);
		if (usrProfileName.Profile.Name == 'Integration User' ||
		    usrProfileName.Profile.Name == 'System Administrator' ||
		    usrProfileName.Profile.Name == 'Master - Local Sales Manager' ||
		    usrProfileName.Profile.Name == 'Master - Director of Sales' ||
		    usrProfileName.Profile.Name == 'Master - Interconnect Sales Manager' ||
		    usrProfileName.Profile.Name == 'Master - National Sales Director' ||
		    usrProfileName.Profile.Name == 'Master - National Sales Manager' ||
		    usrProfileName.Profile.Name == 'Master - Spectrum Preferred' ||
		    usrProfileName.Profile.Name == 'Master - Sales Leadership') {
			System.debug('********** Inside isValidUser() return true');
			return true;
		}
		System.debug('********** Inside isValidUser() return false');
		return false;
	}
}