global class DigitalCreativeUpdaterBatchScheduler implements Schedulable {

    global final String Query;
    global final Integer batchSize;
    
    global DigitalCreativeUpdaterBatchScheduler(){
        
        if( !Test.isRunningTest() ){
            query = 'SELECT Id, Status__c, Record_Lock__c FROM Digital_Creative__c Where Creative_End_Date__c != null AND Creative_End_Date__c < TODAY AND SAM_Designation__c != \'Pending Key\' AND Digital_Campaign__r.SAM_Designation__c != \'Pending Key\' AND'+
                                                   ' ( Status__c=\'05 Trafficked by Digital Ops\' OR Status__c=\'64 Date Revision Confirmed by Digital Ops\' )';
                                                   
        }else{
            query = 'SELECT Id, Status__c FROM Digital_Creative__c Where Digital_Campaign_End_Date__c!= null AND '+
                                                   ' ( Status__c=\'05 Trafficked by Digital Ops\' OR Status__c=\'64 Date Revision Confirmed by Digital Ops\' )';
        }
        batchSize = 1;
    }
    
    global DigitalCreativeUpdaterBatchScheduler( String q, Integer bs ){
        Query = q;
        batchSize = bs;
    }
    
    global void execute(SchedulableContext sc) {
    
        DigitalCreativeUpdaterBatch batchable = new DigitalCreativeUpdaterBatch( Query ); 
        database.executebatch( batchable, batchSize );
    }
}