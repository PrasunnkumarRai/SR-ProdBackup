@isTest
private class ProposalApproverControllerTest {
    static opportunity opp;
    static  proposal__c prop;
    static ProposalApproverController approverController;
	static User lsmUser;
	static void prepareTestData() { 
        TestDataHelper.createTIMIntegrationCustomSettings();
	    User u = TestDataHelper.getBoomiIntegrationUser();
        lsmUser = [SELECT Id FROM User WHERE UserRole.Name LIKE: 'LSM%' LIMIT 1];
        System.runAs(u){
    		Account acc = TestDataHelper.createAcc('Test Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                        
            acc.Spectrum_Reach_Preferred__c = true;
            insert acc;
    		
            opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
    		opp.Owner = u;
            insert opp;

            System.assert(opp != null);            

        }

        Group__c gr = TestDataHelper.createGroup('Test group');
        insert gr;

        Group_Member__c groupMember = TestDataHelper.createGroupMember(gr.Id);
        groupMember.User__c = UserInfo.getUserId();
        insert groupMember;

        Group_Status__c groupStatus = TestDataHelper.createGroupStatus('Test group status', gr.Id);
        groupStatus.Is_Active__c = true;
        groupStatus.Is_Entry__c = true;
        insert groupStatus;

        User_Approval_Zone__c userApprovalZone = TestDataHelper.createUserApproval(null);
        userApprovalZone.User__c = UserInfo.getUserId();
        insert userApprovalZone;
        
        prop = TestDataHelper.createProposal('Test Proposal',opp.id,'76877',True); 
        prop.TIM_Status__c = 'Test group status';              
        insert prop;
        
        Proposal_Zone__c propZone = TestDataHelper.createProposalZone('3377',prop.Id);
        propZone.TIM_Status__c = 'Test group status';              
        propzone.SurveyId__c = 'Test';
        insert propZone;
        
        UserConnection__c connection = TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');   
        insert connection;

        System.assert(connection != null);

    }


    static void prepareTestDataforLSM() { 
        TestDataHelper.createTIMIntegrationCustomSettings();
        User u = TestDataHelper.getBoomiIntegrationUser();
        lsmUser = [SELECT Id FROM User WHERE UserRole.Name LIKE: 'LSM%' LIMIT 1];
        lsmUser.Approving_Manager__c = UserInfo.getUserId();
        lsmUser.Team_Role__c = 'Sales Manager';
        lsmUser.division__c = 'Central';
        lsmUser.region__c = '';
        lsmUser.sales_office__c = '';
        update lsmUser;
        System.runAs(lsmUser){
            Account acclsm = TestDataHelper.createAcc('Test Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                        
            acclsm.Spectrum_Reach_Preferred__c = true;
            insert acclsm;
            
            opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acclsm.ID);        
            opp.Owner = u;
            insert opp;        

            Group__c gr = TestDataHelper.createGroup('Test group');
            insert gr;

            Group_Member__c groupMember = TestDataHelper.createGroupMember(gr.Id);
            groupMember.User__c = UserInfo.getUserId();
            insert groupMember;

            Group_Status__c groupStatus = TestDataHelper.createGroupStatus('Test group status', gr.Id);
            groupStatus.Is_Active__c = true;
            groupStatus.Is_Entry__c = true;
            insert groupStatus;

            User_Approval_Zone__c userApprovalZone = TestDataHelper.createUserApproval(null);
            userApprovalZone.User__c = UserInfo.getUserId();
            insert userApprovalZone;
            
            prop = TestDataHelper.createProposal('Test Proposal',opp.id,'76877',True); 
            prop.TIM_Status__c = 'Test group status';              
            insert prop;
            
            Proposal_Zone__c propZone = TestDataHelper.createProposalZone('3377',prop.Id);
            propZone.TIM_Status__c = 'Test group status';              
            propzone.SurveyId__c = 'Test';
            insert propZone;
        
            UserConnection__c connection = TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');   
            insert connection;

            System.assert(connection != null);
        }    

    }
	
	static testMethod void approveMethodPositivePathTest() {
    	
		prepareTestData();
		    	   
        approverController = new ProposalApproverController();
        approverController.proId = prop.Id;
        
        
			//Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
			approverController.submit();
            approverController.submitAll();
            approverController.cancelAll();
			approverController.toggleView();
            try{
            approverController.showProposalZones();
            }
            catch(Exception ex){}
            approverController.sendMassEmailNotification('Approval', 'Test comment');
            //ProposalApproverController.sendEmailNotification(prop, 'Approval', 'Test comment', null);
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
            try{
            approverController.approve();
            }
        	catch(Exception ex){}
            
        
        approverController.cancel();

        approverController = new ProposalApproverController();
        approverController.showDetail = false;
        approverController.toggleView();
        approverController.sendMassEmailNotification('Rejection', 'Test comment');
        //ProposalApproverController.sendEmailNotification(prop, 'Rejection', 'Test comment', null); 

        System.runAs(lsmUser){                
            approverController = new ProposalApproverController();
            approverController.proId = prop.Id;           
            approverController.showProposalZones();
        }

        User testUser = TestDataHelper.createUser(true);

        System.runAs(testUser){
            approverController = new ProposalApproverController();
            approverController.proId = prop.Id;
        }
        Test.stopTest();
    }


   /* static testMethod void approveMethodLSMUserTest() {        
        prepareTestData();
        System.runAs(lsmUser){
            UserConnection__c connection = TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');   
            insert connection;    
            approverController = new ProposalApproverController();
            approverController.proId = prop.Id;
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
                approverController.approve();
            Test.stopTest();
            approverController.showProposalZones();
        }
    }*/


    static testMethod void rejectMethodPositivePathTest() {
        prepareTestData();
                   
        approverController = new ProposalApproverController();

        User loggedInUser = [SELECT Id, Name,UserRoleId,UserRole.Name,Profile.Name,ManagerId 
                        FROM User 
                        WHERE Id = :UserInfo.getUserId()];

        System.assert(loggedInUser != null);                

        approverController.proId = prop.Id;

        Test.StartTest();
            Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
            try{
            approverController.reject();
            }
            catch(Exception ex){}
        Test.StopTest();
    }

    static testMethod void rejectMethodLSMUserTest() {
        prepareTestDataforLSM();
        System.runAs(lsmUser){                    
            approverController = new ProposalApproverController();

            User loggedInUser = [SELECT Id, Name,UserRoleId,UserRole.Name,Profile.Name,ManagerId 
                        FROM User 
                        WHERE Id = :UserInfo.getUserId()];

            System.assert(loggedInUser != null);

            approverController.proId = prop.Id;

            Test.StartTest();
                Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
                approverController.reject();
            Test.StopTest();
        }    
    }

    static testMethod void approveAllMethodPositivePathTest() {
        prepareTestData();
                   
        approverController = new ProposalApproverController();

        User loggedInUser = [SELECT Id, Name,UserRoleId,UserRole.Name,Profile.Name,ManagerId 
                        FROM User 
                        WHERE Id = :UserInfo.getUserId()];

        System.assert(loggedInUser != null);

        approverController.proId = prop.Id;

        Test.StartTest();
            Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
            try{
            approverController.approveAll();
            }
            catch(Exception ex){}
        Test.StopTest();
    }

    static testMethod void approveAllMethodLSMUserTest() {
        prepareTestData();
        System.runAs(lsmUser){ 
            UserConnection__c connection = TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');   
            insert connection;             
            approverController = new ProposalApproverController();

            User loggedInUser = [SELECT Id, Name,UserRoleId,UserRole.Name,Profile.Name,ManagerId 
                        FROM User 
                        WHERE Id = :UserInfo.getUserId()];

            System.assert(loggedInUser != null);

            approverController.proId = prop.Id;

            Test.StartTest();
                Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
                approverController.approveAll();
            Test.StopTest();
        }    
    }

    static testMethod void rejectAllMethodPositivePathTest() {
        prepareTestData();
                   
        approverController = new ProposalApproverController();

        User loggedInUser = [SELECT Id, Name,UserRoleId,UserRole.Name,Profile.Name,ManagerId 
                        FROM User 
                        WHERE Id = :UserInfo.getUserId()];

        System.assert(loggedInUser != null);

        approverController.proId = prop.Id;

        Test.StartTest();
            Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
            try{
            approverController.rejectAll();
            }
            catch(Exception ex){}
        Test.StopTest();
    }

    static testMethod void rejectAllMethodLSMUserTest() {
        prepareTestData();
        System.runAs(lsmUser){ 
            UserConnection__c connection = TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');   
            insert connection;          
            approverController = new ProposalApproverController();

            User loggedInUser = [SELECT Id, Name,UserRoleId,UserRole.Name,Profile.Name,ManagerId 
                        FROM User 
                        WHERE Id = :UserInfo.getUserId()];

            System.assert(loggedInUser != null);

            approverController.proId = prop.Id;

            Test.StartTest();
                Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
                approverController.rejectAll();
            Test.StopTest();
        }    
    }
    
}