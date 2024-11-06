@IsTest(SeeAllData = false)
public class DateInventoryHandleUpdateBatchTest {

     //Test method to update Date Inventories on the basis of bookings
    public static testmethod void testUpdateInventories(){
        List<Templates__c> sponsorshipList = new List<Templates__c>();
        Map<String,Map<Date,Date>> mapForBookingDetails = new Map<String,Map<Date,Date>>();
        List<Sponsorship_Date_Inventory__c> sponsorshipInventoryList = new List<Sponsorship_Date_Inventory__c>();
        
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
		temp.Start_Date__c = date.parse('8/10/2020');
		temp.End_Date__c = date.parse('8/15/2020');
		temp.Syscode__c = '2838';
		temp.Network_Code__c = 'S1LA';
		insert temp;
        sponsorshipList.add(temp);
        
        Sponsorship_Date_Inventory__c inventory1 = new Sponsorship_Date_Inventory__c();
        inventory1.Sponsorship__c = temp.Id;
        inventory1.Sponsorship_Inventory_Date__c = date.parse('8/10/2020');
        inventory1.Booked_Quantity__c = 1;
        insert inventory1;
        sponsorshipInventoryList.add(inventory1);

        Sponsorship_Date_Inventory__c inventory2 = new Sponsorship_Date_Inventory__c();
        inventory2.Sponsorship__c = temp.Id;
        inventory2.Sponsorship_Inventory_Date__c = date.parse('8/11/2020');
        inventory2.Booked_Quantity__c = 1;
        insert inventory2;
        sponsorshipInventoryList.add(inventory2);

        Sponsorship_Date_Inventory__c inventory3 = new Sponsorship_Date_Inventory__c();
        inventory3.Sponsorship__c = temp.Id;
        inventory3.Sponsorship_Inventory_Date__c = date.parse('8/12/2020');
        inventory3.Booked_Quantity__c = 1;
        insert inventory3;
        sponsorshipInventoryList.add(inventory3);

        Sponsorship_Date_Inventory__c inventory4 = new Sponsorship_Date_Inventory__c();
        inventory4.Sponsorship__c = temp.Id;
        inventory4.Sponsorship_Inventory_Date__c = date.parse('8/13/2020');
        inventory4.Booked_Quantity__c = 1;
        insert inventory4;
        sponsorshipInventoryList.add(inventory4);

        Sponsorship_Date_Inventory__c inventory5 = new Sponsorship_Date_Inventory__c();
        inventory5.Sponsorship__c = temp.Id;
        inventory5.Sponsorship_Inventory_Date__c = date.parse('8/14/2020');
        inventory5.Booked_Quantity__c = 1;
        insert inventory5;
        sponsorshipInventoryList.add(inventory5);

        Sponsorship_Date_Inventory__c inventory6 = new Sponsorship_Date_Inventory__c();
        inventory6.Sponsorship__c = temp.Id;
        inventory6.Sponsorship_Inventory_Date__c = date.parse('8/15/2020');
        inventory6.Booked_Quantity__c = 1;
        insert inventory6;
        sponsorshipInventoryList.add(inventory6);
        
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
		sponsorshipBooking.Start_Date__c = date.parse('8/10/2020');
		sponsorshipBooking.End_Date__c = date.parse('8/12/2020');
		sponsorshipBooking.Status__c = 'Pending';
		sponsorshipBooking.Syscode__c = '2838';
		sponsorshipBooking.Network_Code__c = 'S1LA';
        sponsorshipBooking.Booked_Sponsorship__c = booking.Id;
		insert sponsorshipBooking;
        
        List<Sponsorship_Booking__c> bookingListToUpdate = [Select Id, Name,Start_Date__c,End_Date__c,Template__c from Sponsorship_Booking__c WHERE Template__c = :temp.Id];
        
        for(Templates__c t: sponsorshipList){
				mapForBookingDetails.put(t.Id,new Map<Date,Date>());
		}
		for(Sponsorship_Booking__c s: bookingListToUpdate){
				if(mapForBookingDetails.containsKey(s.Template__c))
				mapForBookingDetails.get(s.Template__c).put(s.Start_Date__c,s.End_Date__c);
		}
        
        Test.startTest();
        DateInventoryHandleUpdateBatch sponInventory2 = new DateInventoryHandleUpdateBatch(booking.Id,null);
        Database.executeBatch(sponInventory2);
		Test.stopTest();
    }

