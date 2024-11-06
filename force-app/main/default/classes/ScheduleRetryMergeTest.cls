@isTest
public class ScheduleRetryMergeTest {

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
    static void testScheduleRetryMerge() {
        // Start the test
        Test.startTest();

        // Schedule the job
        String cronExpression = '0 0 0 * * ?'; // Every day at midnight
        String jobId = System.schedule('Test ScheduleRetryMerge Job', cronExpression, new ScheduleRetryMerge());

        // Get the job result
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE Id = :jobId];
        


        // Execute the scheduled job
        Test.stopTest();

   
    }
}