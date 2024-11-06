@IsTest(SeeAllData = false)
public class SponsorshipControllerTest {

    public static testmethod void testgetOpportunityDetails() {
        Test.startTest();
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
        System.debug('Details Id: ' + details.Id);

        SponsorshipController.getOpportunityDetails(details.Id);

        Test.stopTest();

    }

    public static testmethod void testgetMaxMinBookedSponsorships() {

        List<SponsorshipController.allSelectedTemplatesWrapper> wrapper = new List<SponsorshipController.allSelectedTemplatesWrapper> ();

        SponsorshipController.allSelectedTemplatesWrapper wrap = new SponsorshipController.allSelectedTemplatesWrapper();

        Templates__c temp = new Templates__c();
        temp.Name = 'Weather on the Ones';
        temp.Total_Quantity__c = 10;
        temp.Start_Date__c = date.parse('8/28/2020');
        temp.End_Date__c = date.parse('8/28/2021');
        temp.Syscode__c = '2838';
        temp.Network_Code__c = 'S1LA';
        insert temp;

        Sponsorship_Date_Inventory__c sponsorshipDateInventory = new Sponsorship_Date_Inventory__c();
        sponsorshipDateInventory.Sponsorship_Inventory_Date__c = date.parse('06/07/2012');
        sponsorshipDateInventory.Booked_Quantity__c = 0;
        sponsorshipDateInventory.Sponsorship__c = temp.id;
        insert sponsorshipDateInventory;


        String EndDate = '2021-10-28';
        String StartDate = '2020-10-28';
        String tempID = temp.Id;

        
        wrap.ed = EndDate;
        wrap.sd = StartDate;
        wrap.tempID = tempID;
        wrapper.add(wrap);
        String testVar = JSON.serialize(wrapper);
        boolean val=false;

        Test.startTest();
        SponsorshipController.getMaxMinBookedSponsorships(testVar,val);
        SponsorshipController.getMaxMinBookedSponsorships(testVar,true);
        Test.stopTest();

    }
    /*public static testmethod void testsendPPMEmail() {

        String bsId;
        List<String> userIDList = new List<String> ();

        Test.startTest();
        //SponsorshipController.sendPPMEmail(bsId,userIDList);
        Test.stopTest();


    }*/

    public static testmethod void testgetMaxMinSponsorships() {
        List<String> recordIds = new List<String> ();
        Date StartDate = date.parse('10/28/2020');
        Date EndDate = date.parse('10/28/2022');

        Templates__c temp = new Templates__c();
        temp.Name = 'Weather on the Ones';
        temp.Total_Quantity__c = 10;
        temp.Start_Date__c = date.parse('8/28/2020');
        temp.End_Date__c = date.parse('8/28/2021');
        temp.Syscode__c = '2838';
        temp.Network_Code__c = 'S1LA';
        insert temp;

        Sponsorship_Date_Inventory__c sponsorshipDateInventory = new Sponsorship_Date_Inventory__c();
        sponsorshipDateInventory.Sponsorship_Inventory_Date__c = date.parse('06/07/2021');
        sponsorshipDateInventory.Booked_Quantity__c = 0;
        sponsorshipDateInventory.Sponsorship__c = temp.id;
        insert sponsorshipDateInventory;

        recordIds.add(temp.Id);
        Test.startTest();
        SponsorshipController.getMaxMinSponsorships(recordIds, StartDate, EndDate);
        
        Test.stopTest();


    }

    public static testmethod void testgetBookingSponsorshipList() {
        Date StartDate = date.parse('10/28/2020');
     

        Templates__c temp = new Templates__c();
        temp.Name = 'Weather on the Ones';
        temp.Total_Quantity__c = 10;
        temp.Start_Date__c = date.parse('8/28/2020');
        temp.End_Date__c = date.parse('8/28/2021');

        temp.Network_Code__c = 'S1LA';
        insert temp;

        Sponsorship_Date_Inventory__c sponsorshipDateInventory = new Sponsorship_Date_Inventory__c();
        sponsorshipDateInventory.Sponsorship_Inventory_Date__c = date.parse('06/07/2012');
        sponsorshipDateInventory.Booked_Quantity__c = 0;
        sponsorshipDateInventory.Sponsorship__c = temp.id;
        insert sponsorshipDateInventory;

        Test.startTest();
        SponsorshipController.getBookingSponsorshipList(sponsorshipDateInventory.id, StartDate);
        Test.stopTest();

    }
    
      public static testmethod void testgetBookingSponsorshipListexport() {
       
        Date start = date.parse('12/28/2020');
        Date endDate = Date.parse('7/28/2021');
        Date newStart = date.parse('8/28/2020');
        Date newEnd = date.parse('1/28/2022');

        Templates__c temp = new Templates__c();
        temp.Name = 'Weather on the Ones';
        temp.Total_Quantity__c = 10;
        temp.Start_Date__c = date.parse('8/28/2022');
        temp.End_Date__c = date.parse('12/28/2022');
        temp.Syscode__c = '2838';
        temp.Network_Code__c = 'S1LA';
          
        insert temp;

        Sponsorship_Date_Inventory__c sponsorshipDateInventory = new Sponsorship_Date_Inventory__c();
        sponsorshipDateInventory.Sponsorship_Inventory_Date__c = date.parse('06/07/2012');
        sponsorshipDateInventory.Booked_Quantity__c = 0;
        sponsorshipDateInventory.Sponsorship__c = temp.id;
        insert sponsorshipDateInventory;

        Test.startTest();
          
        SponsorshipController.getBookingSponsorshipListexport(sponsorshipDateInventory.id, newStart,endDate);
           SponsorshipController.checkStartEndDate(start, endDate, newStart, newEnd);
           SponsorshipController.checkStartEndDates(start, endDate, newStart, newEnd);
        Test.stopTest();

    }

