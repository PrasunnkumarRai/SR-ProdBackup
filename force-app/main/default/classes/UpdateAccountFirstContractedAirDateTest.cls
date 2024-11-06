@isTest
private class UpdateAccountFirstContractedAirDateTest {
    static testMethod void testMethod1() {

    	Account acc = TestDataHelper.createAcc('Test Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                                
        insert acc;        

        Account acc2 = TestDataHelper.createAcc('Test Account123', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                                
        acc2.First_Contracted_Air_Date__c = System.today()+1;
        insert acc2;        

        Account agencyRecType = TestDataHelper.createAgency('Test Account','123 Wright Plaza','Omaha','NE','68130','USA');
        insert agencyRecType;

        Id repFirmRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Rep_Firm' AND SobjectType = 'Account' LIMIT 1].Id;

        Account repFirmRecType = new Account(Name = 'Test Account',BillingStreet = '123 Wright Plaza',BillingCity = 'Omaha',
            BillingState ='NE',BillingPostalCode = '68130',BillingCountry = 'USA',Active__c = true,RecordTypeId = repFirmRecTypeId);
        insert repFirmRecType;

        Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
        insert opp;
        System.debug('@@opp '+opp);

        Test.startTest();
        List<Proposal__c>  propList = new List<Proposal__c>();
        proposal__c prop = TestDataHelper.createProposal('Test Proposal',opp.id,'76877',True); 
        prop.Advertiser__c = acc.Id;   
        prop.Active__c = false;
        prop.ProposalExternalId__c='';
        prop.TIM_Status__c = 'Proposal';  
        prop.AE_ID__c = '309';        
        prop.Agency__c = agencyRecType.Id;
        prop.Rep_Firm__c = repFirmRecType.Id;
        prop.Start_Date__c = System.today()+1;

        proposal__c prop2 = TestDataHelper.createProposal('Test Proposal2',opp.id,'76878',True); 
        prop2.Advertiser__c = acc.Id; 
        prop2.ProposalExternalId__c='';  
        prop2.Active__c = false;
        prop2.AE_ID__c = '309';
        prop2.TIM_Status__c = 'Proposal';                  
        prop2.Rep_Firm__c = repFirmRecType.Id;
        prop2.Proposal_Closed__c = true;
        prop2.Start_Date__c = System.today()-1;

        proposal__c prop3 = TestDataHelper.createProposal('Test Proposal13',opp.id,'76877',True); 
        prop3.Advertiser__c = acc2.Id;   
        prop3.Active__c = false;
        prop3.ProposalExternalId__c='';
        prop3.TIM_Status__c = 'Proposal';  
        prop3.AE_ID__c = '309';        
        prop3.Agency__c = agencyRecType.Id;
        prop3.Rep_Firm__c = repFirmRecType.Id;
        prop3.Start_Date__c = System.today();

        proposal__c prop4 = TestDataHelper.createProposal('Test Proposal14',opp.id,'76877',True); 
        prop4.Advertiser__c = acc2.Id;   
        prop4.Active__c = false;
        prop4.ProposalExternalId__c='';
        prop4.TIM_Status__c = 'Proposal';  
        prop4.AE_ID__c = '309';        
        prop4.Agency__c = agencyRecType.Id;
        prop4.Rep_Firm__c = repFirmRecType.Id;
        prop4.Start_Date__c = System.today()-1;

        propList.add(prop); propList.add(prop2); propList.add(prop3); propList.add(prop4);
        insert propList;
        propList.get(0).Proposal_Closed__c = true;
        propList.get(1).Proposal_Closed__c = true;
        propList.get(2).Proposal_Closed__c = true;
        propList.get(3).Proposal_Closed__c = true;
        update propList;
        System.debug('propList---->'+propList);

        UpdateAccountFirstContractedAirDate batch = new UpdateAccountFirstContractedAirDate();
        Database.executeBatch(batch);
        String query = 'SELECT Id, Start_Date__c, Proposal_Closed__c,Proposal_Closed_Date__c, Opportunity__r.AccountId, Opportunity__r.Account.First_Contracted_Air_Date__c FROM Proposal__c WHERE Proposal_Closed__c =true AND Proposal_Closed_Date__c >= LAST_N_DAYS:1';
        UpdateAccountFirstContractedAirDate batch2 = new UpdateAccountFirstContractedAirDate(query);
        Database.executeBatch(batch2);
		system.schedule('Test status Check', '0 0 23 * * ?', batch);
        Test.stopTest();        
    }
}