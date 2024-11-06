@isTest
private class BudgetingToolAdOppBudgetControllerTest {

    @isTest
    static void testConstructor() {
        Profile directorOfSalesProfile = [SELECT Id FROM Profile WHERE Name = 'Master - Local Sales Manager'
            LIMIT 1
        ];
        User primaryUser = new User(
            FirstName = 'Primary',
            LastName = 'User',
            ProfileId = directorOfSalesProfile.Id,
            Username = 'primaryuser@charter.com',
            Email = 'primaryuser@charter.com',
            Alias = 'puser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Budget_Product_Lines__c = 'Linear/News/Sports;Digital;Production',
            Budget_Type__c = 'Local',
            Forecasting_Tool_Account_Limit__c = 200
        );

        insert primaryUser;
        System.debug('primaryUser ::: ' + primaryUser);
        System.runAs(primaryUser) {
            Test.startTest();
            BudgetingToolAdjustOppBudgetController controllerInstance = new BudgetingToolAdjustOppBudgetController();
            controllerInstance.loggedInUser = primaryUser;
            controllerInstance.loggedUserId = UserInfo.getUserId(); //primaryUser.Id;
            controllerInstance.salesProbSelected = '10,50,75,90,100';
            controllerInstance.lastYear = String.valueOf(Integer.valueOf(Label.BudgetCurrentYear) - 1);
            controllerInstance.currentYear = String.valueOf(Date.today().year());
            controllerInstance.nextYear = String.valueOf(Date.today().year() + 1);
            controllerInstance.selectedYear = '2023'; //controllerInstance.currentYear;
            controllerInstance.totalsLabel = 'TOTALS';
            controllerInstance.pendingLabel = 'Pending';
            controllerInstance.projectedLabel = 'Projected';
            controllerInstance.loggedInBudgetView = 'Manager'; // Adjust as needed
            controllerInstance.Q3FCSTLabel = 'qtL';

            BudgetingToolAdjustOppBudgetController.userParam = UserInfo.getUserId(); //primaryUser.Id;
            BudgetingToolAdjustOppBudgetController.impParam = UserInfo.getUserId(); //primaryUser.Id;
            Test.stopTest();
        }
    }
    @isTest
    static void testConstructorSecond() {

        BudgetingToolAdjustOppBudgetController controllerInstance = new BudgetingToolAdjustOppBudgetController();
        controllerInstance.loggedInBudgetView = 'Leadership';
    }

    @isTest
    static void testShowAEGrid() {
        Test.startTest();
        BudgetingToolAdjustOppBudgetController controller = new BudgetingToolAdjustOppBudgetController();
        PageReference pageRef = controller.showAEGrid();
        Test.stopTest();
    }

    @isTest
    static void testShowUserListStatus() {
        Test.startTest();
        BudgetingToolAdjustOppBudgetController controller = new BudgetingToolAdjustOppBudgetController();
        // controller.showUserListStatus();
        Test.stopTest();
    }

