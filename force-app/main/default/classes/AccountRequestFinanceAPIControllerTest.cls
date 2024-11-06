@IsTest(SeeAllData = false)
public class AccountRequestFinanceAPIControllerTest {
    @testSetup
  	static void loadTestDataFromStaticResource(){
    	/*Profile prof = [SELECT Id, Name FROM Profile WHERE Name like 'Master - Account Executive' LIMIT 1];
        
        User userSysAdmin = TestUtil.prepareUser();
		insert userSysAdmin;

		User userAE = TestUtil.createAEUser();
		userAE.ProfileId = prof.Id;
		userAE.Approving_Manager__c = userSysAdmin.Id;
		userAE.Team_Role__c = 'Account Executive';
		update userAE;*/
		List<Account> accList =  new List<Account>();
        Account testAccts = new Account(Name = 'Big Oak Golf', DunsNumber__c = '059643510',
		                                Primary_Commodity__c = 'Retail', Active__c = true,
		                                Commodity_Codes__c = 'RETAIL -- Sporting Goods',
		                                BillingStreet = '441 NORTH WASHINGTON', BillingCountry = 'US',
		                                BillingCity = 'ST', BillingState = 'NY', BillingPostalCode = '14445', Website = 'bigoak.com', Phone = '5853815141');
        Account testAcct2 = new Account(Name = 'Big Oak Golf2', DunsNumber__c = '',
		                                Primary_Commodity__c = 'Retail', Active__c = true,
		                                Commodity_Codes__c = 'RETAIL -- Sporting Goods',
		                                BillingStreet = '441 NORTH WASHINGTON', BillingCountry = 'US',
		                                BillingCity = 'ST', BillingState = 'NY', BillingPostalCode = '14445', Website = 'bigoak.com', Phone = '5853815141');
        accList.add(testAccts);
        accList.add(testAcct2);
        insert accList;
        
        D_B_account__c dnbAccount = new D_B_account__c(Name='Test DnB Account', PrimaryAddress1__c = 'Test Add 1', PrimaryStreetAddress__c='Test Street', 
                                                       PrimaryCityName__c='New York', PrimaryStateProvinceName__c='NY', 
                                                       PrimaryAddressPostalCode__c='76544', PrimaryCountryName__c='US',
                                                       DUNSNumber__c='86868668');
        insert dnbAccount;
        
        User userAE = [SELECT ID FROM User WHERE Name = 'Rachel Fromm' And Profile.Name = 'Master - Account Executive' and isActive = true LIMIT 1];
        RecordType objRecType = [SELECT ID FROM RecordType WHERE DeveloperName = 'Create_new_account' LIMIT 1];
        System.runAs(userAE){
            Account_Request__c objAccReq = TestUtil.getAccountRequestRec(testAccts.Id, userAE.Id, objRecType.Id);
            objAccReq.Advertiser_Agency_Rep_Firm__c = testAccts.Id;
            insert objAccReq;
        }
  	}
    
