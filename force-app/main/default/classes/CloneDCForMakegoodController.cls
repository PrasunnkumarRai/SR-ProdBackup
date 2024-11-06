public class CloneDCForMakegoodController {
    
    public static string makegoodRecordType;
    
    @AuraEnabled
    public static Digital_Campaign__c cloneThisDigitalCampaign( String recordId ){
        try{
            Set<String> InvReqRecTypes = new Set<String>{'Ads Everywhere', 'New Ads Everywhere', 'Display Custom', 'Pre-roll Custom', 'Addressable Display', 'Addressable Video'};    //SRSF-1142 
            String campaignQuery = getCreatableFieldsSOQL('Digital_Campaign__c', 'Id=:recordId');
            Digital_Campaign__c originalCampaign = (Digital_Campaign__c) Database.query( campaignQuery );
            if(originalCampaign.IsMakegoodDC__c == true){
                throw new DMLException('Makegood DCs cannot be cloned.');
            }            
            Digital_Campaign__c clonedCampaign = originalCampaign.clone(false, true, false, false);
        // SRSF-1146   clonedCampaign.Status__c = '01 Draft Campaign';  
            clonedCampaign.Campaign_Start_Date__c = clonedCampaign.Campaign_End_Date__c = null;
            // Added SRSF-1526
            clonedCampaign.Bypass_Apex_Execution__c = true;
            clonedCampaign.Sales_Cannot_Edit_Detail__c = false;
            clonedCampaign.Sales_Cannot_Edit_Status__c = false;
            // END SRSF-1526
            //         
            // Added SRSF-1454
            clonedCampaign.Has_hit_03_Digital_Ops_In_Progress__c = false;
            clonedCampaign.Has_hit_09_Live__c = false;
            clonedCampaign.Inventory_Check_Complete__c = false;
            // END SRSF-1454
            //
            // Added SRSF-3841
            clonedCampaign.Online_Legacy_Campaign__c = false;
            // END SRSF-3841
            // 
            // Added for SRSF-444
            clonedCampaign.IsFromClone__c = true;
            clonedCampaign.CloneNameChanged__c = false;
            clonedCampaign.CloneProposalIdChanged__c = false;
            // END SRSF-444
            
            // Added for SRSF-1628
            clonedCampaign.Max_Trafficked_Creative_End_Date__c = null;
            clonedCampaign.Max_Pending_Creative_End_Date__c = null;
            clonedCampaign.Max_Pending_Creative_End_Date_Record_St__c = null;
            
            //Added for SRSF-1402
            clonedCampaign.Has_hit_03_Submitted_to_Digital_Ops__c = false;
             
            //SRSF-1142 Start
            Map<Id, RecordType> DCReqTypeMap = new Map<Id, RecordType>([SELECT Id, Name, DeveloperName FROM RecordType where sObjectType = 'Digital_Campaign__c']);
            String RTName = DCReqTypeMap.get(clonedCampaign.RecordTypeId).Name;
            System.debug('RTName::'+RTName);
            Id RTId = clonedCampaign.RecordTypeId;
            System.debug('RTId@@@@' +RTId);
            //Ads Everywhere RT clone is no more available from SRSF-1873(OMS Integration)
            if(RTName == 'Ads Everywhere' || RTName == 'Inventory Request - Ads Everywhere' || RTName == 'Inventory Request - Revision - Ads Everywhere'){
                RTName = RTName.replace('Ads ', 'New Ads ');
                RTId = [SELECT Id FROM RecordType where sObjectType = 'Digital_Campaign__c' and Name=:RTName].Id;
                clonedCampaign.RecordTypeId = RTId;
            }
            //If the RT is 'Inventory Request - Revision - Ads Everywhere' then we need to change 'Inventory Request - Ads Everywhere'
            if(RTName.contains('Revision')){
                RTName = RTName.replace('Inventory Request - Revision','Inventory Request');
                list<RecordType> lstRTId = [SELECT Id FROM RecordType where sObjectType = 'Digital_Campaign__c' and Name=:RTName];
                if( lstRTId!=null && !lstRTId.isEmpty() )
                    RTId = lstRTId[0].Id;
            }
            
            if (InvReqRecTypes.contains(RTName)) {
                RTName = 'Inventory Request - ' + RTName;
                for (RecordType rt : DCReqTypeMap.values()) {
                    if (rt.Name == RTName) {
                        RTId = rt.Id;
                        break;
                    }
                }
                
            }
           
            clonedCampaign.RecordTypeId = RTId;
            System.debug('clonedCampaign.RecordTypeId' +clonedCampaign.RecordTypeId);
            // SRSF-1142 End
            // SRSF-1146
            RTName = DCReqTypeMap.get(clonedCampaign.RecordTypeId).Name;
            System.debug('clonedCampaign RTName' +RTName);
            /*if (RTName.startsWith('Makegood - Inventory Request - ')) {
                clonedCampaign.Status__c = 'Draft Plan'; 
            } else {
                clonedCampaign.Status__c = '01 Draft Campaign';
            }*/
            // SRSF-1146 end
            
            //Added for OMS functionality
            clonedCampaign.Operative_ID__c = null;
            clonedCampaign.Rate_Classification__c = null;
            //clonedCampaign.VAST_Tag__c = 'No';
            clonedCampaign.OMS_Error_Description__c = null;
            clonedCampaign.Rate_Card_CPM__c = null;
            clonedCampaign.License_End_Date__c = null;
            clonedCampaign.X1x1_Pixel__c = false;
            clonedCampaign.Product_Type__c = originalCampaign.Product_Type__c;
            clonedCampaign.Desired_Budget__c = null;
            clonedCampaign.Gross_Campaign_Cost__c = null;
            clonedCampaign.Total_Impressions__c = null;
           // clonedCampaign.AdsE_Genre_s__c = null;
            clonedCampaign.Original_Digital_Campaign__c = originalCampaign.Id;
            clonedCampaign.IsMakegoodDC__c = true;


            
            //StreamingTV
            if(!(RTName.contains('Addressable Display') || RTName.contains('Addressable Video'))){
                clonedCampaign.Total_Impressions__c = null;
                clonedCampaign.Gross_Campaign_Cost__c = null;
            }
            //clonedCampaign.Gross_CPM__c = null;
            clonedCampaign.Operative_Sales_Order_Hyperlink__c = null;
            if(RTName.contains('New Ads')){
                clonedCampaign.Flight_Dates_Backend__c = null;
            }
            String makegoodDCId = getMakeGoodDCId(clonedCampaign.RecordTypeId);
            System.debug('makegoodDCId' +makegoodDCId);
            if(String.isNotBlank(makegoodDCId)){
                System.debug('@@@Makegood');
                clonedCampaign.RecordTypeId = makegoodDCId;
            }
            if (String.isNotBlank(makegoodRecordType) && makegoodRecordType.startsWith('Makegood - Inventory Request - ')) {
                System.debug('@@@Makegood Inventroy IF');
                clonedCampaign.Status__c = 'Draft Plan'; 
            } else {
                 System.debug('@@@Makegood Inventroy ELSE');
                clonedCampaign.Status__c = '01 Draft Campaign';
            }
            System.debug('----> New DC BEFORE: '+clonedCampaign);
            insert clonedCampaign;
            System.debug('----> New DC: '+clonedCampaign);
            return [SELECT Id, Name FROM Digital_Campaign__c WHERE Id=:clonedCampaign.Id limit 1];
            }catch( Exception ex){
                System.debug(ex.getMessage()+'::'+ex.getLineNumber());
                if(!test.isRunningTest()){
                    throw new DMLException(ex.getMessage());
                }else{
                    return null;
                }
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
    
    public static string getMakeGoodDCId(String dcRTId){
        RecordType objRT = [Select Id,name From RecordType where sobjecttype = 'Digital_Campaign__c' AND Id=: dcRTId];
        String recordtypeName = objRT.Name;
        System.debug('Before::'+recordtypeName);
        map<string,string> mapDCToMakegoodDC = new map<string,string>();
        for(DC_Makegood_Clone_Matrix__mdt objCloneMatrix : [SELECT From_DC__c,Makegood_DC__c FROM DC_Makegood_Clone_Matrix__mdt WHERE Makegood_DC__c!=null AND From_DC__c!=null]){
            mapDCToMakegoodDC.put(objCloneMatrix.From_DC__c, objCloneMatrix.Makegood_DC__c);
            System.debug('objCloneMatrix.From_DC__c'+objCloneMatrix.From_DC__c);
            System.debug('objCloneMatrix.Makegood_DC__c'+objCloneMatrix.Makegood_DC__c);
        }
        makegoodRecordType = mapDCToMakegoodDC.get(recordtypeName);
        System.debug('After::'+makegoodRecordType);
        objRT = [Select Id,name From RecordType where sobjecttype = 'Digital_Campaign__c' AND Name=:makegoodRecordType];
        return objRT.Id;
    }
}