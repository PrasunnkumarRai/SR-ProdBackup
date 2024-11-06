@isTest
public with sharing class forecastMatrixAEControllerTest {
   static testMethod void prepareTestDataAE() {
        ID userId = UserInfo.getUserId();
        User u =new User();
        //System.runAs(u){
           
            SysCodeManualProposalCreation__c cs = new SysCodeManualProposalCreation__c(Name='Digital', Name__c= 'DigitalSysCode',Value__c= '0');                
            INSERT cs;

        //  test.startTest();
            Account acc = new Account(Name='Test Account',Commodity_Codes__c='  ADV_MKG -- Marketing',SAM_Designation__c='Extra', BillingStreet='Harizona',Billingcity='CA',BillingState='KA',BillingPostalCode='12233',BillingCountry='USA', Primary_Commodity__C = 'Media', Spectrum_Reach_Preferred__c=true);
            INSERT acc;
            List<AccountShare> share = new List<AccountShare>();
            AccountShare accountShare = new AccountShare();
            accountShare.AccountId = acc.Id;
            accountShare.UserOrGroupId = userId;
            accountShare.AccountAccessLevel = 'Edit';            
            accountShare.CaseAccessLevel = 'Edit';
            accountShare.OpportunityAccessLevel = 'Edit';
            share.add(accountShare);    
            INSERT share;

            System.debug('acc.ID:::'+acc.Id);
            
            Budget__c budget = TestDataHelper.createBudget(System.Today(),1000.00,'SRNews',userId,acc.Id,'Approved'); 
            budget.OwnerId = userId;
            budget.Status__c = 'Not Submitted';
            budget.Account__c= acc.Id;
            budget.Start_Month_N__c = 4;
            budget.End_Month_N__c = 12;
            INSERT budget;

             //CreateRevenue
            Revenue__c  revenue = TestDataHelper.createRevenue('2222', '3333', System.today(), 1000, 1000, 0, 0, '1');
            revenue.Revenue_Type__c = 'Core';
            revenue.Advertiser__c = acc.Id;
            revenue.ContractNumber__c = 1111;
            revenue.Account_Executive__c = userId;
            INSERT revenue;

            Account Agencytest =TestDataHelper.createAcc('Test AgencyAccount','Manikonda','Hyderabad','Telangana','500084','India');
            Agencytest.Spectrum_Reach_Preferred__c=true; 
            Agencytest.RecordTypeId= TestDataHelper.agencyRecTypeId; 
            INSERT Agencytest;            
        
            Opportunity oppr =new Opportunity(Name='Test Opp', CloseDate=System.today().addMonths(1),
                AccountId=acc.Id, Agency_Account__c= Agencytest.Id);
            oppr.StageName= 'Identification';           
            INSERT oppr;
            test.startTest();
            oppr.StageName= 'Closed Won';
            oppr.OwnerId = userId; 
            oppr.Sales_Probability__c= '100';
            UPDATE oppr;
            System.debug(' ### opp salesProbability :::: ' +oppr.Sales_Probability__c);
            RecordType rt = [SELECT Id, Name FROM RecordType WHERE Name ='Linear'];
            System.debug('rt Linear::'+rt.Name);
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
            ApexPages.currentPage().getParameters().put('userId', userId);
            ApexPages.currentPage().getParameters().put('selYear', String.valueOf(System.today().year()));
                
            Set<Id> userIds = new Set<Id>();
                      
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
            Test.StopTest();
            cp.accNameparam = 'Test';
            cp.politicalFilter = '';
            cp.tradeFilter = '';

            // cp.calculatePerformancePercentage();
            // cp.calculatePercentage(new List<Decimal>{1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0}, new List<Decimal>{11.0,12.0,0.13,14.0,15.0,16.0,17.0,18.0,19.0,20.0,21.0,22.0,23.0}, 'Linear');
        }
   // }

    static testMethod void Negativetestmethod(){                 
        
        UserRole usrRole = new UserRole(Name = 'AE1');
        INSERT usrRole;
      UserRole  usrRole1 = new UserRole(Name = 'test1',ParentRoleID = usrRole.Id );
        INSERT usrRole1;
        System.assert(usrRole1 != null);        
        
       User usr = TestDataHelper.createSystemAdminUser(false);
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
    }
}