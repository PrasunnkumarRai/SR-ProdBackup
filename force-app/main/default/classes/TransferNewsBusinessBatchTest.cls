@isTest(SeeAllData=false)
public class TransferNewsBusinessBatchTest {
     @isTest
     public static  void testsalessimulation()
    {  
         Account acc = TestUtil.getAccountRec();
        acc.primary_commodity__c =   'Auto Aftermarket';
        insert acc;
        List<Test_Data_Utility__mdt> ucList = new List<Test_Data_Utility__mdt>();
        
        Map<String,String> TestData = new Map<String, String>();
        
         ucList = [Select DeveloperName, label from Test_Data_Utility__mdt ];
        for(Test_Data_Utility__mdt abcd : ucList)
        {
            TestData.put(abcd.DeveloperName, abcd.label);
        }
       system.debug('TestData=-=====> '+ TestData.get('Region_c_1'));
        
        User userAE = TestUtil.prepareUser();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@mands.com';
        userAE.Budget_type__c = 'Local';
        userAE.Budget_product_Lines__c = 'Linear/News/Sports';
        userAE.rate_plan_status__c = 'Draft';
        userAE.Rate_Plan_Commit_Date__c =Date.newInstance(2019, 01, 10);
        userAE.Region__c=TestData.get('Region_c_1');
       // userAE.HR_Name__c='ans';
        insert userAE;

        
        Profile pro2 = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        
		User u2 = TestUtil.prepareUser();
        //Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        u2.ProfileId = objProfile.Id;
        u2.Username = 'testu2@mands.com';
        u2.Budget_type__c = 'Local';
        u2.Budget_product_Lines__c = 'Linear/News/Sports';
        u2.rate_plan_status__c = 'Draft';
        u2.Rate_Plan_Commit_Date__c =Date.newInstance(2019, 01, 10);
        u2.Region__c=TestData.get('Region_c_1');
       // userAE.HR_Name__c='ans';
        insert u2;
        
		System.debug(u2.Name);
        Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
        att.Division__c = TestData.get('Division_c_1');
        att.Region__c = TestData.get('Region_c_1');
        att.Status__c = 'Approved';
        att.Transfer_Effective_Date__c = Date.newInstance(2018, 01, 15);
        insert att;
        
         /*Account_Transfer_Tool__c att1 = new Account_Transfer_Tool__c();
        att.Division__c = 'Central';
        att.Region__c = 'MidNorth';
        att.Status__c = 'Pending';
        att.Transfer_Effective_Date__c = Date.newInstance(2018, 02, 15);
        insert att1;*/
        
        Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
        atm.Account__c = acc.Id;
        atm.Account_Transfer_Simulation__c = att.Id;
        atm.From_User__c = userAE.Id;
        atm.To_User__c = u2.Id;
		atm.Count_of_NBUC_Success__c = 0;
        atm.External_ID__c = Userinfo.getUserId()+';;;'+acc.Id+';;;'+'2018Jan'+';;;'+Userinfo.getUserId();
        insert atm;
        
        Account_Transfer_Tool__c ats = new Account_Transfer_Tool__c();
        insert ats;
        List<Admin_Tool_Status_Summary__c>adminToolSmry=new list<Admin_Tool_Status_Summary__c>();
        
        Admin_Tool_Status_Summary__c ob = new Admin_Tool_Status_Summary__c();
        ob.From_User_Id__c = userAE.Id;
        ob.To_User_Id__c = u2.Id;
        ob.Proposal_End_Date__c = String.valueOf(Date.today());
        ob.Job_Type__c = 'AE Transfer';
        ob.Transfer_Details__c = atm.Id; 
        adminToolSmry.add(ob);
        insert adminToolSmry;

        Sales_Budget_Simulation__c sm=new Sales_Budget_Simulation__c();
        sm.Budget_User__c=u2.Id;
        sm.Amount__c=999;
        sm.Account_Transfer_Simulation__c=att.id;
        sm.From_Budget_user__c=userAE.id;
        sm.New_Business_Churn__c='Unknown Churn';
        sm.DMA__c='DMAs';
        sm.Broadcast_Month_Date__c=Date.Today();
        sm.Product_Line__c='Production';
        sm.Commodity__c='Restaurant';
        sm.External_Id__c = UserInfo.getUserId()+':' +sm.Unique_Key__c; 
		sm.Type__c = 'Simulation';
        sm.Account_Transfer_Simulation__c = ats.Id;
        sm.Comments__c='ASP';
        insert sm;
        
         List<Sales_Budget__c>slist=new list<Sales_Budget__c>();
        Sales_Budget__c sb = new Sales_Budget__c();
        //sb = TestUtil.getSalesBudgetRec(userAE, acc);
        sb.Type__c = 'DOS';
       // sb.Amount__c = Integer.valueOf(Label.RatePlanThresholdAmount);
        
        sb.Amount__c=500500;
        sb.Budget_User__c=userAE.Id;
        sb.New_Business_Churn__c='Unknown Churn';
        sb.DMA__c='DMAs';
       // sb.Old_Budget_User__c=u3.id;
        sb.Product_Line__c='Production';
        sb.Commodity__c='Restaurant';
        sb.Broadcast_Month_Date__c=Date.Today();
        sb.External_Id__c = userAE.id + ':' +System.today();
        slist.add(sb);	
		
		Sales_Budget__c sb1 = new Sales_Budget__c();
        //sb = TestUtil.getSalesBudgetRec(userAE, acc);
        sb1.Type__c = 'DOS';
       // sb.Amount__c = Integer.valueOf(Label.RatePlanThresholdAmount);
        sb1.Advertiser__c = acc.Id;
        sb1.Amount__c=5500;
        sb1.Budget_User__c=u2.Id;
        sb1.New_Business_Churn__c='Unknown Churn';
        sb1.DMA__c='DMAs';
       // sb.Old_Budget_User__c=u3.id;
        sb1.Product_Line__c='Production';
        sb1.Commodity__c='Restaurant';
        sb1.Broadcast_Month_Date__c=Date.Today();
        sb1.External_Id__c =u2.id + ':' +System.today();
        slist.add(sb1);	
        insert slist; 
        System.debug('ds'+slist);
        
				Revenue__c  revenue2 = TestDataHelper.createRevenue('55556', '88886', System.today(), 100060, 106000, 0, 0, '1');
        revenue2.ContractNumber__c = 666676;
        revenue2.Account_Executive__c = u2.Id;
        revenue2.Broadcast_Month_Date__c = System.today();
        revenue2.Product_Line__c = 'Linear/News/Sports';
        revenue2.Advertiser__c = acc.Id;
		revenue2.Projected_Gross_Amount__c = 9000;
        insert revenue2; 
      System.debug('rev ' + revenue2);
        System.debug('rev Net_Projected_Amount__c' + revenue2.Net_Projected_Amount__c);
        String v=String.valueof(att.id);
        Map<string,integer>mapOfBcthsize=new Map<String,Integer>();
        mapOfBcthsize.put('NBUC_Batch_Size',2);
        Test.StartTest();

        TransferNewsBusinessBatch obj=new TransferNewsBusinessBatch(v,false,adminToolSmry,mapOfBcthsize);
		obj.IsRetry = true;
        Database.executeBatch(obj,2);
        Test.stopTest();   
    }
    
