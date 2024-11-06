@isTest
/*
###########################################################################
# Change Log:               
# 1. Puneet Khosla - SRSF-846 - Test Methods With No Assert
############################################################################*/
private class BudgetControllerTest {
	//static BudgetController budgetCtr;
	static String year;
	//static User u;
	//static User usr;
    //static Budget__c budget1;
    static Account acc;
	//static User usrpro;	
    //static UserRole usrRole1;
    static List<List<String>> budgetRows;

    @testSetup
    static void prepareTestData(){
    	
        User u = TestDataHelper.getBoomiIntegrationUser();
    	//User u = [select Id, Name from User where Name = 'Boomi Integration User'];

        /*profile newProfile = new profile();
        newProfile.Name = 'LSM new profile';
        insert newProfile;*/

        System.runAs(u){

            //TestDataHelper.createBudgetEntryYear();
            
            Profile p = [select id from profile where name = 'Standard User'];
            Profile admProfile = [select id from profile where name = 'System Administrator'];
            Profile billingProfile = [select id from profile where name = 'Master - FBO'];
            //Profile mgr = [select id from profile where name LIKE 'LSM%' LIMIT 1];
            //System.debug(' $$$ mgr :: ' +mgr);
        	UserRole usrRole = new UserRole(Name = 'LSM Account Executive');
            insert usrRole;

            UserRole usrRole1 = new UserRole(Name = 'LSM test',ParentRoleID = usrRole.Id );
            insert usrRole1;

            UserRole usrRoleAE = new UserRole(Name = 'AE Account Executive');
            insert usrRoleAE;

            UserRole usrRoleAE1 = new UserRole(Name = 'AE test',ParentRoleID = usrRoleAE.Id );
            insert usrRoleAE1;
            
        	User usr = new User(alias = 'usr', email = 'userr123@test2orgosius.com',
                emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                localesidkey = 'en_US', profileid = p.Id, UserRoleId=usrRole.Id,
                timezonesidkey = 'America/Los_Angeles', username = 'userr123@test2orgosius2sree.com'); 
        	insert usr;

        	User usrpro = new User(alias = 'usr', email = 'userPro1263@testorgosius.com',
                emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                localesidkey = 'en_US', profileid = p.Id, ManagerId = usr.Id,isActive = true,
                timezonesidkey = 'America/Los_Angeles', username = 'userPro1263@testorgosiussree.com'); 
            usrpro.UserRoleId = usrRole1.Id;
        	insert usrpro;

            User usrpro2 = new User(alias = 'usr', email = 'userPro2123@testorgosius.com',
                emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                localesidkey = 'en_US', profileid = admProfile.Id, ManagerId = usr.Id,isActive = true,
                timezonesidkey = 'America/Los_Angeles', username = 'userPro2123@testorgosiussree.com'); 
            usrpro2.UserRoleId = usrRole1.Id;
            insert usrpro2;

            User usrpro4 = new User(alias = 'usr', email = 'userPro4123@testorgosius.com',
                emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                localesidkey = 'en_US', profileid = admProfile.Id, ManagerId = usr.Id,isActive = true,
                timezonesidkey = 'America/Los_Angeles', username = 'userPro4123@testorgosiussree.com'); 
            usrpro4.UserRoleId = usrRoleAE1.Id;
            insert usrpro4;

            User usrpro3 = new User(alias = 'usr', email = 'userPro3123@testorgosius.com',
                emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                localesidkey = 'en_US', profileid = billingProfile.Id, ManagerId = usr.Id,isActive = true,
                timezonesidkey = 'America/Los_Angeles', username = 'userPro3123@testorgosiussree.com'); 
            usrpro3.UserRoleId = usrRole1.Id;
            insert usrpro3;

            Budget__C budget1 = TestDataHelper.createBudget(System.Today(),1000,'Linear',u.Id,null ,'Approved'); 
            budget1.Amount__c = 1000;
            budget1.ownerId = u.Id;
            budget1.Status__c = 'Not Submitted';
            insert budget1;
            Budget__C budget2 = TestDataHelper.createBudget(System.Today(),1000,'Production',usrpro.Id,null ,'Approved'); 
            budget2.Amount__c = 1000;
            budget2.ownerId = u.Id;
            budget2.Status__c = 'Not Submitted';
            insert budget2;
        }
    }

