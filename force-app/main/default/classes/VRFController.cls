/*
###########################################################################
# File..................: VRFController.cls
# Version...............: 
# Created by............: Jose Calicdan
# Created Date..........: 7-Apirl-2019
# Last Modified by......:  
# Last Modified Date....: 
# Description...........: VRFController for the Order Managment Lighthing Aura Component
# TAO Ref#..............: 
# Change Log:               
#
#
############################################################################*/
public without sharing class VRFController {
    
    public static Boolean ThrowException {get; set;}
    public static VRFClass vrfClass                       = new VRFClass();
    private static string DIGITAL_CREATIVE_NAME           = 'Digital_Creative__c';
    private static string DIGITAL_CREATIVE_VRF_FIELD_NAME = 'VRF_Client_Id__c';
    // private static Boolean VAST_TAG_ENABLED = 'Vast_Tag_Enabled__c';
    
    @AuraEnabled
    public static String getVRFComponents(string creativeId){
        
        Boolean isValidProfile; 
        Digital_Creative__c dcc = null;
        String recordTypeName; 
        Boolean isValidRecordType;
        Boolean isOrderPrefix99;

        try {

                if(Test.isRunningTest()){
                    if (ThrowException == true){
                     throw new AuraHandledException('Aura Exception Test');
                    }
                }
                
               vrfClass.hasValidationError = false;
               vrfClass.ValidationMessage  = '';
               VRFClass.vrfToastErrorMessage = '';
            
               Log('Creative id: ' + creativeId);
                List<string> recordTypeSettings = GetRecordTypeCustomSettings();
        
                isValidProfile        = isProfileNameValid();
                dcc                   = GetDigitalCreativeByID(creativeId);
                recordTypeName        = GetRecordTypeNameById(dcc.Digital_Campaign__r.RecordTypeId);
                System.debug('recordTypeName@@' +recordTypeName);
                
                Boolean OkForSubmissionForOnline = false;
                Log('isValidProfile ' + isValidProfile + ' ddc.VRF_Client_Id__c ' + dcc.VRF_Client_Id__c);

                List<Map<String, String>> trafficElement = GetTrafficIdOptionsbyAccountId(dcc);

                Boolean OkForSubmission = VRFUtility.isOKForSubmission(dcc.Status__c); 
            
                if(OkForSubmission==false && recordTypeName.contains('New Ads Everywhere')){
                    VRFClass.vrfToastErrorMessage = 'Digital Creative Status must be 2.1 Submitted to Digital Traffic in order to submit a VRF.';
                }
            
                if(dcc.VAST_Tag__c == 'No' ){
                    if(recordTypeName.contains('Pre-roll') || recordTypeName.contains('Addressable Video')){
                        if(dcc.status__c != '02 Submitted to Digital Ops'){
                            VRFClass.vrfToastErrorMessage = 'Digital Creative Status must be 02 Submitted to Digital Ops in order to submit a VRF.';
                            OkForSubmissionForOnline = false;
                        }else{
                            OkForSubmissionForOnline = true;
                        }
                    }else if(recordTypeName.contains('Display')){
                        VRFClass.vrfToastErrorMessage = 'The DCC cannot be trafficked through the VRF its a Display campaign. Please traffic manually.';
                        OkForSubmissionForOnline = false;
                    }
                }
                
                if(dcc.VAST_Tag__c == 'Yes'){
                    if(recordTypeName.contains('Pre-roll') || recordTypeName.contains('Addressable Video') || (recordTypeName.contains('New Ads Everywhere') && !OkForSubmission) ){
                        if(dcc.status__c != '02 Submitted to Digital Ops' && dcc.status__c != '48 Date Revision Submitted to Digital Ops'){
                            VRFClass.vrfToastErrorMessage = 'Digital Creative Status must be 02 Submitted to Digital Ops OR 48 Date Revision Submitted to Digital Ops in order to submit a VRF.';
                            OkForSubmissionForOnline = false;
                            
                        }else{
                            OkForSubmissionForOnline = true;
                        }
                    }else if(recordTypeName.contains('Display')){
                        VRFClass.vrfToastErrorMessage = 'The DCC cannot be trafficked through the VRF its a Display campaign. Please traffic manually.';
                        OkForSubmissionForOnline = false;
                    }
                }
                
                vrfClass.VrfClientId         = dcc.VRF_Client_Id__c;
                vrfClass.isOrderPrefix99     = VRFCallOuts.isOrderPrefix99(dcc) && OkForSubmission;
                vrfClass.isSubmitValid       = (OkForSubmission || OkForSubmissionForOnline)  && (dcc.VRF_Client_Id__c == null) && !vrfClass.isOrderPrefix99 ; 
                if(OkForSubmission == false && OkForSubmissionForOnline == false){
                    vrfClass.invalidStatus = true;
                }
                vrfClass.isVrfVisible        = (isValidProfile && (dcc.VRF_Client_Id__c == null) && !vrfClass.isOrderPrefix99);
                vrfClass.TrafficElements     = trafficElement;
                vrfClass.VrfClientIdHelpMsg  = GetVRFClientIdHelpMessage();
                vrfClass.SpotId              = (dcc.VRF_Spot_ID__c != null || dcc.VRF_Spot_ID__c == '') ? dcc.VRF_Spot_ID__c :  dcc.Spot_ID_if_needed__c; 
                vrfClass.isVRFMessageVisble  = (dcc.VRF_Client_Id__c != '' || dcc.VRF_Client_Id__c != null) && OkForSubmission &&  !vrfClass.isOrderPrefix99;
  
                System.debug('vrfClass.invalidStatus' +vrfClass.invalidStatus);
                System.debug('vrfClass.vrfToastErrorMessage' +vrfClass.vrfToastErrorMessage);
                  Log('vrfClass.isVrfVisible ' + vrfClass.isVrfVisible + 
                      ' | VrfClientId ' + vrfClass.VrfClientId  + 
                      ' | SpotId ' +  vrfClass.SpotId  + 
                      ' | vrfClass.hasValidationError ' + vrfClass.hasValidationError +
                      ' | vrfClass.isSubmitValid ' + vrfClass.isSubmitValid );

                if (vrfClass.isOrderPrefix99){
                    String message = 'Order Prefix for DCC ' + dcc.Id  + ' not found for Divison: ' + dcc.Division__c   + ', Region:  ' +  dcc.Region__c +  ' Sales Office: ' +  dcc.Sales_Office__c;
                    VRFCallOuts.SendEmailMessageToAdmins('Order Prefix Issue', message);
                }else{
                    VRFUtility.RemoveErrorMessage(creativeId);
                }
    
        } catch (Exception ex) {
            Log('Error ' + ex.getMessage()+ '::'+ex.getLineNumber()); 
        }

        return JSON.serialize(vrfClass);
    }

    @AuraEnabled
    public static String saveVRFData(string creativeId, string vrfClientId, string spotId){

        string message; 
        VRFResponseClass vrfResponseClass = new VRFResponseClass();
       try 
        {
            if(Test.isRunningTest()){
                if (ThrowException == true){
                    throw new AurahandledException('Aura Exception Test');
                }
            }

            VRFCallOuts vfrCallOut = new VRFCallOuts();
            vrfResponseClass = vfrCallOut.ProcessVRFData(creativeId, vrfClientId, spotId);

           if (!vrfResponseClass.isSuccessfull){
              Log('VRF Submission is not Successful' + vrfResponseClass.Message);
              VRFUtility.SetErrorMessage(creativeId, 'VRF submission issue');
           }
           else{
               VRFUtility.RemoveErrorMessage(creativeId);
           }

        } catch (Exception ex) {
            Log(ex.getMessage()); 

            vrfResponseClass.isSuccessfull = false;
            vrfResponseClass.Message       = ex.getMessage();

            return JSON.serialize(vrfResponseClass);
        }

          return JSON.serialize(vrfResponseClass);
    } 

    @AuraEnabled
    public static String getOrderPrefixUrl(){

        String orderPrefixUrl;

        List<VRF_Settings__c> settings =  [SELECT Value__c  FROM VRF_Settings__c 
                                     WHERE Category__c =: 'orderPrefix_endpoint' 
                                     LIMIT 1];

        if (settings.size() > 0){
            orderPrefixUrl = settings[0].Value__c;
        }

        Log('getOrderPrefixUrl url : ' + orderPrefixUrl);

        return orderPrefixUrl;
    }

    @AuraEnabled
    public static void SendErrorMessage(string creativeId, string spotId, string vrfClientId, string message){
        
        Log('Error Message ' + message);

        String json = VRFCallOuts.CreateJson(creativeId, spotId, vrfClientId, true); 
        VRFCallOuts.SendEmailMessageToAdmins('Error sending creative id  ' + creativeId,   message + ' \n\n' + json);
    }
    
    @AuraEnabled
    public static void UpdateStatus(string creativeId){

        VRFCallOuts vfrCallOut = new VRFCallOuts();

        string succesStatus = VRFUtility.GetVRFSubmmittedStatus();
        string json         = vfrCallOut.CreateStatusJson(succesStatus, null);
        Log('VRF Submission is successful set status to ' + succesStatus);
        VRFUtility.PostUpdateStatus(creativeId,  json);
    }

    @TestVisible
    private static List<string> GetRecordTypeCustomSettings(){

        List<string> RecordTypeList        = new List<string>();
        //List<VRF_Record_Types__c> listName = [SELECT name FROM  VRF_Record_Types__c];
        List<VRF_Record_Types__c> listName = VRF_Record_Types__c.getall().values();

        for (VRF_Record_Types__c s : listName){
            Log('VRF_Record_Types__c : ' +  s.Name);
            RecordTypeList.add(s.Name);
        }

        return RecordTypeList;
    }

    @TestVisible
    private static Boolean isProfileNameValid(){

          Log('Start isProfileNameValid Method '); 


          id id1 = userinfo.getProfileId();

          Log('Profile id  ' +  id1); 

          Profile profile = [SELECT Name FROM Profile where Id =: id1 LIMIT 1];
          Log('User Profile : ' +  profile.Name);   

         VRF_Settings__c[] vrfProfiles =  [SELECT Value__c  FROM VRF_Settings__c 
                                            WHERE Category__c =: 'vrf_profile'
                                            AND Value__c =: profile.Name]; 

         return (vrfProfiles.size() > 0);
    }

    @TestVisible
    private static Digital_Creative__c GetDigitalCreativeByID(string creativeId){

        Digital_Creative__c ddc = [SELECT  
                                   Digital_Campaign__r.Name, 
                                   Digital_Campaign__r.RecordTypeId,
                                   Digital_Campaign__r.Opportunity__r.Account.Id,
                                   Digital_Campaign__r.Opportunity__r.Account.Name,
                                   Digital_Campaign__r.Opportunity__c,
                                   TIM_ID_Form__c,
                                   VRF_Client_Id__c,
                                   Spot_ID_if_needed__c,
                                   Status__c,
                                   Sales_Office__c,
                                   Region__c,
                                   Division__c,
                                   VRF_Spot_ID__c,
                                   HD_AssetId__c,
                                   SD_AssetId__c,
                                   CreativeUrl__c,
                                   VAST_Tag__c
                                   FROM Digital_Creative__c 
                                   WHERE id=: creativeId LIMIT 1];

        Log('Digital Campaign Name : ' + ddc.Digital_Campaign__r.Name);
        Log('Digital Campaign RecordTypeId : ' + ddc.Digital_Campaign__r.RecordTypeId);
        Log('Digital Campaign AccountId : ' + ddc.Digital_Campaign__r.Opportunity__r.Account.Id);
        Log('Digital Campaign OpportunityId : ' + ddc.Digital_Campaign__r.Opportunity__c);
        Log('Digital Creative VRF_Client_Id__c : ' + ddc.VRF_Client_Id__c);
        Log('Digital Creative VAST_Tag__c : ' + ddc.VAST_Tag__c);
        Log('Digital Creative Spot ID if Need : ' + ddc.Spot_ID_if_needed__c);
        Log('Digital Creative HD Asset ID : ' + ddc.HD_AssetId__c);
        Log('Digital Creative SD Asset ID : ' + ddc.SD_AssetId__c);
        Log('Digital Creative CreativeUrl : ' + ddc.CreativeUrl__c);

        return ddc;  
    }

    @TestVisible
    private static string GetRecordTypeNameById(string recordTypeId){

      RecordType recordType = [SELECT
                                Name
                                FROM RecordType
                                WHERE id=:recordTypeId ];

       Log('RecordTypeName: ' + recordType.Name);

       return recordType.Name;
    }

    @TestVisible
    private static string GetVRFClientIdHelpMessage(){

        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType dcc = schemaMap.get(DIGITAL_CREATIVE_NAME);
        Map<String, Schema.SObjectField> fieldMap = dcc.getDescribe().fields.getMap();
        string helptext = fieldMap.get(DIGITAL_CREATIVE_VRF_FIELD_NAME).getDescribe().getInlineHelpText();
        System.debug(helptext);
        
        return helptext;
    }
  
    public static List<Map<String, String>> GetTrafficIdOptionsbyAccountId(Digital_Creative__c dcc){

        List<Map<String, String>> options = new List<Map<String, String>>();   
        options.add(new Map<String, String>{'value' => '', 'label' => 'Select VRF Client Id'});

        List<string> vrfList = GenerateVrfIds(dcc);

        for(string vrfID :vrfList){

            options.add(new Map<String, String>{'value' => vrfID, 
                                                'label' => vrfID });

        }

        return options;
    }
    
    public static List<string> GenerateVrfIds(Digital_Creative__c dcc){
    


        List<string>  vrfList = new List<string>();
        Traffic_Id_Element__c[] trafficElement = [SELECT 
                                                  Account__r.Name, 
                                                  Account_TIM_ID__C, 
                                                  Traffic_Id__c,
                                                  Name,
                                                  TIM_System__c, 
                                                  ExportSystem_Name__c 
                                                  FROM Traffic_Id_Element__c
                                                  WHERE  Traffic_Type__c = 'Account' 
                                                  AND Account__c =: dcc.Digital_Campaign__r.Opportunity__r.Account.Id];

        List<Proposal_Zone__c> proposalZones =  [SELECT Sys_Code__c 
                                                 FROM Proposal_Zone__c 
                                                 WHERE Proposal__r.Opportunity__c =: dcc.Digital_Campaign__r.Opportunity__c
                                                 LIMIT 1];

         string sysCode = '';

        if (proposalZones.size() > 0){   
             sysCode = proposalZones[0].Sys_Code__c + ' ';        
        }
     
        System.debug('SysCode is ' + sysCode);

       List<VRF_SalesOffice__c> salesOffice = [SELECT Eclipse_System__c FROM VRF_SalesOffice__c
                                                WHERE Division__c =: dcc.Division__c
                                                AND Region__c =: dcc.Region__c
                                                AND Sales_Office__c =: dcc.Sales_Office__c ];

        string eclipseSystem = '';

        if (salesOffice.size() > 0){
            eclipseSystem = salesOffice[0].Eclipse_System__c;
        }


        for(Traffic_Id_Element__c traffic : trafficElement){

           string VrfID = dcc.Digital_Campaign__r.Opportunity__r.Account.Name
                            + ' - ' + sysCode       
                            + ' - ' + traffic.Traffic_Id__c  
                            + ' - ' + traffic.ExportSystem_Name__c  
                            + ' - ' + dcc.TIM_ID_Form__c  
                            + ' - ' + traffic.Account_TIM_ID__c
                            + ' - ' + eclipseSystem;  

            vrfList.add(VrfID);
        }

    
        return vrfList;
    } 
  
    @TestVisible
    public static void Log(string log){
        System.Debug(log);
    }

    @AuraEnabled(cacheable=false)
    public static Digital_Creative__c getDigitalCreativeRecord(String recordId ){
        try {
            return [SELECT Id, Vast_Tag_Enabled__c FROM Digital_Creative__c WHERE ID =:recordId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}