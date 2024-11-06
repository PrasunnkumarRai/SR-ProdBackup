@isTest
global class VRFHttpCalloutMock implements HttpCalloutMock {

      global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"DccId":"a098A000001NgccQAC","SdAssetId":"3019061900000023","HdAssetId":"3019061900000024","CreativeUrl":["https://www.google.com/","https://msdn.microsoft.com/en-us/","https://spectrumreach--operative.lightning.force.com/lightning/n/Announcements"]}');
        response.setStatusCode(200);
        return response; 
    }
}