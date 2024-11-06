/*-------------------------------------------------------------------------------------------------
  Functionality......: Helper to the Batch class SponsorshipDateInventoryBatch.
  -------------------------------------------------------------------------------
  @author............: Ankit Bhatia
  @created...........: 3rd November 2021
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

public class SponsorshipDateInventoryUtility implements Iterable<Sponsorship_Date_Inventory__c>{

    public static List<Sponsorship_Date_Inventory__c> dateInventories = new List<Sponsorship_Date_Inventory__c>();
    public static List<Templates__c> childCreateTemplates = new List<Templates__c>();
    public static List<Templates__c> chidUpdateTemplates = new List<Templates__c>();
	public static List<Sponsorship_Date_Inventory__c> sponsorshipInventoryList = new List<Sponsorship_Date_Inventory__c>();
	public static Map<String,List<Sponsorship_Booking__c>> spr_bSD_bED_Map = new Map<String,List<Sponsorship_Booking__c>>();
	public static String bookedSponsorshipId;

    public SponsorshipDateInventoryUtility(List<Templates__c> sponsorshipsToUpdate){

        for(Templates__c sponsorship : sponsorshipsToUpdate){
		childCreateTemplates.add(sponsorship);
           /*
		    if(sponsorship.Date_Inventory_Change_Type__c == 'Create'){
                childCreateTemplates.add(sponsorship);
            }else if(sponsorship.Date_Inventory_Change_Type__c == 'Update'){
                chidUpdateTemplates.add(sponsorship);
            }
			*/
        }
        SponsorshipDateInventoryUtility.createDateInventories();
        iterator();
    }

    public SponsorshipDateInventoryUtility(List<Templates__c> sponsorshipsToUpdate,Map<String,List<Sponsorship_Booking__c>> mapSPR_bSD_bED){
        for(Templates__c sponsorship : sponsorshipsToUpdate){
            childCreateTemplates.add(sponsorship);
               
            }
            spr_bSD_bED_Map = mapSPR_bSD_bED;
            SponsorshipDateInventoryUtility.createDateInventories();
            iterator();
    }

	//Method to create date inventories
    public static void createDateInventories(){
		List<Sponsorship_Booking__c> bookingList = new List<Sponsorship_Booking__c>();
		// for(List<Sponsorship_Booking__c> bookings: spr_bSD_bED_Map.values()){
		// 	for(Sponsorship_Booking__c booking: bookings){
		// 		bookingList.add(booking);
		// 	}
		// }
        for(Templates__c spnsrship : childCreateTemplates){
			System.debug('spnsrship Size ' + spnsrship);
            Date sponsorshipSD = spnsrship.Start_Date__c;
            Date sponsorshipED = spnsrship.End_Date__c;
           // if(sponsorshipED > sponsorshipSD){
                Date loopDate = sponsorshipSD;
                while(loopDate != sponsorshipED){
                    Sponsorship_Date_Inventory__c dateInv = new Sponsorship_Date_Inventory__c();
					dateInv.Sponsorship__c = spnsrship.Id;
					dateInv.External_ID__c = spnsrship.Id + '-' + String.valueOf(loopDate); 
                    dateInv.Sponsorship_Inventory_Date__c = loopDate;
					dateInv.Booked_Quantity__c = 0;
					if(spr_bSD_bED_Map.size() > 0)
					{
						if(spr_bSD_bED_Map.containsKey(spnsrship.ID))
						{
								Integer count = 0;	
								for(Sponsorship_Booking__c booking: spr_bSD_bED_Map.get(spnsrship.ID)){
									System.debug('Count: '+count++);
									System.debug('Booking list '+ booking);
									if((booking.Start_Date__c <= loopDate && booking.End_Date__c >= loopDate) && booking.Template__c == spnsrship.ID){
										dateInv.Booked_Quantity__c ++;
										System.debug('dateInv:' +dateInv);
									}
								}
						}
					}
                    dateInventories.add(dateInv);
                    loopDate = loopDate.addDays(1);
                }
				System.debug('Record Size post while ' + dateInventories.size());
            //}
        }
		System.debug('Record Size ' + dateInventories.size());
    }


    public class CustomIterator implements Iterator<Sponsorship_Date_Inventory__c>{ 

        private List<Sponsorship_Date_Inventory__c> dateInventories;
        private Integer currentIndex;

        public CustomIterator(List<Sponsorship_Date_Inventory__c> dateInventories){
            this.dateInventories = dateInventories;
            this.currentIndex = 0;
        }

        public Boolean hasNext(){ 
            return currentIndex < dateInventories.size() - 1;
        }    

        public Sponsorship_Date_Inventory__c next(){
            if(hasNext()) {
                currentIndex++;
                return dateInventories[currentIndex];
            } else {
                throw new NoSuchElementException();
            }
        } 
    }

	public static void updateSprDateInventories(List<templates__c> sprList,List<Sponsorship_Date_Inventory__c> inventoryList)
	/*{
		List<String> sprIDList = new List<String>();

		for(Templates__c spnsrship : sprList){
			sprIDList.add(spnsrship.ID);
		}
		List<Sponsorship_Date_Inventory__c> sprDateInvList = [SELECT Id, Sponsorship__c, Sponsorship_Inventory_Date__c, Total_Quantity__c, Booked_Quantity__c, Available_Quantity__c FROM Sponsorship_Date_Inventory__c where Sponsorship__c in :sprIDList];
		for(Sponsorship_Date_Inventory__c sprDateInv : sprDateInvList)
		{
			if(mapSprDateInv.containsKey(sprDateInv.Sponsorship__c))
			{
				mapSprDateInv.get(sprDateInv.Sponsorship__c).add(sprDateInv);
			}
			else
				mapSprDateInv.put(sprDateInv.Sponsorship__c, new List<Sponsorship_Date_Inventory__c>{sprDateInv});
		}


		List<Sponsorship_Booking__c> bookSprList = [SELECT Id, End_Date__c, Start_Date__c, Quantity__c, Template__c FROM Sponsorship_Booking__c where Template__c in : sprIDList];
		for(Sponsorship_Booking__c bookSpr : bookSprList)
		{
			if(mapSprDateInv.containsKey(bookSpr.Template__c))
			{
				for(Sponsorship_Date_Inventory__c sprDateInv : mapSprDateInv.get(bookSpr.Template__c))
				{
					if(bookSpr.Start_Date__c <= sprDateInv.Sponsorship_Inventory_Date__c && bookSpr.End_Date__c >=  sprDateInv.Sponsorship_Inventory_Date__c )
					{
						sprDateInv.Booked_Quantity__c = sprDateInv.Booked_Quantity__c + 1;
						sprDateInvUpdateList.add(sprDateInv);

					}
				}
			}
		}

		if(sprDateInvUpdateList.size() > 0)
		 update sprDateInvUpdateList;
	}*/
	{

	}

	public void afterUpdateSponsorship(Map<Id,Templates__c> oldMap,Map<Id,Templates__c> newMap)
	{
		try{
			for(Templates__c spr: newMap.values())
			{
				if(newMap.get(spr.ID).Start_Date__c != oldMap.get(spr.ID).Start_Date__c  )
				 newMap.get(spr.ID);
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('SponsorshipDateInventoryUtility', 'afterUpdateSponsorship', ex.getMessage(),UserInfo.getUserId(),null);
		}
	}

    public Iterator<Sponsorship_Date_Inventory__c> iterator(){
        return new CustomIterator(dateInventories);
    }
}