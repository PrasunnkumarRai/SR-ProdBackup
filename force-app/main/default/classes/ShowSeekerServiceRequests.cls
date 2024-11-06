/*
###########################################################################
# File..................: ShowSeekerServiceRequests.cls
# Version...............: 1
# Created by............: Sridhar Aluru
# Created Date..........: 03-June-2020
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: Jira Ticket : SRSF-2175, SRSF-2176
# TAO Ref#..............: NA
# Test Class............: ShowSeekerServiceRequestsTest
# Change Log............:               
# Date            User          Requested By (Optional)      Description
# 03-June-2020  Sridhar Aluru         Greg Rice         
#
############################################################################*/
@RestResource(urlMapping='/ShowSeekerService/*')
global with sharing class ShowSeekerServiceRequests {

    @HttpGet
    global static String doGet() {
        return 'ShowSeekerService API is Alive!';
    }
    
    // Pass AE ID in place of User ID    
    @HttpPost
    global static ObjectResultWrapper doPost(IncomingRequestWrapper incomingRequest) {      

        Map<String,Object> mapOfThirdPartyLog = new Map<String, Object>{'JSON__c' => String.valueOf(incomingRequest), 'User__c' =>incomingRequest.userId, 'Account_Id_List__c' => String.valueOf(incomingRequest.accountIdList) ,'API_Name__c' => 'ShowSeekerService','Source__c' => String.valueOf(incomingRequest.source)}; 

        Third_Party_Logger__c thirdPartyLogger = Log4SF.createThirdPartyLogger(mapOfThirdPartyLog, TRUE, new Third_Party_Logger__c());
        return processIncomingRequest(incomingRequest.aeId, incomingRequest.objectType, incomingRequest.accountIdList , thirdPartyLogger);
    }
    

    global static ObjectResultWrapper processIncomingRequest(String aeId, String objectType, List<String> accountIdList ,Third_Party_Logger__c thirdPartyLogger ) 
    {
        List<SObject> genericList = new List<SObject>();
        String errMesg = '';
        String status = 'Success';
        ObjectResultWrapper response;

        try {
            if (String.isNotBlank(objectType)) 
            {
                List<ShowSeeker_Service__mdt> fieldMap = [SELECT Label,DeveloperName,Field_Names__c,Filter_Conditions__c,Limit__c FROM ShowSeeker_Service__mdt WHERE DeveloperName =: objectType];

                //Get the User data
                List<User> activeUserList = [SELECT Id, Name FROM User WHERE Id =:aeId AND isActive = TRUE LIMIT 1];

                if (activeUserList.isEmpty()) 
                {                    
                    errMesg = String.format(System.Label.UserID_Not_esist, new List<String> {aeId});
                    response = populateResultWrapper (NULL, errMesg);                    
                }
                //Get the Opportunity Team for the User.
                else if(fieldMap.size() > 0)
                {
                    String finalQuery;
                    System.debug('objectType-1>>>>'+objectType);
                    if('Account'.equalsIgnoreCase(objectType)) {
                        finalQuery = getQuery(aeId, objectType, fieldMap, accountIdList);
                    } 
                    else if ('Opportunity'.equalsIgnoreCase(objectType)) {
                        if(NULL == accountIdList || (NULL != accountIdList && accountIdList.isEmpty())) {
                            errMesg = String.format(System.Label.Account_Id_Mandatory_Error_Message, new List<String> {objectType});
                        } else {
                            finalQuery = getQuery(aeId, objectType, fieldMap, accountIdList);
                        }
                    }

                    if (String.isNotBlank(finalQuery)) genericList = Database.Query(finalQuery);

                    if (genericList.isEmpty() || String.isBlank(finalQuery)) {
                      errMesg = String.format(System.Label.No_record_message, new List<String>{objectType,aeId});
                        System.debug('errMesg : ' + errMesg);
                    }
                }
                else {
                   errMesg = String.format(System.Label.Data_Cannot_Retrieve_Error, new List<String>{objectType});
                }
            }
        }
        catch(Exception ex) {
            errMesg = 'Exception in ShowSeeker Service Request :'+ ex.getMessage()+' Line : '+ ex.getLineNumber();
        }
     
        if(CommonUtilities.isStringNullOrEmpty(errMesg)){
            response = populateResultWrapper (genericList, NULL);
        } else {
            status = 'Failure';
            response = populateResultWrapper (NULL, errMesg);
        }
        //thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => status ,'ObjectType__c' =>objectType, 'Error_Message__c' =>errMesg} ,TRUE ,thirdPartyLogger);
        
        return response;
    }


    global static ObjectResultWrapper populateResultWrapper(List<SObject> recordList, String errorMsg) 
    {
        ObjectResultWrapper resultWrapper;
        if ((NULL == recordList || (NULL != recordList && recordList.isEmpty())) && String.isNotBlank(errorMsg)) {
            resultWrapper = new ObjectResultWrapper(false, errorMsg, NULL);
        }
        else {
            resultWrapper = new ObjectResultWrapper(true, NULL, recordList);
        }
        return resultWrapper;
    }


    global static String getQuery(String idOfUser, String objectName, List<ShowSeeker_Service__mdt> objectDetails, List<String> accIdList) 
    {
        System.debug('objectName>>>>>>'+objectName);
        String query = 'SELECT ID,Name ';
        
        if(!String.isBlank(objectDetails[0].Field_Names__c) && !String.isEmpty(objectDetails[0].Field_Names__c))
            query+=  ', '+ objectDetails[0].Field_Names__c ;        
            query+=  ' FROM ' + objectName ;
        
        if(!String.isBlank(objectDetails[0].Filter_Conditions__c) && !String.isEmpty(objectDetails[0].Filter_Conditions__c))
            query+=  ' WHERE ' + objectDetails[0].Filter_Conditions__c;
        
        //Get the Account Team for the User.
        if('Account'.equalsIgnoreCase(objectName)) {
            String accIdString = '(';
            List<AccountTeamMember> accTeamMemList = [SELECT AccountId FROM AccountTeamMember WHERE CreatedDate = LAST_N_DAYS:14 AND UserId =: idOfUser];
            if (accTeamMemList.isEmpty()) {
                return '';
            }
            for (AccountTeamMember accTeamMem : accTeamMemList) {
                accIdString += '\'' + accTeamMem.AccountId + '\',';
            }
            accIdString = accIdString.removeEnd(',') + ')';

            query += (query.containsIgnoreCase('WHERE'))? ' AND ' : ' WHERE ';
            query += ' ID IN ' + accIdString; 
        }

        if('Opportunity'.equalsIgnoreCase(objectName) && NULL != accIdList && !accIdList.isEmpty()) {

            Set<String> accountIdSet = new Set<String>();
            accountIdSet.addAll(accIdList);
            String accIdString = '(';
            for (Id accId : accountIdSet) {
                accIdString += '\'' + accId + '\',';
            }
            accIdString = accIdString.removeEnd(',') + ')';

            query += (query.containsIgnoreCase('WHERE'))? ' AND ' : ' WHERE ';
            query += ' AccountID IN ' + accIdString;
            query += ' AND (OwnerID = \'' + idOfUser + '\'';

            List<OpportunityTeamMember > oppTeamMemList = [SELECT OpportunityId FROM OpportunityTeamMember WHERE UserId =: idOfUser];
            if (oppTeamMemList.size()>0) {
                String oppIdString = ' OR ID IN(';
                for (OpportunityTeamMember oppTeamMem : oppTeamMemList) {
                    oppIdString += '\'' + oppTeamMem.OpportunityId + '\',';
                }
                oppIdString = oppIdString.removeEnd(',') + ')';
                query += oppIdString;
            }
            query += ')'; 
        }
        query += ' ORDER BY CreatedDate DESC';   // LIMIT ' + Integer.valueOf(objectDetails[].Limit__c);
        System.debug('query : ' + query);
        return query;
    }
    

    global class IncomingRequestWrapper {
        global String userId;
        global String aeId;
        global String objectType;
        global List<String> accountIdList;
        global String source;       
    }


    global class ObjectResultWrapper 
    {
        global boolean isSuccess;
        global String message;
        global List<SObject> results;
        global ObjectResultWrapper(boolean success, String msg, List<SObject> resultList) {
            isSuccess = success;
            message = msg;
            results = resultList;
        }
    }
}