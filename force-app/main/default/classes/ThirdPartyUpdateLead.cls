/*
###########################################################################
# File..................: ThirdPartyUpdateLead .cls
# Version...............: 1
# Created by............: Abhilash Vangari
# Created Date..........: 14-Jan-2019
# Last Modified by......: Abhilash Vangari
# Last Modified Date....: 
# Description...........: Jira Ticket : SRSF- 1589
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/
@RestResource(urlMapping='/SpectrumReachUpdateLead')
global with sharing class ThirdPartyUpdateLead {
    
    @HttpGet
    global static String doGet() {
        return 'SpectrumReachUpdateLead API is Alive!';
    }

    @HttpPost
    global static ResponseCls doPost(Lead lead) {
        Map<String,Object> mapOfThirdPartyLog = new Map<String, Object>{'JSON__c' => String.valueOf(lead),'API_Name__c' => 'SpectrumReachUpdateLead', 'Source__c' => Label.SPP_Search };
        Third_Party_Logger__c thirdPartyLogger = Log4SF.createThirdPartyLogger(mapOfThirdPartyLog,FALSE,new Third_Party_Logger__c());
     
        try{            
            if(lead!=NULL && lead.Id!=NULL){
               Lead ld= [SELECT Id, IsConverted FROM Lead WHERE Id = :lead.Id]; 
               if(!ld.IsConverted) {
                   //SRSF-2010 : Code Starts here
                    Map<String, List<String>> dependentPLmap = PicklistFieldController.getDependentPicklistValues(new Lead(),'Primary_Commodity__c','Commodity_Codes__c');

                    if(!String.isBlank(lead.Primary_Commodity__c)  && lead.Primary_Commodity__c != NULL ){                        
                        String response = PicklistFieldController.validatePicklistValues(dependentPLmap,lead.Primary_Commodity__c, lead.Commodity_Codes__c) ;
                        if(!String.isBlank(response)){
                            thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure','Error_Message__c' => response ,'User__c' =>UserInfo.getUserId() } ,TRUE ,thirdPartyLogger);
                            return new ResponseCls(FALSE,response, null);
                        }
                    }
                    if(String.isBlank(lead.Primary_Commodity__c) && !String.isBlank(lead.Commodity_Codes__c)){
                        thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure','Error_Message__c' => Label.Mandatory_Lead_Primary_Commodity,'User__c' =>UserInfo.getUserId()} ,TRUE ,thirdPartyLogger);
                        return new ResponseCls(FALSE,Label.Mandatory_Lead_Primary_Commodity,NULL);
                    }
                   //SRSF-2010 : Code Ends here           
                   UPDATE lead;
                   thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Success','User__c' =>UserInfo.getUserId() } ,TRUE ,thirdPartyLogger);
                   return new ResponseCls(TRUE,Label.Lead_Update_Success_Message , lead);
                }else{
                     thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Success','User__c' =>UserInfo.getUserId() } ,TRUE ,thirdPartyLogger);
                     return new ResponseCls(FALSE,Label.Lead_Update_Error_Message, null);
                }
            }
            else{
                thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure','Error_Message__c' => Label.Id_mandatory_to_update_lead ,'User__c' =>UserInfo.getUserId() } ,TRUE ,thirdPartyLogger);
                return new ResponseCls(FALSE,Label.Id_mandatory_to_update_lead, NULL);  
            }
        }
        catch(Exception exp){
            thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure','Error_Message__c' => exp.getMessage() ,'User__c' =>UserInfo.getUserId() } ,TRUE ,thirdPartyLogger);
            return new ResponseCls(FALSE,'Error:'+exp.getMessage() , NULL); 
        }
    }
    
    global class ResponseCls {
        global boolean isSuccess;
        global String message;
        global Lead lead;
        global ResponseCls(boolean success, String msg, Lead updatedLead) {
            isSuccess = success;
            message = msg;
            lead = updatedLead;
        }
    }

}