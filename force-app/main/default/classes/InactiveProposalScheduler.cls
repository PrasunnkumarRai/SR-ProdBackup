/*
###########################################################################
# File..................: InactiveProposalScheduler.apxc
# Version...............: 1
# Created by............: Matthew Kidman 
# Created Date..........: 12-June-2019
# Last Modified by......:  
# Last Modified Date....: 
# Description...........: Scheduler class for InactivateProposal Batch
# TAO Ref#..............: 
# Change Log............: SRSF-2177 : Updated to deactivate Proposals from both TIM & Pilot systems both               
############################################################################*/

global class InactiveProposalScheduler implements Schedulable {
    
    global InactiveProposalScheduler(){        
    }

    global void execute(SchedulableContext sc)
    {         
        Set<Id> lostTIMPropIds = new Set<Id>();
        Set<Id> lostPilotPropIds = new Set<Id>();  
        //SRSF-2177: Added inner query to check the proposal order system
        List<Opportunity> lostOppIds = [SELECT Id, (SELECT Id, Pilot_Proposal_ID__c FROM Proposals__r WHERE Active__c=TRUE) FROM Opportunity WHERE Closed_Won_Lost_Date__c = TODAY AND (StageName = 'Closed Lost' OR StageName = 'Closed Lost to Competitor') AND Loss_Reason__c != null AND Active_Proposal_Count__c != 0];
        
        System.debug('lostOppIds--->'+lostOppIds);

        for(Opportunity opp : lostOppIds)
        {
            if(opp.Proposals__r != null)
            {
                for(Proposal__c prop : opp.Proposals__r)
                {
                    if(NULL != prop.Pilot_Proposal_ID__c){
                      lostPilotPropIds.add(prop.Id);
                    }
                    else lostTIMPropIds.add(prop.Id);
                }            
            }
        }

        System.debug('lostTIMPropIds--->'+lostTIMPropIds);
        System.debug('lostPilotPropIds--->'+lostPilotPropIds);

        if(lostTIMPropIds.size() > 0)
        {
            List<UserConnection__c> userConnectionList = [SELECT Id,TIM_System__c,AE_Id__c,User__c,Username__c FROM UserConnection__c WHERE User__c=:UserInfo.getUserId() AND TIM_System__c!=NULL ORDER BY Createddate];
            System.debug('userConnectionList--->'+userConnectionList);
            if(userConnectionList.size()>0){
              Map<String,UserConnection__c> userConnMap = new Map<String,UserConnection__c>();
              for(UserConnection__c userConn : userConnectionList){
                  userConnMap.put(userConn.TIM_System__c,userConn);
              }
              List<Id> listOfIDs = new List<Id>();
              listOfIDs.addAll(lostTIMPropIds);
              
              String queryStr = 'SELECT Id, Active__c, TIM_System__c, Recordtype.DeveloperName, TIM_Id__c, (SELECT Id FROM Proposal_Zones__r) FROM Proposal__c WHERE Id IN ' + '(\'' + String.join(listOfIDs,'\',\'') + '\')';
              Integer batchSize = String.isNotBlank(Label.InactiveProposalsBatch_Size)? Integer.valueOf(Label.InactiveProposalsBatch_Size) : 5;
              InactiveProposalsBatch propBatch = new InactiveProposalsBatch(queryStr ,userConnMap);
              Database.executeBatch(propBatch,batchSize);
            }
        }

        if(lostPilotPropIds.size() > 0)
        {
            List<Id> listOfIDs = new List<Id>();
            listOfIDs.addAll(lostPilotPropIds);         
            String queryStr = 'SELECT Id, Active__c, Pilot_Proposal_ID__c, Recordtype.DeveloperName, (SELECT Id FROM Proposal_Zones__r) FROM Proposal__c WHERE Id IN ' + '(\'' + String.join(listOfIDs,'\',\'') + '\')';
            //New Batch job for Pilot Proposals
            Integer batchSize = String.isNotBlank(Label.InactiveProposalsBatch_Size)? Integer.valueOf(Label.InactiveProposalsBatch_Size) : 5;
            InactivePilotProposalsBatch propBatch = new InactivePilotProposalsBatch(queryStr);
            Database.executeBatch(propBatch,batchSize);
        }
    }
}