/*
    Author               :  M & S
    Date                 :  Sep 09-19
    Description          :  Helper Class to prepare JSON data for OMS system. 
                            Update Zip Code Information into Digital_Campaign__c.Zip_Codes__c from Lightning Component input
    Modification History : 
*/
public with sharing class OMSHelper {
    
 
    //Preparing DC Json data for middleware
    public static string prepareJSONDataToOMS(Digital_Campaign__c dc){
        System.debug('dc is coming in prepareJSONDataToOMS ::: ' + dc);
        System.debug('dc.Total_Impressions__c ::: ' + dc.Total_Impressions__c);

      JSONGenerator gen = JSON.createGenerator(false); 
      
        gen.writeStartObject();
            gen.writeStringField('DcId', OMSHelper.stringCoalesce(dc.id));
            gen.writeStringField('DigitalCampaignName', OMSHelper.stringCoalesce(dc.Name));
            gen.writeStringField('ProposalId', OMSHelper.stringCoalesce(dc.Proposal__c));
            gen.writeStringField('DcRecordType', OMSHelper.stringCoalesce(dc.RecordTypeId));
            gen.writeStringField('RecordTypeName', OMSHelper.stringCoalesce(dc.RecordType.Name));
            gen.writeStringField('Status', OMSHelper.stringCoalesce(dc.Status__c));
            gen.writeStringField('SfAdvertiserId', OMSHelper.stringCoalesce(dc.Advertiser__c));    
            gen.writeStringField('AdvertiserName', OMSHelper.stringCoalesce(dc.Advertiser__r.Name));
            gen.writeStringField('EnterpriseAccountType', OMSHelper.stringCoalesce(dc.Opportunity__r.Enterprise_Account_Type__c));
            gen.writeStringField('SfAgencyId', OMSHelper.stringCoalesce(dc.Agency__c));
            gen.writeStringField('AgencyName', OMSHelper.stringCoalesce(dc.Agency__r.Name));
            gen.writeStringField('RepFirmId', OMSHelper.stringCoalesce(dc.Opportunity__r.Rep_Firm__c));
            gen.writeStringField('RepFirmName', OMSHelper.stringCoalesce(dc.Rep_Firm_Text__c));
            gen.writeStringField('ProductTypes', OMSHelper.stringCoalesce(dc.Product_Type__c));
           
            gen.writeStringField('ProgramType', OMSHelper.stringCoalesce(dc.Program_Type__c));
            gen.writeStringField('DaysofWeek', OMSHelper.stringCoalesce(dc.Day_of_Week__c));
            gen.writeStringField('ContentType', OMSHelper.stringCoalesce(dc.Content_Type__c));
            gen.writeStringField('TIGNetwork', OMSHelper.stringCoalesce(dc.TIG_Network__c));//TIG C
            gen.writeStringField('AdvanceCustomization', OMSHelper.stringCoalesce(dc.Advanced_Customizations__c));
            gen.writeStringField('Season', OMSHelper.stringCoalesce(dc.Season__c));
            gen.writeStringField('Episode', OMSHelper.stringCoalesce(dc.Episode__c));
            gen.writeBooleanField('LiveInTelecast', dc.Live_In_Telecast__c);
           // gen.writeStringField('DaysofWeek', OMSHelper.stringCoalesce(dc.Live_In_Telecast__c));
             
            gen.writeStringField('ProductVendor', OMSHelper.stringCoalesce(dc.Product_Vendor__c));
            gen.writeStringField('DCUniqueRecordId', OMSHelper.stringCoalesce(dc.Digital_Campaign_ID__c));
            gen.writeStringField('TIMId', OMSHelper.stringCoalesce(dc.TIM_ID__c));
        	gen.writeStringField('PilotOrderID', OMSHelper.stringCoalesce(dc.Pilot_Order_ID__c));
            gen.writeStringField('CampaignName', OMSHelper.stringCoalesce(dc.Campaign_Name__c));
            gen.writeStringField('CampaignStartDate', OMSHelper.dateCoalesce(dc.Campaign_Start_Date__c));
            gen.writeStringField('CampaignEndDate', OMSHelper.dateCoalesce(dc.Campaign_End_Date__c));
        	gen.writeBooleanField('Preemptable', dc.Preemptable__c);
        	gen.writeBooleanField('TIGActivated', dc.TIG_Activated__c);
        	gen.writeStringField('TimeZones', OMSHelper.stringCoalesce(dc.Time_Zones__c));
        	gen.writeStringField('FrequencyCap', OMSHelper.stringCoalesce(dc.Frequency_Cap__c));
			gen.writeStringField('AudienceTrakProposalID', OMSHelper.stringCoalesce(dc.AudienceTrak_Proposal_ID__c));
        	gen.writeStringField('DataCatalog', OMSHelper.stringCoalesce(dc.Data_Catalog__c));
       		if(dc.Data_Catalog__c != null && (dc.Data_Catalog__c.contains('Custom|Custom 2') || dc.Data_Catalog__c.contains('Custom|Custom 1') || dc.Data_Catalog__c.contains('Custom|Custom 3') || dc.Data_Catalog__c.contains('Custom|Custom'))){
            	gen.writeStringField('AudienceProfile', OMSHelper.stringCoalesce(dc.Audience_Profile__c));
        	}
        	gen.writeStringField('ExportKeyLogic', OMSHelper.stringCoalesce(dc.Export_Key_Logic__c));
        	gen.writeBooleanField('AdvancedReporting', dc.Advanced_Reporting__c);
            Decimal totalImpressions = dc.Total_Impressions__c == null ? 0 : dc.Total_Impressions__c;
            System.debug('totalImpressions in generateor :::: '  + totalImpressions);
        	gen.writeNumberField('TotalImpressions', totalImpressions); 
        	Decimal makegoodImpressions = (dc.Makegood_Impressions__c == null) ? 0 : dc.Makegood_Impressions__c;
            gen.writeNumberField('MakegoodImpressions', makegoodImpressions); 

            

            if (dc.Gross_CPM1__c == null){
                gen.writeNumberField('GrossCpmDollars', 0); 
            } else{
                gen.writeNumberField('GrossCpmDollars', dc.Gross_CPM1__c); //dc.Gross_CPM__c
            }
        
            if (dc.Gross_Campaign_Cost__c == null){
                gen.writeNumberField('GrossCampaignCost', 0); 
            } else{
                gen.writeNumberField('GrossCampaignCost', dc.Gross_Campaign_Cost__c); //dc.Gross_Campaign_Cost__c
            }
        	if (dc.Makegood_Campaign_CPM__c == null){
                gen.writeNumberField('MakegoodCampaignCPM', 0); 
            } else{
                gen.writeNumberField('MakegoodCampaignCPM', dc.Makegood_Campaign_CPM__c); //dc.Makegood_Campaign_CPM__c
            }
            if (dc.Makegood_CPM__c == null){
                    gen.writeNumberField('MakegoodCPM', 0); 
            } else{
                gen.writeNumberField('MakegoodCPM', dc.Makegood_CPM__c); //dc.Makegood_CPM__c
            }
        
            gen.writeStringField('RateClassifications', OMSHelper.stringCoalesce(dc.Rate_Classification__c));
            gen.writeStringField('VastTag', OMSHelper.stringCoalesce(dc.VAST_Tag__c));
        
            //Added by M&S for SRSF-2147 on 5th Jun-2020
            String platforms = '';
            if(dc.Is_Freewheel_FF_OTT_Primary__c)
                platforms = OMS_MiddlwareController.OTTExtensionVal+';';
            else
                platforms = OMSHelper.stringCoalesce(dc.AdsE_Platform_s__c);
            gen.writeStringField('AdsePlatforms', platforms);
        
            gen.writeStringField('AdseGenres', OMSHelper.stringCoalesce(dc.AdsE_Genre_s__c ));
            gen.writeBooleanField('KidsNetworkExclusion', dc.Kids_Network_Exclusion__c);
        	gen.writeBooleanField('NewsNetworkExclusions', dc.News_Network_Exclusions__c);
            gen.writeBooleanField('TuneInExclusions', dc.Tune_In_Exclusions__c);
        	gen.writeBooleanField('FullAvailCampaign', dc.Full_Avail_Campaign__c);
            gen.writeStringField('AdseNetworks',  OMSHelper.stringCoalesce(dc.AdsE_Network__c));
        	gen.writeStringField('ExcludeNetworks', OMSHelper.stringCoalesce(dc.Exclude_Networks__c));

            gen.writeStringField('SalesPersonId', OMSHelper.stringCoalesce(dc.OwnerId));


            gen.writeStringField('SalesPersonFName',   cleanseFirstName(dc.Owner.FirstName));
            gen.writeStringField('SalesPersonLName', OMSHelper.stringCoalesce(dc.Owner.LastName));
            gen.writeStringField('SalesPersonEmail', OMSHelper.stringCoalesce(dc.Owner.Email));
            gen.writeStringField('SalesOffice', OMSHelper.stringCoalesce(dc.Sales_Office__c));
            gen.writeStringField('LastModifiedBy', OMSHelper.stringCoalesce(dc.LastModifiedById));
            gen.writeStringField('LastModifiedByName', OMSHelper.stringCoalesce(dc.LastModifiedBy.Name));
            gen.writeStringField('SpectrumReachZones', OMSHelper.stringCoalesce(dc.Spectrum_Reach_Zones__c));
           // gen.writeStringField('CongressionalDistricts', OMSHelper.stringCoalesce(dc.Congressional_Districts__c));
            gen.writeStringField('States', OMSHelper.stringCoalesce(dc.State__c));
            
            Boolean isZipCodeCheck = dc.CustomZipCode__c;
            
            string dma =  (isZipCodeCheck) ?   '' : OMSHelper.stringCoalesce(dc.DMAs__c);      

            gen.writeStringField('DMAs', dma);

            string zipCodes = (isZipCodeCheck) ? OMSHelper.stringCoalesce(dc.Zip_Codes__c) : '';        
            gen.writeStringField('ZipCodes', zipCodes);
           

          //  System.debug('Advertiser__c: ' + dc.Advertiser__c);
 			//SRSF - 4523 - Get Eclipse ID and System from the Digital Campaign rather than the Traffic Data 
            
            //string eclipseCustomerId = (dc.Advertiser__c != null) ? getEclipseInstanceAndId(OMSHelper.stringCoalesce(dc.Advertiser__c)) : '';
           // gen.writeStringField('EclipseCustomerId', eclipseCustomerId);
             //4523 New Changes for eclipseId  
            string newEclipseID = OMSHelper.stringCoalesce(dc.Eclipse_Customer_ID__c);
            string updatedEclipseID = '';
             System.debug('newEclipseID: ' + newEclipseID);
            List<String> eclipseList = new List<String>();
            if(newEclipseID.indexOf('|') > 0)
             eclipseList = newEclipseID.split('\\|');
            System.debug('eclipseList: ' + eclipseList);
            if(eclipseList.size() > 0)
            {
                for(String eclipse: eclipseList)
                {
                    String eclipseID = eclipse.indexOf('\t') > 0 ? eclipse.replaceAll('\t', '-').replaceAll(' ','') : eclipse.trim().replaceAll('\\s+', '-');
                    updatedEclipseID = string.isNotEmpty(updatedEclipseID) ? updatedEclipseID + ' ; ' + eclipseID: eclipseID;
                }
            }
            else
            {
                updatedEclipseID = OMSHelper.stringCoalesce(dc.Eclipse_Customer_ID__c);
                updatedEclipseID = updatedEclipseID.indexOf('\t') > 0 ? updatedEclipseID.replaceAll('\t', '-').replaceAll(' ','') : updatedEclipseID.replaceAll('\\s+', '-');
            }
            System.debug('newEclipseID: ' + updatedEclipseID);
        System.debug('newEclipseID: ' + newEclipseID);
            gen.writeStringField('EclipseCustomerId', updatedEclipseID);
            // End Of Change

            gen.writeStringField('TIMSystem', OMSHelper.stringCoalesce(dc.Proposal__r.TIM_System__c));
            gen.writeStringField('TrafficOrderNumber', OMSHelper.stringCoalesce(dc.Proposal__r.Traffic_Order_Number__c));
            gen.writeBooleanField('AdvertiserPolitical', dc.Advertiser__r.Political_Account__c);
            
            gen.writeBooleanField('IsLegacy', dc.Streaming_TV_Old_Process__c);
            gen.writeStringField('EfficiencyPackages', OMSHelper.stringCoalesce(dc.Efficiency_Packages__c));
        	gen.writeStringField('DeviceExclusions', OMSHelper.stringCoalesce(dc.Device_Exclusions__c));
        
            gen.writeFieldName('InventorySources');
            gen.writeStartArray();
        
        	//Get ProfileName of  digital campaign createdby user 
        	String profileName = [Select id,profile.name FROM user WHERE id=:dc.createdbyid limit 1].profile.name;
        
         //SRSF-4473 :  pass the cpm and Total impression values to operative push.
            for(Inventory_Source__c objIS :dc.Inventory_Sources__r){
                if(objIS.Inventory_Resource_Type__c == 'Freewheel-O&O/Affiliate/Direct' && (dc.Source__c =='Audience Track' || dc.Source__c=='SPP' || 	profileName == 'Integration User')){
                    if(objIS.CPM_Gross__c == null ){
                        objIS.CPM_Gross__c = dc.Gross_CPM1__c;   
                    }
                    if(objIS.COST_Gross__c == null ){
                        objIS.COST_Gross__c = dc.Gross_Campaign_Cost__c;   
                    }
                        if(objIS.Impressions__c == null ){
                        objIS.Impressions__c = dc.Total_Impressions__c;   
                    }
                }


                gen.writeStartObject();
                gen.writeStringField('SourceName', stringCoalesce(objIS.Inventory_Resource_Type__c));
                gen.writeStringField('StartDate', dateCoalesce(objIS.Campaign_Start_Date__c));
                gen.writeStringField('EndDate', dateCoalesce(objIS.Campaign_End_Date__c));
                gen.writeStringField('SfdcDcType', stringCoalesce(objIS.SFDC_DC_Type__c));
                gen.writeStringField('Audience', stringCoalesce(objIS.Audience__c));
                gen.writeStringField('GeoTargetType', stringCoalesce(objIS.Geo_Target_Type__c));
                gen.writeStringField('Exclusions', OMSHelper.stringCoalesce(objIS.Exclusions__c));
                Decimal Impress = (objIS.Impressions__c == null) ? 0 : objIS.Impressions__c;
                Integer Impressions = Integer.valueOf(Impress);
                gen.writeNumberField('Impressions', Impressions); 
                Decimal CPMGross = (objIS.CPM_Gross__c == null) ? 0 : objIS.CPM_Gross__c;
                gen.writeNumberField('CPM', CPMGross);
                Decimal CostGross = (objIS.CPM_Gross__c == null) ? 0 : objIS.CPM_Gross__c;
                gen.writeNumberField('Cost', CostGross);
                gen.writeStringField('LineItemIds', '');
                gen.writeEndObject();
            }
            gen.writeEndArray();
            gen.writeEndObject();
      
            gen.close();
            String jsonString = gen.getAsString();
        	System.debug('jsonString::'+jsonString);
            return jsonString;
    }

    @TestVisible
    private static string cleanseFirstName(string firstname){

        string result = OMSHelper.stringCoalesce(firstname);
        string fname = result.trim();
        return  (fname == '') ? 'UNKNOWN' : fname;
    } 

    
    @TestVisible
    private static string getEclipseInstanceAndId(string accountId){

            if (accountId == '' || accountId  == null){
                 return '';
            }

            List<Traffic_Id_Element__c> trafficeElement = [SELECT ExportSystem_Name__c, Traffic_Id__c  FROM Traffic_Id_Element__c 
                                                           WHERE Account__c  =: accountId];

            if (trafficeElement.size() == 0){
                return '';
            }

            Set<string> eclipse = new Set<String>();


            for(Traffic_Id_Element__c elm : trafficeElement){
                eclipse.add(elm.ExportSystem_Name__c + '-' + elm.Traffic_Id__c);    
            }

            return String.join(new List<String>(eclipse), ';');
    }


    //send Agency and Advertiser info. to OMS
    @future (callout=true)
    public static void SendData(String strLstId){
       System.debug('strLstId::'+strLstId);
       list<string> lstDCId = strLstId.split(','); 
       list<Digital_Campaign__c> lstDC = [select Id,Name,
                                          Advertiser__c,Advertiser__r.Name,
                                          Campaign_Name__c,
                                          Agency__c,Agency__r.Name,
                                          Opportunity__r.Rep_Firm__c, Opportunity__r.Rep_Firm__r.Name 
                                         from Digital_Campaign__c where id in :lstDCId];
       string payload = GetJSONPayLoad(lstDC);
     //  String strResponseMsg = SendToMiddleware(payload);
    }

    //Preparing JSON Agency, Advertiser, Repfirm data for Middleware
    @TestVisible
    private static string GetJSONPayLoad(list<Digital_Campaign__c> dcList){

      JSONGenerator gen = JSON.createGenerator(false); 
      for(Digital_Campaign__c  dcc : dcList){
          gen.writeStartObject();
      
          gen.writeStringField('Digital Campagin ID', OMSHelper.stringCoalesce(dcc.id));
          gen.writeStringField('Name', OMSHelper.stringCoalesce(dcc.Name));
          gen.writeStringField('Advertiser', OMSHelper.stringCoalesce(dcc.Advertiser__c));    
          gen.writeStringField('Advertiser Name', OMSHelper.stringCoalesce(dcc.Advertiser__r.Name));  
          gen.writeStringField('Campaign Name', OMSHelper.stringCoalesce(dcc.Campaign_Name__c));  
          gen.writeStringField('Agency', OMSHelper.stringCoalesce(dcc.Agency__c));
          gen.writeStringField('Agency Name', OMSHelper.stringCoalesce(dcc.Agency__r.Name));
          gen.writeStringField('Repfirm', OMSHelper.stringCoalesce(dcc.Opportunity__r.Rep_Firm__c));
          gen.writeStringField('Repfirm Name', OMSHelper.stringCoalesce(dcc.Opportunity__r.Rep_Firm__r.Name));      
          gen.writeEndObject();
      }
      gen.close();  
      return gen.getAsString();
    }

    @TestVisible
    private static string Get15DigitId(string id){

       string dccid =  OMSHelper.stringCoalesce(id);

       if (dccid.length() > 15){
            return dccId.substring(0,15);
       }

        return dccid;

    }

    //Sending the data to Middleware
    public static string SendToMiddleware(string json){
        String url;  
        list<OMS_Settings__c> lstOMS =OMS_Settings__c.getall().values();
        if(lstOMS!=null && !lstOMS.isEmpty())
            url = lstOMS[0].Endpoint_URL__c;
        if(Test.isRunningTest())
            url = 'test.com';   
        
        Http http           = new Http();
        HttpRequest request = new HttpRequest();
        String omsApiKey = System.Label.OmsApiKey;
        request.setEndpoint(url);
        request.setTimeout(120000);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/plain');
        request.setHeader('OmsApiKey', omsApiKey);
        request.setBody(json);
       
        HttpResponse response = new HttpResponse();
        if(!Test.isRunningTest())
            response = http.send(request);


        String message='';
        if (response.getStatusCode() != 200 || response.getStatusCode() != 400) {       
             message = response.getStatusCode() + ' ' + response.getBody() + ' on ' + url;
            System.debug('OMS Middleware Response ' + message +  '\n \n' + json);
        } else {
             message = '200 Success';
            System.debug('Middleware Response ' + response.getBody());
        }
        return message;
    }

    public static string stringCoalesce(string input){
        return input == null ? '' :  input.replaceAll('\'', '\'');
    }

    public static string dateCoalesce(date input){
        return input == null ? '' : input.format();
    }

    public static Boolean validateEmail(String email) {
            
        Boolean res = true;

        // source https://www.regular-expressions.info/email.html 
        String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})'; 
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);

        if (!MyMatcher.matches()) 
            res = false;
        return res; 
    }


    
    public static OMS_NetworkValidationClass getInvalidNetworks(List<String> selecteNetworks){

        OMS_NetworkValidationClass omsValidationClass = new OMS_NetworkValidationClass();
        omsValidationClass.isValid = true;

        List<string> invalidNetworks        = new List<string>();
        List<Networks__c> lstNetworks       = [SELECT id, Name, ActiveNetwork__c, LastModifiedDate, LastModifiedBy.Name FROM Networks__c  ORDER BY Name limit 50000];               
        Map<string, Networks__c> activeNetworks  = new Map<string, Networks__c>();
        Map<string, Networks__c> inActiveNetwork = new Map<string, Networks__c>();

        List<string> inactiveNetworkLogList = new List<string>();

        if (lstNetworks.size() > 0){

            for(Networks__c network : lstNetworks){
                if (network.ActiveNetwork__c){
                    activeNetworks.put(network.Name.trim(), network);
                }
                else{
                    inActiveNetwork.put(network.Name.trim(), network);
                }      
            }

            List<string> invalidNetworkList     = new List<string>();
            List<string> inactiveNetworkList    = new List<string>();
            Networks__c networkObj; 

            for(String network : selecteNetworks){
         
                networkObj = activeNetworks.get(network.trim());
                if (networkObj == null){

                    networkObj = inActiveNetwork.get(network.trim());
                    if (networkObj != null){
                        inactiveNetworkList.add(networkObj.Name);
                        inactiveNetworkLogList.add(networkObj.Name + '  Modified by ' + networkObj.LastModifiedBy.Name + ' on ' +  networkObj.LastModifiedDate.format('yyyy-MM-dd \'T\' HH:mm:ss z'));
                    }else{
                        invalidNetworkList.add(network);
                    }
                }
              
            }
               
            omsValidationClass.InvalidNetworks     = invalidNetworkList;
            omsValidationClass.InActiveNetworks    = inactiveNetworkList;
            omsValidationClass.InActiveNetworksLog = inactiveNetworkLogList;

            System.debug('InActive Networks Size: ' +  omsValidationClass.InActiveNetworks.size());
            System.debug('Invalid Network Size: ' +omsValidationClass.InvalidNetworks.size());

            if (omsValidationClass.InvalidNetworks.size() > 0 || omsValidationClass.InActiveNetworks.size() > 0){
                omsValidationClass.isValid = false;
            }
     
            System.debug('Invalid: ' +  omsValidationClass.isValid);
            System.debug('Invalid Networks: ' + omsValidationClass.InvalidNetworks);
            System.debug('InActive Networks: ' + omsValidationClass.InActiveNetworks);
            System.debug('InActive Networks Log Networks: ' + omsValidationClass.InActiveNetworksLog);
                  
        }

        return omsValidationClass;
    }

    public static List<string> validNetworks(OMS_NetworkValidationClass networkvalidation, List<String> lstSelectedNetworks){

        Set<String> setSelectedNetworks = new Set<string>();
        setSelectedNetworks.addAll(lstSelectedNetworks);

        for(string network : lstSelectedNetworks){
            if (networkvalidation.InvalidNetworks.contains(network)){
                setSelectedNetworks.remove(network);
            }

            if (networkvalidation.InActiveNetworks.contains(network)){
                setSelectedNetworks.remove(network);
            }
        }
        
     
        List<string> validNetworks = new List<string>();
        validNetworks.addAll(setSelectedNetworks);


        return validNetworks;
    }

    public static List<String> getInvalidNetworksBysGenre(Digital_Campaign__c dc){

        List<string> selectedNetworkList = new List<string>();

        selectedNetworkList  = dc.AdsE_Network__c.split(';');
        String selectedGenre = dc.AdsE_Genre_s__c;

            
        List<Networks__c> networks = [SELECT Name, 
                                            AdsE_Genre_s__c 
                                        FROM Networks__c WHERE AdsE_Genre_s__c INCLUDES (:selectedGenre)]; 
    
        List<String> networkList = new List<String>(); 

        for(Networks__c network : networks){
            if (selectedNetworkList.contains(network.Name)){
                Integer index = selectedNetworkList.indexOf(network.Name);
                selectedNetworkList.remove(index);
            }
        }

        System.debug('Selected Network left over size : ' + selectedNetworkList.size());


        return selectedNetworkList;
     
    }

    public static List<String> getCleanInvalidNetworks(List<string> invalidNetworks,  List<String> lstSelectedNetworks){

        List<string> validNetworks = new List<String>();

        for(String network : invalidNetworks){

            if (lstSelectedNetworks.contains(network)){
                Integer index = lstSelectedNetworks.indexOf(network);
                lstSelectedNetworks.remove(index);
            }
        }

        validNetworks = lstSelectedNetworks;

        return validNetworks;

    }

    public static List<string> GetListOfFligthEndDates(string fligthDateArray){

        List<string> fligtDateEndDate = new List<string>();

        if (fligthDateArray == null) return  fligtDateEndDate;

        List<string> flightDateList   = fligthDateArray.split(';');
    
        for(string dates : flightDateList){
             List<string> fligthDates = dates.split(':');

             try {
                fligtDateEndDate.add(fligthDates[1]);   
             } catch (Exception ex) {
                fligtDateEndDate.add('');
             }             
        }

        return fligtDateEndDate;
    }


   public static List<string> GetListOfFligthStartDates(string fligthDateArray){

        List<string> fligtDateStartDate = new List<string>();

        if (fligthDateArray == null) return  fligtDateStartDate;

        List<string> flightDateList   = fligthDateArray.split(';');
    
        for(string dates : flightDateList){
             List<string> fligthDates = dates.split(':');

             try {
                fligtDateStartDate.add(fligthDates[0]);   
             } catch (Exception ex) {
                fligtDateStartDate.add('');
             }             
        }

        return fligtDateStartDate;

   }
    
    public static List<Date> ConvertoDateSorted(List<string> dateList){

        List<date> validDateList = new List<date>();

        for(string dateValue : dateList){
            try {
                validDateList.add(date.valueof(dateValue));
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }
        }

        validDateList.sort();

        return validDateList;
    }

}