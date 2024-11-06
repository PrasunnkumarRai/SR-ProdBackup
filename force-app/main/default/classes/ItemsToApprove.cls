/*
* @Author               : M & S
* @Description          : Getting the records of Approval process and updating the status 
* @Date Of Creation     : 8/28/2017 
* @Modified by          : 
* @Modified Date        : 
* @Modifiction History  :
* @Related Meta Data    : ItemsToApproveCmp (Lightning Component) 
*/
public class ItemsToApprove { 
    
    /*
    * @Description          : This method will be called by the helper function from ItemToApproveCmp Component  
    * Returns               : instance of wrapper class 
    */
   @AuraEnabled  
   public static ApprovalList getApprovalData()  
   {  
            
      ApprovalList approvalResult = new ApprovalList();  
      Set<String> setUserId = new Set<String>();//Holds UserId
      Set<String> setTargetObjId = new Set<String>();//Holds TargetObjectIds 
      List<String> profileLst = new List<String>{'Master - Local Sales Manager', 'Master - Director of Sales'}; //SRSF-3844
 

      setUserId.add(UserInfo.getUserId());       
      for (ProcessInstance pI: getProcessHistory().values()) {
            setUserId.add(pI.SubmittedById);            
            setTargetObjId.add(pI.TargetObjectId);
      }
       
      Map<String,String> mapUserAlias = getUserAlias(setUserId);
      Map<String,Account_Request__c> mapAccReq = getAssociatedAccount(setTargetObjId);       
      Map<String,String> mapARRT = getAssociatedAccountRequestRT(mapAccReq); 

       // START : SRSF-3392
      Map<String,Trade__c> mapTradeReq = getAssociatedTrade(setTargetObjId);
      Map<String,String> mapTradeRT = getAssociatedTradeRT (mapTradeReq);
       // END : SRSF-3392

      Map<String,Account_Transfer_Tool__c> mapATSReq = getAssociatedATS(setTargetObjId); // SRSF-3762 

      // START : SRSF-3844 
      Map<String,Account_SAM_Mapping__c> mapASMReq = getAssociatedASM(setTargetObjId);       
      String usrProfile = [SELECT Id, Name FROM Profile WHERE Id =:Userinfo.getProfileId()].Name; 
      // END : SRSF-3844
       
      for (ProcessInstance pI: getProcessHistory().values()) 
      {  
          String strRecordType='', strSobjLbl='', strActorName='', strAccName='', strAcctExecutiveId='', strAcctExecutive='', strStatus='', strAccId = null,strDept,strReason;  
          Decimal strNetAmt=0.0;        

          System.debug('SubmittedById-->'+pI.SubmittedBy.Name);
          System.debug('RecordId-->'+pI.TargetObjectId);
          String sObjectName = pI.TargetObjectId.getSObjectType().getDescribe().getName();
           
        if(!mapAccReq.isEmpty() && mapAccReq.containsKey(pI.TargetObjectId)) 
        {  // START : SRSF-3392
           strRecordType = (!mapARRT.isEmpty() && mapARRT.containsKey(pI.TargetObjectId) && mapARRT.get(pI.TargetObjectId)!=null)? mapARRT.get(pI.TargetObjectId) : null;
           strSobjLbl = pI.TargetObjectId.getSObjectType().getDescribe().getLabel();            
           strActorName = (!mapUserAlias.isEmpty() && mapUserAlias.containsKey(pI.SubmittedById))? mapUserAlias.get(pI.SubmittedById) : '';
           strAccId = (!mapAccReq.isEmpty() && mapAccReq.containsKey(pI.TargetObjectId) && mapAccReq.get(pI.TargetObjectId)!=null)? mapAccReq.get(pI.TargetObjectId).Advertiser_Agency_Rep_Firm__c : null;
           strAccName = (!mapAccReq.isEmpty() && mapAccReq.containsKey(pI.TargetObjectId)  && mapAccReq.get(pI.TargetObjectId)!=null )? mapAccReq.get(pI.TargetObjectId).Advertiser_Agency_Rep_Firm__r.Name : '';
           strAcctExecutiveId = (!mapAccReq.isEmpty() && mapAccReq.containsKey(pI.TargetObjectId)  && mapAccReq.get(pI.TargetObjectId)!=null )? mapAccReq.get(pI.TargetObjectId).Account_Executive__c : '';
           strAcctExecutive = (!mapAccReq.isEmpty() && mapAccReq.containsKey(pI.TargetObjectId)  && mapAccReq.get(pI.TargetObjectId)!=null )? mapAccReq.get(pI.TargetObjectId).Account_Executive__r.Name : '';
           strStatus =  (!mapAccReq.isEmpty() && mapAccReq.containsKey(pI.TargetObjectId)  && mapAccReq.get(pI.TargetObjectId)!=null )? mapAccReq.get(pI.TargetObjectId).Status__c : '';
           strNetAmt = (!mapAccReq.isEmpty() && mapAccReq.containsKey(pI.TargetObjectId)  && mapAccReq.get(pI.TargetObjectId)!=null )? mapAccReq.get(pI.TargetObjectId).Adjustment_Amount_Net_1__c : 0.0;
           strDept = (!mapAccReq.isEmpty() && mapAccReq.containsKey(pI.TargetObjectId)  && mapAccReq.get(pI.TargetObjectId)!=null )? mapAccReq.get(pI.TargetObjectId).Department_Responsible__c : '';
           strReason = (!mapAccReq.isEmpty() && mapAccReq.containsKey(pI.TargetObjectId)  && mapAccReq.get(pI.TargetObjectId)!=null )? mapAccReq.get(pI.TargetObjectId).Reasons__c : '';
           //SRSF-3667:Moved to inside block to avoid showing other objects pending approvals on UI
           approvalResult.approvals.add(new ApprovalHistoryWrap(pI.CreatedDate, strActorName, pI.targetObjectId,pI.SubmittedBy.Name,pI.TargetObject.Name,pI.SubmittedById,sObjectName,strRecordType,strSobjLbl,strAccId,strAccName,strAcctExecutiveId,strAcctExecutive, strStatus,strNetAmt,strDept,strReason)); 

        } 
        
        else if (!mapTradeReq.isEmpty() && mapTradeReq.containsKey(pI.TargetObjectId)) 
        {
           strRecordType = (!mapTradeRT.isEmpty() && mapTradeRT.containsKey(pI.TargetObjectId) && mapTradeRT.get(pI.TargetObjectId)!=null)? mapTradeRT.get(pI.TargetObjectId) : null;
           strSobjLbl = pI.TargetObjectId.getSObjectType().getDescribe().getLabel();            
           strActorName = (!mapUserAlias.isEmpty() && mapUserAlias.containsKey(pI.SubmittedById))? mapUserAlias.get(pI.SubmittedById) : '';
           strAccId = (!mapTradeReq.isEmpty() && mapTradeReq.containsKey(pI.TargetObjectId) && mapTradeReq.get(pI.TargetObjectId)!=null)? mapTradeReq.get(pI.TargetObjectId).Account__c : null;
           strAccName = (!mapTradeReq.isEmpty() && mapTradeReq.containsKey(pI.TargetObjectId)  && mapTradeReq.get(pI.TargetObjectId)!=null )? mapTradeReq.get(pI.TargetObjectId).Account__r.Name : '';        
           strStatus =  (!mapTradeReq.isEmpty() && mapTradeReq.containsKey(pI.TargetObjectId)  && mapTradeReq.get(pI.TargetObjectId)!=null )? mapTradeReq.get(pI.TargetObjectId).Status__c : '';
          //SRSF-3667:Moved to inside block to avoid showing other objects pending approvals on UI
          approvalResult.approvals.add(new ApprovalHistoryWrap(pI.CreatedDate, strActorName, pI.targetObjectId,pI.SubmittedBy.Name,pI.TargetObject.Name,pI.SubmittedById,sObjectName,strRecordType,strSobjLbl,strAccId,strAccName,strAcctExecutiveId,strAcctExecutive, strStatus, null, null, null));           
        }   
        // END : SRSF-3392      

        //Start : SRSF-3762
        if(!mapATSReq.isEmpty() && mapATSReq.containsKey(pI.TargetObjectId)) 
        {          
           strSobjLbl = pI.TargetObjectId.getSObjectType().getDescribe().getLabel();            
           strActorName = (!mapUserAlias.isEmpty() && mapUserAlias.containsKey(pI.SubmittedById))? mapUserAlias.get(pI.SubmittedById) : '';
           strStatus =  (!mapATSReq.isEmpty() && mapATSReq.containsKey(pI.TargetObjectId)  && mapATSReq.get(pI.TargetObjectId)!=null )? mapATSReq.get(pI.TargetObjectId).Status__c : '';         
           approvalResult.approvals.add(new ApprovalHistoryWrap(pI.CreatedDate, strActorName, pI.targetObjectId,pI.SubmittedBy.Name,pI.TargetObject.Name,pI.SubmittedById,sObjectName,strRecordType,strSobjLbl,strAccId,strAccName,strAcctExecutiveId,strAcctExecutive, strStatus,null, null, null));
        }  
        //End : SRSF-3762  

        //Start : SRSF-3844               
        if(!mapASMReq.isEmpty() && mapASMReq.containsKey(pI.TargetObjectId) && profileLst.contains(usrProfile)) 
        {          
           strSobjLbl = pI.TargetObjectId.getSObjectType().getDescribe().getLabel();            
           strActorName = (!mapUserAlias.isEmpty() && mapUserAlias.containsKey(pI.SubmittedById))? mapUserAlias.get(pI.SubmittedById) : '';             
           strAccId = (!mapASMReq.isEmpty() && mapASMReq.containsKey(pI.TargetObjectId) && mapASMReq.get(pI.TargetObjectId)!=null)? mapASMReq.get(pI.TargetObjectId).Account__c : null;
           strAccName = (!mapASMReq.isEmpty() && mapASMReq.containsKey(pI.TargetObjectId)  && mapASMReq.get(pI.TargetObjectId)!=null )? mapASMReq.get(pI.TargetObjectId).Account__r.Name : '';      
           approvalResult.approvals.add(new ApprovalHistoryWrap(pI.CreatedDate, strActorName, pI.targetObjectId,pI.SubmittedBy.Name,pI.TargetObject.Name,pI.SubmittedById,sObjectName,strRecordType,strSobjLbl,strAccId,strAccName,strAcctExecutiveId,strAcctExecutive, strStatus,null, null, null));
        }  
        //End : SRSF-3844 
      }       
      System.debug('approvalResult>>>>>'+approvalResult);  
      return approvalResult;  
   }

    
   /*
    * @Description          : This method queries the User and Its Alias 
    * @Returns              : Map of all processinstance related to the record id  
   */
    public static Map<String,String> getUserAlias(Set<String> setUserId){
        Map<String,String> mapUserIdToAlias = new Map<String,String>();
        for(User objUser : [SELECT Id,Name, Alias FROM User WHERE Id IN : setUserId]){
            mapUserIdToAlias.put(objUser.Id, objUser.Name);
        }
        return mapUserIdToAlias;
    }

    
    /*
    * @Description          : This method queries the processinstance and workitem for the record 
    * @Returns              : Map of all processinstance related to the record id  
   */
    // SRSF-4025: Added Adjustment_Amount_Net_1__c, Department_Responsible__c, Reasons__c
    public static Map<String,Account_Request__c> getAssociatedAccount(Set<String> setTargetObjId){
        Map<String,Account_Request__c> mapAccReq = new Map<String,Account_Request__c>();
        for(Account_Request__c objAR : [SELECT Id,Advertiser_Agency_Rep_Firm__c,RecordType.Name, Advertiser_Agency_Rep_Firm__r.Name,Account_Executive__c,Account_Executive__r.Name,Status__c, Adjustment_Amount_Net_1__c, Department_Responsible__c, Reasons__c FROM Account_Request__c WHERE Id IN : setTargetObjId]){
            mapAccReq.put(objAR.Id, objAR);
        }
        return mapAccReq;
    }    

    
    /*
    * @Description          : This method returns AccountRequest related recordtype
    * @Returns              : Map of all AccountRequest related recordtype  
   */
    public static Map<String,String> getAssociatedAccountRequestRT( Map<String,Account_Request__c> mapAR){
        Map<String,String> mapAccReqRT = new Map<String,String>();
        for( Account_Request__c objAR : mapAR.values()){
            mapAccReqRT.put(objAR.Id, objAR.Recordtype.Name);
        }
        return mapAccReqRT;
    }

