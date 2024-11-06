@RestResource(urlMapping='/TIMUserAccess/*')
global with sharing class TIMUserAccess{
    
    @HttpGet
    global static String doGet() {
        return 'SpectrumReachTIMUserAccess API is Alive!';
    }
    
    @HttpPost
    global static String doPost() {     
        
        Map<String,User> timuserMap = new Map<String,User>();
        RestRequest req = RestContext.request;
        String timSystem = req.params.get('TIMSystem');
        String timSystemUntrimmed = req.params.get('TIMSystem');
        System.debug('timSystem: ' + timSystem); 
        if(timSystem.indexOf('.') > 0)
            {
            	timSystem = timSystem.replace('.','');
            	timSystem = timSystem.deleteWhitespace();
            }
        System.debug('timSystem: ' + timSystem);        
        
        try{
            if(CacheManager.checkCacheSize(timSystem) > 0){
                timUserMap = (Map<String,TIMUserAccess.User>) Cache.Org.get('local.TIMAccess.'+timSystem);
            }
        }
        catch(Exception ex){
        	Log4SF.logMessage('TIMUserAccess', 'doPost', 'Exception in getCache: ',ex, UserInfo.getUserId(),'NA');
            return 'getCacheError: ' + ex;
        }
            
        try{
            for(User tu: parse(req.requestBody.toString()).UserList.User){
            	String userKey = String.valueOf(tu.UN)+timSystem; 
                timuserMap.put(userKey.toUpperCase(),tu);        
            }
            Cache.Org.put('local.TIMAccess.'+timSystem, timuserMap,172800);
            
            //Reset Cache Refresh flag
            Map<String,TIMIntegration__c> custSettMap = new Map<String,TIMIntegration__c>();
	        custSettMap = TIMIntegration__c.getAll();
            TIMIntegration__c ti = custSettMap.get(timSystemUntrimmed);
            ti.CacheUnderRefresh__c = false;
	        update ti;
        }
        catch(Exception ex){
        	Log4SF.logMessage('TIMUserAccess', 'doPost', 'Exception in putCache: ',ex, UserInfo.getUserId(),'NA');
            return 'Error: ' + ex;
        }
        
        return 'Success: '+timuserMap.size();
    }
    
    global class TIMUsers {
        global UserList UserList;
    }

    global class User {
        global Integer UID;
        global String UN;
        global String UP;
        //global String ADUser;
    }

    global class UserList {
        global List<User> User;
    }

    
    global static TIMUsers parse(String json) {
        return (TIMUsers) System.JSON.deserialize(json, TIMUsers.class);
    }
}