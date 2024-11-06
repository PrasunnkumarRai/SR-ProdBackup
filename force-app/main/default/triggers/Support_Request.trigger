/* 
    Customer/Project:   Spectrum Reach 
    Class name:          Support_Request.trigger
    Author/Date:        John King    5/23/2017
    Release:             TBD
    Related US:         264, 97
    Purpose:            Provides comprehensive callouts for Proposal

  // This should be used in conjunction with the ApexTriggerComprehensive.trigger template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

*/


trigger Support_Request on Support_Request__c (after delete, after insert, after undelete,
after update, before delete, before insert, before update) {
  // This should be used in conjunction with the TriggerHandlerComprehensive.cls template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

  SupportRequestTriggerHandler handler = new SupportRequestTriggerHandler(Trigger.isExecuting, Trigger.size);
  // SRSF-2143 : Added below if condition to prevent trigger firing from batch job
  if(System.isFuture()) {
    return;
  }

  if(Trigger.isInsert && Trigger.isBefore){
    handler.OnBeforeInsert(Trigger.new);
  }
  else if(Trigger.isInsert && Trigger.isAfter){
  List<support_request__c> srList = new List<support_request__c>();
  Set <ID> supportReqIds = new Set<ID>();
  for(support_request__c sr: trigger.new){
   if(sr.Type_of_Request__c == 'Pre-contract consult' && sr.Status__c=='Submitted to Kernel'){    
    srList.add(sr);
    supportReqIds.add(sr.ID);
    System.debug('inside isInsert srList>>>>>'+srList.Size());
   }
  }

  if(srList.size()>0 && ConstantVariables.recurssivevar == false){
    //SRSF-2573 Commented below code
    /*for (ID srId : supportReqIds){
      Set <ID> sendToIMN = new Set <ID>();
      sendToIMN.add(srId);
      SupportRequestTriggerHandler.sendSupportRequestToIMN (sendToIMN,false); 
    } */       
    ConstantVariables.recurssivevar = true;
     //SRSF-2573: Added below code to avoid future calls from for loop
      SupportRequestTriggerHandler.sendSupportRequestToIMN (supportReqIds,false);
  }

  handler.OnAfterInsert(Trigger.new);
  /*if(srList.size()>0){
    // SupportRequestTriggerHandler.callBatchSupportRequest(srList);  // commented by Sridhar
    SupportRequestTriggerHandler.sendSupportRequestToIMN (supportReqIds,false);
  }    */
    
   /* Commented on 15-06-2020 : Sridhar : No logic implemented in this method
    if(executionUtils.isFutureAllowed()) {
      SupportRequestTriggerHandler.OnAfterInsertAsync(Trigger.newMap.keySet());
    }
    */
  }

  else if(Trigger.isUpdate && Trigger.isBefore){
    handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
  }
  else if(Trigger.isUpdate && Trigger.isAfter){
    handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    List<support_request__c> srList = new List<support_request__c>();
     Set <ID> supportReqIds = new Set<ID>();
    if(!system.isBatch()){
          //Call Dell Boomi , kernel project requirement
      for(Support_Request__c sr: trigger.new){
       /*if((Trigger.oldMap.get(sr.Id).Status__c != sr.Status__c && sr.Status__c=='Submitted to Kernel')){
          System.debug('inside IF Loop>>>>>');
          srList.add(sr);
       }else if((Trigger.oldMap.get(sr.Id).Type_of_Request__c != sr.Type_of_Request__c && sr.Type_of_Request__c == 'Pre-contract consult' && sr.Status__c=='Submitted to Kernel')){
          System.debug('inside ELSE IF Loop-1 >>>>>');
          srList.add(sr);
       }else if((Trigger.oldMap.get(sr.Id).Type_of_Request__c != sr.Type_of_Request__c && sr.Type_of_Request__c == 'Post Sale Production Request' && sr.Status__c=='Submitted to Kernel')){
          System.debug('inside ELSE IF Loop-2 >>>>>');
          srList.add(sr);
       }*/
        
        if((sr.Type_of_Request__c == 'Pre-contract consult' && Trigger.oldMap.get(sr.Id).Status__c != sr.Status__c && sr.Status__c=='Submitted to Kernel')){
            srList.add(sr);
            supportReqIds.add(sr.ID);
            System.debug('inside ELSE IF Loop-1 srList>>>>>'+srList.Size());
        }else if((sr.Type_of_Request__c == 'Post Sale Production Request' && Trigger.oldMap.get(sr.Id).Status__c != sr.Status__c && sr.Status__c=='Submitted to Kernel')){
            srList.add(sr);
            supportReqIds.add(sr.ID);
            System.debug('inside ELSE IF Loop-2 srList>>>>>'+srList.Size());
        }
      }
      System.debug('srList Size >>>>>'+srList.Size());
      if(srList.size()>0 && ConstantVariables.recurssivevar == false){
         //SRSF-2573 Commented below code
       /* for (ID srId : supportReqIds){
          Set <ID> sendToIMN = new Set <ID>();
          sendToIMN.add(srId);
          SupportRequestTriggerHandler.sendSupportRequestToIMN (sendToIMN,false); 
        }*/        
        ConstantVariables.recurssivevar = true;
        //SRSF-2573: Added below code to avoid future calls from for loop
        SupportRequestTriggerHandler.sendSupportRequestToIMN (supportReqIds,false);
       // SupportRequestTriggerHandler.callBatchSupportRequest(srList); // commented by Sridhar
       // || (sr.Type_of_Request__c  != Trigger.oldMap.get(sr.Id).Type_of_Request__c  && sr.Type_of_Request__c =='Pre-contract consult') || (sr.Type_of_Request__c  != Trigger.oldMap.get(sr.Id).Type_of_Request__c && sr.Type_of_Request__c =='Post Sale Production Request')
      } 
      
    /* Commented on 15-06-2020 : Sridhar : No logic implemented in this method  
    if(executionUtils.isFutureAllowed()) {
      SupportRequestTriggerHandler.OnAfterUpdateAsync(Trigger.newMap.keySet());
      
    }
    */
    }
  }

  else if(Trigger.isDelete && Trigger.isBefore){
    handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
  }
  else if(Trigger.isDelete && Trigger.isAfter){
    handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
     /* Commented on 15-06-2020 : Sridhar : No logic implemented in this method
    if(executionUtils.isFutureAllowed()) {
      SupportRequestTriggerHandler.OnAfterDeleteAsync(Trigger.oldMap.keySet());
    }
    */
  }

  else if(Trigger.isUnDelete){
    handler.OnUndelete(Trigger.new);
  }
}