/*
Author : MAndS 
Date   : Apr 04-2018
Description : test class to cover CM_DigitalCampaign related classes
Modification History : 
*/
@isTest
public class CM_CloneMultipleDCCreativesTest {
    
    @isTest
    public static void testCreateCloneDigitalCreative(){
        Account objAgencyAcc = TestUtil.getAgencyAccountRec();
        insert objAgencyAcc;
        
        Opportunity opp = TestDataHelper.createopportunity(null,System.Today(),null,null,null);
        insert opp;
        Proposal__c prop = TestDataHelper.createProposal(null,opp.Id,null,null);
        insert prop;
       

        Digital_Campaign__c digiObj = TestDataHelper.createDigitalCampaign('testDName', opp.Id, prop.Id);
        insert digiObj;
        
        Digital_Campaign__c digiObj1 = TestDataHelper.createDigitalCampaign('tN', opp.Id, prop.Id);
        insert digiObj1;
        
       Digital_Creative__c obj = new Digital_Creative__c();
        obj.Digital_Campaign__c = digiObj.Id; //DcList[0].Id;
        obj.Creative_Name__c = 'test1';
        obj.Creative_Start_Date__c = date.today();
        obj.Creative_End_Date__c = date.today()+1;
        obj.Creative_Location__c = 'Audience Trak';
        obj.Click_Through_URL__c = 'www.test.com';
        obj.Status__c = '01 Draft Creative';
        insert obj;
        
        
        List<CM_DCCWrap> lstDCCWrap = new List<CM_DCCWrap>();
        CM_DCCWrap objWrap = new CM_DCCWrap(true,obj,digiObj,digiObj1);
        lstDCCWrap.add(objWrap);
        
        List<String> cloneToDCId = new List<String>();
        cloneToDCId.add(digiObj.Id);
        
        // Call the method being tested
      Test.startTest();
        String result1 = CM_CloneMultipleDCCreatives.CreateCloneDigitalCreative(JSON.serialize(lstDCCWrap), cloneToDCId, digiObj.Id);
        String result2 = CM_CloneDCCreativesController.CreateCloneDigitalCreative(JSON.serialize(lstDCCWrap), digiObj.Id, digiObj.Id);

       
        
        
        

        // Create test Digital_Creative__c records to clone from
        /*List<Digital_Creative__c> testFromDigitalCreatives = new List<Digital_Creative__c>();
        for (Integer i = 0; i < 5; i++) {
               Digital_Creative__c testFromDigitalCreative = new Digital_Creative__c(Digital_Campaign__c = digiObj.Id,
                Creative_Name__c = 'Test Creative ' + i);
            testFromDigitalCreatives.add(testFromDigitalCreative);
        }
        insert testFromDigitalCreatives;

        // Prepare the input parameters for the method
        List<CM_DCCWrap> testWrapperList = new List<CM_DCCWrap>();
        for (Digital_Creative__c fromDC : testFromDigitalCreatives) {
            CM_DCCWrap wrapper = new CM_DCCWrap(true, fromDC, digiObj, null);
            testWrapperList.add(wrapper);
        }
        String selWrapJson = JSON.serialize(testWrapperList);*/
        String[] cloneToDCIds = new String[]{'khusboo'};//{digiObj.Id};
        Id fromStrDCId = digiObj.Id; // Pick one of the Digital_Creative__c records as the source

        // Call the method being tested
        
        String result3 = CM_CloneMultipleDCCreatives.CreateCloneDigitalCreative('selWrapJson', cloneToDCIds, fromStrDCId);
        String result4 = CM_CloneDCCreativesController.CreateCloneDigitalCreative('selWrapJson', fromStrDCId, fromStrDCId);


        Test.stopTest();

        
        
        
        
        
        
        
        
        
    }
    
