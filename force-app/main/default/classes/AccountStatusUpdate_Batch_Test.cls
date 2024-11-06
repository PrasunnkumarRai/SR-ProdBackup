/* 
    Customer/Project:   Spectrum Reach
    Class name:         AccountStatusUpdate_Batch_Test
    Author/Date:        Brett Ballantyne    3/8/2017
    Release:            TBD
    Purpose:            Test class for AccountStatusUpdate_Batch
*/

@isTest
private class AccountStatusUpdate_Batch_Test {
    
    @isTest static void testDefaultConstructor() {
        Test.startTest();
        AccountStatusUpdate_Batch acctBatch = new AccountStatusUpdate_Batch();
        Database.executeBatch(acctBatch);
        Test.stopTest();
        List<Account> acctList = [select Id, Name, Active__c, Max_End_Date_Proposals__c from Account where Active__c = false];
        system.assertEquals(20, acctList.size());
    }
    
    @isTest static void testArgConstructor() {
        AccountStatusUpdate_Batch acctBatch = new AccountStatusUpdate_Batch(100, 'select Id, Name, Active__c, Max_End_Date_Proposals__c from Account');
        Test.startTest();
        Database.executeBatch(acctBatch);
        System.assertNotEquals(null, acctBatch);
        Test.stopTest();
    }

    @testSetup static void createTestData() {
        // create Contact for the account
        RecordType recType = [select Id from RecordType where IsActive = true and SobjectType = 'Contact' limit 1];
  //      Contact con = new Contact (LastName = 'TestContact', Phone = '303-111-2222', Email='testContact@somecompany.com', recordTypeId = recType.Id);  
  //      Insert con;     
        // Set up accounts
        Date oldDate = Date.today().addMonths(-14);
        List<Account> testAccts = new List<Account>();
    //    for (integer i = 0; i < 200; i++) {               // getting a Too Many SOQL error in the Box.com stuff, so reducing to 20
        for (integer i = 0; i < 20; i++) {
            Account acct = new Account(Name='TestAccount' + i, 
  //              Account_Rep__c = con.Id,
                BillingStreet = '235 High St',
                BillingCity = 'Morgantown',
                BillingState = 'WV',
                BillingPostalCode = '26505',
                BillingCountry = 'USA',
                ShippingStreet = '235 High St',
                ShippingCity = 'Morgantown',
                ShippingState = 'WV',
                ShippingPostalCode = '26505',
                ShippingCountry = 'USA'); // ,
              //  Max_End_Date_Proposals__c = oldDate);
            testAccts.add(acct);
        }
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true; 
        List<Database.SaveResult> srList = Database.insert(testAccts, dml);
      //  insert testAccts;
        System.assertEquals(20, testAccts.size());
    }
    
}