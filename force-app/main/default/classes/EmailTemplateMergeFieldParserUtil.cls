/*
	Author      : M&S
	Date        : 11/05/2017 
	ClassName   : EmailTemplateCustomMergeFieldParserUtil 
	Description : Util class to Parse Merge Fields from Header/ Body/ Footer/ EmailTemplate Body 
*/
public with sharing class EmailTemplateMergeFieldParserUtil {
	
	//method to parse email template with sObject field values
	public static String ParseEmailTemplate( String objectId, EmailTemplate email, String objectTypeName ){
    	String body = email.Body;
      	set< String > lstFields = new set< String >();
      	if( body!=null )
        	body = body.replace('{!','{');
      
      	lstFields.addAll(fieldsInHtml( body,objectTypeName ));
      	DataValueResponse objDataResponse = getFields( objectId, lstFields,objectTypeName );
      	String resultData = datatofieldsInHtml ( objectId, body, objDataResponse,objectTypeName );
      	return resultData;
  	}
  
	//gets all fields based on Object from the Template Body 
  	public static set< String > fieldsInHtml( string bodyContent, String objectTypeName )
    {
    	set< String > lstFields = new set< String >();
      	if ( bodyContent == null || bodyContent == '' )
        	return lstFields;
      	Pattern p = Pattern.compile('\\{([^}]*)\\}');
      	Matcher m = p.matcher(bodyContent);
      	while( m.find() )
      	{
        	if ( m.group(1) != '' ){
            	String strField = m.group(1).replace(objectTypeName+'.','');
              	//checking for Owner fields
            	if( strField.toLowerCase().contains('owner') && !strField.toLowerCase().contains('__c') && !strField.contains('.') )
              	{
                	if( strField.toLowerCase()=='ownerfullname' )
                  		strField = 'OwnerName';
                	string strSubField = strField.substring(5);
                	strField = 'Owner.'+strSubField;  
              	}  
              	lstFields.add(strField);
          	}
      	}
    	return lstFields;
    }
    
	/**
    	* Given a list of field names and an instance ID, return the corresponding SObject (if found).  This
     	* returns the data values; the schema definitions are pulled above in "describeFields".
     	* @param objectTypeName an SObject type name such as "Quote__c"
     	* @param Id the ID of an object of type "objectTypeName" 
     	* @param fieldsToRetrieve a list of fields to return such as "Date__c".
     	* @return a tuple of the "raw data" response as an SObject and formatted equivalents (if any) for each
     	* field listed in fieldsToRetrieve.
   	*/
	public static DataValueResponse getFields( String objectId, set< String > fieldsToRetrieve,String objectTypeName )
   	{
   		try{
        	map< String, Schema.SObjectField > objectFields = Schema.getGlobalDescribe().get( objectTypeName ).getDescribe().fields.getMap();
          	String objectQuery = 'SELECT Id';
          	for ( String objectFieldName : fieldsToRetrieve )
          	{
            	if( objectFieldName !='Id' )//to avoid repeat Id 
                	objectQuery += ', ' + objectFieldName;
          	}
          	objectQuery += ' FROM ' + objectTypeName + ' WHERE Id = :objectId';
          	system.debug('objectQuery::'+objectQuery);
          	SObject instance = Database.query( objectQuery );
          	// Convert the SObject to a map of strings to strings so that I can include "value" objects
          	// for dates and currency fields in the response.
          	//objectFields = Schema.getGlobalDescribe().get( objectTypeName ).getDescribe().fields.getMap();
          	DataValueResponse response = new DataValueResponse();
          	response.displayFields = new Map< String, String >();
          	list<string> lstsplitName = new list<string>();
          	Schema.DescribeFieldResult describeField;
          	for ( String objectFieldName : fieldsToRetrieve )
          	{
            	lstsplitName = objectFieldName.split('\\.');
             
             	if ( lstsplitName.size() > 1 && instance.getSObject( lstsplitName[0] ) != null )
              	{
                	describeField = instance.getSObject( lstsplitName[0] ).getSObjectType().getDescribe().fields.getMap().get( lstsplitName[1] ).getDescribe();
                  	response.displayFields.put( objectFieldName, string.valueOf( describeField.getType() ) );
              	}
              	else if ( objectFields != null && objectFieldName!=null && objectFields.containsKey( objectFieldName ) )
              	{
                	describeField = objectFields.get( objectFieldName ).getDescribe(); 
                 	response.displayFields.put( objectFieldName, string.valueOf( describeField.getType() ) );
              	}
          	}
          	response.dataFields = instance;
          	response.query = objectQuery;
          	return response;
       	}catch( Exception ex){
        	system.debug('Exception::'+ex);
       	}
       	return null;
	}
   
	//to replace the fields in the template with the response data
   	public static string datatofieldsInHtml ( String objectId, string bodyContent, DataValueResponse response, String objectTypeName )
   	{
    	if ( bodyContent == null || bodyContent == '' )
        	return null;
      	Pattern p = Pattern.compile('\\{([^}]*)\\}');
      	Matcher m = p.matcher(bodyContent);
      	string field, value;
      	list<string> lstsplitName = new list<string>();
      	while( m.find() )
      	{
        	if ( m.group(1) != '' )
          	{
            	field = m.group(1).replace(objectTypeName+'.','');
                System.debug('field-->'+field);
              	if( field.contains('Owner') && !field.contains('__c') && !field.contains('.') )
              	{
                	String fieldTemp = field;
                	if( field.toLowerCase()=='ownerfullname' )
                  		field = 'OwnerName';
                	string strSubField = field.substring(5);
                	field = 'Owner.'+strSubField;
                	bodyContent = bodyContent.replace('{'+objectTypeName+'.'+fieldTemp,'{'+objectTypeName+'.'+field);
              	}
              	lstsplitName = field.split('\\.');
              	if ( lstsplitName.size() > 1 )
              	{ 
                	if ( lstsplitName[ 0 ].contains('__r') )
                    	value = ( ( response.dataFields.get( lstsplitName[ 0 ].replace('__r','__c') ) != null) && response.dataFields.getSObject( lstsplitName[0] ).get( lstsplitName[1] )  != null) ? string.valueOf ( response.dataFields.getSObject( lstsplitName[0] ).get( lstsplitName[1] ) ) : null;
                  	else
                      	value = ( response.dataFields.getSObject( lstsplitName[0] ).get( lstsplitName[1] )  != null) ? string.valueOf ( response.dataFields.getSObject( lstsplitName[0] ).get( lstsplitName[1] ) ) : null;
              	}
              	else
                  	value = string.valueOf( response.dataFields.get(field) );   
              	if ( value != null )
              	{
                  	value = fieldData ( value, field, response.displayFields );
                  	bodyContent = bodyContent.replaceAll( '\\{'+objectTypeName+'.'+field+'\\}' , value );
              	}
              	else
                  	bodyContent = bodyContent.replaceAll( '\\{'+objectTypeName+'.'+field+'\\}' , ' ' );
          	}
      	}
      	return bodyContent;
   	}
   
	//Appends data to body based on Datatype of field 
   	public static string fieldData ( string fieldValue, string field, Map< String, String > displayFields )
   	{
    	if ( displayFields.get ( field ) == null  )
        	return fieldValue;
		else if ( displayFields.get ( field ) == 'CURRENCY' )
      	{
            String s = formatStringToCurrency(fieldValue);
        	return '\\$'+s;
      	}	
      	else if ( displayFields.get ( field ) == 'PERCENT' )
      	{
        	return fieldValue + '%';
      	}else if ( displayFields.get ( field ) == 'DATE' )
      	{
          	Date dtField = Date.valueOf( fieldValue );
          	return dtField.month() + '/' + dtField.day() + '/' + dtField.year();
      	}else if ( displayFields.get ( field ) == 'DATETIME' )
      	{
          	DateTime dtField = DateTime.valueOf( fieldValue );
          	return dtField.month() + '/' + dtField.day() + '/' + dtField.year()+' '+dtField.time();
      	}
      	return fieldValue;  
   	}
	
	//format String to Decimal 
   	public static string formatStringToCurrency(String fieldValue){
   		Decimal rA = Decimal.valueOf(fieldValue);
        List<String> args = new String[]{'0','number','###,###,##0.00'};
        return String.format(rA.format(), args);
   	}
    
   	public class DataValueResponse
   	{
    	public SObject dataFields;
        public String query;
        public Map< String, String > displayFields;
   	}
}