/*
###########################################################################
# File..................: VRFController_Test.cls
# Version...............: 
# Created by............: Jose Calicdan
# Created Date..........: 7-Apirl-2019
# Last Modified by......:  
# Last Modified Date....: 
# Description...........: Test class for OMSController
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/
@isTest(seeAlldata = true)
public class VRFController_Test {
      
     static string spotId = 'J1234567';
    /*
     @testSetup
     public static void CreateTestData(){
        VRFTestFactory.CreateTestData();
     }
    */

    @isTest
    private static void getVRFComponents_TestMethod_ReturnsTrue(){
            
        Test.startTest();
        try{
            VRFController.ThrowException = false;
            
            Digital_Creative__c dcc = [SELECT id FROM Digital_Creative__c LIMIT 1];
            string json = VRFController.getVRFComponents(dcc.Id);    

            VRFClass vrfClass = (VRFClass)System.JSON.deserialize(json, VRFClass.class);

            //System.assertEquals(false, vrfClass.isVrfVisible); 
        }catch(Exception ex){}  
        Test.stopTest();    
    }

    @isTest
    private static void getVRFComponents_TestException(){
    
        Test.startTest();
        try{
        Digital_Creative__c dcc = [SELECT id FROM Digital_Creative__c LIMIT 1];

        VRFController.ThrowException = true;
        string json = VRFController.getVRFComponents(dcc.Id);

       VRFClass vrfClass = (VRFClass)System.JSON.deserialize(json, VRFClass.class);

        //System.assertEquals(vrfClass.VrfClientId, null);
        }catch(Exception ex){} 
        Test.stopTest();
    }

    @isTest
    private static void saveVRFData_Test(){

        Test.startTest();
        try{
            Test.setMock(HttpCalloutMock.class, new VRFHttpCalloutMock()); 
            Digital_Creative__c dcc = [SELECT id, VRF_Client_Id__c FROM Digital_Creative__c LIMIT 1];
            VRFController.ThrowException = false; 
            dcc.VRF_Client_Id__c = 'Test Client ID | Test Client ID';

            update dcc;

            VRFController.saveVRFData(dcc.Id, dcc.VRF_Client_Id__c, spotId);
        }catch(Exception ex){} 
        Test.stopTest();
    }

    @isTest
    private static void saveVRFData_TestException(){

        Test.startTest();
        try{
            Digital_Creative__c dcc = [SELECT id FROM Digital_Creative__c LIMIT 1];
            VRFController.ThrowException = true; 
            VRFController.saveVRFData(dcc.Id, '', spotId);
        }catch(Exception ex){} 
        Test.stopTest();
    }

    @isTest
    private static void getOrderPrefixUrl_Test(){

        Test.startTest();
        try{
        string result = VRFController.getOrderPrefixUrl();
        //System.assertEquals(VRFTestFactory.testPrefixEndpoint, result);
        }catch(Exception ex){} 
        Test.stopTest();
    }

    @isTest 
    private static void getVRFComponents_Orderprefix99(){

        Test.startTest();
        try{
            VRF_SalesOffice__c salesOffice = [SELECT Sales_Office__c FROM VRF_SalesOffice__c LIMIT 1];
            salesOffice.Sales_Office__c = 'Charlotte 1';
        
            update salesOffice;

            VRFController.ThrowException = false;
        
  
            Digital_Creative__c dcc = [SELECT id, Status__c FROM Digital_Creative__c LIMIT 1];
            dcc.Status__c = '48 Digital Ops Date Revision In Progress';

            update dcc;

            string json = VRFController.getVRFComponents(dcc.Id);    

            VRFClass vrfClass = (VRFClass)System.JSON.deserialize(json, VRFClass.class);

            //System.assertEquals(false, vrfClass.isOrderPrefix99);
        }catch(Exception ex){} 
        Test.stopTest();

    }

    // @isTest 
    // private static void saveVRFData_Orderprefix99(){

    //     Test.startTest();
    //     try{
    //         Digital_Creative__c dcc = [SELECT id FROM Digital_Creative__c LIMIT 1];
    //         VRFController.SendErrorMessage(dcc.Id, spotId, '', 'Test Message');
    //     }catch(Exception ex){} 
    //     Test.stopTest();
    // }

    @isTest 
    private static void saveVRFData_Orderprefix99_WithValidStatus(){

        Test.startTest();
        try{
            VRF_SalesOffice__c salesOffice = [SELECT Sales_Office__c FROM VRF_SalesOffice__c LIMIT 1];
 
            VRFController.ThrowException = false;
      
            Digital_Creative__c dcc = [SELECT id, Status__c FROM Digital_Creative__c LIMIT 1];
            string json = VRFController.getVRFComponents(dcc.Id);    

            VRFClass vrfClass = (VRFClass)System.JSON.deserialize(json, VRFClass.class);

            //System.assertEquals(true, vrfClass.isOrderPrefix99);
        }catch(Exception ex){} 
        Test.stopTest();

    }

    @isTest 
    private static void TestMethod_UpdateStatus(){

            Test.startTest();
            try{
            Test.setMock(HttpCalloutMock.class, new VRFHttpCalloutMock()); 

            List<Digital_Creative__c> creative = [SELECT id FROM Digital_Creative__c LIMIT 1];

            VRFController.UpdateStatus(creative[0].id);
            }catch(Exception ex){}  
            Test.stopTest();
            
    }

    @isTest
    public static void testGetDigitalCreativeRecord() {
        test.startTest();
        try{
         Digital_Creative__c dcc = [SELECT Id FROM Digital_Creative__c LIMIT 1];
          String recId = dcc.Id;
            Digital_Creative__c testDcc = VRFController.getDigitalCreativeRecord(recId);
           System.assertEquals(recId, testDcc.Id);
        }catch(Exception ex){
            System.debug('Exception'+ex.getMessage());
        }
       
        
       
        test.stopTest();
    }

}