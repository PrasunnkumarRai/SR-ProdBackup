trigger BookedSponsorship on Booked_Sponsorship__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)  {

 if(trigger.isUpdate && trigger.isAfter)
 {
     BookedSponsorshipTriggerHandler.afterUpdate(trigger.newMap,trigger.oldMap);
 }
 }