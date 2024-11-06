@isTest
private class ThirdPartyRateCardsTest {
   @testSetup    
    static void prepareTestData() {
        User u = TestDataHelper.createUser(true);
        u.isActive = true;
        update u;
        System.assert(u != null);        
 
        UserConnection__c userConn = TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
        insert userConn;    

        List<Ratecard__c> rcList = new List<Ratecard__c>();
        Ratecard__c rc1 = new Ratecard__c(RateCard_Id__c ='123',Name='RateCard 1',Syscode__c='123|3456|6789',TIM_System__c ='St. Louis Local',Active__c=TRUE,RateCardExternalId__c ='123 St. Louis Local');
        rcList.add(rc1);
        Ratecard__c rc2 = new Ratecard__c(RateCard_Id__c ='124',Name='RateCard 2',Syscode__c='4566|6789',TIM_System__c ='St. Louis Local',Active__c=TRUE,RateCardExternalId__c ='124 St. Louis Local');
        rcList.add(rc2);
        insert rcList;
    }

     static testMethod void doGetMethodPositivePathTest() {
        String response = ThirdPartyRateCards.doGet();
        System.assert(response != null);
    }

    static testMethod void doPostMethodPositivePathTest1() {

        User u = [SELECT Id, Name FROM User WHERE isActive = true LIMIT 1];
        System.assert(u != null);

        UserConnection__c loggedInUser = [SELECT AE_Id__c, TIM_System__c, Username__c
                            FROM UserConnection__c
                            WHERE User__c=: UserInfo.getUserId() AND TIM_System__c ='St. Louis Local' LIMIT 1];
       
        String timSystem = 'StLouisLocal';
        String partitionName = 'local.TIMAccess';
        Cache.OrgPartition newpart = new Cache.OrgPartition(partitionName);
        Map<String,TIMUserAccess.User> timuserMap = new Map<String,TIMUserAccess.User>();
        timuserMap.put('St. Louis Local', CacheManager.getTIMUser(loggedInUser.Username__c+timSystem,timSystem));
        newpart.put('StLouisLocal', timuserMap);

        ThirdPartyRateCards.RateCardResponseWrapper response = ThirdPartyRateCards.doPost(String.valueOf(UserInfo.getUserId()), '6789', null);

        System.assert(response != null);
    }

    static testMethod void doPostMethodNegativePathTest1() {

        User u = [SELECT Id, Name FROM User WHERE isActive = true LIMIT 1];
        System.assert(u != null);

        ThirdPartyRateCards.RateCardResponseWrapper response = ThirdPartyRateCards.doPost(String.valueOf(UserInfo.getUserId()), '6789', null);
        System.assert(response != null);
    }

    static testMethod void doPostMethodNegativePathTest2() {

        User u = [SELECT Id, Name FROM User WHERE isActive = true LIMIT 1];
        System.assert(u != null);

        UserConnection__c loggedInUser = [SELECT AE_Id__c, TIM_System__c, Username__c
                            FROM UserConnection__c
                            WHERE User__c=: UserInfo.getUserId() AND TIM_System__c ='St. Louis Local' LIMIT 1];
       
        String timSystem = 'StLouisLocal';
        String partitionName = 'local.TIMAccess';
        Cache.OrgPartition newpart = new Cache.OrgPartition(partitionName);
        Map<String,TIMUserAccess.User> timuserMap = new Map<String,TIMUserAccess.User>();
        timuserMap.put('St. Louis Local', CacheManager.getTIMUser(loggedInUser.Username__c+timSystem,timSystem));
        newpart.put('StLouisLocal', timuserMap);

        ThirdPartyRateCards.RateCardResponseWrapper response = ThirdPartyRateCards.doPost(String.valueOf(UserInfo.getUserId()), '999', null);

        System.assert(response != null);
    }

     static testMethod void doPostMethodNegativePathTest3() {

        User u = [SELECT Id, Name FROM User WHERE isActive = true LIMIT 1];
        System.assert(u != null);

        UserConnection__c loggedInUser = [SELECT AE_Id__c, TIM_System__c, Username__c
                            FROM UserConnection__c
                            WHERE User__c=: UserInfo.getUserId() AND TIM_System__c ='St. Louis Local' LIMIT 1];
       
        String timSystem = 'StLouisLocal';
        String partitionName = 'local.TIMAccess';
        Cache.OrgPartition newpart = new Cache.OrgPartition(partitionName);
        Map<String,TIMUserAccess.User> timuserMap = new Map<String,TIMUserAccess.User>();
        timuserMap.put('St. Louis Local', CacheManager.getTIMUser(loggedInUser.Username__c+timSystem,timSystem));
        newpart.put('StLouisLocal', timuserMap);

        ThirdPartyRateCards.RateCardResponseWrapper response = ThirdPartyRateCards.doPost(String.valueOf(UserInfo.getUserId()), '', null);

        System.assert(response != null);
    }

    static testMethod void doPostMethodNegativePathTest4() {

        List<Ratecard__c> rcList = [SELECT Id, Name, TIM_System__c FROM Ratecard__c LIMIT 2];
        rcList.get(0).TIM_System__c = 'Dallas';
        rcList.get(1).TIM_System__c = 'Dallas';
        update rcList;

        UserConnection__c loggedInUser = [SELECT AE_Id__c, TIM_System__c, Username__c
                            FROM UserConnection__c
                            WHERE User__c=: UserInfo.getUserId() AND TIM_System__c ='St. Louis Local' LIMIT 1];
       
        String timSystem = 'StLouisLocal';
        String partitionName = 'local.TIMAccess';
        Cache.OrgPartition newpart = new Cache.OrgPartition(partitionName);
        Map<String,TIMUserAccess.User> timuserMap = new Map<String,TIMUserAccess.User>();
        timuserMap.put('St. Louis Local', CacheManager.getTIMUser(loggedInUser.Username__c+timSystem,timSystem));
        newpart.put('StLouisLocal', timuserMap);

        ThirdPartyRateCards.RateCardResponseWrapper response = ThirdPartyRateCards.doPost(String.valueOf(UserInfo.getUserId()), '6789', null);

        System.assert(response != null);
    }

    static testMethod void doPostMethodNegativePathTest5() {

        ThirdPartyRateCards.RateCardResponseWrapper response = ThirdPartyRateCards.doPost(null, '6789', null);
        System.assert(response != null);
    }

     static testMethod void doPostMethodNegativePathTest6() {

        UserConnection__c loggedInUser = [SELECT AE_Id__c, TIM_System__c, Username__c
                            FROM UserConnection__c
                            WHERE User__c=: UserInfo.getUserId() AND TIM_System__c ='St. Louis Local' LIMIT 1];
       
        loggedInUser.Is_Primary__c = false;
        update loggedInUser;
        ThirdPartyRateCards.RateCardResponseWrapper response = ThirdPartyRateCards.doPost(String.valueOf(UserInfo.getUserId()), '6789', null);

        System.assert(response != null);
    }
}