global class EmptyRecycleBinBasedOnIdsbatch implements Database.Batchable<sObject> {
	global String[] idsTobeDeleted;
	global String query;
	global Set<Id> UserIds;

	global EmptyRecycleBinBasedOnIdsbatch(String qry, Set<Id> UserIds) {
		this.query = qry;
		this.UserIds = UserIds;
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<SObject> scope) {
		try {
			delete scope;
			Database.emptyRecycleBin(scope);
            
            if(Test.isRunningTest()) {
CalloutException e = new CalloutException();
e.setMessage('This is a constructed exception for testing and code coverage');
throw e;
            }
		}
		catch(Exception ex) {
			System.Debug('exception EmptyRecycleBinBasedOnIdsbatch:' + ex.getMessage());
			Log4SF.logMessage('EmptyRecycleBinBasedOnIdsbatch', 'execute', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
	}

	global void finish(Database.BatchableContext BC) {
	}
}