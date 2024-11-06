/**********************************************************************
 * @url: /services/apexrest/
 * @data:
 *  {} 
 * File..................: ThirdPartyDigitalInvReqServices.cls
 * Version...............: 1
 * Description...........: Jira Ticket : SRSF-2199
 * Change Log............: 
 * 1) SRSF-2592 : Zip_Codes__c,CustomZipCode__c logic added      
 * 2) SRSF-2694 : Updated to accept multiple DC products in a single request                           
 * 
*************************************************************************/
@RestResource(urlMapping='/SpectrumReachDIRServices/*')
global with sharing class ThirdPartyDigitalInvReqServices {

    global static final String GET_DIGITAL_CAMPAIGN = 'GetDigitalInventoryRequest';
    global static final String UPSERT_DIGITAL_CAMPAIGN = 'UpsertDigitalInventoryRequest';
    global static final String STATUS_PARTIALLY_SUCCESS = 'Partial Success';
    global static final String STATUS_SUCCESS = 'Success';
    global static final String STATUS_FAIL = 'Failure';
//  global static final String DRAFT_PLAN = 'Draft Plan'; // SRSF-3715: Commented
    global static final String PLAN_APPROVED = 'Plan Approved';  // SRSF-3715
    global static final String DRAFT_CAMPAIGN = '01 Draft Campaign';    
    global static final String PLAN_SUBMITTED = 'Plan Submitted';
    global static final String STREAMING_TV = 'Inventory_Request_New_Ads_Everywhere';
    global static final String PRE_ROLL = 'Pre_roll';
    global static final String DISPLAY = 'Display';
    global static final String SEARCH = 'Search';
    global static final String SOCIAL = 'Social'; // SRSF-3913    
    global static String Source;
    global static Boolean hasError;  
    global static Boolean isUpdate; 

    @HttpGet
    global static ResponseWrapper doGet() {
        RestRequest req = RestContext.request;
        String recordId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);        
        return getDigitalInventoryRequest(recordId);
    }

    @HttpPost
    global static OutgoingResponseWrapper doPost(IncomingRequestWrapper incomingThirdPartyRequestWrapper) 
    {        
        OutgoingResponseWrapper response;
        if(incomingThirdPartyRequestWrapper!=NULL && String.isNotBlank(incomingThirdPartyRequestWrapper.source)) {
            Source = incomingThirdPartyRequestWrapper.source ;
        } 

        String userId = incomingThirdPartyRequestWrapper.userID;

        Map<String,Object> mapOfThirdPartyLog = new Map<String, Object>{'JSON__c' => String.valueOf(incomingThirdPartyRequestWrapper) , 'API_Name__c' => 'SpectrumReachDIRServices', 'Source__c' => Source,'ObjectType__c' => UPSERT_DIGITAL_CAMPAIGN, 'User__c' =>userId};
        Third_Party_Logger__c thirdPartyLog = Log4SF.createThirdPartyLogger(mapOfThirdPartyLog, FALSE, new Third_Party_Logger__c());

        if(CommonUtilities.isStringNullOrEmpty(Source) || (!Source.equals(System.Label.Audience_Track) && !Source.equals(System.Label.SPP) && !Source.equals(System.Label.Architect) )){ 
            response = new OutgoingResponseWrapper(FALSE, System.Label.Invalid_Source + Source, NULL, NULL);
        } 
        else {
            System.debug('incomingThirdPartyRequestWrapper>>>'+incomingThirdPartyRequestWrapper);
            response = UpsertDigitalInventoryRequest(incomingThirdPartyRequestWrapper, thirdPartyLog);
        }

        return response;
    }


    // Used to get the Digital Campaign record data for the ID sent in the Request
    global static ResponseWrapper getDigitalInventoryRequest(String recordId) {

        ResponseWrapper resultWrapper;
        String message;
        Integer recCount = 0;  

        try { 
            if(!CommonUtilities.isStringNullOrEmpty(recordId)) {
                recCount = [SELECT count() FROM Digital_Campaign__c WHERE Id =:recordId];
                if(recCount>0)
                {
                    List<String> digitalCampaignfields = new List<String>();
                    List<Digital_Campaign_Fields__c> dirFields = Digital_Campaign_Fields__c.getall().values();

                    for(Digital_Campaign_Fields__c fld : dirFields){
                        digitalCampaignfields.add(fld.name);
                    }
                    //digitalCampaignfields.add('Max_Pending_Creative_End_Date_Record_St__c');
                    
                    String soql = 'SELECT ' + String.join( digitalCampaignfields, ', ') + ' FROM Digital_Campaign__c WHERE Id = \''+recordId+'\'';
                    
                    System.debug('In Get DigitalInventoryRequest method query --->'+soql); 
                    
                    Digital_Campaign__c digitalCampaignRec = Database.query(soql);
                    resultWrapper = new ResponseWrapper(TRUE, STATUS_SUCCESS, digitalCampaignRec);
                }
                else {
                    message = System.Label.No_Digital_Campaign_Error;
                    resultWrapper = new ResponseWrapper(FALSE, message, NULL);
                }
            }
            else {
                message = System.Label.Digital_Campaign_Id_Mandatory;
                resultWrapper = new ResponseWrapper(FALSE, message, NULL);
            }                
        }
        catch(Exception ex)
        {
            message = ex.getMessage()+' Line : '+ ex.getLineNumber();
            resultWrapper = new ResponseWrapper(FALSE, message, NULL);
            Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => STATUS_FAIL, 'Error_Message__c' =>message, 'ObjectType__c' =>GET_DIGITAL_CAMPAIGN} ,TRUE ,new Third_Party_Logger__c());
        } 
        return resultWrapper;
    }

    /*
      This method is used for creating and updating Digital Inventory requests (Digital Campaign) from Third party Services       
      ---> We can update all fields except Proposal, RecordType    
    */
    global static OutgoingResponseWrapper UpsertDigitalInventoryRequest(IncomingRequestWrapper incomingRequestWrapper, Third_Party_Logger__c thirdPartyLog) 
    {      
        Id recordTypeId;
        OutgoingResponseWrapper resultWrapper;
        String message;    
        List<String> successRecs = new List<String>();
        Map<String, String> failedRecs = new Map<String, String>();
        List<Digital_Campaign__c> toUpsertDCs = new List<Digital_Campaign__c>();

        System.debug('UpsertDigitalInventoryRequest request--->'+incomingRequestWrapper);

        try
        {  
            List<DigitalCampaignWrapper> digitalCampaigns = incomingRequestWrapper.digitalCampaignList;
            System.debug('To del stmt: digitalCampaigns--->'+digitalCampaigns);

            if(NULL != digitalCampaigns && digitalCampaigns.Size() > 0)
            {   
               for(DigitalCampaignWrapper dcWrapper : digitalCampaigns)
                {   
                    String recTypeName;
                    hasError = isUpdate = false;
                    Digital_Campaign__c digitalCampaign = dcWrapper.digitalCampaign;
                    Boolean isDraftDC = dcWrapper.isDraftPlan;
                    String campaign = digitalCampaign.Campaign_Name__c;

                    //Check Create or Update request 
                    if(!CommonUtilities.isStringNullOrEmpty(digitalCampaign.Id)){
                        isUpdate = TRUE;
                    } else {
                        digitalCampaign.Id = NULL;
                    }

                    if(!CommonUtilities.isStringNullOrEmpty(dcWrapper.product)) 
                    {
                        recTypeName = getRecordTypeDevName((dcWrapper.product).trim());

                        if(!CommonUtilities.isStringNullOrEmpty(recTypeName)) {
                            recordTypeId = Schema.SObjectType.Digital_Campaign__c.getRecordTypeInfosByDeveloperName().get(recTypeName).getRecordTypeId(); 
                        }
                        else{
                            hasError = true;
                            message = System.Label.Invalid_Product_for_Digital_Campaign; 
                        }
                    }
                    else{
                        hasError = true;
                        message = System.Label.Product_is_mandatory_for_Digital_Campaign; 
                    } 

                    //Check Mandatory fields have values in Create request 
                    if(!hasError) 
                    {   
                        System.debug('isUpdate--->'+isUpdate);
                        Digital_Campaign__c originalDC = new Digital_Campaign__c();
                         System.debug('message--->'+message);  
                        if(recTypeName.equalsIgnoreCase(STREAMING_TV)) {
                            System.debug('recTypeName--->'+recTypeName);  
                            message = validateStreamingTVDCReq(digitalCampaign, originalDC, isDraftDC, thirdPartyLog);
                        }
                        else{
                            System.debug('recTypeName--->'+recTypeName);
                            message = validateOtherDCReq(digitalCampaign, originalDC, recTypeName,isDraftDC);
                        }                        
                    }
                    System.debug('Error message--->'+message);
                                        
                    if(CommonUtilities.isStringNullOrEmpty(message))
                    {
                        //Set Common data 
                        digitalCampaign.RecordTypeId = recordTypeId;
                        digitalCampaign.Source__c = Source; 
                        toUpsertDCs.add(digitalCampaign);
                    }  
                    else{
                        failedRecs.put(digitalCampaign.Campaign_Name__c, message);    
                    }
                }      
                System.debug('toUpsertDCs-->'+toUpsertDCs); 
                System.debug('Record failed-->'+failedRecs);                   
            } 
            else{
                hasError = true;
                message = System.Label.DigitalCampaign_List_Mandatory;              
                thirdPartyLog = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => STATUS_FAIL,'Error_Message__c' => message} ,TRUE ,thirdPartyLog);      
            } 
            
            if(toUpsertDCs.size() > 0)
            {
                System.debug('DigitalCampaign to Upsert>>>>>'+toUpsertDCs);

                Database.UpsertResult[] recsToUpsert = Database.Upsert(toUpsertDCs, false);
                for(Integer i = 0 ; i < recsToUpsert.size(); i++) 
                {
                    if(recsToUpsert[i].isSuccess()) {
                        if(recsToUpsert[i].isCreated()) {
                            successRecs.add(toUpsertDCs[i].Campaign_Name__c+' : '+ String.valueof(recsToUpsert[i].getId()) + ' was Created');                            
                        } else {                            
                            successRecs.add(toUpsertDCs[i].Campaign_Name__c+' : '+ String.valueof(recsToUpsert[i].getId()) + ' was Updated');
                        }
                    }
                    else{                                          
                        String error = recsToUpsert[i].getErrors().get(0).getMessage();
                        failedRecs.put(toUpsertDCs[i].Campaign_Name__c, error);                        
                    }
                }
                System.debug('Record(s) created successfully-->'+successRecs); 
                System.debug('Record(s) failed-->'+failedRecs); 
                String status =  setStatus(successRecs.size(), failedRecs.size()); 
                Boolean isSuccess = successRecs.size()>0 ? TRUE : FALSE ;
                resultWrapper = new OutgoingResponseWrapper(isSuccess, status, successRecs, failedRecs);
                Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => status} ,TRUE,thirdPartyLog);
            }
            else{
                resultWrapper = new OutgoingResponseWrapper(FALSE, STATUS_FAIL, NULL, failedRecs);
            }
        }
        catch(Exception ex)
        {           
            message = ex.getMessage()+' at Line : '+ ex.getLineNumber();
            resultWrapper = new OutgoingResponseWrapper(FALSE, STATUS_FAIL, NULL, failedRecs);

            Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => STATUS_FAIL, 'Error_Message__c' =>message } ,TRUE , thirdPartyLog);
        }       
        return resultWrapper;
    }

    private static String getRecordTypeDevName(String dcProduct)
    {
        String recordType;

        if(dcProduct.equalsIgnoreCase('StreamingTV') || dcProduct.equalsIgnoreCase('STTV')) {
            recordType = STREAMING_TV;
        }  
        else if(dcProduct.equalsIgnoreCase(PRE_ROLL)) {
            recordType = PRE_ROLL;
        }
        else if(dcProduct.equalsIgnoreCase(DISPLAY)) {
            recordType = DISPLAY;
        }
        else if(dcProduct.equalsIgnoreCase(SEARCH)) {
            recordType = SEARCH;
        }
        else if(dcProduct.equalsIgnoreCase(SOCIAL)) { //SRSF-3913
            recordType = SOCIAL;
        }  

        return recordType;
    }

    //Check validations for both Create/Update scenarios
    private static String validateOtherDCReq(Digital_Campaign__c dcRecord, Digital_Campaign__c originalDC, String product, Boolean isDraftDC)
    {
        String msg;
        if(CommonUtilities.isStringNullOrEmpty(dcRecord.Proposal__c))
        {
            System.debug('Required Fields missing for :'+dcRecord.Campaign_Name__c); 
            hasError = true;
            msg = System.Label.Required_Fields_missing_for_Digital_Campaign; 
        } 

        if(!hasError) 
        { 
            if(isDraftDC){
                dcRecord.Status__c = DRAFT_CAMPAIGN;
            }
            else {
                hasError = true;
                msg = System.Label.DCRecord_can_be_edited_in_Draft_Campaign_Status;
            }
        }

        if(!hasError) {
            msg = isValidProposal(dcRecord, originalDC, product);
        } 

        return msg;
    }

    private static String validateStreamingTVDCReq(Digital_Campaign__c dcRecord, Digital_Campaign__c originalDC, Boolean isDraftDC, Third_Party_Logger__c thirdPartyLog)
    {
        String msg;
        Map<String, String> mapNielSonDMAnames = new Map<String, String>();
        Map<String, String> mapSRZones = new Map<String, String>();

        String srZones = dcRecord.Spectrum_Reach_Zones__c;
        String zipcodes = dcRecord.Zip_Codes__c;
        String dmas = dcRecord.DMAs__c;        

        //dcRecord.Status__c =  isDraftDC ? DRAFT_PLAN : PLAN_SUBMITTED; //SRSF-3715: Commented
        dcRecord.Status__c =  isDraftDC ? PLAN_SUBMITTED : PLAN_APPROVED ; //SRSF-3715: Added
        dcRecord.Approved_as_Ordered__c = isDraftDC ? FALSE : TRUE; //SRSF-3715: Added

        //Check Mandatory fields have value in Create request 
        //SRSF-3715: Added Gross Campaign cost, AdsE_Platform_s__c, Total_Impressions__c
        if( !isUpdate && 
           (CommonUtilities.isStringNullOrEmpty(dcRecord.Proposal__c) || 
            CommonUtilities.isStringNullOrEmpty(dcRecord.Campaign_Name__c) || 
            CommonUtilities.isStringNullOrEmpty(dcRecord.Product_Type__c) ||
            CommonUtilities.isStringNullOrEmpty(dcRecord.AdsE_Genre_s__c) ||
            (CommonUtilities.isStringNullOrEmpty(srZones) && 
            CommonUtilities.isStringNullOrEmpty(dmas) &&
            CommonUtilities.isStringNullOrEmpty(zipcodes)) || 
            NULL == dcRecord.Desired_Budget__c ||                 
            NULL == dcRecord.Campaign_Start_Date__c || 
            NULL == dcRecord.Campaign_End_Date__c  ||
            NULL == dcRecord.Gross_Campaign_Cost__c ||
            NULL == dcRecord.Total_Impressions__c ||
            NULL == dcRecord.AdsE_Platform_s__c
            )) {
             System.debug('Required Fields missing for Streaming TV request>>>>>>'); 
             hasError = true;
             msg = System.Label.Required_Fields_missing_for_Digital_Campaign; 
        }

        if(!hasError && ((!CommonUtilities.isStringNullOrEmpty(srZones) && 
            (!CommonUtilities.isStringNullOrEmpty(dmas) || !CommonUtilities.isStringNullOrEmpty(zipcodes) || 
            (!CommonUtilities.isStringNullOrEmpty(dmas) && !CommonUtilities.isStringNullOrEmpty(zipcodes)))) || 
            (!CommonUtilities.isStringNullOrEmpty(dmas) && !CommonUtilities.isStringNullOrEmpty(zipcodes))))
        {  
            System.debug('Combination of DMA or SR Zone or ZipCode not allowed>>>>>>');
            hasError = true;
            msg = System.Label.SRZones_or_DMA_should_have_value; 
        }

        /*SRSF-3715: Commented based on discussion as AdsE_Platform_s__c is mandatory in both 'Plan Submitted' and 'Plan Approved' status
        if(!isDraftDC && CommonUtilities.isStringNullOrEmpty(dcRecord.AdsE_Platform_s__c) && !hasError){
            hasError = true;
            msg = System.Label.Select_Platform_to_select_Status_as_Plan_Submitted; 
        }*/      

        if(!hasError) {
            msg = isValidProposal(dcRecord, originalDC, STREAMING_TV);
        }

        // Added below if condition for SRSF-2592      
        dcRecord.CustomZipCode__c = (!isUpdate && !CommonUtilities.isStringNullOrEmpty(zipcodes))? true : false;
       
        if(!hasError) 
        {
            List<Zipcode_Mapping__c> lstZipCodes = [SELECT Id, Nielsen_DMA_Name__c, SR_Zone_Name__c FROM Zipcode_Mapping__c WHERE Nielsen_DMA_Name__c != NULL OR SR_Zone_Name__c != NULL];

            if(!CommonUtilities.isListNullOrEmpty(lstZipCodes)){
                mapSRZoneAndDMAValues(lstZipCodes, mapNielSonDMAnames, mapSRZones); 
            }else{
                hasError = true;
                msg = System.Label.No_data_found_in_ZipCode_Mapping; 
                thirdPartyLog = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => STATUS_FAIL,'Error_Message__c' => msg} ,TRUE , thirdPartyLog);
            }
        }

        // verify requested DMA values are valid                
        if(!CommonUtilities.isStringNullOrEmpty(dmas) && !hasError) {
            System.debug('Entered in DMA>>>>');
            if (isUpdate) { 
                if(!CommonUtilities.isStringNullOrEmpty(originalDC.Spectrum_Reach_Zones__c)){
                    dcRecord.Spectrum_Reach_Zones__c='';
                }
                if (!CommonUtilities.isStringNullOrEmpty(originalDC.Zip_Codes__c)){ //Condition added for  SRSF-2562 
                    dcRecord.Zip_Codes__c = '';  
                    dcRecord.CustomZipCode__c = false;  
                }
            }
            else{
                List<String> lstDMA = dmas.split(';');
                for(String dma : lstDMA){
                    if(!mapNielSonDMAnames.containsKey(dma)){
                        hasError = true;
                        msg = System.Label.DMA_Not_Found_ZipCode_Mapping + dma; 
                        thirdPartyLog = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => STATUS_FAIL,'Error_Message__c' => msg} ,TRUE ,thirdPartyLog);
                    }
                }
            }
        }               
        // verify requested SR Zone values are valid                
        else if(!CommonUtilities.isStringNullOrEmpty(srZones) && !hasError){
            System.debug('Entered in Spectrum_Reach_Zones__c>>>>');
            if (isUpdate) {
                if(!CommonUtilities.isStringNullOrEmpty(originalDC.DMAs__c)){
                    dcRecord.DMAs__c='';
                }
                if(!CommonUtilities.isStringNullOrEmpty(originalDC.Zip_Codes__c)) { // Condition added for SRSF-2562  
                    dcRecord.Zip_Codes__c = '';  
                    dcRecord.CustomZipCode__c = false;   
                }    
            }
            else {
                List<String> lstSRZones = srZones.split(';');
                for(String zone : lstSRZones){
                   if(!mapSRZones.containsKey(zone)){
                        hasError = true;
                        msg = System.Label.SRZone_Not_Found_In_ZipCode_Mapping + zone;  
                        thirdPartyLog = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => STATUS_FAIL,'Error_Message__c' => msg} ,TRUE ,thirdPartyLog);
                    }                   
                }
            }
        }
        // below Condition added for  SRSF-2592  
        else if(!CommonUtilities.isStringNullOrEmpty(zipcodes) && !hasError)
        {
            System.debug('Entered in Zipcodes>>>>'); 
            dcRecord.CustomZipCode__c = true;
            if (isUpdate) {
                if(!CommonUtilities.isStringNullOrEmpty(originalDC.DMAs__c)){
                    dcRecord.DMAs__c='';
                }
                if(!CommonUtilities.isStringNullOrEmpty(originalDC.Spectrum_Reach_Zones__c)) { 
                    dcRecord.Spectrum_Reach_Zones__c = ''; 
                }    
            }
        }  

        return msg;
    }

    private static String isValidProposal(Digital_Campaign__c dcRecord, Digital_Campaign__c originalDC, String product)
    {
        String msg;
        List<Proposal__c> props = [SELECT Id, Active__c, Opportunity__r.OwnerId, RecordType.DeveloperName FROM Proposal__c WHERE Id = :dcRecord.Proposal__c];
        if(props.size()>0) {
            if(props[0].RecordType.DeveloperName == 'Opportunity_Budget'){
                hasError = true;
                msg = System.Label.DC_cannot_be_created_for_an_Opp_Budget;  
            } else if(props[0].Active__c == false){
                hasError = true;
                msg = System.Label.DC_cannot_be_created_for_an_Inactive_Proposal;
            } else {
                dcRecord.OwnerId = props[0].Opportunity__r.OwnerId;
            }  
        }
        else{
            hasError = true;
            msg = System.Label.Invalid_Proposal; 
        } 

        if(isUpdate && !hasError) 
        {            
            List<Digital_Campaign__c> dcList = [SELECT ID, Status__c, DMAs__c, Spectrum_Reach_Zones__c, Proposal__c, Proposal__r.Opportunity__r.OwnerId, Zip_Codes__c, CustomZipCode__c FROM Digital_Campaign__c WHERE Id = :dcRecord.Id];

            if(dcList.Size()>0)
            {
                originalDC = dcList[0];
                System.debug('dcRec>>>'+originalDC); 
                if(dcRecord.Proposal__c != originalDC.Proposal__c) {
                    hasError = true;
                    msg = System.Label.Digital_Campaign_cannot_be_Reparented_with_different_Proposal;
                }                

                /* SRSF-3715 : Removed below condition for STTV only from if condition
                 originalDC.Status__c != DRAFT_PLAN && product.equalsIgnoreCase(STREAMING_TV)) */
                if( originalDC.Status__c != DRAFT_CAMPAIGN && !product.equalsIgnoreCase(STREAMING_TV) 
                    && !hasError) {   
                    hasError = true;
                    msg = System.Label.DCRecord_can_be_edited_in_Draft_Plan_Status;
                }
            } 
            else {
                msg = System.Label.Invalid_Digital_Campaign_ID;
            }
        }

        return msg;
    }

    private static void mapSRZoneAndDMAValues(List<Zipcode_Mapping__c> lstZipCodes, Map<String, String> mapNielSonDMAnames, Map<String, String> mapSRZones){
        for(Zipcode_Mapping__c zipCode : lstZipCodes ){
            // Retrieve all the DMA values from ZipCode Mapping object and storing in mapNielSonDMAnames 
            if(!mapNielSonDMAnames.containsKey(zipCode.Nielsen_DMA_Name__c) && !CommonUtilities.isStringNullOrEmpty(zipCode.Nielsen_DMA_Name__c)){
                mapNielSonDMAnames.put((zipCode.Nielsen_DMA_Name__c).trim(), (zipCode.Nielsen_DMA_Name__c).trim());
            }
            // Retrieve all the SR Zone values from ZipCode Mapping object and storing in mapSRZones 
            if(!mapSRZones.containsKey(zipCode.SR_Zone_Name__c) && !CommonUtilities.isStringNullOrEmpty(zipCode.SR_Zone_Name__c)){
                mapSRZones.put((zipCode.SR_Zone_Name__c).trim(),(zipCode.SR_Zone_Name__c).trim());
            }
        }
    }

    private static String setStatus(Integer cntSuccess, Integer cntFailed)
    {
        String status = STATUS_SUCCESS;
        if(cntFailed > 0 && cntSuccess >0) {
            status = STATUS_PARTIALLY_SUCCESS;
        }  
        else if(cntSuccess == 0) {
            status = STATUS_FAIL;
        }
        return status;
    }

    global class IncomingRequestWrapper {
        global String userID; 
        global String source;       
        global List<DigitalCampaignWrapper> digitalCampaignList;
    }

    global class DigitalCampaignWrapper {        
        global String product; 
        global Boolean isDraftPlan; 
        global Digital_Campaign__c digitalCampaign;
    }

    global class ResponseWrapper {
        global boolean isSuccess;
        global String message;
        global SObject digitalCampaignData;
        global ResponseWrapper(Boolean success, String msg, SObject result){
            isSuccess = success;
            message = msg;
            digitalCampaignData = result;
        }
    }

    global class OutgoingResponseWrapper {
        global boolean isSuccess;
        global String message;
        global List<String> successDigitalCampaigns;
        global Map<String, String> failedDigitalCampaigns;

        global OutgoingResponseWrapper(Boolean success, String msg, List<String> successRecs, Map<String, String> failedRecs){
            isSuccess = success;
            message = msg;
            successDigitalCampaigns = successRecs;
            failedDigitalCampaigns = failedRecs;
        }
    } 
}