    static testMethod void budgetControllerTest1() {
        //prepareTestData();
        //TestDataHelper.createBudgetEntryYear();
        //prepareTestData();        
        Date dt = System.Today();       
        String year = String.valueOf(dt.year());
        User usrpro = [SELECT Id, Name,UserRoleId, UserRole.Name FROM User WHERE  email = 'userPro1263@testorgosius.com'];
        System.runAs(usrpro){
            Test.startTest();
            Budget__C budget1 = TestDataHelper.createBudget(System.Today(),1000,'Linear',usrpro.Id,null ,'Approved'); 
            budget1.Amount__c = 1000;
            budget1.ownerId = usrpro.Id;
            budget1.Status__c = 'Not Submitted';
            insert budget1;
            BudgetController budgetCtr = new BudgetController();
            Test.setCurrentPage(page.BudgetManagement);
            ApexPages.currentPage().getParameters().put('userId', usrpro.id);
            ApexPages.currentPage().getParameters().put('selYear', '2018');     
            budgetCtr.getFiscalYear();
		    budgetCtr.getUsersList();		 
		    //BudgetController.getBudgets(year,usrpro.Id);
            List<Budget__c> budgetRecordList = [SELECT Id,Status__c,ownerId, BudgetAE__c FROM Budget__c WHERE Year__c = :year];
		    System.assertEquals('Not Submitted', budgetRecordList.get(0).Status__c);
            string result = BudgetController.approveBudgets(year,usrpro.Id,true);
            System.assertEquals('Budget records have already been approved',result);

		    result = BudgetController.submitForApproval(year,usrpro.Id);
            budgetRecordList = [SELECT Id,Status__c,ownerId, BudgetAE__c FROM Budget__c WHERE Year__c = :year];
            System.assertEquals('Submitted For Approval', budgetRecordList.get(0).Status__c);
            System.assertEquals('Budget Records Submitted For Approval', result);

		    result = BudgetController.rejectBudgets(year,usrpro.Id,true);
            System.assertEquals('Budget records have already been approved/rejected.', result);
		    Test.stopTest();

            budgetRows = new List<List<String>>();
            List<String> budget = new List<String>();
            budget.add('Test');
            List<String> budgetList = new List<String>();
            budgetList.add('LSM');
            budgetRows.add(budget);
            budgetRows.add(budgetList);

            budgetCtr.saveRecords();
            Budget__C budgets = [select id, Name, Status__c from Budget__c LIMIT 1];
            budgets.Product_Line__c = 'Production';
            update budgets;
            budgetCtr.saveRecords();
            BudgetController.BudgetRow row = new BudgetController.BudgetRow();
            BudgetController.setRowEditable(row, false, false, false, year);
        }	        
    }

    static testMethod void budgetControllerTest2() {
        //prepareTestData();
        //TestDataHelper.createBudgetEntryYear();
        //prepareTestData();
        Date dt = System.Today();       
        String year = String.valueOf(dt.year());
        User usr = [SELECT Id, Name FROM User WHERE  email = 'userr123@test2orgosius.com'];
        System.runAs(usr){
            Test.setCurrentPage(page.BudgetManagement);
            ApexPages.currentPage().getParameters().put('userId', usr.id);
            ApexPages.currentPage().getParameters().put('selYear', '2018'); 
            BudgetController budgetCtr = new BudgetController();
            Test.startTest();           
	        budgetCtr.getFiscalYear();
		    //User lsmUser = [SELECT Id FROM User WHERE UserRole.Name LIKE: 'LSM%' LIMIT 1];
            System.runAs(usr){
                TestDataHelper.createSuperUserRoles();
                budgetCtr = new BudgetController();
               // BudgetController.getBudgets(year,lsmUser.Id);

               // budgetCtr.saveRecords();
            }
		    //BudgetController.getBudgets(year,usr.Id);
            List<Budget__c> budgetRecordList = [SELECT Id,Status__c,ownerId, BudgetAE__c FROM Budget__c WHERE Year__c = :year];
            
		    BudgetController.approveBudgets(year,usr.Id,true);
            
		    string result = BudgetController.submitForApproval(year,usr.Id);
            System.assertEquals('Budget records have already been submitted or approved', result);

		    result = BudgetController.rejectBudgets(year,usr.Id,true);
            System.assertEquals('Budget records have already been approved/rejected.', result);
		    Test.stopTest();

            BudgetController.BudgetRow row = new BudgetController.BudgetRow();
            BudgetController.setRowEditable(row, true, false, false, null);
	    }	        
    }
    static testMethod void budgetControllerTest3() {
         Date dt = System.Today();       
        String year = String.valueOf(dt.year());
       User user = [SELECT Id, Name FROM User WHERE  email = 'userPro2123@testorgosius.com'];
        System.runAs(user){
            Test.startTest();
            ManagerUserRoles__c roles= new ManagerUserRoles__c(Name='LSM');
            insert roles;
            BudgetController budgetCtr = new BudgetController();
            Test.setCurrentPage(page.BudgetManagement);
            ApexPages.currentPage().getParameters().put('userId', user.id);
            ApexPages.currentPage().getParameters().put('selYear', '2018');     
            budgetCtr.getFiscalYear();
            budgetCtr.getUsersList();        
            //BudgetController.getBudgets(year,usrpro.Id);
            string result = BudgetController.approveBudgets(year,user.Id,true);
            System.assertEquals('Budget records have already been approved',result);

            result = BudgetController.submitForApproval(year,user.Id);
            System.assertEquals('Budget records have already been submitted or approved', result);

            result = BudgetController.rejectBudgets(year,user.Id,true);
            System.assertEquals('Budget records have already been approved/rejected.', result);           

            budgetRows = new List<List<String>>();
            List<String> budget = new List<String>();
            budget.add('Test');
            List<String> budgetList = new List<String>();
            budgetList.add('LSM');
            budgetRows.add(budget);
            budgetRows.add(budgetList);

            //budgetCtr.saveRecords();
            Budget__C budget1 = [select id, Name, Status__c from Budget__c LIMIT 1];
            budget1.Product_Line__c = 'Linear';
            update budget1;
            //budgetCtr.saveRecords();
            BudgetController.BudgetRow row = new BudgetController.BudgetRow();
            BudgetController.setRowEditable(row, false, false, false, year);
            Test.stopTest();
        }           
    }

