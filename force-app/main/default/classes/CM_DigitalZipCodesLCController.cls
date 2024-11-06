/*
    Author               :  M & S
    Date                 :  Jun 07-17
    Description          :  Lightning Controller of CM_DigitalZipCodes.cmp 
                            Update Zip Code Information into Digital_Campaign__c.Zip_Codes__c from Lightning Component input
    Modification History : 
*/
public class CM_DigitalZipCodesLCController {
    
    @AuraEnabled public static Digital_Campaign__c dcRecord{get;set;} 
    
    @AuraEnabled
    public static ResultWrap PrepareData(String dcRecordId){
        dcRecord = [Select Id,zip_codes__c, DMAs__c, Spectrum_Reach_Zones__c,
                    RecordType.DeveloperName, Opportunity__c,Opportunity__r.OwnerId,
                    Status__c, Sales_Cannot_Edit_Detail__c, Sales_Cannot_Edit_Status__c
                    from Digital_Campaign__c where id=: dcRecordId];
        ResultWrap objWrap = new ResultWrap();
        //checking for platform cache
        //Congressional District
      /*  if (Cache.Org.contains('local.SalesAppOrgPartition.lstCongr'))
        {
            objWrap.lstCongr = (list<string>) Cache.Org.get('local.SalesAppOrgPartition.lstCongr');
        }else{
            objWrap.lstCongr = getCongressionals();
            Cache.Org.put('local.SalesAppOrgPartition.lstCongr',objWrap.lstCongr);
        }*/
        
        //DMA
        if (Cache.Org.contains('local.SalesAppOrgPartition.lstDMA'))
        {
            //objWrap.lstDMA = getDMA();
            objWrap.lstDMA = (list<string>) Cache.Org.get('local.SalesAppOrgPartition.lstDMA');
        }else{
            objWrap.lstDMA = getDMA();
            Cache.Org.put('local.SalesAppOrgPartition.lstDMA',objWrap.lstDMA);
        }
        
        //Spectrum Reach Zone
        if (Cache.Org.contains('local.SalesAppOrgPartition.lstZone'))
        {
            objWrap.lstZone = (list<string>) Cache.Org.get('local.SalesAppOrgPartition.lstZone');
            objWrap.lstZone = getZones();
        }else{
            objWrap.lstZone = getZones();
            Cache.Org.put('local.SalesAppOrgPartition.lstZone',objWrap.lstZone);
        }
        string strDCRecType = dcRecord.RecordType.DeveloperName;
        System.debug('RecordType -->'+strDCRecType);
        set<string> setRT = new set<string>{'Addressable_TV','Ads_Everywhere','New_Ads_Everywhere','Automotive_Performance_Package','Directories','Display_Custom','Inventory_Request_Ads_Everywhere','Inventory_Request_New_Ads_Everywhere','Inventory_Request_Display_Custom','Inventory_Request_Pre_roll_Custom', 'Inventory_Request_Revision_Ads_Everywhere', 'Inventory_Request_Revision_New_Ads_Everywhere', 'Inventory_Request_Revision_Display_Custom', 'Inventory_Request_Revision_Pre_roll_Custom', 'Leads','Pre_roll_Custom','Social_Smart_Ads','Spectrum_Networks_Display','Spectrum_Networks_Video','Social_Smart_Ads','Visits','Makegood_Inventory_Request_New_Ads_Everywhere','Makegood_Inventory_Request_Pre_roll_Custom','Makegood_Inventory_Request_Display_Custom','Makegood_Leads','Makegood_Social_Smart_Ads','Makegood_Spectrum_Networks_Display','Makegood_Visits'};
        objWrap.showDMA = setRT.contains(strDCRecType) ? true : false;
        objWrap.showSRZ = (strDCRecType=='Addressable_TV' || strDCRecType=='Search' || strDCRecType=='Automotive_Performance_Package' || strDCRecType=='Social_Smart_Ads') ? false : true;
      //  objWrap.showCD = (strDCRecType=='Addressable_TV' || strDCRecType=='Search' || strDCRecType=='Automotive_Performance_Package' || strDCRecType=='Social_Smart_Ads') ? false : true;
        
        objWrap.objDCampaign = dcRecord;
        objWrap.strLblDMA = Digital_Campaign__c.DMAs__c.getDescribe().getInlineHelpText();
        if(strDCRecType == 'Automotive_Performance_Package' || strDCRecType == 'Social_Smart_Ads')
            objWrap.strLblDMA = 'If no geography is indicated, the GEO will default to 35 mile radius around the Dealership';
        if(objWrap.strLblDMA == null)
            objWrap.strLblDMA = 'Enter Tooltip Information in DMAs__c field.';
        objWrap.strLblSRZone = Digital_Campaign__c.Spectrum_Reach_Zones__c.getDescribe().getInlineHelpText();
        if(objWrap.strLblSRZone == null)
            objWrap.strLblSRZone = 'Enter Tooltip Information in Spectrum_Reach_Zones__c field.';
        //objWrap.strLblCongDist = Digital_Campaign__c.Congressional_Districts__c.getDescribe().getInlineHelpText();
       // if(objWrap.strLblCongDist == null)
            //objWrap.strLblCongDist = 'Enter Tooltip Information in Congressional_Districts__c field.';
        
        objWrap.lockRecord = false;
        User userObj = [SELECT ID, Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];
        
        if(!(userObj.Profile.Name == 'System Administrator' || userObj.Profile.Name == 'Master - Digital Operations' || userObj.Profile.Name == 'Master - Digital Planner' || userObj.Profile.Name == 'Master - Digital Traffic'))
        {    
            if( !( dcRecord.Status__c == '03 Submitted to Digital Ops' && (userObj.Profile.Name == 'Master - Digital Sales' || userObj.Profile.Name == 'Master - Digital Planner')) 
               && ( dcRecord.Sales_Cannot_Edit_Detail__c || dcRecord.Sales_Cannot_Edit_Status__c ) 
               && userObj.Profile.Name != 'System Administrator' && userObj.Profile.Name != 'Master - Digital Operations' && userObj.Profile.Name != 'Master - Digital Traffic'){
                   objWrap.lockRecord = true;
            }  
            
            if( !objWrap.lockRecord && dcRecord.Opportunity__c != null && dcRecord.Opportunity__r.OwnerId!=Userinfo.getUserId()){//Opportunity Owner can directly aceess this lightning component(SRSF-1534)
                list<OpportunityTeamMember> lstOpptyTeamMembers = [SELECT Id FROM OpportunityTeamMember 
                                                                   WHERE OpportunityId=:dcRecord.Opportunity__c AND UserId=:UserInfo.getUserId()];
                objWrap.lockRecord = lstOpptyTeamMembers != null && lstOpptyTeamMembers.size() > 0 ? false : true;
            }
        }
        //objWrap.strZipcode = dcRecord.zip_codes__c;
        System.debug('Not From Cache -->'+objWrap);
        
        return objWrap;
    }
    
