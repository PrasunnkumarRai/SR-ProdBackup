global class ScheduleTerminateInterimAE implements Schedulable 
{    
    global void execute(SchedulableContext sc)
    {
        Integer batchSize = String.isNotBlank(Label.TerminateInterimAEBatchSize)? Integer.valueOf(Label.TerminateInterimAEBatchSize) : 200;
        database.executebatch(new TerminateInterimAE_Batch(), batchSize);
    }
}