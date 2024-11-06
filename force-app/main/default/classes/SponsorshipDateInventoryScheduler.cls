global class SponsorshipDateInventoryScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc){
        createDateInventory();
    }
    
    public void createDateInventory(){
        List<Templates__c> templateList = [Select Id, Name, Start_Date__c, End_Date__c from Templates__c where Date_Inventory_Count__c = 0 AND RecordType.Name = 'Local' LIMIT 150];
        SponsorshipDateInventoryBatch objBatch = new SponsorshipDateInventoryBatch(templateList);
        ID batchprocessid = Database.executeBatch(objBatch,2000);
    }

}