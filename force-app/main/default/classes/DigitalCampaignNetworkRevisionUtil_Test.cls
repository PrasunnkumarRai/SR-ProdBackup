@isTest(seeAlldata = false)
public class DigitalCampaignNetworkRevisionUtil_Test {
   
    static final string NETWORKS            = 'ESPN APP;AMC';
    static final string REMOVE_CNN          = 'Remove: CNN';
    static final string ADD_REMOVE_NETWORKS = 'Added: HGTV || Remove: OWN';

    @testSetup
    private static void init(){
        
        RecordType recordType = [SELECT id, Name FROM RecordType 
                                 WHERE Name = 'Inventory Request - New Ads Everywhere' 
                                 AND SobjectType = 'Digital_Campaign__c' LIMIT 1];

        Digital_Campaign__c dcc = new Digital_Campaign__c( 
        Status__c                   = 'Draft Plan', 
        RecordTypeId                = recordType.Id,
        Rep_Firm_Text__c            = '', 
        Product_Type__c             = 'National Addressable', 
        Campaign_Name__c            = 'Cox Toyota Ads E 2019 (December) - New Ads Everywhere',
        Campaign_Start_Date__c      = Date.newInstance(2020, 9, 20), 
        Campaign_End_Date__c        = Date.newInstance(2020, 9, 28),
        Rate_Classification__c      = 'Paid',
        AdsE_Network__c             = 'ESPN APP;AMC',
        AdsE_Network_PriorValues__c = 'ESPN APP;AMC;CNN',
        AdsE_Platform_s__c          = 'All Platforms',
        Flight_Dates_Backend__c     = '2020-09-20:2020-09-22;2020-09-22:2020-09-24;2020-09-24:2020-09-28;');

        insert dcc;
        
    }   

   
    @isTest
    private static void networkChanges_passIDParam_checkChanges(){

        Test.startTest();

        List<Id> ids = new List<Id>(new Map<Id, Digital_Campaign__c>([SELECT id FROM Digital_Campaign__c]).keySet());

        DigitalCampaignNetworkRevisionUtil.networkChanges(ids);

        Digital_Campaign__c dc = [SELECT id, Adse_Network_History__c FROM Digital_Campaign__c];

        System.assertEquals(REMOVE_CNN, dc.Adse_Network_History__c);

        Test.stopTest();
    }  

    @isTest
    private static void getDigitalCampaigns_passIDParam_getValue(){

       Test.startTest();

       List<Id> ids = new List<Id>(new Map<Id, Digital_Campaign__c>([SELECT id FROM Digital_Campaign__c]).keySet());

       List<Digital_Campaign__c> dcList = DigitalCampaignNetworkRevisionUtil.getDigitalCampaigns(ids);
       
       System.assertEquals(NETWORKS, dcList[0].AdsE_Network__c);

       Test.stopTest();

    } 

    @isTest
    private static void deltaChanges_passDC_getValue(){

        Test.startTest();

        Digital_Campaign__c dc = [SELECT id, AdsE_Network__c, AdsE_Network_PriorValues__c, Adse_Network_History__c FROM Digital_Campaign__c];


        DigitalCampaignNetworkRevisionUtil.deltaChanges(dc);

        update dc;
    
        System.assertEquals(REMOVE_CNN, dc.Adse_Network_History__c);

        Test.stopTest();

    } 


    @isTest
    private static void deltaChangesWithAddRemove_passDC_getValue(){

        Test.startTest();

        Digital_Campaign__c dc = [SELECT id, AdsE_Network__c, AdsE_Network_PriorValues__c, Adse_Network_History__c FROM Digital_Campaign__c];


        dc.AdsE_Network__c             = 'CNN;BET;AMC;HGTV';
        dc.AdsE_Network_PriorValues__c = 'CNN;BET;AMC;OWN';

        update dc;

        DigitalCampaignNetworkRevisionUtil.deltaChanges(dc);

        update dc;
    
        System.assertEquals(ADD_REMOVE_NETWORKS, dc.Adse_Network_History__c);

        Test.stopTest();

    } 

}