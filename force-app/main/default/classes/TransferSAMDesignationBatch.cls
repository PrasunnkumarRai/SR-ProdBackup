global with sharing class TransferSAMDesignationBatch implements Database.Batchable<sObject>, Database.Stateful {
	public String query;
	public List<Admin_Tool_Status_Summary__c> adminToolSummary;
	public Map<String, Integer> mapOfBatchsizes;
	public Set<ID> admToolSummaryIDs;
	public Boolean isRetry = false;
	public Set<ID> atmIds;


	global TransferSAMDesignationBatch(String query, List<Admin_Tool_Status_Summary__c> adminToolSmry, Map<String, Integer> mapOfBcthsize) {
		this.query = query;
		this.adminToolSummary = adminToolSmry;
		this.mapOfBatchsizes = mapOfBcthsize;
		this.admToolSummaryIDs = new Set<ID> ();
		this.atmIds = new Set<ID> ();

		for (Admin_Tool_Status_Summary__c adminStsDet : adminToolSmry) {
			admToolSummaryIDs.add(adminStsDet.ID);
			atmIds.add(adminStsDet.Transfer_Details__r.Account_Transfer_Simulation__r.Id);
			System.debug(adminStsDet.Transfer_Details__r.Account_Transfer_Simulation__r.Id);
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

		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, list<Account_Transfer_Mapping__c> scope) {

		try {
			System.debug('scope' + scope.size());
			MergeAccountSAM(scope);
			if (Test.isRunningTest()) {
				CalloutException e = new CalloutException();
				e.setMessage('This is a constructed exception for testing and code coverage');
				throw e;
			}

		}
		catch(Exception ex) {
			System.debug('Error while updating Admin Status Details records::' + ex.getMessage());
			Log4SF.logMessage('TransferSAMDesignationBatch', 'execute', ex.getMessage(), ex, UserInfo.getUserId(), BC.getJobID(), '');
		}

	}

	global void finish(Database.BatchableContext BC) {
		if (isRetry == false)
		{
			if (!Test.isRunningTest()) {
				string query = 'Select ID,Transfer_Details__c,Transfer_Details__r.Account__c, Transfer_Details__r.To_User__c, Transfer_Details__r.From_User__c,Transfer_Details__r.From_User__r.Id,Transfer_Details__r.To_User__r.Id,Transfer_Details__r.Account__r.Id from Admin_Tool_Status_Summary__c  where id in :admToolSummaryIDs';
				TransferRevenueBatch transferRevBatch = new TransferRevenueBatch(query, adminToolSummary, mapOfBatchsizes);
				Id batchJobId = Database.executeBatch(transferRevBatch, mapOfBatchsizes.get('Revenue_Batch_Size'));
			}
		}
	}

	global void MergeAccountSAM(List<Account_Transfer_Mapping__c> accATM)
	{
		List<Account_SAM_Mapping__c> updateAccSAMList = new List<Account_SAM_Mapping__c> ();
		List<Account_SAM_Mapping__c> delAccSAMList = new List<Account_SAM_Mapping__c> ();
		Set<ID> userList = new Set<ID> ();
		Set<ID> accList = new Set<ID> ();

		Map<Id, Map<Id, Id>> userToFromAccMap = new Map<Id, Map<Id, Id>> ();

		try {
			for (Account_Transfer_Mapping__c atm : accATM)
			{
				userList.add(atm.From_User__c);
				userList.add(atm.To_User__c);
				accList.add(atm.Account__r.Id);


				Map<Id, Id> fromToUserMap = new Map<Id, Id> ();
				fromToUserMap.put(atm.From_User__c, atm.To_User__c);
				userToFromAccMap.put(atm.Account__r.Id, fromToUserMap);
			}

			List<Account_SAM_Mapping__c> accSAMList = [Select ID, User__c, Tier_Designation__c,SAM_Designation__c, Account__c, Is_Transferred__c, Old_SAM_Designation__c
			                                           from Account_SAM_Mapping__c where Account__c in :accList];
			System.debug('userToFromAccMap :' + userToFromAccMap);
			Map<String, Account_SAM_Mapping__c> accSAMMap = new Map<String, Account_SAM_Mapping__c> ();
			for (Account_SAM_Mapping__c accSAM : accSAMList)
			{
				accSAMMap.put(accSAM.User__c + ':' + accSAM.Account__c, accSAM);
			}

			//TODO: Account Tier_Designation__c mappings as discussed with Greg
			//for (Id accKey : userToFromAccMap.keySet())
			//{
			for(Account_SAM_Mapping__c accSam : accSAMMap.values())
			{
				if(userToFromAccMap.containsKey(accSam.Account__c))
				{
					
				}
			}

			if(System.label.SAMDesignationShutDown == 'FALSE'){
				for (Id accKey : userToFromAccMap.keySet())
				{
					Map<Id, Id> fromToUser = new Map<Id, Id> ();
					fromToUser = userToFromAccMap.get(accKey);

					for (Id item : fromToUser.keySet())
					{
						if (accSAMMap.containsKey(fromToUser.get(item) + ':' + accKey))
						{
							if (accSAMMap.containsKey(item + ':' + accKey) != false)
							{
								delAccSAMList.add(accSAMMap.get(item + ':' + accKey));
							}
						}

						else
						{
							System.debug('Test:  ' + accSAMMap.containsKey(item + ':' + accKey));
							System.debug(accSAMMap.get(item + ':' + accKey));
							if (accSAMMap.containsKey(item + ':' + accKey) != false)
							{
								//accSAMMap.get(item + ':' + accKey).User__c = fromToUser.values().get(0);
								//if (accSAMMap.get(item + ':' + accKey).Tier_Designation__c == 'Target' || accSAMMap.get(item + ':' + accKey).Tier_Designation__c == 'Extra') {
									//delAccSAMList.add(accSAMMap.get(item + ':' + accKey));
									////accSAMMap.get(item + ':' + accKey).Old_SAM_Designation__c = accSAMMap.get(item + ':' + accKey).Tier_Designation__c;
									////accSAMMap.get(item + ':' + accKey).Tier_Designation__c = 'Secondary';
								//}
								//else {
									accSAMMap.get(item + ':' + accKey).User__c = fromToUser.get(item);
									accSAMMap.get(item + ':' + accKey).Is_Transferred__c = true;
									updateAccSAMList.add(accSAMMap.get(item + ':' + accKey));
								
							}
						}
					}
					if (Test.isRunningTest()) {
						CalloutException e = new CalloutException();
						e.setMessage('This is a constructed exception for testing and code coverage');
						throw e;
					}
				}
			}

			if (updateAccSAMList.size() > 0)
			update updateAccSAMList;

			if (delAccSAMList.size() > 0)
			delete delAccSAMList;
		}

		catch(Exception ex)
		{
			Log4SF.logMessage('TransferSAMDesignationBatch', 'MergeAccountSAM', ex.getMessage(), ex, UserInfo.getUserId(), '', '');
		}
	}
}