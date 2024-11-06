@isTest
public with sharing class BudgetingToolControllerTest {

	@IsTest(seeAlldata = false)
	static void AEViewTest() {

		ApexPages.currentPage().getParameters().put('selectedPCom', 'Auto Aftermarket');


		//create AE User
		User userAE = TestUtil.prepareUser();
		Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Master - Account Executive'];
		userAE.ProfileId = objProfile.Id;
		userAE.Username = 'testae@mands.com';
		userAE.budget_type__c = 'Local';
		userAE.budget_product_Lines__c = 'Linear/News/Sports';
		userAE.Division__c = 'South';
		userAE.Budget_DMA__c = 'St Louis MO';
		insert userAE;
		Sales_Budget__c sb = new Sales_Budget__c();
		//Sales_Budget__c sbm = new Sales_Budget__c();
		Sales_Budget__c sbForecast = new Sales_Budget__c();
		Sales_Budget__c sbw = new Sales_Budget__c();
		Sales_Budget__c sbf = new Sales_Budget__c();
		Sales_Budget__c sbr = new Sales_Budget__c();


		system.debug(userAE);
		//Execute test as AE User
		System.runAs(userAE) {
			List<Account> accList = new List<Account> ();

			//create Advertiser
			Account acc = TestUtil.getAccountRec();
			acc.primary_commodity__c = 'Auto Aftermarket';
			accList.add(acc);

			Account accForecast = TestUtil.getAccountRec();
			acc.primary_commodity__c = 'Alcoholic Beverages';
			accList.add(accForecast);

			Account objAcc = new Account();
			objAcc.Name = 'New Business/Churn';
			objAcc.BillingStreet = 'Valley1';
			objAcc.BillingCity = 'dallas1';
			objAcc.BillingState = 'TX';
			objAcc.BillingCountry = 'us';
			objAcc.BillingPostalCode = '75433';
			accList.add(objAcc);
			insert accList;

			//create PY Sales Revenue
			List<Revenue__c> srlist = new list<Revenue__c> ();
			Revenue__c pyRev = TestUtil.getRevenueRec(userAE, acc, System.today().addYears(- 1));
			pyRev.Product_Line__c = 'Linear/News/Sports';
			srlist.add(pyRev);


			//create CY Sales Revenue
			Revenue__c sr = TestUtil.getRevenueRec(userAE, acc, System.today());
			sr.Product_Line__c = 'Linear/News/Sports';
			srlist.add(sr);
            
            //create NY Sales Revenue
			Revenue__c nYRev = TestUtil.getRevenueRec(userAE, acc, System.today().addYears(+ 1));
			nYRev.Product_Line__c = 'Linear/News/Sports';
			srlist.add(nYRev);

			insert srlist;
			//system.debug(sr);

			//create Sales Budget
			List<Sales_Budget__c> sbList = new List<Sales_Budget__c> ();
			sb = TestUtil.getSalesBudgetRec(userAE, objAcc);
			sb.Product_Line__c = 'Linear/News/Sports';
			sb.Type__c = 'Data';
			//sb.Advertiser__r.Name='New Business';
			sb.Broadcast_Month_Date__c = Date.newInstance(2020, 12, 15);
			sbList.add(sb);
			//insert sb;

			sbForecast = TestUtil.getSalesBudgetRec(userAE, accForecast);
			sb.Product_Line__c = 'Linear/News/Sports';
			sb.Type__c = 'Workflow';
			sb.Broadcast_Month_Date__c = Date.newInstance(2020, 12, 15);
			sbList.add(sbForecast);

			sbw = TestUtil.getSalesBudgetRec(userAE, acc);
			sbw.Type__c = 'Workflow';
			sbw.Status__c = 'Submitted';
			// insert sbw;

			sbf = TestUtil.getSalesBudgetRec(userAE, acc);
			sbf.Type__c = 'Forecast';
			sbf.CY_FCST_1_Jan_Amount__c = 0;
			sbf.CY_FCST_2_Feb_Amount__c = 1;
			sbf.CY_FCST_3_March_Amount__c = 4;
			sbf.CY_FCST_4_April_Amount__c = 5;
			sbf.CY_FCST_5_May_Amount__c = 4;
			sbf.CY_FCST_6_June_Amount__c = 4;
			sbf.CY_FCST_7_July_Amount__c = 5;
			sbf.CY_FCST_8_Aug_Amount__c = 5;
			sbf.CY_FCST_9_Sep_Amount__c = 6;
			sbf.CY_FCST_10_Oct_Amount__c = 5;
			sbf.CY_FCST_11_Nov_Amount__c = 2;
			sbf.CY_FCST_12_Dec_Amount__c = 1;
			sbf.PY_Rev_1_Jan_Amount__c = 1;
			sbf.PY_Rev_2_Feb_Amount__c = 6;
			sbf.PY_Rev_3_March_Amount__c = 4;
			sbf.PY_Rev_4_April_Amount__c = 4;
			sbf.PY_Rev_5_May_Amount__c = 6;
			sbf.PY_Rev_6_June_Amount__c = 7;
			sbf.PY_Rev_7_July_Amount__c = 9;
			sbf.PY_Rev_8_Aug_Amount__c = 5;
			sbf.PY_Rev_9_Sep_Amount__c = 6;
			sbf.PY_Rev_10_Oct_Amount__c = 3;
			sbf.PY_Rev_11_Nov_Amount__c = 4;
			sbf.PY_Rev_12_Dec_Amount__c = 7;
			sbf.CY_Rev_1_Jan_Amount__c = 6;
			sbf.CY_Rev_2_Feb_Amount__c = 4;
			sbf.CY_Rev_3_March_Amount__c = 2;
			sbf.CY_Rev_4_April_Amount__c = 1;
			sbf.CY_Rev_5_May_Amount__c = 1;
			sbf.CY_Rev_6_June_Amount__c = 3;
			sbf.CY_Rev_7_July_Amount__c = 2;
			sbf.CY_Rev_8_Aug_Amount__c = 0;
			sbf.CY_Rev_9_Sep_Amount__c = 4;
			sbf.CY_Rev_10_Oct_Amount__c = 6;
			sbf.CY_Rev_11_Nov_Amount__c = 7;
			sbf.CY_Rev_12_Dec_Amount__c = 6;

			sbf.Product_Line__c = 'Linear/News/Sports';
			sbf.Broadcast_Month_Date__c = Date.newInstance(2020, 12, 15);
			//sbf.Status__c = 'Submitted';
			sbList.add(sbf);

			
			insert sbList;

			//Create User Connection
			insert TestDataHelper.createUserConnection('St. Louis Local', 'SFDCUser', userAE.id, 'TIM', '1');

			//create Opportunity
			Opportunity opp = TestDataHelper.createopportunity('Test Opportunity', System.today(), 'Planning', 'Pipeline', acc.ID);
			insert opp;

			//create Proposal
			Proposal__c p = TestDataHelper.createProposal('Test Opportunity Proposal', opp.id, '00000', true);
			p.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
			p.Start_Date__c = System.today();
			p.End_Date__c = System.today().addMonths(1);
			insert p;

			//Create SysCode
			Syscode__c sys = TestDataHelper.createSysCode(false);
			insert sys;
			//create Proposal Zone
			Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Proposal Zone', p.Id);
			propZone.Sys_Code__c = '9999';
			insert propZone;


			//create Proposal Zone Monthly Value
			Proposal_Zone_Monthly_Value__c propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value', acc.Id, propZone.Id);
			propZoneMonthly.Schedule_Type__c = 'Linear';
			propZoneMonthly.Proposal_Key_Index__c = p.Id;
			propZoneMonthly.Broadcast_Month_Date__c = Date.newInstance(Integer.valueOf(Label.BudgetForecastCurrentYear), 1, 15);
			insert propZoneMonthly;

			Test.startTest();
			System.debug('AEViewTest');
			BudgetingToolController btc = new BudgetingToolController();

			//PageReference pre=btc.submitForecast();
			String sep = BudgetingToolController.keySeparator;
			btc.JSONOutput = '{"IO":{},"Changes":[{"id":"AR1$AR2$AR3$' + sep + 'Auto Aftermarket' + sep + acc.id + sep + 'Advanced Advertising' + sep + '2017","Changed":1,"Feb":"2","Mar":"3","Apr":"4","May":"5","Jun":"6","Jul":"7","Aug":"8","Sep":"9","Oct":"1","Nov":"2","Dec":"3"}]}';
			btc.saveGridData();
			btc.queryNSMTreeData();
			btc.updateBudgetInstance('999', sbf.id, 'Out of Business');

			String LedName = '2017 OTB';
			List<Integer> months = new List<Integer> { 0, 4000, 6000, 8000, 4000, 2000, 6000, 10000, 5000, 4000, 8000, 9000 };
			String formula = ''; String id = '';
			BudgetingToolModel.Items_Led tgmiLed = new BudgetingToolModel.Items_Led();
			tgmiLed.id = id;
			tgmiLed.Account = LedName;
			tgmiLed.Jan = months[0];
			tgmiLed.Feb = months[1];
			tgmiLed.Mar = months[2];
			tgmiLed.Apr = months[3];
			tgmiLed.May = months[4];
			tgmiLed.Jun = months[5];
			tgmiLed.Jul = months[6];
			tgmiLed.Aug = months[7];
			tgmiLed.Sep = months[8];
			tgmiLed.Oct = months[9];
			tgmiLed.Nov = months[10];
			tgmiLed.Dec = months[11];

			BudgetingToolController.showSelectedDMA('test');
			BudgetingToolController.submitBudget(sb.Id, 'comments', userAE.id);
			BudgetingToolController.submitForecast(sbForecast.Id, 'comments', userAE.id);
			BudgetingToolController.approveBudget(sb.Id, 'comments');
			BudgetingToolController.approveForecast(sb.Id, 'comments');
			BudgetingToolController.rejectBudget(sb.Id, 'comments');
			BudgetingToolController.rejectForecast(sb.Id, 'comments');
			btc.saveSumRollupSelection();

			try {
				BudgetingToolController.submitForecast('', 'comments', userAE.id);
			} catch(Exception ex) { }
			BudgetingToolController.sbWorkflowId = '';
			Test.stopTest();
		}
	}

	@IsTest(seeAlldata = false)
	static void AEViewTest_NewBusiness() {

		//create AE User
		User userAE = TestUtil.prepareUser();
		Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Master - Account Executive'];
		userAE.ProfileId = objProfile.Id;
		userAE.Username = 'testae@mands.com';
		userAE.budget_type__c = 'Local';
		userAE.budget_product_Lines__c = 'Linear/News/Sports;Digital;Production;';
		userAE.Division__c = 'South';
		userAE.Budget_DMA__c = 'Albany NY';
		insert userAE;
		Sales_Budget__c sb = new Sales_Budget__c();
		Sales_Budget__c sb1 = new Sales_Budget__c();
		Sales_Budget__c sbw = new Sales_Budget__c();

		system.debug(userAE);
		//Execute test as AE User
		System.runAs(userAE) {

			//create Advertiser
			Account acc = TestUtil.getAccountRec();
			acc.Name = 'New Business/Churn';
			acc.primary_commodity__c = 'Auto Aftermarket';
			insert acc;

			Account acc1 = TestUtil.getAccountRec();
			acc1.Name = 'Test Account Name';
			acc1.primary_commodity__c = 'Auto Aftermarket';
			insert acc1;

			//create PY Sales Revenue
			insert TestUtil.getRevenueRec(userAE, acc, System.today().addYears(- 1));

			//create CY Sales Revenue
			insert TestUtil.getRevenueRec(userAE, acc, System.today());

			//create Sales Budget
			sb = TestUtil.getSalesBudgetRec(userAE, acc);
			sb.Type__c = 'Data';
			sb.DMA__c = 'St Louis MO';
			sb.Product_Line__c = 'Linear/News/Sports';
			insert sb;

			sb1 = TestUtil.getSalesBudgetRec(userAE, acc1);
			sb1.Type__c = 'Data';
			sb1.DMA__c = 'St Louis MO';
			sb1.Product_Line__c = 'Linear/News/Sports';
			insert sb1;

			sbw = TestUtil.getSalesBudgetRec(userAE, acc);
			sbw.Type__c = 'Workflow';
			sbw.Broadcast_Month_Date__c = Date.newInstance(2020, 12, 15);
			sbw.Status__c = 'Submitted';
			insert sbw;

			//Create User Connection
			insert TestDataHelper.createUserConnection('St. Louis Local', 'SFDCUser', userAE.id, 'TIM', '1');

			//create Opportunity
			Opportunity opp = TestDataHelper.createopportunity('Test Opportunity', System.today(), 'Planning', 'Pipeline', acc.ID);
			insert opp;

			//create Proposal
			Proposal__c p = TestDataHelper.createProposal('Test Opportunity Proposal', opp.id, '00000', true);
			p.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
			p.Start_Date__c = System.today();
			p.End_Date__c = System.today().addMonths(1);
			insert p;

			//Create SysCode
			Syscode__c sys = TestDataHelper.createSysCode(false);
			insert sys;
			//create Proposal Zone
			Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Proposal Zone', p.Id);
			propZone.Sys_Code__c = '9999';
			insert propZone;

			//create Proposal Zone Monthly Value
			Proposal_Zone_Monthly_Value__c propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value', acc.Id, propZone.Id);
			propZoneMonthly.Schedule_Type__c = 'Linear';
			propZoneMonthly.Proposal_Key_Index__c = p.Id;
			propZoneMonthly.Broadcast_Month_Date__c = System.today().addMonths(1);
			insert propZoneMonthly;

			List<SyscodeProductLineMap__c> custSettlist = new list<SyscodeProductLineMap__c> ();

			SyscodeProductLineMap__c sysprod = new SyscodeProductLineMap__c();
			sysprod.Product_Line__c = 'National Spot (NCC)';
			sysprod.Name = 'Test sys';
			custSettlist.add(sysprod);
			insert custSettlist;

			Map<String, SyscodeProductLineMap__c> custSettmap = new map<String, SyscodeProductLineMap__c> ();
			custSettmap.putAll(custSettlist);

			Test.startTest();
			System.debug('AEViewTest');
			BudgetingToolController btc = new BudgetingToolController();
			String sep = BudgetingToolController.keySeparator;
			btc.JSONOutput = '{"IO":{},"Changes":[{"id":"AR1$AR2$AR3$' + sep + 'Auto Aftermarket' + sep + acc.id + sep + 'Advanced Advertising' + sep + '2017","Changed":1,"Feb":"2","Mar":"3","Apr":"4","May":"5","Jun":"6","Jul":"7","Aug":"8","Sep":"9","Oct":"1","Nov":"2","Dec":"3"}]}';
			btc.saveGridData();

			String LedName = '2017 OTB';
			List<Integer> months = new List<Integer> { 0, 4000, 6000, 8000, 4000, 2000, 6000, 10000, 5000, 4000, 8000, 9000 };
			String formula = ''; String id = '';
			BudgetingToolModel.Items_Led tgmiLed = new BudgetingToolModel.Items_Led();
			tgmiLed.id = id;
			tgmiLed.Account = LedName;
			tgmiLed.Jan = months[0];
			tgmiLed.Feb = months[1];
			tgmiLed.Mar = months[2];
			tgmiLed.Apr = months[3];
			tgmiLed.May = months[4];
			tgmiLed.Jun = months[5];
			tgmiLed.Jul = months[6];
			tgmiLed.Aug = months[7];
			tgmiLed.Sep = months[8];
			tgmiLed.Oct = months[9];
			tgmiLed.Nov = months[10];
			tgmiLed.Dec = months[11];

			/*tgmiLed.JanFormula = tgmiLed.FebFormula = tgmiLed.MarFormula = tgmiLed.AprFormula = tgmiLed.MayFormula = tgmiLed.JunFormula = tgmiLed.JulFormula = tgmiLed.AugFormula = tgmiLed.SepFormula = tgmiLed.OctFormula = tgmiLed.NovFormula = tgmiLed.DecFormula = formula;
			  if(LedName =='18YOY%' || LedName =='19YOY%') {
			  String GetYOYStr = 'Grids.GetYOY(Grid, Row, Col)';
			  tgmiLed.JanFormula = tgmiLed.FebFormula = tgmiLed.MarFormula = tgmiLed.AprFormula = tgmiLed.MayFormula = tgmiLed.JunFormula =  GetYOYStr;
			  tgmiLed.JulFormula = tgmiLed.AugFormula = tgmiLed.SepFormula = tgmiLed.OctFormula = tgmiLed.NovFormula = tgmiLed.DecFormula = GetYOYStr;
			  tgmiLed.Q1Formula = tgmiLed.Q2Formula = tgmiLed.Q3Formula = tgmiLed.Q4Formula = tgmiLed.TotalFormula = GetYOYStr;
			  //   tgmiLed.Calculated = '1';
			  }*/
			BudgetingToolController.sbWorkflowId = sbw.Id;
			btc.submitForecast();
			BudgetingToolController.sbWorkflowId = '';
			try {
				btc.submitForecast();
			} catch(Exception ex) { }
			BudgetingToolController.showSelectedDMA('test');
			//BudgetingToolController.createNationalForecastInstance('St Louis MO', '999', 4, sb.id, 'Out of Business', userAE.id);
			//BudgetingToolController.createNationalForecastInstance();
			//tgmiLed.format('c');
			//tgmiLed.format('p');
			/*tgmiLed.SetReadOnly(1); 
			  tgmiLed.SetReadOnly(0);*/

			Test.stopTest();
		}
	}

	@IsTest(seeAlldata = false)
	static void NSMViewTest_NewBusiness() {

		//create National User
		User userNational = TestUtil.prepareUser();
		Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Master - National Sales Manager'];
		userNational.ProfileId = objProfile.Id;
		userNational.Username = 'testNational@mands.com';
		userNational.budget_type__c = 'National';
		userNational.budget_product_Lines__c = 'National Spot (NCC); National Direct Spot; National Digital (NCC); National Direct Digital';
		userNational.budget_dma__c = 'St Louis MO;Wilmington NC;Youngstown OH';
		userNational.Division__c = 'South';
		//userNational.Budget_DMA__c = 'Albany NY';
		insert userNational;
		Sales_Budget__c sb = new Sales_Budget__c();
		Sales_Budget__c sbw = new Sales_Budget__c();
		Sales_Budget__c sbf = new Sales_Budget__c();
		//Execute test as National User
		System.runAs(userNational) {

			//create Advertiser
			Account acc = TestUtil.getAccountRec();
			acc.Name = 'New Business/Churn';
			acc.Primary_Commodity__c = 'Auto Aftermarket';
			insert acc;




			//create Account Team member
			insert TestUtil.getAccountTeamMemRec(acc.Id, userNational.Id);


			//create PY Sales Revenue
			insert TestUtil.getRevenueRec(userNational, acc, System.today().addYears(- 1));

			//create CY Sales Revenue
			insert TestUtil.getRevenueRec(userNational, acc, System.today());

			//create Sales Budget
			sb = TestUtil.getSalesBudgetRec(userNational, acc);
			sb.Type__c = 'Data';
			sb.DMA__c = 'St Louis MO';
			insert sb;

			sbw = TestUtil.getSalesBudgetRec(userNational, acc);
			sbw.Type__c = 'Workflow';
			sbw.Status__c = 'Submitted';
			sb.DMA__c = 'St Louis MO';
			insert sbw;

			sbf = TestUtil.getSalesBudgetRec(userNational, acc);
			sbf.Type__c = 'Forecast';
			sbf.CY_FCST_1_Jan_Amount__c = 0;
			sbf.CY_FCST_2_Feb_Amount__c = 1;
			sbf.CY_FCST_3_March_Amount__c = 4;
			sbf.CY_FCST_4_April_Amount__c = 5;
			sbf.CY_FCST_5_May_Amount__c = 4;
			sbf.CY_FCST_6_June_Amount__c = 4;
			sbf.CY_FCST_7_July_Amount__c = 5;
			sbf.CY_FCST_8_Aug_Amount__c = 5;
			sbf.CY_FCST_9_Sep_Amount__c = 6;
			sbf.CY_FCST_10_Oct_Amount__c = 5;
			sbf.CY_FCST_11_Nov_Amount__c = 2;
			sbf.CY_FCST_12_Dec_Amount__c = 1;
			sbf.PY_Rev_1_Jan_Amount__c = 1;
			sbf.PY_Rev_2_Feb_Amount__c = 6;
			sbf.PY_Rev_3_March_Amount__c = 4;
			sbf.PY_Rev_4_April_Amount__c = 4;
			sbf.PY_Rev_5_May_Amount__c = 6;
			sbf.PY_Rev_6_June_Amount__c = 7;
			sbf.PY_Rev_7_July_Amount__c = 9;
			sbf.PY_Rev_8_Aug_Amount__c = 5;
			sbf.PY_Rev_9_Sep_Amount__c = 6;
			sbf.PY_Rev_10_Oct_Amount__c = 3;
			sbf.PY_Rev_11_Nov_Amount__c = 4;
			sbf.PY_Rev_12_Dec_Amount__c = 7;
			sbf.CY_Rev_1_Jan_Amount__c = 6;
			sbf.CY_Rev_2_Feb_Amount__c = 4;
			sbf.CY_Rev_3_March_Amount__c = 2;
			sbf.CY_Rev_4_April_Amount__c = 1;
			sbf.CY_Rev_5_May_Amount__c = 1;
			sbf.CY_Rev_6_June_Amount__c = 3;
			sbf.CY_Rev_7_July_Amount__c = 2;
			sbf.CY_Rev_8_Aug_Amount__c = 0;
			sbf.CY_Rev_9_Sep_Amount__c = 4;
			sbf.CY_Rev_10_Oct_Amount__c = 6;
			sbf.CY_Rev_11_Nov_Amount__c = 7;
			sbf.CY_Rev_12_Dec_Amount__c = 6;

			sbf.DMA__c = 'St Louis MO';
			sbw.Broadcast_Month_Date__c = System.today();
			//sbf.Status__c = 'Submitted';
			insert sbf;
			//System.debug('SB TYPE: '+ sb.Type__c);

			//Create User Connection
			insert TestDataHelper.createUserConnection('St. Louis Local', 'SFDCUser', userNational.id, 'TIM', '1');

			//create Opportunity
			Opportunity opp = TestDataHelper.createopportunity('Test Opportunity', System.today(), 'Planning', 'Pipeline', acc.ID);
			insert opp;

			//create Proposal
			Proposal__c p = TestDataHelper.createProposal('Test Opportunity Proposal', opp.id, '00000', true);
			p.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
			p.Start_Date__c = System.today();
			p.End_Date__c = System.today().addMonths(1);
			insert p;
			//Create SysCode
			Syscode__c sys = TestDataHelper.createSysCode(false);
			insert sys;
			//create Proposal Zone
			Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Proposal Zone', p.Id);
			insert propZone;

			//create Proposal Zone Monthly Value
			Proposal_Zone_Monthly_Value__c propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value', acc.Id, propZone.Id);
			propZoneMonthly.Schedule_Type__c = 'Linear';
			propZoneMonthly.Proposal_Key_Index__c = p.Id;
			propZoneMonthly.Broadcast_Month_Date__c = System.today().adddays(1);
			propZoneMonthly.Advertiser__c = acc.Id;
			propZoneMonthly.sys_code__c = '9999';
			insert propZoneMonthly;

			Test.startTest();
			BudgetingToolController btc = new BudgetingToolController();
			System.debug('CY3: ' + btc.loggedInUser.id + ',' + btc.loggedInUserProductLines + ',' + Label.RevenueCY);
			System.debug('CY4: ' + userNational.id + ',' + userNational.budget_product_Lines__c + ',' + Label.RevenueCY);
			String sep = BudgetingToolController.keySeparator;
			System.debug('DMA: ' + btc.loggedInUserDMA);
			btc.JSONOutput = '{"IO":{},"Changes":[{"id":"' + btc.loggedInUserDMA + sep + 'AR1$AR2$AR3$' + sep + 'Auto Aftermarket' + sep + acc.id + sep + 'Advanced Advertising' + sep + '2017","Changed":1,"Feb":"2","Mar":"3","Apr":"4","May":"5","Jun":"6","Jul":"7","Aug":"8","Sep":"9","Oct":"1","Nov":"2","Dec":"3"}]}';
			btc.saveGridData();

			String LedName = '2017 OTB';
			List<Integer> months = new List<Integer> { 0, 4000, 6000, 8000, 4000, 2000, 6000, 10000, 5000, 4000, 8000, 9000 };
			String formula = ''; String id = '';
			BudgetingToolModelNational.Items_Led tgmiLed = new BudgetingToolModelNational.Items_Led();
			tgmiLed.id = id;
			tgmiLed.Account = LedName;
			tgmiLed.Jan = months[0];
			tgmiLed.Feb = months[1];
			tgmiLed.Mar = months[2];
			tgmiLed.Apr = months[3];
			tgmiLed.May = months[4];
			tgmiLed.Jun = months[5];
			tgmiLed.Jul = months[6];
			tgmiLed.Aug = months[7];
			tgmiLed.Sep = months[8];
			tgmiLed.Oct = months[9];
			tgmiLed.Nov = months[10];
			tgmiLed.Dec = months[11];
			Test.stopTest();
		}
	}

	@IsTest(seeAlldata = false)
	static void NSMViewTest_Worklow() {

		//create National User
		User userNational = TestUtil.prepareUser();
		Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Master - National Sales Manager'];
		userNational.ProfileId = objProfile.Id;
		userNational.Username = 'testNational@mands.com';
		userNational.budget_type__c = 'National';
		userNational.budget_product_Lines__c = 'National Spot (NCC); National Direct Spot; National Digital (NCC); National Direct Digital';
		userNational.budget_dma__c = 'St Louis MO';
		userNational.Division__c = 'South';
		insert userNational;
		Sales_Budget__c sb = new Sales_Budget__c();
		Sales_Budget__c sbf = new Sales_Budget__c();
		Boolean showApproval = false;

		//Execute test as National User
		System.runAs(userNational) {

			//create Advertiser
			Account acc = TestUtil.getAccountRec();
			insert acc;

			//create Account Team member
			insert TestUtil.getAccountTeamMemRec(acc.Id, userNational.Id);


			//create PY Sales Revenue
			insert TestUtil.getRevenueRec(userNational, acc, System.today().addYears(- 1));

			//create CY Sales Revenue
			insert TestUtil.getRevenueRec(userNational, acc, System.today());

			//create Sales Budget
			sb = TestUtil.getSalesBudgetRec(userNational, acc);
			sb.Type__c = 'Workflow';
			sb.DMA__c = 'St Louis MO';
			sb.Status__c = 'Submitted';
			insert sb;
			//System.debug('SB TYPE: '+ sb.Type__c);

			sbf = TestUtil.getSalesBudgetRec(userNational, acc);
			sbf.Type__c = 'Forecast';
			sbf.CY_FCST_1_Jan_Amount__c = 0;
			sbf.CY_FCST_2_Feb_Amount__c = 1;
			sbf.CY_FCST_3_March_Amount__c = 4;
			sbf.CY_FCST_4_April_Amount__c = 5;
			sbf.CY_FCST_5_May_Amount__c = 4;
			sbf.CY_FCST_6_June_Amount__c = 4;
			sbf.CY_FCST_7_July_Amount__c = 5;
			sbf.CY_FCST_8_Aug_Amount__c = 5;
			sbf.CY_FCST_9_Sep_Amount__c = 6;
			sbf.CY_FCST_10_Oct_Amount__c = 5;
			sbf.CY_FCST_11_Nov_Amount__c = 2;
			sbf.CY_FCST_12_Dec_Amount__c = 1;
			sbf.PY_Rev_1_Jan_Amount__c = 1;
			sbf.PY_Rev_2_Feb_Amount__c = 6;
			sbf.PY_Rev_3_March_Amount__c = 4;
			sbf.PY_Rev_4_April_Amount__c = 4;
			sbf.PY_Rev_5_May_Amount__c = 6;
			sbf.PY_Rev_6_June_Amount__c = 7;
			sbf.PY_Rev_7_July_Amount__c = 9;
			sbf.PY_Rev_8_Aug_Amount__c = 5;
			sbf.PY_Rev_9_Sep_Amount__c = 6;
			sbf.PY_Rev_10_Oct_Amount__c = 3;
			sbf.PY_Rev_11_Nov_Amount__c = 4;
			sbf.PY_Rev_12_Dec_Amount__c = 7;
			sbf.CY_Rev_1_Jan_Amount__c = 6;
			sbf.CY_Rev_2_Feb_Amount__c = 4;
			sbf.CY_Rev_3_March_Amount__c = 2;
			sbf.CY_Rev_4_April_Amount__c = 1;
			sbf.CY_Rev_5_May_Amount__c = 1;
			sbf.CY_Rev_6_June_Amount__c = 3;
			sbf.CY_Rev_7_July_Amount__c = 2;
			sbf.CY_Rev_8_Aug_Amount__c = 0;
			sbf.CY_Rev_9_Sep_Amount__c = 4;
			sbf.CY_Rev_10_Oct_Amount__c = 6;
			sbf.CY_Rev_11_Nov_Amount__c = 7;
			sbf.CY_Rev_12_Dec_Amount__c = 6;

			sbf.NY_Revenue_1_Jan_Amount__c = 1;
			sbf.NY_Revenue_2_Feb_Amount__c =4;
			sbf.NY_Revenue_3_March_Amount__c = 5;
			sbf.NY_Revenue_4_April_Amount__c = 3;
			sbf.NY_Revenue_5_May_Amount__c = 2;
			sbf.NY_Revenue_6_June_Amount__c = 3;
		    sbf.NY_Revenue_7_July_Amount__c =4;
			sbf.NY_Revenue_8_Aug_Amount__c = 2;
			sbf.NY_Revenue_9_Sep_Amount__c = 1;
			sbf.NY_Revenue_10_Oct_Amount__c = 2;
			sbf.NY_Revenue_11_Nov_Amount__c = 3;
			sbf.NY_Revenue_12_Dec_Amount__c = 2;


			sbf.DMA__c = 'St Louis MO';
			//sbw.Broadcast_Month_Date__c = System.today();
			//sbf.Status__c = 'Submitted';
			insert sbf;

			//Create User Connection
			insert TestDataHelper.createUserConnection('St. Louis Local', 'SFDCUser', userNational.id, 'TIM', '1');

			//create Opportunity
			Opportunity opp = TestDataHelper.createopportunity('Test Opportunity', System.today(), 'Planning', 'Pipeline', acc.ID);
			insert opp;

			//create Proposal
			Proposal__c p = TestDataHelper.createProposal('Test Opportunity Proposal', opp.id, '00000', true);
			p.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
			p.Start_Date__c = System.today();
			p.End_Date__c = System.today().addMonths(1);
			insert p;
			System.debug('Test Data Proposal: ' + p);
			//Create SysCode
			Syscode__c sys = TestDataHelper.createSysCode(false);
			insert sys;
			//create Proposal Zone
			Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Proposal Zone', p.Id);
			insert propZone;

			//create Proposal Zone Monthly Value
			Proposal_Zone_Monthly_Value__c propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value', acc.Id, propZone.Id);
			propZoneMonthly.Schedule_Type__c = 'Linear';
			propZoneMonthly.Proposal_Key_Index__c = p.Id;
			propZoneMonthly.Broadcast_Month_Date__c = System.today().adddays(1);
			insert propZoneMonthly;

			Test.startTest();
			BudgetingToolController btc = new BudgetingToolController();
			System.debug('CY3: ' + btc.loggedInUser.id + ',' + btc.loggedInUserProductLines + ',' + Label.RevenueCY);
			System.debug('CY4: ' + userNational.id + ',' + userNational.budget_product_Lines__c + ',' + Label.RevenueCY);
			String sep = BudgetingToolController.keySeparator;
			System.debug('DMA: ' + btc.loggedInUserDMA);
			btc.JSONOutput = '{"IO":{},"Changes":[{"id":"' + btc.loggedInUserDMA + sep + 'AR1$AR2$AR3$' + sep + 'Auto Aftermarket' + sep + acc.id + sep + 'Linear/News/Sports' + sep + '2017","Changed":1,"Feb":"2","Mar":"3","Apr":"4","May":"5","Jun":"6","Jul":"7","Aug":"8","Sep":"9","Oct":"1","Nov":"2","Dec":"3"}]}';
			btc.saveGridData();

			String LedName = '2017 OTB';
			List<Integer> months = new List<Integer> { 0, 4000, 6000, 8000, 4000, 2000, 6000, 10000, 5000, 4000, 8000, 9000 };
			String formula = ''; String id = '';
			BudgetingToolModelNational.Items_Led tgmiLed = new BudgetingToolModelNational.Items_Led();
			tgmiLed.id = id;
			tgmiLed.Account = LedName;
			tgmiLed.Jan = months[0];
			tgmiLed.Feb = months[1];
			tgmiLed.Mar = months[2];
			tgmiLed.Apr = months[3];
			tgmiLed.May = months[4];
			tgmiLed.Jun = months[5];
			tgmiLed.Jul = months[6];
			tgmiLed.Aug = months[7];
			tgmiLed.Sep = months[8];
			tgmiLed.Oct = months[9];
			tgmiLed.Nov = months[10];
			tgmiLed.Dec = months[11];

			/*tgmiLed.JanFormula = tgmiLed.FebFormula = tgmiLed.MarFormula = tgmiLed.AprFormula = tgmiLed.MayFormula = tgmiLed.JunFormula = tgmiLed.JulFormula = tgmiLed.AugFormula = tgmiLed.SepFormula = tgmiLed.OctFormula = tgmiLed.NovFormula = tgmiLed.DecFormula = formula;
			  if(LedName =='18YOY%' || LedName =='19YOY%') {
			  String GetYOYStr = 'Grids.GetYOY(Grid, Row, Col)';
			  tgmiLed.JanFormula = tgmiLed.FebFormula = tgmiLed.MarFormula = tgmiLed.AprFormula = tgmiLed.MayFormula = tgmiLed.JunFormula =  GetYOYStr;
			  tgmiLed.JulFormula = tgmiLed.AugFormula = tgmiLed.SepFormula = tgmiLed.OctFormula = tgmiLed.NovFormula = tgmiLed.DecFormula = GetYOYStr;
			  tgmiLed.Q1Formula = tgmiLed.Q2Formula = tgmiLed.Q3Formula = tgmiLed.Q4Formula = tgmiLed.TotalFormula = GetYOYStr;
			  //   tgmiLed.Calculated = '1';
			  }*/


			//tgmiLed.format('c');
			//tgmiLed.format('p');
			/*tgmiLed.SetReadOnly(1);
			  tgmiLed.SetReadOnly(0);*/

			Test.stopTest();
		}
	}

	@IsTest(seeAlldata = false)
	static void NSMViewTest_Forecasts() {

		//create National User
		User userNational = TestUtil.prepareUser();
		Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Master - National Sales Manager'];
		userNational.ProfileId = objProfile.Id;
		userNational.Username = 'testNational@mands.com';
		userNational.budget_type__c = 'National';
		userNational.budget_product_Lines__c = 'National Spot (NCC); National Direct Spot; National Digital (NCC); National Direct Digital';
		userNational.budget_dma__c = 'St Louis MO;Albany NY';
		userNational.Division__c = 'South';
		insert userNational;
		Sales_Budget__c sb = new Sales_Budget__c();
		Sales_Budget__c sbf = new Sales_Budget__c();
		Boolean showApproval = false;

		//Execute test as National User
		System.runAs(userNational) {

			//create Advertiser
			Account acc = TestUtil.getAccountRec();
			acc.Primary_Commodity__c = 'Healthcare';
			insert acc;

			//create Account Team member
			insert TestUtil.getAccountTeamMemRec(acc.Id, userNational.Id);


			//create PY Sales Revenue
			insert TestUtil.getRevenueRec(userNational, acc, System.today().addYears(- 1));

			//create CY Sales Revenue
			Revenue__c src = TestUtil.getRevenueRec(userNational, acc, System.today());
			src.Budget_DMA__c = 'St Louis MO';
			insert src;
			System.debug('src: ' + src);
			//create Sales Budget
			sb = TestUtil.getSalesBudgetRec(userNational, acc);
			sb.Type__c = 'Workflow';
			sb.DMA__c = 'St Louis MO';
			sb.Status__c = 'Submitted';
			insert sb;
			//System.debug('SB TYPE: '+ sb.Type__c);

			sbf = TestUtil.getSalesBudgetRec(userNational, acc);
			sbf.Type__c = 'Forecast';
			sbf.DMA__c = 'St Louis MO';
			insert sbf;

			//Create User Connection
			insert TestDataHelper.createUserConnection('St. Louis Local', 'SFDCUser', userNational.id, 'TIM', '1');

			//create Opportunity
			Opportunity opp = TestDataHelper.createopportunity('Test Opportunity', System.today(), 'Planning', 'Pipeline', acc.ID);
			opp.DMA__c = 'St Louis MO';
			insert opp;

			//create Proposal
			Proposal__c p = TestDataHelper.createProposal('Test Opportunity Proposal', opp.id, '00000', true);
			p.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
			p.Start_Date__c = System.today();
			p.End_Date__c = System.today().addMonths(1);
			insert p;
			System.debug('Test Data Proposal: ' + p);
			//Create SysCode
			Syscode__c sys = TestDataHelper.createSysCode(false);
			insert sys;
			//create Proposal Zone
			Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Proposal Zone', p.Id);
			insert propZone;

			//create Proposal Zone Monthly Value
			Proposal_Zone_Monthly_Value__c propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value', acc.Id, propZone.Id);
			propZoneMonthly.Schedule_Type__c = 'Linear';
			propZoneMonthly.Proposal_Key_Index__c = p.Id;
			propZoneMonthly.Broadcast_Month_Date__c = System.today().adddays(1);
			insert propZoneMonthly;

			Test.startTest();
			BudgetingToolController btc = new BudgetingToolController();
			BudgetingToolController.saveNationalForecast('St Louis MO', userNational.id, userNational.budget_product_Lines__c, false);
			btc.queryAETreeData();
			//btc.queryDOSTreeData();
			Test.stopTest();
		}
	}


	@IsTest(seeAlldata = false)
	static void NSMViewTest() {

		//create National User
		User userNational = TestUtil.prepareUser();
		Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Master - National Sales Manager'];
		userNational.ProfileId = objProfile.Id;
		userNational.Username = 'testNational@mands.com';
		userNational.budget_type__c = 'National';
		userNational.budget_product_Lines__c = 'National Spot (NCC); National Direct Spot; National Digital (NCC); National Direct Digital';
		userNational.budget_dma__c = 'St Louis MO';
		userNational.Division__c = 'South';
		insert userNational;
		Sales_Budget__c sb = new Sales_Budget__c();
		Sales_Budget__c sbw = new Sales_Budget__c();
		Sales_Budget__c sbf = new Sales_Budget__c();

		//Execute test as National User
		System.runAs(userNational) {

			//create Advertiser
			Account acc = TestUtil.getAccountRec();
			insert acc;
			System.debug('Advertiser Account ID: ' + acc.Id);

			//create Account Team member
			insert TestUtil.getAccountTeamMemRec(acc.Id, userNational.Id);


			//create PY Sales Revenue
			Revenue__c srPY = new Revenue__c();
			srPY = TestUtil.getRevenueRec(userNational, acc, System.today().addYears(- 1));
			srpy.Account_Executive__c = userNational.id;
			srPY.Budget_DMA__c = 'St Louis MO';
			srPY.Product_Line__c = 'National Direct Spot';
			insert srPY;

			//create CY Sales Revenue
			Revenue__c srCY = new Revenue__c();
			srCY = TestUtil.getRevenueRec(userNational, acc, System.today());
			srCY.Budget_DMA__c = 'St Louis MO';
			srCY.Product_Line__c = 'National Direct Spot';
			srCY.Account_Executive__c = userNational.id;

			insert srCY;

			//create CY Sales Budget
			sb = TestUtil.getSalesBudgetRec(userNational, acc);
			sb.Type__c = 'Data';
			sb.DMA__c = 'St Louis MO';
			insert sb;
			//System.debug('SB TYPE: '+ sb);


			sbw = TestUtil.getSalesBudgetRec(userNational, acc);
			sbw.Type__c = 'Workflow';
			sbw.DMA__c = 'St Louis MO';
			//sbw.Broadcast_Month_Date__c = System.today().;
			//sbf.Status__c = 'Submitted';
			//insert sbw;

			sbf = TestUtil.getSalesBudgetRec(userNational, acc);
			sbf.Type__c = 'Forecast';
			sbf.DMA__c = 'St Louis MO';
			//sbw.Broadcast_Month_Date__c = System.today();
			//sbf.Status__c = 'Submitted';
			insert sbf;


			//Create User Connection
			insert TestDataHelper.createUserConnection('St. Louis Local', 'SFDCUser', userNational.id, 'TIM', '1');

			//create Opportunity
			Opportunity opp = TestDataHelper.createopportunity('Test Opportunity', System.today(), 'Planning', 'Pipeline', acc.ID);
			opp.OwnerId = userNational.id;
			opp.DMA__c = 'St Louis MO';
			insert opp;

			//create Proposal
			Proposal__c p = TestDataHelper.createProposal('Test Opportunity Proposal', opp.id, '00000', true);
			p.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
			p.Start_Date__c = System.today();
			p.End_Date__c = System.today().addMonths(1);
			insert p;
			//Create SysCode
			Syscode__c sys = TestDataHelper.createSysCode(false);
			insert sys;
			//create Proposal Zone
			Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Proposal Zone', p.Id);
			propZone.sys_code__c = 'NSPOT';
			insert propZone;

			//create Proposal Zone Monthly Value
			Proposal_Zone_Monthly_Value__c propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value', acc.Id, propZone.Id);
			propZoneMonthly.Schedule_Type__c = 'Linear';
			propZoneMonthly.Proposal_Key_Index__c = p.Id;
			propZoneMonthly.Broadcast_Month_Date__c = System.today().adddays(1);
			//propZoneMonthly.sys_code__c = 'NSPOT';
			insert propZoneMonthly;

			Test.startTest();
			BudgetingToolController btc = new BudgetingToolController();
			System.debug('CY3: ' + btc.loggedInUser.id + ',' + btc.loggedInUserProductLines + ',' + Label.RevenueCY);
			System.debug('CY4: ' + userNational.id + ',' + userNational.budget_product_Lines__c + ',' + Label.RevenueCY);
			String sep = BudgetingToolController.keySeparator;
			System.debug('DMA: ' + btc.loggedInUserDMA);
			btc.JSONOutput = '{"IO":{},"Changes":[{"id":"' + btc.loggedInUserDMA + sep + 'AR1$AR2$AR3$' + sep + 'Auto Aftermarket' + sep + acc.id + sep + 'Linear/News/Sports' + sep + '2017","Changed":1,"Feb":"2","Mar":"3","Apr":"4","May":"5","Jun":"6","Jul":"7","Aug":"8","Sep":"9","Oct":"1","Nov":"2","Dec":"3"}]}';
			btc.saveGridData();
			// btc.queryAETreeData();

			String LedName = '2017 OTB';
			List<Integer> months = new List<Integer> { 0, 4000, 6000, 8000, 4000, 2000, 6000, 10000, 5000, 4000, 8000, 9000 };
			String formula = ''; String id = '';
			BudgetingToolModelNational.Items_Led tgmiLed = new BudgetingToolModelNational.Items_Led();
			tgmiLed.id = id;
			tgmiLed.Account = LedName;
			tgmiLed.Jan = months[0];
			tgmiLed.Feb = months[1];
			tgmiLed.Mar = months[2];
			tgmiLed.Apr = months[3];
			tgmiLed.May = months[4];
			tgmiLed.Jun = months[5];
			tgmiLed.Jul = months[6];
			tgmiLed.Aug = months[7];
			tgmiLed.Sep = months[8];
			tgmiLed.Oct = months[9];
			tgmiLed.Nov = months[10];
			tgmiLed.Dec = months[11];

			/*tgmiLed.JanFormula = tgmiLed.FebFormula = tgmiLed.MarFormula = tgmiLed.AprFormula = tgmiLed.MayFormula = tgmiLed.JunFormula = tgmiLed.JulFormula = tgmiLed.AugFormula = tgmiLed.SepFormula = tgmiLed.OctFormula = tgmiLed.NovFormula = tgmiLed.DecFormula = formula;
			  if(LedName =='18YOY%' || LedName =='19YOY%') {
			  String GetYOYStr = 'Grids.GetYOY(Grid, Row, Col)';
			  tgmiLed.JanFormula = tgmiLed.FebFormula = tgmiLed.MarFormula = tgmiLed.AprFormula = tgmiLed.MayFormula = tgmiLed.JunFormula =  GetYOYStr;
			  tgmiLed.JulFormula = tgmiLed.AugFormula = tgmiLed.SepFormula = tgmiLed.OctFormula = tgmiLed.NovFormula = tgmiLed.DecFormula = GetYOYStr;
			  tgmiLed.Q1Formula = tgmiLed.Q2Formula = tgmiLed.Q3Formula = tgmiLed.Q4Formula = tgmiLed.TotalFormula = GetYOYStr;
			  //   tgmiLed.Calculated = '1';
			  }*/


			//tgmiLed.format('c');
			//tgmiLed.format('p');
			/*tgmiLed.SetReadOnly(1);
			  tgmiLed.SetReadOnly(0);*/

			Test.stopTest();
		}
	}

	@IsTest(seeAlldata = false)
	static void ExecViewTest_DOSInsert() {

		//create Executive User
        
		User userNational = TestUtil.prepareUser();
		Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Master - Director of Sales' limit 1];
		userNational.ProfileId = objProfile.Id;
		userNational.Username = 'testExec@mands.com';
		userNational.Budget_type__c = 'National';
		userNational.budget_product_Lines__c = 'National Spot (NCC); National Direct Spot; National Digital (NCC); National Direct Digital';
		userNational.budget_dma__c = 'St Louis MO;Wilmington NC;Youngstown OH';
		userNational.Division__c = 'South';

		insert userNational;

		User userM = TestUtil.prepareUser();
		Profile objProfileM = [SELECT Id, Name FROM Profile WHERE Name = 'Master - Local Sales Manager' Limit 1];
		userM.ProfileId = objProfileM.Id;
		userM.Username = 'testLSM@mands.com';
		userM.budget_type__c = 'Local';
		userM.budget_product_Lines__c = 'Linear/News/Sports;';
		userM.HR_Manager__c = userNational.id;
		insert userM;
		User userAE = TestUtil.prepareUser();
		Profile objProfileAE = [SELECT Id, Name FROM Profile WHERE Name = 'Master - Account Executive' Limit 1];
		userAE.ProfileId = objProfileAE.Id;
		userAE.Username = 'testae@mands.com';
		userAE.budget_type__c = 'Local';
		userAE.budget_product_Lines__c = 'Linear/News/Sports;';
		userAE.HR_Manager__c = userM.id;
		insert userAE;

		/*List<user>us=new list<user>();
		  us.add(userAE);
		  List<string>usstr=new list<string>();
		  usstr.add(userAE.id);*/


		ApexPages.currentPage().getParameters().put('userparam', userNational.id);
		Sales_Budget__c sb = new Sales_Budget__c();
		//Execute test as National User
		System.runAs(userNational) {
            
			//create Advertiser
			Account acc = TestUtil.getAccountRec();
			insert acc;

			//create PY Sales Revenue
			insert TestUtil.getRevenueRec(userNational, acc, System.today().addYears(- 1));

			//create CY Sales Revenue
			insert TestUtil.getRevenueRec(userNational, acc, System.today());
			ApexPages.currentPage().getParameters().put('selectedDMA', 'Wilmington NC');
			//create Sales Budget
			sb = TestUtil.getSalesBudgetRec(userNational, acc);
			sb.DMA__c = 'Wilmington NC';
			sb.Type__c = 'DOS';
			sb.Product_Line__c = 'National Spot (NCC)';
			sb.New_Business_Churn__c = 'New Business';
			sb.Status__c = 'Pending';
			sb.Broadcast_Month_Date__c = System.today().addYears(1);
			insert sb;

			//Create User Connection
			insert TestDataHelper.createUserConnection('St. Louis Local', 'SFDCUser', userNational.id, 'TIM', '1');

			//create Opportunity
			Opportunity opp = TestDataHelper.createopportunity('Test Opportunity1', System.today(), 'Planning', 'Pipeline', acc.ID);
			insert opp;

			//create Proposal
			Proposal__c p = TestDataHelper.createProposal('Test Opportunity Proposal', opp.id, '00000', true);
			p.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
			p.Start_Date__c = System.today();
			p.End_Date__c = System.today().addMonths(1);
			insert p;
			//Create SysCode
			Syscode__c sys = TestDataHelper.createSysCode(false);
			insert sys;
			//create Proposal Zone
             Test.startTest();
			Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Proposal Zone', p.Id);
			insert propZone;

			//create Proposal Zone Monthly Value
			Proposal_Zone_Monthly_Value__c propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value', acc.Id, propZone.Id);
			propZoneMonthly.Schedule_Type__c = 'Linear';
			propZoneMonthly.Proposal_Key_Index__c = p.Id;
			propZoneMonthly.Broadcast_Month_Date__c = System.today().adddays(1);
			

			
            insert propZoneMonthly;
			BudgetingToolController btc = new BudgetingToolController();
			System.debug('CY3: ' + btc.loggedInUser.id + ',' + btc.loggedInUserProductLines + ',' + Label.RevenueCY);
			System.debug('CY4: ' + userNational.id + ',' + userNational.budget_product_Lines__c + ',' + Label.RevenueCY);
			String sep = BudgetingToolController.keySeparator;
			System.debug('DMA: ' + btc.loggedInUserDMA);
			btc.JSONOutput = '{"IO":{},"Changes":[{"id":"AR1$AR2$AR3$' + sep + 'Auto Aftermarket' + sep + acc.id + sep + 'Linear/News/Sports' + sep + '2017' + sep + 'DOS' + sep + 'New Business","Changed":1,"Feb":"2","Mar":"3","Apr":"4","May":"5","Jun":"6","Jul":"7","Aug":"8","Sep":"9","Oct":"1","Nov":"2","Dec":"3"}]}';
			btc.saveGridData();

			String LedName = '2017 OTB';
			List<Integer> months = new List<Integer> { 0, 4000, 6000, 8000, 4000, 2000, 6000, 10000, 5000, 4000, 8000, 9000 };
			String formula = ''; String id = '';
			BudgetingToolModelNational.Items_Led tgmiLed = new BudgetingToolModelNational.Items_Led();
			tgmiLed.id = id;
			tgmiLed.Account = LedName;
			tgmiLed.Jan = months[0];
			tgmiLed.Feb = months[1];
			tgmiLed.Mar = months[2];
			tgmiLed.Apr = months[3];
			tgmiLed.May = months[4];
			tgmiLed.Jun = months[5];
			tgmiLed.Jul = months[6];
			tgmiLed.Aug = months[7];
			tgmiLed.Sep = months[8];
			tgmiLed.Oct = months[9];
			tgmiLed.Nov = months[10];
			tgmiLed.Dec = months[11];

			/*tgmiLed.JanFormula = tgmiLed.FebFormula = tgmiLed.MarFormula = tgmiLed.AprFormula = tgmiLed.MayFormula = tgmiLed.JunFormula = tgmiLed.JulFormula = tgmiLed.AugFormula = tgmiLed.SepFormula = tgmiLed.OctFormula = tgmiLed.NovFormula = tgmiLed.DecFormula = formula;
			  if(LedName =='18YOY%' || LedName =='19YOY%') {
			  String GetYOYStr = 'Grids.GetYOY(Grid, Row, Col)';
			  tgmiLed.JanFormula = tgmiLed.FebFormula = tgmiLed.MarFormula = tgmiLed.AprFormula = tgmiLed.MayFormula = tgmiLed.JunFormula =  GetYOYStr;
			  tgmiLed.JulFormula = tgmiLed.AugFormula = tgmiLed.SepFormula = tgmiLed.OctFormula = tgmiLed.NovFormula = tgmiLed.DecFormula = GetYOYStr;
			  tgmiLed.Q1Formula = tgmiLed.Q2Formula = tgmiLed.Q3Formula = tgmiLed.Q4Formula = tgmiLed.TotalFormula = GetYOYStr;
			  //   tgmiLed.Calculated = '1';
			  }
			 
			 
			  tgmiLed.format('c');
			  tgmiLed.format('p');
			  tgmiLed.SetReadOnly(1);
			  tgmiLed.SetReadOnly(0);*/

			Test.stopTest();
		}
	}

	@IsTest(seeAlldata = false)
	static void ExecViewTest_DOSUpdate() {

		//create Executive User
      
		User userNational = TestUtil.prepareUser();
		Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Master - Director of Sales'];
		userNational.ProfileId = objProfile.Id;
		userNational.Username = 'testExec@mands.com';
		userNational.Budget_type__c = 'National';
		userNational.budget_product_Lines__c = 'National Spot (NCC); National Direct Spot; National Digital (NCC); National Direct Digital';
		userNational.budget_dma__c = 'St Louis MO;Wilmington NC;Youngstown OH';
		userNational.Division__c = 'South';
		insert userNational;

		User userAE = TestUtil.prepareUser();
		Profile objProfileAE = [SELECT Id, Name FROM Profile WHERE Name = 'Master - Account Executive'];
		userAE.ProfileId = objProfileAE.Id;
		userAE.Username = 'testae@mands.com';
		userAE.budget_type__c = 'Local';
		userAE.budget_product_Lines__c = 'Linear/News/Sports;';
		insert userAE;


		ApexPages.currentPage().getParameters().put('userparam', userAE.id);
		Sales_Budget__c sb = new Sales_Budget__c();
		//Execute test as National User
		System.runAs(userNational) {
             
			//create Advertiser
			Account acc = TestUtil.getAccountRec();
			insert acc;

			//create PY Sales Revenue
			insert TestUtil.getRevenueRec(userNational, acc, System.today().addYears(- 1));

			//create CY Sales Revenue
			insert TestUtil.getRevenueRec(userNational, acc, System.today());

			ApexPages.currentPage().getParameters().put('selectedDMA', 'Wilmington NC');
			//create Sales Budget
			sb = TestUtil.getSalesBudgetRec(userNational, acc);
			sb.DMA__c = 'Wilmington NC';
			sb.Type__c = 'DOS';
			sb.Product_Line__c = 'National Spot (NCC)';
			sb.New_Business_Churn__c = 'New Business';
			sb.Status__c = 'Pending';
			sb.Broadcast_Month_Date__c = System.today().addYears(1);
			insert sb;

			//Create User Connection
			insert TestDataHelper.createUserConnection('St. Louis Local', 'SFDCUser', userNational.id, 'TIM', '1');

			//create Opportunity
			Opportunity opp = TestDataHelper.createopportunity('Test Opportunity1', System.today(), 'Planning', 'Pipeline', acc.ID);
			insert opp;

			//create Proposal
			Proposal__c p = TestDataHelper.createProposal('Test Opportunity Proposal', opp.id, '00000', true);
			p.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
			p.Start_Date__c = System.today();
			p.End_Date__c = System.today().addMonths(1);
			insert p;
			//Create SysCode
			Syscode__c sys = TestDataHelper.createSysCode(false);
			insert sys;
			//create Proposal Zone
             Test.startTest();
			Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Proposal Zone', p.Id);
			insert propZone;

			//create Proposal Zone Monthly Value
			Proposal_Zone_Monthly_Value__c propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value', acc.Id, propZone.Id);
			propZoneMonthly.Schedule_Type__c = 'Linear';
			propZoneMonthly.Proposal_Key_Index__c = p.Id;
			propZoneMonthly.Broadcast_Month_Date__c = System.today().adddays(1);
			

			
            insert propZoneMonthly;
			BudgetingToolController btc = new BudgetingToolController();
			System.debug('CY3: ' + btc.loggedInUser.id + ',' + btc.loggedInUserProductLines + ',' + Label.RevenueCY);
			System.debug('CY4: ' + userNational.id + ',' + userNational.budget_product_Lines__c + ',' + Label.RevenueCY);
			String sep = BudgetingToolController.keySeparator;
			System.debug('DMA: ' + btc.loggedInUserDMA);
			btc.JSONOutput = '{"IO":{},"Changes":[{"id":"AR1$AR2$AR3$' + sep + 'Auto Aftermarket' + sep + acc.id + sep + 'Linear/News/Sports' + sep + '2017' + sep + 'DOS' + sep + 'New Business","Changed":1,"Feb":"2","Mar":"3","Apr":"4","May":"5","Jun":"6","Jul":"7","Aug":"8","Sep":"9","Oct":"1","Nov":"2","Dec":"3"}]}';
			//btc.saveGridData();

			String LedName = '2017 OTB';
			List<Integer> months = new List<Integer> { 0, 4000, 6000, 8000, 4000, 2000, 6000, 10000, 5000, 4000, 8000, 9000 };
			String formula = ''; String id = '';
			BudgetingToolModelNational.Items_Led tgmiLed = new BudgetingToolModelNational.Items_Led();
			tgmiLed.id = id;
			tgmiLed.Account = LedName;
			tgmiLed.Jan = months[0];
			tgmiLed.Feb = months[1];
			tgmiLed.Mar = months[2];
			tgmiLed.Apr = months[3];
			tgmiLed.May = months[4];
			tgmiLed.Jun = months[5];
			tgmiLed.Jul = months[6];
			tgmiLed.Aug = months[7];
			tgmiLed.Sep = months[8];
			tgmiLed.Oct = months[9];
			tgmiLed.Nov = months[10];
			tgmiLed.Dec = months[11];

			Test.stopTest();
		}
	}
}