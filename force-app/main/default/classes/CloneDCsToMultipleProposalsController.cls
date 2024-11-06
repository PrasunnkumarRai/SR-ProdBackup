public inherited sharing class CloneDCsToMultipleProposalsController {
    @AuraEnabled
    public static List<LookupSearchResult> getRecords(String searchTerm,List<String> selectedIds,String searchType, String advertiser,String timId,String pilotOrderId) {
        searchTerm += '*';
        System.debug('searchTerm' +searchTerm);
        //SRSF-4454k:Added Custom label to store the proposal limit.
         String cLabel = System.Label.DCS_Proposals_Limit;
         Integer intValue = Integer.valueOf(cLabel);
		List<List<SObject>> searchResults;
        searchResults = [
                        FIND :searchTerm
                        IN ALL FIELDS
                        RETURNING
                        Proposal__c(Id, Name, Advertiser__c, TIM_Id__c,Pilot_Order_ID__c WHERE id NOT IN :selectedIds AND Advertiser__c = :advertiser AND (Pilot_Order_ID__c =:pilotOrderId OR TIM_Id__c =:timId ))
                        LIMIT :intValue
                    ];

                    System.debug('searchResults ::: ' + searchResults);
        
        // Prepare results
		List<LookupSearchResult> results = new List<LookupSearchResult> ();

		// Extract Accounts & convert them into LookupSearchResult
		String userIcon = 'standard:user';
		Proposal__c[] propRecords = ((List<Proposal__c>) searchResults[0]);
        System.debug('propRecords' +propRecords);
		for (Proposal__c p : propRecords) {
			results.add(
			            new LookupSearchResult(
                                            p.Id,
                                            'Proposal__c',
                                            userIcon,
                                            p.Name,
                                            ''
                                        )
			);
		}
		System.debug('results: '+results);
		return results;
    }

    @AuraEnabled
    public static List<DC_Wrap> getDCData(String propId) {

        List<DC_Wrap> dcWrapList = new List<DC_Wrap>();
        List<Digital_Campaign__c> dcRecords = [SELECT Id,Name,Advertiser__r.Name,Status__c,Campaign_Name__c,RecordTypeId,RecordType.Name,Campaign_Start_Date__c, Campaign_End_Date__c,Proposal__c,Opportunity__c,Pilot_Order_ID__c,TIM_ID__c from Digital_Campaign__c where Proposal__c =:propId limit 1000];
        if(!dcRecords.isEmpty()){
            for(Digital_Campaign__c dc : dcRecords){
                DC_Wrap objDC_Wrap = new DC_Wrap();
                objDC_Wrap.dc = dc;
                objDC_Wrap.dcName = dc.Name;
                objDC_Wrap.strDcStDate = null;
                objDC_Wrap.strDcEndDate = null;
                objDC_Wrap.dcStatus = dc.Status__c;
                objDC_Wrap.dcCampaignName = dc.Campaign_Name__c;
                objDC_Wrap.dcRecordTypeName = dc.RecordType.Name;
                objDC_Wrap.dcAdvertiserName = dc.Advertiser__r.Name;
                objDC_Wrap.dcTimOrderID = dc.TIM_ID__c;
                objDC_Wrap.dcPilotOrderID = dc.Pilot_Order_ID__c;
                    
                dcWrapList.add(objDC_Wrap);
            }
        }

        return dcWrapList;

    }

    @AuraEnabled
    public static String createMultipleDigCamp(String wrapperDC, List<String> dcIDs, List<String> propIds){
        String strResponse = '';
        try {
            List<DC_Wrap> lstDCWrap = (List<DC_Wrap>)JSON.deserialize(wrapperDC, list<DC_Wrap>.class);
            String dcQueryByIds = getCreatableFieldsSOQL('Digital_Campaign__c', 'Id in :dcIDs');
            List<Digital_Campaign__c> dcRecords = (List<Digital_Campaign__c>) Database.query( dcQueryByIds );
            List<Digital_Campaign__c> newListDCs = new List<Digital_Campaign__c>();
            for(String propId : propIds){
                newListDCs.addAll(cloneMultipleDcs(lstDCWrap,propId,dcRecords));
            }
            if(!newListDCs.isEmpty()){
                Insert newListDCs;  
                strResponse = 'successful';
            }else{
                strResponse = 'failed';
            } 
        } catch(exception ex){
                    //Handling errors
                    system.debug('--->'+Ex.getLineNumber()+' '+ ex.getMessage());
                    strResponse =  ex.getMessage();
        }
        return strResponse;
    }

    public static list<Digital_Campaign__c> cloneMultipleDcs(list<DC_Wrap> lstDCWrap,String propId, List<Digital_Campaign__c> listdcs){
        list<Digital_Campaign__c> newDCList = new list<Digital_Campaign__c>();
        system.debug(lstDCWrap);
        try{
            Set<String> InvReqRecTypes = new Set<String>{'Ads Everywhere', 'New Ads Everywhere', 'Display Custom', 'Pre-roll Custom', 'Addressable Display', 'Addressable Video'};
            if(!lstDCWrap.isEmpty()){
                for(Digital_Campaign__c dc : listdcs){
                    Digital_Campaign__c objClone = dc.clone(false,false,false,false);
                    objClone.Proposal__c = propId;
                    objClone.Bypass_Apex_Execution__c = true;

                    for(DC_Wrap wr : lstDCWrap){
                        System.debug('wr' +wr);
                        System.debug('Digital_Campaign__c' +wr.dc);
                        if(wr.dc.Id == dc.Id){
                            objClone.Campaign_Start_Date__c = wr.strDcStDate;
                            objClone.Campaign_End_Date__c = wr.strDcEndDate;
                        }
                    }
                    objClone.Sales_Cannot_Edit_Detail__c = false;
                    objClone.Sales_Cannot_Edit_Status__c = false;
                    objClone.Is_Expedite_Approved__c = 'FALSE';
                    objClone.Product_Vendor__c = null;
                    objClone.No_AudienceTrak_Proposal__c = false;
                    objClone.Has_hit_03_Digital_Ops_In_Progress__c = false;
                    objClone.Has_hit_09_Live__c = false;
                    objClone.Inventory_Check_Complete__c = false;
                    objClone.IsFromClone__c = true;
                    objClone.CloneNameChanged__c = false;
                    objClone.CloneProposalIdChanged__c = false;
                    objClone.Max_Trafficked_Creative_End_Date__c = null;
                    objClone.Max_Pending_Creative_End_Date__c = null;
                    objClone.Max_Pending_Creative_End_Date_Record_St__c = null;
                    objClone.Yield_Exclude_override__c = false;
                    objClone.Ampersand_Prefix__c = null;
                    objClone.Has_hit_03_Submitted_to_Digital_Ops__c = false;

                    Map<Id, RecordType> DCReqTypeMap = new Map<Id, RecordType>([SELECT Id, Name, DeveloperName FROM RecordType where sObjectType = 'Digital_Campaign__c']);
                    String RTName = DCReqTypeMap.get(objClone.RecordTypeId).Name;
                    System.debug('RTName::'+RTName);
                    Id RTId = objClone.RecordTypeId;
                    if(RTName == 'Ads Everywhere' || RTName == 'Inventory Request - Ads Everywhere' || RTName == 'Inventory Request - Revision - Ads Everywhere'){
                        RTName = RTName.replace('Ads ', 'New Ads ');
                        RTId = [SELECT Id FROM RecordType where sObjectType = 'Digital_Campaign__c' and Name=:RTName].Id;
                        objClone.RecordTypeId = RTId;
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
                
                    objClone.RecordTypeId = RTId;
                    RTName = DCReqTypeMap.get(objClone.RecordTypeId).Name;
                    if (RTName.startsWith('Inventory Request - ')) {
                        objClone.Status__c = 'Draft Plan'; 
                    } else {
                        objClone.Status__c = '01 Draft Campaign';
                    }


                    objClone.Operative_ID__c = null;
                    objClone.CPM_Negotiat__c = null;
                    objClone.DSL_Approval_Status__c = null;
                    boolean isRT = false;
                    for(String configuredRecordType : System.Label.DC_RateClassificationCloneRecordType.split(',')){
                        if(RTName == configuredRecordType){
                            isRT = true;
                            break;
                        }
                    }
                    if(isRT == false){
                        objClone.Rate_Classification__c = null;
                    }
                    //clonedCampaign.VAST_Tag__c = 'No';
                    objClone.OMS_Error_Description__c = null;
                    objClone.Rate_Card_CPM__c = null;
                    objClone.License_End_Date__c = null;
                    objClone.X1x1_Pixel__c = false;
                    objClone.Original_Digital_Campaign__c = dc.id;
                                
                    //StreamingTV
                    if(!(RTName.contains('Addressable Display') || RTName.contains('Addressable Video'))){
                        objClone.Total_Impressions__c = null;
                        objClone.Gross_Campaign_Cost__c = null;
                    }
                    //clonedCampaign.Gross_CPM__c = null;
                    objClone.Operative_Sales_Order_Hyperlink__c = null;
                    if(RTName.contains('New Ads')){
                        objClone.Flight_Dates_Backend__c = null;
                    }
                    newDCList.add(objClone);
                }
            }
        }catch( Exception ex){
            System.debug(ex.getMessage()+'::'+ex.getLineNumber());
            throw new DMLException(ex.getMessage());
        }
        return newDCList;
    }

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

    

    public class DC_Wrap{
        @AuraEnabled public Digital_Campaign__c dc {get;set;}
        @AuraEnabled public string dcAdvertiserName {get;set;} 
        @AuraEnabled public string dcTimOrderID {get;set;} 
        @AuraEnabled public string dcPilotOrderID {get;set;} 
        @AuraEnabled public string dcRecordTypeName {get;set;}
        @AuraEnabled public string dcCampaignName {get;set;}
        @AuraEnabled public Date strDcStDate {get;set;} 
        @AuraEnabled public Date strDcEndDate {get;set;}
        @AuraEnabled public String dcStatus {get;set;} //Status__c
        @AuraEnabled public String dcName {get;set;} //Nam
    }
}