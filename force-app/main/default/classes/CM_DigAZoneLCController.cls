/*
	Author 				 :  M & S
	Date   				 :  Jun 07-17
	Description 		 :  Lightning Controller of CM_DigAZoneLC.cmp 
							Update Zip Code Information into Digital_Campaign__c.Zip_Codes__c from Lightning Component input
	Modification History : 
*/
public class CM_DigAZoneLCController {
    
    @AuraEnabled public static Digital_Campaign__c dcRecord{get;set;} 
    
    @AuraEnabled
    public static ResultWrap PrepareData(String dcRecordId){
        dcRecord = [Select Id,DigA_Zone_Zip_Codes__c, Status__c, Sales_Cannot_Edit_Detail__c, Sales_Cannot_Edit_Status__c,
        	Opportunity__c,Opportunity__r.OwnerId  
         	from Digital_Campaign__c where id=: dcRecordId];
        
        ResultWrap objWrap = new ResultWrap();
        //checking for platform cache
        //DigA Zone
        if (Cache.Org.contains('local.SalesAppOrgPartition.lstDigAZone'))
        {
            objWrap.lstDigAZone = (list<string>) Cache.Org.get('local.SalesAppOrgPartition.lstDigAZone');
            //objWrap.lstDigAZone = getDigAZones();
        }else{
            objWrap.lstDigAZone = getDigAZones();
            Cache.Org.put('local.SalesAppOrgPartition.lstDigAZone',objWrap.lstDigAZone);
        }
        objWrap.lstDigAZone = getDigAZones();
        objWrap.strZipcode = dcRecord.DigA_Zone_Zip_Codes__c;
        
        objWrap.lockRecord = false;
        User userObj = [SELECT ID, Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];
		
        if(!(userObj.Profile.Name == 'System Administrator' || userObj.Profile.Name == 'Master - Digital Operations' || userObj.Profile.Name == 'Master - Digital Traffic')){
            if( !( dcRecord.Status__c == '03 Submitted to Digital Ops' && (userObj.Profile.Name == 'Master - Digital Sales' || userObj.Profile.Name == 'Master - Digital Planner')) 
                    && ( dcRecord.Sales_Cannot_Edit_Detail__c || dcRecord.Sales_Cannot_Edit_Status__c ) 
                    && userObj.Profile.Name != 'System Administrator' && userObj.Profile.Name != 'Master - Digital Operations'  && userObj.Profile.Name != 'Master - Digital Traffic'){
                objWrap.lockRecord = true;
            }
            
            if( !objWrap.lockRecord && dcRecord.Opportunity__c != null && dcRecord.Opportunity__r.OwnerId!=Userinfo.getUserId()){
                list<OpportunityTeamMember> lstOpptyTeamMembers = [SELECT Id FROM OpportunityTeamMember 
                                        WHERE OpportunityId=:dcRecord.Opportunity__c AND UserId=:UserInfo.getUserId()];
                objWrap.lockRecord = lstOpptyTeamMembers != null && lstOpptyTeamMembers.size() > 0 ? false : true;
                
            }
        }
        objWrap.strDigAZoneHelpText=Digital_Campaign__c.DigA_Zone_Zip_Codes__c.getDescribe().getInlineHelpText();
        if(objWrap.strDigAZoneHelpText == null)
            objWrap.strDigAZoneHelpText = 'Enter Tooltip Information in DigA_Zone_Zip_Codes__c field';
        return objWrap;
    }
    
    /*
        Description : Populate list of DigA Zones
    */
    public static list<string> getDigAZones(){
        List<string> srOcl = new List<string>();
        srOcl.add('None');
        for(Zipcode_Mapping__c dzm: [Select id, DigA_Zone__c 
                                             from Zipcode_Mapping__c 
                                             where RecordType.DeveloperName='DigA_Zone' and DigA_Zone__c != null and Is_Active__c=true 
                                             order by DigA_Zone__c]){
            system.debug('--->'+dzm.DigA_Zone__c);
            srOcl.add(dzm.DigA_Zone__c);
        }
        return srOcl;
    }
    
