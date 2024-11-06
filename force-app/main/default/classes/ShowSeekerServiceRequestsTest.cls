/*
###########################################################################
# File..................: ShowSeekerServiceRequestsTest.cls
# Version...............: 1
# Created by............: Sridhar Aluru
# Created Date..........: 17-June-2020
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: Test Class for 'ShowSeekerServiceRequests.cls'
# TAO Ref#..............: NA
# Change Log............:               
#
#
############################################################################*/
@isTest
private class ShowSeekerServiceRequestsTest {
    static testMethod void prepareTestData() {
        User u = TestDataHelper.createUser(true);
        System.assert(u != null);
       
        /*Profile p = [SELECT Id FROM Profile WHERE Name = 'Master - Account Executive'];
        User ae = new User(Alias = 'aeUser', Email = 'ae123@testorgosius.com',
            EmailEncodingKey = 'UTF-8', Lastname = 'Testing', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = p.Id, IsActive=true,
            TimeZoneSidKey = 'America/Los_Angeles', Username = 'ae123@testorgosius.com',Division__c='Central');*/
        User lsmUser = TestDataHelper.createLSMUser(true);
        User ae = TestDataHelper.createAEUser(false, 'ae123@charter.com', lsmUser.Id);
        ae.Division__c='Central';
        INSERT ae;     

        List<Account> actList = new List<Account>();
        Account act1 = TestDataHelper.createAcc('Test Act1',null,null,null,null,null);
        actList.add(act1);
        Account act2 = TestDataHelper.createAcc('Test Act2',null,null,null,null,null);
        actList.add(act2);
        INSERT actList;

        List<AccountTeamMember> actMembers = new List<AccountTeamMember>();
        AccountTeamMember actMem1 = new AccountTeamMember(AccountId = actList[0].Id, TeamMemberRole = 'Coordinator', UserId = ae.Id);
        actMembers.add(actMem1);
        INSERT actMembers;

        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp1 = TestDataHelper.createopportunity('Test Opp1',null,null,null,actList[0].Id);
        oppList.add(opp1);
        Opportunity opp2 = TestDataHelper.createopportunity('Test Opp2',null,null,null,actList[1].Id);
        oppList.add(opp2);
        INSERT oppList;

        List<OpportunityTeamMember> oppTeamMembers = new List<OpportunityTeamMember>();
        OpportunityTeamMember oppMem1 = new OpportunityTeamMember(OpportunityId= oppList[0].Id, TeamMemberRole = 'Coordinator', UserId = ae.Id);
        oppTeamMembers.add(oppMem1);
        INSERT oppTeamMembers;
    }

    static testMethod void doGetMethodPositivePathTest() {
        String response = ShowSeekerServiceRequests.doGet();
        System.assert(response != null);
    }

    static testMethod void doPostMethodPositivePathTest1() {  

        prepareTestData();
        User u = [SELECT Id, Name FROM User WHERE profile.Name = 'Standard User' AND IsActive=true LIMIT 1 ];
        User ae = [SELECT Id, Name FROM User WHERE profile.Name = 'Master - Account Executive' AND IsActive=true LIMIT 1 ];
        System.assert(u != null);
        System.assert(ae != null);

        List<Account> actList = [SELECT Id,Name FROM Account LIMIT 5];
        System.assert(actList != null);

        ShowSeekerServiceRequests.IncomingRequestWrapper req = new ShowSeekerServiceRequests.IncomingRequestWrapper();
        req.userId = u.Id;
        req.aeId = ae.Id;
        req.objectType = 'Opportunity';
        req.accountIdList = new List<String>();
        for(Account act : actList){
            req.accountIdList.add(act.Id);
        }

        ShowSeekerServiceRequests.ObjectResultWrapper response = ShowSeekerServiceRequests.doPost(req);
        System.assert(response != null);
    }

    static testMethod void doPostMethodPositivePathTest2() {
        prepareTestData();

        User u = [SELECT Id, Name FROM User WHERE profile.Name = 'Standard User' LIMIT 1 ];
        User ae = [SELECT Id, Name FROM User WHERE profile.Name = 'Master - Account Executive'  AND IsActive=true LIMIT 1 ];
        
        List<Account> actList = [SELECT Id,Name FROM Account LIMIT 5];

        ShowSeekerServiceRequests.IncomingRequestWrapper req = new ShowSeekerServiceRequests.IncomingRequestWrapper();
        req.userId = u.Id;
        req.aeId = ae.Id;
        req.objectType = 'test';
        req.accountIdList = new List<String>();
        for(Account act : actList){
            req.accountIdList.add(act.Id);
        }

        ShowSeekerServiceRequests.ObjectResultWrapper response = ShowSeekerServiceRequests.doPost(req);
        System.assert(response != null);        
    }

