/*
###########################################################################
# File..................: ProposalSCXUploadController.cls
# Version...............: 1
# Created by............: Bhuvanasankar Das   
# Created Date..........: 
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: To sync all the proposals which are activated from inactive state ( initiated from Proposal options page)
# Change Log:               
#
############################################################################*/
global class BatchToSyncProposalLineItems implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public String query; // Query must contain Id, TIM_System__c and Opportunity__r.OwnerId

    global BatchToSyncProposalLineItems(String query) {
        System.debug(' $$$ query ::: ' +query);
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Proposal__c> propList) {
        Map<String, List<Proposal__c>> oppOwnerPropMap = new Map<String, List<Proposal__c>>();
        Map<String, UserConnection__c> oppOwnerUserConnectionMap = new Map<String, UserConnection__c>();
        Set<String> oppOwnerSet = new Set<String>();
        List<Proposal__c> proposalToBeUpdated = new List<Proposal__c>();
        for(Proposal__c prop : propList) {
            // BoomiWebServiceHelper.syncProposalLineItems(Proposal__c pro, UserConnection__c oppOwnerUser);
            String mapKey = prop.Opportunity__r.OwnerId + '_' + prop.TIM_System__c;
            if(!oppOwnerPropMap.containsKey(mapKey)) {
                oppOwnerPropMap.put(mapKey, new List<Proposal__c>{prop});
            }
            else {
                oppOwnerPropMap.get(mapKey).add(prop);
            }
            oppOwnerSet.add(prop.Opportunity__r.OwnerId);
        }

        List<UserConnection__c> userConnectList = [SELECT AE_Id__c, TIM_System__c, Username__c, User__r.Name FROM UserConnection__c WHERE User__c IN : oppOwnerSet AND AE_Id__c != null AND Is_Primary__c = true];

        for(UserConnection__c userConn : userConnectList) {
            String key = userConn.User__c + '_' + userConn.TIM_System__c;
            // if(!oppOwnerUserConnectionMap.containsKey(key)) {
            oppOwnerUserConnectionMap.put(key, userConn);
            // }
        }

        for(String str : oppOwnerPropMap.keySet()) {
            for(Proposal__c prop : oppOwnerPropMap.get(str)) {
                if(oppOwnerUserConnectionMap.containsKey(str)) {
                    UserConnection__c oppOwnerUser = oppOwnerUserConnectionMap.get(str);
                    BoomiWebServiceHelper boomiWSH = new BoomiWebServiceHelper();
                    String syncStatus = boomiWSH.syncProposalLineItems(prop, oppOwnerUser);
                    if(!'Success'.equalsIgnoreCase(syncStatus)) {
                        prop.Bad_Sync__c = true;
                        prop.Bad_Sync_Reason__c = syncStatus;
                    }
                    proposalToBeUpdated.add(prop);
                }
            }
        }
        if(proposalToBeUpdated.size() > 0) {
            update proposalToBeUpdated;
        }
    }

    global void finish(Database.BatchableContext BC) {

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

        message.setSubject(Label.SyncProposalEmailSubject);

        message.setPlainTextBody(Label.SyncProposalBatchEmailBody);

        message.setToAddresses( new String[] { UserInfo.getUserEmail() } );

        Messaging.sendEmail( new Messaging.SingleEmailMessage[] { message } );
    }
}