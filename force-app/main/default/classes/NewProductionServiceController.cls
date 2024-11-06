public class NewProductionServiceController {
    
    @AuraEnabled
    public static List<Support_Request__c> getSupportRequestData(Id recordId){
        List<Support_Request__c> dataSR = [SELECT Id, Sponsorship_Type__c FROM Support_Request__c WHERE Id=:recordId];
        System.debug('dataSR' + dataSR);
        return dataSR;     
    }
    
    @AuraEnabled
    public static list<RecordType> getProductionServiceRecordTypes(){
        list<RecordType> lstRecordTypes = new list<RecordType>();
        Schema.DescribeSObjectResult resultObj = Production_Service__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> lstRTInfos = resultObj.getRecordTypeInfos();
        for( Schema.RecordTypeInfo rtInfo : lstRTInfos ){
            if( rtInfo.isAvailable() && rtInfo.getName() != 'Master' && (rtInfo.getName().tolowercase().indexOf('locked')==-1)){
                lstRecordTypes.add( new RecordType(Id=rtInfo.getRecordTypeId(), Name=rtInfo.getName()));
            }
        }
        return lstRecordTypes;
    }
    
    @AuraEnabled
    public static Map<String, object> getSupportRequestRecord( Id recordId, Id selectedDCRT ){        
        Support_Request__c objSR = [SELECT Id, Account_Executive__c, Sales_Office__c, Region__c, Division__c, Type_of_Request__c,Recordtype.Name FROM Support_Request__c WHERE Id=:recordId];
        Map<String, object> pre_populatedFields = new Map<String, object>();
        if( objSR.Recordtype.Name =='Production' && objSR.Type_of_Request__c=='Pre-contract consult' )
            return pre_populatedFields;
        pre_populatedFields.put('Support_Request__c', recordId );        
        pre_populatedFields.put('Account_Executive__c', objSR.Account_Executive__c );
        pre_populatedFields.put('Sales_Office__c', objSR.Sales_Office__c );
        pre_populatedFields.put('Region__c', objSR.Region__c );
        pre_populatedFields.put('Division__c', objSR.Division__c );
        return pre_populatedFields;
    }

    // START: SRSF-4026
    @AuraEnabled
    public static Production_Service__c getProductionService (Id recordId){
        if(recordId!=null){
            Production_Service__c ps = [SELECT Id, Support_Request__c, Support_Request__r.Status__c, Submit_Support_Request__c FROM Production_Service__c WHERE Id=:recordId];
            return ps;
        } else return null;    
    }

    @AuraEnabled
    public static void updateSupportRequest(Id recordId){
        
        if(recordId!=null){
            Production_Service__c objPS = [SELECT Id, Support_Request__c, Submit_Support_Request__c, Support_Request__r.Status__c FROM Production_Service__c WHERE Submit_Support_Request__c=true AND Support_Request__r.Status__c='Pending' AND Id=:recordId];
            objPS.Support_Request__r.Status__c = 'Submitted to Kernel';
            UPDATE objPS.Support_Request__r;                  
        }     
    }

    @AuraEnabled
    public static void updateProductionService(Id recordId){
        if(recordId!=null){        
            Production_Service__c objPS = [SELECT Id, Submit_Support_Request__c FROM Production_Service__c WHERE Submit_Support_Request__c=true AND Id=:recordId];
        
            objPS.Submit_Support_Request__c = false;
            UPDATE objPS;
        }                    
    }
    //END: SRSF-4026    
}