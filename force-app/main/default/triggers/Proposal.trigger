/* 
    Customer/Project:   Spectrum Reach 
    Class name:          Proposal.Trigger
    Author/Date:        John King    5/17/2017
    Release:             TBD
    Related US:         264
    Purpose:            Provides comprehensive callouts for Proposal

  // This should be used in conjunction with the ApexTriggerComprehensive.trigger template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

*/

trigger Proposal on Proposal__c (after delete, after insert, after undelete,
after update, before delete, before insert, before update) {
  // This should be used in conjunction with the TriggerHandlerComprehensive.cls template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx
    
    // Added by gthathera - 11/13/2017 
    if( String.isNotBlank( System.Label.isActiveProposal ) && System.Label.isActiveProposal.equalsIgnoreCase('true')) {
      ProposalTriggerHandler handler = new ProposalTriggerHandler(Trigger.isExecuting, Trigger.size);
      if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
        OpportunityTriggerHandler.oppTrendCount = 1;
      }
      else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
        //Commenting the OnAfterInsertAsync block for JIRA#SRSF-4075
        /*if(executionUtils.isFutureAllowed()) {           
            ProposalTriggerHandler.OnAfterInsertAsync(Trigger.newMap.keySet());
        }*/
      }
    
      else if(Trigger.isUpdate && Trigger.isBefore){
        //handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
        if(ProposalTriggerHandler.isFirstTimeExecuting){ //SRSF-4822
            handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }    
      }
      else if(Trigger.isUpdate && Trigger.isAfter){
        System.debug('isFirstTimeExecuting>>>'+ProposalTriggerHandler.isFirstTimeExecuting);
        if(ProposalTriggerHandler.isFirstTimeExecuting){ //SRSF-4822 
            handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
            handler.updateAdvancedPropOnPilotPropUpdate(Trigger.old, Trigger.newMap); // SRSF-4822
            handler.updateDealsOnPilotUpdate(Trigger.old, Trigger.newMap);//SRSF-4778
            //handler.updateDealsOnAdvPropUpdate(Trigger.old, Trigger.newMap); //SRSF-5061
            //Start: SRSF-3209 : Do not move this below code to Apex class as we get 'INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY' error
                List<Proposal__c> propLst = new List<Proposal__c> ();
                for (Proposal__c oldProp : Trigger.old){
                    if (oldProp.Active__c && !Trigger.newMap.get(oldProp.Id).Active__c) { 
                        propLst.add(oldProp);
                    }
                }
                System.debug('propLst--->'+propLst);
                if (!CommonUtilities.isListNullOrEmpty(propLst) && propLst.Size()>0) {
                    updateTask(propLst);
                }   
                //End: SRSF-3209
        }  //SRSF-4822        
        if(executionUtils.isFutureAllowed()) {
             //Commenting the OnAfterUpdateAsync block for JIRA#SRSF-4075        
            /*ProposalTriggerHandler.OnAfterUpdateAsync(Trigger.newMap.keySet());
            if (!ProposalTriggerHandler.isPropTrendRecordAlreadyInserted) {
                ProposalTriggerHandler.OnAfterUpdateAsync(JSON.serialize(Trigger.old),JSON.serialize(Trigger.newMap), false);
                ProposalTriggerHandler.isPropTrendRecordAlreadyInserted = true;
            }*/
        }
      }
    
      else if(Trigger.isDelete && Trigger.isBefore){
        handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
      }
      else if(Trigger.isDelete && Trigger.isAfter){
        //handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
            updateTask(Trigger.old); // SRSF-3209
        //Commenting the OnAfterDeleteAsync block for JIRA#SRSF-4075
        /*if(executionUtils.isFutureAllowed()) {            
            ProposalTriggerHandler.OnAfterDeleteAsync(Trigger.oldMap.keySet());
        }*/
      }
    
      else if(Trigger.isUnDelete){
        handler.OnUndelete(Trigger.new);
      }
    }

  // SRSF-3209 : When an Opportunity Budget is Deleted or Deactivated, Task status to be updated to 'Completed'
    // NOTE: Do not move this method to Apex class as we get 'INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY' error
    public void updateTask (List<Proposal__c> propList)
    {
        Map<Id, String> oppMap = new Map<Id, String>();
        List<Task> tskLstUpdate = new List<Task>();             
        Id propRTId = Schema.SObjectType.Proposal__c.getRecordTypeInfosByDeveloperName().get('Opportunity_Budget').getRecordTypeId();   
        for (Proposal__c prop : propList) {     
            if (prop.RecordTypeId == propRTId){
                oppMap.put(prop.Opportunity__c, prop.Name);
            }
        }   

        if(oppMap.size() > 0)
        {
            List<Task> tskLst = [SELECT Id, Subject, Status, WhatId FROM Task WHERE WhatId IN: oppMap.keySet() AND Status!='Completed'];
            System.debug('tskLst--->'+tskLst);
            for (Task tsk : tskLst)
            {   
                if(tsk.WhatId!=NULL && oppMap.get(tsk.WhatId) != NULL){
                    if(tsk.Subject.equalsIgnoreCase(oppMap.get(tsk.WhatId))){   
                        tsk.Status = 'Completed';
                        tskLstUpdate.add(tsk);  
                    }
                }           
            }
            System.debug('tskLstUpdate--->'+tskLstUpdate);
            if(tskLstUpdate.Size()>0) { 
                UPDATE tskLstUpdate;
            }
        }       
    }
}