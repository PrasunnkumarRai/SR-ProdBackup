public class TaskTriggerHandler {

    // After Insert: Update Lead's First Activity Field if applicable
    public static void OnAfterInsert(Task[] newTasks) {
        Set<String> leadIds = getLeadIdsFromTask(newTasks);
        if (!leadIds.isEmpty()) {
            updateLeadFirstActivity(leadIds, false); // Fixed method signature
        }
        sendEmailsForNewTasks(newTasks);
        sendCustomNotificationsForNewTasks(newTasks, 'insert');
    }

    // After Delete: Update Lead's First Activity Field if applicable
    public static void OnAfterDelete(Task[] oldTasks) {
        Set<String> leadIds = getLeadIdsFromTask(oldTasks);
        if (!leadIds.isEmpty()) {
            updateLeadFirstActivity(leadIds, true); // Fixed method signature
        }
    }


    // Update Lead First Activity Field
    private static void updateLeadFirstActivity(Set<String> leadIds, Boolean isDelete) { // Fixed method signature
        List<Lead> leadsToUpdate = new List<Lead>();
        for (Lead objLead : [
            SELECT Id, Lead_First_Activity_Date__c, 
                   (SELECT Id, CreatedDate FROM Tasks ORDER BY CreatedDate LIMIT 2) 
            FROM Lead 
            WHERE Id IN :leadIds
        ]) {
            if (isDelete || objLead.Tasks.size() == 0) {
                objLead.Lead_First_Activity_Date__c = null;
            } else if (objLead.Tasks.size() == 1) {
                objLead.Lead_First_Activity_Date__c = Date.today();
            } else if (objLead.Lead_First_Activity_Date__c == null && objLead.Tasks.size() > 1) {
                objLead.Lead_First_Activity_Date__c = objLead.Tasks[0].CreatedDate.date();
            }
            leadsToUpdate.add(objLead);
        }
        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }
    }

    // Before Insert: Handle SAM Designation and Validate Active Contacts
    public static void OnBeforeInsert(Task[] newTasks) {
        //Map<Id, String> mapSAMvalues = fetchSAMDesignationValues(newTasks); // SRSF-5237 : Commented
        Map<Id, String> mapTiervalues = fetchTierDesignationValues(newTasks);
        Set<Id> accIds = new Set<Id>();

        for (Task objTask : newTasks) {
            /*
            // SRSF-5237 : Commented to exclude SAM Designation population on Task 
            if (mapSAMvalues.containsKey(objTask.WhatId)) {
                if(System.label.SAMDesignationShutDown == 'FALSE'){
                    objTask.SAM_Designation__c = mapSAMvalues.get(objTask.WhatId);
                }
            }*/
            if(mapTiervalues.containsKey(objTask.WhatId)){
                System.debug('TierDesignation: '+  objTask.Tier_Designation__c);
                objTask.Tier_Designation__c = mapTiervalues.get(objTask.WhatId);
            }

            validateActiveContacts(objTask);
            if (objTask.WhatId != null && String.valueOf(objTask.WhatId.getSObjectType()) == 'Account') {
                accIds.add(objTask.WhatId);
            }
        }

        preventTaskCreationForOutOfBusinessAccounts(accIds, newTasks);
    }

    // Fetch Lead IDs from Task.WhoId
    private static Set<String> getLeadIdsFromTask(Task[] tasks) {
        Set<String> leadIds = new Set<String>();
        for (Task objTask : tasks) {
            String whoId = String.valueOf(objTask.WhoId); // Convert Id to String
            if (whoId != null && whoId.startsWith('00Q')) { // Fixed `startsWith` check
                leadIds.add(whoId);
            }
        }
        return leadIds;
    }

    // Fetch SAM Designation values from Account/Opportunity
    // SRSF-5237 : Commented below method as it is no more required
    /*private static Map<Id, String> fetchSAMDesignationValues(Task[] tasks) {
        Set<Id> accIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id, String> mapSAMvalues = new Map<Id, String>();

        for (Task objTask : tasks) {
            String whatId = String.valueOf(objTask.WhatId); // Convert Id to String
            if (whatId != null && whatId.startsWith('001')) accIds.add(objTask.WhatId); // Fixed `startsWith` check
            if (whatId != null && whatId.startsWith('006')) oppIds.add(objTask.WhatId); // Fixed `startsWith` check
        }

        if (!accIds.isEmpty()) {
            for (Account_SAM_Mapping__c acc : [
                SELECT Account__c, SAM_Designation__c 
                FROM Account_SAM_Mapping__c 
                WHERE User__c = :UserInfo.getUserId() AND Account__c IN :accIds
            ]) {
                if(System.label.SAMDesignationShutDown == 'FALSE'){
                    mapSAMvalues.put(acc.Account__c, acc.SAM_Designation__c);
                }
            }
        }

        if (!oppIds.isEmpty()) {
            for (Opportunity opp : [SELECT Id, SAM_Designation__c FROM Opportunity WHERE Id IN :oppIds]) {
                if(System.label.SAMDesignationShutDown == 'FALSE'){
                    mapSAMvalues.put(opp.Id, opp.SAM_Designation__c);
                }
            }
        }

        return mapSAMvalues;
    }*/

    private static Map<Id, String> fetchTierDesignationValues(Task[] tasks) {
        Set<String> accIds = new Set<String>();
        Set<String> oppIds = new Set<String>();
        Map<Id, String> mapTiervalues = new Map<Id, String>();

        for (Task objTask : tasks) {
            String whatId = objTask.WhatId;
            if (whatId != null && whatId.startsWith('001')) accIds.add(whatId);
            if (whatId != null && whatId.startsWith('006')) oppIds.add(whatId);
        }

        if (!accIds.isEmpty()) {
            for (Account_SAM_Mapping__c acc : [
                SELECT Account__c, Tier_Designation__c 
                FROM Account_SAM_Mapping__c 
                WHERE Account__c IN :accIds
            ]) {
                if(acc.Tier_Designation__c != null){
                    mapTiervalues.put(acc.Account__c, acc.Tier_Designation__c);
                }
            }
        }

        if (!oppIds.isEmpty()) {
            for (Opportunity opp : [
                SELECT Id, Tier_Designation__c
                FROM Opportunity 
                WHERE Id IN :oppIds
            ]) {
                if(opp.Tier_Designation__c != null){
                    mapTiervalues.put(opp.Id, opp.Tier_Designation__c);
                }
            }
        }

        return mapTiervalues;
    }

    // Validate Active Contacts
    private static void validateActiveContacts(Task task) {
        if (task.WhoId != null && String.valueOf(task.WhoId.getSObjectType()) == 'Contact') {
            List<Contact> allActiveContacts = [
                SELECT Id FROM Contact 
                WHERE Id = :task.WhoId 
                AND (Contact_Status__c != 'Active' AND Contact_Status__c != null)
            ];
            if (!allActiveContacts.isEmpty()) {
                task.addError('Please select an Active Contact');
            }
        }
    }

    // Prevent Task creation for Out of Business accounts
    private static void preventTaskCreationForOutOfBusinessAccounts(Set<Id> accIds, Task[] newTasks) {
        if (!accIds.isEmpty()) {
            Map<Id, Account> mapAccs = new Map<Id, Account>(
                [SELECT Id FROM Account WHERE Id IN :accIds AND Out_of_Business__c = TRUE]
            );
            if (!mapAccs.isEmpty()) {
                for (Task objTask : newTasks) {
                    if (mapAccs.containsKey(objTask.WhatId)) {
                        objTask.addError('Activity cannot be created for Out of Business Accounts');
                    }
                }
            }
        }
    }
    public static void OnAfterUpdate(List<Task> newTasks, Map<Id, Task> oldTaskMap) {
        List<Task> tasksForEmail = new List<Task>();
        List<Task> tasksForNotification = new List<Task>();
        List<Task> tasksForCompletionEmail = new List<Task>();
        List<Task> tasksForCompletionNotification = new List<Task>();

        for (Task newTask : newTasks) {
            Task oldTask = oldTaskMap.get(newTask.Id);

            // Check if 'Assigned To' (OwnerId) has changed
            if (newTask.OwnerId != oldTask.OwnerId) {
                tasksForEmail.add(newTask);
                tasksForNotification.add(newTask);
            }

                  // Check if the task status is set to "Completed"
            if (newTask.Status == 'Completed' && oldTask.Status != 'Completed') {
                tasksForCompletionEmail.add(newTask);
                tasksForCompletionNotification.add(newTask); 
            }
        }

        // Handle reassignment email and notification
        if (!tasksForEmail.isEmpty()) {
            sendEmailsForReassignedTasks(tasksForEmail, oldTaskMap);
        }

        if (!tasksForNotification.isEmpty()) {
            sendCustomNotificationsForNewTasks(tasksForNotification, 'update');
        }

        //Handle task completion email
         //if (!tasksForCompletionEmail.isEmpty()) {
           // sendCompletionEmails(tasksForCompletionEmail, oldTaskMap);
        // }
        if (!tasksForCompletionNotification.isEmpty()) { 
            sendTaskCompletionNotifications(tasksForCompletionNotification);
        }
    }

    // Send emails for new tasks (assignment)
    private static void sendEmailsForNewTasks(Task[] newTasks) {
        Set<String> excludedSubjects = fetchExcludedSubjects();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        for (Task t : newTasks) {
            if (!shouldExcludeEmail(t, excludedSubjects, 'insert')) {
                Messaging.SingleEmailMessage mail = createTaskEmail(t, 'Task_Assignment_Notification');
                mails.add(mail);
            }
        }

        if (!mails.isEmpty()) {
            Messaging.sendEmail(mails);
        }
    }

    // Send emails for reassigned tasks
    private static void sendEmailsForReassignedTasks(Task[] newTasks, Map<Id, Task> oldTaskMap) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Set<String> excludedSubjects = fetchExcludedSubjects();

        for (Task t : newTasks) {
            Task oldTask = oldTaskMap != null ? oldTaskMap.get(t.Id) : null;
            Boolean doNotSendEmail = oldTask != null && oldTask.OwnerId == t.OwnerId;

            if (!doNotSendEmail && !shouldExcludeEmail(t, excludedSubjects, 'update')) {
                Messaging.SingleEmailMessage mail = createTaskEmail(t, 'Task_Reassignment_Notification');
                mails.add(mail);
            }
        }

        if (!mails.isEmpty()) {
            Messaging.sendEmail(mails);
        }
    }

     //send emails for completed task only to allowed profiles
     /*private static void sendCompletionEmails(Task[] newTasks, Map<Id, Task> oldTaskMap) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
         Set<String> excludedSubjects = fetchExcludedSubjects();
        
         // Fetch all allowed profiles from the custom metadata
         Set<String> allowedProfiles = new Set<String>();
         for (Send_completed_task_email_to_profiles__mdt profile : [SELECT Profile_Names__c FROM Send_completed_task_email_to_profiles__mdt]) {
             allowedProfiles.add(profile.Profile_Names__c);
         }
        
         for (Task t : newTasks) {
             Task oldTask = oldTaskMap != null ? oldTaskMap.get(t.Id) : null;
            
             // Get the created profile from the custom field
            String createdByProfile = t.CreatedBy_Profile__c;
            
             // Decide whether to skip email based on task status and creation/ownership and allowed profiles
             Boolean doNotSendEmail = t.CreatedById == t.OwnerId || 
                                      (oldTask != null && oldTask.Status == 'Completed') || 
                                   !allowedProfiles.contains(createdByProfile);
    
           // Ensure that the email is only sent if the task is newly completed, not excluded, and the profile is allowed
           if (!doNotSendEmail && t.Status == 'Completed' && !shouldExcludeEmail(t, excludedSubjects, 'update')) {
                
                // Fetch the email template by name (adjust this if needed)
                EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Task_Completed_Email_Notification' LIMIT 1];
                
               if (template != null) {
                  // Create the email and send it to the task creator instead of the owner
                   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(t.CreatedById);  // Send email to the task creator instead of the owner
                mail.setSaveAsActivity(false);           // Do not save as activity
                   mail.setWhatId(t.Id);                    // Set task as the related record
                 mail.setTemplateId(template.Id);         // Set the email template
                     mails.add(mail);
                } 
            }
        }
        
       // Only send the emails if there are valid emails to send
      if (!mails.isEmpty()) {
           System.debug('Sending ' + mails.size() + ' emails.');
            Messaging.sendEmail(mails);
       }
  }*/
    
    
    private static void sendTaskCompletionNotifications(List<Task> completedTasks) {
        CustomNotificationType notificationType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Task_Completed'];
    
        for (Task task : completedTasks) {
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('Task Is Completed');
            notification.setBody(task.Subject + ' - Task is Completed');
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(task.Id);
            notification.send(new Set<String> { task.CreatedById });
        }
    }
    

    // Fetch Excluded Subjects from metadata
    public static Set<String> fetchExcludedSubjects() {
        Set<String> excludedSubjects = new Set<String>();
        for (Don_t_send_Emails_for_these_Subjects__mdt record : [SELECT Subject_To_Exclude__c FROM Don_t_send_Emails_for_these_Subjects__mdt]) {
            excludedSubjects.add(record.Subject_To_Exclude__c.trim().toLowerCase());
        }
        return excludedSubjects;
    }

    // Check if the email should be excluded
    private static Boolean shouldExcludeEmail(Task task, Set<String> excludedSubjects, String method) {
        // List<String> restrictedProfiles = new List<String>(Label.Exclude_profile_From_sending_Task_Email.split(','));
        Id userId = userInfo.getUserId();
        if (method == 'insert' && task.CreatedById == task.OwnerId){
            return true;
        }else if(method == 'update' && userId == task.OwnerId){
            return true;
        }

        if (task.Subject != null) {
            String taskSubject = task.Subject.trim().toLowerCase();
            for (String excludedSubject : excludedSubjects) {
                if (taskSubject.contains(excludedSubject)) return true;
            }
        }
        // if(!restrictedProfiles.isEmpty()){
        //     if (restrictedProfiles.contains(task.CreatedBy_Profile__c)) return true;
        // }

        if (task.OwnerId != null){
            
            // // Check if OwnerId is a group
            List<Group> groupCheck = [SELECT Id FROM Group WHERE Id = :task.OwnerId LIMIT 1];
            if (!groupCheck.isEmpty()) return true; // If task is assigned to a group, exclude the email
        }
        
        return false;
    }

    // Create Task Email
    private static Messaging.SingleEmailMessage createTaskEmail(Task task, String templateName) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(task.OwnerId);
        mail.setSaveAsActivity(false);

        // if (task.WhatId != null && String.valueOf(task.WhatId.getSObjectType()) == 'Account') {
        //     Account relatedAccount = [SELECT Name FROM Account WHERE Id = :task.WhatId LIMIT 1];
        //     mail.setSubject('A new Task for (' + relatedAccount.Name + ') has been assigned to you');
        // } else {
        //     mail.setSubject('A new Task has been assigned to you');
        // }
        mail.setWhatId(task.Id);
        mail.setTemplateId([SELECT Id FROM EmailTemplate WHERE DeveloperName = :templateName].Id);
        return mail;
    }

    // Send custom notifications for new or reassigned tasks
    private static void sendCustomNotificationsForNewTasks(Task[] newTasks, String method) {
        Map<Id, Task> tasksWithDetails = new Map<Id, Task>(
            [SELECT Id, Subject, CreatedBy.Name, LastModifiedBy.Name, OwnerId, CreatedBy_Profile__c FROM Task WHERE Id IN :newTasks]
        );
        sendTaskAssignedNotification(tasksWithDetails, method);
    }

    // Send Task Assignment/Reassignment Notifications
    private static void sendTaskAssignedNotification(Map<Id, Task> tasksWithDetails, String method) {
        Set<String> excludedSubjects = fetchExcludedSubjects();
        // List<String> restrictedProfiles = new List<String>(Label.Exclude_profile_From_sending_Task_Email.split(','));
        CustomNotificationType notificationType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'New_Task_Assigned'];

        for (Task task : tasksWithDetails.values()) {
            if (shouldExcludeEmail(task, excludedSubjects, method)) {
                continue;
            }
            String name = method == 'insert' ? task.CreatedBy.Name : task.LastModifiedBy.Name;
            sendCustomNotification(task, notificationType, name);
        }
    }

    // Send Custom Notification
    private static void sendCustomNotification(Task task, CustomNotificationType notificationType, String name) {
        if (task.OwnerId != null && notificationType != null) {
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle(name + ' has assigned you a new task');
            notification.setBody('Subject: ' + task.Subject);
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(task.Id);
            notification.send(new Set<String> { task.OwnerId });
        }
    }

    // Send Task Completed Notification
    private static void sendTaskCompletedNotification(Task task, CustomNotificationType notificationType) {
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle('Task Is Completed');
        notification.setBody(task.Subject + ' - Task is Completed');
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(task.Id);
        notification.send(new Set<String> { task.CreatedById });
    }

    // Update Sales Office and Region on task update
    public static void OnTaskUpdate(List<Task> newTasks) {
        Set<Id> createdByIds = new Set<Id>();

        for (Task t : newTasks) {
            createdByIds.add(t.CreatedById);
        }

        Map<Id, User> usersMap = new Map<Id, User>(
            [SELECT Id, Sales_Office__c, Region__c FROM User WHERE Id IN :createdByIds]
        );

        for (Task t : newTasks) {
            if (usersMap.containsKey(t.CreatedById)) {
                User user = usersMap.get(t.CreatedById);
                t.Sales_Office_On_Task__c = user.Sales_Office__c;
                t.Region_of_User__c = user.Region__c;
            }
        }
    }
}