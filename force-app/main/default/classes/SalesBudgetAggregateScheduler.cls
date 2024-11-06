/*
###########################################################################
# File..................: SalesRevenueReplicationScheduler.cls
# Version...............: 1
# Created by............: Matthew Kidman
# Created Date..........: 27-August-2019
# Last Modified by......:
# Last Modified Date....:
# Description...........: 
# TAO Ref#..............: 
# Test Class............: 
# Change Log............:
#
############################################################################*/
global class SalesBudgetAggregateScheduler implements Schedulable {
	 global SalesBudgetAggregateBatch srrBatch;
    
    global SalesBudgetAggregateScheduler(){
        srrBatch = new SalesBudgetAggregateBatch('',null,false);
    }
      
	/**
	 * @description Executes the scheduled Apex job. 
	 * @param sc contains the job ID
	 */ 
	global void execute(SchedulableContext sc) {
		  Database.executeBatch(srrBatch , 2000);
	}
}