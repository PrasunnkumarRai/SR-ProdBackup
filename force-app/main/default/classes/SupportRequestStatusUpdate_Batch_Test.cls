@isTest
private class SupportRequestStatusUpdate_Batch_Test {
	static opportunity opp;

    @Testsetup static void prepareData() {
        
        Account acc = TestDataHelper.createAcc('Test Account', null, null, null, null, null);                        
        insert acc;
        System.debug('@@acc '+acc);
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.runAs(u){
            opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),null,null,acc.ID);        
            insert opp;
        }
        System.debug('@@opp '+opp);

        Support_Request__c request = TestDataHelper.createSupportrequest('Test Support Request', opp.Id, 2,null,null,System.today());
        insert request;
        System.debug('@@request '+request);

        List<Production_Service__c> services;
        
            Production_Service__c prop = TestDataHelper.createProdservice('Test Production',request.Id,System.today());
        	prop.Digital_Order_Status__c='Complete - Billing Submitted';
            prop.IMN_ID__c = '1111';
            insert prop;
        	Production_Service__c prop1 = TestDataHelper.createProdservice('Test Production1',request.Id,System.today());
        	prop1.Linear_Order_Status__c='Complete - Billing Submitted';
        	prop1.IMN_ID__c = '1122';
        	insert prop1;
    }
    
    @isTest static void testMethodForBatchClass(){
        test.startTest();
        Database.executeBatch(new SupportRequestStatusUpdate_Batch());
        test.stopTest();
    }
    
    @isTest static void testMethodForSchedulerClass(){
        test.startTest();
        String sch = '20 30 8 10 2 ?';     
        String jobID = system.schedule('Schedule for SupportRequestStatusUpdate Batch', sch, new SupportRequestStatusUpdate_Scheduler());
        test.stopTest();
    }
  
}