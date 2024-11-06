global class ExpiredBookedSponsorshipScheduler implements Schedulable {
		
	/**
	* Schedulable Class Constructor
	* Not in use right now, leaving the blank body for any future use
	**/
	global ExpiredBookedSponsorshipScheduler() {		
	}

	/**
	* gets invoked when the Schedulable job starts	
	**/
	global void execute(SchedulableContext sc) {
		//Execute ExpiredBookedSponsorshipsBatch with batch size of 200
		Database.executeBatch(new ExpiredBookedSponsorshipsBatch(), 200);
	}
}