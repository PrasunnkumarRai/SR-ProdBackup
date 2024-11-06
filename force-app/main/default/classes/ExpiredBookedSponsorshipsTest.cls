@isTest
private class ExpiredBookedSponsorshipsTest  {
	static testMethod void ExpiredBookedSponsorshipsBatchTest() 
    {

        //Test Data

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

        Test.startTest();        
        ExpiredBookedSponsorshipsBatch ebsBatch = new ExpiredBookedSponsorshipsBatch();
        ID batchProcessId = Database.executeBatch(ebsBatch);
        Test.stopTest();
    }

    static testMethod void ExpiredBookedSponsorshipsSchedulerTest()
    {
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String sch = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobId = System.schedule('Schedule Batch',sch ,new ExpiredBookedSponsorshipScheduler());   
        Test.stopTest();
        
        System.assertNotEquals(null,jobId);
    }
}