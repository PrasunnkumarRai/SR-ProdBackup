@isTest(SeeAllData=false)
public class RevenueTriggerTest{

    static testMethod void RevenueInsertTest() {
        
        User u = [Select ID,Name from User where ID =: System.Label.BoomiUserId];
        System.debug('@@u Name '+u.Name);
        Account Advertiser=TestDataHelper.createAdvertiser('Advertiser Account123','123 Wright Plaza', 'Omaha', 'NE', '681030', 'USA');                        
	        insert Advertiser;
			AccountConnection__c accCon = TestDataHelper.createAccountConnection(Advertiser.Id);
			accCon.Tim_ID__c = '5413';
			insert accCon ;
	        System.assert(Advertiser != null);
        
        System.runAs(u){
            //UserConnection__c connection = TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');   
            //insert connection;
        	
	        //Create an account
	        
       
	        
	        //create create Traffic Id Element for User
	        Traffic_Id_Element__c trafficElementUser = new Traffic_Id_Element__c();
			//trafficElementUser.Account_TIM_ID__c = Agency.ID;
			trafficElementUser.User__c = u.ID;
			trafficElementUser.AE_ID__c = 1;
        	trafficElementUser.Export_System_Id__c = '1';
        	trafficElementUser.Traffic_Id__c = '2222';
	        trafficElementUser.Tim_System__c = 'St. Louis Local';
	        trafficElementUser.Traffic_Type__c = 'User';
	        trafficElementUser.Account__c = Advertiser.ID;
	        trafficElementUser.ExportSystem_Name__c = 'TWNY';
	        insert trafficElementUser;
	        
	        Traffic_Id_Element__c trafficElementAcc = new Traffic_Id_Element__c();
			trafficElementAcc.Account_TIM_ID__c = Advertiser.ID;
			trafficElementAcc.User__c = u.ID;
			trafficElementAcc.AE_ID__c = 1;
        	trafficElementAcc.Export_System_Id__c = '1';
        	trafficElementAcc.Traffic_Id__c = '5413';
	        trafficElementAcc.Tim_System__c = 'St. Louis Local';
	        trafficElementAcc.Traffic_Type__c = 'Account';
	        trafficElementAcc.Account__c = Advertiser.ID;
	        trafficElementAcc.ExportSystem_Name__c = 'TWNY';
	        insert trafficElementAcc;

	        System.assert(trafficElementUser != null);  
/*	        
	         //create create Traffic Id Element for Advertiser
	      	trafficElementUser = new Traffic_Id_Element__c();
			trafficElementUser.User__c = u.ID;
			trafficElementUser.AE_ID__c = 2;
        	trafficElementUser.Export_System_Id__c = '3';
        	trafficElementUser.Traffic_Id__c = '33';
	        trafficElementUser.Tim_System__c = 'St. Louis Local';
	        trafficElementUser.Traffic_Type__c = 'Account';
	        trafficElementUser.Account__c = Advertiser.ID;
	        trafficElementUser.ExportSystem_Name__c = 'TWNY';
	        insert trafficElementUser;
*/	        
			List<Revenue__c> revList = new List<Revenue__c>();
	        //CreateRevenue
	        Revenue__c  revenue = new Revenue__c();
			revenue.Customer_Number__c = '5413';
	        revenue.AE_Id__c = '2222';
	        revenue.Export_System_Id__c = '1';
	        revenue.Actual_Gross_Amount__c = 10080;
	        revenue.Projected_Gross_Amount__c = 10000;
	        //revenue.Actual_Discount__c = actualDiscount;
	        //revenue.Projected_Discount__c = projectedDiscount;
	        revenue.Broadcast_Month_Date__c = date.today(); 
	        //TestDataHelper.createRevenue('2222', '3333', System.today(), 1000, 1000, 0, 0, '1');
	        revenue.Eclipse_System__c = 'TWNY';
	        revenue.ContractNumber__c = 1111;
	        revList.add( revenue);
	        
	        Revenue__c revenueNew = new Revenue__c();
			revenueNew.Customer_Number__c = '5413';	
	        revenueNew.AE_Id__c = '2222';
	        revenueNew.Export_System_Id__c = '1';
	        revenueNew.Actual_Gross_Amount__c = 9000;
	        revenueNew.Projected_Gross_Amount__c = 1000;
	        //revenue.Actual_Discount__c = actualDiscount;
	        //revenue.Projected_Discount__c = projectedDiscount;
	        revenueNew.Broadcast_Month_Date__c = date.today();  
	        //TestDataHelper.createRevenue('2222', '3333', System.today(), 1000, 1000, 0, 0, '1');
	        revenueNew.Eclipse_System__c = 'TWNY';
	        revenueNew.ContractNumber__c = 1111;
	        revList.add( revenueNew);
	        insert revList;
	        RevenueHelper.updateUserAccountinRevenue(revList,null);  

	        //System.assert(revenue != null);
        }        
    }
        
}