/**
* @author sr.ashok.aggarwal@mandsconsulting.com.preproddev
* @description 
*/ 
global without sharing class SponsorshipController {

	public enum months { January, February, March, April, May, June, July, August, september, October, November, December }

   
	@AuraEnabled
	public static Opportunity getOpportunityDetails(Id oppId) {
		try {
			System.debug('oppId:' + oppId);
			Opportunity opp = new Opportunity();
			opp = [Select Id, Name, Account.Name, Owner_Division__c, Owner_Region__c, Owner_Sales_Office__c, Owner.Name, AccountID from Opportunity WHERE Id = :oppId LIMIT 1];
			return opp;
		}
		catch(Exception e) {
			System.debug('Error: ' + e.getMessage() + 'Error Line Number: ' + e.getLineNumber());
			Log4SF.logMessage('SponsorshipController','getOpportunityDetails',e.getMessage(),e,UserInfo.getUserId(),Id.valueOf(oppId));
			throw e;
		}

	}

	@AuraEnabled
    public static List<Sponsorship_Date_Inventory__c> fetchAllSponsorship(String recordIds, Date startDate1, Date endDate1, String bookingId) {
        try{
		System.debug('bookingId: '+ bookingId);
        System.debug('recordIds: ' + recordIds);
        // System.debug('startDate: ' + startDate1.format());
        //System.debug('endDate: ' + String.valueOf(endDate1).removeEnd(' 00:00:00'));

        String endDate = endDate1.format();
        String startDate = startDate1.format();
        Date stDate = Date.newInstance(endDate1.year(), endDate1.month(), endDate1.day());
        // stDate = endDate1;
        System.debug('endDate: ' + stDate);
        System.debug('startDate: ' + startDate);

        List<Sponsorship_Date_Inventory__c> sponsorshipDateInventoryList = new List<Sponsorship_Date_Inventory__c> ();
		List<Sponsorship_Date_Inventory__c> sponsorshipUpdatedList = new List<Sponsorship_Date_Inventory__c> ();

        sponsorshipDateInventoryList = Database.query('SELECT Id,Sponsorship__r.Name, Sponsorship_Inventory_Date__c, Available_Quantity__c, Booked_Quantity__c, Total_Quantity__c FROM Sponsorship_Date_Inventory__c WHERE Sponsorship__c = :recordIds AND Sponsorship_Inventory_Date__c <= : endDate1 and Sponsorship_Inventory_Date__c>=: startDate1');

        System.debug('sponsorshipDateInventoryList: ' + sponsorshipDateInventoryList);

		if(bookingId != 'null'){
			Sponsorship_Booking__c editedBooking = [Select Id, Name,Start_Date__c,End_Date__c from Sponsorship_Booking__c where Id =: bookingId];
				for(Sponsorship_Date_Inventory__c inventoryToUpdate: sponsorshipDateInventoryList){
					if(inventoryToUpdate.Sponsorship_Inventory_Date__c >= editedBooking.Start_Date__c && inventoryToUpdate.Sponsorship_Inventory_Date__c <= editedBooking.End_Date__c){
						inventoryToUpdate.Booked_Quantity__c --;
						sponsorshipUpdatedList.add(inventoryToUpdate);
					}
					else{
						sponsorshipUpdatedList.add(inventoryToUpdate);
					}
				}
				return sponsorshipUpdatedList;
		}
		else{	
				return sponsorshipDateInventoryList;
		}
        }
        catch(exception ex) { system.debug(ex.getStackTraceString());
			Log4SF.logMessage('SponsorshipController','fetchAllSponsorship',ex.getMessage(),ex,UserInfo.getUserId(),recordIds);
			throw ex; }
    }

    
    @AuraEnabled
    public static List<Sponsorship_Booking__c> getBookingSponsorshipListexport(String recordIds, Date startdate , Date enddate) {
       
        try{
        System.debug('recordIds: ' + recordIds);
             System.debug('sponsorshipBookingListExport: ' + startdate);
               System.debug('sponsorshipBookingListExport: ' + enddate);
       
        List<Sponsorship_Booking__c> sponsorshipBookingListexport = new List<Sponsorship_Booking__c> ();
		List<Sponsorship_Booking__c> sponsorshipBookingListReturn = new List<Sponsorship_Booking__c> ();

        sponsorshipBookingListexport = Database.query('SELECT Id,Template__r.Name,Total_Revenue__c, Name,Opportunity__r.Name,Opportunity__r.Owner.Name,Opportunity__r.Account.Id,Account__c,Start_Date__c,End_Date__c,Syscode__c,Linear_Revenue__c,Quantity__c,Streaming_Revenue__c FROM Sponsorship_Booking__c WHERE Template__c = :recordIds'); // and End_Date__c > :enddate and Start_Date__c < :startdate 
			for(Sponsorship_Booking__c sb : sponsorshipBookingListExport)
			{
                System.debug('sb' +sb);
                System.debug('sb startdate' +startdate);
                System.debug('sb endDate' +endDate);
				if(SponsorshipController.checkStartEndDates(startdate, endDate, sb.Start_Date__c, sb.End_Date__c))
				{
					sponsorshipBookingListReturn.add(sb);
				}
			}
        System.debug('sponsorshipBookingListExport: ' + sponsorshipBookingListReturn);
        return sponsorshipBookingListReturn;
		}
		catch(exception ex) { system.debug(ex.getStackTraceString());
			Log4SF.logMessage('SponsorshipController','getBookingSponsorshipListexport',ex.getMessage(),ex,UserInfo.getUserId(),recordIds);
			throw ex; }
        
        
    }

	
    
    
	@AuraEnabled
    public static List<Sponsorship_Booking__c> getBookingSponsorshipList(String recordIds, Date sponsorshipEventDate) {
       
        try{
        System.debug('recordIds: ' + recordIds);
        System.debug('sponsorshipEventDate: ' + sponsorshipEventDate);
        List<Sponsorship_Booking__c> sponsorshipBookingList = new List<Sponsorship_Booking__c> ();

        sponsorshipBookingList = Database.query('SELECT Id, Name,Opportunity__r.Name,Opportunity__r.Account.Id,Account__c,Start_Date__c,End_Date__c,Syscode__c FROM Sponsorship_Booking__c WHERE Template__c = :recordIds and End_Date__c > :sponsorshipEventDate and Start_Date__c < :sponsorshipEventDate ');

        System.debug('sponsorshipBookingList: ' + sponsorshipBookingList);
        return sponsorshipBookingList;
		}
		catch(exception ex) { system.debug(ex.getStackTraceString());
			Log4SF.logMessage('SponsorshipController','getBookingSponsorshipList',ex.getMessage(),ex,UserInfo.getUserId(),recordIds);
			throw ex; }
        
        
    }

	/*@AuraEnabled
    public static List<Sponsorship_Booking__c> getBookingbookingList(String recordIds, Date sponsorshipEventDate) {
       
        try{
        System.debug('recordIds: ' + recordIds);
        System.debug('sponsorshipEventDate: ' + sponsorshipEventDate);
		
		date starspon=sponsorshipEventDate.addDays(4);
		System.debug('starspon: ' + starspon);
        List<Sponsorship_Booking__c> sponsorshipBookingList = new List<Sponsorship_Booking__c> ();

        sponsorshipBookingList = Database.query('SELECT Id, Name,Opportunity__r.Name,Opportunity__r.Account.Id,Account__c,Start_Date__c,End_Date__c,Syscode__c FROM Sponsorship_Booking__c WHERE Template__c = :recordIds and End_Date__c > :starspon and Start_Date__c < :starspon ');

        System.debug('BookingList: ' + sponsorshipBookingList);
        return sponsorshipBookingList;
		}
		catch(exception ex) { system.debug(ex.getStackTraceString()); throw ex; }
        
        
    }*/

	

	@AuraEnabled
	public static List<Template_Inventory__c> getTemplateInventory(List<String> templateName) {
		List<Template_Inventory__c> inventoryList = new List<Template_Inventory__c> ();
		try {
			if (templateName != null) {
				inventoryList = [Select Id, Inventory_Type__c, Template__r.Name, Available_Quantity__c, Booked_Inventory__c, Total_quantity__c from Template_Inventory__c where Template__r.Name IN :templateName];
			}
			return inventoryList;
		}
		catch(Exception e) {
			System.debug('Error: ' + e.getMessage() + 'Error Line Number: ' + e.getLineNumber());
			Log4SF.logMessage('SponsorshipController','getTemplateInventory',e.getMessage(),e,UserInfo.getUserId(),'');
			throw e;
		}

	}

	@AuraEnabled
	public static Booked_Sponsorship__c getBookedSponsorshipDetails(Id bookedId) {
		try {
			System.debug('bookedId:' + bookedId);
			Booked_Sponsorship__c bSpnship = [SELECT Name, Id, Opportunity__c, Right_to_First_Refusal__c, Record_Type__c, Comments__c,(SELECT Id, Name, Start_Date__c, End_Date__c, Network_Code__c, Opportunity__c, Proposal__c,
			                                                                                                               Syscode__c, Template__r.Id, Template__r.Name, Template__r.Start_Date__c, Template__r.End_Date__c,
			                                                                                                               Template__r.Total_Quantity__c, Template__r.System_Name__c, News_Syscode__c,Template__r.System_Type__c, Inventory_Type__c, Quantity__c,
			                                                                                                               Template__r.Market__c, Template__r.MVPD__c, Template__r.State__c FROM Sponsorship_Bookings__r),
			(SELECT Proposal__r.Name, Proposal__r.Start_Date__c, Proposal__r.End_Date__c, Proposal__r.Gross_Amount__c From Sponsorship_Proposals__r)
			                                  FROM Booked_Sponsorship__c WHERE Id = :bookedId LIMIT 1];
			System.debug('bSpnship  ' + bSpnship);
			return bSpnship;
		}
		catch(Exception e) {
			System.debug('Error: ' + e.getMessage() + 'Error Line Number: ' + e.getLineNumber());
			Log4SF.logMessage('SponsorshipController','getBookedSponsorshipDetails',e.getMessage(),e,UserInfo.getUserId(),Id.valueOf(bookedId));
			throw e;
		}
	}

	@AuraEnabled
	public static List<Proposal__c> getProposalDetails(List<String> proposalId) {
		try {
			List<Proposal__c> proposaldetails = new List<Proposal__c> ();
			proposaldetails = [Select Id, Name, Start_Date__c, End_Date__c from Proposal__c WHERE Id In :proposalId];
			System.debug('Proposal Details ' + proposaldetails);
			return proposaldetails;
		}
		catch(Exception e) {
			System.debug('Error: ' + e.getMessage() + 'Error Line Number: ' + e.getLineNumber());
			Log4SF.logMessage('SponsorshipController','getProposalDetails',e.getMessage(),e,UserInfo.getUserId(),'');
			throw e;
		}

	}

	@AuraEnabled
	public static List<Proposal__c> getProposalList(String bookingId) {
		try{
			List<Sponsorship_Proposals__c> proposalList = new List<Sponsorship_Proposals__c> ();
		proposalList = [Select Id, Proposal__c from Sponsorship_Proposals__c Where Bookied_Sponsorship__c = :bookingId];
		List<String> proposalLists = new List<String> ();
		for (Sponsorship_Proposals__c s : proposalList) {
			proposalLists.add(s.Proposal__c);
		}
		System.debug('Proposal List ' + proposalLists);
		List<Proposal__c> finalProposalList = new List<Proposal__c> ();
		finalProposalList = [Select Id, Name, Start_Date__c, End_Date__c from Proposal__c Where Id IN :proposalLists];
		return finalProposalList;

		}catch(Exception ex){
			Log4SF.logMessage('SponsorshipController','getProposalList',ex.getMessage(),ex,UserInfo.getUserId(),bookingId);
			return new List<Proposal__c>(); 
		}
		
	}

	@AuraEnabled
	public static Booked_Sponsorship__c createBookingRecord(String oppId, List<bookingSponsorshipWrapper> TemplateDetails, List<String> proposalIds, Boolean rightToRefusal, String region, String comments, String EmailStatus) {
		Opportunity opp = [Select Id, Name, AccountId, Owner.Name, Owner_Division__c, Owner_Region__c, Owner_Sales_Office__c from Opportunity where Id = :oppId];
		List<Template_Inventory__c> tempInventoryList = [Select Id, Booked_Inventory__c, Available_Quantity__c, Inventory_Type__c, Total_quantity__c, Template__c from Template_Inventory__c];
		System.debug('Template Details: ' + TemplateDetails);
		List<String> templateIdList = new List<String>();
		System.debug('Proposal Details: ' + proposalIds);
		System.debug('Email Status: '+ EmailStatus);
		try {
			Booked_Sponsorship__c Booked = new Booked_Sponsorship__c();
			Booked.Opportunity__c = oppId;
			Booked.Is_Editable__c = true;
			Booked.Status__c = 'New';
			Booked.Right_to_First_Refusal__c = rightToRefusal;
			Booked.Record_Type__c = region;
			Booked.Comments__c = comments;
			Booked.Email_Status__c = EmailStatus;
			insert Booked;
			Id BookedRecordTypeId = Schema.SObjectType.Sponsorship_Booking__c.getRecordTypeInfosByName().get('Updated').getRecordTypeId();
			List<Sponsorship_Booking__c> sponsorshipBooking = new List<Sponsorship_Booking__c> ();
			List<Sponsorship_Proposals__c> sponsorshipProposals = new List<Sponsorship_Proposals__c> ();
			List<Booked_Sponsorship_Inventory__c> sponsorshipBookedInventory = new List<Booked_Sponsorship_Inventory__c> ();
			if (region == 'National') {
				for (integer i = 0; i<TemplateDetails.size(); i++) {
				System.debug('Template Inventory Details: ' + TemplateDetails[i]);
				System.debug('TemplateDetails[i].isRenewal - '+TemplateDetails[i].isRenewal);
				System.debug('TemplateDetails[i].rightToRefusal - '+TemplateDetails[i].rightToRefusal);
					if(TemplateDetails[i].inventory.size() > 0)
					{
						Sponsorship_Booking__c sponsorship = new Sponsorship_Booking__c(
					                                                                Name = TemplateDetails[i].label,
					                                                                Template__c = TemplateDetails[i].Id,
																					Is_Renewal__c = TemplateDetails[i].isRenewal,
					                                                                Syscode__c = TemplateDetails[i].Syscode,
																					News_Syscode__c = TemplateDetails[i].syscodeId,
					                                                                Network_Code__c = TemplateDetails[i].NetworkCode,
					                                                                Start_Date__c = TemplateDetails[i].StartDate,
					                                                                End_Date__c = TemplateDetails[i].EndDate,
					                                                                Opportunity__c = oppId,
					                                                                Booked_Sponsorship__c = Booked.Id,
					                                                                RecordTypeId = BookedRecordTypeId,
					                                                                Is_Sponsorship_Cancelled__c = TemplateDetails[i].isCanceled,
					                                                                Inventory_Type__c = TemplateDetails[i].inventory[0].InventoryType,
					                                                                Quantity__c = TemplateDetails[i].bookingQuantity,
																					Linear_Revenue__c = TemplateDetails[i].linearRevenueContri,
																					Streaming_Revenue__c = TemplateDetails[i].streamingRevenueContri,
																					First_Right_to_Refusal__c = TemplateDetails[i].rightToRefusal
																					);

						sponsorshipBooking.add(sponsorship);
					}
				}
				insert sponsorshipBooking;
				System.debug('sponsorshipBooking: ' + sponsorshipBooking);
				insert sponsorshipBookedInventory;

				for (integer i = 0; i<sponsorshipBooking.size(); i++) {
					Booked_Sponsorship_Inventory__c bookedInventory = new Booked_Sponsorship_Inventory__c(Booking_Details__c = sponsorshipBooking[i].Id,
					                                                                                      Inventory_Type__c = sponsorshipBooking[i].Inventory_Type__c,
					                                                                                      Quantity__c = sponsorshipBooking[i].Quantity__c);
					sponsorshipBookedInventory.add(bookedInventory);
					for (Template_Inventory__c temp : tempInventoryList) {
						if (temp.Template__c == sponsorshipBooking[i].Template__c && temp.Inventory_Type__c == sponsorshipBooking[i].Inventory_Type__c) {
							if (temp.Booked_Inventory__c == null) {
								temp.Booked_Inventory__c = 0;
							}
							else {
								temp.Booked_Inventory__c = temp.Booked_Inventory__c;
							}
							System.debug('booked Inventory ' + temp.Booked_Inventory__c);
							temp.Booked_Inventory__c = temp.Booked_Inventory__c + sponsorshipBooking[i].Quantity__c;
							update temp;
						}
					}
				}
				insert sponsorshipBookedInventory;
			}

			else {
				for (integer i = 0; i<TemplateDetails.size(); i++) {
					System.debug('TemplateDetails[i].isRenewal - '+TemplateDetails[i].isRenewal);
					System.debug('TemplateDetails[i].rightToRefusal - '+TemplateDetails[i].rightToRefusal);
					templateIdList.add(TemplateDetails[i].Id);
					Sponsorship_Booking__c sponsorship = new Sponsorship_Booking__c(
					                                                                Name = TemplateDetails[i].label,
					                                                                Template__c = TemplateDetails[i].Id,
																					Is_Renewal__c = TemplateDetails[i].isRenewal,
					                                                                Syscode__c = TemplateDetails[i].Syscode,
																					News_Syscode__c = TemplateDetails[i].syscodeId,
					                                                                Network_Code__c = TemplateDetails[i].NetworkCode,
					                                                                Start_Date__c = TemplateDetails[i].StartDate,
					                                                                End_Date__c = TemplateDetails[i].EndDate,
					                                                                Opportunity__c = oppId,
					                                                                Booked_Sponsorship__c = Booked.Id,
					                                                                RecordTypeId = BookedRecordTypeId,
					                                                                Is_Sponsorship_Cancelled__c = TemplateDetails[i].isCanceled,
																					Linear_Revenue__c = TemplateDetails[i].linearRevenueContri,
																					Streaming_Revenue__c = TemplateDetails[i].streamingRevenueContri,
																					First_Right_to_Refusal__c = TemplateDetails[i].rightToRefusal
																					);
					sponsorshipBooking.add(sponsorship);
				}
				insert sponsorshipBooking;
			}
			System.debug('sponsorshipBooking: ' + sponsorshipBooking);
			//SponsorshipController sc = new SponsorshipController();
			//sc.sendBookingEmail(sponsorshipBooking, false, Booked.Id);
			for (Integer i = 0; i<proposalIds.size(); i++) {
				Sponsorship_Proposals__c proposalList = new Sponsorship_Proposals__c(
				                                                                     Proposal__c = proposalIds[i],
				                                                                     Bookied_Sponsorship__c = Booked.Id);


				sponsorshipProposals.add(proposalList);
			}
			insert sponsorshipProposals;
			
			//Calling batch to update the date Inventory to quantity 1 when Booking is made.
			DateInventoryHandleUpdateBatch updateDateInventory = new DateInventoryHandleUpdateBatch(Booked.Id,null);
			Database.executeBatch(updateDateInventory,1);
			return Booked;
		}
		catch(Exception e) {
			System.debug('Error: ' + e.getMessage() + 'Error Line Number: ' + e.getLineNumber());
			Log4SF.logMessage('SponsorshipController','createBookingRecord',e.getMessage(),e,UserInfo.getUserId(),oppId);
			throw e;
		}
	}


	@AuraEnabled
	public static Booked_Sponsorship__c createEditedBookingRecord(String oppId, List<bookingSponsorshipWrapper> TemplateDetails, List<String> proposalIds, String bookingId, Boolean rightToRefusal, String region, String comments,String EmailStatus) {
		Opportunity opp = [Select Id, Name, AccountId, Owner.Name, Owner_Division__c, Owner_Region__c, Owner_Sales_Office__c from Opportunity where Id = :oppId];
		List<Template_Inventory__c> tempInventoryList = [Select Id, Booked_Inventory__c, Available_Quantity__c, Inventory_Type__c, Total_quantity__c, Template__c from Template_Inventory__c];
		//inventoryDetails invDetails = TemplateDetails[0].inventory[0];
		System.debug('Template Details: ' + TemplateDetails[0].syscodeId);
		System.debug('Proposal Details: ' + proposalIds);
		System.debug('Booking Id: ' + bookingId);
		try {
			Booked_Sponsorship__c Booked = new Booked_Sponsorship__c();
			Booked = [Select Id, Name from Booked_Sponsorship__c where Id = :bookingId LIMIT 1];
			Booked.Status__c = 'New';
			Booked.Right_to_First_Refusal__c = rightToRefusal;
			Booked.Comments__c = comments;
			Booked.Email_Status__c = EmailStatus;
			Update Booked;
			Id EditedRecordTypeId = Schema.SObjectType.Sponsorship_Booking__c.getRecordTypeInfosByName().get('Updated').getRecordTypeId();
			List<Sponsorship_Booking__c> sponsorshipBooking = new List<Sponsorship_Booking__c> ();
			List<Sponsorship_Proposals__c> sponsorshipProposals = new List<Sponsorship_Proposals__c> ();
			List<Booked_Sponsorship_Inventory__c> sponsorshipBookedInventory = new List<Booked_Sponsorship_Inventory__c> ();
			if (region == 'National') {
				for (integer i = 0; i<TemplateDetails.size(); i++) {
					Sponsorship_Booking__c sponsorship = new Sponsorship_Booking__c(
					                                                                Name = TemplateDetails[i].label,
					                                                                Template__c = TemplateDetails[i].Id,
					                                                                Syscode__c = TemplateDetails[i].Syscode,
																					News_Syscode__c = TemplateDetails[i].syscodeId,
					                                                                Network_Code__c = TemplateDetails[i].NetworkCode,
					                                                                Start_Date__c = TemplateDetails[i].StartDate,
					                                                                End_Date__c = TemplateDetails[i].EndDate,
					                                                                Opportunity__c = oppId,
					                                                                Booked_Sponsorship__c = Booked.Id,
					                                                                RecordTypeId = EditedRecordTypeId,
					                                                                Is_Sponsorship_Cancelled__c = TemplateDetails[i].isCanceled,
					                                                                Inventory_Type__c = TemplateDetails[i].inventory[0].InventoryType,
					                                                                Quantity__c = TemplateDetails[i].bookingQuantity,
																					Linear_Revenue__c = TemplateDetails[i].linearRevenueContri,
																					Streaming_Revenue__c = TemplateDetails[i].streamingRevenueContri
																					);

					sponsorshipBooking.add(sponsorship);
				}
				insert sponsorshipBooking;
				//System.debug('sponsorshipBooking: ' + sponsorshipBooking);
				//insert sponsorshipBookedInventory;
				for (integer i = 0; i<sponsorshipBooking.size(); i++) {
					Booked_Sponsorship_Inventory__c bookedInventory = new Booked_Sponsorship_Inventory__c(Booking_Details__c = sponsorshipBooking[i].Id,
					                                                                                      Inventory_Type__c = sponsorshipBooking[i].Inventory_Type__c,
					                                                                                      Quantity__c = sponsorshipBooking[i].Quantity__c);
					sponsorshipBookedInventory.add(bookedInventory);
					for (Template_Inventory__c temp : tempInventoryList) {
						if (temp.Template__c == sponsorshipBooking[i].Template__c && temp.Inventory_Type__c == sponsorshipBooking[i].Inventory_Type__c && TemplateDetails[i].isUpdate == false) {
							if (temp.Booked_Inventory__c == null) {
								temp.Booked_Inventory__c = 0;
							}
							else {
								temp.Booked_Inventory__c = temp.Booked_Inventory__c;
							}
							System.debug('booked Inventory ' + temp.Booked_Inventory__c);
							temp.Booked_Inventory__c = temp.Booked_Inventory__c + sponsorshipBooking[i].Quantity__c;
							update temp;
						}
						else if (temp.Template__c == sponsorshipBooking[i].Template__c && temp.Inventory_Type__c == sponsorshipBooking[i].Inventory_Type__c && TemplateDetails[i].isUpdate == true) {
							temp.Booked_Inventory__c = sponsorshipBooking[i].Quantity__c + (TemplateDetails[i].inventory[0].bookedQuantity - TemplateDetails[i].initialQuantity);
							update temp;
						}
					}
				}
				insert sponsorshipBookedInventory;
			}
			else {
				for (integer i = 0; i<TemplateDetails.size(); i++) {
					Sponsorship_Booking__c sponsorship = new Sponsorship_Booking__c(
					                                                                Name = TemplateDetails[i].label,
					                                                                Template__c = TemplateDetails[i].Id,
					                                                                Syscode__c = TemplateDetails[i].Syscode,
																					News_Syscode__c = TemplateDetails[i].syscodeId,
					                                                                Network_Code__c = TemplateDetails[i].NetworkCode,
					                                                                Start_Date__c = TemplateDetails[i].StartDate,
					                                                                End_Date__c = TemplateDetails[i].EndDate,
					                                                                Opportunity__c = oppId,
					                                                                Booked_Sponsorship__c = bookingId,
					                                                                RecordTypeId = EditedRecordTypeId,
					                                                                Is_Sponsorship_Cancelled__c = TemplateDetails[i].isCanceled,
																					Linear_Revenue__c = TemplateDetails[i].linearRevenueContri,
																					Streaming_Revenue__c = TemplateDetails[i].streamingRevenueContri
																					);
					sponsorshipBooking.add(sponsorship);
				}
				insert sponsorshipBooking;
			}
			//SponsorshipController sc = new SponsorshipController();
			//sc.sendBookingEmail(sponsorshipBooking, false, Booked.Id);
			System.debug('Sponsorship Booking Created Record: ' + sponsorshipBooking);

			//query to get proposal id's which are already linked 
			List<Sponsorship_Proposals__c> sponsorshiProposalsForComparison = [SELECT Id, Proposal__c FROM Sponsorship_Proposals__c WHERE Bookied_Sponsorship__c = :bookingId];
			Map<String, Sponsorship_Proposals__c> m1 = new Map<String, Sponsorship_Proposals__c> ();
			for (Sponsorship_Proposals__c sp : sponsorshiProposalsForComparison) {
				m1.put(sp.Proposal__c, sp);
			}
			System.debug('map  --------' + m1);
			System.debug('proposal query result --------' + sponsorshiProposalsForComparison);
			List<Sponsorship_Proposals__c> sponsorshiProposalsForDeletion = new List<Sponsorship_Proposals__c> ();

			for (Integer i = 0; i<proposalIds.size(); i++) {
				Boolean isPresentInMap = m1.containsKey(proposalIds[i]);

				if (isPresentInMap) {
					m1.remove(proposalIds[i]);
				} else {
					Sponsorship_Proposals__c proposalList = new Sponsorship_Proposals__c(
					                                                                     Proposal__c = proposalIds[i],
					                                                                     Bookied_Sponsorship__c = bookingId);
					sponsorshipProposals.add(proposalList);
				}
			}

			for (Sponsorship_Proposals__c sps : m1.values()) {
				sponsorshiProposalsForDeletion.add(sps);
			}
			insert sponsorshipProposals;
			delete sponsorshiProposalsForDeletion;
			System.debug('Sponsorship Proposals: ' + sponsorshipProposals);
			return Booked;
		}
		catch(Exception e) {
			System.debug('Error: ' + e.getMessage() + 'Error Line Number: ' + e.getLineNumber());
			Log4SF.logMessage('SponsorshipController','createEditedBookingRecord',e.getMessage(),e,UserInfo.getUserId(),oppId);
			throw e;
		}
	}

	@ReadOnly
    @RemoteAction
    @AuraEnabled
	public static Map<Id,Boolean> validateEditedBookings(List<bookingSponsorshipWrapper> sponsorshipDetails){
		try {
			Date maxDate;
			Date minDate;
			boolean result;
			Map<String,Map<Date,Date>> mapsprBookings = new Map<String,Map<Date,Date>>();
			Map<Id,List<Boolean>> validationResult = new Map<Id,List<Boolean>>();
			Map<Id,Boolean> returnResult = new Map<Id,Boolean>();
			for(bookingSponsorshipWrapper sb: sponsorshipDetails){
				if(maxDate != null && maxDate < sb.StartDate){
					maxDate = sb.StartDate; 
				}
				if(minDate !=null && minDate > sb.EndDate){
					minDate = sb.EndDate;
				}
				if(mapsprBookings.containsKey(sb.Id)){
					Map<Date,Date> sprBookingDates = mapsprBookings.get(sb.Id);
					sprBookingDates.put(sb.StartDate,sb.EndDate);
					mapsprBookings.put(sb.Id,sprBookingDates);
				}
				else{
					Map<Date,Date> sprBookingDates = new Map<Date,Date>();
					sprBookingDates.put(sb.StartDate,sb.EndDate);
					mapsprBookings.put(sb.Id,sprBookingDates);
				}
			}
			List<Sponsorship_Date_Inventory__c> inventoryListToUpdate = new List<Sponsorship_Date_Inventory__c>();
			List<Sponsorship_Date_Inventory__c> updatedInventory = new List<Sponsorship_Date_Inventory__c>();
			List<Sponsorship_Date_Inventory__c> dateInventoryList = [Select Id, Name,Booked_Quantity__c,Available_Quantity__c,Sponsorship_Inventory_Date__c,Sponsorship__c from Sponsorship_Date_Inventory__c where Sponsorship__c IN :mapsprBookings.keySet() AND (Sponsorship_Inventory_Date__c < :maxDate AND Sponsorship_Inventory_Date__c > :minDate)];
			for(String sponsorshipId:mapsprBookings.keySet()){
				for(Sponsorship_Date_Inventory__c dateInventory: dateInventoryList){
					List<Date> startSponsorshipDates = new List<Date>(mapsprBookings.get(sponsorshipId).keyset());
                         if(startSponsorshipDates[0] <= dateInventory.Sponsorship_Inventory_Date__c && mapsprBookings.get(sponsorshipId).get(startSponsorshipDates[0])>= dateInventory.Sponsorship_Inventory_Date__c)
                         inventoryListToUpdate.add(dateInventory);
				}
			}
			for(Sponsorship_Date_Inventory__c inventoryQuantity: inventoryListToUpdate){
				System.debug('Booked Quantity before update '+ inventoryQuantity.Booked_Quantity__c);
				inventoryQuantity.Booked_Quantity__c --;
				System.debug('Booked Quantity after update '+ inventoryQuantity.Booked_Quantity__c);
				System.debug('Available Quantity '+ inventoryQuantity.Available_Quantity__c);
				if(inventoryQuantity.Available_Quantity__c == inventoryQuantity.Booked_Quantity__c || inventoryQuantity.Available_Quantity__c > inventoryQuantity.Booked_Quantity__c ){
					if(validationResult.containsKey(inventoryQuantity.Sponsorship__c)){
						List<Boolean> resultList = validationResult.get(inventoryQuantity.Sponsorship__c);
						resultList.add(false);
						validationResult.put(inventoryQuantity.Sponsorship__c,resultList);
					}
					else{
						List<Boolean> resultList = new List<Boolean>();
						resultList.add(false);
						validationResult.put(inventoryQuantity.Sponsorship__c,resultList);
					}
				}
				else{
					if(validationResult.containsKey(inventoryQuantity.Sponsorship__c)){
						List<Boolean> resultList = validationResult.get(inventoryQuantity.Sponsorship__c);
						resultList.add(true);
						validationResult.put(inventoryQuantity.Sponsorship__c,resultList);
					}
					else{
						List<Boolean> resultList = new List<Boolean>();
						resultList.add(true);
						validationResult.put(inventoryQuantity.Sponsorship__c,resultList);
					}
				}
			}
			for(Id sponsorshipKey: validationResult.keySet()){
				for(Boolean bookingresult: validationResult.get(sponsorshipKey)){
					if(bookingresult == true){
						returnResult.put(sponsorshipKey,true);
						break;
					}
					else{
						returnResult.put(sponsorshipKey,false);
					}
				}
			}
			return returnResult;

			
		} catch (Exception e) {
			System.debug('Error: ' + e.getMessage() + 'Error Line Number: ' + e.getLineNumber());
		
			Log4SF.logMessage('SponsorshipController','validateEditedBookings',e.getMessage(),e,UserInfo.getUserId(),'');
			throw e;
		}
	}


	@AuraEnabled
	public static void submitForApproval(String BookedSponsorshipId) {
		System.debug('sponId:' + BookedSponsorshipId);
		// Create an approval request for the Opportunity
		Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		req1.setComments('Submitting Sponsorship Booking request for approval');
		req1.setObjectId(BookedSponsorshipId);
		//req1.setNextApproverIds(new Id[] { opp.Next_Approver__c });

		// Submit the approval request for the Opportunity
		Approval.ProcessResult result = Approval.process(req1);
		System.debug('Approval result:' + result);
		try {
			Booked_Sponsorship__c booked = [Select Id, Opportunity__r.Name from Booked_Sponsorship__c where Id = :BookedSponsorshipId LIMIT 1];
			List<GroupMember> groupmem = [SELECT Id, GroupId, Group.DeveloperName, UserOrGroupId, 
											TYPEOF UserOrGroup
												WHEN User THEN IsActive
												WHEN Group THEN Id
											END
											FROM GroupMember
											WHERE Group.DeveloperName = 'Sponsorship_Approval'];
			for (GroupMember g : groupmem) {
				if (g.UserOrGroup instanceof User && g.UserOrGroup.IsActive) {
					generalBellNotification(g.UserOrGroupId, 'Sponsorship is booked for Opportunity ' + booked.Opportunity__r.Name, BookedSponsorshipId);
				}
			}


		}
		catch(Exception e) {
			System.debug('Error: ' + e.getMessage() + 'Error Line Number: ' + e.getLineNumber());
			Log4SF.logMessage('SponsorshipController','submitForApproval',e.getMessage(),e,UserInfo.getUserId(),BookedSponsorshipId);
			throw e;
		}
	}


	/*@AuraEnabled
	  public static List<LookupSearchResult> getmyuserAccountsList(String oppId) {
	  String ProposalIcon = 'standard:proposal';
	  List<LookupSearchResult> results = new List<LookupSearchResult> ();
	  List<Opportunity> opp = new List<Opportunity> ();
	  opp = [Select id, (select id, name, Current_Advertiser_Tim_Id__c from Proposals__r), Active_Proposal_Count__c from Opportunity where id = :oppId];
	  List<Proposal__c> proposal = new List<Proposal__c> ();
	  for (Opportunity o : opp) {
	  proposal.addAll(o.Proposals__r);
	  }
	 
	  for (Proposal__c prop : proposal) {
	 
	 
	  results.add(
	  new LookupSearchResult(
	  prop.Id,
	  'Proposal' + '\n',
	  ProposalIcon,
	  prop.Current_Advertiser_Tim_Id__c
	  )
	  );
	  }
	 
	  return results;
	 
	 
	  }*/

	@AuraEnabled(Cacheable = true)
	public static Template_Inventory__c getTemplateDetails(String TemplateId) {
		try{
			System.debug('Template Id: ' + TemplateId);
		Template_Inventory__c temp = new Template_Inventory__c();
		temp = [Select Id, Name, Start_Date__c, End_Date__c, Inventory_Item_ID__r.Inventory_Name__r.Name, Inventory_Item_ID__r.Inventory_Name__r.Inventory_Quantity__c from Template_Inventory__c WHERE Id = :TemplateId];
		System.debug('template Details ' + temp);
		return temp;

		}catch(Exception ex){
            Log4SF.logMessage('SponsorshipController','getTemplateDetails',ex.getMessage(),ex,UserInfo.getUserId(),TemplateId);
			return null;
		}
		

	}


	@AuraEnabled(Cacheable = true)
	public static List<wrapDataSets> getBookedSponsorships(List<String> templateIds) {
		try{
			System.debug('Template Ids ' + templateIds);
			List<Sponsorship_Booking__c> sponsorships = new List<Sponsorship_Booking__c> ();
			sponsorships = [select Id, Name from Sponsorship_Booking__c where Template__r.Id in :templateIds];
			List<wrapDataSets> lstwrapDataset = new List<wrapDataSets> ();
			for (Integer i = 0; i<sponsorships.size(); i++) {
				wrapDataSets wrap = new wrapDataSets();
				wrap.label = sponsorships[i].Name;
				lstwrapDataset.add(wrap);
			}
	
			System.debug('List of DataSets ' + lstwrapDataset);
			return lstwrapDataset;
		}catch(Exception ex){
            Log4SF.logMessage('SponsorshipController','getBookedSponsorships',ex.getMessage(),ex,UserInfo.getUserId(),'');
			return null;
		}
		
	}

	//@AuraEnabled
	//public static void submitForApproval(String sponId)
	//{
	//System.debug('sponId:' + sponId);
	//// Create an approval request for the Opportunity
	//Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
	//req1.setComments('Submitting Sponsorship Booking request for approval');
	//req1.setObjectId(sponId);
	////req1.setNextApproverIds(new Id[] { opp.Next_Approver__c });

	//// Submit the approval request for the Opportunity
	//Approval.ProcessResult result = Approval.process(req1);
	//System.debug('Approval result:' + result);
	//}



	public class wrapDataSets {
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public List<String> monthYear { get; set; }
		@AuraEnabled
		public Boolean fill { get; set; }
		@AuraEnabled
		public Double barPercentage { get; set; }
		@AuraEnabled
		public Double barThickness { get; set; }
		@AuraEnabled
		public Double maxBarThickness { get; set; }
		@AuraEnabled
		public Double minBarLength { get; set; }



		public wrapDataSets() {
			fill = true;
			barPercentage = 0.5;
			barThickness = 6;
			maxBarThickness = 8;
			minBarLength = 2;
			monthYear = new List<String> ();
			Integer currentYear = System.Today().year();

			for (Integer i = 0; i<months.values().size(); i++) {
				String mon;
				mon = months.values() [i] + '2021';
				monthYear.add(mon);
			}
			System.debug('List of Months nad Year ' + monthYear);
		}




	}

	@AuraEnabled(cacheable = true)
	public static List<sobject> findRecords(String searchKey, String objectName) {
		try{
            //System.debug('recId' + recId);
		//System.debug('relatedRec' + relatedRec);
		//System.debug('objectName' + objectName);
		string searchText = ('\'' + String.escapeSingleQuotes(searchKey) + '%\'');
		System.debug('searchText' + searchText);
		string query = ('SELECT Id, Name,Network_Code__c,State__c,System_Type__c, System_Name__c,Market__c FROM ' + objectName + ' WHERE Name LIKE ' + searchText + ' OR System_Name__c LIKE ' + searchText + ' OR Market__c LIKE ' + searchText + ' OR State__c LIKE ' + searchText);
		return Database.query(query);
		}catch(Exception ex){
            Log4SF.logMessage('SponsorshipController','findRecords',ex.getMessage(),ex,UserInfo.getUserId(),'');
			return null;
		}
		
	}

	@AuraEnabled(cacheable = true)
	public static Syscode_and_Network__c syscodeDetails(String sysCode) {
		try{
            System.debug('Syscode Id - '+sysCode);
		Syscode_and_Network__c syscodeDetails = new Syscode_and_Network__c();
		syscodeDetails = [Select Id, Name, Market__c, MVPD__c, Network_Code__c, State__c, System_Name__c, System_Type__c from Syscode_and_Network__c where Id = :sysCode];
		System.debug('sysCodeDetails List ::::' + syscodeDetails);
		return syscodeDetails;
		}catch(Exception ex){
			Log4SF.logMessage('SponsorshipController','syscodeDetails',ex.getMessage(),ex,UserInfo.getUserId(),sysCode);
			return null;
		}
		
	}

	@AuraEnabled(cacheable = true)
	public static List<Templates__c> createSponsorship(String sponsorShipId){
		try{
			System.debug('sposorshipId are coming :::' + sponsorShipId);
			// SponsorshipDateInventoryBatch bcn = new SponsorshipDateInventoryBatch() ;
			// ID batchprocessid =  Database.executeBatch(sponsorShipId,500);
	
			List<Templates__c> templateList = [Select Id, Name, Start_Date__c, End_Date__c from Templates__c where Id =: sponsorShipId LIMIT 150];
			SponsorshipDateInventoryBatch objBatch = new SponsorshipDateInventoryBatch(templateList);
			ID batchprocessid = Database.executeBatch(objBatch,500);
	
			return templateList;

		}catch(Exception ex){
			Log4SF.logMessage('SponsorshipController','createSponsorship',ex.getMessage(),ex,UserInfo.getUserId(),sponsorShipId);
			return null;
		}
      
	}
	
	@AuraEnabled(cacheable = true)
    public static List<Templates__c> updateSponsorshipWithEndDateChanges(String sponsorShipId, String newEndDate, Integer quantity, Boolean isActive){
		try{
			Date parsedEndDate = Date.valueOf(newEndDate);
        System.debug('sposorshipId - ' + sponsorShipId + ' newEndDate - '+parsedEndDate+' quantity - '+quantity+' isActive - '+isActive);
        List<Templates__c> templateList = [Select Id, Name, Start_Date__c, End_Date__c from Templates__c where Id =: sponsorShipId];
        Boolean endDateChangeValue = true;
        SponsorshipDateInventoryBatch.isEndDateChange = true;
        List<Templates__c> templateListToSend = new List<Templates__c>();
        Templates__c newTemplate = new Templates__c();
        Integer daysDifference = templateList[0].End_Date__c.daysBetween(parsedEndDate);

        newTemplate.Start_Date__c = templateList[0].End_Date__c;
        newTemplate.End_Date__c = templateList[0].End_Date__c.addDays(daysDifference);
        newTemplate.Name = templateList[0].Name;
        newTemplate.ID = templateList[0].ID;
        templateListToSend.add(newTemplate);
        SponsorshipDateInventoryBatch objBatch = new SponsorshipDateInventoryBatch(templateListToSend,endDateChangeValue,parsedEndDate,isActive,quantity);
        ID batchprocessid = Database.executeBatch(objBatch,500);
        // SponsorshipDateInventoryBatch objBatch = new SponsorshipDateInventoryBatch(templateList);
        // ID batchprocessid = Database.executeBatch(objBatch,500);

        return templateList;
		}catch(Exception ex){
			Log4SF.logMessage('SponsorshipController','updateSponsorshipWithEndDateChanges',ex.getMessage(),ex,UserInfo.getUserId(),sponsorShipId);
            return null;
		}
        
    }


	// @AuraEnabled(cacheable = true)
	// public static Templates__c createSponsorshipForm(String Template, Date StartDate, Date EndDate, String NewSyscode){
	// 	System.debug('data are coming from sponsorshipForm :::' + Template);
	// 	Templates__c templateObject = new Templates__c();
	// 	templateObject.Name = Template;
	// 	templateObject.Start_Date__c = StartDate;
	// 	templateObject.End_Date__c = EndDate;
	// 	templateObject.News_Syscode__c = NewSyscode;
	// 	insert templateObject;
	// 	return templateObject;

	// }

	@AuraEnabled(cacheable = true)
	public static Bulk_Sponsorship__c toActiveCheckBox(Boolean checkBoxValue){
		try{
			Bulk_Sponsorship__c bulkSponsorShipObject = new Bulk_Sponsorship__c();
			bulkSponsorShipObject.Active__c = checkBoxValue;
			insert bulkSponsorShipObject;
			return bulkSponsorShipObject;
		}catch(Exception ex){
			Log4SF.logMessage('SponsorshipController','toActiveCheckBox',ex.getMessage(),ex,UserInfo.getUserId(),'');
			return null;
		}
		
       
	}
	

	@AuraEnabled(cacheable = true)
	public static Map<String, List<String>> getNetworkSyscodeMap() {
		try{
            List<Syscode_and_Network__c> SyscodeData = [Select Name, Network_Code__c from Syscode_and_Network__c];
		System.debug('Syscode ' + SyscodeData);
		Map<String, List<String>> NewtworkRelatedSyscode = new Map<String, List<String>> ();
		for (Syscode_and_Network__c sys : SyscodeData) {
			if (NewtworkRelatedSyscode.containsKey(sys.Name)) {
				List<String> ntwrks = NewtworkRelatedSyscode.get(sys.Name);
				ntwrks.add(sys.Network_Code__c);
				NewtworkRelatedSyscode.put(sys.Name, ntwrks);
			} else {
				List<String> ntwrks2 = new List<String> ();
				ntwrks2.add(sys.Network_Code__c);
				NewtworkRelatedSyscode.put(sys.Name, ntwrks2);
			}
		}
		System.debug('Network related Code ' + NewtworkRelatedSyscode);
		return NewtworkRelatedSyscode;
		}catch(Exception ex){
			Log4SF.logMessage('SponsorshipController','getNetworkSyscodeMap',ex.getMessage(),ex,UserInfo.getUserId(),'');
			return null;
		}
		
	}

	@AuraEnabled
	public static void generalBellNotification(String alertUserId, String msg, String recId) {
		try {
			CustomNotificationType notificationType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Book_Sponsorship_Notification'];
			Messaging.CustomNotification notification = new Messaging.CustomNotification();
			notification.setTitle('Sponsorship Booked');
			notification.setBody(msg);
			notification.setNotificationTypeId(notificationType.id);
			notification.setTargetId(recId);
			notification.send(new Set<String> { alertUserId });
		}
		catch(Exception e) {
			System.debug('Error: ' + e.getMessage() + 'Error Line Number: ' + e.getLineNumber());
			Log4SF.logMessage('SponsorshipController','generalBellNotification',e.getMessage(),e,UserInfo.getUserId(),recId);
			throw e;
		}
	}


	//@AuraEnabled(cacheable = true)
	//public static List<templateFields> getBookedTemplates(String templateIds, String syscode, String NetworkCode, Date startDate, Date endDate) {
	//System.debug('Template ' + templateIds);
	//System.debug('SysCode ' + syscode);
	//System.debug('NewteorkCode ' + NetworkCode);
	//startDate = startDate.toStartOfMonth();
	//endDate = endDate.toStartOfMonth();
	//List<templateFields> tempList = new List<templateFields> ();
	//List<Templates__c> bookedTemplateList = new List<Templates__c> ();
	//List<Sponsorship_Booking__c> templateList = new List<Sponsorship_Booking__c> ();
	//templateList = [Select Id, Name, Status__c, Template__r.Name, Template__r.Id, Template__r.Inventory_Type__c, Template__r.Total_Quantity__c, Opportunity__r.Owner.Name, Opportunity__r.Account.Name, Start_Date__c, End_Date__c FROM Sponsorship_Booking__c WHERE Name LIKE :'%' + templateIds + '%'];
	//System.debug('templateList ' + templateList);
	//List<Id> Ids = new List<Id> ();
	//for (Sponsorship_Booking__c sb : templateList) {
	//if (SponsorshipController.checkStartEndDate(startDate, endDate, sb.Start_Date__c.toStartOfMonth(), sb.End_Date__c.toStartOfMonth()))
	//{
	//tempList.add(new templateFields(sb));
	//Ids.add(sb.Template__r.Id);
	//}
	//}
	/*
	  for(Sponsorship_Booking__c s: templateList){
	 
	  Ids.add(s.Template__r.Id);
	  }
	 */
	//bookedTemplateList = [Select Id, Name, (Select Name, Inventory_Quantity__c, Inventory_Name__c from Template_Inventories__r), Total_Quantity__c, Start_Date__c, End_Date__c FROM Templates__c WHERE Id in :Ids];
	//Integer i = 0;
	/*for(Templates__c tem: bookedTemplateList){
	  tempList.add(new templateFields(tem.Template_Inventories__r[i].Inventory_Name__c,tem.Template_Inventories__r[i].Inventory_Quantity__c));
	  i++;
	  }*/


	//return tempList;

	//}

	@AuraEnabled(cacheable = true)
	public static List<Sponsorship_Booking__c> getBookedTemplates(List<String> templateIds, String bookedSpnsrshp) {
      try{
		System.debug('templateIds - ' + templateIds);
		System.debug('bookedSpnsrshp - ' + bookedSpnsrshp);
		List<Sponsorship_Booking__c> templateList = new List<Sponsorship_Booking__c> ();
		if (bookedSpnsrshp == null) {
			templateList = [Select Name, Start_Date__c, End_Date__c, Template__r.Start_Date__c,
			                Template__r.End_Date__c, Template__r.Id, Template__r.Total_Quantity__c
			                FROM Sponsorship_Booking__c WHERE Template__r.Id IN :templateIds];
		} else {
			templateList = [Select Name, Start_Date__c, End_Date__c, Template__r.Start_Date__c,
			                Template__r.End_Date__c, Template__r.Id, Template__r.Total_Quantity__c
			                FROM Sponsorship_Booking__c WHERE(Template__r.Id IN :templateIds AND Booked_Sponsorship__r.Id != :bookedSpnsrshp)];
		}

		System.debug('templateList ' + templateList);
		return templateList;

	  }catch(Exception ex){
		Log4SF.logMessage('SponsorshipController','getBookedTemplates',ex.getMessage(),ex,UserInfo.getUserId(),bookedSpnsrshp);
		return null;
	  }
		
	}

	public static Map<ID, List<Sponsorship_Booking__c>> getTemplatesBookings(List<String> templateIds) {
		try{
            System.debug('templateIds - ' + templateIds);
		List<Sponsorship_Booking__c> bookingList = new List<Sponsorship_Booking__c> ();
		if (templateIds.size()> 0) {
			bookingList = [Select Name, Start_Date__c, End_Date__c, Template__r.Start_Date__c,
			               Template__r.End_Date__c, Template__r.Id, Template__r.Total_Quantity__c
			               FROM Sponsorship_Booking__c WHERE Template__r.Id IN :templateIds];
		}
		Map<ID, List<Sponsorship_Booking__c>> mapTempBookings = new Map<ID, List<Sponsorship_Booking__c>> ();
		for (Sponsorship_Booking__c booking : bookingList)
		{
			if (!mapTempBookings.containsKey(booking.Template__r.Id))
			{
				mapTempBookings.put(booking.Template__r.Id, new List<Sponsorship_Booking__c> { booking });
			}
			else {
				mapTempBookings.get(booking.Template__r.Id).add(booking);
			}

		}
		System.debug('bookingList ' + mapTempBookings);
		return mapTempBookings;
		}catch(Exception ex){
			Log4SF.logMessage('SponsorshipController','getTemplatesBookings',ex.getMessage(),ex,UserInfo.getUserId(),'');
			return null;
		}

		
	}

	@AuraEnabled(cacheable = true)
	public static List<Templates__c> getTemplateInfo(List<String> templateIds) {
		try{
			List<Templates__c> templateList = [Select Id, Name, Start_Date__c, End_Date__c
			FROM Templates__c WHERE Id IN :templateIds];
            System.debug('templateList ' + templateList);
            return templateList;
		}catch(Exception ex){
			Log4SF.logMessage('SponsorshipController','getTemplateInfo',ex.getMessage(),ex,UserInfo.getUserId(),'');
			return null;
		}

		
	}


	@AuraEnabled
	public static Boolean checkTeamMember(Id oppId, Id currentUser) {
		try {
			List<OpportunityTeamMember> opportunityTeamMembers = [Select UserId from OpportunityTeamMember where OpportunityId = :oppId];
			Boolean isMember = false;
			for (OpportunityTeamMember oppMember : opportunityTeamMembers) {
				System.debug('opportunity team member : ' + oppMember.UserId);
				System.debug('current user id from aura : ' + currentUser);
				if (oppMember.UserId == currentUser) {
					isMember = true;
				}
			}
			Opportunity ownerOpp = [Select Owner.Id from opportunity where id = :oppId LIMIT 1];
			String ownerId = ownerOpp.Owner.Id;
			if (ownerId == currentUser) {
				isMember = true;
			}

			String sysAdmin = 'System Administrator';
			String integrationUser = 'Integration User';
			User currentUserProfile = [Select Profile.name from user where id = :currentUser LIMIT 1];
			String userProfileName = currentUserProfile.Profile.name;
			if (userProfileName == sysAdmin) {
				isMember = true;
			} else if (userProfileName == integrationUser) {
				isMember = true;
			}


			//Select Id,Profile.name from user where id =  '00541000000feqDAAQ'
			System.debug('Returned value for isMember   :   ' + isMember);
			return isMember;
		} catch(Exception e) {
			System.debug('Error: ' + e.getMessage() + 'Error Line Number: ' + e.getLineNumber());
			Log4SF.logMessage('SponsorshipController','checkTeamMember',e.getMessage(),e,UserInfo.getUserId(),Id.valueOf(oppId));
			throw e;
		}
	}


	/**
	* @description 
	* @param bsId 
	* @return 
	*/ 
	@AuraEnabled
	public static Boolean checkApprovalProcess(Id bsId) {
		System.debug('Booked Sponsorship Id ' + bsId);
		try {
			Booked_Sponsorship__c bs = [Select Id, Status__c, Is_Editable__c from Booked_Sponsorship__c where Id = :bsId LIMIT 1];
			String stat = bs.Status__c;
			Boolean editable = bs.Is_Editable__c;
			System.debug('stat' + stat);
			String customLabel = System.Label.Sponsorship_Status;
			List<String> statusToEdit = new List<String> ();
			Integer commaIndex = customLabel.indexOf(',');
			if (commaIndex != - 1) {
				System.debug('comma found');
				statusToEdit = customLabel.split(',');
				return((stat == statusToEdit[1] || stat == statusToEdit[0]) && editable) ? true : false;
			} else {
				System.debug('comma not found');
				return((stat == customLabel) && editable) ? true : false;
			}
		} catch(Exception e) {
			System.debug('Error: ' + e.getMessage() + 'Error Line Number: ' + e.getLineNumber());
			Log4SF.logMessage('SponsorshipController','checkApprovalProcess',e.getMessage(),e,UserInfo.getUserId(),Id.valueOf(bsId));
			throw e;
		}
	}

	@AuraEnabled(cacheable = true)
	public static List<templateFields> getAvailableTemplates(String templateIds, String syscode, String NetworkCode) {
		try{
			System.debug('Template ' + templateIds);
			System.debug('SysCode ' + syscode);
			System.debug('NewteorkCode ' + NetworkCode);
			List<templateFields> tempList = new List<templateFields> ();
			//templateFields temp = new templateFields();
	
			List<Templates__c> templateList = new List<Templates__c> ();
			templateList = [Select Id, Name, Total_Quantity__c, Start_Date__c, End_Date__c FROM Templates__c WHERE Name = :templateIds LIMIT 1];
			List<Available_Template__c> available = new List<Available_Template__c> ();
			// available = [Select Id, Template__r.Name, Start_Date__c, End_Date__c, Template__r.Total_Quantity__c, Is_Available__c FROM Available_Template__c WHERE Template__r.Name LIKE :'%' + templateIds + '%' AND Is_Available__c = true];
	
			for (Templates__c t : templateList) {
				tempList.add(new templateFields(t));
			}
	
			//for (Available_Template__c at : available) {
			//  tempList.add(new templateFields(at));
			// }
	
			System.debug('Temp List' + tempList);
			return tempList;
		}catch(Exception ex){
			Log4SF.logMessage('SponsorshipController','getAvailableTemplates',ex.getMessage(),ex,UserInfo.getUserId(),'');
			return null;
		}
		


	}

	@AuraEnabled
	public static Templates__c getSelectedTemplateDetails(String templateId) {
		try{
            Templates__c template = new Templates__c();
		template = [Select Id, Name, Network_Code__c, (Select Name, Inventory_Quantity__c, Inventory_Name__c from Template_Inventories__r), Inventory_Type__c, Total_Quantity__c, Start_Date__c, End_Date__c FROM Templates__c WHERE Id = :templateId LIMIT 1];
		return template;
		}catch(Exception ex){
			Log4SF.logMessage('SponsorshipController','getSelectedTemplateDetails',ex.getMessage(),ex,UserInfo.getUserId(),templateId);
			return null;
		}
	}

	@AuraEnabled
	public static Available_Template__c getSelectedAvailableTemplateDetails(String templateId) {
		try{
            System.debug('template Id: ' + templateId);
		Available_Template__c template = new Available_Template__c();
		template = [Select id, Start_Date__c, Template__r.Name, End_Date__c, Template__r.Network_Code__c, Template_Inventory__r.Inventory_Item_ID__r.Inventory_Name__r.Name, Template_Inventory__r.Inventory_Item_ID__r.Inventory_Name__r.Inventory_Quantity__c, Name from Available_Template__c where Id = :templateId LIMIT 1];
		return template;
		}catch(Exception ex){
			Log4SF.logMessage('SponsorshipController','getSelectedAvailableTemplateDetails',ex.getMessage(),ex,UserInfo.getUserId(),templateId);
			return null;
		}
		

	}

	@AuraEnabled
	public static List<String> showPopUpInfo(String templateId) {
		try{
            System.debug('Template Id--------------' + templateId);
		Sponsorship_Booking__c sb = new Sponsorship_Booking__c();
		List<String> listTemplate = new List<String> ();
		Templates__c temp = new Templates__c();
		sb = [Select Id, Name, Template__r.Name, Template__r.Id, Opportunity__r.Owner.Name, Start_Date__c, End_Date__c FROM Sponsorship_Booking__c WHERE Id = :templateId LIMIT 1];
		String selectedTemplateId = sb.Template__r.Id;
		temp = [Select Id, Network_Code__c, Name, (Select Name, Inventory_Quantity__c, Inventory_Name__c from Template_Inventories__r), Inventory_Type__c, Total_Quantity__c, Start_Date__c, End_Date__c FROM Templates__c WHERE Id = :selectedTemplateId LIMIT 1];
		String templateName = sb.Name;
		String startDate = String.valueOf(sb.Start_Date__c);
		String endDate = String.valueOf(sb.End_Date__c);
		String InventoryType = temp.Inventory_Type__c;
		String quantity = String.valueOf(temp.Total_Quantity__c);
		String networkCode = temp.Network_Code__c;
		listTemplate.add(templateName);
		listTemplate.add(startDate);
		listTemplate.add(endDate);
		listTemplate.add(InventoryType);
		listTemplate.add(quantity);
		listTemplate.add(networkCode);
		//listTemplate.add(templateName);
		return listTemplate;
		}catch(Exception ex){
			Log4SF.logMessage('SponsorshipController','showPopUpInfo',ex.getMessage(),ex,UserInfo.getUserId(),templateId);
			return null;
		}
		

	}

	@AuraEnabled
	public static String updateTemplate(Date startDate, String templateId) {
		try{
			Templates__c updateTemp = new Templates__c();
			//updateTemp = [Select id, Start_Date__c,End_Date__c from Templates__c where Id = :templateId LIMIT 1];
			updateTemp.Id = templateId;
			updateTemp.Start_Date__c = startDate;
			//updateTemp.End_Date__c = enddate;
			update updateTemp;
			return 'Updated';
		}catch(Exception ex){
			Log4SF.logMessage('SponsorshipController','updateTemplate',ex.getMessage(),ex,UserInfo.getUserId(),templateId);
			return null;
		}
		



	}

	/*
	  Method to verify if thew new Booking dates Overlap with any of the existing bookings.
	 
	 */

	public void checkTemplateAvailability()
	{

	}

	public class templateFields {

		@AuraEnabled
		public String name { get; set; }

		@AuraEnabled
		public Decimal quantity { get; set; }

		@AuraEnabled
		public Date startDate { get; set; }

		@AuraEnabled
		public String inventoryType { get; set; }

		@AuraEnabled
		public Date endDate { get; set; }

		@AuraEnabled
		public String Id { get; set; }

		@AuraEnabled
		public Boolean isAvailableTemplate { get; set; }

		@AuraEnabled
		public String Owner { get; set; }

		@AuraEnabled
		public String status { get; set; }


		public templateFields(Templates__c tem) {
			this.Id = tem.Id;
			this.name = tem.Name;
			this.quantity = tem.Total_Quantity__c;
			this.startDate = tem.Start_Date__c;
			this.endDate = tem.End_Date__c;
			this.isAvailableTemplate = false;

		}

		public templateFields(Available_Template__c at) {
			this.id = at.Id;
			this.name = at.Template__r.Name;
			this.quantity = at.Template__r.Total_Quantity__c;
			this.startDate = at.Start_Date__c;
			this.endDate = at.End_date__c;
			this.isAvailableTemplate = true;
		}

		public templateFields(Sponsorship_Booking__c sb) {
			this.Id = sb.Id;
			this.name = sb.Name;
			this.quantity = sb.Template__r.Total_Quantity__c;
			this.inventoryType = sb.Template__r.Inventory_Type__c;
			this.startDate = sb.Start_Date__c;
			this.endDate = sb.End_Date__c;
			this.Owner = sb.Opportunity__r.Account.Name;
			this.status = sb.Status__c;
		}

		/*public templateFields(String InventoryType, Decimal InventoryName){
		  this.quantity = InventoryName;
		  this.inventoryType = InventoryType;
		 
		  }*/



	}
	/*
	 *    This method is used for the template statistics LWC
	 *    It is used to -
	 *    1. Prepare and Return a wrapper list of data that is going to tell the UI about the booked,
	 *      pending and Available template counts choosen from the UI
	 *    
	 *    @author     Ankit Bhatia
	 *    @param      String		            ID of the booking reord choosen from the UI
	 *    @return     List<DataSet>          Wrapper list to show the booking percentage on UI
	 */
	@AuraEnabled
	public static List<TemplateStatisticsWrapper> getTemplateStatistics(String bookingID)
	{
		try{
			Integer bookingStartMonth = 0;
		Integer bookingEndMonth = 0;
		Integer bookingStartYear = 0;
		Integer bookingEndYear = 0;
		Integer templateQuantity = 0;
		Date bookingStartDate;
		Date bookingEndDate;
		List<TemplateStatisticsWrapper> templateDataList = new List<TemplateStatisticsWrapper> ();
		List<Templates__c> templateList = new List<Templates__c> ();
		Map<String, Integer> statisticsMap = new Map<String, Integer> ();
		List<Sponsorship_Booking__c> bookingList = [Select ID, Start_Date__c, End_Date__c, Template__c from Sponsorship_Booking__c where ID = :bookingID];
		if (bookingList.size()> 0)
		{
			bookingStartMonth = bookingList[0].Start_Date__c.month();
			bookingEndMonth = bookingList[0].End_Date__c.month();
			bookingStartYear = bookingList[0].Start_Date__c.year();
			bookingEndYear = bookingList[0].End_Date__c.year();
			bookingStartDate = bookingList[0].Start_Date__c.toStartOfMonth();
			bookingEndDate = bookingList[0].End_Date__c.toStartOfMonth();
			templateList = [Select End_Date__c, Id, Name, OwnerId, Total_Quantity__c, Start_Date__c, Template_Inventory__c,
			(select id, name, Start_Date__c, End_Date__c, Is_Active__c, Status__c from Sponsorship_Bookings__r)
			                from Templates__c where id = :bookingList[0].Template__c and Total_Quantity__c != null ORDER BY Start_Date__c desc];
			for (Templates__c templateRecord : templateList)
			{

				templateQuantity = Integer.valueOf(templateRecord.Total_Quantity__c);
				statisticsMap.put('Available', templateQuantity);
				system.debug('templateRecord=' + templateRecord);
				if (templateRecord.Sponsorship_Bookings__r != null && templateRecord.Sponsorship_Bookings__r.size()> 0)
				{
					for (Sponsorship_Booking__c sponBookRec : templateRecord.Sponsorship_Bookings__r)
					{
						Integer currentBookStartMonth = sponBookRec.Start_Date__c.month();
						Integer currentBookEndMonth = sponBookRec.End_Date__c.month();
						Integer currentBookStartYear = sponBookRec.Start_Date__c.year();
						Integer currentBookEndYear = sponBookRec.End_Date__c.year();

						sponBookRec.Start_Date__c = sponBookRec.Start_Date__c.toStartOfMonth();
						sponBookRec.End_Date__c = sponBookRec.End_Date__c.toStartOfMonth();
						system.debug('currentBookStartMonth =' + currentBookStartMonth + ' bookingStartMonth =' + bookingStartMonth + ' currentBookEndMonth =' + currentBookEndMonth + ' currentBookStartYear =' + currentBookStartYear + ' bookingStartYear=  ' + bookingStartYear);

						if (SponsorshipController.checkStartEndDate(bookingStartDate, bookingEndDate, sponBookRec.Start_Date__c, sponBookRec.End_Date__c))
						{
							if (sponBookRec.Is_Active__c)
							{
								if (statisticsMap.containsKey('Booked'))
								statisticsMap.put('Booked', statisticsMap.get('Booked') + 1);
								else
								statisticsMap.put('Booked', 1);
							}
							else
							{
								if (statisticsMap.containsKey('Pending'))
								statisticsMap.put('Pending', statisticsMap.get('Pending') + 1);
								else
								statisticsMap.put('Pending', 1);
							}
							statisticsMap.put('Available', statisticsMap.get('Available') - 1);
						}
						/*
						  if((currentBookStartMonth >= bookingStartMonth && currentBookStartMonth <= 12) && (currentBookStartYear == bookingStartYear))
						  {
						  //if( (currentBookStartMonth >= bookingStartMonth &&  currentBookStartMonth <= bookingEndMonth) || (currentBookEndMonth >= bookingStartMonth &&  currentBookEndMonth <= bookingEndMonth))
						  //{
						  if(sponBookRec.Is_Active__c)
						  {
						  if(statisticsMap.containsKey('Booked'))
						  statisticsMap.put('Booked',statisticsMap.get('Booked') +1);
						  else
						  statisticsMap.put('Booked',1);
						  }
						  else
						  {
						  if(statisticsMap.containsKey('Pending'))
						  statisticsMap.put('Pending',statisticsMap.get('Pending') +1);
						  else
						  statisticsMap.put('Pending',1);
						  }
						  statisticsMap.put('Available', statisticsMap.get('Available')-1);
						  }
						  else if(( currentBookEndMonth <= bookingEndMonth) && (currentBookEndYear > bookingStartYear && currentBookEndYear == bookingEndYear) )
						  {
						  //{
						  if(sponBookRec.Is_Active__c)
						  {
						  if(statisticsMap.containsKey('Booked'))
						  statisticsMap.put('Booked',statisticsMap.get('Booked') +1);
						  else
						  statisticsMap.put('Booked',1);
						  }
						  else
						  {
						  if(statisticsMap.containsKey('Pending'))
						  statisticsMap.put('Pending',statisticsMap.get('Pending') +1);
						  else
						  statisticsMap.put('Pending',1);
						  }
						  statisticsMap.put('Available', statisticsMap.get('Available')-1);
						 
						  }
						 
						 */
					}
				}
			}
		}
		for (String label : statisticsMap.keySet())
		{
			TemplateStatisticsWrapper tsWrapBookingObj = new TemplateStatisticsWrapper();
			tsWrapBookingObj.label = label;
			tsWrapBookingObj.count = statisticsMap.get(label);
			templateDataList.add(tsWrapBookingObj);
		}
		return templateDataList;


		}catch(Exception ex){
			Log4SF.logMessage('SponsorshipController','getTemplateStatistics',ex.getMessage(),ex,UserInfo.getUserId(),bookingID);
            return null;
		}
		
	}

	/*
	 *    This method is used for the template statistics LWC
	 *    It is used to -
	 *    1. Prepare and Return a wrapper list of data that is going to tell the UI about the booked,
	 *      pending and Available template counts choosen from the UI
	 *    
	 *    @author     Ankit Bhatia
	 *    @param      String		            ID of the booking reord choosen from the UI
	 *    @return     List<DataSet>          Wrapper list to show the booking percentage on UI
	 */
	@AuraEnabled
	public static List<TemplateStatisticsWrapper> getAvailableTemplateStatistics(String templateID, Date startDate, date endDate)
	{
		try{
			Integer bookingStartMonth = 0;
			Integer bookingEndMonth = 0;
			Integer bookingStartYear = startDate.year();
			Integer bookingEndYear = startDate.year();
			Integer templateQuantity = 0;
	
			startDate = startDate.toStartOfMonth();
			endDate = endDate.toStartOfMonth();
	
			List<TemplateStatisticsWrapper> templateDataList = new List<TemplateStatisticsWrapper> ();
			List<Templates__c> templateList = new List<Templates__c> ();
			Map<String, Integer> statisticsMap = new Map<String, Integer> ();
			//List<Sponsorship_Booking__c> bookingList = [Select ID, Start_Date__c, End_Date__c, Template__c from Sponsorship_Booking__c where ID =: bookingID];
			bookingStartMonth = startDate.month();
			bookingEndMonth = endDate.month();
			templateList = [Select End_Date__c, Id, Name, OwnerId, Total_Quantity__c, Start_Date__c, Template_Inventory__c,
			(select id, name, Start_Date__c, End_Date__c, Is_Active__c, Status__c from Sponsorship_Bookings__r)
							from Templates__c where id = :templateID and Total_Quantity__c != null ORDER BY Start_Date__c desc];
	
			for (Templates__c templateRecord : templateList)
			{
				templateRecord.Start_Date__c = templateRecord.Start_Date__c.toStartOfMonth();
				templateRecord.End_Date__c = templateRecord.End_Date__c.toStartOfMonth();
				templateQuantity = Integer.valueOf(templateRecord.Total_Quantity__c);
				statisticsMap.put('Available', templateQuantity);
				system.debug('templateRecord=' + templateRecord);
				system.debug('templateRecord=' + templateRecord.Sponsorship_Bookings__r);
				if (templateRecord.Sponsorship_Bookings__r != null && templateRecord.Sponsorship_Bookings__r.size()> 0)
				{
					for (Sponsorship_Booking__c sponBookRec : templateRecord.Sponsorship_Bookings__r)
					{
						sponBookRec.Start_Date__c = sponBookRec.Start_Date__c.toStartOfMonth();
						sponBookRec.End_Date__c = sponBookRec.End_Date__c.toStartOfMonth();
						system.debug('sponBookRec =' + sponBookRec);
						Integer currentBookStartMonth = sponBookRec.Start_Date__c.month();
						Integer currentBookEndMonth = sponBookRec.End_Date__c.month();
						Integer currentBookStartYear = sponBookRec.Start_Date__c.year();
						Integer currentBookEndYear = sponBookRec.End_Date__c.year();
						system.debug('startDate = ' + startDate + ' endDate =' + endDate);
						system.debug('templateRecord.Start_Date__c =' + sponBookRec.Start_Date__c + ' templateRecord.End_Date__c =' + sponBookRec.End_Date__c + ' startDate >= templateRecord.Start_Date__c =' + (startDate >= sponBookRec.Start_Date__c));
	
						if (SponsorshipController.checkStartEndDate(startDate, endDate, sponBookRec.Start_Date__c, sponBookRec.End_Date__c))
						{
	
							if (sponBookRec.Is_Active__c)
							{
								if (statisticsMap.containsKey('Booked'))
								statisticsMap.put('Booked', statisticsMap.get('Booked') + 1);
								else
								statisticsMap.put('Booked', 1);
							}
							else
							{
								if (statisticsMap.containsKey('Pending'))
								statisticsMap.put('Pending', statisticsMap.get('Pending') + 1);
								else
								statisticsMap.put('Pending', 1);
							}
							statisticsMap.put('Available', statisticsMap.get('Available') - 1);
						}
						/*
						  if((bookingStartMonth >= currentBookStartMonth && bookingStartMonth <= currentBookEndMonth ) && (currentBookStartYear == bookingEndYear) || (bookingStartMonth >= currentBookStartMonth && bookingStartMonth <= currentBookEndMonth ) && (currentBookStartYear == bookingEndYear))
						  {
						  //if( (currentBookStartMonth >= bookingStartMonth &&  currentBookStartMonth <= bookingEndMonth) || (currentBookEndMonth >= bookingStartMonth &&  currentBookEndMonth <= bookingEndMonth))
						  //{
						  system.debug('sponBookRec ='+ sponBookRec);
						  if(sponBookRec.Is_Active__c)
						  {
						  if(statisticsMap.containsKey('Booked'))
						  statisticsMap.put('Booked',statisticsMap.get('Booked') +1);
						  else
						  statisticsMap.put('Booked',1);
						  }
						  else
						  {
						  if(statisticsMap.containsKey('Pending'))
						  statisticsMap.put('Pending',statisticsMap.get('Pending') +1);
						  else
						  statisticsMap.put('Pending',1);
						  }
						  statisticsMap.put('Available', statisticsMap.get('Available')-1);
						  }
						  else if(( currentBookEndMonth <= bookingEndMonth) && (currentBookEndYear > bookingStartYear && currentBookEndYear == bookingEndYear) )
						  {
						  system.debug('currentBookStartMonth ='+currentBookStartMonth +' bookingEndMonth ='+bookingEndMonth +' currentBookStartYear ='+currentBookStartYear + 'currentBookEndYear ' + currentBookEndYear);					//{
						  if(sponBookRec.Is_Active__c)
						  {
						  if(statisticsMap.containsKey('Booked'))
						  statisticsMap.put('Booked',statisticsMap.get('Booked') +1);
						  else
						  statisticsMap.put('Booked',1);
						  }
						  else
						  {
						  if(statisticsMap.containsKey('Pending'))
						  statisticsMap.put('Pending',statisticsMap.get('Pending') +1);
						  else
						  statisticsMap.put('Pending',1);
						  }
						  statisticsMap.put('Available', statisticsMap.get('Available')-1);
						 
						  }
						 */
					}
				}
			}
			for (String label : statisticsMap.keySet())
			{
				TemplateStatisticsWrapper tsWrapBookingObj = new TemplateStatisticsWrapper();
				tsWrapBookingObj.label = label;
				tsWrapBookingObj.count = statisticsMap.get(label);
				templateDataList.add(tsWrapBookingObj);
			}
			System.debug(' templateDataList ' + templateDataList);
			return templateDataList;
		}catch(Exception ex){
			Log4SF.logMessage('SponsorshipController','getAvailableTemplateStatistics',ex.getMessage(),ex,UserInfo.getUserId(),templateID);
            return null;
		}
		
	}

	public static Boolean checkStartEndDate(Date newStartDate, Date newEndDate, Date startDate, Date endDate)
	{
		try
		{
			system.debug('startDate =' + startDate + ' endDate =' + endDate + ' newStartDate =' + newStartDate + ' newEndDate =' + newEndDate);
			startDate = startDate.toStartOfMonth();
			endDate = endDate.toStartOfMonth();
			newStartDate = newStartDate.toStartOfMonth();
			newEndDate = newEndDate.toStartOfMonth();
			system.debug('firstBlock = ' + (newStartDate <= startDate && newEndDate >= startDate) + ' block2 = ' + (newStartDate <= endDate && newEndDate >= endDate) + ' block3 = ' + (newStartDate == startDate && newEndDate == endDate) + ' block4 = ' + (newStartDate <= startDate && newEndDate >= endDate));
			//new code 
			if ((newStartDate <= startDate && newEndDate >= startDate) || (newStartDate <= endDate && newEndDate >= endDate) || (newStartDate == startDate && newEndDate == endDate) || (newStartDate <= startDate && newEndDate >= endDate) || (newStartDate >= startDate && newEndDate <= endDate))
			//if(((newStartDate >= startDate && newStartDate <= endDate)) || (newEndDate >= startDate && newEndDate <= endDate))  
			{
				System.debug(' true ');
				return true;
			}
			return false;
		}
		catch(Exception ex)
		{
			System.debug(' ex ' + ex.getMessage());
			Log4SF.logMessage('SponsorshipController','checkStartEndDate',ex.getMessage(),ex,UserInfo.getUserId(),'');

			return null;
		}

	}
    
    public static Boolean checkStartEndDates(Date newStartDate, Date newEndDate, Date startDate, Date endDate)
	{
		try
		{
			system.debug('startDate =' + startDate + ' endDate =' + endDate + ' newStartDate =' + newStartDate + ' newEndDate =' + newEndDate);
			//startDate = startDate.toStartOfMonth();
			//endDate = endDate.toStartOfMonth();
			//newStartDate = newStartDate.toStartOfMonth();
			//newEndDate = newEndDate.toStartOfMonth();
			system.debug('firstBlock = ' + (newStartDate <= startDate && newEndDate >= startDate) + ' block2 = ' + (newStartDate <= endDate && newEndDate >= endDate) + ' block3 = ' + (newStartDate == startDate && newEndDate == endDate) + ' block4 = ' + (newStartDate <= startDate && newEndDate >= endDate));
			//new code 
			if ((newStartDate <= startDate && newEndDate >= startDate) || (newStartDate <= endDate && newEndDate >= endDate) || (newStartDate == startDate && newEndDate == endDate) || (newStartDate <= startDate && newEndDate >= endDate) || (newStartDate >= startDate && newEndDate <= endDate))
			//if(((newStartDate >= startDate && newStartDate <= endDate)) || (newEndDate >= startDate && newEndDate <= endDate))  
			{
				System.debug(' true ');
				return true;
			}
			return false;
		}
		catch(Exception ex)
		{
			System.debug(' ex ' + ex.getMessage());
			Log4SF.logMessage('SponsorshipController','checkStartEndDates',ex.getMessage(),ex,UserInfo.getUserId(),'');
			return null;
		}

	}

	public void sendBookingEmail(List<Sponsorship_Booking__c> bookingList, Boolean isUpdated, String bsId)
	{ 
		try{
			Map<String, List<String>> mapSyscodeUserID = new Map<String, List<String>> ();
			List<string> userID = new List<String> (); //List of User's email
			String defaultUser = Label.DefaultUserId; //Default email of B Integration user
			System.debug('Default user Mail Id '+ defaultUser);
			
			for (Sponsorship_Booking__c sb : bookingList)
			{
			 UserID = new List<String> ();
				if ((sb.PPM1__c != null) &&  (!userID.contains(sb.PPM1__c)))
				userID.add(sb.PPM1__c);
				if ((sb.PPM2__c != null) &&  (!userID.contains(sb.PPM2__c)))
				userID.add(sb.PPM2__c);
				System.debug('PPM2 mail Id '+ sb.PPM2__c);
				if ((sb.Sales_Director__c != null) &&  (!userID.contains(sb.Sales_Director__c)))
				userID.add(sb.Sales_Director__c);
				if ((sb.Sales_Director_2__c != null) && (!userID.contains(sb.Sales_Director_2__c)))
				userID.add(sb.Sales_Director_2__c);
				System.debug('Sales Director2 mail Id '+ sb.Sales_Director_2__c);
				if (userID.size() == 0)
				userID.add(defaultUser);
				//bookingID = sb.Booked_Sponsorship__c;
				System.debug('Users mail List '+ userID);
				if (!mapSyscodeUserID.containsKey(sb.Syscode__c))
				{
					mapSyscodeUserID.put(sb.Syscode__c, userID);
	
				}
				else
				{
					userID.addAll(mapSyscodeUserID.get(sb.Syscode__c));
					mapSyscodeUserID.put(sb.Syscode__c, userID);
				}
			}
	
			//mapSyscodeUserID.put
				Integer count = 1;
				for (string sys : mapSyscodeUserID.keySet())
				{
					System.debug('email sent');
					if(count < 10 )
					{	
						EmailTemplate et = [Select Id from EmailTemplate where DeveloperName = 'Booked_Sponsorship_Submitted'];
						Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, null, bsId);
						System.debug('set mail Address '+ mapSyscodeUserID.get(sys));
						mail.setToAddresses(mapSyscodeUserID.get(sys));
						Messaging.sendEmail(new Messaging.Email[] { mail });
					}
					if(count >= 10 && count <= mapSyscodeUserID.keySet().size())
					{
							SponsorshipController.sendPPMEmail(bsId,mapSyscodeUserID.get(sys));
					}
					count ++;
				}
		}catch(Exception ex){
			Log4SF.logMessage('SponsorshipController','sendBookingEmail',ex.getMessage(),ex,UserInfo.getUserId(),bsId);
		}
		
	}

	/*
	Method to be used when we reach the LIMIt for Single Email Message.
	*/
	@Future
	public static void sendPPMEmail(string bsId,List<String> userIDList)
	{
		try{
			EmailTemplate et = [Select Id from EmailTemplate where DeveloperName = 'Booked_Sponsorship_Submitted'];
			Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, null, bsId);
			System.debug('set mail Address '+ userIDList);
			mail.setToAddresses(userIDList);
			Messaging.sendEmail(new Messaging.Email[] { mail });
		}catch(Exception ex){
			Log4SF.logMessage('SponsorshipController','sendPPMEmail',ex.getMessage(),ex,UserInfo.getUserId(),bsId);
		}
	
	}


	@AuraEnabled
	public static Map<String, Boolean> sponsorshipBookingAvailability(List<bookingDetailsWrapper> selectedSponsorshipDetails) {
		try{
			// Map to send to frontend
	 		Map<String, Boolean> bookingCheckResult = new Map<String, Boolean> ();
			//validateBooking(selectedSponsorshipDetails);
			
			 
			  // List of Id's to get booking details of booked templates
			List<String> selectedIds = new List<String>();
			for(bookingDetailsWrapper wrapper: selectedSponsorshipDetails){
				selectedIds.add(wrapper.selectedTemplateId);
			}
			 
			  // Add the Booking Details and new entered data in the same data for avoiding extra loop
            List<Sponsorship_Booking__c> sponsorshipDetails = getBookedTemplates(selectedIds,'null');
            for(Integer i = 0;i< selectedSponsorshipDetails.size();i++){
                for(Sponsorship_Booking__c sponsorshipBookingDetail: sponsorshipDetails){
                    if(selectedSponsorshipDetails[i].selectedTemplateId == sponsorshipBookingDetail.Template__r.Id){
                        if(selectedSponsorshipDetails[i].bookingDetails == null){
                            selectedSponsorshipDetails[i].bookingDetails = new List<Sponsorship_Booking__c>();
                            selectedSponsorshipDetails[i].bookingDetails.add(sponsorshipBookingDetail);
                        }else{
                            selectedSponsorshipDetails[i].bookingDetails.add(sponsorshipBookingDetail);
                        }
                    }
                }
            }
            
            // Check for error method starts 
            for(bookingDetailsWrapper bookWrap: selectedSponsorshipDetails){
                // Special case for one quantity
                // if(bookWrap.totalQuantity == 1){
                // 	for(Integer i = 0;i<bookWrap.bookingDetails.size();i++){
                // 		if(dateOverlappingChecker(bookWrap.UIStartDate,bookWrap.UIEndDate,bookWrap.bookingDetails[i].Start_Date__c,bookWrap.bookingDetails[i].End_Date__c)){
                // 			bookingCheckResult.put(bookWrap.selectedTemplateId,true);
                // 			break;
                // 		}
                // 	}
                // 	System.debug('bookingCheckResult '+ bookingCheckResult);
                // }else{  
                // Check for quantities 
                Integer totalSponsorship = bookWrap.totalQuantity;
                //Map to add as many entities for timelines as total quantity of template
                Map<Integer,List<Sponsorship_Booking__c>> sponsorshipComparison = new Map<Integer,List<Sponsorship_Booking__c>>();
                for(Integer i=0;i<totalSponsorship;i++){
                    sponsorshipComparison.put(i,new List<Sponsorship_Booking__c>());
                }
                
                // Map for booking overlap with each other records
                Map<Sponsorship_Booking__c,Map<Sponsorship_Booking__c,Boolean>> comparedBookingDetails = new Map<Sponsorship_Booking__c,Map<Sponsorship_Booking__c,Boolean>>();
                
                // Logic for error 
                for(Sponsorship_Booking__c bookings: bookWrap.bookingDetails){
                    System.debug('bookWrap.bookingDetails '+ bookings);
                    System.debug('Booking size'+ bookWrap.bookingDetails.size());
                    List<Boolean> bookingAdded = new List<Boolean>();
                    System.debug('sponsorshipComparison.size() '+ sponsorshipComparison.size());
                    //Adding booking to entities 
                    for(Integer i = 0;i<sponsorshipComparison.size();i++){
                        Boolean overLappingPresent = false;
                        List<Sponsorship_Booking__c> compareList = sponsorshipComparison.get(i);
                        System.debug('compareList.size() '+compareList.size());
                        if(compareList.size()>0){
                            for(Sponsorship_Booking__c sb: compareList){
                                System.debug('sb '+ sb);
                                if(dateOverlappingChecker(bookings.Start_Date__c,bookings.End_Date__c,sb.Start_Date__c,sb.End_Date__c)){
                                    System.debug('Inside first if');
                                    overLappingPresent = true;
                                    comparedBookingDetails.put(bookings,new Map<Sponsorship_Booking__c,Boolean>{sb=>true});
                                }
                            }
                        }
                        if(compareList.size() == 0 || (compareList.size()>0 && overLappingPresent == false)){
                            System.debug('@@Booking added in this entity --- ' + i); 
                            System.debug('@@ Booking added Id ' + bookings.Id);
                            sponsorshipComparison.get(i).add(bookings);
                            bookingAdded.add(true);
                            break;
                        }else{
                            System.debug('@@bOOKING NOT ADDED IN FOLLOWING ENTITY - ' + i );
                            bookingAdded.add(false);
                        }
                    }
                    
                    // Logic to adjust bookings to go here 
                    
                    // System.debug('bookingAdded '+ bookingAdded);
                    // if(bookingAdded.contains(false)){
                    // 	System.debug('bookingAdded contains false');
                    // 	bookingCheckResult.put(bookWrap.selectedTemplateId,true);
                    // 	break;
                    // } // Extra logic with second map to go here
                }
                
                Boolean isBookable = false;
                // Code to debug each entity number and list of sponsorship bookings in that entity
                System.debug('Booked sponsorship Comparison list '+sponsorshipComparison);
                for(Integer i : sponsorshipComparison.keyset()){
                    List<Sponsorship_Booking__c> list1 = sponsorshipComparison.get(i);
                    for(Sponsorship_Booking__c sb : list1){
                        System.debug('@@map dbug sb--------  ' + sb);
                        System.debug('@@map entity number--------  ' + i);
                    }
                }
                
                //Code for adding error in the map to be sent to frontend 
                for(Integer i = 0;i<sponsorshipComparison.size();i++){
                    List<Sponsorship_Booking__c> theList = sponsorshipComparison.get(i);
                    System.debug('theList '+theList );
                    Boolean overlap = false;
                    for(Sponsorship_Booking__c sb : theList){
                        System.debug('@@sb ' + sb);
                        System.debug('@@startd ' +bookWrap.UIStartDate);
                        System.debug('@@ed ' +bookWrap.UIEndDate);
                        if(dateOverlappingChecker(bookWrap.UIStartDate,bookWrap.UIEndDate,sb.Start_Date__c,sb.End_Date__c)){
                            System.debug('Booking Date overlapped');
                            overlap = true;
                            break;
                        }
                    }
                    if(overlap == false){
                        System.debug('@@ Entity which allowed the booking : ' + i);
                        System.debug('@@ Entity 7 - ' + theList);
                        isBookable = true;
                        System.debug('Booking can be made');
                    }
                }
                if(isBookable){
                    bookingCheckResult.put(bookWrap.selectedTemplateId,false);
                }else{
                    bookingCheckResult.put(bookWrap.selectedTemplateId,true);
                }
                //}
            }
			 System.debug('@@booking Check Result  ' +  bookingCheckResult);
			 return bookingCheckResult;

		}
		catch(Exception ex) {
			System.debug(' ex ' + ex.getMessage());
			Log4SF.logMessage('SponsorshipController','sponsorshipBookingAvailability',ex.getMessage(),ex,UserInfo.getUserId(),'');
			return null;
		}
	}

	public Boolean dateComparisonChecker(date StartDate, date EndDate, date checkDate) {
		try {
			System.debug('dateComparisonChecker ' + checkDate + startDate + endDate);

			if ((checkDate <= EndDate && checkDate >= StartDate)) {
				return true;
			}
			return false;
		}
		catch(Exception ex) {
			System.debug(' ex ' + ex.getMessage());
			Log4SF.logMessage('SponsorshipController','dateComparisonChecker',ex.getMessage(),ex,UserInfo.getUserId(),'');
			return null;
		}


	}

	public static Boolean dateOverlappingChecker(Date checkStartDate, Date checkEndDate, Date startDate, Date endDate) {
		try {
			System.debug('dateOverlappingChecker ' + checkStartDate + checkEndDate + startDate + endDate);
			SponsorshipController sc = new SponsorshipController();
			if ((sc.dateComparisonChecker(startDate, endDate, checkStartDate)) || (sc.dateComparisonChecker(startDate, endDate, checkEndDate)) || (startDate >= checkStartDate && endDate <= checkEndDate)) {
				return true;
			}
			return false;
		}
		catch(Exception ex) {
			System.debug(' ex ' + ex.getMessage());
			Log4SF.logMessage('SponsorshipController','dateOverlappingChecker',ex.getMessage(),ex,UserInfo.getUserId(),'');
			return null;
		}

	}

	public Class TemplateStatisticsWrapper {
		@AuraEnabled
		public String label { get; set; }

		@AuraEnabled
		public Decimal count { get; set; }

		public TemplateStatisticsWrapper()
		{
			label = '';
			count = 0;
		}
	}

	/*public static Map<String, Boolean> validateBooking(List<bookingDetailsWrapper> selectedSponsorshipDetails) {
		// Map to send to frontend
		Map<String, Boolean> bookingCheckResult = new Map<String, Boolean> ();

		// List of Id's to get booking details of booked templates
		List<String> selectedIds = new List<String> ();
		for (bookingDetailsWrapper wrapper : selectedSponsorshipDetails) {
			selectedIds.add(wrapper.selectedTemplateId);
		}
		// Add the Booking Details and new entered data in the same data for avoiding extra loop
		Map<ID, List<Sponsorship_Booking__c>> sponsorshipDetails = getTemplatesBookings(selectedIds);
		for (Integer i = 0; i<selectedSponsorshipDetails.size(); i++) {
			if (sponsorshipDetails.containsKey(selectedSponsorshipDetails[i].selectedTemplateId)) {
				if (selectedSponsorshipDetails[i].bookingDetails == null) {
					selectedSponsorshipDetails[i].bookingDetails = sponsorshipDetails.get(selectedSponsorshipDetails[i].selectedTemplateId);
				}
			}
		}

		// Check for error method starts 
		for (bookingDetailsWrapper bookWrap : selectedSponsorshipDetails)
		{
			// Map for booking overlap with each other records
			Map<Sponsorship_Booking__c, Map<Sponsorship_Booking__c, Boolean>> comparedBookingDetails = new Map<Sponsorship_Booking__c, Map<Sponsorship_Booking__c, Boolean>> ();
			Map<Integer, List<Sponsorship_Booking__c>> sponsorshipComparison = new Map<Integer, List<Sponsorship_Booking__c>> ();
			Integer totalSponsorship = bookWrap.totalQuantity;
			Integer counter = 0;
			Map<Id, Boolean> compWithAllBookings = new Map<Id, Boolean> ();
			// Map for Booking ID => Template Key its associated with
			Map<Id, Integer> mapBookingTemplateKey = new Map<Id, Integer> ();
			System.debug('bookWrap ' + bookWrap.UIStartDate);


			if (bookWrap.bookingDetails.size()> 0)
			{

				for (Integer i = 0; i<totalSponsorship; i++) {
					sponsorshipComparison.put(i, new List<Sponsorship_Booking__c> ());
				}
				System.debug(bookWrap.bookingDetails.size());

				//Map to add as many entities for timelines as total quantity of template	
				sponsorshipComparison.put(0, new List<Sponsorship_Booking__c> { bookWrap.bookingDetails[0] });
				mapBookingTemplateKey.put(bookWrap.bookingDetails[0].ID, 0);
				Boolean uiDateCheck = dateOverlappingChecker(bookWrap.UIStartDate, bookWrap.UIEndDate, bookWrap.bookingDetails[0].Start_Date__c, bookWrap.bookingDetails[0].End_Date__c);
				compWithAllBookings.put(bookWrap.bookingDetails[0].ID, uiDateCheck);
				System.debug('bookWrap.bookingDetails[0] ' + bookWrap.bookingDetails[0] + uiDateCheck);
				
				for (Integer i = 1; i<bookWrap.bookingDetails.size(); i++)
				{

					Sponsorship_Booking__c booking2Compare = bookWrap.bookingDetails[i];
					// Check if the UI Dates overlap with the booking
					uiDateCheck = dateOverlappingChecker(bookWrap.UIStartDate, bookWrap.UIEndDate, booking2Compare.Start_Date__c, booking2Compare.End_Date__c);
					compWithAllBookings.put(booking2Compare.ID, uiDateCheck);
					System.debug('booking2Compare ' + booking2Compare + uiDateCheck);

					for (Integer key : sponsorshipComparison.keySet())
					{
						System.debug('Key ' + key);
						Boolean isTemplateKeyAvailable = true;
						if (sponsorshipComparison.get(key).size()> 0 && (!mapBookingTemplateKey.containsKey(bookWrap.bookingDetails[i].ID)))
						{

							for (Sponsorship_Booking__c sb : sponsorshipComparison.get(key))
							{
								Boolean checkDateValidity = dateOverlappingChecker(booking2Compare.Start_Date__c, booking2Compare.End_Date__c, sb.Start_Date__c, sb.End_Date__c);
								System.debug('Key ' + key);

								if (comparedBookingDetails.containsKey(booking2Compare))
								{
									comparedBookingDetails.get(booking2Compare).put(sb, checkDateValidity);
								}
								else
								comparedBookingDetails.put(booking2Compare, new Map<Sponsorship_Booking__c, Boolean> { sb => checkDateValidity });
								System.debug(key + ' getKey ' + sponsorshipComparison.get(key).size() + checkDateValidity);

								// Check if bookings overlap 
								if (!checkDateValidity)
								{
									sponsorshipComparison.get(key).add(bookWrap.bookingDetails[i]);
									mapBookingTemplateKey.put(bookWrap.bookingDetails[i].ID, key);
									System.debug(sponsorshipComparison.get(key).size());
									break;
								}
							}
						}
						else if (!mapBookingTemplateKey.containsKey(bookWrap.bookingDetails[i].ID))
						{
							sponsorshipComparison.get(key).add(bookWrap.bookingDetails[i]);
							mapBookingTemplateKey.put(bookWrap.bookingDetails[i].ID, key);
							System.debug(sponsorshipComparison.get(key).size());
							break;
						}

					}
				}
			}
			Integer key = sponsorshipComparison.keySet().size();
			System.debug('key ' + key + sponsorshipComparison.keySet() + totalSponsorship);
			Map<Integer, Boolean> mapKeyAvailability = new Map<Integer, Boolean> ();
			if (key == totalSponsorship)
			{
				System.debug('key1 ' + key + sponsorshipComparison.keySet() + totalSponsorship);

				for (Integer tempSize = 0; tempSize<key; tempSize++)
				{
					Boolean isTemplateKeyAvailable = true;
					System.debug('tempSize ' + key + tempSize + sponsorshipComparison.get(tempSize));
					if (sponsorshipComparison.get(tempSize).size()> 0)
					{
						for (Sponsorship_Booking__c sb : sponsorshipComparison.get(tempSize))
						{
							System.debug(sb);
							if (compWithAllBookings.containsKey(sb.ID))
							{
								Boolean checkDateValidity = compWithAllBookings.get(sb.ID);
								System.debug('vsb ' + checkDateValidity + sb);
								//mapKeyAvailability.put(tempSize,)
								if (checkDateValidity)
								{
									isTemplateKeyAvailable = false;
									//break;
								}
							}

						}
						if (isTemplateKeyAvailable)
						{
							System.debug('New Booking can be created in the Template ' + tempSize);
							mapKeyAvailability.put(tempSize, true);
							return null;
						}
					}
				}
				if (mapKeyAvailability.size() == 0)
				{
					for (Sponsorship_Booking__c bookingID : comparedBookingDetails.keySet())
					{
						if (compWithAllBookings.get(bookingID.ID))
						{
							Integer tempKey = mapBookingTemplateKey.get(bookingID.ID);
							if (sponsorshipComparison.containsKey(tempKey))
							{
								for (Integer tempSize = 0; tempSize<sponsorshipComparison.size(); tempSize++)
								{
									if (tempSize != tempKey)
									{
										System.debug(tempKey + ' n ' + tempSize);
									}
								}
							}

						}
					}
				}
			}
		}

		return null;
	}*/