    public static testmethod void testgetTemplatesBookings() {
        List<String> bookingList = new List<String> ();
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
        temp.Start_Date__c = date.parse('8/28/2020');
        temp.End_Date__c = date.parse('8/28/2021');
        temp.Syscode__c = '2838';
        temp.Network_Code__c = 'S1LA';
        insert temp;

        Booked_Sponsorship__c bookedSpon = new Booked_Sponsorship__c();
        bookedSpon.Opportunity__c = details.Id;
        bookedSpon.Status__c = 'New';
        bookedSpon.Right_to_First_Refusal__c = true;
        insert bookedSpon;

        Sponsorship_Booking__c booking = new Sponsorship_Booking__c();
        booking.Name = 'Weather on the Ones';
        booking.Template__c = temp.Id;
        booking.Start_Date__c = date.parse('8/28/2020');
        booking.End_Date__c = date.parse('8/28/2021');
        booking.Status__c = 'Pending';
        booking.Syscode__c = '2838';
        booking.Network_Code__c = 'S1LA';
        booking.Booked_Sponsorship__c = bookedSpon.Id;
        insert booking;
        bookingList.add(temp.id);


        Test.startTest();
        SponsorshipController.getTemplatesBookings(bookingList);
        Test.stopTest();

    }

    public static testmethod void testgetBookedSponsorshipDetails() {
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
        temp.Start_Date__c = date.parse('8/28/2020');
        temp.End_Date__c = date.parse('8/28/2021');
        temp.Syscode__c = '2838';
        temp.Network_Code__c = 'S1LA';
        insert temp;

        Booked_Sponsorship__c bookedSpon = new Booked_Sponsorship__c();
        bookedSpon.Opportunity__c = details.Id;
        bookedSpon.Status__c = 'New';
        bookedSpon.Right_to_First_Refusal__c = true;
        insert bookedSpon;

        Sponsorship_Booking__c booking = new Sponsorship_Booking__c();
        booking.Name = 'Weather on the Ones';
        booking.Template__c = temp.Id;
        booking.Start_Date__c = date.parse('8/28/2020');
        booking.End_Date__c = date.parse('8/28/2021');
        booking.Status__c = 'Pending';
        booking.Syscode__c = '2838';
        booking.Network_Code__c = 'S1LA';
        booking.Booked_Sponsorship__c = bookedSpon.Id;
        insert booking;

        Test.startTest();
        SponsorshipController.getBookedSponsorshipDetails(bookedSpon.Id);
        Test.stopTest();
    }


    public static testmethod void testgetProposalDetails() {

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

        List<String> proposalList = new List<String> ();
        Proposal__c prop = new Proposal__c();
        prop.Opportunity__c = details.Id;
        prop.Start_Date__c = date.parse('8/28/2022');
        prop.End_Date__c = date.parse('8/28/2023');
        insert prop;
        proposalList.add(prop.Id);
        Proposal__c prop2 = new Proposal__c();
        prop2.Opportunity__c = details.Id;
        prop2.Start_Date__c = date.parse('8/28/2022');
        prop2.End_Date__c = date.parse('8/28/2023');
        insert prop2;
        proposalList.add(prop2.Id);

        Test.startTest();
        SponsorshipController.getProposalDetails(proposalList);
        Test.stopTest();

    }

    public static testmethod void testgetTemplateDetails() {
        Inventory__c inv = new Inventory__c();
        inv.Name = 'Local Integration';
        inv.Inventory_Quantity__c = 10;
        insert inv;

        Inventory_Item__c item = new Inventory_Item__c();
        item.Name = 'Weather on the Ones';
        item.Inventory_Name__c = inv.Id;
        item.Inventory_Type__c = 'Local Integration';
        item.Max_Inventory_Quantity__c = 50;
        //item.Network_Id__c = net.Id;
        insert item;

        Templates__c temp = new Templates__c();
        temp.Name = 'Weather on the Ones';
        temp.Total_Quantity__c = 10;
        temp.Start_Date__c = date.parse('8/28/2020');
        temp.End_Date__c = date.parse('8/28/2021');
        temp.Syscode__c = '2838';
        temp.Network_Code__c = 'S1LA';
        insert temp;

        Template_Inventory__c tempInventory = new Template_Inventory__c();
        tempInventory.Template__c = temp.Id;
        temp.Inventory_Type__c = 'Local Integration';
        insert tempInventory;

        Test.startTest();
        SponsorshipController.getTemplateDetails(tempInventory.Id);

        Test.stopTest();



    }

    public static testmethod void testgetBookedSponsorships() {

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
        temp.Name = 'Weather on the Ones - 1';
        temp.Total_Quantity__c = 10;
        temp.Start_Date__c = date.parse('8/28/2020');
        temp.End_Date__c = date.parse('8/28/2021');
        temp.Syscode__c = '2838';
        temp.Network_Code__c = 'S1LA';
        insert temp;

        Templates__c temp1 = new Templates__c();
        temp1.Name = 'Weather on the Ones - 2';
        temp1.Total_Quantity__c = 10;
        temp1.Start_Date__c = date.parse('10/28/2020');
        temp1.End_Date__c = date.parse('10/28/2021');
        temp1.Syscode__c = '2838';
        temp1.Network_Code__c = 'S1LA';
        insert temp1;

        Templates__c temp2 = new Templates__c();
        temp2.Name = 'Weather on the Ones - 3';
        temp2.Total_Quantity__c = 10;
        temp2.Start_Date__c = date.parse('1/28/2020');
        temp2.End_Date__c = date.parse('1/28/2021');
        temp2.Syscode__c = '2838';
        temp2.Network_Code__c = 'S1LA';
        insert temp2;

        Booked_Sponsorship__c bookedSpon = new Booked_Sponsorship__c();
        bookedSpon.Opportunity__c = details.Id;
        bookedSpon.Status__c = 'New';
        bookedSpon.Right_to_First_Refusal__c = true;
        insert bookedSpon;

        Sponsorship_Booking__c booking = new Sponsorship_Booking__c();
        booking.Template__c = temp.Id;
        booking.Start_Date__c = date.parse('8/28/2020');
        booking.End_Date__c = date.parse('8/28/2021');
        booking.Status__c = 'Pending';
        booking.Booked_Sponsorship__c = bookedSpon.Id;
        insert booking;

        List<String> templateIds = new List<String> ();
        templateIds.add(temp.Id);
        templateIds.add(temp1.Id);
        templateIds.add(temp2.Id);

        Test.startTest();
        SponsorshipController.getBookedSponsorships(templateIds);
        SponsorshipController.getTemplateStatistics(booking.Id);
        SponsorshipController.checkApprovalProcess(bookedSpon.Id);
        SponsorshipController.getBookedTemplates(templateIds, bookedSpon.Id);
        SponsorshipController.getBookedTemplates(templateIds, null);
        Test.stopTest();


    }

