@isTest
public class TaskPageControllerTest {

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
        
        
        Contact c = new Contact();
        c.LastName = 'unit Test contact';
       // c.isActive__c = true;
        c.email = 'test@gmail.com';
        insert c;
        
        Lead l = new Lead();
        l.lastname = 'Test Lead';
        l.Primary_Advertising_Region_Text__c = 'testing';
        l.Company = 'Test Company';
        insert l;
	}	
    
    @isTest
    public static void findRecordsTest(){
        taskPageController.findRecords('unit','Contact');
    }
    
    @isTest
    public static void findRecordsTest2(){
        taskPageController.findRecords('test','Lead');
    }
    
    @isTest
    public static void taskCreationTest(){
        User u = [Select id from User Where name = 'Prasunn Rai' Limit 1 ];
        Contact c = [Select id from Contact LImit 1];
        
        Account a = new Account();
        a.name = 'test';
        insert a ; 		
       taskPageController.taskCreation('Test Subject','2025-07-03',String.valueOf(u.Id),'Cold Call/Introductory Meeting',String.valueOf(a.Id),String.valueOf(c.Id),'Test Comment',true,null,'High','Open');
    }
    
    
    @isTest
    public static void pickListValueDynamicallyTest(){    
        Account a = new Account();
        taskPageController.pickListValueDynamically(a, 'Commodity_Codes__c');    
    }
    
}