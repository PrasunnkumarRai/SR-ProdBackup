global class DigitalCreativeUpdaterBatch implements Database.Batchable<sObject> {
	
	global final String query;
	
	global DigitalCreativeUpdaterBatch(String q) {
		Query = q;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Digital_Creative__c> scope) {
      //  Org_Exceptions__c orgExceptionCS = Org_Exceptions__c.getOrgDefaults();
     //   if( !orgExceptionCS.Bypass_Processes__c ){
            for(Digital_Creative__c dcc : scope){
                dcc.Status__c = '99 Creative Completed'; 
                dcc.Record_Lock__c = true;
            }
             
            executionUtils.disableBox();
            update scope;
      //  }	
	}
	
	global void finish(Database.BatchableContext BC) {
		executionUtils.enableBox();
	}
	
}