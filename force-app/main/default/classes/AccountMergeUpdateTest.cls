// @isTest
//     public static void testAccountDataMethod(){
//         Account accObj = new Account();
//         accObj.Name = 'testName';
//         insert accObj;
//        AccountMergeUpdate.getAccountDataMethod(accObj.Id);
//     }
    
//     @isTest
//     public static void testfindRecords(){
//         Account accObj = new Account();
//         accObj.Name = 'testName';
//         insert accObj;
        
//         String searchKey = 'Brooks Law Group';
//         String objectName = 'Account';
//         String searchField = 'Name';
//         String excludeId = accObj.Id;
//         String accRecType = accObj.RecordTypeId;
        
//         AccountMergeUpdate.findRecords(searchKey, objectName, searchField, excludeId, accRecType);
//     }
    
//     @isTest
//     public static void testverifySelectedAcc(){
//         Account accObj = new Account();
//         accObj.Name = 'testName';
//         insert accObj;
//         AccountMergeUpdate.verifySelectedAcc(accObj.Id);
//     }
    
//    // @isTest
//    // public static void testgetOpportunityData(){
//      //   Account accObj = new Account();
//        // accObj.Name = 'testName';
//         //insert accObj;
//        // AccountMergeUpdate.getOpportunityData(accObj.Id);
//     //}
    
//     @isTest
//     public static void testcallAccountMergeDetailInsertionBatch(){
//         Account accObj = new Account();
//         accObj.Name = 't';
//         insert accObj;
        
//         Account accObj1 = new Account();
//         accObj1.Name = 'testName';
//         insert accObj1;
        
//         AccountMergeUpdate.callAccountMergeDetailInsertionBatch(accObj.Id, accObj1.Id);
//        // SalesforceFilesUtility SFU=new SalesforceFilesUtility();
       
//    }
    
//     @isTest
//     public static void testupdateAccount(){
//         Account accObj = new Account();
//         accObj.Name = 'testName';
//         insert accObj;
//         AccountMergeUpdate.updateAccount(accObj);
//     }
    
    
    
    
//     public TestMethod static void SyncplicityTest1() {
//         User newAdminUser = TestDataHelper.createSystemAdminUser(true);
//         System.runAs(newAdminUser) {
//             SyncpIntCustSett.add(new SyncplicityIntegration__c(name = 'Syncplicity',
//                                                                Endpoint__c = 'https://api.syncplicity.com',
//                                                                Password__c = 'cd18cf8f-117f-4f66-acde-d6f1b3291566',
//                                                                SyncAppToken__c = 'FBLti9Bu2UEv8M1JBeJdVE2r55sEs0brphBlOrd9Xt2c32dVxDxZQvKpRbYu32Jq',
//                                                                UserName__c = 'c1d198e2-b351-4910-8a84-d84dfaee688a',
//                                                                APIBatchsize__c = 1,
//                                                                RootFolderSyncpointId__c = '14529970'));
//             System.debug('@@@@' + SyncpIntCustSett);
//             insert SyncpIntCustSett;
            
//             //Create main account
//             Account parentAcc = TestDataHelper.createAdvertiser('Advertiser Account', '123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');
//             insert parentAcc;
//             System.assert(parentAcc != null);
            
//             //Create child account
//             Account childAcc = TestDataHelper.createAdvertiser('Add Account_child', '123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');
//             insert childAcc;
//             parentAcc.MergeAccount__c = childAcc.id;
//             update parentAcc;
//             System.assert(childAcc != null);
            
//             List<Account_Merge_Log__c> accountMergeLogs = new List<Account_Merge_Log__c> ();
//             Account_Merge_Log__c objLog = new Account_Merge_Log__c();
//             objLog.Account__c = parentAcc.Id;
//             objLog.Merged_Account_ID__c = childAcc.Id;
//             System.debug('objLog ' + objLog);
//             accountMergeLogs.add(objLog);
//             insert accountMergeLogs;
            
//             //Creating synctable data
//             Syncplicity__SyncTable__c syn = new Syncplicity__SyncTable__c();
//             syn.Syncplicity__syncpFilesFolderId__c = '123567';
//             syn.Syncplicity__syncpEmailId__c = 'Test@charter.com';
//             syn.Syncplicity__uniqueId__c = 'Test12334';
//             syn.Syncplicity__syncpRecordFolderId__c = '1471037647834001';
//             syn.Syncplicity__isAdmin__c = 'True';
//             syn.Syncplicity__salesforceRecordId__c = parentAcc.Id;
//             syn.Syncplicity__salesforceUserId__c = newAdminUser.Id;
//             insert syn;
//             System.assert(syn != null);
            
