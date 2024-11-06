global class DC_StatusMissingCreativeUpdaterBatchSch implements schedulable{
    global void execute(SchedulableContext sc)
    {
        DC_StatusMissingCreativeUpdaterBatch b = new DC_StatusMissingCreativeUpdaterBatch();  
        database.executebatch(b,1);
    }
}