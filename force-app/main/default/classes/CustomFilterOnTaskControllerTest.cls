@isTest
public class CustomFilterOnTaskControllerTest {
    
    @testSetup static void testData() {
		List<task> taskList = new List<task>{ new task(
                                                Subject='Test Subject',
                                                Status='Open',
                                                Priority='Normal'
                                                )};
        insert taskList; 
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');

	}	
	
    
    @isTest
    public static void getLoggedUserIdTest(){
        customFilterOnTaskController.getLoggedUserId();
        customFilterOnTaskController.nameOftheUser();
    }

    @isTest 
    public static void taskDetailsTest(){
    Account acc= TestUtil.getAccountRec();
    Insert acc;
    Contact con=TestUtil.getContactRec(acc.id,'Test@charter.com');
    Insert con;
      //  string test=UserInfo.getUserId();
	     List<task> taskList = new List<task>{ new task(
                                                Subject='Test Subject',
                                                Status='Open',
                                                Priority='Normal',
                                                Whoid=con.id,
                                                WhatId=acc.id
                                                )};
        insert taskList; 
      customFilterOnTaskController.TaskDetails(acc.id);
	}
    
    @isTest 
    public static void UserDetailTest(){
        customFilterOnTaskController.UserDetail('Test',null,null);
    }
    
    @isTest 
    public static void getTasksByUserIdsTest(){
         Account acc= TestUtil.getAccountRec();
         Insert acc;
         Contact con=TestUtil.getContactRec(acc.id,'Test@charter.com');
         Insert con;
         List<task> taskList = new List<task>{ new task(
                                                Subject='Test Subject',
                                                Status='Open',
                                                Priority='Normal',
                                                Whoid=con.id,
                                                WhatId=acc.id
                                                )};
        insert taskList; 
         
      
       	List<Id> userIdList = new List<Id>();
        userIdList.add(UserInfo.getUserId());
         List<customFilterOnTaskController.TaskWrapper> lst=new List<customFilterOnTaskController.TaskWrapper>();  
        customFilterOnTaskController.TaskWrapper TW=new customFilterOnTaskController.TaskWrapper();
           TW.task =taskList[0]; 

        customFilterOnTaskController.getTasksByUserIds(userIdList,acc.id);
    }
}