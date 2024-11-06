/*
###########################################################################
# File..................: BoomiWebServiceHelper.cls
# Version...............: 1
# Created by............: Sanchit Singhal   
# Created Date..........: 10-April-2017
# Last Modified by......: Bhuvanasankar
# Last Modified Date....: 10-Sep-2018 
# Description...........: This class contains helper methods for Boomi web service calls
# TAO Ref#..............: NA
# Test Class............: BoomiWebServiceHelperTest
# Change Log............:               
# 1. Puneet Khosla - Changes for SRSF-1096
# 2. Puneet Khosla - Changes for SRSF-1098
# 3. Bhuvanasankar - Changes for SRSF-1300
# 4. Bhuvanasankar - Changes for SRSF-1268
############################################################################*/
public with sharing class BoomiWebServiceHelper {
    
    /*custom settings map variable*/
    Map<String,TIMIntegration__c> custSettMap = new Map<String,TIMIntegration__c>();
    /*user id for TIM authentication from custom settings map variable*/ 
    private Integer userId;
    /*user password for TIM authentication from  custom settings map variable*/
    private String passwd;
    /*app id for TIM authentication from custom settings map variable*/
    private Integer appId;
    /*user name for TIM authentication from custom settings map variable*/
    private String userName;
    /*TIMServer for TIM authentication from custom settings map variable*/
    private String timServer;
    /*BoomiServer for Boomi API from custom settings map variable*/
    private String boomiServer;
    /*Logged In User for TIM details*/
    private UserConnection__c loggedInUser;
    /*Code added by Aditi : 5th April 2018 : To control inactive/activate proposal salesforce update*/
    public static Boolean inactiveActiveVar = false;
    private final string SCX_TIMEOUT_KEY = 'SCX_Webservice_TimeOut';

    public Boolean isFrmSCXUpload = false;

    public static Boolean isAccConnectionCreated = true;
    // SRSF-1762 Code Starts here
    public static Boolean createAccInTIM = false;
    public Boolean confirmCreateAcc = false; 
    // SRSF-1762 Code Ends here


    /**
     * Constructor. 
     * 
     * @param  (none) (NA)
     * @return (none) (NA)
    */
    public BoomiWebServiceHelper(){
        System.debug('@@User '+UserInfo.getUserId());
        try{
            loggedInUser = [Select AE_Id__c, TIM_System__c, Username__c from UserConnection__c where User__c=: UserInfo.getUserId() and Is_Primary__c = true limit 1];  
            System.debug('@@loggedInUser '+loggedInUser);
            custSettMap = TIMIntegration__c.getAll();
            System.debug('@@custSettMap '+custSettMap);
            userName = custSettMap.get(loggedInUser.TIM_System__c).UserName__c;
            passwd = custSettMap.get(loggedInUser.TIM_System__c).Password__c;
            userId = Integer.valueOf(custSettMap.get(loggedInUser.TIM_System__c).userId__c);
            
            if(passwd ==  null) passwd = '';
            appId = Integer.valueOf(custSettMap.get(loggedInUser.TIM_System__c).AppId__c);
            timServer = custSettMap.get(loggedInUser.TIM_System__c).Endpoint__c;
            boomiServer = custSettMap.get(loggedInUser.TIM_System__c).boomi_Endpoint__c;
            System.debug('@@boomiServer '+boomiServer);
        }catch(Exception ex){  System.debug('@@Exception '+ex);   }
    }
    
    public BoomiWebServiceHelper(UserConnection__c userConn){
        if(userConn!=null){
            try{
                loggedInUser = userConn;
                custSettMap = TIMIntegration__c.getAll();
                // System.debug('@@custSettMap '+custSettMap);
                System.debug('Tim System::::'+loggedInUser.TIM_System__c);
                if(custSettMap.containsKey(loggedInUser.TIM_System__c)){
                    userName = custSettMap.get(loggedInUser.TIM_System__c).UserName__c;
                    passwd = custSettMap.get(loggedInUser.TIM_System__c).Password__c;
                    userId = Integer.valueOf(custSettMap.get(loggedInUser.TIM_System__c).userId__c);
                    if(passwd ==  null) passwd = '';
                    appId = Integer.valueOf(custSettMap.get(loggedInUser.TIM_System__c).AppId__c);
                    timServer = custSettMap.get(loggedInUser.TIM_System__c).Endpoint__c;
                    boomiServer = custSettMap.get(loggedInUser.TIM_System__c).boomi_Endpoint__c;
                }
            }
            catch(Exception exp){  System.debug('Error in parameterized constructor:::'+exp.getMessage()); }
        }
    }
    
    public static HttpResponse RestServicePostStub(String endpoint, String body){
        System.debug('@@endpoint '+endpoint);
        System.debug('@@body '+body);
        //Instantiate a new http object
        Http h = new Http();
        //Instantiate a new HTTP request, specify the method as well as the endpoint
        HttpRequest req = new HttpRequest();
        //HttpResponse res ;
        HttpResponse res = new HttpResponse();
        req.setEndpoint(endpoint);      
        req.setMethod('POST');
        req.setHeader('Accept','application/xml');
        req.setHeader('Content-type','application/xml; charset=UTF-8');
        req.setHeader('Accept-Language', 'en-CA');
        
        if(String.isNotBlank(Label.SetTimeOut)) req.setTimeout(Integer.valueOf(Label.SetTimeOut));

        req.setBody(body);
        System.debug(body);
        try { res = h.send(req);
            System.debug('@@response '+res); }
        catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug('@@response '+res); }
            //Log4SF.logMessage('BoomiWebServiceHelper', endpoint, System.label.BoomiAPIError,e, UserInfo.getUserId(),'NA',res.getBody());
        if(res!=NULL && res.getStatus().equalsIgnoreCase('OK') && res.getStatusCode() == 200) System.debug('@@res body '+res.getBody());
        else{  Exception ex; System.debug('@@res status '+res.getStatus() + res); }
            //Log4SF.logMessage('BoomiWebServiceHelper', endpoint, System.label.BoomiAPIError,ex, UserInfo.getUserId(),'NA',res.getBody());
        return res;
    }

    // Code Change Start : Sridhar : 20-06-2017 : To display data in Boomi Dashboard
    public static HttpResponse RestServGetProcessData(String endPoint){
        System.debug('@@endPoint in Rest '+endPoint);
       // try{
            //Instantiate a new http object
            Http h = new Http();
            //Instantiate a new HTTP request, specify the method as well as the endpoint
            HttpRequest req = new HttpRequest();
            HttpResponse res ;     
            //req.setEndpoint('http://47.42.247.9:9090/ws/rest/SpectrumReach/processExecutionStatus');   
            req.setEndpoint(endPoint);
            req.setMethod('GET');
            req.setHeader('Accept','application/json');
            req.setHeader('Content-type','application/json; charset=UTF-8');
            req.setHeader('Accept-Language', 'en-CA');
            req.setTimeout(120000);
            System.debug('HTTPRequest: '+ req);
            try { res = h.send(req);
                System.debug('response>>>>>>>>>>>>>>'+res); }
            catch(System.CalloutException e) {
                System.debug('Callout error: '+ e); }
                //Log4SF.logMessage('BoomiWebServiceHelper', endpoint, System.label.BoomiAPIError,e, UserInfo.getUserId(),'NA',res.getBody());
            if(res!=NULL && res.getStatus().equalsIgnoreCase('OK') && res.getStatusCode() == 200) System.debug(res.getBody());
            else{  Exception ex; System.debug('@@res status '+res.getStatus() + res); } 
            return res;
    //  }catch(Exception e){ system.debug('Exception: '+e); return null; }

    }
    // Code Change End : Sridhar : 20-06-2017    


    public static HttpResponse RestServiceGetStub(String endpoint){
        
        //Instantiate a new http object
        Http h = new Http();
        //Instantiate a new HTTP request, specify the method as well as the endpoint
        HttpRequest req = new HttpRequest();
        //HttpResponse res ;
        HttpResponse res = new HttpResponse();
        req.setEndpoint(endpoint);      
        req.setMethod('GET');
        req.setHeader('Accept','application/xml');
        req.setHeader('Accept-Language', 'en-CA');
        System.debug('HTTPRequest: '+ req);
        try { res = h.send(req); }
        catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug('### res ::: ' +res); }
            //Log4SF.logMessage('BoomiWebServiceHelper', endpoint, System.label.BoomiAPIError,e, UserInfo.getUserId(),'NA',res.getBody());
        if(res.getStatus().equalsIgnoreCase('OK') && res.getStatusCode() == 200) System.debug(res.getBody());
        else{  Exception ex; System.debug('@@res status '+res.getStatus() + res); }      
        return res;
    }
    
    /**
     * This method returns the token from the authenticate call. This token needs to be passed from all 
     * the subsequent web service calls to TIM
     * 
     * @param  (none) (NA)
     * @return (String) (Access token for TIM API)
    */  

    public String authenticate(){
        HttpResponse tokenStr ;
        BoomiHelper.SAuthenticate_element request_x = new BoomiHelper.SAuthenticate_element();
        request_x.UserID = UserID;
        request_x.UserPassword = passwd;
        request_x.AppID = AppID;
        System.debug('@@request_x '+request_x);
        try{
            tokenStr = RestServicePostStub(boomiServer + '/authenticate',JSON.serialize(request_x));
            System.debug('tokenStr---'+tokenStr);
            if(tokenStr.getStatusCode() != 200) return System.Label.BoomiAPIError;
        } 
        catch(Exception e){
            System.debug('Exception---'+e + ' ::: line number ::: ' + e.getLineNumber());
            //Log4SF.logMessage('BoomiWebServiceHelper', 'authenticate', 'Exception in TIM API Authentication',e, UserInfo.getUserId(),'NA');
            return System.Label.BoomiAPIError; }
        
        System.debug('@@tokenStr.getBody() '+tokenStr.getBody());
        String sessionId = '';
        try{
          sessionId = BoomiHelper.parseAuthenticate(tokenStr.getBody()).SAuthenticateResponse.SAuthenticateResult;
          System.debug('@@sessionid '+sessionId);
        }
        catch(Exception ex){                                   
                sessionId = 'Error: ' + BoomiResponse.parse(tokenStr.getBody()).Response.error[0].cause;                
                //Log4SF.logMessage('BoomiWebServiceHelper', 'authenticate', 'Exception in TIM API Authentication',ex, UserInfo.getUserId(),'NA',String.valueOf(BoomiResponse.parse(tokenStr.getBody()).Response.metadata));            
        }
        return sessionId;
    }
    
    /**
     * This method returns the token from the authenticate call. This token needs to be passed from all 
     * the subsequent web service calls to TIM
     * 
     * @param  (none) (NA)
     * @return (String) (Access token for TIM API)
    */
    public String timUserId;  
    public String authenticateAE(){
        HttpResponse tokenStr ;
        BoomiHelper.SAuthenticate_element request_x = new BoomiHelper.SAuthenticate_element();
        
        //Fetch logged in user's TIM credentials from Org Cache
        try{
            // System.debug('@@Cache Key: ');
            /*System.debug('@@CacheManager.checkCacheSize() '+CacheManager.checkCacheSize());
            if(CacheManager.checkCacheSize() <=0){
                //CacheManager.refreshCache();
            }*/
            
            System.debug('Cache Key: ' + loggedInUser.Username__c+loggedInUser.TIM_System__c);
            string timSystem = loggedInUser.TIM_System__c;
            //replace '.'  and space
            if(timSystem.indexOf('.') > 0)
            {
              timSystem = timSystem.replace('.','');
              timSystem = timSystem.deleteWhitespace();
            }
            TIMUserAccess.User timuser = CacheManager.getTIMUser(loggedInUser.Username__c+timSystem,timSystem);
            System.debug('Cache Hit: ' + timuser);
            
            if(Test.isRunningTest()){
                timuser = new TIMUserAccess.User();
                timuser.UID = 2;
                timuser.UN = 'SFDCUser';
                timuser.UP = 'us3th3F0RCE!';
            }

            if(timuser != null && timUser.UID != null && String.isNotBlank(timUser.UP)){
                request_x.UserID = timuser.UID;
                timUserId = String.valueOf(timuser.UID);
                request_x.UserPassword = timuser.UP;
            }
            else if(System.label.CacheFailSafe == 'true'){ request_x.UserID = UserID; timUserId = String.valueOf(UserID); request_x.UserPassword = passwd; }
        }
        catch(Exception ex){ System.debug('Error in getting Cache: ' + ex+ex.getLineNumber()); }
        
        request_x.AppID = AppID;
        System.debug(boomiServer + '/authenticate' + JSON.serialize(request_x));
        try{
            tokenStr = RestServicePostStub(boomiServer + '/authenticate',JSON.serialize(request_x));
            System.debug('tokenStr---'+tokenStr);
            if(tokenStr.getStatusCode() != 200) return System.Label.BoomiAPIError; 
        } 
        catch(Exception e){
            System.debug('Exception---'+e + ' ::: Line number ::: ' +e.getLineNumber());
            Log4SF.logMessage('BoomiWebServiceHelper', 'authenticateAE', 'Exception in TIM API Authentication',e, UserInfo.getUserId(),'NA');            
            return System.Label.BoomiAPIError;
        }
        
        String sessionId = '';
        try{
          sessionId = BoomiHelper.parseAuthenticate(tokenStr.getBody()).SAuthenticateResponse.SAuthenticateResult;
          System.debug('@@sessionid '+sessionId); }
      catch(Exception ex){           
          sessionId = 'Error: ' + BoomiResponse.parse(tokenStr.getBody()).Response.error[0].cause;
                Log4SF.logMessage('BoomiWebServiceHelper', 'authenticateAE', 'Exception in TIM API Authentication',ex, UserInfo.getUserId(),'NA',String.valueOf(BoomiResponse.parse(tokenStr.getBody()).Response.metadata));                      
          
      }
        
        return sessionId;
    }
    
    /**
     * This method returns the token from the authenticate call. This token needs to be passed from all 
     * the subsequent web service calls to TIM
     * 
     * @param  (none) (NA)
     * @return (String) (Access token for TIM API)
    */
      
    public String authenticateAETIMSystem(String timSystem){
        HttpResponse tokenStr ;
        BoomiHelper.SAuthenticate_element request_x = new BoomiHelper.SAuthenticate_element();
        
        //Fetch logged in user's TIM credentials from Org Cache
        try{
            loggedInUser = [SELECT AE_Id__c, TIM_System__c, Username__c FROM UserConnection__c WHERE User__c=: UserInfo.getUserId() and TIM_System__c =: timSystem limit 1];  
            
            System.debug('Cache Key: ' + loggedInUser.Username__c+loggedInUser.TIM_System__c);
            
            //replace '.'  and space
            if(timSystem.indexOf('.') > 0)
            {
              timSystem = timSystem.replace('.','');
              timSystem = timSystem.deleteWhitespace();
            }
            System.debug(' ### loggedInUser.Username__c+timSystem :::: ' +loggedInUser.Username__c+timSystem);
            TIMUserAccess.User timuser = CacheManager.getTIMUser(loggedInUser.Username__c+timSystem,timSystem);
            System.debug('Cache Hit: ' + timuser);
            
            if(Test.isRunningTest()){
                timuser = new TIMUserAccess.User();
                timuser.UID = 2;
                timuser.UN = 'SFDCUser';
                timuser.UP = 'us3th3F0RCE!';
            }

            if(timuser != null && timUser.UID != null && String.isNotBlank(timUser.UP)){
                request_x.UserID = timuser.UID;
                timUserId = String.valueOf(timuser.UID);
                request_x.UserPassword = timuser.UP;
            }
            else if(System.label.CacheFailSafe == 'true'){ request_x.UserID = UserID; timUserId = String.valueOf(UserID); request_x.UserPassword = passwd; }
        }
        catch(Exception ex){ System.debug('Error in getting Cache: ' + ex+ex.getLineNumber()); return 'Error: Missing user connection for '+ timSystem + ' TIM.'; }
        
        request_x.AppID = AppID;
        System.debug(boomiServer + '/authenticate' + JSON.serialize(request_x));
        try{
            tokenStr = RestServicePostStub(boomiServer + '/authenticate',JSON.serialize(request_x));
            System.debug('tokenStr---'+tokenStr);
            if(tokenStr.getStatusCode() != 200) return System.Label.BoomiAPIError;
        } 
        catch(Exception e){
            System.debug('Exception---'+e);
            Log4SF.logMessage('BoomiWebServiceHelper', 'authenticateAE', 'Exception in TIM API Authentication',e, UserInfo.getUserId(),'NA');
            return System.Label.BoomiAPIError;
        }
        
        String sessionId = '';
        try{
          sessionId = BoomiHelper.parseAuthenticate(tokenStr.getBody()).SAuthenticateResponse.SAuthenticateResult;
          System.debug('@@sessionid '+sessionId);
        }
        catch(Exception ex){
         sessionId = 'Error: ' + BoomiResponse.parse(tokenStr.getBody()).Response.error[0].cause;
          System.debug('@@sessionid '+sessionId);
          Log4SF.logMessage('BoomiWebServiceHelper', 'authenticateAE', 'Exception in TIM API Authentication',ex, UserInfo.getUserId(),'NA',String.valueOf(BoomiResponse.parse(tokenStr.getBody()).Response.metadata));
        }
        
        return sessionId;
    }
    
    /**
     * This method accepts map of Account object and Verifies if each account has correct record type
     * 
     * @param  (Map<Id,Account> acctMap) (Map of Salesforce Accounts)     
     * @return (String) (Success or Error string)
    */
    public String verifyAccountRecordType(Opportunity opp, Map<Id,Account> acctMap){
        Map<Id,Account> accMap = new Map<Id,Account> ([SELECT Id, RecordType.DeveloperName, BillingStreet FROM Account WHERE Id IN:acctMap.keyset()]);
        Boolean flag = false;
        String retString = '';
        System.debug('acctMap' + acctMap);
        System.debug('Opp' + Opp);
        if(accMap.containsKey(opp.Rep_Firm__c))
        {
            if(opp.Rep_Firm__c!=null && accMap.get(opp.Rep_Firm__c).RecordType.DeveloperName != 'Rep_Firm'){
                Log4SF.logMessage('BoomiWebServiceHelper', 'verifyAccountRecordType', 'Incorrect Rep Firm Record Type', UserInfo.getUserId(),opp.Id);
                flag = true;
                retString = 'Error: Incorrect Record Type for Opportunity Rep Firm. ';
            }
        }
        else if(accMap.containsKey(opp.Agency_Account__c))
        {
            if(opp.Agency_Account__c!=null && (accMap.get(opp.Agency_Account__c).RecordType.DeveloperName != 'Agency_Account' && accMap.get(opp.Agency_Account__c).RecordType.DeveloperName != 'In_House_Agency_Account') ){ // SRSF-3447: Added 'In House Agency Account' check
                Log4SF.logMessage('BoomiWebServiceHelper', 'verifyAccountRecordType', 'Incorrect Agency Record Type', UserInfo.getUserId(),opp.Id);
                flag = true;
                retString = retString + 'Error: Incorrect Record Type for Opportunity Agency.';
            }
        }
        if(flag == true) return retString;   
        return 'Success';
    }
    
    
    /**
     * This method accepts map of Account object and Verifies if each account has value for Tim id.
     * If it is not there , then call TIM webservice and create the same account in TIM and update TIM id value in
     * Salesforce Account.
     * 
     * @param  (Opportunity opp) (Opportunity record in Salesforce)
     * @param  (Map<Id,Account> acctMap) (Map of Salesforce Accounts)
     * @param  (UserConnection__c oppAE) (User connection of Opportunity Owner)
     * @return (Map<String,String>) (Map of Accounts and their TIM Ids)
    */
    Map<String,String> accResponseMap = new Map<String,String>();    
    public Map<String,String> verifyAccountTimIds(Opportunity opp, Map<Id,Account> acctMap,UserConnection__c oppAE){
      System.debug('acctMap>>>>>>>>>>'+acctMap);
      //Check for opportunity accounts recordtypes
      String rtCheck = verifyAccountRecordType(opp,acctMap);
      if (rtCheck.startsWith('Error')){
          accResponseMap.put('',rtCheck);
          return accResponseMap;
      }
      
      System.debug('verifyAccountTimIds:verifyAccountRecordType Successfull!!!');
      
      //Query Opportunity Owner's TIM System for Account creation
      try{
        custSettMap = TIMIntegration__c.getAll();
            System.debug('verifyAccountTimIds:custSettMap '+custSettMap);
            boomiServer = custSettMap.get(oppAE.TIM_System__c).boomi_Endpoint__c;
            System.debug('verifyAccountTimIds:boomiServer '+boomiServer);
      }
        catch(Exception ex){
          System.debug('Exception in getting Opp Owner TIM settings '+ ex);
          accResponseMap.put('','Error: An error occurred while getting TIM Information.');
          return accResponseMap;
        }
        
        System.debug('verifyAccountTimIds:getBoomiEndpoint Successfull!!!');
        
        //Query Account Connections for Opportunity Accounts
        List<AccountConnection__c> toBeInsertedAccountConnections = new List<AccountConnection__c>();
        Map<Id,AccountConnection__c> accConMap = new Map<Id,AccountConnection__c>(); 
        Set<String> aeIdSet = new Set<String>();
        Set<String> agencyOrRepfirmTimIds = new Set<String>();

        Map<String,String> mapAccToAE = new Map<String,String>();      

    for(AccountConnection__c accCon : [Select TIM_ID__c,Account__c,Account__r.BillingState,Account__r.BillingCity,Account__r.BillingStreet,Account__r.Phone,Account__r.BillingPostalCode, Account__r.ShippingState,Account__r.ShippingCity,Account__r.ShippingStreet,Account__r.ShippingPostalCode,Account__r.name,AgencyTIMId__c,Account__r.account_tim_name__c,AE_Id__c,Account_Record_Type__c from AccountConnection__c where Account__c in:acctMap.keyset() and TIM_System__c =: oppAE.TIM_System__c ORDER by createdDate]){  
             
        if(accCon.Account_Record_Type__c!='Advertiser Account' || (String.isBlank(opp.Rep_Firm__c) && String.isBlank(opp.Agency_Account__c) && String.isBlank(accCon.AgencyTIMId__c)) ){
            agencyOrRepfirmTimIds.add(accCon.AgencyTIMId__c);
            accConMap.put(accCon.Account__c, accCon);
            //if(accCon.AE_Id__c!=NULL && accCon.TIM_ID__c!=NULL) aeIdSet.add(accCon.AE_Id__c);   
            if(accCon.AE_Id__c!=NULL && accCon.TIM_ID__c!=NULL){
                aeIdSet.add(accCon.AE_Id__c);                    
                mapAccToAE.put(accCon.AE_Id__c,accCon.TIM_ID__c);   //15-07-2019 
                System.debug('mapAccToAE-1>>>>>'+mapAccToAE);
            }                 
        }          
    } 
        System.debug('aeIdSet-1>>>>>>>'+aeIdSet);       
        System.debug('agencyOrRepfirmTimIds--->'+agencyOrRepfirmTimIds);
        System.debug('verifyAccountTimIds:accConMap-1: '+accConMap);
        
        //Map Opportunity Rep Firm or Agency_Account for Sync
        String oppRepFirmOrAgencyId = '';
        if(String.isNotBlank(opp.Rep_Firm__c)){
            oppRepFirmOrAgencyId = opp.Rep_Firm__c;
            for(AccountConnection__c accCon : [Select TIM_ID__c,Account__c,Account__r.BillingState,Account__r.BillingCity,Account__r.BillingStreet,Account__r.Phone,Account__r.BillingPostalCode,Account__r.ShippingState,Account__r.ShippingCity,Account__r.ShippingStreet,Account__r.ShippingPostalCode,Account__r.name,AgencyTIMId__c,Account__r.account_tim_name__c,AE_Id__c,Account_Record_Type__c from AccountConnection__c where Account__c in:acctMap.keyset() and TIM_System__c =: oppAE.TIM_System__c and AgencyTIMId__c IN :agencyOrRepfirmTimIds ORDER by createdDate]){
                accConMap.put(accCon.Account__c, accCon);
                System.debug('Rep Firm accConMap--->'+accConMap);
                //if(accCon.AE_Id__c!=NULL && accCon.TIM_ID__c!=NULL) aeIdSet.add(accCon.AE_Id__c);
                if(accCon.AE_Id__c!=NULL && accCon.TIM_ID__c!=NULL){
                    aeIdSet.add(accCon.AE_Id__c);
                    mapAccToAE.put(accCon.AE_Id__c,accCon.TIM_ID__c);    //15-07-2019
                    System.debug('mapAccToAE-2>>>>>'+mapAccToAE);
                } 
            }
        }
        else if(String.isNotBlank(opp.Agency_Account__c)){
            oppRepFirmOrAgencyId = opp.Agency_Account__c;
            for(AccountConnection__c accCon : [Select TIM_ID__c,Account__c,Account__r.BillingState,Account__r.BillingCity,Account__r.BillingStreet,Account__r.Phone,Account__r.BillingPostalCode,Account__r.ShippingState,Account__r.ShippingCity,Account__r.ShippingStreet,Account__r.ShippingPostalCode,Account__r.name,AgencyTIMId__c,Account__r.account_tim_name__c,AE_Id__c,Account_Record_Type__c from AccountConnection__c where Account__c in:acctMap.keyset() and TIM_System__c =: oppAE.TIM_System__c and AgencyTIMId__c IN :agencyOrRepfirmTimIds ORDER by createdDate]){
                accConMap.put(accCon.Account__c, accCon);
                  System.debug('Agency acccon--->'+accCon);
               // if(accCon.AE_Id__c!=NULL && accCon.TIM_ID__c!=NULL) aeIdSet.add(accCon.AE_Id__c);       
               if(accCon.AE_Id__c!=NULL && accCon.TIM_ID__c!=NULL){
                    aeIdSet.add(accCon.AE_Id__c);
                    mapAccToAE.put(accCon.AE_Id__c,accCon.TIM_ID__c);    //15-07-2019
                    System.debug('mapAccToAE-3>>>>>'+mapAccToAE);
                }             
            }

        }
        System.debug('aeIdSet-2>>>>>>>'+aeIdSet); 
         System.debug('oppRepFirmOrAgencyId--->'+oppRepFirmOrAgencyId);
         System.debug('verifyAccountTimIds:accConMap-2: '+accConMap);
        AccountConnection__c oppRepFirmOrAgencyAC = new AccountConnection__c();
        try{   
           if(String.isNotBlank(oppRepFirmOrAgencyId)){     
                oppRepFirmOrAgencyAC = [Select TIM_ID__c,Account__c,Account__r.BillingState,Account__r.BillingCity,Account__r.BillingStreet,Account__r.Phone,Account__r.BillingPostalCode, Account__r.ShippingState,Account__r.ShippingCity,Account__r.ShippingStreet,Account__r.ShippingPostalCode,Account__r.name,AgencyTIMId__c,Account__r.account_tim_name__c from AccountConnection__c where Account__c=:oppRepFirmOrAgencyId and TIM_System__c =: oppAE.TIM_System__c ORDER by CreatedDate DESC LIMIT 1];
            }
        }catch(Exception ex){}
        System.debug('oppRepFirmOrAgencyAC--->'+oppRepFirmOrAgencyAC);
        /*Creating Agency in TIM if TIM id is not present.*/
        Account agencyAcc = new Account();
        if(acctMap.containsKey(opp.Agency_Account__c))
        {
            if(opp.Agency_Account__c != null && (accConMap.get(opp.Agency_Account__c) == null || String.isBlank(accConMap.get(opp.Agency_Account__c).AgencyTIMId__c)) && acctMap.containsKey(opp.Agency_Account__c) )
            {
                system.debug('verifyAccountTimIds:Creating Agency in TIM since TIM id is not present '+ opp.Agency_Account__c );    
                agencyAcc = acctMap.get(opp.Agency_Account__c);
                accResponseMap.put(opp.Agency_Account__c,'');
            }
            else if(opp.Agency_Account__c != null && String.isNotBlank(accConMap.get(opp.Agency_Account__c).AgencyTIMId__c)){
            System.debug('verifyAccountTimIds:Agency Account Connection found.');
            accResponseMap.put(opp.Agency_Account__c,accConMap.get(opp.Agency_Account__c).AgencyTIMId__c);  
            }
        }
            
        /*Creating Rep Firm(as Agency) in TIM if TIM id is not present.*/
        Account repFirmAcc = new Account(); 
        if(opp.Rep_Firm__c != null && (accConMap.get(opp.Rep_Firm__c) == null || String.isBlank(accConMap.get(opp.Rep_Firm__c).AgencyTIMId__c))){
          system.debug('verifyAccountTimIds:Creating RepFirm in TIM since TIM id is not present '+ opp.Rep_Firm__c );
            repFirmAcc = acctMap.get(opp.Rep_Firm__c);                        
            accResponseMap.put(opp.Rep_Firm__c,'');
        }
        else if(opp.Rep_Firm__c != null && String.isNotBlank(accConMap.get(opp.Rep_Firm__c).AgencyTIMId__c)){
          System.debug('verifyAccountTimIds:RepFirm Account Connection found.');
            accResponseMap.put(opp.Rep_Firm__c,accConMap.get(opp.Rep_Firm__c).AgencyTIMId__c);                                   
        }
        
        //TODO : Advertiser Agency check is not required only Opp Agency is required.
        /*Creating Advertiser.Agency in TIM if Advertiser.Agency.TIMId is not present.
        AccountConnection__c accConAdAgencyOld;
        try{
            accConAdAgencyOld = [Select TIM_ID__c,Name,Account__r.BillingState,Account__r.BillingCity,Account__r.BillingStreet,Account__r.Phone,Account__r.BillingPostalCode,
                                        Account__r.ShippingState,Account__r.ShippingCity,Account__r.ShippingStreet,Account__r.ShippingPostalCode,Account__r.agency__c,AgencyTIMId__c,Account__r.account_tim_name__c                                       
                                 from   AccountConnection__c 
                                 where  Account__c=:acctMap.get(opp.AccountId).agency__c 
                                        and TIM_System__c =: oppAE.TIM_System__c LIMIT 1];
        }
        catch(Exception ex){}
        
        Account advertiserAgencyAcc = new Account();         
        if(opp.account.agency__c != null && accConAdAgencyOld == null){
            
            //If Advertiser.Agency same as Opportunity.Agency
            if(acctMap.get(opp.AccountId).agency__c == opp.Agency_Account__c){
                //No Action is required as Advertiser Agency will be synced to TIM as part of Opportunity Agency sync
            }            
            //If Advertiser.Agency not same as Opportunity.Agency
            else{
                try{
                    advertiserAgencyAcc = [Select Name,BillingState,BillingCity,BillingStreet,Phone,BillingPostalCode,
                                                  ShippingState,ShippingCity,ShippingStreet,ShippingPostalCode,account_tim_name__c                                       
                                           from Account
                                           where id=:acctMap.get(opp.AccountId).agency__c];
                }
                catch(Exception ex){
                    System.debug('Advertiser.Agency not same as Opportunity.Agency Block. Exception: ' + ex);
                }
            }
            accResponseMap.put(opp.account.agency__c,'');            
        }
        else if(opp.account.agency__c != null && accConAdAgencyOld != null){
            accResponseMap.put(opp.account.agency__c,accConAdAgencyOld.AgencyTIMId__c);
        }*/  
        System.debug('accConMap--->'+accConMap); 
        System.debug('accConMap.get(opp.AccountId)--->'+accConMap.get(opp.AccountId));    
        System.debug('oppRepFirmOrAgencyAC--->'+oppRepFirmOrAgencyAC);     
        System.debug('aeIdSet--->'+aeIdSet);       
        /*Creating Advertiser in TIM if TIM id is not present.*/
        Account advertiserAcc = new Account();
        String agencyTimID  = '';

        if(opp.AccountId != null && accConMap.get(opp.AccountId) == null){
            advertiserAcc = acctMap.get(opp.AccountId);                        
            accResponseMap.put(opp.AccountId,'');
            System.debug('verifyAccountTimIds:Creating Advertiser in TIM since TIM id is not present');    
            System.debug('accResponseMap--1--->'+accResponseMap);          
        }
                
        /*Creating Advertiser in TIM if Opportunity Agency TIM id or AEId is not present in Advertiser User Connection.*/
/*        else if(opp.AccountId != null && accConMap.get(opp.AccountId) != null && ( accConMap.get(opp.AccountId).AgencyTIMId__c != oppRepFirmOrAgencyAC.AgencyTIMId__c || accConMap.get(opp.AccountId).AE_Id__c != oppAE.AE_Id__c) ){*/
        else if(opp.AccountId != null && accConMap.get(opp.AccountId) != null && ( accConMap.get(opp.AccountId).AgencyTIMId__c != oppRepFirmOrAgencyAC.AgencyTIMId__c || !aeIdSet.contains(oppAE.AE_Id__c))){
            advertiserAcc = acctMap.get(opp.AccountId);                        
            accResponseMap.put(opp.AccountId,'');
            System.debug('verifyAccountTimIds:Creating Advertiser in TIM since Opportunity Agency TIM id or AEId is not present in Advertiser User Connection.'
                +accConMap.get(opp.AccountId).AgencyTIMId__c+oppRepFirmOrAgencyAC.AgencyTIMId__c+accConMap.get(opp.AccountId).AE_Id__c+oppAE.AE_Id__c);
        }
        else if(opp.AccountId != null && accConMap.get(opp.AccountId) != null){
            // accResponseMap.put(opp.AccountId,accConMap.get(opp.AccountId).TIM_Id__c); //15-07-2019
            accResponseMap.put(opp.AccountId,mapAccToAE.get(oppAE.AE_Id__c)); //15-07-2019
            System.debug('verifyAccountTimIds:Advertiser Account Connection found.');  
            System.debug('accResponseMap--->'+accResponseMap);   
            System.debug('mapAccToAE.get(oppAE.AE_Id__c)--->'+mapAccToAE.get(oppAE.AE_Id__c));   
            System.debug('accConMap.get(opp.AccountId).TIM_Id__c--->'+accConMap.get(opp.AccountId).TIM_Id__c); 
            System.debug('accResponseMap--3--->'+accResponseMap);      
        }
        
        //agencyTimID = accConAdAgencyOld == NULL ? '' : accConAdAgencyOld.Tim_ID__c;
        System.debug('verifyAccountTimIds:advertiserAcc Before Sync: ' + advertiserAcc);
        System.debug('verifyAccountTimIds:agencyAcc Before Sync: ' + agencyAcc);
        System.debug('verifyAccountTimIds:repFirmAcc Before Sync: ' + repFirmAcc);
        System.debug('verifyAccountTimIds:oppRepFirmOrAgencyId Before Sync: ' + oppRepFirmOrAgencyId);
        
        //Save Accounts in TIM
        Account emptyAccount = new Account();
        // SRSF-1762 Code starts here
        accResponseMap.put('createAccInTIM','false');
        /*Commented below if block and added new one 
        if(advertiserAcc!=emptyAccount || agencyAcc!=emptyAccount || repFirmAcc!=emptyAccount)                
          accResponseMap = saveTIMAccounts(advertiserAcc,agencyAcc,repFirmAcc,oppRepFirmOrAgencyId,oppAE);*/
        if(advertiserAcc!=emptyAccount || agencyAcc!=emptyAccount || repFirmAcc!=emptyAccount) {
            createAccInTIM = true;
            accResponseMap.put('createAccInTIM','true');
        } 
        if(!Boolean.valueOf(System.Label.Show_confirmation_msg_for_new_account_creation_in_TIM))
            confirmCreateAcc = true;
        System.debug('createAccInTIM::: ' + createAccInTIM);
        System.debug('confirmCreateAcc::: ' + confirmCreateAcc);
        if(createAccInTIM && confirmCreateAcc)               
          accResponseMap = saveTIMAccounts(advertiserAcc,agencyAcc,repFirmAcc,oppRepFirmOrAgencyId,oppAE);
       // SRSF -1762 code ends here
        
        System.debug('verifyAccountTimIds:accResponseMap after Sync: ' + accResponseMap );
        
        if(accResponseMap.values()[0].contains('Error')){
          System.debug('verifyAccountTimIds returning with an error: ' + accResponseMap);
          return accResponseMap;
        }

       // advertiserAcc = (advertiserAcc.Id != null)? advertiserAcc: exstngAdvAcc;

        System.debug('verifyAccountTimIds:advertiserAcc after::: ' + advertiserAcc);

        //Check results for Save TIM Accounts and Generate Account Connections        
        if( NULL!=advertiserAcc.Id && String.isNotBlank(accResponseMap.get(advertiserAcc.Id)) && !accResponseMap.get(advertiserAcc.Id).startsWith('Error')){
          System.debug('verifyAccountTimIds:Generate Advertiser Account Connection:' + accResponseMap.get(advertiserAcc.id));
            AccountConnection__c advertiserAccCon = new AccountConnection__c();
                advertiserAccCon.Account__c = advertiserAcc.id;
                advertiserAccCon.TIM_ID__c = accResponseMap.get(advertiserAcc.id);
                advertiserAccCon.AE_Id__c = oppAE.AE_Id__c;
                try{
                    if(!accResponseMap.get(oppRepFirmOrAgencyId).startsWith('Error') && accResponseMap.get(oppRepFirmOrAgencyId) != '1'){
                        advertiserAccCon.AgencyTIMId__c = accResponseMap.get(oppRepFirmOrAgencyId);
                    }
                }catch(Exception ex){}
                advertiserAccCon.TIM_System__c = oppAE.TIM_System__c;
            toBeInsertedAccountConnections.add(advertiserAccCon);
        }
        if(String.isNotBlank(accResponseMap.get(agencyAcc.Id)) && !accResponseMap.get(agencyAcc.Id).startsWith('Error')){
          System.debug('verifyAccountTimIds:Generate Agency Account Connection:' + accResponseMap.get(agencyAcc.id));
            AccountConnection__c agencyAccCon = new AccountConnection__c();
                agencyAccCon.Account__c = agencyAcc.id;
                agencyAccCon.AgencyTIMId__c = accResponseMap.get(agencyAcc.id);
                agencyAccCon.TIM_System__c = oppAE.TIM_System__c;
            toBeInsertedAccountConnections.add(agencyAccCon);
        }
        if(String.isNotBlank(accResponseMap.get(repFirmAcc.Id)) && !accResponseMap.get(repFirmAcc.Id).startsWith('Error')){
          System.debug('verifyAccountTimIds:Generate RepFirm Account Connection:' + accResponseMap.get(repFirmAcc.id));
            AccountConnection__c repFirmAccCon = new AccountConnection__c();
                repFirmAccCon.Account__c = repFirmAcc.id;
                repFirmAccCon.AgencyTIMId__c = accResponseMap.get(repFirmAcc.id);
                repFirmAccCon.TIM_System__c = oppAE.TIM_System__c;
            toBeInsertedAccountConnections.add(repFirmAccCon);
        }
        //TODO: Not Required
        /*if(accResponseMap.get(advertiserAgencyAcc.Id)!='Error'){
            AccountConnection__c advertiserAgencyAccCon = new AccountConnection__c();
                advertiserAgencyAccCon.Account__c = advertiserAgencyAcc.id;
                advertiserAgencyAccCon.TIM_ID__c = accResponseMap.get(advertiserAgencyAcc.id);
                advertiserAgencyAccCon.AE_Id__c = oppAE.AE_Id__c;
                advertiserAgencyAccCon.AgencyTIMId__c = accResponseMap.get(advertiserAgencyAcc.id);
                advertiserAgencyAccCon.TIM_System__c = oppAE.TIM_System__c;
            toBeInsertedAccountConnections.add(advertiserAgencyAccCon);
        }*/
        System.debug('toBeInsertedAccountConnections---->'+toBeInsertedAccountConnections);  
        if(toBeInsertedAccountConnections.size() >0){
          System.debug('verifyAccountTimIds:InsertAccountConnections: ' + toBeInsertedAccountConnections.size());
            Database.UpsertResult[] accountConnectResult = Database.upsert(toBeInsertedAccountConnections, false);
            System.debug(' ### accountConnectResult ::: ' +accountConnectResult);
            
            List<Common_Setting__mdt> cmnSetting = [SELECT Id, Label, DeveloperName, MasterLabel, Condition_Enable__c FROM Common_Setting__mdt WHERE DeveloperName = 'EnableAccountConnectionCreate' limit 1]; 
            if(cmnSetting.size()>0 && cmnSetting[0].Condition_Enable__c){
                // Changes for SRSF-1300
                for(Database.UpsertResult sr : accountConnectResult) {
                    if(!sr.isSuccess()) {
                        isAccConnectionCreated = false;
                    }
                }
            }

        }
        System.debug(' ### isAccConnectionCreated ::: ' +isAccConnectionCreated);
        System.debug('verifyAccountTimIds Successfull!!!');
        return accResponseMap;
    }
    
    /**
     * This method saves new Advertiser,Agency,RepFirm in TIM
     * 
     * @param  (Account advertiserAcc) (Advertiser Account record in Salesforce to be created as Advertiser in TIM)
     * @param  (Account agencyAcc) (Agency Account record in Salesforce to be created as Agency in TIM)
     * @param  (Account repFirmAcc) (RepFirm Account record in Salesforce to be created as Agency in TIM)
     * @return (String advertiserId) (Id of Advertiser record in TIM)
    */
    public Map<String,String> saveTIMAccounts(Account advertiserAcc, Account agencyAcc, Account repFirmAcc, string AgencyTimID,UserConnection__c oppAE){
        StratagTimservice.ServiceSoap stub = new StratagTimservice.ServiceSoap();
        String login = '';
        Account emptyAcc = new Account();                
        BoomiHelper.BoomiAccounts ba = new BoomiHelper.BoomiAccounts();
        
        /*Construct output variables for web service*/
        HttpResponse result = new HttpResponse();
        System.debug('### advertiserAcc ::: ' +advertiserAcc);
        /*gets the TIM access token.*/
        try{
            login = authenticateAETIMSystem(oppAE.TIM_System__c);
            if(login.contains('Error')){
              accResponseMap.clear();
              accResponseMap.put(advertiserAcc.id,Label.ErrorWhileAuthenticatewithTim);
              return accResponseMap;
            }
        }
        catch(Exception e){
            System.debug('saveTIMAccounts:e.getException: ' + e.getMessage());
            accResponseMap.clear();
            accResponseMap = new Map<String, String>();
            accResponseMap.put(advertiserAcc.id,Label.ErrorWhileAuthenticatewithTim);
            return accResponseMap;
        }
        
        System.debug('saveTIMAccounts:authenticateAETIMSystem Successfull!!!');
        
        
                
        //Map Agency Account
        if(agencyAcc!=emptyAcc){
          /*Construct the input for web service*/
          BoomiHelper.SaveEntities_4_2 se = new BoomiHelper.SaveEntities_4_2(); 
          BoomiHelper.Entities entityObj = new BoomiHelper.Entities();
          BoomiHelper.ArrayOfAgency_4_2 agencyArrayObj = new BoomiHelper.ArrayOfAgency_4_2(); 
          BoomiHelper.Agency_4_2[] agencyArray = new BoomiHelper.Agency_4_2[]{};
            BoomiHelper.Agency_4_2 agencyObj = new BoomiHelper.Agency_4_2();
            agencyObj = mapAccountToAgencyBoomi(agencyAcc);
            agencyArray.add(agencyObj);
            agencyArrayObj.Agency_4_2 = agencyArray;
            entityObj.AgencyList_4_2 = agencyArrayObj;
            
            ba.SessionID = login;
            se.Entities = entityObj;
            ba.SaveEntities_4_2 = se;
            
            /*Web service call*/
            try{
                result = RestServicePostStub(boomiServer + '/saveEntities',JSON.serialize(ba));
                String agencyId ='';
                System.debug('### result.getBody() ::: ' +result.getBody());
                try{
                  System.debug(BoomiHelper.parse(result.getBody()));              
                agencyId = BoomiHelper.parse(result.getBody()).SaveEntities_4_2Response.SaveEntities_4_2Result.EntityResult[0].ID;
            }
          catch(Exception ex){
            agencyId = 'Error: ' + BoomiResponse.parse(result.getBody()).Response.error[0].cause;
              System.debug('saveTIMAccounts:@@agencyId '+agencyId);
              Log4SF.logMessage('BoomiWebServiceHelper', 'saveTIMAccounts', 'Exception in TIM Agency Sync',ex, UserInfo.getUserId(),'NA',String.valueOf(BoomiResponse.parse(result.getBody()).Response.metadata));
              accResponseMap.clear();
              accResponseMap.put(agencyAcc.id, agencyId);                   
                    return accResponseMap; 
          }
                //To prevent Account Connection from getting created with 0 as Agency ID
                if(agencyId == '0'){
                    System.debug('saveTIMAccounts:Agency Sync Error!' + agencyId);
                    accResponseMap.clear();
                    accResponseMap.put(agencyAcc.id,'Error: ' + Label.BoomiTIMAgencySyncError);                   
                    return accResponseMap;
                }
                else if(String.isNotBlank(agencyId)) accResponseMap.put(agencyAcc.id,agencyId);
                else{
                    System.debug('saveTIMAccounts:Agency Sync Error!' + agencyId);
                    accResponseMap.clear();
                    accResponseMap.put(agencyAcc.id,'Error: ' + Label.BoomiTIMAgencySyncError);                   
                    return accResponseMap;
                }         
            }
            catch(Exception e){
                System.debug('saveTIMAccounts:Agency Sync Exception: ' + e.getMessage() + ' ::: Line Number ::: ' +e.getLineNumber());
                accResponseMap.clear();
                accResponseMap.put(agencyAcc.id,'Error: ' + Label.BoomiTIMAgencySyncError);
                return accResponseMap;
            }
        }
        
        //Map RepFirm Account
        if(repFirmAcc!=emptyAcc){
          /*Construct the input for web service*/
          BoomiHelper.SaveEntities_4_2 se = new BoomiHelper.SaveEntities_4_2(); 
          BoomiHelper.Entities entityObj = new BoomiHelper.Entities();
          BoomiHelper.ArrayOfAgency_4_2 agencyArrayObj = new BoomiHelper.ArrayOfAgency_4_2(); 
          BoomiHelper.Agency_4_2[] agencyArray = new BoomiHelper.Agency_4_2[]{};
            BoomiHelper.Agency_4_2 repFirmObj = new BoomiHelper.Agency_4_2();           
            repFirmObj = mapAccountToAgencyBoomi(repFirmAcc);
            agencyArray.add(repFirmObj);
            agencyArrayObj.Agency_4_2 = agencyArray;
            entityObj.AgencyList_4_2 = agencyArrayObj;          
            ba.SessionID = login;
            se.Entities = entityObj;
            ba.SaveEntities_4_2 = se;
            
            /*Web service call*/
            try{
                result = RestServicePostStub(boomiServer + '/saveEntities',JSON.serialize(ba));
                System.debug(BoomiHelper.parse(result.getBody()));              
                String repFirmId = BoomiHelper.parse(result.getBody()).SaveEntities_4_2Response.SaveEntities_4_2Result.EntityResult[0].ID;
                
                //To prevent Account Connection from getting created with 0 as RepFirm ID
                if(repFirmId == '0'){
                    System.debug('saveTIMAccounts:RepFirm Sync Error!' + repFirmId);
                    accResponseMap.clear();
                    accResponseMap.put(repFirmAcc.id,'Error: ' + Label.BoomiTIMAgencySyncError + ' Rep Firm');                   
                    return accResponseMap;
                }
                if(String.isNotBlank(repFirmId)) accResponseMap.put(repFirmAcc.id,repFirmId);
                else{
                  accResponseMap.clear();
                    accResponseMap.put(repFirmAcc.id,'Error' + Label.BoomiTIMAgencySyncError + ' Rep Firm');                   
                    return accResponseMap;
                }         
            }
            catch(Exception e){
              System.debug('saveTIMAccounts:RepFirm Sync Exception: ' + e.getMessage());
              accResponseMap.clear();
                accResponseMap.put(repFirmAcc.id,'Error' + Label.BoomiTIMAgencySyncError + ' Rep Firm');
                return accResponseMap;
            }
        }
                
        //Map Advertiser Account
        if(advertiserAcc!=emptyAcc){
          BoomiHelper.SaveEntities_4_2 se = new BoomiHelper.SaveEntities_4_2(); 
          BoomiHelper.Entities entityObj = new BoomiHelper.Entities();
          BoomiHelper.ArrayOfAgency_4_2 agencyArrayObj = new BoomiHelper.ArrayOfAgency_4_2(); 
          BoomiHelper.Agency_4_2[] agencyArray = new BoomiHelper.Agency_4_2[]{};
            BoomiHelper.ArrayOfAdvertiser_4_2 AdvertiserArrayObj = new BoomiHelper.ArrayOfAdvertiser_4_2(); 
            BoomiHelper.Advertiser_4_2[] AdvertiserArray = new BoomiHelper.Advertiser_4_2[]{};
            BoomiHelper.Advertiser_4_2 AdvertiserObj = new BoomiHelper.Advertiser_4_2();
            
            String repAgencyTIMId= accResponseMap.get(AgencyTimID) == 'Error' ? '' : accResponseMap.get(AgencyTimID);
            
            AdvertiserObj = mapAccountToAdvertiserBoomi(advertiserAcc,repAgencyTIMId);
            AdvertiserArray.add(AdvertiserObj);
            AdvertiserArrayObj.Advertiser_4_2 = AdvertiserArray;
            entityObj.AdvertiserList_4_2 = AdvertiserArrayObj;
            ba.SessionID = login;
            se.Entities = entityObj;
            ba.SaveEntities_4_2 = se;
            
            /*Web service call*/
            try{
                result = RestServicePostStub(boomiServer + '/saveEntities',JSON.serialize(ba));
                System.debug('@@@@@@@@@@@ Advertiser in TIM:::'+BoomiHelper.parse(result.getBody()));              
                String advertiserId = BoomiHelper.parse(result.getBody()).SaveEntities_4_2Response.SaveEntities_4_2Result.EntityResult[0].ID;
                //To prevent Account Connection from getting created with 0 as ADV ID                 
                if(advertiserId == '0'){
                    System.debug('saveTIMAccounts:Advertiser Sync Error!' + advertiserId);
                    accResponseMap.clear();
                    accResponseMap.put(advertiserAcc.id,'Error: ' + Label.BoomiTIMAdvertiserSyncError);                   
                    return accResponseMap;
                }
                else if(String.isNotBlank(advertiserId)) accResponseMap.put(advertiserAcc.id,advertiserId);
                else{
                    System.debug('saveTIMAccounts:Advertiser Sync Error!' + advertiserId);
                    accResponseMap.clear();
                    accResponseMap.put(advertiserAcc.id,'Error: ' + Label.BoomiTIMAdvertiserSyncError);                   
                    return accResponseMap;
                }         
            }
            catch(Exception e){
                System.debug('saveTIMAccounts:Advertiser Sync Exception: ' + e.getMessage());
                accResponseMap.clear();
                accResponseMap.put(advertiserAcc.id,'Error: ' + Label.BoomiTIMAdvertiserSyncError);
                return accResponseMap;
            }
        }
        
        //TODO : Not Required
        /*Map Advertiser Agency Account
        if(advertiserAgencyAcc!=emptyAcc){
            BoomiHelper.Agency_4_2 advertiserAgencyObj = new BoomiHelper.Agency_4_2();          
            advertiserAgencyObj = mapAccountToAgencyBoomi(advertiserAgencyAcc);
            agencyArray.add(advertiserAgencyObj);
            agencyArrayObj.Agency_4_2 = agencyArray;
            entityObj.AgencyList_4_2 = agencyArrayObj;
            ba.SessionID = login;
            se.Entities = entityObj;
            ba.SaveEntities_4_2 = se;
            
            //Web service call
            try{
                result = RestServicePostStub(boomiServer + '/saveEntities',JSON.serialize(ba));
                System.debug(BoomiHelper.parse(result.getBody()));              
                String advertiserAgencyId = BoomiHelper.parse(result.getBody()).SaveEntities_4_2Response.SaveEntities_4_2Result.EntityResult[0].ID;
                if(String.isNotBlank(advertiserAgencyId)){
                    accResponseMap.put(advertiserAgencyAcc.id,advertiserAgencyId);
                }
                else{
                    accResponseMap.put(advertiserAcc.id,'Error');                   
                    return accResponseMap;
                }         
            }
            catch(Exception e){
                System.debug('e.getException: ' + e.getMessage());
                accResponseMap.put(advertiserAcc.id,'Error');
                return accResponseMap;
            }
        }*/
    
    System.debug('saveTIMAccounts:syncwithTIM Successfull!!!');                 
        return accResponseMap;        
    }
    
    /**
     * This method maps a Salesforce Account to a TIM Advertiser record
     * 
     * @param  (Account acc) (Account record in Salesforce)
     * @return (BoomiHelper.Advertiser_4_2) (TIM Advertiser object)
    */
    public BoomiHelper.Advertiser_4_2 mapAccountToAdvertiserBoomi(Account acc, String agencyTIMId){        
        BoomiHelper.Advertiser_4_2 Advertiser = new BoomiHelper.Advertiser_4_2();
        Advertiser.AdvertiserName = acc.Account_Tim_Name__c; 
         string bs1 , bs2 = '';
       if(String.isNotBlank(acc.BillingStreet) ){ 
            if(acc.BillingStreet.length() > 50){
                bs1 = acc.BillingStreet.substring(0,50);
                bs1 = bs1.substring(0,bs1.lastIndexOf(' '));
                bs2 = acc.BillingStreet.substring(acc.BillingStreet.indexOf(bs1),acc.BillingStreet.length());
              }else { bs1 = acc.BillingStreet;}
        }
        Advertiser.Address1 = bs1;
        Advertiser.Address2 = bs2.length() > 50 ? bs2.substring(0,50):bs2; 
        
        Advertiser.City = acc.BillingCity; 
        Advertiser.IsActive = true;
        Advertiser.Phone = acc.Phone; 
        Advertiser.State = acc.BillingState; 
        Advertiser.ZIP = acc.BillingPostalCode;
        Advertiser.AdvertiserID = 0;
        Advertiser.Discount = 0.0;
        
        if(!String.isBlank(agencyTIMId)) Advertiser.AgencyID = Integer.valueOf(agencyTIMId);
        else{ System.debug('AgencyId blank block'); Advertiser.AgencyID = 1; }
        Advertiser.Contact = '';
        Advertiser.ProductId = 0;
        Advertiser.IndustryCodeID = 0;
        Advertiser.CommodityID = 0;
        
        
        List<BoomiHelper.TrafficIDElement> listIDE = new List<BoomiHelper.TrafficIDElement>();
        BoomiHelper.ArrayOfTrafficIDElement arrayOfTraffic = new BoomiHelper.ArrayOfTrafficIDElement();
        BoomiHelper.TrafficIDElement traffic = new BoomiHelper.TrafficIDElement();
        traffic.ExportSystemID = 1;
        //traffic.TrafficID = '0';
        listIDE.add(traffic);
        arrayOfTraffic.TrafficIDElement = listIDE;
        Advertiser.TrafficIDs = arrayOfTraffic; 
        return Advertiser;
    }
    
    /**
     * This method maps a Salesforce Account to a TIM agency record
     * 
     * @param  (Account acc) (Account record in Salesforce)
     * @return (BoomiHelper.Agency_4_2) (TIM agency object)
    */
    public BoomiHelper.Agency_4_2 mapAccountToAgencyBoomi(Account acc){        
        BoomiHelper.Agency_4_2 agency = new BoomiHelper.Agency_4_2();
        agency.AgencyName = acc.Account_Tim_Name__c; 
         string bs1 , bs2 = '';
         if(String.isNotBlank(acc.BillingStreet) )
      { 
        if(acc.BillingStreet.length() > 50)
          {
            bs1 = acc.BillingStreet.substring(0,50);
            bs1 = bs1.substring(0,bs1.lastIndexOf(' '));
            bs2 = acc.BillingStreet.substring(acc.BillingStreet.indexOf(bs1),acc.BillingStreet.length());
          } else { bs1 = acc.BillingStreet; }
      }
        agency.Address1 = bs1;
        agency.Address2 = bs2.length() > 50 ? bs2.substring(0,50):bs2; 
        
        agency.City = acc.BillingCity; 
        agency.IsActive = true;
        agency.Phone = acc.Phone; 
        agency.State = acc.BillingState; 
        agency.ZIP = acc.BillingPostalCode;
        agency.AgencyID = 0;
        agency.Discount = 0.0;
        
        return agency;
    }
    
    /**
     * This method saves a new Advertiser in TIM
     * 
     * @param  (Account acc) (Account record in Salesforce to be created as Advertiser in TIM)
     * @return (String advertiserId) (Id of Advertiser record in TIM)
    */
    public String saveAdvertiser(Account acc){
        StratagTimservice.ServiceSoap stub = new StratagTimservice.ServiceSoap();
        StratagTimservice.Login login = new StratagTimservice.Login();
        
        /*gets the TIM access token.*/
        try{ login.User_x = authenticate(); }
        catch(Exception e){ System.debug('e.getException: ' + e.getMessage()); return 'Exception'; }

        login.Password = '';
        stub.Login = login;
        
        /*Construct the input for web service*/
        StratagTimservice.Entities entityObj = new StratagTimservice.Entities();
        StratagTimservice.ArrayOfAdvertiser_4_2 AdvertiserArrayObj = new StratagTimservice.ArrayOfAdvertiser_4_2(); 
        StratagTimservice.Advertiser_4_2[] AdvertiserArray = new StratagTimservice.Advertiser_4_2[]{};
        StratagTimservice.Advertiser_4_2 AdvertiserObj = new StratagTimservice.Advertiser_4_2();
        
        AdvertiserObj = mapAccountToAdvertiser(acc,'');
        AdvertiserArray.add(AdvertiserObj);
        AdvertiserArrayObj.Advertiser_4_2 = AdvertiserArray;
        entityObj.AdvertiserList_4_2 = AdvertiserArrayObj;
        
        /*Construct output variables for web service*/
        StratagTimservice.ArrayOfEntityResult result = new StratagTimservice.ArrayOfEntityResult();
        String AdvertiserID = '';
        
        /*Web service call*/
        try{
            result = stub.SaveEntities_4_2(entityObj);
            AdvertiserID = String.valueOf(result.EntityResult[0].ID);
            
            if(AdvertiserID == '0'){
                System.debug('Web Service error message: ' + result.EntityResult[0].Errors.string_x);
                return 'Exception: '+result.EntityResult[0].Errors.string_x;
            }
            else{ System.debug('Advertiser creation successfull! AdvertiserID: ' + AdvertiserID);  }            
        }
        catch(Exception e){ System.debug('e.getException: ' + e.getMessage() + ' ::: Line number ::: ' +e.getLineNumber()); return 'Exception'; }
                 
        return AdvertiserID;        
    }
    
    /**
     * This method maps a Salesforce Account to a TIM Advertiser record
     * 
     * @param  (Account acc) (Account record in Salesforce)
     * @return (StratagTimservice.Advertiser_4_2) (TIM Advertiser object)
    */
    public StratagTimservice.Advertiser_4_2 mapAccountToAdvertiser(Account acc, String agencyTIMId){        
        StratagTimservice.Advertiser_4_2 Advertiser = new StratagTimservice.Advertiser_4_2();
        Advertiser.AdvertiserName = acc.Account_Tim_Name__c; 
         string bs1 , bs2 = '';
         if(String.isNotBlank(acc.BillingStreet) )
      { 
        if(acc.BillingStreet.length() > 50)
          {
            bs1 = acc.BillingStreet.substring(0,50);
            bs1 = bs1.substring(0,bs1.lastIndexOf(' '));
            bs2 = acc.BillingStreet.substring(acc.BillingStreet.indexOf(bs1),acc.BillingStreet.length());
          }else { bs1 = acc.BillingStreet; }
      }
        Advertiser.Address1 = bs1;
        Advertiser.Address2 = bs2.length() > 50 ? bs2.substring(0,50):bs2; 
        
        Advertiser.City = acc.BillingCity; 
        Advertiser.IsActive = true;
        Advertiser.Phone = acc.Phone; 
        Advertiser.State = acc.BillingState; 
        Advertiser.ZIP = acc.BillingPostalCode;
        Advertiser.AdvertiserID = 0;
        Advertiser.Discount = 0.0;
        
        if(!String.isBlank(agencyTIMId)) Advertiser.AgencyID = Integer.valueOf(agencyTIMId);
        else{ System.debug('AgencyId blank block'); Advertiser.AgencyID = 1; }
        Advertiser.Contact = '';
        Advertiser.ProductId = 0;
        Advertiser.IndustryCodeID = 0;
        Advertiser.CommodityID = 0;
      
        List<StratagTimservice.TrafficIDElement> listIDE = new List<StratagTimservice.TrafficIDElement>();
        StratagTimservice.ArrayOfTrafficIDElement arrayOfTraffic = new StratagTimservice.ArrayOfTrafficIDElement();
        StratagTimservice.TrafficIDElement traffic = new StratagTimservice.TrafficIDElement();
        traffic.ExportSystemID = 1;
        //traffic.TrafficID = '0';
        listIDE.add(traffic);
        arrayOfTraffic.TrafficIDElement = listIDE;
        Advertiser.TrafficIDs = arrayOfTraffic; 
        return Advertiser;
    }
    
    /**
     * This method saves a new Agency/Rep Firm (as Agency only) in TIM
     * 
     * @param  (Account acc) (Account record in Salesforce to be created as Agency in TIM)
     * @return (String agencyId) (Id of agency record in TIM)
    */
    public String saveAgency(AccountConnection__c acc){
        StratagTimservice.ServiceSoap stub = new StratagTimservice.ServiceSoap();
        StratagTimservice.Login login = new StratagTimservice.Login();
        
        /*gets the TIM access token.*/
        try{ login.User_x = authenticate(); }
        catch(Exception e){ System.debug('e.getException: ' + e.getMessage()); return 'Exception'; }

        login.Password = '';
        stub.Login = login;
        
        /*Construct the input for web service*/
        StratagTimservice.Entities entityObj = new StratagTimservice.Entities();
        StratagTimservice.ArrayOfAgency_4_2 agencyArrayObj = new StratagTimservice.ArrayOfAgency_4_2(); 
        StratagTimservice.Agency_4_2[] agencyArray = new StratagTimservice.Agency_4_2[]{};
        StratagTimservice.Agency_4_2 agencyObj = new StratagTimservice.Agency_4_2();
        
        //agencyObj = mapAccountToAgency(acc);
        agencyArray.add(agencyObj);
        agencyArrayObj.Agency_4_2 = agencyArray;
        entityObj.AgencyList_4_2 = agencyArrayObj;
        
        /*Construct output variables for web service*/
        StratagTimservice.ArrayOfEntityResult result = new StratagTimservice.ArrayOfEntityResult();
        String agencyID = '';
        
        /*Web service call*/
        try{
            result = stub.SaveEntities_4_2(entityObj);
            agencyID = String.valueOf(result.EntityResult[0].ID);
            
            if(agencyID == '0'){
                System.debug('Web Service error message: ' + result.EntityResult[0].Errors.string_x);
                return 'Exception';
            }
            else{ System.debug('Agency creation successfull! agencyID: ' + agencyID);  }
        }
        catch(Exception e){ System.debug('e.getException: ' + e.getMessage() + ' ::: line number ::: ' +e.getLineNumber()); return 'Exception'; }
                 
        return agencyID;        
    }
    
    /**
     * This method maps a Salesforce Account to a TIM agency record
     * 
     * @param  (Account acc) (Account record in Salesforce)
     * @return (StratagTimservice.Agency_4_2) (TIM agency object)
    */
    public StratagTimservice.Agency_4_2 mapAccountToAgency(Account acc){        
        StratagTimservice.Agency_4_2 agency = new StratagTimservice.Agency_4_2();
        agency.AgencyName = acc.Account_Tim_Name__c; 
         string bs1 , bs2 = '';
         if(String.isNotBlank(acc.BillingStreet) )
      { 
        if(acc.BillingStreet.length() > 50)
          {
            bs1 = acc.BillingStreet.substring(0,50);
            bs1 = bs1.substring(0,bs1.lastIndexOf(' '));
            bs2 = acc.BillingStreet.substring(acc.BillingStreet.indexOf(bs1),acc.BillingStreet.length());
          }else{ bs1 = acc.BillingStreet; }
      }
        agency.Address1 = bs1;
        agency.Address2 = bs2.length() > 50 ? bs2.substring(0,50):bs2;  
        
        agency.City = acc.BillingCity; 
        agency.IsActive = true;
        agency.Phone = acc.Phone; 
        agency.State = acc.BillingState; 
        agency.ZIP = acc.BillingPostalCode;
        agency.AgencyID = 0;
        agency.Discount = 0.0;
        
        return agency;
    }
    
    /**
     * This method saves a new Rep Firm in TIM
     * 
     * @param  (Account acc) (Account record in Salesforce to be created as Agency in TIM)
     * @return (String agencyId) (Id of agency record in TIM)
    */
    public String saveRepFirm(AccountConnection__c acc){
        StratagTimservice.ServiceSoap stub = new StratagTimservice.ServiceSoap();
        StratagTimservice.Login login = new StratagTimservice.Login();
        
        /*gets the TIM access token.*/
        try{ login.User_x = authenticate(); }
        catch(Exception e){ System.debug('e.getException: ' + e.getMessage()); return System.label.TIMLoginError; }

        login.Password = '';
        stub.Login = login;
        
        /*Construct the input for web service*/
        StratagTimservice.Entities entityObj = new StratagTimservice.Entities();
        StratagTimservice.ArrayOfAgency_4_2 agencyArrayObj = new StratagTimservice.ArrayOfAgency_4_2(); 
        StratagTimservice.Agency_4_2[] agencyArray = new StratagTimservice.Agency_4_2[]{};
        StratagTimservice.Agency_4_2 agencyObj = new StratagTimservice.Agency_4_2();
        
        //agencyObj = mapAccountToAgency(acc);
        agencyArray.add(agencyObj);
        agencyArrayObj.Agency_4_2 = agencyArray;
        entityObj.AgencyList_4_2 = agencyArrayObj;
        
        /*Construct output variables for web service*/
        StratagTimservice.ArrayOfEntityResult result = new StratagTimservice.ArrayOfEntityResult();
        String agencyID = '';
        
        /*Web service call*/
        try{
            result = stub.SaveEntities_4_2(entityObj);
            agencyID = String.valueOf(result.EntityResult[0].ID);
            
            if(agencyID == '0'){
                System.debug('Web Service error message: ' + result.EntityResult[0].Errors.string_x);
                return System.Label.TIMAgencySyncError;
            }
            else{ System.debug('Agency creation successfull! agencyID: ' + agencyID); }
        }
        catch(Exception e){
            System.debug('e.getException: ' + e.getMessage() + ' ::: line number ::: ' +e.getLineNumber());
            return System.Label.TIMAgencySyncError;
        }
                 
        return agencyID;        
    }
   
    /**
     * This method maps a Salesforce Account to a TIM Rep Firm record
     * 
     * @param  (Account acc) (Account record in Salesforce)
     * @return (StratagTimservice.RepFirm_3_2) (TIM RepFirm object)
    */
    public StratagTimservice.RepFirm_3_2 mapAccountToRepFirm(AccountConnection__c acc){        
       
       StratagTimservice.RepFirm_3_2 repFirm = new StratagTimservice.RepFirm_3_2();
        repFirm.RepFirmID = 0;
        repFirm.RepFirmName = acc.Account__r.Account_Tim_Name__c;
       string bs1 , bs2 = '';
       System.debug('repFirm.RepFirmName::'+repFirm.RepFirmName);
       System.debug('acc.Account__r.BillingStreet::'+acc.Account__r.BillingStreet);
        if(acc.Account__r.BillingStreet.length() > 50)
        {
          bs1 = acc.Account__r.BillingStreet.substring(0,50);
          bs1 = bs1.substring(0,bs1.lastIndexOf(' '));
          bs2 = acc.Account__r.BillingStreet.substring(acc.Account__r.BillingStreet.indexOf(bs1),acc.Account__r.BillingStreet.length());
        }
        repFirm.Address1 = bs1;
        repFirm.Address2 = bs2.length() > 50 ? bs2.substring(0,50):bs2;        
        repFirm.City = acc.Account__r.BillingCity;
        repFirm.State = acc.Account__r.BillingState; 
        repFirm.ZIP = acc.Account__r.BillingPostalCode;
        repFirm.Phone = acc.Account__r.Phone; 
        repFirm.IsActive = true;
       
        return repFirm;
    }
    
    /**
     * This method syncs proposal changes from TIM to Salesforce
     * 
     * @param  (Proposal__c pro) (Proposal record in Salesforce to be updated)
     * @param  (UserConnection__c oppOwnerUser) (UserConnection record of related Opportunity Owner)
     * @return (String message) (Status of sync)
    */
    public String syncProposalLineItems(Proposal__c pro, UserConnection__c oppOwnerUser){
        
        //Query Opportunity Owner's TIM System for proposal sync
        try{
            custSettMap = TIMIntegration__c.getAll();
            System.debug('syncProposalLineItems:custSettMap '+custSettMap);
            boomiServer = custSettMap.get(oppOwnerUser.TIM_System__c).boomi_Endpoint__c;
            System.debug('syncProposalLineItems:boomiServer '+boomiServer);
        }
        catch(Exception ex){
            System.debug('syncProposalLineItems:Exception in getting Opp Owner TIM settings '+ ex);
            accResponseMap.put('','Error: Exception in getting Opp Owner TIM settings');
            return 'Error: Exception in getting Opp Owner TIM settings';
        }
        
        StratagTimservice.Login login = new StratagTimservice.Login();
        HttpResponse result = new HttpResponse();
        
        /*gets the TIM access token.*/
        try{
            System.debug('oppOwnerUser.TIM_System__c::'+oppOwnerUser.TIM_System__c);
            //TODO:Add error message handling
            login.User_x = authenticateAETIMSystem(oppOwnerUser.TIM_System__c);
            System.debug('login.User_x::'+login.User_x);
        }
        catch(Exception e){
            System.debug('syncProposalLineItems:Exception in authenticate: ' + e.getMessage());
            return Label.ErrorWhileAuthenticatewithTim;
        }
        
        //SavePoint preSyncState = null; 
        SavePoint preSyncState;
        /*EstimateHeaders Web service call*/
        try{
            System.debug('result rpo::::' + pro.TIM_Id__c);
            System.debug('result key::::' + login.User_x);
            
            result = RestServiceGetStub(boomiServer + '/estimateHeaders?sessionKey=' + login.User_x + '&estimateId=' + pro.TIM_Id__c);            
            
            String responseBody = !Test.isRunningTest() ? result.getBody() : '{ "GetEstimateHeaders_Result" : { "EstimateHeader" : [ { "EstimateID" : 387544, "Description" : "Testing Opportunity Jan09", "AdvertiserID" : 83926, "AgencyID" : 0, "ProductID" : 1203, "FlightStart" : "6/25/2018", "FlightEnd" : "7/29/2018", "Weeks" : 5, "AEID" : 1, "CreatedBy" : "SFDCUser", "Comments" : "Order File Loaded: Electronic SCX Transfer", "EdiClient" : "704134", "EdiProduct" : "6", "EdiEstimate" : "2514", "EdiInvoice" : "true", "ExternalOrderNo" : "A795572A-D2EC-40F9-97EF-BE5D2FAD3690", "BroadcastValues" : { "BroadcastValue" : [ { "YearMonth" : "2018.07", "TotalSpots" : 188, "TotalCost" : 832 } ] }, "Networks" : "BET;BRVO;DISC;FOOD;FRFM;HGTV;HIST;TLC;USA", "NetworkCount" : 9, "Status" : "Proposal", "IsDeleted" : "NotDeleted", "SurveyVersions" : { "SurveyVersion" : [ { "SurveyID" : 611868, "VersionNumber" : 1 } ] }, "ScheduleItems" : { "ScheduleItem_4_6" : [ { "SysCodes" : "2100", "Zones" : "Spectrum/DISH- I+ Huntsville/Decatur, AL, 2100", "Markets" : "Huntsville", "BroadcastValues" : { "BroadcastValue" : [ { "YearMonth" : "2018.07", "TotalSpots" : 188, "TotalCost" : 832 } ] }, "OrderStatus" : "Proposal", "ScheduleType" : "Linear" } ] } } ] } }';
       
            System.debug('result::::' + result);
            System.debug('result12::::' +responseBody);            
            System.debug('EstimateHeaders.result: \n' + BoomiHelper.parseBoomiHelper1(responseBody));
            //System.debug('Final res:'+BoomiHelper.parseBoomiHelper1(result.getBody()).GetEstimateHeaders_Result.EstimateHeader[0]);
            
            BoomiHelper.BoomiHelper1 bhelper =  BoomiHelper.parseBoomiHelper1(responseBody);
 
            if(isFrmSCXUpload == true && 
                (bhelper ==null || 
                bhelper.GetEstimateHeaders_Result == null || 
                bhelper.GetEstimateHeaders_Result.EstimateHeader == null || 
                bhelper.GetEstimateHeaders_Result.EstimateHeader.size() == 0)
            )
            {
                return Label.SCX_ErrorFromTim + Label.SCX_Upload_XML_Error;
            }

            BoomiHelper.EstimateHeader estHeader =  bhelper.GetEstimateHeaders_Result.EstimateHeader[0];
            System.debug('estHeader:'+estHeader);
            

            preSyncState = Database.setSavePoint();
            
            /*Map Estimate info to Proposal record*/            
            pro.name = estHeader.Description;
            pro.description__c = estHeader.Description;
            if(String.isNotEmpty(estHeader.FlightStart))
            pro.Start_Date__c = Date.parse(estHeader.FlightStart);
            if(String.isNotEmpty(estHeader.FlightEnd))
            pro.End_Date__c = Date.parse(estHeader.FlightEnd);
        //  pro.TIM_System__c = oppOwnerUser.TIM_System__c; // Commented on 08-08-2019 While Proposal Sync/Update, we should not populate Opp Owner's TIM System
            pro.AE_ID__c = oppOwnerUser.AE_Id__c; 
            try{
                pro.Traffic_Order_Number__c = estHeader.TrafficOrderNumber;
                pro.TIM_Status__c = estHeader.status;
            }catch(Exception ex){}
            try{
                pro.Revenue_Type__c = estHeader.RevenueType.Description;
            }catch(Exception ex){}
            try{            
                pro.Comments__c = estHeader.Comments;
            }catch(Exception ex){}
            try{                
                pro.Networks__c = estHeader.Networks;
            }catch(Exception ex){}
            

            //Code Added by Abhilash  : 24-09-2018
            if(String.isNotBlank(estHeader.IsDeleted) && estHeader.IsDeleted.equalsIgnoreCase('NotDeleted')) pro.Active__c  = TRUE; 
            else if (String.isNotBlank(estHeader.IsDeleted) && (estHeader.IsDeleted.equalsIgnoreCase('Deleted') || estHeader.IsDeleted.equalsIgnoreCase('NotFound'))) pro.Active__c  = FALSE;
            
            //Code Ends here
            //Map Rep Firm/Agency on proposal
            try{               
                AccountConnection__c acAgency = [Select account__c from AccountConnection__c where AgencyTIMId__c =:String.valueOf(estHeader.agencyId) and tim_system__c =: oppOwnerUser.TIM_System__c and Account_Record_Type__c in ('Agency Account','Rep Firm') limit 1];              
                System.debug('syncProposalLineItems:pro.agency__c '+pro.agency__c);
                if(estHeader.agencyId != 1 && estHeader.agencyId != 0) pro.agency__c = acAgency.account__c;
            
                try{ 
                    AccountConnection__c p = [Select id,AgencyTIMId__c from AccountConnection__c where account__c=: pro.agency__c and tim_system__c =: oppOwnerUser.TIM_System__c limit 1];
                    if(p.AgencyTIMId__c == '1' || p.AgencyTIMId__c == '0') pro.agency__c = null;
                }
                catch(Exception ex){}  
            }
            catch(Exception ex){}
                        
            upsert pro;    
            
            processEstimateHeaderDetailsResponse(estHeader, pro);           
        }
        catch(CalloutException cex){
            System.debug('syncProposalLineItems:CalloutException: ' + cex + cex.getLineNumber());
            if(preSyncState!= null) Database.rollback(preSyncState);
            Log4SF.logMessage('BoomiWebServiceHelper', 'syncProposalLineItems', 'CalloutException in syncProposalLineItems',cex, UserInfo.getUserId(),pro.Id);
            if(cex.getMessage().contains('UNABLE_TO_LOCK_ROW')) return System.label.ProposalConcurrencyMessage;
            else return Label.BoomiAPIError;
        }
        catch(Exception e){
            System.debug('syncProposalLineItems:Exception in sync: ' + e + e.getLineNumber());
            if(preSyncState!= null) Database.rollback(preSyncState);
            Log4SF.logMessage('BoomiWebServiceHelper', 'syncProposalLineItems', 'Exception in syncProposalLineItems',e, UserInfo.getUserId(),pro.Id);
            if(e.getMessage().contains('UNABLE_TO_LOCK_ROW')) return System.label.ProposalConcurrencyMessage;
            else{ string retMsg = (isFrmSCXUpload == true)?Label.SCX_ErrorFromTim + e.getMessage():Label.TIMCreate_Sync_ProposalLineItems_Error; return retMsg; }
        }
                 
        return 'Success';        
    }
    
    /**
     * This method processes proposal changes from TIM to Salesforce objects
     * 
     * @param  (BoomiHelper.EstimateHeader estArr) (Estimate Header Array from TIM)
     * @param  (Proposal__c pro) (Proposal object)    
    */ 
    public void processEstimateHeaderDetailsResponse(BoomiHelper.EstimateHeader estArray, Proposal__c pro){
        
        /*Construct database variables*/
        Map<String,Proposal_Zone__c> proposalLineItemsInsertMap = new Map<String,Proposal_Zone__c>();
        List<Proposal_Zone_Monthly_Value__c> proposalLineScheduleInsertList = new List<Proposal_Zone_Monthly_Value__c>(); 
        
        if(estArray != null){
            
            /*Construct processing variables for GetEstimateHeaders result*/
            BoomiHelper.ScheduleItems scheduleItems = estArray.ScheduleItems;
            
            /*if product schedule list is not empty*/
            if(scheduleItems != null){
                
                /*loop though schedule items list and create insert lists for proposal Zones and proposal Monthly Values*/
                Integer i = 0;
                for(BoomiHelper.ScheduleItem_4_6 scheduleItem : scheduleItems.ScheduleItem_4_6){
                    BoomiHelper.BroadcastValues broadcastArray = scheduleItem.BroadcastValues;                    
                    Proposal_Zone__c pLine = new Proposal_Zone__c();
                    Proposal_Zone_Monthly_Value__c pLineSchedule;
                    List<BoomiHelper.SurveyVersion> surveys = estArray.SurveyVersions.SurveyVersion;
                    
                    pLine.name = scheduleItem.SysCodes;                    
                    pLine.Market__c = scheduleItem.Markets;
                    pLine.Proposal__c = pro.id;
                    pLine.Sys_Code__c = scheduleItem.SysCodes;
                    pLine.Zone__c = scheduleItem.Zones;
                    pLine.TIM_Status__c = scheduleItem.OrderStatus;
                    try{pLine.SurveyId__c = String.valueOf(surveys[i].SurveyID);}catch(Exception ex){System.debug('Exception in SurveryId mapping: '+ex);}                        
                    i++;
                    System.debug('processEstimateHeaderDetailsResponse:scheduleItem.Zones ' + scheduleItem.Zones);
                    
                    if(broadcastArray != null){
                        for(BoomiHelper.BroadcastValue bv : broadcastArray.BroadcastValue){
                            pLineSchedule = new Proposal_Zone_Monthly_Value__c();
                            System.debug('bv.YearMonth: ' + bv.YearMonth);
                            System.debug('bv.YearMonth: ' + bv.YearMonth.split('\\.',2));
                            System.debug('bv.TotalCost: ' + bv.TotalCost);
                            pLineSchedule.Broadcast_Month_Date__c = Date.parse(bv.YearMonth.split('\\.')[1] + '/15/' + bv.YearMonth.split('\\.')[0]);
                            pLineSchedule.Gross_Amount__c = bv.TotalCost;
                            pLineSchedule.Sys_Code__c = scheduleItem.SysCodes;
                            pLineSchedule.Advertiser__c = pro.Advertiser__c;
                            pLineSchedule.Opportunity__c = pro.Opportunity__c;
                            pLineSchedule.Proposal_Key_Index__c = pro.Id;
                            
                            proposalLineScheduleInsertList.add(pLineSchedule);
                        }
                    }
                    
                    proposalLineItemsInsertMap.put(scheduleItem.SysCodes,pLine);                    
                }
                
                
                if(proposalLineItemsInsertMap.size() > 0){
                    
                    try
                    {
                        List<Proposal_Zone__c> proposalZoneToDelete = [Select id from Proposal_Zone__c where proposal__c =: pro.id];

                        insert proposalLineItemsInsertMap.values();
                        for(Proposal_Zone_Monthly_Value__c pls: proposalLineScheduleInsertList)
                        {
                            pls.Proposal_Zone__c = proposalLineItemsInsertMap.get(pls.Sys_Code__c).id;
                        }
                        insert proposalLineScheduleInsertList;
                        delete proposalZoneToDelete;
                        if(proposalZoneToDelete.Size()>0){ Database.emptyRecycleBin(proposalZoneToDelete); } //SRSF-1895
                    }
                    catch(Exception e)
                    {
                        Log4SF.logMessage('BoomiWebServiceHelper', 'processEstimateHeaderDetailsResponse', e.getMessage(),e, UserInfo.getUserId(),pro.id);
                    }
                }                    
            }
        } 
    }    
        
    /**
     * This method activates Estimates in TIM
     * 
     * @param  (List<Proposal__c> propList) (Proposal records in Salesforce to be updated)
     * @return
    */
    public Map<String,HTTPResponse> activateProposals(List<Proposal__c> propList){
    StratagTimservice.ServiceSoap stub = new StratagTimservice.ServiceSoap();
    StratagTimservice.Login login = new StratagTimservice.Login();
    
        /*gets the TIM access token.*/
        try{ login.User_x = authenticate(); }
        catch(Exception e){ System.debug('e.getException: ' + e.getMessage()); }

        login.Password = '';
        stub.Login = login;
        
        //HTTPResponse retStatus = null;
        HTTPResponse retStatus = new HTTPResponse();
        /*Code chnages by Aditi : 5_4_2018 : To have ids instead of name as distinct key*/
        Map<String,HTTPResponse> retMap = new Map<String,HTTPResponse>();
        List<Proposal__c> toBeUpdatedProposal = new List<Proposal__c>();   
        for(Proposal__c proposal : propList){
            BoomiHelper.UndeleteOrderElement bhu = new BoomiHelper.UndeleteOrderElement();
            bhu.User = login.User_x;
            bhu.EstimateID = proposal.TIM_Id__c;
            bhu.UserID = String.valueOf(userId);
            
            BoomiHelper.UndeleteOrderRequest bhr = new BoomiHelper.UndeleteOrderRequest();
            bhr.UndeleteOrder = bhu;
            try{ retStatus = RestServicePostStub(boomiServer + '/unDeleteOrder',JSON.serialize(bhr)); }
            catch(Exception ex){
                System.debug('Exception in activateProposals API call: ' + ex + ' ::: line number ::: ' +ex.getLineNumber());
                Log4SF.logMessage('BoomiWebServiceHelper', 'ActivateProposals', 'Exception in ActivateProposals API call: '+JSON.serialize(bhr),ex, UserInfo.getUserId(),'NA');
            }
                
            if(retStatus.getStatusCode()== 200){
                proposal.Active__c = true;
                // Changes added by Bhuvan on 31-Aug-2018 START (SRSF-1268)
                proposal.Bad_Sync__c = false;
                proposal.Sync_Pending__c  = true;
                proposal.Sync_Pending_Since__c = Datetime.now();
                proposal.Bad_Sync_Reason__c = '';
                proposal.Bad_Sync_Reason_Text__c = '';
                // Changes added by Bhuvan on 31-Aug-2018 END
                toBeUpdatedProposal.add(proposal);
            }
            //else{
                /*Code chnages by Aditi : 5_4_2018 : To have ids instead of name as distinct key
                retMap.put(proposal.Name,string.valueof(retStatus));*/
                //retMap.put(proposal.Id,retStatus); Commented out this link and retMap is getting populated everytime
                /* code change ends */
            //}
            retMap.put(proposal.Id,retStatus);
        }  
            
        try{
            /*Code changes Aditi: 5th April,2018 : To controle inactivation of proposals */
            if(!inactiveActiveVar) update toBeUpdatedProposal;
            /* Code changes ends*/
            //update toBeUpdatedProposal;
        }
        catch(Exception e){ Log4SF.logMessage('BoomiWebServiceHelper', 'ActivateProposals', 'Exception in ActivateProposals Proposal update: '+toBeUpdatedProposal,e, UserInfo.getUserId(),'NA'); }
        return retMap;
    }
    
    
    /**
     * This method deactivates Estimates in TIM
     * 
     * @param  (List<Proposal__c> propList) (Proposal records in Salesforce to be updated)
     * @return
    */
    public Map<String,HTTPResponse> InActivateProposals(List<Proposal__c> propList){
    StratagTimservice.ServiceSoap stub = new StratagTimservice.ServiceSoap();
    StratagTimservice.Login login = new StratagTimservice.Login();
    
        /*gets the TIM access token.*/
        try{ login.User_x = authenticate(); }
        catch(Exception e){ System.debug('e.getException: ' + e.getMessage()); }

        login.Password = '';
        stub.Login = login;
        
        //HTTPResponse retStatus = null;
        HTTPResponse retStatus = new HTTPResponse();
        /*Code chnages by Aditi : 5_4_2018 : To have ids instead of name as distinct key */
        Map<String,HTTPResponse> retMap = new Map<String,HTTPResponse>();
        List<Proposal__c> toBeUpdatedProposal = new List<Proposal__c>();   
        for(Proposal__c proposal : propList){
            BoomiHelper.DeleteOrderElement bhd = new BoomiHelper.DeleteOrderElement();
            bhd.User = login.User_x;
            bhd.EstimateID = proposal.TIM_Id__c;
            bhd.UserID = String.valueOf(userId);
            
            BoomiHelper.DeleteOrderRequest bhr = new BoomiHelper.DeleteOrderRequest();
            bhr.DeleteOrder = bhd;              
            try{ retStatus = RestServicePostStub(boomiServer + '/deleteOrder',JSON.serialize(bhr)); }
            catch(Exception ex){
                System.debug('Exception in deactivateProposals API call: ' + ex + ' ::: line number ::: ' +ex.getLineNumber());
                Log4SF.logMessage('BoomiWebServiceHelper', 'InActivateProposals', 'Exception in InActivateProposals API call: '+JSON.serialize(bhr),ex, UserInfo.getUserId(),'NA');
            }
                
            if(retStatus.getStatusCode()== 200){
                proposal.Active__c = false;
                toBeUpdatedProposal.add(proposal);
            }
            retMap.put(proposal.Id,retStatus);
/*            else{
               // retMap.put(proposal.Name,string.valueof(retStatus));
                retMap.put(proposal.Id,retStatus);
            }*/
        }  
            
        try{
            /*Code changes Aditi: 5th April,2018 : To controle inactivation of proposals */
            if(!inactiveActiveVar) update toBeUpdatedProposal;
            /* Code changes ends*/
        }
        catch(Exception e){
            System.debug('e.getException: ' + e.getMessage());
            Log4SF.logMessage('BoomiWebServiceHelper', 'InActivateProposals', 'Exception in InActivateProposals Proposal update: '+toBeUpdatedProposal,e, UserInfo.getUserId(),'NA');
        }
        return retMap;
    }
    
    /**
     * This method is used to implement TIM importSCX API call.     
     * 
     * @param  (String) (XMLString)
     * @return (Integer) (TIM EstimateId)
    */  
