/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class CloneProductionServiceControllerTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        
        Account acc = TestDataHelper.createAcc('Test Account', null, null, null, null, null);                        
        insert acc;
        System.debug('@@acc '+acc);
        Opportunity opp;
        System.runAs(u){
            opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),null,null,acc.ID);        
            insert opp;
        }
        System.debug('@@opp '+opp);

        Support_Request__c request = TestDataHelper.createSupportrequest('Test Support Request', opp.Id, 2,null,null,System.today());
        insert request;
        System.debug('@@request '+request);
        
        Production_Service__c prop = TestDataHelper.createProdservice('Test Production',request.Id,System.today());   
        prop.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Production_Service__c' AND DeveloperName='Animated_HTML5' limit 1].Id;            
        list<User> lstAEUser = [select id from User where Team_Role__c='Account Executive' OR Team_Role__c='Sales Manager' limit 1];
        if(lstAEUser!=null && !lstAEUser.isEmpty()){
            integer i=0;
            prop.Account_Executive__c = lstAEUser[i].id;
        }
        insert prop;
        System.debug('@@prop '+prop);
        
        CloneProductionServiceController.getProductionServiceRecordTypes( prop.Id );
        list<RecordType> lstRT = [SELECT Id FROM RecordType WHERE SObjectType='Animated_HTML5' AND DeveloperName='Digital_Pushdown' limit 1];
        try{
            String strRTId;
            if(lstRT!=null && !lstRT.isEmpty()){
                integer i=0;
                strRTId = lstRT[i].Id;
            }
            CloneProductionServiceController.cloneThisProductionService( prop.Id, strRTId );
        }catch(Exception ex){}
    }
}