    public static testmethod void testUpdateInventoriesWithDates(){
        List<Templates__c> sponsorshipList = new List<Templates__c>();
        Map<String,Map<Date,Date>> mapForBookingDetails = new Map<String,Map<Date,Date>>();
        List<Sponsorship_Date_Inventory__c> sponsorshipInventoryList = new List<Sponsorship_Date_Inventory__c>();
        List<Sponsorship_Booking__c> bookingListToUpdate = new List<Sponsorship_Booking__c>();
        
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
		temp.Start_Date__c = date.parse('8/10/2020');
		temp.End_Date__c = date.parse('8/15/2020');
		temp.Syscode__c = '2838';
		temp.Network_Code__c = 'S1LA';
		insert temp;
        sponsorshipList.add(temp);
        
        Sponsorship_Date_Inventory__c inventory1 = new Sponsorship_Date_Inventory__c();
        inventory1.Sponsorship__c = temp.Id;
        inventory1.Sponsorship_Inventory_Date__c = date.parse('8/10/2020');
        inventory1.Booked_Quantity__c = 1;
        insert inventory1;
        sponsorshipInventoryList.add(inventory1);

        Sponsorship_Date_Inventory__c inventory2 = new Sponsorship_Date_Inventory__c();
        inventory2.Sponsorship__c = temp.Id;
        inventory2.Sponsorship_Inventory_Date__c = date.parse('8/11/2020');
        inventory2.Booked_Quantity__c = 1;
        insert inventory2;
        sponsorshipInventoryList.add(inventory2);

        Sponsorship_Date_Inventory__c inventory3 = new Sponsorship_Date_Inventory__c();
        inventory3.Sponsorship__c = temp.Id;
        inventory3.Sponsorship_Inventory_Date__c = date.parse('8/12/2020');
        inventory3.Booked_Quantity__c = 1;
        insert inventory3;
        sponsorshipInventoryList.add(inventory3);

        Sponsorship_Date_Inventory__c inventory4 = new Sponsorship_Date_Inventory__c();
        inventory4.Sponsorship__c = temp.Id;
        inventory4.Sponsorship_Inventory_Date__c = date.parse('8/13/2020');
        inventory4.Booked_Quantity__c = 1;
        insert inventory4;
        sponsorshipInventoryList.add(inventory4);

        Sponsorship_Date_Inventory__c inventory5 = new Sponsorship_Date_Inventory__c();
        inventory5.Sponsorship__c = temp.Id;
        inventory5.Sponsorship_Inventory_Date__c = date.parse('8/14/2020');
        inventory5.Booked_Quantity__c = 1;
        insert inventory5;
        sponsorshipInventoryList.add(inventory5);

        Sponsorship_Date_Inventory__c inventory6 = new Sponsorship_Date_Inventory__c();
        inventory6.Sponsorship__c = temp.Id;
        inventory6.Sponsorship_Inventory_Date__c = date.parse('8/15/2020');
        inventory6.Booked_Quantity__c = 1;
        insert inventory6;
        sponsorshipInventoryList.add(inventory6);
        
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
		sponsorshipBooking.Start_Date__c = date.parse('8/10/2020');
		sponsorshipBooking.End_Date__c = date.parse('8/12/2020');
		sponsorshipBooking.Status__c = 'Approved';
		sponsorshipBooking.Syscode__c = '2838';
		sponsorshipBooking.Network_Code__c = 'S1LA';
        sponsorshipBooking.Booked_Sponsorship__c = booking.Id;
		insert sponsorshipBooking;
        bookingListToUpdate.add(sponsorshipBooking);
        
        List<Date> startdates = new List<Date>();
        startdates.add(date.parse('2/10/2020'));
        startdates.add(date.parse('4/10/2020'));
        List<Date> endDates = new List<Date>();
        endDates.add(date.parse('10/10/2020'));
        endDates.add(date.parse('7/10/2020'));

        Test.startTest();
        DateInventoryHandleUpdateBatch sponInventory3 = new DateInventoryHandleUpdateBatch(bookingListToUpdate,startdates,endDates);
        Database.executeBatch(sponInventory3);
		Test.stopTest();
    }

