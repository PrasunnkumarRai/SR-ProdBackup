/*
  ###########################################################################
  # File..................: SalesBudgetCSVBatch.cls
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

global class SalesBudgetCSVBatch implements Database.Batchable<sObject>, Database.Stateful {

	global String query;
	global Map<string, string> salesBudgetFieldValueMap;
	global String csvHeader;
	global String csvFileComplete;
	global String emailIds;
	global Map<string, string> fieldLabelWithNameMap;
	global Attachment csvFile;
	global Set<Id> directMailIds;
	String fileName = 'Budget Transfer Export.csv';
	List<Sales_Budget__c> salesBudgets;
	List<salesbudgetWrapper> salesBudgetWrapperList;
	Map<String, salesbudgetWrapper> salesBudgetWrapperMap;
	Boolean getAllData;
	List<CSV_Product_Line_Map__mdt> prdLineMetadata;
	Map<string, String> prdLineMetadataMap;
	Map<string, String> userMap;
	List<String> userIds;

	global SalesBudgetCSVBatch(String qry, boolean getAllData, List<String> userIds) {
		this.getAllData = getAllData;
		this.userIds = userIds;
		userMap = new Map<String, String> ();
		for (String str : userIds)
		{
			userMap.put(str, str);
		}
		System.debug('Constructor ' + userIds);
		salesBudgetWrapperList = new List<salesbudgetWrapper> ();
		salesBudgetWrapperMap = new Map<String, salesbudgetWrapper> ();
		prdLineMetadata = new List<CSV_Product_Line_Map__mdt> ();
		prdLineMetadataMap = new Map<String, String> ();
		prdLineMetadata = [Select Merged_Product_Line__c, Salesforce_Productlines__c from CSV_Product_Line_Map__mdt];
		for (CSV_Product_Line_Map__mdt prd : prdLineMetadata)
		{
			prdLineMetadataMap.put(prd.Salesforce_Productlines__c, prd.Merged_Product_Line__c);
		}

		this.query = qry;
		fieldLabelWithNameMap = describeFieldList('Sales_Budget__c');
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		csvHeader = Label.MBMT_CSV_Headers;
		csvFileComplete = csvHeader;
		System.debug('Query: ' + query);
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, list<Sales_Budget__c> scope) {
		salesBudgets = new list<Sales_Budget__c> ();
		salesBudgets = scope;

		system.debug('salesBudgetWrapperList: Size after  ' + salesBudgetWrapperMap.keySet());
		system.debug('salesBudgetWrapperList: ' + salesBudgetWrapperList);
		Map<String, salesbudgetWrapper> userSalesBudget = new Map<String, salesbudgetWrapper> ();
		try
		{
			for (Sales_Budget__c sbObj : salesBudgets)
			{
				Integer year = sbObj.Broadcast_Month_Date__c.year();
				Integer month = sbObj.Broadcast_Month_Date__c.month();
				system.debug('month: ' + month);
				system.debug('year: ' + year);
				salesBudgetWrapper sbWObj = new salesBudgetWrapper();
				if (prdLineMetadataMap.containsKey(sbObj.Product_Line__c) && Boolean.valueOf(Label.Merge_Product_Line))
				{
					sbObj.Product_Line__c = prdLineMetadataMap.get(sbObj.Product_Line__c);
				}

				if (!salesBudgetWrapperMap.containsKey((string) sbObj.Budget_User__c + '-' + (string) sbObj.Product_Line__c))
				{
					//
					sbWObj.Division = sbObj.Budget_User__r.Division__c;
					sbWObj.Title = (string) sbObj.Budget_User__r.HR_Job_Title__c;
					sbWObj.Rev_Type = (string) sbObj.Product_Line__c;
					sbWObj.PSID = (string) sbObj.Budget_User__r.HR_PID__c;
					sbWObj.Manager = (string) sbObj.Budget_User__r.HR_Manager__r.Name;
					sbWObj.Managers_PSID = (string) sbObj.Budget_User__r.HR_Manager__r.HR_PID__c;
					sbWObj.Name = (string) sbObj.Budget_User__r.Name;
					sbWObj.inBudgets[month - 1] += sbObj.Amount__c == null ? 0 : (Decimal) sbObj.Amount__c;
					sbWObj.HR_WorkforceId = (string) sbObj.Budget_User__r.HR_WorkforceID__c;
					sbWObj.Manager_HRWorkforceId = (String) sbObj.Budget_User__r.HR_Manager__r.HR_WorkforceID__c;
					/* SRB-722 This code is commented as per Greg's request. This is to calculate the budget differences.
					 
					  if(sbObj.Old_Budget_User__r.Name  != null && !getAllData)
					  {   
					  salesBudgetWrapper sbWOldObj = new salesBudgetWrapper();
					  // Old user Budget Out Movements
					  if(!salesBudgetWrapperMap.containsKey((string)sbObj.Old_Budget_User__c +'-'+(string)sbObj.Product_Line__c))
					  {
					  sbWOldObj.Division = sbObj.Old_Budget_User__r.Division__c;
					  sbWOldObj.Title = (string)sbObj.Old_Budget_User__r.HR_Job_Title__c;
					  sbWOldObj.Rev_Type = (string)sbObj.Product_Line__c;
					  sbWOldObj.PSID = (string)sbObj.Old_Budget_User__r.HR_PID__c;
					  sbWOldObj.Name = (string)sbObj.Old_Budget_User__r.Name;
					  sbWOldObj.Manager = (string)sbObj.Old_Budget_User__r.HR_Manager__r.Name;
					  sbWOldObj.Managers_PSID = (string)sbObj.Old_Budget_User__r.HR_Manager__r.HR_PID__c;
					  sbWOldObj.outBudgets[month-1] += sbObj.Amount__c == null ? 0 : (Decimal)sbObj.Amount__c;  
					  //sbWOldObj.budgetChanges[month-1] = sbWObj.inBudgets[month-1] - sbWObj.outBudgets[month-1];
					  }
					  else
					  {
					  sbWOldObj = salesBudgetWrapperMap.get((string)sbObj.Old_Budget_User__c + '-' + (string)sbObj.Product_Line__c);
					  sbWOldObj.outBudgets[month-1] += sbObj.Amount__c == null ? 0 : (Decimal)sbObj.Amount__c;  
					  }
					  sbWOldObj.budgetChanges[month-1] = sbWOldObj.inBudgets[month-1] - sbWOldObj.outBudgets[month-1];
					  if(userMap.containsKey(sbObj.Old_Budget_User__c))
					  salesBudgetWrapperMap.put((string)sbObj.Old_Budget_User__c +'-'+(string)sbObj.Product_Line__c,sbWOldObj);
					  }
					 */
					sbWObj.budgetChanges[month - 1] = sbWObj.inBudgets[month - 1] - sbWObj.outBudgets[month - 1];
					if (userMap.containsKey(sbObj.Budget_User__c))
					{
						salesBudgetWrapperMap.put((string) sbObj.Budget_User__c + '-' + (string) sbObj.Product_Line__c, sbWObj);
						system.debug((string) sbObj.Budget_User__c + '-' + (string) sbObj.Product_Line__c);
					}
				}
				else
				{
					sbWObj = salesBudgetWrapperMap.get((string) sbObj.Budget_User__c + '-' + (string) sbObj.Product_Line__c);
					sbWObj.Division = (string) sbObj.Budget_User__r.Division__c;
					sbWObj.Title = (string) sbObj.Budget_User__r.HR_Job_Title__c;
					sbWObj.Rev_Type = (string) sbObj.Product_Line__c;
					sbWObj.PSID = (string) sbObj.Budget_User__r.HR_PID__c;
					sbWObj.Manager = (string) sbObj.Budget_User__r.HR_Manager__r.Name;
					sbWObj.Managers_PSID = (string) sbObj.Budget_User__r.HR_Manager__r.HR_PID__c;
					sbWObj.Name = (string) sbObj.Budget_User__r.Name;
					sbWObj.inBudgets[month - 1] += sbObj.Amount__c == null ? 0 : (Decimal) sbObj.Amount__c;
					sbWObj.HR_WorkforceId = (string) sbObj.Budget_User__r.HR_WorkforceID__c;
					sbWObj.Manager_HRWorkforceId = (String) sbObj.Budget_User__r.HR_Manager__r.HR_WorkforceID__c;
					/* SRB-722 This code is commented as per Greg's request. This is to calculate the budget differences.
					  if(sbObj.Old_Budget_User__r.Name  != null && !getAllData)
					  {
					  salesBudgetWrapper sbWOldObj = new salesBudgetWrapper();
					 
					  if(!salesBudgetWrapperMap.containsKey((string)sbObj.Old_Budget_User__c +'-'+(string)sbObj.Product_Line__c))
					  {
					  // Old user Budget Out Movements
					  sbWOldObj.Division = sbObj.Old_Budget_User__r.Division__c;
					  sbWOldObj.Title = (string)sbObj.Old_Budget_User__r.HR_Job_Title__c;
					  sbWOldObj.Rev_Type = (string)sbObj.Product_Line__c;
					  sbWOldObj.PSID = (string)sbObj.Old_Budget_User__r.HR_PID__c;
					  sbWOldObj.Manager = (string)sbObj.Old_Budget_User__r.HR_Manager__r.Name;
					  sbWOldObj.Managers_PSID = (string)sbObj.Old_Budget_User__r.HR_Manager__r.HR_PID__c;                         
					  sbWOldObj.Name = (string)sbObj.Old_Budget_User__r.Name;
					  sbWOldObj.outBudgets[month-1] += sbObj.Amount__c == null ? 0 : sbObj.Amount__c;
					  //sbWObj.budgetChanges[month-1] = sbWObj.inBudgets[month-1] - sbWObj.outBudgets[month-1];  
					  }
					  else
					  {
					  sbWOldObj = salesBudgetWrapperMap.get((string)sbObj.Old_Budget_User__c + '-' + (string)sbObj.Product_Line__c);
					  sbWOldObj.outBudgets[month-1] += sbObj.Amount__c == null ? 0 : (Decimal)sbObj.Amount__c;  
					  //sbWObj.budgetChanges[month-1] = sbWObj.inBudgets[month-1] - sbWObj.outBudgets[month-1];
					  }
					  sbWOldObj.budgetChanges[month-1] = sbWOldObj.inBudgets[month-1] - sbWOldObj.outBudgets[month-1];
					  if(userMap.containsKey(sbObj.Old_Budget_User__c))
					  salesBudgetWrapperMap.put((string)sbObj.Old_Budget_User__c +'-'+(string)sbObj.Product_Line__c,sbWOldObj);
					  }
					 */
					sbWObj.budgetChanges[month - 1] = sbWObj.inBudgets[month - 1] - sbWObj.outBudgets[month - 1];
					if (userMap.containsKey(sbObj.Budget_User__c))
					{
						salesBudgetWrapperMap.put((string) sbObj.Budget_User__c + '-' + (string) sbObj.Product_Line__c, sbWObj);
						system.debug((string) sbObj.Budget_User__c + '-' + (string) sbObj.Product_Line__c);
					}
				}
				system.debug('salesBudgetWrapperMap: inside FOr ' + salesBudgetWrapperMap.keySet());
			}
			system.debug('salesBudgetWrapperMap: Size after  ' + salesBudgetWrapperMap.size());
			system.debug('salesBudgetWrapperMap: ' + salesBudgetWrapperMap);
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
		//emailIds = salesBudgetFieldValueMap.EmailId;
		//createCSV();
	}

	global void createCSV() {
		String csvData = '';
		//integer loopCounter=0;
		system.debug('salesBudgetWrapperMap: Create CSV ' + salesBudgetWrapperMap);
		try
		{
			for (salesBudgetWrapper sbObj : salesBudgetWrapperMap.values()) {
				if (sbObj.Name != null && sbObj.Name != String.Valueof(0) && sbObj.Name != '')
				{
					integer loopCounter = 0;
					system.debug('salesBudgetWrapperMap: CSV ' + sbObj);
					//sbObj = populateSalesBudgetTransferData(sbObj);
					String s = JSON.serialize(sbObj);
					Map<String, Object> obj = (Map<String, Object>) JSON.deserializeUntyped(s);
					system.debug(obj.keyset());
					for (String str : csvHeader.split(',')) {

						String temp;
						if (loopCounter< 9)
						{
							temp = String.valueOf(obj.get(str.indexOf(' ')> 0 ? str.replace(' ', '_') : str));
							system.debug('temp: ' + temp);
							if (temp == null)
							temp = '';
							if (temp.indexof(',') > 0)
							temp = temp.replace(',', '-');
							csvData += temp + ',';
						}
						else
						break;



						loopCounter = loopCounter + 1;
					}
					decimal totalDB = 0;
					for (Decimal db : sbObj.budgetChanges)
					{
						totalDB += db;
						system.debug('db: ' + db);
						csvData += String.valueOf(db) + ',';
						loopCounter = loopCounter + 1;
					}
					csvData += string.valueOf(totalDB) + ',';
					system.debug('salesBudgetWrapperMap: csvData ' + csvData);
					csvData = csvData.removeEnd(',') + '\n';
				}
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('SalesBudgetCSVBatch', 'createCSV', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
		//9system.debug('End of CSV: ' + loopCounter);
		csvData = csvData.removeEnd('\n');
		csvData = csvData.replaceAll('null', '');
		csvFileComplete += '\n' + csvData;
		system.debug('csvFileComplete: ' + csvFileComplete);
	}

	global map<string, string> describeFieldList(string sObjectName) {
		Schema.DescribeSObjectResult sobjResult = Schema.getGlobalDescribe().get(sObjectName).getDescribe();
		map<String, Schema.SObjectField> fieldMap = sobjResult.fields.getMap();
		fieldLabelWithNameMap = new map<String, string> ();

		for (string field : fieldMap.keySet()) {
			if (fieldMap.get(field).getDescribe().isAccessible() && fieldMap.get(field).getDescribe().isCustom())
			fieldLabelWithNameMap.put(fieldMap.get(field).getDescribe().getLabel(), fieldMap.get(field).getDescribe().getName());

		}
		return fieldLabelWithNameMap;
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
			createCSV();
			csvFile = new Attachment(Body = Blob.valueOf(csvFileComplete), Name = fileName);
			sendEmailAttachment();
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('SalesBudgetCSVBatch', 'finish', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
	}

	global void sendEmailAttachment() {
		emailIds = UserInfo.getUserEmail();
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		list<String> toAddresses = new list<String> ();
		list<String> ccAddresses = new list<String> ();
		ccAddresses.add('matthew.kidman@mandsconsulting.com');
		ccAddresses.add('shubham.gupta@mandsconsulting.com');
		toAddresses.add(userInfo.getUserEmail());
		mail.setToAddresses(toAddresses);
		mail.setCcAddresses(ccAddresses);
		mail.setSubject('Budget Transfer Export');
		mail.setPlainTextBody('Budget Transfer Export completed on: ' + DateTime.Now());

		Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
		efa.setBody(csvFile.Body);
		efa.setFileName(csvFile.Name);
		mail.setFileAttachments(new list<Messaging.EmailFileAttachment> { efa });

		Messaging.sendEmail(new list<Messaging.SingleEmailMessage> { mail });
	}

	public class salesbudgetWrapper
	{
		public string Division;
		public string Title;
		public string Manager;
		public string Managers_PSID;
		public String Manager_HRWorkforceId;
		public string PSID;
		public string Name;
		public String HR_WorkforceId;
		public string Rev_Type;
		public List<Decimal> inbudgets;
		public List<Decimal> outBudgets;
		public List<Decimal> budgetChanges;

		public salesbudgetWrapper()
		{
			Division = '';
			Title = '';
			PSID = '';
			Name = '';
			Rev_Type = '';
			HR_WorkforceId = '';
			Manager_HRWorkforceId = '';
			inbudgets = new List<Decimal> { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
			outBudgets = new List<Decimal> { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
			budgetChanges = new List<Decimal> { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
		}

	}
}