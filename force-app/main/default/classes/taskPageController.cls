public with sharing class taskPageController {

    @AuraEnabled(cacheable=true)
     public static List < customValueWrapper > pickListValueDynamically(sObject customObjInfo, string selectPicklistApi) {
        Schema.DescribeSObjectResult objDescribe = customObjInfo.getSObjectType().getDescribe();     
        map < String, Schema.SObjectField > customFieldMap = objDescribe.fields.getMap();      
        list < Schema.PicklistEntry > custPickValues = customFieldMap.get(selectPicklistApi).getDescribe().getPickListValues();
        list < customValueWrapper > customObjWrapper = new list < customValueWrapper > ();
        for (Schema.PicklistEntry myCustPick: custPickValues) {
          customValueWrapper selectOptionValueWrapper = new customValueWrapper();
             selectOptionValueWrapper.custFldlabel = myCustPick.getLabel();
             selectOptionValueWrapper.custFldvalue = myCustPick.getValue();
            customObjWrapper.add(selectOptionValueWrapper);
        }
        
        return customObjWrapper;
  
      }
      // wrapper class 
        public with sharing class customValueWrapper {
          @auraEnabled public string custFldlabel {get;set;}
          @auraEnabled public string custFldvalue {get;set;}
        }

    @AuraEnabled(cacheable = true)
    public static List < sobject > findRecords(String searchKey, String objectName) {
        //System.debug('recId' + recId);
        //System.debug('relatedRec' + relatedRec);
        //System.debug('objectName' + objectName);
        string searchText = ('\'' + String.escapeSingleQuotes(searchKey) + '%\'');
        System.debug('searchText' + searchText);
        string query;
        if (objectName == 'Contact') {
            query = ('SELECT Id, FirstName, LastName FROM ' + objectName + ' WHERE isActive__c=True AND Name LIKE ' + searchText + ' LIMIT 10000');
        }
        if(objectName=='Lead'){
            query = ('SELECT Id,Primary_Advertising_Region_Text__c FROM ' + objectName + 'WHERE Primary_Advertising_Region_Text__c LIKE ' + searchText + ' LIMIT 100');
        }
        
        query = ('SELECT Id, Name FROM ' + objectName + ' WHERE Name LIKE ' + searchText + 'LIMIT 10000');
        
        return Database.query(query);
    }

    @AuraEnabled
    public static void taskCreation(String subject, String dueDate, string assignedTo, string actionType, string relatedTo, string name, string comments, Boolean reminderSet, string reminder, string priority, string status) {
        System.debug('subject==>' + subject + '----' + 'duedate==>' + dueDate + '----' + 'assignedto==>' + assignedTo + '----' + 'actiontype==>' + actionType + '----' + 'relatedTo==>' + relatedTo + '----' + 'name==>' + name + '----' + 'comments==>' + comments + '----' + 'reminderSet===>' + reminderSet + '----' + 'reminderDateTime==>' + reminder + '----' + 'priority==>' + priority + '----' + 'status==>' + status);
         Date dt;
         Datetime myDate;
        
            if(dueDate!=null){
               
                String strDate = dueDate;
                dt = Date.valueOf(strDate.replace('/','-'));
                System.debug('due date==>'+dt);
            }

            if(reminder!=null){
                 myDate = Datetime.valueOf(reminder);
            }
            
       
        Task newTask = new Task(Priority = priority,
            Status = status,
            Subject = subject,
            whatId = relatedTo,
            whoId = name,
            ownerId = assignedTo,
            IsReminderSet = reminderSet,
            Description = comments,
            ActivityDate = dt,
            Action_Type__c= actionType,
            ReminderDateTime = myDate
        );
        insert newTask;
        
        
    }
}