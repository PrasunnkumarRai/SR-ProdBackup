/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-21-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class DuplicateJobController {

    // GroupedAccount class
    public class GroupedAccount {
        @AuraEnabled public String setId;
        @AuraEnabled public String groupName;
        @AuraEnabled public Integer count;
        @AuraEnabled public List<SObject> accounts;
        @AuraEnabled public Map<Id, Decimal> accountScores;
        @AuraEnabled public String selectedId;
        @AuraEnabled public Boolean scoringNeeded;
        

        public GroupedAccount(String setId, String name, Integer count, List<SObject> accounts, Map<Id, Decimal> accountScores, String selectedId, Boolean scoringNeeded) {
            this.setId = setId;
            this.groupName = name;
            this.count = count;
            this.accounts = accounts;
            this.accountScores = accountScores;
            this.selectedId = selectedId;
            this.scoringNeeded = scoringNeeded;
        }
    }

    public class ApexWrapper {
        @AuraEnabled
        public SObject accountRecord { get; set; }
        @AuraEnabled
        public Decimal totalScore { get; set; }
        
        // Constructor
        public ApexWrapper(SObject accountRecord, Decimal totalScore) {
            this.accountRecord = accountRecord;
            this.totalScore = totalScore;
        }
    }
    public class LastModifiedDateComparator implements Comparator<SObject> {
        public Integer compare(SObject a, SObject b) {
            Datetime dateA = (Datetime) a.get('LastModifiedDate');
            Datetime dateB = (Datetime) b.get('LastModifiedDate');
            
            if (dateA == null && dateB == null) {
                return 0;
            } else if (dateA == null) {
                return 1;
            } else if (dateB == null) {
                return -1;
            } else {
                return dateA.getTime() - dateB.getTime() > 0 ? -1 : 1;
            }
        }
    }

    public static List<ApexWrapper> noScore(List<SObject> duplicateSObjects) {

        duplicateSObjects.sort(new LastModifiedDateComparator());
    
        List<ApexWrapper> results = new List<ApexWrapper>();
        
        Decimal score = 10.0;
        for (Integer i = 0; i < duplicateSObjects.size(); i++) {
            SObject record = duplicateSObjects[i];
            ApexWrapper wrapper = new ApexWrapper(record, score);
            results.add(wrapper);
            score -= 0.01;
        }
        
        return results;
    }

    public class FieldComparator implements Comparable {
        public SObject obj;
        public String fieldName;
        public String sortOrder;
    
        public FieldComparator(SObject obj, String fieldName, String sortOrder) {
            this.obj = obj;
            this.fieldName = fieldName;
            this.sortOrder = sortOrder;
        }
    
        public Integer compareTo(Object compareTo) {
            FieldComparator other = (FieldComparator)compareTo;
            
            Decimal value1 = (Decimal) obj.get(fieldName);
            Decimal value2 = (Decimal) other.obj.get(fieldName);
    
            if (value1 == null && value2 == null) {
                return 0;
            } else if (value1 == null) {
                return (sortOrder == 'ASC') ? -1 : 1;
            } else if (value2 == null) {
                return (sortOrder == 'ASC') ? 1 : -1;
            } 
            else {
                if (sortOrder == 'ASC') {
                    if (value1 < value2) {
                        return -1;
                    } else if (value1 > value2) {
                        return 1;
                    } else {
                        return 0;
                    }
                } 
                else {
                    if (value1 < value2) {
                        return 1;
                    } else if (value1 > value2) {
                        return -1;
                    } else {
                        return 0;
                    }
                }
            }
        }
    }

    public class DateTypeFieldComparator implements Comparable {
        public SObject obj;
        public String fieldName;
        public String sortOrder;
    
        public DateTypeFieldComparator(SObject obj, String fieldName, String sortOrder) {
            this.obj = obj;
            this.fieldName = fieldName;
            this.sortOrder = sortOrder;
        }
    
        public Integer compareTo(Object compareTo) {
            DateTypeFieldComparator other = (DateTypeFieldComparator)compareTo;
            
            DateTime value1 = (DateTime) obj.get(fieldName);
            DateTime value2 = (DateTime) other.obj.get(fieldName);
    
            if (value1 == null && value2 == null) {
                return 0;
            } else if (value1 == null) {
                return (sortOrder == 'ASC') ? -1 : 1;
            } else if (value2 == null) {
                return (sortOrder == 'ASC') ? 1 : -1;
            } 
            else {
                if (sortOrder == 'ASC') {
                    if (value1 < value2) {
                        return -1;
                    } else if (value1 > value2) {
                        return 1;
                    } else {
                        return 0;
                    }
                } 
                else {
                    if (value1 < value2) {
                        return 1;
                    } else if (value1 > value2) {
                        return -1;
                    } else {
                        return 0;
                    }
                }
            }
        }
    }

    public static Integer scoreString(String value) {
        return String.isEmpty(value) ? 0 : 1;
    }

    public static Integer scoreBoolean(Boolean value) {
        return value ? 1 : 0;
    }

    public static void scoreNumber(List<SObject> sObjects, String fieldName, Integer weight, Map<Id, List<Decimal>> scoredMap, String sortOrder) {
        List<FieldComparator> comparators = new List<FieldComparator>();
        for (SObject obj : sObjects) {
            comparators.add(new FieldComparator(obj, fieldName,sortOrder));
        }
        comparators.sort();

        Integer rank = 0;
        Decimal previousValue = null;
        for (FieldComparator comparator : comparators) {
            SObject obj = comparator.obj;
            Decimal currentValue = (Decimal) obj.get(fieldName);
            
            if (currentValue == null || currentValue == 0) {
                rank = 0;
            } else if (previousValue == null || !currentValue.equals(previousValue)) {
                rank++;
            }
            previousValue = currentValue;

            Decimal weightedScore = rank * weight;
            if (!scoredMap.containsKey(obj.Id)) {
                scoredMap.put(obj.Id, new List<Decimal>());
            }
            scoredMap.get(obj.Id).add(weightedScore);
        }
    }

    public static void scoreDateTime(List<SObject> sObjects, String fieldName, Integer weight, Map<Id, List<Decimal>> scoredMap, String sortOrder) {
        List<DateTypeFieldComparator> comparators = new List<DateTypeFieldComparator>();
        for (SObject obj : sObjects) {
            comparators.add(new DateTypeFieldComparator(obj, fieldName, sortOrder));
        }
        comparators.sort();

        Integer rank = 0;
        DateTime previousValue = null;
        for (DateTypeFieldComparator comparator : comparators) {
            SObject obj = comparator.obj;
            DateTime currentValue = (DateTime) obj.get(fieldName);
            
            if (currentValue == null) {
                rank = 0;
            } else if (previousValue == null || !currentValue.equals(previousValue)) {
                rank++;
            }
            previousValue = currentValue;

            Decimal weightedScore = rank * weight;
            if (!scoredMap.containsKey(obj.Id)) {
                scoredMap.put(obj.Id, new List<Decimal>());
            }
            scoredMap.get(obj.Id).add(weightedScore);
        }
    }

    public static List<ApexWrapper> scoreDuplicates(List<SObject> duplicateSObjects, String sobjectType, List<Map<String,String>> fieldToWeightage, Integer numberOfFields) {

        Map<Id, List<Decimal>> scoredMap = new Map<Id, List<Decimal>>();
        Schema.SObjectType myobjectSchema = Schema.getGlobalDescribe().get(sobjectType);
        Map<String, Schema.SObjectField> fieldMap = myobjectSchema.getDescribe().fields.getMap();

        List<String> fields = new List<String>();
        for (Map<String, String> fieldWeightage : fieldToWeightage) {
            fields.add(fieldWeightage.get('APIName'));
        }

        Map<String, String> fieldWeightageMap = new Map<String, String>();
        Schema.DisplayType fielddataType;
        for (String fieldName : fields) {
            fielddataType = fieldMap.get(fieldName).getDescribe().getType();
            for (Map<String, String> m : fieldToWeightage) {
                if (m.get('APIName') == fieldName) {
                    fieldWeightageMap = m;
                    break;
                }
            }

            Integer weight = Integer.valueOf(fieldWeightageMap.get('Weightage'));
            String sortOrder = fieldWeightageMap.get('SortingOrder');

            switch on fielddataType {
                when String, TextArea, Url, Email, Phone, EncryptedString, Picklist {
                    for (SObject obj : duplicateSObjects) {
                        Integer score = scoreString((String) obj.get(fieldName));
                        if (!scoredMap.containsKey(obj.Id)) {
                            scoredMap.put(obj.Id, new List<Decimal>());
                        }
                        scoredMap.get(obj.Id).add(score * weight);
                    }
                }
                when Boolean {
                    for (SObject obj : duplicateSObjects) {
                        Integer score = scoreBoolean((Boolean) obj.get(fieldName));
                        if (!scoredMap.containsKey(obj.Id)) {
                            scoredMap.put(obj.Id, new List<Decimal>());
                        }
                        scoredMap.get(obj.Id).add(score * weight);
                    }
                }
                when Integer, Long, Double, Percent, Currency {
                    scoreNumber(duplicateSObjects,fieldName, weight, scoredMap, sortOrder);
                }
                when Date, Datetime, Time {
                    scoreDateTime(duplicateSObjects,fieldName, weight, scoredMap, sortOrder);
                }
            }
        }


        for(Id accountId : scoredMap.keySet()) {
            List<Decimal> scores = scoredMap.get(accountId);
            
            Decimal totalWeightedScore = 0;
            for(Integer i = 0; i < numberOfFields; i++) {
                totalWeightedScore += scores[i];
            }
            
            scoredMap.get(accountId).add(totalWeightedScore);
        }

        Decimal highestTotalScore = 0;
        for (List<Decimal> scores : scoredMap.values()) {
            if (scores[numberOfFields] > highestTotalScore) {
                highestTotalScore = scores[numberOfFields];
            }
        }

        // finding all the accounts with the max score
        Map<Id, List<Decimal>> maxScores = new Map<Id, List<Decimal>>();
        for (Id id : scoredMap.keySet()) {
            if (scoredMap.get(id)[numberOfFields] == highestTotalScore) {
                Decimal[] max = scoredMap.get(id);
                maxScores.put(id, max);
            }
        }
        // this is to iterate through all the accounts with the highest total score, only if there are 2 or more such accounts.
        // We first compare the score for the first field because it has the highest weightage.
        // If there is a tie, we go to the second field and then the third field if there is still a tie.
        // The account with the highest score in the highest possible weighted field gets its total scored increased by one.
        if (maxScores.size() > 1) {

            Id highestId = new List<Id>(maxScores.keySet())[0];
            // Iterate through the IDs and compare the scores
            for (Id id : maxScores.keySet()) {
                Decimal[] scores = maxScores.get(id);
            
                // Check if the current scores are higher than the highest scores
                if (isHigher(scores, highestId, numberOfFields, maxScores)) {
                    highestId = id;   
                }
            }

            // Increment the total score of the winning account by 1
            Decimal[] scores = scoredMap.get(highestId);
            scores[numberOfFields] += 1;
            scoredMap.put(highestId, scores);

            highestTotalScore +=1;
        }

        // final object to be returned, which is of the form <accountRecord, totalScore>.
        // The account record is fetched from the duplicateAccounts list of accounts.
        List<ApexWrapper> finalScore = new List<ApexWrapper>();
        
        // the scores are normalized by dividing by the highest total score and multiplying by 10.
        // this gives a final total score from 0-10 for each account.
        for (Id accountId: scoredMap.keySet()) {
            List<Decimal> scores=scoredMap.get(accountId);
            if (highestTotalScore > 0) {
                scores[numberOfFields] *= 10;
                scores[numberOfFields] /= highestTotalScore;
            }
            else {
                scores[numberOfFields] = 10;
            }

            // this is to find the account record by the accountId in the duplicateAccounts list
            SObject accountRecord = null;
            for (SObject acc : duplicateSObjects) {
            if (acc.Id == accountId) {
                accountRecord = acc;
                break;
            }
            }

            finalScore.add(new ApexWrapper(accountRecord, scores[numberOfFields].setScale(2)));
        }

        return finalScore;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isHigher(Decimal[] currentScores, Id highestId, Integer numberOfFields, Map<Id, List<Decimal>> maxScores) {
        for (Integer i = 0; i < numberOfFields; i++) {
            if (currentScores[i] > maxScores.get(highestId)[i]) {
                return true;
            } else if (currentScores[i] < maxScores.get(highestId)[i]) {
                return false;
            }
        }
        return false; // If all scores are equal
    }

    
    // Method to fetch and organize duplicate record data for a specific processed CSV
    @AuraEnabled
    public static List<GroupedAccount> getGroupedAccountDataFromExcel(List<Map<String, Object>> rawData) {
        List<GroupedAccount> groupedAccounts = new List<GroupedAccount>();
        List<String> allAccountIds = new List<String>();
        Map<Decimal, List<SObject>> setIdToAccountsMap = new Map<Decimal, List<SObject>>();
    
        for (Map<String, Object> dataMap : rawData) {
            Decimal id = (Decimal)dataMap.get('id');
            List<Object> sfids = (List<Object>)dataMap.get('sfids');
            
            // if (id == (count+start)) {
                // Add each sfid to the result list
                for (Object sfid : sfids) {
                    allAccountIds.add((String)sfid);
                }
        }

        String firstId = allAccountIds[0];
        Id firstSObjectId = Id.valueOf(firstId);

        Schema.SObjectType sObjectType = firstSObjectId.getSObjectType();
        Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
        
        String sObjectTypeName = describeResult.getName();

        // Get all fields for the Account object
        Map<String, Schema.SObjectField> accountFieldsMap = describeResult.fields.getMap();
        List<String> accountFields = new List<String>(accountFieldsMap.keySet());

        // Construct the SOQL query dynamically
        String soqlQuery = 'SELECT ';
        soqlQuery += String.join(accountFields, ', ');
        soqlQuery += ' FROM ';
        soqlQuery += sObjectTypeName;
        soqlQuery += ' WHERE Id IN :allAccountIds';

        // Execute the SOQL query
        List<SObject> allAccounts = Database.query(soqlQuery);
        
        for (Map<String, Object> dataMap : rawData) {
            Decimal setId = (Decimal)dataMap.get('id');
            List<Object> sfids = (List<Object>)dataMap.get('sfids');
            List<SObject> accountsForSet = new List<SObject>();
            for (Object sfid : sfids) {
                for (SObject acc : allAccounts) {
                    if (acc.Id == (String)sfid) {
                        accountsForSet.add(acc);
                        break;
                    }
                }
            }
            setIdToAccountsMap.put(setId, accountsForSet);
        }

        List<Decimal> keys = new List<Decimal>(setIdToAccountsMap.keySet());
        keys.sort(); // Sort the keys in ascending order
        for (Decimal key : keys) {
            Map<Id, Decimal> accountScores = new Map<Id, Decimal>();
            Map<Decimal, Id> reversedAccountScores = new Map<Decimal, Id>();
            List<SObject> duplicateAccounts = setIdToAccountsMap.get(key);
            String groupName = '';
            String selectedId = '';
            
            List<ApexWrapper> finalScore = new List<ApexWrapper>();
            
            if (duplicateAccounts.size() > 1) {
                if(sObjectTypeName == 'Account') {
                    //finalScore = scoreDuplicateAccounts(duplicateAccounts);
                }
                else if(sObjectTypeName == 'Contact') {
                    // finalScore = scoreDuplicateContacts(duplicateAccounts);
                }
                else if(sObjectTypeName == 'Lead') {
                    // finalScore = scoreDuplicateLeads(duplicateAccounts);
                }
            }
            else {
                continue;
            }
            for (ApexWrapper score : finalScore) {
                if (sObjectTypeName == 'Account') {
                    Account account = (Account)score.accountRecord;
                    Id accountId = (Id)account.Id;
                
                    Decimal totalScore = score.totalScore;

                    if (totalScore == 10) {
                        groupName = (String)account.Name;
                        selectedId = (String)account.Id;       
                    } 
                
                    accountScores.put(accountId, totalScore);
                    while (reversedAccountScores.containsKey(totalScore)) {
                        totalScore += 0.001;
                    }
                    reversedAccountScores.put(totalScore, accountId);
                }
                else if (sObjectTypeName == 'Contact') {
                    Contact account = (Contact)score.accountRecord;
                    Id accountId = (Id)account.Id;
                
                    Decimal totalScore = score.totalScore;

                    if (totalScore == 10) {
                        groupName = (String)account.Name;
                        selectedId = (String)account.Id;       
                    } 
                
                    accountScores.put(accountId, totalScore);
                    while (reversedAccountScores.containsKey(totalScore)) {
                        totalScore += 0.001;
                    }
                    reversedAccountScores.put(totalScore, accountId);
                }
                else if (sObjectTypeName == 'Lead') {
                    Lead account = (Lead)score.accountRecord;
                    Id accountId = (Id)account.Id;
                
                    Decimal totalScore = score.totalScore;

                    if (totalScore == 10) {
                        groupName = (String)account.Name;
                        selectedId = (String)account.Id;       
                    } 
                
                    accountScores.put(accountId, totalScore);
                    while (reversedAccountScores.containsKey(totalScore)) {
                        totalScore += 0.001;
                    }
                    reversedAccountScores.put(totalScore, accountId);
                }
            }
            
            List<Decimal> scoresList = new List<Decimal>(reversedAccountScores.keySet());
            scoresList.sort();

            List<Decimal> reversedList = new List<Decimal>();
            for(Integer i = scoresList.size() - 1; i >= 0; i--) {
                reversedList.add(scoresList[i]);
            }

            List<SObject> duplicateAccountsForView =  new List<SObject>();
            for(Decimal score : reversedList) {
                Id accountId = reversedAccountScores.get(score);

                for(SObject acc : duplicateAccounts) {
                    if(acc.Id == accountId) {
                        duplicateAccountsForView.add(acc);
                        break;
                    }
                }
            }

            GroupedAccount groupedAccount = new GroupedAccount(String.valueOf(key), groupName, duplicateAccountsForView.size(), duplicateAccountsForView, accountScores, selectedId, false);
            groupedAccounts.add(groupedAccount);
        }
        
        System.debug(Limits.getHeapSize() + ' / ' + Limits.getLimitHeapSize());
        
        return groupedAccounts;
    }

    public class ObjectMetadataWrapper {
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}
        @AuraEnabled public Boolean recordTypeFiltering {get; set;}
    
        // Constructor
        public ObjectMetadataWrapper(String label, String value, Boolean recordTypeFiltering) {
            this.label = label;
            this.value = value;
            this.recordTypeFiltering = recordTypeFiltering;
        }
    }

    @AuraEnabled (cacheable=true)
    public static List<ObjectMetadataWrapper> getObjectAndReqdRecordType(){
        try {
            List<Object_Selector_Metadata__mdt> scoringMetadata = [
                SELECT Object_Label__c, Object_API_Name__c, Has_Record_Type_Filtering__c 
                FROM Object_Selector_Metadata__mdt
            ];

            Set<ObjectMetadataWrapper> objectAndReqdRecordType = new Set<ObjectMetadataWrapper>();
            for (Object_Selector_Metadata__mdt metadataItem : scoringMetadata) {
                objectAndReqdRecordType.add(new ObjectMetadataWrapper(
                    metadataItem.Object_Label__c, 
                    metadataItem.Object_API_Name__c, 
                    metadataItem.Has_Record_Type_Filtering__c
                ));
            }
            List<ObjectMetadataWrapper> finalObjectAndReqdRecordType = new List<ObjectMetadataWrapper>(objectAndReqdRecordType);
            System.debug('objectAndReqdRecordType - ' + finalObjectAndReqdRecordType);
            return finalObjectAndReqdRecordType;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    

    @AuraEnabled
    public static string getSObjectType(String firstId){
        try {
            Id firstSObjectId = Id.valueOf(firstId);
            Schema.SObjectType sObjectType = firstSObjectId.getSObjectType();
            Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
            
            
            String sObjectTypeName = describeResult.getName();
            return sObjectTypeName;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String,String> getDuplicateJobDetails(String jobId){
        try {
            Map<String,String> jobDetails = new Map<String,String>();

            DuplicateJobMatchingRule djmr = [SELECT Id, MatchingRuleBooleanFilter,DuplicateJobMatchRuleDefId,DuplicateJobMatchRuleDef.MatchingRuleId FROM DuplicateJobMatchingRule where DuplicateJobId =: jobId LIMIT 1];
            String matchingRuleId = djmr.DuplicateJobMatchRuleDef.MatchingRuleId;

            jobDetails.put('matchingRule', djmr.MatchingRuleBooleanFilter);
            
            List<DuplicateJobMatchingRuleDefinition> djmrdList = [SELECT DuplicateJobDefinitionId FROM DuplicateJobMatchingRuleDefinition WHERE MatchingRuleId =: matchingRuleId];
            List<String> djdIdList = new List<String>();
            for (DuplicateJobMatchingRuleDefinition djmrd : djmrdList) {
                djdIdList.add(djmrd.DuplicateJobDefinitionId);
            }
            DateTime latestDate = [SELECT EndDateTime FROM DuplicateJob WHERE DuplicateJobDefinitionId IN :djdIdList AND DuplicateJobStatus = 'Completed' ORDER BY EndDateTime DESC LIMIT 1].EndDateTime;
            jobDetails.put('latestDate', String.valueOf(latestDate));
            
            List<DuplicateRecordSet> drsList = [ 
                SELECT Id, ParentId, RecordCount
                FROM DuplicateRecordSet 
                WHERE ParentId = :jobId
                AND RecordCount > 1
                ORDER BY Id ASC
            ];
            jobDetails.put('finalParentId',drsList[drsList.size()-1].Id);

            return jobDetails;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Map<String,String>> getComboboxOptions(String sobjectName){
        try {
            List<DuplicateJob> duplicateJobs = [SELECT Id, Name, DuplicateJobDefinitionId, DuplicateJobDefinition.SobjectType, DuplicateJobStatus FROM DuplicateJob WHERE DuplicateJobDefinition.SobjectType = :sobjectName AND DuplicateJobStatus = 'Completed'];

            List<Map<String,String>> options = new List<Map<String,String>>();
            for(DuplicateJob duplicateJob : duplicateJobs) {
                Map<String, String> option = new Map<String, String>();
                option.put('label', duplicateJob.Name);
                option.put('value', duplicateJob.Id);
                option.put('definitionId',duplicateJob.DuplicateJobDefinitionId);
                options.add(option);
            }
            return options;
        }
        catch (Exception ex) {
            Log4SF.logMessage('DuplicateJobController', 'getComboboxOptions', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
            return null;
        }
    }

    @AuraEnabled
    public static List<String> getDuplicateJobStatus(){
        try {
            List<String> inProgressDefinitions = new List<String>();
            List<DuplicateJob> duplicateJobs = [SELECT Id, DuplicateJobStatus, DuplicateJobDefinitionId FROM DuplicateJob WHERE DuplicateJobStatus = 'InProgress'];
            for (DuplicateJob job : duplicateJobs) {
                inProgressDefinitions.add(job.DuplicateJobDefinitionId);
            }
            return inProgressDefinitions;
        }
        catch (Exception ex) {
            Log4SF.logMessage('DuplicateJobController', 'getDuplicateJobStatus', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
            return null;
        }
    }

    @AuraEnabled
    public static void runMergeFromBatch(String duplicateJobId, String sobjectType, String recordType){
        try {
            BatchMerge bm = new BatchMerge(duplicateJobId, sobjectType, recordType);
            Database.executeBatch(bm, 200);
        } catch (Exception e) {             
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getCurrentDateTime(){
        System.debug(String.valueOf(DateTime.now()));
        return String.valueOf(DateTime.now());
    }

    @AuraEnabled
    public static void sendDownloadEmail(String duplicateJobId, String sobjectType, String recordType){
        BatchDownload batch = new BatchDownload(duplicateJobId, sobjectType, recordType);
        if (!Test.isRunningTest()){
            Database.executeBatch(batch, 200);
        }
    }
    
    @AuraEnabled
    public static List<String> findNextParentId(String duplicateRuleJobId) {
        String query = 'SELECT Id FROM DuplicateRecordSet WHERE ParentId = :duplicateRuleJobId AND RecordCount > 1 ORDER BY Id ASC';
        if (Test.isRunningTest()) {
            query += ' LIMIT 500';
        }
        List<DuplicateRecordSet> drsList = Database.query(query);
        List<String> drsIds = new List<String>();
        for (DuplicateRecordSet drs : drsList) {
            drsIds.add(drs.Id);
        }
        return drsIds;
    }

    @AuraEnabled
    public static List<GroupedAccount> getGroupedAccountData(String duplicateRuleJobId, Integer pageSize, String lastRetrievedParentId, String sobjectType, String recordTypeId) {
		
        String rawDRSNames = [SELECT DRS_Names__c FROM DRS_Not_For_Merge__mdt][0].DRS_Names__c;
		List<String> drsNames = rawDRSNames.split('\n');
		List<String> finalDRSNames = new List<String>();
		for (String drsName : drsNames) {
    		finalDRSNames.add(drsName.trim());
		}

        String objectMdtQuery = 'SELECT Scoring_Needed__c, Field_API_Name__c, Weightage__c, Sort_order__c from Object_Selector_Metadata__mdt WHERE Object_API_Name__c = \'';
        objectMdtQuery += sobjectType;
        objectMdtQuery += '\'';
        if (recordTypeId != null) {
            objectMdtQuery += ' AND Record_Type_API_Name__c = \'';
            objectMdtQuery += recordTypeId;
            objectMdtQuery += '\'';
        }
        objectMdtQuery += ' ORDER BY Weightage__c DESC';
        System.debug('objectMdtQuery@@@' +  objectMdtQuery);
        List<Object_Selector_Metadata__mdt> objectMetadata = Database.query(objectMdtQuery);
        System.debug('objectMetadata@@@' + objectMetadata);

        Boolean scoringNeeded = objectMetadata[0].Scoring_Needed__c;
        Integer numberOfFields = objectMetadata.size();
        List<Map<String, String>> fieldToWeightage = new List<Map<String, String>>();
        for (Object_Selector_Metadata__mdt objectMetadataItem : objectMetadata) {
            Map<String, String> m = new Map<String, String>();
            m.put('APIName',objectMetadataItem.Field_API_Name__c);
            m.put('Weightage',String.valueOf(objectMetadataItem.Weightage__c));
            m.put('SortingOrder',objectMetadataItem.Sort_order__c);
            fieldToWeightage.add(m);
        }

        List<GroupedAccount> groupedAccounts = new List<GroupedAccount>();
        
        List<DuplicateRecordSet> duplicateRecordSets = [
            SELECT Id, ParentId, Name, RecordCount
            FROM DuplicateRecordSet 
            WHERE ParentId = :duplicateRuleJobId
            AND Id > :lastRetrievedParentId
            AND RecordCount > 1
            ORDER BY Id ASC
            LIMIT :pageSize
        ];
        
        System.debug(duplicateRecordSets.size());
        
        // Map to store RecordIds by DuplicateRecordSetId
        Map<Id, List<Id>> recordSetIdToRecordIdsMap = new Map<Id, List<Id>>();

        List<Id> duplicateRecordSetIds = new List<Id>();
        for (DuplicateRecordSet duplicateRecordSet : duplicateRecordSets) {
            duplicateRecordSetIds.add(duplicateRecordSet.Id);
            recordSetIdToRecordIdsMap.put(duplicateRecordSet.Id, new List<Id>());
        }

        for (DuplicateRecordItem item : [SELECT Id, RecordId, DuplicateRecordSetId, Item_Merged__c FROM DuplicateRecordItem WHERE DuplicateRecordSetId IN :duplicateRecordSetIds AND Item_Merged__c = false]) {
            recordSetIdToRecordIdsMap.get(item.DuplicateRecordSetId).add(item.RecordId);
        }

        system.debug('@@recordSetIdToRecordIdsMap:: '+ recordSetIdToRecordIdsMap);
        
        // Flatten the list of RecordIds
        List<Id> allRecordIds = new List<Id>();
        for (List<Id> recordIds : recordSetIdToRecordIdsMap.values()) {
            allRecordIds.addAll(recordIds);
        }
        

        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType sObjectSchemaType = globalDescribeMap.get(sobjectType);
        Schema.DescribeSObjectResult describeResult = sObjectSchemaType.getDescribe();

        // Get all fields for the Account object
        Map<String, Schema.SObjectField> accountFieldsMap = describeResult.fields.getMap();
        List<String> accountFields = new List<String>(accountFieldsMap.keySet());

        // Construct the SOQL query dynamically
        String soqlQuery = 'SELECT ';
        soqlQuery += String.join(accountFields, ', ');
        soqlQuery += ', (SELECT DuplicateRecordSet.Name FROM DuplicateRecordItems WHERE DuplicateRecordSet.ParentId = :duplicateRuleJobId)';
        if (sobjectType == 'Account') {
            soqlQuery += ', (SELECT Traffic_Id__c, ExportSystem_Name__c FROM Traffic_Id_Elements__r)';
            soqlQuery += ', (SELECT User.Name, TeamMemberRole, User.Sales_Office__c, User.Region__c FROM AccountTeamMembers WHERE (TeamMemberRole = \'Account Executive\' OR TeamMemberRole = \'Sales Manager\') AND User.Name != \'Boomi Integration User\' AND User.Name != \'B Integration User\')';
        }
        soqlQuery += ' FROM ';
        soqlQuery += sobjectType;
        soqlQuery += ' WHERE Id IN :allRecordIds';
        if (recordTypeId != null) {
            soqlQuery += ' AND RecordType.DeveloperName = \'' + recordTypeId + '\'';
        }
        System.debug('soqlQuery@@@@'+soqlQuery);
        // Execute the SOQL query
        List<SObject> allAccounts = Database.query(soqlQuery);
        System.debug(JSON.serialize(allRecordIds));
        
        // Map to store Account records by DuplicateRecordSetId
        Map<Id, List<SObject>> recordSetIdToAccountsMap = new Map<Id, List<SObject>>();
        for (Id recordSetId : recordSetIdToRecordIdsMap.keySet()) {
            recordSetIdToAccountsMap.put(recordSetId, new List<SObject>());
        }
        
        // Organize Account records by DuplicateRecordSetId
        for (SObject account : allAccounts) {
            for (Id recordSetId : recordSetIdToRecordIdsMap.keySet()) {
                if (recordSetIdToRecordIdsMap.get(recordSetId).contains(account.Id)) {
                    recordSetIdToAccountsMap.get(recordSetId).add(account);
                }
            }
        }
        System.debug('recordSetIdToAccountsMap@@@'+recordSetIdToAccountsMap);
        System.debug('scoringneeded' + scoringNeeded);
        // Create GroupedAccount objects
        for (DuplicateRecordSet duplicateRecordSet : duplicateRecordSets) {
            String groupName = '';
            String selectedId = '';
            List<SObject> duplicateAccounts = recordSetIdToAccountsMap.get(duplicateRecordSet.Id);
            System.debug('duplicateAccounts@@@' + duplicateAccounts);
            List<String> accountIds = new List<String>();
            List<ApexWrapper> finalScore = new List<ApexWrapper>();
            Map<Id, Decimal> accountScores = new Map<Id, Decimal>();
            Map<Decimal, Id> reversedAccountScores = new Map<Decimal, Id>();
            List<SObject> duplicateAccountsForView =  new List<SObject>();

            if (duplicateAccounts.size() > 1) {
                if (scoringNeeded) {
                    finalScore = scoreDuplicates(duplicateAccounts, sobjectType, fieldToWeightage, numberOfFields);
                }
                else {
                    finalScore = noScore(duplicateAccounts);
                }
            }
            else {
                continue;
            }
            for (ApexWrapper score : finalScore) {

                SObject account = score.accountRecord;
                Id accountId = account.Id;
                Decimal totalScore = score.totalScore;
                System.debug('account' + account);
                if (totalScore == 10) {
                    groupName = (String)account.get('Name');
                    selectedId = (String)account.Id;
                } 
            
                accountScores.put(accountId, totalScore);
                while (reversedAccountScores.containsKey(totalScore)) {
                    totalScore += 0.001;
                }
                reversedAccountScores.put(totalScore, accountId);
                
            }
            
            List<Decimal> scoresList = new List<Decimal>(reversedAccountScores.keySet());
            scoresList.sort();
            List<Decimal> reversedList = new List<Decimal>();
            for(Integer i = scoresList.size() - 1; i >= 0; i--) {
                reversedList.add(scoresList[i]);
            }

            for(Decimal score : reversedList) {
                Id accountId = reversedAccountScores.get(score);
                
                for(SObject acc : duplicateAccounts) {
                    if(acc.Id == accountId) {
                        duplicateAccountsForView.add(acc);
                        break;
                    }
                }
            }
            GroupedAccount groupedAccount = new GroupedAccount(String.valueOf(duplicateRecordSet.Id), groupName, duplicateAccountsForView.size(), duplicateAccountsForView, accountScores, selectedId, scoringNeeded);
            groupedAccounts.add(groupedAccount);
            System.debug(groupedAccount);
        }

        System.debug(Limits.getHeapSize() + ' / ' + Limits.getLimitHeapSize());
        
        return groupedAccounts;
    }

    

    @AuraEnabled
    public static List<Map<String, String>>  getRecordTypeMap(String sobjectType) {

        List<Map<String, String>> recordTypeList = new List<Map<String, String>>();
        String recordMdtQuery = 'SELECT Record_Type_Label__c, Record_Type_API_Name__c FROM Object_Selector_Metadata__mdt WHERE Object_API_Name__c = \'';
        recordMdtQuery += sobjectType;
        recordMdtQuery += '\'';

        System.debug('recordMdtQuery' + recordMdtQuery);

        List<Object_Selector_Metadata__mdt> recordMetadata = Database.query(recordMdtQuery);
        System.debug('recordMetadata'+recordMetadata);

        for (Object_Selector_Metadata__mdt rt : recordMetadata) {
            Map<String, String> recordTypeMap = new Map<String, String>();
            recordTypeMap.put('label', rt.Record_Type_Label__c);
            recordTypeMap.put('value', rt.Record_Type_API_Name__c);
            recordTypeList.add(recordTypeMap);
        }
        return recordTypeList;
    }

    @AuraEnabled
    public static void mergeDuplicates(String groupChangesString) {
        Map<String, Object> groupChange = (Map<String, Object>) JSON.deserializeUntyped(groupChangesString);

        String selectedId = (String) groupChange.get('selectedId');
        List<Object> childIds = (List<Object>) groupChange.get('childIds');

        groupChange.remove('selectedId');
        groupChange.remove('childIds');

        if (groupChange.containsKey('Projected_Segment_Name__c')) {
            groupChange.remove('Projected_Segment_Name__c');
        }

        List<String> childIdsAsString = new List<String>();
        for (Object id : childIds) {
            childIdsAsString.add((String) id);
        }

        Account selectedAccount = new Account(Id = selectedId);

        if (!groupChange.isEmpty()) {
            for (String field : groupChange.keySet()) {
                if (field != 'Complete_Billing_Address__c') {
                    selectedAccount.put(field, groupChange.get(field));
                } else {
                    String[] addressComponents = ((String) groupChange.get(field)).split(', ');

                    String street = addressComponents[0].trim();
                    selectedAccount.put('BillingStreet', street);

                    String city = addressComponents[1].trim();
                    selectedAccount.put('BillingCity', city);

                    String[] statePostalCode = addressComponents[2].trim().split(' ');

                    String state = '';
                    for (Integer i = 0; i < statePostalCode.size() - 1; i++) {
                        state += statePostalCode[i] + ' ';
                    }
                    state = state.trim();
                    selectedAccount.put('BillingState', state);

                    String postalCode = statePostalCode[statePostalCode.size() - 1].trim();
                    selectedAccount.put('BillingPostalCode', postalCode);

                    String country = addressComponents[3].trim();
                    selectedAccount.put('BillingCountry', country);
                }
            }
            try {
                Database.update(selectedAccount);
            } catch (DmlException e) {
                System.debug('Error updating account: ' + e.getMessage());
            }
        }

        List<Account_Bulk_Merge__c> landscapingRecords = new List<Account_Bulk_Merge__c>();

        for (String childId : childIdsAsString) {
            Account_Bulk_Merge__c landscapingRecord = new Account_Bulk_Merge__c();
            landscapingRecord.Parent_Account__c = selectedId;
            landscapingRecord.Child_Account__c = childId;
            landscapingRecord.is_Landscaping__c = true;
            landscapingRecords.add(landscapingRecord);
        }

        System.debug(JSON.serialize(landscapingRecords));
        System.debug(JSON.serialize(selectedAccount));
        
        try {
            Database.insert(landscapingRecords);
        } catch (DmlException e) {
            System.debug('Error inserting landscaping merge records: ' + e.getMessage());
        }
    
        AccountBulkMerge abm = new AccountBulkMerge();
        abm.isLandscaping = true;
        abm.landscapingRecords = new List<Account_Bulk_Merge__c>(landscapingRecords);
        System.debug('@@abm.landscapingRecords: '+abm.landscapingRecords);
        Database.executeBatch(abm, Integer.valueOf(System.Label.AccountMergeBatchSize));
    
    }

    @AuraEnabled
    public static String runJobAgain(String duplicateJobDefId){
            system.debug('duplicateJobDefId:: '+duplicateJobDefId);
            String matchingRuleStatus = [SELECT MatchingRule.RuleStatus FROM DuplicateJobMatchingRuleDefinition WHERE DuplicateJobDefinitionId =: duplicateJobDefId LIMIT 1][0].MatchingRule.RuleStatus;
            if (matchingRuleStatus == 'Inactive') {
                return 'Inactive job';
            }
            String endpoint = URL.getOrgDomainUrl().toExternalForm()  + '/services/data/v58.0/dedupe/jobs';
            System.debug('endpoint::::' + endpoint);
            if (!Test.isRunningTest()) {
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endpoint);
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                String sessionId = MetadataAPIUtility.getSessionId(Label.IntegrationUserName, Label.IntegrationUserNamePass);
                req.setHeader('Authorization', 'Bearer '+ sessionId);
                String requestBody = '{"duplicateJobDefId": "'+duplicateJobDefId+'"}';
                System.debug('requestBody::::' + requestBody);
                req.setBody(requestBody);
                System.debug(req.getHeader('Authorization'));
                System.debug(UserInfo.getOrganizationId().substring(0, 15) + ' ' + UserInfo.getSessionId().substring(15));
                System.debug(req.getBody());
                System.debug(req.getEndpoint());
                Http http = new Http();
                http.send(req);
            }
            return 'Pass';
            
    }

    @AuraEnabled
    public static void mergeAllDuplicates(List<String> groupChangesStringList) {
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        List<Account_Bulk_Merge__c> landscapingRecords = new List<Account_Bulk_Merge__c>();

        for (String groupChangesString : groupChangesStringList) {
            Map<String, Object> groupChange = (Map<String, Object>) JSON.deserializeUntyped(groupChangesString);
            
            String selectedId = (String) groupChange.get('selectedId');
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
                    if (field != 'Complete_Billing_Address__c') {
                        selectedAccount.put(field, groupChange.get(field));
                        hasUpdates = true;
                    } else {
                        String[] addressComponents = ((String) groupChange.get(field)).split(', ');

                        String street = addressComponents[0].trim();
                        selectedAccount.put('BillingStreet', street);

                        String city = addressComponents[1].trim();
                        selectedAccount.put('BillingCity', city);

                        String[] statePostalCode = addressComponents[2].trim().split(' ');

                        String state = '';
                        for (Integer i = 0; i < statePostalCode.size() - 1; i++) {
                            state += statePostalCode[i] + ' ';
                        }
                        state = state.trim();
                        selectedAccount.put('BillingState', state);

                        String postalCode = statePostalCode[statePostalCode.size() - 1].trim();
                        selectedAccount.put('BillingPostalCode', postalCode);

                        String country = addressComponents[3].trim();
                        selectedAccount.put('BillingCountry', country);

                    }
                    
                }
                hasUpdates = true;
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
                landscapingRecords.add(landscapingRecord);
            }
        }

        System.debug(JSON.serialize(landscapingRecords));
        System.debug(JSON.serialize(accountsToUpdate));

        if (!accountsToUpdate.isEmpty()) {
            try {
                Database.SaveResult[] updateResults = Database.update(accountsToUpdate.values());
                for (Database.SaveResult result : updateResults) {
                    if (!result.isSuccess()) {
                        for (Database.Error error : result.getErrors()) {
                            System.debug('Error updating account: ' + error.getStatusCode() + ' - ' + error.getMessage());
                        }
                    }
                }
            } catch (DmlException e) {
                System.debug('Error updating accounts: ' + e.getMessage());
            }
        }

        
        try {
            Database.insert(landscapingRecords);
        } catch (DmlException e) {
            System.debug('Error inserting landscaping merge records: ' + e.getMessage());
        }
        

        AccountBulkMerge abm = new AccountBulkMerge();
        abm.isLandscaping = true;
        abm.landscapingRecords = new List<Account_Bulk_Merge__c>(landscapingRecords);
        System.debug('@@abm.landscapingRecords: '+abm.landscapingRecords);
        Database.executeBatch(abm, Integer.valueOf(System.Label.AccountMergeBatchSize));
    
    }


    @AuraEnabled
    public static Map<String, String> getFieldSetLabels(String fieldSetName, String sobjectType) {
        Map<String, String> fieldDetails = new Map<String, String>();
    
        try {
            // Get the Schema.SObjectType dynamically based on the sobjectType parameter
            Schema.SObjectType sObjectTypeDescribe = Schema.getGlobalDescribe().get(sobjectType);
    
            // Get the field set information dynamically
            Schema.FieldSet fieldSetInfo = sObjectTypeDescribe.getDescribe().fieldSets.getMap().get(fieldSetName);
            if (fieldSetInfo != null) {
                // Iterate through each field in the field set
                for (Schema.FieldSetMember field : fieldSetInfo.getFields()) {
                    fieldDetails.put(field.getFieldPath(), field.getLabel());
                }
            } else {
                System.debug('FieldSet not found: ' + fieldSetName);
            }
        } catch (Exception e) {
            // Handle exception if the sobjectType or fieldSetName is invalid
            System.debug('Exception: ' + e.getMessage());
        }
    
        return fieldDetails;
    }

    @AuraEnabled
    public static void updateMergedAccounts(List<String> accIdList) {
        if (!accIdList.isEmpty()) {
            List<DuplicateRecordItem> itemsToUpdate = [
                SELECT Id, Item_Merged__c
                FROM DuplicateRecordItem
                WHERE RecordId IN :accIdList
            ];
    
            // Update the Item_Merged__c field to true
            for (DuplicateRecordItem item : itemsToUpdate) {
                item.Item_Merged__c = true;
            }
    
            // Perform the update operation
            if (!itemsToUpdate.isEmpty()) {
                try {
                    Database.SaveResult[] updateResults = Database.update(itemsToUpdate);
                    for (Database.SaveResult result : updateResults) {
                        if (!result.isSuccess()) {
                            for (Database.Error error : result.getErrors()) {
                                System.debug('Error updating duplicate record items: ' + error.getStatusCode() + ' - ' + error.getMessage());
                            }
                        }
                    }
                } catch (DmlException e) {
                    System.debug('Error updating accounts: ' + e.getMessage());
                }
            }
        }
    }
    @AuraEnabled
    public static List<Landscaping_UI_Fields_Metadata__mdt> getUIFields(String sobjectType, String recordType){
        try {
            String mdtQuery = 'SELECT Field_Label__c, Field_API_Name__c, Field_Role__c, Accordion_Label__c, Accordion_Level__c, Display_Level__c FROM Landscaping_UI_Fields_Metadata__mdt WHERE Object_API_Name__c =:sobjectType';
            if (recordType != null) {
                mdtQuery += ' AND Record_Type_API_Name__c =:recordType';
            }
            mdtQuery += ' ORDER BY Accordion_Level__c, Display_Level__c';
            return Database.query(mdtQuery);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    //Batch process status
    @AuraEnabled
    public static AggregateResult getJobDetails(){
        try {
            // List<AsyncApexJob> asyncJobList = [SELECT Id, Status, JobItemsProcessed, TotalJobItems,
            //                                     NumberOfErrors FROM AsyncApexJob where Id =: jobId ];
            
            AggregateResult  asyncJob= [SELECT SUM(JobItemsProcessed), SUM(TotalJobItems) FROM AsyncApexJob where ApexClass.name ='AccountBulkMerge' and status!='Completed'];
            return asyncJob;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

   @AuraEnabled(cacheable=true)
   public static List<Not_Merged_Ids_for_Landscaping__mdt> getNotMergedIds(){
    try {
        List<Not_Merged_Ids_for_Landscaping__mdt> nmi = [select Id__c from Not_Merged_Ids_for_Landscaping__mdt];
        return nmi;
    } catch (Exception ex) {
        Log4SF.logMessage('DuplicateJobController', 'getNotMergedIds', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
        return null;
    }
   }

  
    @AuraEnabled
    public static Map<String,String> getTrafficIdFieldsForUI() {
        try {
            // Get the describe information for the Traffic_Id_Element__c object
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType sObjectType = schemaMap.get('Traffic_Id_Element__c');
            Map<String, Schema.SObjectField> fieldMap = sObjectType.getDescribe().fields.getMap();

            // List to hold field information
            Map<String, String> fieldsMap = new Map<String, String>();

            // Iterate through the field map
            for (String fieldName : fieldMap.keySet()) {
                Schema.SObjectField field = fieldMap.get(fieldName);
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                fieldsMap.put(fieldDescribe.getName(),fieldDescribe.getLabel());
            }
            return fieldsMap;
        }  
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void mergeAllDuplicateTrafficIdElements(List<String> groupChangesStringList) {
        try {
            Set<Id> parentIds = new Set<Id>();
            Map<Id, List<Id>> parentToChildIdsMap = new Map<Id, List<Id>>();
            List<Id> allChildIds = new List<Id>();

            for (String groupChangesString : groupChangesStringList) {
                Map<String, Object> groupChange = (Map<String, Object>) JSON.deserializeUntyped(groupChangesString);
                String selectedId = (String) groupChange.get('selectedId');
                List<Object> childIds = (List<Object>) groupChange.get('childIds');
                
                if (selectedId != null && !childIds.isEmpty()) {
                    Id parentId = (Id) selectedId;
                    parentIds.add(parentId);
                    
                    List<Id> childRecordIds = new List<Id>();
                    for (Object childId : childIds) {
                        childRecordIds.add((Id) childId);
                        allChildIds.add((Id) childId);
                    }
                    
                    parentToChildIdsMap.put(parentId, childRecordIds);
                }
            }

            List<Traffic_Id_Element__c> parentRecords = [SELECT Id FROM Traffic_Id_Element__c WHERE Id IN :parentIds];
            Map<Id, Traffic_Id_Element__c> parentRecordMap = new Map<Id, Traffic_Id_Element__c>(parentRecords);

            List<Revenue__c> accountTraffic = [SELECT Id, Account_Traffic_Id_Element__c FROM Revenue__c WHERE Account_Traffic_Id_Element__c IN :allChildIds];
            List<Revenue__c> userTraffic = [SELECT Id, User_Traffic_Id_Element__c FROM Revenue__c WHERE User_Traffic_Id_Element__c IN :allChildIds];

            Map<Id, Revenue__c> revenuesToUpdate = new Map<Id, Revenue__c>();
            
            for (Revenue__c revenue : accountTraffic) {
                for (Id parentId : parentToChildIdsMap.keySet()) {
                    if (parentToChildIdsMap.get(parentId).contains(revenue.Account_Traffic_Id_Element__c)) {
                        revenue.Account_Traffic_Id_Element__c = parentId;
                        revenuesToUpdate.put(revenue.Id, revenue);
                    }
                }
            }

            for (Revenue__c revenue : userTraffic) {
                for (Id parentId : parentToChildIdsMap.keySet()) {
                    if (parentToChildIdsMap.get(parentId).contains(revenue.User_Traffic_Id_Element__c)) {
                        if (revenuesToUpdate.containsKey(revenue.Id)) {
                            revenuesToUpdate.get(revenue.Id).User_Traffic_Id_Element__c = parentId;
                        } else {
                            revenue.User_Traffic_Id_Element__c = parentId;
                            revenuesToUpdate.put(revenue.Id, revenue);
                        }
                    }
                }
            }
            
            update revenuesToUpdate.values();
            
            delete [SELECT Id FROM Traffic_Id_Element__c WHERE Id IN :allChildIds];
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void mergeDuplicateTrafficIdElements(String groupChangesString) {
        
        Map<String, Object> groupChange = (Map<String, Object>) JSON.deserializeUntyped(groupChangesString);

        String selectedId = (String) groupChange.get('selectedId');
        List<Object> childIds = (List<Object>) groupChange.get('childIds');
            
        if (selectedId != null && !childIds.isEmpty()) {
            List<Id> childRecordIds = new List<Id>();
            for (Object childId : childIds) {
                childRecordIds.add((Id) childId);
            }
            Traffic_Id_Element__c parentTE = [SELECT Id FROM Traffic_Id_Element__c WHERE Id =: selectedId LIMIT 1][0];

            List<Revenue__c> accountTraffic = [SELECT Id, Account_Traffic_Id_Element__c FROM Revenue__c WHERE Account_Traffic_Id_Element__c IN :childRecordIds];
            List<Revenue__c> userTraffic = [SELECT Id, User_Traffic_Id_Element__c FROM Revenue__c WHERE User_Traffic_Id_Element__c IN :childRecordIds];

            Map<Id, Revenue__c> revenuesToUpdate = new Map<Id, Revenue__c>();
            
            for (Revenue__c revenue : accountTraffic) {
                revenue.Account_Traffic_Id_Element__c = selectedId;
                revenuesToUpdate.put(revenue.Id, revenue);
            }

            for (Revenue__c revenue : userTraffic) {
                if (revenuesToUpdate.containsKey(revenue.Id)) {
                    revenuesToUpdate.get(revenue.Id).User_Traffic_Id_Element__c = selectedId;
                } else {
                    revenue.User_Traffic_Id_Element__c = selectedId;
                    revenuesToUpdate.put(revenue.Id, revenue);
                }
            }
            update revenuesToUpdate.values();

            delete [SELECT Id FROM Traffic_Id_Element__c WHERE Id IN :childRecordIds];
        }
        
    
    
    }
}