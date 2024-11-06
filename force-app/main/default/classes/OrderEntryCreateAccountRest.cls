@RestResource(urlMapping='/OrderEntry/CreateAccountAndOpps/*')
global with sharing class OrderEntryCreateAccountRest {
    @HttpPost
    global static OrderEntryCreateAccountRestHelper.ResponseWrapper CreateAccountWithOpportunities() 
    {
        RestRequest req = RestContext.request;
        OrderEntryCreateAccountRestHelper.ResponseWrapper resWrap = new OrderEntryCreateAccountRestHelper.ResponseWrapper();      
        OrderEntryCreateAccountRestHelper.CreateAccountParams params;
        Savepoint sp = Database.setSavepoint();
        
        try{
            params = (OrderEntryCreateAccountRestHelper.CreateAccountParams)JSON.deserialize(req.requestBody.tostring(), OrderEntryCreateAccountRestHelper.CreateAccountParams.class);
        } catch (Exception e) {
            resWrap.isError    = true;
            resWrap.errorCode  = e.getMessage();
            resWrap.statusCode = 500;
            return resWrap;
        }
        resWrap = OrderEntryCreateAccountRestHelper.createAccount(resWrap, params);
        if(resWrap.isError == true){
            Database.rollback(sp);
            return resWrap;
        }
        return resWrap;
    }
}