    @isTest(SeeAllData=false)
    static void testsalesbudgetelse()
    {
     
         Account acc = TestUtil.getAccountRec();
        acc.primary_commodity__c =   'Auto Aftermarket';
        insert acc;
        
         List<Test_Data_Utility__mdt> ucList = new List<Test_Data_Utility__mdt>();
        
        Map<String,String> TestData = new Map<String, String>();
        
         ucList = [Select DeveloperName, label from Test_Data_Utility__mdt ];
        for(Test_Data_Utility__mdt abcd : ucList)
        {
            TestData.put(abcd.DeveloperName, abcd.label);
        }
       system.debug('TestData=-=====> '+ TestData.get('Region_c_1'));
        
        User userAE = TestUtil.prepareUser();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@mands.com';
        userAE.Budget_type__c = 'Local';
        userAE.Budget_product_Lines__c = 'Linear/News/Sports';
        userAE.rate_plan_status__c = 'Draft';
        userAE.Rate_Plan_Commit_Date__c =Date.newInstance(2019, 01, 10);
        userAE.Region__c=TestData.get('Region_c_1');
       // userAE.HR_Name__c='ans';
        insert userAE;

        
        Profile pro2 = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        
		User u2 = TestUtil.prepareUser();
       // Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        u2.ProfileId = objProfile.Id;
        u2.Username = 'testu2@mands.com';
        u2.Budget_type__c = 'Local';
        u2.Budget_product_Lines__c = 'Linear/News/Sports';
        u2.rate_plan_status__c = 'Draft';
        u2.Rate_Plan_Commit_Date__c =Date.newInstance(2019, 01, 10);
        u2.Region__c=TestData.get('Region_c_1');
       // userAE.HR_Name__c='ans';
        insert u2;
        


        Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
        att.Division__c = TestData.get('Division_c_1');
        att.Region__c = TestData.get('Region_c_1');
        att.Status__c = 'Approved';
        att.Transfer_Effective_Date__c = Date.newInstance(2018, 01, 15);
        insert att;

        
        Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
        atm.Account__c = acc.Id;
        atm.Account_Transfer_Simulation__c = att.Id;
        atm.From_User__c = userAE.Id;
        atm.To_User__c = u2.Id;
		atm.Count_of_NBUC_Success__c = 0;
        atm.External_ID__c = Userinfo.getUserId()+';;;'+acc.Id+';;;'+'2018Jan'+';;;'+Userinfo.getUserId();
        insert atm;
    	
        Account_Transfer_Tool__c ats = new Account_Transfer_Tool__c();
        insert ats;
        List<Admin_Tool_Status_Summary__c>adminToolSmry=new list<Admin_Tool_Status_Summary__c>();
        
        Admin_Tool_Status_Summary__c ob = new Admin_Tool_Status_Summary__c();
        ob.From_User_Id__c = userAE.Id;
        ob.To_User_Id__c = u2.Id;
        ob.Proposal_End_Date__c = String.valueOf(Date.today());
        ob.Job_Type__c = 'AE Transfer';
        ob.Transfer_Details__c = atm.Id; 
        adminToolSmry.add(ob);
        insert adminToolSmry;

        Sales_Budget_Simulation__c sm=new Sales_Budget_Simulation__c();
        sm.Budget_User__c=u2.Id;
        sm.Amount__c=999;
        sm.Account_Transfer_Simulation__c=att.id;
        sm.From_Budget_user__c=userAE.id;
        sm.New_Business_Churn__c='Unknown Churn';
        sm.DMA__c='DMA';
        sm.Broadcast_Month_Date__c=Date.Today();
        sm.Product_Line__c='Production';
        sm.Commodity__c='Restaurant';
        sm.External_Id__c =UserInfo.getUserId()+':'+ +sm.Unique_Key__c; 
		sm.Type__c = 'Simulation';
        sm.Account_Transfer_Simulation__c = ats.Id;
        sm.Comments__c='ASP';
        insert sm;
        
         List<Sales_Budget__c>slist=new list<Sales_Budget__c>();
        Sales_Budget__c sb = new Sales_Budget__c();
        sb = TestUtil.getSalesBudgetRec(userAE, acc);
        sb.Type__c = 'DOS';
       // sb.Amount__c = Integer.valueOf(Label.RatePlanThresholdAmount);
        
        sb.Amount__c=999;
        sb.Budget_User__c=userAE.Id;
        sb.New_Business_Churn__c='Unknown Churn';
        sb.DMA__c='DMA';
       // sb.Old_Budget_User__c=u3.id;
        sb.Product_Line__c='Production';
        sb.Commodity__c='Restaurant';
        sb.Broadcast_Month_Date__c=Date.Today();
        sb.External_Id__c = userAE.id + ':' +System.today();
        
        slist.add(sb);	
        Sales_Budget__c sb2 = new Sales_Budget__c();
        sb2 = TestUtil.getSalesBudgetRec(userAE, acc);
        sb2.Type__c = 'DOS';
       // sb.Amount__c = Integer.valueOf(Label.RatePlanThresholdAmount);
        
        sb2.Amount__c=999;
        sb2.Budget_User__c=userAE.Id;
        sb2.New_Business_Churn__c='Unknown Churn';
        sb2.DMA__c='DMA';
       // sb.Old_Budget_User__c=u3.id;
        sb2.Product_Line__c='Digital';
        sb2.Commodity__c='Restaurant';
        sb2.Broadcast_Month_Date__c=Date.Today();
        sb2.External_Id__c = userAE.id + ':' +System.today();
        
        slist.add(sb2);	
				Revenue__c  revenue2 = TestDataHelper.createRevenue('55556', '88886', System.today(), 100060, 106000, 0, 0, '1');
        revenue2.ContractNumber__c = 666676;
        revenue2.Account_Executive__c = u2.Id;
        revenue2.Broadcast_Month_Date__c = System.today();
        revenue2.Product_Line__c = 'Linear/News/Sports';
        revenue2.Advertiser__c = acc.Id;
		revenue2.Projected_Gross_Amount__c = 9000;
        insert revenue2; 
		Sales_Budget__c sb1 = new Sales_Budget__c();
        //sb = TestUtil.getSalesBudgetRec(userAE, acc);
        sb1.Type__c = 'DOS';
       // sb.Amount__c = Integer.valueOf(Label.RatePlanThresholdAmount);
        
        sb1.Amount__c=5500;
        sb1.Budget_User__c=u2.Id;
        sb1.New_Business_Churn__c='Unknown Churn';
        sb1.DMA__c='DMA';
       // sb.Old_Budget_User__c=u3.id;
	   sb1.Advertiser__c = acc.Id;
        sb1.Product_Line__c='Production';
        sb1.Commodity__c='Restaurant';
        sb1.Broadcast_Month_Date__c=Date.Today();
        sb1.External_Id__c = u2.id + ':' +System.today();
        slist.add(sb1);	
        insert slist; 
        System.debug('ds'+slist);
      
        String v=String.valueof(att.id);
        Map<string,integer>mapOfBcthsize=new Map<String,Integer>();
        mapOfBcthsize.put('NBUC_Batch_Size',2);
       
    	Test.StartTest();
        TransferNewsBusinessBatch obj=new TransferNewsBusinessBatch(v,true,adminToolSmry,mapOfBcthsize);
		obj.IsRetry = true;
        Database.executeBatch(obj,2);
            Test.stopTest(); 
    }
    
