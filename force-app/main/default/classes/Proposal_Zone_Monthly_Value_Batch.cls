/*
###########################################################################
# File..................: Proposal_Zone_Monthly_Value_Batch.cls
# Version...............: 1
# Created by............: Sanchit Singhal   
# Created Date..........: 29-March-2017
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This class is for scheduling the Job that runs daily for Proposal Zone Monthly Value Deactivation
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/

global with sharing class Proposal_Zone_Monthly_Value_Batch  implements Database.Batchable<sObject>{
	
	global List<Proposal_Zone_Monthly_Value__c>  listProposalZoneMonVal = new List<Proposal_Zone_Monthly_Value__c>();
	
    global String query;
        
    global Database.QueryLocator start(Database.BatchableContext context) {

        Date dt = Date.valueOf(DateTime.now().format('YYYY-MM-dd'));
        query = ' Select ID,Name,Broadcast_Month_Date__c,Broadcast_Month__c,isActive__c'+
                ' FROM Proposal_Zone_Monthly_Value__c '+
                ' WHERE Broadcast_Month_Date__c <: dt'+
                ' AND IsActive__c = true';
        if (test.isRunningTest()) {
            query += ' LIMIT 5';
        }
        System.debug('@@query '+query);
        return Database.getQueryLocator(query);
    }

	/*global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([Select ID,Name,Broadcast_Month_Date__c,Broadcast_Month__c,isActive__c from Proposal_Zone_Monthly_Value__c where Broadcast_Month_Date__c <: Date.valueOf(DateTime.now().format('YYYY-MM-dd')) AND IsActive__c = true]);
    }*/
    
    global void execute(Database.BatchableContext context, List<sObject> sObjects) {
        List<Proposal_Zone_Monthly_Value__c> listProposalVal = (List<Proposal_Zone_Monthly_Value__c>) sObjects;
        System.debug('@@@List '+listProposalVal);
        processProposalVal(listProposalVal);
    }
    
    global void finish(Database.BatchableContext context) {
        
    }
    
     /**
     * This method upserts the proposal zone monthly values deactivating them if they are past the current date.
     * 
     * @Parameter (List<Proposal_Zone_Monthly_Value__c>)
     * @return (void) (NA)
    */
    private void processProposalVal(List<Proposal_Zone_Monthly_Value__c> proposalList) {
    	listProposalZoneMonVal = new List<Proposal_Zone_Monthly_Value__c>();
    	if(proposalList.Size() > 0)
    	{
    		for(Proposal_Zone_Monthly_Value__c proposalVal : proposalList)
    		{
    			 if(proposalVal.Broadcast_Month_Date__c.month() == Date.today().toStartOfWeek().month())
    			 {
    			 	proposalVal.IsActive__c= false;
    			 	listProposalZoneMonVal.add(proposalVal);
    			 }
    			// Month Start
    		}
    		if(listProposalZoneMonVal.Size() > 0)
    		upsert listProposalZoneMonVal;
    	}	
    }
    
}