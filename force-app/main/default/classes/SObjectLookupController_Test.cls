/*

    Customer/Project:   Spectrum Reach
    Class name:
        SObjectLookupController_Test
    Author/Date:        Brett Ballantyne    4/14/2017
    Release:
           TBD
    Purpose:            Test class for SSObjectLookupController
*/

@isTest
private class SObjectLookupController_Test {
    
    @isTest static void testGetQueryFields() {
        
        Account testAcc = [SELECT Id, Name FROM Account LIMIT 1];        
        
        String opptyRecType = SObjectLookupController.getOpportunityRecordType();
       
        //List<Profile> proList = [SELECT Id FROM Profile WHERE Name LIKE '%Account Executive%']; 
        
        User u = TestUtil.createAEUser();
        u = (u != null) ? u : new User(Id = UserInfo.getUserId());         
       
        String opptyId = SObjectLookupController.createOppty('oppty test', testAcc.Id, 'Identification', '2020-07-04', u.Id, Id.valueOf(opptyRecType), null, null, 'avoid this network!', null, 'Albany NY',null,null,null,null,null,null,true,null,new List<String>(),new List<String>(),null,null);
        
        Test.startTest();
        
        SObjectLookupController.crossObjQuery coq = new SObjectLookupController.crossObjQuery();
        List<SObjectLookupController.crossObjQuery> coqList = new List<SObjectLookupController.crossObjQuery>();
        coq.objectType = 'Account';
        coq.fields = 'Name,BillingStreet,BillingCity,BillingState';
        coq.whereClause = 'WHERE Name LIKE \'%acc%\' OR BillingStreet LIKE \'%igh%\'';
        coq.numRecords = '';
        coq.supplementalWhereClause = '';
        coqList.add(coq);
        String jsonStr = System.JSON.serialize(coqList);
        System.debug('=======>> jsonStr = ' + jsonStr);         
         
        //SObjectLookupController.getTheme();
        SObjectLookupController.getMyUserId();
        SObjectLookupController.getObjectKeys();
        SObjectLookupController.getQueryFields('Account');
        SObjectLookupController.getQueryFields('Account');
        SObjectLookupController.getRecTypeMap('Account');
        SObjectLookupController.getObjects(jsonStr); 
        SObjectLookupController.getOpportunityStages();
        SObjectLookupController.getAccountInfo(testAcc.Id);
        SObjectLookupController.getAccountRecTypeInfo();
              
        ChangeOpptyOwner coo = new ChangeOpptyOwner();
        Account adAccount = [SELECT Id FROM Account WHERE Name='TestAccount1'];
             
        SObjectLookupController.addAdAccount(opptyId, String.valueOf(adAccount.Id));
        
        System.runAs(u) {
            SObjectLookupController.isCurrentUserOnAccountTeam(String.valueOf(testAcc.Id));
            SObjectLookupController.getAccountAEs(testAcc.Id);
        }
        // test misc utility methods
         
        String agencyRT = SObjectLookupController.getAccountAgencyRT();       
        SObjectLookupController.getContactRoles();
        List<String> adContactTypeList = SObjectLookupController.getAdContactTypes(testAcc.Id);
        // test new contact functionality
        Map<Id, String> contactRecTypes = SObjectLookupController.getAvailRecordTypes('Contact');
        Set<Id> crtSet = contactRecTypes.keySet();
       // Account advertiserAccount = [select Id from Account where name='TestAccount1'];
        List<String> conRTList = contactRecTypes.values();
        String theRecTypeId;
        for (Id crt : crtSet) {
            theRecTypeId = String.valueOf(crt);
            break;
        }
            SObjectLookupController.createNewContact('Arley', 'Farble', 'afarble@guest.com', String.valueOf(u.Id), theRecTypeId, adAccount.Id, adContactTypeList[0],'Sample Title', null, null, 'ETS', 'Charlotte', 'NC', '28203', 'USA', true);
   
        Test.stopTest();
        
       // SObjectLookupController.createNewContact('Arley', 'Farble', 'afarble@guest.com', String.valueOf(u.Id), theRecTypeId, adAccount.Id, adContactTypeList[0], false);
    }

    
    @isTest static void testGetQueryFields1() {     
     
        Account testAcc = [SELECT Id, Name FROM Account LIMIT 1];      
        
        String opptyRecType = SObjectLookupController.getOpportunityRecordType();
        //SObjectLookupController.getTheme();
        SObjectLookupController.getMyUserId();
        SObjectLookupController.getOpportunityStages();
        SObjectLookupController.getAccountInfo(testAcc.Id);
        SObjectLookupController.getAccountRecTypeInfo();

       // List<Profile> proList = [SELECT Id FROM Profile WHERE Name LIKE '%Account Executive%']; 
        User u = TestUtil.createAEUser();
        u = (u != null) ? u : new User(Id = UserInfo.getUserId());        
        
        String opptyId = SObjectLookupController.createOppty('oppty test', testAcc.Id, 'Identification', '2020-07-04', u.Id, Id.valueOf(opptyRecType), null, null, 'avoid this network!', null, 'Albany NY',null,null,null,null,null,null,true,null,new List<String>(),new List<String>(),null,null);
        Test.startTest();
        
        SObjectLookupController.getObjectKeys();
        SObjectLookupController.getQueryFields('Account');

        SObjectLookupController.crossObjQuery coq = new SObjectLookupController.crossObjQuery();
        List<SObjectLookupController.crossObjQuery> coqList = new List<SObjectLookupController.crossObjQuery>();
        coq.objectType = 'Account';
        coq.fields = 'Name,BillingStreet,BillingCity,BillingState';
        coq.whereClause = 'WHERE Name LIKE \'%acc%\' OR BillingStreet LIKE \'%igh%\'';
        coq.numRecords = '';
        coq.supplementalWhereClause = '';
        coqList.add(coq);
        String jsonStr = System.JSON.serialize(coqList);
        System.debug('=======>> jsonStr = ' + jsonStr);

        SObjectLookupController.getQueryFields('Account');
        SObjectLookupController.getRecTypeMap('Account');
        SObjectLookupController.getObjects(jsonStr); 

        ChangeOpptyOwner coo = new ChangeOpptyOwner();
        Account adAccount = [SELECT Id FROM Account WHERE Name='TestAccount1'];        
       
        SObjectLookupController.addAdAccount(opptyId, String.valueOf(adAccount.Id));
        System.runAs(u) {
            SObjectLookupController.isCurrentUserOnAccountTeam(String.valueOf(testAcc.Id));
            SObjectLookupController.getAccountAEs(testAcc.Id);
        }
        // test misc utility methods
        String agencyRT = SObjectLookupController.getAccountAgencyRT();       
        SObjectLookupController.getContactRoles();
        List<String> adContactTypeList = SObjectLookupController.getAdContactTypes(testAcc.Id);
        // test new contact functionality
        Map<Id, String> contactRecTypes = SObjectLookupController.getAvailRecordTypes('Contact');
        Set<Id> crtSet = contactRecTypes.keySet();
        //Account advertiserAccount = [select Id from Account where name='TestAccount1'];
        List<String> conRTList = contactRecTypes.values();
        String theRecTypeId;
        for (Id crt : crtSet) {
            theRecTypeId = String.valueOf(crt);
            break;
        }
            SObjectLookupController.createNewContact('Arley', 'Farble', 'afarble@guest.com', String.valueOf(u.Id), theRecTypeId, adAccount.Id, adContactTypeList[0], 'Sample Title', null, null, 'ETS', 'Charlotte', 'NC', '28203', 'USA', false);
        
        //Code Added for SRSF-1672 Starts Here
        SObjectLookupController.getBudgetDMAValue(Userinfo.getUserId());
        u.Budget_Type__c = 'National';
        u.Budget_DMA__c = 'Albany NY';
        UPDATE u;
        SObjectLookupController.getBudgetDMAValue(u.Id);
        u.Budget_DMA__c = null;
        UPDATE u;
        SObjectLookupController.getBudgetDMAValue(u.Id);
        SObjectLookupController.getSalesProbability();
        SObjectLookupController.getFirstLookFields();
        SObjectLookupController.getUserProfileName();
        //Code Added for SRSF-1672 Ends Here

        Test.stopTest();  
    }

    
    public testmethod static void AddZipCodesNew1()
    {
        try{
            Account objAcc = TestUtil.getAccountRec();
            INSERT objAcc;
            
            List<RecordType> lst = [SELECT Id FROM RecordType WHERE Name='Agency Account' AND SObjecttype='Account'];
            if(lst!=null && !lst.isEmpty()){
                objAcc.RecordTypeId = lst[0].Id;
                objAcc.Last_Client_Schedule_Date__c = Date.today();
                UPDATE objAcc;
            }
            
            Account objAgencyAcc = TestUtil.getAgencyAccountRec();
            INSERT objAgencyAcc;
            
            Opportunity objOpp = TestUtil.getOpportunityRec(objAgencyAcc.Id);
            objOpp.Spectrum_Reach_Preferred__c = true;
            INSERT objOpp;
            
            OpportunityTeamMember oppTeam = new OpportunityTeamMember();
            oppTeam.Userid = Userinfo.getuserid();
            oppTeam.OpportunityId = objOpp.Id;
            INSERT oppTeam;
            List<OpportunityTeamMember> opptyTeams = new List<OpportunityTeamMember>();
            opptyTeams.add(oppTeam);
            ChangeOpptyOwner.insertOpptyTeam(opptyTeams);
            opptyTeams = new List<OpportunityTeamMember>();
            ChangeOpptyOwner.insertOpptyTeam(opptyTeams);
            List<Opportunity> opptys = new List<Opportunity>();
            opptys.add(objOpp);
            ChangeOpptyOwner.addPreferredTeamMembers(opptys);
        }catch(Exception ex){}        
    }
    
    
    @testSetup static void createTestData() {
        // create custom settings
        ObjectLookupSettings__c ols = new ObjectLookupSettings__c();
        ols.Name = 'OLS1';
        ols.Combination_Key__c = '';
        ols.Display_Text__c = 'Account Name';
        ols.Field_To_Search__c = 'Name';
        ols.HTML_End_Tags__c = '';
        ols.HTML_Start_Tags__c = '';
        ols.Is_Active__c = true;
        ols.Object_Type__c = 'Account';
        ols.Result_HTML_End_Tag__c = '';
        ols.Result_HTML_Start_Tag__c = '';
        INSERT ols;

        ObjectLookupKeys__c olk = new ObjectLookupKeys__c();
        olk.Name = '001';
        olk.SObject__c = 'Account';
        INSERT olk;

 //       RecordType recType = [select Id from RecordType where IsActive = true and SobjectType = 'Contact' limit 1];
 //       Contact con = new Contact (LastName = 'TestContact', Phone = '303-111-2222', Email='testContact@somecompany.com', recordTypeId = recType.Id);  
 //       Insert con; 

        List<Account> testAccts = new List<Account>();
        for (Integer i = 0; i < 3; i++) {
            Account acct = new Account(Name='TestAccount' + i, 
  //              Account_Rep__c = con.Id,
                BillingStreet = '235 High St',
                BillingCity = 'Morgantown',
                BillingState = 'WV',
                BillingPostalCode = '26505',
                BillingCountry = 'USA',
                ShippingStreet = '235 High St',
                ShippingCity = 'Morgantown',
                ShippingState = 'WV',
                ShippingPostalCode = '26505',
                ShippingCountry = 'USA');
            testAccts.add(acct);
        }
        INSERT testAccts;
    }

           
    @isTest static void testGetNoOfBroadcastWeeks() {
        
        Account testAcc = [SELECT Id, Name FROM Account LIMIT 1];        
        
        String opptyRecType = SObjectLookupController.getOpportunityRecordType();       
       
        User u = TestUtil.createAEUser();
        u = (u != null) ? u : new User(Id = UserInfo.getUserId());         
       
        String opptyId = SObjectLookupController.createOppty('oppty test', testAcc.Id, 'Identification', '2020-07-04', u.Id, Id.valueOf(opptyRecType), null, null, 'avoid this network!', null, 'Albany NY',null,'2021-09-04','2021-09-30',null,null,null,true,null,new List<String>(),new List<String>(),null,null);
        Integer noOfWeeks = SObjectLookupController.getNoOfBroadcastWeeks(Date.valueOf('2021-09-04'), Date.valueOf('2021-09-30'));
        System.assertEquals(5,noOfWeeks);        
        Test.startTest();
    }


