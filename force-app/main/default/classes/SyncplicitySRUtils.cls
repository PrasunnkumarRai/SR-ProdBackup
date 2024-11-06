public with sharing class SyncplicitySRUtils {
    public SyncplicitySRUtils() {

    }

//    @future (callout=true)
    public static void CreateSyncplicityFolders(List<Id> Ids) {
        try {
            // SRB-1138  -- start
            if (Ids.size() == 1) {
                Syncplicity.SyncplicityFolderCreationAsync.createObjectFolderForRecordId(Ids[0]);
            }
            else if(Ids.size() > 1) {
                if(!Test.isRunningTest()) {
                            Id syncfldrInstanceId = Database.executeBatch(new createSyncRecBatch(Ids),1);
                }
            }
            // SRB-1138  -- end

        }
        catch (Exception e) {
            System.debug(e);
        }
       /* for(Id id : Ids) {
            Syncplicity.SyncplicityFolderCreationAsync.createObjectFolderForRecordId(id); //async
            //Syncplicity.SyncplicityFolderCreationSync.createObjectFolderForRecordId(id); //sync
        } */
    }
}