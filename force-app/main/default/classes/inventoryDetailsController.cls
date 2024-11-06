global without sharing class inventoryDetailsController  {

@AuraEnabled
public static Sponsorship_Booking__c getBookingDetails(String bookingId){
	Sponsorship_Booking__c sb = new Sponsorship_Booking__c();
	sb = [Select id,Name,Start_Date__c,End_Date__c from Sponsorship_Booking__c WHERE Id = :bookingId LIMIT 1];
	return sb;


}
}