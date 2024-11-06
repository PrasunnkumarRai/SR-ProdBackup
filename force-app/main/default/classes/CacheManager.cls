/*
###########################################################################
# File..................: CacheManager.cls
# Version...............: 1
# Created by............: Sanchit Singhal   
# Created Date..........: 10-June-2017
# Description...........: This class contains helper methods for managing TIM User Org Cache Partition
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/
public with sharing class CacheManager {
    
    /**
     * This method returns the size of cache from TIM User org cache partition
     * 
     * @param  (none) (NA)
     * @return (Integer) (Cache Size)
    */
    public static Integer checkCacheSize(string timSystem){
        
        //Fetch user's TIM credentials from Org Cache
        if(timSystem.indexOf('.') > 0)
            {
                timSystem = timSystem.replace('.','');
                timSystem = timSystem.deleteWhitespace();
            }
            Map<String,TIMUserAccess.User> timuserMap = new Map<String,TIMUserAccess.User>();
            if(Cache.Org.get('local.TIMAccess.'+timSystem) != null){
                timUserMap = (Map<String,TIMUserAccess.User>) Cache.Org.get('local.TIMAccess.'+timSystem);
            }

        return timuserMap.size();
    }
    
    /**
     * This method returns the TIM User credentials from cache based on a userkey
     * 
     * @param  (String) (userKey)
     * @return (TIMUserAccess.User) (credentials of TIM user)
    */ 
    public static TIMUserAccess.User getTIMUser(String userKey, string timSystem){
        
        //Fetch user's TIM credentials from Org Cache
        Map<String,TIMUserAccess.User> timuserMap = new Map<String,TIMUserAccess.User>();
        if(timSystem.indexOf('.') > 0)
            {
                timSystem = timSystem.replace('.','');
                timSystem = timSystem.deleteWhitespace();
            }
        timUserMap = (Map<String,TIMUserAccess.User>) Cache.Org.get('local.TIMAccess.'+timSystem);        
        System.debug('Cache Key: ' + userKey.toUpperCase());
        TIMUserAccess.User tua = new TIMUserAccess.User();
        if(timUserMap != null){
            tua = timUserMap.get(userKey.toUpperCase());
            System.debug('Cache Hit: ' + tua);
        }
        
        return tua;
    }
    
    /**
     * This method refreshes the TIMUser cache using remote Boomi process invocation for loggedIn Users Primary TIM Instance
     * 
     * @param  (none) (none)
     * @return (void) (NA)
    */ 
    @future(callout=true)
    public static void refreshCache(){
        
        String boomiAtomId = System.label.BoomiCacheAtomId;
        
        try{
            UserConnection__c loggedInUser = [Select AE_Id__c, TIM_System__c, Username__c
                                              from UserConnection__c
                                              where User__c=: UserInfo.getUserId() and Is_Primary__c = true limit 1];
            System.debug('@@loggedInUser '+loggedInUser);
            
            Map<String,TIMIntegration__c> custSettMap = new Map<String,TIMIntegration__c>();
            custSettMap = TIMIntegration__c.getAll();
            System.debug('@@custSettMap '+custSettMap);
            boomiAtomId = custSettMap.get(loggedInUser.TIM_System__c).boomiAtomId__c;
        }
        catch(Exception e) {
            System.debug('refreshCache loggedInUser error: '+ e);
        }
        
        // Instantiate a new http object
        Http h = new Http();
        // Instantiate a new HTTP request, specify the method (POST) as well as the endpoint
        HttpRequest req = new HttpRequest();
        HttpResponse res ;
        req.setEndpoint('callout:Boomi/executeProcess');
        req.setMethod('POST');
        req.setHeader('Content-type','application/xml; charset=UTF-8');
        req.setTimeout(120000);
        //Set request format
        String reqBody = '<ProcessExecutionRequest processId="'+ System.label.BoomiCacheProcessId +'" atomId="'+ boomiAtomId +'" xmlns="http://api.platform.boomi.com/"></ProcessExecutionRequest>';
        req.setBody(reqBody);
        try {
            res = h.send(req);
        }
        catch(System.CalloutException e) {
            System.debug('refreshCache Callout error: '+ e + e.getLineNumber());
        }
        
    }
    
    /**
     * This method refreshes the TIMUser cache using remote Boomi process invocation for all TIM Instances
     * 
     * @param  (none) (none)
     * @return (void) (NA)
    */
    public static void refreshAllCache(){
        
        String boomiAtomId = '';
        
        try{
            Map<String,TIMIntegration__c> custSettMap = new Map<String,TIMIntegration__c>();           
            Set<String> timSystems = new Set<String>(); //SRSF-2414

            custSettMap = TIMIntegration__c.getAll();
            System.debug('@@custSettMap '+custSettMap);
            
            for(TIMIntegration__c ti: custSettMap.values()){
                if(String.isNotBlank(ti.boomiAtomId__c)){
                    if(ti.CacheUnderRefresh__c == false){                       
                        /* SRSF-2414:Commented DML and future method call inside for loop
                        ti.CacheUnderRefresh__c = true;                        
                        update ti; 
                        callRefreshService(ti.name);
                        */                 
                        timSystems.add(ti.name);                        
                    }    
                }
            }
            System.debug('timSystems>>'+timSystems);           
            //START : SRSF-2414
            if(timSystems.size() >0 )
            {           
                callCacheRefreshService(timSystems);
            }
            //END: SRSF-2414
        }
        catch(Exception e) {
            System.debug('refreshAllCache error: '+ e + e.getLineNumber());
        }        
    }
    

    /**
     * SRSF-2414
     * This method refreshes the TIMUser cache using remote Boomi process invocation for TIM Instances
     * */
    
     @future(callout=true)
    public static void callCacheRefreshService(Set<String> timSystems)
    {   
        try{
            Map<String,TIMIntegration__c> custSettMap = new Map<String,TIMIntegration__c>();
            List<TIMIntegration__c> updateCustSettList = new List<TIMIntegration__c>();
            custSettMap = TIMIntegration__c.getAll();
            System.debug('@@custSettMap '+custSettMap);  
            for(String timSystemName : timSystems)   
            {    
                String boomiAtomId = '';
                TIMIntegration__c ti = custSettMap.get(timSystemName);
            
                if(String.isNotBlank(ti.boomiAtomId__c))
                {
                    boomiAtomId = ti.boomiAtomId__c;                
                    System.debug('TIM System: '+ti.name);        
                    // Instantiate a new http object
                    Http h = new Http();
                    // Instantiate a new HTTP request, specify the method (POST) as well as the endpoint
                    HttpRequest req = new HttpRequest();
                    HttpResponse res ;
                    req.setEndpoint('callout:Boomi/executeProcess');
                    req.setMethod('POST');
                    req.setHeader('Content-type','application/xml; charset=UTF-8');
                    req.setTimeout(120000);
                    //Set request format
                    String reqBody = '<ProcessExecutionRequest processId="'+ System.label.BoomiCacheProcessId +'" atomId="'+ boomiAtomId +'" xmlns="http://api.platform.boomi.com/"></ProcessExecutionRequest>';
                    req.setBody(reqBody);
                    try {
                        res = h.send(req);
                        if(res!=NULL && res.getStatusCode()==200) 
                        {
                            ti.CacheUnderRefresh__c = true;
                            updateCustSettList.add(ti);
                        }    
                    }
                    catch(System.CalloutException e) {
                        System.debug('refreshSingleCache Callout error: '+ e);
                    }
                }  
            }
            if(updateCustSettList.size() >0 ) { 
                update updateCustSettList; 
            }           
        }
        catch(Exception e) 
        {
            System.debug('refresh Cache error: '+ e + e.getLineNumber());
        }        
    }
    

    /**
     * This method refreshes the TIMUser cache using remote Boomi process invocation for a specific TIM Instance
     * 
     * @param  (none) (none)
     * @return (void) (NA)
    */
    public static void refreshTIMCache(String timSystemName){
        
        String boomiAtomId = '';
        Set<String> timSystems = new Set<String>(); //SRSF-2414
        try{
            Map<String,TIMIntegration__c> custSettMap = new Map<String,TIMIntegration__c>();
            custSettMap = TIMIntegration__c.getAll();
            System.debug('@@custSettMap '+custSettMap);
            
            TIMIntegration__c ti = custSettMap.get(timSystemName);
            if(ti.CacheUnderRefresh__c == false){
                /*ti.CacheUnderRefresh__c = true;
                update ti;
                callRefreshService(timSystemName);*/
                timSystems.add(timSystemName);
                callCacheRefreshService(timSystems);
            }           
        }
        catch(Exception e) {
            System.debug('refreshTIMCache error: '+ e + e.getLineNumber());
        }        
    }
    
    /**
     * This method refreshes the TIMUser cache using remote Boomi process invocation for a specific TIM Instance
     * 
     * @param  (none) (none)
     * @return (void) (NA)
    */ 

    /* Commented for SRSF-2414
    @future(callout=true)
    public static void callRefreshService(String timSystemName){
        
        String boomiAtomId = '';
        
        try{
            Map<String,TIMIntegration__c> custSettMap = new Map<String,TIMIntegration__c>();
            custSettMap = TIMIntegration__c.getAll();
            System.debug('@@custSettMap '+custSettMap);         
            TIMIntegration__c ti = custSettMap.get(timSystemName);
            
            if(String.isNotBlank(ti.boomiAtomId__c)){
                boomiAtomId = ti.boomiAtomId__c;                
                System.debug('TIM System: '+ti.name);        
                // Instantiate a new http object
                Http h = new Http();
                // Instantiate a new HTTP request, specify the method (POST) as well as the endpoint
                HttpRequest req = new HttpRequest();
                HttpResponse res ;
                req.setEndpoint('callout:Boomi/executeProcess');
                req.setMethod('POST');
                req.setHeader('Content-type','application/xml; charset=UTF-8');
                req.setTimeout(120000);
                //Set request format
                String reqBody = '<ProcessExecutionRequest processId="'+ System.label.BoomiCacheProcessId +'" atomId="'+ boomiAtomId +'" xmlns="http://api.platform.boomi.com/"></ProcessExecutionRequest>';
                req.setBody(reqBody);
                try {
                    res = h.send(req);
                }
                catch(System.CalloutException e) {
                    System.debug('refreshSingleCache Callout error: '+ e);
                }
            }           
        }
        catch(Exception e) {
            System.debug('refreshSingleCache error: '+ e + e.getLineNumber());
        }
        
    }*/
    
}