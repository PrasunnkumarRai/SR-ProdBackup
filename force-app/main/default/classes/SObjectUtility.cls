public with sharing class SObjectUtility {

	private final sObject mysObject;
    public String recordType {get;set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public SObjectUtility(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
        system.debug('========>> stdController = ' + stdController);
    }

    public String getRecordName() {
        return 'Hello ' + (String)mysObject.get('name') + ' (' + (Id)mysObject.get('Id') + ')';
    }

    public PageReference createNewAccount() {
        system.debug('=================>> recordType = ' + recordType);
        String recType = recordType != null ? recordType : '';
        PageReference pageRef = new PageReference('/001/e?retURL=%2F001%2Fo&nooverride=1&RecordType=='+ recType);
        //PageReference pageRef = new PageReference('/001/e?retURL=%2F001%2Fo&nooverride=1&acc2='+ searchText);
      //  PageReference pageRef = new PageReference('/setup/ui/recordtypeselect.jsp?ent=Account&nooverride=1&save_new_url=%2F001%2Fe');
        return pageRef;        
    }
}