    @isTest
    public static void testcheckForValidDC(){
        Account objAgencyAcc = TestUtil.getAgencyAccountRec();
        insert objAgencyAcc;
        
        Opportunity opp = TestDataHelper.createopportunity(null,System.Today(),null,null,null);
        insert opp;
        Proposal__c prop = TestDataHelper.createProposal(null,opp.Id,null,null);
        insert prop;
        
        
        Digital_Campaign__c dcampaign = new Digital_Campaign__c();
        dcampaign.Proposal__c = prop.Id;
        dcampaign.Status__c = '05 Trafficked by Digital Ops';
        dcampaign.Campaign_Name__c = 'cName';//testProposal.Name+' - Ads Everywhere '
        dcampaign.Agency__c = objAgencyAcc.id;
        dcampaign.Opportunity__c = opp.Id;
        dcampaign.Desired_Budget__c = 500;
        dcampaign.Campaign_Start_Date__c = date.today();
        dcampaign.Campaign_End_Date__c = date.today();
        dcampaign.Max_Trafficked_Creative_End_Date__c = date.today();
        dcampaign.AudienceTrak_Proposal_ID__c = '1542568817653267380';
        dcampaign.Rate_Classification__c = 'Makegood-Sales';
        dcampaign.Gross_Campaign_Cost__c = 2000;
 dcampaign.Migrated_Creative__c =false; 
        insert dcampaign;
        
        Digital_Campaign__c dcampaign1 = new Digital_Campaign__c();
        dcampaign1.Proposal__c = prop.Id;
        dcampaign1.Status__c = '05 Trafficked by Digital Ops';
        dcampaign1.Campaign_Name__c = 'testCNAME';//testProposal.Name+' - Ads Everywhere ';
        dcampaign1.Agency__c = objAgencyAcc.id;
        dcampaign1.Opportunity__c = opp.Id;
        dcampaign1.Desired_Budget__c = 500;
        dcampaign1.Campaign_Start_Date__c = date.today();
        dcampaign1.Campaign_End_Date__c = date.today();
        dcampaign1.Max_Trafficked_Creative_End_Date__c = date.today();
        dcampaign1.AudienceTrak_Proposal_ID__c = '1542144541926764915';
        dcampaign1.Rate_Classification__c = 'Makegood-Sales';
        dcampaign1.Gross_Campaign_Cost__c = 755;
        dcampaign1.Migrated_Creative__c =false; 
        insert dcampaign1;
        
        Test.startTest();
        CM_CloneMultipleDCCreatives.checkForValidDC(dcampaign, dcampaign1);
        Test.stopTest();
    }
    
    @isTest
    public static void testfetchLookUpValues(){
        //List<sObject> ExcludeitemsList = new List<sObject>();
        List<Contact> conList = new List<Contact>();
        Contact conObj = new Contact();
        conObj.LastName = 'SONARE';
        conObj.Email = 'Test3@gmail.com';
        conList.add(conObj);
        insert conList;
       
        Account objAcc = TestUtil.getAccountRec();
        insert objAcc;
        
        Account objAgencyAcc = TestUtil.getAgencyAccountRec();
        insert objAgencyAcc;
        
        Opportunity opp = TestDataHelper.createopportunity(null,System.Today(),null,null,null);
        insert opp;
        Proposal__c prop = TestDataHelper.createProposal(null,opp.Id,null,null);
        insert prop;
        
        
        Digital_Campaign__c dcampaign = new Digital_Campaign__c();
        dcampaign.Proposal__c = prop.Id;
        dcampaign.Status__c = '05 Trafficked by Digital Ops';
        dcampaign.Campaign_Name__c = 'cName';//testProposal.Name+' - Ads Everywhere '
        dcampaign.Agency__c = objAgencyAcc.id;
        dcampaign.Opportunity__c = opp.Id;
        dcampaign.Desired_Budget__c = 500;
        dcampaign.Campaign_Start_Date__c = date.today();
        dcampaign.Campaign_End_Date__c = date.today();
        dcampaign.Max_Trafficked_Creative_End_Date__c = date.today();
        dcampaign.AudienceTrak_Proposal_ID__c = '1542568817653267380';
        dcampaign.Rate_Classification__c = 'Makegood-Sales';
        dcampaign.Gross_Campaign_Cost__c = 2000;
        dcampaign.Advertiser__c = objAcc.Id;
        dcampaign.Migrated_Creative__c =false; 
        insert dcampaign;
        
       /* Digital_Campaign__c dcampaign1 = new Digital_Campaign__c();
        dcampaign1.Advertiser__c = objAcc.Id;
        //dcampaign1.Name = dcampaign.Name;
        dcampaign1.Campaign_Name__c = dcampaign.Name;
        insert dcampaign1;*/
        
        Test.startTest();
        CM_CloneMultipleDCCreatives.fetchLookUpValues('cName','Digital_Campaign__c',objAcc.Id,conList); 
        Test.stopTest();
    }
    
    
    @isTest
    public static void testgetProfileInfo(){
        Test.startTest();
        CM_CloneMultipleDCCreatives.getProfileInfo();
        Test.stopTest();
    }
    
