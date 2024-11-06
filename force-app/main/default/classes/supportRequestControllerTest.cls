@isTest
private class supportRequestControllerTest {
    @testSetup 
    private static void createTestData(){
        map<String, Id> mapRecordTypeId = new map<String, Id>();
        for( RecordType accRT : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND ( DeveloperName='Agency_Account' OR DeveloperName='Advertiser_Account' OR DeveloperName='Rep_Firm')]){
            mapRecordTypeId.put( accRT.DeveloperName, accRT.Id );
        }
        
        User userObj = TestUtil.prepareUser();
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
           // System.assertEquals(testOppty.Id, sr.Opportunity__c);
        }
    }
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        Support_Request__c sr = [SELECT Id, Opportunity__c FROM Support_Request__c  limit 1];
        supportRequestController.createPostPlanningSupportRequest( sr.Id);
        clonePostPlanningRequestController.cloneThisPostPlanning(sr.Id);
    }

}