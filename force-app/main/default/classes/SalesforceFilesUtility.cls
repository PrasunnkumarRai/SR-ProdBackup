public with sharing class SalesforceFilesUtility {
    public SalesforceFilesUtility() {

    }
// Method created to merge the Salesforce Files 
    public static void mergeSFRecordFiles( string accMergeLogID)
    {
        List<Account_Merge_Log__c> accMergeLog = [Select ID,Account__c,Merged_Account_ID__c from Account_Merge_Log__c where ID =: accMergeLogID];
        //Get all corresponding files of corresponsind Source Object
        list<ContentDocumentLink> allCdLinks = new list<ContentDocumentLink> ();
        
        allCdLinks = [select Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility 
                                        from ContentDocumentLink 
                                        where LinkedEntityId = :accMergeLog[0].Merged_Account_ID__c];
        
        //Final List to insert file into new destination object
        list<ContentDocumentLink> allCdLinksToInsert = new list<ContentDocumentLink> ();
        
        
        for(ContentDocumentLink cdl : allCdLinks){ cdl.Id = null;
           
                cdl.LinkedEntityId = accMergeLog[0].Account__c;
           
            allCdLinksToInsert.add(cdl);
        }

        if(!allCdLinksToInsert.isEmpty()){    database.Insert(allCdLinksToInsert,false);  }
       
    }
}