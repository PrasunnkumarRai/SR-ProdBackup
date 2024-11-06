@isTest
private class ThirdPartyAdvancedProposalServicesTest {
    @testSetup
    static void prepareTestData()  
    {
        User lsmUser = TestDataHelper.createLSMUser(true);
        User ae = TestDataHelper.createAEUser(false, 'ae123@charter.com', lsmUser.Id);
        ae.Sales_Office__c = 'Milwaukee';
        ae.Division__c='Central';
        INSERT ae;        

        List<Account> accountList = new List<Account>();
        Account advAcc = TestDataHelper.createAdvertiser('Test Advertiser', 'KPHB', 'Hyderabad', 'Telangana', '500090', 'India');                        
        advAcc.AOS_Account_Id__c='65bd9304929d4881212f1';
        Account agencyAcc = TestDataHelper.createAgency('Test Agency', 'Manikonda', 'Hyderabad', 'Telangana', '500090', 'India');
        agencyAcc.AOS_Account_Id__c='65bd9304929d4881212f2';
        Account repFirmAcc = TestDataHelper.createRepFirm('Test RepFirm', 'Ameerpet', 'Hyderabad', 'Telangana', '500090', 'India');                        
        repFirmAcc.AOS_Account_Id__c='65bd9304929d4881212f3';
        accountList.add(advAcc);       
        accountList.add(agencyAcc);
        accountList.add(repFirmAcc);
        INSERT accountList;

        Opportunity oppty = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',accountList[0].Id);        
        oppty.Agency_Account__c = accountList[1].Id;
        oppty.Rep_Firm__c = accountList[2].Id;
        oppty.Enterprise_Account_Type__c ='Ampersand Local';
        oppty.Discount_Code__c = 'AG0';
        oppty.OwnerId = ae.Id;
        INSERT oppty;       

        Proposal__c prop = new Proposal__c();            
        prop = TestDataHelper.createProposal('Test Pilot Proposal',oppty.Id, '00000', true);
        prop.Advertiser__c = accountList[0].Id;
        prop.Agency__c = accountList[1].Id;
        prop.Start_Date__c = System.today();
        prop.End_Date__c = System.today().addMonths(3);
        prop.Pilot_Proposal_ID__c = '1234';
        prop.Pilot_Order_ID__c = 'PL1234';
        prop.Pilot_Order_Status__c ='Accepted by Traffic';
        prop.Traffic_Order_Number__c = '12345';
        prop.Eclipse_Customer_ID__c = 'TWCA - 000189828';
        prop.Pilot_Order_ID__c = 'PL28121';
        INSERT prop;
            
        Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Prop Zone', prop.Id);
        propZone.Zone_Type__c = 'Digital';
        INSERT propZone;   
        
        Proposal_Zone_Monthly_Value__c propZoneMonthly = new Proposal_Zone_Monthly_Value__c();
        propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test PZMV',accountList[0].Id, propZone.Id);
        propZoneMonthly.Schedule_Type__c = 'Linear';
        propZoneMonthly.Proposal_Key_Index__c = prop.Id;
        propZoneMonthly.Broadcast_Month_Date__c = System.today().adddays(1);
        propZoneMonthly.gross_Amount__c = 100.00;
            
        INSERT propZoneMonthly;       
    }

