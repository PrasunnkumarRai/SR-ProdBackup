@isTest
private class LightningProposalOpptyBudgetCntrlTest {
    
    static List<List<String>> budgetList;
    static LightningProposalOpportunityBudgetCntrl cp;
    static Account acc;
    static Opportunity opp;
    //static Proposal__c p;
    static Proposal_Zone__c propZone;
    //static Proposal_Zone_Monthly_Value__c propZoneMonthly;
    static String selStartDate;
    static String selendDate;
    
    static testMethod void PositiveTest(){
        //User u = [select Id, Name from User where Name = 'Boomi Integration User'];
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.assertEquals(u.Name,'Boomi Integration User');

        Budget_Product_Lines_Mapping__c customSetting = new Budget_Product_Lines_Mapping__c();
        customSetting.SetupOwnerId = UserInfo.getOrganizationId();
        customSetting.Product_Lines__c = 'Digital, Linear,Production,Linear/News/Sports';
        insert customSetting;

        System.runAs(u){
           
            //TestDataHelper.createTIMIntegrationCustomSettings();
            insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
            //Create an account
            acc = TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
            insert acc;
            System.assertEquals('Advertiser Account',acc.Name);            
            
            //Create an opportunity on the above created account
            opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.Id);        
            //opp.Number_Of_Manual_Proposal_Records__c = 1;
            insert opp;
            System.assertEquals('Test Opportunity',opp.Name);
            Account acnt = [SELECT Id,Name FROM Account WHERE Id=:acc.Id];
            System.assert(opp.AccountId==acnt.Id);
            
             
            Proposal__c p  = new Proposal__c();
            
            p = TestDataHelper.createProposal('Test Opportunity Proposal',opp.Id, '00000', true);
            p.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
            insert p;
            
            propZone = TestDataHelper.createProposalZone('Test Proposal Zone',p.Id);
            insert propZone;
            Proposal__c propId = [SELECT Id FROM Proposal__c WHERE Id=:p.Id];
            
            
            
            System.assert(propZone.Proposal__c==propId.Id);
            
            Proposal_Zone_Monthly_Value__c propZoneMonthly = new Proposal_Zone_Monthly_Value__c();
            propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value',acc.Id,propZone.Id);
            propZoneMonthly.Schedule_Type__c = 'Production';
            propZoneMonthly.Proposal_Key_Index__c = p.Id;
            propZoneMonthly.Broadcast_Month_Date__c = System.today().adddays(1);
            propZoneMonthly.gross_Amount__c = 100.00;
            insert propZoneMonthly;
            System.assertNotEquals(propZoneMonthly,null);
            Test.startTest();
            TestDataHelper.createSysCodeManualProposalCreationCustomSettings();
            
            /* Id linearRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Linear'].Id;

p.RecordTypeId = linearRecTypeId;*/
            
            p.Start_Date__c = Date.today();
            p.End_Date__c = Date.today().addMonths(1);
            update p;
            System.assertEquals(p.Start_Date__c,Date.today());
            System.assertNotEquals(p.End_Date__c,Date.today());
            // Test.stopTest();
            //Date startDate = System.today();
            //selStartDate = DateTime.newInstance(startDate.year(),startDate.month(),startDate.day()).format('MM/dd/YYYY');
            //Date endDate = System.today().adddays(4);
            //selendDate = DateTime.newInstance(endDate.year(),endDate.month(),endDate.day()).format('MM/dd/YYYY');
            //Test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(p);
            ApexPages.currentPage().getParameters().put('oppId', opp.Id);
            //ApexPages.currentPage().getParameters().put('id', p.id);
            cp = new LightningProposalOpportunityBudgetCntrl(controller);
            
            //Test.startTest();
            cp.selectedStartDate = System.today()+5;
            cp.startDate = System.today()+9;    
            cp.selectedEndDate = System.today().addMonths(1);
            cp.endDate = system.today().adddays(12);
            cp.validateProposals();
            
            cp.goBackToOpportunity();
            cp.rowAmount = 100000;
            cp.colAmount = 20000;
            cp.scheduleString = 'Linear';
            cp.monthString = '12_2017';
            cp.splitRowTotal();
            cp.splitColumnTotal();

            cp.rowAmount = 1000;
            cp.scheduleString = 'Digital';
            cp.splitRowTotal();

            cp.submitButton();
            cp.saveData();
            
            LightningProposalOpportunityBudgetCntrl.proposalZoneMonthlyWrapper wrap = new LightningProposalOpportunityBudgetCntrl.proposalZoneMonthlyWrapper();
            wrap.monthAmount = 10;
            wrap.monthKey = '03_2018';
            wrap.scheduleType = 'Linear';
            cp.wrapList.add(wrap);
            
            cp.save();      
            Test.stopTest();
            cp.resetGrid();
            
            
        }
    }
    
    static testMethod void negativeTest(){
        //User u = [select Id, Name from User where Name = 'Boomi Integration User'];
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.assertEquals(u.Name,'Boomi Integration User');
        System.runAs(u){
            Id linearRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Linear'].Id;
            //TestDataHelper.createTIMIntegrationCustomSettings();
            insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
            
            //Create an account
            if(acc == null)
            {
                acc = TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
                insert acc;
            }
            System.assertEquals('123 Wright Plaza',acc.BillingStreet);
            
            //Create an opportunity on the above created account
            if(opp == null)
            {
                opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.Id);        
                //opp.Number_Of_Manual_Proposal_Records__c = 1;
                insert opp;
            }
            Test.startTest();
            System.assertEquals('Test Opportunity',opp.Name);
            Account acnt = [SELECT Id,Name FROM Account WHERE Id=:acc.Id];
            System.assert(opp.AccountId==acnt.Id);
            
            Proposal__c p  = new Proposal__c();
            
            p = TestDataHelper.createProposal('Test Opportunity Proposal',opp.Id, '00000', true);
            p.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
            insert p;
            
            propZone = TestDataHelper.createProposalZone('Test Proposal Zone',p.Id);
            insert propZone;
            
            Proposal__c propId = [SELECT Id FROM Proposal__c WHERE Id=:p.Id];
            System.assert(propZone.Proposal__c==propId.Id);
            
            Proposal_Zone_Monthly_Value__c propZoneMonthly = new Proposal_Zone_Monthly_Value__c();
            propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value',acc.Id,propZone.Id);
            propZoneMonthly.Schedule_Type__c = 'Linear';
            propZoneMonthly.Proposal_Key_Index__c = p.Id;
            propZoneMonthly.Broadcast_Month_Date__c = System.today().adddays(1);
            propZoneMonthly.gross_Amount__c = 100.00;
            
            insert propZoneMonthly;
            System.assertNotEquals(null,propZoneMonthly);
            
            System.debug('### propZoneMonthly ::: ' +propZoneMonthly);
            //test.startTest();
            TestDataHelper.createSysCodeManualProposalCreationCustomSettings();         
            TestDataHelper.OppBudgetMessages();
            p.Start_Date__c = Date.today();
            p.End_Date__c = Date.today().addMonths(1);
            update p;
            
            //Date startDate = System.today();
            //selStartDate = DateTime.newInstance(startDate.year(),startDate.month(),startDate.day()).format('MM/dd/YYYY');
            //Date endDate = System.today().adddays(4);
            //selendDate = DateTime.newInstance(endDate.year(),endDate.month(),endDate.day()).format('MM/dd/YYYY');         
            //test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(p);
            ApexPages.currentPage().getParameters().put('oppId', opp.Id);
            //ApexPages.currentPage().getParameters().put('id', p.id);
            
            cp = new LightningProposalOpportunityBudgetCntrl(controller);
            cp.selectedStartDate = System.today();
            cp.startDate = System.today()-2;    
            
            ApexPages.StandardController contr = new ApexPages.StandardController(p);
            ApexPages.currentPage().getParameters().put('oppId', opp.Id);
            //ApexPages.currentPage().getParameters().put('id', p.id);
            cp = new LightningProposalOpportunityBudgetCntrl(contr);
            cp.selectedStartDate = System.today();
            cp.startDate = System.today();  
            //test.startTest();
            ApexPages.StandardController contrl = new ApexPages.StandardController(p);
            ApexPages.currentPage().getParameters().put('oppId', opp.Id);
            //ApexPages.currentPage().getParameters().put('id', p.id);
            cp = new LightningProposalOpportunityBudgetCntrl(contrl);
            cp.selectedStartDate = System.today();
            cp.startDate = System.today()-2;    
            
            cp.optionSelected = 'ChangeStartDate';          
            cp.validateProposals();
            
            cp.goBackToOpportunity();
            cp.rowAmount = 100000;
            cp.colAmount = 20000;
            cp.scheduleString = 'Linear';
            cp.monthString = '12_2017';
            cp.splitRowTotal();
            cp.splitColumnTotal();
            cp.submitButton();
            cp.saveData();
            /*ProposalOpportunityBudgetController.proposalZoneMonthlyWrapper wrap = new ProposalOpportunityBudgetController.proposalZoneMonthlyWrapper();
            wrap.monthAmount = 10.00;
            wrap.monthKey = '03_2018';
            wrap.scheduleType = 'Linear';
            cp.wrapList.add(wrap);*/
            cp.save();          
            Test.stopTest();
        }
    }
    
    static testMethod void negativeTesting() {
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.assertEquals(u.Name,'Boomi Integration User');
        System.runAs(u){
            
            Id linearRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Linear'].Id;
            //TestDataHelper.createTIMIntegrationCustomSettings();
            insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
            
            //Create an account
            if(acc == null)
            {
                acc = TestDataHelper.createAdvertiser('Advertiser Account','12345 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
                insert acc;
            }
            System.assertEquals('12345 Wright Plaza',acc.BillingStreet);
            Test.startTest();
            
            //Create an opportunity on the above created account
            if(opp == null)
            {
                opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.Id);        
                //opp.Number_Of_Manual_Proposal_Records__c = 1;
                insert opp;
            }
            
            System.assertEquals('Test Opportunity',opp.Name);
            
            Account acnt = [SELECT Id,Name FROM Account WHERE Id=:acc.Id];
            System.assert(opp.AccountId==acnt.Id);
            
            Proposal__c p  = new Proposal__c();
            
            p = TestDataHelper.createProposal('Test Opportunity Proposal',opp.Id, '00000', true);
            p.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
            p.Start_Date__c = null;
            p.End_Date__c = null;
            
            insert p;
            
            propZone = TestDataHelper.createProposalZone('Test Proposal Zone',p.Id);
            insert propZone;
            
            ApexPages.StandardController contrl = new ApexPages.StandardController(p);
            ApexPages.currentPage().getParameters().put('oppId', opp.Id);
            ApexPages.currentPage().getParameters().put('id', p.Id);
            cp = new LightningProposalOpportunityBudgetCntrl(contrl);
            
        }
    }
    
    static testMethod void negativeTest2(){
        //User u = [select Id, Name from User where Name = 'Boomi Integration User'];
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.assertEquals(u.Name,'Boomi Integration User');
        System.runAs(u){
            Id linearRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Linear'].Id;
            //TestDataHelper.createTIMIntegrationCustomSettings();
            insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
            
            //Create an account
            if(acc == null)
            {
                acc = TestDataHelper.createAdvertiser('Advertiser Account','12345 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
                insert acc;
            }
            system.assertEquals('12345 Wright Plaza',acc.BillingStreet);
            
            
            //Create an opportunity on the above created account
            if(opp == null)
            {
                opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.Id);        
                //opp.Number_Of_Manual_Proposal_Records__c = 1;
                insert opp;
            }
            
            System.assertEquals('Test Opportunity',opp.Name);
            Test.startTest();
            Account acnt = [SELECT Id,Name FROM Account WHERE Id=:acc.Id];
            System.assert(opp.AccountId==acnt.Id);
            
            Proposal__c p  = new Proposal__c();
            
            p = TestDataHelper.createProposal('Test Opportunity Proposal',opp.Id, '00000', true);
            p.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
            insert p;
            
            propZone = TestDataHelper.createProposalZone('Test Proposal Zone',p.Id);
            insert propZone;
            
            Proposal__c propId = [SELECT Id FROM Proposal__c WHERE Id=:p.Id];
            System.assert(propZone.Proposal__c==propId.Id);
            
            List<Proposal_Zone_Monthly_Value__c> propZoneMonthlyLst = new List<Proposal_Zone_Monthly_Value__c>();
            Proposal_Zone_Monthly_Value__c propZoneMonthly = new Proposal_Zone_Monthly_Value__c();
            propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value',acc.Id,propZone.Id);
            propZoneMonthly.Schedule_Type__c = 'Linear';
            propZoneMonthly.Proposal_Key_Index__c = p.Id;
            propZoneMonthly.Broadcast_Month_Date__c = System.today().adddays(1);
            propZoneMonthly.gross_Amount__c = 100.00;
            propZoneMonthlyLst.add(propZoneMonthly);
            insert propZoneMonthlyLst;            
            System.assertEquals(1,propZoneMonthlyLst.size());
            
            TestDataHelper.createSysCodeManualProposalCreationCustomSettings();         
            TestDataHelper.OppBudgetMessages();
            p.Start_Date__c = Date.today().addMonths(1);
            p.End_Date__c = Date.today();
            update p;
            System.assertEquals(p.Start_Date__c, Date.today().addMonths(1));
            //Test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(p);
            ApexPages.currentPage().getParameters().put('oppId', opp.Id);
            ApexPages.currentPage().getParameters().put('id', p.Id);
            cp = new LightningProposalOpportunityBudgetCntrl(controller);
            
            p.Start_Date__c = Date.today().addMonths(1);
            p.End_Date__c = Date.today();
            update p;
            
            ApexPages.StandardController con = new ApexPages.StandardController(p);
            ApexPages.currentPage().getParameters().put('oppId', opp.Id);
            ApexPages.currentPage().getParameters().put('id', p.Id);
            cp = new LightningProposalOpportunityBudgetCntrl(con);
            
            cp.selectedStartDate = System.today();
            cp.startDate = System.today();
            
            System.assertEquals(p.Start_Date__c, Date.today().addMonths(1));
            
            ApexPages.StandardController cont = new ApexPages.StandardController(p);
            ApexPages.currentPage().getParameters().put('oppId', opp.Id);
            ApexPages.currentPage().getParameters().put('id', p.Id);
            cp = new LightningProposalOpportunityBudgetCntrl(cont);
            
            cp.optionSelected = 'ChangeEndDate';
            cp.validateProposals();
            
            cp.goBackToOpportunity();
            cp.rowAmount = 100000;
            cp.colAmount = 20000;
            cp.scheduleString = 'Linear';
            cp.monthString = '12_2017';
            cp.splitRowTotal();
            cp.splitColumnTotal();
            cp.submitButton();
            cp.saveData();
            if(cp.wrapList != null) {
                cp.save();              
            }   
            Test.stopTest();
        }
    }
    
    static testMethod void PositiveTestWithoutProposal(){
        //User u = [select Id, Name from User where Name = 'Boomi Integration User'];
        User u = TestDataHelper.getBoomiIntegrationUser();
        u.Budget_Product_Lines__c = 'Production';
        update u;
        
        Budget_Product_Lines_Mapping__c customSetting = new Budget_Product_Lines_Mapping__c();
        customSetting.SetupOwnerId = UserInfo.getOrganizationId();
        customSetting.Product_Lines__c = 'Linear,Production,Linear/News/Sports';
        insert customSetting;
        System.assertEquals(u.Name,'Boomi Integration User');
        System.runAs(u){
            
            //TestDataHelper.createTIMIntegrationCustomSettings();
            insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
            
            //Create an account
            acc = TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
            insert acc;
            System.assertEquals('Advertiser Account',acc.Name);
            
            //Create an opportunity on the above created account
            opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.Id);        
            //opp.Number_Of_Manual_Proposal_Records__c = 1;
            insert opp;
            System.assertEquals('Test Opportunity',opp.Name);
            
            Proposal__c p  = new Proposal__c();
            
            Test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(p);
            ApexPages.currentPage().getParameters().put('oppId', opp.Id);
            //ApexPages.currentPage().getParameters().put('id', p.id);
            cp = new LightningProposalOpportunityBudgetCntrl(controller);
            cp.selectedStartDate = System.today();
            cp.startDate = System.today()+2;    
            cp.validateProposals();
            
            cp.goBackToOpportunity();
            cp.rowAmount = 100000;
            cp.colAmount = 20000;
            cp.scheduleString = 'Linear';
            cp.monthString = '12_2017';
            cp.splitRowTotal();
            cp.splitColumnTotal();
            cp.submitButton();
            cp.saveData();
            LightningProposalOpportunityBudgetCntrl.proposalZoneMonthlyWrapper wrap = new LightningProposalOpportunityBudgetCntrl.proposalZoneMonthlyWrapper();
            wrap.monthAmount = 10;
            wrap.monthKey = '03_2018';
            wrap.scheduleType = 'Linear';
            cp.wrapList.add(wrap);
            cp.save();      
            Test.stopTest();            
        }        
    }


    static testMethod void testChangeEndDate(){  
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.assertEquals(u.Name,'Boomi Integration User');

        Budget_Product_Lines_Mapping__c customSetting = new Budget_Product_Lines_Mapping__c();
        customSetting.SetupOwnerId = UserInfo.getOrganizationId();
        customSetting.Product_Lines__c = 'Digital, Linear,Production,Linear/News/Sports';
        insert customSetting;
        
        System.runAs(u){
            Id linearRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Linear'].Id;
            insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
            
            //Create an account
            if(acc == null)
            {
                acc = TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
                insert acc;
            }
            System.assertEquals('123 Wright Plaza',acc.BillingStreet);
            
            //Create an opportunity on the above created account
            if(opp == null)
            {
                opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.Id);
                insert opp;
            }
            Test.startTest();
            System.assertEquals('Test Opportunity',opp.Name);
            Account acnt = [SELECT Id,Name FROM Account WHERE Id=:acc.Id];
            System.assert(opp.AccountId==acnt.Id);
            
            Proposal__c p  = new Proposal__c();
            
            p = TestDataHelper.createProposal('Test Opportunity Proposal',opp.Id, '00000', true);
            p.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
            insert p;
            
            propZone = TestDataHelper.createProposalZone('Test Proposal Zone',p.Id);
            insert propZone;
            
            Proposal__c propId = [SELECT Id FROM Proposal__c WHERE Id=:p.Id];
            System.assert(propZone.Proposal__c==propId.Id);
            
            Proposal_Zone_Monthly_Value__c propZoneMonthly = new Proposal_Zone_Monthly_Value__c();
            propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value',acc.Id,propZone.Id);
            propZoneMonthly.Schedule_Type__c = 'Linear';
            propZoneMonthly.Proposal_Key_Index__c = p.Id;
        //  propZoneMonthly.Broadcast_Month_Date__c = System.today().adddays(1);
            propZoneMonthly.Broadcast_Month_Date__c = Date.newInstance(System.today().year(), System.today().month(), 15);
            propZoneMonthly.gross_Amount__c = 750.00;            
            insert propZoneMonthly;            

            System.assertNotEquals(null,propZoneMonthly);
            
            System.debug('### propZoneMonthly ::: ' +propZoneMonthly);
            //test.startTest();
            TestDataHelper.createSysCodeManualProposalCreationCustomSettings();         
            TestDataHelper.OppBudgetMessages();
           /* p.Start_Date__c = Date.today();
            p.End_Date__c = Date.today().addMonths(4);*/
            p.Start_Date__c = Date.today().addmonths(-1);
            p.End_Date__c = Date.newInstance(System.today().year(), System.today().month(), 27);
            update p;            
              
            //test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(p);
            ApexPages.currentPage().getParameters().put('oppId', opp.Id);            
            
            cp = new LightningProposalOpportunityBudgetCntrl(controller);             
            cp.endDate = Date.newInstance(System.today().year(), System.today().month(), 10);  
            cp.submitButton();  
            cp.formatDate('03/02/2021');
            cp.optionSelected = 'ReduceStartDate'; 

            cp.rowAmount = 100000;
            cp.colAmount = 20000;
            cp.scheduleString = 'Linear';
                        
            LightningProposalOpportunityBudgetCntrl.proposalZoneMonthlyWrapper wrap = new LightningProposalOpportunityBudgetCntrl.proposalZoneMonthlyWrapper();
            wrap.monthAmount = 750;
            wrap.monthKey = String.valueOf(System.today().month())+'_'+String.valueOf(System.today().year());
            wrap.scheduleType = 'Linear';
            cp.wrapList.add(wrap);

            wrap.monthAmount = 500;         
            wrap.monthKey = String.valueOf(System.today().month())+'_'+String.valueOf(System.today().year());
            wrap.scheduleType = 'Digital';
            cp.wrapList.add(wrap);

            cp.splitRowTotal();
            cp.splitColumnTotal();
            cp.save();          
            Test.stopTest();
        }
    }  
}