@isTest
private class CloneOpportunityControllerTest {

	@testSetup static void setUp(){

		List<Account> accList = new List<Account>();

		Account acc = TestDataHelper.createAcc('Test Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');  
		accList.add(acc);                      
        Account agencyAcc = TestDataHelper.createAgency('Test Agency Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');
        accList.add(agencyAcc);

        Account acc1 = TestDataHelper.createAgency('Test Account1', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500085', 'India');
        accList.add(acc1);

        Account repFirm = TestDataHelper.createRepFirm(null, null, null, null, null, null);
        accList.add(repFirm);

        Insert accList;
        
        Opportunity opp = TestDataHelper.createopportunity('Test Opportunity', System.today(),'Planning','Pipeline',acc.ID);        
        opp.Sales_Probability__c = '50';
        Insert opp;  
        
        Proposal__c prop = TestDataHelper.createProposal('Test Proposal',opp.id,'76877',TRUE); 
        prop.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
        Insert prop;  

        Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Proposal Zone', prop.Id);
        Insert propZone;        

        List<Proposal_Zone_Monthly_Value__c> lstPZMV = new List<Proposal_Zone_Monthly_Value__c>();
        Proposal_Zone_Monthly_Value__c pzmv =  TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value',acc.Id,propZone.Id);
        pzmv.Schedule_Type__c = 'Production';
        pzmv.Proposal_Key_Index__c = prop.Id;
        pzmv.Broadcast_Month_Date__c = System.today().adddays(1);
        pzmv.Gross_Amount__c = 100.00;
        lstPZMV.add(pzmv);
        
        Proposal_Zone_Monthly_Value__c pzmv2 = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value2', acc.Id, propZone.Id);
        pzmv2.Schedule_Type__c = 'Linear';
        pzmv2.Proposal_Key_Index__c = prop.Id;
        pzmv2.Broadcast_Month_Date__c = System.today().adddays(1);
        pzmv2.Gross_Amount__c = 100.00;
        lstPZMV.add(pzmv2);

        Insert lstPZMV;

        // Below: Test data for Opportunity with Locked RecordType
        CloneOppRecTypeSetting__c setting = new CloneOppRecTypeSetting__c ();
        setting.Name = 'Opportunity_Locked';
        setting.OppRecTypeDevName__c = 'Opportunity';
        setting.LockedOppRecTypeDevName__c = 'Opportunity_Locked';
        insert setting;      
	}

    static testMethod void cloneOppBudget() {
        
        Test.startTest();

        //Existing record
        Opportunity opp =  [SELECT Id, Name, StageName, Sales_Probability__c, DMA__c, Account.Name, Agency_Account__c, Rep_Firm__c, CloseDate, Cloned_From_Opportunity__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        System.debug('Opportunity--->'+opp);

        System.assertEquals(null, opp.Agency_Account__c);
        System.assertEquals(null, opp.Rep_Firm__c);
        System.assertEquals(null, opp.Cloned_From_Opportunity__c);       

        // Passing Agency and Repfirm values for Clone record 
        Account advertiser = [SELECT Id FROM Account WHERE Name = 'Test Account1'];
        Account agency = [SELECT Id FROM Account WHERE RecordTypeId = :TestDataHelper.agencyRecTypeId LIMIT 1];

        Account repfirm = [SELECT Id FROM Account WHERE RecordTypeId = :TestDataHelper.repFirmRecTypeId LIMIT 1];
        opp.AccountId = advertiser.Id;    // User is not part of this AccountTeam
        opp.Agency_Account__c = agency.Id;   
        opp.Rep_Firm__c = repfirm.Id;   
        opp.Sales_Probability__c = '75';   
        opp.CloseDate = Date.today().adddays(5);   

        Opportunity oppotunity = CloneOpportunityController.prePopulateOppData(opp.Id);

        System.assert(oppotunity != NULL);
        try{
            Account acct = CloneOpportunityController.validateAccountSelection(oppotunity.Id);
        } catch (Exception ex){
            System.assertEquals('You are not an Account Team Member for selected Advertiser.',System.Label.Only_AccountTeamMember_can_Clone_an_Opportunity);
        }    
        Opportunity clonedOpp = CloneOpportunityController.cloneOpportunity(oppotunity.Id, opp );

        Test.stopTest();

        System.assertEquals(agency.Id, clonedOpp.Agency_Account__c);
        System.assertEquals(repfirm.Id, clonedOpp.Rep_Firm__c);
        System.assertEquals(opp.Id, clonedOpp.Cloned_From_Opportunity__c);        
    }

    static testMethod void cloneOppBudgetLocked() {
        
        Test.startTest();

        //Existing record
        Opportunity opp =  [SELECT Id, Name, StageName, Sales_Probability__c, DMA__c, Account.Name, Agency_Account__c, Rep_Firm__c, CloseDate, Cloned_From_Opportunity__c FROM Opportunity Where Name = 'Test Opportunity' LIMIT 1];
        opp.RecordTypeId=TestDataHelper.oppLockedRecTypeId;
        update opp;
        System.debug('Opportunity--->'+opp);

        System.assertEquals(null, opp.Agency_Account__c);
        System.assertEquals(null, opp.Rep_Firm__c);
        System.assertEquals(null, opp.Cloned_From_Opportunity__c);       

        // Passing Agency value for Clone record        
        Account agency = [SELECT Id FROM Account WHERE RecordTypeId = :TestDataHelper.agencyRecTypeId LIMIT 1];
                 
        opp.Agency_Account__c = agency.Id;    
        opp.Sales_Probability__c = '75';   
        opp.CloseDate = Date.today().adddays(5);   
        
        Opportunity oppotunity = CloneOpportunityController.prePopulateOppData(opp.Id);
        System.assert(oppotunity != NULL);

        Opportunity clonedOpp = CloneOpportunityController.cloneOpportunity(oppotunity.Id, opp );

        Test.stopTest();

        System.assertEquals(agency.Id, clonedOpp.Agency_Account__c);        
        System.assertEquals(opp.Id, clonedOpp.Cloned_From_Opportunity__c);        
    }
}