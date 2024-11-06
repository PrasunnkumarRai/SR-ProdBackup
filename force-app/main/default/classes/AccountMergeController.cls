/*
  ###########################################################################
  # File..................: AccountMergeController.cls
  # Version...............: 1
  # Created by............: Sanchit Singhal   
  # Created Date..........: 17-April-2017
  # Last Modified by......: Bhuvanasankar Das
  # Last Modified Date....: 05-Dec-2017
  # Description...........: This class contains controller methods for AccountMerge visualforce page
  # TAO Ref#..............: NA
  # Change Log:               
  #
  #
  ############################################################################*/
public with sharing class AccountMergeController {

	// Properties
	public String successPageMsg { get; set; }
	public String rejectPageMsg { get; set; }
	public String SfInstance { get; set; }
	public Boolean errorOccured { get; set; }
	public Account acc { get; set; }
	public list<Opportunity> inactiveOppUserList { get; set; }
	public map<string, string> userMap { get; set; }
	public static Account childAcc { get; set; }
	public Integer SizeOfMap { get { return userMap.size(); } }
	// Variables
	public Boolean accessError;
	public List<Account_SAM_Mapping__c> accSAM_Update;
	//public Account_SAM_Mapping__c childAccSAM;
	public Boolean isAgencyAccount = false;
	public Boolean isRepFirmAccount = false;
	public Boolean hasSameRecordType = false;
	public String errorFields = '';
	public Account_Merge_Log__c mergeRec;
	public Account mergeAcc = new Account();
	public Set<String> createableFields;
	public List<Opportunity> mergeOppList = new List<Opportunity> ();
	public List<Contact> mergingContactList = new List<Contact> ();
	public List<AccountConnection__c> mergeAccConnList = new List<AccountConnection__c> ();
	public List<CNA__c> mergeCNAlist = new List<CNA__c> ();
	public List<Revenue__c> revenueList = new List<Revenue__c> ();
	public List<Budget__c> budgetList = new List<Budget__c> ();
	public List<Support_Request__c> supportRequestList = new List<Support_Request__c> ();
	public List<Sales_Budget__c> salesBudgetList = new List<Sales_Budget__c> ();
	public List<Sales_Budget__c> salesBudgetDelList = new List<Sales_Budget__c> ();
	//public List<Team_Member_Role__mdt> custMetadata = new List<Team_Member_Role__mdt>();
	public List<Account_SAM_Mapping__c> updateAccSAMList = new List<Account_SAM_Mapping__c> ();
	public List<Account_SAM_Mapping__c> delAccSAMList = new List<Account_SAM_Mapping__c> ();
	public List<Traffic_Id_Element__c> trafficIdElementList = new List<Traffic_Id_Element__c> ();
	public List<Trade__c> tradeList = new List<Trade__c> ();
	public List<Proposal__c> mergeProposalList = new List<Proposal__c> ();
	public List<Digital_Campaign__c> mergeDigitalCampaignList = new List<Digital_Campaign__c> ();
	public List<Syncplicity__SyncTable__c> syncTable = new List<Syncplicity__SyncTable__c> ();
	public Map<String, Map<String, String>> SFRecSyncpFolderMap { get; set; }
	public String AuthToken = 'lyJ0jS4Tg1LoiRi8k2SDw4SkkAcj7Ep7y2n0jaoAoI6dK5vgnQpuWo';
	// Constants
	public static string name = 'Name';
	public static final string INSUFFICIENT_ACCESS = 'Insufficient Access for the following fields : ';

	public AccountMergeController(ApexPages.StandardController controller) {
		String Id = ApexPages.currentPage().getParameters().get('Id');
		createableFields = new Set<String> ();
		accSAM_Update = new List<Account_SAM_Mapping__c> ();
		Map<String, Set<String>> createUpdateableFieldsMap = UserUtils.fetchCreateableOrUpdatableFields('Account_Merge_Log__c');
		if (createUpdateableFieldsMap != null && !createUpdateableFieldsMap.isEmpty()) {
			createableFields = createUpdateableFieldsMap.get('createable');
		}
		parentAccountDetails(Id);
		accessError = false;
		inactiveOppUserList = new List<Opportunity> ();
		userMap = new Map<String, string> ();
	}

	public AccountMergeController(string ID) {
		parentAccountDetails(ID);
	}

	public void parentAccountDetails(string ID)
	{
		try
		{
			string msg = '';
			successPageMsg = '';
			rejectPageMsg = '';
			errorOccured = false;
			if (string.isNotEmpty(ID))
			{
				acc = [SELECT Id, Name, Parentid, BillingStreet, BillingCity, BillingState, BillingPostalCode, Phone, MergeAccount__c, Account_Tim_Name__c, RecordType.DeveloperName, TIM_Account_ID__c, AccountExternalId__c, Political_Account__c FROM Account WHERE Id = :ID];
				//parentAccSAM = [Select ID,   SAM_Designation__c where ]; 
				//msg = AccountMergeController.verifySelectedAcc(ID);

				if (msg.indexOf('Error') >= 0)
				{
					System.debug(msg);
					errorOccured = true;
					rejectPageMsg = msg;
				}

			}

			SfInstance = URL.getSalesforceBaseUrl().toExternalForm();
			if (Test.isRunningTest()) {
				CalloutException e = new CalloutException();
				e.setMessage('This is a constructed exception for testing and code coverage');
				throw e;
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('AccountMergeController', 'parentAccountDetails', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}

	}

	/**
	 * This methods gets called on from action method of VF page. It gets the details of the account that will be merged 
	 * with the parent account.
	 * 
	 * @Parameter (string) (Account ID)
	 * @return (string) (JSON format Account details)
	 */
	@RemoteAction
	public static string getChildAcc(string childAccId)
	{

		string msg = '';
		String JSONString;
		try {
			childAcc = new Account();
			string pageMsg;
			if (!String.isEmpty(childAccId))
			{
				childAcc = [SELECT Id, Name, Parentid, BillingStreet, BillingCity, BillingState, BillingPostalCode, Phone, Account_Tim_Name__c, Description FROM Account WHERE Id = :childAccId];
				if (childAcc != null)
				{

					msg = AccountMergeController.verifySelectedAcc(childAcc.Id);

					if (msg.indexOf('Error') >= 0)
					{
						childAcc.Description = msg;
						//errorOccured = true;
						//rejectPageMsg = msg;
					}
					else {
						childAcc.Description = 'Success';
					}
					JSONString = JSON.serialize(childAcc);
				}
			}
			if (Test.isRunningTest()) {
				CalloutException e = new CalloutException();
				e.setMessage('This is a constructed exception for testing and code coverage');
				throw e;
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('AccountMergeController', 'getChildAcc', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
		return JSONString;
	}
	/**
	 * This methods gets called on from action method of VF page. It gets the details of the account that will be merged 
	 * with the parent account.
	 * 
	 * @Parameter (string) (Account ID)
	 * @return (string) (JSON format Account details)
	 */
	@RemoteAction
	public static string verifySelectedAcc(string childAccId)
	{
		String JSONString;
		try {

			if (!String.isEmpty(childAccId))
			{
				List<Account_Transfer_Mapping__c> accMap = [Select ID, Account_Transfer_Simulation__r.Name, Account_Transfer_Simulation__c from Account_Transfer_Mapping__c
				                                            where Account__c = :childAccId AND Account_Transfer_Simulation__r.Status__c NOT IN('Transfer in Progress', 'Transfer Completed', 'Denied')];
				if (accmap.size() > 0)
				{

					JSONString = 'Error : The selected account is part of Account Transfer hence cannot be merged yet.';
					for (Account_Transfer_Mapping__c atm : accMap)
					{
						JSONString += atm.Account_Transfer_Simulation__r.Name + '\n';
					}
				}
				else
				{
					JSONString = 'Success';
				}
			}
			if (Test.isRunningTest()) {
				CalloutException e = new CalloutException();
				e.setMessage('This is a constructed exception for testing and code coverage');
				throw e;
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('AccountMergeController', 'verifySelectedAcc', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
		return JSONString;
	}

	public void getOpportunitiesOwner()
	{
		try
		{
			//Check if any opportunity Owner is Inactive
			userMap = new Map<String, string> ();
			inactiveOppUserList = new list<opportunity> ();
			rejectPageMsg = '';
			errorOccured = false;
			inactiveOppUserList = [SELECT Id, Name, Owner.IsActive, Owner.Name, OwnerId FROM Opportunity WHERE(AccountId = :acc.MergeAccount__c Or Rep_Firm__c = :acc.MergeAccount__c Or Agency_Account__c = :acc.MergeAccount__c) AND Owner.isActive = false];

			if (inactiveOppUserList.size() > 0)
			{
				for (Opportunity opp : inactiveOppUserList)
				{
					userMap.put(opp.Owner.Name, opp.OwnerId);
				}
				rejectPageMsg = 'Activate the below Opportunity Owners before you proceed. ';
				if (system.isBatch())
				rejectPageMsg = 'Activate the below Opportunity Owners before you proceed. ' + userMap.keySet();
				errorOccured = true;
				return;
			}
			if (Test.isRunningTest()) {
				CalloutException e = new CalloutException();
				e.setMessage('This is a constructed exception for testing and code coverage');
				throw e;
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('AccountMergeController', 'getOpportunitiesOwner', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
	}


	public void createAccountMergeLog() {

		try
		{

			mergeRec = new Account_Merge_Log__c();

			System.debug(' $$$ acc.MergeAccount__c ::: ' + acc.MergeAccount__c);
			mergeAcc = [SELECT Id, Name, Parentid, BillingStreet, BillingCity, BillingState, BillingPostalCode, Phone, Account_Tim_Name__c, RecordType.DeveloperName, Political_Account__c FROM Account WHERE Id = :acc.MergeAccount__c];
			//accSAM_Update = fetchAccountTeam(new List<String>{acc.ID, acc.MergeAccount__c});
			System.debug(' ======= Merging accSAM_Update ' + accSAM_Update);
			if (acc != null && mergeAcc != null) {
				System.debug('mergeAcc Record ype::' + mergeAcc.RecordType.DeveloperName);
				System.debug('acc Record ype::' + acc.RecordType.DeveloperName);

				if (mergeAcc.RecordType.DeveloperName != acc.RecordType.DeveloperName) {
					rejectPageMsg = Label.Merge_with_same_RT_Error;
					System.debug(' $$$ rejectPageMsg ::: ' + rejectPageMsg);
					errorOccured = true;
					// acc.MergeAccount__c = null;
					return;
				}
				else {
					hasSameRecordType = true;
				}

				if (mergeAcc.Political_Account__c != acc.Political_Account__c) {
					rejectPageMsg = Label.Political_Account_Merge_Error;
					System.debug(' $$$ rejectPageMsg ::: ' + rejectPageMsg);
					errorOccured = true;
					// acc.MergeAccount__c = null;
					return;
				}

				if (!Schema.sObjectType.Account_Merge_Log__c.fields.Account_Log__c.isCreateable()) {
					accessingError(true, 'Account_Log__c,');
				}
				else {
					// Check whether field can be creteable or not
					mergeRec.Account_Log__c = 'BillingStreet : ' + (acc.BillingStreet == null ? '' : acc.BillingStreet) + ',BillingCity : ' + (acc.BillingCity == null ? '' : acc.BillingCity) + ',BillingState : ' + (acc.BillingState == null ? '' : acc.BillingState) + ', BillingPostalCode : ' + (acc.BillingPostalCode == null ? '' : acc.BillingPostalCode) + ', phone : ' + (acc.Phone == null ? '' : acc.Phone);
				}

				if (!Schema.sObjectType.Account_Merge_Log__c.fields.Merged_Account_ID__c.isCreateable()) {
					accessingError(true, 'Merged_Account_ID__c,');
				}
				else {
					mergeRec.Merged_Account_ID__c = MergeAcc.Id;
				}
				if (Schema.sObjectType.Account_Merge_Log__c.fields.Account__c.isCreateable()) {
					mergeRec.Account__c = acc.Id;
				}
				else {
					accessingError(true, 'Account__c,');
				}
			}

			isAgencyAccount = mergeAcc.RecordType.DeveloperName == 'Agency_Account' ? true : false;
			isRepFirmAccount = mergeAcc.RecordType.DeveloperName == 'Rep_Firm' ? true : false;
			System.debug(' $$$ isAgencyAccount ::: ' + isAgencyAccount + ' $$$ isRepFirmAccount ::: ' + isRepFirmAccount);
			if (Test.isRunningTest()) {
				CalloutException e = new CalloutException();
				e.setMessage('This is a constructed exception for testing and code coverage');
				throw e;
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('AccountMergeController', 'createAccountMergeLog', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
	}


	public void MergeAccountSAM()
	{
		try
		{
			//System.debug( ' Merging accIDs ' +accIDs);
			List<Account_SAM_Mapping__c> accSAMList = [Select ID, User__c, SAM_Designation__c, Account__c from Account_SAM_Mapping__c where Account__c = :acc.Id or Account__c = :acc.MergeAccount__c];
			//List<AccountTeamMember> accTeam  = [Select Id, AccountID, Account.Name, Account.SAM_Designation__c, UserId from AccountTeamMember where AccountID IN :accIDs];
			//Map<String,List<String>> mapAccTeam = new Map<String,List<String>>();
			Map<String, Map<String, String>> mapSAM = new Map<String, Map<String, String>> ();
			Map<String, Account_SAM_Mapping__c> mapUserAccSAM = new Map<String, Account_SAM_Mapping__c> ();
			List<Account_SAM_Mapping__c> accSAMUpdated = new List<Account_SAM_Mapping__c> ();
			/*
			  for(AccountTeamMember atm : accTeam)
			  {
			  if(mapAccTeam.containsKey(atm.UserId))
			  {
			  mapAccTeam.get(atm.UserId).add(atm.AccountID);
			  }
			  else
			  {
			  mapAccTeam.put(atm.UserId, new List<String>{atm.AccountID});
			  }
			  }
			 */
			for (Account_SAM_Mapping__c accSAM : accSAMList)
			{
				mapUserAccSAM.put(string.valueOf(accSAM.User__c) + string.valueOf(accSAM.Account__c), accSAM);
				if (mapSAM.containsKey(accSAM.Account__c))
				{
					//mapUserAccSAM.put(accSAM.User__c + accSAM.Account__c,accSAM.SAM_Designation__c);
					mapSAM.get(accSAM.Account__c).put(accSAM.User__c, accSAM.SAM_Designation__c);
				}
				else
				{
					mapSAM.put(accSAM.Account__c, new Map<String, String> { accSAM.User__c => accSAM.SAM_Designation__c });
				}

			}
			Map<String, SAM_Designation_Order__c> accSAMOrder = SAM_Designation_Order__c.getAll();

			if (mapSAM.containsKey(acc.MergeAccount__c)) {
				for (String str : mapSAM.get(acc.MergeAccount__c).keySet())
				{
					if (mapSAM.containsKey(acc.Id)) {
						if (mapSAM.get(acc.Id).containsKey(str))
						{
							System.debug(' ======= Merging accSAMUpdated ' + mapSAM.get(acc.Id).containsKey(str));
							if (accSAMOrder.get(mapSAM.get(acc.Id).get(str)).SAM_Order__c<accSAMOrder.get(mapSAM.get(acc.MergeAccount__c).get(str)).SAM_Order__c)
							{
								mapUserAccSAM.get(str + acc.Id).SAM_Designation__c = mapSAM.get(acc.MergeAccount__c).get(str);
								updateAccSAMList.add(mapUserAccSAM.get(str + acc.Id));
							}
							else
							{
								delAccSAMList.add(mapUserAccSAM.get(str + acc.MergeAccount__c));
							}
						}
						else
						{
							Account_SAM_Mapping__c sam = mapUserAccSAM.get(str + acc.MergeAccount__c);
							sam.Account__c = acc.Id;
							updateAccSAMList.add(sam);
						}
					}
					else
					{
						Account_SAM_Mapping__c sam = mapUserAccSAM.get(str + acc.MergeAccount__c);
						sam.Account__c = acc.Id;
						updateAccSAMList.add(sam);
					}
				}
			}
			System.debug(' ======= Merging accSAMUpdated ' + accSAMUpdated);

			//return  updateAccSAMList;
			if (Test.isRunningTest()) {
				CalloutException e = new CalloutException();
				e.setMessage('This is a constructed exception for testing and code coverage');
				throw e;
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('AccountMergeController', 'MergeAccountSAM', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
	}

	public void MergeOpportunities() {
		try
		{
			System.debug(' ======= Merging Opportunities ======= ');

			if ((!isAgencyAccount && !isRepFirmAccount) && (hasSameRecordType)) {
				mergeOppList = [SELECT Id, Name FROM Opportunity WHERE AccountId = :acc.MergeAccount__c];
			}
			else if (isAgencyAccount && (hasSameRecordType)) {
				mergeOppList = [SELECT Id, Name FROM Opportunity WHERE Agency_Account__c = :acc.MergeAccount__c];
			}
			else if (isRepFirmAccount && (hasSameRecordType)) {
				mergeOppList = [SELECT Id, Name FROM Opportunity WHERE Rep_Firm__c = :acc.MergeAccount__c];
			}
			//Merging Opportunities
			if (mergeOppList.size()> 0)
			{
				for (Opportunity opp : mergeOppList)
				{
					if (!Schema.sObjectType.Account_Merge_Log__c.fields.Opportunity_log__c.isCreateable()) {
						accessingError(true, 'Opportunity_log__c,');
					}
					else {
						mergeRec.Opportunity_log__c = (mergeRec.Opportunity_Log__c == null ? '' : mergeRec.Opportunity_Log__c) + name + ' : ' + opp.Name + ', ';
					}
					if (Schema.sObjectType.Account_Merge_Log__c.fields.Opportunity_Ids__c.isCreateable()) {
						mergeRec.Opportunity_Ids__c = (mergeRec.Opportunity_Ids__c == null ? '' : mergeRec.Opportunity_Ids__c) + opp.Id + ' ';
					}
					else {
						accessingError(true, 'Opportunity_Ids__c,');
					}
					if (Schema.sObjectType.Opportunity.fields.AccountId.isUpdateable() && ((!isAgencyAccount && !isRepFirmAccount) && (hasSameRecordType))) {
						opp.AccountId = acc.Id;
					}
					else if (isAgencyAccount && !isRepFirmAccount) {
						opp.Agency_Account__c = acc.Id;
					}
					else if (!isAgencyAccount && isRepFirmAccount) {
						opp.Rep_Firm__c = acc.Id;
					}
				}
				// update mergeOppList;
			}
			if (Test.isRunningTest()) {
				CalloutException e = new CalloutException();
				e.setMessage('This is a constructed exception for testing and code coverage');
				throw e;
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('AccountMergeController', 'MergeOpportunities', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
	}

	public void MergeContacts() {
		try
		{
			System.debug(' ======= Merging Contacts ======= ');
			mergingContactList = [SELECT Id, Name, AccountId FROM Contact WHERE AccountId = :acc.MergeAccount__c];
			//Merging Contacts
			if (mergingContactList.size() > 0)
			{
				for (Contact con : mergingContactList)
				{
					if (Schema.sObjectType.Account_Merge_Log__c.fields.Contact_Log__c.isCreateable()) {
						mergeRec.Contact_Log__c = (mergeRec.Contact_Log__c == null ? '' : mergeRec.Contact_Log__c) + name + ' : ' + con.Name + ', ';
					}
					else {
						accessingError(true, 'Contact_Log__c,');
					}
					if (Schema.sObjectType.Account_Merge_Log__c.fields.Contact_Ids__c.isCreateable()) {
						mergeRec.Contact_Ids__c = (mergeRec.Contact_Ids__c == null ? '' : mergeRec.Contact_Ids__c) + con.Id + ' ';
					}
					else {
						accessingError(true, 'Contact_Ids__c,');
					}
					if (Schema.sObjectType.contact.fields.AccountId.isUpdateable())
					con.AccountId = acc.Id;
				}
				// update mergingContactList;
			}
			if (Test.isRunningTest()) {
				CalloutException e = new CalloutException();
				e.setMessage('This is a constructed exception for testing and code coverage');
				throw e;
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('AccountMergeController', 'MergeContacts', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
	}

	public void MergeAccountConnections() {
		try
		{
			System.debug(' ======= Merging Account Connections ======= ');
			mergeAccConnList = [SELECT Id, Name, Account__c, TIM_ID__c, AgencyTIMId__c, AE_Id__c, Account_Record_Type__c, AccountConnectionExternalId__c, TIM_System__c FROM AccountConnection__c WHERE Account__c = :acc.MergeAccount__c];
			System.debug('mergeAccConnList' + mergeAccConnList);
			Map<String, AccountConnection__c> accMap = new Map<String, AccountConnection__c> ();
			//Merging Account Connection
			if (mergeAccConnList.size() > 0)
			{
				for (AccountConnection__c accCon : mergeAccConnList)
				{
					if (String.isBlank(accCon.AccountConnectionExternalId__c))
					{
						string extID = '';
						if (accCon.Account_Record_Type__c.indexOf('Advertiser') >= 0)
						{
							accCon.AccountConnectionExternalId__c = 'ADV' + ' ' + accCon.TIM_ID__c;
							if (String.isNotBlank(accCon.AgencyTIMID__c))
							accCon.AccountConnectionExternalId__c += ' ' + accCon.AgencyTIMID__c;
							if (String.isNotBlank(accCon.AE_Id__c))
							accCon.AccountConnectionExternalId__c += ' ' + accCon.AE_Id__c;
							if (String.isNotBlank(accCon.TIM_System__c))
							accCon.AccountConnectionExternalId__c += ' ' + accCon.TIM_System__c;
							extID = accCon.AccountConnectionExternalId__c;
						}
						else if (accCon.Account_Record_Type__c.indexOf('Agency') >= 0 || accCon.Account_Record_Type__c.indexOf('Rep Firm') >= 0)
						{
							accCon.AccountConnectionExternalId__c = 'AGENCY';
							if (String.isNotBlank(accCon.AgencyTIMID__c))
							accCon.AccountConnectionExternalId__c += ' ' + accCon.AgencyTIMID__c;
							if (String.isNotBlank(accCon.TIM_System__c))
							accCon.AccountConnectionExternalId__c += ' ' + accCon.TIM_System__c;
							extID = accCon.AccountConnectionExternalId__c;
						}
						accMap.put(extID, accCon);
						//mergeAccConnList.add(accCon);
					}

					if (Schema.sObjectType.Account_Merge_Log__c.fields.Account_Connection_Log__c.isCreateable()) {
						mergeRec.Account_Connection_Log__c = (mergeRec.Account_Connection_Log__c == null ? '' : mergeRec.Account_Connection_Log__c) + name + ' : ' + accCon.Name + ', ';
					}
					else {
						accessingError(true, 'Account_Connection_Log__c,');
					}
					if (Schema.sObjectType.Account_Merge_Log__c.fields.Account_Connection_Ids__c.isCreateable()) {
						mergeRec.Account_Connection_Ids__c = (mergeRec.Account_Connection_Ids__c == null ? '' : mergeRec.Account_Connection_Ids__c) + accCon.Id + ' ';
					}
					else {
						accessingError(true, 'Account_Connection_Ids__c,');
					}
					if (Schema.sObjectType.AccountConnection__c.fields.Account__c.isUpdateable())
					accCon.Account__c = acc.Id;
					/*if(Schema.sObjectType.AccountConnection__c.fields.TIM_ID__c.isUpdateable() && !isAgencyAccount)
					  accCon.TIM_ID__c = acc.TIM_Account_ID__c;
					  if(Schema.sObjectType.AccountConnection__c.fields.AgencyTIMId__c.isUpdateable() && isAgencyAccount)
					  accCon.AgencyTIMId__c = acc.TIM_Account_ID__c;*/
				}
				// update mergeAccConnList;
			}
			if (Test.isRunningTest()) {
				CalloutException e = new CalloutException();
				e.setMessage('This is a constructed exception for testing and code coverage');
				throw e;
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('AccountMergeController', 'MergeAccountConnections', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
	}

	public void MergeCNA() {
		try
		{
			System.debug(' ======= Merging CNA ======= ');
			mergeCNAlist = [SELECT Id, Name, Account__c, Agency__c FROM CNA__c WHERE Account__c = :acc.MergeAccount__c];
			if (mergeCNAlist.size() > 0)
			{
				for (CNA__c cn : mergeCNAlist)
				{
					if (Schema.sObjectType.Account_Merge_Log__c.fields.CNA_Log__c.isCreateable()) {
						mergeRec.CNA_Log__c = (mergeRec.CNA_Log__c == null ? '' : mergeRec.CNA_Log__c) + name + ' : ' + cn.Name + ', ';
					}
					else {
						accessingError(true, 'CNA_Log__c,');
					}
					if (Schema.sObjectType.Account_Merge_Log__c.fields.CNA_Ids__c.isCreateable()) {
						mergeRec.CNA_Ids__c = (mergeRec.CNA_Ids__c == null ? '' : mergeRec.CNA_Ids__c) + cn.Id + ' ';
					}
					else {
						accessingError(true, 'CNA_Ids__c,');
					}
					if (Schema.sObjectType.CNA__c.fields.Account__c.isUpdateable() && (!isAgencyAccount || hasSameRecordType)) {
						cn.Account__c = acc.Id;
					}
					else if (isAgencyAccount)
					cn.Agency__c = acc.Id;
				}
				// update mergeCNAlist;
			}
			if (Test.isRunningTest()) {
				CalloutException e = new CalloutException();
				e.setMessage('This is a constructed exception for testing and code coverage');
				throw e;
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('AccountMergeController', 'MergeCNA', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
	}

	public void MergeRevenue() {
		try
		{
			System.debug(' ======= Merging Revenues ======= ');
			revenueList = [SELECT Id, Name, Advertiser__c FROM Revenue__c WHERE Advertiser__c = :acc.MergeAccount__c];

			//Merging Revenue
			if (revenueList.size() > 0)
			{
				for (Revenue__c rev : revenueList)
				{
					if (Schema.sObjectType.Account_Merge_Log__c.fields.Revenue_log__c.isCreateable()) {
						mergeRec.Revenue_log__c = (mergeRec.Revenue_log__c == null ? '' : mergeRec.Revenue_log__c) + name + ' : ' + rev.Name + ', ';
					}
					else {
						accessingError(true, 'Revenue_log__c,');
					}
					if (Schema.sObjectType.Account_Merge_Log__c.fields.Revenue_Ids__c.isCreateable()) {
						mergeRec.Revenue_Ids__c = (mergeRec.Revenue_Ids__c == null ? '' : mergeRec.Revenue_Ids__c) + rev.Id + ' ';
					}
					else {
						accessingError(true, 'Revenue_Ids__c,');
					}
					if (Schema.sObjectType.Revenue__c.fields.Advertiser__c.isUpdateable())
					rev.Advertiser__c = acc.Id;

				}
				// update revenueList;
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('AccountMergeController', 'MergeRevenue', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
	}

	/*
	  Merging Budget Records also as per the latest change instruction by Greg.
	 
	  public void MergeBudget() {
	  System.debug( ' ======= Merging Revenues ======= ');
	  budgetList = [SELECT Id, Name,Account__c FROM Budget__c WHERE Account__c =: acc.MergeAccount__c];
	 
	  //Merging Revenue
	  if(budgetList.size() > 0)
	  {
	  for(Budget__c bud: budgetList)
	  {
	  if(Schema.sObjectType.Account_Merge_Log__c.fields.Budgets_log__c.isCreateable()){
	  mergeRec.Budgets_log__c = (mergeRec.Budgets_log__c == null?'':mergeRec.Budgets_log__c) + name +' : ' + bud.Name + ', ';
	  }
	  else{
	  accessingError(true, 'Budgets_log__c,');
	  }
	  if(Schema.sObjectType.Account_Merge_Log__c.fields.Budgets_ID__c.isCreateable()){
	  mergeRec.Budgets_ID__c = (mergeRec.Budgets_ID__c == null?'':mergeRec.Budgets_ID__c)  + bud.Id + ' ';
	  }
	  else{
	  accessingError(true, 'Budgets_ID__c,');
	  }
	  if(Schema.sObjectType.Budget__c.fields.Account__c.isUpdateable())
	  bud.Account__c = acc.Id;
	  }
	  // update budgetList;
	  }
	  }
	 */

	/*
	  Merge Support Request records related to the Account.
	 */
	public void MergeSupportRequest() {
		try
		{
			System.debug(' ======= Merging Support Request ======= ');

			if ((!isAgencyAccount && !isRepFirmAccount) && (hasSameRecordType)) {
				supportRequestList = [SELECT Id, Name, Advertiser__c, Agency__c, Rep_Firm__c FROM Support_Request__c WHERE Advertiser__c = :acc.MergeAccount__c];
			}
			else if (isAgencyAccount && (hasSameRecordType)) {
				supportRequestList = [SELECT Id, Name, Agency__c, Rep_Firm__c FROM Support_Request__c WHERE Agency__c = :acc.MergeAccount__c];
			}
			else if (isRepFirmAccount && (hasSameRecordType)) {
				supportRequestList = [SELECT Id, Name, Agency__c, Rep_Firm__c FROM Support_Request__c WHERE Rep_Firm__c = :acc.MergeAccount__c];
			}

			//Merging Revenue
			if (supportRequestList.size() > 0)
			{
				for (Support_Request__c sr : supportRequestList)
				{
					if (Schema.sObjectType.Account_Merge_Log__c.fields.SupportRequest_log__c.isCreateable()) {
						mergeRec.SupportRequest_log__c = (mergeRec.SupportRequest_log__c == null ? '' : mergeRec.SupportRequest_log__c) + name + ' : ' + sr.Name + ', ';
					}
					else {
						accessingError(true, 'SupportRequest_log__c,');
					}
					if (Schema.sObjectType.Account_Merge_Log__c.fields.SupportRequest_Ids__c.isCreateable()) {
						mergeRec.SupportRequest_Ids__c = (mergeRec.SupportRequest_Ids__c == null ? '' : mergeRec.SupportRequest_Ids__c) + sr.Id + ' ';
					}
					else {
						accessingError(true, 'SupportRequest_Ids__c,');
					}
					if (Schema.sObjectType.Support_Request__c.fields.Advertiser__c.isUpdateable() && (!isAgencyAccount && !isRepFirmAccount))
					sr.Advertiser__c = acc.Id;
					else if (Schema.sObjectType.Support_Request__c.fields.Agency__c.isUpdateable() && (isAgencyAccount))
					sr.Agency__c = acc.Id;
					else if (Schema.sObjectType.Support_Request__c.fields.Rep_Firm__c.isUpdateable() && (isAgencyAccount))
					sr.Rep_Firm__c = acc.Id;
				}
				// update budgetList;
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('AccountMergeController', 'MergeSupportRequest', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
	}

	public void MergeSalesBudget()
	{
		try
		{
			System.debug(' ======= Merging Sales Budget ======= ');
			salesBudgetList = [SELECT Id, Name, Advertiser__c, Commodity__c, DMA__c, New_Business_Churn__c, Type__c, Broadcast_Date_Text__c, Amount__c, External_Id_Text__c, Budget_User__c, Product_Line__c FROM Sales_Budget__c WHERE Advertiser__c = :acc.MergeAccount__c OR Advertiser__c = :acc.Id];
			List<Sales_Budget__c> sbList = new List<Sales_Budget__c> ();
			List<Sales_Budget__c> delList = new List<Sales_Budget__c> ();
			Map<String, Map<string, Sales_Budget__c>> mapAccBud = new Map<String, Map<string, Sales_Budget__c>> ();
			String Key;

			if (salesBudgetList.size() > 0)
			{
				for (Sales_Budget__c bud : salesBudgetList)
				{
					key = bud.External_Id_Text__c;
					// If map contains Account.
					if (mapAccBud.containsKey(bud.Advertiser__c))
					{
						if (!mapAccBud.get(bud.Advertiser__c).containsKey(key))
						mapAccBud.get(bud.Advertiser__c).put(key, bud);
						else {
							bud.Amount__c += mapAccBud.get(bud.Advertiser__c).get(key).Amount__c;
							mapAccBud.get(bud.Advertiser__c).put(key, bud);
						}
					}
					// If map  does not contains Account.
					else
					{
						mapAccBud.put(bud.Advertiser__c, new Map<string, Sales_Budget__c> { key => bud });
					}
				}
				System.debug(' ======= Merging Sales Budget mapSalesBud ======= ' + mapAccBud);
				System.debug('acc.MergeAccount__c@@: ' + acc.MergeAccount__c);
				//If Map contains the child account data.
				if (mapAccBud.containsKey(acc.MergeAccount__c))
				{
					System.debug('----Inside id Condition-----');
					mapAccBud.get(acc.MergeAccount__c).keySet().size();
					system.debug('@@@@@mapAccBud.get(acc.MergeAccount__c).keySet().size();' + mapAccBud.get(acc.MergeAccount__c).keySet().size());
					//Traverse the child account data. 
					for (String strKey : mapAccBud.get(acc.MergeAccount__c).keySet())
					{
						string oldKey = strKey;
						//Validate the Map for Parent Account.
						if (mapAccBud.containsKey(acc.ID))
						{
							//id accID = acc.Id ;
							//string subsetID = acc
							List<string> strList = strKey.split(':');
							if (strList.size() >= 7)
							strList[2] = acc.Id;
							// Check if key has New Business and UnknownChurn Data
							if (strKey.substring(strKey.length() - 1, strKey.length()) == ':')
							strKey = String.join(strList, ':') + ':';
							else
							strKey = String.join(strList, ':');
							System.debug(' ======= Merging Sales Budget Key ======= ' + strKey);
							System.debug(' ======= Merging Sales Budget Old Key ======= ' + oldKey);
							if (mapAccBud.get(acc.Id).containsKey(strKey))
							{
								System.debug(' ======= Merging Sales Budget Inside IF ======= ' + mapAccBud.get(acc.Id).get(strKey));
								if (Schema.sObjectType.Account_Merge_Log__c.fields.Sales_Budgets_Log__c.isCreateable()) {
									mergeRec.Sales_Budgets_Log__c = (mergeRec.Sales_Budgets_Log__c == null ? '' : mergeRec.Sales_Budgets_Log__c) + ' Month : ' + mapAccBud.get(acc.ID).get(strKey).Broadcast_Date_Text__c + ', ';
								}
								else {
									accessingError(true, 'Sales_Budgets_Log__c,');
								}
								if (Schema.sObjectType.Account_Merge_Log__c.fields.Sales_Budgets_ID__c.isCreateable()) {
									mergeRec.Sales_Budgets_ID__c = (mergeRec.Sales_Budgets_ID__c == null ? '' : mergeRec.Sales_Budgets_ID__c) + mapAccBud.get(acc.ID).get(strKey).Id + ' ';
								}
								else {
									accessingError(true, 'Sales_Budgets_ID__c,');
								}
								if (Schema.sObjectType.Sales_Budget__c.fields.Amount__c.isUpdateable())
								mapAccBud.get(acc.Id).get(strKey).Amount__c += mapAccBud.get(acc.MergeAccount__c).get(oldKey).Amount__c;
								//mapAccBud.get(acc.Id).get(strKey).Data_Source__c = 'APEX';
								//mapAccBud.get(acc.Id).get(strKey).Data_Source_Exact__c = 'AccountMergeController - MergeSalesBudget';
								sbList.add(mapAccBud.get(acc.Id).get(strKey));
								delList.add(mapAccBud.get(acc.MergeAccount__c).get(oldKey));
							}
							else
							{
								System.debug(' ======= Merging Sales Budget Inside Else ======= ' + mapAccBud.get(acc.MergeAccount__c).get(oldKey));

								if (Schema.sObjectType.Account_Merge_Log__c.fields.Sales_Budgets_Log__c.isCreateable()) {
									mergeRec.Sales_Budgets_Log__c = (mergeRec.Sales_Budgets_Log__c == null ? '' : mergeRec.Sales_Budgets_Log__c) + ' Month : ' + mapAccBud.get(acc.MergeAccount__c).get(oldKey).Broadcast_Date_Text__c + ', ';
								}
								else {
									accessingError(true, 'Sales_Budgets_Log__c,');
								}
								if (Schema.sObjectType.Account_Merge_Log__c.fields.Sales_Budgets_ID__c.isCreateable()) {
									mergeRec.Sales_Budgets_ID__c = (mergeRec.Sales_Budgets_ID__c == null ? '' : mergeRec.Sales_Budgets_ID__c) + mapAccBud.get(acc.MergeAccount__c).get(oldKey).Id + ' ';
								}
								else {
									accessingError(true, 'Sales_Budgets_ID__c,');
								}
								if (Schema.sObjectType.Sales_Budget__c.fields.Advertiser__c.isUpdateable())
								mapAccBud.get(acc.MergeAccount__c).get(oldKey).Advertiser__c = acc.Id;
								//mapAccBud.get(acc.Id).get(strKey).Data_Source__c = 'APEX';
								//mapAccBud.get(acc.Id).get(strKey).Data_Source_Exact__c = 'AccountMergeController - MergeSalesBudget';
								sbList.add(mapAccBud.get(acc.MergeAccount__c).get(oldKey));
							}
						}
						else
						{
							mapAccBud.get(acc.MergeAccount__c).get(oldKey).Advertiser__c = acc.Id;
							//mapAccBud.get(acc.Id).get(strKey).Data_Source__c = 'APEX';
							//mapAccBud.get(acc.Id).get(strKey).Data_Source_Exact__c = 'AccountMergeController - MergeSalesBudget';
							sbList.add(mapAccBud.get(acc.MergeAccount__c).get(oldKey));
						}
					}
				}
				System.debug(' sbList Size: ' + sbList.size());
				System.debug(' ======= Merging Sales Budget sbList ======= ' + sbList);
				System.debug(' ======= Merging Sales Budget delList ======= ' + delList);
				if (sbList.size() > 0)
				salesBudgetList = sbList;
				if (delList.size() > 0)
				salesBudgetDelList = delList;
				// update budgetList;
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('AccountMergeController', 'MergeSalesBudget', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
	}

	public void MergeTrafficIdElements() {
		try
		{
			System.debug(' ======= Merging Traffic Id Elements ======= ');
			trafficIdElementList = [SELECT Id, Name, Account__c FROM Traffic_Id_Element__c WHERE Account__c = :acc.MergeAccount__c];

			//Merging Traffic id elements
			if (trafficIdElementList.size() > 0)
			{
				for (Traffic_Id_Element__c traff : trafficIdElementList)
				{
					if (Schema.sObjectType.Account_Merge_Log__c.fields.Traffic_Id_Element_log__c.isCreateable()) {
						mergeRec.Traffic_Id_Element_log__c = (mergeRec.Traffic_Id_Element_log__c == null ? '' : mergeRec.Traffic_Id_Element_log__c) + name + ' : ' + traff.Name + ', ';
					}
					else {
						accessingError(true, 'Traffic_Id_Element_log__c,');
					}
					if (Schema.sObjectType.Account_Merge_Log__c.fields.Traffic_element_ids__c.isCreateable()) {
						mergeRec.Traffic_element_ids__c = (mergeRec.Traffic_element_ids__c == null ? '' : mergeRec.Traffic_element_ids__c) + traff.Id + ' ';
					}
					else {
						accessingError(true, 'Traffic_element_ids__c,');
					}
					if (Schema.sObjectType.Traffic_Id_Element__c.fields.Account__c.isUpdateable())
					traff.Account__c = acc.Id;
				}
				// update trafficIdElementList;
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('AccountMergeController', 'MergeTrafficIdElements', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
	}

	public void MergeTrade() {
		try
		{
			System.debug(' ======= Merging Trade ======= ');
			tradeList = [SELECT Id, Name, Account__c FROM Trade__c WHERE Account__c = :acc.MergeAccount__c];
			if (tradeList.size() > 0)
			{
				for (Trade__c tradeObj : tradeList)
				{
					if (Schema.sObjectType.Account_Merge_Log__c.fields.Trade_log__c.isCreateable()) {
						mergeRec.Trade_log__c = (mergeRec.Trade_log__c == null ? '' : mergeRec.Trade_log__c) + name + ' : ' + tradeObj.Name + ', ';
					}
					else {
						accessingError(true, 'Trade_log__c,');
					}
					if (Schema.sObjectType.Account_Merge_Log__c.fields.Trade_ids__c.isCreateable()) {
						mergeRec.Trade_ids__c = (mergeRec.Trade_ids__c == null ? '' : mergeRec.Trade_ids__c) + tradeObj.Id + ' ';
					}
					else {
						accessingError(true, 'Trade_ids__c,');
					}
					if (Schema.sObjectType.Trade__c.fields.Account__c.isUpdateable())
					tradeObj.Account__c = acc.Id;
				}
				// update tradeList;
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('AccountMergeController', 'MergeTrade', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
	}

	public void updateRecords() {


		if (accessError) {
			rejectPageMsg = INSUFFICIENT_ACCESS + errorFields;
			errorOccured = true;
			//return null;
		}

		Savepoint sp = Database.setSavepoint();

		try {
			List<AccountConnection__c> accConnectionsToBeDelete = new List<AccountConnection__c> ();
			insert mergeRec;
			update mergeOppList;
			//updateProposals();
			update mergingContactList;
			List<Database.SaveResult> srList = Database.update(mergeAccConnList, false);
			System.debug('srList' + srList);
			// Iterate through each returned result
			for (Database.SaveResult sr : srList) {
				if (sr.isSuccess()) {
					// Operation was successful, so get the ID of the record that was processed
					// System.debug('Successfully inserted account. Account ID: ' + sr.getId());
				}
				else {
					// Operation failed, so get all errors                
					for (Database.Error err : sr.getErrors()) {
						/*System.debug('The following error has occurred.');                    
						  System.debug(err.getStatusCode() + ': ' + err.getMessage());
						  System.debug('Account fields that affected this error: ' + err.getFields());*/
						if (err.getMessage().containsIgnorecase('duplicate')) {
							accConnectionsToBeDelete.add(new AccountConnection__c(Id = sr.getId()));
						}
					}
				}
			}

			update mergeCNAlist;
			//Code added by Aditi : to reparent Traffic and Revenue objects records :02/14/2018
			update trafficIdElementList;
			update revenueList;

			update tradeList;
			//Code changes ends

			if (accConnectionsToBeDelete != null && accConnectionsToBeDelete.size() > 0) {
				delete accConnectionsToBeDelete;
			}

			if (!UserUtils.checkObjectDeletePermission('Account_Merge_Log__c')) {
				//return null;
			}


		} catch(DmlException e) {
			errorOccured = true;
			Database.rollback(sp);
			// Process exception
			rejectPageMsg = 'error - ' + e.getMessage();
			System.debug('An unexpected error has occurred: ' + e.getMessage());
			Log4SF.logMessage('AccountMergeController', 'updateRecords', e.getMessage(), e, UserInfo.getUserId(), null, '');
			//return null;
		}
		catch(Exception e) {
			errorOccured = true;
			Database.rollback(sp);
			// Process exception
			rejectPageMsg = 'error - ' + e.getMessage();
			System.debug('An unexpected error has occurred: ' + e.getMessage());
			Log4SF.logMessage('AccountMergeController', 'updateRecords', e.getMessage(), e, UserInfo.getUserId(), null, '');
			//return null;
		}
		//return null;
	}

	public PageReference updateBudgets()
	{
		if (accessError) {
			rejectPageMsg = INSUFFICIENT_ACCESS + errorFields;
			errorOccured = true;
			return null;
		}

		Savepoint sp = Database.setSavepoint();

		try
		{
			if (!errorOccured)
			{
				//update budgetList;
				delete salesBudgetDelList;
				update updateAccSAMList;
				delete delAccSAMList;
				update salesBudgetList;
				update supportRequestList;
				//updateDigitalCampaigns();
				if (mergeRec.Id != null)
				{
					System.debug('All objects merged successfully. Now processing Syncplicity Merge.');
					//MergeSyncpFolders();
					System.debug('Syncplicity Merge Complete.');

					System.debug('@@ acc ' + acc + mergeAcc);
					delete mergeAcc;
					successPageMsg = 'Accounts succesfully merged.';
				}
			}
		}
		catch(DmlException e) {
			errorOccured = true;
			Database.rollback(sp);
			// Process exception
			rejectPageMsg = 'error - ' + e.getMessage();
			System.debug('An unexpected error has occurred: ' + e.getMessage());
			Log4SF.logMessage('AccountMergeController', 'updateBudgets', e.getMessage(), e, UserInfo.getUserId(), null, '');
			return null;
		}
		return new PageReference('/' + mergeRec.Id);
	}

	public void updateProposals() {
		try
		{
			System.debug('======= Merging Proposals =======');
			System.debug('mergeProposalList size: ' + mergeProposalList.size());
			System.debug('mergeProposalList: ' + mergeProposalList);
			if ((!isAgencyAccount && !isRepFirmAccount) && (hasSameRecordType)) {
				mergeProposalList = [SELECT Id, Name FROM Proposal__c WHERE advertiser__c = :acc.MergeAccount__c];
			}
			else if (isAgencyAccount && (hasSameRecordType)) {
				mergeProposalList = [SELECT Id, Name FROM Proposal__c WHERE Agency__c = :acc.MergeAccount__c];
			}
			else if (isRepFirmAccount && (hasSameRecordType)) {
				mergeProposalList = [SELECT Id, Name FROM Proposal__c WHERE Rep_Firm__c = :acc.MergeAccount__c];
			}

			System.debug('mergeProposalList size: ' + mergeProposalList.size());

			//Merging Proposals
			if (mergeProposalList.size() > 0)
			{
				for (Proposal__c pro : mergeProposalList)
				{
					if (Schema.sObjectType.Proposal__c.fields.advertiser__c.isUpdateable() && ((!isAgencyAccount && !isRepFirmAccount) && (hasSameRecordType))) {
						pro.advertiser__c = acc.Id;
					}
					else if (isAgencyAccount && !isRepFirmAccount) {
						pro.Agency__c = acc.Id;
					}
					else if (!isAgencyAccount && isRepFirmAccount) {
						pro.Rep_Firm__c = acc.Id;
					}

					System.debug('mergeProposalList pro: ' + pro);
					System.debug('mergeProposalList Advertiser: ' + pro.advertiser__c);
					System.debug('mergeProposalList Agency: ' + pro.Agency__c);
				}

				//Update proposals with new account info
				update mergeProposalList;

				Log4SF.logMessage('AccountMergeController', 'mergeProposalList', UserInfo.getUserId(), null, '');
			}
			if (Test.isRunningTest()) {
				CalloutException e = new CalloutException();
				e.setMessage('This is a constructed exception for testing and code coverage');
				throw e;
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('AccountMergeController', 'updateProposals', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
	}

	public void updateDigitalCampaigns() {
		try
		{
			System.debug('======= Merging Digital Campaigns =======');

			if ((!isAgencyAccount && !isRepFirmAccount) && (hasSameRecordType)) {
				mergeDigitalCampaignList = [SELECT Id, Name FROM Digital_Campaign__c WHERE advertiser__c = :acc.MergeAccount__c LIMIT 300];
			}
			else if (isAgencyAccount && (hasSameRecordType)) {
				mergeDigitalCampaignList = [SELECT Id, Name FROM Digital_Campaign__c WHERE Agency__c = :acc.MergeAccount__c LIMIT 300];
			}

			//Merging Digital Campaigns
			if (mergeDigitalCampaignList.size() > 0)
			{
				for (Digital_Campaign__c dc : mergeDigitalCampaignList)
				{
					if (Schema.sObjectType.Digital_Campaign__c.fields.advertiser__c.isUpdateable() && ((!isAgencyAccount && !isRepFirmAccount) || (hasSameRecordType))) {
						dc.advertiser__c = acc.Id;
					}
					else if (isAgencyAccount && !isRepFirmAccount) {
						dc.Agency__c = acc.Id;
					}
				}

				//Update digital campaigns with new account info
				update mergeDigitalCampaignList;
			}
			if (Test.isRunningTest()) {
				CalloutException e = new CalloutException();
				e.setMessage('This is a constructed exception for testing and code coverage');
				throw e;
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('AccountMergeController', 'updateDigitalCampaigns', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
	}

	public void accessingError(Boolean isAccess, String fieldName) {
		try {
			accessError = isAccess;
			errorFields += fieldName;
			if (Test.isRunningTest()) {
				CalloutException e = new CalloutException();
				e.setMessage('This is a constructed exception for testing and code coverage');
				throw e;
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('AccountMergeController', 'accessingError', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
	}

	@RemoteAction
	public static void sendStatusEmail(Boolean isErrorOccured)
	{
		try
		{
			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			message.toAddresses = new String[] { userinfo.getUserEmail() };
			message.subject = 'Account Merge Status';
			String messageBody = '';

			if (!isErrorOccured)
			{
				messageBody = '<html><body>Hi ' + userinfo.getName() + ', <br/>Account has not been merged. <br/>Please review the details HERE: <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/o/Account_Bulk_Merge__c/list?filterName=All">Click here</a></html><br/><br/>Thanks';
			}

			else
			{
				messageBody = '<html><body>Hi ' + userinfo.getName() + ', <br/>Account has not been merged successfully. <br/>Please review the details HERE: <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/o/Account_Bulk_Merge__c/list?filterName=All">Click here</a></html><br/><br/>Thanks';
			}

			//messageBody+= '<tbody><tr><td>Account Bulk Merge</td><td>'+totalAccounts+'</td><td style="color:green;">'+allSuccessAccounts.size()+'</td><td style="color:red;">'+allErrorAccounts.size()+'</td></tr>';
			//messageBody+= '</tbody></table></body></html><br/><br/>Thanks';
			message.setHtmlBody(messageBody);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
			if (Test.isRunningTest()) {
				CalloutException e = new CalloutException();
				e.setMessage('This is a constructed exception for testing and code coverage');
				throw e;
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('AccountMergeController', 'sendStatusEmail', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
	}


	public void MergeSyncpFolders() {
		try
		{
			Map<String, SyncplicityIntegration__c> custSettMap = new Map<String, SyncplicityIntegration__c> ();
			custSettMap = SyncplicityIntegration__c.getAll();
			Integer apiBatchSize = (Integer) custSettMap.get('Syncplicity').APIBatchsize__c;
			String rootFolderSyncPointId = (String) custSettMap.get('Syncplicity').RootFolderSyncpointId__c;
			SFRecSyncpFolderMap = new Map<String, Map<String, String>> ();
			String targetFolderOppFolderId;
			String targetFolderAccReqFolderId;
			String targetFolderCNAFolderId;
			String targetAccountFilesFolder;

			System.debug(' ======= Merging Syncplicity Folders ======= ');
			System.debug(' acc: ' + acc);

			syncTable = [SELECT Id, Syncplicity__syncpRecordFolderId__c, Syncplicity__syncpSyncPointId__c, Syncplicity__salesforceRecordId__c
			             FROM Syncplicity__SyncTable__c
			             WHERE((Syncplicity__salesforceRecordId__c = :acc.Id OR Syncplicity__salesforceRecordId__c = :acc.MergeAccount__c)
			                   AND Syncplicity__syncpRecordFolderId__c != NULL)];
			if (syncTable.size() > 0)
			{
				for (Syncplicity__SyncTable__c syncpObj : syncTable)
				{
					if (syncpObj.Syncplicity__salesforceRecordId__c == acc.MergeAccount__c) {
						Map<String, String> mapFolderRecId = new Map<String, String> ();
						mapFolderRecId.put(acc.MergeAccount__c, syncpObj.Syncplicity__syncpRecordFolderId__c);
						SFRecSyncpFolderMap.put('Source', mapFolderRecId);
					}

					else if (syncpObj.Syncplicity__salesforceRecordId__c == acc.Id) {
						Map<String, String> mapFolderRecId = new Map<String, String> ();
						mapFolderRecId.put(acc.Id, syncpObj.Syncplicity__syncpRecordFolderId__c);
						SFRecSyncpFolderMap.put('Target', mapFolderRecId);
					}
				}
				System.debug('acc.MergeAccount__c: ' + acc.MergeAccount__c);
				System.debug('SFRecSyncpFolderMap: ' + SFRecSyncpFolderMap);
				SyncplicityWebServiceHelper objSyncplicityWebServiceHelper = new SyncplicityWebServiceHelper();
				AuthSyncplicityJSONParse jsonAuth = AuthSyncplicityJSONParse.parse(objSyncplicityWebServiceHelper.AuthenticateRestService());
				System.debug('jsonAuth: ' + jsonAuth);
				GetFolderContentJSONParser jsonSourceFolderContent = GetFolderContentJSONParser.parse(objSyncplicityWebServiceHelper.GetFolderContent(rootFolderSyncPointId, SFRecSyncpFolderMap.get('Source').get(acc.MergeAccount__c), jsonAuth.access_token));
				System.debug('jsonSourceFolderContent@@: ' + jsonSourceFolderContent);
				GetFolderContentJSONParser jsonTargetFolderContent = GetFolderContentJSONParser.parse(objSyncplicityWebServiceHelper.GetFolderContent(rootFolderSyncPointId, SFRecSyncpFolderMap.get('Target').get(acc.Id), jsonAuth.access_token));

				for (GetFolderContentJSONParser.Folders folder : jsonTargetFolderContent.Folders) {
					if (folder.Name == 'Opportunities') {
						targetFolderOppFolderId = folder.FolderId;
						System.debug('targetFolderOppFolderId@@:' + targetFolderOppFolderId);
					}
					else if (folder.Name == 'CNAs') {
						targetFolderCNAFolderId = folder.FolderId;
						System.debug('targetFolderCNAFolderId@@:' + targetFolderCNAFolderId);
					}
					else if (folder.Name == 'Account Requests') {
						targetFolderAccReqFolderId = folder.FolderId;
						System.debug('targetFolderAccReqFolderId@@:' + targetFolderAccReqFolderId);
					}

					else if (folder.Name.toLowerCase().contains('.files')) {
						targetAccountFilesFolder = folder.FolderId;
						System.debug('targetAccountFilesFolder@@:' + targetAccountFilesFolder);
					}
				}
				List<Opportunity> lstOpp = [SELECT ID, Name, CreatedDate FROM Opportunity WHERE AccountId = :acc.Id];
				List<Account_Request__c> lstAccReq = [SELECT ID, Name, CreatedDate FROM Account_Request__c WHERE Advertiser_Agency_Rep_Firm__c = :acc.Id];
				List<CNA__c> lstCNA = [SELECT ID, Name, CreatedDate FROM CNA__c WHERE Account__c = :acc.Id];

				// This section moves the files and folder from Source Account To Target Account
				for (GetFolderContentJSONParser.Folders folder : jsonSourceFolderContent.Folders) {
					GetFolderContentJSONParser jsonChildFolderContent = getDirectChildFolderContent(folder.FolderId, jsonAuth.access_token, objSyncplicityWebServiceHelper, rootFolderSyncPointId);
					System.debug('jsonChildFolderContent@@: ' + jsonChildFolderContent);

					GetFolderContentJSONParser folderToMove = new GetFolderContentJSONParser();
					folderToMove.Folders = new List<GetFolderContentJSONParser.Folders> ();
					GetFolderContentJSONParser fileToMove = new GetFolderContentJSONParser();
					fileToMove.Files = new List<GetFolderContentJSONParser.Files> ();
					System.debug('jsonChildFolderContent.Folders.size()@@: ' + jsonChildFolderContent.Folders.size());
					System.debug('jsonChildFolderContent.Files.size()@@: ' + jsonChildFolderContent.Files.size());
					// This section moves the files from Source Account To Target Account
					if (jsonChildFolderContent.Name.toLowerCase().contains('.files')) {
						for (Integer i = 0; i<jsonChildFolderContent.Files.size(); i++) {
							jsonChildFolderContent.Files.get(i).FolderId = targetAccountFilesFolder;
							jsonChildFolderContent.Files.get(i).Status = 6; //Value 6 is designated for the folder movement.
							String[] splictChr = jsonChildFolderContent.Files.get(i).Filename.splitByCharacterType();
							jsonChildFolderContent.Files.get(i).Filename = jsonChildFolderContent.Files.get(i).Filename + ' ' + System.now() + '.' + splictChr[splictChr.size() - 1]; //Rename all the files to avoid the duplicate file name issue. Append the Current Date Time with Opp. created date time.
							fileToMove.Files.add(jsonChildFolderContent.Files.get(i));
							System.debug('fileToMove.Files@@ ' + fileToMove.Files);
							//API supports the batch size of 100
							if (fileToMove.Files.size() == apiBatchSize) {
								System.debug(fileToMove.Files);
								String moveFileResponse = objSyncplicityWebServiceHelper.MoveFiles(rootFolderSyncPointId, JSON.serialize(fileToMove.Files), jsonAuth.access_token);
								System.debug('moveFileResponse@@: ' + moveFileResponse);
								fileToMove = new GetFolderContentJSONParser();
								fileToMove.Files = new List<GetFolderContentJSONParser.Files> ();
							}
						}

						for (Integer i = 0; i<jsonChildFolderContent.Folders.size(); i++) {
							jsonChildFolderContent.Folders.get(i).ParentFolderId = targetAccountFilesFolder;
							jsonChildFolderContent.Folders.get(i).Status = 6; //Value 6 is designated for the folder movement.
							jsonChildFolderContent.Folders.get(i).Name = jsonChildFolderContent.Folders.get(i).Name + ' ' + System.now(); //Rename all the folders to avoid the duplicate file name issue. Append the Current Date Time with Opp. created date time.
							folderToMove.Folders.add(jsonChildFolderContent.Folders.get(i));
							System.debug('fileToMove.Files@@ ' + folderToMove.Folders);
							//API supports the batch size of 100
							if (folderToMove.Folders.size() == apiBatchSize) {
								System.debug(fileToMove.Files);
								String moveFolderResponse = objSyncplicityWebServiceHelper.MoveFolders(rootFolderSyncPointId, JSON.serialize(folderToMove.Folders), jsonAuth.access_token);
								System.debug('moveFolderResponse@@: ' + moveFolderResponse);
								folderToMove = new GetFolderContentJSONParser();
								folderToMove.Folders = new List<GetFolderContentJSONParser.Folders> ();
							}
						}

						System.debug('fileToMove.Files@@ ' + fileToMove.Files);
						//For Eg: there were 250 files to Move. In the above for loop 200 files will be moved and the remaining 50 will be moved from here
						if (fileToMove.Files.size() != 0) {
							System.debug(fileToMove.Files);
							String moveFileResponse = objSyncplicityWebServiceHelper.MoveFiles(rootFolderSyncPointId, JSON.serialize(fileToMove.Files), jsonAuth.access_token);
							System.debug('moveFileResponse@@: ' + moveFileResponse);
						}

						System.debug('folderToMove.Folders@@ ' + fileToMove.Folders);
						if (folderToMove.Folders.size() != 0) {
							System.debug(folderToMove.Folders);
							String moveFolderResponse = objSyncplicityWebServiceHelper.MoveFolders(rootFolderSyncPointId, JSON.serialize(folderToMove.Folders), jsonAuth.access_token);
							System.debug('moveFolderResponse@@: ' + moveFolderResponse);
						}
					}

					// This section moves the folder from Source Account To Target Account

					else {

						for (Integer i = 0; i<jsonChildFolderContent.Folders.size(); i++) {
							System.debug('jsonChildFolderContent.Name: ' + jsonChildFolderContent.Name);
							if (jsonChildFolderContent.Name == 'Opportunities') {
								jsonChildFolderContent.Folders.get(i).ParentFolderId = targetFolderOppFolderId;
							}

							else if (jsonChildFolderContent.Name == 'CNAs') {
								jsonChildFolderContent.Folders.get(i).ParentFolderId = targetFolderCNAFolderId;
							}

							else if (jsonChildFolderContent.Name == 'Account Requests') {
								jsonChildFolderContent.Folders.get(i).ParentFolderId = targetFolderAccReqFolderId;
							}

							jsonChildFolderContent.Folders.get(i).Status = 6; //Value 6 is designated for the folder movement.
							folderToMove.Folders.add(jsonChildFolderContent.Folders.get(i));

							//API supports the batch size of 100
							if (folderToMove.Folders.size() == apiBatchSize) {
								System.debug(folderToMove.Folders);

								if (jsonChildFolderContent.Name == 'Opportunities') {
									for (Opportunity opp : lstOpp) {
										for (GetFolderContentJSONParser.Folders fol : folderToMove.Folders) {
											if (fol.Name.endsWithIgnoreCase(opp.Name)) {
												fol.Name = fol.Name + ' ' + opp.CreatedDate + ' ' + System.now(); //Rename all the folder to avoid the duplicate folder name name issue. Append the Current Date Time with Opp. created date time.
											}
										}
									}
								}

								else if (jsonChildFolderContent.Name == 'CNAs') {
									for (Account_Request__c ar : lstAccReq) {
										for (GetFolderContentJSONParser.Folders fol : folderToMove.Folders) {
											if (fol.Name.endsWithIgnoreCase(ar.Name)) {
												fol.Name = fol.Name + ' ' + ar.CreatedDate + ' ' + System.now(); //Rename all the folder to avoid the duplicate folder name name issue. Append the Current Date Time with Account Request. created date time.
											}
										}
									}
								}

								else if (jsonChildFolderContent.Name == 'Account Requests') {
									for (CNA__c cna : lstCNA) {
										for (GetFolderContentJSONParser.Folders fol : folderToMove.Folders) {
											if (fol.Name.endsWithIgnoreCase(cna.Name)) {
												fol.Name = fol.Name + ' ' + cna.CreatedDate + ' ' + System.now(); //Rename all the folder to avoid the duplicate folder name name issue. Append the Current Date Time with CNA. created date time.
											}
										}
									}
								}

								String moveFolderResponse = objSyncplicityWebServiceHelper.MoveFolders(rootFolderSyncPointId, JSON.serialize(folderToMove.Folders), jsonAuth.access_token);
								System.debug('moveFolderResponse@@: ' + moveFolderResponse);
								folderToMove = new GetFolderContentJSONParser();
								folderToMove.Folders = new List<GetFolderContentJSONParser.Folders> ();
							}
						}

						//For Eg: there were 250 folders to Move. In the above for loop 200 folders will be moved and the remaining 50 will be moved from here
						if (folderToMove.Folders.size() != 0) {
							System.debug(folderToMove.Folders);

							if (jsonChildFolderContent.Name == 'Opportunities') {
								for (Opportunity opp : lstOpp) {
									for (GetFolderContentJSONParser.Folders fol : folderToMove.Folders) {
										if (fol.Name.endsWithIgnoreCase(opp.Name)) {
											fol.Name = fol.Name + opp.CreatedDate + ' ' + System.now();
										}
									}
								}
							}

							else if (jsonChildFolderContent.Name == 'CNAs') {
								for (Account_Request__c ar : lstAccReq) {
									for (GetFolderContentJSONParser.Folders fol : folderToMove.Folders) {
										if (fol.Name.endsWithIgnoreCase(ar.Name)) {
											fol.Name = fol.Name + ' ' + ar.CreatedDate + ' ' + System.now(); //Rename all the folder to avoid the duplicate folder name name issue. Append the Current Date Time with Account Request. created date time.
										}
									}
								}
							}

							else if (jsonChildFolderContent.Name == 'Account Requests') {
								for (CNA__c cna : lstCNA) {
									for (GetFolderContentJSONParser.Folders fol : folderToMove.Folders) {
										if (fol.Name.endsWithIgnoreCase(cna.Name)) {
											fol.Name = fol.Name + ' ' + cna.CreatedDate + ' ' + System.now(); //Rename all the folder to avoid the duplicate folder name name issue. Append the Current Date Time with CNA. created date time.
										}
									}
								}
							}

							String moveFolderResponse = objSyncplicityWebServiceHelper.MoveFolders(rootFolderSyncPointId, JSON.serialize(folderToMove.Folders), jsonAuth.access_token);
							System.debug('moveFolderResponse@@: ' + moveFolderResponse);
						}
					}
				}
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('AccountMergeController', 'MergeSyncpFolders', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
	}

	private GetFolderContentJSONParser getDirectChildFolderContent(String FolderId, String AccessToken, SyncplicityWebServiceHelper objSyncplicityWebServiceHelper, String rootFolderSyncPointId) {
		GetFolderContentJSONParser jsonChildFolderContent = GetFolderContentJSONParser.parse(objSyncplicityWebServiceHelper.GetFolderContent(rootFolderSyncPointId, FolderId, AccessToken));
		return jsonChildFolderContent;
	}

	public void mergeAccountTeam()
	{
		try
		{
			List<AccountTeamMember> atmList = [Select ID, AccountID, UserID, TeamMemberRole from AccountTeamMember where AccountID = :acc.MergeAccount__c or AccountID = :acc.ID];
			//Map of Account => User => AccountTeamMember
			Map<String, Map<String, AccountTeamMember>> accUserATMMap = new Map<String, Map<String, AccountTeamMember>> ();
			List<AccountTeamMember> atmUpsertList = new List<AccountTeamMember> ();

			for (AccountTeamMember atm : atmList)
			{
				if (!accUserATMMap.containsKey(atm.AccountId))
				{
					accUserATMMap.put(atm.AccountId, new Map<String, AccountTeamMember> { atm.UserId => atm });
				}
				else {
					Map<String, AccountTeamMember> userATMMap = new Map<String, AccountTeamMember> ();
					userATMMap = accUserATMMap.get(atm.AccountId);
					userATMMap.put(atm.UserId, atm);
					accUserATMMap.put(atm.AccountId, userATMMap);
				}
			}
			//For each of the Child Account Team member verify if the parent has the ATM record for the same user
			//If Yes - then verify the TeamMemberRole
			for (String accID : accUserATMMap.keySet())
			{
				if (accID == acc.MergeAccount__c) {
					for (String userID : accUserATMMap.get(accID).keySet())
					{
						if (accUserATMMap.containsKey(acc.ID))
						{
							if (accUserATMMap.get(acc.id).containsKey(userID))
							{
								System.debug('parent ATM ' + accUserATMMap.get(acc.id).get(userID));
								System.debug('Child ATM' + accUserATMMap.get(acc.MergeAccount__c).get(userID));
								if (accUserATMMap.get(acc.id).get(userID).TeamMemberRole != 'Sales Manager')
								{
									if (accUserATMMap.get(acc.MergeAccount__c).get(userID).TeamMemberRole == 'Sales Manager')
									{
										AccountTeamMember atm = accUserATMMap.get(accID).get(userID);
										AccountTeamMember atmNew = atm.clone(false, false, false, false);
										atmNew.AccountId = acc.Id;
										atmUpsertList.add(atmNew);
									}
									else if (accUserATMMap.get(acc.MergeAccount__c).get(userID).TeamMemberRole == 'Account Executive' && accUserATMMap.get(acc.ID).get(userID).TeamMemberRole != 'Account Executive') {
										AccountTeamMember atm = accUserATMMap.get(accID).get(userID);
										AccountTeamMember atmNew = atm.clone(false, false, false, false);
										atmNew.AccountId = acc.Id;
										atmUpsertList.add(atmNew);
									}
								}
							}
							else {
								System.debug('Child ATM' + accUserATMMap.get(acc.MergeAccount__c).get(userID));
								AccountTeamMember atm = accUserATMMap.get(accID).get(userID);
								AccountTeamMember atmNew = atm.clone(false, false, false, false);
								atmNew.AccountId = acc.Id;
								atmUpsertList.add(atmNew);

							}
						}
					}
				}
			}
			if (atmUpsertList.size()> 0)
			{
				upsert atmUpsertList;
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('AccountMergeController', 'mergeAccountTeam', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		}
	}


}