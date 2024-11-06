/*
  ###########################################################################
  # File..................: BudgetAggregateBatchScheduler.cls
  # Version...............: 1
  # Created by............: Matthew Kidman
  # Created Date..........: 8-Jan-2020
  # Last Modified by......:
  # Last Modified Date....:
  # Description...........: This class is used to Schedule the BudgetAggregateBatch class.
  # TAO Ref#..............: NA
  # Test Class............: 
  # Change Log............:
  #
  #
  ############################################################################*/
global class BudgetAggregateBatchScheduler implements Schedulable {
	global Set<ID> usrID = new Set<Id> ();
	global ID batchID;
	global BudgetAggregateBatchScheduler(Set<ID> usrID) {
		this.usrID = usrID;
	}

	global void execute(SchedulableContext sc) {
		String qry = '';
		qry = 'SELECT Budget_User__c,Budget_User__r.Budget_Type__c, Budget_User__r.Name , Type__c,Amount__c,DMA__c ,Broadcast_Month_Date__c,Product_Line__c FROM Sales_Budget__c  ';
		qry += ' where ((Type__c = \'Data\' and (Product_Line__c != \'New Business\' AND Product_Line__c != \'Unknown Churn\')) OR Type__c = \'DOS\') ';
		if (usrID != null)
		{
			qry += 'AND Calendar_Year(Broadcast_Month_Date__c) = 2020 AND Product_Line__c != null AND Amount__c != 0 and Budget_User__c =:userIDs order by Budget_User__c,Product_Line__c,Type__c desc ';
		}
		else {
			qry += 'AND Calendar_Year(Broadcast_Month_Date__c) = 2020 AND Product_Line__c != null AND Amount__c != 0  order by Budget_User__c,Product_Line__c,Type__c desc ';
		}
		BudgetAggregateBatch brb = new BudgetAggregateBatch(qry, usrId, false);
		database.executeBatch(brb, 2000);
	}
}