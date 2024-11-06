/*?
Customer/Project:   Spectrum Reach 
Class name:?         DigitalCreativeTriggerHandler
Author/Date:        John King    6/2/2017
Release:?            TBD
Related US:     264, 97
Purpose:            Provides handler methods for the Digital_Creative__c Trigger
Modified:           1/19/2018 - Brett Ballantyne - Added modifications for SRSF-716
6/12/2018 - Brett Ballantyne - Added modifications for SRSF-941

// This should be used in conjunction with the ApexTriggerComprehensive.trigger template
// The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

*/

public class DigitalCreativeTriggerHandler {
    
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public DigitalCreativeTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnBeforeInsert(Digital_Creative__c[] newDigital_Creatives){

        try{
            //Added by Madhusudhan on Sep26th for SRSF-361
            //    User currentUser = [select Id, Name, Sales_Office__c, Region__c, Division__c from User where Id = :UserInfo.getUserId()];
            // Should set the owner of the DCC to the ownerId of the oppty - above code commented out by bab and following code added
            map<string,string> mapDCRecName = new map<string,string>();
            Set<Id> digCampIds = new Set<Id>();
            Set<Id> propIdSet = new Set<Id>();
            for(Digital_Creative__c dc : newDigital_Creatives) {
                // Copy Digital Creative Ownerid to Account Executive(Digital Creative)
               // dc.Account_Executive__c = dc.OwnerId;  //commented this line becuase logic already written below
                if (dc.Digital_Campaign__c != null) {
                    digCampIds.add(dc.Digital_Campaign__c);
                }
                //SRSF-993: start
                //dc.Click_Through_URL__c = (dc.Click_Through_URL_Long__c!=null && dc.Click_Through_URL_Long__c.length() > 255 ? dc.Click_Through_URL_Long__c.left(255)  : dc.Click_Through_URL_Long__c );
                //SRSF-993: end
                
            }
            
            set<string> setDCRectypeName = new set<string>();
            Map<Id, Digital_Campaign__c> digitalCampMap = new Map<Id, Digital_Campaign__c>([select Id, Proposal__c,Recordtype.Name,Creative_Requires_Review_via_SR__c from Digital_Campaign__c where Id in :digCampIds]);
            for (Digital_Campaign__c dc : digitalCampMap.values()) {
                if (dc.Proposal__c != null) {
                    propIdSet.add(dc.Proposal__c);
                }
                setDCRectypeName.add(dc.Recordtype.Name); 
                mapDCRecName.put(dc.Id,dc.Recordtype.Name);
            }
            
            Map<Id, Proposal__c> propMap = new Map<Id, Proposal__c>([select Id, Opportunity__r.OwnerId, 
                                                                     Opportunity__r.Rep_Firm__r.Name,
                                                                     Advertiser__r.Name,
                                                                     Agency__r.Name
                                                                     from Proposal__c where Id in: propIdSet]);
            Set<Id> userIdSet = new Set<Id>();
            for (Proposal__c prop : propMap.values()) {
                userIdSet.add(prop.Opportunity__r.OwnerId);
            }
            Map<Id, User> userMap = new Map<Id, User>([select Id, Sales_Office__c, Region__c, Division__c from User where Id in :userIdSet]);
            
            List<String> DCCStatuses = new List<String>();
            try {
                DCCStatuses = System.Label.DCC_Statuses_For_Date_Submitted.split(',');
                System.debug('============>> DCCStatuses = ' + DCCStatuses);
            } catch (Exception ex) {
                // do nothing
            } 
            
            for(Digital_Creative__c dc : newDigital_Creatives) {
                //Added by Madhusudhan on Sep26th for SRSF-361
                // modified by bab to use the oppty owner fields instead of the current users
                dc.Sales_Office__c = userMap.get(propMap.get(digitalCampMap.get(dc.Digital_Campaign__c).Proposal__c).Opportunity__r.OwnerId).Sales_Office__c;
                dc.Region__c = userMap.get(propMap.get(digitalCampMap.get(dc.Digital_Campaign__c).Proposal__c).Opportunity__r.OwnerId).Region__c;
                dc.Division__c = userMap.get(propMap.get(digitalCampMap.get(dc.Digital_Campaign__c).Proposal__c).Opportunity__r.OwnerId).Division__c;
                //SRSF-4123--> Copy Digital Campaign Ownerid to Account Executive
                dc.Account_Executive__c = propMap.get(digitalCampMap.get(dc.Digital_Campaign__c).Proposal__c).Opportunity__r.OwnerId;//
                dc.OwnerId = propMap.get(digitalCampMap.get(dc.Digital_Campaign__c).Proposal__c).Opportunity__r.OwnerId;
                // SRSF-716
                dc.Rep_Firm_Text__c = propMap.get(digitalCampMap.get(dc.Digital_Campaign__c).Proposal__c).Opportunity__r.Rep_Firm__r.Name;
                dc.Advertiser_Text__c = propMap.get(digitalCampMap.get(dc.Digital_Campaign__c).Proposal__c).Advertiser__r.Name;
                dc.Agency_Text__c = propMap.get(digitalCampMap.get(dc.Digital_Campaign__c).Proposal__c).Agency__r.Name;
                // SRSF-716 end
                
                if (DCCStatuses.size() > 0) {
                    Set<String> statusSet = new Set<String>();
                    statusSet.addAll(DCCStatuses);
                    System.debug('============>> statusSet = ' + statusSet);
                    System.debug('============>> dc.Status__c = ' + dc.Status__c);
                    if (statusSet.contains(dc.Status__c)) {
                        system.debug('===================>> found the status!!!');
                        dc.Date_Last_Submitted__c = DateTime.now();
                    }
                }
                
            }
            
           
            //Added by Madhu on Aug 03-2018
            map<Id,string> mapDCToTier = new map<Id,string>();
            map<Id,string> mapDCToSAM = new map<Id,string>();
            set<Id> setDC = new set<Id>();
            for(Digital_Creative__c dcc: newDigital_Creatives) {
                setDC.add(dcc.Digital_Campaign__c);
                //SRSF - 3993 
                dcc.Creative_Requires_Review__c = digitalCampMap.get(dcc.Digital_Campaign__c).Creative_Requires_Review_via_SR__c;
            }
            if(!setDC.isEmpty()){
                for( Digital_Campaign__c objDC : [select id,Tier_Designation__c,SAM_Designation__c from Digital_Campaign__c where id in : setDC]){
                    if(objDC != null && objDC.Tier_Designation__c != null){
                        mapDCToTier.put(objDC.Id, objDC.Tier_Designation__c);
                    }
                    if(System.label.SAMDesignationShutDown == 'FALSE'){
                        mapDCToSAM.put(objDC.Id, objDC.SAM_Designation__c);
                    }
                }
            }
            for (Digital_Creative__c dcc : newDigital_Creatives) {
                //Tier Designation Mapping
                if(dcc.Digital_Campaign__c!=null && mapDCToTier.containsKey(dcc.Digital_Campaign__c))
                    dcc.Tier_Designation__c = mapDCToTier.get(dcc.Digital_Campaign__c);
                else
                    dcc.Tier_Designation__c = null;

                //SAM Designation Mapping
                if((System.label.SAMDesignationShutDown == 'FALSE') && dcc.Digital_Campaign__c != null && mapDCToSAM.containsKey(dcc.Digital_Campaign__c))
                    dcc.SAM_Designation__c = mapDCToSAM.get(dcc.Digital_Campaign__c);
                else
                    dcc.SAM_Designation__c = null;
            }
            
            //Added by Madhu for SRSF-1631 on May 10-2019
            map<string,string> mapDCToDcc = new map<string,string>();
            for(DCC_Clone_Matrix__mdt objCloneMatrix : [select id,To_Digital_Campaign_RecordType__c,DCC_Recordtype_Name__c from DCC_Clone_Matrix__mdt where To_Digital_Campaign_RecordType__c in :setDCRectypeName and DCC_Recordtype_Name__c!=null]){
                mapDCToDcc.put(objCloneMatrix.To_Digital_Campaign_RecordType__c, objCloneMatrix.DCC_Recordtype_Name__c);
            }
            
            
            for (Digital_Creative__c dcc : newDigital_Creatives) {
                string strDCName = mapDCRecName.get(dcc.Digital_Campaign__c);
                if(strDCName!=null && mapDCToDcc.containskey(strDCName) && mapDCToDcc.get(strDCName)!=null){
                    Id AddressableAdsERecordTypeId = Schema.SObjectType.Digital_Creative__c.getRecordTypeInfosByName().get(mapDCToDcc.get(strDCName)).getRecordTypeId();
                    dcc.RecordTypeId = AddressableAdsERecordTypeId;
                }
            }
            
           
    
        
        }catch(Exception ex){
            String strDCCIds = '';
            for(Digital_Creative__c dcc : newDigital_Creatives) {
                strDCCIds+=dcc.Id+',';
            }
            Log4SF.logMessage('DigitalCreativeTriggerHandler', 'OnBeforeInsert', 'Error on One of the DCC Id which is seperated with ,',ex,UserInfo.getUserId(), strDCCIds);
        }
        
    }

    
    public void OnAfterInsert(Digital_Creative__c[] newDigital_Creatives){
        try{
            // Update Parent Digital Campaign with Max Approved Creative End Date - Added by Govind Thathera - 06/21/2017
            Set<id> DigitalCampaignIds = new Set<Id>();
           // Boolean MigratedCreative =false;        //srsf-4862
            for(Digital_Creative__c dcre: newDigital_Creatives ){
                // System.debug('dcc.Digital_Campaign__r.Creative_Requires_Review_via_SR__c::'+dcre.Digital_Campaign__r.Creative_Requires_Review_via_SR__c);
                if( dcre.Digital_Campaign__c != null) 
                    DigitalCampaignIds.add(dcre.Digital_Campaign__c);
                  // MigratedCreative =dcre.Digital_Campaign__r.Migrated_Creative__c;  //srsf-4862
            }
             
            if( DigitalCampaignIds.size() > 0/* &&  MigratedCreative ==false*/){  //srsf-4862
                updateDigiCampaignWithMaxApprovedCreativeDate( DigitalCampaignIds, newDigital_Creatives );
               updateDigiCampaignWithMaxCreativeStartDate(DigitalCampaignIds,newDigital_Creatives);
            }
        }catch(Exception ex){
            String strDCCIds = '';
            for(Digital_Creative__c dcc : newDigital_Creatives) {
                strDCCIds+=dcc.Id+',';
            }
            Log4SF.logMessage('DigitalCreativeTriggerHandler', 'OnAfterInsert', 'Error on One of the DCC Id which is seperated with ,',ex,UserInfo.getUserId(), strDCCIds);
        }
        //SyncplicitySRUtils.CreateSyncplicityFolders(new List<Id>(new Map<Id, Digital_Creative__c>(newDigital_Creatives).keySet()));
    }
    
