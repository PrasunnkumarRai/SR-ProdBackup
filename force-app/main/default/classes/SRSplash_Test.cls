@isTest
private class SRSplash_Test {
    
    @isTest static void test_method_one() {
        SRSplash splashPage = new SRSplash();
        PageReference spRef = splashPage.SplashInit();
        splashPage.SplashAck();
        SRSplash.SplashAckMobile();
        SRSplash.getAnnouncements();
        SRSplash.showAckElements();
        SRSplash.mobileRedirect();
        splashPage.SplashRedirect();
        //System.assertEquals(null, spRef);
    }
    
    @testSetup static void createTestData(){
    	Id recordtype = Schema.SObjectType.Splash_Page__c.getRecordTypeInfosByName().get('Commission Calendar').getRecordTypeId();
        Id recordtype1 = Schema.SObjectType.Splash_Page__c.getRecordTypeInfosByName().get('Splash Page').getRecordTypeId();
        Date today = Date.today();
        Date yesterday = today.addDays(-1);
        Date tomorrow = today.addDays(1); 
        Splash_Page__c splash = new Splash_Page__c(Start_Date__c = yesterday, End_Date__c = tomorrow, name = 'TestSplash',
                                        Platform__c = 'Both', Message__c = 'test message',recordtypeId = recordtype1);
        insert splash;
        Splash_Page__c splash1 = new Splash_Page__c(Start_Date__c = yesterday, End_Date__c = tomorrow, name = 'TestSplash1',
                                        Platform__c = 'Both', Message__c = 'test message',recordtypeId = recordtype );
        insert splash1;                                
    }
    
     @isTest static void test_method_two(){
        SRCommissionCalendarController cPage = new SRCommissionCalendarController();
        PageReference spRef = cPage.SplashInit();
        //cPage.SplashAck();
        //SRCommissionCalendarController.SplashAckMobile();
        SRCommissionCalendarController.getAnnouncements();
        //SRCommissionCalendarController.showAckElements();
        SRCommissionCalendarController.mobileRedirect();
        cPage.SplashRedirect();
        //System.assertEquals(null, spRef);
               
    }
    
}