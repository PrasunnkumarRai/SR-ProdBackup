global class BatchDownload implements Database.Batchable<sObject>, Database.Stateful  {
    private String duplicateJobId;
    private String sobjectType;
    private String recordType;
	private List<Object_Selector_Metadata__mdt> objectMetadata;
	private List<String> exportFields;
	private List<String> exportFieldsLabels;
	private Boolean scoringNeeded;
	private Integer numberOfFields;
    private List<Map<String, String>> fieldToWeightage;
	private String csvBody = '';
    private DateTime dt;
	
    public BatchDownload(String duplicateJobId, String sobjectType, String recordType) {
		System.debug('inside constructor');
        this.duplicateJobId = duplicateJobId;
		this.sobjectType = sobjectType;
		this.recordType = recordType;
		
        dt = DateTime.now();
		String objectMdtQuery = 'SELECT Scoring_Needed__c, Field_API_Name__c, Weightage__c, Sort_order__c from Object_Selector_Metadata__mdt WHERE Object_API_Name__c = \'';
        objectMdtQuery += sobjectType;
        objectMdtQuery += '\'';
        if (recordType != null) {
            objectMdtQuery += ' AND Record_Type_API_Name__c = \'';
            objectMdtQuery += recordType;
            objectMdtQuery += '\'';
        }
        objectMdtQuery += ' ORDER BY Weightage__c DESC';
        this.objectMetadata = Database.query(objectMdtQuery);
		
		this.scoringNeeded = this.objectMetadata[0].Scoring_Needed__c;
		
		this.numberOfFields = this.objectMetadata.size();
		
		this.fieldToWeightage = new List<Map<String, String>>();
        for (Object_Selector_Metadata__mdt objectMetadataItem : this.objectMetadata) {
            Map<String, String> m = new Map<String, String>();
            m.put('APIName',objectMetadataItem.Field_API_Name__c);
            m.put('Weightage',String.valueOf(objectMetadataItem.Weightage__c));
            m.put('SortingOrder',objectMetadataItem.Sort_order__c);
            this.fieldToWeightage.add(m);
        }
		
		String mdtQuery = 'SELECT Field_Label__c, Field_API_Name__c, Field_Role__c, Display_Level__c FROM Landscaping_UI_Fields_Metadata__mdt WHERE Object_API_Name__c =:sobjectType AND Field_Role__c = \'Export\'';
        if (recordType != null) {
            objectMdtQuery += ' AND Record_Type_API_Name__c = \'';
            objectMdtQuery += recordType;
            objectMdtQuery += '\'';
        }
        mdtQuery += ' ORDER BY Display_Level__c';
        List<Landscaping_UI_Fields_Metadata__mdt> exportFieldsFull = Database.query(mdtQuery);
		this.exportFields = new List<String>();
		this.exportFieldsLabels = new List<String>();
		for (Landscaping_UI_Fields_Metadata__mdt field : exportFieldsFull) {
			this.exportFields.add(field.Field_API_Name__c);
			this.exportFieldsLabels.add(field.Field_Label__c);
		}
		
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('inside start');
        if(Test.isRunningTest()){
                return Database.getQueryLocator([
                SELECT Id
                FROM DuplicateRecordSet 
                WHERE ParentId = :duplicateJobId AND RecordCount > 1 LIMIT 99
            ]);
        }
        return Database.getQueryLocator([
            SELECT Id
            FROM DuplicateRecordSet 
            WHERE ParentId = :duplicateJobId AND RecordCount > 1
        ]);
    }

    global void execute(Database.BatchableContext BC, List<DuplicateRecordSet> recordSets) {

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
        Map<Id, List<SObject>> sobjectMap = new Map<Id, List<SObject>>();

		Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType sObjectSchemaType = globalDescribeMap.get(sobjectType);
        Schema.DescribeSObjectResult describeResult = sObjectSchemaType.getDescribe();
        Map<String, Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
        List<String> fields = new List<String>(fieldsMap.keySet());
		
		String soqlQuery = 'SELECT ';
        soqlQuery += String.join(fields, ', ');
        soqlQuery += ', (SELECT DuplicateRecordSet.Name FROM DuplicateRecordItems WHERE DuplicateRecordSet.ParentId = :duplicateJobId)';
        if (sobjectType == 'Account') {
            soqlQuery += ', (SELECT Traffic_Id__c, ExportSystem_Name__c FROM Traffic_Id_Elements__r)';
        }
        soqlQuery += ' FROM ';
        soqlQuery += sobjectType;
        soqlQuery += ' WHERE Id IN :allIds';
        if (recordType != null) {
            soqlQuery += ' AND RecordType.DeveloperName = \'' + recordType + '\'';
        }
        List<SObject> allsObjects = Database.query(soqlQuery);
        if (allsObjects.size() == 0) {
            return;
        }
        
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
        System.debug('sobjectMap@@@' + sobjectMap);

        for (Id setId : recordSetMap.keySet()) {
            List<SObject> elements = sobjectMap.get(setId);
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
			
			List<ApexWrapperComparator> comparatorList = new List<ApexWrapperComparator>();

			for (DuplicateJobController.ApexWrapper score : scores) {
				comparatorList.add(new ApexWrapperComparator(score));
			}
			
			comparatorList.sort();

			List<DuplicateJobController.ApexWrapper> sortedScores = new List<DuplicateJobController.ApexWrapper>();
			for (ApexWrapperComparator comparator : comparatorList) {
				sortedScores.add(comparator.wrapper);
			}
        
            for (DuplicateJobController.ApexWrapper score : sortedScores) {
				SObject record = score.accountRecord;
                SObject drs = record.getSObjects('DuplicateRecordItems')[0];
                SObject drsSet = drs.getSObject('DuplicateRecordSet');
            	csvBody += '"' + drsSet.get('Name') + '",'; 
                csvBody += '"' + record.get('Id') + '",';
				csvBody += '"' + score.totalScore + '",';
                if (score.totalScore == 10) {
					csvBody += '"true"' + ',';
                } 
				else {
                    csvBody += '"false"' + ',';
                }
				for (Integer j = 0; j < exportFields.size(); j++) {
                    String field = exportFields[j];
                    String fieldValue = String.valueOf(record.get(field));
                    
                    if (fieldValue != null) {
                        fieldValue = '"' + fieldValue.replace('"', '""') + '"';
                    } else {
                        fieldValue = '""';
                    }
                    csvBody += fieldValue;
                    
                    if (j < exportFields.size() - 1) {
                        csvBody += ',';
                    }
                }
				if (sobjectType == 'Account') {
					csvBody += ',';
					List<SObject> tideList = record.getSObjects('Traffic_Id_Elements__r');
					if (tideList == null || tideList.isEmpty()) {
                        csvBody += '""';
					}
                    else {
                        csvBody += '"';
                        for (Integer i = 0; i < tideList.size(); i++) {
                            SObject tide = tideList[i];
                            csvBody += tide.get('Traffic_Id__c') + ': ' + tide.get('ExportSystem_Name__c');
                            if (i < tideList.size() - 1) {
                                csvBody += '; ';
                            }
                        }
                        csvBody += '"';
                    }
				}
				csvBody += '\n';
            }
        }
		System.debug('csvBody@@@'+csvBody);
	}

    global void finish(Database.BatchableContext BC) {
        System.debug('inside finish');
		
		String duplicateJobName = [SELECT Name FROM DuplicateJob WHERE Id =: duplicateJobId LIMIT 1][0].Name;
		
		Schema.SObjectType sObjectName = Schema.getGlobalDescribe().get(sObjectType);
		Schema.DescribeSObjectResult describeResult = sObjectName.getDescribe();
		String objectLabel = describeResult.getLabel();
		
		String recordTypeName;
		if (recordType != null) {
			recordTypeName = [SELECT Name FROM RecordType WHERE SObjectType =: sobjectType AND DeveloperName =: recordType LIMIT 1][0].Name;
		}
		
		String csvHeader = '"DRS Name","ID","Score","isParent?",';
		for (Integer j = 0; j < exportFieldsLabels.size(); j++) {
			String field = exportFieldsLabels[j];
			csvHeader += field;
			if (j < exportFieldsLabels.size() - 1) {
				csvHeader += ',';
			}
		}
        if (sobjectType == 'Account') {
			csvHeader += ',"TIDE Data"';
			csvHeader += '\n';
        }
		System.debug('csvHeader@@@'+csvHeader);
		String csvFile = csvHeader + csvBody;
		
		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { userinfo.getUserEmail() , 'shubham.gupta@mandsconsulting.com'};

        message.subject = 'Data Cleanse Hub Download';
        String messageBody = '<html><body>Hi ' + userinfo.getName() + ', <br/>Please find attached the requested duplicate job data.<br/><br/>Name of the duplicate job: <b>' + duplicateJobName + '</b><br/>Object: <b>' + objectLabel + '</b>';
		if (recordType != null) {
			messageBody += '<br/>Record Type: <b>' + recordTypeName + '</b>';
		}	
		messageBody += '<br/><br/>Thanks.';
        message.setHtmlBody(messageBody);

        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
        String fileName = duplicateJobName + '_' + String.valueOf(dt) + '.csv';
        csvAttachment.setFileName(fileName);
        csvAttachment.setBody(Blob.valueOf(csvFile));
        csvAttachment.setContentType('text/csv');

        message.setFileAttachments(new Messaging.EmailFileAttachment[] { csvAttachment });
		
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
		
    }

	public class ApexWrapperComparator implements Comparable {
		public DuplicateJobController.ApexWrapper wrapper;

		public ApexWrapperComparator(DuplicateJobController.ApexWrapper wrapper) {
			this.wrapper = wrapper;
		}

		public Integer compareTo(Object compareTo) {
			ApexWrapperComparator other = (ApexWrapperComparator) compareTo;

			if (this.wrapper.totalScore > other.wrapper.totalScore) {
				return -1;
			} else if (this.wrapper.totalScore < other.wrapper.totalScore) {
				return 1;
			} else {
				return 0;
			}
		}
	}
    
    
}