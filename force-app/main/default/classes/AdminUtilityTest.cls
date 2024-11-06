@IsTest
public class AdminUtilityTest {

	public static testmethod void testSBAggregateFuture()
	{
		Test.startTest();
		User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
		Account acc = TestDataHelper.createAdvertiser('Advertiser Account123', '123 Wright Plaza', 'Omaha', 'NE', '681030', 'USA');
		insert acc;
		AccountConnection__c accCon = TestDataHelper.createAccountConnection(acc.Id);
		accCon.Tim_ID__c = '5413';
		insert accCon;
		System.assert(acc != null);

		System.runAs(thisUser) {
			//Create User
			User userAE = TestUtil.prepareUser();
			userAE.HR_Manager__c = thisUser.Id;
			userAE.Username = 'testae@mands.com';
			userAE.Budget_type__c = 'Local';
			userAE.rate_plan_status__c = 'Draft';
			userAE.Budget_product_Lines__c = 'Linear/News/Sports';
			insert userAE;

			//create Sales Budget
			Sales_Budget__c sb = new Sales_Budget__c();
			sb = TestUtil.getSalesBudgetRec(userAE, acc);
			sb.Type__c = 'Data';
			sb.Product_Line__c = 'Production';
			sb.Amount__c = 9000;
			sb.old_budget_user__c = userAE.Id;
			sb.Budget_user__c = userAE.Id;
			sb.External_Id__c = '008' + userAE.id + System.today();
			insert sb;

			Sales_Budget__c sb1 = new Sales_Budget__c();
			sb1 = TestUtil.getSalesBudgetRec(userAE, acc);
			sb1.Type__c = 'Data';
			sb1.Product_Line__c = 'Digital';
			sb1.Amount__c = 10000;
			sb1.old_budget_user__c = userAE.Id;
			sb1.Budget_user__c = userAE.Id;
			sb1.External_Id__c = '007' + userAE.id + System.today();
			insert sb1;

			AdminUtility.initiateSBAggregate(userAE.ID);
		}
		Test.stopTest();
	}

