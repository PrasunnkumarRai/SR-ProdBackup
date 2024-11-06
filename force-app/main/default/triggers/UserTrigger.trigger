/*###########################################################################
# File..................: UserTrigger.apxt
# Version...............: 1
# Created by............: Sanchit Singhal   
# Created Date..........: 26-Feb-2018
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: User Trigger
# TAO Ref#..............: 
# Change Log:               
#
#
############################################################################*/
trigger UserTrigger on User (after insert, after update, before update) {
	
	if( String.isNotBlank( System.Label.isActiveUserTrigger ) && System.Label.isActiveUserTrigger == 'true' ){
		UserTriggerHandler handler = new UserTriggerHandler(Trigger.isExecuting, Trigger.size);
		
		if(Trigger.isAfter && Trigger.isInsert){
			handler.OnAfterInsert(Trigger.new);			
		}
		
		if(Trigger.isAfter && Trigger.isUpdate){
			handler.OnAfterUpdate(Trigger.old,Trigger.new,Trigger.oldMap);			
		}

		if(Trigger.isBefore && Trigger.isInsert){
			handler.OnBeforeInsert(Trigger.new);			
		}
		
		if(Trigger.isBefore && Trigger.isUpdate){
			handler.OnBeforeUpdate(Trigger.old,Trigger.new,Trigger.oldMap);			
		}
		
		// if(Trigger.isAfter && Trigger.isUpdate){
		// 	UserTriggerHandler.updateIsFrozen(Trigger.new);
		// }
	}
	
}