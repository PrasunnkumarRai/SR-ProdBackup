@isTest
public with sharing class ProposalNewSyncTriggerHandlerTest {
    
    @IsTest(seeAlldata = false)
    static void insertNegativePathTest() {
        
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        
        System.runAs(u){
	        TestDataHelper.createTIMIntegrationCustomSettings();
	        
	        //Create user connections
	        insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
	        
	        //Create an account
	        Account acc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
	        insert acc;
	        
	        try{
		        ProposalNewSync__c pns = TestDataHelper.createProposalNewSync('St. Louis Local','00000');
		        insert pns;
	        }
	        catch(Exception ex){
	        	System.debug(ex);
	        }	        
	        
        }
    }
    
    @IsTest(seeAlldata = false)
    static void updateNegativePathTest() {
        
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        
        System.runAs(u){
	        TestDataHelper.createTIMIntegrationCustomSettings();
	        
	        //Create user connections
	        insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
	        
	        //Create an account
	        Account acc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
	        insert acc;
	        
	        ProposalNewSync__c pns = new ProposalNewSync__c();
	        try{
		        pns = TestDataHelper.createProposalNewSync('St. Louis Local','000000');
		        insert pns;
	        }
	        catch(Exception ex){
	        	System.debug(ex);
	        }	 
	        
	        try{
		        pns.name='00000';
		        update pns;
	        }
	        catch(Exception ex){
	        	System.debug(ex);
	        }	        
	        
        }
    }
}