    static testMethod void doPostMethodPositivePathTest3() {       
        prepareTestData();

        User u = [SELECT Id, Name FROM User WHERE profile.Name = 'Standard User' LIMIT 1 ];
        User ae = [SELECT Id, Name FROM User WHERE profile.Name = 'Master - Account Executive' AND IsActive=true LIMIT 1 ];

        List<Account> actList = [SELECT Id,Name FROM Account LIMIT 5];

        ShowSeekerServiceRequests.IncomingRequestWrapper req = new ShowSeekerServiceRequests.IncomingRequestWrapper();
        req.userId = u.Id;
        req.aeId = ae.Id;
        req.objectType = '';
        req.accountIdList = new List<String>();
        for(Account act : actList){
            req.accountIdList.add(act.Id);
        }

        ShowSeekerServiceRequests.ObjectResultWrapper response = ShowSeekerServiceRequests.doPost(req);
        System.assert(response != null);        
    }

    static testMethod void doPostMethodPositivePathTest5() {
        prepareTestData();
        User u = [SELECT Id, Name FROM User WHERE profile.Name = 'Standard User' LIMIT 1 ];
        User ae = [SELECT Id, Name FROM User WHERE profile.Name = 'Master - Account Executive' AND IsActive=true  LIMIT 1 ];

        ShowSeekerServiceRequests.IncomingRequestWrapper req = new ShowSeekerServiceRequests.IncomingRequestWrapper();
        req.userId = u.Id;
        req.aeId = ae.Id;
        req.objectType = 'Opportunity';
        req.accountIdList = new List<String>();

        ShowSeekerServiceRequests.ObjectResultWrapper response = ShowSeekerServiceRequests.doPost(req);        
        System.assert(response != null);
   }

    static testMethod void doPostMethodPositivePathTest6() {

        prepareTestData();

        User u = [SELECT Id, Name FROM User WHERE profile.Name = 'Standard User' AND IsActive=true LIMIT 1 ];
        
        User ae = [SELECT Id, Name FROM User WHERE profile.Name = 'Master - Account Executive' AND IsActive=true LIMIT 1 ];
        List<Account> actList = [SELECT Id,Name FROM Account LIMIT 5];

        ShowSeekerServiceRequests.IncomingRequestWrapper req = new ShowSeekerServiceRequests.IncomingRequestWrapper();
        req.userId = u.Id;
        req.aeId = ae.Id;
        req.objectType = 'Account';
        req.accountIdList = new List<String>();
        for(Account act : actList){
            req.accountIdList.add(act.Id);
        }

        ShowSeekerServiceRequests.ObjectResultWrapper response = ShowSeekerServiceRequests.doPost(req);        
        System.assert(response != null);
   }

   static testMethod void doPostMethodPositivePathTest7() {

        prepareTestData();

        User u = [SELECT Id, Name FROM User WHERE profile.Name = 'Standard User' LIMIT 1 ];
        User ae = [SELECT Id, Name FROM User WHERE profile.Name = 'Master - Account Executive' AND IsActive=true  LIMIT 1 ];
        
        List<Account> actList = [SELECT Id,Name FROM Account LIMIT 5];

        ShowSeekerServiceRequests.IncomingRequestWrapper req = new ShowSeekerServiceRequests.IncomingRequestWrapper();
        req.userId = u.Id;
        req.aeId = ae.Id;
        req.objectType = 'Opportunity';
        req.accountIdList = new List<String>();
        for(Account act : actList){
            req.accountIdList.add(act.Id);
        }

        ShowSeekerServiceRequests.ObjectResultWrapper response = ShowSeekerServiceRequests.doPost(req);        
        System.assert(response != null);        
    }

    static testMethod void doPostMethodPositivePathTest8() {

        prepareTestData();

        List<User> usrList = [SELECT Id, Name FROM User WHERE IsActive = true AND profile.Name = 'Master - Account Executive' AND IsActive=true LIMIT 1];

        List<Account> actList = [SELECT Id,Name FROM Account LIMIT 5];

        ShowSeekerServiceRequests.IncomingRequestWrapper req = new ShowSeekerServiceRequests.IncomingRequestWrapper();
        req.userId = usrList.size()>0? usrList[0].Id :'';
        req.aeId = usrList.size()>0? usrList[0].Id :'';
        req.objectType = 'Opportunity';
        req.accountIdList = new List<String>();
        for(Account act : actList){
            req.accountIdList.add(act.Id);
        }

        ShowSeekerServiceRequests.ObjectResultWrapper response = ShowSeekerServiceRequests.doPost(req);        
        System.assert(response != null);        
    }
    
    static testMethod void doPostMethodPositivePathTest9() {

        prepareTestData();

        List<User> usrList = [SELECT Id, Name FROM User WHERE IsActive = true AND profile.Name = 'Master - Account Executive' AND IsActive=true LIMIT 1];

        List<Account> actList = [SELECT Id,Name FROM Account LIMIT 5];

        ShowSeekerServiceRequests.IncomingRequestWrapper req = new ShowSeekerServiceRequests.IncomingRequestWrapper();
        req.userId = usrList.size()>0? usrList[0].Id :'';
        req.aeId = usrList.size()>0? usrList[0].Id :'';
        req.objectType = 'Opportunity';
        req.accountIdList = null;
        
        ShowSeekerServiceRequests.ObjectResultWrapper response = ShowSeekerServiceRequests.doPost(req);
        System.assert(response != null);        
    } 
}