/*
###########################################################################
# File..................: AOSWebServiceHelper.cls
# Version...............: 1
# Created by............: Usharani Kasuba   
# Created Date..........: 
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This class contains helper methods for AOS WebService calls
# Test Class............: 
############################################################################*/
public class AOSWebServiceHelper 
{   
    public static HttpCalloutMock mock;

    public static final String PLATFORM = 'DIGITAL';
    public static final String PLAN_CLASS = 'default';
    public static final String AUTHENTICATION_ENDPOINT = 'Authentication';
    public static final String UPSERT_ACC_ENDPOINT = 'UpsertAccount';
    public static final String CREATE_DEAL_ENDPOINT = 'CreateDeal';
    public static final String CREATE_DEAL_RESP_URL = 'CreateDealResponse';
    public static final String UPSERT_DEAL_ENDPOINT = 'UpsertDeal';
    public static final String UPDATE_DEAL_ENDPOINT = 'UpdateDeal';
    public static final String UPDATE_DEAL_STATUS_ENDPOINT = 'UpdateDealStatus';
    public static final String CALLOUT_AOS = 'callout:SalesforceToAOS';
    public static final String CALLOUT_BOOMI = 'callout:BoomiToAOS';
    public static final String AE_ROLE = 'Account Executive';

    public static String dealQuery = 'SELECT Id, Name, Order_Type__c, Product_Type__c, Start_Date__c, End_date__c, Division__c, Region__c, Sales_Office__c, AOS_Deal_Id__c, AOS_Deal_MongoDB_Id__c, AOS_Deal_Status__c, Advertiser_Text__c, Pilot_Proposal__r.Name, Pilot_Proposal__r.Pilot_Proposal_ID__c, Pilot_Proposal__r.Pilot_Order_ID__c, Pilot_Proposal__r.Pilot_Order_Status__c, Traffic_Order_Number__c, Eclipse_Customer_ID__c, Political_Proposal__c, Source__c, Opportunity__c, Opportunity__r.Owner.UserName, Opportunity__r.Owner.Email, Opportunity__r.Owner.AOS_API_Name__c, Opportunity__r.Name, Opportunity__r.CoOp__c, Opportunity__r.Discount_Profile__c, Opportunity__r.Discount_Code__c, Opportunity__r.First_Look__c, Opportunity__r.Billing_Type__c, Opportunity__r.SAM_Designation__c, Opportunity__r.Tier_Designation__c, Advertiser__c, Advertiser__r.Name, Advertiser__r.AOS_Account_Id__c, Opportunity__r.Enterprise_Account_Type__c, Agency__c, Agency__r.Name, Agency__r.AOS_Account_Id__c, Rep_Firm__c, Rep_Firm__r.Name, Rep_Firm__r.AOS_Account_Id__c FROM Proposal__c';

    public AOSWebServiceHelper()
    {
        System.debug('@@User '+UserInfo.getUserId());             
    }   

    public static Boolean isProductionOrg()
    { 
        Boolean isProductionOrg = TRUE;
        //domain sandbox format is Domain name + '--' + sandbox name
        List<String> urlSplit = URL.getOrgDomainUrl().toExternalForm().split('--');
        if(urlSplit.size() > 1){
            isProductionOrg = FALSE; 
        } 
        System.debug('isProductionOrg--->'+isProductionOrg);
        return isProductionOrg; 
    }

    private static Map<String, Map<String, String>> getAOSPicklistValues(Boolean isProd)
    { 
        List<AOS_Picklist_Value_Mapping__mdt> aosPicklistValues = AOS_Picklist_Value_Mapping__mdt.getAll().values();
        System.debug('AOS Picklist Values-->>>>>>'+aosPicklistValues);  

        Map<String, Map<String, String>> mapAOSPicklistVals=new Map<String, Map<String, String>>();

        for(AOS_Picklist_Value_Mapping__mdt data : aosPicklistValues)
        {        
            String aosPicklistId = (isProd ? data.Production_Id__c : data.Staging_Id__c);

            if(!mapAOSPicklistVals.containsKey(data.Field_API_Name__c)){
                mapAOSPicklistVals.put(data.Field_API_Name__c, new Map<String, String>());
            }
            mapAOSPicklistVals.get(data.Field_API_Name__c).put(data.Label, aosPicklistId);
        }

        System.debug('mapAOSPicklistVals-->>>>>>'+mapAOSPicklistVals); 

        return mapAOSPicklistVals;
    }

    private static String getAOSServiceEndpoint(String serviceName, Boolean isProd)
    { 
        String serviceURL;
        Map<String, AOS_Endpoints__mdt> aosServiceURLs = AOS_Endpoints__mdt.getAll();
        System.debug('AOS_Endpoints__mdt-->>>>>>'+aosServiceURLs); 

        if(aosServiceURLs.get(serviceName) != NULL ) 
        {
            AOS_Endpoints__mdt service = aosServiceURLs.get(serviceName);
            serviceURL = isProd ? service.Endpoint__c : service.Staging_Endpoint__c;
        }
               
        System.debug('serviceURL-->>>>>>'+serviceURL); 

        return serviceURL;
    }

