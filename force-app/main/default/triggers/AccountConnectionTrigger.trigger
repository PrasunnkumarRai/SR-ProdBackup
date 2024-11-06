/*
###########################################################################
# File..................: AccountConnectionTrigger.cls
# Version...............: 1
# Created by............: Ankit Bhatia   
# Created Date..........: 9-Sep-2017
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This trigger on Account Connection object after a record is inserted to check for duplicates.
# Change Log:               
#
#
############################################################################*/

trigger AccountConnectionTrigger on AccountConnection__c (after insert, before insert,before update) {
	// Added - 11/13/2017 
	if( String.isNotBlank( System.Label.isActiveAccountConnectionTrigger ) && System.Label.isActiveAccountConnectionTrigger == 'true' ){
		AccountConnectionTriggerHelper accObj = new AccountConnectionTriggerHelper();
		
		if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){
			accObj.beforeInsert(Trigger.new);
		}
		
		if(Trigger.isInsert && Trigger.isAfter){
			accObj.afterInsert(Trigger.new);
		}
	}
}