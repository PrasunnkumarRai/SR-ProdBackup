/*
###########################################################################
# File..................: Proposal_Zone_Monthly_Value_Scheduler.cls
# Version...............: 1
# Created by............: Ankit Bhatia  
# Created Date..........: 29-March-2017
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This class is for scheduling the Job that runs daily for Proposal Zone Monthly Value Deactivation
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/


global class Proposal_Zone_Monthly_Value_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc)
    {
            deactivateZoneMonthlyValue();
    }
   
    /*Deactivation of Proposal Zone Monthly Value based on todays date and Sunday.*/
    public static void deactivateZoneMonthlyValue()
    {
    	Proposal_Zone_Monthly_Value_Batch proposalBatch = new Proposal_Zone_Monthly_Value_Batch();
    	database.executebatch(proposalBatch);
    	
    }
}