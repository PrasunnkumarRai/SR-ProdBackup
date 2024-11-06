/*
  ###########################################################################
  # File..................: BudgetingToolMassResubmission.cls
  # Version...............: 1
  # Created by............: James Dean
  # Created Date..........: 29-August-2019
  # Last Modified by......:
  # Last Modified Date....:
  # Description...........: This class is used to mass submit Budgeting Tool Statuses
  # TAO Ref#..............: NA
  # Test Class............: 
  # Change Log............:
  #
  #
  ############################################################################*/


global class BudgetingToolMassResubmission implements Database.Batchable<sObject> {

	global String query;
	global String calledVia = '';

	global BudgetingToolMassResubmission(String qry) {

		if (string.isEmpty(qry))
		{
			qry = 'SELECT Id, budget_type__c FROM User where budget_type__c != null ';
		}
		this.query = qry;
	}

	global BudgetingToolMassResubmission(string calledVia, Map<String, String> userMap) {
		system.debug('calledVia: ' + calledVia);
		system.debug('userMap: ' + userMap);
		List<String> userIds = new List<String> (userMap.keySet());
		String users = '(';
		Integer count = 0;
		for (String userId : userIds) {
			if (count != 0) {
				users = users + ',' + '\'' + userId + '\'';
			}
			else {
				users = users + '\'' + userId + '\'';
			}
			count++;
		}

		users.removeEnd(',');
		users = users + ')';

		this.query = 'SELECT ID, budget_type__c FROM USER WHERE ID IN ' + users + ' AND budget_type__c != null';
		this.calledVia = calledVia;
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		system.debug('query: ' + query);
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, list<User> scope) {

		for (User u : scope) {
			try {
				//Change user id based on user who needs Forecast re-submission
				BudgetingToolController.impparam = u.id;
				//Execute forecast submission
				BudgetingToolController btc = new BudgetingToolController();
				if (this.calledVia.toLowerCase() == 'adminutility') {
					btc.submitForecast();
				}

				else {
					btc.submitForecast();
				}
			}
			catch(Exception ex) {
				System.Debug('exception:' + ex.getMessage());
				Log4SF.logMessage('BudgetingToolMassResubmission', 'execute', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
			}
		}
	}

	global void finish(Database.BatchableContext BC) {
		system.debug('BudgetingToolMassResubmission.finish()');
	}
}