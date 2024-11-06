global class DuplicateRecordBatch implements Database.Batchable<sObject> {
    private String duplicateJobId;

    // Constructor to initialize the duplicate job ID
    public DuplicateRecordBatch(String jobId) {
        this.duplicateJobId = jobId;
    }

    // Start method: Query all duplicate record sets for the given duplicate job ID
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(Test.isRunningTest()){
                return Database.getQueryLocator([
                SELECT Id
                FROM DuplicateRecordSet 
                WHERE ParentId = :duplicateJobId and RecordCount > 1 LIMIT 1
            ]);
        }
        return Database.getQueryLocator([
            SELECT Id
            FROM DuplicateRecordSet 
            WHERE ParentId = :duplicateJobId and RecordCount > 1
        ]);
    }

    // Execute method: Process each duplicate record set
    global void execute(Database.BatchableContext BC, List<DuplicateRecordSet> recordSets) {
        // Map to hold DuplicateRecordSet IDs to query items in bulk
        Map<Id, DuplicateRecordSet> recordSetMap = new Map<Id, DuplicateRecordSet>();
        List<String> allIds = new List<String>();
        for (DuplicateRecordSet recordSet : recordSets) {
            recordSetMap.put(recordSet.Id, recordSet);
        }
        // Query all DuplicateRecordItems for the DuplicateRecordSets in the batch
        Map<Id, List<DuplicateRecordItem>> recordItemsMap = new Map<Id, List<DuplicateRecordItem>>();
        for (DuplicateRecordItem item : [
            SELECT Id, RecordId, DuplicateRecordSetId
            FROM DuplicateRecordItem
            WHERE DuplicateRecordSetId IN :recordSetMap.keySet() 
            AND Item_Merged__c = false
        ]) {
            if (!recordItemsMap.containsKey(item.DuplicateRecordSetId)) {
                recordItemsMap.put(item.DuplicateRecordSetId, new List<DuplicateRecordItem>());
            }
            recordItemsMap.get(item.DuplicateRecordSetId).add(item);
            allIds.add(item.RecordId);
        }

        Map<Id, List<Traffic_Id_Element__c>> trafficIdElementsMap = new Map<Id, List<Traffic_Id_Element__c>>();
        for (Traffic_Id_Element__c element : [SELECT Id, LastModifiedDate FROM Traffic_Id_Element__c WHERE Id IN :allIds]) {
            for (Id setId : recordItemsMap.keySet()) {
                for (DuplicateRecordItem dri : recordItemsMap.get(setId)) {
                    if (dri.RecordId == element.Id) {
                        if (!trafficIdElementsMap.containsKey(setId)) {
                            trafficIdElementsMap.put(setId, new List<Traffic_Id_Element__c>());
                        }
                        trafficIdElementsMap.get(setId).add(element);
                        break;
                    }
                }
            }
        }
        List<String> mergeMapJsonList = new List<String>();

        for (Id setId : recordSetMap.keySet()) {
            List<Traffic_Id_Element__c> elements = trafficIdElementsMap.get(setId);
            List<DuplicateJobController.ApexWrapper> scores = DuplicateJobController.noScore(elements);
            Map<String,Object> mergeMap = new Map<String,Object>();
            String selectedId = '';
            List<String> childIds = new List<String>();
            for (DuplicateJobController.ApexWrapper score : scores) {
                if (score.totalScore == 10) {
                    selectedId = score.accountRecord.Id;
                } 
                else {
                    childIds.add(score.accountRecord.Id);
                }
            }
            mergeMap.put('selectedId', selectedId);
            mergeMap.put('childIds', childIds);

            String mergeMapJson = JSON.serialize(mergeMap);
            mergeMapJsonList.add(mergeMapJson);
        }

        DuplicateJobController.mergeAllDuplicateTrafficIdElements(mergeMapJsonList);
    }

    // Finish method: Optional cleanup or final operations after batch completion
    global void finish(Database.BatchableContext BC) {
        System.debug('Finished merge');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
        String[] toAddresses = new String[] {'luke.havel@charter.com', 'c-shubham.gupta1@charter.com'};
        mail.setToAddresses(toAddresses);

        mail.setSubject('Completion of Batch Merge Process');
        
        mail.setPlainTextBody('The batch merge process has successfully completed.\n\n');
    
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }
}