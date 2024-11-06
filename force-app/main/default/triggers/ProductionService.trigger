/* 
    Customer/Project:   Spectrum Reach 
    Class name:          ProductionService.trigger
    Author/Date:        John King    6/2/2017
    Release:             TBD
    Related US:     264, 97
    Purpose:            Provides handler methods for the Production_Service__c Trigger

  // This should be used in conjunction with the ApexTriggerComprehensive.trigger template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

*/

trigger ProductionService on Production_Service__c (after delete, after insert, after undelete,
after update, before delete, before insert, before update) {
  // This should be used in conjunction with the TriggerHandlerComprehensive.cls template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

  ProductionServiceTriggerHandler handler = new ProductionServiceTriggerHandler(Trigger.isExecuting, Trigger.size);
 // SRSF-2143 : Added below if condition to prevent trigger firing from batch job
  if(System.isFuture()) {
    return;
  }

  if(Trigger.isInsert && Trigger.isBefore){
    handler.OnBeforeInsert(Trigger.new);
  }
  else if(Trigger.isInsert && Trigger.isAfter){
    handler.OnAfterInsert(Trigger.new);
    /* Commented on 15-06-2020 : Sridhar : No logic implemented in this method
    if(executionUtils.isFutureAllowed()) {
      ProductionServiceTriggerHandler.OnAfterInsertAsync(Trigger.newMap.keySet());
    }
    */
  }

  else if(Trigger.isUpdate && Trigger.isBefore){
    handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
  }
  else if(Trigger.isUpdate && Trigger.isAfter){
    handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    List<production_service__c> psList = new List<production_service__c>();
    Set<ID> prodServID = new Set<ID>();
    For(production_service__c ps: trigger.new){
     if((Trigger.oldMap.get(ps.Id).Status__c != ps.Status__c && ps.Status__c == 'Complete - Billing Submitted')){
          psList.add(ps);
          prodServID.add(ps.Id);
       }
    }
     //Call Dell Boomi
    System.debug('psList>>>>>'+psList.Size());
    if(psList.size()>0 && ConstantVariables.recurssivevar == false){
       //ProductionServiceTriggerHandler.callBatchProductionServ(psList);
       //SRSF-2572 Commented below code
        /*for (ID psId : prodServID){
          Set <ID> sendToIMN = new Set <ID>();
          sendToIMN.add(psId);
          ProductionServiceTriggerHandler.sendProductionServToIMN (sendToIMN,false); 
        } */
       ConstantVariables.recurssivevar = true; 
       //SRSF-2572: Added below code to avoid future calls from for loop     
       ProductionServiceTriggerHandler.sendProductionServToIMN (prodServID, false);
    }

    /* Commented on 15-06-2020 : Sridhar : No logic implemented in this method
    if(executionUtils.isFutureAllowed()) {
      ProductionServiceTriggerHandler.OnAfterUpdateAsync(Trigger.newMap.keySet());
    }
    */
  }

  else if(Trigger.isDelete && Trigger.isBefore){
    handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
  }
  else if(Trigger.isDelete && Trigger.isAfter){
    handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    /* Commented on 15-06-2020 : Sridhar : No logic implemented in this method
    if(executionUtils.isFutureAllowed()) {
      ProductionServiceTriggerHandler.OnAfterDeleteAsync(Trigger.oldMap.keySet());
    }
    */
  }

  else if(Trigger.isUnDelete){
    handler.OnUndelete(Trigger.new);
  }
}