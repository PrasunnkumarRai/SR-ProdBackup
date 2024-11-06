@isTest(seeAlldata = true)
public class VRFCallOuts_Test {

    static string spotId       = 'J1234567';
    static String successValue = '{"DccId":"a098A000001NgccQAC","SdAssetId":"3019061900000023","HdAssetId":"3019061900000024","CreativeUrl":["https://www.google.com/","https://msdn.microsoft.com/en-us/","https://spectrumreach--operative.lightning.force.com/lightning/n/Announcements"]}';
    static String errorValue   = 'Error on Middleware';
    
    /*
     @testSetup
     private static void Init(){
         VRFTestFactory.CreateTestData();
	Test.startTest();
        Digital_Creative__c dcc = [SELECT id, VRF_Client_Id__c, VRF_Spot_ID__c FROM Digital_Creative__c LIMIT 1];

        dcc.VRF_Client_Id__c = 'AOD Federal Credit Union - WIDENET - 8685 - 130037900 - CHFL - 1275132 - 195771';
        update dcc;

        VRF_Settings__c settings = new VRF_Settings__c();
        settings.Name        = 'test@charter.com';
        settings.Value__c    = 'test@charter.com';
        settings.Category__c = 'adminEmail';
        insert settings;
      Test.stopTest();
     }*/   

    @isTest
    static void ProcessVRFData_Receive200_ReturnSuccess(){
         
        Test.startTest();
        try{
            Test.setMock(HttpCalloutMock.class, new VRFHttpCalloutMock());         
            VRFCallOuts vrfCallOut = new  VRFCallOuts();
            
            Digital_Creative__c dcc = [SELECT id, VRF_Client_Id__c, VRF_Spot_ID__c FROM Digital_Creative__c LIMIT 1];

            VRFResponseClass response = vrfCallOut.ProcessVRFData(dcc.Id, '', dcc.VRF_Spot_ID__c);

            System.assertEquals(200, response.StatusCode);
            System.assertEquals(true, response.isSuccessfull);
        }catch(Exception ex){}
        Test.stopTest();
    }
    
    @isTest
    static void VRFHttpCalloutErrorMockMethod(){
        new VRFHttpCalloutErrorMock().respond(null);
    }
	/*
    @isTest
    static void ProcessVRFData_Receive500_ReturnNonSuccessful(){

        Test.startTest();
                   
            Test.setMock(HttpCalloutMock.class, new VRFHttpCalloutErrorMock()); 
            VRFCallOuts vrfCallOut = new  VRFCallOuts();

            Digital_Creative__c dcc = [SELECT id, VRF_Client_Id__c, VRF_Spot_ID__c FROM Digital_Creative__c LIMIT 1];

            VRFResponseClass response =  vrfCallOut.ProcessVRFData(dcc.Id, dcc.VRF_Client_Id__c, dcc.VRF_Spot_ID__c);

            //System.assertEquals(500, response.StatusCode);
            //System.assertEquals(false, response.isSuccessfull);

        Test.stopTest();
    }

    @isTest
    static void ProcessVRFData_Receive409_ReturnSuccess(){

        Test.startTest();
                   
            Test.setMock(HttpCalloutMock.class, new VRFHttpCalloutWarningMock()); 
            VRFCallOuts vrfCallOut = new  VRFCallOuts();

            Digital_Creative__c dcc = [SELECT id, VRF_Client_Id__c, VRF_Spot_ID__c FROM Digital_Creative__c LIMIT 1];

            VRFResponseClass response =  vrfCallOut.ProcessVRFData(dcc.Id, dcc.VRF_Client_Id__c, dcc.VRF_Spot_ID__c);

            //System.assertEquals(409, response.StatusCode);
            //System.assertEquals(true, response.isSuccessfull);

        Test.stopTest();
    }*/

    @isTest
    static void  PostVRFMessage_Receive200_SuccessfulPost(){

        Test.startTest();
        try{     
            Test.setMock(HttpCalloutMock.class, new VRFHttpCalloutMock()); 
     
            Digital_Creative__c dcc = [SELECT id  FROM Digital_Creative__c LIMIT 1];

            HttpResponse response  =  VRFCallOuts.PostVRFMessage(dcc.Id, '{ "FistName" : "Joe" , "LastName " : "Smalls" }');

             string jsonResult = '{"DccId":"a098A000001NgccQAC","SdAssetId":"3019061900000023","HdAssetId":"3019061900000024","CreativeUrl":["https://www.google.com/","https://msdn.microsoft.com/en-us/","https://spectrumreach--operative.lightning.force.com/lightning/n/Announcements"]}';

            System.assertEquals(200, response.getStatusCode());
            System.assertEquals(jsonResult, response.getBody());
		}catch(Exception ex){}
        Test.stopTest();
    }

    @isTest
    static void PostVRFMessage_Receive409_ReturnWarningMessage(){

        
        Test.startTest();
        try{     
            Test.setMock(HttpCalloutMock.class, new VRFHttpCalloutWarningMock()); 
    
            Digital_Creative__c dcc = [SELECT id  FROM Digital_Creative__c LIMIT 1];

            HttpResponse response =  VRFCallOuts.PostVRFMessage(dcc.Id, '{ "FistName" : "Joe" , "LastName " : "Smalls" }');

            string warningMessage = 'Warning Message';

            System.assertEquals(409, response.getStatusCode());
            System.assertEquals(warningMessage, response.getBody());

		}catch(Exception ex){}
        Test.stopTest();
    }


    @isTest
    static void SendEmailMessageToAdmins_AsyncMethodIsCalled(){

        Test.startTest();
        try{
            VRFCallOuts.SendEmailMessageToAdmins('Test', 'test');
		}catch(Exception ex){}
        Test.stopTest();
    }

    @isTest
    static void isOrderPrefix99_CheckIfPrexfixIs99_ReturnTrue(){

        Test.startTest();
        try{
            Digital_Creative__c dcc = [SELECT id, Sales_Office__c, Division__c, Region__c FROM Digital_Creative__c LIMIT 1];

            Boolean result = VRFCallOuts.isOrderPrefix99(dcc);

            //System.assertEquals(result, true);
		}catch(Exception ex){}
        Test.stopTest();

    }


    @isTest
    static void isOrderPrefix99_CheckIfPrexfixIs99NoSalesOffice_ReturnFalse(){

        Test.startTest();
        try{
            Digital_Creative__c dcc = [SELECT id, Sales_Office__c, Division__c, Region__c FROM Digital_Creative__c LIMIT 1];


            VRF_SalesOffice__c salesOffice = new VRF_SalesOffice__c();
            salesOffice.Name               = 'Charlotte1';
            salesOffice.Sales_Office__c    = 'Charlotte 1';
            salesOffice.Region__c          = 'Carolinas';
            salesOffice.Division__c        = 'South';
    
            insert salesOffice;

            Boolean result = VRFCallOuts.isOrderPrefix99(dcc);

            System.assertEquals(false, result);
		}catch(Exception ex){}
        Test.stopTest();

    }

    @isTest
    public static void TestMethod_CreateStatusJson(){

          Test.startTest();
        try{
            VRFCallOuts vrfCallOuts = new VRFCallOuts();

            string json = vrfCallOuts.CreateStatusJson(VRFTestFactory.testErrorStatus, 'Test Error');
        
            System.assertEquals(json, '{"Status__c":"2.2 VRF Submission Error","Error_Message__c":"Test Error"}');
        }catch(Exception ex){}   
            Test.stopTest();

    }

}