public class NewDigitalCampaignController {
	
    @AuraEnabled
    public static ResponseWrapper getDigitalCampaignRecordTypes( Id recordId ){
        ResponseWrapper respWrap = new ResponseWrapper();
        list<RecordType> lstRecordTypes = new list<RecordType>();
        Schema.DescribeSObjectResult resultObj = Digital_Campaign__c.SObjectType.getDescribe();
		List<Schema.RecordTypeInfo> lstRTInfos = resultObj.getRecordTypeInfos();
        for( Schema.RecordTypeInfo rtInfo : lstRTInfos ){
          //SRSF-4062
            /* Added () rtInfo.getName()!= 'Programmatic Non Guaranteed' && rtInfo.getName()!='Programmatic Guaranteed') condition to remove the both record type selection from picklist*/
            if( rtInfo.isAvailable() && rtInfo.getName() != 'Master' && rtInfo.getName()!= 'Programmatic Non Guaranteed' && rtInfo.getName()!='Programmatic Guaranteed'
              && rtInfo.getName()!='Inventory Request - Revision - Programmatic Non Guaranteed' && rtInfo.getName()!='Inventory Request - Revision - Programmatic Guaranteed'){
                lstRecordTypes.add( new RecordType(Id=rtInfo.getRecordTypeId(), Name=rtInfo.getName()));
            }
        }
        respWrap.userPresentInOpptyTeamMember = false;
        if( recordId != null ){
        	
        	User usrProfileName = [select u.Profile.Name, u.userRole.Name, u.Team_Role__c from User u where u.id = :Userinfo.getUserId()];
		    if(usrProfileName.Profile.Name  == 'System Administrator' ||
			        usrProfileName.Profile.Name == 'Master - Digital Sales' ||
                    usrProfileName.Profile.Name == 'Master - Digital Planner' ||
			        usrProfileName.Profile.Name == 'Master - Digital Operations' ||
                    usrProfileName.Profile.Name == 'Master - Digital Traffic' ||
               		usrProfileName.Profile.Name == 'Master - Enterprise Digital' ||
               		usrProfileName.Profile.Name == 'Master - Optimization Manager'
              ) {
		      	respWrap.userPresentInOpptyTeamMember = true;
		    }else{
	        	Proposal__c proposalObj;
                try {
                    proposalObj = [SELECT Id, Opportunity__c, Opportunity__r.OwnerId FROM Proposal__c WHERE Id=:recordId limit 1];
                }
                catch(Exception ex) {

                }
	            
	            if( proposalObj != null && proposalObj.Opportunity__c != null ){
		            if( UserInfo.getUserId() == proposalObj.Opportunity__r.OwnerId ){
		            	respWrap.userPresentInOpptyTeamMember = true;
		            }else{
		                list<OpportunityTeamMember> opptyTeamMembers = new list<OpportunityTeamMember>([SELECT Id FROM OpportunityTeamMember
		                                                                                                WHERE OpportunityId=:proposalObj.Opportunity__c
		                                                                                               AND UserId=:UserInfo.getUserId()]);
		                if( opptyTeamMembers.size() > 0 ){
		                    respWrap.userPresentInOpptyTeamMember = true;
			            }
		            }
	            }
	        }
        }
        
        respWrap.lstRecordTypes = lstRecordTypes;
        return respWrap;
    }
    