    public static testmethod void testcreateBookingRecord() {
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
        Templates__c temp1 = new Templates__c();
        temp1.Name = 'Weather on the Ones - 2';
        temp1.Total_Quantity__c = 10;
        temp1.Start_Date__c = date.parse('10/28/2020');
        temp1.End_Date__c = date.parse('10/28/2021');
        temp1.Syscode__c = '2838';
        temp1.Network_Code__c = 'S1LA';
        insert temp1;

        Syscode_and_Network__c codeId = new Syscode_and_Network__c();
        codeId.Name = '0117';
        codeId.Market__c = 'El Paso';
        codeId.MVPD__c = 'Spectrum';
        codeId.Network_Code__c = 'S1EP';
        codeId.State__c = 'TX';
        codeId.System_Name__c = 'ELPA';
        codeId.System_type__c = 'Cable System';
        insert codeId;


        List<SponsorshipController.bookingSponsorshipWrapper> wrapper = new List<SponsorshipController.bookingSponsorshipWrapper> ();
        List<SponsorshipController.inventoryDetails> inventoryList = new List<SponsorshipController.inventoryDetails> ();
        String label = 'Weather on the Ones';
        String Id = temp1.Id;
        Date StartDate = date.parse('10/28/2020');
        Date EndDate = date.parse('10/28/2021');
        Boolean showInGraph = true;
        Boolean isRenewal = false;
        Boolean DateError = false;
        String Syscode = '0117';
        String State = 'TX';
        String Market = 'El Paso';
        String SystemName = 'ELPA';
        String SystemType = 'Cable System';
        String Mvpd = 'Spectrum';
        String NetworkCode = 'S1EP';
        Boolean rangeError = false;
        Date templateStartDate = date.parse('5/28/2020');
        Date templateEndDate = date.parse('10/28/2022');
        Date UIStartDate = date.parse('5/28/2020');
        Date UIEndDate = date.parse('10/28/2022');
        Boolean bookedError = false;
        Integer totalQty = 30;
        String Qty = '5';
        Boolean isUpdate = false;
        Boolean isCanceled = false;
        String syscodeId = codeId.Id;

        Template_Inventory__c tempInventory = new Template_Inventory__c();
        tempInventory.Template__c = temp1.Id;
        tempInventory.Inventory_Type__c = 'Integration';
        tempInventory.Total_quantity__c = 30;
        tempInventory.Booked_Inventory__c = 10;
        insert tempInventory;


        SponsorshipController.inventoryDetails invt1 = new SponsorshipController.inventoryDetails('Billboard', 10, temp1.Id, tempInventory.Id, 30, 10);
        inventoryList.add(invt1);
        SponsorshipController.bookingSponsorshipWrapper wrap = new SponsorshipController.bookingSponsorshipWrapper(label, Id, StartDate, EndDate, showInGraph,isRenewal,DateError, Syscode, State, Market, SystemName, SystemType, Mvpd, NetworkCode, rangeError, templateStartDate, templateEndDate, bookedError, totalQty, Qty, isUpdate, isCanceled, inventoryList, 10, 10, syscodeId, UIStartDate, UIEndDate);
        wrapper.add(wrap);

        List<Sponsorship_Booking__c> bookinglList = new List<Sponsorship_Booking__c> ();
        List<String> proposalList = new List<String> ();
        Proposal__c prop = new Proposal__c();
        prop.Opportunity__c = details.Id;
        prop.Start_Date__c = date.parse('8/28/2022');
        prop.End_Date__c = date.parse('8/28/2023');
        insert prop;
        proposalList.add(prop.Id);
        Proposal__c prop2 = new Proposal__c();
        prop2.Opportunity__c = details.Id;
        prop2.Start_Date__c = date.parse('8/28/2022');
        prop2.End_Date__c = date.parse('8/28/2023');
        insert prop2;
        proposalList.add(prop2.Id);

        Booked_Sponsorship__c bookedSpon = new Booked_Sponsorship__c();
        bookedSpon.Opportunity__c = details.Id;
        bookedSpon.Status__c = 'New';
        bookedSpon.Right_to_First_Refusal__c = true;
        insert bookedSpon;

        Id nationalRecordTypeId = Schema.SObjectType.Templates__c.getRecordTypeInfosByName().get('National').getRecordTypeId();

        Templates__c temp3 = new Templates__c();
        temp3.Name = 'Weather on the Ones - 1 - National';
        temp3.Total_Quantity__c = 20;
        temp3.Start_Date__c = date.parse('9/28/2020');
        temp3.End_Date__c = date.parse('9/28/2022');
        temp3.Syscode__c = '2838';
        temp3.Network_Code__c = 'S1LA';
        temp3.Inventory_Type__c = 'Integration';
        temp3.RecordTypeId = nationalRecordTypeId;
        insert temp3;

        Template_Inventory__c tempInventory2 = new Template_Inventory__c();
        tempInventory2.Template__c = temp3.Id;
        tempInventory2.Total_Quantity__c = 20;
        tempInventory2.Inventory_Type__c = 'Integration';
        tempInventory2.Booked_Inventory__c = 5;
        insert tempInventory2;

        Booked_Sponsorship__c nationalbookedSpon = new Booked_Sponsorship__c();
        nationalbookedSpon.Opportunity__c = details.Id;
        nationalbookedSpon.Status__c = 'New';
        nationalbookedSpon.Right_to_First_Refusal__c = true;
        nationalbookedSpon.Comments__c = 'national Sponsorship';
        nationalbookedSpon.Record_Type__c = 'National';
        insert nationalbookedSpon;

        Sponsorship_Booking__c nationalbooking2 = new Sponsorship_Booking__c();
        nationalbooking2.Template__c = temp3.Id;
        nationalbooking2.Start_Date__c = date.parse('12/28/2020');
        nationalbooking2.End_Date__c = date.parse('12/28/2021');
        nationalbooking2.Status__c = 'Pending';
        nationalbooking2.Booked_Sponsorship__c = nationalbookedSpon.Id;
        nationalbooking2.Inventory_Type__c = 'Integration';
        nationalbooking2.Quantity__c = 5;
        insert nationalbooking2;
        bookinglList.add(nationalbooking2);

        Sponsorship_Booking__c nationalbooking3 = new Sponsorship_Booking__c();
        nationalbooking3.Template__c = temp3.Id;
        nationalbooking3.Start_Date__c = date.parse('12/28/2020');
        nationalbooking3.End_Date__c = date.parse('12/28/2021');
        nationalbooking3.Status__c = 'Pending';
        nationalbooking3.Booked_Sponsorship__c = nationalbookedSpon.Id;
        nationalbooking3.Inventory_Type__c = 'Integration';
        nationalbooking3.Quantity__c = 5;
        insert nationalbooking3;
        bookinglList.add(nationalbooking3);

        Booked_Sponsorship_Inventory__c nationalBookedInventory = new Booked_Sponsorship_Inventory__c();
        nationalBookedInventory.Booking_Details__c = nationalbooking2.Id;
        nationalBookedInventory.Inventory_Type__c = 'Integration';
        nationalBookedInventory.Quantity__c = 10;
        insert nationalBookedInventory;

        Syscode_and_Network__c syscodeId2 = new Syscode_and_Network__c();
        syscodeId2.Name = '2838';
        syscodeId2.Market__c = 'El Paso';
        syscodeId2.MVPD__c = 'Spectrum';
        syscodeId2.Network_Code__c = 'S1LA';
        syscodeId2.State__c = 'TX';
        syscodeId2.System_Name__c = 'ELPA';
        syscodeId2.System_type__c = 'Cable System';
        insert syscodeId2;

        List<String> templateList = new List<String> ();
        String label2 = 'Weather on the Ones';
        String Id2 = temp3.Id;
        Date StartDate2 = date.parse('10/28/2020');
        Date EndDate2 = date.parse('10/28/2021');
        Boolean showInGraph2 = true;
         Boolean isRenewal2 = false;
        Boolean DateError2 = false;
        String Syscode2 = '2838';
        String State2 = 'TX';
        String Market2 = 'El Paso';
        String SystemName2 = 'ELPA';
        String SystemType2 = 'Cable System';
        String Mvpd2 = 'Spectrum';
        String NetworkCode2 = 'S1LA';
        Boolean rangeError2 = false;
        Date templateStartDate2 = date.parse('9/28/2020');
        Date templateEndDate2 = date.parse('9/28/2022');
        Boolean bookedError2 = false;
        Integer totalQty2 = 30;
        String Qty2 = '5';
        Boolean isUpdate2 = false;
        Boolean isCanceled2 = false;
        String codeId2 = syscodeId2.Id;

        templateList.add(label);
        templateList.add(label2);
        List<SponsorshipController.bookingSponsorshipWrapper> wrapper2 = new List<SponsorshipController.bookingSponsorshipWrapper> ();
        SponsorshipController.bookingSponsorshipWrapper wrap2 = new SponsorshipController.bookingSponsorshipWrapper(label2, Id2, StartDate2, EndDate2, showInGraph2,isRenewal2, DateError2, Syscode2, State2, Market2, SystemName2, SystemType2, Mvpd2, NetworkCode2, rangeError2, templateStartDate2, templateEndDate2, bookedError2, totalQty2, Qty2, isUpdate2, isCanceled2, inventoryList, 10, 10, codeId2, UIStartDate, UIEndDate);
        wrapper2.add(wrap2);
        List<SponsorshipController.bookingDetailsWrapper> availabilityWrapper = new List<SponsorshipController.bookingDetailsWrapper> ();
        SponsorshipController.bookingDetailsWrapper availablewrap = new SponsorshipController.bookingDetailsWrapper(Id2, StartDate2, EndDate2, totalQty2, bookinglList);
        availabilityWrapper.add(availablewrap);

        Test.startTest();
        SponsorshipController.createBookingRecord(details.Id, wrapper, proposalList, true, 'Local', 'Testing template','New');
        SponsorshipController.createBookingRecord(details.Id, wrapper, proposalList, true, 'National', 'Testing National template','New');
        SponsorshipController.createEditedBookingRecord(details.Id, wrapper, proposalList, bookedSpon.Id, true, 'Local', 'Testing Template','Revised');
        SponsorshipController.createEditedBookingRecord(details.Id, wrapper, proposalList, nationalbookedSpon.Id, true, 'National', 'Testing Template','Revised');
        SponsorshipController.submitForApproval(bookedSpon.Id);
        SponsorshipController controller = new SponsorshipController();
        controller.sendBookingEmail(bookinglList, false, nationalbookedSpon.Id);
        SponsorshipController.getProposalList(bookedSpon.Id);
        SponsorshipController.getTemplateInventory(templateList);
        SponsorshipController.sponsorshipBookingAvailability(availabilityWrapper);
        Test.stopTest();
    }
    
