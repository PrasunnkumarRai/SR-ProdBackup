@isTest
private class TestUtilTestClass {
    
    @IsTest(seeAlldata = false)
    static void generateTestUtilCoverage_USER() {
        insert TestUtil.prepareUser();
        TestUtil.createSalesUser();
        TestUtil.createAEUser();
        TestUtil.getUserTeamMember();
    }
    
    @IsTest(seeAlldata = false)
    static void generateTestUtilCoverage_Account() {
        Account acc = new Account();
        acc = TestUtil.getAccountRec();
        insert acc;
        test.startTest();
       // insert TestUtil.getAgencyAccountRec();
        insert TestUtil.getCNA(acc.Id);
        test.stopTest();
    }
    @IsTest(seeAlldata = false)
    static void generateTestUtilCoverage_Account1() {
        Account acc = new Account();
       
        test.startTest();
        insert TestUtil.getAgencyAccountRec();
        //insert TestUtil.getCNA(acc.Id);
        test.stopTest();
    }
    
    @IsTest(seeAlldata = false)
    static void generateTestUtilCoverage_Contact() {
        Account acc = new Account();
        acc = TestUtil.getAccountRec();
        insert acc;
        insert TestUtil.getContactRec(acc.Id,'test@nomail.com');
    }
    
    @IsTest(seeAlldata = false)
    static void generateTestUtilCoverage_Opportunity() {
        Account acc = new Account();
        acc = TestUtil.getAgencyAccountRec();
        insert acc;
        
        User u = new User();
        u = TestUtil.prepareUser();
        //insert u;
        Opportunity o = new Opportunity();
        o = TestUtil.getOpportunityRec(acc.Id);
        //o.OwnerId = u.Id;
        o.OwnerId = userinfo.getUserId();
        insert o;
        
        insert TestUtil.getOpportunityTeamMemRec(o.Id,o.OwnerId);
    }
    
    @IsTest(seeAlldata = false)
    static void generateTestUtilCoverage_Lead() {
        insert TestUtil.getLeadRec();
    }
    
    @IsTest(seeAlldata = false)
    static void generateTestUtilCoverage_ZipCodeMapping() {
        insert TestUtil.getDigitalZipcodeMapping();
    }
    
    @IsTest(seeAlldata = false)
    static void generateTestUtilCoverage_DC() {
        User u = new User();
        u = TestUtil.prepareUser();
        u.Sales_Office__c = 'Albany 1';
        insert u;
        System.runAs( u ){
            Account acc = new Account();
            acc = TestUtil.getAgencyAccountRec();
            insert acc;
            
            Opportunity o = new Opportunity();
            o = TestUtil.getOpportunityRec(acc.Id);
            o.OwnerId = u.Id;
            insert o;
            
            Proposal__c p = new Proposal__c();
            p = TestUtil.getProposal(acc.Id, o.Id);
            insert p;
            
            Digital_Campaign__c dc = new Digital_Campaign__c();
            dc = TestUtil.getDigitalCampaign(acc.Id, o.Id, p.Id);
            dc.status__c = '01 Draft Campaign';
            dc.Bypass_Apex_Execution__c = true;
            insert dc;
            Test.startTest();
            insert TestUtil.getDigitalCreative(dc.Id);
            Test.stopTest();
        }
    }
    
    @IsTest(seeAlldata = false)
    static void generateTestUtilCoverage_SBA() {
        User u = new User();
        u = TestUtil.prepareUser();
        u.Sales_Office__c = 'Albany 1';
        insert u;
        System.runAs( u ){
            Account acc = new Account();
            acc = TestUtil.getAgencyAccountRec();
            insert acc;
            
            Sales_Budget__c sb = new Sales_Budget__c();
            sb = TestUtil.getSalesBudgetRec(u,acc);
            insert sb;
            
            Sales_Budget_Approval__c sba = new Sales_Budget_Approval__c();
            sba = TestUtil.getSalesBudgetApprovalRec(u,sb);
            insert sba;
        }
        //insert TestUtil.getDigitalCampaign(acc.Id, o.Id, p.Id);
    }
    
    
    
}