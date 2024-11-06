/*-----------------------------------------------------------------------------------------------------------------------------
  Functionality......: Updates the Date Inventories when Booking is created for Sponsorship.
                       Updates the Date Inventory when User has edited the existing Booked Sponsorship and it is approved.
  -----------------------------------------------------------------------------------------------------------------------------
  @author............: Priya Singh
  @created...........: 7th December 2021
  @version...........: 1.0
  -----------------------------------------------------------------------------------------------------------------------------
  @author............: 
  @changes...........: 
  vX.X
  YYYY-MM-DD
 
  vX.X 
  YYYY-MM-DD
  ------------------------------------------------------------------------------------------------------------------------------
*/

global class DateInventoryHandleUpdateBatch implements Database.Batchable<sObject>{
    public String sponsorshipBookingId;
    public Date maxDate;
    public Date minDate;
    public List<Sponsorship_Booking__c> SponsorshipBookingList;
    public List<Date> oldBookingStartDates;
    public List<Date> oldBookingEndDates;
    public Set<String> failedIds = new Set<String>();
    public String query;

    //Constructor to be called when inventory need to be updated
    global DateInventoryHandleUpdateBatch(String bookingId, List<Sponsorship_Booking__c> bookingList) { 
        sponsorshipBookingId = bookingId;
        SponsorshipBookingList = bookingList;
    }

    global DateInventoryHandleUpdateBatch(String query, List<Sponsorship_Booking__c> SponsorshipBookingList, String Source){
        this.SponsorshipBookingList = SponsorshipBookingList;
        this.query = query;
    }

    global DateInventoryHandleUpdateBatch( List<Sponsorship_Booking__c> SponsorshipBookingList, List<Date> oldBookingStartDates,List<Date> oldBookingEndDates){
        this.SponsorshipBookingList = SponsorshipBookingList;
        this.oldBookingStartDates = oldBookingStartDates;
        this.oldBookingEndDates = oldBookingEndDates;
    }
    
    global List<Sponsorship_Booking__c> start(Database.BatchableContext bc){
        List<Sponsorship_Booking__c> sponsorshipBookingUpdateList = new List<Sponsorship_Booking__c>();

        if (String.isNotBlank(this.query) || String.isNotEmpty(this.query)){
            sponsorshipBookingUpdateList =   Database.query(this.query);
        }
        else if(SponsorshipBookingList == null){
            //enters in this clause when user is booking the Sponsorship.
            sponsorshipBookingUpdateList = [Select Id,Name,Start_Date__c,End_date__c,Template__c,RecordType.Name from Sponsorship_Booking__c where Booked_Sponsorship__c = :sponsorshipBookingId];
        }
        else{ 
            //enters else clause when Booking is edited and approved.
            sponsorshipBookingUpdateList = SponsorshipBookingList;
        }
        return sponsorshipBookingUpdateList;
    }
    
    global void execute(Database.BatchableContext bc, List<Sponsorship_Booking__c> scope){
        System.debug('Sponsorship Bookings '+ scope);

        List<Sponsorship_Date_Inventory__c> dateInventoriesToUpdate = new List<Sponsorship_Date_Inventory__c>();
        Map<String,Map<Date,Date>> mapSponsorshipBookingDetails = new Map<String,Map<Date,Date>>(); //map of sponsorships and booking startDate and endDate.
        //When user creates a booking, then this method updates the inventory Booking Quantity
        if(SponsorshipBookingList == null && sponsorshipBookingId != null){
            System.debug('@@@@Inside If');
            //loop to put the template and its related booking in a map.
            for(Sponsorship_Booking__c sb: scope){
                if(maxDate != null && maxDate < sb.Start_Date__c){
                   maxDate = sb.Start_Date__c; 
                }
                if(minDate !=null && minDate > sb.End_Date__c){
                   minDate = sb.End_Date__c;
                } 
                   mapSponsorshipBookingDetails.put(sb.Template__c,new Map<Date,Date>());
                   mapSponsorshipBookingDetails.get(sb.Template__c).put(sb.Start_Date__c,sb.End_date__c);
            }

             //This query gets the date inventory records on of the tmplates stored in map, on the basis of min and max dates of Sponsorship Booking.
            List<Sponsorship_Date_Inventory__c> dateInventoryList = [Select Id, Name,Booked_Quantity__c,Sponsorship_Inventory_Date__c,Sponsorship__c from Sponsorship_Date_Inventory__c where Sponsorship__c IN :mapSponsorshipBookingDetails.keySet() AND (Sponsorship_Inventory_Date__c < :maxDate AND Sponsorship_Inventory_Date__c > :minDate)];
            
            //loop to get the exact date inventories for which updation needs to be done and store it in a list.
            for(String sponsorshipIds: mapSponsorshipBookingDetails.keySet()){
                for(Sponsorship_Date_Inventory__c dateInventory: dateInventoryList){
                    if(dateInventory.Sponsorship__c == sponsorshipIds){
                         List<Date> startSponsorshipDates = new List<Date>(mapSponsorshipBookingDetails.get(sponsorshipIds).keyset());
                         if(startSponsorshipDates[0] <= dateInventory.Sponsorship_Inventory_Date__c && mapSponsorshipBookingDetails.get(sponsorshipIds).get(startSponsorshipDates[0])>= dateInventory.Sponsorship_Inventory_Date__c)
                         dateInventoriesToUpdate.add(dateInventory);
                    }
                }
            }

            //loop to update the Booked Quantity.
            for(Sponsorship_Date_Inventory__c sbDateInventory: dateInventoriesToUpdate){
            sbDateInventory.Booked_Quantity__c ++;
            }

         }
         //When user edits the existing booking and make changes, then this method updates the Booking Quantity.
         else if(oldBookingStartDates != null && oldBookingEndDates != null){
            System.debug('@@@@Inside else');
            Map<String,List<Sponsorship_Booking__c>> mapBookingDetailsToUpdate = new Map<String,List<Sponsorship_Booking__c>>(); //map stores the sponsorship and sponsorship booking related to it
                List<String> idsOfSponsorships = new List<String>();
                for(Sponsorship_Booking__c sb: scope){
                    idsOfSponsorships.add(sb.Template__c);
                }

                //Query to get all the bookings for each Sponsorship.
                List<Templates__c> templateWithBookingList = [Select Id,name,(Select Id,Name,Start_Date__c,End_date__c,Template__c,RecordType.Name from Sponsorship_Bookings__r) from Templates__c where Id IN :idsOfSponsorships];
                
                //loop to put the template and its related booking in a map.
                for(Templates__c templatesToModify: templateWithBookingList){
                    for(Sponsorship_Booking__c sb: templatesToModify.Sponsorship_Bookings__r){
                        if(minDate == null || minDate > sb.Start_Date__c){
                            minDate = sb.Start_Date__c; 
                        }
                        if(maxDate == null || maxDate < sb.End_Date__c){
                            maxDate = sb.End_Date__c;
                        }
                        if(mapBookingDetailsToUpdate.containsKey(sb.Template__c)){
                            List<Sponsorship_Booking__c> bookings = mapBookingDetailsToUpdate.get(sb.Template__c);
                            bookings.add(sb);
                            mapBookingDetailsToUpdate.put(sb.Template__c,bookings);
                        }
                        else{
                            List<Sponsorship_Booking__c> bookings = new List<Sponsorship_Booking__c>();
                            bookings.add(sb);
                            mapBookingDetailsToUpdate.put(sb.Template__c,bookings);
                        }
                    }
                }


                for(Date endDate: oldBookingEndDates){
                    if(maxDate < endDate){
                        maxDate = endDate;
                    }
                }
                for(Date startDate: oldBookingStartDates){
                    if(minDate > startDate){
                        minDate = startDate;
                    }
                }

                //This query gets the date inventory records on of the tmplates stored in map, on the basis of min and max dates of Sponsorship Booking.
                List<Sponsorship_Date_Inventory__c> dateInventoryList = [Select Id, Name,Booked_Quantity__c,Sponsorship_Inventory_Date__c,Sponsorship__c,Available_Quantity__c from Sponsorship_Date_Inventory__c where Sponsorship__c IN :mapBookingDetailsToUpdate.keySet() AND (Sponsorship_Inventory_Date__c <= :maxDate AND Sponsorship_Inventory_Date__c >= :minDate)];
                //List<Sponsorship_Date_Inventory__c> dateInventoryList = [Select Id, Name,Booked_Quantity__c,Sponsorship_Inventory_Date__c,Sponsorship__c,Available_Quantity__c from Sponsorship_Date_Inventory__c where Sponsorship__c IN :mapBookingDetailsToUpdate.keySet()];
                List<Sponsorship_Date_Inventory__c> tobeUpdated = new List<Sponsorship_Date_Inventory__c>();
                List<Sponsorship_Date_Inventory__c> ToBeUpdatedWithZero = new List<Sponsorship_Date_Inventory__c>();

                 //loop to get the exact date inventories for which updation needs to be done.
                 //This code first updates all the booked quantity to 0 and store it in tobeUpdated List. 
                for(List<Sponsorship_Booking__c> bookings: mapBookingDetailsToUpdate.values()){
                    for(Sponsorship_Booking__c bookingData: bookings){
                        for(Sponsorship_Date_Inventory__c dateInventory: dateInventoryList){
                            dateInventory.Booked_Quantity__c = 0;
                            if((dateInventory.Sponsorship__c == bookingData.Template__c) && (bookingData.Start_Date__c <= dateInventory.Sponsorship_Inventory_Date__c && bookingData.End_Date__c >= dateInventory.Sponsorship_Inventory_Date__c)){
                                //dateInventory.Booked_Quantity__c = 0;
                                tobeUpdated.add(dateInventory);
                            }
                            else{
                                ToBeUpdatedWithZero.add(dateInventory);
                            }
                        }
                    }   
                }
                System.debug('updated date Inventory: '+ tobeUpdated.size());
                System.debug('ToBeUpdatedWithZero: '+ ToBeUpdatedWithZero.size());
                Map<Sponsorship_Date_Inventory__c,Decimal> updatedSponsorshipDateInventories = new  Map<Sponsorship_Date_Inventory__c,Decimal>();

                //loop to increment the booked Quantity of date inventory as per the bookings exists for each Sponsorship and store it in value of map.
                for(Sponsorship_Date_Inventory__c dateInvntory: tobeUpdated){
                    if(updatedSponsorshipDateInventories.containsKey(dateInvntory)){
                        Decimal bookedQuantity = updatedSponsorshipDateInventories.get(dateInvntory) + 1;
                        updatedSponsorshipDateInventories.put(dateInvntory,bookedQuantity);
                    }
                    else{
                        updatedSponsorshipDateInventories.put(dateInvntory,1);
                    }    
                }

                for(Sponsorship_Date_Inventory__c dateInvntory: ToBeUpdatedWithZero){
                    if(updatedSponsorshipDateInventories.containsKey(dateInvntory)){
                        System.debug('Quantity already updated');
                    }else{
                        updatedSponsorshipDateInventories.put(dateInvntory,0);
                        System.debug('Zero date Inventory: '+ dateInvntory);
                    }
                       
                }

                List<Sponsorship_Date_Inventory__c> spdateInventory = new List<Sponsorship_Date_Inventory__c>(updatedSponsorshipDateInventories.keySet());

                    //loop which updates the booked quantity of date inventory as per the value stored in a map.
                    for(Sponsorship_Date_Inventory__c finalUpdatedList : spdateInventory){
                        if(updatedSponsorshipDateInventories.containsKey(finalUpdatedList))
                        finalUpdatedList.Booked_Quantity__c = updatedSponsorshipDateInventories.get(finalUpdatedList);
                        dateInventoriesToUpdate.add(finalUpdatedList);
                    }
         }
         else{
            System.debug('@@@@Inside else');
            Map<String,List<Sponsorship_Booking__c>> mapBookingDetailsToUpdate = new Map<String,List<Sponsorship_Booking__c>>(); //map stores the sponsorship and sponsorship booking related to it
                List<String> idsOfSponsorships = new List<String>();
                for(Sponsorship_Booking__c sb: scope){
                    idsOfSponsorships.add(sb.Template__c);
                }

                //Query to get all the bookings for each Sponsorship.
                List<Templates__c> templateWithBookingList = [Select Id,name,(Select Id,Name,Start_Date__c,End_date__c,Template__c,RecordType.Name from Sponsorship_Bookings__r) from Templates__c where Id IN :idsOfSponsorships];
                
                //loop to put the template and its related booking in a map.
                for(Templates__c templatesToModify: templateWithBookingList){
                    for(Sponsorship_Booking__c sb: templatesToModify.Sponsorship_Bookings__r){
                        if(maxDate != null && maxDate < sb.Start_Date__c){
                            maxDate = sb.Start_Date__c; 
                        }
                        if(minDate !=null && minDate > sb.End_Date__c){
                            minDate = sb.End_Date__c;
                        }
                        if(mapBookingDetailsToUpdate.containsKey(sb.Template__c)){
                            List<Sponsorship_Booking__c> bookings = mapBookingDetailsToUpdate.get(sb.Template__c);
                            bookings.add(sb);
                            mapBookingDetailsToUpdate.put(sb.Template__c,bookings);
                        }
                        else{
                            List<Sponsorship_Booking__c> bookings = new List<Sponsorship_Booking__c>();
                            bookings.add(sb);
                            mapBookingDetailsToUpdate.put(sb.Template__c,bookings);
                        }
                    }
                }
                //This query gets the date inventory records on of the tmplates stored in map, on the basis of min and max dates of Sponsorship Booking.
                //List<Sponsorship_Date_Inventory__c> dateInventoryList = [Select Id, Name,Booked_Quantity__c,Sponsorship_Inventory_Date__c,Sponsorship__c,Available_Quantity__c from Sponsorship_Date_Inventory__c where Sponsorship__c IN :mapBookingDetailsToUpdate.keySet() AND (Sponsorship_Inventory_Date__c < :maxDate AND Sponsorship_Inventory_Date__c > :minDate)];
                List<Sponsorship_Date_Inventory__c> dateInventoryList = [Select Id, Name,Booked_Quantity__c,Sponsorship_Inventory_Date__c,Sponsorship__c,Available_Quantity__c from Sponsorship_Date_Inventory__c where Sponsorship__c IN :mapBookingDetailsToUpdate.keySet()];
                List<Sponsorship_Date_Inventory__c> tobeUpdated = new List<Sponsorship_Date_Inventory__c>();
                
                 //loop to get the exact date inventories for which updation needs to be done.
                 //This code first updates all the booked quantity to 0 and store it in tobeUpdated List. 
                for(List<Sponsorship_Booking__c> bookings: mapBookingDetailsToUpdate.values()){
                    for(Sponsorship_Booking__c bookingData: bookings){
                        for(Sponsorship_Date_Inventory__c dateInventory: dateInventoryList){
                            if((dateInventory.Sponsorship__c == bookingData.Template__c) && (bookingData.Start_Date__c <= dateInventory.Sponsorship_Inventory_Date__c && bookingData.End_Date__c >= dateInventory.Sponsorship_Inventory_Date__c)){
                                System.debug('@@dateInventory '+ dateInventory);
                                dateInventory.Booked_Quantity__c = 0;
                                System.debug('@@dateInventory after '+ dateInventory);
                                tobeUpdated.add(dateInventory);
                            }
                        }
                    }   
                }

                Map<Sponsorship_Date_Inventory__c,Decimal> updatedSponsorshipDateInventories = new  Map<Sponsorship_Date_Inventory__c,Decimal>();

                //loop to increment the booked Quantity of date inventory as per the bookings exists for each Sponsorship and store it in value of map.
                for(Sponsorship_Date_Inventory__c dateInvntory: tobeUpdated){
                    if(updatedSponsorshipDateInventories.containsKey(dateInvntory)){
                        Decimal bookedQuantity = updatedSponsorshipDateInventories.get(dateInvntory) + 1;
                        updatedSponsorshipDateInventories.put(dateInvntory,bookedQuantity);
                    }
                    else{
                        updatedSponsorshipDateInventories.put(dateInvntory,1);
                    }    
                }

                List<Sponsorship_Date_Inventory__c> spdateInventory = new List<Sponsorship_Date_Inventory__c>(updatedSponsorshipDateInventories.keySet());

                    //loop which updates the booked quantity of date inventory as per the value stored in a map.
                    for(Sponsorship_Date_Inventory__c finalUpdatedList : spdateInventory){
                        if(updatedSponsorshipDateInventories.containsKey(finalUpdatedList))
                        finalUpdatedList.Booked_Quantity__c = updatedSponsorshipDateInventories.get(finalUpdatedList);
                        dateInventoriesToUpdate.add(finalUpdatedList);
                    }
         }
         System.debug('Final List to be updated: '+ dateInventoriesToUpdate);
         Database.SaveResult[] updatedInventories = Database.update(dateInventoriesToUpdate, false);
         for(Database.SaveResult results : updatedInventories){
             if(!results.isSuccess())
             failedIds.add(results.getId());
         }

         if(failedIds != null){
            List<Sponsorship_Date_Inventory__c> sponsorshipErroredInventories = [Select Id,Name,Is_Error__c	from Sponsorship_Date_Inventory__c where Id IN :failedIds];
            for(Sponsorship_Date_Inventory__c inventories: sponsorshipErroredInventories){
                inventories.Is_Error__c	 = true;
                update inventories;
            }
        }
         
    }

    global void finish(Database.BatchableContext bc) {
        
    }
}