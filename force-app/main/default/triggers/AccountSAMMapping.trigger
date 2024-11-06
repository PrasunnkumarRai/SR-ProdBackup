trigger AccountSAMMapping on Account_SAM_Mapping__c(after delete, after insert, after undelete,
after update, before delete, before insert, before update) { 
    AccountSAMMappingTriggerHandler handler = new AccountSAMMappingTriggerHandler();
    if(System.isFuture()) {
        return;
    }
    if(Trigger.isInsert && Trigger.isBefore){
    	handler.OnBeforeInsert(Trigger.new);
  	}
    else if(Trigger.isUpdate && Trigger.isBefore){
    	handler.OnBeforeUpdate(Trigger.new);
 	 }
        
}