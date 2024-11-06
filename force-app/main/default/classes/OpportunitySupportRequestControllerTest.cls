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
private class OpportunitySupportRequestControllerTest {

    @testSetup 
    private static void createTestData(){
         test.startTest();
        map<String, Id> mapRecordTypeId = new map<String, Id>();
        for( RecordType accRT : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND ( DeveloperName='Agency_Account' OR DeveloperName='Advertiser_Account' OR DeveloperName='Rep_Firm')]){
            mapRecordTypeId.put( accRT.DeveloperName, accRT.Id );
        }
        
        User userObj = TestUtil.prepareUser();
        userObj.Email = 'testUser@charter.com';
        userObj.Approving_Manager__c = UserInfo.getUserId();
        userObj.Sales_Office__c = 'Charlotte - DOS';
        userObj.Region__c = 'Florida';
        userObj.Division__c = 'South';
        insert userObj;
        
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
                
            Account RepFirmAccount = new Account(Name='Test rep firm Account', RecordTypeId=mapRecordTypeId.get('Rep_Firm'), BillingStreet = '235 High St',
                BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
                BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
                ShippingPostalCode = '26505', ShippingCountry = 'USA' );
            
            insert new list<Account>{ AdsAccount, AgencyAccount ,RepFirmAccount};
            
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
            testOppty.Rep_Firm__c = RepFirmAccount.Id;
            insert testOppty;
            OpportunityTeamMember otm = new OpportunityTeamMember (OpportunityId = testOppty.id,UserId = userinfo.getuserid(),TeamMemberRole = 'Coordinator');
            insert otm;
            Support_Request__c sr = TestDataHelper.createSupportrequest('Test SR', testOppty.Id, null, null, null, null);
            insert sr;
            System.assertEquals(testOppty.Id, sr.Opportunity__c);
            
            Proposal__c prop = TestDataHelper.createProposal('OppTest',testOppty.Id,'76877', true);
            insert prop;
            Proposal_Zone__c propZone =TestDataHelper.createProposalZone('OppTestPropZone',prop.id);
            insert propZone;
            
            Proposal_Zone_Monthly_Value__c propZoneMonthlyValue = new Proposal_Zone_Monthly_Value__c();
            propZoneMonthlyValue.Proposal_Zone__c = propZone.Id;
            propZoneMonthlyValue.Schedule_Type__c = 'Digital';
            propZoneMonthlyValue.Gross_Amount__c = 23;
            insert propZoneMonthlyValue;
            test.stopTest();
        }
    }
    
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Test.startTest();
        Opportunity oppty = [SELECT Id FROM Opportunity limit 1];
        
        Support_Request__c sr = [SELECT Id, Opportunity__c FROM Support_Request__c  limit 1];
        OpportunitySupportRequestController.createSupportRequest( oppty.Id, 'production' );
        //OpportunitySupportRequestController.createSupportRequest( oppty.Id, 'researchRequest');
        //OpportunitySupportRequestController.createSupportRequest( oppty.Id, 'digitalInventoryRequest' );
        //OpportunitySupportRequestController.createSupportRequest( oppty.Id, 'planningRequest');
      //  OpportunitySupportRequestController.createSupportRequest( oppty.Id, 'pl');
        OpportunitySupportRequestController.editSupportRequest( sr.Id );
        System.assertEquals(oppty.Id, sr.Opportunity__c);
        Test.stopTest();
    }
    
    static testMethod void myUnitTest1() {
        // TO DO: implement unit test
        Test.startTest();
        Opportunity oppty = [SELECT Id FROM Opportunity limit 1];
        
       // Support_Request__c sr = [SELECT Id, Opportunity__c FROM Support_Request__c  limit 1];
        OpportunitySupportRequestController.createSupportRequest( oppty.Id, 'researchRequest');
        //OpportunitySupportRequestController.createSupportRequest( oppty.Id, 'digitalInventoryRequest' );
        //System.assertEquals(oppty.Id, sr.Opportunity__c);
        Test.stopTest();
    }
    
    static testMethod void myUnitTest2() {
        // TO DO: implement unit test
        Test.startTest();
        Opportunity oppty = [SELECT Id FROM Opportunity limit 1];
        
        Support_Request__c sr = [SELECT Id, Opportunity__c FROM Support_Request__c  limit 1];
        OpportunitySupportRequestController.createSupportRequest( oppty.Id, 'planningRequest');
        //OpportunitySupportRequestController.createSupportRequest( oppty.Id, 'pl');
        OpportunitySupportRequestController.editSupportRequest( sr.Id );
        System.assertEquals(oppty.Id, sr.Opportunity__c);
        Test.stopTest();
    }
    //START: SRSF-1897
    static testMethod void TestAudienceRequest() {    
        Test.startTest();    
        Opportunity oppty = [SELECT Id FROM Opportunity LIMIT 1];        
        OpportunitySupportRequestController.createSupportRequest( oppty.Id, 'audienceRequest');
       // Support_Request__c sr = [SELECT Id, Opportunity__c FROM Support_Request__c  LIMIT 1];           
       // System.assertEquals(oppty.Id, sr.Opportunity__c);  
       Test.stopTest();      
    }
    //END: SRSF-1897
}