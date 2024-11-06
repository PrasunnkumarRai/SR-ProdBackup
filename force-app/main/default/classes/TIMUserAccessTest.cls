@isTest
public with sharing class TIMUserAccessTest {
	
    @IsTest(seeAlldata = false)
    static void doGetMethodPositivePathTest() {
        
        String str = TIMUserAccess.doGet(); 

        System.assert(str != null);
    }
    
    @IsTest(seeAlldata = false)
    static void doPostMethodPositivePathTest() {
    	
    	RestRequest req = new RestRequest();
	    RestResponse res = new RestResponse();
		
		req.requestURI = '/services/apexrest/TIMUserAccess?TIMSystem=Dallas';
		req.httpMethod = 'POST';
		req.requestBody=Blob.valueOf('{ "UserList" : { "User" : [ { "UID" : "1", "UN" : "melanie.vaughan@charter.com", "UP" : "us3th3F0RCE!"}, { "UID" : 9, "UN" : "Kgarner", "UP" : "us3th3F0RCE!" }, { "UID" : 22, "UN" : "Ruresti", "UP" : "us3th3F0RCE!" }    ] } }');
		RestContext.request = req;
		req.addParameter('TIMSystem', 'Dallas');
		RestContext.response= res;
        
        String str = TIMUserAccess.doPost();

        System.assert(str != null);
    }
    
    @IsTest(seeAlldata = false)
    static void doPostMethodNegativePathTest() {
    	
    	RestRequest req = new RestRequest();
	    RestResponse res = new RestResponse();
		
		req.requestURI = '/services/apexrest/TIMUserAccess?TIMSystem=Dallas';
		req.httpMethod = 'POST';
		req.requestBody=Blob.valueOf('{ "UserList" : { "User" : [ { "UID" : "A", "UN" : "", "UP" : "us3th3F0RCE!" }, { "UID" : 9, "UN" : "Kgarner", "UP" : "us3th3F0RCE!" }, { "UID" : 22, "UN" : "Ruresti", "UP" : "us3th3F0RCE!" }    ] } }');
		RestContext.request = req;
		req.addParameter('TIMSystem', 'Dallas');
		RestContext.response= res;
        
        String str = TIMUserAccess.doPost();

        System.assert(str != null);
    }
}