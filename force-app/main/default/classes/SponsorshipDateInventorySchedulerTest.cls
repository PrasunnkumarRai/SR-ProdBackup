@IsTest(SeeAllData = false)
public class SponsorshipDateInventorySchedulerTest {
    public static testmethod void createInventory() {
        String cronExpression = '0 0 0/1 1/1 * ? *';
        Opportunity details = new Opportunity();
        Account acc = new Account();
        acc.Name = 'Test Account';
        //acc.RecordType= Account_Request;
        acc.Primary_Commodity__c = 'Alcoholic Beverages';
        acc.Commodity_Codes__c = 'ALC_BEV -- Beer and Wine';
        acc.BillingCity = 'Secaucus';
        acc.BillingCountry = 'US';
        acc.BillingPostalCode = '07094';
        acc.BillingState = 'NJ';
        acc.BillingStreet = 'PO Box 2516';
        insert acc;
        details.Name = 'INW TDA Olympics Digital';
        details.AccountId = acc.Id;
        details.Owner_Division__c = 'West';
        details.Owner_Region__c = 'Big West';
        details.Owner_Sales_Office__c = 'Kennewick';
        details.StageName = 'Identification';
        details.CloseDate = date.parse('8/28/2016');
        //details.Owner.Name = 'Christine Erb';
        insert details;

        Templates__c temp = new Templates__c();
        temp.Name = 'Weather on the Ones';
        temp.Total_Quantity__c = 10;
        temp.Start_Date__c = date.parse('12/28/2020');
        temp.End_Date__c = date.parse('1/28/2021');
        temp.Syscode__c = '2838';
        temp.Network_Code__c = 'S1LA';
        insert temp;

        Test.startTest();
            SponsorshipDateInventoryScheduler sch = new SponsorshipDateInventoryScheduler(); 
            system.schedule('Test Sponsorship Date Inventory', cronExpression, sch);
        Test.stopTest();
    }
}