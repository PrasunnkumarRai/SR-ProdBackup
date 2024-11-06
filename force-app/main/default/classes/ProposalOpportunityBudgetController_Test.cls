/*
###########################################################################
# File..................: ProposalOpportunityBudgetController_Test.cls
# Version...............: 
# Created by............: Aditi Garg
# Created Date..........: 5-July-2017
# Last Modified by......: Anusha Pagidimarri
# Last Modified Date....: 6-July-2017
# Description...........: Test class for ProposalOpportunityBudgetController 
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/
@isTest
private class ProposalOpportunityBudgetController_Test {
	static List<List<String>> budgetList;
	static ProposalOpportunityBudgetController cp;
	static Account acc;
	static Opportunity opp;
	static Proposal__c p;
	static Proposal_Zone__c propZone;
	static Proposal_Zone_Monthly_Value__c propZoneMonthly;
	static String selStartDate;
	static String selendDate;

   @IsTest(seeAlldata = false)
    static void PropOppBudCntrlPositivePathTest() {

    	//User u = [select Id, Name from User where Name = 'Boomi Integration User'];
        User u = TestDataHelper.getBoomiIntegrationUser();
        
        System.runAs(u){

        	//TestDataHelper.createTIMIntegrationCustomSettings();
	        insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
	        
	        //Create an account
	        acc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
	        insert acc;

            System.assert(acc != null);
	        
	        //Create an opportunity on the above created account
	        opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
	        //opp.Number_Of_Manual_Proposal_Records__c = 1;
	        insert opp;

            System.assert(opp != null);
	        
	       
	       /*RecordType oppBudgetRT = [select ID from RecordType 
                               where name = 'Opportunity Budget' 
                                     and SobjectType='Proposal__c' 
                               limit 1];*/
	        
	        p = TestDataHelper.createProposal('Test Opportunity Proposal',opp.id, '00000', true);
	        p.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
	        p.Start_Date__c = System.today();
	        p.End_Date__c = System.today().addMonths(1);
	        insert p;
	        
	        propZone = TestDataHelper.createProposalZone('Test Proposal Zone',p.Id);
            insert propZone;

	        propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value',acc.Id,propZone.Id);
            propZoneMonthly.Schedule_Type__c = 'Linear';
            propZoneMonthly.Proposal_Key_Index__c = p.Id;
            propZoneMonthly.Broadcast_Month_Date__c = System.today().adddays(1);

            insert propZoneMonthly;

	        budgetList = new List<List<String>>();
	        List<String> budgets = new List<String>();
	        budgets.add('Linear');
	        budgets.add('1234');
	        budgets.add('5678');
	        budgetList.add(budgets);

	        TestDataHelper.createSysCodeManualProposalCreationCustomSettings();

	        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
	        ApexPages.currentPage().getParameters().put('oppId', opp.id);

            String oppId = ApexPages.currentPage().getParameters().get('oppId');
            system.assertEquals(true,oppId!=null);
	       
	        cp = new ProposalOpportunityBudgetController(controller);
            Test.startTest();
    	        cp.validateProposals();	        
    			cp.GoBackToOpportunity();
    	        cp.changeDate();
    	        Date startDate = System.today();
    			selStartDate = DateTime.newInstance(startDate.year(),startDate.month(),startDate.day()).format('MM/dd/YYYY');
    	        Date endDate = System.today().adddays(4);
    	        selendDate = DateTime.newInstance(endDate.year(),endDate.month(),endDate.day()).format('MM/dd/YYYY');	        
    	        ProposalOpportunityBudgetController.getRecords(p.Id,selStartDate);
    	        ProposalOpportunityBudgetController.getProposalMap(selStartDate,selendDate, p, p.id, 'Production');
    	        ProposalOpportunityBudgetController.saveRecords(selStartDate,selendDate,null,opp.id,p.id,budgetList);
            Test.stopTest();       
	        
        }
        
    }

    static testMethod void PropOppBudCntrlNegativePathTest(){

    	prepareTestData();

		budgetList = new List<List<String>>();
        List<String> budgets = new List<String>();
        budgets.add('Advanced Advertising');
        budgets.add('1234');
        budgets.add('5678');
        budgetList.add(budgets);

        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
        ApexPages.currentPage().getParameters().put('oppId', opp.id);

        String oppId = ApexPages.currentPage().getParameters().get('oppId');
        system.assertEquals(true,oppId!=null);        

        System.debug(selStartDate);
        System.debug(selendDate);
        ProposalOpportunityBudgetController.getProposalMap(selStartDate,selendDate, null, null, 'Production');
		cp = new ProposalOpportunityBudgetController(controller);
        Test.startTest();
        cp.validateProposals();
        ProposalOpportunityBudgetController.saveRecords(selStartDate,selendDate,null,opp.id,null,budgetList);
        //ProposalOpportunityBudgetController.saveRecords(selStartDate,selendDate,null,opp.id,p.Id,budgetList);
        p.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
		p.Start_Date__c = Null;
        p.End_Date__c = Null;
        update p;
        cp = new ProposalOpportunityBudgetController(controller);
        Test.stopTest();
	}

    static testMethod void PropOppBudCntrlNegativePathTestSRNews(){
    	prepareTestData();

        budgetList = new List<List<String>>();
        List<String> budgets = new List<String>();
        budgets.add('SRNews');
        budgets.add('1234');
        budgets.add('5678');
        budgetList.add(budgets);

        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
        ApexPages.currentPage().getParameters().put('oppId', opp.id);

        String oppId = ApexPages.currentPage().getParameters().get('oppId');
        system.assertEquals(true,oppId!=null);

        cp = new ProposalOpportunityBudgetController(controller);
        ProposalOpportunityBudgetController.getProposalMap(selStartDate,selendDate, null, null, 'Production');
        Test.startTest();
    		cp.validateProposals();
            ProposalOpportunityBudgetController.saveRecords(selStartDate,selendDate,null,opp.id,null,budgetList);
    	    //ProposalOpportunityBudgetController.saveRecords(selStartDate,selendDate,null,opp.id,p.Id,budgetList);
        Test.stopTest();
	}
    
    static testMethod void PropOppBudCntrlNegativePathTestLinear(){
    	prepareTestData();

    	budgetList = new List<List<String>>();
        List<String> budgets = new List<String>();
        budgets.add('Linear');
        budgets.add('1234');
        budgets.add('5678');
        budgetList.add(budgets);

        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
        ApexPages.currentPage().getParameters().put('oppId', opp.id);

        String oppId = ApexPages.currentPage().getParameters().get('oppId');
        system.assertEquals(true,oppId!=null);

        cp = new ProposalOpportunityBudgetController(controller);
        Test.startTest();
	    cp.validateProposals();
    	ProposalOpportunityBudgetController.getProposalMap(selStartDate,selendDate, null, null, 'Production');
		ProposalOpportunityBudgetController.saveRecords(selStartDate,selendDate,null,opp.id,null,budgetList);	
        Test.stopTest();
    }

    static testMethod void PropOppBudCntrlNegativePathTestRSN(){
    	prepareTestData();

    	budgetList = new List<List<String>>();
		List<String> budgets = new List<String>();
        budgets.add('RSN');
        budgets.add('1234');
        budgets.add('5678');
        budgetList.add(budgets);

        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
        ApexPages.currentPage().getParameters().put('oppId', opp.id);

        String oppId = ApexPages.currentPage().getParameters().get('oppId');
        system.assertEquals(true,oppId!=null);

        cp = new ProposalOpportunityBudgetController(controller);
        Test.startTest();
        cp.validateProposals();
		ProposalOpportunityBudgetController.getProposalMap(selStartDate,selendDate, null, null, 'Production');
		ProposalOpportunityBudgetController.saveRecords(selStartDate,selendDate,null,opp.id,null,budgetList);
        //ProposalOpportunityBudgetController.saveRecords(selStartDate,selendDate,null,opp.id,p.Id,budgetList);
        Test.stopTest();
	}

    static testMethod void PropOppBudCntrlNegativePathTestBudget(){
    	prepareTestData();

        budgetList = new List<List<String>>();
        List<String> budgets = new List<String>();
        budgets.add('Test');
        budgets.add('1234');
        budgets.add('5678');
        budgetList.add(budgets);

        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
	    ApexPages.currentPage().getParameters().put('oppId', opp.id);

        String oppId = ApexPages.currentPage().getParameters().get('oppId');
        system.assertEquals(true,oppId!=null);

	    cp = new ProposalOpportunityBudgetController(controller);
        Test.startTest();
        cp.validateProposals();
        ProposalOpportunityBudgetController.getProposalMap(selStartDate,selendDate, null, null, 'Production');
		ProposalOpportunityBudgetController.saveRecords(selStartDate,selendDate,null,opp.id,null,budgetList);
        Test.stopTest();
	}

    static void prepareTestData(){
    	//User u = [select Id, Name from User where Name = 'Boomi Integration User'];
        User u = TestDataHelper.getBoomiIntegrationUser();
        
        System.runAs(u){

        	//TestDataHelper.createTIMIntegrationCustomSettings();
	        insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
	        
	        //Create an account
	        acc = TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
	        insert acc;

            System.assert(acc != null);
	        
	        //Create an opportunity on the above created account
	        opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
	        //opp.Number_Of_Manual_Proposal_Records__c = 1;
	        insert opp;

            System.assert(opp != null);
	        
	        p = TestDataHelper.createProposal('Test Opportunity Proposal',opp.id, '00000', true);
	        p.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
	        insert p;
	        
	        propZone = TestDataHelper.createProposalZone('Test Proposal Zone',p.Id);
            insert propZone;

	        propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value',acc.Id,propZone.Id);
            propZoneMonthly.Schedule_Type__c = 'Production';
            propZoneMonthly.Proposal_Key_Index__c = p.Id;
            propZoneMonthly.Broadcast_Month_Date__c = System.today().adddays(1);

            insert propZoneMonthly;

            TestDataHelper.createSysCodeManualProposalCreationCustomSettings();

	        Id linearRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Linear'].Id;

	        p.RecordTypeId = linearRecTypeId;
			p.Start_Date__c = System.today();
	        p.End_Date__c = System.today().addMonths(1);
	        update p;

            Proposal__c prop = [SELECT id,name,RecordTypeId FROM Proposal__c LIMIT 1];
            System.assertEquals(linearRecTypeId, prop.RecordTypeId);

	        Date startDate = System.today();
			selStartDate = DateTime.newInstance(startDate.year(),startDate.month(),startDate.day()).format('MM/dd/YYYY');
	        Date endDate = System.today().adddays(4);
	        selendDate = DateTime.newInstance(endDate.year(),endDate.month(),endDate.day()).format('MM/dd/YYYY');
	    }
    }
}