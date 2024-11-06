@IsTest
public class AccountCNARequestActionControllerTest {
/* created by vinay chaturvedi */ 
    @testSetup 
    private static void createTestData(){
        map<String, Id> mapRecordTypeId = new map<String, Id>();
        for( RecordType accRT : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND ( DeveloperName='Agency_Account' OR DeveloperName='Advertiser_Account' )]){
            mapRecordTypeId.put( accRT.DeveloperName, accRT.Id );
        }
        
        User userObj = TestUtil.prepareUser();
        userObj.Approving_Manager__c = UserInfo.getUserId();
        userObj.Sales_Office__c = 'Charlotte - DOS';
        userObj.Region__c = 'Florida';
        userObj.Division__c = 'South';
        insert userObj;
        
        System.runAs( userObj ){
            
            // Create Test Accounts
            Account AdsAccount = new Account(Name='Test Ads Account', RecordTypeId=mapRecordTypeId.get('Advertiser_Account'), BillingStreet = '235 High St',
                BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
                BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
                ShippingPostalCode = '26505', ShippingCountry = 'USA', Legal_Entity_Name__c='Test Legal Name' );
                
            Account AgencyAccount = new Account(Name='Test Agency Account', RecordTypeId=mapRecordTypeId.get('Agency_Account'), BillingStreet = '235 High St',
                BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
                BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
                ShippingPostalCode = '26505', ShippingCountry = 'USA' );
            
            insert new list<Account>{ AdsAccount, AgencyAccount };
            
            AdsAccount.Agency__c=AgencyAccount.Id;
            update AdsAccount;
            
        }
    }
    
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        User userObj = [Select Id, Name from User where email = 'test.ms@gmail.com' limit 1];
        Account acc = [SELECT Id, Name FROM Account limit 1];
        System.runAs(userObj) {
            AccountCNARequestActionController.createCNARequest( acc.Id );
            System.assertEquals('Test Ads Account', acc.Name);
        }

    }

}