@isTest 
private class SalesRevenueCancelledOrderDeletionTest {

	@isTest
	private static void testName() {
        
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

        //Create Sales Revenue
        Sales_Revenue__c  revenue = TestUtil.getSalesRevenueRec(userAE,acc,System.today());	
        revenue.Customer_Number__c = '1111';
        revenue.Account_Executive__c = userAE.Id;
        revenue.Product_Line__c = 'Digital';
        revenue.Advertiser__c = acc.Id;
		revenue.External_Id__c = 'digital1';
        insert revenue; 
		//CreateSalesRevenue
	        Sales_Revenue__c  sr = TestUtil.getSalesRevenueRec(userAE,acc,System.today());	
			sr.Customer_Number__c = '5413';
	        sr.AE_Id__c = '2222';
	        sr.Eclipse_System__c = 'TWNY';
			sr.Product_Line__c = 'Digital';
			sr.DMA__c = 'Topeka';
			sr.External_Id__c = 'digital2';
	        insert sr;
	       
        
        SalesRevenueCancelledOrderDeletion btms = new SalesRevenueCancelledOrderDeletion('SELECT ID, Eclipse_System__c, Revenue__c  FROM Sales_Revenue__c where  (Eclipse_System__c != \'WO LA SN\' and Eclipse_System__c != \'WOLA\') and Revenue__c = null LIMIT 1');
        try{
            System.runAs (userAE) {
                Test.startTest();
                  Database.executeBatch(btms,1);                    
                Test.stopTest();
            }
        }catch(Exception ex){}
    }    	
    } }