/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest 
private class DigitalCreativeTriggerHandlerTest {

    static testMethod void myUnitTest() {
        
        
        // TO DO: implement unit test
        map<String, Id> mapRecordTypeId = new map<String, Id>();
        for( RecordType accRT : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND ( DeveloperName='Agency_Account' OR DeveloperName='Advertiser_Account' )]){
            mapRecordTypeId.put( accRT.DeveloperName, accRT.Id );
        }
        User userAE = TestUtil.prepareUser();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@mands.com';
        userAE.Email = 'testae@mandsconsulting.com.sr.uat';
        userAE.Division__c = 'Central';
        //update userObj;
        
        User userObj = TestUtil.prepareUser();
        userObj.Approving_Manager__c = UserInfo.getUserId();
        userObj.Division__c = 'Central';
        userObj.Email = 'testadmin@mandsconsulting.com.sr.uat';
        insert new list<User>{ userObj, userAE };
        
        Digital_Campaign__c dcampaign;
        
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
            dcampaign = new Digital_Campaign__c();
            dcampaign.Proposal__c = testProposal.Id;
            dcampaign.RecordTypeId = dcRT.Id;
            dcampaign.Status__c = '01 Draft Campaign';
            dcampaign.Campaign_Name__c = testProposal.Name+' - Ads Everywhere';
            dcampaign.Advertiser__c = AdsAccount.Id;
            dcampaign.Agency__c = AgencyAccount.id;
            dcampaign.Opportunity__c = testOppty.Id;
            insert dcampaign;
        
        
        Test.startTest();
            
            list<Digital_Creative__c> dCreatives = new list<Digital_Creative__c>();
            for( Integer i = 1; i <= 5; i++ ){
                Digital_Creative__c dCreative = new Digital_Creative__c();
                dCreative.Creative_Name__c = 'Test dCreative';
                dCreative.Digital_Campaign__c = dcampaign.Id;
                dCreative.Creative_End_Date__c = System.Today().addDays( i );
                dCreative.Status__c='00 Rejected';
                dCreative.Creative_Type__c='Digital';
                dCreatives.add( dCreative );
            }

			for( Integer i = 1; i <= 5; i++ ){
                Digital_Creative__c dCreative1 = new Digital_Creative__c();
                dCreative1.Creative_Name__c = 'Test dCreative';
                dCreative1.Digital_Campaign__c = dcampaign.Id;
                dCreative1.Creative_End_Date__c = System.Today().addDays( i );
                dCreative1.Status__c='05 Trafficked by Digital Ops';
                dCreative1.Creative_Type__c='Digital';
                dCreatives.add( dCreative1 );
            }
            
            insert dCreatives;
            
            
            StopTriggerRecursionHelper.methodfirstcall = true;
       
            Digital_Campaign__c updatedDCampaign = [SELECT Id,Max_Trafficked_Creative_End_Date__c FROM Digital_Campaign__c WHERE Id=:dcampaign.Id];
           // System.assert( updatedDCampaign.Max_Trafficked_Creative_End_Date__c == System.Today().addDays(5));
            StopTriggerRecursionHelper.methodafterupdate = true;
            
            dCreatives.get(0).Creative_End_Date__c = System.today().addDays( 10 );
            dCreatives.get(2).Creative_End_Date__c = System.today().addDays( 20 );
            update new list<Digital_Creative__c>{ dCreatives.get(0), dCreatives.get(2) };
                
                 
            
            
            updatedDCampaign = [SELECT Id,Max_Trafficked_Creative_End_Date__c FROM Digital_Campaign__c WHERE Id=:dcampaign.Id];
          //  System.assert( updatedDCampaign.Max_Trafficked_Creative_End_Date__c == System.Today().addDays(20));
            
            DigitalCreativeTriggerHandler handlerObj = new DigitalCreativeTriggerHandler( true, 200 );
            Boolean IsTriggerContext = handlerObj.IsTriggerContext;
            Boolean IsVisualforcePageContext = handlerObj.IsVisualforcePageContext;
            Boolean IsWebServiceContext = handlerObj.IsWebServiceContext;
            Boolean IsExecuteAnonymousContext = handlerObj.IsExecuteAnonymousContext;
            handlerObj.OnBeforeDelete( new list<Digital_Creative__c>(), new map<Id, Digital_Creative__c>() );
            handlerObj.OnAfterDelete( new list<Digital_Creative__c>(), new map<Id, Digital_Creative__c>() );
            handlerObj.OnAfterDelete( new list<Digital_Creative__c>(), new map<Id, Digital_Creative__c>() );
            handlerObj.OnUndelete( new list<Digital_Creative__c>() );
            DigitalCreativeTriggerHandler.OnAfterDeleteAsync( new set<Id>() );
            
            System.runAs( userAE ){
                dCreatives.get(0).Creative_End_Date__c = System.today().addDays( 5 );
                // Handle update in exception as AE is not allowed to update Digital Creative records.
                try{
                    update dCreatives.get(0);   
                }catch(Exception ex){}
            }
            
            delete dCreatives.get(0);
            undelete dCreatives.get(0);
            
