@RestResource(urlMapping='/OrderEntry/CreateOrders/*')
global with sharing class OrderEntryCreateOrdersRest {
    
    @HttpPost
    global static OrderEntryCreateOrdersRestHelper.ResponseWrapperCreateOrders CreateOrders()
    {
        RestRequest req = RestContext.request;
        OrderEntryCreateOrdersRestHelper.ResponseWrapperCreateOrders resWrap = new OrderEntryCreateOrdersRestHelper.ResponseWrapperCreateOrders();      
        OrderEntryCreateOrdersRestHelper.SFSendProposalOrders params;
        Savepoint sp = Database.setSavepoint();

        try{
            params = ( OrderEntryCreateOrdersRestHelper.SFSendProposalOrders)JSON.deserialize(req.requestBody.tostring(),  OrderEntryCreateOrdersRestHelper.SFSendProposalOrders.class);
        } catch (Exception e) {
            resWrap.isError    = true;
            resWrap.errorCode  = e.getMessage();
            resWrap.statusCode = 500;
            return resWrap;
        }

        resWrap = OrderEntryCreateOrdersRestHelper.createDigitalCampaigns(resWrap, params);
        if(resWrap.isError == true){
            Database.rollback(sp);
            return resWrap;
        }

        return resWrap;
    }
}