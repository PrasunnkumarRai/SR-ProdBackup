/*
	Author : MandS
	Date   : Aug 23rd 2022
	Description : LWC Controller for MassApprove/Reject
	Ref: SRSF-3826: Expedite Mass Approval
*/
public class MassApprovalRejectionController {

    //to return the prefix of the object    
    public static string getKeyPrefix(String objectName){
        Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe() ;
        Schema.SObjectType s = m.get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        return r.getKeyPrefix();
    }
    
    //checks if the loggedin user is part of public group
    @AuraEnabled (cacheable=true)
    public static boolean isValidUser(){
        String publicGroupStr = System.Label.MassApproveReject_PublicGroups;
        List<String> publicGroups = publicGroupStr.split(',');
        Boolean isValid = false; 
        List<GroupMember> gm = [select group.name,UserOrGroupId from GroupMember where group.name in :publicGroups and UserOrGroupId =:UserInfo.getUserId()];
        if(!gm.isEmpty()){
           isValid = true;
        }else{
            isValid = false;
        }  
system.debug('isValid'+isValid);
        return isValid;
       
    }
    
    //Method to fetch all the records which are submitted for approval
    @AuraEnabled (cacheable=true)
    public static List<SubmittedRecordsWrapper> getSubmittedRecords(String objectName, String fields, String autoPrefix){
        String keyprefix = getKeyPrefix(objectName);
        system.debug('==>keyprefix ==>'+keyprefix);
        keyprefix = keyprefix;
        List<SubmittedRecordsWrapper> lstSubmissionWrapper = new List<SubmittedRecordsWrapper>();
        List<Id> targetObjectIds = new List<Id>();
        String queryByStatus = 'SELECT  id,Status__c  FROM ' + objectName + ' WHERE Status__c = \'Submit for Expedite Approval\' Limit 1000';
        List<sObject> records = (List<sObject>) Database.query( queryByStatus );
        system.debug('records Size Expedite'+records.size());
        for(sObject rec : records){   targetObjectIds.add(rec.id);
        }
        
        List<String> gmId = new List<String>();
        String publicGroupStr = System.Label.MassApproveReject_PublicGroups;
        List<String> publicGroups = publicGroupStr.split(',');
        List<String> gmList = new List<String>();
        List<GroupMember> groupM = [Select id,group.id,group.name from GroupMember where UserOrGroupId =:UserInfo.getUserId()];
system.debug('records  groupM'+groupM);
        for(GroupMember g : groupM){
            gmList.add(g.group.id);
        }
        
        List<GroupMember> gm = [SELECT UserOrGroupId,GroupId FROM GroupMember WHERE GroupId IN ( SELECT Id FROM Group WHERE Type = 'Queue' and Name in :publicGroups ) and UserOrGroupId in :gmList];
        system.debug('group Member'+gm);
        if(!gm.isEmpty()){  for(GroupMember g : gm){
               // String gid =  g.GroupId.to15();
                gmId.add(g.GroupId);
            }
        }
        //Process instance stores the info of records submitted for approval,
        // Process instance work item are the records an approver sees while approving/rejecting, Process instance step stores approved/rejected record including approva;/rejection comments
        map<Id,SubmittedRecordsWrapper> mapIdToObj = new map<Id,SubmittedRecordsWrapper>();
        list<ProcessInstance> lstPI;
        if(!Test.isRunningTest()){   lstPI = [SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate,
                     			(SELECT ID FROM WorkItems),
                                 (SELECT OriginalActor.Name FROM Steps WHERE StepStatus = 'Started') 
                                  FROM ProcessInstance WHERE TargetObjectId in :targetObjectIds and Id in (SELECT ProcessInstanceId FROM ProcessInstanceWorkItem WHERE ActorId in :gmId)];
 system.debug('Process-Instance'+lstPI);

        }else{
            lstPI = [SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate,
                                 (SELECT ID FROM WorkItems),
                                 (SELECT OriginalActor.Name FROM Steps WHERE StepStatus = 'Started') 
                                  FROM ProcessInstance WHERE TargetObject.Name LIKE :autoPrefix];
 system.debug('Process-Instance'+lstPI);

        }
        if(lstPI!=null && !lstPI.isEmpty()){
            for(ProcessInstance ps : lstPI){
                System.debug('ps::'+ps);
                String targetObject = ps.TargetObjectId;
                if(!ps.WorkItems.isEmpty() && targetObject.startswith(keyprefix)){           SubmittedRecordsWrapper objSubmittedRecordsWrapper = new SubmittedRecordsWrapper();

                    System.debug('ps.stepsps.steps' +ps.steps);
                	System.debug('targetObject' +targetObject);
                	System.debug('ps.WorkItems' +ps.WorkItems);
                    objSubmittedRecordsWrapper.workItemId = ps.WorkItems[0].Id;
                    objSubmittedRecordsWrapper.recordId = ps.TargetObjectId;
                    objSubmittedRecordsWrapper.recordName = ps.TargetObject.Name;
                    //objSubmittedRecordsWrapper.relatedTo = getObjectName(ps.TargetObjectId);//get the object name using the record id
                    objSubmittedRecordsWrapper.submittedDate = Date.newInstance(ps.CreatedDate.year(),ps.CreatedDate.month(),ps.CreatedDate.day());
                    System.debug('objSubmittedRecordsWrapper' +objSubmittedRecordsWrapper);
                    if(!ps.steps.isEmpty()){
                        System.debug('steps' +ps.steps);
                        objSubmittedRecordsWrapper.submittedBy = ps.steps[0].OriginalActor.Name;
                        lstSubmissionWrapper.add(objSubmittedRecordsWrapper);
  System.debug('lstSubmissionWrapper Size' +lstSubmissionWrapper.size());
                        mapIdToObj.put(ps.TargetObjectId, objSubmittedRecordsWrapper);
                    }
                }
            }
        }
        if(mapIdToObj!=null && !mapIdToObj.isEmpty()){   Set<Id> ids = mapIdToObj.keyset();
            String query = 'SELECT '+fields+' FROM '+objectName+' WHERE Id IN:ids';
            map<Id,sObject> mapDC = new Map<ID, sObject>(Database.query(query));
            for(Id dcId : mapDC.keyset()){
                SubmittedRecordsWrapper objWrap = mapIdToObj.get(dcId);
                objWrap.recordInfo = mapDC.get(dcId);
            }
        }
        system.debug('==>lstSubmissionWrapper ==>'+lstSubmissionWrapper);
        return lstSubmissionWrapper;
    }
    