	public static testmethod void testCall() {

		User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
		Account acc = TestDataHelper.createAdvertiser('Advertiser Account123', '123 Wright Plaza', 'Omaha', 'NE', '681030', 'USA');
		insert acc;
		Test.startTest();
		Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Master - Account Executive'];
		User userAE1 = new User();
		userAE1.ProfileId = objProfile.Id;
		userAE1.FirstName = 'User';
		userAE1.LastName = 'Test';
		userAE1.Alias = 'Test12';
		userAE1.EmailEncodingKey = 'UTF-8';
		userAE1.HR_Manager__c = thisUser.Id;
		userAE1.Username = 'testae1234567@mands.com';
		userAE1.Budget_type__c = 'Local';
		userAE1.rate_plan_status__c = 'Draft';
		userAE1.Budget_product_Lines__c = 'Linear/News/Sports';
		userAE1.LanguageLocaleKey = 'en_US';
		userAE1.LocaleSidKey = 'en_US';
		userAE1.TimeZoneSidKey = 'America/Los_Angeles';
		userAE1.Email = 'test@charter.com';

		insert userAE1;

		User userAE3 = TestUtil.prepareUser();
		userAE3.HR_Manager__c = thisUser.Id;
		userAE3.Username = 'testae1234@mands.com';
		userAE3.Budget_type__c = 'Local';
		userAE3.rate_plan_status__c = 'Draft';
		userAE3.Budget_product_Lines__c = 'Linear/News/Sports';
		insert userAE3;
		//create Sales Budget
		Sales_Budget__c sb = new Sales_Budget__c();
		sb = TestUtil.getSalesBudgetRec(userAE1, acc);
		sb.Type__c = 'Data';
		sb.Product_Line__c = 'Production';
		sb.Amount__c = 9000;
		sb.old_budget_user__c = userAE1.Id;
		sb.Budget_user__c = userAE1.Id;
		sb.External_Id__c = '008' + userAE1.id + System.today();
		insert sb;


		Sales_Budget__c sb1 = new Sales_Budget__c();
		sb1 = TestUtil.getSalesBudgetRec(userAE1, acc);
		sb1.Type__c = 'Data';
		sb1.Product_Line__c = 'Digital';
		sb1.Amount__c = 10000;
		sb1.old_budget_user__c = userAE1.Id;
		sb1.Budget_user__c = userAE1.Id;
		sb1.External_Id__c = '007' + userAE1.id + System.today();
		sb1.Status__c = 'Forecast Intermediate Approval';
		insert sb1;

		Sales_Budget_Approval__c ob = new Sales_Budget_Approval__c();
		ob = TestUtil.getSalesBudgetApprovalRec(userAE1, sb1);
		ob.Status__c = 'Forecast Pending';
		insert ob;
		system.debug('Sales Console:' + ob.Id + ',' + sb1.Id + ',Sales :' + ob);

		User userAE2 = TestUtil.prepareUser();
		userAE2.HR_Manager__c = thisUser.Id;
		userAE2.Username = 'testae12345@mands.com';
		userAE2.Budget_type__c = 'Local';
		userAE2.rate_plan_status__c = 'Draft';
		userAE2.Budget_product_Lines__c = 'Linear/News/Sports';
		insert userAE2;

		String userIdsStr = userAE3.Id + ',' + userAE2.Id;
		String userIdsStr2 = userAE1.Id;
		Map<String, Object> mObject = new Map<String, Object> ();
		mObject.put('userID', userIdsStr);
		mObject.put('SelectedUserType', 'Manager');
		mObject.put('Year', '2020');
		mObject.put('FromMonth', '9');
		mObject.put('ToMonth', '12');
		mObject.put('query', '');
		mObject.put('isRetry', true);
		mObject.put('NewPassword', 'Welcome**90!');

		Map<String, Object> mObjectUser = new Map<String, Object> ();
		mObjectUser.put('userID', userIdsStr2);
		mObjectUser.put('SelectedUserType', 'User');
		mObjectUser.put('Year', '2020');
		mObjectUser.put('FromMonth', '9');
		mObjectUser.put('ToMonth', '12');
		mObjectUser.put('query', '');
		mObjectUser.put('isRetry', true);
		mObjectUser.put('NewPassword', 'Welcome**90!');
        
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock> ();
        WebServiceTestMockBudgetAggregate methodname1 = new WebServiceTestMockBudgetAggregate();
        endpoint2TestResp.put(Label.BoomiUserSBAggrURL,methodname1);
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		AdminUtility.call('salesbudgetaggregate', mObject);
		AdminUtility.call('removeusersalesbudget', mObject);
		AdminUtility.call('revenueaggregate', mObject);
		AdminUtility.call('budgetfinalapprovalmasssubmission', mObject);
		AdminUtility.call('budgetaggregate', mObject);
		AdminUtility.call('undoforecastautomation', mObject);
		AdminUtility.call('setuserpassword', mObject);
        AdminUtility.call('usersalesbudgetaggregate', mObject);
        //AdminUtility.call('TotalLocalSponsorship', mObject);
		//AdminUtility.call('salesbudgetreport', mObject);

		Test.stopTest();
	}

