@IsTest
private class AddOppTeamMembersBatchTest {
    
    @IsTest
    static void testAddOppTeamMembersBatch() {
        User userObj = TestDataHelper.createUser(true);
        System.debug('userObj in addATM ::: ' + userObj);
        
        List<Account> accList = new List<Account>();
        Account accObj = TestUtil.getAccountRec();
        accList.add(accObj);
        insert accList;
        System.debug('accList ::: ' + accList);
        //insert accList;
        
        Set<String> setaccountIds = new Set<String>();
        
        for(Account acc: accList){
            setaccountIds.add(acc.Id);
        } 
        System.debug('setaccountIds ::: ' +  setaccountIds);
        
        List<String> accountIds = new List<String>();
        for(Account acc: accList){
            accountIds.add(acc.Id);
        } 
        System.debug('accountIds ::: ' +  accountIds);
        
        Map<String, List<String>> mapOfUserAccount = new Map<String, List<String>>();
        mapOfUserAccount.put(userObj.Id, accountIds);
        
        
        Map<Id, String> oppTeamRoles = new Map<Id, String>();
        oppTeamRoles.put(userObj.Id, 'Planner');
        
        System.debug('accList[0].Id ::: ' + accList[0].Id);
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity oppObj = new Opportunity ();
        oppObj.Name = 'Test Opportunity';
        oppObj.AccountId = accList[0].Id;
        oppObj.CloseDate = date.today();
        oppObj.StageName = 'Identification';
        oppList.add(oppObj);
        insert oppList;
        
        Test.startTest();
        AddOppTeamMembersBatch batch = new AddOppTeamMembersBatch(setaccountIds, mapOfUserAccount, oppTeamRoles);
        Database.executeBatch(batch);
        Test.stopTest();    }
}