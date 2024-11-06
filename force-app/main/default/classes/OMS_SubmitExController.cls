/*
    Author               :  M & S
    Date                 :  Sep 05-19
    Description          :  Visualforce page controller for sending data(dma,platforms,zipcodes,network) to OMS(Middleware) 
                            
    Modification History : 
*/
public with sharing class OMS_SubmitExController {

   public static string message {get; set; }//Holds the message based on response
   public string strDcId {get; set; }//Holds the DigitalCampaign Recordid

    public OMS_SubmitExController(ApexPages.StandardController stdController){
        strDcId = ApexPages.currentPage().getParameters().get('id');
        System.debug('strDcId::'+strDcId);
        //SendData(strDcId);
    }

    //Sending data to Midleware
    public PageReference SendData(){
        System.debug('strDcId::'+strDcId);
       try{
            list<User> lstUser = [select id,Profile.name from User where id=:Userinfo.getUserId()];
            String strProfileName = '';
            if( lstUser!=null && !lstUser.isEmpty() )
                strProfileName = lstUser[0].Profile.name;
           if(!getMasterDigOpsUser().contains(strProfileName)){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Only Master - Digital Operations users are allowed to push the data to Operative');
                ApexPages.addMessage(myMsg);
                return null;
           }
            list<Digital_Campaign__c> lstDC = [SELECT id,
                                                    Name,
                                                    RecordTypeId, RecordType.Name,
                                                    Status__c,
                                                    Advertiser__c, Advertiser__r.Name,
                                                    Agency__c, Agency__r.Name,
                                                    Rep_Firm_Text__c, Opportunity__r.Rep_Firm__c,
                                                    Product_Type__c,
                                                    Digital_Campaign_ID__c,
                                                    TIM_ID__c,
                                                    Campaign_Name__c,
                                                    Campaign_Start_Date__c, Campaign_End_Date__c,
                                                    Total_Impressions__c,
                                                    Gross_CPM1__c,
                                                    Rate_Classification__c,
                                                    VAST_Tag__c,
                                                    AdsE_Platform_s__c,
                                                    Kids_Network_Exclusion__c,
                                                    Tune_In_Exclusions__c,
                                                    AdsE_Network__c,
                                                    AdsE_Genre_s__c,
                                                    DMAs__c,
                                                    OwnerId, Owner.LastName, Owner.FirstName, Owner.Email,
                                                    Sales_Office__c,
                                                    LastModifiedById, LastModifiedBy.Name,
                                                    CustomZipCode__c, Zip_Codes__c,
                                                    State__c,
                                                    Spectrum_Reach_Zones__c,
                                                    Advertiser__r.Political_Account__c,
                                               		Device_Exclusions__c
                                        FROM Digital_Campaign__c
                                        WHERE id =: strDcId and Rate_Classification__c!=null and (status__c='03 Submitted to Digital Ops' OR status__c='3.1 DC Submission Error' OR status__c='13 Revision Submitted to Digital Ops' OR status__c='13.1 DC Revision Submission Error')];
            if( lstDC!=null && !lstDC.isEmpty()){
                    Digital_Campaign__c objDC = lstDC[0];
                    string payload = OMSHelper.prepareJSONDataToOMS(objDC);
                    System.debug(payload);
                    String response = SendToMiddleware(payload, objDC);
                    ApexPages.Message myMsg;
                    if(response.indexOf('Error :')!=-1)
                        myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, response.unescapeHtml4());
                    else
                        myMsg = new ApexPages.Message(ApexPages.Severity.Confirm, response);
                    ApexPages.addMessage(myMsg);
                    return null;
            }else{
                String strMsg = ' Rate Classification should not be none and Digital Campaign status should be Following status.';
                strMsg+='<br />03 Submitted to Digital Ops <br />3.1 DC Submission Error<br/>13 Revision Submitted to Digital Ops<br/>13.1 DC Revision Submission Error';
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, strMsg.unescapeHtml4());
                ApexPages.addMessage(myMsg);
                return null;
            }
       }catch(Exception ex){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
       }
       //return null;
    }
    
    //check for Master - Digital Operations User
    public static set<string> getMasterDigOpsUser(){
        set<string> lstMasterDigopsProfiles = new set<string>();
        lstMasterDigopsProfiles.add('Master - Account Coordinator');
        lstMasterDigopsProfiles.add('Master - Account Planner');
        lstMasterDigopsProfiles.add('Master - Account Executive');
        lstMasterDigopsProfiles.add('Master - Digital Coordinator');
        lstMasterDigopsProfiles.add('Master - Digital Planner');
        lstMasterDigopsProfiles.add('Master - Digital Sales');
        lstMasterDigopsProfiles.add('Master - Interconnect Account Coordinator');
        lstMasterDigopsProfiles.add('Master - Interconnect Account Planner');
        lstMasterDigopsProfiles.add('Master - Interconnect Sales Manager');
        lstMasterDigopsProfiles.add('Master - Local Sales Manager');
        lstMasterDigopsProfiles.add('Master - National Sales Manager');
        lstMasterDigopsProfiles.add('Master - Digital Operations');
        return lstMasterDigopsProfiles;
    }

    //Sending data to Middleware
    public static String SendToMiddleware(string json, Digital_Campaign__c objDC){
        
        //String url = 'http://vrf-api-dev.chartercom.com/api/OMS/ProcessSalesOrder';
        String url;
        OMS_Settings__c objOMSSettings;
        if( objDC.status__c=='03 Submitted to Digital Ops' || objDC.status__c=='3.1 DC Submission Error' )  
            url =OMS_Settings__c.getValues('Operative Submit').Endpoint_URL__c;
        else 
            url =OMS_Settings__c.getValues('Operative Revision').Endpoint_URL__c;
        Http http           = new Http();
        HttpRequest request = new HttpRequest();
        System.debug('url::'+url);
        request.setEndpoint(url);
        request.setTimeout(120000);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/plain');
        request.setBody(json);
       
        HttpResponse response = new HttpResponse();
        if(!Test.isRunningTest())
            response = http.send(request);
        System.debug(response);    
        if (response.getStatusCode() != 200 ) {       
             message = ' Error : '+response.getStatusCode() + ' ' + response.getBody() + '<br /> on ' + url;
             objDC.OMS_Error_Description__c = 'Error : '+response.getStatusCode()+' '+response.getBody()+'<br />'+json;
             if( objDC.Status__c == '03 Submitted to Digital Ops' )
                objDC.Status__c = '3.1 DC Submission Error';
            else if( objDC.Status__c == '13 Revision Submitted to Digital Ops' )
                objDC.Status__c = '13.1 DC Revision Submission Error';
            System.debug('OMS Middleware Response ' + message +  '\n \n' + json);
        } else {
             message = objDC.Name+' is processed successfully.';
             objDC.OMS_Error_Description__c = '';
            System.debug('Middleware Response ' + response.getBody());
        }
        update objDC;
        return message;
    }

}