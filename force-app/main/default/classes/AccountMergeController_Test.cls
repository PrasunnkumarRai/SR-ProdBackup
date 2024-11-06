/*
  ###########################################################################
  # File..................: AccountMergeController_Test.cls
  # Version...............: 
  # Created by............: Aditi Garg
  # Created Date..........: 7-July-2017
  # Last Modified by......: Puneet Khosla 
  # Last Modified Date....: 24-July-2018
  # Description...........: Test class for AccountMergeController 
  # TAO Ref#..............: NA
  # Change Log:              
  # 1. Puneet Khosla - Changes done under SRSF-1163
  #
  ############################################################################*/
@isTest
private class AccountMergeController_Test
{
	private static String token;
	private static String endPoint;
	private static String rootFolderSyncPointId;
	private static String sourceFolder;
	private static List<SyncplicityIntegration__c> SyncpIntCustSett = new List<SyncplicityIntegration__c> ();

	@isTest
	static void accountMergePositivePathTest()
	{
		List<Opportunity> oppList = new List<Opportunity> ();
		List<AccountConnection__c> accConnectList = new List<AccountConnection__c> ();
		List<AccountConnection__c> agencyconn = new list<AccountConnection__c> ();
		List<Contact> conList = new List<Contact> ();
		List<CNA__c> cnaList = new List<CNA__c> ();
		List<Revenue__c> revList = new List<Revenue__c> ();
		List<Traffic_Id_Element__c> trafficList = new List<Traffic_Id_Element__c> ();
		List<Trade__c> tradeList = new List<Trade__c> ();
		List<Account_Transfer_Mapping__c> accMap = new list<Account_Transfer_Mapping__c> ();
        
		User u = TestDataHelper.getBoomiIntegrationUser();
		User newUser = TestDataHelper.createUser(true);
		User inactiveUser = TestDataHelper.createUser(false);
		inactiveUser.username = 'abcd@charter.com';
        inactiveUser.Is_Frozen__c= true;
		inactiveUser.email = 'abcd@charter.com';
		insert inactiveUser;
		User newAdminUser = TestDataHelper.createSystemAdminUser(true);
		System.debug('@@u Name ' + u.Name);
		System.debug('Standarduser' + newUser);

		//System.runAs(u){
		System.runAs(newAdminUser) {
			//Create parent account
			//  Account parentAcc=TestDataHelper.createAdvertiser('Advertiser Account_parent','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
			//Account parentAcc=TestDataHelper.createAcc('Account_parent','122 Wright Plaza Parent', 'Omaha', 'NE', '68130', 'USA');
			//Account parentAcc=TestDataHelper.createAcc('Account_parent','122 Wright Plaza', 'Omaha', 'NE', '68130', 'USA'); 
			// Id recTypeAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advertiser Account').getRecordTypeId();
			//parentAcc.recordTypeid = recTypeAcc;
			//insert parentAcc;
			//  System.debug('parentAcc'+parentAcc);

			// System.assert(parentAcc != null);
            
			//Create main account
			Account parentAcc = TestDataHelper.createAdvertiser('Advertiser Account', '123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');
			//acc.MergeAccount__c = parentAcc.id;
			insert parentAcc;
            

			AccountTeamMember atmP = new AccountTeamMember();
			atmP.AccountId = parentAcc.Id;
			atmP.UserId = newAdminUser.Id;
			atmP.TeamMemberRole = 'Sales Manager';

			insert atmP;
			AccountTeamMember atmP1 = new AccountTeamMember();
			atmP1.AccountId = parentAcc.Id; 
			atmP1.UserId = u.Id;
			atmP1.TeamMemberRole = 'Sales Manager';

			insert atmP1;
			System.assert(parentAcc != null);

			//Create child account
			Account childAcc = TestDataHelper.createAdvertiser('Advertiser Account_child', '123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');
			Account childAc = TestDataHelper.createAdvertiser('Agency Account_child', '123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');
			insert childAc;
			//Account childAcc = TestDataHelper.createAgency('Agency Account_child','124 Wright Plaza Child', 'Omaha', 'NW', '68131', 'USA');                                            
			// Account childAcc = TestDataHelper.createAgency('Agency Account_child','124 Wright Plaza', 'Omaha', 'NW', '68131', 'USA'); 
			//childAcc.MergeAccount__c = parentAcc.id;
			insert childAcc;
			AccountTeamMember atmC = new AccountTeamMember();
			atmC.AccountId = childAcc.Id;
			atmC.userID = newAdminUser.Id;
			atmC.TeamMemberRole = 'Coordinator';

			insert atmC;
            //change 
            /*
            AccountTeamMember atmPnew = new AccountTeamMember();
			atmPnew.AccountId = parentAcc.Id;
			atmPnew.UserId = newAdminUser.Id;
			atmPnew.TeamMemberRole = 'Coordinator';
            
            insert atmPnew;
            
            AccountTeamMember atmCnew = new AccountTeamMember();
			atmCnew.AccountId = childAcc.Id;
			atmCnew.userID = newAdminUser.Id;
			atmCnew.TeamMemberRole = 'Sales Manager';
            
            insert atmCnew;
            */
            //chnage
            
			parentAcc.MergeAccount__c = childAcc.id;
			update parentAcc;
			System.assert(childAcc != null);
            

			//create account transfer tool

			Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
			//att.Division__c = 'Central';
			//att.Region__c = 'MidNorth';
			att.Status__c = 'New';
			//att.Transfer_Effective_Date__c = Date.newInstance(2019, 01, 15);
			insert att;

			//create account transfer mapping
			Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
			atm.Account__c = childAcc.Id;
			atm.Account_Transfer_Simulation__c = att.id;
			accMap.add(atm);
			insert accMap;

			//Create main account
			/* Account parentAccAg=TestDataHelper.createAgency('Agency Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
			  //acc.MergeAccount__c = parentAcc.id;
			  insert parentAccAg;
			 
			  //System.assert(parentAcc != null);
			 
			  //Create child account
			  Account childAccAg = TestDataHelper.createAgency('Agency Account_child','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');
			 
			  //Account childAcc = TestDataHelper.createAgency('Agency Account_child','124 Wright Plaza Child', 'Omaha', 'NW', '68131', 'USA');                                            
			  // Account childAcc = TestDataHelper.createAgency('Agency Account_child','124 Wright Plaza', 'Omaha', 'NW', '68131', 'USA'); 
			  //childAcc.MergeAccount__c = parentAcc.id;
			  insert childAccAg;
			  parentAccAg.MergeAccount__c = childAccAg.id;
			  update parentAccAg;
			  //System.assert(childAcc != null);
			 
			  /*AccountConnection__c accConn = TestDataHelper.createAccountConnection(parentAccAg.Id);
			  accConn.Tim_System__c = 'St. Louis Local';
			  agencyconn.add(accConn);
			  insert agencyconn;*/

			//Create account connenction      
			/* AccountConnection__c accConnectAg = TestDataHelper.createAccountConnection(String.valueOf(parentAccAg.id));
			  agencyconn.add(accConnectAg);
			  System.debug('accConnectList'+agencyconn +'accConnectList size'+ agencyconn.size());     
			  AccountConnection__c accConnectchildAg = TestDataHelper.createAccountConnection(String.valueOf(childAccAg.id));
			  agencyconn.add(accConnectchildAg);        
			  insert agencyconn;*/


			//Create opportunity       
			Opportunity opp = TestDataHelper.createopportunity('Test Opportunity', System.today(), 'Planning', 'Pipeline', childAcc.id);
			oppList.add(opp);
			Opportunity childopp = TestDataHelper.createopportunity('Test Opportunity_child', System.today(), 'Planning', 'Pipeline', childAcc.id);
			childopp.OwnerId = newUser.Id;
			oppList.add(childopp);
			Opportunity inactiveopp = TestDataHelper.createopportunity('Test Opportunity_child', System.today(), 'Planning', 'Pipeline', childAcc.id);
			inactiveopp.OwnerId = inactiveUser.Id;
			oppList.add(inactiveopp);
			insert oppList;
			inactiveUser.IsActive = false;
			update inactiveUser;

			System.assert(oppList != null);
			//Create account connenction      
			AccountConnection__c accConnect = TestDataHelper.createAccountConnection(String.valueOf(parentAcc.id));
			accConnectList.add(accConnect);
			System.debug('accConnectList' + accConnectList + 'accConnectList size' + accConnectList.size());
			AccountConnection__c accConnectchild = TestDataHelper.createAccountConnection(String.valueOf(childAcc.id));
			accConnectList.add(accConnectchild);
			insert accConnectList;
			System.debug('parentAcc.id: ' + parentAcc.id);
			//Create contact         
			//Contact con = TestDataHelper.createContact('testLast', parentAcc.id, 'test@charter.com', '');
			//conList.add(con);
			//Contact childcon = TestDataHelper.createContact('testlast_child', childAcc.id, 'test1@charter.com', '');
			//conList.add(childcon);
			//insert conList;

			//System.assert(conList != null);

			//Create CNA        
			CNA__c cna = TestDataHelper.createCNR(parentAcc.id);
			cnaList.add(cna);
			CNA__c cna_child = TestDataHelper.createCNR(childAcc.id);
			cnaList.add(cna_child);
			insert cnaList;
             Test.StartTest();
			Proposal__c prop = TestDataHelper.createProposal('Test Proposal', childopp.id, '76877', True);
			prop.Advertiser__c = childAcc.Id;
			prop.Active__c = false;
			prop.TIM_Status__c = 'Proposal';
			insert prop;
          
			Digital_Campaign__c dc = TestDataHelper.createDigitalCampaign('Test', String.valueOf(childopp.Id), String.valueOf(prop.Id));
			RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Spectrum Networks Display'];
			dc.RecordTypeId = rt.Id;
			insert dc;
			SAM_Designation_Order__c cs = new SAM_Designation_Order__c();
			cs.Name = 'Key';
			cs.SAM_Order__c = 5.0;
			//cs.Other fiels values
			insert cs;
			cs = new SAM_Designation_Order__c();
			cs.Name = 'Target';
			cs.SAM_Order__c = 2.0;
			//cs.Other fiels values
			insert cs;
			
			Account_SAM_Mapping__c newAsm = new Account_SAM_Mapping__c(account__c = parentAcc.Id, user__c = UserInfo.getUserId(),
			                                                           SAM_Designation__c = 'Target', region__c = newAdminUser.region__c,
			                                                           sales_office__c = newAdminUser.sales_office__c,
			                                                           division__c = newAdminUser.division__c,
			                                                           ownerId = newAdminUser.id);
			insert newAsm;
			newAsm = new Account_SAM_Mapping__c(account__c = childAcc.Id, user__c = UserInfo.getUserId(),
			                                    SAM_Designation__c = 'Key', region__c = newAdminUser.region__c,
			                                    sales_office__c = newAdminUser.sales_office__c,
			                                    division__c = newAdminUser.division__c,
			                                    ownerId = newAdminUser.id);
			insert newAsm;
          /*  newAsm = new Account_SAM_Mapping__c(account__c = childAcc.Id, user__c = newUser.id,
			                                    SAM_Designation__c = 'Key', region__c = newAdminUser.region__c,
			                                    sales_office__c = newAdminUser.sales_office__c,
			                                    division__c = newAdminUser.division__c,
			                                    ownerId = newAdminUser.id);
			insert newAsm;*/
			//Create Revenue 
			Revenue__c revenue = new Revenue__c();
			revenue.Customer_Number__c = '5413';
			revenue.AE_Id__c = '3333';
			revenue.Export_System_Id__c = '1';
			revenue.Actual_Gross_Amount__c = 1000;
			revenue.Projected_Gross_Amount__c = 1000;
			//revenue.Actual_Discount__c = actualDiscount;
			//revenue.Projected_Discount__c = projectedDiscount;
			//rev.Broadcast_Month_Date__c = bMonth; 
			//TestDataHelper.createRevenue('2222', '3333', System.today(), 1000, 1000, 0, 0, '1');
			revenue.Eclipse_System__c = 'TWNY';
			revenue.ContractNumber__c = 1111;
			revenue.Advertiser__c = parentAcc.Id;    
		    revList.add(revenue);
            
            Revenue__c revenue1 = new Revenue__c();   
			revenue1.Customer_Number__c = '5413';
			revenue1.AE_Id__c = '2222';
			revenue1.Export_System_Id__c = '1';
			revenue1.Actual_Gross_Amount__c = 1000;
			revenue1.Projected_Gross_Amount__c = 1000;
			//revenue.Actual_Discount__c = actualDiscount;
			//revenue.Projected_Discount__c = projectedDiscount;
			//rev.Broadcast_Month_Date__c = bMonth; 
			//TestDataHelper.createRevenue('2222', '3333', System.today(), 1000, 1000, 0, 0, '1');
			
			revenue1.Advertiser__c = childAc.ID;
			revenue1.Eclipse_System__c = 'TWNY';
			revenue1.ContractNumber__c = 1111;
			//revList.add(revenue1); 
			insert revList;
			Sales_Budget__c sb = new Sales_Budget__c();
			sb = TestUtil.getSalesBudgetRec(u, parentAcc);
			sb.Type__c = 'Data';
			insert sb;
			sb = new Sales_Budget__c();
			sb = TestUtil.getSalesBudgetRec(u, childAcc);
			sb.Type__c = 'Data';
			insert sb;

			//Create Traffic
			Traffic_Id_Element__c trafficElementUser = new Traffic_Id_Element__c();
			//trafficElementUser.Account_TIM_ID__c = Agency.ID;

			trafficElementUser.User__c = u.ID;
			trafficElementUser.AE_ID__c = 1;
			trafficElementUser.Export_System_Id__c = '1';
			trafficElementUser.Traffic_Id__c = '2222';
			trafficElementUser.Tim_System__c = 'St. Louis Local';
			trafficElementUser.Traffic_Type__c = 'User';
			trafficElementUser.Account__c = parentAcc.ID;
			trafficElementUser.ExportSystem_Name__c = 'TWNY';
			trafficList.add(trafficElementUser);

			Traffic_Id_Element__c trafficElementUser1 = new Traffic_Id_Element__c();

			trafficElementUser1.User__c = u.ID;
			trafficElementUser1.AE_ID__c = 2;
			trafficElementUser1.Export_System_Id__c = '3';
			trafficElementUser1.Traffic_Id__c = '33';
			trafficElementUser1.Tim_System__c = 'St. Louis Local';
			trafficElementUser1.Traffic_Type__c = 'Account';
			trafficElementUser1.Account__c = childAcc.ID;
			trafficElementUser1.ExportSystem_Name__c = 'TWNY';
			trafficList.add(trafficElementUser1);
			insert trafficList;

			//Create Trade


			Trade__c rec1 = TestDataHelper.createTrade('Test Trade1', childopp.id, prop.id);
			rec1.Account__c = childAcc.Id;
			rec1.Trade_Receipt_Value__c = 1.0;
			rec1.Annual_Cash_Spend__c = 25.00;
			tradeList.add(rec1);
			insert tradeList;
              
			Support_Request__c request = TestDataHelper.createSupportrequest('Test Support Request1', opp.Id, 2, null, null, System.today());
			request.Agency__c = parentAcc.Id;
			request.Advertiser__c = parentAcc.Id;
			insert request;
			request = TestDataHelper.createSupportrequest('Test Support Request2', opp.Id, 2, null, null, System.today());
			request.Agency__c = childAcc.Id;
			request.Advertiser__c = childAcc.Id;
			insert request;

			ApexPages.StandardController sc = new ApexPages.StandardController(parentAcc);
			ApexPages.currentPage().getParameters().put('Id', parentAcc.id);
			AccountMergeController accountMergerObj = new AccountMergeController(sc);
			ApexPages.currentPage().getParameters().put('childAcc', childAcc.id);
			accountMergerObj.acc.MergeAccount__c = childAcc.id;

			String childAccVal = ApexPages.currentPage().getParameters().get('childAcc');
			system.assertEquals(true, childAccVal != null);
			List<ID> strList = new List<ID> ();
			strList.add(parentAcc.Id);
			strList.add(childAcc.Id);
			//amita

			accountMergerObj.createAccountMergeLog();
			accountMergerObj.parentAccountDetails(parentAcc.id);
			AccountMergeController.getChildAcc(childAcc.id);
			AccountMergeController.verifySelectedAcc(childAcc.id);


			accountMergerObj.createAccountMergeLog();
			//accountMergerObj.getOpportunitiesOwner();
			accountMergerObj.MergeOpportunities();
			accountMergerObj.MergeContacts();
			accountMergerObj.MergeCNA();
			accountMergerObj.MergeRevenue();
			accountMergerObj.MergeTrafficIdElements();
			accountMergerObj.MergeTrade();
			accountMergerObj.MergeAccountConnections();
			accountMergerObj.updateProposals();
			accountMergerObj.updateDigitalCampaigns();
			accountMergerObj.mergeSalesBudget();
			accountMergerObj.MergeSupportRequest();
			accountMergerObj.MergeAccountSAM();
			accountMergerObj.mergeAccountTeam();
			newUser.isActive = false;
			update newAdminUser;
            
			accountMergerObj.getOpportunitiesOwner();
			accountMergerObj.updateBudgets();
			accountMergerObj.updateRecords();
			//System.assertNotEquals(acc.Id, oppList[0].AccountId);
			//System.assertNotEquals(acc.Id, conList[0].AccountId);
			//System.assertNotEquals(acc.Id, accConnectList[0].Account__c);
			//System.assertNotEquals(acc.Id, cnaList[0].Account__c);
			Test.stopTest();
		}
	}

