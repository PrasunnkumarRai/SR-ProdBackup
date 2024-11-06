@RestResource(urlMapping='/OrderEntry/GetOrders/*')
global with sharing class OrderEntryGetOrdersRest {
    @HttpPost
    global static OrderEntryGetOrdersRestHelper.ResponseWrapper GetOrdersByPrefixId() {
        RestRequest req = RestContext.request;
        OrderEntryGetOrdersRestHelper.ResponseWrapper resWrap = new OrderEntryGetOrdersRestHelper.ResponseWrapper();      
        OrderEntryGetOrdersRestHelper.DigitalCampaignParams params;
        try{
            params = ( OrderEntryGetOrdersRestHelper.DigitalCampaignParams)JSON.deserialize(req.requestBody.tostring(),  OrderEntryGetOrdersRestHelper.DigitalCampaignParams.class);
        } catch (Exception e) {
            resWrap.isError    = true;
            resWrap.errorCode  = e.getMessage();
            resWrap.statusCode = 500;
            return resWrap;
        }

        resWrap = OrderEntryGetOrdersRestHelper.getDigitalCampaigns(params, resWrap);

        return resWrap;
    }
}