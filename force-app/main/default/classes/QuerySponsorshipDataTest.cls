/*-------------------------------------------------------------------------------------------------
functionality......: This class is used to test 
                     QuerySponsorshipData
---------------------------------------------------------------------------------------------------
@author............: 
@created...........: 11th March 2021
@version...........: 1.0
---------------------------------------------------------------------------------------------------
@author............: 
@changes...........: 
vX.X
YYYY-MM-DD

vX.X 
YYYY-MM-DD
---------------------------------------------------------------------------------------------------
*/
@isTest
public with sharing class QuerySponsorshipDataTest {
	/*static Date startDate = Date.today();
	static Date endDate = Date.today().addYears(1);

	static Date startDateSameYear = Date.today();
	static Date endDateSameYear = Date.today().addMonths(1);
	static Templates__c template1 = new templates__c();
	 public static Templates__c createTemplate() {
        return createTemplate(true,null,null,null,null,null,null);
    }
    public static Templates__c createTemplate(boolean doInsert, date startDate, date endDate, string name, integer totalQuantity, string syscode, string networkCode) {
        Templates__c templateRecord         = new Templates__c();
        templateRecord.End_Date__c          = endDate != null ? endDate : system.today().addmonths(5);
        templateRecord.Start_Date__c        = startDate != null ? startDate : system.today();
        templateRecord.Name                 = name != null ? name : 'Template 1';
        templateRecord.Total_Quantity__c    = totalQuantity != null ? totalQuantity : 10;
        templateRecord.Syscode__c           = syscode != null ? syscode : 'Code-1';
        templateRecord.Network_Code__c      = networkCode != null ? networkCode : 'Code-2';
        if (doInsert)insert templateRecord;
        return templateRecord;
    }

    public static Sponsorship_Booking__c createSponsorshipBooking(string templateId) {
        return createSponsorshipBooking(true,templateId,null,null,null,null,null,null,null,null);
    }
    public static Sponsorship_Booking__c createSponsorshipBooking(boolean doInsert, string templateId,date startDate, date endDate, string name, string syscode, string networkCode, string status, string propoalId, string opportunityId) {
        Sponsorship_Booking__c sponsorshipBookingRec         = new Sponsorship_Booking__c();
        sponsorshipBookingRec.Template__c                    = templateId;         
        sponsorshipBookingRec.End_Date__c                    = endDate != null ? endDate : system.today().addmonths(5);
        sponsorshipBookingRec.Start_Date__c                  = startDate != null ? startDate : system.today();
        sponsorshipBookingRec.Name                           = name != null ? name : 'Sponsorship Booking 1';
        sponsorshipBookingRec.Syscode__c                     = syscode != null ? syscode : 'Code-1';
        sponsorshipBookingRec.Network_Code__c                = networkCode != null ? networkCode : 'Code-2';
        sponsorshipBookingRec.Status__c                      = status != null ? status : 'Pending';
        sponsorshipBookingRec.Proposal__c                    = propoalId != null ? propoalId : null;
        sponsorshipBookingRec.Opportunity__c                 = opportunityId != null ? opportunityId : null;
        if (doInsert)insert sponsorshipBookingRec;
        return sponsorshipBookingRec;
    }
    @testSetup static void setup() {
        template1 = QuerySponsorshipDataTest.createTemplate(true,startDate,endDate.addYears(2),null,null,null,null);
		QuerySponsorshipDataTest.createSponsorshipBooking(QuerySponsorshipDataTest.createTemplate().Id);
		QuerySponsorshipDataTest.createSponsorshipBooking(template1.ID);

    }
    static testMethod void testTheBookedStockLogic(){
		Test.startTest();
        System.assertNotEquals(0,QuerySponsorshipData.getData(new List<string>{[select id from Templates__c limit 1].Id},'option1',startDate,endDate).size());
		System.assertNotEquals(0,QuerySponsorshipData.getData(new List<string>{[select id from Templates__c limit 1].Id},'option1',startDateSameYear,endDateSameYear).size());
		QuerySponsorshipData.getData(new List<string>{template1.Id},'option1',startDate, Date.today().addYears(3));
		Test.stopTest();

    }
    static testMethod void testTheAvailableStockLogic(){
        QuerySponsorshipData.getData(new List<string>{[select id from Templates__c limit 1].Id},'Option 2',startDate,endDate);
		System.assertNotEquals(0,QuerySponsorshipData.getData(new List<string>{[select id from Templates__c limit 1].Id},'option 2',startDateSameYear,endDateSameYear).size());
		System.assertNotEquals(0,QuerySponsorshipData.getData(new List<string>{[select id from Templates__c limit 1].Id},'option 2',Date.today().addYears(1), Date.today().addYears(3)).size());
		System.assertNotEquals(0,QuerySponsorshipData.getData(new List<string>{[select id from Templates__c limit 1].Id},'option 2',startDate, Date.today().addYears(3)).size());

    }*/
    
    public static testmethod void testgetData(){
        
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

        
        List<String> tempList = new List<String>();
        List<String> nationaltempList = new List<String>();
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
        nationaltempList.add(temp3.Id);
        
        Template_Inventory__c tempInventory = new Template_Inventory__c();
        tempInventory.Template__c = temp3.Id;
        tempInventory.Total_Quantity__c = 20;
        tempInventory.Inventory_Type__c = 'Integration';
        tempInventory.Booked_Inventory__c = 5;
        insert tempInventory;
        
        
        Booked_Sponsorship__c bookedSpon = new Booked_Sponsorship__c();
		bookedSpon.Opportunity__c = details.Id;
        bookedSpon.Status__c = 'New';
		bookedSpon.Right_to_First_Refusal__c = true;
        insert bookedSpon;
        
        Sponsorship_Booking__c booking = new Sponsorship_Booking__c();
		booking.Template__c = temp.Id;
		booking.Start_Date__c = date.parse('12/28/2020');
		booking.End_Date__c = date.parse('12/28/2021');
		booking.Status__c = 'Pending';
        booking.Booked_Sponsorship__c = bookedSpon.Id;
		insert booking;
        
        Booked_Sponsorship__c nationalbookedSpon = new Booked_Sponsorship__c();
		nationalbookedSpon.Opportunity__c = details.Id;
        nationalbookedSpon.Status__c = 'New';
		nationalbookedSpon.Right_to_First_Refusal__c = true;
        nationalbookedSpon.Comments__c = 'national Sponsorship';
        nationalbookedSpon.Record_Type__c = 'National';
        insert nationalbookedSpon;
        
        Sponsorship_Booking__c nationalbooking = new Sponsorship_Booking__c();
		nationalbooking.Template__c = temp3.Id;
		nationalbooking.Start_Date__c = date.parse('12/28/2020');
		nationalbooking.End_Date__c = date.parse('12/28/2021');
		nationalbooking.Status__c = 'Pending';
        nationalbooking.Booked_Sponsorship__c = nationalbookedSpon.Id;
        nationalbooking.Inventory_Type__c = 'Integration';
        nationalbooking.Quantity__c = 10;
		insert nationalbooking;
        
        Booked_Sponsorship_Inventory__c nationalBookedInventory = new Booked_Sponsorship_Inventory__c();
        nationalBookedInventory.Booking_Details__c = nationalbooking.Id;
        nationalBookedInventory.Inventory_Type__c = 'Integration';
        nationalBookedInventory.Quantity__c = 10;
        insert nationalBookedInventory;
        
        Date startDate = date.parse('10/28/2020');
        Date endDate = date.parse('10/28/2022');
        Test.startTest();
            QuerySponsorshipData.getData(tempList,'Booked',startDate,endDate);
        	QuerySponsorshipData.getData(tempList,'Available',startDate,endDate);
        	QuerySponsorshipData.getavailableBoooking(tempList);
          	QuerySponsorshipData.getData(nationaltempList,'Booked',startDate,endDate);
        	QuerySponsorshipData.getData(nationaltempList,'Available',startDate,endDate);
        	QuerySponsorshipData.getavailableBoooking(nationaltempList);
        Test.stopTest();
    }
    
    public static testmethod void testdataSet(){
        String templateName = 'Weather on the Ones - 1';
        List<QuerySponsorshipData.barAmntWrapper> barAmount = new List<QuerySponsorshipData.barAmntWrapper>();
        QuerySponsorshipData.barAmntWrapper bar1 = new QuerySponsorshipData.barAmntWrapper();
        bar1.x = 'May/2020';
        bar1.y = 20;
        barAmount.add(bar1);
        
        QuerySponsorshipData.barAmntWrapper bar2 = new QuerySponsorshipData.barAmntWrapper();
        bar2.x = 'June/2020';
        bar2.y = 70;
        barAmount.add(bar2);
        
        QuerySponsorshipData.barAmntWrapper bar3 = new QuerySponsorshipData.barAmntWrapper();
        bar3.x = 'July/2020';
        bar3.y = 50;
        barAmount.add(bar3);
        
        QuerySponsorshipData.barAmntWrapper bar4 = new QuerySponsorshipData.barAmntWrapper();
        bar4.x = 'July/2020';
        bar4.y = 50;
        barAmount.add(bar4);
        
        String nationalTemplateName = 'Weather on the Ones - 1 - National';
        List<QuerySponsorshipData.barAmntWrapper> nationalbarAmount = new List<QuerySponsorshipData.barAmntWrapper>();
        QuerySponsorshipData.barAmntWrapper bar5 = new QuerySponsorshipData.barAmntWrapper();
        bar5.x = 'May/2020';
        bar5.y = 20;
        nationalbarAmount.add(bar5);
        
        QuerySponsorshipData.barAmntWrapper bar6 = new QuerySponsorshipData.barAmntWrapper();
        bar6.x = 'June/2020';
        bar6.y = 70;
        nationalbarAmount.add(bar6);
        
        QuerySponsorshipData.barAmntWrapper bar7 = new QuerySponsorshipData.barAmntWrapper();
        bar7.x = 'July/2020';
        bar7.y = 50;
        nationalbarAmount.add(bar7);
        
        QuerySponsorshipData.barAmntWrapper bar8 = new QuerySponsorshipData.barAmntWrapper();
        bar8.x = 'July/2020';
        bar8.y = 50;
        nationalbarAmount.add(bar8);
        
        
        Test.startTest();
			QuerySponsorshipData.DataSet data = new QuerySponsorshipData.DataSet(templateName,barAmount);
            QuerySponsorshipData.DataSet nationalData = new QuerySponsorshipData.DataSet(nationalTemplateName,nationalbarAmount);
        Test.stopTest();
        
    }
    
}