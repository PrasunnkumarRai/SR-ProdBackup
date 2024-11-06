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
private class NewAccountRequestControllerTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        map<String, Id> mapRecordTypeId = new map<String, Id>();
        for( RecordType accRT : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND ( DeveloperName='Agency_Account' OR DeveloperName='Advertiser_Account' )]){
        	mapRecordTypeId.put( accRT.DeveloperName, accRT.Id );
        }
        
        User userObj = TestUtil.prepareUser();
        insert userObj;
        //Id currentUserId = UserInfo.getUserId();
        System.runAs( userObj ){
        Account AdsAccount = new Account(Name='Test Ads Account', RecordTypeId=mapRecordTypeId.get('Advertiser_Account'), BillingStreet = '235 High St',
		        BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
		        BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
		        ShippingPostalCode = '26505', ShippingCountry = 'USA', Legal_Entity_Name__c='Test Legal Name');
	    insert adsAccount;
		    
        AccountTeamMember atmObj2 = TestUtil.getAccountTeamMemRec( adsAccount.Id, UserInfo.getUserId() );
		insert atmObj2;
		    	
       
        	// Create Test Accounts
		    
		    Test.startTest();
		    	
		    	NewAccountRequestController.ResponseWrapper respWrapper = NewAccountRequestController.getARRecordTypes( adsAccount.Id );
		    	respWrapper.lstUsers = NewAccountRequestController.getAETeamMembers( adsAccount.Id );
		    	//System.assert( respWrapper.lstUsers.size() == 1 );
		    	
		    	map<String, RecordType> mapRTByDevName = new map<String, RecordType>();
		    	for( RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType='Account_Request__c']){
		    		mapRTByDevName.put( rt.DeveloperName, rt );
		    	}
		    	
		    	NewAccountRequestController.getAccountData( adsAccount.Id, mapRTByDevName.get('Team_Member_Request').Id, '', false );
		    	
		    	AccountTeamMember atmObj1 = TestUtil.getAccountTeamMemRec( adsAccount.Id, userObj.Id );
		    	insert new list<AccountTeamMember>{ atmObj1 };
		    	
		    	respWrapper = NewAccountRequestController.getARRecordTypes( adsAccount.Id );
		    	atmObj2.TeamMemberRole = 'Account Executive';
		    	update atmObj2; 
		    	
		    	// 
		    	AccountTeamMember atmObject2 = [SELECT Id, TeamMemberRole, AccountId, Userid FROM AccountTeamMember WHERE Id=:atmObj2.Id];
		    	System.assert( atmObject2.TeamMemberRole == 'Account Executive' );
		    	System.assert( atmObject2.AccountId == adsAccount.Id );
		    	
		    	list<User> lstUsers = NewAccountRequestController.getAETeamMembers( adsAccount.Id );
		    	System.debug('----lstUsers.size() '+lstUsers.size());
		    	System.assert( lstUsers.size() > 0 );
		    	 
		    	NewAccountRequestController.getAccountData( adsAccount.Id, mapRTByDevName.get('Account_Id_Credit_Request').ID, lstUsers.get(0).Id, false );
		    	NewAccountRequestController.getAccountData( adsAccount.Id, mapRTByDevName.get('Payment_Research').ID, lstUsers.get(0).Id, false );
		    	NewAccountRequestController.checkForAEInAccTeam(userinfo.getUserId(),adsAccount.Id);
            	try{
            		NewAccountRequestController.saveAccountRequest(atmObject2.Id,mapRTByDevName.get('Team_Member_Request').Id,'new',atmObject2.UserId,datetime.now(),'test');
                }catch(Exception ex){}
                Test.stopTest();
        }
        
    }
}