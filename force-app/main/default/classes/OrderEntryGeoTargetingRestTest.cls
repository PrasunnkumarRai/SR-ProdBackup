@isTest
public with sharing class OrderEntryGeoTargetingRestTest {
    @TestSetup
    static void makeData(){
        
        list<RecordType> lst = [select id from RecordType where name='Nielsen DMA' and sobjecttype='Zipcode_Mapping__c'];
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
        }
    }

    @isTest
    static void OrderEntryGetGeographyTargetDataRest_GetGeographyTargetData_200() {

        Test.startTest();
        RestRequest req = New RestRequest();

        RestContext.request = req;

        Test.setMock(HttpCalloutMock.class, New OrderEntryRestMockUp.OrderEntryGeoTargetingRest());

        OrderEntryGeoTargetRestHelper res = OrderEntryGetGeographyTargetDataRest.GetGeographyTargetData();
        System.assert(res.ZoneList.size() > 0);
        System.assert(res.DMAList.size() > 0);
        System.assert(res.StateList.size() > 0);
        System.assert(res.CongressList.size() > 0);
        Test.stopTest();
    }
}