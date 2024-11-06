@IsTest(SeeAllData = false)
public class dnbAuthenticateControllerTest {
	/*public static testmethod void testcallDnBAuth() {       
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock> ();
		WebServiceTestMockDandB dnbAuth = new WebServiceTestMockDandB('dnbAuth');
        Organization org = [Select Id, Name, IsSandbox from Organization LIMIT 1];
		//String baseUrl =  (org.IsSandbox == false? Label.DnBBoomiBaseURL + 'invoke_DnBAuth/': Label.DnBBoomiSandboxBaseURL+'SandboxInvoke_DnBAuth/');
		String baseUrl;
        if(org.IsSandbox == false){
            baseUrl='http://boomiapi-prod02.spectrumreach.com:9090/ws/rest/DnB/invoke_DnBAuth/';
        }else{
            baseUrl='https://uat1-boomi.spectrumreach.com/ws/rest/DnB/SandboxInvoke_DnBAuth/';
        }
        endpoint2TestResp.put(baseUrl,dnbAuth);
		HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.startTest();
		dnbAuthenticateController.callDnBAuth();
		Test.stopTest();
	}*/
    
    
    public static testmethod void testcallDnBAuth() { 
          Test.startTest();
          Test.setMock(HttpCalloutMock.class, new DnBMockHttpResponseGenerator()); 
		dnbAuthenticateController.callDnBAuth();
		Test.stopTest();
    }
    
     private class DnBMockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            String endpoint = req.getEndpoint();
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setStatus('OK');
            
             res.setBody('{"access_token": "6a57U13QGTT27019z9463utI4S14","expiresIn": "86400"}');    
           
             return res;
        }
    }
    
     @isTest
    static void testSchedulableExecution() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DnBMockHttpResponseGenerator()); 
        dnbAuthenticateController dnbAuthController = new dnbAuthenticateController();
        String jobId = System.schedule('Test DnB Auth', '0 0 0 15 3 ?', dnbAuthController);
        
    
        Test.stopTest();
    }
    
    @isTest
    static void testDnbAuthModel() {
        // Create an instance of dnbAuthModel
         dnbAuthenticateController.dnbAuthModel model = new  dnbAuthenticateController.dnbAuthModel();
        
        // Set the properties
        model.access_token = 'sampleAccessToken';
        model.expiresIn = '3600';
    }
    
}