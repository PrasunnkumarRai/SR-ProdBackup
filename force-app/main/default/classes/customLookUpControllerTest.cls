@isTest(SeeAllData =false)
public class customLookUpControllerTest {

  @testSetup static void setup() {
      
      // Test Data creation starts here
     User usr = TestDataHelper.createUser(false);
     usr.Email = 'avangari@osidigital.com';
     insert usr;
    Account acc = TestDataHelper.createAcc(null,null,null,null,null,null);
    insert acc;
    Opportunity opp = TestDataHelper.createopportunity(null,null,null,null,acc.Id);
    insert opp;
    Proposal__c propsl  = TestDataHelper.createProposal('Test Proposal',String.valueOf(opp.Id),null,null);
    propsl.TIM_System__c = 'St. Louis Local';
    //propsl.End_Date__c = System.today().addYears(1);
    insert propsl;
    
    UserConnection__c oldUserConnctn = TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',usr.Id,'', '5');
    oldUserConnctn.Is_Primary__c = true;
    //oldUserConnctn.AE_Id__c = '1';
    insert oldUserConnctn;

    Map<String, Object> taskFieldNameValueMapping = new Map<String, Object>{'OwnerId' => Id.valueOf(UserInfo.getUserId()), 'WhatId' => opp.Id , 'ActivityDate' =>System.today().addYears(2)};
        Task tsk = TestDataHelper.createTask(taskFieldNameValueMapping,true);

        TestDataHelper.createTIMIntegrationCustomSettings();
    UserConnection__c newUserConnection = TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'', '1');
    insert newUserConnection;

    AccountConnection__c accConn = TestDataHelper.createAccountConnection(acc.Id);
    insert accConn;

    String timSystem = 'StLouisLocal';
        String partitionName = 'local.TIMAccess';
        Cache.OrgPartition newpart = new Cache.OrgPartition(partitionName);

        Map<String,TIMUserAccess.User> timuserMap = new Map<String,TIMUserAccess.User>();
    TIMUserAccess.User timUsr = new TIMUserAccess.User();
        timUsr.UID = 2;
        timUsr.UN = 'SFDCUser';
        timUsr.UP = 'us3th3F0RCE!';
        
        timuserMap.put('St. Louis Local', timUsr);

        newpart.put('StLouisLocal', timuserMap);
    
        // Test Data creation ends here

  }
     
   public static testMethod void testAETransfer(){

     Test.startTest();

    Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
    List<Account> accList = customLookUpController.showAccounts(UserInfo.getUserId());

    List<Account> acc = [Select id ,Name FROM Account limit 1];
        System.assert(acc.size()>0);
        
    List<User> usr = [Select Id ,Name  FROM User WHERE Email like 'avangari@charter.com'];
      //  System.assertNotEqual(usr.size()>0,false);

    IF(acc.size()>0 && usr.size()>0){
      List<customLookUpController.OppProposalWrapper>  oppProposalWrapList = customLookUpController.showOpportunities(new List<String>{acc[0].Id},String.valueOf(System.today().addYears(-10)),Id.valueOf(UserInfo.getUserId()));

      for(customLookUpController.OppProposalWrapper oppWrap : oppProposalWrapList){
        oppWrap.chckBx = true;
        System.debug('Record:::'+oppWrap);
      }

      String JSONString = JSON.serialize(oppProposalWrapList);
          String adminummaryId = customLookUpController.AEtransfer(JSONString,usr[0].Id,Id.valueOf(UserInfo.getUserId()), new List<String>{acc[0].Id} ,String.valueOf(System.today().addYears(-1)));
          Admin_Tool_Status_Summary__c adminSummaryRecord = customLookUpController.returnAdminToolStatus(adminummaryId);
        
            List<Admin_Tool_Status_Summary__c> admnSumary = [Select id from Admin_Tool_Status_Summary__c order by createdDate desc];
            if(admnSumary.size()>0){
           System.assertEquals(adminummaryId,admnSumary[0].Id);
               System.assertEquals(adminSummaryRecord.Id,admnSumary[0].Id);
            }

          customLookUpController.AEtransfer(JSONString,Id.valueOf(UserInfo.getUserId()), usr[0].Id, new List<String>{acc[0].Id} ,String.valueOf(System.today().addYears(-1)));
          Delete [SELECT Id FROM UserConnection__c];
          customLookUpController.AEtransfer(JSONString,Id.valueOf(UserInfo.getUserId()), usr[0].Id, new List<String>{acc[0].Id} ,String.valueOf(System.today().addYears(-1)));

      }
      
    List<SObject> sobjList = customLookUpController.fetchLookUpValues('Testing','User', null);
    
     Test.stopTest();

   }
   
}