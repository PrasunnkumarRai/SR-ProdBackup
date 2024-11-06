@isTest
private class SpectrumReachCreateServiceTest {

    @testSetup static void setup() {
        User usr = TestDataHelper.createUser(true);
        System.assert(usr != null);

        List<Account> actList = new List<Account>();
        Account account = TestDataHelper.createAcc('Test Act1',null,null,null,null,null);
        account.Phone = '1234567890';
        actList.add(account);
        account = TestDataHelper.createAcc('Test Act2',null,null,null,null,null);
        account.Phone = '9876543210';
        actList.add(account);        

        Insert actList;

        List<Traffic_Id_Element__c> trafficIdElmts = new List<Traffic_Id_Element__c>();

        for(Account acc : actList) {
            Traffic_Id_Element__c trfcIdElmt = TestDataHelper.createTrafficIdElement(actList[0].Id , usr.Id , '111' ,'222');
            trfcIdElmt.Traffic_Type__c = 'Account';
            trafficIdElmts.add(trfcIdElmt);
        }

        Insert trafficIdElmts;

    }

    static testMethod void testDoGet() {
        String response = SpectrumReachCreateService.doGet();
        System.assert(response != null);   
    }

    static testMethod void testDoPostForAccountSearch(){
        
        User usr = [Select id,Name from User order by createddate desc limit 1];
        System.assert(usr != null);

        List<Account> accountList = [Select Id,Name,Phone,BillingStreet,BillingCity,BillingCountry,BillingState,BillingPostalCode FROM Account WHERE Name = 'Test Act1'];
        System.assert(accountList.size()>0);

        SpectrumReachCreateService.IncomingSPPRequestWrapper incmngWrpr = new SpectrumReachCreateService.IncomingSPPRequestWrapper(); 
        incmngWrpr.api_Type = SpectrumReachCreateService.ACCOUNT_SEARCH;
        incmngWrpr.source = Label.SPP_Search;
        incmngWrpr.userID = usr.Id;
        incmngWrpr.acc_Name = accountList[0].Name;
        incmngWrpr.acc_PhoneNo = accountList[0].Phone;
	    System.debug('sorce::'+incmngWrpr.source);
        SpectrumReachCreateService.AccountAdress  accountAddress = new SpectrumReachCreateService.AccountAdress();
        accountAddress.acc_Street = accountList[0].BillingStreet;
        accountAddress.acc_City = accountList[0].BillingCity;
        accountAddress.acc_State = accountList[0].BillingState;
        accountAddress.acc_Country = accountList[0].BillingCountry;
        accountAddress.acc_ZipCode = accountList[0].BillingPostalCode;

        incmngWrpr.acc_Address = accountAddress;

        SpectrumReachCreateService.OutgoingResponseWrapper outWrpr = SpectrumReachCreateService.doPost(incmngWrpr);
        System.assert(outWrpr.accountList != null);  

        incmngWrpr.acc_EclipseId = '111';
        outWrpr = SpectrumReachCreateService.doPost(incmngWrpr);
        System.assert(outWrpr.accountList != null); 


    }
    
    static testMethod void testDoPostForCreateAccOppLead(){

        User usr = [Select id,Name from User order by createddate desc limit 1];
        System.assert(usr != null);
        List<Account> lstAcct = new List<Account>();
        SpectrumReachCreateService.IncomingSPPRequestWrapper incmngWrpr = new SpectrumReachCreateService.IncomingSPPRequestWrapper(); 
        incmngWrpr.api_Type = SpectrumReachCreateService.CREATE_ACCOUNT;
        incmngWrpr.source = 'SPP';
        incmngWrpr.userID = usr.Id;
        SpectrumReachCreateService.accountWrapper accWrap = new SpectrumReachCreateService.accountWrapper();
        accWrap.account = TestDataHelper.createAcc(null,null,null,null,null,null);
        Account agencyAcc = TestDataHelper.createAgency('Test Agency',null,null,null,null,null);
        lstAcct.add(agencyAcc);
        Account repfirmAcct = TestDataHelper.createRepFirm('Test RepFirm',null,null,null,null,null);
        lstAcct.add(repfirmAcct);
        insert lstAcct;
        accWrap.account.Agency__c = agencyAcc.Id;
        accWrap.account.Rep_Firm__c = repfirmAcct.Id;
        accWrap.contact = new Contact(LastName = 'Test Lastname',Email = 'test@test.com');
        List<SpectrumReachCreateService.accountWrapper> accWrapList = new List<SpectrumReachCreateService.accountWrapper>{accWrap};
        incmngWrpr.accountlist = accWrapList;

        SpectrumReachCreateService.OutgoingResponseWrapper outWrpr = SpectrumReachCreateService.doPost(incmngWrpr);
        System.assert(outWrpr.results!=null);

        List<String> accIds = outWrpr.results;

        //Code for Opportunity creation
        incmngWrpr.api_Type = SpectrumReachCreateService.CREATE_OPPORTUNITY;
        
        List<Opportunity> opportunityList = new List<Opportunity>();

        for(String str : accIds){        
            opportunityList.add(TestDataHelper.createopportunity(null,null,null,null,str));
        }

        incmngWrpr.opportunityList = opportunityList;
        
        outWrpr = SpectrumReachCreateService.doPost(incmngWrpr);

        //Code for Lead Craetion
        incmngWrpr.api_Type  = SpectrumReachCreateService.CREATE_LEAD;

        SpectrumReachCreateService.leadWrapper leadWrap = new SpectrumReachCreateService.leadWrapper();
        leadWrap.lead = TestDataHelper.createLead( new Map<String, Object>{'FirstName' => 'Lead FirstName' , 'LastName' =>'Lead LastName', 'Company' => 'Test Company Name','Primary_Commodity__c'=>'Education','Commodity_Codes__c'=>'EDUCAT -- Education'} , false);
        Campaign cmpgn = TestDataHelper.createCampaign( new Map<String, Object>{'IsActive' => TRUE , 'Type' =>'Event', 'Name' => 'Test Campaign'} ,TRUE);
        leadWrap.campaignIds = new List<String>{cmpgn.Id};

        List<SpectrumReachCreateService.leadWrapper> leadWrapList = new List<SpectrumReachCreateService.leadWrapper>{leadWrap};
        incmngWrpr.leadList = leadWrapList;
        
        outWrpr = SpectrumReachCreateService.doPost(incmngWrpr);
        System.assert(outWrpr.results!=null);

        incmngWrpr.api_Type  = 'test';
        outWrpr = SpectrumReachCreateService.doPost(incmngWrpr);
        System.assert(outWrpr.results==null);

        incmngWrpr.api_Type  = null;
        outWrpr = SpectrumReachCreateService.doPost(incmngWrpr);
        System.assert(outWrpr.results==null);


    }

