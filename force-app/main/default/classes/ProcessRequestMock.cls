@isTest
public class ProcessRequestMock implements HttpCalloutMock {
		protected Integer code;
		protected String status;
		protected String bodyAsString;
		protected Blob bodyAsBlob;
		protected Map<String, String> responseHeaders;

		public ProcessRequestMock(Integer code, String status, String body,
                                         Map<String, String> responseHeaders) {
			this.code = code;
			System.assertEquals(code, this.code);

			this.status = status;
			System.assertEquals(status, this.status);

			this.bodyAsString = body;
			System.assertEquals(body, this.bodyAsString);

			this.bodyAsBlob = null;
			System.assertEquals(null, this.bodyAsBlob);

			this.responseHeaders = responseHeaders;
			System.assertEquals(responseHeaders, this.responseHeaders);
		}

		public ProcessRequestMock(Integer code, String status, Blob body,
                                         Map<String, String> responseHeaders) {
			this.code = code;
			System.assertEquals(code, this.code);

			this.status = status;
			System.assertEquals(status, this.status);

			this.bodyAsBlob = body;
			System.assertEquals(body, this.bodyAsBlob);

			this.bodyAsString = null;
			System.assertEquals(null, this.bodyAsString);

			this.responseHeaders = responseHeaders;
			System.assertEquals(responseHeaders, this.responseHeaders);
		}

	    public HTTPResponse respond(HTTPRequest req) {
	        HttpResponse resp = new HttpResponse();
			resp.setStatusCode(code);
			resp.setStatus(status);
			
			if (bodyAsBlob != null) {
				resp.setBodyAsBlob(bodyAsBlob);
			} else {
				resp.setBody(bodyAsString);
			}

			if (responseHeaders != null) {
			     for (String key : responseHeaders.keySet()) {
				resp.setHeader(key, responseHeaders.get(key));
			     }
			}
			return resp;
	    }
}