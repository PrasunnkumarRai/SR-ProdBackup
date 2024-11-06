public class AOSDealIdBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts,Schedulable {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Query to get AOS_Deal_Id__c from Proposal__c
        String query = 'SELECT AOS_Deal_Id__c FROM Proposal__c WHERE AOS_Deal_Id__c != NULL';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<String> aosDealIds = new List<String>();
        
        for (SObject sObj : scope) {
            Proposal__c proposal = (Proposal__c) sObj;
            aosDealIds.add(proposal.AOS_Deal_Id__c);
        }
        
         if (!aosDealIds.isEmpty()) {
            // Process IDs in chunks of 200
            Integer chunkSize = 200;
            for (Integer i = 0; i < aosDealIds.size(); i += chunkSize) {
                List<String> chunk = new List<String>();
                Integer lastval = Math.min(i + chunkSize, aosDealIds.size());
                for (Integer j = i; j < lastval; j++) {
                    chunk.add(aosDealIds[j]);
                }
                AOSDealIdSender handler = new AOSDealIdSender();
                handler.sendAOSDealIds(chunk);
            }
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('Batch processing completed.');
    }
	public void execute(SchedulableContext sc) {
        integer batchSize = 1;  
        Database.executeBatch(new AOSDealIdBatch(), 200);
     }
}