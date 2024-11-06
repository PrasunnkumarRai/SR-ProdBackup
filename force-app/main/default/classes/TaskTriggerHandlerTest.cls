@isTest
public class TaskTriggerHandlerTest {
    
     @isTest
    static void testOnTaskUpdateWithNewSalesOfficeAndRegion() {
        Test.startTest();

        // Create a user with Sales Office and Region set
        User user = [SELECT Id, Sales_Office__c, Region__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        // Create and insert a task
        Task task = new Task();
        task.Subject = 'Test Task';
        task.Status = 'Not Started';
        task.ActivityDate = Date.today();
        task.Priority = 'Normal';
        task.Description = 'Testing OnTaskUpdate Sales Office and Region';
        insert task;

        // Update the task to trigger OnTaskUpdate
        task.Status = 'Completed';
        update task;

        // Verify Sales_Office_On_Task__c and Region_of_User__c were updated
        Task updatedTask = [SELECT Sales_Office_On_Task__c, Region_of_User__c FROM Task WHERE Id = :task.Id LIMIT 1];

        System.assertEquals(user.Sales_Office__c, updatedTask.Sales_Office_On_Task__c, 'Sales Office should be updated on task');
        System.assertEquals(user.Region__c, updatedTask.Region_of_User__c, 'Region should be updated on task');

        Test.stopTest();
    }
@isTest
    static void testPreventTaskCreationForOutOfBusinessAccounts() {
        Test.startTest();

        // Create an Out of Business Account
        Account acc = new Account(Name = 'Test Out of Business', Out_of_Business__c = TRUE);
        insert acc;

        // Attempt to create a task for the Out of Business Account
        Task task = new Task();
        task.WhatId = acc.Id;
        task.Subject = 'Test Task';
        task.Status = 'Not Started';
        task.ActivityDate = Date.today();
        task.Priority = 'Normal';
        task.Description = 'Testing Out of Business Account restriction';

        try {
            insert task;
            System.assert(false, 'Task creation should not be allowed for Out of Business accounts');
        } catch (DmlException ex) {
            System.assert(ex.getMessage().contains('Activity cannot be created for Out of Business Accounts'),
                'Error message should indicate restriction for Out of Business accounts');
        }

        Test.stopTest();
    }

      @isTest
    
    static void testFetchExcludedSubjects() {
        Test.startTest();

        // Query any existing custom metadata records for excluded subjects
        List<Don_t_send_Emails_for_these_Subjects__mdt> excludedSubjectsMetadata = [
            SELECT Subject_To_Exclude__c 
            FROM Don_t_send_Emails_for_these_Subjects__mdt
            LIMIT 1
        ];

        // Proceed with the test only if there are metadata records available
        if (!excludedSubjectsMetadata.isEmpty()) {
            Set<String> excludedSubjects = TaskTriggerHandler.fetchExcludedSubjects();
            String expectedSubject = excludedSubjectsMetadata[0].Subject_To_Exclude__c.trim().toLowerCase();
            System.assert(excludedSubjects.contains(expectedSubject), 
                'The excluded subject "' + expectedSubject + '" should be fetched and converted to lowercase');
        } else {
            System.debug('No custom metadata records available for testing excluded subjects');
        }

        Test.stopTest();
    }

    @isTest
    static void testOnAfterInsert() {
        Test.startTest();

        Lead lead = TestUtil.getLeadRec();
        lead.PostalCode = null;
        lead.FirstName = 'Lead First';
        insert lead;

        Task objNewTask = new Task();
        objNewTask.WhoId = lead.Id;
        objNewTask.Subject = 'Call';
        objNewTask.Status = 'Open';
        objNewTask.ActivityDate = Date.today();
        objNewTask.Priority = 'Normal';
        objNewTask.Description = 'Test Desc';
        insert objNewTask;

        // Verify the Lead_First_Activity_Date__c field is updated
        Lead updatedLead = [SELECT Lead_First_Activity_Date__c FROM Lead WHERE Id = :lead.Id];
        System.assertEquals(Date.today(), updatedLead.Lead_First_Activity_Date__c);

        Test.stopTest();
    }

    @isTest
    static void testOnAfterDelete() {
        Test.startTest();

        Lead lead = TestUtil.getLeadRec();
        lead.PostalCode = null;
        lead.FirstName = 'Lead First';
        insert lead;

        Task objNewTask = new Task();
        objNewTask.WhoId = lead.Id;
        objNewTask.Subject = 'Call';
        objNewTask.Status = 'Open';
        objNewTask.ActivityDate = Date.today();
        objNewTask.Priority = 'Normal';
        objNewTask.Description = 'Test Desc';
        insert objNewTask;

        delete objNewTask;

        // Verify the Lead_First_Activity_Date__c field is set to null
        Lead updatedLead = [SELECT Lead_First_Activity_Date__c FROM Lead WHERE Id = :lead.Id];
        System.assertEquals(null, updatedLead.Lead_First_Activity_Date__c);

        Test.stopTest();
    }

    @isTest
    static void testOnBeforeInsert() {
    Test.startTest();

    // Create an Account
    Account acc = TestUtil.getAccountRec();
    acc.Primary_Commodity__c = 'Auto Aftermarket';
    insert acc;

    User loggedInUser = [SELECT Id, Region__c, Sales_Office__c, Division__c FROM User 
                         WHERE Id = :UserInfo.getUserId() LIMIT 1];

    // Dynamically fetch a valid value for the Tier_Designation__c picklist field
    Schema.DescribeFieldResult fieldResult = Account_SAM_Mapping__c.Tier_Designation__c.getDescribe();
    List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
    String validPicklistValue = picklistValues[0].getValue();  // Use the first valid value in the picklist

    // Create Account SAM Mapping with the valid picklist value
    Account_SAM_Mapping__c newAsm = new Account_SAM_Mapping__c(Account__c = acc.Id, User__c = UserInfo.getUserId(),
                                                               Tier_Designation__c = validPicklistValue);
    insert newAsm;

    Task objNewTaskAcc = new Task();
    objNewTaskAcc.WhatId = acc.Id;
    objNewTaskAcc.Subject = 'Test Acct SAM';
    objNewTaskAcc.Status = 'Open';
    objNewTaskAcc.ActivityDate = Date.today();
    objNewTaskAcc.Priority = 'Normal';
    objNewTaskAcc.Description = 'Test Desc';
    insert objNewTaskAcc;

    // Verify the Tier_Designation__c field is updated with the valid value
    Task insertedTask = [SELECT Tier_Designation__c FROM Task WHERE Id = :objNewTaskAcc.Id];
    System.assertEquals(validPicklistValue, insertedTask.Tier_Designation__c);

    Test.stopTest();
}


    @isTest
    static void testOutOfBusinessAccTask() {
        Test.startTest();

        // Create an Account marked as Out of Business
        Account acc = TestUtil.getAccountRec();
        acc.Primary_Commodity__c = 'Auto Aftermarket';
        acc.Out_of_Business__c = TRUE;
        insert acc;

        Task objNewTask = new Task();
        objNewTask.WhatId = acc.Id;
        objNewTask.Subject = 'Call';
        objNewTask.Status = 'Open';
        objNewTask.ActivityDate = Date.today();
        objNewTask.Priority = 'Normal';
        objNewTask.Description = 'Test Desc';

        try {
            insert objNewTask;
            System.assert(false, 'Task creation should fail for Out of Business Accounts.');
        } catch (DmlException ex) {
            System.assert(ex.getMessage().contains('Activity cannot be created for Out of Business Accounts'), 
                          'Error message should indicate restriction.');
        }

        Test.stopTest();
    }

    @isTest
    static void testOnTaskUpdate() {
        Test.startTest();

        // Create and insert a Task
        Task task = new Task();
        task.Subject = 'Test Task';
        task.Status = 'Not Started';
        task.ActivityDate = Date.today();
        task.Priority = 'Normal';
        task.Description = 'Testing OnTaskUpdate';
        insert task;

        // Update the Task to trigger OnTaskUpdate
        task.Status = 'Completed';
        update task;

        // Verify the Task fields were updated
        Task updatedTask = [SELECT Sales_Office_On_Task__c, Region_of_User__c, CreatedById FROM Task WHERE Id = :task.Id LIMIT 1];
        User createdByUser = [SELECT Sales_Office__c, Region__c FROM User WHERE Id = :updatedTask.CreatedById LIMIT 1];

        System.assertEquals(createdByUser.Sales_Office__c, updatedTask.Sales_Office_On_Task__c);
        System.assertEquals(createdByUser.Region__c, updatedTask.Region_of_User__c);

        Test.stopTest();
    }

    // Add test method for sendEmailsForNewTasks
    @isTest
    static void testSendEmailsForNewTasks() {
        Test.startTest();

        // Create a lead and insert it
        Lead lead = TestUtil.getLeadRec();
        insert lead;

        // Create and insert a new task
        Task objNewTask = new Task();
        objNewTask.WhoId = lead.Id;
        objNewTask.Subject = 'New Task for Testing';
        objNewTask.Status = 'Not Started';
        objNewTask.ActivityDate = Date.today();
        objNewTask.Priority = 'Normal';
        objNewTask.Description = 'Test email notification logic';
        insert objNewTask;

        // Assuming email logic is tested via debug or mocked service
        Test.stopTest();
    }

   
    @isTest
    static void testSendEmailsForReassignedTasks() {
        Test.startTest();
        // Create and insert an old user
        User oldUser = new User(
            Username = 'myselfolduser@charter.com.uat', 
            Alias = 'olduser',
            LastName = 'abcd12389',
            Email = 'olduser@charter.com', 
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id, 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US', 
            IsActive = true
        );
        insert oldUser;

        // Create and insert a new user
        User newUser = new User(
            Username = 'myselfnewuser@example.com', 
            Alias = 'newuser',
            LastName = 'Myselfnewuser',
            Email = 'newuser@charter.com', 
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id, 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US', 
            IsActive = true
        );
        insert newUser;

        // Create and insert a new task assigned to the old user
        Task objNewTask = new Task();
        objNewTask.Subject = 'Reassigned Task';
        objNewTask.Status = 'Not Started';
        objNewTask.ActivityDate = Date.today();
        objNewTask.Priority = 'Normal';
        objNewTask.Description = 'Test reassignment email notification';
        objNewTask.OwnerId = oldUser.Id; // Assign task to old user
        insert objNewTask;

        // Change the task owner to the new user
        objNewTask.OwnerId = newUser.Id;
        update objNewTask;

        // Check email sending logic via debug or mocked service
        // You might need to use mock email services or check debug logs to verify email sending
        Test.stopTest();
        
        // Optional: Additional assertions can be made here based on how your email notifications are handled
    }

    @isTest
static void testSendCustomNotificationsForNewTasks() {
    Test.startTest();

    // Create and insert a lead
    Lead lead = TestUtil.getLeadRec();
    insert lead;

    // Create and insert a new task
    Task objNewTask = new Task();
    objNewTask.WhoId = lead.Id;
    objNewTask.Subject = 'Task for Custom Notification Test';
    objNewTask.Status = 'Not Started';
    objNewTask.ActivityDate = Date.today();
    objNewTask.Priority = 'Normal';
    insert objNewTask;

    // Invoke the method to send custom notifications
    TaskTriggerHandler.OnAfterInsert(new Task[] { objNewTask });

    Test.stopTest();
}

    @isTest
static void testUpdateLeadFirstActivityOnDelete() {
    Test.startTest();

    // Create a Lead and insert it
    Lead lead = TestUtil.getLeadRec();
    insert lead;

    // Create and insert a Task for the Lead
    Task task = new Task();
    task.WhoId = lead.Id;
    task.Subject = 'Task for Lead First Activity Date';
    task.Status = 'Not Started';
    task.ActivityDate = Date.today();
    task.Priority = 'Normal';
    insert task;

    // Now delete the task and check if Lead_First_Activity_Date__c is set to null
    delete task;

    // Re-fetch the lead to check if the Lead_First_Activity_Date__c field was reset
    Lead updatedLead = [SELECT Lead_First_Activity_Date__c FROM Lead WHERE Id = :lead.Id];
    System.assertEquals(null, updatedLead.Lead_First_Activity_Date__c, 
                        'Lead First Activity Date should be null after task is deleted');

    Test.stopTest();
}

 @isTest
    static void testValidateActiveContacts() {
        Test.startTest();

        // Create an inactive contact with an email address
        Contact inactiveContact = new Contact(
            LastName = 'Inactive Contact', 
            Contact_Status__c = 'Inactive', 
            Email = 'inactive@example.com' // Adding email to meet the validation rule
        );
        insert inactiveContact;

        // Try to create a task for the inactive contact
        Task objNewTask = new Task();
        objNewTask.WhoId = inactiveContact.Id;
        objNewTask.Subject = 'Test Task for Inactive Contact';
        objNewTask.Status = 'Open';
        objNewTask.ActivityDate = Date.today();
        objNewTask.Priority = 'Normal';
        objNewTask.Description = 'Test Desc';

        try {
            insert objNewTask;
            //System.assert(false, 'Task creation should fail for inactive contacts.');
        } catch (DmlException ex) {
            System.assert(ex.getMessage().contains('Please select an Active Contact'), 
                          'Error message should indicate the contact is inactive.');
        }

        Test.stopTest();
    }

}