@IsTest
public class EmptyRecycleBinBasedOnIdsbatchTest {
	public static testmethod void testEmptyRecycleBinBasedOnIdsbatch()
	{
		Test.startTest();
		User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];

		System.runAs(thisUser) {
			//Create User
			User userAE = TestUtil.prepareUser();
			userAE.HR_Manager__c = thisUser.Id;
			userAE.Username = 'testae@mands.com';
			userAE.Budget_type__c = 'Local';
			userAE.rate_plan_status__c = 'Draft';
			userAE.Budget_product_Lines__c = 'Linear/News/Sports';
			insert userAE;

			User userAETo = TestUtil.prepareUser();
			userAETo.HR_Manager__c = thisUser.Id;
			userAETo.Username = 'testaeTo@mands.com';
			userAETo.Budget_type__c = 'Local';
			userAETo.Budget_product_Lines__c = 'Linear/News/Sports';
			userAETo.Firstname = 'Test';
			userAETo.rate_plan_status__c = 'Draft';
			userAETo.Lastname = 'User';
			insert userAETo;

			User userAETo2 = TestUtil.prepareUser();
			userAETo2.HR_Manager__c = userAETo.Id;
			userAETo2.Username = 'testaeTo2@mands.com';
			userAETo2.Budget_type__c = 'Local';
			userAETo2.Budget_product_Lines__c = 'Linear/News/Sports';
			userAETo2.Firstname = 'Test2';
			userAETo2.rate_plan_status__c = 'Draft';
			userAETo2.Lastname = 'User2';
			insert userAETo2;

			//create account
			Account acc = TestUtil.getAccountRec();
			acc.primary_commodity__c = 'Auto Aftermarket';
			acc.BillingCity = 'dallas';
			acc.BillingState = 'TX';
			acc.BillingCountry = 'us';
			acc.BillingPostalCode = '75432';
			acc.Skip_Address_Validation__c = true;
			acc.Last_Client_Schedule_Date__c = Date.today();
			acc.Primary_Commodity__c = 'Alcoholic Beverages';
			insert acc;

			//create revenue data
			List<Revenue__c>rlist=new list<Revenue__c>();
            
			Revenue__c revenue = TestDataHelper.createRevenue('2222', '3333', System.today().addYears(- 1), 1000, 1000, 0, 0, '1');
			revenue.ContractNumber__c = 1111;
			revenue.Account_Executive__c = userAE.Id;
			revenue.Broadcast_Month_Date__c = System.today();
			revenue.Product_Line__c = 'Linear/News/Sports';
			revenue.Advertiser__c = acc.Id;
			rlist.add(revenue);

			Revenue__c revenue1 = TestDataHelper.createRevenue('5555', '8888', System.today().addYears(- 1), 10000, 10000, 0, 0, '1');
			revenue1.ContractNumber__c = 66666;
			revenue1.Account_Executive__c = userAETo.Id;
			revenue1.Broadcast_Month_Date__c = System.today();
			revenue1.Product_Line__c = 'Linear/News/Sports';
			revenue1.Advertiser__c = acc.Id;
			rlist.add(revenue1);

			Revenue__c revenue2 = TestDataHelper.createRevenue('55556', '88886', System.today().addYears(- 1), 100060, 106000, 0, 0, '1');
			revenue2.ContractNumber__c = 666676;
			revenue2.Account_Executive__c = userAETo2.Id;
			revenue2.Broadcast_Month_Date__c = System.today();
			revenue2.Product_Line__c = 'Linear/News/Sports';
			revenue2.Advertiser__c = acc.Id;
	        rlist.add(revenue2);
            
            insert rList;


			//Add user Id's to the SET
			Set<ID> userIds = new Set<ID> ();
			userIds.add(userAETo.id);
			userIds.add(userAE.id);
			userIds.add(userAETo2.id);

			EmptyRecycleBinBasedOnIdsbatch objRevsbAggregate = new EmptyRecycleBinBasedOnIdsbatch('Select id from Revenue__c where  Account_Executive__c in: userIds', userIds);
			Database.executeBatch(objRevsbAggregate);
			Test.stopTest();
		}
	}
}