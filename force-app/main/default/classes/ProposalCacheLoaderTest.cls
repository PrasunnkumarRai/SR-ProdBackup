/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ProposalCacheLoaderTest {
	
	static opportunity opp;
	static Account acc;
	static string timSystem;
	static string oppID;
	static string retURL;
	static Boolean isRedirect;
		
	
    static testMethod void myUnitTest() 
    {
       	User u = TestDataHelper.getBoomiIntegrationUser();

       	System.assert(u != null);
       	
	    System.runAs(u){
	    Test.startTest();
	    ProposalCacheLoader obj = new ProposalCacheLoader();
	    obj.timSystem = 'St.Louis Local';
	    obj.checkCacheExist();
	    obj.redirect();
	    obj.backToOpp();
	    Test.stopTest();
		}
    }

    static testMethod void testRefreshAllCacheTest() 
    {
        TestDataHelper.createTIMIntegrationCustomSettings();    
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.assert(u != null);  
        insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',u.Id,'TIM','1');  
         
        BoomiWebServiceMock.name = 'BoomiDashboardController';       
        System.runAs(u)
        {
        Test.startTest();
        CacheManager.refreshAllCache();
        Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
        CacheManager.refreshCache();
        Test.stopTest();
       }
    }
}