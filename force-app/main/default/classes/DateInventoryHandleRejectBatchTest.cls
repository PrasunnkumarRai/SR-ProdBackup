@IsTest(SeeAllData = false)
public class DateInventoryHandleRejectBatchTest {
   public static testmethod void testRejectInventories(){
    List<Templates__c> sponsorshipList = new List<Templates__c>();

        //Oportunity and Account Test Data
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

        //Sponsorship test data
        Templates__c temp = new Templates__c();
		temp.Name = 'Weather on the Ones';
		temp.Total_Quantity__c = 10;
		temp.Start_Date__c = date.parse('8/10/2020');
		temp.End_Date__c = date.parse('8/15/2020');
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

        Sponsorship_Date_Inventory__c inventory1 = new Sponsorship_Date_Inventory__c();
        inventory1.Sponsorship__c = temp.Id;
        inventory1.Sponsorship_Inventory_Date__c = date.parse('8/10/2020');
        inventory1.Booked_Quantity__c = 1;
        insert inventory1;

        Sponsorship_Date_Inventory__c inventory2 = new Sponsorship_Date_Inventory__c();
        inventory2.Sponsorship__c = temp.Id;
        inventory2.Sponsorship_Inventory_Date__c = date.parse('8/11/2020');
        inventory2.Booked_Quantity__c = 1;
        insert inventory2;

        Sponsorship_Date_Inventory__c inventory3 = new Sponsorship_Date_Inventory__c();
        inventory3.Sponsorship__c = temp.Id;
        inventory3.Sponsorship_Inventory_Date__c = date.parse('8/12/2020');
        inventory3.Booked_Quantity__c = 1;
        insert inventory3;

        Sponsorship_Date_Inventory__c inventory4 = new Sponsorship_Date_Inventory__c();
        inventory4.Sponsorship__c = temp.Id;
        inventory4.Sponsorship_Inventory_Date__c = date.parse('8/13/2020');
        inventory4.Booked_Quantity__c = 1;
        insert inventory4;

        Sponsorship_Date_Inventory__c inventory5 = new Sponsorship_Date_Inventory__c();
        inventory5.Sponsorship__c = temp.Id;
        inventory5.Sponsorship_Inventory_Date__c = date.parse('8/14/2020');
        inventory5.Booked_Quantity__c = 1;
        insert inventory5;

        Sponsorship_Date_Inventory__c inventory6 = new Sponsorship_Date_Inventory__c();
        inventory6.Sponsorship__c = temp.Id;
        inventory6.Sponsorship_Inventory_Date__c = date.parse('8/15/2020');
        inventory6.Booked_Quantity__c = 1;
        insert inventory6;
        
        //Booked Sponsorship test data
        Booked_Sponsorship__c booking = new Booked_Sponsorship__c();
        booking.Opportunity__c = opp.Id;
        booking.Status__c = 'Rejected';
		booking.Right_to_First_Refusal__c = true;
        insert booking;

        //Booked Sponsorship test data
        Booked_Sponsorship__c booking2 = new Booked_Sponsorship__c();
        booking2.Opportunity__c = opp.Id;
        booking2.Status__c = 'Approved';
		booking2.Right_to_First_Refusal__c = true;
        insert booking2;
        
        Id updatedRecordTypeId = Schema.SObjectType.Sponsorship_Booking__c.getRecordTypeInfosByName().get('Updated').getRecordTypeId();
        //Sponsorship Booking test data linked to above Sponsorship and Booked Sponsorship
        Sponsorship_Booking__c sponsorshipBooking = new Sponsorship_Booking__c();
		sponsorshipBooking.Name='Weather on the Ones';
		sponsorshipBooking.Template__c = temp.Id;
		sponsorshipBooking.Start_Date__c = date.parse('8/10/2020');
		sponsorshipBooking.End_Date__c = date.parse('8/13/2020');
		sponsorshipBooking.Syscode__c = '2838';
		sponsorshipBooking.Network_Code__c = 'S1LA';
        sponsorshipBooking.RecordTypeId = updatedRecordTypeId;
        sponsorshipBooking.Booked_Sponsorship__c = booking.Id;
		insert sponsorshipBooking;


        Sponsorship_Booking__c sponsorshipBooking2 = new Sponsorship_Booking__c();
		sponsorshipBooking2.Name='Weather on the Ones';
		sponsorshipBooking2.Template__c = temp.Id;
		sponsorshipBooking2.Start_Date__c = date.parse('8/10/2020');
		sponsorshipBooking2.End_Date__c = date.parse('8/13/2020');
		sponsorshipBooking2.Syscode__c = '2838';
		sponsorshipBooking2.Network_Code__c = 'S1LA';
        sponsorshipBooking2.Is_Sponsorship_Cancelled__c = true;
        sponsorshipBooking2.RecordTypeId = updatedRecordTypeId;
        sponsorshipBooking2.Booked_Sponsorship__c = booking2.Id;
		insert sponsorshipBooking2;

        Booked_Sponsorship__c bookingStatus1= [Select Id, Name,Status__c from Booked_Sponsorship__c where Id = :booking.Id LIMIT 1];
        Booked_Sponsorship__c bookingStatus2 = [Select Id, Name,Status__c from Booked_Sponsorship__c where Id = :booking2.Id LIMIT 1];

        Test.startTest();
        if(bookingStatus1.Status__c == 'Rejected'){
            DateInventoryHandleRejectBatch testRejectSponsorships = new DateInventoryHandleRejectBatch(booking.Id);
            Database.executeBatch(testRejectSponsorships);
        }
        else if(bookingStatus1.Status__c == 'Approved'){
            DateInventoryHandleRejectBatch testRejectSponsorships = new DateInventoryHandleRejectBatch(booking2.Id);
            Database.executeBatch(testRejectSponsorships);
        }
       
        Test.stopTest();
   }
}