    /*
        Method Name : getCongressionals
        Description : Populate list of Congressionals
    */
    public static list<string> getCongressionals(){
        List<string> conOcl = new List<string>();
        conOcl.add('None');
        for(Zipcode_Mapping__c dzm: [Select id, Congressional_District_Name__c 
                                             from Zipcode_Mapping__c 
                                             where Congressional_District_Name__c != null
                                             order by Congressional_District_Name__c]){
            conOcl.add(dzm.Congressional_District_Name__c);
        }
        return conOcl;
    }
    
    /*
        Description : Populate list of DMA
    */
    public static list<string> getDMA(){
        List<string> dmaOcl = new List<string>();
        list<Zipcode_Mapping__c> lstZM = new list<Zipcode_Mapping__c>();
        //Added by Madhusudhan on 18th-Jul -> Ensure that the "All DMAs" is added as a second entry in DMA picklist
        if(dcRecord.RecordType.DeveloperName != 'Addressable_TV'){//Added by Madhusudhan on Sep18-18 for SRSF-1281
            dmaOcl.add('None');
            dmaOcl.add('All DMAs');
            for(Zipcode_Mapping__c dzm: [Select id, Nielsen_DMA_Name__c 
                                             from Zipcode_Mapping__c 
                                             where Nielsen_DMA_Name__c != null
                                             order by Nielsen_DMA_Name__c]){
                dmaOcl.add(dzm.Nielsen_DMA_Name__c);
            }
        }else{
            for(Zipcode_Mapping__c dzm: [Select id, Nielsen_DMA_Name__c 
                                                 from Zipcode_Mapping__c 
                                                 where Nielsen_DMA_Name__c != null and Is_AddressableTV_Recordtype__c=true
                                                 order by Nielsen_DMA_Name__c]){
                dmaOcl.add(dzm.Nielsen_DMA_Name__c);
            }
        }
        return dmaOcl;
    }
    
