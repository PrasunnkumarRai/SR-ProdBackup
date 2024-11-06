global class TransferDigitalCampaignBatch implements Database.Batchable<SObject> {
	public String query;
	public List<Admin_Tool_Status_Summary__c> adminToolSummary;
	public Map<String, Integer> mapOfBatchsizes;
	//public Set<ID> admToolSummaryIDs;
	public Boolean isRetry = false;
	public Set<ID> atmIds;
	public Set<ID> accountIDs;
	public String simulateID;
	public Map<String,Map<String,String>> accFromToUserMap;
	public Map<String, Account_Transfer_Mapping__c> accATMMap;


	/*
		The constructor of the Class - used to pass the query, list of records and Batch Size.
	*/

	global TransferDigitalCampaignBatch(String query, List<Admin_Tool_Status_Summary__c> adminToolSmry,		string simulateID) {
		this.query = query;
		this.adminToolSummary = adminToolSmry;
		this.simulateID = simulateID;
		//this.admToolSummaryIDs = new Set<ID> ();
		this.atmIds = new Set<ID> ();
		this.accountIDs = new Set<ID> ();
		this.accFromToUserMap = new Map<String,Map<String,String>>();
		this.accATMMap = new Map<String, Account_Transfer_Mapping__c>();


		for (Admin_Tool_Status_Summary__c adminStsDet : adminToolSmry) {
			//admToolSummaryIDs.add(adminStsDet.ID);
			atmIds.add(adminStsDet.Transfer_Details__r.Account_Transfer_Simulation__r.Id);
			System.debug(adminStsDet.Transfer_Details__r.Account_Transfer_Simulation__r.Id);
		}
		query = 'Select ID, Account__c, From_User__r.ID, To_User__r.Id, To_User__r.Rate_Plan_Status__c, Account__r.Id,Account_Transfer_Simulation__r.Transfer_All_Accounts__c, Account_Transfer_Simulation__r.NCC__c, ' +
		'Count_Of_Revenue_Errors__c,Count_Of_Revenue_Success__c, Revenue_Errors__c,dma__c,Account_Transfer_Simulation__r.Transfer_Effective_Date__c,Account_Transfer_Simulation__c ' +
		'From Account_Transfer_Mapping__c where Account_Transfer_Simulation__c in :atmIds';
		if (isRetry)
		{
			query += ' AND Account_Transfer_Simulation__r.Status__c = \'Transfer Completed\'';
		}
		List<Account_Transfer_Mapping__c> atmList = Database.query(query);
		
		for(Account_Transfer_Mapping__c atm:atmList)
		{
			accountIDs.add(atm.Account__c);
			accFromToUserMap.put(atm.Account__c, new Map<String,String>{atm.From_User__c => atm.To_User__c});
			accATMMap.put(atm.Account__c, atm);

		}
	}
	
	/**
	 * @description gets invoked when the batch job starts
	 * @param context contains the job ID
	 * @returns the record set as a QueryLocator object that will be batched for execution
	 */ 
	global Database.QueryLocator start(Database.BatchableContext context) {
		String digitalCampaignQry = 'Select ID, Name, Opportunity__r.OwnerID,OwnerID, Account_Executive__c, Advertiser__c '+ 
		'from Digital_Campaign__c where Advertiser__c in: accountIDs';
		return Database.getQueryLocator(digitalCampaignQry);
		//return Database.getQueryLocator('');
	}

	/**
	 * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
	 * @param context contains the job ID
	 * @param scope contains the batch of records to process.
	 */ 
   	global void execute(Database.BatchableContext context, List<Digital_Campaign__c> scope) {
		try{
			updateDigitalCampaign(scope);
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('TransferDigitalCampaignBatch', 'Batch Execute',ex.getMessage() + ' ' + ex.getLineNumber(), UserInfo.getUserId(), '');
		}
	}

	/*
		Method used to query the Digital Campaign for each of the account.
	*/
	public void updateDigitalCampaign(List<Digital_Campaign__c> dcList)
	{
		List<Digital_Campaign__c> dcUpdateList = new List<Digital_Campaign__c>();
		for(Digital_Campaign__c dc : dcList)
		{
			if(accATMMap.containsKey(dc.Advertiser__c))
			{
				if(String.isNotBlank(dc.Account_Executive__c) && dc.Account_Executive__c == accATMMap.get(dc.Advertiser__c).From_User__c)
				{	
					dc.OwnerID = accATMMap.get(dc.Advertiser__c).To_User__c;
					dc.Account_Executive__c = accATMMap.get(dc.Advertiser__c).To_User__c;
				}
				dcUpdateList.add(dc);
					
			}
			List<Database.SaveResult> result = Database.update(dcUpdateList,true);
		}
	}
	
	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */ 
	global void finish(Database.BatchableContext context) {
		try {
			System.debug('isRetry Value: ' + IsRetry);
			System.debug('Budget recalculation initiated via boomi process.');
			Set<String> setuserIds = new Set<String> ();
			List<String> atsNames = new List<String> ();
			List<String> atmNames = new List<String> ();
			List<Account_Transfer_Mapping__c> atmList = [Select Id, Account__c, From_User__c, To_User__c from Account_Transfer_Mapping__c where Account_Transfer_Simulation__c = :simulateID];
			for (Account_Transfer_Mapping__c atmRec : atmList) {
				setuserIds.add(atmRec.From_User__c);
				setuserIds.add(atmRec.To_User__c);
				atmNames.add(atmRec.Id);
			}
			for (Admin_Tool_Status_Summary__c item : adminToolSummary) {
				atsNames.add(item.Id);
			}
			Log4SF.logMessage('TransferContactBatch', 'finish', 'Debug Log: User Ids: ' + setuserIds, UserInfo.getUserId(), '');
			Log4SF.logMessage('TransferContactBatch', 'finish', 'Debug Log: atsNames: ' + atsNames, UserInfo.getUserId(), '');
			Log4SF.logMessage('TransferContactBatch', 'finish', 'Debug Log: atmList: ' + atmNames, UserInfo.getUserId(), '');
			Log4SF.logMessage('TransferContactBatch', 'finish', 'Debug Log: simulateID: ' + simulateID, UserInfo.getUserId(), '');
			/*
			Budget Transfer should not happen anymore as Budgets will be provided by Finance.

			ID jobID = System.enqueueJob(new UserBudgetAggQueuebleJob(new List<String> (setuserIds)));
			*/
			if (isRetry == false)
			{
				Set<ID> userIds = New_AETransferToolController.returnSalesBudget(adminToolSummary);
				system.debug('userIds ' + userIds);
				String query = 'SELECT  Account_Executive__c  , Account_Executive__r.Name , Advertiser__c, Net_Projected_Amount__c , Broadcast_Month_Date__c,Revenue_User__c,Revenue_User__r.Name ';
				query += ' FROM Revenue__c where  Account_Executive__c in : userIDs AND Advertiser__c != null order by Revenue_User__r.Name,Account_Executive__r.Name,  Advertiser__c  desc';

				RevenueAggregatebatch srb = new RevenueAggregatebatch(query, userIds);
				//if (!Test.isRunningTest()) {
					database.ExecuteBatch(srb, 2000);
			//	}
				if (Test.isRunningTest())
				{
					if (userIds != null && userIds.size() > 1)
					{
						Integer count = userIds.size();
						for (Id usrId : userIds) {
							if (count > 2)
							{
								userIds.remove(usrId);
							}
							count--;
						}
					}

					else
					{
						userIds = new Set<ID> ();
						List<user> lstuserIds = [Select id from User WHERE isActive = true LIMIT 10];
						for (User u : lstuserIds)
						{
							userIds.add(u.id);
						}
					}
				}
				string qry = 'select id,rate_plan_status__c,Rate_Plan_Commit_Date__c from User where id in: userIds';

				//TrackRatePlanChangeQualifications trb = new TrackRatePlanChangeQualifications(qry, userIds);
				if (!Test.isRunningTest()) {
					//database.ExecuteBatch(trb, 1);
				}
				New_AETransferToolController.updateAdminSummary(adminToolSummary);
			}

			Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
			att.Id = simulateID;
			att.Status__c = 'Transfer Completed';
			Upsert att;
		}
		catch(Exception ex) {
			Log4SF.logMessage('TransferContactBatch', 'finish', ex.getMessage() + ' ' + ex.getLineNumber(), UserInfo.getUserId(), '');
		}
	}
}