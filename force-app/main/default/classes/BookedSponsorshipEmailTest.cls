@isTest 
private class BookedSponsorshipEmailTest {

	@isTest
	private static void testName() {
        
          User UserAE = TestUtil.createAEUser();
         System.runAs(UserAE){
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
        Templates__c temp1 = new Templates__c();
		temp1.Name = 'Weather on the Ones - 2';
		temp1.Total_Quantity__c = 10;
		temp1.Start_Date__c = date.parse('10/28/2020');
		temp1.End_Date__c = date.parse('10/28/2021');
		temp1.Syscode__c = '2838';
		temp1.Network_Code__c = 'S1LA';
		insert temp1;
		
        Template_Inventory__c tempInventory = new Template_Inventory__c();
		tempInventory.Template__c = temp1.Id;
		tempInventory.Inventory_Type__c = 'Integration';
       	tempInventory.Total_quantity__c = 30;
        tempInventory.Booked_Inventory__c = 10;
		insert tempInventory;
             
		List<Sponsorship_Booking__c> bookinglList = new List<Sponsorship_Booking__c>();
        List<String> proposalList = new List<String>();
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
        nationalbooking3.Booked_Sponsorship__c = bookedSpon.Id;
        nationalbooking3.Inventory_Type__c = 'Integration';
        nationalbooking3.Quantity__c = 5;
        nationalbooking3.Linear_Revenue__c=1000;
        nationalbooking3.Streaming_Revenue__c=2000;
         nationalbooking3.Confirm_Right_to_Refusal__c=true;
           nationalbooking3.First_Right_to_Refusal__c=true;
     
		insert nationalbooking3;
             
             
          Sponsorship_Booking__c nationalbooking4 = new Sponsorship_Booking__c();
		nationalbooking4.Template__c = nationalbooking3.Template__c;
		nationalbooking4.Start_Date__c = date.parse('12/28/2020');
		nationalbooking4.End_Date__c = date.parse('12/28/2021');
		nationalbooking4.Status__c = 'Pending';
        nationalbooking4.Booked_Sponsorship__c = bookedSpon.Id;
        nationalbooking4.Inventory_Type__c = 'Integration';
        nationalbooking4.Quantity__c = 5;
        nationalbooking4.Linear_Revenue__c=1000;
        nationalbooking4.Streaming_Revenue__c=2000;
         nationalbooking4.Confirm_Right_to_Refusal__c=true;
           nationalbooking4.First_Right_to_Refusal__c=true;
     
		insert nationalbooking4;   
             
             
        bookinglList.add(nationalbooking3);

        Booked_Sponsorship_Inventory__c nationalBookedInventory = new Booked_Sponsorship_Inventory__c();
        nationalBookedInventory.Booking_Details__c = nationalbooking2.Id;
        nationalBookedInventory.Inventory_Type__c = 'Integration';
        nationalBookedInventory.Quantity__c = 10;
        insert nationalBookedInventory;
      
        
        list<BookedSponsorshipEmailController.FirstRightToRefusalWrapper> FRTRWrapper=new list<BookedSponsorshipEmailController.FirstRightToRefusalWrapper>();
        BookedSponsorshipEmailController.FirstRightToRefusalWrapper FRTRW=NEW BookedSponsorshipEmailController.FirstRightToRefusalWrapper();
      FRTRW.Account='Test';
            FRTRW.accountID=acc.id;
            FRTRW.bookingID=nationalbooking3.id;
            FRTRW.endDate=nationalbooking3.End_Date__c;
            FRTRW.LinearRevenue= nationalbooking3.Linear_Revenue__c;
            FRTRW.name='test';
            FRTRW.recordID=nationalbooking3.Template__c;
            FRTRW.startDate=nationalbooking3.Start_Date__c;
            FRTRW.StreamingRevenue= nationalbooking3.Streaming_Revenue__c;
        FRTRWrapper.add(FRTRW);
        
         list<SponsorshipController.allSelectedTemplatesWrapper> SponWrapper=new  list<SponsorshipController.allSelectedTemplatesWrapper>();
             SponsorshipController.allSelectedTemplatesWrapper spon=new SponsorshipController.allSelectedTemplatesWrapper();
             spon.ed= string.valueOf(nationalbooking3.End_Date__c);
             spon.sd= string.valueOf(nationalbooking3.Start_Date__c);
                 spon.tempID=nationalbooking3.Template__c;
                 spon.recordID=nationalbooking3.Id;
             SponWrapper.add(spon);
       // User UserAE = TestUtil.createAEUser();
        
       List<String> templateList = new List<String>();
      
            
        BookedSponsorshipEmailController.bsId = bookedSpon.ID;
            BookedSponsorshipEmailController bsObj = new BookedSponsorshipEmailController();
           BookedSponsorshipEmailController.wrapperList=FRTRWrapper;
          // bsObj.bsId = bookedSpon.Id;
            //System.debug('bsObj.bsId'+bsObj.bsId);
            List<Sponsorship_Booking__c> sbsupdated = bsObj.sbsupdated;
            List<Sponsorship_Booking__c> sbs = bsObj.sbs;
            Booked_Sponsorship__c bs = bsObj.bs;
            String bsLink = bsObj.bsLink;
            String oppLink = bsObj.accLink;
            String accLink = bsObj.oppLink;
            String newline = bsObj.NewLine;
            Test.stopTest();
        }
		
	}
}