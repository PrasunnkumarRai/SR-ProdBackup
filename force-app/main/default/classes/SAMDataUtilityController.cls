public class SAMDataUtilityController{

    @AuraEnabled
     public static String sendCsvData(chunkDataWrapper chunkData) {
         try{
             chunkDataWrapper wrapper = new chunkDataWrapper();
             if(chunkData != null){
                 wrapper.csvData = chunkData.csvData;
                 wrapper.TransactionID = chunkData.TransactionID;
                 wrapper.upsertStatus = chunkData.upsertStatus; 
             }
             String jsonData = JSON.serialize(wrapper);
             System.debug('jsonData: '+ jsonData);
             HttpRequest request = new HttpRequest();
             request.setEndpoint('callout:Boomi_Auth_SAM_NamedCredential/ws/rest/SamDataLoad/SAM_CSV');
             request.setMethod('POST');
             request.setHeader('Content-Type', 'application/json');
             request.setBody(jsondata);
     
             HttpResponse response = new Http().send(request);
             system.debug('status code'+response.getStatusCode());
             system.debug('response'+response.getBody());
             if(String.valueOf(chunkData.upsertStatus) == 'true'){
                 if (response.getStatusCode() == 200) {
                     return 'Data sent to Boomi successfully';    
                 } else {
                     return 'Failed to send data to Boomi: Status Code - ' + response.getStatusCode();
                 }
             }
             else{
                 return 'Processing';
             } 
         }catch(Exception ex){
             Log4SF.logMessage('SAMDataUtilityController','sendCsvData',ex.getMessage(),ex,UserInfo.getUserId(),'');
             return null;
         }
        
     } 
     
     @AuraEnabled(cacheable = true)
     public static Sam_Data_Load_Utility_Metadata__mdt getMetadata(){
         try{
             // Sam_Data_Load_Utility_Metadata__mdt SamLabels = [SELECT Id, All__c, Target__c, Key__c, Secondary__c, 
             // Extra__c, Step_1__c, Step_2__c, Step_3__c, Insert_File__c, First__c, 
             // Previous__c, Next__c, Last__c, Back__c, Next2__c, Cancel__c, Confirm__c 
             // FROM Sam_Data_Load_Utility_Metadata__mdt];
 
             Sam_Data_Load_Utility_Metadata__mdt SamLabels =[SELECT Id, All__c, Target__c, Key__c, Secondary__c, 
             Extra__c, Step_1__c, Step_2__c, Step_3__c, Insert_File__c, First__c, 
             Previous__c, Next__c, Last__c, Back__c, Next2__c, Cancel__c, Confirm__c,Elite__c,Premiere__c,VIP__c,Priority__c,Select__c,Client__c
             FROM Sam_Data_Load_Utility_Metadata__mdt];
 
             system.debug(SamLabels);
             return SamLabels;
 
         }catch(Exception ex){
             Log4SF.logMessage('SAMDataUtilityController','getMetadata',ex.getMessage(),ex,UserInfo.getUserId(),'');
             return null;
         }
      
     }
     
     @AuraEnabled
     public static void deleteRecords(List<String> designations) {
         try{
             system.debug('designations - '+designations);
         
             if(!designations.isEmpty()) {
                Database.executeBatch(new SAMDATARecordsDeleteBatch(designations),2000);
             }
         }catch(Exception ex){
             Log4SF.logMessage('SAMDataUtilityController','deleteRecords',ex.getMessage(),ex,UserInfo.getUserId(),'');
             
         }
        
     }
     
     @AuraEnabled(cacheable=true)
     public static List<AggregateResult> getGroupedByTierDesigRecCount() {
         try{
             List<AggregateResult> tierDesignationRecCount=[SELECT COUNT(Id) RecordCount, Tier_Designation__c FROM Account_SAM_Mapping__c GROUP BY Tier_Designation__c]; 
             return tierDesignationRecCount;
         }catch(Exception ex){
             Log4SF.logMessage('SAMDataUtilityController','getGroupedByTierDesigRecCount',ex.getMessage(),ex,UserInfo.getUserId(),'');
             return null;
         }
        
     }
 
     public class chunkDataWrapper{
         @AuraEnabled 
         public object csvData {get; set;}
 
         @AuraEnabled 
         public boolean upsertStatus {get; set;}
 
         @AuraEnabled 
         public String TransactionID {get; set;}
     }

 }