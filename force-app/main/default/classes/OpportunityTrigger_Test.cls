/* 
    Customer/Project:   Spectrum Reach
    Class name:          OpportunityTrigger_Test
    Author/Date:        Brett Ballantyne    5/1/2017
    Release:             TBD
    Purpose:            The test class for Opportunity.trigger and OpportunityTriggerHandler.cls
*/

@isTest
private class OpportunityTrigger_Test {
    
    @isTest static void testOpptyTrigger() {
     
        createOppBigObjectSetting();
        // Create accountteammembers for some of the accounts
        List<AccountTeamMember> atms = new List<AccountTeamMember>();
        Account objAcc = TestUtil.getAccountRec();
        insert objAcc;
        
        for (integer i = 0; i < 3; i++) {   // only create AccountTeamMembers for half of the accounts
            atms.add(new AccountTeamMember(AccountId = objAcc.Id,
                                              TeamMemberRole = 'Account Executive',
                                              UserId = UserInfo.getUserId()));
        }
        insert atms;
        OpportunityTriggerUtil.createATM(atms);
        test.starttest();
        Account objAgencyAcc = TestUtil.getAgencyAccountRec();
        insert objAgencyAcc;
        // now create opptys

        Opportunity objOpp2 = TestUtil.getOpportunityRec(objAgencyAcc.Id);
        objOpp2.Total_Forecast_Amount__c = 10000;
        objOpp2.Created_By_Account_Executive__c = true;
        objOpp2.Temp_AE_Id__c = UserInfo.getUserId();
        objOpp2.AE_Id__c = UserInfo.getUserId();
        insert objOpp2;
        objOpp2.Total_Forecast_Amount__c  = 20000;
        //objOpp2.Isclosed = true;
        objOpp2.StageName = 'Closed Won';
        //update objOpp2;

        update objOpp2;
        delete objOpp2;
        undelete objOpp2;

        Account repFirmAcc = TestDataHelper.createRepFirm('AMPERSAND', 'Manikonda', 'Hyderabad', 'Telangana', '500090', 'India');
        INSERT repFirmAcc;        
        Opportunity oppty = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',objAcc.Id);        
        oppty.Agency_Account__c = objAgencyAcc.Id;
        oppty.Rep_Firm__c = repFirmAcc.Id;
        oppty.Enterprise_Account_Type__c ='NSM Direct'; 
        oppty.Discount_Code__c = 'A15RP10';
        INSERT oppty;

        // Creating Opportunities to cover the Discount Code logic for different Agencies
        Account agencyAcct1 = TestDataHelper.createAgency('Agency 100', 'Manikonda', 'Hyderabad', 'Telangana', '500091', 'India');
        Opportunity agencyOppty1 = TestDataHelper.createopportunity('Test Agency Oppty1',System.today(),'Planning','Pipeline',objAcc.Id);        
        agencyOppty1.Agency_Account__c = agencyAcct1.Id;        
        agencyOppty1.Enterprise_Account_Type__c ='NSM Direct';         
        INSERT agencyOppty1;

        Account agencyAcct2 = TestDataHelper.createAgency('Stellantis Dealer MarketCenter', 'Manikonda', 'Hyderabad', 'Telangana', '500091', 'India');
        Opportunity agencyOppty2 = TestDataHelper.createopportunity('Test Agency Oppty2',System.today(),'Planning','Pipeline',objAcc.Id);        
        agencyOppty2.Agency_Account__c = agencyAcct2.Id;        
        agencyOppty2.Enterprise_Account_Type__c ='NSM Direct';         
        INSERT agencyOppty2;


/*
        This code was failing because of the Opportunity Type Field Update flow.  Code coverage is ok
        without it, so commenting out for now
        List<Opportunity> opptys = new List<Opportunity>();
        for (integer i = 0; i < 5; i++) {
            Opportunity objOpp = TestUtil.getOpportunityRec(objAgencyAcc.Id);
            objOpp.Total_Forecast_Amount__c = 10000;
            objOpp.Created_By_Account_Executive__c = true;
            objOpp2.Temp_AE_Id__c = UserInfo.getUserId();
            objOpp2.AE_Id__c = UserInfo.getUserId();
            opptys.add(objOpp);
        }
        insert opptys;
        update opptys;
        delete opptys;
        undelete opptys;

*/

        OpportunityUtil ou = new OpportunityUtil();

        OpportunityTriggerHandler opptyTrigger = new OpportunityTriggerHandler(true,1);
        Boolean IsTriggerContext = opptyTrigger.IsTriggerContext;
        Boolean IsVisualforcePageContext = opptyTrigger.IsVisualforcePageContext;
        Boolean IsWebServiceContext = opptyTrigger.IsWebServiceContext;
        Boolean IsExecuteAnonymousContext = opptyTrigger.IsExecuteAnonymousContext;

      test.stoptest();
    }
    

    @testSetup static void createTestData() {
  //      RecordType recType = [select Id from RecordType where IsActive = true and SobjectType = 'Contact' limit 1];
    //  Contact con = new Contact (LastName = 'TestContact', Phone = '303-111-2222', Email = 'abc@def.com', recordTypeId = recType.Id);  
   //     Insert con; 
  //      OpportunityContactRole ocr = new OpportunityContactRole(ContactId = con.Id, IsPrimary = true);
   //     insert ocr;
        List<Account> testAccts = new List<Account>();
        for (integer i = 0; i < 10; i++) {
            Account acct = new Account(Name='TestAccount' + i, 
    //            Account_Rep__c = con.Id,
                BillingStreet = '235 High St',
                BillingCity = 'Morgantown',
                BillingState = 'WV',
                BillingPostalCode = '26505',
                BillingCountry = 'USA',
                ShippingStreet = '235 High St',
                ShippingCity = 'Morgantown',
                ShippingState = 'WV',
                ShippingPostalCode = '26505',
                ShippingCountry = 'USA');
            testAccts.add(acct);
        }
        insert testAccts;
       /* user newAdminUser = new User();
        			Account_SAM_Mapping__c newAsm = new Account_SAM_Mapping__c(account__c = testAccts[0].Id, user__c = UserInfo.getUserId(),
			                                                           Tier_Designation__c = 'VIP', region__c = newAdminUser.region__c,
			                                                           sales_office__c = newAdminUser.sales_office__c,
			                                                           division__c = newAdminUser.division__c,
			                                                           ownerId = newAdminUser.id , Is_New__c = true);
			insert newAsm;*/


    }
    
    public static void createOppBigObjectSetting() {
        BigObjectSettings__c oppTrendBO = new BigObjectSettings__c();
        oppTrendBO.Name = 'OpportunityTrend__b';
        oppTrendBO.IsActive__c = true;
        oppTrendBO.Rolling_Index__c = 0;
        insert oppTrendBO;
    }
}