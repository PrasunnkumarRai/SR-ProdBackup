@isTest
public class OMS_MiddlwareControllerTest {
  
    @testSetup
    private static void CreateTestData(){
       
        RecordType recordType = [SELECT id, Name FROM RecordType 
                                 WHERE Name = 'New Ads Everywhere' 
                                 AND SobjectType = 'Digital_Campaign__c' LIMIT 1];


        Profile p = [SELECT Id FROM Profile WHERE Name='Master - Digital Operations']; 
        User user = new User(Alias = 'LeBron', Email='lebron.james@charter.com', 
                            FirstName = 'Lebron', LastName='Jame',
                            EmailEncodingKey='UTF-8',  LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='lebron.james@testorg.com');

        insert user;



        Digital_Campaign__c dcc = new Digital_Campaign__c( 
        Status__c                   = OMS_MiddlwareController.SubmittedDigOps, 
        RecordTypeId                = recordType.Id,
        Rep_Firm_Text__c            = '', 
        Product_Type__c             = 'National Addressable', 
        Campaign_Name__c            = 'Cox Toyota Ads E 2019 (December) - New Ads Everywhere',
        Campaign_Start_Date__c      =   Date.newInstance(2020, 9, 20), 
        Campaign_End_Date__c        = Date.newInstance(2020, 9, 28),
        OwnerId                     = user.id, 
        Rate_Classification__c      = 'Paid',
        AdsE_Network__c             = 'ESPN APP;AMC',
        AdsE_Platform_s__c          = 'All Platforms',
        Streaming_TV_Old_Process__c = false, 
        DMAs__c = 'ALBANY - GA',
        Flight_Dates_Backend__c     = '2020-09-20:2020-09-22;2020-09-22:2020-09-24;2020-09-24:2020-09-28;');
        
        insert dcc;

        OMS_Settings__c omsSalesOrder = new OMS_Settings__c(Name = 'Operative Submit', Endpoint_URL__c = 'http://3.214.70.103:8083/api/OMS/ProcessSalesOrder' ); 
        insert omsSalesOrder;

        OMS_Settings__c omsRevision = new OMS_Settings__c(Name = 'Operative Revision', Endpoint_URL__c = 'http://3.214.70.103:8083/api/OMS/ProcessRevisedSalesOrder' ); 
        insert omsRevision;

        OMS_Settings__c omsStatus = new OMS_Settings__c(Name = 'Set DCC Status', Endpoint_URL__c = 'http://3.214.70.103:8083/SetSubmissionStatus' ); 
        insert omsStatus;


        List<OMS_Settings__c> mappingEmailList = new List<OMS_Settings__c>();
        mappingEmailList.Add(new OMS_Settings__c(Name = 'test@chater.com',  Category__c = 'MappingEmail', Value__c = 'test@chater.com')); 
        mappingEmailList.Add(new OMS_Settings__c(Name = 'test2@chater.com', Category__c = 'MappingEmail', Value__c = 'test2@chater.com')); 
   
        insert mappingEmailList;

        List<Networks__c> netwworks = new List<Networks__c>();
        netwworks.add(new Networks__c(Name = 'AMC', Call_Letter__c = 'AMC', 
                                    AdsE_Genre_s__c ='All Networks;Men/Sports;Selected Networks',
                                    Kids_Network_Exclusion__c = false,  Tune_In_Exclusions__c = false,
                                    ActiveNetwork__c = true));
        netwworks.add(new Networks__c(Name = 'ESPN', Call_Letter__c = 'ESPN', 
                                     AdsE_Genre_s__c ='All Networks;Men/Sports;Selected Networks',
                                     Kids_Network_Exclusion__c = false,  Tune_In_Exclusions__c = false ,
                                      ActiveNetwork__c = true));
        netwworks.add(new Networks__c(Name = 'Bravo', Call_Letter__c = 'Bravo', 
                                     AdsE_Genre_s__c ='All Networks;Women/Entertainment;Selected Networks',
                                     Kids_Network_Exclusion__c = false,  Tune_In_Exclusions__c = false,     
                                     ActiveNetwork__c = false ));    

        insert netwworks;


        List<Inventory_Source__c> inventoryList = new List<Inventory_Source__c>();
        inventoryList.add(new Inventory_Source__c(Line_Item_Id__c = null,  Digital_Campaign__c = dcc.id,
        Campaign_Start_Date__c = Date.newInstance(2021, 11, 01), Exclusions__c = 'None', SFDC_DC_Type__c = 'Ads Everywhere', Inventory_Resource_Type__c = 'Freewheel-FF OTT', Impressions__c = 100));
        inventoryList.add(new Inventory_Source__c(Line_Item_Id__c = null, Digital_Campaign__c = dcc.id,  
        Campaign_Start_Date__c = Date.newInstance(2021, 11, 01), Exclusions__c = 'None', SFDC_DC_Type__c = 'Pre Roll Custom',Inventory_Resource_Type__c = 'Freewheel-FF TVE', Impressions__c = 100 ));


        insert inventoryList;

        TestUtil.prepareUser();
    }