//             Syncplicity__SyncTable__c syn1 = new Syncplicity__SyncTable__c();
//             syn1.Syncplicity__syncpFilesFolderId__c = '1235678';
//             syn1.Syncplicity__syncpEmailId__c = 'Test@charter.com';
//             syn1.Syncplicity__uniqueId__c = 'Test123345';
//             syn1.Syncplicity__syncpRecordFolderId__c = '1465949844910001';
//             syn1.Syncplicity__isAdmin__c = 'True';
//             syn1.Syncplicity__salesforceRecordId__c = childAcc.Id;
//             syn1.Syncplicity__salesforceUserId__c = newAdminUser.Id;
//             System.debug('@@@@' + syn1);
//             insert syn1;
//             System.assert(syn1 != null);
            
//             AccountMergeBatch objAccountMergeBatch = new AccountMergeBatch();
//             objAccountMergeBatch.acc = parentAcc;
//             objAccountMergeBatch.accMergeData = objLog;
            
//             Test.startTest();
//             Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock> ();
//             SyncplicityWebServiceMock methodName1 = new SyncplicityWebServiceMock('Authentication');
//             endpoint2TestResp.put('https://api.syncplicity.com/oauth/token', methodName1);
//             SyncplicityWebServiceMock methodName2 = new SyncplicityWebServiceMock('GetFolderContent');
//             endpoint2TestResp.put('https://api.syncplicity.com/sync/folder.svc/14529970/folder/1471037647834001?include=active', methodName2);
//             SyncplicityWebServiceMock methodName3 = new SyncplicityWebServiceMock('GetSourceFolderContent');
//             endpoint2TestResp.put('https://api.syncplicity.com/sync/folder.svc/14529970/folder/1465949844910001?include=active', methodName3);
//             SyncplicityWebServiceMock methodName4 = new SyncplicityWebServiceMock('GetAccountFolderContent');
//             endpoint2TestResp.put('https://api.syncplicity.com/sync/folder.svc/14529970/folder/1508934834195001?include=active', methodName4);
//             SyncplicityWebServiceMock methodName5 = new SyncplicityWebServiceMock('MoveFolders');
//             endpoint2TestResp.put('https://api.syncplicity.com/sync/folders.svc/14529970/folders', methodName5);
//             SyncplicityWebServiceMock methodName6 = new SyncplicityWebServiceMock('GetTestFolderContent');
//             endpoint2TestResp.put('https://api.syncplicity.com/sync/folder.svc/14529970/folder/1465949844914001?include=active', methodName6);
//             SyncplicityWebServiceMock methodName7 = new SyncplicityWebServiceMock('GetOpportunityFolderContent');
//             endpoint2TestResp.put('https://api.syncplicity.com/sync/folder.svc/14529970/folder/1465949844915001?include=active', methodName7);
//             SyncplicityWebServiceMock methodName8 = new SyncplicityWebServiceMock('GetCNAFolderContent');
//             endpoint2TestResp.put('https://api.syncplicity.com/sync/folder.svc/14529970/folder/1484145903156001?include=active', methodName8);
//             SyncplicityWebServiceMock methodName9 = new SyncplicityWebServiceMock('MoveFiles');
//             endpoint2TestResp.put('https://api.syncplicity.com/sync/files.svc/14529970/files', methodName9);
            
//             HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
//             Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            
//             // objAccountMergeBatch.MergeSyncpFolders();
            
//             Test.stopTest();
//         }
//     }
    
//     // public TestMethod static void SyncplicityTest2() {
//     //     User newAdminUser = TestDataHelper.createSystemAdminUser(true);
//     //     System.runAs(newAdminUser) {
//     //         SyncpIntCustSett.add(new SyncplicityIntegration__c(name = 'Syncplicity',
//     //                                                            Endpoint__c = 'https://api.syncplicity.com',
//     //                                                            Password__c = 'cd18cf8f-117f-4f66-acde-d6f1b3291566',
//     //                                                            SyncAppToken__c = 'FBLti9Bu2UEv8M1JBeJdVE2r55sEs0brphBlOrd9Xt2c32dVxDxZQvKpRbYu32Jq',
//     //                                                            UserName__c = 'c1d198e2-b351-4910-8a84-d84dfaee688a',
//     //                                                            APIBatchsize__c = 1,
//     //                                                            RootFolderSyncpointId__c = '11081799'));
//     //         System.debug('@@@@' + SyncpIntCustSett);
//     //         insert SyncpIntCustSett;
    
