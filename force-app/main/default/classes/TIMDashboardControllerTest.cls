@isTest
public with sharing class TIMDashboardControllerTest {
    
    @IsTest(seeAlldata = false)
    static void getTimURLMethodPositivePathTest() {
        
        User u = TestDataHelper.getBoomiIntegrationUser();

        System.assert(u != null);
        
        System.debug('@@u Name '+u.Name);
        
        System.runAs(u){
	        TestDataHelper.createTIMIntegrationCustomSettings();
	        insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
	        
	        UserConnection__c loggedInUser = [Select AE_Id__c, TIM_System__c, Username__c
                            from UserConnection__c
                            where User__c=: UserInfo.getUserId() and TIM_System__c ='St. Louis Local' limit 1];
	        String timSystem = 'StLouisLocal';
	        String partitionName = 'local.TIMAccess';
	        Cache.OrgPartition newpart = new Cache.OrgPartition(partitionName);

	        Map<String,TIMUserAccess.User> timuserMap = new Map<String,TIMUserAccess.User>();

	        timuserMap.put('St. Louis Local', CacheManager.getTIMUser(loggedInUser.Username__c+timSystem,timSystem));

	        newpart.put('StLouisLocal', timuserMap);
        
	        TIMDashboardController cp = new TIMDashboardController();
	        
	        Test.StartTest();	            
	        	cp.getTimURL();
	        Test.StopTest();
        }
    }

    @IsTest(seeAlldata = false)
    static void noCacheTest() {
        
        User u = TestDataHelper.getBoomiIntegrationUser();

        System.assert(u != null);
        
        System.debug('@@u Name '+u.Name);
        
        System.runAs(u){
	        TestDataHelper.createTIMIntegrationCustomSettings();
	        insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
	        
	        TIMDashboardController cp = new TIMDashboardController();
	        
	        Test.StartTest();	            
	        	cp.getTimURL();
	        Test.StopTest();
        }
    }
}