@isTest
global class OrderEntryRestMockUp  {
    
    global class OrderEntryProposalOrderMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            string json = JSON.serialize(GetMockProposals());
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json);
            response.setStatusCode(200);
            return  response; 
        }
    
        private OrderEntryCreateOrdersRestHelper.SFSendProposalOrders GetMockProposals(){
    
             OrderEntryCreateOrdersRestHelper.SFSendProposalOrders sfSendOrders       = new OrderEntryCreateOrdersRestHelper.SFSendProposalOrders();
    
             sfSendOrders.proposalOrders = new List<OrderEntryCreateOrdersRestHelper.SFOrderModel>();
    
             return sfSendOrders;
    
        }
    } 

    global class OrderEntryGetOrdersRest implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            string json = JSON.serialize(GetMockResponse());
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json);
            response.setStatusCode(200);
            return response; 
        }
    
        private OrderEntryGetOrdersRestHelper.ResponseWrapper GetMockResponse(){
            OrderEntryGetOrdersRestHelper.ResponseWrapper resWrap = new OrderEntryGetOrdersRestHelper.ResponseWrapper();
            List<Digital_Campaign__c> digitalCampaigns = new List<Digital_Campaign__c>();
            Digital_Campaign__c dc = new Digital_Campaign__c();
            dc.Id = '1234';
            dc.Campaign_Name__c = 'Test';
            dc.Ampersand_Prefix__c = '123456';

            digitalCampaigns.add(dc);

            resWrap.isError = false;
            resWrap.errorCode = '';
            resWrap.statusCode = 200;
            resWrap.digitalCampaigns = digitalCampaigns;

            return resWrap;
    
        }
    }

    global class OrderEntryGeoTargetingRest implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            string json = JSON.serialize(GetMockResponse());
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json);
            response.setStatusCode(200);
            return response; 
        }
    
        private OrderEntryGeoTargetRestHelper GetMockResponse(){
            OrderEntryGeoTargetRestHelper res = new OrderEntryGeoTargetRestHelper();
            res.StateList = new List<string>{'United States', 'New York'};
            res.DMAList = new List<string>{'Test_1'};
            res.ZoneList = new List<string>{'Test_1'};
            res.CongressList = new List<string>{'Test_1'};
            return res;
        }
    }

    global class OrderEntryCreateInventoryItemsRestMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            string json = JSON.serialize(GetMockResponse());
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json);
            response.setStatusCode(200);
            return response; 
        }
    
        private OrderEntryCreateInventoryItemsRestHelper.ResponseWrapperCreateInventoryItems GetMockResponse(){
            OrderEntryCreateInventoryItemsRestHelper.ResponseWrapperCreateInventoryItems resWrap = new OrderEntryCreateInventoryItemsRestHelper.ResponseWrapperCreateInventoryItems();
            List<OrderEntryCreateInventoryItemsRestHelper.InvenotryItemResponseInfo> inventoryItemInfoList = new List<OrderEntryCreateInventoryItemsRestHelper.InvenotryItemResponseInfo>();
            OrderEntryCreateInventoryItemsRestHelper.InvenotryItemResponseInfo inventoryItemInfo = new OrderEntryCreateInventoryItemsRestHelper.InvenotryItemResponseInfo();
            inventoryItemInfo.Id = '1234';
            inventoryItemInfo.orderSFId = '12345';
            inventoryItemInfo.resourceType = 'test';

            inventoryItemInfoList.add(inventoryItemInfo);

            resWrap.isError = false;
            resWrap.errorCode = '';
            resWrap.statusCode = 200;
            resWrap.inventoryItemInfo = inventoryItemInfoList;

            return resWrap;
    
        }
    }
    
    
}