@isTest
public class TopicAssignmentTriggerTest {
   @testSetup
    static void setupTestData() {
        // Test data for Topic
        Topic testTopic = new Topic(Name = 'Test Topic,Test Topic1,Test Topic2');
        insert testTopic;
        
        //account data
        Account acc = new Account(Name='Test Account');
        insert acc;

        // Test data for Opportunity
       Opportunity testOpportunity = new Opportunity(AccountId=acc.Id, Name = 'Test Opportunity', StageName = 'Closed Won', CloseDate = Date.today());
       insert testOpportunity;
        
       TopicAssignment ta = new TopicAssignment(EntityId=testOpportunity.Id, TopicId=testTopic.Id);
        Test.startTest();
        insert ta;
        Test.stopTest();
    } 
        
        @isTest
        static void testTopicAssignmentTrigger() {
        Test.startTest();
       
        TopicAssignment testTopicAssignmentForDelete = [SELECT Id, TopicId, EntityId, EntityType FROM TopicAssignment LIMIT 1];

        delete testTopicAssignmentForDelete;

       
        Test.stopTest();
           
    }
}