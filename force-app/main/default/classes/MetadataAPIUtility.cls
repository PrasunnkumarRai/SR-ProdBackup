public class MetadataAPIUtility {

	//public static boolean createCustomLabel(string csname, string description, string language, string value, boolean isProtected) {
	//List<MetadataService.Metadata> allMetadataList = new List<MetadataService.Metadata> ();
	//MetadataService.MetadataPort service = createService();
	//MetadataService.CustomLabel csLabel = new MetadataService.CustomLabel();
	//csLabel.fullName = csname;
	//csLabel.language = language;
	//csLabel.protected_x = isProtected;
	//csLabel.shortDescription = description;
	//csLabel.value = value;
	//allMetadataList.add(csLabel);
	//List<MetadataService.SaveResult> results = service.createMetadata(allMetadataList);
	//for (MetadataService.SaveResult result : results) {
	//system.debug('update custom label results success=' + result.success);
	//}
	//return results[0].success;
	//}

	public static boolean updateCustomLabel(string csname, string description, string language, string value, boolean isProtected) {
		List<MetadataService.Metadata> allMetadataList = new List<MetadataService.Metadata> ();
		MetadataService.MetadataPort service = createService();
		System.debug('service: ' + service);
		MetadataService.CustomLabel csLabel = new MetadataService.CustomLabel();
		csLabel.fullName = csname;
		csLabel.language = language;
		csLabel.protected_x = isProtected;
		csLabel.shortDescription = description;
		csLabel.value = value;
		allMetadataList.add(csLabel);
		system.debug('allMetadataList:' + allMetadataList);
		List<MetadataService.SaveResult> results = service.updateMetadata(allMetadataList);
		system.debug('Result:' + results);
		if (results != null) {
			for (MetadataService.SaveResult result : results) {
				system.debug('update custom label results success=' + result.success);
			}
			system.debug('Result:' + results);
			return results[0].success;
		}
		return false;
	}

	private static MetadataService.MetadataPort createService() {
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		System.debug('SessionId: ' + getSessionId(Label.IntegrationUserName, Label.IntegrationUserNamePass));
		service.SessionHeader.sessionId = getSessionId(Label.IntegrationUserName, Label.IntegrationUserNamePass);
		return service;
	}

	public static HttpResponse authenticateByUsernamePassword(String useName, String password) {
		String uri = Url.getOrgDomainUrl().toExternalForm() + '/services/Soap/u/44.0';
		//String uri ='callout:Boomi_Integartion_User' ;
		String body =
		'<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' +
		useName +
		'</username><password>' +
		password +
		'</password></login></Body></Envelope>';
         
      //  String sessionId = UserInfo.getSessionId();
       // System.debug('Session ID: ' + sessionId);
		Http h = new Http();
		HttpRequest hRqst = new HttpRequest();
		hRqst.setEndpoint(uri);
		hRqst.setMethod('POST');
		hRqst.setHeader('SOAPAction', 'VALUE');
		hRqst.setHeader('Accept', 'text/xml');
		hRqst.setHeader('Content-type', 'text/xml');
		hRqst.setHeader('charset', 'UTF-8');
		hRqst.setBody(body);
		return h.send(hRqst);
	}

	public static string getSessionId(string username, string password) {
        System.debug(username +' ' +  password);
		HttpResponse response = authenticateByUsernamePassword(username, password);
		if (response.getStatusCode() == 200) {
			Dom.XmlNode resultElmt = response.getBodyDocument()
			.getRootElement()
			.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
			.getChildElement('loginResponse', 'urn:partner.soap.sforce.com')
			.getChildElement('result', 'urn:partner.soap.sforce.com');
			return resultElmt.getChildElement('sessionId', 'urn:partner.soap.sforce.com').getText();
		}
        System.debug(response.getBodyDocument());
		return null;
	}

	/*execute below code in execute anonymous
	  MetadataAPIUtility.createCustomLabel('SFDC_Blog_URL','My test label from metadata api','en_US','http://www.sfdcstuff.com/',false);
	  MetadataAPIUtility.updateCustomLabel('SFDC_Blog_URL','My test label from metadata api','en_US','https://www.sfdcstuff.com/search/label/Lightning',false);
	 
	 */

}