    @isTest
    static void testBuildUserContext() {
		List<User> uList = new List<User>();
        Profile lsmProfileId = [SELECT Id FROM Profile WHERE Name = 'Master - Local Sales Manager'
            LIMIT 1
        ];
        Profile aeProfileId = [SELECT Id FROM Profile WHERE Name = 'Master - Account Executive'
            LIMIT 1
        ];
        User lsmUser = new User(
            FirstName = 'Primary',
            LastName = 'User',
            ProfileId = lsmProfileId.Id,
            Username = 'pmaryuer@charter.com',
            Email = 'priaryur@charter.com',
            Alias = 'puser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Budget_Product_Lines__c = 'Linear/News/Sports;Digital;Production',
            Budget_Type__c = 'Local',
            Forecasting_Tool_Account_Limit__c = 200
        );
        Insert lsmUser;
        
        User aeUser1 = new User(
            FirstName = 'Primary',
            LastName = 'User',
            ProfileId = aeProfileId.Id,
            Username = 'pryuse@charter.com',
            Email = 'primer@charter.com',
            Alias = 'puser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Budget_Product_Lines__c = 'Linear/News/Sports;Digital;Production',
            Budget_Type__c = 'Local',
            HR_Manager__c = lsmUser.Id,
            Forecasting_Tool_Account_Limit__c = 200
        );
        uList.add(aeUser1);

        User aeUser2 = new User(
            FirstName = 'Primary',
            LastName = 'User',
            ProfileId = aeProfileId.Id,
            Username = 'pryse@charter.com',
            Email = 'primer@charter.com',
            Alias = 'puser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Budget_Product_Lines__c = 'Linear/News/Sports;Digital;Production',
            Budget_Type__c = 'Local',
            HR_Manager__c = lsmUser.Id,
            Forecasting_Tool_Account_Limit__c = 200
        );
        uList.add(aeUser2);
        Insert uList;
        
        System.runAs(lsmUser) {
            Test.startTest();
            BudgetingToolAdjustOppBudgetController controller = new BudgetingToolAdjustOppBudgetController();
            controller.buildUserContext(UserInfo.getUserId(), UserInfo.getUserId());
            controller.loggedInBudgetView = 'Leadership';
            Test.stopTest();
        }
    }
    @isTest
    static void testQueryAETreeData() {
        Test.startTest();
        Profile lsmId = [SELECT Id FROM Profile WHERE Name = 'Master - Local Sales Manager'
            LIMIT 1
        ];
        User lsmUser = new User(
            FirstName = 'Primary',
            LastName = 'User',
            ProfileId = lsmId.Id,
            Username = 'pryse@charter.com',
            Email = 'primer@charter.com',
            Alias = 'puser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Budget_Product_Lines__c = 'Linear/News/Sports;Digital;Production',
            Budget_Type__c = 'Local',
            Forecasting_Tool_Account_Limit__c = 200
        );

        insert lsmUser;
          Account accObj1 = new Account(
            Name = 'New Business/Churn',
            BillingStreet = '123 Main St',
            BillingCity = 'Cityville',
            BillingState = 'CA',
            BillingPostalCode = '12345',
            BillingCountry = 'USA',
            ShippingStreet = '456 Oak St',
            ShippingCity = 'Townsville',
            ShippingState = 'NY',
            ShippingPostalCode = '54321',
            ShippingCountry = 'USA',
            Political_Account__c = false 
            // Add other required fields
        );
        insert accObj1;
        System.debug('lsmUserId ::: ' + lsmUser.Id);
        //  System.runAS(lsmUser){
        BudgetingToolAdjustOppBudgetController controller = new BudgetingToolAdjustOppBudgetController();
        List < BudgetingToolModel.Items_Led > tgmiLedList = new List < BudgetingToolModel.Items_Led > ();
        controller.selectedYear = '2023';
        controller.loggedUserId = lsmUser.Id; //UserInfo.getUserId();
        controller.loggedInBudgetView = 'Leadership';
        List < Revenue_Aggregate__c > pyLeadershipRevenues = new List < Revenue_Aggregate__c > ();

        Revenue_Aggregate__c revenue = new Revenue_Aggregate__c();
        revenue.Total_Amount__c = 8116.67; // Replace with your actual value
        revenue.Product_Line__c = 'Digital';
        revenue.Broadcast_Month__c = 4; // Replace with your actual value
        revenue.Year__c = 2022;
        revenue.Account_Executive__c = UserInfo.getUserId(); //'AE_',
        revenue.Account_Executive_Name__c = 'AE Name ';
        revenue.Revenue_User__c = 'Rev_User_';
        revenue.Revenue_User_Name__c = 'Rev User Name ';
        revenue.LSM__c = lsmUser.Id; //UserInfo.getUserId();

        pyLeadershipRevenues.add(revenue);
        insert pyLeadershipRevenues;


        List < Revenue_Aggregate__c > cyLeadershipRevenues = new List < Revenue_Aggregate__c > ();
        Revenue_Aggregate__c revenueAg = new Revenue_Aggregate__c();
        revenueAg.Total_Amount__c = 8116.67; // Replace with your actual value
        revenueAg.Product_Line__c = 'Digital';
        revenueAg.Broadcast_Month__c = 4; // Replace with your actual value
        revenueAg.Year__c = 2023;
        revenueAg.Account_Executive__c = UserInfo.getUserId(); //'AE_',
        revenueAg.Account_Executive_Name__c = 'AE Name ';
        revenueAg.Revenue_User__c = 'Rev_User_';
        revenueAg.Revenue_User_Name__c = 'Rev User Name ';
        revenueAg.LSM__c = lsmUser.Id; //UserInfo.getUserId();

        cyLeadershipRevenues.add(revenueAg);
        insert cyLeadershipRevenues;

        PZMV_Aggregate__c linearRecord = new PZMV_Aggregate__c(
            LSM__c = lsmUser.Id, //UserInfo.getUserId(),
            RecordType__c = 'Linear',
            ProposalZoneStatus__c = 'Pending',
            ProposalActive__c = true,
            Year__c = 2023,
            ProposalOppIsClosed__c = false,
            ProposalOppIsWon__c = true,
            Amount__c = 1000,
            Month__c=1,
            SalesProbability__c = '10',
            AccountId__c=accObj1.Id,
            OwnerId__c=lsmUser.id
        );
        insert linearRecord;

        // Opportunity Budget record
        PZMV_Aggregate__c opportunityBudgetRecord = new PZMV_Aggregate__c(
            LSM__c = lsmUser.Id, //UserInfo.getUserId(),
            RecordType__c = 'Opportunity Budget',
            ProposalActive__c = true,
            Year__c = 2023,
            ProposalOppIsClosed__c = false,
            ProposalOppIsWon__c = true,
            Amount__c = 200,
             Month__c=1,
            SalesProbability__c = '50'
        );
        insert opportunityBudgetRecord;

        // Adjust Opportunity Budget record
        PZMV_Aggregate__c adjustOpportunityBudgetRecord = new PZMV_Aggregate__c(
            LSM__c = lsmUser.Id, //UserInfo.getUserId(),
            RecordType__c = 'Adjust Opportunity Budget',
            Year__c = 2023,
            Amount__c = 300,
             Month__c=1,
            SalesProbability__c = '75'
        );
        insert adjustOpportunityBudgetRecord;


        controller.queryAETreeData();
        Test.stopTest();
        //}
    }


