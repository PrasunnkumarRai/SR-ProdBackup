global class BatchToRetryAOSAccountsUpsert implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts, Schedulable
{
    public String query;
    public Boolean isProduction;
    public String endpoint; 
    public Map<String, AOS_Endpoints__mdt> aosServiceURLs; 

    global BatchToRetryAOSAccountsUpsert() 
    {
        System.debug('Inside BatchToRetryAOSAccountsUpsert-->>>>>>'); 

        isProduction = AOSWebServiceHelper.isProductionOrg();
        System.debug('isProduction-->>>>>>'+isProduction); 

        aosServiceURLs = AOS_Endpoints__mdt.getAll();
        System.debug('AOS_Endpoints__mdt-->>>>>>'+aosServiceURLs);

        String query = 'SELECT Id, Name, Active__c, Credit_Status__c, Discount_Percentage__c, AOS_Account_Id__c, RecordType.DeveloperName FROM Account WHERE AOS_Bad_Sync__c = TRUE';

        System.debug('query------->'+query);         
      
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        System.Debug('Inside Database.QueryLocator--> '+ query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) 
    {
        System.debug('In execute method, scope-->' + scope);
        String endpoint; 

        try 
        {  
            if(scope.size()>0)
            {
                List<Account> lstAccounts = (List<Account>)scope;

                List<AOSHelper.AccountRequest> accData = AOSWebServiceHelper.buildAccountRequest(lstAccounts, isProduction);   

                String request = JSON.serialize(accData);            
                System.debug('request--->>>'+request);   

                if(aosServiceURLs.get('UpsertAccount') != NULL )
                {
                    AOS_Endpoints__mdt service = aosServiceURLs.get('UpsertAccount');
                    String serviceURL = isProduction ? service.Endpoint__c : service.Staging_Endpoint__c;

                    System.debug('serviceURL-->>>>>>'+serviceURL); 

                    endpoint = 'callout:BoomiToAOS'+serviceURL; 
                }
                System.debug('endpoint-->>>>>>'+endpoint);                          

                if(!CommonUtilities.isStringNullOrEmpty(request) && !CommonUtilities.isStringNullOrEmpty(endpoint))
                {  
                    Http h = new Http();
                    HttpRequest req = new HttpRequest();
                    HttpResponse res = new HttpResponse();
                      
                    req.setEndpoint(endpoint);     
                    req.setMethod('POST');
                    req.setHeader('Accept','application/json');
                    req.setHeader('Content-Type','application/json; charset=UTF-8');
                    req.setHeader('Accept-Language', 'en-CA');

                    if(String.isNotBlank(Label.SetTimeOut)) {
                       req.setTimeout(Integer.valueOf(Label.SetTimeOut));
                    }
                   
                    req.setBody(request);
                    System.debug('request---->'+request);
                    
                    res = h.send(req);
                    System.debug('@@response '+res);                    
                }
            }
        } 
        catch(Exception ex) 
        {
            Log4SF.logMessage('BatchToRetryAOSAccountsUpsert', 'execute method :'+ endpoint,ex.getMessage(), ex, UserInfo.getUserId(),null,null);  
        }        
    }

    global void finish(Database.BatchableContext BC) {
    }

    global void execute(SchedulableContext sc) 
    {
        Database.executeBatch(new BatchToRetryAOSAccountsUpsert());        
    }
}