    public static void OnAfterInsertAsync(Set<ID> newDigital_CreativeIDs){
        //Example usage
        //List<Digital_Creative> newDigital_Creatives = [select Id, Name from Digital_Creative where Id IN :newDigital_CreativeIDs];
    }
    
    public void OnBeforeUpdate(Digital_Creative__c[] oldDigital_Creatives, Digital_Creative__c[] updatedDigital_Creatives, Map<ID, Digital_Creative__c> Digital_CreativeMap, Map<ID, Digital_Creative__c> oldDigital_CreativeMap){
        //Example Map usage
        //Map<ID, Contact> contacts = new Map<ID, Contact>( [select Id, FirstName, LastName, Email from Contact where Digital_CreativeId IN :Digital_CreativeMap.keySet()] );
        
        try{
            //Added by Madhusudhan on Sep26th for SRSF-361
            Set<Id> ownerIdSet = new Set<Id>();
            Set<Id> dccIds = new Set<Id>();
            for (Digital_Creative__c dc : updatedDigital_Creatives) {
                ownerIdSet.add(dc.OwnerId);
                if(((!String.isBlank(dc.Vast_Tag_2_0_Line_1__c) || !String.isBlank(dc.Vast_Tag_3_0_Line_1__c)) ||  !String.isBlank(dc.Vast_Tag_URL__c)) && dc.Vast_Tag_Enabled__c !=true ){
                    dc.Vast_Tag_Enabled__c = true;
                }
            }
            
            
            Map<Id, User> userMap = new Map<Id, User>([select Id, Name, Sales_Office__c, Region__c, Division__c from User where Id in :ownerIdSet]);        
            
            List<String> DCCStatuses = new List<String>();
            
            try {
                DCCStatuses = System.Label.DCC_Statuses_For_Date_Submitted.split(',');
                System.debug('============>> DCCStatuses = ' + DCCStatuses);
            } catch (Exception ex) {
                // do nothing
            }
            
            for(Digital_Creative__c dc : updatedDigital_Creatives) {
                //Added by Madhusudhan on Sep26th for SRSF-361
                User userRec = userMap.get(dc.OwnerId);
                dc.Sales_Office__c = userRec.Sales_Office__c;
                dc.Region__c = userRec.Region__c;
                dc.Division__c = userRec.Division__c;
                
                if(dc.Status__c != oldDigital_CreativeMap.get(dc.id).status__c){
                    if (DCCStatuses.size() > 0) {
                        Set<String> statusSet = new Set<String>();
                        statusSet.addAll(DCCStatuses);
                        System.debug('============>> statusSet = ' + statusSet);
                        System.debug('============>> dc.Status__c = ' + dc.Status__c);
                        if (statusSet.contains(dc.Status__c)) {
                            system.debug('===================>> found the status!!!');
                            dc.Date_Last_Submitted__c = DateTime.now();
                        }
                    }
                }
                
                
                //SRSF-993: start
                /*if(dc.Click_Through_URL_Long__c != oldDigital_CreativeMap.get(dc.Id).Click_Through_URL_Long__c) {
dc.Click_Through_URL__c = (dc.Click_Through_URL_Long__c.length() > 255 ? dc.Click_Through_URL_Long__c.left(255)  : dc.Click_Through_URL_Long__c );
}
if(dc.Click_Through_URL_Long__c == null) {
dc.Click_Through_URL_Long__c = dc.Click_Through_URL__c;
}*/
                //SRSF-993: end
                
            }
            
            /* Ok, here's a bunch of complicated code because I misunderstood the requirement.  leaving it here in in case they want it in the future
I could see it happening
Set<Id> digCampIds = new Set<Id>();
Set<Id> propIdSet = new Set<Id>();
for(Digital_Creative__c dc : updatedDigital_Creatives) {
if (dc.Digital_Campaign__c != null) {
digCampIds.add(dc.Digital_Campaign__c);
}
}
Map<Id, Digital_Campaign__c> digitalCampMap = new Map<Id, Digital_Campaign__c>([select Id, Proposal__c from Digital_Campaign__c where Id in :digCampIds]);
for (Digital_Campaign__c dc : digitalCampMap.values()) {
if (dc.Proposal__c != null) {
propIdSet.add(dc.Proposal__c);
}          
}

Map<Id, Proposal__c> propMap = new Map<Id, Proposal__c>([select Id, Opportunity__r.OwnerId from Proposal__c where Id in: propIdSet]);
Set<Id> userIdSet = new Set<Id>();
for (Proposal__c prop : propMap.values()) {
userIdSet.add(prop.Opportunity__r.OwnerId);
}
Map<Id, User> userMap = new Map<Id, User>([select Id, Sales_Office__c, Region__c, Division__c from User where Id in :userIdSet]);

for(Digital_Creative__c dc : updatedDigital_Creatives) {
//Added by Madhusudhan on Sep26th for SRSF-361
// modified by bab to use the oppty owner fields instead of the current users
dc.Sales_Office__c = userMap.get(propMap.get(digitalCampMap.get(dc.Digital_Campaign__c).Proposal__c).Opportunity__r.OwnerId).Sales_Office__c;
dc.Region__c = userMap.get(propMap.get(digitalCampMap.get(dc.Digital_Campaign__c).Proposal__c).Opportunity__r.OwnerId).Region__c;
dc.Division__c = userMap.get(propMap.get(digitalCampMap.get(dc.Digital_Campaign__c).Proposal__c).Opportunity__r.OwnerId).Division__c;
}

*/
            
            // SRSF-716
            Set<Id> digCampIds = new Set<Id>();
            Set<Id> propIdSet = new Set<Id>();
            for(Digital_Creative__c dc : updatedDigital_Creatives) {
                if (dc.Digital_Campaign__c != null) {
                    digCampIds.add(dc.Digital_Campaign__c);
                }
            }
            if(DigitalCreativeTriggerHandlerUtil.isRepfirmExecuted == false){
                Map<Id, Digital_Campaign__c> digitalCampMap = new Map<Id, Digital_Campaign__c>([select Id, Proposal__c from Digital_Campaign__c where Id in :digCampIds]);
                for (Digital_Campaign__c dc : digitalCampMap.values()) {
                    if (dc.Proposal__c != null) {
                        propIdSet.add(dc.Proposal__c);
                    }          
                }
                
                Map<Id, Proposal__c> propMap = new Map<Id, Proposal__c>([select Id, 
                                                                         Opportunity__r.Rep_Firm__r.Name,
                                                                         Advertiser__r.Name,
                                                                         Agency__r.Name
                                                                         from Proposal__c where Id in: propIdSet]);
                
                for(Digital_Creative__c dc : updatedDigital_Creatives) {
                    if(digitalCampMap.containsKey(dc.Digital_Campaign__c)){
                        Proposal__c prop = propMap.get(digitalCampMap.get(dc.Digital_Campaign__c).Proposal__c);
                        dc.Rep_Firm_Text__c = prop.Opportunity__r.Rep_Firm__r.Name;
                        dc.Advertiser_Text__c = prop.Advertiser__r.Name;
                        dc.Agency_Text__c = prop.Agency__r.Name;
                        DigitalCreativeTriggerHandlerUtil.isRepfirmExecuted = true;
                    }
                }
            }
            
            // SRSF-716 end
            
            boolean acceptableProfile = false;
            boolean userCanEdit = false; 
            User usrProfileName = [select Id, u.Profile.Name, u.userRole.Name, u.Team_Role__c from User u where u.id = :Userinfo.getUserId()];
            if(usrProfileName.Profile.Name  == 'System Administrator' ||
               usrProfileName.Profile.Name == 'Integration User' ||
               usrProfileName.Profile.Name == 'Master - Digital Sales' ||            
               usrProfileName.Profile.Name == 'Master - Digital Planner' ||
               usrProfileName.Profile.Name == 'Master - Yield and Inventory' ||
               usrProfileName.Profile.Name == 'Master - Optimization Manager' ||
               usrProfileName.Profile.Name == 'Master - Enterprise Digital' ||
               usrProfileName.Profile.Name == 'Master - Digital Operations' ||
               usrProfileName.Profile.Name == 'Master - Digital Traffic' ||
               usrProfileName.Profile.Name == 'Master - Digital Planner' ||
               usrProfileName.Profile.Name == 'Master - Sales Leadership' ||
               usrProfileName.Profile.Name == 'Master - Sales Support Manager' ||
              usrProfileName.Profile.Name == 'Master - Research') {  //SRSF - 4263K 
                   userCanEdit = acceptableProfile = true;
                   
               }
            for(integer i=0;i<updatedDigital_Creatives.size();i++){
                String newDCCStatus = updatedDigital_Creatives[i].Status__c;
                String oldDCCStatus = oldDigital_Creatives[i].Status__c;
                if(newDCCStatus!=oldDCCStatus && oldDCCStatus=='Submit for Expedite Approval'){
                    System.debug('Status ' +oldDCCStatus +newDCCStatus);
                    userCanEdit = true; 
                }
                if(updatedDigital_Creatives[i].Bypass_Apex_Execution__c !=null && updatedDigital_Creatives[i].Bypass_Apex_Execution__c == true){
                    userCanEdit = true;
                }
            }
            if(!userCanEdit) {
                List<Id> opportunities = new List<Id>();
                set<Id> setDCampaignIds = new set<Id>();
                for(Digital_Creative__c dc: updatedDigital_Creatives) {
                    if( dc.OwnerId != UserInfo.getUserId() ){
                        setDCampaignIds.add( dc.Digital_Campaign__c );
                    }
                }
                if( setDCampaignIds.size() > 0 ){
                    set<Id> setOpptyIds = new set<Id>();
                    map<Id, Id> mapDCampaigns = new map<Id, Id>();
                    for( Digital_Campaign__c dCampaign : [SELECT Id, Opportunity__c from Digital_Campaign__c WHERE Id in: setDCampaignIds]){
                        setOpptyIds.add( dCampaign.Id );
                        mapDCampaigns.put( dCampaign.Id, dCampaign.Opportunity__c );
                    }
                    
                    boolean userOnTeam = false;
                    map<Id, Opportunity> mapOpportunities = new map<Id, Opportunity>( [SELECT id, (SELECT id, UserId FROM OpportunityTeamMembers WHERE UserId =:Userinfo.getUserId()) 
                                                                                       FROM Opportunity WHERE Id IN :mapDCampaigns.values() ] );
                    if( mapOpportunities.size() > 0 ){
                        for( Digital_Creative__c dCreative : oldDigital_Creatives){
                            if( mapDCampaigns.get( dCreative.Digital_Campaign__c ) != null ){
                                if( mapOpportunities.get( mapDCampaigns.get( dCreative.Digital_Campaign__c ) ) != null && 
                                   mapOpportunities.get( mapDCampaigns.get( dCreative.Digital_Campaign__c ) ).OpportunityTeamMembers != null && 
                                   mapOpportunities.get( mapDCampaigns.get( dCreative.Digital_Campaign__c ) ).OpportunityTeamMembers.size() > 0 ){
                                       userOnTeam = true;
                                   }else{
                                       userOnTeam = false;
                                       break;
                                   } 
                            } 
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
                for(Digital_Creative__c dc: updatedDigital_Creatives) {
                    try {
                        throw new DmlException('Not correct Profile or Opportunity Team Member to Edit the Digital Creative.');
                    } catch(DMLException e) {
                        Log4SF.logMessage('DigitalCreativeTriggerHandler', 'OnBeforeUpdate', 'You do not have the appropriate permissions to Edit the Digital Creative. If you are not a Digital Sales or Digital Operations user, please make sure you are on the Opportunity Team if you feel you should be able to make changes.',e,UserInfo.getUserId(), dc.Id);
                        dc.addError('You do not have the appropriate permissions to Edit the Digital Creative. If you are not a Digital Sales or Digital Operations user, please make sure you are on the Opportunity Team if you feel you should be able to make changes.');
                    }
                }
            }
            /*for (Digital_Creative__c dcc : [select Tier_Designation__c, Digital_Campaign__c, Digital_Campaign__r.Tier_Designation__c from Digital_Creative__c where id in :updatedDigital_Creatives]) {
if (dcc.Digital_Campaign__c == null) {
dcc.Tier_Designation__c =null;
} else {
dcc.Tier_Designation__c = dcc.Digital_Campaign__r.Tier_Designation__c;
}
}*/
            //Added by Madhu on Aug 03-2018
            map<Id,string> mapDCToSAM = new map<Id,string>();
            map<Id,string> mapDCToTier = new map<Id,string>();
            set<Id> setDC = new set<Id>();
            Id  AddressableAdseRT = Schema.SObjectType.Digital_Creative__c.getRecordTypeInfosByName().get('Addressable AdsE').getRecordTypeId();
            Id  AddressableAdseLockedRT = Schema.SObjectType.Digital_Creative__c.getRecordTypeInfosByName().get('Addressable AdsE - Locked').getRecordTypeId();            
            for(Digital_Creative__c dcc: updatedDigital_Creatives) {
                setDC.add(dcc.Digital_Campaign__c);
            }
            if(!setDC.isEmpty()){
                for( Digital_Campaign__c objDC : [select id,Tier_Designation__c,SAM_Designation__c from Digital_Campaign__c where id in : setDC]){
                    if(objDC != null && objDC.Tier_Designation__c != null){
                        mapDCToTier.put(objDC.Id, objDC.Tier_Designation__c);
                    }
                    if(System.label.SAMDesignationShutDown == 'FALSE'){
                        mapDCToSAM.put(objDC.Id, objDC.SAM_Designation__c);
                    }
                }
            }
            for (Digital_Creative__c dcc : updatedDigital_Creatives) {
                if(dcc.Digital_Campaign__c!=null && mapDCToTier.containsKey(dcc.Digital_Campaign__c))
                    dcc.Tier_Designation__c = mapDCToTier.get(dcc.Digital_Campaign__c);
                else
                    dcc.Tier_Designation__c = null;

                if((System.label.SAMDesignationShutDown == 'FALSE') && dcc.Digital_Campaign__c!=null && mapDCToSAM.containsKey(dcc.Digital_Campaign__c))
                    dcc.SAM_Designation__c = mapDCToSAM.get(dcc.Digital_Campaign__c);
                else
                    dcc.SAM_Designation__c = null;
            }
            /* for (Digital_Creative__c dcc : updatedDigital_Creatives) {
if((dcc.Status__c == '05 Trafficked by Digital Ops' || dcc.Status__c == '64 Date Revision Confirmed by Digital Ops') && 
(dcc.RecordTypeId == AddressableAdseRT || dcc.RecordTypeId == AddressableAdseLockedRT)){
dcc.Creative_Ready_for_Trafficking__c = true;
}else{
dcc.Creative_Ready_for_Trafficking__c = false;
}
}*/
        }catch(Exception ex){
            String strDCCIds = '';
            for(Digital_Creative__c dcc : updatedDigital_Creatives) {
                strDCCIds+=dcc.Id+',';
            }
            Log4SF.logMessage('DigitalCreativeTriggerHandler', 'OnBeforeUpdate', 'Error on One of the DCC Id which is seperated with ,',ex,UserInfo.getUserId(), strDCCIds);
        }
    }
    
    public void OnAfterUpdate(Digital_Creative__c[] oldDigital_Creatives, Digital_Creative__c[] updatedDigital_Creatives, Map<ID, Digital_Creative__c> Digital_CreativeMap, Map<ID, Digital_Creative__c> oldDigital_CreativeMap){
        //Boolean MigratedCreativeval =false;   //srsf-4862
  if(DigitalCreativeTriggerHandlerUtil.isAfterExecuted == false){
            try{
                System.debug('================>> in OnAfterUpdate!!!');
                // Update Parent Digital Campaign with Max Approved Creative End Date - Added by Govind Thathera - 06/21/2017
                Set<id> DigitalCampaignIds = new Set<Id>();
                 Set<id> digCampIdForStartDate = new Set<Id>();
                list<Digital_Creative__c> lstDCC = new list<Digital_Creative__c>();
                for(Digital_Creative__c dcre: updatedDigital_Creatives ){
                    Digital_Creative__c oldDigiCreative = oldDigital_CreativeMap.get( dcre.Id );
                    System.debug('=========================>> dcre.Creative_End_Date__c = ' + dcre.Creative_End_Date__c);
                    System.debug('==============>> oldDigiCreative.Creative_End_Date__c = ' + oldDigiCreative.Creative_End_Date__c);
                    System.debug('=========================>> dcre.Status__c = ' + dcre.Status__c);
                    System.debug('==============>> oldDigiCreative.Status__c = ' + oldDigiCreative.Status__c);
                    //  MigratedCreativeval =dcre.Digital_Campaign__r.Migrated_Creative__c; //srsf-4862
                   if( ( dcre.Digital_Campaign__c != oldDigiCreative.Digital_Campaign__c ) || ( dcre.Creative_End_Date__c != oldDigiCreative.Creative_End_Date__c ) 
                       || ( dcre.Status__c != oldDigiCreative.Status__c )
                       || (dcre.Cancelled_Omit_from_Flight_Dates__c != oldDigiCreative.Cancelled_Omit_from_Flight_Dates__c)){
                           if(dcre.Digital_Campaign__c != null )
                               DigitalCampaignIds.add(dcre.Digital_Campaign__c);
                           if( oldDigiCreative.Digital_Campaign__c != null )
                               DigitalCampaignIds.add(oldDigiCreative.Digital_Campaign__c);
                       }
                    
                    
                     if( ( dcre.Digital_Campaign__c != oldDigiCreative.Digital_Campaign__c ) || ( dcre.Creative_Start_Date__c != oldDigiCreative.Creative_Start_Date__c ) 
                       || ( dcre.Status__c != oldDigiCreative.Status__c )
                       || (dcre.Cancelled_Omit_from_Flight_Dates__c != oldDigiCreative.Cancelled_Omit_from_Flight_Dates__c)){
                           if(dcre.Digital_Campaign__c != null )
                               digCampIdForStartDate.add(dcre.Digital_Campaign__c);
                           if( oldDigiCreative.Digital_Campaign__c != null )
                               digCampIdForStartDate.add(oldDigiCreative.Digital_Campaign__c);
                       }
                   
                    if(dcre.Status__c != oldDigiCreative.Status__c){
                        lstDCC.add(dcre);
                    }
                }
                System.debug('==============>> lstDCC = ' + lstDCC);
                System.debug('==============>> DigitalCampaignIds = ' + DigitalCampaignIds);
                System.debug('==============>> DigitalCampaignIds.size() = ' + DigitalCampaignIds.size());
                
                System.debug('==============>> digCampIdForStartDate = ' + digCampIdForStartDate);
                System.debug('==============>> digCampIdForStartDate.size() = ' + digCampIdForStartDate.size());
                
                if( DigitalCampaignIds.size() > 0 /* && MigratedCreativeval ==false*/){   //srsf-4862
                    updateDigiCampaignWithMaxApprovedCreativeDate( DigitalCampaignIds, lstDCC ); 
                }
                
                if( digCampIdForStartDate.size() > 0 /* && MigratedCreativeval ==false*/){      //srsf-4862 
                    updateDigiCampaignWithMaxCreativeStartDate(digCampIdForStartDate,lstDCC);
                }
            }catch(Exception ex){
                String strDCCIds = '';
                for(Digital_Creative__c dcc : updatedDigital_Creatives) {
                    strDCCIds+=dcc.Id+',';
                }
                Log4SF.logMessage('DigitalCreativeTriggerHandler', 'OnAfterUpdate', 'Error on One of the DCC Id which is seperated with ,',ex,UserInfo.getUserId(), strDCCIds);
            }
        }
        DigitalCreativeTriggerHandlerUtil.isAfterExecuted = true;
    }
    
    public static void OnAfterUpdateAsync(Set<ID> updatedDigital_CreativeIDs){
        //List<Digital_Creative__c> updatedDigital_Creatives = [select Id, Name from Digital_Creative where Id IN :updatedDigital_CreativeIDs];
    }
    
    public void OnBeforeDelete(Digital_Creative__c[] Digital_CreativesToDelete, Map<ID, Digital_Creative__c> Digital_CreativeMap){
        
    }
    
    public void OnAfterDelete(Digital_Creative__c[] deletedDigital_Creatives, Map<ID, Digital_Creative__c> Digital_CreativeMap){
        
    }
    
    public static void OnAfterDeleteAsync(Set<ID> deletedDigital_CreativeIDs){
        
    }
    
    public void OnUndelete(Digital_Creative__c[] restoredDigital_Creatives){
        
    }
    
    // Update Parent Digital Campaign with Max Approved Creative End Date - Added by Govind Thathera - 06/21/2017
    private void updateDigiCampaignWithMaxApprovedCreativeDate( set<Id> digiCampaignIds, list<Digital_Creative__c> lstDCC){
        
            
        
            List<Digital_Campaign__c> DCToUpdate = new List<Digital_Campaign__c>();
            Map<Id,Digital_Campaign__c> DCToUpdatemap = new Map<Id,Digital_Campaign__c>();
            Map<Id, Integer> trafficDccCountMap = new Map<Id, Integer>();
            Map<Id, Integer> pendingDccCountMap = new Map<Id, Integer>();
            
            for(id dc:digiCampaignIds){
                DCToUpdatemap.put(dc,new Digital_Campaign__c(Id = dc,Max_Trafficked_Creative_End_Date__c = null));        
            }
            
            // Get counts of DCCs where Cancelled_Omit_from_Flight_Dates__c = false.  Used to null out the max trafficked creatie End date
            String query = 'select count(Id), Digital_Campaign__c from Digital_Creative__c ' +
                'where Cancelled_Omit_from_Flight_Dates__c = false ' +
                'and (Status__c=\'05 Trafficked by Digital Ops\' OR Status__c = \'64 Date Revision Confirmed by Digital Ops\' OR Status__c = \'99 Creative Completed\') ' +
                'and Digital_Campaign__c in :digiCampaignIds ' +
                'group by Digital_Campaign__c';
            
            for (AggregateResult agg : Database.query(query)) {
                trafficDccCountMap.put((Id) agg.get('Digital_Campaign__c'), Integer.valueOf(agg.get('expr0')));
                System.debug('===============>> adding to trafficDccCountMap (Id, Count): ' + agg.get('Digital_Campaign__c') + ', ' + Integer.valueOf(agg.get('expr0')));
            } 
            
            query = 'select count(Id), Digital_Campaign__c from Digital_Creative__c ' +
                'where Cancelled_Omit_from_Flight_Dates__c = false ' +
                'and (Status__c != \'05 Trafficked by Digital Ops\' AND Status__c != \'64 Date Revision Confirmed by Digital Ops\' AND Status__c != \'99 Creative Completed\') ' +
                'and Digital_Campaign__c in :digiCampaignIds ' +
                'group by Digital_Campaign__c';
            
            for (AggregateResult agg : Database.query(query)) {
                pendingDccCountMap.put((Id) agg.get('Digital_Campaign__c'), Integer.valueOf(agg.get('expr0')));
                System.debug('===============>> adding to pendingDccCountMap (Id, Count): ' + agg.get('Digital_Campaign__c') + ', ' + Integer.valueOf(agg.get('expr0')));
            } 
            
            Map<Id, Digital_Creative__c> dccTraffMap = new map<Id, Digital_Creative__c>([select Id, status__c, Creative_End_Date__c
                                                                                         FROM   Digital_Creative__c
                                                                                         WHERE  (Status__c='05 Trafficked by Digital Ops' OR Status__c = '64 Date Revision Confirmed by Digital Ops' OR Status__c = '99 Creative Completed' OR Status__c = '00 Abandoned Creative') 
                                                                                         AND Cancelled_Omit_from_Flight_Dates__c = false 
                                                                                         AND Digital_Campaign__c in :digiCampaignIds]);
            
            
            //Query Max Creative End Date from Digital Creatives
            AggregateResult[] groupedResults =[SELECT Digital_Campaign__c, MAX(Creative_End_Date__c) maxCED 
                                               FROM   Digital_Creative__c 
                                               WHERE  (Status__c='05 Trafficked by Digital Ops' OR Status__c = '64 Date Revision Confirmed by Digital Ops' OR Status__c = '99 Creative Completed' OR Status__c = '00 Abandoned Creative') 
                                               ////          AND Cancelled_Omit_from_Flight_Dates__c = false     // SRSF-941
                                               AND Id in :dccTraffMap.keySet()  
                                               GROUP  BY Digital_Campaign__c];
            System.debug('==================>> groupedResults(Trafficked) = ' + groupedResults);
            if (groupedResults.size() == 0) {
                for (Digital_Campaign__c dc : DCToUpdatemap.values()) {
                    dc.Max_Trafficked_Creative_End_Date__c = null;
                    DCToUpdatemap.put(dc.Id, dc);
                    System.debug('DCToUpdatemap ==== '+DCToUpdatemap);
                }
            }
            
            //Update Max Approved Creative End Date for each Digital Campaign
            for(AggregateResult ar: groupedResults){
                Integer dccCount = trafficDccCountMap.get((Id)ar.get('Digital_Campaign__c'));
                Date MaxTraffickedCreativeEndDate = (dccCount == null) ? null : (Date)ar.get('maxCED');
                System.debug('MaxTraffickedCreativeEndDate=====' +MaxTraffickedCreativeEndDate);
                System.debug('==================>> Id = ' + ar.get('Digital_Campaign__c'));
                System.debug('==================>> !Contains key = ' + !DCToUpdatemap.containskey((Id)ar.get('Digital_Campaign__c')));
                System.debug('==================>> count = ' + trafficDccCountMap.get((Id)ar.get('Digital_Campaign__c')));
                if(!DCToUpdatemap.containskey((Id)ar.get('Digital_Campaign__c'))){
                    DCToUpdatemap.put((Id)ar.get('Digital_Campaign__c'),new Digital_Campaign__c(Id = (Id)ar.get('Digital_Campaign__c'),
                                                                                                Max_Trafficked_Creative_End_Date__c = MaxTraffickedCreativeEndDate,
                                                                                                Bypass_Apex_Execution__c = true
                                                                                               ));
                    
                }else{
                    System.debug('---------------->> in else!!!!!');
                    Digital_Campaign__c dc = DCToUpdatemap.get((Id)ar.get('Digital_Campaign__c'));
                    if ((MaxTraffickedCreativeEndDate > dc.Max_Trafficked_Creative_End_Date__c) || dc.Max_Trafficked_Creative_End_Date__c == null) {
                        
                        dc.Max_Trafficked_Creative_End_Date__c = MaxTraffickedCreativeEndDate;
                        dc.Bypass_Apex_Execution__c = true; 
                        System.debug('------------------>> dc (trafficked) = ' + dc);
                        System.debug('------------------>> dc.Max_Trafficked_Creative_End_Date__c = ' + dc.Max_Trafficked_Creative_End_Date__c);
                        // bab 6/25
                        DCToUpdatemap.put(dc.Id, dc);
                        // end bab
                    }
                }
                
                
            }
            
            
            //Query to calculate Max Creative End Date for calculaing Max_Pending_Creative_End_Date__c from Digital Creatives --> Added by Vinay chaturvedi
            Map<Id, Digital_Creative__c> dccMap = new map<Id, Digital_Creative__c>([select Id, status__c, Creative_End_Date__c
                                                                                    FROM   Digital_Creative__c
                                                                                    WHERE  (Status__c!='05 Trafficked by Digital Ops' AND Status__c != '64 Date Revision Confirmed by Digital Ops' AND Status__c != '99 Creative Completed' AND Status__c!= '00 Abandoned Creative') 
                                                                                    AND Cancelled_Omit_from_Flight_Dates__c = false 
                                                                                    AND Digital_Campaign__c in:digiCampaignIds]);
            
            AggregateResult[] groupedResults1 =[SELECT status__c,Digital_Campaign__c, MAX(Creative_End_Date__c) maxCED 
                                                FROM   Digital_Creative__c 
                                                WHERE  (Status__c!='05 Trafficked by Digital Ops' AND Status__c != '64 Date Revision Confirmed by Digital Ops' AND Status__c != '99 Creative Completed' AND Status__c!= '00 Abandoned Creative') 
                                                AND Id IN :dccMap.keySet()
                                                ////                   AND Digital_Campaign__c in:digiCampaignIds  
                                                GROUP  BY Digital_Campaign__c,status__c];
            if (groupedResults1.size() == 0) {
                for (Digital_Campaign__c dc : DCToUpdatemap.values()) {
                    System.debug('Inside 590 if');
                    dc.Max_Pending_Creative_End_Date__c = null;
                    dc.Max_Pending_Creative_End_Date_Record_St__c = null;
                    DCToUpdatemap.put(dc.Id, dc);
                }
            }
            //Update Max Approved Creative End Date for each Digital Campaign
            for(AggregateResult ar: groupedResults1){ 
                Integer dccCount = pendingDccCountMap.get((Id)ar.get('Digital_Campaign__c'));
                Date MaxPendingCreativeEndDate = (dccCount == null) ? null : (Date)ar.get('maxCED');
                String PendingStatus = (dccCount == null) ? null : (string)ar.get('status__c');
                System.debug('PendingStatus' +PendingStatus);
                if(!DCToUpdatemap.containskey((Id)ar.get('Digital_Campaign__c'))){
                    DCToUpdatemap.put((Id)ar.get('Digital_Campaign__c'),new Digital_Campaign__c(Id = (Id)ar.get('Digital_Campaign__c'),
                                                                                                Max_Pending_Creative_End_Date__c = MaxPendingCreativeEndDate,
                                                                                                Bypass_Apex_Execution__c = true,
                                                                                                Max_Pending_Creative_End_Date_Record_St__c = PendingStatus
                                                                                               ));
                }else{
                    Digital_Campaign__c dc = DCToUpdatemap.get((Id)ar.get('Digital_Campaign__c'));
                    System.debug('----------------->> before if,  MaxPendingCreativeEndDate= ' +  MaxPendingCreativeEndDate);
                    System.debug('----------------->> before if,  dc.Max_Pending_Creative_End_Date__c= '  + dc.Max_Pending_Creative_End_Date__c);
                    System.debug('PendingStatus else' +PendingStatus);
                    
                    if ((MaxPendingCreativeEndDate > dc.Max_Pending_Creative_End_Date__c) || dc.Max_Pending_Creative_End_Date__c == null) {
                        system.debug('################## in IF!!!  ###########');
                        system.debug('################## in IF Max_Pending_Creative_End_Date_Record_St__c!!!  ###########' + PendingStatus );
                        dc.Max_Pending_Creative_End_Date__c = MaxPendingCreativeEndDate;
                        dc.Bypass_Apex_Execution__c = true;
                        dc.Max_Pending_Creative_End_Date_Record_St__c = PendingStatus;    
                        system.debug('Max_Pending_Creative_End_Date_Record_St__c!!!  ###########' + dc.Max_Pending_Creative_End_Date_Record_St__c );
                        // bab 6/25
                        DCToUpdatemap.put(dc.Id, dc);
                        // end bab
                    }
                    
                }
                
            }
            //logic to update DC data fields(Creative_Ready_for_Trafficking__c, Creative_Prepared_Date__c) based on DCC status
            if(!lstDCC.isEmpty()){
                Id dcId = lstDCC[0].Digital_Campaign__c;
                List<Digital_Campaign__c> dc = [Select id,RecordType.Name from Digital_Campaign__c where id =:dcId limit 1]; 
                for(Digital_Creative__c objDCC : lstDCC){   
                    String dcRecordTypeName = dc[0].RecordType.Name;
                    if((objDCC.Status__c == '05 Trafficked by Digital Ops' || objDCC.Status__c == '64 Date Revision Confirmed by Digital Ops') && 
                       (dcRecordTypeName == 'New Ads Everywhere' || (dcRecordTypeName == 'Inventory Request - Revision - New Ads Everywhere'))){
                           Date maxTrafficCreativeEndDate = DCToUpdatemap.get(dcId).Max_Trafficked_Creative_End_Date__c;
                           Date maxPendingCreativeEndDate = DCToUpdatemap.get(dcId).Max_Pending_Creative_End_Date__c;
                           String maxPendingCreativeRecordStatus = DCToUpdatemap.get(dcId).Max_Pending_Creative_End_Date_Record_St__c;
                           DCToUpdatemap.put(dcId,new Digital_Campaign__c(Id = dcId,
                                                                          Creative_Ready_for_Trafficking__c = true,
                                                                          Creative_Prepared_Date__c = datetime.now(),
                                                                          Max_Trafficked_Creative_End_Date__c = maxTrafficCreativeEndDate,
                                                                          Max_Pending_Creative_End_Date__c = maxPendingCreativeEndDate,
                                                                          Max_Pending_Creative_End_Date_Record_St__c = maxPendingCreativeRecordStatus
                                                                         ));
                       }
                }
            }
            
            if(DCToUpdatemap.size() > 0){
                update DCToUpdatemap.values();
            }
            
        }
    
    
     //SRSF-4269 Start
    private void updateDigiCampaignWithMaxCreativeStartDate( set<Id> digiCampaignIds, list<Digital_Creative__c> lstDCC){
        
        Validation_Bypass_Setting__c setting  ;
        String userId = userinfo.getUserId();
        setting = Validation_Bypass_Setting__c.getInstance(userId);
        setting.Minimum_Date_Update_Bypass__c    = true;
        upsert setting;
        
        System.debug('****In updateDigiCampaignWithMaxCreativeStartDate');
        List<Digital_Campaign__c> DCToUpdate = new List<Digital_Campaign__c>();
        Map<Id,Digital_Campaign__c> DCToUpdatemap = new Map<Id,Digital_Campaign__c>();
        Map<Id, Integer> trafficDccCountMap = new Map<Id, Integer>();
        Map<Id, Integer> pendingDccCountMap = new Map<Id, Integer>();
        //SRSF- 4544- Added By khushboo [(DCC_Pending_Status_For_Min) this custom label used for DCC pending status.]
        //Set<String> statusForPending = new Set<String>{System.label.DCC_Pending_Status_For_Min}; 
       
        Set<String> statusForPending = new Set<String>();
  		statusForPending.addall(System.label.DCC_Pending_Status_For_Min.split(','));

       /* Map for digitalCampaignid and digitalcampaign refrence*/
        for(id dc:digiCampaignIds){
            DCToUpdatemap.put(dc,new Digital_Campaign__c(Id = dc,Min_Pending_Creative_Start_Date__c = null));        
        }
        

        /*query for pending digital creative*/
        String query = 'select count(Id), Digital_Campaign__c from Digital_Creative__c ' +
            'where Cancelled_Omit_from_Flight_Dates__c = false ' +
            'and Status__c IN : statusForPending ' +
            'and Digital_Campaign__c in :digiCampaignIds ' +
            'group by Digital_Campaign__c';
        
        
        /* pendingDccCountMap for digital campaign with digital creative(pending)*/
        for (AggregateResult agg : Database.query(query)) {
            pendingDccCountMap.put((Id) agg.get('Digital_Campaign__c'), Integer.valueOf(agg.get('expr0')));
            System.debug('===============>>StartDate adding to pendingDccCountMap (Id, Count): ' + agg.get('Digital_Campaign__c') + ', ' + Integer.valueOf(agg.get('expr0')));
        } 
        
         

        Map<Id, Digital_Creative__c> dccMap = new map<Id, Digital_Creative__c>([select Id, status__c, Creative_Start_Date__c
                                                                                FROM   Digital_Creative__c
                                                                                WHERE  Status__c  IN: statusForPending
                                                                                AND Cancelled_Omit_from_Flight_Dates__c = false 
                                                                                AND Digital_Campaign__c in:digiCampaignIds]);
        
        System.debug('****dccMap***'+dccMap);
        System.debug('****dccMap size***'+dccMap.size());
        AggregateResult[] groupedResults1 =[SELECT status__c,Digital_Campaign__c, MIN(Creative_Start_Date__c) maxCED 
                                            FROM   Digital_Creative__c 
                                            WHERE  Status__c  IN: statusForPending
                                            AND Id IN :dccMap.keySet()
                                            GROUP  BY Digital_Campaign__c,status__c];

        /* Logic for making Min_Pending_Creative_Start_Date__c as null when no  pending digital creative record exist for spexific digital campaign  */
        if (groupedResults1.size() == 0) {
            for (Digital_Campaign__c dc : DCToUpdatemap.values()) {
                dc.Min_Pending_Creative_Start_Date__c = null;
                dc.Min_Pending_Creative_Start_Date_Record_S__c = null;
                dc.Bypass_Apex_Execution__c = true;
                DCToUpdatemap.put(dc.Id, dc);
            }
        }
        System.debug('***groupedResults1***'+groupedResults1);  
        
        
        /* Logic for populating earliest date in Min_Pending_Creative_Start_Date__c  when minimum 1 pending digital creative record exist for specific digital campaign  */
        for(AggregateResult ar: groupedResults1){ 
            Integer dccCount = pendingDccCountMap.get((Id)ar.get('Digital_Campaign__c'));
            Date minPendingCreativeStartDate = (dccCount == null) ? null : (Date)ar.get('maxCED');
            String PendingStatus = (dccCount == null) ? null : (string)ar.get('status__c');
            System.debug('PendingStatus' +PendingStatus);
            if(!DCToUpdatemap.containskey((Id)ar.get('Digital_Campaign__c'))){
                DCToUpdatemap.put((Id)ar.get('Digital_Campaign__c'),new Digital_Campaign__c(Id = (Id)ar.get('Digital_Campaign__c'),
                                                                                            Min_Pending_Creative_Start_Date__c = minPendingCreativeStartDate,
                                                                                            Bypass_Apex_Execution__c = true,
                                                                                            Min_Pending_Creative_Start_Date_Record_S__c = PendingStatus
                                                                                           ));
            }else{
                Digital_Campaign__c dc = DCToUpdatemap.get((Id)ar.get('Digital_Campaign__c'));
                System.debug('----------------->> before if,  minPendingCreativeStartDate= ' +  minPendingCreativeStartDate);
                System.debug('----------------->> before if,  dc.Min_Pending_Creative_Start_Date__c= '  + dc.Min_Pending_Creative_Start_Date__c);
                System.debug('PendingStatus else' +PendingStatus);
                
                if ((minPendingCreativeStartDate < dc.Min_Pending_Creative_Start_Date__c) || dc.Min_Pending_Creative_Start_Date__c == null) {
                    system.debug('################## in IF!!!  ###########');
                    system.debug('################## in IF Max_Pending_Creative_Start_Date_Record_St__c!!!  ###########' + PendingStatus );
                    dc.Min_Pending_Creative_Start_Date__c = minPendingCreativeStartDate;
                    dc.Bypass_Apex_Execution__c = true;
                    dc.Min_Pending_Creative_Start_Date_Record_S__c = PendingStatus;   
                    system.debug('Max_Pending_Creative_Start_Date_Record_St__c!!!  ###########' + dc.Min_Pending_Creative_Start_Date_Record_S__c );
                    DCToUpdatemap.put(dc.Id, dc);  
                }          
            } 
        }
         
        System.debug('***lstDCC**'+lstDCC);
        //Commenting out for fix 8-30-23 JCleveland
        //logic to update DC data fields(Min_Pending_Creative_Start_Date__c, Min_Pending_Creative_Start_Date_Record_S__c) based on DCC status
        if(!lstDCC.isEmpty()){
            Id dcId = lstDCC[0].Digital_Campaign__c;
            System.debug('***Id***'+dcId);
            List<Digital_Campaign__c> dc = [Select id,RecordType.Name from Digital_Campaign__c where id =:dcId limit 1]; 
            System.debug('***lstDcc**'+lstDCC);
       //SRSF-4450 -->TO check the DCC RT and the below condition, it will update the dc status to current DCC status;if the status of dc is updated to 02
              //then subsequestly, the status of DC will get updated with the same value.
            Id AddressableAdseLockedId = Schema.SObjectType.Digital_Creative__c.getRecordTypeInfosByName().get('Addressable AdsE - Locked').getRecordTypeId();
            Id AddressableAdseId =Schema.SObjectType.Digital_Creative__c.getRecordTypeInfosByName().get('Addressable AdsE').getRecordTypeId();
            for(Digital_Creative__c objDCC : lstDCC){   
                String dcRecordTypeName = dc[0].RecordType.Name;
                System.debug('objDCC.Status__c::'+objDCC.Status__c);
                 System.debug('statusForPending::'+statusForPending);
                SYstem.debug('statusForPending.contains(objDCC.Status__c)::'+statusForPending.contains(objDCC.Status__c));
                if(statusForPending.contains(objDCC.Status__c)){
                       Date minPendingCreativeStartDate = DCToUpdatemap.get(dcId).Min_Pending_Creative_Start_Date__c;   
                       String minPendingCreativeRecordStatus = DCToUpdatemap.get(dcId).Min_Pending_Creative_Start_Date_Record_S__c;
                    //SRSF-4450: DCC Process builder logic to update min pending date field on DC.
                       /* if(minPendingCreativeRecordStatus == '02 Submitted to Digital Ops' && !objDCC.Vast_Tag_Enabled__c && 
                                    !objDCC.Split_Avail__c && objDCC.X1x1_Pixel_Placement_ID__c==null && 
                                    (objDCC.RecordTypeId==AddressableAdseLockedId  || AddressableAdseId==objDCC.RecordTypeId)) {
                            minPendingCreativeRecordStatus = ''; //SRSF-4589:Condn to make a field null when the DCC goes to 2.1.
                            minPendingCreativeStartDate = null;
                        }*/
                    
                    
                       DCToUpdatemap.put(dcId,new Digital_Campaign__c(Id = dcId,
                                                                      Min_Pending_Creative_Start_Date__c = minPendingCreativeStartDate,
                                                                      Min_Pending_Creative_Start_Date_Record_S__c = minPendingCreativeRecordStatus,
                                                                      Bypass_Apex_Execution__c = true
                                                                     ));
                       System.debug('***DCToUpdatemap***'+DCToUpdatemap);
                }
            }

        } 
        
     
        if(DCToUpdatemap.size() > 0){
            System.debug('****DCToUpdatemap value:::'+DCToUpdatemap);
            update DCToUpdatemap.values();
            
                
            setting.Minimum_Date_Update_Bypass__c    = false;
            update setting;
        }
        
    }
    //SRSF-4269 End
    
    
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