	@isTest
	static void accountMergeNegative()
	{ List<AccountConnection__c> agencyconn = new list<AccountConnection__c> ();
          
		User newAdminUser = TestDataHelper.createSystemAdminUser(true);
		User newUser = TestDataHelper.createUser(true);
		System.runAs(newAdminUser) {
             Test.startTest();
			Account parentAcc = TestDataHelper.createAcc('Account_parent', '122 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');
			insert parentAcc;

			Account acc = TestDataHelper.createAdvertiser('Advertiser Account', '123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');
			Id recTypeAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
			acc.recordTypeid = recTypeAcc;
			acc.MergeAccount__c = parentAcc.id;
			insert acc;

			/*//Create main account
			  Account parentAccAg=TestDataHelper.createAgency('Agency Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
			  //acc.MergeAccount__c = parentAcc.id;
			  insert parentAccAg;
			 
			  //System.assert(parentAcc != null);
			 
			  //Create child account
			  Account childAccAg = TestDataHelper.createAgency('Agency Account_child','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');
			 
			  //Account childAcc = TestDataHelper.createAgency('Agency Account_child','124 Wright Plaza Child', 'Omaha', 'NW', '68131', 'USA');                                            
			  // Account childAcc = TestDataHelper.createAgency('Agency Account_child','124 Wright Plaza', 'Omaha', 'NW', '68131', 'USA'); 
			  //childAcc.MergeAccount__c = parentAcc.id;
			  insert childAccAg;
			  parentAccAg.MergeAccount__c = childAccAg.id;
			  update parentAccAg;
			  //System.assert(childAcc != null);
			 
			  /*AccountConnection__c accConn = TestDataHelper.createAccountConnection(parentAccAg.Id);
			  accConn.Tim_System__c = 'St. Louis Local';
			  agencyconn.add(accConn);
			  insert agencyconn;*/

			//Create account connenction      
			/* AccountConnection__c accConnect = TestDataHelper.createAccountConnection(String.valueOf(parentAccAg.id));
			  agencyconn.add(accConnect);
			  System.debug('accConnectList'+agencyconn +'accConnectList size'+ agencyconn.size());     
			  AccountConnection__c accConnectchild = TestDataHelper.createAccountConnection(String.valueOf(childAccAg.id));
			  agencyconn.add(accConnectchild);        
			  insert agencyconn;*/

			Opportunity opp = TestDataHelper.createopportunity('Test Opportunity1', System.today(), 'Planning', 'Pipeline', parentAcc.id);
			opp.ownerId = newUser.Id;
			insert opp;
			Opportunity childopp = TestDataHelper.createopportunity('Test Opportunity_child1', System.today(), 'Planning', 'Pipeline', acc.id);
			opp.ownerId = newUser.Id;
			insert childopp;

			ApexPages.StandardController sc = new ApexPages.StandardController(acc);
			ApexPages.currentPage().getParameters().put('Id', acc.id);

			AccountMergeController accountMergerObj = new AccountMergeController(sc);
			AccountMergeController.getChildAcc(acc.id);
			accountMergerObj.createAccountMergeLog();

			accountMergerObj.MergeOpportunities();
			accountMergerObj.MergeCNA();
			accountMergerObj.MergeRevenue();
			accountMergerObj.MergeTrafficIdElements();
			accountMergerObj.MergeTrade();

			accountMergerObj.mergeSalesBudget();
			accountMergerObj.MergeSupportRequest();
			accountMergerObj.MergeAccountSAM();
			accountMergerObj.MergeAccountConnections();
			newUser.isActive = false;
			update newAdminUser;
			accountMergerObj.updateProposals();
			accountMergerObj.updateDigitalCampaigns();
			accountMergerObj.getOpportunitiesOwner();
			accountMergerObj.updateBudgets();
			accountMergerObj.updateRecords();
			AccountMergeController accountMergerObj1 = new AccountMergeController(parentAcc.Id);
			AccountMergeController.sendStatusEmail(false);
Test.stopTest();
		}
	}

