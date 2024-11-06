/*
###########################################################################
# File..................: ThirdPartyConvertLead.cls
# Version...............: 1
# Created by............: Bhuvanasankar
# Created Date..........: 31-Dec-2018
# Last Modified by......: Abhilash
# Last Modified Date....: 09-Jan-2019
# Description...........: Jira Ticket : SRSF-1550
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/
@RestResource(urlMapping='/SpectrumReachConvertLead')
global with sharing class ThirdPartyConvertLead {
    
    @HttpGet
	global static String doGet() {
		return 'SpectrumReachConvertLead API is Alive!';
	}

	@HttpPost
	global static ResponseWrapper doPost(IncomingRequestWrapper incomingThirdPartyRequest) {

		Map<String,Object> mapOfThirdPartyLog = new Map<String, Object>{'JSON__c' => String.valueOf(incomingThirdPartyRequest),'API_Name__c' => 'SpectrumReachConvertLead' ,'Source__c' => Label.SPP_Search };

		Third_Party_Logger__c thirdPartyLogger = Log4SF.createThirdPartyLogger(mapOfThirdPartyLog,false , new Third_Party_Logger__c());

		return processIncomingRequest(incomingThirdPartyRequest, thirdPartyLogger);

	}

	global static ResponseWrapper processIncomingRequest(IncomingRequestWrapper incomingThirdPartyRequest,Third_Party_Logger__c thirdPartyLogger ) {

		if(incomingThirdPartyRequest!=NULL && String.isNotBlank(incomingThirdPartyRequest.leadId) && String.isNotBlank(incomingThirdPartyRequest.userID) &&  incomingThirdPartyRequest.leadId.startsWith('00Q') && incomingThirdPartyRequest.userID.startsWith('005') ) {
			try{
				List<Lead> leadList = [SELECT Id,OwnerId,Street,City,State,PostalCode,Country FROM Lead WHERE IsConverted!=true AND ID=:incomingThirdPartyRequest.leadId];
		
				if(leadList.size() > 0 && String.valueOf(leadList[0].OwnerId).ContainsIgnoreCase(incomingThirdPartyRequest.userID)) {
						// SRSF-1894: Added below if else condition 
						if(String.isBlank(leadList[0].Street) ||  String.isBlank(leadList[0].City) || String.isBlank(leadList[0].Country) ||  String.isBlank(leadList[0].PostalCode) || String.isBlank(leadList[0].State)){
							thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure','Error_Message__c' => Label.Update_Lead_before_Lead_Convertion ,'User__c' =>UserInfo.getUserId() } ,TRUE ,thirdPartyLogger);
							return new ResponseWrapper(false, Label.Update_Lead_before_Lead_Convertion, null, null,null);

						}
						else {
							Database.LeadConvert lc = new Database.LeadConvert();
							lc.setLeadId(ID.valueOf(incomingThirdPartyRequest.leadId));
							lc.setDoNotCreateOpportunity(true);
							LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true ORDER By Createddate DESC LIMIT 1];
							lc.setConvertedStatus(convertStatus.MasterLabel);

							Database.LeadConvertResult lcr = Database.convertLead(lc); 

							if(lcr.isSuccess()) {
								ResponseWrapper respWrap = new ResponseWrapper(true, Label.Lead_converted_success_message, String.valueOf(lcr.getAccountId()), String.valueOf(lcr.getContactId()) , NULL);
								DELETE [SELECT Id FROM CampaignMember WHERE LeadId =:incomingThirdPartyRequest.leadId ];
								if(incomingThirdPartyRequest.campaignIdList!=NULL && incomingThirdPartyRequest.campaignIdList.size() > 0){
									List<CampaignMember> campMbrsToInsert = new List<CampaignMember>();
									for(String cmpId : incomingThirdPartyRequest.campaignIdList ){
										CampaignMember cmpMbr = new CampaignMember();
										cmpMbr.CampaignId = cmpId;
										cmpMbr.ContactId = lcr.getContactId();
										campMbrsToInsert.add(cmpMbr);
									}
									if(campMbrsToInsert.size() > 0) Insert campMbrsToInsert;
									List<Campaign> campaignList = Database.query(ThirdPartyUpdateCampaigns.prepareCampaignQuery(incomingThirdPartyRequest.campaignIdList));
									respWrap = new ResponseWrapper(true, Label.Lead_converted_and_campaign_created, String.valueOf(lcr.getAccountId()), String.valueOf(lcr.getContactId()), campaignList);
								}
								// SRSF-1894: Code Start here
								AccountTeamMember atm = new AccountTeamMember( AccountId = lcr.getAccountId(),TeamMemberRole = 'Account Executive', UserId = leadList[0].OwnerId,OpportunityAccessLevel = Label.AccountTeamMeberAccessLevel,AccountAccessLevel=Label.AccountTeamMeberAccessLevel, CaseAccessLevel =Label.AccountTeamMeberAccessLevel);
                                insert atm;
                                // SRSF-1894: Code End here
								thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Success','User__c' =>UserInfo.getUserId() } ,TRUE ,thirdPartyLogger);
								return respWrap;
							}
							else {
								String errorMsg = '';
			                    for (Database.Error error: lcr.getErrors()){
			                        errorMsg += String.valueOf(error.getMessage());
			                    }
				                thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure','Error_Message__c' =>errorMsg ,'User__c' =>UserInfo.getUserId() } ,TRUE ,thirdPartyLogger);
								return new ResponseWrapper(false, errorMsg, null, null,NULL);	
							}
						}
				  }
				  else{
				  	  thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure','Error_Message__c' =>Label.Convert_Lead_Error_Message ,'User__c' =>UserInfo.getUserId() } ,TRUE ,thirdPartyLogger);
					   return new ResponseWrapper(false,Label.Convert_Lead_Error_Message, null, null,NULL);	
				  }
			}
			catch(Exception ex) {
				thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure','Error_Message__c' => ex.getMessage() ,'User__c' =>UserInfo.getUserId() } ,TRUE ,thirdPartyLogger);
				return new ResponseWrapper(false, ex.getMessage(), null, null,null);	
			}
		}
		else {
			thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure','Error_Message__c' =>Label.Valid_LeadId_Error_Message ,'User__c' =>UserInfo.getUserId() } ,TRUE ,thirdPartyLogger);
			return new ResponseWrapper(false, Label.Valid_LeadId_Error_Message, null, null,null);
		}
	}

	global class ResponseWrapper {
		global boolean isSuccess;
	    global String message;
	    global String accountID;
	    global String contactID;
	    global List<SObject> campaignList;

	    global ResponseWrapper(Boolean success, String msg, String accId, String conId,List<SObject> resultList) {
	    	isSuccess = success;
	    	message = msg;
	    	accountID = accId;
	    	contactID = conId;
	    	campaignList = resultList;
	    }
	}

	global class IncomingRequestWrapper {
		global String userID;
		global String leadId;
		global List<String> campaignIdList;

		global IncomingRequestWrapper(String usrId, String ldId, List<String> cmpgnIdList){
			userID = usrId;
			leadId = ldId;
			campaignIdList = cmpgnIdList;
		}

	}
}