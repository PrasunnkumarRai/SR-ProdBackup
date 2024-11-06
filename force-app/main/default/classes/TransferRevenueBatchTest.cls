@IsTest
private with sharing class TransferRevenueBatchTest {

	@isTest static void revenueTransferBatchExecutionTest() {
		User thisUser = [Select ID, Name from User Where ID = :UserInfo.getUserId()];
		System.runAs(thisUser) {
			//create AE User
			User userAE = TestUtil.prepareUser();
			Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Master - Account Executive'];
			userAE.ProfileId = objProfile.Id;
			userAE.Username = 'testae@mands.com';
			userAE.Budget_type__c = 'Local';
			userAE.Budget_product_Lines__c = 'Linear/News/Sports;';
			userAE.rate_plan_status__c = 'Draft';
			insert userAE;

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

			Account_Transfer_Tool__c ats = new Account_Transfer_Tool__c();
			ats.OwnerId = userAE.Id;
			insert ats;

			Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
			atm.Account__c = acc.Id;
			atm.Account_Transfer_Simulation__c = ats.Id;
			atm.From_User__c = userAE.Id;
			atm.To_User__c = userAE.Id;
			atm.External_ID__c = userAE.Id + ';;;' + acc.Id + ';;;' + '2019Jan' + ';;;' + ats.Id;
			insert atm;

			Admin_Tool_Status_Summary__c adminSummary = new Admin_Tool_Status_Summary__c();
			adminSummary.From_User_Id__c = String.valueOf(userAE.Id);
			adminSummary.To_User_Id__c = String.valueOf(userAE.Id);
			adminSummary.Transfer_Details__c = atm.Id;
			insert adminSummary;


			List<Admin_Tool_Status_Summary__c> admToolSummaryIDs = [Select ID, To_User_Id__c, From_User_Id__c, Transfer_Details__r.Account_Transfer_Simulation__r.Transfer_Effective_Date__c, Transfer_Details__c,
			                                                        Transfer_Details__r.Account_Transfer_Simulation__r.Id from Admin_Tool_Status_Summary__c where Transfer_Details__r.Account_Transfer_Simulation__c = :ats.id];

			Map<String, Integer> mapOfBcthsize = new Map<String, Integer> ();
			mapOfBcthsize.put('Budget_Batch_Size', 200);
			mapOfBcthsize.put('NBUC_Batch_Size', 200);
			TransferRevenueBatch trb1 = new TransferRevenueBatch('', admToolSummaryIDs, mapOfBcthsize);
			List<Account_Transfer_Tool__c> attLst = new List<Account_Transfer_Tool__c> ();
			attLst.add(ats);
			TransferRevenueBatch trb = new TransferRevenueBatch(attLst, mapOfBcthsize);
			try {
				System.runAs(userAE) {
					Test.startTest();
					trb.IsRetry = false;
					Database.executeBatch(trb);

					trb1.IsRetry = true;
					Database.executeBatch(trb1);
					Test.stopTest();
				}
			} catch(Exception ex) { }
		}
	}
}