@isTest
private class ProposalEditControllerTest {
    
    static Opportunity opp;
    static Proposal__c prop;
    static ProposalEditController editController;
    
    static testMethod void prepareTestData() { 
    
        TestDataHelper.createTIMIntegrationCustomSettings();        
        User u = TestDataHelper.getBoomiIntegrationUser();
        
        System.runAs(u){

            Account acc = TestDataHelper.createAcc('Test Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                        
            INSERT acc;
            
            opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.Id);
            INSERT opp;
            
            prop = TestDataHelper.createProposal('Test Proposal',opp.Id,'76877',True);  
            prop.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;             
            INSERT prop;
            
            List<Proposal__c> proposals = [SELECT Id, TIM_Id__c,Opportunity__c, RecordType.Name, Advertiser__c
                                            ,Agency__c FROM Proposal__c WHERE ID=:prop.Id];
            System.debug('@@proposals '+proposals);

            UserConnection__c connection = TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');   
            INSERT connection;

            List<UserConnection__c> userConnection =[Select User__c,AE_Id__c, TIM_System__c, Username__c
                                                    FROM UserConnection__c
                                                    WHERE ID=:connection.Id];
        
            ApexPages.StandardController sc = new ApexPages.StandardController(proposals[0]);
            ApexPages.currentPage().getParameters().put('Id',prop.Id);

            String Id = ApexPages.currentPage().getParameters().get('Id');
            System.assertEquals(true,Id!=null);
            
            Test.StartTest();
            Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
            Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
                editController = new ProposalEditController(sc);
                editController.getTimURL();
                editController.back();
                editController.complete();
                editController.execute();
                editController.validate();
                delete proposals;
                try{
                    editController = new ProposalEditController(sc);
                    editController.complete();
                }catch(Exception ex){}
            
            Test.StopTest();
        }
    }
    
    static testMethod void executeTestLinearProposal(){
        TestDataHelper.createTIMIntegrationCustomSettings();
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.runAs(u){
            Account acc = TestDataHelper.createAcc('Test Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                        
            INSERT acc;
            
            opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.Id);
            INSERT opp;
            
            prop = TestDataHelper.createProposal('Test Proposal',opp.Id,'',True);
            prop.RecordTypeId = TestDataHelper.LinearRecTypeId;
            prop.TIM_System__c = 'St. Louis Local';
            INSERT prop;

            List<Proposal__c> proposals = [SELECT Id, TIM_Id__c,Opportunity__c, RecordType.Name, Advertiser__c
                                            ,Agency__c FROM Proposal__c WHERE ID=:prop.Id];
            System.debug('prpp:'+proposals);           

            UserConnection__c connection = TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');   
            INSERT connection;                     

            Test.StartTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(proposals[0]);
            ApexPages.currentPage().getParameters().put('Id',prop.Id);

            String Id = ApexPages.currentPage().getParameters().get('Id');
            System.assertEquals(true,Id!=null);

            editController = new ProposalEditController(sc);
            Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
            Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
            editController.getTimURL();
            editController.back();
            editController.complete();
            editController.execute();
            editController.validate();
            editController.invokeTakeOwership();
            delete proposals;
            Test.stopTest();
        }  
    }
    
    static testMethod void negativeTest() {
       
        User u = TestDataHelper.getBoomiIntegrationUser();
       
        System.runAs(u){
            Account acc = TestDataHelper.createAcc('Test Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                        
            INSERT acc;
            
            opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.Id);
            INSERT opp;
            
            prop = TestDataHelper.createProposal('Test Proposal',opp.Id,'',True);               
            INSERT prop;
            
            List<Proposal__c> proposals = [SELECT Id, TIM_Id__c,Opportunity__c, RecordType.Name, Advertiser__c
                                            ,Agency__c FROM Proposal__c WHERE ID=:prop.Id];
                                            
            ApexPages.StandardController sc = new ApexPages.StandardController(proposals[0]);
            ApexPages.currentPage().getParameters().put('Id',prop.Id);

            String Id = ApexPages.currentPage().getParameters().get('Id');
            System.assertEquals(true,Id!=null);
                
            editController = new ProposalEditController(sc);
            editController.validateTakeOwnershipBtn();
            editController.invokeTakeOwership();
        }
            List<Proposal__c> proposals = [SELECT Id, TIM_Id__c,Opportunity__c, RecordType.Name, Advertiser__c
                                            ,Agency__c FROM Proposal__c WHERE ID=:prop.Id];
                                            
            ApexPages.StandardController sc = new ApexPages.StandardController(proposals[0]);
            ApexPages.currentPage().getParameters().put('Id',prop.Id);

            String Id = ApexPages.currentPage().getParameters().get('Id');
            System.assertEquals(true,Id!=null);
                
            editController = new ProposalEditController(sc);
            editController.validateTakeOwnershipBtn();
            editController.invokeTakeOwership();
    }