	static testMethod void testgetNewAccount() {
		Account testAccts = new Account(Name = 'Biwerwrwrwg Oacvxk Goldfsfsff', DunsNumber__c = '05643510',
		                                Primary_Commodity__c = 'Retail', Active__c = true,
		                                Commodity_Codes__c = 'RETAIL -- Sporting Goods',
		                                BillingStreet = '441 NORTH WASHINGTON', BillingCountry = 'US',
		                                BillingCity = 'ST', BillingState = 'NY', BillingPostalCode = '14445', Website = 'bigoak.com', Phone = '5853815141');

		System.debug('Account Instance Created ' + testAccts);
		insert testAccts;
		Test.startTest();
		AccountRequestFinanceAPIController.getNewAccount(testAccts.Id);
		Test.stopTest();
	}
	public static testmethod void testgetSFAccount() {
		Account testAccts = new Account(Name = 'Bifssfsg Ogfgffak Golbvbcbdf', DunsNumber__c = '059643510',
		                                Primary_Commodity__c = 'Retail', Active__c = true,
		                                Commodity_Codes__c = 'RETAIL -- Sporting Goods',
		                                BillingStreet = '441 NORTH WASHINGTON', BillingCountry = 'US',
		                                BillingCity = 'ST', BillingState = 'NY', BillingPostalCode = '14445', Website = 'bigoak.com', Phone = '5853815141');

		System.debug('Account Instance Created ' + testAccts);
		insert testAccts;
		Test.startTest();
		AccountRequestFinanceAPIController.getSFAccount(testAccts);
		Test.stopTest();

	}
	public static testmethod void testgetAccDbJuncData() {
		Account testAccts = new Account(Name = 'Biddg Oak Golf', DunsNumber__c = '059643510',
		                                Primary_Commodity__c = 'Retail', Active__c = true,
		                                Commodity_Codes__c = 'RETAIL -- Sporting Goods',
		                                BillingStreet = '441 NORTH WASHINGTON', BillingCountry = 'US',
		                                BillingCity = 'ST', BillingState = 'NY', BillingPostalCode = '14445', Website = 'bigoak.com', Phone = '5853815141');

		System.debug('Account Instance Created ' + testAccts);
		insert testAccts;
		Test.startTest();
		AccountRequestFinanceAPIController.getAccDbJuncData(testAccts.Id);
		Test.stopTest();
	}
	public static testmethod void testupdateAccountInfo() {
		Account testAccts = new Account(Name = 'Bdadafsffsig Oafdffk Golf', DunsNumber__c = '059643510',
		                                Primary_Commodity__c = 'Retail', Active__c = true,
		                                Commodity_Codes__c = 'RETAIL -- Sporting Goods',
		                                BillingStreet = '441 NORTH WASHINGTON', BillingCountry = 'US',
		                                BillingCity = 'ST', BillingState = 'NY', BillingPostalCode = '14445', Website = 'bigoak.com', Phone = '5853815141');

		System.debug('Account Instance Created ' + testAccts);
		insert testAccts;
		Test.startTest();
		AccountRequestFinanceAPIController.updateAccountInfo(testAccts);
		Test.stopTest();
	}
	public static testmethod void testupdateAccount() {
		Account testAccts = new Account(Name = 'Bieqewqeqeg Ogghhhhak Gollklklf', DunsNumber__c = '059643510',
		                                Primary_Commodity__c = 'Retail', Active__c = true,
		                                Commodity_Codes__c = 'RETAIL -- Sporting Goods',
		                                BillingStreet = '441 NORTH WASHINGTON', BillingCountry = 'US',
		                                BillingCity = 'ST', BillingState = 'NY', BillingPostalCode = '14445', Website = 'bigoak.com', Phone = '5853815141');

		System.debug('Account Instance Created ' + testAccts);
		insert testAccts;
		Test.startTest();
		AccountRequestFinanceAPIController.updateAccount(testAccts);
		Test.stopTest();
	}
	/*public static testmethod void testaccountActivate() {
        
        Account testAccts = [SELECT ID FROM Account WHERE Name  = 'Big Oak Golf' LIMIT 1];
        User userAE = [SELECT ID FROM USER WHERE Username = 'testsales1@mands.com'];
        Test.startTest();		
		RecordType objRecType = [SELECT ID FROM RecordType WHERE DeveloperName = 'Create_new_account' LIMIT 1];

		Account_Request__c objAccReq = TestUtil.getAccountRequestRec(testAccts.Id, userAE.Id, objRecType.Id);
		objAccReq.Advertiser_Agency_Rep_Firm__c = testAccts.Id;
		objAccReq.Account_Executive__c = userAE.Id;
		objAccReq.OwnerId = userAE.Id;
		insert objAccReq;
	
		AccountRequestFinanceAPIController.accountActivate(testAccts.id);
		Test.stopTest();
	}*/

