@isTest
private class ProductionServiceTriggerHandlerTest {
    static opportunity opp;
    static testMethod void testMethod1() {
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        
        Account acc = TestDataHelper.createAcc('Test Account', null, null, null, null, null);                        
        insert acc;
        System.debug('@@acc '+acc);
        
        System.runAs(u){
            opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),null,null,acc.ID);        
            insert opp;
        }
        System.debug('@@opp '+opp);

        Support_Request__c request = TestDataHelper.createSupportrequest('Test Support Request', opp.Id, 2,null,null,System.today());
        insert request;
        System.debug('@@request '+request);

        List<Production_Service__c> services;
        system.runAs(u) {
            Production_Service__c prop = TestDataHelper.createProdservice('Test Production',request.Id,System.today());               
            insert prop;
            System.debug('@@prop '+prop);
            services = [SELECT fsa_amount__c,First_Look__c, Rate_Card_Value__c, Amount_to_be_Billed__c,KDD__c,Name, Account_Executive__c, Box_Callout_Status__c, Box_Folder_Exists__c, Box_Callout_Last_Updated__c, CreatedDate, RecordTypeId, Kernel_Offer__c, Sponsorship_Type__c, Sponsorship_Discount__c,Status__c FROM Production_Service__c WHERE ID=:prop.Id];
        
            System.debug('@@services '+services);

            List<Production_Service__c> oldservices = new List<Production_Service__c>();
            oldservices.addAll(services);

            Map<ID, Production_Service__c> servicesMap = new Map<ID, Production_Service__c>();
            for (Production_Service__c prSer:services) {
                servicesMap.put(prSer.Id, prSer);
            //  prSer.Digital_Order_Status__c = 'In Progress';
            }
            update services;
            System.debug('@@services after update '+services);

            ProductionServiceTriggerHandler serviceTrigger = new ProductionServiceTriggerHandler(true,1);
            Boolean IsTriggerContext = serviceTrigger.IsTriggerContext;
            Boolean IsVisualforcePageContext = serviceTrigger.IsVisualforcePageContext;
            Boolean IsWebServiceContext = serviceTrigger.IsWebServiceContext;
            Boolean IsExecuteAnonymousContext = serviceTrigger.IsExecuteAnonymousContext;
            serviceTrigger.OnBeforeInsert(services);
            serviceTrigger.OnAfterInsert(services);
            serviceTrigger.OnBeforeUpdate(oldservices, services,servicesMap);
            serviceTrigger.OnAfterUpdate(oldservices, services, servicesMap);
            
            delete services;
            undelete services;
        }
        //Code Coverage for NewProductionServiceController.cls added by Madhusudhan on 05 Jul-17
        
    }
    
    //test dell boomi call outs
    static testMethod void testDellBoomi() {
     
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        
        Account acc = TestDataHelper.createAcc('Test Account', null, null, null, null, null);                        
        insert acc;
        System.debug('@@acc '+acc);
        
        System.runAs(u){
            opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),null,null,acc.ID);        
            insert opp;
        }
             
        System.debug('@@opp '+opp);
        Support_Request__c request = TestDataHelper.createSupportrequest('Test Support Request', opp.Id, 2,null,null,System.today());
        // request.
        insert request;
        System.debug('@@request '+request);
       //Insert custom settings
        Kernel_Project__c  EndPoints = new Kernel_Project__c ();
        EndPoints.Name='SupportRequest';
        EndPoints.End_Point__c='http://www.gmail.com';
        EndPoints.User_name__c='4rQTfA3Bkn5I+codw4QJDKXBKV1qwETZ7rqcDK8jwe0=';
        EndPoints.Password__c='NtJzMtMzAdO3DiNheP1cdQ1cmEco8y/OXaf6HsCGYU4=';           
        Insert EndPoints; 
        
        Kernel_Project__c  EndPoints1 = new Kernel_Project__c ();
        EndPoints1.Name='ProductionService';
        EndPoints1.End_Point__c='http://www.gmail.com';
        EndPoints1.User_name__c='4rQTfA3Bkn5I+codw4QJDKXBKV1qwETZ7rqcDK8jwe0=';
        EndPoints1.Password__c='NtJzMtMzAdO3DiNheP1cdQ1cmEco8y/OXaf6HsCGYU4=';           
        Insert EndPoints1;  
        
        Production_Service__c prop = TestDataHelper.createProdservice('Test Production',request.Id,System.today());               
        
        ProductionServiceTriggerHandler.mock = new ProductionServiceRequestMockImpl(true, 200);
        Test.StartTest();
       // prop.Account_Executive__c = userAE.Id;
        prop .Billed__c=false;
       // prop .Digital_Order_Status__c='Complete - Billing Submitted';
        prop.Existing_Spot_Location__c='test';
        prop.Finished_Spot_ID__c='test1';
        prop.Finished_Spot_Location__c='test2';
        prop.Finished_Spot_Title__c='test4';
        prop.IMN_ID__c = '1111';
        insert prop;
        
        prop.Linear_Order_Status__c= 'Complete - Billing Submitted';
        update prop;
        Test.StopTest();
    }

    static testMethod void testNegativeScenario() {
     
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        
        Account acc = TestDataHelper.createAcc('Test Account', null, null, null, null, null);                        
        insert acc;
        System.debug('@@acc '+acc);
        
        System.runAs(u){
            opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),null,null,acc.ID);        
            insert opp;
        }
             
        System.debug('@@opp '+opp);
        Support_Request__c request = TestDataHelper.createSupportrequest('Test Support Request', opp.Id, 2,null,null,System.today());
        // request.
        insert request;
        System.debug('@@request '+request);
       //Insert custom settings
        Kernel_Project__c  EndPoints = new Kernel_Project__c ();
        EndPoints.Name='SupportRequest';
        EndPoints.End_Point__c='http://www.gmail.com';
        EndPoints.User_name__c='4rQTfA3Bkn5I+codw4QJDKXBKV1qwETZ7rqcDK8jwe0=';
        EndPoints.Password__c='NtJzMtMzAdO3DiNheP1cdQ1cmEco8y/OXaf6HsCGYU4=';           
        Insert EndPoints; 
        
        Kernel_Project__c  EndPoints1 = new Kernel_Project__c ();
        EndPoints1.Name='ProductionService';
        EndPoints1.End_Point__c='http://www.gmail.com';
        EndPoints1.User_name__c='4rQTfA3Bkn5I+codw4QJDKXBKV1qwETZ7rqcDK8jwe0=';
        EndPoints1.Password__c='NtJzMtMzAdO3DiNheP1cdQ1cmEco8y/OXaf6HsCGYU4=';           
        Insert EndPoints1;  
        
        Production_Service__c prop = TestDataHelper.createProdservice('Test Production',request.Id,System.today());               
        
        ProductionServiceTriggerHandler.mock = new ProductionServiceRequestMockImpl(true, 404);
        Test.StartTest();
       // prop.Account_Executive__c = userAE.Id;
        prop .Billed__c=false;
       // prop .Digital_Order_Status__c='Complete - Billing Submitted';
        prop.Existing_Spot_Location__c='test';
        prop.Finished_Spot_ID__c='test1';
        prop.Finished_Spot_Location__c='test2';
        prop.Finished_Spot_Title__c='test4';
        prop.IMN_ID__c = '1111';
        insert prop;
        
        prop.Linear_Order_Status__c= 'Complete - Billing Submitted';
        update prop;
        Test.StopTest();
    }

    static testMethod void testCallOutException() {
     
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        
        Account acc = TestDataHelper.createAcc('Test Account', null, null, null, null, null);                        
        insert acc;
        System.debug('@@acc '+acc);
        
        System.runAs(u){
            opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),null,null,acc.ID);        
            insert opp;
        }
             
        System.debug('@@opp '+opp);
        Support_Request__c request = TestDataHelper.createSupportrequest('Test Support Request', opp.Id, 2,null,null,System.today());
        // request.
        insert request;
        System.debug('@@request '+request);
       //Insert custom settings
        Kernel_Project__c  EndPoints = new Kernel_Project__c ();
        EndPoints.Name='SupportRequest';
        EndPoints.End_Point__c='http://www.gmail.com';
        EndPoints.User_name__c='4rQTfA3Bkn5I+codw4QJDKXBKV1qwETZ7rqcDK8jwe0=';
        EndPoints.Password__c='NtJzMtMzAdO3DiNheP1cdQ1cmEco8y/OXaf6HsCGYU4=';           
        Insert EndPoints; 
        
        Kernel_Project__c  EndPoints1 = new Kernel_Project__c ();
        EndPoints1.Name='ProductionService';
        EndPoints1.End_Point__c='http://www.gmail.com';
        EndPoints1.User_name__c='4rQTfA3Bkn5I+codw4QJDKXBKV1qwETZ7rqcDK8jwe0=';
        EndPoints1.Password__c='NtJzMtMzAdO3DiNheP1cdQ1cmEco8y/OXaf6HsCGYU4=';           
        Insert EndPoints1;  
        
        Production_Service__c prop = TestDataHelper.createProdservice('Test Production',request.Id,System.today());               
        
        ProductionServiceTriggerHandler.mock = new ProductionServiceRequestMockImpl(false, 400);
        Test.StartTest();
       // prop.Account_Executive__c = userAE.Id;
        prop .Billed__c=false;
       // prop .Digital_Order_Status__c='Complete - Billing Submitted';
        prop.Existing_Spot_Location__c='test';
        prop.Finished_Spot_ID__c='test1';
        prop.Finished_Spot_Location__c='test2';
        prop.Finished_Spot_Title__c='test4';
        prop.IMN_ID__c = '1111';
        insert prop;
        
        prop.Linear_Order_Status__c= 'Complete - Billing Submitted';
        update prop;
        Test.StopTest();
    }    
}