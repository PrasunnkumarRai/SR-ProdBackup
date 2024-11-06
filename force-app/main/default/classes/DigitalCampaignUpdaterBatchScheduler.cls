global class DigitalCampaignUpdaterBatchScheduler implements Schedulable {
    
    global final String Query;
    global final Integer batchSize;
    
    global DigitalCampaignUpdaterBatchScheduler(){
        
        if( !Test.isRunningTest() ){
       		query = 'SELECT Id, Status__c FROM Digital_Campaign__c Where Campaign_End_Date__c != null AND SAM_Designation__c != \'Pending Key\' AND Campaign_End_Date__c<TODAY AND'+
                                                   ' ( Status__c=\'19 Revision Live\' OR Status__c=\'09 Live\' OR Status__c=\'20 Missing Creative / Instructions\' )';
                                                   
    	}else{
    		query = 'SELECT Id, Status__c FROM Digital_Campaign__c Where Campaign_End_Date__c != null AND '+
                                                   ' ( Status__c=\'19 Revision Live\' OR Status__c=\'09 Live\' OR Status__c=\'20 Missing Creative / Instructions\' )';
        }
        batchSize = 1;
    }
    
    global DigitalCampaignUpdaterBatchScheduler( String q, Integer bs ){
        Query = q;
        batchSize = bs;
    }
    
    global void execute(SchedulableContext sc) {
    
        DigitalCampaignUpdaterBatch batchable = new DigitalCampaignUpdaterBatch( Query ); 
        database.executebatch( batchable, batchSize );
    }
}