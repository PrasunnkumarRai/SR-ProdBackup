@isTest
private class UserConnectionTriggerHelperTest {
    static testMethod void triggerHelper() {

    	User u = TestDataHelper.getBoomiIntegrationUser();
        System.runAs(u){

            UserConnection__c connection = TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');   
            insert connection;

            System.assert(connection != null);


            List<UserConnection__c> userConnection =[Select User__c,AE_Id__c, TIM_System__c, Username__c
                                                    FROM UserConnection__c
                                                    WHERE ID=:connection.Id];

            UserConnectionTriggerHelper helper = new UserConnectionTriggerHelper();
            helper.getUserConnection(userConnection);

            userConnection[0].AE_Id__c = '';
            update userConnection;
            
            helper = new UserConnectionTriggerHelper();
            helper.getUserConnection(userConnection);
        }
    }
}