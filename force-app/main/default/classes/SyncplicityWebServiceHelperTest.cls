@isTest
public class SyncplicityWebServiceHelperTest {
	public static String endPoint;
	public static String token;
	public static String rootFolderSyncPointId;
    
	public static void prepareTestData() {
		List<SyncplicityIntegration__c> SyncpIntCustSett = new List<SyncplicityIntegration__c> ();
		SyncpIntCustSett.add(new SyncplicityIntegration__c(name = 'Syncplicity',
		                                                   Endpoint__c = 'https://api.syncplicity.com',
		                                                   Password__c = 'cd18cf8f-117f-4f66-acde-d6f1b3291566',
		                                                   SyncAppToken__c = 'FBLti9Bu2UEv8M1JBeJdVE2r55sEs0brphBlOrd9Xt2c32dVxDxZQvKpRbYu32Jq',
		                                                   UserName__c = 'c1d198e2-b351-4910-8a84-d84dfaee688a',
		                                                   APIBatchsize__c = 100,
		                                                   RootFolderSyncpointId__c = '11081799'));

		insert SyncpIntCustSett;

		Map<String, SyncplicityIntegration__c> custSettMap = new Map<String, SyncplicityIntegration__c> ();
		custSettMap = SyncplicityIntegration__c.getAll();
		endPoint = custSettMap.get('Syncplicity').Endpoint__c;
		rootFolderSyncPointId = custSettMap.get('Syncplicity').RootFolderSyncpointId__c;
	}
    
	public static testMethod void authentication() {
		prepareTestData();
		SyncplicityWebServiceMock.name = 'Authentication';
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new SyncplicityWebServiceMock());
		SyncplicityWebServiceHelper obj = new SyncplicityWebServiceHelper();
		AuthSyncplicityJSONParse jsonAuth = AuthSyncplicityJSONParse.parse(obj.AuthenticateRestService());
		token = jsonAuth.access_token;
		Test.stopTest();
	}

	public static testMethod void moveFile() {
		SyncplicityWebServiceMock.name = 'MoveFiles';
		String body = '[{"SyncpointId": 11081799,"FileId": 1008010565297001,"Filename": "New Text Document (2).txt","Status": 6,"FolderId": 382811655,}]';
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new SyncplicityWebServiceMock());
		SyncplicityWebServiceHelper obj = new SyncplicityWebServiceHelper();
		obj.MoveFiles(rootFolderSyncPointId, body, token);
		Test.stopTest();
	}

	public static testMethod void moveFolders() {
		SyncplicityWebServiceMock.name = 'MoveFolders';
		String body = '[{"SyncpointId": 11081799,"FolderId": 384103255,"Name": "1st Qtr 2018","Status": 6,"ParentFolderId": 382951565}]';
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new SyncplicityWebServiceMock());
		SyncplicityWebServiceHelper obj = new SyncplicityWebServiceHelper();
		obj.MoveFolders(rootFolderSyncPointId, body, token);
		Test.stopTest();
	}

	public static testMethod void getFolderContent() {
		SyncplicityWebServiceMock.name = 'GetFolderContent';
		String body = '[{"SyncpointId": 11081799,"FolderId": 384103255,"Name": "1st Qtr 2018","Status": 6,"ParentFolderId": 382951565}]';
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new SyncplicityWebServiceMock());
		SyncplicityWebServiceHelper obj = new SyncplicityWebServiceHelper();
		obj.GetFolderContent(rootFolderSyncPointId, body, token);
		Test.stopTest();
	}
}