	public static testmethod void testSubmitForecast() {

		User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
		Account acc = TestDataHelper.createAdvertiser('Advertiser Account123', '123 Wright Plaza', 'Omaha', 'NE', '681030', 'USA');
		insert acc;
		Test.startTest();
		Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Master - Account Executive'];
		User userAE1 = new User();
		userAE1.ProfileId = objProfile.Id;
		userAE1.FirstName = 'User';
		userAE1.LastName = 'Test';
		userAE1.Alias = 'Test12';
		userAE1.EmailEncodingKey = 'UTF-8';
		userAE1.HR_Manager__c = thisUser.Id;
		userAE1.Username = 'testae1234567@mands.com';
		userAE1.Budget_type__c = 'Local';
		userAE1.rate_plan_status__c = 'Draft';
		userAE1.Budget_product_Lines__c = 'Linear/News/Sports';
		userAE1.LanguageLocaleKey = 'en_US';
		userAE1.LocaleSidKey = 'en_US';
		userAE1.TimeZoneSidKey = 'America/Los_Angeles';
		userAE1.Email = 'test@charter.com';

		insert userAE1;


		//create Sales Budget
		Sales_Budget__c sb = new Sales_Budget__c();
		sb = TestUtil.getSalesBudgetRec(userAE1, acc);
		sb.Type__c = 'Data';
		sb.Product_Line__c = 'Production';
		sb.Amount__c = 9000;
		sb.old_budget_user__c = userAE1.Id;
		sb.Budget_user__c = userAE1.Id;
		sb.External_Id__c = '008' + userAE1.id + System.today();
		insert sb;


		Sales_Budget__c sb1 = new Sales_Budget__c();
		sb1 = TestUtil.getSalesBudgetRec(userAE1, acc);
		sb1.Type__c = 'Data';
		sb1.Product_Line__c = 'Digital';
		sb1.Amount__c = 10000;
		sb1.old_budget_user__c = userAE1.Id;
		sb1.Budget_user__c = userAE1.Id;
		sb1.External_Id__c = '007' + userAE1.id + System.today();
		sb1.Status__c = 'Forecast Intermediate Approval';
		insert sb1;

		Sales_Budget_Approval__c ob = new Sales_Budget_Approval__c();
		ob = TestUtil.getSalesBudgetApprovalRec(userAE1, sb1);
		ob.Status__c = 'Forecast Pending';
		insert ob;
		system.debug('Sales Console:' + ob.Id + ',' + sb1.Id + ',Sales :' + ob);

		User userAE2 = TestUtil.prepareUser();
		userAE2.HR_Manager__c = thisUser.Id;
		userAE2.Username = 'testae12345@mands.com';
		userAE2.Budget_type__c = 'Local';
		userAE2.rate_plan_status__c = 'Draft';
		userAE2.Budget_product_Lines__c = 'Linear/News/Sports';
		insert userAE2;


		String userIdsStr2 = userAE1.Id;
		Map<String, Object> mObject = new Map<String, Object> ();
		mObject.put('userID', userIdsStr2);
		mObject.put('SelectedUserType', 'Manager');


		Map<String, Object> mObjectUser = new Map<String, Object> ();
		mObjectUser.put('userID', userIdsStr2);
		mObjectUser.put('SelectedUserType', 'User');


		AdminUtility.submitforecast(userAE1.Id, mObjectUser);
		AdminUtility.submitforecast(userAE1.Id, mObject);
		AdminUtility.rejectForecast(userAE1.Id);
		AdminUtility.rejectForecastManager(userAE1.Id);
	}
    
    public static testmethod void testLocalSponsorship(){
        String checkdate = '2022-05-20'; 
        User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Master - Account Executive'];
        User userAE1 = new User();
		userAE1.ProfileId = objProfile.Id;
		userAE1.FirstName = 'User';
		userAE1.LastName = 'Test';
		userAE1.Alias = 'Test12';
		userAE1.EmailEncodingKey = 'UTF-8';
		userAE1.HR_Manager__c = thisUser.Id;
		userAE1.Username = 'testae1234567@mands.com';
		userAE1.Budget_type__c = 'Local';
		userAE1.rate_plan_status__c = 'Draft';
		userAE1.Budget_product_Lines__c = 'Linear/News/Sports';
		userAE1.LanguageLocaleKey = 'en_US';
		userAE1.LocaleSidKey = 'en_US';
		userAE1.TimeZoneSidKey = 'America/Los_Angeles';
		userAE1.Email = 'test@charter.com';

		insert userAE1;

        
        Map<String, Object> mObjectUser = new Map<String, Object> ();
		mObjectUser.put('userID', userAE1);
		mObjectUser.put('SelectedUserType', 'User');
		mObjectUser.put('Year', '2020');
		mObjectUser.put('FromMonth', '9');
		mObjectUser.put('ToMonth', '12');
		mObjectUser.put('query', '');
		mObjectUser.put('isRetry', true);
		mObjectUser.put('NewPassword', 'Welcome**90!');
        mObjectUser.put('selectedDataLoadDate',checkdate);
        
        Test.startTest();
        AdminUtility.call('TotalLocalSponsorship', mObjectUser);
        AdminUtility.call('TotalNationalSponsorship', mObjectUser);
        AdminUtility.call('SoldNationalSponsorship', mObjectUser);
        AdminUtility.call('SoldLocalSponsorship', mObjectUser);
        Test.stopTest();
    }

