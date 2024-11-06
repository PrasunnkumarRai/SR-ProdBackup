@isTest
private class ProposalBulkSyncControllerTest {
	static ProposalBulkSyncController ProposalBulkSyncController;
	
    static testMethod void syncProposalsTest() {
    	List<TIMIntegration__c> tList = new List<TIMIntegration__c>();
        tList.add(new TIMIntegration__c(name='St. Louis Local',AppId__c='1',Boomi_Endpoint__c='http://47.42.247.9:9090/ws/rest/SpectrumReach',
        								Endpoint__c='https://its-vmt-timwb01.chartermedia.com/timws/service.asmx',Password__c='us3th3F0RCE!',
        								TIMServer__c='https://its-vmt-timwb01.chartermedia.com/timtest',UserId__c='2',UserName__c='SFDCUser',
        								boomiAtomId__c='5897381a-8c8c-4def-9508-bca93f8cb'));
        
        insert tList;

        TIMIntegration__c timInt = [SELECT id,name,username__c,password__c FROM TIMIntegration__c LIMIT 1];
        System.assertEquals('SFDCUser', timInt.username__c);
        System.assertEquals('us3th3F0RCE!', timInt.password__c);    
        
    	ProposalBulkSync__c sys = new ProposalBulkSync__c();
    	ApexPages.StandardController controller = new ApexPages.StandardController(sys);	
        ProposalBulkSyncController = new ProposalBulkSyncController(controller);
        
        Test.startTest();    
        Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());    
        ProposalBulkSyncController.syncProposals();
        Test.stopTest();  
    }
}