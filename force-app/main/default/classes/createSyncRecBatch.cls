global class createSyncRecBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    global final List<String> recIds;
    global final List<sObject> recIdObjs = new List<sObject>();

    global createSyncRecBatch(List<String> recs)
    {
       for(string rec : recs)
      {
        id recid = rec;
        String objName =  String.valueOf(recid.getsobjecttype());
        sObject recObj = Schema.getGlobalDescribe().get(objName).newSObject(recid);

        recIdObjs.add(recObj);
      }

        recIds = recs;
    }



    global Iterable<sObject> start(Database.BatchableContext bc) 
    {


        return recIdObjs;
    }

    global void execute(Database.BatchableContext bc, List<sObject> recIdList) {

        for (sObject recId : recIdList) 
        {
          try
          {
             String RecordId = String.valueof(recId.id);
             Syncplicity.SyncplicityFolderCreationSync.createObjectFolderForRecordId(RecordId);
          }
          catch(Exception e)
          {
            System.debug(e);
          }
        }

    }

    global void finish(Database.BatchableContext bc) {
    }
}