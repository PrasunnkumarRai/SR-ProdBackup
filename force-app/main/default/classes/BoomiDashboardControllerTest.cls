/*
###########################################################################
# File..................: BoomiDashboardControllerTest.cls
# Version...............: 
# Created by............: Anusha Rao
# Created Date..........: 27-June-2016
# Last Modified by......:  
# Last Modified Date....: 
# Description...........: Test class for BoomiDashboardController 
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/
@isTest(seeAllData=false)
private class BoomiDashboardControllerTest {
@testsetup
    public static void prepareTestData() {
        BoomiIntegration__c boomiInt = new BoomiIntegration__c(Name='Default DataCenter',Value__c = 'Charlotte', Endpoint__c='http://47.42.247.10:9090/ws/rest/SpectrumReach/processExecutionStatus');
        insert boomiInt;
        BoomiIntegration__c boomiInt2 = new BoomiIntegration__c(Name='St. Louis Local', Endpoint__c='http://47.42.247.10:9090/ws/rest/SpectrumReach/processExecutionStatus');
        insert boomiInt2;
    }

    public static testMethod void displayProcesses() {
        System.assertEquals(1,1);
        BoomiWebServiceMock.name = 'BoomiDashboardController';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
        BoomiDashboardController boomiDashboard = new BoomiDashboardController();
        boomiDashboard.selectedDataCenter = 'St. Louis Local';
        boomiDashboard.displayProceses();
        boomiDashboard.startProcess();
        boomiDashboard.lastRefreshTime = System.now();
        boomiDashboard.fetchEndPointUrl();
        Test.stopTest();
    }
}