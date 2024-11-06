public class SAMDataUtilityControllerMock implements HttpCalloutMock {
	public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if(req.getbody()==''){
            res.setStatus('NOT OK');
        	res.setBody('Mock response body');
            res.setStatusCode(400);
        }else{
            res.setStatus('OK');
        	res.setBody('Mock response body');
            res.setStatusCode(200);
        }
        
        return res;
    }
}