public class OpportunitySupportRequestController {
   
    @AuraEnabled
    public static Map<String, Object> createSupportRequest( Id opptyId, String selectedRequest ){
        Map<String, Object> data = new Map<String, Object>();
        Map<String, Object> defaultValues = new Map<String, Object>();
        System.debug('opptyId>>'+opptyId);
        Opportunity objOppty = [SELECT Id, Name, AccountId, Account.Agency__c, Account.ShippingStreet, 
                                Account.ShippingCity, Account.ShippingState, OwnerId, DMA__c, Tier_Designation__c,SAM_Designation__c,
                                Owner.Sales_Office__c, Owner.Division__c, Owner.Region__c, Rep_Firm__c, Agency_Account__c,
                                Flight_Start_Date__c,Flight_End_Date__c, Account.Last_Client_Schedule_Date__c, StageName, Projected_Gross_Amount__c
                                FROM Opportunity 
                                WHERE Id=:opptyId Limit 1];   
        //Map<String, Object> propMonthlyZone = new Map<String, Object>(); // Commented: SRSF-3996
        Map<String, Decimal> propMonthlyZone = new Map<String, Decimal>(); // Added : SRSF-3996
        
        List<Proposal_Zone_Monthly_Value__c> prop = [SELECT Id, Schedule_Type__c, Gross_Amount__c FROM Proposal_Zone_Monthly_Value__c WHERE Opportunity__r.Id=:opptyId];
        if(!prop.isEmpty()){
            for (Proposal_Zone_Monthly_Value__c propListMonthly : prop) {
                // START: SRSF-3996
                if(!propMonthlyZone.containsKey(propListMonthly.Schedule_Type__c)){
                    propMonthlyZone.put(propListMonthly.Schedule_Type__c, propListMonthly.Gross_Amount__c);
                } else {
                  Decimal totalAmount = propMonthlyZone.get(propListMonthly.Schedule_Type__c)+propListMonthly.Gross_Amount__c;
                  propMonthlyZone.put(propListMonthly.Schedule_Type__c, totalAmount);
                }                
                // END: SRSF-3996
            	//propMonthlyZone.put(propListMonthly.Schedule_Type__c, propListMonthly.Gross_Amount__c); // Commented: SRSF-3996
			}            
            for (String key: propMonthlyZone.keySet()) {
                if (key == 'Linear/News/Sports') {
                    defaultValues.put('Linear_Budget_Over_Campaign__c',propMonthlyZone.get(key));
                    System.debug('Linear_Budget_Over_Campaign__c' +defaultValues);
                }
                else if(key == 'Digital') {
                    defaultValues.put('Advanced_Budget_Over_Campaign__c',propMonthlyZone.get(key));
                    System.debug('Advanced_Budget_Over_Campaign__c' +defaultValues);
                } 
            }
        }
        
        data.put('entityApiName', 'Support_Request__c');     

        RecordType rt;
        System.debug('selectedRequest>>>>>'+selectedRequest);    
        if( selectedRequest == 'production' ){
            rt = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Support_Request__c' AND DeveloperName='Production' AND IsActive=true Limit 1];
        }else if (selectedRequest == 'researchRequest') {
            rt = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Support_Request__c' AND DeveloperName='Research_Request' AND IsActive=true Limit 1];
        } else if (selectedRequest == 'digitalInventoryRequest') {
            rt = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Support_Request__c' and DeveloperName = 'Digital_Inventory_Request' AND IsActive=true Limit 1];
        } else if (selectedRequest == 'planningRequest') {
            rt = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Support_Request__c' and DeveloperName = 'Planning_Request' AND IsActive=true Limit 1];
        } else if (selectedRequest == 'audienceRequest') { // SRSF-1897
            rt = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Support_Request__c' and DeveloperName = 'Audience_Request' AND IsActive=true Limit 1];
        } 
        else {
            data = null;
            return data;
        }

        Boolean isOnOpptyTeam = isOpportunityTeamMember(objOppty, rt.DeveloperName);
        
        data.put('recordTypeId', rt.Id);
        
        //TODO - determine if AE should be defaulted for DigitalInventoryRequests
        defaultValues.put('Account_Executive__c', objOppty.OwnerId );
        defaultValues.put('OwnerId', objOppty.OwnerId );
        defaultValues.put('Sales_Office__c', objOppty.Owner.Sales_Office__c );
        defaultValues.put('Division__c', objOppty.Owner.Division__c );
        defaultValues.put('Region__c', objOppty.Owner.Region__c );
        
        defaultValues.put('Opportunity__c', objOppty.Id );
        if( objOppty.AccountId != null ){
            defaultValues.put('Advertiser__c', objOppty.AccountId ); 
        }
        if( objOppty.Rep_Firm__c != null ){
            defaultValues.put('Rep_Firm__c', objOppty.Rep_Firm__c );
        }
        
        if( objOppty.Agency_Account__c!= null ){
            defaultValues.put('Agency__c', objOppty.Agency_Account__c );
        }
        if (selectedRequest == 'planningRequest'){            

            if(objOppty.StageName == 'Closed Lost'){
                String errorMessage = 'You cannot create a Planning Request if the Opportunity is Closed as Lost';	
                data.put('errorMessage', errorMessage);
                }
            else{
                Datetime yourDate = Datetime.now();
                String dateOutput = yourDate.format('MM/dd/yyyy');
                defaultValues.put('Name', objOppty.Name+' - '+dateOutput);
            }            
        }
      //  if (selectedRequest == 'planningRequest' || selectedRequest == 'researchRequest'){ // Commented as part of Release 19 : SRSF-3984/SRSF-4004
            // START : SRSF-3785 / SRSF-3787
            System.debug('DMA__c>>>>>'+objOppty.DMA__c);
            if( objOppty.DMA__c != null ){
                defaultValues.put('DMA__c', objOppty.DMA__c );
            }
            System.debug('Tier_Designation__c>>>>>'+objOppty.Tier_Designation__c);
            if( objOppty.Tier_Designation__c != null ){
                defaultValues.put('Tier_Designation__c', objOppty.Tier_Designation__c );
            }

            if(System.label.SAMDesignationShutDown == 'FALSE' && objOppty.SAM_Designation__c != null){
                defaultValues.put('SAM_Designation__c', objOppty.SAM_Designation__c );
            }
            // END : SRSF-3785 / SRSF-3787
       // } // Commented as part of Release 19 : SRSF-3984/SRSF-4004
        //SRSF-1897: Added if condition to set default request type for audience request
        if (selectedRequest == 'audienceRequest') {
            defaultValues.put('Type_of_Request__c', 'Addressable Audience Approval');
        }
        /*if(selectedRequest == 'planningRequest'){
            Datetime yourDate = Datetime.now();
            String dateOutput = yourDate.format('MM/dd/yyyy');
            defaultValues.put('Name', objOppty.Name+' - '+dateOutput);
        }*/
        defaultValues.put('Flight_Start_Date__c', objOppty.Flight_Start_Date__c );
        defaultValues.put('Flight_End_Date__c', objOppty.Flight_End_Date__c );
        defaultValues.put('Last_Client_Schedule_Date__c', objOppty.Account.Last_Client_Schedule_Date__c);
        defaultValues.put('Budget_Over_Campaign__c', objOppty.Projected_Gross_Amount__c);
        if( defaultValues.size() > 0 ){
            data.put( 'defaultFieldValues', defaultValues );
        }
        
        String oppownerid = objOppty.OwnerId;
        User usrProfileName = [SELECT u.Profile.Name, u.UserRole.Name, u.Team_Role__c FROM User u WHERE u.Id = :Userinfo.getUserId()];
        if(usrProfileName.Profile.Name == 'Master - Spectrum Preferred' && (rt.developerName == 'Research_Request' || rt.developerName == 'Planning_Request' || rt.developerName == 'Production')){
        	data.put( 'isPreferred', true );
            return data;
        }
        if(objOppty.AccountId !=null && selectedRequest == 'researchRequest' && isOnOpptyTeam==true){
            boolean isSAMExists = isOppOwnerInAccountSAM(oppownerid,objOppty.AccountId);
            if(isSAMExists == false)
            	data.put( 'isOnOpptyTeam', isSAMExists );
            else{
                return data;
            }
        }
        
        if(!isOnOpptyTeam){
            data = null;
            return data;
        }
        System.debug('data>>>>>'+data);
        return data;        
    }

