global class TransferAccountConnectionBatch implements Database.Batchable<sObject>,Database.Stateful {
    public String query;
    public List<Admin_Tool_Status_Summary__c> adminToolSummary;
    public Map<String,Integer> mapOfBatchsizes;
    public Set<ID> admToolSummaryIDs;
	public Boolean isRetry = false;


    global TransferAccountConnectionBatch(String query , List<Admin_Tool_Status_Summary__c> adminToolSmry ,Map<String,Integer> mapOfBcthsize) {
        this.query = query;
        this.adminToolSummary = adminToolSmry;
        this.mapOfBatchsizes = mapOfBcthsize;
        this.admToolSummaryIDs = new Set<ID>();
        for(Admin_Tool_Status_Summary__c adminStsDet : adminToolSmry ){
            admToolSummaryIDs.add(adminStsDet.ID);
        }
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Admin_Tool_Status_Detail__c> scope) {

        try{
          New_AETransferToolController.updateAccountConnections(scope);
        }
        catch(Exception ex){
        	Log4SF.logMessage('TransferAccountConnectionBatch', 'execute', ex.getMessage(),ex, UserInfo.getUserId(),BC.getJobID(),'');
            System.debug('Error while updating Admin Status Details records::'+ex.getMessage());
        }

    }

    global void finish(Database.BatchableContext BC) {
        // Commented Activities batch as per Gregs feedback
        //String query = 'Select ID, Account__c, From_User__r.ID, To_User__r.Id, Account__r.Id from Account_Transfer_Mapping__c where Admin_Tool_Status_Summary__c =\''+adminToolSummary.Id+'\'';
        //UpdateAllActivitiesBatch updateActivities = new UpdateAllActivitiesBatch(query,adminToolSummary,mapOfBatchsizes);
        //Id batchJobId = Database.executeBatch(updateActivities , mapOfBatchsizes.get('Activity_Batch_Size'));
		if(isRetry == false)
		{
			string query = 'Select ID,Transfer_Details__r.Account__c, Transfer_Details__r.To_User__c, Transfer_Details__r.From_User__c,Transfer_Details__r.From_User__r.Id,Transfer_Details__r.To_User__r.Id,Transfer_Details__r.Account__r.Id from Admin_Tool_Status_Summary__c  where   id in : admToolSummaryIDs';
			TransferSAMDesignationBatch transferAccSAM = new TransferSAMDesignationBatch(query,adminToolSummary,mapOfBatchsizes);
			Id batchJobId = Database.executeBatch(transferAccSAM , mapOfBatchsizes.get('Account_SAM_Mappings_Batch_Size'));
        }


    }
}