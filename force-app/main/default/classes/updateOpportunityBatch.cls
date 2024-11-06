global class updateOpportunityBatch implements Database.Batchable<sObject> , Database.Stateful{
    public String query;
    public Admin_Tool_Status_Summary__c adminToolSummary;
    public Map<String,List<Proposal__c>> mapOfProposals;
    public Map<String,Integer> mapOfBatchsizes;
    List<UserConnection__c> userConn = new List<UserConnection__c>();
    Map<String,String> mapOfTimAEIds = new Map<String,String>();

    global updateOpportunityBatch(String query , Admin_Tool_Status_Summary__c adminToolSmry ,Map<String,Integer> mapOfBcthsize) {
        this.query = query;
        this.adminToolSummary = adminToolSmry;
        this.mapOfBatchsizes = mapOfBcthsize;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Admin_Tool_Status_Detail__c> scope) {
       try{
           customLookUpController.updateOpportunities(adminToolSummary.From_User_Id__c , adminToolSummary.To_User_Id__c , scope );
        }
        catch(Exception exp){
            System.debug('Error while updating Admin Status Details records::'+exp.getMessage());
        }
    }

    global void finish(Database.BatchableContext BC) {

        String query = 'Select id,Id__c , Status__c,Error_Message__c from Admin_Tool_Status_Detail__c where Object_Type__c = \'Account Team\' and Status__c=\'Not Started\' and Admin_Tool_Status_Summary__c =\''+adminToolSummary.Id+'\'';
        CreateAccountTeamBatch updateOppBatch = new CreateAccountTeamBatch(query,adminToolSummary ,mapOfBatchsizes);
        Id batchJobId = Database.executeBatch(updateOppBatch ,mapOfBatchsizes.get('Account_Team_Batch_Size'));


    }
}