/*
###########################################################################
# File..................: ProposalActiveInactiveController.cls
# Version...............: 1
# Created by............:  
# Created Date..........: 
# Last Modified by......: Bhuvanasankar Das 
# Last Modified Date....: 07-Aug-2018
# Description...........: This class is for scheduling the Job that runs daily for Proposal Zone Monthly Value Deactivation
# TAO Ref#..............: NA
# Change Log:               
# 1. Bhuvanasankar - Changes 
#
############################################################################*/


global without sharing class ProposalActiveInactiveController {
    
    public static List<Proposal__c> proposalList {get;set;}
    public  Map<ID,Proposal__c> proposalMap;
    Id oppId ;
    public static String pageMesg{get; set;}    
    //Update Proposal RecordTypes
    //Code changes by Aditi : 19_3_2018 : To add dynamic picklist 
    public List<SelectOption> recordTypeLst;
    public String selectedAllRecordType{get; set;}
    public String proposalRecordId{get;set;}
    public String selectedProposalId{get;set;}
    public String selectedActiveInactiveChck{get;set;}
    public Map<Id,Proposal__c> updateModifiedProposalsMap;
    public List<Proposal__c> activeProposalList;
    public List<Proposal__c> deactiveProposalList;
    public Map<String, RecordType> recordTypeMap;
    public Map<Id,ProposaldisplayWrapper> proposaldisplayWrapperMap{get;set;}
    public List<ProposaldisplayWrapper> proposaldisplayWrapperList{get;set;}
    public List<RecordType> recordTypeList{get;set;}
    public Boolean isSelectAll{get;set;}
    public Boolean isSelectAllActiveDeactive{get;set;}
    public Boolean oppRecordType;
    public Integer successCount{get;set;}
    public Integer failureCount{get;set;}
    public Integer numOfRecordsSentToAOS{get;set;}
    public Set<String> failureCountSet;
    public Map<String, Logger__c> proposalLoggerDetailsMap ;
    //SRSF-1966 
    private ShowSeekerWebServiceHelper ssHelper; 
    public List<Proposal__c> showseekerProposalList;
    public Boolean isSSUser{get;set;}
    
    //SRSF-4881
    public Map<Id,Proposal__c> advancedProposalMap;
    public List<String> allowedStatusesToDeactivateDeal;
    public List<String> deactivateDealStatusList;
    public List<String> advancedPropRecTypes;
    public Boolean isDeactivateAllowed{ get; set; }
    public String pilotProposalTitleNote{ get; set;}
    public String advancedProposalTitleNote{ get; set;}
    public Boolean hasShowseekerError{ get; set; }
    public String recTypeOppBudget { get; set; }

    //Constants
    public static final String REQUEST_SENT_TO_AOS = 'REQUEST SENT';
    public static final String REQUEST_FAILED_TO_AOS = 'FAILURE';

    public ProposalActiveInactiveController(ApexPages.StandardSetController stdSetController){
        try{
            proposalLoggerDetailsMap = new Map<String, Logger__c>();
            //Code changes by Aditi 19_3_2018
            proposalList = new List<Proposal__c>();
            failureCountSet = new Set<String>();
            proposaldisplayWrapperMap = new Map<Id,ProposaldisplayWrapper>();
            proposaldisplayWrapperList = new List<ProposaldisplayWrapper>();
            advancedProposalMap = new Map<Id,Proposal__c>();
            allowedStatusesToDeactivateDeal = new List<String>();
            deactivateDealStatusList = new List<String>();
            advancedPropRecTypes = new List<String>();
            proposalRecordId='';
            selectedProposalId='';
            selectedActiveInactiveChck ='';
            selectedAllRecordType ='';
            oppRecordType = false;
            successCount =0;
            failureCount =0;
            numOfRecordsSentToAOS = 0;
            //Code changes ends
            List<Proposal__c> proposalList_temp = (List<Proposal__c>)stdSetController.getSelected();
            recTypeOppBudget = Label.Record_Type_Opportunity_Budget;    
            advancedPropRecTypes = Label.Activate_Deactivate_Advanced_Proposal_RecordTypes.split(',');
            deactivateDealStatusList = Label.Activate_Deactivate_Deal_Status_Deactivate.split(',');
            pilotProposalTitleNote = Label.Activate_Deactivate_Pilot_Proposal_Title_Note;
            advancedProposalTitleNote = Label.Activate_Deactivate_Advanced_Proposal_Title_Note;
            System.debug('advancedPropRecTypes:' + advancedPropRecTypes);
            System.debug('deactivateDealStatusList:' + deactivateDealStatusList);
            
            //SRSF-1966: Added ShowSeeker fields in below 2 SOQL's
            if(proposalList_temp.size()<>0)
            {
                proposalMap = new Map<ID, Proposal__c>([SELECT Id, Name, Active__c, Opportunity__c, RecordType.Name, RecordType.DeveloperName, Opportunity__r.PoliticalOpportunity__c, RecordtypeId, Net_Amount__c, Opportunity__r.OwnerId, Pilot_Proposal_ID__c, Pilot_Order_Status__c, Pilot_Proposal__r.Pilot_Proposal_ID__c, AOS_Deal_Id__c, AOS_Deal_Status__c, Opportunity__r.Owner.ShowSeeker_User__c, (SELECT Id FROM PilotProposals__r WHERE RecordType.DeveloperName IN :advancedPropRecTypes AND Active__c = TRUE LIMIT 1) FROM Proposal__c WHERE Id IN :proposalList_temp]);
            }
            else{
                Id oppId_temp = ApexPages.currentPage().getParameters().get('Id');
                proposalMap = new Map<ID, Proposal__c>([SELECT Id, Name, Active__c, Opportunity__c, RecordType.Name, RecordType.DeveloperName, Opportunity__r.PoliticalOpportunity__c, RecordtypeId, Net_Amount__c, Opportunity__r.OwnerId, Pilot_Proposal_ID__c, Pilot_Order_Status__c, Pilot_Proposal__r.Pilot_Proposal_ID__c, AOS_Deal_Id__c, AOS_Deal_Status__c, Opportunity__r.Owner.ShowSeeker_User__c, (SELECT Id FROM PilotProposals__r WHERE RecordType.DeveloperName IN :advancedPropRecTypes AND Active__c = TRUE LIMIT 1) FROM Proposal__c WHERE Opportunity__c =:oppId_temp]);
            }

            // Remove Proposals from the proposalMap if it has any active Advanced Proposals (or) Activate and Deactivate not allowed
            Set<Id> propIdsToExclude = new Set<Id>();
            allowedStatusesToDeactivateDeal = Label.Activate_Deactivate_Deal_Deactivate_Allowed_Status.split(',');
            
            for(Proposal__c prop : proposalMap.values())
            {
                if(prop.PilotProposals__r != NULL && prop.PilotProposals__r.size() > 0)
                {
                    propIdsToExclude.add(prop.Id);
                }
                else if(advancedPropRecTypes.size() > 0 && advancedPropRecTypes.contains(prop.RecordType.DeveloperName))
                {
                    // Below if condition to allow only Active Advanced Proposal for Deactivate
                    if(!prop.Active__c){
                        propIdsToExclude.add(prop.Id);
                    }
                    // Below condition is SOQL Replacement of AOS_Deal_Status__c NOT IN :deactivateDealStatusList
                    else if(String.isNotBlank(prop.AOS_Deal_Status__c) && deactivateDealStatusList.size() > 0 && deactivateDealStatusList.contains(prop.AOS_Deal_Status__c)){
                        propIdsToExclude.add(prop.Id);
                    }
                    else {
                        // isDeactivateAllowed = String.isNotBlank(prop.AOS_Deal_Status__c) && allowedStatusesToDeactivateDeal.size() > 0 && allowedStatusesToDeactivateDeal.contains(prop.AOS_Deal_Status__c) ? true : false;
                        isDeactivateAllowed = String.isNotBlank(prop.AOS_Deal_Status__c) && allowedStatusesToDeactivateDeal.size() > 0 && allowedStatusesToDeactivateDeal.contains(prop.AOS_Deal_Status__c) ? true 
                                            : String.isBlank(prop.AOS_Deal_Id__c) && String.isBlank(prop.AOS_Deal_Status__c) ? true 
                                            : false;
                        if(!isDeactivateAllowed){
                            propIdsToExclude.add(prop.Id);
                        }
                    }
                }
            }
            if(propIdsToExclude.size() > 0){
                System.debug('proposalMap size before exclude:' + proposalMap.values().size());
                proposalMap.keySet().removeAll(propIdsToExclude);
                System.debug('proposalMap size after exclude:' + proposalMap.values().size());
            }
            //End of Removing Proposal from the proposalMap
            
            proposalList = proposalMap.values();
            //Start : SRSF-1966
                     
            if(proposalList.size() > 0 && proposalList.get(0).Opportunity__r.Owner.ShowSeeker_User__c){
                isSSUser = true;
            }
            else isSSUser = false;
            //End : SRSF-1966           

            oppRecordType = null != proposalList.get(0).Opportunity__r.PoliticalOpportunity__c ? proposalList.get(0).Opportunity__r.PoliticalOpportunity__c : false;
            
            String recordTypequery= 'SELECT Id, DeveloperName, Name, Description FROM RecordType WHERE SobjectType =\'Proposal__c\' AND IsActive = true ';
            
            if(oppRecordType){
                recordTypequery += ' AND (DeveloperName = \''+Label.Political_RT+'\' OR DeveloperName = \''+Label.Inventory_RT+'\' OR DeveloperName = \'Opportunity_Budget\')' ;
            }
            else{
                recordTypequery += ' AND ( DeveloperName != \''+Label.Political_RT+'\' OR DeveloperName = \'Opportunity_Budget\')' ;                
            }
            
            System.debug(' ### Recordtype query ::: '+recordTypequery);
            recordTypeList = Database.query(recordTypequery); 
            recordTypeMap = new Map<String, RecordType>();
            for(RecordType recType : recordTypeList){
                recordTypeMap.put(recType.DeveloperName,recType);
            }  
            //Code changes by Aditi _20_3_2018
            populateProposaldisplayWrapper(proposalMap);
            //Code changes ends

            System.debug(' #### proposalMap ::: '+proposalMap);

            ssHelper = new ShowSeekerWebServiceHelper(); //SRSF-1966
        }
        catch(exception ex)
        {
            System.debug(ex.getMessage());
        }
    }
    
    /*
    * This method populates wrapper and create List and map of wrapper
    *
    * @param : Map<ID, Proposal__c>
    */
    public void populateProposaldisplayWrapper(Map<ID, Proposal__c> proposalMap)
    {
        Integer activeCounts = 0;
        for(Proposal__c probObj : proposalMap.values())
        {  
            ProposaldisplayWrapper wrapObj = new ProposaldisplayWrapper();            
            wrapObj.propObj = probObj;             
            wrapObj.isActive = probObj.Active__c;            
            wrapObj.isActivechanged = false;            
            wrapObj.link = '/'+probObj.Id;             
            wrapObj.showPicklist = false;            
            wrapObj.isSelected =false;             
            wrapObj.recordtypename=probObj.RecordType.Name;
            wrapObj.recTypeDevName = probObj.RecordType.DeveloperName;
            wrapObj.selectedrecordType ='';
            wrapObj.updateStatus ='';
            wrapObj.updateStatusDetail = '';
            if(probObj.Active__c)
            {
                activeCounts++;
            }
            
            proposaldisplayWrapperList.add(wrapObj);
            proposaldisplayWrapperMap.put(probObj.Id, wrapObj);
        }
        if(proposaldisplayWrapperMap.Size() == activeCounts){
            isSelectAllActiveDeactive = true;
        }
        else{
            isSelectAllActiveDeactive =false;
        }
    }
    
    
    public PageReference GoBackToOpportunity(){
        oppId = ApexPages.currentPage().getParameters().get('Id');
        return new PageReference('/' + oppId);
    }

    
    //Code changes Aditi : 19_3_2018
    /*
    * This methods is called when edit button is clicked
    *
    */
    public PageReference fetchRecordTypeList(){        
        
        System.debug('proposalRecordId###'+proposalRecordId);
        System.debug('proposaldisplayWrapperMap###'+proposaldisplayWrapperMap);
        selectedAllRecordType = '';
        if(checkForString(proposalRecordId)){
            ProposaldisplayWrapper propWrapper = proposaldisplayWrapperMap.get(proposalRecordId);
            if(propWrapper.isSelected){
                if(!propWrapper.showPicklist){
                    propWrapper.showPicklist = true;
                }
                else{
                    propWrapper.showPicklist = false;
                }
            }
            else{
                pageMesg= Label.CURR_PROP_NOT_SELECTED;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CURR_PROP_NOT_SELECTED));
            }
            System.debug('current item ##'+propWrapper.showPicklist);
        }        
        return null;
    }
    
    /*
    * This methods is called when header checkbox selected, mark all 
    *
    */
    public void setSelectAll(){
        Integer countAllactiveheader = 0;
        Integer countOfUnselected = 0;
        if(proposaldisplayWrapperMap != null && proposaldisplayWrapperMap.size() > 0) {
            for( ProposaldisplayWrapper propWrapper : proposaldisplayWrapperMap.values() ){

                System.debug('inside setSelectAll >>>>>>>>>>>>> '+isSelectAll);

                if(isSelectAll){
                    pageMesg ='';
                    successCount =0;
                    failureCount =0;

                    if(propWrapper.propObj.RecordType.DeveloperName == recTypeOppBudget || isSSUser) { // added isSSUser check
                        System.debug('inside map>>>>>>>>>');
                        propWrapper.isSelected = true;
                        if(checkForString(selectedAllRecordType)){
                            propWrapper.recTypeDevName = propWrapper.recTypeDevName == recTypeOppBudget? propWrapper.recTypeDevName :selectedAllRecordType;
                        }
                    }
                    else{
                        propWrapper.isSelected = false;
                        countOfUnselected ++;
                    }
                }
                else{
                    propWrapper.isSelected = false;
                    propWrapper.recTypeDevName = propWrapper.propObj.RecordType.DeveloperName;
                    propWrapper.isActive = propWrapper.propObj.Active__c;
                    propWrapper.selectedrecordType =  propWrapper.propObj.RecordType.DeveloperName;
                    propWrapper.showPicklist = false; 
                    selectedAllRecordType = ''; 
                    if(!propWrapper.isActive) {
                        countAllactiveheader++;
                    }
                }
            }
            if(countAllactiveheader == proposaldisplayWrapperMap.size()){
                isSelectAllActiveDeactive = true;
            }
            else{
                isSelectAllActiveDeactive = false;
            }
            if(countOfUnselected>0){
                pageMesg = String.format(Label.ERRO_SHOW_USERCONN_UNSELECT, new String[]{String.valueOf(countOfUnselected)});
            }
        }
        else {
            pageMesg = Label.No_Proposal_Error;
        }
    }
    
    /*
    * This methods is called when single checkbox is selected 
    */
    public void singleSelection(){
        
        if(checkForString(selectedProposalId) && null != proposaldisplayWrapperMap && proposaldisplayWrapperMap.size() >0 ){
            ProposaldisplayWrapper propWrapper = proposaldisplayWrapperMap.get(selectedProposalId);
            System.debug('inside singleSelection >>>>>>'+propWrapper.isSelected);
            if(propWrapper.isSelected){
                if(propWrapper.propObj.RecordType.DeveloperName == recTypeOppBudget || isSSUser){ //added isSSUser check
                    pageMesg = '';
                    successCount =0;
                    failureCount =0;
                    if(checkForString(selectedAllRecordType)){
                        propWrapper.recTypeDevName = propWrapper.recTypeDevName == recTypeOppBudget? propWrapper.recTypeDevName :selectedAllRecordType;
                    }
                }
                else{
                    propWrapper.isSelected = false;
                    pageMesg= Label.USERCONN_MISSING;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.USERCONN_MISSING));
                }
            }
            else{
                pageMesg = '';
                propWrapper.recTypeDevName = propWrapper.propObj.RecordType.DeveloperName;
                propWrapper.isActive = propWrapper.propObj.Active__c; 
                propWrapper.selectedrecordType =  propWrapper.propObj.RecordType.DeveloperName;  
                selectedAllRecordType = '';
                if(!propWrapper.isActive){
                    isSelectAllActiveDeactive = false;
                } 
                else{
                    isSelectAllActiveDeactive = true;
                }
            }
            propWrapper.showPicklist = false;
        }
    }
    
    /*
    * This methods is called when header checkbox selected, mark all 
    *
    */
    public void setSelectActiveDeactive(){
        successCount =0;
        failureCount =0;
        List<ProposaldisplayWrapper> notselectedList = new List<ProposaldisplayWrapper>();
        for( ProposaldisplayWrapper propWrapper : proposaldisplayWrapperMap.values() ){  
            if(propWrapper.propObj.RecordType.DeveloperName == recTypeOppBudget || isSSUser){ // added isSSUser check              
                if(isSelectAllActiveDeactive){
                    propWrapper.isActive = true;
                }
                else{
                    propWrapper.isActive= false;
                }
                if(propWrapper.propObj.Active__c != propWrapper.isActive){
                    propWrapper.isActivechanged = true;
                }
                else{
                    propWrapper.isActivechanged = false;
                }
            }
            else{
                propWrapper.isActive = propWrapper.propObj.Active__c;
            }
            if(propWrapper.isSelected){
                notselectedList.add(propWrapper);
            }
        }
        if(notselectedList == null || notselectedList.size()<1 ){
            pageMesg= Label.NO_PROP_SELECTED;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.NO_PROP_SELECTED));
        }
    }
    
    /*
    * This methods populates header picklist
    * @Return : List<selectoption>
    */   
    public List<SelectOption> getheaderRecTypeLst(){        
        List<SelectOption> recordTypeList = new List<SelectOption>();
        recordTypeList.add(new SelectOption('','RECORD TYPE'));
        if(oppRecordType){
            recordTypeList.add(new SelectOption(Label.Political_RT,Label.Political_RT));
            recordTypeList.add(new SelectOption(Label.Inventory_RT,Label.Inventory_RT));
        }
        else{
            recordTypeList.add(new SelectOption(Label.Linear_RT,Label.Linear_RT));
            recordTypeList.add(new SelectOption(Label.Trade_RT,Label.Trade_RT));
            recordTypeList.add(new SelectOption(Label.Inventory_RT,Label.Inventory_RT));
        }
        return recordTypeList;
    }
    
    /*
    * This method populates per proposal item picklist
    * @Return : List<selectoption>
    */
    public List<SelectOption> getrecordTypeLst()
    {
        System.debug('proposalRecordId###---'+proposalRecordId);
        System.debug('proposaldisplayWrapperMap###---'+proposaldisplayWrapperMap);
        List<SelectOption> recordTypeList = new List<SelectOption>();
        if(checkForString(proposalRecordId) && null != proposaldisplayWrapperMap && proposaldisplayWrapperMap.size() >0){
            ProposaldisplayWrapper propWrapper = proposaldisplayWrapperMap.get(proposalRecordId);            
            
            if(null != propWrapper && propWrapper.recTypeDevName.contains(Label.Trade_RT))
            { 
                recordTypeList.add(new SelectOption(Label.Trade_RT,Label.Trade_RT));
                recordTypeList.add(new SelectOption(Label.Inventory_RT,Label.Inventory_RT));
                recordTypeList.add(new SelectOption(Label.Linear_RT,Label.Linear_RT));
            }
            else if(null != propWrapper && propWrapper.recTypeDevName.contains(Label.Inventory_RT) && !(oppRecordType) ){
                recordTypeList.add(new SelectOption(Label.Inventory_RT,Label.Inventory_RT));
                recordTypeList.add(new SelectOption(Label.Trade_RT,Label.Trade_RT));                
                recordTypeList.add(new SelectOption(Label.Linear_RT,Label.Linear_RT));
            }
            else if(null != propWrapper && propWrapper.recTypeDevName.contains(Label.Linear_RT)){
                recordTypeList.add(new SelectOption(Label.Linear_RT,Label.Linear_RT));
                recordTypeList.add(new SelectOption(Label.Trade_RT,Label.Trade_RT));
                recordTypeList.add(new SelectOption(Label.Inventory_RT,Label.Inventory_RT));
            }
            else if(null != propWrapper && propWrapper.recTypeDevName.contains(Label.Inventory_RT) && oppRecordType){
                recordTypeList.add(new SelectOption(Label.Inventory_RT,Label.Inventory_RT));
                recordTypeList.add(new SelectOption(Label.Political_RT,Label.Political_RT));
            }
            else if(null != propWrapper && propWrapper.recTypeDevName.contains(Label.Political_RT) && oppRecordType){
                recordTypeList.add(new SelectOption(Label.Political_RT,Label.Political_RT));
                recordTypeList.add(new SelectOption(Label.Inventory_RT,Label.Inventory_RT));
            }
        }
        return recordTypeList;        
    }
    
    /**
    * This methods is used to select the record types for each proposal values in the list
    * 
    */
    public void setRecordTypeName()
    {        
        successCount =0;
        failureCount =0;
        if(checkForString(proposalRecordId) && null != proposaldisplayWrapperMap && proposaldisplayWrapperMap.size() >0 ){
            ProposaldisplayWrapper propWrapper = proposaldisplayWrapperMap.get(proposalRecordId);
            if(checkForString(propWrapper.selectedrecordType)){
                propWrapper.recTypeDevName = propWrapper.selectedrecordType;
                propWrapper.showPicklist = false;
            }
        }
    }
    
    /**
    * This methods is used to set the record types for all selected 
    * 
    */
    public void setForAllRecordTypeName()
    {   
        successCount =0;
        failureCount =0;
        List<ProposaldisplayWrapper> notselectedList = new List<ProposaldisplayWrapper>();
        if(checkForString(selectedAllRecordType)){
            for(ProposaldisplayWrapper propWrapper : proposaldisplayWrapperMap.values() ){
                propWrapper.showPicklist = false;
                if(propWrapper.isSelected){
                    notselectedList.add(propWrapper);
                    propWrapper.recTypeDevName = propWrapper.recTypeDevName == recTypeOppBudget? propWrapper.recTypeDevName :selectedAllRecordType;                
                }
            }
            if(notselectedList == null || notselectedList.size()<1 ){
                pageMesg= Label.NO_PROP_SELECTED;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.NO_PROP_SELECTED));
            }
        }
    }
    
    /*
    * This method is called onchange of Active/deactive checkbox for each item
    *
    */
    
    public void checkActiveInactive(){
        successCount =0;
        failureCount =0;    
        System.debug('selectedActiveInactiveChck'+selectedActiveInactiveChck);
        if(checkForString(selectedActiveInactiveChck) && null != proposaldisplayWrapperMap && proposaldisplayWrapperMap.size() >0){
            ProposaldisplayWrapper propWrapper = proposaldisplayWrapperMap.get(selectedActiveInactiveChck);   
            if(propWrapper.propObj.RecordType.DeveloperName == recTypeOppBudget || isSSUser){  // added isSSUser check              
                if(propWrapper.propObj.Active__c != propWrapper.isActive){
                    propWrapper.isActivechanged = true;
                }
                else{
                    propWrapper.isActivechanged = false;
                }
            }else{
                propWrapper.isActive = propWrapper.propObj.Active__c;
            }
           
            if(!propWrapper.isSelected){                
                pageMesg= Label.CURR_PROP_NOT_SELECTED;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CURR_PROP_NOT_SELECTED));
            }
        }
    }
    
    /*
    * This method is used to check for null or empty string
    *
    */
    private Boolean checkForString(String valString ){
        if(null != valString && !String.isEmpty(valString)){
            return true;
        }
        else{
            return false;
        }
    } 
    
    public PageReference updateProposals()
    {
        pageMesg = '';
        successCount =0;
        failureCount =0;        
        activeProposalList = new List<Proposal__c>();
        deactiveProposalList = new List<Proposal__c>();
        showseekerProposalList = new List<Proposal__c>(); //SRSF-1966
        updateModifiedProposalsMap = new Map<id,Proposal__c>();
        Integer selcount =0;
        hasShowseekerError = false;

        System.debug('inside updateProposals >>>>>>'+proposaldisplayWrapperMap.size());
        boolean isAnyOneProposalSelected = false;
        if (proposaldisplayWrapperMap.size() > 0) {

            for(ProposaldisplayWrapper propWrapper : proposaldisplayWrapperMap.values())
            {
                if (propWrapper.isSelected) isAnyOneProposalSelected = true;
                if(propWrapper.isSelected && checkForString(selectedAllRecordType) && selectedAllRecordType != 'RECORD TYPE'){
                    propWrapper.recTypeDevName = propWrapper.recTypeDevName == recTypeOppBudget ? propWrapper.recTypeDevName :selectedAllRecordType;
                }
                
                if(propWrapper.isSelected && !propWrapper.isActivechanged &&  (propWrapper.recTypeDevName != propWrapper.propObj.RecordType.DeveloperName )){                    
                    if(recordTypeMap.containsKey(propWrapper.recTypeDevName)) {
                        propWrapper.propObj.RecordTypeId = recordTypeMap.get(propWrapper.recTypeDevName).Id; 
                    }
                    else {
                        pageMesg = Label.Record_type_not_available;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, pageMesg));
                        return null;
                    }
                    updateModifiedProposalsMap.put(propWrapper.propObj.id,propWrapper.propObj);                    
                }

                if(propWrapper.isSelected && propWrapper.isActivechanged) 
                {
                    System.debug('propWrapper.recTypeDevName:' + propWrapper.recTypeDevName);
                    System.debug('recTypeOppBudget:' + recTypeOppBudget);

                    if(recordTypeMap.containsKey(propWrapper.recTypeDevName)) {
                        propWrapper.propObj.RecordTypeId = recordTypeMap.get(propWrapper.recTypeDevName).Id; 
                    }
                    else {
                        pageMesg = Label.Record_type_not_available;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, pageMesg));
                        return null;
                    }
                    // SRSF-4881 : Updated if else condition to if condition for keeping the logic only for SS request. Removed TIM Logic
                    if(isSSUser)
                    {
                        //SRSF-3720: If Pilot user selected TIM proposals as well, then deactivate them in SF only. Added if condition to separate proposals.                       
                        if(propWrapper.propObj.Pilot_Proposal_ID__c != NULL){
                            showseekerProposalList.add(propWrapper.propObj);                       
                        }
                        else{
                            propWrapper.propObj.Active__c = false;
                        }
                    }  
                    // Changes by bhuvan on 06-Aug-2018
                    if(propWrapper.recTypeDevName == recTypeOppBudget) {
                        propWrapper.propObj.Active__c = propWrapper.isActive;
                    }
                    // Changes END

                    // SRSF-4881
                    if(advancedPropRecTypes.size() > 0 && advancedPropRecTypes.contains(propWrapper.recTypeDevName)){
                        propWrapper.propObj.Active__c = propWrapper.isActive;
                        if(String.isNotBlank(propWrapper.propObj.AOS_Deal_Id__c)){
                            if(!advancedProposalMap.containsKey(propWrapper.propObj.Id)){
                                advancedProposalMap.put(propWrapper.propObj.Id, propWrapper.propObj);
                            }
                        }
                    }
                    
                    updateModifiedProposalsMap.put(propWrapper.propObj.id,propWrapper.propObj);
                }
                propWrapper.isSelected =false;
                propWrapper.showPicklist = false;
                propWrapper.isActivechanged = false;
            }
        }
        else {
            pageMesg = Label.No_Proposal_Error;
        }        
        System.debug('activeProposalList >>>>>>>>>>>>> '+activeProposalList);
        System.debug('deactiveProposalList >>>>>>>>>>> '+deactiveProposalList);
        System.debug('showseekerProposalList >>>>>>>>> '+showseekerProposalList);
        System.debug('updateModifiedProposalsMap---> '+updateModifiedProposalsMap);
        
        isSelectAll = false;
        selectedAllRecordType =''; 

        //Start: SRSF-4881 AOS Changes
        System.debug('advancedProposalMap.values:' + advancedProposalMap.values());
        if(advancedProposalMap.size() > 0){
            Boolean isSuccess = AOSWebServiceHelper.sendReqToActivateDeactivateDeals(advancedProposalMap.values());
            // Boolean isSuccess = true;
            for(Proposal__c advProp: advancedProposalMap.values()){
                if(proposaldisplayWrapperMap.containsKey(advProp.Id)){
                    ProposaldisplayWrapper propWrapRec = proposaldisplayWrapperMap.get(advProp.Id);
                    propWrapRec.updateStatus = isSuccess ? REQUEST_SENT_TO_AOS : REQUEST_FAILED_TO_AOS;
                    proposaldisplayWrapperMap.put(propWrapRec.propObj.Id, propWrapRec); 
                }
            }

            numOfRecordsSentToAOS = isSuccess ? advancedProposalMap.size() : 0;
  
        }
        // End - AOS Changes

        //Start: SRSF-1966 : Showseeker changes
        if(showseekerProposalList != null && showseekerProposalList.size()>0) 
        {
            List<Logger__c> loggerList = new List<Logger__c>();
            Map<Id, ShowSeekerHelper.ProposalResponse> responseMap = ssHelper.activateInactiveProposals(showseekerProposalList); 
            pageMesg = ssHelper.responseMsg;                            
            if(ssHelper.hasError) 
            { 
                hasShowseekerError = true;
                System.debug('showseeker hasError responseMap:' + responseMap);

                for(Proposal__c ssProp:showseekerProposalList){
                    ProposaldisplayWrapper propWrapperRecord = proposaldisplayWrapperMap.containsKey(ssProp.Id) ? proposaldisplayWrapperMap.get(ssProp.Id) : NULL;
                    if(propWrapperRecord != NULL){
                        failureCount++;
                        populateUpdateStatus(propWrapperRecord, pageMesg);
                    }
                    if(updateModifiedProposalsMap.containsKey(ssProp.Id)){
                        updateModifiedProposalsMap.remove(ssProp.Id);
                    }
                }
            }
            else
            {
                System.debug('responseMap  >>>>>> '+responseMap);

                if(responseMap.size() > 0) 
                {
                    for(Id propId : responseMap.keySet())
                    {
                        ProposaldisplayWrapper propWrapperRecord = proposaldisplayWrapperMap.containsKey(propId) ? proposaldisplayWrapperMap.get(propId) : NULL;
                        if(responseMap.get(propId).isSuccess){
                            updateModifiedProposalsMap.get(propId).Active__c = responseMap.get(propId).isActive;
                            populateUpdateStatus(propWrapperRecord, NULL);
                        }
                        else
                        {
                            failureCountSet.add(propId);
                            String propErrorMsg = 'Could not activate/deactivate proposal :' + propId;
                            populateUpdateStatus(propWrapperRecord, propErrorMsg);
                            Logger__c logger = Log4SF.populateLog('ProposalActiveInactiveController', 'activateProp', propErrorMsg,null,'',Id.valueOf(UserInfo.getUserId()),propId,'');
                            loggerList.add(logger);
                        }                   
                    }
                    System.debug('failureCountSet -------------> '+failureCountSet);
                    System.debug('loggerList ------------------> '+loggerList);
                    System.debug('updateModifiedProposalsMap---> '+updateModifiedProposalsMap);
                    //TODO: Insert loggerlist                    
                }
                else
                {
                    for(ProposaldisplayWrapper propWrapper : proposaldisplayWrapperMap.values())
                    {
                        if(updateModifiedProposalsMap.containsKey(propWrapper.propObj.Id)) 
                        {
                            String propId = propWrapper.propObj.Id;
                            failureCountSet.add(propId);
                            String propErrorMsg = 'Could not activate/deactivate proposal :' + propId;
                            populateUpdateStatus(propWrapper, propErrorMsg);
                            Logger__c logger = Log4SF.populateLog('ProposalActiveInactiveController', 'activateProp', propErrorMsg,null,'',Id.valueOf(UserInfo.getUserId()),propId,'');
                            loggerList.add(logger);
                        }
                    }
                }               
            }
        }       
        //End: SRSF-1966 : Showseeker changes

        if(updateModifiedProposalsMap == null || updateModifiedProposalsMap.size() <= 0){
            if(hasShowseekerError){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, pageMesg));
            }
            else{
                pageMesg = isAnyOneProposalSelected ? 'No change in selected proposal records.' : Label.NOT_SELECT_UPDATE_PROP;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, pageMesg));
            }
        }
        else if(updateModifiedProposalsMap.size() >0){
            System.debug('updateModifiedProposalsMap.remove:' + advancedProposalMap.keySet());
            updateModifiedProposalsMap.keySet().removeAll(advancedProposalMap.keySet());
            pageMesg = dmlUpdateProp(updateModifiedProposalsMap);
        }
        
        pageMesg = pageMesg.removeEnd(',');
        
        return null;
    }
    
    //Code changes ends

    /*Function to switch Record Type for selected Proposals based on User Inputs*/
    public String dmlUpdateProp(Map<Id,Proposal__c > updatePropMap)
    {
        System.debug(' ### updatePropMap ::: ' +updatePropMap);
        System.debug(' ### failureCountSet ::: ' +failureCountSet);
        try{
            List<Proposal__c> newupdateProposalList = new List<Proposal__c>();
            for(String failedPropId : failureCountSet){
                if(updatePropMap.containsKey(failedPropId))
                {
                    updatePropMap.remove(failedPropId);
                    failureCount++;
                    if(proposaldisplayWrapperMap.get(failedPropId).recTypeDevName == proposaldisplayWrapperMap.get(failedPropId).propObj.RecordType.DeveloperName)
                    {
                        updatePropMap.remove(failedPropId);
                    }
                }
            }
            System.debug(' ### after removing values in updatePropMap - SIZE ::: ' +updatePropMap.size());
            if(updatePropMap.size() > 0){
                newupdateProposalList.addAll(updatePropMap.values());
                Database.SaveResult[] results = Database.update(newupdateProposalList, false);
                List<Logger__c> loggerList = new List<Logger__c>();
                for(Integer i = 0; i<results.size() ; i++){
                    Proposal__c propRecord = newupdateProposalList.get(i);
                    ProposaldisplayWrapper propWrapperRecord = proposaldisplayWrapperMap.containsKey(propRecord.Id) ? proposaldisplayWrapperMap.get(propRecord.Id) : NULL;
                    if(results[i].isSuccess()){
                        successCount++;
                        populateUpdateStatus(propWrapperRecord, NULL); 
                    }
                    else
                    {
                        failureCount++;
                         
                        Logger__c logger = Log4SF.populateLog('ProposalActiveInactiveController', 'dmlUpdateProp', System.Label.TIM_ACTIVE_DEACTIVE_ERROR,null,'',Id.valueOf(UserInfo.getUserId()),String.valueOf(results[i].Id),'');
                        loggerList.add(logger);
                        populateUpdateStatus(propWrapperRecord, System.Label.TIM_ACTIVE_DEACTIVE_ERROR);
                    }
                }
                // Changes by bhuvan on 28-June-2018 START
                INSERT loggerList;
                proposalLoggerDetailsMap.clear();
                for(Logger__c log : loggerList) {
                    proposalLoggerDetailsMap.put(log.Record_Id__c, log);
                }
                populateUpdateStatusWithErrorDetails(proposalLoggerDetailsMap, proposaldisplayWrapperMap);
                // Changes by bhuvan END
            }

            System.debug('dmlUpdateProp successCount:' + successCount);
            System.debug('dmlUpdateProp numOfRecordsSentToAOS:' + numOfRecordsSentToAOS);
            
            if(successCount == 0 && failureCount == 0 && numOfRecordsSentToAOS > 0){
                successCount = numOfRecordsSentToAOS;
                return String.format(Label.PROPOSAL_RECORDTYPE_MESG, new String[]{String.valueOf(0),String.valueOf(numOfRecordsSentToAOS), String.valueOf(failureCount)});
            }

            return String.format(Label.PROPOSAL_RECORDTYPE_MESG, new String[]{String.valueOf(successCount),String.valueOf(numOfRecordsSentToAOS), String.valueOf(failureCount)});
        }
        catch(Exception ex)
        {
            return 'Error ' + ex.getMessage();
        }

    }

    public void populateUpdateStatus(ProposaldisplayWrapper propWrapRec, String errorMessage) {
        if (NULL != propWrapRec) {
            if (String.isBlank(errorMessage)) {
                propWrapRec.updateStatus = 'SUCCESS';
                propWrapRec.updateStatusDetail = 'SUCCESSFULLY UPDATED';
            }
            else {
                propWrapRec.updateStatus = 'FAILURE';
                propWrapRec.updateStatusDetail = errorMessage;   
            }
            proposaldisplayWrapperMap.put(propWrapRec.propObj.Id, propWrapRec);
        }
    }

    public void populateUpdateStatusWithErrorDetails(Map<String, Logger__c> loggerMap , Map<id,ProposaldisplayWrapper> propWrapperMap) {
        
        for(String str : propWrapperMap.keySet()) {
            if(loggerMap != null && loggerMap.containsKey(str)) {
                propWrapperMap.get(str).errorDetails = loggerMap.get(str);
            }
        }
    }

    //Code changes by Aditi : 20_3_2018
    public class ProposaldisplayWrapper{
        public Proposal__c propObj {get;set;}
        public Boolean isActivechanged {get;set;}
        public Boolean isActive{get;set;}
        public String recordtypename {get;set;}
        public String recTypeDevName {get;set;}
        public String selectedrecordType{get;set;}
        public String link {get;set;}
        public Boolean showPicklist{get;set;}
        public Boolean isSelected{get;set;}
        public String updateStatus {get;set;}
        public String updateStatusDetail {get;set;}
        public Logger__c errorDetails {get; set;}
    }
}