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
private class CloneDigitalCampaignControllerTest {
 	
 	// Create Test Data
 	@testSetup 
	private static void createTestData(){
		map<String, Id> mapRecordTypeId = new map<String, Id>();
        for( RecordType accRT : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND ( DeveloperName='Agency_Account' OR DeveloperName='Advertiser_Account' )]){
        	mapRecordTypeId.put( accRT.DeveloperName, accRT.Id );
        }
        
        User userObj = TestUtil.prepareUser();
        userObj.Approving_Manager__c = UserInfo.getUserId();
        userObj.Division__c = 'Central';
        insert userObj;
        
        System.runAs( userObj ){
	        Account AdsAccount = new Account(Name='Test Ads Account', RecordTypeId=mapRecordTypeId.get('Advertiser_Account'), BillingStreet = '235 High St',
	            BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
	            BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
	            ShippingPostalCode = '26505', ShippingCountry = 'USA', Legal_Entity_Name__c='Test Legal Name' );
	            
	        Account AgencyAccount = new Account(Name='Test Agency Account', RecordTypeId=mapRecordTypeId.get('Agency_Account'), BillingStreet = '235 High St',
	            BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
	            BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
	            ShippingPostalCode = '26505', ShippingCountry = 'USA' );
	        
	        insert new list<Account>{ AdsAccount, AgencyAccount };
	        
	        RecordType opptyRT = [SELECT Id FROM RecordType WHERE SObjectType='Opportunity' AND DeveloperName='Opportunity' limit 1];
	        Opportunity testOppty = new Opportunity();
	        testOppty.Name = 'Test Opportunity';
	        testOppty.RecordTypeId = opptyRT.Id;
	        testOppty.StageName='Proposal Presentation';
	        testOppty.CloseDate = System.Today().addDays( 30 );
	        testOppty.AccountId = AdsAccount.id;
	        testOppty.Agency_Account__c = AgencyAccount.Id;
	        insert testOppty;
	        
	        RecordType proposalRT = [SELECT Id FROM RecordType WHERE SobjectType='Proposal__c' AND DeveloperName='Linear' limit 1];
	        Proposal__c testProposal = new Proposal__c();
	        testProposal.Name = 'TestProposal';
	        testProposal.TIM_System__c = 'Dallas';
	        testProposal.Start_Date__c = SYstem.Today();
	        testProposal.End_Date__c = System.Today().addDays( 7 );
	        testProposal.Opportunity__c = testOppty.Id;
	        testProposal.Advertiser__c = AdsAccount.Id; 
	        testProposal.RecordTypeId = proposalRT.Id;
	        insert testProposal;
	        
	        RecordType dcRT = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Digital_Campaign__c' AND DeveloperName='New_Ads_Everywhere' limit 1];
	        Digital_Campaign__c dcampaign = new Digital_Campaign__c();
	        dcampaign.Proposal__c = testProposal.Id;
	        dcampaign.RecordTypeId = dcRT.Id;
	        dcampaign.Status__c = '01 Draft Campaign';
	    	dcampaign.Campaign_Name__c = testProposal.Name+'-Ads Everywhere';
	        dcampaign.Advertiser__c = AdsAccount.Id;
	        dcampaign.Agency__c = AgencyAccount.id;
	        dcampaign.Opportunity__c = testOppty.Id;
            dcampaign.State__c = 'United States';
            dcampaign.DMAs__c = 'None';
            dcampaign.Spectrum_Reach_Zones__c = 'None';
	        insert dcampaign;
	        
	       /* Digital_Creative__c dCreative = new Digital_Creative__c();
	        dCreative.Creative_Name__c = 'Test dCreative';
	        dCreative.Digital_Campaign__c = dcampaign.Id;
            dCreative.Creative_Type__c = 'Digital';
	        insert dCreative;*/
        }    
    }
 	
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
     	Test.StartTest();
     		Digital_Campaign__c dcampaign = [SELECT Id FROM Digital_Campaign__c limit 1];
        	System.debug('dcampaignID' + dcampaign.Id);
        	System.assert( dcampaign != null );
			CloneDigitalCampaignController.cloneThisDigitalCampaign( dcampaign.Id );
     	Test.StopTest();
    }
    
    static testMethod void getDaypartingDataTest() {
        List<Digital_Campaign__c> dcList = [SELECT Day_of_Week__c FROM Digital_Campaign__c ];
        CloneDigitalCampaignController.getDayPartingData('Id');
    }
}