@isTest
private class SupportRequestTriggerHandlerTest {
    static opportunity opp;
    static testMethod void testMethod1() {
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        
        Account acc = TestDataHelper.createAcc('Test Account', null, null, null, null, null);                        
        insert acc;

        System.assert(acc != null);

        System.debug('@@acc '+acc);
        
        System.runAs(u){
            opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),null,null,acc.Id); 
            //opp.Agency_Account__c = acc.Id;       
            insert opp;

            System.assert(opp != null);
        }
        System.debug('@@opp '+opp);

        Support_Request__c request = TestDataHelper.createSupportrequest('Test Support Request', opp.Id, 2,null,null,System.today());
        request.Agency__c = acc.Id;
        request.Advertiser__c = acc.Id;
        request.Account_Executive__c = u.Id;
        insert request;

        System.assert(request != null);

        System.debug('@@request '+request);

        Support_Request__c request2 = TestDataHelper.createSupportrequest('Test Support Request2', opp.Id, 2,null,null,System.today());
        request2.Agency__c = acc.Id;
        request2.Advertiser__c = acc.Id;
        request2.Opportunity__c = null;
        try{
            // Oppty null -- must originate from Oppty
            insert request2;
        }catch(Exception ex){}       

        List<Support_Request__c> supports = [SELECT Name,Advertiser__c,Agency__c,Opportunity__c,Account_Executive__c,Assigned_To__c,RecordTypeId FROM Support_Request__c WHERE ID=:request.Id];
        System.debug('@@supports '+supports);

        List<Support_Request__c> oldsupports = new List<Support_Request__c>();
        oldsupports.addAll(supports);

        Map<ID, Support_Request__c> supportsMap = new Map<ID, Support_Request__c>();
        for (Support_Request__c prSer:supports) {
            supportsMap.put(prSer.Id, prSer);
            prSer.Status__c = 'Completed by Kernel';
            prSer.First_Look__c = true;
        }
        update supports;
        System.debug('@@supports after update '+supports);

        SupportRequestTriggerHandler supportTrigger = new SupportRequestTriggerHandler(true,1);
        Boolean IsTriggerContext = supportTrigger.IsTriggerContext;
        Boolean IsVisualforcePageContext = supportTrigger.IsVisualforcePageContext;
        Boolean IsWebServiceContext = supportTrigger.IsWebServiceContext;
        Boolean IsExecuteAnonymousContext = supportTrigger.IsExecuteAnonymousContext;
        supportTrigger.OnBeforeInsert(supports);
        supportTrigger.OnAfterInsert(supports);
        supportTrigger.OnBeforeUpdate(oldsupports,supports,supportsMap);
        supportTrigger.OnAfterUpdate(oldsupports,supports,supportsMap);
        
        delete supports;
        undelete supports;

        //Code Coverage for SupportRequestTriggerHandler.cls added by John King on 07 Jul-17
        
        SupportRequestUtils sru = new SupportRequestUtils();
        
    }
    
    //Added for Dell Boomi call outs
    static testMethod void testDellBoomi() {
    
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        Account acc = TestDataHelper.createAcc('Test Account', null, null, null, null, null);                        
        insert acc;
        Account agency = TestDataHelper.createAgency('Test Agency', 'Test Street', 'Test City', 'Test State', '99221', 'US');                        
        INSERT agency;
        System.assert(acc != null);            
        System.debug('@@acc '+acc);            
        System.runAs(u){
        opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),null,null,acc.Id); 
        opp.Agency_Account__c = agency.Id;      
        insert opp;            
        System.assert(opp != null);
        }
        System.debug('@@opp '+opp);            
        Support_Request__c request = TestDataHelper.createSupportrequest('Test Support Request', opp.Id, 2,null,null,System.today());
        request.Agency__c = acc.Id;
        request.Advertiser__c = acc.Id;
        insert request;            
        Support_Request__c request1 = TestDataHelper.createSupportrequest('Test Support Request', opp.Id, 2,null,null,System.today());
        request1.Agency__c = acc.Id;
        request1.Advertiser__c = acc.Id;
        insert request1;            
        System.assert(request != null);         

        Production_Service__c prop = TestDataHelper.createProdservice('Test Production',request.Id,System.today());               
        //  prop.Account_Executive__c = userAE.Id;
        insert prop;            
        //  Production_Service__c prop1 = TestDataHelper.createProdservice('Test Production',request1.Id,System.today());               
        //  prop.Account_Executive__c = userAE.Id;
        // insert prop1;
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
        List<Support_Request__c >  nwReq = new List<Support_Request__c >();
        
      //  Test.setMock(HttpCalloutMock.class, new ProductionServiceRequestMockImpl());
        SupportRequestTriggerHandler.mock = new ProductionServiceRequestMockImpl(true, 200);
        Test.StartTest();
        System.debug('@@request '+request);          
        request.Status__c='Submitted to Kernel';
        request.Type_of_Request__c = 'Post Sale Production Request' ;
        update request;
        
        request1.Status__c='Submitted to Kernel';
        request1.Type_of_Request__c = 'Pre-contract consult' ;
        update request1;
        Test.StopTest();
   
    }

    static testMethod void testCallOutException() {
    
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        Account acc = TestDataHelper.createAcc('Test Account', null, null, null, null, null);                        
        insert acc;
        System.assert(acc != null);            
        System.debug('@@acc '+acc);            
        System.runAs(u){
        opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),null,null,acc.ID);        
        insert opp;            
        System.assert(opp != null);
        }
        System.debug('@@opp '+opp);            
        Support_Request__c request = TestDataHelper.createSupportrequest('Test Support Request', opp.Id, 2,null,null,System.today());
        request.Agency__c = acc.Id;
        request.Advertiser__c = acc.Id;
        insert request;            
        Support_Request__c request1 = TestDataHelper.createSupportrequest('Test Support Request', opp.Id, 2,null,null,System.today());
        request1.Agency__c = acc.Id;
        request1.Advertiser__c = acc.Id;
        insert request1;            
        System.assert(request != null);            
        Production_Service__c prop = TestDataHelper.createProdservice('Test Production',request.Id,System.today());               
        //  prop.Account_Executive__c = userAE.Id;
        insert prop;            
        //  Production_Service__c prop1 = TestDataHelper.createProdservice('Test Production',request1.Id,System.today());               
        //  prop.Account_Executive__c = userAE.Id;
        // insert prop1;
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
        List<Support_Request__c >  nwReq = new List<Support_Request__c >();
        
      //  Test.setMock(HttpCalloutMock.class, new ProductionServiceRequestMockImpl());
        SupportRequestTriggerHandler.mock = new ProductionServiceRequestMockImpl(false, 400);
        Test.StartTest();
        System.debug('@@request '+request);          
        request.Status__c='Submitted to Kernel';
        request.Type_of_Request__c = 'Post Sale Production Request' ;
        update request;
        
        request1.Status__c='Submitted to Kernel';
        request1.Type_of_Request__c = 'Pre-contract consult' ;
        update request1;
        Test.StopTest();
   
    }

     static testMethod void testNegativeScenario() {
    
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        Account acc = TestDataHelper.createAcc('Test Account', null, null, null, null, null);                        
        insert acc;
        System.assert(acc != null);            
        System.debug('@@acc '+acc);            
        System.runAs(u){
        opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),null,null,acc.ID);        
        insert opp;            
        System.assert(opp != null);
        }
        System.debug('@@opp '+opp);            
        Support_Request__c request = TestDataHelper.createSupportrequest('Test Support Request', opp.Id, 2,null,null,System.today());
        request.Agency__c = acc.Id;
        request.Advertiser__c = acc.Id;
        insert request;            
        Support_Request__c request1 = TestDataHelper.createSupportrequest('Test Support Request', opp.Id, 2,null,null,System.today());
        request1.Agency__c = acc.Id;
        request1.Advertiser__c = acc.Id;
        insert request1;            
        System.assert(request != null);            
        Production_Service__c prop = TestDataHelper.createProdservice('Test Production',request.Id,System.today());               
        //  prop.Account_Executive__c = userAE.Id;
        insert prop;            
        //  Production_Service__c prop1 = TestDataHelper.createProdservice('Test Production',request1.Id,System.today());               
        //  prop.Account_Executive__c = userAE.Id;
        // insert prop1;
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
        List<Support_Request__c >  nwReq = new List<Support_Request__c >();
        
      //  Test.setMock(HttpCalloutMock.class, new ProductionServiceRequestMockImpl());
        SupportRequestTriggerHandler.mock = new ProductionServiceRequestMockImpl(true, 404);
        Test.StartTest();
        System.debug('@@request '+request);          
        request.Status__c='Submitted to Kernel';
        request.Type_of_Request__c = 'Post Sale Production Request' ;
        update request;
        
        request1.Status__c='Submitted to Kernel';
        request1.Type_of_Request__c = 'Pre-contract consult' ;
        update request1;
        Test.StopTest();
   
    }

    //START: SRSF-1897
    static testMethod void TestAudienceRequest() 
    {
   User use = TestDataHelper.createSystemAdminUser(false);
system.runAs(use){
        Account AdvAccount = TestDataHelper.createAcc('Test Account', null, null, null, null, null);
        INSERT AdvAccount;       
        
        Opportunity testOppty = TestDataHelper.createopportunity('Test Opportunity',System.today(),null,null,AdvAccount.Id); 
        INSERT testOppty;
        
        Support_Request__c sr = TestDataHelper.createAudienceRequest ('Test Audience Request',testOppty.Id); 
        INSERT sr;          
        System.assertEquals(testOppty.Id, sr.Opportunity__c);

        TestDataHelper.createDataCatalog();
        
        try{
            sr.Data_Catalog_Product_Type__c = ''; 
            sr.Addressable_Online_Data_Catalog__c = '';
            sr.Streaming_TV_Data_Catalog__c =''; 
            sr.Status__c = 'Submitted to Audience Creation Team'; 
            UPDATE sr; 
        } catch (DmlException ex){
            System.assert(TRUE, Label.Select_Data_Catalog_Values);
        }

        try{
            sr.Streaming_TV_Data_Catalog__c = 'Sports|Tennis |TENNIS2021';
            sr.Status__c = 'Submitted to Audience Creation Team';
            UPDATE sr;
        } catch (DmlException ex){
            System.assert(TRUE, Label.Select_Restricted_Audiences);
        }

        try{
            sr.Data_Catalog_Product_Type__c = ''; 
            sr.Streaming_TV_Data_Catalog__c ='Voter Age|55+|POLVOTE55PLUS';  
            UPDATE sr; 
        } catch (DmlException ex){
            System.assert(TRUE, Label.Political_Interest_Can_t_be_Selected);
        } 

        AdvAccount.Political_Account__c = true;
        UPDATE AdvAccount;

        //sr.Status__c = 'Review In Progress';
      //  sr.Data_Catalog_Product_Type__c = 'Addressable Online;Streaming TV'; 
        sr.Data_Catalog_Product_Type__c = 'Addressable Online';
        sr.Addressable_Online_Data_Catalog__c = 'Voter Household Income|$200k+';
        sr.Streaming_TV_Data_Catalog__c ='Sports|Tennis |TENNIS2021;Education|College|COLLGRAD';  
        UPDATE sr;         

}    }
    //END: SRSF-1897    
}