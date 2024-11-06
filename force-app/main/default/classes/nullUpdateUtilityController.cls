public with sharing class nullUpdateUtilityController {

    @AuraEnabled(cacheable=true)
    public static String getCurrentUserEmail() {
       
        try{

            return UserInfo.getUserEmail();

        }catch(Exception e) {

			System.debug('Error: ' + e.getMessage() + 'Error Line Number: ' + e.getLineNumber());
			Log4SF.logMessage('nullUpdateUtilityController','getCurrentUserEmail',e.getMessage(),e,UserInfo.getUserId(),'');
			throw e;

		}
    }

    @AuraEnabled(cacheable=true)
    public static List<FieldWrapper> getFields(String selectedObject) {
        List<FieldWrapper> result = new List<FieldWrapper>();

        try{
            // Collecting field data
            for (Schema.SObjectField field : Schema.getGlobalDescribe().get(selectedObject).getDescribe().fields.getMap().values()) {
                FieldWrapper fieldData = new FieldWrapper();
                
                fieldData.label = field.getDescribe().getLabel();
                fieldData.value = field.getDescribe().getName();
                fieldData.dataType = String.valueOf(field.getDescribe().getType());
                
                result.add(fieldData);
            }

            // Sort the results based on the label
            result.sort();

            System.debug(result);
            return result;

        }catch(Exception e) {

			System.debug('Error: ' + e.getMessage() + 'Error Line Number: ' + e.getLineNumber());
			Log4SF.logMessage('nullUpdateUtilityController','getFields',e.getMessage(),e,UserInfo.getUserId(),'');
			throw e;
		}
        
    }

    public class FieldWrapper implements Comparable {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String dataType;

        // Implement the compareTo method from the Comparable interface
        public Integer compareTo(Object objToCompare) {
            FieldWrapper toCompare = (FieldWrapper)objToCompare;
            return label.compareTo(toCompare.label);
        }
    }

    @AuraEnabled(cacheable=true)
    public static Object executeSOQLQuery(String soql) {
        
        System.debug('SOQL Query =========> '+soql);
        try{

            SObject records = Database.query(soql);
            return records.get('expr0');

        }catch(Exception e) {

			System.debug('Error: ' + e.getMessage() + 'Error Line Number: ' + e.getLineNumber());
			Log4SF.logMessage('nullUpdateUtilityController','executeSOQLQuery',e.getMessage(),e,UserInfo.getUserId(),'');
			throw e;
		}
            
    }


    @AuraEnabled
    public static void callBoomiListener(String payload) {

        String endpoint = system.Label.NullUpdateEndpoint; 

        String userName = system.Label.NullUpdateUserName;

        String password = system.Label.NullUpdatePassword;

        System.debug('Payload ========> '+payload);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        // String username = 'SFMandSUser@chartersalesforce-VB2XFC'; 
        // String password = '0362129b-878b-41ce-b88c-c6bc8a6a0e6e'; 
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);

        req.setBody(payload);
    
        try{

            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(res.getBody());


        }catch(Exception e) {

                System.debug('Error: ' + e.getMessage() + 'Error Line Number: ' + e.getLineNumber());
                Log4SF.logMessage('nullUpdateUtilityController','callBoomiListener',e.getMessage(),e,UserInfo.getUserId(),'');
                throw e;
            }
   
}

@AuraEnabled(cacheable=true)
    public static List<Object_details_for_data_retention__mdt> fetchObjectDetails(){
       
        List<Object_details_for_data_retention__mdt> objectDetails = new List<Object_details_for_data_retention__mdt>();
        
        try {

            objectDetails = [Select Object_API_Name__c FROM Object_details_for_data_retention__mdt WHERE Data_Update_Utility__c = true];
            System.debug('objectDetails - '+objectDetails);
            return objectDetails;

        } catch (Exception e) {

            Log4SF.logMessage('nullUpdateUtilityController','fetchObjectDetails',e.getMessage(),e,UserInfo.getUserId(),'');
            throw e;
            
        }
        
    }

}