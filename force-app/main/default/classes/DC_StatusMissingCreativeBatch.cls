/*
	Author : M&S 
	Ref    : SRSF-2687
*/
global class DC_StatusMissingCreativeBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String dcStatus=System.Label.DC_Status_c;
        List<String> dcStatusList=new List<String>();
        dcStatusList=dcStatus.split(',');
        return Database.getQueryLocator([select id,Status__c,Max_Trafficked_Creative_End_Date__c,Campaign_End_Date__c from Digital_Campaign__c where Status__c IN :dcStatusList and Max_Trafficked_Creative_End_Date__c != null and  Campaign_End_Date__c != null]);
        
    }
    
    global void execute(Database.BatchableContext BC, list<Digital_Campaign__c> dcList) {
        list<Digital_Campaign__c> lstUpdated = new list<Digital_Campaign__c>();
        for(Digital_Campaign__c objDC : dcList) {
            if(objDC.Max_Trafficked_Creative_End_Date__c < objDC.Campaign_End_Date__c){
                objDC.Status__c = '20 Missing Creative / Instructions'; 
                lstUpdated.add(objDC);
            }   
        }
        if(lstUpdated.size() > 0) {
            update lstUpdated;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}