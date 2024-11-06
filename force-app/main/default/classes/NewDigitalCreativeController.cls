public class NewDigitalCreativeController {
	
    @AuraEnabled
    public static ResponseWrapper getDigitalCreativeRecordTypes( Id recordId ){
        ResponseWrapper respWrap = new ResponseWrapper();
         
        list<RecordType> lstRecordTypes = new list<RecordType>();
        Schema.DescribeSObjectResult resultObj = Digital_Creative__c.SObjectType.getDescribe();
		List<Schema.RecordTypeInfo> lstRTInfos = resultObj.getRecordTypeInfos();
        Digital_Campaign__c dCampaignObj = [SELECT Id, Proposal__c, Proposal__r.Opportunity__c, Proposal__r.Opportunity__r.OwnerId, Recordtype.Name
	            									FROM Digital_Campaign__c WHERE Id=:recordId limit 1];
        System.debug('dCampaignObj' +dCampaignObj);
        //Added by Madhu for SRSF-1631 on May 10-2019
        for(DCC_Clone_Matrix__mdt objCloneMatrix : [select id,To_Digital_Campaign_RecordType__c,DCC_Recordtype_Name__c from DCC_Clone_Matrix__mdt where To_Digital_Campaign_RecordType__c=:dCampaignObj.Recordtype.Name and DCC_Recordtype_Name__c!=null limit 1]){
            Id AddressableAdsERecordTypeId = Schema.SObjectType.Digital_Creative__c.getRecordTypeInfosByName().get(objCloneMatrix.DCC_Recordtype_Name__c).getRecordTypeId();
            System.debug('AddressableAdsERecordTypeId '+AddressableAdsERecordTypeId);
            lstRecordTypes.add( new RecordType(Id=AddressableAdsERecordTypeId, Name=objCloneMatrix.DCC_Recordtype_Name__c));
        }
        if(lstRecordTypes.isEmpty()){
            for( Schema.RecordTypeInfo rtInfo : lstRTInfos ){
                if( rtInfo.isAvailable() && rtInfo.getName() != 'Master' ){
                    lstRecordTypes.add( new RecordType(Id=rtInfo.getRecordTypeId(), Name=rtInfo.getName()));
                }
            }
        }
         
        respWrap.userPresentInOpptyTeamMember = false;
        if( recordId != null ){
            User usrProfileName = [select u.Profile.Name, u.userRole.Name, u.Team_Role__c from User u where u.id = :Userinfo.getUserId()];
		    if(usrProfileName.Profile.Name  == 'System Administrator' ||
			        usrProfileName.Profile.Name == 'Master - Digital Sales' ||
                    usrProfileName.Profile.Name == 'Master - Digital Planner' ||
			        usrProfileName.Profile.Name == 'Master - Digital Operations' ||
               		usrProfileName.Profile.Name == 'Master - Optimization Manager'||
               		usrProfileName.Profile.Name == 'Master - Enterprise Digital'
              ) {
		      	respWrap.userPresentInOpptyTeamMember = true;
		    }else{
        	    if( dCampaignObj.Proposal__c != null && dCampaignObj.Proposal__r.Opportunity__c != null ){
	                if( dCampaignObj.Proposal__r.Opportunity__r.OwnerId == UserInfo.getUserId() ){
	                	respWrap.userPresentInOpptyTeamMember = true;
	                }else{
		                list<OpportunityTeamMember> opptyTeamMembers = new list<OpportunityTeamMember>([SELECT Id FROM OpportunityTeamMember
		                                                                                                WHERE OpportunityId=:dCampaignObj.Proposal__r.Opportunity__c
		                                                                                               AND UserId=:UserInfo.getUserId()]);
		                if( opptyTeamMembers.size() > 0 ){
		                    respWrap.userPresentInOpptyTeamMember = true;
		                }
	                }
	            }
	        }
        }
        
        respWrap.lstRecordTypes = lstRecordTypes;
        System.debug('respWrap'+respWrap);
        return respWrap;
        //return lstRecordTypes;
    }
    
    @AuraEnabled
    public static map<String, object> getDigitalCampaignRecord( Id recordId ){
        
        Digital_Campaign__c objDC = [SELECT Id, Campaign_Start_Date__c, Campaign_End_Date__c,
                                     Account_Executive__r.Sales_Office__c, Account_Executive__r.Division__c, 
                                     Account_Executive__r.Region__c, Account_Executive__c
                                     FROM Digital_Campaign__c
                                     WHERE Id=:recordId];
        
        map<String, object> pre_populatedFields = new map<String, object>();
        pre_populatedFields.put('Digital_Campaign__c', recordId );
        pre_populatedFields.put('Status__c', '01 Draft Creative' );
        pre_populatedFields.put('Creative_Start_Date__c', objDC.Campaign_Start_Date__c );
        pre_populatedFields.put('Creative_End_Date__c', objDC.Campaign_End_Date__c );
        pre_populatedFields.put('Account_Executive__c', objDC.Account_Executive__c );
        pre_populatedFields.put('Sales_Office__c', objDC.Account_Executive__r.Sales_Office__c );
        pre_populatedFields.put('Division__c', objDC.Account_Executive__r.Division__c );
        pre_populatedFields.put('Region__c', objDC.Account_Executive__r.Region__c );
        pre_populatedFields.put('Source__c', 'New DC' );
        
        System.debug('pre_populatedFields'+pre_populatedFields);
        return pre_populatedFields;
	}
    
    public class ResponseWrapper{
        @AuraEnabled
        public Boolean userPresentInOpptyTeamMember{get;set;}
        @AuraEnabled
        public list<RecordType> lstRecordTypes{get;set;} 
        
        public ResponseWrapper(){}
    }
}