    @isTest static void testGetFlightEndDate() {
        
        Account testAcc = [SELECT Id, Name FROM Account LIMIT 1];        
        
        String opptyRecType = SObjectLookupController.getOpportunityRecordType();       
       
        User u = TestUtil.createAEUser();
        u = (u != null) ? u : new User(Id = UserInfo.getUserId());         
       
        String opptyId = SObjectLookupController.createOppty('oppty test', testAcc.Id, 'Identification', '2020-07-04', u.Id, Id.valueOf(opptyRecType), null, null, 'avoid this network!', null, 'Albany NY',null,'2021-09-04',null,null,null,null,true,null,new List<String>(),new List<String>(),null,null);
        Date flightEndDate = SObjectLookupController.getFlightEndDate(Date.valueOf('2021-09-04'), 3);
        System.assertEquals(Date.valueOf('2021-09-19'),flightEndDate);
        Test.startTest();
    } 

    @isTest static void testCreateMassOpps() {
        
        Account testAcc = [SELECT Id, Name FROM Account LIMIT 1];        
        
        String opptyRecType = SObjectLookupController.getOpportunityRecordType();   

        User u = TestUtil.createAEUser();
        u = (u != null) ? u : new User(Id = UserInfo.getUserId());     
       
       
        SObjectLookupController.createOppty('oppty test', testAcc.Id, 'Identification', '2020-07-04', u.Id, Id.valueOf(opptyRecType), null, null, 'avoid this network!', null, 'Albany NY,Austin TX,Central NY',null,'2022-06-04','2022-09-30',null,null,null,true,null,new List<String>(),new List<String>(),null,null);
    }

