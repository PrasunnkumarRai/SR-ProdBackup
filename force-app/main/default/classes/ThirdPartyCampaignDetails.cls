/*
###########################################################################
# File..................: ThirdPartyCampaignDetails.cls
# Version...............: 1
# Created by............: Abhilash Vangari
# Created Date..........: 24-Dec-2018
# Last Modified by......: Abhilash Vangari
# Last Modified Date....: 24-Dec-2018
# Description...........: Jira Ticket : SRSF-1544
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/
@RestResource(urlMapping='/SpectrumReachCampaignDetails')
global with sharing class ThirdPartyCampaignDetails {

	@HttpGet
	global static String doGet() {
		return 'SpectrumReachCampaignDetails API is Alive!';
	}

    @HttpPost
    global static ResponseCls doPost(String leadIdOrContId) {
       	
    	Map<String,Object> mapOfThirdPartyLog = new Map<String, Object>{'JSON__c' => String.valueOf(leadIdOrContId),'API_Name__c' => 'SpectrumReachCampaignDetails', 'Source__c' => Label.SPP_Search };
    	Third_Party_Logger__c thirdPartyLogger = Log4SF.createThirdPartyLogger(mapOfThirdPartyLog,FALSE,new Third_Party_Logger__c());

        try{
          if(String.isNotBlank(leadIdOrContId)){
            Boolean isLeadId = leadIdOrContId.startsWith('00Q')? TRUE : FALSE;
        	List<Campaign> campaignList = Database.query(prepareCampaignQuery(leadIdOrContId , isLeadId));
        	System.debug('Campaign ID:: '+campaignList);
	    	if(campaignList.size()>0){
	    		thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Success','User__c' =>UserInfo.getUserId() } ,TRUE ,thirdPartyLogger);
	    		return new ResponseCls(TRUE,NULL,campaignList);
	    	}
	    	else{
	    	   thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure','Error_Message__c' => Label.No_Campaign_Record_Found_Message ,'User__c' =>UserInfo.getUserId() } ,TRUE ,thirdPartyLogger);
    		   return new ResponseCls(FALSE,Label.No_Campaign_Record_Found_Message,NULL);	
	    	}
	      }
	      else{
	      	  thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure','Error_Message__c' => Label.No_LeadId_and_ContactId_Error_Message,'User__c' =>UserInfo.getUserId() } ,TRUE ,thirdPartyLogger);
    		   return new ResponseCls(FALSE,Label.No_LeadId_and_ContactId_Error_Message,NULL);	

	      }
    	}
    	catch(Exception ex){
    	  	thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure','Error_Message__c' => ex.getMessage() ,'User__c' =>UserInfo.getUserId() } ,TRUE ,thirdPartyLogger);
    		return new ResponseCls(FALSE,'Error::'+ex.getMessage(),NULL);
    	}
    }

	global static String prepareCampaignQuery(String leadIdOrContId, Boolean isLeadId){
		String query = 'SELECT ';
		List<Fields__mdt> sppPropFields = [SELECT Field_Names__c,Limit__c from Fields__mdt where DeveloperName =:Label.SPP_Campaign_Field_Setting_API_Name];
		
		if( sppPropFields.size()>0 && String.isNotBlank(sppPropFields[0].Field_Names__c)){
			query += ' Id,Name,'+ sppPropFields[0].Field_Names__c;
		}
		else{
			Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Campaign.fields.getMap();
	    	for (String fieldName: schemaFieldMap.keySet()) {
	    			query += fieldName + ',';
	    	}
	    	query = query.removeEnd(',');
		}
		query += ' FROM Campaign WHERE Id IN (Select CampaigniD from CampaignMember WHERE ';
       	if(isLeadId)
       		query += ' leadId = \''+leadIdOrContId +'\'';
       	else
			query += ' ContactId = \'' +leadIdOrContId +'\'';
		query += ' )';
		//query += ' FROM Campaign WHERE Id IN ' + '(\'' + String.join(campaignIds,'\',\'') + '\') ';
		//query+= (sppPropFields.size()>0 && sppPropFields[0].Limit__c!=NULL)? Integer.valueOf(sppPropFields[0].Limit__c) : 10 ;
		return query;
	}

    global class ResponseCls {
		global boolean isSuccess;
	    global String message;
	    global List<SObject> campaignList;
	    global ResponseCls(boolean success, String msg, List<SObject> resultList) {
	    	isSuccess = success;
	    	message = msg;
	    	campaignList = resultList;
	    }
	}

}