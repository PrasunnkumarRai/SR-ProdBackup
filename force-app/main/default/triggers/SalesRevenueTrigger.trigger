/*###########################################################################
# File..................: SalesRevenueTrigger.apxt
# Version...............: 1
# Created by............: Ashok Aggarwal   
# Created Date..........: 18-June-2018
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: Sales Revenue Trigger
# TAO Ref#..............: 
# Change Log:               
#
#
############################################################################*/
trigger SalesRevenueTrigger on Sales_Revenue__c (after insert, before insert, before update) {
	if(Boolean.valueOf(Label.Sales_Revenue_Trigger_Switch))
	{
		if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
			SalesRevenueTriggerHelper.updateUserAccountinRevenue(Trigger.new);  
		}
	}   
	SalesRevenueTriggerHelper.mapDMAGLID(Trigger.new);
}