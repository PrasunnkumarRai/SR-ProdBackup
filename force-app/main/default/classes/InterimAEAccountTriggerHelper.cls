/**
###########################################################################
# Author ...............: Usha Rani
# Created Date..........: 18-June-21
# Ticket ...............: SRSF-2662
# Description...........: It is a helper class for InterimAEAccountTrigger
# Test Class............: 
# Change Log:
# Date              User        Requested By (Optional)      Description  
# 18-June-21        Usha            Greg                      SRSF-2662
# 24-Sep-21         Usha            Greg                      SRSF-3242
############################################################################
*/
public with sharing class InterimAEAccountTriggerHelper 
{
    public static boolean isFirstTime = true;
    private static final String READ_WRITE_ACCESS = 'Edit';
    private static final String INTERIM_AE = 'Interim AE';
    private static List<String> closedLostStage = new List<String>{'Closed Lost','Closed Lost to Competitor'};

    public static void afterUpdate(Map<Id,List<Interim_AE_Account__c>> accToAEmap, Set<Id> interimAEs)
    {
        System.debug('accToAEmap-->' +accToAEmap); 
        if(accToAEmap.size()>0)
        { 
            List<AccountTeamMember> toInsertATMs = new List<AccountTeamMember>();
            List<OpportunityTeamMember> toInsertOTMs = new List<OpportunityTeamMember>();
            List<Interim_AE_Account__c> updateInterim = new List<Interim_AE_Account__c>();
            List<Interim_AE_Account__c> lstInterimAE = new List<Interim_AE_Account__c>();
          /*  SRSF-4928:  Commented 
            Set<String> interimAEFound = new Set<String>();
            Set<String> interimAEFoundOnOTM = new Set<String>();
           */

            for(Id acctId : accToAEmap.keySet())
            {
                lstInterimAE.addAll(accToAEmap.get(acctId));
            }
            System.debug('lstInterimAE-->'+lstInterimAE);

           /*  SRSF-4928: Commented below code
           List<AccountTeamMember> atmList = [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN :accToAEmap.keyset() AND UserId IN :interimAEs];
            System.debug('atmList-->'+atmList);

            for(AccountTeamMember atm : atmList)
            {
                interimAEFound.add(atm.AccountId+'_'+atm.UserId);
            }
            System.debug('interimAEFound-->'+interimAEFound);*/

            for(Interim_AE_Account__c interimAcct : lstInterimAE)
            {
                String key = interimAcct.Account__c+'_'+interimAcct.Interim_AE__c;
                System.debug('ATM key-->'+key);
                //if(!interimAEFound.contains(key)) { // SRSF-4928: Commented if condition
                AccountTeamMember atm = new AccountTeamMember();
                atm.AccountId = interimAcct.Account__c;
                atm.UserId = interimAcct.Interim_AE__c;
                atm.AccountAccessLevel = READ_WRITE_ACCESS ;
                atm.OpportunityAccessLevel = READ_WRITE_ACCESS ;
            //  atm.CaseAccessLevel = READ_WRITE_ACCESS ; // SRSF-4367: Commented to avoid Insufficient Access issue as Interim AE can't have access more than the Account Owner and Interim AE don't need CASE access
                atm.TeamMemberRole = INTERIM_AE ;
                toInsertATMs.add(atm);                    
               // }   // SRSF-4928: Commented if condition
                updateInterim.add(new Interim_AE_Account__c(Id= interimAcct.Id, Processed__c = true));
            }            
                 
            List<Opportunity> opportunities = [SELECT Id, AccountId, OwnerId, (SELECT Id, UserId FROM OpportunityTeamMembers WHERE UserId IN :interimAEs) FROM Opportunity WHERE AccountId IN :accToAEmap.keySet() AND StageName NOT IN :closedLostStage] ;
            System.debug('opportunities-->'+opportunities);

           /*  SRSF-4928: Commented below code
           for(Opportunity opp: opportunities)
            {
                for(OpportunityTeamMember otm : opp.OpportunityTeamMembers) 
                {
                    interimAEFoundOnOTM.add(opp.AccountId+'_'+opp.Id+'_'+otm.UserId);
                }
            }
            System.debug('interimAEFoundOnOTM-->'+interimAEFoundOnOTM);   */         
            
            for(Opportunity opp: opportunities)
            {
                if(NULL != accToAEmap.get(opp.AccountId)) 
                {
                    for(Interim_AE_Account__c interimAcc : accToAEmap.get(opp.AccountId))
                    {    
                        String key = opp.AccountId+'_'+opp.Id+'_'+interimAcc.Interim_AE__c;
                        System.debug('OTM key-->'+key);
                       // SRSF-4928: Commented if condition : if(!interimAEFoundOnOTM.contains(key) && opp.OwnerId == interimAcc.Primary_AE__c)
                        if(opp.OwnerId == interimAcc.Primary_AE__c) 
                        {
                            OpportunityTeamMember otm = new OpportunityTeamMember();
                            otm.OpportunityId = opp.Id ;
                            otm.UserId = interimAcc.Interim_AE__c;
                            otm.OpportunityAccessLevel = READ_WRITE_ACCESS ;
                            otm.TeamMemberRole = INTERIM_AE;
                            toInsertOTMs.add(otm);
                        }
                    }
                }
            }

            System.debug('toInsertATMs-->' +toInsertATMs); 
            System.debug('toInsertOTMs-->' +toInsertOTMs);    
         
            if(toInsertATMs.size()>0)
                INSERT toInsertATMs;

            if(toInsertOTMs.size()>0)
                INSERT toInsertOTMs;
            
            if (updateInterim.Size()>0){             
                UPDATE updateInterim;
            }
        }
    }
}