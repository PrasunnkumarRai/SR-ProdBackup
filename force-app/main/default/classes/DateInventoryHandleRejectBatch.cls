/*-------------------------------------------------------------------------------------------------
  Functionality......: Updates the Date Inventories with rejected Status and Sponsorships which are cancelled.
  -------------------------------------------------------------------------------
  @author............: Priya Singh
  @created...........: 1st December 2021
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
global class DateInventoryHandleRejectBatch implements Database.Batchable<sObject>{
	public String sponsorshipBookingId;
    public Date maxDate;
    public Date minDate;
 
    //Constructor to be called when Sponsorship is Rejected
    global DateInventoryHandleRejectBatch(String bookingId){
        sponsorshipBookingId = bookingId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String Query;
        String bookedSponsorshipQuery = 'Select Id, Status__c, Name from Booked_Sponsorship__c where Id = :sponsorshipBookingId  LIMIT 1';
        Booked_Sponsorship__c bookedResult = new Booked_Sponsorship__C();
        bookedResult = Database.Query(bookedSponsorshipQuery);
        
        //Query the Booking Sponsorships with Approved Status and contains Cancelled Sponsorships
        if(bookedResult.Status__c == 'Approved'){
            Query = 'Select Id, Name, Start_Date__c,End_date__c,Template__c,RecordType.Name from Sponsorship_Booking__c where Booked_Sponsorship__c = :sponsorshipBookingId AND Is_Sponsorship_Cancelled__c = true';
        }
        //Query the Booking Sponsorships with Rejected Status 
        else{
            Query = 'Select Id, Name, Start_Date__c,End_date__c,Template__c,RecordType.Name from Sponsorship_Booking__c where Booked_Sponsorship__c = :sponsorshipBookingId AND RecordType.Name = \'Updated\''; 
        }  
       return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext bc, List<Sponsorship_Booking__c> scope){
        System.debug('Sponsorship Booking '+ scope);
        List<Sponsorship_Booking__c> deleteUpdatedBookings = new List<Sponsorship_Booking__c>(); //List of Sponsorships which are either rejected or approved for cancellation.
        Map<String,Map<Date,Date>> mapSponsorshipBookingDetails = new Map<String,Map<Date,Date>>(); //map of sponsorships and booking startDate and endDate.
        List<Sponsorship_Date_Inventory__c> dateInventoriesToUpdate = new List<Sponsorship_Date_Inventory__c>(); //List of inventories which are selected for updation.
        
        //loop which will be iterating on the bookings to add the data on map and max date and min date from all the bookings.
        for(Sponsorship_Booking__c sb: scope){
            if(maxDate != null && maxDate < sb.Start_Date__c){
               maxDate = sb.Start_Date__c; 
            }
            if(minDate !=null && minDate > sb.End_Date__c){
               minDate = sb.End_Date__c;
            } 
                deleteUpdatedBookings.add(sb);
				mapSponsorshipBookingDetails.put(sb.Template__c,new Map<Date,Date>());
				mapSponsorshipBookingDetails.get(sb.Template__c).put(sb.Start_Date__c,sb.End_date__c);
		}
        
        //Inventory list of all the sponsorships which are in the middle of min date and max date.
        List<Sponsorship_Date_Inventory__c> dateInventoryList = [Select Id, Name,Booked_Quantity__c,Sponsorship_Inventory_Date__c,Sponsorship__c from Sponsorship_Date_Inventory__c where Sponsorship__c IN :mapSponsorshipBookingDetails.keySet() AND (Sponsorship_Inventory_Date__c < :maxDate AND Sponsorship_Inventory_Date__c > :minDate)];
        
        //loop to filter and store the inventories which needs to be updated.
        for(String sponsorshipIds: mapSponsorshipBookingDetails.keySet()){
                for(Sponsorship_Date_Inventory__c dateInventory: dateInventoryList){
                    if(dateInventory.Sponsorship__c == sponsorshipIds){
                         List<Date> startSponsorshipDates = new List<Date>(mapSponsorshipBookingDetails.get(sponsorshipIds).keyset());
                         if(startSponsorshipDates[0] <= dateInventory.Sponsorship_Inventory_Date__c && mapSponsorshipBookingDetails.get(sponsorshipIds).get(startSponsorshipDates[0])>= dateInventory.Sponsorship_Inventory_Date__c)
                         dateInventoriesToUpdate.add(dateInventory);
                    }
                }
            }
        for(Sponsorship_Date_Inventory__c sbDateInventory: dateInventoriesToUpdate){
            sbDateInventory.Booked_Quantity__c --;
        }
        System.debug('Rejected Data to be updated'  + dateInventoriesToUpdate.size());
        System.debug('Data to be deleted '+ deleteUpdatedBookings);
        update dateInventoriesToUpdate;
        if(deleteUpdatedBookings.size() > 0)
        delete deleteUpdatedBookings;
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
}