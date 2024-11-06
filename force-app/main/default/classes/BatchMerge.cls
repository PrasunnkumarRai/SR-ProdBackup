global class BatchMerge implements Database.Batchable<sObject>, Database.Stateful  {
    private String duplicateJobId;
    private String sobjectType;
    private String recordType;
    public List<Account_Bulk_Merge__c> landscapingRecords;
    public List<Object_Selector_Metadata__mdt> objectMetadata;
    public Boolean scoringNeeded;
    public Integer numberOfFields;
    public List<Map<String, String>> fieldToWeightage;
    public List<String> fields;
    public Map<String,String> fieldsToCheck;

    public BatchMerge(String duplicateJobId, String sobjectType, String recordType) {
        this.duplicateJobId = duplicateJobId;
		this.sobjectType = sobjectType;
		this.recordType = recordType;
        
        if(sobjectType == 'Account') {
             landscapingRecords= new List<Account_Bulk_Merge__c>();
        }
        
        String objectMdtQuery = 'SELECT Scoring_Needed__c, Field_API_Name__c, Weightage__c, Sort_order__c from Object_Selector_Metadata__mdt WHERE Object_API_Name__c = \'';
        objectMdtQuery += sobjectType;
        objectMdtQuery += '\'';
        if (recordType != null) {
            objectMdtQuery += ' AND Record_Type_API_Name__c = \'';
            objectMdtQuery += recordType;
            objectMdtQuery += '\'';
        }
        objectMdtQuery += ' ORDER BY Weightage__c DESC';
        objectMetadata = Database.query(objectMdtQuery);

       	scoringNeeded = objectMetadata[0].Scoring_Needed__c;
        numberOfFields = objectMetadata.size();
        fieldToWeightage = new List<Map<String, String>>();
        for (Object_Selector_Metadata__mdt objectMetadataItem : objectMetadata) {
            Map<String, String> m = new Map<String, String>();
            m.put('APIName',objectMetadataItem.Field_API_Name__c);
            m.put('Weightage',String.valueOf(objectMetadataItem.Weightage__c));
            m.put('SortingOrder',objectMetadataItem.Sort_order__c);
            fieldToWeightage.add(m);
        }

		Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType sObjectSchemaType = globalDescribeMap.get(sobjectType);
        Schema.DescribeSObjectResult describeResult = sObjectSchemaType.getDescribe();
        Map<String, Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
        fields = new List<String>(fieldsMap.keySet());

       	fieldsToCheck = DuplicateJobController.getFieldSetLabels('CI_Fields','Account');

    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
       
        String rawDRSNames = [SELECT DRS_Names__c FROM DRS_Not_For_Merge__mdt][0].DRS_Names__c;
		List<String> drsNames = rawDRSNames.split('\n');
		List<String> finalDRSNames = new List<String>();
		for (String drsName : drsNames) {
    		finalDRSNames.add(drsName.trim());
		}
        if(Test.isRunningTest()){
            return Database.getQueryLocator([
                SELECT Id
                FROM DuplicateRecordSet 
                WHERE ParentId = :duplicateJobId
                AND RecordCount > 1
                LIMIT 200
            ]);
        }
        return Database.getQueryLocator([
            SELECT Id, Name
            FROM DuplicateRecordSet 
            WHERE ParentId = :duplicateJobId
            AND RecordCount > 1
            AND Name IN :finalDRSNames
            ORDER BY Id ASC
        ]);
    }

    global void execute(Database.BatchableContext BC, List<DuplicateRecordSet> recordSets) {
		System.debug('recordSets@@@@' + recordSets);
        

        Map<Id, DuplicateRecordSet> recordSetMap = new Map<Id, DuplicateRecordSet>();
        List<String> allIds = new List<String>();
        for (DuplicateRecordSet recordSet : recordSets) {
            recordSetMap.put(recordSet.Id, recordSet);
        }
		
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
		
        String soqlQuery = 'SELECT ';
        soqlQuery += String.join(fields, ', ');
        soqlQuery += ' FROM ';
        soqlQuery += sobjectType;
        soqlQuery += ' WHERE Id IN :allIds';
        if (recordType != null) {
            soqlQuery += ' AND RecordType.DeveloperName = \'' + recordType + '\'';
        }
        if (sobjectType == 'Account' && recordType == 'Advertiser_Account') {
            soqlQuery += ' AND Primary_Commodity__c != \'Political\'';
        }
        List<SObject> allsObjects = Database.query(soqlQuery);
        if (allsObjects.size() == 0) {
            return;
        }
        System.debug('allSobjects.size@@@' + allsObjects.size());
        
        Map<Id, List<SObject>> sobjectMap = new Map<Id, List<SObject>>();
        
        for (SObject sobjectIterator : allsObjects) {
            for (Id setId : recordItemsMap.keySet()) {
                for (DuplicateRecordItem dri : recordItemsMap.get(setId)) {
                    if (dri.RecordId == sobjectIterator.Id) {
                        if (!sobjectMap.containsKey(setId)) {
                            sobjectMap.put(setId, new List<SObject>());
                        }
                        sobjectMap.get(setId).add(sobjectIterator);
                        break;
                    }
                }
            }
        }

        List<String> mergeMapJsonList = new List<String>();

        for (Id setId : recordSetMap.keySet()) {
            List<SObject> elements = sobjectMap.get(setId);
            String selectedId = '';
            SObject selectedRecord;
            List<String> childIds = new List<String>();
            List<Map<String,Object>> childRecordsMap = new List<Map<String,Object>>();
            Map<String,Object> mergeMap = new Map<String,Object>();
            List<DuplicateJobController.ApexWrapper> scores = new List<DuplicateJobController.ApexWrapper>();
        
            if (elements == null || elements.isEmpty()) {
                continue;
            } else if (elements.size() > 1) {
                if (scoringNeeded) {
                    scores = DuplicateJobController.scoreDuplicates(elements, sobjectType, fieldToWeightage, numberOfFields);
                } else {
                    scores = DuplicateJobController.noScore(elements);
                }
            } else {
                continue;
            }
        
            for (DuplicateJobController.ApexWrapper score : scores) {
                if (score.totalScore == 10) {
                    selectedId = score.accountRecord.Id;
                    selectedRecord = score.accountRecord;
                    System.debug('selectedRecord@@@@' + selectedRecord);
                }
                else {
                    if (sobjectType == 'Account') {
                        Map<String, Object> m = new Map<String, Object>();
                        m.put('childRecord', score.accountRecord);
                        m.put('score', score.totalScore);
                        m.put('LastModifiedDate', score.accountRecord.get('LastModifiedDate'));
                        if (recordType == 'Agency_Account') {
                        //    Date lastScheduledDate = (Date)score.accountRecord.get('Last_Scheduled_Date_Latest_Agency_Opp__c');
                        //    Date comparisonDate = Date.newInstance(2021, 12, 31);

                        //    if ((lastScheduledDate == null) || (lastScheduledDate != null && lastScheduledDate <= comparisonDate)) {
                                m.put('Most_Recently_Used_Opportunity_Date_Agen__c', score.accountRecord.get('Most_Recently_Used_Opportunity_Date_Agen__c'));
                        //        childIds.add(score.accountRecord.Id);
                        //        childRecordsMap.add(m);
                        //   }
                        }
                        // else {
                            childRecordsMap.add(m);
                            childIds.add(score.accountRecord.Id);
                        // }
                    }
                    else {
                        childIds.add(score.accountRecord.Id);
                    }
                }
            }    
            
            if (childIds.size() == 0) {
                continue;
            }
    
            if (sobjectType == 'Account') {
                List<String> missingFields = new List<String>();
                for (String field : fieldsToCheck.keySet()) {
                    if (selectedRecord.get(field) == null) {
                        missingFields.add(field);
                    }
                }
                if (missingFields.size() > 0) {
                    List<ChildRecordComparator> comparators = new List<ChildRecordComparator>();
                    for (Map<String, Object> recordMap : childRecordsMap) {
                        comparators.add(new ChildRecordComparator(recordMap));
                    }
                    comparators.sort();
        
                    childRecordsMap.clear();
                    for (ChildRecordComparator comparator : comparators) {
                        childRecordsMap.add(comparator.record);
                    }
        
                    for (Map<String, Object> recordMap : childRecordsMap) {
                        SObject childRecord = (SObject) recordMap.get('childRecord');
                        List<String> foundFields = new List<String>();
                        for (String field : missingFields) {
                            if (childRecord.get(field) != null) {
                                mergeMap.put(field, childRecord.get(field));
                                foundFields.add(field);
                            }
                        }
                        for (String field : foundFields) {
                            Integer index = missingFields.indexOf(field);
                            if (index != -1) {
                                missingFields.remove(index);
                            }
                        }
        
                        if (missingFields.isEmpty()) {
                            break;
                        }
                    }
                }
                if (recordType == 'Agency_Account' && selectedRecord.get('AOS_Account_Id__c') == null) {
                    List<AOSRecordComparator> comparators = new List<AOSRecordComparator>();
                    for (Map<String, Object> recordMap : childRecordsMap) {
                        comparators.add(new AOSRecordComparator(recordMap));
                    }
                    comparators.sort();
        
                    childRecordsMap.clear();
                    for (AOSRecordComparator comparator : comparators) {
                        childRecordsMap.add(comparator.record);
                    }
                    for (Map<String, Object> recordMap : childRecordsMap) {
                        SObject childRecord = (SObject) recordMap.get('childRecord');
                        if (childRecord.get('AOS_Account_Id__c') != null) {
                            mergeMap.put('AOS_Account_Id__c', childRecord.get('AOS_Account_Id__c'));
                            break;
                        }
                    }
                }
            }
    
            mergeMap.put('selectedId', selectedId);
            mergeMap.put('childIds', childIds);
            System.debug('mergeMap@@@@' + mergeMap);
        
            String mergeMapJson = JSON.serialize(mergeMap);
            if (mergeMapJson != null) {
                mergeMapJsonList.add(mergeMapJson);
            }
        }
        

        System.debug('mergeMapJsonList' + mergeMapJsonList);

        if (sobjectType == 'Traffic_Id_Element__c'  && mergeMapJsonList != null) {
            DuplicateJobController.mergeAllDuplicateTrafficIdElements(mergeMapJsonList);
        }

        else if (sobjectType == 'Account' && mergeMapJsonList != null) {
            Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
            List<Account_Bulk_Merge__c> tempLandscapingRecords = new List<Account_Bulk_Merge__c>();
            for (String groupChangesString : mergeMapJsonList) {
                Map<String, Object> groupChange = (Map<String, Object>) JSON.deserializeUntyped(groupChangesString);
            
                String selectedId = (String)groupChange.get('selectedId');
                List<Object> childIds = (List<Object>) groupChange.get('childIds');
                
                groupChange.remove('selectedId');
                groupChange.remove('childIds');
                System.debug('selectedId@@@'+ selectedId + 'childIds@@@' + childIds);
                if (groupChange.containsKey('Projected_Segment_Name__c')) {
                    groupChange.remove('Projected_Segment_Name__c');
                }

                List<String> childIdsAsString = new List<String>();
                for (Object id : childIds) {
                    childIdsAsString.add((String) id);
                }

                Account selectedAccount = new Account(Id = selectedId);
                Boolean hasUpdates = false;

                if (!groupChange.isEmpty()) {
                    for (String field : groupChange.keySet()) {
                        selectedAccount.put(field, groupChange.get(field));
                        hasUpdates = true;
                    }
                }

                if (hasUpdates) {
                    accountsToUpdate.put(selectedId, selectedAccount);
                }

                for (String childId : childIdsAsString) {
                    Account_Bulk_Merge__c landscapingRecord = new Account_Bulk_Merge__c();
                    landscapingRecord.Parent_Account__c = selectedId;
                    landscapingRecord.Child_Account__c = childId;
                    landscapingRecord.is_Landscaping__c = true;
                    System.debug('landscapingRecord@@@'+ landscapingRecord);
                    tempLandscapingRecords.add(landscapingRecord);
                }
            }

            System.debug(JSON.serialize(tempLandscapingRecords));
            System.debug(JSON.serialize(accountsToUpdate));

            if (!accountsToUpdate.isEmpty()) {
                update(accountsToUpdate.values());
            }

            insert(tempLandscapingRecords);

            landscapingRecords.addAll(tempLandscapingRecords);
            
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Finished merge');

        if (sobjectType == 'Account') {
            AccountBulkMerge abm = new AccountBulkMerge();
            abm.isLandscaping = true;
            abm.landscapingRecords = new List<Account_Bulk_Merge__c>(landscapingRecords);
            System.debug('@@abm.landscapingRecords: '+abm.landscapingRecords);
            if (!Test.isRunningTest()) {
               Database.executeBatch(abm, Integer.valueOf(System.Label.AccountMergeBatchSize));
            }
            
        }
    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
		String[] toAddresses = new String[] {'shubham.gupta@mandsconsulting.com'};
		mail.setToAddresses(toAddresses);

        mail.setSubject('Completion of Batch Merge Process');
        
        mail.setPlainTextBody('The batch merge process has successfully completed.\n\n');
    
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }

    public class ChildRecordComparator implements Comparable {
        public Map<String, Object> record;
    
        public ChildRecordComparator(Map<String, Object> record) {
            this.record = record;
        }
    
        public Integer compareTo(Object compareTo) {
            ChildRecordComparator other = (ChildRecordComparator) compareTo;
            
            Decimal scoreA = (Decimal) this.record.get('score');
            Decimal scoreB = (Decimal) other.record.get('score');
            
            if (scoreA > scoreB) {
                return -1;
            } else if (scoreA < scoreB) {
                return 1;
            } else {
                DateTime lastModifiedA = (DateTime) this.record.get('LastModifiedDate');
                DateTime lastModifiedB = (DateTime) other.record.get('LastModifiedDate');
                if (lastModifiedA > lastModifiedB) {
                    return -1;
                } else if (lastModifiedA < lastModifiedB) {
                    return 1;
                } else {
                    return 0;
                }
            }
        }
    }

    public class AOSRecordComparator implements Comparable {
        public Map<String, Object> record;
    
        public AOSRecordComparator(Map<String, Object> record) {
            this.record = record;
        }
    
        public Integer compareTo(Object compareTo) {
            AOSRecordComparator other = (AOSRecordComparator) compareTo;
    
            DateTime oppDateA = (DateTime) this.record.get('Most_Recently_Used_Opportunity_Date_Agen__c');
            DateTime oppDateB = (DateTime) other.record.get('Most_Recently_Used_Opportunity_Date_Agen__c');
    
            if (oppDateA == oppDateB || (oppDateA != null && oppDateB != null && oppDateA.equals(oppDateB))) {
                DateTime lastModifiedA = (DateTime) this.record.get('LastModifiedDate');
                DateTime lastModifiedB = (DateTime) other.record.get('LastModifiedDate');
                if (lastModifiedA > lastModifiedB) {
                    return -1;
                } else if (lastModifiedA < lastModifiedB) {
                    return 1;
                } else {
                    return 0; 
                }
            } else if (oppDateA != null && (oppDateB == null || oppDateA > oppDateB)) {
                return -1;
            } else {
                return 1;
            }
        }
    }
    
    
}