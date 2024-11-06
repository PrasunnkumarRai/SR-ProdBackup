public with sharing class AccountTransferToolRetryController {

	public String atsId;
	public String retryScope;
	public List<Admin_Tool_Status_Summary__c> admToolSummaryIDs;
	Map<String, Integer> mapOfBatchsizes = new Map<String, Integer> ();
	public String errorMsg { get; set; }
	public Boolean isStatusComplete { get; set; }


	/**
	 * This constructor gets called on page load
	 * 
	 */
	public AccountTransferToolRetryController(ApexPages.StandardController controller) {
		atsId = ApexPages.currentPage().getParameters().get('id');
		retryScope = ApexPages.currentPage().getParameters().get('retry');
		errorMsg = '';
		isStatusComplete = false;
		System.debug('atsId: ' + atsId);
		System.debug('retryScope: ' + retryScope);
	}



	public pageReference retry() {

		for (AE_transfer_setting__mdt aeTransferSetting :[Select id, DeveloperName, BatchSize__c from AE_transfer_setting__mdt LIMIT 1000]) {
			mapOfBatchsizes.put(aeTransferSetting.DeveloperName, Integer.valueOf(aeTransferSetting.BatchSize__c));
		}

		admToolSummaryIDs = [Select ID, To_User_Id__c, From_User_Id__c, Transfer_Details__r.Account_Transfer_Simulation__r.Transfer_Effective_Date__c,
		                     Transfer_Details__c, Transfer_Details__r.Account_Transfer_Simulation__r.Id, Transfer_Details__r.Account_Transfer_Simulation__r.Count_Of_Sales_Budget_Success__c,
		                     Transfer_Details__r.Account_Transfer_Simulation__r.Total_Count_of_Sales_Budget__c
		                     from Admin_Tool_Status_Summary__c
		                     where Transfer_Details__r.Account_Transfer_Simulation__c = :atsId];

		List<Account_Transfer_Tool__c> status = [SELECT Status__c FROM Account_Transfer_Tool__c WHERE ID = :atsId];

		if (status[0].Status__c != 'Transfer Completed')
		{
			List<String> retryValue = new List<String> ();
			retryValue.add(retryScope);
			isStatusComplete = true;
			errorMsg = String.format(Label.AXT_Retry_Error_Message, retryValue);
			return null;
		}

		if (retryScope == 'proposal') {
			retryProposals();
		}

		if (retryScope == 'opportunity') {
			retryOpportunities();
		}

		if (retryScope == 'revenue') {
			retryRevenues();
		}

		if (retryScope == 'salesbudget') {
			if (admToolSummaryIDs.size() > 0)
			{
				System.debug('retry count ' + admToolSummaryIDs[0].Transfer_Details__r.Account_Transfer_Simulation__r.Count_Of_Sales_Budget_Success__c + ' : ' + admToolSummaryIDs[0].Transfer_Details__r.Account_Transfer_Simulation__r.Total_Count_of_Sales_Budget__c);
				//if(admToolSummaryIDs[0].Transfer_Details__r.Account_Transfer_Simulation__r.Count_Of_Sales_Budget_Success__c != admToolSummaryIDs[0].Transfer_Details__r.Account_Transfer_Simulation__r.Total_Count_of_Sales_Budget__c)
				retrySalesBudget();
				/*else{
				  isStatusComplete = true;
				  errorMsg = 'All Sales Budget data have already been transferred Successfully.' ;
				  return null;
				  }*/
			}



		}

		if (retryScope == 'newsbusiness') {
			retryNewsBusiness();
		}

		if (retryScope == 'accountconn') {
			retryAccountConnection();
		}

		if (retryScope == 'accteam') {
			retryAccountTeam();
		}
		if (retryScope == 'Contact') {
			retryConatactTransfer();
		}


		if (retryScope == 'samdesignation') {
			retrySAMDesignation();
		}
		return new PageReference('/' + atsId);
	}

	public pageReference retryProposals() {

		Set<String> userList = new Set<String> ();
		for (Admin_Tool_Status_Summary__c ats : admToolSummaryIDs) {
			userList.add(ats.To_User_Id__c);
		}

		String query = 'Select id,Id__c , Status__c,Error_Message__c, Admin_Tool_Status_Summary__r.Proposal_End_Date__c, Admin_Tool_Status_Summary__r.To_User_ID__c, Admin_Tool_Status_Summary__r.From_User_ID__c ' +
		'from Admin_Tool_Status_Detail__c ' +
		'where Object_Type__c = \'Proposal\' and Status__c in(\'Not Started\',\'Error\') and Admin_Tool_Status_Summary__r.Id in: admToolSummaryIDs order by Tim_System__c';

		TransferProposalBatch tpb = new TransferProposalBatch(query, admToolSummaryIDs, mapOfBatchsizes, userList);
		tpb.isRetry = true;
		Database.executeBatch(tpb);

		return new PageReference('/' + atsId);
	}

	public pageReference retryOpportunities() {

		String query = 'Select id,Id__c , Status__c,Error_Message__c, Admin_Tool_Status_Summary__r.Proposal_End_Date__c, Admin_Tool_Status_Summary__r.To_User_ID__c, Admin_Tool_Status_Summary__r.From_User_ID__c ' +
		'from Admin_Tool_Status_Detail__c ' +
		'where Object_Type__c = \'Opportunity\' and Status__c in(\'Not Started\',\'Error\') and Admin_Tool_Status_Summary__r.Id in: admToolSummaryIDs';

		TransferOpportunityBatch tob = new TransferOpportunityBatch(query, admToolSummaryIDs, mapOfBatchsizes);
		tob.isRetry = true;
		Database.executeBatch(tob);

		return new PageReference('/' + atsId);
	}

	public pageReference retryRevenues() {

		String query = 'Select ID,Account_Transfer_Simulation__r.NCC__c ,Transfer_Details__c,Transfer_Details__r.Account__c, Transfer_Details__r.To_User__c, Transfer_Details__r.From_User__c,Transfer_Details__r.From_User__r.Id,Transfer_Details__r.To_User__r.Id,Transfer_Details__r.Account__r.Id from Admin_Tool_Status_Summary__c  where id in : admToolSummaryIDs';
		TransferRevenueBatch TRB = new TransferRevenueBatch(query, admToolSummaryIDs, mapOfBatchsizes);
		TRB.isRetry = true;
		Database.executeBatch(TRB);
		return new PageReference('/' + atsId);
	}

	public pageReference retrySalesBudget() {

		String query = 'Select ID,Transfer_Details__c,Transfer_Details__r.Account__c, Transfer_Details__r.To_User__c, Transfer_Details__r.From_User__c,Transfer_Details__r.From_User__r.Id,Transfer_Details__r.To_User__r.Id,Transfer_Details__r.Account__r.Id from Admin_Tool_Status_Summary__c  where id in :admToolSummaryIDs';
		TransferSalesBudgetBatch TSBB = new TransferSalesBudgetBatch(query, admToolSummaryIDs, mapOfBatchsizes);
		TSBB.isRetry = true;
		Database.executeBatch(TSBB);
		return new PageReference('/' + atsId);
	}

	public pageReference retryNewsBusiness() {


		Account_Transfer_Tool__c ATTRec = [Select id, Transfer_All_Accounts__c from Account_Transfer_Tool__c where id = :atsId];
		TransferNewsBusinessBatch TNBB = new TransferNewsBusinessBatch(atsId, ATTRec.Transfer_All_Accounts__c, admToolSummaryIDs, mapOfBatchsizes);
		TNBB.IsRetry = true;
		Database.executeBatch(TNBB);

		return new PageReference('/' + atsId);
	}

	public pageReference retryAccountConnection() {

		String query = 'Select id,Id__c , Status__c,Error_Message__c, Admin_Tool_Status_Summary__r.To_User_ID__c, Admin_Tool_Status_Summary__r.From_User_ID__c,AccountConnection__c,New_AE_Id_for_Account_Conn__c from Admin_Tool_Status_Detail__c where Object_Type__c = \'Account Connection\' and (Status__c=\'Not Started\' OR Status__c=\'Error\') and Admin_Tool_Status_Summary__r.Id in : admToolSummaryIDs';
		TransferAccountConnectionBatch TAC = new TransferAccountConnectionBatch(query, admToolSummaryIDs, mapOfBatchsizes);
		TAC.isRetry = true;
		Database.executeBatch(TAC);
		return new PageReference('/' + atsId);
	}

	public pageReference retryAccountTeam() {

		String query = 'Select id,Id__c , Status__c,Error_Message__c, Admin_Tool_Status_Summary__r.To_User_ID__c,AccountConnection__c, Admin_Tool_Status_Summary__r.From_User_ID__c from Admin_Tool_Status_Detail__c where Object_Type__c = \'Account Team\' and (Status__c=\'Not Started\' OR Status__c=\'Error\')  and Admin_Tool_Status_Summary__c in: admToolSummaryIDs';
		TransferAccountTeamBatch TAT = new TransferAccountTeamBatch(query, admToolSummaryIDs, mapOfBatchsizes);
		TAT.isRetry = true;
		Database.executeBatch(TAT);
		return new PageReference('/' + atsId);
	}
	public pageReference retrySAMDesignation() {

		string query = '';
		TransferSAMDesignationBatch transferAccSAM = new TransferSAMDesignationBatch(query, admToolSummaryIDs, mapOfBatchsizes);
		transferAccSAM.isRetry = true;
		Database.executeBatch(transferAccSAM);
		return new PageReference('/' + atsId);

	}


	public pageReference retryConatactTransfer() {

		
		TransferContactBatch transferCon = new TransferContactBatch(admToolSummaryIDs,atsId );
		transferCon.isRetry = true;
		Database.executeBatch(transferCon,250);
		return new PageReference('/' + atsId);

	}
}