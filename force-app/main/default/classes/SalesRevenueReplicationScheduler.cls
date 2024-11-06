/*
###########################################################################
# File..................: SalesRevenueReplicationScheduler.cls
# Version...............: 1
# Created by............: James Dean
# Created Date..........: 27-June-2019
# Last Modified by......:
# Last Modified Date....:
# Description...........: 
# TAO Ref#..............: 
# Test Class............: 
# Change Log............:
#
############################################################################*/
global class SalesRevenueReplicationScheduler implements Schedulable {
    
    global SalesRevenueReplicationBatch srrBatch;
    
    global SalesRevenueReplicationScheduler(){
        srrBatch = new SalesRevenueReplicationBatch('');
    }
      
    global void execute(SchedulableContext sc) {
        Database.executeBatch(srrBatch , 2000);
    }
    
    global void finish(SchedulableContext BC)
    {
        System.debug('SalesRevenueReplicationScheduler.finish()');
    }
        
}