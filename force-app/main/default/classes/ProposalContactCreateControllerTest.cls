@isTest
public with sharing class ProposalContactCreateControllerTest {
  @IsTest(seeAlldata = false)
    static void proposalContactCreation() {
    	Account acc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
	    insert acc;
	    system.assert(acc.Id != null);
        Opportunity opp = TestDataHelper.createopportunity('TestOpp', System.today(),'Planning', 'Pipeline', acc.Id);
    	ProposalContactCreateController pcc = new ProposalContactCreateController();
    	pageReference pager = page.ProposalContactCreate;
        Test.setCurrentPage(pager);
        apexPages.Currentpage().getParameters().put('accId',acc.id);
        apexPages.Currentpage().getParameters().put('oppID',opp.id);
        Test.StartTest();
        pcc.accountRecordDetails();
        pcc.lightningComponentdetails();
        pcc.oppRecordDetails();
        Test.stopTest();
    }
}