    @isTest static void testOutOfBusinessAccOpp() {
        
        Test.StartTest();
        Account acc = TestUtil.getAccountRec();
        acc.primary_commodity__c = 'Auto Aftermarket';
        acc.Out_of_Business__c = TRUE;
        INSERT acc;       
        
        String opptyRecType = SObjectLookupController.getOpportunityRecordType();   

        User u = TestUtil.createAEUser();
        u = (u != null) ? u : new User(Id = UserInfo.getUserId());     
              
        try{
            SObjectLookupController.createOppty('oppty test', acc.Id, 'Identification', '2020-07-04', u.Id, Id.valueOf(opptyRecType), null, null, 'avoid this network!', null, 'Albany NY,Austin TX,Central NY',null,'2022-06-04','2022-09-30',null,null,null,true,null,new List<String>(), new List<String>(),null,null);
        }catch(AuraHandledException ex){
          System.debug('exception test class-->'+ex.getMessage());
          String errMesg = 'Opportunity can\'t be created for Out Of Business Accounts'; 
          System.debug('label test class-->'+System.Label.Prevent_Activity_creation_on_Out_Of_Business_Accounts);
          System.debug('errMesg test class-->'+errMesg);
         System.assertEquals(TRUE, ex.getMessage().contains(errMesg));  
        }

        Test.StopTest();             
    }