    @isTest
    static void testSaveAdjustedForecast() {

        Account accObj = new Account(
            Name = 'New Business/Churn',
            BillingStreet = '123 Main St',
            BillingCity = 'Cityville',
            BillingState = 'CA',
            BillingPostalCode = '12345',
            BillingCountry = 'USA',
            ShippingStreet = '456 Oak St',
            ShippingCity = 'Townsville',
            ShippingState = 'NY',
            ShippingPostalCode = '54321',
            ShippingCountry = 'USA',
            Political_Account__c = false 
            // Add other required fields
        );
        insert accObj;

        System.debug('accObj Id ::' + accObj.Id);

        String testForecastData = '[{"accountId": "' + accObj.Id + '", "monthKey": "2023-01", "monthAmount": 1000, "scheduleType": "Linear/News/Sports;Digital;Production"}]';
        String selectedUserId = UserInfo.getUserId();




        // List<User> testUsers = new List<User>();
        Profile foruId1 = [SELECT Id FROM Profile WHERE Name = 'Integration User'
            LIMIT 1
        ];
        User user1 = new User(
            ProfileId = foruId1.Id,
            FirstName = 'Primary',
            LastName = 'User',
            Username = 'pryse@charter.com',
            Email = 'primer@charter.com',
            Alias = 'puser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Budget_Product_Lines__c = 'Linear/News/Sports;Digital;Production',
            Budget_Type__c = 'Local',
            Forecasting_Tool_Account_Limit__c = 200
        );
        // testUsers.add(user1);


        insert user1;
        System.runAs(user1) {

            // Create test Account_SAM_Mappings__r records
            // List<Account_SAM_Mapping__c> testMappings = new List<Account_SAM_Mapping__c>();
            // 
            // 


            List < AccountTeamMember > testAccountTeamMembers = new List < AccountTeamMember > ();

            AccountTeamMember teamMember1 = new AccountTeamMember(
                AccountId = accObj.Id,
                UserId = user1.Id,
                TeamMemberRole = 'Sales Representative'

            );
            testAccountTeamMembers.add(teamMember1);

            AccountTeamMember teamMember2 = new AccountTeamMember(
                AccountId = accObj.Id,
                UserId = UserInfo.getUserId(),
                TeamMemberRole = 'Support Representative'

            );
            testAccountTeamMembers.add(teamMember2);

            insert testAccountTeamMembers;


            Account_SAM_Mapping__c mapping1 = new Account_SAM_Mapping__c(
                User__c = testAccountTeamMembers[0].UserId, //TeamMember1.UserId,
                SAM_Designation__c = 'Secondary',
                Account__c = accObj.Id
            );
            insert mapping1;

            Opportunity dummyOpp = new Opportunity();
            dummyOpp.Name = 'Opportunity For Forecast Adjustment' + '::' + selectedUserId;
            dummyOpp.StageName = 'Identification';
            dummyOpp.Sales_Probability__c = '10';
            dummyOpp.AccountId = accObj.Id;
            dummyOpp.CloseDate = System.Date.today();
            dummyOpp.OpportunityExternalId__c = accObj.Id + ':' + selectedUserId;
            dummyOpp.OwnerId = user1.Id; //'00541000002Xx6zAAC';
            //dummyOpp.RecordTypeId = rt.Id;//'0124C000000MYx3QAG';
            dummyOpp.Account_For_Forecasting_Tool__c = accObj.Id;
            dummyOpp.Owner_For_Forecasting_Tool__c = selectedUserId;
            //oppList.add(dummyOpp);
            insert dummyOpp;

            //testMappings.add(mapping1);









            // Call the remote action
            Test.startTest();
          //  BudgetingToolAdjustOppBudgetController.saveAdjustedForecast(testForecastData, selectedUserId);
            Test.stopTest();

            //List<Opportunity> oppList = [SELECT Id FROM Opportunity];
            // List<Proposal__c> proposalList = [SELECT Id FROM Proposal__c];
            //  List<Proposal_Zone__c> pzList = [SELECT Id FROM Proposal_Zone__c];
            //  List<Proposal_Zone_Monthly_Value__c> pzmvList = [SELECT Id FROM Proposal_Zone_Monthly_Value__c];

        }
    }


