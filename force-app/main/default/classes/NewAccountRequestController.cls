public class NewAccountRequestController {

    @AuraEnabled
    public static ResponseWrapper getARRecordTypes( Id recordId ){
        ResponseWrapper responseObj = new ResponseWrapper();
        list<RecordType> lstRecordTypes = new list<RecordType>();
        Schema.DescribeSObjectResult resultObj = Account_Request__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> lstRTInfos = resultObj.getRecordTypeInfos();
        for( Schema.RecordTypeInfo rtInfo : lstRTInfos ){
            if( rtInfo.isAvailable() && rtInfo.getName() != 'Master' ){
                lstRecordTypes.add( new RecordType(Id=rtInfo.getRecordTypeId(), Name=rtInfo.getName()));
                System.debug('---> Adding Id=: '+rtInfo.getRecordTypeId() + ' Name= '+ rtInfo.getName());
            }
        }
        RecordType teamMemberRT; 
        map<String, RecordType> mapRTByDevName = new map<String, RecordType>();
        for( RecordType rtObj : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType='Account_Request__c' 
                                 AND ( DeveloperName='Account_Switch_Request' OR DeveloperName='Team_Member_Request'  OR DeveloperName='Search_ID_Request' OR 
                                      DeveloperName='Payment_Research' OR DeveloperName='Revenue_Adjustment' OR 
                                      DeveloperName='Account_Id_Credit_Request' OR DeveloperName='Payment_Plan' OR DeveloperName='Remove_Account_Team_Member' ) ]){
            mapRTByDevName.put( rtObj.DeveloperName, rtObj );
        }
        
        if( mapRTByDevName.get('Account_Switch_Request') != null  ){
            responseObj.switchRTId = mapRTByDevName.get('Account_Switch_Request').Id;
        }  
        if( mapRTByDevName.get('Team_Member_Request') != null ){
            responseObj.teamMemberRTId = mapRTByDevName.get('Team_Member_Request').Id;
            teamMemberRT = mapRTByDevName.get('Team_Member_Request');
        }    
      /*  if( mapRTByDevName.get('Search_ID_Request') != null ){
            responseObj.teamMemberRTId = mapRTByDevName.get('Search_ID_Request').Id;
            teamMemberRT = mapRTByDevName.get('Search_ID_Request');
        } */ 
        
        
        responseObj.lstRecordTypes = lstRecordTypes;
        
        User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];
        responseObj.isUserLSM = currentUser.Profile.Name == System.Label.LSM_Profile_Name ? true : false;
        // Check if current User is AE under Account        
        list<AccountTeamMember> teamMember = new list<AccountTeamMember>([Select Id, UserId, TeamMemberRole 
                                              From AccountTeamMember a 
                                              WHERE AccountId=:recordId 
                                              AND UserId=:UserInfo.getUserId() ]);
                                              if( teamMember.isEmpty() ){
            System.debug('---> Inside teamMember.isEmpty()'); 
            // SRSF-1329 Added Master - Field Marketing
            set<String> setProfiles = new set<String>();
            if(Master_Field_Marketing_Profiles__c.getAll() !=null && !Master_Field_Marketing_Profiles__c.getAll().isEmpty() ){
                for(Master_Field_Marketing_Profiles__c obj : Master_Field_Marketing_Profiles__c.getAll().values())
                    setProfiles.add(obj.Name);
            }
            //set<String> setProfiles = new set<String>{'Master - FBO', 'Master - Field Marketing'};
            list<RecordType> availableRTs = new list<RecordType>();
            if(teamMember!=null && teamMember.size()>0){
                availableRTs.add( mapRTByDevName.get('Remove_Account_Team_Member') );
            }
            if( setProfiles.contains( currentUser.Profile.Name ) && mapRTByDevName.get('Payment_Research') != null ){
                availableRTs.add( mapRTByDevName.get('Payment_Research') );
            }
            if( setProfiles.contains( currentUser.Profile.Name ) && mapRTByDevName.get('Payment_Plan') != null ){
                availableRTs.add( mapRTByDevName.get('Payment_Plan') );
            }
            System.debug('---> Adding to availableRTs currentUser.Profile.Name: '+currentUser.Profile.Name);
            if(( currentUser.Profile.Name == System.Label.Revenue_Adjustment_Profile) && mapRTByDevName.get('Revenue_Adjustment') != null ){
                System.debug('---> Adding to availableRTs: Revenue_Adjustment');
                availableRTs.add( mapRTByDevName.get('Revenue_Adjustment') );
            }
            if((currentUser.Profile.Name == 'Master - FBO' || currentUser.Profile.Name == 'Master - Spectrum Preferred') && mapRTByDevName.get('Account_Id_Credit_Request') != null ){
                System.debug('---> Adding to availableRTs: Revenue_Adjustment');
                availableRTs.add( mapRTByDevName.get('Account_Id_Credit_Request') );
            }
             if((currentUser.Profile.Name == 'Master - Digital Operations' || currentUser.Profile.Name == 'Master - Optimization Manager') && mapRTByDevName.get('Search_ID_Request') != null && mapRTByDevName.get('Team_Member_Request') != null ){
                System.debug('---> Adding to availableRTs: Revenue_Adjustment');
               availableRTs.add( mapRTByDevName.get('Search_ID_Request') );
              // availableRTs.add( mapRTByDevName.get('Team_Member_Request') );
            }
            if( teamMemberRT != null )
                availableRTs.add( teamMemberRT );
            //responseObj.isUserTeamMember = teamMember.isEmpty() ? false : true;
            if( currentUser.Profile.Name == 'Master - FBO' || currentUser.Profile.Name == 'Master - Spectrum Preferred')
                responseObj.lstRecordTypes = lstRecordTypes;
            else
                responseObj.lstRecordTypes = availableRTs;
        }
        if( !teamMember.isEmpty()){
            responseObj.isCurrentUserAE = teamMember.get(0).TeamMemberRole == 'Account Executive' ? true : false ;
        }else{
            responseObj.isCurrentUserAE = false;
        }    
        //responseObj.lstUsers = lstUsers;
        System.debug('---> Respnse: '+responseObj );
        System.debug('---> Respnse.lstRecordTypes: '+responseObj.lstRecordTypes.size() );
        
        
        Id currentUserProfileId = UserInfo.getProfileId();

        //Retrieve profile name
        String profileName = [SELECT Name FROM Profile WHERE Id =: currentUserProfileId].Name;
        
        //Print out profile name
        System.debug('Profile Name: '+ profileName);
        responseObj.profileName = profileName;
        //System.debug('---> Respnse.lstUsers: '+responseObj.lstUsers.size() );
        return responseObj;
    }
    
    @AuraEnabled
    public static list<User> getAETeamMembers( Id accountId ){
        list<User> lstUsers = new list<User>();
        for( AccountTeamMember teamMember :  [Select a.User.Name, a.UserId, a.TeamMemberRole, a.User.Sales_Office__c 
                                              From AccountTeamMember a 
                                              WHERE AccountId=:accountId 
                                              AND (TeamMemberRole='Account Executive' OR TeamMemberRole='Sales Manager') Order By User.Name asc]){
            lstUsers.add( teamMember.User );
        }
        return lstUsers;
    }
    
    @AuraEnabled
    public static AccountData getAccountData( Id recordId, Id selectedRT, String selectedAE, Boolean isCurrentUserAE ){
        AccountData respObj = new AccountData();
        
        Account accObj = [SELECT Id, Invoice_Type__c, Bill_To__c, Address_Change_in_Progress__c FROM Account WHERE Id=:recordId limit 1];
        
        RecordType rtObj = [SELECT Id, DeveloperName FROM RecordType WHERE Id=:selectedRT];
        system.debug('Record Type Name'+rtObj.DeveloperName);
        if( rtObj.DeveloperName != 'Team_Member_Request' ){
            respObj.allowAddressRequest = true;
            if( rtObj.DeveloperName == 'Address_Contact_Update_Request' ){
                respObj.isAddressChangeRequest = true;
                if( accObj.Address_Change_in_Progress__c ){
                    respObj.allowAddressRequest = false;
                    return respObj;
                }
            }else{
                respObj.isAddressChangeRequest = false;
            }
            
            map<String, object> pre_populatedFields = new map<String, object>();
            
            pre_populatedFields.put('Advertiser_Agency_Rep_Firm__c', recordId );
            pre_populatedFields.put('Status__c', 'New' );
            
            if( rtObj.DeveloperName != 'Account_Switch_Request'  && 
                ( selectedAE != '' || isCurrentUserAE) ){
                User aeUser;
                if( isCurrentUserAE ){
                    aeUser = [SELECT Id, Sales_Office__c, Region__c, Division__c  FROM User WHERE Id=:UserInfo.getUserId()];
                }else{
                    aeUser = [SELECT Id, Sales_Office__c, Region__c, Division__c  FROM User WHERE Id=:selectedAE];
                }
            if(rtObj.DeveloperName != 'Search_ID_Request') {
                pre_populatedFields.put('Account_Executive__c', aeUser.Id );
               }                      pre_populatedFields.put('Sales_Office__c', aeUser.Sales_Office__c );
                pre_populatedFields.put('Region__c', aeUser.Region__c );
                pre_populatedFields.put('Division__c', aeUser.Division__c );
            }
            if( rtObj.DeveloperName == 'Account_Id_Credit_Request'){
                pre_populatedFields.put('Invoice_Type__c', accObj.Invoice_Type__c );
                pre_populatedFields.put('Contract_Type__c', accObj.Bill_To__c );
            }
            respObj.pre_populatedFields = pre_populatedFields;
            /*list<String> teamMembers = new list<String>();
            for( AccountTeamMember teamMember :  [Select a.User.Name, a.UserId, a.TeamMemberRole 
                                                  From AccountTeamMember a 
                                                  WHERE AccountId=:recordId 
                                                  AND TeamMemberRole='Account Executive' Order By User.Name asc]){
                                                      teamMembers.add( teamMember.User.Name );
                                                  }
            if( teamMembers.size() > 0 ){
                pre_populatedFields.put('Account_Executives__c', String.join( teamMembers, ';') );
            }*/
        }else{
            respObj.selRTName = rtObj.DeveloperName;
            Account_Request__c objAR = new Account_Request__c();
            objAR.Status__c = 'New';
            objAR.Account_Executive__c = UserInfo.getUserId();
            respObj.selAEId = UserInfo.getUserId();
            objAR.Advertiser_Agency_Rep_Firm__c = recordId;
            respObj.objAR = objAR;
        }        
        return respObj;
    }
    
    @AuraEnabled
    public static AccReqTeamMemberData checkForAEInAccTeam( string aeId, string accId ){
        boolean isAEOnAccTeam = false;
        User objUser = [select id,Sales_Office__c from User where id=:aeId];
        string strSO;
        if(objUser!=null){
            strSO = objUser.Sales_Office__c;
            list<AccountTeamMember> lstTM = [select Id, AccountId from AccountTeamMember 
                                             WHERE AccountId =: accId and TeamMemberRole ='Account Executive'
                                             and User.Sales_Office__c=:strSO];
            isAEOnAccTeam = (lstTM!=null && !lstTM.isEmpty());
        }
        AccReqTeamMemberData objRes = new AccReqTeamMemberData();
        List<Object> parameters = new List<Object> {strSO};
        //SYSTEM.Debug(String.format(Label.ATM_AEPresentAccSalesOffice,parameters));
        objRes.errorMsg = String.format(Label.ATM_AEPresentAccSalesOffice,parameters) ;
        objRes.isAEExists = isAEOnAccTeam;
        return objRes;
    }
    
    @AuraEnabled
    public static string saveAccountRequest(string accId, string selectedRT, string status, string aeId, datetime dtComplete, string comments){
        try{
            Account_Request__c objReq = new Account_Request__c();
            objReq.Advertiser_Agency_Rep_Firm__c = accId;
            objReq.RecordtypeId = selectedRT;
            //objReq.Status__c = status;
            objReq.Account_Executive__c = aeId;
            //objReq.Date_Completed__c = dtComplete;
            objReq.Comments__c = comments;
            insert objReq;
            return objReq.Id;
        }catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException('Error: '
                + e.getMessage());    
        }
    }
    
    public class ResponseWrapper{
        @AuraEnabled
        public Boolean isUserTeamMember{get;set;}
        @AuraEnabled
        public Boolean isUserLSM{get;set;}
        @AuraEnabled
        public Boolean isCurrentUserAE{get;set;}
        @AuraEnabled
        public Id teamMemberRTId{get;set;}
        @AuraEnabled
        public Id switchRTId{get;set;} 
        @AuraEnabled
        public list<User> lstUsers{get;set;}
        @AuraEnabled
        public list<RecordType> lstRecordTypes{get;set;}
        
        @AuraEnabled
        public String profileName{get;set;}
        
        public ResponseWrapper(){}
    }
    
    public class AccountData{
        @AuraEnabled public Boolean allowAddressRequest{get;set;}
        @AuraEnabled public Boolean isAddressChangeRequest{get;set;}
        @AuraEnabled public map<String, object> pre_populatedFields{get;set;}
        @AuraEnabled public string selRTName{get;set;}//selected RecordtypeName
        @AuraEnabled public string selAEId{get;set;}//selected AccountExecutive
        @AuraEnabled public Account_Request__c objAR{get;set;}//if the selected Recordtype is 'Team Member Request'
    }
    
    public class AccReqTeamMemberData{
        @AuraEnabled public Boolean isAEExists{get;set;}
        @AuraEnabled public String errorMsg{get;set;}
    }
}