    /*public static String getObjectName(String recordId){
        //To get the label of the object name using Schema methods
        String keyPrefix = recordId.subString(0,3);
        String objectName = '';
        Map<String,Schema.SObjectType> sobjectTypeMap = Schema.getGlobalDescribe();
        for(String obj : sobjectTypeMap.keySet()){
            Schema.DescribeSObjectResult sobjectResult = sobjectTypeMap.get(obj).getDescribe();
            if(sobjectResult.getKeyPrefix() == keyPrefix){
                objectName = sobjectResult.getLabel();
                break;
            }
        }
        return objectName;
    }*/
    
    //Method to Approve or Reject the selected records
    @AuraEnabled
    public static String processRecords(List<String> lstWorkItemIds,String processType, String comments){
        String message = '';
        Integer recordsProcessed = 0;
        List<Approval.ProcessWorkitemRequest> lstWorkItemRequest = new List<Approval.ProcessWorkitemRequest>();//ProcessWorkitemRequest class has methods to programmatically process submitted records
        for(String workItemId : lstWorkItemIds){
            Approval.ProcessWorkitemRequest objWorkItemRequest = new Approval.ProcessWorkitemRequest();
            objWorkItemRequest.setComments(comments);
            objWorkItemRequest.setAction(processType);//approve or reject
            objWorkItemRequest.setWorkitemId(workItemId);
            lstWorkItemRequest.add(objWorkItemRequest);
        }
        Approval.ProcessResult[] lstProcessResult = Approval.process(lstWorkItemRequest,FALSE);//process method is used for approving/rejecting records depending on setAction attribute
        for(Approval.ProcessResult processResult : lstProcessResult){
            if(processResult.isSuccess()){              recordsProcessed++;
            }
            else{
                for(Database.Error error : processResult.getErrors()){
                    message += error.getMessage();
                }
            }
        }
        if(recordsProcessed == lstWorkItemIds.size()){
            message = 'All records are '+comments+' successfully';
        }
        System.debug('message::'+message);
        return message;
    }

