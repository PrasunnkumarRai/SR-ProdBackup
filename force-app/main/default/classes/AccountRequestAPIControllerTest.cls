@IsTest(SeeAllData = false)
public class AccountRequestAPIControllerTest {
    
    public static testmethod void testgetResult() {
        User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        User AEUser = TestUtil.createAEUser();
        system.debug('AEUser: '+AEUser.ProfileId);
        
        AEUser.ManagerId = thisUser.Id;
        AEUser.Approving_Manager__c = thisUser.Id;
        AEUser.Team_Role__c = 'Account Executive';
        update AEUser;
        
        Account accObj = new Account();
        accObj.Name = 'tes';
        insert accObj;
        
        Account accObj1 = new Account();
        accObj1.Name = 'testName';
        insert accObj1;
        
        Account_Request__c accRequest1 = new Account_Request__c();
        Account_Request__c accRequest2 = new Account_Request__c();
        Account_Request__c accRequest3 = new Account_Request__c();
        List<Account_Request__c> accRequests = new List<Account_Request__c>();
        List<Account> accounts = new List<Account>();
        Account accountData = new Account();
        Account accountData1 = new Account();
        Id AccountRecordTypeId = Schema.SObjectType.Account_Request__c.getRecordTypeInfosByName().get('Create New Account').getRecordTypeId();
        List<RecordType> AdvRecordTypeId = [SELECT ID, NAME, Description,DeveloperName FROM RecordType WHERE DeveloperName = 'Advertiser_Account'];
        
        accountData.Name = 'Spectrum';
        accountData.OwnerId = AEUser.Id;
        accountData.BillingStreet = '150,north avenue';
        accountData.BillingCity = 'New York';
        accountData.BillingCountry = 'USA';
        accountData.BillingState = 'NY';
        accountData.BillingPostalCode = '78001';
        accountData.RecordTypeId = AdvRecordTypeId[0].Id;
        accounts.add(accountData);
        
        accountData1.Name = 'TestSpectrum';
        accountData1.OwnerId = AEUser.Id;
        accountData1.BillingStreet = '150,north avenue';
        accountData1.BillingCity = 'New York';
        accountData1.BillingCountry = 'USA';
        accountData1.BillingState = 'NY';
        accountData1.BillingPostalCode = '78001';
        accountData1.RecordTypeId = AdvRecordTypeId[0].Id;
        accounts.add(accountData1);
        
        accRequest1.Account_Name__c = 'Spectrum Account';
        accRequest1.Billing_Street__c = '123,north avenue';
        accRequest1.Billing_City__c = 'New York';
        accRequest1.Billing_Country__c = 'USA';
        accRequest1.Billing_State_Province__c = 'New York';
        accRequest1.Phone__c = '22334455';
        accRequest1.Billing_Zip_Postal_Code__c='78001';
        accRequest1.ownerid = AEUser.Id;
        accRequest1.Account_Executive__c = AEUser.Id;
        accRequest1.Duplicate_Account__c = accObj.Id;
        accRequest1.Advertiser_Agency_Rep_Firm__c = accObj1.Id;
        accRequests.add(accRequest1);
        
        accRequest2.Account_Name__c = 'SpectrumTest';
        accRequest2.Billing_Street__c = '150,north avenue';
        accRequest2.Billing_City__c = 'New York';
        accRequest2.Billing_Country__c = 'USA';
        accRequest2.Billing_State_Province__c = 'New York';
        accRequest2.ownerid = AEUser.Id;
        accRequest2.Account_Executive__c = AEUser.Id;
        accRequest2.Duplicate_Account__c = accObj.Id;
        accRequest2.Advertiser_Agency_Rep_Firm__c = accObj1.Id;
        accRequests.add(accRequest2);
        
        insert accounts;
        insert accRequests;
        
        accRequest3.Account_Name__c = 'Spectrum';
        accRequest3.Billing_Street__c = '150,north avenue';
        accRequest3.Billing_City__c = 'New York';
        accRequest3.Billing_Country__c = 'USA';
        accRequest3.Billing_State_Province__c = 'NY';
        accRequest3.Billing_Zip_Postal_Code__c = '78001';
        accRequest3.OwnerId = AEUser.Id;
        accRequest3.RecordTypeId = AdvRecordTypeId[0].Id;
        
        system.debug('accRequests: '+accRequests[0].Id);
        
        Test.startTest();
        AccountRequestAPIController.getResult(accRequests[0]);
        AccountRequestAPIController.getResult(accRequests[1]);
        AccountRequestAPIController.getResult(accRequest3);
        Test.stopTest();
    }
    
