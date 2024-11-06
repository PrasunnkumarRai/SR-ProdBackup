/*
    Author : MAndS 
    Date   : May 14-2020
    Description : Lightning component Apex controller of CM_DCClientRequestPlanDetails to Add/Remove/Update plan details on DigitalCampaign
    Modification History : 
*/
public class CM_DCClientRequestPlanController{
    
    /**
        MethodName  : PrepareData
        Output      : List of Picklist Entries
        Description : Aura enabled method to fetch picklist data 
     */
    @AuraEnabled
    public static List<String> getExclusionsPickListValues(){
       List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Inventory_Source__c.Exclusions__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
            System.debug('pickListValuesList1 '+pickListValuesList);
		}     
		return pickListValuesList;
    }
    
    /**
        MethodName  : PrepareData
        Input       : DigitalCampaign Id
        Output      : List of ClientRequestPlanDetail Records
        Description : Aura enabled method to prepare the data 
     */
    @AuraEnabled
    public static ResultWrap PrepareData(String dcRecordId){
        ResultWrap objWrap = new ResultWrap();
        objWrap.isLockRecord = false;
        try{
            string profileName = [SELECT Id, Name FROM Profile WHERE Id =:UserInfo.getProfileId()].Name;
            list<PlanDetailsWrap> lstPlanRecords = new list<PlanDetailsWrap>();
            Inventory_Source__c[] lstRecords = new Inventory_Source__c[6];
            Digital_Campaign__c dcRecord = [Select Id,Campaign_Start_Date__c,Campaign_End_Date__c,Data_Catalog__c,
                                                    Freewheel_O_O_Affiliate_Direct_Info__c,TTD_CTV_Info__c,
                                                    Freewheel_FF_OTT_Info__c,Freewheel_FF_TVE_Info__c,RecordType.DeveloperName,       //SRSF-4062
                                                    ClientRequestFormPlanDetails_Notes__c,Is_Freewheel_FF_OTT_Primary__c,AdsE_Genre_s__c,
                                                    AdsE_Platform_s__c,Desired_Budget__c,Operative_ID__c,Efficiency_Packages__c,Yield_Exclude_override__c,
                                                    Total_Impressions__c,Gross_CPM__c,Gross_Campaign_Cost__c,Rate_Card_CPM__c,Gross_CPM1__c,
                                                    Has_hit_09_Live__c,Status__c,X1x1_Pixel__c,VAST_Tag__c,CustomZipCode__c,Source__c,
                                            		State__c,DMAs__c, Spectrum_Reach_Zones__c,Product_Type__c,Full_Avail_Campaign__c,CreatedById,
                                            	(select Id,Status__c from Digital_Creatives__r where Status__c!=null)
                    from Digital_Campaign__c where id=: dcRecordId  ];

                
            String dcSSPrt=System.Label.DC_SSP_Record_Type; //SRSF-4062 
            System.debug('dcSSPrt' +dcSSPrt);
            List<string> setdcSSPrt = new List<string>(); //SRSF-4062 
            setdcSSPrt = dcSSPrt.split(',');  //SRSF-4062 
            System.debug('setdcSSPrt' +setdcSSPrt);        

            string strDCRecType = dcRecord.RecordType.DeveloperName;
            System.debug('RecordType --> ' + strDCRecType);
                
            objWrap.yisfVisible = setdcSSPrt.contains(strDCRecType) ? false : true;     //SRSF-4062
         //   System.debug('isNotSSPRecordType' + geoClass.isNotSSPRecordType);

           
            //S-SRSF-4316K
            if(dcRecord.RecordType.DeveloperName =='Inventory_Request_Revision_New_Ads_Everywhere' &&  profileName == 'Master - Digital Planner'){
                objWrap.yisfVisible = false;
            }            
            //E-SRSF-4316K        

            System.debug('dcRecord===@@@ '+dcRecord);
            if(dcRecord.Campaign_Start_Date__c==null) return objWrap;
            /*if(dcRecord.Campaign_Start_Date__c==null)
                dcRecord.Campaign_Start_Date__c = Date.today();
            if(dcRecord.Campaign_End_Date__c==null){
                dcRecord.Campaign_End_Date__c = Date.today();
                objWrap.isLockRecord = true;
            }*/
            
            String profName = [Select id,profile.name FROM user WHERE id=:dcRecord.createdbyid limit 1].profile.name;
            
            
            list<Inventory_Source__c> lstIS = [select id,Audience__c,Campaign_Start_Date__c,Campaign_End_Date__c,COST_Gross__c,CPM_Gross__c,
                                                Digital_Campaign__c,Error_Message__c,Geo_Target_Type__c,Impressions__c,Industry__c,
                                                Inventory_Resource_Type__c,Name,Line_Item_Id__c,Notes__c,SFDC_DC_Type__c,Exclusions__c
                                                from Inventory_Source__c where Digital_Campaign__c=: dcRecordId];
            
            System.debug('lstIS-63' +lstIS);
            //Create default InventoryResources
            if(lstIS.isEmpty()){
                System.debug('dcRecord');
                lstIS = new list<Inventory_Source__c>();
                Inventory_Source__c objDef = new Inventory_Source__c();
                objDef.Digital_Campaign__c = dcRecord.Id;
                objDef.Campaign_Start_Date__c = dcRecord.Campaign_Start_Date__c;
                objDef.Campaign_End_Date__c = dcRecord.Campaign_End_Date__c;
                objDef.Inventory_Resource_Type__c = 'Freewheel-O&O/Affiliate/Direct';
                objDef.SFDC_DC_Type__c = 'Ads Everywhere';
                System.debug('dcRecord.Status__c@@' +dcRecord.Status__c);
                if((dcRecord.Source__c =='Audience Track' || dcRecord.Source__c=='SPP') && (dcRecord.Status__c == 'Plan Submitted' || dcRecord.Status__c == '01 Draft Campaign')){
                   System.debug('dcRecord.Status__c' +dcRecord.Status__c);
                   objDef.COST_Gross__c = dcRecord.Gross_Campaign_Cost__c;
                   objDef.CPM_Gross__c = dcRecord.Gross_CPM1__c;
                   objDef.Impressions__c = (objDef.COST_Gross__c/objDef.CPM_Gross__c)*1000;
                    
                }
                lstIS.add(objDef);
                
                Inventory_Source__c objSA = new Inventory_Source__c();
                objSA.Digital_Campaign__c = dcRecord.Id;
                objSA.Campaign_Start_Date__c = dcRecord.Campaign_Start_Date__c;
                objSA.Campaign_End_Date__c = dcRecord.Campaign_End_Date__c;
                objSA.Inventory_Resource_Type__c = 'Freewheel-SA';
                objSA.SFDC_DC_Type__c = 'Ads Everywhere';
                lstIS.add(objSA);
                
                Inventory_Source__c objOTT = new Inventory_Source__c();
                objOTT.Digital_Campaign__c = dcRecord.Id;
                objOTT.Campaign_Start_Date__c = dcRecord.Campaign_Start_Date__c;
                objOTT.Campaign_End_Date__c = dcRecord.Campaign_End_Date__c;
                objOTT.Inventory_Resource_Type__c = 'Freewheel-FF OTT';
                objOTT.SFDC_DC_Type__c = 'Pre Roll Custom';
                lstIS.add(objOTT);
                
                Inventory_Source__c objTVE = new Inventory_Source__c();
                objTVE.Digital_Campaign__c = dcRecord.Id;
                objTVE.Campaign_Start_Date__c = dcRecord.Campaign_Start_Date__c;
                objTVE.Campaign_End_Date__c = dcRecord.Campaign_End_Date__c;
                objTVE.Inventory_Resource_Type__c = 'Freewheel-FF TVE';
                objTVE.SFDC_DC_Type__c = 'Pre Roll Custom';
                lstIS.add(objTVE);
                
                Inventory_Source__c objCTV = new Inventory_Source__c();
                objCTV.Digital_Campaign__c = dcRecord.Id;
                objCTV.Campaign_Start_Date__c = dcRecord.Campaign_Start_Date__c;
                objCTV.Campaign_End_Date__c = dcRecord.Campaign_End_Date__c;
                objCTV.Inventory_Resource_Type__c = 'TTD-CTV';
                objCTV.SFDC_DC_Type__c = 'Pre Roll Custom';
                lstIS.add(objCTV);

                Inventory_Source__c objFI = new Inventory_Source__c();
                objFI.Digital_Campaign__c = dcRecord.Id;
                objFI.Campaign_Start_Date__c = dcRecord.Campaign_Start_Date__c;
                objFI.Campaign_End_Date__c = dcRecord.Campaign_End_Date__c;
                objFI.Inventory_Resource_Type__c = 'Simpli.fi-CTV';
                objFI.SFDC_DC_Type__c = 'Ads Everywhere';
                lstIS.add(objFI);
                insert lstIS;
                System.debug('lstIS===>' + lstIS);
                System.debug('lstIS SIZE===>' + lstIS.size());
            }
            //workaround for the duplicate IS records       
            if(lstIS.size() > 6){
                list<Inventory_Source__c> lstTemp = new list<Inventory_Source__c>();
                list<Inventory_Source__c> lstToDelete = new list<Inventory_Source__c>();
                for(Inventory_Source__c objIS : lstIS){ 
                    Boolean isDuplicate=false;           
                    for(Inventory_Source__c objISNew : lstTemp){           
                        if(objISNew.Inventory_Resource_Type__c == objIS.Inventory_Resource_Type__c){
                            isDuplicate=true;          	
                        }
                    }
                    lstTemp.add(objIS);
                    if(isDuplicate==true && objIS.Impressions__c == null){
                        lstToDelete.add(objIS);
                    }
                } 
                if(lstToDelete.size()>0){
                	delete lstToDelete;
                }
            }

            if( lstIS!=null && !lstIS.isEmpty()){  
                System.debug('list od IS' +lstIS.size());
                System.debug('lstIS-149' + lstIS);
                if(lstIS.size()==4){
                    System.debug('lstIS-151' + lstIS);
                    lstIS = new list<Inventory_Source__c>();
                    Inventory_Source__c objSA = new Inventory_Source__c();
                    objSA.Digital_Campaign__c = dcRecord.Id;
                    objSA.Campaign_Start_Date__c = dcRecord.Campaign_Start_Date__c;
                    objSA.Campaign_End_Date__c = dcRecord.Campaign_End_Date__c;
                    objSA.Inventory_Resource_Type__c = 'Freewheel-SA';
                    objSA.SFDC_DC_Type__c = 'Ads Everywhere';
                    lstIS.add(objSA);
                   // System.debug('objSA' +objSA);
                    insert lstIS;
                }
                if(lstIS.size()==5){
                    System.debug('lstIS-164' + lstIS);
                    lstIS = new list<Inventory_Source__c>();
                    Inventory_Source__c objFI = new Inventory_Source__c();
                    objFI.Digital_Campaign__c = dcRecord.Id;
                    objFI.Campaign_Start_Date__c = dcRecord.Campaign_Start_Date__c;
                    objFI.Campaign_End_Date__c = dcRecord.Campaign_End_Date__c;
                    objFI.Inventory_Resource_Type__c = 'Simpli.fi-CTV';
                    objFI.SFDC_DC_Type__c = 'Ads Everywhere';
                    System.debug('objFI' +objFI);
                    lstIS.add(objFI);
                    insert lstIS;
                }
                
                System.debug('lstIS-177' + lstIS);
                
                
                for(Inventory_Source__c inv : lstIS ){
                    System.debug('Inventory_Resource_Type__c' + inv.Inventory_Resource_Type__c);
                    System.debug('inv' + inv);
                    if(inv.Inventory_Resource_Type__c == 'Freewheel-O&O/Affiliate/Direct'){
                        lstRecords[0]=inv;
                    }if(inv.Inventory_Resource_Type__c == 'Freewheel-SA'){
                         lstRecords[1]=inv;
                    }if(inv.Inventory_Resource_Type__c == 'Freewheel-FF OTT'){
                         lstRecords[2]=inv;
                    }if(inv.Inventory_Resource_Type__c == 'Freewheel-FF TVE'){
                         lstRecords[3]=inv;
                    }if(inv.Inventory_Resource_Type__c == 'TTD-CTV'){
                         lstRecords[4]=inv;
                    }if(inv.Inventory_Resource_Type__c == 'Simpli.fi-CTV'){
                         lstRecords[5]=inv;
                    }
                    
                }
                    
                System.debug('lstRecords' + lstRecords[0]);
                System.debug('lstRecords' + lstRecords[1]);
                System.debug('lstRecords' + lstRecords[2]);
                System.debug('lstRecords' + lstRecords[3]);
                System.debug('lstRecords' + lstRecords[4]);
                System.debug('lstRecords' + lstRecords[5]);
                String strStatuses = System.Label.CM_DCCRFForm_DCCStatusError;
                set<string> setStatus = new set<string>();
                String statusList = '';
                if(strStatuses!=null){
                    list<string> lstStatus = strStatuses.split(',');
                    for(string str : lstStatus){
                        statusList+=str+'\n';
                    }
                    setStatus.addAll(lstStatus);
                    System.debug('setStatus '+ setStatus);
                }
                
                boolean isCPM_GrossLocked = false;
                for(Digital_Creative__c objDCC : dcRecord.Digital_Creatives__r){
                    if(setStatus.contains(objDCC.Status__c)){
                        isCPM_GrossLocked = true;
                        break;
                    }
                }
                
                                
                boolean isProfile = false;
                set<string> setProfiles = new set<string>();
                String profileList = '';
                System.debug('profileName ' + profileName);
                String strProfiles = System.Label.CM_DCCRFForm_ProfileError;
                if(strProfiles!=null){
                    list<string> lstProfiles = strProfiles.split(',');
                    setProfiles.addAll(lstProfiles);
                    for(string str : lstProfiles){
                        profileList+=str+'\n';
                    }
                    if(setProfiles.contains(profileName)){
                        isProfile = true;
                    }
                }
                Integer totImpressions = 0;
                decimal totCPM = 0.00;
                decimal totCOST = 0.00;
                for(Inventory_Source__c objIS : lstRecords){
                    System.debug('ObjIS is' + objIS );
             //SRSF-3999 : If yisf 1st row is null, it will update from the cpm fields which is present on DC layout .
                    if(objIS.Inventory_Resource_Type__c == 'Freewheel-O&O/Affiliate/Direct' && (dcRecord.Source__c =='Audience Track' || dcRecord.Source__c=='SPP' || profName=='Integration User')){
                        if(objIS.CPM_Gross__c == null ){
                            objIS.CPM_Gross__c = dcRecord.Gross_CPM1__c;   
                        }
                         if(objIS.COST_Gross__c == null ){
                            objIS.COST_Gross__c = dcRecord.Gross_Campaign_Cost__c;   
                        }
                         if(objIS.Impressions__c == null ){
                            objIS.Impressions__c = dcRecord.Total_Impressions__c;   
                        }
                    }
                    PlanDetailsWrap obj = getDetails(objIS);
                    obj.RecordNum = lstPlanRecords.size();
                    System.debug('obj' + obj.RecordNum);
                    if(objIS.Campaign_Start_Date__c == null)
                        objIS.Campaign_Start_Date__c = dcRecord.Campaign_Start_Date__c;
                    if(objIS.Campaign_End_Date__c == null)
                        objIS.Campaign_End_Date__c = dcRecord.Campaign_End_Date__c;
                    obj.isEditStDate = (!string.isBlank(objIS.Line_Item_Id__c) && dcRecord.Has_hit_09_Live__c==true && objIS.Campaign_Start_Date__c == date.today())? false : true;
                    obj.isCPMGrrossLocked = (String.isBlank(objIS.Line_Item_Id__c) && isCPM_GrossLocked && isProfile && (dcRecord.Has_hit_09_Live__c==true || !String.isBlank(dcRecord.Operative_ID__c) ));
                    lstPlanRecords.add(obj);
                    System.debug('lstPlanRecords' + lstPlanRecords);             
                }
                objWrap.totImpressions = (dcRecord.Total_Impressions__c!=null)? Integer.valueOf(dcRecord.Total_Impressions__c) : 0;
                objWrap.totCPM  = dcRecord.Gross_CPM1__c; //SRSF-3999
                objWrap.totCOST = dcRecord.Gross_Campaign_Cost__c;
                objWrap.desiredBudget = (dcRecord.Desired_Budget__c!=null)? dcRecord.Desired_Budget__c : 0.00;
                objWrap.yieldExclude = dcRecord.Yield_Exclude_override__c;
            }
                        
            string strAccessableProfiles = System.Label.CM_ClientRequestPlanDetailsProfiles;
            objWrap.isOTTExtensionPayloadInfo = strAccessableProfiles.contains(profileName) && dcRecord.Is_Freewheel_FF_OTT_Primary__c;
            string strEditDateProfiles = System.Label.CRFComponent_EditDateAccessProfiles;
            objWrap.isEditDate = strEditDateProfiles.contains(profileName);
            objWrap.objDCampaign = dcRecord;
            objWrap.profileName = profileName;
            objWrap.lstPlanRecords = lstPlanRecords;
            System.debug('lstPlanRecords 257' + objWrap.lstPlanRecords);



            //Code for simplify greyout when no active catalog
            // SRSF-4158 start
            Set<String> setDCNames = new Set<String>();
            for(Data_Catalog__c objDataCatalog : [Select id,DISPLAY_TEXT__c from Data_Catalog__c where SimpliFi_Activated__c  = true]){
                setDCNames.add(objDataCatalog.DISPLAY_TEXT__c);
            }
            String strDCCatalogs = dcRecord.Data_Catalog__c;  
            boolean isActivatedInterset = isActiveInterestedCatalog(strDCCatalogs,setDCNames);
            objWrap.isActiveCatalog = isActivatedInterset;
            // SRSF-4158 end
            
        }catch( Exception ex){
            System.debug('Error::'+ex.getMessage() +ex.getLineNumber());
            objWrap.strMsg = 'Error : '+ex.getMessage();
        }
        
        System.debug('objWrap@@@' +objWrap);
        return objWrap;
    }
    
    //Preparing Wraper object from the string
    public static PlanDetailsWrap getDetails(Inventory_Source__c objInvSrc){
        System.debug('objInvSrc::'+objInvSrc);
        PlanDetailsWrap obj = new PlanDetailsWrap();
        obj.selIS = objInvSrc.Inventory_Resource_Type__c; //INVENTORY SOURCE
        obj.selType = objInvSrc.SFDC_DC_Type__c; //SFDC DC TYPE
        obj.selAud = objInvSrc.Audience__c; //AUDIENCE
        obj.selGeoType = objInvSrc.Geo_Target_Type__c; //GEO TARGET TYPE
        obj.Notes = objInvSrc.Notes__c;
        obj.Impressions = (objInvSrc.Impressions__c!=null)? Integer.valueOf(objInvSrc.Impressions__c) : null; //IMPRESSIONS
        
        obj.CPM = objInvSrc.CPM_Gross__c;//CPM (GROSS)
        obj.Cost = objInvSrc.COST_Gross__c; //COST (GROSS)
        obj.Industry = objInvSrc.Industry__c;//Industry
        obj.LineItemId = objInvSrc.Line_Item_Id__c; //LineItemId
        obj.RecordId = objInvSrc.Id;
        //obj.YieldEx = objInvSrc.Yield_Override_Exclude__c;
        obj.objIS = objInvSrc; 
        return obj;
    }
    
    /**
        MethodName  : PrepareData
        Input       : DigitalCampaign Id
        Output      : List of Plan Records
        Description : Aura enabled method to update the data 
     */
    @AuraEnabled
    public static ResultWrap UpdateData(String dcRecordId, string wrapInvSrcData, integer totImpressions, decimal totCPM, decimal totCOST, boolean yieldEx){
        System.debug('dcRecordId::'+dcRecordId);
        System.debug('totImpressions::'+totImpressions);
        System.debug('totCPM::'+totCPM);
        System.debug('totCOST::'+totCOST);
        System.debug('wrapInvSrcData::'+wrapInvSrcData);
        System.debug('yieldEx::'+yieldEx);
        
		ResultWrap objWrap = new ResultWrap();
        try{
            
            Digital_Campaign__c dcRecord = [Select Id,Campaign_Start_Date__c,Campaign_End_Date__c,
                                                    Freewheel_O_O_Affiliate_Direct_Info__c,TTD_CTV_Info__c,
                                                    Freewheel_FF_OTT_Info__c,Freewheel_FF_TVE_Info__c,
                                                    ClientRequestFormPlanDetails_Notes__c,Is_Freewheel_FF_OTT_Primary__c,AdsE_Genre_s__c,
                                                    AdsE_Platform_s__c,Desired_Budget__c,Operative_ID__c,Efficiency_Packages__c,Yield_Exclude_override__c,
                                                    Total_Impressions__c,Gross_CPM__c,Gross_Campaign_Cost__c,Has_hit_09_Live__c, Rate_Card_CPM__c,Status__c,CustomZipCode__c,
                                            		State__c,DMAs__c, Spectrum_Reach_Zones__c,X1x1_Pixel__c,VAST_Tag__c,Product_Type__c,Full_Avail_Campaign__c,
                                                    (select Id,Status__c from Digital_Creatives__r where Status__c!=null)
                    from Digital_Campaign__c where id=: dcRecordId];
            System.debug('dcRecord ' + dcRecord);
            
            String strStatuses = System.Label.CM_DCCRFForm_DCCStatusError;
            set<string> setStatus = new set<string>();
            String statusList = '';
            if(strStatuses!=null){
                list<string> lstStatus = strStatuses.split(',');
                for(string str : lstStatus){
                    statusList+=str+'\n';
                }
                setStatus.addAll(lstStatus);
                System.debug('setStatus '+ setStatus);
            }
            boolean isError = false;
            for(Digital_Creative__c objDCC : dcRecord.Digital_Creatives__r){
                if(setStatus.contains(objDCC.Status__c)){            isError = true;break;
                }
            }
            
            boolean isUnAuthenticatedProfile = false;
            set<string> setProfiles = new set<string>();
            String profileList = '';
            string profileName = [SELECT Id, Name FROM Profile WHERE Id =:UserInfo.getProfileId()].Name;
            System.debug('profileName ' + profileName);
            String strProfiles = System.Label.CM_DCCRFForm_ProfileError;
            if(strProfiles!=null){
                list<string> lstProfiles = strProfiles.split(',');
                setProfiles.addAll(lstProfiles);
                for(string str : lstProfiles){
                    profileList+=str+'\n';
                }
                if(setProfiles.contains(profileName)){
                    isUnAuthenticatedProfile = true;
                }
            }
            System.debug('Next Step');
            List<PlanDetailsWrap> wrapperList = (List<PlanDetailsWrap>)JSON.deserialize(wrapInvSrcData,List<PlanDetailsWrap>.class);
            list<Inventory_Source__c> lstISUpdate = new list<Inventory_Source__c>();
            boolean isImpressionsError = false;
            totImpressions = 0;
            list<string> lstPlatformCombination = new list<string>();
            if(InventorySource_Platform_Validation__c.getAll()!=null){
                for(InventorySource_Platform_Validation__c objPVCombinations:InventorySource_Platform_Validation__c.getAll().values()){
                	string str = objPVCombinations.Platform_Combinations__c;
                    System.debug('str:'+str);
                    list<string> lst = str.split(',');
                    lst.sort();
                    System.debug(lst);
                    System.debug(String.join(lst,','));
                    lstPlatformCombination.add(String.join(lst,','));
                }
            }
            
            list<string> blockSAISforPlatforms = new list<string>{'Spectrum News Live Stream','3rd Party Apps','Spectrum Sports Net Live Stream'};
            string strPlatforms = dcRecord.AdsE_Platform_s__c;
            System.debug('strPlatforms ' +strPlatforms);
            list<string> lst = new list<string>();
            
            if(strPlatforms!=null || String.isnotblank(strPlatforms)){
                lst = strPlatforms.split(';');
                lst.sort();
                strPlatforms = String.join(lst,','); 
            }
            
            
            System.debug('strPlatforms::'+strPlatforms);
            System.debug('size:::'+wrapperList.size());
            for(PlanDetailsWrap objPlanWrap : wrapperList){
                if(objPlanWrap.selIS!='Freewheel-O&O/Affiliate/Direct' && objPlanWrap.selIS!='Freewheel-SA' && objPlanWrap.Impressions!=null){
                    boolean isMatched = false;
                    for(string str : lstPlatformCombination){
                        System.debug(strPlatforms+'<->'+str);
                        if(strPlatforms.contains(str)){
                            isMatched = true;
                            break;
                        }
                    }
                    if(isMatched == false)
                        throw new DMLException('Only \'All Platforms\' or \'3rd Party Apps\' allowed to add Impressions for OTT/TVE/TTD/Simpli.fi-CTV Inventory Source');
                }
                
                if(objPlanWrap.selIS=='Freewheel-SA' && objPlanWrap.Impressions!=null && objPlanWrap.CPM!=null){
                  if(dcRecord.DMAs__c == 'None' && ( dcRecord.CustomZipCode__c == false )) {throw new DMLException(
                  //'Only DMA Selection is allowed to add Impressions for Freewheel-SA Inventory Source'
                  'The Freewheel SA inventory source can only be used for impression allocation if the Geo-targeting is either DMA or Custom Zip');
                    }
                    // Added by Khushboo (11/12/22): Commented the below condition For SRSF-4567.
                    //else if(dcRecord.CustomZipCode__c == true){throw new DMLException('Custom Zip Code is not allowed for Freewheel-SA Inventory Source'); }
                    if(blockSAISforPlatforms.contains(strPlatforms)) {  throw new DMLException('Only \'All Platforms\', \'Spectrum TV App Live\', \'Spectrum TV App VOD\' and \'VOD Set-top box\' are allowed to add Impressions for Freewheel-SA Inventory Source');
                    }
                    
                }
                
              /*  if(objPlanWrap.selIS=='Simpli.fi-CTV' && objPlanWrap.Impressions!=null && objPlanWrap.CPM!=null){
                  if(dcRecord.AdsE_Genre_s__c != 'All Networks'){throw new DMLException('Only All Networks is allowed to add Impressions for Simpli.fi-CTV Inventory Source'); }
                }*/
                
                if((objPlanWrap.CPM!=null || objPlanWrap.Impressions!=null) && String.isBlank(objPlanWrap.LineItemId) && (!String.isBlank(objWrap.objDCampaign.Operative_ID__c) ||objWrap.objDCampaign.Has_Hit_09_Live__c == true) ){
                    if(isError && isUnAuthenticatedProfile){// && dcRecord.Has_hit_09_Live__c
                        String strErrorMsg = 'You cannot add Inventory Source when Digital Creative status is any of the following.\n';
                        throw new DMLException(strErrorMsg+statusList);
                    }
                }
                
                integer impressions;
                if(objPlanWrap.CPM!=null && objPlanWrap.Impressions!=null){
                    if(objPlanWrap.CPM==0 && objPlanWrap.cost==0)
                        impressions = objPlanWrap.Impressions;
                    else if(objPlanWrap.CPM!=0){
                        Decimal toround = objPlanWrap.cost/objPlanWrap.CPM;
                        Decimal rounded = toRound.setScale(2);
                        impressions =  Integer.valueOf(toround*1000);
                    }
                }
                
                
                Inventory_Source__c obj = new Inventory_Source__c();
                obj.Id = objPlanWrap.RecordId;
                obj.Campaign_Start_Date__c     = objPlanWrap.objIS.Campaign_Start_Date__c;
                obj.Campaign_End_Date__c       = objPlanWrap.objIS.Campaign_End_Date__c;
                obj.Inventory_Resource_Type__c = objPlanWrap.selIS;
                obj.SFDC_DC_Type__c            = objPlanWrap.selType;
                obj.Audience__c                = objPlanWrap.selAud;
                obj.Geo_Target_Type__c         = objPlanWrap.selGeoType;
                obj.Notes__c                   = objPlanWrap.Notes;
                obj.Impressions__c             = impressions;
                obj.CPM_Gross__c               = objPlanWrap.CPM;
                obj.COST_Gross__c              = objPlanWrap.cost;
                obj.Exclusions__c              = objPlanWrap.objIS.Exclusions__c;
                // obj.Yield_Override_Exclude__c  = yieldEx;
                lstISUpdate.add(obj);
                if(impressions!=null)
                    totImpressions+=impressions;
                System.debug(objPlanWrap.selIS+'-->'+impressions);
            }
            System.debug('lstISUpdate ---- >' +lstISUpdate);
            update lstISUpdate;
            objWrap.isLockRecord = false;
            objWrap.isVRError = false;
        
            dcRecord.Total_Impressions__c = totImpressions;
            dcRecord.Yield_Exclude_override__c = yieldEx;
            dcRecord.Gross_CPM__c = totCPM;
            dcRecord.Gross_Campaign_Cost__c = totcost;
            update dcRecord;
            string strAccessableProfiles = System.Label.CM_ClientRequestPlanDetailsProfiles;
            objWrap.isOTTExtensionPayloadInfo = strAccessableProfiles.contains(profileName) && dcRecord.Is_Freewheel_FF_OTT_Primary__c;
            string strEditDateProfiles = System.Label.CRFComponent_EditDateAccessProfiles;
            objWrap.isEditDate = strEditDateProfiles.contains(profileName);
            objWrap.strMsg = 'Client Request Form Plan Details have been added successfully.';
            objWrap.objDCampaign = dcRecord;
            objWrap.totImpressions = totImpressions;
            objWrap.totCPM = totCPM;
            objWrap.totCOST = totcost;
           
             
        }catch( Exception ex){
            System.debug('ex::'+ex.getLineNumber());
            objWrap.isVRError = true;
            objWrap.strMsg = ex.getMessage();
            throw new DMLException(ex.getMessage());
        }
        return objWrap;
    }
            
    public class ResultWrap{
        @AuraEnabled public Digital_Campaign__c objDCampaign{get;set;} //Holds Digital Campaign information
        @AuraEnabled public string strMsg; //Result after Digital Campaign DML
        @AuraEnabled public boolean isOTTExtensionPayloadInfo; //Result after Digital Campaign DML
        @AuraEnabled public Boolean isLockRecord; //To lock record in UI level
        @AuraEnabled public Boolean isEditDate; //To edit date fields in UI level
        @AuraEnabled public Boolean isVRError; //To lock record in UI level
        @AuraEnabled public Boolean isLockDates; //To prevent edit access
        @AuraEnabled public list<PlanDetailsWrap> lstPlanRecords{get;set;} //Holds list of PlanDetails
        @AuraEnabled public Integer totImpressions{get;set;} //Total Impressions
        @AuraEnabled public Boolean yieldExclude{get;set;}
        @AuraEnabled public decimal totCPM{get;set;} //Total Gross(CPM)
        @AuraEnabled public decimal totCOST{get;set;} //Total Gross(Cost)
        @AuraEnabled public decimal desiredBudget{get;set;} //Total Gross(Cost)
        @AuraEnabled public string TotCost_DesiredBudget{get;set;} //Warning message to see conditional color coding
        @AuraEnabled public string profileName; //Result after Digital Campaign DML
        @AuraEnabled public Boolean yisfVisible;
        @AuraEnabled public Boolean isActiveCatalog;
       
    }
    
    public class PlanDetailsWrap{
        @AuraEnabled public integer RecordNum{get;set;} //Record Number
        @AuraEnabled public string RecordId{get;set;} //Record Id
        @AuraEnabled public string startDate{get;set;} //Campaign StartDate
        @AuraEnabled public string endDate{get;set;} //Campaign EndDate
        @AuraEnabled public string selIS{get;set;} //INVENTORY SOURCE
        @AuraEnabled public string selType{get;set;} //SFDC DC TYPE
        @AuraEnabled public string selAud{get;set;} //AUDIENCE
        @AuraEnabled public string selGeoType{get;set;} //GEO TARGET TYPE
        @AuraEnabled public string Notes{get;set;} //NOTES
        @AuraEnabled public integer Impressions{get;set;} //IMPRESSIONS
        @AuraEnabled public Decimal CPM{get;set;} //CPM (GROSS)
        @AuraEnabled public Decimal Cost{get;set;} //COST (GROSS)
        @AuraEnabled public string Industry{get;set;} //Industry
        @AuraEnabled public string LineItemId{get;set;} //LineItemId
        //@AuraEnabled public boolean YieldEx{get;set;}
        @AuraEnabled public string Exclusions{get;set;} //Exclusions 
        @AuraEnabled public Inventory_Source__c objIS{get;set;} //Inventory Source
        @AuraEnabled public boolean isPrimary{get;set;} //IsPrimary
        @AuraEnabled public boolean isEditStDate{get;set;} //To edit date fields in UI level
        @AuraEnabled public boolean isCPMGrrossLocked{get;set;} //To lock CPM/Gross field
    }
	public class SelectOptionObj {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public Boolean isChecked {get; set;}
        
        public SelectOptionObj(String label ,Boolean isChecked) {
            this.label = label;
            this.isChecked = isChecked;
        }
    }
    @AuraEnabled
    public static List<SelectOptionObj> getOptions() {
        List<SelectOptionObj> options = new List<SelectOptionObj>();
        try {
            //Schema.SObjectType obj_describe = Schema.getGlobalDescribe().get(objectApiName) ;
            //Schema.DescribeSObjectResult obj_describe_result = obj_describe.getDescribe() ;
           // Map<String,Schema.SObjectField> fields = obj_describe_result.fields.getMap() ;
            //Schema.DescribeFieldResult fieldResult = fields.get(fieldApiName).getDescribe();
            Schema.DescribeFieldResult fieldResult = Inventory_Source__c.Exclusions__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            SelectOptionObj option = null;
            for (Schema.PicklistEntry pickListVal : ple) {
                option = new SelectOptionObj(pickListVal.getLabel(), pickListVal.isDefaultValue());
                options.add(option);
            }
            
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return options;
    }
    
    
     //SRSF- 4158
     //checks for Activated Interseted
    public static boolean isActiveInterestedCatalog(string strDCCatalogs, set<string> setDCNames){
        boolean isActivatedInterested = false;
        System.debug('strDCCatalogs::'+strDCCatalogs);
        if(!String.isBlank(strDCCatalogs)){
            list<string> lstCatalogs = strDCCatalogs.split(';');
            for(string setDCName : strDCCatalogs.split(';')){
                if(setDCNames.contains(setDCName)){
                    isActivatedInterested = true;      
                }else{
                    isActivatedInterested = false; 
                    break;
                }
            }
        }
        return isActivatedInterested;
    }
    
    //SRSF- 4158 End
 
    
}