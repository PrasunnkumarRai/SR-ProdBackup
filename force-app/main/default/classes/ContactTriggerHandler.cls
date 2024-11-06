/* 
    Customer/Project:   Spectrum Reach
    Class name:          ContactTriggerHandler.cls
    Author/Date:        Brett Ballantyne    1/18/2018
    Release:             Phase 3
    Purpose:            Handler for the Contact trigger

  // This should be used in conjunction with the ApexTriggerComprehensive.trigger template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx
*/

public with sharing class ContactTriggerHandler {

  private boolean m_isExecuting = false;
  private integer BatchSize = 0;

  public ContactTriggerHandler(boolean isExecuting, integer size){
    m_isExecuting = isExecuting;
    BatchSize = size;
  }

  public void OnBeforeInsert(Contact[] newRecords){
    // current user on create should be the AE
    Set<Id> ownerIdSet = new Set<Id>();
    for (Contact con : newRecords) {
        ownerIdSet.add(con.OwnerId);
    }
    Map<Id, User> userMap = new Map<Id, User>([select Id, Name, Sales_Office__c, Region__c, Division__c from User where Id in :ownerIdSet]);

    for(Contact newRecord : newRecords){
      User userRec = userMap.get(newRecord.OwnerId);
      newRecord.Region__c = userRec.Region__c;
      newRecord.Division__c = userRec.Division__c;
      newRecord.Sales_Office__c = userRec.Sales_Office__c;
    }
  }

  public void OnAfterInsert(Contact[] newRecords){

  }

  public static void OnAfterInsertAsync(Set<ID> newRecordIDs){
    //Example usage
    //List<Contact> newRecords = [select Id, Name from Contact where Id IN :newRecordIDs];
  }

  public void OnBeforeUpdate(Contact[] oldRecords, Contact[] updatedRecords, Map<ID, Contact> recordMap){
    //Example Map usage
    //Map<ID, Contact> contacts = new Map<ID, Contact>( [select Id, FirstName, LastName, Email from Contact where ContactId IN :recordMap.keySet()] );
    Set<Id> ownerIdSet = new Set<Id>();
    for (Contact con : updatedRecords) {
        ownerIdSet.add(con.OwnerId);
    }
    Map<Id, User> userMap = new Map<Id, User>([select Id, Name, Sales_Office__c, Region__c, Division__c from User where Id in :ownerIdSet]);
    for (Contact con : updatedRecords) {
        User userRec = userMap.get(con.OwnerId);
        system.debug(loggingLevel.WARN, '---------->> con.OwnerId = ' + con.OwnerId);
        system.debug(loggingLevel.WARN, '---------->> userRec.Sales_Office__c = ' + userRec.Sales_Office__c);
        system.debug(loggingLevel.WARN, '---------->> userRec.Region__c = ' + userRec.Region__c);
        system.debug(loggingLevel.WARN, '---------->> userRec.Division__c = ' + userRec.Division__c);
        con.Sales_Office__c = userRec.Sales_Office__c;
        con.Region__c = userRec.Region__c;
        con.Division__c = userRec.Division__c;
    }

  }

  public void OnAfterUpdate(Contact[] oldRecords, Contact[] updatedRecords, Map<ID, Contact> recordMap){

  }

  public static void OnAfterUpdateAsync(Set<ID> updatedRecordIDs){
    //List<Contact> updatedRecords = [select Id, Name from Contact where Id IN :updatedRecordIDs];
  }

  public void OnBeforeDelete(Contact[] recordsToDelete, Map<ID, Contact> recordMap){

  }

  public void OnAfterDelete(Contact[] deletedRecords, Map<ID, Contact> recordMap){

  }

  public static void OnAfterDeleteAsync(Set<ID> deletedRecordIDs){

  }

  public void OnUndelete(Contact[] restoredRecords){

  }

  public boolean IsTriggerContext{
    get{ return m_isExecuting;}
  }

  public boolean IsVisualforcePageContext{
    get{ return !IsTriggerContext;}
  }

  public boolean IsWebServiceContext{
    get{ return !IsTriggerContext;}
  }

  public boolean IsExecuteAnonymousContext{
    get{ return !IsTriggerContext;}
  }
}