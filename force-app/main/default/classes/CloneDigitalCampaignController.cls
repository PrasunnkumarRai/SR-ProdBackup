public class CloneDigitalCampaignController {
    public static String myGlobalVariable = '';
    @AuraEnabled
    public static Digital_Campaign__c cloneThisDigitalCampaign( String recordId ){
        System.debug(' recordId::'+ recordId);
       myGlobalVariable =recordId;
        try{
            Set<String> InvReqRecTypes = new Set<String>{'Ads Everywhere', 'New Ads Everywhere', 'Display Custom', 'Pre-roll Custom', 'Addressable Display', 'Addressable Video','Title in Guide','Programmatic Guaranteed','Programmatic Non Guaranteed'};    //SRSF-1142 
            String campaignQuery = getCreatableFieldsSOQL('Digital_Campaign__c', 'Id=:recordId');
            Digital_Campaign__c originalCampaign = (Digital_Campaign__c) Database.query( campaignQuery );
                       
         //SRSF-4513 Block to clone DC if it consist Deactivated Data Catalog
          List<string> Inactivelst=new List<string>();
          string inActiveint;
          boolean Dcclone;
          List<Data_Catalog__c> DeactivatedInterest=[SELECT Id,Display_Text__c,Political__c,Restricted_Interest__c,CPM__c,Export_Key__c  FROM Data_Catalog__c WHERE isActive__c = false];
          system.debug('DeactivatedInterest'+DeactivatedInterest.size());
          for(Data_Catalog__c datacatalog:DeactivatedInterest){
           inActiveint= datacatalog.Id;
            if(inActiveint !=null){
                Inactivelst.add(inActiveint);
            }
           
           }
             String deactiveIntr = String.join(Inactivelst, ',');     
             system.debug(' deactiveIntr'+ deactiveIntr);
         
            for(string s:Inactivelst){
             if(originalCampaign.Selected_Data_Catalog_Id__c!=null && s !=null && string.isNotBlank(originalCampaign.Selected_Data_Catalog_Id__c) && originalCampaign.Selected_Data_Catalog_Id__c.contains(s)){
               Dcclone=true;
                break;
                 
             }else{
                 Dcclone=false;
             }
            }
            if(Dcclone == true){
                throw new DMLException('This DC contains deactivated data catalog interests. It cannot be cloned. Please create a new DC with new/refreshed interests');
            }
        
          //SRSF-4513

            
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
            // Added SRSF-3206
            clonedCampaign.Is_Expedite_Approved__c = 'FALSE';
            // END SRSF-3206
            //
            // Added SRSF-3936
            clonedCampaign.Product_Vendor__c = null;
            clonedCampaign.No_AudienceTrak_Proposal__c = false;
            // END SRSF-3936
            //
            // Added SRSF-3841
            clonedCampaign.Online_Legacy_Campaign__c = false;
            // END SRSF-3841
            //
            // Added SRSF-1454
            clonedCampaign.Has_hit_03_Digital_Ops_In_Progress__c = false;
            clonedCampaign.Has_hit_09_Live__c = false;
            clonedCampaign.Inventory_Check_Complete__c = false;
            // END SRSF-1454
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
            clonedCampaign.Min_Pending_Creative_Start_Date__c = null; //SRSF-4308K
            clonedCampaign.Min_Pending_Creative_Start_Date_Record_S__c = null; //SRSF-4408K
            clonedCampaign.Yield_Exclude_override__c = false;
            clonedCampaign.Ampersand_Prefix__c = null;
            
            // Added for SRSF-4797
            clonedCampaign.Date_Last_Submitted__c = null;
            clonedCampaign.TotalNumberOfDays__c = null;                    
            
            //Added for SRSF-1402
            clonedCampaign.Has_hit_03_Submitted_to_Digital_Ops__c = false;
             
            //SRSF-1142 Start
            Map<Id, RecordType> DCReqTypeMap = new Map<Id, RecordType>([SELECT Id, Name, DeveloperName FROM RecordType where sObjectType = 'Digital_Campaign__c']);
            String RTName = DCReqTypeMap.get(clonedCampaign.RecordTypeId).Name;
            System.debug('RTName::'+RTName);
            
         
          
            Id RTId = clonedCampaign.RecordTypeId;
           // String DayParting = clonedCampaign.Day_of_Week__c;
            //  System.debug('DayParting::::'+DayParting);
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
            /*//if the recordtype is belongs to Addressable Display/Addressable Video/Ads Everywhere/Display Custom/New Ads Everywhere/Pre-roll Custom its automatically flips to Inventory RT
            set<string> setFlipsToInventory = new set<string>();
            setFlipsToInventory.add('Addressable Display');
            setFlipsToInventory.add('Addressable Video');
            setFlipsToInventory.add('Ads Everywhere');
            setFlipsToInventory.add('Display Custom');
            setFlipsToInventory.add('New Ads Everywhere');
            setFlipsToInventory.add('Pre-roll Custom');*/
            // SRSF-1142 End
            // SRSF-1146
            RTName = DCReqTypeMap.get(clonedCampaign.RecordTypeId).Name;
            if (RTName.startsWith('Inventory Request - ')) {
                clonedCampaign.Status__c = 'Draft Plan'; 
            } else {
                clonedCampaign.Status__c = '01 Draft Campaign';
            }
            // SRSF-1146 end
            
            //Added for OMS functionality
            clonedCampaign.Operative_ID__c = null;
            clonedCampaign.CPM_Negotiat__c = null;
            clonedCampaign.DSL_Approval_Status__c = null;
            boolean isRT = false;
            for(String configuredRecordType : System.Label.DC_RateClassificationCloneRecordType.split(',')){
                if(RTName == configuredRecordType){
                    isRT = true;
                    break;
                }
            }
            if(isRT == false){
                clonedCampaign.Rate_Classification__c = null;
            }
            //clonedCampaign.VAST_Tag__c = 'No';
            clonedCampaign.OMS_Error_Description__c = null;
            clonedCampaign.Rate_Card_CPM__c = null;
            clonedCampaign.License_End_Date__c = null;
            clonedCampaign.X1x1_Pixel__c = false;
            clonedCampaign.Original_Digital_Campaign__c = originalCampaign.Id;
                        
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
            /*         RecordType rt = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Id=:clonedCampaign.RecordTypeId limit 1];
                       if( rt.DeveloperName == 'Display' ){
                            clonedCampaign.Status__c = '02 New Campaign';
            } */
           // List<Digital_Campaign__c> data = getDayPartingData();
           // System.debug('data :::'+data);
     //      System.debug( 'get fubc'+data);
            //timezone logic
            String timezone = getTimeZoneValue(clonedCampaign.DMAs__c, clonedCampaign.Spectrum_Reach_Zones__c, clonedCampaign.State__c,clonedCampaign.Zip_Codes__c,clonedCampaign.CustomZipCode__c,clonedCampaign.OwnerId );
            System.debug('timezone' +timezone);
            if(string.isNotBlank(timezone)){
                clonedCampaign.Time_Zones__c = timezone;
            }
            insert clonedCampaign;
            
        /*
            Integer creativeCount = [SELECT Count() from Digital_Creative__c WHERE Digital_Campaign__c=:recordId];
            if( creativeCount > 0 ){
                String creativeQuery = getCreatableFieldsSOQL('Digital_Creative__c', 'Digital_Campaign__c=:recordId');
                list<Digital_Creative__c> clonedCreatives = new list<Digital_Creative__c>();
                for( Digital_Creative__c originalCreative : Database.query( creativeQuery ) ){
                    Digital_Creative__c clonedCreative = originalCreative.clone(false, true, false, false);
                    clonedCreative.Digital_Campaign__c = clonedCampaign.Id;
                    clonedCreatives.add( clonedCreative );
                }
                
                if( !clonedCreatives.isEmpty() ){
                    insert clonedCreatives;
                }
            }
        */
                System.debug('----> New DC: '+clonedCampaign);
                return [SELECT Id, Name FROM Digital_Campaign__c WHERE Id=:clonedCampaign.Id limit 1];
            }catch( Exception ex){
                System.debug(ex.getMessage()+'::'+ex.getLineNumber());
                throw new DMLException(ex.getMessage());
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
    
    public static string getTimeZoneValue(String DMAValue, String ZoneValue, String StateValue, String customZipValue, Boolean customZip, String OwnerID){
        String timezone;
        String firstZip;
        List<string> locations = new List<string>();
        if(!string.isBlank(DMAValue) && DMAValue != 'None'){
            System.debug('DMAValue'+DMAValue);
            locations = DMAValue.split(',');
            System.debug('location' +locations);
            timezone = OMS_NetworkExController.getTimezoneByDMA(locations);
            System.debug('Inside DMA@@' +timezone);
        }
        else if(!string.isBlank(ZoneValue) && ZoneValue != 'None'){
            System.debug('Inside Zone');
            locations = ZoneValue.split(',');
            timezone = OMS_NetworkExController.getTimezoneByZones(locations);
            System.debug('Inside Zone@@' +timezone);
        }
        else if(!string.isBlank(StateValue) && StateValue != 'None'){
            System.debug('Inside State');
            locations = StateValue.split(',');
            timezone = OMS_NetworkExController.getTimezoneByStates(locations);
            System.debug('Inside State@@' +timezone);
        }
        else if((string.isBlank(DMAValue) || DMAValue == 'None') && (string.isBlank(ZoneValue) || ZoneValue == 'None') && (string.isBlank(StateValue) || StateValue == 'None') && customZip == true){
            System.debug('Inside custom Zip ');
            locations = customZipValue.split(',');
            System.debug('locations custom Zip' +locations);
            firstZip = locations[0];
            System.debug('firstZip custom Zip' +firstZip);  
            timezone = OMS_NetworkExController.getCustomZipCodeMapping(customZip, firstZip,OwnerID);
            System.debug('Inside custom@@' +timezone);
        }
        System.debug('timezone@@' +timezone);
        return timezone;       
    }
   //TIG 
     @AuraEnabled   
    public static List<Digital_Campaign__c> getDayPartingData(String recordId){ 
       // List<String> listOfString = new List<String>();
      // String   listOfString = ;
         System.debug('DayParting::::'+[SELECT Id, Day_of_Week__c FROM Digital_Campaign__c where Id=: recordId]);
        return [SELECT Day_of_Week__c FROM Digital_Campaign__c where Id=: recordId];
    }//TIG
}