/*
###########################################################################
# File..................: ProposalNewSync.tgr
# Version...............: 1
# Created by............: Sanchit Singhal   
# Created Date..........: 06-February-2018
# Last Modified by......: Sanchit Singhal
# Last Modified Date....:  
# Description...........: This trigger contains DML handlers for ProposalNewSync
# TAO Ref#..............: NA
# Test Class............: ProposalNewSyncTriggerHandlerTest
# Change Log............:               
#
#
############################################################################*/
trigger ProposalNewSync on ProposalNewSync__c (before insert, before update) {
 
 ProposalNewSyncTriggerHandler handler = new ProposalNewSyncTriggerHandler(Trigger.isExecuting, Trigger.size);
 
 //Before Insert handling
 if(Trigger.isInsert && Trigger.isBefore){
 	handler.OnBeforeInsert(Trigger.new);
 }
 
 //Before Update handling
 else if(Trigger.isUpdate && Trigger.isBefore){
    handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
 }
	   
}