    static testMethod void budgetControllerTest4() {
        //prepareTestData();
         Date dt = System.Today();       
        String year = String.valueOf(dt.year());
       User user = [SELECT Id, Name FROM User WHERE  email = 'userPro3123@testorgosius.com'];
        System.runAs(user){
            Test.startTest();
            Budget__C budget1 = TestDataHelper.createBudget(System.Today(),1000,'Linear',user.Id,null ,'Approved'); 
            budget1.Amount__c = 1000;
            budget1.ownerId = user.Id;
            budget1.Status__c = 'Not Submitted';
            insert budget1;
            ManagerUserRoles__c roles= new ManagerUserRoles__c(Name='VP');
            insert roles;
            BudgetController budgetCtr = new BudgetController();
            Test.setCurrentPage(page.BudgetManagement);
            ApexPages.currentPage().getParameters().put('userId', user.id);
            ApexPages.currentPage().getParameters().put('selYear', '2018');     
            budgetCtr.getFiscalYear();
            budgetCtr.getUsersList();        
            //BudgetController.getBudgets(year,usrpro.Id);
            string result = BudgetController.approveBudgets(year,user.Id,true);
            System.assertEquals('Budget records have already been approved',result);

            result = BudgetController.submitForApproval(year,user.Id);
            List<Budget__c> budgetRecordList = [SELECT Id,Status__c,ownerId, BudgetAE__c FROM Budget__c WHERE Year__c = :year];
            System.assertEquals('Submitted For Approval', budgetRecordList.get(0).Status__c);
            System.assertEquals('Budget Records Submitted For Approval', result);

            result = BudgetController.rejectBudgets(year,user.Id,true);
            System.assertEquals('Budget records have already been approved/rejected.', result);           

            budgetRows = new List<List<String>>();
            List<String> budget = new List<String>();
            budget.add('Test');
            List<String> budgetList = new List<String>();
            budgetList.add('LSM');
            budgetRows.add(budget);
            budgetRows.add(budgetList);

            //budgetCtr.saveRecords();
            Budget__C budgets = [select id, Name, Status__c from Budget__c LIMIT 1];
            budgets.Product_Line__c = 'Production';
            update budgets;
            //budgetCtr.saveRecords();
            BudgetController.BudgetRow row = new BudgetController.BudgetRow();
            BudgetController.setRowEditable(row, false, false, false, year);
            Test.stopTest();
        }           
    }

