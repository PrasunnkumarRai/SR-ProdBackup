global with sharing class TransferRevenueBatch implements Database.Batchable<sObject>, Database.Stateful {
	public String query;
	public List<Admin_Tool_Status_Summary__c> adminToolSummary;
	public Map<String, Integer> mapOfBatchsizes;
	public Set<ID> admToolSummaryIDs;
	public Set<ID> atmIds;
	public Boolean IsRetry = false;

	global TransferRevenueBatch(String query, List<Admin_Tool_Status_Summary__c> adminToolSmry, Map<String, Integer> mapOfBcthsize) {
		this.query = query;
		this.adminToolSummary = adminToolSmry;
		this.mapOfBatchsizes = mapOfBcthsize;
		this.admToolSummaryIDs = new Set<ID> ();
		this.atmIds = new Set<ID> ();

		for (Admin_Tool_Status_Summary__c adminStsDet : adminToolSmry) {
			admToolSummaryIDs.add(adminStsDet.ID);
			atmIds.add(adminStsDet.Transfer_Details__r.Account_Transfer_Simulation__r.Id);
		}
	}

	global TransferRevenueBatch(List<Account_Transfer_Tool__c> ATTList, Map<String, Integer> mapOfBcthsize) {
		System.debug('ATTList size: ' + ATTList.size());
		System.debug('ATTList: ' + ATTList);
		this.mapOfBatchsizes = mapOfBcthsize;
		this.atmIds = new Set<ID> ();

		for (Account_Transfer_Tool__c att : ATTList) {
			atmIds.add(att.Id);
		}
	}

	global Database.QueryLocator start(Database.BatchableContext bc) {
		query = 'Select ID, Account__c, From_User__r.ID, To_User__r.Id, To_User__r.Rate_Plan_Status__c, Account__r.Id,Account_Transfer_Simulation__r.Transfer_All_Accounts__c, Account_Transfer_Simulation__r.NCC__c, ' +
		'Count_Of_Revenue_Errors__c,Count_Of_Revenue_Success__c, Revenue_Errors__c,dma__c,Account_Transfer_Simulation__r.Transfer_Effective_Date__c,Account_Transfer_Simulation__c ' +
		'From Account_Transfer_Mapping__c where Account_Transfer_Simulation__c in :atmIds';
		if (isRetry)
		{
			query += ' AND Account_Transfer_Simulation__r.Status__c = \'Transfer Completed\'';
		}
		System.debug('Query: ' + query);
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, list<Account_Transfer_Mapping__c> scope) {

		try {
			System.debug('TransferRevenueBatch scope: ' + scope);
			New_AETransferToolController.updateRevenue(scope);
		}
		catch(Exception ex) {
			System.debug('Error while transferring Revenue records: ' + ex.getMessage());
			Log4SF.logMessage('TransferRevenueBatch', 'execute', ex.getMessage(), ex, UserInfo.getUserId(), BC.getJobID(), '');
		}
	}

	global void finish(Database.BatchableContext BC) {
		if (IsRetry == false) {
			String query = 'Select ID,Transfer_Details__c,Transfer_Details__r.Account__c, Transfer_Details__r.To_User__c, Transfer_Details__r.From_User__c,Transfer_Details__r.From_User__r.Id,Transfer_Details__r.To_User__r.Id,Transfer_Details__r.Account__r.Id from Admin_Tool_Status_Summary__c  where id in :admToolSummaryIDs';
			TransferSalesBudgetBatch transferBudBatch = new TransferSalesBudgetBatch(query, adminToolSummary, mapOfBatchsizes);
			Id batchJobId = Database.executeBatch(transferBudBatch, mapOfBatchsizes.get('Budget_Batch_Size'));
		}
	}

	/*Sample Batch Test script
	  List<Admin_Tool_Status_Summary__c> adminToolSmry =[Select id,transfer_details__c from Admin_Tool_Status_Summary__c where id = 'a1Y1K00000346EBUAY'];
	  Map<String,Integer> mapOfBcthsize = new Map<String,Integer>();
	  mapOfBcthsize.put('Budget_Batch_Size',200);
	  TransferRevenueBatch trb = new TransferRevenueBatch('',adminToolSmry,mapOfBcthsize);
	 
	  Database.executeBatch(trb);
	 */
}