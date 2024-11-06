public class SAMDATARecordsDeleteBatch implements Database.Batchable<sObject> {
	Set<String> designations;
    
    public SAMDATARecordsDeleteBatch(List<String> designations) {
        this.designations = new Set<String>(designations);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
            String query = 'SELECT Id FROM Account_SAM_Mapping__c WHERE Tier_Designation__c IN :designations ';
            return Database.getQueryLocator(query);
     
    }
    
    public void execute(Database.BatchableContext bc, List<Account_SAM_Mapping__c> scope) {
            delete scope;
        
    }
    
    public void finish(Database.BatchableContext bc) {
        
    }
}