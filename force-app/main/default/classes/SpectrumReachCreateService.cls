/*
###########################################################################
# File..................: SpectrumReachCreateService.cls
# Version...............: 1
# Created by............: Ishwar bajpai
# Created Date..........: 03-July-2018
# Last Modified by......: Abhilash Vangari
# Last Modified Date....: 19-July 2018
# Description...........: Jira Ticket : SRSF-1130
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/

@RestResource(urlMapping='/SpectrumReachCreate/*')
global with sharing class SpectrumReachCreateService {
    global STATIC FINAL String ACCOUNT_SEARCH = 'AccountSearch';
    global STATIC FINAL String CREATE_ACCOUNT = 'CreateAccount';
    global STATIC FINAL String CREATE_OPPORTUNITY = 'CreateOpportunity';
    global STATIC FINAL String CREATE_LEAD = 'CreateLead';
    global STATIC String Source = Label.SPP_Search;

    @HttpGet
    global static String doGet() {
        return 'SpectrumReachCreate API is Alive!';
    }

    @HttpPost
    global static OutgoingResponseWrapper doPost(IncomingSPPRequestWrapper incomingThirdPartyRequestWrapper) {
      
        Source = (incomingThirdPartyRequestWrapper!=NULL && String.isNotBlank(incomingThirdPartyRequestWrapper.source) )? incomingThirdPartyRequestWrapper.source : Source;
        Map<String,Object> mapOfThirdPartyLog = new Map<String, Object>{'JSON__c' => String.valueOf(incomingThirdPartyRequestWrapper) , 'API_Name__c' => 'SpectrumReachCreate', 'Source__c' => Source };

        Third_Party_Logger__c thirdPartyLogger = Log4SF.createThirdPartyLogger(mapOfThirdPartyLog,false , new Third_Party_Logger__c());

        return processIncomingRequest(incomingThirdPartyRequestWrapper ,thirdPartyLogger );
    }

    global static OutgoingResponseWrapper processIncomingRequest(IncomingSPPRequestWrapper incomingRequestWrapper, Third_Party_Logger__c thirdPartyLogger) {
        if (NULL != incomingRequestWrapper) {
          try{
            if (String.isBlank(incomingRequestWrapper.api_Type)) {
                thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure' , 'Error_Message__c' =>Label.API_Type_Can_t_be_Blank} ,TRUE ,thirdPartyLogger);
                return populateResultWrapper(NULL , NULL ,Label.API_Type_Can_t_be_Blank, NULL); 
            }
            else if (ACCOUNT_SEARCH.equalsIgnoreCase(incomingRequestWrapper.api_Type)) {
                return accountSearch(incomingRequestWrapper, thirdPartyLogger);
            }
            else if (CREATE_ACCOUNT.equalsIgnoreCase(incomingRequestWrapper.api_Type)) {
                return accountCreation(incomingRequestWrapper, thirdPartyLogger);
            }
            else if (CREATE_OPPORTUNITY.equalsIgnoreCase(incomingRequestWrapper.api_Type)) {
                return opportunityCreation(incomingRequestWrapper, thirdPartyLogger);
            }
            else if (CREATE_LEAD.equalsIgnoreCase(incomingRequestWrapper.api_Type)) {
                return leadCreation(incomingRequestWrapper, thirdPartyLogger);
            }
            else{
                thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure','Error_Message__c' => Label.API_Type_Error_Message ,'User__c' =>incomingRequestWrapper.userID } ,TRUE ,thirdPartyLogger);
                return populateResultWrapper(incomingRequestWrapper.api_Type , NULL ,Label.API_Type_Error_Message,NULL);    
            }

          }
          catch (Exception ex) {
            thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure','Error_Message__c' => ex.getMessage() ,'User__c' =>incomingRequestWrapper.userID } ,TRUE ,thirdPartyLogger);
            return populateResultWrapper(incomingRequestWrapper.api_Type , NULL ,ex.getMessage(),NULL); 
          }

        }
        return NULL;
    }

    global static OutgoingResponseWrapper populateResultWrapper( String apiType , List<SObject> recordList, String errorMsg, List<String> resList) {
        OutgoingResponseWrapper resultWrapper;

        if(String.isNOTBlank(apiType)){
            if(apiType.equalsIgnoreCase(ACCOUNT_SEARCH)){
                if ((NULL == recordList || (NULL != recordList && recordList.isEmpty())) && String.isNotBlank(errorMsg) ){
                    resultWrapper = new OutgoingResponseWrapper(apiType, FALSE, errorMsg, NULL, NULL);
                }
                else{
                    resultWrapper = new OutgoingResponseWrapper(apiType, TRUE, NULL, recordList, NULL);
                }
            }
            else if( apiType.equalsIgnoreCase(CREATE_ACCOUNT) || apiType.equalsIgnoreCase(CREATE_OPPORTUNITY) || apiType.equalsIgnoreCase(CREATE_LEAD) ){
                if ((NULL == resList || (NULL != resList && resList.isEmpty())) && String.isNotBlank(errorMsg) ){
                    resultWrapper = new OutgoingResponseWrapper(apiType, FALSE, errorMsg, NULL, NULL);
                }
                else{
                    resultWrapper = new OutgoingResponseWrapper(apiType, TRUE, NULL, NULL, resList);
                }
            }
            else{
                resultWrapper = new OutgoingResponseWrapper(apiType, FALSE, errorMsg, NULL, NULL);
            }

        }
        else{
            resultWrapper = new OutgoingResponseWrapper(NULL, false, errorMsg, NULL, NULL);
        }

        return resultWrapper;
    }

    global static OutgoingResponseWrapper accountSearch(IncomingSPPRequestWrapper incomingRequestWrapper, Third_Party_Logger__c thirdPartyLogger) {

        if( String.isNotBlank(incomingRequestWrapper.acc_EclipseId)){

            List<Traffic_Id_Element__c> trafficIdElmnts = [Select Account__c FROM Traffic_Id_Element__c WHERE Export_System_Id__c = :incomingRequestWrapper.acc_EclipseId AND Traffic_Type__c = 'Account' AND isdeleted =  FALSE];
            if(trafficIdElmnts.size()>0){
                Set<Id> accountIds = new Set<Id>();
                for(Traffic_Id_Element__c trfcIdElmt : trafficIdElmnts ){
                    if(trfcIdElmt.Account__c!=NULL)
                       accountIds.add(trfcIdElmt.Account__c);
                }

                if(accountIds.size()>0){
                    List<Account> accountList = Database.query(prepareAccountQuery());
                    if(accountList.size()>0){
                        thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Success' ,'ObjectType__c' => ACCOUNT_SEARCH ,'User__c' =>incomingRequestWrapper.userID } ,TRUE ,thirdPartyLogger);
                        return populateResultWrapper(incomingRequestWrapper.api_Type , accountList ,NULL,NULL);
                    }
                }
            }
        }
        
        //Account Fuzzy Logic
        if (String.isNotBlank(incomingRequestWrapper.acc_Name)) {
            Account account = new Account(Name = incomingRequestWrapper.acc_Name, Source__c = Label.SPP_Search );
            
            if(String.isNotBlank(incomingRequestWrapper.acc_PhoneNo)){
              account.Phone = incomingRequestWrapper.acc_PhoneNo;
            }
            
            if(incomingRequestWrapper.acc_Address!=NULL){
                if(String.isNotBlank(incomingRequestWrapper.acc_Address.acc_Street)){   
                    account.BillingStreet = incomingRequestWrapper.acc_Address.acc_Street;
                }
                if(String.isNotBlank(incomingRequestWrapper.acc_Address.acc_City)){ 
                    account.BillingCity = incomingRequestWrapper.acc_Address.acc_City;
                }
                if(String.isNotBlank(incomingRequestWrapper.acc_Address.acc_Country)){  
                    account.BillingCountry = incomingRequestWrapper.acc_Address.acc_Country;
                }
                if(String.isNotBlank(incomingRequestWrapper.acc_Address.acc_ZipCode)){  
                    account.BillingPostalCode = incomingRequestWrapper.acc_Address.acc_ZipCode;
                }
                if(String.isNotBlank(incomingRequestWrapper.acc_Address.acc_State)){    
                    account.BillingState = incomingRequestWrapper.acc_Address.acc_State;
                }
            }
            System.debug('Account::'+account);

            SavePoint accInsertSavePoint = Database.setSavePoint();
            List<sObject> duplicateRecords = new List<sObject>();
            String errorMsg = '';

            Database.SaveResult saveResult = Database.insert(account, false);
            if (saveResult.isSuccess()) {
                System.debug('In Success');
                Database.rollback(accInsertSavePoint);
            }
            else{
                System.debug('In error');
                for (Database.Error error : saveResult.getErrors()) {
                    System.debug('Error::'+error);
                    if (error instanceof Database.DuplicateError) {

                        Database.DuplicateError duplicateError = (Database.DuplicateError)error;
                        System.debug('duplicateError::'+duplicateError);
                        Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
                        System.debug('duplicateResult::'+duplicateResult);
                        errorMsg = 'Duplicate Error: ' + duplicateResult.getErrorMessage();
                        Datacloud.MatchResult[] matchResults = duplicateResult.getMatchResults();
                        Datacloud.MatchResult matchResult = matchResults[0];
                        Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();
                        for (Datacloud.MatchRecord matchRecord : matchRecords) {
                            System.debug('MatchRecord: ' + matchRecord.getRecord());
                            duplicateRecords.add(matchRecord.getRecord());
                        }
                    }
                }

            }

            if(duplicateRecords.size()>0){
                Set<Id> accountIds = new Set<Id>();
                for(sObject sobj : duplicateRecords){
                    accountIds.add(sobj.Id);
                }
                
                List<Account> accountList = Database.query(prepareAccountQuery());

                thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Success' ,'ObjectType__c' => ACCOUNT_SEARCH ,'User__c' =>incomingRequestWrapper.userID } ,TRUE ,thirdPartyLogger);
                return populateResultWrapper(incomingRequestWrapper.api_Type , accountList ,NULL,NULL);             
            }
        }
        
        thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure' ,'Error_Message__c' => Label.No_Record_Found_Error_Message,'ObjectType__c' => ACCOUNT_SEARCH ,'User__c' =>incomingRequestWrapper.userID } ,TRUE ,thirdPartyLogger);
        return populateResultWrapper(incomingRequestWrapper.api_Type , NULL ,Label.No_Record_Found_Error_Message,NULL); 
    }

    global static OutgoingResponseWrapper accountCreation(IncomingSPPRequestWrapper incomingRequestWrapper, Third_Party_Logger__c thirdPartyLogger) {

        if(NULL != incomingRequestWrapper.accountList && incomingRequestWrapper.accountList.size()>0 ){

            List<String> successIds = new List<String>();
            List<Account> accToInsert = new List<Account>();
            List<Contact> conToInsert = new List<Contact>();
            Map<Integer,Contact> mapOfAccContact = new Map<Integer,Contact>();
            Integer count = 0;

            for( accountWrapper accwrap : incomingRequestWrapper.accountList){
                if(accwrap.account!=NULL){
                    accwrap.account.OwnerId = incomingRequestWrapper.userID;
                    accToInsert.add(accwrap.account);
                    if(accwrap.contact!=NULL){
                        mapOfAccContact.put(count,accwrap.contact);
                    }
                    count++;
                }
            }

            List<Database.SaveResult> results = Database.Insert(accToInsert,TRUE);
            List<AccountTeamMember> accTeamMbrLst = new List<AccountTeamMember>();

            for(Integer i=0; i < results.size(); i++){
                if(results[i].isSuccess()){
                    successIds.add(results[i].getId());
                    accTeamMbrLst.add(new AccountTeamMember(AccountId = results[i].getId() ,UserId = incomingRequestWrapper.userID,TeamMemberRole = 'Account Executive',OpportunityAccessLevel = Label.AccountTeamMeberAccessLevel,AccountAccessLevel=Label.AccountTeamMeberAccessLevel, CaseAccessLevel =Label.AccountTeamMeberAccessLevel));
                    if(mapOfAccContact.containsKey(i)){
                        Contact con = mapOfAccContact.get(i);
                        con.AccountId = results[i].getId();
                        conToInsert.add(con);
                    }
                }
            }

            if(conToInsert.size()>0)
              results = Database.Insert(conToInsert,TRUE);
            if(accTeamMbrLst.size()>0) Insert accTeamMbrLst;
            
            thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Success' ,'ObjectType__c' => CREATE_ACCOUNT ,'User__c' =>incomingRequestWrapper.userID } ,TRUE ,thirdPartyLogger);
            return populateResultWrapper(incomingRequestWrapper.api_Type , NULL ,NULL,successIds);  

        }
        else{
            thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure','Error_Message__c' => Label.AccountList_Mandatory_Error_Message ,'ObjectType__c' => CREATE_ACCOUNT ,'User__c' =>incomingRequestWrapper.userID } ,TRUE ,thirdPartyLogger);
            return populateResultWrapper(incomingRequestWrapper.api_Type , NULL ,Label.AccountList_Mandatory_Error_Message,NULL);   
        }

    }

    global static OutgoingResponseWrapper opportunityCreation(IncomingSPPRequestWrapper incomingRequestWrapper, Third_Party_Logger__c thirdPartyLogger) {
        // Start: SRSF-1789 : 04-07-2019
        Map<Id, Opportunity> acctIds = new Map<Id,Opportunity>();
        Boolean allowUser = FALSE; 
        List<AccountTeamMember> lstATM = new List<AccountTeamMember> ();
        // End: SRSF-1789 : 04-07-2019
        if(NULL != incomingRequestWrapper.opportunityList && incomingRequestWrapper.opportunityList.size()>0 ){

            User usrProfileName = [select Id, Profile.Name from User where Id = :incomingRequestWrapper.userID]; // SRSF-1789 : 04-07-2019
            
            // START: SRSF-3866
            List<String> dmaList= new List<String>(); 
            dmaList.addAll(ApexUtils.getPickListValues('Opportunity', 'DMA__c'));  
            // END : SRSF-3866

            for(Opportunity opp : incomingRequestWrapper.opportunityList ){
                acctIds.put(opp.AccountId,opp); // SRSF-1789 : 04-07-2019                          
            }
            // Start: SRSF-1789 : 04-07-2019
            if(incomingRequestWrapper.source == 'SPP' || (usrProfileName != null && usrProfileName.Profile.Name == 'System Administrator')) {               
                allowUser = TRUE;     
                System.debug('allowUser:::'+allowUser);
            } 

            if(!allowUser){
                lstATM = [select Id, AccountId , UserId from AccountTeamMember 
                                    WHERE AccountId IN: acctIds.keySet() AND UserId =: incomingRequestWrapper.userID
                                    AND (TeamMemberRole = 'Account Executive' OR TeamMemberRole  = 'Sales Manager')];  // OR TeamMemberRole = 'LSM'
            }

            if(!allowUser && lstATM.size() == 0){
                 return populateResultWrapper(incomingRequestWrapper.api_Type , NULL ,Label.No_Permission_to_Create_an_Opportunity,NULL);  
            }else{         
            // End: SRSF-1789 : 04-07-2019 

                // Start: SRSF-2290 : 12-10-2020
                System.debug('acctIds>>>>'+acctIds);

                Map<ID, Account> acctMap = new Map<ID, Account>([Select Id, Agency__c, Agency__r.RecordType.DeveloperName, Rep_Firm__c,Rep_Firm__r.RecordType.DeveloperName FROM Account WHERE Id IN :acctIds.keySet()]);
                System.debug('acctMap>>>>>>'+acctMap);

                for(Opportunity opp : incomingRequestWrapper.opportunityList ){
                    opp.OwnerId = incomingRequestWrapper.userID;

                    // START: SRSF-3866
                    if(incomingRequestWrapper.source == 'SPP' && !CommonUtilities.isListNullOrEmpty(dmaList) && !dmaList.contains(opp.DMA__c)) {
                        opp.DMA__c = ''; 
                    } 
                    // END: SRSF-3866
                                   
                    if(CommonUtilities.isStringNullOrEmpty(opp.Agency_Account__c) && acctMap.Size()>0 && acctMap.get(opp.AccountId).Agency__c!=NULL) {
                        if(acctMap.get(opp.AccountId).Agency__r.RecordType.DeveloperName == 'Agency_Account' || acctMap.get(opp.AccountId).Agency__r.RecordType.DeveloperName == 'In_House_Agency_Account') {  // SRSF-3447: Added 'In House Agency Account' check                          
                            opp.Agency_Account__c = acctMap.get(opp.AccountId).Agency__c;
                        } else {
                            return populateResultWrapper(incomingRequestWrapper.api_Type , NULL,Label.Agency_RecordType_Error,NULL);
                        }    
                    }
                    if(CommonUtilities.isStringNullOrEmpty(opp.Rep_Firm__c) && acctMap.Size()>0 && acctMap.get(opp.AccountId).Rep_Firm__c!=NULL) {
                        if (acctMap.get(opp.AccountId).Rep_Firm__r.RecordType.DeveloperName == 'Rep_Firm') {
                            opp.Rep_Firm__c = acctMap.get(opp.AccountId).Rep_Firm__c;
                        } else {
                            return populateResultWrapper(incomingRequestWrapper.api_Type , NULL,Label.Repfirm_RecordType_Error,NULL);
                        }    
                    }                             
                }
                // End: SRSF-2290 : 12-10-2020
                System.debug('Opportunity List:::'+incomingRequestWrapper.opportunityList);
                
                List<Database.SaveResult> results = Database.Insert(incomingRequestWrapper.opportunityList,TRUE);
                List<String> successIds = new List<String>();
                List<OpportunityTeamMember> oppTeamMemberToInsert = new List<OpportunityTeamMember>();

                for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                        successIds.add(sr.getId());
                        OpportunityTeamMember newAccTm = new OpportunityTeamMember(OpportunityId = sr.getId() , UserId = incomingRequestWrapper.userID);
                        oppTeamMemberToInsert.add(newAccTm);
                    }
                }
            
                if(oppTeamMemberToInsert.size()>0)
                    Insert oppTeamMemberToInsert;

                thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Success' ,'ObjectType__c' => CREATE_OPPORTUNITY ,'User__c' =>incomingRequestWrapper.userID } ,TRUE ,thirdPartyLogger);
                return populateResultWrapper(incomingRequestWrapper.api_Type , NULL ,NULL,successIds);  
            }
        }
        else{
            thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure','Error_Message__c' => Label.OpportunityList_Mandatory_Error_Message ,'ObjectType__c' => CREATE_OPPORTUNITY ,'User__c' =>incomingRequestWrapper.userID } ,TRUE ,thirdPartyLogger);
            return populateResultWrapper(incomingRequestWrapper.api_Type , NULL ,Label.OpportunityList_Mandatory_Error_Message,NULL);   
        }

    }

    global static OutgoingResponseWrapper leadCreation(IncomingSPPRequestWrapper incomingRequestWrapper, Third_Party_Logger__c thirdPartyLogger) {

  
        if(NULL != incomingRequestWrapper.leadList && incomingRequestWrapper.leadList.size()>0){

            List<String> successIds = new List<String>();
            List<Lead> leadsToInsert = new List<Lead>();
            List<CampaignMember> cmpgnMbrsToInsert = new List<CampaignMember>();
            Map<Integer,List<String>> mapOfCampaignIds = new Map<Integer,List<String>>();
            Integer count = 0;
            //SRSF-2010 : Code Starts here
            Map<String, List<String>> dependentPLmap = PicklistFieldController.getDependentPicklistValues(new Lead(),'Primary_Commodity__c','Commodity_Codes__c');
           //SRSF-2010 : Code Ends here 
            for(leadWrapper ledwrap : incomingRequestWrapper.leadList ){
                if(ledwrap.lead!=NULL){
                    ledwrap.lead.OwnerId = incomingRequestWrapper.userID;
                    //SRSF-2010 : Code Starts here
                    if(!String.isBlank(ledwrap.lead.Primary_Commodity__c)  && ledwrap.lead.Primary_Commodity__c != NULL ){
                       String response = PicklistFieldController.validatePicklistValues(dependentPLmap,ledwrap.lead.Primary_Commodity__c, ledwrap.lead.Commodity_Codes__c) ;
                       if(!String.isBlank(response)) {
                            thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure','Error_Message__c' => response,'ObjectType__c' => CREATE_LEAD ,'User__c' =>incomingRequestWrapper.userID } ,TRUE ,thirdPartyLogger);
                            return populateResultWrapper(incomingRequestWrapper.api_Type,NULL,response,NULL);
                       }
                    }
                    if(String.isBlank(ledwrap.lead.Primary_Commodity__c) && !String.isBlank(ledwrap.lead.Commodity_Codes__c)){
                        thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure','Error_Message__c' => Label.Mandatory_Lead_Primary_Commodity,'ObjectType__c' => CREATE_LEAD ,'User__c' =>incomingRequestWrapper.userID} ,TRUE ,thirdPartyLogger);
                        return populateResultWrapper(incomingRequestWrapper.api_Type,NULL,Label.Mandatory_Lead_Primary_Commodity,NULL);
                    }
                    //SRSF-2010 : Code Ends here
                    leadsToInsert.add(ledwrap.lead);
                    if(ledwrap.campaignIds!=NULL && ledwrap.campaignIds.size() > 0 ){
                        mapOfCampaignIds.put(count,ledwrap.campaignIds);                        
                    }
                    count++;
                }

            }

            List<Database.SaveResult> results = Database.Insert(leadsToInsert,TRUE);

            for(Integer i=0; i < results.size(); i++){
                if(results[i].isSuccess()){
                    successIds.add(results[i].getId());
                    if(mapOfCampaignIds.containsKey(i)){
                        for(String cmpId : mapOfCampaignIds.get(i)){
                            CampaignMember cmpgnMbr = new CampaignMember(CampaignId = cmpId, LeadId = results[i].getId());
                            cmpgnMbrsToInsert.add(cmpgnMbr);
                        }   
                    }
                }
            }

            if(cmpgnMbrsToInsert.size()>0)
                results = Database.Insert(cmpgnMbrsToInsert,TRUE);

            thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Success' ,'ObjectType__c' => CREATE_LEAD ,'User__c' =>incomingRequestWrapper.userID } ,TRUE ,thirdPartyLogger);
            return populateResultWrapper(incomingRequestWrapper.api_Type , NULL ,NULL,successIds);
        }
        else{
            thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure','Error_Message__c' => Label.LeadList_Mandatory_Error_Message ,'ObjectType__c' => CREATE_LEAD ,'User__c' =>incomingRequestWrapper.userID } ,TRUE ,thirdPartyLogger);
            return populateResultWrapper(incomingRequestWrapper.api_Type , NULL ,Label.LeadList_Mandatory_Error_Message ,NULL); 
        }

    }

    global static String prepareAccountQuery(){
        String query = 'SELECT Id,Name';
        List<Fields__mdt> sppAccFields = [SELECT Field_Names__c,Limit__c from Fields__mdt where DeveloperName =:Label.SPP_AccountField_Setting_API_Name];
        
        if( sppAccFields.size()>0 && String.isNotBlank(sppAccFields[0].Field_Names__c)){
            query += ','+ sppAccFields[0].Field_Names__c;
        }
        query += ' FROM Account WHERE Id IN:accountIds';
        return query;
    }

    global class OutgoingResponseWrapper {
        global String api_Type;
        global boolean isSuccess;
        global String message;
        global List<SObject> accountList;//only for account search
        global List<String> results;
        global OutgoingResponseWrapper(String apiType, boolean success, String msg, List<SObject> accList, List<String> resultList) {
            api_Type = apiType;
            isSuccess = success;
            message = msg;
            accountList = accList;
            results = resultList;
        }
    }

    global class IncomingSPPRequestWrapper {
        global String userID; 
        global String api_Type; //Possible Values are "AccountSearch","CreateAccount","CreateOpportunity","CreateLead"
        global String source;
        //Account Search Fields
        global String acc_Name;
        global String acc_PhoneNo;
        global String acc_EclipseId;
        global AccountAdress acc_Address;
        
        //List to create Account
        global List<accountWrapper> accountlist;

        //List to create Opportunity
        global List<Opportunity> opportunityList;
        
        //List to create Lead
        global List<leadWrapper> leadList;

    }
    //address values used in Account Search
    global class AccountAdress {
        global String acc_Street;
        global String acc_City;
        global String acc_State;
        global String acc_Country;
        global String acc_ZipCode;
    }

    global class leadWrapper{
        global Lead lead;
        global List<String> campaignIds;
    }

    global class accountWrapper{
        global Account account;
        global Contact contact;
    }

}