    // *******************************************
    // Start Test Cases on Send data Method 
  
    @isTest
    private static void Test_SendData_Method_DCC_Not_Found(){

        Test.startTest();
     	Digital_Campaign__c dcc = [SELECT id, Name FROM Digital_Campaign__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new OMSHttpCalloutMock(dcc.Id));    
        OMS_MiddlwareController.StatusCode = 200;

        string json = OMS_MiddlwareController.SendData('xxxx');

        OMSMiddlewareClass oms =  (OMSMiddlewareClass)System.JSON.deserialize(json, OMSMiddlewareClass.class);

        //System.assertEquals('Digital Campaign is not found', oms.Message, 'Digital Campaign is not found');

        Test.stopTest();
    }

    
    @isTest
    private static void Test_isYisfValid_Method_IsTrue(){

        Test.startTest();

        Digital_Campaign__c dc = [SELECT id, Streaming_TV_Old_Process__c FROM Digital_Campaign__c LIMIT 1];



        List<Inventory_Source__c> invSource = [SELECT id, Line_Item_Id__c, Impressions__c, Campaign_Start_Date__c  FROM Inventory_Source__c];


        for(Inventory_Source__c inv : invSource){

            inv.Campaign_Start_Date__c = Date.newInstance(2030, 11, 01);
            inv.Impressions__c         = 100;
            inv.Line_Item_Id__c        = 'Test';

        }
 
        
        update invSource;

        Boolean result = OMS_MiddlwareController.isYisfValid(dc.id);

        //System.assertEquals(true, result);

        Test.stopTest();

    }

    @isTest
    private static void Test_isYisfValid_Method_IsFalse(){

        Test.startTest();

        Digital_Campaign__c dc = [SELECT id, Streaming_TV_Old_Process__c FROM  Digital_Campaign__c LIMIT 1];

        Boolean result = OMS_MiddlwareController.isYisfValid(dc.id);
    
        //System.assertEquals(true, result);

        Test.stopTest();
    }


    @isTest
    private static void Test_SendData_Method_ThrowException(){

        Test.startTest();

        Digital_Campaign__c dcc = [SELECT id, Name FROM Digital_Campaign__c LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new OMSHttpCalloutMock(dcc.Id));    
        OMS_MiddlwareController.StatusCode = 400;

        OMS_MiddlwareController.ThrowException = true;

        string json = OMS_MiddlwareController.SendData(dcc.id);
        OMSMiddlewareClass oms = (OMSMiddlewareClass)System.JSON.deserialize(json, OMSMiddlewareClass.class);

        //System.assertEquals(false, oms.isValid);

        Test.stopTest();
    }


    @isTest
    private static void Test_SendData_WithNoNetworks(){

        Test.startTest();
    
            Digital_Campaign__c dcc = [SELECT id, Name, Status__c, Rate_Classification__c FROM Digital_Campaign__c LIMIT 1];

            dcc.Status__c              = '03 Submitted to Digital Ops';
            dcc.Rate_Classification__c = 'Paid';
            dcc.AdsE_Platform_s__c     = 'OTT Extension';
            dcc.AdsE_Network__c        = null;
            update dcc;

            Test.setMock(HttpCalloutMock.class, new OMSHttpCalloutMock(dcc.Id));    
          
            OMS_MiddlwareController.StatusCode      = 200;
            OMS_MiddlwareController.OverrideProfile = false;
            OMS_MiddlwareController.ThrowException  = false;

            string json = OMS_MiddlwareController.SendData(dcc.id);

            OMSMiddlewareClass oms = (OMSMiddlewareClass)System.JSON.deserialize(json, OMSMiddlewareClass.class);

            //System.assertEquals(true, oms.isValid);

            System.debug(oms.Message);

        Test.stopTest();
    }


