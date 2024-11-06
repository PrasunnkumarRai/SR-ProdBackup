@istest
public class InactiveProposalSchedulerTest {
    public static testmethod void testInactiveproposal(){
        Test.startTest();
        //test data
        Account acc = TestDataHelper.createAcc('Test Account1', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                        
        insert acc;
        List<opportunity> oppToInsert = new List<opportunity>();

        opportunity opp= TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);
        opp.StageName = 'Closed Lost';
        opp.Loss_Reason__c = 'Lost to No Decision/Unresponsive';
        opp.Closed_Won_Lost_Date__c = System.today();
        //opp.Active_Proposal_Count__c=1;
        oppToInsert.add(opp);
        oppToInsert.add(TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID));

        Insert oppToInsert;
        
       User loggedInUser = [SELECT Id, Name,UserRoleId,UserRole.Name,Profile.Name,ManagerId FROM User WHERE Id = :UserInfo.getUserId()];
        // boomiUser = TestDataHelper.getBoomiIntegrationUser();
        System.debug('User name::'+loggedInUser);
        List<proposal__c> propToInsert = new List<proposal__c>();
        for(Integer i = 1 ;i<=2 ;i++){
            proposal__c prop = TestDataHelper.createProposal('Test Proposal'+i,opp.id,'76877'+i,True); 
            prop.TIM_Status__c = 'Test group status'; 
            prop.TIM_System__c='St. Louis Local';
            propToInsert.add(prop);
        }
        proposal__c prop = TestDataHelper.createProposal('Test Proposal',opp.id,'76877',True);
        List<Recordtype> recordTypeId = [Select id from Recordtype where developerName = 'Opportunity_Budget' limit 1];
        if(recordTypeId.size()>0) prop.RecordTypeId = recordTypeId[0].Id;
        propToInsert.add(prop);
        Insert propToInsert;
        
        List<Proposal_Zone__c> propZonesToInsert = new List<Proposal_Zone__c>();
        for( proposal__c proposl : propToInsert){
            Proposal_Zone__c prop_zone = TestDataHelper.createProposalZone('Test Proposal', proposl.id);
            propZonesToInsert.add(prop_zone);
        }

        Insert propZonesToInsert;

        UserConnection__c connection = TestDataHelper.createUserConnection('St. Louis Local', 'SFDCUser',UserInfo.getUserId(),'','1');
        insert connection; 
        
        InactiveProposalScheduler inprosche=new InactiveProposalScheduler();
        String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, inprosche);
        Test.stopTest();
    }

}