/**
###########################################################################
# Author ...............: Usha Rani
# Created Date..........: 18-June-21
# Ticket ...............: SRSF-2662
# Description...........: 
# Test Class............: 
# Change Log:
# Date              User        Requested By (Optional)      Description  
# 18-June-21        Usha            Greg                      SRSF-2662
# 24-Sep-21         Usha            Greg                      SRSF-3242
############################################################################
*/
trigger InterimAEAccountTrigger on Interim_AE_Account__c (after update) 
{

    if(Trigger.isUpdate && Trigger.isAfter)
    {   
        System.debug('Inside after update trigger' +InterimAEAccountTriggerHelper.isFirstTime); 
        if(InterimAEAccountTriggerHelper.isFirstTime)
        {
            InterimAEAccountTriggerHelper.isFirstTime = false;

            //Map<Id, Interim_AE_Account__c> accToAEmap = new Map<Id, Interim_AE_Account__c>();
            Map<Id, List<Interim_AE_Account__c>> accToAEmap = new Map<Id, List<Interim_AE_Account__c>>();
            Set<Id> interimAEs = new Set<Id>();

            for(Interim_AE_Account__c acct : Trigger.New)
            {                
                if(acct.Status__c == 'Approved' && Trigger.OldMap.get(acct.Id).Status__c != 'Approved' && !acct.Processed__c && !acct.Ended__c){ 
                    //SRSF:3242 Commented to support mass approval scenario
                    // accToAEmap.put(acct.Account__c, acct); 
                    interimAEs.add(acct.Interim_AE__c);
                    if(!accToAEmap.containsKey(acct.Account__c)){
                        accToAEmap.put(acct.Account__c, new List<Interim_AE_Account__c>());
                    }
                    accToAEmap.get(acct.Account__c).add(acct);
                    //END : SRSF-3242
                }
            }

            if(accToAEmap.size() > 0 ){
               InterimAEAccountTriggerHelper.afterUpdate(accToAEmap, interimAEs);
            }
        }    
    }

}