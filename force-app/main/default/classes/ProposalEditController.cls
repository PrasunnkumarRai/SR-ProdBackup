/*
###########################################################################
# File..................: ProposalEditController.cls
# Version...............: 1
# Created by............: Sanchit Singhal   
# Created Date..........: 27-March-2017
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This class contains controller methods for ProposalEdit visualforce page
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/
public without sharing class ProposalEditController {
    
    /* This is to get the proposal details when user comes on this page.*/
    public List<Proposal__c> proposal ; 
    /* User Name for connecting to TIM UI page.*/
    private String userName; 
    /* User passwd for connecting to TIM UI page.*/
    private String passwd; 
    /* Tim server for connecting to TIM UI page.*/
    private String timServer;
    /* Tim System for connecting to Tim UI page.*/
    private String timSystem;
    /* Enfore classic mode for connecting to TIM UI page.*/
    public Boolean ClassicCompatibilityMode{get;set;} 
    /* Custom Setting map.*/
    Map<String,TIMIntegration__c> custSettMap = new Map<String,TIMIntegration__c>(); 
    /* to make sure if able to Authenticate to TIM system.*/
    public Boolean isAuthenticated {get;set;}
    /* Page messages*/
    public String pageMsg{get;set;} 
    public List<UserConnection__c> loggedInUser;
    public UserConnection__c currentUser;

    public Boolean TakeOwnershipBtnFlag{get;set;}  //SRSF- 1160 by Abhilash : 23-07-2018

    public ShowSeekerWebServiceHelper showSeekerWSHelper {get;set;}
    public String response{get;set;}
    public Boolean isSSuser{get;set;}
    public Proposal__c oppBudgetProposal {get;set;} 
    
    public ProposalEditController(ApexPages.StandardController controller){
        List<String> parameters = new List<String>();
        proposal = [SELECT Id, Name, TIM_Id__c, Opportunity__c, RecordType.Name, Advertiser__c, Agency__c,TIM_System__c, Opportunity__r.OwnerId, Opportunity__r.Owner.Name, Pilot_Proposal_ID__c, Opportunity__r.Owner.ShowSeeker_User__c, Active__c, (SELECT Id FROM Proposal_Zones__r) FROM Proposal__c WHERE Id = :ApexPages.currentPage().getParameters().get('Id')];

        System.debug('ProposalEditController:proposal '+proposal);
        isSSuser = proposal[0].Opportunity__r.Owner.ShowSeeker_User__c;

        System.debug('ProposalEditController:proposal '+proposal[0].TIM_System__c);
        System.debug('ProposalEditController:userInfo '+UserInfo.getUserId());
        ClassicCompatibilityMode = false;
        TakeOwnershipBtnFlag = false; //SRSF- 1160 by Abhilash : 23-07-2018

        if(proposal[0].Active__c) 
        {
            showSeekerWSHelper = new ShowSeekerWebServiceHelper();           
            System.debug('Is ShowSeeker User-->'+isSSuser);
            if(!isSSuser)
            {
                try
                {
                    isAuthenticated = true; 

                    loggedInUser = [SELECT AE_Id__c, TIM_System__c, Username__c FROM UserConnection__c WHERE User__c=: UserInfo.getUserId() AND TIM_System__c =: proposal[0].TIM_System__c];
                    System.debug ('ProposalEditController:loggedInUser '+loggedInUser);

                    if(loggedInUser.size() > 1)
                     {
                        parameters.add(userInfo.getName());
                        pageMsg = String.format(System.Label.TIMCreate_Multiple_UserConError, parameters);
                        isAuthenticated = false;
                        return;
                     }                  
                    else if(loggedInUser.size() == 0)
                    {
                        pageMsg = String.format(System.Label.TIMCreate_No_UserCon_Error,parameters); 
                        isAuthenticated = false;
                        return;
                    }
                    else
                    {
                        currentUser = loggedInUser[0];
                    }
                    System.debug('ProposalEditController:proposal '+proposal[0].recordType.name);                 
                                    
                    if(proposal[0].recordType.name != 'Opportunity Budget'){                                  
                    
                    /*Values from Custom setting objects.*/
                    custSettMap = TIMIntegration__c.getAll();
                    userName = custSettMap.get(currentUser.TIM_System__c).UserName__c;
                    passwd = custSettMap.get(currentUser.TIM_System__c).Password__c;
                    timServer = custSettMap.get(currentUser.TIM_System__c).TIMServer__c;
                    timSystem = currentUser.TIM_System__c;
                    ClassicCompatibilityMode = custSettMap.get(currentUser.TIM_System__c).ClassicCompatibilityMode__c;
                    Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
                    }
                }
                catch(Exception ex){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.format(System.Label.TIMCreate_No_UserCon_Error,parameters)));
                    pageMsg = string.format(System.Label.TIMCreate_No_UserCon_Error,parameters);                     
                    isAuthenticated = false;
                    return;
                }
            }
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.format(System.Label.Deactivated_Proposal_Cannot_be_Edited, parameters)));
            pageMsg = String.format(System.Label.Deactivated_Proposal_Cannot_be_Edited, parameters);
            isAuthenticated = false;
            return;
        }                    
    }
    
    /* This is the action method of VF page.*/    
    public PageReference execute()
    {   
        // SRSF-2001 : Moved to After showseeker user check    
        /*if(isAuthenticated){
            if(proposal[0].recordType.name == 'Linear' && (proposal.size() < 1 || proposal.get(0).TIM_Id__c == null)){                   
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.ProposalEdit_No_TIMID));
            }
        }*/
       
        if(proposal[0].recordType.name == 'Opportunity Budget'){
            return new PageReference('/apex/ProposalOpportunityBudget?id=' + proposal[0].Id+'&oppId='+proposal[0].Opportunity__c);
        }            
        else //SRSF-2001 : Code starts here   
        {            
            try
            {
                
                Opportunity opp = [SELECT Id, OwnerId, Owner.ShowSeeker_User__c, (SELECT Id, Start_Date__c, End_Date__c FROM Proposals__r WHERE RecordTypeId =: Label.Opportunity_Budget_RecordTypeId) FROM Opportunity WHERE Id=:proposal[0].Opportunity__c LIMIT 1];
              
                System.debug('Opportunity-->'+opp);
                System.debug('opp.Owner.ShowSeeker_User__c-->'+opp.Owner.ShowSeeker_User__c);
                System.debug('Opportunity budget proposal-->'+proposal[0]);

                if(isSSuser)    
                {      
                    if(opp.Proposals__r!=null && opp.Proposals__r.size() > 0)
                    {
                        oppBudgetProposal = opp.Proposals__r[0];
                    } 
                    else oppBudgetProposal = null;
                    
                    if(proposal[0].Active__c) 
                    {
                        response = showSeekerWSHelper.editProposal(proposal[0]);
                        System.debug('response-->'+response);
                        System.debug('showSeekerWSHelper.hasError-->'+showSeekerWSHelper.hasError);
                        if(showSeekerWSHelper.hasError)
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, response));
                            pageMsg = response;
                        }
                    }
                } 
                else // Existing TIM system code moved to else block
                {            
                    try
                    {
                        if(isAuthenticated)
                        {
                            if(proposal[0].recordType.name == 'Linear' && (proposal.size() < 1 || proposal.get(0).TIM_Id__c == null)){                   
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.ProposalEdit_No_TIMID));
                            }
                        }
                        if(CacheManager.checkCacheSize(timSystem) <=0){
                            CacheManager.refreshCache();
                            return  new PageReference('/apex/Proposal_Cache_Error?timSystem='+timSystem+'&retURL=/apex/ProposalEdit?Id='+proposal[0].Id + '&oppID=' + proposal[0].Opportunity__c);
                        }
                    }
                    catch(Exception ex){
                        System.debug('refreshCache Callout error: '+ ex);
                    }
        
                    if(ClassicCompatibilityMode){
                         return null;               
                    }
                    /*else{  
                        validate();
                        return new PageReference('/apex/ProposalEdit?id=' + proposal[0].id+'&oppId='+proposal[0].Opportunity__c);
                    }*/
                    validate();
                }
            // SRSF-2001 : End here 
            }
            catch(Exception ex){
                System.debug('Exception occured: '+ ex);
            }
            
        }
        return null;        
    }
    
    /* This is the action method of Edit VF page.*/    
    public PageReference validate(){
        
        if(isAuthenticated){
            if(proposal[0].recordType.name == 'Linear' && (proposal.size() < 1 || proposal.get(0).TIM_Id__c == null)){                   
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.ProposalEdit_No_TIMID));
            }
        }
        validateTakeOwnershipBtn(); //SRSF- 1160 by Abhilash : 23-07-2018
        return null;
    }

    // Code Changes for SRSF – 1160 – Code Starts
    //This Method will validate takeOwnership button
    public void validateTakeOwnershipBtn(){
        if(proposal[0]!=NULL){
            if(proposal[0].Proposal_Zones__r.size()==0){
               if(proposal[0].opportunity__r.ownerId!=UserInfo.getUserId()){
                    List<OpportunityTeamMember> oppTeamMbrList = [SELECT Id FROM OpportunityTeamMember WHERE OpportunityId =:proposal[0].Opportunity__c AND UserId =:UserInfo.getUserId()];
                    if(oppTeamMbrList.size()<=0)
                       return;
                }
                TakeOwnershipBtnFlag = TRUE;   
            }
        }
    }

    public void invokeTakeOwership(){
        System.debug('call web service method here');
        BoomiWebServiceHelper boomiwebservc = new BoomiWebServiceHelper();
        List<UserConnection__c>  userConnList = [SELECT Id,AE_Id__c,Username__c,TIM_System__c FROM UserConnection__c WHERE User__c =:UserInfo.getUserId() AND TIM_System__c =:proposal[0].tim_system__c];
        if(userConnList.size()>0){
            pageMsg = boomiwebservc.transferOwnership(proposal[0],userConnList[0]);
            System.debug('Page msg::'+pageMsg);
            if(pageMsg.equalsIgnoreCase(''))
                isAuthenticated = TRUE;
        }
        else{
            pageMsg = Label.No_User_Connection_Error; 
            isAuthenticated = false;
        }
    }
    // Code Changes for SRSF – 1160 – Code Ends

    
    /*Method that gets called on Click of Complete Proposal button to sync proposal zones and proposal zone monthly values*/    
    public PageReference complete(){
        String res;
        BoomiWebServiceHelper boomiHelper = new BoomiWebServiceHelper();                    
        /*If proposal has been created properly, create Proposal Zones/Monthly Values in Salesforce, else display error message on VF page*/
        if(proposal.size() > 0)
            res =  boomiHelper.syncProposalLineItems(proposal.get(0),currentUser);
        else
            res = 'Error: Proposal not found.';
                        
        if(res == 'Success'){
            return new PageReference('/'+ proposal.get(0).Id);
        }
        else{
            if(System.label.ShowDevMessages == 'true'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.TIMCreate_Sync_ProposalLineItems_Error + '\n ' + res));
                Log4SF.logMessage('ProposalEditController', 'complete', res, UserInfo.getUserId(),proposal.get(0).Id);
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.TIMCreate_Sync_ProposalLineItems_Error));
                Log4SF.logMessage('ProposalEditController', 'complete', res, UserInfo.getUserId(),proposal.get(0).Id);
            }   
        }
        return null;    
    }
    
    /*This method prepares the TIM url dynamically based on account values on Opportunity*/
    public String getTimURL(){
  
        String retUrl = ''; 
        userName = userName != null ? userName : '';
        passwd = passwd != null ? passwd : '';
        
        try{            
            //Fetch logged in user's TIM credentials from Org Cache
            System.debug('Cache Key: ' + currentUser.Username__c+currentUser.TIM_System__c);
            String timSystem = currentUser.TIM_System__c;
            //replace '.'  and space
            if(timSystem.indexOf('.') > 0)
            {
                timSystem = timSystem.replace('.','');
                timSystem = timSystem.deleteWhitespace();
            }
            TIMUserAccess.User timuser = CacheManager.getTIMUser(currentUser.Username__c+timSystem,timSystem);
            System.debug('ProposalEditController:Cache Hit ' + timuser);
            
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
            System.debug('ProposalEditController:Error in getting Cache: ' + ex+ex.getLineNumber());
        }
        
        /*prepare TIM url with required parameters*/
        if(proposal.size() > 0)
            retUrl = timServer + '/crmlogin.aspx?uname='+userName+'&pwd='+passwd+
                                 '&redirect=crmopenorderstatus.aspx%3Forder%3D'+proposal.get(0).TIM_Id__c;
                                 
        System.debug('ProposalEditController:TIM URL ' + retUrl);
        return retUrl;
    }

    public PageReference back(){
        return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
    } 

    //SRSF-3937: Added method to delete opportunity budget record if exists
    public PageReference deleteOpportunityBudget()
    {
        //pageMsg = '';
        try
        {
            DELETE oppBudgetProposal; 
        }
        catch(Exception ex){
            pageMsg = ex.getMessage();
            Log4SF.logMessage('CreateShowSeekerProposal', 'deleteOpportunityBudget', '', ex, UserInfo.getUserId(),proposal.get(0).Id);            
        }        
        return null;
    }
}