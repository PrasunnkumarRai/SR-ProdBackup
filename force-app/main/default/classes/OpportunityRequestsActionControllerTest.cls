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
private class OpportunityRequestsActionControllerTest {
    
    @testSetup 
    private static void createTestData(){
        map<String, Id> mapRecordTypeId = new map<String, Id>();
        for( RecordType accRT : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND ( DeveloperName='Agency_Account' OR DeveloperName='Advertiser_Account' )]){
            mapRecordTypeId.put( accRT.DeveloperName, accRT.Id );
        }
         
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
            
            AdsAccount.Agency__c=AgencyAccount.Id;
        update AdsAccount;
        
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
        System.assertEquals('Test Opportunity', testOppty.Name);
        OpportunityTeamMember oppTeam = new OpportunityTeamMember();
        oppTeam.Userid = Userinfo.getuserid();
        oppTeam.OpportunityId = testOppty.Id;
        insert oppTeam;
        
    }
    
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Test.StartTest();
        Opportunity oppty = [SELECT Id, Name, OwnerId FROM Opportunity limit 1];
        OpportunityRequestsActionController.createCNARequest( oppty.Id );
        System.debug(oppty.OwnerId+' == '+Userinfo.getUserId());
        System.assertEquals('Test Opportunity', oppty.Name);
        Test.StopTest();
    }
}