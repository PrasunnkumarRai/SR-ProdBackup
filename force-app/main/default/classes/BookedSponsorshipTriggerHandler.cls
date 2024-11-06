/*
  ###########################################################################
  # File..................: BookedSponsorshipTriggerHandler.cls
  # Version...............: 1
  # Created by............: Ankit Bhatia
  # Created Date..........: 11 June 2021
  # Last Modified by......:
  # Last Modified Date....:
  # Description...........: This class is used to handle all BookedSponsorship Object Trigger events
  # TAO Ref#..............: NA
  # Test Class............: 
  # Change Log............:
  #
  #
  ############################################################################*/
  public class BookedSponsorshipTriggerHandler {


	public static void afterUpdate(Map<ID, Booked_Sponsorship__c> newItems, Map<ID, Booked_Sponsorship__c> oldItems)
	{
		
		//Function variable declarations
		// Use Map for updates to avoid Dulicate values
		Map<String, Sponsorship_Booking__c> mapBookedSpr= new Map<String, Sponsorship_Booking__c> ();

		List<ID> bookingDetailsIDList = new List<ID> ();
		bookingDetailsIDList.addAll(newItems.keySet());
        String sponsorshipBookingId = bookingDetailsIDList[0];
        Boolean sponsorshipRejected = false;
		Boolean sponsorshipApproved = false;
		List<Sponsorship_Booking__c> updateBookingsList = new List<Sponsorship_Booking__c> ();
		List<Sponsorship_Booking__c> deleteBookingsList = new List<Sponsorship_Booking__c> ();
		List<Sponsorship_Booking__c> deleteOrginalCancelledSponsorship = new List<Sponsorship_Booking__c> ();
		List<Date> oldBookingStartDates = new List<Date>();
		List<Date> oldBookingEndDates = new List<Date>();
		Map<String, Map<String, List<Sponsorship_Booking__c>>> mapBookingMasterChild = new Map<String, Map<String, List<Sponsorship_Booking__c>>> ();
		Map<String, Sponsorship_Booking__c> mapBookingTemplate = new Map<String, Sponsorship_Booking__c> ();
		List<Booked_Sponsorship_Inventory__c> bookedSponInventoryList = new List<Booked_Sponsorship_Inventory__c>();
		List<Booked_Sponsorship_Inventory__c> oldbookedSponInventoryList = new List<Booked_Sponsorship_Inventory__c>();

		//SOQL Queries
		List<recordtype> recordTypeName = [Select ID, name from recordtype where SobjectType = 'Sponsorship_Booking__c' and Name = 'Original'];
		List<Sponsorship_Booking__c> bookingDetailsList = [Select ID, name, RecordType.name, PPM1__c,PPM2__c,Sales_Director__c,Sales_Director_2__c,Start_Date__c, Quantity__c, End_Date__c,Syscode__c, (Select Id, Inventory_Type__c, Quantity__c from Booked_Sponsorship_Inventories__r), RecordTypeID, Booked_Sponsorship__c, Booked_Sponsorship__r.Record_Type__c, Template__c, Is_Sponsorship_Cancelled__c from Sponsorship_Booking__c where Booked_Sponsorship__c in :bookingDetailsIDList];
		System.debug('recordTypeName --- ' + recordTypeName);
		System.debug('bookingDetailsList ----' + bookingDetailsList);

		for (Sponsorship_Booking__c sb : bookingDetailsList)
		{
			// Map of Master Booking Record + Template + RecordType
			mapBookingTemplate.put(String.valueOf(sb.Booked_Sponsorship__c) + String.valueOf(sb.Template__c) + sb.recordType.Name, sb);
			System.debug('sb ----' + sb);
			if (!mapBookingMasterChild.containsKey(sb.Booked_Sponsorship__c))
			{
				mapBookingMasterChild.put(sb.Booked_Sponsorship__c, new Map<String, List<Sponsorship_Booking__c>> { sb.RecordType.Name => new List<Sponsorship_Booking__c> { sb } });
			}
			else
			{
				if (!mapBookingMasterChild.get(sb.Booked_Sponsorship__c).containsKey(sb.RecordType.name))
				{
					mapBookingMasterChild.get(sb.Booked_Sponsorship__c).put(sb.RecordType.name, new List<Sponsorship_Booking__c> { sb });
				}
				else
				{
					mapBookingMasterChild.get(sb.Booked_Sponsorship__c).get(sb.RecordType.name).add(sb);
				}
			}
		}
		for (Booked_Sponsorship__c sb : newItems.values())
		{
			// When Master is approved through the Approval Process
			if (newItems.get(sb.ID).Status__c == 'Approved' && newItems.get(sb.ID).Status__c != oldItems.get(sb.ID).Status__c)
			{
				// Get all child Records that were newly created/edited
				List<Sponsorship_Booking__c> updateBookings = mapBookingMasterChild.get(sb.ID).get('Updated');
				System.debug('in Approved ' + sb);
				// Get all Older child Records.
				List<Sponsorship_Booking__c> originalBookings = mapBookingMasterChild.get(sb.ID).containsKey('Original') ? mapBookingMasterChild.get(sb.ID).get('Original') : new List<Sponsorship_Booking__c> ();
				for(Sponsorship_Booking__c booking: originalBookings){
					Date newDate = booking.Start_Date__c;
					Date endDate = booking.End_Date__c;
					oldBookingStartDates.add(newDate);
					oldBookingEndDates.add(endDate);
				}
				if (originalBookings.size() == 0 && updateBookings.size() > 0)
				{
					System.debug('updateBookings.size()' + updateBookings.size());
					for (Sponsorship_Booking__c sbDet : updateBookings)
					{
						sbDet.RecordTypeID = recordTypeName[0].Id;
						updateBookingsList.add(sbDet);
						mapBookedSpr.put(sbDet.Id,sbDet);
						System.debug('in Approved  sbDet' + sbDet);
					}
				}
				else
				{
					for (Sponsorship_Booking__c sbDet : updateBookings)
					{
						String parentID = String.valueOf(sb.ID);
						String templateID = String.valueOf(sbDet.template__c);
						if (!sbDet.Is_Sponsorship_Cancelled__c)
						{
							if(sbDet.Booked_Sponsorship__r.Record_Type__c != 'National') sponsorshipApproved = true;
							if (mapBookingTemplate.containsKey(parentID + templateID + 'Original'))
							{
								mapBookingTemplate.get(parentID + templateID + 'Original').Start_Date__c = sbDet.Start_Date__c;
								mapBookingTemplate.get(parentID + templateID + 'Original').End_Date__c = sbDet.End_Date__c;
								if (sbDet.Booked_Sponsorship__r.Record_Type__c == 'National') {
									mapBookingTemplate.get(parentID + templateID + 'Original').Quantity__c = sbDet.Quantity__c;
									Booked_Sponsorship_Inventory__c bookedSponInventory = new Booked_Sponsorship_Inventory__c();
									Booked_Sponsorship_Inventory__c oldbookedSponInventory = new Booked_Sponsorship_Inventory__c();
									bookedSponInventory.Id = mapBookingTemplate.get(parentID + templateID + 'Original').Booked_Sponsorship_Inventories__r[0].Id;
									oldbookedSponInventory.Id = sbDet.Booked_Sponsorship_Inventories__r[0].Id;
									bookedSponInventory.Quantity__c = sbDet.Quantity__c;
									bookedSponInventoryList.add(bookedSponInventory);
									oldbookedSponInventoryList.add(oldbookedSponInventory);
									
								}
								else {
									System.debug('Local Template');
								}
								updateBookingsList.add(mapBookingTemplate.get(parentID + templateID + 'Original'));
								mapBookedSpr.put(mapBookingTemplate.get(parentID + templateID + 'Original').Id,mapBookingTemplate.get(parentID + templateID + 'Original'));
								deleteBookingsList.add(sbDet);
							}
							else
							{
								sbDet.RecordTypeID = recordTypeName[0].Id;
								updateBookingsList.add(sbDet);
								mapBookedSpr.put(sbDet.Id,sbdet);
							}
							System.debug('in Approved  sbDet --1' + sbDet);
							System.debug('updateBookingsList sbDet --1' + mapBookedSpr);

						}
						else
						{
							sponsorshipRejected = true;
							if (mapBookingTemplate.containsKey(parentID + templateID + 'Original'))
							{								
								 //deleteBookingsList.add(sbDet);
								 deleteOrginalCancelledSponsorship.add(mapBookingTemplate.get(parentID + templateID + 'Original'));
							}
						}
						//sbDet.RecordTypeID = recordTypeName[0].Id;
						//updateBookingsList.add(sbDet);
						//deleteBookingsList
						//SponsorshipController sc = new SponsorshipController();
						//sc.sendBookingEmail(updateBookingsList,false,sb.Id);
						System.debug('in Approved  sbDet--2' + sbDet);
					}
				}
			}
			else if (newItems.get(sb.ID).Status__c == 'Rejected' && newItems.get(sb.ID).Status__c != oldItems.get(sb.ID).Status__c)
			{
				List<Sponsorship_Booking__c> updateBookings = mapBookingMasterChild.get(sb.ID).get('Updated');
				for (Sponsorship_Booking__c sbDet : updateBookings)
				{
					String parentID = String.valueOf(sb.ID);
					String templateID = String.valueOf(sbDet.template__c);
					
					if (mapBookingTemplate.containsKey(parentID + templateID + 'Updated'))
					{
						if (sbDet.Booked_Sponsorship__r.Record_Type__c == 'National') {
                            Template_Inventory__c templateInventory = [Select Id, Name, Inventory_Type__c,Total_quantity__c,Booked_Inventory__c  from Template_Inventory__c where Template__c =: templateID LIMIT 1];
							Booked_Sponsorship_Inventory__c bookedSponInventory = new Booked_Sponsorship_Inventory__c();
							Booked_Sponsorship_Inventory__c oldbookedSponInventory = new Booked_Sponsorship_Inventory__c();
							bookedSponInventory.Id = mapBookingTemplate.get(parentID + templateID + 'Updated').Booked_Sponsorship_Inventories__r[0].Id;
							templateInventory.Booked_Inventory__c = templateInventory.Booked_Inventory__c  - sbDet.Quantity__c;
							update templateInventory;
							delete bookedSponInventory;
                            deleteBookingsList.add(sbDet);
						}
						else {
                            sponsorshipRejected = true;
							System.debug('Local Template');
						}
						//deleteBookingsList.add(sbDet);
						//deleteBookingsList.add(mapBookingTemplate.get(parentID+templateID+'Original'));
					}
				}
                
			}
		}
		
        if(sponsorshipRejected == true){
			if(deleteOrginalCancelledSponsorship.size() > 0 )
			delete deleteOrginalCancelledSponsorship;
            DateInventoryHandleRejectBatch inventoryRejectBatch = new DateInventoryHandleRejectBatch(sponsorshipBookingId);
	        Database.executeBatch(inventoryRejectBatch,1);
        }

		if(sponsorshipApproved == true){
            DateInventoryHandleUpdateBatch inventoryUpdateEditedSponsorship = new DateInventoryHandleUpdateBatch(bookingDetailsList,oldBookingStartDates,oldBookingEndDates);
            Database.executeBatch(inventoryUpdateEditedSponsorship,1);
        }
        
		if (mapBookedSpr.size() > 0)
		System.debug('update Booking List ' + mapBookedSpr);
		update mapBookedSpr.values();
		for(Id keys : newItems.keySet()){
			System.debug('newItems Status----------- ' + newItems.get(keys).Status__c);
		if(newItems.get(keys).Status__c == 'Approved'){
			SponsorshipController sc = new SponsorshipController();
			sc.sendBookingEmail(updateBookingsList,false,keys);	
		}
		}
		if (deleteBookingsList.size() > 0)	
		delete deleteBookingsList;
		if(bookedSponInventoryList.size() > 0)
		update bookedSponInventoryList;
		if(oldbookedSponInventoryList.size() > 0)
		delete oldbookedSponInventoryList;
	}

}