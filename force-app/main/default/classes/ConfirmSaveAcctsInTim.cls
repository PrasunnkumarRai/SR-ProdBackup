/*
###########################################################################
# File..................: ConfirmSaveAcctsInTim.cls
# Version...............: 1
# Created by............: Usharani   
# Created Date..........: 01-Nov-2019
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This class contains controller methods for 'ConfirmToSaveAccountsInTim' visualforce page
# TAO Ref#..............: NA
# Test Class............: ConfirmSaveAcctsInTimTest
# Change Log............:               
# Date            User       Requested By (Optional)   Description
# 01-Nov-2019  Usharani         Greg Rice              
#
############################################################################*/
public with sharing class ConfirmSaveAcctsInTim 
{
    public Boolean isPoliticalOpp {get; set;}
    public String recordID {get; set;}
    public String specialRecType{get;set;}
    public String isSaveTimAcct {get;set;}
    public Boolean isCTP {get;set;}
    public Boolean isSSusr {get;set;}
    public ApexPages.StandardSetController propCont{get;set;}

    public ConfirmSaveAcctsInTim() 
    {      
        isSSusr = false;     
        isSaveTimAcct = 'false';
        recordID = ApexPages.currentPage().getParameters().get('OppId');
        specialRecType = null !=ApexPages.currentPage().getParameters().get('recType') ? ApexPages.currentPage().getParameters().get('recType') : null; 
        isCTP = null != ApexPages.currentPage().getParameters().get('isCTP')?Boolean.valueOf(ApexPages.currentPage().getParameters().get('isCTP')):false;
        isPoliticalOpp = null != ApexPages.currentPage().getParameters().get('isPolitical')?Boolean.valueOf(ApexPages.currentPage().getParameters().get('isPolitical')):false;
        System.debug('recordID>>>'+recordID + '<<<< isCTP >>>>>'+isCTP);    
    }

    public PageReference checkAccountConnections()
    {    
        List<Opportunity> oppLst = [SELECT Id, Owner.ShowSeeker_User__c FROM Opportunity WHERE Id = :recordID];
        if(oppLst != null && oppLst.size()>0 )
        { 
            if(oppLst[0].Owner.ShowSeeker_User__c) {
                isSSusr = true;
            }
        }
        System.debug('ShowSeeker_User__c--->'+ isSSusr);

        if(!isSSusr)
        {
            if(Boolean.valueOf(System.Label.Show_confirmation_msg_for_new_account_creation_in_TIM))
            {   
                if(isCTP)
                {
                    ApexPages.currentPage().getParameters().put('Id',recordID);                    
                    propCont = new ApexPages.StandardSetController(new List<Proposal__c>());
                    ProposalTIMCreateController ctp = new ProposalTIMCreateController(propCont);
                    ctp.execute();            
                    isSaveTimAcct = ctp.createAccInTIM; 
                }
                else{                
                    ProposalSCXUploadController cont = new ProposalSCXUploadController(recordID); 
                    cont.verifyTimAccountID();           
                    isSaveTimAcct = cont.createAccInTIM;
                } 
            }
            else
            {               
                if(isCTP) { 
                    PageReference ctpPage= new PageReference('/apex/ProposalTIMCreate?id={!recordID}&recType={!specialRecType}&isConfirm=true'); 
                }
                else {                         
                    PageReference scxPage= new PageReference('/apex/ProposalSCXUpload?OppId={!recordID}&isPolitical={!isPoliticalOpp}&recType={!specialRecType}&isConfirm=true');
                }
            }
        }        
        System.debug('ConfirmSaveAcctsInTim--->'+isSaveTimAcct);
        return null;
    }
}