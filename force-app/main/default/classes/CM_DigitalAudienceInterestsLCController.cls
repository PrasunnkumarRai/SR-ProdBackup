/*
	Author 				 :  M & S
	Date   				 :  Jun 07-17
	Description 		 :  Lightning Controller of CM_DigitalAudienceInterestsLC.cmp 
							update Zip Codes Information into Digital_Campaign__c.Audience_Interests__c from Lightning Component input
	Modification History : 
*/
public class CM_DigitalAudienceInterestsLCController {
	@AuraEnabled public static Digital_Campaign__c dcRecord{get;set;}
    
    @AuraEnabled
    public static ResultWrap PrepareData(String dcRecordId){
        System.debug(dcRecordId);
        dcRecord = [Select id, Audience_Interests__c, DigA_Audience_Interests__c,
        	Status__c, Sales_Cannot_Edit_Detail__c, Sales_Cannot_Edit_Status__c,
			Opportunity__c,RecordType.Name,Opportunity__r.OwnerId 
         	from Digital_Campaign__c where id=: dcRecordId];
        ResultWrap objWrap = new ResultWrap();
        objWrap.LockRecord = false;
        //checking for platform cache
        //Standard
        if (Cache.Org.contains('local.SalesAppOrgPartition.lstCntxOptions'))
        {
            objWrap.lstOptions = (list<string>) Cache.Org.get('local.SalesAppOrgPartition.lstCntxOptions');
        }else{
            objWrap.lstOptions = getContextuals();
        }
        
        //DigA
        if (Cache.Org.contains('local.SalesAppOrgPartition.lstAudInt'))
        {
            objWrap.lstDigAAudianceInterests = (list<string>) Cache.Org.get('local.SalesAppOrgPartition.lstAudInt');
        }else{
            objWrap.lstDigAAudianceInterests = getDigAAudianceInterestList(); 
        }
        
        try{
            objWrap.strSelOption = dcRecord.Audience_Interests__c != null ? dcRecord.Audience_Interests__c : '';
            objWrap.selectedDigA = dcRecord.DigA_Audience_Interests__c != null ? dcRecord.DigA_Audience_Interests__c : '';
        }
        catch(Exception ex){
            System.debug('Audience_Interests__c null for this record: ' + ex);    
        }
        User userObj = [SELECT ID, Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];
        if(!(userObj.Profile.Name == 'System Administrator' || userObj.Profile.Name == 'Master - Digital Operations')){
            if( !( dcRecord.Status__c == '03 Submitted to Digital Ops' && (userObj.Profile.Name == 'Master - Digital Sales' || userObj.Profile.Name == 'Master - Digital Planner')) 
               && ( dcRecord.Sales_Cannot_Edit_Detail__c || dcRecord.Sales_Cannot_Edit_Status__c ) 
               /*&& userObj.Profile.Name != 'System Administrator' && userObj.Profile.Name != 'Master - Digital Operations'*/){
                   objWrap.lockRecord = true;
               }   
            
            if( !objWrap.lockRecord && dcRecord.Opportunity__c != null && dcRecord.Opportunity__r.OwnerId!=Userinfo.getUserId()){
                list<OpportunityTeamMember> lstOpptyTeamMembers = [SELECT Id FROM OpportunityTeamMember 
                                                                   WHERE OpportunityId=:dcRecord.Opportunity__c AND UserId=:UserInfo.getUserId()];
                objWrap.lockRecord = lstOpptyTeamMembers != null && lstOpptyTeamMembers.size()>0 ? false : true;
            }
        }
        objWrap.strLblAudInt = Digital_Campaign__c.Audience_Interests__c.getDescribe().getInlineHelpText();
        if(objWrap.strLblAudInt == null)
            objWrap.strLblAudInt = 'Enter Tooltip Information in Audience_Interests__c field.';
        objWrap.strLblDigAAudInt = Digital_Campaign__c.DigA_Audience_Interests__c.getDescribe().getInlineHelpText();
        if(objWrap.strLblDigAAudInt == null)
            objWrap.strLblDigAAudInt = 'Enter Tooltip Information in DigA_Audience_Interests__c field.';
        String strRecTypeName = dcRecord.RecordType.Name;
        strRecTypeName = strRecTypeName.toLowerCase();
        System.debug('strRecTypeName-->'+strRecTypeName);
        set<string> setHideStandardRT = new set<string>{'display custom','pre-roll custom','inventory request - display custom','inventory request - revision - display custom','inventory request - pre-roll custom','inventory request - revision - pre-roll custom'}; 
        boolean isDisplayStd = setHideStandardRT.contains(strRecTypeName) ? false : true;//SRSF-1425
        System.debug('isDisplayStd-->'+isDisplayStd);
        objWrap.isDisplay = isDisplayStd;
//        objWrap.lockRecord = false;
        
        return objWrap;
    }
    
