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
private class cloneSupportRequestControllerTest {
    
    // Create Test Data
    @testSetup 
    private static void createTestData(){
        map<String, Id> mapRecordTypeId = new map<String, Id>();
        for( RecordType accRT : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND ( DeveloperName='Agency_Account' OR DeveloperName='Advertiser_Account' )]){
            mapRecordTypeId.put( accRT.DeveloperName, accRT.Id );
        }
        
      /*  User userObj = TestUtil.prepareUser();
        userObj.Approving_Manager__c = UserInfo.getUserId();
        insert userObj;*/
        
        //System.runAs( userObj ){
            Account AdsAccount = new Account(Name='Test Ads Accounst', RecordTypeId=mapRecordTypeId.get('Advertiser_Account'), BillingStreet = '235 High Sts',
                BillingCity = 'Morgantown', BillingState = 'WVs', BillingPostalCode = '265051',
                BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
                ShippingPostalCode = '26505', ShippingCountry = 'USA', Legal_Entity_Name__c='Test Legal Name' );
                
            Account AgencyAccount = new Account(Name='Tests Agency Account', RecordTypeId=mapRecordTypeId.get('Agency_Account'), BillingStreet = '235 High Sts',
                BillingCity = 'Morgantowns', BillingState = 'WV', BillingPostalCode = '26505',
                BillingCountry = 'USA', ShippingStreet = '235 High Sts', ShippingCity = 'Morgantowns', ShippingState = 'WV',
                ShippingPostalCode = '26505s', ShippingCountry = 'USA' );
            
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
            
            OpportunityTeamMember oppTeam = new OpportunityTeamMember();
            oppTeam.Userid = Userinfo.getuserid();
            oppTeam.OpportunityId = testOppty.Id;
            insert oppTeam;
            
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
            
            RecordType srRT = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Support_Request__c' AND DeveloperName='Production' limit 1];
            Support_Request__c srRecord = new Support_Request__c();
            //srRecord.Proposal__c = testProposal.Id;
            srRecord.RecordTypeId = srRT.Id;
            srRecord.Status__c = 'Completed by Kernel';
            srRecord.Name = 'Production Request Test';
            srRecord.Advertiser__c = AdsAccount.Id;
            srRecord.Agency__c = AgencyAccount.id;
            srRecord.Opportunity__c = testOppty.Id;
            srRecord.Due_Date__c = System.Today();
            srRecord.Type_of_Request__c = 'Post Sale Production Request';
            srRecord.Production_Budget__c = 5000.00;
            insert srRecord;
            
        //}    
    }
    
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Test.StartTest();
            Support_Request__c srRecord = [SELECT Id FROM Support_Request__c limit 1];
            System.assert( srRecord != null );
            
            
            
            cloneSupportRequestController.cloneThisSupportRequest( srRecord.Id );
        Test.StopTest();
    }
}