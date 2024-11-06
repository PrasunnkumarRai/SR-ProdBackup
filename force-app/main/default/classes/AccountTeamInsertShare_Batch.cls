/*
    Customer/Project:   Spectrum Reach
    Class name:          AccountTeamInsertShare_Batch
    Author/Date:        John King    6/28/2017
    Release:             TBD
    Purpose:            Ensures all Account Team Shares are inserted as Read/Write

    To test, enter this in MavensMate or developer console:
        AccountTeamInsertShare_Batch atis = new AccountTeamInsertShare_Batch(200, 11);
        Database.executeBatch(atis);

    To set it to run every 10 min, use this code:
        AccountTeamInsertShare_Batch atis = new AccountTeamInsertShare_Batch(200, 11);
        System.schedule('Account Team Share Insert 09', '0 9 * * * ?', atis);
        System.schedule('Account Team Share Insert 19', '0 19 * * * ?', atis);
        System.schedule('Account Team Share Insert 29', '0 29 * * * ?', atis);
        System.schedule('Account Team Share Insert 39', '0 39 * * * ?', atis);
        System.schedule('Account Team Share Insert 49', '0 49 * * * ?', atis);
        System.schedule('Account Team Share Insert 59', '0 59 * * * ?', atis);
*/


global without sharing class AccountTeamInsertShare_Batch  implements Database.Batchable<sObject>, Schedulable {

    Integer batchSize = 200;
    String query;
    Integer numMinutes = 11;
    Datetime beforeDate;
    
    global AccountTeamInsertShare_Batch(Integer bSize, Integer pNumMinutes) {
        // If test is running, set accountShare age to 2 days in the future, otherwise use numMinutes * -1
        batchSize = (bSize == null) ? 200 : bSize;
        numMinutes = (pNumMinutes == null) ? 11 : pNumMinutes;
        Integer acctShareAge = (Test.isRunningTest()) ? 2 : (numMinutes * -1);
        beforeDate = Datetime.now().addMinutes(acctShareAge);

               
        query = 'select Id, AccountAccessLevel, UserId, AccountId, TeamMemberRole, LastModifiedDate '+
        		'from AccountTeamMember '+
        		'where  User.IsActive = true AND AccountAccessLevel != \'Edit\' and AccountAccessLevel != \'All\' and UserId != \''+UserUtils.BoomiUserId+'\'';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug(loggingLevel.WARN, '--------->> query = ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> objList) {
        system.debug(loggingLevel.WARN, '=======>> in execute!');
        system.debug('------>> objList = ' + objList);
        List<AccountShare> acctShareInsertList = new List<AccountShare>();
        List<AccountTeamMember> acctTeamMemberInsertList = new List<AccountTeamMember>();
        List<AccountTeamMember> acctTeamMemberInsertListOld = new List<AccountTeamMember>();
        for (sObject so: objList) {
            AccountTeamMember acctTeamMember = (AccountTeamMember) so;
            //acctTeamMember.AccountAccessLevel = 'Edit';
/*            acctTeamMemberInsertList.add(
                    New AccountTeamMember(
                        AccountId = acctTeamMember.AccountId,
                        TeamMemberRole = acctTeamMember.TeamMemberRole,
                        UserId = acctTeamMember.UserId
                    )
            	);
            acctTeamMemberInsertListOld.add(acctTeamMember);
*/
            acctShareInsertList.add(
                  New AccountShare(
			              AccountId = acctTeamMember.AccountId,
			              AccountAccessLevel = 'Edit',
			              OpportunityAccessLevel = 'Edit',
			              UserOrGroupId = acctTeamMember.UserId
			      )
            	);
        }
        system.debug('=============>> acctShareInsertList size = ' + acctShareInsertList.size());
/*        if (acctTeamMemberInsertList.size() > 0) {
            try {
            	delete acctTeamMemberInsertListOld;
                insert acctTeamMemberInsertList;
            } catch (Exception ex) {
                // do we have any error logging we use at M&S?
                System.debug('Caught exception inserting account team members in AccountTeamInsertShare_Batch: ' + ex.getMessage());
            }
        }
  */      if (acctShareInsertList.size() > 0) {
            try {
                insert acctShareInsertList;
            } catch (Exception ex) {
                // do we have any error logging we use at M&S?
                System.debug('Caught exception inserting account shares in AccountTeamInsertShare_Batch: ' + ex.getMessage());
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(this, batchSize);
     }

}