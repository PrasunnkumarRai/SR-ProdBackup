/* 
    Customer/Project:  Spectrum Reach
    Class name:         ApexUtils
    Author/Date:       Brett Ballantyne    12/26/2017
    Release:            TBD
    Purpose:           Misc utility methods
*/

public with sharing class ApexUtils {
	public ApexUtils() {
		
	}

	// Returns the picklist values for the passed in sObject and field
	public static List<String> getPicklistValues(String ObjectApi_name, String Field_name){ 

		  List<String> lstPickvals=new List<String>();
		  Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);	//From the Object Api name retrieving the SObject
		  Sobject Object_name = targetType.newSObject();
		  Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
	      Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
	      Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
	      List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
	      for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
	      		lstPickvals.add(a.getValue());//add the value  to our final list
	      }
	  	  return lstPickvals;
  	}

  	// Returns the record types available to the current user for the specified object
  	public static Map<Id, String> getAvailRecordTypes(String ObjectApi_name) {
  		Map<Id, String> rtypeMap = new Map<Id, String>();
  		if (ObjectApi_name == null || ObjectApi_name == '') return rtypeMap;
  		RecordType rt = [SELECT Id, Name FROM RecordType WHERE SobjectType = :ObjectApi_name LIMIT 1];
  		
  		Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new List<String>{ObjectApi_name});

		Map<Id, Schema.RecordTypeInfo> rtMapById = results[0].getRecordTypeInfosById();
		for (Id rtId : rtMapById.keySet()) {
			Schema.RecordTypeInfo rtInfo = rtMapById.get(rtId);
			if (rtInfo.isAvailable())			// ensure record type is available to the user
				rtypeMap.put(rtId, rtInfo.getName());
		}
		
		return rtypeMap;
  	}


}