//     //         //Create main account
//     //         Account parentAcc = TestDataHelper.createAdvertiser('Advertiser Account', '123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');
//     //         insert parentAcc;
//     //         System.assert(parentAcc != null);
    
//     //         //Create Opportunity:   
//     //         Opportunity opp = TestDataHelper.createopportunity('Test Opportunity', System.today(), 'Planning', 'Pipeline', parentAcc.id);
//     //         oppList.add(opp);            
//     //         insert oppList;
    
//     //         //Create CNA:        
//     //         CNA__c cna = TestDataHelper.createCNR(parentAcc.id);
//     //         cnaList.add(cna);
//     //         insert cnaList;
    
//     //         //Create Account Request
//     //         /*Account_Request__c accReq = new Account_Request__c();
//     //         accReq.Advertiser_Agency_Rep_Firm__c = parentAcc.id;
//     //         insert accReq;*/
    
//     //         //Create child account
//     //         Account childAcc = TestDataHelper.createAdvertiser('Advertiser Account_child', '123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');
//     //         insert childAcc;
//     //         parentAcc.MergeAccount__c = childAcc.id;
//     //         update parentAcc;
    
//     //         System.debug('2_parentAcc:' + parentAcc);
//     //         System.debug('2_childAcc:' + childAcc);
//     //         System.assert(childAcc != null);
    
//     //         //Creating synctable data
//     //         Syncplicity__SyncTable__c syn = new Syncplicity__SyncTable__c();
//     //         syn.Syncplicity__syncpFilesFolderId__c = '123567';
//     //         syn.Syncplicity__syncpEmailId__c = 'Test@test.com';
//     //         syn.Syncplicity__uniqueId__c = 'Test12334';
//     //         syn.Syncplicity__syncpRecordFolderId__c = '382343761';
//     //         syn.Syncplicity__isAdmin__c = 'True';
//     //         syn.Syncplicity__salesforceRecordId__c = parentAcc.Id;
//     //         syn.Syncplicity__salesforceUserId__c = newAdminUser.Id;
//     //         insert syn;
//     //         System.assert(syn != null);
    
//     //         Syncplicity__SyncTable__c syn1 = new Syncplicity__SyncTable__c();
//     //         syn1.Syncplicity__syncpFilesFolderId__c = '1235678';
//     //         syn1.Syncplicity__syncpEmailId__c = 'Test@test.com';
//     //         syn1.Syncplicity__uniqueId__c = 'Test123345';
//     //         syn1.Syncplicity__syncpRecordFolderId__c = '382419311';
//     //         syn1.Syncplicity__isAdmin__c = 'True';
//     //         syn1.Syncplicity__salesforceRecordId__c = childAcc.Id;
//     //         syn1.Syncplicity__salesforceUserId__c = newAdminUser.Id;
//     //         System.debug('@@@@' + syn1);
//     //         insert syn1;
//     //         System.assert(syn1 != null);
    
//     //         AccountMergeBatch objAccountMergeBatch = new AccountMergeBatch();
//     //         objAccountMergeBatch.acc = parentAcc;
    
//     //         Test.startTest();
//     //         Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock> ();
//     //         SyncplicityWebServiceMock methodName1 = new SyncplicityWebServiceMock('Authentication');
//     //         endpoint2TestResp.put('https://api.syncplicity.com/oauth/token', methodName1);
//     //         SyncplicityWebServiceMock methodName2 = new SyncplicityWebServiceMock('GetFolderContentWOFile');
//     //         endpoint2TestResp.put('https://api.syncplicity.com/sync/folder.svc/11081799/folder/382343761?include=active', methodName2);
//     //         SyncplicityWebServiceMock methodName3 = new SyncplicityWebServiceMock('GetSourceFolderContentFile');
//     //         endpoint2TestResp.put('https://api.syncplicity.com/sync/folder.svc/11081799/folder/382419311?include=active', methodName3);
//     //         SyncplicityWebServiceMock methodName4 = new SyncplicityWebServiceMock('GetFolderContentWOFile');
//     //         endpoint2TestResp.put('https://api.syncplicity.com/sync/folder.svc/11081799/folder/382592384?include=active', methodName4);
//     //         SyncplicityWebServiceMock methodName5 = new SyncplicityWebServiceMock('MoveFoldersWithFiles');
//     //         endpoint2TestResp.put('https://api.syncplicity.com/sync/folders.svc/11081799/folders', methodName5);
//     //         SyncplicityWebServiceMock methodName6 = new SyncplicityWebServiceMock('GetFolderContentWOFile');
//     //         endpoint2TestResp.put('https://api.syncplicity.com/sync/folder.svc/11081799/folder/382789622?include=active', methodName6);
//     //         SyncplicityWebServiceMock methodName7 = new SyncplicityWebServiceMock('GetFolderContentWOFile');
//     //         endpoint2TestResp.put('https://api.syncplicity.com/sync/folder.svc/11081799/folder/383027115?include=active', methodName7);
//     //         SyncplicityWebServiceMock methodName8 = new SyncplicityWebServiceMock('GetFolderContentWOFile');
//     //         endpoint2TestResp.put('https://api.syncplicity.com/sync/folder.svc/11081799/folder/383093332?include=active', methodName8);
//     //         SyncplicityWebServiceMock methodName9 = new SyncplicityWebServiceMock('MoveFiles');
//     //         endpoint2TestResp.put('https://api.syncplicity.com/sync/files.svc/11081799/files', methodName9);
    
