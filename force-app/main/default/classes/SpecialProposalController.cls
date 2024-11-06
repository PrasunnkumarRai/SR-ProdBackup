/*
###########################################################################
# File..................: SpecialProposalController.cls
# Version...............: 1
# Created by............:  
# Created Date..........: 
# Last Modified by......: Bhuvanasankar Chinta 
# Last Modified Date....: 27-June-2018
# Description...........: 
# TAO Ref#..............: NA
# Change Log:               
# Change Political_Opportunity__c to PoliticalOpportunity__c (formula field).
#
############################################################################*/
public with sharing class SpecialProposalController {

    @AuraEnabled
    public static Map<String,RecordType> fetchRecordType (String oppId)
    {
    	System.debug('oppId'+oppId);
    	Map<String,RecordType> recordTypeMap = new Map<String,RecordType>();
    	if(oppId != null)
        {
        	Opportunity opp = [SELECT Id, Name, RecordType.Name , Account.Political_Account__c , PoliticalOpportunity__c FROM Opportunity WHERE Id =:oppId];
        	/*String query= 'Select id, DeveloperName, Description from RecordType where SobjectType =\'Proposal__c\' AND IsActive = true AND DeveloperName != \'Opportunity_Budget\'';*/            

            // SRSF-4859 / SRSF-5076 / SRSF-4907: Query Updated
            String query= 'SELECT Id, DeveloperName, Description FROM RecordType WHERE SobjectType =\'Proposal__c\' AND IsActive = true AND DeveloperName IN (\'Inventory\',\'Trade\')';

        	//if(null != opp.Political_Opportunity__c && null != opp.Account.Political_Account__c && opp.Political_Opportunity__c && opp.Account.Political_Account__c) // Commented by bhuvan on 27-june-2018
            if(null != opp.PoliticalOpportunity__c && opp.PoliticalOpportunity__c)
            {
        	   query += ' AND (DeveloperName = \''+Label.Political_RT+'\' OR DeveloperName = \''+Label.Inventory_RT+'\')';	
        	}
        	else{
        	   query += ' AND DeveloperName != \''+Label.Political_RT+'\'';
        	}
        	System.debug('query'+query);
        	List<RecordType> recordTypeList = Database.query(query);
        	for(RecordType rt : recordTypeList){
        		recordTypeMap.put(rt.Id,rt);
        	}
        	System.debug('recordTypeList'+recordTypeList);
        	return recordTypeMap;
        }
        else{
        	return recordTypeMap;
        }
    }
}