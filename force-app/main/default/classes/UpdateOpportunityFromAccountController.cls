public class UpdateOpportunityFromAccountController {

    @AuraEnabled
    public static List<Account> getAccountList(){
        String query = 'SELECT Id, Name,Type,Account_Tim_Name__c,AE__c,Active__c,UpdateOppFromAccount__c,Total_Gross_Amount__c,BillingAddress FROM Account WHERE (RecordType.DeveloperName=\'Rep_Firm\' and UpdateOppFromAccount__c = \'' + AccountUtils.ACC_REC_TYPE_AGENCY_TO_REP_FIRM + '\') OR ' + '(RecordType.DeveloperName=\'Agency_Account\' and UpdateOppFromAccount__c = \'' + AccountUtils.ACC_REC_TYPE_REP_FIRM_TO_AGENCY + '\')';
        List<Account> accountList = Database.query(query);
        Set<Id> agencyAccIdSet = new Set<Id>();
        Set<Id> repFirmAccIdSet = new Set<Id>();
        for (Account acc : accountList) {
            if (acc.UpdateOppFromAccount__c == AccountUtils.ACC_REC_TYPE_AGENCY_TO_REP_FIRM) agencyAccIdSet.add(acc.Id);
            if (acc.UpdateOppFromAccount__c == AccountUtils.ACC_REC_TYPE_REP_FIRM_TO_AGENCY) repFirmAccIdSet.add(acc.Id);
        }
        Map<Id,Integer> agencyOppCountMap = fetchOppCount(agencyAccIdSet, 'agency_account__c');
        Map<Id,Integer> repFirmOppCountMap = fetchOppCount(repFirmAccIdSet, 'rep_firm__c');
        for (Account acc : accountList) {
            if (acc.UpdateOppFromAccount__c == AccountUtils.ACC_REC_TYPE_AGENCY_TO_REP_FIRM) {
                acc.Type = (agencyOppCountMap.containsKey(acc.Id)) ? String.valueOf(agencyOppCountMap.get(acc.Id)) : '0';
            }
            else if (acc.UpdateOppFromAccount__c == AccountUtils.ACC_REC_TYPE_REP_FIRM_TO_AGENCY) {
                acc.Type = (repFirmOppCountMap.containsKey(acc.Id)) ? String.valueOf(repFirmOppCountMap.get(acc.Id)) : '0';
            }
        }
        return accountList;
    }

    public static Map<Id,Integer> fetchOppCount(Set<Id> accountIdSet, String accType) {
        Map<Id,Integer> oppCountMap = new Map<Id,Integer>();
        String query = 'SELECT count(Id),' + accType + ' FROM Opportunity WHERE ' + accType + ' IN: accountIdSet GROUP BY ' + accType;
        System.debug('query : ' + query);
        for (AggregateResult agg : Database.query(query)) {
            oppCountMap.put((Id) agg.get(accType), Integer.valueOf(agg.get('expr0')));
        }
        System.debug('oppCountMap : ' + oppCountMap);
        return oppCountMap;
    }
    
    @AuraEnabled
    public static Boolean isBatchRunning(){
        List<AsyncApexJob> apexJobList = [SELECT id,status FROM AsyncApexJob WHERE (ApexClass.name= 'UpdateOpportunityFromAccountBatch') and (status='Processing' or status='Preparing' or status='Queued')];
        if(apexJobList == NULL || apexJobList.size() == 0 ){
            return true;
        }
        return false;
    }
    @AuraEnabled
    public static Id runBatchApex(){
        Id batchJobId = Database.executeBatch(new UpdateOpportunityFromAccountBatch(), 1);
        return batchJobId;
    }
    
    @AuraEnabled
    public static AsyncApexJob getBatchStatus(Id jobId){
        //jobId = (Id)'707m000000p6A6bAAE';
        List<AsyncApexJob> jobResults = [SELECT id,Status,ExtendedStatus FROM AsyncApexJob WHERE id=:jobId];
        return (NULL != jobResults && !jobResults.isEmpty()) ? jobResults[0] : NULL;
    }

}