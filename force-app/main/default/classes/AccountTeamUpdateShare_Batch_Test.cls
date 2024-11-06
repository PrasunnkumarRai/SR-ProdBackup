/*
    Customer/Project:   Spectrum Reach
    Class name:          AccountTeamUpdateShare_Batch_Test
    Author/Date:        Brett Ballantyne    7/7/2017
    Release:             TBD
    Purpose:            Test class for AccountTeamUpdateShare_Batch
*/

@isTest
private class AccountTeamUpdateShare_Batch_Test {
	
	@isTest static void testBatch() {
		Test.startTest();
		AccountTeamUpdateShare_Batch atmBatch = new AccountTeamUpdateShare_Batch(20, 10);
		Database.executeBatch(atmBatch);
		Test.stopTest();
	}


    @testSetup static void createTestData() {
        List<Account> testAccts = new List<Account>();
    //    for (integer i = 0; i < 200; i++) {               // getting a Too Many SOQL error in the Box.com stuff, so reducing to 20
        for (integer i = 0; i < 20; i++) {
            Account acct = new Account(Name='TestAccount' + i, 
                BillingStreet = '235 High St',
                BillingCity = 'Morgantown',
                BillingState = 'WV',
                BillingPostalCode = '26505',
                BillingCountry = 'USA',
                ShippingStreet = '235 High St',
                ShippingCity = 'Morgantown',
                ShippingState = 'WV',
                ShippingPostalCode = '26505',
                ShippingCountry = 'USA');
            testAccts.add(acct);
        }
        insert testAccts;
    }
	
}