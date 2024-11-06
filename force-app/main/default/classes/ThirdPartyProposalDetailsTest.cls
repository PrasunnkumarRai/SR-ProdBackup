@isTest
private class ThirdPartyProposalDetailsTest {

    @testSetup static void setup() {
        Account acc = TestDataHelper.createAcc(null,null,null,null,null,null);
        insert acc;
        Opportunity opp = TestDataHelper.createopportunity(null,null,null,null,acc.Id);
        insert opp;
        Proposal__c propsl  = TestDataHelper.createProposal('Test Proposal',String.valueOf(opp.Id),null,null);
        propsl.TIM_System__c = 'St. Louis Local';
        insert propsl;
    }

    static testMethod void testDoGet() {
        String response = ThirdPartyProposalDetails.doGet();
        System.assert(response != null);   
    }

    static testMethod void testDoPost() {
        List<String> propIds = new List<String>();
        ThirdPartyProposalDetails.ResponseCls response1 = ThirdPartyProposalDetails.doPost(propIds);
        System.assert(response1 != null);
        System.debug('response1::'+response1);
        for(Proposal__c prop : [SELECT Id,Name FROM Proposal__c LIMIT 2]){
            propIds.add(prop.Id);
        }
        ThirdPartyProposalDetails.ResponseCls response2 = ThirdPartyProposalDetails.doPost(propIds);
        System.assert(response2 != null);
        System.debug('response2::'+response2);
        if(propIds.size()>0) propIds[0] = propIds[0]+'123';
        ThirdPartyProposalDetails.ResponseCls response3 = ThirdPartyProposalDetails.doPost(propIds);
        System.assert(response3 != null);
        System.debug('response3::'+response3);

    }

}