    private static Discount_Code__mdt getOppDiscountCodeValues(String discCode)
    { 
        List<Discount_Code__mdt> discCodeLst = Discount_Code__mdt.getAll().values();
        Discount_Code__mdt discCodeData = new Discount_Code__mdt();

        if(discCodeLst != NULL )
        {
            Map<String, Discount_Code__mdt> discCodeMap = new Map<String, Discount_Code__mdt>();
            for(Discount_Code__mdt eachDiscCode : discCodeLst)
            {
                if(!discCodeMap.containsKey(eachDiscCode.Label)){
                    discCodeMap.put(eachDiscCode.Label, eachDiscCode);
                }
            }
        
            System.debug('Opportunity discount code data-->>>>>>'+discCodeMap); 

            if(discCodeMap.containsKey(discCode)){
                discCodeData = discCodeMap.get(discCode);
            }
        }
        System.debug('discCodeData-->>>>>>'+discCodeData); 

        return discCodeData;
    }


    /**
    * @param endpoint
    * @param body
    * @return
    */
    public static HttpResponse RestServicePostStub(String endpoint, String body, String token)
    {
        System.debug('@@endpoint-->'+endpoint);
        System.debug('@@token--->'+token);

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
          
        req.setEndpoint(endpoint);     
        req.setMethod('POST');
        req.setHeader('Accept','application/json');
        req.setHeader('Content-Type','application/json; charset=UTF-8');
        req.setHeader('Accept-Language', 'en-CA');

        if(token != NULL){
           req.setHeader('Authorization', 'Bearer ' + token); 
           req.setHeader('Accept-Encoding', 'gzip');  // to avoid CalloutException: Not in GZIP format
        }  
        if(String.isNotBlank(Label.SetTimeOut)) {
           req.setTimeout(Integer.valueOf(Label.SetTimeOut));
        }
       
        req.setBody(body);
        System.debug('RestServicePostStub body---->'+body);

        try { 
            System.debug ('mock>>>>'+mock);
            if (Test.isRunningTest()) {
                if (mock!=NULL){
                    res = mock.respond(req);
                }    
            } else res = h.send(req);
            System.debug('@@response '+res);
        } 
        catch(System.CalloutException ex) 
        { 
            System.debug('Callout error: '+ ex);
            throw ex;
        }      
        return res;
    }


    //Method to get Authentication Token from AOS
    public static String authenticate()
    {   
        String token;
        AOSHelper.AuthenticationRequest request = new AOSHelper.AuthenticationRequest();
        request.userId = '{!$Credential.BasicAuthToAOS.userId}';
        request.password = '{!$Credential.BasicAuthToAOS.password}';
        request.apiKey = '{!$Credential.BasicAuthToAOS.apiKey}';
        System.debug('@@request '+request);  

        try
        {   
            Boolean isProduction = isProductionOrg();

            String req = JSON.serialize(request);
            System.debug('Authentication Request --->' +req);

            String endpoint = getAOSServiceEndpoint(AUTHENTICATION_ENDPOINT, isProduction);

            HttpResponse result = RestServicePostStub(CALLOUT_AOS+endpoint, req, NULL); 
            System.debug('Authentication Response --->' +result);

            if(result!=NULL && result.getStatusCode() == 200)
            {   
                String responseBody = result.getBody();
                System.debug('### responseBody ::: ' +responseBody);  
                  
                AOSHelper.AuthenticationResponse response = AOSHelper.parseAuthenticationResponse(responseBody); 
                token = response.token;                  
            }
        }
        catch(Exception ex){ 
            System.debug('Authenticate Exception: ' + ex.getMessage() + ' ::: Line Number ::: ' +ex.getLineNumber());                         
            throw ex;
        }
        return token;
    }


    //START SRSF-4341
    @future (callout=true) 
    public static void sendReqToUpsertAOSAccount(Set<ID> accountIDs) 
    {
        System.debug('Inside sendReqToUpsertAOSAccount -->'+accountIDs); 

        List<Account> lstAccrecs = new List<Account>();
        List<Account> accounts = new List<Account>();

        try 
        {
            accounts = [SELECT Id, Name, Active__c, Credit_Status__c, AOS_Account_Id__c, RecordType.DeveloperName FROM Account WHERE Id IN :accountIDs]; // Discount_Percentage__c, Enterprise_Account_Type__c
            System.debug('accounts -->'+accounts);

            if(accounts.size()>0) 
            {
                Boolean isProduction = isProductionOrg();
                List<AOSHelper.AccountRequest> accData = buildAccountRequest(accounts, isProduction); 
                String request = JSON.serialize(accData);
                System.debug('#######'+request);              

                if(!CommonUtilities.isStringNullOrEmpty(request))
                {    
                    String endpoint = getAOSServiceEndpoint(UPSERT_ACC_ENDPOINT, isProduction);

                    HttpResponse res = RestServicePostStub(CALLOUT_BOOMI+endpoint, request, NULL); 
                    System.debug('UpsertAccount Response --->' +res);      
                    System.debug('UpsertAccount Response --->' +res.getBody());     
                    if(res.getStatusCode() != 200) 
                    {                             
                        for(Account acc : accounts)
                        {
                          acc.AOS_Error_Message__c = 'Error'+res.getStatus();
                          acc.AOS_Bad_Sync__c = TRUE;
                          lstAccrecs.add(acc);
                        }                  
                    }
                }                 
            }
        } 
        catch(Exception ex) 
        {
            System.debug('Exception: '+ ex.getMessage()); 
            for(Account acc : accounts)
            {
                acc.AOS_Error_Message__c = 'Error:'+ex.getMessage();
                acc.AOS_Bad_Sync__c = TRUE;
                lstAccrecs.add(acc);
            }                   
        }

        System.debug('lstAccrecs--->'+lstAccrecs);
        if(lstAccrecs.size()>0) {
            AccountTriggerHandler.isFirstTime = FALSE;
            UPDATE lstAccrecs;   
        }
    }
    // END SRSF-4341

