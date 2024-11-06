public with sharing class OMS_NetworkExController {
    
    public static Boolean setProfile = false;

    // This 
    public static String SalesProfile   = 'Master - Account Executive';
    public static String PlanInProgress = 'Planning in Progress';
    

    @AuraEnabled(cacheable=true)
    public static string getNetworkMessage(string dcID){
        return getOMSNetworkClass(dcID);
    }

    @AuraEnabled(cacheable=false)
    public static string getCleanseOMSNetworkValues(string dcID){
        return getOMSNetworkClass(dcID);
    }

    //SRSF - 4137
    @AuraEnabled(cacheable=true)
    public static String getImpressionValue(String recId){
        System.debug('****recid****'+recId);
        Decimal impressionValue;
        try {
            List<Inventory_Source__c> invResList =[ Select id,Impressions__c,name,Inventory_Resource_Type__c 
                                                             FROM Inventory_Source__c 
                                                             WHERE  Inventory_Resource_Type__c = 'Simpli.fi-CTV' and Digital_Campaign__c=:recId];
            if(invResList.size()>0){
                impressionValue = invResList[0].Impressions__c;
                System.debug('****impressionValue****'+impressionValue);
            }                                       
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('****impressionValue****'+impressionValue);
        return JSON.serialize(impressionValue);
    }
      //SRSF - 4137

    private static string getOMSNetworkClass(string dcID){

        OMS_NetworkClass omsNetworkClass = new OMS_NetworkClass();

        List<Digital_Campaign__c> dCampaign = [SELECT id, AdsE_Network__c FROM Digital_Campaign__c WHERE id =: dcID];

         omsNetworkClass.SelectedNetworks = new List<string>();
         omsNetworkClass.InActiveNetworks = new List<string>();
         omsNetworkClass.InvalidNetworks  = new List<string>();

        System.debug('dCampaign size ' + dCampaign.size());

        if (dCampaign.size() == 0){
            return JSON.serialize(omsNetworkClass);     
        }

        String AdseNetwork = dCampaign[0].AdsE_Network__c;
        List<string> selecteNetworks = new List<string>();

        if (AdseNetwork != null){
           selecteNetworks = AdseNetwork.split(';');
        }


        omsNetworkClass.SelectedNetworks = selecteNetworks;
  
    
        OMS_NetworkValidationClass networkvalidation = OMSHelper.getInvalidNetworks(selecteNetworks);

        if (!networkvalidation.isValid){

            omsNetworkClass.InActiveNetworks = networkvalidation.InActiveNetworks;
            omsNetworkClass.InvalidNetworks  = networkvalidation.InvalidNetworks;

            System.debug('InActive networks ' + String.join(networkvalidation.InActiveNetworks, ';'));
            System.debug('Invalid networks ' + String.join(networkvalidation.InvalidNetworks, ';'));

           omsNetworkClass.SelectedNetworks = OMSHelper.validNetworks(networkvalidation, selecteNetworks);
        }

    

        return JSON.serialize(omsNetworkClass); 
    }
  


    @AuraEnabled(cacheable=true)
    public static string getAllNetworks() {
  
        NetworkClass networkClass = new networkClass();
        List<AuraSelectOptions> networkOptions = new List<AuraSelectOptions>();
        List<string> kidsNetworks  = new List<string>();
        List<string> tuneInNetworks  = new List<string>();
        List<string> newsNetworks  = new List<string>();
        List<string> networkExSelectedNetwork  = new List<string>();

        List<Networks__c>  networks = [SELECT Id, Name, Call_Letter__c,  Kids_Network_Exclusion__c, Tune_In_Exclusions__c,News_Exclusions__c FROM Networks__c 
                                       WHERE ActiveNetwork__c = true ORDER BY Name];
        List<Networks__c> net = [Select id, Name from Networks__c where ActiveNetwork__c = true AND AdsE_Genre_s__c EXCLUDES ('Selected Networks') ORDER BY Name];
        
        for(Networks__c n : net){
           // networkOptions.add(new AuraSelectOptions(n.Name, n.Name));
			networkExSelectedNetwork.add(n.Name);            
        }

        for(Networks__c network : networks){

            networkOptions.add(new AuraSelectOptions(network.Name, network.Name));

            if (network.Kids_Network_Exclusion__c){
                kidsNetworks.add(network.Name);
            }
            

            if (network.Tune_In_Exclusions__c ){
                tuneInNetworks.add(network.Name);
            }

            if (network.News_Exclusions__c ){
                newsNetworks.add(network.Name);
            }

        }

        networkClass.Networks = networkOptions;
        networkClass.KidsNetworks = kidsNetworks;
        networkClass.TuneInNetworks = TuneInNetworks;
        networkClass.NewsNetworks = newsNetworks;
        networkClass.NetworkExSelectedNetworks = networkExSelectedNetwork;
        return JSON.serialize(networkClass);
    } 

    @AuraEnabled(cacheable=true)
    public static List<string> getNetworksByGenre(List<string> genres) {

        String delimtedValues =  String.join(genres, ';');
        System.debug('Genres ' + delimtedValues);

        string condition = '';

        for(string val : genres) {

            condition += '\''+ val +'\''+',';
        }

        condition = condition.substring(0, condition.length() - 1);

        string query = 'SELECT Id, Name, Call_Letter__c, AdsE_Genre_s__c  FROM  Networks__c WHERE ActiveNetwork__c = true AND AdsE_Genre_s__c INCLUDES (' + condition + ')';

        System.debug('Query ' + query);

        List<Networks__c> networks = (List<Networks__c>)Database.query(query);
        List<string> networkList   = new List<string>();

        for(Networks__c network : networks){
           networkList.add(network.Name);
        }
		System.debug('networkList ' + networkList);
        return networkList;
    }

    @AuraEnabled(cacheable=false)
    public static boolean isSaveEnabled(string id){

        System.debug('DCC Id: ' + id);

        String ProfileName;
        String Status;
       
        List<Digital_Campaign__c> dcc = [SELECT id, Status__c FROM Digital_Campaign__c WHERE id  =: id LIMIT 1];       
        List<User> userObj            = [SELECT Id, Username, Suffix, Profile.Name FROM User WHERE id =: UserInfo.getUserId() LIMIT 1];

        if (dcc.size() > 0){
            Status = dcc[0].Status__c; 
        }

        if (userObj.size() > 0){
            ProfileName = userObj[0].Profile.Name; 
        }

        System.debug('User Profile: ' + ProfileName + ' | ' + ' Status ' +  Status);

        if (ProfileName == SalesProfile && Status == PlanInProgress) {
            return false;
        }

        return true;
    }

    @AuraEnabled(cacheable=false)
    public static boolean isGeoGroupEditable(string id){

      System.debug('DCC Id: ' + id);

      Boolean result = false;
      String dcRTNonAddressableNonPreRoll=System.Label.DC_RTForNonAddressablePreRoll;
      List<string> setdcRTNonAddressableNonPreRoll = new List<string>();
      setdcRTNonAddressableNonPreRoll = dcRTNonAddressableNonPreRoll.split(',');

      List<Digital_Campaign__c> dcc = [SELECT id, Status__c, Operative_Sales_Order_Hyperlink__c,RecordType.DeveloperName FROM Digital_Campaign__c WHERE id  =: id LIMIT 1];       
      List<OMS_Settings__c> oms     = [SELECT Id, Name  FROM OMS_Settings__c WHERE Category__c = 'GeoGroup'];
      Set<string> statuses          = new Set<string>();

        if (dcc.size() > 0){
            
            if (oms.size() > 0){
                
                for(OMS_Settings__c omsStatus : oms){
                    System.debug(omsStatus.Name);
                    statuses.add(omsStatus.Name);
                }
            }
            
            System.debug('DCC Status ' + dcc[0].Status__c);
            
            if(setdcRTNonAddressableNonPreRoll.contains(dcc[0].RecordType.DeveloperName)){
                if(dcc[0].Status__c == '01 Draft Campaign' || dcc[0].Status__c == '11 Sales Revision In Progress'){
                    result = true;
                }else{
                    result = false;
                }
                
            }else{
                result = statuses.contains(dcc[0].Status__c);
            }
             System.debug('Result ' + result);
        }


        return result;
    }

    @AuraEnabled(cacheable=true)
    public static string getPlatformRevision(){

        String result = '';
        List<string> statuses = new List<string>();
        List<OMS_Settings__c> oms = [SELECT id, Value__c FROM OMS_Settings__c WHERE Category__c = 'PlatformEdit'];  

        if (oms.size() > 0){

            for(OMS_Settings__c setting :  oms){
                statuses.add(setting.Value__c);
            }

            result = String.join( statuses, ';' );
        } 

        return result;
     } 

    @AuraEnabled(cacheable=true)
    public static string getAllPlatformsType(){
        
        String result = '';
        List<string> platforms = new List<string>();
        List<OMS_Settings__c> oms = [SELECT id, Value__c FROM OMS_Settings__c WHERE Category__c = 'AllPlatforms'];  

         if (oms.size() > 0){

            for(OMS_Settings__c setting :  oms){
                platforms.add(setting.Value__c);
            }

            result = String.join(platforms, ';' );
        } 

        return result;

    }

    @AuraEnabled(cacheable=false)
    public static Integer getNumberOfDays(string flightDates){


        List<FlightDatesClass> flightDatesClassList = CustomPacing.createFlightDatesObject(flightDates);
        return CustomPacing.getTotalFlightDays(flightDatesClassList, CustomPacing.CalculationType.NORMAL);   

    }


    private static final string DMA_TEXT = 'If no geography is indicated, the GEO will default to 35 mile radius around the Dealership'; 

    /*
        Author               :  M & S
        Date                 :  Jun 07-17
        Description          :  Tp Prepare the list of DMA, Spectrum Reach Zone and Congressional District 
                                Update Zip Code Information into Digital_Campaign__c.Zip_Codes__c from Lightning Component input
        Modification History :  JC Update wrapper class
    */
    @AuraEnabled(cacheable=true)
    public static string getGeographyTargetData(string strDCId){

        Digital_Campaign__c objDC = [Select Id,zip_codes__c, DMAs__c, Spectrum_Reach_Zones__c, 
                                    RecordType.DeveloperName, Opportunity__c,Opportunity__r.OwnerId,
                                    Status__c, Sales_Cannot_Edit_Detail__c, Sales_Cannot_Edit_Status__c
                                    from Digital_Campaign__c where id =: strDCId];


        GeographyTargetClass geoClass = new GeographyTargetClass();
 
        List<string> dmaOptions         =  GeographyTargetClass.getDMA(objDC);// CM_DigitalZipCodesLCController.getDMA();
        List<AuraSelectOptions> dmaList = new List<AuraSelectOptions>();

        for(string option : dmaOptions){
            dmaList.add(new AuraSelectOptions(option, option));
        }

        List<string> zoneOptions         = CM_DigitalZipCodesLCController.getZones();
        List<AuraSelectOptions> zoneList = new List<AuraSelectOptions>();

        for(string option : zoneOptions){
            zoneList.add(new AuraSelectOptions(option, option));
        }

      /*  List<string> congressOptions         = CM_DigitalZipCodesLCController.getCongressionals();
        List<AuraSelectOptions> congressList = new List<AuraSelectOptions>();

        for(string option : congressOptions){
            congressList.add(new AuraSelectOptions(option, option));
        }*/
        
        List<string> timezoneOptions         = GeographyTargetClass.getTimeZones();
        List<AuraSelectOptions> timezoneList = new List<AuraSelectOptions>();

        for(string option : timezoneOptions){
            timezoneList.add(new AuraSelectOptions(option, option));
        }

        geoClass.DMAList      = dmaList;
        geoClass.ZoneList     = zoneList;
       // geoClass.CongressList = congressList;
        geoClass.TimezoneList = timezoneList;
        
        String dcRT=System.Label.DC_RtForNetwokrscmp;
        List<string> setRT = new List<string>();
        setRT = dcRT.split(',');
        
        String dcSSPrt=System.Label.DC_SSP_Record_Type; //SRSF-4062 
        System.debug('dcSSPrt' +dcSSPrt);
        List<string> setdcSSPrt = new List<string>(); //SRSF-4062 
        setdcSSPrt = dcSSPrt.split(',');  //SRSF-4062 
        System.debug('setdcSSPrt' +setdcSSPrt);

        String dcRTNonAddressableNonPreRoll=System.Label.DC_RTForNonAddressablePreRoll;
        List<string> setdcRTNonAddressableNonPreRoll = new List<string>();
        setdcRTNonAddressableNonPreRoll = dcRTNonAddressableNonPreRoll.split(',');
        
   
       //TODO: Remove Hard Codeed values
        //set<string> setRT = new set<string>{'Addressable_TV','Ads_Everywhere','New_Ads_Everywhere','Automotive_Performance_Package','Directories','Display_Custom','Inventory_Request_Ads_Everywhere','Inventory_Request_New_Ads_Everywhere','Inventory_Request_Display_Custom','Inventory_Request_Pre_roll_Custom', 'Inventory_Request_Revision_Ads_Everywhere', 'Inventory_Request_Revision_New_Ads_Everywhere', 'Inventory_Request_Revision_Display_Custom', 'Inventory_Request_Revision_Pre_roll_Custom', 'Leads','Pre_roll_Custom','Social_Smart_Ads','Spectrum_Networks_Display','Spectrum_Networks_Video','Social_Smart_Ads','Visits','Makegood_Inventory_Request_New_Ads_Everywhere'};      
        
        string strDCRecType = objDC.RecordType.DeveloperName;
        System.debug('RecordType --> ' + strDCRecType);
         
        geoClass.isNotSSPRecordType = setdcSSPrt.contains(strDCRecType) ? false : true;     //SRSF-4062
        System.debug('isNotSSPRecordType' + geoClass.isNotSSPRecordType);
        geoClass.isDMAVisible  = setRT.contains(strDCRecType) || (strDCRecType.contains('Addressable_Display') || strDCRecType.contains('Addressable_Video')) ? true : false;
        
        Boolean isVisible = (strDCRecType == 'Addressable_TV' || strDCRecType == 'Search' || strDCRecType =='Automotive_Performance_Package' || strDCRecType=='Social_Smart_Ads' || (strDCRecType.contains('Addressable_Display')) ||strDCRecType.contains('Addressable_Video') ) ? false : true;
        
        geoClass.isZoneVisible     = isVisible;
        geoClass.isCongressVisible = isVisible;
        geoClass.isTimeZoneVisible = isVisible;
        geoClass.isNotAddressableDisplayPreroll = !(strDCRecType.contains('Addressable_Display') || strDCRecType.contains('Addressable_Video') || strDCRecType.contains('Display_Custom') || strDCRecType.contains('Pre_roll_Custom') || setdcRTNonAddressableNonPreRoll.contains(strDCRecType));

        geoClass.DMAHelpText      = Digital_Campaign__c.DMAs__c.getDescribe().getInlineHelpText();
        geoClass.ZoneHelpText     = Digital_Campaign__c.Spectrum_Reach_Zones__c.getDescribe().getInlineHelpText();
       // geoClass.CongressHelpText = Digital_Campaign__c.Congressional_Districts__c.getDescribe().getInlineHelpText();

        if(strDCRecType == 'Automotive_Performance_Package' || strDCRecType == 'Social_Smart_Ads'){
            geoClass.DMAHelpText = DMA_TEXT;
        }

        if(geoClass.DMAHelpText == null){
            geoClass.DMAHelpText = 'Enter Tooltip Information in DMAs__c field.';
        }

        if(geoClass.ZoneHelpText == null){
            geoClass.ZoneHelpText = 'Enter Tooltip Information in Spectrum_Reach_Zones__c field.';
        }

        /*if(geoClass.CongressHelpText == null){
            geoClass.CongressHelpText = 'Enter Tooltip Information in Congressional_Districts__c field.';
        }*/

        geoClass.isLockRecord = false;

        User userObj = [SELECT ID, Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];

        String ProfileName = userObj.Profile.Name;

        if(Test.isRunningTest()){

            if (setProfile){
                ProfileName = 'Fake Profile';
            }

        }

        //TODO: Remove Hard Codeed values
        if(!(ProfileName == 'System Administrator' || ProfileName == 'Master - Digital Operations' || ProfileName == 'Master - Digital Traffic'))
        {    
            if( !( objDC.Status__c == '03 Submitted to Digital Ops' && (userObj.Profile.Name == 'Master - Digital Sales' || userObj.Profile.Name == 'Master - Digital Planner')) 
               && ( objDC.Sales_Cannot_Edit_Detail__c || objDC.Sales_Cannot_Edit_Status__c ) 
               && userObj.Profile.Name != 'System Administrator' && userObj.Profile.Name != 'Master - Digital Operations' && userObj.Profile.Name != 'Master - Digital Traffic'){
                   geoClass.isLockRecord = true;
               }  
            
            if( !geoClass.isLockRecord && objDC.Opportunity__c != null && objDC.Opportunity__r.OwnerId != Userinfo.getUserId()){
                //Opportunity Owner can directly aceess this lightning component(SRSF-1534)      
                list<OpportunityTeamMember> lstOpptyTeamMembers = [SELECT Id FROM OpportunityTeamMember 
                                                                   WHERE OpportunityId=:objDC.Opportunity__c AND UserId=:UserInfo.getUserId()];

                geoClass.isLockRecord = lstOpptyTeamMembers != null && lstOpptyTeamMembers.size() > 0 ? false : true;
            }
        }
		System.debug('geoClass::'+JSON.serialize(geoClass));
        return JSON.serialize(geoClass);
    
    }


    @AuraEnabled(cacheable=true)
    public static List<string> getDMAZipCodes(List<string> locations){

        System.debug('Location size ' + locations.size());

        for(string location : locations){
            System.debug(locations);
        }

        List<Zipcode_Mapping__c> zipMapping  = [SELECT  Zip_List__c 
                                                FROM Zipcode_Mapping__c 
                                                WHERE Nielsen_DMA_Name__c IN : locations 
                                                AND Nielsen_DMA_Name__c != null
                                                ORDER BY Nielsen_DMA_Name__c]; 

        List<string> zipList = new List<string>();
    
        for(Zipcode_Mapping__c zip : zipMapping){
            zipList.add(zip.Zip_List__c);
        }

        string ZipCodes = String.join(zipList , ',');
        System.debug(ZipCodes);

        return zipList;

    }

    @AuraEnabled(cacheable=true)
    public static List<string> getZoneZipCodes(List<string> locations){

       
         List<Zipcode_Mapping__c> zipMapping = [SELECT id, Zip_List__c 
                                              FROM Zipcode_Mapping__c 
                                              WHERE SR_Zone_Name__c in : locations 
                                              AND SR_Zone_Name__c != null
                                              ORDER by SR_Zone_Name__c]; 

       
        List<string> zipList = new List<string>();
    
        for(Zipcode_Mapping__c zip : zipMapping){
            zipList.add(zip.Zip_List__c);
        }

        string ZipCodes = String.join(zipList , ',');
        System.debug(ZipCodes);

        return zipList;

    }

 /*   @AuraEnabled(cacheable=true)
    public static List<string> getCongressional(List<string> locations){

        List<Zipcode_Mapping__c> zipMapping = [SELECT id, Zip_List__c 
                                               FROM Zipcode_Mapping__c 
                                               WHERE Congressional_District_Name__c IN : locations 
                                               AND Congressional_District_Name__c != null
                                               ORDER BY Congressional_District_Name__c]; 


       
        List<string> zipList = new List<string>();
    
        for(Zipcode_Mapping__c zip : zipMapping){
            zipList.add(zip.Zip_List__c);
        }

        string ZipCodes = String.join(zipList , ',');
        System.debug(ZipCodes);

        return zipList;

    }*/
    
    @AuraEnabled(cacheable=true)
    public static String getTimezoneByDMA(List<string> locations){

        System.debug('Location size ' + locations.size());

        for(string location : locations){
            System.debug(locations);
        }
        set<string> setTimezone = new set<string>();
        String resultTimezone;
        if(!locations.isEmpty()){
            for(Zipcode_Mapping__c zipMapping  : [SELECT  Time_Zones__c 
                                                    FROM Zipcode_Mapping__c 
                                                    WHERE Nielsen_DMA_Name__c IN : locations 
                                                    AND Nielsen_DMA_Name__c != null AND Time_Zones__c != null
                                                  ORDER BY Nielsen_DMA_Name__c]){
                System.debug('zipMapping##' +zipMapping.Time_Zones__c);
            	setTimezone.add(zipMapping.Time_Zones__c);                                          
            }
            System.debug(resultTimezone);
        }
        if(setTimezone.size() == 1){
            list<string> lstTZ = new list<string>();
			lstTZ.addAll(setTimezone);
            resultTimezone = lstTZ.get(0);
            System.debug('resultTimezone@@' +resultTimezone);
        }else{
            //User objUser = [select id,TimeZoneSidKey from User where id=:Userinfo.getUserId()];
            resultTimezone = 'America/New_York';
        }
		System.debug('resultTimezoneFinal' +resultTimezone);
        return resultTimezone;

    }

	@AuraEnabled(cacheable=true)
    public static String getTimezoneByZones(List<string> locations){

        System.debug('Location size ' + locations.size());

        for(string location : locations){
            System.debug(locations);
        }
        set<string> setTimezone = new set<string>();
        String resultTimezone;
        if(!locations.isEmpty()){
            for(Zipcode_Mapping__c zipMapping  : [SELECT  Time_Zones__c 
                                                    FROM Zipcode_Mapping__c 
                                                    WHERE SR_Zone_Name__c IN : locations 
                                                    AND SR_Zone_Name__c != null AND SR_Zone_Name__c != null
                                                  ORDER BY SR_Zone_Name__c]){
            	setTimezone.add(zipMapping.Time_Zones__c);                                          
            }
            System.debug(resultTimezone);
        }
        if(setTimezone.size() == 1){
            list<string> lstTZ = new list<string>();
			lstTZ.addAll(setTimezone);
            resultTimezone = lstTZ.get(0);
        }else{
            //User objUser = [select id,TimeZoneSidKey from User where id=:Userinfo.getUserId()];
            resultTimezone = 'America/New_York';
        }

        return resultTimezone;

    }

	@AuraEnabled(cacheable=true)
    public static String getTimezoneByStates(List<string> locations){

        System.debug('Location size ' + locations.size());

        for(string location : locations){
            System.debug(locations);
        }
        set<string> setTimezone = new set<string>();
        String resultTimezone;
        if(!locations.isEmpty()){
            for(Zipcode_Mapping__c zipMapping  : [SELECT  Time_Zones__c 
                                                    FROM Zipcode_Mapping__c 
                                                    WHERE State__c IN : locations 
                                                    AND State__c != null AND State__c != null
                                                    ORDER BY State__c]){
            	setTimezone.add(zipMapping.Time_Zones__c);                                          
            }
            System.debug(resultTimezone);
        }
        if(setTimezone.size() == 1){
            list<string> lstTZ = new list<string>();
			lstTZ.addAll(setTimezone);
            resultTimezone = lstTZ.get(0);
        }else{
          //  User objUser = [select id,TimeZoneSidKey from User where id=:Userinfo.getUserId()];
            resultTimezone = 'America/New_York';
        }
        return resultTimezone;

    }


	@AuraEnabled(cacheable=true)
	public static String getCurrentAETimeZone(Boolean customZipValue,string DCOwnerID){
        System.debug('dcID' +DCOwnerID);
		string resultTimezone;
		if(customZipValue){
			User objUser = [select id,TimeZoneSidKey from User where id=:DCOwnerID];
			resultTimezone = objUser.TimeZoneSidKey;
			}
		return resultTimezone;
	}
    
    @AuraEnabled(cacheable=true)
    public static String getCustomZipCodeMapping(Boolean customZipValue,string firstZip,string DCOwnerID){
        System.debug('firstZip' +firstZip);
        System.debug('dcID' +DCOwnerID);
        List<String> zipDMA = new List<String>();
        set<string> setTimezone = new set<string>();
        List<List<Zipcode_Mapping__c>> customZipDMA = new List<List<Zipcode_Mapping__c>> ();
        List<Zipcode_Mapping__c> zipCodeMap = new List<Zipcode_Mapping__c>();
        string resultTimezone;
        if(customZipValue){
			customZipDMA = [FIND :firstZip IN ALL FIELDS RETURNING Zipcode_Mapping__c(Zip_List__c ,Nielsen_DMA_Name__c) limit 200];
            System.debug('customZipDMA' +customZipDMA);
            zipCodeMap = customZipDMA[0];
            for(List<Zipcode_Mapping__c> z : customZipDMA){
                System.debug('z' + z);
                for (Zipcode_Mapping__c zip : z) {
                    System.debug('zip' +zip);
                	zipDMA.add(zip.Nielsen_DMA_Name__c);
            	}
            }
           // zipDMA.add(zipCodeMap[0].Nielsen_DMA_Name__c);
            System.debug('zipDMA' +zipDMA);
            if(!customZipDMA.isEmpty()){
                resultTimezone = OMS_NetworkExController.getTimezoneByDMA(zipDMA);
            }
            else{
                resultTimezone = OMS_NetworkExController.getCurrentAETimeZone(customZipValue,DCOwnerID);
            }
        }
        return resultTimezone;
    }

       
    @AuraEnabled
    public static GeographyTargetHelper insertZipCodes(String dcRecordId,string lstCng,string lstDMA,string lstZone,string strZipData){
        
        GeographyTargetHelper objWrap = new GeographyTargetHelper();
        String strResult = '';
        Digital_Campaign__c objDC = [Select Id,zip_codes__c, DMAs__c, Spectrum_Reach_Zones__c from Digital_Campaign__c where Id=: dcRecordId];
        
       set<String> allZipCodes = new set<String>();
        String strAllZipCodes = '';
        //System.debug('----> incoming lstDMA: '+lstDMA);
        String newDMAs = '';
        set<string> setDMANames = new set<string>( String.isNotBlank( lstDMA ) && lstDMA != 'null' ? lstDMA.split('; ') : new list<String>() );
        setDMANames.remove( null );
        setDMANames.remove( '' );
        System.debug('----> setDMANames: '+setDMANames);
        if(!setDMANames.isEmpty()){
            for(Zipcode_Mapping__c dzm: [Select id, Zip_List__c 
                                             from Zipcode_Mapping__c 
                                             where Nielsen_DMA_Name__c in : setDMANames and Nielsen_DMA_Name__c!=null
                                             order by Nielsen_DMA_Name__c] ){
                if( String.isNotBlank( dzm.Zip_List__c ) ){                                
                    String zipValues = (dzm.Zip_List__c.trim()).replace(' ', '') +',';              
                    strAllZipCodes += zipValues;
                }
            }
        }
        
        //system.debug('-----> 1. strAllZipCodes: '+strAllZipCodes);
        
        list<String> lstDMANames = new list<String>( setDMANames );
        lstDMANames.sort();
        //System.debug('----> lstDMANames: '+lstDMANames);
        objDC.DMAs__c = lstDMANames != null && lstDMANames.size() > 0 ? String.join( lstDMANames, '; ') : '';
        
        //Processing Spectrum_Reach_Zones__c data
        String newSRMs = '';
        set<string> setSRMNames = new set<string>( String.isNotBlank( lstZone ) && lstZone != 'null' ? lstZone.split('; ') : new list<String>() );
        setSRMNames.remove( null );
        setSRMNames.remove( '' );
        
        if(!setSRMNames.isEmpty()){
            for(Zipcode_Mapping__c dzm: [Select id, Zip_List__c 
                                             from Zipcode_Mapping__c 
                                             where SR_Zone_Name__c in : setSRMNames and SR_Zone_Name__c!=null
                                             order by SR_Zone_Name__c] ){
                if( String.isNotBlank( dzm.Zip_List__c ) )                                 
                    strAllZipCodes += (dzm.Zip_List__c.trim()).replace(' ', '') +',' ;
            }
        }
        
        //system.debug('-----> 2. strAllZipCodes: '+strAllZipCodes);
        //If the existing Zone is Inactive, but Spectrum_Reach_Zones__c field will be hold the Zone value 
        String strExistingSRZName = (objDC.Spectrum_Reach_Zones__c!=null)? objDC.Spectrum_Reach_Zones__c : '';
        list<string> lstExistingSRZName = strExistingSRZName.split(';');//Existing Zones from DC
        set<string> setInactiveSRMNames = new set<string>();//Inactive Zones from Custom Settings
        for(Zipcode_Mapping__c obj : [select SR_Zone_Name__c from Zipcode_Mapping__c where RecordType.DeveloperName='SR_Zone' and Is_Active__c!=true]){
            setInactiveSRMNames.add(obj.SR_Zone_Name__c);
        }
        for(String str : lstExistingSRZName){
            if(setInactiveSRMNames.contains(str)){
                setSRMNames.add(str);
            }
        }
        list<String> lstSRZNames = new list<String>( setSRMNames );
        System.debug('----> lstSRZNames: '+lstSRZNames);
        lstSRZNames.sort();
        objDC.Spectrum_Reach_Zones__c = lstSRZNames != null && lstSRZNames.size() > 0 ? String.join( lstSRZNames, '; ') : '';
        
        
        //Processing Congressional_Districts__c data
       /* String newCRs = '';
        set<string> setCRNames = new set<string>( String.isNotBlank( lstCng ) && lstCng != 'null' ? lstCng.split('; ') : new list<String>() );
        setCRNames.remove( null );
        setCRNames.remove( '' );
        
        if(!setCRNames.isEmpty()){
            for(Zipcode_Mapping__c dzm: [Select id, Zip_List__c 
                                             from Zipcode_Mapping__c 
                                             where Congressional_District_Name__c in : setCRNames and Congressional_District_Name__c!=null
                                             order by Congressional_District_Name__c] ){
                if( String.isNotBlank( dzm.Zip_List__c ) )                                 
                    strAllZipCodes += (dzm.Zip_List__c.trim()).replace(' ', '') +',';
            }
        }*/
        //system.debug('-----> 3. strAllZipCodes: '+strAllZipCodes);
       // list<String> lstCRNames = new list<String>( setCRNames );
       // lstCRNames.sort();
        //objDC.Congressional_Districts__c = lstCRNames != null && lstCRNames.size() > 0 ? String.join( lstCRNames, '; ') : '';
        
        try{
            //System.debug('----> strAllZipCodes: '+strAllZipCodes );
            set<String> setAllZipCodes = new set<String>( strAllZipCodes.split(',') );
            //System.debug('----> setAllZipCodes 174 : '+setAllZipCodes );
            if( String.isNotBlank( strZipData ) ){
                strZipData.replace(' ', '');
                setAllZipCodes.addAll( new list<String>( strZipData.split(',') ) );
            }
            //boolean isZipChanged = CompareZipCodes(objDC.zip_codes__c,strZipData);
            //System.debug('isZipChanged::'+isZipChanged);
            //System.debug('----> setAllZipCodes: '+setAllZipCodes.size()+'-----'+setAllZipCodes);
            
            //System.debug('-----> String join: '+String.join( new list<String>( setAllZipCodes ), ', '));
            objDC.zip_codes__c = String.join( new list<String>( setAllZipCodes ), ', ');
            update objDC;
            strResult = 'The ZipCodes have been added.';
        }catch( Exception ex ){
            strResult+='Error in saving zip code information! Error details:' + ex.getMessage();
        }
        system.debug('----> dcRecord: '+objDC );
        objWrap.objDCampaign = objDC;
        //objWrap.strZipcode = objDC.Zip_Codes__c;
        objWrap.strMsg = strResult;
        return objWrap;       
    }

    //For Ratecard CPM Auto Calculation(SRSF-2147)
    @AuraEnabled(cacheable=true)
    public static String getGrossCPMConfig(){
        String strResult;
        List <CPM_Calculation__c> lstCPM = CPM_Calculation__c.getall().values();
        if(!lstCPM.isEmpty()){
            strResult = JSON.serialize(lstCPM[0]);
        }
        return strResult;
    }
    
        
}