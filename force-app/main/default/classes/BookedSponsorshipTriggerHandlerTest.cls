@IsTest(SeeAllData = false)
public class BookedSponsorshipTriggerHandlerTest {
    
    public static testmethod void testafterUpdateLocalSponsorship(){
        Booked_Sponsorship__c bookedSponsorship = new Booked_Sponsorship__c();
        Opportunity details = new Opportunity();
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

		details.Name = 'INW TDA Olympics Digital';
		details.AccountId = acc.Id;
		details.Owner_Division__c = 'West';
		details.Owner_Region__c = 'Big West';
		details.Owner_Sales_Office__c = 'Kennewick';
		details.StageName = 'Identification';
		details.CloseDate = date.parse('8/28/2016');
		insert details;

        Id BookingRecordTypeId = Schema.SObjectType.Sponsorship_Booking__c.getRecordTypeInfosByName().get('Updated').getRecordTypeId();
        Id OriginalRecordTypeId = Schema.SObjectType.Sponsorship_Booking__c.getRecordTypeInfosByName().get('Original').getRecordTypeId();
        
        Templates__c temp = new Templates__c();
		temp.Name = 'Weather on the Ones - 1';
		temp.Total_Quantity__c = 10;
		temp.Start_Date__c = date.parse('8/28/2020');
		temp.End_Date__c = date.parse('8/29/2020');
		temp.Syscode__c = '2838';
		temp.Network_Code__c = 'S1LA';
		insert temp;

        bookedSponsorship.Opportunity__c = details.Id;
        bookedSponsorship.Status__c = 'Approved';
		bookedSponsorship.Right_to_First_Refusal__c = true;
        insert bookedSponsorship;

        Sponsorship_Booking__c booking = new Sponsorship_Booking__c();
		booking.Template__c = temp.Id;
		booking.Start_Date__c = date.parse('12/28/2020');
		booking.End_Date__c = date.parse('12/29/2020');
		booking.Status__c = 'Pending';
        booking.RecordTypeId = BookingRecordTypeId;
        booking.Booked_Sponsorship__c = bookedSponsorship.Id;
		insert booking;
        
        Test.startTest();
        Booked_Sponsorship__c booking1 = [Select Id, Status__c, Opportunity__c,Right_to_First_Refusal__c From Booked_Sponsorship__c Where Id =: bookedSponsorship.Id];
        booking1.Right_to_First_Refusal__c = false;
        update booking1;
        Test.stopTest();
    }

    public static testmethod void testafterUpdateNational(){
        Booked_Sponsorship__c bookedSponsorship = new Booked_Sponsorship__c();
        Opportunity details = new Opportunity();
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

		details.Name = 'INW TDA Olympics Digital';
		details.AccountId = acc.Id;
		details.Owner_Division__c = 'West';
		details.Owner_Region__c = 'Big West';
		details.Owner_Sales_Office__c = 'Kennewick';
		details.StageName = 'Identification';
		details.CloseDate = date.parse('8/28/2016');
		insert details;

        Id NationalTemplateId = Schema.SObjectType.Templates__c.getRecordTypeInfosByName().get('National').getRecordTypeId();

        //Booking Record Types
        Id BookingRecordTypeId = Schema.SObjectType.Sponsorship_Booking__c.getRecordTypeInfosByName().get('Updated').getRecordTypeId();
        Id OriginalRecordTypeId = Schema.SObjectType.Sponsorship_Booking__c.getRecordTypeInfosByName().get('Original').getRecordTypeId();

        Templates__c temp = new Templates__c();
		temp.Name = 'Weather on the Ones - 1';
		temp.Total_Quantity__c = 10;
		temp.Start_Date__c = date.parse('8/28/2020');
		temp.End_Date__c = date.parse('8/29/2020');
		temp.Syscode__c = '2838';
		temp.Network_Code__c = 'S1LA';
        temp.RecordTypeID = NationalTemplateId;
		insert temp;

        Template_Inventory__c inventory = new Template_Inventory__c();
        inventory.Template__c = temp.Id;
        inventory.Total_Quantity__c = 10;
        inventory.Inventory_Type__c = 'Billboard';
        inventory.Booked_Inventory__c = 2;
        insert inventory;

        bookedSponsorship.Opportunity__c = details.Id;
        bookedSponsorship.Status__c = 'Approved';
		bookedSponsorship.Right_to_First_Refusal__c = true;
        insert bookedSponsorship;

        Sponsorship_Booking__c booking = new Sponsorship_Booking__c();
		booking.Template__c = temp.Id;
		booking.Start_Date__c = date.parse('12/28/2020');
		booking.End_Date__c = date.parse('12/29/2020');
		booking.Status__c = 'Pending';
        booking.RecordTypeId = BookingRecordTypeId;
        booking.Booked_Sponsorship__c = bookedSponsorship.Id;
		insert booking;

        Test.startTest();
        Booked_Sponsorship__c booking2 = [Select Id, Status__c, Opportunity__c,Right_to_First_Refusal__c From Booked_Sponsorship__c Where Id =: bookedSponsorship.Id];
        booking2.Status__c = 'Rejected';
        update booking2;
        Test.stopTest();
    }

