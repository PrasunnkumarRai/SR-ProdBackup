@isTest
public class AOSDealIdSenderTest {

    @isTest
    static void testSendAOSDealIds() {
        // Set up mock response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"data":[{"planId":"12345", "lineName":"Line1", "planName":"Plan1", "planLineId":"1", "packageLineEndDate":"2024-12-31", "packageLineStartDate":"2024-01-01", "creativeLineEndDate":"2024-06-30", "creativeLineStartDate":"2024-01-01"}]}');
        mockResponse.setStatusCode(200);

        // Set up mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        // Create an instance of the class
        AOSDealIdSender sender = new AOSDealIdSender();
        
        // Call the method with a test list
        List<String> testAosDealIds = new List<String>{'12345'};
        Test.startTest();
        sender.sendAOSDealIds(testAosDealIds);
        Test.stopTest();

        // Verify the upsert operation
        List<PLAN_DIGITAL_LINES__c> records = [SELECT Id, Plan_Id__c FROM PLAN_DIGITAL_LINES__c WHERE Plan_Id__c = '12345'];
        System.assertEquals(1, records.size(), 'One record should be upserted');
        System.assertEquals('12345', records[0].Plan_Id__c, 'The Plan_Id__c should match');
    }
    
    // Mock HttpResponseGenerator class for HTTP callout simulation
    class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;

        MockHttpResponseGenerator(HttpResponse response) {
            this.response = response;
        }

        public HttpResponse respond(HttpRequest req) {
            return response;
        }
    }
}