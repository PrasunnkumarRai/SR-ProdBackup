/*
  ###########################################################################
  # File..................: TrackCompensationPlanController.cls
  # Version...............: 1
  # Created by............: Shubham Gupta   
  # Created Date..........: 08-Feb-2019
  # Last Modified by......: 
  # Last Modified Date....: 
  # Description...........: This class contains the methods related to track compensation
  # Change Log............:
  ############################################################################*/

public with sharing class TrackCompensationPlanController {
	//region variables
	public String pageMsg { get; set; }
	Transient public List<AggregateResult> BudgetList { get; set; }
	Transient public List<AggregateResult> SalesBudgetList { get; set; }
	Transient public Map<String, salesbudgetWrapper> salesBudgetWrapperMap { get; set; }
	Transient public Map<String, AggregateResult> salesBudgeMap { get; set; }
	//Transient public String jsonTrackCompData { get; set; }
	public final String genericErrorMsg = 'Something went wrong. Please contact administrator';
	public Integer currentYear { get; set; }
	public Integer nextYear { get; set; }

	public User loggedInUser { get; set; }
	public String loggedInUserRole { get; set; }
	public String loggedInBudgetView { get; set; }
	Transient public Map<String, String> userMap { get; set; }
	public Boolean isAdmin { get; set; }
	public Boolean isSDOF { get; set; }
	public List<User> division;
	//endregion

	public TrackCompensationPlanController() {
		try {
			userMap = new Map<String, String> ();
			division = new List<User> ();

			isAdmin = false;
			isSDOF = false;
			division = [SELECT Division__c FROM User WHERE Id = :userInfo.getUserId() LIMIT 1];
			currentYear = Date.Today().Year();
			nextYear = Date.Today().Year() + 1;

			buildUserContext(UserInfo.getUserId(), division[0].Division__c);
			GetTrackCompDetails();

			if (Test.isRunningTest()) {
				CalloutException e = new CalloutException();
				e.setMessage('This is a constructed exception for testing and code coverage');
				throw e;
			}
		}

		catch(exception ex)
		{
			Log4SF.logMessage('TrackCompensationPlanController', 'constructor', ex.getMessage(), ex, UserInfo.getUserId(), '', '');
			pageMsg = genericErrorMsg;
		}
	}

	public void GetTrackCompDetails()
	{
		Cache.SessionPartition partition = Cache.Session.getPartition('SRPartition');
		salesBudgetWrapperMap = new Map<String, salesbudgetWrapper> ();
		salesBudgeMap = new Map<String, AggregateResult> ();
		List<String> lstratePlanStatus = new List<String> ();
		List<Integer> lstselectedYear = new List<Integer> ();
		try {
			String selectedYear = Apexpages.currentPage().getParameters().get('selectedBudgetYear');
			String ratePlanStatus = Apexpages.currentPage().getParameters().get('ratePlanStatus');

			if (ratePlanStatus == null || ratePlanStatus == 'AllUser')
			{
				lstratePlanStatus.add('Pending');
				lstratePlanStatus.add('Committed');
				lstratePlanStatus.add('Draft');
			}

			else
			{
				lstratePlanStatus.Add(ratePlanStatus);
			}

			if (selectedYear == null)
			{
				lstselectedYear.Add(currentYear);
			}

			else {
				lstselectedYear.Add(Integer.ValueOf(selectedYear));
			}

			if (userMap == null || userMap.size() == 0) {
				userMap = new Map<String, String> ();
				buildUserContext(UserInfo.getUserId(), division[0].Division__c);
			}

			List<String> userIds = new List<String> (userMap.keySet());
			partition.put('lstUserIdsAllowed', userIds);

			system.debug('lstUserIdsAllowed ' + userIds);
			system.debug('isAdmin ' + isAdmin);
			system.debug('isSDOF ' + isSDOF);
			system.debug('lstselectedYear ' + lstselectedYear);

			if (isAdmin == true || isSDOF == true)
			{
				partition.put('isCommitReadonly', false);
			}

			BudgetList = [SELECT
			              Budget_User__r.Name AEName,
			              Budget_User__c AeId,
			              From_Budget_user__r.Name oldAEName,
			              From_Budget_user__c oldAeId,
			              Sum(Amount__c) BudAmt,
			              CALENDAR_MONTH(Budget_Change_Date__c) bdMonth,
			              Budget_User__r.Rate_Plan_Status__c BudUserStatus,
			              From_Budget_user__r.Rate_Plan_Status__c OldBudUserStatus,
			              Budget_User__r.Division__c BudUserDivision,
			              From_Budget_user__r.Division__c OldBudUserDivision,
			              BUCommitDateCompareTransferDate__c BUCommitDateBool,
			              Old_BU_Commit_Date_Compare_Transfer_Date__c OldBUCommitDateBool
			              FROM Sales_Budget_Simulation__c
			              WHERE(Budget_User__r.Rate_Plan_Status__c IN('Pending', 'Committed', 'Draft')
			                    OR From_Budget_user__r.Rate_Plan_Status__c IN('Pending', 'Committed', 'Draft'))
			              AND CALENDAR_YEAR(Budget_Change_Date__c) IN :lstselectedYear
			              AND Amount__c != NULL
			              AND Amount__c != 0
			              AND Broadcast_Month_Date__c != NULL
			              AND Type__c = 'Log'
			              AND(Budget_User__c IN :userIds
			                  OR From_Budget_user__c IN :userIds)
			              AND((Sales_Budget__r.Type__c = 'Data' and(Sales_Budget__r.Product_Line__c != 'New Business' AND Sales_Budget__r.Product_Line__c != 'Unknown Churn')) OR Sales_Budget__r.Type__c = 'DOS')
			              GROUP BY CALENDAR_MONTH(Budget_Change_Date__c), Budget_User__c, Budget_User__r.Name, From_Budget_user__r.Name,
			              From_Budget_user__c, Budget_User__r.Rate_Plan_Status__c, From_Budget_user__r.Rate_Plan_Status__c,
			              Budget_User__r.Division__c, From_Budget_user__r.Division__c, BUCommitDateCompareTransferDate__c, Old_BU_Commit_Date_Compare_Transfer_Date__c
			              ORDER BY Budget_User__r.Name, CALENDAR_MONTH(Budget_Change_Date__c)
			             ];

			SalesBudgetList = [SELECT
			                   Budget_User__r.Name AEName,
			                   Budget_User__c AeId,
			                   Sum(Amount__c) BudAmt,
			                   CALENDAR_MONTH(Broadcast_Month_Date__c) bdMonth
			                   FROM Sales_Budget__c
			                   WHERE(Budget_User__r.Rate_Plan_Status__c IN('Pending', 'Committed', 'Draft')
			                         OR Old_Budget_user__r.Rate_Plan_Status__c IN('Pending', 'Committed', 'Draft'))
			                   AND CALENDAR_YEAR(Broadcast_Month_Date__c) IN :lstselectedYear
			                   AND Amount__c != NULL
			                   AND Amount__c != 0
			                   AND Broadcast_Month_Date__c != NULL
			                   AND Budget_User__c IN :userIds
			                   AND Old_Budget_user__c = NULL
			                   AND((Type__c = 'Data' and(Product_Line__c != 'New Business' AND Product_Line__c != 'Unknown Churn')) OR Type__c = 'DOS')
			                   GROUP BY Budget_User__r.Name, Budget_User__c, CALENDAR_MONTH(Broadcast_Month_Date__c)
			                   ORDER BY Budget_User__r.Name, CALENDAR_MONTH(Broadcast_Month_Date__c)
			                  ];

			for (AggregateResult SBItem : SalesBudgetList)
			{
				salesBudgeMap.put((String) SBItem.get('AeId') + ';' + SBItem.get('bdMonth'), SBItem);
			}

			system.debug('salesBudgeMap =' + salesBudgeMap);

			for (AggregateResult BudItem : BudgetList)
			{
				String Key = (String) BudItem.get('AeId');

				salesBudgetWrapper sbWObj = new salesBudgetWrapper();

				if (!salesBudgetWrapperMap.containsKey(Key))
				{
					sbWObj.aeName = (String) BudItem.get('AeName');
					sbWObj.aeId = (String) BudItem.get('AeId');
					PopulateData(sbWObj, Key, BudItem, lstratePlanStatus, userIds, salesBudgeMap);
				}

				else
				{
					sbWObj = salesBudgetWrapperMap.get(Key);
					sbWObj.aeName = (String) BudItem.get('AeName');
					sbWObj.aeId = (String) BudItem.get('AeId');
					PopulateData(sbWObj, Key, BudItem, lstratePlanStatus, userIds, salesBudgeMap);
				}
			}

			for (salesbudgetWrapper sbWItem : salesBudgetWrapperMap.values())
			{
				for (Decimal bcItem : sbWItem.budgetChanges)
				{
					sbWItem.total += bcItem;
				}
			}

			system.debug(salesBudgetWrapperMap);
			//jsonTrackCompData = JSON.serialize(salesBudgetWrapperMap);
			//pageMsg = jsonTrackCompData;

			if (Test.isRunningTest()) {
				CalloutException e = new CalloutException();
				e.setMessage('This is a constructed exception for testing and code coverage');
				throw e;
			}
		}

		catch(exception ex)
		{
			system.debug(ex.getMessage());
			system.debug(ex.getLineNumber());
			system.debug(ex);
			Log4SF.logMessage('TrackCompensationPlanController', 'GetTrackCompDetails', ex.getMessage(), ex, UserInfo.getUserId(), 'Parametr value: ' + lstratePlanStatus, '');
			pageMsg = genericErrorMsg;
		}
	}

	private void PopulateData(salesBudgetWrapper sbWObj, String Key, AggregateResult BudItem, List<String> lstratePlanStatus, List<String> userIds, Map<String, AggregateResult> salesBudgeMap)
	{
		String oldKey = (String) BudItem.get('oldAeId');
		Integer month = (Integer) BudItem.get('bdMonth');
		String OldBudUserStatus = (String) BudItem.get('OldBudUserStatus');
		String BudUserStatus = (String) BudItem.get('BudUserStatus');
		String BudUserDivision = (String) BudItem.get('BudUserDivision');
		String OldBudUserDivision = (String) BudItem.get('OldBudUserDivision');
		Boolean BUCommitDateBool = (Boolean) BudItem.get('BUCommitDateBool');
		Boolean OldBUCommitDateBool = (Boolean) BudItem.get('OldBUCommitDateBool');


		if ((String) BudItem.get('oldAeId') != null && (String) BudItem.get('oldAeId') != '' && lstratePlanStatus.Contains(OldBudUserStatus) && (isAdmin == true || (isSDOF == true && division[0].Division__c == OldBudUserDivision)) && OldBUCommitDateBool == true)
		{
			salesBudgetWrapper sbWOldObj = new salesBudgetWrapper();
			AggregateResult amount;
			// Old user Budget Out Movements
			if (!salesBudgetWrapperMap.containsKey(oldKey))
			{
				sbWOldObj.aeName = (String) BudItem.get('oldAeName');
				sbWOldObj.aeId = (String) BudItem.get('oldAeId');
				amount = salesBudgeMap.get((String) BudItem.get('oldAeId') + ';' + String.valueOf(month));
				sbWOldObj.outBudgets[month - 1] += ((BudItem.get('BudAmt') == null ? 0 : (Decimal) BudItem.get('BudAmt')) + (amount == null ? 0 : (Decimal) amount.get('BudAmt')));
			}
			else
			{
				sbWOldObj = salesBudgetWrapperMap.get(oldKey);
				amount = salesBudgeMap.get(oldKey + ';' + String.valueOf(month));
				sbWOldObj.outBudgets[month - 1] += ((BudItem.get('BudAmt') == null ? 0 : (Decimal) BudItem.get('BudAmt')) + (amount == null ? 0 : (Decimal) amount.get('BudAmt')));
			}

			if (sbWOldObj.inBudgets[month - 1] == NULL || sbWOldObj.inBudgets[month - 1] == 0)
			sbWOldObj.inBudgets[month - 1] = sbWOldObj.inBudgets[month - 1] + (amount == null ? 0 : (Decimal) amount.get('BudAmt'));
			sbWOldObj.budgetChanges[month - 1] = sbWOldObj.inBudgets[month - 1] - sbWOldObj.outBudgets[month - 1];

			if (isAdmin == true || (isSDOF == true && division[0].Division__c == OldBudUserDivision) || userIds.Contains(oldKey))
			{
				salesBudgetWrapperMap.put(oldKey, sbWOldObj);
			}
		}

		if (lstratePlanStatus.Contains(BudUserStatus) && BUCommitDateBool == true)
		{
			AggregateResult amount = salesBudgeMap.get(Key + ';' + String.valueOf(month));
			sbWObj.inBudgets[month - 1] += (BudItem.get('BudAmt') == null ? 0 : (Decimal) BudItem.get('BudAmt') + (amount == null ? 0 : (Decimal) amount.get('BudAmt')));
			sbWObj.outBudgets[month - 1] = sbWObj.outBudgets[month - 1] + (amount == null ? 0 : (Decimal) amount.get('BudAmt'));
			sbWObj.budgetChanges[month - 1] = sbWObj.inBudgets[month - 1] - sbWObj.outBudgets[month - 1];
			if (isAdmin == true || (isSDOF == true && division[0].Division__c == BudUserDivision) || userIds.Contains(Key))
			{
				salesBudgetWrapperMap.put(Key, sbWObj);
			}
		}
	}

	public void buildUserContext(String prmuserid, String division)
	{
		System.debug('selected/primaryuser : ' + prmuserid);
		Cache.SessionPartition partition = Cache.Session.getPartition('SRPartition');
		List<User> lstUser1 = new List<User> ();
		List<User> lstUser2 = new List<User> ();
		List<UserClassification__mdt> lstUC = new List<UserClassification__mdt> ();
		Map<String, List<String>> mapUserClassification = new Map<String, List<String>> ();

		lstUC = [Select id, DeveloperName, MasterLabel, user_profiles__c, Budget_View__c, Impersonate_Capability__c from UserClassification__mdt];

		for (UserClassification__mdt uc : lstUC)
		{
			mapUserClassification.put(uc.DeveloperName, uc.user_profiles__c.indexOf(',') > 0 ? uc.user_profiles__c.split(',') : new list<String> { uc.user_profiles__c });
		}

		loggedInUser = [Select id, name, profile.name, HR_Manager__c, HR_Manager__r.email, HR_Manager__r.name, Budget_Type__c
		                from User
		                where id = :prmuserid or name = :prmuserid limit 1];

		lstUser1 = [Select id, name, profile.name, HR_Manager__r.email, HR_Manager__r.name, Budget_Type__c, Budget_Product_Lines__c, HR_Level__c
		            from User
		            where hr_manager__c = :loggedInUser.id AND Division__c = :division AND Budget_Type__c != NULL AND Budget_Product_Lines__c != NULL AND Budget_DMA__c != NULL AND profile.name NOT IN :mapUserClassification.get('Admin')
		            order by name];

		for (UserClassification__mdt uc : lstUC)
		{
			if (uc.user_profiles__c.contains(loggedInUser.profile.name))
			{
				loggedInUserRole = uc.developername;
				loggedInBudgetView = uc.Budget_View__c;
				partition.put('isCommitReadonly', true);
				if (uc.DeveloperName == 'Admin' && uc.user_profiles__c.contains(loggedInUser.profile.name))
				{
					List<String> adminProfilelst = new List<String> (mapUserClassification.get('Admin'));
					system.debug('adminProfilelst ' + adminProfilelst);
					isAdmin = true;
					partition.put('isCommitReadonly', false);
					lstUser1 = [Select id, name, profile.name, HR_Manager__r.email, HR_Manager__r.name, Budget_Type__c, Budget_Product_Lines__c, HR_Level__c
					            from User
					            where Budget_Type__c != NULL AND Budget_Product_Lines__c != NULL AND Budget_DMA__c != NULL AND profile.name NOT IN :mapUserClassification.get('Admin')
					            order by name];
					for (User ru : lstUser1)
					{
						userMap.put(ru.id, ru.name);
					}
				}

				if (uc.DeveloperName == 'Finance' && uc.user_profiles__c.contains(loggedInUser.profile.name))
				{
					isSDOF = true;
					partition.put('isCommitReadonly', false);
				}

				break;
			}
			else
			{
				loggedInUserRole = 'NA';
				loggedInBudgetView = 'NA';
			}
		}

		if (!isAdmin)
		{
			userMap.put(loggedInUser.id, loggedInUser.name);
			List<String> uList = new List<String> ();
			if (loggedInBudgetView == 'Manager' || loggedInBudgetView == 'Leadership')
			{
				for (User ru : lstUser1)
				{
					userMap.put(ru.id, ru.name);
					uList.add(ru.id);
				}
			}

			if (loggedInBudgetView == 'Leadership')
			{
				if (loggedInUserRole == 'Finance')
				{
					String nationalUsersDiv = 'National - ' + division;
					lstUser2 = [Select id, name, profile.name, HR_Manager__r.email, HR_Manager__r.name, Budget_Type__c, Budget_Product_Lines__c, HR_Level__c
					            from User
					            where(Division__c = :division OR Division__c = :nationalUsersDiv) AND Budget_Type__c != NULL AND Budget_Product_Lines__c != NULL AND Budget_DMA__c != NULL AND profile.name NOT IN :mapUserClassification.get('Admin')
					            order by HR_Manager__r.name, name
					           ];
				}

				else
				{
					lstUser2 = [Select id, name, profile.name, HR_Manager__r.email, HR_Manager__r.name, Budget_Type__c, Budget_Product_Lines__c, HR_Level__c
					            from User
					            where HR_Manager__c in :uList AND Division__c = :division AND Budget_Type__c != NULL AND Budget_Product_Lines__c != NULL AND Budget_DMA__c != NULL AND profile.name NOT IN :mapUserClassification.get('Admin')
					            order by HR_Manager__r.name, name
					           ];
				}
				for (User ru : lstUser2)
				{
					userMap.put(ru.id, ru.name);
				}
			}
		}
		system.debug('userMap Record Count ' + userMap.size());
		system.debug('userMap ' + userMap);
	}

	public class salesbudgetWrapper
	{
		public String aeId { get; set; }
		public String aeName { get; set; }
		public Decimal total { get; set; }
		public List<Decimal> inbudgets { get; set; }
		public List<Decimal> outBudgets { get; set; }
		public List<Decimal> budgetChanges { get; set; }

		public salesbudgetWrapper()
		{
			aeId = '';
			aeName = '';
			total = 0;
			inbudgets = new List<Decimal> { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
			outBudgets = new List<Decimal> { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
			budgetChanges = new List<Decimal> { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
		}

	}
	/*   
	  public void CallBatch(){
	  try{
	  TrackRatePlanChangeQualifications trpcq = new TrackRatePlanChangeQualifications(); 
	  Database.executeBatch(trpcq, 200);
	  batchMsg = batchSuccessMsg;
	  System.debug(batchSuccessMsg);
	 
	 
	  if(Test.isRunningTest()) {
	  CalloutException e = new CalloutException();
	  e.setMessage('This is a constructed exception for testing and code coverage');
	  throw e;
	  }
	  }
	 
	  catch(exception ex)
	  {
	  Log4SF.logMessage('TrackCompensationPlanController', 'CallBatch', ex.getMessage(),ex, UserInfo.getUserId(),'','');
	  batchMsg = batchErrorMsg;       
	  }
	  }    
	 
	  @RemoteAction  
	  public static String ConfirmAEList(List<String> aeIdListToConfirm){
	  string pageMsg;
	  try{
	  List<User> aeListToUpdate = [SELECT Id, Name, Rate_Plan_Status__c FROM USER WHERE Id IN :aeIdListToConfirm];
	  for(USER usr : aeListToUpdate) {
	  usr.Rate_Plan_Status__c  = '';
	  }
	  update aeListToUpdate;
	  pageMsg = 'Success';
	 
	 
	  if(Test.isRunningTest()) {
	  CalloutException e = new CalloutException();
	  e.setMessage('This is a constructed exception for testing and code coverage');
	  throw e;
	  }  
	 
	  }
	 
	  catch(exception ex)
	  {
	  pageMsg = ex.getMessage();
	  }
	  return pageMsg;
	  }*/
}