global with sharing class TransferSalesBudgetBatch implements Database.Batchable<sObject>, Database.Stateful {

	public String query;
	public List<Admin_Tool_Status_Summary__c> adminToolSummary;
	public Map<String, Integer> mapOfBatchsizes;
	public Set<ID> admToolSummaryIDs;
	public Set<ID> atmIds;
	public string simulateId;
	public Boolean transferAllAcc;
	public Boolean IsRetry = false;

	global TransferSalesBudgetBatch(String query, List<Admin_Tool_Status_Summary__c> adminToolSmry, Map<String, Integer> mapOfBcthsize) {
		this.query = query;
		this.adminToolSummary = adminToolSmry;
		this.mapOfBatchsizes = mapOfBcthsize;
		this.admToolSummaryIDs = new Set<ID> ();
		this.atmIds = new Set<ID> ();
		this.transferAllAcc = false;

		for (Admin_Tool_Status_Summary__c adminStsDet : adminToolSmry) {
			admToolSummaryIDs.add(adminStsDet.ID);
			atmIds.add(adminStsDet.Transfer_Details__r.Account_Transfer_Simulation__r.Id);
			system.debug('Simulation Id: ' + adminToolSummary[0].Transfer_Details__r.Account_Transfer_Simulation__r.Id);
			system.debug('atmIds Id: ' + atmIds);
		}
	}

	global Database.QueryLocator start(Database.BatchableContext bc) {
			system.debug('atmIds Id start:  ' + atmIds);
		query = 'Select ID, Account__c, From_User__r.ID, To_User__r.Id, To_User__r.Rate_Plan_Status__c, Account__r.Id,Account_Transfer_Simulation__r.Transfer_All_Accounts__c, Count_Of_Sales_Budget_Errors__c,' +
		'From_User__r.Budget_Type__c, To_User__r.Budget_Type__c, Count_Of_Sales_Budget_Success__c, Sales_Budget_Errors__c,dma__c,Total_Count_of_Sales_Budget__c, ' +
		'Account_Transfer_Simulation__r.Transfer_Effective_Date__c,Account_Transfer_Simulation__c, Account_Transfer_Simulation__r.NCC__c ' +
		'From Account_Transfer_Mapping__c where Account_Transfer_Simulation__c in :atmIds';
		if (isRetry)
		{
			query += ' AND Account_Transfer_Simulation__r.Status__c = \'Transfer Completed\'';
		}
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, list<Account_Transfer_Mapping__c> scope) {

		try {
			System.debug('TransferSalesBudgetBatch scope: ' + scope);
			New_AETransferToolController.updateSalesBudget(scope, isRetry);
			simulateId = scope[0].Account_Transfer_Simulation__c;
			transferAllAcc = scope[0].Account_Transfer_Simulation__r.Transfer_All_Accounts__c;
		}
		catch(Exception ex) {
			System.debug('Error while transferring Sales Budget records: ' + ex.getMessage());
			Log4SF.logMessage('TransferSalesBudgetBatch', 'execute', ex.getMessage(), ex, UserInfo.getUserId(), BC.getJobID(), '');
		}
	}

	global void finish(Database.BatchableContext BC) {
		//New_AETransferToolController.updateAdminSummary(adminToolSummary);

		if (IsRetry == false) {
			if (adminToolSummary.size() > 0)
			{
                
				system.debug('adminToolSummary: ' + adminToolSummary[0]);
				system.debug('Simulation Id: ' + adminToolSummary[0].Transfer_Details__r.Account_Transfer_Simulation__r.Id);
                 if(!Test.isRunningTest()) {
				TransferNewsBusinessBatch transferBudBatch = new TransferNewsBusinessBatch(simulateId, transferAllAcc, adminToolSummary, mapOfBatchsizes);
				Id batchJobId = Database.executeBatch(transferBudBatch, mapOfBatchsizes.get('NBUC_Batch_Size'));
			}
            }}
	}

	/*Sample Batch Test script
	  List<Admin_Tool_Status_Summary__c> adminToolSmry =[Select id,transfer_details__c from Admin_Tool_Status_Summary__c where id = 'a1Q2C0000006Mkq'];
	  Map<String,Integer> mapOfBcthsize = new Map<String,Integer>();
	  mapOfBcthsize.put('Budget_Batch_Size',200);
	  TransferSalesBudgetBatch tsb = new TransferSalesBudgetBatch('',adminToolSmry,mapOfBcthsize);
	 
	  Database.executeBatch(tsb);
	 */

}