    /*
        Description : update Zip Codes Information into Digital_Campaign__c.DigA_Zone_Zip_Codes__c
    */
    @AuraEnabled
    public static ResultWrap insertZipCodes(String dcRecordId, string lstDZone){
        ResultWrap objWrap = new ResultWrap();
        String strResult = '';
        dcRecord = [Select Id,DigA_Zone_Zip_Codes__c,Sales_Cannot_Edit_Detail__c,zip_codes__c from Digital_Campaign__c where id=: dcRecordId];
        boolean isDCNotEdit = (dcRecord.Sales_Cannot_Edit_Detail__c!=null && dcRecord.Sales_Cannot_Edit_Detail__c==true)? true : false;
        System.debug('lstDZone::'+lstDZone);
        if(!CM_DigitalUtil.isPreventRecordEdit(isDCNotEdit)){
            //Processing Spectrum_Reach_Zones__c data
            //String strAllZipCodes = '';
            set<string> setDZNames = new set<string>( String.isNotBlank( lstDZone ) && lstDZone != 'null' ? lstDZone.split('; ') : new list<String>() );
            setDZNames.remove( null );
            setDZNames.remove( '' );
            
            /*if(!setDZNames.isEmpty()){
                for(Zipcode_Mapping__c dzm: [Select id, Zip_List__c 
                                                 from Zipcode_Mapping__c 
                                                 where DigA_Zone__c in : setDZNames and DigA_Zone__c!=null and RecordType.DeveloperName='DigA_Zone'
                                                 order by DigA_Zone__c] ){
                    if( String.isNotBlank( dzm.Zip_List__c ) )                                 
                        strAllZipCodes += (dzm.Zip_List__c.trim()).replace(' ', '') +',' ;
                }
            }*/
            
            //If the existing Zone is Inactive, but DigA_Zone_Zip_Codes__c field will be hold the Zone value 
            String strExistingDZName = (dcRecord.DigA_Zone_Zip_Codes__c!=null)? dcRecord.DigA_Zone_Zip_Codes__c : '';
            System.debug('----> strExistingDZName: '+strExistingDZName);
            list<string> lstExistingDZName = strExistingDZName.split('; ');//Existing Zones from DC
            set<string> setInactiveDZNames = new set<string>();//Inactive Zones from Custom Settings
            for(Zipcode_Mapping__c obj : [select DigA_Zone__c from Zipcode_Mapping__c where Is_Active__c!=true and RecordType.DeveloperName='DigA_Zone']){
                setInactiveDZNames.add(obj.DigA_Zone__c);
            }
            for(String str : lstExistingDZName){
                if(setInactiveDZNames.contains(str)){
                    setDZNames.add(str);
                }
            }
            list<String> lstDZNames = new list<String>( setDZNames );
            System.debug('----> lstDZNames: '+lstDZNames);
            lstDZNames.sort();
            try{
                dcRecord.DigA_Zone_Zip_Codes__c = lstDZNames != null && lstDZNames.size() > 0 ? String.join( lstDZNames, '; ') : '';
                //Processing duplicate zipcodes
                /*System.debug('----> strAllZipCodes: '+strAllZipCodes );
                set<String> setAllZipCodes = new set<String>( strAllZipCodes.split(',') );
                System.debug('----> setAllZipCodes: '+setAllZipCodes );
                dcRecord.zip_codes__c = String.join( new list<String>( setAllZipCodes ), ', ');*/
                update dcRecord;
                strResult = 'The DigA Zone ZipCodes have been added.';
            }catch (Exception ex){
                strResult+='Error in saving DigA Zone ZipCodes information! Error details:' + ex.getMessage();
            }
        }else
        	strResult = CM_DigitalUtil.strErrMsg;
       
        objWrap.strZipcode = dcRecord.DigA_Zone_Zip_Codes__c;
        objWrap.strMsg = strResult;
        return objWrap;
    }
    
    public class ResultWrap{
        @AuraEnabled public list<string> lstDigAZone;//AVAILABLE DIGA ZONES
        @AuraEnabled public string strZipcode;//Zipcode Info.
        @AuraEnabled public string strMsg;//Result Message after Digital Campaign DML 
        @AuraEnabled public Boolean lockRecord;
        @AuraEnabled public string strDigAZoneHelpText;//Help Text of Digital_Campaign__c.DigA_Zone_Zip_Codes__c 
    }
}