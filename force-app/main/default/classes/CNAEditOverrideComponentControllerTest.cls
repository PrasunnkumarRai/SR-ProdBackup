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
private class CNAEditOverrideComponentControllerTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        Account AdsAccount = new Account(Name='Test Ads Account', BillingStreet = '235 High St',
		        BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
		        BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
		        ShippingPostalCode = '26505', ShippingCountry = 'USA', Legal_Entity_Name__c='Test Legal Name');
	    insert adsAccount;
	    
        CNA__c cnaObj = TestUtil.getCNA( adsAccount.Id );
        insert cnaObj;
	    
        CNAEditOverrideComponentController.checkAccountTeamMember( cnaObj.Id );
        
        Cache.Session.put( 'local.CNAPartition.'+cnaObj.Id, 2099287993);
        System.debug('-----> test call');
        CNAEditOverrideComponentController.checkAccountTeamMember( cnaObj.Id );
        CNAEditOverrideComponentController.checkForOpportunityTeamMember( cnaObj, UserInfo.getUserId() );
        System.assertEquals(AdsAccount.Id, cnaObj.Account__c);
    }
}