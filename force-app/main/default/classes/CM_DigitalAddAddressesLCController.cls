/*
	Author 				 :  M & S
	Date   				 :  Jun 07-17
	Description 		 :  Lightning Controller of CM_DigitalAddAddressesLC.cmp 
							update Address information into Digital_Campaign__c.Address__c
	Modification History : 
*/
public class CM_DigitalAddAddressesLCController {
    @AuraEnabled public static Digital_Campaign__c dcRecord{get;set;}
    @AuraEnabled public static List<String> addList{get;set;}
    
    //Retrieving Digital_Campaign__c.Address__c
    @AuraEnabled 
    public static ResultWrap PrepareData(String dcRecordId){
    	ResultWrap objWrap = new ResultWrap();
        String strResult = '';
        dcRecord = [Select Id,Address__c, Status__c, Sales_Cannot_Edit_Detail__c, Sales_Cannot_Edit_Status__c,
        			Opportunity__c
        			from Digital_Campaign__c where id=: dcRecordId];
        addList = new List<String>();
        try{
            if(dcRecord.Address__c!=null)
            	addList = dcRecord.Address__c.split(System.label.CM_DigitalAddressLineSeparator);        
            objWrap.lstAddress = addList;
            objWrap.lockRecord = false;
           	User userObj = [SELECT ID, Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];
			
            if(!(userObj.Profile.Name == 'System Administrator' || userObj.Profile.Name == 'Master - Digital Operations' || userObj.Profile.Name == 'Master - Digital Traffic')){
                if( !( dcRecord.Status__c == '03 Submitted to Digital Ops' && (userObj.Profile.Name == 'Master - Digital Sales' || userObj.Profile.Name == 'Master - Digital Planner')) 
                        && ( dcRecord.Sales_Cannot_Edit_Detail__c || dcRecord.Sales_Cannot_Edit_Status__c ) 
                        && userObj.Profile.Name != 'System Administrator' && userObj.Profile.Name != 'Master - Digital Operations' && userObj.Profile.Name != 'Master - Digital Traffic'){
                    objWrap.lockRecord = true;
                }   
                
                if( !objWrap.lockRecord && dcRecord.Opportunity__c != null ){
                    list<OpportunityTeamMember> lstOpptyTeamMembers = [SELECT Id FROM OpportunityTeamMember 
                                            WHERE OpportunityId=:dcRecord.Opportunity__c AND UserId=:UserInfo.getUserId()];
                    objWrap.lockRecord = lstOpptyTeamMembers != null && lstOpptyTeamMembers.size() > 0 ? false : true;
                }
            }
            
            //addList.add('testS, testC, TX, 500082|Conquest|150');
        }
        catch(Exception ex){
            System.debug('Address information null for Digital Campaign: ' + ex);
        }
        return objWrap;
    }
    
    /*
        Description : update Address information into Digital_Campaign__c.Address__c from Component input
    */
    @AuraEnabled
    public static ResultWrap insertAddress(string dcRecordId,string street,string city,string state,string zip,string type,string radius,boolean isNone){
        ResultWrap objWrap = new ResultWrap();
        String strResult = '';
        if((street!=null&&street!='' && city!=null&&city!='' && state!=null&&state!='' && zip!=null&&zip!='') || (isNone!=null && isNone==true)){
            try{
                addList = new List<String>();
                dcRecord = [Select Id,Address__c,Sales_Cannot_Edit_Detail__c from Digital_Campaign__c where id=: dcRecordId];
                boolean isDCNotEdit = (dcRecord.Sales_Cannot_Edit_Detail__c!=null && dcRecord.Sales_Cannot_Edit_Detail__c==true)? true : false;
        		if(!CM_DigitalUtil.isPreventRecordEdit(isDCNotEdit)){
                    if(dcRecord.Address__c!=null)
                        addList = dcRecord.Address__c.split(System.label.CM_DigitalAddressLineSeparator);
                    if(isNone!=null && isNone==true){
                        street = 'None';
                        city = 'None';
                        state = 'None';
                        zip = 'None';
                        type = 'None';
                        radius = 'None';
                    }
                    addList.add(street + ', ' + city + ', ' + state + ', ' + zip + System.label.CM_DigitalAddressSeparator + type + System.label.CM_DigitalAddressSeparator + radius);
                    dcRecord.Address__c = String.join(addList,System.label.CM_DigitalAddressLineSeparator);     
                    update dcRecord;
                    strResult = 'Success';
                }else
                    strResult = CM_DigitalUtil.strErrMsg;
            }catch (Exception ex){
                strResult+='Error in saving information! Error details:' + ex.getMessage();
            }
        }else{
            strResult = 'Error! Please provide Street, City, State and Zip information to Add Address.';
        }
        objWrap.strMsg = strResult;
        objWrap.lstAddress = addList;
        return objWrap;   
    }
    
    /*
        Description : delete Address information into Digital_Campaign__c.Address__c from Component input
    */
    @AuraEnabled
    public static ResultWrap deleteAddressCC(string dcRecordId,Integer rowInd){
        ResultWrap objWrap = new ResultWrap();
        String strResult = '';
        try{
            dcRecord = [Select Id,Address__c from Digital_Campaign__c where id=: dcRecordId];
            if(dcRecord.Address__c!=null)
            	addList = dcRecord.Address__c.split(System.label.CM_DigitalAddressLineSeparator);
            addList.remove(rowInd);
            dcRecord.Address__c = String.join(addList,System.label.CM_DigitalAddressLineSeparator);     
            update dcRecord;
            strResult = 'Success';
        }catch (Exception ex){
            strResult+='Error in deleting information! Error details:' + ex;
        }   
        objWrap.strMsg = strResult;
        objWrap.lstAddress = addList;
        return objWrap;
    }
    
    public class ResultWrap{
        @AuraEnabled public list<string> lstAddress;//EXISTING ADDRESSES
        @AuraEnabled public String strMsg;//Result Message after Digital Campaign DML
        @AuraEnabled public Boolean lockRecord;
    }
}