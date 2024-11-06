public with sharing class ProposalQueueSyncController {
	
	public List<Proposal__c> proposalList = new List<Proposal__c>();
	public String oppId;
	public String successPageMsg{get;set;}
	public String rejectPageMsg{get;set;}
	
    /* Constructor for the controller class. */ 
    public ProposalQueueSyncController(ApexPages.StandardSetController controller){
    	oppId = ApexPages.currentPage().getParameters().get('Id');
    	//Query all related proposals for syncing
    	proposalList = [SELECT Id, Sync_Pending__c, Opportunity__r.OwnerId, Opportunity__r.Owner.Name,TIM_Id__c,TIM_System__c
                        FROM Proposal__c 
                        WHERE Opportunity__c = : oppId AND RecordType.Name != 'Opportunity Budget'];
    }
    
    /*Mark all related Proposals for Sync*/
    public PageReference execute(){    	
    	
    	//If related proposals are more than 10, queue for sync asynchronously
    	if(proposalList.size() > 10){
    		for(Proposal__c p: proposalList){
	    		p.Sync_Pending__c = true;
	    	}
    		try{
    			update proposalList;
    		}
    		catch(Exception ex){
    			successPageMsg = '';
	        	rejectPageMsg = 'An error occured while performing sync, please contact your system administrator.';
	        	Log4SF.logMessage('ProposalQueueSyncController', 'execute', 'Exception in asyncProcessing',ex, UserInfo.getUserId(),oppId);
    		}
    		
    		successPageMsg = 'Number of Proposals are more than 10, your request for syncing has been queued.';
    	}
    	
    	//If related proposals are less than equal to 10, sync in real time
    	else if(proposalList.size() > 0){    		
			/*Get the Opportunity AE User Connections*/
	        List<UserConnection__c> oppAE = [SELECT AE_Id__c, TIM_System__c
						                     FROM UserConnection__c
						                     WHERE User__c=:proposalList[0].Opportunity__r.OwnerId AND AE_Id__c != null AND Is_Primary__c = true];
            System.debug('oppAE: '+oppAE);
	        Set <Id> propSet = new Set<Id>();
			if(oppAE.size() > 0){
				//Sync all related proposals individually
				/* Comment this block : SRSF-2429
                for(Proposal__c p: proposalList){
			        syncProposalFuture(p.id,oppAE[0].id);
				}*/
                for(Proposal__c p: proposalList){
                    propSet.add(p.Id);
                }
                syncProposalFuture(propSet,oppAE[0].Id);
		    }
		    else{
		    	successPageMsg = '';
	        	rejectPageMsg = 'User Connection for Opportunity Owner not found, sync cannot be completed!';
		    }		    
		    successPageMsg = 'Proposal sync scheduled successfully!';			
    	}
    	//If related proposals are less than equal to 10, sync in real time
    	else if(proposalList.size() == 0){
    		successPageMsg = '';
        	rejectPageMsg = 'No TIM Proposals found for syncing, please use Proposal New Sync for syncing new proposals.';
        	return null;
    	}     	
    	rejectPageMsg = '';
    	return null;
    }
    
    /*Navigate back to Opportunity*/
    public PageReference backToOpp(){ 
    	return new PageReference('/'+oppId);	
    }
    
    // Commented this method : SRSF-2429
    /*
    @Future(Callout=true)
    public static void syncProposalFuture(Id pId, Id aeId){ 
    	BoomiWebServiceHelper bws = new BoomiWebServiceHelper();       
		Proposal__c p = [SELECT Id, Sync_Pending__c, Opportunity__r.OwnerId, Opportunity__r.Owner.Name,TIM_Id__c,TIM_System__c
                         FROM Proposal__c 
                         WHERE Id =: pId];
                         
		UserConnection__c oppAE = [SELECT AE_Id__c, TIM_System__c
			                       FROM UserConnection__c
			                       WHERE Id =: aeId];
		String returnValue = bws.syncProposalLineItems(p,oppAE);			
    }*/

    @Future(Callout=true)
    public static void syncProposalFuture(Set<Id> propIdSet, Id aeId)
    { 
        System.debug('Inside syncProposalFuture_New method');
        BoomiWebServiceHelper bws = new BoomiWebServiceHelper(); 
        // Store Updated proposal data response received from TIM in map to make DML statements after each proposal API call
        Map<Id, String> syncProposalsData =  new Map<Id, String>(); 
        Map<Id, Proposal__c> propList = new Map<Id, Proposal__c>([SELECT Id, Advertiser__c, Sync_Pending__c, Opportunity__r.OwnerId, Opportunity__r.Owner.Name,TIM_Id__c,TIM_System__c
                         FROM Proposal__c WHERE Id IN : propIdSet]);
        UserConnection__c oppAE = [SELECT AE_Id__c, TIM_System__c, User__c
                                   FROM UserConnection__c
                                   WHERE Id =: aeId]; 
        String response = bws.syncProposal_authenticateAE(oppAE);
        System.debug('response:::'+response);
        String accessToken = response.split('_')[1];
        String boomiServer = response.split('_')[0]; 
        if(!accessToken.equalsIgnoreCase(Label.ErrorWhileAuthenticatewithTim) && !accessToken.contains('Error')) 
        {                                                                
            for (Proposal__c p : propList.values())
            {
               bws.syncAllProposals(p,accessToken, boomiServer, syncProposalsData);  
            }    
        } 
        // update proposals in SF from the response received through API call
        if(syncProposalsData.size()>0)
        {
            bws.updateProposals(syncProposalsData, propList, oppAE);
        }         
    }
}