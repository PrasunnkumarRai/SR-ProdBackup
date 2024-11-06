/*
###########################################################################
# File..................: EditOppBudgetProposal.cls
# Version...............: 1
# Created by............: Usharani   
# Created Date..........: 11-Dec-2019
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This class contains logic for Edit Proposal of type Opportunity Budget
# TAO Ref#..............: NA
# Test Class............: EditOppBudgetProposalTest
# Change Log............:               
# Date            User       Requested By (Optional)   Description
# 11-Dec-2019  Usharani         Greg Rice              SRSF-1960   
#
############################################################################*/

@RestResource(urlMapping='/SpectrumReachEditOppBudgetProposal/*') 
global with sharing class EditOppBudgetProposal 
{

    @HttpGet
    global static ResponseCls editBudgetProposals()
    {
        String response = ''; 
        Boolean isSuccess = FALSE;
        Integer oppCount = 0;

        RestRequest req = RestContext.request;
        String oppId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);

        Map<String,Object> mapOfThirdPartyLog = new Map<String, Object>{'JSON__c' => oppId,'API_Name__c' => 'SpectrumReachEditOppBudgetProposal', 'Source__c' => 'ShowSeeker'};
        Third_Party_Logger__c thirdPartyLogger = Log4SF.createThirdPartyLogger(mapOfThirdPartyLog,TRUE,new Third_Party_Logger__c());

        if(!CommonUtilities.isStringNullOrEmpty(oppId))
        {
            oppCount = [SELECT count() FROM Opportunity WHERE Id=:oppId];        
            try
            { 
                if(oppCount>0)
                {
                    Id recordTypeId = Schema.SObjectType.Proposal__c.getRecordTypeInfosByDeveloperName().get('Opportunity_Budget').getRecordTypeId();    
                    List<Proposal__c> oppBudgetProp = [SELECT Id FROM Proposal__c WHERE RecordTypeId=:recordTypeId AND Opportunity__c=:oppId LIMIT 1];
                    if(oppBudgetProp!=NULL && oppBudgetProp.size()>0 )
                    {
                        response = URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Proposal__c/'+oppBudgetProp[0].Id+'/edit';
                        isSuccess = TRUE;
                    }                
                    else response = System.Label.No_Opportunity_Budget_Proposal_found +oppId; 
                }
                else response = System.Label.No_Opportunity_Error+': '+ oppId;
            }
            catch(Exception ex) {
                System.debug('Exception occured--->'+ex.getMessage());
                response = ex.getMessage(); 
                thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure','Error_Message__c' => response,'User__c' =>UserInfo.getUserId() } ,TRUE ,thirdPartyLogger);
            }  
        }
        else {
            response = System.Label.Opportunity_Id_Error;
        }              
        return new ResponseCls(isSuccess,response);
    }

    global class ResponseCls {
        global boolean isSuccess;
        global String result;
        global ResponseCls(boolean success, String msg) {
            isSuccess = success;
            result = msg;
        }
    }
}