    /**
    * Mapping the account details(advertiser, agency & repfirm) to build AOS request
    * @param acc
    * @return 
    */
    public static List<AOSHelper.AccountRequest> buildAccountRequest(List<Account> accountsLst, Boolean isProd)
    {  
        System.debug('In buildAccountRequest accountsLst-->>>>>>'+accountsLst);   
        List<AOSHelper.AccountRequest> allAccounts = new List<AOSHelper.AccountRequest>(); 

        Map<String, Map<String, String>> mapAOSPicklistVals = getAOSPicklistValues(isProd);

        for (Account acc : accountsLst) 
        {       
            String creditStatus = '';
            String aosAccId = acc.AOS_Account_Id__c;
            String recType = acc.RecordType.DeveloperName; //SRSF-5062
            AOSHelper.AccountRequest account = new AOSHelper.AccountRequest();  
            account.id = (CommonUtilities.isStringNullOrEmpty(aosAccId) ? null : aosAccId); 
            account.mdmId = acc.Id; 
            account.name = acc.Name;  
            account.recordType = recType; //SRSF-5062      
            account.active = TRUE; // By default, Account created as InActive and will be marked TRUE through AccountRequest process. SF will send Active=TRUE to AOS       
        //  account.discountRate = acc.Discount_Percentage__c;  
            account.platform = new List<String>{PLATFORM}; 
            if(mapAOSPicklistVals.get('Credit_Status__c') != NULL){
                creditStatus = mapAOSPicklistVals.get('Credit_Status__c').get(acc.Credit_Status__c);
            }
            account.creditStatus = creditStatus;
            if(recType.equals('Agency_Account') || recType.equals('In_House_Agency_Account')){ //SRSF-5062 : Added Condition
                account.customFieldValues = buildAccountCFVs(acc, mapAOSPicklistVals);
            }
            
            if(recType.equals('Advertiser_Account')){
                account.psMappings = buildAccountPSMappings(acc, mapAOSPicklistVals);
            }

            allAccounts.add(account);
        }
    
        System.debug('all AccountRequests-->>>>>>'+allAccounts);
        
        return allAccounts;
    } 

    private static AOSHelper.CustomFieldValues buildAccountCFVs(Account acc, Map<String, Map<String, String>> mapAOSPicklistVals)
    { 
        AOSHelper.CustomFieldValues customVals = new AOSHelper.CustomFieldValues(); 
        String agencyType='';

        String recordType = acc.RecordType.DeveloperName;
        
        if(!recordType.equals('Advertiser_Account') && mapAOSPicklistVals.get('Agency_Type') != NULL) {
            agencyType = mapAOSPicklistVals.get('Agency_Type').get(recordType);
        }

        customVals.agencytype = agencyType; 
        
        return customVals;
    }

    private static List<AOSHelper.PSMappings> buildAccountPSMappings(Account acc, Map<String, Map<String, String>> mapAOSPicklistVals)
    {
        List<AOSHelper.PSMappings> psMappings = new List<AOSHelper.PSMappings>();
        AOSHelper.PSMappings psMapping = new AOSHelper.PSMappings();
        psMapping.active = TRUE;
        psMapping.extId = acc.Id;
        psMapping.externalValue = acc.Name;
        psMapping.extName = mapAOSPicklistVals.get('AudienceTrak').get('AudienceTrak'); 
        psMappings.add(psMapping);

        return psMappings;
    } 
    
    
    //SRSF-4342:Added this method to Create deals in AOS when user click on 'Create AOS Deal' button
    @AuraEnabled
    public static String sendReqToCreateAOSDeal(String proposalId)    
    {
        System.debug('Inside sendReqToCreateAOSDeal--->>>'+proposalId);
        String response;
        Set<Id> advProps = new Set<Id>();
        Id propId = Id.ValueOf(proposalId);
        advProps.add(propId); 
        System.debug ('advProps-->>'+advProps);

        String finalQuery = dealQuery + ' WHERE Id IN :recordIds';
        String endpoint = CALLOUT_AOS;
        String serviceURL = CREATE_DEAL_ENDPOINT;
        try{
            response = sendReqToUpsertAOSDeal(advProps, finalQuery, serviceURL, endpoint, null); 
        }
        catch(Exception ex){
            throw new AuraException(ex);
        }
        return response;
    }