//     //         HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
//     //         Test.setMock(HttpCalloutMock.class, multiCalloutMock);
    
//     //         objAccountMergeBatch.MergeSyncpFolders();
    
//     //         Test.stopTest();
//     //     }
//     // }
//     // 
//      @isTest
//     static void testGetAccountList() {
//         Test.startTest();
    
//         Account acc = new Account(Name = 'Test Account');
//         insert acc;

//         Account result = AccountMergeUpdate.getAccountList(acc.Id);
        
//         Test.stopTest();
//     }
    
//      @isTest
//     static void testGetFieldSetLabels() {
//         Test.startTest();
//         Map<String, String> labels = AccountMergeUpdate.getFieldSetLabels();
      
//         Test.stopTest();
//     }
    

//     @isTest
//     static void testGetbatch() {
//         // Create test data
//          Account acc = new Account(Name = 'Test Account');
//         insert acc;
//         Account_Merge_Log__c mergeLog = new Account_Merge_Log__c(Account__c =acc.Id);
//         insert mergeLog;

//         Test.startTest();
//         String result = AccountMergeUpdate.getbatch(mergeLog.Id);
//         Test.stopTest();

//     }


//     @isTest
//     static void testToSendEmail() {
//         // Create Account_Merge_Log__c record
//         Account testAccount = new Account(Name = 'Test Account');
//         insert testAccount;

//         Account_Merge_Log__c mergeLog = new Account_Merge_Log__c(Account__c = testAccount.Id);
//         insert mergeLog;

//         // Create related Account_Merge_Detail__c records
//         Account_Merge_Detail__c mergeDetail1 = new Account_Merge_Detail__c(
//             Account_Merge_Log__c = mergeLog.Id,
//            // Name = 'Merge Detail 1',
//             Error__c = 'Error 1',
//             Is_Error__c = true,
//             Object_Name__c = 'Opportunity',
//             Record_ID__c = 'Test Record ID 1'
//         );
//         insert mergeDetail1;

//         Account_Merge_Detail__c mergeDetail2 = new Account_Merge_Detail__c(
//             Account_Merge_Log__c = mergeLog.Id,
//            // Name = 'Merge Detail 2',
//             Error__c = 'Error 2',
//             Is_Error__c = true,
//             Object_Name__c = 'Trade__c',
//             Record_ID__c = 'Test Record ID 2'
//         );
//         insert mergeDetail2;

//         // Set up email sending mock
//         Test.startTest();
//         List<String> result = AccountMergeUpdate.toSendEmail(mergeLog.Id);
//         Test.stopTest();
// }

//    @isTest
//     static void testGetRelatedRecordList() {
//         Account parentAcc = new Account(Name='Parent Account');
//         insert parentAcc;
        
//         Account childAcc = new Account(Name='Child Account');
//         insert childAcc;
        
        
        
//          List<Account_Merge_Log__c> accountMergeLogs = new List<Account_Merge_Log__c> ();
//             Account_Merge_Log__c objLog = new Account_Merge_Log__c();
//             objLog.Account__c = parentAcc.Id;
//             objLog.Merged_Account_ID__c = childAcc.Id;
//             System.debug('objLog ' + objLog);
//             accountMergeLogs.add(objLog);
//             insert accountMergeLogs;
        
//         Test.startTest();
//          AccountMergeUpdate aMU= new AccountMergeUpdate(accountMergeLogs);
//         Test.stopTest();
//     }
    
