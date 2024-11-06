/*
###########################################################################
# File..................: ThirdPartyUpdateCampaigns.cls
# Version...............: 1
# Created by............: Abhilash Vangari
# Created Date..........: 28-Dec-2018
# Last Modified by......: Abhilash Vangari
# Last Modified Date....: 28-Dec-2018
# Description...........: Jira Ticket : SRSF-1549
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/
@RestResource(urlMapping='/SpectrumReachUpdateCampaigns')
global with sharing class ThirdPartyUpdateCampaigns {
    
	@HttpGet
	global static String doGet() {
		return 'SpectrumReachUpdateCampaigns API is Alive!';
	}

    @HttpPost
    global static ResponseCls doPost(IncomingSPPRequestWrapper incomingThirdPartyRequestWrapper) {
       	
    	Map<String,Object> mapOfThirdPartyLog = new Map<String, Object>{'JSON__c' => String.valueOf(incomingThirdPartyRequestWrapper),'API_Name__c' => 'SpectrumReachUpdateCampaigns', 'Source__c' => Label.SPP_Search };
    	Third_Party_Logger__c thirdPartyLogger = Log4SF.createThirdPartyLogger(mapOfThirdPartyLog,FALSE,new Third_Party_Logger__c());

        try{
          if( String.isNotBlank(incomingThirdPartyRequestWrapper.leadIdOrContId) && incomingThirdPartyRequestWrapper.campaignIds!=NULL && !incomingThirdPartyRequestWrapper.campaignIds.isEmpty() ){	
			Boolean isLeadId = incomingThirdPartyRequestWrapper.leadIdOrContId.startsWith('00Q')? TRUE : FALSE;
			String campMbrQuery = 'SELECT Id,LeadId,ContactId,CampaignId FROM CampaignMember WHERE ';
	       	if(isLeadId)
	       		campMbrQuery += ' leadId = \''+incomingThirdPartyRequestWrapper.leadIdOrContId +'\'';
	       	else
				campMbrQuery += ' ContactId = \'' +incomingThirdPartyRequestWrapper.leadIdOrContId +'\'';

			//campMbrQuery += ' AND CampaignId NOT IN' + '(\'' + String.join(incomingThirdPartyRequestWrapper.campaignIds,'\',\'') + '\') ';

          	List<CampaignMember> campaignMemberList = new List<CampaignMember>();
          	List<CampaignMember> campaignMemberToDelete = new List<CampaignMember>();
  			
  			Map<Id,CampaignMember> campMbrmap = new Map<Id,CampaignMember>();

          	for(CampaignMember cmpMember : Database.query(campMbrQuery)){
          		campMbrmap.put(cmpMember.CampaignId,cmpMember);
	     	}

			for(String str : incomingThirdPartyRequestWrapper.campaignIds){
				if(!campMbrmap.containsKey(str)){
					CampaignMember cmpMbr = new CampaignMember();
					cmpMbr.CampaignId = str;
					if(isLeadId)
					 cmpMbr.LeadId = incomingThirdPartyRequestWrapper.leadIdOrContId;
					else
					 cmpMbr.ContactId = incomingThirdPartyRequestWrapper.leadIdOrContId;
					campaignMemberList.add(cmpMbr);  
				}
				else{
					campMbrmap.remove(str);
				}
          	}

          	if(campMbrmap.size()>0) campaignMemberToDelete.addAll(campMbrmap.values());

          	if(campaignMemberList.size()>0)
          		INSERT campaignMemberList;
          	if(campaignMemberToDelete.size()>0)
          		DELETE campaignMemberToDelete;
          	
        	List<Campaign> campaignList = Database.query(prepareCampaignQuery(incomingThirdPartyRequestWrapper.campaignIds));

		    thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Success','User__c' =>UserInfo.getUserId() } ,TRUE ,thirdPartyLogger);
		    	return new ResponseCls(TRUE,Label.Lead_Update_Success_Message,campaignList);

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

	global static String prepareCampaignQuery(List<String> campaignIds){
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
		query += ' FROM Campaign WHERE Id IN ' + '(\'' + String.join(campaignIds,'\',\'') + '\') ';

		return query;
	}


    global class IncomingSPPRequestWrapper {
    	global List<String> campaignIds;
		global String leadIdOrContId;
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