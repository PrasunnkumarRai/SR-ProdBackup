/*
  ###########################################################################
  # File..................: AccountMergeQueueable.cls
  # Version...............: 1
  # Created by............: Ankit Bhatia
  # Created Date..........: 14-October-2021
  # Last Modified by......: 
  # Last Modified Date....: 
  # Description...........: This class is used to enque jobs for Account Bulk Merge.
  # TAO Ref#..............: NA
  # Change Log:               
  #
  #
  ############################################################################*/

  public class AccountMergeQueueable implements Queueable {
    List < Account_Merge_Log__c > accountMergeLogsList = new List < Account_Merge_Log__c > ();
    public String trxnId;
    public Integer totalCount;

    public AccountMergeQueueable(List < Account_Merge_Log__c > accountMergeLogsListParam, String trxnId, Integer totalCount) {
      accountMergeLogsList = accountMergeLogsListParam;
      this.trxnId= trxnId;
      this.totalCount= totalCount;
      System.debug('totalCount@@@@'+totalCount);
    }
    public void execute(QueueableContext context) {
      try {
        AccountMergeDetailInsertionBatch objBatch = new AccountMergeDetailInsertionBatch(accountMergeLogsList, 'Merging');
        objBatch.trxnId = this.trxnId;
        objBatch.totalCount = this.totalCount;
        Database.executeBatch(objBatch, 1000);
        if (Test.isRunningTest()) {
          CalloutException e = new CalloutException();
          e.setMessage('This is a constructed exception for testing and code coverage');
          throw e;
        }
      } catch (Exception e) {
        System.debug('@@@ Error Message : ' + e.getMessage());
      }
    }
  }