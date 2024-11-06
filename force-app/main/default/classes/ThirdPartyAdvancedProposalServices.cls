/**********************************************************************
 * 
 *
 * @url: /services/apexrest/rest
 * @data:
 *  {}
 * File..................: ThirdPartyAdvancedProposalServices.cls
 * Version...............: 1
 * Description...........: Jira Ticket : SRSF-4344 & SRSF-4707
*************************************************************************/
@RestResource(urlMapping='/SpectrumReachAdvPropServices/*')
global with sharing class ThirdPartyAdvancedProposalServices 
{
    global static final String CREATE_ADV_PROP = 'CreateAdvancedProposal';
    global static final String STATUS_SUCCESS = 'Success';
    global static final String STATUS_FAIL = 'Failure';
    global static String source;
    global static Boolean hasError;     

    @HttpGet
    global static String doGet() {
        return 'SpectrumReach Advanced Proposal Services API is Alive!';
    }

    @HttpPost
    global static OutgoingResponseWrapper doPost(IncomingRequestWrapper advanceProposalRequest) 
    { 
        OutgoingResponseWrapper response;
        String userId = advanceProposalRequest.userID;
        
        if(advanceProposalRequest!=NULL && String.isNotBlank(advanceProposalRequest.source)) {
            source = advanceProposalRequest.source;
        } 

        Map<String,Object> mapOfThirdPartyLog = new Map<String, Object>{'JSON__c' => String.valueOf(advanceProposalRequest) , 'API_Name__c' => 'SpectrumReachAdvPropServices', 'Source__c' => source, 'ObjectType__c' => CREATE_ADV_PROP, 'User__c' =>userId};

        Third_Party_Logger__c thirdPartyLog = Log4SF.createThirdPartyLogger(mapOfThirdPartyLog, FALSE, new Third_Party_Logger__c());

        if(CommonUtilities.isStringNullOrEmpty(source) || (!Source.equals(System.Label.Audience_Track) && !source.equals(System.Label.Architect) && !source.equals(System.Label.Digital_Hub) && !source.equals(System.Label.SPP))){
            response = new OutgoingResponseWrapper(FALSE, NULL, NULL, NULL, System.Label.Invalid_Source + source);
        } 
        else {
            
            System.debug('AdvanceProposalRequest-->>>'+advanceProposalRequest);
            String advancedPropId = advanceProposalRequest.advancedPropId;

            //Check If advanced Proposal exists in Salesforce, then send deal payload else create adv prop
            if(!CommonUtilities.isStringNullOrEmpty(advancedPropId))
            {
                response = getAdvancedProposal(advancedPropId, thirdPartyLog);             
            }
            else{                
                response = createAdvancedProposal(advanceProposalRequest, thirdPartyLog);
            }               
        }        
        return response;
    }

     /*
    This method is used to check advanced proposal already created for DigitalHub/Map Users from Third party Services 
    */
    global static OutgoingResponseWrapper getAdvancedProposal(String advPropId, Third_Party_Logger__c thirdPartyLog) 
    {
        OutgoingResponseWrapper resultWrapper;
        String message, planId, planStatus, response;  
        hasError = false; 

        try
        {
            List<Id> advPropRTIds = new List<Id>(); 

            advPropRTIds.add(Proposalutils.advancedProposalRtId);
            advPropRTIds.add(Proposalutils.advancedPoliticalRtId);
            advPropRTIds.add(Proposalutils.advancedTradeRtId);
            
            List<Proposal__c> advProp = [SELECT Id, Active__c, AOS_Deal_Id__c, AOS_Deal_Status__c FROM Proposal__c WHERE Id = :advPropId AND RecordTypeId IN :advPropRTIds];
            System.debug('advProp--->'+advProp);
            if(advProp == NULL || advProp.size() == 0) 
            {    
                hasError = true;        
                message = System.Label.Invalid_Advanced_Proposal_Id;
            }
            else if(advProp.size() > 0 && !advProp[0].Active__c) 
            {
                hasError = true;    
                message = System.Label.Inactive_Advanced_Proposal;   
            }
            else 
            {
               planId = advProp[0].AOS_Deal_Id__c;
               planStatus = advProp[0].AOS_Deal_Status__c;

                if(CommonUtilities.isStringNullOrEmpty(planId) || CommonUtilities.isStringNullOrEmpty(planStatus))
                {
                    response = buildAOSDealReqPayload(advPropId);
                }
            } 
            resultWrapper = new OutgoingResponseWrapper(!hasError, response, planId, planStatus, message);
        }
        catch(Exception ex)
        {           
            message = ex.getMessage()+' at Line : '+ ex.getLineNumber();
            resultWrapper = new OutgoingResponseWrapper(FALSE, NULL, NULL, NULL, message);

            Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => STATUS_FAIL, 'Error_Message__c' =>message } ,TRUE , thirdPartyLog);
        }
        return resultWrapper;
    }
    
    /*
    This method is used for creating advanced proposal for DigitalHub/Map Users from Third party Services 
    */
    global static OutgoingResponseWrapper createAdvancedProposal(IncomingRequestWrapper requestWrapper, Third_Party_Logger__c thirdPartyLog) 
    {  

        OutgoingResponseWrapper resultWrapper;
        String message, response;  
        hasError = false; 

        String pilotId = requestWrapper.pilotId;

        if(!CommonUtilities.isStringNullOrEmpty(pilotId)) 
        {
            try 
            {
                Id advPropRtId= ProposalUtils.advancedProposalRtId;
                String query = 'SELECT Id, Name, Active__c, Start_Date__c, End_date__c, Division__c, Region__c, Sales_Office__c, Traffic_Order_Number__c, Eclipse_Customer_ID__c, Political_Proposal__c, Opportunity__c, Opportunity__r.OwnerId, Opportunity__r.StageName,  Advertiser__c, Advertiser__r.AOS_Account_Id__c, Agency__c, Agency__r.AOS_Account_Id__c, Rep_Firm__c, Rep_Firm__r.AOS_Account_Id__c, (SELECT Id FROM Proposal_Zones__r WHERE Zone_Type__c=\'Digital\'), (SELECT Id FROM PilotProposals__r WHERE RecordtypeId=:advPropRtId) FROM Proposal__c'; 

                if(Source.equalsIgnoreCase(System.Label.Architect) || Source.equalsIgnoreCase(System.Label.Audience_Track) || Source.equalsIgnoreCase(System.Label.SPP)){
                    query +=  ' WHERE Pilot_Proposal_ID__c = :pilotId';
                }else{
                    query += ' WHERE Pilot_Order_ID__c = :pilotId' ;  
                } 

                System.debug('Query--->'+ query);
                List<Proposal__c> proposal = Database.Query(query);
                System.debug('Pilot Proposal --->'+ proposal);
                 
                if(proposal.size()>0)
                {      
                    message = validateRequest(proposal[0], requestWrapper.startDate, requestWrapper.endDate);

                    if(!hasError)
                    {
                        Proposal__c advProp = insertAdvancedProposal(proposal[0], requestWrapper, advPropRtId);
                        response = buildAOSDealReqPayload(advProp.Id);
                        resultWrapper = new OutgoingResponseWrapper(TRUE, response, NULL, NULL, NULL);
                    } 
                    else{
                        resultWrapper = new OutgoingResponseWrapper(FALSE, NULL, NULL, NULL, message);
                    }
                }
                else{
                    hasError = true;
                    message = System.Label.Invalid_Pilot_Prop_Id_Pilot_Order_Id;
                    resultWrapper = new OutgoingResponseWrapper(FALSE, NULL, NULL, NULL, message);
                }
            }
            catch(Exception ex)
            {           
                message = ex.getMessage()+' at Line : '+ ex.getLineNumber();
                resultWrapper = new OutgoingResponseWrapper(FALSE, NULL, NULL, NULL, message);

                Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => STATUS_FAIL, 'Error_Message__c' =>message } ,TRUE , thirdPartyLog);
            }
        }
        else{
            hasError = true;
            message = System.Label.Pilot_Order_Id_Pilot_Prop_Id_is_mandatory;
            resultWrapper = new OutgoingResponseWrapper(FALSE, NULL, NULL, NULL, message);
        }
        
        return resultWrapper;
    }

    //Check validations for both Create/Update scenarios
    private static String validateRequest(Proposal__c prop, String startDt, String endDt)
    {
        System.debug('Inside validateRequest startDt--->'+ startDt+' EndDt--->'+endDt);

        String msg;

        Date startDate = (startDt != NULL ? Date.valueOf(startDt) : NULL);
        Date endDate = (endDt != NULL ? Date.valueOf(endDt) : NULL);         
        
        // Check if a Pilot Proposal has Digital Order lines 
        /*if(!hasError && (prop.Proposal_Zones__r == NULL || prop.Proposal_Zones__r.size() == 0)) {
            hasError = true;
            msg = System.Label.Advanced_Prop_can_t_be_created_for_Non_Digital_Proposal_Zones;
        }*/
        //If Pilot Proposal is Inactive
        if(!hasError && !prop.Active__c) {
            hasError = true;
            msg = System.Label.Advanced_Proposal_can_t_be_created_for_Inactive_Proposals;
        }

        //Check if Pilot Proposal’s Opportunity Stage is Closed/Lost (OR) Closed Lost to Competitor
        if(!hasError && (prop.Opportunity__r.StageName.equalsIgnoreCase('Closed Lost') || prop.Opportunity__r.StageName.equalsIgnoreCase('Closed Lost to Competitor'))) {
            hasError = true;
            msg = System.Label.Advanced_Prop_Cannot_be_created_for_Closed_Lost_Opportunities;
        }       

        if(!hasError && startDate!=NULL && endDate!=NULL && source.equalsIgnoreCase(System.Label.Digital_Hub))
        {
            if (startDate < prop.Start_Date__c || endDate > prop.End_Date__c)
            { 
                hasError = true;
                msg = System.Label.Adv_Prop_Dates_must_be_within_Prop_Dates_Range;
            }

            if (startDate < Date.today() || endDate < Date.today())
            { 
                hasError = true;
                msg = System.Label.Adv_Prop_Dates_must_be_in_future_Dates;
            }
        }

        return msg;
    }

    //Create Advanced Propoal in Salesforce
    private static Proposal__c insertAdvancedProposal(Proposal__c pilotProp, IncomingRequestWrapper request, Id recTypId)
    {        
        String advPropName = request.advancedPropName;
        String orderType = request.orderType;
        String productType = request.productType;
        
        Date startDate = (request.startDate != NULL ? Date.valueOf(request.startDate) : NULL);
        Date endDate = (request.endDate != NULL ? Date.valueOf(request.endDate) : NULL);          

        Proposal__c advProp;

        try
        {
            advProp = new Proposal__c(); 
            advProp.RecordTypeId = recTypId;
            advProp.Proposal_Owner__c = pilotProp.Opportunity__r.OwnerId;
            advProp.Source__c = source;
            advProp.Pilot_Proposal__c = pilotProp.Id;
            advProp.Name =  (advPropName != NULL ? advPropName : pilotProp.Name); 
            advProp.Order_Type__c = orderType;
            advProp.Product_Type__c = productType;
            advProp.Start_Date__c = (startDate != NULL ? startDate : pilotProp.Start_Date__c);
            advProp.End_date__c = (endDate != NULL ? endDate : pilotProp.End_date__c); 
            advProp.Division__c = pilotProp.Division__c;
            advProp.Region__c = pilotProp.Region__c;
            advProp.Sales_Office__c = pilotProp.Sales_Office__c;  
            advProp.Traffic_Order_Number__c = pilotProp.Traffic_Order_Number__c;
            advProp.Eclipse_Customer_ID__c = pilotProp.Eclipse_Customer_ID__c;
            advProp.Opportunity__c = pilotProp.Opportunity__c;
            advProp.Advertiser__c = pilotProp.Advertiser__c;
            advProp.Agency__c = pilotProp.Agency__c;
            advProp.Rep_Firm__c = pilotProp.Rep_Firm__c;
              
            INSERT advProp;  
        }
        catch(Exception ex){
            hasError = true;
            String msg = 'Failed to Create Advanced proposal-->'+ex.getMessage();
            System.debug(msg);
            throw ex; 
        }  
        return advProp;
    } 

    //Create Advanced Propoal in Salesforce
    private static String buildAOSDealReqPayload(Id recordId)
    {  
        String payload;

        System.debug('Inside buildAOSDealReqPayload recordId-->'+recordId);

        String dealQry = AOSWebServiceHelper.dealQuery;       
        String finalQuery = dealQry + ' WHERE Id =\''+ recordId +'\'';
        System.debug('finalQuery-->'+finalQuery);

        List<Proposal__c> advProps = Database.Query(finalQuery);
        System.debug('advProps-->'+advProps);

        try
        {
            Boolean isProd = AOSWebServiceHelper.isProductionOrg();
            List<AOSHelper.DealRequest> request= AOSWebServiceHelper.buildDealRequest(advProps,isProd);
            payload = JSON.serialize(request[0]);
        }
        catch(Exception ex){
            hasError = true;
            String msg = 'Failed to build AOS Deal Request-->'+ex.getMessage();
            System.debug(msg);
            throw ex; 
        }  

        System.debug('Deal request payload'+payload);

        return payload;
    }       

    global class IncomingRequestWrapper {
        global String userID; 
        global String source;       
        global String pilotId;       
        global String advancedPropId;       
        global String advancedPropName;       
        global String orderType;
        global String productType;       
        global String startDate;       
        global String endDate;       
    }

    global class OutgoingResponseWrapper {
        global boolean isSuccess;
        global String dealReqPayload;       
        global String planId;       
        global String planStatus;       
        global String errorMsg;       

        global OutgoingResponseWrapper(Boolean success, String data, String id, String status, String msg){
            isSuccess = success;
            dealReqPayload = data;
            planId = id;
            planStatus = status;
            errorMsg = msg;
        }
    } 
}