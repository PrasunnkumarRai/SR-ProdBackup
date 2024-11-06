@isTest
private class ProposalTriggerHandlerTest {
    static opportunity opp;
    
    @testSetup
    static void prepareTestData()  
    {
        User usr = TestDataHelper.getBoomiIntegrationUser();     
        System.runAs(usr){
            Account acc = TestDataHelper.createAcc('TestAcct12', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                                
            insert acc;        
            System.debug('@@acc '+acc);        

            Account agencyRecType = TestDataHelper.createAgency('Testing23 Account','123 Wright Plaza','Omaha','NE','68130','USA');
            insert agencyRecType;
            System.debug('agencyRecrdType::'+agencyRecType.Id);        

            Id repFirmRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Rep_Firm' AND SobjectType = 'Account' LIMIT 1].Id;

            Account repFirmRecType = new Account(Name = 'Test Account',BillingStreet = '123 Wright Plaza',BillingCity = 'Omaha',
                BillingState ='NE',BillingPostalCode = '68130',BillingCountry = 'USA',Active__c = true,RecordTypeId = repFirmRecTypeId);
            insert repFirmRecType;
           
            opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
            insert opp;
            System.debug('@@opp '+opp);

            UserConnection__c connection = TestDataHelper.createUserConnection('St. Louis Local','emily.sabo',UserInfo.getUserId(),'TIM','1');   
                connection.AE_Id__c = '';
                insert connection;
                connection.AE_Id__c = '309';
                connection.user__c = UserInfo.getUserId();
                connection.TIM_System__c = connection.TIM_System__c;
            update connection;

            List<Group_Status__c> groupStatusList = new List<Group_Status__c>();

            Group_Status__c gs = TestDataHelper.createGroupStatus('Proposal', null);
            gs.Is_Closed_Won__c = true;
            gs.Is_Active__c = true;
            groupStatusList.add(gs);
            Group_Status__c gs1 = TestDataHelper.createGroupStatus('Approved by Traffic', null);
            gs1.Is_Closed_Won__c = true;
            gs1.Is_Active__c = true;
            groupStatusList.add(gs1);
            insert groupStatusList;

            Traffic_Id_Element__c trficidele = TestDataHelper.createTrafficIdElement (acc.Id, usr.Id, '1', '1111');
            trficidele.Account_TIM_ID__c='2';
            insert trficidele;

            proposal__c prop = TestDataHelper.createProposal('Test Proposal',opp.id,'76877',True); 
            prop.Advertiser__c = acc.Id;   
            prop.Active__c = false;
            prop.ProposalExternalId__c='';
            prop.TIM_Status__c = 'Proposal';  
            prop.AE_ID__c = '309';       
            prop.Current_Advertiser_Tim_Id__c = '2'; 
            prop.Agency__c = agencyRecType.Id;
            prop.Rep_Firm__c = repFirmRecType.Id;
            insert prop;
            prop.AE_ID__c = '12';
            prop.TIM_Status__c = groupStatusList[0].Name;
            prop.Proposal_Closed__c = true;
            update prop;      

            proposal__c oppBudgetProp = TestDataHelper.createProposal('Test OppBudgetProp', opp.id, NULL, TRUE);
            oppBudgetProp.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
            INSERT oppBudgetProp;

            Map<String, Object> taskFieldNameValueMapping = new Map<String, Object>{'OwnerId' => Id.valueOf(UserInfo.getUserId()), 'WhatId' => opp.Id , 'ActivityDate' =>System.today().addYears(2)};
            Task tsk = TestDataHelper.createTask(taskFieldNameValueMapping,true);
        }    
    }
    

    static testMethod void testInsertProposals() 
    {
        Test.startTest();
        createPropBigObjectSetting();               
        User usr = TestDataHelper.getBoomiIntegrationUser();     
        System.runAs(usr){
             
            List<Proposal__c> proposals = [SELECT Id, Name,AE_ID__c,Advertiser__c,Agency__c,Rep_Firm__c,Active__c,TIM_Status__c,Opportunity__c,Current_Advertiser_Tim_Id__c,RecordTypeId,ProposalExternalId__c,TIM_Id__c,TIM_system__c,Proposal_Owner__c,division__c, region__c, sales_office__c, Political_Proposal__c, Proposal_Closed__c FROM Proposal__c WHERE Name = 'Test Proposal' LIMIT 1];
            Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAcct12' LIMIT 1];
            System.debug('@@proposals '+proposals);
            
            Set<Id> proposalIds = new Set<Id>();
            List<Proposal__c> oldProposals = new List<Proposal__c>();
            oldProposals.addAll(proposals);
            for (Proposal__c pro:oldProposals) {
                proposalIds.add(pro.Id);
            }
            
            Map<ID, Proposal__c> ProposalMap = new Map<ID, Proposal__c>();
            Map<ID, Proposal__c> OldProposalMap = new Map<ID, Proposal__c>(); // SRSF-1911
            for (Proposal__c pr:proposals) {
                ProposalMap.put(pr.Id, pr);
                OldProposalMap.put(pr.Id, pr); // SRSF-1911     
                pr.TIM_Status__c = 'Approved by Traffic';
            }

            update proposals;
            System.debug('@@proposals after update '+proposals);
            
            Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Proposal Zone',proposals[0].Id);
            insert propZone;

            System.assert(propZone != null);

            propZone.Sys_Code__c = 'TestSys';
            update propZone;

            Syscode__c sysCode = new Syscode__c(Name = 'TestSys',Market__c='301',Type__c='Linear',Zone__c='102');
            insert sysCode;

            System.assert(sysCode != null);    
            
            Proposal_Zone_Monthly_Value__c propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value',acc.Id,propZone.Id);
            propZoneMonthly.Net_Amount__c = 100;
            propZoneMonthly.Gross_Amount__c = 100;
            propZoneMonthly.Broadcast_Month_Date__c = System.today();
            insert propZoneMonthly;

            System.assert(propZoneMonthly != null);

            ProposalTriggerHandler proposalHandler = new ProposalTriggerHandler(true,1);
            proposalHandler.OnBeforeInsert(proposals);        
            proposalHandler.OnAfterInsert(proposals, ProposalMap);
            System.assert(proposalHandler.IsTriggerContext);       

            Test.stopTest();
        }        
    }


    static testMethod void testUpdateProposals() 
    {                   
       
        User usr = TestDataHelper.getBoomiIntegrationUser();     
        System.runAs(usr)
        {
            Test.startTest();           
            List<Proposal__c> proposals = [SELECT Id, Name,AE_ID__c,Advertiser__c,Agency__c,Rep_Firm__c,Active__c,TIM_Status__c,Opportunity__c,Current_Advertiser_Tim_Id__c,RecordTypeId,ProposalExternalId__c,TIM_Id__c,TIM_system__c,Proposal_Owner__c,division__c, region__c, sales_office__c, Political_Proposal__c, Proposal_Closed__c,Account_Credit_Status__c,Account_Status__c FROM Proposal__c WHERE Name = 'Test Proposal' LIMIT 1];
            Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAcct12' LIMIT 1];
            System.debug('@@proposals '+proposals);

            Syscode__c sysCode = new Syscode__c(Name = 'TestSys',Market__c='301',Type__c='Linear',Zone__c='102');
            insert sysCode;

            System.assert(sysCode != null); 

            Set<Id> proposalIds = new Set<Id>();
            List<Proposal__c> oldProposals = new List<Proposal__c>();
            oldProposals.addAll(proposals);
            for (Proposal__c pro:oldProposals) {
                proposalIds.add(pro.Id);
            }
            
            Map<ID, Proposal__c> ProposalMap = new Map<ID, Proposal__c>();
            Map<ID, Proposal__c> OldProposalMap = new Map<ID, Proposal__c>(); // SRSF-1911
            for (Proposal__c pr:proposals) {
                ProposalMap.put(pr.Id, pr);
                OldProposalMap.put(pr.Id, pr); // SRSF-1911     
                pr.TIM_Status__c = 'Approved by Traffic';
            }

            update proposals;
            System.debug('@@proposals after update '+proposals);
            
            Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Proposal Zone',proposals[0].Id);
            insert propZone;

            System.assert(propZone != null);

            propZone.Sys_Code__c = 'TestSys';
            update propZone;             
            
            Proposal_Zone_Monthly_Value__c propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value',acc.Id,propZone.Id);
            propZoneMonthly.Net_Amount__c = 100;
            propZoneMonthly.Gross_Amount__c = 100;
            propZoneMonthly.Broadcast_Month_Date__c = System.today();
            insert propZoneMonthly;

            System.assert(propZoneMonthly != null);

            ProposalTriggerHandler proposalHandler = new ProposalTriggerHandler(true,1);
            proposalHandler.OnBeforeUpdate(oldProposals, proposals, OldProposalMap, ProposalMap); // SRSF-1911
            proposalHandler.OnAfterUpdate(oldProposals, proposals ,ProposalMap);
            System.assert(proposalHandler.IsTriggerContext);
            System.assertEquals(proposalHandler.IsVisualforcePageContext,false);        
            System.assertEquals(proposalHandler.IsWebServiceContext,false);
            System.assertEquals(proposalHandler.IsExecuteAnonymousContext,false);
           
            Test.stopTest();
        }        
    }


    static testMethod void testDeleteProposals() 
    {                   
        User usr = TestDataHelper.getBoomiIntegrationUser();     
        System.runAs(usr)
        {
            Test.startTest();   
            List<Proposal__c> proposals = [SELECT Id, Name,AE_ID__c,Advertiser__c,Agency__c,Rep_Firm__c,Active__c,TIM_Status__c,Opportunity__c,Current_Advertiser_Tim_Id__c,RecordTypeId FROM Proposal__c WHERE Name = 'Test Proposal' LIMIT 1];
            Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAcct12' LIMIT 1];
            System.debug('@@proposals '+proposals);

            Syscode__c sysCode = new Syscode__c(Name = 'TestSys',Market__c='301',Type__c='Linear',Zone__c='102');
            insert sysCode;

            System.assert(sysCode != null); 

            Set<Id> proposalIds = new Set<Id>();
            List<Proposal__c> oldProposals = new List<Proposal__c>();
            oldProposals.addAll(proposals);
            for (Proposal__c pro:oldProposals) {
                proposalIds.add(pro.Id);
            }
           
            Map<ID, Proposal__c> ProposalMap = new Map<ID, Proposal__c>();  
            for (Proposal__c pr:proposals) {
                ProposalMap.put(pr.Id, pr);      
            }        
            
            Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Proposal Zone',proposals[0].Id);
            insert propZone;

            System.assert(propZone != null);

            propZone.Sys_Code__c = 'TestSys';
            update propZone;             
            
            Proposal_Zone_Monthly_Value__c propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value',acc.Id,propZone.Id);
            propZoneMonthly.Net_Amount__c = 100;
            propZoneMonthly.Gross_Amount__c = 100;
            propZoneMonthly.Broadcast_Month_Date__c = System.today();
            insert propZoneMonthly;

            System.assert(propZoneMonthly != null);   
            ProposalTriggerHandler proposalHandler = new ProposalTriggerHandler(true,1);
            proposalHandler = new ProposalTriggerHandler(true,1);

            proposalHandler.OnBeforeDelete(oldProposals, ProposalMap);
            proposalHandler.OnAfterDelete(oldProposals, ProposalMap);
            ProposalTriggerHandler.OnAfterDeleteAsync(proposalIds);
            proposalHandler.OnUndelete([SELECT Id FROM Proposal__c WHERE ID IN:proposalIds ALL ROWS]);

            Boolean IsTriggerContext = proposalHandler.IsTriggerContext;
            Boolean IsVisualforcePageContext = proposalHandler.IsVisualforcePageContext;
            Boolean IsWebServiceContext = proposalHandler.IsWebServiceContext;
            Boolean IsExecuteAnonymousContext = proposalHandler.IsExecuteAnonymousContext;

            delete proposals;
            undelete proposals;
            Test.stopTest();
        }        
    }

    static testMethod void testUpdateTask() 
    {   
        Test.startTest();                
        User usr = TestDataHelper.getBoomiIntegrationUser();     
        System.runAs(usr)
        {
            List<Proposal__c> proposals = [SELECT Id, Active__c FROM Proposal__c WHERE Name = 'Test OppBudgetProp' LIMIT 1];
            System.debug('@@proposals '+proposals);
            proposals[0].Active__c = FALSE;
            UPDATE proposals[0];
        }
        Test.stopTest();

    }

    public static void createPropBigObjectSetting() {
        BigObjectSettings__c propTrendBO = new BigObjectSettings__c();
        propTrendBO.Name = 'ProposalTrend__b';
        propTrendBO.IsActive__c = true;
        propTrendBO.Rolling_Index__c = 0;
        insert propTrendBO;
    }
}