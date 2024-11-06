public class DigitalCreativeRevisionUtil {

  public static Boolean setStatusTo200 {get; set;}

  @InvocableMethod(label='' description='Send revised status and dates to middleware if the status is set to 48 Digital Ops Date Revision In Progress')
  public static void SendVRFData(List<ID> ids) {
        
        Log('Process Builder is hit becase the statu is change to 48 Digital Ops Date Revision In Progress'); 

        for(ID id : ids){
            System.debug('Process Builder '  + id);
        }

        List<Digital_Creative__c> creativeList = [SELECT Digital_Campaign__c, 
                                                         id, 
                                                         Status__c,
                                                         Digital_Campaign__r.Campaign_Start_Date__c,
                                                         Digital_Campaign__r.Campaign_End_Date__c,
                                                         Creative_Start_Date__c,
                                                         Creative_End_Date__c  
                                                 FROM Digital_Creative__c WHERE Id in: ids];

       Log('Process Builder size: ' + creativeList.size());

        if (creativeList.size() > 0){
            try{
            	SendDataToMiddleWare(creativeList);
            }catch(Exception ex){}
        }
   }

   @TestVisible
   private static void SendDataToMiddleWare(List<Digital_Creative__c> creatliveList){

        List<string> creativeIdList = new List<string>();

        JSONGenerator gen = JSON.createGenerator(false);

        gen.writeStartObject();
        
        gen.writeFieldName('Digital Creatives');
        gen.writeStartArray();
        
        for(Digital_Creative__c creative :  creatliveList){
            
            Log('Process Builder Digital Creative  data: Digital Campaign ID ' +   creative.Digital_Campaign__c + ' | Digital Creative ID '  
            +  creative.id + ' | Status ' +  creative.Status__c + ' | Digital Campaign Start Date ' + creative.Digital_Campaign__r.Campaign_Start_Date__c  
            +  ' | Digital Campaign End Date ' +  creative.Digital_Campaign__r.Campaign_End_Date__c + ' | Creative Start Date ' + creative.Creative_Start_Date__c
            +  ' | Creative End Date ' + creative.Creative_End_Date__c);  

            gen.writeStartObject();
                gen.writeStringField('Digital Campaign ID', VRFCallouts.stringCoalesce(creative.Digital_Campaign__c));
                gen.writeStringField('Digital Creative ID', VRFCallouts.stringCoalesce(creative.Id));
                gen.writeStringField('Status', VRFCallouts.stringCoalesce(creative.Status__c));
                gen.writeStringField('Digital Campaign Start Date', VRFCallouts.dateCoalesce(creative.Digital_Campaign__r.Campaign_Start_Date__c));
                gen.writeStringField('Digital Campaign End Date', VRFCallouts.dateCoalesce(creative.Digital_Campaign__r.Campaign_End_Date__c));
                gen.writeStringField('Creative Start Date', VRFCallouts.dateCoalesce(creative.Creative_Start_Date__c));
                gen.writeStringField('Creative End Date', VRFCallouts.dateCoalesce(creative.Creative_End_Date__c));
            gen.writeEndObject();

            creativeIdList.add(creative.id);
        }

        gen.writeEndArray();
        gen.writeEndObject();
        gen.close();    

        String jsonString = gen.getAsString();
        Log('Process Builder Json ' + jsonString);  

        SendData(creativeIdList, jsonString);
    }

    @future(callout=true)
    private static void SendData(List<string> creatliveIds, string json){

        try {
            
            String url = getRevisionURL();

            Log('Process Builder Url: ' + url);
 
            Http http           = new Http();
            HttpRequest request = new HttpRequest();
            String omsApiKey = System.Label.OmsApiKey;
            request.setEndpoint(url);
            request.setTimeout(120000);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'text/plain');
            request.setHeader('OmsApiKey', omsApiKey);
            request.setHeader('accept', 'application/json');
            request.setBody(json);

            HttpResponse response = http.send(request);

            if(Test.isRunningTest()){
                if (setStatusTo200 == true){
                    response.setStatusCode(200);
                }else{
                    response.setStatusCode(400);
                }
            }

           VRFUtility utility;

           if (response.getStatusCode() != 200) {

                string message = response.getStatusCode() + ' ' + response.getBody() +  ' on ' + url + ' \n \n' + json;
                Log('Process Builder Error: ' + message);
                SendEmailMessageToAdmins('Process Builder Error : 48 Digital Ops Date Revision In Progress', url +  '\n\n\n\n' + json + '\n\n\n\n' + message);
                utility  = new VRFUtility(creatliveIds, 'Process Builder Error: ' +   response.getStatusCode());
    
            } else {
                Log('Process Builder Middleware Response ' + response.getStatusCode());
                utility  = new VRFUtility(creatliveIds);
              
            }

           System.enqueueJob(utility);

        } catch (Exception ex) {
            Log('Processer Builder Error: ' + ex.getMessage());
            SendEmailMessageToAdmins('Process Builder Error : ',  ex.getMessage());
        }

    }

    @TestVisible
    private static string getRevisionURL(){

        List<VRF_Settings__c> vrfSetting = [SELECT Value__c 
                                            FROM VRF_Settings__c
                                            WHERE Category__c = 'vrf_revision_endpoint' LIMIT 1 ];

        if (vrfSetting.size() > 0){
            return vrfSetting[0].Value__c;
        }

        return '';
    }

    public static void SendEmailMessageToAdmins(string title, string message){

        List<VRF_Settings__c> settings = [SELECT Value__c  
                                          FROM VRF_Settings__c 
                                          WHERE Category__c =: 'adminEmail'];

        List<string> emailList = new List<string>();

        for (VRF_Settings__c email : settings){
            emailList.Add(email.Value__c);
        }
        if(!emailList.isEmpty()){
            EmailHelper.sendEmailToListOfUsers(emailList, title, message);
        }
    }

    @TestVisible
    private static void Log(string log){
        System.Debug(log);
    }

}