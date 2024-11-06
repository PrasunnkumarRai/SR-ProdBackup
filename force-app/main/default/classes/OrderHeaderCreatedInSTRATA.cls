/*
###########################################################################
# File..................: OrderHeaderCreatedInSTRATA.cls
# Version...............: 1
# Created by............: Sanchit Singhal   
# Created Date..........: 10-May-2017
# Description...........: This class contains SOAP API for TIM Linear Proposal creation callback
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/
global with sharing class OrderHeaderCreatedInSTRATA {
    
  global class OrderHeaderInfo {
    WebService Integer EstimateId;
    WebService String ProposalId;
  }
  
  global class returnStatus {
    WebService Boolean success;
    WebService String exceptionMsg;
  }
  
  /**
     * This method captures OrderHeaderInfo from TIM SOAP callback
     * 
     * @param  (OrderHeaderInfo) (info)
     * @return (returnStatus) (status of proposal creation process in Salesforce)
  */ 
  WebService static returnStatus updateProposal(OrderHeaderInfo info) {
    System.debug('/*Entered Web service method updateProposal*/');  
    returnStatus returnMsg = new returnStatus();
    Log4SF.logMessage('OrderHeaderCreatedInSTRATA', 'updateProposal', 'New TIM Callback: ' + info, UserInfo.getUserId(),'NA');
    if (info.EstimateId != null && info.ProposalId != null) {
      try {
        System.debug('/*entered in web service 2*/');
        createProposal(info.ProposalId, info.EstimateId); 
        
      } catch (Exception e) {
      	Log4SF.logMessage('OrderHeaderCreatedInSTRATA', 'updateProposal', 'Exception in TIM Callback Service.' +  info,e, UserInfo.getUserId(),info.ProposalId);
        System.debug('/*exception in web service*/' + e);
        returnMsg.success = false;
        returnMsg.exceptionMsg = String.valueOf(e);
        return returnMsg;
      }
    
      returnMsg.success = true;
      return returnMsg;
    } else {
      Log4SF.logMessage('OrderHeaderCreatedInSTRATA', 'updateProposal', 'EstimateId or ProposalId is null' + info, UserInfo.getUserId(),'NA');
      returnMsg.success = false;
      returnMsg.exceptionMsg = 'EstimateId and ProposalId must be specified';
      return returnMsg;
    }
  }
  
  /**
     * This method captures creates a new proposal in Salesforce based on estimateId and Opportunity Id
     * 
     * @param  (String) (oppId)
     * @param  (Integer) (estimateId)
     * @return (void) (NA)
  */ 
  public static void createProposal(String oppId, Integer estimateId){
       //Code changes to include inventory recordType : Aditi : 2/26/2018
                 
        String query = 'Select ID from RecordType where SobjectType =\'Proposal__c\'';
        if(oppId.contains('_INV')){
          query += ' AND Name = \''+Label.Inventory_RT+'\'';
          String[] str = oppId.split('_');
          oppId = str[0];
        }
        else if(oppId.contains('_PR')){
          query += ' AND Name = \''+Label.Political_RT+'\'';
          String[] str = oppId.split('_');
          oppId = str[0];
        }
        else if(oppId.contains('_TR')){
          query += ' AND Name = \''+Label.Trade_RT+'\'';
          String[] str = oppId.split('_');
          oppId = str[0];
        }
        else if(oppId.contains('_LR')){
          query += ' AND Name = \''+Label.Linear_RT+'\'';
          String[] str = oppId.split('_');
          oppId = str[0];
        }
        else{
          query += ' AND Name = \'Linear\'';

        }
        
        query += ' limit 1';

         RecordType recordType = Database.query(query);

        
                
       /* RecordType linearRT = [select ID from RecordType 
                               where name = 'Linear' 
                                     and SobjectType='Proposal__c' 
                               limit 1];*/
         //Code changes ends                      
        
        /*Creating new proposal*/
        Proposal__c newProposal = new Proposal__c();
        newProposal.TIM_Id__c = String.valueOf(estimateId);

        newProposal.Opportunity__c = oppId;
        //Code changes by Aditi : 2/26/2018
        newProposal.RecordTypeId = recordType.id;
        //newProposal.RecordTypeId = linearRT.ID;
        //Code changes ends
        
        newProposal.Origin__c = 'TIM Callback';
        
        // SRSF-1283
        // Opportunity opp = [select id,Agency__c,Rep_Firm__c,AccountId,name,ownerId from Opportunity where Id= :oppId];
      	Opportunity opp = [select id,Agency_Account__c,Rep_Firm__c,AccountId,name,ownerId from Opportunity where Id= :oppId];

        
        try{
        	Userconnection__c oppOwner = [Select TIM_system__c from Userconnection__c where user__c =: opp.OwnerId and is_Primary__c = true limit 1];
        	newProposal.TIM_system__c = oppOwner.TIM_system__c;
        	newProposal.ProposalExternalId__c = String.valueOf(estimateId)+ ' ' +oppOwner.TIM_system__c;
        }
        catch(Exception ex){
        	System.debug('Exception in Opportunity Owner Primary User Connection: ' + ex);
        	Log4SF.logMessage('OrderHeaderCreatedInSTRATA', 'createProposal', 'Exception in Opportunity Owner Primary User Connection.' ,ex, UserInfo.getUserId(), opp.Id);
        }
      	// SRSF-1283
      	// newProposal.Agency__c = opp.Agency__c;        
        newProposal.Agency__c = opp.Agency_Account__c;
        newProposal.Advertiser__c = opp.AccountId;
        String propName = opp.Name + '-Proposal ' + DateTime.now();
        if(propName.length() >=79){
          propName = propName.substring(0, 79);
        }
        newProposal.Name = propName;
        insert newProposal;
  }
  
  /*Provision for TIM callback simulation
  @future
  public static void createProposalAsync(String oppId, Integer estimateId){
        
        RecordType linearRT = [select ID from RecordType 
                               where name = 'Linear' 
                                     and SobjectType='Proposal__c' 
                               limit 1];
        
        //Creating new proposal
        Proposal__c newProposal = new Proposal__c();
        newProposal.TIM_Id__c = String.valueOf(estimateId);
        newProposal.Opportunity__c = oppId;
        newProposal.RecordTypeId = linearRT.ID;

        // SRSF-1283
        // Opportunity opp = [select id,Agency__c,Rep_Firm__c,AccountId from Opportunity where Id= :oppId];
      	Opportunity opp = [select id,Agency_Account__c,Rep_Firm__c,AccountId from Opportunity where Id= :oppId];
      	// newProposal.Agency__c = opp.Agency__c;        
        newProposal.Agency__c = opp.Agency_Account__c;
        newProposal.Agency__c = opp.Agency__c;
        newProposal.Advertiser__c = opp.AccountId;
        
        insert newProposal;
    }*/
}