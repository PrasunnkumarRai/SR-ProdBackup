global class DC_StatusMissingCreativeToLiveSch implements schedulable{
    global void execute(SchedulableContext sc)
    {
      DC_StatusMissingCreativeToLive b = new DC_StatusMissingCreativeToLive();  
      database.executebatch(b,1);
    }
}