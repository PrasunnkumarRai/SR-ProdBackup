@isTest
public with sharing class ProposalQueueSyncControllerTest {
    
    @IsTest(seeAlldata = false)
    static void executeMethodPositivePathTest() {
        
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        
        insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');  
        
        System.runAs(u){
            TestDataHelper.createTIMIntegrationCustomSettings();
            
            //Create user connections                 
            insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',u.Id,'TIM','1');  
            //Create an account
            Account acc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
            insert acc;
            
            //Create an opportunity on the above created account
            Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
            // opp.OwnerId = u.Id; 
            insert opp;
            
            List<Opportunity> opplist = new List<Opportunity>();
            opplist.add(opp);
            
            Proposal__c prop = TestDataHelper.createProposal('Test Opportunity Proposal',opp.id, '00000', true);
            insert prop;
            
            ApexPages.StandardSetController controller = new ApexPages.StandardSetController(opplist);
            ApexPages.currentPage().getParameters().put('Id', opp.id);
            
            Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
            Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
            
            
            //Create Proposal
            
            List<Proposal__c> propToInsert = new List<Proposal__c>();
            for(Integer i = 0; i<=10; i++){
                propToInsert.add(TestDataHelper.createProposal('Test Opportunity Proposal'+i,opp.id, '000'+i, true));
            }
            insert propToInsert;
            ProposalQueueSyncController cp = new ProposalQueueSyncController(controller);
            cp.execute();
            System.assert(cp.proposalList!=null);
            
            
        }
    }
    
    
    @IsTest(seeAlldata = false)
    static void executeMethodPositivePathTest1() {
        
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        
        insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');  
        
        System.runAs(u){
            TestDataHelper.createTIMIntegrationCustomSettings();
            
            //Create user connections                 
            insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',u.Id,'TIM','1');  
            //Create an account
            Account acc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
            insert acc;
            
            //Create an opportunity on the above created account
            Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
            // opp.OwnerId = u.Id; 
            insert opp;
            
            List<Opportunity> opplist = new List<Opportunity>();
            opplist.add(opp);
            
            Proposal__c prop = TestDataHelper.createProposal('Test Opportunity Proposal',opp.id, '00000', true);
            insert prop;
            
            ApexPages.StandardSetController controller = new ApexPages.StandardSetController(opplist);
            ApexPages.currentPage().getParameters().put('Id', opp.id);
            
            Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
            Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
            
            
            //Create Proposal
            
            List<Proposal__c> propToInsert = new List<Proposal__c>();
            for(Integer i = 1; i<=5; i++){
                propToInsert.add(TestDataHelper.createProposal('Test Opportunity Proposal'+i,opp.id, '000'+i, true));
            }
            insert propToInsert;
            ProposalQueueSyncController cp = new ProposalQueueSyncController(controller);
            cp.execute();
            System.assert(cp.proposalList!=null);
            
            
        }
    }
    @IsTest(seeAlldata = false)
    static void executeMethodPositivePathTest3() {
        
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        
        insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');  
        
        System.runAs(u){
            TestDataHelper.createTIMIntegrationCustomSettings();
            
            //Create user connections                 
            insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',u.Id,'TIM','1');  
            //Create an account
            Account acc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
            insert acc;
            
            //Create an opportunity on the above created account
            Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
            // opp.OwnerId = u.Id; 
            insert opp;
            
            List<Opportunity> opplist = new List<Opportunity>();
            opplist.add(opp);
            
            ApexPages.StandardSetController controller = new ApexPages.StandardSetController(opplist);
            ApexPages.currentPage().getParameters().put('Id', opp.id);
            
            Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
            Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
     
            ProposalQueueSyncController cp = new ProposalQueueSyncController(controller);
            cp.execute();
           cp.backToOpp();
            
            
        }
    }
    
}