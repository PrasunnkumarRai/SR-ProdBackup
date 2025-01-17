/* 
    Customer/Project:   Spectrum Reach 
    Class name:          Lead.trigger
    Author/Date:        John King    5/31/2017
    Release:             TBD
    Purpose:            Provides handler methods for the Lead Trigger

  // This should be used in conjunction with the ApexTriggerComprehensive.trigger template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

*/

trigger Lead on Lead (after delete, after insert, after undelete,
after update, before delete, before insert, before update) {
  // This should be used in conjunction with the TriggerHandlerComprehensive.cls template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

  LeadTriggerHandler handler = new LeadTriggerHandler(Trigger.isExecuting, Trigger.size);

  if(Trigger.isInsert && Trigger.isBefore){
    handler.OnBeforeInsert(Trigger.new);
  }
  else if(Trigger.isInsert && Trigger.isAfter){
    handler.OnAfterInsert(Trigger.new);
    //LeadTriggerHandler.OnAfterInsertAsync(Trigger.newMap.keySet());
  }

  else if(Trigger.isUpdate && Trigger.isBefore){
    handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
  }
  else if(Trigger.isUpdate && Trigger.isAfter){
    handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    //LeadTriggerHandler.OnAfterUpdateAsync(Trigger.newMap.keySet());
  }

  //else if(Trigger.isDelete && Trigger.isBefore){
    //handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
  //}
  else if(Trigger.isDelete && Trigger.isAfter){
    handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    //LeadTriggerHandler.OnAfterDeleteAsync(Trigger.oldMap.keySet());
  }

  else if(Trigger.isUnDelete){
    handler.OnUndelete(Trigger.new);
  }
}