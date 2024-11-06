public class lwcCustomLookup  {
/*@AuraEnabled(cacheable=true)  
   public static List<sobject> findRecords(String searchKey, String objectName, String recId, string relatedRec ) {  
	//System.debug('recId' + recId);
	//System.debug('relatedRec' + relatedRec);
	//System.debug('objectName' + objectName);
	 String newrecId = '\''+ recId + '\'';
	 System.debug(newrecId);
     string searchText = ('\'' + String.escapeSingleQuotes(searchKey) + '%\'');  
	 System.debug('searchText' + searchText);
     string query = ('SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText+ ' AND ' +relatedRec+ ' = '  +newrecId);  
     return Database.query(query); 
   }  */
@AuraEnabled(cacheable=true)  
   public static List<sobject> findStateRecords(String searchKey, String objectName, string stateId, string stateNameField, string countryField) {  
   	System.debug('searchKey' + searchKey);
	System.debug('objectName' + objectName);
	System.debug('stateNameField' + stateNameField);
	System.debug('countryField' + countryField);
	System.debug('stateId' + stateId);
		string searchText = ('\'' + String.escapeSingleQuotes(searchKey) + '%\'');  
		System.debug('searchText' + searchText);
		string metaQuery = ('SELECT Id, ' +stateId+ ', ' +stateNameField+ ', ' +countryField+ ' FROM ' +objectName+ ' WHERE ' +stateId+ ' LIKE ' +searchText);
		System.debug('string query ' +metaQuery);
		System.debug('Output' + Database.query(metaQuery));
		return Database.query(metaQuery); 
   }  
 }