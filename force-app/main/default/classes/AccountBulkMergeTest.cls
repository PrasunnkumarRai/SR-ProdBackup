@isTest
public class AccountBulkMergeTest {
    
    @isTest static void testStartMethod() {
        // Create test data
        User newAdminUser = TestDataHelper.createSystemAdminUser(true);
        System.runAs(newAdminUser){
        	Account childAcc = new Account(Name = 'Child');
            insert childAcc;
            Account parentAcc = new Account(Name = 'Parent');
            insert parentAcc;
            Account_Bulk_Merge__c bulkMerge = new Account_Bulk_Merge__c(Child_Account__c = childAcc.Id, Parent_Account__c = parentAcc.Id);
            insert bulkMerge;
    
            Test.startTest();
            AccountBulkMerge batch = new AccountBulkMerge();
            batch.landscapingRecords = new List<Account_Bulk_Merge__c>{bulkMerge};
            batch.isLandscaping = true;
            Database.executeBatch(batch);
            Test.stopTest();
            
            // Verify
            //System.assertEquals(1, [SELECT COUNT() FROM Account_Bulk_Merge__c WHERE is_Landscaping__c = true AND isDeleted = true]);
        }
    }
    
    @isTest static void testExecuteMethod() {
        // Create test data
        User newAdminUser = TestDataHelper.createSystemAdminUser(true);
        System.runAs(newAdminUser){
            Account childAcc = new Account(Name = 'Child');
            insert childAcc;
            Account parentAcc = new Account(Name = 'Parent');
            insert parentAcc;
            Account_Bulk_Merge__c bulkMerge = new Account_Bulk_Merge__c(Child_Account__c = childAcc.Id, Parent_Account__c = parentAcc.Id);
            insert bulkMerge;
            
            Test.startTest();
            AccountBulkMerge batch = new AccountBulkMerge();
            batch.landscapingRecords = new List<Account_Bulk_Merge__c>{bulkMerge};
            Database.executeBatch(batch);
            Test.stopTest();
            
            // Verify
            //System.assertEquals(1, [SELECT COUNT() FROM Account_Bulk_Merge__c WHERE isDeleted = true]);
        }
    }
    
    @isTest static void testFinishMethod() {
        // Create test data
        User newAdminUser = TestDataHelper.createSystemAdminUser(true);
        System.runAs(newAdminUser){
            Account childAcc = new Account(Name = 'Child');
            insert childAcc;
            Account parentAcc = new Account(Name = 'Parent');
            insert parentAcc;
            Account_Bulk_Merge__c bulkMerge = new Account_Bulk_Merge__c(Child_Account__c = childAcc.Id, Parent_Account__c = parentAcc.Id);
            insert bulkMerge;
 
            Test.startTest();
            AccountBulkMerge batch = new AccountBulkMerge();
            batch.landscapingRecords = new List<Account_Bulk_Merge__c>{bulkMerge};
            Database.executeBatch(batch);
            Test.stopTest();
            
            // Verify
            //System.assertEquals(1, [SELECT COUNT() FROM Account_Bulk_Merge__c WHERE isDeleted = true]);
        }
    }
}