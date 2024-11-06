public class DcSocialExportController {

@AuraEnabled(cacheable=true)
    public static List<Digital_Campaign__c> dcSocialRecords(String dcRecordId){
        String dcFieldsToExport = System.Label.FieldsForSocialExport;
        String dccFieldsToExport = System.Label.DCCFieldsToExport;
        String dccSatausToExclude = System.Label.dccStatusExcludeFromExport;
        List<String> dccSatausToExcludeList = new List<String>();
        dccSatausToExcludeList = dccSatausToExclude.split(',');
        String dcRecordQuery = 'Select id,' + dcFieldsToExport + ', (select id, ' + dccFieldsToExport + ' from Digital_Creatives__r where Creative_End_Date__c >= TODAY AND Status__c NOT IN ' + dccSatausToExcludeList + ') from Digital_Campaign__c Where id=:dcRecordId' ;
        List<Digital_Campaign__c> dcRecord = database.query(dcRecordQuery);
        System.debug(dcRecord);
        return dcRecord;
    }

}