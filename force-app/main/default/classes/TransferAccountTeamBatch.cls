global class TransferAccountTeamBatch implements Database.Batchable<sObject> ,Database.Stateful{
    public String query;
    public List<Admin_Tool_Status_Summary__c> adminToolSummary;
    public Map<String,Integer> mapOfBatchsizes;
    public Set<ID> admToolSummaryIDs;
	public Boolean  isRetry = false;

    global TransferAccountTeamBatch(String query , List<Admin_Tool_Status_Summary__c> adminToolSmry,Map<String,Integer> mapOfBcthsize) {
        this.query = query;
        this.adminToolSummary = adminToolSmry;
        this.mapOfBatchsizes = mapOfBcthsize;
        this.admToolSummaryIDs= new Set<ID>();
        for(Admin_Tool_Status_Summary__c adminStsDet : adminToolSmry ){
        	admToolSummaryIDs.add(adminStsDet.ID);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Admin_Tool_Status_Detail__c> scope) {

        try{
            New_AETransferToolController.updateAccountTeam(scope );
        }
        catch(Exception ex){
        	Log4SF.logMessage('TransferAccountTeamBatch', 'execute', ex.getMessage(),ex, UserInfo.getUserId(),BC.getJobID(),'');
            System.debug('Error while updating Admin Status Details records::'+ex.getMessage());
        }

    }

    global void finish(Database.BatchableContext BC) 
	{
		if(isRetry == false)
		{
			String query = 'Select id,Id__c , Status__c,Error_Message__c, Admin_Tool_Status_Summary__r.To_User_ID__c, Admin_Tool_Status_Summary__r.From_User_ID__c,AccountConnection__c,New_AE_Id_for_Account_Conn__c from Admin_Tool_Status_Detail__c where Object_Type__c = \'Account Connection\' and Status__c=\'Not Started\' and Admin_Tool_Status_Summary__r.Id in : admToolSummaryIDs';
			TransferAccountConnectionBatch  updateAccConnBatch = new TransferAccountConnectionBatch (query,adminToolSummary ,mapOfBatchsizes);
			Id batchJobId = Database.executeBatch(updateAccConnBatch , mapOfBatchsizes.get('Account_Connection_Batch_Size'));

		}
	}
}