    @isTest(SeeAllData=false)
    static void testsalessimulationelse()
    {
     
         Account acc = TestUtil.getAccountRec();
        acc.primary_commodity__c =   'Auto Aftermarket';
        insert acc;
        
         List<Test_Data_Utility__mdt> ucList = new List<Test_Data_Utility__mdt>();
        
        Map<String,String> TestData = new Map<String, String>();
        
         ucList = [Select DeveloperName, label from Test_Data_Utility__mdt ];
        for(Test_Data_Utility__mdt abcd : ucList)
        {
            TestData.put(abcd.DeveloperName, abcd.label);
        }
       system.debug('TestData=-=====> '+ TestData.get('Region_c_1'));
        
        User userAE = TestUtil.prepareUser();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@mands.com';
        userAE.Budget_type__c = 'Local';
        userAE.Budget_product_Lines__c = 'Linear/News/Sports';
        userAE.rate_plan_status__c = 'Draft';
        userAE.Rate_Plan_Commit_Date__c =Date.newInstance(2019, 01, 10);
        userAE.Region__c=TestData.get('Region_c_1');
       // userAE.HR_Name__c='ans';
        insert userAE;
        

        
        Profile pro2 = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        
		User u2 = TestUtil.prepareUser();
       // Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        u2.ProfileId = objProfile.Id;
        u2.Username = 'testu2@mands.com';
        u2.Budget_type__c = 'Local';
        u2.Budget_product_Lines__c = 'Linear/News/Sports';
        u2.rate_plan_status__c = 'Draft';
        u2.Rate_Plan_Commit_Date__c =Date.newInstance(2019, 01, 10);
        u2.Region__c=TestData.get('Region_c_1');
       // userAE.HR_Name__c='ans';
        insert u2;
        

        Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
        att.Division__c = TestData.get('Division_c_1');
        att.Region__c = TestData.get('Region_c_1');
        att.Status__c = 'Approved';
        att.Transfer_Effective_Date__c = Date.newInstance(2018, 01, 15);
        insert att;

        
        Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
        atm.Account__c = acc.Id;
        atm.Account_Transfer_Simulation__c = att.Id;
        atm.From_User__c = userAE.ID;
		atm.Count_of_NBUC_Success__c = 0;
        atm.To_User__c = u2.Id;
        atm.External_ID__c = Userinfo.getUserId()+';;;'+acc.Id+';;;'+'2018Jan'+';;;'+Userinfo.getUserId();
        insert atm;
        
        Account_Transfer_Tool__c ats = new Account_Transfer_Tool__c();
        insert ats;
        List<Admin_Tool_Status_Summary__c>adminToolSmry=new list<Admin_Tool_Status_Summary__c>();
        
        Admin_Tool_Status_Summary__c ob = new Admin_Tool_Status_Summary__c();
        ob.From_User_Id__c = userAE.Id;
        ob.To_User_Id__c = u2.Id;
        ob.Proposal_End_Date__c = String.valueOf(Date.today());
        ob.Job_Type__c = 'AE Transfer';
        ob.Transfer_Details__c = atm.Id; 
        adminToolSmry.add(ob);
        insert adminToolSmry;

        Sales_Budget_Simulation__c sm=new Sales_Budget_Simulation__c();
        sm.Budget_User__c=u2.Id;
        sm.Amount__c=9;
        sm.Account_Transfer_Simulation__c=att.id;
        sm.From_Budget_user__c=userAE.id;
        sm.New_Business_Churn__c='Unknown Churn';
        sm.DMA__c='DMAs';
        sm.Broadcast_Month_Date__c=Date.Today();
        sm.Product_Line__c='Production';
        sm.Commodity__c='Restaurant';
        sm.External_Id__c =u2.Id+':'+sm.Unique_Key__c; 
		sm.Type__c = 'Simulation';
        sm.Account_Transfer_Simulation__c = ats.Id;
        sm.Comments__c='ASP';
        insert sm;
        
        Sales_Budget_Simulation__c sm1=new Sales_Budget_Simulation__c();
        sm1.Budget_User__c=u2.Id;
        sm1.Amount__c=90;
        sm1.Account_Transfer_Simulation__c=att.id;
        sm1.From_Budget_user__c=userAE.id;
        sm1.New_Business_Churn__c='Unknown Churn';
        sm1.DMA__c='DMA';
        sm1.Broadcast_Month_Date__c=Date.Today();
        sm1.Product_Line__c='Production';
        sm1.Commodity__c='Restaurant';
        sm1.External_Id__c =u2.Id+':'+sm1.Unique_Key__c+sm1.DMA__c; 
		sm1.Type__c = 'Simulation';
        sm1.Comments__c='ASP';
        insert sm1;
        
         List<Sales_Budget__c>slist=new list<Sales_Budget__c>();
        Sales_Budget__c sb = new Sales_Budget__c();
        sb = TestUtil.getSalesBudgetRec(userAE, acc);
        sb.Type__c = 'DOS';
       // sb.Amount__c = Integer.valueOf(Label.RatePlanThresholdAmount);
        
        sb.Amount__c=500;
        sb.Budget_User__c=userAE.Id;
        sb.New_Business_Churn__c='Unknown Churn';
        sb.DMA__c='DMAs';
       // sb.Old_Budget_User__c=u3.id;
        sb.Product_Line__c='Production';
        sb.Commodity__c='Restaurant';
        sb.Broadcast_Month_Date__c=Date.Today();
        sb.External_Id__c = userAE.id + ':' +System.today();
        slist.add(sb);	
        
		Sales_Budget__c sb1 = new Sales_Budget__c();
        //sb = TestUtil.getSalesBudgetRec(userAE, acc);
        sb1.Type__c = 'DOS';
       // sb.Amount__c = Integer.valueOf(Label.RatePlanThresholdAmount);
        sb1.Advertiser__c = acc.Id;
        sb1.Amount__c=5500;
        sb1.Budget_User__c=u2.Id;
        sb1.New_Business_Churn__c='Unknown Churn';
        sb1.DMA__c='DMAs';
       // sb.Old_Budget_User__c=u3.id;
        sb1.Product_Line__c='Production';
        sb1.Commodity__c='Restaurant';
        sb1.Broadcast_Month_Date__c=Date.Today();
        sb1.External_Id__c = u2.id + ':' +System.today();
        slist.add(sb1);	
        insert slist; 
        System.debug('ds'+slist);
        
		Revenue__c  revenue2 = TestDataHelper.createRevenue('55556', '88886', System.today(), 100060, 106000, 0, 0, '1');
        revenue2.ContractNumber__c = 666676;
        revenue2.Account_Executive__c = u2.Id;
        revenue2.Broadcast_Month_Date__c = System.today();
        revenue2.Product_Line__c = 'Linear/News/Sports';
		revenue2.Projected_Gross_Amount__c = 9000;
        revenue2.Advertiser__c = acc.Id;
        insert revenue2; 
        String v=String.valueof(att.id);
        Map<string,integer>mapOfBcthsize=new Map<String,Integer>();
        mapOfBcthsize.put('NBUC_Batch_Size',1);
        //Test.StartTest();
        
       // ApexPages.StandardController sc = new ApexPages.StandardController();
       // AccountTransferToolController attc = new AccountTransferToolController(sc);
        TransferNewsBusinessBatch obj=new TransferNewsBusinessBatch(v,false, adminToolSmry,mapOfBcthsize);
		//obj.IsRetry = true;
		System.runAs (userAE) {
        	Test.startTest();
        Database.executeBatch(obj,1);
            Test.stopTest();   
        }
    }
   @isTest     
   public static void testsalessimulationelsetest()
	{
		Account acc = TestUtil.getAccountRec();
		acc.primary_commodity__c = 'Auto Aftermarket';
		insert acc;
		
        List<Test_Data_Utility__mdt> ucList = new List<Test_Data_Utility__mdt>();
        
        Map<String,String> TestData = new Map<String, String>();
        
         ucList = [Select DeveloperName, label from Test_Data_Utility__mdt ];
        for(Test_Data_Utility__mdt abcd : ucList)
        {
            TestData.put(abcd.DeveloperName, abcd.label);
        }
       system.debug('TestData=-=====> '+ TestData.get('Region_c_1'));
        
		User userAE = TestUtil.prepareUser();
		Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Master - Account Executive'];
		userAE.ProfileId = objProfile.Id;
		userAE.Username = 'testae@mands.com';
		userAE.Budget_type__c = 'Local';
		userAE.Budget_product_Lines__c = 'Linear/News/Sports';
		userAE.rate_plan_status__c = 'Draft';
		userAE.Rate_Plan_Commit_Date__c = Date.newInstance(2019, 01, 10);
		userAE.Region__c = TestData.get('Region_c_1');
		// userAE.HR_Name__c='ans';
		insert userAE;


		Profile pro2 = [SELECT Id FROM Profile WHERE Name = 'Standard User'];


		User u2 = TestUtil.prepareUser();
		//Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
		u2.ProfileId = objProfile.Id;
		u2.Username = 'testu2@mands.com';
		u2.Budget_type__c = 'Local';
		u2.Budget_product_Lines__c = 'Linear/News/Sports';
		u2.rate_plan_status__c = 'Draft';
		u2.Rate_Plan_Commit_Date__c = Date.newInstance(2019, 01, 10);
		u2.Region__c = TestData.get('Region_c_1');
		// userAE.HR_Name__c='ans';
		insert u2;

		System.debug(u2.Name);
		Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
		att.Division__c = TestData.get('Division_c_1');
		att.Region__c = TestData.get('Region_c_1');
		att.Status__c = 'Approved';
		att.Transfer_Effective_Date__c = Date.newInstance(2018, 01, 15);
		insert att;

		Account_Transfer_Tool__c att1 = new Account_Transfer_Tool__c();
		  att.Division__c = TestData.get('Division_c_1');
		  att.Region__c = TestData.get('Region_c_1');
		  att.Status__c = 'Pending';
		  att.Transfer_Effective_Date__c = Date.newInstance(2018, 02, 15);
		  insert att1;

		Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
		atm.Account__c = acc.Id;
		atm.Account_Transfer_Simulation__c = att.Id;
		atm.From_User__c = userAE.Id;
		atm.To_User__c = u2.Id;
		atm.Count_of_NBUC_Success__c =0;
		atm.External_ID__c = Userinfo.getUserId() + ';;;' + acc.Id + ';;;' + '2018Jan' + ';;;' + Userinfo.getUserId();
		insert atm;

		Account_Transfer_Tool__c ats = new Account_Transfer_Tool__c();
		insert ats;
		List<Admin_Tool_Status_Summary__c> adminToolSmry = new list<Admin_Tool_Status_Summary__c> ();

		Admin_Tool_Status_Summary__c ob = new Admin_Tool_Status_Summary__c();
		ob.From_User_Id__c = userAE.Id;
		ob.To_User_Id__c = u2.Id;
		ob.Proposal_End_Date__c = String.valueOf(Date.today());
		ob.Job_Type__c = 'AE Transfer';
		ob.Transfer_Details__c = atm.Id;
		adminToolSmry.add(ob);
		insert adminToolSmry;

		Sales_Budget_Simulation__c sm = new Sales_Budget_Simulation__c();
		sm.Budget_User__c = u2.Id;
		sm.Amount__c = 999.65;
		sm.Account_Transfer_Simulation__c = att.id;
		sm.From_Budget_user__c = userAE.id;
		sm.New_Business_Churn__c = 'Unknown Churn';
		sm.DMA__c = 'DMAs';
		sm.Broadcast_Month_Date__c = Date.Today();
		sm.Product_Line__c = 'Production';
		sm.Commodity__c = 'Restaurant';
		sm.External_Id__c = UserInfo.getUserId() + ':' + sm.Unique_Key__c;
		sm.Type__c = 'Simulation';
		sm.Account_Transfer_Simulation__c = ats.Id;
		sm.Comments__c = 'ASP';
		insert sm;

		List<Sales_Budget__c> slist = new list<Sales_Budget__c> ();
		Sales_Budget__c sb = new Sales_Budget__c();
		//sb = TestUtil.getSalesBudgetRec(userAE, acc);
		sb.Type__c = 'DOS';
		// sb.Amount__c = Integer.valueOf(Label.RatePlanThresholdAmount);

		sb.Amount__c = 532501.33;
		sb.Budget_User__c = u2.Id;
		sb.New_Business_Churn__c = 'Unknown Churn';
		sb.DMA__c = 'DMA';
		// sb.Old_Budget_User__c=u3.id;
		sb.Product_Line__c = 'Production';
		sb.Commodity__c = 'Restaurant';
		sb.Broadcast_Month_Date__c = Date.Today();
		sb.External_Id__c = userAE.id + ':' + System.today();
		slist.add(sb);

		Sales_Budget__c sb1 = new Sales_Budget__c();
		//sb = TestUtil.getSalesBudgetRec(userAE, acc);
		sb1.Type__c = 'DOS';
		// sb.Amount__c = Integer.valueOf(Label.RatePlanThresholdAmount);
		sb1.Advertiser__c = acc.Id;
		sb1.Amount__c = 500;
		sb1.Budget_User__c = u2.Id;
		sb1.New_Business_Churn__c = 'Unknown Churn';
		sb1.DMA__c = 'DMA';
		// sb.Old_Budget_User__c=u3.id;
		sb1.Product_Line__c = 'Production';
		sb1.Commodity__c = 'Restaurant';
		sb1.Broadcast_Month_Date__c = Date.Today();
		sb1.External_Id__c = u2.id + ':' + System.today();
		slist.add(sb1);
		insert slist;
		System.debug('ds' + slist);
		System.debug('unique key' + slist[0].Unique_Key__c);
		slist =[select id,Unique_Key__c,Type__c,Amount__c,Budget_User__c,New_Business_Churn__c,DMA__c,Product_Line__c,Commodity__c,Broadcast_Month_Date__c,External_Id__c from Sales_Budget__c where Id=:slist[0].Id or Id=:slist[1].Id];
		System.debug('dss' + slist);
		Revenue__c revenue2 = TestDataHelper.createRevenue('55556', '88886', System.today(), 100060, 106000, 0, 0, '1');
		revenue2.ContractNumber__c = 666676;
		revenue2.Account_Executive__c = u2.Id;
		revenue2.Broadcast_Month_Date__c = System.today();
		revenue2.Product_Line__c = 'Linear/News/Sports';
		revenue2.Advertiser__c = acc.Id;
		revenue2.Projected_Gross_Amount__c = 9000;
		insert revenue2;
		System.debug('rev ' + revenue2);
		System.debug('rev Net_Projected_Amount__c' + revenue2.Net_Projected_Amount__c);
		String v = String.valueof(att.id);
		Map<string, integer> mapOfBcthsize = new Map<String, Integer> ();
		mapOfBcthsize.put('NBUC_Batch_Size', 2);
		Test.StartTest();

		TransferNewsBusinessBatch obj = new TransferNewsBusinessBatch(v, false, adminToolSmry, mapOfBcthsize);
		obj.IsRetry = true;
		Database.executeBatch(obj, 2);
		 
		Test.stopTest();
	} 
}