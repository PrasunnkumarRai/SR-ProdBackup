/*
  ###########################################################################
  # File..................: BudgetAutomation.cls
  # Version...............: 1
  # Created by............: Matthew Kidman
  # Created Date..........: 6-Dec-2019
  # Last Modified by......:
  # Last Modified Date....:
  # Description...........: This class is contains the Budget Automation Backend Logic
  # TAO Ref#..............: NA
  # Test Class............: 
  # Change Log............:
  #
  #
  ############################################################################*/
public class BudgetAutomation {
	@AuraEnabled(Cacheable = true)
	public static String getNationalUsers()
	{
		Map<ID, User> mapNationalUser = new Map<ID, User> ([SELECT ID, NAME, Sales_Office__c FROM USER WHERE Budget_Type__c = 'National' AND IsActive = true Order By Name]);
		Map<Id, AggregateResult> mapSB = new Map<Id, AggregateResult> ();
		Map<Id, Budget_Automation__c> mapForecastLogs = new Map<Id, Budget_Automation__c> ();

		//List<AggregateResult> sbData = [SELECT Budget_User__c, Budget_User__r.Name, CALENDAR_QUARTER(Broadcast_Month_Date__c) Quarter
		//FROM Sales_Budget__c
		//WHERE
		//TYPE__c IN('Data')
		//AND CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.Forecast_Automation_Year)
		//AND Budget_User__r.Budget_Type__c = 'National'
		//AND Amount__c != 0 AND Amount__c != NUll
		//AND DMA__c != Null
		//GROUP BY CALENDAR_QUARTER(Broadcast_Month_Date__c), Budget_User__c, Budget_User__r.Name];

		for (AggregateResult sb :[SELECT Budget_User__c, Budget_User__r.Name, CALENDAR_QUARTER(Broadcast_Month_Date__c) Quarter
		     FROM Sales_Budget__c
		     WHERE
		     TYPE__c IN('Data')
		     AND CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.Forecast_Automation_Year)
		     AND Budget_User__r.Budget_Type__c = 'National'
		     AND Amount__c != 0 AND Amount__c != NUll
		     AND DMA__c != Null
		     GROUP BY CALENDAR_QUARTER(Broadcast_Month_Date__c), Budget_User__c, Budget_User__r.Name])
		{
			mapSB.put((Id) sb.get('Budget_User__c'), sb);
		}

		//List<Budget_Automation__c> forecastLogs = [SELECT Id, Name, Budget_User__c, Budget_Year__c, Quarter_1__c, Quarter_2__c, Quarter_3__c, Quarter_4__c
		//FROM Budget_Automation__c WHERE Budget_Year__c = :Decimal.valueOf(Label.Forecast_Automation_Year)];

		for (Budget_Automation__c forecastItem :[SELECT Id, Name, Budget_User__c, Budget_Year__c, Quarter_1__c, Quarter_2__c, Quarter_3__c, Quarter_4__c
		     FROM Budget_Automation__c WHERE Budget_Year__c = :Decimal.valueOf(Label.Forecast_Automation_Year)])
		{
			System.debug('forecastItem: ' + forecastItem);
			mapForecastLogs.put(forecastItem.Budget_User__c, forecastItem);
		}

		List<BAGridModel> gridData = new List<BAGridModel> ();
		for (Id u : mapNationalUser.keySet()) {
			BAGridModel data = new BAGridModel();
			User userData = mapNationalUser.get(u);

			if (mapSB.containsKey(u)) {
				if (mapForecastLogs.containsKey(u))
				{
					data.id = u;
					data.username = userData.NAME;
					data.salesoffice = userData.Sales_Office__c;
					data.q1 = mapForecastLogs.get(u).Quarter_1__c == true ? 'true' : '';
					data.q2 = mapForecastLogs.get(u).Quarter_2__c == true ? 'true' : '';
					data.q3 = mapForecastLogs.get(u).Quarter_3__c == true ? 'true' : '';
					data.q4 = mapForecastLogs.get(u).Quarter_4__c == true ? 'true' : '';
					data.buttonvariant = 'Neutral';
					data.isRowEditable = 'true';

					if (mapForecastLogs.get(u).Quarter_1__c && mapForecastLogs.get(u).Quarter_2__c && mapForecastLogs.get(u).Quarter_3__c && mapForecastLogs.get(u).Quarter_4__c)
					data.buttonlabel = 'Show Details';

					else
					data.buttonlabel = 'Start';
				}

				else {
					data.id = u;
					data.username = userData.NAME;
					data.salesoffice = userData.Sales_Office__c;
					data.q1 = '';
					data.q2 = '';
					data.q3 = '';
					data.q4 = '';
					data.buttonvariant = 'Neutral';
					data.buttonlabel = 'Start';
					data.isRowEditable = 'true';
				}
			}

			else {
				data.id = u;
				data.username = userData.NAME;
				data.salesoffice = userData.Sales_Office__c;
				data.q1 = '';
				data.q2 = '';
				data.q3 = '';
				data.q4 = '';
				data.buttonvariant = 'Neutral';
				data.buttonlabel = 'No Sales Budget Data';
				data.disabledClass = 'slds-color__background_gray-4';
				data.isRowEditable = '';
			}
			System.debug('gridData: ' + data);
			gridData.add(data);
		}