    public static testmethod void testafterUpdateNationalReject(){
        Booked_Sponsorship__c bookedSponsorship = new Booked_Sponsorship__c();
        Opportunity details = new Opportunity();
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

		details.Name = 'INW TDA Olympics Digital';
		details.AccountId = acc.Id;
		details.Owner_Division__c = 'West';
		details.Owner_Region__c = 'Big West';
		details.Owner_Sales_Office__c = 'Kennewick';
		details.StageName = 'Identification';
		details.CloseDate = date.parse('8/28/2016');
		insert details;

        Id NationalTemplateId = Schema.SObjectType.Templates__c.getRecordTypeInfosByName().get('National').getRecordTypeId();

        //Booking Record Types
        Id BookingRecordTypeId = Schema.SObjectType.Sponsorship_Booking__c.getRecordTypeInfosByName().get('Updated').getRecordTypeId();
        Id OriginalRecordTypeId = Schema.SObjectType.Sponsorship_Booking__c.getRecordTypeInfosByName().get('Original').getRecordTypeId();

        Templates__c temp = new Templates__c();
		temp.Name = 'Weather on the Ones - 1';
		temp.Total_Quantity__c = 10;
		temp.Start_Date__c = date.parse('8/28/2020');
		temp.End_Date__c = date.parse('8/29/2020');
		temp.Syscode__c = '2838';
		temp.Network_Code__c = 'S1LA';
        temp.RecordTypeID = NationalTemplateId;
		insert temp;
        System.debug('@@@Tmplate Id: '+ temp.Id);

        Template_Inventory__c inventory = new Template_Inventory__c();
        inventory.Template__c = temp.Id;
        inventory.Total_Quantity__c = 10;
        inventory.Inventory_Type__c = 'Billboard';
        inventory.Booked_Inventory__c = 2;
        insert inventory;
        System.debug('@@@Inventory: '+ inventory.Id);

        bookedSponsorship.Opportunity__c = details.Id;
        bookedSponsorship.Status__c = 'In progress';
		bookedSponsorship.Right_to_First_Refusal__c = true;
        bookedSponsorship.Record_Type__c = 'National';
        insert bookedSponsorship;
        System.debug('@@@ Booked Id: '+ bookedSponsorship.Id);

        Sponsorship_Booking__c booking = new Sponsorship_Booking__c();
		booking.Template__c = temp.Id;
		booking.Start_Date__c = date.parse('12/28/2020');
		booking.End_Date__c = date.parse('12/29/2020');
        booking.Quantity__c = 1;
		booking.Status__c = 'Pending';
        booking.RecordTypeId = BookingRecordTypeId;
        booking.Booked_Sponsorship__c = bookedSponsorship.Id;
		insert booking;
        System.debug('@@@Sponsorship Booking1 Id: '+ booking.Id);

        Sponsorship_Booking__c booking2 = new Sponsorship_Booking__c();
		booking2.Template__c = temp.Id;
		booking2.Start_Date__c = date.parse('12/27/2020');
		booking2.End_Date__c = date.parse('12/29/2020');
        booking2.Quantity__c = 2;
		booking2.Status__c = 'Pending';
        booking2.RecordTypeId = OriginalRecordTypeId;
        booking2.Booked_Sponsorship__c = bookedSponsorship.Id;
		insert booking2;
        System.debug('@@@Sponsorship Booking2 Id: '+ booking2.Id);

        Test.startTest();
        Booked_Sponsorship__c bookedSponsorship3 = [Select Id, Status__c, Opportunity__c,Right_to_First_Refusal__c From Booked_Sponsorship__c Where Id =: bookedSponsorship.Id];
        bookedSponsorship3.Right_to_First_Refusal__c = false;
        update bookedSponsorship3;
        Test.stopTest();
    }

