/*
###########################################################################
# File..................: AccountBulkMergeController.cls
# Version...............: 1
# Created by............: Ankit Bhatia  
# Created Date..........: 19-Sep-2017
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This class is created for BULK Account Merge
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/

public with sharing class AccountBulkMergeController {

    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT ID,Child_Account__r.Name, Parent_Account__r.Name FROM Account_Bulk_Merge__c where Child_Account__c != null order by createdDate desc]));
            }
            return setCon;
        }
        set;
    }

    // Initialize setCon and return a list of records
    public List<Account_Bulk_Merge__c> getBulkAccountMerge() {
        return (List<Account_Bulk_Merge__c>) setCon.getRecords();
    }
    //Default Constructor with Standard Controller
    public AccountBulkMergeController(ApexPages.StandardSetController cntrl)
    {
    	//cntrl.setPageSize(10);
    	
    }
    public AccountBulkMergeController()
    {
    	//cntrl.setPageSize(10);
    	
    }
    public void batchExecute()
    {
    	AccountBulkMerge abm = new AccountBulkMerge();
    	Database.executeBatch(abm,Integer.valueOf(System.Label.AccountMergeBatchSize));
    }
    
}