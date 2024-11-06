@IsTest
private with sharing class SalesRevenueReplicationBatchTest {

	
    @isTest static void revenuereplicationBatchExecutionTest() {
        
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

        //Create Revenue
        Revenue__c  revenue = TestDataHelper.createRevenue('2222', '3333', System.today().addYears(-1), 1000, 1000, 0, 0, '1');
        revenue.ContractNumber__c = 1111;
        revenue.Account_Executive__c = userAE.Id;
        revenue.Product_Line__c = 'Linear';
        revenue.Advertiser__c = acc.Id;
        insert revenue; 
        
        SalesRevenueReplicationBatch srr = new SalesRevenueReplicationBatch('');
        try{
            System.runAs (userAE) {
                Test.startTest();
					SalesRevenueReplicationScheduler srrs =new SalesRevenueReplicationScheduler();
					
					DateTime tobeWorked = Datetime.now();
					String hour = String.valueOf(tobeWorked.hour());
					String min = String.valueOf(tobeWorked.minute()); 
					String ss = String.valueOf(tobeWorked.second());
					String nextScheduledTime = ss + ' ' + min + ' ' + hour + ' * * ?';
					
					String jobID = system.schedule('Proposal Transfer Job - ' + revenue.id, nextScheduledTime, srrs);
	
	                Database.executeBatch(srr);                    
                Test.stopTest();
            }
        }catch(Exception ex){}
    }    
    } }