    public static testmethod void testsendPPMEmail(){
      Opportunity opp = new Opportunity();
        Profile prof = [SELECT Id, Name FROM Profile WHERE Name like 'System Administrator' LIMIT 1];
        User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        List<String> userId = new List<String>();
        userId.add(thisUser.Id);
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

        Templates__c temp1 = new Templates__c();
        temp1.Name = ' Test Weather on the Ones';
        temp1.Total_Quantity__c = 10;
        temp1.Start_Date__c = date.parse('10/28/2020');
        temp1.End_Date__c = date.parse('10/28/2021');
        temp1.Syscode__c = '2838';
        temp1.Network_Code__c = 'S1LA';
        insert temp1;

        Syscode_and_Network__c codeId = new Syscode_and_Network__c();
        codeId.Name = '0117';
        codeId.Market__c = 'El Paso';
        codeId.MVPD__c = 'Spectrum';
        codeId.Network_Code__c = 'S1EP';
        codeId.State__c = 'TX';
        codeId.System_Name__c = 'ELPA';
        codeId.System_type__c = 'Cable System';
        codeId.PPM1__c = thisUser.Id;
        codeId.Sales_Director__c = thisUser.Id;
        insert codeId;

        Booked_Sponsorship__c bookedSpon = new Booked_Sponsorship__c();
        bookedSpon.Opportunity__c = opp.Id;
        bookedSpon.Status__c = 'New';
        bookedSpon.Right_to_First_Refusal__c = true;
        insert bookedSpon;

        Sponsorship_Booking__c bookingDetails = new Sponsorship_Booking__c();
        bookingDetails.Template__c = temp1.Id;
        bookingDetails.Start_Date__c = date.parse('1/28/2020');
        bookingDetails.End_Date__c = date.parse('8/28/2021');
        bookingDetails.Status__c = 'Approved';
        bookingDetails.Booked_Sponsorship__c = bookedSpon.Id;
        insert bookingDetails;
        
        Test.startTest();
        	SponsorshipController.sendPPMEmail(bookedSpon.Id,userId);
        Test.stopTest();
    }

