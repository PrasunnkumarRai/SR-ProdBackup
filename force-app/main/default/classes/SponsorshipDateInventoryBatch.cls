/*-------------------------------------------------------------------------------------------------
  functionality......: This is a batch class that will be used to create and update the Sponsorship Date inventories.
  -------------------------------------------------------------------------------
  @author............: Ankit Bhatia
  @created...........: 1st November 2021
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
global class SponsorshipDateInventoryBatch implements Database.Batchable<Sponsorship_Date_Inventory__c>, Database.Stateful{

	List<Templates__c> templatesToModify = new List<Templates__c>();
	List<Sponsorship_Date_Inventory__c> templateInventoriesToModify = new List<Sponsorship_Date_Inventory__c>();
	 Map<String,List<Sponsorship_Booking__c>> spr_bSD_bED_Map = new Map<String,List<Sponsorship_Booking__c>>();
	 public static boolean isEndDateChange;
	 public static date newEndDateForSponsorship;
	 public static integer newQuantity;
	 public static boolean isActive;


	 public boolean isE_DateChanged = false;
	 public date new_EndDateForSponsorship;
	 public integer new_Quantity;
	 public boolean is_Active;

	// Constructor to be called for Creating new Sponsorship Date Inventories.
	global SponsorshipDateInventoryBatch(List<Templates__c> templates){
		templatesToModify = templates;
	}

	global SponsorshipDateInventoryBatch(List<Templates__c> templates, boolean endDateChange, Date newEndDate, Boolean isActive, Integer newQuantity){
        templatesToModify = templates;
        // isEndDateChange = endDateChange; // Set the value of isEndDateChange here
		newEndDateForSponsorship = newEndDate;
		is_Active = isActive;
		if(isEndDateChange){
			isE_DateChanged = true;
		}
		
		if(newEndDateForSponsorship!=null){
			new_EndDateForSponsorship = newEndDateForSponsorship;
		}
	
		if(newQuantity != null){
			new_Quantity = newQuantity;
		}
		system.debug('isEndDateChange - '+isEndDateChange);
		System.debug('newEndDateForSponsorship - '+newEndDateForSponsorship);
		System.debug('is_Active - '+is_Active);
    }

	global SponsorshipDateInventoryBatch(List<Templates__c> templates,Map<String,List<Sponsorship_Booking__c>> mapSPR_bSD_bED){
		System.debug('map values in constructor '+ mapSPR_bSD_bED);
		spr_bSD_bED_Map = mapSPR_bSD_bED;
		templatesToModify = templates;
	}

	/**
	 * @description gets invoked when the batch job starts
	 * @param context contains the job ID
	 * @returns the record set as a QueryLocator object that will be batched for execution
	 */ 
	global Iterable<Sponsorship_Date_Inventory__c> start(Database.BatchableContext context){
		if(spr_bSD_bED_Map.size() > 0){
			return new SponsorshipDateInventoryUtility(templatesToModify,spr_bSD_bED_Map);
		}
		else{
			return new SponsorshipDateInventoryUtility(templatesToModify);
		}
	}

	/**
	 * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
	 * @param context contains the job ID
	 * @param scope contains the batch of records to process.
	 */ 
   	global void execute(Database.BatchableContext context, List<Sponsorship_Date_Inventory__c> scope) {
		Schema.SObjectField externalId = Sponsorship_Date_Inventory__c.Fields.External_ID__c;
		Database.Upsert(scope,externalId,false);
	}
	
	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */ 
	global void finish(Database.BatchableContext context) {
		if(isE_DateChanged)
		{
			Templates__c sponsorship = [Select Id,End_Date__c,Active__c,Total_Quantity__c From Templates__c Where Id =: templatesToModify[0].Id];
			sponsorship.End_Date__c = new_EndDateForSponsorship;
			sponsorship.Total_Quantity__c = new_Quantity;
			sponsorship.Active__c = is_Active;
			update sponsorship;
		}
	// }
}
}