@isTest
private class AccountTransferToolTriggerTest {

	@isTest
	static void accountTransfertriggerMain()
	{
		User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];

		System.runAs(thisUser) {
			User userAE = TestUtil.prepareUser();
			Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Master - Account Executive'];
			userAE.ProfileId = objProfile.Id;
			userAE.HR_Manager__c = thisUser.Id;
			userAE.Username = 'testae@mands.com';
			userAE.Budget_type__c = 'Local';
			userAE.Budget_product_Lines__c = 'Linear/News/Sports;';
			userAE.Firstname = 'Test';
			userAE.Lastname = 'User1';
			insert userAE;

			User userAETo = TestUtil.prepareUser();
			userAETo.ProfileId = objProfile.Id;
			userAETo.HR_Manager__c = thisUser.Id;
			userAETo.Username = 'testaeTo@mands.com';
			userAETo.Budget_type__c = 'Local';
			userAETo.Budget_product_Lines__c = 'Linear/News/Sports;';
			userAETo.Firstname = 'Test';
			userAETo.Lastname = 'User';
			insert userAETo;

			Account acc = TestUtil.getAccountRec();
			acc.primary_commodity__c = 'Auto Aftermarket';
			insert acc;


			AccountTeammember accTM = new AccountTeammember();
			accTM.UserID = userAE.Id;
			accTM.AccountId = acc.Id;
			accTM.Teammemberrole = 'Account Executive';
			insert accTM;

			AccountTeammember accTM2 = new AccountTeammember();
			accTM2.UserID = userAETo.Id;
			accTM2.AccountId = acc.Id;
			accTM2.Teammemberrole = 'Account Executive';
			insert accTM2;

			Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
			att.Division__c = 'Central';
			att.Region__c = 'MidNorth';
			att.Status__c = 'New';
			att.Transfer_Effective_Date__c = Date.newInstance(2019, 01, 15);
			insert att;

			Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
			atm.Account__c = acc.Id;
			atm.Account_Transfer_Simulation__c = att.Id;
			atm.From_User__c = userAE.Id;
			atm.To_User__c = userAETo.Id;
			atm.External_ID__c = userAE.Id + ';;;' + acc.Id + ';;;' + '2019Jan' + ';;;' + userAETo.Id;
			insert atm;

			List<Sales_Budget__c> slist = new list<Sales_Budget__c> ();
			Sales_Budget__c sb1 = new Sales_Budget__c();
			sb1.Advertiser__c = acc.Id;
			sb1.Type__c = 'DOS';
			// sb1.Amount__c = Integer.valueOf(Label.RatePlanThresholdAmount);

			sb1.Amount__c = 500500;
			sb1.Budget_User__c = userAE.Id;
			sb1.New_Business_Churn__c = 'Unknown Churn';
			sb1.DMA__c = 'DMAs';
			// sb1.Old_Budget_User__c=u3.id;
			sb1.Product_Line__c = 'Linear/News/Sports';
			sb1.Commodity__c = 'Restaurant';
			sb1.Broadcast_Month_Date__c = Date.Today();
			sb1.External_Id__c = '007' + userAE.id + sb1.Advertiser__c + System.today();
			slist.add(sb1);
			insert slist;

			Admin_Tool_Status_Summary__c obj = new Admin_Tool_Status_Summary__c();
			obj.From_User_Id__c = UserInfo.getUserId();
			obj.To_User_Id__c = UserInfo.getUserId();
			obj.Proposal_End_Date__c = String.valueOf(Date.today());
			obj.Job_Type__c = 'AE Transfer';
			obj.Transfer_Details__c = atm.Id;
			insert obj;

			List<Admin_Tool_Status_Summary__c> lstATSS = new List<Admin_Tool_Status_Summary__c> ();
			Set<string> userset = new set<string> ();
			userset.add(userAE.Id);
			userset.add(userAETo.id);

			Map<string, integer> mapOfBcthsize = new map<string, integer> ();
			mapOfBcthsize.put('Opportunity_Batch_Size', 200);
			mapOfBcthsize.put('Account_Team_Batch_Size', 200);
			mapOfBcthsize.put('Account_Connection_Batch_Size', 200);
			mapOfBcthsize.put('Account_SAM_Mappings_Batch_Size', 200);
			mapOfBcthsize.put('Revenue_Batch_Size', 200);
			mapOfBcthsize.put('Budget_Batch_Size', 200);
			mapOfBcthsize.put('NBUC_Batch_Size', 200);

			String query = 'Select id,Id__c , Status__c,Error_Message__c, Admin_Tool_Status_Summary__r.Proposal_End_Date__c, Admin_Tool_Status_Summary__r.To_User_ID__c, Admin_Tool_Status_Summary__r.From_User_ID__c from Admin_Tool_Status_Detail__c where Object_Type__c = \'Proposal\' and Status__c=\'Not Started\' and Admin_Tool_Status_Summary__r.Id in: admToolSummaryIDs order by Tim_System__c';

			Test.startTest();
			AccountTransferToolController.accountTransfer(att.Id);
			TransferProposalBatch trf = new TransferProposalBatch(query, lstATSS, mapOfBcthsize, userset);
			AccountTransferSchedule ats = new AccountTransferSchedule(trf);
			String sch = '20 30 8 10 2 ?';
			String jobID = system.schedule('Merge Job', sch, ats);

			Test.stopTest();

		}

	}
}