    @isTest
    static void testFmtTotalFormula() {
        BudgetingToolAdjustOppBudgetController instace = new BudgetingToolAdjustOppBudgetController();
        String result = instace.fmtTotalFormula('Jan');
    }

    @isTest
    static void testFormatMonthRollupFormula() {
        BudgetingToolAdjustOppBudgetController instace = new BudgetingToolAdjustOppBudgetController();
       // String result = instace.formatMonthRollupFormula('Feb');
    }

    @isTest
    static void testFormatMonthRollupFormulaWithAccount() {
        BudgetingToolAdjustOppBudgetController instace = new BudgetingToolAdjustOppBudgetController();
     //   String result = instace.formatMonthRollupFormula('Mar', 'SampleAccount');
    }

    @isTest
    static void testFormatDef() {
        BudgetingToolAdjustOppBudgetController instace = new BudgetingToolAdjustOppBudgetController();
        String result = instace.formatDef('ldollar');
    }

    @isTest
    static void testAddLed() {
        List < Decimal > months = new List < Decimal > {
            100.00,
            200.00,
            300.00,
            400.00,
            500.00,
            600.00,
            700.00,
            800.00,
            900.00,
            1000.00,
            1100.00,
            1200.00
        };
        BudgetingToolAdjustOppBudgetController instace = new BudgetingToolAdjustOppBudgetController();
        BudgetingToolModel.Items_Led result = instace.AddLed('SampleLed', 'lplain', 0, months, 'SampleFormula', 'SampleId', 'SampleChurnIndicator');
    }

