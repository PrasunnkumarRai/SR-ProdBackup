@isTest(SeeAllData=false)
public class SalesRevenueTriggerTest{

    static testMethod void RevenueAEMappingTest() {
        
        User u = [Select ID,Name from User where ID =: System.Label.BoomiUserId];
        System.debug('@@u Name '+u.Name);
        
        System.runAs(u){
            //Create Advertiser
	        Account Advertiser=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
	        insert Advertiser;
	        
			//create Traffic Id Element for User
	        Traffic_Id_Element__c trafficElementUser = new Traffic_Id_Element__c();
			trafficElementUser.User__c = u.ID;
			trafficElementUser.AE_ID__c = 1;
        	trafficElementUser.Export_System_Id__c = '1';
        	trafficElementUser.Traffic_Id__c = '2222';
	        trafficElementUser.Tim_System__c = 'St. Louis Local';
	        trafficElementUser.Traffic_Type__c = 'User';
	        trafficElementUser.Account__c = Advertiser.ID;
	        trafficElementUser.ExportSystem_Name__c = 'TWNY';
	        insert trafficElementUser;

            //CreateSalesRevenue
	        Sales_Revenue__c  revenue = TestUtil.getSalesRevenueRec(u,Advertiser,System.today());	
			revenue.Customer_Number__c = '5413';
	        revenue.AE_Id__c = '2222';
	        revenue.Eclipse_System__c = 'TWNY';
			revenue.DMA__c = 'Topeka';
	        insert revenue;
	       
	        System.assert(revenue != null);
        }        
    }
    
    static testMethod void RevenueAdvertiserMappingTest() {
        
        User u = [Select ID,Name from User where ID =: System.Label.BoomiUserId];
        System.debug('@@u Name '+u.Name);
        
        System.runAs(u){
            //Create Advertiser
	        Account Advertiser=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
	        insert Advertiser;
	        
			//create Traffic Id Element for User
	        Traffic_Id_Element__c trafficElementUser = new Traffic_Id_Element__c();
			trafficElementUser.User__c = u.ID;
			trafficElementUser.Export_System_Id__c = '1';
        	trafficElementUser.Traffic_Id__c = '2222';
	        trafficElementUser.Tim_System__c = 'St. Louis Local';
	        trafficElementUser.Traffic_Type__c = 'User';
	        trafficElementUser.Account__c = Advertiser.ID;
	        trafficElementUser.ExportSystem_Name__c = 'TWNY';
	        insert trafficElementUser;

            //CreateSalesRevenue
	        Sales_Revenue__c  revenue = TestUtil.getSalesRevenueRec(u,Advertiser,System.today());	
			revenue.Customer_Number__c = '2222';
	        revenue.Eclipse_System__c = 'TWNY';
	        insert revenue;
	       
	        System.assert(revenue != null);
        }        
    }
        
}