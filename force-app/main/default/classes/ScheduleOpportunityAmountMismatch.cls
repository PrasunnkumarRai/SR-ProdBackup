/*
###########################################################################
# Created by............: Sai Anuja
# Created Date..........: 26-June-2018
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This class is scheduler for BatchOpportunityAmountMismatch
# Change Log:               
#

############################################################################*/

global class ScheduleOpportunityAmountMismatch implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchOpportunityAmountMismatch oppAmtMismatchBatch = new BatchOpportunityAmountMismatch();
		ID batchprocessid = Database.executeBatch(oppAmtMismatchBatch,200);
    }
}