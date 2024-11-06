@istest
public class TrackCompensationPlanControllerTest {
    
    public static testmethod void testcompensationplan(){
        
         User thisUser=[Select ID,Name from User Where ID=:UserInfo.getUserId()];
        System.runAs(thisUser){
        //create AE User
        User userAE = TestUtil.prepareUser();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Regional Finance'];
        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@mands.com';
        userAE.Budget_type__c = 'Local';
        userAE.Budget_product_Lines__c = 'Linear/News/Sports;';
        userAE.rate_plan_status__c = 'Draft';
        userAE.Rate_Plan_Commit_Date__c =Date.newInstance(2020, 01, 10);
        userAE.Division__c='Central';
        //userAE.HR_Name__c='ans';
        insert userAE;
        
        Profile pro1 = [SELECT Id FROM Profile WHERE Name='Master - Account Executive'];   
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing 001', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = pro1.Id, Firstname='first',
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1224@testorg.com');
        u1.rate_plan_status__c = 'Draft';
        u1.Division__c='Central';
        u1.hr_manager__c=userAE.id;
        u1.Budget_type__c = 'Local';
        u1.Budget_product_Lines__c = 'Linear/News/Sports';
        u1.HR_Level__c=1;
        u1.HR_Email__c='fg@34.com';
        u1.Budget_DMA__c='Austin TX';
        //u1.HR_Name__c='ans';
        insert u1;
        
        Profile pro2 = [SELECT Id FROM Profile WHERE Name='Master - Account Executive'];              
        User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing 001', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = pro2.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser12424@testorg.com');
        u2.rate_plan_status__c = 'Draft';
        u2.Division__c='Central';
        u2.Budget_type__c = 'Local';
        u2.Budget_product_Lines__c = 'Linear/News/Sports';
        u2.Budget_DMA__c='Austin TX';
        //u2.HR_Name__c=u1.id;
        insert u2;
        
        Profile pro3 = [SELECT Id FROM Profile WHERE Name='System Administrator'];         
        User u3 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing 003', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = pro3.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser124242@testorg.com');
        u3.rate_plan_status__c = 'Draft';
        u3.Division__c='Central';
        u3.Budget_type__c = 'Local';
        u3.Budget_product_Lines__c = 'Linear/News/Sports';
        u3.Budget_DMA__c='Austin TX';
        //u3.HR_Name__c=u1.id;
        insert u3;
        
        Profile pro4= [SELECT Id FROM Profile WHERE Name='Master - Account Executive'];     
        User u4 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing 003', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = pro4.Id, FirstName='was',
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1524242@testorg.com');
        u4.rate_plan_status__c = 'Draft';
        u4.Division__c='Central';
        u4.hr_manager__c=userAE.id;
        u4.Budget_type__c = 'Local';
        u4.Budget_product_Lines__c = 'Linear/News/Sports';
        u4.HR_Level__c=1;
        u4.HR_Email__c='fg@34.com';
        //u4.HR_Name__c='ans';
        u4.Budget_DMA__c='Austin TX';
        insert u4;        
        
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
        sb.Amount__c = Integer.valueOf(Label.RatePlanThresholdAmount);
        sb.old_budget_user__c = userAE.Id;
        insert sb;   
         
        //create sales budget simulation
        Sales_Budget_Simulation__c sm=new Sales_Budget_Simulation__c();
        sm.Advertiser__c=acc.id;
        sm.Budget_User__c=u1.Id;
        sm.Amount__c=999;
        sm.Sales_Budget__c=sb.id;
       // sm.Old_Budget_User__c=u2.id;
        sm.From_Budget_user__c=u2.id;
        sm.Broadcast_Month_Date__c=Date.Today();
        sm.HR_Manager__c=userAE.id;
        sm.Product_Line__c='Linear/News/Sports';
        sm.Type__c='Log';
        sm.Budget_Change_Date__c=Date.newInstance(2020, 01, 15);
        sm.External_Id__c = '007'+u1.id+System.today();
        insert sm;
        
        Sales_Budget_Simulation__c sm1=new Sales_Budget_Simulation__c();
        sm1.Advertiser__c=acc.id;
        sm1.Budget_User__c=u1.Id;
        sm1.Amount__c=8888;
        sm1.Sales_Budget__c=sb.id;
        sm1.From_Budget_User__c=u3.id;
        sm1.Broadcast_Month_Date__c=Date.Today();
        sm1.HR_Manager__c=userAE.id;
        sm1.Product_Line__c='Linear/News/Sports';
        sm1.Type__c='Log';
        sm1.Budget_Change_Date__c=Date.newInstance(2020, 01, 15);
        sm1.External_Id__c = '008'+u1.id+System.today();
        insert sm1;
        
        Sales_Budget_Simulation__c sm2=new Sales_Budget_Simulation__c();
        sm2.Advertiser__c=acc.id;
        sm2.Budget_User__c=u4.Id;
        sm2.Amount__c=88898;
        sm2.Sales_Budget__c=sb.id;
        sm2.From_Budget_User__c=u1.id;
        sm2.Broadcast_Month_Date__c=Date.Today();
        sm2.HR_Manager__c=userAE.id;
        sm2.Product_Line__c='Linear/News/Sports';
        sm2.Type__c='Log';
        sm2.Budget_Change_Date__c=Date.newInstance(2020, 01, 15);
        sm2.External_Id__c = '009'+u1.id+System.today();
        insert sm2;
        
        System.RunAs(userAE){
            TrackCompensationPlanController obj=new TrackCompensationPlanController();
            obj.GetTrackCompDetails();
            TrackCompensationPlanController.salesbudgetWrapper s=new TrackCompensationPlanController.salesbudgetWrapper();
        }
        
        System.RunAs(thisUser){
            TrackCompensationPlanController obj=new TrackCompensationPlanController();
            obj.GetTrackCompDetails();
            TrackCompensationPlanController.salesbudgetWrapper s=new TrackCompensationPlanController.salesbudgetWrapper();
        }
        }  }
}