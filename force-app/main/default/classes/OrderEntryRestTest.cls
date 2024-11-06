@isTest(seeAlldata = false)
public class OrderEntryRestTest {

    public static String accountName = 'Test Acct Order Entry';

    @testSetup static void setup() {
        String accountRecordTypeName = 'Advertiser_Account';
        Id accountRecordTypeId       = Schema.SObjectType.Account
        .getRecordTypeInfosByDeveloperName()
    .get(accountRecordTypeName).getRecordTypeId();

        Account testAcct = new Account();
        testAcct.Name                       = accountName;
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
        
        RecordType dcRecordType = [SELECT id, Name FROM RecordType 
        WHERE Name = 'Inventory Request - New Ads Everywhere' 
        AND SobjectType = 'Digital_Campaign__c' LIMIT 1];

        Digital_Campaign__c dc = new Digital_Campaign__c( 
            Campaign_Name__c         = 'testCampaign',
            Status__c                = 'Draft Plan', 
            RecordTypeId             = dcRecordType.Id
        );

        insert dc;

        Profile p = [SELECT Id FROM Profile WHERE Name='Master - Digital Operations']; 
        User user = new User(Alias = 'LeBron', Email='lebron.james@testorg.com', 
                            FirstName = 'Lebron', LastName='Jame',
                            EmailEncodingKey='UTF-8',  LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='lebron.james@testorg.com');

        insert user;
    }

    @isTest
    static void OrderEntryCreateOrdersRest_CreateOrders_200() {
     
        Test.startTest();
  
        String json = JSON.serialize(GetSFProposalOrders());

        RestRequest req = new RestRequest(); 
        req.requestBody = Blob.valueof(json);

        RestContext.request = req;

        Test.setMock(HttpCalloutMock.class, new OrderEntryRestMockUp.OrderEntryProposalOrderMock());    
        
        OrderEntryCreateOrdersRestHelper.ResponseWrapperCreateOrders resWrap = OrderEntryCreateOrdersRest.CreateOrders();

        System.assertEquals(200, resWrap.statusCode);

        Test.stopTest();
    }

    @isTest
    static void OrderEntryCreateOrdersRest_CreateOrders_DeserializeEx() {
       
        Test.startTest();
        Account testAcct = [SELECT Id FROM Account Where Name =: accountName LIMIT 1];

        String json = '{ \"advertiser\": \"Test\" \"agency\": } ] }';
        RestRequest req = new RestRequest(); 
        req.requestURI  = '/' + testAcct.id;
        req.requestBody = Blob.valueOf(json);

        RestContext.request = req;

        Test.setMock(HttpCalloutMock.class, new OrderEntryRestMockUp.OrderEntryProposalOrderMock());   

        Try {
         
            OrderEntryCreateOrdersRest.CreateOrders();
      
        } catch (Exception e) {

            Boolean expectedExceptionThrown = e.getMessage().contains('Unexpected character') ? true : false;

            System.AssertEquals(true, expectedExceptionThrown);
        }

        Test.stopTest();
     

    }

    @isTest
    static void OrderEntryCreateOrdersRest_CreateOrders_DigitalCampaignEx() {
       
        Test.startTest();
        String json = JSON.serialize(GetSFProposalOrders());

        RestRequest req = new RestRequest(); 
        req.requestBody = Blob.valueof(json);

        RestContext.request = req;

        Test.setMock(HttpCalloutMock.class, new OrderEntryRestMockUp.OrderEntryProposalOrderMock());     

        Try {
         
            OrderEntryCreateOrdersRestHelper.ThrowDigitalCampaignException = true;
            OrderEntryCreateOrdersRestHelper.ResponseWrapperCreateOrders resWrap = OrderEntryCreateOrdersRest.CreateOrders();
     
        } catch (Exception e) {

            Boolean expectedExceptionThrown = e.getMessage().contains('My DML EXCEPTION') ? true : false;

            System.AssertEquals(true, expectedExceptionThrown);
        }
        Test.stopTest();
    }

    @isTest
    static void OrderEntryCreateInventoryItemsRest_CreateInventoryItems_200() {
     
        Test.startTest();
  
        String json = JSON.serialize(GetInventoryItemParams());

        RestRequest req = new RestRequest(); 
        req.requestBody = Blob.valueof(json);

        RestContext.request = req;

        Test.setMock(HttpCalloutMock.class, new OrderEntryRestMockUp.OrderEntryCreateInventoryItemsRestMock());    
        
        OrderEntryCreateInventoryItemsRestHelper.ResponseWrapperCreateInventoryItems resWrap = OrderEntryCreateInventoryItemsRest.CreateInventoryItems();

        System.assertEquals(200, resWrap.statusCode);

        Test.stopTest();
    }

    @isTest
    static void OrderEntryCreateInventoryItemsRest_CreateInventoryItems_DeserializeEx() {
       
        Test.startTest();
        String json = '{ \"inventory\", } ] }';
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(json);

        RestContext.request = req;

        Test.setMock(HttpCalloutMock.class, new OrderEntryRestMockUp.OrderEntryCreateInventoryItemsRestMock());   

        Try {
         
            OrderEntryCreateInventoryItemsRest.CreateInventoryItems();
      
        } catch (Exception e) {

            Boolean expectedExceptionThrown = e.getMessage().contains('Unexpected character') ? true : false;

            System.AssertEquals(true, expectedExceptionThrown);
        }

        Test.stopTest();
    }

