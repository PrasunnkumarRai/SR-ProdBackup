@isTest
public class LwcfbodnbaccountupdateControllerTest {

    static testMethod void testGetAccountDetails() {
        //  test account
        Account acc = new Account(Name='Test Account');
        insert acc;

        List<String> accountIds = new List<String>();
        accountIds.add(acc.Id);

        Test.startTest();
        List<Account> accountList = LwcfbodnbaccountupdateController.getAccountDetails(accountIds);
        Test.stopTest();

       // System.assertEquals(1, accountList.size());
        //System.assertEquals('Test Account', accountList[0].Name);
    }

    static testMethod void testUpdateAccountDetails() {
        //  test account
        Account acc = new Account(Name='Test Account');
        insert acc;

        // Update e
        acc.Name = 'Updated Test Account';

        List<Account> accToUpdate = new List<Account>();
        accToUpdate.add(acc);
        List<string> str =new List<string>();
        str.add(acc.id);
        Test.startTest();
        String result = LwcfbodnbaccountupdateController.updateAccountDetails(accToUpdate);
                     LwcfbodnbaccountupdateController.getLoggerInformation(acc.id);
              LwcfbodnbaccountupdateController.mergeAccs(acc.id,str);
        Test.stopTest();

        
        System.assertEquals('OK', result);

        
        Account updatedAcc = [SELECT Name FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Updated Test Account', updatedAcc.Name);
    }

    static testMethod void testGetAccountDetailsWithNoAccounts() {
        
        Test.startTest();
        List<Account> accountList = LwcfbodnbaccountupdateController.getAccountDetails(new List<String>{});
        Test.stopTest();

        
        System.assertEquals(0, accountList.size());
    }

   /* static testMethod void testUpdateAccountDetailsWithNullList() {
        // Call updateAccountDetails with a null list of accounts to update
        Test.startTest();
        LwcfbodnbaccountupdateController.updateAccountDetails('');
        Test.stopTest();

        // Verify that no exception is thrown
        System.assert(true);
    }   */

    static testMethod void testSelectedAccountIDs() {
        // test accounts
        Account acc1 = new Account(Name = 'Test Account 1');
        Account acc2 = new Account(Name = 'Test Account 2');
        insert new List<Account>{acc1, acc2};

        
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(new List<Account>{acc1, acc2});

        LwcfbodnbaccountupdateController controller = new LwcfbodnbaccountupdateController(ssc);
        
        LwcfbodnbaccountupdateController.SelectedAccountIDs = new String[]{acc1.Id, acc2.Id};
            }
   /* @isTest
    public static void getAdvertiserAgencyRepFirmTest(){
         Account acc1 = new Account(Name = 'Test Account 1');
         insert acc1;
        Account_Request__c acc = new   Account_Request__c();
        acc.Advertiser_Agency_Rep_Firm__c = acc1.Id;
        Account_Executive_Approving_Manager__c
        insert acc;
        LwcfbodnbaccountupdateController.getAdvertiserAgencyRepFirm(String.valueof(acc.Id));
        
    }*/

  @isTest
    static void testUpsertDNBAccountJunctionDetails() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create test D_B_account__c records
        D_B_account__c dnbAccount1 = new D_B_account__c(Name = 'Test D&B Account 1', DUNSNumber__c = '123456789');
        D_B_account__c dnbAccount2 = new D_B_account__c(Name = 'Test D&B Account 2', DUNSNumber__c = '987654321');
        insert dnbAccount1;
        insert dnbAccount2;

        // Create a list of DUNSDataModel objects
        List<LwcfbodnbaccountupdateController.DUNSDataModel> dnbAccJunctions = new List<LwcfbodnbaccountupdateController.DUNSDataModel>();
        LwcfbodnbaccountupdateController.DUNSDataModel dnbModel1 = new LwcfbodnbaccountupdateController.DUNSDataModel();
        dnbModel1.name = 'Company One';
        dnbModel1.Phone = '123-456-7890';
        dnbModel1.Address = '123 Main St';
        dnbModel1.DUN = '123456789';
        dnbModel1.ConfidenceCode = 'A';
        dnbModel1.mostSeniorPrincipals = 'John Doe';
        dnbModel1.website = 'http://www.companyone.com';
        dnbModel1.outofBusiness = 'No';
        dnbModel1.EmployeeCount = 100;
        dnbModel1.Revenue = 1000000.00;
        dnbModel1.MailingAddress = '123 Main St, Suite 100';
        dnbModel1.operatingStatus = 'Active';
        dnbModel1.ErrorMessage = '';
        dnbModel1.isDataError = false;
        dnbModel1.billingStreet = '123 Billing St';
        dnbModel1.billingState = 'CA';
        dnbModel1.billingCity = 'San Francisco';
        dnbModel1.billingZipCode = '94105';
        dnbModel1.billingCountry = 'USA';
        dnbAccJunctions.add(dnbModel1);

        dnbAccJunctions.add(dnbModel1);

        LwcfbodnbaccountupdateController.DUNSDataModel dnbModel2 = new LwcfbodnbaccountupdateController.DUNSDataModel();
         dnbModel2.name = 'Company Two';
        dnbModel2.Phone = '987-654-3210';
        dnbModel2.Address = '456 Elm St';
        dnbModel2.DUN = '987654321';
        dnbModel2.ConfidenceCode = 'B';
        dnbModel2.mostSeniorPrincipals = 'Jane Doe';
        dnbModel2.website = 'http://www.companytwo.com';
        dnbModel2.outofBusiness = 'No';
        dnbModel2.EmployeeCount = 200;
        dnbModel2.Revenue = 2000000.00;
        dnbModel2.MailingAddress = '456 Elm St, Suite 200';
        dnbModel2.operatingStatus = 'Active';
        dnbModel2.ErrorMessage = '';
        dnbModel2.isDataError = false;
        dnbModel2.billingStreet = '456 Billing St';
        dnbModel2.billingState = 'NY';
        dnbModel2.billingCity = 'New York';
        dnbModel2.billingZipCode = '10001';
        dnbModel2.billingCountry = 'USA';
        dnbAccJunctions.add(dnbModel2);
        dnbAccJunctions.add(dnbModel2);

        Test.startTest();
        // Call the upsert method
        LwcfbodnbaccountupdateController.upsertDNBAccountJunctionDetails(dnbAccJunctions, testAccount.Id);
        Test.stopTest();

        // Query the D_B_Account_Junction__c records to verify they were upserted
        /*List<D_B_Account_Junction__c> junctionRecords = [SELECT Id, Account__c, D_B_Account__c FROM D_B_Account_Junction__c WHERE Account__c = :testAccount.Id];
        System.assertEquals(2, junctionRecords.size(), 'Two junction records should be upserted');
        System.assertEquals(dnbAccount1.Id, junctionRecords[0].D_B_Account__c);
        System.assertEquals(dnbAccount2.Id, junctionRecords[1].D_B_Account__c);*/
    }

    @isTest
    static void testUpsertDNBAccountJunctionDetailsWithException() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a list of DUNSDataModel objects with invalid DUN
        List<LwcfbodnbaccountupdateController.DUNSDataModel> dnbAccJunctions = new List<LwcfbodnbaccountupdateController.DUNSDataModel>();
        LwcfbodnbaccountupdateController.DUNSDataModel dnbModel = new LwcfbodnbaccountupdateController.DUNSDataModel();
        dnbModel.DUN = 'invalidDUN';
        dnbAccJunctions.add(dnbModel);

        Test.startTest();
        try {
            // Call the upsert method, which should throw an exception
            LwcfbodnbaccountupdateController.upsertDNBAccountJunctionDetails(dnbAccJunctions, testAccount.Id);
           // System.assert(false, 'Expected an AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
           // System.assertEquals('Attempt to de-reference a null object', e.getMessage());
        }
        Test.stopTest();
    }
}