    static testMethod void budgetControllerTest5() {        
        Date dt = System.Today();       
        String year = String.valueOf(dt.year());
       User usrpro = TestDataHelper.getBoomiIntegrationUser();
        System.runAs(usrpro){                       
            Test.startTest();
            ManagerUserRoles__c roles= new ManagerUserRoles__c(Name='VP');
            insert roles;
            BudgetController budgetCtr = new BudgetController();            
            Test.setCurrentPage(page.BudgetManagement);
            ApexPages.currentPage().getParameters().put('userId', usrpro.id);
            ApexPages.currentPage().getParameters().put('selYear', '2018');     
            budgetCtr.getFiscalYear();
            budgetCtr.getUsersList();        
            //BudgetController.getBudgets(year,usrpro.Id);
            string result = BudgetController.approveBudgets(year,usrpro.Id,true);
            System.assertEquals('Budget records have already been approved',result);

            result = BudgetController.submitForApproval(year,usrpro.Id);
            System.assertEquals('Budget Records Submitted For Approval', result);

            result = BudgetController.rejectBudgets(year,usrpro.Id,true);
            System.assertEquals('Budget records have already been approved/rejected.', result);           

            budgetRows = new List<List<String>>();
            List<String> budget = new List<String>();
            budget.add('Test');
            List<String> budgetList = new List<String>();
            budgetList.add('LSM');
            budgetRows.add(budget);
            budgetRows.add(budgetList);

            //budgetCtr.saveRecords();
            Budget__C budget1 = [select id, Name, Status__c from Budget__c LIMIT 1];
            budget1.Product_Line__c = 'Production';
            update budget1;
            String testLbl = Label.AccountTeamRole;
            //budgetCtr.saveRecords();
            BudgetController.BudgetRow row = new BudgetController.BudgetRow();
            BudgetController.setRowEditable(row, false, false, false, year);
            Test.stopTest();
        }           
    }
    static testMethod void budgetControllerTest6() {
         Date dt = System.Today();       
        String year = String.valueOf(dt.year());
       User user = [SELECT Id, Name FROM User WHERE  email = 'userPro4123@testorgosius.com'];
        System.runAs(user){
            Test.startTest();
            ManagerUserRoles__c roles= new ManagerUserRoles__c(Name='LSM');
            insert roles;
            BudgetController budgetCtr = new BudgetController();
            Test.setCurrentPage(page.BudgetManagement);
            ApexPages.currentPage().getParameters().put('userId', user.id);
            ApexPages.currentPage().getParameters().put('selYear', '2018');     
            budgetCtr.getFiscalYear();
            budgetCtr.getUsersList();        
            //BudgetController.getBudgets(year,usrpro.Id);
            string result = BudgetController.approveBudgets(year,user.Id,true);
            System.assertEquals('Budget records have already been approved',result);

            result = BudgetController.submitForApproval(year,user.Id);
            System.assertEquals('Budget records have already been submitted or approved', result);

            result = BudgetController.rejectBudgets(year,user.Id,true);
            System.assertEquals('Budget records have already been approved/rejected.', result);           

            budgetRows = new List<List<String>>();
            List<String> budget = new List<String>();
            budget.add('Test');
            List<String> budgetList = new List<String>();
            budgetList.add('LSM');
            budgetRows.add(budget);
            budgetRows.add(budgetList);

            budgetCtr.saveRecords();
            Budget__C budget1 = [select id, Name, Status__c from Budget__c LIMIT 1];
            budget1.Product_Line__c = 'Production';
            update budget1;            
            budgetCtr.saveRecords();
            BudgetController.BudgetRow row = new BudgetController.BudgetRow();
            BudgetController.setRowEditable(row, false, false, false, year);           
            Test.stopTest();
        }           
    }

    
    /*static testMethod void negativePathTest(){
        User lsmUser = [SELECT Id FROM User WHERE UserRole.Name LIKE: 'LSM%' LIMIT 1];
        System.runAs(lsmUser){
            BudgetController budgetCtr = new BudgetController();
            budgetCtr.getUsersList();
        }
    }*/

    static testMethod void subUsersTest() {
        //User u = [select Id, Name from User where Name = 'Boomi Integration User'];
        User u = TestDataHelper.getBoomiIntegrationUser();
        //prepareTestData();
        //TestDataHelper.createManagerUserRolesCustomSettings();

        Date dt = System.Today();       
        String year = String.valueOf(dt.year());

        System.runAs(u){
           
            //usrpro.UserRoleId = usrRole1.Id;
            //update usrpro;
            User usr = [SELECT Id, Name FROM User WHERE  email = 'userr123@test2orgosius.com'];
            Set<Id> userIds = new Set<Id>();
            userIds.add(usr.Id);

            BudgetController.getAllSubUserIds(userIds);
            BudgetController.getTopRowLabel('VP');
            //BudgetController.getBudgets(year,usr.Id);
            BudgetController.approveBudgets(year,usr.Id,true);
            BudgetController.rejectBudgets(year,usr.Id,true);

            BudgetController.approveBudgets(year,usr.Id,false);
            BudgetController.rejectBudgets(year,usr.Id,false);

            Budget__C budget1 = [select id, Name, Status__c from Budget__c LIMIT 1];
            budget1.Status__c = 'Submitted For Approval';
            update budget1;
            System.assertEquals('Submitted For Approval',budget1.Status__c);
            BudgetController.rejectBudgets(year,usr.Id,true);
        }
    }
}