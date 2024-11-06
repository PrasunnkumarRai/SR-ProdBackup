global class SupportRequestStatusUpdate_Batch implements Database.Batchable<sObject> {
	
	String query;
	
	global SupportRequestStatusUpdate_Batch() {
		String query;
        if(!test.isRunningTest())
        	query = 'Select Type_of_Request__c, Status__C, Count_of_Production_Services__c, Count_of_Completed_Prod_Services__c, Count_of_Cancelled_Prod_Services__c, Count_of_Cancelled_Digital_Prod_Services__c, Count_of_Cancelled_Linear_Prod_Services__c, Count_of_Completed_Digital_Prod_Services__c, Count_of_Completed_Linear_Prod_Services__c from Support_Request__c where Type_of_Request__c = \'Post Sale Production Request\' AND Status__C NOT IN(\'Completed by Kernel\', \'Cancelled\') AND ((Count_of_Production_Services__c > 0) AND ((Count_of_Cancelled_Prod_Services__c > 0) OR (Count_of_Completed_Prod_Services__c > 0)))';
		else
            query = 'Select Type_of_Request__c, Status__C, Count_of_Production_Services__c, Count_of_Completed_Prod_Services__c, Count_of_Cancelled_Prod_Services__c, Count_of_Cancelled_Digital_Prod_Services__c, Count_of_Cancelled_Linear_Prod_Services__c, Count_of_Completed_Digital_Prod_Services__c, Count_of_Completed_Linear_Prod_Services__c from Support_Request__c where Type_of_Request__c = \'Post Sale Production Request\' AND Status__C NOT IN(\'Completed by Kernel\', \'Cancelled\') AND ((Count_of_Production_Services__c > 0) AND ((Count_of_Cancelled_Prod_Services__c > 0) OR (Count_of_Completed_Prod_Services__c > 0))) limit 1';
        this.query = query;	
        System.Debug('Query in constructor: '+ query);
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
        System.Debug('Query in Database.QueryLocator: '+ query);
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.Debug('Scope in execute method: '+ scope);
        List<Support_Request__c> supportrequests = scope;
        List<Support_Request__c> supportrequestsToAdd = new List<Support_Request__c>();
        for(Support_Request__c sr : supportrequests){
			if ((sr.Count_of_Production_Services__c > 0) && (sr.Count_of_Cancelled_Prod_Services__c == sr.Count_of_Production_Services__c)) {
				sr.Status__c = 'Cancelled';
                supportrequestsToAdd.Add(sr);
                System.Debug('SupportRequestStatusUpdate_Batch: Added sr in Cancelled:'+ sr);
			}
			else if (sr.Count_of_Completed_Prod_Services__c + sr.Count_of_Cancelled_Prod_Services__c == sr.Count_of_Production_Services__c) {
				sr.Status__c = 'Completed by Kernel';
                supportrequestsToAdd.Add(sr);
                System.Debug('SupportRequestStatusUpdate_Batch: Added sr in Completed by Kernel:'+ sr);
       		}
        	else {
        		System.Debug('*** SupportRequestStatusUpdate_Batch Not updated Support Request: ' + sr);
        	}
        }
        System.debug('SupportRequestStatusUpdate_Batch supportrequestsToAdd: '+ supportrequestsToAdd.size());
        if (supportrequestsToAdd.size() > 0){
           System.Debug('Added Support Requests #: '+ supportrequestsToAdd.size());
           update supportrequestsToAdd; 
        }
   	}
	
	global void finish(Database.BatchableContext BC) {
	}	
}