    @isTest static void testOppDemandSupplyPlatforms() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Master - Business Development'];
        User busDevUsr = new User(alias = 'usr', email = 'busDevUsr@charter.com',
                emailencodingkey = 'UTF-8', lastname = 'TestingBusDev', languagelocalekey = 'en_US',
                localesidkey = 'en_US', profileid = p.Id, isActive = true,
                timezonesidkey = 'America/Los_Angeles', username = 'busDevUsr@charter.com',Budget_Type__c = 'National'); 
            INSERT busDevUsr;

        String opptyRecType = SObjectLookupController.getOpportunityRecordType();
            
        System.runAs(busDevUsr){
            Account testAcc = TestUtil.getAccountRec();
            testAcc.primary_commodity__c = 'Auto Aftermarket';           
            INSERT testAcc;
        Test.StartTest();
            List<String> dsPlatform = SObjectLookupController.getPicklistValues('Demand_Side_Platform__c');
            List<String> ssPlatform = SObjectLookupController.getPicklistValues('Supply_Side_Platform__c');
            SObjectLookupController.createOppty('Holding Acct Oppty', testAcc.Id, 'Identification', String.valueOf(System.today()+15), busDevUsr.Id, Id.valueOf(opptyRecType), null, null, 'avoid this network!', null, 'Albany NY,Austin TX,Central NY',null,'2022-06-04','2022-09-30',null,null,null,true,null,dsPlatform,ssPlatform,'Seat123',null); 
            Test.StopTest();  
        }  
    }    
}