@isTest
public class NewProductionServiceControllerTest {
    static testMethod void testNewProductionServiceController() {
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

        //Insert custom settings
        Kernel_Project__c  EndPoints = new Kernel_Project__c ();
        EndPoints.Name='SupportRequest';
        EndPoints.End_Point__c='http://www.gmail.com';
        EndPoints.User_name__c='4rQTfA3Bkn5I+codw4QJDKXBKV1qwETZ7rqcDK8jwe0=';
        EndPoints.Password__c='NtJzMtMzAdO3DiNheP1cdQ1cmEco8y/OXaf6HsCGYU4=';           
        Insert EndPoints;

        Support_Request__c request = TestDataHelper.createSupportrequest('Test Support Request', opp.Id, 2,null,null,System.today());
        insert request;
        System.debug('@@request '+request);
        SupportRequestTriggerHandler.mock = new ProductionServiceRequestMockImpl(true, 200);

        Test.StartTest();
        NewProductionServiceController.getSupportRequestData(request.Id);
        NewProductionServiceController.getProductionServiceRecordTypes();
        NewProductionServiceController.getSupportRequestRecord(request.Id,null); 

        Production_Service__c psReq = TestDataHelper.createProdservice('Test Prod Service',request.Id,System.today());       
        psReq.Submit_Support_Request__c = true;
        INSERT psReq;
        System.assert(psReq.Submit_Support_Request__c);
        NewProductionServiceController.getProductionService(psReq.Id);
        NewProductionServiceController.updateSupportRequest(psReq.Id);
        NewProductionServiceController.updateProductionService(psReq.Id);        
        
        Test.StopTest();
    }
}