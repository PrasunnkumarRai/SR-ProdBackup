/*
###########################################################################
# File..................: ProposalTIMCreateController.cls
# Version...............: 1
# Created by............: Sanchit Singhal   
# Created Date..........: 10-April-2017
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This class contains controller methods for ProposalTIMCreate visualforce page
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/
public without sharing class ProposalTIMCreateController {
    
    /*Opportunity objects*/
    public Opportunity opp {get;set;}
    private List<UserConnection__c> oppAE;
    
    /*Web service Helper class object.*/
    private BoomiWebServiceHelper boomiHelper; 
    
    /*stores the string value for back button.*/
    public String goBackString {get; set;} 
    
    /*Account map of Advertise,Agency and Rep firm on Opportunity.*/
    public Map<Id,Account> acctMap; 
    
    /*This is to get the old proposal count when user Comes on this page.*/
    public List<Proposal__c> oldProposal ; 
    
    /* User Name for connecting to Tim UI page.*/
    private String userName; 
    
    /* User passwd for connecting to Tim UI page.*/    
    private String passwd; 
    
    /* Tim server for connecting to Tim UI page.*/
    private String timServer;
    
    /* Tim System for connecting to Tim UI page.*/
    private String timSystem;
         
    /* Custom Setting map.*/
    Map<String,TIMIntegration__c> custSettMap = new Map<String,TIMIntegration__c>(); 
    
    /* to make sure if able to Authenticate to TIM system.*/
    public Boolean isAuthenticated {get;set;}
    
    /* Estimate Id from TIM*/
    public String estimateId{get;set;}
    
    /* Page messages*/
    public String pageMsg{get;set;}
    
    /* Redirection if cache is empty*/
    //public Boolean isRedirect{get;set;}
    //Code changes to create inventory record type : Aditi 2/26/2018
    public String specialRecordType{get;set;}
    //Code changes ends
    
    public List<UserConnection__c> loggedInUser;
    public UserConnection__c currentUser;
    
    public Boolean isDeleteOppBudgt{get;set;} // Code Added for SRSF-1304
    public List<Proposal__c> propToDelete{get;set;} // Code Added for SRSF-1304
    // Code Added for SRSF-1762
    public String createAccInTIM = 'false';
    public Boolean isConfirm {get;set;}
    //public Boolean fromConstructor {get;set;}
    // Code Ended for SRSF-1762

    public ProposalTIMCreateController(){

    }
    /* Constructor for the controller class. */ 
    public ProposalTIMCreateController(ApexPages.StandardSetController controller){
        pageMsg = '';
        isDeleteOppBudgt = FALSE; // Code Added for SRSF-1304
        propToDelete = new List<Proposal__c>(); // Code Added for SRSF-1304

        //Code changes to create inventory record type : Aditi 2/26/2018
        specialRecordType = null != ApexPages.currentPage().getParameters().get('recType')?ApexPages.currentPage().getParameters().get('recType'):null;
        //Code changes ends
        System.debug(' specialRecordType ::: ' +specialRecordType);

         // Code Added for SRSF-1762
        isConfirm = null != ApexPages.currentPage().getParameters().get('isConfirm')?Boolean.valueOf(ApexPages.currentPage().getParameters().get('isConfirm')):false;
       // System.debug('isConfirm ::: ' +isConfirm);      
       // fromConstructor = null != ApexPages.currentPage().getParameters().get('fromConstructor')?Boolean.valueOf(ApexPages.currentPage().getParameters().get('fromConstructor')):false;
        //System.debug('fromConstructor ::: ' +fromConstructor);  
        //System.debug('TIM Opp Id  ::: ' +ApexPages.currentPage().getParameters().get('Id'));    
        // Code Ended for SRSF-1762

        opp = [SELECT id,Agency_Account__c,Rep_Firm__c,AccountId,OwnerId,RecordType.Name,account.agency__c,name,owner.name, owner.Profile.Name,account.account_tim_name__c,AE_ID__c, PoliticalOpportunity__c,(select id from Proposals__r where RecordTypeId =: label.Opportunity_Budget_RecordTypeId) FROM Opportunity WHERE id=:ApexPages.currentPage().getParameters().get('Id')];
        // Changes done by bhuvan on July-07-2018
        if(String.isBlank(specialRecordType)) {
            if(opp.PoliticalOpportunity__c) {
                specialRecordType = '_PR';
            }
            else {
                specialRecordType = '_LR';    
            }
        }
        // Changes end by bhuvan

        //Code Added for SRSF- 1304
          if(NULL!=opp && opp.Proposals__r.size()>0) propToDelete.addAll(opp.Proposals__r);
        //Code Ends here

        System.debug(' $$$ specialRecordType ::: ' +specialRecordType);
        goBackString = 'Back to Opportunity';
        List<String> parameters = new List<String>();
        try
        {
            UserConnection__c uc = new UserConnection__c();
            
            String label = System.Label.TIMCreate_Multiple_UserConError;

            /*Get the Opp AE User Connections*/
            oppAE = [Select AE_Id__c, TIM_System__c, Username__c,user__r.name
                    from UserConnection__c
                    where User__c=:opp.ownerId and AE_Id__c != null and Is_Primary__c = true];
            if(oppAE.size() > 1)
            {
                parameters.add(opp.owner.name);
                pageMsg = String.format(label, parameters);
                isAuthenticated = false;
                return;
            }       
            else if(oppAE.size() == 0)
            {
                pageMsg = string.format(System.Label.TIMCreate_No_UserCon_Error,parameters);
                isAuthenticated = false;
                return;
            } 
            /*Get the Logged In User Connections*/        
            loggedInUser = [Select AE_Id__c, TIM_System__c, Username__c,user__r.name
                            from UserConnection__c
                            where User__c=: userInfo.getUserId()  AND Tim_System__c =: oppAE[0].Tim_System__c];
            System.debug('@@loggedInUser:'+loggedInUser.size());
            if(loggedInUser.size() > 1)
             {
                parameters.clear();
                parameters.add(userInfo.getName());
                pageMsg = String.format(label, parameters);
                isAuthenticated = false;
                return;
             }                  
            else if(loggedInUser.size() == 0)
            {
                parameters.add(userInfo.getName());
                parameters.add(oppAE[0].Tim_System__c);
                pageMsg = string.format(System.Label.No_User_Connection_for_Tim_System,parameters); 
                isAuthenticated = false;
                return;
            }
            else
            {
                currentUser = loggedInUser[0];
            } 
            if(String.isBlank(currentUser.Username__c)){
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, string.format(System.Label.TIMCreate_UserCon_Details_Error,parameters)));
               pageMsg = string.format(System.Label.TIMCreate_UserCon_Details_Error,parameters); 
                isAuthenticated = false;
                return;            
            }
            else{
                userName = currentUser.username__c;            
                isAuthenticated = true;
            }
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, string.format(System.Label.TIMCreate_No_UserCon_Error,parameters)));
            pageMsg = string.format(System.Label.TIMCreate_No_UserCon_Error,parameters); 
            isAuthenticated = false;
            return;
        }
        
        boomiHelper = new BoomiWebServiceHelper();
        
        /*Values from Custom setting objects.*/
        custSettMap = TIMIntegration__c.getAll();
        userName = custSettMap.get(currentUser.TIM_System__c).UserName__c;
        passwd = custSettMap.get(currentUser.TIM_System__c).Password__c;
        timServer = custSettMap.get(currentUser.TIM_System__c).TIMServer__c;
        timSystem = currentUser.TIM_System__c;
        oldProposal = [select id,TIM_Id__c, Active__c, Opportunity__c
                       from Proposal__c 
                       where Opportunity__c = : opp.Id AND RecordType.Name != 'Opportunity Budget'
                       order by LastModifiedDate desc];
                  
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=EmulateIE8');
        
    }
    
    /**
     * This methods gets called on from action method of VF page. It verifies that Authentication to TIM system is possible and 
     * Verifies TIM id in Agency, Advertiser and rep Firm accounts. If it is not there, it creates the accounts in TIM 
     * and updates the id in salesforce.
     * 
     * @return (void) (NA)
    */
    public Map<String,String> resMap;    
    public PageReference execute(){
        if(isAuthenticated){

            try{
                System.debug(CacheManager.checkCacheSize(timSystem));
                if(CacheManager.checkCacheSize(timSystem) <=0){ 
                    System.debug(CacheManager.checkCacheSize(timSystem));   
                    if(Label.CacheAutoRefresh=='true'){
                        CacheManager.refreshTIMCache(timSystem);
                    }
                    Log4SF.logMessage('ProposalTIMCreateController', 'createProposal', 'Refreshed All Cache' , UserInfo.getUserId(), opp.Id);
                  //  return new PageReference('/apex/Proposal_Cache_Error?timSystem='+timSystem+'&retURL=/apex/ConfirmToSaveAccountsInTim?Id='+opp.Id + '&oppId=' + opp.Id);
                    PageReference pg = new PageReference('/apex/Proposal_Cache_Error?timSystem='+timSystem+'&oppID='+opp.Id);
                    String returlstr = '/apex/ConfirmToSaveAccountsInTim?OppId='+opp.Id+'&recType='+specialRecordType+'&isCTP=true';
                    pg.getParameters().put('retURL', returlstr);
                    return pg;
                }
                 
            }
            catch(Exception ex){
                System.debug('refreshCache Callout error: '+ ex);
            }

            Set<Id> accIds = new Set<Id>();
            if(opp.Agency_Account__c!= null) accIds.add(opp.Agency_Account__c);
            if(opp.Rep_Firm__c != null) accIds.add(opp.Rep_Firm__c);
            if(opp.AccountId != null) accIds.add(opp.AccountId);
            System.debug(accIds);
            acctMap = new Map<Id,Account>([select Name,BillingState,BillingCity,BillingStreet,Phone,BillingPostalCode,
                                                  ShippingState,ShippingCity,ShippingStreet,ShippingPostalCode,agency__c,account_tim_name__c
                                           from Account where id in : accIds]);
            try{
                if(acctMap.keySet().size() > 0){
                    boomiHelper.confirmCreateAcc = isConfirm; // SRSF-1762
                    resMap = boomiHelper.verifyAccountTimIds(opp,acctMap,oppAE[0]);
                    //Boolean result = boomiHelper.verifyAccountTimIdsSample(opp,acctMap,oppAE[0]);
                    System.debug(resMap);
                    //SRSF-1762 Code starts here
                    if(Boolean.valueOf(System.Label.Show_confirmation_msg_for_new_account_creation_in_TIM))
                        createAccInTIM = createAccInTIM = resMap.get('createAccInTIM'); 
                    //SRSF-1762 Code Ends here
                    //System.debug('CTP resMap--->'+ createAccInTIM); // SRSF-1762
                    
                    if(resMap.keySet().size() > 0){
                        //TODO: Check all array values and throw even if one error found
                        for(String res:resMap.values())
                        {
                            if(res == 'Error'){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, res));
                                pageMsg = res;
                                isAuthenticated = false;
                                Log4SF.logMessage('ProposalTIMCreateController', 'Execute', System.Label.TIMCreate_Account_Sync_Error+res, UserInfo.getUserId(),opp.Id);
                            }
                        }   
                    }
                }
            }
            catch(Exception ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.TIMCreate_Account_Sync_Error + 'Error: '
                                                                                     + ex.getMessage()));
                pageMsg = System.Label.TIMCreate_Account_Sync_Error +'Error: ' + ex.getMessage();
                Log4SF.logMessage('ProposalTIMCreateController', 'Execute', System.Label.TIMCreate_Account_Sync_Error, ex, UserInfo.getUserId(),opp.Id);
            }           
           
        }

       /* SRSF-2043 : Moving this code to above 
        try{
                System.debug(CacheManager.checkCacheSize(timSystem));
                if(CacheManager.checkCacheSize(timSystem) <=0){ // SRSF -1762 added fromConstructor condition
                    System.debug(CacheManager.checkCacheSize(timSystem));   
                    if(Label.CacheAutoRefresh=='true'){
                        CacheManager.refreshTIMCache(timSystem);
                    }
                    Log4SF.logMessage('ProposalTIMCreateController', 'createProposal', 'Refreshed All Cache' , UserInfo.getUserId(), opp.Id);
                    return  new PageReference('/apex/Proposal_Cache_Error?timSystem='+timSystem+'&retURL=/apex/ProposalTIMCreate?Id='+opp.Id + '&oppId=' + opp.Id);
                }
                else
                {
                    return null;
                }
                 
            }
            catch(Exception ex){
                System.debug('refreshCache Callout error: '+ ex);
            }     */  
       //proposalContactCreate(); 
       // return proposalContactCreate();
       return null;
    }
    
    /**
     * This methods gets called on Click of Simulate button
     * 
     * @return (PageReference) (PageReference for next view)
    */
    public PageReference simulate(){
        
        if(String.isBlank(estimateId)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a valid Estimate Id.'));   
            isAuthenticated = false;
            return null;
        }
        
        /*temp measure, till TIM web service issue is resolved*/
        //OrderHeaderCreatedInSTRATA.createProposal(String.valueOf(opp.Id), Integer.valueOf(estimateId));
        
        return null;
    }
   
    /**
     * This methods gets called on Click of Complete Proposal button to sync proposal zones and proposal zone monthly values
     * 
     * @return (PageReference) (PageReference for next view)
    */
    public PageReference complete(){
        
        /*temp measure, till TIM web service issue is resolved*/
        /*if(String.isBlank(estimateId)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a valid Estimate Id.'));   
            isAuthenticated = false;
            return null;
        }
        OrderHeaderCreatedInSTRATA.createProposalAsync(String.valueOf(opp.Id), Integer.valueOf(estimateId));*/
        
        /*Checks if old and new proposal is same. If yes then it means that new proposal has not been created from TIM in salesforce*/
        List<Proposal__c> newPropList = [select id,TIM_Id__c, advertiser__c, Opportunity__c,agency__c
                                         from Proposal__c 
                                         where Opportunity__c = : opp.Id AND RecordType.Name != 'Opportunity Budget'
                                         order by LastModifiedDate desc limit 1];
        
        System.debug('oldProposal----'+oldProposal);
        System.debug('newPropList----'+newPropList);
        
        //if(!Test.isRunningTest()){
            if((oldProposal!= null && oldProposal.size() > 0  && oldProposal.get(0).Id == newPropList.get(0).Id) || newPropList.size() == 0){
                pageMsg = System.Label.TIMCreate_No_Proposal_Error;   
                return null;
            }
        //}
        
        /*If proposal has been created properly, create Proposal zones and proposal zone monthly values in Salesforce, else display this message on VF page*/
        String res = BoomiHelper.syncProposalLineItems(newPropList.get(0),oppAE[0]);        
        system.debug('res@@@'+res);
        /*If proposal Proposal Line and Schedules have been created in Salesforce, Lock the opportunity record*/
        if(res == 'Success'){
            String existingRecordType = opp.RecordType.Name;
            if (existingRecordType == null){
                existingRecordType = '';
            }
            if(!existingRecordType.contains('Locked')){
                RecordType lockedRT = [select ID from RecordType where name = 'Opportunity Locked' and SobjectType='Opportunity' limit 1];
                opp.RecordTypeId = lockedRT.ID;
                opp.TIM_System__c = oppAE[0].TIM_System__c;
                try{
                    update opp;
                }
                catch(Exception e){
                    System.debug( System.Label.TIMCreate_Opportunity_RecordTypeUpdate_Error + ' Cause : ' + e.getMessage());
                }
            }
            //Code Added for SRSF-1304
             if(isDeleteOppBudgt) Delete propToDelete;
            //Code Ends here
            return new PageReference('/'+ newPropList.get(0).Id);
        }
        else{
            pageMsg = res;        
            isAuthenticated = false;
            return null;
        }    
    }
    
    /**
     * This methods gets called on Click of back button
     * 
     * @return (PageReference) (PageReference for next view)
    */    
    public PageReference back(){
   
        return new PageReference('/' + opp.Id); 
    }
    
    /**
     * This methods prepares the TIM url dunamically based on account and owner values on Opportunity
     * 
     * @return (String) (URL for TIM Create Order view)
    */  
    public String getTimURL(){  
        
        String retUrl = '';        
        String a = '';
        String agency = '';
        
        try{
            if( resMap.get(opp.AccountId) == null){           
            }
            else{
                a= resMap.get(opp.AccountId);
            }
            System.debug('getTimURL: opp.Rep_Firm__c ' + opp.Rep_Firm__c);
            System.debug('getTimURL: resMap.get(opp.Rep_Firm__c) ' + resMap.get(opp.Rep_Firm__c));
            if(resMap.get(opp.Rep_Firm__c) == null || resMap.get(opp.Rep_Firm__c) == '' || resMap.get(opp.Rep_Firm__c) == 'Error'){
                if(acctMap.get(opp.Agency_Account__c) != null && !String.isBlank(resMap.get(opp.Agency_Account__c))){
                    agency=resMap.get(opp.Agency_Account__c);            
                }                           
            }
            else{
                agency=resMap.get(opp.Rep_Firm__c);
            }            
        }
        catch(Exception ex){
            System.debug('Exception in GetTIMURL: ' + ex+ex.getLineNumber());            
        }
        
        try{            
            //Fetch logged in user's TIM credentials from Org Cache
            System.debug('Cache Key: ' + oppAE[0].Username__c+currentUser.TIM_System__c);
            
            string timSystem = currentUser.TIM_System__c;
            //Replace '.'  and space
            if(timSystem.indexOf('.') > 0)
            {
                timSystem = timSystem.replace('.','');
                timSystem = timSystem.deleteWhitespace();
            }
            TIMUserAccess.User timuser = CacheManager.getTIMUser(currentUser.Username__c+timSystem,timSystem);
            System.debug('Cache Hit: ' + timuser);
            
            if(String.isNotBlank(timUser.UP)){
                userName = timUser.UN;
                passwd = timUser.UP;  
            }
            else if(System.label.CacheFailSafe != 'true'){
                userName = '';
                passwd = '';
            }           
        }
        catch(Exception ex){
            System.debug('Error in getting Cache: ' + ex+ex.getLineNumber());
        }
        
        /*prepare base url with required parameters*/
        userName = userName != null ? userName : '';
        passwd = passwd != null ? passwd : '';
        //Code changes Aditi : 3/7/2018
        if(null != specialRecordType){
        retUrl = timServer + '/crmlogin.aspx?uname='+ userName + '&pwd='+ passwd +'&redirect=crmcreateorder.aspx%3Fcrmid%3D'+ opp.Id+specialRecordType +'%26client%3D'+ a +'%26agency%3D'+ agency +'%26ae%3D'+ oppAE[0].AE_ID__c;
        }
        else
        {
            retUrl = timServer + '/crmlogin.aspx?uname='+ userName + '&pwd='+ passwd +'&redirect=crmcreateorder.aspx%3Fcrmid%3D'+ opp.Id+'%26client%3D'+ a +'%26agency%3D'+ agency +'%26ae%3D'+ oppAE[0].AE_ID__c;
        }
        //Code changes ends
        
        System.debug('TIM URL: ' + retUrl);     
        return retUrl;
    }
