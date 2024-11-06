/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class OrderHeaderCreatedInSTRATATest {

    @IsTest(seeAlldata = false)
    static void updateProposalPositivePathTest() {
        
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        
        System.runAs(u){
	        //Create an account
	        Account acc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                      
	        insert acc;

	        System.assert(acc != null);
	        
	        //Create an opportunity on the above created account
	        Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
	        insert opp;

	        System.assert(opp != null);
	        
	        OrderHeaderCreatedInSTRATA.OrderHeaderInfo oh = new OrderHeaderCreatedInSTRATA.OrderHeaderInfo();
	        oh.EstimateId = 0000;
	        oh.ProposalId = opp.id;
	        Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
	        Test.startTest();
	        OrderHeaderCreatedInSTRATA.updateProposal(oh);
	        oh.ProposalId = opp.id + '_INV';
	        OrderHeaderCreatedInSTRATA.updateProposal(oh);
	        oh.ProposalId = opp.id + '_PR';
	        OrderHeaderCreatedInSTRATA.updateProposal(oh);
	        oh.ProposalId = opp.id + '_TR';
	        OrderHeaderCreatedInSTRATA.updateProposal(oh);
	        oh.ProposalId = opp.id + '_LR';
	        OrderHeaderCreatedInSTRATA.updateProposal(oh);
	        Test.stopTest();
        }
        
    }
    
    @IsTest(seeAlldata = false)
    static void updateProposalNegativePathTest() {
    	
    	User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        
        System.runAs(u){
        
	        //Create an account
	        Account agency=TestDataHelper.createAgency('Agency Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
	        insert agency;
	        
	        System.assert(agency != null);
	        
	        OrderHeaderCreatedInSTRATA.OrderHeaderInfo oh = new OrderHeaderCreatedInSTRATA.OrderHeaderInfo();
	        
	        OrderHeaderCreatedInSTRATA.updateProposal(oh);
	        
	        oh.EstimateId = 0000;
	        oh.ProposalId = System.label.TestTIMId;
	        Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
	        
	        OrderHeaderCreatedInSTRATA.updateProposal(oh);
        }        
    }    
    
}