global class UpdateAccountFirstContractedAirDate implements Database.Batchable<sObject>, Schedulable {
    public String query;
    private Integer noOfDays = Integer.ValueOf(System.label.ProposalClosedFromLastNdays);

    global UpdateAccountFirstContractedAirDate() {
        String query = 'SELECT Id, Start_Date__c, Proposal_Closed__c,Proposal_Closed_Date__c, Opportunity__r.AccountId, Opportunity__r.Account.First_Contracted_Air_Date__c FROM Proposal__c WHERE Proposal_Closed__c =true AND Proposal_Closed_Date__c >= LAST_N_DAYS:'+noOfDays+' ORDER BY Start_Date__c DESC';
        this.query = query;
    }
    
    global UpdateAccountFirstContractedAirDate(String qry) {
        this.query = qry;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        List<Proposal__c> props = scope;
        Map<Id,Account> accountsToUpdate = new Map<Id,Account>();  
        for (Proposal__c pro : props){
            if (pro.Proposal_Closed__c && pro.Start_Date__c != null) { // && pro.Opportunity__c != null && pro.Opportunity__r.AccountId != null
                if (pro.Opportunity__r.Account.First_Contracted_Air_Date__c == null) {
                    pro.Opportunity__r.Account.First_Contracted_Air_Date__c = pro.Start_Date__c;
                    accountsToUpdate.put(pro.Opportunity__r.AccountId, pro.Opportunity__r.Account);

                }else if(pro.Opportunity__r.Account.First_Contracted_Air_Date__c != null && pro.Opportunity__r.Account.First_Contracted_Air_Date__c > pro.Start_Date__c && pro.Opportunity__r.Account.First_Contracted_Air_Date__c > Date.today() && pro.Start_Date__c >=Date.today()){
                     pro.Opportunity__r.Account.First_Contracted_Air_Date__c = pro.Start_Date__c;
                     accountsToUpdate.put(pro.Opportunity__r.AccountId,pro.Opportunity__r.Account);
                }
            }
        } 
        if(accountsToUpdate.size() > 0) {
            try {
                //update accountsToUpdate.values();
                Database.update(accountsToUpdate.values(), false);
            }catch(Exception e){ System.debug('Error while Updating Account:::'+e.getMessage()+' Line No:'+e.getLineNumber()); }
        }        
    }

    global void finish(Database.BatchableContext BC) {}

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new UpdateAccountFirstContractedAirDate(),Integer.valueOf(System.Label.AccFirstContractDtBatchSize));
    }
}