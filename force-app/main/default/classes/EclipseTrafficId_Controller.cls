public with sharing class EclipseTrafficId_Controller {
	public EclipseTrafficId_Controller() {
		
	}

	private static Integer numRecs;

		//Account, Export System, TIM System, Traffic ID

	@AuraEnabled
	public static List<Traffic_Id_Element__c> getEclipseTraffic(Id acctId) {
		System.debug('=================>> acctId = ' + acctId);
		List<Traffic_Id_Element__c> retList;
		retList =  [select Account__c, Account__r.Name, ExportSystem_Name__c, TIM_System__c, Traffic_Id__c From Traffic_Id_Element__c
				 	where Traffic_Type__c = 'Account' and Account__c = :acctId];
		numRecs = retList.size();
		return retList;
	}

}