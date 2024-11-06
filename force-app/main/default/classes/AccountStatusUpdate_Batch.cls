/* 
    Customer/Project:   Spectrum Reach
    Class name:         AccountStatusUpdate_Batch
    Author/Date:        Brett Ballantyne    3/7/2017
    Release:            TBD
    Purpose:            Sets the Active flag to "No" if account is older than specified time period
    Modifications:      Brett Ballantyne - 3/16/2018 - SRSF-887 - changed query criteria

    To test, enter this in MavensMate or developer console:
        AccountStatusUpdate_Batch ab = new AccountStatusUpdate_Batch();
        Database.executeBatch(ab);

    To set it to run nightly at midnight, use this code:
        AccountStatusUpdate_Batch ab = new AccountStatusUpdate_Batch();
        system.schedule('Account Status Update', '0 0 0 * * ?', ab);

*/


global class AccountStatusUpdate_Batch implements Database.Batchable<sObject>, Schedulable {
    Integer batchSize;
    String query;
    Integer numDays;
    
    global AccountStatusUpdate_Batch() {
        String numDays = System.Label.Account_Inactive_Days;
        // If test is running, set account age to 2 days in the future, otherwise use the system label * -1
        Integer accountAgeInDays = (Test.isRunningTest()) ? 2 : (Integer.valueOf(numDays) * -1);
        batchSize = 200;
        Datetime beforeDate = Datetime.now().addDays(accountAgeInDays);
        String activeDateTime = beforeDate.format ('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'' ,'America/New_York');                         //('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'', 'UTC');
        String activeDate = beforeDate.format('yyyy-MM-dd');               
        query = 'select Id, Name, CreatedDate, Active__c, LastModifiedDate, Max_End_Date_Proposals__c';
        query += ' from Account where CreatedDate <= ' + activeDateTime;
        query += ' AND (Max_End_Date_Proposals__c = null OR Max_End_Date_Proposals__c <= ' + activeDate + ')';
    }

    global AccountStatusUpdate_Batch(Integer bSize, String pQuery) {
        batchSize = bSize;
        query = pQuery;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug(loggingLevel.WARN, '--------->> query = ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> objList) {
        system.debug(loggingLevel.WARN, '=======>> in execute!');
        List<Account> acctUpdateList = new List<Account>();
        for (sObject so: objList) {
            Account acct = (Account) so;
            system.debug(loggingLevel.WARN, '============>> setting Account Active Status to Inactive for account: ' + acct.Name);
            acct.Active__c = false;
            acctUpdateList.add(acct);
        }
        if (acctUpdateList.size() > 0) {
            try {
                update acctUpdateList;
            } catch (Exception ex) {
                // do we have any error logging we use at M&S?
                System.debug('Caught exception updating accounts in AccountStatusUpdate_Batch: ' + ex.getMessage());
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }

    global void execute(SchedulableContext sc) {
        integer batchSize = 1;  
        Database.executeBatch(new AccountStatusUpdate_Batch(), 200);
     }
    
}