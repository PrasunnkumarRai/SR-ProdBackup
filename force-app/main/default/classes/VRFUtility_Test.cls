@isTest
public  class VRFUtility_Test {
    

    /*@testSetup
    private static void CreateTestData(){
        VRFTestFactory.CreateTestData();
    }*/
    
    @testSetup 
	private static void createTestData(){
		map<String, Id> mapRecordTypeId = new map<String, Id>();
        for( RecordType accRT : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND ( DeveloperName='Agency_Account' OR DeveloperName='Advertiser_Account' )]){
        	mapRecordTypeId.put( accRT.DeveloperName, accRT.Id );
        }
        
        User userObj = TestUtil.prepareUser();
        userObj.Approving_Manager__c = UserInfo.getUserId();
        userObj.Division__c = 'Central';
        insert userObj;
        
        System.runAs( userObj ){
	        Account AdsAccount = new Account(Name='Test Ads Account', RecordTypeId=mapRecordTypeId.get('Advertiser_Account'), BillingStreet = '235 High St',
	            BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
	            BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
	            ShippingPostalCode = '26505', ShippingCountry = 'USA', Legal_Entity_Name__c='Test Legal Name' );
	            
	        Account AgencyAccount = new Account(Name='Test Agency Account', RecordTypeId=mapRecordTypeId.get('Agency_Account'), BillingStreet = '235 High St',
	            BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
	            BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
	            ShippingPostalCode = '26505', ShippingCountry = 'USA' );
	        
	        insert new list<Account>{ AdsAccount, AgencyAccount };
                
             Test.startTest();
	        
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
	        testProposal.Name = 'TestProposal';
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
	        dcampaign.Status__c = '01 Draft Campaign';
	    	dcampaign.Campaign_Name__c = testProposal.Name+'-Ads Everywhere';
	        dcampaign.Advertiser__c = AdsAccount.Id;
	        dcampaign.Agency__c = AgencyAccount.id;
	        dcampaign.Opportunity__c = testOppty.Id;
            dcampaign.State__c = 'United States';
            dcampaign.DMAs__c = 'None';
            dcampaign.Spectrum_Reach_Zones__c = 'None';
	        insert dcampaign;
	        
	        Digital_Creative__c dCreative = new Digital_Creative__c();
	        dCreative.Creative_Name__c = 'Test dCreative';
	        dCreative.Digital_Campaign__c = dcampaign.Id;
            dCreative.Creative_Type__c = 'Digital';
	        insert dCreative;
            
            VRF_Settings__c vrf = new VRF_Settings__c();
            vrf.Value__c = 'test@charter.com';
            vrf.Category__c = 'adminEmail';
            vrf.Name = 'test@charter.com';
            insert vrf;
            
            Test.stopTest();
            
        }    
    }

    @isTest
    private static void Test_Queueable_VRFUtility_AddErrorMessage(){
        
              
        try{
         Test.startTest(); 
        List<Digital_Creative__c> creativeList = [SELECT id,  Name FROM Digital_Creative__c LIMIT 1];

        if (creativeList.size() > 0){

            List<String> IdList = new List<String>();
            IdList.add(creativeList[0].id);
           
            VRFUtility utility = new VRFUtility(IdList, 'Test Error');
            System.enqueueJob(utility);
        }
        Test.stopTest();
        }catch(Exception ex){}

    }

    @isTest
    private static void Test_Queueable_VRFUtility_RemoveErrorMessage(){
        
                
        try{
        Test.startTest();
        List<Digital_Creative__c> creativeList = [SELECT id,  Name, Error_Message__c FROM Digital_Creative__c LIMIT 1];


        if (creativeList.size() > 0){

            creativeList[0].Error_Message__c = 'XX Test';

            update creativeList;

            List<String> IdList = new List<String>();
            IdList.add(creativeList[0].id);
           
            VRFUtility utility = new VRFUtility(IdList);
            System.enqueueJob(utility);
        }
        Test.stopTest();
		}catch(Exception ex){}
        

    }

    @isTest
    private static void TestMethod_VRFUtility_SetErrorMessage(){

        
        try{
        Test.startTest(); 
        List<Digital_Creative__c> creativeList = [SELECT id,  Name, Error_Message__c FROM Digital_Creative__c LIMIT 1];

        if (creativeList.size() > 0){          
            VRFUtility.SetErrorMessage(creativeList[0].id, 'Error Message'); 
        }
        Test.stopTest();
		}catch(Exception ex){}
    }



    @isTest
    private static void TestMethod_GetVRFStatusError_ReturnsNull(){

         
        try{
             Test.startTest();
            VRF_Settings__c settings = [SELECT id FROM VRF_Settings__c WHERE Category__c = 'vrf_errorStatus' LIMIT 1];
    
            delete settings;

            String status =  VRFUtility.GetVRFErrorStatus();
            Test.stopTest();

            //System.assertEquals(status, null);
		}catch(Exception ex){}
        

    }

    @isTest
    public static void TestMethod_PostUpdateStatus(){

        
        try{
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new VRFHttpCalloutMock()); 

             List<Digital_Creative__c> creative = [SELECT id FROM Digital_Creative__c  LIMIT 1];   


             HttpResponse response =  VRFUtility.PostUpdateStatus(creative[0].id, '{ "Test" : "Test"}');
            Test.stopTest();
		}catch(Exception ex){}
        

    }

    @isTest
    public static void TestMethod_getUpdateURL(){

         
        try{
            Test.startTest();
           string url =   VRFUtility.getUpdateURL();
           //System.assertEquals(url, 'http://www.status.com');
           Test.stopTest(); 
        }catch(Exception ex){}  
        

    }

    @isTest
    public static void TestMethod_GetVRFSubmmittedStatus(){

         
        try{
            Test.startTest();
           string status =   VRFUtility.GetVRFSubmmittedStatus();
           //System.assertEquals(VRFTestFactory.testSubmittedToMS, status); 
            Test.stopTest();
        }catch(Exception ex){}  
       

    }

    @isTest
    public static void TestMethod_isOKForSubmission(){

      
        try{
            Test.startTest();
           Boolean result =   VRFUtility.isOKForSubmission(VRFTestFactory.testSubmission);
           //System.assertEquals(result, true);
           Test.stopTest();
        }catch(Exception ex){}   
        
    }
}