/*
Customer/Project:    Spectrum Reach 
Class name:          DigitalCampaignTriggerUtil
Author/Date:         Madhu    11/16/2020
Related US:          SRSF-2310
Purpose:             Helper class for the DigitalCampaignTriggerHandler

*/
public class DigitalCampaignTriggerUtil {
    
    //Auto populates Zipcodes based on DMA/Zone/Congressional District
    public static list<Digital_Campaign__c> calculateAutoZipcodes(list<Digital_Campaign__c> updatedDigital_Campaigns){
        map<Id,Digital_Campaign__c> mapSource = new map<Id,Digital_Campaign__c>();
        set<string> setDMA = new set<string>();
        set<string> setZones = new set<string>();
        set<string> setCng = new set<string>();
        set<string> setGenre = new set<string>();
        for(Digital_Campaign__c dc : updatedDigital_Campaigns){
            if(dc.Source__c == 'Audience Track'){
                String dma = dc.DMAs__c;
                String zone = dc.Spectrum_Reach_Zones__c;
                //String cngdis = dc.Congressional_Districts__c;
                if( dma!=null && dma!= '' && dma!='None'){
                    setDMA.addAll(dma.split(';'));
                }else if( zone!=null && zone!= '' && zone!='None'){
                    setZones.addAll(zone.split(';'));
                }/*else if( cngdis!=null && cngdis!= '' && cngdis!='None'){
setCng.addAll(cngdis.split(';'));
}*/
                mapSource.put(dc.Id,dc);
                
                if(dc.AdsE_Genre_s__c!=null){
                    String strAdseGenre = dc.AdsE_Genre_s__c;
                    setGenre.addAll(strAdseGenre.split(';'));
                }
                break;//Handling only single record
            }
        }
        
        //Logic for Autopopulate Networks based on Genre
        System.debug('setGenre::'+setGenre);
        map<string,set<string>> mapGenreToNetworks = new map<string,set<string>>();
        list<string> genres = new list<string>();
        if(!setGenre.isEmpty()){
            genres.addAll(setGenre);
            
            String delimtedValues =  String.join(genres, ';');
            System.debug('Genres ' + delimtedValues);
            
            string condition = '';
            for(string val : genres) {
                condition += '\''+ val +'\''+',';
            }
            condition = condition.substring(0, condition.length() - 1);
            string query = 'SELECT Id, Name, Call_Letter__c, AdsE_Genre_s__c  FROM  Networks__c WHERE ActiveNetwork__c = true AND AdsE_Genre_s__c INCLUDES (' + condition + ') order by Name';
            System.debug('Query ' + query);
            List<Networks__c> networks = (List<Networks__c>)Database.query(query);
            set<string> setNW = new set<string>();
            for(Networks__c network : networks){
                setNW.add(network.Name);
                /*System.debug(network.AdsE_Genre_s__c);
                set<string> setNW = new set<string>();
                if(mapGenreToNetworks.containskey(network.AdsE_Genre_s__c)){
                    setNW = mapGenreToNetworks.get(network.AdsE_Genre_s__c);
                }
                setNW.add(network.Name);
                mapGenreToNetworks.put(genres[0],setNW);*/
            }
            mapGenreToNetworks.put(updatedDigital_Campaigns[0].AdsE_Genre_s__c,setNW);
        }
        System.debug(mapGenreToNetworks);
        map<string,string> mapDMA = new map<string,string>();
        map<string,string> mapZone = new map<string,string>();
        map<string,string> mapCngDis = new map<string,string>();
        System.debug(setDMA);
        System.debug(setZones);
        System.debug(setCng);
        if(!setDMA.isEmpty()){
            for(Zipcode_Mapping__c objZip  : [SELECT  Nielsen_DMA_Name__c,Zip_List__c FROM Zipcode_Mapping__c WHERE Nielsen_DMA_Name__c IN : setDMA AND Nielsen_DMA_Name__c != null ORDER BY Nielsen_DMA_Name__c]){
                mapDMA.put(objZip.Nielsen_DMA_Name__c,objZip.Zip_List__c);                                        
            }
        }
        if(!setZones.isEmpty()){
            for(Zipcode_Mapping__c objZip  : [SELECT  SR_Zone_Name__c,Zip_List__c FROM Zipcode_Mapping__c WHERE SR_Zone_Name__c IN : setZones AND SR_Zone_Name__c != null ORDER BY SR_Zone_Name__c]){
                mapZone.put(objZip.SR_Zone_Name__c,objZip.Zip_List__c);                                        
            }
        }
        if(!setCng.isEmpty()){
            for(Zipcode_Mapping__c objZip  : [SELECT  Congressional_District_Name__c,Zip_List__c FROM Zipcode_Mapping__c WHERE Congressional_District_Name__c IN : setCng AND Congressional_District_Name__c != null ORDER BY Congressional_District_Name__c]){
                mapCngDis.put(objZip.Congressional_District_Name__c,objZip.Zip_List__c);                                        
            }
        }
        
        for(Digital_Campaign__c dc : updatedDigital_Campaigns){
            system.debug('dc.Zip_Codes__c---->1'+dc.Zip_Codes__c);
            if(mapSource.containskey(dc.Id)){
               system.debug('dc.Zip_Codes__c---->2'+dc.Zip_Codes__c);
                
                //Networks Logic
                String selNW;
                if(mapGenreToNetworks.containsKey(dc.AdsE_Genre_s__c)){
                    set<string> setNW = mapGenreToNetworks.get(dc.AdsE_Genre_s__c);
                    if(setNW!=null && !setNW.isEmpty()){
                        list<string> lstNW = new list<string>();
                        lstNW.addAll(setNW);
                        lstNW.sort();
                        selNW = '';
                        for(String strNW : lstNW){
                            selNW+=strNW+';';
                        }
                        if(selNW!=''){
                            selNW = selNW.substring(0,selNW.length()-1);
                        }
                    } 
                }
                System.debug('selNW::'+selNW);
                //dc.AdsE_Network__c = selNW;
                
                //Zipcode Logic
                String dma = dc.DMAs__c;
                String zone = dc.Spectrum_Reach_Zones__c;
                // String cngdis = dc.Congressional_Districts__c;
                String zipcodes = '';
                // Start: SRSF-2592    
                 system.debug('dc.Zip_Codes__c---->5'+dc.Zip_Codes__c);              
                if(dc.CustomZipCode__c){
                    zipcodes = dc.Zip_Codes__c;      
                    system.debug('dc.Zip_Codes__c---->6'+zipcodes);              
                } 
                // End: SRSF-2592
                else if( dma!=null && dma!= '' && dma!= 'None'){
                    dc.CustomZipCode__c = false;  // SRSF-2592
                    for(string strDMA : dma.split(';')){
                        zipcodes+= mapDMA.get(strDMA)+',';
                    }
                    if(zipcodes!='')
                        zipcodes = zipcodes.substring(0,zipcodes.length()-1);
                }else if( zone!=null && zone!= '' && zone!= 'None'){
                    dc.CustomZipCode__c = false;  // SRSF-2592
                    for(string strZone : zone.split(';')){
                        zipcodes+= mapZone.get(strZone)+',';
                    }
                    if(zipcodes!='')
                        zipcodes = zipcodes.substring(0,zipcodes.length()-1);
                }/*else if( cngdis!=null && cngdis!= '' && cngdis!= 'None'){
                    dc.CustomZipCode__c = false;  // SRSF-2592
                    for(string strCng : cngdis.split(';')){
                        zipcodes+= mapCngDis.get(strCng)+',';
                    }
                    if(zipcodes!='')
                        zipcodes = zipcodes.substring(0,zipcodes.length()-1);
                }*/
                  system.debug('dc.Zip_Codes__c---->3'+zipcodes);
                
                if(zipcodes!=null && zipcodes != ''){//Removing duplicates
                    set<string> setZip = new set<string>();
                   system.debug('zipcodes'+zipcodes);
                    for(string str : zipcodes.split(',')){
                        //setZip.add(str);  // Commented by Sridhar If the 1st Zipcode is repeated, then it is not removing as repeated zipcode will have space at the beginning
                        setZip.add(str.trim());  // Sridhar : SRSF-2592
                    }
                    system.debug('zipcodes-->3'+zipcodes);
                    list<string> lstSort = new list<string>();
                    lstSort.addAll(setZip);
                    lstSort.sort();
                    zipcodes = '';
                    for(string str : lstSort){
                        //zipcodes=zipcodes+str+',';  // Commented by Sridhar
                        zipcodes=zipcodes+' '+str+','; // Sridhar : SRSF-2592 To add spaces back
                    }
                    zipcodes = zipcodes.substring(0,zipcodes.length()-1);
 system.debug('zipcodes-->4'+zipcodes);
                }
                system.debug('zipcodes'+zipcodes);
// Making Changes for DIR map
                 if(zipcodes =='' || zipcodes == null){
                     dc.Zip_Codes__c =dc.Zip_Codes__c ;}
                    else{
                         dc.Zip_Codes__c = zipcodes;
                    }
// Making Changes for DIR map
               
           system.debug('dc.Zip_Codes__c ----'+dc.Zip_Codes__c);
            }
        }
        
        return updatedDigital_Campaigns;
    }
    
