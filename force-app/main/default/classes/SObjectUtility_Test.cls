/* 
    Customer/Project:  Spectrum Reach
    Class name:         SObjectUtility_Test
    Author/Date:       Brett Ballantyne    6/4/2018
    Release:            
    Purpose:           Test class for SObjectUtility_Test
*/

@isTest
private class SObjectUtility_Test {

    @testSetup static void createTestData() {
         Account objAgencyAcc = TestUtil.getAgencyAccountRec();
        insert objAgencyAcc;
    }

    @isTest static void testController() {
        Account acc = [select Id, Name from Account limit 1];
        system.debug('-------->> acc = ' + acc);
        ApexPages.StandardController sc = new ApexPages.standardController(acc);
        SObjectUtility controller = new SObjectUtility(sc);
        String recName = controller.getRecordName();
        system.debug('----------------->> recName = ' + recName);
        // recName will be in the form: Hello Test Account Owner Change1 (001m000000hsiYcAAI)
        System.assertEquals('Hello ' + acc.Name + ' (' + acc.Id + ')', recName);
        controller.createNewAccount();
    }
    
}