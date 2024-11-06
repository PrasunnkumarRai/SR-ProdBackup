@isTest 
private class TransferDigitalCampaignBatchTest {

	@isTest
	private static void digitalcampaigntest() {
	 Account acc = TestUtil.getAccountRec();
        acc.primary_commodity__c =   'Auto Aftermarket';
        insert acc;
        List<Test_Data_Utility__mdt> ucList = new List<Test_Data_Utility__mdt>();
        
        Map<String,String> TestData = new Map<String, String>();
        
         ucList = [Select DeveloperName, label from Test_Data_Utility__mdt ];
        for(Test_Data_Utility__mdt abcd : ucList)
        {
            TestData.put(abcd.DeveloperName, abcd.label);
        }
       system.debug('TestData=-=====> '+ TestData.get('Region_c_1'));
        
        User userAE = TestUtil.prepareUser();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@mands.com';
        userAE.Budget_type__c = 'Local';
        userAE.Budget_product_Lines__c = 'Linear/News/Sports';
        userAE.rate_plan_status__c = 'Draft';
        userAE.Rate_Plan_Commit_Date__c =Date.newInstance(2019, 01, 10);
        userAE.Region__c=TestData.get('Region_c_1');
       // userAE.HR_Name__c='ans';
        insert userAE;

        
        Profile pro2 = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        
		User u2 = TestUtil.prepareUser();
        //Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        u2.ProfileId = objProfile.Id;
        u2.Username = 'testu2@mands.com';
        u2.Budget_type__c = 'Local';
        u2.Budget_product_Lines__c = 'Linear/News/Sports';
        u2.rate_plan_status__c = 'Draft';
        u2.Rate_Plan_Commit_Date__c =Date.newInstance(2019, 01, 10);
        u2.Region__c=TestData.get('Region_c_1');
       // userAE.HR_Name__c='ans';
        insert u2;
        
		System.debug(u2.Name);
        Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
        att.Division__c = TestData.get('Division_c_1');
        att.Region__c = TestData.get('Region_c_1');
        att.Status__c = 'Approved';
        att.Transfer_Effective_Date__c = Date.newInstance(2018, 01, 15);
        insert att;
        
        map<String, Id> mapRecordTypeId = new map<String, Id>();
        for( RecordType accRT : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND ( DeveloperName='Agency_Account' OR DeveloperName='Advertiser_Account' )]){
        	mapRecordTypeId.put( accRT.DeveloperName, accRT.Id );
        }
        
        
        Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
        atm.Account__c = acc.Id;
        atm.Account_Transfer_Simulation__c = att.Id;
        atm.From_User__c = userAE.Id;
        atm.To_User__c = u2.Id;
		atm.Count_of_NBUC_Success__c = 0;
        atm.External_ID__c = Userinfo.getUserId()+';;;'+acc.Id+';;;'+'2018Jan'+';;;'+Userinfo.getUserId();
        insert atm;
        
        Account_Transfer_Tool__c ats = new Account_Transfer_Tool__c();
        insert ats;
        List<Admin_Tool_Status_Summary__c>adminToolSmry=new list<Admin_Tool_Status_Summary__c>();
        
        Admin_Tool_Status_Summary__c ob = new Admin_Tool_Status_Summary__c();
        ob.From_User_Id__c = userAE.Id;
        ob.To_User_Id__c = u2.Id;
        ob.Proposal_End_Date__c = String.valueOf(Date.today());
        ob.Job_Type__c = 'AE Transfer';
        ob.Transfer_Details__c = atm.Id; 
        adminToolSmry.add(ob);
        insert adminToolSmry;


			        Account AdsAccount = new Account(Name='Test new Ads Account', RecordTypeId=mapRecordTypeId.get('Advertiser_Account'), BillingStreet = '2235 High St',
	            BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
	            BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
	            ShippingPostalCode = '265105', ShippingCountry = 'USA', Legal_Entity_Name__c='Test Legal Name' );
	            
