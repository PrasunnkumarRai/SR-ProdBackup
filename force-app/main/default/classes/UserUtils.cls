public with sharing class UserUtils {
    public UserUtils() {
        
    }
    public static Id BoomiUserId = [Select Id from User where Name = 'Boomi Integration User' LIMIT 1].Id;
    public static Id bIntegrationUserId = [Select Id from User where Name = 'B Integration User' LIMIT 1].Id;

    // To get the createable fields / Updateable fields from an sObject

    public static Map<String,Set<String>> fetchCreateableOrUpdatableFields(String objectName) {

        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        Set<String> creatableFields = new Set<String>();
        Set<String> updatableFields = new Set<String>();
        Map<String, Set<String>> createUpdateableFieldsMap = new Map<String, Set<String>>();
        if (fieldMap != null)
        {
            for (Schema.SObjectField objectField : fieldMap.values())
            { 
                Schema.DescribeFieldResult fieldResult = objectField.getDescribe(); // describe each field 
                if (fieldResult.isCreateable())
                { 
                    creatableFields.add(fieldResult.getName());
                }
                if(fieldResult.isUpdateable()) {
                    updatableFields.add(fieldResult.getName());
                }
            }
            createUpdateableFieldsMap.put('createable', creatableFields);
            createUpdateableFieldsMap.put('updateable', updatableFields);
            return createUpdateableFieldsMap;
        }
        createUpdateableFieldsMap = null;
        return createUpdateableFieldsMap;
    }

    public static Boolean checkObjectDeletePermission(String objectName) {
        if (Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().isDeletable())
            return true;
        else 
            return false;       
    }
}