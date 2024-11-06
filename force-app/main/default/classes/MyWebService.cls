@RestResource(urlMapping='/Util/*')
global class MyWebService {
    
    @HttpGet
    global static List<string> getPickList() {
      
        String objectName = RestContext.request.params.get('objectName');
        String fieldName = RestContext.request.params.get('fieldName');

        return getPicklistValues(objectName, fieldName);
    }

    public static List<String> getPicklistValues(String ObjectApi_name,String Field_name){ 

            List<String> lstPickvals      = new List<String>();
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject

            Sobject Object_name = targetType.newSObject();
    
        Schema.sObjectType sobject_type               = Object_name.getSObjectType();                   //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();       //describe the sobject 
        Map<String, Schema.SObjectField> field_map    = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values   = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }

        return lstPickvals;
    }


}