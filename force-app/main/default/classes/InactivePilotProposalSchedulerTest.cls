@isTest
private class InactivePilotProposalSchedulerTest 
{
    public static testmethod void testInactiveproposal()
    {
        Test.startTest();
        //test data
        Account acc = TestDataHelper.createAcc('TestAcc1', 'HitechCity', 'Hyderabad', 'Telangana','500090', 'India');                        
        INSERT acc;
        
        opportunity opp= TestDataHelper.createopportunity('TestOpp',System.today(), 'Planning','Pipeline',acc.ID);
        opp.StageName = 'Closed Lost';
        opp.Loss_Reason__c = 'Lost to No Decision/Unresponsive';
        opp.Closed_Won_Lost_Date__c = System.today();
        INSERT opp;
   
        List<proposal__c> propToInsert = new List<proposal__c>();
        for(Integer i = 1 ;i<=2 ;i++){
            proposal__c prop = TestDataHelper.createProposal('TestProposal'+i, opp.id, NULL, TRUE); 
            prop.Pilot_Proposal_ID__c = '5432'+i; 
            propToInsert.add(prop);
        }

        proposal__c oppBudget = TestDataHelper.createProposal('TestOppBudget', opp.id, NULL, TRUE);
        List<RecordType> recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Opportunity_Budget' LIMIT 1];
        if(recordTypeId.size()>0) 
            oppBudget.RecordTypeId = recordTypeId[0].Id;
        propToInsert.add(oppBudget);

        INSERT propToInsert;
        
        List<Proposal_Zone__c> propZonesToInsert = new List<Proposal_Zone__c>();
        for( proposal__c prop : propToInsert){
            Proposal_Zone__c prop_zone = TestDataHelper.createProposalZone('TestPZ', prop.id);
            propZonesToInsert.add(prop_zone);
        }

        INSERT propZonesToInsert;

        Test.setMock(HttpCalloutMock.class, new ShowSeekerWebServiceMock(200));
        
        InactiveProposalScheduler schedular = new InactiveProposalScheduler();
        String sch = '0 0 23 * * ?';
        System.schedule('TestStatusCheck', sch, schedular);
        Test.stopTest();
    }



    public static testmethod void testInactiveproposalFailed()
    {
        Test.startTest();
        //test data
        Account acc = TestDataHelper.createAcc('TestAcc1', 'HitechCity', 'Hyderabad', 'Telangana','500090', 'India');                        
        INSERT acc;
        
        opportunity opp= TestDataHelper.createopportunity('TestOpp',System.today(), 'Planning','Pipeline',acc.ID);
        opp.StageName = 'Closed Lost';
        opp.Loss_Reason__c = 'Lost to No Decision/Unresponsive';
        opp.Closed_Won_Lost_Date__c = System.today();
        INSERT opp;
   
        List<proposal__c> propToInsert = new List<proposal__c>();
        for(Integer i = 1 ;i<=2 ;i++){
            proposal__c prop = TestDataHelper.createProposal('TestProposal'+i, opp.id, NULL, TRUE); 
            prop.Pilot_Proposal_ID__c = '5432'+i; 
            propToInsert.add(prop);
        }

        proposal__c oppBudget = TestDataHelper.createProposal('TestOppBudget', opp.id, NULL, TRUE);
        List<RecordType> recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Opportunity_Budget' LIMIT 1];
        if(recordTypeId.size()>0) 
            oppBudget.RecordTypeId = recordTypeId[0].Id;
        propToInsert.add(oppBudget);

        INSERT propToInsert;
        
        List<Proposal_Zone__c> propZonesToInsert = new List<Proposal_Zone__c>();
        for( proposal__c prop : propToInsert){
            Proposal_Zone__c prop_zone = TestDataHelper.createProposalZone('TestPZ', prop.id);
            propZonesToInsert.add(prop_zone);
        }

        INSERT propZonesToInsert;

        Test.setMock(HttpCalloutMock.class, new ShowSeekerWebServiceMock(400));
        
        InactiveProposalScheduler schedular = new InactiveProposalScheduler();
        String sch = '0 0 23 * * ?';
        System.schedule('TestStatusCheck', sch, schedular);
        Test.stopTest();
    }

}