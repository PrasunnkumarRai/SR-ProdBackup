@isTest
public with sharing class Log4SFTest {
	
	@IsTest(seeAlldata = false)
    static void logMessageInfoTest() {
		Log4SF.logMessage('DevConsole', 'ExecuteAnonymous', 'Test No Exception logging' , UserInfo.getUserId(), 'NA');
        List<Logger__c> loggers = [SELECT id, name, Class__c FROM Logger__c WHERE Class__c = 'DevConsole'];
        System.assert(loggers.size() > 0);
    }
    
    @IsTest(seeAlldata = false)
    static void logMessageDataTest() {
		Log4SF.logMessage('DevConsole', 'ExecuteAnonymous', 'Test No Exception logging' , UserInfo.getUserId(),'Data' , 'NA');
        List<Logger__c> loggers = [SELECT id, name, Class__c FROM Logger__c WHERE Class__c = 'DevConsole'];
        System.assert(loggers.size() > 0);
    }
    @IsTest(seeAlldata = false)
    static void logMessageErrorTest() {
    	try{
    		Integer i = Integer.valueOf('Text');	
    	}
    	catch(Exception ex){
			Log4SF.logMessage('DevConsole', 'ExecuteAnonymous', 'Test No Exception logging' , ex, UserInfo.getUserId(), 'NA');
            List<Logger__c> loggers = [SELECT id, name, Class__c FROM Logger__c WHERE Class__c = 'DevConsole'];
            System.assert(loggers.size() > 0);
    	}
    }        
    
}