    @isTest
    static void testFormatDef2() {
        BudgetingToolAdjustOppBudgetController instace = new BudgetingToolAdjustOppBudgetController();
        String result = instace.formatDef('SampleAccount', 'ldollar');
    }

    @isTest
    static void testAddProduct() {
        List < Decimal > months = new List < Decimal > {
            100.00,
            200.00,
            300.00,
            400.00,
            500.00,
            600.00,
            700.00,
            800.00,
            900.00,
            1000.00,
            1100.00,
            1200.00
        };
        BudgetingToolAdjustOppBudgetController instace = new BudgetingToolAdjustOppBudgetController();
        BudgetingToolModel.Items_Led sampleLed = instace.AddLed('SampleLed', 'lplain', 0, months, 'SampleFormula', 'SampleId', 'SampleChurnIndicator');
        List < BudgetingToolModel.Items_Led > ledList = new List < BudgetingToolModel.Items_Led > {
            sampleLed
        };
        BudgetingToolModel.Items_Pro result = instace.AddProduct('SampleProduct', ledList);
    }

    @isTest
    static void testAddAccount() {
        List < Decimal > months = new List < Decimal > {
            100.00,
            200.00,
            300.00,
            400.00,
            500.00,
            600.00,
            700.00,
            800.00,
            900.00,
            1000.00,
            1100.00,
            1200.00
        };
        BudgetingToolAdjustOppBudgetController instace = new BudgetingToolAdjustOppBudgetController();
        BudgetingToolModel.Items_Led sampleLed = instace.AddLed('SampleLed', 'lplain', 0, months, 'SampleFormula', 'SampleId', 'SampleChurnIndicator');
        List < BudgetingToolModel.Items_Led > ledList = new List < BudgetingToolModel.Items_Led > {
            sampleLed
        };
        BudgetingToolModel.Items_Pro sampleProduct = instace.AddProduct('SampleProduct', ledList);
        List < BudgetingToolModel.Items_Pro > productList = new List < BudgetingToolModel.Items_Pro > {
            sampleProduct
        };
        BudgetingToolModel.Body result = instace.AddAccount('SampleAccount', productList);
    }

    @isTest
    static void testCheckMonth() {
        Integer result = BudgetingToolAdjustOppBudgetController.CheckMonth('Jan');
    }
    
     @isTest
    static void testQueryAEAccTeamData() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Master - Local Sales Manager'];
        User testUser = new User(
            Alias = 'standt',
            Email='standarduser@charter.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standarduser12232@charter.com',
            Forecasting_Tool_Account_Limit__c = 200,
            Budget_Product_Lines__c = 'Digital'
        );
        insert testUser;
        
        Account testAccount = new Account(
            Name='Test Account',
            Primary_Commodity__c='Associations',
            Political_Account__c = false
        );
        insert testAccount;
        
        AccountTeamMember testATM = new AccountTeamMember(
            TeamMemberRole='Other',
            UserId=testUser.Id,
            AccountId=testAccount.Id
        );
        AccountTeamMember testATM1 = new AccountTeamMember(
            TeamMemberRole='Other',
            UserId=UserInfo.getUserId(),
            AccountId=testAccount.Id
        );
        insert testATM;
        insert testATM1;
        Task testTask = new Task(
            Subject='Test Task',
            WhatId=testAccount.Id,
            ActivityDate=Date.today()
        );
        insert testTask;
       
        
        BudgetingToolAdjustOppBudgetController.GridHelper rh = new BudgetingToolAdjustOppBudgetController.GridHelper();
        BudgetingToolAdjustOppBudgetController obj = new BudgetingToolAdjustOppBudgetController();
        //obj.queryAEAccTeamData(rh);
       
        
    }

}