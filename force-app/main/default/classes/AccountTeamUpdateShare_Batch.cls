/*
    Customer/Project:   Spectrum Reach
    Class name:          AccountTeamUpdateShare_Batch
    Author/Date:        Brett Ballantyne    6/1/2017
    Release:             TBD
    Purpose:            Ensures all Account Team Shares are Read/Write

    To test, enter this in MavensMate or developer console:
        AccountTeamUpdateShare_Batch atus = new AccountTeamUpdateShare_Batch(200, 11);
        Database.executeBatch(atus);

    To set it to run every 10 min, use this code:
        AccountTeamUpdateShare_Batch atus = new AccountTeamUpdateShare_Batch(200, 11);
        System.schedule('Account Team Share Update 00', '0 0 * * * ?', atus);
        System.schedule('Account Team Share Update 10', '0 10 * * * ?', atus);
        System.schedule('Account Team Share Update 20', '0 20 * * * ?', atus);
        System.schedule('Account Team Share Update 30', '0 30 * * * ?', atus);
        System.schedule('Account Team Share Update 40', '0 40 * * * ?', atus);
        System.schedule('Account Team Share Update 50', '0 50 * * * ?', atus);
*/


global without sharing class AccountTeamUpdateShare_Batch  implements Database.Batchable<sObject>, Schedulable {

    Integer batchSize = 200;
    String query;
    Integer numMinutes = 11;
    Datetime beforeDate;
    
    global AccountTeamUpdateShare_Batch(Integer bSize, Integer pNumMinutes) {
        // If test is running, set accountShare age to 2 days in the future, otherwise use numMinutes * -1
        batchSize = (bSize == null) ? 200 : bSize;
        numMinutes = (pNumMinutes == null) ? 11 : pNumMinutes;
      //  Integer acctShareAge = (Test.isRunningTest()) ? 2 : (numMinutes * -1);
        Integer acctShareAge = numMinutes * -1;
        beforeDate = Datetime.now().addMinutes(acctShareAge);

               
        query = 'select Id, AccountAccessLevel, OpportunityAccessLevel, RowCause, UserOrGroupId, AccountId, LastModifiedDate';
        query += ' from AccountShare where (LastModifiedDate >= :beforeDate ';
       //  query += ' AND (AccountAccessLevel = Read OR OpportunityAccessLevel = Read))';
       query += ' AND ((AccountAccessLevel = \'Read\' OR OpportunityAccessLevel = \'Read\') AND AccountAccessLevel != \'All\' ))';
  ////    query += ' AND ((AccountAccessLevel = \'Read\' OR OpportunityAccessLevel = \'Read\') AND AccountAccessLevel != \'All\' AND RowCause != \'Rule\'))';
    //   query += ' AND (AccountAccessLevel = \'Read\' OR OpportunityAccessLevel = \'Read\'))';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug(loggingLevel.WARN, '--------->> query = ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> objList) {
        system.debug(loggingLevel.WARN, '=======>> in execute!');
        system.debug(loggingLevel.WARN, '------>> objList = ' + objList);
        List<AccountShare> acctShareUpdateList = new List<AccountShare>();
        for (sObject so: objList) {
            AccountShare acctShare = (AccountShare) so;
              if(acctShare.AccountAccessLevel != 'Edit' || acctShare.OpportunityAccessLevel != 'Edit'){
                acctShare.AccountAccessLevel = 'Edit';
                acctShare.OpportunityAccessLevel = 'Edit';
                acctShareUpdateList.add(acctShare);
               }
        }
        system.debug('=============>> acctShareUpdateList size = ' + acctShareUpdateList.size());
        if (acctShareUpdateList.size() > 0) {
            try {
                update acctShareUpdateList;
            } catch (Exception ex) {
                // do we have any error logging we use at M&S?
                System.debug('Caught exception updating accounts in AccountTeamUpdateShare_Batch: ' + ex.getMessage());
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(this, batchSize);
     }

}