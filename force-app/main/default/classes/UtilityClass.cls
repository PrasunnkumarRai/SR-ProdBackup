/*
###########################################################################
# File..................: UtilityClass.cls
# Version...............: 1
# Created by............: Ankit Bhatia
# Created Date..........: 21-Feb-2017
# Last Modified by......: Sai Anuja
# Last Modified Date....: 19-June-2018
# Description...........: This class is being used as a Utility Class.
# Change Log:               
# 1. Added emptyRecycleBin method

############################################################################*/
public class UtilityClass {

	public static String aes256Encryption(String data, Boolean isEncode){
	    String clearText = data;
	    String returnedString = '';
	    //32 byte string. since characters used are ascii, each char is 1 byte.
	    Blob key = Blob.valueOf('12345678901234567890123456789012');
	    if(isEncode)
	    {
	    	Blob cipherText = Crypto.encryptWithManagedIV('AES256', key, Blob.valueOf(clearText));
	    	returnedString = EncodingUtil.base64Encode(cipherText); 
	    }
	    else
	    {
		    Blob encodedEncryptedBlob = EncodingUtil.base64Decode(clearText);
		    Blob decryptedBlob = Crypto.decryptWithManagedIV('AES256', key, encodedEncryptedBlob);
		    returnedString = decryptedBlob.toString();
	    }
	    return returnedString;
	}
	
	@future
	public static void asyncApexSharing(List<Id> recordIds, List<Id> userOrGroupIds, String sObjectName, String accessLevel){
		List<ApexShareClass> sharingList = new List<ApexShareClass>();
		for(Integer i =0; i<recordIds.size();i++){
  			sharingList.add(new ApexShareClass(sObjectName,recordIds[i],userOrGroupIds[i],accessLevel));
  		}
		
		if(sharingList.size() > 0){
			createApexShare(sharingList, sObjectName);
		}
	}
	
	public static String createApexShare(List<ApexShareClass> sharingList, String sObjectName){
	  
	  //Create new sharing object list
	  List<sObject> sObjectShrList  = new List<sObject>();
	  Map<String,String> metadataValueMap = retrieveMetadata(sObjectName);
	  
	  for(ApexShareClass sharingData:sharingList){		
		  	  	
	      // Create new sharing object
	      sObject sObjectShr  = Schema.getGlobalDescribe().get(metadataValueMap.get('Sharing_Object_Name__c')).newSObject();	   
	   
	      //Define object’s recordID
	      sObjectShr.put(metadataValueMap.get('Sharing_Field_Name__c'), sharingData.recordId);	      
	      
	      // Define access level
	      sObjectShr.put(metadataValueMap.get('Sharing_Access_Level__c'), sharingData.accessLevel);	      
	        
	      // Define ID of a user/group
	      sObjectShr.put('UserOrGroupId', sharingData.UserOrGroupId);	        
	      
	      sObjectShrList.add(sObjectShr);
	  }        
      System.debug('sObjectShrList: ' + sObjectShrList);
      
      // Insert the created sharing records
      if(sObjectShrList.size() > 0){
      	try{
      		insert sObjectShrList;
      	}
      	catch(DMLException dex){
      		return 'Error: ' + dex.getMessage();
      	}
      }
      
      return 'Success';
   }
   
   public class ApexShareClass{
   		String sObjectName;
   		Id recordId;
   		Id userOrGroupId;
   		String accessLevel;
   		String rowCause;
   		
   		public ApexShareClass(String sObjectName, Id recordId, Id userOrGroupId, String accessLevel){
   			this.sObjectName=sObjectName;
   			this.recordId=recordId;
   			this.userOrGroupId=userOrGroupId;
   			this.accessLevel=accessLevel;
   		}
   }
   
   public static Map<String,String> retrieveMetadata (String customMetadataName) {
  	
    // List fullnames of components we want to retrieve
    List<String> componentNameList = new List<String>{'SObject_Sharing_Info.'+customMetadataName};

    // Retrieve components that are records of custom metadata types based on name
    List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.CustomMetadata, componentNameList);
    System.debug('components: '+components);
    Metadata.CustomMetadata customMetadataRecord = (Metadata.CustomMetadata) components.get(0);
	
    // Check fields of retrieved component
    List<Metadata.CustomMetadataValue> values = customMetadataRecord.values;
    Map<String,String> metadataValueMap = new Map<String,String>(); 
    for (integer i = 0; i < values.size(); i++) {	  
	  System.debug('values.get(i): '+values.get(i));
	  metadataValueMap.put(values.get(i).field,String.valueOf(values.get(i).value));      
    }
    
    return metadataValueMap;
   }  
  //Example for testing retrieveMetadata code: utilityClass.retrieveMetadata('SObject_Sharing_Info.Opportunity');	

   public static ID getRecordTypeID(SObject sobjectName, string recordTypeName){
        Schema.DescribeSObjectResult describeSobjectSchema = sobjectName.getSObjectType().getDescribe();
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = describeSobjectSchema.getRecordTypeInfosByName();
        Id recordTypeId = recordTypeInfo.get(recordTypeName).getRecordTypeId();
        return recordTypeId;
    }

    public static void emptyRecycleBin(List<id> ids){
    	Database.EmptyRecycleBinResult[] emptyRecycleBinResults = Database.emptyRecycleBin(ids);
    }

    /**
    * <p> This method returns all fields of an Object, which can be used in a dynamic select query.
    */
    public static String getFieldsAsQueryString(String obj,boolean allFields) {
        SObjectType objToken = Schema.getGlobalDescribe().get(obj);
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map<String, SObjectField> fields = objDef.fields.getMap();
        Set<String> fieldSet = fields.keySet();
        System.debug('Fields in the given object are :-->'+fieldSet);
        String queryStr='';
        for(String s:fieldSet) {
            SObjectField fieldToken = fields.get(s);
            DescribeFieldResult selectedField = fieldToken.getDescribe();
            if(allFields) {
                queryStr = queryStr + selectedField.getName() + ',';

            }else if (selectedField.isAccessible()) {
                queryStr = queryStr + selectedField.getName() + ',';
            }
        }
        if(queryStr.length() > =1){
            queryStr=queryStr.substring(0, queryStr.length()-1);
        }
        return queryStr;
    }
}