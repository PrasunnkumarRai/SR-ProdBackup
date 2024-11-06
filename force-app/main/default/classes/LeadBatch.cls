global class LeadBatch implements Schedulable {
	
	global void execute(SchedulableContext sc){
	 LeadBatchServices LS = new LeadBatchServices();
	 LS.LeadMessageService();
	}

}