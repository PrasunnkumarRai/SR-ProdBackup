public with sharing class SyscodeSyncController {

public SyscodeSyncController(ApexPages.StandardController std){
		
}

public pageReference syncSyscodes(){
	
	BoomiWebServiceHelper bws = new BoomiWebServiceHelper();	
	bws.syncSyscodes();		
	//return new pageReference('/one/one.app#/sObject/Syscode__c/list?filterName=' + System.label.SyscodeListView);
	return new pageReference(Label.LEX_sObject_URL + 'Syscode__c/list?filterName=' + System.label.SyscodeListView);
}
    
}