@isTest(SeeAllData=false) @testVisible 
private class TradeTriggerHandlerTest {
    static opportunity opp;

    static testMethod void testTrades() {
        createPropBigObjectSetting();
        /*String testLbl = Label.BoomiUser;        
        User usr = [SELECT Id,Name,Username FROM User where userName=:testLbl];*/
        Profile p = [select id from profile where name = 'Standard User'];
        User usr = new User(alias = 'usr', email = 'user123@testorgosius.com',
                emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                localesidkey = 'en_US', profileid = p.Id,
                timezonesidkey = 'America/Los_Angeles', username = 'sr.boomi@osius.com.preprodde',Division__c='Central'); 
        insert usr;        
        System.runAs(usr){
        Account acc = TestDataHelper.createAcc('Test Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                                
        insert acc;        
        System.debug('@@acc '+acc);        

        Account agencyRecType = TestDataHelper.createAgency('Test ',' Wright Plaza','Omah','Ny','68131','USA');
        insert agencyRecType;
        System.debug('agencyRecrdType::'+agencyRecType.Id);        

        Id repFirmRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Rep_Firm' AND SobjectType = 'Account' LIMIT 1].Id;

        Account repFirmRecType = new Account(Name = 'Test Acc',BillingStreet = 'Wright Plaza',BillingCity = 'Omaa',
            BillingState ='NE',BillingPostalCode = '68133',BillingCountry = 'USA',Active__c = true,RecordTypeId = repFirmRecTypeId);
        insert repFirmRecType;
       
        opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
        insert opp;
        System.debug('@@opp '+opp);

        Proposal__c prop = TestDataHelper.createProposal('Test Proposal',opp.id,'76877',True); 
        prop.Advertiser__c = acc.Id;   
        prop.Active__c = false;
        prop.ProposalExternalId__c='';
        prop.TIM_Status__c = 'Proposal';  
        prop.AE_ID__c = '309';        
        prop.Agency__c = agencyRecType.Id;
        prop.Rep_Firm__c = repFirmRecType.Id;
        insert prop;
        //prop.AE_ID__c = '12';
        //update prop;

        Proposal__c prop_trade = TestDataHelper.createProposal('Test Proposal',opp.id,'76877',True); 
        prop_trade.Advertiser__c = acc.Id;   
        prop_trade.Active__c = false;
        prop_trade.ProposalExternalId__c='';
        prop_trade.TIM_Status__c = 'Proposal';  
        prop_trade.AE_ID__c = '309';        
        prop_trade.Agency__c = agencyRecType.Id;
        prop_trade.Rep_Firm__c = repFirmRecType.Id;
        insert prop_trade;
        //prop_trade.AE_ID__c = '12';
        //update prop_trade;
        Document document;

		document = new Document();
		document.Body = Blob.valueOf('Some Text');
		document.ContentType = 'application/pdf';
		document.DeveloperName = 'my_document';
		document.IsPublic = true;
		document.Name = 'TradeDealRevenue';
		document.FolderId = UserInfo.getUserId();
		insert document;
      

Test.startTest();
        trade__c trade = TestDataHelper.createTrade('Test Trade1',opp.id, prop.id); 
        trade.Account__c = acc.Id;   
        trade.Trade_Proposal__c = prop_trade.id;
        insert trade;
        Trade_proposal__c tradeproposal = new Trade_proposal__c();
        tradeproposal.trade__c = trade.Id;
        tradeproposal.Trade_Proposal_Account__c = trade.Account__c;
        tradeproposal.Type_of_Proposal__c = 'Paid';
        insert tradeproposal;
       // Test.startTest();
        TradeProposalController.createTradeProposal(trade.Id);
        prop_trade.Has_Digital_Campaigns__c = true;
        update prop_trade;
        trade.Trade_Receipt_Value__c = 1;
        update trade;
        prop_trade.Has_Production_Services__c  = true;
        prop_trade.Has_Digital_Campaigns__c = false;
        //update prop_trade;
        //update trade;
        trade.Status__c = 'Draft';
        //update trade;
        prop_trade.Has_Production_Services__c  = false;
        prop_trade.Has_Digital_Campaigns__c = true;
        update prop_trade;
        update trade;


        List<Trade__c> trades = [SELECT Name FROM Trade__c WHERE ID=:trade.Id];
        System.debug('@@trades '+trades);

        Set<Id> tradeIds = new Set<Id>();
        List<Trade__c> oldTrades = new List<Trade__c>();
        oldTrades.addAll(trades);
        for (Trade__c pro:oldTrades) {
            tradeIds.add(pro.Id);
        }

        Map<ID, Trade__c> TradeMap = new Map<ID, Trade__c>();
        for (Trade__c pr:trades) {
            TradeMap.put(pr.Id, pr);
            //pr.Active__c = true;
            pr.Trade_Number__c = acc.Name + '-TRADE-1';
        }
        //System.debug('@@trades '+trades);
        update trades;
        System.debug('@@trades after update '+trades);

        TradeTriggerHandler tradeHandler = new TradeTriggerHandler(true,1);
        
        tradeHandler.OnBeforeInsert(trades);        
        tradeHandler.OnAfterInsert(trades);
        tradeHandler.OnBeforeUpdate(oldTrades, trades ,TradeMap);
        tradeHandler.OnAfterUpdate(oldTrades, trades ,TradeMap);
        System.assert(tradeHandler.IsTriggerContext);
        System.assertEquals(tradeHandler.IsVisualforcePageContext,false);        
        System.assertEquals(tradeHandler.IsWebServiceContext,false);
        System.assertEquals(tradeHandler.IsExecuteAnonymousContext,false);

        tradeHandler = new TradeTriggerHandler(true,1);
        tradeHandler.OnBeforeDelete(oldTrades, TradeMap);
        tradeHandler.OnAfterDelete(oldTrades, TradeMap);
        TradeTriggerHandler.OnAfterUpdateAsync(tradeIds);
        TradeTriggerHandler.OnAfterDeleteAsync(tradeIds);
        tradeHandler.OnUndelete([SELECT Id FROM Trade__c WHERE ID IN:tradeIds ALL ROWS]);
		
        Boolean IsTriggerContext = tradeHandler.IsTriggerContext;
        Boolean IsVisualforcePageContext = tradeHandler.IsVisualforcePageContext;
        Boolean IsWebServiceContext = tradeHandler.IsWebServiceContext;
        Boolean IsExecuteAnonymousContext = tradeHandler.IsExecuteAnonymousContext;

       delete trades;
       undelete trades;
		 Test.stopTest();
    }        
    }

    public static void createPropBigObjectSetting() {
        BigObjectSettings__c tradeTrendBO = new BigObjectSettings__c();
        tradeTrendBO.Name = 'TradeTrend__b';
        tradeTrendBO.IsActive__c = true;
        tradeTrendBO.Rolling_Index__c = 0;
        insert tradeTrendBO;
    }
}