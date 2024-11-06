/*
Author : MandS
Date   : Aug 29th 2022
Description : Test class for MassApprovalRejectionController
Ref: SRSF-3826: Expedite Mass Approval
*/
@isTest
public class MassApprovalRejectionController_Test {
    @testSetup 
    static void setupmethod() {
        // TO DO: implement unit test
        map<String, Id> mapRecordTypeId = new map<String, Id>();
        for( RecordType accRT : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND ( DeveloperName='Agency_Account' OR DeveloperName='Advertiser_Account' )]){
            mapRecordTypeId.put( accRT.DeveloperName, accRT.Id );
        }
        User userAE = TestUtil.prepareUser();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@mands.com';
        userAE.Email = 'testae@charter.com';
        userAE.Division__c = 'Central';
        //update userObj;
        
        User userObj = TestUtil.prepareUser();
        userObj.Approving_Manager__c = UserInfo.getUserId();
        userObj.Division__c = 'Central';
        insert new list<User>{ userObj, userAE };
            
            Proposal__c testProposal;
        Account AdsAccount;
        Account AgencyAccount;
        Opportunity testOppty;
        
        System.runAs( userObj ){
            AdsAccount = new Account(Name='Test Ads Account', RecordTypeId=mapRecordTypeId.get('Advertiser_Account'), BillingStreet = '235 High St',
                                     BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
                                     BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
                                     ShippingPostalCode = '26505', ShippingCountry = 'USA', Legal_Entity_Name__c='Test Legal Name' );
            
            AgencyAccount = new Account(Name='Test Agency Account', RecordTypeId=mapRecordTypeId.get('Agency_Account'), BillingStreet = '235 High St',
                                        BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
                                        BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
                                        ShippingPostalCode = '26505', ShippingCountry = 'USA' );
            
            insert new list<Account>{ AdsAccount, AgencyAccount };
                
                RecordType opptyRT = [SELECT Id FROM RecordType WHERE SObjectType='Opportunity' AND DeveloperName='Opportunity' limit 1];
            testOppty = new Opportunity();
            testOppty.Name = 'Test Opportunity';
            testOppty.RecordTypeId = opptyRT.Id;
            testOppty.StageName='Proposal Presentation';
            testOppty.CloseDate = System.Today().addDays( 30 );
            testOppty.AccountId = AdsAccount.id;
            testOppty.Agency_Account__c = AgencyAccount.Id;
            insert testOppty;
            
            RecordType proposalRT = [SELECT Id FROM RecordType WHERE SobjectType='Proposal__c' AND DeveloperName='Linear' limit 1];
            testProposal = new Proposal__c();
            testProposal.Name = 'Test Proposal';
            testProposal.TIM_System__c = 'Dallas';
            testProposal.Start_Date__c = SYstem.Today();
            testProposal.End_Date__c = System.Today().addDays( 7 );
            testProposal.Opportunity__c = testOppty.Id;
            testProposal.Advertiser__c = AdsAccount.Id; 
            testProposal.RecordTypeId = proposalRT.Id;
            insert testProposal;
            
            
            
            Test.startTest();
            
            Networks__c net = new Networks__c();
            net.Name = 'ABC News' ;
            net.ActiveNetwork__c = true;
            net.Split_Avail_Activated__c = true;
            net.Frequence_Activated__c = true;
            insert net;
            
            RecordType dcRT = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Digital_Campaign__c' AND DeveloperName='New_Ads_Everywhere' limit 1];
            
            list<Digital_Campaign__c> dCampaigns = new list<Digital_Campaign__c>();
            for( Integer i = 1; i <= 2; i++ ){
                Digital_Campaign__c dcampaign = new Digital_Campaign__c();
                dcampaign.Proposal__c = testProposal.Id;
                dcampaign.RecordTypeId = dcRT.Id;
                dcampaign.Status__c = '01 Draft Campaign';
                dcampaign.Campaign_Name__c = testProposal.Name+' - Ads Everywhere ' + i;
                dcampaign.Advertiser__c = AdsAccount.Id;
                dcampaign.Agency__c = AgencyAccount.id;
                dcampaign.Opportunity__c = testOppty.Id;
                dcampaign.Desired_Budget__c = 500;
                dcampaign.Source__c = 'Audience Track';
                dcampaign.DMAs__c = 'ALBANY - GA';
                dcampaign.Full_Avail_Campaign__c = False;
                dcampaign.Product_Type__c = 'DMA Addressable';
                dcampaign.AdsE_Genre_s__c = 'Selected Networks';
                dcampaign.AdsE_Network__c = net.Name;
                dCampaigns.add( dcampaign );
            }
            insert dCampaigns;
        }
    }
    
    @istest
    static void myUnitTest() {
    
        Test.startTest();
        list<Digital_Campaign__c> dCampaigns = [SELECT Id,Status__c,Campaign_Start_Date__c FROM Digital_Campaign__c LIMIT 1];
        for(Digital_Campaign__c objDC : dCampaigns){
            objDC.Status__c = 'Submit for Expedite Approval';
        }
        update dCampaigns;
        dCampaigns = [SELECT Id,Status__c,Campaign_Start_Date__c FROM Digital_Campaign__c LIMIT 1];
        system.debug('==>dCampaigns::'+dCampaigns);
        MassApprovalRejectionController.getKeyPrefix('Digital_Campaign__c');
        MassApprovalRejectionController.isValidUser();
        
        
        
        
        List<MassApprovalRejectionController.SubmittedRecordsWrapper> lst= MassApprovalRejectionController.getSubmittedRecords('Digital_Campaign__c','RecordType.Name,id,Name,Advertiser__r.Name,OwnerId,Status__c,Campaign_Start_Date__c,Campaign_End_Date__c,Region__c,Sales_Office__c,Date_Last_Submitted__c','DC-%');
        system.debug('==>lst::'+lst);
        //System.assertEquals(lst.isEmpty(), false);
        list<Id> workitems = new list<Id>();
        if (lst.size()>0){
        workitems.add(lst[0].workItemId);}
        MassApprovalRejectionController.processRecords(workitems,'Approve', 'Test');
        Test.stopTest();
    }
    
    @isTest
    public static void testgetSubmittedRecords(){
        Group test = new Group();
        test.Name = 'Test Group';
        insert test;
        
        GroupMember grpObj = new GroupMember();
        grpObj.UserOrGroupId = UserInfo.getUserId();
        grpObj.GroupId = test.Id;
        insert grpObj;
        MassApprovalRejectionController.getSubmittedRecords('Digital_Campaign__c','Id,Name,Status__c','DC-%');
    }
    
    @isTest
    public static void testprocessRecords1(){
        List<String> testWorkItemIds = new List<String>{'', '', ''};
            String testProcessType = 'SomeProcessType';
        String testComments = 'Test comments';
        
        MassApprovalRejectionController.processRecords(testWorkItemIds,testProcessType,testComments);
    }
    
    @isTest
    public static void testprocessRecordsformakegood(){
        List<String> testWorkItemIds = new List<String>{'ID001', 'ID002', 'ID003'};
            String testProcessType = 'SomeProcessType';
        String testComments = 'Test comments';
        
        MassApprovalRejectionController.processRecordsformakegood(testWorkItemIds,testProcessType,testComments);
    }
    @isTest
    public static void testprocessRecordsformakegood1(){
        List<String> testWorkItemId = new List<String>{'', '', ''};
            String testProcessType = 'SomeProcessType';
        String testComments = 'Test comments';
        
        MassApprovalRejectionController.processRecordsformakegood(testWorkItemId,testProcessType,testComments);
    }
    
    @isTest
    public static void testprocessRecordsforCpm(){
        List<String> testWorkItemIds = new List<String>{'ID001', 'ID002', 'ID003'};
            String testProcessType = 'SomeProcessType';
        String testComments = 'Test comments';
        MassApprovalRejectionController.processRecordsforCpm(testWorkItemIds,testProcessType,testComments);
    }
    @isTest
    public static void testprocessRecordsforCpm1(){
        List<String> testWorkItemId = new List<String>{'', '', ''};
            String testProcessType = 'SomeProcessType';
        String testComments = 'Test comments';
        MassApprovalRejectionController.processRecordsforCpm(testWorkItemId,testProcessType,testComments);
    }
    
    @isTest
    public static void testisValidUsermakeGood(){
        MassApprovalRejectionController.isValidUsermakeGood();
    }
    
    @isTest
    public static void testgetAllMakeGoodData(){
        String testObjectName = 'Digital_Campaign__c'; 
        String testFields = 'Field1__c, Field2__c'; 
        String testAutoPrefix = 'AutoPrefix';
        
        Group test = new Group();
        test.Name = 'Test Group';
        insert test;
        
        GroupMember grpObj = new GroupMember();
        grpObj.UserOrGroupId = UserInfo.getUserId();
        grpObj.GroupId = test.Id;
        insert grpObj;
        
        
        
        MassApprovalRejectionController.getAllMakeGoodData(testObjectName,testFields,testAutoPrefix);
    }
    
    @isTest
    public static void testgetAllCPMData(){
        String testObjectName = 'Digital_Campaign__c'; 
        String testFields = 'Field1__c, Field2__c'; 
        String testAutoPrefix = 'AutoPrefix';
        Group test = new Group();
        test.Name = 'Test Group';
        insert test;
        
        GroupMember grpObj = new GroupMember();
        grpObj.UserOrGroupId = UserInfo.getUserId();
        grpObj.GroupId = test.Id;
        insert grpObj;
        MassApprovalRejectionController.getAllCPMData(testObjectName,testFields,testAutoPrefix);
    }
    
    
}