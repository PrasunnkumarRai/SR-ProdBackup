/*
###########################################################################
# File..................: CreateShowSeekerProposal.cls
# Version...............: 1
# Created by............: Usharani   
# Created Date..........: 03-June-2020
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This class contains logic for Proposal creation is ShowSeeker
# TAO Ref#..............: NA
# Test Class............: CreateShowSeekerProposalTest
# Change Log............:               
# Date            User       Requested By (Optional)   Description
# 03-June-2020  Usharani         Greg Rice              SRSF-1960
#
############################################################################*/

public with sharing class CreateShowSeekerProposal {

    private ShowSeekerWebServiceHelper ssHelper;
    public Opportunity opp {get;set;}
    public String response{get;set;}
    public Map<Id,Account> acctMap; //Account map of Advertise,Agency & Rep firm on Opportunity
    public String specialRecordType{get;set;}
    public String pageMsg{get;set;}
    public String recordID{get; set;}
    public String isSCXupload{get; set;}
    public Proposal__c oppBudgetProposal {get;set;}
   
    public CreateShowSeekerProposal(){
        pageMsg = '';
        response = '';
        ssHelper = new ShowSeekerWebServiceHelper();
        recordID = ApexPages.currentPage().getParameters().get('OppId');        
        isSCXupload = null != ApexPages.currentPage().getParameters().get('isSCX')?ApexPages.currentPage().getParameters().get('isSCX'):null;
        specialRecordType =  ApexPages.currentPage().getParameters().get('recType');
        // If request is not for Special proposal creation then set Default record type as Linear  
        if(String.isBlank(specialRecordType) || null == specialRecordType) {
            specialRecordType = Label.Linear_RT;
        }

        System.debug(' $$$ CreateShowSeekerProposal ::: Opportunity Id ::: ' +recordID + ' $$$ specialRecordType ::: '+specialRecordType + ' $$$ isSCXupload ::: ' +isSCXupload);       
    }

    /**
     * On CreateShowSeekerProposal VF page load this method will be called to hit directly Showseeker create 
     * proposal rest API and it will return hash url as response back to user on screen if no errors encountered
     * @return
     */
    public PageReference execute(){
        try{
            List<Opportunity> oppLst = [SELECT Id, Name, PoliticalOpportunity__c FROM Opportunity WHERE Id=:recordID]; 
            System.debug('inside execute>>>>>>'+oppLst);
            if(oppLst != null && oppLst.size()>0) 
            {
                opp = oppLst[0];
                if(opp.PoliticalOpportunity__c) 
                    specialRecordType = Label.Political_RT ;
                ssHelper.isFrmSCXUpload = Boolean.valueOf(isSCXupload);
                response = ssHelper.CreateProposal(opp.Id, specialRecordType);    
                System.debug('inside execute response>>>>>>'+response);        
                if(ssHelper.hasError){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, response));
                    pageMsg = response;
                    Log4SF.logMessage('CreateShowSeekerProposal', 'Execute', ''+response, UserInfo.getUserId(),recordID);
                }                 
                if(ssHelper.lstOpportunity[0].Proposals__r!=null && ssHelper.lstOpportunity[0].Proposals__r.Size()>0){
                    oppBudgetProposal = ssHelper.lstOpportunity[0].Proposals__r[0];                     
                } else oppBudgetProposal = null; 
                System.debug('oppBudgetProposal>>>>>>'+oppBudgetProposal); 
            }
            else pageMsg = Label.No_Opportunity_Error;
            
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: '+ ex.getMessage()));
            pageMsg = 'Error: ' + ex.getMessage();
            Log4SF.logMessage('CreateShowSeekerProposal', 'Execute', '', ex, UserInfo.getUserId(),recordID);
        }
        return null;
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
            Log4SF.logMessage('CreateShowSeekerProposal', 'deleteOpportunityBudget', '', ex, UserInfo.getUserId(),recordID);            
        }
        return null;
    }
}