    @isTest
    static void OrderEntryCreateInventoryItemsRest_CreateInventoryItems_CreateInventoryItemsEx() {
       
        Test.startTest();
        String json = JSON.serialize(GetInventoryItemParams());

        RestRequest req = new RestRequest(); 
        req.requestBody = Blob.valueof(json);

        RestContext.request = req;

        Test.setMock(HttpCalloutMock.class, new OrderEntryRestMockUp.OrderEntryCreateInventoryItemsRestMock());     

        Try {
         
            OrderEntryCreateInventoryItemsRestHelper.ThrowInventoryItemException = true;
            OrderEntryCreateInventoryItemsRestHelper.ResponseWrapperCreateInventoryItems resWrap = OrderEntryCreateInventoryItemsRest.CreateInventoryItems();
     
        } catch (Exception e) {

            Boolean expectedExceptionThrown = e.getMessage().contains('My DML EXCEPTION') ? true : false;

            System.AssertEquals(true, expectedExceptionThrown);
        }
        Test.stopTest();
    }

    private static OrderEntryCreateInventoryItemsRestHelper.SFInventoryItemRequestModel GetInventoryItemParams() {
        Digital_Campaign__c testDC = [SELECT Id, Name from Digital_Campaign__c where Campaign_Name__c =: 'testCampaign' LIMIT 1];
        
        OrderEntryCreateInventoryItemsRestHelper.SFInventoryItemRequestModel request = new OrderEntryCreateInventoryItemsRestHelper.SFInventoryItemRequestModel();

        List<OrderEntryCreateInventoryItemsRestHelper.OrderInventoryItemModel> orderInventoryItemList = new List<OrderEntryCreateInventoryItemsRestHelper.OrderInventoryItemModel>();

        OrderEntryCreateInventoryItemsRestHelper.OrderInventoryItemModel orderInventoryItem = new OrderEntryCreateInventoryItemsRestHelper.OrderInventoryItemModel();
        orderInventoryItem.orderId = testDC.Id;

        List<OrderEntryCreateInventoryItemsRestHelper.SFInventoryModel> inventoryItemList = new List<OrderEntryCreateInventoryItemsRestHelper.SFInventoryModel>();

        OrderEntryCreateInventoryItemsRestHelper.SFInventoryModel inventoryItem = new OrderEntryCreateInventoryItemsRestHelper.SFInventoryModel();

        inventoryItem.startdate = '2023-04-01';
        inventoryItem.enddate = '2023-05-01';
        inventoryItem.grossCPM = 50.00;
        inventoryItem.grossCost = 50.00;
        inventoryItem.impressions = 50.00;
        inventoryItem.exclusions = 'DirectTV; Dish/Sling';
        inventoryItem.inventoryResourceType = 'Freewheel-O&O/Affiliate/Direct';
        inventoryItem.orderId = testDC.Id;

        inventoryItemList.add(inventoryItem);
        orderInventoryItem.inventoryItems = inventoryItemList;

        orderInventoryItemList.add(orderInventoryItem);

        request.orderInventoryItems = orderInventoryItemList;

        return request;

    }

    private static OrderEntryCreateOrdersRestHelper.SFSendProposalOrders GetSFProposalOrders(){

        Proposal__c testProp = [SELECT Id, Name from Proposal__c where name =: 'Test Proposal' LIMIT 1];

        OrderEntryCreateOrdersRestHelper.SFSendProposalOrders sfProposalOrders = new  OrderEntryCreateOrdersRestHelper.SFSendProposalOrders();
    
        OrderEntryCreateOrdersRestHelper.SFSendProposalOrders sfSendOrders       = new OrderEntryCreateOrdersRestHelper.SFSendProposalOrders();
        OrderEntryCreateOrdersRestHelper.SFOrderModel order                      = new OrderEntryCreateOrdersRestHelper.SFOrderModel(); 
        List<OrderEntryCreateOrdersRestHelper.SFOrderModel> orderList            = new List<OrderEntryCreateOrdersRestHelper.SFOrderModel>();

        order.market = 'Test';
        order.campaignName = 'Campaign Test';
        order.publisher = 'test';
        order.prefixId = '12345';
        order.placementName = 'test';
        order.targeting = 'test';
        order.startdate = '2023-04-01';
        order.enddate = '2023-05-01';
        order.impressionUnits = 1234;
        order.grossCPM = 1234;
        order.grossInvestment = 1234;
        order.netCPM = 1234;
        order.netInvestment = 1234;
        order.networks = 'Adult Swim; ABC News';
        order.vastTag = false;
        order.kidsNetworkExclusion = false;
        order.tuneInExclusion = false;
        order.newsExclusion = true;
        order.customZipCode = false;
        order.platforms = 'VOD (Set-top Box); Spectrum TV App (Live)';
        order.genres = 'Adults 18-34';
        order.frequencyCap = 'Standard';
        order.yieldExcludeOverride = false;
        order.proposalId = testProp.Id;
        order.excludedNetworks = 'FOX News; CNN';
        order.preemptable = true;
        order.states = 'California; Texas; New York';
        order.dma = 'Los Angeles; Dallas-Ft. Worth; New York';
        order.zones = 'Zone 1; Zone 2; Zone 3';
        order.congressionalDistricts = 'District 1; District 2; District 3';
        order.zipCodes = '90210; 10001; 75201';
        order.productType = 'DMA Addressable';
        order.notes = 'These are test notes for the campaign.';
        order.hpo = 'College Football Playoffs';
        order.liveInTelecast = false;
        order.retargeting = true;
        order.hpoCustomNetAudience = false;
        order.iso = true;
        order.advancedCustomization = 'Customization Details';
        order.deviceExclusions = 'Tablet;Phone';
        order.dataCatalog = 'Data Catalog Details';
        order.dataCatalogExportKeyLogic = 'Export Key Logic Details';
        order.dataCatalogCustomLogic = 'Custom Logic Details';

        sfSendOrders.proposalOrders = new List<OrderEntryCreateOrdersRestHelper.SFOrderModel>{order};

        return sfSendOrders;

    }
}