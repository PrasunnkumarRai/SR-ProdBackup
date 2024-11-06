@IsTest(SeeAllData = false)
public class SponsorshipDateInventoryBatchTest {
    
    //Test method to create the Date Inventories for Sponsorship
    public static testmethod void testCreateInventories(){
        List<Templates__c> sponsorshipList = new List<Templates__c>();
        
        Opportunity opp = new Opportunity();
        Account acc = new Account();
        acc.Name = 'Test Account';
		acc.Primary_Commodity__c = 'Alcoholic Beverages';
		acc.Commodity_Codes__c = 'ALC_BEV -- Beer and Wine';
        acc.BillingCity = 'Secaucus';
        acc.BillingCountry = 'US';
        acc.BillingPostalCode = '07094';
        acc.BillingState = 'NJ';
        acc.BillingStreet = 'PO Box 2516';
		insert acc;
        
		opp.Name = 'INW TDA Olympics Digital';
		opp.AccountId = acc.Id;
		opp.Owner_Division__c = 'West';
		opp.Owner_Region__c = 'Big West';
		opp.Owner_Sales_Office__c = 'Kennewick';
		opp.StageName = 'Identification';
		opp.CloseDate = date.parse('8/28/2016');
		insert opp;
        
        Templates__c temp = new Templates__c();
		temp.Name = 'Weather on the Ones';
		temp.Total_Quantity__c = 10;
		temp.Start_Date__c = date.parse('8/28/2020');
		temp.End_Date__c = date.parse('10/28/2020');
		temp.Syscode__c = '2838';
		temp.Network_Code__c = 'S1LA';
		insert temp;
        sponsorshipList.add(temp);
        
        Templates__c temp1 = new Templates__c();
		temp1.Name = 'Weather on the Ones - 2';
		temp1.Total_Quantity__c = 10;
		temp1.Start_Date__c = date.parse('10/28/2020');
		temp1.End_Date__c = date.parse('11/28/2020');
		temp1.Syscode__c = '2838';
		temp1.Network_Code__c = 'S1LA';
		insert temp1;
        sponsorshipList.add(temp1);
        
        Booked_Sponsorship__c booking = new Booked_Sponsorship__c();
        booking.Opportunity__c = opp.Id;
        booking.Status__c = 'New';
		booking.Right_to_First_Refusal__c = true;
        insert booking;
        
        Sponsorship_Booking__c sponsorshipBooking = new Sponsorship_Booking__c();
		sponsorshipBooking.Name='Weather on the Ones';
		sponsorshipBooking.Template__c = temp.Id;
		sponsorshipBooking.Start_Date__c = date.parse('8/28/2020');
		sponsorshipBooking.End_Date__c = date.parse('9/5/2020');
		sponsorshipBooking.Status__c = 'Pending';
		sponsorshipBooking.Syscode__c = '2838';
		sponsorshipBooking.Network_Code__c = 'S1LA';
        sponsorshipBooking.Booked_Sponsorship__c = booking.Id;
		insert sponsorshipBooking;
        
        Test.startTest();
		SponsorshipDateInventoryBatch sponInventory = new SponsorshipDateInventoryBatch(sponsorshipList);
		Database.executeBatch(sponInventory);
		Test.stopTest();
    }
    
}