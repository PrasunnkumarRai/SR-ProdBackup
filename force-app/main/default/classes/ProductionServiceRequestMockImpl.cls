@isTest
global class ProductionServiceRequestMockImpl implements HttpCalloutMock {

    private String json = '{"example": {"id":2, "name":"Test"}}';
    Boolean isMockResponseSuccessful;
    Integer statusCode;

    global ProductionServiceRequestMockImpl(){}

    global ProductionServiceRequestMockImpl(Boolean isMockResponseSuccessful, Integer statusCode) {
      this.isMockResponseSuccessful  = isMockResponseSuccessful;
      this.statusCode = statusCode;
    }

    global HTTPResponse respond(HTTPRequest request) {
      HttpResponse response = new HttpResponse();
      System.debug('this.isMockResponseSuccessful--->'+this.isMockResponseSuccessful);
      if (this.isMockResponseSuccessful) { 
          response.setHeader('Content-Type', 'application/json');
          response.setBody(json);
          response.setStatusCode(this.statusCode);
          return response;
      }
      else {
          CalloutException e = (CalloutException)CalloutException.class.newInstance();
          e.setMessage('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
          throw e; 
      }
    }
}