@isTest
private class UserSynchronizationToTIMTest {
    static testMethod void syncToTIM() {
    	TestDataHelper.createTIMIntegrationCustomSettings();
        //User u = [select Id, Name from User where Name = 'Boomi Integration User'];
        User u = TestDataHelper.getBoomiIntegrationUser();

        System.runAs(u){

            UserConnection__c connection = TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');   
            insert connection;

            System.assert(connection != null);

            List<UserConnection__c> userConnection =[Select User__c,AE_Id__c, TIM_System__c, Username__c
                                                    FROM UserConnection__c
                                                    WHERE ID=:connection.Id];

            ApexPages.StandardController sc = new ApexPages.StandardController(u);
            
            UserSynchronizationToTIM userSyncController = new UserSynchronizationToTIM(sc);
            
            
            Test.StartTest();
            BoomiWebServiceMock.name = 'UserSynchronizationToTIMTest';
            Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
            Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
            userSyncController.timListAE();
            Test.StopTest();

            userSyncController.userInput = 'Test';
            userSyncController.searchList();
            userSyncController.close();
            
            userSyncController.selectedAEID = '1';
            userSyncController.doNothing();

        }
        UserSynchronizationToTIM.syncUser('2','St. Louis Local',UserInfo.getUserId());
    }

    static testMethod void negativeTest(){
        TestDataHelper.createTIMIntegrationCustomSettings();
        //User u = [select Id, Name from User where Name = 'Boomi Integration User'];
        User u = TestDataHelper.getBoomiIntegrationUser();

        ApexPages.StandardController sc = new ApexPages.StandardController(u);

        System.assert(ApexPages.getMessages().size() == 0);
            
        UserSynchronizationToTIM userSyncController = new UserSynchronizationToTIM(sc);
    }

}