    // START : SRSF-3392
    
    public static Map<String,Trade__c> getAssociatedTrade(Set<String> setTargetObjId){
        Map<String,Trade__c> mapTradeReq = new Map<String,Trade__c>();
        for(Trade__c objTr : [SELECT Id,Account__c, Account__r.Name, Status__c, RecordType.Name FROM Trade__c WHERE Id IN : setTargetObjId]){
            mapTradeReq.put(objTr.Id, objTr);
        }
        return mapTradeReq;
    }    


    /*
    * @Description          : This method returns Trade related recordtype
    * @Returns              : Map of all Trade related recordtype  
   */
    public static Map<String,String> getAssociatedTradeRT( Map<String,Trade__c> mapTrade){
        Map<String,String> mapTradeRT = new Map<String,String>();
        for( Trade__c objTrade : mapTrade.values()){
            mapTradeRT.put(objTrade.Id, objTrade.Recordtype.Name);
        }
        return mapTradeRT;
    }

    // END : SRSF-3392

    //SRSF-3762 : Added below method 
    public static Map<String,Account_Transfer_Tool__c> getAssociatedATS(Set<String> setTargetObjId){
        Map<String,Account_Transfer_Tool__c> mapATSReq = new Map<String,Account_Transfer_Tool__c>();
        for(Account_Transfer_Tool__c objATS : [SELECT Id, Status__c FROM Account_Transfer_Tool__c WHERE Id IN : setTargetObjId]){
            mapATSReq.put(objATS.Id, objATS);
        }
        return mapATSReq;
    }   
     

