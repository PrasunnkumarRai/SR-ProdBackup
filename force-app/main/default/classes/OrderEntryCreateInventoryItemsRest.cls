@RestResource(urlMapping='/OrderEntry/CreateInventoryItems/*')
global with sharing class OrderEntryCreateInventoryItemsRest {
    
    @HttpPost
    global static OrderEntryCreateInventoryItemsRestHelper.ResponseWrapperCreateInventoryItems CreateInventoryItems()
    {
        RestRequest req = RestContext.request;
        OrderEntryCreateInventoryItemsRestHelper.ResponseWrapperCreateInventoryItems resWrap = new OrderEntryCreateInventoryItemsRestHelper.ResponseWrapperCreateInventoryItems();      
        OrderEntryCreateInventoryItemsRestHelper.SFInventoryItemRequestModel params;
        Savepoint sp = Database.setSavepoint();

        try{
            params = (OrderEntryCreateInventoryItemsRestHelper.SFInventoryItemRequestModel)JSON.deserialize(req.requestBody.tostring(),  OrderEntryCreateInventoryItemsRestHelper.SFInventoryItemRequestModel.class);
        } catch (Exception e) {
            resWrap.isError    = true;
            resWrap.errorCode  = e.getMessage();
            resWrap.statusCode = 500;
            return resWrap;
        }

        resWrap = OrderEntryCreateInventoryItemsRestHelper.createInventoryItems(resWrap, params);
        if(resWrap.isError == true){
            Database.rollback(sp);
            return resWrap;
        }

        return resWrap;
    }
}