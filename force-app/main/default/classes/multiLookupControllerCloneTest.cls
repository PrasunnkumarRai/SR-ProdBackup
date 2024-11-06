@IsTest(SeeAllData = false)
public class multiLookupControllerCloneTest  {
	
	public static testmethod void testretrieveRecords(){
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

		Templates__c temp = new Templates__c();
		temp.Name = 'Weather on the Ones - 1';
		temp.Total_Quantity__c = 10;
		temp.Start_Date__c = date.parse('8/28/2020');
		temp.End_Date__c = date.parse('8/28/2021');
		temp.News_Syscode__c = sys.Id;
        temp.Active__c=true;
		insert temp;
        
        Templates__c temp2 = new Templates__c();
		temp2.Name = 'Weather on the Ones - 2';
		temp2.Total_Quantity__c = 10;
		temp2.Start_Date__c = date.parse('8/28/2020');
		temp2.End_Date__c = date.parse('8/28/2021');
		temp2.News_Syscode__c = sys.Id;
        temp2.Active__c=true;
		insert temp2;

		String input = '0117';
		String sysCode = sys.Name;
		String strInput2 = '*';
        
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
        
        Proposal__c proposals = new Proposal__c();
        proposals.Name = 'Test Proposal';
        proposals.Opportunity__c = details.Id;
        proposals.End_Date__c = date.parse('11/28/2017');
        proposals.Start_Date__c = date.parse('11/28/2015');
        insert proposals;
        
        Id BookingRecordTypeId = Schema.SObjectType.Sponsorship_Booking__c.getRecordTypeInfosByName().get('Updated').getRecordTypeId();
        
        Booked_Sponsorship__c bookedSponsorship = new Booked_Sponsorship__c();
        bookedSponsorship.Opportunity__c = details.Id;
        bookedSponsorship.Status__c = 'Approved';
		bookedSponsorship.Right_to_First_Refusal__c = true;
        insert bookedSponsorship;
        
        Sponsorship_Booking__c booking = new Sponsorship_Booking__c();
		booking.Template__c = temp2.Id;
		booking.Start_Date__c = date.parse('12/28/2020');
		booking.End_Date__c = date.parse('12/28/2021');
		booking.Status__c = 'Pending';
        booking.RecordTypeId = BookingRecordTypeId;
        booking.Booked_Sponsorship__c = bookedSponsorship.Id;
     
		insert booking;
        
        Sponsorship_Booking__c booking2 = new Sponsorship_Booking__c();
		booking2.Template__c = temp.Id;
		booking2.Start_Date__c = date.parse('12/28/2020');
		booking2.End_Date__c = date.parse('12/28/2021');
		booking2.Status__c = 'Pending';
        booking2.RecordTypeId = BookingRecordTypeId;
        booking2.Booked_Sponsorship__c = bookedSponsorship.Id;
       
		insert booking2;
        
        String Id = proposals.Id;
        String Name = proposals.Name;
        Date StartDate = proposals.Start_Date__c;
        Date EndDate = proposals.End_Date__c;
        Decimal grossAmount = proposals.Gross_Amount__c;

		Test.startTest();
		MultiLookupController.retrieveRecords('Templates__c','Id,Name','Name',input);
		MultiLookupController.retrieveRecords('Templates__c', 'Name','Name',input);
		MultiLookupController.retrieveRecords('Templates__c', 'Id,Name','Name',strInput2);
        MultiLookUpControllerProposal.retrieveRecords('Proposal__c','Name','Name',input,details.Id);
        MultiLookUpControllerProposal.retrieveRecords('Proposal__c','Name','Name','',details.Id);
        MultiLookUpControllerProposal.SObjectQueryResult wrap = new MultiLookUpControllerProposal.SObjectQueryResult();
        wrap.recordId = Id;
        wrap.endDate = EndDate;
        wrap.recordName = Name;
        wrap.startDate = StartDate;
        wrap.gross = grossAmount;
        multiLookupControllerClone.retrieveRecords('Templates__c','Id,Name,Total_Quantity__c,Start_Date__c,End_Date__c','Name','News_Syscode__r.Name','News_Syscode__r.Network_Code__c','S1EP','bookedSponsorship.Id','0117','Weather','Local');
        multiLookupControllerClone.retrieveRecords('Templates__c','Id,Name,Total_Quantity__c,Start_Date__c,End_Date__c','Name','News_Syscode__r.Name','News_Syscode__r.Network_Code__c','none',null,'0117','Weather','Local');
        multiLookupControllerClone.retrieveRecords('Templates__c','Id,Name,Total_Quantity__c,Start_Date__c,End_Date__c','Name','News_Syscode__r.Name','News_Syscode__r.Network_Code__c','S1EP',null,'0117','Weather','Local');
        // multiLookupControllerClone.retrieveRecords('Templates__c','Id,Name,Total_Quantity__c,Start_Date__c,End_Date__c','Name','News_Syscode__r.Name','News_Syscode__r.Network_Code__c','none','bookedSponsorship.Id','0117','Weather','Local');
		Test.stopTest();


	}
}