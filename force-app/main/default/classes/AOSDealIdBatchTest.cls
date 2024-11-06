@isTest
private class AOSDealIdBatchTest {

    private class MockAOSDealIdSender implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        // Create a mock response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status": "success"}');
        res.setStatusCode(200);
        return res;
    }
}
    @isTest
    static void testBatch() {
        // Insert test data
        /*List<Proposal__c> proposals = new List<Proposal__c>();
        for (Integer i = 0; i < 10; i++) {
            proposals.add(new Proposal__c(AOS_Deal_Id__c = 'TestDealId_' + i));
        }
        insert proposals;*/
  		Account act = TestDataHelper.createAdvertiser('Test Adv',null,null,null,null,null);
       	insert act;

       	Opportunity opp = TestDataHelper.createopportunity(null,null,null,null,act.id);
       	opp.Amount = 100;
       	opp.Total_Forecast_Amount__c = 50;
       	insert opp;

       	Proposal__c prop = TestDataHelper.createProposal('Test prop',opp.id,null,true);
       	insert prop;
        prop.AOS_Deal_Id__c = 'TestDealId_';
        update prop;
    // Proposal__c prop=  new Proposal__c(AOS_Deal_Id__c = 'TestDealId_' + i)
 // Set the mock response for callouts
        Test.setMock(HttpCalloutMock.class, new MockAOSDealIdSender());
        // Test the batch execution
        Test.startTest();
        AOSDealIdBatch batch = new AOSDealIdBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Verify results (you might need to verify external callouts if applicable)
        // Here, you would check that your handler's sendAOSDealIds method was called as expected
    }
    
    @isTest
    static void testBatchScheduling() {
        // Test scheduling of the batch
        Test.startTest();
        AOSDealIdBatch batch = new AOSDealIdBatch();
        String jobId = System.schedule('Test AOSDealIdBatch Schedule', '0 0 0 * * ?', batch);
        Test.stopTest();

        // Verify the job was scheduled
        CronTrigger[] triggers = [SELECT Id, CronExpression, State FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(1, triggers.size(), 'Cron trigger should be created');
        System.assertEquals('0 0 0 * * ?', triggers[0].CronExpression, 'Cron expression should match');
    }
}