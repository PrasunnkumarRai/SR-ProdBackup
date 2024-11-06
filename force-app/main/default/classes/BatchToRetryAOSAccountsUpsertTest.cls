@isTest
private class BatchToRetryAOSAccountsUpsertTest 
{
    @testSetup
    static void prepareTestData()  
    {
        AccountTriggerHandler.isFirstTime = false; 

        List<Account> accountList = new List<Account>();
        Account advAcc = TestDataHelper.createAdvertiser('Test Advertiser', 'KPHB', 'Hyderabad', 'Telangana', '500090', 'India');                        
        INSERT advAcc;  

        advAcc.Credit_Status__c = 'Pending';
        advAcc.AOS_Account_Id__c='65bd9304929d4881212f1';
        UPDATE advAcc;
    }

    static testMethod void RetryAOSAccountsUpsertTest() 
    {
        List<Account> acctList = new List<Account>();
        Test.setMock(HttpCalloutMock.class, new AOSWebServiceMock(200));

        Test.startTest();

        Account advAcc = [SELECT Id, Name, AOS_Account_Id__c FROM Account WHERE Name = 'Test Advertiser' LIMIT 1];        
        advAcc.Name = 'Test Adv Name Updated';
        advAcc.AOS_Bad_Sync__c = true;
        acctList.add(advAcc);

        for(Integer i=0 ;i <10;i++)
        { 
            Account agencyAcc = TestDataHelper.createAgency('Test Agency'+i, 'KPHB', 'Hyderabad', 'Telangana', '500090', 'India');                        
            agencyAcc.Name = 'Test Agency Name Updated'+i;
            agencyAcc.AOS_Account_Id__c='';
            agencyAcc.AOS_Bad_Sync__c = true;   
            acctList.add(agencyAcc);

            Account repFirmAcc = TestDataHelper.createRepFirm('Test RepFirm'+i, 'KPHB', 'Hyderabad', 'Telangana', '500090', 'India');                        
            repFirmAcc.AOS_Account_Id__c='65bd9304929d4881212f3'+i;
            repFirmAcc.AOS_Bad_Sync__c = false;  
            acctList.add(repFirmAcc); 
        }
        UPSERT acctList;

        Assert.areEqual(11, [SELECT COUNT() FROM Account WHERE AOS_Bad_Sync__c = TRUE]);

        BatchToRetryAOSAccountsUpsert acctBatch = new BatchToRetryAOSAccountsUpsert();        
        SchedulableContext sc;
        acctBatch.execute(sc);

        Test.stopTest();
    }
}