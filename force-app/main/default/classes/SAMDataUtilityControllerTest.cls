@IsTest
public class SAMDataUtilityControllerTest {

    @TestSetup
    static void setupData() {
        // Instead of inserting metadata, you can mock the behavior or rely on existing records if any.

        // Create test Account_SAM_Mapping__c records
        Account_SAM_Mapping__c samMapping1 = new Account_SAM_Mapping__c(Tier_Designation__c = 'Elite');
        Account_SAM_Mapping__c samMapping2 = new Account_SAM_Mapping__c(Tier_Designation__c = 'VIP');
        insert new List<Account_SAM_Mapping__c>{samMapping1, samMapping2};
    }

    @IsTest
    static void testSendCsvData_TrueUpsertStatus() {
        Test.startTest();
        SAMDataUtilityController.chunkDataWrapper chunkData = new SAMDataUtilityController.chunkDataWrapper();
        chunkData.csvData = 'some csv data';
        chunkData.TransactionID = '12345';
        chunkData.upsertStatus = true;

        // Mocking HTTP Response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('Data sent to Boomi successfully');

        // Set mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, 'Success'));

        // Call method
        String result = SAMDataUtilityController.sendCsvData(chunkData);
        System.assertEquals('Data sent to Boomi successfully', result);
        Test.stopTest();
    }

    @IsTest
    static void testSendCsvData_FalseUpsertStatus() {
        Test.startTest();
        SAMDataUtilityController.chunkDataWrapper chunkData = new SAMDataUtilityController.chunkDataWrapper();
        chunkData.csvData = 'some csv data';
        chunkData.TransactionID = '12345';
        chunkData.upsertStatus = false;

          // Call the method
        String result = SAMDataUtilityController.sendCsvData(chunkData);
        
           // Check the result
        //System.assertEquals('Null', result);
        Test.stopTest();
    }

    @IsTest
    static void testGetMetadata() {
        Test.startTest();

        // Use existing metadata records if needed, or mock the query result
        Sam_Data_Load_Utility_Metadata__mdt result = SAMDataUtilityController.getMetadata();
        System.assertNotEquals(null, result);
        Test.stopTest();
    }

    @IsTest
    static void testDeleteRecords() {
        Test.startTest();
        List<String> designations = new List<String>{'Elite', 'Premiere'};
        List<String> designations2 = new List<String>{'Key', 'Pending'};
        SAMDataUtilityController.deleteRecords(designations);
        SAMDATARecordsDeleteBatch sb = new SAMDATARecordsDeleteBatch(designations2);
        Database.executeBatch(sb);
        Test.stopTest();
    }

    @IsTest
    static void testGetGroupedByTierDesigRecCount() {
        Test.startTest();
        List<AggregateResult> result = SAMDataUtilityController.getGroupedByTierDesigRecCount();
        System.assertNotEquals(null, result);
        System.assertEquals(2, result.size());
        Test.stopTest();
    }


 @IsTest
    public static void testSendCsvData_Exception() {
        // Set up mock to simulate an exception during HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseServerError()); // Mock class to simulate server error
        
        // Create instance of chunkDataWrapper and set values
        SAMDataUtilityController.chunkDataWrapper chunkData = new SAMDataUtilityController.chunkDataWrapper();
        chunkData.csvData = 'some csv data';
        chunkData.TransactionID = '12345';
        chunkData.upsertStatus = true;

        // Call method within test context
        Test.startTest();
        String result = SAMDataUtilityController.sendCsvData(chunkData);
        Test.stopTest();
        
    }

    private class MockHttpResponseServerError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Simulate an HTTP 500 error response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Internal Server Error');
            return res;
        }
    }
    
    // Mock class for HTTP callout
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;

        public MockHttpResponseGenerator(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            return res;
        }
    }
}