    @AuraEnabled
    public static String processRecordsformakegood(List<String> lstWorkItemIds,String processType, String comments){
        String message = '';
        Integer recordsProcessed = 0;
        List<Approval.ProcessWorkitemRequest> lstWorkItemRequest = new List<Approval.ProcessWorkitemRequest>();//ProcessWorkitemRequest class has methods to programmatically process submitted records
        for(String workItemId : lstWorkItemIds){
            Approval.ProcessWorkitemRequest objWorkItemRequest = new Approval.ProcessWorkitemRequest();
            objWorkItemRequest.setComments(comments);
            objWorkItemRequest.setAction(processType);//approve or reject
            objWorkItemRequest.setWorkitemId(workItemId);
            lstWorkItemRequest.add(objWorkItemRequest);
        }
        Approval.ProcessResult[] lstProcessResult = Approval.process(lstWorkItemRequest,FALSE);//process method is used for approving/rejecting records depending on setAction attribute
        for(Approval.ProcessResult processResult : lstProcessResult){
            if(processResult.isSuccess()){              recordsProcessed++;
            }
            else{
                for(Database.Error error : processResult.getErrors()){
                    message += error.getMessage();
                }
            }
        }
        if(recordsProcessed == lstWorkItemIds.size()){
            //message = 'All records are '+comments+' successfully';
        }
        System.debug('message::'+message);
        return message;
    }
  
    @AuraEnabled
    public static String processRecordsforCpm(List<String> lstWorkItemIds,String processType, String comments){
        String message = '';
        Integer recordsProcessed = 0;
        List<Approval.ProcessWorkitemRequest> lstWorkItemRequest = new List<Approval.ProcessWorkitemRequest>();//ProcessWorkitemRequest class has methods to programmatically process submitted records
        for(String workItemId : lstWorkItemIds){
            Approval.ProcessWorkitemRequest objWorkItemRequest = new Approval.ProcessWorkitemRequest();
            objWorkItemRequest.setComments(comments);
            objWorkItemRequest.setAction(processType);//approve or reject
            objWorkItemRequest.setWorkitemId(workItemId);
            lstWorkItemRequest.add(objWorkItemRequest);
        }
        Approval.ProcessResult[] lstProcessResult = Approval.process(lstWorkItemRequest,FALSE);//process method is used for approving/rejecting records depending on setAction attribute
        for(Approval.ProcessResult processResult : lstProcessResult){
            if(processResult.isSuccess()){     recordsProcessed++;
            }
            else{
                for(Database.Error error : processResult.getErrors()){
                    message += error.getMessage();
                }
            }
        }
        if(recordsProcessed == lstWorkItemIds.size()){
           // message = 'All records are '+comments+' successfully';
        }
        System.debug('message::'+message);
        return message;
    }