    public static testmethod void testfetchAllSponsorship(){
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

        Templates__c temp1 = new Templates__c();
        temp1.Name = ' Test Weather on the Ones';
        temp1.Total_Quantity__c = 10;
        temp1.Start_Date__c = date.parse('10/28/2020');
        temp1.End_Date__c = date.parse('10/28/2021');
        temp1.Syscode__c = '2838';
        temp1.Network_Code__c = 'S1LA';
        insert temp1;

        Syscode_and_Network__c codeId = new Syscode_and_Network__c();
        codeId.Name = '0117';
        codeId.Market__c = 'El Paso';
        codeId.MVPD__c = 'Spectrum';
        codeId.Network_Code__c = 'S1EP';
        codeId.State__c = 'TX';
        codeId.System_Name__c = 'ELPA';
        codeId.System_type__c = 'Cable System';
        insert codeId;

        Booked_Sponsorship__c bookedSpon = new Booked_Sponsorship__c();
        bookedSpon.Opportunity__c = opp.Id;
        bookedSpon.Status__c = 'New';
        bookedSpon.Right_to_First_Refusal__c = true;
        insert bookedSpon;

        Sponsorship_Booking__c bookingDetails = new Sponsorship_Booking__c();
        bookingDetails.Template__c = temp1.Id;
        bookingDetails.Start_Date__c = date.parse('1/28/2020');
        bookingDetails.End_Date__c = date.parse('8/28/2021');
        bookingDetails.Status__c = 'Approved';
        bookingDetails.Booked_Sponsorship__c = bookedSpon.Id;
        insert bookingDetails;

        String sponsorshipId = temp1.Id;
        Date startDate = date.parse('3/1/2021');
        Date endDate = date.parse('6/30/2021');

        Test.startTest();
           //SponsorshipController.fetchAllSponsorship(sponsorshipId,startDate,endDate,null);
            SponsorshipController.fetchAllSponsorship(sponsorshipId,startDate,endDate,bookingDetails.Id);
        Test.stopTest();

    }

    public static testmethod void testcheckTeamMember() {
        Profile prof = [SELECT Id, Name FROM Profile WHERE Name like 'System Administrator' LIMIT 1];
        User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
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
		
        List<Profile> profList = [SELECT Id,Name FROM Profile WHERE Name like '%Account Executive%'];
        //User userAETestForOpp = TestUtil.createAEUser();
        User userAETestForOpp = new User();
            userAETestForOpp.Alias = 'Test1';
            userAETestForOpp.Email = 'test1@mandsconsulting.com';
            userAETestForOpp.EmailEncodingKey = 'UTF-8';
            userAETestForOpp.LastName = 'Test1';
            userAETestForOpp.LanguageLocaleKey = 'en_US';
            userAETestForOpp.LocaleSidKey = 'en_US';
            userAETestForOpp.TimeZoneSidKey='America/Los_Angeles';
            userAETestForOpp.ProfileId =profList[0].Id;
            userAETestForOpp.UserName='testsales1@mands.com';
            insert userAETestForOpp;
        
        List<OpportunityTeamMember> oppMember = new List<OpportunityTeamMember> ();
        OpportunityTeamMember opp1 = new OpportunityTeamMember();
        opp1.UserId = userAETestForOpp.Id;
        opp1.OpportunityId = details.Id;
        insert opp1;
        oppMember.add(opp1);


        Test.startTest();
        SponsorshipController.checkTeamMember(details.Id, userAETestForOpp.Id);
        Test.stopTest();

    }

