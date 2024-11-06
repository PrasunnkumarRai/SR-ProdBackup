global class UpdateAccountConnectionBatch implements Database.Batchable<sObject>,Database.Stateful {
    public String query;
    public Admin_Tool_Status_Summary__c adminToolSummary;
    public Map<String,Integer> mapOfBatchsizes;

    global UpdateAccountConnectionBatch(String query , Admin_Tool_Status_Summary__c adminToolSmry ,Map<String,Integer> mapOfBcthsize) {
        this.query = query;
        this.adminToolSummary = adminToolSmry;
        this.mapOfBatchsizes = mapOfBcthsize;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Admin_Tool_Status_Detail__c> scope) {

        try{
          customLookUpController.updateAccountConnections(scope);
        }
        catch(Exception exp){
            System.debug('Error while updating Admin Status Details records::'+exp.getMessage());
        }

    }

    global void finish(Database.BatchableContext BC) {
		// Commented Activities batch as per Gregs feedback
        //String query = 'Select id,Id__c,Status__c,Error_Message__c from Admin_Tool_Status_Detail__c where Object_Type__c = \'Activity\' and Status__c=\'Not Started\' and Admin_Tool_Status_Summary__c =\''+adminToolSummary.Id+'\'';
        //UpdateAllActivitiesBatch updateActivities = new UpdateAllActivitiesBatch(query,adminToolSummary,mapOfBatchsizes);
        //Id batchJobId = Database.executeBatch(updateActivities , mapOfBatchsizes.get('Activity_Batch_Size'));
        customLookUpController.updateAdminSummary(adminToolSummary);

    }
}