	@isTest
	static void mergeAgencyAccounts() {
		User newAdminUser = TestDataHelper.createSystemAdminUser(true);
		System.runAs(newAdminUser) {
			Account parentAcc = TestDataHelper.createAgency('Account_parent_Agency', '122 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');
			parentAcc.RecordTypeId = TestDataHelper.agencyRecTypeId;
			insert parentAcc;

			Account acc = TestDataHelper.createAgency('Child Agency', '123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');
			acc.RecordTypeId = TestDataHelper.agencyRecTypeId;

			insert acc;
			parentAcc.MergeAccount__c = acc.id;
			update parentAcc;
			AccountConnection__c accConnectchild = TestDataHelper.createAccountConnection(String.valueOf(acc.id));
			//accConnectList.add(accConnectchild);        
			insert accConnectchild;
			List<Opportunity> oppList = new List<Opportunity> ();
			//Create opportunity       
			Opportunity opp = TestDataHelper.createopportunity('Test Opportunity', System.today(), 'Planning', 'Pipeline', parentAcc.id);
			oppList.add(opp);
			Opportunity childopp = TestDataHelper.createopportunity('Test Opportunity_child', System.today(), 'Planning', 'Pipeline', acc.id);
			oppList.add(childopp);
			insert oppList;

			CNA__c cna_child = TestDataHelper.createCNR(acc.id);
			insert cna_child;

			ApexPages.StandardController sc = new ApexPages.StandardController(parentAcc);
			ApexPages.currentPage().getParameters().put('Id', parentAcc.id);
			//accountMergerObj.parentAccountDetails();
			AccountMergeController.getChildAcc(acc.id);
			AccountMergeController accountMergerObj = new AccountMergeController(parentAcc.Id);
			accountMergerObj.parentAccountDetails(parentAcc.Id);
			accountMergerObj.createAccountMergeLog();
			accountMergerObj.MergeOpportunities();

			accountMergerObj.MergeCNA();
		}
	}