    @AuraEnabled
    public static String editSupportRequest( Id recordId ){
        System.debug('-----> recordId: '+recordId);
        String cacheKey = 'local.SRPartition.' + recordId;
        Boolean doQuery = true;
        Boolean srIsCached = false;
        Long rightNow = Datetime.now().getTime();
        if (Cache.Session.contains(cacheKey)) {
            System.debug('=========>> num seconds = ' + ((rightNow - (Long) Cache.Session.get(cacheKey)) / 1000));
            doQuery = (((rightNow - (Long) Cache.Session.get(cacheKey)) / 1000)  < 5) ? false : true;
            srIsCached = true;
          //  Cache.Session.remove(cacheKey);
        }
        if (doQuery) {

            Support_Request__c srObj = [SELECT Id, Opportunity__c, RecordTypeId, Account_Executive__c,
            Sales_Office__c, Division__c, Region__c FROM Support_Request__c WHERE Id=:recordId Limit 1];
            // SRSF-814
            if (srObj.Opportunity__c == null) {
                return 'No Opportunity';
            }
            // end SRSF-814
            RecordType rt = [SELECT DeveloperName FROM RecordType WHERE Id = :srObj.RecordTypeId];
            /*
            Opportunity objOppty = [SELECT Id, AccountId, Account.Agency__c, Account.ShippingStreet, 
                                    Account.ShippingCity, Account.ShippingState, OwnerId,
                                    Owner.Sales_Office__c, Owner.Division__c, Owner.Region__c
                                    FROM Opportunity 
                                    WHERE Id=:srObj.Opportunity__c limit 1];
            */
            Opportunity objOppty = [SELECT Id, OwnerId
                                    FROM Opportunity 
                                    WHERE Id=:srObj.Opportunity__c Limit 1];
            if(isOpportunityTeamMember(objOppty, rt.DeveloperName)){
                return 'true';                    
            }

        } else if (srIsCached) {
            return 'Record exists in cache';
        }
        return 'false';  
    }

