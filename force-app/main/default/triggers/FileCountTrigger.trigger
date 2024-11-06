trigger FileCountTrigger on ContentDocumentLink (after insert, before delete, after undelete ) {
   /* Set<Id> parentRecordIds = new Set<Id>();

    if (Trigger.isInsert || Trigger.isUndelete) {
        for (ContentDocumentLink cdl : Trigger.new) {
            parentRecordIds.add(cdl.LinkedEntityId);
        }
    }

    if (Trigger.isDelete) {
        for (ContentDocumentLink cdl : Trigger.old) {
            parentRecordIds.add(cdl.LinkedEntityId);
        }
    }

    if (!parentRecordIds.isEmpty()) {
        //FileCountUpdater.updateFileCount(parentRecordIds);
    }*/
 
    if(Trigger.isInsert && Trigger.isAfter) {
      FileCountUpdater.updateFileCount(Trigger.New);
    }
     
    
   

}