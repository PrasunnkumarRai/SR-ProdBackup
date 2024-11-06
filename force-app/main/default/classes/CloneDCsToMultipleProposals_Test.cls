@isTest
private class CloneDCsToMultipleProposals_Test {
    private final static Integer MAX_RESULTS = 5;
    
    @testSetup static void setup(){
        
        map<String, Id> mapRecordTypeId = new map<String, Id>();
        for( RecordType accRT : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND ( DeveloperName='Agency_Account' OR DeveloperName='Advertiser_Account' )]){
        	mapRecordTypeId.put( accRT.DeveloperName, accRT.Id );
        }
        User userAE = TestUtil.prepareUser();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@mands.com';
        userAE.Email = 'testae@charter.com';
        userAE.Division__c = 'Central';
        //update userObj;
        
        User userObj = TestUtil.prepareUser();
        userObj.Approving_Manager__c = UserInfo.getUserId();
        userObj.Division__c = 'Central';
        insert new list<User>{ userObj, userAE };
        
        Proposal__c testProposal;
        Account AdsAccount;
        Account AgencyAccount;
        Opportunity testOppty;

        System.runAs( userObj ){
	        AdsAccount = new Account(Name='Test Ads Account', RecordTypeId=mapRecordTypeId.get('Advertiser_Account'), BillingStreet = '235 High St',
	            BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
	            BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
	            ShippingPostalCode = '26505', ShippingCountry = 'USA', Legal_Entity_Name__c='Test Legal Name' );
	            
	        AgencyAccount = new Account(Name='Test Agency Account', RecordTypeId=mapRecordTypeId.get('Agency_Account'), BillingStreet = '235 High St',
	            BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
	            BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
	            ShippingPostalCode = '26505', ShippingCountry = 'USA' );
	        
	        insert new list<Account>{ AdsAccount, AgencyAccount };
	        
	        RecordType opptyRT = [SELECT Id FROM RecordType WHERE SObjectType='Opportunity' AND DeveloperName='Opportunity' limit 1];
	        testOppty = new Opportunity();
	        testOppty.Name = 'Test Opportunity';
	        testOppty.RecordTypeId = opptyRT.Id;
	        testOppty.StageName='Proposal Presentation';
	        testOppty.CloseDate = System.Today().addDays( 30 );
	        testOppty.AccountId = AdsAccount.id;
	        testOppty.Agency_Account__c = AgencyAccount.Id;
	        insert testOppty;
	        
	        RecordType proposalRT = [SELECT Id FROM RecordType WHERE SobjectType='Proposal__c' AND DeveloperName='Linear' limit 1];
	        testProposal = new Proposal__c();
	        testProposal.Name = 'Test Proposal';
	        testProposal.TIM_System__c = 'Dallas';
	        testProposal.Start_Date__c = SYstem.Today();
	        testProposal.End_Date__c = System.Today().addDays( 7 );
	        testProposal.Opportunity__c = testOppty.Id;
	        testProposal.Advertiser__c = AdsAccount.Id; 
	        testProposal.RecordTypeId = proposalRT.Id;
	        insert testProposal;
            
            RecordType dcRT = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Digital_Campaign__c' AND DeveloperName='New_Ads_Everywhere' limit 1];
        	
        	list<Digital_Campaign__c> dCampaigns = new list<Digital_Campaign__c>();
        	for( Integer i = 1; i <= 5; i++ ){
	        	Digital_Campaign__c dcampaign = new Digital_Campaign__c();
		        dcampaign.Proposal__c = testProposal.Id;
		        dcampaign.RecordTypeId = dcRT.Id;
		        dcampaign.Status__c = 'Draft Plan';
		    	dcampaign.Campaign_Name__c = testProposal.Name+' - Ads Everywhere ' + i;
		        dcampaign.Advertiser__c = AdsAccount.Id;
		        dcampaign.Agency__c = AgencyAccount.id;
		        dcampaign.Opportunity__c = testOppty.Id;
                dcampaign.Desired_Budget__c = 500;
                dcampaign.Source__c = 'Audience Track';
                dcampaign.DMAs__c = 'ALBANY - GA';
                dcampaign.Full_Avail_Campaign__c = False;
                dcampaign.Product_Type__c = 'DMA Addressable';
                dcampaign.AdsE_Genre_s__c = 'Selected Networks';
                dcampaign.AdsE_Network__c = 'ABC News';
			    dCampaigns.add( dcampaign );
        	}
        	
        	insert dCampaigns;
       
    	}
    }
    
    @isTest static void testgetRecords(){
        Test.startTest();
        List<String> pid = new List<String>();
        List<Proposal__c> p = [Select id from Proposal__c limit 1];
        Account a = [Select id from Account where Name='Test Ads Account' limit 1];
        for(Proposal__c pro : p){
            pid.add(pro.id);
        }
        CloneDCsToMultipleProposalsController.getRecords('Test',pid,'ProposalSearch',a.Id,'','');
        Test.stopTest();
    }
    
    @isTest static void testgetDCData(){
         Test.startTest();
        List<String> pid = new List<String>();
        Proposal__c p = [Select id from Proposal__c limit 1];
        Account a = [Select id from Account where Name='Test Ads Account' limit 1];
        CloneDCsToMultipleProposalsController.getDCData(p.id);
        Test.stopTest();
    }
    
    @isTest static void testgetCreatableFieldsSOQL(){
        Test.startTest();
        List<String> dcIds = new List<String>();
        List<Digital_Campaign__c> dc = [Select id from Digital_Campaign__c limit 5];
        for(Digital_Campaign__c d : dc){
            dcIds.add(d.id);
        }
        CloneDCsToMultipleProposalsController.getCreatableFieldsSOQL('Digital_Campaign__c','Id in :dcIds');
        Test.stopTest();
    }
    
    @isTest static void testcreateMultipleDigCamp(){
        Test.startTest();
         List<String> dcIds = new List<String>();
         List<String> pIds = new List<String>();
         List<Digital_Campaign__c> dc = [Select id from Digital_Campaign__c limit 5];
         List<Proposal__c> p = [Select id from Proposal__c limit 1];
         for(Digital_Campaign__c d : dc){
            dcIds.add(d.id);
         }
        for(Proposal__c pi : p){
            pIds.add(pi.id);
         }
        CloneDCsToMultipleProposalsController.createMultipleDigCamp('[{"dc":{"Id":"a084N00000XDlPcQAL","Name":"DC-0000204332","Advertiser__c":"0014100000pClkcAAC","Status__c":"20 Missing Creative / Instructions","Campaign_Name__c":"Subaru 2Q21 LA Auto Intenders May","RecordTypeId":"0124N00000111ueQAA","Campaign_Start_Date__c":"2021-04-26","Campaign_End_Date__c":"2021-05-30","Proposal__c":"a0O4N00000CTgT6UAL","Opportunity__c":"0064N00000dZ28mQAC","TIM_ID__c":"535345","Advertiser__r":{"Name":"Subaru/Adlink","Id":"0014100000pClkcAAC"},"RecordType":{"Name":"Addressable Video","Id":"0124N00000111ueQAA"}},"dcAdvertiserName":"Subaru/Adlink","dcCampaignName":"Subaru 2Q21 LA Auto Intenders May","dcName":"DC-0000204332","dcRecordTypeName":"Addressable Video","dcStatus":"20 Missing Creative / Instructions","dcTimOrderID":"535345","row":"row-0"}]',dcIds,pIds);
        Test.stopTest();
    }
    
    
}