    /*
        Description : Populate list of Contextuals
    */
    public static list<string> getContextuals(){
        List<string> ocl = new List<string>();
        ocl.add('None');
        for(Contextuals__c con: Contextuals__c.getAll().values()){
            ocl.add(con.label__c);
        }
        return ocl; 
    }
    
    /*
        Description : Populate list of Contextuals
    */
    private static list<string> getDigAAudianceInterestList(){
        List<string> ocl = new List<string>();
        ocl.add('None');
        for(DigA_Audience_Interest__c digA : [SELECT Interest__c FROM DigA_Audience_Interest__c where Is_Active__c=true order By Interest__c]){
            ocl.add( digA.Interest__c );
        }
        return ocl; 
    }
    
    /*
        Description : update Information into Digital_Campaign__c.Audience_Interests__c from Component input
    */
    @AuraEnabled
    public static ResultWrap updateAudData(String dcRecordId, string strSelOpts, String selectedDigA){
        System.debug('strSelOpts-->'+strSelOpts);
        String strResult = '';
        ResultWrap objWrap = new ResultWrap();
        try{
            dcRecord = [Select id,Audience_Interests__c,DigA_Audience_Interests__c,Sales_Cannot_Edit_Detail__c,RecordType.Name from Digital_Campaign__c where id=: dcRecordId];
            boolean isDCNotEdit = (dcRecord.Sales_Cannot_Edit_Detail__c!=null && dcRecord.Sales_Cannot_Edit_Detail__c==true)? true : false;
        	if(!CM_DigitalUtil.isPreventRecordEdit(isDCNotEdit)){
                if(strSelOpts!=null)
                    strSelOpts = strSelOpts.replace(',',';');
                if( String.isNotBlank( selectedDigA ) )
                    selectedDigA = selectedDigA.replace(',',';');
                
                //If the existing Interest is Inactive, but DigA_Audience_Interests__c field will be hold the value 
                set<string> setIntNames = new set<string>();
                if(selectedDigA!=null){
                    list<string> lst = selectedDigA.split(';');
                    for(string str : lst){
                        setIntNames.add(str);
                    }
                }
                String strExistingIntName = (dcRecord.DigA_Audience_Interests__c!=null)? dcRecord.DigA_Audience_Interests__c : '';
                list<string> lstExistingIntName = strExistingIntName.split(';');//Existing Interests from DC
                set<string> setInactiveIntNames = new set<string>();//Inactive Zones from Custom Settings
                for(DigA_Audience_Interest__c obj : [select Interest__c from DigA_Audience_Interest__c where Is_Active__c!=true]){
                    setInactiveIntNames.add(obj.Interest__c);
                }
                for(String str : lstExistingIntName){
                    if(setInactiveIntNames.contains(str)){
                        setIntNames.add(str);
                    }
                }
                list<String> lstIntNames = new list<String>( setIntNames );
                System.debug('----> lstIntNames: '+lstIntNames);
                lstIntNames.sort();
                dcRecord.DigA_Audience_Interests__c = lstIntNames != null && lstIntNames.size() > 0 ? String.join( lstIntNames, ';') : '';
                dcRecord.Audience_Interests__c = strSelOpts;
                //dcRecord.DigA_Audience_Interests__c = selectedDigA;
                    
                system.debug(dcRecord.Audience_Interests__c);
                update dcRecord;
                objWrap.lstOptions = getContextuals();
                objWrap.lstDigAAudianceInterests = getDigAAudianceInterestList();
                objWrap.strSelOption = dcRecord.Audience_Interests__c;
                objWrap.selectedDigA = dcRecord.DigA_Audience_Interests__c;
                strResult = 'Success';
            }else
                strResult = CM_DigitalUtil.strErrMsg;
        }catch (Exception ex){
            strResult+='Error in saving information! Error details:' + ex.getMessage();
        }
        String strRecTypeName = dcRecord.RecordType.Name;
        strRecTypeName = strRecTypeName.toLowerCase();
        boolean isDisplayStd = (strRecTypeName!='display custom' && strRecTypeName!='pre roll custom');
        objWrap.isDisplay = isDisplayStd;
        objWrap.strMsg = strResult;
        return objWrap;
    }
    
    public class ResultWrap{
        @AuraEnabled public list<string> lstOptions;//Custom Setting Contextual Options
        @AuraEnabled public list<string> lstDigAAudianceInterests;//Interest__c FROM DigA_Audience_Interest__c
        @AuraEnabled public string selectedDigA;//Selected DigA
        @AuraEnabled public string strSelOption;//Selected Audience Interest
        @AuraEnabled public string strMsg;//Result Message after DML opn.
        @AuraEnabled public string strLblAudInt;//Label of Audience Interest
        @AuraEnabled public string strLblDigAAudInt;//Label of DigAAudience Interest
        @AuraEnabled public Boolean lockRecord;//disable or not
        @AuraEnabled public Boolean isDisplay;//Added for SRSF-536
    }
}