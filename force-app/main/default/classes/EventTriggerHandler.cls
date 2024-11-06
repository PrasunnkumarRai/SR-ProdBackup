/*
###########################################################################
# File..................: EventTriggerHandler.cls
# Version...............: 1
# Created by............: Usharani   
# Created Date..........: 21-Sep-2023
# Description...........: To prevent Event creation for Out of Business accounts
# Test Class............: 
# Change Log............:               
#     Date           User       Requested By(Optional)   Description
# 21-Sep-2023     Usharani         Luke                  SRSF-4428 
############################################################################*/
public class EventTriggerHandler 
{
    public static void OnBeforeInsert(Event[] newEvents)
    {
        Set<Id> accIds = new Set<Id>();
        for(Event objEvent : newEvents)
        {
            Id accountId = objEvent.WhatId;
            if (accountId != NULL && String.valueof(accountId.getSobjectType()) == 'Account'){
                accIds.add(accountId); 
            }                    
        }
        if(accIds.size() > 0)
        {        
           Map<Id,Account> mapAccs= new Map<Id,Account>([SELECT Id FROM Account WHERE Id IN :accIds AND Out_of_Business__c=TRUE]);
            if(mapAccs.size()>0){
                for(Event objEvent : newEvents)
                {
                    if(mapAccs.containsKey(objEvent.WhatId)){
                        String errMesg = String.format(System.Label.Prevent_Activity_creation_on_Out_Of_Business_Accounts, new List<String> {'Event'});
                        objEvent.addError(errMesg);
                    }
                }
            }
        }
    }
}