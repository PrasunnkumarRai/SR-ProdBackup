@IsTest
Private class TransferContactTest  {
static testmethod void test() {
    
    User thisUser = [Select ID, Name from User Where ID = :UserInfo.getUserId()];
		System.runAs(thisUser) {
			//create AE User
			User userAE = TestUtil.prepareUser();
			Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Master - Account Executive'];
			userAE.ProfileId = objProfile.Id;
			userAE.Username = 'testae@mands.com';
			userAE.Budget_type__c = 'Local';
			userAE.Budget_product_Lines__c = 'Linear/News/Sports;';
			userAE.rate_plan_status__c = 'Draft';
			insert userAE;

			//create account
			Account acc = TestUtil.getAccountRec();
			acc.primary_commodity__c = 'Auto Aftermarket';
			insert acc;
             
            contact c = new contact();
            c.Email= 'Nishant@t.digital';
            c.LastName = 'Dells labs';
            c.AccountId = acc.id;
            c.Advertiser_Contact_Type__c= 'Agency Contact';
             
               insert c;
            
			//create account team member
			AccountTeammember accTM = new AccountTeammember();
			accTM.UserID = userAE.Id;
			accTM.AccountId = acc.Id;
			accTM.Teammemberrole = 'Other';
			insert accTM;

			//create account share
			Accountshare accShare = new Accountshare();
			accShare.AccountId = acc.Id;
			accShare.UserOrGroupId = userAE.Id;
			accShare.AccountAccessLevel = 'Edit';
			accShare.OpportunityAccessLevel = 'Edit';
			insert accShare;

		

			Account_Transfer_Tool__c ats = new Account_Transfer_Tool__c();
			ats.OwnerId = userAE.Id;
			insert ats;

			Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
			atm.Account__c = acc.Id;
			atm.Account_Transfer_Simulation__c = ats.Id;
			atm.From_User__c = userAE.Id;
			atm.To_User__c = userAE.Id;
			atm.External_ID__c = userAE.Id + ';;;' + acc.Id + ';;;' + '2019Jan' + ';;;' + ats.Id;
			insert atm;

			Admin_Tool_Status_Summary__c adminSummary = new Admin_Tool_Status_Summary__c();
			adminSummary.From_User_Id__c = String.valueOf(userAE.Id);
			adminSummary.To_User_Id__c = String.valueOf(userAE.Id);
			adminSummary.Transfer_Details__c = atm.Id;
			insert adminSummary;
            
            

			List<Admin_Tool_Status_Summary__c> admToolSummaryIDs = [Select ID, To_User_Id__c, From_User_Id__c, Transfer_Details__r.Account_Transfer_Simulation__r.Transfer_Effective_Date__c, Transfer_Details__c,
			                                                        Transfer_Details__r.Account_Transfer_Simulation__r.Id from Admin_Tool_Status_Summary__c where Transfer_Details__r.Account_Transfer_Simulation__c = :ats.id];

			Map<String, Integer> mapOfBcthsize = new Map<String, Integer> ();
			mapOfBcthsize.put('Budget_Batch_Size', 200);
			mapOfBcthsize.put('NBUC_Batch_Size', 200);

             String v=String.valueof(ats.id);
			TransferContactBatch trb = new TransferContactBatch(admToolSummaryIDs,v);
           
			try {
				System.runAs(userAE) {
					Test.startTest();
					Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock> ();
                    WebServiceTestMockBudgetAggregate methodname1 = new WebServiceTestMockBudgetAggregate();
                    endpoint2TestResp.put('http://52.3.208.14:9090/ws/rest/UserSBAgg/invoke_SBAgg/',methodname1);
                    HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
					Test.setMock(HttpCalloutMock.class, multiCalloutMock);
					Database.executeBatch(trb,2);
					Test.stopTest();
				}
			} catch(Exception ex) { }
		}
    /*
    List<Contact> conList = new List<Contact>();
    for (Integer i=0;i<300;i++) {
    contact c = new contact(title = 'contact ' + i);
    c.Email= 'Nishant@t.digital';
         c.LastName = 'Dells labs';
    c.AccountId = '0015500000qMRitAAG';
    c.Advertiser_Contact_Type__c= 'Agency Contact';
    conList.add(c);
    }
    insert conList;

      Test.startTest();
     // TransferContact tC = new  TransferContact  ();
      //Database.executeBatch(tC);
      
      Test.stopTest();

     // Verify accounts updated
    List<Contact> accUpdatedList = [SELECT Id,Name FROM contact];
    System.assert(accUpdatedList[0].Name.Contains('Updated'));
    */
}    
}