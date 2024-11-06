@isTest
public class BatchSingleUnmergeTest {
    
    @isTest static void testBatch() {
    	Account p = new Account(Name = 'p');
        insert p;
        Account c = new Account(Name = 'c');
        insert c;
        Account_Merge_Log__c aml = new Account_Merge_Log__c(Account__c = p.Id, Merged_Account_ID__c = c.Id);
        insert aml;
        
        Opportunity o = new Opportunity(AccountId = p.Id, Name ='o', StageName='o', CloseDate=Date.today());
        insert o;
        Task t = new Task(WhatId = p.Id);
        insert t;
        Account_Merge_Detail__c mergeDetail1 = new Account_Merge_Detail__c(
            Account_Merge_Log__c = aml.Id,
            Object_Name__c = 'Opportunity',
            Field_to_Update__c = 'AccountId',
            Record_ID__c = o.Id
            
        );
        insert mergeDetail1;
        
        Account_Merge_Detail__c mergeDetail2 = new Account_Merge_Detail__c(
            Account_Merge_Log__c = aml.Id,
            Object_Name__c = 'Task',
            Field_to_Update__c = 'AccountId',
            Record_ID__c = t.Id
            
        );
        insert mergeDetail2;
        
        delete c;
        
        Test.startTest();
        BatchSingleUnmerge b = new BatchSingleUnmerge(aml.Id);
        Database.executeBatch(b);
        Test.stopTest();
    
    }
}