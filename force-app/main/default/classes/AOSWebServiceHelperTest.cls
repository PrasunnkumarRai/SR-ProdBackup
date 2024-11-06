@isTest
private class AOSWebServiceHelperTest {    
    
    @testSetup
    static void prepareTestData()  
    {
        AccountTriggerHandler.isFirstTime = false;
     // ProposalTriggerHandler.isFirstTimeExecuting = false;

        User lsmUser = TestDataHelper.createLSMUser(true);
        User ae = TestDataHelper.createAEUser(false, 'ae123@charter.com', lsmUser.Id);
        ae.Division__c='Central';
        ae.Sales_Office__c = 'Milwaukee';
        INSERT ae;

        List<Account> accountList = new List<Account>();
        Account advAcc = TestDataHelper.createAdvertiser('Test Advertiser', 'KPHB', 'Hyderabad', 'Telangana', '500090', 'India');                        
        Account agencyAcc = TestDataHelper.createAgency('Test Agency', 'Manikonda', 'Hyderabad', 'Telangana', '500090', 'India');
        accountList.add(advAcc);       
        accountList.add(agencyAcc);        
        INSERT accountList;

        Opportunity oppty = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',advAcc.Id);        
        oppty.Agency_Account__c = agencyAcc.Id;
        oppty.Enterprise_Account_Type__c ='NSM Direct'; 
        oppty.Discount_Code__c = 'A15RP10';  
        oppty.OwnerId = ae.Id;     
        INSERT oppty;       

        Proposal__c prop = new Proposal__c();            
        prop = TestDataHelper.createProposal('Test Pilot Proposal',oppty.Id, '00000', true);
        prop.Advertiser__c = advAcc.Id;    
        prop.Start_Date__c = System.today();
        prop.End_Date__c = System.today().addMonths(3);
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

    public static testMethod void createAOSDealTest()
    { 
        List<Account> accountList = new List<Account>(); 
        AOSWebServiceHelper.mock = new AOSWebServiceMock(200);    
        Test.StartTest();        
        Account agencyAcc = [SELECT Id, AOS_Account_Id__c FROM Account WHERE Name = 'Test Agency' LIMIT 1];
        agencyAcc.AOS_Account_Id__c='65bd9304929d4881212f2'; 
        UPDATE agencyAcc;
        
        Account repFirmAcc = TestDataHelper.createRepFirm('Test RepFirm', 'Ameerpet', 'Hyderabad', 'Telangana', '500090', 'India');
        repFirmAcc.AOS_Account_Id__c='65bd9304929d4881212f3'; 
        INSERT repFirmAcc;
        
        Proposal__c prop = [SELECT Id, Opportunity__c, Opportunity__r.OwnerId, Sales_Office__c, Division__c, Region__c, Eclipse_Customer_ID__c, Traffic_Order_Number__c,Advertiser__c, Agency__c, Rep_Firm__c FROM Proposal__c WHERE Name = 'Test Pilot Proposal' LIMIT 1];
        prop.Agency__c = agencyAcc.Id;
        prop.Rep_Firm__c = repFirmAcc.Id;
        UPDATE prop; 
        
        Proposal__c advProp = TestDataHelper.createAdvancedProposal(prop, 'Streaming TV', 'Streaming TV', 'Test Adv Proposal', TRUE);        

        Account advAcc = [SELECT Id, AOS_Account_Id__c FROM Account WHERE Name = 'Test Advertiser' LIMIT 1];
        advAcc.AOS_Account_Id__c='65bd9304929d4881212f1';        
        UPDATE advAcc;        
                
        Assert.isNotNull(advProp);        
        AOSWebServiceHelper.sendReqToCreateAOSDeal(advProp.Id);
        Proposal__c advProposal =  [SELECT Id, AOS_Deal_Id__c, AOS_Bad_Sync__c FROM Proposal__c WHERE Name LIKE '%Test Adv Proposal' LIMIT 1];

        System.debug('Deal ID>>>>'+advProposal.AOS_Deal_Id__c); 
        System.debug('Bad Sync>>>>'+advProposal.AOS_Bad_Sync__c); 
        Assert.isNotNull (advProposal.AOS_Deal_Id__c);
        Assert.isFalse (advProposal.AOS_Bad_Sync__c);
        Test.StopTest();
    }

    public static testMethod void createAOSDealFailureTest()
    { 
        List<Account> accountList = new List<Account>(); 
        AOSWebServiceHelper.mock = new AOSWebServiceMock(400); 

        Test.StartTest();  
        Proposal__c prop = [SELECT Id, Opportunity__c, Opportunity__r.OwnerId, Sales_Office__c, Division__c, Region__c, Eclipse_Customer_ID__c, Traffic_Order_Number__c,Advertiser__c, Agency__c, Rep_Firm__c FROM Proposal__c WHERE Name = 'Test Pilot Proposal' LIMIT 1];
    
        Proposal__c advProp = TestDataHelper.createAdvancedProposal(prop, 'Streaming TV', 'Streaming TV', 'Test Adv Proposal', TRUE);         
        Assert.isNotNull(advProp);    

        Account advAcc = [SELECT Id, AOS_Account_Id__c FROM Account WHERE Name = 'Test Advertiser' LIMIT 1];
        advAcc.AOS_Account_Id__c='65bd9304929d4881212f1';
        UPDATE advAcc; 
    
        AOSWebServiceHelper.sendReqToCreateAOSDeal(advProp.Id);
        Proposal__c advProposal = [SELECT Id, AOS_Deal_Id__c, AOS_Bad_Sync__c FROM Proposal__c WHERE Name = 'Test Adv Proposal' LIMIT 1];

        System.debug('Bad Sync>>>>'+advProposal.AOS_Bad_Sync__c);
        Assert.isTrue(advProposal.AOS_Bad_Sync__c);    
        Assert.isNull (advProposal.AOS_Deal_Id__c);
        Test.StopTest();
    }

    public static testMethod void UpsertAdvertiserTest()
    {
        Test.StartTest();   
        AOSWebServiceHelper.mock = new AOSWebServiceMock(200);      
        Account advAcc = [SELECT Id, AOS_Account_Id__c FROM Account WHERE Name = 'Test Advertiser' LIMIT 1];
        advAcc.AOS_Account_Id__c='A-12345';        
        advAcc.Name = 'Test Advertiser Name Updated';
        advAcc.Credit_Status__c = 'Pending';    
        UPDATE advAcc;
        Test.StopTest();
        Account advertiserAcc = [SELECT Id, AOS_Account_Id__c, AOS_Bad_Sync__c FROM Account WHERE Name = 'Test Advertiser Name Updated' LIMIT 1];        
        System.debug('Bad Sync>>>>'+advertiserAcc.AOS_Bad_Sync__c);
        System.debug('AOS Account ID>>>>'+advertiserAcc.AOS_Account_Id__c);
        Assert.isFalse(advertiserAcc.AOS_Bad_Sync__c);        
    }  

    public static testMethod void UpdateAgencyTest() 
    {
        Test.StartTest();     
        AOSWebServiceHelper.mock = new AOSWebServiceMock(200);
         Account agencyAcc = TestDataHelper.createAgency('Test Agency-1', 'Manikonda', 'Hyderabad', 'Telangana', '500090', 'India');
        INSERT agencyAcc; 
   
        AccountTriggerHandler.isFirstTime=TRUE;
        agencyAcc.AOS_Account_Id__c ='R-1234';
        agencyAcc.Name = 'Test Agency Name Update';
        agencyAcc.Credit_Status__c = 'Cash In Advance';
        UPDATE agencyAcc;      
    
        Test.StopTest();           
    }

    public static testMethod void UpdateRepFirmTest()
    {       
        Test.StartTest();
        AOSWebServiceHelper.mock = new AOSWebServiceMock(200); 
        Account repFirmAcc = TestDataHelper.createRepFirm('Test RepFirm', 'Ameerpet', 'Hyderabad', 'Telangana', '500090', 'India');
        INSERT repFirmAcc;

        repFirmAcc.AOS_Account_Id__c = '';
        repFirmAcc.Credit_Status__c = '';       
        UPDATE repFirmAcc;

        AccountTriggerHandler.isFirstTime=TRUE;
        repFirmAcc.Name = 'Test RepFirm Updated';
        repFirmAcc.Credit_Status__c = 'Cash In Advance';
        UPDATE repFirmAcc;
        Test.StopTest();
    }

    
    public static testMethod void UpsertDealTest()
    {  
        Test.StartTest();
        AOSWebServiceHelper.mock = new AOSWebServiceMock(200);       
        Account advAcc = [SELECT Id, AOS_Account_Id__c FROM Account WHERE Name = 'Test Advertiser' LIMIT 1];
        Opportunity oppty = [SELECT Id, Enterprise_Account_Type__c FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        Assert.isNotNull(oppty);
        
        Proposal__c prop = [SELECT Id, Opportunity__c, Opportunity__r.OwnerId, Sales_Office__c, Division__c, Region__c, Eclipse_Customer_ID__c, Traffic_Order_Number__c,Advertiser__c, Agency__c, Rep_Firm__c FROM Proposal__c WHERE Name = 'Test Pilot Proposal' LIMIT 1];

        Proposal__c advProposal = TestDataHelper.createAdvancedProposal(prop, 'Streaming TV', 'Streaming TV', 'Test Adv Proposal', TRUE);        

        advProposal.AOS_Deal_Id__c = '1234';
        advProposal.AOS_Deal_Status__c = 'Draft Plan';
        UPDATE advProposal;
        Assert.isNotNull(advProposal);
        
        advAcc.AOS_Account_Id__c='65bd9304929d4881212f1';
        UPDATE advAcc;        
        oppty.Enterprise_Account_Type__c = 'Ampersand National';
        UPDATE oppty;
        
		System.enqueueJob(new AOSWebServiceHelper.AOSDealUpdateQueueable(new Set<Id>{advProposal.Id}));
        System.enqueueJob(new AOSWebServiceHelper.AOSDealUpdateOfOppQueueable(new Set<Id>{oppty.Id}));
        Test.StopTest();
    } 

    // Deals must be synced when a Pilot Proposal is Updated
       public static testMethod void UpsertPilotProposalDealsTest()
    {  
        Test.StartTest();
        AOSWebServiceHelper.mock = new AOSWebServiceMock(200);
        Proposal__c prop = [SELECT Id, Name, Opportunity__c, Opportunity__r.OwnerId, Sales_Office__c, Division__c, Region__c, Pilot_Order_ID__c, Pilot_Order_Status__c, Traffic_Order_Number__c, Eclipse_Customer_ID__c, Advertiser__c, Agency__c, Rep_Firm__c FROM Proposal__c WHERE Name = 'Test Pilot Proposal' LIMIT 1];

        Proposal__c advProposal = TestDataHelper.createAdvancedProposal(prop, 'Streaming TV', 'Streaming TV', 'Test Adv Proposal', TRUE);        
                 
        advProposal.AOS_Deal_Id__c = '1234';
        advProposal.AOS_Deal_Status__c = 'Draft Plan';
        UPDATE advProposal;
        System.assert(advProposal!=NULL); 

        prop.Pilot_Proposal_ID__c = '26416';
        prop.Pilot_Order_ID__c = 'PL26416';
        prop.Pilot_Order_Status__c = 'Accepted By Traffic';
        prop.Traffic_Order_Number__c = 'XGT2 11592911';
        prop.Eclipse_Customer_ID__c = 'XGT2 500085028';
        prop.Division__c = 'Local';
        prop.Region__c = 'West';
        prop.Sales_Office__c = 'Auto';  
        UPDATE prop;
        Test.StopTest();
    }  
}