    public static testmethod void testsyscodeDetails() {
        Syscode_and_Network__c sys = new Syscode_and_Network__c();
        sys.Name = '0117';
        sys.Description__c = 'Spectrum News Texas Southern Tier';
        sys.Market__c = 'El Paso';
        sys.MVPD__c = 'Spectrum';
        sys.State__c = 'TX';
        sys.Network_Code__c = 'S1EP';
        sys.System_Name__c = 'ELPA';
        sys.System_type__c = 'Cable System';
        insert sys;

        Test.startTest();
        SponsorshipController.syscodeDetails(sys.Id);
        Test.stopTest();
    }
    
    public static testmethod void testcreateSponsorshipForm() {
        Syscode_and_Network__c ns=new Syscode_and_Network__c();
        ns.Name='test';
        insert ns;
        Templates__c templateObject = new Templates__c();
        templateObject.Name='testingName';
        templateObject.News_Syscode__c=ns.id;
       
        insert templateObject;
        
        Test.startTest();
        SponsorshipController.createSponsorship(templateObject.Id);
        Test.stopTest();
        
    }
    
    
    public static testmethod void testgetBookedTemplates() {

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

        Inventory__c inv = new Inventory__c();
        inv.Name = 'Local Integration';
        inv.Inventory_Quantity__c = 10;
        insert inv;

        //Network__c net = new Network__c();
        //net.Name = 'CTCA';
        //insert net;

        Inventory_Item__c item = new Inventory_Item__c();
        item.Name = 'Weather on the Ones';
        item.Inventory_Name__c = inv.Id;
        item.Inventory_Type__c = 'Local Integration';
        item.Max_Inventory_Quantity__c = 50;
        //item.Network_Id__c = net.Id;
        insert item;

        Templates__c temp = new Templates__c();
        temp.Name = 'Weather on the Ones - 1';
        temp.Total_Quantity__c = 10;
        temp.Start_Date__c = date.parse('8/28/2020');
        temp.End_Date__c = date.parse('8/28/2021');
        temp.Syscode__c = '2838';
        temp.Network_Code__c = 'S1LA';
        insert temp;

        Template_Inventory__c tempInventory = new Template_Inventory__c();
        tempInventory.Template__c = temp.Id;
        temp.Inventory_Type__c = 'Local Integration';
        insert tempInventory;

        Booked_Sponsorship__c bookedSpon = new Booked_Sponsorship__c();
        bookedSpon.Opportunity__c = details.Id;
        bookedSpon.Status__c = 'New';
        bookedSpon.Right_to_First_Refusal__c = true;
        insert bookedSpon;

        Sponsorship_Booking__c booking = new Sponsorship_Booking__c();
        booking.Name = 'Weather on the Ones';
        booking.Template__c = temp.Id;
        booking.Start_Date__c = date.parse('8/28/2020');
        booking.End_Date__c = date.parse('8/28/2021');
        booking.Status__c = 'Pending';
        booking.Syscode__c = '2838';
        booking.Network_Code__c = 'S1LA';
        booking.Booked_Sponsorship__c = bookedSpon.Id;
        insert booking;

        Available_Template__c available = new Available_Template__c();
        available.Sponsorship_Booking__c = booking.Id;
        available.Template_Inventory__c = tempInventory.Id;
        available.Template__c = temp.Id;
        available.Is_Available__c = true;
        insert available;

        String templateName = booking.Name;
        String syscode = booking.Syscode__c;
        String NetworkCode = booking.Network_Code__c;


        // Test.startTest();
        // SponsorshipController.getBookedTemplates(templateName,syscode,NetworkCode,booking.Start_Date__c,booking.End_Date__c);

        // Test.stopTest();

    }
    public static testmethod void testgetSelectedAvailableTemplateDetails() {
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

        Inventory__c inv = new Inventory__c();
        inv.Name = 'Local Integration';
        inv.Inventory_Quantity__c = 10;
        insert inv;

        //Network__c net = new Network__c();
        //net.Name = 'CTCA';
        //insert net;

        Inventory_Item__c item = new Inventory_Item__c();
        item.Name = 'Weather on the Ones';
        item.Inventory_Name__c = inv.Id;
        item.Inventory_Type__c = 'Local Integration';
        item.Max_Inventory_Quantity__c = 50;
        //item.Network_Id__c = net.Id;
        insert item;

        Templates__c temp = new Templates__c();
        temp.Name = 'Weather on the Ones - 1';
        temp.Total_Quantity__c = 10;
        temp.Start_Date__c = date.parse('8/28/2020');
        temp.End_Date__c = date.parse('8/28/2021');
        temp.Syscode__c = '2838';
        temp.Network_Code__c = 'S1LA';
        insert temp;

        Template_Inventory__c tempInventory = new Template_Inventory__c();
        tempInventory.Template__c = temp.Id;
        temp.Inventory_Type__c = 'Local Integration';
        insert tempInventory;

        Booked_Sponsorship__c bookedSpon = new Booked_Sponsorship__c();
        bookedSpon.Opportunity__c = details.Id;
        bookedSpon.Status__c = 'New';
        bookedSpon.Right_to_First_Refusal__c = true;
        insert bookedSpon;

        Sponsorship_Booking__c booking = new Sponsorship_Booking__c();
        booking.Name = 'Weather on the Ones';
        booking.Template__c = temp.Id;
        booking.Start_Date__c = date.parse('8/28/2020');
        booking.End_Date__c = date.parse('8/28/2021');
        booking.Status__c = 'Pending';
        booking.Syscode__c = '2838';
        booking.Network_Code__c = 'S1LA';
        booking.Booked_Sponsorship__c = bookedSpon.Id;
        insert booking;

        Available_Template__c available = new Available_Template__c();
        available.Sponsorship_Booking__c = booking.Id;
        available.Template_Inventory__c = tempInventory.Id;
        available.Template__c = temp.Id;
        available.Is_Available__c = true;
        insert available;
        String templateId = available.Id;
        Test.startTest();

        SponsorshipController.getSelectedAvailableTemplateDetails(templateId);

        Test.stopTest();
    }