	        Account AgencyAccount = new Account(Name='Test New Agency Account', RecordTypeId=mapRecordTypeId.get('Agency_Account'), BillingStreet = '2135 High St',
	            BillingCity = 'Morgantown', BillingState = 'WestV', BillingPostalCode = '26505',
	            BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
	            ShippingPostalCode = '265025', ShippingCountry = 'USA' );
	        
	        insert new list<Account>{ AdsAccount, AgencyAccount };
	              System.runAs( userAE ){

	        RecordType opptyRT = [SELECT Id FROM RecordType WHERE SObjectType='Opportunity' AND DeveloperName='Opportunity' limit 1];
	        Opportunity testOppty = new Opportunity();
	        testOppty.Name = 'Test Opportunity';
	        testOppty.RecordTypeId = opptyRT.Id;
	        testOppty.StageName='Proposal Presentation';
	        testOppty.CloseDate = System.Today().addDays( 30 );
	        testOppty.AccountId = AdsAccount.id;
	        testOppty.Agency_Account__c = AgencyAccount.Id;
	        insert testOppty;
	        
	        RecordType proposalRT = [SELECT Id FROM RecordType WHERE SobjectType='Proposal__c' AND DeveloperName='Linear' limit 1];
	        Proposal__c testProposal = new Proposal__c();
	        testProposal.Name = 'Test Proposal';
	        testProposal.TIM_System__c = 'Dallas';
	        testProposal.Start_Date__c = SYstem.Today();
	        testProposal.End_Date__c = System.Today().addDays( 7 );
	        testProposal.Opportunity__c = testOppty.Id;
	        testProposal.Advertiser__c = AdsAccount.Id; 
	        testProposal.RecordTypeId = proposalRT.Id;
	        insert testProposal;
	        
	        RecordType dcRT = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Digital_Campaign__c' AND DeveloperName='New_Ads_Everywhere' limit 1];
	        Digital_Campaign__c dcampaign = new Digital_Campaign__c();
	        dcampaign.Proposal__c = testProposal.Id;
	        dcampaign.RecordTypeId = dcRT.Id;
	       // dcampaign.Status__c = '19 Revision Live';
	    	dcampaign.Campaign_Name__c = testProposal.Name+' - Ads Everywhere';
	        dcampaign.Advertiser__c = AdsAccount.Id;
	        dcampaign.Agency__c = AgencyAccount.id;
	        dcampaign.Opportunity__c = testOppty.Id;
	        dcampaign.Account_Executive__c = testOppty.OwnerId;
	        dcampaign.Campaign_End_Date__c = System.today().addDays( 10 );
	        dcampaign.Campaign_Start_Date__c = System.today();
	        //insert dcampaign;
	        
	        Digital_Campaign__c dcampaign2 = new Digital_Campaign__c();
	        dcampaign2.Proposal__c = testProposal.Id;
	        dcampaign2.RecordTypeId = dcRT.Id;
	        //dcampaign2.Status__c = '09 Live';
	    	dcampaign2.Campaign_Name__c = testProposal.Name+' - Ads Everywhere';
	        dcampaign2.Advertiser__c = AdsAccount.Id;
	        dcampaign2.Agency__c = AgencyAccount.id;
	        dcampaign2.Opportunity__c = testOppty.Id;
	        dcampaign2.Account_Executive__c = testOppty.OwnerId;
	        dcampaign2.Campaign_End_Date__c = System.today().addDays( 10 );
	        dcampaign2.Campaign_Start_Date__c = System.today();
	        insert dcampaign2;

			Test.StartTest();

        TransferDigitalCampaignBatch obj=new TransferDigitalCampaignBatch('',adminToolSmry,ats.ID);
		obj.IsRetry = true;
        Database.executeBatch(obj,2);
        Test.stopTest();  
			}
	}
}