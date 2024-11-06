global with sharing class multiLookupControllerClone  {
	 //This method retrieves the data from database table. It search input is '*', then retrieve all records
    @AuraEnabled (cacheable=true)
    public static List<SObjectQueryResult> retrieveRecords(String objectName, 
                                                    String fieldAPINames,
                                                    String filterFieldAPIName,
													String fieldName,
													String codeName,
													String networkCode,
													String bookedSponsorshipId,
													String syscode,
                                                    String strInput,
                                                    String recordType){
        
        List<SObjectQueryResult> lstReturnResult = new List<SObjectQueryResult>();
        if(strInput.equals('*')){
            strInput = '';
        }
        String str = '%'+ strInput + '%';
        String strQueryField = '';
		String sys = '\''+ syscode + '\'';
		String networ = '\''+ networkCode + '\'';
        List<String> fieldList = fieldAPINames.split(',');
		System.debug('bookedspnsrshipId  ---- ' + bookedSponsorshipId);
		List<Sponsorship_Booking__c> listBooked = [Select id,Template__c from Sponsorship_Booking__c where Booked_Sponsorship__c = :bookedSponsorshipId];
		System.debug('Booked Sponsorship Details ------' + listBooked);
		List<String> idList = new List<String>();
		for(Sponsorship_Booking__c sb : listBooked){
			idList.add(sb.Template__c);
		}
		System.debug('idList ---- ' + idList);

        //check if Id is already been passed
        if(!fieldList.contains('Id')){
            fieldList.add('Id');
            strQueryField = String.join(fieldList, ',');
        }else {
            strQueryField = fieldAPINames;
        }

		String strQuery = '';
		if(bookedSponsorshipId != null){
			if(networkCode != 'none'){
			strQuery = 'SELECT ' + String.escapeSingleQuotes(strQueryField) 
                        + ' FROM ' 
                        + String.escapeSingleQuotes(objectName) 
                        + ' WHERE ' + filterFieldAPIName + '  LIKE \''  + str + '\'' + ' AND ' + fieldName + '=' + sys + ' AND ' + codeName + '=' + networ + 'AND RecordType.Name = :recordType'+ ' AND Id NOT IN :idList AND Active__c = true' 
                        + ' ORDER BY ' + filterFieldAPIName
                        + ' LIMIT 50'; 
                        
			System.debug('strQuery=' + strQuery);	
		}else{
			strQuery = 'SELECT ' + String.escapeSingleQuotes(strQueryField) 
                        + ' FROM ' 
                        + String.escapeSingleQuotes(objectName) 
                        + ' WHERE ' + filterFieldAPIName + '  LIKE \''  + str + '\'' + ' AND ' + fieldName + '=' + sys + 'AND RecordType.Name = :recordType' + 'AND Id NOT IN :idList AND Active__c = true'
                        + ' ORDER BY ' + filterFieldAPIName
                        + ' LIMIT 50'; 
                        
			System.debug('strQuery=' + strQuery);
		}	
		}else{
			if(networkCode != 'none'){
			strQuery = 'SELECT ' + String.escapeSingleQuotes(strQueryField) 
                        + ' FROM ' 
                        + String.escapeSingleQuotes(objectName) 
                        + ' WHERE ' + filterFieldAPIName + '  LIKE \''  + str + '\'' + ' AND ' + fieldName + '=' + sys + ' AND ' + codeName + '=' + networ + 'AND RecordType.Name = :recordType AND Active__c = true' 
                        + ' ORDER BY ' + filterFieldAPIName
                        + ' LIMIT 50'; 
                        
			System.debug('strQuery=' + strQuery);	
		}else{
			strQuery = 'SELECT ' + String.escapeSingleQuotes(strQueryField) 
                        + ' FROM ' 
                        + String.escapeSingleQuotes(objectName) 
                        + ' WHERE ' + filterFieldAPIName + '  LIKE \''  + str + '\'' + ' AND ' + fieldName + '=' + sys + 'AND RecordType.Name = :recordType AND Active__c = true'  
                        + ' ORDER BY ' + filterFieldAPIName
                        + ' LIMIT 50'; 
                        
			System.debug('strQuery=' + strQuery);
		}
		}
		
        

        List<SObject> lstResult = database.query(strQuery);
        //create list of records that can be easily be parsable at js controller.
        // for(String strField:fieldList){
        //     for(SObject sobj:lstResult){                
        //         if(strField != 'Id'){
        //             SObjectQueryResult result = new SObjectQueryResult();
        //             result.recordId = (String) sobj.get('Id');
        //             result.recordName = (String) sobj.get(strField);
        //             lstReturnResult.add(result);
        //         }                
        //    }
        // }

		for(SObject sobj:lstResult){                
            SObjectQueryResult result = new SObjectQueryResult();
            result.recordId = (String) sobj.get('Id');
            result.recordName = (String) sobj.get('Name');
			result.startDate = (Date) sobj.get('Start_Date__c');
			result.endDate = (Date) sobj.get('End_Date__c');
			result.totalQuantity = (Decimal) sobj.get('Total_Quantity__c');
			lstReturnResult.add(result);                        
        }

		System.debug('lstReturnResult   ' + lstReturnResult );
        return lstReturnResult;
    }
	
    
    public class SObjectQueryResult {
        @AuraEnabled
        public String recordId;

        @AuraEnabled
        public String recordName;

		@AuraEnabled
        public Date StartDate;

		@AuraEnabled
        public Date EndDate;

		@AuraEnabled
        public Decimal totalQuantity;
    }

}