  //Validuser For MakeGood
 @AuraEnabled (cacheable=true)
    public static boolean isValidUsermakeGood(){
        String publicGroupStr = System.Label.MassApprovalForCPMMakeGoodPublicGroup;
        List<String> publicGroups = publicGroupStr.split(',');
        Boolean UserAccess = false;
        User u=[Select Id,UserRole.DeveloperName From user Where Id =:UserInfo.getUserId()];
        List<GroupMember> gm =[select GroupId,group.name,UserOrGroupId from GroupMember where group.DeveloperName in :publicGroups];
        List<id> grId=new List<id>();
        For(GroupMember g:gm){
           grId.add(g.UserOrGroupId);
        }
        List<Group> GroupName = [select Id ,name, DeveloperName From Group Where Id=:grId ];
        For(Group gp:GroupName){
        System.debug('gp.DeveloperName'+gp.DeveloperName);
        System.debug('u.UserRole.DeveloperName'+u.UserRole.DeveloperName);
        if(u.UserRole.DeveloperName == gp.DeveloperName ){   UserAccess=true;
        }
        System.debug('UserAccess'+UserAccess);}
        return UserAccess;
       
    }
  // Method to fetch all the records whose status is makeGood Approval 
    @AuraEnabled (cacheable=false)
    public static List<MakeGoodWrapper> getAllMakeGoodData(String objectName, String fields, String autoPrefix){
        String keyprefix = getKeyPrefix(objectName);
        system.debug('==>keyprefix ==>'+keyprefix);
        keyprefix = keyprefix;
        List<MakeGoodWrapper> MakegoodApprovalWrapper = new List<MakeGoodWrapper>();
        List<Id> targetObjectIds = new List<Id>();
        String queryByStatus = 'SELECT  id,Status__c  FROM ' + objectName + ' WHERE Status__c = \'Submit Makegood Approval\' Limit 1000';
        List<sObject> AllmakeGood = (List<sObject>) Database.query( queryByStatus );
 system.debug('records Size AllmakeGood'+AllmakeGood.size());
        for(sObject rec : AllmakeGood){   targetObjectIds.add(rec.id);
        }
        List<String> gmId = new List<String>();
        String publicGroupStr = System.Label.MassApprovalForCPMMakeGoodPublicGroup;
        List<String> publicGroups = publicGroupStr.split(',');
        System.debug('publicGroups'+publicGroups);
        List<String> gmList = new List<String>();
        List<GroupMember> groupM = [Select id,group.id,group.name,UserOrGroupId from GroupMember where group.DeveloperName in :publicGroups];
 system.debug('records  groupM'+groupM);
        for(GroupMember g : groupM){
            gmList.add(g.UserOrGroupId);
        }
        System.debug('gmList'+gmList);
         
        List<GroupMember> gm = [SELECT UserOrGroupId,GroupId FROM GroupMember WHERE GroupId IN ( SELECT Id FROM Group WHERE  Id=:gmList ) and group.DeveloperName in :publicGroups];
 system.debug('group Member'+gm);
        if(!gm.isEmpty()){
            for(GroupMember g : gm){
               // String gid =  g.GroupId.to15();
                gmId.add(g.UserOrGroupId);
            } 
            System.debug('gmId'+gmId);
        }
//new Region Changes

List<string> lst=new List<string>();
User u=[Select Id,UserRole.DeveloperName From user Where Id =:UserInfo.getUserId()];
List<Group> gplist= [select Id ,name, DeveloperName From Group Where Id=:gmId];
For(Group gp:gplist){
   System.debug('gp.DeveloperName'+gp.DeveloperName);
   System.debug('u.UserRole.DeveloperName'+u.UserRole.DeveloperName);
   if(u.UserRole.DeveloperName == gp.DeveloperName ){ lst.add(gp.Id);
   }}
   System.debug('lst'+lst);
List<GroupMember> groupme =[select GroupId,group.name,UserOrGroupId from GroupMember where UserOrGroupId =:lst];

list<string> lsstr=new list<string>();
For(GroupMember gmme:groupme){lsstr.add(gmme.GroupId);
}
System.debug('lsstr'+lsstr);
list<string> lsstr2=new list<string>();
List<GroupMember> groupme2 =[select GroupId,group.name,UserOrGroupId from GroupMember where UserOrGroupId =:lsstr];
For(GroupMember gmm:groupme2){lsstr2.add(gmm.GroupId);
}
System.debug('lsstr2'+lsstr2);



//new Region Changes

        //Process instance stores the info of records submitted for approval,
        // Process instance work item are the records an approver sees while approving/rejecting, Process instance step stores approved/rejected record including approva;/rejection comments
        map<Id,MakeGoodWrapper> mapIdToObj = new map<Id,MakeGoodWrapper>();
        list<ProcessInstance> lstPI;
        if(!Test.isRunningTest()){  lstPI = [SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate,
                     			(SELECT ID FROM WorkItems),
                                 (SELECT OriginalActor.Name FROM Steps WHERE StepStatus = 'Started' OR StepStatus ='Pending') 
                                  FROM ProcessInstance WHERE TargetObjectId in :targetObjectIds and Id in (SELECT ProcessInstanceId FROM ProcessInstanceWorkItem WHERE ActorId in :lsstr2)];
 system.debug('Process-Instance'+lstPI);

        }else{
            lstPI = [SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate,
                                 (SELECT ID FROM WorkItems),
                                 (SELECT OriginalActor.Name FROM Steps WHERE StepStatus = 'Started'OR StepStatus ='Pending') 
                                  FROM ProcessInstance WHERE TargetObject.Name LIKE :autoPrefix];
 system.debug('Process-Instance'+lstPI);

        }
        if(lstPI!=null && !lstPI.isEmpty()){   for(ProcessInstance ps : lstPI){
                System.debug('ps::'+ps);
                String targetObject = ps.TargetObjectId;
                if(!ps.WorkItems.isEmpty() && targetObject.startswith(keyprefix)){
                    System.debug('ps.stepsps.steps' +ps.steps);
                	System.debug('targetObject' +targetObject);
                	System.debug('ps.WorkItems' +ps.WorkItems);


                    MakeGoodWrapper objMakeGoodRecordsWrapper = new MakeGoodWrapper();
                    objMakeGoodRecordsWrapper.workItemId = ps.WorkItems[0].Id;
                    objMakeGoodRecordsWrapper.recordId = ps.TargetObjectId;
                    objMakeGoodRecordsWrapper.recordName = ps.TargetObject.Name;
                    //objMakeGoodRecordsWrapper.relatedTo = getObjectName(ps.TargetObjectId);//get the object name using the record id
                    objMakeGoodRecordsWrapper.submittedDate = Date.newInstance(ps.CreatedDate.year(),ps.CreatedDate.month(),ps.CreatedDate.day());
                    System.debug('objMakeGoodRecordsWrapper' +objMakeGoodRecordsWrapper);
                    if(!ps.steps.isEmpty()){
                        System.debug('steps' +ps.steps);
                        objMakeGoodRecordsWrapper.submittedBy = ps.steps[0].OriginalActor.Name;
                        MakegoodApprovalWrapper.add(objMakeGoodRecordsWrapper);
                         system.debug('MakegoodApprovalWrapper Size'+MakegoodApprovalWrapper.size());

                        mapIdToObj.put(ps.TargetObjectId, objMakeGoodRecordsWrapper);
                    }

                }
            }
        }
        if(mapIdToObj!=null && !mapIdToObj.isEmpty()){Set<Id> ids = mapIdToObj.keyset();
            String query = 'SELECT '+fields+' FROM '+objectName+' WHERE Id IN:ids';
            map<Id,sObject> mapDC = new Map<ID, sObject>(Database.query(query));
            for(Id dcId : mapDC.keyset()){
                MakeGoodWrapper objWrap = mapIdToObj.get(dcId);
                objWrap.recordInfo = mapDC.get(dcId);
            }
        }
        system.debug('==>MakegoodApprovalWrapper ==>'+MakegoodApprovalWrapper);
        return MakegoodApprovalWrapper;
        

    }

