global class DC_StatusMissingCreativeUpdaterBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String dcExcludeRT=System.Label.DC_ExcludeRT;
        List<String> dcExcludeRTList=new List<String>();
        dcExcludeRTList=dcExcludeRT.split(',');
        return Database.getQueryLocator([Select id, Status__c,Max_Trafficked_Creative_End_Date__c,Max_Pending_Creative_End_Date__c,Max_Pending_Creative_End_Date_Record_St__c from Digital_Campaign__c where  RecordType.Name Not IN :dcExcludeRTList AND Status__c != '00 Abandoned Campaign' AND Status__c != '20 Missing Creative / Instructions' AND
                                         ((Status__c ='03 Submitted to Digital Ops' and Max_Trafficked_Creative_End_Date__c = null and Max_Pending_Creative_End_Date__c = null) OR (Max_Trafficked_Creative_End_Date__c = null and Max_Pending_Creative_End_Date__c!=null and Max_Pending_Creative_End_Date_Record_St__c = 'Draft Creative'))]);
        
        
    }
    global void execute(Database.BatchableContext BC, list<Digital_Campaign__c> dcList) {
        list<Digital_Campaign__c> lstUpdated = new list<Digital_Campaign__c>();
        for(Digital_Campaign__c objDC : dcList) {
            objDC.Status__c = '20 Missing Creative / Instructions';
            lstUpdated.add(objDC);      
        }
        if(lstUpdated.size() > 0) {
            update lstUpdated;
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}