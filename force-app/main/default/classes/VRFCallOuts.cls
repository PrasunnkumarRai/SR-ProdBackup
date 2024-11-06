public with sharing class VRFCallOuts  {
   

    public VRFResponseClass ProcessVRFData(string creativeId, string vrfClientId, string spotId){
     
        VRFResponseClass vrfResponse = new VRFResponseClass();
        String json           = CreateJson(creativeId, spotId, vrfClientId, false); 
        HttpResponse response = PostVRFMessage(creativeId, json); 

        Log('Json Value ' + response.getBody());

        vrfResponse.StatusCode = response.getStatusCode();

        if (response.getStatusCode() == 200){
            VRFClass vrfClass    = (VRFClass)System.JSON.deserialize(response.getBody(), VRFClass.class);
            vrfClass.SpotId      = spotId;
            vrfClass.VrfClientId = vrfClientId;
            Log('SD ' + vrfClass.SdAssetId);
            Log('HD ' + vrfClass.HdAssetId);
          
            UpdateVrf(creativeId, vrfClass);  

            vrfResponse.Message = response.getBody();
            vrfResponse.isSuccessfull = true;

        }else if (response.getStatusCode() == 409){
            vrfResponse.Message = response.getBody();
            vrfResponse.isSuccessfull = true;       
        }
        else{
            vrfResponse.Message = response.getBody();
            vrfResponse.isSuccessfull = false;             
        }

        return vrfResponse;
    }

    public static string CreateJson(string creativeId, string spotId, string vrfClientId, Boolean formatted){

      Log('=========== Start PostVRF Method ===========');

      JSONGenerator gen = JSON.createGenerator(formatted); 

      Digital_Creative__c dcc = [SELECT Id, 
                                 VRF_Client_Id__c,
                                 Status__c, 
                                 SD_AssetId__c,
                                 HD_AssetId__c,
                                 Creative_Name__c, 
                                 Spot_ID_if_needed__c, 
                                 Digital_Campaign_Start_Date__c, 
                                 Digital_Campaign_End_Date__c, 
                                 Creative_Start_Date__c,                      
                                 Creative_End_Date__c, 
                                 Advertiser_Name__c,
                                 TIM_ID_Form__c,
                                 Account_Executive__r.Name,
                                 Campaign_Name__c,
                                 Agency_Name_Form__c,
                                 First_Look__c,
                                 Sales_Office__c,
                                 Region__c,
                                 Division__c,
                                 Digital_Priority_Campaign__c,
                                 Digital_Campaign__c,
                                 DCC_Unique_Record_ID__c,
                                 Creative_Ready_for_Trafficking__c,
                                 Creative_Notes__c,
                                 Campaign_Status__c,
                                 Campaign_Record_Type__c,
                                 Digital_Campaign__r.Opportunity__r.Account.Name,
                                 X1x1_Pixel_Placement_ID__c,
                                 Click_Through_URL__c,
                                 Creative_Type__c,
                                 Pilot_Order_ID__c,
                                 Enterprise_Account_Type__c,
                                 Vast_Tag_2_0_Line_1__c,
                                 Vast_Tag_2_0_Line_2__c,
                                 Vast_Tag_2_0_Line_3__c,
                                 Vast_Tag_2_0_Line_4__c,
                                 Vast_Tag_2_0_Line_5__c,
                                 Vast_Tag_2_0_Line_6__c,
                                 Vast_Tag_2_0_Line_7__c,
                                 Vast_Tag_3_0_Line_1__c,
                                 Vast_Tag_3_0_Line_2__c,
                                 Vast_Tag_3_0_Line_3__c,
                                 Vast_Tag_3_0_Line_4__c,
                                 Vast_Tag_3_0_Line_5__c,
                                 Vast_Tag_3_0_Line_6__c,
                                 Vast_Tag_3_0_Line_7__c,
                                 Vast_Tag_Enabled__c
                                // VAST_Tag__c
                                 FROM Digital_Creative__c
                                 WHERE id =: creativeId];

        string orderPrefix = GetOrderPrefix(dcc);

        gen.writeStartObject();
        gen.writeStringField('DCC id', stringCoalesce(dcc.id));

        string clientId =  (vrfClientId == '') ? stringCoalesce(dcc.VRF_Client_Id__c ) : vrfClientId;
        
        gen.writeStringField('VRF Client ID', clientId);   
        gen.writeStringField('Status', stringCoalesce(dcc.Status__c));
        gen.writeStringField('ISCI', stringCoalesce(dcc.Creative_Name__c));
        gen.writeStringField('Spot ID', stringCoalesce(dcc.Spot_ID_if_needed__c));
        gen.writeStringField('VRF Spot ID', stringCoalesce(spotId));
        gen.writeStringField('Campaign Start date', dateCoalesce(dcc.Digital_Campaign_Start_Date__c));
        gen.writeStringField('Campaign End date', dateCoalesce(dcc.Digital_Campaign_End_Date__c));
        gen.writeStringField('Flight Start Date', dateCoalesce(dcc.Creative_Start_Date__c));
        gen.writeStringField('Flight End Date', dateCoalesce(dcc.Creative_End_Date__c));
        gen.writeStringField('Client Name', stringCoalesce(dcc.Digital_Campaign__r.Opportunity__r.Account.Name));
        gen.writeStringField('TIM Number', stringCoalesce(dcc.TIM_ID_Form__c));
        gen.writeStringField('Pilot Order ID', stringCoalesce(dcc.Pilot_Order_ID__c));
        gen.writeStringField('AssetID prefix', stringCoalesce(orderPrefix));
        gen.writeStringField('Account Executive', stringCoalesce(dcc.Account_Executive__r.Name));
        gen.writeStringField('Campaign Name', stringCoalesce(dcc.Campaign_Name__c));
        gen.writeStringField('Agency Name', stringCoalesce(dcc.Agency_Name_Form__c));
        gen.writeBooleanField('First Look', dcc.First_Look__c);
        gen.writeStringField('Sales Office', stringCoalesce(dcc.Sales_Office__c));
        gen.writeStringField('Region', stringCoalesce(dcc.Region__c));  
        gen.writeStringField('Division', stringCoalesce(dcc.Division__c));  
        gen.writeBooleanField('Priority', dcc.Digital_Priority_Campaign__c);  
        gen.writeStringField('Campaign', stringCoalesce(dcc.Digital_Campaign__c)); 
        gen.writeStringField('DCC Unique Record ID', stringCoalesce(dcc.DCC_Unique_Record_ID__c)); 
        gen.writeBooleanField('Creative Ready for Trafficking', dcc.Creative_Ready_for_Trafficking__c); 
        gen.writeStringField('Creative Notes', stringCoalesce(dcc.Creative_Notes__c)); 
        gen.writeStringField('Campaign Status', stringCoalesce(dcc.Campaign_Status__c)); 
        gen.writeStringField('Campaign Record Type', stringCoalesce(dcc.Campaign_Record_Type__c));         
        gen.writeStringField('1x1 Pixel Placement ID', stringCoalesce(dcc.X1x1_Pixel_Placement_ID__c));
        gen.writeStringField('Click Through URL', stringCoalesce(dcc.Click_Through_URL__c));
        gen.writeStringField('Enterprise Account Type', stringCoalesce(dcc.Enterprise_Account_Type__c));
        gen.writeStringField('Creative Type', stringCoalesce(dcc.Creative_Type__c));
        //gen.writeStringField('VAST Tag', stringCoalesce(dcc.VAST_Tag__c));
        gen.writeStringField('Vast Tag 2.0 Line 1', stringCoalesce(dcc.Vast_Tag_2_0_Line_1__c));
        gen.writeStringField('Vast Tag 2.0 Line 2', stringCoalesce(dcc.Vast_Tag_2_0_Line_2__c));
        gen.writeStringField('Vast Tag 2.0 Line 3', stringCoalesce(dcc.Vast_Tag_2_0_Line_3__c));
        gen.writeStringField('Vast Tag 2.0 Line 4', stringCoalesce(dcc.Vast_Tag_2_0_Line_4__c));
        gen.writeStringField('Vast Tag 2.0 Line 5', stringCoalesce(dcc.Vast_Tag_2_0_Line_5__c));
        gen.writeStringField('Vast Tag 2.0 Line 6', stringCoalesce(dcc.Vast_Tag_2_0_Line_6__c));
        gen.writeStringField('Vast Tag 2.0 Line 7', stringCoalesce(dcc.Vast_Tag_2_0_Line_7__c));
        gen.writeStringField('Vast Tag 3.0 Line 1', stringCoalesce(dcc.Vast_Tag_3_0_Line_1__c));
        gen.writeStringField('Vast Tag 3.0 Line 2', stringCoalesce(dcc.Vast_Tag_3_0_Line_2__c));
        gen.writeStringField('Vast Tag 3.0 Line 3', stringCoalesce(dcc.Vast_Tag_3_0_Line_3__c));
        gen.writeStringField('Vast Tag 3.0 Line 4', stringCoalesce(dcc.Vast_Tag_3_0_Line_4__c));
        gen.writeStringField('Vast Tag 3.0 Line 5', stringCoalesce(dcc.Vast_Tag_3_0_Line_5__c));
        gen.writeStringField('Vast Tag 3.0 Line 6', stringCoalesce(dcc.Vast_Tag_3_0_Line_6__c));
        gen.writeStringField('Vast Tag 3.0 Line 7', stringCoalesce(dcc.Vast_Tag_3_0_Line_7__c));
        gen.writeBooleanField('Vast Tag Enabled', dcc.Vast_Tag_Enabled__c);
        gen.writeEndObject();
        gen.close();
        
        String jsonString = gen.getAsString();
        Log(jsonString);
    
        Log('=========== Start PostVRF Method ===========');

         return jsonString;
    }
    
    public static HttpResponse PostVRFMessage(string creativeId, string json){
        
        String url = getVRFURL();
        
        Http http           = new Http();
        HttpRequest request = new HttpRequest();
        String omsApiKey = System.Label.OmsApiKey;
        request.setEndpoint(url);
        request.setTimeout(120000);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/plain');
        request.setHeader('OmsApiKey', omsApiKey);
        request.setBody(json);
       
        HttpResponse response = http.send(request);

        if (response.getStatusCode() != 200) {       
            string message = response.getStatusCode() + ' ' + response.getBody() + ' on ' + url;
            Log('Middleware Response ' + message +  '\n \n' + json);
        } else {
            Log('Middleware Response ' + response.getBody());
        }

        return response;
    }

    @TestVisible
    private static string getVRFURL(){

         VRF_Settings__c settings = [SELECT Value__c  
                                     FROM VRF_Settings__c 
                                     WHERE Category__c =: 'vrf_endpoint' 
                                     LIMIT 1];

        Log('VRF Middleware Enpoint: ' + settings.Value__c);

        return settings.Value__c;
    }

    public void UpdateVrf(string creativeId, VRFClass vrfClass){
        Log('=========== Start UpdateVrfId Method ===========');
        Log('Create Id ' + creativeId + ' | vrfClientId ' + vrfClass.VrfClientId  + ' | vrfClass.CreativeUrl ' + vrfClass.CreativeUrl  );

        Digital_Creative__c dcc = [SELECT id,  
                                          VRF_Client_Id__c,
                                          VRF_Spot_ID__c,
                                          HD_AssetId__c,
                                          SD_AssetId__c,
                                          CreativeUrl__c
                                   FROM Digital_Creative__c 
                                   WHERE id=: creativeId];
       string creativeUrl = '';

     /*  for(string url : vrfClass.CreativeUrl){
           creativeUrl += url + '\n';
           Log('Creative Url ' + url);
        }*/

        dcc.VRF_Client_Id__c = vrfClass.VrfClientId;
        dcc.VRF_Spot_ID__c   = vrfClass.SpotId;
        dcc.HD_AssetId__c    = vrfClass.HdAssetId;
        dcc.SD_AssetId__c    = vrfClass.SdAssetId;
      //  dcc.CreativeUrl__c   = creativeUrl;
        dcc.Error_Message__c = null;

        update dcc;
        
        Log('=========== End UpdateVrfId Method ===========');
    }

    public static string stringCoalesce(string input){
        return input == null ? '' :  input.replaceAll('\'', '\'');
    }

    public static Boolean isOrderPrefix99(Digital_Creative__c creativeObj){
        
        string result = GetOrderPrefix(creativeObj);

        if (result == '99'){
            return true;
        }

        return false;
    }

    public static string GetOrderPrefix(Digital_Creative__c dcc){

       Log('Getting Order Prefix with Sales Office:  ' + dcc.Sales_Office__c +  
        ', Region Sales: ' + dcc.Region__c + 
        ', Division: ' + dcc.Division__c );
        
                       
        List<vrf_SalesOffice__c> salesOffice = [SELECT OrderPrefix__c, Sales_Office__c FROM VRF_SalesOffice__c  
                                                WHERE Sales_Office__c =: dcc.Sales_Office__c 
                                                AND Region__c =: dcc.Region__c 
                                                AND Division__c =: dcc.Division__c  
                                                LIMIT 1];


        if (salesOffice.size() > 0){
            Log('Order Prefix is ' + salesOffice[0].OrderPrefix__c);
            string result = String.valueof(salesOffice[0].OrderPrefix__c);
            return result;
        }

        String message = 'Order Prefix for DCC ' + dcc.Id  + ' not found for Divison: ' + dcc.Division__c   + ', Region:  ' +  dcc.Region__c +  ' Sales Office: ' +  dcc.Sales_Office__c;
        Log(message);
     
        return '99';              
    }

    @future(callout=true)
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
    public static string dateCoalesce(date input){
        return input == null ? '' : input.format();
    }
    
    public string CreateStatusJson(string status, string error){

     
      JSONGenerator gen = JSON.createGenerator(false); 

        gen.writeStartObject();
            if(status!=null)
                gen.writeStringField('Status__c', status);

            if (error != null){
                gen.writeStringField('Error_Message__c', error); 
            }

            
        gen.writeEndObject();
        gen.close();  
   
        String jsonString = gen.getAsString();
        Log(jsonString);

        return jsonString;
    }

    @TestVisible
    private static void Log(string log){
        System.Debug(log);
    }

}