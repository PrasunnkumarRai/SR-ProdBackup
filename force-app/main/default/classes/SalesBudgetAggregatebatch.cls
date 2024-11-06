/*
  ###########################################################################
  # File..................: SalesBudgetAggregatebatch.cls
  # Version...............: 1
  # Created by............: Matthew Kidman
  # Created Date..........: 5-Mar-2019
  # Last Modified by......:
  # Last Modified Date....:
  # Description...........: This class is used to Extract the Change in Budget data due to transfers.
  # TAO Ref#..............: NA
  # Test Class............: 
  # Change Log............:
  #
  #
  ############################################################################*/

global class SalesBudgetAggregatebatch implements Database.Batchable<sObject>, Database.Stateful {

	global String query;
	global Map<string, string> salesBudgetFieldValueMap;
	List<Sales_Budget__c> salesBudgets;
	List<Sales_Budget_Aggregate__c> salesBudgetAggregates;
	List<salesbudgetWrapper> salesBudgetWrapperList;
	Set<String> salesBudgetIds;
	Map<String, salesbudgetWrapper> salesBudgetWrapperMap;
	Boolean executeRevenue = true;
	Map<string, String> userMap;
	Set<ID> userIDs;
	public Boolean sendEmail = false;
	AsyncApexJob aaj;

	global SalesBudgetAggregatebatch(String qry, Set<ID> userIDs, Boolean executeRevenue) {
		userMap = new Map<String, String> ();
		salesBudgetAggregates = new List<Sales_Budget_Aggregate__c> ();
		salesBudgetIds = new Set<String> ();
		this.userIDs = userIDs;
		this.executeRevenue = executeRevenue;
		aaj = new AsyncApexJob();
		salesBudgetWrapperList = new List<salesbudgetWrapper> ();
		salesBudgetWrapperMap = new Map<String, salesbudgetWrapper> ();
		if (string.isEmpty(qry))
		{
			qry = 'SELECT Budget_User__c, Budget_User__r.Name , Advertiser__c,Amount__c , Broadcast_Month_Date__c FROM Sales_Budget__c ';
			qry += ' where (Type__c = \'Data\' and (Product_Line__c != \'New Business\' AND Product_Line__c != \'Unknown Churn\')) AND Calendar_Year(Broadcast_Month_Date__c) >= 2019';
			qry += ' AND Advertiser__c != null AND Amount__c > 0 order by Budget_User__r.Name,Advertiser__c desc ';
		}
		this.query = qry;
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		if(userIds != null && userIds.size() > 0)
		{
			List<Sales_Budget_Aggregate__c> Ids = [Select Id from Sales_Budget_Aggregate__c where  Account_Executive__c in: userIDs limit 5000];
			delete Ids;
			if(Ids.size()>0)
			Database.emptyRecycleBin(Ids);

		
		//Batch cannot be called from the start of another batch.
		//EmptyRecycleBinBasedOnIdsbatch emp = new EmptyRecycleBinBasedOnIdsbatch('Select Id from Sales_Budget_Aggregate__c where Account_Executive__c in: userIDs',UserIds);
		//database.ExecuteBatch(emp, 200);	
		}
		aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
		       FROM AsyncApexJob WHERE ID = :BC.getJobId()];
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, list<Sales_Budget__c> scope) {

		createSBWrapper(scope);
		//emailIds = salesBudgetFieldValueMap.EmailId;

	}
	global void createSBWrapper(List<Sales_Budget__c> sbList)
	{
		salesBudgets = new list<Sales_Budget__c> ();
		salesBudgets = sbList;
		salesBudgetWrapperList = new List<salesbudgetWrapper> ();
		system.debug('salesBudgetWrapperList: Size after  ' + salesBudgetWrapperMap.keySet());
		system.debug('salesBudgetWrapperList: ' + salesBudgetWrapperList);
		Map<String, salesbudgetWrapper> userSalesBudget = new Map<String, salesbudgetWrapper> ();
		try
		{
			integer i = 0;
			for (Sales_Budget__c sbObj : salesBudgets)
			{
				Integer year = sbObj.Broadcast_Month_Date__c.year();
				Integer month = sbObj.Broadcast_Month_Date__c.month();
				system.debug('month: ' + month);
				system.debug('year: ' + year);
				salesBudgetWrapper sbWObj = new salesBudgetWrapper();

				if (!salesBudgetWrapperMap.containsKey((string) sbObj.Budget_User__c + '-' + (string) sbObj.Advertiser__c + '-' + string.valueOf(year)))
				{
					if (salesBudgetWrapperMap.keySet().size() > 0)
					{
						for (salesbudgetWrapper rev : salesBudgetWrapperMap.values())
						{
							salesBudgetWrapperList.add(rev);
						}
					}

					salesBudgetWrapperMap.clear();
					sbWObj.Year = string.valueOf(year);
					sbWObj.UserId = (string) sbObj.Budget_User__c;
					sbWObj.Advertiser = (string) sbObj.Advertiser__c;
					sbWObj.inBudgets[month - 1] += sbObj.Amount__c == null ? 0 : (Decimal) sbObj.Amount__c;
                    if(salesBudgets.size() ==  1)
                    {
                        salesBudgetWrapperList.add(sbwObj);
                    }
                    else
					salesBudgetWrapperMap.put((string) sbObj.Budget_User__c + '-' + (string) sbObj.Advertiser__c + '-' + string.valueOf(year), sbWObj);
				}
				else
				{
					sbWObj = salesBudgetWrapperMap.get((string) sbObj.Budget_User__c + '-' + (string) sbObj.Advertiser__c + '-' + string.valueOf(year));
					sbWObj.inBudgets[month - 1] += sbObj.Amount__c == null ? 0 : (Decimal) sbObj.Amount__c;
					salesBudgetWrapperMap.put((string) sbObj.Budget_User__c + '-' + (string) sbObj.Advertiser__c + '-' + string.valueOf(year), sbWObj);
                    System.debug('aaj ' +aaj.JobItemsProcessed);
					if (aaj.JobItemsProcessed != null && aaj.JobItemsProcessed == aaj.TotalJobItems && i == salesBudgets.size() - 1)
					{
						if (salesBudgetWrapperMap.keySet().size() > 0)
						{
							for (salesbudgetWrapper rev : salesBudgetWrapperMap.values())
							{
								salesBudgetWrapperList.add(rev);
							}
						}
					}
					else if(aaj.JobItemsProcessed == null && i == salesBudgets.size() - 1){
						if (salesBudgetWrapperMap.keySet().size() > 0)
							{
								for (salesbudgetWrapper rev : salesBudgetWrapperMap.values())
								{
									salesBudgetWrapperList.add(rev);
								}
							}
						}
				}
				i++;
			}
			system.debug('salesBudgetWrapperMap: Size after  ' + salesBudgetWrapperMap.size());
			system.debug('salesBudgetWrapperList: ' + salesBudgetWrapperList);
			createSbAggregate();

			if (Test.isRunningTest()) {
				CalloutException e = new CalloutException();
				e.setMessage('This is a constructed exception for testing and code coverage');
				throw e;
			}
		}
		catch(Exception ex)
		{ System.Debug('exception:' + ex.getMessage());
			Log4SF.logMessage('SalesBudgetCSVBatch', 'execute', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
	
	}

	global void createSbAggregate() {
		String csvData = '';
		//integer loopCounter=0;
		system.debug('salesBudgetWrapperMap: createSbAggregate' + salesBudgetWrapperList.size());
		try
		{
			salesBudgetAggregates = new List<Sales_Budget_Aggregate__c> ();
			Schema.SObjectField ftoken = Sales_Budget_Aggregate__c.Fields.External_Id__c;
			Sales_Budget_Aggregate__c sbaObj;
			for (salesBudgetWrapper sbObj : salesBudgetWrapperList)
			{
				integer loopCounter = 0;
				sbaObj = new Sales_Budget_Aggregate__c();
				sbaObj.Account_Executive__c = ID.valueOf(sbObj.UserID);
				sbaObj.Broadcast_Year__c = sbObj.Year;
				sbaObj.SalesBudget_Advertiser__c = ID.valueOf(sbObj.Advertiser);
				sbaObj.External_Id__c = sbObj.UserID + sbObj.Advertiser + sbObj.Year;
				for (integer i = 1; i <= sbObj.inBudgets.size(); i++)
				{
					if (i == 1) {
						sbaObj.January_Budget__c = sbObj.inBudgets[i - 1];
					}
					if (i == 2) {
						sbaObj.February_Budget__c = sbObj.inBudgets[i - 1];
					}
					if (i == 3) {
						sbaObj.March_Budget__c = sbObj.inBudgets[i - 1];
					}
					if (i == 4) {
						sbaObj.April_Budget__c = sbObj.inBudgets[i - 1];
					}
					if (i == 5) {
						sbaObj.May_Budget__c = sbObj.inBudgets[i - 1];
					}
					if (i == 6) {
						sbaObj.June_Budget__c = sbObj.inBudgets[i - 1];
					}
					if (i == 7) {
						sbaObj.July_Budget__c = sbObj.inBudgets[i - 1];
					}
					if (i == 8) {
						sbaObj.August_Budget__c = sbObj.inBudgets[i - 1];
					}
					if (i == 9) {
						sbaObj.September_Budget__c = sbObj.inBudgets[i - 1];
					}
					if (i == 10) {
						sbaObj.October_Budget__c = sbObj.inBudgets[i - 1];
					}
					if (i == 11) {
						sbaObj.November_Budget__c = sbObj.inBudgets[i - 1];
					}
					if (i == 12) {
						sbaObj.December_Budget__c = sbObj.inBudgets[i - 1];
					}
				}
				salesBudgetAggregates.add(sbaObj);
			}
			system.debug('salesBudgetAggregates ' + salesBudgetAggregates);
			database.upsert(salesBudgetAggregates, ftoken, false);
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('SalesBudgetCSVBatch', 'createSbAggregate', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
		//9system.debug('End of CSV: ' + loopCounter);

	}

	/*
	  public Sales_Budget__c populateSalesBudgetTransferData(Sales_Budget__c sbObj ){
	  sbObj.Division = salesBudgetFieldValueMap.Division');
	  sbObj.Title = salesBudgetFieldValueMap.get('Title');
	  sbObj.PSID = salesBudgetFieldValueMap.get('PSID');
	  sbObj.Name = salesBudgetFieldValueMap.get('Name');
	  sbObj.Rev Type = salesBudgetFieldValueMap.get('Rev Type');
	  sbObj.January = salesBudgetFieldValueMap.get('January');
	  sbObj.February = salesBudgetFieldValueMap.get('February');
	  sbObj.March = salesBudgetFieldValueMap.get('March');
	  sbObj.April = salesBudgetFieldValueMap.get('April');
	  sbObj.May = salesBudgetFieldValueMap.get('May');
	  sbObj.June = salesBudgetFieldValueMap.get('June');
	  sbObj.July = salesBudgetFieldValueMap.get('July');
	  sbObj.August = salesBudgetFieldValueMap.get('August');
	  sbObj.September = salesBudgetFieldValueMap.get('September');
	  sbObj.October = salesBudgetFieldValueMap.get('October');
	  sbObj.November = salesBudgetFieldValueMap.get('November');
	  sbObj.December = salesBudgetFieldValueMap.get('December');
	  sbObj.Full Year = salesBudgetFieldValueMap.get('Full Year');
	  return sbObj;
	  }
	 */
	global void finish(Database.BatchableContext BC) {
		try
		{
			if (executeRevenue)
			{
				String query = 'SELECT  Account_Executive__c  , Account_Executive__r.Name , Advertiser__c, Net_Projected_Amount__c , Broadcast_Month_Date__c ';
				query += ' FROM Revenue__c where  Account_Executive__c in : userIDs AND Advertiser__c != null order by Account_Executive__r.Name, Advertiser__c  desc';
				RevenueAggregatebatch rb = new RevenueAggregatebatch(query, userIds);
				database.ExecuteBatch(rb, 200);
			}
			if(sendEmail)
			{
				sendEmailOnComplete();
			}
			/*
			if (userIds != null && userIds.size() > 0)
			{
				EmptyRecycleBinBasedOnIdsbatch emp = new EmptyRecycleBinBasedOnIdsbatch('Select Id from Sales_Budget_Aggregate__c where Account_Executive__c in: userIDs', userIds);
				database.ExecuteBatch(emp, 2000);
			}
			*/
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('SalesBudgetCSVBatch', 'finish', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
	}

	  global void sendEmailOnComplete()
	  {
		  string emailIds = UserInfo.getUserEmail();
		  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		  list<String> toAddresses = new list<String>();
		  toAddresses.add(emailIds.remove(' '));
		  mail.setToAddresses(toAddresses);
		  mail.setSubject('Sales Budget Refresh has Completed.');
		  mail.setPlainTextBody('Sales Budget Refresh has Completed for ' + userIds);
	 
		  Messaging.sendEmail(new list<Messaging.SingleEmailMessage>{mail});
	  }

	public class salesbudgetWrapper
	{
		public string UserID;
		public string Name;
		public string Year;
		public String Advertiser;
		public List<Decimal> inbudgets;
		public List<Decimal> outBudgets;
		public List<Decimal> budgetChanges;

		public salesbudgetWrapper()
		{
			UserID = '';
			Advertiser = '';
			Year = '';
			Name = '';
			inbudgets = new List<Decimal> { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
			outBudgets = new List<Decimal> { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
			budgetChanges = new List<Decimal> { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
		}

	}
}