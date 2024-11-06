@isTest
public class mapProposalControllerTest {
    @testSetup
    static void setup() {
        // Create a test user to assign as the owner of the opportunity
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User u = new User(Alias = 'testsu', Email='testuser@examp.com',
            EmailEncodingKey='UTF-8', LastName='Testig', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
            UserName='testuser@examp.com');
        insert u;
  Account acc = new Account(Name = 'Test Account');
        insert acc;
        // Create a test Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today(),
            OwnerId = UserInfo.getUserId(),
            AccountId = acc.Id    
        );
        insert opp;

        // Set the current page parameters
        Test.setCurrentPageReference(new PageReference('somePage'));
        ApexPages.currentPage().getParameters().put('id', opp.Id);
    }

    @isTest
    static void testMapProposalController() {
        // Get the test opportunity id from the setup method
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];

        // Simulate the StandardController
        ApexPages.StandardController sc = new ApexPages.StandardController(testOpp);

        // Instantiate the mapProposalController
        mapProposalController controller = new mapProposalController(sc);
         controller.aeEmail='test@gmail.com.invald';
          controller.opp=testOpp;
       
    }
}