@isTest	
private with sharing class TrackRatePlanChangeQualificationsTest {   

    
    @isTest (seeAlldata = false)
    static void newBudgetBatchExecutionTest() {
    	User thisUser=[Select ID,Name from User Where ID=:UserInfo.getUserId()];
        System.runAs(thisUser){
        //create AE User
        User userAE = TestUtil.prepareUser();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@mands.com';
        userAE.Budget_type__c = 'Local';
        userAE.Budget_product_Lines__c = 'Linear/News/Sports;';
        userAE.rate_plan_status__c = 'Draft';
        insert userAE;
		
		//create account
		Account acc = TestUtil.getAccountRec();
        acc.primary_commodity__c =   'Auto Aftermarket';
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

        //create Sales Budget
        Sales_Budget__c sb = new Sales_Budget__c();
        sb = TestUtil.getSalesBudgetRec(userAE, acc);
        sb.Type__c = 'Data';
        sb.Amount__c = Integer.valueOf(Label.RatePlanThresholdAmount);
        sb.old_budget_user__c = userAE.Id;
        insert sb;
		
		string qry = 'select id,rate_plan_status__c,Rate_Plan_Commit_Date__c from User where id in: userIds';
		Set<ID> userIds = new Set<Id>();
		userIds.add(userAE.Id);
		TrackRatePlanChangeQualifications tpc = new TrackRatePlanChangeQualifications(qry,userIds);
		
		System.runAs (userAE) {
        	Test.startTest();
                
        		Database.executeBatch(tpc,2);
        	Test.stopTest();
		}
        }  }
    
    @isTest (seeAlldata = false)
    static void existingBudgetBatchExecutionTest() {
    	User thisUser=[Select ID,Name from User Where ID=:UserInfo.getUserId()];
        System.runAs(thisUser){
        //create AE User
        User userAE = TestUtil.prepareUser();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@mands.com';
        userAE.Budget_type__c = 'Local';
        userAE.Budget_product_Lines__c = 'Linear/News/Sports;';
        userAE.rate_plan_status__c = 'Draft';
        insert userAE;
        
        User userAE2 = TestUtil.prepareUser();
        userAE2.ProfileId = objProfile.Id;
        userAE2.Username = 'testae2@mands.com';
        userAE2.Budget_type__c = 'Local';
        userAE2.Budget_product_Lines__c = 'Linear/News/Sports;';
        userAE2.rate_plan_status__c = 'Draft';
        insert userAE2;
		
		//create account
		Account acc = TestUtil.getAccountRec();
        acc.primary_commodity__c =   'Auto Aftermarket';
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

        //create Sales Budget
        Sales_Budget__c sb = new Sales_Budget__c();
        sb = TestUtil.getSalesBudgetRec(userAE, acc);
        sb.Type__c = 'Data';
        sb.old_budget_user__c = userAE2.Id;
        sb.Amount__c = Integer.valueOf(Label.RatePlanThresholdAmount);
        insert sb;
		string qry = 'select id,rate_plan_status__c,Rate_Plan_Commit_Date__c from User where id in: userIds';
		Set<ID> userIds = new Set<Id>();
		userIds.add(userAE2.Id);
		TrackRatePlanChangeQualifications tpc = new TrackRatePlanChangeQualifications(qry,userIds);
		
		System.runAs (userAE) {
        	Test.startTest();
                
        		Database.executeBatch(tpc,2);
        	Test.stopTest();
		}
    }    
    } }