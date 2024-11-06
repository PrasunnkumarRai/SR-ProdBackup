global class SalesRevenueCancelledOrderDeletion implements Database.Batchable<SObject> {
	string query = '';
	global SalesRevenueCancelledOrderDeletion(string qry) {
	this.query = qry;
		
	}
	
	/**
	 * @description gets invoked when the batch job starts
	 * @param context contains the job ID
	 * @returns the record set as a QueryLocator object that will be batched for execution
	 */ 
	global Database.QueryLocator start(Database.BatchableContext context) {
	
		string woEclipse = Label.Wide_Orbit_Eclipse_System_Names;
		List<String> woEclipselist =woEclipse.indexOf(',') > 0 ? woEclipse.split(',') : new List<String>{woEclipse};
		//List<Sales_Revenue__c> srList = [SELECT ID, Eclipse_System__c, Revenue__c  FROM Sales_Revenue__c where  (Eclipse_System__c Not in:woEclipselist) and Revenue__c = null LIMIT 10000];
		if(String.isEmpty(query))
			query = 'SELECT ID, Eclipse_System__c, Revenue__c  FROM Sales_Revenue__c where  (Eclipse_System__c != \'WO LA SN\' and Eclipse_System__c != \'WOLA\') and Revenue__c = null';
		return Database.getQueryLocator(query);
	}

	/**
	 * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
	 * @param context contains the job ID
	 * @param scope contains the batch of records to process.
	 */ 
   	global void execute(Database.BatchableContext context, List<Sales_Revenue__c> scope) {
	try{
		delete scope;
		}
		catch(Exception ex)
		{
			System.Debug('exception:' +ex.getMessage());
            Log4SF.logMessage('SalesRevenueCancelledOrderDeletion', 'execute', ex.getMessage(),ex, UserInfo.getUserId(),null,'');
		}
	}
	
	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */ 
	global void finish(Database.BatchableContext context) {
		RevenueAggregateBatch rb = new RevenueAggregateBatch('' ,null);
		database.ExecuteBatch(rb, 2000);  
	}
}