    static testMethod void testCreateAdvProposal() 
    {
        Test.startTest();
        Proposal__c prop =  [SELECT Id, Pilot_Order_ID__c FROM Proposal__c WHERE Name = 'Test Pilot Proposal' LIMIT 1];
        ThirdPartyAdvancedProposalServices.IncomingRequestWrapper incmgWrpr = new ThirdPartyAdvancedProposalServices.IncomingRequestWrapper();
        incmgWrpr.source = System.Label.Digital_Hub;
        incmgWrpr.userID = [SELECT Id FROM User WHERE email = 'ae123@charter.com' LIMIT 1].Id;
        incmgWrpr.pilotId = prop.Pilot_Order_ID__c;
        incmgWrpr.advancedPropId = '';
        incmgWrpr.advancedPropName = 'Test Adv Proposal';
        incmgWrpr.orderType = 'Streaming TV';
        incmgWrpr.productType = 'Streaming TV';
        incmgWrpr.startDate = String.valueOf(System.today().addDays(10));
        incmgWrpr.endDate = String.valueOf(System.today().addMonths(3));

        ThirdPartyAdvancedProposalServices.OutgoingResponseWrapper outWrpr = ThirdPartyAdvancedProposalServices.doPost(incmgWrpr);
        System.debug('outWrpr>>>>>'+outWrpr);
        System.debug('isSuccess>>>>>'+outWrpr.isSuccess);
        Assert.isTrue(outWrpr.isSuccess); 
        Assert.isNotNull(outWrpr.dealReqPayload);        
        Assert.isNull(outWrpr.errorMsg);

        // Deserialize the JSON string into an instance of the Apex class to access the sfadvancedproposalid
        AOSHelper.DealRequest data = (AOSHelper.DealRequest)JSON.deserialize(outWrpr.dealReqPayload, AOSHelper.DealRequest.class);
        System.debug('data>>>>>'+data);
        String sfadvancedproposalid = data.customFieldValues.sfadvancedproposalid;
        Assert.isNotNull(sfadvancedproposalid);
        Test.stopTest();
    }

    static testMethod void testGetAdvProposal() 
    {
        Test.startTest();
        Proposal__c prop =  [SELECT Id, Pilot_Order_ID__c, Pilot_Proposal_ID__c FROM Proposal__c WHERE Name = 'Test Pilot Proposal' LIMIT 1];
        ThirdPartyAdvancedProposalServices.IncomingRequestWrapper incmgWrpr = new ThirdPartyAdvancedProposalServices.IncomingRequestWrapper();
        incmgWrpr.source = System.Label.Architect;
        incmgWrpr.userID = [SELECT Id FROM User WHERE email = 'ae123@charter.com' LIMIT 1].Id;
        incmgWrpr.pilotId = prop.Pilot_Proposal_ID__c;
        incmgWrpr.advancedPropId = '';
        incmgWrpr.advancedPropName = 'Test Adv Proposal';
        incmgWrpr.orderType = 'Streaming TV';
        incmgWrpr.productType = 'Streaming TV';
        incmgWrpr.startDate = String.valueOf(System.today().addDays(10));
        incmgWrpr.endDate = String.valueOf(System.today().addMonths(3));

        ThirdPartyAdvancedProposalServices.OutgoingResponseWrapper outWrpr = ThirdPartyAdvancedProposalServices.doPost(incmgWrpr);
        System.debug('outWrpr>>>>>'+outWrpr);
        System.debug('isSuccess>>>>>'+outWrpr.isSuccess);
        Assert.isTrue(outWrpr.isSuccess); 
        Assert.isNotNull(outWrpr.dealReqPayload);        
        Assert.isNull(outWrpr.errorMsg);

        // Deserialize the JSON string into an instance of the Apex class to access the sfadvancedproposalid
        AOSHelper.DealRequest data = (AOSHelper.DealRequest)JSON.deserialize(outWrpr.dealReqPayload, AOSHelper.DealRequest.class);
        System.debug('data>>>>>'+data);
        String sfadvancedproposalid = data.customFieldValues.sfadvancedproposalid;
        Assert.isNotNull(sfadvancedproposalid); 
        
        // Advanced Proposal already exists in Salesforce
        ThirdPartyAdvancedProposalServices.IncomingRequestWrapper incmgWrpr1 = new ThirdPartyAdvancedProposalServices.IncomingRequestWrapper();
        incmgWrpr1.source = System.Label.Digital_Hub;
        incmgWrpr1.userID = [SELECT Id FROM User WHERE email = 'ae123@charter.com' LIMIT 1].Id;
        incmgWrpr1.pilotId = prop.Pilot_Order_ID__c;
        incmgWrpr1.advancedPropId = sfadvancedproposalid; // To get the existing Adv Proposal
        incmgWrpr1.advancedPropName = 'Test Adv Proposal';
        incmgWrpr1.orderType = 'Streaming TV';
        incmgWrpr1.productType = 'Streaming TV';
        incmgWrpr1.startDate = String.valueOf(System.today().addDays(10));
        incmgWrpr1.endDate = String.valueOf(System.today().addMonths(3));

        ThirdPartyAdvancedProposalServices.doGet();

        ThirdPartyAdvancedProposalServices.OutgoingResponseWrapper outWrpr1 = ThirdPartyAdvancedProposalServices.doPost(incmgWrpr1);
        System.debug('outWrpr>>>>>'+outWrpr1);
        Test.stopTest();
    }

