global class TransferProposalBatch implements Database.Batchable<sObject> , Database.Stateful,Database.AllowsCallouts{
    public String query;
    public List<Admin_Tool_Status_Summary__c> adminToolSummary;
    public Map<String,List<String>> userProposalMap;
    public Map<String,Proposal__c> mapTimProposal;
    public Map<String,Integer> mapOfBatchsizes;
    public Set<ID> admToolSummaryIDs;
    List<UserConnection__c> userConn = new List<UserConnection__c>();
    Map<String,String> mapOfTimAEIds = new Map<String,String>();
    Map<String,UserConnection__c> mapOfUserConn = new Map<String,UserConnection__c>();
    Map<string,Map<String,UserConnection__c>> mapOfUserCons = new Map<String,Map<String,UserConnection__c>>();
    public Boolean IsRetry = false;
    
	/**
     * Batch Class Constructor
     * 
     * @param (String query) (Query to be used in batch execution)
     * @param (List<Admin_Tool_Status_Summary__c> adminToolSmry) (List of Admin Tool Summary records, contains ids of proposals to be transferred)     
     * @param (Map<String,Integer> mapOfBcthsize) (A static map containing batch size information for transfer batches)
     * @param (Set<String> userSet) (Set of user ids involved in proposal transfers)
    */
    global TransferProposalBatch(String query , List<Admin_Tool_Status_Summary__c> adminToolSmry, Map<String,Integer> mapOfBcthsize, Set<String> userSet) {
        this.query = query;
        this.adminToolSummary = adminToolSmry;
        this.userProposalMap = new Map<String,List<String>>();
        this.mapTimProposal = new Map<String,Proposal__c>();
        this.mapOfBatchsizes = mapOfBcthsize;
        this.admToolSummaryIDs = new Set<ID>();
        
        for(Admin_Tool_Status_Summary__c adminSumm : adminToolSmry){
			admToolSummaryIDs.add(adminSumm.ID);
        }
        
        userConn =  [SELECT Id,TIM_System__c,AE_Id__c,Username__c,User__c FROM UserConnection__c WHERE User__r.ID in :userSet ORDER by lastModifiedDate asc];
        for (UserConnection__c usrCon : userConn) {
			//Map of UserId+TIM System as key and User Connection as value
			mapOfUserConn.put(usrCon.User__c+usrCon.TIM_System__c,usrCon);
			
			//Map of user id as key and mapOfUserConn as value
			mapOfUserCons.put(usrCon.User__c,mapOfUserConn);
        }
        System.debug('mapOfUserConn::::'+mapOfUserConn.keySet());
    }
	
	/**
     * Batch Start Method
     * 
     * @param (Database.BatchableContext BC) (Standard Salesforcer Database.BatchableContext object)    
    */
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
	
	/**
     * Batch Execute Method
     * 
     * @param (Database.BatchableContext BC) (Standard Salesforcer Database.BatchableContext object)
     * @param (List<Admin_Tool_Status_Detail__c> scope) (Transfer records that constitutes scope of batch execution)
    */
    global void execute(Database.BatchableContext BC, List<Admin_Tool_Status_Detail__c> scope){
    	
    	Map<string,Map<String,List<Proposal__c>>> mapOfUserTimProposal = new Map<String,Map<String,List<Proposal__c>>>();
        Map<String,Admin_Tool_Status_Detail__c> proposalMap = new Map<String,Admin_Tool_Status_Detail__c>();
        Map<String,List<Proposal__c>> mapOfProposals = new Map<String,List<Proposal__c>>();        
        List<Proposal__c> proposalToUpdate = new List<Proposal__c>();
        
		try{
			//Use of this for loop is to get a Map of To User id as key and its associated list of proposal ids as value 
	        for(Admin_Tool_Status_Detail__c adminStsDet : scope){
	        	admToolSummaryIDs.add(adminStsDet.Admin_Tool_Status_Summary__r.ID);
	            //proposalMap=Map of proposal id as key and Admin_Tool_Status_Detail__c as value
	            proposalMap.put(adminStsDet.Id__c , adminStsDet);
	            
	            //userProposalMap=Map of To User id as key and its associated list of proposal ids as value
	            if(userProposalMap.containsKey(adminStsDet.Admin_Tool_Status_Summary__r.To_User_Id__c))
	            {
	                userProposalMap.get(adminStsDet.Admin_Tool_Status_Summary__r.To_User_Id__c).add(adminStsDet.Id__c);
	            }
	            else
	            {
	                userProposalMap.put(adminStsDet.Admin_Tool_Status_Summary__r.To_User_Id__c, new List<String>{adminStsDet.Id__c});
	            }
	        }
	        
	        //Query all active TIM Proposals that are part of transfer
	        Date clsDate  = Date.valueOf(scope[0].Admin_Tool_Status_Summary__r.Proposal_End_Date__c);
			System.debug('clsDate ' + clsDate);
	        List<Proposal__c> proposalData = [Select id ,Name, AE_ID__c, Active__c, Tim_ID__c,TIM_System__c,Advertiser__r.Id,End_Date__c,Advertiser__r.TIM_Account_ID__c,Current_Advertiser_Tim_Id__c,Agency__r.TIM_Account_ID__c,Current_Agency_Tim_Id__c 
	        								  from Proposal__c 
	        								  where ID in: proposalMap.keySet() AND 
		        								    Active__c = true AND 
		        								    RecordType.DeveloperName != 'Opportunity_Budget' AND 
		        								    (End_Date__c>=:clsdate OR End_Date__c=null)];
	        								  
			//Useless for loop, can be replaced by taking query's output directly in map
			for(Proposal__c prop : proposalData){
	        	mapTimProposal.put(prop.Id, prop);
	    	}
	
	        //New code to create a map of User - TIM System and all the associated proposals
	        //Create a Map of all AE's as key, and TIM System as another key with the List of their associated Proposals
	        //Map< String, Map< String, List< Proposal__c >>> mapOfUserTimProposal
	        //userProposalMap = user as key and all its associated proposals as value
	        for(string ae: userProposalMap.keySet())
	        {
	        	Map<String, List<Proposal__c>> timProposalMap = new Map<String,List<Proposal__c>>();	
	        
	        	for(String prop : userProposalMap.get(ae))
	        	{
		        	if(!mapOfUserTimProposal.containsKey(ae) && mapTimProposal.containsKey(prop))
		        	{
		        		timProposalMap.put(mapTimProposal.get(prop).Tim_System__c,new List<Proposal__c>{mapTimProposal.get(prop)});
		        		mapOfUserTimProposal.put(ae,timProposalMap);
		        	}
		        	else if(mapOfUserTimProposal.containsKey(ae) && mapTimProposal.containsKey(prop))
		        	{
		        		timProposalMap  = mapOfUserTimProposal.get(ae);
		        		
		        		if(timProposalMap.containsKey(mapTimProposal.get(prop).Tim_System__c)){
		        			timProposalMap.get(mapTimProposal.get(prop).Tim_System__c).add(mapTimProposal.get(prop));
		        		}
		        		else{
		        			timProposalMap.put(mapTimProposal.get(prop).Tim_System__c,new List<Proposal__c>{mapTimProposal.get(prop)});
		        		}
		        		
		        		mapOfUserTimProposal.put(ae,timProposalMap);
		        	}
	        	}
	        	
	        }
			
			//Verifying User Connection of the To User for the TIM System.
			for(String ae: mapOfUserTimProposal.keySet())
			{
				for(string tim : mapOfUserTimProposal.get(ae).keySet())
				{
					if(mapOfUserCons.containsKey(ae))
					{
						if(mapOfUserCons.get(ae).containsKey(ae+tim))
						{
			                //Call Boomi TIM Proposal Sync API Method(List of proposals,user connection, proposalMap)
			                proposalMap = callBoomiService(mapOfUserTimProposal.get(ae).get(tim),mapOfUserCons.get(ae).get(ae+tim),proposalMap);
			
			                for(Admin_Tool_Status_Detail__c adminStsDet: proposalMap.values()) {
			                    if(adminStsDet.Status__c == 'Success'){
			                        Proposal__c prop = new Proposal__c(Id = adminStsDet.Id__c);
			                        if(adminStsDet.Error_Message__c!=null)
			                           prop.Active__c = false;
			                        else
			                           prop.AE_ID__c = mapOfUserCons.get(ae).get(ae+tim).AE_Id__c;
			                        proposalToUpdate.add(prop);
			                    }
			                }
		            	}
		            	else
		            	{
		            		if(mapOfUserTimProposal.containsKey(ae))
		            		{
		            			if(mapOfUserTimProposal.get(ae).containsKey(tim))
				                {
					                for(Proposal__c prop : mapOfUserTimProposal.get(ae).get(tim)){
					                    proposalMap.get(prop.Id).Status__c = 'Error';
					                    proposalMap.get(prop.Id).Error_Message__c = 'No User Connection Exist for this Tim System';
					                }
				                }
		            		}
		            	}
					}
				}
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('TransferProposalBatch', 'execute-Proposal API Sync section', ex.getMessage(),ex, UserInfo.getUserId(),BC.getJobID(),'');
		}
        
        try{
            if(proposalToUpdate.size()>0)
            	update proposalToUpdate;
            
            if(proposalMap.values()!=null && proposalMap.values().size() > 0)            	
             	update proposalMap.values();
        }
		catch(Exception ex)
		{
			Log4SF.logMessage('TransferProposalBatch', 'execute-Proposal DML section', ex.getMessage(),ex, UserInfo.getUserId(),BC.getJobID(),'');
		}
    }
	
	//Batch Finish Method
    global void finish(Database.BatchableContext BC) {
    	if(IsRetry == false){
	        String query = 'Select id,Id__c , Status__c,Error_Message__c, Admin_Tool_Status_Summary__r.To_User_ID__c, Admin_Tool_Status_Summary__r.From_User_ID__c from Admin_Tool_Status_Detail__c where Object_Type__c = \'Opportunity\' and Status__c=\'Not Started\' and Admin_Tool_Status_Summary__r.Id in : admToolSummaryIDs';
	        TransferOpportunityBatch updateOppBatch = new TransferOpportunityBatch(query,adminToolSummary ,mapOfBatchsizes);
	        Id batchJobId = Database.executeBatch(updateOppBatch , mapOfBatchsizes.get('Opportunity_Batch_Size'));
    	}
    }
	
	//Proposal TIM API Sync Method
    global Map<String,Admin_Tool_Status_Detail__c> callBoomiService(List<Proposal__c> propList ,UserConnection__c userContn ,Map<String,Admin_Tool_Status_Detail__c> mapOfAdminStsDet){
		try{
	        Integer cachesize = CacheManager.checkCacheSize(userContn.TIM_System__c);
	        System.debug('Tim System Name in Batch:::'+userContn.TIM_System__c);
	        System.debug('Cache size::'+cachesize);
	        BoomiWebServiceHelper boomiSrvcHelper  = new BoomiWebServiceHelper(userContn);
	        if(cachesize<=0){
	            //CacheManager.refreshTIMCache(userContn.TIM_System__c);
	            return boomiSrvcHelper.addErrMsgToProposals(propList,mapOfAdminStsDet,Label.Cache_Error_Message);
	        }
	        else{
	            mapOfAdminStsDet = boomiSrvcHelper.editProposalAE(propList, userContn,mapOfAdminStsDet);
	            return mapOfAdminStsDet;
	        }
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('TransferProposalBatch', 'callBoomiService', ex.getMessage(),ex, UserInfo.getUserId(),'','');
			return new Map<String,Admin_Tool_Status_Detail__c>();
		}
    }

}