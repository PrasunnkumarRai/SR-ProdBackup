/*
###########################################################################
# File..................: DeleteOppBudgetProposal.cls
# Version...............: 1
# Created by............: Usharani   
# Created Date..........: 12-Dec-2019
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This class contains logic for Delete Proposal of type Opportunity Budget
# TAO Ref#..............: NA
# Test Class............: DeleteOppBudgetProposalTest
# Change Log............:               
# Date            User       Requested By (Optional)   Description
# 12-Dec-2019   Usharani         Greg Rice              SRSF-1960               
#
############################################################################*/

@RestResource(urlMapping='/SpectrumReachDeleteOppBudgetProp/*')
global with sharing class DeleteOppBudgetProposal 
{

  @HttpGet
  global static String doGet() 
  {
    return 'SpectrumReachDeleteOppBudgetProp API is Alive!';
  }

  @Httpdelete
  global static ResponseCls deleteProposals()
  {
    String response = ''; 
    Boolean isSuccess = FALSE;
    List<Proposal__c> proposals=new List<Proposal__c>();
    Integer oppCnt = 0;

    RestRequest req = RestContext.request;         
    String oppId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);

    System.debug('oppId>>>'+oppId + '<<<  req >>>'+req);

    Map<String,Object> mapOfThirdPartyLog = new Map<String, Object>{'JSON__c' => oppId,'API_Name__c' => 'SpectrumReachDeleteOppBudgetProp', 'Source__c' => 'ShowSeeker'};
    Third_Party_Logger__c thirdPartyLogger = Log4SF.createThirdPartyLogger(mapOfThirdPartyLog,TRUE,new Third_Party_Logger__c());
    
    if(!CommonUtilities.isStringNullOrEmpty(oppId))
    {
        oppCnt = [SELECT count() FROM Opportunity WHERE Id=:oppId];
        try
        {
            if(oppCnt>0)
            {
                Id recordTypeId = Schema.SObjectType.Proposal__c.getRecordTypeInfosByDeveloperName().get('Opportunity_Budget').getRecordTypeId();       
                proposals=[SELECT Id FROM Proposal__c WHERE RecordTypeId=:recordTypeId AND Opportunity__c=:oppId];
                
                System.debug('proposals >>>>'+proposals.Size());

                if(proposals!=null && proposals.size()>0){                   
                  delete proposals;
                  isSuccess = TRUE;
                  response = System.Label.Opportunity_Budget_Proposal_Deleted;
                }  
                else response = System.Label.No_Opportunity_Budget_Proposal_found +oppId;     
            }           
            else response = System.Label.No_Opportunity_Error+': '+ oppId;
        }
        catch(Exception ex)
        {
            response = ex.getMessage();                
            thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure','Error_Message__c' => response,'User__c' =>UserInfo.getUserId() } ,TRUE ,thirdPartyLogger);
        }
    } 
    else {
        response = System.Label.Opportunity_Id_Error;
    } 
    System.debug('response >>>>'+response);               
    return new ResponseCls(isSuccess,response);   
  }

  global class ResponseCls 
  {
    global boolean isSuccess;
    global String result;
    global ResponseCls(boolean success, String msg) {
      isSuccess = success;
      result = msg;
    }
  }
}