    @AuraEnabled
    public static map<String, object> getProposalRecord( Id recordId, Id selectedDCRT ){
        System.debug(recordId+'->'+selectedDCRT);
        Proposal__c proposalObj = [Select p.Name, p.Opportunity__r.Id, p.Opportunity__r.Agency_Account__c, p.Opportunity__c, 
                                   p.Opportunity__r.Agency_Account__r.Website, p.Opportunity__r.OwnerId,
                                   p.Opportunity__r.Agency_Account__r.Phone, p.Opportunity__r.Agency_Account__r.Description, 
                                   p.Opportunity__r.Agency_Account__r.BillingStreet, p.Opportunity__r.Agency_Account__r.BillingState, 
                                   p.Opportunity__r.Agency_Account__r.BillingPostalCode, p.Opportunity__r.Agency_Account__r.BillingCity,
                                   p.Id, p.Advertiser__c, p.Advertiser__r.Legal_Entity_Name__c,
                                   p.Opportunity__r.Owner.Sales_Office__c, p.Opportunity__r.Owner.Division__c,
                                   p.Opportunity__r.Owner.Region__c
                                   From Proposal__c p
                                   WHERE p.Id=:recordId limit 1];
    	
        User currentUser = [SELECT Id, Sales_Office__c, Division__c, Region__c FROM User WHERE Id=:UserInfo.getUserId()];
        
        map<String, object> pre_populatedFields = new map<String, object>();
        pre_populatedFields.put('Advertiser__c', proposalObj.Advertiser__c);
        pre_populatedFields.put('Agency__c', proposalObj.Opportunity__r.Agency_Account__c);
        pre_populatedFields.put('Opportunity__c', proposalObj.Opportunity__c);
        pre_populatedFields.put('Proposal__c', proposalObj.Id);
     //   pre_populatedFields.put('Status__c', '01 Draft Campaign');  SRSF-1146
        pre_populatedFields.put('Account_Executive__c', proposalObj.Opportunity__r.OwnerId);
        pre_populatedFields.put('Sales_Office__c', proposalObj.Opportunity__r.Owner.Sales_Office__c );
        pre_populatedFields.put('Division__c', proposalObj.Opportunity__r.Owner.Division__c );
        pre_populatedFields.put('Region__c', proposalObj.Opportunity__r.Owner.Region__c );
        
        if( selectedDCRT != null ){
           	RecordType rt = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Id=:selectedDCRT limit 1];
            // SRSF-1139
            String recTypeName = (rt.Name.startsWith('Inventory Request - ')) ?  rt.Name.substringAfter(' - ') : rt.Name;
            String campaignName = ( proposalObj.Name + ' - '+ recTypeName ).length() < 255 ? ( proposalObj.Name + ' - '+ recTypeName ) : ( proposalObj.Name + ' - '+ recTypeName ).subString( 0, 254 );            
      //      String campaignName = ( proposalObj.Name + ' - '+ rt.Name ).length() < 255 ? ( proposalObj.Name + ' - '+ rt.Name ) : ( proposalObj.Name + ' - '+ rt.Name ).subString( 0, 254 );
            // End SRSF-1139
            // SRSF-1146            
            if (rt.Name.startsWith('Inventory Request - ')) {
                pre_populatedFields.put('Status__c', 'Draft Plan');
            } else {
                pre_populatedFields.put('Status__c', '01 Draft Campaign');
            }
        	pre_populatedFields.put('Campaign_Name__c', campaignName );
            // end SRSF-1146
            // SRSF-1119 Don't set this check box
            /*
            if( rt.DeveloperName == 'Ads_Everywhere' || rt.DeveloperName == 'Content' ){
                pre_populatedFields.put( 'CoOp__c', true);
            }
            */
            // end of SRSF-1119
            //if( rt.DeveloperName == 'Ads_Everywhere' || rt.DeveloperName == 'Spectrum_Reach_Nets_Online' ){
                
            //}
            
/*            if( ( rt.DeveloperName == 'Content' || rt.DeveloperName == 'Directories' 
                 	|| rt.DeveloperName == 'Leads' || rt.DeveloperName == 'Search' ) 
               					&& proposalObj.Opportunity__c != null && proposalObj.Opportunity__r.Agency_Account__c != null ){
            
                pre_populatedFields.put('Business_Address__c', proposalObj.Opportunity__r.Agency_Account__r.BillingStreet); 
                pre_populatedFields.put('Business_City__c', proposalObj.Opportunity__r.Agency_Account__r.BillingCity);
                pre_populatedFields.put('Business_Phone__c', proposalObj.Opportunity__r.Agency_Account__r.Phone);
                pre_populatedFields.put('Business_State__c', proposalObj.Opportunity__r.Agency_Account__r.BillingState);
                pre_populatedFields.put('Business_Website__c', proposalObj.Opportunity__r.Agency_Account__r.Website);
                pre_populatedFields.put('Business_Zip__c', proposalObj.Opportunity__r.Agency_Account__r.BillingPostalCode);
            }
 */           
            /*if( rt.DeveloperName == 'Display' ){
                pre_populatedFields.put('Status__c', '02 New Campaign');
            }*/
            
            if( ( rt.DeveloperName == 'Search' || rt.DeveloperName == 'Directories' ) 
               			&& proposalObj.Advertiser__c != null ){
                //pre_populatedFields.put('Business_Name__c', proposalObj.Advertiser__r.Legal_Entity_Name__c );
            }
        }    
        
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