@isTest
private class BatchToDeleteLoggersTest {

    static testMethod void deleteLoggers() 
    {
        List<Logger__c> loggerList = new List<Logger__c>();
        Logger__c logger = new Logger__c();
        logger.Type__c = 'BOOMI';
        logger.Method__c = 'Update';
        loggerList.add(logger);

        insert loggerList;
        
        loggerList = [SELECT Id FROM Logger__c LIMIT 1];
        System.assertEquals(1,loggerList.size());

        Test.startTest();        
        BatchToDeleteLoggers loggerBatch = new BatchToDeleteLoggers();
        ID batchProcessId = Database.executeBatch(loggerBatch);
        Test.stopTest();

        loggerList = [SELECT Id FROM Logger__c LIMIT 1];
        System.assertEquals(0,loggerList.size()); 
    }

    static testMethod void ScheduleTest()
    {

        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String sch = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobId = System.schedule('Schedule Batch',sch ,new ScheduleToDeleteLoggers());   
        Test.stopTest();
        
        System.assertNotEquals(null,jobId);
    }
}