    @isTest
    private static void Test_SendData_Method_With_Rate_Method(){

        Test.startTest();
    

        Digital_Campaign__c dcc = [SELECT id, Name, Status__c, Rate_Classification__c FROM Digital_Campaign__c LIMIT 1];

        dcc.Status__c              = '03 Submitted to Digital Ops';
        dcc.Rate_Classification__c = 'Paid';
        update dcc;

        Test.setMock(HttpCalloutMock.class, new OMSHttpCalloutMock(dcc.Id));    
        OMS_MiddlwareController.StatusCode = 200;

        OMS_MiddlwareController.OverrideProfile = false;
        OMS_MiddlwareController.ThrowException = false;

        string json = OMS_MiddlwareController.SendData(dcc.id);

        OMSMiddlewareClass oms =  (OMSMiddlewareClass)System.JSON.deserialize(json, OMSMiddlewareClass.class);

        //System.assertEquals(true, oms.isValid, 'Payload with Rate Card');

        Test.stopTest();
    }

    @isTest
    private static void Test_SendData_Method_With_Rate_And_Invalid_User_Method(){

        Test.startTest();
 
            Digital_Campaign__c dcc = [SELECT id, Name, Rate_Classification__c FROM Digital_Campaign__c LIMIT 1];
            dcc.Rate_Classification__c = 'Paid';

            update dcc;

            Test.setMock(HttpCalloutMock.class, new OMSHttpCalloutMock(dcc.Id));    
            OMS_MiddlwareController.StatusCode = 200;
            OMS_MiddlwareController.OverrideProfile = true;

            string json = OMS_MiddlwareController.SendData(dcc.id);

            OMSMiddlewareClass oms =  (OMSMiddlewareClass)System.JSON.deserialize(json, OMSMiddlewareClass.class);

            //System.assertEquals(false, oms.isValid, 'Invalid User');

         

        Test.stopTest();
    }

    @isTest
    private static void Test_SendData_Method_With_Status_400(){

        Test.startTest();

        
            Digital_Campaign__c dcc = [SELECT id, Name, Rate_Classification__c FROM Digital_Campaign__c LIMIT 1];
            dcc.Rate_Classification__c = 'Paid';

            update dcc;

            Test.setMock(HttpCalloutMock.class, new OMSHttpCalloutMock(dcc.Id));    
            OMS_MiddlwareController.StatusCode = 400;


            string json = OMS_MiddlwareController.SendData(dcc.id);

            OMSMiddlewareClass oms =  (OMSMiddlewareClass)System.JSON.deserialize(json, OMSMiddlewareClass.class);

            //System.assertEquals(false, oms.isValid, 'Invalid');

        Test.stopTest();
    }


    @isTest
    private static void Test_SendData_Method_With_Status_409(){

        Test.startTest();

        
            Digital_Campaign__c dcc = [SELECT id, Name, Rate_Classification__c FROM Digital_Campaign__c LIMIT 1];
            dcc.Rate_Classification__c = 'Paid';

            update dcc;

            Test.setMock(HttpCalloutMock.class, new OMSHttpCalloutMock(dcc.Id));    
            OMS_MiddlwareController.StatusCode = 409;


            string json = OMS_MiddlwareController.SendData(dcc.id);

            OMSMiddlewareClass oms =  (OMSMiddlewareClass)System.JSON.deserialize(json, OMSMiddlewareClass.class);

            //System.assertEquals(false, oms.isValid, 'Invalid');

        Test.stopTest();
    }

    @isTest
    private static void Test_SendData_Method_With_Non200Call(){

        Test.startTest();

        
            Digital_Campaign__c dcc = [SELECT id, Name, Rate_Classification__c FROM Digital_Campaign__c LIMIT 1];
            dcc.Rate_Classification__c = 'Paid';

            update dcc;

            Test.setMock(HttpCalloutMock.class, new OMSHttpCalloutMock(dcc.Id));    
            OMS_MiddlwareController.StatusCode = 500;


            string json = OMS_MiddlwareController.SendData(dcc.id);

            OMSMiddlewareClass oms =  (OMSMiddlewareClass)System.JSON.deserialize(json, OMSMiddlewareClass.class);

            //System.assertEquals(false, oms.isValid, 'Invalid');

        Test.stopTest();
    }


    // End Test Cases on Send data Method 
    // *******************************************