    public static void sendReqToUpdateAOSDeal(Set<ID> advProps){
        if(isAsynchronous()){
            System.debug('sendReqToUpdateAOSDeal AOSDealUpdateQueueable:');
            System.enqueueJob(new AOSDealUpdateQueueable(advProps));
        }
        else{
            System.debug('sendReqToUpdateAOSDeal sendAsyncReqToUpdateAOSDeal:');
            sendAsyncReqToUpdateAOSDeal(advProps);
        }
    }

    @future (callout=true) 
    public static void sendAsyncReqToUpdateAOSDeal(Set<ID> advProps){
        sendUpdateDealRequestToAOS(advProps); 
    }

    //SRSF-4778: Added this method to update deals when a pilot proposal updated 
    public static void sendUpdateDealRequestToAOS(Set<ID> advProps)    
    {
        System.debug('Inside sendUpdateDealRequestToAOS--->>>'+advProps.size());       
        System.debug('Advanced Proposal Ids--->>>'+advProps);

        Set<String> dealStatusSet = new Set<string>();
        dealStatusSet.addAll(System.Label.ExcludeDealStatuses.replace('\n', '').split(','));
        System.debug('Deal Statuses to be excluded>>>>>> '+dealStatusSet);        
        
        String finalQuery = dealQuery + ' WHERE Id IN :recordIds AND AOS_Deal_Status__c NOT IN : dealStatuses'; 
        String endpoint = CALLOUT_BOOMI;
        String serviceURL = UPSERT_DEAL_ENDPOINT;
        
        sendReqToUpsertAOSDeal(advProps, finalQuery, serviceURL, endpoint, dealStatusSet);         
    }
    
    public static void sendReqToUpdateAOSDealsOfOpportunity(Set<ID> opptyIds){
        if(isAsynchronous()){
            System.debug('sendReqToUpdateAOSDealsOfOpportunity isAsynchronous:');
            System.enqueueJob(new AOSDealUpdateOfOppQueueable(opptyIds));
        }
        else{
            System.debug('sendReqToUpdateAOSDealsOfOpportunity Synchronous:');
            sendAsyncReqToUpdateAOSDealsOfOpportunity(opptyIds);
        }
    }

    @future (callout=true)
    public static void sendAsyncReqToUpdateAOSDealsOfOpportunity(Set<ID> opptyIds){
        sendUpdateAOSDealsOfOppReqToAOS(opptyIds);
    }

    //SRSF-4706: Added this method to update deals when an enterprise account type on Opportunity is updated
    // @future (callout=true) 
    public static void sendUpdateAOSDealsOfOppReqToAOS(Set<ID> opptyIds) 
    {
        System.debug('Inside sendUpdateAOSDealsOfOppReqToAOS--->>>'+opptyIds.size()); 
        System.debug('Opportunity Ids--->>>'+opptyIds);

        Set<String> dealStatusSet = new Set<string>();
        dealStatusSet.addAll(System.Label.ExcludeDealStatuses.replace('\n', '').split(','));
        System.debug('Deal Statuses to be excluded>>>>>> '+dealStatusSet);
              
        String finalQuery = dealQuery + ' WHERE Opportunity__c IN :recordIds AND AOS_Deal_Id__c!=NULL AND AOS_Deal_Status__c NOT IN :dealStatuses';        
        String endpoint = CALLOUT_BOOMI;
        String serviceURL = UPSERT_DEAL_ENDPOINT;
        
        sendReqToUpsertAOSDeal(opptyIds, finalQuery, serviceURL, endpoint, dealStatusSet);
    }

