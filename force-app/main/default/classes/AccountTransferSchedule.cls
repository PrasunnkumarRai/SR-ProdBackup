global class AccountTransferSchedule implements Schedulable {
	global Object trf;
	global ID batchID;
	global AccountTransferSchedule(Object trf) {
		this.trf = trf;
	}

	global void execute(SchedulableContext sc) {
		//Sequence of batch execution: Proposal, Opportunity, AccountTeamMember, AccountConnection, AccountSAMMapping, Revenue, SalesBudget 	
		if ((Object) trf instanceof TransferProposalBatch) {
			batchID = Database.executeBatch((TransferProposalBatch) trf, 100);
		}
		else if ((Object) trf instanceof TransferNewsBusinessBatch) {
			batchID = Database.executeBatch((TransferNewsBusinessBatch) trf, 100);
		}
		system.abortJob(sc.getTriggerId());
	}
	/*
	  global void finish(SchedulableContext BC)
	  {
	  // Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext.
	  // Query the AsyncApexJob object to retrieve the current job's information.
	  AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email 
	  FROM AsyncApexJob 
	  WHERE Id =:BC.getTriggerId()];
	 
	  //then use the active job id and abort it
	  system.abortJob(a.id);
	  }
	 */
}