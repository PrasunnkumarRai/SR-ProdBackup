/*
###########################################################################
# File..................: SalesBudgetAggregateQueuable.cls
# Version...............: 1
# Created by............: Matthew Kidman
# Created Date..........: 5-May-2019
# Last Modified by......:
# Last Modified Date....:
# Description...........: This class is used to Initiate the Sales Budget Aggregate Batch in a queue.
# TAO Ref#..............: NA
# Test Class............: 
# Change Log............:
#
#
############################################################################*/
public without sharing class SalesBudgetAggregateQueuable implements Queueable {
	String query;
	Set<ID> userIDs;
	
	public SalesBudgetAggregateQueuable(String qry,Set<ID> userIDs)
	{
		this.query = qry;
		this.userIDs = userIDs;
	}
    public void execute(QueueableContext context) {
       SalesBudgetAggregatebatch srb = new SalesBudgetAggregatebatch(query,userIDs,false);
       database.ExecuteBatch(srb, 2000);
       System.abortJob(context.getJobId());
    }
}