    public static String sendReqToUpsertAOSDeal(Set<Id> records, String query, String serviceURL, String endpoint, Set<String> dealStatus) 
    {
        System.debug('#### Inside sendReqToUpsertAOSDeal ###');
        System.debug('records--->>>'+records);
        System.debug('query--->>>'+query);
        System.debug('serviceURL--->>>'+serviceURL);
        System.debug('endpoint--->>>'+endpoint);        

        String token, service, msg;
        List<Proposal__c> advancedProps = new List<Proposal__c>();

        try 
        { 
            Map<String, Object> bindParams = new Map<String, Object>();
            bindParams.put('recordIds', records);
            bindParams.put('dealStatuses', dealStatus);
            advancedProps = Database.queryWithBinds(query, bindParams, AccessLevel.SYSTEM_MODE);

            System.debug('advancedProps--->>>'+advancedProps.size()+'--->>>'+advancedProps);

            if(!isAsynchronous())
            {
                Proposal__c advProp = advancedProps[0];
                if (!CommonUtilities.isStringNullOrEmpty(advProp.AOS_Deal_Id__c) && !advProp.AOS_Deal_Status__c.equalsIgnoreCase('Abandoned Campaign'))
                {                    
                    msg = 'Error:AOS Deal already exists for Advanced Proposal';
                } 
                else if(advProp.Advertiser__c != null  && (advProp.Advertiser__r.AOS_Account_Id__c == null))
                {
                    msg = 'Error: Deal cannot be created as Advertiser does not have AOS Account Id';
                } 
                else if(advProp.Agency__c != null && (advProp.Agency__r.AOS_Account_Id__c == null))
                {
                    msg = 'Error: Deal cannot be created as Agency does not have AOS Account Id';
                } 
                else if(advProp.Rep_Firm__c != null && (advProp.Rep_Firm__r.AOS_Account_Id__c == null))
                {
                    msg = 'Error: Deal cannot be created as RepFirm does not have AOS Account Id';
                }
            }

            if(CommonUtilities.isStringNullOrEmpty(msg) && advancedProps.size()>0) 
            { 
                Boolean isProduction = isProductionOrg();

                List<AOSHelper.DealRequest> deals = buildDealRequest(advancedProps, isProduction); 
                System.debug('deals--->>>'+deals);
                
                if(deals.size()>0) 
                {
                    String dealReqest;
                    if(!isAsynchronous())
                    {
                        dealReqest = JSON.serialize(deals[0]);

                        //To send request to AOS, authentication token is mandatory
                        token = authenticate(); 
                        System.debug('token--->>>'+token); 

                    }else{
                        dealReqest = JSON.serialize(deals);
                    }
                   
                    System.debug('dealReqest--->'+dealReqest); 

                    if(!CommonUtilities.isStringNullOrEmpty(dealReqest))
                    {
                        service = getAOSServiceEndpoint(serviceURL, isProduction);
                        String finalEndpoint = endpoint + service;

                        HttpResponse res = RestServicePostStub(finalEndpoint, dealReqest, token);
                        System.debug('Deal Response --->' +res);                        

                        if(!isAsynchronous())
                        {
                            System.debug('Inside Future check, status --->'+res.getStatusCode()); 
                            System.debug('res>>>>>>'+res);
                            String response = res.getBody();
                            System.debug('response>>>>>>'+response);
                            AOSHelper.DealResponse result = AOSHelper.parseDealResponse(response);
                            System.debug('result>>>>>'+result);

                            Proposal__c advProp = advancedProps[0];

                            if(res.getStatusCode() != 200 && res.getStatusCode() != 201) 
                            {                               
                                List<String> errorLst = result.errorMsg;
                                String errors = String.join(errorLst, ',');
                                msg = 'Error:' +errors;
                                advProp.Error_Message__c = msg;
                                advProp.AOS_Bad_Sync__c = TRUE; 
                                UPDATE advProp;       
                            } 
                            else {
                             // advProp.Name = result.response.planId+'_'+ advProp.Name; //SRSF-5061
                                advProp.AOS_Deal_Id__c = result.response.planId;
                                advProp.AOS_Deal_Status__c = result.response.planStatus.statusName;
                                advProp.AOS_Deal_MongoDB_Id__c = result.response.id;
                                advProp.Error_Message__c = ''; 
                                advProp.AOS_Bad_Sync__c = FALSE;
                                UPDATE advProp;

                                String responseURL = getAOSServiceEndpoint(CREATE_DEAL_RESP_URL, isProduction);
                                msg = String.format(responseURL, new List<String> {result.response.planId});
                            }
                        }
                    }
                }
            }
        }
        catch(DMLException exp)
        {   
            msg = 'Error:' +exp.getMessage();  
            System.debug('Exception occured --->'+msg);                          
            Log4SF.logMessage('AOSWebServiceHelper', 'sendReqToUpsertAOSDeal method :'+ endpoint,exp.getMessage(), exp, UserInfo.getUserId(),null,null);
            throw new AuraException('Error:' +exp.getMessage());
        }
        catch(Exception ex)
        {
            msg = 'Error:' +ex.getMessage();
            System.debug('Exception occured --->'+msg); 
            for(Proposal__c advProp : advancedProps)
            {                
                advProp.Error_Message__c = msg;
                advProp.AOS_Bad_Sync__c = TRUE;               
            }
            UPDATE advancedProps;           
        }
        System.debug('msg--->'+msg);
        return msg;
    }    

   
    public static List<AOSHelper.DealRequest> buildDealRequest(List<Proposal__c> advancedProps,Boolean isProd)
    { 
        System.debug('Inside buildDealRequest-->');

        String orderTypeId, dealMDMId, deald;

        List<AOSHelper.DealRequest> deals = new List<AOSHelper.DealRequest>();

        Map<String, Map<String, String>> mapAOSPicklistVals = getAOSPicklistValues(isProd);

        for(Proposal__c advProp : advancedProps)
        {   
            orderTypeId='';
            dealMDMId = advProp.AOS_Deal_MongoDB_Id__c;
            deald = advProp.AOS_Deal_Id__c;            

            AOSHelper.DealRequest dealReq = new AOSHelper.DealRequest(); 
            dealReq.platform = PLATFORM;
            dealReq.planName = advProp.Name;
            dealReq.id = (CommonUtilities.isStringNullOrEmpty(dealMDMId) ? null : dealMDMId);
            dealReq.planId = (CommonUtilities.isStringNullOrEmpty(deald) ? null : deald);
            if(mapAOSPicklistVals.get('Order_Type__c') != NULL){
                orderTypeId = mapAOSPicklistVals.get('Order_Type__c').get(advProp.Order_Type__c);
            }
            dealReq.orderTypeId = orderTypeId;
            dealReq.planClassId = PLAN_CLASS;
        //  dealReq.inCompletePlan = FALSE; // To get the planStatus as 'Draft Plan'
            dealReq.startDate = String.valueOf(advProp.Start_Date__c);
            dealReq.endDate = String.valueOf(advProp.End_Date__c);            
           /* dealReq.calendarId = mapAOSPicklistVals.get('Standard_Billing_Type').get('Broadcast');
            dealReq.discountProfileId = mapAOSPicklistVals.get('Discount_Profile__c').get(advProp.Opportunity__r.Discount_Profile__c);*/
            if(mapAOSPicklistVals.get('Discount_Profile__c') != NULL){
                dealReq.discountProfileId = mapAOSPicklistVals.get('Discount_Profile__c').get('Default Discount');
            }
            dealReq.accountExecutives = buildDealAEs(advProp);
            dealReq.advertisers = buildDealAccountDetails(advProp, 'Advertiser');
            if(advProp.Agency__c != NULL){            
                dealReq.agencies = buildDealAccountDetails(advProp, 'Agency');
            }
            else{
                dealReq.agencies = new List<AOSHelper.DealAccountDetails>();
            }
            if(advProp.Rep_Firm__c != NULL){ //SRSF-5062 : Added this Loop 
                dealReq.otherAccounts = buildDealAccountDetails(advProp, 'RepFirm');
            }
            if(advProp.Opportunity__r.Discount_Code__c != NULL){ 
                dealReq.discounts = buildOppDiscCodes(advProp.Opportunity__r.Discount_Code__c);
            }    
            dealReq.customFieldValues = buildDealCFVs(advProp, isProd, mapAOSPicklistVals); 

            deals.add(dealReq);
        }           

        return deals;
    }
    
