@isTest 
public class AccountMergeRetryAndEmailBatchTest {
        @isTest static void testBatch() {
        Account childAcc = new Account(Name = 'Child');
        insert childAcc;
        Account parentAcc = new Account(Name = 'Parent');
        insert parentAcc;
        Account_Merge_Log__c mergeLog = new Account_Merge_Log__c(Account__c = parentAcc.Id, Merged_Account_ID__c = childAcc.Id, TransactionId__c = 'Test Id', isRowLock__c = true);
        insert mergeLog;
        
        Test.startTest();
        AccountMergeRetryAndEmailBatch batch = new AccountMergeRetryAndEmailBatch('Test Id');
        Database.executeBatch(batch, 1);
        Test.stopTest();
        
    }

}