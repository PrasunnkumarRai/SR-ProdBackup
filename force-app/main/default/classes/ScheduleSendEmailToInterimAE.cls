global class ScheduleSendEmailToInterimAE implements Schedulable {
    global void execute(SchedulableContext sc) {
        SendEmailToInterimAE_Batch batch = new SendEmailToInterimAE_Batch();
        database.executebatch(batch);
    }
}