    public static testmethod void testgetAvailableTemplates() {

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

        List<String> tempList = new List<String> ();
        Templates__c temp = new Templates__c();
        temp.Name = 'Weather on the Ones - 1';
        temp.Total_Quantity__c = 10;
        temp.Start_Date__c = date.parse('8/28/2020');
        temp.End_Date__c = date.parse('8/28/2021');
        temp.Syscode__c = '2838';
        temp.Network_Code__c = 'S1LA';
        insert temp;
        tempList.add(temp.Id);

        Templates__c temp2 = new Templates__c();
        temp2.Name = 'Weather on the Ones - 2';
        temp2.Total_Quantity__c = 10;
        temp2.Start_Date__c = date.parse('9/28/2020');
        temp2.End_Date__c = date.parse('9/28/2022');
        temp2.Syscode__c = '2838';
        temp2.Network_Code__c = 'S1LA';
        insert temp2;
        tempList.add(temp2.Id);

        Template_Inventory__c tempInventory = new Template_Inventory__c();
        tempInventory.Template__c = temp.Id;
        temp.Inventory_Type__c = 'Local Integration';
        insert tempInventory;

        Booked_Sponsorship__c bookedSpon = new Booked_Sponsorship__c();
        bookedSpon.Opportunity__c = details.Id;
        bookedSpon.Status__c = 'New';
        bookedSpon.Right_to_First_Refusal__c = true;
        insert bookedSpon;

        Sponsorship_Booking__c booking = new Sponsorship_Booking__c();
        booking.Name = 'Weather on the Ones';
        booking.Template__c = temp.Id;
        booking.Start_Date__c = date.parse('8/28/2020');
        temp.End_Date__c = date.parse('8/28/2021');
        booking.Status__c = 'Pending';
        booking.Syscode__c = '2838';
        booking.Network_Code__c = 'S1LA';
        booking.Booked_Sponsorship__c = bookedSpon.Id;
        insert booking;

        Available_Template__c available = new Available_Template__c();
        available.Sponsorship_Booking__c = booking.Id;
        available.Template_Inventory__c = tempInventory.Id;
        available.Template__c = temp.Id;
        available.Is_Available__c = true;
        insert available;

        Test.startTest();
        SponsorshipController.getAvailableTemplates(temp.Name, temp.Syscode__c, temp.Network_Code__c);
        SponsorshipController.showPopUpInfo(booking.Id);
        SponsorshipController.getTemplateInfo(tempList);
        Test.stopTest();

    }

    public static testmethod void testgetSelectedTemplateDetails() {
        Templates__c temp = new Templates__c();
        temp.Name = 'Weather on the Ones - 1';
        temp.Total_Quantity__c = 10;
        temp.Start_Date__c = date.parse('8/28/2020');
        temp.End_Date__c = date.parse('8/28/2021');
        temp.Syscode__c = '2838';
        temp.Network_Code__c = 'S1LA';
        insert temp;

        Template_Inventory__c tempInventory = new Template_Inventory__c();
        tempInventory.Template__c = temp.Id;
        temp.Inventory_Type__c = 'Local Integration';
        insert tempInventory;

        Test.startTest();
        SponsorshipController.getSelectedTemplateDetails(temp.Id);

        Test.stopTest();

    }


    public static testmethod void testupdateTemplate() {
        Templates__c temp = new Templates__c();
        temp.Name = 'Weather on the Ones - 1';
        temp.Total_Quantity__c = 10;
        temp.Start_Date__c = date.parse('8/28/2020');
        temp.End_Date__c = date.parse('8/28/2021');
        temp.Syscode__c = '2838';
        temp.Network_Code__c = 'S1LA';
        insert temp;

        Date start = date.parse('5/28/2021');

        Test.startTest();
        SponsorshipController.updateTemplate(start, temp.Id);

        Test.stopTest();

    }




    public static testmethod void testcheckStartEndDate() {
        Date start = date.parse('12/28/2020');
        Date endDate = Date.parse('7/28/2021');
        Date newStart = date.parse('8/28/2020');
        Date newEnd = date.parse('1/28/2022');

        Test.startTest();
        SponsorshipController.checkStartEndDate(start, endDate, newStart, newEnd);
         SponsorshipController.checkStartEndDates(start, endDate, newStart, newEnd);

        Test.stopTest();

    }

    public static testmethod void testfindRecords() {
        Syscode_and_Network__c sys = new Syscode_and_Network__c();

        insert sys; sys.Name = '0117';
        sys.Description__c = 'Spectrum News Texas Southern Tier';
        sys.Market__c = 'El Paso';
        sys.MVPD__c = 'Spectrum';
        sys.State__c = 'TX';
        sys.Network_Code__c = 'S1EP';
        sys.System_Name__c = 'ELPA';
        sys.System_type__c = 'Cable System';

        Test.startTest();
        SponsorshipController.findRecords('2838', 'Syscode_and_Network__c');
        SponsorshipController.getNetworkSyscodeMap();
        Test.stopTest();
    }

    public static testmethod void testgetAvailableTemplateStatistics() {

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
        temp.Name = 'Weather on the Ones - 1';
        temp.Total_Quantity__c = 10;
        temp.Start_Date__c = date.parse('8/28/2020');
        temp.End_Date__c = date.parse('8/28/2021');
        temp.Syscode__c = '2838';
        temp.Network_Code__c = 'S1LA';
        insert temp;

        Booked_Sponsorship__c bookedSpon = new Booked_Sponsorship__c();
        bookedSpon.Opportunity__c = details.Id;
        bookedSpon.Status__c = 'New';
        bookedSpon.Right_to_First_Refusal__c = true;
        insert bookedSpon;

        Sponsorship_Booking__c booking = new Sponsorship_Booking__c();
        booking.Name = 'Weather on the Ones';
        booking.Template__c = temp.Id;
        booking.Start_Date__c = date.parse('10/28/2020');
        booking.End_Date__c = date.parse('12/28/2020');
        booking.Status__c = 'Pending';
        booking.Syscode__c = '2838';
        booking.Network_Code__c = 'S1LA';
        booking.Booked_Sponsorship__c = bookedSpon.Id;
        insert booking;

        Date newStart = date.parse('8/28/2020');
        Date newEnd = date.parse('1/28/2022');

        Test.startTest();
        SponsorshipController.getAvailableTemplateStatistics(temp.Id, newStart, newEnd);
        Test.stopTest();


    }
    
