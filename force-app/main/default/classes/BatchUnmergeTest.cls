@isTest
public class BatchUnmergeTest {
    
    
    @isTest static void testBatch() {
    	Account parentAccount = new Account(Name = 'Parent Account');
        Account childAccount = new Account(Name = 'Child Account');
        insert new List<Account>{parentAccount, childAccount};
        
        Account_Merge_Log__c mergeLog = new Account_Merge_Log__c(Account__c = parentAccount.Id, Merged_Account_ID__c = childAccount.Id);
        insert mergeLog;
        
        List<String> accMLList = new List<String>{mergeLog.Id};
            
        Test.startTest();
        BatchUnmerge batch = new BatchUnmerge(accMLList);
        Database.executeBatch(batch,1);
        Test.stopTest();
    }
}