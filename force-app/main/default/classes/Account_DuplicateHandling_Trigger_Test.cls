/* 
    Customer/Project:   Spectrum Reach
    Class name:          Account_DuplicateHandling_Trigger_Test
    Author/Date:        Brett Ballantyne    7/12/2017
    Release:             TBD
    Purpose:            The test class for Account_DuplicateHandling_Trigger
*/

@isTest
private class Account_DuplicateHandling_Trigger_Test {
	
	@isTest static void test_method_one() {
       	DuplicateRule dR = [select id from DuplicateRule where DeveloperName = 'Standard_Account_Duplicate_Rule' LIMIT 1];
        DuplicateRecordSet dupRS = new DuplicateRecordSet(DuplicateRuleId = dR.id);
        insert dupRS;
        Test.startTest();
        Account acc = new Account(Name='TestAccount',
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
         Database.DMLOptions insertDML = new Database.DMLOptions(); 
        insertDML.DuplicateRuleHeader.AllowSave = true; 
        Database.SaveResult sr = Database.insert(acc, insertDML);
        system.debug('===============>> sr = ' + sr);
        DuplicateRecordItem dup = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId=sr.getId());
        insert dup;
        Test.stopTest();	
	}

}