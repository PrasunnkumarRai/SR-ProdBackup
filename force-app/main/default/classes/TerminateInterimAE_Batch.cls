/**
###########################################################################
# Author ...............: Usha Rani
# Created Date..........: 18-June-21
# Ticket ...............: SRSF-2662
# Description...........: This batch job is to delete the account/opportunity access for interim AE's once .........................  the service is ended
# Test Class............:  TerminateInterimAE_BatchTest
# Change Log:
# Date              User        Requested By (Optional)      Description  
# 18-June-21        Usha            Greg                      SRSF-2662
############################################################################
*/
global class TerminateInterimAE_Batch implements Database.Batchable<sObject>, Database.Stateful
{ 
    List<Interim_AE_Account__c> recsToProcess = new List<Interim_AE_Account__c>(); 
    Map<Id, Set<Id>> recsRenewed = new Map<Id, Set<Id>>();
    Map<Id, AccountTeamMember> toDeleteATMs = new Map<Id, AccountTeamMember>();
    Map<Id, OpportunityTeamMember> toDeleteOTMs = new Map<Id, OpportunityTeamMember>();
    Set<String> failToDelTeamMembers = new Set<String>();
    Map<String, List<Interim_AE_Account__c>> recsToUpdate = new Map<String, List<Interim_AE_Account__c>>(); 

    public String query = 'SELECT Id, Account__c, Primary_AE__c, Interim_AE__c, StartDate__c, EndDate__c, Ended__c FROM Interim_AE_Account__c WHERE Status__c = \'Approved\' AND Ended__c = FALSE AND Processed__c = TRUE ORDER BY Account__c';

    global TerminateInterimAE_Batch()
    {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        System.debug('query -->' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) 
    { 
        System.debug('In execute method, scope-->' + scope);
        Map<Id, Set<Id>> aeIds = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> primaryAEs = new Map<Id, Set<Id>>();    
        List<String> closedLostStage = new List<String>{'Closed Lost','Closed Lost to Competitor'};
        
        // Iterate all records and check if Enddate is past date then remove interim AE access
        for (sObject so: scope) 
        {
            Interim_AE_Account__c interimAcct = (Interim_AE_Account__c) so;
            if(interimAcct.EndDate__c <= Date.today())
            {
                recsToProcess.add(interimAcct);
            }
            //For Renewed records, same account and same AE combination multiple records will exist then do not delete ATM/OTM if service renewed            
            if(interimAcct.EndDate__c > Date.today()) 
            {
                if(!recsRenewed.containsKey(interimAcct.Account__c))
                {
                    recsRenewed.put(interimAcct.Account__c, new Set<Id>());
                }
                recsRenewed.get(interimAcct.Account__c).add(interimAcct.Interim_AE__c);
            }
        }

        System.debug('In execute method, records to process-->' + recsToProcess);
        System.debug('In execute method, records Renewed-->' + recsRenewed);
        
        for (Interim_AE_Account__c interimAcct: recsToProcess)  
        {     
            interimAcct.Ended__c = true;  //SRSF-4931 - Mark old interimAE record as Ended
            Set<Id> interimUsers = recsRenewed.get(interimAcct.Account__c); 
            System.debug('In execute method, interimUsers-->' + interimUsers);   

            if(NULL == interimUsers || (NULL != interimUsers && !interimUsers.contains(interimAcct.Interim_AE__c))) 
            {        
               // interimAcct.Ended__c = true;     //SRSF-4931 - Commented     
                //Map all the AE's if Account is assigned for multiple users for temporary servicing 
                if(!aeIds.containsKey(interimAcct.Account__c))
                {
                    aeIds.put(interimAcct.Account__c, new Set<Id>());
                }
                aeIds.get(interimAcct.Account__c).add(interimAcct.Interim_AE__c);
                //Map all the Original AE's for removing temporary service access for the opportunities wrt. accounts
                if(!primaryAEs.containsKey(interimAcct.Account__c))
                {
                    primaryAEs.put(interimAcct.Account__c, new Set<Id>());
                }
                primaryAEs.get(interimAcct.Account__c).add(interimAcct.Primary_AE__c);
            }           

            //START - SRSF-4931 : Added below code
            String interimAEAccKey = interimAcct.Account__c + '_'+interimAcct.Interim_AE__c ;
            if(!recsToUpdate.containsKey(interimAEAccKey))
            {
                recsToUpdate.put(interimAEAccKey, new List<Interim_AE_Account__c>());
            }
            recsToUpdate.get(interimAEAccKey).add(interimAcct);
            //END - SRSF-4931
        }       

        if(aeIds.size()>0)
        {       
            List<Set<Id>> lstUserIds = aeIds.values();
            Set<Id> userIds = new Set<Id>();
            for(Set<Id> ids : lstUserIds)
            {
                userIds.addAll(ids);
            }

            // Retrive all ATM/OTM records wherever AE is added as Interim AE             
            List<AccountTeamMember> lstATMs = [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN :aeIds.keySet() AND UserId IN :userIds AND TeamMemberRole = 'Interim AE']; 

            for(AccountTeamMember atm : lstATMs)
            {
                Set<Id> users = aeIds.get(atm.AccountId); 
                if(NULL != users && users.contains(atm.UserId)) 
                {                     
                    toDeleteATMs.put(atm.Id, atm); 
                }
            }           
            
            List<Opportunity> oppList =  [SELECT Id, AccountId, OwnerId, (SELECT Id, UserId FROM OpportunityTeamMembers WHERE UserId IN :userIds AND TeamMemberRole = 'Interim AE' ) FROM Opportunity WHERE AccountId IN :aeIds.keySet() AND StageName NOT IN :closedLostStage];

            for(Opportunity opp : oppList)
            {
                if(opp.OpportunityTeamMembers != NULL && opp.OpportunityTeamMembers.size() > 0)
                {
                    Set<Id> originalAEs = primaryAEs.get(opp.AccountId);
                    if(originalAEs.contains(opp.OwnerId)) 
                    {
                        Set<Id> interimAEs = aeIds.get(opp.AccountId);
                        for(OpportunityTeamMember otm : opp.OpportunityTeamMembers) 
                        {
                            if(NULL != interimAEs && interimAEs.contains(otm.UserId))
                            {                                
                                toDeleteOTMs.put(otm.Id, otm);
                            }
                        }
                    }
                }
            }            
        }

        System.debug('toDeleteATMs-->' + toDeleteATMs);
        System.debug('toDeleteOTMs-->' + toDeleteOTMs);
        System.debug('recsToUpdate-->' + recsToUpdate);
                
        //Remove InterimAE's from AccountTeamMember and OppotunityTeamMember
        if(toDeleteATMs.size()>0)
        {
            Database.DeleteResult[] deleteATMResults = Database.delete(toDeleteATMs.values(), false);

            for(Integer i=0; i < deleteATMResults.size(); i++)
            {
                // get failed recors to stop the associated interimAE record Ended as true
                if(!deleteATMResults.get(i).isSuccess()) 
                {   
                    AccountTeammember failedATM = toDeleteATMs.values().get(i); 
                    if(failedATM != NULL)
                    { 
                        String failedATMKey = failedATM.AccountId+ '_'+ failedATM.UserId;
                        failToDelTeamMembers.add(failedATMKey);
                    }
                }
            }
        }

        if(toDeleteOTMs.size()>0)
        {
            Database.DeleteResult[] deleteOTMResults = Database.delete(toDeleteOTMs.values(), false);

            for(Integer i=0; i < deleteOTMResults.size(); i++)
            {
                // get failed recors to stop the associated interimAE record Ended as true
                if(!deleteOTMResults.get(i).isSuccess()) 
                {   
                    OpportunityTeamMember failedOTM = toDeleteOTMs.values().get(i);  
                    if(failedOTM != NULL && failedOTM.Opportunity != NULL)
                    {
                        String failedOTMKey = failedOTM.Opportunity.AccountId+ '_'+ failedOTM.UserId;
                        failToDelTeamMembers.add(failedOTMKey);
                    }
                }
            }
        }

        //Once InterimAE is removed update interim AE service ended as true       
        if(recsToUpdate.size() > 0) 
        {  
            //Remove interimAE records from recsToUpdate as team member deletion failed, so interimAE record should not be marked as ended unless all the team members deletion is success
            List<Interim_AE_Account__c> endedInterimAERecs =  new List<Interim_AE_Account__c>();
            for(String key : failToDelTeamMembers)
            {
                if(recsToUpdate.containsKey(key)){
                   recsToUpdate.remove(key); 
                }   
            }
            for(List<Interim_AE_Account__c> lstRecs : recsToUpdate.values())
            {
                endedInterimAERecs.addAll(lstRecs);  
            }          
            
            System.debug('Final InterimAE Records to Mark as Ended TRUE-->' + endedInterimAERecs);
            if(endedInterimAERecs.size() > 0)
            {                
                Database.update(endedInterimAERecs, false);
            }
        }
    }

    global void finish(Database.BatchableContext BC) { }
}