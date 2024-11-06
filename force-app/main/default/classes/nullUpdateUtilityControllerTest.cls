@IsTest
public class nullUpdateUtilityControllerTest {
    
 

    @IsTest
    static void testGetCurrentUserEmail() {
        Test.startTest();
        String email = nullUpdateUtilityController.getCurrentUserEmail();
        System.assertNotEquals(null, email, 'Email should not be null');
        Test.stopTest();
    }

    @IsTest
    static void testGetFields() {
        Test.startTest();
        List<nullUpdateUtilityController.FieldWrapper> fields = nullUpdateUtilityController.getFields('Account');
        System.assertNotEquals(0, fields.size(), 'Fields list should not be empty');
        Test.stopTest();
    }
    
 
    @IsTest
    static void testExecuteSOQLQuery() {
      

        Test.startTest();
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        String soql = 'SELECT Count(Id) FROM Account';
       Object results =  nullUpdateUtilityController.executeSOQLQuery(soql);

        Test.stopTest();
    }



    @IsTest
    static void testCallBoomiListener() {
        String payload = '{"key":"value"}';
        
        // Mock the HTTP response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"success":true}');
        mockResponse.setStatusCode(200);
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        Test.startTest();
        nullUpdateUtilityController.callBoomiListener(payload);
        Test.stopTest();
    }

    @IsTest
    static void testFetchObjectDetails() {
        Test.startTest();
        List<Object_details_for_data_retention__mdt> objectDetails = nullUpdateUtilityController.fetchObjectDetails();
       // System.assertEquals(2, objectDetails.size(), 'There should be 2 records fetched');
        Test.stopTest();
    }

    // Mock HTTP response generator for callouts
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;

        public MockHttpResponseGenerator(HttpResponse response) {
            this.response = response;
        }

        public HTTPResponse respond(HTTPRequest req) {
            return response;
        }
    }
    
  

    @isTest
    static void testGetFields_Exception() {
        Test.startTest();
        try {
            // Using a non-existent object to induce an exception
            List<nullUpdateUtilityController.FieldWrapper> fields = nullUpdateUtilityController.getFields('NonExistentObject');
            System.assert(false, 'Expected exception was not thrown');
        } catch (Exception e) {
            System.assert(true, 'Exception was successfully caught');
        }
        Test.stopTest();
    }

    @isTest
    static void testExecuteSOQLQuery_Exception() {
        Test.startTest();
        try {
            // Using a malformed SOQL query to induce an exception
            Object result = nullUpdateUtilityController.executeSOQLQuery('SELECT MALFORMED_QUERY FROM NonExistentObject');
            System.assert(false, 'Expected exception was not thrown');
        } catch (Exception e) {
            System.assert(true, 'Exception was successfully caught');
        }
        Test.stopTest();
    }

   

    // Mock class for custom metadata
    private class CustomMetadataMock implements System.StubProvider {
        public Object handleMethodCall(Object obj, String methodName, System.Type returnType, List<System.Type> paramTypes, List<String> paramNames, List<Object> paramValues) {
            if (methodName == 'query' && paramTypes.size() == 1 && paramTypes.get(0) == String.class) {
                // Simulating an exception for custom metadata query
                throw new QueryException('Mock query exception');
            }
            return null;
        }
    }
}