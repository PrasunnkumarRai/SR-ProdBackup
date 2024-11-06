@isTest
private class DeleteProposalZoneMonthlyValuesTest {
    static testMethod void unitTest() {
        Account adv = TestDataHelper.createAdvertiser('Test Advertiser',null,null,null,null,null);
        insert adv;

        Opportunity opp = TestDataHelper.createopportunity('Test Opp',null,null,null,adv.id);
        insert opp;

        Proposal__c prop = TestDataHelper.createProposal('Test Prop',opp.Id,null,true);
        insert prop;

        Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Prop Zone', prop.Id);
        insert propZone;

        Proposal_Zone_Monthly_Value__c propZoneMonVal = TestDataHelper.createProposalZoneMontly('Test Mon Val',adv.Id,propZone.Id);
        insert propZoneMonVal;

        DeleteProposalZoneMonthlyValues delPropZonMonValBatch = new DeleteProposalZoneMonthlyValues();

        Test.startTest();
        Database.executeBatch(delPropZonMonValBatch);
        System.assertNotEquals(null, delPropZonMonValBatch);
        Test.stopTest();
    }
}