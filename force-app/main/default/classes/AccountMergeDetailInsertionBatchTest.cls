@isTest 
public class AccountMergeDetailInsertionBatchTest {
    
    @isTest static void testBatch() {
        Account childAcc = new Account(Name = 'Child');
        insert childAcc;
        Account parentAcc = new Account(Name = 'Parent');
        insert parentAcc;
        Account_Merge_Log__c mergeLog = new Account_Merge_Log__c(Account__c = parentAcc.Id, Merged_Account_ID__c = childAcc.Id, TransactionId__c = 'Test Id');
        insert mergeLog;
        
        Test.startTest();
        AccountMergeDetailInsertionBatch batch = new AccountMergeDetailInsertionBatch(new List<Account_Merge_Log__c>{mergeLog}, 'Merging');
        batch.trxnId = 'Test Id';
        batch.totalCount = 1;
        Database.executeBatch(batch);
        Test.stopTest();
        
    }
}