	public static testmethod void testRemoveUserSalesBudget() {
		User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
		Account acc = TestDataHelper.createAdvertiser('Advertiser Account123', '123 Wright Plaza', 'Omaha', 'NE', '681030', 'USA');
		insert acc;
		AdminUtility admUtil = new AdminUtility();
		Test.startTest();

		User userAE1 = TestUtil.prepareUser();
		userAE1.HR_Manager__c = thisUser.Id;
		userAE1.Username = 'testae1234@mands.com';
		userAE1.Budget_type__c = 'Local';
		userAE1.rate_plan_status__c = 'Draft';
		userAE1.Budget_product_Lines__c = 'Linear/News/Sports';
		insert userAE1;

		//create Sales Budget
		Sales_Budget__c sb = new Sales_Budget__c();
		sb = TestUtil.getSalesBudgetRec(userAE1, acc);
		sb.Type__c = 'Data';
		sb.Product_Line__c = 'Production';
		sb.Amount__c = 9000;
		sb.old_budget_user__c = userAE1.Id;
		sb.Budget_user__c = userAE1.Id;
		sb.External_Id__c = '008' + userAE1.id + System.today();
		insert sb;


		Sales_Budget__c sb1 = new Sales_Budget__c();
		sb1 = TestUtil.getSalesBudgetRec(userAE1, acc);
		sb1.Type__c = 'Data';
		sb1.Product_Line__c = 'Digital';
		sb1.Amount__c = 10000;
		sb1.old_budget_user__c = userAE1.Id;
		sb1.Budget_user__c = userAE1.Id;
		sb1.External_Id__c = '007' + userAE1.id + System.today();
		insert sb1;

		User userAE2 = TestUtil.prepareUser();
		userAE2.HR_Manager__c = thisUser.Id;
		userAE2.Username = 'testae12345@mands.com';
		userAE2.Budget_type__c = 'Local';
		userAE2.rate_plan_status__c = 'Draft';
		userAE2.Budget_product_Lines__c = 'Linear/News/Sports';
		insert userAE2;

		admUtil.year = '2020';
		admUtil.userSelected = sb1;

		admUtil.removeUserSalesBudget();
		Test.stopTest();
	}

	public static testmethod void testVerifyUserPassword() {
		String urlInstance = String.valueof(System.URL.getSalesforceBaseURL()).replace('Url:[delegate=', '').replace(']', '');
		String[] instance = urlInstance.split('\\.');
		Test.startTest();
      
		Test.setMock(HttpCalloutMock.class, new WebServiceTestMock());
		AdminUtility.verifyUserPassword('Welcome**90!', instance[1]);
		Test.stopTest();
	}

