/*
###########################################################################
# File..................: AccountBillingSync_Test.cls
# Version...............: 
# Created by............: Aditi Garg
# Created Date..........: 7-July-2017
# Last Modified by......:  
# Last Modified Date....: 
# Description...........: Test class for AccountBillingSync 
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/
@isTest
private class AccountBillingSync_Test {
    static User u;
    static Account parentAcc;
    static Account acc;
    static List<Id> accIds;
    static Account agencyAcc;
    static List<AccountConnection__c> accConnectList;

	static void prepareTestData() { 
        accIds = new List<Id>();
		accConnectList = new List<AccountConnection__c>();
    	u = TestDataHelper.getBoomiIntegrationUser();
       
        TestDataHelper.createTIMIntegrationCustomSettings();
        //Create parent account
    //	Account parentAcc=TestDataHelper.createAdvertiser('Advertiser Account_parent','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');
    	parentAcc=TestDataHelper.createAcc('Account_parent','122 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                                                
        insert parentAcc;

        System.assert(parentAcc != null);

        acc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68131', 'USA'); 
        acc.MergeAccount__c = parentAcc.id;
        acc.Billing_Change_Status__c = System.Label.TimBillingSyncApproval_Status;
        insert acc;

        System.assert(acc != null);

        accIds.add(acc.Id);

        agencyAcc=TestDataHelper.createAgency('Agency Account','124 Wright Plaza', 'Omaha', 'NW', '68132', 'USA');                                                
        agencyAcc.MergeAccount__c = parentAcc.id;
        agencyAcc.Billing_Change_Status__c = System.Label.TimBillingSyncApproval_Status;
        insert agencyAcc;

        System.assert(agencyAcc != null);

        //Create account connenction	
        AccountConnection__c accConnect = TestDataHelper.createAccountConnection(String.valueOf(parentAcc.id));
	    accConnectList.add(accConnect);		 
	//  AccountConnection__c accConnectchild = TestDataHelper.createAccountConnection(String.valueOf(acc.id));
	    AccountConnection__c accConnectchild = TestDataHelper.createAccountConnection(String.valueOf(acc.id));
	    accConnectList.add(accConnectchild);

	    AccountConnection__c accConnectagency = TestDataHelper.createAccountConnection(String.valueOf(agencyAcc.id));
	    accConnectList.add(accConnectagency);		    
	    insert accConnectList; 

        System.assert(accConnectList != null); 
	}


    @IsTest(seeAlldata = false)
    static void accountBillingPositivePathTest() {    	
    	prepareTestData(); 
        System.runAs(u){
	        ApexPages.StandardController sc = new ApexPages.StandardController(parentAcc);      
	        AccountBillingSync accountMergerObj = new AccountBillingSync(sc);
	        //accountMergerObj.acc = parentAcc;

            System.assert(accountMergerObj.acc != null);

	        Test.startTest();
	        Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());           
	        AccountBillingSync.syncAccounts(accIds);

	        Test.stopTest();
	        /*Test.startTest();
	        ApexPages.StandardController sc = new ApexPages.StandardController(parentAcc);	
	        ApexPages.currentPage().getParameters().put('Id', parentAcc.id);        
	        AccountBillingSync accountMergerObj = new AccountBillingSync(sc);
	        Test.stopTest();*/
	    }        
    }

    /*@IsTest(seeAlldata = false)
    static void accountBillingAgencyTest() {    	
    	prepareTestData(); 
        System.runAs(u){
	        Test.startTest();
	        Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
	       // AccountBillingSync.syncAccounts(agencyAcc.id);
	        Test.stopTest();	     
	    }        
    }

    @IsTest(seeAlldata = false)
    static void accountBillingExceptionTest() {    	
    	prepareTestData(); 
        System.runAs(u){
	        Test.startTest();
	     // Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
	        //sAccountBillingSync.syncAccounts(agencyAcc.id);
	        Test.stopTest();	     
	    }        
    }*/

    @IsTest(seeAlldata = false)
    static void accountBillControllerTest() {    	
    	prepareTestData(); 
        System.runAs(u){
	        Test.startTest();
	       ApexPages.StandardController sc = new ApexPages.StandardController(parentAcc);	
	        ApexPages.currentPage().getParameters().put('Id', parentAcc.id);  

            String id = ApexPages.currentPage().getParameters().get('Id');
            system.assertEquals(true,id!=null);

	        AccountBillingSync accountMergerObj = new AccountBillingSync(sc);
	        Test.stopTest();	     
	    }        
    }
}