    private static List<AOSHelper.DealAccountExecutives> buildDealAEs(Proposal__c advProp)
    {
        List<AOSHelper.DealAccountExecutives> dealAEs= new List<AOSHelper.DealAccountExecutives>();
        
        AOSHelper.DealAccountExecutives dealAE = new AOSHelper.DealAccountExecutives();
        System.debug('opp Owner Email>>>>'+advProp.Opportunity__r.Owner.AOS_API_Name__c); 
      //dealAE.userName = advProp.Opportunity__r.Owner.Email;
        dealAE.userName = advProp.Opportunity__r.Owner.AOS_API_Name__c;      
        dealAE.startDate = String.valueOf(advProp.Start_Date__c);
        dealAE.endDate = String.valueOf(advProp.End_Date__c);
        dealAEs.add(dealAE);

        return dealAEs;
    }    

    private static List<AOSHelper.DealAccountDetails> buildDealAccountDetails(Proposal__c advProp, String accType)
    {
        List<AOSHelper.DealAccountDetails> dealAccs= new List<AOSHelper.DealAccountDetails>();        
        String accId, accName;

        if(accType == 'Advertiser') {
            accId = advProp.Advertiser__r.AOS_Account_Id__c;
            accName = advProp.Advertiser__r.Name;
        } 
        if(advProp.Rep_Firm__c != NULL && accType == 'RepFirm') {
            accId =  advProp.Rep_Firm__r.AOS_Account_Id__c;
            accName = advProp.Rep_Firm__r.Name;                
        } 
        if(advProp.Agency__c != NULL && accType == 'Agency') {
            accId = advProp.Agency__r.AOS_Account_Id__c;
            accName = advProp.Agency__r.Name;
        }            

        AOSHelper.DealAccountDetails acc = new AOSHelper.DealAccountDetails(); 
        acc.id = accId; 
        acc.name = accName;
        acc.startDate = (accType == 'Advertiser' ? '' : String.valueOf(advProp.Start_Date__c)); 
        acc.endDate = (accType == 'Advertiser' ? '' : String.valueOf(advProp.End_Date__c)); 
        dealAccs.add(acc);

        return dealAccs;
    }

    private static List<AOSHelper.Discounts> buildOppDiscCodes(String oppDiscCode)
    {
        List<AOSHelper.Discounts> discountLst = new List<AOSHelper.Discounts>(); 
        System.debug('Inside buildOppDiscCodes oppDiscCode--->>>>'+oppDiscCode); 
      
        Discount_Code__mdt discCode = getOppDiscountCodeValues(oppDiscCode);

        if(discCode != NULL) 
        {
            if(discCode.Adv_Discount__c!=NULL && discCode.Adv_Discount__c > 0)
            {
                AOSHelper.Discounts advDisc = new AOSHelper.Discounts();
                advDisc.applyOn = 'Net';
                advDisc.discountName = 'Advertiser';
                advDisc.discountType = 'Advertiser';
                advDisc.discountValue = discCode.Adv_Discount__c;
                advDisc.sequenceNo  = Integer.valueOf(discCode.Advertiser_Sequence__c);
                discountLst.add(advDisc);
            }
            if(discCode.Agency_Discount__c!=NULL && discCode.Agency_Discount__c > 0)
            {
                AOSHelper.Discounts agencyDisc = new AOSHelper.Discounts();
                agencyDisc.applyOn = 'Net';
                agencyDisc.discountName = 'Agency';
                agencyDisc.discountType = 'Agency';
                agencyDisc.discountValue = discCode.Agency_Discount__c;
                agencyDisc.sequenceNo  = Integer.valueOf(discCode.Agency_Sequence__c);
                discountLst.add(agencyDisc);
            }
            if(discCode.RepFirm_Discount__c!=NULL && discCode.RepFirm_Discount__c > 0)
            {
                AOSHelper.Discounts repFirmDisc = new AOSHelper.Discounts();
                repFirmDisc.applyOn = 'Net';
                repFirmDisc.discountName = 'Rep Firm';
                repFirmDisc.discountType = 'Rep Firm';
                repFirmDisc.discountValue = discCode.RepFirm_Discount__c;
                repFirmDisc.sequenceNo  = Integer.valueOf(discCode.RepFirm_Sequence__c);
                discountLst.add(repFirmDisc);
            }
            if(discCode.Other_Discount__c!=NULL && discCode.Other_Discount__c > 0)
            {
                AOSHelper.Discounts otherDisc = new AOSHelper.Discounts();
                otherDisc.applyOn = 'Net';
                otherDisc.discountName = 'Other';
                otherDisc.discountType = 'Other';
                otherDisc.discountValue = discCode.Other_Discount__c;
                otherDisc.sequenceNo  = Integer.valueOf(discCode.Other_Disc_Sequence__c);
                discountLst.add(otherDisc);
            }            
        }

        return discountLst;
    }       

