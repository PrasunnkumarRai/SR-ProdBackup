/*
###########################################################################
# File..................: ThirdPartyProposalDetails.cls
# Version...............: 1
# Created by............: Abhilash Vangari
# Created Date..........: 21-Nov-2018
# Last Modified by......: Abhilash Vangari
# Last Modified Date....: 21-Nov-2018
# Description...........: Jira Ticket : SRSF-1478
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/
@RestResource(urlMapping='/SpectrumReachProposalDetails')
global with sharing class ThirdPartyProposalDetails {

	@HttpGet
	global static String doGet() {
		return 'SpectrumReachProposalDetails API is Alive!';
	}

    @HttpPost
    global static ResponseCls doPost(List<String> propIds) {

    	Map<String,Object> mapOfThirdPartyLog = new Map<String, Object>{'JSON__c' => String.valueOf(propIds),'API_Name__c' => 'SpectrumReachProposalDetails', 'Source__c' => Label.SPP_Search };
    	Third_Party_Logger__c thirdPartyLogger = Log4SF.createThirdPartyLogger(mapOfThirdPartyLog,FALSE,new Third_Party_Logger__c());
    	try{
	    	List<Proposal__c> proposalDetails = Database.query(prepareProposalQuery(propIds));
	    	if(proposalDetails.size()>0){
	    		thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Success','User__c' =>UserInfo.getUserId() } ,TRUE ,thirdPartyLogger);
	    		return new ResponseCls(TRUE,NULL,proposalDetails);
	    	}
	    	else{
	    	   thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure','Error_Message__c' => Label.No_Record_Found_Message ,'User__c' =>UserInfo.getUserId() } ,TRUE ,thirdPartyLogger);
    		   return new ResponseCls(FALSE,Label.No_Record_Found_Message,NULL);	
	    	}
    	}
    	catch(Exception ex){
    	  	thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure','Error_Message__c' => ex.getMessage() ,'User__c' =>UserInfo.getUserId() } ,TRUE ,thirdPartyLogger);
    		return new ResponseCls(FALSE,'Error::'+ex.getMessage(),NULL);
    	}
    }

	global static String prepareProposalQuery(List<String> propIds){
		String query = 'SELECT ';
		List<Fields__mdt> sppPropFields = [SELECT Field_Names__c,Limit__c from Fields__mdt where DeveloperName =:Label.SPP_Proposal_Field_Setting_API_Name];
		Set<String> excludeFields = new Set<String>{'closed_gross_amount__c','closed_net_amount__c','gross_amount__c','net_amount__c','pending_gross_amount__c','pending_net_amount__c'}; // Sridhar: 09-07-2019
		if( sppPropFields.size()>0 && String.isNotBlank(sppPropFields[0].Field_Names__c)){
			query += ' Id,Name,'+ sppPropFields[0].Field_Names__c;
		}
		else{
			Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Proposal__c.fields.getMap();
	    	
	    	for (String fieldName: schemaFieldMap.keySet()) {
	    		if(!excludeFields.contains(fieldName)){	  // Sridhar: 09-07-2019  	
	    			query += fieldName + ',';
	    		} // Sridhar: 09-07-2019	
	    	}
	    	query = query.removeEnd(',');
		}
		query += ' FROM Proposal__c WHERE Id IN ' + '(\'' + String.join(propIds,'\',\'') + '\') ORDER BY CreatedDate DESC LIMIT ';
		query+= (sppPropFields.size()>0 && sppPropFields[0].Limit__c!=NULL)? Integer.valueOf(sppPropFields[0].Limit__c) : 10 ;
		return query;
	}

    global class ResponseCls {
		global boolean isSuccess;
	    global String message;
	    global List<SObject> proposalList;
	    global ResponseCls(boolean success, String msg, List<SObject> resultList) {
	    	isSuccess = success;
	    	message = msg;
	    	proposalList = resultList;
	    }
	}

}