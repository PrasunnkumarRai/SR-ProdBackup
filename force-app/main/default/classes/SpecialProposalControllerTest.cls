@isTest
private class SpecialProposalControllerTest {
    static testMethod void testPositiveScenario() {
		Account acc = TestDataHelper.createAcc('Test Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                        
        insert acc;
        opportunity opp= TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);
        insert opp;        

        SpecialProposalController.fetchRecordType(String.valueOf(opp.Id));
    }

    static testMethod void testNegativeScenario() {
		SpecialProposalController.fetchRecordType(null);
    }

    static testMethod void testWithPoliticalOpp() {
    	Account acc = TestDataHelper.createAcc('Test Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');
    	acc.Primary_Commodity__c = 'Political';
    	acc.Commodity_Codes__c = 'POLITICL -- Governor- Democrat';
        insert acc;
        opportunity opp= TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);
        insert opp;
        SpecialProposalController.fetchRecordType(String.valueOf(opp.Id));
    }
}