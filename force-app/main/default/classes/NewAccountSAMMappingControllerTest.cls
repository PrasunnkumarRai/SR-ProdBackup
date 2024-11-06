@isTest
public class NewAccountSAMMappingControllerTest {
    
    static testMethod void myUnitTest() {
        
        // Create record type map
        map<String, Id> mapRecordTypeId = new map<String, Id>();
        for (RecordType accRT : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND (DeveloperName='Agency_Account' OR DeveloperName='Advertiser_Account')]) {
            mapRecordTypeId.put(accRT.DeveloperName, accRT.Id);
        }
        
        // Create a separate test user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User userObj = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser@charter.com.uat',
            Username = 'testuser@charter.com.uat' + System.currentTimeMillis(),
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert userObj;
        
        System.runAs(userObj) {
            // Create an Account
            Account adsAccount = new Account(Name='Test Ads Account', RecordTypeId=mapRecordTypeId.get('Advertiser_Account'), 
                BillingStreet='235 High St', BillingCity='Morgantown', BillingState='WV', 
                BillingPostalCode='26505', BillingCountry='USA', 
                ShippingStreet='235 High St', ShippingCity='Morgantown', 
                ShippingState='WV', ShippingPostalCode='26505', 
                ShippingCountry='USA', Legal_Entity_Name__c='Test Legal Name');
            insert adsAccount;
            
            // Create Account_SAM_Mapping__c record with a valid designation
            Account_SAM_Mapping__c newAsm = new Account_SAM_Mapping__c(Account__c=adsAccount.Id, User__c=userObj.Id, 
                SAM_Designation__c='Target'); // Replace with an actual valid designation
            insert newAsm;
            
            Test.startTest();
            // Call the createAccountSAMMapping method
            NewAccountSAMMappingController.createAccountSAMMapping(adsAccount.Id);
            
            // Call the checkCountForTargetAndExtra method to cover it
            String result = NewAccountSAMMappingController.checkCountForTargetAndExtra('ValidDesignation', userObj.Id); // Use the same valid designation
            System.debug('Result from checkCountForTargetAndExtra: ' + result);
            Test.stopTest();
        }
    }
}