     // Method to fetch all the records whose status is CPM Negotiated Approval 
     @AuraEnabled (cacheable=false)
     public static List<CPMNegotiatedWrapper> getAllCPMData(String objectName, String fields, String autoPrefix){
         String keyprefix = getKeyPrefix(objectName);
         system.debug('==>keyprefix ==>'+keyprefix);
         keyprefix = keyprefix;
         List<CPMNegotiatedWrapper> CpmApprovalWrapper = new List<CPMNegotiatedWrapper>();
         List<Id> targetObjectIds = new List<Id>();
         //String queryByStatus = 'SELECT  id,Status__c  FROM ' + objectName + ' WHERE Status__c = \'Draft Plan\' Limit 1000';
         //List<sObject> AllmakeCPM = (List<sObject>) Database.query( queryByStatus );
        List<sObject> AllmakeCPM =[select id,Name From Digital_Campaign__c Where Status__c = 'Draft Plan' AND CPM_Negotiat__c !=null AND CreatedDate = LAST_N_DAYS:120];
         system.debug('records Size cpm'+AllmakeCPM.size());
         for(sObject rec : AllmakeCPM){
             targetObjectIds.add(rec.id);
         }
         system.debug('targetObjectIds'+targetObjectIds);
         List<String> gmId = new List<String>();
         String publicGroupStr = System.Label.MassApprovalForCPMMakeGoodPublicGroup;
         List<String> publicGroups = publicGroupStr.split(',');
         System.debug('publicGroups'+publicGroups);
         List<String> gmList = new List<String>();      
        List<GroupMember> groupM = [Select id,group.id,group.name,UserOrGroupId from GroupMember where group.DeveloperName in :publicGroups];

        system.debug('records  groupM'+groupM);
         for(GroupMember g : groupM){
             gmList.add(g.UserOrGroupId);
         }
          System.debug('gmList'+gmList);
         List<GroupMember> gm = [SELECT UserOrGroupId,GroupId FROM GroupMember WHERE GroupId IN ( SELECT Id FROM Group WHERE  Id=:gmList ) and group.DeveloperName in :publicGroups];
 system.debug('group Member'+gm);
         if(!gm.isEmpty()){
             for(GroupMember g : gm){
                // String gid =  g.GroupId.to15();
                 gmId.add(g.UserOrGroupId);
             }
             System.debug('gmId'+gmId);
         }
//new Region Changes

List<string> lst=new List<string>();
User u=[Select Id,UserRole.DeveloperName From user Where Id =:UserInfo.getUserId()];
List<Group> gplist= [select Id ,name, DeveloperName From Group Where Id=:gmId];
For(Group gp:gplist){
   System.debug('gp.DeveloperName'+gp.DeveloperName);
   System.debug('u.UserRole.DeveloperName'+u.UserRole.DeveloperName);
   if(u.UserRole.DeveloperName == gp.DeveloperName ){lst.add(gp.Id);
   }}
   System.debug('lst'+lst);
List<GroupMember> groupme =[select GroupId,group.name,UserOrGroupId from GroupMember where UserOrGroupId =:lst];

list<string> lsstr=new list<string>();
For(GroupMember gmme:groupme){lsstr.add(gmme.GroupId);
}
System.debug('lsstr'+lsstr);
list<string> lsstr2=new list<string>();
List<GroupMember> groupme2 =[select GroupId,group.name,UserOrGroupId from GroupMember where UserOrGroupId =:lsstr];
For(GroupMember gmm:groupme2){lsstr2.add(gmm.GroupId);
}
System.debug('lsstr2'+lsstr2);



//new Region Changes







         //Process instance stores the info of records submitted for approval,
         // Process instance work item are the records an approver sees while approving/rejecting, Process instance step stores approved/rejected record including approva;/rejection comments
         map<Id,CPMNegotiatedWrapper> mapIdToObj = new map<Id,CPMNegotiatedWrapper>();
         list<ProcessInstance> lstPI;
         if(!Test.isRunningTest()){ lstPI =[SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate,
                     			(SELECT ID FROM WorkItems),
                                 (SELECT OriginalActor.Name FROM Steps WHERE StepStatus = 'Started'OR StepStatus ='Pending') 
                                  FROM ProcessInstance WHERE TargetObjectId in :targetObjectIds and Id in (SELECT ProcessInstanceId FROM ProcessInstanceWorkItem WHERE ActorId in :lsstr2) ];
 system.debug('Process-Instance'+lstPI.size());
 system.debug('Process-Instance'+lstPI);

         }else{
             lstPI = [SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate,
                                  (SELECT ID FROM WorkItems),
                                  (SELECT OriginalActor.Name FROM Steps WHERE StepStatus = 'Started' OR StepStatus = 'Pending') 
                                   FROM ProcessInstance WHERE TargetObject.Name LIKE :autoPrefix];
 system.debug('Process-Instance'+lstPI);

         }
         if(lstPI!=null && !lstPI.isEmpty()){ for(ProcessInstance ps : lstPI){     String targetObject = ps.TargetObjectId;

                 System.debug('ps::'+ps);
                 if(!ps.WorkItems.isEmpty() && targetObject.startswith(keyprefix)){
                     System.debug('ps.stepsps.steps' +ps.steps);
                     System.debug('targetObject' +targetObject);
                     System.debug('ps.WorkItems' +ps.WorkItems);


                     CPMNegotiatedWrapper objCPMRecordsWrapper = new CPMNegotiatedWrapper();
                     objCPMRecordsWrapper.workItemId = ps.WorkItems[0].Id;
                     objCPMRecordsWrapper.recordId = ps.TargetObjectId;
                     objCPMRecordsWrapper.recordName = ps.TargetObject.Name;
                     //objCPMRecordsWrapper.relatedTo = getObjectName(ps.TargetObjectId);//get the object name using the record id
                     objCPMRecordsWrapper.submittedDate = Date.newInstance(ps.CreatedDate.year(),ps.CreatedDate.month(),ps.CreatedDate.day());
                     System.debug('objCPMRecordsWrapper' +objCPMRecordsWrapper);
                     if(!ps.steps.isEmpty()){
                         System.debug('steps' +ps.steps);
                         objCPMRecordsWrapper.submittedBy = ps.steps[0].OriginalActor.Name;
                         CpmApprovalWrapper.add(objCPMRecordsWrapper);
 system.debug('CpmApprovalWrapper Size'+CpmApprovalWrapper.size());
                         mapIdToObj.put(ps.TargetObjectId, objCPMRecordsWrapper);
                     }
                   
                 }
             }
         }
         if(mapIdToObj!=null && !mapIdToObj.isEmpty()){  Set<Id> ids = mapIdToObj.keyset();
             String query = 'SELECT '+fields+' FROM '+objectName+' WHERE Id IN:ids';
             map<Id,sObject> mapDC = new Map<ID, sObject>(Database.query(query));
             for(Id dcId : mapDC.keyset()){
                CPMNegotiatedWrapper objWrap = mapIdToObj.get(dcId);
                 objWrap.recordInfo = mapDC.get(dcId);
             }
         }
         system.debug('==>CpmApprovalWrapper ==>'+CpmApprovalWrapper);
         return CpmApprovalWrapper;
         
 
     }
    
    //Wrapper class to store the column values of data table
    public class SubmittedRecordsWrapper{
        @AuraEnabled public Id workItemId;
    	@AuraEnabled public String recordId;
        @AuraEnabled public String relatedTo;
        @AuraEnabled public String recordName;
        @AuraEnabled public String submittedBy;
        @AuraEnabled public Date submittedDate;
        @AuraEnabled public sObject recordInfo;
    }
    //Wrapper class to store the column values of MakeGood datatable
    public class MakeGoodWrapper{
        @AuraEnabled public Id workItemId;
    	@AuraEnabled public String recordId;
        @AuraEnabled public String relatedTo;
        @AuraEnabled public String recordName;
        @AuraEnabled public String submittedBy;
        @AuraEnabled public Date submittedDate;
        @AuraEnabled public sObject recordInfo;


    }
     //Wrapper class to store the column values of CPM datatable
     public class CPMNegotiatedWrapper{
        @AuraEnabled public Id workItemId;
    	@AuraEnabled public String recordId;
        @AuraEnabled public String relatedTo;
        @AuraEnabled public String recordName;
        @AuraEnabled public String submittedBy;
        @AuraEnabled public Date submittedDate;
        @AuraEnabled public sObject recordInfo;


    }


}