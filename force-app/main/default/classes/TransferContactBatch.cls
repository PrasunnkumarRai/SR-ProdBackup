global class TransferContactBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
	public String query;
	public Set<ID> atmIds;
	public List<Admin_Tool_Status_Summary__c> adminToolSummary;
	public Set<Id> AccIdlist;
	public list<Contact> contactRecord;
	public Map<String, Id> TransferUser;
	public Set<ID> atssIds;
	public String simulateID;
	public List<contact> contactRecordTodel;
	public Map<String, Id> duplicatecontact;
	public Boolean IsRetry = false;
	public Map<String, Id> removeContact;
	public Map<String, Contact> ContactMap;
	global TransferContactBatch(List<Admin_Tool_Status_Summary__c> adminToolSmry, string simulateID) {
		System.debug('adminToolSmry ' + adminToolSmry);
		System.debug('simulateID ' + simulateID);
		this.query = query;
		this.adminToolSummary = adminToolSmry;
		this.simulateID = simulateID;
		this.atssIds = new Set<ID> ();
		this.AccIdlist = new Set<Id> ();
		this.TransferUser = new Map<String, Id> ();
		for (Admin_Tool_Status_Summary__c adminStsDet : adminToolSmry) {

			atssIds.add(adminStsDet.Id);

			system.debug('atm Id: ' + atssIds);
		}
		List<Account_Transfer_Mapping__c> atmList = [Select Id, Account__c, From_User__c, To_User__c from Account_Transfer_Mapping__c where Account_Transfer_Simulation__c = :simulateID];
		//List<Admin_Tool_Status_Summary__c> accountIds = [select id, name, Transfer_Details__r.account__c, Transfer_Details__r.To_User__c, Transfer_Details__r.from_user__c from Admin_Tool_Status_Summary__c where id in :atssIds];
		System.debug('accountIds' + atmList[0].Id);

		for (Account_Transfer_Mapping__c atm : atmList) {
			System.debug('@@@@ ' + atm.Id);
			AccIdlist.add(atm.account__c);
			system.debug('AccIdlist' + AccIdlist);

			TransferUser.put(String.valueOf(atm.from_user__c) + String.valueOf(atm.account__c), atm.To_User__c);
			TransferUser.put(String.valueOf(atm.To_user__c) + String.valueOf(atm.account__c), atm.To_User__c);
		}
	}

	/**
	 * @description gets invoked when the batch job starts
	 * @param context contains the job ID
	 * @returns the record set as a QueryLocator object that will be batched for execution
	 */
	global Database.QueryLocator start(Database.BatchableContext context) {

		query = 'select id,OwnerId,AccountId,Email from contact where account.id in :AccIdlist';

		system.Debug('getQueryLocator' + query);
		return Database.getQueryLocator(query);

	}


	/**
	 * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
	 * @param context contains the job ID
	 * @param scope contains the batch of records to process.
	 */
	global void execute(Database.BatchableContext context, List<Contact> scope) {
		this.contactRecord = new list<contact> ();
		this.contactRecordTodel = new List<Contact> ();
		this.duplicatecontact = new Map<String, Id> ();
		this.removeContact = new Map<String, Id> ();
		this.ContactMap = new Map<String, Contact> ();

		for (Contact conId : scope) {
			String oldKey = String.valueOf(conId.OwnerId) + String.valueOf(conId.Email) + String.valueOf(conId.AccountId);

			//if (ContactMap.containsKey(oldKey))
			//{
			//contactRecordTodel.add(conId);
			//System.debug('contactRecordTodel line77 ' + contactRecordTodel);
			//}
			//else {
			ContactMap.put(oldKey, conId);
			//}
		}

		for (String strKey : contactMap.keySet()) {
			Contact conRec = contactMap.get(strKey);
			if (TransferUser.containsKey(string.valueof(ConRec.OwnerId) + string.valueof(ConRec.AccountId))) {
				String newKey = String.valueOf(TransferUser.get(string.valueof(ConRec.OwnerId) + string.valueof(ConRec.AccountId))) + String.valueOf(ConRec.Email) + String.valueOf(ConRec.AccountId);
				if (ContactMap.containsKey(newKey))
				{
					//Delete ConId
					contactRecordTodel.add(contactMap.get(newKey));
					System.debug('contactRecordTodel line95 ' + contactRecordTodel);
				}
				else {
					ConRec.OwnerId = TransferUser.get(string.valueof(ConRec.OwnerId) + string.valueof(ConRec.AccountId));
					contactRecord.add(ConRec);
					System.debug('contactRecord ' + contactRecord);
				}

			}

		}
		system.Debug('contactRecord ' + contactRecord);
		System.debug('contactRecordTodel ' + contactRecordTodel);
		update contactRecord;
		delete contactRecordTodel;
	}

	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */
	global void finish(Database.BatchableContext context) {
		TransferDigitalCampaignBatch tdc = new TransferDigitalCampaignBatch('', adminToolSummary, simulateID);
		Database.executeBatch(tdc,5);
	}

	//@future(callout = true)
	//public static void callBoomiUserBudgetAggregate(List<String> setuserIds) {
	//BoomiBudgetAggregate body = new BoomiBudgetAggregate();
	//body.userList = setuserIds;
	//System.debug('setuserIds: ' + setuserIds);
	//String baseUrl = 'http://3.227.174.198:9090/ws/rest/UserSBAgg/invoke_SBAgg/';
	//HttpRequest httpRequest = new HttpRequest();
	//httpRequest.setEndpoint(baseUrl);
	//httpRequest.setMethod('POST');
	//httpRequest.setHeader('Accept', 'application/json');
	//httpRequest.setHeader('Content-type', 'application/json; charset=UTF-8');
	//httpRequest.setTimeout(120000);
	//httpRequest.setBody(JSON.serialize(body, true));
	//Http http = new Http();
	//System.debug('httpRequest ' + httpRequest);
	//HttpResponse httpResponse = http.send(httpRequest);
	//System.debug('@@httpResponse: ' + httpResponse);
	//}
}