    public static testmethod void testafterUpdateLocalSponsorshipApproved(){
        Booked_Sponsorship__c bookedSponsorship = new Booked_Sponsorship__c();
        Opportunity details = new Opportunity();
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

		details.Name = 'INW TDA Olympics Digital';
		details.AccountId = acc.Id;
		details.Owner_Division__c = 'West';
		details.Owner_Region__c = 'Big West';
		details.Owner_Sales_Office__c = 'Kennewick';
		details.StageName = 'Identification';
		details.CloseDate = date.parse('8/28/2016');
		insert details;

        Id BookingRecordTypeId = Schema.SObjectType.Sponsorship_Booking__c.getRecordTypeInfosByName().get('Updated').getRecordTypeId();
        Id OriginalRecordTypeId = Schema.SObjectType.Sponsorship_Booking__c.getRecordTypeInfosByName().get('Original').getRecordTypeId();
        
        Templates__c temp = new Templates__c();
		temp.Name = 'Weather on the Ones - 1';
		temp.Total_Quantity__c = 10;
		temp.Start_Date__c = date.parse('8/28/2020');
		temp.End_Date__c = date.parse('8/29/2020');
		temp.Syscode__c = '2838';
		temp.Network_Code__c = 'S1LA';
		insert temp;

        bookedSponsorship.Opportunity__c = details.Id;
        bookedSponsorship.Status__c = 'In progress';
		bookedSponsorship.Right_to_First_Refusal__c = true;
        insert bookedSponsorship;

        Sponsorship_Booking__c booking = new Sponsorship_Booking__c();
		booking.Template__c = temp.Id;
		booking.Start_Date__c = date.parse('12/28/2020');
		booking.End_Date__c = date.parse('12/29/2020');
		booking.Status__c = 'Pending';
        booking.RecordTypeId = BookingRecordTypeId;
        booking.Booked_Sponsorship__c = bookedSponsorship.Id;
		insert booking;
        
        Test.startTest();
        Booked_Sponsorship__c booking1 = [Select Id, Status__c, Opportunity__c,Right_to_First_Refusal__c From Booked_Sponsorship__c Where Id =: bookedSponsorship.Id];
        booking1.Status__c = 'Approved';
        update booking1;
        Test.stopTest();

    }

    public static testmethod void testafterUpdateLocalSponsorshipCancelled(){
        Booked_Sponsorship__c bookedSponsorship = new Booked_Sponsorship__c();
        Opportunity details = new Opportunity();
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

		details.Name = 'INW TDA Olympics Digital';
		details.AccountId = acc.Id;
		details.Owner_Division__c = 'West';
		details.Owner_Region__c = 'Big West';
		details.Owner_Sales_Office__c = 'Kennewick';
		details.StageName = 'Identification';
		details.CloseDate = date.parse('8/28/2016');
		insert details;

        Id BookingRecordTypeId = Schema.SObjectType.Sponsorship_Booking__c.getRecordTypeInfosByName().get('Updated').getRecordTypeId();
        Id OriginalRecordTypeId = Schema.SObjectType.Sponsorship_Booking__c.getRecordTypeInfosByName().get('Original').getRecordTypeId();
        
        Templates__c temp = new Templates__c();
		temp.Name = 'Weather on the Ones - 1';
		temp.Total_Quantity__c = 10;
		temp.Start_Date__c = date.parse('8/28/2020');
		temp.End_Date__c = date.parse('8/29/2020');
		temp.Syscode__c = '2838';
		temp.Network_Code__c = 'S1LA';
		insert temp;

        bookedSponsorship.Opportunity__c = details.Id;
        bookedSponsorship.Status__c = 'In progress';
		bookedSponsorship.Right_to_First_Refusal__c = true;
        insert bookedSponsorship;

        Sponsorship_Booking__c booking = new Sponsorship_Booking__c();
		booking.Template__c = temp.Id;
		booking.Start_Date__c = date.parse('12/28/2020');
		booking.End_Date__c = date.parse('12/29/2020');
		booking.Status__c = 'Pending';
        booking.Is_Sponsorship_Cancelled__c = true;
        booking.RecordTypeId = BookingRecordTypeId;
        booking.Booked_Sponsorship__c = bookedSponsorship.Id;
		insert booking;

        Sponsorship_Booking__c booking2 = new Sponsorship_Booking__c();
		booking2.Template__c = temp.Id;
		booking2.Start_Date__c = date.parse('12/28/2020');
		booking2.End_Date__c = date.parse('12/29/2020');
		booking2.Status__c = 'Pending';
        booking2.Is_Sponsorship_Cancelled__c = false;
        booking2.RecordTypeId = OriginalRecordTypeId;
        booking2.Booked_Sponsorship__c = bookedSponsorship.Id;
		insert booking2;
        
        Test.startTest();
        Booked_Sponsorship__c booking1 = [Select Id, Status__c, Opportunity__c,Right_to_First_Refusal__c From Booked_Sponsorship__c Where Id =: bookedSponsorship.Id];
        booking1.Status__c = 'Approved';
        update booking1;
        Test.stopTest();

    }

