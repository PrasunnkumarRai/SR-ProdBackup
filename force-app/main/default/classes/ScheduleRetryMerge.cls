global class ScheduleRetryMerge implements Schedulable{
    
    global void execute(SchedulableContext ctx) {
        AccountMergeRetryBatch btc = new AccountMergeRetryBatch();
        Database.executeBatch(btc,1);
    }

}