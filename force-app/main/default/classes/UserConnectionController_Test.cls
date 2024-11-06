/* 
    Customer/Project:  Spectrum Reach
    Class name:         UserConnectionController_Test
    Author/Date:       Brett Ballantyne    2/22/18
    Release:            4.0
    Purpose:           Test class for the UserConnectionConroller
*/
@isTest
private class UserConnectionController_Test {
	
	@isTest static void test_method_one() {

		Account acc = TestDataHelper.createAcc('TestAcct14', 'TestAccount222', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                                
        insert acc; 

        Traffic_Id_Element__c trafficIdElement = TestDataHelper.createTrafficIdElement(acc.Id,UserInfo.getUserId(), '1', '1111');
        insert trafficIdElement;
        Test.startTest();
        PageReference pageRef = Page.UserConnections;
        Test.setCurrentPage(pageRef);
        System.assertEquals(trafficIdElement.User__c, UserInfo.getUserId());

        ApexPages.StandardController userController = new ApexPages.StandardController([Select Id, Name from User where Id = :UserInfo.getUserId()]);
        UserConnectionController ucc = new UserConnectionController(userController);
        ucc.getCurrentUserId();
        ucc.getFields();
        ucc.getUserConnections();
        ucc.dummyUpdateUser();
        Test.stopTest();
	}

	
}