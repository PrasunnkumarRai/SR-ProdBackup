global class ShowSeekerWebServiceMock implements HttpCalloutMock 
{
    Integer statusCode;
    global ShowSeekerWebServiceMock(Integer statusCode)
    {
        this.statusCode = statusCode;
    }

    global HTTPResponse respond(HTTPRequest req) 
    {
        HttpResponse res;
        String endpoint = req.getEndpoint();
        System.debug('Endpoint-->'+endpoint);
        System.debug('statusCode-->'+statusCode);

        if(statusCode == 200)
        {
            if(endpoint.contains('/crm/startproposal')) 
            {
                res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{ "proposalId": 0,  "link":  "https://spectrumreach.showseeker.com/123456789" }');
                res.setStatusCode(200);
                res.setStatus('OK');
            }
            else if(endpoint.contains('/crm/editproposal')) 
            {
                res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{ "proposalId": 0,  "link":  "https://spectrumreach.showseeker.com/123456789" }');
                res.setStatusCode(200);
                res.setStatus('OK');
            }
            else if(endpoint.contains('/crm/archive')) 
            {
                res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"userName":"user@email.com","proposals":[{"proposalId":12345,"isActive":true,"isSuccess":true}]}');
                res.setStatusCode(200);
                res.setStatus('OK');
            }
            else {
                res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{ "tokenId": "12345" }');
                res.setStatusCode(200);
                res.setStatus('OK');
            }
        }
        else{
            if(endpoint.contains('/crm/startproposal')) 
            {
                res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"error": "NotFound","message":"Unable to find user"}');
                res.setStatusCode(400);
                res.setStatus('OK');
            }
            else if(endpoint.contains('/crm/editproposal')) 
            {
                res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"error":"UnkownProposalId","message":"unable to find proposal with id 12345678"}');
                res.setStatusCode(400);
                res.setStatus('OK');
            }
            else if(endpoint.contains('/crm/archive')) 
            {
                res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"error": "NotFound","message":"Unable to find user"}');               
                res.setStatusCode(400);
                res.setStatus('OK');
            }
            else { //Auth call always success, else remaining endpoint error scenarios will not cover
                res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{ "tokenId": "12345" }');
                res.setStatusCode(200);
                res.setStatus('OK');
            }
        }
        System.debug('Mock Response--->'+res);
        return res;
    }
}