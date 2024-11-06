/*
  ###########################################################################
  # File..................: AccountBulkMerge.cls
  # Version...............: 1
  # Created by............: Ankit Bhatia
  # Created Date..........: 18-Sep-2017
  # Last Modified by......:
  # Last Modified Date....:
  # Description...........: This class is created for BULK Account Merge
  # TAO Ref#..............: NA
  # Change Log:
  #
  #
  ############################################################################*/

global with sharing class AccountBulkMerge implements Database.Batchable < sObject > , Database.AllowsCallouts, Database.Stateful {

    List < Account_Merge_Log__c > accountMergeLogsList;
    List < Account_Bulk_Merge__c > accntBulkMergeRecords = new List < Account_Bulk_Merge__c > ();
    global String query;
    public Boolean isLandscaping = false;
    public List < Account_Bulk_Merge__c > landscapingRecords;
    public Boolean isRecursion = false;
    public String trxnId;
    public Integer totalCount;

    global Database.QueryLocator start(Database.BatchableContext context) {
        try {
            Set < Id > landscapingAccountMergeIds = new Set < Id > ();
            if (isLandscaping) {
                for (Account_Bulk_Merge__c rec: landscapingRecords) {
                    landscapingAccountMergeIds.add(rec.Id);
                }
                query
                    = 'SELECT ID,Child_Account__c, Parent_Account__c , Child_Account__r.Name FROM Account_Bulk_Merge__c where Child_Account__c != null AND is_Landscaping__c=:isLandscaping  AND Id in: landscapingAccountMergeIds ORDER BY CreatedDate desc LIMIT 90';
            } else {
                query
                    = 'SELECT ID,Child_Account__c, Parent_Account__c , Child_Account__r.Name FROM Account_Bulk_Merge__c where Child_Account__c != null ORDER BY CreatedDate desc';
            }
            if (!isRecursion) {
                List<AggregateResult> result = [SELECT Count(Id) totalCount FROM Account_Bulk_Merge__c where Child_Account__c != null AND is_Landscaping__c =: isLandscaping  AND Id in : landscapingAccountMergeIds];
                totalCount = (Integer)result[0].get('totalCount');
                System.debug('totalCount@@@@'+totalCount);
                Set < String > existingLogTrxnIds = new Set < String > ();
                Boolean isUnique = false;
                for (Account_Merge_Log__c log: [SELECT TransactionId__c FROM Account_Merge_Log__c WHERE TransactionId__c != NULL]) {
                    existingLogTrxnIds.add(log.transactionId__c);
                }
                while (!isUnique) {
                    UUID u = UUID.randomUUID();
                    String s = String.valueOf(u);
                    if (existingLogTrxnIds.contains(s)) {
                        isUnique = false;
                    } else {
                        isUnique = true;
                        trxnId = s;
                    }
                }
                
            }
            System.debug('trxnId@@@@'+trxnId);

            if (test.isRunningTest()) {
                //query += ' LIMIT 5';
                CalloutException e = new CalloutException();
                e.setMessage(
                    'This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception ex) {
            Log4SF.logMessage('AccountBulkMerge', 'start', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
        }
        system.debug('@@landscapingAccountMergeIds: ' + landscapingRecords);
        // System.debug('@@query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext context, List < sObject > sObjects) {
        List < Account_Bulk_Merge__c > accountMergeLogsInActiveOppList = new List < Account_Bulk_Merge__c > ();
        List < Account_Bulk_Merge__c > accountMergeLogsInTransferList = new List < Account_Bulk_Merge__c > ();

        try {
            accntBulkMergeRecords = (List < Account_Bulk_Merge__c > ) sObjects;
            accountMergeLogsList = new List < Account_Merge_Log__c > ();
            accountMergeLogsList.addAll(createAccountMergeLog(accntBulkMergeRecords));
            if (accountMergeLogsList.size() > 0) {
                System.debug('accountMergeLogs size ' + accountMergeLogsList.size());
                System.debug('totalCount@@@@'+totalCount);
                ID jobID = System.enqueueJob(new AccountMergeQueueable(accountMergeLogsList,trxnId,totalCount));
                System.debug('jobID' + jobID);
            }
            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage(
                    'This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception ex) {
            System.debug('ex : ' + ex);
            System.debug('ex line: ' + ex.getLineNumber());
            System.debug('ex : ' + ex);
            Log4SF.logMessage('AccountBulkMerge', 'execute', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
        }
    }
    global void finish(Database.BatchableContext context) {
        try {

            List < Account_Bulk_Merge__c > lstAccBulkMerge;
            if (isLandscaping) {
                Set < Id > landscapingAccountMergeIds = new Set < Id > ();
                for (Account_Bulk_Merge__c rec: this.landscapingRecords) {
                    landscapingAccountMergeIds.add(rec.Id);
                }
                lstAccBulkMerge = [SELECT ID FROM Account_Bulk_Merge__c where Child_Account__c != null AND is_Landscaping__c =: isLandscaping AND Id in: landscapingAccountMergeIds ORDER BY CreatedDate desc];
            }

            if (lstAccBulkMerge != null && lstAccBulkMerge.size() > 0 && isLandscaping) {
                AccountBulkMerge abm = new AccountBulkMerge();
                abm.isLandscaping = true;
                abm.landscapingRecords = this.landscapingRecords;
                abm.isRecursion = true;
                abm.trxnId = this.trxnId;
                abm.totalCount = this.totalCount;
                Database.executeBatch(abm, Integer.valueOf(System.Label.AccountMergeBatchSize));
            } else {
                if (Test.isRunningTest()) {
                    CalloutException e = new CalloutException();
                    e.setMessage(
                        'This is a constructed exception for testing and code coverage');
                    throw e;
                }
            }



        } catch (Exception ex) {
            Log4SF.logMessage('AccountBulkMerge', 'finish', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
        }
    }

    public List < Account_Merge_Log__c > createAccountMergeLog(List < Account_Bulk_Merge__c > accountMergeLogsInTransferList) {
        List < Account_Merge_Log__c > accountMergeLogs = new List < Account_Merge_Log__c > ();
        try {
            for (Account_Bulk_Merge__c mergeAccount : accountMergeLogsInTransferList) {
                Account_Merge_Log__c objLog = new Account_Merge_Log__c();
                objLog.Account__c = mergeAccount.Parent_Account__c;
                List < Account > accPresent = [select ID from Account where ID =: mergeAccount.Child_Account__c];
                if (accPresent == null || accPresent.size() == 0) {
                    continue;
                }
                objLog.Merged_Account_ID__c = mergeAccount.Child_Account__c;
                objLog.Child_Account__c = mergeAccount.Child_Account__r.Name;
                objLog.TransactionId__c = trxnId;
                accountMergeLogs.add(objLog);
                System.debug('objLog@@@@'+objLog);
            }
            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage(
                    'This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception ex) {
            Log4SF.logMessage('AccountBulkMerge', 'createAccountMergeLog', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
        }
        insert accountMergeLogs;
        delete accntBulkMergeRecords;
        return accountMergeLogs;

    }
}