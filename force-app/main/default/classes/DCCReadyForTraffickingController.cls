public with sharing class DCCReadyForTraffickingController {
    @AuraEnabled(cacheable=true)  
    public static List<Digital_Creative__c> getDigitalCreatives(String recordId){  
      return [SELECT Id,Name, Status__c, Creative_Name__c,VRF_Spot_ID__c,VAST_Tag__c,Creative_Start_Date__c,Creative_End_Date__c,Date_Last_Submitted__c 
                From Digital_Creative__c Where Digital_Campaign__c =:recordId AND (Status__c = '05 Trafficked by Digital Ops' OR Status__c = '64 Date Revision Confirmed by Digital Ops') ];  
    }  
}