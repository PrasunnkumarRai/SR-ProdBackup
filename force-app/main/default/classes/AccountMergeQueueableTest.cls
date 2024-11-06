@isTest
public class AccountMergeQueueableTest {
    
    @isTest static void testExecuteMethod() {
        // Create test data
        Account childAcc = new Account(Name = 'Child');
        insert childAcc;
        Account parentAcc = new Account(Name = 'Parent');
        insert parentAcc;
        Account_Merge_Log__c mergeLog = new Account_Merge_Log__c(Account__c = parentAcc.Id, Merged_Account_ID__c = childAcc.Id);
        insert mergeLog;
        
        Test.startTest();
        AccountMergeQueueable queueable = new AccountMergeQueueable(new List<Account_Merge_Log__c>{mergeLog},'Test Id',1);
        
        System.enqueueJob(queueable);
        Test.stopTest();
        
        // Verify
        System.assertEquals(1, [SELECT COUNT() FROM Account_Merge_Log__c]);
    }
}