		return JSON.serialize(gridData);
	}
	@AuraEnabled(Cacheable = false)
	public static String getCurrentStatus()
	{
		List<Budget_Automation__c> budstatus = [select Status__c FROM Budget_Automation__c WHERE Status__c = 'In-progress' LIMIT 1];
		if (budstatus != null && budstatus.size() > 0)
		{
			return budstatus[0].Status__c;
		}
		return null;
	}
	/*
	  Purpose : Get Sales Budget Data for a User based on the Parameter selected.
	 */
	@AuraEnabled(Cacheable = false)
	public static string getSalesBudgetData(string userId, string quarter, string year)
	{
		try {
			Map<String, BudgetAutomationModel> bamMap = new Map<String, BudgetAutomationModel> ();
			List<Budget_Automation__c> budAList = new List<Budget_Automation__c> ();
			List<Integer> quarterList = new List<Integer> ();
			if (quarter.indexOf(';') > 0)
			{
				for (String s : quarter.split(';')) {
					quarterList.add(Integer.valueOf(s));
				}
			}
			else
			quarterList.add(Integer.valueOf(quarter));

			List<String> userList = new List<String> ();
			if (userId.indexOf(';') > 0)
			{
				for (String s : userId.split(';')) {
					userList.add(s);
				}
			}
			else
			userList.add(userId);
			//Data validation for the user 
			List<Budget_Automation__c> budAutoList = [Select Id, Quarter_1__c, Quarter_2__c, Quarter_3__c, Quarter_4__c, Budget_Year__c, External_ID__c,
			                                          Budget_User__c from Budget_Automation__c
			                                          where Budget_User__c in :userList and Budget_Year__c = :Integer.valueOF(year)];
			Map<String, Budget_Automation__c> budAMap = new Map<String, Budget_Automation__c> ();
			List<Integer> quarterListNew = new List<Integer> ();
			quarterListNew = quarterList;
			for (Budget_Automation__c budA : budAutoList)
			{
				budAMap.put(budA.External_ID__c, budA);
				for (Integer i = 0; i<quarterListNew.size(); i++)
				{
					switch on quarterListNew[i] {
						when 1 {
							if (budA.Quarter_1__c)
							quarterList.remove(i);
							else {
								budA.Quarter_1__c = true;
							}
						}
						when 2 {
							if (budA.Quarter_2__c)
							quarterList.remove(i);
							else {
								budA.Quarter_2__c = true;
							}
						}
						when 3 {
							if (budA.Quarter_3__c)
							quarterList.remove(i);
							else {
								budA.Quarter_3__c = true;
							}
						}
						when else {
							if (budA.Quarter_4__c)
							quarterList.remove(i);
							else {
								budA.Quarter_4__c = true;
							}
						}
					}

				}
				budA.Status__c = 'In-Progress';
				budAList.add(budA);
			}
			System.debug('quarterList ' + quarterList);
			System.debug('userList ' + userList);
			List<Sales_Budget__c> sbList = [SELECT Amount__c, Budget_User__c, Advertiser__c, DMA__c, Product_Line__c, Advertiser__r.Name,Advertiser__r.Agency__c, External_Id_Text__c,Advertiser__r.Rep_Firm__c,
			                                Broadcast_Month_Date__c FROM Sales_Budget__c
			                                WHERE Budget_User__c in :userList AND Type__c = 'Data'
			                                AND CALENDAR_quarter(Broadcast_Month_Date__c) in :quarterList
			                                AND CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(year)
			                               ];
			//Group By Budget_User__c,Advertiser__c, DMA__c, Product_Line__c, Advertiser__r.Name,
			//Calendar_Month(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c)];
			System.debug('sblist@@@' + sbList);
			if (sbList.size()> 0)
			{
				for (Sales_Budget__c sb : sbList)
				{
					string broadcastdatequarter = String.valueOf(Math.ceil(Decimal.valueOf(sb.Broadcast_Month_Date__c.month()) / 3.0));
					string key = (String) sb.Budget_User__c + (String) sb.Advertiser__c + sb.DMA__c + broadcastdatequarter;
					if (!bamMap.containsKey(key))
					{
						System.debug('New Key: ' + key);
						BudgetAutomationModel bam = new BudgetAutomationModel();
						bam.advertiserID = (String) sb.Advertiser__c;
						bam.AgencyId=(string) sb.Advertiser__r.Agency__c;
						bam.repfirmID=(string) sb.Advertiser__r.Rep_Firm__c;
						bam.DMA = (String) sb.DMA__c;
						bam.OppName = 'Opportunity for ' + (String) sb.Advertiser__r.Name + 'quarter ' + broadcastdatequarter;
						bam.OppOwner = (String) sb.Budget_User__c;
						bam.OppBudgetName = 'Opportunity Budget for ' + (String) sb.Advertiser__r.Name + 'quarter ' + broadcastdatequarter;
						bam.pzCount += 1;
						bam.proposalZoneMap = new Map<String, BudgetAutomationModel.ProposalZoneModel> ();
						bam.broadcastDate = sb.Broadcast_Month_Date__c;
						BudgetAutomationModel.ProposalZoneModel pz = new BudgetAutomationModel.ProposalZoneModel();
						pz.productLine = sb.Product_Line__c;
						bam.key = key;
						pz.pzmvMap = new Map<Decimal, BudgetAutomationModel.ProposalZoneMonthlyValueModel> ();
						BudgetAutomationModel.ProposalZoneMonthlyValueModel pzmv = new BudgetAutomationModel.ProposalZoneMonthlyValueModel();
						pzmv.amount = sb.Amount__c;
						pzmv.broadcastMonth = sb.Broadcast_Month_Date__c.month();
						pzmv.broadcastYear = sb.Broadcast_Month_Date__c.year();
						//pz.pzmvMap = new Ma
						bam.pzmvCount += 1;
						pz.pzmvMap.put(pzmv.broadcastMonth, pzmv);
						bam.proposalZoneMap.put(pz.productLine, pz);
						bamMap.put(key, bam);
						System.debug('Record 1:' + bamMap.get(key).proposalZoneMap.get(sb.Product_Line__c).pzmvMap);
					}
					else
					{
						System.debug('Old Key: ' + key);
						BudgetAutomationModel bam = bamMap.get(key);
						//if (bam.proposalZoneMap.containsKey())
						//{

						system.debug('Test :' + bam.proposalZoneMap + 'Line ' + sb.Product_Line__c);
						system.debug('Line ' + sb.Product_Line__c);
						if (bam.proposalZoneMap.containsKey(sb.Product_Line__c))
						{
							BudgetAutomationModel.ProposalZoneModel bamPZ = new BudgetAutomationModel.ProposalZoneModel();
							//bam.pzCount += 1;
							bamPZ = bam.proposalZoneMap.get(sb.Product_Line__c);
							bamPZ.pzmvMap = bam.proposalZoneMap.get(sb.Product_Line__c).pzmvMap;
							//bam.pzmvCount += 1;
							system.debug('bamPZ.pzmvMap : ' + sb.Broadcast_Month_Date__c.month() + 'Helo ' + bamPZ.pzmvMap);
							if (!bamPZ.pzmvMap.containsKey(sb.Broadcast_Month_Date__c.month()))
							{
								bam.pzmvCount += 1;
								System.debug('PZMV New Key: ' + sb.Broadcast_Month_Date__c.month());
								BudgetAutomationModel.ProposalZoneMonthlyValueModel pzmv = new BudgetAutomationModel.ProposalZoneMonthlyValueModel();
								pzmv.amount = sb.Amount__c;
								pzmv.broadcastMonth = sb.Broadcast_Month_Date__c.month();
								pzmv.broadcastYear = sb.Broadcast_Month_Date__c.year();
								bamPZ.pzmvMap.put(pzmv.broadcastMonth, pzmv);
								System.debug('pzmv: ' + pzmv);
							}
							else
							{
								System.debug('PZMV Old Key: ' + sb.Broadcast_Month_Date__c.month());
								BudgetAutomationModel.ProposalZoneMonthlyValueModel pzmv = new BudgetAutomationModel.ProposalZoneMonthlyValueModel();
								pzmv = bamPZ.pzmvMap.get(sb.Broadcast_Month_Date__c.month());
								pzmv.amount += sb.Amount__c;
								System.debug('pzmv: ' + pzmv);
								bamPZ.pzmvMap.put(sb.Broadcast_Month_Date__c.month(), pzmv);
							}

							System.debug('Record 2:' + bamPZ.pzmvMap);
							bam.proposalZoneMap.get(sb.Product_Line__c).pzmvMap = bamPZ.pzmvMap;
							//break;
						}
						else
						{
							bam.pzCount += 1;
							bam.pzmvCount += 1;
							BudgetAutomationModel.ProposalZoneModel pz = new BudgetAutomationModel.ProposalZoneModel();
							pz.productLine = sb.Product_Line__c;
							pz.pzmvMap = new Map<Decimal, BudgetAutomationModel.ProposalZoneMonthlyValueModel> ();
							BudgetAutomationModel.ProposalZoneMonthlyValueModel pzmv = new BudgetAutomationModel.ProposalZoneMonthlyValueModel();
							pzmv.amount = sb.Amount__c;
							pzmv.broadcastMonth = sb.Broadcast_Month_Date__c.month();
							pzmv.broadcastYear = sb.Broadcast_Month_Date__c.year();
							pz.pzmvMap.put(pzmv.broadcastMonth, pzmv);
							bam.proposalZoneMap.put(pz.productLine, pz);
							System.debug('Record 3:' + bamMap.get(key).proposalZoneMap.get(sb.Product_Line__c).pzmvMap);
							System.debug('pzmv: ' + pzmv);
							bamMap.put(key, bam);
							//break;
						}
						//bamMap.put(key, bam);
						//pz.pzmvMap.add(pzmv);
						//bam.proposalZoneList.add(pz);
					}
					//}
				}

				for (string usr : userList)
				{
					if (!budAMap.containsKey(usr + year))
					{
						Budget_Automation__c budA = new Budget_Automation__c();
						budA.Budget_User__c = usr;
						budA.Quarter_1__c = quarterList.contains(1);
						budA.Quarter_2__c = quarterList.contains(2);
						budA.Quarter_3__c = quarterList.contains(3);
						budA.Quarter_4__c = quarterList.contains(4);
						budA.Budget_Year__c = Decimal.valueOf(Label.Forecast_Automation_Year);
						budA.Status__c = 'In-Progress';
						budA.External_ID__c = usr + year;
						budAList.add(budA);
					}
					else {
						Budget_Automation__c budA = budAMap.get(usr + year);

					}
				}
			}

			System.debug('budAList.size(): ' + budAList.size());

			if (budAList.size() > 0)
			{
				List<Database.UpsertResult> dbresults = database.upsert(budAList, false);

				for (Database.UpsertResult r : dbresults) {
					for (Database.Error error : r.getErrors())
					{
						System.debug('Error Message: ' + error);
					}
				}
			}
			string jsonObj = JSON.serialize(bamMap);
			return jsonObj;
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('BudgetAutomation', 'getSalesBudgetData', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
			return null;
		}
	}

	/*
	  Purpose : Create All opportunities using the JSON string as a parameter.
	 */
	@AuraEnabled(Cacheable = false)
	public static string createOpportunity(string jsonWrapper)
	{
		List<Opportunity> oppList = new List<Opportunity> ();
		Map<String, Opportunity> oppMap = new Map<String, Opportunity> ();
		Map<String, BudgetAutomationModel> bamMap = (Map<String, BudgetAutomationModel>) JSON.deserialize(jsonWrapper, Map<String, BudgetAutomationModel>.class);
		Map<String, Budget_Automation__c> budAMap = new Map<String, Budget_Automation__c> ();
		List<Budget_Automation_Object_Detail__c> budADetailList = new List<Budget_Automation_Object_Detail__c> ();
		string userID = '';
		try {
			Map<String, ForecastAutomation_OppDate__c> presentationDateList = ForecastAutomation_OppDate__c.getAll();
			for (String str : bamMap.keySet())
			{
				userID = bamMap.get(str).OppOwner;
				if (!budAMap.containsKey(bamMap.get(str).OppOwner))
				{
					List<Budget_Automation__c> budAList = [Select ID, Budget_User__c from Budget_Automation__c where Status__c = 'In-Progress' and Budget_User__c = :bamMap.get(str).OppOwner and Budget_Year__c = :Decimal.valueOf(Label.Forecast_Automation_Year)];
					for (Budget_Automation__c budA : budAList)
					{
						budAMap.put(budA.Budget_User__c, budA);
					}
				}
				BudgetAutomationModel bam = bamMap.get(str);

				Date pDate = presentationDateList.containsKey('Opp Quarter ' + Math.ceil(Decimal.valueOf(Date.valueOf(bam.broadcastDate).month()) / Decimal.valueOf(4))) ? presentationDateList.get('Opp Quarter ' + Math.ceil(Decimal.valueOf(Date.valueOf(bam.broadcastDate).month()) / Decimal.valueOf(4))).Presentation_Date__c : System.today().addYears(1);
				Opportunity opp = new Opportunity();
				opp.AccountId = bam.advertiserID;
				opp.Name = bam.OppName;
				opp.OwnerId = bam.OppOwner;
				opp.Rep_Firm__c = bam.repfirmID;
				opp.StageName = bam.stage;
				opp.CloseDate = pDate;
				opp.Forecast_Automation_Key__c = bam.key;
				opp.Source__c = 'Forecast Automation';
				opp.Probability = 50;
				//opp.
				opp.DMA__c = bam.DMA;
				oppList.add(opp);
				oppMap.put(bam.key, opp);

			}
			List<Database.SaveResult> saveResultList = Database.insert(oppList, false);
			integer successCount = 0;
			integer errorCount = 0;
			for (Integer i = 0; i<saveResultList.size(); i++)
			{
				Database.SaveResult sr = saveResultList[i];
				if (sr.isSuccess())
				{
					successCount += 1;
					bamMap.get(oppList[i].Forecast_Automation_Key__c).isOppCreated = true;
					bamMap.get(oppList[i].Forecast_Automation_Key__c).oppId = sr.getId();
				}
				else
				{
					errorCount += 1;
					bamMap.get(oppList[i].Forecast_Automation_Key__c).isOppCreated = false;
					bamMap.get(oppList[i].Forecast_Automation_Key__c).errorMessage = sr.getErrors() [0].getMessage();
					Log4SF.logMessage('BudgetAutomation', 'createOpportunity', 'Upsert Failed -' + sr.getErrors() [0].getMessage(), null, UserInfo.getUserId(), null, '');
				}
			}
			BudgetAutomation.createDetail(userID, Label.Forecast_Automation_Year, 'Opportunity', 'Completed', Decimal.valueOf(successCount), Decimal.valueOf(errorCount));
			string jsonObj = JSON.serialize(bamMap);
			//jsonObj = createOppBudget(jsonObj);
			return jsonObj;
		}
		catch(Exception ex)
		{
			System.debug(ex.getMessage());
			Log4SF.logMessage('BudgetAutomation', 'createOpportunity', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
			throw ex;
		}
	}

	/*
	  Purpose : Create All opportunity Budgets using the JSON string as a parameter.
	 */
	@AuraEnabled(Cacheable = false)
	public static string createOppBudget(string jsonWrapper)
	{
	    System.debug('@@@jsonWrapper:'+jsonWrapper); 
		List<Proposal__c> oppBudgetList = new List<Proposal__c> ();
		Map<String, Proposal__c> oppBudgetMap = new Map<String, Proposal__c> ();
		Map<String, BudgetAutomationModel> bamMap = (Map<String, BudgetAutomationModel>) JSON.deserialize(jsonWrapper, Map<String, BudgetAutomationModel>.class);
		System.debug('@@@bamMap11:'+bamMap);
		Map<String, Budget_Automation__c> budAMap = new Map<String, Budget_Automation__c> ();
		//Map<String, List<Budget_Automation_Object_Detail__c>> budAutoDetMap = new Map<String, List<Budget_Automation_Object_Detail__c>> ();
		List<Budget_Automation_Object_Detail__c> budADetailList = new List<Budget_Automation_Object_Detail__c> ();
		string userID = '';
		try {
			for (String str : bamMap.keySet())
			{
				userID = bamMap.get(str).OppOwner;
				if (bamMap.get(str).isOppCreated && String.isNotBlank(bamMap.get(str).oppID))
				{
					if (!budAMap.containsKey(bamMap.get(str).OppOwner))
					{
						List<Budget_Automation__c> budAList = [Select ID, Budget_User__c, (Select ID, Object_Name__c, Success_Count__c, Error_Count__c from Budget_Automation_Object_Details__r) from Budget_Automation__c where Status__c = 'In-Progress' and Budget_User__c = :bamMap.get(str).OppOwner and Budget_Year__c = :Decimal.valueOf(Label.Forecast_Automation_Year)];
						for (Budget_Automation__c budA : budAList)
						{
							budAMap.put(budA.Budget_User__c, budA);
							//budAutoDetMap.put(budA.Id, budA.Budget_Automation_Object_Details__r);
						}
					}
					BudgetAutomationModel bam = bamMap.get(str);
					System.debug('@@@@@bam:'+ bam);
					Proposal__c oppBudget = new Proposal__c();
					oppBudget.RecordTypeId = UtilityClass.getRecordTypeID(oppBudget, 'Opportunity Budget');
					oppBudget.Advertiser__c = bam.advertiserID;
					oppBudget.Rep_Firm__c = bam.repfirmID;
					OppBudget.Agency__c = bam.AgencyId;
					oppBudget.Description__c = bam.key;
					oppBudget.Name = bam.oppBudgetName;
					oppBudget.Opportunity__c = bam.oppID;
					oppBudget.Source__c = 'Forecast Automation';
					oppBudgetList.add(oppBudget);
					oppBudgetMap.put(bam.key, oppBudget);
				}
			}
			List<Database.SaveResult> saveResultList = Database.insert(oppBudgetList, false);
			integer successCount = 0;
			integer errorCount = 0;
			for (Integer i = 0; i<saveResultList.size(); i++)
			{
				Database.SaveResult sr = saveResultList[i];
				if (sr.isSuccess())
				{
					successCount += 1;
					bamMap.get(oppBudgetList[i].Description__c).isoppBudgetCreated = true;
					bamMap.get(oppBudgetList[i].Description__c).oppBudgetId = sr.getId();
				}
				else
				{
					errorCount += 1;
					bamMap.get(oppBudgetList[i].Description__c).isoppBudgetCreated = false;
					bamMap.get(oppBudgetList[i].Description__c).errorMessage = sr.getErrors() [0].getMessage();
					Log4SF.logMessage('BudgetAutomation', 'createOppBudget', 'Upsert Failed -' + sr.getErrors() [0].getMessage(), null, UserInfo.getUserId(), null, '');
				}
			}
			BudgetAutomation.createDetail(userID, Label.Forecast_Automation_Year, 'Opportunity Budget', 'Completed', Decimal.valueOf(successCount), Decimal.valueOf(errorCount));
			string jsonObj = JSON.serialize(bamMap);
			return jsonObj;
		}
		catch(Exception ex)
		{
			System.debug(ex.getMessage());
			Log4SF.logMessage('BudgetAutomation', 'createOppBudget', ex.getMessage(), ex, UserInfo.getUserId(), null, '');

			return null;
		}
	}

	/*
	  Purpose : Create All Proposal Zones using the JSON string as a parameter.
	 */
	@AuraEnabled(Cacheable = false)
	public static string createProposalZone(string jsonWrapper)
	{
		Map<String, String> custSettingMap = new Map<String, String> ();
		List<Proposal_Zone__c> proposalZoneList = new List<Proposal_Zone__c> ();
		Map<String, Proposal_Zone__c> proposalZoneMap = new Map<String, Proposal_Zone__c> ();
		Map<String, SysCodeManualProposalCreation__c> custSettMap = new Map<String, SysCodeManualProposalCreation__c> ();
		custSettMap = SysCodeManualProposalCreation__c.getAll();
		try {
			for (SysCodeManualProposalCreation__c cs : custSettMap.values()) {
				custSettingMap.put(cs.Name__c, cs.Value__c);
			}
			Map<String, BudgetAutomationModel> bamMap = (Map<String, BudgetAutomationModel>) JSON.deserialize(jsonWrapper, Map<String, BudgetAutomationModel>.class);
			for (String str : bamMap.keySet())
			{

				if (bamMap.get(str).isOppBudgetCreated && String.isNotBlank(bamMap.get(str).oppBudgetID))
				{

					for (BudgetAutomationModel.ProposalZoneModel pzm : bamMap.get(str).proposalZoneMap.values())
					{
						String sysCode = custSettingMap.get(pzm.productLine);
						//BudgetAutomationModel bam = bamMap.get(str);
						Proposal_Zone__c proposalZone = new Proposal_Zone__c();
						//proposalZone.RecordTypeId = UtilityClass.getRecordTypeID(proposalZone,'Opportunity Budget');
						proposalZone.Proposal__c = bamMap.get(str).oppBudgetID;
						proposalZone.Zone_Type__c = pzm.productLine;
						proposalZone.Forecast_Automation_Key__c = bamMap.get(str).key;
						proposalZone.Sys_Code__c = sysCode;
						//proposalZone.Description__c = pzm.key;
						//proposalZone.Name = bam.oppBudgetName;
						//proposalZone.Opportunity__c = pzm.oppID;
						//opp.Source__c = 'Forecast Automation';oppBudgetID
						proposalZoneList.add(proposalZone);
						proposalZoneMap.put(pzm.productLine, proposalZone);
					}
				}
			}
			List<Database.SaveResult> saveResultList = Database.insert(proposalZoneList, false);
			for (Integer i = 0; i<saveResultList.size(); i++)
			{
				Database.SaveResult sr = saveResultList[i];
				if (sr.isSuccess())
				{
					bamMap.get(proposalZoneList[i].Forecast_Automation_Key__c).proposalZoneMap.get(proposalZoneList[i].Zone_Type__c).isCreated = true;
					bamMap.get(proposalZoneList[i].Forecast_Automation_Key__c).proposalZoneMap.get(proposalZoneList[i].Zone_Type__c).pzID = sr.getId();
				}
				else
				{
					for (Database.Error err : sr.getErrors()) {
						System.debug('Propozal Zone Error: ' + err.getMessage());
					}
					//bamMap.get(proposalZoneList[i].Forecast_Automation_Key__c).proposalZoneMap.get(proposalZoneList[i].Zone_Type__c).isCreated = f;
					bamMap.get(proposalZoneList[i].Forecast_Automation_Key__c).proposalZoneMap.get(proposalZoneList[i].Zone_Type__c).errorMessage = sr.getErrors() [0].getMessage();
					Log4SF.logMessage('BudgetAutomation', 'createProposalZone', 'Upsert Failed -' + sr.getErrors() [0].getMessage(), null, UserInfo.getUserId(), null, '');
				}
			}
			string jsonObj = JSON.serialize(bamMap);
			return jsonObj;
		}
		catch(Exception ex)
		{
			System.debug(ex.getMessage());
			Log4SF.logMessage('BudgetAutomation', 'createProposalZone', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
			return null;
		}
	}

	/*
	  Purpose : Create All Proposal Zone Monthly Values(PZMV) using the JSON string as a parameter.
	 */
	@AuraEnabled(Cacheable = false)
	public static string createPZMV(string jsonWrapper)
	{
		List<Proposal_Zone_Monthly_Value__c> proposalZoneMVList = new List<Proposal_Zone_Monthly_Value__c> ();
		Map<String, Proposal_Zone_Monthly_Value__c> proposalZoneMVMap = new Map<String, Proposal_Zone_Monthly_Value__c> ();
		Map<String, BudgetAutomationModel> bamMap = (Map<String, BudgetAutomationModel>) JSON.deserialize(jsonWrapper, Map<String, BudgetAutomationModel>.class);
		try {
			for (String str : bamMap.keySet())
			{

				for (BudgetAutomationModel.ProposalZoneModel pzm : bamMap.get(str).proposalZoneMap.values())
				{
					if (pzm.isCreated && String.isNotBlank(pzm.pzID) && pzm.pzmvMap.size()> 0)
					{
						for (BudgetAutomationModel.ProposalZoneMonthlyValueModel pzmv : pzm.pzmvMap.values())
						{
							Proposal_Zone_Monthly_Value__c proposalZoneMV = new Proposal_Zone_Monthly_Value__c();
							proposalZoneMV.Proposal_Zone__c = pzm.pzID;
							proposalZoneMV.Broadcast_Month_Date__c = Date.newInstance(Integer.valueOf(pzmv.broadcastYear), Integer.valueOf(pzmv.broadcastMonth), 15);
							proposalZoneMV.Gross_Amount__c = pzmv.amount;
							proposalZoneMV.Forecast_Automation_Key__c = bamMap.get(str).key;
							proposalZoneMV.Product_Line__c = pzm.productLine;
							proposalZoneMVList.add(proposalZoneMV);
							proposalZoneMVMap.put(pzm.productLine, proposalZoneMV);
						}
					}
				}

			}
			List<Database.SaveResult> saveResultList = Database.insert(proposalZoneMVList, false);
			for (Integer i = 0; i<saveResultList.size(); i++)
			{
				string key = proposalZoneMVList[i].Forecast_Automation_Key__c;
				Database.SaveResult sr = saveResultList[i];
				if (sr.isSuccess())
				{
					//proposalZoneMVList[i].recalculateFormulas();
					bamMap.get(key).proposalZoneMap.get(proposalZoneMVList[i].Product_Line__c).pzmvMap.get(proposalZoneMVList[i].Broadcast_Month_Date__c.month()).isCreated = true;
					bamMap.get(key).proposalZoneMap.get(proposalZoneMVList[i].Product_Line__c).pzmvMap.get(proposalZoneMVList[i].Broadcast_Month_Date__c.month()).pzmvID = sr.getId();
				}
				else
				{
					//bamMap.get(key).proposalZoneMVMap.get(proposalZoneMVList[i].Zone_Type__c).isCreated = f;
					bamMap.get(key).proposalZoneMap.get(proposalZoneMVList[i].Product_Line__c).pzmvMap.get(proposalZoneMVList[i].Broadcast_Month_Date__c.month()).errorMessage = sr.getErrors() [0].getMessage();
					Log4SF.logMessage('BudgetAutomation', 'createPZMV', 'Upsert Failed -' + sr.getErrors() [0].getMessage(), null, UserInfo.getUserId(), null, '');
				}
			}
			string jsonObj = JSON.serialize(bamMap);
			return jsonObj;
		}
		catch(Exception ex)
		{
			System.debug(ex.getMessage() + '.....' + ex.getStackTraceString());
			Log4SF.logMessage('BudgetAutomation', 'createPZMV', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
			return null;
		}
	}

	@AuraEnabled(Cacheable = false)
	public static String createDetail(string userId, string year, string objectName, string status, decimal successCount, decimal errorCount)
	{
		try {
			List<String> userList = new List<String> ();
			if (userId.indexOf(';')> 0)
			{
				for (String s : userId.split(';')) {
					userList.add(s);
				}
			}
			else
			userList.add(userId);

			Map<String, Budget_Automation_Object_Detail__c> budAutoMap = new Map<String, Budget_Automation_Object_Detail__c> ();
			List<Budget_Automation_Object_Detail__c> budAutoList = new List<Budget_Automation_Object_Detail__c> ();
			budAutoList = [Select Id, Object_Name__c, Status__c, Success_Count__c, Error_Count__c, Budget_Automation__r.Quarter_1__c, Budget_Automation__r.Quarter_2__c,
			               Budget_Automation__r.Quarter_3__c, Budget_Automation__r.Quarter_4__c, Budget_Automation__r.Budget_Year__c,
			               Budget_Automation__r.Budget_User__c from Budget_Automation_Object_Detail__c
			               where Budget_Automation__r.Budget_User__c in :userList and Budget_Automation__r.Budget_Year__c = :Integer.valueOF(year)];
			List<Budget_Automation__c> budAList = [Select ID, Budget_User__c, (Select ID, Object_Name__c, Success_Count__c, Error_Count__c, Budget_Automation__r.Budget_User__c,
			                                                                   Budget_Automation__r.Id
			                                                                   from Budget_Automation_Object_Details__r)
			                                       from Budget_Automation__c where Budget_User__c in :userList and Budget_Year__c = :Integer.valueOf(year)];
			for (Budget_Automation__c budDetA : budAList)
			{
				if (String.isBlank(status))
				status = 'Completed';
				if (budDetA.Budget_Automation_Object_Details__r.size()> 0)
				{
					for (Budget_Automation_Object_Detail__c budDetAuto : budDetA.Budget_Automation_Object_Details__r)
					{
						if (budDetAuto.Object_Name__c == objectName)
						{
							budDetAuto.Success_Count__c += successCount;
							budDetAuto.Error_Count__c += errorCount;
							budAutoMap.put(objectName + budDetAuto.Budget_Automation__r.Budget_User__c, budDetAuto);
							break;
						}
					}
				}
			}
			if (!budAutoMap.containsKey(objectName + userId) || budAutoMap.size() == 0)
			{
				Budget_Automation_Object_Detail__c budAutoDetail = new Budget_Automation_Object_Detail__c();
				budAutoDetail.Object_Name__c = objectName;
				budAutoDetail.Success_Count__c = successCount;
				budAutoDetail.Error_Count__c = errorCount;
				if (String.isBlank(status))
				budAutoDetail.Status__c = 'Completed';
				else
				budAutoDetail.Status__c = status;
				budAutoDetail.Budget_Automation__c = budAList[0].Id;
				budAutoMap.put(objectName, budAutoDetail);
			}
			if (budAutoMap.values().size()> 0)
			Database.Upsert(budAutoMap.values());
			if (objectName == 'Proposal Zone Monthly Value')
			{
				budAList[0].Status__c = 'Completed';
				Database.update(budAList[0]);
			}
			//for (Budget_Automation_Object_Detail__c data : (budAutoMap.values()))
			//{
			//return data.Budget_Automation__r.Id;
			//}

			return budAList[0].Id;
		}
		catch(Exception ex)
		{
			System.debug(ex.getMessage() + ex.getStackTraceString());
			Log4SF.logMessage('BudgetAutomation', 'createDetail', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
			return ex.getMessage();
		}
	}

	@AuraEnabled(Cacheable = false)
	public static List<Budget_Automation_Object_Detail__c> getForecastGeneratedDetail(string userId, string year)
	{
		List<String> userList = new List<String> ();
		if (userId.indexOf(';') > 0)
		{
			for (String s : userId.split(';')) {
				userList.add(s);
			}
		}
		else
		userList.add(userId);

		List<Budget_Automation_Object_Detail__c> budAutoDetailList = [Select Id, Object_Name__c, Status__c, Success_Count__c, Error_Count__c, Budget_Automation__r.Quarter_1__c, Budget_Automation__r.Quarter_2__c,
		                                                              Budget_Automation__r.Quarter_3__c, Budget_Automation__r.Quarter_4__c, Budget_Automation__r.Budget_Year__c,
		                                                              Budget_Automation__r.Budget_User__c, Budget_Automation__r.Budget_User__r.Name, Budget_Automation__r.Id from Budget_Automation_Object_Detail__c
		                                                              where Budget_Automation__r.Budget_User__c in :userList and Budget_Automation__r.Budget_Year__c = :Integer.valueOF(year) Order By Id Asc];

		return budAutoDetailList;
	}

	public class BAGridModel {
		public String id;
		public String username;
		public String salesoffice;
		public String q1;
		public String q2;
		public String q3;
		public String q4;
		public String buttonlabel;
		public String buttonvariant;
		public String disabledClass;
		public string isRowEditable;

		public BAGridModel()
		{
		}
	}
}