    @isTest
    private static void Test_UpdateToSuccess_Method(){

        Test.startTest();
         
            Digital_Campaign__c dcc = [SELECT id, Name, Rate_Classification__c FROM Digital_Campaign__c LIMIT 1];

            Test.setMock(HttpCalloutMock.class, new OMSHttpCalloutMock(dcc.Id));    
            OMS_MiddlwareController.StatusCode = 200;

            String operativeId = '1234';

            OMS_MiddlwareController.UpdateToSuccess(dcc.id, operativeId);

        Test.stopTest();
    }

    @isTest
    private static void Test_UpdateToError_Method(){


        Test.startTest();
        
            Digital_Campaign__c dcc = [SELECT id, Name, Rate_Classification__c FROM Digital_Campaign__c LIMIT 1];

            Test.setMock(HttpCalloutMock.class, new OMSHttpCalloutMock(dcc.Id));    
            OMS_MiddlwareController.StatusCode = 200;

            String errorMsg = 'Error Message';

            OMS_MiddlwareController.UpdateToError(dcc.id, errorMsg);

        Test.stopTest();
    }

    @isTest
    private static void Test_getMasterDigOpsUser_Method(){

       Test.startTest();

        set<string>  masterOps =  OMS_MiddlwareController.getMasterDigOpsUser();

        Boolean isTrue = masterOps.contains('Master - Digital Coordinator');
        //System.assertEquals(true, isTrue);

       Test.stopTest();
    }
    
    @isTest
    private static void Test_AllowSubmission_Method(){

        Test.startTest();

        OMS_Settings__c oms = new OMS_Settings__c(Name='System Administrator', Category__c = 'AllowSubmit');

        insert oms;

        Boolean allowSubmissionsTrue = OMS_MiddlwareController.AllowSubmission();

        //System.assertEquals(true, allowSubmissionsTrue);

        oms.Name = 'xxx';

        update oms;

        Boolean allowSubmissionsFalse = OMS_MiddlwareController.AllowSubmission();

         //System.assertEquals(false, allowSubmissionsFalse);

        Test.stopTest();
    }

    // *******************************************
    // Start Test Cases on validationOMSPayload data Method 
  

    @isTest
    private static void Test_validationOMSPayload_Method(){

        Test.startTest();

        Digital_Campaign__c dc = [SELECT id FROM Digital_Campaign__c LIMIT 1 ];
 
        string result = OMS_MiddlwareController.validationOMSPayload(dc.id);

        OMSMiddlewareClass omsClass = (OMSMiddlewareClass)System.JSON.deserialize(result, OMSMiddlewareClass.class);

        //System.assertEquals(true, omsClass.isValid);
        //System.assertEquals('No Validation Issues', omsClass.Message);

        Test.stopTest();
    }

     @isTest
     private static void Test_validationOMSPayload_InvalidEmail(){

            Test.startTest();

                Profile p = [SELECT Id FROM Profile WHERE Name='Master - Digital Operations']; 

                 User user = new User(Alias = 'LeBron', Email='lnew.jo@charter.com.invalid', 
                            FirstName = 'Jose', LastName = 'New',
                            EmailEncodingKey='UTF-8',  LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='new.joe@testorg.com.invalid');

                insert user;

                Digital_Campaign__c dc = [SELECT id, OwnerId FROM Digital_Campaign__c LIMIT 1];
                dc.OwnerId = user.id;
                update dc;

                string message = 'The Digital Campaign  Owner ' + user.FirstName  + ' ' +  user.LastName + 
                                ' has an invalid email address. Please correct the email address ' +  user.Email;

                
                string json = OMS_MiddlwareController.validationOMSPayload(dc.id);

                OMSMiddlewareClass oms = (OMSMiddlewareClass)System.JSON.deserialize(json, OMSMiddlewareClass.class);

                //System.assertEquals(false, oms.isValid);
                //System.assertEquals(message, oms.Message);

            Test.stopTest();
     }

     @isTest
     private static void Test_validationOMSPayload_Without_Rate_Method(){

        Test.startTest();
    
        Digital_Campaign__c dcc = [SELECT id, Name, Rate_Classification__c FROM Digital_Campaign__c LIMIT 1];
        dcc.Rate_Classification__c = null;
        update dcc;


        string json = OMS_MiddlwareController.validationOMSPayload(dcc.id);

        OMSMiddlewareClass oms =  (OMSMiddlewareClass)System.JSON.deserialize(json, OMSMiddlewareClass.class);

        //System.assertEquals(false, oms.isValid);
        //System.assertEquals('Please select a rate classification', oms.Message, 'Payload without Rate Card');

        Test.stopTest();
     }

