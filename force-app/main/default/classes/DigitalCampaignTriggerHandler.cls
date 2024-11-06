/*
Customer/Project:   Spectrum Reach 
Class name:         DigitalCampaignTriggerHandler
Author/Date:        John King    6/2/2017
Release:            TBD
Related US:         264, 97
Purpose:            Provides handler methods for the Digital_Campaign__c Trigger
Modified:           1/19/2018 - Brett Ballantyne - Added modifications for SRSF-716

// This should be used in conjunction with the ApexTriggerComprehensive.trigger template
// The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

*/

public with sharing class DigitalCampaignTriggerHandler {
    
    
    private boolean m_isExecuting = false;
    private Integer BatchSize = 0;
    
    public DigitalCampaignTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnBeforeInsert(Digital_Campaign__c[] newDigital_Campaigns){
        
        List<Id> ProposalList = new List<Id>();
        List<string> locations = new List<string>();
        list<string> locationsForTZ = new list<string>();
        Id RecordTypeId = Schema.SObjectType.Digital_Campaign__c.getRecordTypeInfosByName().get('New Ads Everywhere').getRecordTypeId();
        
        list<string> lstDMATZ = new list<string>();
        list<string> lstZoneTZ = new list<string>();
        list<string> lstStateTZ = new list<string>();
        list<Digital_Campaign__c> updateTimeZone = new list<Digital_Campaign__c>();
        map<string,string> mapTimezone = new map<string,string>();
        
        Map<String,Boolean> mapDCRT = new Map<String,Boolean>();
        Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9-]');
        
        for(Digital_Campaign__c dc :newDigital_Campaigns){
          
            if((dc.Source__c =='Audience Track' || dc.Source__c=='SPP') && dc.Status__c == 'Plan Approved'){
                dc.RecordTypeId = RecordTypeId;
                dc.Status__c = '01 Draft Campaign';
                if(dc.CustomZipCode__c == false){
                    if(!string.isBlank(dc.DMAs__c) && dc.DMAs__c != 'None'){
                        locations = dc.DMAs__c.split(',');
                        lstDMATZ.addAll(locations);
                    }
                    if(!string.isBlank(dc.Spectrum_Reach_Zones__c) && dc.Spectrum_Reach_Zones__c != 'None'){
                        locations = dc.Spectrum_Reach_Zones__c.split(',');
                        lstZoneTZ.addAll(locations);
                    }
                    if(!string.isBlank(dc.State__c) && dc.State__c != 'None'){
                        locations = dc.State__c.split(',');
                        lstStateTZ.addAll(locations);
                    }
                    updateTimeZone.add(dc);
                }
                
                if((string.isBlank(dc.DMAs__c) || dc.DMAs__c == 'None') && (string.isBlank(dc.Spectrum_Reach_Zones__c) || dc.Spectrum_Reach_Zones__c == 'None') && (string.isBlank(dc.State__c) || dc.State__c == 'None') && dc.CustomZipCode__c == true){
                    List<string> locations1 = new List<string>();
                    String timezone,firstZip;
                    
                    System.debug('Inside custom Zip ');
                    locations1 = dc.Zip_Codes__c.split(',');
                    System.debug('locations custom Zip' +locations1);
                    firstZip = locations1[0];
                    System.debug('firstZip custom Zip' +firstZip);  
                    timezone = OMS_NetworkExController.getCustomZipCodeMapping(dc.CustomZipCode__c, firstZip,dc.OwnerId);
                    dc.Time_Zones__c = timezone;
                    System.debug('Inside custom@@' +timezone);
                }
                
                
            }
            System.debug(dc);
            ProposalList.add(dc.Proposal__C);
            mapDCRT.put(dc.RecordtypeId,false);
            //Added by Madhu for SRSF-2481 on Jan 07-2021
            String str = dc.Campaign_Name__c;
            System.debug(str);
            if(!String.isBlank(str)){
                Matcher matcher = nonAlphanumeric.matcher(str);
                dc.Campaign_Name__c = matcher.replaceAll(' ');
            }
            System.debug(dc.Campaign_Name__c);
        }
        
        if(!lstDMATZ.isEmpty()){
            mapTimezone = DigitalCampaignTriggerUtil.getTimezoneByDMA(lstDMATZ);
        }
        if(!lstZoneTZ.isEmpty()){
            mapTimezone = DigitalCampaignTriggerUtil.getTimezoneByZone(lstZoneTZ);
        }
        if(!lstStateTZ.isEmpty()){
            mapTimezone = DigitalCampaignTriggerUtil.getTimezoneByState(lstStateTZ);
        }
        
        for(Digital_Campaign__c dc : updateTimeZone){
            if(!string.isBlank(dc.DMAs__c) && dc.DMAs__c != 'None'){
                locationsForTZ = dc.DMAs__c.split(',');
            }
            if(!string.isBlank(dc.Spectrum_Reach_Zones__c) && dc.Spectrum_Reach_Zones__c != 'None'){
                locationsForTZ = dc.Spectrum_Reach_Zones__c.split(',');
            }
            if(!string.isBlank(dc.State__c) && dc.State__c != 'None'){
                locationsForTZ = dc.State__c.split(',');
            }
            System.debug('locations' +locationsForTZ);
            if(!locations.isEmpty()){
                integer count = 0;
                String timezone;
                for(String location : locationsForTZ){
                    System.debug('location::'+location);
                    if(mapTimezone.containskey(location)){
                        timezone = mapTimezone.get(location);
                        System.debug('timezone::'+timezone);
                        if(timezone !=null){
                            count++;
                        }
                    }
                }
                System.debug('count::'+count);
                if(count == 1){
                    dc.Time_Zones__c = timezone;
                }else{
                    dc.Time_Zones__c = 'America/New_York';
                }
            }
        }
        
        for(RecordType objrt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE Id IN :mapDCRT.keySet()]){
            String strDCRecType = objrt.DeveloperName;
            if(strDCRecType.contains('Addressable_Display') || strDCRecType.contains('Addressable_Video'))
                mapDCRT.put(objrt.Id,true);
        }
        for(Digital_Campaign__c dc :newDigital_Campaigns){
            if(mapDCRT.get(dc.RecordtypeId))
                dc.DigA_Zone_Zip_Codes__c = 'None';
        }
        
        List<Proposal__C> listpp = [SELECT Id, Name, Opportunity__r.Id, Opportunity__r.OwnerId, Advertiser__r.Id, Agency__r.Id, Advertiser__r.OwnerId, 
                                    Opportunity__r.Rep_Firm__r.Name,
                                    Advertiser__r.Name,
                                    Agency__r.Name,
                                    Opportunity__r.CoOp__c
                                    FROM Proposal__c WHERE Id IN:ProposalList ];
        
        Map<Id,Proposal__C> ppMap = new  Map<Id,Proposal__C>(listpp);
        
        //Added by Madhusudhan on 16th Oct-18 for SRSF-1119
        Map<Id,Boolean> mapOppCoOp = new Map<Id,Boolean>();
        for (Proposal__c prop : listpp) {
            if( prop.Opportunity__r.Id!=null )
                mapOppCoOp.put(prop.Opportunity__r.Id,prop.Opportunity__r.CoOp__c);
            
        }
        // Should set the owner of the DC to the ownerId of the oppty - above code commented out by bab and following code added
        Set<Id> userIdSet = new Set<Id>();
        for (Proposal__c prop : listpp) {
            userIdSet.add(prop.Opportunity__r.OwnerId);
        }
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Sales_Office__c, Region__c, Division__c FROM User WHERE Id IN :userIdSet]);
        
        List<String> DCStatuses = new List<String>();
        try {
            DCStatuses = System.Label.DC_Statuses_For_Date_Submitted.split(',');
            System.debug('============>> DCStatuses = ' + DCStatuses);
        } catch (Exception ex) {
            // do nothing
        } 
        
        for(Digital_Campaign__c dc :newDigital_Campaigns){
            if(ppMap.keySet().contains(dc.Proposal__c)){
                
                dc.Advertiser__c = ppMap.get(dc.Proposal__c).Advertiser__c;
                dc.Agency__c = ppMap.get(dc.Proposal__c).Agency__c;
                dc.Opportunity__c= ppMap.get(dc.Proposal__c).Opportunity__c;
                //added not null condition by Madhusudhan for SRMSUC-485
                if( ppMap.get(dc.Proposal__c).Opportunity__r.OwnerId != null ) {
                    // bab - change requested by Greg Rice    dc.OwnerId= ppMap.get(dc.proposal__c).Advertiser__r.OwnerId;
                    dc.OwnerId= ppMap.get(dc.Proposal__c).Opportunity__r.OwnerId;
                    //SRSF- 4123 populate the opp owner value in AE
                    dc.Account_Executive__c = ppMap.get(dc.Proposal__c).Opportunity__r.OwnerId;
                    // SRSF-716
                    dc.Advertiser_Text__c = ppMap.get(dc.Proposal__c).Advertiser__r.Name;
                    dc.Agency_Text__c = ppMap.get(dc.Proposal__c).Agency__r.Name;
                    dc.Rep_Firm_Text__c = ppMap.get(dc.Proposal__c).Opportunity__r.Rep_Firm__r.Name;
                    // end SRSF-716
                    
                    // SRSF-1119
                    if( !dc.CoOp__c && dc.Opportunity__c!=null ) //SRSF-2691 : Added condition "dc.CoOp__c"
                        dc.CoOp__c = mapOppCoOp.get(dc.Opportunity__c);
                }
            }
            //Added by Madhusudhan on Sep26th for SRSF-361
            // modified by bab to use the oppty owner fields instead of the current users
            if (dc.OwnerId != null) {
                User opptyOwner = userMap.get(dc.OwnerId);
                if(opptyOwner!=null){
                    dc.Sales_Office__c = opptyOwner.Sales_Office__c;
                    dc.Region__c = opptyOwner.Region__c;
                    dc.Division__c = opptyOwner.Division__c;
                }          
            }
            if (DCStatuses.size() > 0) {
                Set<String> statusSet = new Set<String>();
                statusSet.addAll(DCStatuses);
                System.debug('============>> statusSet = ' + statusSet);
                System.debug('============>> dc.Status__c = ' + dc.Status__c);
                if (statusSet.contains(dc.Status__c)) 
                    dc.Date_Last_Submitted__c = DateTime.now();
                
            }
        }
        
        //New SAM Designation mapping based on Account SAM Mapping object
        Map<String,String> mapAdvAEToSAM = new Map<String,String>();
        Map<String,String> mapAdvAEToTier = new Map<String,String>();
        Set<Id> setAdv = new Set<Id>();
        Set<Id> setAE = new Set<Id>();
        for(Digital_Campaign__c dc: newDigital_Campaigns) {
            setAdv.add(dc.Advertiser__c);
            setAE.add(dc.Account_Executive__c);
        }
        //Added regarding Tier Designation field update SRSF-4944
        if(!setAdv.isEmpty()){
            for(Account_SAM_Mapping__c objAcc : [SELECT Id,Tier_Designation__c,SAM_Designation__c,User__c,Account__c FROM Account_SAM_Mapping__c WHERE Account__c IN :setAdv]){
                if(objAcc != null && objAcc.Tier_Designation__c != null){
                    mapAdvAEToTier.put(String.valueOf(objAcc.account__c), objAcc.Tier_Designation__c);
                }
                if(System.label.SAMDesignationShutDown == 'FALSE'){
                    mapAdvAEToSAM.put(String.valueOf(objAcc.account__c)+String.valueOf(objAcc.User__c), objAcc.SAM_Designation__c);
                }
            }
        }
        for (Digital_Campaign__c dc : newDigital_Campaigns) {
            //Tier Designation Mapping
            if(String.isNotBlank(dc.Advertiser__c) && mapAdvAEToTier.containsKey(String.valueOf(dc.Advertiser__c))){
                dc.Tier_Designation__c = mapAdvAEToTier.get(String.valueOf(dc.Advertiser__c));
            }
            else{
                dc.Tier_Designation__c = null;
            }

            //SAM Designation Mapping
            if(System.label.SAMDesignationShutDown == 'FALSE' && String.isNotBlank(dc.Advertiser__c) && String.isNotBlank(dc.Account_Executive__c) && mapAdvAEToSAM.containsKey(String.valueOf(dc.Advertiser__c)+String.valueOf(dc.Account_Executive__c))){
                if(mapAdvAEToSAM.get(String.valueOf(dc.Advertiser__c)+String.valueOf(dc.Account_Executive__c)) == 'In Approval Process'){
                    dc.SAM_Designation__c = 'In Approval Process';
                }
                else{
                    dc.SAM_Designation__c = mapAdvAEToSAM.get(String.valueOf(dc.Advertiser__c)+String.valueOf(dc.Account_Executive__c));
                }
            }
            else{
                dc.SAM_Designation__c = null;
            }
        }
    }
    
    public void OnAfterInsert(Digital_Campaign__c[] newDigital_Campaigns){
                
                /*
        //Sending Agency, Advertiser info. to the OMS
        String strDC = '';
        for(Digital_Campaign__c obj : newDigital_Campaigns){
        strDC+=obj.Id+',';
        }
        strDC = strDC.substring(0,strDC.length()-1);
        if(!Test.isRunningTest()) //Avoiding test class falures
        OMSHelper.SendData(strDC);*/
        
        //SyncplicitySRUtils.CreateSyncplicityFolders(new List<Id>(new Map<Id, Digital_Campaign__c>(newDigital_Campaigns).keySet()));
        
    }
        
    /*@future*/ public static void OnAfterInsertAsync(Set<ID> newDigital_CampaignIDs){
        //Example usage
        //List<Digital_Campaign> newDigital_Campaigns = [select Id, Name from Digital_Campaign where Id IN :newDigital_CampaignIDs];
    }
    
    
    
    public void OnBeforeUpdate(Digital_Campaign__c[] oldDigital_Campaigns, Digital_Campaign__c[] updatedDigital_Campaigns, Map<ID, Digital_Campaign__c> oldDigital_CampaignMap, Map<ID, Digital_Campaign__c> Digital_CampaignMap){
  		
        updateInventoryResourceDate(oldDigital_Campaigns,updatedDigital_Campaigns);
        System.debug('testonbefore.......');
        Id newAddsEveryWhereRecTypeId = Schema.SObjectType.Digital_Campaign__c.getRecordTypeInfosByName().get('New Ads Everywhere').getRecordTypeId();
              //SRSF-4513
       List<string> Inactivelst=new List<string>();
        string inActiveint;
        List<Data_Catalog__c> DeactivatedInterest=[SELECT Id,Display_Text__c,Political__c,Restricted_Interest__c,CPM__c,Export_Key__c  FROM Data_Catalog__c WHERE isActive__c = false];
        system.debug('DeactivatedInterest'+DeactivatedInterest.size());
        for(Data_Catalog__c datacatalog:DeactivatedInterest){
           inActiveint= datacatalog.Id;
            if(inActiveint !=null){
                Inactivelst.add(inActiveint);
            }
           
        }
          system.debug(' Inactivelst'+ Inactivelst);
         system.debug(' Inactivelstsize'+ Inactivelst.size());
        String deactiveIntr = String.join(Inactivelst, ',');     
         system.debug(' deactiveIntr'+ deactiveIntr);
        for(Digital_Campaign__c dc:updatedDigital_Campaigns){
              system.debug('dc.Data_Catalog__c'+dc.Data_Catalog__c);
            for(string s:Inactivelst){
                 system.debug('s'+s);
             if(dc.Selected_Data_Catalog_Id__c!=null && s !=null && string.isNotBlank(dc.Selected_Data_Catalog_Id__c) && dc.Selected_Data_Catalog_Id__c.contains(s)){
                dc.HasInactiveInterests__c=true;
                 system.debug(' dc.HasInactiveInterests__c true '+ dc.HasInactiveInterests__c);
                break;
                 
             }else{
                  dc.HasInactiveInterests__c=false;
                 
                   system.debug(' dc.HasInactiveInterests__c false '+ dc.HasInactiveInterests__c);
             }
            }
             system.debug(' dc.HasInactiveInterests__c fal '+ dc.HasInactiveInterests__c);
        }
       
        
        //SRSF-4513


        //Example Map usage
        //Map<ID, Contact> contacts = new Map<ID, Contact>( [select Id, FirstName, LastName, Email from Contact where Digital_CampaignId IN :Digital_CampaignMap.keySet()] );
        
        //Added by Madhusudhan on 06-Jan-2021 for Platform Validation when status is '11 Sales Revision In Progress'
        Map<String,Set<String>> mapSelectedPlatforms = new Map<String,Set<String>>();
        for(Integer i=0;i<updatedDigital_Campaigns.size();i++){
            String newPlatforms = updatedDigital_Campaigns[i].AdsE_Platform_s__c;
            if(!String.isBlank(newPlatforms)){
                Set<String> setPlatforms = new Set<String>();
                for(String str : newPlatforms.split(';')){
                    setPlatforms.add(str);
                }
                mapSelectedPlatforms.put(updatedDigital_Campaigns[i].Id,setPlatforms);
                System.debug('NewSetPlatforms::'+setPlatforms);
            }
            // SRSF-4328 start
            /*if (updatedDigital_Campaigns[i].Product_Type__c == 'Customer Data Match' && updatedDigital_Campaigns[i].Customer_Data_Match_Type__c == 'BlockGraph') {
                updatedDigital_Campaigns[i].Audience_Profile__c = 'Custom Interest';
               System.debug('true+++++++++++');
           }*/
            // SRSF-4328 end
        }
        for(integer i=0;i<updatedDigital_Campaigns.size();i++){
            String newPlatforms = updatedDigital_Campaigns[i].AdsE_Platform_s__c;
            String oldPlatforms = oldDigital_Campaigns[i].AdsE_Platform_s__c;
            if(newPlatforms!=oldPlatforms && updatedDigital_Campaigns[i].status__c=='11 Sales Revision In Progress'){
                if(!String.isBlank(newPlatforms)){
                    Set<String> newPlatformSelection = mapSelectedPlatforms.get(updatedDigital_Campaigns[i].Id);
                    System.debug('newPlatformSelection::'+newPlatformSelection);
                    for(String str : oldPlatforms.split(';')){
                        if(!newPlatformSelection.contains(str)){//Platform is removed
                            updatedDigital_Campaigns[i].Is_Platforms_Removed__c = true; 
                        }
                    }
                }else{//Platform is removed
                    updatedDigital_Campaigns[i].Is_Platforms_Removed__c = true;
                }
            }
        }
        
        //Added for SRSF-2657
        for(integer i=0;i<updatedDigital_Campaigns.size();i++){
            Decimal newDesiredBudget = updatedDigital_Campaigns[i].Desired_Budget__c;
            Decimal oldDesiredBudget = oldDigital_Campaigns[i].Desired_Budget__c;
            if(newDesiredBudget!=oldDesiredBudget){
                if(oldDesiredBudget!=null && newDesiredBudget!=null && (newDesiredBudget-oldDesiredBudget)<0 ){
                    updatedDigital_Campaigns[i].Desired_Budget_Change__c = true;
                }else{
                    updatedDigital_Campaigns[i].Desired_Budget_Change__c = false;
                }
            }else{
                updatedDigital_Campaigns[i].Desired_Budget_Change__c = false;
            }
        }
        
        //Added by Madhusudhan on Jan19-2021 for SRSF-2248 (Validation Rule for Frequency Activation)
        Set<String> setNWNames = new Set<String>();
        for(Networks__c objNW : [SELECT Id,Name,Frequence_Activated__c FROM Networks__c WHERE Frequence_Activated__c=true]){
            setNWNames.add(objNW.Name);
        }
        System.debug('setNWNames::'+setNWNames);
        for(Inventory_Source__c objIS : [SELECT Id,Digital_Campaign__c,CPM_Gross__c,COST_Gross__c,Inventory_Resource_Type__c,Digital_Campaign__r.AdsE_Network__c 
                                         FROM Inventory_Source__c 
                                         WHERE Digital_Campaign__c IN:Digital_CampaignMap.keyset() AND Inventory_Resource_Type__c='TTD-CTV' AND CPM_Gross__c!=null AND COST_Gross__c!=null]){
                                             Digital_Campaign__c objDC = Digital_CampaignMap.get(objIS.Digital_Campaign__c);
                                             System.debug('genre selected :: ' +objDC.AdsE_Genre_s__c);
                                             if(objDC.AdsE_Genre_s__c == 'Selected Networks'){
                                                 //System.debug('genre selected inside:: ' +objDC.AdsE_Genre_s__c);
                                                 String strDCNetworks = objDC.AdsE_Network__c;                                  
                                                 boolean isfrequency = DigitalCampaignTriggerUtil.isFrequencyActivation(objIS,strDCNetworks,setNWNames);
                                                 if( isfrequency== false )
                                                     objDC.addError('Error: There are no active Frequence Networks selected when inventory source is TTD-CTV.');
                                                 
                                             }   
                                         }
        
        
                //SRSF-2248
                //SRSF-4158
                /*    String usrProfileName1 = [SELECT Profile.Name FROM User  WHERE Id = :Userinfo.getUserId() Limit 1].profile.name;
        if(usrProfileName1 == 'Master - Yield and Inventory'||
        usrProfileName1 == 'Master - Enterprise Digital'||
        usrProfileName1 == 'Master - Optimization Manager'||
        usrProfileName1 == 'System Administrator'){
        
        //Validation For Activated Interest
        Set<String> setDCNames = new Set<String>();
        for(Data_Catalog__c objDataCatalog : [Select id,DISPLAY_TEXT__c from Data_Catalog__c where SimpliFi_Activated__c  = true]){
        setDCNames.add(objDataCatalog.DISPLAY_TEXT__c);
        }
        System.debug('setDCNames::'+setDCNames);
        for(Inventory_Source__c objIS : [SELECT Id,Digital_Campaign__c,CPM_Gross__c,COST_Gross__c,Inventory_Resource_Type__c,
        Digital_Campaign__r.Data_Catalog__c 
        FROM Inventory_Source__c 
        WHERE Digital_Campaign__c IN:Digital_CampaignMap.keyset() 
        AND Inventory_Resource_Type__c='Simpli.fi-CTV' AND CPM_Gross__c!=null AND COST_Gross__c!=null]){
        Digital_Campaign__c objDC = Digital_CampaignMap.get(objIS.Digital_Campaign__c);
        System.debug('Catalog selected :: ' +objDC.Data_Catalog__c);
        
        
        String strDCCatalogs = objDC.Data_Catalog__c;  
        Id recTypeId = objDC.RecordTypeId;     
        
        if(recTypeId == newAddsEveryWhereRecTypeId){
        boolean isActivatedInterset = DigitalCampaignTriggerUtil.isActiveInterestedCatalog(objIS,strDCCatalogs,setDCNames);
        if( isActivatedInterset == false ){
        objDC.addError('Error: There are no active Interest Catalog selected when inventory source is Simpli.fi-CTV.');
        }
        }                                
        }
        }*/
        //SRSF-4158 End
        
        //VR for Split Avail Activation
        Set<String> setDCNWNames = new Set<String>();
        for(Networks__c networkObj : [SELECT Id,Name,Split_Avail_Activated__c FROM Networks__c WHERE Split_Avail_Activated__c=true]){
            setDCNWNames.add(networkObj.Name);
        }
        for(Inventory_Source__c obIS : [SELECT Id,Digital_Campaign__c,CPM_Gross__c,COST_Gross__c,Inventory_Resource_Type__c,Digital_Campaign__r.AdsE_Network__c 
                                        FROM Inventory_Source__c 
                                        WHERE Digital_Campaign__c IN:Digital_CampaignMap.keyset() AND Inventory_Resource_Type__c='Freewheel-SA' AND CPM_Gross__c!=null AND COST_Gross__c!=null]){
                                            Digital_Campaign__c obDC = Digital_CampaignMap.get(obIS.Digital_Campaign__c);
                                            if(obDC.AdsE_Genre_s__c == 'Selected Networks'){
                                                String strDCNW = obDC.AdsE_Network__c;                                  
                                                boolean isSplitActivated = DigitalCampaignTriggerUtil.isSplitAvailActivated(obIS,strDCNW,setDCNWNames);
                                                if( isSplitActivated== false ){
                                                    obDC.addError('Error: There are no active Split Avail Networks selected when inventory source is Freewheel-SA.');
                                                }
                                            }
                                        }
        
        
        //Added by Madhusudhan on Sep26th for SRSF-361
        Set<Id> ownerIdSet = new Set<Id>();
        Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9-]');
        for (Digital_Campaign__c dc : updatedDigital_Campaigns) {
            ownerIdSet.add(dc.OwnerId);
            String str = dc.Campaign_Name__c;
            System.debug(str);
            if(!String.isBlank(str)){
                Matcher matcher = nonAlphanumeric.matcher(str);
                dc.Campaign_Name__c = matcher.replaceAll(' ');
            }
        }
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name, Sales_Office__c, Region__c, Division__c FROM User WHERE Id IN :ownerIdSet]);
        for(Digital_Campaign__c dc: updatedDigital_Campaigns) {
            //Added by Madhusudhan on Sep26th for SRSF-361
            User userRec = userMap.get(dc.OwnerId);
            dc.Sales_Office__c = userRec.Sales_Office__c;
            dc.Region__c = userRec.Region__c;
            dc.Division__c = userRec.Division__c;   
            //Code Change for the Owner to be similar to the Account Executive always
            //SRSF - 4693
            if(Digital_CampaignMap.get(dc.ID).OwnerID != oldDigital_CampaignMap.get(dc.ID).OwnerID)
            {
                if(Digital_CampaignMap.get(dc.ID).Account_Executive__c != Digital_CampaignMap.get(dc.ID).OwnerID)
                    dc.Account_Executive__c = dc.OwnerID;
            }
        }
        
        
        //SRSF-1764
        User usrProfileName = [SELECT u.Profile.Name, u.userRole.Name, u.Team_Role__c FROM User u WHERE u.Id = :Userinfo.getUserId()];
        //if(usrProfileName.Profile.Name != 'Integration User'){//SRSF-1940
        for (Digital_Campaign__c dc : updatedDigital_Campaigns){
            if(dc.Status__c != oldDigital_CampaignMap.get(dc.Id).status__c && 
               (dc.Status__c ==  'Planning in Progress' || 
                dc.Status__c ==  '03 Digital Ops In Progress' ||
                dc.Status__c ==  '11 Sales Revision In Progress' || 
                dc.Status__c ==  '13 Digital Ops Revision In Progress' ||
                dc.Status__c ==  '32 Sales Cancellation in Progress' ||
                dc.Status__c ==  '33 Digital Ops Cancellation In Progress' ||
                dc.Status__c ==  '00 Rejected')
              )
                dc.Working__c = Userinfo.getUserId();
        }
        //}
        
        //SRSF-716
        Set<Id> propIdSet = new Set<Id>();
        for (Digital_Campaign__c dc : updatedDigital_Campaigns){
            propIdSet.add(dc.Proposal__C);
           //SRSF-4670 start
          /* if( dc.Audience_Profile__c!=null && dc.Data_Catalog_Custom_Logic__c.contains('Custom 1') && dc.Audience_Profile__c.contains('1')) {
               dc.Custom_Export_Key_Logic__c = dc.Export_Key_Logic__c.replaceAll('CUSTOM',dc.Audience_Profile__c);
               
            }else if( dc.Audience_Profile__c!=null && dc.Data_Catalog_Custom_Logic__c.contains('Custom 2') && dc.Audience_Profile__c.contains('2')) {
                dc.Custom_Export_Key_Logic__c = dc.Export_Key_Logic__c.replaceAll('CUSTOM',dc.Audience_Profile__c);
                 
             }else if( dc.Audience_Profile__c!=null && dc.Data_Catalog_Custom_Logic__c.contains('Custom 3') && dc.Audience_Profile__c.contains('3')) {
                dc.Custom_Export_Key_Logic__c = dc.Export_Key_Logic__c.replaceAll('CUSTOM',dc.Audience_Profile__c);
              
             }  
            List<String> strList=new List<String>();
   if( !String.isBlank(dc.Export_Key_Logic__c)){
            String str= dc.Export_Key_Logic__c;
            strList = str.split('CUSTOM');
            System.debug('strList.size()'+strList.size());
            if(str.contains('CUSTOM'))
            {
                Integer count = 1;
                do{
                    string valst='.*'+'/'+count.toString()+'/'+'.*';
                    str = str.replaceFirst('CUSTOM',valst);
                    count= count+1;
                    System.debug(count);
                }
                while(str.contains('CUSTOM'));
            }
            System.debug('str'+str);
           
            if( !String.isBlank(dc.Audience_Profile__c)){
            String strv = dc.Audience_Profile__c;
                 List<string> lsstr=new  List<string>();
            
            lsstr=strv.split(',');
            system.debug('lsstr'+lsstr);
            for(string strval:lsstr){
                system.debug('strval'+strval);
                
                if(strval.contains('1')) {
                    str=str.replace('.1/.*',strval);
                    
                    
                }else if(strval.contains('2')){
                    str=str.replace('.2/.*',strval);
                    
                }else if(strval.contains('3')){
                    str=str.replace('.3/.*',strval);
                    //system.debug('dc.Custom_Export_Key_Logic__c'+dc.Custom_Export_Key_Logic__c);
                }
                dc.Custom_Export_Key_Logic__c=str; 
            }}}
            //System.debug('final  dc.Custom_Export_Key_Logic__c'+ dc.Custom_Export_Key_Logic__c);*/
            
            
            
            
            
            
            
            
            
            
            

             // sRSF-4670 end

        }
        
        
        Map<Id, Proposal__c> propMap = new Map<Id, Proposal__c>([SELECT Id, Name,
                                                                 Opportunity__r.Rep_Firm__r.Name,
                                                                 Advertiser__r.Name,
                                                                 Agency__r.Name,
                                                                 Opportunity__r.Id,Opportunity__r.CoOp__c
                                                                 FROM Proposal__c WHERE Id IN :propIdSet ]);
        
        List<String> DCStatuses = new List<String>();
        try {
            DCStatuses = System.Label.DC_Statuses_For_Date_Submitted.split(',');
            System.debug('============>> DCStatuses = ' + DCStatuses);
        } catch (Exception ex) {
            System.debug('find the error -------' + ex);
        }
        list<string> lstDMATZ = new list<string>();
        list<string> lstZoneTZ = new list<string>();
        list<string> lstStateTZ = new list<string>();
        String boomiUserID = System.Label.BoomiUserId;
        list<Digital_Campaign__c> updateTimeZone = new list<Digital_Campaign__c>();
        for (Digital_Campaign__c dc : updatedDigital_Campaigns) {
            Proposal__c prop = propMap.get(dc.Proposal__c);
            if (prop != null) {
                if (prop.Advertiser__c != null)
                    dc.Advertiser_Text__c = prop.Advertiser__r.Name;
                if (prop.Agency__c != null)
                    dc.Agency_Text__c = prop.Agency__r.Name;
                if (prop.Opportunity__r != null && prop.Opportunity__r.Rep_Firm__c != null)
                    dc.Rep_Firm_Text__c = prop.Opportunity__r.Rep_Firm__r.Name;
            }
            //Map<Id, Digital_Campaign__c> dcUpdated = new Map<Id, Digital_Campaign__c>(oldDigital_Campaigns);
            if(dc.status__c != oldDigital_CampaignMap.get(dc.id).status__c){
                System.debug('!!!!!!');
                if (DCStatuses.size() > 0) {
                    Set<String> statusSet = new Set<String>();
                    statusSet.addAll(DCStatuses);
                    System.debug('============>> statusSet = ' + statusSet);
                    System.debug('============>> dc.Status__c = ' + dc.Status__c);
                    if (statusSet.contains(dc.Status__c)) {
                        System.debug('===================>> found the status!!!');
                        dc.Date_Last_Submitted__c = DateTime.now();
                    }
                }
                
                System.debug('dc.status__c -- ' +dc.status__c);
                System.debug('oldDigital_CampaignMap.status__c -- ' +oldDigital_CampaignMap.get(dc.id).status__c);
                //3701
                List<string> locations = new List<string>();
                if(dc.status__c == 'Plan Approved' && oldDigital_CampaignMap.get(dc.id).status__c == 'Plan Submitted' && (dc.Source__c == 'Audience Track' || dc.CreatedById == boomiUserID)  ){
                    if(!string.isBlank(dc.DMAs__c) && dc.DMAs__c != 'None'){
                        locations = dc.DMAs__c.split(',');
                        lstDMATZ.addAll(locations);
                    }
                    if(!string.isBlank(dc.Spectrum_Reach_Zones__c) && dc.Spectrum_Reach_Zones__c != 'None'){
                        locations = dc.Spectrum_Reach_Zones__c.split(',');
                        lstZoneTZ.addAll(locations);
                    }
                    if(!string.isBlank(dc.State__c) && dc.State__c != 'None'){
                        locations = dc.State__c.split(',');
                        lstStateTZ.addAll(locations);
                    }
                    updateTimeZone.add(dc);
                }
                if(dc.status__c == 'Plan Approved' && oldDigital_CampaignMap.get(dc.id).status__c == 'Plan Submitted' && (dc.Source__c == 'Audience Track' || dc.CreatedById == boomiUserID)){
                    List<string> locations1 = new List<string>();
                    String timezone;
                    String firstZip;
                    if((string.isBlank(dc.DMAs__c) || dc.DMAs__c == 'None') && (string.isBlank(dc.Spectrum_Reach_Zones__c) || dc.Spectrum_Reach_Zones__c == 'None') && (string.isBlank(dc.State__c) || dc.State__c == 'None') && dc.CustomZipCode__c == true){
                        System.debug('Inside custom Zip ');
                        locations1 = dc.Zip_Codes__c.split(',');
                        System.debug('locations custom Zip' +locations1);
                        firstZip = locations1[0];
                        System.debug('firstZip custom Zip' +firstZip);  
                        timezone = OMS_NetworkExController.getCustomZipCodeMapping(dc.CustomZipCode__c, firstZip,dc.OwnerId);
                        dc.Time_Zones__c = timezone;
                        System.debug('Inside custom@@' +timezone);
                    }
                }
                
            }
            
            //SRSF-3644
            if(dc.Audience_Profile__c != oldDigital_CampaignMap.get(dc.id).Audience_Profile__c){
                String ap = oldDigital_CampaignMap.get(dc.id).Audience_Profile__c;
                if(ap!= null && ap.length()>255){
                    ap = ap.substring(0,255);
                }
                dc.Audience_Profile_History__c = ap;
                //dc.Audience_Profile_History__c = oldDigital_CampaignMap.get(dc.id).Audience_Profile__c;               
            }
            
        }
        map<string,string> mapTimezone = new map<string,string>();
        if(!lstDMATZ.isEmpty()){
            mapTimezone = DigitalCampaignTriggerUtil.getTimezoneByDMA(lstDMATZ);
        }
        if(!lstZoneTZ.isEmpty()){
            mapTimezone = DigitalCampaignTriggerUtil.getTimezoneByZone(lstZoneTZ);
        }
        if(!lstStateTZ.isEmpty()){
            mapTimezone = DigitalCampaignTriggerUtil.getTimezoneByState(lstStateTZ);
        }
        list<string> locations = new list<string>();
        for(Digital_Campaign__c dc : updateTimeZone){
            if(!string.isBlank(dc.DMAs__c) && dc.DMAs__c != 'None'){
                locations = dc.DMAs__c.split(',');
            }
            if(!string.isBlank(dc.Spectrum_Reach_Zones__c) && dc.Spectrum_Reach_Zones__c != 'None'){
                locations = dc.Spectrum_Reach_Zones__c.split(',');
            }
            if(!string.isBlank(dc.State__c) && dc.State__c != 'None'){
                locations = dc.State__c.split(',');
            }
            System.debug('locations' +locations);
            if(!locations.isEmpty()){
                integer count = 0;
                String timezone;
                for(String location : locations){
                    System.debug('location::'+location);
                    if(mapTimezone.containskey(location)){
                        timezone = mapTimezone.get(location);
                        System.debug('timezone::'+timezone);
                        if(timezone !=null){
                            count++;
                        }
                    }
                }
                System.debug('count::'+count);
                if(count == 1){
                    dc.Time_Zones__c = timezone;
                }else{
                    dc.Time_Zones__c = 'America/New_York';
                }
            }
        }
        // end SRSF-716
        
        
        
        //New SAM Designation mapping based on Account SAM Mapping object
        Map<String,String> mapAdvAEToSAM = new Map<String,String>();
        Map<String,String> mapAdvAEToTier = new Map<String,String>();
        Set<Id> setAdv = new Set<Id>();
        Set<Id> setAE = new Set<Id>();
        for(Digital_Campaign__c dc: updatedDigital_Campaigns) {
            setAdv.add(dc.Advertiser__c);
            setAE.add(dc.Account_Executive__c);
        }
        //Added regarding Tier Designation field update SRSF-4944
        if(!setAdv.isEmpty()){
            for(Account_SAM_Mapping__c objAcc : [SELECT Id,Tier_Designation__c,SAM_Designation__c,User__c,Account__c FROM Account_SAM_Mapping__c WHERE Account__c IN :setAdv]){
                if(objAcc != null && objAcc.Tier_Designation__c != null){
                    mapAdvAEToTier.put(String.valueOf(objAcc.account__c), objAcc.Tier_Designation__c);
                }
                if(System.label.SAMDesignationShutDown == 'FALSE'){
                    mapAdvAEToSAM.put(String.valueOf(objAcc.Account__c)+String.valueOf(objAcc.User__c), objAcc.SAM_Designation__c);
                }
            }
        }
        for (Digital_Campaign__c dc : updatedDigital_Campaigns) {
            //Tier Designation Mapping
            if(String.isNotBlank(dc.Advertiser__c) && mapAdvAEToTier.containsKey(String.valueOf(dc.Advertiser__c))){
                dc.Tier_Designation__c = mapAdvAEToTier.get(String.valueOf(dc.Advertiser__c));
            }else{
                dc.Tier_Designation__c = null;
            }

            //SAM Designation Mapping
            if(System.label.SAMDesignationShutDown == 'FALSE' && String.isNotBlank(dc.Advertiser__c) && String.isNotBlank(dc.Account_Executive__c) && mapAdvAEToSAM.containsKey(String.valueOf(dc.Advertiser__c)+String.valueOf(dc.Account_Executive__c))){
                if(mapAdvAEToSAM.get(String.valueOf(dc.Advertiser__c)+String.valueOf(dc.Account_Executive__c)) == 'In Approval Process'){
                    dc.SAM_Designation__c = 'In Approval Process'; 
                }
                else{
                    dc.SAM_Designation__c = mapAdvAEToSAM.get(String.valueOf(dc.Advertiser__c)+String.valueOf(dc.Account_Executive__c));
                }
            }
            else{
                dc.SAM_Designation__c = null;
            }
        }
        
        boolean acceptableProfile = false;
        boolean userCanEdit = false;
        //4576 creating Custom Label for adding/removing Profile                     
        String publicGroupStr = System.Label.Profile_For_DC_Edit;
        List<String> publicGroups = publicGroupStr.split(',');
        if(publicGroups.contains(usrProfileName.Profile.Name)) {
              userCanEdit = acceptableProfile = true;
          }
          system.debug('userCanEdit'+userCanEdit);
           //4576
        for(integer i=0;i<updatedDigital_Campaigns.size();i++){
            String newDCStatus = updatedDigital_Campaigns[i].Status__c;
            String oldDCStatus = oldDigital_Campaigns[i].Status__c;
            if(newDCStatus!=oldDCStatus && oldDCStatus=='Submit for Expedite Approval'){
                userCanEdit = true; 
            }
            if(updatedDigital_Campaigns[i].Bypass_Apex_Execution__c !=null && updatedDigital_Campaigns[i].Bypass_Apex_Execution__c == true){
                userCanEdit = true;
            }
        }
        if(!userCanEdit) {
            Boolean userOwnAllRecords = true;
            List<Id> opportunities = new List<Id>();
            for(Digital_Campaign__c dc: oldDigital_Campaigns) {
                if( dc.OwnerId != UserInfo.getUserId() ){
                    opportunities.add(dc.Opportunity__c);
                }
            }
            if( opportunities.size() > 0 ){
                boolean userOnTeam = true;
                for(Opportunity oppty: [SELECT id, (SELECT Id,UserID FROM OpportunityTeamMembers WHERE UserId=:UserInfo.getUserId() ) FROM Opportunity WHERE Id IN :opportunities]) {
                    if( oppty.OpportunityTeamMembers == null || oppty.OpportunityTeamMembers.isEmpty() ){
                        userOnTeam = false;
                        break;
                    }
                }
                if(userOnTeam) {
                    userCanEdit = true;
                }
            }else{
                userCanEdit = true;
            }
        }
        if(!userCanEdit) {
            for(Digital_Campaign__c dc: updatedDigital_Campaigns) {
                try {
                    throw new DmlException('You are not allowed to edit this Digital Campaign as you are not the owner of this record or not present in Opportunity\'s Team Member list.');
                } catch(DMLException e) {
                    dc.addError('You are not allowed to edit this Digital Campaign as you are not the owner of this record or not present in Opportunity\'s Team Member list.');
                }
            }
        }
        
        
        //Kafka integration block  
        for (Digital_Campaign__c dc : updatedDigital_Campaigns){
            
            System.debug('KIB: ' + dc.Id);
            
            if(oldDigital_CampaignMap.get(dc.Id).First_Impression__c != null && dc.First_Impression__c != oldDigital_CampaignMap.get(dc.Id).First_Impression__c){          
                dc.addError('First Impression data already exists and cannot be updated again!');
            }
            
            if(dc.First_Impression__c!= null && dc.First_Impression__c > oldDigital_CampaignMap.get(dc.Id).First_Impression__c){          
                dc.First_Impression__c = oldDigital_CampaignMap.get(dc.Id).First_Impression__c;
            }
        }
        updatedDigital_Campaigns = DigitalCampaignTriggerUtil.calculateAutoZipcodes(updatedDigital_Campaigns);    
        //if the recordtype is makegood and status is "Plan Approved", need to flip the recordtype
        //
         updatedDigital_Campaigns = DigitalCampaignTriggerUtil.flipRecordType(updatedDigital_Campaigns);
        updatedDigital_Campaigns = DigitalCampaignTriggerUtil.flipNewRecordType(oldDigital_Campaigns,updatedDigital_Campaigns);
    }
    
    public void OnAfterUpdate(Digital_Campaign__c[] oldDigital_Campaigns, Digital_Campaign__c[] updatedDigital_Campaigns, Map<ID, Digital_Campaign__c> Digital_CampaignMap,Map<ID, Digital_Campaign__c> oldDigitalCampaignMap){
        
        System.debug('DC-OnAfterUpdate');
        //Added by Madhu for SRSF-1631 on May 14-2019. When DC recordtype is changed, update related DCCS of DC based on DCC_Clone_Matrix__mdt
        Map<String,String> mapDCToRTName = new Map<String,String>();
        for (integer i=0;i<updatedDigital_Campaigns.size();i++) {
            if(updatedDigital_Campaigns[i].recordtypeid != oldDigital_Campaigns[i].recordtypeid){
                String strRTName = Schema.SObjectType.Digital_Campaign__c.getRecordTypeInfosById().get(updatedDigital_Campaigns[i].recordtypeid).getname();
                mapDCToRTName.put(updatedDigital_Campaigns[i].Id,strRTName);
            }
        }
        System.debug('mapDCToRTName'+mapDCToRTName);
        if(!mapDCToRTName.isEmpty()){
            Map<String,String> mapDCToDcc = new Map<String,String>();
            for(DCC_Clone_Matrix__mdt objCloneMatrix : [SELECT Id,To_Digital_Campaign_RecordType__c,DCC_Recordtype_Name__c FROM DCC_Clone_Matrix__mdt WHERE To_Digital_Campaign_RecordType__c IN :mapDCToRTName.values() AND DCC_Recordtype_Name__c!=null]){
                mapDCToDcc.put(objCloneMatrix.To_Digital_Campaign_RecordType__c, objCloneMatrix.DCC_Recordtype_Name__c);
            }    
            
            List<Digital_Creative__c> lstUpdateDCC = new List<Digital_Creative__c>();
            for(Digital_Creative__c dcc : [SELECT Id,RecordtypeId,Digital_Campaign__r.Recordtype.Name,Digital_Campaign__c FROM Digital_Creative__c WHERE Digital_Campaign__c IN : mapDCToRTName.keySet() and Status__c != 'Submit for Expedite Approval']) {
                if(mapDCToRTName != null){
                String strDCName = mapDCToRTName.get(dcc.Digital_Campaign__c);
                if(strDCName!=null && mapDCToDcc.containskey(strDCName) && mapDCToDcc.get(strDCName)!=null){
                    System.debug('DCC RT-'+mapDCToDcc.get(strDCName));
                    If(mapDCToDcc.get(strDCName) !=null){
                    Id AddressableAdsERecordTypeId = Schema.SObjectType.Digital_Creative__c.getRecordTypeInfosByName().get(mapDCToDcc.get(strDCName)).getRecordTypeId();
                    System.debug('dcc.RecordtypeId-'+dcc.RecordtypeId);
                    System.debug('AddressableAdsERecordTypeId-'+AddressableAdsERecordTypeId);
                    if(dcc.RecordtypeId != AddressableAdsERecordTypeId){//If the existing recordtype is not matched then update DCC
                        Digital_Creative__c objUpdate = new Digital_Creative__c(Id=dcc.Id,RecordTypeId=AddressableAdsERecordTypeId,Bypass_Apex_Execution__c=true);
                        lstUpdateDCC.add(objUpdate);
                    }}
                }}
            }
            System.debug('lstUpdateDCC'+lstUpdateDCC);
            if(!lstUpdateDCC.isEmpty())
                UPDATE lstUpdateDCC;
        }
        
        //SRSF-3503
        list<Inventory_Source__c> lstISUpdate = new list<Inventory_Source__c>();
        set<Id> setDCIdForISSA = new set<Id>();
        for (integer i=0;i<updatedDigital_Campaigns.size();i++) {
            if(updatedDigital_Campaigns[i].Full_Avail_Campaign__c == true && oldDigital_Campaigns[i].Full_Avail_Campaign__c != updatedDigital_Campaigns[i].Full_Avail_Campaign__c){
                setDCIdForISSA.add(updatedDigital_Campaigns[i].Id);
            }
        }
        
        if(!setDCIdForISSA.isEmpty()){
            for(Inventory_Source__c objIS :[SELECT Id,Digital_Campaign__c,CPM_Gross__c,COST_Gross__c,Inventory_Resource_Type__c,
                                            Digital_Campaign__r.Full_Avail_Campaign__c 
                                            FROM Inventory_Source__c  
                                            WHERE Digital_Campaign__c IN :setDCIdForISSA AND Inventory_Resource_Type__c='Freewheel-SA' AND Digital_Campaign__r.Full_Avail_Campaign__c = true ]){        
                                                objIS.Impressions__c = 1;
                                                objIS.COST_Gross__c = .00;
                                                objIS.CPM_Gross__c = .00;
                                                lstISUpdate.add(objIS);
                                            }
            if(!lstISUpdate.isEmpty()){
                update lstISUpdate;
            }
        }
        //SRSF-4273
        DigitalCampaignTriggerUtil.createZipCodeHistory(oldDigital_Campaigns, Digital_CampaignMap, oldDigitalCampaignMap);
        
    }
    
    /*updateInventoryResourceDate start*/ 
    public static void updateInventoryResourceDate(Digital_Campaign__c[] oldDigital_Campaigns, Digital_Campaign__c[] updatedDigital_Campaigns){
        System.debug('updatedDigital_Campaigns = ' + updatedDigital_Campaigns);
        Id newAddsEveryWhereRecTypeId = Schema.SObjectType.Digital_Campaign__c.getRecordTypeInfosByName().get('New Ads Everywhere').getRecordTypeId();
        
        Set<String> digitalCampaignIds = new Set<String>();
        for (integer i=0;i<updatedDigital_Campaigns.size();i++) {
            if((updatedDigital_Campaigns[i].Status__c != oldDigital_Campaigns[i].Status__c)
               && (String.isBlank(updatedDigital_Campaigns[i].Operative_ID__c) || String.isEmpty(updatedDigital_Campaigns[i].Operative_ID__c))
               && (updatedDigital_Campaigns[i].Status__c == '03 Submitted to Digital Ops' || updatedDigital_Campaigns[i].Status__c == '03 Digital Ops In Progress')
               && (oldDigital_Campaigns[i].Status__c == '01 Draft Campaign' || oldDigital_Campaigns[i].Status__c == 'Submit for Expedite Approval') //SRSF-4235K  
               &&  newAddsEveryWhereRecTypeId == updatedDigital_Campaigns[i].RecordTypeId ){
                   digitalCampaignIds.add(updatedDigital_Campaigns[i].Id);
                   
               }
        }
        System.debug('digitalCampaignIds***'+digitalCampaignIds);
        List<Inventory_source__c> lstInvSource = new List<Inventory_source__c>();
        
        for(Inventory_source__c invRes : [Select id,Campaign_Start_Date__c, Campaign_End_Date__c, Digital_Campaign__r.Campaign_Start_Date__c, 
                                          Digital_Campaign__r.Campaign_End_Date__c from Inventory_Source__c WHERE Digital_Campaign__c IN :digitalCampaignIds ]){
                                              //	System.debug('Approval.isLocked(invRes):::'+Approval.isLocked(invRes))        ;                          
                                              //SRSF-4278k
                                             // if(!Approval.isLocked(invRes)){    
                                              Inventory_source__c singleInvRes = new Inventory_source__c();
                                              singleInvRes.Id = invRes.Id;
                                              singleInvRes.Campaign_Start_Date__c = invRes.Digital_Campaign__r.Campaign_Start_Date__c;
                                              singleInvRes.Campaign_End_Date__c = invRes.Digital_Campaign__r.Campaign_End_Date__c;    
                                              lstInvSource.add(singleInvRes);
                                           //   }
                                          }
        System.debug('lstInvSource size:::'+lstInvSource.size());
        if(lstInvSource.size()>0){    
            System.debug('lstInvSource:::'+lstInvSource);
            update lstInvSource;      
        }
        
    }
    /*updateInventoryResourceDate end*/
    
    /*@future*/ public static void OnAfterUpdateAsync(Set<ID> updatedDigital_CampaignIDs){
        //List<Digital_Campaign__c> updatedDigital_Campaigns = [select Id, Name from Digital_Campaign where Id IN :updatedDigital_CampaignIDs];
    }
    
    public void OnBeforeDelete(Digital_Campaign__c[] Digital_CampaignsToDelete, Map<ID, Digital_Campaign__c> Digital_CampaignMap){
        
    }
    
    public void OnAfterDelete(Digital_Campaign__c[] deletedDigital_Campaigns, Map<ID, Digital_Campaign__c> Digital_CampaignMap){
        
    }
    
    /*@future*/ public static void OnAfterDeleteAsync(Set<ID> deletedDigital_CampaignIDs){
        
    }
    
    public void OnUndelete(Digital_Campaign__c[] restoredDigital_Campaigns){
        
    }
    
    
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
    
    public boolean IsVisualforcePageContext{
        get{ return !IsTriggerContext;}
    }
    
    public boolean IsWebServiceContext{
        get{ return !IsTriggerContext;}
    }
    
    public boolean IsExecuteAnonymousContext{
        get{ return !IsTriggerContext;}
    }
}