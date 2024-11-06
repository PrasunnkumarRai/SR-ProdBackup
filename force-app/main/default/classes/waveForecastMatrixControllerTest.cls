/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
// NOTE: ADDED LOGIC TO GET COVERAGE FOR waveForecastMatrixControllerClone BACKUP COPY AS WELL
@isTest
private class waveForecastMatrixControllerTest {
    static String year;
    static User u;
    static User usr;
    static Budget__c budget1;
    static Account acc;
    static User usrpro;     
    static Opportunity opp; 
    static UserRole usrRole1;
    static String chosenUser;

    static testMethod void prepareTestData() {         
        User stan_user=TestDataHelper.createUser(true);
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.runAs(u){
            //Advertiser Account
            acc = TestDataHelper.createAdvertiser('Test Account', '2912 Petit ST', 'Camarello', 'CA', '96012', 'US');
            acc.Spectrum_Reach_Preferred__c=true;   
            INSERT acc;
            System.assert(acc != null);
            
            //Agency Account
            Account Agencytest =TestDataHelper.createAgency('Test AgencyAccount','Manikonda','Hyderabad','Telangana','500084','India');
            Agencytest.Spectrum_Reach_Preferred__c=true;                          
            INSERT Agencytest;
            
            //Create an opportunity on the above created account
            opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.Id);
            opp.Agency_Account__c=Agencytest.Id;
            opp.OwnerId = stan_user.Id;     
            INSERT opp;
            
            //create a proposal on above created Opportunity
            Proposal__c proposal = TestDataHelper.createProposal('Test Opportunity Proposal',opp.Id, '00000', true); 
            proposal.Traffic_Order_Number__c  = '1111,3425';
            proposal.Advertiser__c = acc.Id;
            INSERT proposal;
            
            List<Traffic_Id_Element__c> tIdLIst = new List<Traffic_Id_Element__c>();
            // create Traffic Id Element for Account
            Traffic_Id_Element__c trafficElementAcc = TestDataHelper.createTrafficIdElement(acc.Id,NULL,'1','2222');
            tIdLIst.add(trafficElementAcc);
            
            // create Traffic Id Element for User
            Traffic_Id_Element__c trafficElementUser = TestDataHelper.createTrafficIdElement(NULL,stan_user.Id,'1','3333');
            tIdLIst.add(trafficElementUser);
            INSERT tIdLIst;
        }
    }

    static testMethod void prepareTestDataManager() {
        User u = TestDataHelper.getBoomiIntegrationUser();
        prepareTestData();
        System.runAs(u){
            TestDataHelper.createBudgetEntryYear();
            TestDataHelper.createTIMIntegrationCustomSettings();     
            TestDataHelper.createSysCodeManualProposalCreationCustomSettings();    
            
            UserRole usrRole = new UserRole(Name = 'LSM');
            INSERT usrRole;

            usrRole1 = new UserRole(Name = 'test',ParentRoleID = usrRole.Id );
            INSERT usrRole1; 
            Test.StartTest(); 
            usr = TestDataHelper.createUser (false);
            usr.username = 'user123@testorgosius.com';
            usr.UserRoleId=usrRole1.Id;    
            INSERT usr;         

            // Start: 26-08-2019
            Profile nsmProf = [SELECT Id FROM Profile WHERE Name = 'Master - National Sales Manager'];
            UserRole nsmRole = new UserRole(Name = 'NSM');
            INSERT nsmRole;

            User nsmUsr = new User(alias = 'usr', email = 'nsmuser@charter.com',
                emailencodingkey = 'UTF-8', lastname = 'TestingNSM', languagelocalekey = 'en_US',
                localesidkey = 'en_US', profileid = nsmProf.Id, UserRoleId=nsmRole.Id,isActive = true,
                timezonesidkey = 'America/Los_Angeles', username = 'nsmuser@testorgosius.com',Budget_Type__c = 'National'); 
            INSERT nsmUsr;

            TestDataHelper.createGlidMapping(nsmUsr);
            // End: 26-08-2019

            Revenue_Type_Mapping__c rtm = new Revenue_Type_Mapping__c();
            rtm.Name = 'Core';
            rtm.Available_Revenue_Type__c = 'Core,National Core';
            INSERT rtm;

            Budget__c budget = TestDataHelper.createBudget(System.Today(),1000.00,'SRNews',usr.Id,acc.Id,'Approved'); 
            budget.OwnerId = u.Id;
            budget.Status__c = 'Not Submitted';
            budget.Start_Month_N__c = 4;
            budget.End_Month_N__c = 12;
            INSERT budget;
            System.assert(budget.Id != null);

            //SRSF-2072: Changed from Budget__c to Sales_Budget__c
            /*Sales_Budget__c salesBudget = TestDataHelper.createSalesBudget(System.Today(),1000.00,'Linear/News/Sports',usr.Id,acc.Id,'Final Approval'); 
            salesBudget.ownerId = u.Id;
            salesBudget.Status__c = 'Not Submitted';
            insert salesBudget;
            system.assert(salesBudget.Id != null);*/
             //CreateRevenue
            Revenue__c  revenue = TestDataHelper.createRevenue('2222', '3333', System.today().addYears(-1), 1000, 1000, 0, 0, '1');
            revenue.Revenue_Type__c = 'Core';
            revenue.ContractNumber__c = 1111;
            revenue.Account_Executive__c = u.Id;
            revenue.Actual_Gross_Amount__c = 433.33;
            revenue.Projected_Gross_Amount__c = 400;
            revenue.Product_Line__c = 'Linear';
            revenue.Advertiser__c = acc.Id;
            INSERT revenue; 
        //  Test.StartTest();        
            System.assert(revenue.Id != null);
            //Create proposal
            Proposal__c prop = TestDataHelper.createProposal('Test Opportunity Proposal',opp.Id, '00000', true);
            prop.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
            prop.Start_Date__c = System.today();
            prop.End_Date__c = System.today().addMonths(1);
            INSERT prop;
            //Create proposal zone
            Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Proposal Zone',prop.Id);
            propZone.Status_Type__c = 'Pending';
            INSERT propZone;
            //Create proposal zone monthly value
            Proposal_Zone_Monthly_Value__c propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value',acc.Id,propZone.Id);
            propZoneMonthly.Schedule_Type__c = 'Production';
            propZoneMonthly.Proposal_Key_Index__c = prop.Id;
            propZoneMonthly.Broadcast_Month_Date__c = System.today().adddays(1);
            propZoneMonthly.Net_Amount__c = 100.00;
            INSERT propZoneMonthly;

            PageReference myVfPage = Page.waveForecastMatrix;
            Test.setCurrentPageReference(myVfPage);
            ApexPages.currentPage().getParameters().put('userId', nsmUsr.Id);  //Changed from u.Id to nsmusr.Id : 26-08-2019
            ApexPages.currentPage().getParameters().put('selectedGlidoption', 'Albany NY'); //  26-08-2019
            Set<Id> userIds = new Set<Id>();
            userIds.add(usr.Id);
            
            Proposal_Zone_Monthly_Value__c pzmv = [SELECT Schedule_Type__c, Advertiser__r.Name, Advertiser__c, Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c,Proposal_Zone__r.Proposal__r.Opportunity__r.Account.Political_Account__c , Proposal_Zone__r.Proposal__r.Opportunity__r.OwnerId, Proposal_Zone__r.Proposal__r.RecordTypeId, Year__c, Proposal_Zone__r.Proposal__r.Opportunity__r.isClosed, Net_Amount__c, Broadcast_Month_Date__c FROM Proposal_Zone_Monthly_Value__c LIMIT 10];
            System.debug('pzmv---->'+pzmv);
                              
            waveForecastMatrixController cp = new waveForecastMatrixController();
            waveForecastMatrixControllerClone cp1 = new waveForecastMatrixControllerClone();
            /*INSERT TestDataHelper.createProposal('Test Opportunity Proposal2',opp.Id, '00001', true);*/
            
            Test.StopTest();
        }
    }

    /*Added by Srikanth */
    static testMethod void prepareTestDataMasterBillingProfile() { 
        TestDataHelper.createTIMIntegrationCustomSettings();        
        User intUser = TestDataHelper.getBoomiIntegrationUser();
        Profile p = [SELECT Id FROM Profile WHERE Name='Master - FBO'];

        User u1 = new User(Alias = 'standt1',ManagerID = intUser.Id,Country='United Kingdom',Email='demo1@charter.com',EmailEncodingKey='UTF-8', LastName='TestingFBO', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', isActive = true, UserName='dprobertdemo127@camfed127.org');              
        INSERT u1;
        System.assert(u1 != null);
        Map<String,String> globalParentChildUserMap = new Map<String,String>();
        globalParentChildUserMap.put(u1.Id,u1.ManagerId);
        prepareTestData();
        System.runAs(u1){       
            Test.StartTest();               
            waveForecastMatrixController cp = new waveForecastMatrixController();         
            cp.getUsersList();

            waveForecastMatrixControllerClone cp1 = new waveForecastMatrixControllerClone();
            cp1.getUsersList();
            Test.StopTest();
        }
    }
    
    static testMethod void prepareTestDataSysAdmProfile() { 
        User u1 = TestDataHelper.createSystemAdminUser(false);
        INSERT u1;
        System.assert(u1 != null);
        prepareTestData();
        System.runAs(u1){           
            Test.StartTest();
            waveForecastMatrixController cp = new waveForecastMatrixController();
            cp.getUsersList();

            waveForecastMatrixControllerClone cp1 = new waveForecastMatrixControllerClone();
            cp1.getUsersList();
            Test.StopTest();
        }
    }

    static testMethod void prepareTestDataGridData() {                
        User u = TestDataHelper.getBoomiIntegrationUser();
        prepareTestData();
        System.runAs(u){
            TestDataHelper.createBudgetEntryYear();
            TestDataHelper.createTIMIntegrationCustomSettings();      
            TestDataHelper.createSysCodeManualProposalCreationCustomSettings();    
          
            UserRole usrRole1 = new UserRole(Name = 'LSM');
            INSERT usrRole1;
            System.assert(usrRole1 != null);

            UserRole usrRole2 = new UserRole(Name = 'ParentRoleId',ParentRoleID = usrRole1.Id );
            INSERT usrRole2;            
           
            User usr12 = TestDataHelper.createUser(false);
            usr12.username = 'user1234@testorgosius.com'; 
            usr12.UserRoleId=usrRole2.Id;   
            INSERT usr12;
            System.debug('usr12.Id::'+usr12.Id);
                                       
            SysCodeManualProposalCreation__c cs = new SysCodeManualProposalCreation__c(Name='Digital',Name__c = 'DigitalSysCode',Value__c = '0');                
            INSERT cs;
        }
    }
    
    static testMethod void prepareTestDataBilling() {         
        User u = TestDataHelper.getBoomiIntegrationUser();
        prepareTestData();

        System.runAs(u){
            test.startTest();
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Master - FBO'];
            UserRole usrRole = new UserRole(Name = 'LSM');
            INSERT usrRole;

            usrRole1 = new UserRole(Name = 'test',ParentRoleID = usrRole.Id );
            INSERT usrRole1;
            System.assert(usrRole1 != null);            
     
            usr = TestDataHelper.createUser(false);
            usr.username = 'user123@testorgosius.com';
            usr.profileid = p.Id;
            usr.UserRoleId=usrRole.Id;    
            INSERT usr;
          
            Id accBudgetRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName !='Competitor Account' LIMIT 1].Id;
            acc.RecordTypeId = accBudgetRecTypeId;

            Budget__c budget = TestDataHelper.createBudget(System.Today(),1000.00,'SRNews',u.Id,acc.Id,'Approved'); 
            budget.ownerId = u.Id;
            budget.Status__c = 'Not Submitted';
            INSERT budget;

            /*SRSF-2072: Changed from Budget__c to Sales_Budget__c
            Sales_Budget__c salesBudget = TestDataHelper.createSalesBudget(System.Today(),1000.00,'Linear/News/Sports',usr.Id,acc.Id,'Final Approval'); 
            salesBudget.ownerId = u.Id;
            salesBudget.Status__c = 'Not Submitted';
            insert salesBudget;
            system.assert(salesBudget.Id != null);*/

             //CreateRevenue
            Revenue__c  revenue = TestDataHelper.createRevenue('2222', '3333', System.today(), 1000, 1000, 0, 0, '1');
            revenue.Revenue_Type__c = 'Core';
            revenue.ContractNumber__c = 1112;
            revenue.Account_Executive__c = u.Id;
            INSERT revenue;
           // Test.StartTest();
            //Create proposal
            Proposal__c prop = TestDataHelper.createProposal('Test Opportunity Proposal',opp.Id, '00000', true);
            prop.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
            prop.Start_Date__c = System.today();
            prop.End_Date__c = System.today().addMonths(1);
            INSERT prop;
            
            //Create proposal zone
            Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Proposal Zone',prop.Id);
            INSERT propZone;
            
            //Create proposal zone monthly value
            Proposal_Zone_Monthly_Value__c propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value',acc.Id,propZone.Id);
            propZoneMonthly.Schedule_Type__c = 'Production';
            propZoneMonthly.Proposal_Key_Index__c = prop.Id;
            propZoneMonthly.Broadcast_Month_Date__c = System.today().adddays(1);
            INSERT propZoneMonthly;
            
            ApexPages.currentPage().getParameters().put('userId', u.Id);
            Set<Id> userIds = new Set<Id>();
            userIds.add(u.Id);

            Cookie userCookie = new Cookie('userSelection', usr.Id,null,-1,false);
            ApexPages.currentPage().setCookies(new Cookie[]{userCookie});
                               
            waveForecastMatrixController cp = new waveForecastMatrixController();                           
            cp.getUsersList(); 

            waveForecastMatrixControllerClone cp1 = new waveForecastMatrixControllerClone();
            cp1.getUsersList();            
            Test.StopTest();
        }
    }

    /*@IsTest(seeAlldata = true)
    static void prepareTestDataAE() { */
    static testMethod void prepareTestDataAE() {
        User u = TestDataHelper.getBoomiIntegrationUser();
        
        System.runAs(u){
            // To get Division & Region from Custom Metadatatype
            //Map<String,String> TestData = TestDataHelper.fetchDivisions();            
            //test.startTest();
            
            UserRole usrRole = new UserRole(Name = 'Manager');
            INSERT usrRole;
           /* UserRole usrRole1 = new UserRole(Name = 'LSM');
            INSERT usrRole1;

            usrRole1 = new UserRole(Name = 'test',ParentRoleID = usrRole.Id );
            INSERT usrRole1;
            System.assert(usrRole1 != null);*/            
            
            usrpro = TestDataHelper.createSystemAdminUser(false);
            usrpro.UserRoleId = usrRole.Id;
            usrpro.Division__c='Central';
            INSERT usrpro;
            System.debug('usrpro::'+usrpro.Id);

            SysCodeManualProposalCreation__c cs = new SysCodeManualProposalCreation__c(Name='Digital', Name__c= 'DigitalSysCode',Value__c= '0');                
            INSERT cs;

        //  test.startTest();
            Account acc = new Account(Name='Test Account',Commodity_Codes__c='  ADV_MKG -- Marketing',SAM_Designation__c='Extra', BillingStreet='Harizona',Billingcity='CA',BillingState='KA',BillingPostalCode='12233',BillingCountry='USA', Primary_Commodity__C = 'Media', Spectrum_Reach_Preferred__c=true);
            INSERT acc;
            List<AccountShare> share = new List<AccountShare>();
            AccountShare accountShare = new AccountShare();
            accountShare.AccountId = acc.Id;
            accountShare.UserOrGroupId = usrpro.Id;
            accountShare.AccountAccessLevel = 'Edit';            
            accountShare.CaseAccessLevel = 'Edit';
            accountShare.OpportunityAccessLevel = 'Edit';
            share.add(accountShare);    
            INSERT share;

            System.debug('acc.ID:::'+acc.Id);
            
            Budget__c budget = TestDataHelper.createBudget(System.Today(),1000.00,'SRNews',usrpro.Id,acc.Id,'Approved'); 
            budget.OwnerId = usrpro.Id;
            budget.Status__c = 'Not Submitted';
            budget.Account__c= acc.Id;
            budget.Start_Month_N__c = 4;
            budget.End_Month_N__c = 12;
            INSERT budget;

            /*SRSF-2072: Changed from Budget__c to Sales_Budget__c
            Sales_Budget__c salesBudget = TestDataHelper.createSalesBudget(System.Today(),1000.00,'Linear/News/Sports',usrpro.Id,acc.Id,'Final Approval'); 
            salesBudget.ownerId = usrpro.Id;
            salesBudget.Status__c = 'Not Submitted';
            insert salesBudget;
            system.assert(salesBudget.Id != null);*/

             //CreateRevenue
            Revenue__c  revenue = TestDataHelper.createRevenue('2222', '3333', System.today(), 1000, 1000, 0, 0, '1');
            revenue.Revenue_Type__c = 'Core';
            revenue.Advertiser__c = acc.Id;
            revenue.ContractNumber__c = 1111;
            revenue.Account_Executive__c = usrpro.Id;
            INSERT revenue;

            Account Agencytest =TestDataHelper.createAcc('Test AgencyAccount','Manikonda','Hyderabad','Telangana','500084','India');
            Agencytest.Spectrum_Reach_Preferred__c=true; 
            Agencytest.RecordTypeId= TestDataHelper.agencyRecTypeId; 
            INSERT Agencytest;            
        
            Opportunity oppr =new Opportunity(Name='Test Opp', CloseDate=System.today().addMonths(1),
                AccountId=acc.Id, Agency_Account__c= Agencytest.Id);
            oppr.StageName= 'Identification';           
            INSERT oppr;
         // test.startTest();
            oppr.StageName= 'Closed Won';
            oppr.OwnerId = usrpro.Id; 
            oppr.Sales_Probability__c= '100';
            UPDATE oppr;
            System.debug(' ### opp salesProbability :::: ' +oppr.Sales_Probability__c);
            RecordType rt = [SELECT Id, Name FROM RecordType WHERE Name ='Linear'];
            System.debug('rt Linear::'+rt.Name);
            Test.startTest();
            //Create proposal
            Proposal__c prop = new Proposal__c(Name ='Test Opportunity Proposal',Opportunity__c = oppr.Id,
                RecordTypeId = rt.Id,Start_Date__c = System.today(),End_Date__c = System.today().addMonths(1),TIM_Id__c='00000',Active__c = true);
            INSERT prop;
            
            Group__c grp = new Group__c(Name='Test Group', Group_Id__C = '123', TIM_System__c = 'St. Louis Local');
            INSERT grp;
            Group_Status__c groupStatus = new Group_Status__c();
            groupStatus.Name = 'Submitted to Traffic';
            groupStatus.Is_Active__c = true;
            groupStatus.Is_Entry__c = true;
            groupStatus.Is_Rejection__c = false;
            groupStatus.Group__c = grp.Id;
            INSERT groupStatus;

            //Create proposal zone          
            Proposal_Zone__c propZone = new Proposal_Zone__c(Name='Test Proposal Zone',Proposal__c=prop.Id,Status_Type__c = 'Pending');
            propZone.TIM_Status__c='Submitted to Traffic';
            INSERT propZone;
                   
            //Create proposal zone monthly value
            Proposal_Zone_Monthly_Value__c propZoneMonthly =new Proposal_Zone_Monthly_Value__c(Name ='Test Proposal Zone Monthly Value',Advertiser__c=acc.Id,
                Proposal_Zone__c=propZone.Id,Schedule_Type__c='Linear',Proposal_Key_Index__c=prop.Id,Broadcast_Month_Date__c=System.today().adddays(1));
            // propZoneMonthly.Net_Amount__c = 100;
            propZoneMonthly.Gross_Amount__c = 300;
            // propZoneMonthly.Net_of_Agency__c = 200;
            propZoneMonthly.Proposal_Key_Index__c = prop.Id;
            INSERT propZoneMonthly;                

            PageReference myVfPage = Page.waveForecastMatrix;
            Test.setCurrentPageReference(myVfPage);
            ApexPages.currentPage().getParameters().put('userId', usrpro.Id);
            ApexPages.currentPage().getParameters().put('selYear', String.valueOf(System.today().year()));
                
            Set<Id> userIds = new Set<Id>();
         // Test.startTest();          
            waveForecastMatrixController cp = new waveForecastMatrixController();
            cp.chosenDMAoption = 'All';          
            cp.getUsersList();
            cp.getFiscalYear();
            // cp.fetchChildUserIds();  
            // cp.fetchBudgetData();
            cp.getGridData();
            // cp.calculateQuarterlyTotals();
            cp.getPerformanceLabels();
            // cp.calculateAllPerformancePercentage();
            waveForecastMatrixController.productTypeWrapper tstPrdct2 = new waveForecastMatrixController.productTypeWrapper();
            //insert TestDataHelper.createProposal('Test Opportunity Proposal2',oppr.id, '00001', true);  
            //START: SRSF-3393 
            cp.selectedRowType = 'Booked';
            cp.accGroupMapJSON = '{"Test Account":[{"prodType":"Linear/News/Sports","forecastWrpSize":2,"forecastWrpList_prod":[{"totalRowAmount":1000,"rowType":"Booked","quarterlyTotalsAcctwise":[1000,0,0,0],"monthsData":[0,1000,0,0,0,0,0,0,0,0,0,0]},{"totalRowAmount":255,"rowType":"Pending","quarterlyTotalsAcctwise":[255,0,0,0],"monthsData":[0,255,0,0,0,0,0,0,0,0,0,0]}],"Accid":"0017X00000r0ISsQAM"},{"prodType":"Total","forecastWrpSize":1,"forecastWrpList_prod":[{"totalRowAmount":1255,"rowType":"Total","quarterlyTotalsAcctwise":[1255,0,0,0],"monthsData":[0,1255,0,0,0,0,0,0,0,0,0,0]}],"Accid":"0017X00000r0ISsQAM"},{"prodType":"Booked_Total","forecastWrpSize":1,"forecastWrpList_prod":[{"totalRowAmount":1000,"rowType":"Booked_Total","quarterlyTotalsAcctwise":[1000,0,0,0],"monthsData":[0,1000,0,0,0,0,0,0,0,0,0,0]}],"Accid":"0017X00000r0ISsQAM"},{"prodType":"Pending_Total","forecastWrpSize":1,"forecastWrpList_prod":[{"totalRowAmount":255,"rowType":"Pending_Total","quarterlyTotalsAcctwise":[255,0,0,0],"monthsData":[0,255,0,0,0,0,0,0,0,0,0,0]}],"Accid":"0017X00000r0ISsQAM"},{"prodType":"Projected_Total","forecastWrpSize":1,"forecastWrpList_prod":[{"totalRowAmount":0,"rowType":"Projected_Total","quarterlyTotalsAcctwise":[0,0,0,0],"monthsData":[0,0,0,0,0,0,0,0,0,0,0,0]}],"Accid":"0017X00000r0ISsQAM"}]}'; 
            cp.populateAcctsDataOnRowTypeSelection();
            //END : SRSF-3393

            PageReference myVfPageClone = Page.waveForecastMatrixClone;
            Test.setCurrentPageReference(myVfPageClone);
            ApexPages.currentPage().getParameters().put('userId', usrpro.Id);
            ApexPages.currentPage().getParameters().put('selYear', String.valueOf(System.today().year()));
            waveForecastMatrixControllerClone cp1 = new waveForecastMatrixControllerClone();
            cp1.chosenDMAoption = 'All';          
            cp1.getUsersList();
            cp1.getFiscalYear();
            cp1.getGridData();
            cp1.getPerformanceLabels();            
            cp1.selectedRowType = 'Booked';
            cp1.accGroupMapJSON = '{"Test Account":[{"prodType":"Linear/News/Sports","forecastWrpSize":2,"forecastWrpList_prod":[{"totalRowAmount":1000,"rowType":"Booked","quarterlyTotalsAcctwise":[1000,0,0,0],"monthsData":[0,1000,0,0,0,0,0,0,0,0,0,0]},{"totalRowAmount":255,"rowType":"Pending","quarterlyTotalsAcctwise":[255,0,0,0],"monthsData":[0,255,0,0,0,0,0,0,0,0,0,0]}],"Accid":"0017X00000r0ISsQAM"},{"prodType":"Total","forecastWrpSize":1,"forecastWrpList_prod":[{"totalRowAmount":1255,"rowType":"Total","quarterlyTotalsAcctwise":[1255,0,0,0],"monthsData":[0,1255,0,0,0,0,0,0,0,0,0,0]}],"Accid":"0017X00000r0ISsQAM"},{"prodType":"Booked_Total","forecastWrpSize":1,"forecastWrpList_prod":[{"totalRowAmount":1000,"rowType":"Booked_Total","quarterlyTotalsAcctwise":[1000,0,0,0],"monthsData":[0,1000,0,0,0,0,0,0,0,0,0,0]}],"Accid":"0017X00000r0ISsQAM"},{"prodType":"Pending_Total","forecastWrpSize":1,"forecastWrpList_prod":[{"totalRowAmount":255,"rowType":"Pending_Total","quarterlyTotalsAcctwise":[255,0,0,0],"monthsData":[0,255,0,0,0,0,0,0,0,0,0,0]}],"Accid":"0017X00000r0ISsQAM"},{"prodType":"Projected_Total","forecastWrpSize":1,"forecastWrpList_prod":[{"totalRowAmount":0,"rowType":"Projected_Total","quarterlyTotalsAcctwise":[0,0,0,0],"monthsData":[0,0,0,0,0,0,0,0,0,0,0,0]}],"Accid":"0017X00000r0ISsQAM"}]}'; 
            cp1.populateAcctsDataOnRowTypeSelection();

            Test.StopTest();
            cp.accNameparam = 'Test';
            cp.politicalFilter = '';
            cp.tradeFilter = '';

            // cp.calculatePerformancePercentage();
            // cp.calculatePercentage(new List<Decimal>{1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0}, new List<Decimal>{11.0,12.0,0.13,14.0,15.0,16.0,17.0,18.0,19.0,20.0,21.0,22.0,23.0}, 'Linear');
        }
    }

    static testMethod void Negativetestmethod(){                 
        
        UserRole usrRole = new UserRole(Name = 'AE1');
        INSERT usrRole;
        usrRole1 = new UserRole(Name = 'test1',ParentRoleID = usrRole.Id );
        INSERT usrRole1;
        System.assert(usrRole1 != null);        
        
        usr = TestDataHelper.createSystemAdminUser(false);
        usr.UserRoleId=usrRole1.Id;             
        INSERT usr;        
     
        PageReference myVfPage = Page.waveForecastMatrix;
        Test.setCurrentPageReference(myVfPage);
        ApexPages.currentPage().getParameters().put('userId',' ');
        ApexPages.currentPage().getParameters().put('yearSelection', null);
        ApexPages.currentPage().getParameters().put('selYear', String.valueOf(System.today().year()));
        ApexPages.currentPage().getParameters().put('selProduct','Political & Trade');
        ApexPages.currentPage().getParameters().put('selSalesProb','10');
        
        waveForecastMatrixController cp = new waveForecastMatrixController();                                         
        cp.getUsersList();
        cp.getFiscalYear();
        // cp.fetchChildUserIds();  
        cp.fetchBudgetData();
        cp.fetchProjectedProposalZoneMonthlyValues();  

        PageReference myVfPageClone = Page.waveForecastMatrixClone;
        Test.setCurrentPageReference(myVfPageClone);
        ApexPages.currentPage().getParameters().put('userId',' ');
        ApexPages.currentPage().getParameters().put('yearSelection', null);
        ApexPages.currentPage().getParameters().put('selYear', String.valueOf(System.today().year()));
        ApexPages.currentPage().getParameters().put('selProduct','Political & Trade');
        ApexPages.currentPage().getParameters().put('selSalesProb','10');
        waveForecastMatrixControllerClone cp1 = new waveForecastMatrixControllerClone();
        cp1.getUsersList();
        cp1.getFiscalYear();    
        cp1.fetchBudgetData();
        cp1.fetchProjectedProposalZoneMonthlyValues();
    }

    static testMethod void testAggregatequerycover(){
        User u = TestDataHelper.getBoomiIntegrationUser();
        
        System.runAs(u){
            //test.startTest();            

            UserRole usrRole = new UserRole(Name = 'Manager');
            INSERT usrRole;
            UserRole usrRole1 = new UserRole(Name = 'LSM');
            INSERT usrRole1;

            /*usrRole1 = new UserRole(Name = 'test',ParentRoleID = usrRole.Id );
            insert usrRole1;
            System.assert(usrRole1 != null);*/            
            
            usrpro = TestDataHelper.createSystemAdminUser(false);     
            usrpro.UserRoleId = usrRole.Id;
            INSERT usrpro;
            System.debug('usrpro::'+usrpro.Id);        

            SysCodeManualProposalCreation__c cs = new SysCodeManualProposalCreation__c(Name='Digital', Name__c= 'DigitalSysCode',Value__c= '0');                
            INSERT cs;

        //  test.startTest();
            Account acc = new Account(Name='Test Account',Commodity_Codes__c='  ADV_MKG -- Marketing',SAM_Designation__c='Extra',BillingStreet='Harizona',Billingcity='CA', BillingState='KA',BillingPostalCode='12233',BillingCountry='USA', Primary_Commodity__C = 'Media', Spectrum_Reach_Preferred__c=true);
            INSERT acc;
            List<AccountShare> share = new List<AccountShare>();
            AccountShare accountShare = new AccountShare();
            accountShare.AccountId = acc.Id;
            accountShare.UserOrGroupId = usrpro.Id;
            accountShare.AccountAccessLevel = 'Edit';
            //accountShare.ContactAccessLevel = 'Edit';
            accountShare.CaseAccessLevel = 'Edit';
            accountShare.OpportunityAccessLevel = 'Edit';
            share.add(accountShare);    
            INSERT share;

            System.debug('acc.ID:::'+acc.Id);
            
            Budget__c budget = TestDataHelper.createBudget(System.Today(),1000.00,'SRNews',usrpro.Id,acc.Id,'Approved'); 
            budget.ownerId = usrpro.Id;
            budget.Status__c = 'Not Submitted';
            budget.Account__c= acc.Id;
            budget.Start_Month_N__c = 4;
            budget.End_Month_N__c = 12;
            INSERT budget;

            /*SRSF-2072: Changed from Budget__c to Sales_Budget__c
            Sales_Budget__c salesBudget = TestDataHelper.createSalesBudget(System.Today(),1000.00,'Linear/News/Sports',usrpro.Id,acc.Id,'Final Approval'); 
            salesBudget.ownerId = usrpro.Id;
            salesBudget.Status__c = 'Not Submitted';
            insert salesBudget;
            system.assert(salesBudget.Id != null);*/

            //CreateRevenue
            Revenue__c  revenue = TestDataHelper.createRevenue('2222', '3333', System.today(), 1000, 1000, 0, 0, '1');
            revenue.Revenue_Type__c = 'Core';
            revenue.Advertiser__c = acc.Id;
            revenue.ContractNumber__c = 1111;
            revenue.Account_Executive__c = usrpro.Id;
            INSERT revenue;

            Account Agencytest =TestDataHelper.createAcc('Test AgencyAccount','Manikonda','Hyderabad','Telangana','500084','India');
            Agencytest.Spectrum_Reach_Preferred__c=true; 
            Agencytest.RecordTypeId= TestDataHelper.agencyRecTypeId; 
            INSERT Agencytest;            
            
            Opportunity oppr =new Opportunity(Name='Test Opp', CloseDate=System.today().addMonths(1),
                AccountId=acc.Id, Agency_Account__c= Agencytest.Id);
            oppr.StageName= 'Identification';            
            oppr.OwnerId = usrpro.Id; 
            INSERT oppr;
            test.startTest();
            RecordType rt = [SELECT Id, Name FROM RecordType WHERE Name ='Opportunity Budget'];
            System.debug('rt Name ::'+rt.Name);
            //Create proposal
            Proposal__c prop = new Proposal__c(Name ='Test Opportunity Proposal',Opportunity__c = oppr.Id,
                RecordTypeId = rt.Id,Start_Date__c = System.today(),End_Date__c = System.today().addMonths(1),
                TIM_Id__c='00000',Active__c = true);
            INSERT prop;
            
            Group__c grp = new Group__c(Name='Test Group', Group_Id__C = '123', TIM_System__c = 'St. Louis Local');
            INSERT grp;
            Group_Status__c groupStatus = new Group_Status__c();
            groupStatus.Name = 'Submitted to Traffic';
            groupStatus.Is_Active__c = true;
            groupStatus.Is_Entry__c = true;
            groupStatus.Is_Rejection__c = false;
            groupStatus.Group__c = grp.Id;
            INSERT groupStatus;

            //Create proposal zone          
            Proposal_Zone__c propZone = new Proposal_Zone__c(Name='Test Proposal Zone',Proposal__c=prop.Id,Status_Type__c = 'Pending');
            propZone.TIM_Status__c='Submitted to Traffic';
            INSERT propZone;
                   
            //Create proposal zone monthly value
            Proposal_Zone_Monthly_Value__c propZoneMonthly =new Proposal_Zone_Monthly_Value__c(Name ='Test Proposal Zone Monthly Value',Advertiser__c=acc.Id,
                Proposal_Zone__c=propZone.Id,Schedule_Type__c='Linear',Proposal_Key_Index__c=prop.Id,Broadcast_Month_Date__c=System.today().adddays(1));
            // propZoneMonthly.Net_Amount__c = 100;
            propZoneMonthly.Gross_Amount__c = 300;
            // propZoneMonthly.Net_of_Agency__c = 200;
            propZoneMonthly.Proposal_Key_Index__c = prop.Id;
            INSERT propZoneMonthly;         

            PageReference myVfPage = Page.waveForecastMatrix;
            Test.setCurrentPageReference(myVfPage);
            ApexPages.currentPage().getParameters().put('userId', usrpro.Id);           
            ApexPages.currentPage().getParameters().put('selYear', String.valueOf(System.today().year()));
                
            Set<Id> userIds = new Set<Id>();
                        
            waveForecastMatrixController cp = new waveForecastMatrixController();         
            cp.getUsersList();
            cp.getFiscalYear();
            // cp.fetchChildUserIds();  
        //  cp.fetchBudgetData();
            cp.getGridData();

            PageReference myVfPageClone = Page.waveForecastMatrixClone;
            Test.setCurrentPageReference(myVfPageClone);
            ApexPages.currentPage().getParameters().put('userId', usrpro.Id);           
            ApexPages.currentPage().getParameters().put('selYear', String.valueOf(System.today().year()));
            waveForecastMatrixControllerClone cp1 = new waveForecastMatrixControllerClone();
            cp1.getUsersList();
            cp1.getFiscalYear();           
            cp1.getGridData();

            Test.StopTest();
        }
    }

    static testMethod void testCompanyModel(){
        User u = TestDataHelper.getBoomiIntegrationUser();                
        
        System.runAs(u){
            //test.startTest();
            Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

            UserRole usrRole = new UserRole(Name = 'Manager');
            INSERT usrRole;
            UserRole usrRole1 = new UserRole(Name = 'LSM');
            INSERT usrRole1;

            usrRole1 = new UserRole(Name = 'test',ParentRoleID = usrRole.Id );
            INSERT usrRole1;
            System.assert(usrRole1 != null);            
            
            usrpro = TestDataHelper.createSystemAdminUser(false);
            usrpro.UserRoleId = usrRole.Id;
            INSERT usrpro;
            System.debug('usrpro::'+usrpro.Id);

            usr = new User(alias = 'usr', email = 'user123@charter.com',
                emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                localesidkey = 'en_US', profileid = p.Id, UserRoleId=usrRole1.Id,isActive = true,
                timezonesidkey = 'America/Los_Angeles', username = 'user123@testorgosius.com',ManagerID = usrpro.Id); 
            INSERT usr;

            SysCodeManualProposalCreation__c cs = new SysCodeManualProposalCreation__c(Name='Digital', Name__c= 'DigitalSysCode',Value__c= '0');                
            INSERT cs;

        //  test.startTest();
            Account acc = new Account(Name='Test Account',Commodity_Codes__c='  ADV_MKG -- Marketing',SAM_Designation__c='Extra',BillingStreet='Harizona',Billingcity='CA',BillingState='KA',BillingPostalCode='12233',BillingCountry='USA', Primary_Commodity__C = 'Media', Spectrum_Reach_Preferred__c=true);
            INSERT acc;
            List<AccountShare> share = new List<AccountShare>();
            AccountShare accountShare = new AccountShare();
            accountShare.AccountId = acc.Id;
            accountShare.UserOrGroupId = usrpro.Id;
            accountShare.AccountAccessLevel = 'Edit';
            //accountShare.ContactAccessLevel = 'Edit';
            accountShare.CaseAccessLevel = 'Edit';
            accountShare.OpportunityAccessLevel = 'Edit';
            share.add(accountShare);    
            INSERT share;

            System.debug('acc.ID:::'+acc.Id);
            
            Budget__c budget = TestDataHelper.createBudget(System.Today(),1000.00,'SRNews',usrpro.Id,acc.Id,'Approved'); 
            budget.ownerId = usrpro.Id;
            budget.Status__c = 'Not Submitted';
            budget.Account__c= acc.Id;
            budget.Start_Month_N__c = 6;
            budget.End_Month_N__c = 12;
            INSERT budget;

            /* SRSF-2072: Changed from Budget__c to Sales_Budget__c
            Sales_Budget__c salesBudget = TestDataHelper.createSalesBudget(System.Today(),1000.00,'Linear/News/Sports',usrpro.Id,acc.Id,'Final Approval'); 
            salesBudget.ownerId = usrpro.Id;
            salesBudget.Status__c = 'Not Submitted';
            insert salesBudget;
            system.assert(salesBudget.Id != null);*/
            
             //CreateRevenue
            Revenue__c  revenue = TestDataHelper.createRevenue('2222', '3333', System.today(), 1000, 1000, 0, 0, '1');
            revenue.Revenue_Type__c = 'Core';
            revenue.Advertiser__c = acc.Id;
            revenue.ContractNumber__c = 1111;
            revenue.Account_Executive__c = usrpro.Id;
            INSERT revenue;

            Account Agencytest =TestDataHelper.createAcc('Test AgencyAccount','Manikonda','Hyderabad','Telangana','500084','India');
            Agencytest.Spectrum_Reach_Preferred__c=true; 
            Agencytest.RecordTypeId= TestDataHelper.agencyRecTypeId; 
            INSERT Agencytest;            
            
            Opportunity oppr =new Opportunity(Name='Test Opp', CloseDate=System.today().addMonths(1),
                AccountId=acc.Id, Agency_Account__c= Agencytest.Id);
            oppr.StageName= 'Identification';             
            oppr.OwnerId = usrpro.Id; 
            INSERT oppr;
            test.startTest();
            RecordType rt = [SELECT Id,Name FROM RecordType WHERE Name ='Opportunity Budget'];
            System.debug('rt Name ::'+rt.Name);
            //Create proposal
            Proposal__c prop = new Proposal__c(Name ='Test Opportunity Proposal',Opportunity__c = oppr.Id,
                RecordTypeId = rt.Id,Start_Date__c = System.today(),End_Date__c = System.today().addMonths(1),
                TIM_Id__c='00000',Active__c = true);
            INSERT prop;
            
            Group__c grp = new Group__c(Name='Test Group', Group_Id__C = '123', TIM_System__c = 'St. Louis Local');
            INSERT grp;
            Group_Status__c groupStatus = new Group_Status__c();
            groupStatus.Name = 'Submitted to Traffic';
            groupStatus.Is_Active__c = true;
            groupStatus.Is_Entry__c = true;
            groupStatus.Is_Rejection__c = false;
            groupStatus.Group__c = grp.Id;
            INSERT groupStatus;

            //Create proposal zone          
            Proposal_Zone__c propZone = new Proposal_Zone__c(Name='Test Proposal Zone',Proposal__c=prop.Id,Status_Type__c = 'Pending');
            propZone.TIM_Status__c='Submitted to Traffic';
            INSERT propZone;
                   
            //Create proposal zone monthly value
            Proposal_Zone_Monthly_Value__c propZoneMonthly =new Proposal_Zone_Monthly_Value__c(Name ='Test Proposal Zone Monthly Value',Advertiser__c=acc.Id,
                Proposal_Zone__c=propZone.Id,Schedule_Type__c='Linear',Proposal_Key_Index__c=prop.Id,Broadcast_Month_Date__c=System.today().adddays(1));
            // propZoneMonthly.Net_Amount__c = 100;
            propZoneMonthly.Gross_Amount__c = 300;
            // propZoneMonthly.Net_of_Agency__c = 200;
            propZoneMonthly.Proposal_Key_Index__c = prop.Id;
            INSERT propZoneMonthly;         

            PageReference myVfPage = Page.waveForecastMatrix;
            Test.setCurrentPageReference(myVfPage);
            ApexPages.currentPage().getParameters().put('userId', usrpro.Id);          
            ApexPages.currentPage().getParameters().put('selYear', String.valueOf(System.today().year()));
            ApexPages.currentPage().getParameters().put('selCompModel', 'TRUE');
                
            WaveForecastMatrixController cp = new WaveForecastMatrixController();         
            cp.getUsersList();
            cp.getFiscalYear();
            // cp.fetchChildUserIds();  
        //  cp.fetchBudgetData();
            cp.getGridData();
           
            PageReference myVfPageClone = Page.waveForecastMatrixClone;
            Test.setCurrentPageReference(myVfPageClone);
            ApexPages.currentPage().getParameters().put('userId', usrpro.Id);          
            ApexPages.currentPage().getParameters().put('selYear', String.valueOf(System.today().year()));
            ApexPages.currentPage().getParameters().put('selCompModel', 'TRUE'); 
            waveForecastMatrixControllerClone cp1 = new waveForecastMatrixControllerClone();
            cp1.getUsersList();
            cp1.getFiscalYear();    
            cp1.getGridData();

            Test.StopTest();
        }
    }

    static testMethod void testBudgetDataForLSM(){
        User u = TestDataHelper.getBoomiIntegrationUser();        

        System.runAs(u){ 
            UserRole usrRole = new UserRole(Name = 'Manager');
            INSERT usrRole;
            /*UserRole usrRole1 = new UserRole(Name = 'LSM');
            INSERT usrRole1;

            usrRole1 = new UserRole(Name = 'test',ParentRoleID = usrRole.Id );
            INSERT usrRole1;
            System.assert(usrRole1 != null);*/            
             
            usrpro = TestDataHelper.createSystemAdminUser(false);    
            usrpro.UserRoleId = usrRole.Id;
            INSERT usrpro;
            System.debug('usrpro::'+usrpro.Id);          

            User lsmUser = TestDataHelper.createLSMUser(true);
            User ae1 = TestDataHelper.createAEUser(true, 'aeuser123@charter.com', lsmUser.Id);
            User ae2 = TestDataHelper.createAEUser(true, 'aeuser456@charter.com', lsmUser.Id);

            SysCodeManualProposalCreation__c cs = new SysCodeManualProposalCreation__c(Name='Digital', Name__c= 'DigitalSysCode',Value__c= '0');                
            INSERT cs;

            Account acc = new Account(Name='Test Account',Commodity_Codes__c='  ADV_MKG -- Marketing',SAM_Designation__c='Extra', BillingStreet='Harizona',Billingcity='CA',BillingState='KA',BillingPostalCode='12233',BillingCountry='USA', Primary_Commodity__C = 'Media', Spectrum_Reach_Preferred__c=true);
            INSERT acc;
            List<AccountShare> share = new List<AccountShare>();
            AccountShare accountShare = new AccountShare();
            accountShare.AccountId = acc.Id;
            accountShare.UserOrGroupId = usrpro.Id;
            accountShare.AccountAccessLevel = 'Edit';
            accountShare.CaseAccessLevel = 'Edit';
            accountShare.OpportunityAccessLevel = 'Edit';
            share.add(accountShare);    
            INSERT share;

            System.debug('acc.ID:::'+acc.Id);

            List<Budget__c> lstBudget = new List<Budget__c>();
            Budget__c budget=TestDataHelper.createBudget(System.Today(),10.00,'SRNews',usrpro.Id,acc.Id,'Approved'); 
            Budget__c budget2 =TestDataHelper.createBudget(System.Today(),100.00,'SRNews',ae1.Id,acc.Id,'Approved'); 
            Budget__c budget3 =TestDataHelper.createBudget(System.Today(),100.00,'SRNews',ae2.Id,acc.Id,'Approved'); 
            budget.OwnerId = usrpro.Id; budget2.OwnerId = ae1.Id;  budget3.OwnerId = ae2.Id; 
            budget.Start_Month_N__c = 4;
            budget.End_Month_N__c = 12;
            budget2.Start_Month_N__c = 4;
            budget2.End_Month_N__c = 12;
            budget3.Start_Month_N__c = 4;
            budget3.End_Month_N__c = 12;
            lstBudget.add(budget); lstBudget.add(budget2);  lstBudget.add(budget3);
            INSERT lstBudget;

            //CreateRevenue
            Revenue__c  revenue = TestDataHelper.createRevenue('2222','3333',System.today(), 1000, 1000, 0, 0, '1');
            revenue.Revenue_Type__c = 'Core';
            revenue.Advertiser__c = acc.Id;
            revenue.ContractNumber__c = 1111;
            revenue.Account_Executive__c = usrpro.ID;
            INSERT revenue;

            Account Agencytest =TestDataHelper.createAcc('Test AgencyAccount','Manikonda','Hyderabad','Telangana','500084','India');
            Agencytest.Spectrum_Reach_Preferred__c=true; 
            Agencytest.RecordTypeId= TestDataHelper.agencyRecTypeId; 
            INSERT Agencytest;            
            
            Opportunity oppr =new Opportunity(Name='Test Opp', CloseDate=System.today().addMonths(1),
                AccountId=acc.Id, Agency_Account__c= Agencytest.Id);
            oppr.StageName= 'Identification';
            oppr.OwnerId = usrpro.Id; 
            INSERT oppr;
            test.startTest();
            RecordType rt = [SELECT Id, Name FROM RecordType WHERE Name ='Opportunity Budget'];
            System.debug('rt Name ::'+rt.Name);
            //Create proposal
            Proposal__c prop = new Proposal__c(Name ='Test Opportunity Proposal',Opportunity__c = oppr.Id,
                RecordTypeId = rt.Id,Start_Date__c = System.today(),End_Date__c = System.today().addMonths(1), TIM_Id__c='00000',Active__c = true);
            INSERT prop;
            
            Group__c grp = new Group__c(Name='Test Group', Group_Id__C = '123', TIM_System__c = 'St. Louis Local');
            INSERT grp;
            Group_Status__c groupStatus = new Group_Status__c();
            groupStatus.Name = 'Submitted to Traffic';
            groupStatus.Is_Active__c = true;
            groupStatus.Is_Entry__c = true;
            groupStatus.Is_Rejection__c = false;
            groupStatus.Group__c = grp.Id;
            INSERT groupStatus;

            //Create proposal zone          
            Proposal_Zone__c propZone = new Proposal_Zone__c(Name='Test Proposal Zone',Proposal__c=prop.Id,Status_Type__c = 'Pending');
            propZone.TIM_Status__c='Submitted to Traffic';
            INSERT propZone;
                   
            //Create proposal zone monthly value
            Proposal_Zone_Monthly_Value__c propZoneMonthly =new Proposal_Zone_Monthly_Value__c(Name ='Test Proposal Zone Monthly Value',Advertiser__c=acc.Id,
                Proposal_Zone__c=propZone.Id,Schedule_Type__c='Linear',Proposal_Key_Index__c=prop.Id,Broadcast_Month_Date__c=System.today().adddays(1));
            // propZoneMonthly.Net_Amount__c = 100;
            propZoneMonthly.Gross_Amount__c = 300;
            // propZoneMonthly.Net_of_Agency__c = 200;
            propZoneMonthly.Proposal_Key_Index__c = prop.Id;
            INSERT propZoneMonthly; 

            PageReference myVfPage = Page.waveForecastMatrix;
            Test.setCurrentPageReference(myVfPage);
            ApexPages.currentPage().getParameters().put('userId', lsmUser.Id);           
            ApexPages.currentPage().getParameters().put('selYear', String.valueOf(System.today().year()));
            ApexPages.currentPage().getParameters().put('selCompModel', 'TRUE');
                
            WaveForecastMatrixController cp = new WaveForecastMatrixController();         
            cp.getUsersList();
            cp.getFiscalYear();
            cp.getGridData();

            PageReference myVfPageClone = Page.waveForecastMatrixClone;
            Test.setCurrentPageReference(myVfPageClone);
            ApexPages.currentPage().getParameters().put('userId', lsmUser.Id);           
            ApexPages.currentPage().getParameters().put('selYear', String.valueOf(System.today().year()));
            ApexPages.currentPage().getParameters().put('selCompModel', 'TRUE');
            waveForecastMatrixControllerClone cp1 = new waveForecastMatrixControllerClone();
            cp1.getUsersList();
            cp1.getFiscalYear();
            cp1.getGridData();

            Test.StopTest();
        }
    }  
    
     static testMethod void testNewsDataSection(){
        User u = TestDataHelper.getBoomiIntegrationUser();        
        
        System.runAs(u){           
            UserRole usrRole = new UserRole(Name = 'Manager');
            INSERT usrRole;            
            
            usrpro = TestDataHelper.createSystemAdminUser(false);
            usrpro.UserRoleId = usrRole.Id;    
            INSERT usrpro;
            System.debug('usrpro::'+usrpro.Id);

            SysCodeManualProposalCreation__c cs = new SysCodeManualProposalCreation__c(Name='Digital', Name__c= 'DigitalSysCode',Value__c= '0');                
            INSERT cs;

        //  test.startTest();
            Account acc = new Account(Name='Test Account',Commodity_Codes__c='  ADV_MKG -- Marketing',SAM_Designation__c='Extra', BillingStreet='Harizona',Billingcity='CA',BillingState='KA',BillingPostalCode='12233',BillingCountry='USA', Primary_Commodity__C = 'Media', Spectrum_Reach_Preferred__c=true);
            INSERT acc;
            List<AccountShare> share = new List<AccountShare>();
            AccountShare accountShare = new AccountShare();
            accountShare.AccountId = acc.Id;
            accountShare.UserOrGroupId = usrpro.Id;
            accountShare.AccountAccessLevel = 'Edit';
            //accountShare.ContactAccessLevel = 'Edit';
            accountShare.CaseAccessLevel = 'Edit';
            accountShare.OpportunityAccessLevel = 'Edit';
            share.add(accountShare);    
            INSERT share;

            System.debug('acc.ID:::'+acc.Id);

            RecordType budgetRT = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Budget__c' AND DeveloperName='NewsTarget'];
            
            Budget__c budget = TestDataHelper.createBudget(System.Today(),1000.00,'SRNews',usrpro.Id,acc.Id,'Approved'); 
            budget.ownerId = usrpro.Id;
            budget.RecordTypeId= budgetRT.Id; 
            budget.Start_Month_N__c = 4;
            budget.End_Month_N__c = 12;
            INSERT budget;

            Revenue__c  revenue = TestDataHelper.createRevenue('2222', '3333', System.today(), 1000, 1000, 0, 0, '1');
            revenue.Revenue_Type__c = 'Core';
            revenue.Advertiser__c = acc.Id;
            revenue.ContractNumber__c = 1111;
            revenue.Account_Executive__c = usrpro.Id;
            revenue.IsNews__c = true;
            INSERT revenue; 

            Account Agencytest =TestDataHelper.createAcc('Test AgencyAccount','Manikonda','Hyderabad','Telangana','500084','India');
            Agencytest.Spectrum_Reach_Preferred__c=true; 
            Agencytest.RecordTypeId= TestDataHelper.agencyRecTypeId; 
            INSERT Agencytest;            
            
            Opportunity oppr =new Opportunity(Name='Test Opp', CloseDate=System.today().addMonths(1),
                AccountId=acc.Id, Agency_Account__c= Agencytest.Id,StageName= 'Identification',OwnerId = usrpro.Id);
            INSERT oppr;
            test.startTest();

            RecordType rt = [SELECT Id, Name FROM RecordType WHERE Name ='Opportunity Budget'];
            System.debug('rt Name ::'+rt.Name);
            //Create proposal
            Proposal__c prop = new Proposal__c(Name ='Test Opportunity Proposal',Opportunity__c = oppr.Id,
                RecordTypeId = rt.Id,Start_Date__c = System.today(),End_Date__c = System.today().addMonths(1),TIM_Id__c='00000',Active__c = true);
            INSERT prop;
            
            Group__c grp = new Group__c(Name='Test Group', Group_Id__C = '123', TIM_System__c = 'St. Louis Local');
            INSERT grp;
            Group_Status__c groupStatus = new Group_Status__c(Name = 'Submitted to Traffic',Is_Active__c = true,Is_Entry__c = true,Is_Rejection__c = false,Group__c = grp.Id);
            INSERT groupStatus;

            //Create proposal zone          
            Proposal_Zone__c propZone = new Proposal_Zone__c(Name='Test Proposal Zone',Proposal__c=prop.Id,Status_Type__c = 'Pending',TIM_Status__c='Submitted to Traffic');
            INSERT propZone;
                   
            //Create proposal zone monthly value
            Proposal_Zone_Monthly_Value__c propZoneMonthly =new Proposal_Zone_Monthly_Value__c(Name ='Test Proposal Zone Monthly Value',Advertiser__c=acc.Id,
                Proposal_Zone__c=propZone.Id,Schedule_Type__c='Linear',Proposal_Key_Index__c=prop.Id,Broadcast_Month_Date__c=System.today().adddays(1),Gross_Amount__c = 300);
            INSERT propZoneMonthly;         

            PageReference myVfPage = Page.waveForecastMatrix;
            Test.setCurrentPageReference(myVfPage);
            ApexPages.currentPage().getParameters().put('userId', usrpro.Id);          
            ApexPages.currentPage().getParameters().put('selYear', String.valueOf(System.today().year()));
            ApexPages.currentPage().getParameters().put('selCompModel', 'TRUE');
                
            WaveForecastMatrixController cp = new WaveForecastMatrixController();         
            cp.getUsersList();
            cp.getFiscalYear();
            cp.getGridData();

            PageReference myVfPageClone = Page.waveForecastMatrixClone;
            Test.setCurrentPageReference(myVfPageClone);
            ApexPages.currentPage().getParameters().put('userId', usrpro.Id);          
            ApexPages.currentPage().getParameters().put('selYear', String.valueOf(System.today().year()));
            ApexPages.currentPage().getParameters().put('selCompModel', 'TRUE');

            waveForecastMatrixControllerClone cp1 = new waveForecastMatrixControllerClone();
            cp1.getUsersList();
            cp1.getFiscalYear();
            cp1.getGridData();

            Test.StopTest();
        }
    }

    //SRSF-4489 : Create proposal for Forecast Adjustment
    /*static testMethod void testForecastAdjSection() {
       
        User u = TestDataHelper.getBoomiIntegrationUser();       

        Map<String,String> TestData = TestDataHelper.fetchDivisions();
      
        System.runAs(u){
            User ae1 =TestDataHelper.createAEUser(false, 'aeuser123@charter.com', null);
            ae1.Region__c=TestData.get('Region_c_1');
            INSERT ae1;
            
        //  Test.StartTest();
            Account acc = new Account(Name='Test Account',Commodity_Codes__c='  ADV_MKG -- Marketing',SAM_Designation__c='Extra', BillingStreet='Harizona',Billingcity='CA',BillingState='KA',BillingPostalCode='12233',BillingCountry='USA', Primary_Commodity__C = 'Media', Spectrum_Reach_Preferred__c=true);
            INSERT acc;
                
            List<AccountShare> share = new List<AccountShare>();
            AccountShare accountShare = new AccountShare();
            accountShare.AccountId = acc.Id;
            accountShare.UserOrGroupId = ae1.Id;
            accountShare.AccountAccessLevel = 'Edit';
            accountShare.CaseAccessLevel = 'Edit';
            accountShare.OpportunityAccessLevel = 'Edit';
            share.add(accountShare);    
            INSERT share;

            Id adjForecastingOppRTId = String.valueOf(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Forecasting_Tool_Opportunity').getRecordTypeId());

            Id adjOppBudgetPropRTId = String.valueOf(Schema.SObjectType.Proposal__c.getRecordTypeInfosByDeveloperName().get('Adjust_Opportunity_Budget').getRecordTypeId());
            Test.StartTest();
            Opportunity forecastAdjOppty = TestDataHelper.createopportunity('Opp For Forecast Adj',System.today(),'Identification','Pipeline',acc.Id);
            forecastAdjOppty.RecordTypeId = adjForecastingOppRTId;
            forecastAdjOppty.Owner_For_Forecasting_Tool__c = ae1.Id;     
            INSERT forecastAdjOppty;

            Proposal__c forecastAdjProp = new Proposal__c(Name ='Test Forecast Adj Proposal',Opportunity__c = forecastAdjOppty.Id, RecordTypeId = adjOppBudgetPropRTId,Start_Date__c = System.today(),End_Date__c = System.today().addMonths(1),Active__c = true);
            INSERT forecastAdjProp;
                   
            Proposal_Zone__c forecastAdjpropZone = new Proposal_Zone__c(Name='Test Forecast Adj PZ',Proposal__c=forecastAdjProp.Id);            
            INSERT forecastAdjpropZone;                   
            
            Proposal_Zone_Monthly_Value__c forecastAdjPZMV =new Proposal_Zone_Monthly_Value__c(Name ='Test Forecast Adj PZMV',Advertiser__c=acc.Id, Proposal_Zone__c=forecastAdjpropZone.Id, Schedule_Type__c='Linear',Proposal_Key_Index__c=forecastAdjProp.Id,Broadcast_Month_Date__c=System.today().adddays(1));
            // propZoneMonthly.Net_Amount__c = 100;
            forecastAdjPZMV.Gross_Amount__c = 30000;            
            INSERT forecastAdjPZMV;
        //  Test.StartTest();
            Budget__c budget = TestDataHelper.createBudget(System.Today(),1000.00,'SRNews',ae1.Id,acc.Id,'Approved'); 
            budget.OwnerId = ae1.Id;
            budget.Status__c = 'Not Submitted';
            budget.Account__c= acc.Id;
            budget.Start_Month_N__c = 1;
            budget.End_Month_N__c = 12;
            INSERT budget;                

            PageReference myVfPage = Page.waveForecastMatrix;
            Test.setCurrentPageReference(myVfPage);
            ApexPages.currentPage().getParameters().put('userId', ae1.Id);          
            ApexPages.currentPage().getParameters().put('selYear', String.valueOf(System.today().year()));
            ApexPages.currentPage().getParameters().put('selCompModel', 'FALSE');
        //  Test.StartTest();        
            WaveForecastMatrixController cp = new WaveForecastMatrixController();
            cp.getUsersList();
            cp.getFiscalYear();
        //  Test.StartTest();
        //    cp.getGridData(); 

            Test.StopTest();       
        }        
    }*/

     //SRSF-4489 : Create proposal for Forecast Adjustment to get coverage for clone copy controller
    /*static testMethod void testForecastAdjSectionClone () {
       
        User u = TestDataHelper.getBoomiIntegrationUser();       

        Map<String,String> TestData = TestDataHelper.fetchDivisions();
      
        System.runAs(u){
            User ae1 =TestDataHelper.createAEUser(false, 'aeuser123@charter.com', null);
            ae1.Region__c=TestData.get('Region_c_1');
            INSERT ae1;
            
         // Test.StartTest();

            Account acc = new Account(Name='Test Account',Commodity_Codes__c='  ADV_MKG -- Marketing',SAM_Designation__c='Extra', BillingStreet='Harizona',Billingcity='CA',BillingState='KA',BillingPostalCode='12233',BillingCountry='USA', Primary_Commodity__C = 'Media', Spectrum_Reach_Preferred__c=true);
            INSERT acc;
                
            List<AccountShare> share = new List<AccountShare>();
            AccountShare accountShare = new AccountShare();
            accountShare.AccountId = acc.Id;
            accountShare.UserOrGroupId = ae1.Id;
            accountShare.AccountAccessLevel = 'Edit';
            accountShare.CaseAccessLevel = 'Edit';
            accountShare.OpportunityAccessLevel = 'Edit';
            share.add(accountShare);    
            INSERT share;

            Id adjForecastingOppRTId = String.valueOf(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Forecasting_Tool_Opportunity').getRecordTypeId());

            Id adjOppBudgetPropRTId = String.valueOf(Schema.SObjectType.Proposal__c.getRecordTypeInfosByDeveloperName().get('Adjust_Opportunity_Budget').getRecordTypeId());
            Test.StartTest();
            Opportunity forecastAdjOppty = TestDataHelper.createopportunity('Opp For Forecast Adj',System.today(),'Identification','Pipeline',acc.Id);
            forecastAdjOppty.RecordTypeId = adjForecastingOppRTId;
            forecastAdjOppty.Owner_For_Forecasting_Tool__c = ae1.Id;     
            INSERT forecastAdjOppty;

            Proposal__c forecastAdjProp = new Proposal__c(Name ='Test Forecast Adj Proposal',Opportunity__c = forecastAdjOppty.Id, RecordTypeId = adjOppBudgetPropRTId,Start_Date__c = System.today(),End_Date__c = System.today().addMonths(1),Active__c = true);
            INSERT forecastAdjProp;
                   
            Proposal_Zone__c forecastAdjpropZone = new Proposal_Zone__c(Name='Test Forecast Adj PZ',Proposal__c=forecastAdjProp.Id);            
            INSERT forecastAdjpropZone;                   
            
            Proposal_Zone_Monthly_Value__c forecastAdjPZMV =new Proposal_Zone_Monthly_Value__c(Name ='Test Forecast Adj PZMV',Advertiser__c=acc.Id, Proposal_Zone__c=forecastAdjpropZone.Id, Schedule_Type__c='Linear',Proposal_Key_Index__c=forecastAdjProp.Id,Broadcast_Month_Date__c=System.today().adddays(1));
            // propZoneMonthly.Net_Amount__c = 100;
            forecastAdjPZMV.Gross_Amount__c = 30000;            
            INSERT forecastAdjPZMV;
        //  Test.StartTest();
            Budget__c budget = TestDataHelper.createBudget(System.Today(),1000.00,'SRNews',ae1.Id,acc.Id,'Approved'); 
            budget.OwnerId = ae1.Id;
            budget.Status__c = 'Not Submitted';
            budget.Account__c= acc.Id;
            budget.Start_Month_N__c = 1;
            budget.End_Month_N__c = 12;
            INSERT budget;                

            PageReference myVfPageClone = Page.waveForecastMatrixClone;
            Test.setCurrentPageReference(myVfPageClone);
            ApexPages.currentPage().getParameters().put('userId', ae1.Id);          
            ApexPages.currentPage().getParameters().put('selYear', String.valueOf(System.today().year()));
            ApexPages.currentPage().getParameters().put('selCompModel', 'FALSE'); 
        //  Test.StartTest();
            waveForecastMatrixControllerClone cp1 = new waveForecastMatrixControllerClone();
            cp1.getUsersList();
            cp1.getFiscalYear();
        //  Test.StartTest();
         //   cp1.getGridData();

            Test.StopTest();       
        }        
    }
*/
    //SRSF-4421
    /*static testMethod void prepareTestDataCustomerSuccessProfile() {                
        User intUser = TestDataHelper.getBoomiIntegrationUser();
        Map<String,String> TestData = TestDataHelper.fetchDivisions();
        
        User ae1 =TestDataHelper.createAEUser(false, 'aeuserforCSTest@charter.com', null);
        ae1.Region__c=TestData.get('Region_c_1');
        INSERT ae1;

        Profile ssmProf = [SELECT Id FROM Profile WHERE Name='Master - Sales Support Manager'];

        User supportMngr = new User(alias = 'supMgr', email = 'ssmuser@charter.com', emailencodingkey = 'UTF-8', lastname = 'TestingSSM', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = ssmProf.Id, isActive = true, timezonesidkey = 'America/Los_Angeles', username = 'supportMngr@testorgosius.com',Region__c=TestData.get('Region_c_1')); 
            INSERT supportMngr;

        System.assert(supportMngr != null);
     // Test.StartTest();
        prepareTestData(); 
        Test.StartTest();       
        System.runAs(supportMngr){       
           // Test.StartTest();               
            waveForecastMatrixController cp = new waveForecastMatrixController();         
            cp.getUsersList();

            waveForecastMatrixControllerClone cp1 = new waveForecastMatrixControllerClone();
            cp1.getUsersList();
           // Test.StopTest();
        } 
        Test.StopTest();   
    }*/
}