    @isTest
    private static void Test_validationOMSPayload_InvalidStatus(){

        Test.startTest();
        
            Digital_Campaign__c dcc = [SELECT id, Status__c FROM Digital_Campaign__c LIMIT 1];
            dcc.Status__c = 'Draft Plan';

            update dcc;

            string json = OMS_MiddlwareController.validationOMSPayload(dcc.id);
            OMSMiddlewareClass oms = (OMSMiddlewareClass)System.JSON.deserialize(json, OMSMiddlewareClass.class);

            //System.assertEquals(false, oms.isValid);
            //System.assertEquals('Digital Campaign status must be following status <br />03 Submitted to Digital Ops <br />3.1 DC Submission Error<br/>13 Revision Submitted to Digital Ops<br/>13.1 DC Revision Submission Error', oms.Message, 'Invalid Status');


        Test.stopTest();
    }

    @isTest
    private static void Test_validationOMSPayload_NoPlatform(){

        Test.startTest();
        
            Digital_Campaign__c dcc = [SELECT id, AdsE_Platform_s__c FROM Digital_Campaign__c LIMIT 1];
            dcc.AdsE_Platform_s__c = null;

            update dcc;

        

            string json = OMS_MiddlwareController.validationOMSPayload(dcc.id);
            OMSMiddlewareClass oms = (OMSMiddlewareClass)System.JSON.deserialize(json, OMSMiddlewareClass.class);

            //System.assertEquals(false, oms.isValid);
            //System.assertEquals('There are no platforms selected', oms.Message, 'No Platform');


        Test.stopTest();
    }

    @isTest
    private static void Test_validationOMSPayload_Exception(){

        Test.startTest();
        
            Digital_Campaign__c dcc = [SELECT id, AdsE_Platform_s__c FROM Digital_Campaign__c LIMIT 1];
        
            update dcc;

            OMS_MiddlwareController.ThrowException = true;     

            string json = OMS_MiddlwareController.validationOMSPayload(dcc.id);
            OMSMiddlewareClass oms = (OMSMiddlewareClass)System.JSON.deserialize(json, OMSMiddlewareClass.class);

            //System.assertEquals(false, oms.isValid);
            //System.assertEquals('Test Exception', oms.Message, 'Exception Test');


        Test.stopTest();
    }


         // End Test Cases on Send data Method 
    // *******************************************

    @isTest
    private static void Test_UpdateNetwork(){

         Test.startTest();

         Digital_Campaign__c dc = [SELECT id, AdsE_Platform_s__c, AdsE_Genre_s__c FROM Digital_Campaign__c LIMIT 1];

         OMS_MiddlwareController.UpdateNetwork(dc.id);

         Test.stopTest();

    }
    
    @isTest
    private static void Test_CheckFlightDates(){

        Test.startTest();

        Digital_Campaign__c dc = [SELECT id, Name, Campaign_End_Date__c, Flight_Dates_Backend__c FROM Digital_Campaign__c LIMIT 1];

         string json = OMS_MiddlwareController.CheckFlightDates(dc.id);

         OMSMiddlewareClass oms = (OMSMiddlewareClass)System.JSON.deserialize(json, OMSMiddlewareClass.class);

         //System.assertEquals(oms.isValid, true);
         //System.assertEquals(oms.Message, 'No Validation Issues');

        Test.stopTest();
    }

    @isTest
    private static void Test_CheckFlightDates_WithNoFlightDates(){

        Test.startTest();

        Digital_Campaign__c dc = [SELECT id, Name, Campaign_End_Date__c, Flight_Dates_Backend__c FROM Digital_Campaign__c LIMIT 1];

        dc.Flight_Dates_Backend__c = null;
        
        update dc;

         string json = OMS_MiddlwareController.CheckFlightDates(dc.id);

         OMSMiddlewareClass oms = (OMSMiddlewareClass)System.JSON.deserialize(json, OMSMiddlewareClass.class);

         //System.assertEquals(oms.isValid, true);
         //System.assertEquals(oms.Message, 'No Validation Issues');

        Test.stopTest();
    }


    @isTest
    private static void Test_CheckFlightDates_WithInvalidCampaignID(){

        Test.startTest();

         string id = 'xxxx';
    
         string json = OMS_MiddlwareController.CheckFlightDates('xxxx');

         OMSMiddlewareClass oms = (OMSMiddlewareClass)System.JSON.deserialize(json, OMSMiddlewareClass.class);

         //System.assertEquals(oms.isValid, false);
         //System.assertEquals(oms.Message, 'Campaign ID cannot be id ' + id + ' cannot be found');

         Test.stopTest();
    }