    //SRSF-SRSF-3844 : Added below method 
    public static Map<String,Account_SAM_Mapping__c> getAssociatedASM(Set<String> setTargetObjId){
        Map<String,Account_SAM_Mapping__c> mapASMReq = new Map<String,Account_SAM_Mapping__c>();
        for(Account_SAM_Mapping__c objASM : [SELECT Id, Account__c, Account__r.Name FROM Account_SAM_Mapping__c WHERE Id IN : setTargetObjId]){
            mapASMReq.put(objASM.Id, objASM); 
        }
        return mapASMReq;
    } 
    
    /*
    * @Description          : This method queries the processinstance and workitem for the record 
    * @Returns              : Map of all processinstance related to the record id  
   */ 
   @AuraEnabled  
   public static Map<Id,ProcessInstance> getProcessHistory()  
   { 
        return new Map<Id,ProcessInstance>([SELECT Id, ProcessDefinitionId, Status, SubmittedBy.Name, SubmittedById, TargetObjectId,TargetObject.Name,CreatedDate FROM ProcessInstance WHERE Status='Pending' AND Id IN (SELECT ProcessInstanceId FROM ProcessInstanceWorkItem WHERE ActorId =:UserInfo.getUserId()) ORDER BY CreatedDate DESC]);
   } 