    public static testmethod void  Testsponsorshipid() {
        List<Templates__c> lsttemp=new List<Templates__c>();
          Templates__c temp = new Templates__c();
        temp.Name = 'Weather on the Ones - 1';
        temp.Total_Quantity__c = 10;
        temp.Start_Date__c = date.parse('8/28/2020');
        temp.End_Date__c = date.parse('8/28/2021');
        temp.Syscode__c = '2838';
        temp.Network_Code__c = 'S1LA';
        insert temp;
        lsttemp.add(temp);
       
        Syscode_and_Network__c sys = new Syscode_and_Network__c();
        sys.Name = '2425';
        insert sys;
        
        List<SponsorshipController.sponsorshipWrapper> lstsponwarp=new List<SponsorshipController.sponsorshipWrapper>();
        SponsorshipController.sponsorshipWrapper SponWrapp=new SponsorshipController.sponsorshipWrapper();
          SponWrapp.id =temp.id;
        SponWrapp.sObjectType='Temaplate__c';
         SponWrapp.title=temp.Name;
         SponWrapp.subtitle=temp.Name;
         SponWrapp.StartDate= temp.Start_Date__c;
         SponWrapp.EndDate=temp.End_Date__c;
         SponWrapp.Quantity= temp.Total_Quantity__c;
            SponWrapp.IsActive=true;
       lstsponwarp.add(SponWrapp);
        
        List<Templates__c> lsttemp1 = new List<Templates__c>();
    for(Integer i = 0; i < 5; i++) {
        Templates__c temp1 = new Templates__c();
        temp1.Name = 'Weather on the Ones - ' + i;
        temp1.Total_Quantity__c = 10;
        temp1.Start_Date__c = Date.today();
        temp1.End_Date__c = Date.today().addDays(365);
        temp1.Syscode__c = '2838';
        temp1.News_Syscode__c = sys.Id;
        
        lsttemp1.add(temp1);
    }
	insert lsttemp1;
        
        
        
        
         Test.startTest();
        //sp.sWrapper = new List<SponsorshipController.sponsorshipWrapper>();
        SponsorshipController.sponsorshipid(sys.Id);
         Test.stopTest();
    }
    
    
    public static testmethod void  TesttoActiveCheckBox() {
Bulk_Sponsorship__c bulkSponsorShipObject = new Bulk_Sponsorship__c();
bulkSponsorShipObject.Active__c = true;
		insert bulkSponsorShipObject;
         Test.startTest();
        SponsorshipController.toActiveCheckBox(true);
         Test.stopTest();
        
    }
    
    
    public static testmethod void  TestvalidateEditedBookings(){
        
          List<SponsorshipController.bookingSponsorshipWrapper> wrapper = new List<SponsorshipController.bookingSponsorshipWrapper> ();
         SponsorshipController.bookingSponsorshipWrapper wrap2 = new SponsorshipController.bookingSponsorshipWrapper();
        wrapper.add(wrap2);
        Test.startTest();
     
        SponsorshipController.validateEditedBookings(wrapper);
         Test.stopTest(); 
        
    }
    
    
    public static testmethod void TestconfirmFirstRightToRefusal(){
        
        List<string> Strid=new List<string>();
        Strid.add('abc');
        string accID = 'xyz';
        
        String allSelectedTemplates = '\'recordID\': \'xyz\'';
        
        List<SponsorshipController.FirstRightToRefusalWrapper> FRTRWlst=new List<SponsorshipController.FirstRightToRefusalWrapper>();
        SponsorshipController.FirstRightToRefusalWrapper FRTR=new  SponsorshipController.FirstRightToRefusalWrapper();
        FRTR.Account='';
            FRTR.accountID='';
            FRTR.aeName='';
            FRTR.bookingID='';
            FRTR.endDate=date.parse('8/28/2020');
            FRTR.name='';
            FRTR.recordID='';
            FRTR.startDate=date.parse('8/28/2021');
        FRTRWlst.add(FRTR);
        
        List< SponsorshipController.allSelectedTemplatesWrapper> lstASTW=new  List<SponsorshipController.allSelectedTemplatesWrapper>();
        SponsorshipController.allSelectedTemplatesWrapper ASTW=new SponsorshipController.allSelectedTemplatesWrapper();
        ASTW.ed='8/28/2020';
            ASTW.recordID='';
            ASTW.sd='8/28/2021';
            ASTW.tempID='';
          Test.startTest();
     
        SponsorshipController.confirmFirstRightToRefusal(Strid,accID,allSelectedTemplates);
       SponsorshipController.getMaxMinBookedSponsorships(allSelectedTemplates,true);
         Test.stopTest(); 
    }
    public static testmethod void AEDetailsTest(){
     List< SponsorshipController.AEWrapper> lstAEW=new  List<SponsorshipController.AEWrapper>();
        SponsorshipController.AEWrapper AEW=new SponsorshipController.AEWrapper();
        AEW.id='';
        AEW.sObjectType='';
        AEW.title='';
        AEW.subtitle='';

	User u = [Select Id From User Where Name = 'Helene Juceam' limit 1];
        System.runAs(u){
            Test.startTest();
        SponsorshipController.AEDetails('Rachel Fromm');
        SponsorshipController.AccountTrend('');
         SponsorshipController.AllAEAccountTrend('');

    Test.stopTest(); 
        }
    
    
    }


}