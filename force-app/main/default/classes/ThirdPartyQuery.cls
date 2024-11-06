@RestResource(urlMapping='/SpectrumReachQuery/*')
global with sharing class ThirdPartyQuery{
	
	@HttpGet
	global static String doGet() {
		return 'SpectrumReachQuery API is Alive!';
	}
	
	@HttpPost
	global static ObjectResultWrapper doPost(IncomingRequestWrapper incomingThirdPartyRequest) {

		Map<String,Object> mapOfThirdPartyLog = new Map<String, Object>{'JSON__c' => String.valueOf(incomingThirdPartyRequest), 'User__c' =>incomingThirdPartyRequest.userID, 'Account_Id_List__c' => String.valueOf(incomingThirdPartyRequest.accountIdList) ,'API_Name__c' => 'SpectrumReachQuery' ,'Source__c' => 'Audience App'};

		Third_Party_Logger__c thirdPartyLogger = Log4SF.createThirdPartyLogger(mapOfThirdPartyLog,false , new Third_Party_Logger__c());

		return processIncomingRequest(incomingThirdPartyRequest.userID, incomingThirdPartyRequest.objectType, incomingThirdPartyRequest.accountIdList , thirdPartyLogger);
	}

	global class IncomingRequestWrapper {
		global String userID;
	    global String objectType;
	    global List<String> accountIdList;
	    global String source;
	}

	global static ObjectResultWrapper processIncomingRequest(String userID, String objectType, List<String> accountIdList ,Third_Party_Logger__c thirdPartyLogger ) {

		List<sObject> genericList = new List<sObject>();
		try {
			if (String.isNotBlank(objectType)) {
				List<Fields__mdt> fieldMap = [SELECT Label,DeveloperName,Field_Names__c,Filter_Conditions__c,Limit__c from Fields__mdt where DeveloperName =: objectType];
				//Get the User data
				List<User> activeUserList = [SELECT Id, Name FROM User WHERE Id =:userID and isActive = true limit 1];
				if (activeUserList.isEmpty()) {
					
					String errMesg = String.format(System.Label.UserID_Not_esist, new List<String> {userID});
				 	thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure' ,'ObjectType__c' =>objectType, 'Error_Message__c' =>errMesg} ,TRUE ,thirdPartyLogger);
					return populateResultWrapper(NULL, errMesg);
				}
				//Get the Opportunity Team for the User.
				else if(fieldMap.size() > 0)
				{
					if('Opportunity'.equalsIgnoreCase(objectType) && (NULL == accountIdList || (NULL != accountIdList && accountIdList.isEmpty()))) {
						String errMesg = String.format(System.Label.Account_Id_Mandatory_Error_Message, new List<String> {objectType});
				 		thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure' ,'ObjectType__c' =>objectType, 'Error_Message__c' =>errMesg} ,TRUE, thirdPartyLogger);
						return populateResultWrapper(NULL, errMesg);
					}
					String finalQuery = getQuery(userID, objectType, fieldMap, accountIdList);
					if (String.isNotBlank(finalQuery)) genericList = Database.Query(finalQuery);
					if (genericList.isEmpty() || String.isBlank(finalQuery)) {
						String errMesg = String.format(System.Label.No_record_message, new List<String> {objectType,userID});
				 		thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure' ,'ObjectType__c' =>objectType, 'Error_Message__c' =>errMesg} ,TRUE ,thirdPartyLogger);
						System.debug('errMesg : ' + errMesg);
						return populateResultWrapper(NULL, errMesg);
					}
				}
				else {
					thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure' ,'ObjectType__c' =>objectType, 'Error_Message__c' =>String.format(System.Label.Data_Cannot_Retrieve_Error, new List<String> {objectType})} ,TRUE ,thirdPartyLogger );
					return populateResultWrapper(NULL, String.format(System.Label.Data_Cannot_Retrieve_Error, new List<String> {objectType}) );

				}
			}
		}
		catch(Exception ex) {
			//Log4SF.logMessage('ThirdPartyQuery', 'doPost', 'Exception in ThirdParty Data Query',ex,userID,'NA');
			thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure' ,'ObjectType__c' =>objectType, 'Error_Message__c' =>'Exception in ThirdParty Data Query'+ ex.getMessage()+' Line : '+ ex.getLineNumber()} ,TRUE ,thirdPartyLogger);
			return populateResultWrapper(NULL, 'Exception in ThirdParty Data Query : ' + ex.getMessage());
		}
		thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Success' ,'ObjectType__c' =>objectType} ,TRUE , thirdPartyLogger);
		return populateResultWrapper(genericList, NULL);
	}

	global static ObjectResultWrapper populateResultWrapper(List<SObject> recordList, String errorMsg) {
		ObjectResultWrapper resultWrapper;
		if ((NULL == recordList || (NULL != recordList && recordList.isEmpty())) && String.isNotBlank(errorMsg)) {
			resultWrapper = new ObjectResultWrapper(false, errorMsg, NULL);
		}
		else {
			resultWrapper = new ObjectResultWrapper(true, NULL, recordList);
		}
		return resultWrapper;
	}

	global static String getQuery(String idOfUser, String objectName, List<Fields__mdt> objectDetails, List<String> accIdList) {

		String query = 'SELECT Id,Name ';
		
		if(!String.isBlank(objectDetails[0].Field_Names__c) && !String.isEmpty(objectDetails[0].Field_Names__c))
			query+=  ', '+ objectDetails[0].Field_Names__c ;
		
		query+=  ' FROM ' + objectName ;
		
		if(!String.isBlank(objectDetails[0].Filter_Conditions__c) && !String.isEmpty(objectDetails[0].Filter_Conditions__c))
			query+=  ' WHERE ' + objectDetails[0].Filter_Conditions__c;
		
		//Get the Account Team for the User.
		if('Account'.equalsIgnoreCase(objectName)) {
			String accIdString = '(';
			List<AccountTeamMember> accTeamMemList = [Select AccountId from AccountTeamMember where UserId =: idOfUser];
			if (accTeamMemList.isEmpty()) {
                return '';
            }
			for (AccountTeamMember accTeamMem : accTeamMemList) {
				accIdString += '\'' + accTeamMem.AccountId + '\',';
			}
			accIdString = accIdString.removeEnd(',') + ')';

			query += (query.containsIgnoreCase('WHERE'))? ' AND ' : ' WHERE ';
			query += ' id IN ' + accIdString;

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
			query += ' AccountId IN ' + accIdString;

			query += ' AND (OwnerId = \'' + idOfUser + '\'';

			List<OpportunityTeamMember > oppTeamMemList = [Select OpportunityId  from OpportunityTeamMember where UserId =: idOfUser];
			if (oppTeamMemList.size()>0) {
				String oppIdString = ' OR Id IN(';
				for (OpportunityTeamMember oppTeamMem : oppTeamMemList) {
					oppIdString += '\'' + oppTeamMem.OpportunityId + '\',';
				}
				oppIdString = oppIdString.removeEnd(',') + ')';
				query += oppIdString;
			}

			query += ')'; 

		}
		query += ' ORDER BY CreatedDate DESC LIMIT ' + Integer.valueOf(objectDetails[0].Limit__c);
		System.debug('query : ' + query);
		return query;
	}

	global class ObjectResultWrapper {
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