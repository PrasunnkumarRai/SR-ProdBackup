/*
###########################################################################
# Created by............: Sai Anuja
# Created Date..........: 26-June-2018
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This class is being used to update opportunity mismatched amount.
# Change Log:               
#

############################################################################*/

global class BatchOpportunityAmountMismatch implements Database.Batchable<sObject> {
    public String query;

    global BatchOpportunityAmountMismatch() {
        String query = 'SELECT id, name, Amount_Mismatch__c, Amount, Total_Gross_Amount__c, Total_Forecast_Amount__c, Projected_Gross_Amount__c FROM Opportunity WHERE Amount_Mismatch__c = true';
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        List<Opportunity> opportunities = scope;
        for(Opportunity opp : opportunities){
            opp.Amount = opp.Total_Gross_Amount__c;
            opp.Total_Forecast_Amount__c = opp.Projected_Gross_Amount__c;
        }
        update opportunities;
    }

    global void finish(Database.BatchableContext BC) {

    }
}