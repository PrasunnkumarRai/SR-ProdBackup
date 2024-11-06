/* 
    Customer/Project:   Spectrum Reach
    Class name:         OpportunityUtil
    Author/Date:       Brett Ballantyne    5/11/2017
    Release:            TBD
    Purpose:           Utility methods for the Opportunity Object
*/

public with sharing class OpportunityUtil {
	public OpportunityUtil() {
		
	}

	public static List<OpportunityStage> getOpptyStages() {
		return [SELECT ApiName,DefaultProbability,Description,ForecastCategory,ForecastCategoryName,Id,IsActive,MasterLabel,SortOrder 
				FROM OpportunityStage
				where IsActive = true
				order by SortOrder];
	}
}