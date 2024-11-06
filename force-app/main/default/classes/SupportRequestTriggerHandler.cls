/*
Customer/Project:   Spectrum Reach
Class name:         SupportRequestTriggerHandler
Author/Date:        John King    5/23/2017
Release:            TBD
Related US:         264, 97
Purpose:            Provides handler methods for the Support_Request__c Trigger
Modified:           1/19/2018 - Added refactoring comments to refactor the for loop in OnBeforeInsert.
Decided not to refactor at this point since it's Friday evening and UAT starts Monday
1/19/2018 - Brett Ballantyne - Added modifications for SRSF-716
2/20/2018 - Brett Ballantyne - SRSF-723 and refactor
*/

public with sharing class SupportRequestTriggerHandler {
    
    
    private boolean m_isExecuting = false;
    private Integer BatchSize = 0;
    public static Id prdTypeId;
    public static Map<Id,String> sendtoBoomi;
    public static HttpCalloutMock mock = null;    
    
    public SupportRequestTriggerHandler(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
        sendtoBoomi = new Map<Id,String>();
    }
    
    public void OnBeforeInsert(Support_Request__c[] newSupport_Requests) {
        
        // Notes for the refactor:
        /*      1. Remove SOQL queries from the for loop (done as part of SRSF-723)
2. Refactoring the multiple loops into one, merging changes done for SRSF-716 and probably other stories into one loop
*/
        
        Set<Id> advertiserIdSet = new Set<Id>();
        Set<Id> agencyIdSet = new Set<Id>();
        Set<Id> opptyIdSet = new Set<Id>();
        Set<Id> setAE = new Set<Id>();
        //   Set<Id> opptyOwnerIds = new Set<Id>();
        Set<Id> opptyAccountIds = new Set<Id>();
        
        for (Support_Request__c sr : newSupport_Requests) {
            if (sr.Advertiser__c != null) {
                advertiserIdSet.add(sr.Advertiser__c);
            } 
            if (sr.Opportunity__c != null) {
                opptyIdSet.add(sr.Opportunity__c);
            }
            if (sr.Agency__c != null) {
                agencyIdSet.add(sr.Agency__c);
            }
            if (sr.Account_Executive__c != null) {
                setAE.add(sr.Account_Executive__c);
            }    
        }
        
        Map<Id, Id> advertiserToAgencyIdMap = new Map<Id, Id>();
        for (Account acc : [SELECT Agency__c FROM Account WHERE Id IN :advertiserIdSet]) {
            advertiserToAgencyIdMap.put(acc.Id, acc.Agency__c);   // acc.Id will be the support request Advertiser__c field
        }
        
        
        Map<Id, Account> advertiserMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN : advertiserIdSet]);
        Map<Id, Account> agencyMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN : agencyIdSet]);
        Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>();
        //SRSF-2633 : Added Multiclultural field to SOQL
        for (Opportunity opp : [SELECT Id, AccountId, Agency_Account__c, OwnerId, Rep_Firm__r.Name, Multicultural__c FROM Opportunity WHERE Id IN :opptyIdSet]) {
            opptyMap.put(opp.Id, opp);
            //    opptyOwnerIds.add(opp.Id);
            if (opp.AccountId != null)
                opptyAccountIds.add(opp.AccountId);
        }
        
        Map<Id, Account> opptyAccountMap = new Map<Id, Account>([SELECT Id, ShippingStreet, ShippingCity, ShippingState,
                                           ShippingPostalCode, ShippingCountry FROM Account WHERE Id IN : opptyAccountIds]);
        
        ////   Map<Id, User> userMap = new Map<Id, User>([select Sales_Office__c, Region__c from User where Id in :opptyOwnerIds]);
        
        for (Support_Request__c sr : newSupport_Requests) {
            System.debug('OnBeforeInsert: SR');
            
            if(sr.Opportunity__c == null) {
                try {
                    throw new DmlException('No Opportunity set.');
                } catch(DMLException e) {
                    sr.addError('A Support Request must originate from an Opportunity.');
                }
            }
            
            //built from Opportunity:
            if (sr.Opportunity__c != null && sr.Advertiser__c != null) {
                System.debug('Built from oppty w/ account');
                Opportunity opp = opptyMap.get(sr.Opportunity__c);
                
               // Id acctId = advertiserToAgencyIdMap.get(sr.Advertiser__c);
                Id acctId = opp.Agency_Account__c;
                if (acctId != null) {
                    Account acc = opptyAccountMap.get(sr.Opportunity__c);
                    if (acc != null) {
                        sr.Advertiser_Locations__c = acc.ShippingStreet + '\n' +
                            acc.ShippingCity + ', ' + acc.ShippingState + '  ' + acc.ShippingPostalCode + '\n' +
                            acc.ShippingCountry;
                    }
                  sr.Agency__c = acctId;  
                }
               // sr.Agency__c = acctId;
            }
            // Start: SRSF-1897 
            String rtDevName = Schema.getGlobalDescribe().get('Support_Request__c').getDescribe().getRecordTypeInfosById().get(sr.RecordTypeId).getDeveloperName();
            if(rtDevName == 'Audience_Request' && sr.Status__c == 'Draft'){
                sr.Date_Time_Submitted__c=null;
                sr.Date_Time_Completed__c=null;
                sr.Audience_Creation_Team_Feedback__c = null;
                sr.Working__c=null;
            }
            // End: SRSF-1897
            
            // SRSF-716
            if (sr.Opportunity__c != null) {
                sr.Rep_Firm_Text__c = (opptyMap.get(sr.Opportunity__c)).Rep_Firm__r.Name;
                sr.Multicultural__c = (opptyMap.get(sr.Opportunity__c)).Multicultural__c; // SRSF-2633 : 08-04-2021
            }
            if (sr.Agency__c != null) {
                System.debug('-------->> sr.Agency__c = -' + sr.Agency__c + '-');
                System.debug('============>> get from agencyMap = ' + agencyMap.get(sr.Agency__c));
                Account acc = agencyMap.get(sr.Agency__c);
                if (acc != null)
                    sr.Agency_Text__c = acc.Name;
            }
            if (sr.Advertiser__c != null) {
                sr.Advertiser_Text__c = (advertiserMap.get(sr.Advertiser__c)).Name;
            }
            // end SRSF-716
            
            //clearing the Dell boomi fields for cloned or new records
            sr.Boomi_Error_Message__c='';
            sr.IMN_ID__c='';
            sr.Work_Request_ID__c=''; // added on 09-07-2020
            sr.Integrated_with_IMN__c=false;
            sr.IMN_Sync_Status__c='';  
        }

        Map<String,String> mapAdvToTier = new Map<String,String>();
        Map<String,String> mapAdvAEToSAM = new Map<String,String>();
        //Added regarding Tier Designation field update SRSF-4944
        if(!advertiserIdSet.isEmpty()){
            for(Account_SAM_Mapping__c objAcc : [SELECT Id,Tier_Designation__c,User__c,Account__c,SAM_Designation__c FROM Account_SAM_Mapping__c WHERE Account__c IN :advertiserIdSet]){
                if(objAcc != null && objAcc.Tier_Designation__c != null)
                    mapAdvToTier.put(String.valueOf(objAcc.account__c), objAcc.Tier_Designation__c);

                if(System.label.SAMDesignationShutDown == 'FALSE')
                    mapAdvAEToSAM.put(String.valueOf(objAcc.account__c)+String.valueOf(objAcc.User__c), objAcc.SAM_Designation__c);
            }
            for (Support_Request__c sr : newSupport_Requests) {
                //Tier Designation Mapping
                if(String.isNotBlank(sr.Advertiser__c) && mapAdvToTier.containsKey(String.valueOf(sr.Advertiser__c))){
                    sr.Tier_Designation__c = mapAdvToTier.get(sr.Advertiser__c);
                }
                else{
                    sr.Tier_Designation__c = null;
                }
                
                //SAM Designation Mapping
                if((System.label.SAMDesignationShutDown == 'FALSE') &&String.isNotBlank(sr.Advertiser__c) && String.isNotBlank(sr.Account_Executive__c) && mapAdvAEToSAM.containsKey(String.valueOf(sr.Advertiser__c)+String.valueOf(sr.Account_Executive__c))){
                    if(mapAdvAEToSAM.get(String.valueOf(sr.Advertiser__c)+String.valueOf(sr.Account_Executive__c)) == 'In Approval Process'){
                        sr.SAM_Designation__c = 'In Approval Process';
                    }
                    else{
                        sr.SAM_Designation__c = mapAdvAEToSAM.get(String.valueOf(sr.Advertiser__c)+String.valueOf(sr.Account_Executive__c));
                    }
                }
                else{
                    sr.SAM_Designation__c = null;
                }
            }
        }
        System.debug('calling updateWorkingAndAssignedTo');
        updateWorkingAndAssignedTo(null, newSupport_Requests, null);
    }
    
    public void OnAfterInsert(Support_Request__c[] newSupport_Requests) {
        //SyncplicitySRUtils.CreateSyncplicityFolders(new List<Id>(new Map<Id, Support_Request__c>(newSupport_Requests).keySet()));
    }
    
    @future public static void OnAfterInsertAsync(Set<ID> newSupport_RequestIDs) {
        //Example usage
        //List<Support_Request> newSupport_Requests = [select Id, Name from Support_Request where Id IN :newSupport_RequestIDs];
    }
    
    public void OnBeforeUpdate(Support_Request__c[] oldSupport_Requests, Support_Request__c[] updatedSupport_Requests, Map<ID, Support_Request__c> Support_RequestMap) {
        // Start: SRSF-1897
        Map<String,Data_Catalog__c> datacatMap = new Map<String,Data_Catalog__c> ();
        List<Data_Catalog__c> datacatList = new List<Data_Catalog__c> ([SELECT DISPLAY_TEXT__c,Political__c, Restricted_Interest__c FROM Data_Catalog__c WHERE DISPLAY_TEXT__c!=null]);
        for(Data_Catalog__c dc: datacatList){
            datacatMap.put(dc.DISPLAY_TEXT__c, dc);
        }
        // End: SRSF-1897 
        Id currentUserProfileId= userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:currentUserProfileId].Name;
        String RR_ProfilesAbleToChangeStatus = System.Label.RR_ProfilesAbleToChangeStatus;
        List<String> RR_ProfilesAbleToChangeStatusList=new List<String>();
    	RR_ProfilesAbleToChangeStatusList=RR_ProfilesAbleToChangeStatus.split(',');
        Map<Id, Support_Request__c> olsSupportReq = new Map<Id, Support_Request__c>(oldSupport_Requests);
        System.debug('olsSupportReq' +olsSupportReq);
        Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Support_Request__c.fields.getMap(); 
        for(Support_Request__c sr : updatedSupport_Requests){
          Support_Request__c oldSR = olsSupportReq.get(sr.Id);  
          
            //SRSF-3993 
            
          if((profileName =='Master - Research' || profileName =='System Administrator') && sr.Status__c  == 'Approved Pending Creative Review' &&  oldSR.get('status__c')!=sr.Status__c )  {
                sr.Creative_Requires_Review__c = true;
          }/*else if((profileName =='Master - Research' || profileName =='System Administrator') && (sr.Status__c  != 'Approved Pending Creative Review') &&  oldSR.get('status__c')!=sr.Status__c ) {
              sr.Creative_Requires_Review__c = false;
          }*/
          
          //End- SRSF-3993
             
          String recordtypename = Schema.getGlobalDescribe().get('Support_Request__c').getDescribe().getRecordTypeInfosById().get(sr.RecordTypeId).getName();
         
            if(RR_ProfilesAbleToChangeStatusList.contains(profileName) && recordtypename == 'Research Request'){
                
                for (String str : mapFields.keyset()) {
                  if(str == 'status__c' && oldSR.get('status__c') == 'Completed by Research'){
                      if(sr.get('status__c')=='Revisions Needed'){
                          sr.Bypass_Apex_Execution__c = True; 
                      }
                      else{
                          sr.addError('You are allowed to change the status from Completed by Research to Revisions Needed ONLY.');
                      }                  
                  }
                  else if(sr.get(str) != oldSR.get(str) && str != 'status__c' && str != 'user_alert__c' && str !='bypass_apex_execution__c'){
                      sr.Bypass_Apex_Execution__c = False;
                  }
         	 	}
                
            }

            //Start : SRSF-1897 : Validations for Audience Request records           
            if (recordtypename =='Audience Request')
            {                
                List<String> displayTxtLst = new List<String>();
                if(!CommonUtilities.isStringNullOrEmpty(sr.Addressable_Online_Data_Catalog__c)){       
                    displayTxtLst.addAll(sr.Addressable_Online_Data_Catalog__c.split(';'));
                }
                if(!CommonUtilities.isStringNullOrEmpty(sr.Streaming_TV_Data_Catalog__c)){       
                    displayTxtLst.addAll(sr.Streaming_TV_Data_Catalog__c.split(';'));
                }

                // block Record Status change if there are no Data Catalog selection
                if(sr.Status__c!='Draft' && displayTxtLst.Size()==0){
                    sr.addError(Label.Select_Data_Catalog_Values);
                }
                
                Integer count=0;   
                List<String> politicalInt = new List<String>();                             
                for(String strAddr : displayTxtLst) 
                {
                    if(datacatMap.containsKey(strAddr))
                    {
                        Data_Catalog__c dcName = datacatMap.get(strAddr);
                        System.debug('dcName' +dcName);
                        // block Record if there are no Restricted audiences                        
                        if(sr.Status__c == 'Submitted to Audience Creation Team' && dcName.Restricted_Interest__c){  
                            count++;                             
                        } 
                        // block Record for Political Interest selection
                        if(dcName.Political__c && !sr.Is_Political_Account__c) { // SRSF-3941 : Replaced 'sr.Advertiser__r.Political_Account__c' with a Formula field (sr.Is_Political_Account__c) in this condition
                            politicalInt.add(dcName.Display_Text__c);                            
                        } 
                    }
                }  
                System.debug('politicalInt>>>>'+politicalInt);                
                if (politicalInt.Size()>0){                    
                    sr.addError(Label.Political_Interest_Can_t_be_Selected+':'+String.join(politicalInt,','));
                }
                if (count==0 && sr.Status__c == 'Submitted to Audience Creation Team'){
                    // sr.addError(Label.Select_Restricted_Audiences);
                }               
            }      
            //End : SRSF-1897            		  
  	    }
        // SRSF-439 - update sales office, region, and division
        for (Support_Request__c sr : oldSupport_Requests) {
        //  Support_Request__c oldOpp = Trigger.oldMap.get(sr.Id);
            System.Debug('$$$$$$$$ Clarka in oldSupport_Requests size '+oldSupport_Requests.size());
            System.Debug('$$$$$$$$ Clarka  '+sr);
            String SJSON = JSON.serialize(sr,false);
            System.debug('$$$$$in oldSupport_Requests $$> '+SJSON );
        }
        

        for (Support_Request__c sr : updatedSupport_Requests) {
        //  Support_Request__c oldOpp = Trigger.oldMap.get(sr.Id);
            System.Debug('$$$$$$$$ Clarka in updatedSupport_Requests size '+oldSupport_Requests.size());   
            String SJSON = JSON.serialize(sr,false);
            System.debug('$$$$$in updatedSupport_Requests $$> '+SJSON );
        }

        Set<Id> AEIds = new Set<Id>();
        
        for (Support_Request__c sr : updatedSupport_Requests) {
            AEIds.add(sr.Account_Executive__c);
        }
        Map<Id, User> userInfoMap = new Map<Id, User>([SELECT Id, Sales_Office__c, Region__c, Division__c FROM User WHERE Id IN :AEIds]);
        for (Support_Request__c sr : updatedSupport_Requests) {
            User ae = userInfoMap.get(sr.Account_Executive__c);
            if (ae != null) {
                sr.Sales_Office__c = ae.Sales_Office__c;
                sr.Region__c = ae.Region__c;
                sr.Division__c = ae.Division__c;
            }
        }
        // End of SRSF-439
        // SRSF-716
        Set<Id> opptyIdSet = new Set<Id>();
        Set<Id> agencyIdSet = new Set<Id>();
        Set<Id> advertiserIdSet = new Set<Id>();
        String profileId = userinfo.getprofileId();
        for (Support_Request__c sr : updatedSupport_Requests) {
            if(profileId != system.label.IntegrationUserProfileId){
            sr.Boomi_Error_Message__c = null;
        //  sr.Integrated_with_IMN__c = false; // Commented by Sridhar : 12-05-2020 
        //  sr.IMN_Sync_Status__c=''; // Commented by Sridhar : 12-05-2020
            }
            if (sr.Opportunity__c != null)
                opptyIdSet.add(sr.Opportunity__c);
            if (sr.Agency__c != null) 
                agencyIdSet.add(sr.Agency__c);
            if (sr.Advertiser__c != null)
                advertiserIdSet.add(sr.Advertiser__c);
        }
        
        Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>([SELECT Id, Rep_Firm__r.Name, Stagename FROM Opportunity WHERE Id IN : opptyIdSet]);
        Map<Id, Account> agencyMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN : agencyIdSet]);
        Map<Id, Account> advertiserMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN : advertiserIdSet]);
        
        
        for (Support_Request__c sr : updatedSupport_Requests) {
            if (sr.Opportunity__c != null) {
                sr.Rep_Firm_Text__c = (opptyMap.get(sr.Opportunity__c)).Rep_Firm__r.Name;
                /*//SRSF-2661
                String stagename = (opptyMap.get(sr.Opportunity__c)).Stagename;
                String recordtypename = Schema.getGlobalDescribe().get('Support_Request__c').getDescribe().getRecordTypeInfosById().get(sr.RecordTypeId).getName();
                if( !String.isBlank(recordtypename) && recordtypename== 'Planning_Request' && !String.isBlank(stagename) && stagename == 'Closed Lost'){
                    sr.Status__c = 'Abandoned Request';
                }*/
            }
            if (sr.Agency__c != null) {
                sr.Agency_Text__c = (agencyMap.get(sr.Agency__c)).Name;
            }
            if (sr.Advertiser__c != null) {
                sr.Advertiser_Text__c = (advertiserMap.get(sr.Advertiser__c)).Name;
            }
        }
        // End SRSF-726
        //Example Map usage
        //Map<ID, Contact> contacts = new Map<ID, Contact>( [select Id, FirstName, LastName, Email from Contact where Support_RequestId IN :Support_RequestMap.keySet()] );
        
        Map<String,String> mapAdvToTier = new Map<String,String>();
        Map<String,String> mapAdvAEToSAM = new Map<String,String>();
        //Added regarding Tier Designation field update SRSF-4944
        if(!advertiserIdSet.isEmpty()){
            for(Account_SAM_Mapping__c objAcc : [SELECT Id,Tier_Designation__c,User__c,Account__c,SAM_Designation__c FROM Account_SAM_Mapping__c WHERE Account__c IN :advertiserIdSet]){
                if(objAcc != null && objAcc.Tier_Designation__c != null)
                    mapAdvToTier.put(String.valueOf(objAcc.account__c), objAcc.Tier_Designation__c);

                if(System.label.SAMDesignationShutDown == 'FALSE')
                    mapAdvAEToSAM.put(String.valueOf(objAcc.account__c)+String.valueOf(objAcc.User__c), objAcc.SAM_Designation__c);

            }
            for (Support_Request__c sr : updatedSupport_Requests) {
                //Tier Designation Mapping
                if(String.isNotBlank(sr.Advertiser__c) && mapAdvToTier.containsKey(String.valueOf(sr.Advertiser__c))){
                    sr.Tier_Designation__c = mapAdvToTier.get(sr.Advertiser__c);
                }
                else{
                    sr.Tier_Designation__c = null;
                } 

                //SAM Mapping
                if((System.label.SAMDesignationShutDown == 'FALSE') && String.isNotBlank(sr.Advertiser__c) && String.isNotBlank(sr.Account_Executive__c) && mapAdvAEToSAM.containsKey(String.valueOf(sr.Advertiser__c)+String.valueOf(sr.Account_Executive__c))){
                    if(mapAdvAEToSAM.get(String.valueOf(sr.Advertiser__c)+String.valueOf(sr.Account_Executive__c)) == 'In Approval Process'){
                        sr.SAM_Designation__c = 'In Approval Process'; 
                    }
                    else{
                        sr.SAM_Designation__c = mapAdvAEToSAM.get(String.valueOf(sr.Advertiser__c)+String.valueOf(sr.Account_Executive__c));
                    }
                }
                else{
                    sr.SAM_Designation__c = null;
                }
            }
        }
        updateWorkingAndAssignedTo(oldSupport_Requests, updatedSupport_Requests, Support_RequestMap);
    }
    
    public void OnAfterUpdate(Support_Request__c[] oldSupport_Requests, Support_Request__c[] updatedSupport_Requests, Map<ID, Support_Request__c> Support_RequestMap) {
       List<Id> sIds = new List<Id>();
         //SRSF-1516
         for (Support_Request__c sr : oldSupport_Requests) {           
            if(Support_RequestMap.get(sr.Id).First_Look__c != sr.First_Look__c){
              sIds.add(sr.Id);
            }                  
        }  
        if(sIds.size()>0){
          List<Production_Service__c> PList = [SELECT Id FROM Production_Service__c WHERE Support_Request__c IN: sIds];
           if(PList.size() > 0){
             update PList;
           }
        }      
       if (updatedSupport_Requests.size() == 1) {  // this code is only needed as users update SRs.  Not needed for batch or bulk operations
            setSession(updatedSupport_Requests[0]);
        }
        
    }
    
    @future public static void OnAfterUpdateAsync(Set<ID> updatedSupport_RequestIDs) {
        //List<Support_Request__c> updatedSupport_Requests = [select Id, Name from Support_Request where Id IN :updatedSupport_RequestIDs];
    }
    
    public void OnBeforeDelete(Support_Request__c[] Support_RequestsToDelete, Map<ID, Support_Request__c> Support_RequestMap) {
        
    }
    
    public void OnAfterDelete(Support_Request__c[] deletedSupport_Requests, Map<ID, Support_Request__c> Support_RequestMap) {
        
    }
    
    @future public static void OnAfterDeleteAsync(Set<ID> deletedSupport_RequestIDs) {
        
    }
    
    public void OnUndelete(Support_Request__c[] restoredSupport_Requests) {
        
    }
    
    public boolean IsTriggerContext {
        get{ return m_isExecuting;}
    }
    
    public boolean IsVisualforcePageContext {
        get{ return !IsTriggerContext;}
    }
    
    public boolean IsWebServiceContext {
        get{ return !IsTriggerContext;}
    }
    
    public boolean IsExecuteAnonymousContext {
        get{ return !IsTriggerContext;}
    }
    
    private void setSession(Support_Request__c sr) {            
        System.debug('inside setSession>>>>>>>');
        Long rightNow = Datetime.now().getTime();
        String cacheKey = 'local.SRPartition.' + sr.Id;
        try {
            Cache.Session.put(cacheKey, rightNow, 300, Cache.Visibility.All, false);
        }
        catch(Exception ex){
            System.debug('Unable to save Cache to Session: ' + ex.getMessage());
            Log4SF.logMessage('SupportRequestTriggerHandler', 'setSession', 'Unable to save Cache to Session',ex,UserInfo.getUserId(), sr.Id);
        }
        
    }


    @future (callout=true)
    public static void sendSupportRequestToIMN (Set<ID> updatedSupportReqIDs, Boolean retryVal) {
        sendtoBoomi = new Map<Id,String>();
        System.debug('$$$In sendSupportRequestToIMN $'+sendtoBoomi); 
        List<Support_Request__c> supportReqList = [Select ID, Type_of_Request__c, Status__c, RecordTypeId, IMN_Sync_Status__c, Boomi_Error_Message__c FROM Support_Request__c WHERE ID IN: updatedSupportReqIDs];
        if(sendtoBoomi.isEmpty()) { // && ConstantVariables.recurssivevar == false
            Id prdTypeId = Schema.SObjectType.Support_Request__c.getRecordTypeInfosByName().get('Production').getRecordTypeId();
            for(Support_Request__c eachSPR : supportReqList){           
                    // SRSF-1134
                    if(eachSPR.Status__c=='Submitted to Kernel' && eachSPR.RecordTypeId == prdTypeId && eachSPR.Type_of_Request__c == 'Post Sale Production Request')  // && eachSPR.Submitted_to_Kernel_Post_Sales__c != true 
                        sendtoBoomi.put(eachSPR.Id,'Submitted_to_Kernel_Post_Sales__c');
                    // SRSF-1135  
                    if(eachSPR.Status__c=='Submitted to Kernel' && eachSPR.RecordTypeId == prdTypeId && eachSPR.Type_of_Request__c == 'Pre-contract consult') //  && eachSPR.Submitted_to_Kernel_Pre_Contract__c!= true
                        sendtoBoomi.put(eachSPR.Id,'Submitted_to_Kernel_Pre_Contract__c');      
            }

            if(sendtoBoomi.size()>0)
            { 
                List<String> supportReqfields = new List<String>();
                List<String> ProductionServicefields = new List<String>();
                List<Support_Request__c> lstSRrecs = new List<Support_Request__c>();
                 List<Logger__c> logSuccessData = new List<Logger__c>();
                
                List<Kernel_Support_Request_Fields__c> supporReq= Kernel_Support_Request_Fields__c.getall().values();
                List<Kernel_Production_Service_Fields__c> PrdService= Kernel_Production_Service_Fields__c.getall().values();
                for(Kernel_Support_Request_Fields__c eachSPR : supporReq)
                    supportReqfields.add(eachSPR.name);
                for(Kernel_Production_Service_Fields__c eachPSF : PrdService)
                    ProductionServicefields.add(eachPSF.name);
                
                //Extra Fields , if it is more than 40 charactes Custom setting won't take.
                supportReqfields.add('Creative_Agency_Contact_Email_formula__c');
                ProductionServicefields.add('Support_Request__r.Account_Executive__r.name');

                System.debug('$$support request fields$$'+supportReqfields);
                System.debug('$production service fields$$$'+ProductionServicefields);

                String soql = 'select  ' + String.join( supportReqfields, ', ') + ', ( select  '+ String.join(ProductionServicefields , ', ') +' from Production_Services__r ORDER BY CreatedDate ASC) from Support_Request__c where Id IN: updatedSupportReqIDs';
                
                System.debug('$$$In Excute method query $'+soql); 
                
                List<Support_Request__c>  supportReqRec= Database.query(soql);

                System.debug('##In Execute method Support Request####'+supportReqRec);
            //  List<Production_Service__c> allProductionSeric = new  List<Production_Service__c>();
                
               /* SRSF-2573: Moving to other method 'sendRequestToIMN'
                 String JsonString = JSON.serialize(supportReqRec); 
                System.debug('##In Execute method JsonString  ####'+JsonString ); 
                */
                if(retryVal)
                {
                   String jsonString = JSON.serialize(supportReqRec);
                   sendRequestToIMN(retryVal, jsonString, lstSRrecs, supportReqList, logSuccessData);
                }
                else
                {
                  for(Support_Request__c sr : supportReqRec)
                  {
                    List<Support_Request__c> srList = new List<Support_Request__c>();
                    srList.add(sr);
                    String jsonString = JSON.serialize(srList);
                    sendRequestToIMN(retryVal,  jsonString, lstSRrecs, supportReqList, logSuccessData);
                  }        
                }
                //END:SRSF-2573  

                // SRSF-2143 : Added below if condition
                System.debug('lstSRrecs--->'+lstSRrecs);
                if(lstSRrecs.size()>0)
                    UPDATE lstSRrecs; 
                 //SRSF-2573
                System.debug('logSuccessRecs---->'+logSuccessData);
                if(logSuccessData.size()>0)
                  INSERT logSuccessData;                      
            }
        }    
    }

    //03-22-2021 : Added below code
    private static void sendRequestToIMN(Boolean retryVal,  String request, List<Support_Request__c> lstSRrecs, List<Support_Request__c> supportReqList, List<Logger__c> logSuccessRecs)
    {
        //Getting the Web Serive Username and password from custom settings 1st web service
        String endpoint = retryVal ? 'SupportRequest_Retry' : 'SupportRequest';
        Kernel_Project__c sprCustomSett = Kernel_Project__c.getValues(endpoint);
        String sprEndPoint = sprCustomSett.End_Point__c;
        String sprUsername= sprCustomSett.User_name__c;
        String sprPassword= sprCustomSett.Password__c;
        
        System.debug('retryVal-->'+retryVal+' Endpoint :'+sprEndPoint);

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setHeader('Content-type','application/json');      
        req.setEndpoint(sprEndPoint);        
        Blob headerValue = Blob.valueOf(sprUsername+':' +sprPassword); 
        String authorizationHeader = 'Basic '  + EncodingUtil.base64Encode(headerValue);
        
        System.debug('Encoder Value'+EncodingUtil.base64Encode(headerValue)); 
        
        req.setHeader('Authorization', authorizationHeader);      
        req.setTimeout(120000);
        
        System.debug('!!In set end point!!');
        
        req.setMethod('POST');
        req.setBody(request);
        System.debug('#######'+request); 
        //req.setCompressed(true); // otherwise we hit a limit of 32000
        System.debug('!!In Webservice class req!!'+req);   
        
        try {
            if (!Test.isRunningTest()){
                res = http.send(req);
            }else{
               res = mock.respond(req);
            }
            System.debug('$$$$'+res.getbody());
            
            if (res.getStatusCode() == 200 ) // && !retryVal
            {  
                Logger__c logger = new Logger__c(
                      Class__c = 'sendSupportRequest',
                      Method__c = 'Execution Method',
                      Message__c = 'Successfully sent to Boomi at time: '+ DateTime.Now()+' with status : '+res.getStatus(),                     
                      User__c = UserInfo.getUserId(),
                      Record_Id__c = '');
                logSuccessRecs.add(logger);  
            }
            else{ 
                //SRSF-2143: Added below logic to update error fields if any error occured from boomi                  
                for(Support_Request__c sr : supportReqList){
                    sr.Boomi_Error_Message__c = 'Error while sending data to Boomi with status :'+res.getStatus() ;
                    sr.IMN_Sync_Status__c = 'Error';
                    lstSRrecs.add(sr);
                }                    
            }
        } 
        catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);                    
            //SRSF-2143: Added below logic to update error fields if any error occured from boomi                  
            for(Support_Request__c sr : supportReqList){
                sr.Boomi_Error_Message__c = 'Error while sending data to Boomi :'+e;
                sr.IMN_Sync_Status__c = 'Error';
                lstSRrecs.add(sr);
            }                    
        }
    }
    
    
    /*****
     * Updated by Clark after v6 deployment 11/9/2018 to fix bug where Assigned To and Working are alway populated on creation.
     * */
    private static void updateWorkingAndAssignedTo(Support_Request__c[] oldSupport_Requests, Support_Request__c[] updatedSupport_Requests, Map<ID, Support_Request__c> Support_RequestMap) {
        System.debug('Inside updateWorkingAndAssignedTo newSR '+updatedSupport_Requests[0]);
        User usr;
        /*
        if (updatedSupport_Requests != null && updatedSupport_Requests.size() ==1){ 
          Support_Request__c srNew = updatedSupport_Requests[0];
          Support_Request__c srOld = oldSupport_Requests==null?null:oldSupport_Requests[0];
            
          if ((srOld != null && srOld.Status__c != 'Planning in Progress') && (srNew.Status__c == 'Planning in Progress')){
              System.debug('((srOld != null && srOld.Status__c != Planning in Progress) && (srNew.Status__c == Planning in Progress))');
              srNew.Assigned_To__c = userinfo.getUserId();
              srNew.Working__c = userinfo.getName();
        } else if (srOld == null || (srOld.Assigned_To__c != srNew.Assigned_To__c)) {
                if (srNew.Assigned_To__c != null){
                    usr = [Select Name From User where Id = :srNew.Assigned_To__c];
                    srNew.Working__c = usr.Name;
                } else if (srOld == null && srNew.Assigned_To__c != null) {
                    usr = [Select Name From User where Id = :srNew.Assigned_To__c];
                    srNew.Working__c = usr.Name;
                }              
            }    
        }*/
        
        Set<String> setUId = new Set<String>();
        for( Integer i=0;i<updatedSupport_Requests.size();i++){
            if(updatedSupport_Requests[i].Assigned_To__c!=null)
                setUId.add(updatedSupport_Requests[i].Assigned_To__c);
        }
        Map<String,String> mapUser = new Map<String,String>();
        if(!setUId.isEmpty()){
            for(User obj : [SELECT Id,Name FROM User WHERE Id IN : setUId]){
                mapUser.put(obj.Id,obj.Name);
            }
        }
        for( Integer i=0;i<updatedSupport_Requests.size();i++){
            Support_Request__c srNew = updatedSupport_Requests[i];
            String rtDevName = Schema.getGlobalDescribe().get('Support_Request__c').getDescribe().getRecordTypeInfosById().get(srNew.RecordTypeId).getDeveloperName();
            System.debug('rtDevName>>>>'+rtDevName);
            Support_Request__c srOld = oldSupport_Requests==null?null:oldSupport_Requests[i];
            if ((srOld != null && srOld.Status__c != 'Planning in Progress') && (srNew.Status__c == 'Planning in Progress')){
                System.debug('((srOld != null && srOld.Status__c != Planning in Progress) && (srNew.Status__c == Planning in Progress))');
                srNew.Assigned_To__c = userinfo.getUserId();
                srNew.Working__c = userinfo.getName();
            }
            else if (srOld == null || (srOld.Assigned_To__c != srNew.Assigned_To__c)) {
                if (srNew.Assigned_To__c != null){
                    //usr = [Select Name From User where Id = :srNew.Assigned_To__c];
                    if(mapUser.containskey(srNew.Assigned_To__c))
                        srNew.Working__c = mapUser.get(srNew.Assigned_To__c);
                } else if (srOld == null && srNew.Assigned_To__c != null) {
                    //usr = [Select Name From User where Id = :srNew.Assigned_To__c];
                    if(mapUser.containskey(srNew.Assigned_To__c))
                        srNew.Working__c = mapUser.get(srNew.Assigned_To__c);
                    srNew.Working__c = usr.Name;
                }              
            } 
            // Start: SRSF-1897
            if(rtDevName=='Audience_Request' && srOld != null && srOld.Status__c != srNew.Status__c && srNew.Status__c=='Review In Progress')
            {                
                srNew.Working__c = UserInfo.getName();                                
            }
            // End: SRSF-1897
        }
    } 
}