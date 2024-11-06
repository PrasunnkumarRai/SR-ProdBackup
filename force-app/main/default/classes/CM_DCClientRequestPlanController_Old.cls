/*
    Author : MAndS 
    Date   : May 14-2020
    Description : Lightning component Apex controller of CM_DCClientRequestPlanDetails to Add/Remove/Update plan details on DigitalCampaign
    Modification History : 
*/
public class CM_DCClientRequestPlanController_Old{
    
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
            Digital_Campaign__c dcRecord = [Select Id,Campaign_Start_Date__c,Campaign_End_Date__c,
                                            		Freewheel_O_O_Affiliate_Direct_Info__c,TTD_CTV_Info__c,
                                            		Freewheel_FF_OTT_Info__c,Freewheel_FF_TVE_Info__c,
                                            		ClientRequestFormPlanDetails_Notes__c,Is_Freewheel_FF_OTT_Primary__c,
                                            		AdsE_Platform_s__c
                    from Digital_Campaign__c where id=: dcRecordId ];
            if(dcRecord.Campaign_Start_Date__c==null)
                dcRecord.Campaign_Start_Date__c = Date.today();
            if(dcRecord.Campaign_End_Date__c==null){
                dcRecord.Campaign_End_Date__c = Date.today();
                objWrap.isLockRecord = true;
            }
            list<PlanDetailsWrap> lstPlanRecords = new list<PlanDetailsWrap>();
            string strnotes = dcRecord.ClientRequestFormPlanDetails_Notes__c;
            string freewheelNotes='';
            string freewheelFFOTTNotes='';
            string freewheelFFProgrammerNotes='';
            string freequencenotes='';
            System.debug('strnotes::'+strnotes);
            if(strnotes!=null){
                list<string> lstnotes = new list<string>();
                lstnotes = strnotes.split(';');
                System.debug('lstnotes::'+lstnotes);
                if(lstnotes!=null && !lstnotes.isEmpty()){
                    for(string str : lstnotes){
                        if(str!=null && str!='' && str.contains(':')){
                            if(str.contains('Freewheel – O&O/Affiliate/Direct:')){
                                if(str.split(':').size()>1)
                                	freewheelnotes = str.split(':')[1];
                            }
                            else if(str.contains('Freewheel - FF OTT:')){
                                if(str.split(':').size()>1)
                                	freewheelFFOTTNotes = str.split(':')[1];
                            }
                            else if(str.contains('Freewheel – FF TVE:')){
                                if(str.split(':').size()>1)
                                	freewheelFFProgrammerNotes = str.split(':')[1];
                            }
                            else if(str.contains('TTD - CTV:')){
                                if(str.split(':').size()>1)
                                	freequencenotes = str.split(':')[1];
                            }
                        }
                    }
                }
            }
            if(dcRecord.Freewheel_O_O_Affiliate_Direct_Info__c!=null && dcRecord.Freewheel_O_O_Affiliate_Direct_Info__c!='')
            {
                PlanDetailsWrap obj = getDetails(dcRecord.Freewheel_O_O_Affiliate_Direct_Info__c);
                obj.RecordNum = lstPlanRecords.size();
                obj.notes = freewheelnotes;
                System.debug(obj);
                lstPlanRecords.add(obj);
            }
            if(dcRecord.Freewheel_FF_OTT_Info__c!=null && dcRecord.Freewheel_FF_OTT_Info__c!='')
            {
                PlanDetailsWrap obj = getDetails(dcRecord.Freewheel_FF_OTT_Info__c);
                obj.RecordNum = lstPlanRecords.size();
                obj.notes = freewheelFFOTTNotes;
                System.debug(obj);
                lstPlanRecords.add(obj);
            }
            if(dcRecord.Freewheel_FF_TVE_Info__c!=null && dcRecord.Freewheel_FF_TVE_Info__c!='')
            {
                PlanDetailsWrap obj = getDetails(dcRecord.Freewheel_FF_TVE_Info__c);
                obj.RecordNum = lstPlanRecords.size();
                obj.notes = freewheelFFProgrammerNotes;
                System.debug(obj);
                lstPlanRecords.add(obj);
            }
            if(dcRecord.TTD_CTV_Info__c!=null && dcRecord.TTD_CTV_Info__c!='')
            {
                PlanDetailsWrap obj = getDetails(dcRecord.TTD_CTV_Info__c);
                obj.RecordNum = lstPlanRecords.size();
                obj.notes = freequencenotes;
                System.debug(obj);
                lstPlanRecords.add(obj);
            }
            string profileName = [SELECT Id, Name FROM Profile WHERE Id =:UserInfo.getProfileId()].Name;
            string strAccessableProfiles = System.Label.CM_ClientRequestPlanDetailsProfiles;
            objWrap.isOTTExtensionPayloadInfo = strAccessableProfiles.contains(profileName) && dcRecord.Is_Freewheel_FF_OTT_Primary__c;
            objWrap.objDCampaign = dcRecord;
            objWrap.lstPlanRecords = lstPlanRecords;
            
        }catch( Exception ex){
            System.debug('Error::'+ex.getMessage());
            objWrap.strMsg = 'Error : '+ex.getMessage();
        }
        return objWrap;
    }
    
    //Preparing Wraper object from the string
    public static PlanDetailsWrap getDetails(string info){
        list<string> lst = info.split(':');
        PlanDetailsWrap obj = new PlanDetailsWrap();
        obj.selIS = lst[0]; //INVENTORY SOURCE
        obj.selType = lst[1]; //SFDC DC TYPE
        obj.selAud = lst[2]; //AUDIENCE
        obj.selGeoType = lst[3]; //GEO TARGET TYPE
        obj.Impressions = (lst.size()>4 && lst[4]!=null && lst[4]!='')? Integer.valueOf(lst[4]) : null; //IMPRESSIONS
        obj.CPM = (lst.size()>5 && lst[5]!=null && lst[5]!='')? Decimal.valueOf(lst[5]) : null; //CPM (GROSS)
        obj.Cost = (lst.size()>6 && lst[6]!=null && lst[6]!='')? Decimal.valueOf(lst[6]) : null; //COST (GROSS)
        obj.isPrimary = (lst.size()>7 && lst[7]!=null && lst[7]!='')? boolean.valueOf(lst[7]) : null; //IsPrimary
        System.debug(obj);
        return obj;
    }
    
    /**
     	MethodName  : PrepareData
		Input       : DigitalCampaign Id
		Output      : List of Plan Records
     	Description : Aura enabled method to update the data 
     */
    @AuraEnabled
    public static ResultWrap UpdateData(String dcRecordId, String strData, String notes, String primaryInventorySource, boolean isOTTPrimaryVal){
        System.debug('dcRecordId::'+dcRecordId);
        System.debug('strData::'+strData);
        System.debug('notes::'+notes);
        ResultWrap objWrap = new ResultWrap();
        objWrap.isLockRecord = false;
        objWrap.isVRError = false;
        try{
        	Digital_Campaign__c dcRecord = [Select Id,Campaign_Start_Date__c,Campaign_End_Date__c,
                                            		Freewheel_O_O_Affiliate_Direct_Info__c,TTD_CTV_Info__c,
                                            		Freewheel_FF_OTT_Info__c,Freewheel_FF_TVE_Info__c,
                                            		ClientRequestFormPlanDetails_Notes__c,Is_Freewheel_FF_OTT_Primary__c,
                                            		AdsE_Platform_s__c
                    from Digital_Campaign__c where id=: dcRecordId];
            System.debug('isOTTPrimaryVal::'+dcRecord.AdsE_Platform_s__c);
            System.debug('AdsE_Platform_s__c::'+notes);
            if(dcRecord.AdsE_Platform_s__c != '3rd Party Apps' && primaryInventorySource== 'Freewheel – FF TVE'){
                objWrap.isVRError = true;
                objWrap.strMsg = 'Select Platform(s) should be \'3rd Party Apps\' when Freewheel – FF OTT is primary.'; 
                return objWrap;
            }
            if(strData!=null && strData!=''){
                list<string> lst = strdata.split(';');
                if(!lst.isEmpty()){
                    System.debug('size:'+lst.size());
                    String strDirect;
                    String strOTT;
                    string strTVE;
                    string strCTV;
                    for(string str : lst){
                        System.debug('str::'+str);
                        if(str.contains('Freewheel – O&O/Affiliate/Direct:'))
                            strDirect = str;
                        else if(str.contains('Freewheel - FF OTT:'))
                            strOTT = str; 
                        else if(str.contains('Freewheel – FF TVE:'))
                            strTVE = str;
                        else if(str.contains('TTD - CTV:'))
                            strCTV = str;
                    }
                    dcRecord.Freewheel_O_O_Affiliate_Direct_Info__c = strDirect;
                    dcRecord.Freewheel_FF_OTT_Info__c = strOTT;
                    dcRecord.Freewheel_FF_TVE_Info__c = strTVE;
                    dcRecord.TTD_CTV_Info__c = strCTV;
                }else{
                    dcRecord.TTD_CTV_Info__c = null;
                    dcRecord.Freewheel_FF_OTT_Info__c = null;
                    dcRecord.Freewheel_FF_TVE_Info__c = null;
                    dcRecord.Freewheel_O_O_Affiliate_Direct_Info__c = null;
                }
                dcRecord.ClientRequestFormPlanDetails_Notes__c = notes;
            }else{
                dcRecord.TTD_CTV_Info__c = null;
                dcRecord.Freewheel_O_O_Affiliate_Direct_Info__c = null;
                dcRecord.Freewheel_FF_TVE_Info__c = null;
                dcRecord.Freewheel_O_O_Affiliate_Direct_Info__c = null;
            }
            dcRecord.Is_Freewheel_FF_OTT_Primary__c = isOTTPrimaryVal;
            if(isOTTPrimaryVal)
                dcRecord.AdsE_Platform_s__c = null;
            update dcRecord;
            string profileName = [SELECT Id, Name FROM Profile WHERE Id =:UserInfo.getProfileId()].Name;
            string strAccessableProfiles = System.Label.CM_ClientRequestPlanDetailsProfiles;
            objWrap.isOTTExtensionPayloadInfo = strAccessableProfiles.contains(profileName) && dcRecord.Is_Freewheel_FF_OTT_Primary__c;
            objWrap.strMsg = 'Client Request Form Plan Details have been added successfully.';
        	objWrap.objDCampaign = dcRecord;
        }catch( Exception ex){
            objWrap.isVRError = true;
            objWrap.strMsg = ex.getMessage();
        }
        return objWrap;
    }
            
    public class ResultWrap{
        @AuraEnabled public Digital_Campaign__c objDCampaign; //Holds Digital Campaign information
        @AuraEnabled public string strMsg; //Result after Digital Campaign DML
        @AuraEnabled public boolean isOTTExtensionPayloadInfo; //Result after Digital Campaign DML
        @AuraEnabled public Boolean isLockRecord; //To lock record in UI level
        @AuraEnabled public Boolean isVRError; //To lock record in UI level
        @AuraEnabled public list<PlanDetailsWrap> lstPlanRecords{get;set;} //Holds list of PlanDetails
    }
    
    public class PlanDetailsWrap{
        @AuraEnabled public integer RecordNum{get;set;} //Record Number
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
        @AuraEnabled public boolean isPrimary{get;set;} //IsPrimary
    }
}