        	Test.stopTest();
        }
    }
    
     static testMethod void myUnitTest1() {
        
        
        // TO DO: implement unit test
        map<String, Id> mapRecordTypeId = new map<String, Id>();
        for( RecordType accRT : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND ( DeveloperName='Agency_Account' OR DeveloperName='Advertiser_Account' )]){
            mapRecordTypeId.put( accRT.DeveloperName, accRT.Id );
        }
        User userAE = TestUtil.prepareUser();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@charter.com';
        userAE.Email = 'testae@mandsconsulting.com.sr.uat';
        userAE.Division__c = 'Central';
        //update userObj;
        
        User userObj = TestUtil.prepareUser();
        userObj.Approving_Manager__c = UserInfo.getUserId();
        userObj.Division__c = 'Central';
        userObj.Email = 'testadmin@mandsconsulting.com.sr.uat';
        insert new list<User>{ userObj, userAE };
        
        Digital_Campaign__c dcampaign;
        
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
            dcampaign = new Digital_Campaign__c();
            dcampaign.Proposal__c = testProposal.Id;
            dcampaign.RecordTypeId = dcRT.Id;
            dcampaign.Status__c = '01 Draft Campaign';
            dcampaign.Campaign_Name__c = testProposal.Name+' - Ads Everywhere';
            dcampaign.Advertiser__c = AdsAccount.Id;
            dcampaign.Agency__c = AgencyAccount.id;
            dcampaign.Opportunity__c = testOppty.Id;
            insert dcampaign;
        
        
        Test.startTest();
            
            list<Digital_Creative__c> dCreatives = new list<Digital_Creative__c>();
            for( Integer i = 1; i <= 5; i++ ){
                Digital_Creative__c dCreative = new Digital_Creative__c();
                dCreative.Creative_Name__c = 'Test dCreative';
                dCreative.Digital_Campaign__c = dcampaign.Id;
                dCreative.Creative_End_Date__c = System.Today().addDays( i );
                dCreative.Status__c='00 Rejected';
                dCreative.Creative_Type__c='Digital';
                dCreatives.add( dCreative );
            }

			for( Integer i = 1; i <= 5; i++ ){
                Digital_Creative__c dCreative1 = new Digital_Creative__c();
                dCreative1.Creative_Name__c = 'Test dCreative';
                dCreative1.Digital_Campaign__c = dcampaign.Id;
                dCreative1.Creative_End_Date__c = System.Today().addDays( i );
                dCreative1.Status__c='05 Trafficked by Digital Ops';
                dCreative1.Creative_Type__c='Digital';
                dCreatives.add( dCreative1 );
            }
            
            insert dCreatives;
            
            
            StopTriggerRecursionHelper.methodfirstcall = true;
       
            Digital_Campaign__c updatedDCampaign = [SELECT Id,Max_Trafficked_Creative_End_Date__c FROM Digital_Campaign__c WHERE Id=:dcampaign.Id];
           // System.assert( updatedDCampaign.Max_Trafficked_Creative_End_Date__c == System.Today().addDays(5));
            
            dCreatives.get(0).Creative_End_Date__c = System.today().addDays( 10 );
            dCreatives.get(2).Creative_End_Date__c = System.today().addDays( 20 );
          //  update new list<Digital_Creative__c>{ dCreatives.get(0), dCreatives.get(2) };
                
                 
            
            StopTriggerRecursionHelper.methodafterupdate = true;
            
            updatedDCampaign = [SELECT Id,Max_Trafficked_Creative_End_Date__c FROM Digital_Campaign__c WHERE Id=:dcampaign.Id];
          //  System.assert( updatedDCampaign.Max_Trafficked_Creative_End_Date__c == System.Today().addDays(20));
            
            DigitalCreativeTriggerHandler handlerObj = new DigitalCreativeTriggerHandler( true, 200 );
            Boolean IsTriggerContext = handlerObj.IsTriggerContext;
            Boolean IsVisualforcePageContext = handlerObj.IsVisualforcePageContext;
            Boolean IsWebServiceContext = handlerObj.IsWebServiceContext;
            Boolean IsExecuteAnonymousContext = handlerObj.IsExecuteAnonymousContext;
            handlerObj.OnBeforeDelete( new list<Digital_Creative__c>(), new map<Id, Digital_Creative__c>() );
            handlerObj.OnAfterDelete( new list<Digital_Creative__c>(), new map<Id, Digital_Creative__c>() );
            handlerObj.OnAfterDelete( new list<Digital_Creative__c>(), new map<Id, Digital_Creative__c>() );
            handlerObj.OnUndelete( new list<Digital_Creative__c>() );
            DigitalCreativeTriggerHandler.OnAfterDeleteAsync( new set<Id>() );
            
            System.runAs( userAE ){
                dCreatives.get(0).Creative_End_Date__c = System.today().addDays( 5 );
                // Handle update in exception as AE is not allowed to update Digital Creative records.
                try{
                    update dCreatives.get(0);   
                }catch(Exception ex){}
            }
            
            delete dCreatives.get(0);
            undelete dCreatives.get(0);
            
        	Test.stopTest();
        }
    }
    
    
}