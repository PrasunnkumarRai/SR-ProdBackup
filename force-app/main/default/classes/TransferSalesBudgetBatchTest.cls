@IsTest
private with sharing class TransferSalesBudgetBatchTest {
	
    @isTest static void budgetTransferBatchExecutionTest() {
	User userAE = TestUtil.prepareUser();
	 User userAE2 = TestUtil.prepareUser();
	 Account acc = TestUtil.getAccountRec();
	  AccountTeammember accTM = new AccountTeammember();
	  Accountshare accShare = new Accountshare();
    	        User thisUser=[Select ID,Name from User Where ID=:UserInfo.getUserId()];
        System.runAs (thisUser){
        //create AE User
        
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@mands.com';
        userAE.Budget_type__c = 'Local';
        userAE.Budget_product_Lines__c = 'Linear/News/Sports';
        userAE.rate_plan_status__c = 'Draft';
        insert userAE;
        
        //Create To AE User
       
        //Profile objProfile2 = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        userAE2.ProfileId = objProfile.Id;
        userAE2.Username = 'testae2@mands.com';
        userAE2.Budget_type__c = 'Local';
        userAE2.Budget_product_Lines__c = 'Linear/News/Sports';
        userAE2.rate_plan_status__c = 'Draft';
        insert userAE2;
		
		//create account
		
        acc.primary_commodity__c =   'Auto Aftermarket';
        insert acc;

		//create account team member
       
        accTM.UserID = userAE.Id;
        accTM.AccountId = acc.Id;
        accTM.Teammemberrole = 'Other';
        insert accTM;
		
		//create account share
        
        accShare.AccountId = acc.Id;
        accShare.UserOrGroupId = userAE.Id;
        accShare.AccountAccessLevel = 'Edit';
        accShare.OpportunityAccessLevel = 'Edit';
        insert accShare;
		}
        //create Sales Budget
        Sales_Budget__c sb = new Sales_Budget__c();
        sb = TestUtil.getSalesBudgetRec(userAE, acc);
        sb.Type__c = 'Data';
        sb.Amount__c = Integer.valueOf(Label.RatePlanThresholdAmount);
        sb.old_budget_user__c = userAE.Id;
        sb.OwnerId  = userAE.id;
        insert sb;
        
        Account_Transfer_Tool__c ats = new Account_Transfer_Tool__c();
        ats.Division__c = 'Central';
        ats.Region__c = 'MidNorth';
        ats.Status__c = 'New';
        ats.Transfer_Effective_Date__c = Date.newInstance(2019, 01, 15);
        ats.OwnerId = userAE.Id;
        ats.NCC__c = 'NCC' ;
        ats.Transfer_All_Accounts__c = true;
        insert ats;        
        system.debug('ats.OwnerId '+ats.OwnerId);
        Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
        atm.Account__c = acc.Id;
        atm.Account_Transfer_Simulation__c = ats.Id;
        atm.From_User__c = userAE.Id;
        atm.To_User__c = userAE2.Id;
        atm.External_ID__c = userAE2.Id+';;;'+acc.Id+';;;'+'2019Jan'+';;;'+ats.Id;
        //atm.OwnerId = userAE.Id;
        insert atm;
        system.debug('ATS ID: '+atm.Id);
        system.debug('ATS ID: '+atm.Account_Transfer_Simulation__c);
        Admin_Tool_Status_Summary__c adminSummary = new Admin_Tool_Status_Summary__c();
        adminSummary.From_User_Id__c = String.valueOf(userAE.Id);
        adminSummary.To_User_Id__c = String.valueOf(userAE2.Id);
        adminSummary.Transfer_Details__c = atm.Id;
        //adminSummary.Transfer_Details__r.Account_Transfer_Simulation__r.Id = ats.Id;
        //system.debug('Simulation Id: ' + adminSummary.Transfer_Details__r.Account_Transfer_Simulation__r.Id);
        insert adminSummary;
        system.debug('adminSummary.Transfer_Details__c '+adminSummary.Transfer_Details__r.Account_Transfer_Simulation__c);       
        
		List<Admin_Tool_Status_Summary__c> admToolSummaryIDs = [Select ID,To_User_Id__c,From_User_Id__c,  Transfer_Details__r.Account_Transfer_Simulation__r.Transfer_Effective_Date__c,Transfer_Details__c,
	        	Transfer_Details__r.Account_Transfer_Simulation__r.Id from Admin_Tool_Status_Summary__c where Transfer_Details__r.Account_Transfer_Simulation__c =:  ats.id];
		
		Map<String,Integer> mapOfBcthsize = new Map<String,Integer>();
		mapOfBcthsize.put('Budget_Batch_Size',200);
        mapOfBcthsize.put('NBUC_Batch_Size',200);  

		//try{
		System.runAs (userAE) {
        	Test.startTest();
        		TransferSalesBudgetBatch tsb = new TransferSalesBudgetBatch('',admToolSummaryIDs,mapOfBcthsize);
                //tsb.IsRetry = true;
        		Database.executeBatch(tsb, 200);
        	Test.stopTest();
		}
        //}catch(Exception ex){}
    }  
}