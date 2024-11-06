/*
###########################################################################
# File..................: Event.trigger
# Version...............: 1
# Created by............: Usharani   
# Created Date..........: 21-Sep-2023
# Description...........: To prevent Event creation for Out of Business accounts
# Test Class............: 
# Change Log............:               
#     Date           User       Requested By(Optional)   Description
# 21-Sep-2023     Usharani         Luke                  SRSF-4428 
############################################################################*/
trigger EventTrg on Event (before insert) {
    if(Trigger.isInsert && Trigger.isBefore){
        EventTriggerHandler.OnBeforeInsert(trigger.new);
    }
}