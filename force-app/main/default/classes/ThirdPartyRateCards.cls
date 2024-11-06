@RestResource(urlMapping='/SpectrumReachRateCard/*')
global with sharing class ThirdPartyRateCards {

    @HttpGet
    global static String doGet() {
        return 'SpectrumReachRateCard API is Alive!';
    }

    @HttpPost
    global static RateCardResponseWrapper doPost(String userID, String syscode, String source) {
        System.debug(' ### userID ::: ' +userID);
        System.debug(' ### syscode ::: ' +syscode);
        System.debug(' ### source ::: ' +source);
        Map<String,Object> mapOfThirdPartyLog = new Map<String, Object>{'User__c' =>userID,'API_Name__c' => 'SpectrumReachRateCard','Source__c' => source };

        Third_Party_Logger__c thirdPartyLogger = Log4SF.createThirdPartyLogger(mapOfThirdPartyLog,false , new Third_Party_Logger__c());
        RateCardResponseWrapper response = new RateCardResponseWrapper();

        User user = new User();
        user blankUser = new User();
        UserConnection__c userCon = new UserConnection__c();
        Map<String,String> rcToSyscodeMap = new Map<String,String>();

        try{
            user = [SELECT Id, Name FROM User WHERE Id =:userID AND isActive = true LIMIT 1];
            System.debug('@@@ user ::: ' +user);
        }
        catch(Exception ex){
            System.debug(' ### exception :::: ' +ex.getMessage() + ' ### Line number ::: ' +ex.getLineNumber());
            String errMesg = String.format(System.Label.UserID_Not_esist, new List<String> {userID});
            thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure', 'Error_Message__c' =>errMesg} ,TRUE ,thirdPartyLogger);
            return new RateCardResponseWrapper(false, errMesg, null);
        }

        if(user == blankUser){
            String errMesg = String.format(System.Label.UserID_Not_esist, new List<String> {userID});
            thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure', 'Error_Message__c' =>errMesg} ,TRUE ,thirdPartyLogger);
            return new RateCardResponseWrapper(false, errMesg, null);
        }else if(String.isBlank(syscode)) {
            System.debug(' $$$ Syscode is null ::: ');
            return new RateCardResponseWrapper(false, Label.Syscode_Error, null);
        }
        else {
            String timSystem = '';
            try {
                userCon = [SELECT AE_Id__c, TIM_System__c, Username__c, User__r.name FROM UserConnection__c WHERE User__c =:userID AND AE_Id__c != null AND Is_Primary__c = true LIMIT 1];
                timSystem = userCon.TIM_System__c;
            }
            catch(Exception ex) {
                System.debug(' $$$ error in primary user connection ::: ' +ex.getMessage() + ' $$$$ Line number :::: ' +ex.getLineNumber());
                return new RateCardResponseWrapper(false, Label.No_Primary_UserConnection, null);
            }

            try{
                System.debug(CacheManager.checkCacheSize(timSystem));
                if(CacheManager.checkCacheSize(timSystem) <=0){
                    if(Label.CacheAutoRefresh=='true'){
                        CacheManager.refreshTIMCache(timSystem);
                    }
                    Log4SF.logMessage('SpectrumReachRateCard', 'doPost', 'Refreshed All Cache' , userId, null);
                    return new RateCardResponseWrapper(false, Label.Cache_Refresh_Error, null);
                }
            }
            catch(Exception ex){
                System.debug('refreshCache Callout error: '+ ex.getMessage());
                return new RateCardResponseWrapper(false, 'refreshCache Callout error: ' + ex.getMessage(), null);
            }

           List<RateCard__c> rateCards = [SELECT Id,RateCard_Id__c, Name,Syscode__c FROM RateCard__c WHERE TIM_System__c =:timSystem AND Active__c=TRUE];
            if(rateCards.size()>0){
                for(RateCard__c rc: rateCards){
                    if(rc.Syscode__c.contains(syscode)) {
                        rcToSyscodeMap.put(rc.RateCard_Id__c,rc.Name);
                    }
                }
            }else{
                 System.debug(' $$$ No Active Rate cards found for TIM System ::: '+syscode);
                 response = new RateCardResponseWrapper(false, Label.RateCards_Not_Found+' for Syscode :'+syscode, null);
            }

            if(rcToSyscodeMap.size()>0){
                List<RateCards> rcList = new List<RateCards>();
                for(String rateCard : rcToSyscodeMap.keySet()){
                    rcList.add(new RateCards(rateCard,rcToSyscodeMap.get(rateCard)));
                }
                response = new RateCardResponseWrapper(true, 'Success', rcList);
            } 
            else{
                 System.debug(' $$$ Not found Rate cards for Syscode ::: '+timSystem);
                response = new RateCardResponseWrapper(false, Label.RateCards_Not_Found+' for Syscode :'+syscode, null);
            }           
        }
        return response;
    }

    global class RateCardResponseWrapper {
        global boolean isSuccess;
        global String message;
        global List<RateCards> rateCards;

        global RateCardResponseWrapper(){}

        global RateCardResponseWrapper(boolean success, String msg, List<RateCards> resultList) {
            isSuccess = success;
            message = msg;
            rateCards = resultList;
        }
    }

    global class RateCards {
        global String Id;
        global String Name;

        global RateCards(){}

        global RateCards(String ratecardId, String ratecardName) {
            Id = ratecardId;
            Name = ratecardName;
        }
    }


}