    //checks for Frequency (SRSF-2548)
    public static boolean isFrequencyActivation(Inventory_Source__c objIS, string strDCNetworks, set<string> setNWNames){
        boolean isfrequency = false;
        System.debug('strDCNetworks::'+strDCNetworks);
        if(!String.isBlank(strDCNetworks)){
            list<string> lstNetworks = strDCNetworks.split(';');
            for(string strNWName : strDCNetworks.split(';')){
                if(setNWNames.contains(strNWName)){
                    isfrequency = true;
                    break;
                }
            }
        }
        return isfrequency;
    }
    
    
    
    
    //checks for Split Avail Activation(SRSF-3332)
    public static boolean isSplitAvailActivated(Inventory_Source__c obIS, string strDCNW, set<string> setDCNWNames){
        boolean isSplitActivated = false;
        System.debug('strDCNW::'+strDCNW);
        if(!String.isBlank(strDCNW)){
            list<string> lstNetworks = strDCNW.split(';');
            for(string strNWName : strDCNW.split(';')){
                if(setDCNWNames.contains(strNWName)){
                    isSplitActivated = true;
                    break;
                }
            }   
        }
        return isSplitActivated;
    } 
     //SRSF  - 3579
    public static list<Digital_Campaign__c> flipNewRecordType(list<Digital_Campaign__c> oldDigital_Campaigns,list<Digital_Campaign__c> updatedDigital_Campaigns){
        Id oldStatusId;
        Id revertOldStatusId;
        Id newStatusId;
        Id revertNewStatusId;
        Id tigTypeId = Schema.SObjectType.Digital_Campaign__c.getRecordTypeInfosByName().get('Title in Guide').getRecordTypeId();
        Id invRevTigTypeId = Schema.SObjectType.Digital_Campaign__c.getRecordTypeInfosByName().get('Inventory Request - Revision - Title in Guide').getRecordTypeId();
        for(Digital_Campaign__c objDC : oldDigital_Campaigns){
            if((objDC.status__c != '11 Sales Revision in Progress')  ){
                oldStatusId = objDC.Id;
            }
            if((objDC.status__c != '13 Revision Submitted to Digital Ops')  ){
                revertOldStatusId = objDC.Id;
            }
        }
    
        for(Digital_Campaign__c objDC : updatedDigital_Campaigns){
            if((objDC.status__c == '11 Sales Revision in Progress')  ){
                newStatusId = objDC.Id;
            }
            if((objDC.status__c == '13 Revision Submitted to Digital Ops')  ){
                revertNewStatusId = objDC.Id;
            }
        }
       
        if(oldStatusId != null){
            for(Digital_Campaign__c objDC : updatedDigital_Campaigns){
                if(oldStatusId != null && newStatusId == objDC.Id){
                    if(objDC.RecordtypeId==tigTypeId){
                        objDC.RecordTypeId = invRevTigTypeId ;
                    }
                }
            }
        }
        if(revertOldStatusId != null){
            for(Digital_Campaign__c objDC : updatedDigital_Campaigns){
                if(revertOldStatusId != null && revertNewStatusId == objDC.Id){
                    if(objDC.RecordtypeId == invRevTigTypeId){
                        objDC.RecordTypeId = tigTypeId ;
                    }
                }
            }
        }
        return updatedDigital_Campaigns;
    }
 //SRSF  - 3579 
    //if the recordtype is makegood and status is "Plan Approved", need to flip the recordtype
    public static list<Digital_Campaign__c> flipRecordType(list<Digital_Campaign__c> updatedDigital_Campaigns){
        map<string,string> mapDCToRT = new map<string,string>();
        set<String> digitalCampaignIdSet = new set<String>(); 
        set<string> mapDCRT = new set<string>();
        for(Digital_Campaign__c objDC : updatedDigital_Campaigns){
            if(objDC.status__c == 'Plan Approved' || objDC.status__c == '03 Submitted to Digital Ops'){
                mapDCRT.add(objDC.RecordtypeId);
                mapDCToRT.put(objDC.Id,objDC.RecordtypeId);
            } 
            //SRSF-4062
            if((objDC.status__c == 'Plan Approved' || objDC.status__c == '01 Draft Campaign')  ){
                digitalCampaignIdSet.add(objDC.Id);
            }
            //SRSF-4062 
        }
        System.debug('mapDCToRT::'+mapDCToRT);
        if(!mapDCRT.isEmpty()){
            map<String,String> mapDCToMakegoodDC = new map<String,String>();
            map<String,String> mapDCMakegoodRTName = new map<string,string>();
            set<string> setRTName = new set<string>();
            for(Digital_Campaign__c objDC : [SELECT Id,Recordtype.Name FROM Digital_Campaign__c WHERE Id in : mapDCToRT.keySet() AND Recordtype.Name LIKE '%Makegood%']){
                mapDCMakegoodRTName.put(objDC.Id, objDC.Recordtype.Name);
                setRTName.add(objDC.Recordtype.Name);
            }
            for(DC_Makegood_To_General_Recordtype__mdt objCloneMatrix : [SELECT From_Makegood_DC__c,To_General_DC__c FROM DC_Makegood_To_General_Recordtype__mdt WHERE From_Makegood_DC__c IN:setRTName]){
                mapDCToMakegoodDC.put(objCloneMatrix.From_Makegood_DC__c, objCloneMatrix.To_General_DC__c);
            }
            map<string,string> mapRTNameToId = new map<string,string>();
            for(RecordType objRT : [SELECT Id,name FROM RecordType WHERE sobjecttype = 'Digital_Campaign__c' AND Name IN: mapDCToMakegoodDC.values()]){
                mapRTNameToId.put(objRT.Name, objRT.Id);
            }
            
            for(Digital_Campaign__c objDC : updatedDigital_Campaigns){
                if(mapDCMakegoodRTName.containskey(objDC.Id)){
                    String currentRTName = mapDCMakegoodRTName.get(objDC.Id);
                    System.debug('Before::'+currentRTName);
                    String toRTName;
                    if(mapDCToMakegoodDC.containskey(currentRTName)){
                        toRTName = mapDCToMakegoodDC.get(currentRTName);
                    }
                    System.debug('toRTName::'+toRTName);
                    if(String.isNotBlank(toRTName) && mapRTNameToId.containskey(toRTName)){
                        String newRTId = mapRTNameToId.get(toRTName);
                        objDC.RecordTypeId = newRTId;
                        if(toRTName == 'Social' || toRTName == 'Search' || toRTName == 'Pre-roll' || toRTName == 'Display') {
                            objDC.Status__c = '03 Submitted to Digital Ops';
                        } else {
                            objDC.Status__c = '01 Draft Campaign';
                        }            
                    }
                }
            }
        }
   
    
    
        
        //SRSF-4062
        Id propRecTypeId = Schema.SObjectType.Digital_Campaign__c.getRecordTypeInfosByName().get('Programmatic Guaranteed').getRecordTypeId();
        Id nonProRecTypeId = Schema.SObjectType.Digital_Campaign__c.getRecordTypeInfosByName().get('Programmatic Non Guaranteed').getRecordTypeId();
        Id invPropRecTypeId = Schema.SObjectType.Digital_Campaign__c.getRecordTypeInfosByName().get('Inventory Request - Programmatic Guaranteed').getRecordTypeId();
        Id invNonProRecTypeId = Schema.SObjectType.Digital_Campaign__c.getRecordTypeInfosByName().get('Inventory Request - Programmatic Non Guaranteed').getRecordTypeId();
        System.debug('***digitalCampaignIdSet::'+digitalCampaignIdSet);
        if(!digitalCampaignIdSet.isEmpty()){
            for(Digital_Campaign__c objDC : updatedDigital_Campaigns){
                if(digitalCampaignIdSet.contains(objDC.Id)){
                    if(objDC.RecordtypeId==invPropRecTypeId){
                        objDC.RecordTypeId = propRecTypeId ;
                        System.debug('***in if');
                    }
                    if(objDC.RecordtypeId==invNonProRecTypeId){
                        objDC.RecordTypeId = nonProRecTypeId ;
                        System.debug('***in else');
                    }
                }
            }
        }
        //SRSF-4062

        //SRSF  - 3579
        Id tigTypeId = Schema.SObjectType.Digital_Campaign__c.getRecordTypeInfosByName().get('Title in Guide').getRecordTypeId();
        Id invTigTypeId = Schema.SObjectType.Digital_Campaign__c.getRecordTypeInfosByName().get('Inventory Request - Title in Guide').getRecordTypeId();
        if(!digitalCampaignIdSet.isEmpty()){
            for(Digital_Campaign__c objDC : updatedDigital_Campaigns){
                if(digitalCampaignIdSet.contains(objDC.Id)){
                    if(objDC.RecordtypeId==invTigTypeId){
                        objDC.RecordTypeId = tigTypeId ;
                        objDC.status__c = '01 Draft Campaign';
                    }
                }
            }
        }
        for(Digital_Campaign__c objDC : updatedDigital_Campaigns){
            if(objDC.status__c == 'Draft Plan'){
                if(objDC.RecordtypeId==tigTypeId){
                    objDC.RecordTypeId = invTigTypeId ;
                    objDC.status__c = 'Draft Plan';
                }
            }
        }
        //SRSF  - 3579
        System.debug('***updatedDigital_Campaigns::'+updatedDigital_Campaigns); 
        return updatedDigital_Campaigns;
    }
    
