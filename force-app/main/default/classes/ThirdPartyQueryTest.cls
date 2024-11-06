@isTest
private class ThirdPartyQueryTest {

    static testMethod void prepareTestData() {
        User u = TestDataHelper.createUser(true);
        System.assert(u != null);

        List<Account> actList = new List<Account>();
        Account act1 = TestDataHelper.createAcc('Test Act1',null,null,null,null,null);
        actList.add(act1);
        Account act2 = TestDataHelper.createAcc('Test Act2',null,null,null,null,null);
        actList.add(act2);
        insert actList;

        List<AccountTeamMember> actMembers = new List<AccountTeamMember>();
        AccountTeamMember actMem1 = new AccountTeamMember(AccountId = actList[0].Id, TeamMemberRole = 'Coordinator', UserId = u.Id);
        actMembers.add(actMem1);
        insert actMembers;

        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp1 = TestDataHelper.createopportunity('Test Opp1',null,null,null,actList[0].Id);
        oppList.add(opp1);
        Opportunity opp2 = TestDataHelper.createopportunity('Test Opp2',null,null,null,actList[1].Id);
        oppList.add(opp2);
        insert oppList;
    }

    static testMethod void doGetMethodPositivePathTest() {
        String response = ThirdPartyQuery.doGet();
        System.assert(response != null);
    }

    static testMethod void doPostMethodPositivePathTest1() {
       
        prepareTestData();

        User u = [SELECT Id, Name FROM User LIMIT 1];
        System.assert(u != null);

        List<Account> actList = [SELECT Id,Name FROM Account LIMIT 2];
        System.assert(actList != null);

        ThirdPartyQuery.IncomingRequestWrapper req = new ThirdPartyQuery.IncomingRequestWrapper();
        req.userID = u.Id;
        req.objectType = 'Opportunity';
        req.accountIdList = new List<String>();
        for(Account act : actList){
            req.accountIdList.add(act.Id);
        }

        ThirdPartyQuery.ObjectResultWrapper response = ThirdPartyQuery.doPost(req);

        System.assert(response != null);

    }

    static testMethod void doPostMethodPositivePathTest2() {
        
        prepareTestData();

        User u = [SELECT Id, Name FROM User LIMIT 1];
        List<Account> actList = [SELECT Id,Name FROM Account LIMIT 2];

        ThirdPartyQuery.IncomingRequestWrapper req = new ThirdPartyQuery.IncomingRequestWrapper();
        req.userID = u.Id;
        req.objectType = 'test';
        req.accountIdList = new List<String>();
        for(Account act : actList){
            req.accountIdList.add(act.Id);
        }

        ThirdPartyQuery.ObjectResultWrapper response = ThirdPartyQuery.doPost(req);

        System.assert(response != null);
        
    }

    static testMethod void doPostMethodPositivePathTest3() {
      
        prepareTestData();

        User u = [SELECT Id, Name FROM User LIMIT 1];
        List<Account> actList = [SELECT Id,Name FROM Account LIMIT 2];

        ThirdPartyQuery.IncomingRequestWrapper req = new ThirdPartyQuery.IncomingRequestWrapper();
        req.userID = u.Id;
        req.objectType = '';
        req.accountIdList = new List<String>();
        for(Account act : actList){
            req.accountIdList.add(act.Id);
        }

        ThirdPartyQuery.ObjectResultWrapper response = ThirdPartyQuery.doPost(req);

        System.assert(response != null);
        
    }

    static testMethod void doPostMethodPositivePathTest5() {
        
        prepareTestData();
        User u = [SELECT Id, Name FROM User LIMIT 1];

        ThirdPartyQuery.IncomingRequestWrapper req = new ThirdPartyQuery.IncomingRequestWrapper();
        req.userID = u.Id;
        req.objectType = 'Opportunity';
        req.accountIdList = new List<String>();

        ThirdPartyQuery.ObjectResultWrapper response = ThirdPartyQuery.doPost(req);

        System.assert(response != null);

   }

    static testMethod void doPostMethodPositivePathTest6() {
      
        prepareTestData();

        User u = [SELECT Id, Name FROM User LIMIT 1];
        List<Account> actList = [SELECT Id,Name FROM Account LIMIT 2];

        ThirdPartyQuery.IncomingRequestWrapper req = new ThirdPartyQuery.IncomingRequestWrapper();
        req.userID = u.Id;
        req.objectType = 'Account';
        req.accountIdList = new List<String>();
        for(Account act : actList){
            req.accountIdList.add(act.Id);
        }

        ThirdPartyQuery.ObjectResultWrapper response = ThirdPartyQuery.doPost(req);

        System.assert(response != null);

   }

   static testMethod void doPostMethodPositivePathTest7() {

        prepareTestData();

        User u = [SELECT Id, Name FROM User LIMIT 1];
        //u.IsActive = true;
        //update u;

        List<Account> actList = [SELECT Id,Name FROM Account LIMIT 2];

        ThirdPartyQuery.IncomingRequestWrapper req = new ThirdPartyQuery.IncomingRequestWrapper();
        req.userID = u.Id;
        req.objectType = 'Opportunity';
        req.accountIdList = new List<String>();
        for(Account act : actList){
            req.accountIdList.add(act.Id);
        }

        ThirdPartyQuery.ObjectResultWrapper response = ThirdPartyQuery.doPost(req);

        System.assert(response != null);
        
    }
    
    static testMethod void doPostMethodPositivePathTest8() {

        prepareTestData();

        List<User> usrList = [SELECT Id, Name FROM User WHERE IsActive = true LIMIT 1];

        List<Account> actList = [SELECT Id,Name FROM Account LIMIT 2];

        ThirdPartyQuery.IncomingRequestWrapper req = new ThirdPartyQuery.IncomingRequestWrapper();
        req.userID = usrList.size()>0? usrList[0].Id :'';
        req.objectType = 'Opportunity';
        req.accountIdList = new List<String>();
        for(Account act : actList){
            req.accountIdList.add(act.Id);
        }

        ThirdPartyQuery.ObjectResultWrapper response = ThirdPartyQuery.doPost(req);

        System.assert(response != null);
        
    }
    
    static testMethod void doPostMethodPositivePathTest9() {

        prepareTestData();

        List<User> usrList = [SELECT Id, Name FROM User WHERE IsActive = true LIMIT 1];    

        ThirdPartyQuery.IncomingRequestWrapper req = new ThirdPartyQuery.IncomingRequestWrapper();
        req.userID = usrList.size()>0? usrList[0].Id :'';
        req.objectType = 'Opportunity';
        req.accountIdList = null;
        
        ThirdPartyQuery.ObjectResultWrapper response = ThirdPartyQuery.doPost(req);

        System.assert(response != null);        
    }   
}