@AuraEnabled
    public static List<allSelectedTemplatesWrapper> getMaxMinBookedSponsorships(String allSelectedTemplates, Boolean checkFirstRightToRefusal) {
		try{
            System.debug('allSelectedTemplates: ' + allSelectedTemplates);
        List<allSelectedTemplatesWrapper> newAllSelectedTemplatesWrapper = new List<allSelectedTemplatesWrapper> ();
        List<allSelectedTemplatesWrapper> flusers = (List<allSelectedTemplatesWrapper>) json.deserialize(allSelectedTemplates, List<allSelectedTemplatesWrapper>.class);

        System.debug('flusers: ' + flusers);
        Set<String> tempIDs = new Set<String> ();
        Set<Date> startDate = new Set<Date> ();
        Set<Date> endDate = new Set<Date> ();
        Map<string, List<allSelectedTemplatesWrapper>> abcd = new Map<string, List<allSelectedTemplatesWrapper>> ();

        String WhereCondition;
        for (allSelectedTemplatesWrapper aSTW : flusers) {
            WhereCondition += '( Sponsorship__c =\'' + aSTW.tempID + '\' AND Sponsorship_Inventory_Date__c >=' + aSTW.sd + ' AND Sponsorship_Inventory_Date__c <= ' +aSTW.ed + ') OR';
            //startDate.add(Date.valueOf(aSTW.sd));
            //endDate.add(Date.valueOf(aSTW.ed));
            //tempIDs.add(aSTW.tempID);
        }
        WhereCondition = WhereCondition.removeEnd('OR');
        WhereCondition = WhereCondition.replaceAll('null', '');

        System.debug('WhereCondition: ' + WhereCondition);
        //system.debug('strValue1: ' + WhereCondition.removeEnd('OR'));
        //system.debug('strValue2: ' + WhereCondition.replaceAll('null',''));


        //Sponsorship__c IN : tempIDs AND Sponsorship_Inventory_Date__c >= :startDate AND Sponsorship_Inventory_Date__c <= :endDate
        // System.debug('mapSelectedTemp===: ' + mapSelectedTemp.get('a2s7X000001ItwxQAC'));

        List<AggregateResult> sponsorDateInventory = new List<AggregateResult> ();

        String Str = 'SELECT Max(Booked_Quantity__c) BQ,Min(Available_Quantity__c) AQ, Sponsorship__c SP  from Sponsorship_Date_Inventory__c where ' + WhereCondition;
        Str = Str + 'group by Sponsorship__c';

        System.debug('Str: ' + Str);

        sponsorDateInventory = Database.query(Str);

        if (sponsorDateInventory.size() > 0) {

            for (AggregateResult aRes : sponsorDateInventory) {
                System.debug('aRes: ' + aRes);
                if (aRes.get('AQ') == 0 && !checkFirstRightToRefusal) {
                    allSelectedTemplatesWrapper aSTW = new allSelectedTemplatesWrapper();
                    aSTW.recordID = String.valueOf(aRes.get('SP'));
                    newAllSelectedTemplatesWrapper.add(aSTW);
                }
				else if(checkFirstRightToRefusal && aRes.get('AQ') == 1)
				{
					allSelectedTemplatesWrapper aSTW = new allSelectedTemplatesWrapper();
                    aSTW.recordID = String.valueOf(aRes.get('SP'));
                    newAllSelectedTemplatesWrapper.add(aSTW);
				}
            }
        }

        System.debug('sponsorDateInventory: ' + sponsorDateInventory);

        System.debug('newAllSelectedTemplatesWrapper: ' + newAllSelectedTemplatesWrapper);


        return newAllSelectedTemplatesWrapper;

    
		}catch(Exception ex){
			Log4SF.logMessage('SponsorshipController','getMaxMinBookedSponsorships',ex.getMessage(),ex,UserInfo.getUserId(),'');
			return null;
		}

        
    }


	/**
	* @description - Validate if there are other bookings that First Right to refusal enabled.
	* @param sprIDs - List of Sponsorship
	* @param accID - Account ID for the new booking.
	* @return - List of Bookings in the wrapper.
	*/ 
	@AuraEnabled
	public static List<FirstRightToRefusalWrapper> confirmFirstRightToRefusal(List<string> sprIDs,string accID, string allSelectedTemplates)
	{
		System.debug('allSelectedTemplates - '+allSelectedTemplates);
		string accID1 = '';
	string allSelectedTemplates1 = '';
		if(sprIDs.size() > 0 && allSelectedTemplates.length() > 0)
		{
			try{
			List<FirstRightToRefusalWrapper> wrapperList = new List<FirstRightToRefusalWrapper>();
			List<allSelectedTemplatesWrapper> rightToRefusalWrapper = getMaxMinBookedSponsorships(allSelectedTemplates,true);
			if(rightToRefusalWrapper.size() > 0)
			{
				list<String> sprIDList = new List<String>();
				for(allSelectedTemplatesWrapper ats : rightToRefusalWrapper)
				{
					sprIDList.add(ats.recordID);
				}
				
				List<Sponsorship_Booking__c> sprList = [Select ID, Booked_Sponsorship__r.Account__c, End_Date__c, Start_Date__c,Template__c,Opportunity__r.Owner.Name  from Sponsorship_Booking__c where Template__c in : sprIDList AND First_Right_to_Refusal__c= true];
				if(sprList.size() > 0)
				{
					for(Sponsorship_Booking__c sprBook : sprList)
					{
						//if(accID == sprBook.Booked_Sponsorship__r.Account__c)
						//{
							FirstRightToRefusalWrapper wrapperObj = new FirstRightToRefusalWrapper();
							wrapperObj.Account = sprBook.Booked_Sponsorship__r.Account__c;
							wrapperObj.bookingID = sprBook.ID;
							wrapperObj.accountID = sprBook.Booked_Sponsorship__r.Account__c;
							wrapperObj.startDate = sprBook.Start_Date__c;
							wrapperObj.endDate = sprBook.End_Date__c;
							wrapperObj.recordID = sprBook.Template__c;
							wrapperObj.aeName = sprBook.Opportunity__r.Owner.Name;
							wrapperList.add(wrapperObj);
						//}
					}
				}
				
				}
				return wrapperList;
			}

			catch(Exception ex)
			{
				        System.debug('confirmFirstRightToRefusal Exception: ' + ex);
						Log4SF.logMessage('SponsorshipController','confirmFirstRightToRefusal',ex.getMessage(),ex,UserInfo.getUserId(),'');

				return null;
			}
		}
		else
		return null;
		
	} 

	@AuraEnabled
    public static List<BarChartWrapperList> getMaxMinSponsorships(List<String> recordIds, Date startDate, Date endDate) {
		try{
            Date endDate1 = Date.valueOf(endDate);

        Date startDate1 = Date.valueOf(startDate);

        Map<Integer, String> monthNames = new Map<Integer, String> {
            1 => 'Jan',
            2 => 'Feb',
            3 => 'Mar',
            4 => 'Apr',
            5 => 'May',
            6 => 'Jun',
            7 => 'Jul',
            8 => 'Aug',
            9 => 'Sept',
            10 => 'Oct',
            11 => 'Nov',
            12 => 'Dec'
        };


        System.debug('endDate1: ' + endDate1);
        System.debug('startDate1: ' + startDate1);

        List<BarChartWrapperList> barWrapperList = new List<BarChartWrapperList> ();
        List<AggregateResult> sponsorshipBookingList = new List<AggregateResult> ();
        Set<String> sponsorshipName = new Set<String> ();
        Set<String> sponsorshipBarColor = new Set<String> ();
        Map<String, String> sponsorshipBarColorMap = new Map<String, String> ();

        sponsorshipBarColor.add('rgba(165,170,217,1)');
        sponsorshipBarColor.add('rgb(212, 131, 192)');
        sponsorshipBarColor.add('rgba(236, 228, 16, 0.8)');
        sponsorshipBarColor.add('rgba(89, 206, 227, 0.8)');

        //Integer columnBarWidth;

        Map<String, List<String>> categoriesDateYearMap = new Map<String, List<String>> ();
        Map<String, List<Integer>> sponsorshipAvailableDataMap = new Map<String, List<Integer>> ();
        Map<String, List<Integer>> sponsorshipBookedDataMap = new Map<String, List<Integer>> ();
        sponsorshipBookingList = Database.query('SELECT Max(Booked_Quantity__c) BQ,Min(Available_Quantity__c) AQ,CALENDAR_YEAR(Sponsorship_Inventory_Date__c) CY, CALENDAR_MONTH(Sponsorship_Inventory_Date__c) CM, Sponsorship__r.Name From Sponsorship_Date_Inventory__c where Sponsorship__c IN : recordIds  AND Sponsorship_Inventory_Date__c <= : endDate1 and Sponsorship_Inventory_Date__c>=: startDate1 group by CALENDAR_YEAR(Sponsorship_Inventory_Date__c),CALENDAR_MONTH(Sponsorship_Inventory_Date__c),Sponsorship__r.Name ');

        System.debug('recordIds: ' + recordIds);

        System.debug('sponsorshipBookingList: ' + sponsorshipBookingList);

        if (!sponsorshipBookingList.isEmpty()) {
            for (AggregateResult aggRes : sponsorshipBookingList) {

                sponsorshipName.add(String.valueOf(aggRes.get('Name')));



                if (!sponsorshipAvailableDataMap.containsKey(String.valueOf(aggRes.get('Name')))) {
                    sponsorshipAvailableDataMap.put(String.valueOf(aggRes.get('Name')), new List<Integer> ());
                }
                if (!sponsorshipBookedDataMap.containsKey(String.valueOf(aggRes.get('Name')))) {
                    sponsorshipBookedDataMap.put(String.valueOf(aggRes.get('Name')), new List<Integer> ());
                }
                if (!categoriesDateYearMap.containsKey(String.valueOf(aggRes.get('Name')))) {
                    categoriesDateYearMap.put(String.valueOf(aggRes.get('Name')), new List<String> ());
                }


                categoriesDateYearMap.get(String.valueOf(aggRes.get('Name'))).add(monthNames.get(Integer.valueOf(aggRes.get('CM'))) + '-' + String.valueOf(aggRes.get('CY')));
                sponsorshipAvailableDataMap.get(String.valueOf(aggRes.get('Name'))).add(Integer.valueOf(aggRes.get('AQ')));
                sponsorshipBookedDataMap.get(String.valueOf(aggRes.get('Name'))).add(Integer.valueOf(aggRes.get('BQ')));


                for (String strColor : sponsorshipBarColor) {
                    if (!sponsorshipBarColorMap.containsKey(String.valueOf(aggRes.get('Name')))) {
                        sponsorshipBarColorMap.put(String.valueOf(aggRes.get('Name')), strColor);

                    }
                    //System.debug('strColor: ' + strColor);
                }
                sponsorshipBarColor.remove(sponsorshipBarColorMap.get(String.valueOf(aggRes.get('Name'))));

            }

            //System.debug('sponsorshipBarColorMap: ' + sponsorshipBarColorMap);

            System.debug('sponsorshipAvailableDataMap: ' + sponsorshipAvailableDataMap);
            System.debug('sponsorshipBookedDataMap: ' + sponsorshipBookedDataMap);
            System.debug('sponsorshipName: ' + sponsorshipName);

        }


        if (!sponsorshipName.isEmpty()) {
            for (String sponsorName : sponsorshipName) {
                BarChartWrapperList barWrapperAvail = new BarChartWrapperList();
                barWrapperAvail.name = sponsorName;
                barWrapperAvail.color = sponsorshipBarColorMap.get(sponsorName);
                barWrapperAvail.categoriesList = categoriesDateYearMap.get(sponsorName);
                //'rgba(165,170,217,1)';
                barWrapperAvail.data = sponsorshipAvailableDataMap.get(sponsorName);
                barWrapperAvail.stack = sponsorName;
                barWrapperAvail.custom = 'Available';
                barWrapperAvail.pointWidth = 22;
                barWrapperList.add(barWrapperAvail);

                BarChartWrapperList barWrapperBooked = new BarChartWrapperList();
                barWrapperBooked.linkedTo = ':previous';
                barWrapperBooked.name = 'Booked';
                barWrapperBooked.color = 'rgb(150, 34, 26)';
                barWrapperBooked.data = sponsorshipBookedDataMap.get(sponsorName);
                barWrapperBooked.stack = sponsorName;
                barWrapperBooked.custom = 'Booked';
                barWrapperBooked.pointWidth = 22;
                barWrapperList.add(barWrapperBooked);

            }
        }
        System.debug('barWrapperList: ' + barWrapperList);


        //}
        return barWrapperList;
		}catch(Exception ex){
			Log4SF.logMessage('SponsorshipController','getMaxMinSponsorships',ex.getMessage(),ex,UserInfo.getUserId(),'');
			return null;
		}

        
    }

	public class FirstRightToRefusalWrapper {
		@AuraEnabled
        public String name { get; set; }
		@AuraEnabled
        public String bookingID { get; set; }
		@AuraEnabled
        public String Account { get; set; }
		@AuraEnabled
        public String accountID { get; set; }
		@AuraEnabled
        public Date startDate { get; set; }
		@AuraEnabled
        public Date endDate { get; set; }
		@AuraEnabled
        public String recordID { get; set; }
		@AuraEnabled
        public String aeName { get; set; }
	}
	public class BarChartWrapperList {
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String color { get; set; }
        @AuraEnabled
        public List<Integer> data { get; set; }
        @AuraEnabled
        public String stack { get; set; }
        @AuraEnabled
        public String custom { get; set; }
        @AuraEnabled
        public Integer pointWidth { get; set; }
        @AuraEnabled
        public String linkedTo { get; set; }
        @AuraEnabled
        public List<String> categoriesList { get; set; }
    }

	public class allSelectedTemplatesWrapper {
        @AuraEnabled
        public String ed;
        @AuraEnabled
        public String sd;
        @AuraEnabled
        public String tempID;
        @AuraEnabled
        public String recordID;
    }


	public class bookingDetailsWrapper {
		@AuraEnabled
		public String selectedTemplateId { get; set; }

		@AuraEnabled
		public Date UIStartDate { get; set; }

		@AuraEnabled
		public Date UIEndDate { get; set; }

		@AuraEnabled
		public Integer totalQuantity { get; set; }

		@AuraEnabled
		public List<Sponsorship_Booking__c> bookingDetails { get; set; }

		public bookingDetailsWrapper() {
			this.selectedTemplateId = '';
			this.UIStartDate = null;
			this.UIEndDate = null;
			this.totalQuantity = 0;
			this.bookingDetails = null;
		}

		public bookingDetailsWrapper(String selectedTemplateId, Date UIStartDate, Date UIEndDate, Integer totalQuantity, List<Sponsorship_Booking__c> bookingDetails) {
			this.selectedTemplateId = selectedTemplateId;
			this.UIStartDate = UIStartDate;
			this.UIEndDate = UIEndDate;
			this.totalQuantity = totalQuantity;
			this.bookingDetails = bookingDetails;
		}
	}

	public Class inventoryDetails {
		@AuraEnabled
		public String InventoryType { get; set; }

		@AuraEnabled
		public Integer availableQuantity { get; set; }

		@AuraEnabled
		public String TemplateId { get; set; }

		@AuraEnabled
		public String inventoryId { get; set; }

		@AuraEnabled
		public Integer totalQuantity { get; set; }

		@AuraEnabled
		public Integer bookedQuantity { get; set; }

		public inventoryDetails() {
			this.InventoryType = '';
			this.availableQuantity = 0;
			this.TemplateId = '';
			this.inventoryId = '';
			this.bookedQuantity = 0;
			this.totalQuantity = 0;
		}

		public inventoryDetails(String InventoryType, Integer availableQuantity, String TemplateId, String inventoryId, Integer totalQuantity, Integer bookedQuantity) {
			this.InventoryType = this.InventoryType;
			this.availableQuantity = this.availableQuantity;
			this.TemplateId = this.TemplateId;
			this.inventoryId = this.inventoryId;
			this.bookedQuantity = this.bookedQuantity;
			this.totalQuantity = this.totalQuantity;
		}
	}


	public Class bookingSponsorshipWrapper {
		@AuraEnabled
		public String label { get; set; }

		@AuraEnabled
		public String Id { get; set; }

		@AuraEnabled
		public Date StartDate { get; set; }

		@AuraEnabled
		public Date EndDate { get; set; }

		@AuraEnabled
		public Boolean showInGraph { get; set; }

		@AuraEnabled
		public Boolean  isRenewal { get; set; }

		@AuraEnabled
		public Boolean DateError { get; set; }

		@AuraEnabled
		public String Syscode { get; set; }

		@AuraEnabled
		public String State { get; set; }

		@AuraEnabled
		public String Market { get; set; }

		@AuraEnabled
		public String SystemName { get; set; }

		@AuraEnabled
		public String SystemType { get; set; }

		@AuraEnabled
		public String Mvpd { get; set; }

		@AuraEnabled
		public String NetworkCode { get; set; }

		@AuraEnabled
		public Boolean rangeError { get; set; }

		@AuraEnabled
		public Date templateStartDate { get; set; }

		@AuraEnabled
		public Date templateEndDate { get; set; }

		@AuraEnabled
		public Boolean bookedError { get; set; }

		@AuraEnabled
		public Integer totalQty { get; set; }

		@AuraEnabled
		public String Qty { get; set; }

		@AuraEnabled
		public Boolean isUpdate { get; set; }

		@AuraEnabled
		public Boolean isCanceled { get; set; }

		@AuraEnabled
		public List<inventoryDetails> inventory { get; set; }

		@AuraEnabled
		public Integer bookingQuantity { get; set; }

		@AuraEnabled
		public Integer initialQuantity { get; set; }

		@AuraEnabled
		public String syscodeId{get; set;}

		@AuraEnabled
		public Date UIStartDate { get; set; }

		@AuraEnabled
		public Date UIEndDate { get; set; }

		@AuraEnabled
		public Decimal linearRevenueContri { get; set; }

		@AuraEnabled
		public  Decimal streamingRevenueContri { get; set; }
		@AuraEnabled
		public Boolean  rightToRefusal { get; set; }
		

		public bookingSponsorshipWrapper() {
			this.label = '';
			this.Id = '';
			this.StartDate = null;
			this.EndDate = null;
			this.showInGraph = false;
			this.isRenewal = false;
			this.DateError = false;
			this.Syscode = '';
			this.State = '';
			this.Market = '';
			this.SystemName = '';
			this.SystemType = '';
			this.Mvpd = '';
			this.NetworkCode = '';
			this.rangeError = false;
			this.templateStartDate = null;
			this.templateEndDate = null;
			this.bookedError = false;
			this.Qty = '';
			this.isUpdate = false;
			this.isCanceled = false;
			this.totalQty = 0;
			this.bookingQuantity = 0;
			this.initialQuantity = 0;
			this.syscodeId = '';
			this.UIStartDate = null;
			this.UIEndDate = null;
						this.linearRevenueContri = 0;
			this.streamingRevenueContri = 0;
			this.rightToRefusal = false;
		}

		public bookingSponsorshipWrapper(String label, String Id, Date StartDate, Date EndDate, Boolean showInGraph, Boolean isRenewal, Boolean DateError, String Syscode, String State, String Market, String SystemName, String SystemType, String Mvpd,
		                                 String NetworkCode, Boolean rangeError, Date templateStartDate, Date templateEndDate, Boolean bookedError, Integer totalQty, String Qty, Boolean isUpdate, Boolean isCanceled, List<inventoryDetails> inventory, Integer initialQuantity, Integer bookingQuantity, String syscodeId,Date UIStartDate, Date UIEndDate)
		{
			this.label = label;
			this.Id = Id;
			this.StartDate = StartDate;
			this.EndDate = EndDate;
			this.showInGraph = showInGraph;
			this.isRenewal = isRenewal;
			this.DateError = DateError;
			this.Syscode = Syscode;
			this.State = State;
			this.Market = Market;
			this.SystemName = SystemName;
			this.SystemType = SystemType;
			this.Mvpd = Mvpd;
			this.NetworkCode = NetworkCode;
			this.rangeError = rangeError;
			this.templateStartDate = templateStartDate;
			this.templateEndDate = templateEndDate;
			this.bookedError = bookedError;
			this.Qty = Qty;
			this.isUpdate = isUpdate;
			this.isCanceled = isCanceled;
			this.totalQty = totalQty;
			this.inventory = inventory;
			this.initialQuantity = initialQuantity;
			this.bookingQuantity = bookingQuantity;
			this.syscodeId = syscodeId;
			this.UIStartDate = UIStartDate;
			this.UIEndDate = UIEndDate;
						this.linearRevenueContri = 0;
			this.streamingRevenueContri = 0;
			this.rightToRefusal = false;
		}
	}
    
    @AuraEnabled
     public static List<sponsorshipWrapper> sponsorshipid(String Syscode) {
       
        try{
        System.debug('Syscode: ' + Syscode);
            
       List<sponsorshipWrapper> sWrapper=new List<sponsorshipWrapper>();
       List<Templates__c> SponsorshipidList = new List<Templates__c>();

        SponsorshipidList = Database.query('select id ,Name,News_Syscode__c, Start_Date__c, Total_Quantity__c, Syscode__c, End_Date__c,Active__c from Templates__c where News_Syscode__c =:Syscode ');
		for(Templates__c spon:SponsorshipidList){
                sponsorshipWrapper Wrapp=new sponsorshipWrapper();
                Templates__c temp=new Templates__c();
                
                Wrapp.id=spon.id;
                Wrapp.sObjectType='Templates__c';
                Wrapp.title=spon.Name;
                Wrapp.subtitle='';
				Wrapp.StartDate=spon.Start_Date__c;
                Wrapp.EndDate=spon.End_Date__c;
				Wrapp.Quantity=spon.Total_Quantity__c;
				Wrapp.IsActive=spon.Active__c;
				 sWrapper.add(Wrapp);
            }
        System.debug('sponsorshipidList: ' + SponsorshipidList);
        return sWrapper;
		}
		catch(exception ex) { system.debug(ex.getStackTraceString()); 
			Log4SF.logMessage('SponsorshipController','sponsorshipid',ex.getMessage(),ex,UserInfo.getUserId(),'');
			throw ex; }
        
        
    }


	/*@AuraEnabled
	public static void BookingDetailToBeUpdated(String sponsorshipName,string recordIds) {
		List<Sponsorship_Booking__c> listOfSponsorshipBooking = new List<Sponsorship_Booking__c> ();
		List<Sponsorship_Booking__c> sbRecordToUpdate = new List<Sponsorship_Booking__c>();
		listOfSponsorshipBooking = Database.query('SELECT Id,Template__r.Name, Name,Opportunity__r.Name,Opportunity__r.Owner.Name,Opportunity__r.Account.Id,Account__c,Start_Date__c,End_Date__c,Syscode__c,Linear_Revenue__c,Quantity__c,Streaming_Revenue__c,Total_Revenue__c  FROM Sponsorship_Booking__c WHERE Template__c = :recordIds');
		for(Sponsorship_Booking__c sb : listOfSponsorshipBooking){
		sb.Name=sponsorshipName;
		sbRecordToUpdate.add(sb);
		}
		Update sbRecordToUpdate;
	}*/
    public class sponsorshipWrapper{
        
        @AuraEnabled
		public string id { get; set; }

		@AuraEnabled
		public string sObjectType { get; set; }

		@AuraEnabled
		public string title { get; set; }

		@AuraEnabled
		public String subtitle { get; set; }
		
		@AuraEnabled
		public date StartDate { get; set; }
		 
		@AuraEnabled
		public date EndDate { get; set; }

		@AuraEnabled
		public Double Quantity { get; set; }

		@AuraEnabled
		public Boolean IsActive { get; set; }
    }

	@AuraEnabled(cacheable = true)
	public static List<AEWrapper> AEDetails(String AEName) {
		try{
            system.debug('AEName'+AEName);
		ID CurrentUserId = UserInfo.getUserId();
		List<AEWrapper> AEWrapper=new List<AEWrapper>();
		//List<User> SponsorshipidList = new List<User>();
		System.debug('CurrentUserId'+CurrentUserId);
		List<User> AEDetails = new List<User>();
		//AEDetails = Database.query('Select Id, Name, Profile.Name,Approving_Manager__r.Profile.Name,Approving_Manager__r.Name From User where Profile.Name = "Master - Account Executive" AND Approving_Manager__r.ID = :CurrentUserId');
		AEDetails=[Select Id, Name, Profile.Name,Approving_Manager__r.Profile.Name,Approving_Manager__r.Name From User where Profile.Name = 'Master - Account Executive' AND Approving_Manager__r.ID = :CurrentUserId];
		for(User users:AEDetails){
			AEWrapper AEWrapp=new AEWrapper();
			User temp=new User();
			AEWrapp.id=users.id;
			AEWrapp.sObjectType='User';
			AEWrapp.title=users.Name;
			AEWrapp.subtitle='';
			//Wrapp.StartDate=spon.Start_Date__c;
			//Wrapp.EndDate=spon.End_Date__c;
			//Wrapp.Quantity=spon.Total_Quantity__c;
			//Wrapp.IsActive=spon.Active__c;
			AEWrapper.add(AEWrapp);
		}
		
		
		System.debug('AEDetails List ::::' + AEDetails);
		return AEWrapper;
		}catch(Exception ex){
			Log4SF.logMessage('SponsorshipController','AEDetails',ex.getMessage(),ex,UserInfo.getUserId(),'');
			return null;
		}
		
	}

	public class AEWrapper{
        
        @AuraEnabled
		public string id { get; set; }

		@AuraEnabled
		public string sObjectType { get; set; }

		@AuraEnabled
		public string title { get; set; }

		@AuraEnabled
		public String subtitle { get; set; }
		
	}
	@AuraEnabled
	public static List<Account_Trends__c> AccountTrend(string SelectAeID){
		try {
         Integer currentmonth = Date.Today().Month();
         Integer currentyear = Date.Today().Year(); 
			List<Account_Trends__c> AccountTrendlst=new List<Account_Trends__c>();
	 AccountTrendlst=[SELECT Id, Name, Account__c,Account__r.Name,AccountExecutive__r.Name,AccountExecutive__c,PY_Total_Net_Actual_Revenue__c, Account_Health__c, OwnedByAccountExecutive__c, Total_Net_Actual_Revenue__c,Month_Value__c FROM Account_Trends__c Where AccountExecutive__c =:SelectAeID AND  Month_Value__c =:currentmonth  AND Year__c =: currentyear];
		return AccountTrendlst;
	} catch (Exception e) {
		Log4SF.logMessage('SponsorshipController','AccountTrend',e.getMessage(),e,UserInfo.getUserId(),'');
			throw new AuraHandledException(e.getMessage());
		}
	}
	@AuraEnabled
	public static List<Account_Trends__c> AllAEAccountTrend(string LSMID){
		try {
        Integer currentmonth = Date.Today().Month();
        Integer currentyear = Date.Today().Year();         
            ID CurrentUsersId = UserInfo.getUserId();
			List<Account_Trends__c> AllAccountTrendlst=new List<Account_Trends__c>();
	 AllAccountTrendlst=[SELECT Id, Name, Account__c,Account__r.Name,AccountExecutive__r.Name,AccountExecutive__c,PY_Total_Net_Actual_Revenue__c, Account_Health__c, OwnedByAccountExecutive__c, Total_Net_Actual_Revenue__c,Month_Value__c FROM Account_Trends__c Where AccountExecutive__r.Approving_Manager__r.ID = :CurrentUsersId AND Month_Value__c =:currentmonth AND Year__c =: currentyear];
		System.debug('AllAccountTrendlst'+AllAccountTrendlst);
return AllAccountTrendlst;
	} catch (Exception e) {
		Log4SF.logMessage('SponsorshipController','AllAEAccountTrend',e.getMessage(),e,UserInfo.getUserId(),'');

			throw new AuraHandledException(e.getMessage());
		}
	}
	

	@AuraEnabled
	public static void updateTemplateInventory(String recId,Decimal quantity ){
		try {
			List<Template_Inventory__c> listTemplateInventory = [Select id,Total_quantity__c,Template__r.RecordType.DeveloperName 
																FROM Template_Inventory__c 
																WHERE Template__c=:recId and Template__r.RecordType.DeveloperName='National'];

			if(listTemplateInventory.size()>0){
				listTemplateInventory[0].Total_quantity__c = quantity;
				update listTemplateInventory;
			}
		} catch (Exception e) {
			Log4SF.logMessage('SponsorshipController','updateTemplateInventory',e.getMessage(),e,UserInfo.getUserId(),'');

		// 	throw new AuraHandledException(e.getMessage());
		 }
	}
    
    
	@AuraEnabled
	public static List<Sponsorship_Booking__c> getExistingBookingDetailsForRenewal(String sponsorshipId, String OpportunityId){
		try {
			List<Sponsorship_Booking__c> existingSponsorshipBookings = new List<Sponsorship_Booking__c>();
			existingSponsorshipBookings = [SELECT Id,End_Date__c,Start_Date__c,Account__c,Name,Linear_Revenue__c From Sponsorship_Booking__c Where Template__c = : sponsorshipId AND Opportunity__c = : OpportunityId];
			return existingSponsorshipBookings;
		} catch (Exception e) {
			Log4SF.logMessage('SponsorshipController','getExistingBookingDetailsForRenewal',e.getMessage(),e,UserInfo.getUserId(),sponsorshipId);

			throw new AuraHandledException(e.getMessage());
		}
	}
}