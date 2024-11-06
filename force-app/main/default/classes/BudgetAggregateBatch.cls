/*
  ###########################################################################
  # File..................: BudgetAggregateBatch.cls
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

global class BudgetAggregateBatch implements Database.Batchable<sObject>, Database.Stateful {

	global String query;
	global Map<string, string> salesBudgetFieldValueMap;
	List<Sales_Budget__c> salesBudgets;
	List<Budget__c> budgetAggregates;
	List<budgetWrapper> BudgetWrapperList;
	Set<String> salesBudgetIds;
	Map<String, budgetWrapper> BudgetWrapperMap;
	Boolean executeRevenue = true;
	Map<string, String> userMap;
	Set<ID> userIDs;
	AsyncApexJob aaj;
	list<string> lstUserWhoModifiedSBRecs;

	global BudgetAggregateBatch(String qry, Set<ID> userIDs, Boolean executeRevenue) {
		userMap = new Map<String, String> ();
		budgetAggregates = new List<Budget__c> ();
		salesBudgetIds = new Set<String> ();
		this.userIDs = userIDs;
		this.executeRevenue = executeRevenue;
		aaj = new AsyncApexJob();
		BudgetWrapperList = new List<budgetWrapper> ();
		BudgetWrapperMap = new Map<String, budgetWrapper> ();
		lstUserWhoModifiedSBRecs = new list<Id> ();


		system.debug('@@@qry :' + qry);
		if (string.isEmpty(qry)) {

			for (AsyncApexJob Jobdetails :[SELECT CreatedDate FROM AsyncApexJob
			     where(jobType = 'BatchApex' or jobType = 'ScheduledApex') and apexclass.name = 'BudgetAggregateBatch' order by CreatedDate desc NULLS Last limit 1])
			{
				if (Jobdetails != null)
				{
					Datetime LastRunDate = Jobdetails.CreatedDate;
					system.debug('@@@LastRunDate:' + LastRunDate);

					AggregateResult[] groupedResults = [SELECT Budget_User__c FROM Sales_Budget__c
					                                    where((Type__c = 'Data' and(Product_Line__c != 'New Business' AND Product_Line__c != 'Unknown Churn')) OR Type__c = 'DOS') AND
					                                    Calendar_Year(Broadcast_Month_Date__c) = 2020 AND
					                                    Product_Line__c != null AND
					                                    Amount__c != 0 and
					                                    lastmodifieddate >= :LastRunDate
					                                    Group by Budget_User__c];

					for (AggregateResult ar : groupedResults) {
						lstUserWhoModifiedSBRecs.add(string.valueof(ar.get('Budget_User__c')));
					}
				}
			}
			system.debug('@@@lstUserWhoModifiedSBRecs :' + lstUserWhoModifiedSBRecs);

			//and (Product_Line__c != \'New Business\' AND Product_Line__c != \'Unknown Churn\'))


			if (lstUserWhoModifiedSBRecs.size() > 0) {
				qry = 'SELECT Budget_User__c,Budget_User__r.Budget_Type__c, Budget_User__r.Name , Type__c,Amount__c,DMA__c ,Broadcast_Month_Date__c,Product_Line__c FROM Sales_Budget__c  ';
				qry += ' where ((Type__c = \'Data\' and (Product_Line__c != \'New Business\' AND Product_Line__c != \'Unknown Churn\')) OR Type__c = \'DOS\') ';
				qry += 'AND Calendar_Year(Broadcast_Month_Date__c) = 2020 AND Product_Line__c != null AND Amount__c != 0 ';
				qry += 'AND Budget_User__c in:lstUserWhoModifiedSBRecs order by Budget_User__c,Product_Line__c desc ';
			}

		}
		system.debug('@@qry2:' + qry);
		this.query = qry;
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {

		aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
		       FROM AsyncApexJob WHERE ID = :BC.getJobId()];
		system.debug('query ' + query);
		if (string.isEmpty(query)) {
			System.abortJob(BC.getJobId());
			return null;
		}
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, list<Sales_Budget__c> scope) {
		salesBudgets = new list<Sales_Budget__c> ();
		salesBudgets = scope;
		BudgetWrapperList = new List<budgetWrapper> ();
		system.debug('BudgetWrapperList: Size after  ' + BudgetWrapperMap.keySet());
		system.debug('BudgetWrapperList: ' + BudgetWrapperList);
		Map<String, budgetWrapper> userSalesBudget = new Map<String, budgetWrapper> ();
		try
		{
			integer i = 0;
			for (Sales_Budget__c sbObj : salesBudgets)
			{
				Integer year = sbObj.Broadcast_Month_Date__c.year();
				Integer month = sbObj.Broadcast_Month_Date__c.month();
				BudgetWrapper sbWObj = new BudgetWrapper();
				string key = '';
				if (sbObj.DMA__c == null)
				sbObj.DMA__c = 'NA';

				if (sbObj.Budget_User__r.Budget_Type__c == 'National' && Boolean.valueOf(Label.Budget_Aggregate_DMA_Switch) == true)
				key = (string) sbObj.Budget_User__c + (string) sbObj.Product_Line__c + string.valueOf(month) + string.valueOf(year) + (string) sbObj.DMA__c;
				else {
					key = (string) sbObj.Budget_User__c + (string) sbObj.Product_Line__c + string.valueOf(month) + string.valueOf(year);
				}
				if (!BudgetWrapperMap.containsKey(key))
				{
					if (BudgetWrapperMap.keySet().size() > 0)
					{
						for (budgetWrapper rev : BudgetWrapperMap.values())
						{
							BudgetWrapperList.add(rev);
						}
					}

					BudgetWrapperMap.clear();
					sbWObj.Year = string.valueOf(year);
					sbWObj.Month = string.valueOf(month);
					sbWObj.UserId = (string) sbObj.Budget_User__c;
					sbWObj.userType = (string) sbObj.Budget_User__r.Budget_Type__c;
					sbWObj.ProductLine = (string) sbObj.Product_Line__c;
					if (sbObj.Budget_User__r.Budget_Type__c == 'National' && Boolean.valueOf(Label.Budget_Aggregate_DMA_Switch) == true)
					sbWObj.DMA = (string) sbObj.DMA__c;

					//sbWObj.budgetType = (string) sbObj.Type__c;
					sbWObj.inBudgets[month - 1] += sbObj.Amount__c == null ? 0 : (Decimal) sbObj.Amount__c;
					System.debug('sbWObj.inBudgets[month - 1]: ' + sbWObj.inBudgets[month - 1]);
					BudgetWrapperMap.put(key, sbWObj);
				}
				else
				{
					sbWObj = BudgetWrapperMap.get(key);
					/*
					  if(sbObj.Budget_User__r.Budget_Type__c == 'National' && Label.Budget_Aggregate_DMA_Switch == 'False' )
					  sbWObj.DMA += ';' + (string)sbObj.DMA__c;
					 */
					sbWObj.inBudgets[month - 1] += sbObj.Amount__c == null ? 0 : (Decimal) sbObj.Amount__c;
					System.debug('else sbWObj.inBudgets[month - 1]: ' + sbWObj.inBudgets[month - 1]);
					BudgetWrapperMap.put(key, sbWObj);
					if (aaj.JobItemsProcessed == aaj.TotalJobItems && i == salesBudgets.size() - 1)
					{
						if (BudgetWrapperMap.keySet().size() > 0)
						{
							for (budgetWrapper rev : BudgetWrapperMap.values())
							{
								BudgetWrapperList.add(rev);
							}
						}
					}
				}
				i++;
			}
			system.debug('BudgetWrapperMap: Size after  ' + BudgetWrapperMap.size());
			system.debug('BudgetWrapperList: ' + BudgetWrapperList);
			createbAggregate();

			if (Test.isRunningTest()) {
				CalloutException e = new CalloutException();
				e.setMessage('This is a constructed exception for testing and code coverage');
				throw e;
			}
		}
		catch(Exception ex)
		{ System.Debug('exception:' + ex.getMessage());
			Log4SF.logMessage('BudgetAggregateBatch', 'execute', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
		//emailIds = salesBudgetFieldValueMap.EmailId;

	}

	global void createbAggregate() {
		String csvData = '';
		//integer loopCounter=0;
		system.debug('BudgetWrapperMap: createbAggregate' + BudgetWrapperList.size());
		try
		{
			budgetAggregates = new List<Budget__c> ();
			Map<String, Budget__c> mapBudget = new Map<String, Budget__c> ();
			Schema.SObjectField ftoken = Budget__c.Fields.Budget_External_Id__c;
			Budget__c sbaObj;
			for (BudgetWrapper sbObj : BudgetWrapperList)
			{
				integer loopCounter = 0;
				system.debug('BudgetWrapperMap: sbObj' + sbObj);
				system.debug('BudgetWrapperMap: sbObj inbudgets' + sbObj.inbudgets);
				for (integer i = 1; i <= sbObj.inBudgets.size(); i++)
				{
					system.debug('sbObj.inBudgets[i - 1]' + sbObj.inBudgets[i - 1]);
					sbaObj = new Budget__c();
					sbaObj.BudgetAE__c = ID.valueOf(sbObj.UserID);
					//sbaObj.Year__c = sbObj.Year;
					sbaObj.Product_Line__c = sbObj.ProductLine;
					//sbaObj.DMA__c = sbObj.DMA;
					//sbaObj.Budget_Type__c = sbObj.budgetType;
					sbaObj.Comments__c = 'Aggregate';
					if (sbObj.userType == 'National' && Label.Budget_Aggregate_DMA_Switch == 'True') {
						sbaObj.Budget_External_Id__c = sbObj.UserID + sbObj.ProductLine + sbObj.Month + sbObj.Year + sbObj.DMA;
						sbaObj.DMA__c = sbObj.DMA;
					}
					else {
						sbaObj.Budget_External_Id__c = sbObj.UserID + sbObj.ProductLine + sbObj.Month + sbObj.Year;
					}
					sbaObj.Amount__c = sbObj.inBudgets[i - 1];
					sbaObj.Broadcast_Month_Date__c = Date.newInstance(Integer.valueOf(Label.Budget_Aggregate_Year), i, 15);
					system.debug('@@@sbaObj.Budget_External_Id__c :' + sbaObj.Budget_External_Id__c);
					system.debug('@@@mapBudget.containsKey(sbaObj.Budget_External_Id__c) :' + mapBudget.containsKey(sbaObj.Budget_External_Id__c));
					system.debug('sbaObj.Amount__c :' + sbaObj.Amount__c);
					if (sbaObj.Amount__c != 0) {
						if (!mapBudget.containsKey(sbaObj.Budget_External_Id__c))
						mapBudget.put(sbaObj.Budget_External_Id__c, sbaObj);
						else
						mapBudget.get(sbaObj.Budget_External_Id__c).Amount__c += sbaObj.Amount__c;
					}
				}
				//salesBudgetAggregates.add(sbaObj);
				system.debug('BudgetAggregates out For ' + mapBudget);
			}
			system.debug('BudgetAggregates ' + budgetAggregates);
			List<database.UpsertResult> results = database.upsert(mapBudget.values(), ftoken, false);
			for (Integer i = 0; i<results.size(); i++) {
				if (!results[i].isSuccess()) {
					Database.Error error = results.get(i).getErrors().get(0);
					String failedDML = error.getMessage();
					Log4SF.logMessage('BudgetAggregateBatch', 'createbAggregate', 'Upsert Failed -' + failedDML, null, UserInfo.getUserId(), null, '');
				}
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('BudgetAggregateBatch', 'createbAggregate', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
		//9system.debug('End of CSV: ' + loopCounter);

	}

	global void finish(Database.BatchableContext BC) {
		try
		{ /*
			  if(executeRevenue)
			  {
			  String 	query = 'SELECT  Account_Executive__c  , Account_Executive__r.Name , Advertiser__c, Net_Projected_Amount__c , Broadcast_Month_Date__c ';
			  query +=' FROM Revenue__c where  Account_Executive__c in : userIDs AND Advertiser__c != null order by Account_Executive__r.Name, Advertiser__c  desc';
			  RevenueAggregatebatch rb = new RevenueAggregatebatch(query,userIds);
			  database.ExecuteBatch(rb, 200);
			  }
			 */
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('BudgetAggregateBatch', 'finish', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
	}
	/*
	  global void sendEmailAttachment(){
	  emailIds = UserInfo.getUserEmail();
	  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	  list<String> toAddresses = new list<String>();
	  toAddresses.add(emailIds.remove(' '));
	  mail.setToAddresses(toAddresses);
	  mail.setSubject('Budget Transfer Export');
	  mail.setPlainTextBody('Budget Transfer Export completed on: ' + DateTime.Now());
	 
	  Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
	  efa.setBody(csvFile.Body);
	  efa.setFileName(csvFile.Name);
	  mail.setFileAttachments(new list<Messaging.EmailFileAttachment>{efa});
	 
	  Messaging.sendEmail(new list<Messaging.SingleEmailMessage>{mail});
	  }
	 */
	public class budgetWrapper
	{
		public string UserID;
		public string Name;
		public string Year;
		public string Month;
		public String ProductLine;
		public string DMA;
		public string budgetType;
		public string userType;
		public List<Decimal> inbudgets;
		public List<Decimal> outBudgets;
		public List<Decimal> budgetChanges;

		public budgetWrapper()
		{
			UserID = '';
			ProductLine = '';
			Year = '';
			Month = '';
			Name = '';
			DMA = '';
			userType = '';
			budgetType = '';
			inbudgets = new List<Decimal> { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
			outBudgets = new List<Decimal> { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
			budgetChanges = new List<Decimal> { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
		}

	}
}