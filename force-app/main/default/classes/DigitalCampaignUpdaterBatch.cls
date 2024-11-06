global class DigitalCampaignUpdaterBatch implements Database.Batchable<sObject>{
	
	global final String Query;
    
    // In use with DigitalCampaignUpdaterBatchScheduler class.
    global DigitalCampaignUpdaterBatch(String q){
        Query = q;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Digital_Campaign__c> scope){
        Org_Exceptions__c orgExceptionCS = Org_Exceptions__c.getOrgDefaults();
        if( !orgExceptionCS.Bypass_Processes__c ){
            for(Digital_Campaign__c dCampaign : scope){
                dCampaign.Status__c = '99 Campaign Completed'; 
            }
             
            executionUtils.disableBox();
            update scope;
        }
    }

    global void finish(Database.BatchableContext BC){
    	executionUtils.enableBox();
    }
}