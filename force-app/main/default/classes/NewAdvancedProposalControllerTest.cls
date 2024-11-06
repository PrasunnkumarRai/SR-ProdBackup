// SRSF-4342
@isTest
private class NewAdvancedProposalControllerTest
{
    @testSetup
    static void prepareTestData()
    {
        User lsmUser = TestDataHelper.createLSMUser(true);
        User ae = TestDataHelper.createAEUser(false, 'ae123@charter.com', lsmUser.Id);
        ae.Division__c = 'Central';
        ae.Sales_Office__c = 'Milwaukee';
        INSERT ae;

        List<Account> accountList = new List<Account>();
        Account advAcc = TestDataHelper.createAdvertiser('Test Advertiser', 'KPHB', 'Hyderabad', 'Telangana', '500090', 'India');                        
        Account agencyAcc = TestDataHelper.createAgency('Test Agency', 'Manikonda', 'Hyderabad', 'Telangana', '500090', 'India');
        accountList.add(advAcc);       
        accountList.add(agencyAcc);        
        INSERT accountList;

        Opportunity oppty = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',accountList[0].Id);        
        oppty.Agency_Account__c = agencyAcc.Id; 
        oppty.Enterprise_Account_Type__c ='Ampersand Local';       
        oppty.OwnerId = ae.Id;
        oppty.Discount_Code__c = 'AG0';
        oppty.OwnerId = ae.Id;
        INSERT oppty;
                  
        Proposal__c prop = TestDataHelper.createProposal('Test Pilot Proposal',oppty.Id, '00000', true);
        prop.Advertiser__c = advAcc.Id;
        prop.Agency__c = agencyAcc.Id;
        prop.Start_Date__c = System.today();
        prop.End_Date__c = System.today().addMonths(3);
        prop.Pilot_Proposal_ID__c = '1234';
        prop.Pilot_Order_ID__c = 'PL1234';
        prop.Pilot_Order_Status__c ='Accepted by Traffic';
        prop.Traffic_Order_Number__c = '12345';
        prop.Eclipse_Customer_ID__c = 'TWCA - 000189828';
        INSERT prop;
            
        Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Proposal Zone',prop.Id);
        propZone.Zone_Type__c='Digital';
        INSERT propZone;   
        
        Proposal_Zone_Monthly_Value__c propZoneMonthly = new Proposal_Zone_Monthly_Value__c();
        propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value',accountList[0].Id, propZone.Id);
        propZoneMonthly.Schedule_Type__c = 'Linear';
        propZoneMonthly.Proposal_Key_Index__c = prop.Id;
        propZoneMonthly.Broadcast_Month_Date__c = System.today().adddays(1);
        propZoneMonthly.gross_Amount__c = 100.00;
            
        INSERT propZoneMonthly;        
    }

    static testMethod void testCreateAdvProposal()
    {
        Test.startTest();
        Proposal__c prop = [SELECT Id FROM Proposal__c LIMIT 1]; 
        Map<String, Object> mapData = NewAdvancedProposalController.fetchProposalData(prop.Id);
        Assert.isTrue(mapData.Size() > 0); 
        List<String> depPickLstValues = NewAdvancedProposalController.getPicklistValues('Product_Type__c', 'Streaming TV');
        Assert.isTrue(depPickLstValues.Size()>0);
        Proposal__c advProp = NewAdvancedProposalController.createAdvancedProposal(prop.Id, 'Streaming TV', 'Streaming TV', 'Test Adv Proposal',System.today(),System.today().addMonths(3));
        System.debug('advProp RT ID>>>'+advProp.RecordTypeId);       

        Assert.isNotNull(advProp); 
        Assert.isNotNull(advProp.Pilot_Proposal__c);
        Assert.isNotNull(advProp.Start_Date__c);
        Assert.isNotNull(advProp.End_Date__c); 
        Assert.isNull(advProp.AOS_Deal_Id__c);
        Assert.areEqual(advProp.RecordtypeId, ProposalUtils.advancedProposalRtId);                        
        Test.stopTest();    
    }
}