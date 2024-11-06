@IsTest
private class AddAccTeamMemberBatchTest {

    @IsTest
    static void testAddAccTeamMemberBatch() {
        
        User userObj = TestDataHelper.createUser(true);
        System.debug('userObj in addATM ::: ' + userObj);
        
        List<Account> accList = new List<Account>();
        Account accObj = TestUtil.getAccountRec();
        accList.add(accObj);
        insert accList;
        System.debug('accList ::: ' + accList);
        
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
        
        Map<String, List<String>> mapATMData = new Map<String, List<String>>();
        mapATMData.put(userObj.Id, accountIds);
        
        Map<Id, String> atmTeamRoles = new Map<Id, String>();
        atmTeamRoles.put(userObj.Id, 'Planner');
        
        
        Test.startTest();
        AddAccTeamMemberBatch batch = new AddAccTeamMemberBatch(setaccountIds, mapATMData, atmTeamRoles);
        Database.executeBatch(batch);
        Test.stopTest();

    }
}