    @isTest
    public static void testgetDigitalCampaign(){
        Account objAgencyAcc = TestUtil.getAgencyAccountRec();
        insert objAgencyAcc;
        
        Opportunity opp = TestDataHelper.createopportunity(null,System.Today(),null,null,null);
        insert opp;
        Proposal__c prop = TestDataHelper.createProposal(null,opp.Id,null,null);
        insert prop;
        
        
        Digital_Campaign__c dcampaign = new Digital_Campaign__c();
        dcampaign.Proposal__c = prop.Id;
        dcampaign.Status__c = '05 Trafficked by Digital Ops';
        dcampaign.Campaign_Name__c = 'cName';//testProposal.Name+' - Ads Everywhere '
        dcampaign.Agency__c = objAgencyAcc.id;
        dcampaign.Opportunity__c = opp.Id;
        dcampaign.Desired_Budget__c = 500;
        dcampaign.Campaign_Start_Date__c = date.today();
        dcampaign.Campaign_End_Date__c = date.today();
        dcampaign.Max_Trafficked_Creative_End_Date__c = date.today();
        dcampaign.AudienceTrak_Proposal_ID__c = '1542568817653267380';
        dcampaign.Rate_Classification__c = 'Makegood-Sales';
        dcampaign.Gross_Campaign_Cost__c = 2000;
        dcampaign.Migrated_Creative__c =false; 

        insert dcampaign;
        
        
        Test.startTest();
        CM_CloneMultipleDCCreatives.getDigitalCampaign(dcampaign.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testgetDigitalCreatives(){
        Opportunity opp = TestDataHelper.createopportunity(null,System.Today(),null,null,null);
        insert opp;
        Proposal__c prop = TestDataHelper.createProposal(null,opp.Id,null,null);
        insert prop;
        
        Account acc = new Account();
        acc.Name = 'testName';
        insert acc;
        
        Account accObj = new Account();
        accObj.Name = 'tName';
        insert accObj;
        
        Digital_Campaign__c dcampaign = new Digital_Campaign__c();
        dcampaign.Proposal__c = prop.Id;
        //dcampaign.RecordTypeId = dcRT.Id;
        dcampaign.Status__c = '05 Trafficked by Digital Ops';
        dcampaign.Campaign_Name__c = 'cName';//testProposal.Name+' - Ads Everywhere ';
        dcampaign.Advertiser__c = acc.Id;
        dcampaign.Agency__c = accObj.id;
        dcampaign.Opportunity__c = opp.Id;
        dcampaign.Desired_Budget__c = 500;
        dcampaign.Campaign_Start_Date__c = date.today();
        dcampaign.Campaign_End_Date__c = date.today();
        dcampaign.Max_Trafficked_Creative_End_Date__c = date.today();
        dcampaign.Migrated_Creative__c =false; 

        insert dcampaign;
        
        Digital_Campaign__c dcampaign1 = new Digital_Campaign__c();
        dcampaign1.Proposal__c = prop.Id;
        //dcampaign.RecordTypeId = dcRT.Id;
        dcampaign1.Status__c = '05 Trafficked by Digital Ops';
        dcampaign1.Campaign_Name__c = 'testCNAME';//testProposal.Name+' - Ads Everywhere ';
        dcampaign1.Advertiser__c = acc.Id;
        dcampaign1.Agency__c = accObj.id;
        dcampaign1.Opportunity__c = opp.Id;
        dcampaign1.Desired_Budget__c = 500;
        dcampaign1.Campaign_Start_Date__c = date.today();
        dcampaign1.Campaign_End_Date__c = date.today();
        dcampaign1.Max_Trafficked_Creative_End_Date__c = date.today();
        dcampaign1.Migrated_Creative__c =false; 

        insert dcampaign1;
        
        
        Test.startTest();
        CM_CloneMultipleDCCreatives.getDigitalCreatives(dcampaign,dcampaign1);
        Test.stopTest();
    }
}