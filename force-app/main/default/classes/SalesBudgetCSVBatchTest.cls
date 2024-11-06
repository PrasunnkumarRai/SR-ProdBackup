@IsTest
public class SalesBudgetCSVBatchTest {
    
    @Istest     
    static void  salesbudgetCSV(){
        
         User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
         
         User userAE = TestUtil.prepareUser();
        //Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        //userAE.ProfileId = objProfile.Id;
        userAE.HR_Manager__c = thisUser.Id;
        userAE.Username = 'testae@mands.com';
        userAE.Budget_type__c = 'Local';
        userAE.rate_plan_status__c = 'Draft';
        userAE.Budget_product_Lines__c = 'Linear/News/Sports;';
        insert userAE;
        
        //create AE User      
       System.runAs(userAE){
            User userAETo = TestUtil.prepareUser();
            //Profile objProfile1 = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
            //userAETo.ProfileId = objProfile1.Id;
            userAETo.HR_Manager__c = thisUser.Id;
            userAETo.Username = 'testaeTo@mands.com';
            userAETo.Budget_type__c = 'Local';
            userAETo.Budget_product_Lines__c = 'Linear/News/Sports;';
            userAETo.Firstname = 'Test';
            userAETo.rate_plan_status__c = 'Draft';
            userAETo.Lastname = 'User';
            insert userAETo; 
            
         User userAETo2 = TestUtil.prepareUser();
        //userAETo2.ProfileId = objProfile.Id;
        userAETo2.HR_Manager__c = userAETo.Id;
        userAETo2.Username = 'testaeTo2@mands.com';
        userAETo2.Budget_type__c = 'Local';
        userAETo2.Budget_product_Lines__c = 'Linear/News/Sports;';
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
        Sales_Budget__c sb = new Sales_Budget__c();
        sb = TestUtil.getSalesBudgetRec(userAE, acc);
        sb.Type__c = 'Data';
        sb.Product_Line__c='Production';
        sb.Amount__c = Integer.valueOf(Label.RatePlanThresholdAmount);
        sb.old_budget_user__c = userAE.Id;
        sb.Budget_user__c = userAETo.Id;
        sb.Broadcast_Month_Date__c = date.today().addmonths(1);   
        sb.External_Id__c = '008'+userAE.id+System.today();
        insert sb;
        
        Sales_Budget__c sb1 = new Sales_Budget__c();
        sb1 = TestUtil.getSalesBudgetRec(userAETo, acc);
        sb1.Type__c = 'Data';
           sb1.Broadcast_Month_Date__c = date.today().addmonths(1);
        sb1.Product_Line__c='Production';
        sb1.Amount__c = Integer.valueOf(Label.RatePlanThresholdAmount);
        sb1.old_budget_user__c = userAETo.Id;
        sb1.Budget_user__c = userAE.Id;
        sb1.External_Id__c = '007'+userAETo.id+System.today();
        insert sb1;
            
         
        Sales_Budget__c sb2 = new Sales_Budget__c();
        sb2 = TestUtil.getSalesBudgetRec(userAETo2, acc);
        sb2.Type__c = 'Data';
        sb2.Product_Line__c='Digital';
        sb2.Amount__c = Integer.valueOf(Label.RatePlanThresholdAmount);
        sb2.old_budget_user__c = userAETo2.Id;
        sb2.Budget_user__c = userAE.Id;
        sb2.Broadcast_Month_Date__c = date.today().addmonths(1);
           
        sb2.External_Id__c = '009'+userAETo2.id+System.today();
        insert sb2;
        
        Cache.SessionPartition partition = Cache.Session.getPartition('SRPartition');
        List<String> userIds = new List<String>();
        userIds.add(userAETo.id);
        userIds.add(userAE.id);
        userIds.add(userAETo2.id);
        partition.put('lstUserIdsAllowed', userIds);
        
        PageReference pgRef = Page.TrackCompensationPlanCSV;
        Test.setCurrentPage(pgRef);
        
        ApexPages.currentPage().getParameters().put('selectedBudgetYear', '2019');
            
            TrackCompensationPlanCSVController obj=new TrackCompensationPlanCSVController();
            Test.startTest();
            TrackCompensationPlanCSVController.salesbudgetWrapper s1=new TrackCompensationPlanCSVController.salesbudgetWrapper();
            String v='2019';
            Boolean b=false;
            TrackCompensationPlanCSVController.generateCSV(b,v);
           TrackCompensationPlanCSVController.generateCSV(true,v);
            Test.stopTest();
        }
  }
    
   
}