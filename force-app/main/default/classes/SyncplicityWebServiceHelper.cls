/*
  ###########################################################################
  # File..................: SyncplicityWebServiceHelper.cls
  # Version...............: 1
  # Created by............: Matthew Kidman  
  # Created Date..........: 09-March-2020
  # Description...........: This class contains helper methods for managing Syncplicity Call Outs.
  # TAO Ref#..............: NA
  # Change Log:               
  #
  #
  ############################################################################*/
public class SyncplicityWebServiceHelper {
	/*custom settings map variable*/
	Map<String, SyncplicityIntegration__c> custSettMap = new Map<String, SyncplicityIntegration__c> ();
	/*user password for Syncplicity authentication from  custom settings map variable*/
	private String passwd;
	/*user name for Syncplicity authentication from custom settings map variable*/
	private String userName;
	/*SyncplicityServer for Syncplicity authentication from custom settings map variable*/
	private String SyncplicityServer;
	/*To store the App token provided by Syncp Team*/
	private String SyncplicityAppToken;

	public SyncplicityWebServiceHelper() {
		System.debug('@@User ' + UserInfo.getUserId());
		try {
			custSettMap = SyncplicityIntegration__c.getAll();
			System.debug('@@custSettMap ' + custSettMap);
			userName = custSettMap.get('Syncplicity').UserName__c;
			passwd = custSettMap.get('Syncplicity').Password__c;
			SyncplicityAppToken = custSettMap.get('Syncplicity').SyncAppToken__c;
			if (passwd == null) passwd = '';
			SyncplicityServer = custSettMap.get('Syncplicity').Endpoint__c;
			System.debug('@@SyncplicityServer ' + SyncplicityServer);
		}
		catch(Exception ex) {
			System.debug('@@Exception ' + ex);
		}
	}

	/*
	 * API to authenticate and generate the token for the Syncplicity API calls.
	 */
	public String AuthenticateRestService() {
		Blob headerValue = Blob.valueOf(userName + ':' + passwd);
		String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
		//Instantiate a new http object
		Http h = new Http();
		//Instantiate a new HTTP request, specify the method as well as the endpoint
		HttpRequest req = new HttpRequest();
		//HttpResponse res ;
		HttpResponse res = new HttpResponse();
		req.setEndpoint(SyncplicityServer + '/oauth/token');
		req.setMethod('POST');
		req.setHeader('Accept', 'application/json');
		req.setHeader('Content-type', 'application/x-www-form-urlencoded');
		req.setHeader('Sync-App-Token', SyncplicityAppToken);
		req.setHeader('Authorization', authorizationHeader);

		if (String.isNotBlank(Label.SetTimeOut))
		req.setTimeout(Integer.valueOf(Label.SetTimeOut));

		req.setBody('grant_type=client_credentials');

		try
		{ res = h.send(req);
			System.debug('@@response ' + res);
		}
		catch(System.CalloutException e)
		{
			System.debug('Callout error: ' + e);
			System.debug('@@response ' + res);
		}
		System.debug('res.getStatus() '+res.getStatus());
		if (res != NULL && res.getStatus().equalsIgnoreCase('OK') && res.getStatusCode() == 200)
		System.debug('@@res body ' + res.getBody());
		else { Exception ex; System.debug('@@res status ' + res.getStatus() + res); }
		return res.getBody();
	}

	/*
	  API Post Stub
	  Parameters : 
	  Endpoint - Endpoint of the rest API call.
	  Body - to be passed to the API call.
	 */
	public static HttpResponse RestServicePostStub(String endpoint, String body, String Token) {
		System.debug('@@endpoint ' + endpoint);
		System.debug('@@body ' + body);
		//Instantiate a new http object
		Http h = new Http();
		//Instantiate a new HTTP request, specify the method as well as the endpoint
		HttpRequest req = new HttpRequest();
		//HttpResponse res ;
		HttpResponse res = new HttpResponse();
		req.setEndpoint(endpoint);
		req.setMethod('POST');
		req.setHeader('Accept', 'application/json');
		req.setHeader('Content-type', 'application/json; charset=UTF-8');
		req.setHeader('Syncplicity-ErrorOnExisting', 'true');
		req.setHeader('Authorization', 'Bearer ' + Token);

		if (String.isNotBlank(Label.SetTimeOut))
		req.setTimeout(Integer.valueOf(Label.SetTimeOut));

		req.setBody(body);
		System.debug(body);
		try
		{ res = h.send(req);
			System.debug('@@response ' + res);
		}
		catch(System.CalloutException e)
		{	
            system.debug('e.getStackTraceString(): ' + e.getStackTraceString());
			System.debug('Callout error: ' + e);
			System.debug('@@response ' + res);
		}

		if (res != NULL && res.getStatus().equalsIgnoreCase('OK') && res.getStatusCode() == 200)
		System.debug('@@res body ' + res.getBody());
		else { Exception ex; System.debug('@@res status ' + res.getStatus() + res); }
		return res;
	}

