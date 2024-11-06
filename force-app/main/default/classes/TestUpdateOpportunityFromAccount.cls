@isTest
public class TestUpdateOpportunityFromAccount {
	@testSetup static void prepareData()
    {
        List<Account> accountList = new List<Account>();
        Account advAcc = TestDataHelper.createAdvertiser(null, null, null, null, null, null);

        Account acc = TestDataHelper.createAgency(null, null, null, null, null, null);
        //insert acc;
        accountList.add(acc);
        accountList.add(advAcc);
        insert accountList;

        Opportunity opp = TestDataHelper.createopportunity(null,null,null,null,advAcc.Id);
        opp.agency_account__c = acc.id;

        /*Account accRepFirm = TestDataHelper.createRepFirm(null, null, null, null, null, null);
        insert accRepFirm;
        System.assertEquals(TestDataHelper.repFirmRecTypeId, accRepFirm.RecordTypeId);
        */
        Opportunity opp2 = TestDataHelper.createopportunity(null,null,null,null,advAcc.Id);
        //opp2.Rep_Firm__c = accRepFirm.id;
        opp2.agency_account__c = acc.id;
        //opp2.AccountId = NULL;
        List<Opportunity> oppList = new list<Opportunity>();
        oppList.add(opp);
        oppList.add(opp2);

        insert oppList;

        Proposal__c prop = TestDataHelper.createProposal(null,opp2.Id,null, true);
        insert prop;
    }

    /*	Method for coverage for controller class: UpdateOpportunityFromAccount
     * 	Methods covered:-
     *  1) getAccountList
     *  2) isBatchRunning:-
     *  3) runBatchApex
     */
    public static testMethod void controllerClass (){
        List<Account> accList = [Select id, UpdateOppFromAccount__c,RecordTypeId,RecordType.Name from Account LIMIT 2];
        System.assertEquals(2, accList.size());
        
        Account acc = accList.get(0);
        //Account accRepFirm = accList.get(1);
        System.debug('acc.RecordType.Name : ' + acc.RecordType.Name);
        //System.debug('accRepFirm.RecordType.Name : ' + accRepFirm.RecordType.Name);
        System.assertEquals(TestDataHelper.agencyRecTypeId, acc.RecordTypeId);
        //System.assertEquals(TestDataHelper.repFirmRecTypeId, accRepFirm.RecordTypeId);
        System.assertEquals(null, acc.UpdateOppFromAccount__c);

        acc.RecordTypeId = TestDataHelper.repFirmRecTypeId;
        update acc;
        Test.startTest();
            UpdateOpportunityFromAccountController.getAccountList();
            acc.RecordTypeId = TestDataHelper.agencyRecTypeId;
            update acc;
            UpdateOpportunityFromAccountController.getAccountList();
            UpdateOpportunityFromAccountController.isBatchRunning();
            UpdateOpportunityFromAccountController.runBatchApex();
            UpdateOpportunityFromAccountController.getBatchStatus(NULL);
        Test.stopTest();
    }
    
    /*	Method for coverage for batch class: UpdateOpportunityFromAccountBatch
     * 
     */
     
    public static testMethod void batchClass (){
        Test.startTest();
        UpdateOpportunityFromAccountBatch batchObj = new UpdateOpportunityFromAccountBatch();
        Database.executeBatch(batchObj);
        Test.stopTest();
    }
}