//     @isTest
//     static void testRealtedObject(){
//         Account acc=new Account(Name='Test Account');
//         insert acc;
        
//       /* User u = TestDataHelper.getBoomiIntegrationUser();
//         User newUser = TestDataHelper.createUser(true);
//         User inactiveUser = TestDataHelper.createUser(false);
//         inactiveUser.username = 'abcd@abcdtestmns.charter.com';
//         inactiveUser.email = 'abcd@abcdtestmns.charter.com';
//         insert inactiveUser;
//         User newAdminUser = TestDataHelper.createSystemAdminUser(true);*/
//          List<Opportunity> oppList = new List<Opportunity> ();
//          Opportunity opp = TestDataHelper.createopportunity('Test Opportunity', System.today(), 'Planning', 'Pipeline', acc.id);
//             oppList.add(opp);
//             Opportunity childopp = TestDataHelper.createopportunity('Test Opportunity_child', System.today(), 'Planning', 'Pipeline', acc.id);
//             oppList.add(childopp);
//             Opportunity inactiveopp = TestDataHelper.createopportunity('Test Opportunity_child', System.today(), 'Planning', 'Pipeline', acc.id);
//             oppList.add(inactiveopp);
//             insert oppList;
            
        
        
//             Test.startTest();
//         Map<String, Integer> relatedObjectsCount = AccountMergeUpdate.relatedObject(acc.Id);
//         Test.StopTest();
//         //checking result
//         Integer objectCount=relatedObjectsCount.get('total_Opportunity');
//         System.assertEquals(3,objectCount);
        
        
//     }
// }

@isTest
public class AccountMergeUpdateTest {
    
    
    @isTest static void testMergeAccounts() {
        // Create test data
        Account parentAccount = new Account(Name = 'Parent Account');
        insert parentAccount;
        
        Account childAccount = new Account(Name = 'Child Account');
        insert childAccount;
        
        Account_Merge_Log__c mergeLog = new Account_Merge_Log__c(Account__c = parentAccount.Id, Merged_Account_ID__c = childAccount.Id);
        insert mergeLog;
        
        Test.startTest();
        AccountMergeUpdate.mergeAccounts(mergeLog.Id, parentAccount.Id, childAccount.Id, 'Merging');
        Test.stopTest();
        
        // Verify
        System.assertEquals(1, [SELECT COUNT() FROM Account WHERE Name = 'Parent Account']);
    }
    
    @isTest static void testGetAccountDataMethod() {
        // Create test data
        Account parentAccount = new Account(Name = 'Parent Account');
        insert parentAccount;

        
        Test.startTest();
        List < Account > accList = AccountMergeUpdate.getAccountDataMethod(parentAccount.Id);
        Test.stopTest();
        
        // Verify
        System.assertEquals(1, accList.size());
    }
    
    @isTest static void testDeleteAccount() {
        // Create test data
        Account parentAccount = new Account(Name = 'Parent Account');
        insert parentAccount;

        
        Test.startTest();
        AccountMergeUpdate.deleteAccount(parentAccount);
        Test.stopTest();
        
        // Verify
        System.assertEquals(0, [SELECT COUNT() FROM Account WHERE Name = 'Parent Account']);
    }
    
     @isTest static void testUpdateAccount() {
        // Create test data
        Account parentAccount = new Account(Name = 'Parent Account');
        insert parentAccount;

        
        Test.startTest();
        Account acc = AccountMergeUpdate.updateAccount(parentAccount);
        Test.stopTest();
    }
    
    @isTest
    static void testCallAccountMergeDetailInsertionBatch() {
        // Create test data for parent and child accounts
        Account parentAccount = new Account(Name = 'Parent Account 1 2 3');
        Account childAccount = new Account(Name = 'Child Account', BillingStreet = '123 Main St', BillingCity = 'Anytown', BillingState = 'CA', BillingCountry = 'USA', BillingPostalCode = '12345', DunsNumber__c = '123456789', Billing_Preference__c = 'Detail');
        
        insert parentAccount;
        insert childAccount;

        // Create Account Merge Log record
        Account_Merge_Log__c mergeLog = new Account_Merge_Log__c(Account__c = parentAccount.Id, Merged_Account_ID__c = childAccount.Id, Child_Account__c = childAccount.Name);
        insert mergeLog;

        Test.startTest();
        // Call the method
        AccountMergeUpdate.callAccountMergeDetailInsertionBatch(childAccount.Id, parentAccount.Id);
        Test.stopTest();

        // Verify that the Account_Merge_Log__c record was created
        List<Account_Merge_Log__c> mergeLogs = [SELECT Id, Account__c, Merged_Account_ID__c, Child_Account__c, Account_Log__c FROM Account_Merge_Log__c WHERE Account__c = :parentAccount.Id];
        Account_Merge_Log__c createdLog = mergeLogs[0];

        // Verify that the batch job was enqueued
        List<AsyncApexJob> jobs = [SELECT Id, JobType, Status FROM AsyncApexJob WHERE JobType = 'BatchApex' AND Status = 'Holding'];
    }
    
