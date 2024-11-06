@isTest
public class AdddressableSTVRatecardControllerTest {
    
    @testSetup
    private static void init(){
        
        Map<String, Id> mapRecordTypeId = new Map<String, Id>();
        
        for( RecordType accRT : [SELECT Id, DeveloperName FROM RecordType 
                                 WHERE SObjectType='Account' AND ( DeveloperName='Agency_Account' OR DeveloperName='Advertiser_Account' )]){
        	mapRecordTypeId.put( accRT.DeveloperName, accRT.Id );
        }
        test.startTest();
        User userAE = TestUtil.prepareUser();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@charter.com';
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
            
            Data_Catalog__c dc = new Data_Catalog__c(
            Display_Text__c =  'Auto Intenders (New Car)|New Fullsize Trucks or Vans|AUTONEWFLSZTRKVAN',
            isSTV__c = true,Export_Key__c='AUTONEWFLSZTRKVAN',Political__c=false,Restricted_Interest__c=false,isActive__c=true);
            
            insert dc;
            
            RecordType recordType = [SELECT id, Name FROM RecordType 
                                     WHERE Name = 'Inventory Request - New Ads Everywhere' 
                                     AND SobjectType = 'Digital_Campaign__c' LIMIT 1];
            
            
            Digital_Campaign__c dcampaign = new Digital_Campaign__c();
            dcampaign.Proposal__c = testProposal.Id;
            dcampaign.RecordTypeId = recordType.Id;
            dcampaign.Status__c = 'Draft Plan';
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
            
            insert dcampaign;
test.stopTest();
        }
    }
    
    @isTest
    private static void retrieveDisplayTextForDCC(){
        Test.startTest();
        List<Digital_Campaign__c> dcList = [Select id, RecordTypeId from Digital_Campaign__c Limit 1];
        AdddressableSTVRatecardController.retrieveDisplayText(dcList[0].RecordTypeId);
        Test.stopTest();
    }
    
    @isTest
    private static void retrieveDisplayTextForSRTest(){
        Test.startTest();
        AdddressableSTVRatecardController.retrieveDisplayTextBySR('Streaming TV');
        Test.stopTest();
    }

   /* @isTest
    private static void testUpdateDataCatalogValues() {
        List<Digital_Campaign__c> dcList = [Select id,Data_Catalog__c,Data_Catalog_Custom_Logic__c, Data_Catalog_For_Groups__c, Selected_Data_Catalog_Id__c,
                                            Export_Key_Logic__c, Addressable_Rate_Card_CPM__c  FROM Digital_Campaign__c Limit 1];
        AdddressableSTVRatecardController.updateDataCatalogValues('Age|18+|ADLT18PLUS', dcList[0].Id);
    }*/
    
    @isTest 
	private static void getDayAndTimeDataTest() {
          Test.startTest();
        List<Digital_Campaign__c> dcList = [Select id,Data_Catalog__c,Data_Catalog_Custom_Logic__c, Data_Catalog_For_Groups__c, Selected_Data_Catalog_Id__c, 
                                            Export_Key_Logic__c, Addressable_Rate_Card_CPM__c  FROM Digital_Campaign__c Limit 1];
		String data = '[{"Day_of_Week":"Tuesday","Start_Time":"01:00 A.M","End_Time":"02:00 A.M"}]';       
        AdddressableSTVRatecardController.getDayAndTimeData(data, dcList[0].Id);
      test.stopTest();
        
    }    
}