    static testMethod void testInvalidSourceError() 
    {
        Test.startTest();
        Proposal__c prop =  [SELECT Id, Pilot_Order_ID__c FROM Proposal__c WHERE Name = 'Test Pilot Proposal' LIMIT 1];
        ThirdPartyAdvancedProposalServices.IncomingRequestWrapper incmgWrpr = new ThirdPartyAdvancedProposalServices.IncomingRequestWrapper();
        incmgWrpr.source = 'Test Invalid Source';
        incmgWrpr.userID = [SELECT Id FROM User WHERE email = 'ae123@charter.com' LIMIT 1].Id;
        incmgWrpr.pilotId = prop.Pilot_Order_ID__c;
        incmgWrpr.advancedPropName = 'Test Adv Proposal';
        incmgWrpr.orderType = 'Streaming TV';
        incmgWrpr.productType = 'Streaming TV';
        incmgWrpr.startDate = String.valueOf(System.today().addDays(10));
        incmgWrpr.endDate = String.valueOf(System.today().addMonths(3));

        ThirdPartyAdvancedProposalServices.OutgoingResponseWrapper outWrpr = ThirdPartyAdvancedProposalServices.doPost(incmgWrpr);
        System.debug('outWrpr>>>>>'+outWrpr);
        System.assertEquals(FALSE, outWrpr.isSuccess);           
        Test.stopTest();
    }

    static testMethod void testInvalidPilotId() 
    {
        Test.startTest();
        ThirdPartyAdvancedProposalServices.IncomingRequestWrapper incmgWrpr = new ThirdPartyAdvancedProposalServices.IncomingRequestWrapper();
        incmgWrpr.source = System.Label.Digital_Hub;
        incmgWrpr.userID = [SELECT Id FROM User WHERE email = 'ae123@charter.com' LIMIT 1].Id;
        incmgWrpr.pilotId = '1234';
        incmgWrpr.advancedPropName = 'Test Adv Proposal';
        incmgWrpr.orderType = 'Online';
        incmgWrpr.productType = 'Online Video';
        incmgWrpr.startDate = String.valueOf(System.today().addDays(10));
        incmgWrpr.endDate = String.valueOf(System.today().addMonths(3));

        ThirdPartyAdvancedProposalServices.OutgoingResponseWrapper outWrpr = ThirdPartyAdvancedProposalServices.doPost(incmgWrpr);
        System.debug('outWrpr>>>>>'+outWrpr);
        System.assertEquals(FALSE, outWrpr.isSuccess);  
        System.assertEquals(System.label.Invalid_Pilot_Prop_Id_Pilot_Order_Id, outWrpr.errorMsg);         
        Test.stopTest();
    }

    static testMethod void testPilotOrderIdError() 
    {
        Test.startTest();
        Proposal__c prop =  [SELECT Id, Pilot_Order_ID__c FROM Proposal__c WHERE Name = 'Test Pilot Proposal' LIMIT 1];
        prop.Pilot_Order_ID__c = '';
        UPDATE prop;
        ThirdPartyAdvancedProposalServices.IncomingRequestWrapper incmgWrpr = new ThirdPartyAdvancedProposalServices.IncomingRequestWrapper();
        incmgWrpr.source = System.Label.Digital_Hub;
        incmgWrpr.userID = [SELECT Id FROM User WHERE email = 'ae123@charter.com' LIMIT 1].Id;
        incmgWrpr.pilotId = prop.Pilot_Order_ID__c;
        incmgWrpr.advancedPropName = 'Test Adv Proposal';
        incmgWrpr.orderType = 'Streaming TV';
        incmgWrpr.productType = 'Streaming TV';
        incmgWrpr.startDate = String.valueOf(System.today().addDays(10));
        incmgWrpr.endDate = String.valueOf(System.today().addMonths(3));

        ThirdPartyAdvancedProposalServices.OutgoingResponseWrapper outWrpr = ThirdPartyAdvancedProposalServices.doPost(incmgWrpr);
        System.debug('outWrpr>>>>>'+outWrpr);
        System.assertEquals(false, outWrpr.isSuccess);  
        System.assertEquals(System.label.Pilot_Order_Id_Pilot_Prop_Id_is_mandatory, outWrpr.errorMsg);         
        Test.stopTest();
    }

