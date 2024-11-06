global class DC_StatusMissingCreativeToLive implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([select id,Status__c,Max_Trafficked_Creative_End_Date__c,Campaign_End_Date__c,Has_hit_09_Live__c from Digital_Campaign__c where Max_Trafficked_Creative_End_Date__c != null 
                                         and Campaign_End_Date__c != null and Status__c = '20 Missing Creative / Instructions' ]);
    }
    
    global void execute(Database.BatchableContext BC, list<Digital_Campaign__c> dcList) {
        list<Digital_Campaign__c> lstDCUpdated = new list<Digital_Campaign__c>();
        for(Digital_Campaign__c objDC : dcList) {
            if(objDC.Max_Trafficked_Creative_End_Date__c == objDC.Campaign_End_Date__c ){
                if(objDC.Has_hit_09_Live__c == true){
                   objDC.Status__c = '19 Revision Live'; 
                }
                else if(objDC.Has_hit_09_Live__c == false){
                   objDC.Status__c = '09 Live';
                }
                lstDCUpdated.add(objDC);
            }   
        }
        if(!lstDCUpdated.isEmpty()) {
            update lstDCUpdated;
        }
    }
    global void finish(Database.BatchableContext BC) {        
    }
}