    public static map<string,string> getTimezoneByDMA(List<string> locations){
        map<string,string> mapTimezone = new map<string,string>();
        for(Zipcode_Mapping__c zipMapping : [SELECT Nielsen_DMA_Name__c,Time_Zones__c FROM Zipcode_Mapping__c WHERE Nielsen_DMA_Name__c IN:locations AND Nielsen_DMA_Name__c != null AND Time_Zones__c != null ORDER BY Nielsen_DMA_Name__c]){
            mapTimezone.put(zipMapping.Nielsen_DMA_Name__c,zipMapping.Time_Zones__c);                                          
        }
        return mapTimezone;
    }
    
    public static map<string,string> getTimezoneByZone(List<string> locations){
        map<string,string> mapTimezone = new map<string,string>();
        for(Zipcode_Mapping__c zipMapping : [SELECT SR_Zone_Name__c,Time_Zones__c FROM Zipcode_Mapping__c WHERE SR_Zone_Name__c IN:locations AND SR_Zone_Name__c != null AND Time_Zones__c != null ORDER BY SR_Zone_Name__c]){
            mapTimezone.put(zipMapping.SR_Zone_Name__c,zipMapping.Time_Zones__c);                                          
        }
        return mapTimezone;
    }
    
    public static map<string,string> getTimezoneByState(List<string> locations){
        map<string,string> mapTimezone = new map<string,string>();
        for(Zipcode_Mapping__c zipMapping : [SELECT State__c,Time_Zones__c FROM Zipcode_Mapping__c WHERE State__c IN:locations AND State__c != null AND Time_Zones__c != null ORDER BY State__c]){
            mapTimezone.put(zipMapping.State__c,zipMapping.Time_Zones__c);                                          
        }
        return mapTimezone; 
    }
    
