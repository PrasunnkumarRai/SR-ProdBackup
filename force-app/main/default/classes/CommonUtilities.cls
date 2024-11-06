public with sharing class CommonUtilities {
    
    // This method is used to Check the String is Null or empty   
    public static Boolean isStringNullOrEmpty(String strData) {
        return (strData == NULL || strData == '' || (strData.trim()).length() == 0 || 'NULL'.equalsignorecase(strData));
    }

    //This method is used to Check the List is Null or empty    
    public static Boolean isListNullOrEmpty(List<Object> listData) {
        return (NULL == listData || listData.isEmpty());
    }

    public static Boolean isSetNullOrEmpty(Set<String> setData) {
        return (NULL == setData || setData.isEmpty());
    }    

    public static Map<String, RecordType> fetchRecordTypeDetails (String sobjectName) {
        Map<String, RecordType> recordTypeMap = new Map<String, RecordType> ();
        for (RecordType rt : [SELECT ID, Name, DeveloperName, IsActive FROM RecordType WHERE SobjectType = :sobjectName]) {
            recordTypeMap.put(rt.DeveloperName, rt);
        }
        return recordTypeMap;
    } 
}