    //Test method to update inventory when Sponsorship is edited.
    public static testmethod void testUpdateInventoriesAfterEdit(){
        List<Templates__c> sponsorshipList = new List<Templates__c>();
        Map<String,Map<Date,Date>> mapForBookingDetails = new Map<String,Map<Date,Date>>();
        List<Sponsorship_Date_Inventory__c> sponsorshipInventoryList = new List<Sponsorship_Date_Inventory__c>();
        List<Sponsorship_Booking__c> bookingListToUpdate = new List<Sponsorship_Booking__c>();
        
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
		temp.Start_Date__c = date.parse('8/10/2020');
		temp.End_Date__c = date.parse('8/15/2020');
		temp.Syscode__c = '2838';
		temp.Network_Code__c = 'S1LA';
		insert temp;
        sponsorshipList.add(temp);
        
        Sponsorship_Date_Inventory__c inventory1 = new Sponsorship_Date_Inventory__c();
        inventory1.Sponsorship__c = temp.Id;
        inventory1.Sponsorship_Inventory_Date__c = date.parse('8/10/2020');
        inventory1.Booked_Quantity__c = 1;
        insert inventory1;
        sponsorshipInventoryList.add(inventory1);

        Sponsorship_Date_Inventory__c inventory2 = new Sponsorship_Date_Inventory__c();
        inventory2.Sponsorship__c = temp.Id;
        inventory2.Sponsorship_Inventory_Date__c = date.parse('8/11/2020');
        inventory2.Booked_Quantity__c = 1;
        insert inventory2;
        sponsorshipInventoryList.add(inventory2);

        Sponsorship_Date_Inventory__c inventory3 = new Sponsorship_Date_Inventory__c();
        inventory3.Sponsorship__c = temp.Id;
        inventory3.Sponsorship_Inventory_Date__c = date.parse('8/12/2020');
        inventory3.Booked_Quantity__c = 1;
        insert inventory3;
        sponsorshipInventoryList.add(inventory3);

        Sponsorship_Date_Inventory__c inventory4 = new Sponsorship_Date_Inventory__c();
        inventory4.Sponsorship__c = temp.Id;
        inventory4.Sponsorship_Inventory_Date__c = date.parse('8/13/2020');
        inventory4.Booked_Quantity__c = 1;
        insert inventory4;
        sponsorshipInventoryList.add(inventory4);

        Sponsorship_Date_Inventory__c inventory5 = new Sponsorship_Date_Inventory__c();
        inventory5.Sponsorship__c = temp.Id;
        inventory5.Sponsorship_Inventory_Date__c = date.parse('8/14/2020');
        inventory5.Booked_Quantity__c = 1;
        insert inventory5;
        sponsorshipInventoryList.add(inventory5);

        Sponsorship_Date_Inventory__c inventory6 = new Sponsorship_Date_Inventory__c();
        inventory6.Sponsorship__c = temp.Id;
        inventory6.Sponsorship_Inventory_Date__c = date.parse('8/15/2020');
        inventory6.Booked_Quantity__c = 1;
        insert inventory6;
        sponsorshipInventoryList.add(inventory6);
        
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
		sponsorshipBooking.Start_Date__c = date.parse('8/10/2020');
		sponsorshipBooking.End_Date__c = date.parse('8/12/2020');
		sponsorshipBooking.Status__c = 'Approved';
		sponsorshipBooking.Syscode__c = '2838';
		sponsorshipBooking.Network_Code__c = 'S1LA';
        sponsorshipBooking.Booked_Sponsorship__c = booking.Id;
		insert sponsorshipBooking;
        bookingListToUpdate.add(sponsorshipBooking);
        
        Test.startTest();
        DateInventoryHandleUpdateBatch sponInventory2 = new DateInventoryHandleUpdateBatch(booking.Id,bookingListToUpdate);
        Database.executeBatch(sponInventory2);
		Test.stopTest();
        
    }
}