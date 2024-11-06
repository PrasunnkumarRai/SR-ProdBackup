public class cloneSupportRequestController {
    
    @AuraEnabled
    public static Support_Request__c cloneThisSupportRequest( String recordId ){
        string loggedinuser = userinfo.getuserid();
        Support_Request__c SR = [Select id,opportunity__c from Support_Request__c where id=:recordId limit 1];
        Opportunity opp = [select id,OwnerId,(SELECT Id,OpportunityId,UserId FROM OpportunityTeamMembers where UserId =: loggedinuser) from Opportunity where id=:SR.Opportunity__c limit 1];
        if(opp.OpportunityTeamMembers.size() >0 || opp.OwnerID == loggedinuser){
            String recordQuery = getCreatableFieldsSOQL('Support_Request__c', 'Id = :recordId');
        Support_Request__c originalRecord = (Support_Request__c) Database.query( recordQuery );
        Support_Request__c newRecord = originalRecord.clone(false, false, false, false);
        newRecord.IsClone__c = true;    // SRSF-576
        newRecord.Bypass_Apex_Execution__c = true;
        newRecord.Status__c = 'Pending'; // set status of new cloned record
        newRecord.Name += ' - Clone'; // Add - Clone to the end of the name of the cloned record.  Users can overwrite but will help distinguish between the cloned record.
        newRecord.IsClone__c = true; // set iscloned checkbox to true to avoid workflow that updates status to Submitted to Kernel so users can update cloned record.
        // SRSF-1200
        newRecord.Date_Time_Completed__c = null;
        newRecord.Date_Time_Submitted__c = null;
        newRecord.Working__c = null;
        // end SRSF-1200
        if (originalRecord.Status__c == 'Completed by Kernel') {    // is a Production rectype, so these fields should be visible
            newRecord.Status__c = 'Pending';
            newRecord.Type_of_Request__c = 'Post Sale Production Request';
        }
        insert newRecord;

        System.debug('******DEBUG****** New SR: '+ newRecord);
        return newRecord;
        }else{
            return null;
        }
        
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
}