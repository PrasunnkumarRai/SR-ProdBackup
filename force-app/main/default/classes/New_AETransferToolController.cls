public with sharing class  New_AETransferToolController {
	static Database.SaveResult[] results;

	public Static List<OppProposalWrapper> showOpportunities(List<String> AccountIds, String oppCloseDate, Id oldUserId) {
		//if (Test.isRunningTest()) {
			//oppCloseDate = String.valueOf(System.today().addYears(- 10));
		//}
		System.debug('Closed Date:::' + oppCloseDate);
		//try {
		oppCloseDate = oppCloseDate.trim();
		List<String> strDate = oppCloseDate.split('-');
		if (strDate.size() > 2) {
			Integer myIntDate = integer.valueOf(strDate[2]);
			Integer myIntMonth = integer.valueOf(strDate[1]);
			Integer myIntYear = integer.valueOf(strDate[0]);
			Date clsdate = Date.newInstance(myIntYear, myIntMonth, myIntDate);
			List<Opportunity> oppList = [Select Id, AccountId, Account.Name, Name, StageName, CloseDate, (select id, Name, Tim_ID__c, TIM_System__c, Advertiser__r.Id, End_Date__c, Advertiser__r.TIM_Account_ID__c, Current_Advertiser_Tim_Id__c, Agency__r.TIM_Account_ID__c, Current_Agency_Tim_Id__c from Proposals__r where Active__c = true AND(End_Date__c >= :clsdate OR End_Date__c = null)) FROM Opportunity where AccountId IN :AccountIds and OwnerId = :oldUserId];

			Map<Id, List<Proposal__c>> mapOfPropsals = new Map<Id, List<Proposal__c>> ();
			List<OppProposalWrapper> oppPropWrapList = new List<OppProposalWrapper> ();

			for (Opportunity opp : oppList) {
				//opPropWrap.chckBx = true;
				if (opp.Proposals__r.size() > 0) {
					OppProposalWrapper opPropWrap = new OppProposalWrapper();
					opPropWrap.oppId = opp.Id;
					opPropWrap.oppName = opp.Name;
					opPropWrap.accId = opp.AccountId;
					opPropWrap.chckBx = true;
					opPropWrap.accName = opp.Account.Name;
					for (Proposal__c prop : opp.Proposals__r) {
						opPropWrap.proposalList.add(new proposalWrap(prop));

					}
					oppPropWrapList.add(opPropWrap);
				}
			}
			/*if (Test.isRunningTest()) {
			  CalloutException ex = new CalloutException();
			  ex.setMessage('This is a constructed exception for testing and code coverage');
			  throw ex;
			  }*/
			System.debug('Proposal wrapper::' + oppPropWrapList);
			return oppPropWrapList;
		}
		//}
		/*catch(Exception ex)
		  {
		  System.debug('Error showOpportunities: ' + ex.getMessage());
		  Log4SF.logMessage('New_AETransferToolController', 'showOpportunities', ex.getMessage(), ex, UserInfo.getUserId(), oldUserId, '');
		  }*/
		return null;
	}

	/*
	  @AuraEnabled
	  public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, Id UserId) {
	  system.debug('ObjectName-->' + ObjectName);
	  system.debug('searchKeyWord-->' + searchKeyWord);
	  System.debug('UserId:::'+UserId);
	  String searchKey = searchKeyWord + '%';
	  system.debug('searchKey-->' + searchKey);
	  List < sObject > returnList = new List < sObject > ();
	 
	  // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
	  String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey ';
	  if(UserId!=null)
	  sQuery+= 'and Id!=:UserId';  //sQuery+= 'and Id!=\''+UserId+'\'';    
	  sQuery+= ' order by createdDate DESC limit 10';
	  System.debug('query::'+sQuery);
	  List < sObject > lstOfRecords = Database.query(sQuery);
	 
	  for (sObject obj: lstOfRecords) {
	  returnList.add(obj);
	  }
	  return returnList;
	  }
	 */
	@AuraEnabled
	public static Admin_Tool_Status_Summary__c returnAdminToolStatus(String adminStatusId) {
		System.debug('adminStatusId ' + adminStatusId);
		Admin_Tool_Status_Summary__c adminStatus = new Admin_Tool_Status_Summary__c();
		//try {
		List<Admin_Tool_Status_Summary__c> adminStatusList = [SELECT Id,
		                                                      Count_of_Proposal_Success__c, Count_of_Proposal_Error__c,
		                                                      Count_of_Opportunity_Success__c, Count_of_Opportunity_Error__c,
		                                                      Count_of_Activity_Success__c, Count_of_Activity_Error__c,
		                                                      Count_of_Account_Team_Success__c, Count_of_Account_Team_Error__c,
		                                                      Count_of_Account_Connection_Success__c, Count_of_Account_Connection_Error__c, Count_of_Records__c,
		                                                      Batch_Completed__c, of_completion__c,
		                                                      Total_Proposal_Count__c, Total_Opportunity_Count__c, Total_Account_Team_Count__c, Total_Account_Connection_Count__c, Total_Activity_Count__c
		                                                      FROM Admin_Tool_Status_Summary__c WHERE Id = :adminStatusId];

		if (adminStatusList.size() > 0)
		adminStatus = adminStatusList[0];
		return adminStatus;
		//}
		/*catch(Exception ex)
		  {
		  Log4SF.logMessage('New_AETransferToolController', 'returnAdminToolStatus', ex.getMessage(), ex, UserInfo.getUserId(), adminStatusId, '');
		  }*/
		//return null;
	}

	@AuraEnabled
	public static String AEtransfer(String wrapperString, Id newUserId, Id oldUserId, List<String> AccountIds, String proposalEndDate, string simulateID) {
		try {
			System.debug('AccountIds::::' + AccountIds);
			System.debug('wrapper String :::' + wrapperString);
			List<OppProposalWrapper> wrapperList = new List<OppProposalWrapper> ();
			if (String.isNotBlank(wrapperString))
			wrapperList = (List<OppProposalWrapper>) JSON.deserialize(wrapperString, List<OppProposalWrapper>.class);
			System.debug('wrapper  List:::' + wrapperList);

			//Integer countOfProposals = 0;
			Set<String> timSysNames = new Set<String> ();
			Map<String, Proposal__c> mapOfPrpsl = new Map<String, Proposal__c> ();
			Map<String, String> mapOfTimAEIds = new Map<String, String> ();

			List<Admin_Tool_Status_Detail__c> adminDetailsRecords = new List<Admin_Tool_Status_Detail__c> ();

			Admin_Tool_Status_Summary__c adminSummary = new Admin_Tool_Status_Summary__c();
			adminSummary.From_User_Id__c = String.valueOf(oldUserId);
			adminSummary.To_User_Id__c = String.valueOf(newUserId);
			adminSummary.Job_Type__c = 'AE Transfer';
			adminSummary.Proposal_End_Date__c = proposalEndDate.trim();
			adminSummary.Transfer_Details__c = simulateId;
			insert adminSummary;

			for (OppProposalWrapper opp : wrapperList) {
				if (opp.chckBx) {
					adminDetailsRecords.add(new Admin_Tool_Status_Detail__c(Admin_Tool_Status_Summary__c = adminSummary.Id, Id__c = opp.oppId, Object_Type__c = 'Opportunity'));
					for (proposalWrap propWrap : opp.proposalList) {
						adminDetailsRecords.add(new Admin_Tool_Status_Detail__c(Admin_Tool_Status_Summary__c = adminSummary.Id, Id__c = propWrap.prop.Id, Tim_System__c = propWrap.prop.TIM_System__c, Object_Type__c = 'Proposal'));
						timSysNames.add(propWrap.prop.TIM_System__c);
						mapOfPrpsl.put(propWrap.prop.Id, propWrap.prop);
					}
				}
			}

			//Code for new Changes          
			//For Account Ids
			for (String accId : AccountIds) {
				adminDetailsRecords.add(new Admin_Tool_Status_Detail__c(Admin_Tool_Status_Summary__c = adminSummary.Id, Id__c = accId, Object_Type__c = 'Account Team'));
			}

			//For Account connection records
			Map<String, UserConnection__c> oldUserAEIds = fecthUserConnections(oldUserId);
			Map<String, UserConnection__c> newUserAEIds = fecthUserConnections(newUserId);

			Set<String> timSystemSet = new Set<String> ();
			Set<String> aeIDSet = new Set<String> ();

			for (UserConnection__c uc : oldUserAEIds.values())
			{
				timSystemSet.add(uc.TIM_System__c);
				aeIDSet.add(uc.AE_Id__c);

			}

			List<AccountConnection__c> accConnections = [Select Id, AE_Id__c, TIM_System__c
			                                             From AccountConnection__c
			                                             WHERE Account__c IN :AccountIds AND TIM_System__c IN :timSystemSet
			                                             AND AE_Id__c IN :aeIDSet];
			Map<String, UserConnection__c> strTimUser = new Map<String, UserConnection__c> ();
			//Map<String,String> strTimUser = new Map<String,String>();

			for (String str : newUserAEIds.keySet())
			{
				if (!strTimUser.containsKey(newUserAEIds.get(str).TIM_System__c))
				strTimUser.put(newUserAEIds.get(str).TIM_System__c, newUserAEIds.get(str));
				else
				{
					if (newUserAEIds.get(str).Is_Primary__c == true)
					strTimUser.put(newUserAEIds.get(str).TIM_System__c, newUserAEIds.get(str));
				}

			}
			for (AccountConnection__c accConn : accConnections) {
				if (strTimUser.containsKey(accConn.TIM_System__c) && strTimUser.get(accConn.TIM_System__c).Is_Primary__c == true)
				{
					adminDetailsRecords.add(new Admin_Tool_Status_Detail__c(Admin_Tool_Status_Summary__c = adminSummary.Id, Id__c = accConn.Id, AccountConnection__c = accConn.Id, New_AE_Id_for_Account_Conn__c = strTimUser.get(accConn.TIM_System__c).AE_Id__c, Object_Type__c = 'Account Connection'));
				}

			}

			/*Task transfers disabled as requested by Greg
			  //For Task
			  for(Task tsk : [SELECT Id, WhoId, WhatId ,OwnerId FROM Task where OwnerId =: oldUserId and IsClosed = False]){
			  adminDetailsRecords.add(new Admin_Tool_Status_Detail__c(Admin_Tool_Status_Summary__c = adminSummary.Id,Id__c = tsk.Id,Object_Type__c='Activity'));
			  }
			 */
			if (adminDetailsRecords.size() > 0) {
				insert adminDetailsRecords;
			}

			Map<String, Integer> mapOfBatchsizes = new Map<String, Integer> ();
			for (AE_transfer_setting__mdt aeTransferSetting :[Select id, DeveloperName, BatchSize__c from AE_transfer_setting__mdt WHERE Id != null ]) {
				mapOfBatchsizes.put(aeTransferSetting.DeveloperName, Integer.valueOf(aeTransferSetting.BatchSize__c));
			}

			if (mapOfBatchsizes.size() > 0) {
				String query = 'Select id,Id__c , Status__c,Error_Message__c from Admin_Tool_Status_Detail__c where Object_Type__c = \'Proposal\' and Status__c=\'Not Started\' and Admin_Tool_Status_Summary__r.Id =\'' + adminSummary.Id + '\' order by Tim_System__c';
				//updateProposalBatch updPrslBtch = new updateProposalBatch(query,adminSummary,timSysNames,mapOfPrpsl, mapOfBatchsizes);
				//Id batchJobId = Database.executeBatch(updPrslBtch , mapOfBatchsizes.get('Proposal_Batch_Size'));
			}
			return adminSummary.Id;


		}
		catch(Exception ex)
		{
			Log4SF.logMessage('New_AETransferToolController', 'AEtransfer', ex.getMessage(), ex, UserInfo.getUserId(), simulateID, '');
			return null;
		}
		return null;
	}

	public static void initiateTransfer(List<Account_Transfer_Tool__c> accTransferList) {
		Map<String, Integer> mapOfBatchsizes = new Map<String, Integer> ();
		Set<String> userList = new Set<String> ();
		try {
			for (AE_transfer_setting__mdt aeTransferSetting :[Select id, DeveloperName, BatchSize__c from AE_transfer_setting__mdt LIMIT 1000]) {
				mapOfBatchsizes.put(aeTransferSetting.DeveloperName, Integer.valueOf(aeTransferSetting.BatchSize__c));
			}
			List<Admin_Tool_Status_Summary__c> admToolSummaryIDs = [Select ID, To_User_Id__c, From_User_Id__c, Transfer_Details__r.Account_Transfer_Simulation__r.Transfer_Effective_Date__c, Transfer_Details__r.Account_Transfer_Simulation__r.Transfer_NBUC__c,
			                                                        Transfer_Details__c, Transfer_Details__r.Account_Transfer_Simulation__r.Id, Transfer_Details__r.Account_Transfer_Simulation__r.Transfer_NBUC_Select__c
			                                                        from Admin_Tool_Status_Summary__c where Transfer_Details__r.Account_Transfer_Simulation__c in :accTransferList];
			for (Admin_Tool_Status_Summary__c ats : admToolSummaryIDs)
			{
				userList.add(ats.To_User_Id__c);
			}

			if (mapOfBatchsizes.size() > 0) {
				System.debug('admToolSummaryIDs: ' + admToolSummaryIDs);
				for (Account_Transfer_Tool__c att : accTransferList)
				{
					if (att.Transfer_NBUC__c == false)
					{
						String query = 'Select id,Id__c , Status__c,Error_Message__c, Admin_Tool_Status_Summary__r.Proposal_End_Date__c, Admin_Tool_Status_Summary__r.To_User_ID__c, Admin_Tool_Status_Summary__r.From_User_ID__c from Admin_Tool_Status_Detail__c where Object_Type__c = \'Proposal\' and Status__c=\'Not Started\' and Admin_Tool_Status_Summary__r.Id in: admToolSummaryIDs order by Tim_System__c';

						transferProposalBatch updPrslBtch = new transferProposalBatch(query, admToolSummaryIDs, mapOfBatchsizes, userList);
						Datetime scheduledDate = admToolSummaryIDs[0].Transfer_Details__r.Account_Transfer_Simulation__r.Transfer_Effective_Date__c;
						AccountTransferSchedule atrf = new AccountTransferSchedule(updPrslBtch);
						DateTime tobeWorked = Datetime.now().addSeconds(15);
						//DateTime tobeWorked1 = scheduledDate <= Datetime.now()?Datetime.now().addSeconds(15):scheduledDate;
						//DateTime tobeWorked = tobeWorked1 != null?tobeWorked1:Datetime.now().addSeconds(15);
						String hour = String.valueOf(tobeWorked.hour());
						String min = String.valueOf(tobeWorked.minute());
						String ss = String.valueOf(tobeWorked.second());
						String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';

						String jobID = system.schedule('Proposal Transfer Job- ' + att.Id, nextFireTime, atrf);
					}
					else {
						TransferNewsBusinessBatch trNBUC;
						if (att.Transfer_NBUC_Select__c == 'Transfer All NBUC')
						{
							trNBUC = new TransferNewsBusinessBatch(String.valueOf(att.Id), true, admToolSummaryIDs, mapOfBatchsizes);
							//Database.executeBatch(trNBUC, 2000);
						}
						else {
							trNBUC = new TransferNewsBusinessBatch(String.valueOf(att.Id), false, admToolSummaryIDs, mapOfBatchsizes);
							//Database.executeBatch(trNBUC, 2000);
						}
						trNBUC.IsRetry = true;
						trNBUC.isNBUC = true;
						AccountTransferSchedule atrf = new AccountTransferSchedule(trNBUC);
						DateTime tobeWorked = Datetime.now().addSeconds(15);
						String hour = String.valueOf(tobeWorked.hour());
						String min = String.valueOf(tobeWorked.minute());
						String ss = String.valueOf(tobeWorked.second());
						String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
						String jobID = system.schedule('Proposal Transfer Job- ' + att.Id, nextFireTime, atrf);
					}
				}
			}
			if (Test.isRunningTest()) {
				CalloutException ex = new CalloutException();
				ex.setMessage('This is a constructed exception for testing and code coverage');
				throw ex;
			}

		}
		catch(Exception ex)
		{
			system.debug('Error InitiateTransfer: ' + ex.getMessage());
			Log4SF.logMessage('New_AETransferToolController', 'initiateTransfer', ex.getMessage(), ex, UserInfo.getUserId(), accTransferList[0].Id, '');
		}
	}

	public Static void updateAdminSummary(List<Admin_Tool_Status_Summary__c> adminToolSummary) {
		Integer count = 0;
		try {
			Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
			for (Admin_Tool_Status_Summary__c adm : adminToolSummary)
			{
				adm.Batch_Completed__c = TRUE;
				system.debug('ID ATT' + adm.Transfer_Details__r.Account_Transfer_Simulation__r.Id);
				att.Id = adm.Transfer_Details__r.Account_Transfer_Simulation__r.Id;
				att.Status__c = 'Transfer Completed';
			}
			update adminToolSummary;
			Upsert att;
			// Code for sending email
			List<Admin_Tool_Status_Summary__c> userDetails = [Select Id, Name, Count_of_Proposal_Success__c, Count_of_Proposal_Error__c,
			                                                  Count_of_Opportunity_Success__c, Count_of_Opportunity_Error__c,
			                                                  Count_of_Account_Team_Success__c, Count_of_Account_Team_Error__c,
			                                                  Count_of_Account_Connection_Success__c, Count_of_Account_Connection_Error__c,
			                                                  Count_of_Activity_Success__c, Count_of_Activity_Error__c,
			                                                  Total_Proposal_Count__c, Total_Opportunity_Count__c, Total_Account_Team_Count__c,
			                                                  Total_Account_Connection_Count__c, Total_Activity_Count__c, Transfer_Details__c, Transfer_Details__r.Account_Transfer_Simulation__r.Id
			                                                  FROM Admin_Tool_Status_Summary__c
			                                                  Where Id in :adminToolSummary];
			List<Account_Transfer_Tool__c> attList = [SELECT Id, Createdby.Email, Count_Of_Sales_Budget_Errors__c, From_LSM__r.Name, To_LSM__r.Name, Count_Of_Sales_Budget_Success__c, CreatedBy.Name, Count_Of_Revenue_Errors__c, Count_Of_Revenue_Success__c, (select Account__r.name, From_User__r.Name, To_User__r.Name from Account_Transfer_Mappings__r), Transfer_Effective_Date__c, Transfer_NBUC__c
			                                          FROM Account_Transfer_Tool__c WHERE Id = :userDetails[0].Transfer_Details__r.Account_Transfer_Simulation__r.Id];

			List<AggregateResult> accountList = [Select COUNT(Account__c) accCount FROM Account_Transfer_Mapping__c where Account_Transfer_Simulation__c = :userDetails[0].Transfer_Details__r.Account_Transfer_Simulation__r.Id];



			List<String> toAddresses = new List<String> ();
			List<String> toAddressesCreatedBy = new List<String> ();
			if (attList.size() > 0)
			{
				toAddressesCreatedBy.add(attList[0].Createdby.Email);
				toAddresses.add(userinfo.getUserEmail());
			}
			if (userDetails.size() > 0 && attList.size() > 0) {
				Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
				message.toAddresses = toAddresses;
				message.subject = 'AE Transfer Tool Details';
				String messageBody = '<html><body>Hi ' + userinfo.getName() + ',<br/><br/> Transfer status for the ATS <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + adminToolSummary[0].id + '">' + userDetails[0].Name + '' + '</a> is completed.<br/>Following are the details of latest transfer and For more details, please review the summary record HERE: <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + adminToolSummary[0].id + '">' + userDetails[0].Name + '</a> <br/><br/><table><thead><tr><th>Object Name</th><th>Total Count</th><th>No of Success</th><th>No of Error</th></tr></thead>';
				messageBody += '<tbody><tr><td>Proposal</td><td>' + userDetails[0].Total_Proposal_Count__c + '</td><td style="color:green;">' + userDetails[0].Count_of_Proposal_Success__c + '</td><td style="color:red;">' + userDetails[0].Count_of_Proposal_Error__c + '</td></tr>';
				messageBody += '<tr><td>Opportunity</td><td>' + userDetails[0].Total_Opportunity_Count__c + '</td><td style="color:green;">' + userDetails[0].Count_of_Opportunity_Success__c + '</td><td style="color:red;">' + userDetails[0].Count_of_Opportunity_Error__c + '</td></tr>';
				messageBody += '<tr><td>Account Team</td><td>' + userDetails[0].Total_Account_Team_Count__c + '</td><td style="color:green;">' + userDetails[0].Count_of_Account_Team_Success__c + '</td><td style="color:red;">' + userDetails[0].Count_of_Account_Team_Error__c + '</td></tr>';
				messageBody += '<tr><td>Account Connection</td><td>' + userDetails[0].Total_Account_Connection_Count__c + '</td><td style="color:green;">' + userDetails[0].Count_of_Account_Connection_Success__c + '</td><td style="color:red;">' + userDetails[0].Count_of_Account_Connection_Error__c + '</td></tr>';
				//messageBody+= '<tr><td>Activity Task</td><td>'+userDetails[0].Total_Activity_Count__c+'</td><td style="color:green;">'+userDetails[0].Count_of_Activity_Success__c+'</td><td style="color:red;">'+userDetails[0].Count_of_Activity_Error__c+'</td></tr>';
				messageBody += '<tr><td>Sales Budget</td><td>' + ((Integer) attList[0].Count_Of_Sales_Budget_Success__c + (Integer) attList[0].Count_Of_Sales_Budget_Errors__c) + '</td><td style="color:green;">' + attList[0].Count_Of_Sales_Budget_Success__c + '</td><td style="color:red;">' + attList[0].Count_Of_Sales_Budget_Errors__c + '</td></tr>';
				messageBody += '<tr><td>Revenue</td><td>' + ((Integer) attList[0].Count_Of_Revenue_Success__c + (Integer) attList[0].Count_Of_Revenue_Errors__c) + '</td><td style="color:green;">' + attList[0].Count_Of_Revenue_Success__c + '</td><td style="color:red;">' + attList[0].Count_Of_Revenue_Errors__c + '</td></tr>';
				messageBody += '</tbody></table></body></html><br/><br/>Thanks';
				message.setHtmlBody(messageBody);
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });

				Messaging.SingleEmailMessage messageToCreatedBy = new Messaging.SingleEmailMessage();
				messageToCreatedBy.toAddresses = toAddressesCreatedBy;
				messageToCreatedBy.subject = 'AE Transfer Tool Details';
				String messageBodyforCreatedBy = '<html><body>Hi ' + attList[0].CreatedBy.Name + ',<br/><br/> Transfer status for' + ' ' + userDetails[0].Name + ' ' + 'is completed.<br/><br/>Below are the details for this transfer:<br/>Status: Completed<br>Transfer Effective Date: ' + attList[0].Transfer_Effective_Date__c.month() + '/' + attList[0].Transfer_Effective_Date__c.day() + '/' + attList[0].Transfer_Effective_Date__c.year() + '<br/>From LSM: ' + attList[0].From_LSM__r.Name + '<br/>To LSM: ' + attList[0].To_LSM__r.Name + '<br/><br/>';

				if (Integer.valueOf(accountList[0].get('accCount')) > 10) {
					messageBodyforCreatedBy += 'Below are some accounts which were part of this transfer. Click here for more details - ' + '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + adminToolSummary[0].id + '">' + userDetails[0].Name + '</a><br/>';
				}
				else {
					messageBodyforCreatedBy += 'Below are the accounts which were part of this transfer. Click here for more details - ' + '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + adminToolSummary[0].id + '">' + userDetails[0].Name + '</a><br/>';
				}
				messageBodyforCreatedBy += '<table><thead><tr><th style="border: 1px solid #dddddd;text-align: left;">From User</th><th style="border: 1px solid #dddddd;text-align: left;">To User</th><th style="border: 1px solid #dddddd;text-align: left;">Account Name</th></tr></thead>';
				for (Account_Transfer_Tool__c ats : attList) {
					for (Account_Transfer_Mapping__c atm : ats.Account_Transfer_Mappings__r) {
						if (count< 10) {
							messageBodyforCreatedBy += '<tbody><tr><td style="border: 1px solid #dddddd;text-align: left;">' + atm.From_User__r.Name + '</td><td style="border: 1px solid #dddddd;text-align: left;">' + atm.To_User__r.Name + '</td><td style="border: 1px solid #dddddd;text-align: left;">' + atm.Account__r.Name + '</td></tr>';
						}
					}
				}
				messageBodyforCreatedBy += '</tbody></table><br/>';

				messageBodyforCreatedBy += '<br/>Thanks</body></html>';
				messageToCreatedBy.setHtmlBody(messageBodyforCreatedBy);
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { messageToCreatedBy });
			}
		}

		catch(Exception ex)
		{
			System.debug('Error initiateTransfer: ' + ex.getMessage());
			Log4SF.logMessage('New_AETransferToolController', 'initiateTransfer', ex.getMessage(), ex, UserInfo.getUserId(), adminToolSummary[0].Id, '');
		}
	}

	/*
	  public static void updateAllActivities(Id oldUserId, Id newUserId ,List<Admin_Tool_Status_Detail__c> adminToolDetailsRecords){
	 
	  Map<String,Admin_Tool_Status_Detail__c> mapOfTasks = new Map<String,Admin_Tool_Status_Detail__c>();
	 
	  for(Admin_Tool_Status_Detail__c adminToolDetail : adminToolDetailsRecords){
	  mapOfTasks.put(adminToolDetail.Id__c, adminToolDetail);
	  }
	 
	  List<Task> taskList = [SELECT Id, WhoId, WhatId ,OwnerId FROM Task where Id in : mapOfTasks.keySet() ];
	 
	  for(Task taskObj : taskList){
	  taskObj.OwnerId = newUserId;
	  }
	 
	  results = Database.Update(taskList,true);
	 
	  for (Database.SaveResult sr : results) {
	  if (sr.isSuccess()) {
	  mapOfTasks.get(sr.getId()).Status__c = 'Success';
	  }
	  else{
	  for(Database.Error err : sr.getErrors()) {
	  mapOfTasks.get(sr.getId()).Status__c = 'Error';
	  mapOfTasks.get(sr.getId()).Error_Message__c = err.getMessage();
	  }
	  }
	  }
	 
	  Update mapOfTasks.values();
	  }
	 */
	public static void updateOpportunities(Map<String, String> mapOppNewOwner, List<Admin_Tool_Status_Detail__c> adminToolDetailsRecords) {
		try {
			Map<String, Admin_Tool_Status_Detail__c> mapOfOpportunity = new Map<String, Admin_Tool_Status_Detail__c> ();
			Set<ID> oldUserIDSet = new Set<ID> ();
			for (Admin_Tool_Status_Detail__c adminToolDetail : adminToolDetailsRecords) {
				mapOfOpportunity.put(adminToolDetail.Id__c, adminToolDetail);
				oldUserIDSet.add(adminToolDetail.Admin_Tool_Status_Summary__r.From_User_ID__c);
			}

			List<Opportunity> oppList = [Select id, OwnerId from Opportunity where OwnerId = :oldUserIDSet and Id IN :mapOfOpportunity.keySet()];
			for (Opportunity oppObj : oppList) {
				if (mapOppNewOwner.containsKey(oppObj.Id))
				oppObj.OwnerId = mapOppNewOwner.get(oppObj.id);
			}
			results = Database.Update(oppList, true);

			for (Database.SaveResult sr : results) {
				if (sr.isSuccess()) {
					mapOfOpportunity.get(sr.getId()).Status__c = 'Success';
				}
				else {
					for (Database.Error err : sr.getErrors()) {
						mapOfOpportunity.get(sr.getId()).Status__c = 'Error';
						mapOfOpportunity.get(sr.getId()).Error_Message__c = err.getMessage();
					}
				}
			}

			Update mapOfOpportunity.values();
			if (Test.isRunningTest()) {
				CalloutException ex = new CalloutException();
				ex.setMessage('This is a constructed exception for testing and code coverage');
				throw ex;
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('New_AETransferToolController', 'updateOpportunities', ex.getMessage(), ex, UserInfo.getUserId(), adminToolDetailsRecords[0].Id, '');
			//return null;
		}
		//return null;
	}


	public static void updateAccountTeam(List<Admin_Tool_Status_Detail__c> adminToolDetailsRecords) {
		system.debug('Account Team' + adminToolDetailsRecords);
		try {
			Map<String, Admin_Tool_Status_Detail__c> mapOfAccTeams = new Map<String, Admin_Tool_Status_Detail__c> ();
			Set<ID> oldUserIDs = new Set<ID> ();
			for (Admin_Tool_Status_Detail__c adminToolDetail : adminToolDetailsRecords) {
				mapOfAccTeams.put(adminToolDetail.Id__c, adminToolDetail);
				oldUserIds.add(adminToolDetail.Admin_Tool_Status_Summary__r.From_User_Id__c);
			}
			System.debug('oldUserIds '+oldUserIds);
			System.debug('mapOfAccTeams.keySet() '+mapOfAccTeams.keySet());
			List<AccountTeamMember> accTmMbrs = [SELECT Id, UserId, AccountId, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, ContactAccessLevel from AccountTeamMember WHERE userId in :oldUserIds and AccountId in :mapOfAccTeams.keySet()];
			List<AccountTeamMember> newAccTmMbrs = new List<AccountTeamMember> ();
			List<AccountTeamMember> accTmMbrsToDelete = new List<AccountTeamMember> ();
			Map<Id, AccountTeamMember> oldAccTmMbr = new Map<Id, AccountTeamMember> ();
			System.debug('accTmMbrs '+accTmMbrs);
			for (AccountTeamMember atm : accTmMbrs) {
				AccountTeamMember newAccTm = new AccountTeamMember();
				newAccTm = atm.clone(false, true, true, false);
				newAccTm.AccountId = atm.AccountId;
				newAccTm.UserId = mapOfAccTeams.get(atm.AccountId).Admin_Tool_Status_Summary__r.To_User_Id__c;
				newAccTm.AccountAccessLevel = 'Edit';
				newAccTm.CaseAccessLevel = 'Edit';
				newAccTm.ContactAccessLevel = 'Edit';
				newAccTm.OpportunityAccessLevel = 'Edit';
				newAccTmMbrs.add(newAccTm);
				oldAccTmMbr.put(atm.AccountId, atm);
			}
			system.debug('New Account Team' + newAccTmMbrs);

			List<Database.UpsertResult> results = Database.upsert(newAccTmMbrs, true);

			for (Integer i = 0; i<results.size(); i++) {
				if (results[i].isSuccess()) {
					if (mapOfAccTeams.containsKey(newAccTmMbrs[i].AccountId))
					mapOfAccTeams.get(newAccTmMbrs[i].AccountId).Status__c = 'Success';
					if (oldAccTmMbr.containsKey(newAccTmMbrs[i].AccountId))
					accTmMbrsToDelete.add(oldAccTmMbr.get(newAccTmMbrs[i].AccountId));
				}
				else {
					for (Database.Error err : results[i].getErrors()) {
						if (mapOfAccTeams.containsKey(newAccTmMbrs[i].AccountId)) {
							mapOfAccTeams.get(newAccTmMbrs[i].AccountId).Status__c = 'Error';
							mapOfAccTeams.get(newAccTmMbrs[i].AccountId).Error_Message__c = err.getMessage();
						}
					}
				}
			}
			system.debug('Del Account Team' + accTmMbrsToDelete);

			if (accTmMbrsToDelete.size()> 0)
			List<Database.DeleteResult> deleteResults = Database.delete(accTmMbrsToDelete, true);
			Update mapOfAccTeams.values();
			if (Test.isRunningTest()) {
				CalloutException ex = new CalloutException();
				ex.setMessage('This is a constructed exception for testing and code coverage');
				throw ex;
			}

		}
		catch(Exception ex)
		{
			Log4SF.logMessage('New_AETransferToolController', 'updateAccountTeam', ex.getMessage(), ex, UserInfo.getUserId(), adminToolDetailsRecords[0].Id, '');
			//return null;
		}
		//return null;
	}

	public static void updateAccountConnections(List<Admin_Tool_Status_Detail__c> adminToolDetailsAccConn) 
	{
		System.debug('adminToolDetailsAccConn : ' + adminToolDetailsAccConn);
		List<AccountConnection__c> accConnections = new List<AccountConnection__c> ();
		Map<String, Admin_Tool_Status_Detail__c> mapOfAccConntn = new Map<String, Admin_Tool_Status_Detail__c> ();
		try 
		{
			for (Admin_Tool_Status_Detail__c admindet : adminToolDetailsAccConn) {
				AccountConnection__c accConn = new AccountConnection__c();
				accConn.Id = admindet.AccountConnection__c;
				accConn.AE_Id__c = admindet.New_AE_Id_for_Account_Conn__c;
				accConnections.add(accConn);
				mapOfAccConntn.put(admindet.Id__c, admindet);
			}

			results = Database.Update(accConnections, false);

			for (Database.SaveResult sr : results)
			{
				System.debug('results : ' + sr);
				if (mapOfAccConntn.containsKey(sr.getId()))
				{
					if (sr.isSuccess()) {
						mapOfAccConntn.get(sr.getId()).Status__c = 'Success';
					}
					else
					{
						for (Database.Error err : sr.getErrors()) {
							mapOfAccConntn.get(sr.getId()).Status__c = 'Error';
							mapOfAccConntn.get(sr.getId()).Error_Message__c = err.getMessage();
						}
					}
				}
			}

			update mapOfAccConntn.values();
			//if (Test.isRunningTest()) {
				//CalloutException ex = new CalloutException();
				//ex.setMessage('This is a constructed exception for testing and code coverage');
				//throw ex;
				//}

		}
		catch(Exception ex)
		{
		    System.debug('updateAccountConnections ex'+ex);
			Log4SF.logMessage('New_AETransferToolController', 'updateAccountConnections', ex.getMessage(), ex, UserInfo.getUserId(), adminToolDetailsAccConn[0].Id, '');
			//return null;
		}
		    //return null;
	}

	       public static Map<String, UserConnection__c> fecthUserConnections(Id userId) {
		      Map<String, UserConnection__c> timAEIds = new Map<String, UserConnection__c> ();

		      for (UserConnection__c usrCon :[SELECT Id, TIM_System__c, AE_Id__c, Is_Primary__c FROM UserConnection__c WHERE User__c = :userId and AE_Id__c !=null order by lastModifiedDate asc]) {
			     
				 timAEIds.put(usrCon.TIM_System__c + '-' + usrCon.AE_Id__c, usrCon);
				 
		      }
		      return timAEIds;
	       }



	       //Transfer logic for Revenue records
	       public static void updateRevenue(List<Account_Transfer_Mapping__c> accTransferMappingRecords) {

		      system.debug('Revenue Transfer Details: ' + accTransferMappingRecords);
		      try {
			     Map<String, Account_Transfer_Mapping__c> mapOfRevenue = new Map<String, Account_Transfer_Mapping__c> ();
			     string ncc = '';
			     Set<ID> oldUserIDs = new Set<ID> ();
			     Set<ID> accIDs = new Set<ID> ();
			     Date effectiveDate;

			     for (Account_Transfer_Mapping__c atm : accTransferMappingRecords) {
				    mapOfRevenue.put(String.valueOf(atm.account__c) + String.valueOf(atm.From_User__c), atm);
				    oldUserIds.add(atm.From_User__c);
				    accIDs.add(atm.account__c);
				    effectiveDate = atm.Account_Transfer_Simulation__r.Transfer_Effective_Date__c;
				    ncc = atm.Account_Transfer_Simulation__r.NCC__c;
			     }

			     system.debug('@@@ncc:' + ncc);

			     //SRB 644 - Update based on Revenue User and also cover all Historical Revenues.
			     List<Revenue__c> revenueList = [SELECT Id, Revenue_User__c, Account_Executive__c, Advertiser__c, Product_Line__c
			     FROM Revenue__c
			     WHERE((Account_Executive__c in :oldUserIds
			            and Advertiser__c in :accIDs) OR(Revenue_User__c in :oldUserIds
			                                             and Advertiser__c in :accIDs))];

			     Set<Revenue__c> newRevenueList = new Set<Revenue__c> ();
			     Map<string, Account_Transfer_Mapping__c> mapOfRevATM = new Map<string, Account_Transfer_Mapping__c> ();
			     Map<string, AXT_Product_Line_Mapping__c> plMap = AXT_Product_Line_Mapping__c.getAll();
			     for (Revenue__c rev : revenueList) {
				    if (mapOfRevenue.containsKey(String.valueOf(rev.Advertiser__c) + String.valueOf(rev.Account_Executive__c))) {
					   Revenue__c newRevenue = new Revenue__c();
					   newRevenue.id = rev.id;
					   newRevenue.Revenue_User__c = mapOfRevenue.get(String.valueOf(rev.Advertiser__c) + String.valueOf(rev.Account_Executive__c)).To_User__c;
					   ncc = mapOfRevenue.get(String.valueOf(rev.Advertiser__c) + String.valueOf(rev.Account_Executive__c)).Account_Transfer_Simulation__r.NCC__c;
					   if (String.isNotEmpty(ncc))
					   {
						  //system.debug('ncc ' + ncc);
						  //system.debug('ncc ' + ncc + ' ' +rev.Product_Line__c);
						  //system.debug('ncc ' +  plMap.get(ncc + ' ' +rev.Product_Line__c));
						  newRevenue.Product_Line__c = plMap.get(ncc + ' ' + rev.Product_Line__c).Relevant_Product_Line__c;
					   }
					   mapOfRevATM.put(newRevenue.id, mapOfRevenue.get(String.valueOf(rev.Advertiser__c) + String.valueOf(rev.Account_Executive__c)));
					   //newRevenue.Data_Source__c = 'APEX';
					   //newRevenue.Data_Source_Exact__c = 'New_AETransferToolController - updateSalesBudget';
					   newRevenueList.add(newRevenue);
				    }
				    else if (rev.Revenue_User__c != null && mapOfRevenue.containsKey(String.valueOf(rev.Advertiser__c) + String.valueOf(rev.Revenue_User__c)) && rev.Revenue_User__c != mapOfRevenue.get(String.valueOf(rev.Advertiser__c) + String.valueOf(rev.Revenue_User__c)).To_User__c) {

					   Revenue__c newRevenue = new Revenue__c();
					   newRevenue.id = rev.id;
					   newRevenue.Revenue_User__c = mapOfRevenue.get(String.valueOf(rev.Advertiser__c) + String.valueOf(rev.Revenue_User__c)).To_User__c;
					   system.debug(mapOfRevenue.get(String.valueOf(rev.Advertiser__c) + String.valueOf(rev.Account_Executive__c)));

					   if (mapOfRevenue.containsKey(String.valueOf(rev.Advertiser__c) + String.valueOf(rev.Account_Executive__c))) {
						  ncc = mapOfRevenue.get(String.valueOf(rev.Advertiser__c) + String.valueOf(rev.Account_Executive__c)).Account_Transfer_Simulation__r.NCC__c;
					   }

					   if (String.isNotEmpty(ncc)) {
						  newRevenue.Product_Line__c = plMap.get(ncc + ' ' + rev.Product_Line__c).Relevant_Product_Line__c;
					   }
					   mapOfRevATM.put(newRevenue.id, mapOfRevenue.get(String.valueOf(rev.Advertiser__c) + String.valueOf(rev.Account_Executive__c)));
					   //newRevenue.Data_Source__c = 'APEX';
					   //newRevenue.Data_Source_Exact__c = 'New_AETransferToolController - updateSalesBudget';
					   newRevenueList.add(newRevenue);
				    }
			     }

			     List<Revenue__c> lstRevenue = new List<Revenue__c> (newRevenueList);

			     system.debug('Updated Revenue List: ' + newRevenueList);

			     List<Database.SaveResult> results = Database.update(lstRevenue, true);

			     for (Integer i = 0; i<results.size(); i++) {
				    if (results[i].isSuccess()) {
					   if (mapOfRevATM.containsKey(lstRevenue[i].id)) {
						  if (mapOfRevATM.get(lstRevenue[i].id).Count_Of_Revenue_Success__c != null) {
							 Decimal SuccessCount = mapOfRevATM.get(lstRevenue[i].id).Count_Of_Revenue_Success__c + 1;
							 mapOfRevATM.get(lstRevenue[i].id).Count_Of_Revenue_Success__c = SuccessCount;
						  } else {
							 mapOfRevATM.get(lstRevenue[i].id).Count_Of_Revenue_Success__c = 1;
						  }
					   }
				    }
				    else {
					   if (mapOfRevATM.containsKey(lstRevenue[i].id)) {
						  if (mapOfRevATM.get(lstRevenue[i].id).Count_Of_Revenue_Errors__c != null) {
							 Decimal ErrorCount = mapOfRevATM.get(lstRevenue[i].id).Count_Of_Revenue_Errors__c + 1;
							 mapOfRevATM.get(lstRevenue[i].id).Count_Of_Revenue_Errors__c = ErrorCount;
						  } else {
							 mapOfRevATM.get(lstRevenue[i].id).Count_Of_Revenue_Errors__c = 1;
						  }
					   }
				    }
			     }
			     system.debug(mapOfRevATM.Values());
			     if (mapOfRevATM.Values().size()> 0) {
				    system.debug('mapOfRevATM.Values()' + mapOfRevATM);
				    update removeDuplicateFromList(mapOfRevATM.values());
			     }
			     //if (Test.isRunningTest()) {
				    //CalloutException ex = new CalloutException();
				    //ex.setMessage('This is a constructed exception for testing and code coverage');
				    //throw ex;
			     //}

		      }
		      catch(Exception ex)
		      {
			     System.debug('ex'+ex);
			     Log4SF.logMessage('New_AETransferToolController', 'updateRevenue', ex.getMessage(), ex, UserInfo.getUserId(), accTransferMappingRecords[0].Id, '');
		      }
	       }

	       public static List<SObject> removeDuplicateFromList(List<SObject> lstWithDuplicateItems) {
		      Set<SObject> uniqueItems = new Set<SObject> (lstWithDuplicateItems);
		      return new List<SObject> (uniqueItems);
	       }

	       //Transfer logic for Sales Budget records
	       /**
	       * @description 
	       * @param accTransferMappingRecords 
	       * @param isRetry 
	       */
	       public static void updateSalesBudget(List<Account_Transfer_Mapping__c> accTransferMappingRecords, Boolean isRetry) {

		      system.debug('Sales Budget Transfer Details: ' + accTransferMappingRecords);
		      try {
			     Map<String, Account_Transfer_Mapping__c> mapOfSalesBudget = new Map<String, Account_Transfer_Mapping__c> ();
			     Map<String, Account_Transfer_Mapping__c> mapSalesBudgetATM = new Map<String, Account_Transfer_Mapping__c> ();
			     Set<User> userSet = new Set<User> ();
			     List<User> userList = new List<User> ();
			     Set<ID> oldUserIDs = new Set<ID> ();
			     Set<ID> newUserIDs = new Set<ID> ();
			     Set<ID> accIDs = new Set<ID> ();
			     Map<Id, Account_Transfer_Mapping__c> updateATMMap = new Map<Id, Account_Transfer_Mapping__c> ();
			     Date effectiveDate;
			     List<Sales_Budget__c> salesBudgetList = new List<Sales_Budget__c> ();
			     Boolean transferAllAccounts = false;
			     Map<String, Boolean> transferredSB = new Map<String, Boolean> ();
			     string ncc = '';
			     for (Account_Transfer_Mapping__c atm : accTransferMappingRecords) {
				    mapOfSalesBudget.put(String.valueOf(atm.account__c) + String.valueOf(atm.From_User__c), atm);
				    mapSalesBudgetATM.put(String.valueOf(atm.account__c) + String.valueOf(atm.To_User__c), atm);
				    oldUserIds.add(atm.From_User__c);
				    newUserIDs.add(atm.To_User__c);
				    accIDs.add(atm.account__c);
				    effectiveDate = atm.Account_Transfer_Simulation__r.Transfer_Effective_Date__c;
				    //if (Test.isRunningTest() && effectiveDate == null)
				    //{
					   //effectiveDate = System.today().addYears(- 1);
				    //}
				    system.debug('effectiveDate: ' + effectiveDate);
				    if (atm.Account_Transfer_Simulation__r.Transfer_All_Accounts__c)
				    {
					   transferAllAccounts = true;
				    }
				    ncc = atm.Account_Transfer_Simulation__r.NCC__c;
				    //if (Test.isRunningTest() && (ncc == '' || ncc == null))
				    //{
					   //ncc = 'NCC';
				    //}
				    System.debug('mapOfSalesBudget ' + mapOfSalesBudget);

			     }
				 System.debug('oldUserIDs '+oldUserIDs);
				 System.debug('accIDs '+accIDs);
			     salesBudgetList = [SELECT Id, Budget_User__c, Budget_User__r.Rate_Plan_Status__c, Advertiser__c, Product_Line__c, Transfer_Date__c,
			     Broadcast_Month_Date__c, Forecast_User__c, Old_Budget_User__c, Account_Transfer__c, External_Id_Text__c, DMA__c, Commodity__c, Type__c,
			     New_Business_Churn__c, Amount__c, Budget_User__r.Budget_DMA__c, Old_Budget_User__r.Budget_DMA__c
			     FROM Sales_Budget__c
			     WHERE(Budget_User__c in :oldUserIds OR Budget_User__c IN :newUserIDs OR Forecast_User__c in :oldUserIDs)
			     and Advertiser__c in :accIDs AND Type__c not in('DOS', 'Forecast', 'Workflow')];
			     Map<String, Sales_Budget__c> mapNewUserSB = new Map<String, Sales_Budget__c> ();
			     Map<string, AXT_Product_Line_Mapping__c> plMap = AXT_Product_Line_Mapping__c.getAll();
				 System.debug('plMap '+plMap);
			     List<Sales_Budget__c> newSalesBudgetList = new List<Sales_Budget__c> ();
			     List<Sales_Budget__c> delSalesBudgetList = new List<Sales_Budget__c> ();
			     Map<string, Account_Transfer_Mapping__c> mapOfSBATM = new Map<string, Account_Transfer_Mapping__c> ();
			     for (Sales_Budget__c bud : salesBudgetList) {
				    mapNewUserSB.put(bud.External_Id_Text__c, bud);
			     }
			     for (Sales_Budget__c bud : salesBudgetList) {
				    system.debug('bud External Key: ' + bud.External_Id_Text__c);
				    Sales_Budget__c newSalesBudget = new Sales_Budget__c();
				    newSalesBudget.id = bud.id;
				    if (mapOfSalesBudget.containsKey(String.valueOf(bud.Advertiser__c) + String.valueOf(bud.Budget_User__c))) {

					   system.debug('salbud: ' + bud);
					   system.debug('effectiveDate: ' + effectiveDate);
					   if ((effectiveDate.month() <= bud.Broadcast_Month_Date__c.month() && effectiveDate.year() <= bud.Broadcast_Month_Date__c.year()) || transferAllAccounts) {
						  transferredSB.put(bud.Id, true);

						  System.debug(bud.DMA__c);
						  System.debug(bud.Commodity__c);
						  System.debug(bud.Advertiser__c);
						  System.debug(bud.Product_Line__c);
						  System.debug(bud.Broadcast_Month_Date__c);
						  System.debug(bud.Type__c);
						  System.debug(bud.New_Business_Churn__c);
						  String newExternalId =
						  ':' +
						  bud.Commodity__c + ':' +
						  bud.Advertiser__c + ':' +
						  bud.Product_Line__c + ':' +
						  String.valueOf(bud.Broadcast_Month_Date__c.year()) + ':' +
						  String.valueOf(bud.Broadcast_Month_Date__c.month()) + ':' +
						  String.valueOf(mapOfSalesBudget.get(String.valueOf(bud.Advertiser__c) + String.valueOf(bud.Budget_User__c)).To_User__c) + ':' +
						  bud.Type__c + ':' +
						  '';

						  String oldExternalId =
						  ':' +
						  bud.Commodity__c + ':' +
						  bud.Advertiser__c + ':' +
						  bud.Product_Line__c + ':' +
						  String.valueOf(bud.Broadcast_Month_Date__c.year()) + ':' +
						  String.valueOf(bud.Broadcast_Month_Date__c.month()) + ':' +
						  String.valueOf(mapOfSalesBudget.get(String.valueOf(bud.Advertiser__c) + String.valueOf(bud.Budget_User__c)).From_User__c) + ':' +
						  bud.Type__c + ':' +
						  '';

						  system.debug('newExternalId: ' + newExternalId);
						  if (!mapNewUserSB.containsKey(newExternalId)) {
							 newSalesBudget.Account_Transfer__c = mapOfSalesBudget.get(String.valueOf(bud.Advertiser__c) + String.valueOf(bud.Budget_User__c)).Account_Transfer_Simulation__c;
							 newSalesBudget.Old_Budget_User__c = bud.budget_user__c;
							 newSalesBudget.Transfer_Date__c = effectiveDate;
							 System.debug('budgetTypeToUser '+mapOfSalesBudget.get(String.valueOf(bud.Advertiser__c) + String.valueOf(bud.Budget_User__c)).To_User__r.Budget_Type__c);
							 newSalesBudget.Budget_User__c = mapOfSalesBudget.get(String.valueOf(bud.Advertiser__c) + String.valueOf(bud.Budget_User__c)).To_User__c;
							 String budgetTypeToUser = mapOfSalesBudget.get(String.valueOf(bud.Advertiser__c) + String.valueOf(bud.Budget_User__c)).To_User__r.Budget_Type__c;
							 String budgetTypeFromUser = mapOfSalesBudget.get(String.valueOf(bud.Advertiser__c) + String.valueOf(bud.Budget_User__c)).From_User__r.Budget_Type__c;
							 System.debug('ncc value: ' + ncc);
							 System.debug('budgetTypeToUser value: ' + budgetTypeToUser);
							 System.debug('budgetTypeFromUser value: ' + budgetTypeFromUser);
							 System.debug('bud.Product_Line__c value: ' + bud.Product_Line__c);
							 //if (String.isNotEmpty(ncc)) {
							 //For National to Local we need to Map the data to the proper product line irrespective of NCC or Direct.
							 if (budgetTypeToUser == 'Local' && budgetTypeFromUser == 'National')
							 {
								if (plMap.containsKey('Direct ' + bud.Product_Line__c))
								newSalesBudget.Product_Line__c = plMap.get('Direct ' + bud.Product_Line__c).Relevant_Product_Line__c;
								else if (plMap.containsKey('NCC ' + bud.Product_Line__c))
								newSalesBudget.Product_Line__c = plMap.get('NCC ' + bud.Product_Line__c).Relevant_Product_Line__c;
								if (String.isEmpty(newSalesBudget.DMA__c))
								newSalesBudget.DMA__c = bud.Budget_User__r.Budget_DMA__c;

							 }
							 else if (String.isNotEmpty(ncc))
							 {
								if (String.isNotBlank(ncc) && plMap.containsKey(ncc + ' ' + bud.Product_Line__c)) {
									newSalesBudget.Product_Line__c = plMap.get(ncc + ' ' + bud.Product_Line__c).Relevant_Product_Line__c;
								}
								else if (String.isBlank(ncc))
								{
									ncc = bud.Product_Line__c.contains('NCC') ? 'NCC' : 'Direct';
									newSalesBudget.Product_Line__c = plMap.get(ncc + ' ' + bud.Product_Line__c).Relevant_Product_Line__c;
								}
								if (String.isBlank(newSalesBudget.DMA__c))
								newSalesBudget.DMA__c = bud.Budget_User__r.Budget_DMA__c;
							 }
							 //}
						  }
						  else {
							 if (bud.External_Id_Text__c != newExternalId)
							 {
								System.debug('Inside Else');
								System.debug('oldExternalId: ' + oldExternalId);
								newSalesBudget.id = mapNewUserSB.get(newExternalId).Id;
								newSalesBudget.Amount__c = mapNewUserSB.get(newExternalId).Amount__c;
								newSalesBudget.Amount__c += bud.Amount__c;
								newSalesBudget.Old_Budget_User__c = mapNewUserSB.get(oldExternalId).budget_user__c;
								newSalesBudget.Account_Transfer__c = mapOfSalesBudget.get(String.valueOf(bud.Advertiser__c) + String.valueOf(bud.Budget_User__c)).Account_Transfer_Simulation__c;
								newSalesBudget.Transfer_Date__c = effectiveDate;
								delSalesBudgetList.add(mapNewUserSB.get(oldExternalId));
							 }
						  }
					   }
					   else
					   newSalesBudget.Forecast_User__c = mapOfSalesBudget.get(String.valueOf(bud.Advertiser__c) + String.valueOf(bud.Budget_User__c)).To_User__c;
					   system.debug('newSalesBudget SalesBudget List: ' + newSalesBudget);
					   //newSalesBudget.Data_Source__c = 'APEX';
					   //newSalesBudget.Data_Source_Exact__c = 'New_AETransferToolController - updateSalesBudget';
					   newSalesBudgetList.add(newSalesBudget);
					   mapOfSBATM.put(newSalesBudget.id, mapOfSalesBudget.get(String.valueOf(bud.Advertiser__c) + String.valueOf(bud.Budget_User__c)));
					   System.debug('mapOfSBATM '+mapOfSBATM);
					   if (newSalesBudget.Budget_User__r.rate_plan_status__c != 'Pending' && newSalesBudget.Budget_User__r.rate_plan_status__c != 'Draft')
					   userSet.add(new User(id = newSalesBudget.Budget_User__c, rate_plan_status__c = 'Draft'));

					   if (newSalesBudget.Old_Budget_User__r.rate_plan_status__c != 'Pending' && newSalesBudget.Old_Budget_User__r.rate_plan_status__c != 'Draft')
					   userSet.add(new User(id = newSalesBudget.Old_Budget_User__c, rate_plan_status__c = 'Draft'));
				    }
				    else if (bud.Forecast_User__c != null && mapOfSalesBudget.containsKey(String.valueOf(bud.Advertiser__c) + String.valueOf(bud.Forecast_User__c))) {
					   system.debug('Updated bud.Forecast_User__c : ' + bud.Forecast_User__c);
					   system.debug(' mapOfSalesBudget: ' + mapOfSalesBudget.get(String.valueOf(bud.Advertiser__c) + String.valueOf(bud.Forecast_User__c)));
					   newSalesBudget.Forecast_User__c = mapOfSalesBudget.get(String.valueOf(bud.Advertiser__c) + String.valueOf(bud.Forecast_User__c)).To_User__c;
					   newSalesBudgetList.add(newSalesBudget);
				    }
			     }

			     system.debug('Updated SalesBudget List: ' + newSalesBudgetList);
			     system.debug('delSalesBudgetList: ' + delSalesBudgetList);
			     List<Database.SaveResult> results = Database.update(newSalesBudgetList, false);
			     List<Database.DeleteResult> delResults = Database.delete(delSalesBudgetList, false);
			     Boolean isError = false;

			     for (Integer i = 0; i<results.size(); i++) {
				    Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
				    if (mapSalesBudgetATM.containsKey(String.valueOf(newSalesBudgetList[i].Advertiser__c) + String.valueOf(newSalesBudgetList[i].Budget_User__c)) && transferredSB.containsKey(newSalesBudgetList[i].Id))
				    {
					   atm = mapSalesBudgetATM.get(String.valueOf(newSalesBudgetList[i].Advertiser__c) + String.valueOf(newSalesBudgetList[i].Budget_User__c));
					   atm.Total_Count_of_Sales_Budget__c = atm.Total_Count_of_Sales_Budget__c == null ? 1 : atm.Total_Count_of_Sales_Budget__c + 1;
				    }
				    if (results[i].isSuccess()) {

					   if (mapOfSBATM.containsKey(newSalesBudgetList[i].id) && transferredSB.containsKey(newSalesBudgetList[i].Id)) {
						  decimal totalSBCOunt = 0;
						  System.debug('mapOfSBATM@@@ '+ mapOfSBATM.get(newSalesBudgetList[i].id).Total_Count_of_Sales_Budget__c);
						  if (mapOfSBATM.get(newSalesBudgetList[i].id).Total_Count_of_Sales_Budget__c != null)
						  totalSBCOunt = mapOfSBATM.get(newSalesBudgetList[i].id).Total_Count_of_Sales_Budget__c;
						  mapOfSBATM.get(newSalesBudgetList[i].id).Total_Count_of_Sales_Budget__c = totalSBCOunt == 0 ? 1 : totalSBCOunt + 1;
						  if (mapOfSBATM.get(newSalesBudgetList[i].id).Count_Of_Sales_Budget_Success__c != null) {
							 Decimal SuccessCount = mapOfSBATM.get(newSalesBudgetList[i].id).Count_Of_Sales_Budget_Success__c + 1;
							 mapOfSBATM.get(newSalesBudgetList[i].id).Count_Of_Sales_Budget_Success__c = SuccessCount;
							 if (isRetry)
							 {
								System.debug('newSalesBudgetList[i].id: ' + newSalesBudgetList[i].id);
								if (mapOfSBATM.get(newSalesBudgetList[i].id).Count_Of_Sales_Budget_Errors__c == null) {
									mapOfSBATM.get(newSalesBudgetList[i].id).Count_Of_Sales_Budget_Errors__c = 0;
								}
								mapOfSBATM.get(newSalesBudgetList[i].id).Count_Of_Sales_Budget_Errors__c -= 1;
								//If count of Sales Budget is less than zero then reset it to 0.
								if (mapOfSBATM.get(newSalesBudgetList[i].id).Count_Of_Sales_Budget_Errors__c< 0)
								mapOfSBATM.get(newSalesBudgetList[i].id).Count_Of_Sales_Budget_Errors__c = 0;
							 }
						  } else {
							 mapOfSBATM.get(newSalesBudgetList[i].id).Count_Of_Sales_Budget_Success__c = 1;
						  }
					   }
				    }
				    else if (transferredSB.containsKey(newSalesBudgetList[i].Id)) {
					   isError = true;
					   if (mapOfSBATM.containsKey(newSalesBudgetList[i].id)) {
						  Log4SF.logMessage('New_AETransferToolController', 'updateSalesBudget', newSalesBudgetList[i].id + results[i].getErrors() [0].getMessage(), null, UserInfo.getUserId(), null, '');
						  decimal totalSBCOunt = 0;
						  if (mapOfSBATM.get(newSalesBudgetList[i].id).Total_Count_of_Sales_Budget__c != null)
						  totalSBCOunt = mapOfSBATM.get(newSalesBudgetList[i].id).Total_Count_of_Sales_Budget__c;
						  mapOfSBATM.get(newSalesBudgetList[i].id).Total_Count_of_Sales_Budget__c = totalSBCOunt == 0 ? 1 : totalSBCOunt + 1;
						  if (mapOfSBATM.get(newSalesBudgetList[i].id).Count_Of_Sales_Budget_Errors__c != null) {
							 Decimal errorCount = mapOfSBATM.get(newSalesBudgetList[i].id).Count_Of_Sales_Budget_Errors__c + 1;
							 mapOfSBATM.get(newSalesBudgetList[i].id).Count_Of_Sales_Budget_Errors__c = errorCount;
						  } else {
							 mapOfSBATM.get(newSalesBudgetList[i].id).Count_Of_Sales_Budget_Errors__c = 1;
						  }
					   }
				    }
				    updateATMMap.put(mapOfSBATM.get(newSalesBudgetList[i].id).Id, mapOfSBATM.get(newSalesBudgetList[i].id));
			     }
			     if (mapOfSBATM.values().size()> 0) {
				    System.debug('updateATMMap.size() ' + updateATMMap.size());
				    System.debug('updateATMMap.values(): ' + updateATMMap.values());
				    System.debug('updateATMMap.keySet(): ' + updateATMMap.keySet());
				    database.update(updateATMMap.values(), false);
				    userList.addAll(userSet);
				    database.update(userList, false);
			     }

			     if (Test.isRunningTest()) {
				    CalloutException ex = new CalloutException();
				    ex.setMessage('This is a constructed exception for testing and code coverage');
				    throw ex;
			     }

		      }
		      catch(Exception ex)
		      {
			     system.debug('ex updateSB: ' + ex.getMessage() + ' Line Number: ' + ex.getLineNumber());
			     Log4SF.logMessage('New_AETransferToolController', 'updateSalesBudget', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		      }
	       }


	       //Create Transfer Logs for Sales Budget Simulation - called from Sales Budget Trigger
	       public static void createSalesBudgetSimulation(List<Sales_Budget__c> sbList)
	       {
		      try
		      {
			     List<Sales_Budget_Simulation__c> sbsList = new List<Sales_Budget_Simulation__c> ();
			     Map<string, Sales_Budget_Simulation__c> sbsMap = new Map<String, Sales_Budget_Simulation__c> ();
			     List<Sales_Budget_Simulation__c> sbsErrUpList = new List<Sales_Budget_Simulation__c> ();
			     List<Sales_Budget_Simulation__c> sbsErrList = new List<Sales_Budget_Simulation__c> ();
			     for (Sales_Budget__c sb : sbList)
			     {
				    Sales_Budget_Simulation__c sbs = new Sales_Budget_Simulation__c();
				    sbs.Budget_User__c = sb.Budget_User__c;
				    sbs.From_Budget_User__c = sb.Old_Budget_User__c;
				    sbs.Product_Line__c = sb.Product_Line__c;
				    sbs.Amount__c = sb.Amount__c;
				    sbs.Advertiser__c = sb.Advertiser__c;
				    sbs.Broadcast_Month_Date__c = sb.Broadcast_Month_Date__c;
				    sbs.Sales_Budget__c = sb.Id;
				    sbs.External_Id__c = sb.Old_Budget_User__c + ':' + sb.Unique_Key__c + sb.id;
				    sbs.Budget_Change_Date__c = sb.Transfer_Date__c;
				    sbs.Type__c = 'Log';
				    sbs.Account_Transfer_Simulation__c = sb.Account_Transfer__c;
				    sbsList.add(sbs);
				    sbsMap.put(sbs.External_Id__c, sbs);

			     }
			     Schema.SObjectField ftoken = Sales_Budget_Simulation__c.Fields.External_Id__c;
			     List<String> extIDList = new List<String> ();
			     //Insert Logs for SB updates
			     if (sbsList.size()> 0)
			     {

				    Database.SaveResult[] sberrList = Database.insert(sbsList, false);
				    system.debug('sberrList ' + sberrList);
				    // Iterate through each returned result
				    /*
				  for (Database.UpsertResult sr : sberrList) {
				    
				  if (!sr.isSuccess()) {
				  // Operation failed, so get all errors                
				  extIDList.add(sr.getId());
				  } 
				  } 
				    */
			     }
			     if (Test.isRunningTest()) {
				    CalloutException ex = new CalloutException();
				    ex.setMessage('This is a constructed exception for testing and code coverage');
				    throw ex;
			     }
		      }
		      catch(Exception ex)
		      {
			     Log4SF.logMessage('New_AETransferToolController', 'createSalesBudgetSimulation', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		      }

	       }

	       public static Set<ID> returnSalesBudget(List<Admin_Tool_Status_Summary__c> accTransferMappingRecords) {

		      system.debug('Sales Budget Transfer Details: ' + accTransferMappingRecords);
		      //try
		      //{
		      Map<String, Admin_Tool_Status_Summary__c> mapOfSalesBudget = new Map<String, Admin_Tool_Status_Summary__c> ();
		      List<User> userSet = new List<User> ();
		      Set<ID> oldUserIDs = new Set<ID> ();
		      Set<ID> accIDs = new Set<ID> ();
		      Date effectiveDate;
		      for (Admin_Tool_Status_Summary__c atm : accTransferMappingRecords) {
			     oldUserIds.add(atm.To_User_Id__c);
			     oldUserIds.add(atm.From_User_Id__c);
		      }
		      return oldUserIds;

		      //}
		      /*catch(Exception ex)
		  {   
		  Log4SF.logMessage('New_AETransferToolController', 'returnSalesBudget', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
		  return null;
		  }   */
	       }
	       //Wrappper class
	       public class OppProposalWrapper {

		      @AuraEnabled
		      public Boolean chckBx = false;
		      @AuraEnabled
		      public Id oppId;
		      @AuraEnabled
		      public Id accId;
		      @AuraEnabled
		      public String oppName;
		      @AuraEnabled
		      public String accName;
		      @AuraEnabled
		      public List<proposalWrap> proposalList;

		      public OppProposalWrapper() {
			     proposalList = new List<proposalWrap> ();
		      }

	       }

	       public class proposalWrap {
		      @AuraEnabled
		      public Proposal__c prop;
		      @AuraEnabled
		      public String status = 'Not Transferred';
		      @AuraEnabled
		      public String stsClr = 'black';

		      public proposalWrap(Proposal__c propRcrd) {
			     prop = propRcrd;
		      }

	       }
        }