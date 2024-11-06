@isTest
public class DC_StatusMissingCreativeToLiveTest {
    
   @testSetup 
    static void setupmethod(){
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
            
            Networks__c net = new Networks__c();
            net.Name = 'ABC News' ;
            net.ActiveNetwork__c = true;
            net.Split_Avail_Activated__c = true;
            net.Frequence_Activated__c = true;
            insert net;

	        RecordType dcRT = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Digital_Campaign__c' AND DeveloperName='New_Ads_Everywhere' limit 1];
        	
        	//list<Digital_Campaign__c> dCampaigns = new list<Digital_Campaign__c>();
           // for( Integer i = 1; i <= 2; i++ ){
	        	Digital_Campaign__c dcampaign = new Digital_Campaign__c();
		        dcampaign.Proposal__c = testProposal.Id;
		        dcampaign.RecordTypeId = dcRT.Id;
		        dcampaign.Status__c = '20 Missing Creative / Instructions';
		    	dcampaign.Campaign_Name__c = testProposal.Name+' - Ads Everywhere ';
		        dcampaign.Advertiser__c = AdsAccount.Id;
		        dcampaign.Agency__c = AgencyAccount.id;
		        dcampaign.Opportunity__c = testOppty.Id;
                dcampaign.Desired_Budget__c = 500;
                dcampaign.Source__c = 'Audience Track';
                dcampaign.DMAs__c = 'ALBANY - GA';
                dcampaign.Full_Avail_Campaign__c = False;
                dcampaign.Product_Type__c = 'DMA Addressable';
                dcampaign.AdsE_Genre_s__c = 'Selected Networks';
                dcampaign.AdsE_Network__c = net.Name;
                dcampaign.AdsE_Platform_s__c = 'VOD (Set-top Box)';
                dcampaign.Max_Trafficked_Creative_End_Date__c = date.today().addYears(1);
                dcampaign.Campaign_Start_Date__c = date.today();
                dcampaign.Campaign_End_Date__c = date.today().addYears(1);
                dcampaign.VAST_Tag__c = 'No';
                //if(i==1){
                    dcampaign.Has_hit_09_Live__c = true;
                //}
                /*else{
                    dcampaign.Has_hit_09_Live__c = false;
                }*/
			    //dCampaigns.add( dcampaign );
           // }
        	insert dcampaign;
		}
    }
 
    @istest	
    static void myUnitTest() {
        Test.startTest();

        DC_StatusMissingCreativeToLive b = new DC_StatusMissingCreativeToLive();  
        database.executebatch(b,1);
        
        DC_StatusMissingCreativeToLiveSch sh1 = new DC_StatusMissingCreativeToLiveSch();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test DC_StatusMissingCreativeToLiveSch', sch, sh1);
        
        Test.stopTest();
    }
    

}