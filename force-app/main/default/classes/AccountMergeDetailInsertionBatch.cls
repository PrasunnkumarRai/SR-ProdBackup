global class AccountMergeDetailInsertionBatch implements Database.Batchable < Account_Merge_Detail__c > {
    List < Account_Merge_Detail__c > accMergeDetailList = new List < Account_Merge_Detail__c > ();
    List < Account_Merge_Log__c > accmDLog;
    public String mergingType;
    Map < String, String > mergeDetailsObjectCounts = new Map < String, String > ();
    String Exception_Message {
      get;
      set;
    }
    public String trxnId;
    public Integer totalCount;
    global AccountMergeDetailInsertionBatch(List < Account_Merge_Log__c > accmD, String mergeType) {
      accmDLog = accmD;
      mergingType = mergeType;
      System.debug('accmDLog ' + accmDLog);
      Exception_Message = System.Label.Exception_Message_For_Code_Coverage_and_Testing;
    }
  
    /**
     * @description gets invoked when the batch job starts
     * @param context contains the job ID
     * @returns the record set as a QueryLocator object that will be batched for execution
     */
    global Iterable < Account_Merge_Detail__c > start(Database.BatchableContext context) {
      system.debug(accmDLog);
      return new AccountMergeUpdate(accmDLog);
    }
  
    /**
     * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
     * @param context contains the job ID
     * @param scope contains the batch of records to process.
     */
    global void execute(Database.BatchableContext context, List < Account_Merge_Detail__c > scope) {
      insert scope;
    }
  
    /**
     * @description gets invoked when the batch job finishes. Place any clean up code in this method.
     * @param context contains the job ID
     */
    global void finish(Database.BatchableContext context) {
    	System.debug('trxnId@@@@'+trxnId);
        System.debug('totalCount@@@@'+totalCount);
      	try {
        	for (Account_Merge_Log__c acMLog: accmDLog) {
            	system.debug('@@accmDLog: '+accmDLog);
          		AccountMergeUpdate.mergeAccounts(acMLog.Id, acMLog.Account__c, acMLog.Merged_Account_ID__c, mergingType);
          		System.debug('Standard Merge initiated from AccountMergeDetailInsertionBatch...!');
        	}
          
            if (mergingType == 'Merging') {
                List<AggregateResult> result = [SELECT Count(Id) isMergedTriedCount FROM Account_Merge_Log__c WHERE TransactionId__c =: trxnId AND isMergeTried__c = true];
                Integer isMergedTriedCount = (Integer)result[0].get('isMergedTriedCount');
                System.debug('isMergedTriedCount@@@@'+isMergedTriedCount);
                if (isMergedTriedCount == totalCount) {
                    System.debug('shoot email');
                    
                    if (!Test.isRunningTest()) {
                        AccountMergeRetryAndEmailBatch b = new AccountMergeRetryAndEmailBatch(trxnId);
                        Database.executeBatch(b,1);
                        
                    	TierUpdateAfterMerge batch = new TierUpdateAfterMerge(trxnId);
                    	Database.executeBatch(batch);
                    }
                    
                }
         
          	}
            else {
                System.debug('Single merge');
            }

        
      	} 
        catch (Exception ex) {
        	Log4SF.logMessage('AccountMergeDetailInsertionBatch', 'finish', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
  
      	}
    }

  }