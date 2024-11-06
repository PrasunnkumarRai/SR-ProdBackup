/*
###########################################################################
# File..................: DeleteOppBudgetProposalTest.cls
# Version...............: 1
# Created by............: Usharani   
# Created Date..........: 21-Dec-2019
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: Test class used to get code coverage for DeleteOppBudgetProposal
# TAO Ref#..............: NA
# Change Log:               
#
############################################################################*/
@isTest
private class DeleteOppBudgetProposalTest 
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
        String response = DeleteOppBudgetProposal.doGet();
        System.assert(response != null);   
    }

    @istest static void testDeleteMethodWithValidId()
    {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/SpectrumReachDeleteOppBudgetProp/' + opp.Id;
        req.httpMethod = 'DELETE';
        RestContext.request = req;
        RestContext.response= res;

        Proposal__c pro=[SELECT Id FROM Proposal__c WHERE Opportunity__c=:opp.Id LIMIT 1];
        System.assertequals([SELECT count() FROM Proposal__c], 1);

        Test.startTest();
        DeleteOppBudgetProposal.ResponseCls resp=DeleteOppBudgetProposal.deleteProposals();       
        System.assertequals([SELECT count() FROM Proposal__c], 0);

        DeleteOppBudgetProposal.ResponseCls resp1=DeleteOppBudgetProposal.deleteProposals();
        System.assertequals(false, resp1.issuccess);
        Test.stopTest();
    }

    @istest static void testInvalidOpportunityId()
    {
        Account acc = TestUtil.getAccountRec();
        INSERT acc;
        Opportunity opp1=TestUtil.getOpportunityRec(acc.Id);

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/SpectrumReachDeleteOppBudgetProp/'+'87493lkdf9000';
        req.httpMethod = 'DELETE';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        try {
            DeleteOppBudgetProposal.ResponseCls resp2 = DeleteOppBudgetProposal.deleteProposals();
        }
        catch (exception e) {
            System.assert(e.getmessage()!=null) ;
        }    
        Test.stopTest();
    }

    @istest static void testOpportunityIdError() 
    {   
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/SpectrumReachDeleteOppBudgetProp/';
        req.httpMethod = 'DELETE';
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        DeleteOppBudgetProposal.ResponseCls response = DeleteOppBudgetProposal.deleteProposals();
        System.assert(!response.isSuccess);   
        System.assertEquals(System.Label.Opportunity_Id_Error, response.result);   
        Test.stopTest();
    }
}