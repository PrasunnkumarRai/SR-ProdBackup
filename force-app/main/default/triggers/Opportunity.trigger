/* 
    Customer/Project:   Spectrum Reach
    Class name:          Opportunity.Trigger
    Author/Date:        Brett Ballantyne    5/1/2017
    Release:             TBD
    Purpose:            The one and only Opportunity Trigger

  // This should be used in conjunction with the ApexTriggerComprehensive.trigger template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx
  // Brett's note - I'm a believer in trigger frameworks, and I've implemented more complex and capable frameworks than this before,
  // but this is a start and should be sufficient for now.  If we end up doing a lot more oppty trigger work, I would recommend
  // we go with something more comprehensive

*/

trigger Opportunity on Opportunity (after delete, after insert, after undelete,
after update, before delete, before insert, before update) {

    // Added by gthathera - 11/13/2017 
    if( String.isNotBlank( System.Label.isActiveOpportunity ) && System.Label.isActiveOpportunity.equalsIgnoreCase('true')) {
    
      OpportunityTriggerHandler handler = new OpportunityTriggerHandler(Trigger.isExecuting, Trigger.size);
    
      if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
      }
      else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
        OpportunityTriggerHandler.InsertDefaultOpptyTeam(Trigger.new);
        //Commenting the OnAfterInsertAsync block below for JIRA#SRSF-4075
        /*if(executionUtils.isFutureAllowed()) {
          //OpportunityTriggerHandler.OnAfterInsertAsync(Trigger.newMap.keySet());          
          OpportunityTriggerHandler.OnAfterInsertAsync(JSON.serialize(Trigger.new));
        }*/
      }
    
      else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
      }
      else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAftrUpdt(Trigger.old, Trigger.new, Trigger.newMap,Trigger.oldMap);
        //handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
        System.debug('executionUtils.isFutureAllowed() : ' + executionUtils.isFutureAllowed());
        System.debug('OpportunityTriggerHandler.isOppTrendRecordAlreadyInserted : ' + OpportunityTriggerHandler.isOppTrendRecordAlreadyInserted);
        System.debug('OpportunityTriggerHandler.oppTrendCount : ' + OpportunityTriggerHandler.oppTrendCount);
        if(executionUtils.isFutureAllowed()) {
            //Commenting the OnAfterUpdateAsync block for JIRA#SRSF-4075
            /*OpportunityTriggerHandler.OnAfterUpdateAsync(Trigger.newMap.keySet());
            IB: below code is to create Opportunity Trend record
            if (!OpportunityTriggerHandler.isOppTrendRecordAlreadyInserted || OpportunityTriggerHandler.oppTrendCount == 2) {
                if (OpportunityTriggerHandler.oppTrendCount <= 1) {
                    OpportunityTriggerHandler.OnAfterUpdateAsync(JSON.serialize(Trigger.old),JSON.serialize(Trigger.newMap), false);
                    OpportunityTriggerHandler.oppTrendCount = OpportunityTriggerHandler.oppTrendCount + 1;
                    OpportunityTriggerHandler.isOppTrendRecordAlreadyInserted = true;
                }
            }*/
        }
      }
    
      else if(Trigger.isDelete && Trigger.isBefore){
        handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
      }
      else if(Trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
        //Commenting the OnAfterDeleteAsync block for JIRA#SRSF-4075
        /*if(executionUtils.isFutureAllowed()) {          
          OpportunityTriggerHandler.OnAfterDeleteAsync(Trigger.oldMap.keySet());
        }*/
      }
    
      else if(Trigger.isUnDelete){
        handler.OnUndelete(Trigger.new);
      }
    }
}