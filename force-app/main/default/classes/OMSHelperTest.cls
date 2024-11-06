@isTest(seeAlldata = false)
public class OMSHelperTest {


    @testSetup
    static void CreateTestData(){

        RecordType recordType = [SELECT id, Name FROM RecordType 
        WHERE Name = 'New Ads Everywhere' 
        AND SobjectType = 'Digital_Campaign__c' LIMIT 1];
        
        Account acct = new Account(Name ='Test Account');
        insert acct;


        Digital_Campaign__c dcc = new Digital_Campaign__c( 
        Status__c = OMS_MiddlwareController.SubmittedDigOps, 
        Advertiser__c = acct.id,
        RecordTypeId = recordType.Id,
        Rep_Firm_Text__c = '', 
        Product_Type__c = 'National Addressable', 
        Campaign_Name__c = 'Cox Toyota Ads E 2019 (December) - New Ads Everywhere',
        Campaign_Start_Date__c =   Date.newInstance(2019, 9, 20), 
        Campaign_End_Date__c = Date.newInstance(2019, 9, 28),
        CustomZipCode__c = true,
        AdsE_Genre_s__c  = 'All Networks;Sports',
        AdsE_Network__c = 'AMC;HGTV;ESPN APP;FOX');

        insert dcc;

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
                AdsE_Genre_s__c =  (n == 'FOX')  ? 'All Networks' : 'All Networks;Sports',
                ActiveNetwork__c  = (n != 'FOX') ? true : false
            ));   
            
            

        }

        insert networkList;

    }

    @isTest
    static void TestMethod_SendData(){

        Test.startTest();

            Digital_Campaign__c dcc = [SELECT id, Name FROM Digital_Campaign__c LIMIT 1];

            Test.setMock(HttpCalloutMock.class, new OMSHttpCalloutMock(dcc.id));    
            OMS_MiddlwareController.StatusCode = 200;

            OMSHelper.SendData(dcc.id);

        Test.stopTest();
    }

    @isTest
    static void TestMethod_SendToMiddleware(){

        Test.startTest();
		Digital_Campaign__c dcc = [SELECT id, Name FROM Digital_Campaign__c LIMIT 1];
        string json = '{ "Test" : "Test"  }';
        Test.setMock(HttpCalloutMock.class, new OMSHttpCalloutMock(dcc.Id));   

        String result = OMSHelper.SendToMiddleware(json);
  
        System.assert(result.contains('test.com'));
    
        Test.stopTest();

    }


    @isTest
    static void TestMethod_prepareJSONDataToOMS(){

       Test.startTest();

        Digital_Campaign__c dcc = [SELECT id,
               Name,
               RecordTypeId, RecordType.Name,
               Status__c,
               Advertiser__c, Advertiser__r.Name,
               Agency__c, Agency__r.Name,
               Rep_Firm_Text__c, Opportunity__r.Rep_Firm__c,
               Product_Type__c,
               Digital_Campaign_ID__c,
               TIM_ID__c,
               Campaign_Name__c,
               Campaign_Start_Date__c, Campaign_End_Date__c,
               Total_Impressions__c,
               Gross_CPM1__c,
               Gross_CPM__c,
               Rate_Classification__c,
               VAST_Tag__c,
               AdsE_Platform_s__c,
               Kids_Network_Exclusion__c,
               Tune_In_Exclusions__c,
               AdsE_Network__c,
               AdsE_Genre_s__c,
               DMAs__c,
               OwnerId, Owner.LastName, Owner.FirstName, Owner.Email,
               Sales_Office__c,
               LastModifiedById, LastModifiedBy.Name,
               CustomZipCode__c, Zip_Codes__c,
               State__c,
               Spectrum_Reach_Zones__c,
               Proposal__c,
               Frequency_Cap__c,
               Opportunity__r.Enterprise_Account_Type__c,
               Proposal__r.TIM_System__c,
               Proposal__r.Traffic_Order_Number__c,
               Advertiser__r.Political_Account__c,
               Is_Freewheel_FF_OTT_Primary__c,
               Streaming_TV_Old_Process__c,
               AudienceTrak_Proposal_ID__c,
               Gross_Campaign_Cost__c,
               Makegood_Campaign_CPM__c,
               Makegood_Impressions__c,
               Product_Vendor__c,
               News_Network_Exclusions__c,
               Makegood_CPM__c,
               Data_Catalog__c,
               Program_Type__c,
               Day_of_Week__c,
               Content_Type__c,
               TIG_Network__c,
               Season__c,
               Episode__c,
               Live_In_Telecast__c,
               Advanced_Customizations__c,
               Eclipse_Customer_ID__c,
               Export_Key_Logic__c,
               Audience_Profile__c,
               Advanced_Reporting__c,CreatedById,
               Exclude_Networks__c,Full_Avail_Campaign__c,Pilot_Order_ID__c,TIG_Activated__c,       
               Operative_Sales_Order_Hyperlink__c,Efficiency_Packages__c,Preemptable__c,Time_Zones__c,Device_Exclusions__c,
               (select id,Audience__c,Campaign_Start_Date__c,Campaign_End_Date__c,COST_Gross__c,CPM_Gross__c,
                Digital_Campaign__c,Error_Message__c,Geo_Target_Type__c,Impressions__c,Industry__c,
                Inventory_Resource_Type__c,Name,Line_Item_Id__c,Notes__c,SFDC_DC_Type__c,Exclusions__c
                from Inventory_Sources__r)
               FROM Digital_Campaign__c limit 1];


        string json = OMSHelper.prepareJSONDataToOMS(dcc);

        OMSHelperTest.JsontestData data = (OMSHelperTest.JsontestData)System.JSON.deserialize(json, OMSHelperTest.JsontestData.class);

        //System.assertEquals('Cox Toyota Ads E 2019 (December) - New Ads Everywhere', data.Campaign_Name);
        //System.assertEquals(dcc.RecordTypeId, data.Record_Type);


        Test.stopTest();
        
    }

    public class JsontestData {
        public string Record_Type {get; set;}
        public string Campaign_Name {get; set;}
    }

    @isTest
    static void TestMethod_getEclipseInstanceAndId(){

        Test.startTest();

        Account acct = new Account(Name ='TAccount1');
        insert acct;

        Traffic_Id_Element__c trafficElement = new Traffic_Id_Element__c( Account_TIM_ID__c = '208921', ExportSystem_Name__c = 'TWOH', 
                                                                         Account_Type__c = 'Advertiser',
                                                                         Traffic_Id__c = '500029283',
                                                                         Account__c =  acct.id);

        insert trafficElement;

        String eclipseInstance = OMSHelper.getEclipseInstanceAndId(acct.id);


        System.assertEquals('TWOH-500029283', eclipseInstance);

        eclipseInstance =  OMSHelper.getEclipseInstanceAndId('');

        System.assertEquals('', eclipseInstance);

        Test.stopTest();
    }

    @isTest
    static void TestMethod_stringCoalesce(){


        Test.startTest();

            string nullString = null;
            string testString = 'Test';

            string nullResult = OMSHelper.stringCoalesce(nullString);
            string testResult = OMSHelper.stringCoalesce(testString);

            System.assertEquals(nullResult, '');
            System.assertEquals(testString, testResult);


        Test.stopTest();

    }

    @isTest
    static void  TestMethod_dateCoalesce(){

        Test.startTest();

            date nullDate = null;
            date testDate = date.parse('12/27/2009');

            string nullResult = OMSHelper.dateCoalesce(nullDate);
            string testResult = OMSHelper.dateCoalesce(testDate);

            
            System.assertEquals(nullResult, '');
            System.assertEquals(testDate.format(), testResult);


        Test.stopTest();
    }


    @isTest
    static void TestMethod_cleanseFirstName(){

        Test.startTest();

        string UNKNOWN = 'UNKNOWN';
        string FirstName1 = '';
        string FirstName2 = null;
        string FirstName3 = 'John';

        string FirstnName1Result = OMSHelper.cleanseFirstName(FirstName1);

        System.assertEquals(UNKNOWN, FirstnName1Result);

        string FirstnName2Result = OMSHelper.cleanseFirstName(FirstName2);

        System.assertEquals(UNKNOWN, FirstnName2Result);
 
        string FirstnName3Result = OMSHelper.cleanseFirstName(FirstName3);

        System.assertEquals(FirstName3, FirstnName3Result);

        Test.stopTest();
    }


    @isTest
    static void TestMethod_Get15DigitId(){

        Test.startTest();

         Digital_Campaign__c dcc = [SELECT id, Name FROM Digital_Campaign__c LIMIT 1];

        string result    = OMSHelper.Get15DigitId(dcc.id);
        string fifteenId = dcc.id;

         System.assertEquals(fifteenId.substring(0, 15), result);
         System.assertEquals(15, result.length());

         string fifteenDigit =  OMSHelper.Get15DigitId(result);

         System.assertEquals(result, fifteenDigit);

        Test.stopTest();
    }

    private static final string TEST_EMAIL_TEXT = 'Test email: ';

    @isTest
    static void TestMethod_validateEmail_isValid(){

        Test.startTest();

        String email  = 'coffee.shop@charter.com';
        String email2 = 'kelly.a.hernandez@charter.com';

        Boolean emailResult  = OMSHelper.validateEmail(email);
        Boolean emailResult2 = OMSHelper.validateEmail(email2);

        System.assertEquals(true, emailResult, TEST_EMAIL_TEXT + email);
        System.assertEquals(true, emailResult2, TEST_EMAIL_TEXT + email);

        Test.stopTest();

    }



    @isTest
    static void TestMethod_validateEmail_isNotValid(){

        Test.startTest();

        String email1 = 'hldactnational.cincinnat=charter.com@fixme.com';
        String email2 = 'email@example@example.com';
        String email3 = 'email@111.222.333.44444';
        String email4 = 'Joe Smith <email@example.com>';


        Boolean testEmail1 = OMSHelper.validateEmail(email1);
        System.assertEquals(false, testEmail1, TEST_EMAIL_TEXT + email1);

        Boolean testEmail2 = OMSHelper.validateEmail(email2);
        System.assertEquals(false, testEmail2, TEST_EMAIL_TEXT + email2);

        Boolean testEmail3 = OMSHelper.validateEmail(email3);
        System.assertEquals(false, testEmail3, TEST_EMAIL_TEXT + email3);
    
        Boolean testEmail4 = OMSHelper.validateEmail(email4);
        System.assertEquals(false, testEmail4, TEST_EMAIL_TEXT + email4);


        Test.stopTest();

    }

    @isTest 
     static void TestMethods_getInvalidNetworks_And_validNetworks(){


        Test.startTest();

        Digital_Campaign__c objDC = [SELECT Id, AdsE_Network__c FROM Digital_Campaign__c LIMIT 1];

        List<string> adseNetworks = objDC.AdsE_Network__c.split(';');

        OMS_NetworkValidationClass networkvalidation = OMSHelper.getInvalidNetworks(adseNetworks);


        String invalidNetworks  = String.join(networkvalidation.InvalidNetworks, ';');
        String inActiveNetworks = String.join(networkvalidation.InActiveNetworks, ';');

        System.assertEquals(invalidNetworks, 'ESPN APP');
        System.assertEquals(inActiveNetworks, 'FOX');
 

        List<string> validNetworks = OMSHelper.validNetworks(networkvalidation, adseNetworks);


        Test.stopTest();


     }

     @isTest
     static void TestMethod_getInvalidNetworksBysGenre(){

        Test.startTest();

            string FoxNetwork = 'FOX';

            Digital_Campaign__c objDC = [SELECT Id, 
                                          AdsE_Network__c,
                                          AdsE_Genre_s__c FROM 
                                          Digital_Campaign__c LIMIT 1];

            List<string> invalidNetworksByGenreList = OMSHelper.getInvalidNetworksBysGenre(objDC);

            System.assert(invalidNetworksByGenreList.size() > 1);
            System.assert(invalidNetworksByGenreList.contains(FoxNetwork));


        Test.stopTest();

     }

     @isTest
    static void TestMethod_getCleanInvalidNetworks(){


        Test.startTest();

            List<string> networks  = new List<String>{
                'A&E Network'
                ,'AMC'
                ,'Bravo'
                ,'Cartoon Network'
                ,'Comedy Central'
                ,'Discovery Channel'
                ,'Disney XD'
                ,'E!'
                ,'Food Network'
                ,'FX'
                ,'HGTV' };

                String AMC_Network   = 'AMC';
                String Bravo_Network = 'Bravo';

                List<string> excludeNetworks = new List<String>{AMC_Network, Bravo_Network};
                List<string> result          = OMSHelper.getCleanInvalidNetworks(excludeNetworks, networks);


                System.assert(!result.contains(AMC_Network));
                System.assert(!result.contains(Bravo_Network));

        Test.stopTest();

    }

    @isTest 
    static void TestMethod_getFligthDatesEnd(){

        string flightDates = '2020-03-02:2020-03-06;2020-03-02:2020-03-10;2020-03-02:2020-03-18;';
        
        List<string> campaignEndDate = OMSHelper.GetListOfFligthEndDates(flightDates);
     
        System.assertEquals(campaignEndDate[0], '2020-03-06');
        System.assertEquals(campaignEndDate[1], '2020-03-10');
        System.assertEquals(campaignEndDate[2], '2020-03-18');
        
    }


    @isTest 
    static void TestMethod_getFligthDatesEnd_WithBadValue(){

        string flightDates = '2020-03-02:2020-03-06;2020-03-02:2020-03-10;2020-03-02:2020-03-18;2020-03-02';
        
        List<string> campaignEndDate = OMSHelper.GetListOfFligthEndDates(flightDates);
     
        System.assertEquals(campaignEndDate[0], '2020-03-06');
        System.assertEquals(campaignEndDate[1], '2020-03-10');
        System.assertEquals(campaignEndDate[2], '2020-03-18');
        System.assertEquals(campaignEndDate[3], '');
        
    }

    @isTest 
    static void TestMethod_ConvertoDate(){

        string flightDates = '2020-03-02:2020-03-06;2020-03-02:2020-03-10;2020-03-02:2020-03-18;';

        List<string> campaignEndDate = OMSHelper.GetListOfFligthEndDates(flightDates);
        List<Date> dateList          =  OMSHelper.ConvertoDateSorted(campaignEndDate);

        System.assertEquals(dateList[0], date.valueOf('2020-03-06'));
        System.assertEquals(dateList[1], date.valueOf('2020-03-10'));
        System.assertEquals(dateList[2], date.valueOf('2020-03-18'));

    }

    @isTest 
    static void TestMethod_ConvertoDate_WithBadValue(){

        string flightDates = '2020-03-02:2020-03-06;2020-03-02:2020-03-10;2020-03-02:2020xxx;';

        List<string> campaignEndDate = OMSHelper.GetListOfFligthEndDates(flightDates);
        List<Date> dateList          = OMSHelper.ConvertoDateSorted(campaignEndDate);

        System.assert(dateList.size() == 2);

        System.assertEquals(dateList[0], date.valueOf('2020-03-06'));
        System.assertEquals(dateList[1], date.valueOf('2020-03-10'));

    }

    @isTest
    static void TestMethod_GetListOfFligthStartDates(){

        string flightDates = '2020-03-02:2020-03-06;2020-03-06:2020-03-10;2020-03-10:2020-03-18;';
        
        List<string> campaignEndDate = OMSHelper.GetListOfFligthStartDates(flightDates);
        
        System.assertEquals(campaignEndDate[0], '2020-03-02');
        System.assertEquals(campaignEndDate[1], '2020-03-06');
        System.assertEquals(campaignEndDate[2], '2020-03-10');

    }

}