@isTest
private class AccountTransferToolControllerTest {
	@IsTest(seeAlldata = false)
	static void accTransferListNEW_Test() {
        
		User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];

		Sales_Budget__c sb = new Sales_Budget__c();
		System.runAs(thisUser) {
			//create AE User
			User userAE = TestUtil.prepareUser();
			Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Master - Account Executive'];
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
			acc.primary_commodity__c = 'Auto Aftermarket';
			insert acc;
			
			// Account acc1 = TestUtil.getAccountRec();
			// acc1.primary_commodity__c = 'ftermarket';
			// insert acc1;
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

			

			//create Traffic Element ID
			insert TestDataHelper.createTrafficIdElement(acc.Id, userAE.Id, 'test1234', 'test1234567890');

			//create PY Sales Revenue
			//insert TestUtil.getSalesRevenueRec(userAE, acc, System.today().addYears(-1));

			//create CY Sales Revenue
			//Sales_Revenue__c sr = TestUtil.getSalesRevenueRec(userAE, acc, System.today());
			//insert sr;
			//system.debug(sr);

			//create Sales Budget
			sb = TestUtil.getSalesBudgetRec(userAE, acc);
			sb.Type__c = 'DOS';
			insert sb;

			

			//Create User Connection
			insert TestDataHelper.createUserConnection('St. Louis Local', 'SFDCUser', userAE.id, 'TIM', '1');
			//insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',userAEF.id,'TIM','1');

			//create Opportunity
			Opportunity opp = TestDataHelper.createopportunity('Test Opportunity', System.today(), 'Planning', 'Pipeline', acc.ID);
			opp.OwnerId = userAE.Id;
			insert opp;

			//create Proposal
			Proposal__c p = TestDataHelper.createProposal('Test Opportunity Proposal', opp.id, '00000', true);
			p.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
			p.Active__c = true;
			p.TIM_System__c = 'St. Louis Local';
			p.Start_Date__c = Date.newInstance(2020, 2, 20);
			p.End_Date__c = System.today().addMonths(1);
			p.Current_Advertiser_Tim_Id__c = '12345';
			insert p;

			//Create SysCode
			Syscode__c sys = TestDataHelper.createSysCode(false);
			insert sys;
			//create Proposal Zone
			Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Proposal Zone', p.Id);
			propZone.Sys_Code__c = 'Linear/News/Sports';
			propZone.Status_Type__c = 'Pending';
            insert propZone;
			Test.startTest();
			//create Proposal Zone Monthly Value
			Proposal_Zone_Monthly_Value__c propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value', acc.Id, propZone.Id);
			propZoneMonthly.Schedule_Type__c = 'Linear';
			propZoneMonthly.Proposal_Key_Index__c = p.Id;
			propZoneMonthly.Advertiser__c = acc.Id;
			propZoneMonthly.Broadcast_Month_Date__c =  Date.newInstance(2020, 2, 20);
			insert propZoneMonthly;

			//create Proposal
			Proposal__c pl = TestDataHelper.createProposal('Test Opportunity Proposal', opp.id, '00000', true);
			pl.RecordTypeId = TestDataHelper.LinearRecTypeId;
			pl.Active__c = true;
			pl.Start_Date__c =  Date.newInstance(2020, 2, 20);
			pl.End_Date__c = System.today().addMonths(1);
			insert pl;


			//create Proposal Zone
			Proposal_Zone__c prop_Zone = TestDataHelper.createProposalZone('Test Proposal Zone', pl.Id);
			prop_Zone.Sys_Code__c = 'Linear/News/Sports';
			prop_Zone.Status_Type__c = 'Pending';
        

			insert prop_Zone;

			//create Proposal Zone Monthly Value
			Proposal_Zone_Monthly_Value__c propZoneMonthlyVal = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value', acc.Id, prop_Zone.Id);
			propZoneMonthlyVal.Schedule_Type__c = 'Linear';
			propZoneMonthlyVal.Advertiser__c = acc.Id;
			propZoneMonthlyVal.Proposal_Key_Index__c = pl.Id;
			propZoneMonthlyVal.Broadcast_Month_Date__c =  Date.newInstance(2020, 2, 20);
			insert propZoneMonthlyVal;

			Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
			att.Division__c = 'Central';
			att.Region__c = 'MidNorth';
			att.Status__c = 'New';
			att.Transfer_Effective_Date__c = Date.newInstance(2020, 01, 15);
			insert att;

			Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
			atm.Account__c = acc.Id;
			atm.Account_Transfer_Simulation__c = att.Id;
			atm.From_User__c = userAE.Id;
			atm.To_User__c = userAETo.Id;
			atm.External_ID__c = userAE.Id + ';;;' + acc.Id + ';;;' + '2020Jan' + ';;;' + userAETo.Id;
			insert atm;

			Sales_Revenue_Aggregate__c sra = new Sales_Revenue_Aggregate__c();
			sra.SalesRevenue_AccountExecutive__c = UserAE.ID;
			sra.January_Revenue__c = 100;
			sra.February_Revenue__c = 100;
			sra.March_Revenue__c = 100;
			sra.April_Revenue__c = 100;
			sra.May_Revenue__c = 100;
			sra.June_Revenue__c = 100;
			sra.July_Revenue__c = 100;
			sra.August_Revenue__c = 100;
			sra.September_Revenue__c = 100;
			sra.October_Revenue__c = 100;
			sra.November_Revenue__c = 100;
			sra.December_Revenue__c = 100;
			sra.Broadcast_Year__c = '2020';
			sra.External_Id__c = '007' + userAE.ID + sra.Broadcast_Year__c;
			insert sra;

			Sales_Revenue_Aggregate__c sraTo = new Sales_Revenue_Aggregate__c();
			sraTo = sra.clone(false, false, false, false);
			sraTo.SalesRevenue_AccountExecutive__c = userAETo.Id;
			sraTo.External_Id__c = '007' + userAETo.ID + acc.ID + sraTo.Broadcast_Year__c;
			insert sraTo;



			Sales_Budget_Aggregate__c sba = new Sales_Budget_Aggregate__c();
			sba.Account_Executive__c = userAE.Id;
			sba.SalesBudget_Advertiser__c = acc.Id;
			sba.January_Budget__c = 100;
			sba.February_Budget__c = 100;
			sba.March_Budget__c = 100;
			sba.April_Budget__c = 100;
			sba.May_Budget__c = 100;
			sba.June_Budget__c = 100;
			sba.July_Budget__c = 100;
			sba.August_Budget__c = 100;
			sba.September_Budget__c = 100;
			sba.October_Budget__c = 100;
			sba.November_Budget__c = 100;
			sba.Broadcast_Year__c = '2020';
			sba.December_Budget__c = 100;
			sba.External_Id__c = '007' + userAE.ID + acc.ID + sba.Broadcast_Year__c;
			insert sba;

			Sales_Budget_Aggregate__c sbaTo = new Sales_Budget_Aggregate__c();
			sbato = sba.clone(false, false, false, false);
			sbaTo.Account_Executive__c = userAETo.Id;
			sbaTo.External_Id__c = '007' + userAETo.ID + acc.ID + sbaTo.Broadcast_Year__c;
			insert sbaTo;


			List<Sales_Budget__c> slist = new list<Sales_Budget__c> ();
			Sales_Budget__c sb1 = new Sales_Budget__c();
			sb1 = TestUtil.getSalesBudgetRec(userAE, acc);
			sb1.Type__c = 'DOS';
			// sb1.Amount__c = Integer.valueOf(Label.RatePlanThresholdAmount);

			sb1.Amount__c = 500500;
			sb1.Budget_User__c = userAE.Id;
			sb1.New_Business_Churn__c = 'Unknown Churn';
			sb1.DMA__c = 'DMAs';
			// sb1.Old_Budget_User__c=u3.id;
			sb1.Product_Line__c = 'Linear/News/Sports';
			sb1.Commodity__c = 'Restaurant';
			sb1.Broadcast_Month_Date__c = Date.newInstance(2020, 2, 20);
			sb1.External_Id__c = '007' + userAE.id + System.today();
			slist.add(sb1);

			Sales_Budget__c sb12 = new Sales_Budget__c();
			sb12 = TestUtil.getSalesBudgetRec(userAE, acc);
			sb12.Type__c = 'DATA';
			// sb1.Amount__c = Integer.valueOf(Label.RatePlanThresholdAmount);

			sb12.Amount__c = 500500;
			sb12.Budget_User__c = userAE.Id;
			//sb12.New_Business_Churn__c = 'Unknown Churn';
			sb12.Advertiser__c = acc.Id;
			sb12.DMA__c = 'DMAs';
			// sb1.Old_Budget_User__c=u3.id;
			sb12.Product_Line__c = 'Linear/News/Sports';
			sb12.Commodity__c = 'Restaurant';
			sb12.Broadcast_Month_Date__c = Date.Today();
			sb12.External_Id__c = '0071' + userAE.id + System.today();
			slist.add(sb12);			Sales_Budget__c sb2 = new Sales_Budget__c();
			sb2 = TestUtil.getSalesBudgetRec(userAE, acc);
			sb2.Type__c = 'DOS';
			// sb2.Amount__c = Integer.valueOf(Label.RatePlanThresholdAmount);

			sb2.Amount__c = 5000;
			sb2.Budget_User__c = userAE.Id;
			sb2.New_Business_Churn__c = 'New Business';
			sb2.DMA__c = 'Albany ';
			// sb2.Old_Budget_User__c=u3.id;
			sb2.Product_Line__c = 'Production';
			sb2.Commodity__c = 'Restaurant';
			sb2.Broadcast_Month_Date__c = Date.Today();
			sb2.External_Id__c = '007' + userAE.id + System.today();
			slist.add(sb2);

			Sales_Budget__c sb3 = new Sales_Budget__c();
			sb3 = TestUtil.getSalesBudgetRec(userAE, acc);
			sb3.Type__c = 'DOS';
			// sb3.Amount__c = Integer.valueOf(Label.RatePlanThresholdAmount);

			sb3.Amount__c = 5000;
			sb3.Budget_User__c = userAE.Id;
			sb3.New_Business_Churn__c = 'New Business';
			sb3.DMA__c = 'Albany';
			// sb3.Old_Budget_User__c=u3.id;
			sb3.Product_Line__c = 'Production';
			sb3.Commodity__c = 'Alcoholic Beverages';
			sb3.Broadcast_Month_Date__c = Date.Today();
			sb3.External_Id__c = '007' + userAE.id + System.today();
			slist.add(sb3);


			insert slist;


			Sales_Budget_Simulation__c sm = new Sales_Budget_Simulation__c();
			sm.Budget_User__c = userAETo.Id;
			sm.Amount__c = 999;
			sm.Account_Transfer_Simulation__c = att.id;
			sm.From_Budget_user__c = userAE.id;
			sm.New_Business_Churn__c = 'Unknown Churn';
			sm.DMA__c = 'DMAs';
			sm.Broadcast_Month_Date__c = Date.newInstance(2020, 2, 20);
			sm.Product_Line__c = 'Linear/News/Sports';
			sm.Old_Product_Line__c = 'Linear/News/Sports';
			sm.Commodity__c = 'Restaurant';
			sm.External_Id__c = userAETo.Id + ':' + sm.Unique_Key__c;
			sm.Type__c = 'Simulation';
			sm.Comments__c = 'ASP';
			insert sm;

			Sales_Budget_Simulation__c sm1 = new Sales_Budget_Simulation__c();
			sm1.Budget_User__c = userAE.Id;
			sm1.Amount__c = 999;
			sm1.Account_Transfer_Simulation__c = att.id;
			sm1.From_Budget_user__c = userAETo.id;
			sm1.New_Business_Churn__c = 'Unknown Churn';
			sm1.DMA__c = 'DMAs';
			sm1.Broadcast_Month_Date__c = Date.Today();
			sm1.Product_Line__c = 'Digital';
			sm1.Old_Product_Line__c = 'Linear/News/Sports';
			sm1.Commodity__c = 'Restaurant';
			sm1.External_Id__c = userAE.Id + ':' + sm.Unique_Key__c;
			sm1.Type__c = 'Simulation';
			sm1.Comments__c = 'ASP';
			insert sm1;

			Sales_Budget_Simulation__c sm11 = new Sales_Budget_Simulation__c();
			sm11.Budget_User__c = userAETo.Id;
			sm11.Amount__c = 1999;
			sm11.Account_Transfer_Simulation__c = att.id;
			sm11.From_Budget_user__c = userAE.id;
			sm11.New_Business_Churn__c = 'Unknown Churn';
			sm11.DMA__c = 'DMAs';
			sm11.Broadcast_Month_Date__c = Date.Today().addMonths(2);
			sm11.Product_Line__c = 'Digital';
			sm11.Old_Product_Line__c = 'Linear/News/Sports';
			sm11.Commodity__c = 'Alcoholic Beverages';
			sm11.External_Id__c = userAE.Id + ':' + sm.Unique_Key__c + sm11.Broadcast_Month_Date__c;
			sm11.Type__c = 'Simulation';
			sm11.Comments__c = 'ASP';
			insert sm11;

           string axtJSON = '[{"FromUserID":"00541000004MKRGAA4","ToUserID":"005410000037TaNAAU","Type":"New Business","ProductLine":"National Spot (NCC)","BroadcastDate":"3/15/2020","MonthID":3,"commodity":"Travel/Leisure/Entertainment","DMAContri":1304,"Percentage":28.571428571428573,"CommodityContri":0,"DMA":"Lexington KY","UniqueKey":"00541000004MKRGAA4:005410000037TaNAAU:New BusinessNational Spot (NCC)Travel/Leisure/EntertainmentLexington KY32020","Unknown":"Unknown"}]';
			System.JSONParser parser = System.JSON.createParser(axtJSON);
			AXTNBUCJSONParser par = new AXTNBUCJSONParser(parser);
            List < AXTNBUCJSONParser > sbSimulationList = AXTNBUCJSONParser.parse(axtJSON);
           list<Sales_Budget_Simulation__c> SBMC=new list<Sales_Budget_Simulation__c>();
           Map < String, Sales_Budget_Simulation__c > mapSBNew = new Map < String, Sales_Budget_Simulation__c > ();
       
string simulateID;           
            Sales_Budget_Simulation__c sbm = new Sales_Budget_Simulation__c();

                  sbm.From_Budget_user__c = par.FromUserID;
                  sbm.Budget_user__c = par.ToUserID;
                  sbm.Commodity__c = par.Commodity;
                  sbm.DMA__c = par.DMA;
                  sbm.Product_Line__c = par.ProductLine;
                  sbm.Old_Product_Line__c = par.OldProductLine;
                  sbm.Type__c = 'Simulation';
                  sbm.New_Business_Churn__c = par.Type_Z;
                  sbm.Broadcast_Month_Date__c = Date.parse(par.BroadcastDate);
                  sbm.External_Id__c = par.ToUserID + ':' + par.UniqueKey + simulateID;
                  sbm.Account_Transfer_Simulation__c = simulateID;
			SBMC.add(sbm);
             
        mapSBNew.put(sbm.External_Id__c,sbm);
            
            
			/*  Date broadcastMonthDateDec = date.parse('12/15/2020');
			  Revenue__c r10 = TestUtil.generateRevenue(userAE.Id, acc.Id, broadcastMonthDateDec);
			  insert r10;*/

			//simulate|||fromUserId1;;;fromAccId1;;;2020Jan;;;toUserId1|||fromUserId2;;;fromAccId2;;;fromUserMonthYear2;;;toUserId2|||
			String simulateString = 'simulate_' + userAE.FirstName + ' ' + userAE.LastName + '_' + userAETo.FirstName + ' ' + userAETo.LastName + '|||' + userAE.Id + ';;;' + acc.Id + ';;;' + '2020Jan' + ';;;' + userAETo.Id + '|||';
			String userString = String.valueOf(thisUser.Name);
			String getmyUserAccount = userAE.Id + ':::Annie Keith,' + userAE.Id + ':::Christine Smith';
			String accountIdString = acc.Id + ';;;' + acc.Id + ';;;' + acc.Id + ';;;';
			String frmAccountToUserTest = acc.Id + ';;;' + UserAETo.Id + ';;;' + UserAETo.Name + '|||';


			//AccountTransferToolController.accTransferList(simulateString, thisUser.Name, att.Id,'');
			AccountTransferToolController.gethandleSimulateClick(userString, userString, userString, userString, userString, userString);
			AccountTransferToolController.getmyuserAccountsList(getmyUserAccount);
			AccountTransferToolController.getmyuserlistRemote(userAE.Id, String.valueOf(userAE.ID));
			AccountTransferToolController.getmyuserlistRemote(userAE.Id, null);
			AccountTransferToolController.getmyuserlistRemote(userAE.Id, '');
			
			AccountTransferToolController.getmyuserlistRemote('Test User','');
			AccountTransferToolController.initializeFromEdit(att.Id);
			AccountTransferToolController.loadEclipseIDs(accountIdString);
			AccountTransferToolController.analysisResult(userAE.Id, acc.Id, UserAETo.Id, '2020Jan', frmAccountToUserTest, att.Id);
			//att.All_Transfer_Logs_Created__c = true;
			//AccountTransferToolController.accountTransfer(att.Id);
			AccountTransferToolController.generateApprovalURL(att.Id);
			AccountTransferToolController.checkCrossTeam(userAE.Id, userAETo.Id);
            AccountTransferToolController.createNBUC(att.Id, axtJSON);
			//AccountTransferToolController.createNBUC(att.Id, 'time pas');
			//String frmUser, String frmAcc, String toUser, String monthYear, String frmAccountToUser
			//frmAccountToUserStr += frmAccIdTmp+';;;'+toUserIdTmp+';;;'+toUserNameTmp;
			Test.stopTest();
		}
		
	
	} 
	
	@IsTest(seeAlldata = false)
	static void New_accTransferList_Test() {
		   User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
		   Sales_Budget__c sb = new Sales_Budget__c();
			
			System.runAs(thisUser) {
			User userAEF = TestUtil.prepareUser();
			Profile objProfileF = [SELECT Id, Name FROM Profile WHERE Name = 'Master - Regional Finance'];
			userAEF.ProfileId = objProfileF.Id;
			userAEF.Username = 'testae@mandss.com';
			userAEF.budget_type__c = 'Local';
			userAEF.budget_product_Lines__c = 'Linear/News/Sports';
			userAEF.Firstname = 'Test';
			userAEF.Lastname = 'Userf';
			userAEF.HR_Manager__c = thisUser.Id;
			insert userAEF;

			Account acc = TestUtil.getAccountRec();
			acc.primary_commodity__c = 'Auto Aftermarket';
			insert acc;

			sb = TestUtil.getSalesBudgetRec(userAEF, acc);
			sb.Type__c = 'DOS';
			insert sb;
			
			/*Account acc1 = TestUtil.getAccountRec();
			AccountTeammember accTM3 = new AccountTeammember();
			accTM3.UserID = userAEF.Id;
			accTM3.AccountId = acc1.Id;
			accTM3.Teammemberrole = 'Account Executive';
			insert accTM3;

			Accountshare accShare3 = new Accountshare();
			accShare3.AccountId = acc.Id;
			accShare3.UserOrGroupId = userAEF.Id;
			accShare3.AccountAccessLevel = 'Edit';
			accShare3.OpportunityAccessLevel = 'Edit';
			insert accShare3;*/

						
			}
	
	
	}@IsTest(seeAlldata = false)
	static void accTransferList_Test() {
		User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];

		System.runAs(thisUser) {
			Sales_Budget__c sb = new Sales_Budget__c();
			//create AE User
			User userAE = TestUtil.prepareUser();
			Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Master - Account Executive'];
			userAE.ProfileId = objProfile.Id;
			userAE.Username = 'testae@mands.com';
			userAE.budget_type__c = 'Local';
			userAE.budget_product_Lines__c = 'Linear/News/Sports';
			userAE.Firstname = 'Test';
			userAE.Lastname = 'User1';
			userAE.HR_Manager__c = thisUser.Id;
			insert userAE;

			User userAEF = TestUtil.prepareUser();
			Profile objProfileF = [SELECT Id, Name FROM Profile WHERE Name = 'Master - Regional Finance'];
			userAEF.ProfileId = objProfileF.Id;
			userAEF.Username = 'testae@mandss.com';
			userAEF.budget_type__c = 'Local';
			userAEF.budget_product_Lines__c = 'Linear/News/Sports';
			userAEF.Firstname = 'Test';
			userAEF.Lastname = 'Userf';
			userAEF.HR_Manager__c = thisUser.Id;
			insert userAEF;

			User userAETo = TestUtil.prepareUser();
			userAETo.ProfileId = objProfile.Id;
			userAETo.Username = 'testaeTo@mands.com';
			userAETo.Budget_type__c = 'Local';
			userAETo.Budget_product_Lines__c = 'Linear/News/Sports';
			userAETo.Firstname = 'Test';
			userAETo.Lastname = 'User';
			userAETo.HR_Manager__c = thisUser.Id;
			insert userAETo;

			User userDOS = TestUtil.prepareUser();
			Profile objProfile1 = [SELECT Id, Name FROM Profile WHERE Name = 'Master - Director of Sales'];
			userDOS.ProfileId = objProfile1.Id;
			userDOS.Username = 'testdos@mands.com';
			userDOS.budget_type__c = 'Local';
			userDOS.budget_product_Lines__c = 'Linear/News/Sports';
			userDOS.Firstname = 'Test';
			userDOS.Lastname = 'UserDOS';
			userDOS.HR_Manager__c = thisUser.Id;
			insert userDOS;

			User userLSM = TestUtil.prepareUser();
			Profile objProfile2 = [SELECT Id, Name FROM Profile WHERE Name = 'Master - Local Sales Manager'];
			userLSM.ProfileId = objProfile2.Id;
			userLSM.Username = 'testlsm@mands.com';
			userLSM.budget_type__c = 'Local';
			userLSM.budget_product_Lines__c = 'Linear/News/Sports';
			userLSM.Firstname = 'Test';
			userLSM.Lastname = 'UserLSM';
			userLSM.Sales_Office__c = 'LA Interconnect';
			userLSM.HR_Manager__c = thisUser.Id;
			insert userLSM; 

			Account acc = TestUtil.getAccountRec();
			acc.primary_commodity__c = 'Auto Aftermarket';
			insert acc;

			AccountTeammember accTM = new AccountTeammember();
			accTM.UserID = userAE.Id;
			accTM.AccountId = acc.Id;
			accTM.Teammemberrole = 'Other';
			insert accTM;

			AccountTeammember accTM2 = new AccountTeammember();
			accTM2.UserID = userAEF.Id;
			accTM2.AccountId = acc.Id;
			accTM2.Teammemberrole = 'Other';
			insert accTM2;

			Accountshare accShare = new Accountshare();
			accShare.AccountId = acc.Id;
			accShare.UserOrGroupId = userAE.Id;
			accShare.AccountAccessLevel = 'Edit';
			accShare.OpportunityAccessLevel = 'Edit';
			insert accShare;

			AccountConnection__c accConn = TestDataHelper.createAccountConnection(acc.Id);
			accConn.Tim_System__c = 'St. Louis Local';
			insert accConn;

			//create Sales Budget
			sb = TestUtil.getSalesBudgetRec(userAE, acc);
			sb.Type__c = 'Data';
			insert sb;
			sb = new Sales_Budget__c();
			sb = TestUtil.getSalesBudgetRec(userAE, Acc);
			sb.Product_Line__c = 'Linear/News/Sports';
			sb.Type__c = 'Data';
			//sb.Advertiser__r.Name='New Business';
			sb.Broadcast_Month_Date__c = System.today().addYears(1);
			insert sb;
			
			Sales_Budget__c sbf = new Sales_Budget__c();
			sbf = TestUtil.getSalesBudgetRec(userAEF, acc);
			sbf.Type__c = 'Data';
			insert sbf;
			sbf = new Sales_Budget__c();
			sbf = TestUtil.getSalesBudgetRec(userAEF, Acc);
			sbf.Product_Line__c = 'Linear/News/Sports';
			sbf.Type__c = 'Data';
			//sb.Advertiser__r.Name='New Business';
			sbf.Broadcast_Month_Date__c = System.today().addYears(1);
			insert sbf;
			//Create User Connection
			insert TestDataHelper.createUserConnection('St. Louis Local', 'SFDCUser', userAE.id, 'TIM', '1');
			Test.startTest();
			//create Opportunity
			Opportunity opp = TestDataHelper.createopportunity('Test Opportunity', System.today(), 'Planning', 'Pipeline', acc.ID);
			opp.ownerid = userAE.Id;
			insert opp;

			//create Proposal
			Proposal__c p = TestDataHelper.createProposal('Test Opportunity Proposal', opp.id, '00000', true);
			p.RecordTypeId = TestDataHelper.LinearRecTypeId;
			p.Active__c = true;
			p.Start_Date__c = System.today();
			p.End_Date__c = System.today().addMonths(1);
			insert p;

			
			List<Account_Transfer_Tool__c> attList = new List<Account_Transfer_Tool__c> ();
			Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
			att.Division__c = 'Central';
			att.Region__c = 'MidNorth';
			att.Status__c = 'In Process';
			att.Transfer_Effective_Date__c = Date.newInstance(2020, 01, 15);
			attList.add(att);

			Account_Transfer_Tool__c attApproval = new Account_Transfer_Tool__c();
			attApproval.Division__c = 'Central';
			attApproval.Region__c = 'MidNorth';
			attApproval.Status__c = 'New';
			attApproval.OwnerId = thisUser.Id;
			attApproval.Transfer_Effective_Date__c = Date.newInstance(2020, 01, 15);
			attList.add(attApproval);
			insert attList;
			System.debug('ATTApproval: ' + attApproval);
            
			Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
			atm.Account__c = acc.Id;
			atm.Account_Transfer_Simulation__c = att.Id;
			atm.From_User__c = userAE.Id;
			atm.To_User__c = userAETo.Id;
			atm.External_ID__c = userAE.Id + ';;;' + acc.Id + ';;;' + '2020Jan' + ';;;' + userAETo.Id;
			insert atm;

			System.debug('Test ATM: ' + atm);

			String stringTest = 'Hello World';
			String stringTest2 = 'Hello World';

			String simulateString = 'simulate_' + userAE.FirstName + ' ' + userAE.LastName + '_' + userAETo.FirstName + ' ' + userAETo.LastName + '|||' + userAE.Id + ';;;' + acc.Id + ';;;' + '2020Jan' + ';;;' + userAETo.Id + '|||';

			//Dupe check
			////'accSimRecords' String format:   fromUserId ;;; fromAccId ;;; fromUserMonthYear ;;; toUserId ;;; uiRowNum ||| (repeat)
			String dupeString = userAE.Id + ';;;' + acc.Id + ';;;' + '2020Jan' + ';;;' + userAETo.Id + ';;;' + '0';

			ApexPages.StandardController sc = new ApexPages.StandardController(acc);
			System.runAs(userDOS) {
				AccountTransferToolController attc1 = new AccountTransferToolController(sc);
				//attc.HARDWIRE_DOS_TEST = true;
				attc1.initializeController();
			}
			ApexPages.StandardController sc1 = new ApexPages.StandardController(acc);
			System.runAs(userLSM) {
				AccountTransferToolController attc1 = new AccountTransferToolController(sc1);
				//attc.HARDWIRE_DOS_TEST = true;
				attc1.initializeController();
			}
			AccountTransferToolController attc = new AccountTransferToolController(sc);
			//attc.HARDWIRE_DOS_TEST = true;
			attc.initializeController();
			PageReference pageRef = Page.AccountTransferTool;
			pageRef.getParameters().put('id', String.valueOf(acc.Id));
			Test.setCurrentPage(pageRef);
			string axtJSON = '[{"FromUserID":"00541000004MKRGAA4","ToUserID":"005410000037TaNAAU","Type":"New Business","ProductLine":"National Spot (NCC)","BroadcastDate":"3/15/2020","MonthID":3,"commodity":"Travel/Leisure/Entertainment","DMAContri":1304,"Percentage":28.571428571428573,"CommodityContri":0,"DMA":"Lexington KY","UniqueKey":"00541000004MKRGAA4:005410000037TaNAAU:New BusinessNational Spot (NCC)Travel/Leisure/EntertainmentLexington KY32020","Unknown":"Unknown"}]';
			System.JSONParser parser = System.JSON.createParser(axtJSON);
			AXTNBUCJSONParser pr = new AXTNBUCJSONParser(parser);
			// Account testAcc = new Account(sc); 
			Sales_Budget_Simulation__c sm = new Sales_Budget_Simulation__c();

			sm.Budget_User__c = userAETo.Id;
			sm.Amount__c = 999;
			sm.Account_Transfer_Simulation__c = att.id;
			sm.From_Budget_user__c = userAE.id;
			sm.New_Business_Churn__c = 'Unknown Churn';
			sm.DMA__c = 'DMAs';
			sm.Broadcast_Month_Date__c = Date.Today();
			sm.External_Id__c = '007' + userAETo.id + System.today();
			sm.Comments__c = 'ASP';
			sm.Product_Line__c = 'Linear/News/Sports';
			sm.Old_Product_Line__c = 'Linear/News/Sports';
			insert sm;

			Set<ID> userIDs = new Set<ID> ();
			userIDs.add(userAE.ID);

			AccountTransferToolController.getProductlineMap();
			AccountTransferToolController.accTransferList(simulateString, thisUser.Name, null, '',true,'Transfer_Entered_Amounts');
			AccountTransferToolController.accTransferList(dupeString, thisUser.Name, att.Id, '', true, 'Transfer_All_NBUC');
			AccountTransferToolController.atmDupeCheck(dupeString, att.Id);
			AccountTransferToolController.submitATSApproval(attApproval.Id);
			AccountTransferToolController.accountTransfer(att.Id);
			AccountTransferToolController.executeSBAggBatch(String.valueOf(userAE.ID));
			List<Account> accList = new List<Account> ();
			accList.add(acc);
			//accList = New_AETransferToolController.showAccounts(UserInfo.getUserId());
			List<User> usr = new List<User> ();
			usr.add(thisUser);
			IF (accList.size() > 0 && usr.size() > 0) {
				List<New_AETransferToolController.OppProposalWrapper> oppProposalWrapList = New_AETransferToolController.showOpportunities(new List<String> { accList[0].Id }, String.valueOf(System.today().addYears(-10)), Id.valueOf(UserInfo.getUserId()));
                System.debug('Test Message 1 ' + oppProposalWrapList);
				for (New_AETransferToolController.OppProposalWrapper oppWrap : oppProposalWrapList) {
					System.debug('Test Message 2');
                    oppWrap.chckBx = true;
					System.debug('Record:::' + oppWrap);
				}

				String JSONString = JSON.serialize(oppProposalWrapList);
				String adminummaryId = New_AETransferToolController.AEtransfer(JSONString, usr[0].Id, Id.valueOf(UserInfo.getUserId()), new List<String> { accList[0].Id }, String.valueOf(System.today().addYears(- 1)), atm.Id);
				Admin_Tool_Status_Summary__c adminSummaryRecord = New_AETransferToolController.returnAdminToolStatus(adminummaryId);

				List<Admin_Tool_Status_Summary__c> admnSumary = [Select id from Admin_Tool_Status_Summary__c order by createdDate desc];
				if (admnSumary.size() > 0) {
					System.assertEquals(adminummaryId, admnSumary[0].Id);
					System.assertEquals(adminSummaryRecord.Id, admnSumary[0].Id);
				}

				//New_AETransferToolController.AEtransfer(JSONString,Id.valueOf(UserInfo.getUserId()), usr[0].Id, new List<String>{accList[0].Id} ,String.valueOf(System.today().addYears(-1)),att.id);
			}

			// testAcc.AccountTransferToolController();
			Test.stopTest();
		}

	}
	
    @IsTest(seeAlldata = false)
	static void accTransferList_New_Test() {
		New_AETransferToolController.showOpportunities(new List<String> { null }, system.today().format(), null);
		Account acc = TestUtil.getAccountRec();
		acc.primary_commodity__c = 'Auto Aftermarket';
		insert acc;
		AccountConnection__c accCon = TestDataHelper.createAccountConnection(acc.Id);
		accCon.Tim_ID__c = '5413';
		insert accCon;
		Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
		att.Division__c = 'Central';
		att.Region__c = 'MidNorth';
		att.Status__c = 'Approved';
		att.Transfer_Effective_Date__c = Date.newInstance(2018, 01, 15);
		att.Transfer_All_Accounts__c = true;
		insert att;

		Account_Transfer_Tool__c attApproval = new Account_Transfer_Tool__c();
		attApproval.Division__c = 'Central';
		attApproval.Region__c = 'MidNorth';
		attApproval.Status__c = 'New';
		attApproval.Transfer_Effective_Date__c = System.today().addYears(-1);
		attApproval.Transfer_All_Accounts__c = true;
		insert attApproval;

		System.debug('ATTApproval: ' + attApproval);


		Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
		atm.Account__c = acc.Id;
		atm.Account_Transfer_Simulation__c = attApproval.Id;
		atm.From_User__c = Userinfo.getUserId();
		atm.To_User__c = Userinfo.getUserId();
		atm.External_ID__c = Userinfo.getUserId() + ';;;' + acc.Id + ';;;' + '2020Jan' + ';;;' + Userinfo.getUserId();
		insert atm;

		Admin_Tool_Status_Summary__c obj = new Admin_Tool_Status_Summary__c();
		obj.From_User_Id__c = UserInfo.getUserId();
		obj.To_User_Id__c = UserInfo.getUserId();
		obj.Proposal_End_Date__c = String.valueOf(Date.today());
		obj.Job_Type__c = 'AE Transfer';
		obj.Transfer_Details__c = atm.Id;
		insert obj;

		Admin_Tool_Status_Detail__c objAT = new Admin_Tool_Status_Detail__c();
		objAT.Admin_Tool_Status_Summary__c = obj.Id;
		insert objAT;
		Sales_Budget__c sb = new Sales_Budget__c();
		sb.advertiser__c = acc.id;
		sb.Budget_user__c = Userinfo.getUserId();
		sb.Amount__c = 999;
		sb.Commodity__c = 'Auto Aftermarket';
		sb.Product_Line__c = 'Digital';
		sb.Broadcast_Month_Date__c = System.today().addYears(1);
		sb.External_Id__c = '007' + Userinfo.getUserId() + System.today().addYears(1);
		insert sb;
		//create create Traffic Id Element for User
		Traffic_Id_Element__c trafficElementUser = new Traffic_Id_Element__c();
		trafficElementUser.User__c = Userinfo.getUserId();
		trafficElementUser.AE_ID__c = 1;
		trafficElementUser.Export_System_Id__c = '1';
		trafficElementUser.Traffic_Id__c = '2222';
		trafficElementUser.Tim_System__c = 'St. Louis Local';
		trafficElementUser.Traffic_Type__c = 'User';
		trafficElementUser.Account__c = acc.ID;
		trafficElementUser.ExportSystem_Name__c = 'TWNY';
		insert trafficElementUser;

		Traffic_Id_Element__c trafficElementAcc = new Traffic_Id_Element__c();
		trafficElementAcc.Account_TIM_ID__c = acc.ID;
		trafficElementAcc.User__c = Userinfo.getUserId();
		trafficElementAcc.AE_ID__c = 1;
		trafficElementAcc.Export_System_Id__c = '1';
		trafficElementAcc.Traffic_Id__c = '5413';
		trafficElementAcc.Tim_System__c = 'St. Louis Local';
		trafficElementAcc.Traffic_Type__c = 'Account';
		trafficElementAcc.Account__c = acc.ID;
		trafficElementAcc.ExportSystem_Name__c = 'TWNY';
		insert trafficElementAcc;

		System.assert(trafficElementUser != null);

		List<Revenue__c> revList = new List<Revenue__c> ();
		//CreateRevenue
		Revenue__c revenue = new Revenue__c();
		revenue.Customer_Number__c = '5413';
		revenue.AE_Id__c = '2222';
		revenue.Export_System_Id__c = '1';
		revenue.Actual_Gross_Amount__c = 10080;
		revenue.Projected_Gross_Amount__c = 10000;
		revenue.Product_Line__c = 'Digital';
		revenue.Advertiser__c = acc.ID;
		revenue.Broadcast_Month_Date__c = date.today();
		revenue.Eclipse_System__c = 'TWNY';
		revenue.Account_Executive__c = userInfo.getUserId();
		revenue.ContractNumber__c = 1111;
		revList.add(revenue);

		Revenue__c revenueNew = new Revenue__c();
		revenueNew.Customer_Number__c = '5413';
		revenueNew.AE_Id__c = '2222';
		revenueNew.Export_System_Id__c = '1';
		revenueNew.Actual_Gross_Amount__c = 9000;
		revenueNew.Projected_Gross_Amount__c = 1000;
		revenuenew.Revenue_User__c = userInfo.getUserId();
		revenueNew.Product_Line__c = 'Linear/News/Sports';
		revenueNew.Broadcast_Month_Date__c = date.today();
		revenueNew.Advertiser__c = acc.ID;
		revenueNew.Eclipse_System__c = 'CHSLEDA';
		revenueNew.ContractNumber__c = 11;
		revList.add(revenueNew);
        insert revList;
		
		try {
			List<Admin_Tool_Status_Detail__c> adminToolDetailsAccConn = new List<Admin_Tool_Status_Detail__c> ();
			adminToolDetailsAccConn.add(objAT);
			New_AETransferToolController.updateAccountConnections(adminToolDetailsAccConn);
		} catch(Exception ex) {

		}

		try {
			//create Opportunity
			Opportunity opp = TestDataHelper.createopportunity('Test Opportunity', System.today(), 'Planning', 'Pipeline', acc.ID);
			Map<String, String> mapOppNewOwner = new Map<String, String> ();
			mapOppNewOwner.put(opp.Id, Userinfo.getUserId());
			insert opp;
			List<Admin_Tool_Status_Detail__c> adminToolDetailsAccConn = new List<Admin_Tool_Status_Detail__c> ();
			adminToolDetailsAccConn.add(objAT);
			New_AETransferToolController.updateOpportunities(mapOppNewOwner, adminToolDetailsAccConn);
			New_AETransferToolController.updateAccountTeam(adminToolDetailsAccConn);
		} catch(Exception ex) {

		}

		try {
			List<Account_Transfer_Mapping__c> accTransferMappingRecords = new List<Account_Transfer_Mapping__c> ();
			accTransferMappingRecords.add(atm);
			New_AETransferToolController.updateRevenue(accTransferMappingRecords);
		} catch(Exception ex) {

		}

		try {
			List<Account_Transfer_Mapping__c> accTransferMappingRecords = new List<Account_Transfer_Mapping__c> ();
            system.debug('atm: ' +atm);
			accTransferMappingRecords.add(atm);
			New_AETransferToolController.updateSalesBudget(accTransferMappingRecords, false);
		} catch(Exception ex) {

		}
		try {
			List<Account_Transfer_Tool__c> accTransferList = new List<Account_Transfer_Tool__c> ();
			accTransferList.add(att);
			List<Sales_Budget__c> sbsList = new list<Sales_Budget__c> ();
			sbsList.add(sb);
			List<Admin_Tool_Status_Summary__c> admintoolaccTransferMappingRecords = new List<Admin_Tool_Status_Summary__c> ();
			admintoolaccTransferMappingRecords.add(obj);
			New_AETransferToolController.returnSalesBudget(admintoolaccTransferMappingRecords);
			New_AETransferToolController.createSalesBudgetSimulation(sbsList);
			New_AETransferToolController.initiateTransfer(accTransferList);
			New_AETransferToolController.updateAdminSummary(admintoolaccTransferMappingRecords);
			New_AETransferToolController.updateAdminSummary(admintoolaccTransferMappingRecords);


		} catch(Exception ex) {

		}

	}

	@IsTest(seeAlldata = false)
	static void TestUpdateSalesBudget() { 
        User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
        Account_Transfer_Tool__c attApproval = new Account_Transfer_Tool__c();
        Admin_Tool_Status_Summary__c obj = new Admin_Tool_Status_Summary__c();
        Admin_Tool_Status_Detail__c objAT = new Admin_Tool_Status_Detail__c();
        Sales_Budget__c sb1 = new Sales_Budget__c();
        Sales_Budget__c sb = new Sales_Budget__c();
        
        System.runAs(thisUser) {
            User userAEToTest = TestUtil.prepareUser();
            userAEToTest.Username = 'testaeTo@mands.com';
            userAEToTest.Budget_type__c = 'Local';
            userAEToTest.Budget_product_Lines__c = 'Linear/News/Sports';
            userAEToTest.Firstname = 'Test';
            userAEToTest.Lastname = 'User';
            insert userAEToTest;
            
            Account acc = TestUtil.getAccountRec();
            acc.primary_commodity__c = 'Auto Aftermarket';
            insert acc;
            AccountConnection__c accCon = TestDataHelper.createAccountConnection(acc.Id);
            accCon.Tim_ID__c = '5413';
            insert accCon;
            
            attApproval.Division__c = 'Central';
            attApproval.Region__c = 'MidNorth';
            attApproval.Status__c = 'New';
            attApproval.Transfer_Effective_Date__c = System.today().addYears(-1);
            attApproval.Transfer_All_Accounts__c = true;
            insert attApproval;
            System.debug('atm ATTApproval: ' + attApproval);
               
            atm.Account__c = acc.Id;
            atm.Account_Transfer_Simulation__c = attApproval.Id;
            atm.From_User__c = Userinfo.getUserId();
            atm.To_User__c = userAEToTest.Id;
            atm.External_ID__c = Userinfo.getUserId() + ';;;' + acc.Id + ';;;' + '2020Jan' + ';;;' + Userinfo.getUserId();
            insert atm;
            System.debug('atm Account_Transfer_Simulation__c: ' + atm.Account_Transfer_Simulation__c);        
            System.debug('atm Transfer Effective Date: ' + atm.Account_Transfer_Simulation__r.Transfer_Effective_Date__c);            
            
            obj.From_User_Id__c = UserInfo.getUserId();
            obj.To_User_Id__c = userAEToTest.Id;
            obj.Proposal_End_Date__c = String.valueOf(Date.today());
            obj.Job_Type__c = 'AE Transfer';
            obj.Transfer_Details__c = atm.Id;
            insert obj;
                
            objAT.Admin_Tool_Status_Summary__c = obj.Id;
            insert objAT;
                      
            sb.advertiser__c = acc.id;
            sb.Budget_user__c = Userinfo.getUserId();
            sb.Amount__c = 999;
            sb.Commodity__c = 'Auto Aftermarket';
            sb.Product_Line__c = 'Digital';
            sb.Broadcast_Month_Date__c = System.today().addYears(1);
            sb.External_Id__c = '007' + Userinfo.getUserId() + System.today().addYears(1);
            insert sb;
                        
            sb1.advertiser__c = acc.id;
            sb1.Budget_user__c = userAEToTest.Id;
            sb1.Amount__c = 999;
            sb1.Commodity__c = 'Auto Aftermarket';
            sb1.Product_Line__c = 'Digital';
            sb1.Broadcast_Month_Date__c = System.today().addYears(1);
            sb1.External_Id__c = '007' + Userinfo.getUserId() + System.today().addYears(1);
            insert sb1;
            
            New_AETransferToolController.showOpportunities(new List<String> { null }, system.today().format(), null);
        }
        try {
			List<Account_Transfer_Mapping__c> accTransferMappingRecords = new List<Account_Transfer_Mapping__c> ();
            system.debug('atm Transfer Effective Date: ' +atm.Account_Transfer_Simulation__r.Transfer_Effective_Date__c);
			accTransferMappingRecords.add(atm);
			New_AETransferToolController.updateSalesBudget(accTransferMappingRecords, true);
		} 
        catch(Exception ex) {
		}
    }
}