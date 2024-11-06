/* 
    Customer/Project:   Spectrum Reach 
    Class name:          CNA.Trigger
    Author/Date:        John King    5/17/2017
    Release:             TBD
    Related US:         264
    Purpose:            Provides comprehensive callouts for CNA

  // This should be used in conjunction with the ApexTriggerComprehensive.trigger template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

*/


trigger CNA on CNA__c (after delete, after insert, after undelete,
after update, before delete, before insert, before update) {

  CNATriggerHandler handler = new CNATriggerHandler(Trigger.isExecuting, Trigger.size);

  if(Trigger.isInsert && Trigger.isBefore){
    handler.OnBeforeInsert(Trigger.new);
  }
  else if(Trigger.isInsert && Trigger.isAfter){
    handler.OnAfterInsert(Trigger.new);
    if(executionUtils.isFutureAllowed()) {
      CNATriggerHandler.OnAfterInsertAsync(Trigger.newMap.keySet());
    }
  }

  else if(Trigger.isUpdate && Trigger.isBefore){
    handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    handler.UpdateAEDetails(Trigger.new);
  }
  else if(Trigger.isUpdate && Trigger.isAfter){
    handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    if(executionUtils.isFutureAllowed()) {
      CNATriggerHandler.OnAfterUpdateAsync(Trigger.newMap.keySet());
    }
  }

  else if(Trigger.isDelete && Trigger.isBefore){
    handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
  }
  else if(Trigger.isDelete && Trigger.isAfter){
    handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    if(executionUtils.isFutureAllowed()) {
      CNATriggerHandler.OnAfterDeleteAsync(Trigger.oldMap.keySet());
    }
  }

  else if(Trigger.isUnDelete){
    handler.OnUndelete(Trigger.new);
  }
}