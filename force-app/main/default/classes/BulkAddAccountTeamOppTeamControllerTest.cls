@isTest
public class BulkAddAccountTeamOppTeamControllerTest {
    
    @testSetup
    static void setupTestData() {
        
        /*User userObj = new User();
userObj.FirstName = 'John';
userObj.LastName = 'Doe';
userObj.Email = 'johndoe@example.com';
// userList.add(userObj);
insert userObj;
*/
        
    }
    
    @isTest public static void getUserListViewTest(){
        
        List<String> columns = new List<String>{'Central_Division', 'East_Division', 'West_Division'};
            
            Test.startTest();
        BulkAddAccountTeamOppTeamController.getUserListView();
        Test.stopTest();
    }
    
    @isTest public static void getListViewDataTest(){
        
        List < ListView > listViewList = new List < ListView > ();
        listViewList = [SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, IsSoqlCompatible
            FROM ListView WHERE SobjectType = 'User'
            AND DeveloperName IN('Central_Division', 'East_Division', 'West_Division')
        ];
        System.debug('listViewList ::: ' + listViewList);
        
        List<BulkAddAccountTeamOppTeamController.UsersDetails> userDetails = new List<BulkAddAccountTeamOppTeamController.UsersDetails>();
        BulkAddAccountTeamOppTeamController.UsersDetails userDetailsObj = new BulkAddAccountTeamOppTeamController.UsersDetails();
        
        BulkAddAccountTeamOppTeamController.sessionId = 'mockSessionId1234';
       
        String json = '{"size": 2, "records": [{"columns": [{"value": "Value 1", "fieldNameOrPath": "Field1"}]}], "label": "Label", "id": "123", "done": true, "developerName": "DevName", "columns": [{"type": "Type", "sortable": true, "sortIndex": 1, "sortDirection": "ASC", "selectListItem": "Select", "searchable": true, "label": "ColumnLabel", "hidden": false, "fieldNameOrPath": "Field", "descendingLabel": "Desc", "ascendingLabel": "Asc"}]}';   
      
        
        
        Test.setMock(HttpCalloutMock.class, new MyMockHttpResponseGenerator(json));
        User userObj = TestDataHelper.createUser(true);
        System.debug('userObj in addATM ::: ' + userObj);
        
        // Set values for the properties
        userDetailsObj.userName = 'johndoe@example.com';
        userDetailsObj.name = 'John Doe';
        userDetailsObj.email = 'johndoe@example.com';
        userDetailsObj.profileName = 'Standard User';
        //userDetailsObj.division = 'Sales';
        userDetailsObj.Id = userObj.Id;
        userDetailsObj.teamRole = 'Planner';
        
       // userDetails = BulkAddAccountTeamOppTeamController.getListViewData(listViewList[0].Id,2);
        
        Test.startTest();
         BulkAddAccountTeamOppTeamController.getListViewData(listViewList[0].Id,2);
        Test.stopTest();
    }   
    
    private class MyMockHttpResponseGenerator implements HttpCalloutMock {
        private String expectedContent;
        
        public MyMockHttpResponseGenerator(String expectedContent) {
            this.expectedContent = expectedContent;
        }
        
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(expectedContent);
            return res;
        }
    }
    
    
    @isTest public static void getUserProfilesTest(){
        Test.startTest();
        BulkAddAccountTeamOppTeamController.getUserProfiles();
        Test.stopTest();
    }
    
    @isTest public static void AddAtmTest(){
        
        Account accObj = TestUtil.getAccountRec();
        insert accObj;
        System.debug('accObj ::::' + accObj);
        System.debug('accountId ::: ' + accObj.Id);
        
        List<AccountTeamMember> accountTeamMemberList = new List<AccountTeamMember>();
        
        AccountTeamMember newATM = new AccountTeamMember();
        newATM.AccountId = accObj.Id;
        newATM.UserId = UserInfo.getUserId();
        newATM.TeamMemberRole = 'Planner';
        newATM.AccountAccessLevel  = 'Edit';
        accountTeamMemberList.add(newATM);
        insert accountTeamMemberList;
        
        
        Test.startTest();
        BulkAddAccountTeamOppTeamController.AddAtm(accountTeamMemberList);
        Test.stopTest();
    }
    
    
    @isTest public static void AddAtmUsingBatchTest(){
        
        User userObj = TestDataHelper.createUser(true);
        System.debug('userObj in addATM ::: ' + userObj);
        
        List<Account> accList = new List<Account>();
        Account accObj = TestUtil.getAccountRec();
        accList.add(accObj);
        insert accList;
        
        List<String> accountIds = new List<String>();
        
        for(Account acc: accList){
            accountIds.add(acc.Id);
        } 
        System.debug('accountIds ::: ' +  accountIds);
        
        Map<String, List<String>> mapATMData = new Map<String, List<String>>();
        mapATMData.put(userObj.Id, accountIds);
        
        Map<Id, String> mapATMTeamRole = new Map<Id, String>();
        mapATMTeamRole.put(userObj.Id, 'Planner');
        
        Test.startTest();
        BulkAddAccountTeamOppTeamController.AddAtmUsingBatch(mapATMData, mapATMTeamRole);
        Test.stopTest();
    }
    
    @isTest
    public static void AddOtm(){
        
        User userObj = TestDataHelper.createUser(true);
        System.debug('userObj in OTM ::: ' + userObj);
        List<Account> accList = new List<Account>();
        Account accObj = TestUtil.getAccountRec();
        accList.add(accObj);
        insert accList;
        List<String> accountIds = new List<String>();
        for(Account acc: accList){
            accountIds.add(acc.Id);
        } 
        System.debug('accountIds ::: ' +  accountIds);
        Map<String, List<String>> mapOTMData = new Map<String, List<String>>();
        mapOTMData.put(userObj.Id, accountIds);
        Map<Id, String> mapOTMTeamRole = new Map<Id, String>();
        mapOTMTeamRole.put(userObj.Id, 'Planner');
        
        Test.startTest();
        BulkAddAccountTeamOppTeamController.AddOtm(mapOTMData, mapOTMTeamRole);
        Test.stopTest();
    }
    
    
}