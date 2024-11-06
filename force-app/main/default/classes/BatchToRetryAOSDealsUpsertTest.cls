@isTest
private class BatchToRetryAOSDealsUpsertTest 
{
    @testSetup
    static void prepareTestData()  
    {
        AccountTriggerHandler.isFirstTime = false;    

        User lsmUser = TestDataHelper.createLSMUser(true);
        User ae = TestDataHelper.createAEUser(false, 'ae123@charter.com', lsmUser.Id);
        ae.Division__c='Central';
        ae.Sales_Office__c = 'Milwaukee';
        INSERT ae;

        List<Account> accountList = new List<Account>();
        Account advAcc = TestDataHelper.createAdvertiser('Test Advertiser', 'KPHB', 'Hyderabad', 'Telangana', '500090', 'India');                        
        advAcc.Credit_Status__c = 'Pending';
        advAcc.AOS_Account_Id__c='65bd9304929d4881212f1';   
        INSERT advAcc;

        Opportunity oppty = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',advAcc.Id);
        oppty.Enterprise_Account_Type__c ='Ampersand Local';
        oppty.OwnerId = ae.Id;        
        INSERT oppty;       

        Proposal__c prop = new Proposal__c();            
        prop = TestDataHelper.createProposal('Test Pilot Proposal',oppty.Id, '00000', true);
        prop.Advertiser__c = advAcc.Id;    
        prop.Start_Date__c = System.today();
        prop.End_Date__c = System.today().addMonths(12);
        prop.Pilot_Proposal_ID__c = '1234';
        prop.Pilot_Order_ID__c = 'PL1234';
        
        prop.Traffic_Order_Number__c = '12345';
        prop.Eclipse_Customer_ID__c = 'TWCA - 000189828';
        INSERT prop;
            
        Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Proposal Zone',prop.Id);
        propZone.Zone_Type__c='Digital';
        INSERT propZone;   
        
        Proposal_Zone_Monthly_Value__c propZoneMonthly = new Proposal_Zone_Monthly_Value__c();
        propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value',advAcc.Id, propZone.Id);
        propZoneMonthly.Schedule_Type__c = 'Linear';
        propZoneMonthly.Proposal_Key_Index__c = prop.Id;
        propZoneMonthly.Broadcast_Month_Date__c = System.today().adddays(1);
        propZoneMonthly.gross_Amount__c = 100.00;
            
        INSERT propZoneMonthly;    
    }

    static testMethod void RetryAOSUpsertDealsTest() 
    {
        Test.setMock(HttpCalloutMock.class, new AOSWebServiceMock(200));
        Test.startTest();
        List<Proposal__c> insertPropLst = new List<Proposal__c>();
        List<Proposal__c> propLst = new List<Proposal__c>();
        Proposal__c pilotProp = [SELECT Id, Opportunity__c, Opportunity__r.OwnerId, Sales_Office__c, Division__c, Region__c, Eclipse_Customer_ID__c, Traffic_Order_Number__c,Advertiser__c, Agency__c, Rep_Firm__c FROM Proposal__c WHERE Name = 'Test Pilot Proposal' LIMIT 1];
        
        Proposal__c advProp1 = TestDataHelper.createAdvancedProposal(pilotProp, 'Streaming TV', 'Streaming TV', 'Test Adv Proposal-1', FALSE);
        insertPropLst.add(advProp1);                
        
        Proposal__c advProp2 = TestDataHelper.createAdvancedProposal(pilotProp, 'Streaming TV', 'Addressable', 'Test Adv Proposal-2', FALSE);
        insertPropLst.add(advProp2);        

        Proposal__c advProp3 = TestDataHelper.createAdvancedProposal(pilotProp, 'Streaming TV', 'Streaming TV', 'Test Adv Proposal-3', FALSE);
        insertPropLst.add(advProp3);        

        /*Proposal__c advProp4 = TestDataHelper.createAdvancedProposal(pilotPropId, 'Online', 'Display;Online Video', 'Test Online Adv Proposal-4', System.today().addDays(4), System.today().addMonths(4));
        insertPropLst.add(advProp4);        

        Proposal__c advProp5 = TestDataHelper.createAdvancedProposal(pilotPropId, 'Online', 'Online Video', 'Test Online Adv Proposal-5', System.today().addDays(5), System.today().addMonths(5));
        insertPropLst.add(advProp5);        

        Proposal__c advProp6 = TestDataHelper.createAdvancedProposal(pilotPropId, 'Online', 'Online Video;Display', 'Test Online Adv Proposal-6', System.today().addDays(3), System.today().addMonths(3));
        insertPropLst.add(advProp6);*/        

        INSERT insertPropLst;

        advProp1.AOS_Deal_Id__c = '1231';
        advProp1.AOS_Deal_Status__c = 'Draft Plan';
        advProp1.AOS_Bad_Sync__c = true;
        propLst.add(advProp1);

        advProp2.AOS_Deal_Id__c = '1232';
        advProp2.AOS_Deal_Status__c = 'Draft Plan';
        advProp2.AOS_Bad_Sync__c = false;
        propLst.add(advProp2);

        advProp3.AOS_Deal_Id__c = '1233';
        advProp3.AOS_Deal_Status__c = 'Draft Plan';
        advProp3.AOS_Bad_Sync__c = true;
        propLst.add(advProp3);

        /*advProp4.AOS_Bad_Sync__c = true;
        advProp4.AOS_Deal_Id__c = '';
        propLst.add(advProp4);

        advProp5.AOS_Bad_Sync__c = false;
        advProp5.AOS_Deal_Id__c = '1235';
        propLst.add(advProp5);

        advProp6.AOS_Bad_Sync__c = true;
        advProp6.AOS_Deal_Id__c = '';
        propLst.add(advProp6);*/

        UPDATE propLst;  

        //Assert.isTrue(propLst.Size() > 0);   
        Assert.areEqual(2,[SELECT COUNT() FROM Proposal__c WHERE AOS_Bad_Sync__c=TRUE]);

        BatchToRetryAOSDealsUpsert dealsBatch = new BatchToRetryAOSDealsUpsert();
        SchedulableContext sc;
        dealsBatch.execute(sc);
        Test.stopTest();
    }
}