    @isTest
    private static void Test_CheckFlightDates_FlightEndDateIsBehind(){

        Test.startTest();

       // Digital_Campaign__c dc = [SELECT id, Name, Campaign_End_Date__c, Flight_Dates_Backend__c FROM Digital_Campaign__c LIMIT 1];
        //dc.Campaign_End_Date__c = Date.newInstance(2020, 3, 30);
        //dc.Flight_Dates_Backend__c = '2020-03-20:2020-03-22;2020-03-22:2020-03-24;2020-03-24:2020-03-27';
       
       // insert dc;

         string json = OMS_MiddlwareController.CheckFlightDates('a084C000006KmnDQAS');

         OMSMiddlewareClass oms = (OMSMiddlewareClass)System.JSON.deserialize(json,OMSMiddlewareClass.class);

         //System.assertEquals(oms.isValid, false);
         //System.assertEquals(oms.Message, OMS_MiddlwareController.FlightDateIsBehindMsg);

         Test.stopTest();
    }


    @isTest
    private static void Test_CheckFlightDates_FlightEndDateIsAhead(){

        Test.startTest();

        //Digital_Campaign__c dc = [SELECT id, Name, Campaign_End_Date__c, Flight_Dates_Backend__c FROM Digital_Campaign__c LIMIT 1];
       // dc.Campaign_End_Date__c = Date.newInstance(2020, 3, 30);
       // dc.Flight_Dates_Backend__c = '2020-03-20:2020-03-22;2020-03-22:2020-03-24;2020-03-24:2020-04-01';
       // insert dc;

         string json = OMS_MiddlwareController.CheckFlightDates('a084C000006KmnDQAS');

         OMSMiddlewareClass oms = (OMSMiddlewareClass)System.JSON.deserialize(json,OMSMiddlewareClass.class);

         //System.assertEquals(oms.isValid, false);
         //System.assertEquals(oms.Message, OMS_MiddlwareController.FlightDateIsAheadMsg);

         Test.stopTest();

    }

      @isTest
      private static void Test_CheckFlightDates_ThrowException(){


        Test.startTest();

        Digital_Campaign__c dc = [SELECT id, Name, Campaign_End_Date__c, Flight_Dates_Backend__c FROM Digital_Campaign__c  LIMIT 1];
        dc.Campaign_End_Date__c = null;
        dc.Flight_Dates_Backend__c = '2020-03-20:2020-03-22;2020-03-22:2020-03-24;2020-03-24:2020-04-01';
        update dc;

        OMS_MiddlwareController.ThrowException = true;

        string json = OMS_MiddlwareController.CheckFlightDates(dc.id);

        OMSMiddlewareClass oms = (OMSMiddlewareClass)System.JSON.deserialize(json, OMSMiddlewareClass.class);

        //System.assertEquals(oms.isValid, false);
        //System.assertEquals(oms.Message, 'My DML EXCEPTION');

        Test.stopTest();

    }

    @isTest
    private static void Test_SendData_MappingError(){

        Test.startTest();
    
            Digital_Campaign__c dcc = [SELECT id, Name, Status__c, Rate_Classification__c FROM Digital_Campaign__c LIMIT 1];

            dcc.Status__c              = '03 Submitted to Digital Ops';
            dcc.Rate_Classification__c = 'Paid';
            dcc.AdsE_Platform_s__c     = 'OTT Extension';
            dcc.AdsE_Network__c        = null;
            update dcc;

            Test.setMock(HttpCalloutMock.class, new OMSHttpCalloutMockError());    
          
            OMS_MiddlwareController.StatusCode      = 400;
            OMS_MiddlwareController.OverrideProfile = false;
            OMS_MiddlwareController.ThrowException  = false;
            OMS_MiddlwareController.PayLoadMessage  = '{\"SalesOrderId\":\"123456\",\"Message\":\"Mapping Issue\",\"Exception\":null}';

            string json = OMS_MiddlwareController.SendData(dcc.id);

            OMSMiddlewareClass oms = (OMSMiddlewareClass)System.JSON.deserialize(json, OMSMiddlewareClass.class);

            //System.assertEquals(false, oms.isValid);

            System.debug(oms.Message);

        Test.stopTest();
    }

}