	@isTest
	static void testMergeRepFirmAccounts() {
		User newAdminUser = TestDataHelper.createSystemAdminUser(true);
		System.runAs(newAdminUser) {
			Account parentAcc = TestDataHelper.createAgency('Account_parent_Agency', '122 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');
			parentAcc.RecordTypeId = TestDataHelper.repFirmRecTypeId;
			insert parentAcc;

			Account acc = TestDataHelper.createAgency('Child Agency', '123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');
			acc.RecordTypeId = TestDataHelper.repFirmRecTypeId;
			acc.MergeAccount__c = parentAcc.id;
			insert acc;
			List<Opportunity> oppList = new List<Opportunity> ();

			//Create opportunity       
			Opportunity opp = TestDataHelper.createopportunity('Test Opportunity', System.today(), 'Planning', 'Pipeline', parentAcc.id);
			oppList.add(opp);
			Opportunity childopp = TestDataHelper.createopportunity('Test Opportunity_child', System.today(), 'Planning', 'Pipeline', acc.id);
			oppList.add(childopp);
			insert oppList;

			ApexPages.StandardController sc = new ApexPages.StandardController(acc);
			ApexPages.currentPage().getParameters().put('Id', acc.id);

			AccountMergeController accountMergerObj = new AccountMergeController(sc);
			accountMergerObj.createAccountMergeLog();
			accountMergerObj.MergeOpportunities();
			accountMergerObj.accessError = true;
			accountMergerObj.updateRecords();
		}
	}

