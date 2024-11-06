@IsTest
private with sharing class BudgetingToolMassResubmissionTest {


	@isTest static void BudgetingToolMassResubmissionTest() {
	 Map<String,String> userId = new Map<String,String>();
		User thisUser = [Select ID, Name from User Where ID = :UserInfo.getUserId()];
		System.runAs(thisUser) {
			//create AE User
			User userAE = TestUtil.prepareUser();
			Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Master - Account Executive'];
			userAE.ProfileId = objProfile.Id;
			userAE.Username = 'testae@mands.com';
			userAE.Budget_type__c = 'Local';
		    userAE.FirstName='test User';
			userAE.Budget_product_Lines__c = 'Linear/News/Sports;';
			userAE.rate_plan_status__c = 'Draft';
			insert userAE;
			userId.put(userAE.Id,userAE.FirstName);
			System.debug('userId@'+userAE);
			System.debug('User@@@'+userAE.Id);
			System.debug('User@@@'+userAE.FirstName);
			//create account
			Account acc = TestUtil.getAccountRec();
			acc.primary_commodity__c = 'Auto Aftermarket';
			insert acc;

			//create account team member
			AccountTeammember accTM = new AccountTeammember();
			accTM.UserID = userAE.Id;
			accTM.AccountId = acc.Id;
			accTM.Teammemberrole = 'Other';
			insert accTM;

			//create account share
			Accountshare accShare = new Accountshare();
			accShare.AccountId = acc.Id;
			accShare.UserOrGroupId = userAE.Id;
			accShare.AccountAccessLevel = 'Edit';
			accShare.OpportunityAccessLevel = 'Edit';
			insert accShare;

			//Create Revenue
			Revenue__c revenue = TestDataHelper.createRevenue('2222', '3333', System.today().addYears(- 1), 1000, 1000, 0, 0, '1');
			revenue.ContractNumber__c = 1111;
			revenue.Account_Executive__c = userAE.Id;
			revenue.Product_Line__c = 'Linear';
			revenue.Advertiser__c = acc.Id;
			insert revenue;

			BudgetingToolMassResubmission btms = new BudgetingToolMassResubmission('SELECT Id, budget_type__c FROM User where budget_type__c != null limit 1');
			try {
				System.runAs(userAE) {
					Test.startTest();
					Database.executeBatch(btms, 1);
					//Test.stopTest();
				}
			} catch(Exception ex) {
			}
			BudgetingToolMassResubmission btm = new BudgetingToolMassResubmission('adminutility',userId);
			System.debug('userId@'+userId);
			try {
				System.runAs(userAE) {
					//Test.startTest();
					Database.executeBatch(btm, 1);
					Test.stopTest();
				}
			} catch(Exception ex) {
			}

		}
	}
}