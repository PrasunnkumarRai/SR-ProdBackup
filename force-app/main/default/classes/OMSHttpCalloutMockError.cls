@isTest
global class OMSHttpCalloutMockError implements HttpCalloutMock {

    string mappingError = '{"SalesOrderId":null,"SalesOrderUrl":null,"Message":"Mapping errors found, not submitting to O1: The Eclipse ID & Eclipse Customer Number is a required field","ExceptionMessage":null,"InventorySources":[]}';

    global HTTPResponse respond(HTTPRequest request) {

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(mappingError);
        response.setStatusCode(400);
        return response; 
    }
}