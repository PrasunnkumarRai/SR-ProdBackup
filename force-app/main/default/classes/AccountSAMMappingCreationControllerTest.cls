@isTest	
public with sharing class AccountSAMMappingCreationControllerTest {

    //Methods are obsolete in the Apex Class
    /*
    @IsTest(seeAlldata = false)
    static void AccountSAMMappingKeyCreationTest() {

    	//create Advertiser
	    Account acc = TestUtil.getAccountRec();
		acc.primary_commodity__c =   'Auto Aftermarket';
		insert acc;
    	
    	ApexPages.currentPage().getParameters().put('accId',acc.Id);
    	ApexPages.currentPage().getParameters().put('sd','Key');
        ApexPages.currentPage().getParameters().put('accId',null);
    	
    	AccountSAMMappingCreationController asm = new AccountSAMMappingCreationController();
    	asm.upsertAccountSAMMapping();
    }
    
    @IsTest(seeAlldata = false)
    static void AccountSAMMappingTargetCreationTest() {
    	
    	//create Advertiser
	    Account acc = TestUtil.getAccountRec();
		acc.primary_commodity__c =   'Auto Aftermarket';
		insert acc;

    	
    	ApexPages.currentPage().getParameters().put('accId',acc.Id);
    	ApexPages.currentPage().getParameters().put('sd','Target');
        ApexPages.currentPage().getParameters().put('accId',null);
    	
    	AccountSAMMappingCreationController asm = new AccountSAMMappingCreationController();
    	asm.upsertAccountSAMMapping();
    }
    
    @IsTest(seeAlldata = false)
    static void AccountSAMMappingKeyUpdateTest() {
    	
    	//create Advertiser
	    Account acc = TestUtil.getAccountRec();
		acc.primary_commodity__c =   'Auto Aftermarket';
		insert acc;
		
		User loggedInUser = [Select id,region__c,sales_office__c,division__c 
							 from User 
							 where id =:UserInfo.getUserId()];
			
		Account_SAM_Mapping__c newAsm = new Account_SAM_Mapping__c(account__c =acc.Id,user__c =UserInfo.getUserId(),
																   Tier_Designation__c ='VIP',region__c=loggedInUser.region__c,
																   sales_office__c=loggedInUser.sales_office__c,
																   division__c=loggedInUser.division__c,
																   ownerId =loggedInUser.id);
		insert newAsm;
    	
    	ApexPages.currentPage().getParameters().put('accId',acc.Id);
    	ApexPages.currentPage().getParameters().put('sd','Key');
    	
    	AccountSAMMappingCreationController asm = new AccountSAMMappingCreationController();
        try{
        	asm.upsertAccountSAMMapping();
        }catch(Exception ex){
            System.debug('Exceptionnn.'+ex.getMessage());
        }
    }*/
    
    @IsTest(seeAlldata = false)
    static void validateForErrorsTest() {
    	
    	//create Advertiser
	    Account acc = TestUtil.getAccountRec();
		acc.primary_commodity__c =   'Auto Aftermarket';
		insert acc;
		
		User loggedInUser = [Select id,region__c,sales_office__c,division__c 
							 from User 
							 where id =:UserInfo.getUserId()];
			
		Account_SAM_Mapping__c newAsm = new Account_SAM_Mapping__c(account__c =acc.Id,user__c =UserInfo.getUserId(),
																   Tier_Designation__c ='Premier',region__c=loggedInUser.region__c,
																   sales_office__c=loggedInUser.sales_office__c,
																   division__c=loggedInUser.division__c,
																   ownerId =loggedInUser.id);
		insert newAsm;
    	
        try{
        	// AccountSAMMappingCreationController.validateForErrors(acc.Id, 'Extra');
            // AccountSAMMappingCreationController.validateForErrors(acc.Id, 'Target');
        }catch(Exception ex){
            throw ex;
        }
    }
    
    @IsTest(seeAlldata = false)
    static void upsertASMTest() {
    	
    	//create Advertiser
	    Account acc = TestUtil.getAccountRec();
		acc.primary_commodity__c =   'Auto Aftermarket';
		insert acc;
		
		User loggedInUser = [Select id,region__c,sales_office__c,division__c 
							 from User 
							 where id =:UserInfo.getUserId()];
    	
        try{
        	 AccountSAMMappingCreationController.upsertASM(acc.Id, 'Extra');
        }catch(Exception ex){
            throw ex;
        }
    }
    
    @IsTest(seeAlldata = false)
    static void upsertASMSAMExistTest() {
    	
    	//create Advertiser
	    Account acc = TestUtil.getAccountRec();
		acc.primary_commodity__c =   'Auto Aftermarket';
		insert acc;
		
		User loggedInUser = [Select id,region__c,sales_office__c,division__c 
							 from User 
							 where id =:UserInfo.getUserId()];
			
		Account_SAM_Mapping__c newAsm = new Account_SAM_Mapping__c(account__c =acc.Id,user__c =UserInfo.getUserId(),
																   Tier_Designation__c ='VIP',region__c=loggedInUser.region__c,
																   sales_office__c=loggedInUser.sales_office__c,
																   division__c=loggedInUser.division__c,
																   ownerId =loggedInUser.id);
		insert newAsm;
    	
        try{
        	 AccountSAMMappingCreationController.upsertASM(acc.Id, 'Extra');
        }catch(Exception ex){
            throw ex;
        }
    }
}