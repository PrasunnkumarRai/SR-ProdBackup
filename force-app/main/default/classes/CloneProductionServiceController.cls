public class CloneProductionServiceController {
    
    @AuraEnabled 
    public static ResponseWrapper getProductionServiceRecordTypes( Id recordId ){
        list<RecordType> lstRecordTypes = new list<RecordType>();
        Schema.DescribeSObjectResult resultObj = Production_Service__c.SObjectType.getDescribe();
		List<Schema.RecordTypeInfo> lstRTInfos = resultObj.getRecordTypeInfos();
        for( Schema.RecordTypeInfo rtInfo : lstRTInfos ){
            if( rtInfo.isAvailable() && rtInfo.getName() != 'Master' && (rtInfo.getName().indexOf('LOCKED')==-1) ){
                lstRecordTypes.add( new RecordType(Id=rtInfo.getRecordTypeId(), Name=rtInfo.getName()));
            }
        } 
        
        Production_Service__c objPService = [SELECT RecordTypeId FROM Production_Service__c WHERE Id=:recordId];
        return new ResponseWrapper( objPService.RecordTypeId, lstRecordTypes );        
        //return (Sobject)JSON.deserialize( '{ "currentRTId":"'+objPService.RecordTypeId+'", "recordTypes": '+JSON.serialize( lstRecordTypes )+'}', SObject.class );
    }
    
	@AuraEnabled
    public static Production_Service__c cloneThisProductionService( String recordId, String recordTypeId ){
        String campaignQuery = getCreatableFieldsSOQL('Production_Service__c', 'Id=:recordId');
        Production_Service__c originalPService = (Production_Service__c) Database.query( campaignQuery );
        Production_Service__c clonedPService = originalPService.clone(false, true, false, false);
        clonedPService.RecordTypeId = recordTypeId;
        clonedPService.Name += ' - Clone';
        //added for SRSF-2000
        clonedPService.Linear_Order_Status__c = '';
        clonedPService.Digital_Order_Status__c = '';
        clonedPService.Date_Completed_Billing_Submitted__c = null;
        clonedPService.Billed__c = false;
        clonedPService.Proposal__c = null;
        clonedPService.IMN_ID__c = null;
        clonedPService.Integrated_with_IMN__c = false;
        clonedPService.Boomi_Error_Message__c = null;
        clonedPService.FSA_Amount__c = null;
        clonedPService.KDD__c = null;
        clonedPService.Rate_Card_Value__c = null;
        clonedPService.IMN_Sync_Status__c='';
        clonedPService.Work_Request_ID__c=null;
        insert clonedPService;
        return [SELECT Id, Name FROM Production_Service__c WHERE Id=:clonedPService.Id limit 1];
    }
    
    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    @AuraEnabled
    public static string getCreatableFieldsSOQL(String objectName, String whereClause){
        String selects = '';
        if (whereClause == null || whereClause == ''){ return null; }
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectedFields = new list<string>();
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectedFields.add(fd.getName());
                }
            }
        }
        if (!selectedFields.isEmpty()){
        	selects = String.join(selectedFields, ', ');
        }
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
    }
    
    public class ResponseWrapper{
        @AuraEnabled
        public String currentRTId;
        @AuraEnabled
        public list<RecordType> recordTypes;
        
        public ResponseWrapper( String currentRTId, list<RecordType> recordTypes ){
            this.currentRTId = currentRTId;
            this.recordTypes = recordTypes;
        }
    }
}