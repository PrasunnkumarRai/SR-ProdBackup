@isTest
private class AccountRequestTriggerHandlerTest {
    static testMethod void testMethod1() {
        User u = TestDataHelper.createSystemAdminUser(true);
        
        System.runAs( u ){
            User userAE = TestUtil.prepareUser();
            
            Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
            userAE.Username = 'testae@mands.com';
            userAE.Email = 'testae@charter.com';
            userAE.Team_Role__c = 'Account Executive';
            userAE.Approving_Manager__c = UserInfo.getUserId();
            
            User userSalesManager = TestUtil.prepareUser();
            objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Local Sales Manager'];
            userSalesManager.Username = 'testlsm@mands.com';
            userSalesManager.Email = 'testlsm@charter.com';
            userSalesManager.Team_Role__c = 'Sales Manager';
            userSalesManager.Approving_Manager__c = UserInfo.getUserId();
            
            User userObj = TestUtil.prepareUser();
            
            userObj.Approving_Manager__c = UserInfo.getUserId();
            
            insert new list<User>{ userObj, userAE, userSalesManager };
                
            
            map<String, Id> mapRecordTypeId = new map<String, Id>();
            for( RecordType accRT : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND ( DeveloperName='Agency_Account' OR DeveloperName='Advertiser_Account' )]){
                mapRecordTypeId.put( accRT.DeveloperName, accRT.Id );
            }
            
            Account acc = new Account(Name='Test Ads Account', RecordTypeId=mapRecordTypeId.get('Advertiser_Account'), BillingStreet = '235 High St',
                                      BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
                                      BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
                                      ShippingPostalCode = '26505', ShippingCountry = 'USA', Legal_Entity_Name__c='Test Legal Name' );
            
            Account acc2 = new Account(Name='Test Agency Account', RecordTypeId=mapRecordTypeId.get('Agency_Account'), BillingStreet = '235 High St',
                                       BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
                                       BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
                                       ShippingPostalCode = '26505', ShippingCountry = 'USA' );
            
            insert new list<Account>{ acc, acc2 };
                
            Account_Request__c ar;
            
            System.runAs( userAE ){
                ar = new Account_Request__c();
                ar.Advertiser_Agency_Rep_Firm__c = acc.Id;
                ar.RecordTypeId = AccountRequestUtils.teamMemberRequestRtId;
                insert ar;
                System.debug('@@ar '+ar);
                AccountRequestTriggerHandler.isFBOUser(Userinfo.getUserId());
            }
            
            Account_Request__c ar2;
            System.runAs( userSalesManager ){
                ar2 = new Account_Request__c();
                ar2.Advertiser_Agency_Rep_Firm__c = acc2.Id;
                ar2.RecordTypeId = AccountRequestUtils.teamMemberRequestRtId;
                ar2.Account_Executive__c = userAE.Id;
                insert ar2;
                System.debug('@@ar2 '+ar2);
            }
            
            Account_Request__c ar3;
            
            System.runAs( userSalesManager ){
                ar3 = new Account_Request__c();
                ar3.Status__c = 'In Approval Process';
                ar3.Advertiser_Agency_Rep_Firm__c = acc.Id;
                ar3.RecordTypeId = Schema.SObjectType.Account_Request__c.getRecordTypeInfosByName().get('Account Approval Request').getRecordTypeId();
                ar3.Account_Executive__c = userAE.Id;
                insert ar3;
                System.debug('@@ar3 '+ar3);
            }
        }
    }
    
    static testMethod void isFBOTest(){
        
        User userSalesManager = TestUtil.prepareUser();
        String objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Local Sales Manager' Limit 1].Id;
        userSalesManager.profileid = objProfile;
        userSalesManager.Username = 'testlsm@mands.com';
        userSalesManager.Email = 'testlsm@charter.com';
        userSalesManager.Team_Role__c = 'Sales Manager';
        userSalesManager.Approving_Manager__c = UserInfo.getUserId();
        insert userSalesManager;
        
        AccountRequestTriggerHandler.isFBOUser(userSalesManager.Id);
    }
    
    static testMethod void extraMethodTest(){
        List<Account_Request__c> ars = [SELECT Name FROM Account_Request__C];
        List<Account_Request__c> oldars = new List<Account_Request__c>();
        oldars.addAll(ars);
        Map<ID, Account_Request__c> arsMap = new Map<ID, Account_Request__c>();
        Integer count = 0;
        Set<Id> accReqId = new   Set<Id>();
        for (Account_Request__c prSer:ars) {
            arsMap.put(prSer.Id, prSer);
            if(count++ == 0) {
                prSer.Team_Member_Approved__c = 'Approved';
            }
            else {
                prSer.RecordTypeId = AccountRequestUtils.billingRequestRtId;
                prSer.Status__c = 'Completed';
                prSer.New_Account_Owner__c  = UserInfo.getUserId();
            }
        }
        set<Id> Stid =new set<id>();
        AccountRequestTriggerHandler arTrigger = new AccountRequestTriggerHandler(true,1);
        Boolean IsTriggerContext = arTrigger.IsTriggerContext;
        Boolean IsVisualforcePageContext = arTrigger.IsVisualforcePageContext;
        Boolean IsWebServiceContext = arTrigger.IsWebServiceContext;
        Boolean IsExecuteAnonymousContext = arTrigger.IsExecuteAnonymousContext;
        arTrigger.OnBeforeInsert(ars);
       // arTrigger.OnAfterInsertAsync(Stid);
        arTrigger.OnAfterInsert(ars);
        arTrigger.OnBeforeUpdate(ars,oldars,arsMap);
        arTrigger.OnAfterUpdate(ars,oldars,arsMap);
        arTrigger.OnUndelete(ars);
        AccountRequestTriggerHandler.OnAfterUpdateAsync(accReqId);
        arTrigger.OnBeforeDelete(ars, arsMap);
        arTrigger.OnAfterDelete(ars, arsMap);
        AccountRequestTriggerHandler.OnAfterDeleteAsync(accReqId);
    }
}