    public static testmethod void testafterUpdateNationalEditedSponsorshipApproved(){
        Booked_Sponsorship__c bookedSponsorship = new Booked_Sponsorship__c();
        Opportunity details = new Opportunity();
        Account acc = new Account();
        Test.startTest();
		acc.Name = 'Test Account';
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
		insert details;

        Id BookingRecordTypeId = Schema.SObjectType.Sponsorship_Booking__c.getRecordTypeInfosByName().get('Updated').getRecordTypeId();
        Id OriginalRecordTypeId = Schema.SObjectType.Sponsorship_Booking__c.getRecordTypeInfosByName().get('Original').getRecordTypeId();
        
        Templates__c temp = new Templates__c();
		temp.Name = 'Weather on the Ones - 1';
		temp.Total_Quantity__c = 10;
		temp.Start_Date__c = date.parse('8/28/2020');
		temp.End_Date__c = date.parse('8/29/2020');
		temp.Syscode__c = '2838';
		temp.Network_Code__c = 'S1LA';
		insert temp;

        Template_Inventory__c inventory = new Template_Inventory__c();
        inventory.Template__c = temp.Id;
        inventory.Total_Quantity__c = 10;
        inventory.Inventory_Type__c = 'Billboard';
        inventory.Booked_Inventory__c = 2;
        insert inventory;

        bookedSponsorship.Opportunity__c = details.Id;
        bookedSponsorship.Status__c = 'In progress';
		bookedSponsorship.Right_to_First_Refusal__c = true;
        bookedSponsorship.Record_Type__c = 'National';
        insert bookedSponsorship;

        Sponsorship_Booking__c booking = new Sponsorship_Booking__c();
		booking.Template__c = temp.Id;
		booking.Start_Date__c = date.parse('12/28/2020');
		booking.End_Date__c = date.parse('12/29/2020');
		booking.Status__c = 'Pending';
        booking.Is_Sponsorship_Cancelled__c = false;
        booking.RecordTypeId = BookingRecordTypeId;
        booking.Booked_Sponsorship__c = bookedSponsorship.Id;
		insert booking;

        Sponsorship_Booking__c booking2 = new Sponsorship_Booking__c();
		booking2.Template__c = temp.Id;
		booking2.Start_Date__c = date.parse('12/28/2020');
		booking2.End_Date__c = date.parse('12/29/2020');
		booking2.Status__c = 'Pending';
        booking2.Is_Sponsorship_Cancelled__c = false;
        booking2.RecordTypeId = OriginalRecordTypeId;
        booking2.Booked_Sponsorship__c = bookedSponsorship.Id;
		insert booking2;

        Booked_Sponsorship_Inventory__c inventory1 = new Booked_Sponsorship_Inventory__c();
        inventory1.Booking_Details__c = booking.Id;
        inventory1.Inventory_Type__c = 'Billboard';
        inventory1.Quantity__c = 2;
        insert inventory1;

        Booked_Sponsorship_Inventory__c inventory2 = new Booked_Sponsorship_Inventory__c();
        inventory2.Booking_Details__c = booking2.Id;
        inventory2.Inventory_Type__c = 'Billboard';
        inventory2.Quantity__c = 3;
        insert inventory2;

        
        Booked_Sponsorship__c booking1 = [Select Id, Status__c, Opportunity__c,Right_to_First_Refusal__c From Booked_Sponsorship__c Where Id =: bookedSponsorship.Id LIMIT 1];
        booking1.Status__c = 'Approved';
        update booking1;
        Test.stopTest();

    }
}