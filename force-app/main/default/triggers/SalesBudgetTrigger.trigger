trigger SalesBudgetTrigger on Sales_Budget__c(before update, after update, after insert, before insert) {

	List<Sales_Budget__c> sbList = new List<Sales_Budget__c> ();
	List<String> cList = new List<String> ();
	List<String> uList = new List<String> ();
	Set<ID> budUser = new Set<ID> ();
	Set<ID> oldBudUser = new Set<ID> ();
	List<Sales_Budget__c> sbList4Simulation = new List<Sales_Budget__c> ();
	Set<Id> sbListToDelete = new Set<Id> ();
	if (Trigger.isAfter)
	{
		for (Sales_Budget__c sb : Trigger.new) {
			if (sb.Amount__c == 0 && (sb.Type__c == 'DOS' || sb.Type__c == 'Data')) {
				sbListToDelete.add(sb.Id);
			}

			//Populate Revenue Information field for Data and Forecast rows
			if (BudgetingToolController.triggerFirstRun == false) {
				if (String.isBlank(sb.revenue_information__c) && (sb.Type__c == 'Data' || sb.Type__c == 'Forecast')) {
					sbList.add(sb);
					cList.add(sb.Commodity__c);
					uList.add(sb.budget_user__c);
				}
			}

			// Logic to create logs for each update and insert on Sales Budget.
			if (Trigger.isUpdate)
			{
				if ((sb.Amount__c != Trigger.oldMap.get(sb.Id).Amount__c || sb.Budget_User__c != Trigger.oldMap.get(sb.Id).Budget_User__c || sb.Old_Budget_User__c != Trigger.oldMap.get(sb.Id).Old_Budget_User__c) && ((sb.Type__c == 'Data' && (sb.Product_Line__c != 'New Business' && sb.Product_Line__c != 'Unknown Churn')) || sb.Type__c == 'DOS'))
				{
					sbList4Simulation.add(sb);
					//Populate user list for SB Aggregate batch
					if (sb.Type__c != 'DOS')
					budUser.add(sb.budget_user__c);

				}
				//Populate LEX if data Source is Blank in SalesBudget
				//if (String.isBlank(sb.Data_Source__c)) {
				//sb.Data_Source__c = 'LEX';
				//}
			}
			else if (Trigger.isInsert && sb.Old_Budget_User__c != null && ((sb.Type__c == 'Data' && (sb.Product_Line__c != 'New Business' && sb.Product_Line__c != 'Unknown Churn')) || sb.Type__c == 'DOS'))
			{
				//sb.transfer_date__c = System.Date.today();
				sbList4Simulation.add(sb);
				//Populate user list for SB Aggregate batch
				if (sb.Type__c != 'DOS')
				budUser.add(sb.budget_user__c);
			}
		}

		BudgetingToolController.triggerFirstRun = true;
		System.debug(sbList);
		System.debug(BudgetingToolController.triggerFirstRun);
		if (sbList.size() > 0 && !System.IsFuture() && !System.isBatch()) {
			BudgetingToolController.saveBudgetRevenue(JSON.serialize(sbList), JSON.serialize(cList), JSON.serialize(uList));
		}
	}
	if (Trigger.isBefore && Trigger.isUpdate)
	{
		for (Sales_Budget__c sb : Trigger.new) {
			if (sb.Amount__c != Trigger.oldMap.get(sb.Id).Amount__c || sb.Budget_User__c != Trigger.oldMap.get(sb.Id).Budget_User__c || sb.Old_Budget_User__c != Trigger.oldMap.get(sb.Id).Old_Budget_User__c)
			{
				sb.transfer_date__c = System.Date.today();
				if (sb.Budget_User__c != Trigger.oldMap.get(sb.Id).Budget_User__c)
				sb.Old_Budget_User__c = Trigger.oldMap.get(sb.Id).Budget_User__c;
			}

		}
	}
	if (Trigger.isBefore && Trigger.isInsert)
	{
		for (Sales_Budget__c sb : Trigger.new)
		{
			if (String.isBlank(sb.DMA__c) && sb.Type__c == 'DOS' && sb.Broadcast_Month_Date__c.year() == 2022)
			{
				sb.DMA__c = sb.Budget_User__r.Budget_DMA__c;
			}
			//Populate LEX if data Source is Blank in SalesBudget
			//if (String.isBlank(sb.Data_Source__c)) {
			//sb.Data_Source__c = 'LEX';
			//}
			

		}
		System.debug('In before Insert');
			SalesBudgetTriggerHelper sbObj = new SalesBudgetTriggerHelper();
			sbObj.isAfterInsert(Trigger.new, Trigger.newMap);
	}
	// Create Logs for Sales Budget updates
	if (sbList4Simulation.size() > 0)
	{
		New_AETransferToolController.createSalesBudgetSimulation(sbList4Simulation);

	}

	if (sbListToDelete.size() > 0) {
		delete[select id from Sales_Budget__c where id in : sbListToDelete AND IsDeleted = false];
	}
	//Call SB Aggregate Batch for updates to the Sales budget.
	// Set<ID> userIds = New_AETransferToolController.returnSalesBudget(adminToolSummary);
	if (Boolean.valueOf(Label.Sales_Budget_Aggregate_Batch_Switch) && budUser.size() > 0 && !System.IsFuture() && !System.isBatch())
	{
		String budUserID = '';
		for (ID usrID : budUser)
		{
			budUserID += usrID + ';';
		}
		AdminUtility.initiateSBAggregate(budUserID);
	}

}