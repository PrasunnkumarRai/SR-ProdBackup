global class SupportRequestStatusUpdate_Scheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		Id batchJobId = Database.executeBatch(new SupportRequestStatusUpdate_Batch());
        System.debug('Hourly Support Request Update Job Id:' + batchJobId);
	}
}