	@isTest
	static void PoliticalAccountError()
	{
		User newAdminUser = TestDataHelper.createSystemAdminUser(true);
		System.runAs(newAdminUser) {
			Account parentAcc = TestDataHelper.createAcc('Account_parent', '122 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');
			parentAcc.Primary_Commodity__c = 'Political';
			parentAcc.Commodity_Codes__c = 'POLITICL -- Governor- Independent';
			insert parentAcc;

			Account acc = TestDataHelper.createAdvertiser('Advertiser Account', '123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');
			acc.MergeAccount__c = parentAcc.id;
			insert acc;

			ApexPages.StandardController sc = new ApexPages.StandardController(acc);
			ApexPages.currentPage().getParameters().put('Id', acc.id);

			AccountMergeController accountMergerObj = new AccountMergeController(sc);
			accountMergerObj.createAccountMergeLog();
			accountMergerObj.accessingError(true, 'FieldName');
			AccountMergeController.sendStatusEmail(true);
		}
	}

	@isTest
	public static void TestMergeSyncpFolders() {
		User newAdminUser = TestDataHelper.createSystemAdminUser(true);
		System.runAs(newAdminUser) {
			SyncpIntCustSett.add(new SyncplicityIntegration__c(name = 'Syncplicity',
			                                                   Endpoint__c = 'https://api.syncplicity.com',
			                                                   Password__c = 'cd18cf8f-117f-4f66-acde-d6f1b3291566',
			                                                   SyncAppToken__c = 'FBLti9Bu2UEv8M1JBeJdVE2r55sEs0brphBlOrd9Xt2c32dVxDxZQvKpRbYu32Jq',
			                                                   UserName__c = 'c1d198e2-b351-4910-8a84-d84dfaee688a',
			                                                   APIBatchsize__c = 100,
			                                                   RootFolderSyncpointId__c = '11081799'));
			System.debug('@@@@' + SyncpIntCustSett);
			insert SyncpIntCustSett;

			//Create main account
			Account parentAcc = TestDataHelper.createAdvertiser('Advertiser Account', '123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');
			insert parentAcc;
			System.assert(parentAcc != null);

			//Create child account
			Account childAcc = TestDataHelper.createAdvertiser('Advertiser Account_child', '123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');
			insert childAcc;
			parentAcc.MergeAccount__c = childAcc.id;
			update parentAcc;
			System.assert(childAcc != null);

			//Creating synctable data
			Syncplicity__SyncTable__c syn = new Syncplicity__SyncTable__c();
			syn.Syncplicity__syncpFilesFolderId__c = '123567';
			syn.Syncplicity__syncpEmailId__c = 'Test@test.com';
			syn.Syncplicity__uniqueId__c = 'Test12334';
			syn.Syncplicity__syncpRecordFolderId__c = '382343761';
			syn.Syncplicity__isAdmin__c = 'True';
			syn.Syncplicity__salesforceRecordId__c = parentAcc.Id;
			syn.Syncplicity__salesforceUserId__c = newAdminUser.Id;
			insert syn;
			System.assert(syn != null);

			Syncplicity__SyncTable__c syn1 = new Syncplicity__SyncTable__c();
			syn1.Syncplicity__syncpFilesFolderId__c = '1235678';
			syn1.Syncplicity__syncpEmailId__c = 'Test@test.com';
			syn1.Syncplicity__uniqueId__c = 'Test123345';
			syn1.Syncplicity__syncpRecordFolderId__c = '382419311';
			syn1.Syncplicity__isAdmin__c = 'True';
			syn1.Syncplicity__salesforceRecordId__c = childAcc.Id;
			syn1.Syncplicity__salesforceUserId__c = newAdminUser.Id;
			System.debug('@@@@' + syn1);
			insert syn1;
			System.assert(syn1 != null);

			AccountMergeController accountMergerObj = new AccountMergeController(new ApexPages.StandardController(parentAcc));
			ApexPages.currentPage().getParameters().put('Id', parentAcc.id);
			ApexPages.currentPage().getParameters().put('childAcc', childAcc.id);
			String childAccVal = ApexPages.currentPage().getParameters().get('childAcc');
			system.assertEquals(true, childAccVal != null);
			String parentAccVal = ApexPages.currentPage().getParameters().get('Id');
			system.assertEquals(true, parentAccVal != null);

			AccountMergeController accountMergerObj1 = new AccountMergeController(parentAcc.Id);
			accountMergerObj1.acc.MergeAccount__c = childAcc.id;

			Test.startTest();
			Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock> ();
			SyncplicityWebServiceMock methodName1 = new SyncplicityWebServiceMock('Authentication');
			endpoint2TestResp.put('https://api.syncplicity.com/oauth/token', methodName1);
			SyncplicityWebServiceMock methodName2 = new SyncplicityWebServiceMock('GetFolderContent');
			endpoint2TestResp.put('https://api.syncplicity.com/sync/folder.svc/11081799/folder/382343761?include=active', methodName2);
			SyncplicityWebServiceMock methodName3 = new SyncplicityWebServiceMock('GetSourceFolderContent');
			endpoint2TestResp.put('https://api.syncplicity.com/sync/folder.svc/11081799/folder/382419311?include=active', methodName3);
			SyncplicityWebServiceMock methodName4 = new SyncplicityWebServiceMock('GetFolderContent');
			endpoint2TestResp.put('https://api.syncplicity.com/sync/folder.svc/11081799/folder/382592384?include=active', methodName4);
			SyncplicityWebServiceMock methodName5 = new SyncplicityWebServiceMock('MoveFolders');
			endpoint2TestResp.put('https://api.syncplicity.com/sync/folders.svc/11081799/folders', methodName5);
			SyncplicityWebServiceMock methodName6 = new SyncplicityWebServiceMock('GetFolderContent');
			endpoint2TestResp.put('https://api.syncplicity.com/sync/folder.svc/11081799/folder/382789622?include=active', methodName6);
			SyncplicityWebServiceMock methodName7 = new SyncplicityWebServiceMock('GetFolderContent');
			endpoint2TestResp.put('https://api.syncplicity.com/sync/folder.svc/11081799/folder/383027115?include=active', methodName7);
			SyncplicityWebServiceMock methodName8 = new SyncplicityWebServiceMock('GetFolderContent');
			endpoint2TestResp.put('https://api.syncplicity.com/sync/folder.svc/11081799/folder/383093332?include=active', methodName8);
            //change
            SyncplicityWebServiceMock methodName9 = new SyncplicityWebServiceMock('GetFolderContent');
			endpoint2TestResp.put('https://api.syncplicity.com/sync/folder.svc/11081799/folder/1508934834195001?include=active', methodName9);
            SyncplicityWebServiceMock methodName10 = new SyncplicityWebServiceMock('GetFolderContent');
			endpoint2TestResp.put('https://api.syncplicity.com/sync/folder.svc/11081799/folder/1465949844915001?include=active', methodName10);
            SyncplicityWebServiceMock methodName11 = new SyncplicityWebServiceMock('GetFolderContent');
			endpoint2TestResp.put('https://api.syncplicity.com/sync/folder.svc/11081799/folder/1465949844914001?include=active', methodName11);
            SyncplicityWebServiceMock methodName12 = new SyncplicityWebServiceMock('GetFolderContent');
			endpoint2TestResp.put('https://api.syncplicity.com/sync/folder.svc/11081799/folder/1484145903156001?include=active', methodName12);

			HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
			Test.setMock(HttpCalloutMock.class, multiCalloutMock);
			//------------
			
			//------------
			accountMergerObj1.MergeSyncpFolders();
			Test.StopTest();
		}
	}
}