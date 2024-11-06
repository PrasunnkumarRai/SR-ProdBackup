global class BoomiWebServiceMock implements HttpCalloutMock {
	global static String name = '';
	global HTTPResponse respond(HTTPRequest req) {
		HttpResponse res;
		if (name == 'UserSynchronizationToTIMTest') {
			res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody('{"AEList":{"AE_3_5":[{"TrafficIDs":{"TrafficIDElement":[{"TrafficID":"LHA","ExportSystemID":null}]},"IsActive":null,"Alias":null,"AeOfficeID":null,"AeName":"Naveen","AeID":"1"}]}}');
			res.setStatusCode(200);
			res.setStatus('OK');
			return res;
		} else if (name == 'BoomiDashboardController'){
			res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');			
			res.setBody('{"Response":{"error":[{"message" : "3ad84a8f-821a-43ba-8c9a-e442c7020f8c","cause" : "INT-001 Authentication_Provider","ExecutionRecord":[{"executionId":"execution-4820cb7b-bd8a-4b2a-a92a-c14c6e38c514-2017.06.27","executionTime":"2017-06-27T01:56:36-0500","status":"COMPLETE","executionType":"exec_listener","processName":"INT-001 Authentication_Provider","processId":"3ad84a8f-821a-43ba-8c9a-e442c7020f8c","atomName":"STL_DEV_01","atomId":"fa179ef9-a2f3-4c71-8498-b6a4cc8a1c94","inboundDocumentCount":"1","outboundDocumentCount":"0","executionDuration":"140","outboundDocumentSize":"0"}]}]}}');
			res.setStatusCode(200);
			res.setStatus('OK');
			return res;
		} 
		else if (name == 'BoomiWebServiceHelperTest'){
			res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');			
			res.setBody('{"Response":{"metadata":[{"executionId" : "3ad84a8f-821a-43ba-8c9a-e442c7020f8c","System" : "3ad84a8f-821a-43ba-8c9a-e442c7020f8c","date" : "3ad84a8f-821a-43ba-8c9a-e442c7020f8c","ProcessName" : "INT-001 Authentication_Provider"}],"error":[{"message" : "3ad84a8f-821a-43ba-8c9a-e442c7020f8c","cause" : "INT-001 Authentication_Provider","ExecutionRecord":[{"executionId":"execution-4820cb7b-bd8a-4b2a-a92a-c14c6e38c514-2017.06.27","executionTime":"2017-06-27T01:56:36-0500","status":"COMPLETE","executionType":"exec_listener","processName":"INT-001 Authentication_Provider","processId":"3ad84a8f-821a-43ba-8c9a-e442c7020f8c","atomName":"STL_DEV_01","atomId":"fa179ef9-a2f3-4c71-8498-b6a4cc8a1c94","inboundDocumentCount":"1","outboundDocumentCount":"0","executionDuration":"140","outboundDocumentSize":"0"}]}]}}');
			res.setStatusCode(200);
			res.setStatus('OK');
			return res;
		}
		
		else if (name == 'ProposalSCXUpload'){
			res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');			
			res.setBody('{"ImportSCX_Result":{"ID":"76483","HasErrors":"false","Messages":{"Message":["Missing/Invalid EstimateID: Order will be imported as new.","Missing/Invalid RevisionID:RevisionID will be defaulted to.","RevisionID=0","Warning:User SFDCUser are assigned more than one AEs.The most recently used or most recently added AE is chosen as the default."]}}}');
			res.setStatusCode(200);
			res.setStatus('OK');
			return res;
		} 
		else{
			res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody('{  "SAuthenticateResponse" : {    "SAuthenticateResult" : "nmgv3ufn5pbrvsu1qxfawrtc"  }}');
			res.setStatusCode(200);
			res.setStatus('OK');
			return res;
		}
		return null;
	}
}