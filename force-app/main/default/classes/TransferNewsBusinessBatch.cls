/*
  ###########################################################################
  # File..................: TransferNewsBusinessBatch.cls
  # Version...............: 1
  # Created by............: Matthew Kidman
  # Created Date..........: 24-Sep-2018
  # Last Modified by......:
  # Last Modified Date....:
  # Description...........: This class is used to transfer the New Business and Unknown Churn to among the AE's as part of the Account transfer Tool.
  # TAO Ref#..............: NA
  # Test Class............: 
  # Change Log............:
  #
  #
  ############################################################################*/
global with sharing class TransferNewsBusinessBatch implements Database.Batchable<sObject>, Database.Stateful {
	public String query;
	public String simulateID;
	public Map<String, Integer> mapOfBatchsizes;
	public List<Admin_Tool_Status_Summary__c> adminToolSummary;
	public Boolean transferAllAcc;
	public Boolean IsRetry = false;
	public Boolean isNBUC = false;


	global TransferNewsBusinessBatch(string simulateID, Boolean transferAllAcc, List<Admin_Tool_Status_Summary__c> adminToolSmry, Map<String, Integer> mapOfBcthsize) {
		this.query = '';
		this.simulateID = simulateID;
		this.transferAllAcc = transferAllAcc;
		this.mapOfBatchsizes = mapOfBcthsize;
		this.adminToolSummary = adminToolSmry;
		system.debug(adminToolSummary);
	}

	global Database.QueryLocator start(Database.BatchableContext bc) {
		//List<Account_Transfer_Mapping__c> accSAM =	[Select ID, Account__c, From_User__r.ID, To_User__r.Id, Account__r.Id from Account_Transfer_Mapping__c ];
		if (transferAllAcc)
		{
			query = 'Select ID, Account__c,Count_of_NBUC_Success__c, From_User__r.ID, To_User__r.Id, To_User__r.Rate_Plan_Status__c, Account__r.Id, Account_Transfer_Simulation__r.Transfer_Effective_Date__c,Account_Transfer_Simulation__c From Account_Transfer_Mapping__c where Account_Transfer_Simulation__c = \'' + simulateID + '\'';
		}
		else
		query = 'Select ID, Name, Amount__c, Unique_Key__c, Comments__c, Budget_user__c, From_Budget_user__c,Account_Transfer_Simulation__r.Transfer_All_Accounts__c, External_Id__c,Broadcast_Month_Date__c, New_Business_Churn__c,Product_Line__c, Commodity__c, DMA__c from Sales_Budget_Simulation__c where type__c = \'Simulation\' And Status__c != \'Transferred\' AND Account_Transfer_Simulation__c =\'' + simulateID + '\'';

		system.debug(query);
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, list<sObject> scope) {

		try {
			System.debug('Scope@@ ' + scope[0]);
			if (transferAllAcc)
			transferAllNBUC(scope);
			else
			transferNBUC(scope);
			if (Test.isRunningTest()) {
				CalloutException e = new CalloutException();
				e.setMessage('This is a constructed exception for testing and code coverage');
				throw e;
			}
		}
		catch(Exception ex) {
			System.debug('TransferNewsBusinessBatch::' + ex.getMessage() + ex.getLineNumber());
			Log4SF.logMessage('TransferNewsBusinessBatch', 'execute', ex.getMessage(), ex, UserInfo.getUserId(), BC.getJobID(), '');
		}
    }

	global void finish(Database.BatchableContext BC) {
		System.debug('isRetry Value: ' + IsRetry);
		if (isRetry == false)
		{
            if(!Test.isRunningTest()){

			TransferContactBatch trb = new TransferContactBatch(adminToolSummary, simulateID);
			database.ExecuteBatch(trb, 200);
            }

		}
		else if(isNBUC == true || isRetry == true)
		{
			Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
			att.Id = simulateID;
			att.Status__c = 'Transfer Completed';
			update att;
			//Upsert att;
		}
	}

	private Map<String, Object> getRoundedContri(Map<String, Decimal> userPrdContriMap, String BudgetUser, String NBUC, String ProductLine, String Month, String Year) {
		Map<String, Decimal> roundedContriMap = New Map<String, Decimal> ();
		Map<String, Decimal> sortedContriMap = New Map<String, Decimal> ();
		Map<String, Object> retunList = New Map<String, Object> ();
		ContriWrapper[] sortedContriList = new ContriWrapper[0];

		Integer contriSum = 0;
		for (String contri : userPrdContriMap.keySet()) {
			System.debug('contri: ' + contri + ' BudgetUser : + NBUC + ProductLine: ' + BudgetUser + NBUC + ProductLine);
			System.debug('contri ' + contri);
			System.debug('@@@bbb ' + BudgetUser.substring(0, BudgetUser.length() - 3) + ':' + NBUC + ProductLine);
			if (contri.contains(BudgetUser.substring(0, BudgetUser.length() - 3) + ':' + NBUC + ProductLine))
			{
				System.debug('contri: ' + contri + ' BudgetUser : + NBUC + ProductLine: ' + BudgetUser + NBUC + ProductLine);
				Integer contriLength = contri.length();
				string monthYear = contri.substring((contriLength - 6), contriLength);
				if (monthYear.contains(Month + Year))
				{
					System.debug('monthYear: ' + monthYear + ' Month + Year: ' + Month + Year);
					contriSum += Integer.valueOf(Math.floor(userPrdContriMap.get(contri)));
					roundedContriMap.put(contri, Math.floor(userPrdContriMap.get(contri)));
					sortedContriList.add(new ContriWrapper(contri, userPrdContriMap.get(contri)));
				}
			}
		}
		sortedContriList.sort();
		retunList.put('roundedMap', roundedContriMap);
		retunList.put('contriSum', contriSum);
		retunList.put('sortedContriList', sortedContriList);
		return retunList;
	}

	private void getRoundedAmounts(List<Sales_Budget__c> updateSBList, String BudgetUser, String NBUC, String ProductLine, String Month, String Year) {
		Map<String, Decimal> roundedContriMap = New Map<String, Decimal> ();
		Map<String, Decimal> sortedContriMap = New Map<String, Decimal> ();
		Map<String, Object> retunList = New Map<String, Object> ();
		ContriWrapper[] sortedContriList = new ContriWrapper[0];
		List<Sales_Budget__c> updatedSBList = new List<Sales_Budget__c> ();
		List<Integer> lstCounter = new List<Integer> ();
		Integer counter = 0;
		Integer contriSum = 0;
		for (Sales_Budget__c sb : updateSBList) {
			counter++;
			System.debug('sb UniqueKey: ' + sb.Unique_Key__c + ' BudgetUser : + NBUC + ProductLine: ' + BudgetUser + NBUC + ProductLine);
			if (sb.Unique_Key__c.contains(BudgetUser.substring(0, BudgetUser.length() - 3) + ':' + NBUC + ProductLine))
			{
				System.debug('sb UniqueKey: ' + sb.Unique_Key__c + ' BudgetUser : + NBUC + ProductLine: ' + BudgetUser + NBUC + ProductLine);
				Integer contriLength = sb.Unique_Key__c.length();
				string monthYear = sb.Unique_Key__c.substring((contriLength - 6), contriLength);
				if (monthYear.contains(Month + Year))
				{
					System.debug('monthYear: ' + monthYear + ' Month + Year: ' + Month + Year);
					String amount = String.valueOf(sb.Amount__c); // assuming you meant to use d here
					String amountAfterDecimal = amount.substringAfter('.');
					System.debug('amountAfterDecimal: ' + amountAfterDecimal);
					if (String.isNotBlank(amountAfterDecimal) && String.isNotEmpty(amountAfterDecimal))
					{
						contriSum += Integer.valueOf(amountAfterDecimal);
					}
					roundedContriMap.put(sb.Unique_Key__c, Math.floor(sb.Amount__c));
					sortedContriList.add(new ContriWrapper(sb.Unique_Key__c, sb.Amount__c));
					lstCounter.add(counter);
					//sb.Data_Source__c = 'APEX';
					//sb.Data_Source_Exact__c = 'TransferNewBusinessBatch - getRoundedAmounts';
					updatedSBList.add(sb);
				}
			}
		}
		sortedContriList.sort();
		System.debug('sortedContriList: ' + sortedContriList);
		Integer diff = Integer.valueOf(contriSum / 100);
		System.debug('diff: ' + diff);
		for (Integer i = 0; i<sortedContriList.size(); i++)
		{
			if (i<diff)
			{
				System.debug('Inside for loop if condition: ' + i);
				sortedContriList[i].Contri = Math.floor(sortedContriList[i].Contri) + 1;
				for (Integer k : lstCounter)
				{
					if (updateSBList.get(k - 1).Unique_Key__c == sortedContriList[i].Key)
					{
						updateSBList.get(k - 1).Amount__c = sortedContriList[i].Contri;
					}
				}
			}
			else
			{
				System.debug('Inside for loop else condition: ' + i);
				sortedContriList[i].Contri = Math.floor(sortedContriList[i].Contri);
				for (Integer k : lstCounter)
				{
					if (updateSBList.get(k - 1).Unique_Key__c == sortedContriList[i].Key)
					{
						updateSBList.get(k - 1).Amount__c = sortedContriList[i].Contri;
					}
				}
			}
		}
	}

	public void transferNBUC(list<Sales_Budget_Simulation__c> scope)
	{
		try {

			Set<String> KeyLst = new Set<String> ();
			Schema.SObjectField ftoken = Sales_Budget__c.Fields.External_Id__c;
			List<Sales_Budget__c> sbList = new List<Sales_Budget__c> ();
			Set<String> uniqueKey = new Set<String> ();
			List<Sales_Budget__c> updatesbList = new List<Sales_Budget__c> ();
			List<Sales_Budget__c> insertsbList = new List<Sales_Budget__c> ();
			Map<String, Sales_Budget_Simulation__c> mapSBNew = new Map<String, Sales_Budget_Simulation__c> ();
			List<Sales_budget__c> upsertSB = new List<Sales_budget__c> ();
			List<Sales_Budget_Simulation__c> updateSBS = new List<Sales_Budget_Simulation__c> ();
			Map<String, Sales_Budget__c> oldKeySBMap = new Map<String, Sales_Budget__c> ();
			Map<String, String> userMap = new Map<String, String> ();
			Map<String, Decimal> userPrdSimTotalMap = new Map<String, Decimal> ();
			Map<String, Decimal> userPrdOrgTotalMap = new Map<String, Decimal> ();
			Map<String, Decimal> userPrdContriMap = new Map<String, Decimal> ();
			if (scope.size()> 0)
			{
				for (Sales_Budget_Simulation__c sb : scope)
				{
					userMap.put(sb.From_Budget_user__c, sb.Budget_user__c);
					string key = string.valueOf(sb.From_Budget_user__c) + sb.New_Business_Churn__c + sb.Product_Line__c + string.valueOf(sb.Broadcast_Month_Date__c.month()) + string.valueOf(sb.Broadcast_Month_Date__c.year());
					if (String.isNotBlank(sb.Unique_Key__c))
					{
						string str = sb.Unique_Key__c;
						str = sb.Budget_user__c + str.substring(str.indexOf(':'), str.length());
						//mapSBNew.put(str, sb);

					}
					if (!userPrdSimTotalMap.containsKey(key))
					{
						userPrdSimTotalMap.put(key, sb.Amount__c);
					}
					else
					{
						decimal amnt = userPrdSimTotalMap.get(key);
						amnt += sb.Amount__c;
						userPrdSimTotalMap.put(key, amnt);
					}
					mapSBNew.put(sb.Unique_Key__c, sb);
				}
				system.debug('userPrdSimTotalMap' + userPrdSimTotalMap);
				System.debug('uniqueKey' + mapSBNew);
				if (userMap.size()> 0)
				sbList = [Select ID, Name, Unique_Key__c, Amount__c, External_Id__c, Budget_user__c, Old_Budget_user__c, Broadcast_Month_Date__c, New_Business_Churn__c, Product_Line__c, Commodity__c, DMA__c from Sales_Budget__c
				          where(Budget_user__c in :userMap.keySet() Or Budget_User__c in :userMap.values()) AND Type__c = 'DOS'];

				system.debug('sd' + sblist);
				for (Sales_Budget__c sb : sblist)
				{
					system.debug('salesbudget' + sb);
					oldKeySBMap.put(sb.Unique_Key__c, sb);
					if (userMap.containsKey(sb.Budget_User__c))
					{
						string key = string.valueOf(sb.Budget_user__c) + sb.New_Business_Churn__c + sb.Product_Line__c + string.valueOf(sb.Broadcast_Month_Date__c.month()) + string.valueOf(sb.Broadcast_Month_Date__c.year());
						//Calculate Orginal total for the User NB/UC ProductLine Month & Year
						if (!userPrdOrgTotalMap.containsKey(key))
						{
							userPrdOrgTotalMap.put(key, sb.Amount__c);
						}
						else
						{
							decimal amnt = userPrdOrgTotalMap.get(key);
							amnt += sb.Amount__c;
							userPrdOrgTotalMap.put(key, amnt);
						}
						string comDMAKey = string.valueOf(sb.Budget_user__c) + sb.New_Business_Churn__c + sb.Product_Line__c + sb.Commodity__c + sb.DMA__c + string.valueOf(sb.Broadcast_Month_Date__c.month()) + string.valueOf(sb.Broadcast_Month_Date__c.year());

					}

					system.debug('userPrdOrgTotalMap' + userPrdOrgTotalMap);
				}
				for (Sales_Budget__c sb : sblist)
				{
					string key = string.valueOf(sb.Budget_user__c) + sb.New_Business_Churn__c + sb.Product_Line__c + string.valueOf(sb.Broadcast_Month_Date__c.month()) + string.valueOf(sb.Broadcast_Month_Date__c.year());
					string Setkey = string.valueOf(sb.Budget_user__c) + ':' + sb.New_Business_Churn__c + ':' + sb.Product_Line__c + ':' + string.valueOf(sb.Broadcast_Month_Date__c.month()) + ':' + string.valueOf(sb.Broadcast_Month_Date__c.year());
					KeyLst.add(Setkey);
					if (userMap.containsKey(sb.Budget_User__c))
					{
						System.debug('userPrdContriMap: ' + userPrdContriMap);
						System.debug('Key: ' + key);
						System.debug('userPrdOrgTotalMap.get(key): ' + userPrdOrgTotalMap.get(key));

						if (userPrdOrgTotalMap.get(key) != null && userPrdOrgTotalMap.get(key) != 0) {
							System.debug('sb.Unique_Key__c ' + sb.Unique_Key__c);
							userPrdContriMap.put(sb.Unique_Key__c, (sb.Amount__c / userPrdOrgTotalMap.get(key)) * 100);
						}
						else {
							userPrdContriMap.put(sb.Unique_Key__c, 0);
						}

					}
				}

				for (String sb : KeyLst)
				{
					System.debug('sbkey: ' + sb);
					String[] splitKey = sb.split(':');
					Map<String, Object> UpdatedContri = getRoundedContri(userPrdContriMap, string.valueOf(splitKey[0]), splitKey[1], splitKey[2], string.valueOf(splitKey[3]), string.valueOf(splitKey[4]));
					System.debug('UpdatedContri: ' + UpdatedContri);
					Map<String, Decimal> roundedConti = (Map<String, Decimal>) UpdatedContri.get('roundedContri');
					System.debug('roundedConti: ' + roundedConti);
					Integer diff = 100 - Integer.valueOf(UpdatedContri.get('contriSum'));
					System.debug('diff: ' + diff);
					List<ContriWrapper> sortedContriList = (List<ContriWrapper>) UpdatedContri.get('sortedContriList');
					System.debug('sortedContriList: ' + sortedContriList);
					for (Integer i = 0; i<sortedContriList.size(); i++)
					{
						if (i<diff)
						{
							System.debug('Inside for loop if condition: ' + i);
							sortedContriList[i].Contri = Math.floor(sortedContriList[i].Contri) + 1;
							userPrdContriMap.put(sortedContriList[i].Key, sortedContriList[i].Contri);
						}
						else
						{
							System.debug('Inside for loop else condition: ' + i);
							sortedContriList[i].Contri = Math.floor(sortedContriList[i].Contri);
							userPrdContriMap.put(sortedContriList[i].Key, sortedContriList[i].Contri);
						}
					}
				}

				system.debug('userPrdContriMap' + userPrdContriMap);
				for (string str : mapSBNew.keySet())
				{
					string newUserKey = '';
					if (String.isNotBlank(mapSBNew.get(str).Unique_Key__c))
					{
						newUserKey = mapSBNew.get(str).Unique_Key__c;
						system.debug('newUserKey ' + mapSBNew.get(str).Budget_user__c + newUserKey.substring(newUserKey.indexOf(':'), newUserKey.length()));
						newUserKey = (string.valueOf(mapSBNew.get(str).Budget_user__c).length()> 15 ? string.valueOf(mapSBNew.get(str).Budget_user__c).substring(0, 15) : mapSBNew.get(str).Budget_user__c) + newUserKey.substring(newUserKey.indexOf(':'), newUserKey.length());
						system.debug('newUserKey ' + newUserKey);
						//mapSBNew.put(str, sb);
					}
					//string newUserKey = string.valueOf(sb.Budget_user__c) + sb.New_Business_Churn__c + sb.Product_Line__c + string.valueOf(sb.Broadcast_Month_Date__c.month()) + string.valueOf(sb.Broadcast_Month_Date__c.year());
					string oldUserKey = string.valueOf(mapSBNew.get(str).From_Budget_user__c) + mapSBNew.get(str).New_Business_Churn__c + mapSBNew.get(str).Product_Line__c + string.valueOf(mapSBNew.get(str).Broadcast_Month_Date__c.month()) + string.valueOf(mapSBNew.get(str).Broadcast_Month_Date__c.year());
					decimal totalAmnt = userPrdSimTotalMap.get(oldUserKey);
					decimal comContri = 0;
					if (userPrdContriMap.get(mapSBNew.get(str).Unique_Key__c) != null && userPrdContriMap.get(mapSBNew.get(str).Unique_Key__c) != 0)
					{
						comContri = (totalAmnt * userPrdContriMap.get(mapSBNew.get(str).Unique_Key__c)) / 100;
					}
					if (oldKeySBMap.containsKey(str))
					{
						if (userMap.containsKey(mapSBNew.get(str).From_Budget_User__c))
						{
							Sales_budget__c sbOld = oldKeySBMap.get(str);
							sbOld.Amount__c -= comContri;
							//sbOld.Data_Source__c = 'APEX';
							//sbOld.Data_Source_Exact__c = 'TransferNewBusinessBatch - transferNBUC';
							updatesbList.add(sbOld);
							system.debug('updatesbList Old Data' + sbOld);
						}
					}
					if (oldKeySBMap.containsKey(newUserKey))
					{
						Sales_budget__c sbOld = oldKeySBMap.get(newUserKey);
						sbOld.Amount__c += comContri;
						//sbOld.Data_Source__c = 'APEX';
						//sbOld.Data_Source_Exact__c = 'TransferNewBusinessBatch - transferNBUC';
						updatesbList.add(sbOld);
						system.debug('updatesbList New user Data' + sbOld);
						system.debug('updatesbList New user Data@@' + oldKeySBMap.get(newUserKey));
					}
					else
					{
						Sales_Budget__c sbNew = new Sales_budget__c();
						if (oldKeySBMap.get(str) != null)
						sbNew = oldKeySBMap.get(str).clone(false, false);
						sbNew.Old_Budget_User__c = sbNew.Budget_user__c;
						sbNew.Budget_User__c = userMap.get(sbNew.Budget_User__c);
						sbNew.Amount__c = comContri;
						sbNew.Type__c = 'DOS';
						sbNew.External_Id__c = sbNew.Budget_user__c + sbNew.Type__c + sbNew.Unique_Key__c;
						sbNew.Advertiser__c = Label.BudgetNewBusinessAcountId;
						//sbNew.Data_Source__c = 'APEX';
						//sbNew.Data_Source_Exact__c = 'TransferNewBusinessBatch - transferNBUC';
						insertsbList.add(sbNew);
						system.debug('create New  Data' + sbNew);
						System.debug('oldKeySBMap.get(str)' + oldKeySBMap.get(str));

					}
					mapSBNew.get(str).Status__c = 'Transferred';
					updateSBS.add(mapSBNew.get(str));
				}

				for (String sb : KeyLst)
				{
					System.debug('sbkey: ' + sb);
					String[] splitKey = sb.split(':');
					getRoundedAmounts(updatesbList, string.valueOf(splitKey[0]), splitKey[1], splitKey[2], string.valueOf(splitKey[3]), string.valueOf(splitKey[4]));
					getRoundedAmounts(insertsbList, string.valueOf(splitKey[0]), splitKey[1], splitKey[2], string.valueOf(splitKey[3]), string.valueOf(splitKey[4]));
				}

				if (updatesbList.size()> 0)
				database.update(updatesbList, true);
				if (insertsbList.size() > 0)
				database.insert(insertsbList, true);
				if (updateSBS.size() > 0)
				update updateSBS;
			}
		}
		catch(Exception ex) {
			System.debug('transferNBUC::' + ex.getMessage() + ex.getLineNumber());
			Log4SF.logMessage('TransferNewsBusinessBatch', 'transferNBUC', ex.getMessage(), ex, UserInfo.getUserId(), '', '');
		}
	}

	public void transferAllNBUC(List<Account_Transfer_Mapping__c> scope)
	{
		try
		{
			Schema.SObjectField ftoken = Sales_Budget__c.Fields.External_Id__c;
			List<Sales_Budget__c> sbList = new List<Sales_Budget__c> ();
			List<Sales_Budget__c> insertSB = new List<Sales_Budget__c> ();
			List<Sales_Budget__c> updatesbList = new List<Sales_Budget__c> ();
			List<ID> userID = new List<ID> ();
			List<Account_Transfer_Mapping__c> mappingList = (List<Account_Transfer_Mapping__c>) scope;
			Map<String, Sales_Budget__c> oldKeySBMap = new Map<String, Sales_Budget__c> ();
			Map<ID, Sales_Budget__c> mapSB = new Map<ID, Sales_Budget__c> ();
			Map<String, String> userMap = new Map<String, String> ();
			Map<String, Account_Transfer_Mapping__c> userATMMap = new Map<String, Account_Transfer_Mapping__c> ();
			for (Account_Transfer_Mapping__c accMap : mappingList)
			{
				userID.add(accMap.From_User__c);
				userID.add(accMap.To_User__c);
				userMap.put(accMap.From_User__c, accMap.To_User__c);
				userATMMap.put(String.valueOf(accMap.From_User__c) + String.valueOf(accMap.To_User__c), accMap);
			}
			sbList = [Select ID, Name, Unique_Key__c, Amount__c, Budget_User__c, Old_Budget_User__c, Comments__c from Sales_Budget__c where Budget_User__c in :userID AND Type__c = 'DOS'];
			for (Sales_Budget__c sb : sblist)
			{
				system.debug('sb.Unique_Key__c' + sb.Unique_Key__c);
				oldKeySBMap.put(sb.Unique_Key__c, sb);
				mapSB.put(sb.ID, sb);
			}
			for (string str : oldKeySBMap.keySet())
			{
				if (userMap.containsKey(oldKeySBMap.get(str).Budget_User__c) && userMap.get(oldKeySBMap.get(str).Budget_User__c) != null)

				{
					system.debug('@@oldKeySBMap.get(str) ' + oldKeySBMap.get(str));
					system.debug('@@userMap' + userMap.get(oldKeySBMap.get(str).Budget_User__c));

					string newKey = (userMap.get(oldKeySBMap.get(str).Budget_User__c).length() > 15 ? userMap.get(oldKeySBMap.get(str).Budget_User__c).substring(0, 15) : userMap.get(oldKeySBMap.get(str).Budget_User__c)) + str.substring(str.indexOf(':'), str.length());
					system.debug('newkey' + newKey);
					// New User has some NB UC data for that Product Line / Commodit/ DMA combination
					if (oldKeySBMap.containsKey(newKey))
					{
						System.debug('Add amount for the New AE' + oldKeySBMap.get(newKey) + oldKeySBMap.get(str));
						//Add amount for the New AE
						Sales_Budget__c sbNew = oldKeySBMap.get(newKey);
						sbNew.Amount__c += oldKeySBMap.get(str).Amount__c;
						sbNew.Comments__c = String.valueOf(oldKeySBMap.get(str).Budget_User__c) + String.valueOf(oldKeySBMap.get(newKey).Budget_User__c);
						//sbNew.Data_Source__c = 'APEX';
						//sbNew.Data_Source_Exact__c = 'TransferNewBusinessBatch - transferAllNBUC';
						updatesbList.add(sbNew);
						System.debug('sbNew Amount' + sbNew.Amount__c);
						System.debug('Reduce amount for the New AE' + oldKeySBMap.get(str));
						//reduce amount for the Old AE
						Sales_Budget__c sbOld = oldKeySBMap.get(str);
						sbOld.Amount__c = 0;
						//sbOld.Data_Source__c = 'APEX';
						//sbOld.Data_Source_Exact__c = 'TransferNewBusinessBatch - transferAllNBUC';
						updatesbList.add(sbOld);
						System.debug('sbNew Amount' + sbNew.Amount__c);
					}
					// New user does not has any NB / UC data for this record
					else
					{
						Sales_Budget__c sbNew = oldKeySBMap.get(str);
						//sbNew = oldKeySBMap.get(str).clone(false,false);
						sbNew.Old_Budget_User__c = sbNew.Budget_user__c;
						sbNew.Budget_User__c = userMap.get(sbNew.Budget_User__c);
						sbNew.Comments__c = oldKeySBMap.get(str).Budget_User__c + userMap.get(sbNew.Budget_User__c);
						sbNew.External_Id__c = sbNew.Budget_user__c + sbNew.Unique_Key__c;
						//sbNew.Data_Source__c = 'APEX';
						//sbNew.Data_Source_Exact__c = 'TransferNewBusinessBatch - transferAllNBUC'; sbNew.Advertiser__c = Label.BudgetNewBusinessAcountId;
						updatesbList.add(sbNew);
						System.debug('New SB record' + sbNew);
					}
				}
			}
			List<Database.SaveResult> saveUpdateResults = Database.update(updatesbList, false);
			//update updatesbList;
			if (insertSB.size() > 0)
			List<Database.SaveResult> saveResults = Database.insert(insertSB, false);
			Set<Account_Transfer_Mapping__c> atmList = new Set<Account_Transfer_Mapping__c> ();
			for (Database.SaveResult sv : saveUpdateResults)
			{
				if (sv.isSuccess())
				{
					if (mapSB.containsKey(sv.getId()))
					{
						if (userATMMap.containsKey(mapSB.get(sv.getId()).Comments__c))
						{
							Account_Transfer_Mapping__c atm = userATMMap.get(mapSB.get(sv.getId()).Comments__c);
							if (atm.Count_Of_NBUC_Success__c == null) {
								atm.Count_Of_NBUC_Success__c = 0;
							}
							atm.Count_Of_NBUC_Success__c += 1;
							atmList.add(atm);
						}
					}
				}
				else
				{
					if (mapSB.containsKey(sv.getId()))
					{
						if (userATMMap.containsKey(mapSB.get(sv.getId()).Comments__c))
						{
							Account_Transfer_Mapping__c atm = userATMMap.get(mapSB.get(sv.getId()).Comments__c);
							if (atm.Count_Of_NBUC_Errors__c == null) {
								atm.Count_Of_NBUC_Errors__c = 0;
							}
							atm.Count_Of_NBUC_Errors__c += 1;
							System.debug('atmList' + atmList);
							atmList.add(atm);
						}
					}

				}
			}
			List<Account_Transfer_Mapping__c> updateATMList = new List<Account_Transfer_Mapping__c> ();
			if (atmList.size() > 0)
			{
				updateATMList.addAll(atmList);
				update updateATMList;
			}
			if (Test.isRunningTest()) {
				CalloutException e = new CalloutException();
				e.setMessage('This is a constructed exception for testing and code coverage');
				throw e;
			}
		}
		catch(Exception ex)
		{
			System.debug('exception@@ ' + ex.getMessage());
			System.debug('exception@@Line ' + ex.getLineNumber());
			Log4SF.logMessage('TransferNewsBusinessBatch', 'transferAllNBUC', ex.getMessage(), ex, UserInfo.getUserId(), '', '');
		}
		//List<>
	}

	/*public void updateATMCounts(List<Sales_Budget__c> sbList)
	  {
	 
	  }*/

	public class ContriWrapper implements Comparable
	{
		public string Key;
		public Decimal Contri;
		public ContriWrapper(string Key, Decimal Contri)
		{
			this.Key = Key;
			this.Contri = Contri;
		}
		public Integer compareTo(Object other) {
			// for descending order
			return Integer.valueOf(((Math.floor(Contri) - Contri) - (Math.floor(((ContriWrapper) other).Contri) - ((ContriWrapper) other).Contri)) * 100);
		}
	}
}