     static testMethod void testInvalidLeadPrimaryCommodity(){

        User usr = [Select id,Name from User order by createddate desc limit 1];
        System.assert(usr != null);

        SpectrumReachCreateService.IncomingSPPRequestWrapper incmngWrpr = new SpectrumReachCreateService.IncomingSPPRequestWrapper(); 
        //Code for Lead Craetion
        incmngWrpr.api_Type  = SpectrumReachCreateService.CREATE_LEAD;
        incmngWrpr.source = 'SPP';
        incmngWrpr.userID = usr.Id;

        SpectrumReachCreateService.leadWrapper leadWrap = new SpectrumReachCreateService.leadWrapper();
        leadWrap.lead = TestDataHelper.createLead( new Map<String, Object>{'FirstName' => 'Lead FN1' , 'LastName' =>'Lead LN1', 'Company' => 'Test Company Name','Primary_Commodity__c'=>'test','Commodity_Codes__c'=>'EDUCAT -- Education'} , false);        

        List<SpectrumReachCreateService.leadWrapper> leadWrapList = new List<SpectrumReachCreateService.leadWrapper>{leadWrap};
        incmngWrpr.leadList = leadWrapList;
        
        SpectrumReachCreateService.OutgoingResponseWrapper outWrpr = SpectrumReachCreateService.doPost(incmngWrpr);
        System.assert(!outWrpr.isSuccess);        
    }

    static testMethod void testInvalidLeadCommodityCodes(){

        User usr = [Select id,Name from User order by createddate desc limit 1];
        System.assert(usr != null);

        SpectrumReachCreateService.IncomingSPPRequestWrapper incmngWrpr = new SpectrumReachCreateService.IncomingSPPRequestWrapper(); 
        //Code for Lead Craetion
        incmngWrpr.api_Type  = SpectrumReachCreateService.CREATE_LEAD;
        incmngWrpr.source = 'SPP';
        incmngWrpr.userID = usr.Id;

        SpectrumReachCreateService.leadWrapper leadWrap = new SpectrumReachCreateService.leadWrapper();
        leadWrap.lead = TestDataHelper.createLead( new Map<String, Object>{'FirstName' => 'Lead FN1' , 'LastName' =>'Lead LN1', 'Company' => 'Test Company Name','Primary_Commodity__c'=>'Education','Commodity_Codes__c'=>'test'} , false);        

        List<SpectrumReachCreateService.leadWrapper> leadWrapList = new List<SpectrumReachCreateService.leadWrapper>{leadWrap};
        incmngWrpr.leadList = leadWrapList;
        
        SpectrumReachCreateService.OutgoingResponseWrapper outWrpr = SpectrumReachCreateService.doPost(incmngWrpr);
        System.assert(!outWrpr.isSuccess);        
    }

    static testMethod void testMandatorydLeadCommodityCodes(){

        User usr = [Select id,Name from User order by createddate desc limit 1];
        System.assert(usr != null);

        SpectrumReachCreateService.IncomingSPPRequestWrapper incmngWrpr = new SpectrumReachCreateService.IncomingSPPRequestWrapper(); 
        //Code for Lead Craetion
        incmngWrpr.api_Type  = SpectrumReachCreateService.CREATE_LEAD;
        incmngWrpr.source = 'SPP';
        incmngWrpr.userID = usr.Id;

        SpectrumReachCreateService.leadWrapper leadWrap = new SpectrumReachCreateService.leadWrapper();
        leadWrap.lead = TestDataHelper.createLead( new Map<String, Object>{'FirstName' => 'Lead FN1' , 'LastName' =>'Lead LN1', 'Company' => 'Test Company Name','Primary_Commodity__c'=>'Education','Commodity_Codes__c'=>''} , false);        

        List<SpectrumReachCreateService.leadWrapper> leadWrapList = new List<SpectrumReachCreateService.leadWrapper>{leadWrap};
        incmngWrpr.leadList = leadWrapList;
        
        SpectrumReachCreateService.OutgoingResponseWrapper outWrpr = SpectrumReachCreateService.doPost(incmngWrpr);
        System.assert(!outWrpr.isSuccess);        
    }

}