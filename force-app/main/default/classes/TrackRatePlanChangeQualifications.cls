global class TrackRatePlanChangeQualifications implements Database.Batchable<sObject> ,Database.Stateful{
	
    global String query;
    global Set<Id> budgetUserProcessed = new Set<Id>();
	global Set<Id> userIDs = new Set<Id>();
	public TrackRatePlanChangeQualifications(string query, Set<ID> userIDs)
	{
		this.query = query;
		this.userIds = userIDs;
	}
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
    	List<String> rpStatus = new List<String>{'Draft','Committed'}; 
		System.debug('qry ' + query);
		System.debug('userIds ' + userIds); 	
		if(String.isBlank(query))
    		query = 'select id,rate_plan_status__c,Rate_Plan_Commit_Date__c from User where rate_plan_status__c in: rpStatus';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<User> scope) {
    	Decimal originalBudget = 0;
    	Decimal newBudget = 0;
    	List<Sales_Budget__c> sbList = new List<Sales_Budget__c>(); 
		List<User> userList = new List<User>();
		System.debug('Batch job count: ' + scope.size());
		try{
			for(User job:scope){		        
	        	if(!budgetUserProcessed.contains(job.id)){     
					budgetUserProcessed.add(job.id);
		        	sbList = [select amount__c,old_budget_user__c,budget_user__c,Transfer_Date__c,budget_user__r.Rate_Plan_Commit_Date__c
	        				  from Sales_Budget__c 
	        				  where (budget_user__c =: job.id or old_budget_user__c =: job.id) and ((Type__c = 'Data' and (Product_Line__c != 'New Business' AND Product_Line__c != 'Unknown Churn')) OR Type__c = 'DOS')];
		        	
		        	System.debug('Batch Sales_Budget__c count: ' + sbList.size());
		        	
		            for(Sales_Budget__c sb: sbList){
		            	System.debug('sb.budget_user__c: ' + sb.budget_user__c);
		            	System.debug('sb.old_budget_user__c: ' + sb.old_budget_user__c);
		            	System.debug('job.id: ' + job.id);
		            	if(sb.budget_user__r.Rate_Plan_Commit_Date__c == null || (sb.Transfer_Date__c > sb.budget_user__r.Rate_Plan_Commit_Date__c && job.rate_plan_status__c == 'Committed')) //Added the logic for comparing the transfer date with last commit date, So that only transfers which occured after last commit are considered for the compensation change.
		            	{
		            		if((sb.budget_user__c == job.id && sb.old_budget_user__c == null) || sb.old_budget_user__c == job.id){
								originalBudget = originalBudget + sb.amount__c;
		            		}
							newBudget =  newBudget + sb.amount__c;
		            	}
		            }
		            
		            Decimal budgetDiffAmount =  math.abs(originalBudget-newBudget);
		            Decimal budgetDiffPercent = 0;
		            if(originalBudget>0){
	            		budgetDiffPercent =  math.abs(100 * ((newBudget - originalBudget) / originalBudget));
		            }
		            
		            System.debug('budgetDiffAmount: ' + budgetDiffAmount);
		            if(budgetDiffAmount >= Decimal.valueOf(Label.RatePlanThresholdAmount) || budgetDiffPercent >= Decimal.valueOf(Label.RatePlanThresholdPercent)){
	        			job.rate_plan_status__c = 'Pending';
	        			userList.add(job);
		            }
	        	}		        
			}
			
			if(userList.size()>0){
				update userList;
			}
		}
        catch(Exception ex){
        	Log4SF.logMessage('TrackRatePlanChangeQualifications', 'execute', ex.getMessage(),ex, UserInfo.getUserId(),BC.getJobID(),'');
            System.debug('Error while updating Track Rate Plan Change Qualifications: ' + ex.getMessage());
        }
    }

    global void finish(Database.BatchableContext BC) {
    	String subject = 'Rate Plan Change Qualifications tracking batch completed: ' + BC.getJobId();
    	String body = 'Batch completion timestamp: ' + System.DateTime.Now().format();
    	EmailHelper.sendEmailToUser(UserUtils.bIntegrationUserId, subject, body);
    	
    	/*
    	TrackRatePlanChangeQualifications trpcq = new TrackRatePlanChangeQualifications();
		Database.executeBatch(trpcq, 200);
		*/
    }
}