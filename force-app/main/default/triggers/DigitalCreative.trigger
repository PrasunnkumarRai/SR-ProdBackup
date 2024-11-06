/* 
    Customer/Project:   Spectrum Reach 
    Class name:          DigitalCreative.trigger
    Author/Date:        John King    6/2/2017
    Release:             TBD
    Related US:     264, 97
    Purpose:            Provides handler methods for the Digital_Creative__c Trigger

  // This should be used in conjunction with the ApexTriggerComprehensive.trigger template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

*/


trigger DigitalCreative on Digital_Creative__c (after delete, after insert, after undelete,
after update, before delete, before insert, before update) {
  // This should be used in conjunction with the TriggerHandlerComprehensive.cls template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx
  //public static Boolean methodfirstcall=true; //static keyoword for removing redundancy
 // public static Integer counter=0;

if(Label.IsActiveDigitalCreativeTrigger == 'true'){
  DigitalCreativeTriggerHandler handler = new DigitalCreativeTriggerHandler(Trigger.isExecuting, Trigger.size);

  if(Trigger.isInsert && Trigger.isBefore){
    handler.OnBeforeInsert(Trigger.new);
  }
  else if(Trigger.isInsert && Trigger.isAfter){
    handler.OnAfterInsert(Trigger.new);
    if(executionUtils.isFutureAllowed()) {
      DigitalCreativeTriggerHandler.OnAfterInsertAsync(Trigger.newMap.keySet());
    }
  }

  else if(StopTriggerRecursionHelper.methodfirstcall){
    if(Trigger.isUpdate && Trigger.isBefore){ StopTriggerRecursionHelper.methodfirstcall=false; // making false to remove redundancy
     // counter++;
    //  system.debug('@@counter '+counter);
    handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);}
  }
  else  if(StopTriggerRecursionHelper.methodafterupdate){
    if(Trigger.isUpdate && Trigger.isAfter){ StopTriggerRecursionHelper.methodafterupdate=false;
    handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
    if(executionUtils.isFutureAllowed()) {
      DigitalCreativeTriggerHandler.OnAfterUpdateAsync(Trigger.newMap.keySet());
    }}
  }

  else if(Trigger.isDelete && Trigger.isBefore){
    handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
  }
  else if(Trigger.isDelete && Trigger.isAfter){
    handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    if(executionUtils.isFutureAllowed()) {
      DigitalCreativeTriggerHandler.OnAfterDeleteAsync(Trigger.oldMap.keySet());
    }
  }

  else if(Trigger.isUnDelete){
    handler.OnUndelete(Trigger.new);
  }
}
}