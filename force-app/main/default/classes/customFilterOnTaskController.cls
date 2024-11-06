public with sharing class customFilterOnTaskController {

    @AuraEnabled
    public static Id getLoggedUserId() {
        return UserInfo.getUserId();
    }

     @AuraEnabled
    public static List<User> nameOftheUser() {
         Id loggedUserId = getLoggedUserId();
         List<User> userN=[Select Name from User where Id=:loggedUserId LIMIT 1];
        return userN;
    }
    

    @AuraEnabled
    public static List < TaskWrapper > TaskDetails(String recordIds) {
        System.debug('Record Id From JS-->'+recordIds);
        Id loggedUserId = getLoggedUserId();
        List < Task > taskDetail = [Select Id, OwnerId,ActivityDate, Owner.Name, WhoId, Who.Name, WhatId, What.Name, Status, Subject, Priority From Task where Status != 'Completed'
            AND CreatedById =: loggedUserId AND (WhoId =: recordIds OR WhatId =: recordIds)
        ];
        System.debug('Task Details==>' + taskDetail);
        List < TaskWrapper > taskWrapperList = new List < TaskWrapper > ();
        for (Task task: taskDetail) {
            TaskWrapper taskWrapper = new TaskWrapper();
            taskWrapper.Status = task.Status != null ? task.Status : null;
            taskWrapper.Id = task.Id != null ? task.Id : null;
            taskWrapper.dueDtae = task.ActivityDate != null ? task.ActivityDate : null;
            taskWrapper.Subject = task.Subject != null ? task.Subject : null;
            taskWrapper.Priority = task.Priority != null ? task.Priority : null;
            taskWrapper.ownerName = task.Owner != null ? task.Owner.Name : null;
            taskWrapper.whoName = task.Who != null ? task.Who.Name : null;
            taskWrapper.whatName = task.What != null ? task.What.Name : null;
            taskWrapperList.add(taskWrapper);
        }
        return taskWrapperList;
    }

    @AuraEnabled
    public static List<LookupSearchResult> UserDetail(String searchTerm,
	                                                      List<String> selectedIds,
	                                                      String searchType) {
        List < User > getUsers = [SELECT Id, Name, Email, Profile.Name FROM User WHERE Name LIKE: searchTerm + '%'];
		System.debug('getUsers::'+getUsers);
        List<LookupSearchResult> results = new List<LookupSearchResult> ();

		String userIcon = 'standard:user';
		for (User user : getUsers) {
			results.add(
			            new LookupSearchResult(
			                                   user.Id,
			                                   'User',
			                                   userIcon,
			                                   user.Name,
			                                   'Email : ' + user.Email + '\n' + ' | Profile : ' + user.Profile.Name + '\n'
			)
			);
		}
		System.debug('results: '+results);
		return results;
    }

     @AuraEnabled(cacheable=true)
    public static List<MultiTaskWrapper> getTasksByUserIds(List<Id> userIds, String recordIds) {
        System.debug('Record Id From JS In getTasksByUserIds-->'+recordIds);
        Id loggedUserId = getLoggedUserId();
        List<Task> tasks = [SELECT Id, Subject,ActivityDate, Status, Priority, Owner.Name, Who.Name, What.Name,WhoId,WhatId
                            FROM Task
                            WHERE Status != 'Completed' AND OwnerId IN :userIds AND CreatedById =: loggedUserId AND (WhoId =: recordIds OR WhatId =: recordIds)];
        System.debug('tasks::'+tasks);
        List<MultiTaskWrapper> taskWrapperList = new List<MultiTaskWrapper>();
        for (Task task : tasks) {
            MultiTaskWrapper taskWrapper = new MultiTaskWrapper();
            taskWrapper.Id = task.Id != null ? task.Id : null;
            taskWrapper.MultiStatus = task.Status != null ? task.Status : null;
            taskWrapper.MultidueDtae = task.ActivityDate != null ? task.ActivityDate : null;
            taskWrapper.MultiSubject = task.Subject != null ? task.Subject : null;
            taskWrapper.MultiPriority = task.Priority != null ? task.Priority : null;
            taskWrapper.MultiownerName = task.Owner != null ? task.Owner.Name : null;
            taskWrapper.MultiwhoName = task.Who != null ? task.Who.Name : null;
            taskWrapper.MultiwhatName = task.What != null ? task.What.Name : null;
            taskWrapperList.add(taskWrapper);
        }
        
        return taskWrapperList;
    }
    
    public class MultiTaskWrapper {
        @AuraEnabled
        public Id Id { get; set; }
        @AuraEnabled
        public String MultiStatus { get; set; }
        @AuraEnabled
        public Date MultidueDtae { get; set; }
        @AuraEnabled
        public String MultiSubject { get; set; }
        @AuraEnabled
        public String MultiPriority { get; set; }
        @AuraEnabled
        public String MultiownerName { get; set; }
        @AuraEnabled
        public String MultiwhoName { get; set; }
        @AuraEnabled
        public String MultiwhatName { get; set; }
    }


    public class TaskWrapper {
        @AuraEnabled
        public Id Id {
            get;
            set;
        }
        @AuraEnabled
        public Task task {
            get;
            set;
        }
        @AuraEnabled
        public String whoName {
            get;
            set;
        }
        @AuraEnabled
        public Date dueDtae {
            get;
            set;
        }
        @AuraEnabled
        public String whatName {
            get;
            set;
        }
        @AuraEnabled
        public String ownerName {
            get;
            set;
        }
        @AuraEnabled
        public String Status {
            get;
            set;
        }
        @AuraEnabled
        public String Subject {
            get;
            set;
        }
        @AuraEnabled
        public String Priority {
            get;
            set;
        }
    }



}