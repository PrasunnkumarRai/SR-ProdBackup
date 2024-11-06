@isTest
private class SyscodeSyncControllerTest {
	static SyscodeSyncController syscodeController;
	
    static testMethod void syncSyscodesTest() {
    	Syscode__c sys = new Syscode__c();
    	ApexPages.StandardController controller = new ApexPages.StandardController(sys);	
        syscodeController = new SyscodeSyncController(controller);

        System.assert(ApexPages.getMessages().size() == 0);
        
        Test.startTest();    
        Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());    
        syscodeController.syncSyscodes();
        Test.stopTest();  
    }
}