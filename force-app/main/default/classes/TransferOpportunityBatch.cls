global class TransferOpportunityBatch implements Database.Batchable<sObject> , Database.Stateful{
    public String query;
    public List<Admin_Tool_Status_Summary__c> adminToolSummary;
    public Map<String,String> mapOppNewOwner;
    public Map<String,Integer> mapOfBatchsizes;
    public Set<ID> admToolSummaryIDs;
    List<UserConnection__c> userConn = new List<UserConnection__c>();
    Map<String,String> mapOfTimAEIds = new Map<String,String>();
    public Boolean IsRetry = false;

    global TransferOpportunityBatch(String query , List<Admin_Tool_Status_Summary__c> adminToolSmry ,Map<String,Integer> mapOfBcthsize) {
        this.query = query;
        System.debug('q'+query);
        this.adminToolSummary = adminToolSmry;
        this.mapOfBatchsizes = mapOfBcthsize;
        this.admToolSummaryIDs = new Set<ID>();
        for(Admin_Tool_Status_Summary__c adminStsDet : adminToolSmry ){
        	admToolSummaryIDs.add(adminStsDet.ID);
        }
        //this.query = query.replace(replace, admToolSummaryIDs);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
        //System.debug('q1'+query);
        
        
        
        
    }

    global void execute(Database.BatchableContext BC, list<Admin_Tool_Status_Detail__c> scope) {
       try{
       		mapOppNewOwner = new Map<String, String>();
       		for(Admin_Tool_Status_Detail__c adm : scope)
       		{
       			mapOppNewOwner.put(adm.ID__c,adm.Admin_Tool_Status_Summary__r.To_User_ID__c);
       		}
           	New_AETransferToolController.updateOpportunities(mapOppNewOwner, scope);
           
            
        }
        catch(Exception ex){
        	Log4SF.logMessage('TransferOpportunityBatch', 'execute', ex.getMessage(),ex, UserInfo.getUserId(),BC.getJobID(),''); 
            System.debug('Error while updating Admin Status Details records::'+ex.getMessage());
        }
    }

    global void finish(Database.BatchableContext BC) {
		if(IsRetry == false){
	        String query = 'Select id,Id__c , Status__c,Error_Message__c, Admin_Tool_Status_Summary__r.To_User_ID__c,AccountConnection__c, Admin_Tool_Status_Summary__r.From_User_ID__c from Admin_Tool_Status_Detail__c where Object_Type__c = \'Account Team\' and Status__c=\'Not Started\' and Admin_Tool_Status_Summary__c in: admToolSummaryIDs';
	        TransferAccountTeamBatch updateOppBatch = new TransferAccountTeamBatch(query,adminToolSummary ,mapOfBatchsizes);
	        Id batchJobId = Database.executeBatch(updateOppBatch ,mapOfBatchsizes.get('Account_Team_Batch_Size'));
		}

    }
}