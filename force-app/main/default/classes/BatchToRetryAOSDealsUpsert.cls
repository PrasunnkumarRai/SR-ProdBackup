global class BatchToRetryAOSDealsUpsert implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts, Schedulable
{
    public String query;
    public Boolean isProduction;
    public String endpoint; 
    public Map<String, AOS_Endpoints__mdt> aosServiceURLs; 
    public Set<String> dealStatusSet = new Set<string>();
    public Set<Id> advPropRTIds = new Set<Id>();

    global BatchToRetryAOSDealsUpsert() 
    {
        System.debug('Inside BatchToRetryAOSDealsUpsert-->>>>>>');
          
        dealStatusSet.addAll(System.Label.ExcludeDealStatuses.replace('\n', '').split(','));

        advPropRTIds.add(Proposalutils.advancedProposalRtId);
        advPropRTIds.add(Proposalutils.advancedPoliticalRtId);
        advPropRTIds.add(Proposalutils.advancedTradeRtId);          

        isProduction = AOSWebServiceHelper.isProductionOrg();
        System.debug('isProduction-->>>>>>'+isProduction); 

        aosServiceURLs = AOS_Endpoints__mdt.getAll();
        System.debug('AOS_Endpoints__mdt-->>>>>>'+aosServiceURLs);     

        String dealQuery = AOSWebServiceHelper.dealQuery; 

        String query = dealQuery + ' WHERE AOS_Bad_Sync__c = TRUE AND ((AOS_Deal_ID__c=NULL AND Start_Date__c>=TODAY) OR (AOS_Deal_ID__c!=NULL AND AOS_Deal_Status__c NOT IN : dealStatusSet)) AND RecordTypeId IN : advPropRTIds'; 
        // Updated Query to exclude Proposals which don't have AOS Deal ID and Start Date <Today

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
                List<Proposal__c> lstAdvProps = (List<Proposal__c>)scope;
                System.debug('lstAdvProps>>>'+lstAdvProps.Size());
                List<AOSHelper.DealRequest> dealReq = AOSWebServiceHelper.buildDealRequest(lstAdvProps, isProduction); 

                String request = JSON.serialize(dealReq);            
                System.debug('request--->>>'+request);   

                if(aosServiceURLs.get('UpsertDeal') != NULL )
                {
                    AOS_Endpoints__mdt service = aosServiceURLs.get('UpsertDeal');
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
            Log4SF.logMessage('BatchToRetryAOSDealsUpsert', 'execute method :'+ endpoint,ex.getMessage(), ex, UserInfo.getUserId(),null,null);  
        }
    }

    global void finish(Database.BatchableContext BC) {

    }

    global void execute(SchedulableContext sc) 
    {        
        Database.executeBatch(new BatchToRetryAOSDealsUpsert());        
    }
}