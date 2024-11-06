@RestResource(urlMapping='/SpectrumReachSCXUpload/*')
global with sharing class ThirdPartySCXUpload{
    
    @HttpGet
    global static String doGet() {
        return 'SpectrumReachSCXUpload API is Alive!';
    }

    @HttpPost
    global static SCXUploadResponseWrapper doPost(String userID, String xml, String oppID, String source,String rateCardName) {
        System.debug(' ### userID ::: ' +userID);
        System.debug(' ### oppID ::: ' +oppID);
        System.debug(' ### xml ::: ' +xml);
        System.debug(' ### rateCard ::: ' +rateCardName);
        Map<String,Object> mapOfThirdPartyLog = new Map<String, Object>{'User__c' =>userID,'API_Name__c' => 'SpectrumReachSCXUpload','Source__c' => source };

        Third_Party_Logger__c thirdPartyLogger = Log4SF.createThirdPartyLogger(mapOfThirdPartyLog,false , new Third_Party_Logger__c());
        //BoomiWebServiceHelper boomi = new BoomiWebServiceHelper();
        //ApexPages.currentPage().getParameters().put('OppId', oppID);
        User user = new User();
        user blankUser = new User();
        SCXUploadResponseWrapper response = new SCXUploadResponseWrapper();

        if(String.isBlank(oppID)) {
            System.debug(' $$$ Opportunity Id is null ::: ');
            return new SCXUploadResponseWrapper(false, Label.Opportunity_Id_Error, null, null);
        }
        else {
            // return checkCachePresence(oppID);
            Opportunity opp = new Opportunity();
            try {
                opp = [SELECT Id, Name, Owner.Name, Owner.Profile.Name, OwnerId ,AccountID FROM Opportunity WHERE id=: oppID];
                if(opp!=NULL && opp.AccountId==NULL) return new SCXUploadResponseWrapper(false, Label.Account_Missing_On_Opp, null, null);
            }
            catch(Exception ex) {
                System.debug(' $$$ Opportunity is not available ::: ');
                return new SCXUploadResponseWrapper(false, Label.No_Opportunity_Error, null, null);
            }

            /*Get the Opp AE User Connections*/
            UserConnection__c oppAE = new UserConnection__c();
            try {
                oppAE = [SELECT AE_Id__c, TIM_System__c, Username__c, User__r.name FROM UserConnection__c WHERE User__c =: opp.OwnerId AND AE_Id__c != null AND Is_Primary__c = true LIMIT 1];
            }
            catch(Exception ex) {
                System.debug(' $$$ error in primary user connection ::: ' +ex.getMessage() + ' $$$$ Line number :::: ' +ex.getLineNumber());
                return new SCXUploadResponseWrapper(false, Label.No_Primary_UserConnection, null, null);
            }

            /*Get the Logged In User Connections*/        
            List<UserConnection__c> loggedInUser = [SELECT AE_Id__c, TIM_System__c, Username__c, User__r.name FROM UserConnection__c WHERE User__c =: userInfo.getUserId() AND Tim_System__c =: oppAE.Tim_System__c];
            
            String timSystem = '';

            if(loggedInUser.size() > 0) {
                timSystem = loggedInUser[0].TIM_System__c;
            }
            else {
                thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure', 'Error_Message__c' =>'User Connection is not available'} ,TRUE ,thirdPartyLogger);
                return new SCXUploadResponseWrapper(false, Label.No_User_Connection_Error, null, null);
            }

            try{
                System.debug(CacheManager.checkCacheSize(timSystem));
                if(CacheManager.checkCacheSize(timSystem) <=0){
                    //System.debug(CacheManager.checkCacheSize(timSystem)); 
                    if(Label.CacheAutoRefresh=='true'){
                        CacheManager.refreshTIMCache(timSystem);
                    }
                    Log4SF.logMessage('SpectrumReachSCXUpload', 'doPost', 'Refreshed All Cache' , UserInfo.getUserId(), opp.Id);
                    // return  new PageReference('/apex/Proposal_Cache_Error?timSystem='+timSystem+'&retURL=/apex/ProposalTimCreate?Id='+opp.Id + '&oppId=' + opp.Id);
                    //return new SCXUploadResponseWrapper(true, Label.Cache_Error_Message, null, null);
                    // Cache is refreshing, please send the request again.
                    return new SCXUploadResponseWrapper(false, Label.Cache_Refresh_Error, null, null);
                }
                // else
                // {
                //  return null;
                // }
            }
            catch(Exception ex){
                System.debug('refreshCache Callout error: '+ ex.getMessage());
                return new SCXUploadResponseWrapper(false, 'refreshCache Callout error: ' + ex.getMessage(), null, null);
            }
        }

        try{
            try{
                user = [SELECT Id, Name FROM User WHERE Id =:userID AND isActive = true LIMIT 1];
                System.debug('@@@ user ::: ' +user);
            }
            catch(Exception ex){
                //response.hasError =    'true';
                //response.message = 'This User does not exist or is inactive.'+userID;
                System.debug(' ### exception :::: ' +ex.getMessage() + ' ### Line number ::: ' +ex.getLineNumber());
                String errMesg = String.format(System.Label.UserID_Not_esist, new List<String> {userID});
                thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure', 'Error_Message__c' =>errMesg} ,TRUE ,thirdPartyLogger);
                response = new SCXUploadResponseWrapper(false, errMesg, null, null);
                //return new SCXUploadResponseWrapper(true, errMesg, null, null);
            }            
            if(user == blankUser){
                // response.hasError =       'true';
                // response.message = 'This User does not exist or is inactive.'+userID;
                // return 'This User does not exist or is inactive.'+userID;
                String errMesg = String.format(System.Label.UserID_Not_esist, new List<String> {userID});
                thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure', 'Error_Message__c' =>errMesg} ,TRUE ,thirdPartyLogger);
                response = new SCXUploadResponseWrapper(false, errMesg, null, null);
                //return new SCXUploadResponseWrapper(true, errMesg, null, null);
            }
            else if(String.isNotBlank(xml))
            {
               //SRSF-1762  Code Starts here 
                ProposalSCXUploadController propCont = new ProposalSCXUploadController(oppID); 
                propCont.isConfirm = true;
                //SRSF-1762  Code Ends here 
                propCont.recordID = oppID;
                propCont.uploadedFile  = Blob.valueOf(xml);
                propCont.isThirdParty = true;
                propCont.xmlParser();
                String replacedXMLstring = propCont.mergeAccountDetailsToSCX(xml);
                propCont.proposalSource = source;
                propCont.selectedRateCard = rateCardName;
                propCont.timServiceCall();
                
                thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'SUCCESS','Error_Message__c' =>propCont.pageMsg} ,TRUE ,thirdPartyLogger);

                if((propCont.pageMsg).containsIgnoreCase('Proposal was created successfully.')) {
                    response = new SCXUploadResponseWrapper(true, propCont.pageMsg, String.valueOf(propCont.estimateID), String.valueOf(propCont.proposal.ID));
                }
                else {
                    response = new SCXUploadResponseWrapper(false, propCont.pageMsg, String.valueOf(propCont.estimateID), String.valueOf(propCont.proposal.ID));    
                }
                /*
                response.EstimateID =   String.valueOf(propCont.estimateID);
                response.ProposalID =   String.valueOf(propCont.proposal.ID);
                response.hasError =     propCont.estimateId > 0 ?'false' : 'true';
                response.message = propCont.pageMsg;
                */
            }
            else
            {
                //response.message = 'The SCX provided is invalid.';
                thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure','Error_Message__c' =>'The SCX provided is invalid.'} ,TRUE ,thirdPartyLogger);
                //return populateResultWrapper(true, propCont.pageMsg, propCont.estimateID, propCont.proposal.ID);
                response = new SCXUploadResponseWrapper(false, 'The SCX provided is invalid.', null, null);
            }
                            
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
        }
        catch(Exception ex){
            Log4SF.logMessage('SpectrumReachSCXUpload', 'Post', 'Exception in SCX Upload',ex,userID,'NA');
            //return propCont.pageMsg+userID;
            system.debug('Exception ' + ex.getMessage() + ' line number :::: ' +ex.getLineNumber());
        }
        
        //return JSON.serialize(tSCX);
        return response;
    }
    
    global with sharing class SCXUploadResponseWrapper {
    
        global String EstimateID;
        global String ProposalID;
        //global Boolean hasError;
        global Boolean isSuccess;
        global String message;

        global SCXUploadResponseWrapper() {}

        global SCXUploadResponseWrapper(Boolean isSuccess, String message, String estimateId, String proposalId) {
            this.EstimateID = estimateId;
            this.ProposalID = proposalId;
            //this.hasError = hasError;
            this.isSuccess = isSuccess;
            this.message = message;
        }
    }

    /*gloabl SCXUploadResponseWrapper populateResultWrapper(Boolean hasError, String message, String estimateId, String proposalId) {

        SCXUploadResponseWrapper response = new SCXUploadResponseWrapper(hasError, message, estimateId, proposalId);
        
        return response;
    }*/

    /*global static SCXUploadResponseWrapper checkCachePresence(String opportunityId) {

        
        return null;
    }*/

}