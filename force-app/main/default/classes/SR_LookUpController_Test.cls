/* 
    Customer/Project:   Spectrum Reach
    Class name:         SR_LookUpController_Test
    Author/Date:       Brett Ballantyne    6/4/2018
    Release:            
    Purpose:           Test class for SR_LookUpController - NOTE: not sure if / where that class and associated
                       Lightning Component are used
*/

@isTest
private class SR_LookUpController_Test {
    
    @testSetup static void createTestData() {
         Account objAgencyAcc = TestUtil.getAgencyAccountRec();
        insert objAgencyAcc;

    }
    
    @isTest static void testLookup() {
        Account acc = [select Id, Name from Account limit 1];
        system.debug('-------->> acc = ' + acc);
        Id [] fixedSearcResults = new Id[1];
        fixedSearcResults[0] = acc.Id;
        Test.setFixedSearchResults(fixedSearcResults);
        SR_LookUpController.Result [] results = new List<SR_LookUpController.Result>();
        results = SR_LookUpController.lookup('Test', 'Account');
        system.debug('------->> results = ' + results);
        System.assertEquals(acc.Id, results[0].SObjectId);
    }
    
}