    /*static testMethod void testNonDigitalProposalError() 
    {
        Test.startTest();
        Proposal__c prop =  [SELECT Id, Pilot_Order_ID__c FROM Proposal__c WHERE Name = 'Test Pilot Proposal' LIMIT 1];
        Proposal_Zone__c pz = [SELECT Id, Zone_Type__c FROM Proposal_Zone__c WHERE Proposal__c = :prop.Id LIMIT 1];
        pz.Zone_Type__c = 'Linear';
        UPDATE pz;
        ThirdPartyAdvancedProposalServices.IncomingRequestWrapper incmgWrpr = new ThirdPartyAdvancedProposalServices.IncomingRequestWrapper();
        incmgWrpr.source = System.Label.Digital_Hub;
        incmgWrpr.userID = [SELECT Id FROM User WHERE email = 'ae123@charter.com' LIMIT 1].Id;
        incmgWrpr.pilotId = prop.Pilot_Order_ID__c;
        incmgWrpr.advancedPropName = 'Test Adv Proposal';
        incmgWrpr.orderType = 'Streaming TV';
        incmgWrpr.productType = 'Streaming TV';
        incmgWrpr.startDate = String.valueOf(System.today().addDays(2));
        incmgWrpr.endDate = String.valueOf(System.today().addMonths(3));

        ThirdPartyAdvancedProposalServices.OutgoingResponseWrapper outWrpr = ThirdPartyAdvancedProposalServices.doPost(incmgWrpr);
        System.debug('outWrpr>>>>>'+outWrpr);
        System.assertEquals(false, outWrpr.isSuccess);  
        System.assertEquals(System.label.Advanced_Prop_can_t_be_created_for_Non_Digital_Proposal_Zones, outWrpr.errorMsg);         
        Test.stopTest();
    }*/

    static testMethod void testInactiveProposalError() 
    {
        Test.startTest();
        Proposal__c prop =  [SELECT Id, Pilot_Order_ID__c FROM Proposal__c WHERE Name = 'Test Pilot Proposal' LIMIT 1];
        prop.Active__c = FALSE;
        UPDATE prop;

        ThirdPartyAdvancedProposalServices.IncomingRequestWrapper incmgWrpr = new ThirdPartyAdvancedProposalServices.IncomingRequestWrapper();
        incmgWrpr.source = System.Label.Digital_Hub;
        incmgWrpr.userID = [SELECT Id FROM User WHERE email = 'ae123@charter.com' LIMIT 1].Id;
        incmgWrpr.pilotId = prop.Pilot_Order_ID__c;
        incmgWrpr.advancedPropName = 'Test Adv Proposal';
        incmgWrpr.orderType = 'Streaming TV';
        incmgWrpr.productType = 'Streaming TV';
        incmgWrpr.startDate = String.valueOf(System.today().addDays(10));
        incmgWrpr.endDate = String.valueOf(System.today().addMonths(3));

        ThirdPartyAdvancedProposalServices.OutgoingResponseWrapper outWrpr = ThirdPartyAdvancedProposalServices.doPost(incmgWrpr);
        System.debug('outWrpr>>>>>'+outWrpr);
        System.assertEquals(false, outWrpr.isSuccess); 
        System.assertEquals(System.label.Advanced_Proposal_can_t_be_created_for_Inactive_Proposals, outWrpr.errorMsg);          
        Test.stopTest();
    }