    private static AOSHelper.DealCustomFieldValues buildDealCFVs(Proposal__c advProp, Boolean isProd, Map<String, Map<String, String>> mapAOSPicklistVals)
    { 
        String enterpriseAccType='';
        Boolean isFullAvail = String.isNotBlank(advProp.Product_Type__c) && advProp.Product_Type__c.equals(Label.Prod_Type_Full_Avail) ? true : false;
        System.debug('isFullAvail:' + isFullAvail);
        AOSHelper.DealCustomFieldValues customVals = new AOSHelper.DealCustomFieldValues(); 
        
        if(advProp.Order_Type__c == 'Streaming TV' && mapAOSPicklistVals.get('Product_Type__c') != NULL)
        {
            customVals.producttype = mapAOSPicklistVals.get('Product_Type__c').get(advProp.Product_Type__c);
        } 
        else if(advProp.Order_Type__c == 'Online' && !CommonUtilities.isStringNullOrEmpty(advProp.Product_Type__c))
        {            
            List<String> onlineProdTypes = new List<String>();
            List<String> selectedProdTypes = advProp.Product_Type__c.split(';');            

            for(String prodType : selectedProdTypes){
                if(prodType!=NULL && mapAOSPicklistVals.get('Product_Type__c') != NULL)
                {
                    String onlineProdType = mapAOSPicklistVals.get('Product_Type__c').get(prodType);
                    onlineProdTypes.add(onlineProdType);
                } 
            }    
            
            customVals.onlineproducttype2 = onlineProdTypes;
        }   
        customVals.sfproposalid = advProp.Pilot_Proposal__c;
        customVals.sfadvancedproposalid = advProp.Id;
        customVals.proposalname = advProp.Pilot_Proposal__r.Name; 
        /*customVals.spectrumdivision = advProp.Division__c;
        customVals.region = advProp.Region__c;
        customVals.salesoffice = advProp.Sales_Office__c;*/  
        customVals.political = advProp.Political_Proposal__c;  
        customVals.pilotproposalid = advProp.Pilot_Proposal__r.Pilot_Proposal_ID__c;
        customVals.pilotid = advProp.Pilot_Proposal__r.Pilot_Order_ID__c;
    //  customVals.pilotorderstatus = advProp.Pilot_Proposal__r.Pilot_Order_Status__c;
        customVals.trafficordernumber = isFullAvail ? getTrafficEclipseID(advProp.Traffic_Order_Number__c) : advProp.Traffic_Order_Number__c;
        customVals.trafficcustomerid = isFullAvail ? getTrafficEclipseID(advProp.Eclipse_Customer_ID__c) : advProp.Eclipse_Customer_ID__c;
        customVals.coopcheck = advProp.Opportunity__r.CoOp__c;  
        customVals.opportunityid = advProp.Opportunity__c;
        customVals.opportunityname = advProp.Opportunity__r.Name;         
        customVals.firstlookcheck=(advProp.Opportunity__r.First_Look__c != NULL) ? TRUE : FALSE; 
        if(mapAOSPicklistVals.get('Pilot_Order_Status__c') != NULL){
            customVals.pilotorderstatuspicklist = mapAOSPicklistVals.get('Pilot_Order_Status__c').get(advProp.Pilot_Proposal__r.Pilot_Order_Status__c);
        }

        if(mapAOSPicklistVals.get('Division__c') != NULL){
            customVals.divisionpicklist = mapAOSPicklistVals.get('Division__c').get(advProp.Division__c);
        }

        if(mapAOSPicklistVals.get('Region__c') != NULL){
            customVals.regionpicklist = mapAOSPicklistVals.get('Region__c').get(advProp.Region__c);
        }

        if(mapAOSPicklistVals.get('Sales_Office__c') != NULL){
            customVals.salesofficepicklist = mapAOSPicklistVals.get('Sales_Office__c').get(advProp.Sales_Office__c);
        }

        if(mapAOSPicklistVals.get('Billing_Type__c') != NULL){
            customVals.billingcalendar = mapAOSPicklistVals.get('Billing_Type__c').get(advProp.Opportunity__r.Billing_Type__c);
        }
        if(mapAOSPicklistVals.get('Enterprise_Account_Type__c') != NULL){
            enterpriseAccType = mapAOSPicklistVals.get('Enterprise_Account_Type__c').get(advProp.Opportunity__r.Enterprise_Account_Type__c);
        }
        customVals.enterpriseaccounttype = enterpriseAccType; 
        customVals.advertisername = advProp.Advertiser_Text__c;
        customVals.source = advProp.Source__c;
        if(Label.SAMDesignationShutDown=='FALSE' && mapAOSPicklistVals.get('SAM_Designation__c') != NULL){
            customVals.samdesignation = mapAOSPicklistVals.get('SAM_Designation__c').get(advProp.Opportunity__r.SAM_Designation__c);
        }
        if(mapAOSPicklistVals.get('Tier_Designation__c') != NULL){
            customVals.tierdesignation = mapAOSPicklistVals.get('Tier_Designation__c').get(advProp.Opportunity__r.Tier_Designation__c);
        }
        if(mapAOSPicklistVals.get('Discount_Code__c') != NULL){
            customVals.discountcode = mapAOSPicklistVals.get('Discount_Code__c').get(advProp.Opportunity__r.Discount_Code__c);
        }       

        return customVals;
    }
    // END SRSF-4342  
    
