@IsTest
public class BudgetAggregateBatchTest {
    public static testmethod void testBudgetAggregate()
    {
        Test.startTest();
        User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(thisUser){
            
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
            acc.primary_commodity__c =   'Auto Aftermarket';        
            acc.BillingCity = 'dallas';
            acc.BillingState = 'TX';
            acc.BillingCountry = 'us';
            acc.BillingPostalCode = '75432';
            acc.Skip_Address_Validation__c = true;
            acc.Last_Client_Schedule_Date__c = Date.today();
            acc.Primary_Commodity__c = 'Alcoholic Beverages';
            insert acc;
            
            //create Sales Budget
			List<Sales_Budget__c> sbList = new List<Sales_Budget__c>();
            Sales_Budget__c sb = new Sales_Budget__c();
            sb = TestUtil.getSalesBudgetRec(userAE, acc);
            sb.Type__c = 'Data';
            sb.Product_Line__c='Production';
            sb.Amount__c = Integer.valueOf(Label.RatePlanThresholdAmount);
            sb.Budget_user__c = userAETo.Id;
            sb.External_Id__c = '008'+userAE.id+System.today();
			sb.Broadcast_Month_Date__c = Date.today().addMonths(-1);
            sbList.add( sb);
            
            Sales_Budget__c sb1 = new Sales_Budget__c();
            sb1 = TestUtil.getSalesBudgetRec(userAETo, acc);
            sb1.Type__c = 'Data';
            sb1.Product_Line__c='Production';
			sb1.Broadcast_Month_Date__c = Date.today();
            sb1.Amount__c = 10000;
            sb1.old_budget_user__c = userAETo.Id;
            sb1.Budget_user__c = userAE.Id;
            sb1.External_Id__c = '007'+userAETo.id+System.today();
           sbList.add( sb1);
            
            Sales_Budget__c sb11 = new Sales_Budget__c();
            sb11 = TestUtil.getSalesBudgetRec(userAETo, acc);
            sb11.Type__c = 'Data';
            sb11.Product_Line__c='Production';
			sb11.Broadcast_Month_Date__c = Date.today().addMonths(-2);
            sb11.Amount__c = 100;
            sb11.old_budget_user__c = userAETo.Id;
            sb11.Budget_user__c = userAE.Id;
            sb11.External_Id__c = '001'+userAETo.id+System.today().addMonths(-2);
           sbList.add( sb11);            
            
			Sales_Budget__c sbd = new Sales_Budget__c();
            sbd = TestUtil.getSalesBudgetRec(userAE, acc);
            sbd.Type__c = 'DOS';
            sbd.Product_Line__c='Production';
            sbd.Amount__c = Integer.valueOf(Label.RatePlanThresholdAmount);
            sbd.Budget_user__c = userAETo.Id;
            sbd.External_Id__c = '018'+userAE.id+System.today();
			sbd.Broadcast_Month_Date__c = Date.today().addMonths(-5);
            sbList.add( sbd);

            Sales_Budget__c sb2 = new Sales_Budget__c();
            sb2 = TestUtil.getSalesBudgetRec(userAETo2, acc);
            sb2.Type__c = 'Data';
			sb2.Broadcast_Month_Date__c = Date.today().addMonths(1);
            sb2.Product_Line__c='Production';
            sb2.Amount__c = 9000;
            sb2.old_budget_user__c = userAETo2.Id;
            sb2.Budget_user__c = userAE.Id;
            sb2.External_Id__c = '009'+userAETo2.id+System.today();
            sbList.add( sb2);
			insert sbList;
            
            //Add user Id's to the SET
            Set<ID> userIds = new Set<ID>();
            userIds.add(userAETo.id);
            userIds.add(userAE.id);
            userIds.add(userAETo2.id);
            
            BudgetAggregatebatch objBAggregate = new BudgetAggregatebatch('',userIds,false);
				
			DateTime tobeWorked = Datetime.now();
			String hour = String.valueOf(tobeWorked.hour());
			String min = String.valueOf(tobeWorked.minute()); 
			String ss = String.valueOf(tobeWorked.second());
			String nextScheduledTime = ss + ' ' + min + ' ' + hour + ' * * ?';
			BudgetAggregateBatchScheduler m = new BudgetAggregateBatchScheduler(userIds);
			String sch = '20 30 8 10 2 ?';
			String jobID = system.schedule('Schedule for BudgetAggragetBatch_Test', sch, m);		
			//String jobID = system.schedule('SB Aggregate-', nextScheduledTime, sbas);
	        Database.executeBatch(objBAggregate);
            Test.stopTest();
        }
    }
	 
}