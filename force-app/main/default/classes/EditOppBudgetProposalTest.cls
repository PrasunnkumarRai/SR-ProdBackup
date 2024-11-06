/*
###########################################################################
# File..................: EditOppBudgetProposalTest.cls
# Version...............: 1
# Created by............: Usharani   
# Created Date..........: 21-Dec-2019
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: Test class used to get code coverage for EditOppBudgetProposal
# TAO Ref#..............: NA
# Change Log:               
#
############################################################################*/
@isTest
private class EditOppBudgetProposalTest 
{
    @testSetup static void setup() 
    {
        Account acc = TestUtil.getAgencyAccountRec();
        INSERT acc;
        Opportunity opp = TestUtil.getOpportunityRec(acc.Id);
        INSERT opp;
        Proposal__c prop = TestUtil.getProposal(acc.Id, opp.Id);
        INSERT prop;
    }

    @istest static void testDoGet() 
    {   
        Id recordTypeId = Schema.SObjectType.Proposal__c.getRecordTypeInfosByDeveloperName().get('Opportunity_Budget').getRecordTypeId();    
        Opportunity opp = [SELECT Id, (SELECT Id FROM Proposals__r WHERE RecordTypeId=:recordTypeId) FROM Opportunity LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/SpectrumReachEditOppBudgetProposal/' + opp.Id;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        EditOppBudgetProposal.ResponseCls response = EditOppBudgetProposal.editBudgetProposals();
        System.assert(response.isSuccess);   
        Id oppBudgetId = opp.Proposals__r[0].Id;
        String expectedURL = URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Proposal__c/'+oppBudgetId+'/edit';
        System.assertEquals(response.result, expectedURL);   
        Test.stopTest();
    }

    @istest static void testNoOppBudget() 
    {   
        Account acc = TestUtil.getAgencyAccountRec();
        INSERT acc;
        Opportunity opp2 = TestUtil.getOpportunityRec(acc.Id);
        opp2.Name = 'Test Opportunity2';
        INSERT opp2;

        Test.startTest(); 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/SpectrumReachEditOppBudgetProposal/' + opp2.Id;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;

        
        EditOppBudgetProposal.ResponseCls response = EditOppBudgetProposal.editBudgetProposals();
        System.assert(!response.isSuccess);   
        System.assertEquals(System.Label.No_Opportunity_Budget_Proposal_found + opp2.Id, response.result);   
        Test.stopTest();
    }

    @istest static void testNoOpportunityError() 
    {   
        String invalidOppId = '12345';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/SpectrumReachEditOppBudgetProposal/'+invalidOppId;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        EditOppBudgetProposal.ResponseCls response = EditOppBudgetProposal.editBudgetProposals();
        System.assert(!response.isSuccess);   
        System.assertEquals(System.Label.No_Opportunity_Error + ': '+invalidOppId, response.result);   
        Test.stopTest();
    }

    @istest static void testOpportunityIdError() 
    {   
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/SpectrumReachEditOppBudgetProposal/';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        EditOppBudgetProposal.ResponseCls response = EditOppBudgetProposal.editBudgetProposals();
        System.assert(!response.isSuccess);   
        System.assertEquals(System.Label.Opportunity_Id_Error, response.result);   
        Test.stopTest();
    }
}