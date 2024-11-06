/*
    Author : MAndS
    Date   : 11/05/2017
    Description : test utility class
    Modification History :
*/
public with sharing class TestUtil {
    //to get test user information

    public static User prepareUser(){
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator']; //Profile
        //User related to Profile
        User objUser = new User();
        objUser.Alias = 'Test';
        objUser.Email = 'test.ms@gmail.com';
        objUser.EmailEncodingKey = 'UTF-8';
        objUser.Firstname = 'Johnny';
        objUser.LastName = 'Test';
        objUser.LanguageLocaleKey = 'en_US';
        objUser.LocaleSidKey = 'en_US';
        objUser.TimeZoneSidKey='America/Los_Angeles';
        objUser.ProfileId =objProfile.Id;
        objUser.UserName = uniqueName + '@test' + orgId + '.org';
        return objUser;
    }


    public static User createSalesUser(){
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Sales Vertical']; //Profile
        //User related to Profile
        User objUser = new User();
        objUser.Alias = 'Test11';
        objUser.Email = 'test11.ms@gmail.com';
        objUser.EmailEncodingKey = 'UTF-8';
        objUser.LastName = 'Test11';
        objUser.LanguageLocaleKey = 'en_US';
        objUser.LocaleSidKey = 'en_US';
        objUser.TimeZoneSidKey='America/Los_Angeles';
        objUser.ProfileId =objProfile.Id;
        objUser.UserName='testsales11@mands.com';
        insert objUser;
        return objUser;
    }

     public static User createAEUser(){
        List<Profile> profList = [SELECT Id,Name FROM Profile WHERE Name like '%Account Executive%'];
        if (profList.size() > 0) {
             //User related to Profile
            User objUser = new User();
            objUser.Alias = 'Test1';
            objUser.Email = 'test1.ms@gmail.com';
            objUser.EmailEncodingKey = 'UTF-8';
            objUser.LastName = 'Test1';
            objUser.LanguageLocaleKey = 'en_US';
            objUser.LocaleSidKey = 'en_US';
            objUser.TimeZoneSidKey='America/Los_Angeles';
            objUser.ProfileId =profList[0].Id;
            objUser.UserName='testsales1@mands.com';
            insert objUser;
            return objUser;
        }
        return null;
    }


    //to get test Account information
    public static Account getAccountRec(){
        Account objAcc = new Account ();
        objAcc.Name = 'Test Account Owner Change';
        objAcc.BillingStreet = 'Valley';
        objAcc.BillingCity = 'dallas';
        objAcc.BillingState = 'TX';
        objAcc.BillingCountry = 'us';
        objAcc.BillingPostalCode = '75432';
        objAcc.Skip_Address_Validation__c = true;
        objAcc.Last_Client_Schedule_Date__c = Date.today();
        objAcc.Primary_Commodity__c = 'Alcoholic Beverages';
        return objAcc;
    }

    //to get test Account information
    public static Account getAgencyAccountRec(){
        Account objAcc = new Account ();
        objAcc.Name = 'Test Account Owner Change1';
        objAcc.BillingStreet = 'Valley1';
        objAcc.BillingCity = 'dallas1';
        objAcc.BillingState = 'TX';
        objAcc.BillingCountry = 'us';
        objAcc.BillingPostalCode = '75433';
        objAcc.Skip_Address_Validation__c = true;
        objAcc.Phone = '9848012345';
        objAcc.Approval_Status__c = 'Approved';
        objAcc.Credit_Status__c = 'Pending';
        objAcc.Active__c = true;
        objAcc.Agency__c = objAcc.Id;
        //list<RecordType> lst = [select id from RecordType where name='Agency Account' and sobjecttype='Account'];
        Id AccRId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        if(AccRId!=null){
            objAcc.RecordTypeId = AccRId;
        }
        return objAcc;
    }

    //to get test Contact information
    public static Contact getContactRec(String strAccId,String strEmail){
        Contact objCon = new Contact();
        objCon.LastName = 'Test LN';
        objCon.Email = strEmail;
        objCon.AccountId = strAccId;
        return objCon;
    }

    //to get test account team member information
    public static AccountTeamMember getAccountTeamMemRec(string strAccId, string strUserId){
        AccountTeamMember objAccTM = new AccountTeamMember ();
        objAccTM.AccountId = strAccId;
        objAccTM.TeamMemberRole = 'Account Executive';
        objAccTM.UserId = strUserId;
        return objAccTM;
    }

    //to get test UserTeamMember
    public static UserTeamMember getUserTeamMember(){
        UserTeamMember obj = new UserTeamMember();
        obj.OpportunityAccessLevel = 'Edit';
        obj.UserId = UserInfo.getUserId();
        obj.TeamMemberRole = 'Update';
        return obj;
    }

    //to get test account request information
    public static Account_Request__c getAccountRequestRec(string strAccId, string strUserId, string strRecTypeId){
        Account_Request__c objAR = new Account_Request__c();
        objAR.RecordTypeId = strRecTypeId;
        objAR.Status__c = 'New';
        objAR.Advertiser_Agency_Rep_Firm__c = strAccId;
        objAR.New_Account_Owner__c = strUserId;
        return objAR;
    }

    //to get test opportunity information
    public static Opportunity getOpportunityRec(string strAccId){
        Opportunity objOpp = new Opportunity ();
        objOpp.Name = 'Test Opportunity';
        objOpp.AccountId = strAccId;
        //objOpp.Agency__c = strAccId;
        objOpp.Agency_Account__c = strAccId;
        objOpp.CloseDate = date.today();
        objOpp.StageName = 'Identification';
        objOpp.ForecastCategoryName = 'Omitted';
        objOpp.Type = 'New Business';
        objOpp.Probability = 10;
        objOpp.DMA__c = 'Albany NY';
        return objOpp;
    }

    //to get test account team member information
    public static OpportunityTeamMember getOpportunityTeamMemRec(string strOppId, string strUserId){
        OpportunityTeamMember objOppTM = new OpportunityTeamMember ();
        objOppTM.OpportunityId = strOppId;
        objOppTM.TeamMemberRole = 'Account Executive';
        objOppTM.UserId = strUserId;
        return objOppTM;
    }

    //to get test lead information
    public static Lead getLeadRec(){
        Lead objLead = new Lead ();
        objLead.LastName = 'Test Lead';
        objLead.FirstName = 'Test Lead1';
        objLead.Company ='Test Account';
        objLead.Status = 'Converted';
        objLead.Street = 'test';
        objLead.City = 'test';
        objLead.State = 'test';
        objLead.Country = 'test';
        objLead.PostalCode = 'test';
        return objLead;
    }

    //to get Proposal information
    public static Proposal__c getProposal(string strAccId, String strOppId){
        Proposal__c objPro = new Proposal__c();
        objPro.Opportunity__c = strOppId;
        objPro.Advertiser__c = strAccId;
        objPro.Agency__c = strAccId;
        objPro.Start_Date__c = Date.today();
        objPro.End_Date__c = Date.today()+1;
        //list<RecordType> lst = [select id from RecordType where name!='Opportunity Budget' and sobjecttype='Proposal__c'];
        Id proposalId = Schema.SObjectType.Proposal__c.getRecordTypeInfosByName().get('Opportunity Budget').getRecordTypeId();
        if(proposalId!=null){
            objPro.RecordTypeId = proposalId;
        }
        return objPro;
    }

    //to get Digital Campaign Information
    public static Digital_Campaign__c getDigitalCampaign(string strAccId, String strOppId, String strProposalId){
        String strRecId = [Select Id From RecordType where sobjecttype = 'Digital_Campaign__c' and name='Display'].Id;
        Digital_Campaign__c objDC = new Digital_Campaign__c();
        objDC.RecordTypeId = strRecId;
        objDC.Status__c = '01 Draft Campaign';
        objDC.Campaign_Name__c = 'Test Camp';
        objDC.Advertiser__c = strAccId;
        objDC.Opportunity__c = strOppId;
        objDC.Proposal__c = strProposalId;
        objDC.Campaign_Start_Date__c = Date.today();
        objDC.Campaign_End_Date__c = Date.today()+1;
        objDC.Gross_Campaign_Cost__c = 12;
        objDC.Brand__c = 'Acura';
        objDC.Address__c = 'testS, testC, TX, 500082|Conquest|150';
        objDC.Audience_Interests__c = 'Int1';
        objDC.AudienceTrak_Proposal_ID__c = '123451234512345';
        objDC.Account_Executive__c = Userinfo.getUserId();
        return objDC;
    }

    //to get Digital_Creative__c information
    public static Digital_Creative__c getDigitalCreative(string strDCId){
        Digital_Creative__c obj = new Digital_Creative__c();
        obj.Digital_Campaign__c = strDCId;
        obj.Creative_Name__c = 'test1';
        obj.Creative_Start_Date__c = date.today();
        obj.Creative_End_Date__c = date.today()+1;
        obj.Creative_Location__c = 'Audience Trak';
        obj.Click_Through_URL__c = 'www.test.com';
        return obj;
    }

    //to get Zipcode_Mapping__c information
    public static Zipcode_Mapping__c getDigitalZipcodeMapping(){
        Zipcode_Mapping__c objDZM = new Zipcode_Mapping__c();
        objDZM.Congressional_District_Name__c = 'Cng1';
        objDZM.DigA_Zone__c = 'DigA1';
        objDZM.Nielsen_DMA_Name__c = 'DMA1';
        objDZM.SR_Zone_Name__c = 'Zone1';
        objDZM.SR_Zone_Syscode__c = '123';
        objDZM.Zip_List__c = 'Cng1,DigA1,DMA1,Zone1';
        return objDZM;
    }

    //to get CNA information
    public static CNA__c getCNA(string accId){
        CNA__c objCNA = new CNA__c();
        objCNA.Account__c = accId;
        return objCNA;
    }

    //create test Sales Revenue instance
    public static Sales_Revenue__c getSalesRevenueRec(User testUser, Account acc, Date bDate){
        Sales_Revenue__c sr = new Sales_Revenue__c();
        sr.advertiser__c = acc.id;
        sr.Customer_Number__c = '007';
        sr.revenue_user__c = testUser.id;
        sr.Account_Executive__c = testUser.id;
        sr.Amount__c=999;
        sr.Primary_Commodity__c='Auto Aftermarket';
        sr.Product_Line__c='Linear/News/Sports';
        sr.Revenue_Type_Code__c='Local Spot';
        sr.Broadcast_Month_Date__c = bDate;
        sr.External_Id__c = '007'+testUser.id+bDate;
        return sr;
    }
    
    public static Revenue__c getRevenueRec(User testUser, Account acc, Date bDate){
        Revenue__c sr = new Revenue__c();
        sr.advertiser__c = acc.id;
        sr.Customer_Number__c = '007';
        sr.Account_Executive__c = testUser.id;
        //sr.Amount__c=999;
        sr.Primary_Commodity__c='Auto Aftermarket';
        sr.Product_Line__c='National Spot (NCC)';
        //sr.Revenue_Type_Code__c='Local Spot';
        sr.Broadcast_Month_Date__c = bDate;
        //sr.External_Id__c = '007'+testUser.id+bDate;
        sr.Budget_DMA__c = 'St Louis MO';
        return sr;
    }

    //create test Sales Budget instance
    public static Sales_Budget__c getSalesBudgetRec(User testUser, Account acc){
        Sales_Budget__c sb = new Sales_Budget__c();
        sb.advertiser__c = acc.id;
        sb.Budget_user__c = testUser.id;
        sb.Amount__c=999;
        sb.Commodity__c='Auto Aftermarket';
        sb.Product_Line__c='National Spot (NCC)';
        sb.Broadcast_Month_Date__c = System.today().addYears(1);
        sb.External_Id__c = '007'+testUser.id+System.today().addYears(1);
        return sb;
    }

    //create test Sales Budget Approval instance
    public static Sales_Budget_Approval__c getSalesBudgetApprovalRec(User testUser, Sales_Budget__c sb){
    Sales_Budget_Approval__c sba = new Sales_Budget_Approval__c();
    sba.Sales_Budget__c = sb.Id;
        sba.Approver__c = testUser.Id;
    sba.Status__c = 'Forecast Pending';
        return sba;
    }
    //Create test Sales Revenue Aggregate instance
    public static Sales_Revenue_Aggregate__c generateSalesRevenueAgg(String accountExecutiveId) {
    Sales_Revenue_Aggregate__c sra = new Sales_Revenue_Aggregate__c();
        sra.SalesRevenue_AccountExecutive__c = accountExecutiveId;
        sra.January_Revenue__c = 100;
        sra.February_Revenue__c = 100;
        sra.March_Revenue__c = 100;
        sra.April_Revenue__c = 100;
        sra.May_Revenue__c = 100;
        sra.June_Revenue__c = 100;
        sra.July_Revenue__c = 100;
        sra.August_Revenue__c = 100;
        sra.September_Revenue__c = 100;
        sra.October_Revenue__c = 100;
        sra.November_Revenue__c = 100;
        sra.December_Revenue__c = 100;
        sra.External_Id__c = '007'+accountExecutiveId+System.today();
        return sra;
    }
    //Create test Revenue instance
    public static Revenue__c generateRevenue(String accountExecutiveId, String advertiserId, Date bMD) {
        Revenue__c r = new Revenue__c();
        r.Account_Executive__c = accountExecutiveId;
        r.Advertiser__c = advertiserId;
        r.Actual_Gross_Amount__c = 100;
        r.Broadcast_Month_Date__c = bMD;
        return r;
    }
    public static List<Networks__c> getNetworks(){
        List<Networks__c> netwworks = new List<Networks__c>();
        netwworks.add(new Networks__c(Name = 'AMC', Call_Letter__c = 'AMC', 
                                    AdsE_Genre_s__c ='All Networks;Men/Sports;Selected Networks',
                                    Kids_Network_Exclusion__c = false,  Tune_In_Exclusions__c = false,
                                    ActiveNetwork__c = true, Frequence_Activated__c = true));
        netwworks.add(new Networks__c(Name = 'ESPN', Call_Letter__c = 'ESPN', 
                                     AdsE_Genre_s__c ='All Networks;Men/Sports;Selected Networks',
                                     Kids_Network_Exclusion__c = false,  Tune_In_Exclusions__c = false ,
                                      ActiveNetwork__c = true, Frequence_Activated__c = true));
        netwworks.add(new Networks__c(Name = 'AFRO', Call_Letter__c = 'Bravo', 
                                     AdsE_Genre_s__c ='All Networks;Women/Entertainment;Selected Networks',
                                     Kids_Network_Exclusion__c = false,  Tune_In_Exclusions__c = false,     
                                     ActiveNetwork__c = false, Frequence_Activated__c=false ));    

        return netwworks;
    }
}