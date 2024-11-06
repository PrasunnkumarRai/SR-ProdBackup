/*
    Author               :  M & S
    Date                 :  Sep 17-19
    Description          :  Test Class for OMS_NetworkExController. 
    Modification History : 
*/
@isTest
public with sharing class OMS_NetworkExControllerTest {
    @testSetup 
    private static void createTestData(){
        User userObj = TestUtil.prepareUser();
        userObj.Approving_Manager__c = UserInfo.getUserId();
        userObj.Division__c = 'Central';
        insert userObj;
        
        
        System.runAs(userObj)
        {

            Account objAcc = TestUtil.getAccountRec();
            insert objAcc;
              
            list<RecordType> lst = [select id from RecordType where name='Agency Account' and sobjecttype='Account'];
            if(lst!=null && !lst.isEmpty()){
                objAcc.RecordTypeId = lst[0].Id;
                objAcc.Last_Client_Schedule_Date__c = Date.today();
                update objAcc;
            }
            
            Account objAgencyAcc = TestUtil.getAgencyAccountRec();
            insert objAgencyAcc;
            
            Opportunity objOpp = TestUtil.getOpportunityRec(objAgencyAcc.Id);
            insert objOpp;
                        
            Proposal__c objPro = TestUtil.getProposal(objAcc.Id,objOpp.Id);
            insert objPro;
            test.startTest();   
            String strRecId = [Select Id From RecordType where sobjecttype = 'Digital_Campaign__c' and name='New Ads Everywhere'].Id;
            Digital_Campaign__c objDC = new Digital_Campaign__c();
            objDC.RecordTypeId = strRecId;
            objDC.Status__c = '03 Submitted to Digital Ops';
            objDC.Campaign_Name__c = 'Test Camp';
            objDC.Advertiser__c = objAgencyAcc.Id;
            objDC.Opportunity__c = objOpp.Id;
            objDC.Proposal__c = objPro.Id;
            objDC.Campaign_Start_Date__c = Date.today();
            objDC.Campaign_End_Date__c = Date.today()+1;
            objDC.Gross_Campaign_Cost__c = 12;
            objDC.Brand__c = 'Acura';
            objDC.Address__c = 'testS, testC, TX, 500082|Conquest|150';
            objDC.Audience_Interests__c = 'Int1';
            objDC.AudienceTrak_Proposal_ID__c = '123451234512345';
            objDC.Account_Executive__c = Userinfo.getUserId();
            objDC.AdsE_Platform_s__c = 'All Platforms';
            objDC.AdsE_Genre_s__c = 'All Networks';
            objDC.AdsE_Network__c = 'AMC;HGTV;ESPN APP;FOX';
            objDC.Kids_Network_Exclusion__c = true;
            objDC.Tune_In_Exclusions__c = true;
            objDC.State__c = 'United states';
            objDC.DMAs__c = 'United states';
            objDC.OwnerId = userObj.Id;
            objDC.Bypass_Apex_Execution__c = true;
            insert objDC;

            Networks__c objNW = new Networks__c();
            objNW.Name = 'Test Network1';
            objNW.Kids_Network_Exclusion__c = true;
            objNW.Tune_In_Exclusions__c = true;
            objNW.Call_Letter__c = 'TST';
            objNW.AdsE_Genre_s__c = 'All Networks';
            insert objNW;

            List<string> networks = new List<string>{
                'HGTV',
                'AMC',
                'CNN',
                'FOX'
            };

            List<Networks__c> networkList = new List<Networks__c>();

            for(string n : networks){
                networkList.add(new Networks__c(
                    Name = n,
                    Kids_Network_Exclusion__c = false,
                    Tune_In_Exclusions__c = true,
                    Call_Letter__c = n,
                    AdsE_Genre_s__c =  'All Networks',
                    ActiveNetwork__c  = (n != 'FOX') ? true : false
                ));              
            }

            insert networkList;


            lst = [select id from RecordType where name='Nielsen DMA' and sobjecttype='Zipcode_Mapping__c'];
            if(lst!=null && !lst.isEmpty()){
                Zipcode_Mapping__c objDZM1 = TestUtil.getDigitalZipcodeMapping();
                objDZM1.RecordTypeId = lst[0].Id;
                objDZM1.Is_Active__c = true;
                objDZM1.Nielsen_DMA_Name__c = 'Test_1';
                objDZM1.Zip_List__c = '12345';
                insert objDZM1;
            }

            lst = [select id from RecordType where name='SR Zone' and sobjecttype='Zipcode_Mapping__c'];
            if(lst!=null && !lst.isEmpty()){
                Zipcode_Mapping__c objDZM1 = TestUtil.getDigitalZipcodeMapping();
                objDZM1.RecordTypeId = lst[0].Id;
                objDZM1.Is_Active__c = true;
                objDZM1.SR_Zone_Name__c = 'Test_1';
                objDZM1.Zip_List__c = '23456';
                insert objDZM1;
            }

            lst = [select id from RecordType where name='Congressional District' and sobjecttype='Zipcode_Mapping__c'];
            if(lst!=null && !lst.isEmpty()){
                Zipcode_Mapping__c objDZM1 = TestUtil.getDigitalZipcodeMapping();
                objDZM1.RecordTypeId = lst[0].Id;
                objDZM1.Is_Active__c = true;
                objDZM1.Congressional_District_Name__c = 'Test_1';
                objDZM1.Zip_List__c = '34567';
                insert objDZM1;
                
                OMS_Settings__c objSettings = new OMS_Settings__c();
                objSettings.Name = 'Operative Submit';
                objSettings.Endpoint_URL__c = 'test.com';
                insert objSettings;
                
				//test.startTest();                
               /* objDC=[Select
                       name,
                       RecordTypeId ,
                       RecordType.name,  
                       Status__c,
                       Campaign_Name__c,
                       Advertiser__c,
                       Advertiser__r.name,
                       Opportunity__c,
                       Proposal__c,
                       Campaign_Start_Date__c,
                       Campaign_End_Date__c,
                       Gross_Campaign_Cost__c, 
                       Brand__c,
                       Address__c ,
                       Audience_Interests__c ,
                       AudienceTrak_Proposal_ID__c ,
                       Account_Executive__c ,
                       AdsE_Platform_s__c,
                       AdsE_Genre_s__c ,
                       AdsE_Network__c ,
                       Kids_Network_Exclusion__c,
                       Tune_In_Exclusions__c ,
                       State__c,
                       DMAs__c,
                       Total_Impressions__c,
                       Agency__c,
                       Agency__r.Name,
                       Opportunity__r.Rep_Firm__r.Name,
                       Opportunity__r.Rep_Firm__c,
                       OwnerId,
                       Bypass_Apex_Execution__c,
                       createdbyid,Live_In_Telecast__c,Product_Vendor__c,Digital_Campaign_ID__c,TIM_ID__c,Pilot_Order_ID__c,Preemptable__c,TIG_Activated__c,Time_Zones__c,Frequency_Cap__c,Data_Catalog__c,
					   Rep_Firm_Text__c,Export_Key_Logic__c,Advanced_Reporting__c,Makegood_Impressions__c,Gross_CPM1__c,Makegood_Campaign_CPM__c,Makegood_CPM__c,Rate_Classification__c,VAST_Tag__c,
					   Product_Type__c,Is_Freewheel_FF_OTT_Primary__c,News_Network_Exclusions__c,Full_Avail_Campaign__c,Exclude_Networks__c,Proposal__r.TIM_System__c,Proposal__r.Traffic_Order_Number__c,
					   Program_Type__c,Eclipse_Customer_ID__c,Advertiser__r.Political_Account__c,Streaming_TV_Old_Process__c,Efficiency_Packages__c,Device_Exclusions__c,
					   Day_of_Week__c,
					   Content_Type__c,
					   TIG_Network__c,Season__c,Owner.FirstName,Owner.LastName,Owner.Email,Sales_Office__c,LastModifiedById,LastModifiedBy.Name,Spectrum_Reach_Zones__c,
					   Advanced_Customizations__c,
                       Opportunity__r.Enterprise_Account_Type__c,Episode__c,CustomZipCode__c
                       FROM Digital_Campaign__c LIMIT 1];
                //System.debug('objDC::'+objDC.CreatedById);*/
               test.stopTest();
                //OMSHelper.SendData(objDC.Id);
                //string payload = OMSHelper.prepareJSONDataToOMS(objDC);
                //OMS_SubmitExController.SendToMiddleware(payload, objDC);
            }

        }
   
    }

    static testMethod void testOMS_NetworkExController() {
        Test.StartTest();
            Digital_Campaign__c objDC = [SELECT Id,OwnerId FROM Digital_Campaign__c limit 1];
            System.assert( objDC.Id != null );
            OMS_NetworkExController objOMS = new OMS_NetworkExController();
            OMS_NetworkExController.getAllNetworks();
            list<string> lstG = new list<string>();
            lstG.add('All Networks');
            OMS_NetworkExController.getNetworksByGenre(lstG);
            OMS_NetworkExController.getGeographyTargetData(objDC.Id);
            list<string> lstDMA = new list<string>();
            lstDMA.add('Test_1');
            OMS_NetworkExController.getDMAZipCodes(lstDMA);
            list<string> lstZone = new list<string>();
            lstZone.add('Test_1');
            OMS_NetworkExController.getZoneZipCodes(lstZone);
            /*list<string> lstCD = new list<string>();
            lstCD.add('Test_1');
            OMS_NetworkExController.getCongressional(lstCD);*/
        	list<string> lstTZDMA = new list<string>();
            lstTZDMA.add('Test_1');
            OMS_NetworkExController.getTimezoneByDMA(lstTZDMA);
       		list<string> lstTZZones = new list<string>();
            lstTZZones.add('Test_1');
            OMS_NetworkExController.getTimezoneByZones(lstTZZones);
			list<string> lstStates = new list<string>();
            lstStates.add('Test_1');
            OMS_NetworkExController.getTimezoneByStates(lstStates);
        	OMS_NetworkExController.getCurrentAETimeZone(true,objDC.OwnerId);
            OMS_NetworkExController.insertZipCodes(objDC.Id,'Test_1','Test_1','Test_1','45678');
        	OMS_NetworkExController.getCustomZipCodeMapping(true, '45678', objDC.OwnerId);
        Test.StopTest();
    }

    static testMethod void testOMS_SubmitExController() {
        Test.StartTest();
            Digital_Campaign__c objDC = [SELECT Id,status__c,Rate_Classification__c FROM Digital_Campaign__c limit 1];
            objDC.status__c = '3.1 DC Submission Error';
        	objDC.Rate_Classification__c = 'Paid';
            update objDC;
            ApexPages.StandardController sc = new ApexPages.StandardController(objDC);
            OMS_SubmitExController objSubmit = new OMS_SubmitExController(sc);
        	User userObj = TestDataHelper.createLSMUser(true);
            //System.runAs(userObj){
             objSubmit.strDcId = objDC.Id;
             objSubmit.SendData();
           // }
        Test.StopTest();
    }
    static testMethod void testOMS_SubmitExController1() {
        Test.StartTest();
            Digital_Campaign__c objDC = [SELECT Id,status__c,Rate_Classification__c FROM Digital_Campaign__c limit 1];
            objDC.status__c = '3.1 DC Submission Error';
        	objDC.Rate_Classification__c = 'Paid';
            update objDC;
            ApexPages.StandardController sc = new ApexPages.StandardController(objDC);
            OMS_SubmitExController objSubmit = new OMS_SubmitExController(sc);
        	User userObj = TestDataHelper.createLSMUser(true);
            System.runAs(userObj){
                objSubmit.strDcId = objDC.Id;
                objSubmit.SendData();
            }
        Test.StopTest();
    }

    @isTest
    static void TestMethod_OMS_getGeographyTargetData_InvalidProfile(){

        Test.startTest();

            User userObj         = [SELECT ID, Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];
            userObj.Profile.Name = 'Master - Account Executive';
            
            update userObj;

            Opportunity opp = [SELECT id, OwnerId FROM Opportunity limit 1];
            opp.OwnerId = UserInfo.getUserId();

            update opp;


            RecordType recordType = [SELECT id, Name, DeveloperName FROM RecordType WHERE Name = 'New Ads Everywhere' LIMIT 1];

            Digital_Campaign__c objDC = [SELECT Id,status__c FROM Digital_Campaign__c limit 1];
           // objDC.status__c = 'None';
            objDC.Opportunity__c = opp.Id;
            objDC.RecordTypeId = recordType.id;
            update objDC;


            OMS_NetworkExController.setProfile = true;
            OMS_NetworkExController.getGeographyTargetData(objDC.Id);


        Test.stopTest();

    }

    @isTest
    static void TestMethod_isSaveEnabled(){
        

        Test.startTest();

        Digital_Campaign__c objDC = [SELECT Id, status__c FROM Digital_Campaign__c LIMIT 1];

        Boolean isVisible = OMS_NetworkExController.isSaveEnabled(objDC.id);

        System.assertEquals(true, isVisible);

        Test.stopTest();
    }


    @isTest
    static void TestMethod_isGeoGroupEditable(){

        Test.startTest();

        String DraftPlan = 'Draft Plan';
        String GeoGroup = 'GeoGroup';
        
        Digital_Campaign__c objDC = [SELECT Id, status__c,Campaign_Start_Date__c, Is_Expedite_Approved__c  FROM Digital_Campaign__c LIMIT 1];
        objDC.status__c = DraftPlan;
		objDC.Campaign_Start_Date__c = System.today()+2; 
        objDC.Is_Expedite_Approved__c = 'true';
        update objDC;

        OMS_Settings__c oms = new OMS_Settings__c(Name=DraftPlan, Category__c=GeoGroup);
        insert oms;
        
        Boolean isTrue = OMS_NetworkExController.isGeoGroupEditable(objDC.id);

        System.assertEquals(true, isTrue);

        objDC.status__c = 'Plan Submitted';
		objDC.Campaign_Start_Date__c = System.today()+2;
         objDC.Is_Expedite_Approved__c = 'true';
        update objDC;

        Boolean isFalse = OMS_NetworkExController.isGeoGroupEditable(objDC.id);

      

        System.assertEquals(false, isFalse);


        Test.stopTest();

    }

    @isTest
    static void TestMethod_getPlatformRevision(){

        Test.startTest();


        OMS_Settings__c oms = new OMS_Settings__c(Name='PlatformEdit1', Value__c='11 Sales Revision In Progress', Category__c='PlatformEdit');
        insert oms;
        
        String result = OMS_NetworkExController.getPlatformRevision();

        System.assertEquals(oms.Value__c, result);

        Test.stopTest();
    }

    @isTest
    static void TestMethod_getAllPlatformsType(){

        Test.startTest();

        OMS_Settings__c oms = new OMS_Settings__c(Name='VOD (Set-top Box)', Value__c='VOD (Set-top Box)', Category__c='AllPlatforms');
        insert oms;
        
        String result = OMS_NetworkExController.getAllPlatformsType();

        System.assertEquals(oms.Value__c, result);

        Test.stopTest();

    }

    @isTest
    static void TestMethod_getCleanseOMSNetworkValues_NoCampaign(){

       Test.startTest();


        string json = OMS_NetworkExController.getCleanseOMSNetworkValues(null);

        OMS_NetworkClass omsClass = (OMS_NetworkClass)System.JSON.deserialize(json, OMS_NetworkClass.class); 

        System.assertEquals(omsClass.InvalidNetworks.size(), 0);
        System.assertEquals(omsClass.InActiveNetworks .size(), 0);
        System.assertEquals(omsClass.SelectedNetworks .size(), 0);

        Test.stopTest();
    }

    @isTest
    static void TestMethod_getCleanseOMSNetworkValues(){

        Test.startTest();

        Digital_Campaign__c objDC = [SELECT Id FROM Digital_Campaign__c LIMIT 1];

        string json = OMS_NetworkExController.getCleanseOMSNetworkValues(objDC.Id);

        OMS_NetworkClass omsClass = (OMS_NetworkClass)System.JSON.deserialize(json, OMS_NetworkClass.class); 

        String invalidNetworks  = String.join(omsClass.InvalidNetworks, ';');
        String inActiveNetworks = String.join(omsClass.InActiveNetworks, ';');

        System.assertEquals(invalidNetworks, 'ESPN APP');
        System.assertEquals(inActiveNetworks, 'FOX');
        System.assertEquals(omsClass.SelectedNetworks.size(), 2);

        Test.stopTest();

    }

    @isTest
    static void TestMethod_getNetworkMessage(){

        Test.startTest();

        Digital_Campaign__c objDC = [SELECT Id FROM Digital_Campaign__c LIMIT 1];

        string json = OMS_NetworkExController.getNetworkMessage(objDC.Id);

        OMS_NetworkClass omsClass = (OMS_NetworkClass)System.JSON.deserialize(json, OMS_NetworkClass.class); 

        String invalidNetworks  = String.join(omsClass.InvalidNetworks, ';');
        String inActiveNetworks = String.join(omsClass.InActiveNetworks, ';');

        System.assertEquals(invalidNetworks, 'ESPN APP');
        System.assertEquals(inActiveNetworks, 'FOX');
        System.assertEquals(omsClass.SelectedNetworks.size(), 2);
        
        OMS_NetworkExController.getGrossCPMConfig();

        Test.stopTest();

    }
    
    @isTest
    static void TestMethod_ZipcodeForAudienceTrack(){

        Test.startTest();
        Digital_Campaign__c objDC = [select Id,Name, Source__c,DMAs__c,Zip_Codes__c from Digital_Campaign__c limit 1];
        objDC.Source__c = 'Audience Track';
        objDC.DMAs__c = 'Test_1';
        update objDC;
        
        objDC.DMAs__c = null;
        objDC.Spectrum_Reach_Zones__c = 'Test_1';
        update objDC;
        
        objDC.Spectrum_Reach_Zones__c = null;
        //objDC.Congressional_Districts__c = 'Test_1';
        update objDC;

        Test.stopTest();

    }
    
    //Code coverage for GeographyTargetHelper, GeographyTargetClass classes.
    @isTest
    static void TestGeographyTargetClass(){

        Test.startTest();
        Digital_Campaign__c objDC = new Digital_Campaign__c();
        GeographyTargetClass.getDMA(objDC);
        GeographyTargetClass.getZones();
        //GeographyTargetClass.getCongressionals();
        GeographyTargetHelper obj = new GeographyTargetHelper();
        obj.lstCongr = null;
        obj.lstDMA = null;
        obj.lstZone = null;
        obj.lstDigAZone = null;
        obj.showDMA = true;
        obj.showSRZ = true;
        obj.showCD = true;
        obj.strZipcode = null;
        obj.lockRecord = true;
        obj.strLblDMA = null;
        obj.strLblSRZone = null;
        obj.strLblCongDist = null;
        Test.stopTest();
    }

    @isTest
    static void getNumberOfDays_PassFlightDates_GetCorrectValue(){

      Test.startTest();

        Integer expectedNumberOfDays = 29;
        string flightDates           = '2021-06-01:2021-06-01;2021-06-03:2021-06-30;';

        Integer result = OMS_NetworkExController.getNumberOfDays(flightDates);

        System.assertEquals(expectedNumberOfDays, result);

      Test.stopTest();

    }
    @isTest
    static void getImpressionValueTest(){

      Test.startTest();

        Digital_Campaign__c objDC = [select Id,Name, Source__c,DMAs__c,Zip_Codes__c from Digital_Campaign__c limit 1];
          Inventory_Source__c objIs = new Inventory_Source__c();
            objIs.Digital_Campaign__c = objDC.id;
            objIs.CPM_Gross__c = 100;
            objIs.COST_Gross__c = 100;
            objIs.Inventory_Resource_Type__c = 'Simpli.fi-CTV';
            insert objIs;
		OMS_NetworkExController.getImpressionValue(objDC.Id);
      Test.stopTest();

    }
    
    @isTest
    static void testgetpoliticalCPMConfig(){
        Data_Catalog__c data = new Data_Catalog__c();
        data.Display_Text__c = 'Test Display';
        data.Political__c = true;
        data.CPM__c = 'CPM';
        data.Export_Key__c = 'Test Export';
        data.Political_CPM__c = 'Test political';
        
        insert data;
        
        
        String str = 'Test Display,Test CPM,Test Export,Test political';
        
        //Test.startTest();
       // List<String> displayTest = OMS_NetworkExController.getpoliticalCPMConfig(str);
        //Test.stopTest();
       // System.assertEquals(1,displayTest.size());
        
    }
}