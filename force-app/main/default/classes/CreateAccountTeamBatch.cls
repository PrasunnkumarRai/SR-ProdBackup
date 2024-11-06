global class CreateAccountTeamBatch implements Database.Batchable<sObject> ,Database.Stateful{
    public String query;
    public Admin_Tool_Status_Summary__c adminToolSummary;
    public Map<String,Integer> mapOfBatchsizes;

    global CreateAccountTeamBatch(String query , Admin_Tool_Status_Summary__c adminToolSmry,Map<String,Integer> mapOfBcthsize) {
        this.query = query;
        this.adminToolSummary = adminToolSmry;
        this.mapOfBatchsizes = mapOfBcthsize;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Admin_Tool_Status_Detail__c> scope) {

        try{
            customLookUpController.updateAccountTeam(adminToolSummary.From_User_Id__c , adminToolSummary.To_User_Id__c ,scope );
        }
        catch(Exception exp){
            System.debug('Error while updating Admin Status Details records::'+exp.getMessage());
        }

    }

    global void finish(Database.BatchableContext BC) {

        String query = 'Select id,Id__c , Status__c,Error_Message__c,AccountConnection__c,New_AE_Id_for_Account_Conn__c from Admin_Tool_Status_Detail__c where Object_Type__c = \'Account Connection\' and Status__c=\'Not Started\' and Admin_Tool_Status_Summary__c =\''+adminToolSummary.Id+'\'';
        UpdateAccountConnectionBatch updateAccConnBatch = new UpdateAccountConnectionBatch(query,adminToolSummary ,mapOfBatchsizes);
        Id batchJobId = Database.executeBatch(updateAccConnBatch , mapOfBatchsizes.get('Account_Connection_Batch_Size'));

    }
}