    static testMethod void testClosedLostOppError() 
    {
        Test.startTest();
        Proposal__c prop =  [SELECT Id, Opportunity__c, Pilot_Order_ID__c FROM Proposal__c WHERE Name = 'Test Pilot Proposal' LIMIT 1];
        Opportunity opp = [SELECT Id, StageName, Loss_Reason__c FROM Opportunity WHERE Id = :prop.Opportunity__c];
        opp.StageName = 'Closed Lost';
        opp.Loss_Reason__c = 'Test';
        UPDATE opp;

        ThirdPartyAdvancedProposalServices.IncomingRequestWrapper incmgWrpr = new ThirdPartyAdvancedProposalServices.IncomingRequestWrapper();
        incmgWrpr.source = System.Label.Digital_Hub;
        incmgWrpr.userID = [SELECT Id FROM User WHERE email = 'ae123@charter.com' LIMIT 1].Id;
        incmgWrpr.pilotId = prop.Pilot_Order_ID__c;
        incmgWrpr.advancedPropName = 'Test Adv Proposal';
        incmgWrpr.orderType = 'Streaming TV';
        incmgWrpr.productType = 'Streaming TV';
        incmgWrpr.startDate = String.valueOf(System.today().addDays(10));
        incmgWrpr.endDate = String.valueOf(System.today().addMonths(3));

        ThirdPartyAdvancedProposalServices.OutgoingResponseWrapper outWrpr = ThirdPartyAdvancedProposalServices.doPost(incmgWrpr);
        System.debug('outWrpr>>>>>'+outWrpr);
        System.assertEquals(false, outWrpr.isSuccess); 
        System.assertEquals(System.label.Advanced_Prop_Cannot_be_created_for_Closed_Lost_Opportunities, outWrpr.errorMsg);          
        Test.stopTest();
    }

    static testMethod void testOutOfFlightDatesRangeError() 
    {
        Test.startTest();
        Proposal__c prop =  [SELECT Id, Pilot_Order_ID__c FROM Proposal__c WHERE Name = 'Test Pilot Proposal' LIMIT 1];
        ThirdPartyAdvancedProposalServices.IncomingRequestWrapper incmgWrpr = new ThirdPartyAdvancedProposalServices.IncomingRequestWrapper();
        incmgWrpr.source = System.Label.Digital_Hub;
        incmgWrpr.userID = [SELECT Id FROM User WHERE email = 'ae123@charter.com' LIMIT 1].Id;
        incmgWrpr.pilotId = prop.Pilot_Order_ID__c;
        incmgWrpr.advancedPropName = 'Test Adv Proposal';
        incmgWrpr.orderType = 'Streaming TV';
        incmgWrpr.productType = 'Streaming TV';
        incmgWrpr.startDate = String.valueOf(System.today().addDays(10));
        incmgWrpr.endDate = String.valueOf(System.today().addMonths(4));

        ThirdPartyAdvancedProposalServices.OutgoingResponseWrapper outWrpr = ThirdPartyAdvancedProposalServices.doPost(incmgWrpr);
        System.debug('outWrpr>>>>>'+outWrpr);
        System.assertEquals(false, outWrpr.isSuccess);  
        System.assertEquals(System.label.Adv_Prop_Dates_must_be_within_Prop_Dates_Range, outWrpr.errorMsg);         
        Test.stopTest();
    }


    static testMethod void testPastDatesError() 
    {
        Test.startTest();
        Proposal__c prop =  [SELECT Id, Pilot_Order_ID__c FROM Proposal__c WHERE Name = 'Test Pilot Proposal' LIMIT 1];
        ThirdPartyAdvancedProposalServices.IncomingRequestWrapper incmgWrpr = new ThirdPartyAdvancedProposalServices.IncomingRequestWrapper();
        incmgWrpr.source = System.Label.Digital_Hub;
        incmgWrpr.userID = [SELECT Id FROM User WHERE email = 'ae123@charter.com' LIMIT 1].Id;
        incmgWrpr.pilotId = prop.Pilot_Order_ID__c;
        incmgWrpr.advancedPropName = 'Test Adv Proposal';
        incmgWrpr.orderType = 'Streaming TV';
        incmgWrpr.productType = 'Streaming TV';
        incmgWrpr.startDate = String.valueOf(System.today().addDays(-5));
        incmgWrpr.endDate = String.valueOf(System.today().addMonths(3));

        ThirdPartyAdvancedProposalServices.OutgoingResponseWrapper outWrpr = ThirdPartyAdvancedProposalServices.doPost(incmgWrpr);
        System.debug('outWrpr>>>>>'+outWrpr);
        System.assertEquals(false, outWrpr.isSuccess);  
        System.assertEquals(System.label.Adv_Prop_Dates_must_be_in_future_Dates, outWrpr.errorMsg);         
        Test.stopTest();
    }
}