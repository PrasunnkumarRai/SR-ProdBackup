@isTest
public with sharing class VRFTestFactory {
   
    public static string testEndPointSetting = 'http://www.test.com'; 
    public static string testPrefixEndpoint  = 'http://www.testtest.com';
    public static string testErrorStatus     = '2.2 VRF Submission Error';
    public static string testSubmission      = '2.1 Submitted to Digital Traffic';
    public static string testSubmittedToMS   = '2.2 Submitted to Master Control';


    @isTest
    public static void CreateTestData(){
		/*
       CreateVRFSettings('Test Test', testEndPointSetting, 'vrf_endpoint');
       CreateVRFSettings('Prefix', testPrefixEndpoint, 'orderPrefix_endpoint');
       CreateVRFSettings('Master - Digital Operations', 'Master - Digital Operations', 'vrf_profile');
       CreateVRFSettings('test@test.com', 'test@test.com', 'adminEmail');
       CreateVRFSettings('test@test.com', 'http://www.acme.com/api', 'vrf_revision_endpoint');
       CreateVRFSettings(testErrorStatus, testErrorStatus, 'vrf_errorStatus');
       CreateVRFSettings('Test Test', 'http://www.status.com', 'vrf_status_endpoint');
       CreateVRFSettings(testSubmittedToMS, testSubmittedToMS, 'vrf_submitted');
       CreateVRFSettings(testSubmission, testSubmission, 'vrf_allowCreate');*/
        try{
        list<VRF_Settings__c> lstVRF = new list<VRF_Settings__c>();
        lstVRF.add(CreateVRFSettings('Test Test', testEndPointSetting, 'vrf_endpoint'));
        lstVRF.add(CreateVRFSettings('Prefix', testPrefixEndpoint, 'orderPrefix_endpoint'));
        lstVRF.add(CreateVRFSettings('Master - Digital Operations', 'Master - Digital Operations', 'vrf_profile'));
        lstVRF.add(CreateVRFSettings('test@test.com', 'test@test.com', 'adminEmail'));
        lstVRF.add(CreateVRFSettings('test@test.com1', 'http://www.acme.com/api', 'vrf_revision_endpoint'));
        lstVRF.add(CreateVRFSettings(testErrorStatus, testErrorStatus, 'vrf_errorStatus'));
        lstVRF.add(CreateVRFSettings('Test Test1', 'http://www.status.com', 'vrf_status_endpoint'));
        lstVRF.add(CreateVRFSettings(testSubmittedToMS, testSubmittedToMS, 'vrf_submitted'));
        lstVRF.add(CreateVRFSettings(testSubmission, testSubmission, 'vrf_allowCreate'));
        insert lstVRF;
        VRF_DigitalTraffic_Profiles__c vrfProfiles = new VRF_DigitalTraffic_Profiles__c();
        vrfProfiles.Name = 'Master - Digital Operations';

        insert vrfProfiles;

        VRF_Record_Types__c  recordTypes = new VRF_Record_Types__c();
        recordTypes.Name = 'Inventory Request - Ads Everywhere';

        insert recordTypes;

        VRF_SalesOffice__c salesOffice = new VRF_SalesOffice__c();
        salesOffice.Name              = 'Charlotte 1';
        salesOffice.OrderPrefix__c    = 50;
        salesOffice.Region__c         = 'Carolinas';
        salesOffice.Division__c       = 'South';
        salesOffice.Eclipse_System__c = 'CHFL';

        insert salesOffice;


        Map<String, Id> mapRecordTypeId = new Map<String, Id>();
        for( RecordType accRT : [ SELECT Id, DeveloperName FROM RecordType 
                                  WHERE SObjectType='Account' 
                                  AND ( DeveloperName='Agency_Account' OR DeveloperName='Advertiser_Account' )]){
            mapRecordTypeId.put( accRT.DeveloperName, accRT.Id );
        }

        User userAE = TestUtil.prepareUser();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Digital Operations'];
        
        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@mands.com';
        userAE.Email = 'testae@mands.com';
        userAE.Sales_Office__c = 'Charlotte 1';
        userAE.Division__c = 'South';
        userAE.Region__c = 'Carolinas';
        insert userAE;


        Proposal__c testProposal;
        Account AdsAccount;
        Account AgencyAccount;
        Opportunity testOppty;

        AdsAccount = new Account(Name='Test Ads Account', RecordTypeId=mapRecordTypeId.get('Advertiser_Account'), BillingStreet = '235 High St',
                BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
                BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
                ShippingPostalCode = '26505', ShippingCountry = 'USA', Legal_Entity_Name__c='Test Legal Name' );


       insert AdsAccount;
                    
        AgencyAccount = new Account(Name='Test Agency Account', RecordTypeId=mapRecordTypeId.get('Agency_Account'), BillingStreet = '235 High St',
        BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
        BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
        ShippingPostalCode = '26505', ShippingCountry = 'USA' );

        insert AgencyAccount;

        RecordType opptyRT = [SELECT Id FROM RecordType WHERE SObjectType='Opportunity' AND DeveloperName='Opportunity' limit 1];
        testOppty = new Opportunity();
        testOppty.Name = 'Test Opportunity';
        testOppty.RecordTypeId = opptyRT.Id;
        testOppty.StageName='Proposal Presentation';
        testOppty.CloseDate = System.Today().addDays( 30 );
        testOppty.AccountId = AdsAccount.id;
        testOppty.Agency_Account__c = AgencyAccount.Id;
        testOppty.OwnerId = userAE.Id;
        testOppty.CoOp__c = true;
     

        insert testOppty;
        
        RecordType proposalRT = [SELECT Id FROM RecordType WHERE SobjectType='Proposal__c' AND DeveloperName='Linear' LIMIT 1];
        testProposal = new Proposal__c();
        testProposal.Name = 'Test Proposal';
        testProposal.TIM_System__c = 'Dallas';
        testProposal.Start_Date__c = SYstem.Today();
        testProposal.End_Date__c = System.Today().addDays( 7 );
        testProposal.Opportunity__c = testOppty.Id;
        testProposal.Advertiser__c = AdsAccount.Id; 
        testProposal.Agency__c = AdsAccount.Id; 
        testProposal.RecordTypeId = proposalRT.Id;
        testProposal.Tim_Status__c = 'Proposal';
        
         insert testProposal;

        RecordType digitalCampaignRT = [SELECT Id FROM RecordType WHERE sObjectType = 'Digital_Campaign__c' 
                                        AND DeveloperName = 'Inventory_Request_New_Ads_Everywhere' LIMIT 1];
		test.startTest();
        Digital_Campaign__c digitalCampaign = new Digital_Campaign__c();
        digitalCampaign.RecordTypeId = digitalCampaignRT.Id;
        digitalCampaign.Proposal__c = testProposal.Id;
        digitalCampaign.Advertiser__c = AdsAccount.Id;
        digitalCampaign.Agency__c = AgencyAccount.id;
        digitalCampaign.Opportunity__c = testOppty.Id;     
        digitalCampaign.Agency_Text__c = AgencyAccount.Name;
        digitalCampaign.OwnerId = userAE.Id;
        digitalCampaign.Campaign_Name__c = 'Test Campaign';

        insert digitalCampaign;


        RecordType digitalCreativeRT = [SELECT Id FROM RecordType WHERE sobjectType = 'digital_creative__c'
                                       AND DeveloperName = 'Addressable_Adse' LIMIT 1];
      
        Digital_Creative__c digitalCreative = new Digital_Creative__c();
        digitalCreative.Account_Executive__c  = userAE.Id;
        digitalCreative.RecordTypeId          = digitalCreativeRT.Id;
        digitalCreative.Digital_Campaign__c   = digitalCampaign.Id;
        digitalCreative.Account_Executive__c  = userAE.Id;
        digitalCreative.Status__c             = '2.1 Submitted to Digital Traffic';
        digitalCreative.VRF_Spot_ID__c        = 'J123456';
        digitalCreative.HD_AssetId__c         = '3019062000000004';
        digitalCreative.SD_AssetId__c         = '3019062000000003';
        digitalCreative.Click_Through_URL__c  = 'http://testing.com';
        insert digitalCreative;
            test.stopTest();
        }catch(Exception ex){}
     }
 
    private static VRF_Settings__c CreateVRFSettings(string name, string value, string category){
      
        VRF_Settings__c settings = new VRF_Settings__c();
        settings.Name = name;
        settings.Value__c = value; 
        settings.Category__c =  category;

        return settings;
    }
}