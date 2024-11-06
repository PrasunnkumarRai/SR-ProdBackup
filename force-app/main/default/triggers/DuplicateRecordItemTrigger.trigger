trigger DuplicateRecordItemTrigger on DuplicateRecordItem (before insert, before update) {
        Boolean isActive = Boolean.valueOf(Label.IsActiveDuplicateRecordItemTrigger);
         if (isActive) {
            DRITriggerHandler handler = new DRITriggerHandler(Trigger.isExecuting, Trigger.size);
            switch on Trigger.operationType {
                when BEFORE_INSERT {
                    handler.beforeInsert(Trigger.new);
                }
                when BEFORE_UPDATE {
                    handler.beforeUpdate(Trigger.new);
                }
            }
        }
        else {
        // Optionally log or perform other actions when the trigger is inactive
        System.debug('DuplicateRecordItemTrigger is currently deactivated.');
    }
}