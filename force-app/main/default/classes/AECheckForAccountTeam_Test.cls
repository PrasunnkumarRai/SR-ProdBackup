@isTest
public class AECheckForAccountTeam_Test {
	static testMethod void checkAccExeInAccTeam_Testmethod() {
        map<String, Id> mapRecordTypeId = new map<String, Id>();
        for( RecordType accRT : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND ( DeveloperName='Agency_Account' OR DeveloperName='Advertiser_Account' )]){
        	mapRecordTypeId.put( accRT.DeveloperName, accRT.Id );
        }
        User userAE = TestUtil.prepareUser();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
//        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@mands.com';
        userAE.Email = 'testae@mands.com';
        userAE.Team_Role__c = 'Account Executive';
        userAE.Approving_Manager__c = UserInfo.getUserId();
        insert userAE;
        System.runAs(userAE){
            Account acc = new Account(Name='Test Ads Account', RecordTypeId=mapRecordTypeId.get('Advertiser_Account'), BillingStreet = '235 High St',
                    BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
                    BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
                    ShippingPostalCode = '26505', ShippingCountry = 'USA', Legal_Entity_Name__c='Test Legal Name' );
                    
            insert acc;
            Account_Request__c ar = new Account_Request__c();
            ar.Advertiser_Agency_Rep_Firm__c = acc.Id;
            ar.RecordTypeId = AccountRequestUtils.teamMemberRequestRtId;
            ar.Account_Executive__c = userAE.Id;
            ar.Requested_Regions__c = 'Big West';
            ar.Requested_Markets__c = 'Billings MT'; 
            insert ar;
            System.debug('@@ar '+ar);
            AECheckForAccountTeam.checkAccExeInAccTeam(ar.Id);
        }
    }
}