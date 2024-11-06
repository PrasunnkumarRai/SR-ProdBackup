@isTest
public with sharing class UserTriggerHandler_Test {
    
    @IsTest(seeAllData = false)
    static void recordSharePositivePathTest() {
        
        //Create Metadata
        TestDataHelper.createTIMIntegrationCustomSettings();
        insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
        
        //Create an account
        Account acc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
        insert acc;
        
        //Create an opportunity on the above created account
        Opportunity opp = TestDataHelper.createOpportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
        insert opp;
        
        //Create a budget record
        Budget__c budget = TestDataHelper.createBudget(System.Today(),1000,'Linear',UserInfo.getUserId(),null ,'Approved');
        insert budget;
        
        //Create a revenue record
        Revenue__c revenue = new Revenue__c();
        revenue.Customer_Number__c = '5413';
        revenue.AE_Id__c = '3333';
        revenue.Export_System_Id__c = '1';
        revenue.Actual_Gross_Amount__c = 1000;
        revenue.Projected_Gross_Amount__c = 1000;
        revenue.Eclipse_System__c = 'TWNY';
        revenue.ContractNumber__c = 1111;
        insert revenue;
        
        Test.startTest();
            User u = TestDataHelper.createUser(true);
            u.Job_Share_User__c = UserInfo.getUserId();
            update u;
            System.debug('@@u Name '+u.Name);
        Test.stopTest();        
    }
    @IsTest(seeAllData = false)
    static void updateIsFrozenTest() {
        User u = TestDataHelper.createUser(true);
        // Create a user to be updated
        // Update the user to set IsFrozen to true
        Test.startTest();
            u.Is_Frozen__c = true;
            update u;
        Test.stopTest();
        
        // Verify the update
        System.runAs(u){
        User updatedUser = [SELECT Is_Frozen__c FROM User WHERE Id = :u.Id ];
    }
    }           
}