/*
    public string bindDynamicLabelValues(string labelName, List<String> parameter)
    {
        //String label = Label.labelName;
        return string.format(label,parameter);
    }
  */
    /**
     * This methods gets called on from action method of VF page. It checks the Opportunity owner profile with custom setting profiles
     * also verifies Opportunity Account having contact reord with email or not. If these conditions are not satisfied then 
     * will open ProposalContactCreate Page.
     * 
     * @return (void) (NA)
    */
    /*public PageReference proposalContactCreate(){
        System.debug('opp.Id here::'+opp.Id);
        try{
            List<Contact> conList = [SELECT Id,Name,Email FROM Contact where Account.Id =:opp.AccountId AND Email != null LIMIT 1];          
            for(NationalProfiles__c custSetting : NationalProfiles__c.getAll().Values()){                
                if(custSetting.Profile_Name__c == opp.owner.Profile.Name && conList.size() <= 0){                            
                    PageReference pr =  new PageReference('/apex/ProposalContactCreate');
                    pr.getParameters().put('accId',opp.AccountId);
                    pr.getParameters().put('oppId',opp.Id);
                    pr.setRedirect(true);                    
                    return pr;                     
                }
            }            
        }
        catch(Exception e){
            System.debug('Exception '+e.getMessage()+' Line Number '+e.getLineNumber());
        }

        return null;
    }*/
    
}