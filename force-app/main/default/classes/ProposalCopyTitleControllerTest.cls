@isTest
private class ProposalCopyTitleControllerTest {
    //static Opportunity opp;
    //static Proposal__c prop;
    static ProposalCopyTitleController copyTitleController;

    @testSetup
    static void prepareTestData() { 
        Account acc = TestDataHelper.createAcc('Test Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                        
        insert acc;
            
        Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
        insert opp;
        
        Proposal__c prop = TestDataHelper.createProposal('Test Proposal',opp.id,'76877',True);  
        //prop.RecordTypeId = TestDataHelper.oppBudgetRecTypeId; 
        prop.Traffic_Order_Number__c = '123456';
        prop.Eclipse_Customer_ID__c = 'TWCA - 000189828';
        insert prop;  

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
    }        

    static testMethod void getCopyTitles () {
        Proposal__c prop =  [SELECT Id, Name, Traffic_Order_Number__c, Eclipse_Customer_ID__c FROM Proposal__c LIMIT 1];
        List<Proposal__c> propList = ProposalCopyTitleController.getProposalList(prop.Id);
        ProposalCopyTitleController.mock = new ProposalCopyTitleMockImpl(true, 200, 'OK');
        Test.StartTest();        
        ProposalCopyTitleController.getCopyTitlesForProposal(prop.Id);       
        Test.StopTest();
    }   

    static testMethod void getCopyTitlesMultiTrafficOrderMultiEclipse() {
        Proposal__c prop =  [SELECT Id, Name, Traffic_Order_Number__c, Eclipse_Customer_ID__c FROM Proposal__c LIMIT 1];
        prop.Traffic_Order_Number__c = '123456, 121212';
        prop.Eclipse_Customer_ID__c = 'TWCA - 000189828 | CHFL - 000198823';
        update prop;
        List<Proposal__c> propList = ProposalCopyTitleController.getProposalList(prop.Id);
        ProposalCopyTitleController.mock = new ProposalCopyTitleMockImpl(true, 200, 'OK');
        Test.StartTest();
        try{    
            ProposalCopyTitleController.getCopyTitlesForProposal(prop.Id);
        } 
        catch (Exception ex){ 
        System.assertEquals(ProposalCopyTitleController.pageMsg, System.Label.Proposal_has_Multiple_Traffic_Orders_in_Multiple_Eclipse_Systems);
        }
        Test.StopTest();
    }   

    static testMethod void getCopyTitlesMultiTrafficOrders() {
        Proposal__c prop =  [SELECT Id, Name, Traffic_Order_Number__c, Eclipse_Customer_ID__c FROM Proposal__c LIMIT 1];
        prop.Traffic_Order_Number__c = '123456, 121212';
        update prop;        
        List<Proposal__c> propList = ProposalCopyTitleController.getProposalList(prop.Id);
        ProposalCopyTitleController.mock = new ProposalCopyTitleMockImpl(true, 200, 'OK');
        Test.StartTest();
        try{    
            ProposalCopyTitleController.getCopyTitlesForProposal(prop.Id);
        } catch (Exception ex){
          //  System.assert(ex.getMessage()!=Null);
            System.assertEquals(ProposalCopyTitleController.pageMsg, System.Label.Proposal_has_Multiple_Traffic_Orders_in_EclipseSystem);
        }           
        Test.StopTest();
    } 

    static testMethod void getCopyTitlesTrafficOrderNotFound() {
        Proposal__c prop =  [SELECT Id, Name, Traffic_Order_Number__c, Eclipse_Customer_ID__c FROM Proposal__c LIMIT 1];
        prop.Traffic_Order_Number__c = '';
        prop.Eclipse_Customer_ID__c = '';
        update prop;        
        List<Proposal__c> propList = ProposalCopyTitleController.getProposalList(prop.Id);
        ProposalCopyTitleController.mock = new ProposalCopyTitleMockImpl(true, 200, 'OK');
        Test.StartTest();
        try{    
            ProposalCopyTitleController.getCopyTitlesForProposal(prop.Id);
        } catch (Exception ex){            
           // System.assertEquals(ProposalCopyTitleController.pageMsg, 'Exception occured during CopyTitlesForProposal API call: ');
            System.assertEquals(ProposalCopyTitleController.pageMsg, System.Label.Traffic_Order_Number_Eclipse_Customer_Number_not_found);
        } 
        Test.StopTest();
    }    
}