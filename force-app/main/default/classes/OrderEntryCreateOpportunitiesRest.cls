@RestResource(urlMapping='/OrderEntry/CreateOpportunities/*')
global with sharing class OrderEntryCreateOpportunitiesRest {
    @HttpPost
    global static OrderEntryCreateAccountRestHelper.ResponseWrapper CreateOpportunitiesExistingAccount() 
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

        string accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Account acct = [SELECT Id, Name FROM Account where Id =: accountId];
        string accountName = acct.Name; 
        resWrap.accountId = accountId;
        resWrap.accountName = accountName;

        resWrap = OrderEntryCreateAccountRestHelper.createOpportunities(accountId, accountName, resWrap, params);

        if(resWrap.isError == true){
            Database.rollback(sp);
            return resWrap;
        }

        return resWrap;
    }
}