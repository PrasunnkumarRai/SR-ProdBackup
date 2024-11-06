@IsTest
public class BudgetAutomationTest  {
    
        public static testmethod void testGetSalesBudgetData(){

            User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
            Account acc = TestDataHelper.createAdvertiser('Advertiser Account123', '123 Wright Plaza', 'Omaha', 'NE', '681030', 'USA');

            insert acc;

            User userAE1 = TestUtil.prepareUser();
            userAE1.HR_Manager__c = thisUser.Id;
            userAE1.Username = 'testae1234@mands.com';
            userAE1.Budget_type__c = 'National';
            userAE1.rate_plan_status__c = 'Draft';
            userAE1.Budget_product_Lines__c = 'Linear/News/Sports';
            insert userAE1;

            //create Sales Budget
            Sales_Budget__c sb = new Sales_Budget__c();
            sb = TestUtil.getSalesBudgetRec(userAE1, acc);
            sb.Type__c = 'Data';
            sb.Product_Line__c = 'National Spot (NCC)';
            sb.Amount__c = 9000;
            sb.old_budget_user__c = userAE1.Id;
            sb.Budget_user__c = userAE1.Id;
            sb.External_Id__c = '008' + userAE1.id + System.today();
            sb.Broadcast_Month_Date__c = Date.newInstance(Integer.valueOf(Label.Forecast_Automation_Year), 2, 2);
            sb.DMA__c = 'Albany NY';
            insert sb;

            Sales_Budget__c sb1 = new Sales_Budget__c();
            sb1 = TestUtil.getSalesBudgetRec(userAE1, acc);
            sb1.Type__c = 'Data';
            sb1.Product_Line__c = 'National Spot (NCC)';
            sb1.Amount__c = 10000;
            sb1.old_budget_user__c = userAE1.Id;
            sb1.Budget_user__c = userAE1.Id;
            sb1.External_Id__c = '007' + userAE1.id + System.today();
            sb1.Status__c = 'Forecast Intermediate Approval';
            sb1.Broadcast_Month_Date__c = Date.newInstance(Integer.valueOf(Label.Forecast_Automation_Year), 3, 2);
            sb1.DMA__c = 'Albany NY';
            insert sb1;
           

            User userAE2 = TestUtil.prepareUser();
            userAE2.HR_Manager__c = thisUser.Id;
            userAE2.Username = 'testae12345@mands.com';
            userAE2.Budget_type__c = 'National';
            userAE2.rate_plan_status__c = 'Draft';
            userAE2.Budget_product_Lines__c = 'Linear/News/Sports';
            insert userAE2;
            
            Sales_Budget__c sb2 = new Sales_Budget__c();
            sb2 = TestUtil.getSalesBudgetRec(userAE1, acc);
            sb2.Type__c = 'Data';
            sb2.Product_Line__c = 'National Direct Spot';
            sb2.Amount__c = 9000;
            sb2.old_budget_user__c = userAE2.Id;
            sb2.Budget_user__c = userAE1.Id;
            sb2.External_Id__c = '008' + userAE1.id + System.today();
            sb2.Broadcast_Month_Date__c = Date.newInstance(Integer.valueOf(Label.Forecast_Automation_Year), 3, 2);
            sb2.DMA__c = 'Albany NY';
            insert sb2;

            Sales_Budget__c sb3 = new Sales_Budget__c();
            sb3 = TestUtil.getSalesBudgetRec(userAE1, acc);
            sb3.Type__c = 'Data';
            sb3.Product_Line__c = 'Production';
            sb3.Amount__c = 10000;
            sb3.old_budget_user__c = userAE2.Id;
            sb3.Budget_user__c = userAE1.Id;
            sb3.External_Id__c = '007' + userAE1.id + System.today();
            sb3.Status__c = 'Forecast Intermediate Approval';
            sb3.Broadcast_Month_Date__c = Date.newInstance(Integer.valueOf(Label.Forecast_Automation_Year), 4, 2);
            sb3.DMA__c = 'Albany NY';
            insert sb3;

            String userIdsStr = userAE1.Id + ';' + userAE2.Id;
			
            //Use list for mass insert of Sales Budget
            List<Sales_Budget__c> sbList = new List<Sales_Budget__c>{sb,sb1};
                
            //Remove for loop after testing is complete    
            for (Sales_Budget__c sbData : sbList){
                system.debug('Debugger : ' + (String) sbData.Budget_User__c + (String) sbData.Advertiser__c + sbData.DMA__c);
            }
            string strJSON = '';
            Test.startTest();
            strJSON = BudgetAutomation.getSalesBudgetData(userAE1.Id,'1',Label.Forecast_Automation_Year);//Use Label.ForecastYear instead of hard coded 2020
            //strJSON = BudgetAutomation.getSalesBudgetData(userIdsStr,'1;2;3',Label.Forecast_Automation_Year);
            strJSON = BudgetAutomation.getSalesBudgetData(userAE1.Id,'1;2',Label.Forecast_Automation_Year);
			strJSON = BudgetAutomation.createOpportunity(strJSON);
            strJSON = BudgetAutomation.createOppBudget(strJSON);
			strJSON = BudgetAutomation.createProposalZone(strJSON);
            strJSON = BudgetAutomation.createPZMV(strJSON);
            BudgetAutomation.createDetail(userAE1.Id,Label.Forecast_Automation_Year,'Proposal Zone', 'Completed', 2,4);
            Test.stopTest();
            
        }
    
    public static testmethod void testGetNationalUsers(){
        	            User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
            Account acc = TestDataHelper.createAdvertiser('Advertiser Account123', '123 Wright Plaza', 'Omaha', 'NE', '681030', 'USA');

            insert acc;

            User userAE1 = TestUtil.prepareUser();
            userAE1.HR_Manager__c = thisUser.Id;
            userAE1.Username = 'testae1234@mands.com';
            userAE1.Budget_type__c = 'National';
            userAE1.rate_plan_status__c = 'Draft';
            userAE1.Budget_product_Lines__c = 'Linear/News/Sports';
            insert userAE1;
        
        	Sales_Budget__c sb1 = new Sales_Budget__c();
            sb1 = TestUtil.getSalesBudgetRec(userAE1, acc);
            sb1.Type__c = 'Data';
            sb1.Product_Line__c = 'National Spot (NCC)';
            sb1.Amount__c = 10000;
            sb1.old_budget_user__c = userAE1.Id;
            sb1.Budget_user__c = userAE1.Id;
            sb1.External_Id__c = '007' + userAE1.id + System.today();
            sb1.Status__c = 'Forecast Intermediate Approval';
            sb1.Broadcast_Month_Date__c = Date.newInstance(Integer.valueOf(Label.Forecast_Automation_Year), 3, 2);
            sb1.DMA__c = 'Albany NY';
            insert sb1;
            Test.startTest();
                BudgetAutomation.getNationalUsers();
        BudgetAutomation.getForecastGeneratedDetail(userAE1.ID,Label.Forecast_Automation_Year);
            Test.stopTest();
    }
    
    
}