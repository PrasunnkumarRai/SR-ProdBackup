global class UpdateOpportunityFrmAccBatchSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        UpdateOpportunityFromAccountBatch btchCls  = new UpdateOpportunityFromAccountBatch();
     	Id jobId = database.executebatch(btchCls,1);
    }
}