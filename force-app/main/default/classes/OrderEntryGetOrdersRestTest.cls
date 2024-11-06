@isTest(seeAlldata = false)
public class OrderEntryGetOrdersRestTest {

    @testSetup static void setup() {
        String accountRecordTypeName = 'Advertiser_Account';
        Id accountRecordTypeId       = Schema.SObjectType.Account
        .getRecordTypeInfosByDeveloperName()
        .get(accountRecordTypeName).getRecordTypeId();

        Account testAcct = new Account();
        testAcct.Name                       = 'Test Account';
        testAcct.Enterprise_Account_Type__c = 'Ampersand Local';
        testAcct.recordTypeId               = accountRecordTypeId;
        testAcct.ShippingStreet             = 'Test';
        testAcct.ShippingCity               = 'Test';
        testAcct.ShippingState              = 'Test';
        testAcct.ShippingCountry            = 'Test';
        testAcct.BillingStreet              = 'Test'; 
        testAcct.BillingCity                = 'Test';
        testAcct.BillingState               =  'Test';
        testAcct.BillingCountry             = 'Test';
        insert testAcct;    
        
        RecordType opptyRT = [SELECT Id FROM RecordType WHERE SObjectType='Opportunity' AND DeveloperName='Opportunity' limit 1];
        Opportunity testOppty = new Opportunity();
        testOppty.Name         = 'Test Opportunity';
        testOppty.RecordTypeId = opptyRT.Id;
        testOppty.StageName    = 'Proposal Presentation';
        testOppty.CloseDate    = System.Today().addDays( 30 );
        testOppty.AccountId    = testAcct.id;
        insert testOppty;

        RecordType proposalRT = [SELECT Id FROM RecordType WHERE SobjectType='Proposal__c' AND DeveloperName='Linear' limit 1];
        Proposal__c testProposal = new Proposal__c();
        testProposal.Name           = 'Test Proposal';
        testProposal.Start_Date__c  = SYstem.Today();
        testProposal.End_Date__c    = System.Today().addDays( 7 );
        testProposal.Opportunity__c = testOppty.Id;
        testProposal.Advertiser__c  = testAcct.Id;
        testProposal.RecordTypeId   = proposalRT.Id;
        insert testProposal;
        
     
        RecordType dcRT = [SELECT Id, Name FROM RecordType 
                                 WHERE Name = 'New Ads Everywhere' 
                                 And SobjectType = 'Digital_Campaign__c' LIMIT 1];

        Digital_Campaign__c testDC = new Digital_Campaign__c();
        testDC.Campaign_Name__c = 'Test';
        testDC.Proposal__c = testProposal.Id;
        testDC.Advertiser__c = testAcct.Id;
        testDC.Ampersand_Prefix__c = '123456';
        testDC.RecordTypeId = dcRT.Id;
        insert testDC;
    }

    @isTest
    static void OrderEntryGetOrdersRest_OrderEntryGetOrdersRest_200() {

        Test.startTest();
        OrderEntryGetOrdersRestHelper.DigitalCampaignParams params = GetDigitalCampaignParams();

        RestRequest req = New RestRequest(); 
        req.requestBody = Blob.valueof(JSON.serialize(params));

        RestContext.request = req;

        Test.setMock(HttpCalloutMock.class, New OrderEntryRestMockUp.OrderEntryGetOrdersRest());

        OrderEntryGetOrdersRestHelper.ResponseWrapper resWrap = OrderEntryGetOrdersRest.GetOrdersByPrefixId();

        System.assert(resWrap.digitalCampaigns != null);
        
        Test.stopTest();
    }

    @isTest
    static void OrderEntryGetOrdersRest_OrderEntryGetOrdersRest_QueryEx() {

        Test.startTest();
        OrderEntryGetOrdersRestHelper.DigitalCampaignParams params = GetDigitalCampaignParams();

        params.fields = 'Name, FieldThatThrowrsError';

        RestRequest req = New RestRequest(); 
        req.requestBody = Blob.valueof(JSON.serialize(params));

        RestContext.request = req;

        Test.setMock(HttpCalloutMock.class, New OrderEntryRestMockUp.OrderEntryGetOrdersRest());

        try {
            OrderEntryGetOrdersRest.GetOrdersByPrefixId();

        } catch (Exception e) {

            Boolean expectedExceptionThrown = e.getMessage().contains('Unexpected character') ? true : false;

            System.AssertEquals(true, expectedExceptionThrown);
        }
        
        Test.stopTest();
    }

    @isTest
    static void OrderEntryGetOrdersRest_OrderEntryGetOrdersRest_DeserializeEx() {

        Test.startTest();
        OrderEntryGetOrdersRestHelper.DigitalCampaignParams params = GetDigitalCampaignParams();

        String json = '{ \"advertiser\": \"Test\" \"agency\": } ] }';
        RestRequest req = New RestRequest();
        req.requestBody = Blob.valueOf(json);

        RestContext.request = req;

        Test.setMock(HttpCalloutMock.class, New OrderEntryRestMockUp.OrderEntryGetOrdersRest());

        try {
            OrderEntryGetOrdersRest.GetOrdersByPrefixId();

        } catch (Exception e) {

            Boolean expectedExceptionThrown = e.getMessage().contains('Unexpected character') ? true : false;

            System.AssertEquals(true, expectedExceptionThrown);
        }
        
        Test.stopTest();
    }

    private static OrderEntryGetOrdersRestHelper.DigitalCampaignParams GetDigitalCampaignParams() {

        OrderEntryGetOrdersRestHelper.DigitalCampaignParams params = new OrderEntryGetOrdersRestHelper.DigitalCampaignParams();
        params.prefixIds = new list<string>{'123456'};
        params.fields = 'Id, Name, Campaign_Name__c, Ampersand_Prefix__c, Advertiser__r.Name,  Advertiser__r.Id, Proposal__r.Name, Proposal__r.Id, Proposal__r.Opportunity__r.Id, Proposal__r.Opportunity__r.Name';

        return params;
    }

}