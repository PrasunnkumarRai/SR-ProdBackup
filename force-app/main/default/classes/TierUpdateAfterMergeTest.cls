@IsTest
public class TierUpdateAfterMergeTest {

    @isTest
    static void testBatch() {
        
        Account p = new Account(Name = 'parent');
        insert p;
        Account c = new Account(Name = 'child');
        insert c;
        Account_SAM_Mapping__c tier1 = new Account_SAM_Mapping__c(Account__c = p.Id, Tier_Designation__c = 'VIP', Tier_External_Id__c = p.Id + 'VIP');
        insert tier1;
        Account_SAM_Mapping__c tier2 = new Account_SAM_Mapping__c(Account__c = p.Id, Tier_Designation__c = 'Premier', Tier_External_Id__c = c.Id + 'Premier');
        insert tier2;
        
        Account_Merge_Log__c aml = new Account_Merge_Log__c(Account__c = p.Id, Merged_Account_ID__c = c.Id, Error_Description__c = null, TransactionId__c ='Test');
        insert aml;
        
        Tier_Designation_Order__c t1 = new Tier_Designation_Order__c(Name = 'Premier', Tier_Order__c = 2);
        insert t1;
        
        Tier_Designation_Order__c t2 = new Tier_Designation_Order__c(Name = 'VIP', Tier_Order__c = 3);
        insert t2;
        
        TierUpdateAfterMerge batch = new TierUpdateAfterMerge('Test');

        // Execute the batch
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();
    }
}