    public static testmethod void testgetDnBData() {
        User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Account_Request__c details = new Account_Request__c();
        Integer counter = 1;
        
        details.Account_Name__c = 'Spectrum';
        details.Billing_Street__c = '123,north avenue';
        details.Billing_City__c = 'New York';
        details.Billing_Country__c = 'USA';
        details.Billing_State_Province__c = 'New York';
        details.Billing_Zip_Postal_Code__c='78001';
        details.Phone__c = '22334455';
        
        
        Test.startTest();
        Organization org = [Select Id, Name, IsSandbox from Organization LIMIT 1];
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock> ();
        WebServiceTestMockDandB methodname1 = new WebServiceTestMockDandB('dandbdata');
        String baseUrl1 =  (org.IsSandbox == false? Label.DnBBoomiBaseURL: Label.DnBBoomiSandboxBaseURL)+'Invoke_DnB/';
        endpoint2TestResp.put(baseUrl1,methodname1);
        
        WebServiceTestMockDandB methodname2 = new WebServiceTestMockDandB('enrichdata');
        String baseUrl2 =  (org.IsSandbox == false? Label.DnBBoomiBaseURL: Label.DnBBoomiSandboxBaseURL)+'Invoke_DnB_CSS/';
        endpoint2TestResp.put(baseUrl2,methodname2);
        
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        AccountRequestAPIController.getDnBData(details);
        Test.stopTest();
    }
    
    public static testmethod void testgetContactDetails() {
        List<String> acclist = new List<String>();
        User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Primary_Commodity__c = 'Alcoholic Beverages';
        acc.Commodity_Codes__c = 'ALC_BEV -- Beer and Wine';
        acc.DunsNumber__c ='123344';
        acclist.add(acc.DunsNumber__c);
        insert acc;
        
        /*  Account acc1 = new Account();
acc1.Name = 'Test AccountDone';
acc1.Primary_Commodity__c = 'Alcoholic Beverages';
acc1.Commodity_Codes__c = 'ALC_BEV -- Beer and Wine';
acc1.DunsNumber__c ='123364';
acclist.add(acc1.DunsNumber__c);
insert acc1;*/
        
        Account accObj = new Account();
        accObj.Name = 'testName';
        insert accObj;
        
        Contact con = new Contact();
        con.LastName = 'testlast';
        con.Email = 'test@charter.com';
        con.AccountId = acc.Id;
        con.Advertiser_Contact_Type__c = 'Agency Contact';
        insert con;
        
        D_B_account__c dnb = new D_B_account__c();
        dnb.Name = 'Test d and b';
        dnb.DUNSNumber__c = '123344';
        dnb.Confidence_Code__c  = 10;
        insert dnb;
        
        System.debug('@@@accid@@ ' + acc.id);
        Test.startTest();
        String email = 'john.sm@toyota.com';
        AccountRequestAPIController.duplicateContactEmailCheck(con.Email,accObj.Id);
        AccountRequestAPIController.duplicateContactEmailCheck(email,acc.Id);
        AccountRequestAPIController.getContactDetails(acc.Id);
        System.debug('@@@ 11' +acclist);
        map<string, string> mapDnBConfidence = new map<string,string>();
        mapDnBConfidence.put(dnb.DUNSNumber__c,String.valueOf(dnb.Confidence_Code__c));
        AccountRequestAPIController.setdnbJunctionData(mapDnBConfidence,acc.Id);
        AccountRequestAPIController.getdandbaccountsalesforce(acc.DunsNumber__c);
        Test.stopTest();
    }
    
    public static testmethod void testPrimarycomm() {
        PrimaryCommodityDependency.getDependentOptionsImpl();
       // DnbIDRJson dnb = new DnbIDRJson();
       // string dnbTest = dnb.strDnBIDRJson;
      //  DnbCSSJson dnbc = new DnbCSSJson();
        //string dnbcTest =  dnbc.strDnbCSSJson;
        
    }
    
    public static testmethod void testrecordtypeID() {
        AccountRequestAPIController.recordtypeID();
    }
    
    public static testmethod void testgetdandbAddress() {
        D_B_account__c dnbAccount = new D_B_account__c();
        dnbAccount.PrimaryStreetAddress__c = 'Test Street';
        dnbAccount.PrimaryStateProvinceName__c = 'NY';
        dnbAccount.PrimaryCityName__c = 'NY';
        dnbAccount.PrimaryCountryName__c = 'US';
        dnbAccount.PrimaryAddressPostalCode__c = '73006';
        dnbAccount.DUNSNumber__c = '12569999';
        insert dnbAccount;
        AccountRequestAPIController.getdandbAddress('12569999');
    }
    
