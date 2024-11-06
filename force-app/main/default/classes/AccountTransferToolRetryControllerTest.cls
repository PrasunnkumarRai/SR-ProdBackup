@isTest	
private class AccountTransferToolRetryControllerTest {


    @isTest static void proposalRetryTest() {
        User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
		
        List<Test_Data_Utility__mdt> ucList = new List<Test_Data_Utility__mdt>();
        
        Map<String,String> TestData = new Map<String, String>();
        
         ucList = [Select DeveloperName, label from Test_Data_Utility__mdt ];
        for(Test_Data_Utility__mdt abcd : ucList)
        {
            TestData.put(abcd.DeveloperName, abcd.label);
        }
       system.debug('TestData=-=====> '+ TestData.get('Region_c_1'));
        
        System.runAs (thisUser) {
        
	        User userAE = TestUtil.prepareUser();
	        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
	        userAE.ProfileId = objProfile.Id;
	        userAE.HR_Manager__c = thisUser.Id;
	        userAE.Username = 'testae@mands.com';
	        userAE.Budget_type__c = 'Local';
	        userAE.Budget_product_Lines__c = 'Linear/News/Sports;';
	        userAE.Firstname = 'Test';
	        userAE.Lastname = 'User1';
	        insert userAE;
	
	        User userAETo = TestUtil.prepareUser(); 
	        userAETo.ProfileId = objProfile.Id;
	        userAETo.HR_Manager__c = thisUser.Id;
	        userAETo.Username = 'testaeTo@mands.com';
	        userAETo.Budget_type__c = 'Local';
	        userAETo.Budget_product_Lines__c = 'Linear/News/Sports;';
	        userAETo.Firstname = 'Test';
	        userAETo.Lastname = 'User';
	        insert userAETo;
	
	        User userAETo2 = TestUtil.prepareUser();
	        userAETo2.ProfileId = objProfile.Id;
	        userAETo2.HR_Manager__c = userAETo.Id;
	        userAETo2.Username = 'testaeTo2@mands.com';
	        userAETo2.Budget_type__c = 'Local';
	        userAETo2.Budget_product_Lines__c = 'Linear/News/Sports;';
	        userAETo2.Firstname = 'Test2';
	        userAETo2.Lastname = 'User2';
	        insert userAETo2;
		
			
	        Account acc = TestUtil.getAccountRec();
	        acc.primary_commodity__c =   'Auto Aftermarket';
	        insert acc;
	
			Accountshare accShare = new Accountshare();
	        accShare.AccountId = acc.Id;
	        accShare.UserOrGroupId = userAE.Id;
	        accShare.AccountAccessLevel = 'Edit';
	        accShare.OpportunityAccessLevel = 'Edit';
	        insert accShare;
	                
	        Accountshare accShare1 = new Accountshare();
	        accShare1.AccountId = acc.Id;
	        accShare1.UserOrGroupId = userAETo.Id;
	        accShare1.AccountAccessLevel = 'Edit';
	        accShare1.OpportunityAccessLevel = 'Edit';
	        insert accShare1;
	        
	        Accountshare accShare2 = new Accountshare();
	        accShare2.AccountId = acc.Id;
	        accShare2.UserOrGroupId = userAETo2.Id;
	        accShare2.AccountAccessLevel = 'Edit';
	        accShare2.OpportunityAccessLevel = 'Edit';
	        insert accShare2;
	        
	        AccountTeammember accTM = new AccountTeammember();
	        accTM.UserID = userAE.Id;
	        accTM.AccountId = acc.Id;
	        accTM.Teammemberrole = 'Account Executive';
	        insert accTM;
			
			AccountTeammember accTM2 = new AccountTeammember();
	        accTM2.UserID = userAETo.Id;
	        accTM2.AccountId = acc.Id;
	        accTM2.Teammemberrole = 'Account Executive';
	        insert accTM2;
	        
	        AccountTeammember accTM1 = new AccountTeammember();
	        accTM1.UserID = userAETo2.Id;
	        accTM1.AccountId = acc.Id;
	        accTM1.Teammemberrole = 'Account Executive';
	        insert accTM1;
	        
	        //Create User Connection
	        insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',userAE.id,'TIM','1');
	
	        //create Opportunity
	        Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);
	        opp.OwnerId = userAE.Id;
	        insert opp;
	
	        //create Proposal
	        Proposal__c p = TestDataHelper.createProposal('Test Opportunity Proposal',opp.id, '00000', true);
	        p.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
	        p.Active__c = true;
	        p.TIM_System__c = 'St. Louis Local';
	        p.Start_Date__c = System.today();
	        p.End_Date__c = System.today().addMonths(1);
	        p.Current_Advertiser_Tim_Id__c = '12345';
	        insert p;
			
	        //Create SysCode
	        Syscode__c sys = TestDataHelper.createSysCode(false);
	        insert sys;
	        
	        //create Proposal Zone
	        Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Proposal Zone',p.Id);
	        propZone.Sys_Code__c = 'Linear/News/Sports';
			propZone.Status_Type__c = 'Pending';
	        insert propZone;
	        
			Test.startTest();
		        //create Proposal Zone Monthly Value
		        Proposal_Zone_Monthly_Value__c propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value',acc.Id,propZone.Id);
		        propZoneMonthly.Schedule_Type__c = 'Linear';
		        propZoneMonthly.Proposal_Key_Index__c = p.Id;
		        propZoneMonthly.Advertiser__c = acc.Id;
		        propZoneMonthly.Broadcast_Month_Date__c = System.today().addMonths(1);
		        insert propZoneMonthly;
		        
		        //create Proposal
		        Proposal__c pl = TestDataHelper.createProposal('Test Opportunity Proposal',opp.id, '00000', true);
		        pl.RecordTypeId = TestDataHelper.LinearRecTypeId;
		        pl.Active__c = true;
		        pl.Start_Date__c = System.today();
		        pl.End_Date__c = System.today().addMonths(1);
		        insert pl;
				
		
		        //create Proposal Zone
		        Proposal_Zone__c prop_Zone = TestDataHelper.createProposalZone('Test Proposal Zone',pl.Id);
		        prop_Zone.Sys_Code__c = 'Linear/News/Sports';
		        prop_Zone.Status_Type__c = 'Pending';
		        insert prop_Zone;
		
		        //create Proposal Zone Monthly Value
		        Proposal_Zone_Monthly_Value__c propZoneMonthlyVal = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value',acc.Id,prop_Zone.Id);
		        propZoneMonthlyVal.Schedule_Type__c = 'Linear';
		        propZoneMonthlyVal.Advertiser__c = acc.Id;
		        propZoneMonthlyVal.Proposal_Key_Index__c = pl.Id;
		        propZoneMonthlyVal.Broadcast_Month_Date__c = System.today().addMonths(1);
		        insert propZoneMonthlyVal;
		
		        Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
		        att.Division__c = TestData.get('Division_c_1');
		        att.Region__c = TestData.get('Region_c_1');
		        att.Status__c = 'Transfer Completed';
		        att.Transfer_Effective_Date__c = Date.newInstance(2019, 01, 15);
		        insert att;
		
		        Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
		        atm.Account__c = acc.Id;
		        atm.Account_Transfer_Simulation__c = att.Id;
		        atm.From_User__c = userAE.Id;
		        atm.To_User__c = userAETo.Id;
		        atm.External_ID__c = userAE.Id+';;;'+acc.Id+';;;'+'2019Jan'+';;;'+userAETo.Id;
		        insert atm;
		    	
		    	ApexPages.StandardController sc = new ApexPages.StandardController(att);
			    ApexPages.currentPage().getParameters().put('id',att.id);
			    ApexPages.currentPage().getParameters().put('retry','proposal');			        
			    AccountTransferToolRetryController attrc = new AccountTransferToolRetryController(sc);
			    
			    attrc.retry();    

 			Test.stopTest();
    	}
    
    }
    
    @isTest static void opportunityRetryTest() {
        User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
		
        List<Test_Data_Utility__mdt> ucList = new List<Test_Data_Utility__mdt>();
        
        Map<String,String> TestData = new Map<String, String>();
        
         ucList = [Select DeveloperName, label from Test_Data_Utility__mdt ];
        for(Test_Data_Utility__mdt abcd : ucList)
        {
            TestData.put(abcd.DeveloperName, abcd.label);
        }
       system.debug('TestData=-=====> '+ TestData.get('Region_c_1'));
        
        System.runAs (thisUser) {
        
	        User userAE = TestUtil.prepareUser();
	        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
	        userAE.ProfileId = objProfile.Id;
	        userAE.HR_Manager__c = thisUser.Id;
	        userAE.Username = 'testae@mands.com';
	        userAE.Budget_type__c = 'Local';
	        userAE.Budget_product_Lines__c = 'Linear/News/Sports;';
	        userAE.Firstname = 'Test';
	        userAE.Lastname = 'User1';
	        insert userAE;
	
	        User userAETo = TestUtil.prepareUser(); 
	        userAETo.ProfileId = objProfile.Id;
	        userAETo.HR_Manager__c = thisUser.Id;
	        userAETo.Username = 'testaeTo@mands.com';
	        userAETo.Budget_type__c = 'Local';
	        userAETo.Budget_product_Lines__c = 'Linear/News/Sports;';
	        userAETo.Firstname = 'Test';
	        userAETo.Lastname = 'User';
	        insert userAETo;
	
	        User userAETo2 = TestUtil.prepareUser();
	        userAETo2.ProfileId = objProfile.Id;
	        userAETo2.HR_Manager__c = userAETo.Id;
	        userAETo2.Username = 'testaeTo2@mands.com';
	        userAETo2.Budget_type__c = 'Local';
	        userAETo2.Budget_product_Lines__c = 'Linear/News/Sports;';
	        userAETo2.Firstname = 'Test2';
	        userAETo2.Lastname = 'User2';
	        insert userAETo2;
		
			
	        Account acc = TestUtil.getAccountRec();
	        acc.primary_commodity__c =   'Auto Aftermarket';
	        insert acc;
	
			Accountshare accShare = new Accountshare();
	        accShare.AccountId = acc.Id;
	        accShare.UserOrGroupId = userAE.Id;
	        accShare.AccountAccessLevel = 'Edit';
	        accShare.OpportunityAccessLevel = 'Edit';
	        insert accShare;
	                
	        Accountshare accShare1 = new Accountshare();
	        accShare1.AccountId = acc.Id;
	        accShare1.UserOrGroupId = userAETo.Id;
	        accShare1.AccountAccessLevel = 'Edit';
	        accShare1.OpportunityAccessLevel = 'Edit';
	        insert accShare1;
	        
	        Accountshare accShare2 = new Accountshare();
	        accShare2.AccountId = acc.Id;
	        accShare2.UserOrGroupId = userAETo2.Id;
	        accShare2.AccountAccessLevel = 'Edit';
	        accShare2.OpportunityAccessLevel = 'Edit';
	        insert accShare2;
	        
	        AccountTeammember accTM = new AccountTeammember();
	        accTM.UserID = userAE.Id;
	        accTM.AccountId = acc.Id;
	        accTM.Teammemberrole = 'Account Executive';
	        insert accTM;
			
			AccountTeammember accTM2 = new AccountTeammember();
	        accTM2.UserID = userAETo.Id;
	        accTM2.AccountId = acc.Id;
	        accTM2.Teammemberrole = 'Account Executive';
	        insert accTM2;
	        
	        AccountTeammember accTM1 = new AccountTeammember();
	        accTM1.UserID = userAETo2.Id;
	        accTM1.AccountId = acc.Id;
	        accTM1.Teammemberrole = 'Account Executive';
	        insert accTM1;
	        
	        //Create User Connection
	        insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',userAE.id,'TIM','1');
	
	        //create Opportunity
	        Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);
	        opp.OwnerId = userAE.Id;
	        insert opp;
	
	        //create Proposal
	        Proposal__c p = TestDataHelper.createProposal('Test Opportunity Proposal',opp.id, '00000', true);
	        p.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
	        p.Active__c = true;
	        p.TIM_System__c = 'St. Louis Local';
	        p.Start_Date__c = System.today();
	        p.End_Date__c = System.today().addMonths(1);
	        p.Current_Advertiser_Tim_Id__c = '12345';
	        insert p;
			
	        //Create SysCode
	        Syscode__c sys = TestDataHelper.createSysCode(false);
	        insert sys;
	        
	        //create Proposal Zone
	        Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Proposal Zone',p.Id);
	        propZone.Sys_Code__c = 'Linear/News/Sports';
			propZone.Status_Type__c = 'Pending';
	        insert propZone;
	        
			Test.startTest();
		        //create Proposal Zone Monthly Value
		        Proposal_Zone_Monthly_Value__c propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value',acc.Id,propZone.Id);
		        propZoneMonthly.Schedule_Type__c = 'Linear';
		        propZoneMonthly.Proposal_Key_Index__c = p.Id;
		        propZoneMonthly.Advertiser__c = acc.Id;
		        propZoneMonthly.Broadcast_Month_Date__c = System.today().addMonths(1);
		        insert propZoneMonthly;
		        
		        //create Proposal
		        Proposal__c pl = TestDataHelper.createProposal('Test Opportunity Proposal',opp.id, '00000', true);
		        pl.RecordTypeId = TestDataHelper.LinearRecTypeId;
		        pl.Active__c = true;
		        pl.Start_Date__c = System.today();
		        pl.End_Date__c = System.today().addMonths(1);
		        insert pl;
				
		
		        //create Proposal Zone
		        Proposal_Zone__c prop_Zone = TestDataHelper.createProposalZone('Test Proposal Zone',pl.Id);
		        prop_Zone.Sys_Code__c = 'Linear/News/Sports';
		        prop_Zone.Status_Type__c = 'Pending';
		        insert prop_Zone;
		
		        //create Proposal Zone Monthly Value
		        Proposal_Zone_Monthly_Value__c propZoneMonthlyVal = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value',acc.Id,prop_Zone.Id);
		        propZoneMonthlyVal.Schedule_Type__c = 'Linear';
		        propZoneMonthlyVal.Advertiser__c = acc.Id;
		        propZoneMonthlyVal.Proposal_Key_Index__c = pl.Id;
		        propZoneMonthlyVal.Broadcast_Month_Date__c = System.today().addMonths(1);
		        insert propZoneMonthlyVal;
		
		        Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
		        att.Division__c = TestData.get('Division_c_1');
		        att.Region__c = TestData.get('Region_c_1');
		        att.Status__c = 'Transfer Completed';
		        att.Transfer_Effective_Date__c = Date.newInstance(2019, 01, 15);
		        insert att;
		
		        Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
		        atm.Account__c = acc.Id;
		        atm.Account_Transfer_Simulation__c = att.Id;
		        atm.From_User__c = userAE.Id;
		        atm.To_User__c = userAETo.Id;
		        atm.External_ID__c = userAE.Id+';;;'+acc.Id+';;;'+'2019Jan'+';;;'+userAETo.Id;
		        insert atm;
		    	
		    	ApexPages.StandardController sc = new ApexPages.StandardController(att);
			    ApexPages.currentPage().getParameters().put('id',att.id);
			    ApexPages.currentPage().getParameters().put('retry','opportunity');			        
			    AccountTransferToolRetryController attrc = new AccountTransferToolRetryController(sc);
			    
			    attrc.retry();    

 			Test.stopTest();
    	}
    
    }
    
    @isTest static Void RevenueRetryTest(){
    	
        User thisUser=[Select ID,Name from User Where ID=:UserInfo.getUserId()];
        
        List<Test_Data_Utility__mdt> ucList = new List<Test_Data_Utility__mdt>();
        
        Map<String,String> TestData = new Map<String, String>();
        
         ucList = [Select DeveloperName, label from Test_Data_Utility__mdt ];
        for(Test_Data_Utility__mdt abcd : ucList)
        {
            TestData.put(abcd.DeveloperName, abcd.label);
        }
        
        System.runAs(thisUser){
            
        //create AE User
        User userAE = TestUtil.prepareUser();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@mands.com';
        userAE.Budget_type__c = 'Local';
        userAE.Budget_product_Lines__c = 'Linear/News/Sports;';
        userAE.rate_plan_status__c = 'Draft';
        insert userAE;

        User userAE2 = TestUtil.prepareUser();
        userAE2.ProfileId = objProfile.Id;
        userAE2.Username = 'testae2@mands.com';
        userAE2.Budget_type__c = 'Local';
        userAE2.Budget_product_Lines__c = 'Linear/News/Sports';
        userAE2.rate_plan_status__c = 'Draft';
        insert userAE2;

        
		//create account
		Account acc = TestUtil.getAccountRec();
        acc.primary_commodity__c =   'Auto Aftermarket';
        insert acc;

		//create account team member
        AccountTeammember accTM = new AccountTeammember();
        accTM.UserID = userAE.Id;
        accTM.AccountId = acc.Id;
        accTM.Teammemberrole = 'Other';
        insert accTM;
		
		//create account share
        Accountshare accShare = new Accountshare();
        accShare.AccountId = acc.Id;
        accShare.UserOrGroupId = userAE.Id;
        accShare.AccountAccessLevel = 'Edit';
        accShare.OpportunityAccessLevel = 'Edit';
        insert accShare;

        //Create Revenue
        Revenue__c  revenue = TestDataHelper.createRevenue('2222', '3333', System.today().addYears(-1), 1000, 1000, 0, 0, '1');
        revenue.ContractNumber__c = 1111;
        revenue.Account_Executive__c = userAE.Id;
        revenue.Product_Line__c = 'Linear';
        revenue.Advertiser__c = acc.Id;
        insert revenue; 
        
        Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
        att.OwnerId = userAE.Id;
        att.Division__c = TestData.get('Division_c_1');
        att.Region__c = TestData.get('Region_c_1');
        att.Status__c = 'Transfer Completed';
        att.Transfer_Effective_Date__c = Date.newInstance(2019, 01, 15);
        insert att;        
        
        Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
        atm.Account__c = acc.Id;
        atm.Account_Transfer_Simulation__c = att.Id;
        atm.From_User__c = userAE.Id;
        atm.To_User__c = userAE2.Id;
        atm.External_ID__c = userAE.Id+';;;'+acc.Id+';;;'+'2019Jan'+';;;'+att.Id;
        
        insert atm;
        
        Admin_Tool_Status_Summary__c adminSummary = new Admin_Tool_Status_Summary__c();
        adminSummary.From_User_Id__c = String.valueOf(userAE.Id);
        adminSummary.To_User_Id__c = String.valueOf(userAE2.Id);
        adminSummary.Transfer_Details__c = atm.Id;
        insert adminSummary;
        /*
        list<Account_Transfer_Mapping__c> lstAccRev =new list<Account_Transfer_Mapping__c>();
        lstAccRev.add(atm);
        New_AETransferToolController.updateRevenue(lstAccRev);
        
*/
        ApexPages.StandardController sc = new ApexPages.StandardController(att);
        ApexPages.currentPage().getParameters().put('id',att.id);
        ApexPages.currentPage().getParameters().put('retry','revenue');			        
        AccountTransferToolRetryController attrc = new AccountTransferToolRetryController(sc);
        
        attrc.retry(); 
   }
    }
    
    @isTest static Void BudgetSalesRetryTest(){
        
        User thisUser=[Select ID,Name from User Where ID=:UserInfo.getUserId()];
        
        List<Test_Data_Utility__mdt> ucList = new List<Test_Data_Utility__mdt>();
        
        Map<String,String> TestData = new Map<String, String>();
        
         ucList = [Select DeveloperName, label from Test_Data_Utility__mdt ];
        for(Test_Data_Utility__mdt abcd : ucList)
        {
            TestData.put(abcd.DeveloperName, abcd.label);
        }
        system.debug('TestData=-=====> '+ TestData.get('Region_c_1'));
        
        System.runAs(thisUser){
         //create AE User
        User userAE = TestUtil.prepareUser();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@mands.com';
        userAE.Budget_type__c = 'Local';
        userAE.Budget_product_Lines__c = 'Linear/News/Sports';
        userAE.rate_plan_status__c = 'Draft';
        insert userAE;
        
        //Create To AE User
        User userAE2 = TestUtil.prepareUser();
        userAE2.ProfileId = objProfile.Id;
        userAE2.Username = 'testae2@mands.com';
        userAE2.Budget_type__c = 'Local';
        userAE2.Budget_product_Lines__c = 'Linear/News/Sports';
        userAE2.rate_plan_status__c = 'Draft';
        insert userAE2;
		
		//create account
		Account acc = TestUtil.getAccountRec();
        acc.primary_commodity__c =   'Auto Aftermarket';
        insert acc;

		//create account team member
        AccountTeammember accTM = new AccountTeammember();
        accTM.UserID = userAE.Id;
        accTM.AccountId = acc.Id;
        accTM.Teammemberrole = 'Other';
        insert accTM;
		
		//create account share
        Accountshare accShare = new Accountshare();
        accShare.AccountId = acc.Id;
        accShare.UserOrGroupId = userAE.Id;
        accShare.AccountAccessLevel = 'Edit';
        accShare.OpportunityAccessLevel = 'Edit';
        insert accShare;
		Test.startTest();
        //create Sales Budget
        Sales_Budget__c sb = new Sales_Budget__c();
        sb = TestUtil.getSalesBudgetRec(userAE, acc);
        sb.Type__c = 'Data';
        sb.Amount__c = Integer.valueOf(Label.RatePlanThresholdAmount);
        sb.old_budget_user__c = userAE.Id;
        sb.OwnerId  = userAE.id;
        insert sb;
        
        Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
        att.Division__c = TestData.get('Division_c_1');
        att.Region__c = TestData.get('Region_c_1');
        att.Status__c = 'Transfer Completed';
        att.Transfer_Effective_Date__c = Date.newInstance(2019, 01, 15);
        att.OwnerId = userAE.Id;
        att.NCC__c = 'NCC' ;
        att.Transfer_All_Accounts__c = true;
        insert att;        

        Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
        atm.Account__c = acc.Id;
        atm.Account_Transfer_Simulation__c = att.Id;
        atm.From_User__c = userAE.Id;
        atm.To_User__c = userAE2.Id;
        atm.External_ID__c = userAE2.Id+';;;'+acc.Id+';;;'+'2019Jan'+';;;'+att.Id;
        insert atm;
        
        Admin_Tool_Status_Summary__c adminSummary = new Admin_Tool_Status_Summary__c();
        adminSummary.From_User_Id__c = String.valueOf(userAE.Id);
        adminSummary.To_User_Id__c = String.valueOf(userAE2.Id);
        adminSummary.Transfer_Details__c = atm.Id;
        insert adminSummary;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(att);
        ApexPages.currentPage().getParameters().put('id',att.id);
        ApexPages.currentPage().getParameters().put('retry','salesbudget');			        
        AccountTransferToolRetryController attrc = new AccountTransferToolRetryController(sc);
        
        attrc.retry(); 
        
        Test.stopTest();
        }}
    
    /*@isTest static Void AccountSAMRetryTest(){
        //create AE User
        User userAE = TestUtil.prepareUser();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@mands.com';
        userAE.Budget_type__c = 'Local';
        userAE.Budget_product_Lines__c = 'Linear/News/Sports';
        userAE.rate_plan_status__c = 'Draft';
        insert userAE;
        
        //Create To AE User
        User userAE2 = TestUtil.prepareUser();
        userAE2.ProfileId = objProfile.Id;
        userAE2.Username = 'testae2@mands.com';
        userAE2.Budget_type__c = 'Local';
        userAE2.Budget_product_Lines__c = 'Linear/News/Sports';
        userAE2.rate_plan_status__c = 'Draft';
        insert userAE2;
		
		//create account
		Account acc = TestUtil.getAccountRec();
        acc.primary_commodity__c =   'Auto Aftermarket';
        insert acc;

		//create account team member
        AccountTeammember accTM = new AccountTeammember();
        accTM.UserID = userAE.Id;
        accTM.AccountId = acc.Id;
        accTM.Teammemberrole = 'Other';
        insert accTM;
		
		//create account share
        Accountshare accShare = new Accountshare();
        accShare.AccountId = acc.Id;
        accShare.UserOrGroupId = userAE.Id;
        accShare.AccountAccessLevel = 'Edit';
        accShare.OpportunityAccessLevel = 'Edit';
        insert accShare;
        
        Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
        att.Division__c = 'Central';
        att.Region__c = 'MidNorth';
        att.Status__c = 'Transfer Completed';
        att.Transfer_Effective_Date__c = Date.newInstance(2019, 01, 15);
        att.OwnerId = userAE.Id;
        att.NCC__c = 'NCC' ;
        att.Transfer_All_Accounts__c = true;
        insert att;        

        Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
        atm.Account__c = acc.Id;
        atm.Account_Transfer_Simulation__c = att.Id;
        atm.From_User__c = userAE.Id;
        atm.To_User__c = userAE2.Id;
        atm.External_ID__c = userAE2.Id+';;;'+acc.Id+';;;'+'2019Jan'+';;;'+att.Id;
        insert atm;
        
        Admin_Tool_Status_Summary__c adminSummary = new Admin_Tool_Status_Summary__c();
        adminSummary.From_User_Id__c = String.valueOf(userAE.Id);
        adminSummary.To_User_Id__c = String.valueOf(userAE2.Id);
        adminSummary.Transfer_Details__c = atm.Id;
        insert adminSummary;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(att);
        ApexPages.currentPage().getParameters().put('id',att.id);
        ApexPages.currentPage().getParameters().put('retry','samdesignation');			        
        AccountTransferToolRetryController attrc = new AccountTransferToolRetryController(sc);
        
        attrc.retry(); 
    }
    */
    @isTest static Void AccountTeamRetryTest(){
        
        User thisUser=[Select ID,Name from User Where ID=:UserInfo.getUserId()];
        
        List<Test_Data_Utility__mdt> ucList = new List<Test_Data_Utility__mdt>();
        
        Map<String,String> TestData = new Map<String, String>();
        
         ucList = [Select DeveloperName, label from Test_Data_Utility__mdt ];
        for(Test_Data_Utility__mdt abcd : ucList)
        {
            TestData.put(abcd.DeveloperName, abcd.label);
        }
        system.debug('TestData=-=====> '+ TestData.get('Region_c_1'));
        
        System.runAs(thisUser){
        //create AE User
        User userAE = TestUtil.prepareUser();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@mands.com';
        userAE.Budget_type__c = 'Local';
        userAE.Budget_product_Lines__c = 'Linear/News/Sports';
        userAE.rate_plan_status__c = 'Draft';
        insert userAE;
        
        //Create To AE User
        User userAE2 = TestUtil.prepareUser();
        userAE2.ProfileId = objProfile.Id;
        userAE2.Username = 'testae2@mands.com';
        userAE2.Budget_type__c = 'Local';
        userAE2.Budget_product_Lines__c = 'Linear/News/Sports';
        userAE2.rate_plan_status__c = 'Draft';
        insert userAE2;
		
		//create account
		Account acc = TestUtil.getAccountRec();
        acc.primary_commodity__c =   'Auto Aftermarket';
        insert acc;

		//create account team member
        AccountTeammember accTM = new AccountTeammember();
        accTM.UserID = userAE.Id;
        accTM.AccountId = acc.Id;
        accTM.Teammemberrole = 'Other';
        insert accTM;
		
		//create account share
        Accountshare accShare = new Accountshare();
        accShare.AccountId = acc.Id;
        accShare.UserOrGroupId = userAE.Id;
        accShare.AccountAccessLevel = 'Edit';
        accShare.OpportunityAccessLevel = 'Edit';
        insert accShare;
        
        Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
        att.Division__c = TestData.get('Division_c_1');
        att.Region__c = TestData.get('Region_c_1');
        att.Status__c = 'Transfer Completed';
        att.Transfer_Effective_Date__c = Date.newInstance(2019, 01, 15);
        att.OwnerId = userAE.Id;
        att.NCC__c = 'NCC' ;
        att.Transfer_All_Accounts__c = true;
        insert att;        

        Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
        atm.Account__c = acc.Id;
        atm.Account_Transfer_Simulation__c = att.Id;
        atm.From_User__c = userAE.Id;
        atm.To_User__c = userAE2.Id;
        atm.External_ID__c = userAE2.Id+';;;'+acc.Id+';;;'+'2019Jan'+';;;'+att.Id;
        insert atm;
        
        Admin_Tool_Status_Summary__c adminSummary = new Admin_Tool_Status_Summary__c();
        adminSummary.From_User_Id__c = String.valueOf(userAE.Id);
        adminSummary.To_User_Id__c = String.valueOf(userAE2.Id);
        adminSummary.Transfer_Details__c = atm.Id;
        insert adminSummary;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(att);
        ApexPages.currentPage().getParameters().put('id',att.id);
        ApexPages.currentPage().getParameters().put('retry','accteam');			        
        AccountTransferToolRetryController attrc = new AccountTransferToolRetryController(sc);
        
        attrc.retry(); 
        }}
    
    @isTest static Void AccountConnectionRetryTest(){
        
        User thisUser=[Select ID,Name from User Where ID=:UserInfo.getUserId()];
        
        List<Test_Data_Utility__mdt> ucList = new List<Test_Data_Utility__mdt>();
        
        Map<String,String> TestData = new Map<String, String>();
        
         ucList = [Select DeveloperName, label from Test_Data_Utility__mdt ];
        for(Test_Data_Utility__mdt abcd : ucList)
        {
            TestData.put(abcd.DeveloperName, abcd.label);
        }
        system.debug('TestData=-=====> '+ TestData.get('Region_c_1'));
        
        System.runAs(thisUser){
        //create AE User
        User userAE = TestUtil.prepareUser();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@mands.com';
        userAE.Budget_type__c = 'Local';
        userAE.Budget_product_Lines__c = 'Linear/News/Sports';
        userAE.rate_plan_status__c = 'Draft';
        insert userAE;
        
        //Create To AE User
        User userAE2 = TestUtil.prepareUser();
        userAE2.ProfileId = objProfile.Id;
        userAE2.Username = 'testae2@mands.com';
        userAE2.Budget_type__c = 'Local';
        userAE2.Budget_product_Lines__c = 'Linear/News/Sports';
        userAE2.rate_plan_status__c = 'Draft';
        insert userAE2;
		
		//create account
		Account acc = TestUtil.getAccountRec();
        acc.primary_commodity__c =   'Auto Aftermarket';
        insert acc;

		//create account team member
        AccountTeammember accTM = new AccountTeammember();
        accTM.UserID = userAE.Id;
        accTM.AccountId = acc.Id;
        accTM.Teammemberrole = 'Other';
        insert accTM;
		
		//create account share
        Accountshare accShare = new Accountshare();
        accShare.AccountId = acc.Id;
        accShare.UserOrGroupId = userAE.Id;
        accShare.AccountAccessLevel = 'Edit';
        accShare.OpportunityAccessLevel = 'Edit';
        insert accShare;
        
        Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
        att.Division__c = TestData.get('Division_c_1');
        att.Region__c = TestData.get('Region_c_1');
        att.Status__c = 'Transfer Completed';
        att.Transfer_Effective_Date__c = Date.newInstance(2019, 01, 15);
        att.OwnerId = userAE.Id;
        att.NCC__c = 'NCC' ;
        att.Transfer_All_Accounts__c = true;
        insert att;        

        Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
        atm.Account__c = acc.Id;
        atm.Account_Transfer_Simulation__c = att.Id;
        atm.From_User__c = userAE.Id;
        atm.To_User__c = userAE2.Id;
        atm.External_ID__c = userAE2.Id+';;;'+acc.Id+';;;'+'2019Jan'+';;;'+att.Id;
        insert atm;
        
        Admin_Tool_Status_Summary__c adminSummary = new Admin_Tool_Status_Summary__c();
        adminSummary.From_User_Id__c = String.valueOf(userAE.Id);
        adminSummary.To_User_Id__c = String.valueOf(userAE2.Id);
        adminSummary.Transfer_Details__c = atm.Id;
        insert adminSummary;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(att);
        ApexPages.currentPage().getParameters().put('id',att.id);
        ApexPages.currentPage().getParameters().put('retry','accountconn');			        
        AccountTransferToolRetryController attrc = new AccountTransferToolRetryController(sc);
        
        attrc.retry(); 
        }}
    
    @isTest static Void NewBusinessRetryTest(){
        
        User thisUser=[Select ID,Name from User Where ID=:UserInfo.getUserId()];
        
        List<Test_Data_Utility__mdt> ucList = new List<Test_Data_Utility__mdt>();
        
        Map<String,String> TestData = new Map<String, String>();
        
         ucList = [Select DeveloperName, label from Test_Data_Utility__mdt ];
        for(Test_Data_Utility__mdt abcd : ucList)
        {
            TestData.put(abcd.DeveloperName, abcd.label);
        }
        
        System.runAs(thisUser){
            
        //create AE User
        User userAE = TestUtil.prepareUser();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@mands.com';
        userAE.Budget_type__c = 'Local';
        userAE.Budget_product_Lines__c = 'Linear/News/Sports';
        userAE.rate_plan_status__c = 'Draft';
        insert userAE;
        
        //Create To AE User
        User userAE2 = TestUtil.prepareUser();
        userAE2.ProfileId = objProfile.Id;
        userAE2.Username = 'testae2@mands.com';
        userAE2.Budget_type__c = 'Local';
        userAE2.Budget_product_Lines__c = 'Linear/News/Sports';
        userAE2.rate_plan_status__c = 'Draft';
        insert userAE2;
		
		//create account
		Account acc = TestUtil.getAccountRec();
        acc.primary_commodity__c =   'Auto Aftermarket';
        insert acc;

		//create account team member
        AccountTeammember accTM = new AccountTeammember();
        accTM.UserID = userAE.Id;
        accTM.AccountId = acc.Id;
        accTM.Teammemberrole = 'Other';
        insert accTM;
		
		//create account share
        Accountshare accShare = new Accountshare();
        accShare.AccountId = acc.Id;
        accShare.UserOrGroupId = userAE.Id;
        accShare.AccountAccessLevel = 'Edit';
        accShare.OpportunityAccessLevel = 'Edit';
        insert accShare;
        
        Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
        att.Division__c = TestData.get('Division_c_1');
        att.Region__c = TestData.get('Region_c_1');
        att.Status__c = 'Transfer Completed';
        att.Transfer_Effective_Date__c = Date.newInstance(2019, 01, 15);
        att.OwnerId = userAE.Id;
        att.NCC__c = 'NCC' ;
        att.Transfer_All_Accounts__c = true;
        insert att;        

        Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
        atm.Account__c = acc.Id;
        atm.Account_Transfer_Simulation__c = att.Id;
        atm.From_User__c = userAE.Id;
        atm.To_User__c = userAE2.Id;
        atm.External_ID__c = userAE2.Id+';;;'+acc.Id+';;;'+'2019Jan'+';;;'+att.Id;
        insert atm;
        
        Admin_Tool_Status_Summary__c adminSummary = new Admin_Tool_Status_Summary__c();
        adminSummary.From_User_Id__c = String.valueOf(userAE.Id);
        adminSummary.To_User_Id__c = String.valueOf(userAE2.Id);
        adminSummary.Transfer_Details__c = atm.Id;
        insert adminSummary;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(att);
        ApexPages.currentPage().getParameters().put('id',att.id);
        ApexPages.currentPage().getParameters().put('retry','newsbusiness');			        
        AccountTransferToolRetryController attrc = new AccountTransferToolRetryController(sc);
        
        attrc.retry(); 
        }}
    
    @isTest static Void NewBusinessRetryTranferNotCompleteTest(){
        
        User thisUser=[Select ID,Name from User Where ID=:UserInfo.getUserId()];
        
        List<Test_Data_Utility__mdt> ucList = new List<Test_Data_Utility__mdt>();
        
        Map<String,String> TestData = new Map<String, String>();
        
         ucList = [Select DeveloperName, label from Test_Data_Utility__mdt ];
        for(Test_Data_Utility__mdt abcd : ucList)
        {
            TestData.put(abcd.DeveloperName, abcd.label);
        }
        
        System.runAs(thisUser){
            
        //create AE User
        User userAE = TestUtil.prepareUser();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@mands.com';
        userAE.Budget_type__c = 'Local';
        userAE.Budget_product_Lines__c = 'Linear/News/Sports';
        userAE.rate_plan_status__c = 'Draft';
        insert userAE;
        
        //Create To AE User
        User userAE2 = TestUtil.prepareUser();
        userAE2.ProfileId = objProfile.Id;
        userAE2.Username = 'testae2@mands.com';
        userAE2.Budget_type__c = 'Local';
        userAE2.Budget_product_Lines__c = 'Linear/News/Sports';
        userAE2.rate_plan_status__c = 'Draft';
        insert userAE2;
		
		//create account
		Account acc = TestUtil.getAccountRec();
        acc.primary_commodity__c =   'Auto Aftermarket';
        insert acc;

		//create account team member
        AccountTeammember accTM = new AccountTeammember();
        accTM.UserID = userAE.Id;
        accTM.AccountId = acc.Id;
        accTM.Teammemberrole = 'Other';
        insert accTM;
		
		//create account share
        Accountshare accShare = new Accountshare();
        accShare.AccountId = acc.Id;
        accShare.UserOrGroupId = userAE.Id;
        accShare.AccountAccessLevel = 'Edit';
        accShare.OpportunityAccessLevel = 'Edit';
        insert accShare;
        
        Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
        att.Division__c = TestData.get('Division_c_1');
        att.Region__c = TestData.get('Region_c_1');
        att.Status__c = 'New';
        att.Transfer_Effective_Date__c = Date.newInstance(2019, 01, 15);
        att.OwnerId = userAE.Id;
        att.NCC__c = 'NCC' ;
        att.Transfer_All_Accounts__c = true;
        insert att;        

        Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
        atm.Account__c = acc.Id;
        atm.Account_Transfer_Simulation__c = att.Id;
        atm.From_User__c = userAE.Id;
        atm.To_User__c = userAE2.Id;
        atm.External_ID__c = userAE2.Id+';;;'+acc.Id+';;;'+'2019Jan'+';;;'+att.Id;
        insert atm;
        
        Admin_Tool_Status_Summary__c adminSummary = new Admin_Tool_Status_Summary__c();
        adminSummary.From_User_Id__c = String.valueOf(userAE.Id);
        adminSummary.To_User_Id__c = String.valueOf(userAE2.Id);
        adminSummary.Transfer_Details__c = atm.Id;
        insert adminSummary;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(att);
        ApexPages.currentPage().getParameters().put('id',att.id);
        ApexPages.currentPage().getParameters().put('retry','newsbusiness');			        
        AccountTransferToolRetryController attrc = new AccountTransferToolRetryController(sc);
        
        attrc.retry(); 
    }
    } }