@IsTest
public class TrackCompensationPlanCSVControllerTest {
   
@Istest     
static void  testtrackcompensationCSV(){
        
         User thisUser=[Select ID,Name from User Where ID=:UserInfo.getUserId()];
        System.runAs(thisUser){
        //create AE User
        User userAE = TestUtil.prepareUser();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@mands.com';
        userAE.Budget_type__c = 'Local';
        userAE.Budget_product_Lines__c = 'Linear/News/Sports;';
        userAE.rate_plan_status__c = 'Draft';
        userAE.Region__c='Texas';
        userAE.Rate_Plan_Commit_Date__c =Date.newInstance(2019, 01, 10);
        insert userAE;
        
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
        insert sb;
        
        
    
    
        Profile pro1 = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing 001', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = pro1.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1224@testorg.com');
        u1.rate_plan_status__c = 'Draft';
        u1.Region__c='Texas';
        insert u1;
        
        Profile pro2 = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        
        User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing 001', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = pro2.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser12424@testorg.com');
        u2.rate_plan_status__c = 'Draft';
        u2.Region__c='Texas';
        insert u2;
        
        //Map<String,string> userMap = new Map<String,String>();
        Cache.SessionPartition partition = Cache.Session.getPartition('SRPartition');
        List<String> userIds = new List<String>();
        userIds.add(u1.id);
        userIds.add(userAE.id);
        userIds.add(u2.id);
        partition.put('lstUserIdsAllowed', userIds);
        
        PageReference pgRef = Page.TrackCompensationPlanCSV;
       Test.setCurrentPage(pgRef);

        ApexPages.currentPage().getParameters().put('selectedBudgetYear', '2019');
        
        //create sales budget simulation
        Sales_Budget_Simulation__c sm=new Sales_Budget_Simulation__c();
        sm.Advertiser__c=acc.id;
        sm.Budget_User__c=u1.Id;
        sm.Amount__c=9999;
        sm.Sales_Budget__c=sb.id;
        sm.From_Budget_User__c=u2.id;
        sm.Broadcast_Month_Date__c=Date.Today();
        sm.HR_Manager__c=userAE.id;
        sm.Product_Line__c='Linear/News/Sports';
        sm.Type__c='Log';
        sm.Budget_Change_Date__c=Date.newInstance(2019, 05, 15);
        sm.External_Id__c = '007'+u1.id+System.today();
        insert sm;
        
        Sales_Budget_Simulation__c sm1=new Sales_Budget_Simulation__c();
        sm1.Advertiser__c=acc.id;
        sm1.Budget_User__c=u1.Id;
        sm1.Amount__c=8888;
        sm1.Sales_Budget__c=sb.id;
        sm1.From_Budget_User__c=u2.id;
        sm1.Broadcast_Month_Date__c=Date.Today();
        sm1.HR_Manager__c=userAE.id;
        sm1.Product_Line__c='Linear/News/Sports';
        sm1.Type__c='Log';
        sm1.Budget_Change_Date__c=Date.newInstance(2019, 06, 15);
        sm1.External_Id__c = '008'+u1.id+System.today();
        insert sm1;
        
        System.runAs(u1){
        
        
        TrackCompensationPlanCSVController obj=new TrackCompensationPlanCSVController();
        
        Test.startTest();
        TrackCompensationPlanCSVController.salesbudgetWrapper s1=new TrackCompensationPlanCSVController.salesbudgetWrapper();
        //obj.GetTrackCompDetails();
        String v='2019';
        Boolean b=false;
        TrackCompensationPlanCSVController.generateCSV(b,v);
        Test.stopTest();
        }
    }
    
} }