    /*  
    * Wrapper class  
    */  
   public class ApprovalHistoryWrap  
   {  
     @AuraEnabled  
     public Date createdDate {get;set;}//Record Creation Date  
     @AuraEnabled  
     public String actorName {get;set;}//Recent Approver  
     @AuraEnabled  
     public String targetObjectId {get;set;}//Target Object Id   
     @AuraEnabled  
     public String assignedTo {get;set;}//To Assigned User 
     @AuraEnabled  
     public String targetObjectName {get;set;}//Target Object Name 
     @AuraEnabled  
     public String assignedId {get;set;}//Assigned User 
     @AuraEnabled  
     public String sObjectName {get;set;}//Holds Object Name
     @AuraEnabled  
     public Boolean isVisible {get;set;}//Rendering for Popup 
     @AuraEnabled  
     public String RecordTypeName {get;set;}//Holds RecordType Name
     @AuraEnabled  
     public String sObjectLabel {get;set;}//Holds Object Label
     @AuraEnabled  
     public String strAccountId {get;set;}//Associated AccountId
     @AuraEnabled  
     public String strAccountName {get;set;}//Associated AccountName

     // START : SRSF-3392
     @AuraEnabled  
     public String strAcctExecutiveId {get;set;}//Associated Account's AE Id
     @AuraEnabled  
     public String strAcctExecutive {get;set;}//Associated Account's AE Name
     @AuraEnabled  
     public String strStatus {get;set;}//Associated Status
     // END : SRSF-3392  

