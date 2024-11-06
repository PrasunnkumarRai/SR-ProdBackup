global with sharing  class MultiLookUpControllerProposal 
{
@AuraEnabled (cacheable=true)
 public static List<SObjectQueryResult> retrieveRecords(String objectName, 
                                                    String fieldAPINames,
                                                    String filterFieldAPIName,
                                                    String strInput,
													String relatedopportunityId){
List<SObjectQueryResult> lstReturnResult = new List<SObjectQueryResult>();
        if(strInput.equals('*')){
            strInput = '';
        }
        String str = '%'+ strInput + '%';
		System.debug('str Input: '+ str);
		String oppId = relatedopportunityId;
		System.debug('Opportunity ID: ' +oppId);
        String strQueryField = '';
		//String sys = '\''+ syscode + '\'';
        List<String> fieldList = fieldAPINames.split(',');

        //check if Id is already been passed
        if(!fieldList.contains('Id')){
            fieldList.add('Id');
            strQueryField = String.join(fieldList, ',');
        }else {
            strQueryField = fieldAPINames;
        }

        String strQuery = 'SELECT ' + String.escapeSingleQuotes(strQueryField) + ', Start_Date__c, End_Date__c, Gross_Amount__c' +
                        + ' FROM ' 
                        + String.escapeSingleQuotes(objectName) 
                        + ' WHERE ' + filterFieldAPIName + '  LIKE \''  + str + '\'' + 'AND Opportunity__c = ' + '\''+oppId + '\'' + 'AND RecordType.Name != ' +  '\'' + 'Opportunity Budget' + '\''
                        + ' ORDER BY ' + filterFieldAPIName
                        + ' LIMIT 50';
                        
        System.debug('strQuery=' + strQuery);

        List<SObject> lstResult = database.query(strQuery);
        //create list of records that can be easily be parsable at js controller.
        //for(String strField:fieldList){
            //for(SObject sobj:lstResult){                
                //if(strField != 'Id'){
                    //SObjectQueryResult result = new SObjectQueryResult();
                    //result.recordId = (String) sobj.get('Id');
                    //result.recordName = (String) sobj.get(strField);
					//System.debug('sobj '+ sobj.Start_Date__c);
					////System.debug('startDate '+ (String) sobj.Start_Date__c);
                    //lstReturnResult.add(result);
                //}                
            //}
        //}

		for(SObject sobj:lstResult){                
            SObjectQueryResult result = new SObjectQueryResult();
            result.recordId = (String) sobj.get('Id');
            result.recordName = (String) sobj.get('Name');
			result.startDate = (Date) sobj.get('Start_Date__c');
			result.endDate = (Date) sobj.get('End_Date__c');
			result.gross = (Decimal) sobj.get('Gross_Amount__c');
			lstReturnResult.add(result);                        
        }

        return lstReturnResult;
    }
    
    public class SObjectQueryResult {
        @AuraEnabled
        public String recordId;

        @AuraEnabled
        public String recordName;

		@AuraEnabled
		public Date startDate;

		@AuraEnabled
		public Date endDate;

		@AuraEnabled
		public Decimal gross;
    }

}