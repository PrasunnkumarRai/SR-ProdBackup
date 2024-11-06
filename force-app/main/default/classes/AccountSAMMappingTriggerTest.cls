@isTest	
public with sharing class AccountSAMMappingTriggerTest {

    @IsTest(seeAlldata = false)
    static void AccountSAMMappingCreationTest() {
    	//create Advertiser
	    Account acc = TestUtil.getAccountRec();
		acc.primary_commodity__c =   'Auto Aftermarket';
		insert acc;
		
		User loggedInUser = [Select id,region__c,sales_office__c,division__c 
							 from User 
							 where id =:UserInfo.getUserId()];
			
		Account_SAM_Mapping__c newAsm = new Account_SAM_Mapping__c(account__c =acc.Id,user__c =UserInfo.getUserId(),
																   SAM_Designation__c ='key',region__c=loggedInUser.region__c,
																   sales_office__c=loggedInUser.sales_office__c,
																   division__c=loggedInUser.division__c,
																   ownerId =loggedInUser.id);
		insert newAsm;
    }
    
    
}