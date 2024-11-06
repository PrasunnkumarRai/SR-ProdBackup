/*
###########################################################################
# File..................: UpdateOpportunityFromAccountBatch_Test.cls
# Version...............: 
# Created by............: Puneet Khosla
# Created Date..........: 04-Apr-2018
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This is the test class for UpdateOpportunityFromAccountBatch
# Change Log:               
#
############################################################################*/
@isTest
private class UpdateOpportunityFromAccountBatch_Test 
{    
    static void showOppDetails() {
        List<Opportunity> opportunityList = [SELECT Id, Name, agency_account__r.Name, agency_account__c, rep_firm__c, rep_firm__r.Name, AccountId, Account.Name FROM Opportunity LIMIT 10];
        System.debug('opportunityList : ' + opportunityList);
        for (Opportunity oppRec : opportunityList) {
            System.debug('oppRec : ' + oppRec);
            System.debug('oppRec.AccountId : ' + oppRec.AccountId);
            System.debug('oppRec.Account.Name : ' + oppRec.Account.Name);
            System.debug('oppRec.agency_account__c : ' + oppRec.agency_account__c);
            System.debug('oppRec.agency_account__r.Name : ' + oppRec.agency_account__r.Name);
            System.debug('oppRec.rep_firm__c : ' + oppRec.rep_firm__c);
            System.debug('oppRec.rep_firm__r.Name : ' + oppRec.rep_firm__r.Name);
        }    
    }
    
    @testSetup static void prepareData()
    {
        Test.startTest();
            Account acc = TestDataHelper.createAgency('Test Agency Account', null, null, null, null, null);
            insert acc;
            System.Debug('oppRec : acc.RecordTypeId : ' + acc.RecordTypeId);
            System.assertEquals(TestDataHelper.agencyRecTypeId, acc.RecordTypeId);
            
            Opportunity opp = TestDataHelper.createopportunity('Test opportunity 1',null,null,null,null);
            
            Account advAcc = TestDataHelper.createAcc('Test Advertiser Account', 'Test Street', 'Test City', 'Test State', '123456', 'USA');
            advAcc.Approval_Status__c = 'Approved';
            insert advAcc;
            Opportunity opp2 = TestDataHelper.createopportunity('Test opportunity 2',null,null,null,advAcc.Id);
            List<Opportunity> oppList = new List<Opportunity>();
            oppList.add(opp);
            oppList.add(opp2);
        Test.stopTest();
        insert oppList;
        for (Opportunity oppR : oppList) {
            oppR.agency_account__c = acc.Id;
        }
        update oppList;
        showOppDetails();
        Proposal__c prop = TestDataHelper.createProposal(null,opp2.Id,null, true);
        insert prop;
    }
    @isTest static void CheckOpportunityBatch() 
    {
        List<Account> accList = [Select Id, UpdateOppFromAccount__c,RecordTypeId,RecordType.Name FROM Account LIMIT 2];
        System.assertEquals(2, accList.size());
        
        Account acc = accList.get(0);
        System.assertEquals(TestDataHelper.agencyRecTypeId, acc.RecordTypeId);
        System.assertEquals(null, acc.UpdateOppFromAccount__c);

        acc.RecordTypeId = TestDataHelper.repFirmRecTypeId;
        update acc;
        
        accList = [Select Id, UpdateOppFromAccount__c,RecordTypeId FROM Account LIMIT 2];
        acc = accList.get(0);
        System.assertEquals(TestDataHelper.repFirmRecTypeId, acc.RecordTypeId);        
        showOppDetails();

        Test.StartTest();
            UpdateOpportunityFromAccountBatch updateOppBatch = new UpdateOpportunityFromAccountBatch();
            Id batchId = database.executeBatch(updateOppBatch);
        Test.stopTest();
        
        accList = [Select Id, UpdateOppFromAccount__c,RecordTypeId FROM Account LIMIT 1];
        acc = accList.get(0);
        
        acc.RecordTypeId = TestDataHelper.agencyRecTypeId;
        update acc;

        String accQuery = 'SELECT Id from Account WHERE Id = \'' + acc.Id + '\'';
        updateOppBatch = new UpdateOpportunityFromAccountBatch(accQuery);
        Database.executeBatch(updateOppBatch);
    }

    @isTest static void testMethodForScheduleClass(){
        UpdateOpportunityFrmAccBatchSchedule m = new UpdateOpportunityFrmAccBatchSchedule();
        String sch = '20 30 8 10 2 ?';
        String jobID = system.schedule('Schedule for Update Opportunity Batch', sch, m);
    }
}