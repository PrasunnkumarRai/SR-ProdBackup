global class DeleteProposalZoneMonthlyValues implements Database.Batchable<sObject> {
    public String query;

    global DeleteProposalZoneMonthlyValues() {
        query = 'SELECT Id FROM Proposal_Zone_Monthly_Value__c WHERE CreatedById = \''+System.Label.DltPrpslZoneBatchUserId+'\'';
       
        //query = 'SELECT Id FROM Proposal_Zone_Monthly_Value__c '+
               // ' WHERE Id = \'a0H3B000003gHYV\' ';

        if(test.isRunningTest()){
            query = 'SELECT Id FROM Proposal_Zone_Monthly_Value__c';
        }
        System.debug('@@query '+query);

        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> sObjects) {
        List<Proposal_Zone_Monthly_Value__c> listProposalVal = (List<Proposal_Zone_Monthly_Value__c>) sObjects;
        System.debug('@@@List size '+listProposalVal.size());
        delete listProposalVal;
    }

    global void finish(Database.BatchableContext BC) {

    }
}