    public static testmethod void testgetLeadDetails() {
        Lead objLead = TestUtil.getLeadRec();
        objLead.Email = 'Test@charter.com';
        insert objLead;
        Account objAcc = TestUtil.getAccountRec();
        insert objAcc;
        AccountRequestAPIController.getLeadDetails(objLead.Id);
        AccountRequestAPIController.updateLeads(objLead);
        AccountRequestAPIController.convertLead(objLead, objAcc.Id, True, 'Test Opportunity', UserInfo.getUserId());
        AccountRequestAPIController.accountDetails(objAcc.Id);
    }
    
    public static testmethod void testfindStateRecords() {
        AccountRequestAPIController.findStateRecords('NY');
    }
    
    public static testmethod void testgetAccountListFinance() {
        RecordType objRecType = [SELECT ID FROM RecordType WHERE Name = 'Agency Account' LIMIT 1];
        Account objAcc = TestUtil.getAccountRec();
        objAcc.RecordTypeId = objRecType.Id;
        insert objAcc;
        AccountRequestAPIController.getAccountListFinance('Test',null,'');
        AccountRequestAPIController.getAccountList('Test',null,'');
    } 
    
    public static testmethod void testAccountWrapper(){
        User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Account acc1 = new Account();
        acc1.Name = 'Test Account';
        //acc.RecordType= Account_Request;
        acc1.Primary_Commodity__c = 'Alcoholic Beverages';
        acc1.Commodity_Codes__c = 'ALC_BEV -- Beer and Wine';
        acc1.DunsNumber__c ='123344';
        insert acc1;
        
        Test.startTest();
        AccountRequestAPIController.AccountWrapper acc = new AccountRequestAPIController.AccountWrapper(acc1);
        Test.stopTest();
    }
    
    public static testmethod void testSubmitForApproval(){
        User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        User AEUser = TestUtil.createAEUser();
        system.debug('AEUser: '+AEUser.ProfileId);
        
        AEUser.ManagerId = thisUser.Id;
        AEUser.Approving_Manager__c = thisUser.Id;
        AEUser.Team_Role__c = 'Account Executive';
        update AEUser;
        
        Account accObj = new Account();
        accObj.Name = 'testName';
        insert accObj;
        
        Account accObj1 = new Account();
        accObj1.Name = 't';
        insert accObj1;
        
        Id AccountRecordTypeId = Schema.SObjectType.Account_Request__c.getRecordTypeInfosByName().get('Create New Account').getRecordTypeId();
        Account_Request__c details = new Account_Request__c(); 
        details.Account_Name__c = 'Spectrum';
        details.Billing_Street__c = '123,north avenue';
        details.Billing_City__c = 'New York';
        details.Billing_Country__c = 'USA';
        details.Billing_State_Province__c = 'New York';
        details.Phone__c = '22334455';
        details.Billing_Zip_Postal_Code__c='78001';
        details.RecordTypeId = AccountRecordTypeId;
        details.Status__c = 'New';
        details.Account_Executive__c = AEUser.Id;
        details.ownerid = AEUser.Id;
        detailS.Duplicate_Account__c = accObj.Id;
        details.Advertiser_Agency_Rep_Firm__c = accObj1.Id;
        insert details;
        
        Test.startTest();
        AccountRequestAPIController.submitForApproval(details.Id);
        Test.stopTest();
    }
    
    public static testmethod void testduplicateContactNameCheck(){
        String name = 'John Smith';
        
        Test.startTest();
        AccountRequestAPIController.duplicateContactNameCheck(name);
        Test.stopTest(); 
    }
    
    public static testmethod void testgetRecordType(){
        RecordType recordTypeRec = new RecordType();
        recordTypeRec = [SELECT ID, NAME, DeveloperName FROM RecordType WHERE DeveloperName = 'Advertiser_Account' LIMIT 1];
        Test.startTest();
        AccountRequestAPIController.getRecordType(recordTypeRec.Id);
        Test.stopTest();
    }
    
    public static testmethod void testgetUserDetail(){
        Test.startTest();
        AccountRequestAPIController.getUserDetail(UserInfo.getUserId());
        Test.stopTest();
    }
    
    @IsTest
    static void testRemoveAll() {
        List<Object> target = new List<Object>{
            'apple', 'banana', 'apple', 'orange', 'apple'
                };
                    Object toRemove = 'apple';
        
        List<Object> result = AccountRequestAPIController.removeAll(target, toRemove);
        
        List<Object> expectedResult = new List<Object>{
            'banana', 'orange'
                };
                    
    }
    
}