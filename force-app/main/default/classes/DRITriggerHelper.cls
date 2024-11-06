public class DRITriggerHelper {
	public DRITriggerHelper() {
        System.debug('Inside DRITriggerHelper Constructor');
    }
    public void updateRecordTypeofDRI(List<DuplicateRecordItem> newDRIs) {
        system.debug('@@newDRIs: '+newDRIs);
        Map<Id,DuplicateRecordItem> recordIds = new Map<Id,DuplicateRecordItem>();
        for(DuplicateRecordItem dri: newDRIs){
            recordIds.put(dri.RecordId,dri);
        }
        system.debug('@@recordIds: '+recordIds);
        List<Account> accnts = [SELECT ID, RecordType.DeveloperName, Website, Phone,  
                                Complete_Billing_Address__c, DunsNumber__c, Primary_Commodity__c
                                FROM Account WHERE ID IN :recordIds.keySet()];
        system.debug('@@accnts: '+accnts);
        if(accnts !=null && accnts.size()>0){
            for(Account acc:accnts){
                DuplicateRecordItem driObj = recordIds.get(acc.Id);
                driObj.Record_Type_Name__c = acc.RecordType.DeveloperName;
				driObj.Phone__c = acc.Phone;
				//driObj.Website__c = acc.Website;
				driObj.Complete_Billing_Address__c = acc.Complete_Billing_Address__c;
				driObj.DunsNumber__c = acc.DunsNumber__c;
                driObj.IsUpdated__c = true;
                driObj.Primary_Commodity__c = acc.Primary_Commodity__c;
                system.debug('@@driObj: '+driObj);
            }
        }
    }
}