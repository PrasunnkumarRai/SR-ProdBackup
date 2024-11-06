global class DC_StatusMissingCreativeBatchSch implements schedulable{
    global void execute(SchedulableContext sc)
    {
      DC_StatusMissingCreativeBatch b = new DC_StatusMissingCreativeBatch();  
      database.executebatch(b,200);
    }
}