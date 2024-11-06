@isTest
private class CloneDCForMakegoodController_Test {
 	
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
	        
            list<Digital_Campaign__c> lstDC = new list<Digital_Campaign__c>();
	        RecordType dcRT = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Digital_Campaign__c' AND DeveloperName='New_Ads_Everywhere' limit 1];
	        Digital_Campaign__c dcampaign = new Digital_Campaign__c();
	        dcampaign.Proposal__c = testProposal.Id;
	        dcampaign.RecordTypeId = dcRT.Id;
	        dcampaign.Status__c = '01 Draft Campaign';
	    	dcampaign.Campaign_Name__c = testProposal.Name+'-Ads Everywhere';
	        dcampaign.Advertiser__c = AdsAccount.Id;
	        dcampaign.Agency__c = AgencyAccount.id;
	        dcampaign.Opportunity__c = testOppty.Id;
            lstDC.add(dcampaign);
	        //insert dcampaign;
            RecordType dcMGRT = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Digital_Campaign__c' AND Name='Makegood - Inventory Request - Addressable Display' limit 1];
	        Digital_Campaign__c dcampaignMG = new Digital_Campaign__c();
	        dcampaignMG.Proposal__c = testProposal.Id;
	        dcampaignMG.RecordTypeId = dcMGRT.Id;
	        dcampaignMG.Status__c = 'Plan Approved';
	    	dcampaignMG.Campaign_Name__c = testProposal.Name+'-Ads Everywhere';
	        dcampaignMG.Advertiser__c = AdsAccount.Id;
	        dcampaignMG.Agency__c = AgencyAccount.id;
	        dcampaignMG.Opportunity__c = testOppty.Id;
            lstDC.add(dcampaignMG);
            insert lstDC;
        }    
    }
 	
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
     	Test.StartTest();
        
        	DC_Makegood_Clone_Matrix__mdt obj = new DC_Makegood_Clone_Matrix__mdt();
        	obj.DeveloperName  = 'New_Ads_Everywhere';
        	obj.From_DC__c = 'New Ads Everywhere';
        	obj.Makegood_DC__c = 'Makegood - Inventory Request - New Ads Everywhere';
     		Digital_Campaign__c dcampaign = [SELECT Id FROM Digital_Campaign__c limit 1];
        	System.assert( dcampaign != null );
        	CloneDCForMakegoodController.cloneThisDigitalCampaign( dcampaign.Id );
     	Test.StopTest();
    }
}