     // START : SRSF-4025
     @AuraEnabled  
     public Decimal strNetAmt {get;set;}//
     @AuraEnabled  
     public String strDept {get;set;}//
     @AuraEnabled  
     public String strReason {get;set;}//
     // END : SRSF-4025  

     public ApprovalHistoryWrap(DateTime crDate, String name, String TargetObjId, String actor,String targetObjName,String actorId,String sObjName,String RecType, String sObjLabel, String accId, String accName, String acctExecId, String acctExecutive, String status, Decimal netAmt, String dept, String reason)  // SRSF-3392 : Added last 3 parameters
     {  
       createdDate = crDate.date();  
       actorName = name;  
       targetObjectId = TargetObjId;  
       assignedTo = actor;       
       targetObjectName = targetObjName; 
       assignedId = actorId;
       sObjectName = sObjName;
       isVisible = true;
       RecordTypeName = RecType;
       sObjectLabel = sObjLabel;
       strAccountId = accId;
       strAccountName = accName; 
       strAcctExecutiveId = acctExecId;  // SRSF-3392
       strAcctExecutive = acctExecutive; // SRSF-3392  
       strStatus = status;               // SRSF-3392
       strNetAmt = netAmt;  // SRSF-4025
       strDept = dept; // SRSF-4025  
       strReason = reason; // SRSF-4025
     }  
   } 

   /*  
    * Wrapper class  
    */  
   public class ApprovalList  
   {   
     @AuraEnabled  
     public List<ApprovalHistoryWrap> approvals {get;set;}  

     public ApprovalList(){  
       approvals = new List<ApprovalHistoryWrap>();  
     }  
   }


   /*
    * @Description          : This method queries the ProcessInstanceWorkitem and update the status
    * @Parameters           : Status,ObjectId,Comment,User
    * @Returns              : Void 
   */
   @AuraEnabled 
   public static String UpdateStatus(String status,String ids,String comment,Id User)
   {
       String strResult='';       
       System.debug('inn User'+User);
       List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
       List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :ids AND ActorId=:UserInfo.getUserId()]; // SRSF-3881 : Added ActorId filter
       List<ProcessInstanceWorkitem> workItemsUpdate = new List<ProcessInstanceWorkitem>();
       try{
           System.debug('workItems==>'+workItems);
            for(ProcessInstanceWorkitem workItem : workItems)
            {
                if(status == 'Reassigned'){                
                   workItem.ActorId = User;
                   workItemsUpdate.add(workItem);
                }else{
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setWorkitemId(workItem.Id);
                    //Valid values are: Approve, Reject, or Removed. 
                    //Only system administrators can specify Removed.
                    System.debug('workItem Id>>>>'+workItem.Id);
                    if(status == 'Approved')
                        req.setAction('Approve');
                    else if(status == 'Rejected')
                        req.setAction('Reject');
                    if(comment !='')
                        req.setComments(comment);
                    requests.add(req);
                    Approval.ProcessResult[] processResults = Approval.process(requests);
                }
            }
            if(!workItemsUpdate.isEmpty()) 
                UPDATE workItemsUpdate;
       }catch(Exception ex){
           strResult+='Error in Updating Status! Error details:' + ex.getMessage();
       }
       return strResult;
   }    
}