    //SRSF-4881
    public static Boolean sendReqToActivateDeactivateDeals(List<Proposal__c> proposalList)    
    {
        Boolean isSuccess = false;
        try{
            String requestBody = '';
            Boolean isProduction = isProductionOrg();
            String service = getAOSServiceEndpoint(UPDATE_DEAL_STATUS_ENDPOINT, isProduction); 
            String endpoint = CALLOUT_BOOMI + service;
            AOSHelper.ActivateDeactivateAOSDealRequest actDeactDealReq = new AOSHelper.ActivateDeactivateAOSDealRequest();
            List<AOSHelper.ActivateDeactivateDeal> dealProposals = new List<AOSHelper.ActivateDeactivateDeal>();
            
            if(proposalList.size() > 0) {
                for(Proposal__c prop : proposalList) {
                    AOSHelper.ActivateDeactivateDeal actDeactDeal = new AOSHelper.ActivateDeactivateDeal();
                    actDeactDeal.proposalId = prop.Id;
                    actDeactDeal.dealId = prop.AOS_Deal_Id__c;
                    actDeactDeal.isActive = prop.Active__c;
                    dealProposals.add(actDeactDeal);
                }
                
                actDeactDealReq.plans = dealProposals;
                requestBody = JSON.serialize(actDeactDealReq);

                System.debug('sendReqToActivateDeactivateDeals requestBody:' + requestBody);            
                HttpResponse response = RestServicePostStub(endpoint, requestBody, NULL);  
                System.debug('sendReqToActivateDeactivateDeals response getStatusCode:' + response.getStatusCode());
                if(response != NULL && response.getStatusCode() == 200) {
                    isSuccess = true;
                }
                else{
                    Log4SF.logMessage('AOSWebServiceHelper', 'sendReqToActivateDeactivateDeals', Label.Activate_Deactivate_Deal_Request_Error_Message, null, UserInfo.getUserId(),null,null);
                }
            }
        }
        catch(Exception ex){
            System.debug('sendReqToActivateDeactivateDeals Exception:'+ ex.getMessage());
            Log4SF.logMessage('AOSWebServiceHelper', 'sendReqToActivateDeactivateDeals', ex.getMessage(), ex, UserInfo.getUserId(),null,null);
        }
        
        System.debug('sendReqToActivateDeactivateDeals isSuccess:' + isSuccess);
        
        return isSuccess;
    }
    //END SRSF-4881
    public static Boolean isAsynchronous() { 
        return System.IsBatch() || System.isFuture() || System.isQueueable() || System.isScheduled() ? true : false;
    }

    //SRSF-5160 - Added this method to get only one Traffic Order Number or Eclipse Customer ID from multiple traffic order #s and Eclipse customer ids
    public static String getTrafficEclipseID(String data) {
        String value = '';

        if(String.isNotBlank(data)){
            List<String> values = data.split('\\|');
            System.debug('TrafficEclipseID values:' + value);
            if(values.size() > 0){
                for(String val : values){
                    if(String.isNotBlank(val) && val.trim().toUpperCase().startsWith('XGNY')){
                        value = val.trim();
                        break;
                    }
                }
            }
        }

        System.debug('TrafficEclipseID:' + value);

        return value;
    }

    public class AOSDealUpdateQueueable implements Queueable {
        public Set<ID> advProps; 
        public AOSDealUpdateQueueable(Set<ID> advProps){
            this.advProps = advProps;  
        }
        public void execute(QueueableContext context) {
            System.debug('AOSDealUpdateQueueable execute:');
            sendUpdateDealRequestToAOS(advProps);
        }
    }

    public class AOSDealUpdateOfOppQueueable implements Queueable {
        public Set<ID> opptyIds; 
        public AOSDealUpdateOfOppQueueable(Set<ID> opptyIds){
            this.opptyIds = opptyIds;  
        }
        public void execute(QueueableContext context) {
            System.debug('AOSDealUpdateOfOppQueueable execute:');
            sendUpdateAOSDealsOfOppReqToAOS(opptyIds);
        }
    }
}