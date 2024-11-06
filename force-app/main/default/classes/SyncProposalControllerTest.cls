@isTest
public with sharing class SyncProposalControllerTest {
    
    @IsTest(seeAlldata = false)
    static void syncProposalTest() {
        
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        
        System.runAs(u){
            TestDataHelper.createTIMIntegrationCustomSettings();
            
            //Create user connections
            insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
            
            //Create an account
            Account acc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
            insert acc;
            System.assert(acc.Id != null);
            
            //Create an opportunity on the above created account
            Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
            opp.OwnerId = u.Id; 
            insert opp;
            System.assert(opp.Id != null);
 
            //Create Proposal
            Proposal__c p = TestDataHelper.createProposal('Test Opportunity Proposal',opp.Id, '00000', true);
            insert p;
            
            ApexPages.StandardController controller = new ApexPages.StandardController(p);
            ApexPages.currentPage().getParameters().put('Id', p.Id);
                    
            SyncProposalController cp = new SyncProposalController(controller);         
            cp.syncProposals();

            // Code Added for SRSF - 1101
            SyncProposalController.ResultWrapper  result = SyncProposalController.syncProposal(p.Id);
            
            // Code to Add St. Louis Local Partition in Cache
            String timSystem = 'StLouisLocal';
            String partitionName = 'local.TIMAccess';
            Cache.OrgPartition newpart = new Cache.OrgPartition(partitionName);
            Map<String,TIMUserAccess.User> timuserMap = new Map<String,TIMUserAccess.User>();
            TIMUserAccess.User timUsr = new TIMUserAccess.User();
            timUsr.UID = 2;
            timUsr.UN = 'SFDCUser';
            timUsr.UP = 'us3th3F0RCE!';
            timuserMap.put('St. Louis Local', timUsr);
            newpart.put('StLouisLocal', timuserMap);
            //Cache code ends here
            
            result = SyncProposalController.syncProposal(p.Id);
            Delete [SELECT Id FROM UserConnection__c LIMIT 1];
            result = SyncProposalController.syncProposal(p.Id);
            //Ends here
        }
    }
}