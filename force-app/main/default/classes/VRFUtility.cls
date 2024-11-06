public with sharing class VRFUtility implements Queueable {
    
    List<string> IDs; 
    String Message = null;

    public VRFUtility(List<string> Ids, string message){
        this.IDs     = Ids;
        this.Message = message;
    }

    public VRFUtility(List<string> Ids){
          this.IDs     = Ids;
          this.Message = null;
    }

    public void execute(QueueableContext context) 
    {
        if (this.Message  != null){
            SetErrorMessages(IDs, Message);
        }   
    }

    public static void SetErrorMessage(string id, string message){

        System.debug('SetErrorMessage Called id: ' + id);
        List<string> idsList = new List<string>();
        idsList.add(id);

        List<Digital_Creative__c> digitalCreativeList = GetDigitalCreativeList(idsList);  

         System.debug('Digital Creative Size ' + digitalCreativeList.size());
         System.debug('SetErrorMessage Called id: ' + message);

        if (digitalCreativeList.size() > 0){
            digitalCreativeList[0].Status__c        = GetVRFErrorStatus();
            digitalCreativeList[0].Error_Message__c = message;
            update digitalCreativeList[0];
        }

    }

    public static void RemoveErrorMessage(string id){

        List<string> idsList = new List<string>();
        idsList.add(id);

        List<Digital_Creative__c> digitalCreativeList = GetDigitalCreativeErrorList(idsList);  

        if (digitalCreativeList.size() > 0){
            digitalCreativeList[0].Error_Message__c = null;   
            update digitalCreativeList[0];
        }

    }

    public static void SetErrorMessages(List<string> creativeIdList, string message){

        List<Digital_Creative__c> digitalCreativeList = GetDigitalCreativeList(creativeIdList);  

        if (digitalCreativeList.size() > 0){

            for(Digital_Creative__c creative : digitalCreativeList){
                creative.Error_Message__c = message;             
            }         

            update digitalCreativeList;
        }
    }


    private static List<Digital_Creative__c> GetDigitalCreativeErrorList(List<string> creativeIdList){

         List<Digital_Creative__c> creativeList = [SELECT Error_Message__c, Status__c FROM Digital_Creative__c 
                                                   WHERE (Error_Message__c !=  null OR Error_Message__c <> '')
                                                   AND id IN: creativeIdList];

         return creativeList;
     }

    @TestVisible
    private static List<Digital_Creative__c> GetDigitalCreativeList(List<string> creativeIdList){

        List<Digital_Creative__c> creativeList = [SELECT Error_Message__c, Status__c FROM Digital_Creative__c 
                                                  WHERE (Error_Message__c = null OR Error_Message__c = '')
                                                  AND id IN: creativeIdList];

       return creativeList;
    }

    public static string GetVRFErrorStatus(){

            List<VRF_Settings__c> vrf_status =  [SELECT Value__c  FROM VRF_Settings__c 
                                                 WHERE Category__c =: 'vrf_errorStatus' 
                                                 LIMIT 1];

            if (vrf_status.size() > 0){
                return vrf_status[0].Value__c;
            }

            return null;

    }

     public static string GetVRFSubmmittedStatus(){

            List<VRF_Settings__c> vrf_status =  [SELECT Value__c  FROM VRF_Settings__c 
                                                 WHERE Category__c =: 'vrf_submitted' 
                                                 LIMIT 1];

            if (vrf_status.size() > 0){
                return vrf_status[0].Value__c;
            }

            return null;

    }

    @TestVisible
    public static Boolean isOKForSubmission(string status){

              List<VRF_Settings__c> settings = [SELECT Value__c FROM VRF_Settings__c 
                                                WHERE Value__c =: status 
                                                AND Category__c = 'vrf_allowCreate'];

        if (settings.size() > 0){
            return true;
        }

        return false;
    }
    
    public static HttpResponse PostUpdateStatus(string creativeId, string json){

        String url =  getUpdateURL() + '?id=' + creativeId;
        String omsApiKey = System.Label.OmsApiKey;

        Http http           = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(url);
        request.setTimeout(120000);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('OmsApiKey', omsApiKey);
        request.setBody(json);

        HttpResponse response = http.send(request);

        System.debug('PostUpdateStatus' + url);
        System.debug('PostUpdateStatus' + json);
        System.debug('PostUpdateStatus' + response.getBody() + ' ' +  response.getStatusCode());

        return response;

    }

    @TestVisible
    private static string getUpdateURL(){

         VRF_Settings__c settings = [SELECT Value__c  
                                     FROM VRF_Settings__c 
                                     WHERE Category__c =: 'vrf_status_endpoint' 
                                     LIMIT 1];

        System.debug('VRF Middleware Enpoint: ' + settings.Value__c);

        return settings.Value__c;
    }

}