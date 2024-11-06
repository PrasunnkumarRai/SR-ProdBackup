/*###########################################################################
# File..................: TrafficIDTrigger.apxt
# Version...............: 1
# Created by............: Ankit Bhatia   
# Created Date..........: 10-Oct-2017
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: Traffic_Id_Element__c Trigger
# TAO Ref#..............: 
# Change Log:               
#
#
############################################################################*/
trigger TrafficIDTrigger on Traffic_Id_Element__c (before insert,before update) {
  
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        TrafficIDTriggerHelper.updateUserRecords(Trigger.new);  
    }
}