	/*
	  API Post Stub
	  Parameters : 
	  Endpoint - Endpoint of the rest API call.
	 
	 */
	public static HttpResponse RestServiceGetStub(String endpoint, String Token) {
		System.debug('RestServiceGetStub endpoint: ' + endpoint);
		//Instantiate a new http object
		Http h = new Http();
		//Instantiate a new HTTP request, specify the method as well as the endpoint
		HttpRequest req = new HttpRequest();
		//HttpResponse res ;
		HttpResponse res = new HttpResponse();
		req.setEndpoint(endpoint);
		req.setMethod('GET');
		req.setHeader('Accept', 'application/json');
		req.setHeader('Authorization', 'Bearer ' + Token);
		System.debug('HTTPRequest: ' + req);
		System.debug('RestServiceGetStub Token: ' + Token);
		try {
			System.debug('Callout req: ' + req);
			res = h.send(req);
			System.debug('Callout response: ' + res);
		}
		catch(System.CalloutException e)
		{
			System.debug('Callout error: ' + e);
			System.debug('### res ::: ' + res);
		}
		//Log4SF.logMessage('BoomiWebServiceHelper', endpoint, System.label.BoomiAPIError,e, UserInfo.getUserId(),'NA',res.getBody());
		if (res.getStatus().equalsIgnoreCase('OK') && res.getStatusCode() == 200)
		System.debug(res.getBody());
		//else
		//Exception ex; System.debug('@@res status ' + res.getStatus() + res);

		return res;
	}

	/*
	  To get the contents of the folder. To be sued to get Source Folder Content.
	 */
	public String GetFolderContent(string syncpointId, string folderId, String token) {
		String endPoint = SyncplicityServer + '/sync/folder.svc/' + syncpointId + '/folder/' + folderId + '?include=active';
		HttpResponse folderContent = RestServiceGetStub(endPoint, token);
		System.debug('folderContent@@: ' + folderContent);
		return folderContent.getBody();
	}

	/*
	  For SyncpointId always use the RootFolder SyncpointId
	  Request Body Format:
	  [
	  {
	  "SyncpointId": "string",
	  "FolderId": "string",
	  "Name": "string",
	  "ParentFolderId": "string",
	  "VirtualPath": "string",
	  "Status": 0,
	  "Folders": [
	  {}
	  ]
	  }
	  ]
	 */
	public String MoveFolders(string syncpointId, string bodyFolderJsonArray, string token) {
		String endPoint = SyncplicityServer + '/sync/folders.svc/' + syncpointId + '/folders';
        system.debug('MoveFoldersendPoint: '+endPoint);
        system.debug('MoveFolderbodyFolderJsonArray: '+bodyFolderJsonArray);
        system.debug('MoveFoldertoken: '+token);
		HttpResponse reponse = RestServicePostStub(endPoint, bodyFolderJsonArray, token);
		return reponse.getBody();
	}

	/*
	  For SyncpointId always use the RootFolder SyncpointId
	  Request Body Format:
	  [
	  {
	  "SyncpointId": "string",
	  "Filename": "string",
	  "Length": "string",
	  "CreationTimeUtc": "2020-03-11T10:12:34.333Z",
	  "LastWriteTimeUtc": "2020-03-11T10:12:34.333Z",
	  "Status": 0,
	  "LatestVersionId": "string",
	  "ThumbnailUrl": "string",
	  "Hash": "string",
	  "VirtualPath": "string"
	  }
	  ]
	 */
	public String MoveFiles(string syncpointId, string bodyFilesJsonArray, string token) {
		String endPoint = SyncplicityServer + '/sync/files.svc/' + syncpointId + '/files';
        system.debug('MoveFilesendPoint: '+endPoint);
		HttpResponse reponse = RestServicePostStub(endPoint, bodyFilesJsonArray, token);
		return reponse.getBody();
	}
}