    private static Boolean isOpportunityTeamMember(Opportunity oppty, String developerName) {
       System.debug('------------->> in isOpportunityTeamMember, developerName = ' + developerName + ' oppty = ' + oppty);
       User usrProfileName = [SELECT u.Profile.Name, u.UserRole.Name, u.Team_Role__c FROM User u WHERE u.Id = :Userinfo.getUserId()];
       String profileName = System.Label.PlanningRequestEditableProfiles;
        List<String> profileNameList=new List<String>();
        if(profileName != null){            
       		profileNameList =  profileName.split(',');
        }
       
        if(usrProfileName.Profile.Name == 'Master - Spectrum Preferred' && (developerName == 'Research_Request' || developerName == 'Planning_Request' || developerName == 'Production')){
            return true;
        } 
        if (developerName == 'Digital_Inventory_Request') {
           if(UserInfo.getUserId() == oppty.OwnerId || usrProfileName.Profile.Name == 'System Administrator' || usrProfileName.Profile.Name == 'Master - Digital Sales' || usrProfileName.Profile.Name == 'Master - Digital Planner' || usrProfileName.Profile.Name == 'Master - Spectrum Preferred') {
                return true;
            }

        } else if (developerName == 'Production' || developerName == 'Research_Request') {
           if(UserInfo.getUserId() == oppty.OwnerId || usrProfileName.Profile.Name == 'System Administrator' || usrProfileName.Profile.Name == 'Master - Production' || usrProfileName.Profile.Name == 'Master - Research' || usrProfileName.Profile.Name == 'Master - Spectrum Preferred') {
                return true;
           }
        // SRSF-1330
        }  else if (developerName == 'Planning_Request' || developerName == 'Planning_Locked_Request') {
           if(UserInfo.getUserId() == oppty.OwnerId || profileNameList.contains(usrProfileName.Profile.Name) ) {
               System.debug('profileNameList' + profileNameList.contains(usrProfileName.Profile.Name));
               System.debug('------------->> Debug return true in isOpportunityTeamMember, developerName = ' + developerName);             
                return true;
           }
        } // SRSF-1330
        else if (developerName == 'Audience_Request' && usrProfileName.Profile.Name == 'Master - Research'){  // SRSF-1897
            return true;
        }

       // Added for SRSF-1587
       for( OpportunityTeamMember oppTeamObj : [SELECT o.UserId, o.Id FROM OpportunityTeamMember o 
                                             WHERE OpportunityId =: oppty.Id]){
            if( UserInfo.getUserId() == oppTeamObj.UserId ) {
              //  Cache.Session.put(cacheKey, rightNow, 300, Cache.Visibility.All, false); moved to SR trigger
                return true;
            }                                          
        }
        if( UserInfo.getUserId() == oppty.OwnerId ) {	
            return true;	
        } 
        return false;
    }
    
    //checks for Opportunity owner is in related Account of SAMMapping list
    private static Boolean isOppOwnerInAccountSAM(Id userid, Id advertiserId) {
        List<Account_SAM_Mapping__c> lstASM = [SELECT Id FROM Account_SAM_Mapping__c WHERE Account__c =:advertiserId];
        return (!lstASM.isEmpty());   
    }
}