    //SRSF-4273: To update the zipcode History of DC.
     public static void createZipCodeHistory(Digital_Campaign__c[] oldDigital_Campaigns, Map<Id, Digital_Campaign__c> newDigital_CampaignsMap,Map<ID, Digital_Campaign__c> digitalCampaignMap){
        
        List<ZipCode_History__c> zipLst = new List <ZipCode_History__c>();
        for(Digital_Campaign__c dc : newDigital_CampaignsMap.values()){
           
            if(digitalCampaignMap.get(dc.id).Zip_Codes__c!=dc.Zip_Codes__c || 
            digitalCampaignMap.get(dc.id).State__c!=dc.State__c || 
            digitalCampaignMap.get(dc.id).DMAs__c!=dc.DMAs__c ||
            digitalCampaignMap.get(dc.id).Spectrum_Reach_Zones__c!=dc.Spectrum_Reach_Zones__c){
                System.debug('digitalCampaignMap-->'+digitalCampaignMap.get(dc.id).DMAs__c);
                System.debug('digitalCampaignMap states-->'+digitalCampaignMap.get(dc.id).State__c);

                //track zipcodes
                Set<String> oldZips = new Set<String>();
                Set<String> newZips = new Set<String>();
                if (digitalCampaignMap.get(dc.id).Zip_Codes__c != null) {
                oldZips.addAll(digitalCampaignMap.get(dc.id).Zip_Codes__c.split(',')); //to store the old zipcode values.
                }
                if (dc.Zip_Codes__c != null) {
                newZips.addAll(dc.Zip_Codes__c.split(',')); //to store the old zipcode values.
                }
                Set<String> addedZips = newZips.clone(); //cloning the new zipcode values to check the newly added values.
                addedZips.removeAll(oldZips); //removed all the Old zipcodes to get the newly added zipcodes.
                Set<String> removedZips = oldZips.clone(); //cloning the old zipcode values to check the removed zipcode values.
                removedZips.removeAll(newZips); //removed all the new zipcodes to get the removed zipcodes.

                //track DMAs --------------------------------------------------------------------------------------------------------
                Set<String> oldDMAs = new Set<String>();
                Set<String> newDMAs = new Set<String>();
                if(digitalCampaignMap.get(dc.id).DMAs__c !=null){
                    oldDMAs.addAll(digitalCampaignMap.get(dc.id).DMAs__c.split(';'));
                }

                if(dc.DMAs__c !=null){
                    newDMAs.addAll(dc.DMAs__c.split(';'));
                }
                Set<String> addedDMAs = newDMAs.clone();
                addedDMAs.removeAll(oldDMAs);
                Set<String> removedDMAs = oldDMAs.clone();
                removedDMAs.removeAll(newDMAs);

                //SRSF - 4529 (Zipcode Changes - Additions and Removals) Track States --------------------------------------------------------------------------------------------------------
                Set<String> oldStates = new Set<String>();
                Set<String> newStates = new Set<String>();
                if(digitalCampaignMap.get(dc.id).State__c !=null){
                    oldStates.addAll(digitalCampaignMap.get(dc.id).State__c.split(';'));
                }

                if(dc.State__c !=null){
                    newStates.addAll(dc.State__c.split(';'));
                }

                Set<String> addedStates = newStates.clone();
                addedStates.removeAll(oldStates);
                Set<String> removedStates = oldStates.clone();
                removedStates.removeAll(newStates);

                //SRSF - 4529 (Zipcode Changes - Additions and Removals) track Zones --------------------------------------------------------------------------------------------------------
                Set<String> oldZones = new Set<String>();
                Set<String> newZones = new Set<String>();
                if(digitalCampaignMap.get(dc.id).Spectrum_Reach_Zones__c !=null){
                    oldZones.addAll(digitalCampaignMap.get(dc.id).Spectrum_Reach_Zones__c.split(';'));
                }

                if(dc.Spectrum_Reach_Zones__c !=null){
                    newZones.addAll(dc.Spectrum_Reach_Zones__c.split(';'));
                }

                Set<String> addedZones = newZones.clone();
                addedZones.removeAll(oldZones);
                Set<String> removedZones = oldZones.clone();
                removedZones.removeAll(newZones);


                ZipCode_History__c zipHistory = new ZipCode_History__c();
                zipHistory.OldValue__c = digitalCampaignMap.get(dc.id).Zip_Codes__c;
                zipHistory.NewValue__c = dc.Zip_Codes__c;
                zipHistory.Digital_Campaign__c = dc.Id;
                zipHistory.Added_ZipCode__c = String.join(new List<String>(addedZips), ',');
                zipHistory.Removed_ZipCode__c = String.join(new List<String>(removedZips), ',');
                zipHistory.Added_DMAs__c = String.join(new List<String>(addedDMAs), ';');
                zipHistory.Removed_DMAs__c = String.join(new List<String>(removedDMAs), ';');
                zipHistory.Added_States__c = String.join(new List<String>(addedStates), ';');
                zipHistory.Removed_States__c = String.join(new List<String>(removedStates), ';');
                zipHistory.Added_Zones__c = String.join(new List<String>(addedZones), ';');
                zipHistory.Removed_Zones__c = String.join(new List<String>(removedZones), ';');
                
                zipLst.add(zipHistory);
            }
        }
        if(zipLst.size()>0){
             insert zipLst;
        }
        
    } 
    
}