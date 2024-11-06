/*
###########################################################################
# File..................: TestDataHelper.cls
# Version...............: 
# Created by............: Anusha Pagidimarri
# Created Date..........: 29-June-2017
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This is the helper class which creates test data for test classes
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/
public with sharing class TestDataHelper {

    // To get Division & Region from Custom Metadatatype
    public static Map<String,String> fetchDivisions () {
        List<Test_Data_Utility__mdt> ucList = new List<Test_Data_Utility__mdt>();        
        Map<String,String> TestData = new Map<String, String>();

        ucList = [SELECT DeveloperName, Label FROM Test_Data_Utility__mdt LIMIT 50];
        for(Test_Data_Utility__mdt du : ucList)
        {
            TestData.put(du.DeveloperName, du.Label);
        }
      return TestData; 
    }

    public static User createUser(boolean doInsert) {
        Map<String,String> TestData = TestDataHelper.fetchDivisions();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User user = new User(alias = 'standt', email = 'standarduser123@charter.com',
            emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
            localesidkey = 'en_US', profileid = p.Id,isActive = true,
            timezonesidkey = 'America/Los_Angeles', username = 'standarduser123@testorgosius.com',Division__c=TestData.get('Division_c_1'));
        if (doInsert)
            insert user;
        return user;
    }

    // Bhuvan changes on 07-Dec-2017
    public static User createSystemAdminUser(boolean doInsert) {
        Map<String,String> TestData = TestDataHelper.fetchDivisions();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User user = new User(alias = 'System', email = 'adminUser123@charter.com',
            emailencodingkey = 'UTF-8', lastname = 'Testing Sys', languagelocalekey = 'en_US',
            localesidkey = 'en_US', profileid = p.Id,isActive = true,
            timezonesidkey = 'America/Los_Angeles', username = 'standarduser123@sysAdmin.com',
            Division__c = TestData.get('Division_c_1'));
        if (doInsert)
            insert user;
        return user;
    }

    public static UserConnection__c createUserConnection(String timSystem, String userName, String userId, String externalSystem, String aEId) {
        UserConnection__c connection = new UserConnection__c();
        
        if (String.isBlank(timSystem)) {
            timSystem = 'St. Louis Local';
        }
        connection.TIM_System__c = timSystem;

        if (String.isBlank(userName)) {
            userName = 'SFDCUser';
        }
        connection.Username__c = userName;  

        connection.User__c = userId;

        if (String.isBlank(externalSystem)) {
            externalSystem = 'TIM';
        }
        connection.External_System__c = externalSystem;

        if (String.isBlank(aEId)) {
            aEId = '';
        }
        connection.AE_Id__c = aEId;
        
        connection.Is_Primary__c = true;
        
        return connection;
    }

    public static User getBoomiIntegrationUser() {
        return [SELECT Id, Name FROM User WHERE Name = 'Boomi Integration User' LIMIT 1];
    }

    public static void createBoomiEndpointData() {
        BoomiIntegration__c obj = new BoomiIntegration__c(Name = 'Default DataCenter',Endpoint__c='http://47.42.247.9:9090/ws/rest/SpectrumReach/processExecutionStatus');
        insert obj;
    }

    public static Account createAcc(String accName, String street, String city, String state, String postal, String country){//, String code, String designation, Date scheduleDate, Boolean isInsert
        Account acc = new Account();
        if (null == accName || ''.equals(accName)){
            accName = 'Test Account';
        }
        acc.Name = accName;

        if (null == street || ''.equals(street)){
            street = 'Manikonda';
        }
        acc.BillingStreet = street;

        if (null == city || ''.equals(city)){
            city = 'Hyderabad';
        }
        acc.BillingCity = city;

        if (null == state || ''.equals(state)){
            state = 'Telangana';
        }
        acc.BillingState = state;

        if (null == postal || ''.equals(postal)){
            postal = '500084';
        }
        acc.BillingPostalCode = postal;

        if (null == country || ''.equals(country)){
            country = 'India';
        }
        acc.BillingCountry = country;       
        /*acc.Commodity_Codes__c = code;
        acc.SAM_Designation__c = designation;
        
        acc.Last_Client_Schedule_Date__c = scheduleDate;

        if(isInsert){
            insert acc;
        }*/

        return acc;
    }
    

    public static AccountConnection__c createAccountConnection(String accountId){
        AccountConnection__c accCon = new AccountConnection__c();
            accCon.Account__c = accountId;        
            accCon.TIM_System__c = 'St. Louis Local'; 
            accCon.AE_Id__c='1'; 
        return accCon;
    }

    public static Opportunity createopportunity(String name, Date closeDate,String stageName, String forecastCategoryName, String accountId)
    {
        Opportunity opp = new opportunity();
        if(null==name||''.equals(name)){
            name = 'Test opportunity';
        }
        opp.Name=name;
        
        if(null == closeDate){
            closeDate = system.today();            
        }
        opp.CloseDate = closeDate;
        
        if(null == stageName||''.equals(stageName)){
            StageName = 'Planning';
        }
        opp.StageName = stageName;
        
        if(null == forecastCategoryName||''.equals(forecastCategoryName)){
            ForecastCategoryName = 'Pipeline';
        }
        opp.ForecastCategoryName = forecastCategoryName;
        
        if(null == accountId||''.equals(accountId)){
            account acc = createAcc('Test Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                        
            insert acc;
            AccountId = acc.id;
        }
        opp.AccountId = accountId;
        opp.OwnerId = UserInfo.getUserId();
        opp.CoOp__c = FALSE;
        return opp;
    }
    
    public static Id oppBudgetRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Opportunity_Budget'].Id;    
    public static Id LinearRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Linear' LIMIT 1].Id;
    public static Id oppLockedRecTypeId = [SELECT Id FROM RecordType WHERE SobjectType='Opportunity' AND DeveloperName='Opportunity_Locked' LIMIT 1].Id;
    
    public static Proposal__c createProposal(String name, String OpportunityId, String TIMId, Boolean isActive)
    {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Linear'];
        
        Proposal__c prop = new Proposal__c();
        
        if(null == OpportunityId||''.equals(OpportunityId)){
            Opportunity opp = createopportunity(null,System.Today(),null,null,null);
            insert opp;
            OpportunityId =opp.id;
        }
        if(null == name||''.equals(name)){
            name = 'Test Proposal';
        }
        prop.Name = name;
        prop.Opportunity__c =OpportunityId;
        prop.RecordTypeId = rt.Id;
        
        if(null==TIMId||''.equals(TIMId)){
            TIMId = '76877';
        }
        prop.TIM_Id__c = TIMId;
        
        if(null == isActive){
            isActive = True;
        }
        prop.active__c = isActive;
        
        System.debug(prop);
        
        return prop;
    }
    
    public static Trade__c createTrade(String name, String OpportunityId, String ProposalId)
    {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Trade Warning'];
        
        Trade__c trade = new Trade__c();
        
        if(null == OpportunityId||''.equals(OpportunityId)){
            Opportunity opp = createopportunity(null,System.Today(),null,null,null);
            insert opp;
            OpportunityId =opp.id;
        }
        if(null == ProposalId||''.equals(ProposalId)){
            Proposal__c prop = createProposal(null,OpportunityId,null,null);
            insert prop;
            ProposalId =prop.id;
        }
        if(null == name||''.equals(name)){
            name = 'Test Trade';
        }
        trade.Name = name;
        trade.Trade_Opportunity__c =OpportunityId;
        trade.Paid_Proposal__c =ProposalId;
        trade.RecordTypeId = rt.Id;
        
        
        System.debug(trade);
        
        return trade;
    }


    public static Proposal__c createAdvancedProposal (Proposal__c pilotProp, String orderType, String prodType, String advPropName, Boolean isInsert)
    {        
        Proposal__c advProp = new Proposal__c();        
        
        if(null == advPropName||''.equals(advPropName)){
            advPropName = 'Test Advanced Proposal';
        }
        advProp.RecordTypeId = ProposalUtils.advancedProposalRtId;
        advProp.active__c = TRUE;
        advProp.Name = advPropName;
        advProp.Order_Type__c = orderType;
        advProp.Product_Type__c = prodType;
        advProp.Pilot_Proposal__c = pilotProp.Id;         
        advProp.Start_Date__c = System.today().addDays(2);
        advProp.End_Date__c = System.today().addMonths(2);
        advProp.Opportunity__c = pilotProp.Opportunity__c;
        advProp.Proposal_Owner__c = pilotProp.Opportunity__r.OwnerId;
        advProp.Sales_Office__c = pilotProp.Sales_Office__c;
        advProp.Division__c = pilotProp.Division__c; 
        advProp.Region__c = pilotProp.Region__c;        
        advProp.Eclipse_Customer_ID__c = pilotProp.Eclipse_Customer_ID__c;        
        advProp.Traffic_Order_Number__c = pilotProp.Traffic_Order_Number__c;
        advProp.Advertiser__c = pilotProp.Advertiser__c; 
        advProp.Agency__c = pilotProp.Agency__c; 
        advProp.Rep_Firm__c = pilotProp.Rep_Firm__c;        
        
        System.debug('advProp>>>>'+advProp);

        if (isInsert){
            INSERT advProp;
        }
        
        return advProp;
    }

    
    public static Digital_Campaign__c createDigitalCampaign(String name, String OpportunityId, String ProposalId)
    {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Spectrum Networks Display'];
        
        Digital_Campaign__c dc = new Digital_Campaign__c();
        
        if(null == OpportunityId||''.equals(OpportunityId)){
            Opportunity opp = createopportunity(null,System.Today(),null,null,null);
            insert opp;
            OpportunityId =opp.id;
        }
        if(null == ProposalId||''.equals(ProposalId)){
            Proposal__c prop = createProposal(null,OpportunityId,null,null);
            insert prop;
            ProposalId =prop.id;
        }
        if(null == name||''.equals(name)){
            name = 'Test Digital Campaign';
        }
        dc.Campaign_Name__c = name;
        dc.Opportunity__c =OpportunityId;
        dc.Proposal__c =ProposalId;
        dc.RecordTypeId = rt.Id;
        
        System.debug(dc);
        
        return dc;
    }
    
     public static Digital_Creative__c createDigitalCreative(String name, String DigitalCampaignId)
    {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Upload Creative - Display'];
        Digital_Creative__c dc = new Digital_Creative__c();
        
        
        if(null == DigitalCampaignId||''.equals(DigitalCampaignId)){
            Opportunity opp = createopportunity(null,System.Today(),null,null,null);
            insert opp;
            String OpportunityId =opp.id;

            Proposal__c prop = createProposal(null,OpportunityId,null,null);
            insert prop;
            String ProposalId =prop.id;

            Digital_Campaign__c dCamp = createDigitalCampaign(null, OpportunityId, ProposalId);
            insert dCamp;
            DigitalCampaignId = dCamp.Id;
        }

        if(null == name||''.equals(name)){
            name = 'Test Digital Creative';
        }
        dc.Creative_Name__c = name;
        dc.Digital_Campaign__c =DigitalCampaignId;
        
        System.debug(dc);
        
        return dc;
    }
    
    public static Proposal_Zone__c createProposalZone(String name, String proposalId){

        Proposal_Zone__c proposalZone = new Proposal_Zone__c();

        if (String.isBlank(name)) {
            name = 'Test Proposal Zone';
        }
        proposalZone.Name = name;

        if (String.isBlank(proposalId)) {
            Proposal__c proposal = createProposal('Test Proposal',null,null,null);
            insert proposal;
            proposalId = proposal.Id;
        }

        proposalzone.Proposal__c = proposalId;

        return proposalZone;
    }

    public static Proposal_Zone_Monthly_Value__c createProposalZoneMontly(String name,String accId, String proposalZoneId){
        
        Proposal_Zone_Monthly_Value__c proposalZoneMonValue = new Proposal_Zone_Monthly_Value__c();
        
        if (String.isBlank(name)) {
            name = 'Test Proposal Zone Monthly Value';
        }
        proposalZoneMonValue.Name = name;

        if (String.isBlank(accId)) {
            Account acc = createAcc('Test Account',null,null,null,null,null);  
            insert acc;
            accId = acc.Id;                      
        }
        proposalZoneMonValue.Advertiser__c = accId;

        if (String.isBlank(proposalZoneId)) {
            Proposal_Zone__c proposalZone = createProposalZone('Test Proposal Zone',null);
            insert proposalZone;
            proposalZoneId = proposalZone.Id;
        }
        proposalZoneMonValue.Proposal_Zone__c = proposalZoneId;

        return proposalZoneMonValue;
    }

    public static Group__c createGroup(String name){
        Group__c gr = new Group__c();
        if (String.isBlank(name)) {
            name = 'Test Group';
        }
        gr.Name = name;

        return gr;
    }

    public static Group_Status__c createGroupStatus(String name, String groupId){
        Group_Status__c groupStatus = new Group_Status__c();
        if (String.isBlank(name)) {
            name = 'Test Group Status';
        }
        groupStatus.Name = name;

        if (String.isBlank(groupId)) {
            Group__c gr = createGroup('Test group');
            insert gr;
            groupId = gr.Id;
        }
        groupStatus.Group__c = groupId;
        return groupStatus;
    }


    public static Support_Request__c createSupportrequest(String name, String opportunityId, Decimal budget, String type, String status, Date dueDate){
        
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Production'];

        Support_Request__c request = new Support_Request__c();

        if(String.isBlank(name)){
            name = 'Test Support Request';
        }
        request.Name = name;

        if (String.isBlank(opportunityId)) {
            Opportunity opp = createopportunity(null,System.today(),null,null,null);
            insert opp;   
            opportunityId = opp.Id;
        }
        request.Opportunity__c = opportunityId;

        if(budget == Null){
            budget = 2;
        }
        request.Production_Budget__c = budget;

        if(String.isBlank(type)){
            type = 'Post Sale Production Request';
        }
        request.Type_of_Request__c = type;

        if(String.isBlank(status)){
            status = 'Pending';
        }
        request.Status__c = status;

        if(dueDate == Null){
            dueDate = System.today();
        }
        request.Due_Date__c = dueDate;

        request.RecordTypeId = rt.Id;

        return request;
    }

    public static Production_Service__c createProdservice(String name, String supportRequestId, Date startDate){
        Production_Service__c service = new Production_Service__c();

        if (String.isBlank(name) ) {
            name = 'Test Production';
        }
        service.Name = name;
        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType = 'Production_Service__c' limit 1];
        service.RecordTypeId = rt.Id;

        if (String.isBlank(supportRequestId)) {
            Support_Request__c request = createSupportrequest(null,null,2,null,null,System.today());
            insert request;
            supportRequestId = request.Id;
        }
        service.Support_Request__c = supportRequestId;

        if (startDate == Null) {
            startDate = System.today();
        }
        service.Flight_Start_Date__c = startDate;
        service.Account_Executive__c = UserInfo.getUserId();

        return service;
    }

    public static Group_Member__c createGroupMember(String groupId){
        Group_Member__c groupMember = new Group_Member__c();

        if (String.isBlank(groupId)) {
            Group__c gr = createGroup('Test group');
            insert gr;
            groupId = gr.Id;
        }
        
        groupMember.Group__c = groupId;
        
        return groupMember;
    }

     public static User_Approval_Zone__c createUserApproval(String sysCode){
        User_Approval_Zone__c userApprovalZone = new User_Approval_Zone__c();
        if (String.isBlank(sysCode)) {
            sysCode = '3377,5526,6665';
        }
        userApprovalZone.Authorized_Syscodes__c = sysCode;
        
        return userApprovalZone;
    }
    
    public static void createTIMIntegrationCustomSettings(){
        List<TIMIntegration__c> tList = new List<TIMIntegration__c>();
        tList.add(new TIMIntegration__c(name='St. Louis Local',AppId__c='1',Boomi_Endpoint__c='http://47.42.247.9:9090/ws/rest/SpectrumReach',
                                        Endpoint__c='https://its-vmt-timwb01.chartermedia.com/timws/service.asmx',Password__c='us3th3F0RCE!',
                                        TIMServer__c='https://its-vmt-timwb01.chartermedia.com/timtest',UserId__c='2',UserName__c='SFDCUser',
                                        boomiAtomId__c='5897381a-8c8c-4def-9508-bca93f8cb' , Boomi_EnvironmentId__c='670e0f93-d137-4323-b55e-37db5d76f9bc')); //Added Boomi EnvironmentId
        
        insert tList;
    }
    
    public static Id advRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Advertiser_Account' AND SobjectType = 'Account' LIMIT 1].Id;
    public static Id agencyRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Agency_Account' AND SobjectType = 'Account' LIMIT 1].Id;
    //Code added by aditi : 7/7/2017
    public static Id repFirmRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Rep_Firm' AND SobjectType = 'Account' LIMIT 1].Id;
    //code changes done
    
    public static Account createAdvertiser(String accountName, String street, String city, String state, String postal, String country){
        
        Account advAcc = new Account(RecordTypeId = advRecTypeId);
        if (null == accountName || ''.equals(accountName)){
            accountName = 'Test Account';
        }
        advAcc.Name = accountName;
                
        if (null == street || ''.equals(street)){
            street = '123 Wright Plaza';
        }
        advAcc.BillingStreet = street;

        if (null == city || ''.equals(city)){
            city = 'Omaha';
        }
        advAcc.BillingCity = city;

        if (null == state || ''.equals(state)){
            state = 'NE';
        }
        advAcc.BillingState = state;

        if (null == postal || ''.equals(postal)){
            postal = '68130';
        }
        advAcc.BillingPostalCode = postal;

        if (null == country || ''.equals(country)){
            country = 'USA';
        }
        advAcc.BillingCountry = country;
        
        advAcc.Active__c = true;
        
        //insert advadvAcc;
        return advAcc;
    }
    
    public static Account createAgency(String accountName, String street, String city, String state, String postal, String country){
        
        Account advAcc = new Account(RecordTypeId = agencyRecTypeId);
        if (null == accountName || ''.equals(accountName)){
            accountName = 'Test Account';
        }
        advAcc.Name = accountName;
                
        if (null == street || ''.equals(street)){
            street = '123 Wright Plaza';
        }
        advAcc.BillingStreet = street;

        if (null == city || ''.equals(city)){
            city = 'Omaha';
        }
        advAcc.BillingCity = city;

        if (null == state || ''.equals(state)){
            state = 'NE';
        }
        advAcc.BillingState = state;

        if (null == postal || ''.equals(postal)){
            postal = '68130';
        }
        advAcc.BillingPostalCode = postal;

        if (null == country || ''.equals(country)){
            country = 'USA';
        }
        advAcc.BillingCountry = country;
        
        advAcc.Active__c = true;
        
        //insert advadvAcc;
        return advAcc;
    }

    public static Account createRepFirm(String accountName, String street, String city, String state, String postal, String country){
        
        Account repFirmAcc = new Account(RecordTypeId = repFirmRecTypeId);
        if (null == accountName || ''.equals(accountName)){
            accountName = 'Test Account';
        }
        repFirmAcc.Name = accountName;
                
        if (null == street || ''.equals(street)){
            street = '123 Wright Plaza';
        }
        repFirmAcc.BillingStreet = street;

        if (null == city || ''.equals(city)){
            city = 'Omaha';
        }
        repFirmAcc.BillingCity = city;

        if (null == state || ''.equals(state)){
            state = 'NE';
        }
        repFirmAcc.BillingState = state;

        if (null == postal || ''.equals(postal)){
            postal = '68130';
        }
        repFirmAcc.BillingPostalCode = postal;

        if (null == country || ''.equals(country)){
            country = 'USA';
        }
        repFirmAcc.BillingCountry = country;
        
        repFirmAcc.Active__c = true;
        
        //insert advadvAcc;
        return repFirmAcc;
    }
    
    public static Traffic_Id_Element__c createTrafficIdElement(String accId, String userId, String exportSystemId, String trafficId){
        Traffic_Id_Element__c trfcId = new Traffic_Id_Element__c();
        if(accId != null)
            trfcId.Account__c = accId;
        if(userId != null)
            trfcId.User__c = userId;
        trfcId.Export_System_Id__c = exportSystemId;
        trfcId.Traffic_Id__c = trafficId;
        return trfcId;
    }
    
    
    public static Revenue__c createRevenue(String accId, String userId, Date bMonth, Decimal actualGross, Decimal projectedGross, Decimal actualDiscount, Decimal projectedDiscount, String exportSystemId){
        Revenue__c rev = new Revenue__c();
        rev.Customer_Number__c = accId;
        rev.AE_Id__c = userId;
        rev.Export_System_Id__c = exportSystemId;
        rev.Actual_Gross_Amount__c = actualGross;
        rev.Projected_Gross_Amount__c = projectedGross;
        rev.Actual_Discount__c = actualDiscount;
        rev.Projected_Discount__c = projectedDiscount;
        rev.Broadcast_Month_Date__c = bMonth;
        return rev;
    }

    //Code added By Aditi : 5-7-2017
    /*@Desc: To create contacts
      @param: lastname : Last name of contact
      @param: accountid : account's id
      @param: email : email address
      @param: contacttype : Advertiser_Contact_Type__c  picklist
      @return : Contact

    */

    public static Contact createContact(String lastName, String accId, String email , String contactType){

        Contact con = new Contact();
        if (null == lastName || ''.equals(lastName)){
            lastName = 'Test lName';
        }
        con.LastName = lastName;
        if (null == email || ''.equals(email)){
            email = 'test@test.com';
        }
        con.Email = email;
        if (null == contactType || ''.equals(contactType)){
            contactType = 'Billing Contact';
        }
        con.Advertiser_Contact_Type__c = contactType;
        if (null == accId || String.isBlank(accId)){
            Account acc = createAcc('Test Account',null,null,null,null,null);  
            insert acc;
            accId = acc.Id; 
        }
        con.AccountId = accId;

        return con;
    }

    /*@Desc: To create CNA      
      @param: accountid : account's id
      @return : CNA

    */

    public static CNA__c createCNR(String accId)
    {
        CNA__c cnaObj = new CNA__c();
        if (null == accId || String.isBlank(accId)){
            Account acc = createAcc('Test Account',null,null,null,null,null);  
            insert acc;
            accId = acc.Id; 
        }
        cnaObj.Account__c = accId;

        return cnaObj;

    }

    public static void createSysCodeManualProposalCreationCustomSettings(){
        List<SysCodeManualProposalCreation__c> tList = new List<SysCodeManualProposalCreation__c>();
        tlist.add(new SysCodeManualProposalCreation__c(name='DigitalSysCode',Value__c='0000'));
        tlist.add(new SysCodeManualProposalCreation__c(name='LinearSysCode',Value__c='9999'));
        tlist.add(new SysCodeManualProposalCreation__c(name='ProductionRequestSysCode',Value__c='PROD'));
        tlist.add(new SysCodeManualProposalCreation__c(name='RSN',Value__c='RSNB'));
        tlist.add(new SysCodeManualProposalCreation__c(name='SRNews',Value__c='SRNB'));
        tlist.add(new SysCodeManualProposalCreation__c(name='National Spot (NCC)',Value__c='NSPOT'));
        insert tList;
    }
    public static void OppBudgetMessages(){
        List<OppBudgetMessages__c> oppBudList = new List<OppBudgetMessages__c>();
        oppBudList.add(new OppBudgetMessages__c(name='End Date Pulled',MessageDetails__c='Do you want to keep the tenure and data by reducing the start date?',OptionDetails__c='ReduceStartDate'));
        oppBudList.add(new OppBudgetMessages__c(name='End Date Pulled 2',MessageDetails__c='Do you wish to remove the month(s) and data from the end?',OptionDetails__c='RemoveE'));
        oppBudList.add(new OppBudgetMessages__c(name='End Date Pushed Ahead',MessageDetails__c='Do you want to keep the tenure and data by extending the start date?',OptionDetails__c='ChangeStartDate'));
        oppBudList.add(new OppBudgetMessages__c(name='End Date Pushed Ahead2',MessageDetails__c='Do you wish to add the month(s) in the end ?',OptionDetails__c='AddE'));
        oppBudList.add(new OppBudgetMessages__c(name='Start Date Pulled1',MessageDetails__c='Do you want to keep the tenure and data by reducing the start date?',OptionDetails__c='ReduceStartDate'));
        oppBudList.add(new OppBudgetMessages__c(name='Start Date Pulled2',MessageDetails__c='Do you wish to add the month(s) in the beginning?',OptionDetails__c='AddB'));
        oppBudList.add(new OppBudgetMessages__c(name='Start Date Pushed Ahead1',MessageDetails__c='Do you want to keep the tenure and data by extending the end date?',OptionDetails__c='ChangeEndDate'));
        oppBudList.add(new OppBudgetMessages__c(name='Start Date Pushed Ahead2',MessageDetails__c='Do you wish to remove the month(s) and data from the beginning ?',OptionDetails__c='RemoveB'));
        insert oppBudList;
    }

    public static void createManagerUserRolesCustomSettings(){
        List<ManagerUserRoles__c> roleList = new List<ManagerUserRoles__c>();
        roleList.add(new ManagerUserRoles__c (Name='Director'));
        roleList.add(new ManagerUserRoles__c (Name='GSM'));
        roleList.add(new ManagerUserRoles__c (Name='LSM'));
        roleList.add(new ManagerUserRoles__c (Name='VP'));       
        insert roleList;
    }

    public static void createSuperUserRoles(){
        List<SuperUserRoles__c> userRoles = new List<SuperUserRoles__c>();
        userRoles.add(new SuperUserRoles__c (Name='Billing'));
        userRoles.add(new SuperUserRoles__c (Name='System Administrator'));
        userRoles.add(new SuperUserRoles__c (Name='Standard User'));

        insert userRoles;
    }

    public static Budget__c createBudget(Date budgetDate,Decimal amount, String budgetLevel,String budgetAE, String accId,String status){
        
        Budget__c budget = new Budget__c();
        budget.Broadcast_Month_Date__c = budgetDate;
        if (null == amount){
            amount = 1000;
        }
        budget.Amount__c = amount;
        if (null == budgetLevel || ''.equals(budgetLevel)){
            budgetLevel = 'Linear';
        }
        budget.Product_Line__c = budgetLevel;
        budget.BudgetAE__c = budgetAE;
        budget.Account__c = accId;
        if (null != status && !''.equals(status)){
            budget.Status__c = status;
        }
        //insert budget;
        return budget;
    }

    public static void createBudgetEntryYear() {
        Date dt = System.Today();       
        String year = String.valueOf(dt.year());
        Budget_Entry_Year__c obj = new Budget_Entry_Year__c (Name = 'Budget_Year',Value__c=year);
        insert obj; 
    }

    public static Account_Bulk_Merge__c getAccountBulkMerge(String childAccId , String parentAccId)
    {
        Account_Bulk_Merge__c accBulkMerge = new Account_Bulk_Merge__c();
        accBulkMerge.Child_Account__c = childAccId;
        accBulkMerge.Parent_Account__c = parentAccId;
        return accBulkMerge;

    }
    
    public static ProposalNewSync__c createProposalNewSync(String TIMSystem, String TIMId)
    {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Linear'];        
                
        Opportunity opp = createopportunity(null,System.Today(),null,null,null);
        insert opp;
        String OpportunityId =opp.id;
        
        Proposal__c prop = new Proposal__c();
        prop.Name = 'Test Proposal';
        prop.Opportunity__c =OpportunityId;
        prop.RecordTypeId = rt.Id;        
        prop.TIM_Id__c = '00000';
        insert prop;
        
        ProposalNewSync__c pns = new ProposalNewSync__c();
        pns.name = TIMId;
        pns.TIM_System__c = TIMSystem;  
        
        return pns;      
    }
    
    /*
    public static API_Profile__c getAPIProfile(String apiprofNAme , String description , String apiKey)
    {
        API_Profile__c apiProfile = new API_Profile__c();
        apiProfile.Name = apiprofNAme;
        apiProfile.API_Key__c = apiKey;
        apiProfile.Description__c = description;
        return apiProfile;

    }
    public static API_Profile_sObject__c getAPIProfilesObject(String apiProfId, String fieldNames ,Boolean isUpdate, Boolean isCreate, Boolean isRead, Boolean isDelete)
    {
        API_Profile_sObject__c apiProfsObj = new API_Profile_sObject__c();
        apiProfsObj.API_Profile__c = apiProfId;
        apiProfsObj.Authorized_Fields__c = fieldNames;
        apiProfsObj.Create__c =isCreate;
        apiProfsObj.Update__c=isUpdate;
        apiProfsObj.Delete__c=isDelete;
        apiProfsObj.Read__c=isRead;
        return apiProfsObj;

    }
*/

    //Code Added by Abhilash : 30-03-2018
    public static SObject assignFields(Map<String, Object> fieldNameValueMapping, SObject obj, Boolean isInsert) {
        if(fieldNameValueMapping != null && !fieldNameValueMapping.IsEmpty()) {
            for (String key : fieldNameValueMapping.keyset()) {
                obj.put(key, fieldNameValueMapping.get(key));
            }
        }
        if (isInsert) {
            insert obj;
        }
        return obj;
    }

    public static Task createTask(Map<String, Object> fieldNameValueMapping, Boolean ins){        
        final String now = '' + System.currentTimeMillis();
        // Create new Task
        Task newTask = new Task(Subject = 'Test');
        return (Task) assignFields(fieldNameValueMapping, newTask, ins);
    }

    //Code Added for SRSF : 1130

    public static Lead createLead(Map<String, Object> fieldNameValueMapping, Boolean ins){        
        // Create new Lead
        Lead newLead = new Lead();
        return (Lead) assignFields(fieldNameValueMapping, newLead, ins);
    }

    public static Campaign createCampaign(Map<String, Object> fieldNameValueMapping, Boolean ins){  
        // Create new campaign
        Campaign newCmpgn = new Campaign();
        return (Campaign) assignFields(fieldNameValueMapping, newCmpgn, ins);
    }

    //Insert SysCode values. TODO - Parameterised creation of Syscode
    public static Syscode__c createSysCode(boolean isInsert)
    {
        Syscode__c sysCode = new SysCode__c();
        sysCode.isActive__c = true;
        sysCode.Description__c = 'Linear';
        sysCode.Type__c = 'Linear';
        sysCode.Name = 'Linear/News/Sports';
        if(isInsert)
            insert sysCode;
        return sysCode;
    }

    public static void createGlidMapping(User user){

        List<GLIDMapping__c> glidMappingLst = new List<GLIDMapping__c>();
        
        GLIDMapping__c glidMapping = new GLIDMapping__c();
        glidMapping.UserID__c = user.Id;
        glidMapping.IsActive__c = true;
        glidMapping.GLIDName__c = 'Albany NY';
        glidMapping.BudgetDMA__c = 'Albany NY';

        glidMappingLst.add(glidMapping);

        GLIDMapping__c glidMapping1 = new GLIDMapping__c();
        glidMapping1.UserID__c = user.Id;
        glidMapping1.IsActive__c = true;
        glidMapping1.GLIDName__c = 'Minnesota MN';
        glidMapping1.BudgetDMA__c = 'Duluth MN; Rochester MN';
        glidMappingLst.add(glidMapping1);

        insert glidMappingLst;        
    }

    public static Sales_Budget__c createSalesBudget(Date budgetDate,Decimal amount, String budgetLevel,String budgetAE, String accId,String status){
        
        Sales_Budget__c salesBudget = new Sales_Budget__c();
        salesBudget.Broadcast_Month_Date__c = budgetDate;
        if (null == amount){
            amount = 1000;
        }
        salesBudget.Amount__c = amount;
        if (null == budgetLevel || ''.equals(budgetLevel)){
            budgetLevel = 'Linear/News/Sports';
        }
        salesBudget.Product_Line__c = budgetLevel;
        salesBudget.Budget_User__c = budgetAE;
        salesBudget.Advertiser__c = accId;
        if (null != status && !''.equals(status)){
            salesBudget.Status__c = status;
        }
        return salesBudget;
    }

    public static User createLSMUser(boolean doInsert) {
        Map<String,String> TestData = TestDataHelper.fetchDivisions();
        Profile p = [select id from profile where name = 'Master - Local Sales Manager'];
        User user = new User(alias = 'standt', email = 'lsmuser123@charter.com',
            emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
            localesidkey = 'en_US', profileid = p.Id,isActive = true,
            timezonesidkey = 'America/Los_Angeles', username = 'lsmuser123@testorgosius.com',Division__c=TestData.get('Division_c_1'));
        if (doInsert)
            insert user;
        return user;
    }

    public static User createAEUser(boolean doInsert, String emailId, String hrManager) {
        Map<String,String> TestData = TestDataHelper.fetchDivisions();
        Profile p = [select id from profile where name = 'Master - Account Executive'];
        User user = new User(alias = 'standt', email = emailId,
            emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
            localesidkey = 'en_US', profileid = p.Id,isActive = true,
            timezonesidkey = 'America/Los_Angeles', username = emailId,Division__c=TestData.get('Division_c_1'), HR_Manager__c =hrManager);
        if (doInsert)
            insert user;
        return user;
    }

    // SRSF-1897
    public static Support_Request__c createAudienceRequest(String name, String opportunityId)
    {
        
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Audience_Request'];

        Support_Request__c request = new Support_Request__c();
        request.RecordTypeId = rt.Id;
        request.Status__c = 'Draft';
        request.DMA__c = 'Albany NY';
        request.Type_of_Request__c = 'Addressable Audience Approval';        
        request.Flight_Start_Date__c = System.Today();
        request.Flight_End_Date__c = System.Today().addDays(10);
        request.Due_Date__c = System.Today().addDays(10);

        if(String.isBlank(name)){
            name = 'Test Audience Request';
        }
        request.Name = name;

        if (String.isBlank(opportunityId)) {
            Opportunity opp = createopportunity(null,System.today(),null,null,null);
            INSERT opp;   
            opportunityId = opp.Id;
        }
        request.Opportunity__c = opportunityId;

        return request;
    }

    public static void createDataCatalog()
    {
        List<Data_Catalog__c> datacatList = new List<Data_Catalog__c>();
        
        Data_Catalog__c dc1 = new Data_Catalog__c();
        dc1.DISPLAY_TEXT__c = 'Voter Age|55+|POLVOTE55PLUS';
        dc1.Political__c = TRUE;
        dc1.Restricted_Interest__c = FALSE;
        datacatList.add(dc1);

        Data_Catalog__c dc2 = new Data_Catalog__c();
        dc2.DISPLAY_TEXT__c = 'Voter Household Income|$200k+';
        dc2.Political__c = FALSE;
        dc2.Restricted_Interest__c = TRUE;
        datacatList.add(dc2);

        Data_Catalog__c dc3 = new Data_Catalog__c();
        dc3.DISPLAY_TEXT__c = 'Sports|Tennis |TENNIS2021;';
        dc3.Political__c = FALSE;
        dc3.Restricted_Interest__c = FALSE;
        datacatList.add(dc3);

        Data_Catalog__c dc4 = new Data_Catalog__c();
        dc4.DISPLAY_TEXT__c = 'Education|College|COLLGRAD';
        dc4.Political__c = FALSE;
        dc4.Restricted_Interest__c = TRUE;
        datacatList.add(dc4);

        INSERT datacatList;
    } 
}