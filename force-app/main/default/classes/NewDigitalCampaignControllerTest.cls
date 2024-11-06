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
private class NewDigitalCampaignControllerTest {
    
    static testMethod void unitTest(){
        
        map<String, Id> mapRecordTypeId = new map<String, Id>();
        for( RecordType accRT : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND ( DeveloperName='Agency_Account' OR DeveloperName='Advertiser_Account' )]){
            mapRecordTypeId.put( accRT.DeveloperName, accRT.Id );
        }
        
        User userObj = TestUtil.prepareUser();
        userObj.Alias = 'Test_1';
        userObj.Email = 'test_1.ms1@charter.com';
        userObj.UserName='test_1@mands.com';
        userObj.Approving_Manager__c = UserInfo.getUserId();
        userObj.Division__c = 'Central';
        insert userObj;
        User salesUser = TestUtil.createSalesUser();
        
        System.runAs( userObj ){
            
            // Create Test Accounts
            Account AdsAccount = new Account(Name='Test Ads Account', RecordTypeId=mapRecordTypeId.get('Advertiser_Account'), BillingStreet = '235 High St',
                BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
                BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
                ShippingPostalCode = '26505', ShippingCountry = 'USA', Legal_Entity_Name__c='Test Legal Name' );
                
            Account AgencyAccount = new Account(Name='Test Agency Account', RecordTypeId=mapRecordTypeId.get('Agency_Account'), BillingStreet = '235 High St',
                BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
                BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
                ShippingPostalCode = '26505', ShippingCountry = 'USA' );
            
            insert new list<Account>{ AdsAccount, AgencyAccount };
            
            // Create Test Opportunity
            RecordType opptyRT = [SELECT Id FROM RecordType WHERE SObjectType='Opportunity' AND DeveloperName='Opportunity' limit 1];
            Opportunity testOppty = new Opportunity();
            testOppty.Name = 'Test Opportunity';
            testOppty.RecordTypeId = opptyRT.Id;
            testOppty.StageName='Proposal Presentation';
            testOppty.CloseDate = System.Today().addDays( 30 );
            testOppty.AccountId = AdsAccount.id;
            testOppty.Agency_Account__c = AgencyAccount.Id;
            insert testOppty;
            
            // Create Test Proposal
            RecordType proposalRT = [SELECT Id FROM RecordType WHERE SobjectType='Proposal__c' AND DeveloperName='Opportunity_Budget' limit 1];
            Proposal__c testProposal = new Proposal__c();
            testProposal.Name = 'Test Proposal';
            testProposal.TIM_System__c = 'Dallas';
            testProposal.Start_Date__c = SYstem.Today();
            testProposal.End_Date__c = System.Today().addDays( 7 );
            testProposal.Opportunity__c = testOppty.Id;
            testProposal.Advertiser__c = AdsAccount.Id; 
            testProposal.RecordTypeId = proposalRT.Id;
            insert testProposal;
        }
        
        map<String, Id> mapDCRecordType = new map<String, Id>();
        for( RecordType dcRT : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Digital_Campaign__c']){
            mapDCRecordType.put( dcRT.DeveloperName, dcRT.Id );
        }
        
        Test.startTest();
            
            Proposal__c testProposal = [SELECT Id FROM Proposal__c WHERE Name='Test Proposal' limit 1];
            System.assert( testProposal != null );
            
            NewDigitalCampaignController.ResponseWrapper respWrapper = NewDigitalCampaignController.getDigitalCampaignRecordTypes( testProposal.Id );
            
            Account AgencyAccount = [SELECT Id, BillingStreet FROM Account WHERE Name='Test Agency Account' limit 1];
            Account AdsAccount = [SELECT Id, Legal_Entity_Name__c FROM Account WHERE Name='Test Ads Account' limit 1];
            
            
            map<String, object> adsdataMap = NewDigitalCampaignController.getProposalRecord( testProposal.Id, mapDCRecordType.get('Ads_Everywhere') );
          //  System.assertEquals( adsdataMap.get('CoOp__c'), true);
            
            map<String, object> contentdataMap = NewDigitalCampaignController.getProposalRecord( testProposal.Id, mapDCRecordType.get('Content') );
            map<String, object> displaydataMap = NewDigitalCampaignController.getProposalRecord( testProposal.Id, mapDCRecordType.get('Display') );
            map<String, object> SearchdataMap = NewDigitalCampaignController.getProposalRecord( testProposal.Id, mapDCRecordType.get('Search') );
            
            
            System.runAs( salesUser ){
            	respWrapper = NewDigitalCampaignController.getDigitalCampaignRecordTypes( testProposal.Id );
            }
            
        Test.stopTest();
    }
    
    
}