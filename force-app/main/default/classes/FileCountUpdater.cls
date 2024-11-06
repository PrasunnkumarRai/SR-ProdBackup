public class FileCountUpdater {

   /* public static void updateFileCount(Set<Id> parentRecordIds) {
        try {
            // Get the count of files related to parent record
            List<AggregateResult> fileCounts = [SELECT LinkedEntityId, COUNT(Id) fileCount
                                                FROM ContentDocumentLink
                                                WHERE LinkedEntityId IN :parentRecordIds
                                                GROUP BY LinkedEntityId];

            // Map to store the count of files for each parent record
            Map<Id, Integer> fileCountMap = new Map<Id, Integer>();
            for (AggregateResult ar : fileCounts) {
                fileCountMap.put((Id)ar.get('LinkedEntityId'), (Integer)ar.get('fileCount'));
            }

            // List to store the parent records to be updated
            List<Account_Request__c> accountrequestsToUpdate = new List<Account_Request__c>();

            for (Id accountrequestId : parentRecordIds) {
                Integer fileCount = fileCountMap.containsKey(accountrequestId) ? fileCountMap.get(accountrequestId) : 0;
                accountrequestsToUpdate.add(new Account_Request__c(Id = accountrequestId , Count_of_Files__c = fileCount));
            }

            // Update the parent records with the new file counts
            if (!accountrequestsToUpdate.isEmpty()) {
                update accountrequestsToUpdate;
            }
        } catch (Exception e) {
            // Add appropriate error handling, e.g., logging the exception
            System.debug('Error in FileCountUpdater.updateFileCount: ' + e.getMessage());
        }
    }  */

    public static void updateFileCount(List<ContentDocumentLink> Contentdocumentlnk) {
        
        Map<Id, Integer> FileCountMap = new Map<Id, Integer>();
        
        // Iterate over the inserted ContentDocumentLinks
        for (ContentDocumentLink cdl : Contentdocumentlnk) {
            // Check if the linked record is of the custom object type
            if (cdl.LinkedEntityId != null && cdl.LinkedEntityId.getSObjectType() == Account_Request__c.SObjectType) {
                // Increment the count for this custom object
                if (FileCountMap.containsKey(cdl.LinkedEntityId)) {
                    FileCountMap.put(cdl.LinkedEntityId, FileCountMap.get(cdl.LinkedEntityId) + 1);
                } else {
                    FileCountMap.put(cdl.LinkedEntityId, 1);
                }
            }
        }
        
        
        // List to hold the custom objects to update
        List<Account_Request__c> AccRqstToUpdate = new List<Account_Request__c>();
        
        // Retrieve the existing file counts for the custom objects
        List<Account_Request__c> Accreq = [SELECT Id, Count_of_Files__c FROM Account_Request__c WHERE Id IN :FileCountMap.keySet()];
         system.debug('Accreq'+Accreq);
        
        // Update the file counts
        for (Account_Request__c Req : Accreq) {
            Decimal newFileCount = (Req.Count_of_Files__c != null ? Req.Count_of_Files__c : 0) + FileCountMap.get(Req.Id);
            Req.Count_of_Files__c = newFileCount;
            AccRqstToUpdate.add(Req);
        }
        
        // Update the custom objects
        if (!AccRqstToUpdate.isEmpty()) {
            update AccRqstToUpdate;
        }
        


}



}