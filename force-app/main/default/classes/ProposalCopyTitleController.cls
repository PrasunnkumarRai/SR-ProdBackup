public with sharing class ProposalCopyTitleController {

    public static String pageMsg {get;set;}
    public static HttpCalloutMock mock = null;

    @AuraEnabled
    public static List<Proposal__c> getProposalList(String proposalId) {
        System.debug('proposalId>>>>'+proposalId);
        return [ SELECT Id, Name, Advertiser__r.Name, Pilot_Proposal_ID__c, Pilot_Order_Status__c, TIM_Id__c, TIM_Status__c,Traffic_Order_Number__c, Start_Date__c, End_Date__c, Opportunity_Owner__c FROM Proposal__c WHERE Id = :proposalId];
    }

    @AuraEnabled  
    public static Map<String, Response> getCopyTitlesForProposal(String proposalId) {
        String trafficOrderNo, eclipseSystem, response ;        
        Map<String, Response> responseMap;
        System.debug('In CopyTitlesForProposal method proposalId--->>>'+ proposalId);
        try {
            List<Proposal__c> proposals = [SELECT Id, TIM_Id__c, Traffic_Order_Number__c, Eclipse_Customer_ID__c FROM Proposal__c WHERE Id = :proposalId AND RecordType.DeveloperName != 'Opportunity_Budget'];
            System.debug('Proposals Data--->>>'+ proposals);
        
            if (!CommonUtilities.isListNullOrEmpty(proposals) && proposals.size() > 0 ) {           
                //Validate and get request values from Proposal
                validateRequest (proposals[0]); 
                trafficOrderNo = proposals[0].Traffic_Order_Number__c;
                eclipseSystem = proposals[0].Eclipse_Customer_ID__c;
                System.debug('### trafficOrderNo ::: '+trafficOrderNo + '### eclipseSystem :::'+eclipseSystem);
                                
                if(eclipseSystem != 'null') { 
                    CopyTitlesRequest request;
                    
                    String endpoint = System.label.Proposal_Copy_Titles_Boomi_Endpoint;
                    HTTPResponse httpRes = new HTTPResponse();                  
                    request = buildCopyTitlesRequest(trafficOrderNo, eclipseSystem);
                    System.debug('### Endpoint ::: '+endpoint);
                    System.debug('### HTTPRequest ::: '+JSON.serialize(request));                       
                    
                    httpRes = RestServicePostStub(endpoint,JSON.serialize(request)); 
                    System.debug('### HTTPResponse ::: '+httpRes);  
                    if (httpRes!=NULL && httpRes.getStatus().equalsIgnoreCase('OK') && httpRes.getStatusCode() == 200) {
                        response = httpRes.getBody();
                        System.debug('### Response ::: '+response); 
                    
                        if(!CommonUtilities.isStringNullOrEmpty(response)) {    
                            EclipseData data = parse(response);
                            System.debug('### Parse Response ::: '+data);
                            if(!data.hasError) {
                                responseMap = buildCopyTitlesResponse(data);                    
                                System.debug('### ResponseMap ::: '+responseMap);  
                            }  
                            else {
                                pageMsg = data.errorMessage;
                                setErrorMessage(pageMsg);
                            }                    
                        }
                    }
                    else {
                        pageMsg = 'Failed to process request due to error code : '+httpRes.getStatusCode() + ' : ' + httpRes.getStatus();
                        setErrorMessage(pageMsg); 
                    }
                }   
                else {  
                    pageMsg = System.Label.Invalid_Eclipse_System;
                    setErrorMessage(pageMsg);  
                }
            }
            else {
                pageMsg = System.Label.Copy_Titles_not_exist_for_Opportunity_Budget_Proposals;
                setErrorMessage(pageMsg);   
            }
        }
        catch(AuraHandledException ex) {  
            System.debug('@@Exception :'+ex.getMessage()+' at Line No: '+ex.getLineNumber());  
            throw ex;  
        }
        catch(Exception ex) {   
            pageMsg = 'Exception occured during CopyTitlesForProposal API call: ' ; 
            Log4SF.logMessage('ProposalCopyTitleController', 'getCopyTitlesForProposal', pageMsg,ex, UserInfo.getUserId(),'NA');
            System.debug(pageMsg + ex.getMessage() + ' at Line no : ' + ex.getLineNumber()); 
            setErrorMessage(pageMsg + ex.getMessage()); 
        }
        return responseMap;
    }

    public static void validateRequest(Proposal__c prop) {      
        List<String> multipleTrafficOrders = new List<String>();
        String trafficOrderNo = prop.Traffic_Order_Number__c;
        String eclipseSystem = prop.Eclipse_Customer_ID__c;
        if(!CommonUtilities.isStringNullOrEmpty(trafficOrderNo) && !CommonUtilities.isStringNullOrEmpty(eclipseSystem)) {   

            multipleTrafficOrders = trafficOrderNo.split(','); 
            System.debug('Multiple TrafficOrders---->'+multipleTrafficOrders);          
            
            if(multipleTrafficOrders.size() > 1 && !CommonUtilities.isStringNullOrEmpty(eclipseSystem) && eclipseSystem.contains('|')) {
                pageMsg = System.Label.Proposal_has_Multiple_Traffic_Orders_in_Multiple_Eclipse_Systems;
                setErrorMessage(pageMsg); 
            }
            else if (multipleTrafficOrders.size() > 1 && !eclipseSystem.contains('&#124;')  && !CommonUtilities.isStringNullOrEmpty(eclipseSystem)) {
                pageMsg = System.Label.Proposal_has_Multiple_Traffic_Orders_in_EclipseSystem;
                setErrorMessage(pageMsg);
            }
            else {          
                prop.Traffic_Order_Number__c =  (multipleTrafficOrders[0]).trim();          
                prop.Eclipse_Customer_ID__c  =  (eclipseSystem.split('-')[0]).trim();               
            }   
        } else{
            pageMsg = System.Label.Traffic_Order_Number_Eclipse_Customer_Number_not_found;
            setErrorMessage(pageMsg); 
        }           
    }

    private static CopyTitlesRequest buildCopyTitlesRequest(String orderNo, String eclipsepSys) {
        CopyTitlesRequest request = new CopyTitlesRequest();
        request.eclipseSystem = eclipsepSys ;
        request.trafficOrderNumber = orderNo ;
        return request;
    }

    private static Map<String, Response> buildCopyTitlesResponse(EclipseData data) {
        Map<String, Response> resMap = new Map <String, Response>();
        String ONLY_SPOT = 'Spot:';
        String SPOT_TOP = 'BookedTop:';
        String SPOT_BOTTOM = 'BookedBtm:';
         
        if (data != NULL) {
            for(CopyTitlesResponse spot : data.eclipseData) {
                System.debug('spot---->'+spot);
                if(spot.ST_SZTITLE != NULL && spot.SB_SZTITLE != NULL) {
                    //Set Spot Top Data
                    Response spotTopVal = response (spot.ST_SZTITLE, spot.ST_SZEDICREATIVE, spot.ST_SZADID, spot.ST_ULLENGTH );
                    resMap.put(SPOT_TOP+spot.SB_SZTITLE, spotTopVal);
                    //Set Spot Bottom Data
                    Response spotBtmVal = response (spot.SB_SZTITLE, spot.SB_SZEDICREATIVE, spot.SB_SZADID, spot.SB_ULLENGTH );
                    resMap.put(SPOT_BOTTOM+spot.SB_SZTITLE, spotBtmVal);
                }
                else {
                    Response spotVal = response (spot.S_SZTITLE, spot.S_SZEDICREATIVE, spot.S_SZADID, spot.S_ULLENGTH );
                    resMap.put(ONLY_SPOT+spot.S_SZTITLE, spotVal);
                }
            }
        }                   
        return resMap;
    }

    private static Response response(String title, String ediCreative, String adId, String length) {
        
        Response response = new Response();
        response.SZTITLE = title ;
        response.SZEDICREATIVE = ediCreative ;
        response.SZADID = adId ;
        response.ULLENGTH = length ;

        return response;
    }


    private static HttpResponse RestServicePostStub(String endpoint, String body) {      
        //Instantiate a new http object
        Http h = new Http();
        //Instantiate a new HTTP request, specify the method as well as the endpoint
        HttpRequest req = new HttpRequest();
        //HttpResponse res ;
        HttpResponse res = new HttpResponse();
        req.setEndpoint(endpoint);      
        req.setMethod('POST');
        req.setHeader('Accept','application/json');
        req.setHeader('Content-type','application/json; charset=UTF-8');
        req.setHeader('Accept-Language', 'en-CA');
      
        if(String.isNotBlank(Label.SetTimeOut)) {
            req.setTimeout(Integer.valueOf(Label.SetTimeOut));
        }

        req.setBody(body);
        System.debug('Request body--->'+body);
        try { 
            if(!Test.isRunningTest()) {
                res = h.send(req);
            }
            else  {
                res = mock.respond(req);
            } 
            System.debug('@@response '+res); 
        }
        catch(System.CalloutException e)  {
            System.debug('Callout error: '+ e);
            System.debug('@@response '+res); 
            throw e;
        }           
        return res;
    }

    private static void setErrorMessage(String message) {
        System.debug(message);
        AuraHandledException auraEx = new AuraHandledException(message);
        auraEx.setMessage(message);
        throw auraEx;  
    }

    public class CopyTitlesRequest {
        public String eclipseSystem;
        public String trafficOrderNumber;
    }

    public class EclipseData {
        public Boolean hasError;
        public String errorMessage;
        public List<CopyTitlesResponse> EclipseData;
    }

    public class CopyTitlesResponse {       
        public String S_SZTITLE;
        public String S_SZEDICREATIVE;
        public String S_SZADID;
        public String S_ULLENGTH;
        public String ST_SZTITLE;
        public String ST_SZEDICREATIVE;
        public String ST_SZADID;
        public String ST_ULLENGTH;  
        public String SB_SZTITLE;
        public String SB_SZEDICREATIVE;
        public String SB_SZADID;
        public String SB_ULLENGTH; 
    }

    public class Response {
        @AuraEnabled
        public String SZTITLE;
        @AuraEnabled
        public String SZEDICREATIVE;
        @AuraEnabled
        public String SZADID;
        @AuraEnabled
        public String ULLENGTH;
    }

    public static EclipseData parse(String json) {
        return (EclipseData) System.JSON.deserialize(json, EclipseData.class);
    }
}