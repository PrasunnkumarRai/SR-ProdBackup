global class AccountMergeRetryBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext context) {
        String query = '';
        query = 'Select Id, name, isRowLock__c,Account__c,Merged_Account_ID__c, Account__r.Id from Account_Merge_Log__c where isRowLock__c = True LIMIT 20';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account_Merge_Log__c> scope) {
        List<Account_Merge_Log__c> logList = new List<Account_Merge_Log__c>();
            for(Account_Merge_Log__c log: scope){
                try{
                    Database.MergeResult mergeResult = Database.merge(log.Account__r, Id.valueOf(log.Merged_Account_ID__c), true);
                    if (mergeResult.isSuccess()) {
                        System.debug('mergeResult.isSuccess():'+ mergeResult.isSuccess());
                        log.isRowLock__c = false;
                        logList.add(log);
                    }

                }catch(Exception e){
                    Log4SF.logMessage('AccountMergeRetry', 'mergeRetryAccounts', e.getMessage(), e, UserInfo.getUserId(), log.Account__r.Id + ';' + log.Merged_Account_ID__c);
                }
           }
           update logList;
    }

    global void finish(Database.BatchableContext BC) {
    }
}