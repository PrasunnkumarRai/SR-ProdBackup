global class dnbAuthenticateController implements Schedulable {

	global void execute(SchedulableContext SC) {
		callDnBAuth();
	}

	@future(callout = true)
	global static void callDnBAuth() {
		dnbAuthModel dnbAuthData = new dnbAuthModel();
		Organization org = [Select Id, Name, IsSandbox from Organization LIMIT 1];
		String baseUrl =  (org.IsSandbox == false? Label.DnBBoomiBaseURL + 'invoke_DnBAuth/': Label.DnBBoomiSandboxBaseURL+'SandboxInvoke_DnBAuth/');
		HttpRequest httpRequest = new HttpRequest();
		httpRequest.setEndpoint(baseUrl);
		httpRequest.setMethod('GET');
		httpRequest.setHeader('Accept', '*/*');
		if (org.IsSandbox == false) {
			httpRequest.setHeader('Authorization', Label.BoomiUserDnBProcess);	
		}
		else {
			httpRequest.setHeader('Authorization', Label.BoomiUserDnBSandbox);	
		}
		httpRequest.setTimeout(120000);
		String dnbResponse = null;
		Http http = new Http();
		System.debug('httpRequest ' + httpRequest);
		HttpResponse httpResponse = http.send(httpRequest);
		System.debug('@@dnbResponse: ' + httpResponse.getBody());
		if (httpResponse.getStatusCode() == 200) {
			dnbResponse = httpResponse.getBody();
			System.debug('@@dnbResponse: ' + dnbResponse);
			dnbAuthData = dnbAuthData.parse(dnbResponse);
			if (!Test.isRunningTest()) {
				System.debug('@@UpdateCustomLabel: Update Called');
				MetadataAPIUtility.updateCustomLabel('DnBAuth', 'DnBAuth', 'en_US', dnbAuthData.access_token, false);
				System.debug('@@UpdateCustomLabel: Updated');
			}
		}
	}

	public class dnbAuthModel {
		public String access_token { get; set; }
		public String expiresIn { get; set; }

		public dnbAuthModel parse(String json) {
			return(dnbAuthModel) System.JSON.deserialize(json, dnbAuthModel.class);
		}
	}
}