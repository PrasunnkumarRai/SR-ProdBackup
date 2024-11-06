@IsTest
public class AdminUtilityCommonHelperControllerTest  {
    public static testmethod void testGetUsers(){
        Test.startTest();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive']; //Profile
		Profile objProfileAC = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Coordinator']; //Profile
        Profile objProfileSSM = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Sales Support Manager']; //Profile
        Profile objProfileLSM = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Local sales Manager']; //Profile
        Profile objProfileDOS = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Director of Sales']; //Profile
       
       
        
        User userAE1 = TestUtil.prepareUser();
        userAE1.FirstName = 'Test';
        userAE1.LastName = 'user1';
        userAE1.Username = 'testae1@mands.com';
        userAE1.Budget_type__c = 'Local';
        userAE1.rate_plan_status__c = 'Draft';
        userAE1.Budget_product_Lines__c = 'Linear/News/Sports';
        userAE1.Profile = objProfile;
        insert userAE1;

       /* User userAE2 = TestUtil.prepareUser();
        userAE2.FirstName = 'Demo';
        userAE2.LastName = 'user';
        userAE2.Username = 'testae2@mands.com';                          // Commented out because of too much SOQL Query.
        userAE2.Budget_type__c = 'Local';
        userAE2.rate_plan_status__c = 'Draft';
        userAE2.Budget_product_Lines__c = 'Linear/News/Sports';
        userAE2.Profile = objProfile;
        insert userAE2;
        
        User userAE3 = TestUtil.prepareUser();
        userAE3.FirstName = 'Demo';
        userAE3.LastName = 'user1';
        userAE3.Username = 'testae3@mands.com';
        userAE3.Budget_type__c = 'National';
        userAE3.rate_plan_status__c = 'Draft';
        userAE3.Budget_product_Lines__c = 'Linear/News/Sports';
        userAE3.ProfileId = objProfile.Id;
        insert userAE3;
        
        User userAE4 = TestUtil.prepareUser();
        userAE4.FirstName = 'Demo';
        userAE4.LastName = 'user3';
        userAE4.Username = 'testae4@mands.com';
        userAE4.Budget_type__c = 'Local';
        userAE4.rate_plan_status__c = 'Draft';
        userAE4.Budget_product_Lines__c = 'Linear/News/Sports';
        userAE4.ProfileId = objProfile.Id;
        insert userAE4; */
        
        User userAE5 = TestUtil.prepareUser();
        userAE5.FirstName = 'Demo';
        userAE5.LastName = 'user2';
        userAE5.Username = 'testae5@mands.com';
        userAE5.Budget_type__c = 'Local';
        userAE5.rate_plan_status__c = 'Draft';
        userAE5.Budget_product_Lines__c = 'Linear/News/Sports';
        userAE5.ProfileId = objProfile.Id;
        insert userAE5;
        
       /*  User userDOS = TestUtil.prepareUser();    // Created for DOS Profile.
        userDOS.FirstName = 'Demo'; 
        userDOS.LastName = 'user3';
        userDOS.Username = 'testdos@mands.com';
        userDOS.Budget_type__c = 'Local';
        userDOS.rate_plan_status__c = 'Draft';
        userDOS.Budget_product_Lines__c = 'Linear/News/Sports';
        userDOS.ProfileId = objProfileDOS.Id;
        insert userDOS;  */
        
    	
    	User userSysAdmin  = TestUtil.prepareUser();
    	insert userSysAdmin;
    	
        
        User userSSM = new User();
        userSSM.UserName='testSalesManager1102@mands.com';
    	userSSM.ProfileId = objProfileSSM.Id;
    	userSSM.Approving_Manager__c = userSysAdmin.Id;
    	userSSM.Team_Role__c = 'Planner';
        userSSM.Alias = 'Test1';
        userSSM.Email = 'test1.ms@charter.com';
        userSSM.EmailEncodingKey = 'UTF-8';
        userSSM.LastName = 'Test1';
        userSSM.LanguageLocaleKey = 'en_US';
        userSSM.LocaleSidKey = 'en_US';
        userSSM.TimeZoneSidKey='America/Los_Angeles';
        insert userSSM;
        
        User userLSM = new User();
        userLSM.UserName='testLocalSalesManager1102@mands.com';
    	userLSM.ProfileId = objProfileLSM.Id;
    	userLSM.Approving_Manager__c = userSysAdmin.Id;
    	userLSM.Team_Role__c = 'Sales Manager';
        userLSM.Alias = 'Test1';
        userLSM.Email = 'test1.ms@charter.com';
        userLSM.EmailEncodingKey = 'UTF-8';
        userLSM.LastName = 'Test1';
        userLSM.LanguageLocaleKey = 'en_US';
        userLSM.LocaleSidKey = 'en_US';
        userLSM.TimeZoneSidKey='America/Los_Angeles';
        insert userLSM;
        
         User userdos = new User();
        userdos.UserName='testLocalSalesManager110212@mands.com';
    	userdos.ProfileId = objProfileDOS.Id;
    	userdos.Approving_Manager__c = userSysAdmin.Id;
    	userdos.Team_Role__c = 'Sales Manager';
        userdos.Alias = 'Test12';
        userdos.Email = 'test12.ms@charter.com';
        userdos.EmailEncodingKey = 'UTF-8';
        userdos.LastName = 'Test12';
        userdos.LanguageLocaleKey = 'en_US';
        userdos.LocaleSidKey = 'en_US';
        userdos.TimeZoneSidKey='America/Los_Angeles';
        insert userdos;

       
        List<String> userIds = new List<String>{String.Valueof(userAE1.Id)};
		String userIcon = 'standard:user';
        
        
        
        User userAE = TestUtil.createAEUser();
    	userAE.ProfileId = objProfileAC.Id;
    	userAE.Approving_Manager__c = userSysAdmin.Id;
    	userAE.Team_Role__c = 'Account Executive';
    	update userAE;
        
        List<LookupSearchResult> results = new List<LookupSearchResult> ();
        results.add(
			            new LookupSearchResult(
			                                   userAE1.Id,
			                                   'User',
			                                   userIcon,
			                                   '',
			                                   'Email : ' +  + '\n' + ' | Profile : ' +  + '\n' + ' | Manager : '
			)
			);
        results[0].getId();
        results[0].getSObjectType();
        results[0].getIcon();
        results[0].getTitle();
        results[0].getSubtitle();
        
        AdminUtilityCommonHelperController.getUsers('Demo',userIds,'user');
        AdminUtilityCommonHelperController.getUsers('Demo',userIds,'local');
        AdminUtilityCommonHelperController.getUsers('Demo',userIds,'National');
        AdminUtilityCommonHelperController.getUsers('Demo',userIds,'');
        AdminUtilityCommonHelperController.getUsers('Demo',userIds,'AccountCreation');
        System.runAs(userAE) {
            AdminUtilityCommonHelperController.getUsers('Demo',userIds,'AccountCreation');
        }
		System.runAs(userSSM) {
            AdminUtilityCommonHelperController.getUsers('Demo',userIds,'AccountCreation');
        }
        System.runAs(userLSM) {
           AdminUtilityCommonHelperController.getUsers('Demo',userIds,'AccountCreation');
        }
       System.runAs(userdos){
            AdminUtilityCommonHelperController.getUsers('Demo',userIds,'AccountCreation');        //Verify
        } 
        Test.stopTest();

    }
    public static testmethod void testGetUserTeam(){
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - National Sales Manager']; //Profile
        User userAE1 = TestUtil.prepareUser();
        userAE1.FirstName = 'Test';
        userAE1.LastName = 'user1';
        userAE1.Username = 'testae1@mands.com';
        userAE1.Budget_type__c = 'Local';
        userAE1.rate_plan_status__c = 'Draft';
        userAE1.Budget_product_Lines__c = 'Linear/News/Sports';
        insert userAE1;

        
        User user1 = TestUtil.prepareUser();                  // 
        user1.HR_Manager__c = userAE1.Id;
        insert user1;
        User user2 = TestUtil.prepareUser();
        user2.HR_Manager__c = userAE1.Id;
        user2.ProfileId=objProfile.Id;
        insert user2;                                                // Test cLass enhancement



        Test.startTest();
        AdminUtilityCommonHelperController admUtilHelper = new AdminUtilityCommonHelperController();
        admUtilHelper.getUserTeam(userAE1.Id);
        Test.stopTest();

    }
    
    public static testmethod void test(){
       
        String validQuery = 'Budget_User__c != null';
        System.assertEquals('True', AdminUtilityCommonHelperController.verifyQuery(validQuery));
        
        // Test query that should fail
        String invalidQuery = 'Random = "test"';
        System.assertEquals('Exception', AdminUtilityCommonHelperController.verifyQuery(invalidQuery));
    }
    }