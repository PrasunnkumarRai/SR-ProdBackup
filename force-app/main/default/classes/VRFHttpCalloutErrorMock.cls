global class VRFHttpCalloutErrorMock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('Enternal Server Error');
        response.setStatusCode(500);
        return response; 
    }
}