    static testMethod void testEditProposalForSSuser() 
    {
        User u = TestDataHelper.createSystemAdminUser(true);
        u.ShowSeeker_User__c=true;
        UPDATE u;

        System.runAs(u)
        {
            Account acc = TestDataHelper.createAcc('Test Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                        
            INSERT acc;
            
            opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);    
            opp.OwnerId = u.Id;    
            INSERT opp;
            
            List<Proposal__c> propLst = new List<Proposal__c>();
            prop = TestDataHelper.createProposal('Test Proposal',opp.Id,'76877',True);  
            prop.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;             
            propLst.add(prop);            
            
            Proposal__c prop2 = TestDataHelper.createProposal('Test Proposal2',opp.Id,'',True);
            prop2.RecordTypeId = TestDataHelper.LinearRecTypeId;
            propLst.add(prop2);

            INSERT propLst;

            List<Proposal__c> proposals = [SELECT Id, Opportunity__c, RecordType.Name, Advertiser__c, Agency__c FROM Proposal__c WHERE RecordTypeId =: TestDataHelper.LinearRecTypeId];

            System.debug('propasals-->:'+proposals);                                

            Test.StartTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(proposals[0]);
            ApexPages.currentPage().getParameters().put('Id',prop2.Id);

            String Id = ApexPages.currentPage().getParameters().get('Id');
            System.assertEquals(true, Id != NULL);

            Test.setMock(HttpCalloutMock.class, new ShowSeekerWebServiceMock(200));

            editController = new ProposalEditController(sc);          
            editController.execute();

            System.assertEquals(null, editController.pageMsg);
            System.assertEquals('https://spectrumreach.showseeker.com/123456789', editController.response);
           
            DELETE proposals;
            //Remove Opportunity budget
            editController.oppBudgetProposal = prop;
            editController.deleteOpportunityBudget();
            Test.stopTest();
        } 
    }

    static testMethod void testEditProposalFailedForSSuser() 
    {
        User u = TestDataHelper.createSystemAdminUser(true);
        u.ShowSeeker_User__c=true;
        UPDATE u;

        System.runAs(u)
        {
            Account acc = TestDataHelper.createAcc('Test Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                        
            INSERT acc;
            
            opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.Id);
            opp.OwnerId = u.Id;    
            INSERT opp;
            
            prop = TestDataHelper.createProposal('Test Proposal2',opp.Id,'',True);
            prop.Pilot_Proposal_ID__c = '12345678';
            prop.RecordTypeId = TestDataHelper.LinearRecTypeId;
            INSERT prop;

            List<Proposal__c> proposals = [SELECT Id, Opportunity__c, RecordType.Name, Advertiser__c, Agency__c FROM Proposal__c WHERE ID=:prop.Id];

            System.debug('propasals-->:'+proposals);                                

            Test.StartTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(proposals[0]);
            ApexPages.currentPage().getParameters().put('Id',prop.Id);

            String Id = ApexPages.currentPage().getParameters().get('Id');
            System.assertEquals(true, Id != NULL);

            Test.setMock(HttpCalloutMock.class, new ShowSeekerWebServiceMock(400));

            editController = new ProposalEditController(sc);          
            editController.execute();

            String errorMsg = editController.response;
            System.assert(errorMsg.contains('unable to find proposal with id 12345678'));

            DELETE proposals;
            Test.stopTest();
        } 
    }
}