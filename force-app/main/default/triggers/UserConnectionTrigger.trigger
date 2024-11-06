/*
###########################################################################
# File..................: UserConnectionTrigger.cls
# Version...............: 1
# Created by............: Ankit Bhatia   
# Created Date..........: 1-June-2017
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This trigger on User Connection object whenever a record is inserted.
# Change Log:               
#
#
############################################################################*/

trigger UserConnectionTrigger on UserConnection__c (before insert) {
    UserConnectionTriggerHelper userObj = new UserConnectionTriggerHelper();
     if(Trigger.isInsert && Trigger.isBefore){
        userObj.getUserConnection(Trigger.new);
      }
}