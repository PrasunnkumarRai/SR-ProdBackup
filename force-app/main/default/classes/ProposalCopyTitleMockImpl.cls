@isTest
global class ProposalCopyTitleMockImpl implements HttpCalloutMock {

    private String json = '{"hasError":false,"Eclipsedata":[{"S_SZTITLE":"No_Closing_Cost_Moving_FINAL","S_ULLENGTH":"30"},{"S_SZTITLE":"No_Closing_Cost_Moving_FINAL","S_ULLENGTH":"30","ST_SZTITLE":"G1S15YLFH","ST_SZEDICREATIVE":"G1S15YLFH","ST_ULLENGTH":"15","SB_SZTITLE":"G1S15YLFH","SB_SZEDICREATIVE":"G1S15YLFH","SB_ULLENGTH":"15"}]}';
    Boolean isMockResponseSuccessful;
    Integer statusCode;
    String status;

    global ProposalCopyTitleMockImpl (){}

    global ProposalCopyTitleMockImpl (Boolean isMockResponseSuccessful, Integer statusCode, String status) {
      this.isMockResponseSuccessful  = isMockResponseSuccessful;
      this.statusCode = statusCode;
      this.status = status;
    }

    global HTTPResponse respond(HTTPRequest request) {
      HttpResponse response = new HttpResponse();
      System.debug('this.isMockResponseSuccessful--->'+this.isMockResponseSuccessful);
      if (this.isMockResponseSuccessful) { 
          response.setHeader('Content-Type', 'application/json');
          response.setBody(json);
          response.setStatusCode(this.statusCode);
          response.setStatus(this.status);
          return response;
      }
      else {
          CalloutException e = (CalloutException)CalloutException.class.newInstance();
          e.setMessage('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
          throw e; 
      }
    }
}