    /*
        Description : Populate list of SR Zones
    */
    public static list<string> getZones(){
        List<string> srOcl = new List<string>();
        srOcl.add('None');
        for(Zipcode_Mapping__c dzm: [Select id, SR_Zone_Name__c 
                                             from Zipcode_Mapping__c 
                                             where RecordType.DeveloperName='SR_Zone' and SR_Zone_Name__c != null and Is_Active__c=true
                                             order by SR_Zone_Name__c]){
            srOcl.add(dzm.SR_Zone_Name__c);
        }
        return srOcl;
    }
    
    /*
        Description : update Zip Codes Information into Digital_Campaign__c.Zip_Codes__c
    */
    @AuraEnabled
    public static ResultWrap insertZipCodes(String dcRecordId,string lstCng,string lstDMA,string lstZone,string strZipData){
        
        ResultWrap objWrap = new ResultWrap();
        String strResult = '';
        dcRecord = [Select Id,zip_codes__c, DMAs__c, Spectrum_Reach_Zones__c from Digital_Campaign__c where Id=: dcRecordId];
        
       set<String> allZipCodes = new set<String>();
        String strAllZipCodes = '';
        System.debug('----> incoming lstDMA: '+lstDMA);
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
        
        system.debug('-----> 1. strAllZipCodes: '+strAllZipCodes);
        
        list<String> lstDMANames = new list<String>( setDMANames );
        lstDMANames.sort();
        System.debug('----> lstDMANames: '+lstDMANames);
        dcRecord.DMAs__c = lstDMANames != null && lstDMANames.size() > 0 ? String.join( lstDMANames, '; ') : '';
        
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
        
        system.debug('-----> 2. strAllZipCodes: '+strAllZipCodes);
        //If the existing Zone is Inactive, but Spectrum_Reach_Zones__c field will be hold the Zone value 
        String strExistingSRZName = (dcRecord.Spectrum_Reach_Zones__c!=null)? dcRecord.Spectrum_Reach_Zones__c : '';
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
        dcRecord.Spectrum_Reach_Zones__c = lstSRZNames != null && lstSRZNames.size() > 0 ? String.join( lstSRZNames, '; ') : '';
        
        
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
        }
        system.debug('-----> 3. strAllZipCodes: '+strAllZipCodes);
        list<String> lstCRNames = new list<String>( setCRNames );
        lstCRNames.sort();
        dcRecord.Congressional_Districts__c = lstCRNames != null && lstCRNames.size() > 0 ? String.join( lstCRNames, '; ') : '';*/
        
        try{
            System.debug('----> strAllZipCodes: '+strAllZipCodes );
            set<String> setAllZipCodes = new set<String>( strAllZipCodes.split(',') );
            System.debug('----> setAllZipCodes 174 : '+setAllZipCodes );
            if( String.isNotBlank( strZipData ) ){
                strZipData.replace(' ', '');
                setAllZipCodes.addAll( new list<String>( strZipData.split(',') ) );
            }
            System.debug('----> setAllZipCodes: '+setAllZipCodes.size()+'-----'+setAllZipCodes);
            
            System.debug('-----> String join: '+String.join( new list<String>( setAllZipCodes ), ', '));
            dcRecord.zip_codes__c = String.join( new list<String>( setAllZipCodes ), ', ');
            update dcRecord;
            strResult = 'The ZipCodes have been added.';
        }catch( Exception ex ){
            strResult+='Error in saving zip code information! Error details:' + ex.getMessage();
        }
        system.debug('----> dcRecord: '+dcRecord );
        objWrap.objDCampaign = dcRecord;
        //objWrap.strZipcode = dcRecord.Zip_Codes__c;
        objWrap.strMsg = strResult;
        return objWrap;
        
    }
    
    public class ResultWrap{
      //  @AuraEnabled public list<string> lstCongr;//Congressional District
        @AuraEnabled public list<string> lstDMA;//DMA
        @AuraEnabled public list<string> lstZone;//Spectrum Reach Zone
        @AuraEnabled public list<string> lstDigAZone;
        @AuraEnabled public Boolean showDMA;//DMA rendering
        @AuraEnabled public Boolean showSRZ;//Spectrum Reach Zone rendering
       // @AuraEnabled public Boolean showCD;//Congressional District rendering
        @AuraEnabled public Digital_Campaign__c objDCampaign;
        @AuraEnabled public string strZipcode;
        @AuraEnabled public string strMsg;//Result after Digital Campaign DML
        @AuraEnabled public Boolean lockRecord;
        @AuraEnabled public string strLblDMA;//DMA Label
        @AuraEnabled public string strLblSRZone;//Spectrum Reach Zone Label
      //  @AuraEnabled public string strLblCongDist;//Congressional District Label
    }
}