/* 
Customer/Project:   Spectrum Reach 
Class name:          DigitalCampaign.trigger
Author/Date:        John King    6/2/2017
Release:             TBD
Related US:     264, 97
Purpose:            Provides handler methods for the Digital_Campaign__c Trigger

// This should be used in conjunction with the ApexTriggerComprehensive.trigger template
// The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

*/

trigger DigitalCampaign on Digital_Campaign__c (after delete, after insert, after undelete,
                                                after update, before delete, before insert, before update) {
                                                    // This should be used in conjunction with the TriggerHandlerComprehensive.cls template
                                                    // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx
                                                    if(Label.IsActiveDigitalCampaignTrigger == 'true'){
                                                        DigitalCampaignTriggerHandler handler = new DigitalCampaignTriggerHandler(Trigger.isExecuting, Trigger.size);
                                                        System.debug('StopTriggerRecursionHelper.methodfirstcall::'+StopTriggerRecursionHelper.methodfirstcall);
                                                        System.debug('Trigger.isInsert:::'+Trigger.isInsert);
                                                        System.debug('Trigger.isBefore:::'+Trigger.isBefore);
                                                        System.debug('Trigger.isUpdate:::'+Trigger.isUpdate);
                                                        System.debug('Trigger.isAfter:::'+Trigger.isAfter);
                                                        if(Trigger.isInsert && Trigger.isBefore){
                                                            handler.OnBeforeInsert(Trigger.new);
                                                        }
                                                        else if(Trigger.isInsert && Trigger.isAfter){
                                                            handler.OnAfterInsert(Trigger.new);
                                                         
                                                            if(executionUtils.isFutureAllowed()) {
                                                                DigitalCampaignTriggerHandler.OnAfterInsertAsync(Trigger.newMap.keySet());
                                                            }
                                                        }
                                                        else  if(StopTriggerRecursionHelper.methodfirstcall){
                                                              if(Trigger.isUpdate && Trigger.isBefore){
                                                              StopTriggerRecursionHelper.methodfirstcall=false; // making false to remove redundancy
                                                            handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
                                                              }}
                                                       else  if(StopTriggerRecursionHelper.methodafterupdate){
                                                               if(Trigger.isUpdate && Trigger.isAfter){
                                                                StopTriggerRecursionHelper.methodafterupdate=false;
                                                            handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap,Trigger.oldMap); 
                                                              }
                                                            
                                                            if(executionUtils.isFutureAllowed()) {
                                                                DigitalCampaignTriggerHandler.OnAfterUpdateAsync(Trigger.newMap.keySet());
                                                            }
                                                        }
                                                        
                                                        else if(Trigger.isDelete && Trigger.isBefore){
                                                            handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
                                                        }
                                                        else if(Trigger.isDelete && Trigger.isAfter){
                                                            handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
                                                            if(executionUtils.isFutureAllowed()) {
                                                                DigitalCampaignTriggerHandler.OnAfterDeleteAsync(Trigger.oldMap.keySet());
                                                            }
                                                        }
                                                        
                                                        else if(Trigger.isUnDelete){
                                                            handler.OnUndelete(Trigger.new);
                                                        }
                                                    }
                                                }