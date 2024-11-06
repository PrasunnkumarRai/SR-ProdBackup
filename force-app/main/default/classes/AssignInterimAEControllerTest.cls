/*
###########################################################################
# File..................: AssignInterimAEControllerTest.cls
# Version...............: 1
# Created by............: Sridhar Aluru
# Created Date..........: 30-Jun-2021
# Last Modified by......:
# Last Modified Date....:
# Description...........: This class is used to get the Test coverage for AssignInterimAEController.cls, 
#                         InterimAEAccountTrigger, InterimAEAccountTriggerHelper.cls
# TAO Ref#..............: NA
# Test Class............: 
# Change Log............:
#
############################################################################*/
@isTest
private class AssignInterimAEControllerTest 
{
	static User userLSM;
	static User approvingMgr;
	static User userPrimary;
	static User userInterim;
	static Account acc;
	static Opportunity opp;
	static Opportunity opp1;
	static Interim_AE_Account__c interimAE;

	static void prepareTestData() 
	{
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser)
        {
        	approvingMgr = TestDataHelper.createSystemAdminUser(false);
			approvingMgr.Username = 'ApprovingMgr123@testorg.com';
			approvingMgr.Region__c = 'Northeast';
			INSERT approvingMgr;

	        User userHRMgr = TestDataHelper.createLSMUser(false);
			userHRMgr.Username = 'HRMgr123@testorg.com';
			userHRMgr.Region__c = 'Northeast';
			INSERT userHRMgr;

			userLSM = TestDataHelper.createLSMUser(false);
			userLSM.Region__c = 'Northeast';
			userLSM.Approving_Manager__c = approvingMgr.Id;
			userLSM.ManagerId = approvingMgr.Id;
			userLSM.HR_Manager__c = userHRMgr.Id;		
			INSERT userLSM;	        
    	}
		
		userPrimary = TestDataHelper.createAEUser(true, 'testprimary@charter.com', userLSM.Id);
		userInterim = TestDataHelper.createAEUser(true, 'testinterim@charter.com', userLSM.Id);		

		acc=TestDataHelper.createAdvertiser('Test Advertiser','Central Plaza', 'Hyderabad', 'Telangana', '500085', 'India');
        INSERT acc;

        Accountshare accShare = new Accountshare();
		accShare.AccountId = acc.Id;
		accShare.UserOrGroupId = userPrimary.Id;
		accShare.AccountAccessLevel = 'Edit';
		accShare.OpportunityAccessLevel = 'Edit';
		INSERT accShare;

		AccountTeammember atm = new AccountTeammember();
		atm.AccountId = acc.Id;
		atm.UserId = userPrimary.Id;		
		atm.Teammemberrole = 'Account Executive';
		INSERT atm;

        List<Opportunity> oppList = new List<Opportunity>();
        opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.Id);	
        opp.OwnerId = userPrimary.Id;
        oppList.add(opp);

        opp1 = TestDataHelper.createopportunity('Test Opportunity1',System.today(),'Planning','Pipeline',acc.Id);
        opp1.OwnerId = userPrimary.Id;
        oppList.add(opp1);
        INSERT oppList;

        //create Traffic Id Element for User : SRSF-3821
		Traffic_Id_Element__c trafficElementUser = new Traffic_Id_Element__c();
		trafficElementUser.User__c = Userinfo.getUserId();
		trafficElementUser.AE_ID__c = 1;
		trafficElementUser.Export_System_Id__c = '1';
		trafficElementUser.Traffic_Id__c = '2222';
		trafficElementUser.Tim_System__c = 'St. Louis Local';
		trafficElementUser.Traffic_Type__c = 'User';
		trafficElementUser.Account__c = acc.ID;
		trafficElementUser.ExportSystem_Name__c = 'TWNY';
		insert trafficElementUser;
	}

  	static testMethod void assignInterimAETest() 
  	{
  		String effectiveMonth, getmyUserAccount;
        prepareTestData();

        System.runAs(userLSM) 
        { test.startTest();
	        AssignInterimAEController assignInterim = new AssignInterimAEController();
	        DateTime dt=System.Today().addMonths(1);
	        effectiveMonth = dt.format('YYYYMMM');		
			assignInterim.effectiveMonthYear = effectiveMonth;

				
			AssignInterimAEController.getmyuserlistRemote(userLSM.Id, String.valueOf(userLSM.Id));

			getmyUserAccount = userPrimary.Id + ':::Test1';
			AssignInterimAEController.getmyuserAccountsList(getmyUserAccount);

			String accountIdString = acc.Id + ';;;' + acc.Id + ';;;' + acc.Id + ';;;';  //SRSF-3821
			String[] accArray = accountIdString.split(';;;');
			AssignInterimAEController.loadEclipseIDs(accArray); //SRSF-3821
			
			String accSimRecords = 'tempAccess_'+userLSM.Id+'_'+userLSM.Id+'|||'+userPrimary.Id+';;;'+acc.Id+';;;'+effectiveMonth+';;;'+userLSM.Id+';;;55555 SRNC,55555 SRNY';
			System.debug('accSimRecords in Test Class:: '+accSimRecords);

			System.assertNotEquals(accSimRecords, '');

			AssignInterimAEController.saveInterimAE(accSimRecords);	
			Test.stopTest();			
		}					
			
		Interim_AE_Account__c interimAE = [SELECT Id, Name, Status__c,Processed__c,Ended__c,CreatedDate, SDOF__c FROM Interim_AE_Account__c LIMIT 1];
		System.assertNotEquals(interimAE.Id, null);
		InterimAEAccountTriggerHelper.isFirstTime = true;

		//START: SRSF-3242
		User approver = [SELECT Id FROM User WHERE Username = 'ApprovingMgr123@testorg.com'];
		System.runAs(approver)
        {	
            List<Interim_AE_Account__c> pendingInterimAEs = MassApprovalForInterimAEsController.getInterimAEAccountsList();
            if (!Commonutilities.isListNullOrEmpty(pendingInterimAEs) && pendingInterimAEs.Size()>0){
            	System.assertEquals(1 , pendingInterimAEs.size());
            }

            Map<String, String> interimRecs = new Map<String, String>();
            interimRecs.put(String.valueOf(interimAE.Id), 'Test Approved');
            MassApprovalForInterimAEsController.processApprovalRequest(interimRecs, TRUE);
        }
		//END : SRSF-3242		        
        
        //SRSF-4099
      //  AssignInterimAEController.checkDuplicateTSA(acc.Id, getmyUserAccount, effectiveMonth);
       // System.assert(AssignInterimAEController.isDuplcateTSA);
        
	}
}