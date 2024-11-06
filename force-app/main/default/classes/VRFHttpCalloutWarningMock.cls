@isTest
global class VRFHttpCalloutWarningMock implements HttpCalloutMock  {
    
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('Warning Message');
        response.setStatusCode(409);
        return response; 
    }
}