public HttpResponse importSCX(String XMLString,String timSystem, String AEId, string AdvertiserID, String AgencyID,String ratecard)
{
    BoomiHelper.importSCXChanges bmH = new BoomiHelper.importSCXChanges();
    integer webServiceTimeOut = 120000;
    try
    {
        custSettMap = TIMIntegration__c.getAll();
        // System.debug('custSettMap '+custSettMap);
        boomiServer = custSettMap.get(timSystem).boomi_Endpoint__c;
        System.debug('boomiServer '+boomiServer);

        List<Common_Setting__mdt> commonSetting = [SELECT NumberValue__c FROM Common_Setting__mdt WHERE DeveloperName = :SCX_TIMEOUT_KEY];
        if(commonSetting!= null && commonSetting.size() ==1 && commonSetting.get(0).NumberValue__c != null)
            webServiceTimeOut =  Integer.valueof(commonSetting.get(0).NumberValue__c);
    }
    catch(Exception ex){
          System.debug('Exception in getting Opp Owner TIM settings '+ ex);
          Log4SF.logMessage('BoomiWebServiceHelper', 'importSCX', 'Exception in getting Opp Owner TIM settings ',ex, UserInfo.getUserId(),'NA');
          accResponseMap.put('','Error');
          return null;
    }
        
        StratagTimservice.Login login = new StratagTimservice.Login();
        HttpResponse result = new HttpResponse();
        
        /*gets the TIM access token.*/
        try{ bmH.SessionKey = authenticateAETIMSystem(timSystem); }
        catch(Exception e){
            System.debug('Exception in syncProposalLineItems.authenticate: ' + e.getMessage());
            Log4SF.logMessage('BoomiWebServiceHelper', 'importSCX', 'Exception in syncProposalLineItems.authenticate: ',e, UserInfo.getUserId(),'NA');
            return null;
        }
        bmH.FileContent = xmlString;
        bmH.AEId = AEId;
        bmH.AdvertiserID = AdvertiserID;
        bmH.agencyID  = agencyID;
        bmH.rateCardName = rateCard; 
        HttpResponse estimateId;
        System.debug('JSON.serialize(bmH) '+ JSON.serialize(bmH));
        try{
               //Sample SCX XMString for testing purpose
               //XMLString = '<?xml version="1.0" encoding="UTF-8"?><adx xsi:noNamespaceSchemaLocation="http://www.spotcable.com/schema/spotcableOrder_101.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><document><schemaVersion>1.0</schemaVersion><name>Hello SCX Order</name><date>2015-05-21</date><mediaType>Spotcable</mediaType><documentType/><documentCode/></document><campaign><key codeOwner="NCC" codeDescription="CampaignID"><id></id></key><key codeOwner="Strata" codeDescription="DMA Override"><id>0</id></key><key codeOwner="Strata" codeDescription="Zone Pops"><id>sum</id></key><key codeOwner="VIEW32" codeDescription="CampaignName"><id></id></key><key codeOwner="Strata" codeDescription="distro"><id>bc</id></key><dateRange><startDate>2014-12-29</startDate><endDate>2015-12-27</endDate></dateRange><company type="Rep"><name></name><office><name></name><address><street/><city/><state code="__"/><postalCode>00000</postalCode></address><phone type="voice"></phone></office><contact role="AE"><firstName/><lastName/><email/><phone type="voice"/></contact></company><company type="Agency"><name>THE TOLAND GROUP INC - AGY38598</name><contact role="Buyer"><firstName/><lastName/><email/><phone type="voice"></phone></contact><ID><code codeOwner="Agency"></code></ID></company><advertiser><name>101 Market - 14510</name><ID><code codeOwner="Agency"></code></ID></advertiser><product><name></name><ID><code codeOwner="Agency"></code></ID></product><estimate><desc>Hello SCX Order</desc><ID><code codeOwner="Agency"></code></ID></estimate><makeGoodPolicy><code/></makeGoodPolicy><demo demoRank="1"><group>Households</group><ageFrom>0</ageFrom><ageTo>99</ageTo></demo><buyType>weekly</buyType><populations demoRank="1">40425</populations><order><key codeOwner="NCC" codeDescription="Market"><id>180</id></key><key codeOwner=""><id/></key><key codeOwner="Strata" codeDescription="Pops"><id>zone</id></key><key codeOwner="Strata" codeDescription="UseBroadcastWeeks"><id>1</id></key><totals><cost>12000.00</cost><spots>11</spots></totals><market nsi_id="269"><name>Madison</name></market><survey><ratingService/><geography/><shareBook/><PUTBook/><profile/><comment codeOwner="Spotcable">Feb15 C-DMA Custom Live+1</comment></survey><populations demoRank="1">40425</populations><comment/><systemOrder><key codeOwner=""><id/></key><key codeOwner="Strata" codeDescription="UseZonePop"><id>true</id></key><comment></comment><system><name>Madison East, WI</name><syscode>0397</syscode></system><affiliateSplit/><populations demoRank="1">40425</populations><totals><cost>12000.00</cost><spots>11</spots></totals><weeks count="52"><week number="1" startDate="2014-12-29"/><week number="2" startDate="2015-01-05"/><week number="3" startDate="2015-01-12"/><week number="4" startDate="2015-01-19"/><week number="5" startDate="2015-01-26"/><week number="6" startDate="2015-02-02"/><week number="7" startDate="2015-02-09"/><week number="8" startDate="2015-02-16"/><week number="9" startDate="2015-02-23"/><week number="10" startDate="2015-03-02"/><week number="11" startDate="2015-03-09"/><week number="12" startDate="2015-03-16"/><week number="13" startDate="2015-03-23"/><week number="14" startDate="2015-03-30"/><week number="15" startDate="2015-04-06"/><week number="16" startDate="2015-04-13"/><week number="17" startDate="2015-04-20"/><week number="18" startDate="2015-04-27"/><week number="19" startDate="2015-05-04"/><week number="20" startDate="2015-05-11"/><week number="21" startDate="2015-05-18"/><week number="22" startDate="2015-05-25"/><week number="23" startDate="2015-06-01"/><week number="24" startDate="2015-06-08"/><week number="25" startDate="2015-06-15"/><week number="26" startDate="2015-06-22"/><week number="27" startDate="2015-06-29"/><week number="28" startDate="2015-07-06"/><week number="29" startDate="2015-07-13"/><week number="30" startDate="2015-07-20"/><week number="31" startDate="2015-07-27"/><week number="32" startDate="2015-08-03"/><week number="33" startDate="2015-08-10"/><week number="34" startDate="2015-08-17"/><week number="35" startDate="2015-08-24"/><week number="36" startDate="2015-08-31"/><week number="37" startDate="2015-09-07"/><week number="38" startDate="2015-09-14"/><week number="39" startDate="2015-09-21"/><week number="40" startDate="2015-09-28"/><week number="41" startDate="2015-10-05"/><week number="42" startDate="2015-10-12"/><week number="43" startDate="2015-10-19"/><week number="44" startDate="2015-10-26"/><week number="45" startDate="2015-11-02"/><week number="46" startDate="2015-11-09"/><week number="47" startDate="2015-11-16"/><week number="48" startDate="2015-11-23"/><week number="49" startDate="2015-11-30"/><week number="50" startDate="2015-12-07"/><week number="51" startDate="2015-12-14"/><week number="52" startDate="2015-12-21"/></weeks><detailLine detailLineID="0"><startTime>06:00:00</startTime><endTime>00:00:00</endTime><startDay>M</startDay><dayOfWeek><Monday>N</Monday><Tuesday>N</Tuesday><Wednesday>N</Wednesday><Thursday>N</Thursday><Friday>N</Friday><Saturday>N</Saturday><Sunday>Y</Sunday></dayOfWeek><length>PT30S</length><daypartCode>RT</daypartCode><program></program><comment>TP</comment><network><name>TACV</name><ID><code codeOwner="Spotcable" codeDescription="-1">TACV</code></ID><ID><code codeOwner="Strata" codeDescription="Station">TACV</code></ID></network><spotCost currency="USD">1000.00</spotCost><demoValue demoRank="1"><value type="Ratings">0.0</value><value type="Impressions">0</value></demoValue><totals><cost currency="USD">7000.00</cost><spots>7</spots></totals><spot><weekNumber>1</weekNumber><quantity>0</quantity></spot><spot><weekNumber>2</weekNumber><quantity>0</quantity></spot><spot><weekNumber>3</weekNumber><quantity>0</quantity></spot><spot><weekNumber>4</weekNumber><quantity>0</quantity></spot><spot><weekNumber>5</weekNumber><quantity>0</quantity></spot><spot><weekNumber>6</weekNumber><quantity>0</quantity></spot><spot><weekNumber>7</weekNumber><quantity>0</quantity></spot><spot><weekNumber>8</weekNumber><quantity>0</quantity></spot><spot><weekNumber>9</weekNumber><quantity>0</quantity></spot><spot><weekNumber>10</weekNumber><quantity>0</quantity></spot><spot><weekNumber>11</weekNumber><quantity>0</quantity></spot><spot><weekNumber>12</weekNumber><quantity>0</quantity></spot><spot><weekNumber>13</weekNumber><quantity>0</quantity></spot><spot><weekNumber>14</weekNumber><quantity>0</quantity></spot><spot><weekNumber>15</weekNumber><quantity>0</quantity></spot><spot><weekNumber>16</weekNumber><quantity>0</quantity></spot><spot><weekNumber>17</weekNumber><quantity>0</quantity></spot><spot><weekNumber>18</weekNumber><quantity>0</quantity></spot><spot><weekNumber>19</weekNumber><quantity>0</quantity></spot><spot><weekNumber>20</weekNumber><quantity>0</quantity></spot><spot><weekNumber>21</weekNumber><quantity>0</quantity></spot><spot><weekNumber>22</weekNumber><quantity>0</quantity></spot><spot><weekNumber>23</weekNumber><quantity>0</quantity></spot><spot><weekNumber>24</weekNumber><quantity>0</quantity></spot><spot><weekNumber>25</weekNumber><quantity>0</quantity></spot><spot><weekNumber>26</weekNumber><quantity>1</quantity></spot><spot><weekNumber>27</weekNumber><quantity>0</quantity></spot><spot><weekNumber>28</weekNumber><quantity>0</quantity></spot><spot><weekNumber>29</weekNumber><quantity>0</quantity></spot><spot><weekNumber>30</weekNumber><quantity>1</quantity></spot><spot><weekNumber>31</weekNumber><quantity>0</quantity></spot><spot><weekNumber>32</weekNumber><quantity>0</quantity></spot><spot><weekNumber>33</weekNumber><quantity>0</quantity></spot><spot><weekNumber>34</weekNumber><quantity>0</quantity></spot><spot><weekNumber>35</weekNumber><quantity>1</quantity></spot><spot><weekNumber>36</weekNumber><quantity>0</quantity></spot><spot><weekNumber>37</weekNumber><quantity>0</quantity></spot><spot><weekNumber>38</weekNumber><quantity>0</quantity></spot><spot><weekNumber>39</weekNumber><quantity>1</quantity></spot><spot><weekNumber>40</weekNumber><quantity>0</quantity></spot><spot><weekNumber>41</weekNumber><quantity>0</quantity></spot><spot><weekNumber>42</weekNumber><quantity>0</quantity></spot><spot><weekNumber>43</weekNumber><quantity>1</quantity></spot><spot><weekNumber>44</weekNumber><quantity>0</quantity></spot><spot><weekNumber>45</weekNumber><quantity>0</quantity></spot><spot><weekNumber>46</weekNumber><quantity>0</quantity></spot><spot><weekNumber>47</weekNumber><quantity>0</quantity></spot><spot><weekNumber>48</weekNumber><quantity>1</quantity></spot><spot><weekNumber>49</weekNumber><quantity>0</quantity></spot><spot><weekNumber>50</weekNumber><quantity>0</quantity></spot><spot><weekNumber>51</weekNumber><quantity>0</quantity></spot><spot><weekNumber>52</weekNumber><quantity>1</quantity></spot></detailLine><detailLine detailLineID="0"><startTime>06:00:00</startTime><endTime>00:00:00</endTime><startDay>M</startDay><dayOfWeek><Monday>N</Monday><Tuesday>N</Tuesday><Wednesday>N</Wednesday><Thursday>N</Thursday><Friday>N</Friday><Saturday>N</Saturday><Sunday>Y</Sunday></dayOfWeek><length>PT30S</length><daypartCode>RT</daypartCode><program></program><comment>TP</comment><network><name>TACV</name><ID><code codeOwner="Spotcable" codeDescription="-1">TACV</code></ID><ID><code codeOwner="Strata" codeDescription="Station">TACV</code></ID></network><spotCost currency="USD">2000.00</spotCost><demoValue demoRank="1"><value type="Ratings">0.0</value><value type="Impressions">0</value></demoValue><totals><cost currency="USD">2000.00</cost><spots>1</spots></totals><spot><weekNumber>1</weekNumber><quantity>0</quantity></spot><spot><weekNumber>2</weekNumber><quantity>0</quantity></spot><spot><weekNumber>3</weekNumber><quantity>0</quantity></spot><spot><weekNumber>4</weekNumber><quantity>0</quantity></spot><spot><weekNumber>5</weekNumber><quantity>0</quantity></spot><spot><weekNumber>6</weekNumber><quantity>0</quantity></spot><spot><weekNumber>7</weekNumber><quantity>0</quantity></spot><spot><weekNumber>8</weekNumber><quantity>0</quantity></spot><spot><weekNumber>9</weekNumber><quantity>0</quantity></spot><spot><weekNumber>10</weekNumber><quantity>0</quantity></spot><spot><weekNumber>11</weekNumber><quantity>0</quantity></spot><spot><weekNumber>12</weekNumber><quantity>0</quantity></spot><spot><weekNumber>13</weekNumber><quantity>0</quantity></spot><spot><weekNumber>14</weekNumber><quantity>0</quantity></spot><spot><weekNumber>15</weekNumber><quantity>0</quantity></spot><spot><weekNumber>16</weekNumber><quantity>0</quantity></spot><spot><weekNumber>17</weekNumber><quantity>0</quantity></spot><spot><weekNumber>18</weekNumber><quantity>0</quantity></spot><spot><weekNumber>19</weekNumber><quantity>0</quantity></spot><spot><weekNumber>20</weekNumber><quantity>0</quantity></spot><spot><weekNumber>21</weekNumber><quantity>0</quantity></spot><spot><weekNumber>22</weekNumber><quantity>0</quantity></spot><spot><weekNumber>23</weekNumber><quantity>0</quantity></spot><spot><weekNumber>24</weekNumber><quantity>0</quantity></spot><spot><weekNumber>25</weekNumber><quantity>0</quantity></spot><spot><weekNumber>26</weekNumber><quantity>1</quantity></spot><spot><weekNumber>27</weekNumber><quantity>0</quantity></spot><spot><weekNumber>28</weekNumber><quantity>0</quantity></spot><spot><weekNumber>29</weekNumber><quantity>0</quantity></spot><spot><weekNumber>30</weekNumber><quantity>0</quantity></spot><spot><weekNumber>31</weekNumber><quantity>0</quantity></spot><spot><weekNumber>32</weekNumber><quantity>0</quantity></spot><spot><weekNumber>33</weekNumber><quantity>0</quantity></spot><spot><weekNumber>34</weekNumber><quantity>0</quantity></spot><spot><weekNumber>35</weekNumber><quantity>0</quantity></spot><spot><weekNumber>36</weekNumber><quantity>0</quantity></spot><spot><weekNumber>37</weekNumber><quantity>0</quantity></spot><spot><weekNumber>38</weekNumber><quantity>0</quantity></spot><spot><weekNumber>39</weekNumber><quantity>0</quantity></spot><spot><weekNumber>40</weekNumber><quantity>0</quantity></spot><spot><weekNumber>41</weekNumber><quantity>0</quantity></spot><spot><weekNumber>42</weekNumber><quantity>0</quantity></spot><spot><weekNumber>43</weekNumber><quantity>0</quantity></spot><spot><weekNumber>44</weekNumber><quantity>0</quantity></spot><spot><weekNumber>45</weekNumber><quantity>0</quantity></spot><spot><weekNumber>46</weekNumber><quantity>0</quantity></spot><spot><weekNumber>47</weekNumber><quantity>0</quantity></spot><spot><weekNumber>48</weekNumber><quantity>0</quantity></spot><spot><weekNumber>49</weekNumber><quantity>0</quantity></spot><spot><weekNumber>50</weekNumber><quantity>0</quantity></spot><spot><weekNumber>51</weekNumber><quantity>0</quantity></spot><spot><weekNumber>52</weekNumber><quantity>0</quantity></spot></detailLine><detailLine detailLineID="0"><startTime>06:00:00</startTime><endTime>00:00:00</endTime><startDay>M</startDay><dayOfWeek><Monday>N</Monday><Tuesday>N</Tuesday><Wednesday>N</Wednesday><Thursday>N</Thursday><Friday>N</Friday><Saturday>N</Saturday><Sunday>Y</Sunday></dayOfWeek><length>PT30S</length><daypartCode>RT</daypartCode><program></program><comment>TP</comment><network><name>VDAN</name><ID><code codeOwner="Spotcable" codeDescription="-1">VDAN</code></ID><ID><code codeOwner="Strata" codeDescription="Station">VDAN</code></ID></network><spotCost currency="USD">1000.00</spotCost><demoValue demoRank="1"><value type="Ratings">0.0</value><value type="Impressions">0</value></demoValue><totals><cost currency="USD">3000.00</cost><spots>3</spots></totals><spot><weekNumber>1</weekNumber><quantity>0</quantity></spot><spot><weekNumber>2</weekNumber><quantity>0</quantity></spot><spot><weekNumber>3</weekNumber><quantity>0</quantity></spot><spot><weekNumber>4</weekNumber><quantity>0</quantity></spot><spot><weekNumber>5</weekNumber><quantity>0</quantity></spot><spot><weekNumber>6</weekNumber><quantity>0</quantity></spot><spot><weekNumber>7</weekNumber><quantity>0</quantity></spot><spot><weekNumber>8</weekNumber><quantity>0</quantity></spot><spot><weekNumber>9</weekNumber><quantity>0</quantity></spot><spot><weekNumber>10</weekNumber><quantity>0</quantity></spot><spot><weekNumber>11</weekNumber><quantity>0</quantity></spot><spot><weekNumber>12</weekNumber><quantity>0</quantity></spot><spot><weekNumber>13</weekNumber><quantity>0</quantity></spot><spot><weekNumber>14</weekNumber><quantity>0</quantity></spot><spot><weekNumber>15</weekNumber><quantity>0</quantity></spot><spot><weekNumber>16</weekNumber><quantity>0</quantity></spot><spot><weekNumber>17</weekNumber><quantity>0</quantity></spot><spot><weekNumber>18</weekNumber><quantity>0</quantity></spot><spot><weekNumber>19</weekNumber><quantity>0</quantity></spot><spot><weekNumber>20</weekNumber><quantity>0</quantity></spot><spot><weekNumber>21</weekNumber><quantity>0</quantity></spot><spot><weekNumber>22</weekNumber><quantity>0</quantity></spot><spot><weekNumber>23</weekNumber><quantity>0</quantity></spot><spot><weekNumber>24</weekNumber><quantity>0</quantity></spot><spot><weekNumber>25</weekNumber><quantity>0</quantity></spot><spot><weekNumber>26</weekNumber><quantity>1</quantity></spot><spot><weekNumber>27</weekNumber><quantity>0</quantity></spot><spot><weekNumber>28</weekNumber><quantity>0</quantity></spot><spot><weekNumber>29</weekNumber><quantity>0</quantity></spot><spot><weekNumber>30</weekNumber><quantity>1</quantity></spot><spot><weekNumber>31</weekNumber><quantity>0</quantity></spot><spot><weekNumber>32</weekNumber><quantity>0</quantity></spot><spot><weekNumber>33</weekNumber><quantity>0</quantity></spot><spot><weekNumber>34</weekNumber><quantity>0</quantity></spot><spot><weekNumber>35</weekNumber><quantity>1</quantity></spot><spot><weekNumber>36</weekNumber><quantity>0</quantity></spot><spot><weekNumber>37</weekNumber><quantity>0</quantity></spot><spot><weekNumber>38</weekNumber><quantity>0</quantity></spot><spot><weekNumber>39</weekNumber><quantity>0</quantity></spot><spot><weekNumber>40</weekNumber><quantity>0</quantity></spot><spot><weekNumber>41</weekNumber><quantity>0</quantity></spot><spot><weekNumber>42</weekNumber><quantity>0</quantity></spot><spot><weekNumber>43</weekNumber><quantity>0</quantity></spot><spot><weekNumber>44</weekNumber><quantity>0</quantity></spot><spot><weekNumber>45</weekNumber><quantity>0</quantity></spot><spot><weekNumber>46</weekNumber><quantity>0</quantity></spot><spot><weekNumber>47</weekNumber><quantity>0</quantity></spot><spot><weekNumber>48</weekNumber><quantity>0</quantity></spot><spot><weekNumber>49</weekNumber><quantity>0</quantity></spot><spot><weekNumber>50</weekNumber><quantity>0</quantity></spot><spot><weekNumber>51</weekNumber><quantity>0</quantity></spot><spot><weekNumber>52</weekNumber><quantity>0</quantity></spot></detailLine></systemOrder></order></campaign></adx>';
            //http://XGBEPAPP01.corp.twcable.com:9090/ws/rest/SpectrumReach/importSCX
           // estimateId = RestServicePostStub(boomiServer + '/importSCX',xmlString);
                Http h = new Http();
                //Instantiate a new HTTP request, specify the method as well as the endpoint
                HttpRequest req = new HttpRequest();
                HttpResponse res ;
                req.setEndpoint(boomiServer + '/importSCX');        
                req.setMethod('POST');
                // req.setHeader('Accept','application/xml');
                req.setHeader('Accept','application/json');
                req.setHeader('Content-type','application/json; charset=UTF-8');
                req.setHeader('Accept-Language', 'en-CA');
                //Set request body
                req.setBody(JSON.serialize(bmH));
                req.setTimeout(webServiceTimeOut);
                BoomiWebServiceMock.name = 'ProposalSCXUpload';
                BoomiWebServiceMock mock = new BoomiWebServiceMock();
                try {
                    if(!Test.isRunningTest()) res = h.send(req);
                    else res =mock.respond(req); 
                }
                catch(System.CalloutException e) {
                    System.debug('Callout error: '+ e);
                    Log4SF.logMessage('BoomiWebServiceHelper', 'importSCX', 'Exception in importSCX API Call: '+req,e, UserInfo.getUserId(),'NA');
                }
                if(res!= null && res.getStatus().equalsIgnoreCase('OK') && res.getStatusCode() == 200) System.debug(string.valueOf(res.getBody()));
                else System.debug(' $$$ Error ::: ' +res.getStatus() + ' $$$ response ::: ' + res); 
                estimateId = res;
            System.debug('$$$ estimateId --- '+estimateId + ' estimateId response ::: ' + estimateId.getBody());
        } 
        catch(Exception e){
            System.debug('Exception---'+e);
            Log4SF.logMessage('BoomiWebServiceHelper', 'importSCX', 'Exception in importSCX'+XMLString,e, UserInfo.getUserId(),'NA');
        }
        
        return estimateId;
    }
    
    /**
     * This method syncs the list of syscodes from TIM.
     * 
     * @param  (none) (NA)
     * @return (String) (Success/Error message)
    */
    public String syncSyscodes(){
      
      List<Syscode__c> syscodeList = new List<Syscode__c>();
      Set<String> syscodeSet = new Set<String>();
      for(TIMIntegration__c t: custSettMap.values()){
        System.debug('Syncing Syscode for: ' + t.name);
        userName = t.UserName__c;
            passwd = t.Password__c;
            userId = Integer.valueOf(t.userId__c);            
            if(passwd ==  null) passwd = '';
            appId = Integer.valueOf(t.AppId__c);
            timServer = t.Endpoint__c;
            boomiServer = t.boomi_Endpoint__c;
            
          StratagTimservice.Login login = new StratagTimservice.Login();        
          HttpResponse syscodeStr = new HttpResponse();
          
          /*gets the TIM access token.*/
          try{ login.User_x = authenticate(); }
          catch(Exception e){ System.debug('e.getException: ' + e.getMessage()); continue; }        
          
          try{
              syscodeStr = RestServiceGetStub(boomiServer + '/entities?entityType=Zone&sessionKey=' + login.User_x);
              SyscodeHelper sch = SyscodeHelper.parse(syscodeStr.getBody());                        
              System.debug('syscodeStrParsed---'+sch);
              
              for(SyscodeHelper.Zone_3_5 s:sch.ZoneList.Zone_3_5){
                if(!syscodeSet.contains(s.SysCode)){
                    syscodeSet.add(s.SysCode);
                    syscodeList.add(new Syscode__c(name=s.SysCode, Description__c=s.Description,market__c=s.MarketID,isActive__c=Boolean.valueOf(s.IsActive),zone__c=s.ZoneID));                    
                }
              }              
          } 
          catch(Exception e){
              System.debug('Exception---'+e + ' ::: line numner ::: ' +e.getLineNumber());
              //Log4SF.logMessage('BoomiWebServiceHelper', 'syncSyscodes', 'Exception in Syscode Sync',e, UserInfo.getUserId(),'NA');
              //return 'Error';
          }
      }
      
      //Insert all syscodes
        if(syscodeList.size() > 0) upsert syscodeList name;
      
        return 'Success';
    }
    
         /**
     * This method maps the Advertiser information
     * 
     * @param  (none) (Advertiser Account, Advertiser TIM ID, Advertiser Agency TIM ID)
     * @return (String) (Success/Error message)
    */
    public BoomiHelper.saveAdvertiser_4_2 mapAccountToAdvertiserBoomi_saveAdvertiser(Account acc, string advTIMId, string agencyTimID){        
        BoomiHelper.saveAdvertiser_4_2 Advertiser = new BoomiHelper.saveAdvertiser_4_2();
        Advertiser.AdvertiserName = acc.Account_Tim_Name__c; 
         string bs1 , bs2 = '';
         if(String.isNotBlank(acc.BillingStreet) )
      { 
        if(acc.BillingStreet.length() > 50)
          {
            bs1 = acc.BillingStreet.substring(0,50);
            bs1 = bs1.substring(0,bs1.lastIndexOf(' '));
            bs2 = acc.BillingStreet.substring(acc.BillingStreet.indexOf(bs1),acc.BillingStreet.length());
          } else { bs1 = acc.BillingStreet;}
      }
        Advertiser.Address1 = bs1;
        Advertiser.Address2 = bs2.length() > 50 ? bs2.substring(0,50):bs2;   
        
        Advertiser.City = acc.BillingCity; 
        Advertiser.IsActive = true;
        Advertiser.Phone = acc.Phone; 
        Advertiser.State = acc.BillingState; 
        Advertiser.ZIP = acc.BillingPostalCode;
        Advertiser.AdvertiserID = integer.valueOf(advTIMId);
        Advertiser.Discount = 0.0;
        
        if(!String.isBlank(agencyTIMId)) Advertiser.AgencyID = Integer.valueOf(agencyTIMId);
        else{ System.debug('AgencyId blank block'); Advertiser.AgencyID = 1; }
        Advertiser.Contact = '';
        Advertiser.ProductId = 0;
        //Advertiser.Commodity = 0;

        List<BoomiHelper.TrafficIDElement> listIDE = new List<BoomiHelper.TrafficIDElement>();
        BoomiHelper.ArrayOfTrafficIDElement arrayOfTraffic = new BoomiHelper.ArrayOfTrafficIDElement();
        BoomiHelper.TrafficIDElement traffic = new BoomiHelper.TrafficIDElement();
        traffic.ExportSystemID = 0;
        listIDE.add(traffic);
        arrayOfTraffic.TrafficIDElement = listIDE;
        Advertiser.TrafficIDs = arrayOfTraffic; 
        return Advertiser;
    }
    
     /**
     * This method syncs any change in the billing address of an Account to Tim.
     * 
     * @param  (none) (NA)
     * @return (String) (Success/Error message)
    */
    public String syncAccountBilling(string endpoint, string accountType, Account acc, string advtimId,string agencyTimId){
        HttpResponse syncAccountStr ;
        //List<Syscode__c> syscodeList = new List<Syscode__c>(); 
        
        try{
            if(accountType=='Advertiser')
            {
                BoomiHelper.saveAdvertiserMaster adv = new BoomiHelper.saveAdvertiserMaster(); 
                BoomiHelper.saveAdvertiserPayload saveAdv = new BoomiHelper.saveAdvertiserPayload();
                saveAdv.User = authenticate();
                
                saveAdv.advertiser = mapAccountToAdvertiserBoomi_saveAdvertiser(acc,advtimId,agencyTimId);
                adv.SaveAdvertiser_3_2 = saveAdv;
                syncAccountStr = RestServicePostStub(boomiServer + '/saveAdvertiser',JSON.serialize(adv));
                System.debug(JSON.serialize(adv));
            }
            else if(accountType=='Agency')
            {
                BoomiHelper.saveAgencyPayload saveAg = new BoomiHelper.saveAgencyPayload();
                saveAg.SessionKey = authenticate();
                //string sessionKey = authenticate();
                integer atimID = integer.valueOf(String.isEmpty(agencyTimId) ? '0':agencyTimId);
                saveAg.Agency = mapAccountToAgencyBoomi_Update(acc,atimID);
                Http h = new Http();
                //Instantiate a new HTTP request, specify the method as well as the endpoint
                HttpRequest req = new HttpRequest();
                HttpResponse res ;
                req.setEndpoint(boomiServer + '/saveAgency');       
                req.setMethod('POST');
                req.setHeader('Accept','application/json');
                req.setHeader('Content-type','application/json; charset=UTF-8');
                req.setHeader('Accept-Language', 'en-CA');
                //Set request body
                req.setBody(JSON.serialize(saveAg));        
                //req.setBody(JSON.serialize('{"SessionKey" :' + JSON.serialize(sessionKey) + ', "agency" :' + JSON.serialize(agency) + '}'));
                System.debug(JSON.serialize(saveAg));
                try {
                    res = h.send(req);
                }
                catch(System.CalloutException e) { System.debug('Callout error: '+ e); }
                if(res.getStatus().equalsIgnoreCase('OK') && res.getStatusCode() == 200) System.debug(res.getBody());
                else System.debug(res.getStatus() + res);
                syncAccountStr = res;
                
            }
            System.debug(syncAccountStr);
        } 
        catch(Exception e){
            System.debug('Exception---'+e);
            return 'Exception';
        }
        
        return 'Success';
    }
    
    /**
     * This method approves/rejects Estimates in TIM
     * 
     * @param  (List<Proposal__c> propList) (Proposal records in Salesforce to be updated)
     * @return
    */
    public Map<String,String> approveProposals(List<Proposal_Zone__c> propList, String comments, Map<String,Group_Status__c> groupStatusMap, String operationtype){
    StratagTimservice.ServiceSoap stub = new StratagTimservice.ServiceSoap();
    StratagTimservice.Login login = new StratagTimservice.Login();
    Map<String,String> retMap = new Map<String,String>();
    
    /*gets the TIM access token.*/
        try{
            login.User_x = authenticateAE();
        }
        catch(Exception e){
             System.debug('approveProposals.getException: ' + e.getMessage());
             retMap.put('Error','Error: '+System.label.BoomiErrorMessage);
             return retMap; 
        }

        login.Password = '';
        stub.Login = login;
        
        //HTTPResponse retStatus = null;
        HTTPResponse retStatus = new HTTPResponse(); 
        List<Proposal_Zone__c> toBeUpdatedProposal = new List<Proposal_Zone__c>();
        Map<String, Proposal_Zone__c> proposalMap = new Map<String, Proposal_Zone__c>();
        BoomiHelper.ProposalApprovalUpdatesRequest bpr = new BoomiHelper.ProposalApprovalUpdatesRequest();
        BoomiHelper.ProposalApprovalUpdates bpu = new BoomiHelper.ProposalApprovalUpdates();
        List<BoomiHelper.ProposalApprovalPayload> bpuList = new List<BoomiHelper.ProposalApprovalPayload>();   
        for(Proposal_Zone__c proposal : propList){
            BoomiHelper.ProposalApprovalPayload bpp = new BoomiHelper.ProposalApprovalPayload();
            bpp.ScheduleStatusUpdated = '1';
            bpp.ESTIMATE_ID = proposal.proposal__r.tim_id__c;
            bpp.UserID = timUserId;
            bpp.SURVEY_ID = proposal.surveyId__c;
            if(operationtype == 'Approve') bpp.StatusID = groupStatusMap.get(proposal.TIM_Status__c).Approval_Status__r.Status_Id__c;
            
            else bpp.StatusID = groupStatusMap.get(proposal.TIM_Status__c).Rejection_Status__r.Status_Id__c;
            
            bpp.FromStatusID = groupStatusMap.get(proposal.TIM_Status__c).Status_Id__c;
            bpp.SysCode = proposal.name;
            bpp.Note = comments;
                        
            bpuList.add(bpp);
            proposalMap.put(proposal.surveyId__c,proposal);         
        }        
        
        bpu.ProposalApprovalUpdate = bpuList;
        bpr.ProposalApprovalUpdates = bpu;
        System.debug(boomiServer + '/proposalApproval');
        try{
            retStatus = RestServicePostStub(boomiServer + '/proposalApproval',JSON.serialize(bpr));
        }
        catch(Exception ex){
            System.debug('Exception in approveProposals API call: ' + ex);
            retMap.put('Error','Error: '+System.label.BoomiErrorMessage);
            Log4SF.logMessage('BoomiWebServiceHelper', 'approveProposals', 'Exception in approveProposals API call: ' + JSON.serialize(bpr),ex, UserInfo.getUserId(),'NA');
            return retMap; 
        }
        
        BoomiHelper.ProposalApprovalResponse par = new BoomiHelper.ProposalApprovalResponse();
        List<BoomiHelper.ProposalApprovalUpdate> result = new List<BoomiHelper.ProposalApprovalUpdate>();
        if(retStatus.getStatusCode()== 200){            
            try{
                System.debug('### retStatus.getBody() ::: ' +retStatus.getBody());
                par = BoomiHelper.parseProposalResponse(retStatus.getBody());
                result = par.ProposalApprovalUpdates.ProposalApprovalUpdate;
            }
            catch(Exception ex){
                System.debug('Exception in approveProposals API response parsing: ' + ex + ' ::: line number ::: ' +ex.getLineNumber());
                retMap.put('Error','Error: '+System.label.BoomiErrorMessage);
                Log4SF.logMessage('BoomiWebServiceHelper', 'approveProposals', 'Exception in approveProposals API response parsing: ' + retStatus.getBody(),ex, UserInfo.getUserId(),'NA');
                return retMap; 
            }
            
            for(BoomiHelper.ProposalApprovalUpdate pa: result){
                if(pa.ResultStatus == 'Success'){
                    Proposal_Zone__c pz = proposalMap.get(String.valueOf(pa.SURVEY_ID));
                    if(operationtype == 'Approve') pz.tim_status__c = groupStatusMap.get(pz.TIM_Status__c).Approval_Status__r.name;
                    
                    else pz.tim_status__c = groupStatusMap.get(pz.TIM_Status__c).Rejection_Status__r.name;
                    
                    toBeUpdatedProposal.add(pz);
                    retMap.put(String.valueOf(pa.syscode),pa.ResultStatus);
                }
                else{
                    retMap.put('Error','TIM Error: '+pa.Message);
                    Log4SF.logMessage('BoomiWebServiceHelper', 'approveProposals', 'TIM Error in approveProposals API: ' + result, UserInfo.getUserId(),'NA');
                }
            }            
        }
        else{ retMap.put('Error','Error: '+System.label.BoomiErrorMessage); return retMap;  }
            
        try{
            if(toBeUpdatedProposal.size() > 0) update toBeUpdatedProposal;
        }
        catch(Exception e){
            System.debug('Exception in approveProposals Proposal Zone updates: ' + e.getMessage());
            Log4SF.logMessage('BoomiWebServiceHelper', 'approveProposals', 'Exception in approveProposals Proposal Zone updates: ' + toBeUpdatedProposal,e, UserInfo.getUserId(),'NA');
        }
        return retMap;
    }

    
     /**
     * This method syncs the current User to the TIM system.
     * 
     * @param  (none) (NA)
     * @return (String) (Success/Error message)
    */
    public HttpResponse syncAeToTim(){
        StratagTimservice.Login login = new StratagTimservice.Login();
        HttpResponse synUserStr ;
        List<Syscode__c> syscodeList = new List<Syscode__c>(); 
        
        /*gets the TIM access token.*/
        try{
            login.User_x = authenticate();
        }
        catch(Exception e){ System.debug('e.getException: ' + e.getMessage()); }        
        
        try{
            synUserStr = RestServiceGetStub(boomiServer + '/entities?entityType=Ae&sessionKey=' + login.User_x);
            //SyscodeHelper sch = SyscodeHelper.parse(syscodeStr.getBody());                        
            System.debug('synUserStrParsed---'+synUserStr);
            //if(syscodeList.size() > 0){
                //upsert syscodeList name;
            //}
        } 
        catch(Exception e){System.debug('Exception---'+e); return null; }
        
        return synUserStr;
    }
   /**
     * This method maps a Salesforce Account to a TIM agency record. 
     * This will be only used for updating an existing account to TIM.
     * 
     * @param  (Account acc) (Account record in Salesforce)
     * @return (BoomiHelper.Agency_4_2) (TIM agency object)
    */
    public BoomiHelper.Agency_4_2 mapAccountToAgencyBoomi_Update(Account acc, integer agencyID){        
        BoomiHelper.Agency_4_2 agency = new BoomiHelper.Agency_4_2();
        agency.AgencyName = acc.Account_Tim_Name__c; 
         string bs1 , bs2 = '';
         if(String.isNotBlank(acc.BillingStreet) )
      { 
        if(acc.BillingStreet.length() > 50)
          {
            bs1 = acc.BillingStreet.substring(0,50);
            bs1 = bs1.substring(0,bs1.lastIndexOf(' '));
            bs2 = acc.BillingStreet.substring(acc.BillingStreet.indexOf(bs1),acc.BillingStreet.length());
          }else{ bs1=acc.BillingStreet; }
      }
        agency.Address1 = bs1;
        agency.Address2 = bs2.length() > 50 ? bs2.substring(0,50):bs2; 
        
        agency.City = acc.BillingCity; 
        agency.IsActive = true;
        agency.Phone = acc.Phone; 
        agency.State = acc.BillingState; 
        agency.ZIP = acc.BillingPostalCode;
        agency.AgencyID = agencyID;
        agency.Discount = 0.0;
        
        return agency;
    } 
    

    /**
     * This method syncs proposal AE changes from TIM to Salesforce
     * 
     * @param  (List<Proposal__c> proList) (Proposal records in Salesforce to be updated)
     * @param  (UserConnection__c oppOwnerUser) (UserConnection record of related Opportunity Owner)     
     * @return (String message) (Status of sync)
    */
    
       public Map<String,Admin_Tool_Status_Detail__c> editProposalAE(List<Proposal__c> proList, UserConnection__c oppOwnerUser,Map<String,Admin_Tool_Status_Detail__c> mapOfAdminStsDet){
        
        Map<String,Id> propsalEstIds = new Map<String,Id>();

        //Query Opportunity Owner's TIM System for proposal sync
        try{
            custSettMap = TIMIntegration__c.getAll();
            System.debug('editProposalAE:custSettMap '+custSettMap);
            System.debug('Opportunity owner tim System::' +oppOwnerUser.TIM_System__c);
            if(custSettMap.containsKey(oppOwnerUser.TIM_System__c))
               boomiServer = custSettMap.get(oppOwnerUser.TIM_System__c).boomi_Endpoint__c;
            System.debug('editProposalAE:boomiServer '+boomiServer);
        }
        catch(Exception ex){
            System.debug('editProposalAcE:Exception in getting Opp Owner TIM settings '+ ex);
            accResponseMap.put('','Error: Exception in getting Opp Owner TIM settings');
            mapOfAdminStsDet = addErrMsgToProposals(proList,mapOfAdminStsDet,'Error: Exception in getting Opp Owner TIM settings'+ex.getMessage()+'::'+ex.getLineNumber() );
            return mapOfAdminStsDet;
        }
        
        StratagTimservice.Login login = new StratagTimservice.Login();
        HttpResponse result = new HttpResponse();
        
        /*gets the TIM access token.*/
        try{
            System.debug('oppOwnerUser.TIM_System__c::'+oppOwnerUser.TIM_System__c);
            //TODO:Add error message handling
            //login.User_x = authenticateAETIMSystem(oppOwnerUser.TIM_System__c);
             login.User_x = authenticateAdminTool(oppOwnerUser);
            System.debug('login.User_x::'+login.User_x);
            if(login.User_x.contains('Error') && !Test.isRunningTest())
             return addErrMsgToProposals(proList,mapOfAdminStsDet,Label.ErrorWhileAuthenticatewithTim);
        }
        catch(Exception e){
            System.debug('editProposalAE:Exception in authenticate: ' + e.getMessage());
            mapOfAdminStsDet = addErrMsgToProposals(proList,mapOfAdminStsDet,Label.ErrorWhileAuthenticatewithTim);
            return mapOfAdminStsDet;
        }
        
        //SavePoint preSyncState = null; 
        SavePoint preSyncState;
        /*EditEstimateHeaders Web service call*/
        try{
            System.debug('result key::::' + login.User_x);
            BoomiHelper.EditEstimateHeaderRequest_Z eehrz = new BoomiHelper.EditEstimateHeaderRequest_Z();
            
            BoomiHelper.EditEstimateHeaderRequest eehr = new BoomiHelper.EditEstimateHeaderRequest();
            BoomiHelper.EditEstimateHeaderList eehl = new BoomiHelper.EditEstimateHeaderList();
            List<BoomiHelper.EditEstimateHeader_5_0> editEstimateHeader = new List<BoomiHelper.EditEstimateHeader_5_0>();
            
            for( Proposal__c prop : proList ){
                BoomiHelper.EditEstimateHeader_5_0 eeh = new BoomiHelper.EditEstimateHeader_5_0();
                String advtsrId = prop.Current_Advertiser_Tim_Id__c!=null? prop.Current_Advertiser_Tim_Id__c : prop.Advertiser__r.TIM_Account_ID__c!=null? prop.Advertiser__r.TIM_Account_ID__c: null;
                if(prop.Tim_ID__c!=null && advtsrId!=null && oppOwnerUser.AE_Id__c!=null){
                   propsalEstIds.put(prop.TIM_Id__c, prop.Id);
                   eeh.EstimateID = prop.Tim_ID__c; 
                   eeh.AdvertiserID = advtsrId; 
                   eeh.AEID = oppOwnerUser.AE_Id__c;
                   eeh.AgencyID = prop.Agency__r.TIM_Account_ID__c!=null? prop.Agency__r.TIM_Account_ID__c : prop.Current_Agency_Tim_Id__c;
                   editEstimateHeader.add(eeh);
                }
                else if(mapOfAdminStsDet.containsKey(prop.Id)){
                  mapOfAdminStsDet.get(prop.Id).Status__c = 'Error';
                  mapOfAdminStsDet.get(prop.Id).Error_Message__c = 'Proposal Id:'+prop.Id+'  Error:';

                  if(prop.Tim_ID__c==null) mapOfAdminStsDet.get(prop.Id).Error_Message__c += ' Tim Id is Required,';
                  if(advtsrId==null) mapOfAdminStsDet.get(prop.Id).Error_Message__c += ' Advertiser Tim Id is Required,';
                  if(oppOwnerUser.AE_Id__c==null) mapOfAdminStsDet.get(prop.Id).Error_Message__c += ' User Connection AE ID is Required';

                  mapOfAdminStsDet.get(prop.Id).Error_Message__c = mapOfAdminStsDet.get(prop.Id).Error_Message__c.removeEnd(',');

                }
            }
            
            if(editEstimateHeader.size()>0){

                eehl.EditEstimateHeader_5_0 = editEstimateHeader;
                eehr.EditEstimateHeaderList = eehl;
                eehrz.EditEstimateHeaderRequest = eehr;
                System.debug('eehr'+eehr);
                System.debug('eehl'+eehl);
                String jsonString =JSON.serialize(eehrz) ;
                system.debug('jsonString'+jsonString);

                //string jsonString = JSON.serializePretty(eehr);

                //

                /*result = RestServiceGetStub(boomiServer + '/estimateHeaders?sessionKey=' + login.User_x + '&estimateId=' + pro.TIM_Id__c);   */         
                result = RestServicePostStub(boomiServer + '/estimateHeaderList?sessionKey=' + login.User_x , JSON.serialize(eehrz)); 
                System.debug('result::::' + result);
                System.debug('result12::::' + result.getBody());            
                
                //Code Added by Abhilash for Admin Tool : 06-04-2018
                BoomiHelper.BoomiHelperCls  esthdr = BoomiHelper.parseEstimateHdrLsttJson(result.getBody());
                System.debug('BoomiHelper.BoomiHelperCls ::::'+esthdr);
               
                if(esthdr!=NULL){
                    if(esthdr.Response==null){
                        if(esthdr.EditHdrResponseList.EditEstimateHeader_5_0Response.size()>0){
                            System.debug('esthdr.EditHdrResponseList.EditEstimateHeader_5_0Response.size()::::::::'+esthdr.EditHdrResponseList.EditEstimateHeader_5_0Response.size());
                            for( BoomiHelper.cls_EditEstimateHeader_5_0Response  estHdrResp : esthdr.EditHdrResponseList.EditEstimateHeader_5_0Response ){
                                Id proposalId = propsalEstIds.get(String.valueOf(estHdrResp.EstimateID));
                                if(estHdrResp.success == 'true'){
                                    if(mapOfAdminStsDet.containsKey(proposalId)) mapOfAdminStsDet.get(proposalId).Status__c = 'Success';
                                    
                                }
                                else if(estHdrResp.errors.error.size()>0){
                                    for(BoomiHelper.cls_Error clsErr : estHdrResp.errors.error){
                                        if(mapOfAdminStsDet.containsKey(proposalId)){
                                          if(clsErr.message.containsIgnoreCase('The Order is deleted')) mapOfAdminStsDet.get(proposalId).Status__c = 'Success';
                                          else mapOfAdminStsDet.get(proposalId).Status__c = 'Error';
                                          
                                          mapOfAdminStsDet.get(proposalId).Error_Message__c = 'Proposal Id:'+proposalId +' Tim id:'+ String.valueOf(estHdrResp.EstimateID) +'  Error::'+ clsErr.message;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else{
                        if(esthdr.Response.success == 'false' && esthdr.Response.error.size()>0){
                            for( BoomiHelper.cls_ResponseError clsResErr : esthdr.Response.error){
                               mapOfAdminStsDet = addErrMsgToProposals(proList,mapOfAdminStsDet,clsResErr.message);
                            }
                        }
                    }

                }                
                preSyncState = Database.setSavePoint();
            }
            return mapOfAdminStsDet;

        }
        catch(Exception e){
            mapOfAdminStsDet = addErrMsgToProposals(proList,mapOfAdminStsDet,Label.ErrorWhileSynchronizewithTim + e.getMessage() );
            return mapOfAdminStsDet;
        }

    }

    public String authenticateAdminTool(UserConnection__c userConn){
        HttpResponse tokenStr ;
        BoomiHelper.SAuthenticate_element request_x = new BoomiHelper.SAuthenticate_element();
        
        //Fetch logged in user's TIM credentials from Org Cache
        try{
                        
            //replace '.'  and space
            String timSystem = userConn.TIM_System__c;
            if(timSystem.indexOf('.') > 0)
            {
              timSystem = timSystem.replace('.','');
              timSystem = timSystem.deleteWhitespace();
            }
            TIMUserAccess.User timuser = CacheManager.getTIMUser(userConn.Username__c+timSystem,timSystem);
            if(Test.isRunningTest()){
                timuser = new TIMUserAccess.User();
                timuser.UID = 2;
                timuser.UN = 'SFDCUser';
                timuser.UP = 'us3th3F0RCE!';
            }
            System.debug('Cache Hit: ' + timuser);
            
            if(timuser!=null){
                if(timUser.UID != null && String.isNotBlank(timUser.UP)){
                    request_x.UserID = timuser.UID;
                    timUserId = String.valueOf(timuser.UID);
                    request_x.UserPassword = timuser.UP;
                }
                else if(System.label.CacheFailSafe == 'true'){ request_x.UserID = UserID; timUserId = String.valueOf(UserID); request_x.UserPassword = passwd; }
            }

        }
        catch(Exception ex){
            System.debug('Error in getting Cache: ' + ex+ex.getLineNumber());
            return 'Error in getting Cache:'+ ex.getMessage();
        }
        
        request_x.AppID = AppID;
        System.debug(boomiServer + '/authenticate' + JSON.serialize(request_x));
        try{
            tokenStr = RestServicePostStub(boomiServer + '/authenticate',JSON.serialize(request_x));
            System.debug('tokenStr---'+tokenStr);
            if(tokenStr.getStatusCode() != 200){
              return System.Label.BoomiAPIError;
            }
        } 
        catch(Exception e){
            System.debug('Exception---'+e);
            Log4SF.logMessage('BoomiWebServiceHelper', 'authenticateAE', 'Exception in TIM API Authentication',e, UserInfo.getUserId(),'NA');
            return System.Label.BoomiAPIError;
        }
        
        String sessionId = '';
        try{
          sessionId = BoomiHelper.parseAuthenticate(tokenStr.getBody()).SAuthenticateResponse.SAuthenticateResult;
          System.debug('@@sessionid '+sessionId);
      }
      catch(Exception ex){
        sessionId = 'Error: ' + BoomiResponse.parse(tokenStr.getBody()).Response.error[0].cause;
          System.debug('@@sessionid '+sessionId);
          Log4SF.logMessage('BoomiWebServiceHelper', 'authenticateAE', 'Exception in TIM API Authentication',ex, UserInfo.getUserId(),'NA',String.valueOf(BoomiResponse.parse(tokenStr.getBody()).Response.metadata));
      }
        
        return sessionId;
    }

    public Map<String,Admin_Tool_Status_Detail__c> addErrMsgToProposals(List<Proposal__c> proList,Map<String,Admin_Tool_Status_Detail__c> mapOfAdminStsDet,String errorMsg){
        for(Proposal__c prop : proList){
            if(mapOfAdminStsDet.containsKey(prop.Id)){
                mapOfAdminStsDet.get(prop.Id).Status__c = 'Error';
                mapOfAdminStsDet.get(prop.Id).Error_Message__c = errorMsg ;
            }
        }
        return mapOfAdminStsDet;
    }

    // Code Changes for SRSF – 1160 – Code Starts
    public String transferOwnership(Proposal__c proposal, UserConnection__c oppOwnerUser){
        
        try{
            custSettMap = TIMIntegration__c.getAll();
            System.debug('editProposalAE:custSettMap '+custSettMap);
            System.debug('Opportunity owner tim System::' +oppOwnerUser.TIM_System__c);
            if(custSettMap.containsKey(oppOwnerUser.TIM_System__c))
               boomiServer = custSettMap.get(oppOwnerUser.TIM_System__c).boomi_Endpoint__c;
            System.debug('editProposalAE:boomiServer '+boomiServer);
        }
        catch(Exception ex){
            System.debug('editProposalAcE:Exception in getting Opp Owner TIM settings '+ ex);
            accResponseMap.put('','Error: Exception in getting Opp Owner TIM settings');
            return 'Error: Exception in getting Opp Owner TIM settings'+ex.getMessage()+'::'+ex.getLineNumber();
        }
        
        StratagTimservice.Login login = new StratagTimservice.Login();
        HttpResponse result = new HttpResponse();
        
        /*gets the TIM access token.*/
        try{
            System.debug('oppOwnerUser.TIM_System__c::'+oppOwnerUser.TIM_System__c);
            login.User_x = authenticateAdminTool(oppOwnerUser);
            System.debug('login.User_x::'+login.User_x);
            if(login.User_x.contains('Error'))
              return Label.ErrorWhileAuthenticatewithTim;
        }
        catch(Exception e){
            System.debug('editProposalAE:Exception in authenticate: ' + e.getMessage());
            return Label.ErrorWhileAuthenticatewithTim +e.getMessage()+'::'+e.getLineNumber();
        }
        
        SavePoint preSyncState;
        try{

            System.debug('result key::::' + login.User_x);
            String timSystem = oppOwnerUser.TIM_System__c;
            if(timSystem.indexOf('.') > 0)
            {
              timSystem = timSystem.replace('.','');
              timSystem = timSystem.deleteWhitespace();
            }
            TIMUserAccess.User timuser = CacheManager.getTIMUser(oppOwnerUser.Username__c+timSystem,timSystem);
            System.debug('TIm user Access:::'+timuser);

            BoomiHelper.TransferOwnership transfrOwnrshp = new BoomiHelper.TransferOwnership();

            BoomiHelper.cls_TransferOwnershipReq transfrOwnrReq = new BoomiHelper.cls_TransferOwnershipReq();
            transfrOwnrReq.EstimateId = proposal.tim_id__c;
            transfrOwnrReq.UserId = timuser!=NULL? String.valueOf(timuser.UID):'';
            transfrOwnrReq.UserName = oppOwnerUser.Username__c;

            if(transfrOwnrReq!=NULL){

                transfrOwnrshp.TransferOwnership = transfrOwnrReq;
                String jsonString =JSON.serialize(transfrOwnrshp) ;
                system.debug('jsonString'+jsonString);

                result = RestServicePostStub(boomiServer + '/assignProposalUser?sessionKey=' + login.User_x , jsonString); 
                System.debug('result::::' + result);
                System.debug('result12::::' + result.getBody());            
                
                BoomiHelper.TransferOwnershipResponse  esthdr = BoomiHelper.parseTransferOwnership(result.getBody());
                System.debug('BoomiHelper.BoomiHelperCls ::::'+esthdr);
               String resultString = '';
                if(esthdr!=NULL){
                    if(esthdr.Response!=null){
                        if(esthdr.Response.success == 'false' && esthdr.Response.error.size()>0){
                            for( BoomiHelper.cls_ResponseError clsResErr : esthdr.Response.error){
                              resultString+= 'Error : '+clsResErr.message +' \n';
                            }
                        }
                    }
                }

                preSyncState = Database.setSavePoint();
                return resultString;
            }
            return 'Error in Request JSON';
        }
        catch(Exception e){
            return Label.ErrorWhileSynchronizewithTim + e.getMessage();
        }

    }

    // Code Changes for SRSF – 1160 – Code Ends  

     public String syncProposal_authenticateAE(UserConnection__c oppOwnerUser)
    {
        StratagTimservice.Login login = new StratagTimservice.Login();
        String respone;
        //Query Opportunity Owner's TIM System for proposal sync
        try{
            custSettMap = TIMIntegration__c.getAll();
            System.debug('syncProposalLineItems:custSettMap '+custSettMap);
            boomiServer = custSettMap.get(oppOwnerUser.TIM_System__c).boomi_Endpoint__c;
            System.debug('syncProposalLineItems:boomiServer '+boomiServer);
        }
        catch(Exception ex){
            System.debug('syncProposalLineItems:Exception in getting Opp Owner TIM settings '+ ex);
            //accResponseMap.put('','Error: Exception in getting Opp Owner TIM settings');
            return 'Error: Exception in getting Opp Owner TIM settings';
        }      

        /*gets the TIM access token.*/
        try{
            System.debug('oppOwnerUser.TIM_System__c::'+oppOwnerUser.TIM_System__c);
            //TODO:Add error message handling
            login.User_x = authenticateAETIMSystem(oppOwnerUser.TIM_System__c);
            System.debug('login.User_x::'+login.User_x);
            respone = boomiServer +'_'+login.User_x ;
        }
        catch(Exception e){
            System.debug('syncProposalLineItems:Exception in authenticate: ' + e.getMessage());
            return Label.ErrorWhileAuthenticatewithTim;
        }
        System.debug('syncProposal_authenticateAE_respone:::'+respone);
        return respone;
    }
    
     public void syncAllProposals(Proposal__c pro, String accessToken, String boomiServer, Map<Id,String> proposalData)
     { 
        
        HttpResponse result = new HttpResponse();
      
        /*EstimateHeaders Web service call*/
        try{
            System.debug('result rpo::::' + pro.TIM_Id__c);
            System.debug('result key::::' + accessToken);
            
            result = RestServiceGetStub(boomiServer + '/estimateHeaders?sessionKey=' + accessToken + '&estimateId=' + pro.TIM_Id__c);            
            
            String responseBody = !Test.isRunningTest() ? result.getBody() : '{ "GetEstimateHeaders_Result" : { "EstimateHeader" : [ { "EstimateID" : 387544, "Description" : "Testing Opportunity Jan09", "AdvertiserID" : 83926, "AgencyID" : 0, "ProductID" : 1203, "FlightStart" : "6/25/2018", "FlightEnd" : "7/29/2018", "Weeks" : 5, "AEID" : 1, "CreatedBy" : "SFDCUser", "Comments" : "Order File Loaded: Electronic SCX Transfer", "EdiClient" : "704134", "EdiProduct" : "6", "EdiEstimate" : "2514", "EdiInvoice" : "true", "ExternalOrderNo" : "A795572A-D2EC-40F9-97EF-BE5D2FAD3690", "BroadcastValues" : { "BroadcastValue" : [ { "YearMonth" : "2018.07", "TotalSpots" : 188, "TotalCost" : 832 } ] }, "Networks" : "BET;BRVO;DISC;FOOD;FRFM;HGTV;HIST;TLC;USA", "NetworkCount" : 9, "Status" : "Proposal", "IsDeleted" : "NotDeleted", "SurveyVersions" : { "SurveyVersion" : [ { "SurveyID" : 611868, "VersionNumber" : 1 } ] }, "ScheduleItems" : { "ScheduleItem_4_6" : [ { "SysCodes" : "2100", "Zones" : "Spectrum/DISH- I+ Huntsville/Decatur, AL, 2100", "Markets" : "Huntsville", "BroadcastValues" : { "BroadcastValue" : [ { "YearMonth" : "2018.07", "TotalSpots" : 188, "TotalCost" : 832 } ] }, "OrderStatus" : "Proposal", "ScheduleType" : "Linear" } ] } } ] } }';
       
            System.debug('result::::' + result);
            System.debug('result12::::' +responseBody);            
            System.debug('EstimateHeaders.result: \n' + BoomiHelper.parseBoomiHelper1(responseBody));
            //Set Proposal data in Map
            proposalData.put(pro.Id, responseBody);
        }
        catch(CalloutException cex){
            System.debug('syncProposalLineItems:CalloutException: ' + cex + cex.getLineNumber());
            proposalData.put(pro.Id, Label.BoomiAPIError);
        }
        catch(Exception e){
            System.debug('syncProposalLineItems:Exception in sync: ' + e + e.getLineNumber());
            proposalData.put(pro.Id, Label.TIMCreate_Sync_ProposalLineItems_Error); 
        }        
    }

    public void updateProposals(Map<Id,String> estHeaderResponseMap, Map<Id, Proposal__c> proposalsMap, UserConnection__c oppOwnerUser)
    {
        System.debug('In updateProposals method - proposalsMap :' + proposalsMap);  
        System.debug('estHeaderResponseMap :' + estHeaderResponseMap);  

        Map<Id, Proposal__c> propToUpdate = new Map<Id, Proposal__c>();
        Map<Id, Map<String, Proposal_Zone__c>> mapZones = new Map<Id, Map<String, Proposal_Zone__c>>(); // No need 
        Map<Id, List<Proposal_Zone__c>> listZones = new Map<Id, List<Proposal_Zone__c>>(); // Sridhar
        Map<Id, List<Proposal_Zone_Monthly_Value__c>> mapZoneValues =  new Map<Id, List<Proposal_Zone_Monthly_Value__c>>();
        try
        {
            // Iterate each proposal and update data
            for (Proposal__c pro : proposalsMap.values()) 
            { 
                String responseBody = estHeaderResponseMap.get(pro.Id); // gets response from estHeaderResponseMap
                System.debug('EstimateHeaders.result: \n' + BoomiHelper.parseBoomiHelper1(responseBody));
            
                BoomiHelper.BoomiHelper1 bhelper =  BoomiHelper.parseBoomiHelper1(responseBody); // parse responseBody
                 
                BoomiHelper.EstimateHeader estHeader=bhelper.GetEstimateHeaders_Result.EstimateHeader[0];
                System.debug('estHeader:'+estHeader);           

                //preSyncState = Database.setSavePoint();
                
                /*Map Estimate info to Proposal record*/            
                pro.name = estHeader.Description;
                pro.description__c = estHeader.Description;
                if(String.isNotEmpty(estHeader.FlightStart))
                pro.Start_Date__c = Date.parse(estHeader.FlightStart);
                if(String.isNotEmpty(estHeader.FlightEnd))
                pro.End_Date__c = Date.parse(estHeader.FlightEnd);
                pro.AE_ID__c = oppOwnerUser.AE_Id__c; 
               
                try{
                    pro.Traffic_Order_Number__c = estHeader.TrafficOrderNumber;
                    pro.TIM_Status__c = estHeader.status;
                }catch(Exception ex){
                    System.debug('Error while setting TrafficOrderNumber/Status data to proposal');
                }
                try{
                    pro.Revenue_Type__c = estHeader.RevenueType.Description;
                }catch(Exception ex){
                    System.debug('Error while setting Revenue Type data to proposal');
                }
                try{            
                    pro.Comments__c = estHeader.Comments;
                }catch(Exception ex){
                    System.debug('Error while setting Comments to proposal');
                }
                try{                
                    pro.Networks__c = estHeader.Networks;
                }catch(Exception ex){
                    System.debug('Error while setting Networks data to proposal');
                }         

                //Code Added by Abhilash  : 24-09-2018
                if( String.isNotBlank(estHeader.IsDeleted) && 
                    estHeader.IsDeleted.equalsIgnoreCase('NotDeleted')) 
                {
                    pro.Active__c  = TRUE;
                } 
                else if (String.isNotBlank(estHeader.IsDeleted) && 
                        (estHeader.IsDeleted.equalsIgnoreCase('Deleted') || 
                         estHeader.IsDeleted.equalsIgnoreCase('NotFound'))) 
                {
                    pro.Active__c  = FALSE;
                }            
                //Code Ends here
                
                //Map Rep Firm/Agency on proposal
                try {               
                    AccountConnection__c acAgency = [SELECT Account__c FROM AccountConnection__c WHERE AgencyTIMId__c =:String.valueOf(estHeader.agencyId) AND tim_system__c =: oppOwnerUser.TIM_System__c AND Account_Record_Type__c IN ('Agency Account','Rep Firm') LIMIT 1];              
                    System.debug('syncProposalLineItems:pro.agency__c '+pro.agency__c);
                    if(estHeader.agencyId != 1 && estHeader.agencyId != 0) 
                        pro.agency__c = acAgency.account__c;
                
                    try{ 
                        AccountConnection__c p = [SELECT Id, AgencyTIMId__c FROM AccountConnection__c WHERE Account__c=: pro.agency__c AND tim_system__c =:oppOwnerUser.TIM_System__c LIMIT 1];
                        if(p.AgencyTIMId__c == '1' || p.AgencyTIMId__c == '0') pro.agency__c = null;
                    }
                    catch(Exception ex){}  
                }
                catch(Exception ex){}  

            propToUpdate.put(pro.Id, pro);          
            //upsert pro; //--- HOW TO HANDLE to roll back for multiple proposals here if             
            mapPZAndPZMVtoProposal(estHeader, pro, mapZones, mapZoneValues); 
            }

            // Update PZMV,PZ and Proposals
            if(propToUpdate.size()>0)
            {
               upsertProposalsPZandPZMVs(propToUpdate, mapZones, mapZoneValues);  
            } 
        }
        catch(CalloutException cex){
            System.debug('syncProposalLineItems:CalloutException: ' + cex + cex.getLineNumber());
            Log4SF.logMessage('BoomiWebServiceHelper', 'syncProposalLineItems', 'CalloutException in syncProposalLineItems',cex, UserInfo.getUserId(),null);
        }
        catch(Exception e){
            System.debug('syncProposalLineItems:Exception in sync: ' + e + e.getLineNumber());
            Log4SF.logMessage('BoomiWebServiceHelper', 'syncProposalLineItems', 'Exception in syncProposalLineItems',e, UserInfo.getUserId(),null);           
        }        
    }
    

    public void mapPZAndPZMVtoProposal(BoomiHelper.EstimateHeader estArray, Proposal__c pro, Map<Id, Map<String, Proposal_Zone__c>> mapZones, Map<Id,List<Proposal_Zone_Monthly_Value__c>> mapZoneValues) 
    {        
        /*Construct database variables*/
        Map<String,Proposal_Zone__c> proposalLineItemsInsertMap = new Map<String,Proposal_Zone__c>();
        List<Proposal_Zone_Monthly_Value__c> proposalLineScheduleInsertList = new List<Proposal_Zone_Monthly_Value__c>(); 
        
        if(estArray != null){
            
            /*Construct processing variables for GetEstimateHeaders result*/
            BoomiHelper.ScheduleItems scheduleItems = estArray.ScheduleItems;
            
            /*if product schedule list is not empty*/
            if(scheduleItems != null){
                
                /*loop though schedule items list and create insert lists for proposal Zones and proposal Monthly Values*/
                Integer i = 0;
                for(BoomiHelper.ScheduleItem_4_6 scheduleItem : scheduleItems.ScheduleItem_4_6)
                {
                    BoomiHelper.BroadcastValues broadcastArray = scheduleItem.BroadcastValues;                    
                    Proposal_Zone__c pLine = new Proposal_Zone__c();
                    Proposal_Zone_Monthly_Value__c pLineSchedule;
                    List<BoomiHelper.SurveyVersion> surveys = estArray.SurveyVersions.SurveyVersion;
                    
                    pLine.name = scheduleItem.SysCodes;                    
                    pLine.Market__c = scheduleItem.Markets;
                    pLine.Proposal__c = pro.Id;
                    pLine.Sys_Code__c = scheduleItem.SysCodes;
                    pLine.Zone__c = scheduleItem.Zones;
                    pLine.TIM_Status__c = scheduleItem.OrderStatus;
                    try{pLine.SurveyId__c = String.valueOf(surveys[i].SurveyID);}catch(Exception ex){System.debug('Exception in SurveryId mapping: '+ex);}                        
                    i++;
                    System.debug('processEstimateHeaderDetailsResponse:scheduleItem.Zones ' + scheduleItem.Zones);
                    
                    if(broadcastArray != null)
                    {
                        for(BoomiHelper.BroadcastValue bv : broadcastArray.BroadcastValue){
                            pLineSchedule = new Proposal_Zone_Monthly_Value__c();
                            System.debug('bv.YearMonth: ' + bv.YearMonth);
                            System.debug('bv.YearMonth: ' + bv.YearMonth.split('\\.',2));
                            System.debug('bv.TotalCost: ' + bv.TotalCost);
                            pLineSchedule.Broadcast_Month_Date__c = Date.parse(bv.YearMonth.split('\\.')[1] + '/15/' + bv.YearMonth.split('\\.')[0]);
                            pLineSchedule.Gross_Amount__c = bv.TotalCost;
                            pLineSchedule.Sys_Code__c = scheduleItem.SysCodes;
                            pLineSchedule.Advertiser__c = pro.Advertiser__c;
                            pLineSchedule.Opportunity__c = pro.Opportunity__c;
                            pLineSchedule.Proposal_Key_Index__c = pro.Id;
                            
                            proposalLineScheduleInsertList.add(pLineSchedule);
                        }
                    }
                    
                    proposalLineItemsInsertMap.put(pro.Id+'_'+scheduleItem.SysCodes,pLine);                    
                }  
            }      
        }
        mapZones.put(pro.Id, proposalLineItemsInsertMap);
        mapZoneValues.put(pro.Id, proposalLineScheduleInsertList);
    }    


    public void upsertProposalsPZandPZMVs(Map<Id, Proposal__c> proposals, 
        Map<Id, Map<String, Proposal_Zone__c>> zonerecs, Map<Id, List<Proposal_Zone_Monthly_Value__c>> zoneValues)
    {

        Map<Id,Id> recIds = new Map<Id,Id>();
        Map<String,Proposal_Zone__c> mapZoneRecs = new Map<String,Proposal_Zone__c>();
        List<Proposal_Zone_Monthly_Value__c> lstZoneValRecs = new List<Proposal_Zone_Monthly_Value__c>();
        List<Proposal_Zone__c> zonesLst = new List<Proposal_Zone__c>();
        Set<Id> deleteNewZones = new Set<Id>();
        // Query to get all existing zone records from proposal to delete later
        List<Proposal_Zone__c> proposalZoneToDelete = [Select id from Proposal_Zone__c where proposal__c =: proposals.keySet()];
        System.debug('Existing Zones for deletion-->'+proposalZoneToDelete);
        // Creating all the zones and Zone values
        if(zonerecs.size() > 0 )
        {   
            List<Map<String,Proposal_Zone__c>> lstZoneRecs = zonerecs.values();
            for(Map<String,Proposal_Zone__c> rec : lstZoneRecs)
            {
                mapZoneRecs.putAll(rec);
            }
            for(Proposal_Zone__c eachZone : mapZoneRecs.values())
            {
                zonesLst.add(eachZone);
            }           

            Database.SaveResult[] srZoneList = Database.insert(zonesLst, false);
            for(Integer i=0;i<srZoneList.size();i++)
            {               
                System.debug('zonesLst.get(i) :::'+zonesLst.get(i));
                if (!srZoneList.get(i).isSuccess()) // DML operation failed
                {
                    Database.Error error = srZoneList.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    System.debug('Failed Proposal ID-->'+zonesLst.get(i).Proposal__c);
                    //Capturing failed zones proposals to recIds
                    recIds.put(zonesLst.get(i).Proposal__c,zonesLst.get(i).Proposal__c);
                }
            }
        }
        System.debug('Zone records failed for proposals-->'+recIds);

        if(zoneValues.size() > 0 )
        {
            for(List<Proposal_Zone_Monthly_Value__c> recs : zoneValues.values())
            {
                for(Proposal_Zone_Monthly_Value__c rec : recs ) 
                {
                    //If zone cretaion failed then Id value is null here, so zonevalue recs without Zone are not available for insertion
                    if(mapZoneRecs.get(rec.Proposal_Key_Index__c+'_'+rec.Sys_Code__c).Id != NULL ) 
                    {
                        rec.Proposal_Zone__c = mapZoneRecs.get(rec.Proposal_Key_Index__c+'_'+rec.Sys_Code__c).Id;
                        lstZoneValRecs.add(rec);
                    }
                }
            }
            
           Database.SaveResult[] srList = Database.insert(lstZoneValRecs, false);
           for(Integer i=0;i<srList.size();i++)
           {                
                System.debug('lstZoneValRecs.get(i) :::'+lstZoneValRecs.get(i));
                if (!srList.get(i).isSuccess()) // DML operation failed
                {
                    Database.Error error = srList.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    System.debug('Failed proposal ID'+lstZoneValRecs.get(i).Proposal_Key_Index__c);
                    recIds.put(lstZoneValRecs.get(i).Proposal_Key_Index__c,lstZoneValRecs.get(i).Proposal_Key_Index__c);
                    deleteNewZones.add(lstZoneValRecs.get(i).Proposal_Zone__c);
                }
            }
        }
        System.debug('deleteNewZones-->'+deleteNewZones);
        System.debug('Zone value records failed for proposals-->'+recIds);
        System.debug('before removing proposals-->'+proposals);
        if(recIds.size() > 0)
        {
            proposals.keySet().removeAll(recIds.keyset());
        }
        if(proposals.size()>0){
            update proposals.values();
        }
        System.debug('after removing proposals-->'+proposals);
        // Remove Newly created Zones if ZoneValue creation fails
        if(deleteNewZones.size()>0)
        {
            List<Proposal_Zone__c> deleteZoneRecs = [Select Id FROM Proposal_Zone__c WHERE Id IN :deleteNewZones ];
            System.debug('Newly created Zones for deletion-->'+deleteZoneRecs);
            proposalZoneToDelete.addAll(deleteZoneRecs);  
        }
        System.debug('Before deleting proposalZoneToDelete-->'+proposalZoneToDelete);
        //delete existing and new zones failed while creation
        delete proposalZoneToDelete;
        // Remove Data from Recycle bin also
        if(proposalZoneToDelete.size()>0)
            Database.emptyRecycleBin(proposalZoneToDelete);
    }
}