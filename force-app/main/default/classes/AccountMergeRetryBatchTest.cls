@isTest
public class AccountMergeRetryBatchTest {
    
    @testSetup
    static void setupTestData() {
        // Creating parent and child accounts
        Account parentAccount = new Account(Name = 'Parent Account');
        Account childAccount = new Account(Name = 'Child Account');
        insert new List<Account>{ parentAccount, childAccount };

        // Creating Account_Merge_Log__c records
        Account_Merge_Log__c mergeLog = new Account_Merge_Log__c(
            Account__c = parentAccount.Id,
            Merged_Account_ID__c = childAccount.Id,
            isRowLock__c = true
        );
        insert mergeLog;
    }
    
    @isTest
    static void testBatchExecution() {
        // Start the test
        Test.startTest();
        
        // Execute the batch
        Database.BatchableContext context;
        AccountMergeRetryBatch batch = new AccountMergeRetryBatch();
        Id batchId = Database.executeBatch(batch);
        
        // Get the job result
        
        Test.stopTest();
        
   
    }
}