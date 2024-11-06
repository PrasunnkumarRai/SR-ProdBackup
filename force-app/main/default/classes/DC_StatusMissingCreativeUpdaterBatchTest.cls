@isTest
public class DC_StatusMissingCreativeUpdaterBatchTest {
    @isTest
    static void myUnitTest() {
        // TO DO: implement unit test
        map<String, Id> mapRecordTypeId = new map<String, Id>();
        for( RecordType accRT : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND ( DeveloperName='Agency_Account' OR DeveloperName='Advertiser_Account' )]){
        	mapRecordTypeId.put( accRT.DeveloperName, accRT.Id );
        }
        User userAE = TestUtil.prepareUser();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@mands.com';
        userAE.Email = 'testae@mands.com';
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
	    
            Test.startTest();

	        RecordType dcRT = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Digital_Campaign__c' AND DeveloperName='Display' limit 1];
        	
        	list<Digital_Campaign__c> dCampaigns = new list<Digital_Campaign__c>();
        	for( Integer i = 1; i <= 2; i++ ){
	        	Digital_Campaign__c dcampaign = new Digital_Campaign__c();
		        dcampaign.Proposal__c = testProposal.Id;
		        dcampaign.RecordTypeId = dcRT.Id;
		        dcampaign.Status__c = '03 Submitted to Digital Ops';
		    	dcampaign.Campaign_Name__c = testProposal.Name+' - Ads Everywhere ' + i;
		        dcampaign.Advertiser__c = AdsAccount.Id;
		        dcampaign.Agency__c = AgencyAccount.id;
		        dcampaign.Opportunity__c = testOppty.Id;
                dcampaign.Desired_Budget__c = 500;
                dcampaign.Campaign_Start_Date__c = date.today();
                dcampaign.Campaign_End_Date__c = date.today();
			    dCampaigns.add( dcampaign );
        	}
        	insert dCampaigns;	
            
			list<Digital_Creative__c> dCreatives = new list<Digital_Creative__c>(); 
            for( Integer i = 1; i <= 2; i++ ){
	        	Digital_Creative__c dcc = new Digital_Creative__c();
				dcc.Creative_Name__c = 'test' + date.today()+ i;
		        dcc.Status__c = '01 Draft Creative';
                dcc.Creative_Start_Date__c = date.today();
                dcc.Creative_End_Date__c = date.today();
                dcc.Digital_Campaign__c = dCampaigns[0].id;			   
        	}
            insert dCreatives;
            
            DC_StatusMissingCreativeUpdaterBatch b = new DC_StatusMissingCreativeUpdaterBatch();  
      		database.executebatch(b,200);
            
            DC_StatusMissingCreativeUpdaterBatchSch sh1 = new DC_StatusMissingCreativeUpdaterBatchSch();      
 			String sch = '0 0 23 * * ?';
        	system.schedule('Test DC_StatusMissingCreativeUpdaterBatchSch', sch, sh1);
            
    		Test.stopTest();
        }
    }

}