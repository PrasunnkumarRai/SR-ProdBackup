@isTest 
private class SalesBudgetTriggerTest {

	@isTest
	private static void testName() {
	 User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        System.debug('@@u Name '+thisUser.Name);
        Account Advertiser=TestDataHelper.createAdvertiser('Advertiser Account123','123 Wright Plaza', 'Omaha', 'NE', '681030', 'USA');                        
	        insert Advertiser;
			AccountConnection__c accCon = TestDataHelper.createAccountConnection(Advertiser.Id);
			accCon.Tim_ID__c = '5413';
			insert accCon ;
	        System.assert(Advertiser != null);
        
        System.runAs(thisUser){
            //UserConnection__c connection = TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');   
            //insert connection;
        	
	        //Create an account
	        
       
	        
	      //create create Traffic Id Element for Account
	        
	        Traffic_Id_Element__c trafficElementAcc = new Traffic_Id_Element__c();
			trafficElementAcc.Account_TIM_ID__c = Advertiser.ID;
			//trafficElementAcc.User__c = u.ID;
			trafficElementAcc.AE_ID__c = 1;
        	trafficElementAcc.Export_System_Id__c = '1';
        	trafficElementAcc.Traffic_Id__c = '5413';
	        trafficElementAcc.Tim_System__c = 'St. Louis Local';
	        trafficElementAcc.Traffic_Type__c = 'Account';
	        trafficElementAcc.Account__c = Advertiser.ID;
	        trafficElementAcc.ExportSystem_Name__c = 'TWNY';
	        insert trafficElementAcc;   
         
			Sales_Budget__c sb2 = new Sales_Budget__c();
			//sb2 = TestUtil.getSalesBudgetRec(userAETo2, acc);
			sb2.Type__c = 'Data';
			sb2.Product_Line__c='Digital';
			sb2.Eclipse_ID__c = '5413';
			sb2.Eclipse_System__c = 'TWNY';
			sb2.Amount__c = 1000;
			//sb2.old_budget_user__c = userAETo2.Id;
			sb2.Budget_user__c = thisUser.Id;
			sb2.Broadcast_Month_Date__c = date.today().addmonths(1);
           
			sb2.External_Id__c = '009'+thisUser.id+System.today();
			insert sb2;

			sb2.Amount__c = 1010;
			update sb2;
        }
	}
}