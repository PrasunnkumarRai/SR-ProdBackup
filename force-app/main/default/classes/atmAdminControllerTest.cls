@isTest
public class atmAdminControllerTest {
	static testMethod void testAtmAdminControllerTest() {
		//Boolean isOnOpptyTeam = atmAdminController.isValidUser();
		if (atmAdminController.isValidUser())
		{
			User u = TestDataHelper.getBoomiIntegrationUser();
			System.debug('@@u Name ' + u.Name);
			System.runAs(u) {
				User ae = TestUtil.createAEUser();
				Account acc = TestDataHelper.createAcc('atmAdminControllerTest Test Account', '12834 Grant Circle', 'Omaha', 'NE', '68164', 'USA');
				insert acc;
				Opportunity opp = TestDataHelper.createopportunity('Test Opportunity1', System.today(), 'Planning', 'Pipeline', acc.id);
				insert opp;
				System.AssertNotEquals(opp.Id, null);
				Test.startTest();
				System.debug('@@acc ' + acc);
				//create Account Team member
				insert TestUtil.getAccountTeamMemRec(acc.Id, ae.Id);
				List<map<String, Object>> atmList = atmAdminController.showAccountTeamMembers(acc.ID);
				//System.assertEquals(1,atmList.size()); 
				List<String> testDeleteList = new List<String> ();
				testDeleteList.add(acc.ID + ':::' + u.Id);
				atmAdminController.deleteSelectedAtm(true, 'Atlanta', acc.Id, testDeleteList);
				List<Accountteammember> acctmDeleteList = new List<Accountteammember> ();
				acctmDeleteList = [Select Id from Accountteammember where AccountId = :acc.ID and UserId = :u.Id Limit 1];
				Test.stopTest();
			}
		}
	}
	static testMethod void testAtmAdminControllerTest1() {

		User u = TestDataHelper.getBoomiIntegrationUser();
		//System.debug('@@u Name '+u.Name);
		System.runAs(u) {
			User ae = TestUtil.createAEUser();
			Account acc = TestDataHelper.createAcc('atmAdminControllerTest Test Account', '12834 Grant Circle', 'Omaha', 'NE', '68164', 'USA');
			acc.ownerId = userinfo.getuserid();
			insert acc;
			accountteammember atm = new accountteammember();
			atm.AccountId = acc.id;
			atm.userid = acc.ownerid;
			atm.teammemberrole = 'Sales Assistant';
			insert atm;
			Account_SAM_Mapping__c newAsm = new Account_SAM_Mapping__c(account__c = Acc.Id, user__c = UserInfo.getUserId(),
			                                                           Tier_Designation__c = 'Premier',
			                                                           ownerId = userinfo.getuserId());
			insert newAsm;
			Opportunity opp = TestDataHelper.createopportunity('Test Opportunity1', System.today(), 'Planning', 'Pipeline', acc.id);
			insert opp;
			System.AssertNotEquals(opp.Id, null);
			Test.startTest();
			System.debug('@@acc ' + acc);
			//create Account Team member
			insert TestUtil.getAccountTeamMemRec(acc.Id, ae.Id);
			List<map<String, Object>> atmList = atmAdminController.showAccountTeamMembers(acc.ID);
			//System.assertEquals(1,atmList.size()); 
			List<String> testDeleteList = new List<String> ();
			testDeleteList.add(acc.ID + ':::' + userinfo.getuserId());
			atmAdminController.deleteSelectedAtm(true, 'Atlanta', acc.Id, testDeleteList);
			List<Accountteammember> acctmDeleteList = new List<Accountteammember> ();
			acctmDeleteList = [Select Id from Accountteammember where AccountId = :acc.ID and UserId = :userinfo.getuserId() Limit 1];
			Test.stopTest();
		}

	}
	static testMethod void testAtmAdminControllerTest3() {

		User u = TestDataHelper.getBoomiIntegrationUser();
		//System.debug('@@u Name '+u.Name);
		System.runAs(u) {
			User ae = TestUtil.createAEUser();
			Account acc = TestDataHelper.createAcc('atmAdminControllerTest Test Account', '12834 Grant Circle', 'Omaha', 'NE', '68164', 'USA');
			acc.ownerId = userinfo.getuserid();
			insert acc;
			accountteammember atm = new accountteammember();
			atm.AccountId = acc.id;
			atm.userid = acc.ownerid;
			atm.teammemberrole = 'Sales Assistant';
			insert atm;

			Sales_Budget__c sb = new Sales_Budget__c();
			sb = TestUtil.getSalesBudgetRec(ae, acc);
			sb.Type__c = 'DOS';
			insert sb;
			Account_SAM_Mapping__c newAsm = new Account_SAM_Mapping__c(account__c = Acc.Id, user__c = UserInfo.getUserId(),
			                                                           Tier_Designation__c = 'VIP',
			                                                           ownerId = userinfo.getuserId());
			insert newAsm;
			Opportunity opp = TestDataHelper.createopportunity('Test Opportunity1', System.today(), 'Planning', 'Pipeline', acc.id);
			insert opp;
			System.AssertNotEquals(opp.Id, null);
			Test.startTest();
			System.debug('@@acc ' + acc);
			//create Account Team member
			insert TestUtil.getAccountTeamMemRec(acc.Id, ae.Id);
			List<map<String, Object>> atmList = atmAdminController.showAccountTeamMembers(acc.ID);
			//System.assertEquals(1,atmList.size()); 
			List<String> testDeleteList = new List<String> ();
			testDeleteList.add(acc.ID + ':::' + userinfo.getuserId());
			atmAdminController.deleteSelectedAtm(true, 'Atlanta', acc.Id, testDeleteList);
			List<Accountteammember> acctmDeleteList = new List<Accountteammember> ();
			acctmDeleteList = [Select Id from Accountteammember where AccountId = :acc.ID and UserId = :userinfo.getuserId() Limit 1];
			Test.stopTest();
		}

	}
}