    @isTest
    static void testVerifySelectedAcc() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Create related Account_Transfer_Mapping__c records
        Account_Transfer_Tool__c transferSimulation = new Account_Transfer_Tool__c(Status__c = 'Completed');
        insert transferSimulation;
        
        Account_Transfer_Mapping__c transferMapping = new Account_Transfer_Mapping__c(
            Account__c = testAccount.Id,
            Account_Transfer_Simulation__c = transferSimulation.Id
            
        );
        insert transferMapping;
        
        // Test case: Account with Account_Transfer_Mapping__c records
        Test.startTest();
        Map<String, String> result = AccountMergeUpdate.verifySelectedAcc(testAccount.Id);
        Test.stopTest();
        
    }
    
       @isTest
    	static void testFindRecords() {
        // Create test data
        Account testAccount1 = new Account(Name = 'Test Account 1', RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Agency Account' LIMIT 1].Id);
  
        insert new List<Account>{testAccount1};

        // Call the method with various inputs
        Test.startTest();
        List<SObject> result1 = AccountMergeUpdate.findRecords('Test', 'Account', 'Name', testAccount1.Id, 'Agency Account');
        List<SObject> result2 = AccountMergeUpdate.findRecords('001', 'Account', 'Name', testAccount1.Id, 'In House Agency Account');
        List<SObject> result3 = AccountMergeUpdate.findRecords('NonExistingKey', 'Account', 'Name', testAccount1.Id, 'Agency Account');
        Test.stopTest();

    }
    
    @isTest static void testRelatedObject() {
        // Create test data
        Account parentAccount = new Account(Name = 'Parent Account');
        insert parentAccount;

        
        Test.startTest();
        Map<String, Integer> accRecord = AccountMergeUpdate.relatedObject(parentAccount.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetAccountMDetailRecord() {
        // Create test data
        Account parentAccount = new Account(Name = 'Parent Account');
        Account childAccount = new Account(Name = 'Child Account');
        insert new List<Account>{parentAccount, childAccount};
        
        Account_Merge_Log__c mergeLog = new Account_Merge_Log__c(Account__c = parentAccount.Id, Merged_Account_ID__c = childAccount.Id);
        insert mergeLog;
        
        Account_Merge_Log__c mergeLog2 = new Account_Merge_Log__c(Account__c = parentAccount.Id, Merged_Account_ID__c = childAccount.Id);
        insert mergeLog2;
		
        Opportunity o = new Opportunity(AccountId = parentAccount.Id,Name ='o', StageName='o', CloseDate=Date.today());
        insert o;
        Task t = new Task(WhatId = parentAccount.Id);
        insert t;
        Account_Merge_Detail__c mergeDetail1 = new Account_Merge_Detail__c(
            Account_Merge_Log__c = mergeLog.Id,
            Object_Name__c = 'Opportunity',
            Field_to_Update__c = 'AccountId',
            Record_ID__c = o.Id
            
        );
        insert mergeDetail1;
        
        Account_Merge_Detail__c mergeDetail2 = new Account_Merge_Detail__c(
            Account_Merge_Log__c = mergeLog.Id,
            Object_Name__c = 'Task',
            Field_to_Update__c = 'AccountId',
            Record_ID__c = t.Id
            
        );
        insert mergeDetail2;

        // Call the method
        Test.startTest();
        List<Account_Merge_Detail__c> result = AccountMergeUpdate.getAccountMDetailRecord(mergeLog.Id);
        String s2 = AccountMergeUpdate.unmergeAccountMergeLog(mergeLog2.Id);
        Database.merge(parentAccount,childAccount);
        String y = AccountMergeUpdate.checkUnmergeBatch(mergeLog.Id);
        String s = AccountMergeUpdate.unmergeAccountMergeLog(mergeLog.Id);
        String z = AccountMergeUpdate.checkUnmergeBatch(mergeLog.Id);
        Test.stopTest();

    }
    

    
    
}