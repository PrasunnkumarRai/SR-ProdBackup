@isTest
public class EclipseTrafficId_Controller_Test {
    static testMethod void validate_EclipseTrafficId_Controller() {
        
        Account acc = TestUtil.getAccountRec();
        acc.primary_commodity__c =   'Auto Aftermarket';
        insert acc;   
        
       EclipseTrafficId_Controller.getEclipseTraffic(acc.Id);
       EclipseTrafficId_Controller ec = new EclipseTrafficId_Controller();
        
    }
}