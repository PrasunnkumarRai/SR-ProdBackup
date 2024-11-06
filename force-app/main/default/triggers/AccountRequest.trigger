/* 
    Customer/Project:   Spectrum Reach 
    Class name:          AccountRequestTriggerHandler
    Author/Date:        John King    5/31/2017
    Release:             TBD
    Purpose:            Provides handler methods for the AccountRequest Trigger

  // This should be used in conjunction with the ApexTriggerComprehensive.trigger template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

*/

trigger AccountRequest on Account_Request__c (after delete, after insert, after undelete,
after update, before delete, before insert, before update) {
  // This should be used in conjunction with the TriggerHandlerComprehensive.cls template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

  AccountRequestTriggerHandler handler = new AccountRequestTriggerHandler(Trigger.isExecuting, Trigger.size);

  if(Trigger.isInsert && Trigger.isBefore){
    handler.OnBeforeInsert(Trigger.new);
  }
  else if(Trigger.isInsert && Trigger.isAfter){
    handler.OnAfterInsert(Trigger.new);
    //Commenting the OnAfterInsertAsync block for JIRA#SRSF-4075
    /*if(executionUtils.isFutureAllowed()) {      
      AccountRequestTriggerHandler.OnAfterInsertAsync(Trigger.newMap.keySet());
    }*/
  }

  else if(Trigger.isUpdate && Trigger.isBefore){
    handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
  }
  else if(Trigger.isUpdate && Trigger.isAfter){
    handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    //Commenting the OnAfterUpdateAsync block for JIRA#SRSF-4075
    /*if(executionUtils.isFutureAllowed()) {      
      AccountRequestTriggerHandler.OnAfterUpdateAsync(Trigger.newMap.keySet());
    }*/
  }

  else if(Trigger.isDelete && Trigger.isBefore){
    handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
  }
  else if(Trigger.isDelete && Trigger.isAfter){
    handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    //Commenting the OnAfterDeleteAsync block for JIRA#SRSF-4075
    /*if(executionUtils.isFutureAllowed()) {      
      AccountRequestTriggerHandler.OnAfterDeleteAsync(Trigger.oldMap.keySet());
    }*/
  }

  else if(Trigger.isUnDelete){
    handler.OnUndelete(Trigger.new);
  }
}