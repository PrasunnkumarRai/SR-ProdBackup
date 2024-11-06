@isTest(seeAlldata = false)
public  class DigitalCreativeRevisionUtilTest {
   
     @testSetup
     private static void Init(){
         VRFTestFactory.CreateTestData();
     }   


    @isTest
    public static void TestMethod_SendVRFData_Status200(){

         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new VRFHttpCalloutMock()); 

         Set<Id> creatives = new Set<Id>(new Map<Id, Digital_Creative__c>([SELECT Id FROM Digital_Creative__c limit 1000]).keySet());
    
         List<Id> creativesList = new List<Id>(creatives);

         for(Id creativeRecordId : creativesList){
            System.debug('Record ID ' + creativeRecordId);
         }
  
         DigitalCreativeRevisionUtil.setStatusTo200 = true;

         DigitalCreativeRevisionUtil.SendVRFData(creativesList);

         Test.stopTest();

    }


    
    @isTest
    public static void TestMethod_SendVRFData_Status400(){

         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new VRFHttpCalloutMock()); 

         Set<Id> creatives = new Set<Id>(new Map<Id, Digital_Creative__c>([SELECT Id FROM Digital_Creative__c limit 1000]).keySet());
    
         List<Id> creativesList = new List<Id>(creatives);

         for(Id creativeRecordId : creativesList){
            System.debug('Record ID ' + creativeRecordId);
         }
  
         DigitalCreativeRevisionUtil.setStatusTo200 = false;

         DigitalCreativeRevisionUtil.SendVRFData(creativesList);

         Test.stopTest();

    }

    @isTest
    public static void TestMethod_getRevisionURL_ReturnsBlank(){

        Test.startTest();

        List< VRF_Settings__c> settings = [SELECT Category__c, Value__c 
                                            FROM VRF_Settings__c
                                            WHERE Category__c = 'vrf_revision_endpoint' LIMIT 1 ];

        if (settings.size() > 0){
            settings[0].Category__c = 'xx';
            update settings;
        }


        String url = DigitalCreativeRevisionUtil.getRevisionURL();
        System.assertEquals('', url);

        Test.stopTest();

    }

    @isTest
    public static void TestMethod_SendVRFDataL_TestExceptionError(){

         Test.startTest();
         
         Set<Id> creatives = new Set<Id>(new Map<Id, Digital_Creative__c>([SELECT Id FROM Digital_Creative__c limit 1000]).keySet());
    
         List<Id> creativesList = new List<Id>(creatives);

         for(Id creativeRecordId : creativesList){
            System.debug('Record ID ' + creativeRecordId);
         }
  
         DigitalCreativeRevisionUtil.setStatusTo200 = false;

         DigitalCreativeRevisionUtil.SendVRFData(creativesList);

         Test.stopTest();

    }
}