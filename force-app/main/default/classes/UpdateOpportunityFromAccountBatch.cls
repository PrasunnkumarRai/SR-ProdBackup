public class UpdateOpportunityFromAccountBatch implements Database.Batchable<sObject> {
    public String query = 'SELECT Id, Name, UpdateOppFromAccount__c FROM Account WHERE (RecordType.DeveloperName=\'Rep_Firm\' and UpdateOppFromAccount__c = \'' + AccountUtils.ACC_REC_TYPE_AGENCY_TO_REP_FIRM + '\') OR ' + '(RecordType.DeveloperName=\'Agency_Account\' and UpdateOppFromAccount__c = \'' + AccountUtils.ACC_REC_TYPE_REP_FIRM_TO_AGENCY + '\')';
    //public String query = 'SELECT Id, Name FROM Account WHERE RecordType.DeveloperName=\'Rep_Firm\' and UpdateOppFromAccount__c IN (\'' + AccountUtils.ACC_REC_TYPE_AGENCY_TO_REP_FIRM + '\',' + '\'' + AccountUtils.ACC_REC_TYPE_REP_FIRM_TO_AGENCY + '\')';
    public UpdateOpportunityFromAccountBatch() {
        this.query = query;
    }

    public UpdateOpportunityFromAccountBatch(String accountQuery) {
        this.query = accountQuery;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, list<Sobject> scope) {
        Map<Id,Id> oppIdAndAccountIdMap = new Map<Id,Id>();
        Set<Id> accountOppIds = new Set<Id>();
        for (SObject sObj : scope) {
            Account accRec = (Account) sObj;
            accountOppIds.add(accRec.Id);
        }
        
        //Update Opportunity AgencyAccount and RepFirm fields based on current Account record type
        if(accountOppIds.size() > 0) {
            
            Map<Id,Account> accMapToUpdate = new Map<Id,Account>();
            List<String> opptyJSONList = new List<String>();
            List<Opportunity> updateOppList = new List<Opportunity>();   
            system.debug(loggingLevel.WARN, '============================>> accountOppIds = ' + accountOppIds);
            List<Account> accList = [SELECT Id, Name, UpdateOppFromAccount__c, (Select id, agency_account__c, rep_firm__c,agency_account__r.recordtype.name,agency_account__r.recordtype.DeveloperName,rep_firm__r.recordtype.name,stageName,Number_of_Linear_Proposals__c,recordtypeId from Opportunities__r LIMIT 5000), (Select id, agency_account__c, rep_firm__c,agency_account__r.recordtype.name,rep_firm__r.recordtype.name,rep_firm__r.recordtype.DeveloperName,stageName,Number_of_Linear_Proposals__c,recordtypeId from RepFirmOpportunities__r LIMIT 5000) FROM Account WHERE Id IN: accountOppIds];
            if (NULL != accList && !accList.isEmpty()) {
                for (Account acc : accList) {
                    if ((acc.UpdateOppFromAccount__c == AccountUtils.ACC_REC_TYPE_AGENCY_TO_REP_FIRM && acc.Opportunities__r.size() == 0) || (acc.UpdateOppFromAccount__c == AccountUtils.ACC_REC_TYPE_REP_FIRM_TO_AGENCY && acc.RepFirmOpportunities__r.size() == 0)) {
                        acc.UpdateOppFromAccount__c = AccountUtils.ACC_REC_TYPE_UPDATE_DONE;
                        accMapToUpdate.put(acc.Id,acc);
                    }
                    else if (acc.UpdateOppFromAccount__c == AccountUtils.ACC_REC_TYPE_AGENCY_TO_REP_FIRM && acc.Opportunities__r.size() > 0) {
                        for (Opportunity opp : acc.Opportunities__r) {
                            //for(Opportunity opp: [Select id, agency_account__c, rep_firm__c,agency_account__r.recordtype.name,rep_firm__r.recordtype.name,stageName,Number_of_Linear_Proposals__c,recordtypeId from Opportunity where agency_account__c in: accountOppIds]) 
                            system.debug(loggingLevel.WARN, '============================>> opp = ' + opp);
                            //if Opp.AgencyAccount is changed to RepFirm Account and Opp.RepFirm is blank, update RepFirm with AgencyAccount value
                            if(opp.agency_account__r.recordtype.DeveloperName == 'Rep_Firm') {
                                oppIdAndAccountIdMap.put(opp.Id,opp.agency_account__c);
                                system.debug(loggingLevel.WARN, '============================>>  account is Rep Firm!!!');
                                if(String.isBlank(opp.rep_firm__c)) {
                                    system.debug(loggingLevel.WARN, '============================>> Setting opp.rep_firm__c to: ' + opp.agency_account__c);
                                    opp.rep_firm__c = opp.agency_account__c;
                                }
                                //if Opp.AgencyAccount is changed to RepFirm Account, clear value in that field
                                opp.agency_account__c = null;
                                
                                if(opp.Number_of_Linear_Proposals__c > 0) {
                                    opp.recordtypeId = OpportunityUtils.nationalLockedOpportunityRtId;
                                }
                                else {
                                    opp.recordtypeId = OpportunityUtils.nationalOpportunityRtId;
                                }
                                updateOppList.add(opp);
                            }
                        }
                    }
                    else if (acc.UpdateOppFromAccount__c == AccountUtils.ACC_REC_TYPE_REP_FIRM_TO_AGENCY && acc.RepFirmOpportunities__r.size() > 0) {
                        for (Opportunity opp : acc.RepFirmOpportunities__r) {
                            system.debug(loggingLevel.WARN, '============================>> opp = ' + opp);
                            if(opp.rep_firm__r.recordtype.DeveloperName == 'Agency_Account') {
                                oppIdAndAccountIdMap.put(opp.Id,opp.rep_firm__c);
                                system.debug(loggingLevel.WARN, '============================>>  account is Agency Acc!!!');
                                if(String.isBlank(opp.agency_account__c)) {
                                    system.debug(loggingLevel.WARN, '============================>> Setting opp.agency_account__c to: ' + opp.rep_firm__c);
                                    //opp.rep_firm__c = opp.agency_account__c;
                                    opp.agency_account__c = opp.rep_firm__c;
                                }
                                opp.rep_firm__c = null;
                                updateOppList.add(opp);
                            }
                        }
                    }
                }
                if (!updateOppList.isEmpty()) {
                    Database.SaveResult[] saveResultsList = Database.update(updateOppList,false);
                    for (Integer cnt = 0; cnt < updateOppList.size(); cnt++) {
                        Database.SaveResult saveRes = saveResultsList.get(cnt);
                        System.debug('saveRes : ' + saveRes);
                        Opportunity oppRec = updateOppList.get(cnt);
                        if (!saveRes.isSuccess()) {
                            System.debug('saveRes.getId() : ' + saveRes.getId());
                            System.debug('oppRec.Id : ' + oppRec.Id);
                            System.debug('saveRes.getErrors() : ' + saveRes.getErrors()[0].getMessage());
                        }
                        else if (saveRes.isSuccess() && oppIdAndAccountIdMap.containsKey(oppRec.Id)) {
                            Id accId = oppIdAndAccountIdMap.get(oppRec.Id);
                            Account acc = new Account(Id = accId, UpdateOppFromAccount__c = AccountUtils.ACC_REC_TYPE_UPDATE_DONE);
                            accMapToUpdate.put(acc.Id,acc);
                        }
                    }
                }
                if (!accMapToUpdate.isEmpty()) {
                    Database.update(accMapToUpdate.values(),false);
                }
                //Log4SF.logMessage('OpportunityTriggerHandler', 'trackOppotunityTrends', 'Opportunity Trend Big Object Error',ex, UserInfo.getUserId(),'NA');
            }
        }
    }

    public void finish(Database.BatchableContext BC) {

    }
}