	public static testmethod void testalertAE() {
		Test.startTest();
            Account testAccts = [SELECT ID FROM Account WHERE Name  = 'Big Oak Golf' LIMIT 1];
            AccountRequestFinanceAPIController.alertAE(testAccts.Id, new List<String> { 'Name' });
		Test.stopTest();
	}
    
    public static testmethod void testgetAeAddressDetails() {
        User userAE = [SELECT ID FROM User WHERE Name = 'Rachel Fromm' And Profile.Name = 'Master - Account Executive' and isActive = true LIMIT 1];
        System.runAs(userAE){
            Test.startTest();
                Account_Request__c accReq = [SELECT ID FROM Account_Request__c WHERE RecordType.DeveloperName  = 'Create_new_account' LIMIT 1];
                AccountRequestFinanceAPIController.getAeAddressDetails(accReq.Id);
            Test.stopTest();
        }
    }
	
	public static testmethod void testgetRecordType() {
		RecordType objRecType = [SELECT ID FROM RecordType WHERE Name = 'Advertiser Account' LIMIT 1];
		Account testAccts = new Account(Name = 'Birwrwrwsffsg Orwrwrak fsfsGolf', DunsNumber__c = '0643510',
		                                Primary_Commodity__c = 'Retail', Active__c = true,
		                                Commodity_Codes__c = 'RETAIL -- Sporting Goods',
		                                BillingStreet = '441 NORTH WASHINGTON', BillingCountry = 'US',
		                                BillingCity = 'ST', BillingState = 'NY', BillingPostalCode = '14445', Website = 'bigoak.com', Phone = '5853815141', RecordTypeId = objRecType.Id);

		System.debug('Account Instance Created ' + testAccts);
		insert testAccts;
		Test.startTest();
		AccountRequestFinanceAPIController.getRecordType('Advertiser Account');
		Test.stopTest();
	}
	public static testmethod void testgetAccountList() {
		RecordType objAdvRecType = [SELECT ID FROM RecordType WHERE Name = 'Agency Account' LIMIT 1];

		Account testAccts = new Account(Name = 'Bisddag Ofsfsak Golf', DunsNumber__c = '643510',
		                                Primary_Commodity__c = 'Retail', Active__c = true,
		                                BillingStreet = '441 NORTH WASHINGTON', BillingCountry = 'US',
		                                BillingCity = 'ST', BillingState = 'NY', BillingPostalCode = '14445', Website = 'bigoak.com', Phone = '5853815141', RecordTypeId = objAdvRecType.Id);
		INSERT testAccts;
		AccountRequestFinanceAPIController.getAccountList('Big Oak Golf', null, '');
		AccountRequestFinanceAPIController.getTrafficIds(testAccts.Id);
	}
	public static testmethod void testfindStateRecords() {
		lwcCustomLookup.findStateRecords('NY', 'Account_Creation_States__mdt', 'State_code__c', 'state_Name__c', 'country__c');
	}
    public static testmethod void testgetDnBAccount(){
        D_B_account__c dnbAccount =  [SELECT Id FROM D_B_account__c WHERE Name = 'Test DnB Account'];
        AccountRequestFinanceAPIController.getDnBAccount(dnbAccount.Id);
    }
    public static testmethod void testmergeAccount(){
        List<Account> lstAccnts = [SELECT ID FROM Account Limit 2];
        Account_Request__c accReq = [SELECT ID FROM Account_Request__c WHERE RecordType.DeveloperName  = 'Create_new_account' LIMIT 1];
        AccountRequestFinanceAPIController.mergeAccount(lstAccnts[0].Id, lstAccnts[1].Id, accReq.Id);
    }
    public static testmethod void testaccountActivate(){
        Account acc = [SELECT ID FROM Account Limit 1];
        AccountRequestFinanceAPIController.accountActivate(acc.Id);
    }
}