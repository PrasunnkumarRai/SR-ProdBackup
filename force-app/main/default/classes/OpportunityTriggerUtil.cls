/* 
    Customer/Project:   Spectrum Reach
    Class name:          OpportunityTriggerUtil
    Author/Date:        Brett Ballantyne    5/2/2017
    Release:            	TBD
    Purpose:            Provides utility methods for the Opportunity Trigger

    *** IMPORTANT ***
    This class runs in "god mode", meaning without sharing.
    Please ensure that any code added to this class won't allow security abuses
*/

public without sharing class OpportunityTriggerUtil {
	public OpportunityTriggerUtil() {
		
	}

	public static void createATM(List<AccountTeamMember> atms) {
	      if (atms.size() == 0) return;
	      try {
	          insert atms;
	      } catch(Exception e) {
	          system.debug('==========>> Error caught inserting AccountTeamMembers: ' + e.getMessage());
	      }

	}
}