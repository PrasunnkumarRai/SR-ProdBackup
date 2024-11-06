global class BatchSingleUnmerge implements Database.Batchable<sObject>, Database.Stateful {
    private String recordId;

    public BatchSingleUnmerge(String recordId) {
        this.recordId = recordId;
        
        Account_Merge_Log__c aml = [SELECT Id, Merged_Account_ID__c
                                    FROM Account_Merge_Log__c
                                   	WHERE Id =: recordId
                                   ][0];
       
        List<Account> deletedAccounts = [
            SELECT Id FROM Account 
            WHERE IsDeleted = true AND Id = :aml.Merged_Account_ID__c ALL ROWS
        ];
        
        if (!deletedAccounts.isEmpty()) {
                Database.undelete(deletedAccounts, false);
        }
            
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, Object_Name__c, Record_ID__c, Field_to_Update__c, Account_Merge_Log__c, Account_Merge_Log__r.Merged_Account_ID__c
            FROM Account_Merge_Detail__c 
            WHERE Account_Merge_Log__c = :recordId AND Object_Name__c NOT IN ('AccountShare', 'AccountTeamMember', 'Lead')
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Account_Merge_Detail__c> scope) {
        Map<String, List<SObject>> recordsByType = new Map<String, List<SObject>>();

        // Process each detail record and prepare updates
        for (Account_Merge_Detail__c detail : scope) {
            if (detail.Object_Name__c != null) {
                Schema.SObjectType targetType = Schema.getGlobalDescribe().get(detail.Object_Name__c);
                if (targetType != null) {
                    SObject record = targetType.newSObject(detail.Record_ID__c);
                    if (detail.Object_Name__c != 'Task') {
                        record.put(detail.Field_to_Update__c, detail.Account_Merge_Log__r.Merged_Account_ID__c);
                    } else {
                        record.put('WhatId', detail.Account_Merge_Log__r.Merged_Account_ID__c);
                    }

                    // Add the record to the correct list for its type
                    if (!recordsByType.containsKey(detail.Object_Name__c)) {
                        recordsByType.put(detail.Object_Name__c, new List<SObject>());
                    }
                    recordsByType.get(detail.Object_Name__c).add(record);
                }
            }
        }

        // Perform update operations separately for each SObject type
        for (String objectType : recordsByType.keySet()) {
            List<SObject> recordsToUpdate = recordsByType.get(objectType);
            if (!recordsToUpdate.isEmpty()) {
                System.debug('Updating records of type ' + objectType + ': ' + recordsToUpdate);
                Database.update(recordsToUpdate, false);
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Logic to execute when the batch job finishes
        System.debug('Inside finish');
    }
}