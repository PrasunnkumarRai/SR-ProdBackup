public with sharing class MassApprovalForInterimAEsController {

    @AuraEnabled
	public static List<Interim_AE_Account__c> getInterimAEAccountsList() 
	{
		
		Set<Id> targetObjIds = new Set<Id>();
		List<Interim_AE_Account__c> interimAEAccs;		

		List<ProcessInstance> processInst = [SELECT Id, Status, TargetObjectId 
		   FROM ProcessInstance WHERE Status='Pending' AND Id IN (SELECT ProcessInstanceId FROM ProcessInstanceWorkItem WHERE ActorId =:UserInfo.getUserId()) AND TargetObject.Type = 'Interim_AE_Account__c'];

		if(!CommonUtilities.isListNullOrEmpty(processInst))
		{   
			for (ProcessInstance ps : processInst){
				targetObjIds.add(ps.TargetObjectId);
			}
			System.debug('inside getInterimAEAccountsList>>>>>>>>'+targetObjIds); 
			
			interimAEAccs =[SELECT Id, Name, Account__c, Account__r.Name, Primary_AE__r.Name,Interim_AE__r.Name, InitiatedBy__r.Name, StartDate__c, EndDate__c FROM Interim_AE_Account__c WHERE Id IN :targetObjIds];			
		}
		
		return interimAEAccs;		  	 
	}

	@AuraEnabled
	public static void processApprovalRequest(Map<String, String> interimRecs, Boolean isApproved) 
	{
		System.debug('Records to be Processed>>>>'+interimRecs);
		
		String loginUser = UserInfo.getUserId();

		Map<Id, String> processInstMap = new Map<Id, String>();
		List<Approval.ProcessWorkItemRequest> requests = new List<Approval.ProcessWorkitemRequest>();

		List<ProcessInstanceWorkitem> recsToProcess = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :interimRecs.keySet()];
		System.debug('recsToProcess>>>>'+recsToProcess);
		
		try{
			for(ProcessInstanceWorkitem item :  recsToProcess)
	        {
	        	processInstMap.put(item.ProcessInstanceId, interimRecs.get(item.ProcessInstance.TargetObjectId));   
	        }

			if(processInstMap.size() > 0)
			{
				String status = isApproved ? 'Approve' : 'Reject' ;
				List<ProcessInstanceWorkitem> workItemList = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId IN :processInstMap.keySet()];

				for(ProcessInstanceWorkitem workItem : workItemList)
				{
					Approval.ProcessWorkItemRequest request = new Approval.ProcessWorkItemRequest();
		            request.setWorkitemId(workItem.Id);
		            request.setAction(status);
		            request.setComments(processInstMap.get(workItem.ProcessInstanceId));
		            requests.add(request);
				}
			}

			System.debug('ApprovalRequest process results--->'+requests);
			if(requests.size() > 0)
			{
				// TODO : Uncomment before handover to client for testing
				Approval.ProcessResult[] processResults = Approval.process(requests);
			}
		} catch(Exception ex) {    
            String msg = ex.getMessage() + ' at Line no : ' + ex.getLineNumber();
            System.debug(msg);        
            Log4SF.logMessage('MassApprovalForInterimAEsController', 'MassApprove Interim AEs', msg, ex, loginUser,'NA');
            AuraHandledException auraEx = new AuraHandledException(msg);
	        auraEx.setMessage(msg);
	        throw auraEx;  
        }
	}
}