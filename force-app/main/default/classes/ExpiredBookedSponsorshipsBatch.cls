global class ExpiredBookedSponsorshipsBatch implements Database.Batchable<SObject>{

	public String query;
	//public List<Sponsorship_Booking__c> sbList;
	//public Map<Id,Sponsorship_Booking__c> sbMap;
	//public List<Template_Inventory__c> tiList;

	/**
	* Batch Class Constructor
	* Not in use right now, leaving the blank body for any future use
	**/
	global ExpiredBookedSponsorshipsBatch() {		
	}

	/**
	 * @description gets invoked when the batch job starts
	 * @param context contains the job ID
	 * @returns the record set as a QueryLocator object that will be batched for execution
	 */
	global Database.QueryLocator start(Database.BatchableContext context) {

		query = 'Select id,quantity__c,Inventory_Released__c,Template__c From Sponsorship_Booking__c Where Inventory_Released__c = false and quantity__c !=null and End_Date__c<Today And Template__r.RecordType.Name = \'National\'';

		system.Debug('ExpiredBookedSponsorshipsBatch:getQueryLocator: ' + query);
		return Database.getQueryLocator(query);
	}


	/**
	 * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
	 * @param context contains the job ID
	 * @param scope contains the batch of records to process.
	 */
	global void execute(Database.BatchableContext context, List<Sponsorship_Booking__c> scope) {

		//Loop through the batch job and convert the scope list to map for easy lookups
		System.debug('@@@scope: '+ scope);
		Map<Id,Sponsorship_Booking__c> sbMap = new Map<Id,Sponsorship_Booking__c>();
		Map<Id,Decimal> bookedQuantityMap = new Map<Id,Decimal>();
		List<Sponsorship_Booking__c> sbList = new List<Sponsorship_Booking__c>();
		List<Template_Inventory__c> tiList = new List<Template_Inventory__c>();
		for (Sponsorship_Booking__c sb : scope) {	
			System.debug('Booking Id: '+ sb.id);		
			sbMap.put(sb.Template__c, sb);
			If(bookedQuantityMap.containsKey(sb.Template__c)) 
			bookedQuantityMap.put(sb.Template__c,bookedQuantityMap.get(sb.Template__c)+sb.quantity__c);
			else
			bookedQuantityMap.put(sb.Template__c,sb.quantity__c);
		}
		system.Debug('ExpiredBookedSponsorshipsBatch:scope.size: ' + scope.size());		
		
		//Loop through the related Template_Inventory records to add the quantity back from the expired bookings
		for(Template_Inventory__c ti:[Select id,Template__c,Quantity__c,Booked_Inventory__c From Template_Inventory__c Where Template__c in:bookedQuantityMap.keySet()]){
			System.debug('@@@ti: '+ ti);
			ti.Booked_Inventory__c = ti.Booked_Inventory__c - bookedQuantityMap.get(ti.Template__c);		
			tiList.add(ti);
			// Sponsorship_Booking__c sb = new Sponsorship_Booking__c(Id=ti.Template__c,Inventory_Released__c=true);
			// sbList.add(sb);
		}

		//Update the Template_Inventory records to persist the quanity additions
		if(tiList.size()>0){
			system.Debug('ExpiredBookedSponsorshipsBatch:tiList.size: ' + tiList.size());
			update tiList;
			
		}

		//Once Inventory is updated as per the booking, update the Inventory Release Boolean field to true, which represents if Inventory is update or not.
		for(Sponsorship_Booking__c booking: scope){
			Sponsorship_Booking__c sb = new Sponsorship_Booking__c(Id=booking.Id,Inventory_Released__c=true);
		     sbList.add(sb);
		}

		//Update the Sponsorship_Booking records to persist the inventory release flag changes
		if(sbList != null && sbList.size()>0){
			update sbList;
			system.Debug('ExpiredBookedSponsorshipsBatch:sbList.size: ' + tiList.size());
		}		
	}

	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */
	global void finish(Database.BatchableContext context) { 
		system.Debug('ExpiredBookedSponsorshipsBatch:finish(): ' + context.getJobId());		
		Log4SF.logMessage('ExpiredBookedSponsorshipsBatch', 'finish', '', UserInfo.getUserId(), context.getJobId());		
	}
}