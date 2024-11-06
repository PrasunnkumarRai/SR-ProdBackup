/*
    Customer/Project:   Spectrum Reach 
    Author/Date:        Madhu    Feb 12-2020
    Purpose:            SRSF-2008 : Lead - First Activity Field Creation
    Modified:           
    
#   Change Log............:               
#   Date           User       Requested By(Optional)   Description
#   28-Dec-2021    Usharani     Luke                    SRSF-3441 
*/
trigger TaskTrg on Task (before insert, before update, after insert, after update, after delete) {
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            // Handle logic before Task insert
            TaskTriggerHandler.OnBeforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            // Handle logic before Task update (e.g., updating Sales Office and Region)
            TaskTriggerHandler.OnTaskUpdate(Trigger.new);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            // Handle logic after Task insert (e.g., sending emails and notifications)
            TaskTriggerHandler.OnAfterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            // Handle logic after Task update (e.g., reassignment and completion notifications)
            TaskTriggerHandler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete) {
            // Handle logic after Task delete (e.g., updating Lead's First Activity Field)
            TaskTriggerHandler.OnAfterDelete(Trigger.old);
        }
    }
}