	public static testmethod void TestSetNewPassword() {
		//String urlInstance = String.valueof(System.URL.getSalesforceBaseURL()).replace('Url:[delegate=', '').replace(']', '');
		//String[] instance = urlInstance.split('\\.');

		User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
		User userAE22 = TestUtil.prepareUser();
		userAE22.HR_Manager__c = thisUser.Id;
		userAE22.Username = 'testae12345@mands.com';
		userAE22.Budget_type__c = 'Local';
		userAE22.rate_plan_status__c = 'Draft';
		userAE22.Budget_product_Lines__c = 'Linear/News/Sports';
		insert userAE22;
		String userstrid = userAE22.Id;
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new WebServiceTestMock());
		//SingleRequestMock fakeResponse = new SingleRequestMock(204,'Complete','[{"Name": "sForceTest1"}]',null);
		AdminUtility.SetNewPassword(userstrid, 'Welcome**90!!');
		Test.stopTest();

	}

	public static testmethod void TestSelectedScript() {
		User userAE = TestUtil.prepareUser();
		userAE.Username = 'testae@mands.com';
		insert userAE;
		AdminUtility.getScripts();
	}

	private static User createUserWithSalesBudget(String userName) {
		User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
		Account acc = TestDataHelper.createAdvertiser('Advertiser Account123', '123 Wright Plaza', 'Omaha', 'NE', '681030', 'USA');
		insert acc;
		AccountConnection__c accCon = TestDataHelper.createAccountConnection(acc.Id);
		accCon.Tim_ID__c = '5413';
		insert accCon;

		User userAE = TestUtil.prepareUser();
		userAE.HR_Manager__c = thisUser.Id;
		userAE.Username = userName;
		userAE.Budget_type__c = 'Local';
		userAE.rate_plan_status__c = 'Draft';
		userAE.Budget_product_Lines__c = 'Linear/News/Sports';
		insert userAE;

		//create Sales Budget
		Sales_Budget__c sb = new Sales_Budget__c();
		sb = TestUtil.getSalesBudgetRec(userAE, acc);
		sb.Type__c = 'Data';
		sb.Product_Line__c = 'Production';
		sb.Amount__c = 9000;
		sb.old_budget_user__c = userAE.Id;
		sb.Budget_user__c = userAE.Id;
		sb.External_Id__c = '008' + userAE.id + System.today();
		insert sb;

		return userAE;
	}

	public static testmethod void testSBAggregate()
	{
		Test.startTest();
		AdminUtility obj = new AdminUtility();
		User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
		Account acc = TestDataHelper.createAdvertiser('Advertiser Account123', '123 Wright Plaza', 'Omaha', 'NE', '681030', 'USA');
		insert acc;
		AccountConnection__c accCon = TestDataHelper.createAccountConnection(acc.Id);
		accCon.Tim_ID__c = '5413';
		insert accCon;
		System.assert(acc != null);

		System.runAs(thisUser) {
			//Create User
			User userAE = TestUtil.prepareUser();
			userAE.HR_Manager__c = thisUser.Id;
			userAE.Username = 'testae@mands.com';
			userAE.Budget_type__c = 'Local';
			userAE.rate_plan_status__c = 'Draft';
			userAE.Budget_product_Lines__c = 'Linear/News/Sports';
			insert userAE;

			//create Sales Budget
			Sales_Budget__c sb = new Sales_Budget__c();
			sb = TestUtil.getSalesBudgetRec(userAE, acc);
			sb.Type__c = 'Data';
			sb.Product_Line__c = 'Production';
			sb.Amount__c = 9000;
			sb.old_budget_user__c = userAE.Id;
			sb.Budget_user__c = userAE.Id;
			sb.External_Id__c = '008' + userAE.id + System.today();
			insert sb;

			Sales_Budget__c sb1 = new Sales_Budget__c();
			sb1 = TestUtil.getSalesBudgetRec(userAE, acc);
			sb1.Type__c = 'Data';
			sb1.Product_Line__c = 'Digital';
			sb1.Amount__c = 10000;
			sb1.old_budget_user__c = userAE.Id;
			sb1.Budget_user__c = userAE.Id;
			sb1.External_Id__c = '007' + userAE.id + System.today();
			insert sb1;

			obj.executeSalesBudgetAgg('', new Set<Id> { userAE.Id }, false);
		}
		Test.stopTest();
	}

	public static testmethod void testDeleteOpportunityFromUserOwner() {

		Account acc = TestDataHelper.createAdvertiser('Advertiser Account123', '123 Wright Plaza', 'Omaha', 'NE', '681030', 'USA');
		insert acc;

		User userAE = TestUtil.prepareUser();
		userAE.Username = 'testae@mands.com';
		insert userAE;

		//create Opportunity
		Opportunity opp = TestDataHelper.createopportunity('Test Opportunity', System.today(), 'Planning', 'Pipeline', acc.ID);
		opp.ownerid = userAE.Id;
		insert opp;

		//create proposal
		Proposal__c p = TestDataHelper.createProposal('Test Opportunity psosal', opp.id, '00000', true);
		p.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
		p.Active__c = true;
		p.TIM_System__c = 'St. Louis Local';
		p.Start_Date__c = System.today();
		p.End_Date__c = System.today().addMonths(1);
		p.Current_Advertiser_Tim_Id__c = '12345';
		insert p;

		Test.startTest();
		AdminUtility.deleteOpportunityFromUserOwner(userAE.Id);
		Test.stopTest();
	}

	public static testmethod void resendSupportRequest() {
		User u = TestDataHelper.getBoomiIntegrationUser();
		System.debug('@@u Name ' + u.Name);

		Account acc = TestDataHelper.createAcc('Test Account', null, null, null, null, null);
		insert acc;
		System.assert(acc != null);
		System.debug('@@acc ' + acc);

		Opportunity opp;

		System.runAs(u) {
			opp = TestDataHelper.createopportunity('Test Opportunity', System.today(), null, null, acc.ID);
			insert opp;
			System.assert(opp != null);
			System.debug('@@opp ' + opp);
		}

		Support_Request__c request = TestDataHelper.createSupportrequest('Test Support Request', opp.Id, 2, null, null, System.today());
		request.Agency__c = acc.Id;
		request.Advertiser__c = acc.Id;
		request.Account_Executive__c = u.Id;
		insert request;
		System.assert(request != null);
		System.debug('@@request ' + request);

		System.runAs(u) {
			request.IMN_Sync_Status__c = 'Error';
			request.Integrated_with_IMN__c = false;
			update request;
		}

		Kernel_Project__c EndPoints = new Kernel_Project__c();
		EndPoints.Name = 'SupportRequest';
		EndPoints.End_Point__c = 'http://www.gmail.com';
		EndPoints.User_name__c = '4rQTfA3Bkn5I+codw4QJDKXBKV1qwETZ7rqcDK8jwe0=';
		EndPoints.Password__c = 'NtJzMtMzAdO3DiNheP1cdQ1cmEco8y/OXaf6HsCGYU4=';
		Insert EndPoints;

		Test.startTest();
		AdminUtility.call('supportrequestsync', null);
		Test.stopTest();

	}

	public static testmethod void resendProductionService() {
		User u = TestDataHelper.getBoomiIntegrationUser();
		System.debug('@@u Name ' + u.Name);

		Account acc = TestDataHelper.createAcc('Test Account', null, null, null, null, null);
		insert acc;
		System.assert(acc != null);
		System.debug('@@acc ' + acc);

		Opportunity opp;

		System.runAs(u) {
			opp = TestDataHelper.createopportunity('Test Opportunity', System.today(), null, null, acc.ID);
			insert opp;
			System.assert(opp != null);
			System.debug('@@opp ' + opp);
		}

		Support_Request__c sr = TestDataHelper.createSupportrequest('Test Support Request', opp.Id, 2, null, null, System.today());
		insert sr;
		System.assert(sr != null);
		System.debug('@@request ' + sr);

		Kernel_Project__c EndPoints = new Kernel_Project__c();
		EndPoints.Name = 'SupportRequest';
		EndPoints.End_Point__c = 'http://www.gmail.com';
		EndPoints.User_name__c = '4rQTfA3Bkn5I+codw4QJDKXBKV1qwETZ7rqcDK8jwe0=';
		EndPoints.Password__c = 'NtJzMtMzAdO3DiNheP1cdQ1cmEco8y/OXaf6HsCGYU4=';
		Insert EndPoints;

		Kernel_Project__c EndPoints1 = new Kernel_Project__c();
		EndPoints1.Name = 'ProductionService';
		EndPoints1.End_Point__c = 'http://www.gmail.com';
		EndPoints1.User_name__c = '4rQTfA3Bkn5I+codw4QJDKXBKV1qwETZ7rqcDK8jwe0=';
		EndPoints1.Password__c = 'NtJzMtMzAdO3DiNheP1cdQ1cmEco8y/OXaf6HsCGYU4=';
		Insert EndPoints1;

		Production_Service__c ps = TestDataHelper.createProdservice('Test Production', sr.Id, System.today());
		ps.Billed__c = false;
		ps.Existing_Spot_Location__c = 'test';
		ps.Finished_Spot_ID__c = 'test1';
		ps.Finished_Spot_Location__c = 'test2';
		ps.Finished_Spot_Title__c = 'test4';
		insert ps;

		System.runAs(u) {
			ps.IMN_Sync_Status__c = 'Error';
			ps.Integrated_with_IMN__c = false;
			update ps;
		}

		Test.startTest();
		AdminUtility.call('productionservicesync', null);
		Test.stopTest();

	}

	public static testmethod void noRecsToResendProdServiceAndSupportReqs() {
		User u = TestDataHelper.getBoomiIntegrationUser();
		System.debug('@@u Name ' + u.Name);

		Account acc = TestDataHelper.createAcc('Test Account', null, null, null, null, null);
		insert acc;
		System.assert(acc != null);

		Opportunity opp;

		System.runAs(u) {
			opp = TestDataHelper.createopportunity('Test Opportunity', System.today(), null, null, acc.ID);
			insert opp;
			System.assert(opp != null);
		}

		Support_Request__c sr = TestDataHelper.createSupportrequest('Test Support Request', opp.Id, 2, null, null, System.today());
		insert sr;
		System.assert(sr != null);

		Production_Service__c ps = TestDataHelper.createProdservice('Test Production', sr.Id, System.today());
		ps.Billed__c = false;
		ps.Existing_Spot_Location__c = 'test';
		ps.Finished_Spot_ID__c = 'test1';
		ps.Finished_Spot_Location__c = 'test2';
		ps.Finished_Spot_Title__c = 'test4';
		insert ps;

		Test.startTest();
		AdminUtility.call('supportrequestsync', null);
		AdminUtility.call('productionservicesync', null);
		Test.stopTest();
	}
}