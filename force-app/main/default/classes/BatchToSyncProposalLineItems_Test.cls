@isTest
public class BatchToSyncProposalLineItems_Test {
    @testSetup
    //****Creation of test data
    static void createTestdata() {
        
        Account acc = TestDataHelper.createAcc('Test Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                        
        insert acc;
        Opportunity opp= TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
        insert opp;
        
        User loggedInUser = [SELECT Id, Name,UserRoleId,UserRole.Name,Profile.Name,ManagerId 
                             FROM User WHERE Id = :UserInfo.getUserId()];
        
        Proposal__c prop = TestDataHelper.createProposal('Test Proposal',opp.Id,'76877',True); 
        prop.TIM_Status__c = 'Test group status'; 
        prop.TIM_System__c='St. Louis Local';
        insert prop;
        
        UserConnection__c connection = TestDataHelper.createUserConnection('St. Louis Local', 'loggedInUser', UserInfo.getUserId(),'TIM','1');
        insert connection;  
    }
    
    @isTest
    // ***test method for testing functionlity
    static void BatchToSyncProposalLineItemsPositiveTest() {
        String Query = 'SELECT Id, Opportunity__r.OwnerId, TIM_System__c FROM Proposal__c LIMIT 100';
        Proposal__c tempProposal = [SELECT Id, Opportunity__r.OwnerId, TIM_System__c FROM Proposal__c LIMIT 1];
        UserConnection__c connection=[SELECT Id, User__c, TIM_System__c FROM UserConnection__c WHERE User__c=:UserInfo.getUserId() AND TIM_System__c='St. Louis Local'];
        System.debug('@2'+tempProposal.Opportunity__r.OwnerId);
        BatchToSyncProposalLineItems obj = new BatchToSyncProposalLineItems(Query);
      
        Test.startTest(); 
        Database.executeBatch(obj); 
        Test.stopTest();    
    }
}