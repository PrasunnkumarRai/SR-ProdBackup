@isTest
global class AOSWebServiceMock implements HttpCalloutMock
{
    Integer statusCode;
    public AOSWebServiceMock(Integer statusCode) {
        this.statusCode = statusCode;
    }

    global HTTPResponse respond(HTTPRequest req) 
    {
        HttpResponse res;
        String endpoint = req.getEndpoint();
        System.debug('Endpoint-->'+endpoint);
        System.debug('statusCode-->'+statusCode);

        if(statusCode == 200 || statusCode == 201)
        {            
            if(endpoint.contains('/upsertAccount')) 
            {
                System.debug ('inside upsertAccount>>>>');
                res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('Test Response');
                res.setStatusCode(200);
                res.setStatus('OK');
            }
            else if(endpoint.contains('/plans/')) 
            {
                System.debug ('inside plans>>>>');
                res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"response": {"id": "662064b6c8ae7c0ad66da7","planId": 60000098,"planName": "AOS Adv Proposal 23/04","planStatus": {"statusId": "INPROGRESS","statusName": "In Progress"}}}');
                res.setStatusCode(200);
                res.setStatus('OK');
            }
            else if(endpoint.contains('/upsertPlan'))
            {
                System.debug ('inside upsertPlan>>>>');
                res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"response": {"id": "662064b6c8ae7c0ad66da7","planId": 60000098,"planName": "AOS Adv Proposal 23/04","planStatus": {"statusId": "INPROGRESS","statusName": "In Progress"}}}');
                res.setStatusCode(200);
                res.setStatus('OK');
            }            
            else
            {                
                res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"token": "abc12345fgh"}');
                res.setStatusCode(200);
                res.setStatus('OK');
            }
            
        }
        else{
            if(endpoint.contains('/upsertAccount')) 
            {
                res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"httpStatusCode":"400","errorMessage":"Validation failure","internalErrorMessage":"MDM id cannot be null"}');
                res.setStatusCode(400);
                res.setStatus('OK');
            }
            else if(endpoint.contains('/plans/')) 
            {
                res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"httpStatusCode": "400","errorMsg": ["Sorry, you have no permission to Create Plans. Please contact your administrator for permission to Create Plans"],"exception": "com.operative.planner.exception.PermissionDeniedException"}');
                res.setStatusCode(400);
                res.setStatus('OK');
            }
        }
        System.debug('Mock Response--->'+res);
        return res;
    }
}