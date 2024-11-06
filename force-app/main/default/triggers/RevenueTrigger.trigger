/*###########################################################################
# File..................: RevenueTrigger.apxt
# Version...............: 1
# Created by............: Sanchit Singhal   
# Created Date..........: 29-May-2017
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: Revenue Trigger
# TAO Ref#..............: 
# Change Log:               
#
#
############################################################################*/
trigger RevenueTrigger on Revenue__c (after insert, before insert, before update) {
  
	if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
		RevenueHelper.updateUserAccountinRevenue(Trigger.new,Trigger.oldMap);  
	}
	
	if(Trigger.isAfter && Trigger.isInsert){
		/*Uncomment if Revenue needs to be linked with Proposals
		Set<Id> setAccId =  new Set<Id> ();
	    Set<Id> setRevenueId = new Set<Id> ();
	    
	    for (Revenue__c rev: Trigger.new) {
	       setAccID.add(rev.Advertiser__c);
	       setRevenueId.add(rev.Id);
	    }
	    if(setAccID.size() > 0) {
	        RevenueHelper.updateProposalinRevenue(setAccID,setRevenueId);
	    }*/
	}
	
}