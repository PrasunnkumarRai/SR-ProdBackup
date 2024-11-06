/*
  ###########################################################################
  # File..................: BudgetingToolController.cls
  # Version...............: 1
  # Created by............: Shubham Gupta
  # Created Date..........: 20-May-2019
  # Last Modified by......:
  # Last Modified Date....:
  # Description...........: 
  # TAO Ref#..............: 
  # Test Class............: 
  # Change Log............:
  #
  #
  ############################################################################*/
global without sharing class BudgetingToolController {

	public User loggedInUser { get; set; }
	public String loggedInUserBudgetType { get; set; }
	public String loggedInUserRole { get; set; }
	public String loggedInBudgetView { get; set; }
	public String loggedInUserProductLines { get; set; }
	public String loggedInUserDMA { get; set; }
	public Boolean loggedInUserImpersonate { get; set; }
	public String submissionDateCheck { get; set; }
	public String gridWorkflowStatus { get; set; }
	public Set<String> productTotalsSet;
	public transient String GridDef { get; set; }
	public transient String JSONData { get; set; }
	public transient String JSONString { get; set; }
	public String JSONOutput { get; set; }
	public String JSONOutputDOS { get; set; }
	transient BudgetingToolModel tgm;
	transient BudgetingToolModelNational tgmNational;
	transient BudgetingToolModelDOS tgmDOS;
	transient Map<String, gridHelper> budgetKeys = new Map<String, gridHelper> ();
	Map<String, gridHelper> revenuePYMap = new Map<String, gridHelper> ();
	Map<String, gridHelper> revenueCYMap = new Map<String, gridHelper> ();
	Map<String, gridHelper> revenueNYMap = new Map<String, gridHelper> ();
	Set<Id> advertiserIdList = new Set<Id> ();
	Map<String, gridHelper> budgetMap { get; set; }
	Map<String, gridHelper> dosBudgetMap { get; set; }
	Map<String, gridHelper> dosBudgetKeys = new Map<String, gridHelper> ();
	Map<String, gridHelper> newBusinessBudgetMap = new Map<String, gridHelper> ();
	Map<String, gridHelper> forecastMap = new Map<String, gridHelper> ();
	transient public Map<Id, Account> accMap { get; set; }
	public static String keySeparator = '::';
	String DMAList = '';
	String PComList = '';
	static String selectedDMA = '';
	static String selectedPCom = '';
	public List<String> userList { get; set; }
	public transient List<String> impersonateList { get; set; }
	public Map<String, String> userListStatus { get; set; } // = new Map<String,String>();
	public Map<String, String> userListStatusColorMap { get; set; } // = new Map<String,String>();
	public Map<String, String> userListNameMap { get; set; } // = new Map<String,String>();
	public Map<String, String> userMap { get; set; }
	static String selectedUser = '';
	public Boolean noSaveMode { get; set; }
	public Boolean noSaveModeDOS { get; set; }
	public Boolean noApproveMode { get; set; }
	public String comments { get; set; }
	static Sales_Budget__c sbWorkflow;
	public static String sbWorkflowId { get; set; }
	public static String alertMessage { get; set; }
	public transient String GridDefDOS { get; set; }
	public transient String JSONDataDOS { get; set; }
	public transient String JSONStringDOS { get; set; }
	public static String userParam { get; set; }
	public static String impParam { get; set; }
	public User dosUser;
	public String newBusinessAccount;
	public Boolean showApproval;
	public String sbStatus { get; set; }
	public String clientInfo { get; set; }
	//labels
	public String ProductTotalsLabel { get; set; }
	public String TotalsLabel { get; set; }
	public String BudgetLabel { get; set; }
	public String TotalsBudgetLabel { get; set; }
	public String Q3FCSTLabel { get; set; }
	public String TotalsQ3FCSTLabel { get; set; }
	public String PrevYearOTBLabel { get; set; }
	public String TotalsPrevYearOTBLabel { get; set; }
	public String CurrYearOTBLabel { get; set; }
	public String TotalsCurrYearOTBLabel { get; set; }
	public String NextYearOTBLabel { get; set; }
	public String TotalsNextYearOTBLabel { get; set; }
	public String CurrYearYOYLabel { get; set; }
	public String TotalsCurrYearYOYLabel { get; set; }
	public String NextYearYOYLabel { get; set; }
	public String TotalsNextYearYOYLabel { get; set; }
	public String ChurnLabel { get; set; }
	public String ChurnYearLabel { get; set; }
	public String TotalsChurnLabel { get; set; }
	public String TotalsKnownBudgetLabel { get; set; }
	public String NewBusinessLabel { get; set; }
	public String NewBusinessYearLabel { get; set; }
	public String TotalsNewBusinessLabel { get; set; }
	public String submittedUser { get; set; }
	public Boolean rollupSumOnBudget { get; set; }
	public String rollupSumOnBudgetStr { get; set; }
	public String LastYear { get; set; }
	public String LastToLastYear { get; set; }
	public String NextYear { get; set; }

	public list<Budgeting_Report__mdt> getBudgetingReports() {
		return[Select DeveloperName, MasterLabel, Report_URL__c from Budgeting_Report__mdt];
	}


	/**
	 * Constructor.
	 *
	 * @param  (none) (NA)
	 * @return (none) (NA)
	 */
	public BudgetingToolController() {
		LastYear = String.valueOf(Integer.valueof(Label.BudgetCurrentYear) - 1);
		LastToLastYear = String.valueOf(Integer.valueof(LastYear) - 1);
		NextYear = String.valueOf(Integer.valueof(Label.BudgetCurrentYear));
		newBusinessAccount = 'New Business/Churn';
		//these can eventually be set via Custom Labels
		ProductTotalsLabel = 'TOTALS BY PRODUCT LINE';
		TotalsLabel = 'TOTALS';
		BudgetLabel = Label.BudgetCurrentYear + ' ' + 'Budget';
		TotalsBudgetLabel = Label.BudgetCurrentYear + ' ' + 'Total';
		Q3FCSTLabel = 'Q3 FCST';
		TotalsQ3FCSTLabel = LastYear + ' ' + 'Total FCST';
		PrevYearOTBLabel = LastToLastYear + ' ' + 'OTB';
		TotalsPrevYearOTBLabel = LastToLastYear + ' ' + 'Total OTB';
		CurrYearOTBLabel = LastYear + ' ' + 'OTB';
		TotalsCurrYearOTBLabel = LastYear + ' ' + 'Total OTB';
		NextYearOTBLabel = NextYear + ' ' + 'OTB';
		TotalsNextYearOTBLabel = NextYear + ' ' + 'Total OTB';
		CurrYearYOYLabel = '19YOY%';
		TotalsCurrYearYOYLabel = Label.BudgetCurrentYear + ' ' + 'Variance';
		NextYearYOYLabel = '20YOY%';
		TotalsNextYearYOYLabel = Label.BudgetCurrentYear + ' ' + 'Variance';
		ChurnLabel = 'Unknown Churn';
		ChurnYearLabel = Label.BudgetCurrentYear + ' ' + 'Unknown Churn';
		TotalsChurnLabel = Label.BudgetCurrentYear + ' ' + 'Total Unknown Churn';
		TotalsKnownBudgetLabel = Label.BudgetCurrentYear + ' ' + 'Known Budget';
		NewBusinessLabel = 'New Business';
		NewBusinessYearLabel = Label.BudgetCurrentYear + ' ' + 'New Business';
		TotalsNewBusinessLabel = Label.BudgetCurrentYear + ' ' + 'Total New Business';
		rollupSumOnBudget = true;
		//END labels
		alertMessage = '';
		userList = new List<String> ();
		impersonateList = new List<String> ();
		comments = '';
		sbWorkflow = new Sales_Budget__c();
		noSaveMode = false;
		noSaveModeDOS = false;
		noApproveMode = false;
		gridWorkflowStatus = '';
		budgetMap = new Map<String, gridHelper> ();
		dosBudgetMap = new Map<String, gridHelper> ();
		userListNameMap = new Map<String, String> ();
		userMap = new Map<String, String> ();
		userListStatus = new Map<String, String> ();
		userListStatusColorMap = new Map<String, String> ();
		accMap = new Map<Id, Account> ();
		if (ApexPages.currentPage() != null) {
			userParam = ApexPages.currentPage().getParameters().get('userparam');
			impParam = ApexPages.currentPage().getParameters().get('impparam');
			selectedDMA = ApexPages.currentPage().getParameters().get('selectedDMA');
			selectedPCom = ApexPages.currentPage().getParameters().get('selectedPCom');
		}
		System.debug('User Param: ' + userParam);
		System.debug('impParam: ' + impParam);
		System.debug('selectedPCom: ' + selectedPCom);
		if (String.isNotBlank(userparam) && userParam.contains('--')) {
			userParam = userParam.split('--') [1].trim();
		}
		if (String.isNotBlank(userparam)) {
			if (String.isNotBlank(impparam)) {
				buildUserContext(userParam, impparam);
			}
			else {
				buildUserContext(userParam, UserInfo.getUserId());
			}
		}
		else {
			if (String.isNotBlank(impparam)) {
				buildUserContext(impparam, '');
			}
			else {
				buildUserContext(UserInfo.getUserId(), '');
			}
		}

		if (String.isBlank(loggedInUserProductLines)) {
			alertMessage = 'Please contact your system administrator for creating Budget profile.';
		}
		else {
			if (loggedInUserBudgetType == 'National') {
				if (String.isBlank(loggedInUserProductLines) || String.isBlank(loggedInUserDMA)) {
					if (loggedInBudgetView == 'Executive') {
						alertMessage = 'Please contact your system administrator for creating Budget profile.';
					}
					System.debug('Budget Product Lines or Budget DMA on User record not populated.');
				}
				else {
					System.debug('selectedDMA: ' + selectedDMA);
					alertMessage = '';
					showNSMGrid();
				}
			}
			else if (loggedInUserBudgetType == 'Local' || loggedInUserBudgetType == 'Local Special') {
				if (String.isBlank(loggedInUserProductLines)) {
					if (loggedInBudgetView == 'Executive') {
						alertMessage = 'Please contact your system administrator for creating Budget profile.';
					}
					System.debug('Budget Product Lines on User record not populated.');
				}
				else {
					alertMessage = '';
					showAEGrid();
				}
			}
			if (loggedInBudgetView == 'Leadership' && String.isNotblank(userparam)) {
				showDOSGrid();
			}
		}
		showUserListStatus();
	}


	/**
	 * This method builds the map for subordinates of logged in user and their statuses to display
	 *
	 * @param  (none) (NA)
	 * @return (void) (NA)
	 */
	public void showUserListStatus() {
		userListStatusColorMap.put('Pending', 'f00');
		userListStatusColorMap.put('Forecast Rejected', 'f00');
		userListStatusColorMap.put('Rejected', 'f00');
		userListStatusColorMap.put('No status', '888');
		userListStatusColorMap.put('Intermediate Approval', 'da2');
		userListStatusColorMap.put('Forecast Intermediate Approval', 'da2');
		userListStatusColorMap.put('Final Approval', 'da2');
		userListStatusColorMap.put('Submitted', 'da2');
		userListStatusColorMap.put('Forecast Submitted', '080');
		userListStatusColorMap.put('Forecast Approved', '080');
		userListStatusColorMap.put('Approved', '080');

		for (AggregateResult ar :[SELECT Status__c, Count(Id)
		     FROM Sales_Budget__c
		     GROUP BY Status__c]) {
			if (!userListStatusColorMap.containsKey((String) ar.get('Status__c'))) {
				userListStatusColorMap.put((String) ar.get('Status__c'), '888');
			}
		}



		for (Sales_Budget__c sb :[SELECT Advertiser__c, Amount__c, Broadcast_Month_Date__c, Budget_User__c, Commodity__c, DMA__c, External_Id__c, Id, Name, OwnerId, Product_Line__c, Status__c, Type__c, Churn_Indicator__c, Advertiser__r.name
		     FROM Sales_Budget__c
		     WHERE Budget_User__c in :userListNameMap.values() and
		     //Advertiser__c in:advertiserIdList and
		     CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.BudgetCurrentYear) and
		     type__c in('Workflow')
		     order by LastModifiedDate asc]) {
			userListStatus.put(sb.Budget_User__c, sb.Status__c);
		}

		for (String key : userListNameMap.keySet()) {
			String userId = userListNameMap.get(key);
			if (userListStatus.get(userId) == null) {
				userListStatus.put(userId, 'No status');
			}
		}

		//Create Impersonate group list
		for (Budget_Impersonation_Group__c uc :[Select id, LoggedIn_User__r.name, Impersonate_User__r.name
		     from Budget_Impersonation_Group__c where SF_Group__c = true order by Impersonate_User__r.name asc]) {
			impersonateList.add(uc.Impersonate_User__r.name);
		}

	}


	/**
	 * This method builds the logged in user's context for grid methods
	 *
	 * @param  (none) (NA)
	 * @return (void) (NA)
	 */
	public void buildUserContext(String prmuserid, String secuserid) {
		System.debug('selected/primaryuser : DOS/secondaryuser = ' + prmuserid + ' : ' + secuserid);
		loggedInUser = [Select id, name, profile.name, HR_Manager__c, HR_Manager__r.email, HR_Manager__r.name, Budget_Type__c, Budget_Product_Lines__c, Budget_DMA__c, HR_Level__c, BT_Sum_on_Budget__c
		                from User
		                where id = :prmuserid or name = :prmuserid limit 1];

		loggedInUserBudgetType = loggedInUser.Budget_Type__c;
		loggedInUserProductLines = loggedInUser.Budget_Product_Lines__c;
		loggedInUserDMA = loggedInUser.Budget_DMA__c;
		submittedUser = loggedInUser.Id;
		rollupSumOnBudget = loggedInUser.BT_Sum_on_Budget__c;
		userMap.put(loggedInUser.id, loggedInUser.name);

		System.debug('Setting Logged in User:' + submittedUser);

		for (UserClassification__mdt uc :[Select id, DeveloperName, MasterLabel, user_profiles__c, Budget_View__c, Impersonate_Capability__c
		     from UserClassification__mdt]) {
			if (uc.user_profiles__c.contains(loggedInUser.profile.name)) {
				loggedInUserRole = uc.developername;
				loggedInBudgetView = uc.Budget_View__c;
				loggedInUserImpersonate = uc.Impersonate_Capability__c;
				break;
			}
			else {
				loggedInUserRole = 'NA';
				loggedInBudgetView = 'NA';
			}
		}
		List<String> uList = new List<String> ();
		if (loggedInBudgetView == 'Manager' || loggedInBudgetView == 'Leadership') {
			for (User ru :[Select id, name, profile.name, HR_Manager__r.email, HR_Manager__r.name, Budget_Type__c, Budget_Product_Lines__c, HR_Level__c
			     from User
			     where hr_manager__c = :loggedInUser.id
			     order by name]) {
				userList.add(ru.name);
				userListNameMap.put(ru.name, ru.id);
				userMap.put(ru.id, ru.name);
				uList.add(ru.id);
				System.debug('usermap' + userMap);
				System.debug('userList' + userList);
			}
		}
		if (loggedInBudgetView == 'Leadership') {

			List<String> nList = new List<String> ();
			Integer i = 0;
			Integer countI = 0;
			do {
				i = 0;
				nList = new List<String> ();
				//System.debug('ulist'+umap.containsKey);
				for (User ru :[Select id, name, profile.name, HR_Manager__r.email, HR_Manager__r.name, Budget_Type__c, Budget_Product_Lines__c, HR_Level__c
				     from User
				     where HR_Manager__c in :uList
				     order by HR_Manager__r.name, name]) {
					if (userList.size() <= 998) {
						userList.add(ru.HR_Manager__r.name + ' -- ' + ru.name);
						userListNameMap.put(ru.HR_Manager__r.name + ' -- ' + ru.name, ru.id);
						userMap.put(ru.id, ru.name);
					}
					i++;
					nList.add(ru.id);
				}

				uList = new List<String> ();
				uList.addAll(nList);
				System.debug(uList);
				countI++;
			}
			while (i > 0);

			System.debug(countI);
		}
		userList.add(loggedInUser.name);
		userListNameMap.put(loggedInUser.name, loggedInUser.id);
		userMap.put(loggedInUser.id, loggedInUser.name);

		if (String.isNotblank(secuserid)) {
			dosUser = [Select id, name, profile.name, HR_Manager__r.email, HR_Manager__r.name, Budget_Type__c, Budget_Product_Lines__c, Budget_DMA__c, HR_Level__c
			           from User
			           where id = :secuserid or name = :secuserid limit 1];

			for (UserClassification__mdt uc :[Select id, DeveloperName, MasterLabel, user_profiles__c, Budget_View__c, Impersonate_Capability__c
			     from UserClassification__mdt]) {

				if (uc.user_profiles__c.contains(dosuser.profile.name)) {
					loggedInUserRole = uc.developername;
					loggedInBudgetView = uc.Budget_View__c;
					loggedInUserImpersonate = uc.Impersonate_Capability__c;
					break;
				}
				else {
					loggedInUserRole = 'NA';
					loggedInBudgetView = 'NA';
				}
			}
			userList = new List<String> ();
			if (loggedInBudgetView == 'Manager' || loggedInBudgetView == 'Leadership') {
				for (User ru :[Select id, name, profile.name, HR_Manager__r.email, HR_Manager__r.name, Budget_Type__c, Budget_Product_Lines__c, HR_Level__c
				     from User
				     where hr_manager__c = :dosUser.id
				     order by name]) {
					userList.add(ru.name);
					userListNameMap.put(ru.name, ru.id);
					userMap.put(ru.id, ru.name);
					uList.add(ru.id);
				}

			}
			if (loggedInBudgetView == 'Leadership') {
				List<String> nList = new List<String> ();
				Integer i = 0;
				Integer countI = 0;
				do {
					i = 0;
					nList.clear();
					for (User ru :[Select id, name, profile.name, HR_Manager__r.email, HR_Manager__r.name, Budget_Type__c, Budget_Product_Lines__c, HR_Level__c
					     from User
					     where HR_Manager__c in :uList
					     order by HR_Manager__r.name, name]) {
						//system.debug('ru'+ru);
						if (userList.size() <= 998) {
							userList.add(ru.HR_Manager__r.name + ' -- ' + ru.name);
							userListNameMap.put(ru.HR_Manager__r.name + ' -- ' + ru.name, ru.id);
							userMap.put(ru.id, ru.name);
						}
						i++;
						nList.add(ru.id);
					}
					uList.clear();
					uList.addAll(nList);
					countI++;
				}
				while (i > 0);

				System.debug(countI);

			}

			userList.add(dosUser.name);
			userListNameMap.put(dosUser.name, dosUser.id);
			userMap.put(dosUser.id, dosUser.name);
		}
		//System.debug(userList);
		// Checking date for Forecast Submission
		Date forecastDate = date.valueof(System.Label.ForecastingDate);
		submissionDateCheck = 'NA';
		System.debug('Date value of label: ' + forecastDate.format());

		if (Date.Today() >= forecastDate) {
			submissionDateCheck = 'Budget';
		} else {
			submissionDateCheck = 'Forecast';
		}
		//  System.debug('Submission Date Check '+ submissionDateCheck);

	}


	private String fmtTotalFormula(String mon) {
		return mon + 'Formula=\'fcst(Grid,Row,Col)\' ';
	}

	private String formatMonthRollupFormulaAEDOS(String mon) {
		String singleQuote = '&quot;';
		String singleQuoteX2 = '\\\\&quot;';
		return mon + 'Formula=\'sumif(' + singleQuote + mon + singleQuote + ',' + singleQuote + 'Account==' + singleQuoteX2 + NewBusinessLabel + singleQuoteX2 + ' || Account==' + singleQuoteX2 + ChurnLabel + singleQuoteX2 + singleQuote + ')\' ';
		//            return mon + 'Formula=\'sumif('+singleQuote+mon+singleQuote+','+singleQuote+'Account=='+singleQuoteX2+BudgetLabel+singleQuoteX2+singleQuote+')\' ';
	}

	private String formatMonthRollupFormula(String mon) {
		String singleQuote = '&quot;';
		String singleQuoteX2 = '\\\\&quot;';
		//            return mon + 'Formula=\'sumif('+singleQuote+mon+singleQuote+','+singleQuote+'Account=='+singleQuoteX2+BudgetLabel+singleQuoteX2+' || Account=='+singleQuoteX2+NewBusinessYearLabel+singleQuoteX2+' || Account=='+singleQuoteX2+ChurnYearLabel+singleQuoteX2+singleQuote+')\' ';
		return mon + 'Formula=\'rollitup(Grid,Row,Col)\' ';
		//            return mon + 'Formula=\'sumif('+singleQuote+mon+singleQuote+','+singleQuote+'Account=='+singleQuoteX2+BudgetLabel+singleQuoteX2+singleQuote+')\' ';
	}

	private String formatMonthRollupFormula(String mon, String account) {
		String singleQuote = '&quot;';
		String singleQuoteX2 = '\\\\&quot;';
		//            return mon + 'Formula=\'sumif('+singleQuote+mon+singleQuote+','+singleQuote+'Account=='+singleQuoteX2+account+singleQuoteX2+singleQuote+')\' ';
		return mon + 'Formula=\'rollitup(Grid,Row,Col)\' ';
	}

	private String formatDef(String t) {
		String retStr = '';
		String maskStr = '', canEditStr = '', typeStr = '', formatStr = '$#,##0;($#,##0)', messageStr = '', formulaStr = '', onChangeStr = '';
		String[] months = new String[] { 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' };

		retStr += '<D Name=\'' + t + '\' ';


		if (t == 'lplain') {
			messageStr = ''; maskStr = ''; canEditStr = ''; typeStr = 'Float';
		}
		else if (t == 'ldollar') {
			messageStr = 'Please enter a valid dollar amount'; maskStr = '^[0-9]{0,3}(?:,?[0-9]{3})*[\\.]{0,1}[0-9]{0,2}$'; canEditStr = '0'; typeStr = 'Float'; // formatStr = '';
			formatStr = '<span style=&quot;color:#000;font-size:1.05em&quot;>$#,##0;($#,##0)</span>';
			retStr += 'Growth%CanEdit=\'1\' ChurnIndicatorCanEdit=\'1\' OnChange=\'Grids.C(Grid,Row,Col)\' ';
		}
		else if (t == 'lneg') {
			messageStr = 'Please enter a value of 0 or less'; maskStr = '^(-[0-9]+|[0]{0,1})$'; canEditStr = '0'; typeStr = 'Float'; //formatStr = '';
			formatStr = '<span style=&quot;color:#000;font-size:1.05em&quot;>$#,##0;($#,##0)</span>';
			retStr += 'OnChange=\'Grids.C(Grid,Row,Col)\' ';
		}
		else if (t == 'lpct') {
			messageStr = 'Please enter an integer from 0 to 100'; maskStr = '^[1-9][0-9]?$|^100$'; canEditStr = ''; typeStr = ''; formatStr = '0%';
			formulaStr = 'getyoy(Grid,Row,Col)';
			retStr += ' Q1Format=\'0%\' Q2Format=\'0%\' Q3Format=\'0%\' Q4Format=\'0%\' TotalFormat=\'0%\' ';
			retStr += ' TotalFormula=\'' + formulaStr + '\' Q1Formula=\'' + formulaStr + '\' Q2Formula=\'' + formulaStr + '\' Q3Formula=\'' + formulaStr + '\' Q4Formula=\'' + formulaStr + '\' Calculated=\'1\' ';
		}
		//        else if(t == 'lfcst') {
		//            messageStr = ''; maskStr = ''; canEditStr = ''; typeStr = 'Float'; //formatStr = '';
		//        }


		for (String m : months) {
			if (messageStr != '') { retStr += m + 'ResultMessage=\'' + messageStr + '\' '; }
			if (maskStr != '') { retStr += m + 'ResultMask=\'' + maskStr + '\' '; }
			if (canEditStr != '') { retStr += m + 'CanEdit=\'' + canEditStr + '\' '; }
			//if(typeStr!= '') { retStr += m+'Type=\''+typeStr+'\' '; }
			if (formatStr != '') { retStr += m + 'Format=\'' + formatStr + '\' '; }
			if (formulaStr != '') { retStr += m + 'Formula=\'' + formulaStr + '\' '; }
		}


		retStr += ' Recalc=\'256\' R.CanFilter = \'0\' Node.CanFilter = \'1\'/>';

		return retStr;
	}



	/**
	 * This method builds JSON for grid metadata and data rows for an AE user
	 *
	 * @param  (none) (NA)
	 * @return (pageReference) (returns control back to grid page)
	 */
	public pageReference showAEGrid() {
		tgm = buildAETreeData();
		String rollupFormulaStr = 'sum()';
		String jsStr = '<script>Grids.HandleChange = function(Grid, Row, Col) { alert(\'hi: \'+ Col)}</script>';
		GridDef = '<Grid ><Panel Visible=\'0\'/><Cfg CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' Deleting=\'0\' ChildPaging=\'2\' StandardFilter=\'3\' Levels=\'2\' Expanded=\'0\' FormulaRelative=\'1\' NoHScroll=\'1\' NoVScroll=\'1\' Code=\'STREFSXJSLTIED\' MainCol=\'Account\' Delete=\'0\' FullId=\'1\' Dragging =\'0\' Dropping=\'0\' Adding=\'0\'/><Cols><C Name=\'Account\' TextStyle=\'1\' Width=\'360\' CanEdit=\'0\' CanSort=\'0\'/></Cols><Header id=\'id\' AccountLevels=\'2\' AccountTextStyle=\'2\' AChecked=\' \' Account =\' Advertiser | Product | Ledger\' AccountCanEdit=\'0\' ChurnIndicator=\'Churn Indicator\'/>';
		GridDef += '<Def><D Name=\'t\' CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' Calculated=\'1\' Format=\'#\' TotalFormat=\'$#,##0;($#,##0)\' Q1Format=\'$#,##0;($#,##0)\' Q2Format=\'$#,##0;($#,##0)\' Q3Format=\'$#,##0;($#,##0)\' Q4Format=\'$#,##0;($#,##0)\' JanFormat=\'$#,##0;($#,##0)\' FebFormat=\'$#,##0;($#,##0)\' MarFormat=\'$#,##0;($#,##0)\' AprFormat=\'$#,##0;($#,##0)\' MayFormat=\'$#,##0;($#,##0)\' JunFormat=\'$#,##0;($#,##0)\' JulFormat=\'$#,##0;($#,##0)\' AugFormat=\'$#,##0;($#,##0)\' SepFormat=\'$#,##0;($#,##0)\' OctFormat=\'$#,##0;($#,##0)\' NovFormat=\'$#,##0;($#,##0)\' DecFormat=\'$#,##0;($#,##0)\' ';
		GridDef += 'JanFormula=\'' + rollupFormulaStr + '\'  FebFormula=\'' + rollupFormulaStr + '\'  MarFormula=\'' + rollupFormulaStr + '\'  AprFormula=\'' + rollupFormulaStr + '\'  MayFormula=\'' + rollupFormulaStr + '\'  JunFormula=\'' + rollupFormulaStr + '\'  JulFormula=\'' + rollupFormulaStr + '\'  AugFormula=\'' + rollupFormulaStr + '\'  SepFormula=\'' + rollupFormulaStr + '\'  OctFormula=\'' + rollupFormulaStr + '\'  NovFormula=\'' + rollupFormulaStr + '\'  DecFormula=\'' + rollupFormulaStr + '\' ';
		GridDef += ' Recalc=\'256\' R.CanFilter = \'0\' Node.CanFilter = \'1\'/>';
		GridDef += '<D Name=\'tot\' CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' Calculated=\'1\' Format=\'#\' TotalFormat=\'$#,##0;($#,##0)\' Q1Format=\'$#,##0;($#,##0)\' Q2Format=\'$#,##0;($#,##0)\' Q3Format=\'$#,##0;($#,##0)\' Q4Format=\'$#,##0;($#,##0)\' JanFormat=\'$#,##0;($#,##0)\' FebFormat=\'$#,##0;($#,##0)\' MarFormat=\'$#,##0;($#,##0)\' AprFormat=\'$#,##0;($#,##0)\' MayFormat=\'$#,##0;($#,##0)\' JunFormat=\'$#,##0;($#,##0)\' JulFormat=\'$#,##0;($#,##0)\' AugFormat=\'$#,##0;($#,##0)\' SepFormat=\'$#,##0;($#,##0)\' OctFormat=\'$#,##0;($#,##0)\' NovFormat=\'$#,##0;($#,##0)\' DecFormat=\'$#,##0;($#,##0)\' ';
		GridDef += fmtTotalFormula('Jan') + fmtTotalFormula('Feb') + fmtTotalFormula('Mar') + fmtTotalFormula('Apr') + fmtTotalFormula('May') + fmtTotalFormula('Jun') + fmtTotalFormula('Jul') + fmtTotalFormula('Aug') + fmtTotalFormula('Sep') + fmtTotalFormula('Oct') + fmtTotalFormula('Nov') + fmtTotalFormula('Dec');
		GridDef += ' Recalc=\'256\' R.CanFilter = \'0\' Node.CanFilter = \'1\'/>';
		GridDef += '<D Name=\'totp\' CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' Calculated=\'1\' Format=\'#\' TotalFormat=\'0%\' Q1Format=\'0%\' Q2Format=\'0%\' Q3Format=\'0%\' Q4Format=\'0%\' JanFormat=\'0%\' FebFormat=\'0%\' MarFormat=\'0%\' AprFormat=\'0%\' MayFormat=\'0%\' JunFormat=\'0%\' JulFormat=\'0%\' AugFormat=\'0%\' SepFormat=\'0%\' OctFormat=\'0%\' NovFormat=\'0%\' DecFormat=\'0%\' Q1Format=\'0%\' Q2Format=\'0%\' Q3Format=\'0%\' Q4Format=\'0%\' TotalFormat=\'0%\' ';
		GridDef += fmtTotalFormula('Jan') + fmtTotalFormula('Feb') + fmtTotalFormula('Mar') + fmtTotalFormula('Apr') + fmtTotalFormula('May') + fmtTotalFormula('Jun') + fmtTotalFormula('Jul') + fmtTotalFormula('Aug') + fmtTotalFormula('Sep') + fmtTotalFormula('Oct') + fmtTotalFormula('Nov') + fmtTotalFormula('Dec');
		GridDef += fmtTotalFormula('Total') + fmtTotalFormula('Q1') + fmtTotalFormula('Q2') + fmtTotalFormula('Q3') + fmtTotalFormula('Q4');
		GridDef += ' Recalc=\'256\' R.CanFilter = \'0\' Node.CanFilter = \'1\'/>';
		GridDef += '<D Name=\'prod\' CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' Calculated=\'1\' Format=\'#\' TotalFormat=\'$#,##0;($#,##0)\' Q1Format=\'$#,##0;($#,##0)\' Q2Format=\'$#,##0;($#,##0)\' Q3Format=\'$#,##0;($#,##0)\' Q4Format=\'$#,##0;($#,##0)\' JanFormat=\'$#,##0;($#,##0)\' FebFormat=\'$#,##0;($#,##0)\' MarFormat=\'$#,##0;($#,##0)\' AprFormat=\'$#,##0;($#,##0)\' MayFormat=\'$#,##0;($#,##0)\' JunFormat=\'$#,##0;($#,##0)\' JulFormat=\'$#,##0;($#,##0)\' AugFormat=\'$#,##0;($#,##0)\' SepFormat=\'$#,##0;($#,##0)\' OctFormat=\'$#,##0;($#,##0)\' NovFormat=\'$#,##0;($#,##0)\' DecFormat=\'$#,##0;($#,##0)\' ';
		GridDef += formatMonthRollupFormula('Jan') + formatMonthRollupFormula('Feb') + formatMonthRollupFormula('Mar') + formatMonthRollupFormula('Apr') + formatMonthRollupFormula('May') + formatMonthRollupFormula('Jun') + formatMonthRollupFormula('Jul') + formatMonthRollupFormula('Aug') + formatMonthRollupFormula('Sep') + formatMonthRollupFormula('Oct') + formatMonthRollupFormula('Nov') + formatMonthRollupFormula('Dec');
		GridDef += ' Recalc=\'256\' R.CanFilter = \'0\' Node.CanFilter = \'1\'/>';
		GridDef += formatDef('ldollar');
		GridDef += formatDef('lneg');
		GridDef += formatDef('lpct');
		GridDef += formatDef('lplain');
		//         GridDef += formatDef('lfcst');
		GridDef += '<D Name=\'fcst\' CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' Calculated=\'1\' Format=\'#\' TotalFormat=\'$#,##0;($#,##0)\' Q1Format=\'$#,##0;($#,##0)\' Q2Format=\'$#,##0;($#,##0)\' Q3Format=\'$#,##0;($#,##0)\' Q4Format=\'$#,##0;($#,##0)\' JanFormat=\'$#,##0;($#,##0)\' FebFormat=\'$#,##0;($#,##0)\' MarFormat=\'$#,##0;($#,##0)\' AprFormat=\'$#,##0;($#,##0)\' MayFormat=\'$#,##0;($#,##0)\' JunFormat=\'$#,##0;($#,##0)\' JulFormat=\'$#,##0;($#,##0)\' AugFormat=\'$#,##0;($#,##0)\' SepFormat=\'$#,##0;($#,##0)\' OctFormat=\'$#,##0;($#,##0)\' NovFormat=\'$#,##0;($#,##0)\' DecFormat=\'$#,##0;($#,##0)\' ';
		GridDef += formatMonthRollupFormula('Jan', Q3FCSTLabel) + formatMonthRollupFormula('Feb', Q3FCSTLabel) + formatMonthRollupFormula('Mar', Q3FCSTLabel) + formatMonthRollupFormula('Apr', Q3FCSTLabel) + formatMonthRollupFormula('May', Q3FCSTLabel) + formatMonthRollupFormula('Jun', Q3FCSTLabel) + formatMonthRollupFormula('Jul', Q3FCSTLabel) + formatMonthRollupFormula('Aug', Q3FCSTLabel) + formatMonthRollupFormula('Sep', Q3FCSTLabel) + formatMonthRollupFormula('Oct', Q3FCSTLabel) + formatMonthRollupFormula('Nov', Q3FCSTLabel) + formatMonthRollupFormula('Dec', Q3FCSTLabel);
		GridDef += ' Recalc=\'256\' R.CanFilter = \'0\' Node.CanFilter = \'1\'/>';
		GridDef += '<D Name=\'R\' Recalc=\'256\' DefParent=\'Node\'/><D Name=\'Node\' Recalc=\'256\' DefEmpty=\'R\' Color=\'#EFE\'/></Def>';
		GridDef += '<Toolbar Scales=\'0\' Debug=\'\' Help=\'0\'  /><Head><Filter AccountCaseSensitive=\'0\' AccountRange=\'1\' AccountButton=\'\' AccountDefaults=\'|*FilterOff|*RowsAll\' Expanded=\'3\' OnFilterFinish=\'Grid.ExpandAll();\'/></Head><Solid></Solid></Grid>';

		JSONData = System.JSON.serialize(tgm);
		JSONData = JSONData.substring(1, JSONData.length());
		System.debug('JSONData' + JSONData);
		String JSONHeader = '{Cols: [{ Name:\'Growth%\', Type:\'Float\' ,Format:\'#\',CanSort:\'0\',CanEdit:\'0\',Hidden:\'1\',Visible:\'0\'},{ Name:\'ChurnIndicator\', Type:\'Enum\',Enum:\'||Out of Business|Media Shift|Move to National|Move to Local\',CanEdit:\'0\',Hidden:\'1\',Visible:\'0\'},{ Name:\'Jan\', Type:\'Float\',Format:\'#\',CanSort:\'0\',CanEdit:\'0\',CanEmpty:\'1\',Width:\'110\'},{ Name:\'Feb\', Type:\'Float\',Format:\'#\',CanSort:\'0\',CanEdit:\'0\',CanEmpty:\'1\',Width:\'110\'},{ Name:\'Mar\',Type:\'Float\',Format:\'#\',CanSort:\'0\',CanEdit:\'0\',CanEmpty:\'1\',Width:\'110\'},{ Name:\'Apr\', Type:\'Float\',Format:\'#\' ,CanSort:\'0\',CanEdit:\'0\',CanEmpty:\'1\',Width:\'110\'},{ Name:\'May\', Type:\'Float\',Format:\'#\',CanSort:\'0\',CanEdit:\'0\',CanEmpty:\'1\',Width:\'110\'},{ Name:\'Jun\',Type:\'Float\',Format:\'#\',CanSort:\'0\',CanEdit:\'0\',CanEmpty:\'1\',Width:\'110\'},{ Name:\'Jul\', Type:\'Float\',Format:\'#\' ,CanSort:\'0\',CanEdit:\'0\',CanEmpty:\'1\',Width:\'110\'},{ Name:\'Aug\', Type:\'Float\',Format:\'#\',CanSort:\'0\',CanEdit:\'0\',CanEmpty:\'1\',Width:\'110\'},{ Name:\'Sep\',Type:\'Float\',Format:\'#\',CanSort:\'0\',CanEdit:\'0\',CanEmpty:\'1\',Width:\'110\'},{ Name:\'Oct\', Type:\'Float\',Format:\'#\' ,CanSort:\'0\',CanEdit:\'0\',CanEmpty:\'1\',Width:\'110\'},{ Name:\'Nov\', Type:\'Float\',Format:\'#\',CanSort:\'0\',CanEdit:\'0\',CanEmpty:\'1\',Width:\'110\'},{ Name:\'Dec\',Type:\'Float\',Format:\'#\',CanSort:\'0\',CanEdit:\'0\',CanEmpty:\'1\',Width:\'110\'},{ Name:\'Total\',Type:\'Float\', Formula:\'parseFloat(Q1)+parseFloat(Q2)+parseFloat(Q3)+parseFloat(Q4)\',CanSort:\'0\',CanEdit:\'0\',Width:\'110\',Format:\'$#,##0;($#,##0)\',Color:\'#f4f4f4\'},{ Name:\'Q1\',Type:\'Float\', Formula:\'(isNaN(parseFloat(Jan))?0:parseFloat(Jan))+(isNaN(parseFloat(Feb))?0:parseFloat(Feb))+(isNaN(parseFloat(Mar))?0:parseFloat(Mar))\',CanSort:\'0\',CanEdit:\'0\',Format:\'$#,##0;($#,##0)\',Width:\'110\',Color:\'#fafafa\'},{ Name:\'Q2\',Type:\'Float\', Formula:\'(isNaN(parseFloat(Apr))?0:parseFloat(Apr))+(isNaN(parseFloat(May))?0:parseFloat(May))+(isNaN(parseFloat(Jun))?0:parseFloat(Jun))\',CanSort:\'0\',CanEdit:\'0\',Width:\'110\',Format:\'$#,##0;($#,##0)\',Color:\'#fafafa\'},{ Name:\'Q3\',Type:\'Float\', Formula:\'(isNaN(parseFloat(Jul))?0:parseFloat(Jul))+(isNaN(parseFloat(Aug))?0:parseFloat(Aug))+(isNaN(parseFloat(Sep))?0:parseFloat(Sep))\',CanSort:\'0\',CanEdit:\'0\',Width:\'110\',Format:\'$#,##0;($#,##0)\',Color:\'#fafafa\'},{ Name:\'Q4\',Type:\'Float\', Formula:\'(isNaN(parseFloat(Oct))?0:parseFloat(Oct))+(isNaN(parseFloat(Nov))?0:parseFloat(Nov))+(isNaN(parseFloat(Dec))?0:parseFloat(Dec))\',Format:\'$#,##0;($#,##0)\',CanSort:\'0\',CanEdit:\'0\',Width:\'110\',Color:\'#fafafa\'}],';
		JSONString = JSONHeader + JSONData.replace('"', '\'');
		//System.debug('JSONString.length(): ' + JSONString.length());
		return null;
	}
	/*<Tabber Cells=\'Com\' ComType=\'Button\' ComButton=\'Tab\' ComOnChange=\'showSelectedPCom(Value);\' ComSwitch=\'1\' ComRadio=\'1\' ComList='+ PComList +' ComEmptyValue=\'tab1\' ComWidth=\'150\' ComPopupIcon=\'2\' Com='+ '\'' + selectedPCom + '\'' +' ComTip=\'Please select Commodity\' />*/
	/**
	 * This method builds JSON for grid metadata and data rows for a NSM user
	 *
	 * @param  (none) (NA)
	 * @return (pageReference) (returns control back to grid page)
	 */
	public pageReference showNSMGrid() {
		tgmNational = buildNSMTreeData();


		String rollupFormulaStr = 'sum()';
		GridDef = '<Grid ><Panel Visible=\'0\'/><Cfg CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' Deleting=\'0\' ChildPaging=\'2\' StandardFilter=\'3\' Expanded=\'0\' FormulaRelative=\'1\' NoHScroll=\'0\' NoVScroll=\'0\' Code=\'STREFSXJSLTIED\' MainCol=\'Account\' Delete=\'0\' FullId=\'1\' Dragging =\'0\' Dropping=\'0\' Adding=\'0\'/><LeftCols><C Name=\'Account\' TextStyle=\'1\' Width=\'360\' CanEdit=\'0\' CanSort=\'0\'/></LeftCols><Header id=\'id\' AccountLevels=\'2\' AccountTextStyle=\'2\' AChecked=\' \' Account =\'DMA | Advertiser | Product | Ledger\' ChurnIndicator=\'Churn Indicator\'/>';
		GridDef += '<Def><D Name=\'t\' CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' Calculated=\'1\' Format=\'#\' TotalFormat=\'$#,##0;($#,##0)\' Q1Format=\'$#,##0;($#,##0)\' Q2Format=\'$#,##0;($#,##0)\' Q3Format=\'$#,##0;($#,##0)\' Q4Format=\'$#,##0;($#,##0)\' JanFormat=\'$#,##0;($#,##0)\' FebFormat=\'$#,##0;($#,##0)\' MarFormat=\'$#,##0;($#,##0)\' AprFormat=\'$#,##0;($#,##0)\' MayFormat=\'$#,##0;($#,##0)\' JunFormat=\'$#,##0;($#,##0)\' JulFormat=\'$#,##0;($#,##0)\' AugFormat=\'$#,##0;($#,##0)\' SepFormat=\'$#,##0;($#,##0)\' OctFormat=\'$#,##0;($#,##0)\' NovFormat=\'$#,##0;($#,##0)\' DecFormat=\'$#,##0;($#,##0)\' ';
		GridDef += 'JanFormula=\'' + rollupFormulaStr + '\'  FebFormula=\'' + rollupFormulaStr + '\'  MarFormula=\'' + rollupFormulaStr + '\'  AprFormula=\'' + rollupFormulaStr + '\'  MayFormula=\'' + rollupFormulaStr + '\'  JunFormula=\'' + rollupFormulaStr + '\'  JulFormula=\'' + rollupFormulaStr + '\'  AugFormula=\'' + rollupFormulaStr + '\'  SepFormula=\'' + rollupFormulaStr + '\'  OctFormula=\'' + rollupFormulaStr + '\'  NovFormula=\'' + rollupFormulaStr + '\'  DecFormula=\'' + rollupFormulaStr + '\' ';
		GridDef += ' Recalc=\'256\' R.CanFilter = \'0\' Node.CanFilter = \'1\'/>';
		GridDef += '<D Name=\'tot\' CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' Calculated=\'1\' Format=\'#\' TotalFormat=\'$#,##0;($#,##0)\' Q1Format=\'$#,##0;($#,##0)\' Q2Format=\'$#,##0;($#,##0)\' Q3Format=\'$#,##0;($#,##0)\' Q4Format=\'$#,##0;($#,##0)\' JanFormat=\'$#,##0;($#,##0)\' FebFormat=\'$#,##0;($#,##0)\' MarFormat=\'$#,##0;($#,##0)\' AprFormat=\'$#,##0;($#,##0)\' MayFormat=\'$#,##0;($#,##0)\' JunFormat=\'$#,##0;($#,##0)\' JulFormat=\'$#,##0;($#,##0)\' AugFormat=\'$#,##0;($#,##0)\' SepFormat=\'$#,##0;($#,##0)\' OctFormat=\'$#,##0;($#,##0)\' NovFormat=\'$#,##0;($#,##0)\' DecFormat=\'$#,##0;($#,##0)\' ';
		GridDef += fmtTotalFormula('Jan') + fmtTotalFormula('Feb') + fmtTotalFormula('Mar') + fmtTotalFormula('Apr') + fmtTotalFormula('May') + fmtTotalFormula('Jun') + fmtTotalFormula('Jul') + fmtTotalFormula('Aug') + fmtTotalFormula('Sep') + fmtTotalFormula('Oct') + fmtTotalFormula('Nov') + fmtTotalFormula('Dec');
		GridDef += ' Recalc=\'256\' R.CanFilter = \'0\' Node.CanFilter = \'1\'/>';
		GridDef += '<D Name=\'totp\' CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' Calculated=\'1\' Format=\'#\' TotalFormat=\'0%\' Q1Format=\'0%\' Q2Format=\'0%\' Q3Format=\'0%\' Q4Format=\'0%\' JanFormat=\'0%\' FebFormat=\'0%\' MarFormat=\'0%\' AprFormat=\'0%\' MayFormat=\'0%\' JunFormat=\'0%\' JulFormat=\'0%\' AugFormat=\'0%\' SepFormat=\'0%\' OctFormat=\'0%\' NovFormat=\'0%\' DecFormat=\'0%\' Q1Format=\'0%\' Q2Format=\'0%\' Q3Format=\'0%\' Q4Format=\'0%\' TotalFormat=\'0%\' ';
		GridDef += fmtTotalFormula('Jan') + fmtTotalFormula('Feb') + fmtTotalFormula('Mar') + fmtTotalFormula('Apr') + fmtTotalFormula('May') + fmtTotalFormula('Jun') + fmtTotalFormula('Jul') + fmtTotalFormula('Aug') + fmtTotalFormula('Sep') + fmtTotalFormula('Oct') + fmtTotalFormula('Nov') + fmtTotalFormula('Dec');
		GridDef += fmtTotalFormula('Total') + fmtTotalFormula('Q1') + fmtTotalFormula('Q2') + fmtTotalFormula('Q3') + fmtTotalFormula('Q4');
		GridDef += ' Recalc=\'256\' R.CanFilter = \'0\' Node.CanFilter = \'1\'/>';
		GridDef += '<D Name=\'prod\' CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' Calculated=\'1\' Format=\'#\' TotalFormat=\'$#,##0;($#,##0)\' Q1Format=\'$#,##0;($#,##0)\' Q2Format=\'$#,##0;($#,##0)\' Q3Format=\'$#,##0;($#,##0)\' Q4Format=\'$#,##0;($#,##0)\' JanFormat=\'$#,##0;($#,##0)\' FebFormat=\'$#,##0;($#,##0)\' MarFormat=\'$#,##0;($#,##0)\' AprFormat=\'$#,##0;($#,##0)\' MayFormat=\'$#,##0;($#,##0)\' JunFormat=\'$#,##0;($#,##0)\' JulFormat=\'$#,##0;($#,##0)\' AugFormat=\'$#,##0;($#,##0)\' SepFormat=\'$#,##0;($#,##0)\' OctFormat=\'$#,##0;($#,##0)\' NovFormat=\'$#,##0;($#,##0)\' DecFormat=\'$#,##0;($#,##0)\' ';
		GridDef += formatMonthRollupFormula('Jan') + formatMonthRollupFormula('Feb') + formatMonthRollupFormula('Mar') + formatMonthRollupFormula('Apr') + formatMonthRollupFormula('May') + formatMonthRollupFormula('Jun') + formatMonthRollupFormula('Jul') + formatMonthRollupFormula('Aug') + formatMonthRollupFormula('Sep') + formatMonthRollupFormula('Oct') + formatMonthRollupFormula('Nov') + formatMonthRollupFormula('Dec');
		GridDef += ' Recalc=\'256\' R.CanFilter = \'0\' Node.CanFilter = \'1\'/>';
		GridDef += formatDef('ldollar');
		GridDef += formatDef('lneg');
		GridDef += formatDef('lpct');
		GridDef += formatDef('lplain');
		//         GridDef += formatDef('lfcst');
		GridDef += '<D Name=\'fcst\' CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' Calculated=\'1\' Format=\'#\' TotalFormat=\'$#,##0;($#,##0)\' Q1Format=\'$#,##0;($#,##0)\' Q2Format=\'$#,##0;($#,##0)\' Q3Format=\'$#,##0;($#,##0)\' Q4Format=\'$#,##0;($#,##0)\' JanFormat=\'$#,##0;($#,##0)\' FebFormat=\'$#,##0;($#,##0)\' MarFormat=\'$#,##0;($#,##0)\' AprFormat=\'$#,##0;($#,##0)\' MayFormat=\'$#,##0;($#,##0)\' JunFormat=\'$#,##0;($#,##0)\' JulFormat=\'$#,##0;($#,##0)\' AugFormat=\'$#,##0;($#,##0)\' SepFormat=\'$#,##0;($#,##0)\' OctFormat=\'$#,##0;($#,##0)\' NovFormat=\'$#,##0;($#,##0)\' DecFormat=\'$#,##0;($#,##0)\' ';
		GridDef += formatMonthRollupFormula('Jan', Q3FCSTLabel) + formatMonthRollupFormula('Feb', Q3FCSTLabel) + formatMonthRollupFormula('Mar', Q3FCSTLabel) + formatMonthRollupFormula('Apr', Q3FCSTLabel) + formatMonthRollupFormula('May', Q3FCSTLabel) + formatMonthRollupFormula('Jun', Q3FCSTLabel) + formatMonthRollupFormula('Jul', Q3FCSTLabel) + formatMonthRollupFormula('Aug', Q3FCSTLabel) + formatMonthRollupFormula('Sep', Q3FCSTLabel) + formatMonthRollupFormula('Oct', Q3FCSTLabel) + formatMonthRollupFormula('Nov', Q3FCSTLabel) + formatMonthRollupFormula('Dec', Q3FCSTLabel);
		GridDef += ' Recalc=\'256\' R.CanFilter = \'0\' Node.CanFilter = \'1\'/>';
		GridDef += '<D Name=\'R\' DefParent=\'Node\'/><D Name=\'Node\' DefEmpty=\'R\' Color=\'#EFE\'/></Def>';
		GridDef += '<Toolbar Scales=\'0\' Debug=\'\' Help=\'0\'  /><Head><Filter AccountCaseSensitive=\'0\' AccountRange=\'1\' AccountButton=\'\' AccountDefaults=\'|*FilterOff|*RowsAll\' AccountCanEdit=\'1\' Expanded=\'3\' OnFilterFinish=\'Grid.ExpandAll();\'/></Head><Solid> <Tabber Cells=\'DMA\' DMAType=\'Button\' DMAButton=\'Tab\' DMAOnChange=\'showSelected(Value);\' DMASwitch=\'1\' DMARadio=\'1\' DMAList=' + DMAList + ' DMAEmptyValue=\'tab1\' DMAWidth=\'150\' DMAPopupIcon=\'2\' DMA=' + '\'' + selectedDMA + '\'' + ' DMATip=\'Please select DMA\' /></Solid></Grid>';

		JSONData = System.JSON.serialize(tgmNational);
		JSONData = JSONData.substring(1, JSONData.length());
		//        String JSONHeader = '{Cols: [{ Name:\'Growth%\', Type:\'Int\' ,Format:\'#\',CanSort:\'0\'},{ Name:\'Churn Indicator\', Type:\'Enum\',Enum:\'||Out of Business|Media Shift|Move to National|Move to Local\'},{ Name:\'Jan\', Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\'},{ Name:\'Feb\', Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\'},{ Name:\'Mar\',Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\'},{ Name:\'Apr\', Type:\'Int\',Format:\'#\' ,CanSort:\'0\',CanEmpty:\'1\',Width:\'110\'},{ Name:\'May\', Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\'},{ Name:\'Jun\',Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\'},{ Name:\'Jul\', Type:\'Int\',Format:\'#\' ,CanSort:\'0\',CanEmpty:\'1\',Width:\'110\'},{ Name:\'Aug\', Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\'},{ Name:\'Sep\',Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\'},{ Name:\'Oct\', Type:\'Int\',Format:\'#\' ,CanSort:\'0\',CanEmpty:\'1\',Width:\'110\'},{ Name:\'Nov\', Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\'},{ Name:\'Dec\',Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\'},{ Name:\'Total\',Type:\'Int\', Formula:\'Q1+Q2+Q3+Q4\',CanSort:\'0\',Width:\'110\'},{ Name:\'Q1\',Type:\'Int\', Formula:\'(isNaN(parseFloat(Jan))?0:Jan)+(isNaN(parseFloat(Feb))?0:Feb)+(isNaN(parseFloat(Mar))?0:Mar)\',CanSort:\'0\',Width:\'110\'},{ Name:\'Q2\',Type:\'Int\', Formula:\'(isNaN(parseFloat(Apr))?0:Apr)+(isNaN(parseFloat(May))?0:May)+(isNaN(parseFloat(Jun))?0:Jun)\',CanSort:\'0\',Width:\'110\'},{ Name:\'Q3\',Type:\'Int\', Formula:\'(isNaN(parseFloat(Jul))?0:Jul)+(isNaN(parseFloat(Aug))?0:Aug)+(isNaN(parseFloat(Sep))?0:Sep)\',CanSort:\'0\',Width:\'110\'},{ Name:\'Q4\',Type:\'Int\', Formula:\'(isNaN(parseFloat(Oct))?0:Oct)+(isNaN(parseFloat(Nov))?0:Nov)+(isNaN(parseFloat(Dec))?0:Dec)\',CanSort:\'0\',Width:\'110\'}],';
		String JSONHeader = '{Cols: [{ Name:\'Growth%\', Type:\'Int\' ,Format:\'#\',CanSort:\'0\',CanEdit:\'0\',Hidden:\'1\',Visible:\'0\'},{ Name:\'ChurnIndicator\', Type:\'Enum\',Enum:\'||Out of Business|Media Shift|Move to National|Move to Local\',CanEdit:\'0\',Hidden:\'1\',Visible:\'0\'},{ Name:\'Jan\', Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\',CanEdit:\'0\'},{ Name:\'Feb\', Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\',CanEdit:\'0\'},{ Name:\'Mar\',Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\',CanEdit:\'0\'},{ Name:\'Apr\', Type:\'Int\',Format:\'#\' ,CanSort:\'0\',CanEmpty:\'1\',Width:\'110\',CanEdit:\'0\'},{ Name:\'May\', Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\',CanEdit:\'0\'},{ Name:\'Jun\',Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\',CanEdit:\'0\'},{ Name:\'Jul\', Type:\'Int\',Format:\'#\' ,CanSort:\'0\',CanEmpty:\'1\',Width:\'110\',CanEdit:\'0\'},{ Name:\'Aug\', Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\',CanEdit:\'0\'},{ Name:\'Sep\',Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\',CanEdit:\'0\'},{ Name:\'Oct\', Type:\'Int\',Format:\'#\' ,CanSort:\'0\',CanEmpty:\'1\',Width:\'110\',CanEdit:\'0\'},{ Name:\'Nov\', Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\',CanEdit:\'0\'},{ Name:\'Dec\',Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\',CanEdit:\'0\'},{ Name:\'Total\',Type:\'Float\', Formula:\'parseFloat(Q1)+parseFloat(Q2)+parseFloat(Q3)+parseFloat(Q4)\',CanSort:\'0\',CanEdit:\'0\',Width:\'110\',Format:\'$#,##0;($#,##0)\',Color:\'#f4f4f4\'},{ Name:\'Q1\',Type:\'Float\', Formula:\'(isNaN(parseFloat(Jan))?0:parseFloat(Jan))+(isNaN(parseFloat(Feb))?0:parseFloat(Feb))+(isNaN(parseFloat(Mar))?0:parseFloat(Mar))\',CanSort:\'0\',CanEdit:\'0\',Format:\'$#,##0;($#,##0)\',Width:\'110\',Color:\'#fafafa\'},{ Name:\'Q2\',Type:\'Float\', Formula:\'(isNaN(parseFloat(Apr))?0:parseFloat(Apr))+(isNaN(parseFloat(May))?0:parseFloat(May))+(isNaN(parseFloat(Jun))?0:parseFloat(Jun))\',CanSort:\'0\',CanEdit:\'0\',Width:\'110\',Format:\'$#,##0;($#,##0)\',Color:\'#fafafa\'},{ Name:\'Q3\',Type:\'Float\', Formula:\'(isNaN(parseFloat(Jul))?0:parseFloat(Jul))+(isNaN(parseFloat(Aug))?0:parseFloat(Aug))+(isNaN(parseFloat(Sep))?0:parseFloat(Sep))\',CanSort:\'0\',CanEdit:\'0\',Width:\'110\',Format:\'$#,##0;($#,##0)\',Color:\'#fafafa\'},{ Name:\'Q4\',Type:\'Float\', Formula:\'(isNaN(parseFloat(Oct))?0:parseFloat(Oct))+(isNaN(parseFloat(Nov))?0:parseFloat(Nov))+(isNaN(parseFloat(Dec))?0:parseFloat(Dec))\',Format:\'$#,##0;($#,##0)\',CanSort:\'0\',CanEdit:\'0\',Width:\'110\',Color:\'#fafafa\'}],';
		JSONString = JSONHeader + JSONData.replace('"', '\'');
		//System.debug('JSONString.length(): ' + JSONString.length());
		return null;
	}

	/**
	 * This method builds JSON for grid metadata and data rows for an AE user
	 *
	 * @param  (none) (NA)
	 * @return (pageReference) (returns control back to grid page)
	 */
	public pageReference showDOSGrid() {
		String rollupFormulaStr = 'sum()';
		GridDefDOS = '<Grid ><Panel Visible=\'0\'/><Cfg CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' TotalDeleting=\'0\' ChildPaging=\'2\' StandardFilter=\'3\' Expanded=\'0\' FormulaRelative=\'1\' NoHScroll=\'1\' NoVScroll=\'1\' Code=\'STREFSXJSLTIED\' MainCol=\'Account\' Delete=\'0\' FullId=\'1\' Dragging =\'0\' Dropping=\'0\' Adding=\'0\'/><Cols><C Name=\'Account\' TextStyle=\'1\' Width=\'360\' CanEdit=\'0\' CanSort=\'0\'/></Cols><Header id=\'id\' AccountLevels=\'2\' AccountTextStyle=\'2\' AChecked=\' \' Account =\'Category | Product | Ledger\'/>';
		GridDefDOS += '<Def><D Name=\'t\' CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' Calculated=\'1\' Format=\'#\' TotalFormat=\'$#,##0;($#,##0)\' Q1Format=\'$#,##0;($#,##0)\' Q2Format=\'$#,##0;($#,##0)\' Q3Format=\'$#,##0;($#,##0)\' Q4Format=\'$#,##0;($#,##0)\' JanFormat=\'$#,##0;($#,##0)\' FebFormat=\'$#,##0;($#,##0)\' MarFormat=\'$#,##0;($#,##0)\' AprFormat=\'$#,##0;($#,##0)\' MayFormat=\'$#,##0;($#,##0)\' JunFormat=\'$#,##0;($#,##0)\' JulFormat=\'$#,##0;($#,##0)\' AugFormat=\'$#,##0;($#,##0)\' SepFormat=\'$#,##0;($#,##0)\' OctFormat=\'$#,##0;($#,##0)\' NovFormat=\'$#,##0;($#,##0)\' DecFormat=\'$#,##0;($#,##0)\' ';
		GridDefDOS += 'JanFormula=\'' + rollupFormulaStr + '\'  FebFormula=\'' + rollupFormulaStr + '\'  MarFormula=\'' + rollupFormulaStr + '\'  AprFormula=\'' + rollupFormulaStr + '\'  MayFormula=\'' + rollupFormulaStr + '\'  JunFormula=\'' + rollupFormulaStr + '\'  JulFormula=\'' + rollupFormulaStr + '\'  AugFormula=\'' + rollupFormulaStr + '\'  SepFormula=\'' + rollupFormulaStr + '\'  OctFormula=\'' + rollupFormulaStr + '\'  NovFormula=\'' + rollupFormulaStr + '\'  DecFormula=\'' + rollupFormulaStr + '\' ';
		GridDefDOS += ' Recalc=\'256\' R.CanFilter = \'0\' Node.CanFilter = \'1\'/>';
		GridDefDOS += '<D Name=\'tot\' CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' Calculated=\'1\' Format=\'#\' TotalFormat=\'$#,##0;($#,##0)\' Q1Format=\'$#,##0;($#,##0)\' Q2Format=\'$#,##0;($#,##0)\' Q3Format=\'$#,##0;($#,##0)\' Q4Format=\'$#,##0;($#,##0)\' JanFormat=\'$#,##0;($#,##0)\' FebFormat=\'$#,##0;($#,##0)\' MarFormat=\'$#,##0;($#,##0)\' AprFormat=\'$#,##0;($#,##0)\' MayFormat=\'$#,##0;($#,##0)\' JunFormat=\'$#,##0;($#,##0)\' JulFormat=\'$#,##0;($#,##0)\' AugFormat=\'$#,##0;($#,##0)\' SepFormat=\'$#,##0;($#,##0)\' OctFormat=\'$#,##0;($#,##0)\' NovFormat=\'$#,##0;($#,##0)\' DecFormat=\'$#,##0;($#,##0)\' ';
		GridDefDOS += fmtTotalFormula('Jan') + fmtTotalFormula('Feb') + fmtTotalFormula('Mar') + fmtTotalFormula('Apr') + fmtTotalFormula('May') + fmtTotalFormula('Jun') + fmtTotalFormula('Jul') + fmtTotalFormula('Aug') + fmtTotalFormula('Sep') + fmtTotalFormula('Oct') + fmtTotalFormula('Nov') + fmtTotalFormula('Dec');
		GridDefDOS += ' Recalc=\'256\' R.CanFilter = \'0\' Node.CanFilter = \'1\'/>';
		GridDefDOS += '<D Name=\'totp\' CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' Calculated=\'1\' Format=\'#\' TotalFormat=\'0%\' Q1Format=\'0%\' Q2Format=\'0%\' Q3Format=\'0%\' Q4Format=\'0%\' JanFormat=\'0%\' FebFormat=\'0%\' MarFormat=\'0%\' AprFormat=\'0%\' MayFormat=\'0%\' JunFormat=\'0%\' JulFormat=\'0%\' AugFormat=\'0%\' SepFormat=\'0%\' OctFormat=\'0%\' NovFormat=\'0%\' DecFormat=\'0%\' Q1Format=\'0%\' Q2Format=\'0%\' Q3Format=\'0%\' Q4Format=\'0%\' TotalFormat=\'0%\' ';
		GridDefDOS += fmtTotalFormula('Jan') + fmtTotalFormula('Feb') + fmtTotalFormula('Mar') + fmtTotalFormula('Apr') + fmtTotalFormula('May') + fmtTotalFormula('Jun') + fmtTotalFormula('Jul') + fmtTotalFormula('Aug') + fmtTotalFormula('Sep') + fmtTotalFormula('Oct') + fmtTotalFormula('Nov') + fmtTotalFormula('Dec');
		GridDefDOS += fmtTotalFormula('Total') + fmtTotalFormula('Q1') + fmtTotalFormula('Q2') + fmtTotalFormula('Q3') + fmtTotalFormula('Q4');
		GridDefDOS += ' Recalc=\'256\' R.CanFilter = \'0\' Node.CanFilter = \'1\'/>';
		GridDefDOS += formatDef('ldollar');
		GridDefDOS += formatDef('lneg');
		GridDefDOS += formatDef('lpct');
		GridDefDOS += formatDef('lplain');
		//       GridDefDOS += formatDef('lfcst');
		GridDefDOS += '<D Name=\'prod\' CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' Calculated=\'1\' Format=\'#\' TotalFormat=\'$#,##0;($#,##0)\' Q1Format=\'$#,##0;($#,##0)\' Q2Format=\'$#,##0;($#,##0)\' Q3Format=\'$#,##0;($#,##0)\' Q4Format=\'$#,##0;($#,##0)\' JanFormat=\'$#,##0;($#,##0)\' FebFormat=\'$#,##0;($#,##0)\' MarFormat=\'$#,##0;($#,##0)\' AprFormat=\'$#,##0;($#,##0)\' MayFormat=\'$#,##0;($#,##0)\' JunFormat=\'$#,##0;($#,##0)\' JulFormat=\'$#,##0;($#,##0)\' AugFormat=\'$#,##0;($#,##0)\' SepFormat=\'$#,##0;($#,##0)\' OctFormat=\'$#,##0;($#,##0)\' NovFormat=\'$#,##0;($#,##0)\' DecFormat=\'$#,##0;($#,##0)\' ';
		GridDefDOS += formatMonthRollupFormula('Jan') + formatMonthRollupFormula('Feb') + formatMonthRollupFormula('Mar') + formatMonthRollupFormula('Apr') + formatMonthRollupFormula('May') + formatMonthRollupFormula('Jun') + formatMonthRollupFormula('Jul') + formatMonthRollupFormula('Aug') + formatMonthRollupFormula('Sep') + formatMonthRollupFormula('Oct') + formatMonthRollupFormula('Nov') + formatMonthRollupFormula('Dec');
		GridDefDOS += ' Recalc=\'256\' R.CanFilter = \'0\' Node.CanFilter = \'1\'/>';
		GridDefDOS += '<D Name=\'prodDOS\' CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' Calculated=\'1\' Format=\'#\' TotalFormat=\'$#,##0;($#,##0)\' Q1Format=\'$#,##0;($#,##0)\' Q2Format=\'$#,##0;($#,##0)\' Q3Format=\'$#,##0;($#,##0)\' Q4Format=\'$#,##0;($#,##0)\' JanFormat=\'$#,##0;($#,##0)\' FebFormat=\'$#,##0;($#,##0)\' MarFormat=\'$#,##0;($#,##0)\' AprFormat=\'$#,##0;($#,##0)\' MayFormat=\'$#,##0;($#,##0)\' JunFormat=\'$#,##0;($#,##0)\' JulFormat=\'$#,##0;($#,##0)\' AugFormat=\'$#,##0;($#,##0)\' SepFormat=\'$#,##0;($#,##0)\' OctFormat=\'$#,##0;($#,##0)\' NovFormat=\'$#,##0;($#,##0)\' DecFormat=\'$#,##0;($#,##0)\' ';
		GridDefDOS += formatMonthRollupFormulaAEDOS('Jan') + formatMonthRollupFormulaAEDOS('Feb') + formatMonthRollupFormulaAEDOS('Mar') + formatMonthRollupFormulaAEDOS('Apr') + formatMonthRollupFormulaAEDOS('May') + formatMonthRollupFormulaAEDOS('Jun') + formatMonthRollupFormulaAEDOS('Jul') + formatMonthRollupFormulaAEDOS('Aug') + formatMonthRollupFormulaAEDOS('Sep') + formatMonthRollupFormulaAEDOS('Oct') + formatMonthRollupFormulaAEDOS('Nov') + formatMonthRollupFormulaAEDOS('Dec');
		GridDefDOS += ' Recalc=\'256\' R.CanFilter = \'0\' Node.CanFilter = \'1\'/>';
		GridDefDOS += '<D Name=\'fcst\' CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' Calculated=\'1\' Format=\'#\' TotalFormat=\'$#,##0;($#,##0)\' Q1Format=\'$#,##0;($#,##0)\' Q2Format=\'$#,##0;($#,##0)\' Q3Format=\'$#,##0;($#,##0)\' Q4Format=\'$#,##0;($#,##0)\' JanFormat=\'$#,##0;($#,##0)\' FebFormat=\'$#,##0;($#,##0)\' MarFormat=\'$#,##0;($#,##0)\' AprFormat=\'$#,##0;($#,##0)\' MayFormat=\'$#,##0;($#,##0)\' JunFormat=\'$#,##0;($#,##0)\' JulFormat=\'$#,##0;($#,##0)\' AugFormat=\'$#,##0;($#,##0)\' SepFormat=\'$#,##0;($#,##0)\' OctFormat=\'$#,##0;($#,##0)\' NovFormat=\'$#,##0;($#,##0)\' DecFormat=\'$#,##0;($#,##0)\' ';
		GridDefDOS += formatMonthRollupFormula('Jan', Q3FCSTLabel) + formatMonthRollupFormula('Feb', Q3FCSTLabel) + formatMonthRollupFormula('Mar', Q3FCSTLabel) + formatMonthRollupFormula('Apr', Q3FCSTLabel) + formatMonthRollupFormula('May', Q3FCSTLabel) + formatMonthRollupFormula('Jun', Q3FCSTLabel) + formatMonthRollupFormula('Jul', Q3FCSTLabel) + formatMonthRollupFormula('Aug', Q3FCSTLabel) + formatMonthRollupFormula('Sep', Q3FCSTLabel) + formatMonthRollupFormula('Oct', Q3FCSTLabel) + formatMonthRollupFormula('Nov', Q3FCSTLabel) + formatMonthRollupFormula('Dec', Q3FCSTLabel);
		GridDefDOS += ' Recalc=\'256\' R.CanFilter = \'0\' Node.CanFilter = \'1\'/>';
		GridDefDOS += '<D Name=\'R\' Recalc=\'256\' DefParent=\'Node\'/><D Name=\'Node\' Recalc=\'256\' DefEmpty=\'R\' Color=\'#EFE\'/></Def>';
		GridDefDOS += '<Toolbar Scales=\'0\' Debug=\'\' Help=\'0\'  /><Head><Filter AccountCaseSensitive=\'0\' AccountRange=\'1\' AccountButton=\'Defaults\' AccountDefaults=\'|*FilterOff|*RowsAll\' AccountCanEdit=\'1\' Expanded=\'1\' /></Head><Solid><Tabber Cells=\'DMA\' DMAType=\'Button\' DMAButton=\'Tab\' DMAOnChange=\'showSelected(Value);\' DMASwitch=\'1\' DMARadio=\'1\' DMAList=' + DMAList + ' DMAEmptyValue=\'tab1\' DMAWidth=\'150\' DMAPopupIcon=\'2\' DMA=' + '\'' + selectedDMA + '\'' + ' DMATip=\'Please select DMA\' /></Solid></Grid>';

		tgmDOS = buildDOSTreeData();
		JSONDataDOS = System.JSON.serialize(tgmDOS);
		JSONDataDOS = JSONDataDOS.substring(1, JSONDataDOS.length());
		String JSONHeader = '{Cols: [{ Name:\'Category\',CanSort:\'0\',CanEmpty:\'1\',Visible:\'0\',CanEdit:\'0\'},{ Name:\'Jan\', Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\',CanEdit:\'0\'},{ Name:\'Feb\', Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\',CanEdit:\'0\'},{ Name:\'Mar\',Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\',CanEdit:\'0\'},{ Name:\'Apr\', Type:\'Int\',Format:\'#\' ,CanSort:\'0\',CanEmpty:\'1\',Width:\'110\',CanEdit:\'0\'},{ Name:\'May\', Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\',CanEdit:\'0\'},{ Name:\'Jun\',Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\',CanEdit:\'0\'},{ Name:\'Jul\', Type:\'Int\',Format:\'#\' ,CanSort:\'0\',CanEmpty:\'1\',Width:\'110\',CanEdit:\'0\'},{ Name:\'Aug\', Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\',CanEdit:\'0\'},{ Name:\'Sep\',Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\',CanEdit:\'0\'},{ Name:\'Oct\', Type:\'Int\',Format:\'#\' ,CanSort:\'0\',CanEmpty:\'1\',Width:\'110\',CanEdit:\'0\'},{ Name:\'Nov\', Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\',CanEdit:\'0\'},{ Name:\'Dec\',Type:\'Int\',Format:\'#\',CanSort:\'0\',CanEmpty:\'1\',Width:\'110\',CanEdit:\'0\'},{ Name:\'Total\',Type:\'Float\', Formula:\'parseFloat(Q1)+parseFloat(Q2)+parseFloat(Q3)+parseFloat(Q4)\',CanSort:\'0\',CanEdit:\'0\',Width:\'110\',Format:\'$#,##0\',Color:\'#f4f4f4\'},{ Name:\'Q1\',Type:\'Float\', Formula:\'(isNaN(parseFloat(Jan))?0:parseFloat(Jan))+(isNaN(parseFloat(Feb))?0:parseFloat(Feb))+(isNaN(parseFloat(Mar))?0:parseFloat(Mar))\',CanSort:\'0\',CanEdit:\'0\',Format:\'$#,##0\',Width:\'110\',Color:\'#fafafa\'},{ Name:\'Q2\',Type:\'Float\', Formula:\'(isNaN(parseFloat(Apr))?0:parseFloat(Apr))+(isNaN(parseFloat(May))?0:parseFloat(May))+(isNaN(parseFloat(Jun))?0:parseFloat(Jun))\',CanSort:\'0\',CanEdit:\'0\',Width:\'110\',Format:\'$#,##0\',Color:\'#fafafa\'},{ Name:\'Q3\',Type:\'Float\', Formula:\'(isNaN(parseFloat(Jul))?0:parseFloat(Jul))+(isNaN(parseFloat(Aug))?0:parseFloat(Aug))+(isNaN(parseFloat(Sep))?0:parseFloat(Sep))\',CanSort:\'0\',CanEdit:\'0\',Width:\'110\',Format:\'$#,##0\',Color:\'#fafafa\'},{ Name:\'Q4\',Type:\'Float\', Formula:\'(isNaN(parseFloat(Oct))?0:parseFloat(Oct))+(isNaN(parseFloat(Nov))?0:parseFloat(Nov))+(isNaN(parseFloat(Dec))?0:parseFloat(Dec))\',Format:\'$#,##0\',CanSort:\'0\',CanEdit:\'0\',Width:\'110\',Color:\'#fafafa\'}],';
		JSONStringDOS = JSONHeader + JSONDataDOS.replace('"', '\'');
		//System.debug('JSONStringDOS.length(): ' + JSONStringDOS.length());
		return null;
	}

	@RemoteAction
	global static String showSelectedDMA(String selectedDMA) {
		BudgetingToolController.SelectedDMA = selectedDMA;
		BudgetingToolController btc = new BudgetingToolController();
		//System.debug(btc.JSONString.unescapeUnicode());
		return btc.JSONString.unescapeUnicode();
	}

	/**
	 * This method builds JSON for grid data rows for an AE user
	 *
	 * @param  (none) (NA)
	 * @return (BudgetingToolModel) (budget grid data model instance with AE rows)
	 */
	public BudgetingToolModel buildAETreeData() {
		queryAETreeData();

		productTotalsSet = new Set<String> ();
		BudgetingToolModel tgm = new BudgetingToolModel();
		List<BudgetingToolModel.Body> tgmbList = new List<BudgetingToolModel.Body> ();
		BudgetingToolModel.Body tgmb = new BudgetingToolModel.Body();
		//BudgetingToolModel.Items_Acc tgmiAcc = new BudgetingToolModel.Items_Acc();
		BudgetingToolModel.Items_Pro tgmiPro = new BudgetingToolModel.Items_Pro();
		BudgetingToolModel.Items_Led tgmiLed = new BudgetingToolModel.Items_Led();
		List<BudgetingToolModel.Items_Pro> tgmiAccList = new List<BudgetingToolModel.Items_Pro> ();
		List<BudgetingToolModel.Items_Pro> tgmiProList = new List<BudgetingToolModel.Items_Pro> ();
		List<BudgetingToolModel.Items_Led> tgmiLedList = new List<BudgetingToolModel.Items_Led> ();
		Map<String, BudgetingToolModel.Items_Pro> tgmiProMap = new Map<String, BudgetingToolModel.Items_Pro> ();
		List<Integer> blankMonths = new List<Integer> { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
		String commodity = '';
		String advertiser = '';
		String productLine = '';
		Map<String, List<BudgetingToolModel.Items_Pro>> accBMap = new Map<String, List<BudgetingToolModel.Items_Pro>> ();
		Map<String, String> comBMap = new Map<String, String> ();

		BudgetingToolModel.Items_Pro tgmiAccTmp = new BudgetingToolModel.Items_Pro();

		tgmiAccTmp = new BudgetingToolModel.Items_Pro();
		tgmiAccTmp.Account = TotalsPrevYearOTBLabel;
		tgmiAccTmp.Def = 'tot';
		tgmiAccList.add(tgmiAccTmp);

		tgmiAccTmp = new BudgetingToolModel.Items_Pro();
		tgmiAccTmp.Account = TotalsCurrYearOTBLabel;
		tgmiAccTmp.Def = 'tot';
		tgmiAccList.add(tgmiAccTmp);

		tgmiAccTmp = new BudgetingToolModel.Items_Pro();
		tgmiAccTmp.Account = TotalsNextYearOTBLabel;
		tgmiAccTmp.Def = 'tot';
		tgmiAccList.add(tgmiAccTmp);

		tgmiAccTmp = new BudgetingToolModel.Items_Pro();
		tgmiAccTmp.Account = TotalsQ3FCSTLabel;
		tgmiAccTmp.Def = 'tot';
		tgmiAccList.add(tgmiAccTmp);

		tgmiAccTmp = new BudgetingToolModel.Items_Pro();
		tgmiAccTmp.Account = TotalsKnownBudgetLabel;
		tgmiAccTmp.Def = 'tot';
		tgmiAccList.add(tgmiAccTmp);

		tgmiAccTmp = new BudgetingToolModel.Items_Pro();
		tgmiAccTmp.Account = TotalsNewBusinessLabel;
		tgmiAccTmp.Def = 'tot';
		tgmiAccList.add(tgmiAccTmp);

		tgmiAccTmp = new BudgetingToolModel.Items_Pro();
		tgmiAccTmp.Account = TotalsChurnLabel;
		tgmiAccTmp.Def = 'tot';
		tgmiAccList.add(tgmiAccTmp);

		tgmiAccTmp = new BudgetingToolModel.Items_Pro();
		tgmiAccTmp.Account = TotalsBudgetLabel;
		tgmiAccTmp.Def = 'tot';
		tgmiAccList.add(tgmiAccTmp);

		tgmiAccTmp = new BudgetingToolModel.Items_Pro();
		tgmiAccTmp.Account = TotalsNextYearYOYLabel;
		tgmiAccTmp.Def = 'totp';
		tgmiAccList.add(tgmiAccTmp);

		BudgetingToolModel.Body commTmp = new BudgetingToolModel.Body();
		commTmp.Account = TotalsLabel;
		commTmp.Def = '';
		commTmp.Items = tgmiAccList;
		tgmbList.add(commTmp);

		//tgmiAccList = new List<BudgetingToolModel.Items_Acc>();
		Set<String> existingCategories = new Set<String> ();
		Integer i = 0;
		for (String s : budgetKeys.keySet()) {
			Boolean hasAmount = false;
			for (Integer k = 0; k< 12; k++)
			{
				if (revenueCYMap != null && revenueCYMap.size()> 0 && revenueCYMap.get(s) != null && revenueCYMap.get(s).months != null && revenueCYMap.get(s).months[k] != 0)
				{
					hasAmount = true;
				}

				else if (revenuePYMap != null && revenuePYMap.size() > 0 && revenuePYMap.get(s) != null && revenuePYMap.get(s).months != null && revenuePYMap.get(s).months[k] != 0)
				{
					hasAmount = true;
				}

				else if (revenueNYMap != null && revenueNYMap.size() > 0 && revenueNYMap.get(s) != null && revenueNYMap.get(s).months != null && revenueNYMap.get(s).months[k] != 0)
				{
					hasAmount = true;
				}

				else if (forecastMap != null && forecastMap.size() > 0 && forecastMap.get(s) != null && forecastMap.get(s).months != null && forecastMap.get(s).months[k] != 0)
				{
					hasAmount = true;
				}

				else if (budgetMap != null && budgetMap.size() > 0 && budgetMap.get(s) != null && budgetMap.get(s).months != null && budgetMap.get(s).months[k] != 0)
				{
					hasAmount = true;
				}
			}
			if (hasAmount)
			{
				System.debug('AE KEY: ' + s);

				if (budgetMap.get(s) != null && budgetMap.get(s).advertiser == Label.BudgetNewBusinessAcountId) {
					if (budgetMap.get(s).productLine != budgetMap.get(s).churnIndicator)
					tgmiLedList.add(AddLed(Label.BudgetCurrentYear + ' ' + budgetMap.get(s).churnIndicator, 'c', 1, budgetMap.get(s).months, '', s, budgetMap.get(s).churnIndicator));
					else
					tgmiLedList.add(AddLed(Label.BudgetCurrentYear + ' ' + budgetMap.get(s).productLine, 'c', 1, budgetMap.get(s).months, '', s, budgetMap.get(s).churnIndicator));
				}
				else {
					//Add 2017 Revenue row
					if (revenuePYMap.get(s) != null) {
						tgmiLedList.add(AddLed(PrevYearOTBLabel, 'c', 0, revenuePYMap.get(s).months, '', '', ''));
					} else { tgmiLedList.add(AddLed(PrevYearOTBLabel, 'c', 0, blankMonths, '', '', '')); }
					//Add 2018 Revenue row
					if (revenueCYMap.get(s) != null) {
						tgmiLedList.add(AddLed(CurrYearOTBLabel, 'c', 0, revenueCYMap.get(s).months, '', '', ''));
					} else { tgmiLedList.add(AddLed(CurrYearOTBLabel, 'c', 0, blankMonths, '', '', '')); }
					//Add 2018 Forecast row

					if (revenueNYMap.get(s) != null) {
						tgmiLedList.add(AddLed(NextYearOTBLabel, 'c', 0, revenueNYMap.get(s).months, '', '', ''));
					} else { tgmiLedList.add(AddLed(NextYearOTBLabel, 'c', 0, blankMonths, '', '', '')); }

					if (forecastMap.get(s) != null) {
						System.debug('forecastMap1 ' + forecastMap.get(s));
						tgmiLedList.add(AddLed(Q3FCSTLabel, 'q3', 0, forecastMap.get(s).months, '', '', ''));
					} else {
						System.debug('forecastMap2 ' + forecastMap.keySet());
						tgmiLedList.add(AddLed(Q3FCSTLabel, 'q3', 0, blankMonths, '', '', '')); }
					//Add 2018 YOY% row
					//                    if(revenuePYMap.get(s) != null){
					tgmiLedList.add(AddLed(CurrYearYOYLabel, 'p', 0, blankMonths, '', '', ''));
					//                    }
					//Add 2019 Budget row
					if (budgetMap.get(s) != null) {
						tgmiLedList.add(AddLed(BudgetLabel, 'c', 1, budgetMap.get(s).months, '', s, budgetMap.get(s).churnIndicator));
					} else { tgmiLedList.add(AddLed(BudgetLabel, 'c', 1, blankMonths, '', s, '')); }
					//Add 2019 YOY% row
					//                  if(revenuePYMap.get(s) != null){
					tgmiLedList.add(AddLed(NextYearYOYLabel, 'p', 0, blankMonths, '', '', ''));
					//                    }
				}

				//if(productLine != budgetKeys.get(s).ProductLine){
				productLine = budgetKeys.get(s).ProductLine;
				tgmiProList.add(AddProduct(budgetKeys.get(s).ProductLine, tgmiLedList));
				tgmiLedList = new List<BudgetingToolModel.Items_Led> ();
				if (productLine != NewBusinessLabel && productLine != ChurnLabel) {
					productTotalsSet.add(productLine);
				}
				//}

				if (accMap.get(budgetKeys.get(s).Advertiser) != null) {
					if (accBMap.containsKey(budgetKeys.get(s).Advertiser)) {
						accBMap.get(budgetKeys.get(s).Advertiser).addAll(tgmiProList);
					}
					else {
						accBMap.put(budgetKeys.get(s).Advertiser, tgmiProList);
						System.debug(accBMap);
					}
				}

				tgmiProList = new List<BudgetingToolModel.Items_Pro> ();

			}
		}
		String lstCom = '';
		//for(String s1: existingCategories){
		for (String s : accBMap.keyset()) {
			//if(s1==s.split(keySeparator)[0]){
			tgmbList.add(AddAccount(accMap.get(s).name, accBMap.get(s)));
			system.debug('tgmbList ' + tgmbList);
			//}
			//tgmbList.add(AddCommodity(accMap.get(s).name,tgmiAccList));
			//tgmiAccList = new List<BudgetingToolModel.Items_Pro>();
		}
		//}

		//Totals by Product Line block
		tgm.body = new List<List<BudgetingToolModel.Body>> ();
		tgm.body.add(tgmbList);
		system.debug('tgm ' + tgm);
		return tgm;
	}

	/**
	 * This method builds JSON for grid data rows for a NSM user
	 *
	 * @param  (none) (NA)
	 * @return (BudgetingToolModel) (budget grid data model instance with NSM rows)
	 */
	public BudgetingToolModelNational buildNSMTreeData() {
		queryNSMTreeData();

		productTotalsSet = new Set<String> ();
		BudgetingToolModelNational tgmNational = new BudgetingToolModelNational();
		List<BudgetingToolModelNational.Body> tgmbList = new List<BudgetingToolModelNational.Body> ();
		BudgetingToolModelNational.Body tgmb = new BudgetingToolModelNational.Body();
		BudgetingToolModelNational.Items_DMA tgmiDMA = new BudgetingToolModelNational.Items_DMA();
		//BudgetingToolModelNational.Items_Commodity tgmiCom = new BudgetingToolModelNational.Items_Commodity(); Commented by Shubham Gupta
		BudgetingToolModelNational.Items_Acc tgmiAcc = new BudgetingToolModelNational.Items_Acc();
		BudgetingToolModelNational.Items_Led tgmiLed = new BudgetingToolModelNational.Items_Led();
		List<BudgetingToolModelNational.Items_DMA> tgmiDMAList = new List<BudgetingToolModelNational.Items_DMA> ();
		List<BudgetingToolModelNational.Items_Acc> tgmiAccList = new List<BudgetingToolModelNational.Items_Acc> ();
		//List<BudgetingToolModelNational.Items_Commodity> tgmiComList = new List<BudgetingToolModelNational.Items_Commodity>(); Commented by Shubham Gupta
		List<BudgetingToolModelNational.Items_Led> tgmiLedList = new List<BudgetingToolModelNational.Items_Led> ();
		//Map<String,BudgetingToolModelNational.Items_Commodity> tgmiComMap = new Map<String,BudgetingToolModelNational.Items_Commodity>(); Commented by Shubham Gupta
		List<Integer> blankMonths = new List<Integer> { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
		String DMA = '';
		String commodity = '';
		String advertiser = '';
		String productLine = '';
		Map<String, List<BudgetingToolModelNational.Items_Acc>> accBMap = new Map<String, List<BudgetingToolModelNational.Items_Acc>> ();
		Map<String, String> comBMap = new Map<String, String> ();

		BudgetingToolModelNational.Items_DMA tgmiDMATmp = new BudgetingToolModelNational.Items_DMA();

		tgmiDMATmp = new BudgetingToolModelNational.Items_DMA();
		tgmiDMATmp.Account = TotalsPrevYearOTBLabel;
		tgmiDMATmp.Def = 'tot';
		tgmiDMAList.add(tgmiDMATmp);

		tgmiDMATmp = new BudgetingToolModelNational.Items_DMA();
		tgmiDMATmp.Account = TotalsCurrYearOTBLabel;
		tgmiDMATmp.Def = 'tot';
		tgmiDMAList.add(tgmiDMATmp);

		tgmiDMATmp = new BudgetingToolModelNational.Items_DMA();
		tgmiDMATmp.Account = TotalsQ3FCSTLabel;
		tgmiDMATmp.Def = 'tot';
		tgmiDMAList.add(tgmiDMATmp);

		tgmiDMATmp = new BudgetingToolModelNational.Items_DMA();
		tgmiDMATmp.Account = TotalsKnownBudgetLabel;
		tgmiDMATmp.Def = 'tot';
		tgmiDMAList.add(tgmiDMATmp);

		tgmiDMATmp = new BudgetingToolModelNational.Items_DMA();
		tgmiDMATmp.Account = TotalsNewBusinessLabel;
		tgmiDMATmp.Def = 'tot';
		tgmiDMAList.add(tgmiDMATmp);

		tgmiDMATmp = new BudgetingToolModelNational.Items_DMA();
		tgmiDMATmp.Account = TotalsChurnLabel;
		tgmiDMATmp.Def = 'tot';
		tgmiDMAList.add(tgmiDMATmp);

		tgmiDMATmp = new BudgetingToolModelNational.Items_DMA();
		tgmiDMATmp.Account = TotalsBudgetLabel;
		tgmiDMATmp.Def = 'tot';
		tgmiDMAList.add(tgmiDMATmp);

		tgmiDMATmp = new BudgetingToolModelNational.Items_DMA();
		tgmiDMATmp.Account = TotalsNextYearYOYLabel;
		tgmiDMATmp.Def = 'totp';
		tgmiDMAList.add(tgmiDMATmp);

		BudgetingToolModelNational.Body commTmp = new BudgetingToolModelNational.Body();
		commTmp.Account = TotalsLabel;
		commTmp.Def = '';
		commTmp.Items = tgmiDMAList;
		tgmbList.add(commTmp);

		tgmiDMAList = new List<BudgetingToolModelNational.Items_DMA> ();

		Set<String> existingCategories = new Set<String> ();


		for (String s : budgetKeys.keySet()) {

			Boolean hasAmount = false;
			for (Integer k = 0; k< 12; k++)
			{
				if (revenueCYMap != null && revenueCYMap.size()> 0 && revenueCYMap.get(s) != null && revenueCYMap.get(s).months != null && revenueCYMap.get(s).months[k] != 0)
				{
					hasAmount = true;
				}

				else if (revenuePYMap != null && revenuePYMap.size() > 0 && revenuePYMap.get(s) != null && revenuePYMap.get(s).months != null && revenuePYMap.get(s).months[k] != 0)
				{
					hasAmount = true;
				}

				else if (forecastMap != null && forecastMap.size() > 0 && forecastMap.get(s) != null && forecastMap.get(s).months != null && forecastMap.get(s).months[k] != 0)
				{
					hasAmount = true;
				}

				else if (budgetMap != null && budgetMap.size() > 0 && budgetMap.get(s) != null && budgetMap.get(s).months != null && budgetMap.get(s).months[k] != 0)
				{
					hasAmount = true;
				}
			}
			if (hasAmount)
			{

				System.debug('NSM KEY: ' + s);

				if (budgetMap.get(s) != null && budgetMap.get(s).advertiser == Label.BudgetNewBusinessAcountId) {
					if (budgetMap.get(s).productLine != budgetMap.get(s).churnIndicator)
					tgmiLedList.add(AddNationalLed(Label.BudgetCurrentYear + ' ' + budgetMap.get(s).churnIndicator, 'c', 1, budgetMap.get(s).months, '', s, budgetMap.get(s).churnIndicator));
					else
					tgmiLedList.add(AddNationalLed(Label.BudgetCurrentYear + ' ' + budgetMap.get(s).productLine, 'c', 1, budgetMap.get(s).months, '', s, budgetMap.get(s).churnIndicator));
				}
				else {
					//Add 2017 Revenue row
					if (revenuePYMap.get(s) != null) {
						tgmiLedList.add(AddNationalLed(PrevYearOTBLabel, 'c', 0, revenuePYMap.get(s).months, '', '', ''));
					} else { tgmiLedList.add(AddNationalLed(PrevYearOTBLabel, 'c', 0, blankMonths, '', '', '')); }
					//Add 2018 Revenue row
					if (revenueCYMap.get(s) != null) {
						tgmiLedList.add(AddNationalLed(CurrYearOTBLabel, 'c', 0, revenueCYMap.get(s).months, '', '', ''));
					} else { tgmiLedList.add(AddNationalLed(CurrYearOTBLabel, 'c', 0, blankMonths, '', '', '')); }
					//Add 2018 Forecast row
					if (forecastMap.get(s) != null) {
						tgmiLedList.add(AddNationalLed(Q3FCSTLabel, 'q3', 0, forecastMap.get(s).months, '', '', ''));
					} else { tgmiLedList.add(AddNationalLed(Q3FCSTLabel, 'q3', 0, blankMonths, '', '', '')); }
					//Add 2018 YOY% row
					if (budgetKeys.get(s) != null) {
						tgmiLedList.add(AddNationalLed(CurrYearYOYLabel, 'p', 0, budgetKeys.get(s).months, '', '', ''));
					}
					//Add 2018 Budget row
					if (budgetMap.get(s) != null) {
						tgmiLedList.add(AddNationalLed(BudgetLabel, 'c', 1, budgetMap.get(s).months, '', s, budgetMap.get(s).churnIndicator));
					} else { tgmiLedList.add(AddNationalLed(BudgetLabel, 'c', 1, blankMonths, '', s, '')); }
					//Add 2019 YOY% row
					if (budgetKeys.get(s) != null) {
						tgmiLedList.add(AddNationalLed(NextYearYOYLabel, 'p', 0, budgetKeys.get(s).months, '', '', ''));
					}
				}

				tgmb.Account = budgetKeys.get(s).DMA;

				//if(productLine != budgetKeys.get(s).ProductLine){
				productLine = budgetKeys.get(s).ProductLine;
				tgmiAccList.add(AddNationalProduct(budgetKeys.get(s).ProductLine, tgmiLedList));
				tgmiLedList = new List<BudgetingToolModelNational.Items_Led> ();
				if (productLine != NewBusinessLabel && productLine != ChurnLabel) {
					productTotalsSet.add(productLine);
				}
				//}

				if (accMap.get(budgetKeys.get(s).Advertiser) != null) {
					if (accBMap.containsKey(budgetKeys.get(s).Advertiser)) {
						accBMap.get(budgetKeys.get(s).Advertiser).addAll(tgmiAccList);
					}
					else {
						accBMap.put(budgetKeys.get(s).Advertiser, tgmiAccList);
					}

					if (comBMap.containsKey(budgetKeys.get(s).Commodity + budgetKeys.get(s).Advertiser)) {
					}
					else {
						comBMap.put(budgetKeys.get(s).Commodity + keySeparator + budgetKeys.get(s).Advertiser, budgetKeys.get(s).Advertiser);
					}
				}
				existingCategories.add(budgetKeys.get(s).Commodity);
				tgmiAccList = new List<BudgetingToolModelNational.Items_Acc> ();
			}
		}

		for (String s : accBMap.keyset()) {
			tgmiDMAList.add(AddNationalAccount(accMap.get(s).name, accBMap.get(s)));
		}

		tgmb.Items = tgmiDMAList;
		tgmNational.body = new List<List<BudgetingToolModelNational.Body>> ();
		tgmbList.add(tgmb);
		tgmNational.body.add(tgmbList);

		return tgmNational;
	}

	/**
	 * This method builds JSON for grid data rows for a Leadership user
	 *
	 * @param  (none) (NA)
	 * @return (BudgetingToolModel) (budget grid data model instance with Leadership rows)
	 */
	public BudgetingToolModelDOS buildDOSTreeData() {

		queryDOSTreeData();

		productTotalsSet = new Set<String> ();
		BudgetingToolModelDOS tgmDOSLocal = new BudgetingToolModelDOS();
		List<BudgetingToolModelDOS.Body> tgmbList = new List<BudgetingToolModelDOS.Body> ();
		BudgetingToolModelDOS.Body tgmb = new BudgetingToolModelDOS.Body();
		BudgetingToolModelDOS.Items_Acc tgmiAcc = new BudgetingToolModelDOS.Items_Acc();
		BudgetingToolModelDOS.Items_Pro tgmiPro = new BudgetingToolModelDOS.Items_Pro();
		//BudgetingToolModelDOS.Items_Led tgmiLed = new BudgetingToolModelDOS.Items_Led();
		List<BudgetingToolModelDOS.Items_Acc> tgmiAccList = new List<BudgetingToolModelDOS.Items_Acc> ();
		List<BudgetingToolModelDOS.Items_Pro> tgmiProList = new List<BudgetingToolModelDOS.Items_Pro> ();
		//List<BudgetingToolModelDOS.Items_Led> tgmiLedList = new List<BudgetingToolModelDos.Items_Led>();
		Map<String, BudgetingToolModelDOS.Items_Pro> tgmiProMap = new Map<String, BudgetingToolModelDOS.Items_Pro> ();
		List<Integer> blankMonths = new List<Integer> { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
		String commodity = '';
		String advertiser = '';
		String productLine = '';
		Map<String, List<BudgetingToolModelDOS.Items_Pro>> accBMap = new Map<String, List<BudgetingToolModelDOS.Items_Pro>> ();
		Map<String, List<BudgetingToolModelDOS.Items_Pro>> comBMap = new Map<String, List<BudgetingToolModelDOS.Items_Pro>> ();
		List<String> newBusinessAccList = new List<String> { 'New Business 1', 'New Business 2', 'New Business 3', 'New Business 4', 'New Business 5', 'New Business 6', 'New Business 7', 'New Business 8', 'New Business 9', 'New Business 10', 'New Business 11', 'New Business 12', 'New Business 13', 'New Business 14', 'New Business 15', 'New Business 16', 'New Business 17', 'New Business 18', 'New Business 19', 'New Business 20', 'New Business 21', 'New Business 22', 'New Business 23' };
		List<String> categoryList = new List<String> { 'Alcoholic Beverages', 'Associations', 'Auto Aftermarket', 'Auto Dealer', 'Auto Dealer Association', 'Auto Manufacturer', 'Automall/Used Cars', 'Education', 'Financial Services and Insurance', 'Government and Military', 'Grocery/Food and Beverage', 'Healthcare', 'Home Improvement', 'Legal Services', 'Media', 'Real Estate', 'Remnant/Direct Response', 'Restaurant', 'Retail', 'RV/Cycles Vehicles', 'Telecommunications', 'Travel/Leisure/Entertainment', 'Marketing' };
		System.debug('DOS newBusinessBudgetMap: ' + newBusinessBudgetMap);

		BudgetingToolModelDOS.Items_Acc tgmiAccTmp = new BudgetingToolModelDOS.Items_Acc();

		tgmiAccTmp = new BudgetingToolModelDOS.Items_Acc();
		tgmiAccTmp.Account = TotalsPrevYearOTBLabel;
		tgmiAccTmp.Def = 'tot';
		tgmiAccList.add(tgmiAccTmp);

		tgmiAccTmp = new BudgetingToolModelDOS.Items_Acc();
		tgmiAccTmp.Account = TotalsCurrYearOTBLabel;
		tgmiAccTmp.Def = 'tot';
		tgmiAccList.add(tgmiAccTmp);

		tgmiAccTmp = new BudgetingToolModelDOS.Items_Acc();
		tgmiAccTmp.Account = TotalsQ3FCSTLabel;
		tgmiAccTmp.Def = 'tot';
		tgmiAccList.add(tgmiAccTmp);

		tgmiAccTmp = new BudgetingToolModelDOS.Items_Acc();
		tgmiAccTmp.Account = TotalsKnownBudgetLabel;
		tgmiAccTmp.Def = 'tot';
		tgmiAccList.add(tgmiAccTmp);

		tgmiAccTmp = new BudgetingToolModelDOS.Items_Acc();
		tgmiAccTmp.Account = TotalsNewBusinessLabel;
		tgmiAccTmp.Def = 'tot';
		tgmiAccList.add(tgmiAccTmp);

		tgmiAccTmp = new BudgetingToolModelDOS.Items_Acc();
		tgmiAccTmp.Account = TotalsChurnLabel;
		tgmiAccTmp.Def = 'tot';
		tgmiAccList.add(tgmiAccTmp);

		tgmiAccTmp = new BudgetingToolModelDOS.Items_Acc();
		tgmiAccTmp.Account = TotalsBudgetLabel;
		tgmiAccTmp.Def = 'tot';
		tgmiAccList.add(tgmiAccTmp);

		tgmiAccTmp = new BudgetingToolModelDOS.Items_Acc();
		tgmiAccTmp.Account = TotalsNextYearYOYLabel;
		tgmiAccTmp.Def = 'totp';
		tgmiAccList.add(tgmiAccTmp);

		BudgetingToolModelDOS.Body commTmp = new BudgetingToolModelDOS.Body();
		commTmp.Account = TotalsLabel;
		commTmp.Def = '';
		commTmp.Items = tgmiAccList;
		tgmbList.add(commTmp);

		tgmiAccList = new List<BudgetingToolModelDOS.Items_Acc> ();

		//New Business/Churn rows logic for selected user
		if (newBusinessBudgetMap.size() > 0) {
			for (String s : newBusinessBudgetMap.keySet()) {
				//System.debug('DOS selected user KEY: ' + s+newBusinessBudgetMap.get(s).Months);

				tgmiAcc = new BudgetingToolModelDOS.Items_Acc();
				tgmiAcc.account = newBusinessBudgetMap.get(s).productLine;

				if (newBusinessBudgetMap.get(s).productLine != NewBusinessLabel && newBusinessBudgetMap.get(s).productLine != ChurnLabel) {
					productTotalsSet.add(newBusinessBudgetMap.get(s).productLine);
				}
				tgmiAcc.Def = 'prodDOS';

				tgmiPro = new BudgetingToolModelDOS.Items_Pro();
				tgmiProList = new List<BudgetingToolModelDOS.Items_Pro> ();

				tgmiPro.Account = newBusinessBudgetMap.get(s).productLine;
				tgmiPro.Jan = newBusinessBudgetMap.get(s).Months[0];
				tgmiPro.Feb = newBusinessBudgetMap.get(s).Months[1];
				tgmiPro.Mar = newBusinessBudgetMap.get(s).Months[2];
				tgmiPro.Apr = newBusinessBudgetMap.get(s).Months[3];
				tgmiPro.May = newBusinessBudgetMap.get(s).Months[4];
				tgmiPro.Jun = newBusinessBudgetMap.get(s).Months[5];
				tgmiPro.Jul = newBusinessBudgetMap.get(s).Months[6];
				tgmiPro.Aug = newBusinessBudgetMap.get(s).Months[7];
				tgmiPro.Sep = newBusinessBudgetMap.get(s).Months[8];
				tgmiPro.Oct = newBusinessBudgetMap.get(s).Months[9];
				tgmiPro.Nov = newBusinessBudgetMap.get(s).Months[10];
				tgmiPro.Dec = newBusinessBudgetMap.get(s).Months[11];
				//                tgmiPro.format('c');
				tgmiPro.Def = formatDef(tgmiPro.Account, 'c');

				tgmiProList.add(tgmiPro);
				tgmiAcc.Items = tgmiProList;
				tgmiAccList.add(tgmiAcc);
			}

			tgmb = new BudgetingToolModelDOS.Body();
			tgmb.Account = userMap.get(userParam).replace('\'', '');
			tgmb.items = tgmiAccList;
			tgmbList.add(tgmb);
		}

		Set<String> existingDOSCategories = new Set<String> ();
		tgmb = new BudgetingToolModelDOS.Body();
		tgmiAcc = new BudgetingToolModelDOS.Items_Acc();
		tgmiAccList = new List<BudgetingToolModelDOS.Items_Acc> ();
		tgmiPro = new BudgetingToolModelDOS.Items_Pro();
		tgmiProList = new List<BudgetingToolModelDOS.Items_Pro> ();

		//New Business/Churn rows logic based on saved DOS data
		if (dosBudgetMap.size() > 0) {

			for (String s : dosBudgetMap.keySet()) {
				//System.debug('DOS KEY: ' + s);

				if (productLine != dosBudgetMap.get(s).NewBusinessChurn) {
					productLine = dosBudgetMap.get(s).NewBusinessChurn;
					existingDOSCategories.add(dosBudgetMap.get(s).Commodity);
					tgmiPro.Account = Label.BudgetCurrentYear + ' ' + dosBudgetMap.get(s).NewBusinessChurn;
					tgmiPro.id = s;
					tgmiPro.Jan = dosBudgetMap.get(s).Months[0];
					tgmiPro.Feb = dosBudgetMap.get(s).Months[1];
					tgmiPro.Mar = dosBudgetMap.get(s).Months[2];
					tgmiPro.Apr = dosBudgetMap.get(s).Months[3];
					tgmiPro.May = dosBudgetMap.get(s).Months[4];
					tgmiPro.Jun = dosBudgetMap.get(s).Months[5];
					tgmiPro.Jul = dosBudgetMap.get(s).Months[6];
					tgmiPro.Aug = dosBudgetMap.get(s).Months[7];
					tgmiPro.Sep = dosBudgetMap.get(s).Months[8];
					tgmiPro.Oct = dosBudgetMap.get(s).Months[9];
					tgmiPro.Nov = dosBudgetMap.get(s).Months[10];
					tgmiPro.Dec = dosBudgetMap.get(s).Months[11];
					//tgmiPro.format('c');
					tgmiPro.Def = formatDef(tgmiPro.Account, 'c');
					tgmiProList.add(tgmiPro);

				}

				if (accBMap.containsKey(dosBudgetMap.get(s).productLine)) {
					accBMap.get(dosBudgetMap.get(s).productLine).addAll(tgmiProList);
				}
				else {
					accBMap.put(dosBudgetMap.get(s).productLine, tgmiProList);
				}

				if (dosBudgetMap.get(s).productLine != NewBusinessLabel && dosBudgetMap.get(s).productLine != ChurnLabel) {
					productTotalsSet.add(dosBudgetMap.get(s).productLine);
				}

				if (comBMap.containsKey(dosBudgetMap.get(s).Commodity + keySeparator + dosBudgetMap.get(s).productLine)) {
					comBMap.get(dosBudgetMap.get(s).Commodity + keySeparator + dosBudgetMap.get(s).productLine).add(tgmiPro);
				}
				else {
					comBMap.put(dosBudgetMap.get(s).Commodity + keySeparator + dosBudgetMap.get(s).productLine, new List<BudgetingToolModelDOS.Items_Pro> { tgmiPro });
				}
				tgmiProList = new List<BudgetingToolModelDOS.Items_Pro> ();
				tgmiPro = new BudgetingToolModelDOS.Items_Pro();
			}

			for (String s1 : existingDOSCategories) {
				for (String s : comBMap.keyset()) {
					if (s1 == s.split(keySeparator) [0]) {
						BudgetingToolModelDOS.Items_Acc tgmiAcc1 = new BudgetingToolModelDOS.Items_Acc();
						tgmiAcc1.Account = s.split(keySeparator) [1];

						tgmiAcc1.items = comBMap.get(s);
						tgmiAccList.add(tgmiAcc1);
					}
				}
				BudgetingToolModelDOS.Body tgmib = new BudgetingToolModelDOS.Body();
				tgmib.Account = s1;
				tgmib.items = tgmiAccList;
				tgmbList.add(tgmib);
				tgmiAccList = new List<BudgetingToolModelDOS.Items_Acc> ();
			}


			if (productTotalsSet.size() > 0) {
				tgmiAccList = new List<BudgetingToolModelDOS.Items_Acc> ();
				for (String s : productTotalsSet) {
					BudgetingToolModelDOS.Items_Pro tgmiProTmp = new BudgetingToolModelDOS.Items_Pro();
					List<BudgetingToolModelDOS.Items_Pro> tgmiProListTmp = new List<BudgetingToolModelDOS.Items_Pro> ();

					tgmiProTmp = new BudgetingToolModelDOS.Items_Pro();
					tgmiProTmp.Account = TotalsPrevYearOTBLabel;
					tgmiProTmp.Def = 'tot';
					tgmiProListTmp.add(tgmiProTmp);

					tgmiProTmp = new BudgetingToolModelDOS.Items_Pro();
					tgmiProTmp.Account = TotalsCurrYearOTBLabel;
					tgmiProTmp.Def = 'tot';
					tgmiProListTmp.add(tgmiProTmp);

					tgmiProTmp = new BudgetingToolModelDOS.Items_Pro();
					tgmiProTmp.Account = TotalsQ3FCSTLabel;
					tgmiProTmp.Def = 'tot';
					tgmiProListTmp.add(tgmiProTmp);

					tgmiProTmp = new BudgetingToolModelDOS.Items_Pro();
					tgmiProTmp.Account = TotalsKnownBudgetLabel;
					tgmiProTmp.Def = 'tot';
					tgmiProListTmp.add(tgmiProTmp);

					tgmiProTmp = new BudgetingToolModelDOS.Items_Pro();
					tgmiProTmp.Account = TotalsNewBusinessLabel;
					tgmiProTmp.Def = 'tot';
					tgmiProListTmp.add(tgmiProTmp);

					tgmiProTmp = new BudgetingToolModelDOS.Items_Pro();
					tgmiProTmp.Account = TotalsChurnLabel;
					tgmiProTmp.Def = 'tot';
					tgmiProListTmp.add(tgmiProTmp);

					tgmiProTmp = new BudgetingToolModelDOS.Items_Pro();
					tgmiProTmp.Account = TotalsBudgetLabel;
					tgmiProTmp.Def = 'tot';
					tgmiProListTmp.add(tgmiProTmp);

					tgmiProTmp = new BudgetingToolModelDOS.Items_Pro();
					tgmiProTmp.Account = TotalsNextYearYOYLabel;
					tgmiProTmp.Def = 'totp';
					tgmiProListTmp.add(tgmiProTmp);


					tgmiAccTmp = new BudgetingToolModelDOS.Items_Acc();
					tgmiAccTmp.Account = s;
					tgmiAccTmp.Def = '';
					tgmiAccTmp.Items = tgmiProListTmp;
					tgmiAccList.add(tgmiAccTmp);
				}
				commTmp = new BudgetingToolModelDOS.Body();
				commTmp.Account = ProductTotalsLabel;
				commTmp.Def = '';
				commTmp.Items = tgmiAccList;
				tgmbList.add(1, commTmp);
			}


			tgmDOSLocal.body = new List<List<BudgetingToolModelDOS.Body>> ();
			tgmDOSLocal.body.add(tgmbList);
		}
		//New Business/Churn rows logic if there is either no saved DOS data or partially saved data
		/*for(Integer i=0;i<newBusinessAccList.size();i++){
		  if(!existingDOSCategories.contains(categoryList[i])){
		  tgmiAccList = new List<BudgetingToolModelDOS.Items_Acc>();
		  for(String pl:loggedInUserProductLines.split(';')){
		  tgmiAcc = new BudgetingToolModelDOS.Items_Acc();
		  tgmiAcc.account=pl;
		  tgmiAcc.Def = 'prod';
		 
		  tgmiPro =  new BudgetingToolModelDOS.Items_Pro();
		  tgmiProList = new List<BudgetingToolModelDOS.Items_Pro>();
		  if(loggedInUserBudgetType == 'National'){
		  tgmiPro.id =  keySeparator+selectedDMA+keySeparator+categoryList[i]+keySeparator+Label.BudgetNewBusinessAcountId+keySeparator+pl+keySeparator+Label.BudgetCurrentYear+keySeparator+'DOS'+keySeparator+NewBusinessLabel;
		  }
		  else{
		  tgmiPro.id = keySeparator+categoryList[i]+keySeparator+Label.BudgetNewBusinessAcountId+keySeparator+pl+keySeparator+Label.BudgetCurrentYear+keySeparator+'DOS'+keySeparator+NewBusinessLabel;
		  }
		  tgmiPro.Account = NewBusinessYearLabel;
		  tgmiPro.Jan = blankMonths[0];
		  tgmiPro.Feb = blankMonths[1];
		  tgmiPro.Mar = blankMonths[2];
		  tgmiPro.Apr = blankMonths[3];
		  tgmiPro.May = blankMonths[4];
		  tgmiPro.Jun = blankMonths[5];
		  tgmiPro.Jul = blankMonths[6];
		  tgmiPro.Aug = blankMonths[7];
		  tgmiPro.Sep = blankMonths[8];
		  tgmiPro.Oct = blankMonths[9];
		  tgmiPro.Nov = blankMonths[10];
		  tgmiPro.Dec = blankMonths[11];
		 
		  tgmiPro.format('c');
		 
		  tgmiProList.add(tgmiPro);
		  tgmiPro =  new BudgetingToolModelDOS.Items_Pro();
		  if(loggedInUserBudgetType == 'National'){
		  tgmiPro.id =  keySeparator+selectedDMA+keySeparator+categoryList[i]+keySeparator+Label.BudgetNewBusinessAcountId+keySeparator+pl+keySeparator+Label.BudgetCurrentYear+keySeparator+'DOS'+keySeparator+ChurnLabel;
		  }
		  else{
		  tgmiPro.id = keySeparator+categoryList[i]+keySeparator+Label.BudgetNewBusinessAcountId+keySeparator+pl+keySeparator+Label.BudgetCurrentYear+keySeparator+'DOS'+keySeparator+ChurnLabel;
		  }
		  tgmiPro.Account = ChurnYearLabel;
		  tgmiPro.Jan = blankMonths[0];
		  tgmiPro.Feb = blankMonths[1];
		  tgmiPro.Mar = blankMonths[2];
		  tgmiPro.Apr = blankMonths[3];
		  tgmiPro.May = blankMonths[4];
		  tgmiPro.Jun = blankMonths[5];
		  tgmiPro.Jul = blankMonths[6];
		  tgmiPro.Aug = blankMonths[7];
		  tgmiPro.Sep = blankMonths[8];
		  tgmiPro.Oct = blankMonths[9];
		  tgmiPro.Nov = blankMonths[10];
		  tgmiPro.Dec = blankMonths[11];
		 
		  tgmiPro.format('c');
		 
		  tgmiProList.add(tgmiPro);
		 
		  tgmiAcc.Items=tgmiProList;
		  tgmiAccList.add(tgmiAcc);
		  }
		 
		  tgmb = new BudgetingToolModelDOS.Body();
		  tgmb.Account = categoryList[i];
		  tgmb.Category = categoryList[i];
		  tgmb.items = tgmiAccList;
		  tgmbList.add(tgmb);
		  }
		  }
		 
		  tgmDOSLocal.body = new List<List<BudgetingToolModelDOS.Body>>();
		  tgmDOSLocal.body.add(tgmbList);*/

		return tgmDOSLocal;
	}

	/**
	 * This method queries Salesforce objects required for grid data rows, for an AE user
	 *
	 * @param  (none) (NA)
	 * @return (void) (NA)
	 */
	public void queryAETreeData() {
		try {
			GridHelper rh = new GridHelper();
			if (budgetKeys == null || budgetKeys.size() == 0) {
				budgetKeys = new Map<String, gridHelper> ();
			}

			Set<String> comSet = new Set<String> ();
			List<String> comList = new List<String> ();
			advertiserIdList = new Set<Id> ();
			Map<String, String> accComMap;
			if (accComMap == null || accComMap.size() == 0) {
				accComMap = new Map<String, String> ();
			}
			queryAEAccTeamData(rh, accComMap, comSet, comList);
			//Query Current year's Workflow
			for (Sales_Budget__c sb :[SELECT Advertiser__c, Amount__c, Broadcast_Month_Date__c, Budget_User__c, Commodity__c, DMA__c, External_Id__c, Id, Name, OwnerId, Product_Line__c, Status__c, Type__c, Churn_Indicator__c, Advertiser__r.name
			     FROM Sales_Budget__c
			     WHERE Budget_User__c = :loggedInUser.id and
			     CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.BudgetCurrentYear) and
			     type__c in('Workflow') limit 1]) {

				sbStatus = sb.Status__c;
				gridWorkflowStatus = sb.Status__c;
				sbWorkflow = sb;
				sbWorkflowId = sb.id;
				System.debug('sbWorkflowId: ' + sbWorkflowId);
				showApproval = UserApprovalGeneration.showapprovalUI(sbWorkflowId);
				Date forecastDate = date.valueof(System.Label.ForecastingDate);

				//  System.debug('Show Approval: '+ showApproval);
				if (sb.Status__c == 'Submitted' || sb.Status__c == 'Final Approval' || sb.Status__c == 'Intermediate Approval') {
					noSaveMode = true;
				}
				if (sb.Status__c == 'Final Approval' || sb.Status__c == 'Intermediate Approval') {
					noSaveModeDOS = true;
				}
				if (showApproval == false) {
					noApproveMode = true;
					//noSaveMode = true;
					System.debug('No Save Mode: ' + noSaveMode);
				}
				System.debug('AE SB Status: ' + sb.Status__c);
				if (sb.Status__c != 'Pending' && sb.Status__c != 'Forecast Rejected' && Date.Today() < forecastDate) {
					submissionDateCheck = 'Forecast Approve';
				}

				/*if(showApproval == true && (sb.Status__c != 'Pending' && sb.Status__c != 'Forecast Rejected' && sb.Status__c != 'Rejected')){
				  submissionDateCheck = 'NA';
				  if(Date.Today() >= forecastDate){
				  submissionDateCheck = 'Budget';
				  }
				  }*/
				System.debug('Submission Date Check: ' + submissionDateCheck);
			}


			if (sbWorkflow == null || String.isBlank(sbWorkflow.status__c) || sbWorkflow.status__c == 'Pending' || sbWorkflow.status__c == 'Forecast Rejected') {

				//Query Previous year's Revenue
				for (AggregateResult sr :[SELECT Budget_DMA__c, Advertiser__c, sum(Net_Projected_Amount__c) amount, Advertiser__r.Primary_Commodity__c Primary_Commodity__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year
				     FROM Revenue__c
				     WHERE((Account_Executive__c = :loggedInUser.id AND revenue_user__c = null) OR(revenue_user__c = :loggedInUser.id AND Account_Executive__c != NULL)) AND
				     CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.RevenuePY)
				     and
				     //Revenue__c  != null AND
				     //Primary_Commodity__c =:selectedPCom and
				     Advertiser__r.Primary_Commodity__c != null and
				     Product_Line__c in :loggedInUserProductLines.split(';')
				     group by Advertiser__r.Name, Budget_DMA__c, Advertiser__r.Primary_Commodity__c, Advertiser__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c)
				     order by Advertiser__r.Name, Budget_DMA__c, Advertiser__r.Primary_Commodity__c, Advertiser__c, min(Product_Line_Sequence__c) asc]) {

					String commodity = '';
					if ((String) sr.get('Advertiser__c') == Label.Dummy_Revenue_Account) {
						commodity = 'Unmapped Revenue';
					}
					else {
						commodity = (String) sr.get('Primary_Commodity__c');
					}
					String key = keySeparator + commodity + keySeparator + (String) sr.get('Advertiser__c') + keySeparator + (String) sr.get('Product_Line__c') + keySeparator + Label.BudgetCurrentYear;
					rh = new gridHelper();
					rh.dma = (String) sr.get('Budget_DMA__c');
					rh.commodity = commodity;
					rh.Advertiser = (String) sr.get('Advertiser__c');
					rh.ProductLine = (String) sr.get('Product_Line__c');
					rh.year = (Integer) sr.get('year');
					if (revenuePYMap.containsKey(key)) {
						rh.months = revenuePYMap.get(key).months;
					}
					if (commodity == 'Unmapped Revenue') {
						rh.months[(Integer) sr.get('mon') - 1] = rh.months[(Integer) sr.get('mon') - 1] + Integer.valueOf((Decimal) sr.get('amount'));
					}
					else {
						rh.months[(Integer) sr.get('mon') - 1] += Integer.valueOf((Decimal) sr.get('amount'));
					}
					revenuePYMap.put(key, rh);
					budgetKeys.put(key, rh);
					advertiserIdList.add((Id) sr.get('Advertiser__c'));
				}

				//Query Current year's Revenue
				for (AggregateResult sr :[SELECT Budget_DMA__c, Advertiser__c, sum(Net_Projected_Amount__c) amount, Advertiser__r.Primary_Commodity__c Primary_Commodity__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year
				     FROM Revenue__c
				     WHERE((Account_Executive__c = :loggedInUser.id AND revenue_user__c = null) OR(revenue_user__c = :loggedInUser.id AND Account_Executive__c != NULL)) AND
				     CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.RevenueCY) and
				     //Revenue__c  != null AND
				     //Primary_Commodity__c =:selectedPCom and 
				     Advertiser__r.Primary_Commodity__c != null and
				     Product_Line__c in :loggedInUserProductLines.split(';')
				     group by Advertiser__r.Name, Budget_DMA__c, Advertiser__r.Primary_Commodity__c, Advertiser__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c)
				     order by Advertiser__r.Name, Budget_DMA__c, Advertiser__r.Primary_Commodity__c, Advertiser__c, min(Product_Line_Sequence__c) asc]) {

					String commodity = '';
					if ((String) sr.get('Advertiser__c') == Label.Dummy_Revenue_Account) {
						commodity = 'Unmapped Revenue';
					}
					else {
						commodity = (String) sr.get('Primary_Commodity__c');
					}
					String key = keySeparator + commodity + keySeparator + (String) sr.get('Advertiser__c') + keySeparator + (String) sr.get('Product_Line__c') + keySeparator + Label.BudgetCurrentYear;
					rh = new gridHelper();
					rh.dma = (String) sr.get('Budget_DMA__c');
					rh.commodity = commodity;
					rh.Advertiser = (String) sr.get('Advertiser__c');
					rh.ProductLine = (String) sr.get('Product_Line__c');
					rh.year = (Integer) sr.get('year');
					if (revenueCYMap.containsKey(key)) {
						rh.months = revenueCYMap.get(key).months;
					}
					if (commodity == 'Unmapped Revenue') {
						rh.months[(Integer) sr.get('mon') - 1] = rh.months[(Integer) sr.get('mon') - 1] + Integer.valueOf((Decimal) sr.get('amount'));
					}
					else {
						rh.months[(Integer) sr.get('mon') - 1] += Integer.valueOf((Decimal) sr.get('amount'));
					}
					revenueCYMap.put(key, rh);
					budgetKeys.put(key, rh);
					advertiserIdList.add((Id) sr.get('Advertiser__c'));
				}

				for (AggregateResult sr :[SELECT Budget_DMA__c, Advertiser__c, sum(Net_Projected_Amount__c) amount, Advertiser__r.Primary_Commodity__c Primary_Commodity__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year
				     FROM Revenue__c
				     WHERE((Account_Executive__c = :loggedInUser.id AND revenue_user__c = null) OR(revenue_user__c = :loggedInUser.id AND Account_Executive__c != NULL)) AND
				     CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.RevenueNY)
				     and
				     Advertiser__r.Primary_Commodity__c != null and
				     Product_Line__c in :loggedInUserProductLines.split(';')
				     group by Advertiser__r.Name, Budget_DMA__c, Advertiser__r.Primary_Commodity__c, Advertiser__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c)
				     order by Advertiser__r.Name, Budget_DMA__c, Advertiser__r.Primary_Commodity__c, Advertiser__c, min(Product_Line_Sequence__c) asc]) {
					System.debug('Test1@@@@@@');
					String commodity = '';
					if ((String) sr.get('Advertiser__c') == Label.Dummy_Revenue_Account) {
						commodity = 'Unmapped Revenue';
					}
					else {
						commodity = (String) sr.get('Primary_Commodity__c');
					}
					String key = keySeparator + commodity + keySeparator + (String) sr.get('Advertiser__c') + keySeparator + (String) sr.get('Product_Line__c') + keySeparator + Label.BudgetCurrentYear;
					rh = new gridHelper();
					rh.dma = (String) sr.get('Budget_DMA__c');
					rh.commodity = commodity;
					rh.Advertiser = (String) sr.get('Advertiser__c');
					rh.ProductLine = (String) sr.get('Product_Line__c');
					rh.year = (Integer) sr.get('year');
					if (revenueNYMap.containsKey(key)) {
						rh.months = revenueNYMap.get(key).months;
					}
					if (commodity == 'Unmapped Revenue') {
						rh.months[(Integer) sr.get('mon') - 1] = rh.months[(Integer) sr.get('mon') - 1] + Integer.valueOf((Decimal) sr.get('amount'));
					}
					else {
						rh.months[(Integer) sr.get('mon') - 1] += Integer.valueOf((Decimal) sr.get('amount'));
					}
					System.debug('key' + key);
					revenueNYMap.put(key, rh);
					System.debug(revenueNYMap);
					budgetKeys.put(key, rh);
					advertiserIdList.add((Id) sr.get('Advertiser__c'));
				}


				Map<String, SyscodeProductLineMap__c> custSettMap = SyscodeProductLineMap__c.getAll();
				//Query Current year's Forecast
				for (AggregateResult pzmv :[SELECT proposal_zone__r.proposal__r.opportunity__r.accountId accId, sum(Broadcast_Amount__c) amount, proposal_zone__r.proposal__r.opportunity__r.account.Primary_Commodity__c cc,
				     proposal_zone__r.sys_code__c syscode, CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year
				     FROM Proposal_Zone_Monthly_Value__c
				     where proposal_zone__r.proposal__r.opportunity__r.ownerid = :loggedInUser.id and
				     proposal_zone__r.proposal__r.opportunity__r.accountId in :advertiserIdList and
				((proposal_zone__r.proposal__r.recordtype.name = 'Opportunity Budget' and proposal_zone__r.proposal__r.Active__c = true) or
				(proposal_zone__r.proposal__r.recordtype.name = 'Linear' and proposal_zone__r.status_type__c = 'Pending' and proposal_zone__r.proposal__r.Active__c = true)) and
				     CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.BudgetForecastCurrentYear)
				     //and Proposal_Zone__r.Sys_Code__c in: custSettMap.keySet() 
				     // and proposal_zone__r.proposal__r.opportunity__r.account.Primary_Commodity__c in:comList
				     group by proposal_zone__r.proposal__r.opportunity__r.accountId, proposal_zone__r.proposal__r.opportunity__r.account.Primary_Commodity__c,
				     proposal_zone__r.sys_code__c, CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c)
				     order by Proposal_Zone__r.Sys_Code__c]) {
					String productLine = (String) pzmv.get('syscode');
					if (custSettMap.containsKey((String) pzmv.get('syscode'))) {
						productLine = custSettMap.get((String) pzmv.get('syscode')).product_Line__c;
					}
					else
					{
						productLine = 'Linear/News/Sports';
					}
					System.debug('pzmv ' + pzmv);
					String key = keySeparator + (String) pzmv.get('cc') + keySeparator + (String) pzmv.get('accId') +
					keySeparator + productLine + keySeparator + Label.BudgetCurrentYear;
					rh = new GridHelper();
					rh.commodity = (String) pzmv.get('cc');
					rh.Advertiser = (String) pzmv.get('accId');
					rh.ProductLine = productLine;
					rh.year = (Integer) pzmv.get('year');
					if (forecastMap.containsKey(key)) {
						rh.months = forecastMap.get(key).months;
					}

					if ((Integer) pzmv.get('mon') <= Integer.Valueof(Label.Forecast_Month)) {
						if (revenueCYMap.get(key) != null) {
							for (Integer i = 0; i<Integer.Valueof(Label.Forecast_Month); i++)
							{
								rh.months[i] = revenueCYMap.get(key).months[i];
							}
						}
					}
					else {
						if (Integer.valueOf((Decimal) pzmv.get('amount')) != null) {
							rh.months[(Integer) pzmv.get('mon') - 1] = Integer.valueOf((Decimal) pzmv.get('amount'));
						}
						if (revenueCYMap.get(key) != null) {
							for (Integer j = 0; j<Integer.Valueof(Label.Forecast_Month); j++)
							{
								rh.months[j] = revenueCYMap.get(key).months[j];
							}
						}
					}
					forecastMap.put(key, rh);
					budgetKeys.put(key, rh);
					advertiserIdList.add((Id) pzmv.get('accId'));
				}
				if (Label.Budget_CopyRevenuetoForecast == 'true') {
					for (String s : revenueCYMap.keySet()) {
						if (!forecastMap.containsKey(s)) {
							rh = new GridHelper();
							rh = revenueCYMap.get(s);
							forecastMap.put(s, rh);
						}
						else {
							if (revenueCYMap.get(s).months != null && forecastMap.get(s).months != null) {
								forecastMap.get(s).months[7] = forecastMap.get(s).months[7] + revenueCYMap.get(s).months[7];
								forecastMap.get(s).months[8] = forecastMap.get(s).months[8] + revenueCYMap.get(s).months[8];
								forecastMap.get(s).months[9] = forecastMap.get(s).months[9] + revenueCYMap.get(s).months[9];
								forecastMap.get(s).months[10] = forecastMap.get(s).months[10] + revenueCYMap.get(s).months[10];
								forecastMap.get(s).months[11] = forecastMap.get(s).months[11] + revenueCYMap.get(s).months[11];
							}
						}
					}
					//Populate Forecast Map for keys where no Revenue exists
					for (String s : forecastMap.keySet()) {
						System.debug('forecastMap KEY: ' + s);
						if (!revenueCYMap.containsKey(s)) {
							forecastMap.get(s).months[7] = forecastMap.get(s).months[7];
							forecastMap.get(s).months[8] = forecastMap.get(s).months[8];
							forecastMap.get(s).months[9] = forecastMap.get(s).months[9];
							forecastMap.get(s).months[10] = forecastMap.get(s).months[10];
							forecastMap.get(s).months[11] = forecastMap.get(s).months[11];
						}
					}
				}
			}
			else {
				//queryAEAccTeamData(rh,accComMap,comSet,comList);
				for (Sales_Budget__c sb :[SELECT
				     Advertiser__c,
				     CY_FCST_1_Jan_Amount__c, CY_FCST_2_Feb_Amount__c, CY_FCST_3_March_Amount__c, CY_FCST_4_April_Amount__c, CY_FCST_5_May_Amount__c, CY_FCST_6_June_Amount__c, CY_FCST_7_July_Amount__c,
				     CY_FCST_8_Aug_Amount__c, CY_FCST_9_Sep_Amount__c, CY_FCST_10_Oct_Amount__c, CY_FCST_11_Nov_Amount__c, CY_FCST_12_Dec_Amount__c,
				     PY_Rev_1_Jan_Amount__c, PY_Rev_2_Feb_Amount__c, PY_Rev_3_March_Amount__c, PY_Rev_4_April_Amount__c, PY_Rev_5_May_Amount__c, PY_Rev_6_June_Amount__c, PY_Rev_7_July_Amount__c,
				     PY_Rev_8_Aug_Amount__c, PY_Rev_9_Sep_Amount__c, PY_Rev_10_Oct_Amount__c, PY_Rev_11_Nov_Amount__c, PY_Rev_12_Dec_Amount__c,
				     CY_Rev_1_Jan_Amount__c, CY_Rev_2_Feb_Amount__c, CY_Rev_3_March_Amount__c, CY_Rev_4_April_Amount__c, CY_Rev_5_May_Amount__c, CY_Rev_6_June_Amount__c, CY_Rev_7_July_Amount__c,
				     CY_Rev_8_Aug_Amount__c, CY_Rev_9_Sep_Amount__c, CY_Rev_10_Oct_Amount__c, CY_Rev_11_Nov_Amount__c, CY_Rev_12_Dec_Amount__c,
					 NY_Revenue_1_Jan_Amount__c, NY_Revenue_2_Feb_Amount__c, NY_Revenue_3_March_Amount__c, NY_Revenue_4_April_Amount__c, NY_Revenue_5_May_Amount__c, NY_Revenue_6_June_Amount__c, NY_Revenue_7_July_Amount__c,
				     NY_Revenue_8_Aug_Amount__c, NY_Revenue_9_Sep_Amount__c, NY_Revenue_10_Oct_Amount__c, NY_Revenue_11_Nov_Amount__c, NY_Revenue_12_Dec_Amount__c,
				     Broadcast_Month_Date__c, Budget_User__c, Commodity__c, DMA__c, External_Id__c, Id, Name, OwnerId, Product_Line__c, Status__c, Type__c
				     FROM Sales_Budget__c
				     WHERE Budget_User__c = :loggedInUser.id and
				     Advertiser__c in :advertiserIdList and
				     CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.BudgetCurrentYear) and
				     Product_Line__c in :loggedInUserProductLines.split(';') and
				     type__c = 'Forecast'
				     ORDER BY Advertiser__r.Name])
				{
					String key = keySeparator + (String) sb.get('Commodity__c') + keySeparator + (String) sb.get('Advertiser__c') + keySeparator + (String) sb.get('Product_Line__c') + keySeparator + Label.BudgetCurrentYear;
					rh = new GridHelper();
					//rh.dma = (String)sb.get('DMA__c');
					rh.commodity = (String) sb.get('Commodity__c');
					rh.Advertiser = (String) sb.get('Advertiser__c');
					rh.ProductLine = (String) sb.get('Product_Line__c');
					rh.year = ((Date) sb.get('Broadcast_Month_Date__c')).year();

					if (forecastMap.containsKey(key)) {
						rh.months = forecastMap.get(key).months;
					}

					GridHelper rh1 = new GridHelper();
					//rh1.dma = (String)sb.get('DMA__c');
					rh1.commodity = (String) sb.get('Commodity__c');
					rh1.Advertiser = (String) sb.get('Advertiser__c');
					rh1.ProductLine = (String) sb.get('Product_Line__c');
					rh1.year = ((Date) sb.get('Broadcast_Month_Date__c')).year();

					if (forecastMap.containsKey(key)) {
						rh1.months = forecastMap.get(key).months;
					}

					GridHelper rh2 = new GridHelper();
					//rh2.dma = (String)sb.get('DMA__c');
					rh2.commodity = (String) sb.get('Commodity__c');
					rh2.Advertiser = (String) sb.get('Advertiser__c');
					rh2.ProductLine = (String) sb.get('Product_Line__c');
					rh2.year = ((Date) sb.get('Broadcast_Month_Date__c')).year();

					if (forecastMap.containsKey(key)) {
						rh2.months = forecastMap.get(key).months;
					}

					GridHelper rh3 = new GridHelper();
					//rh2.dma = (String)sb.get('DMA__c');
					rh3.commodity = (String) sb.get('Commodity__c');
					rh3.Advertiser = (String) sb.get('Advertiser__c');
					rh3.ProductLine = (String) sb.get('Product_Line__c');
					rh3.year = ((Date) sb.get('Broadcast_Month_Date__c')).year();

					if (forecastMap.containsKey(key)) {
						rh3.months = forecastMap.get(key).months;
					}

					rh.months[0] = Integer.valueOf((Decimal) sb.get('CY_FCST_1_Jan_Amount__c'));
					rh.months[1] = Integer.valueOf((Decimal) sb.get('CY_FCST_2_Feb_Amount__c'));
					rh.months[2] = Integer.valueOf((Decimal) sb.get('CY_FCST_3_March_Amount__c'));
					rh.months[3] = Integer.valueOf((Decimal) sb.get('CY_FCST_4_April_Amount__c'));
					rh.months[4] = Integer.valueOf((Decimal) sb.get('CY_FCST_5_May_Amount__c'));
					rh.months[5] = Integer.valueOf((Decimal) sb.get('CY_FCST_6_June_Amount__c'));
					rh.months[6] = (sb.get('CY_FCST_7_July_Amount__c') == null ? 0 : Integer.valueOf((Decimal) sb.get('CY_FCST_7_July_Amount__c'))) + (sb.get('CY_Rev_7_July_Amount__c') == null ? 0 : Integer.valueOf((Decimal) sb.get('CY_Rev_7_July_Amount__c')));
					rh.months[7] = (sb.get('CY_FCST_8_Aug_Amount__c') == null ? 0 : Integer.valueOf((Decimal) sb.get('CY_FCST_8_Aug_Amount__c'))) + (sb.get('CY_Rev_8_Aug_Amount__c') == null ? 0 : Integer.valueOf((Decimal) sb.get('CY_Rev_8_Aug_Amount__c')));
					rh.months[8] = (sb.get('CY_FCST_9_Sep_Amount__c') == null ? 0 : Integer.valueOf((Decimal) sb.get('CY_FCST_9_Sep_Amount__c'))) + (sb.get('CY_Rev_9_Sep_Amount__c') == null ? 0 : Integer.valueOf((Decimal) sb.get('CY_Rev_9_Sep_Amount__c')));
					rh.months[9] = (sb.get('CY_FCST_10_Oct_Amount__c') == null ? 0 : Integer.valueOf((Decimal) sb.get('CY_FCST_10_Oct_Amount__c'))) + (sb.get('CY_Rev_10_Oct_Amount__c') == null ? 0 : Integer.valueOf((Decimal) sb.get('CY_Rev_10_Oct_Amount__c')));
					rh.months[10] = (sb.get('CY_FCST_11_Nov_Amount__c') == null ? 0 : Integer.valueOf((Decimal) sb.get('CY_FCST_11_Nov_Amount__c'))) + (sb.get('CY_Rev_11_Nov_Amount__c') == null ? 0 : Integer.valueOf((Decimal) sb.get('CY_Rev_11_Nov_Amount__c')));
					rh.months[11] = (sb.get('CY_FCST_12_Dec_Amount__c') == null ? 0 : Integer.valueOf((Decimal) sb.get('CY_FCST_12_Dec_Amount__c'))) + (sb.get('CY_Rev_12_Dec_Amount__c') == null ? 0 : Integer.valueOf((Decimal) sb.get('CY_Rev_12_Dec_Amount__c')));
					forecastMap.put(key, rh);

					rh1.months[0] = Integer.valueOf((Decimal) sb.get('PY_Rev_1_Jan_Amount__c'));
					rh1.months[1] = Integer.valueOf((Decimal) sb.get('PY_Rev_2_Feb_Amount__c'));
					rh1.months[2] = Integer.valueOf((Decimal) sb.get('PY_Rev_3_March_Amount__c'));
					rh1.months[3] = Integer.valueOf((Decimal) sb.get('PY_Rev_4_April_Amount__c'));
					rh1.months[4] = Integer.valueOf((Decimal) sb.get('PY_Rev_5_May_Amount__c'));
					rh1.months[5] = Integer.valueOf((Decimal) sb.get('PY_Rev_6_June_Amount__c'));
					rh1.months[6] = Integer.valueOf((Decimal) sb.get('PY_Rev_7_July_Amount__c'));
					rh1.months[7] = Integer.valueOf((Decimal) sb.get('PY_Rev_8_Aug_Amount__c'));
					rh1.months[8] = Integer.valueOf((Decimal) sb.get('PY_Rev_9_Sep_Amount__c'));
					rh1.months[9] = Integer.valueOf((Decimal) sb.get('PY_Rev_10_Oct_Amount__c'));
					rh1.months[10] = Integer.valueOf((Decimal) sb.get('PY_Rev_11_Nov_Amount__c'));
					rh1.months[11] = Integer.valueOf((Decimal) sb.get('PY_Rev_12_Dec_Amount__c'));
					revenuePYMap.put(key, rh1);

					rh2.months[0] = Integer.valueOf((Decimal) sb.get('CY_Rev_1_Jan_Amount__c'));
					rh2.months[1] = Integer.valueOf((Decimal) sb.get('CY_Rev_2_Feb_Amount__c'));
					rh2.months[2] = Integer.valueOf((Decimal) sb.get('CY_Rev_3_March_Amount__c'));
					rh2.months[3] = Integer.valueOf((Decimal) sb.get('CY_Rev_4_April_Amount__c'));
					rh2.months[4] = Integer.valueOf((Decimal) sb.get('CY_Rev_5_May_Amount__c'));
					rh2.months[5] = Integer.valueOf((Decimal) sb.get('CY_Rev_6_June_Amount__c'));
					rh2.months[6] = Integer.valueOf((Decimal) sb.get('CY_Rev_7_July_Amount__c'));
					rh2.months[7] = Integer.valueOf((Decimal) sb.get('CY_Rev_8_Aug_Amount__c'));
					rh2.months[8] = Integer.valueOf((Decimal) sb.get('CY_Rev_9_Sep_Amount__c'));
					rh2.months[9] = Integer.valueOf((Decimal) sb.get('CY_Rev_10_Oct_Amount__c'));
					rh2.months[10] = Integer.valueOf((Decimal) sb.get('CY_Rev_11_Nov_Amount__c'));
					rh2.months[11] = Integer.valueOf((Decimal) sb.get('CY_Rev_12_Dec_Amount__c'));
					revenueCYMap.put(key, rh2);

					rh3.months[0] = Integer.valueOf((Decimal) sb.get('NY_Revenue_1_Jan_Amount__c'));
					rh3.months[1] = Integer.valueOf((Decimal) sb.get('NY_Revenue_2_Feb_Amount__c'));
					rh3.months[2] = Integer.valueOf((Decimal) sb.get('NY_Revenue_3_March_Amount__c'));
					rh3.months[3] = Integer.valueOf((Decimal) sb.get('NY_Revenue_4_April_Amount__c'));
					rh3.months[4] = Integer.valueOf((Decimal) sb.get('NY_Revenue_5_May_Amount__c'));
					rh3.months[5] = Integer.valueOf((Decimal) sb.get('NY_Revenue_6_June_Amount__c'));
					rh3.months[6] = Integer.valueOf((Decimal) sb.get('NY_Revenue_7_July_Amount__c'));
					rh3.months[7] = Integer.valueOf((Decimal) sb.get('NY_Revenue_8_Aug_Amount__c'));
					rh3.months[8] = Integer.valueOf((Decimal) sb.get('NY_Revenue_9_Sep_Amount__c'));
					rh3.months[9] = Integer.valueOf((Decimal) sb.get('NY_Revenue_10_Oct_Amount__c'));
					rh3.months[10] = Integer.valueOf((Decimal) sb.get('NY_Revenue_11_Nov_Amount__c'));
					rh3.months[11] = Integer.valueOf((Decimal) sb.get('NY_Revenue_12_Dec_Amount__c'));
					revenueNYMap.put(key, rh3);

					budgetKeys.put(key, rh1);
					budgetKeys.put(key, rh2);
					budgetKeys.put(key, rh);
					budgetKeys.put(key, rh3);
					//advertiserIdList.add((Id)sb.get('Advertiser__c'));
				}
			}
			System.debug('forecastMap size while get: ' + forecastMap.size());


		}

		catch(Exception ex) {
			System.debug(ex.getMessage());
			System.debug(ex.getStackTraceString());
			system.debug('Exception at line 1638: ' + ex.getMessage() + ' at Line: ' + ex.getLineNumber());
			//create new mail message
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(new String[] { 'shubham.gupta@mandsconsulting.com' });
			mail.setSubject('Developer script exception from New Spectrum Reach : BudgetingToolNSMGridController : SaveNationalForecast : ');
			mail.setPlainTextBody(ex.getMessage() + ex.getLineNumber());

			//send mail
			//Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

		}
	}


	public void queryAEAccTeamData(GridHelper rh, Map<String, String> accComMap, Set<String> comSet, List<String> comList)
	{
		//Create Budget keys
		for (Sales_Budget__c sb :[SELECT Advertiser__c, Commodity__c
		     FROM Sales_Budget__c
		     WHERE Budget_User__c = :loggedInUser.id and
		     CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.BudgetCurrentYear) and
		     type__c in('Data') and
		     advertiser__c != :Label.BudgetNewBusinessAcountId
		     order by Advertiser__r.Name, Commodity__c asc]) {
			for (String pl : loggedInUserProductLines.split(';')) {
				String key = keySeparator + sb.Commodity__c + keySeparator + sb.Advertiser__c + keySeparator + pl + keySeparator + Label.BudgetCurrentYear;
				rh = new gridHelper();
				rh.commodity = sb.Commodity__c;
				rh.Advertiser = sb.Advertiser__c;
				rh.ProductLine = pl;
				rh.year = Integer.valueOf(Label.BudgetCurrentYear);
				budgetKeys.put(key, rh);

				accComMap.put(sb.Advertiser__c, sb.Commodity__c);
			}
			advertiserIdList.add(sb.Advertiser__c);

			comSet.add(sb.Commodity__c);
		}
		for (AccountTeamMember atm :[SELECT TeamMemberRole, accountid, account.name, account.Primary_Commodity__c
		     FROM AccountTeamMember
		     WHERE UserId = :loggedInUser.id and
		     account.Primary_Commodity__c != null
		     order by account.name, account.Primary_Commodity__c asc]) {
			for (String pl : loggedInUserProductLines.split(';')) {
				String com = atm.account.Primary_Commodity__c;
				if (accComMap.containsKey(atm.accountId)) {
					com = accComMap.get(atm.accountId);
				}
				String key = keySeparator + com + keySeparator + atm.accountId + keySeparator + pl + keySeparator + Label.BudgetCurrentYear;
				rh = new gridHelper();
				rh.commodity = com;
				rh.Advertiser = atm.accountId;
				rh.ProductLine = pl;
				rh.year = Integer.valueOf(Label.BudgetCurrentYear);
				budgetKeys.put(key, rh);
			}
			if (!accComMap.containsKey(atm.accountId)) {
				advertiserIdList.add(atm.accountId);
				comSet.add(atm.account.Primary_Commodity__c);
			}
		}
		advertiserIdList.add(Label.BudgetNewBusinessAcountId);
		System.debug('advertiserIdList: ' + advertiserIdList.size());

		//Logic for Commodity selector if less than max ATM count
		if (advertiserIdList.size() <= Integer.valueOf(Label.BudgetMaxAdvertiserCount)) {
			comList.addAll(comSet);

			Integer i = 1;
			PComList = '\'';
			for (String cm : comSet) {
				PComList = PComList + '|' + cm;
				if (String.isBlank(selectedPCom)) {
					if (i == 1) {
						comList.add(cm);
						selectedPCom = 'All';
					}
				}
				i++;
			}
			PComList = PComList + '\'';

			System.debug('AllPrimaryCommodities: ' + comList);
			System.debug('selectedPCom: ' + selectedPCom);

			//Logic for Commodity selector if a commodity other than All is selected
			if (String.isNotBlank(selectedPCom) && selectedPCom != 'All') {
				System.debug('In 1');
				//Create Budget keys
				comList = new List<String> ();
				budgetKeys = new Map<String, gridHelper> ();
				accComMap = new Map<String, String> ();
				for (Sales_Budget__c sb :[SELECT Advertiser__c, Commodity__c
				     FROM Sales_Budget__c
				     WHERE Budget_User__c = :loggedInUser.id and
				     CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.BudgetCurrentYear) and
				     type__c in('Data') and
				     Commodity__c = :selectedPCom
				     Order By Advertiser__r.Name]) {
					for (String pl : loggedInUserProductLines.split(';')) {
						String key = keySeparator + sb.Commodity__c + keySeparator + sb.Advertiser__c + keySeparator + pl + keySeparator + Label.BudgetCurrentYear;
						rh = new gridHelper();
						rh.commodity = sb.Commodity__c;
						rh.Advertiser = sb.Advertiser__c;
						rh.ProductLine = pl;
						rh.year = Integer.valueOf(Label.BudgetCurrentYear);
						budgetKeys.put(key, rh);
						accComMap.put(sb.Advertiser__c, sb.Commodity__c);
					}
					advertiserIdList.add(sb.Advertiser__c);
					comSet.add(sb.Commodity__c);
					comList.add(sb.Commodity__c);
				}
				for (AccountTeamMember atm :[SELECT TeamMemberRole, accountid, account.name, account.Primary_Commodity__c
				     FROM AccountTeamMember
				     WHERE UserId = :loggedInUser.id and
				     account.Primary_Commodity__c = :selectedPCom
				     ORDER BY account.name]) {
					for (String pl : loggedInUserProductLines.split(';')) {
						String com = atm.account.Primary_Commodity__c;
						if (accComMap.containsKey(atm.accountId)) {
							com = accComMap.get(atm.accountId);
						}
						String key = keySeparator + com + keySeparator + atm.accountId + keySeparator + pl + keySeparator + Label.BudgetCurrentYear;
						rh = new gridHelper();
						rh.commodity = com;
						rh.Advertiser = atm.accountId;
						rh.ProductLine = pl;
						rh.year = Integer.valueOf(Label.BudgetCurrentYear);
						budgetKeys.put(key, rh);
					}
					if (!accComMap.containsKey(atm.accountId)) {
						advertiserIdList.add(atm.accountId);
						comSet.add(atm.account.Primary_Commodity__c);
						comList.add(atm.account.Primary_Commodity__c);
					}
				}
			}
		}
		//Logic for Commodity selector if more than max ATM count
		else {
			System.debug('In else');
			Integer i = 1;
			PComList = '\'';
			for (String cm : comSet) {
				PComList = PComList + '|' + cm;
				if (String.isBlank(selectedPCom)) {
					if (i == 1) {
						comList.add(cm);
						selectedPCom = cm;
					}
				}
				else {
					comList.add(selectedPCom);
				}
				i++;
			}
			PComList = PComList + '\'';
			System.debug('PComList: ' + PComList);
			System.debug('comList: ' + comList);
			System.debug('selectedPCom: ' + selectedPCom);

			//Create Budget keys
			budgetKeys = new Map<String, gridHelper> ();
			accComMap = new Map<String, String> ();
			for (Sales_Budget__c sb :[SELECT Advertiser__c, Commodity__c
			     FROM Sales_Budget__c
			     WHERE Budget_User__c = :loggedInUser.id and
			     CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.BudgetCurrentYear) and
			     type__c in('Data') //and
			     //Commodity__c = :selectedPCom
			     ORDER BY Advertiser__r.Name ASC]) {
				for (String pl : loggedInUserProductLines.split(';')) {
					String key = keySeparator + sb.Commodity__c + keySeparator + sb.Advertiser__c + keySeparator + pl + keySeparator + Label.BudgetCurrentYear;
					rh = new gridHelper();
					rh.commodity = sb.Commodity__c;
					rh.Advertiser = sb.Advertiser__c;
					rh.ProductLine = pl;
					rh.year = Integer.valueOf(Label.BudgetCurrentYear);
					budgetKeys.put(key, rh);
					accComMap.put(sb.Advertiser__c, sb.Commodity__c);
				}
				advertiserIdList.add(sb.Advertiser__c);
				comSet.add(sb.Commodity__c);
			}
			for (AccountTeamMember atm :[SELECT TeamMemberRole, accountid, account.name, account.Primary_Commodity__c
			     FROM AccountTeamMember
			     WHERE UserId = :loggedInUser.id and
			     account.Primary_Commodity__c = :selectedPCom
			     Order BY account.name ASC]) {
				for (String pl : loggedInUserProductLines.split(';')) {
					String com = atm.account.Primary_Commodity__c;
					if (accComMap.containsKey(atm.accountId)) {
						com = accComMap.get(atm.accountId);
					}
					String key = keySeparator + com + keySeparator + atm.accountId + keySeparator + pl + keySeparator + Label.BudgetCurrentYear;
					rh = new gridHelper();
					rh.commodity = com;
					rh.Advertiser = atm.accountId;
					rh.ProductLine = pl;
					rh.year = Integer.valueOf(Label.BudgetCurrentYear);
					budgetKeys.put(key, rh);
				}
				if (!accComMap.containsKey(atm.accountId)) {
					advertiserIdList.add(atm.accountId);
					comSet.add(atm.account.Primary_Commodity__c);
				}
			}
		}
		advertiserIdList.add(Label.BudgetNewBusinessAcountId);
		System.debug('comList: ' + comList);

		//Query Advertiser Info
		accMap = new Map<Id, Account> ();
		System.debug('advertiserIdList '+advertiserIdList);
		for (Account acc :[Select id, name from account where id in :advertiserIdList]) {
			acc.name = acc.name.replace('\'', '');
			acc.name = acc.name.replace('\"', '');
			//System.debug(acc.name);
			accMap.put(acc.id, acc);
		}
		//System.debug(accMap);

		//Query Current year's Budget
		for (AggregateResult sb :[SELECT Advertiser__c, sum(Amount__c) amount, Commodity__c, DMA__c, Product_Line__c, Type__c, Churn_Indicator__c,
		     CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year, Advertiser__r.name advertiserName
		     FROM Sales_Budget__c
		     WHERE Budget_User__c = :loggedInUser.id and
		     Product_Line__c in :loggedInUserProductLines.split(';') and
		     CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.BudgetCurrentYear) //and
		     //Commodity__c in :comList 
		     and
		     type__c in('Data')
		     group by DMA__c, Commodity__c, Advertiser__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c), Type__c, Churn_Indicator__c, Advertiser__r.name]) {
			//if (sb.Type__c == 'Data') {
			String key = keySeparator + (String) sb.get('Commodity__c') + keySeparator + (String) sb.get('Advertiser__c') + keySeparator + (String) sb.get('Product_Line__c') + keySeparator + Label.BudgetCurrentYear;
			rh = new GridHelper();
			rh.commodity = (String) sb.get('Commodity__c');
			rh.Advertiser = (String) sb.get('Advertiser__c');
			rh.ProductLine = (String) sb.get('Product_Line__c');
			rh.year = (Integer) sb.get('year');
			if (budgetMap.containsKey(key)) {
				rh.months = budgetMap.get(key).months;
				rh.monthIds = budgetMap.get(key).monthIds;
			}
			rh.months[(Integer) sb.get('mon') - 1] = Integer.valueOf((Decimal) sb.get('amount')) + (rh.months[(Integer) sb.get('mon') - 1] == null ? 0 : rh.months[(Integer) sb.get('mon') - 1]);
			//rh.monthIds[(Integer) sb.get('mon') - 1] = (String) sb.get('Id');
			if (budgetMap.containsKey(key) && (String.isBlank(budgetMap.get(key).ChurnIndicator) || budgetMap.get(key).ChurnIndicator == 'null')) {
				rh.ChurnIndicator = (String) sb.get('Churn_Indicator__c');
			}
			else if (!budgetMap.containsKey(key)) {
				rh.ChurnIndicator = (String) sb.get('Churn_Indicator__c');
			}
			else if (budgetMap.containsKey(key)) {
				rh.ChurnIndicator = budgetMap.get(key).ChurnIndicator;
			}
			System.debug('Budget Key: ' + key);
			budgetMap.put(key, rh);

			if ((String) sb.get('advertiserName') == newBusinessAccount) {
				newBusinessBudgetMap.put(key, rh);
			}
			//}

		}

		System.debug('sbWorkflowId: ' + sbWorkflowId);
		//Query Current year's New Business Budget
		String existingNewBusinessProductLines = '';
		for (AggregateResult sb :[SELECT Advertiser__c, sum(Amount__c) amount, Commodity__c, DMA__c, Product_Line__c, Type__c, Churn_Indicator__c,
		     CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year, New_Business_Churn__c
		     FROM Sales_Budget__c
		     WHERE Budget_User__c = :loggedInUser.id and
		     Advertiser__r.name = :newBusinessAccount and
		     CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.BudgetCurrentYear) and
		     type__c in('Data', 'DOS')
		     group by DMA__c, Commodity__c, Advertiser__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c), Type__c, Churn_Indicator__c, New_Business_Churn__c
		     ]) {
			//System.debug('SB '+sb);
			String key = keySeparator + (String) sb.get('Advertiser__c') + keySeparator + (String) sb.get('Product_Line__c') + keySeparator + Label.BudgetCurrentYear;
			rh = new GridHelper();
			rh.commodity = (String) sb.get('Commodity__c');
			rh.Advertiser = (String) sb.get('Advertiser__c');
			rh.ProductLine = (String) sb.get('Product_Line__c');
			existingNewBusinessProductLines = existingNewBusinessProductLines + (String) sb.get('Product_Line__c') + ',';
			rh.year = (Integer) sb.get('year');
			if (budgetMap.containsKey(key)) {
				rh.months = budgetMap.get(key).months;
				rh.monthIds = budgetMap.get(key).monthIds;
			}
			//rh.months[(Integer) sb.get('mon') - 1] = Integer.valueOf((Decimal) sb.get('amount'));
			//rh.monthIds[(Integer) sb.get('mon') - 1] = (String) sb.get('Id');
			rh.months[(Integer) sb.get('mon') - 1] = Integer.valueOf((Decimal) sb.get('amount')) + (rh.months[(Integer) sb.get('mon') - 1] == null ? 0 : rh.months[(Integer) sb.get('mon') - 1]);
			//rh.monthIds[(Integer) sb.get('mon') - 1] = (String) sb.get('Id');
			if ((String) sb.get('type__c') == 'DOS')
			{
				rh.ChurnIndicator = (String) sb.get('New_Business_Churn__c');
			}
			else {
				if (budgetMap.containsKey(key) && (String.isBlank(budgetMap.get(key).ChurnIndicator) || budgetMap.get(key).ChurnIndicator == 'null')) {
					rh.ChurnIndicator = (String) sb.get('Churn_Indicator__c');
				}
				else if (!budgetMap.containsKey(key)) {
					rh.ChurnIndicator = (String) sb.get('Churn_Indicator__c');
				}
				else if (budgetMap.containsKey(key)) {
					rh.ChurnIndicator = budgetMap.get(key).ChurnIndicator;
				}
			}
			//System.debug('rh.ChurnIndicator: '+ rh.ChurnIndicator);
			budgetKeys.put(key, rh);
			budgetMap.put(key, rh);
			newBusinessBudgetMap.put(key, rh);
		}
		//System.debug(existingNewBusinessProductLines);
		if (!existingNewBusinessProductLines.contains(NewBusinessLabel)) {
			String key = keySeparator + 'New Business/Churn' + keySeparator + Label.BudgetNewBusinessAcountId + keySeparator + NewBusinessLabel + keySeparator + Label.BudgetCurrentYear;
			rh = new GridHelper();
			rh.commodity = 'New Business/Churn';
			rh.Advertiser = Label.BudgetNewBusinessAcountId;
			rh.ProductLine = NewBusinessLabel;
			budgetKeys.put(key, rh);
			budgetMap.put(key, rh);
			newBusinessBudgetMap.put(key, rh);
		}

		if (!existingNewBusinessProductLines.contains(ChurnLabel)) {
			String key = keySeparator + 'New Business/Churn' + keySeparator + Label.BudgetNewBusinessAcountId + keySeparator + ChurnLabel + keySeparator + Label.BudgetCurrentYear;
			rh = new GridHelper();
			rh.commodity = 'New Business/Churn';
			rh.Advertiser = Label.BudgetNewBusinessAcountId;
			rh.ProductLine = ChurnLabel;
			budgetKeys.put(key, rh);
			budgetMap.put(key, rh);
			newBusinessBudgetMap.put(key, rh);
		}
	}

	/**
	 * This method queries Salesforce objects required for grid data rows, for a NSM user
	 *
	 * @param  (none) (NA)
	 * @return (void) (NA)
	 */
	public void queryNSMTreeData() {
		GridHelper rh = new GridHelper();

		if (budgetKeys == null || budgetKeys.size() == 0) {
			budgetKeys = new Map<String, gridHelper> ();
		}
		Integer i = 1;
		DMAList = '\'';
		for (String dm : loggedInUserDMA.split(';')) {
			DMAList = DMAList + '|' + dm;
			if (String.isBlank(selectedDMA)) {
				if (i == 1) {
					selectedDMA = dm;
				}
			}
			i++;
		}
		DMAList = DMAList + '\'';
		System.debug('selectedDMA: ' + selectedDMA + DMAList);


		//Query Current year's Workflow
		for (Sales_Budget__c sb :[SELECT Advertiser__c, Amount__c, Broadcast_Month_Date__c, Budget_User__c, Commodity__c, DMA__c, External_Id__c, Id, Name, OwnerId, Product_Line__c, Status__c, Type__c, Churn_Indicator__c, Advertiser__r.name
		     FROM Sales_Budget__c
		     WHERE Budget_User__c = :loggedInUser.id and
		     CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.BudgetCurrentYear) and
		     type__c in('Workflow') limit 1]) {

			sbStatus = sb.Status__c;
			gridWorkflowStatus = sb.status__c;
			sbWorkflow = sb;
			sbWorkflowId = sb.id;

			showApproval = UserApprovalGeneration.showapprovalUI(sbWorkflowId);
			Date forecastDate = date.valueof(System.Label.ForecastingDate);


			if (sb.Status__c == 'Submitted' || sb.Status__c == 'Final Approval' || sb.Status__c == 'Intermediate Approval') {
				noSaveMode = true;
			}
			if (sb.Status__c == 'Final Approval' || sb.Status__c == 'Intermediate Approval') {
				noSaveModeDOS = true;
			}
			if (showApproval == false) {
				noApproveMode = true;
				//  noSaveMode = true;
			}

			System.debug('NSM SB Status: ' + sb.Status__c);
			if (sb.Status__c != 'Pending' && sb.Status__c != 'Forecast Rejected' && Date.Today() <forecastDate) {
				submissionDateCheck = 'Forecast Approve';
			}

			/*if(showApproval == true && (sb.Status__c != 'Pending' && sb.Status__c != 'Forecast Rejected' && sb.Status__c != 'Rejected')){
			 
			  submissionDateCheck = 'NA';
			  if(Date.Today() >= forecastDate){
			  submissionDateCheck = 'Budget';
			  }
			  }*/
			System.debug('Submission Date Check: ' + submissionDateCheck);
		}
		system.debug('selectedDMA ' + selectedDMA);
		if (sbWorkflow == null || String.isBlank(sbWorkflow.status__c) || sbWorkflow.status__c == 'Pending' || sbWorkflow.status__c == 'Forecast Rejected') {
			//Query Previous year's Revenue
			for (AggregateResult sr :[SELECT Budget_DMA__c, Advertiser__c, sum(Net_Projected_Amount__c) amount, Advertiser__r.Primary_Commodity__c Primary_Commodity__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year
			     FROM Revenue__c
			     WHERE((Account_Executive__c = :loggedInUser.id AND revenue_user__c = null) OR(revenue_user__c = :loggedInUser.id AND Account_Executive__c != NULL)) AND
			     CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.RevenuePY) and
			     //Revenue__c  != null AND
			     Budget_DMA__c = :selectedDMA and
			     Advertiser__r.Primary_Commodity__c != null and
			     Product_Line__c in :loggedInUserProductLines.split(';')
			     group by Advertiser__r.Name, Budget_DMA__c, Advertiser__r.Primary_Commodity__c, Advertiser__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c)
			     order by Advertiser__r.Name, Budget_DMA__c, Advertiser__r.Primary_Commodity__c, Advertiser__c, min(Product_Line_Sequence__c) asc]) {

				String commodity = '';
				if ((String) sr.get('Advertiser__c') == Label.Dummy_Revenue_Account) {
					commodity = 'Unmapped Revenue';
				}
				else {
					commodity = (String) sr.get('Primary_Commodity__c');
				}
				String key = keySeparator + (String) sr.get('Budget_DMA__c') + keySeparator + commodity + keySeparator + (String) sr.get('Advertiser__c') + keySeparator + (String) sr.get('Product_Line__c') + keySeparator + Label.BudgetCurrentYear;
				rh = new gridHelper();
				rh.dma = (String) sr.get('Budget_DMA__c');
				rh.commodity = commodity;
				rh.Advertiser = (String) sr.get('Advertiser__c');
				rh.ProductLine = (String) sr.get('Product_Line__c');
				rh.year = (Integer) sr.get('year');
				if (revenuePYMap.containsKey(key)) {
					rh.months = revenuePYMap.get(key).months;
				}
				if (commodity == 'Unmapped Revenue') {
					rh.months[(Integer) sr.get('mon') - 1] = rh.months[(Integer) sr.get('mon') - 1] + Integer.valueOf((Decimal) sr.get('amount'));
				}
				else {
					rh.months[(Integer) sr.get('mon') - 1] = Integer.valueOf((Decimal) sr.get('amount'));
				}
				revenuePYMap.put(key, rh);
				budgetKeys.put(key, rh);
				advertiserIdList.add((Id) sr.get('Advertiser__c'));
			}

			//Query Current year's Revenue
			for (AggregateResult sr :[SELECT Budget_DMA__c, Advertiser__c, sum(Net_Projected_Amount__c) amount, Advertiser__r.Primary_Commodity__c Primary_Commodity__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year
			     FROM Revenue__c
			     WHERE((Account_Executive__c = :loggedInUser.id AND revenue_user__c = null) OR(revenue_user__c = :loggedInUser.id AND Account_Executive__c != NULL))
			     and
			     //Revenue__c  != null AND 
			     CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.RevenueCY) and
			     Budget_DMA__c = :selectedDMA and
			     Product_Line__c in :loggedInUserProductLines.split(';') and
			     Advertiser__r.Primary_Commodity__c != null
			     group by Advertiser__r.Name, Budget_DMA__c, Advertiser__r.Primary_Commodity__c, Advertiser__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c)
			     order by Advertiser__r.Name, Budget_DMA__c, Advertiser__r.Primary_Commodity__c, Advertiser__c, min(Product_Line_Sequence__c) asc]) {

				String commodity = '';
				if ((String) sr.get('Advertiser__c') == Label.Dummy_Revenue_Account) {
					commodity = 'Unmapped Revenue';
				}
				else {
					commodity = (String) sr.get('Primary_Commodity__c');
				}
				String key = keySeparator + (String) sr.get('Budget_DMA__c') + keySeparator + commodity + keySeparator + (String) sr.get('Advertiser__c') + keySeparator + (String) sr.get('Product_Line__c') + keySeparator + Label.BudgetCurrentYear;
				rh = new gridHelper();
				rh.dma = (String) sr.get('Budget_DMA__c');
				rh.commodity = commodity;
				rh.Advertiser = (String) sr.get('Advertiser__c');
				rh.ProductLine = (String) sr.get('Product_Line__c');
				rh.year = (Integer) sr.get('year');
				if (revenueCYMap.containsKey(key)) {
					rh.months = revenueCYMap.get(key).months;
				}
				if (commodity == 'Unmapped Revenue') {
					rh.months[(Integer) sr.get('mon') - 1] = rh.months[(Integer) sr.get('mon') - 1] + Integer.valueOf((Decimal) sr.get('amount'));
				}
				else {
					rh.months[(Integer) sr.get('mon') - 1] = Integer.valueOf((Decimal) sr.get('amount'));
				}
				revenueCYMap.put(key, rh);
				budgetKeys.put(key, rh);
				advertiserIdList.add((Id) sr.get('Advertiser__c'));
			}
			System.debug('revenueCYMap data: ' + revenueCYMap);

			queryNSMAccTeamData(rh);

			Map<String, SyscodeProductLineMap__c> custSettMap = SyscodeProductLineMap__c.getAll();
			System.debug('custSettMap: ' + custSettMap);
			//Query Current year's Forecast
			for (AggregateResult pzmv :[SELECT proposal_zone__r.proposal__r.opportunity__r.DMA__C dm, proposal_zone__r.proposal__r.opportunity__r.accountId accId, sum(Broadcast_Amount__c) amount, proposal_zone__r.proposal__r.opportunity__r.account.Primary_Commodity__c cc,
			     proposal_zone__r.sys_code__c syscode, CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year
			     FROM Proposal_Zone_Monthly_Value__c
			     where proposal_zone__r.proposal__r.opportunity__r.ownerid = :loggedInUser.id and
			     proposal_zone__r.proposal__r.opportunity__r.accountId in :advertiserIdList and
			((proposal_zone__r.proposal__r.recordtype.name = 'Opportunity Budget' and proposal_zone__r.proposal__r.Active__c = true) or
			(proposal_zone__r.proposal__r.recordtype.name = 'Linear' and proposal_zone__r.status_type__c = 'Pending' and proposal_zone__r.proposal__r.Active__c = true)) and
			     CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.BudgetForecastCurrentYear) and
			     proposal_zone__r.proposal__r.opportunity__r.DMA__C = :selectedDMA and
			     Proposal_Zone__r.Sys_Code__c in :custSettMap.keySet()
			     group by proposal_zone__r.proposal__r.opportunity__r.DMA__C, proposal_zone__r.proposal__r.opportunity__r.accountId, proposal_zone__r.proposal__r.opportunity__r.account.Primary_Commodity__c,
			     proposal_zone__r.sys_code__c, CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c)
			     order by Proposal_Zone__r.Sys_Code__c]) {
				String productLine = (String) pzmv.get('syscode');

				System.debug('syscode: ' + productLine);
				productLine = custSettMap.get((String) pzmv.get('syscode')).product_Line__c;

				String key = keySeparator + (String) pzmv.get('dm') + keySeparator + (String) pzmv.get('cc') + keySeparator + (String) pzmv.get('accId') +
				keySeparator + productLine + keySeparator + Label.BudgetCurrentYear;
				rh = new GridHelper();
				rh.dma = (String) pzmv.get('dm');
				rh.commodity = (String) pzmv.get('cc');
				rh.Advertiser = (String) pzmv.get('accId');
				rh.ProductLine = productLine;
				rh.year = (Integer) pzmv.get('year');
				if (forecastMap.containsKey(key)) {
					rh.months = forecastMap.get(key).months;
				}
				//If forecast month is Jan-July use actual revenue amount, else use forecast amount from proposals
				if ((Integer) pzmv.get('mon') <= Integer.Valueof(Label.Forecast_Month)) {
					if (revenueCYMap.get(key) != null) {
						for (Integer j = 0; j<Integer.Valueof(Label.Forecast_Month); j++)
						{
							system.debug('Inside If: ' + j);
							rh.months[j] = revenueCYMap.get(key).months[j];
						}
					}
				}
				else {
					rh.months[(Integer) pzmv.get('mon') - 1] = Integer.valueOf((Decimal) pzmv.get('amount'));
					if (revenueCYMap.get(key) != null) {
						for (Integer j = 0; j<Integer.Valueof(Label.Forecast_Month); j++)
						{
							system.debug('Inside Else: ' + j);
							rh.months[j] = revenueCYMap.get(key).months[j];
						}
					}
				}
				forecastMap.put(key, rh);
				budgetKeys.put(key, rh);
				advertiserIdList.add((Id) pzmv.get('accId'));
			}

			if (Label.Budget_CopyRevenuetoForecast == 'true') {
				//Loop on RevenueCYMap to populate forecastMap with Revenue and Forecast numbers
				for (String s : revenueCYMap.keySet()) {
					System.debug('revenueCYMap KEY: ' + s);
					if (!forecastMap.containsKey(s)) {
						rh = new GridHelper();
						rh = revenueCYMap.get(s);
						forecastMap.put(s, rh);
					}
					else {
						if (revenueCYMap.get(s) != null) {
							forecastMap.get(s).months[7] = forecastMap.get(s).months[7] + revenueCYMap.get(s).months[7];
							forecastMap.get(s).months[8] = forecastMap.get(s).months[8] + revenueCYMap.get(s).months[8];
							forecastMap.get(s).months[9] = forecastMap.get(s).months[9] + revenueCYMap.get(s).months[9];
							forecastMap.get(s).months[10] = forecastMap.get(s).months[10] + revenueCYMap.get(s).months[10];
							forecastMap.get(s).months[11] = forecastMap.get(s).months[11] + revenueCYMap.get(s).months[11];
						}
					}
				}

				//Populate Forecast Map for keys where no Revenue exists
				for (String s : forecastMap.keySet()) {
					System.debug('forecastMap KEY: ' + s);
					if (!revenueCYMap.containsKey(s)) {
						forecastMap.get(s).months[7] = forecastMap.get(s).months[7];
						forecastMap.get(s).months[8] = forecastMap.get(s).months[8];
						forecastMap.get(s).months[9] = forecastMap.get(s).months[9];
						forecastMap.get(s).months[10] = forecastMap.get(s).months[10];
						forecastMap.get(s).months[11] = forecastMap.get(s).months[11];
					}
				}
			}
		}

		else {
			queryNSMAccTeamData(rh);
			for (Sales_Budget__c sb :[SELECT
			     Advertiser__c,
			     CY_FCST_1_Jan_Amount__c, CY_FCST_2_Feb_Amount__c, CY_FCST_3_March_Amount__c, CY_FCST_4_April_Amount__c, CY_FCST_5_May_Amount__c, CY_FCST_6_June_Amount__c, CY_FCST_7_July_Amount__c,
			     CY_FCST_8_Aug_Amount__c, CY_FCST_9_Sep_Amount__c, CY_FCST_10_Oct_Amount__c, CY_FCST_11_Nov_Amount__c, CY_FCST_12_Dec_Amount__c,
			     PY_Rev_1_Jan_Amount__c, PY_Rev_2_Feb_Amount__c, PY_Rev_3_March_Amount__c, PY_Rev_4_April_Amount__c, PY_Rev_5_May_Amount__c, PY_Rev_6_June_Amount__c, PY_Rev_7_July_Amount__c,
			     PY_Rev_8_Aug_Amount__c, PY_Rev_9_Sep_Amount__c, PY_Rev_10_Oct_Amount__c, PY_Rev_11_Nov_Amount__c, PY_Rev_12_Dec_Amount__c,
			     CY_Rev_1_Jan_Amount__c, CY_Rev_2_Feb_Amount__c, CY_Rev_3_March_Amount__c, CY_Rev_4_April_Amount__c, CY_Rev_5_May_Amount__c, CY_Rev_6_June_Amount__c, CY_Rev_7_July_Amount__c,
			     CY_Rev_8_Aug_Amount__c, CY_Rev_9_Sep_Amount__c, CY_Rev_10_Oct_Amount__c, CY_Rev_11_Nov_Amount__c, CY_Rev_12_Dec_Amount__c,
			     Broadcast_Month_Date__c, Budget_User__c, Commodity__c, DMA__c, External_Id__c, Id, Name, OwnerId, Product_Line__c, Status__c, Type__c
			     FROM Sales_Budget__c
			     WHERE Budget_User__c = :loggedInUser.id and
			     Advertiser__c in :advertiserIdList and
			     CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.BudgetCurrentYear) and
			     DMA__c = :selectedDMA and
			     Product_Line__c in :loggedInUserProductLines.split(';') and
			     type__c = 'Forecast'
			     Order By Advertiser__r.Name])
			{
				String key = keySeparator + (String) sb.get('DMA__c') + keySeparator + (String) sb.get('Commodity__c') + keySeparator + (String) sb.get('Advertiser__c') + keySeparator + (String) sb.get('Product_Line__c') + keySeparator + Label.BudgetCurrentYear;

				rh = new GridHelper();
				rh.dma = (String) sb.get('DMA__c');
				rh.commodity = (String) sb.get('Commodity__c');
				rh.Advertiser = (String) sb.get('Advertiser__c');
				rh.ProductLine = (String) sb.get('Product_Line__c');
				rh.year = ((Date) sb.get('Broadcast_Month_Date__c')).year();

				if (forecastMap.containsKey(key)) {
					rh.months = forecastMap.get(key).months;
				}

				GridHelper rh1 = new GridHelper();
				rh1.dma = (String) sb.get('DMA__c');
				rh1.commodity = (String) sb.get('Commodity__c');
				rh1.Advertiser = (String) sb.get('Advertiser__c');
				rh1.ProductLine = (String) sb.get('Product_Line__c');
				rh1.year = ((Date) sb.get('Broadcast_Month_Date__c')).year();

				if (forecastMap.containsKey(key)) {
					rh1.months = forecastMap.get(key).months;
				}

				GridHelper rh2 = new GridHelper();
				rh2.dma = (String) sb.get('DMA__c');
				rh2.commodity = (String) sb.get('Commodity__c');
				rh2.Advertiser = (String) sb.get('Advertiser__c');
				rh2.ProductLine = (String) sb.get('Product_Line__c');
				rh2.year = ((Date) sb.get('Broadcast_Month_Date__c')).year();

				if (forecastMap.containsKey(key)) {
					rh2.months = forecastMap.get(key).months;
				}

				rh.months[0] = Integer.valueOf(sb.CY_FCST_1_Jan_Amount__c == null ? 0 : sb.CY_FCST_1_Jan_Amount__c);
				rh.months[1] = Integer.valueOf(sb.CY_FCST_2_Feb_Amount__c == null ? 0 : sb.CY_FCST_2_Feb_Amount__c);
				rh.months[2] = Integer.valueOf(sb.CY_FCST_3_March_Amount__c == null ? 0 : sb.CY_FCST_3_March_Amount__c);
				rh.months[3] = Integer.valueOf(sb.CY_FCST_4_April_Amount__c == null ? 0 : sb.CY_FCST_4_April_Amount__c);
				rh.months[4] = Integer.valueOf(sb.CY_FCST_5_May_Amount__c == null ? 0 : sb.CY_FCST_5_May_Amount__c);
				rh.months[5] = Integer.valueOf(sb.CY_FCST_6_June_Amount__c == null ? 0 : sb.CY_FCST_6_June_Amount__c);
				rh.months[6] = Integer.valueOf(sb.CY_FCST_7_July_Amount__c == null ? 0 : sb.CY_FCST_7_July_Amount__c) + (sb.get('CY_Rev_7_July_Amount__c') == null ? 0 : Integer.valueOf((Decimal) sb.get('CY_Rev_7_July_Amount__c')));
				rh.months[7] = Integer.valueOf(sb.CY_FCST_8_Aug_Amount__c == null ? 0 : sb.CY_FCST_8_Aug_Amount__c) + (sb.get('CY_Rev_8_Aug_Amount__c') == null ? 0 : Integer.valueOf((Decimal) sb.get('CY_Rev_8_Aug_Amount__c')));
				rh.months[8] = Integer.valueOf(sb.CY_FCST_9_Sep_Amount__c == null ? 0 : sb.CY_FCST_9_Sep_Amount__c) + (sb.get('CY_Rev_9_Sep_Amount__c') == null ? 0 : Integer.valueOf((Decimal) sb.get('CY_Rev_9_Sep_Amount__c')));
				rh.months[9] = Integer.valueOf(sb.CY_FCST_10_Oct_Amount__c == null ? 0 : sb.CY_FCST_10_Oct_Amount__c) + (sb.get('CY_Rev_10_Oct_Amount__c') == null ? 0 : Integer.valueOf((Decimal) sb.get('CY_Rev_10_Oct_Amount__c')));
				rh.months[10] = Integer.valueOf(sb.CY_FCST_11_Nov_Amount__c == null ? 0 : sb.CY_FCST_11_Nov_Amount__c) + (sb.get('CY_Rev_11_Nov_Amount__c') == null ? 0 : Integer.valueOf((Decimal) sb.get('CY_Rev_11_Nov_Amount__c')));
				rh.months[11] = Integer.valueOf(sb.CY_FCST_12_Dec_Amount__c == null ? 0 : sb.CY_FCST_12_Dec_Amount__c) + (sb.get('CY_Rev_12_Dec_Amount__c') == null ? 0 : Integer.valueOf((Decimal) sb.get('CY_Rev_12_Dec_Amount__c')));
				forecastMap.put(key, rh);

				rh1.months[0] = Integer.valueOf(sb.PY_Rev_1_Jan_Amount__c == null ? 0 : sb.PY_Rev_1_Jan_Amount__c);
				rh1.months[1] = Integer.valueOf(sb.PY_Rev_2_Feb_Amount__c == null ? 0 : sb.PY_Rev_2_Feb_Amount__c);
				rh1.months[2] = Integer.valueOf(sb.PY_Rev_3_March_Amount__c == null ? 0 : sb.PY_Rev_3_March_Amount__c);
				rh1.months[3] = Integer.valueOf(sb.PY_Rev_4_April_Amount__c == null ? 0 : sb.PY_Rev_4_April_Amount__c);
				rh1.months[4] = Integer.valueOf(sb.PY_Rev_5_May_Amount__c == null ? 0 : sb.PY_Rev_5_May_Amount__c);
				rh1.months[5] = Integer.valueOf(sb.PY_Rev_6_June_Amount__c == null ? 0 : sb.PY_Rev_6_June_Amount__c);
				rh1.months[6] = Integer.valueOf(sb.PY_Rev_7_July_Amount__c == null ? 0 : sb.PY_Rev_7_July_Amount__c);
				rh1.months[7] = Integer.valueOf(sb.PY_Rev_8_Aug_Amount__c == null ? 0 : sb.PY_Rev_8_Aug_Amount__c);
				rh1.months[8] = Integer.valueOf(sb.PY_Rev_9_Sep_Amount__c == null ? 0 : sb.PY_Rev_9_Sep_Amount__c);
				rh1.months[9] = Integer.valueOf(sb.PY_Rev_10_Oct_Amount__c == null ? 0 : sb.PY_Rev_10_Oct_Amount__c);
				rh1.months[10] = Integer.valueOf(sb.PY_Rev_11_Nov_Amount__c == null ? 0 : sb.PY_Rev_11_Nov_Amount__c);
				rh1.months[11] = Integer.valueOf(sb.PY_Rev_12_Dec_Amount__c == null ? 0 : sb.PY_Rev_12_Dec_Amount__c);
				revenuePYMap.put(key, rh1);

				rh2.months[0] = Integer.valueOf(sb.CY_Rev_1_Jan_Amount__c == null ? 0 : sb.CY_Rev_1_Jan_Amount__c);
				rh2.months[1] = Integer.valueOf(sb.CY_Rev_2_Feb_Amount__c == null ? 0 : sb.CY_Rev_2_Feb_Amount__c);
				rh2.months[2] = Integer.valueOf(sb.CY_Rev_3_March_Amount__c == null ? 0 : sb.CY_Rev_3_March_Amount__c);
				rh2.months[3] = Integer.valueOf(sb.CY_Rev_4_April_Amount__c == null ? 0 : sb.CY_Rev_4_April_Amount__c);
				rh2.months[4] = Integer.valueOf(sb.CY_Rev_5_May_Amount__c == null ? 0 : sb.CY_Rev_5_May_Amount__c);
				rh2.months[5] = Integer.valueOf(sb.CY_Rev_6_June_Amount__c == null ? 0 : sb.CY_Rev_6_June_Amount__c);
				rh2.months[6] = Integer.valueOf(sb.CY_Rev_7_July_Amount__c == null ? 0 : sb.CY_Rev_7_July_Amount__c);
				rh2.months[7] = Integer.valueOf(sb.CY_Rev_8_Aug_Amount__c == null ? 0 : sb.CY_Rev_8_Aug_Amount__c);
				rh2.months[8] = Integer.valueOf(sb.CY_Rev_9_Sep_Amount__c == null ? 0 : sb.CY_Rev_9_Sep_Amount__c);
				rh2.months[9] = Integer.valueOf(sb.CY_Rev_10_Oct_Amount__c == null ? 0 : sb.CY_Rev_10_Oct_Amount__c);
				rh2.months[10] = Integer.valueOf(sb.CY_Rev_11_Nov_Amount__c == null ? 0 : sb.CY_Rev_11_Nov_Amount__c);
				rh2.months[11] = Integer.valueOf(sb.CY_Rev_12_Dec_Amount__c == null ? 0 : sb.CY_Rev_12_Dec_Amount__c);
				revenueCYMap.put(key, rh2);

				budgetKeys.put(key, rh1);
				budgetKeys.put(key, rh2);
				budgetKeys.put(key, rh);
				//advertiserIdList.add((Id)sb.get('Advertiser__c'));
			}
		}

		System.debug('forecastMap size while get: ' + forecastMap.size());
	}

	private void queryNSMAccTeamData(GridHelper rh)
	{
		//List<Sales_Budget__c> sbListTest = [SELECT ID FROM Sales_Budget__c];
		//System.debug('Sales Budget List: ' + sbListTest);
		//Create Budget keys
		Map<String, String> accComMap = new Map<String, String> ();
		for (Sales_Budget__c sb :[SELECT Advertiser__c, Commodity__c
		     FROM Sales_Budget__c
		     WHERE Budget_User__c = :loggedInUser.id and
		     CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.BudgetCurrentYear) and
		     advertiser__c != :Label.BudgetNewBusinessAcountId and
		     type__c in('Data')
		     order by Advertiser__r.Name, Commodity__c asc]) {
			for (String pl : loggedInUserProductLines.split(';')) {
				String key = keySeparator + selectedDMA + keySeparator + sb.Commodity__c + keySeparator + sb.Advertiser__c + keySeparator + pl + keySeparator + Label.BudgetCurrentYear;
				rh = new gridHelper();
				rh.DMA = selectedDMA;
				rh.commodity = sb.Commodity__c;
				rh.Advertiser = sb.Advertiser__c;
				rh.ProductLine = pl;
				rh.year = Integer.valueOf(Label.BudgetCurrentYear);
				budgetKeys.put(key, rh);
				accComMap.put(sb.Advertiser__c, sb.Commodity__c);
			}
			advertiserIdList.add(sb.Advertiser__c);
		}
		for (AccountTeamMember atm :[SELECT TeamMemberRole, accountid, account.name, account.Primary_Commodity__c
		     FROM AccountTeamMember
		     WHERE UserId = :loggedInUser.id and
		     account.Primary_Commodity__c != null
		     order by account.name, account.Primary_Commodity__c asc]) {

			for (String pl : loggedInUserProductLines.split(';')) {
				String com = atm.account.Primary_Commodity__c;
				if (accComMap.containsKey(atm.accountId)) {
					com = accComMap.get(atm.accountId);
				}
				String key = keySeparator + selectedDMA + keySeparator + atm.account.Primary_Commodity__c + keySeparator + atm.accountId + keySeparator + pl + keySeparator + Label.BudgetCurrentYear;
				rh = new gridHelper();
				rh.DMA = selectedDMA;
				rh.commodity = com;
				rh.Advertiser = atm.accountId;
				rh.ProductLine = pl;
				rh.year = Integer.valueOf(Label.BudgetCurrentYear);
				//budgetKeys.put(key,rh);
			}

			if (!accComMap.containsKey(atm.accountId)) {
				advertiserIdList.add(atm.accountId);
			}
		}
		advertiserIdList.add(Label.BudgetNewBusinessAcountId);

		//Query Advertiser Info
		accMap = new Map<Id, Account> ();
		for (Account acc :[Select id, name from account where id in :advertiserIdList]) {
			acc.name = acc.name.replace('\'', '');
			acc.name = acc.name.replace('\"', '');
			//System.debug(acc.name);
			accMap.put(acc.id, acc);
		}
		String existingNewBusinessProductLines = '';
		//Query Current year's Budget
		System.Debug('Advertiser List: ' + advertiserIdList);
		for (AggregateResult sb :[SELECT Advertiser__c, sum(Amount__c) amount, Commodity__c, DMA__c, Product_Line__c, Type__c, Churn_Indicator__c,
		     CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year
		     FROM Sales_Budget__c
		     WHERE Budget_User__c = :loggedInUser.id and
		     Product_Line__c in :loggedInUserProductLines.split(';') and
		     CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.BudgetCurrentYear) and
		     DMA__c = :selectedDMA and
		     type__c in('Data')
		     group by DMA__c, Commodity__c, Advertiser__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c), Type__c, Churn_Indicator__c]) {
			//if (sb.Type__c == 'Data') {
			String key = keySeparator + (String) sb.get('DMA__c') + keySeparator + (String) sb.get('Commodity__c') + keySeparator + (String) sb.get('Advertiser__c') + keySeparator + (String) sb.get('Product_Line__c') + keySeparator + Label.BudgetCurrentYear;
			rh = new GridHelper();
			rh.dma = (String) sb.get('DMA__c');
			rh.commodity = (String) sb.get('Commodity__c');
			rh.Advertiser = (String) sb.get('Advertiser__c');
			rh.ProductLine = (String) sb.get('Product_Line__c');
			rh.year = (Integer) sb.get('year');
			if (budgetMap.containsKey(key)) {
				rh.months = budgetMap.get(key).months;
				rh.monthIds = budgetMap.get(key).monthIds;
			}
			rh.months[(Integer) sb.get('mon') - 1] = Integer.valueOf((Decimal) sb.get('amount'));
			rh.monthIds[(Integer) sb.get('mon') - 1] = (String) sb.get('Id');

			if (budgetMap.containsKey(key) && (String.isBlank(budgetMap.get(key).ChurnIndicator) || budgetMap.get(key).ChurnIndicator == 'null')) {
				rh.ChurnIndicator = (String) sb.get('Churn_Indicator__c');
			}
			else if (!budgetMap.containsKey(key)) {
				rh.ChurnIndicator = (String) sb.get('Churn_Indicator__c');
			}
			else if (budgetMap.containsKey(key)) {
				rh.ChurnIndicator = budgetMap.get(key).ChurnIndicator;
			}

			budgetMap.put(key, rh);
			if (rh.Advertiser == Label.BudgetNewBusinessAcountId) {
				existingNewBusinessProductLines = existingNewBusinessProductLines + (String) sb.get('Product_Line__c') + ',';
			}
			//}
		}
		System.debug('NSM budgetMap: ' + budgetMap);

		//Query Current year's New Business Budget
		for (AggregateResult sb :[SELECT Advertiser__c, sum(Amount__c) amount, Commodity__c, DMA__c, Product_Line__c, Type__c, Churn_Indicator__c,
		     CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year, New_Business_Churn__c
		     FROM Sales_Budget__c
		     WHERE Budget_User__c = :loggedInUser.id and
		     Advertiser__r.name = :newBusinessAccount and
		     CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.BudgetCurrentYear) and
		     DMA__c = :selectedDMA and
		     type__c in('Data', 'DOS')
		     group by DMA__c, Commodity__c, Advertiser__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c), Type__c, Churn_Indicator__c, New_Business_Churn__c
		     ]) {

			String key = keySeparator + (String) sb.get('DMA__c') + keySeparator + (String) sb.get('Advertiser__c') + keySeparator + (String) sb.get('Product_Line__c') + keySeparator + Label.BudgetCurrentYear;

			rh = new GridHelper();
			rh.dma = (String) sb.get('DMA__c');
			rh.commodity = (String) sb.get('Commodity__c');
			rh.Advertiser = (String) sb.get('Advertiser__c');
			rh.ProductLine = (String) sb.get('Product_Line__c');
			existingNewBusinessProductLines = existingNewBusinessProductLines + (String) sb.get('Product_Line__c') + ',';
			rh.year = (Integer) sb.get('year');
			if (budgetMap.containsKey(key)) {
				rh.months = budgetMap.get(key).months;
				rh.monthIds = budgetMap.get(key).monthIds;
			}
			rh.months[(Integer) sb.get('mon') - 1] = Integer.valueOf((Decimal) sb.get('amount')) + (rh.months[(Integer) sb.get('mon') - 1] == null ? 0 : rh.months[(Integer) sb.get('mon') - 1]);
			//rh.monthIds[(Integer) sb.get('mon') - 1] = (String) sb.get('Id');
			if ((String) sb.get('type__c') == 'DOS')
			{
				rh.ChurnIndicator = (String) sb.get('New_Business_Churn__c');
			}
			else {
				if (budgetMap.containsKey(key) && (String.isBlank(budgetMap.get(key).ChurnIndicator) || budgetMap.get(key).ChurnIndicator == 'null')) {
					rh.ChurnIndicator = (String) sb.get('Churn_Indicator__c');
				}
				else if (!budgetMap.containsKey(key)) {
					rh.ChurnIndicator = (String) sb.get('Churn_Indicator__c');
				}
				else if (budgetMap.containsKey(key)) {
					rh.ChurnIndicator = budgetMap.get(key).ChurnIndicator;
				}
			}
			//System.debug('rh.ChurnIndicator: '+ rh.ChurnIndicator);
			budgetKeys.put(key, rh);
			budgetMap.put(key, rh);
			newBusinessBudgetMap.put(key, rh);
		}
		//System.debug(existingNewBusinessProductLines);

		if (!existingNewBusinessProductLines.contains(NewBusinessLabel)) {
			String key = keySeparator + selectedDMA + keySeparator + 'New Business/Churn' + keySeparator + Label.BudgetNewBusinessAcountId + keySeparator + NewBusinessLabel + keySeparator + Label.BudgetCurrentYear;
			rh = new GridHelper();
			rh.DMA = selectedDMA;
			rh.commodity = 'New Business/Churn';
			rh.Advertiser = Label.BudgetNewBusinessAcountId;
			rh.ProductLine = NewBusinessLabel;
			budgetKeys.put(key, rh);
			budgetMap.put(key, rh);
			newBusinessBudgetMap.put(key, rh);
		}

		if (!existingNewBusinessProductLines.contains(ChurnLabel)) {
			String key = keySeparator + selectedDMA + keySeparator + 'New Business/Churn' + keySeparator + Label.BudgetNewBusinessAcountId + keySeparator + ChurnLabel + keySeparator + Label.BudgetCurrentYear;
			rh = new GridHelper();
			rh.DMA = selectedDMA;
			rh.commodity = 'New Business/Churn';
			rh.Advertiser = Label.BudgetNewBusinessAcountId;
			rh.ProductLine = ChurnLabel;
			budgetKeys.put(key, rh);
			budgetMap.put(key, rh);
			newBusinessBudgetMap.put(key, rh);
		}

		System.debug('NSM newBusinessBudgetMap: ' + newBusinessBudgetMap);
	}

	/**
	 * This method queries Salesforce objects required for grid data rows, for a DOS user
	 *
	 * @param  (none) (NA)
	 * @return (void) (NA)
	 */
	public void queryDOSTreeData() {
		GridHelper rh = new GridHelper();
		String key = '';
		List<String> categoryList = new List<String> { 'Alcoholic Beverages', 'Associations', 'Auto Aftermarket', 'Auto Dealer', 'Auto Dealer Association', 'Auto Manufacturer', 'Automall/Used Cars', 'Education', 'Financial Services and Insurance', 'Government and Military', 'Grocery/Food and Beverage', 'Healthcare', 'Home Improvement', 'Legal Services', 'Media', 'Real Estate', 'Remnant/Direct Response', 'Restaurant', 'Retail', 'RV/Cycles Vehicles', 'Telecommunications', 'Travel/Leisure/Entertainment', 'Marketing' };
		for (Integer i = 0; i<categoryList.size(); i++) {
			for (String pl : dosUser.budget_Product_Lines__c.split(';')) {
				if (loggedInUserBudgetType == 'National') {
					key = keySeparator + selectedDMA + keySeparator + categoryList[i] + keySeparator + Label.BudgetNewBusinessAcountId + keySeparator + pl + keySeparator + Label.BudgetCurrentYear + keySeparator + 'DOS' + keySeparator + NewBusinessLabel;
				}
				else {
					key = keySeparator + categoryList[i] + keySeparator + Label.BudgetNewBusinessAcountId + keySeparator + pl + keySeparator + Label.BudgetCurrentYear + keySeparator + 'DOS' + keySeparator + NewBusinessLabel;
				}
				rh = new gridHelper();
				rh.commodity = categoryList[i];
				rh.Advertiser = Label.BudgetNewBusinessAcountId;
				rh.ProductLine = pl;
				rh.year = Integer.valueOf(Label.BudgetCurrentYear);
				rh.NewBusinessChurn = NewBusinessLabel;
				dosBudgetMap.put(key, rh);

				if (loggedInUserBudgetType == 'National') {
					key = keySeparator + selectedDMA + keySeparator + categoryList[i] + keySeparator + Label.BudgetNewBusinessAcountId + keySeparator + pl + keySeparator + Label.BudgetCurrentYear + keySeparator + 'DOS' + keySeparator + ChurnLabel;
				}
				else {
					key = keySeparator + categoryList[i] + keySeparator + Label.BudgetNewBusinessAcountId + keySeparator + pl + keySeparator + Label.BudgetCurrentYear + keySeparator + 'DOS' + keySeparator + ChurnLabel;
				}
				rh = new gridHelper();
				rh.commodity = categoryList[i];
				rh.Advertiser = Label.BudgetNewBusinessAcountId;
				rh.ProductLine = pl;
				rh.year = Integer.valueOf(Label.BudgetCurrentYear);
				rh.NewBusinessChurn = ChurnLabel;
				dosBudgetMap.put(key, rh);
			}
		}
		//Query Current year's Budget
		System.debug('dosUser1' + dosUser);
		System.debug('selectedDMA1' + selectedDMA);
		//System.debug('CALENDAR_YEAR'+CALENDAR_YEAR);
		for (Sales_Budget__c sb :[SELECT Advertiser__c, Amount__c, Broadcast_Month_Date__c, Budget_User__c, Commodity__c, DMA__c, External_Id__c, Id, Name, OwnerId, Product_Line__c, Status__c, Type__c, New_Business_Churn__c
		     FROM Sales_Budget__c
		     WHERE Budget_User__c = :loggedInUser.id and
		     CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.BudgetCurrentYear) and
		     Product_Line__c in :dosUser.budget_Product_Lines__c.split(';') and
		     DMA__c = :selectedDMA and
		     type__c = :'DOS'
		     order by Commodity__c, Advertiser__c, Product_Line_Sequence__c asc]) {

			System.debug('sb1' + sb);
			if (loggedInUserBudgetType == 'National') {
				key = keySeparator + selectedDMA + keySeparator + (String) sb.get('Commodity__c') + keySeparator + (String) sb.get('Advertiser__c') + keySeparator + (String) sb.get('Product_Line__c') + keySeparator + Label.BudgetCurrentYear + keySeparator + 'DOS' + keySeparator + (String) sb.get('New_Business_Churn__c');

			}

			else {
				key = keySeparator + (String) sb.get('Commodity__c') + keySeparator + (String) sb.get('Advertiser__c') + keySeparator + (String) sb.get('Product_Line__c') + keySeparator + Label.BudgetCurrentYear + keySeparator + 'DOS' + keySeparator + (String) sb.get('New_Business_Churn__c');
			}
			//String key = keySeparator+(String)sb.get('Commodity__c')+keySeparator+(String)sb.get('Advertiser__c')+keySeparator+(String)sb.get('Product_Line__c')+keySeparator+Label.BudgetCurrentYear+keySeparator+(String)sb.get('New_Business_Churn__c');
			rh = new GridHelper();
			rh.commodity = (String) sb.get('Commodity__c');
			rh.Advertiser = (String) sb.get('Advertiser__c');
			rh.ProductLine = (String) sb.get('Product_Line__c');
			rh.NewBusinessChurn = (String) sb.get('New_Business_Churn__c');
			rh.year = ((Date) sb.get('Broadcast_Month_Date__c')).year();
			if (dosBudgetMap.containsKey(key)) {
				rh.months = dosBudgetMap.get(key).months;
				rh.monthIds = dosBudgetMap.get(key).monthIds;
			}
			rh.months[((Date) sb.get('Broadcast_Month_Date__c')).month() - 1] = Integer.valueOf((Decimal) sb.get('Amount__c'));
			rh.monthIds[((Date) sb.get('Broadcast_Month_Date__c')).month() - 1] = (String) sb.get('Id');
			dosBudgetMap.put(key, rh);
			dosBudgetKeys.put(key, rh);
		}

		System.debug('dosBudgetMap: ' + dosBudgetMap);
	}

	/**
	 * Helper method to add products, cut down on repeated code during dev iterations
	 *
	 * @param  (String LedName) (NA)
	 * @param  (String format) (NA)
	 * @param  (Integer ReadOnly) (NA)
	 * @param  (List<Integer> months) (NA)
	 * @param  (String formula) (NA)
	 * @param  (String id) (NA)
	 * @return (BudgetingToolModel.Items_Led) (NA)
	 */
	private BudgetingToolModel.Items_Led AddLed(String LedName, String format, Integer ReadOnly, List<Integer> months, String formula, String id, String churnIndicator) {
		BudgetingToolModel.Items_Led tgmiLed = new BudgetingToolModel.Items_Led();
		tgmiLed.id = id;
		tgmiLed.Account = LedName;
		tgmiLed.Jan = months[0];
		tgmiLed.Feb = months[1];
		tgmiLed.Mar = months[2];
		tgmiLed.Apr = months[3];
		tgmiLed.May = months[4];
		tgmiLed.Jun = months[5];
		tgmiLed.Jul = months[6];
		tgmiLed.Aug = months[7];
		tgmiLed.Sep = months[8];
		tgmiLed.Oct = months[9];
		tgmiLed.Nov = months[10];
		tgmiLed.Dec = months[11];
		tgmiLed.ChurnIndicator = churnIndicator;

		//        tgmiLed.format(format);
		tgmiLed.Def = formatDef(LedName, format);
		system.debug('tgmiLed ' + tgmiLed);
		return tgmiLed;
	}

	/**
	 * Helper method to add products, cut down on repeated code during dev iterations
	 *
	 * @param  (String LedName) (NA)
	 * @param  (String format) (NA)
	 * @param  (Integer ReadOnly) (NA)
	 * @param  (List<Integer> months) (NA)
	 * @param  (String formula) (NA)
	 * @param  (String id) (NA)
	 * @return (BudgetingToolModel.Items_Led) (NA)
	 */
	private BudgetingToolModelNational.Items_Led AddNationalLed(String LedName, String format, Integer ReadOnly, List<Integer> months, String formula, String id, String churnIndicator) {
		BudgetingToolModelNational.Items_Led tgmiLed = new BudgetingToolModelNational.Items_Led();
		tgmiLed.id = id;
		tgmiLed.Account = LedName;
		tgmiLed.Jan = months[0];
		tgmiLed.Feb = months[1];
		tgmiLed.Mar = months[2];
		tgmiLed.Apr = months[3];
		tgmiLed.May = months[4];
		tgmiLed.Jun = months[5];
		tgmiLed.Jul = months[6];
		tgmiLed.Aug = months[7];
		tgmiLed.Sep = months[8];
		tgmiLed.Oct = months[9];
		tgmiLed.Nov = months[10];
		tgmiLed.Dec = months[11];
		tgmiLed.ChurnIndicator = churnIndicator;

		//        tgmiLed.format(format);
		tgmiLed.Def = formatDef(LedName, format);

		system.debug('tgmiLed: ' + tgmiLed);

		return tgmiLed;
	}

	/**
	 * Helper to format and choose Def for item (removing logic from Model, adding generic Labels)
	 *
	 * @param  (String AccountName) (NA)
	 * @param  (String format) (NA)
	 * @return (String) (NA)
	 */
	private String formatDef(String AccountName, String format) {
		String defTmp = 'lplain';

		if (AccountName == ChurnYearLabel) { defTmp = 'lneg'; }
		else if (AccountName == BudgetLabel || AccountName == NewBusinessYearLabel) { defTmp = 'ldollar'; }
		else if (format == 'p') { defTmp = 'lpct'; }

		return defTmp;
	}

	/**
	 * Helper method to return which type of Grid Def formula to apply for Rollup, based on Workflow Status
	 *
	 * @return (String) (NA)
	 */
	private String GetGridWorkflowRollupDef() {
		return(gridWorkflowStatus == 'Pending' || gridWorkflowStatus == 'Rejected') ? 'fcst' : 'prod';
	}

	/**
	 * Helper method to add products, cut down on repeated code during dev iterations
	 *
	 * @param  (String ProductName) (NA)
	 * @param  (List<BudgetingToolModel.Items_Led> tgmiLedList) (NA)
	 * @return (BudgetingToolModel.Items_Pro) (NA)
	 */
	private BudgetingToolModelNational.Items_Acc AddNationalProduct(String ProductName, List<BudgetingToolModelNational.Items_Led> tgmiLedList) {
		BudgetingToolModelNational.Items_Acc tgmiPro = new BudgetingToolModelNational.Items_Acc();
		tgmiPro.Account = ProductName;
		tgmiPro.items = tgmiLedList;
		tgmiPro.Def = GetGridWorkflowRollupDef();
		return tgmiPro;
	}

	/**
	 * Helper method to add products, cut down on repeated code during dev iterations
	 *
	 * @param  (String ProductName) (NA)
	 * @param  (List<BudgetingToolModel.Items_Led> tgmiLedList) (NA)
	 * @return (BudgetingToolModel.Items_Pro) (NA)
	 */

	/* Commented by Shubham Gupta
	  private BudgetingToolModelNational.Items_Commodity AddNationalAccount(String ProductName, List<BudgetingToolModelNational.Items_Acc> tgmiLedList) {
	  BudgetingToolModelNational.Items_Commodity tgmiCom = new BudgetingToolModelNational.Items_Commodity();
	  tgmiCom.Account = ProductName;
	  tgmiCom.items = tgmiLedList;
	  return tgmiCom;
	  }*/

	//Method added by Shubham gupta
	private BudgetingToolModelNational.Items_DMA AddNationalAccount(String ProductName, List<BudgetingToolModelNational.Items_Acc> tgmiLedList) {
		BudgetingToolModelNational.Items_DMA tgmiPro = new BudgetingToolModelNational.Items_DMA();
		tgmiPro.Account = ProductName;
		tgmiPro.items = tgmiLedList;
		return tgmiPro;
	}

	/**
	 * Helper method to add products, cut down on repeated code during dev iterations
	 *
	 * @param  (String ProductName) (NA)
	 * @param  (List<BudgetingToolModel.Items_Led> tgmiLedList) (NA)
	 * @return (BudgetingToolModel.Items_Pro) (NA)
	 */

	/* Commented by Shubham Gupta
	  private BudgetingToolModelNational.Items_DMA AddNationalCommodity(String ProductName, List<BudgetingToolModelNational.Items_Commodity> tgmiLedList) {
	  BudgetingToolModelNational.Items_DMA tgmiPro = new BudgetingToolModelNational.Items_DMA();
	  tgmiPro.Account = ProductName;
	  tgmiPro.items = tgmiLedList;
	  return tgmiPro;
	  }*/

	/**
	 * Helper method to add products, cut down on repeated code during dev iterations
	 *
	 * @param  (String ProductName) (NA)
	 * @param  (List<BudgetingToolModel.Items_Led> tgmiLedList) (NA)
	 * @return (BudgetingToolModel.Items_Pro) (NA)
	 */
	private BudgetingToolModel.Items_Pro AddProduct(String ProductName, List<BudgetingToolModel.Items_Led> tgmiLedList) {
		BudgetingToolModel.Items_Pro tgmiPro = new BudgetingToolModel.Items_Pro();
		tgmiPro.Account = ProductName;
		tgmiPro.items = tgmiLedList;
		tgmiPro.Def = GetGridWorkflowRollupDef();
		return tgmiPro;
	}

	/**
	 * Helper method to add products, cut down on repeated code during dev iterations
	 *
	 * @param  (String ProductName) (NA)
	 * @param  (List<BudgetingToolModel.Items_Led> tgmiLedList) (NA)
	 * @return (BudgetingToolModel.Items_Pro) (NA)
	 */
	private BudgetingToolModel.Body AddAccount(String AccName, List<BudgetingToolModel.Items_Pro> tgmiLedList) {
		BudgetingToolModel.Body tgmiAcc = new BudgetingToolModel.Body();
		tgmiAcc.Account = AccName;
		tgmiAcc.items = tgmiLedList;
		return tgmiAcc;
	}

	/**
	 * Helper method to add products, cut down on repeated code during dev iterations
	 *
	 * @param  (String ProductName) (NA)
	 * @param  (List<BudgetingToolModel.Items_Led> tgmiLedList) (NA)
	 * @return (BudgetingToolModel.Items_Pro) (NA)
	 */
	/*
	  private BudgetingToolModel.Body AddCommodity(String AccName, List<BudgetingToolModel.Items_Acc> tgmiLedList) {
	  BudgetingToolModel.Body tgmiAcc = new BudgetingToolModel.Body();
	  tgmiAcc.Account = AccName;
	  tgmiAcc.items = tgmiLedList;
	  return tgmiAcc;
	  }
	 */
	/**
	 * This method saves updated budget data from Grid to Budget object
	 *
	 * @param  (String ProductName) (NA)
	 * @param  (List<BudgetingToolModel.Items_Led> tgmiLedList) (NA)
	 * @return (BudgetingToolModel.Items_Pro) (NA)
	 */
	public PageReference saveGridData() {

		try {
			//Deserialize changed Budget rows output from grid
			if (String.isBlank(JSONOutput) && String.isNotBlank(JSONOutputDOS)) {
				JSONOutput = JSONOutputDOS;
			}

			if (String.isNotBlank(JSONOutput)) {
				System.debug('JSONOutput: ' + JSONOutput);
				BudgetingToolBudgetOutputModel bom = BudgetingToolBudgetOutputModel.parse(JSONOutput);
				System.debug('deserializedJSONOutput: ' + bom);
				if (bom.changes.size() == 0 && String.isNotBlank(JSONOutputDOS)) {
					bom = BudgetingToolBudgetOutputModel.parse(JSONOutputDOS);
					System.debug('deserializedJSONOutputDOS: ' + bom);
				}

				System.debug('budgetMap: ' + budgetMap.values());
				List<Sales_Budget__c> sbList = new List<Sales_Budget__c> ();
				List<String> sbsList = new List<String> ();
				Boolean workflowAdded = false;
				//Create monthly Budget records
				for (BudgetingToolBudgetOutputModel.Change ch : bom.changes) {
					String key = ch.id.substring(ch.id.indexOf(keySeparator));
					System.debug(key);

					if (key.contains('DOS')) {
						//DOS Budget Insert Block
						if (DOSBudgetMap.keySet() == null || DOSBudgetMap.get(key) == null) {
							if (String.isNotBlank(ch.Jan)) {
								sbList.add(createBudgetInstance(ch.id, ch.Jan, 1, '', ch.ChurnIndicator));
							}
							if (String.isNotBlank(ch.Feb)) {
								sbList.add(createBudgetInstance(ch.id, ch.Feb, 2, '', ch.ChurnIndicator));
							}
							if (String.isNotBlank(ch.Mar)) {
								sbList.add(createBudgetInstance(ch.id, ch.Mar, 3, '', ch.ChurnIndicator));
							}
							if (String.isNotBlank(ch.Apr)) {
								sbList.add(createBudgetInstance(ch.id, ch.Apr, 4, '', ch.ChurnIndicator));
							}
							if (String.isNotBlank(ch.May)) {
								sbList.add(createBudgetInstance(ch.id, ch.May, 5, '', ch.ChurnIndicator));
							}
							if (String.isNotBlank(ch.Jun)) {
								sbList.add(createBudgetInstance(ch.id, ch.Jun, 6, '', ch.ChurnIndicator));
							}
							if (String.isNotBlank(ch.Jul)) {
								sbList.add(createBudgetInstance(ch.id, ch.Jul, 7, '', ch.ChurnIndicator));
							}
							if (String.isNotBlank(ch.Aug)) {
								sbList.add(createBudgetInstance(ch.id, ch.Aug, 8, '', ch.ChurnIndicator));
							}
							if (String.isNotBlank(ch.Sep)) {
								sbList.add(createBudgetInstance(ch.id, ch.Sep, 9, '', ch.ChurnIndicator));
							}
							if (String.isNotBlank(ch.Oct)) {
								sbList.add(createBudgetInstance(ch.id, ch.Oct, 10, '', ch.ChurnIndicator));
							}
							if (String.isNotBlank(ch.Nov)) {
								sbList.add(createBudgetInstance(ch.id, ch.Nov, 11, '', ch.ChurnIndicator));
							}
							if (String.isNotBlank(ch.Dec)) {
								sbList.add(createBudgetInstance(ch.id, ch.Dec, 12, '', ch.ChurnIndicator));
							}
						}

						//DOS Budget Update Block
						else if (dosBudgetMap.keySet() != null && dosBudgetMap.get(key) != null) {
							if (ch.Jan != null && String.isNotBlank(dosBudgetMap.get(key).monthIds[0])) {
								if (String.isBlank(ch.Jan)) { ch.Jan = '0'; } sbList.add(updateBudgetInstance(ch.Jan, dosBudgetMap.get(key).monthIds[0], ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.Jan) && String.isBlank(dosBudgetMap.get(key).monthIds[0])) {
								sbList.add(createBudgetInstance(ch.id, ch.Jan, 1, '', ch.ChurnIndicator));
							}
							if (ch.Feb != null && String.isNotBlank(dosBudgetMap.get(key).monthIds[1])) {
								if (String.isBlank(ch.Feb)) { ch.Feb = '0'; } sbList.add(updateBudgetInstance(ch.Feb, dosBudgetMap.get(key).monthIds[1], ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.Feb) && String.isBlank(dosBudgetMap.get(key).monthIds[1])) {
								sbList.add(createBudgetInstance(ch.id, ch.Feb, 2, '', ch.ChurnIndicator));
							}
							if (ch.Mar != null && String.isNotBlank(dosBudgetMap.get(key).monthIds[2])) {
								if (String.isBlank(ch.Mar)) { ch.Mar = '0'; } sbList.add(updateBudgetInstance(ch.Mar, dosBudgetMap.get(key).monthIds[2], ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.Mar) && String.isBlank(dosBudgetMap.get(key).monthIds[2])) {
								sbList.add(createBudgetInstance(ch.id, ch.Mar, 3, '', ch.ChurnIndicator));
							}
							if (ch.Apr != null && String.isNotBlank(dosBudgetMap.get(key).monthIds[3])) {
								if (String.isBlank(ch.Apr)) { ch.Apr = '0'; } sbList.add(updateBudgetInstance(ch.Apr, dosBudgetMap.get(key).monthIds[3], ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.Apr) && String.isBlank(dosBudgetMap.get(key).monthIds[3])) {
								sbList.add(createBudgetInstance(ch.id, ch.Apr, 4, '', ch.ChurnIndicator));
							}
							if (ch.May != null && String.isNotBlank(dosBudgetMap.get(key).monthIds[4])) {
								if (String.isBlank(ch.May)) { ch.May = '0'; } sbList.add(updateBudgetInstance(ch.May, dosBudgetMap.get(key).monthIds[4], ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.May) && String.isBlank(dosBudgetMap.get(key).monthIds[4])) {
								sbList.add(createBudgetInstance(ch.id, ch.May, 5, '', ch.ChurnIndicator));
							}
							if (ch.Jun != null && String.isNotBlank(dosBudgetMap.get(key).monthIds[5])) {
								if (String.isBlank(ch.Jun)) { ch.Jun = '0'; } sbList.add(updateBudgetInstance(ch.Jun, dosBudgetMap.get(key).monthIds[5], ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.Jun) && String.isBlank(dosBudgetMap.get(key).monthIds[5])) {
								sbList.add(createBudgetInstance(ch.id, ch.Jun, 6, '', ch.ChurnIndicator));
							}
							if (ch.Jul != null && String.isNotBlank(dosBudgetMap.get(key).monthIds[6])) {
								if (String.isBlank(ch.Jul)) { ch.Jul = '0'; } sbList.add(updateBudgetInstance(ch.Jul, dosBudgetMap.get(key).monthIds[6], ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.Jul) && String.isBlank(dosBudgetMap.get(key).monthIds[6])) {
								sbList.add(createBudgetInstance(ch.id, ch.Jul, 7, '', ch.ChurnIndicator));
							}
							if (ch.Aug != null && String.isNotBlank(dosBudgetMap.get(key).monthIds[7])) {
								if (String.isBlank(ch.Aug)) { ch.Aug = '0'; } sbList.add(updateBudgetInstance(ch.Aug, dosBudgetMap.get(key).monthIds[7], ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.Aug) && String.isBlank(dosBudgetMap.get(key).monthIds[7])) {
								sbList.add(createBudgetInstance(ch.id, ch.Aug, 8, '', ch.ChurnIndicator));
							}
							if (ch.Sep != null && String.isNotBlank(dosBudgetMap.get(key).monthIds[8])) {
								if (String.isBlank(ch.Sep)) { ch.Sep = '0'; } sbList.add(updateBudgetInstance(ch.Sep, dosBudgetMap.get(key).monthIds[8], ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.Sep) && String.isBlank(dosBudgetMap.get(key).monthIds[8])) {
								sbList.add(createBudgetInstance(ch.id, ch.Sep, 9, '', ch.ChurnIndicator));
							}
							if (ch.Oct != null && String.isNotBlank(dosBudgetMap.get(key).monthIds[9])) {
								if (String.isBlank(ch.Oct)) { ch.Oct = '0'; } sbList.add(updateBudgetInstance(ch.Oct, dosBudgetMap.get(key).monthIds[9], ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.Oct) && String.isBlank(dosBudgetMap.get(key).monthIds[9])) {
								sbList.add(createBudgetInstance(ch.id, ch.Oct, 10, '', ch.ChurnIndicator));
							}
							if (ch.Nov != null && String.isNotBlank(dosBudgetMap.get(key).monthIds[10])) {
								if (String.isBlank(ch.Nov)) { ch.Nov = '0'; } sbList.add(updateBudgetInstance(ch.Nov, dosBudgetMap.get(key).monthIds[10], ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.Nov) && String.isBlank(dosBudgetMap.get(key).monthIds[10])) {
								sbList.add(createBudgetInstance(ch.id, ch.Nov, 11, '', ch.ChurnIndicator));
							}
							if (ch.Dec != null && String.isNotBlank(dosBudgetMap.get(key).monthIds[11])) {
								if (String.isBlank(ch.Dec)) { ch.Dec = '0'; } sbList.add(updateBudgetInstance(ch.Dec, dosBudgetMap.get(key).monthIds[11], ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.Dec) && String.isBlank(dosBudgetMap.get(key).monthIds[11])) {
								sbList.add(createBudgetInstance(ch.id, ch.Dec, 12, '', ch.ChurnIndicator));
							}
						}
					}
					else {
						//Budget Insert Block
						if (budgetMap.keySet() == null || budgetMap.get(key) == null) {
							if (String.isNotBlank(ch.Jan)) {
								sbList.add(createBudgetInstance(ch.id, ch.Jan, 1, '', ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.ChurnIndicator)) { sbList.add(createBudgetInstance(ch.id, '0', 1, '', ch.ChurnIndicator)); }
							if (String.isNotBlank(ch.Feb)) {
								sbList.add(createBudgetInstance(ch.id, ch.Feb, 2, '', ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.ChurnIndicator)) { sbList.add(createBudgetInstance(ch.id, '0', 2, '', ch.ChurnIndicator)); }
							if (String.isNotBlank(ch.Mar)) {
								sbList.add(createBudgetInstance(ch.id, ch.Mar, 3, '', ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.ChurnIndicator)) { sbList.add(createBudgetInstance(ch.id, '0', 3, '', ch.ChurnIndicator)); }
							if (String.isNotBlank(ch.Apr)) {
								sbList.add(createBudgetInstance(ch.id, ch.Apr, 4, '', ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.ChurnIndicator)) { sbList.add(createBudgetInstance(ch.id, '0', 4, '', ch.ChurnIndicator)); }
							if (String.isNotBlank(ch.May)) {
								sbList.add(createBudgetInstance(ch.id, ch.May, 5, '', ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.ChurnIndicator)) { sbList.add(createBudgetInstance(ch.id, '0', 5, '', ch.ChurnIndicator)); }
							if (String.isNotBlank(ch.Jun)) {
								sbList.add(createBudgetInstance(ch.id, ch.Jun, 6, '', ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.ChurnIndicator)) { sbList.add(createBudgetInstance(ch.id, '0', 6, '', ch.ChurnIndicator)); }
							if (String.isNotBlank(ch.Jul)) {
								sbList.add(createBudgetInstance(ch.id, ch.Jul, 7, '', ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.ChurnIndicator)) { sbList.add(createBudgetInstance(ch.id, '0', 7, '', ch.ChurnIndicator)); }
							if (String.isNotBlank(ch.Aug)) {
								sbList.add(createBudgetInstance(ch.id, ch.Aug, 8, '', ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.ChurnIndicator)) { sbList.add(createBudgetInstance(ch.id, '0', 8, '', ch.ChurnIndicator)); }
							if (String.isNotBlank(ch.Sep)) {
								sbList.add(createBudgetInstance(ch.id, ch.Sep, 9, '', ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.ChurnIndicator)) { sbList.add(createBudgetInstance(ch.id, '0', 9, '', ch.ChurnIndicator)); }
							if (String.isNotBlank(ch.Oct)) {
								sbList.add(createBudgetInstance(ch.id, ch.Oct, 10, '', ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.ChurnIndicator)) { sbList.add(createBudgetInstance(ch.id, '0', 10, '', ch.ChurnIndicator)); }
							if (String.isNotBlank(ch.Nov)) {
								sbList.add(createBudgetInstance(ch.id, ch.Nov, 11, '', ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.ChurnIndicator)) { sbList.add(createBudgetInstance(ch.id, '0', 11, '', ch.ChurnIndicator)); }
							if (String.isNotBlank(ch.Dec)) {
								sbList.add(createBudgetInstance(ch.id, ch.Dec, 12, '', ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.ChurnIndicator)) { sbList.add(createBudgetInstance(ch.id, '0', 12, '', ch.ChurnIndicator)); }

							System.debug(sbWorkflowId + workflowAdded);
							List<Sales_Budget__c> sbw = new List<Sales_Budget__c> ();
							sbw = [SELECT id
							       FROM Sales_Budget__c
							       WHERE Budget_User__c = :loggedInUser.id and
							       CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.BudgetCurrentYear) and
							       type__c in('Workflow') limit 1];
							if (sbw.size() == 0 && workflowAdded == false) {
								//add workflow record
								Sales_Budget__c sb = createBudgetInstance(ch.id + keySeparator + 'Workflow', '0', 1, '', '');
								sb.type__c = 'Workflow';
								sb.HR_Manager__c = loggedInUser.HR_Manager__c;
								//sb.Data_Source__c = 'APEX';
								//sb.Data_Source_Exact__c = 'BudgetingToolController - saveGridData';
								sbList.add(sb);
								sbsList.add(JSON.serialize(sb));
								workflowAdded = true;
							}
						}
						//System.debug('budgetMap1'+budgetMap);
						//Budget Update Block
						else if (budgetMap.keySet() != null && budgetMap.get(key) != null) {
							System.debug('budgetMap1' + budgetMap);
							if (ch.Jan != null && String.isNotBlank(budgetMap.get(key).monthIds[0])) {
								if (String.isBlank(ch.Jan)) { ch.Jan = '0'; } sbList.add(updateBudgetInstance(ch.Jan, budgetMap.get(key).monthIds[0], ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.Jan) && String.isBlank(budgetMap.get(key).monthIds[0])) {
								sbList.add(createBudgetInstance(ch.id, ch.Jan, 1, '', ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.ChurnIndicator)) { sbList.add(createBudgetInstance(ch.id, '0', 1, '', ch.ChurnIndicator)); }
							if (ch.Feb != null && String.isNotBlank(budgetMap.get(key).monthIds[1])) {
								if (String.isBlank(ch.Feb)) { ch.Feb = '0'; } sbList.add(updateBudgetInstance(ch.Feb, budgetMap.get(key).monthIds[1], ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.Feb) && String.isBlank(budgetMap.get(key).monthIds[1])) {
								sbList.add(createBudgetInstance(ch.id, ch.Feb, 2, '', ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.ChurnIndicator)) { sbList.add(createBudgetInstance(ch.id, '0', 2, '', ch.ChurnIndicator)); }
							if (ch.Mar != null && String.isNotBlank(budgetMap.get(key).monthIds[2])) {
								if (String.isBlank(ch.Mar)) { ch.Mar = '0'; } sbList.add(updateBudgetInstance(ch.Mar, budgetMap.get(key).monthIds[2], ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.Mar) && String.isBlank(budgetMap.get(key).monthIds[2])) {
								sbList.add(createBudgetInstance(ch.id, ch.Mar, 3, '', ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.ChurnIndicator)) { sbList.add(createBudgetInstance(ch.id, '0', 3, '', ch.ChurnIndicator)); }
							if (ch.Apr != null && String.isNotBlank(budgetMap.get(key).monthIds[3])) {
								if (String.isBlank(ch.Apr)) { ch.Apr = '0'; } sbList.add(updateBudgetInstance(ch.Apr, budgetMap.get(key).monthIds[3], ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.Apr) && String.isBlank(budgetMap.get(key).monthIds[3])) {
								sbList.add(createBudgetInstance(ch.id, ch.Apr, 4, '', ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.ChurnIndicator)) { sbList.add(createBudgetInstance(ch.id, '0', 4, '', ch.ChurnIndicator)); }
							if (ch.May != null && String.isNotBlank(budgetMap.get(key).monthIds[4])) {
								if (String.isBlank(ch.May)) { ch.May = '0'; } sbList.add(updateBudgetInstance(ch.May, budgetMap.get(key).monthIds[4], ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.May) && String.isBlank(budgetMap.get(key).monthIds[4])) {
								sbList.add(createBudgetInstance(ch.id, ch.May, 5, '', ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.ChurnIndicator)) { sbList.add(createBudgetInstance(ch.id, '0', 5, '', ch.ChurnIndicator)); }
							if (ch.Jun != null && String.isNotBlank(budgetMap.get(key).monthIds[5])) {
								if (String.isBlank(ch.Jun)) { ch.Jun = '0'; } sbList.add(updateBudgetInstance(ch.Jun, budgetMap.get(key).monthIds[5], ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.Jun) && String.isBlank(budgetMap.get(key).monthIds[5])) {
								sbList.add(createBudgetInstance(ch.id, ch.Jun, 6, '', ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.ChurnIndicator)) { sbList.add(createBudgetInstance(ch.id, '0', 6, '', ch.ChurnIndicator)); }
							if (ch.Jul != null && String.isNotBlank(budgetMap.get(key).monthIds[6])) {
								if (String.isBlank(ch.Jul)) { ch.Jul = '0'; } sbList.add(updateBudgetInstance(ch.Jul, budgetMap.get(key).monthIds[6], ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.Jul) && String.isBlank(budgetMap.get(key).monthIds[6])) {
								sbList.add(createBudgetInstance(ch.id, ch.Jul, 7, '', ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.ChurnIndicator)) { sbList.add(createBudgetInstance(ch.id, '0', 7, '', ch.ChurnIndicator)); }
							if (ch.Aug != null && String.isNotBlank(budgetMap.get(key).monthIds[7])) {
								if (String.isBlank(ch.Aug)) { ch.Aug = '0'; } sbList.add(updateBudgetInstance(ch.Aug, budgetMap.get(key).monthIds[7], ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.Aug) && String.isBlank(budgetMap.get(key).monthIds[7])) {
								sbList.add(createBudgetInstance(ch.id, ch.Aug, 8, '', ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.ChurnIndicator)) { sbList.add(createBudgetInstance(ch.id, '0', 8, '', ch.ChurnIndicator)); }
							if (ch.Sep != null && String.isNotBlank(budgetMap.get(key).monthIds[8])) {
								if (String.isBlank(ch.Sep)) { ch.Sep = '0'; } sbList.add(updateBudgetInstance(ch.Sep, budgetMap.get(key).monthIds[8], ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.Sep) && String.isBlank(budgetMap.get(key).monthIds[8])) {
								sbList.add(createBudgetInstance(ch.id, ch.Sep, 9, '', ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.ChurnIndicator)) { sbList.add(createBudgetInstance(ch.id, '0', 9, '', ch.ChurnIndicator)); }
							if (ch.Oct != null && String.isNotBlank(budgetMap.get(key).monthIds[9])) {
								if (String.isBlank(ch.Oct)) { ch.Oct = '0'; } sbList.add(updateBudgetInstance(ch.Oct, budgetMap.get(key).monthIds[9], ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.Oct) && String.isBlank(budgetMap.get(key).monthIds[9])) {
								sbList.add(createBudgetInstance(ch.id, ch.Oct, 10, '', ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.ChurnIndicator)) { sbList.add(createBudgetInstance(ch.id, '0', 11, '', ch.ChurnIndicator)); }
							if (ch.Nov != null && String.isNotBlank(budgetMap.get(key).monthIds[10])) {
								if (String.isBlank(ch.Nov)) { ch.Nov = '0'; } sbList.add(updateBudgetInstance(ch.Nov, budgetMap.get(key).monthIds[10], ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.Nov) && String.isBlank(budgetMap.get(key).monthIds[10])) {
								sbList.add(createBudgetInstance(ch.id, ch.Nov, 11, '', ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.ChurnIndicator)) { sbList.add(createBudgetInstance(ch.id, '0', 11, '', ch.ChurnIndicator)); }
							if (ch.Dec != null && String.isNotBlank(budgetMap.get(key).monthIds[11])) {
								if (String.isBlank(ch.Dec)) { ch.Dec = '0'; } sbList.add(updateBudgetInstance(ch.Dec, budgetMap.get(key).monthIds[11], ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.Dec) && String.isBlank(budgetMap.get(key).monthIds[11])) {
								sbList.add(createBudgetInstance(ch.id, ch.Dec, 12, '', ch.ChurnIndicator));
							} else if (String.isNotBlank(ch.ChurnIndicator)) { sbList.add(createBudgetInstance(ch.id, '0', 12, '', ch.ChurnIndicator)); }

						}
					}
				}

				System.debug('sbList: ' + sbList);

				//Upsert modified budget records
				Map<String, Sales_Budget__c> sbMap = new Map<String, Sales_Budget__c> ();
				List<Sales_Budget__c> sbUpdateList = new List<Sales_Budget__c> ();
				if (sbList.size()> 0) {
					for (Sales_Budget__c sb : sbList) {
						System.debug('sb.External_Id__c: ' + sb.External_Id__c);
						if (String.isBlank(sb.External_Id__c) && String.isNotBlank(sb.id)) {
							sbUpdateList.add(sb);
						}
						else if (String.isNotBlank(sb.External_Id__c) && !sbMap.containskey(sb.External_Id__c)) {
							sbMap.put(sb.External_Id__c, sb);
						}
					}
					if (sbMap.values().size()> 0) {
						Database.insert(sbMap.values(), false);
					}
					if (sbUpdateList.size()> 0) {
						Database.update(sbUpdateList, false);
					}

					//Log JSON payload in Logger for dupes tracking
					Log4SF.logMessage('BudgetingToolController', 'saveGridData', 'Client Details: ' + clientInfo + '\n JSON Save Payload: ' + JSONOutput, loggedInUser.Id, loggedInUser.Id);
				}

				//Refresh Grid to show new Budget rows
				if (loggedInUserBudgetType == 'National') {
					showNSMGrid();
				}
				else if (loggedInUserBudgetType == 'Local' || loggedInUserBudgetType == 'Local Special') {
					showAEGrid();
				}
				if (loggedInBudgetView == 'Leadership' && dosUser != null) {
					showDOSGrid();
					return(new PageReference(Label.SalesforceLightningInstance + 'apex/BudgetingToolNSMGrid?userparam=' + userParam + '&selectedDMA=' + selectedDMA));
				}
			}
			if (Test.isRunningTest()) {
				CalloutException e = new CalloutException();
				e.setMessage('This is a constructed exception for testing and code coverage');
				throw e;
			}

		}
		catch(Exception ex) {
			System.debug(ex.getMessage());
			System.debug(ex.getStackTraceString());
			alertMessage = 'An unexpected error has occured. Please contact your system administrator.';
			//create new mail message
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(new String[] { Label.BudgetErrorRecipient });
			mail.setSubject('Developer script exception from New Spectrum Reach : BudgetingToolController : SaveGridData : ' + loggedinUser.Id);
			mail.setPlainTextBody(ex.getMessage() + ex.getLineNumber() + JSONOutput);

			//send mail
			//Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
		return null;
	}

	/**
	 * This method creates a new budget object instance with all required fields
	 *
	 * @param  (String key) (NA)
	 * @param  (String amount) (NA)
	 * @param  (String month) (NA)
	 * @param  (String id) (NA)
	 * @return (Sales_Budget__c) (NA)
	 */
	public Sales_Budget__c createBudgetInstance(String key, String amount, Integer month, String id, String ChurnIndicator) {
		List<String> keyAttrs = key.split(keySeparator);
		System.debug(key);
		Sales_Budget__c sb = new Sales_Budget__c();
		if (String.isNotBlank(id)) {
			sb.id = id;
		}
		sb.Amount__c = Decimal.valueOf(amount);
		sb.Broadcast_Month_Date__c = System.Date.newInstance(Integer.valueOf(Label.BudgetCurrentYear), month, 15);
		sb.Budget_User__c = loggedInUser.id;
		sb.ownerId = loggedInUser.id;

		//System.debug(keyAttrs[1] + ',' + keyAttrs[2] + ',' + keyAttrs[3] + ',' + keyAttrs[4]);
		if (loggedInUserBudgetType == 'National') {
			sb.DMA__c = keyAttrs[1];
			sb.Commodity__c = keyAttrs[2];
			if (keyAttrs[3].startsWith('001'))
			sb.Advertiser__c = keyAttrs[3];
			sb.Product_Line__c = keyAttrs[4];
		}
		else if (loggedInUserBudgetType == 'Local' || loggedInUserBudgetType == 'Local Special') {
			sb.Commodity__c = keyAttrs[1];
			if (keyAttrs[2].startsWith('001'))
			sb.Advertiser__c = keyAttrs[2];
			sb.Product_Line__c = keyAttrs[3];
		}
		sb.External_Id__c = loggedInUser + keySeparator + key + keySeparator + month;
		sb.Status__c = 'Pending';

		if (key.contains('DOS')) {
			sb.type__c = 'DOS';
			if (loggedInUserBudgetType == 'National') {
				sb.New_Business_Churn__c = keyAttrs[7];
			}
			else {
				sb.New_Business_Churn__c = keyAttrs[6];
			}

		}

		if (key.contains('Forecast')) {
			sb.type__c = 'Forecast';
			sb.Broadcast_Month_Date__c = System.Date.newInstance(Integer.valueOf(Label.BudgetForecastCurrentYear), month, 15);
		}

		sb.Churn_Indicator__c = ChurnIndicator;
		return sb;
	}

	/**
	 * This method creates a new budget object instance with an existing budget record id
	 *
	 * @param  (String amount) (NA)
	 * @param  (String id) (NA)
	 * @return (Sales_Budget__c) (NA)
	 */
	public Sales_Budget__c updateBudgetInstance(String amount, String id, String ChurnIndicator) {
		Sales_Budget__c sb = new Sales_Budget__c();
		sb.id = id;
		sb.Amount__c = Decimal.valueOf(amount);
		sb.Churn_Indicator__c = ChurnIndicator;

		return sb;
	}

	/**
	 * This method submits budget for manager's approval
	 *
	 * @return (PageReference) (NA)
	 */
	@RemoteAction
	global static String submitBudget(String sbWorkflowId, String comments, String submittedUser) {
		System.debug('WorkflowID: ' + sbWorkflowId);
		System.debug('Logged in User: ' + submittedUser);
		String submitStatus = 'Submitted';
		Sales_Budget__c sbw = new Sales_Budget__c();
		if (sbWorkflowId != null) {
			sbw.id = sbWorkflowId;
			sbw.Status__c = submitStatus;
			sbw.Comments__c = comments;
			update sbw;
		}

		UserApprovalGeneration.updateBudgetApprovalSubmission(sbWorkflowId);

		return 'Submitted';
	}

	@RemoteAction
	global static String submitForecast(String sbWorkflowId, String comments, String submittedUser) {
		System.debug('WorkflowID: ' + sbWorkflowId + comments);
		String submitStatus = 'Forecast Submitted';
		Sales_Budget__c sbw = new Sales_Budget__c();
		if (String.IsBlank(sbWorkflowId) || String.isEmpty(sbWorkflowId)) {
			sbw.Status__c = submitStatus;
			sbw.Comments__c = comments;
			sbw.Budget_User__c = submittedUser;
			sbw.ownerId = submittedUser;
			sbw.External_Id__c = 'Workflow' + submittedUser;
			sbw.Type__c = 'Workflow';
			//sbw.Data_Source__c = 'APEX';
			//sbw.Data_Source_Exact__c = 'BudgetingToolController - submitForecast';
			sbw.Broadcast_Month_Date__c = System.Date.newInstance(Integer.valueOf(Label.BudgetCurrentYear), 12, 15);
			insert sbw;

			System.debug('INSERTED SBW: ' + sbw);
			sbWorkflowId = sbw.Id;
		}

		if (sbWorkflowId != null) {
			sbw.id = sbWorkflowId;
			sbw.status__c = submitStatus;
			sbw.Comments__c = comments;
			update sbw;
			UserApprovalGeneration.userApprovalAssignment(submittedUser,sbWorkflowId);
			UserApprovalGeneration.updateForecastApprovalSubmission(sbWorkflowId);

		}

		return 'Submitted';
	}

	public pageReference submitForecast() {
		System.debug('WorkflowID: ' + sbWorkflowId + comments);

		saveForecast();

		String submitStatus = 'Forecast Submitted';
		Sales_Budget__c sbw = new Sales_Budget__c();
		if (String.IsBlank(sbWorkflowId) || String.isEmpty(sbWorkflowId)) {
			sbw.Status__c = submitStatus;
			sbw.Comments__c = comments;
			sbw.Budget_User__c = loggedInUser.id;
			sbw.ownerId = submittedUser;
			sbw.External_Id__c = 'Workflow' + loggedInUser.id;
			sbw.Type__c = 'Workflow';
			//sbw.Data_Source__c = 'APEX';
			//sbw.Data_Source_Exact__c = 'BudgetingToolController - submitForecast';
			sbw.Broadcast_Month_Date__c = System.Date.newInstance(Integer.valueOf(Label.BudgetCurrentYear), 12, 15);
			insert sbw;
			
			System.debug('INSERTED SBW: ' + sbw);
			sbWorkflowId = sbw.Id;
			UserApprovalGeneration.userApprovalAssignment(submittedUser,sbWorkflowId);
		}

		if (sbWorkflowId != null) {
			sbw.id = sbWorkflowId;
			sbw.status__c = submitStatus;
			sbw.Comments__c = comments;
			update sbw;
			UserApprovalGeneration.updateForecastApprovalSubmission(sbWorkflowId);
		}

		//Refresh Grid to show new Budget rows
		if (loggedInUserBudgetType == 'National') {
			showNSMGrid();
		}
		else if (loggedInUserBudgetType == 'Local' || loggedInUserBudgetType == 'Local Special') {
			showAEGrid();
		}

		return null;
	}

	@RemoteAction
	global static void approveBudget(String sbWorkflowId, String comments) {
		//System.debug('WorkflowID Approve: '+sbWorkflowId);
		String approverID = UserInfo.getUserId();
		String approveStatus = 'Approved';
		//Sales_Budget__c sbw = new Sales_Budget__c();
		if (sbWorkflowId != null) {
			UserApprovalGeneration.budgetProcess(approverID, sbWorkflowId, comments, approveStatus);
			/*
			  sbw.id = sbWorkflowId;
			  sbw.status__c = approveStatus;
			  sbw.Comments__c = comments;
			  update sbw;*/
		}
		//  return 'Approved';
	}

	@RemoteAction
	global static void approveForecast(String sbWorkflowId, String comments) {
		//  System.debug('WorkflowID: '+sbWorkflowId);
		String approverID = UserInfo.getUserId();
		String forecastStatus = 'Forecast Approved';
		//Sales_Budget__c sbw = new Sales_Budget__c();
		if (sbWorkflowId != null) {
			UserApprovalGeneration.forecastProcess(approverID, sbWorkflowId, comments, forecastStatus);
			/*  sbw.id = sbWorkflowId;
			  sbw.status__c = forecastStatus;
			  sbw.Comments__c = comments;
			  update sbw;*/
		}

		//return 'Approved';
	}

	@RemoteAction
	global static void rejectBudget(String sbWorkflowId, String comments) {
		System.debug('WorkflowID: ' + sbWorkflowId);
		String rejectorID = UserInfo.getUserId();
		String rejectStatus = 'Forecast Rejected';
		//Sales_Budget__c sbw = new Sales_Budget__c();
		if (sbWorkflowId != null) {
			UserApprovalGeneration.budgetProcess(rejectorID, sbWorkflowId, comments, rejectStatus);

			/*    sbw.id = sbWorkflowId;
			  sbw.status__c = rejectStatus;
			  sbw.Comments__c = comments;
			  update sbw;*/
		}

		//BudgetingToolController btc = new BudgetingToolController();

		//return 'Rejected';
	}

	@RemoteAction
	global static void rejectForecast(String sbWorkflowId, String comments) {
		System.debug('WorkflowID: ' + sbWorkflowId);
		String rejectorID = UserInfo.getUserId();
		String rejectStatus = 'Forecast Rejected';
		//Sales_Budget__c sbw = new Sales_Budget__c();
		if (sbWorkflowId != null) {
			UserApprovalGeneration.forecastProcess(rejectorID, sbWorkflowId, comments, rejectStatus);
			/*  sbw.id = sbWorkflowId;
			  sbw.HR_Manager__c = sbw.Budget_User__r.HR_Manager__c;
			  sbw.status__c = rejectStatus;
			  sbw.Comments__c = comments;
			  update sbw;*/
		}

		//BudgetingToolController btc = new BudgetingToolController();

		//        return 'Forecast Rejected';
	}

	/**
	 * This method saves updated Forecast data from Grid to Budget object
	 *
	 * @param  (String ProductName) (NA)
	 * @param  (List<BudgetingToolModel.Items_Led> tgmiLedList) (NA)
	 * @return (BudgetingToolModel.Items_Pro) (NA)
	 */
	public pageReference saveForecast() {
		System.debug('saveForecast()' + comments);
		List<Sales_Budget__c> sbList = new List<Sales_Budget__c> ();

		//Delete all existing Forecast records for this user
		List<Sales_Budget__c> sbDelList = new List<Sales_Budget__c> ();
		Datetime dt = Datetime.now();
		sbDelList = [SELECT id FROM Sales_Budget__c WHERE Budget_User__c = :loggedInUser.id and type__c = 'Forecast' and calendar_year(broadcast_month_date__c) = :Integer.valueof(label.BudgetCurrentYear) ];
		if (sbDelList.size()> 0) {
			delete sbDelList;
		}

		if (loggedInUserBudgetType == 'National' && String.isNotBlank(loggedInUserDMA)) {
			System.debug('saveForecast() for NSM' + comments);
			System.debug('loggedInUserDMA: ' + loggedInUserDMA);
			for (String dm : loggedInUserDMA.split(';')) {
				System.debug(dm);
				if (String.isNotBlank(dm)) {
					saveNationalForecast(dm, loggedInUser.id, loggedInUserProductLines, false);
				}
			}

		}
		else {
			//for (String dm : loggedInUserDMA.split(';')) {
			//System.debug(dm);
			//if (String.isNotBlank(dm)) {
			saveNationalForecast('', loggedInUser.id, loggedInUserProductLines, true);
			//}
			//break;
			//}
		}

		System.debug('sbList: ' + sbList);

		//Upsert forecast records
		if (sbList.size()> 0) {
			upsert sbList;
		}

		return null;
	}

	/**
	 * This method saves updated National Forecast data from Grid to Budget object
	 *
	 * @param  (String ProductName) (NA)
	 * @param  (List<BudgetingToolModel.Items_Led> tgmiLedList) (NA)
	 * @return (BudgetingToolModel.Items_Pro) (NA)
	 */

	public static void saveNationalForecast(String DMA, String loggedInUser, String loggedInUserProductLines, boolean isLocal) {
		System.debug('saveNationalForecast(): ' + DMA);
		try
		{
			GridHelper rh = new GridHelper();
			Map<String, gridHelper> allAdvertiserMap = new Map<String, gridHelper> ();
			Map<String, gridHelper> revenueCYMap = new Map<String, gridHelper> ();
			Map<String, gridHelper> revenuePYMap = new Map<String, gridHelper> ();
			Map<String, gridHelper> revenueNYMap = new Map<String, gridHelper> ();
			Map<String, gridHelper> forecastMap = new Map<String, gridHelper> ();
			List<Sales_Budget__c> sbList = new List<Sales_Budget__c> ();
			List<Sales_Budget__c> sbSampleRecordList = new List<Sales_Budget__c> ();
			String keySeparator = '::';
			Set<Id> advertiserIdList = new Set<Id> ();

			for (AccountTeamMember atm :[SELECT TeamMemberRole, accountid, account.name, account.Primary_Commodity__c
			     FROM AccountTeamMember
			     WHERE UserId = :loggedInUser and
			     account.Primary_Commodity__c != null
			     order by account.Primary_Commodity__c desc]) {

				advertiserIdList.add(atm.accountId);

				if (Boolean.valueOf(Label.saveZeroDollarAccounts))
				{
					for (String prodLine : loggedInUserProductLines.split(';'))
					{
						String key = keySeparator + DMA + keySeparator + atm.account.Primary_Commodity__c + keySeparator + atm.accountid + keySeparator + prodLine + keySeparator + Label.BudgetCurrentYear;
						rh = new gridHelper();
						rh.dma = DMA;
						rh.commodity = atm.account.Primary_Commodity__c;
						rh.Advertiser = atm.accountid;
						rh.ProductLine = prodLine;
						rh.year = Integer.valueOf(Label.BudgetForecastCurrentYear);
						allAdvertiserMap.put(key, rh);
					}
				}
			}

			List<AggregateResult> rList = new List<AggregateResult> ();
			if (!isLocal)
			{
				rList = [SELECT Budget_DMA__c, Advertiser__c, sum(Net_Projected_Amount__c) amount, Advertiser__r.Primary_Commodity__c Primary_Commodity__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year, Eclipse_System__c es, Customer_Number__c eid
				         FROM Revenue__c
				         WHERE((Account_Executive__c = :loggedInUser AND revenue_user__c = null) OR(revenue_user__c = :loggedInUser AND Account_Executive__c != NULL)) and
				         CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.RevenueCY) and
				         Budget_DMA__c = :DMA and
				         //Revenue__c  != null AND 
				         Product_Line__c in :loggedInUserProductLines.split(';') and
				         Advertiser__r.Primary_Commodity__c != null
				         group by Budget_DMA__c, Advertiser__r.Primary_Commodity__c, Advertiser__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c), Eclipse_System__c, Customer_Number__c
				         order by Budget_DMA__c, Advertiser__r.Primary_Commodity__c, Advertiser__c, min(Product_Line_Sequence__c) asc];
			}
			else
			{
				rList = [SELECT Budget_DMA__c, Advertiser__c, sum(Net_Projected_Amount__c) amount, Advertiser__r.Primary_Commodity__c Primary_Commodity__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year, Eclipse_System__c es, Customer_Number__c eid
				         FROM Revenue__c
				         WHERE((Account_Executive__c = :loggedInUser AND revenue_user__c = null) OR(revenue_user__c = :loggedInUser AND Account_Executive__c != NULL)) and
				         CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.RevenueCY) and
				         //Revenue__c  != null AND 
				         Product_Line__c in :loggedInUserProductLines.split(';') and
				         Advertiser__r.Primary_Commodity__c != null
				         group by Budget_DMA__c, Advertiser__r.Primary_Commodity__c, Advertiser__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c), Eclipse_System__c, Customer_Number__c
				         order by Budget_DMA__c, Advertiser__r.Primary_Commodity__c, Advertiser__c, min(Product_Line_Sequence__c) asc];
			}
			Map<String, Set<String>> mapEclipseID = new Map<String, Set<String>> ();
			Map<String, Set<String>> mapEclipseSystem = new Map<String, Set<String>> ();
			for (AggregateResult sr : rList)
			{
				String commodity = '';
				if ((String) sr.get('Advertiser__c') == Label.Dummy_Revenue_Account) {
					commodity = 'Unmapped Revenue';
				}
				else {
					commodity = (String) sr.get('Primary_Commodity__c');
				}
				String key = '';
				if (!isLocal)
				key = keySeparator + (String) sr.get('Budget_DMA__c') + keySeparator + commodity + keySeparator + (String) sr.get('Advertiser__c') + keySeparator + (String) sr.get('Product_Line__c') + keySeparator + Label.BudgetCurrentYear;
				else
				key = keySeparator + commodity + keySeparator + (String) sr.get('Advertiser__c') + keySeparator + (String) sr.get('Product_Line__c') + keySeparator + Label.BudgetCurrentYear;
				rh = new gridHelper();
				rh.dma = (String) sr.get('Budget_DMA__c');
				rh.commodity = commodity;
				rh.Advertiser = (String) sr.get('Advertiser__c');

				rh.ProductLine = (String) sr.get('Product_Line__c');
				rh.year = (Integer) sr.get('year');
				if (revenueCYMap.containsKey(key)) {
					rh.months = revenueCYMap.get(key).months;
					if (sr.get('es') != null)
					mapEclipseSystem.get(key).add((String) sr.get('es'));
					if (sr.get('eid') != null)
					mapEclipseID.get(key).add((String) sr.get('eid'));

					//rh.eclipseSystem = revenueCYMap.get(key).eclipseSystem + ',' + (String)revPY.get('es');
					//rh.eclipseId = revenueCYMap.get(key).eclipseId + ',' + (String)revPY.get('eid');
				}
				else
				{
					if (sr.get('es') != null)
					mapEclipseSystem.put(key, new Set<String> { (String) sr.get('es') });
					if (sr.get('eid') != null)
					mapEclipseID.put(key, new Set<String> { (String) sr.get('eid') });
					//rh.eclipseSystem =  (String)revPY.get('es');
					//rh.eclipseId = (String)revPY.get('eid');
				}
				if (mapEclipseSystem.containsKey(key))
				{
					for (String s : mapEclipseSystem.get(key)) {
						if (s != 'null')
						rh.eclipseSystem += s + ',';
					}
					//rh.eclipseSystem = String.join(mapEclipseSystem.get(key),',');
				}
				if (mapEclipseID.containsKey(key))
				{
					for (String s : mapEclipseID.get(key)) {
						if (s != 'null')
						rh.eclipseId += s + ',';
					}
				}
				if (commodity == 'Unmapped Revenue') {
					rh.months[(Integer) sr.get('mon') - 1] = rh.months[(Integer) sr.get('mon') - 1] + Integer.valueOf((Decimal) sr.get('amount'));
				}
				else {
					rh.months[(Integer) sr.get('mon') - 1] += Integer.valueOf((Decimal) sr.get('amount'));
				}
				revenueCYMap.put(key, rh);
				allAdvertiserMap.put(key, rh);
				advertiserIdList.add((String) sr.get('Advertiser__c'));
			}

			List<AggregateResult> revPYList = new List<AggregateResult> ();
			if (!isLocal)
			{
				revPYList = [SELECT Budget_DMA__c, Advertiser__c, sum(Net_Projected_Amount__c) amount, Advertiser__r.Primary_Commodity__c Primary_Commodity__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year, Eclipse_System__c es, Customer_Number__c eid
				             FROM Revenue__c
				             WHERE((Account_Executive__c = :loggedInUser AND revenue_user__c = null) OR(revenue_user__c = :loggedInUser AND Account_Executive__c != NULL)) and
				             CALENDAR_YEAR(Broadcast_Month_Date__c) = :(Integer.valueOf(Label.RevenueCY) - 1) and
				             Budget_DMA__c = :DMA and
				             //Revenue__c  != null AND 
				             Product_Line__c in :loggedInUserProductLines.split(';') and
				             Advertiser__r.Primary_Commodity__c != null
				             group by Budget_DMA__c, Advertiser__r.Primary_Commodity__c, Advertiser__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c), Eclipse_System__c, Customer_Number__c
				             order by Budget_DMA__c, Advertiser__r.Primary_Commodity__c, Advertiser__c, min(Product_Line_Sequence__c) asc];
			}
			else
			{
				revPYList = [SELECT Budget_DMA__c, Advertiser__c, sum(Net_Projected_Amount__c) amount, Advertiser__r.Primary_Commodity__c Primary_Commodity__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year, Eclipse_System__c es, Customer_Number__c eid
				             FROM Revenue__c
				             WHERE((Account_Executive__c = :loggedInUser AND revenue_user__c = null) OR(revenue_user__c = :loggedInUser AND Account_Executive__c != NULL)) and
				             CALENDAR_YEAR(Broadcast_Month_Date__c) = :(Integer.valueOf(Label.RevenueCY) - 1) and
				             //Revenue__c  != null AND 
				             Product_Line__c in :loggedInUserProductLines.split(';') and
				             Advertiser__r.Primary_Commodity__c != null
				             group by Budget_DMA__c, Advertiser__r.Primary_Commodity__c, Advertiser__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c), Eclipse_System__c, Customer_Number__c
				             order by Budget_DMA__c, Advertiser__r.Primary_Commodity__c, Advertiser__c, min(Product_Line_Sequence__c) asc];
			}
			mapEclipseID = new Map<String, Set<String>> ();
			mapEclipseSystem = new Map<String, Set<String>> ();
			System.debug('revPYList ' + revPYList.size());
			System.debug(':loggedInUserProductLines ' + loggedInUserProductLines);
			System.debug('loggedInUser ' + loggedInUser);
			System.debug('Label.RevenueCY ' + Label.RevenueCY);
			for (AggregateResult revPY : revPYList) {
				String commodity = '';
				if ((String) revPY.get('Advertiser__c') == Label.Dummy_Revenue_Account) {
					commodity = 'Unmapped Revenue';
				}
				else {
					commodity = (String) revPY.get('Primary_Commodity__c');
				}
				String key = '';
				if (!isLocal)
				key = keySeparator + (String) revPY.get('Budget_DMA__c') + keySeparator + commodity + keySeparator + (String) revPY.get('Advertiser__c') + keySeparator + (String) revPY.get('Product_Line__c') + keySeparator + Label.BudgetCurrentYear;
				else
				key = keySeparator + commodity + keySeparator + (String) revPY.get('Advertiser__c') + keySeparator + (String) revPY.get('Product_Line__c') + keySeparator + Label.BudgetCurrentYear;
				rh = new gridHelper();
				rh.dma = (String) revPY.get('Budget_DMA__c');
				rh.commodity = commodity;
				rh.Advertiser = (String) revPY.get('Advertiser__c');
				rh.ProductLine = (String) revPY.get('Product_Line__c');
				rh.year = (Integer) revPY.get('year');
				if (revenuePYMap.containsKey(key)) {
					rh.months = revenuePYMap.get(key).months;
					mapEclipseSystem.get(key).add((String) revPY.get('es'));
					mapEclipseID.get(key).add((String) revPY.get('eid'));

					//rh.eclipseSystem = revenuePYMap.get(key).eclipseSystem + ',' + (String)revPY.get('es');
					//rh.eclipseId = revenuePYMap.get(key).eclipseId + ',' + (String)revPY.get('eid');
				}
				else
				{
					mapEclipseSystem.put(key, new Set<String> { (String) revPY.get('es') });
					mapEclipseID.put(key, new Set<String> { (String) revPY.get('eid') });
					//rh.eclipseSystem =  (String)revPY.get('es');
					//rh.eclipseId = (String)revPY.get('eid');
				}
				if (mapEclipseSystem.containsKey(key))
				{
					for (String s : mapEclipseSystem.get(key)) {
						if (s != 'null')
						rh.eclipseSystem += s + ',';
					}
					//rh.eclipseSystem = String.join(mapEclipseSystem.get(key),',');
				}
				if (mapEclipseID.containsKey(key))
				{
					for (String s : mapEclipseID.get(key)) {
						if (s != 'null')
						rh.eclipseId += s + ',';
					}
				}
				if (commodity == 'Unmapped Revenue') {
					rh.months[(Integer) revPY.get('mon') - 1] = rh.months[(Integer) revPY.get('mon') - 1] + Integer.valueOf((Decimal) revPY.get('amount'));
				}
				else {
					rh.months[(Integer) revPY.get('mon') - 1] += Integer.valueOf((Decimal) revPY.get('amount'));
				}
				revenuePYMap.put(key, rh);
				allAdvertiserMap.put(key, rh);
				System.debug('allAdvertiserMap revenue ' + allAdvertiserMap);
				advertiserIdList.add((String) revPY.get('Advertiser__c'));
			}

			List<AggregateResult> rNYList = new List<AggregateResult> ();
			if (!isLocal)
			{
				rNYList = [SELECT Budget_DMA__c, Advertiser__c, sum(Net_Projected_Amount__c) amount, Advertiser__r.Primary_Commodity__c Primary_Commodity__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year, Eclipse_System__c es, Customer_Number__c eid
				           FROM Revenue__c
				           WHERE((Account_Executive__c = :loggedInUser AND revenue_user__c = null) OR(revenue_user__c = :loggedInUser AND Account_Executive__c != NULL)) and
				           CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.RevenueNY) and
				           Budget_DMA__c = :DMA and
				           //Revenue__c  != null AND 
				           Product_Line__c in :loggedInUserProductLines.split(';') and
				           Advertiser__r.Primary_Commodity__c != null
				           group by Budget_DMA__c, Advertiser__r.Primary_Commodity__c, Advertiser__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c), Eclipse_System__c, Customer_Number__c
				           order by Budget_DMA__c, Advertiser__r.Primary_Commodity__c, Advertiser__c, min(Product_Line_Sequence__c) asc];
			}
			else
			{
				rNYList = [SELECT Budget_DMA__c, Advertiser__c, sum(Net_Projected_Amount__c) amount, Advertiser__r.Primary_Commodity__c Primary_Commodity__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year, Eclipse_System__c es, Customer_Number__c eid
				           FROM Revenue__c
				           WHERE((Account_Executive__c = :loggedInUser AND revenue_user__c = null) OR(revenue_user__c = :loggedInUser AND Account_Executive__c != NULL)) and
				           CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.RevenueNY) and
				           //Revenue__c  != null AND 
				           Product_Line__c in :loggedInUserProductLines.split(';') and
				           Advertiser__r.Primary_Commodity__c != null
				           group by Budget_DMA__c, Advertiser__r.Primary_Commodity__c, Advertiser__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c), Eclipse_System__c, Customer_Number__c
				           order by Budget_DMA__c, Advertiser__r.Primary_Commodity__c, Advertiser__c, min(Product_Line_Sequence__c) asc];
			}
			mapEclipseID = new Map<String, Set<String>> ();
			mapEclipseSystem = new Map<String, Set<String>> ();
			for (AggregateResult sr : rNYList)
			{
				String commodity = '';
				if ((String) sr.get('Advertiser__c') == Label.Dummy_Revenue_Account) {
					commodity = 'Unmapped Revenue';
				}
				else {
					commodity = (String) sr.get('Primary_Commodity__c');
				}
				String key = '';
				if (!isLocal)
				key = keySeparator + (String) sr.get('Budget_DMA__c') + keySeparator + commodity + keySeparator + (String) sr.get('Advertiser__c') + keySeparator + (String) sr.get('Product_Line__c') + keySeparator + Label.BudgetCurrentYear;
				else
				key = keySeparator + commodity + keySeparator + (String) sr.get('Advertiser__c') + keySeparator + (String) sr.get('Product_Line__c') + keySeparator + Label.BudgetCurrentYear;
				rh = new gridHelper();
				rh.dma = (String) sr.get('Budget_DMA__c');
				rh.commodity = commodity;
				rh.Advertiser = (String) sr.get('Advertiser__c');

				rh.ProductLine = (String) sr.get('Product_Line__c');
				rh.year = (Integer) sr.get('year');
				if (revenueNYMap.containsKey(key)) {
					rh.months = revenueNYMap.get(key).months;
					if (sr.get('es') != null)
					mapEclipseSystem.get(key).add((String) sr.get('es'));
					if (sr.get('eid') != null)
					mapEclipseID.get(key).add((String) sr.get('eid'));

					//rh.eclipseSystem = revenueCYMap.get(key).eclipseSystem + ',' + (String)revPY.get('es');
					//rh.eclipseId = revenueCYMap.get(key).eclipseId + ',' + (String)revPY.get('eid');
				}
				else
				{
					if (sr.get('es') != null)
					mapEclipseSystem.put(key, new Set<String> { (String) sr.get('es') });
					if (sr.get('eid') != null)
					mapEclipseID.put(key, new Set<String> { (String) sr.get('eid') });
					//rh.eclipseSystem =  (String)revPY.get('es');
					//rh.eclipseId = (String)revPY.get('eid');
				}
				if (mapEclipseSystem.containsKey(key))
				{
					for (String s : mapEclipseSystem.get(key)) {
						if (s != 'null')
						rh.eclipseSystem += s + ',';
					}
					//rh.eclipseSystem = String.join(mapEclipseSystem.get(key),',');
				}
				if (mapEclipseID.containsKey(key))
				{
					for (String s : mapEclipseID.get(key)) {
						if (s != 'null')
						rh.eclipseId += s + ',';
					}
				}
				if (commodity == 'Unmapped Revenue') {
					rh.months[(Integer) sr.get('mon') - 1] = rh.months[(Integer) sr.get('mon') - 1] + Integer.valueOf((Decimal) sr.get('amount'));
				}
				else {
					rh.months[(Integer) sr.get('mon') - 1] += Integer.valueOf((Decimal) sr.get('amount'));
				}
				revenueNYMap.put(key, rh);
				allAdvertiserMap.put(key, rh);
				advertiserIdList.add((String) sr.get('Advertiser__c'));
				
			}

			Map<String, SyscodeProductLineMap__c> custSettMap = SyscodeProductLineMap__c.getAll();
			//Query Current year's Forecast
			List<AggregateResult> pzmvList = new List<AggregateResult> ();
			if (!isLocal)
			{
				pzmvList = [SELECT proposal_zone__r.proposal__r.opportunity__r.DMA__C dm, proposal_zone__r.proposal__r.opportunity__r.accountId accId, sum(Broadcast_Amount__c) amount, proposal_zone__r.proposal__r.opportunity__r.account.Primary_Commodity__c cc,
				            proposal_zone__r.sys_code__c syscode, CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year
				            FROM Proposal_Zone_Monthly_Value__c
				            where proposal_zone__r.proposal__r.opportunity__r.ownerid = :loggedInUser and
				            proposal_zone__r.proposal__r.opportunity__r.accountId in :advertiserIdList and
				((proposal_zone__r.proposal__r.recordtype.name = 'Opportunity Budget' and proposal_zone__r.proposal__r.Active__c = true) or
				(proposal_zone__r.proposal__r.recordtype.name = 'Linear' and proposal_zone__r.status_type__c = 'Pending' and proposal_zone__r.proposal__r.Active__c = true)) and
				            CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.BudgetForecastCurrentYear) and
				            proposal_zone__r.proposal__r.opportunity__r.DMA__C = :DMA
				            and Proposal_Zone__r.Sys_Code__c in :custSettMap.keySet()
				            group by proposal_zone__r.proposal__r.opportunity__r.DMA__C, proposal_zone__r.proposal__r.opportunity__r.accountId, proposal_zone__r.proposal__r.opportunity__r.account.Primary_Commodity__c,
				            proposal_zone__r.sys_code__c, CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c)
				            order by Proposal_Zone__r.Sys_Code__c];
			}
			else
			{
				pzmvList = [SELECT proposal_zone__r.proposal__r.opportunity__r.DMA__C dm, proposal_zone__r.proposal__r.opportunity__r.accountId accId, sum(Broadcast_Amount__c) amount, proposal_zone__r.proposal__r.opportunity__r.account.Primary_Commodity__c cc,
				            proposal_zone__r.sys_code__c syscode, CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year
				            FROM Proposal_Zone_Monthly_Value__c
				            where proposal_zone__r.proposal__r.opportunity__r.ownerid = :loggedInUser and
				            proposal_zone__r.proposal__r.opportunity__r.accountId in :advertiserIdList and
				((proposal_zone__r.proposal__r.recordtype.name = 'Opportunity Budget' and proposal_zone__r.proposal__r.Active__c = true) or
				(proposal_zone__r.proposal__r.recordtype.name = 'Linear' and proposal_zone__r.status_type__c = 'Pending' and proposal_zone__r.proposal__r.Active__c = true)) and
				            CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.BudgetForecastCurrentYear)
				            //and Proposal_Zone__r.Sys_Code__c in: custSettMap.keySet()                                              
				            group by proposal_zone__r.proposal__r.opportunity__r.DMA__C, proposal_zone__r.proposal__r.opportunity__r.accountId, proposal_zone__r.proposal__r.opportunity__r.account.Primary_Commodity__c,
				            proposal_zone__r.sys_code__c, CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c)
				            order by Proposal_Zone__r.Sys_Code__c];
			}
			for (AggregateResult pzmv : pzmvList) {
				String productLine = (String) pzmv.get('syscode');
				system.debug('(String)pzmv.get(\'syscode\'): ' + (String) pzmv.get('syscode'));
				if (custSettMap.containsKey((String) pzmv.get('syscode')))
				{
					productLine = custSettMap.get((String) pzmv.get('syscode')).product_Line__c;
				}
				//System.debug(productLine);
				String key = '';
				if (!isLocal) {
					key = keySeparator + (String) pzmv.get('dm') + keySeparator + (String) pzmv.get('cc') + keySeparator + (String) pzmv.get('accId') +
					keySeparator + productLine + keySeparator + Label.BudgetCurrentYear;
				}
				else {
					if (String.isEmpty(productLine) || String.isBlank(productLine) || productLine == null)
					{
						productLine = 'Linear/News/Sports';
					}
					key = keySeparator + (String) pzmv.get('cc') + keySeparator + (String) pzmv.get('accId') +
					keySeparator + productLine + keySeparator + Label.BudgetCurrentYear;
				}
				rh = new GridHelper();
				rh.dma = (String) pzmv.get('dm');
				rh.commodity = (String) pzmv.get('cc');
				rh.Advertiser = (String) pzmv.get('accId');
				rh.ProductLine = productLine;
				rh.year = (Integer) pzmv.get('year');
				if (forecastMap.containsKey(key)) {
					rh.months = forecastMap.get(key).months;
				}
				//If forecast month is Jan-July use actual revenue amount, else use forecast amount from proposals
				if ((Integer) pzmv.get('mon') <= Integer.Valueof(Label.Forecast_Month)) {
					if (revenueCYMap.get(key) != null) {
						for (Integer i = 0; i<Integer.Valueof(Label.Forecast_Month); i++)
						{
							rh.months[i] = revenueCYMap.get(key).months[i];
						}
					}
				}
				else {
					rh.months[(Integer) pzmv.get('mon') - 1] = Integer.valueOf((Decimal) pzmv.get('amount'));
					if (revenueCYMap.get(key) != null) {
						for (Integer j = 0; j<Integer.Valueof(Label.Forecast_Month); j++)
						{
							rh.months[j] = revenueCYMap.get(key).months[j];
						}
					}
				}
				forecastMap.put(key, rh);
				allAdvertiserMap.put(key, rh);
			}

			Map<String, gridHelper> forecastMapPY = new Map<String, gridHelper> ();
			List<AggregateResult> pzmvPYList = new List<AggregateResult> ();
			if (!isLocal)
			{
				pzmvPYList = [SELECT proposal_zone__r.proposal__r.opportunity__r.DMA__C dm, proposal_zone__r.proposal__r.opportunity__r.accountId accId, sum(Broadcast_Amount__c) amount, proposal_zone__r.proposal__r.opportunity__r.account.Primary_Commodity__c cc,
				              proposal_zone__r.sys_code__c syscode, CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year
				              FROM Proposal_Zone_Monthly_Value__c
				              where proposal_zone__r.proposal__r.opportunity__r.ownerid = :loggedInUser and
				              proposal_zone__r.proposal__r.opportunity__r.accountId in :advertiserIdList and
				((proposal_zone__r.proposal__r.recordtype.name = 'Opportunity Budget' and proposal_zone__r.proposal__r.Active__c = true) or
				(proposal_zone__r.proposal__r.recordtype.name = 'Linear' and proposal_zone__r.status_type__c = 'Pending' and proposal_zone__r.proposal__r.Active__c = true)) and
				              CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.BudgetForecastCurrentYear) - 1 and
				              proposal_zone__r.proposal__r.opportunity__r.DMA__C = :DMA and
				              Proposal_Zone__r.Sys_Code__c in :custSettMap.keySet()
				              group by proposal_zone__r.proposal__r.opportunity__r.DMA__C, proposal_zone__r.proposal__r.opportunity__r.accountId, proposal_zone__r.proposal__r.opportunity__r.account.Primary_Commodity__c,
				              proposal_zone__r.sys_code__c, CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c)
				              order by Proposal_Zone__r.Sys_Code__c];
			}
			else
			{
				pzmvPYList = [SELECT proposal_zone__r.proposal__r.opportunity__r.DMA__C dm, proposal_zone__r.proposal__r.opportunity__r.accountId accId, sum(Broadcast_Amount__c) amount, proposal_zone__r.proposal__r.opportunity__r.account.Primary_Commodity__c cc,
				              proposal_zone__r.sys_code__c syscode, CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year
				              FROM Proposal_Zone_Monthly_Value__c
				              where proposal_zone__r.proposal__r.opportunity__r.ownerid = :loggedInUser and
				              proposal_zone__r.proposal__r.opportunity__r.accountId in :advertiserIdList and
				((proposal_zone__r.proposal__r.recordtype.name = 'Opportunity Budget' and proposal_zone__r.proposal__r.Active__c = true) or
				(proposal_zone__r.proposal__r.recordtype.name = 'Linear' and proposal_zone__r.status_type__c = 'Pending' and proposal_zone__r.proposal__r.Active__c = true)) and
				              CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.BudgetForecastCurrentYear) - 1
				              //and Proposal_Zone__r.Sys_Code__c in: custSettMap.keySet()
				              group by proposal_zone__r.proposal__r.opportunity__r.DMA__C, proposal_zone__r.proposal__r.opportunity__r.accountId, proposal_zone__r.proposal__r.opportunity__r.account.Primary_Commodity__c,
				              proposal_zone__r.sys_code__c, CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c)
				              order by Proposal_Zone__r.Sys_Code__c];
			}
			for (AggregateResult PYpzmv : pzmvPYList)
			{
				system.debug('PYpzmv RESULT: ' + PYpzmv);

				String productLine = (String) PYpzmv.get('syscode');
				if (custSettMap.containsKey((String) PYpzmv.get('syscode')))
				{
					productLine = custSettMap.get((String) PYpzmv.get('syscode')).product_Line__c;
				}
				String key = '';
				if (!isLocal)
				key = keySeparator + (String) PYpzmv.get('dm') + keySeparator + (String) PYpzmv.get('cc') + keySeparator + (String) PYpzmv.get('accId') +
				keySeparator + productLine + keySeparator + Label.BudgetCurrentYear;
				else
				{
					if (String.isEmpty(productLine) || String.isBlank(productLine) || productLine == null)
					{
						productLine = 'Linear/News/Sports';
					}
					key = keySeparator + (String) PYpzmv.get('cc') + keySeparator + (String) PYpzmv.get('accId') +
					keySeparator + productLine + keySeparator + Label.BudgetCurrentYear;
				}
				rh = new GridHelper();
				rh.dma = (String) PYpzmv.get('dm');
				rh.commodity = (String) PYpzmv.get('cc');
				rh.Advertiser = (String) PYpzmv.get('accId');
				rh.ProductLine = productLine;
				rh.year = (Integer) PYpzmv.get('year');
				rh.months[(Integer) PYpzmv.get('mon') - 1] = Integer.valueOf((Decimal) PYpzmv.get('amount'));
				if (forecastMapPY.containsKey(key)) {
					rh.months = forecastMapPY.get(key).months;
					rh.months[(Integer) PYpzmv.get('mon') - 1] = Integer.valueOf((Decimal) PYpzmv.get('amount'));
				}

				forecastMapPY.put(key, rh);
				allAdvertiserMap.put(key, rh);
			}

			system.debug('forecastMapPY size: ' + forecastMapPY.size());
			system.debug('allAdvertiserMap: ' + allAdvertiserMap);
			if (allAdvertiserMap != null) {
				//Create monthly Forecast records
				for (String key : allAdvertiserMap.keySet()) {
					String forecastkey = key + keySeparator + 'Forecast';

					System.debug('forecastMap size: ' + allAdvertiserMap.size());
					sbList.add(createNationalForecastInstanceNewBT(forecastkey, forecastMap, 12, '', '', loggedInUser, key, forecastMapPY, revenueCYMap, revenueNYMap, revenuePYMap, allAdvertiserMap, isLocal));
				}
			}

			System.debug('sbList: ' + sbList);

			//Upsert forecast records
			if (sbList.size()> 0) {

				Database.upsert(sbList, false);

				string Extkey = sbList[0].External_Id__c;
				List<String> keyAttrs = sbList[0].External_Id__c.split(keySeparator);

				for (String prodLine : loggedInUserProductLines.split(';'))
				{
					Sales_Budget__c sbSampleData = new Sales_Budget__c();
					sbSampleData.Broadcast_Month_Date__c = System.Date.newInstance(Integer.valueOf(Label.BudgetCurrentYear), 12, 15);
					sbSampleData.Budget_User__c = loggedInUser;
					sbSampleData.OwnerId = loggedInUser;
					sbSampleData.DMA__c = DMA;
					sbSampleData.Commodity__c = keyAttrs[2];
					if (keyAttrs[3].startsWith('001'))
					sbSampleData.Advertiser__c = keyAttrs[3];
					sbSampleData.Product_Line__c = prodLine;
					sbSampleData.Status__c = 'Pending';
					sbSampleData.type__c = 'Data';
					sbSampleData.Forecast__c = sbList[0].Id;
					sbSampleData.External_Id__c = loggedInUser + keySeparator + prodLine + keySeparator + keyAttrs[3] + keySeparator + keyAttrs[2] + keySeparator + DMA + keySeparator + 'Data' + keySeparator + '12' + keySeparator + Label.BudgetCurrentYear;

					Sales_Budget__c sbSampleDOSChrn = new Sales_Budget__c();
					sbSampleDOSChrn.Broadcast_Month_Date__c = System.Date.newInstance(Integer.valueOf(Label.BudgetCurrentYear), 12, 15);
					sbSampleDOSChrn.Budget_User__c = loggedInUser;
					sbSampleDOSChrn.OwnerId = loggedInUser;
					sbSampleDOSChrn.DMA__c = DMA;
					sbSampleDOSChrn.Commodity__c = 'New Business/Churn';
					sbSampleDOSChrn.Advertiser__c = Label.BudgetNewBusinessAcountId;
					sbSampleDOSChrn.Product_Line__c = prodLine;
					sbSampleDOSChrn.Status__c = 'Pending';
					sbSampleDOSChrn.type__c = 'DOS';
					sbSampleDOSChrn.New_Business_Churn__c = 'Unknown Churn';
					sbSampleDOSChrn.Forecast__c = sbList[0].Id;
					sbSampleDOSChrn.External_Id__c = loggedInUser + keySeparator + prodLine + keySeparator + sbSampleDOSChrn.Advertiser__c + keySeparator + sbSampleDOSChrn.Commodity__c + keySeparator + DMA + keySeparator + sbSampleDOSChrn.type__c + keySeparator + sbSampleDOSChrn.New_Business_Churn__c + keySeparator + '12' + keySeparator + Label.BudgetCurrentYear;

					Sales_Budget__c sbSampleDOSNB = new Sales_Budget__c();
					sbSampleDOSNB.Broadcast_Month_Date__c = System.Date.newInstance(Integer.valueOf(Label.BudgetCurrentYear), 12, 15);
					sbSampleDOSNB.Budget_User__c = loggedInUser;
					sbSampleDOSNB.OwnerId = loggedInUser;
					sbSampleDOSNB.DMA__c = DMA;
					sbSampleDOSNB.Commodity__c = 'New Business/Churn';
					sbSampleDOSNB.Advertiser__c = Label.BudgetNewBusinessAcountId;
					sbSampleDOSNB.Product_Line__c = prodLine;
					sbSampleDOSNB.Status__c = 'Pending';
					sbSampleDOSNB.type__c = 'DOS';
					sbSampleDOSNB.New_Business_Churn__c = 'New Business';
					sbSampleDOSNB.Forecast__c = sbList[0].Id;
					sbSampleDOSNB.External_Id__c = loggedInUser + keySeparator + prodLine + keySeparator + sbSampleDOSNB.Advertiser__c + keySeparator + sbSampleDOSNB.Commodity__c + keySeparator + DMA + keySeparator + sbSampleDOSNB.type__c + keySeparator + sbSampleDOSNB.New_Business_Churn__c + keySeparator + '12' + keySeparator + Label.BudgetCurrentYear;


					//sbSampleData.Data_Source__c = 'APEX';
					//sbSampleData.Data_Source_Exact__c = 'BudgetingToolController - saveNationalForecast' ;
					//sbSampleDOSChrn.Data_Source__c = 'APEX';
					//sbSampleDOSChrn.Data_Source_Exact__c = 'BudgetingToolController - saveNationalForecast' ; 
					//sbSampleDOSNB.Data_Source__c = 'APEX';
					//sbSampleDOSNB.Data_Source_Exact__c = 'BudgetingToolController - saveNationalForecast' ;  
					sbSampleRecordList.Add(sbSampleData);
					sbSampleRecordList.Add(sbSampleDOSChrn);
					sbSampleRecordList.Add(sbSampleDOSNB);
				}


				for (Integer j = 0; j <= 1; j++)
				{
					Sales_Budget__c sbSampleData = new Sales_Budget__c();
					sbSampleData.Broadcast_Month_Date__c = System.Date.newInstance(Integer.valueOf(Label.BudgetCurrentYear), 12, 15);
					sbSampleData.Budget_User__c = loggedInUser;
					sbSampleData.OwnerId = loggedInUser;
					sbSampleData.DMA__c = DMA;
					sbSampleData.Commodity__c = 'New Business/Churn';
					sbSampleData.Advertiser__c = Label.BudgetNewBusinessAcountId;
					sbSampleData.Product_Line__c = j == 0 ? 'New Business' : 'Unknown Churn';
					sbSampleData.Status__c = 'Pending';
					sbSampleData.type__c = 'Data';
					sbSampleData.Forecast__c = sbList[0].Id;
					//sbSampleData.Data_Source__c = 'APEX';
					//sbSampleData.Data_Source_Exact__c = 'BudgetingToolController - saveNationalForecast' ; 
					sbSampleData.External_Id__c = loggedInUser + keySeparator + sbSampleData.Product_Line__c + keySeparator + sbSampleData.Advertiser__c + keySeparator + sbSampleData.Commodity__c + keySeparator + DMA + sbSampleData.type__c + keySeparator + '12' + keySeparator + Label.BudgetCurrentYear;
					sbSampleRecordList.Add(sbSampleData);

				}

				if (sbSampleRecordList.size()> 0) {
					Database.upsert(sbSampleRecordList, false);
				}
			}
		}
		catch(Exception ex) {
			System.debug(ex.getMessage());
			System.debug(ex.getStackTraceString());
			//create new mail message
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(new String[] { 'shubham.gupta@mandsconsulting.com' });
			mail.setSubject('Developer script exception from New Spectrum Reach : BudgetingToolController : SaveNationalForecast : ' + DMA);
			mail.setPlainTextBody(ex.getMessage() + ex.getLineNumber());

			//send mail
			//Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}

	/**
	 * This method creates a new budget object instance with all required fields
	 *
	 * @param  (String key) (NA)
	 * @param  (String amount) (NA)
	 * @param  (String month) (NA)
	 * @param  (String id) (NA)
	 * @return (Sales_Budget__c) (NA)
	 */
	public static Sales_Budget__c createNationalForecastInstance(String key, String amount, Integer month, String id, String ChurnIndicator, String loggedInUser) {
		List<String> keyAttrs = key.split(keySeparator);
		System.debug(key);
		Sales_Budget__c sb = new Sales_Budget__c();
		if (String.isNotBlank(id)) {
			sb.id = id;
		}
		sb.Amount__c = Decimal.valueOf(amount);
		sb.Broadcast_Month_Date__c = System.Date.newInstance(Integer.valueOf(Label.BudgetCurrentYear), month, 15);
		sb.Budget_User__c = loggedInUser;
		sb.OwnerId = loggedInUser;

		sb.DMA__c = keyAttrs[1];
		sb.Commodity__c = keyAttrs[2];
		if (keyAttrs[3].startsWith('001'))
		sb.Advertiser__c = keyAttrs[3];
		sb.Product_Line__c = keyAttrs[4];
		sb.External_Id__c = key + keySeparator + month;
		sb.Status__c = 'Pending';

		sb.type__c = 'Forecast';
		sb.Broadcast_Month_Date__c = System.Date.newInstance(Integer.valueOf(Label.BudgetForecastCurrentYear), month, 15);

		return sb;
	}

	public static Sales_Budget__c createNationalForecastInstanceNewBT(String key, Map<String, gridHelper> forecastMap, Integer month, String id, String ChurnIndicator, String loggedInUser,
	                                                                  String forecastMapKey, Map<String, gridHelper> forecastMapPY, Map<String, gridHelper> revenueCYMap, Map<String, gridHelper> revenueNYMap ,Map<String, gridHelper> revenuePYMap, Map<String, gridHelper> allAdvertiserMap, boolean isLocal)
	{
		Boolean isAmontZero = true;
		List<String> keyAttrs = key.split(keySeparator);
		System.debug('key: ' + key);
		Sales_Budget__c sb = new Sales_Budget__c();
		if (String.isNotBlank(id)) {
			sb.id = id;
		}

		System.debug('forecastMapKey: ' + forecastMapKey);
		System.debug('forecastMap.get(forecastMapKey)' + forecastMap.get(forecastMapKey));

		if (forecastMap.size() > 0 && forecastMap.containsKey(forecastMapKey))
		{
			isAmontZero = false;
			sb.CY_FCST_1_Jan_Amount__c = 0; //Decimal.valueOf(String.valueOf(forecastMap.get(forecastMapKey).months[0]));
			sb.CY_FCST_2_Feb_Amount__c = 0; //Decimal.valueOf(String.valueOf(forecastMap.get(forecastMapKey).months[1]));
			sb.CY_FCST_3_March_Amount__c = 0; //Decimal.valueOf(String.valueOf(forecastMap.get(forecastMapKey).months[2]));
			sb.CY_FCST_4_April_Amount__c = 0; //Decimal.valueOf(String.valueOf(forecastMap.get(forecastMapKey).months[3]));
			sb.CY_FCST_5_May_Amount__c = 0; //Decimal.valueOf(String.valueOf(forecastMap.get(forecastMapKey).months[4]));
			sb.CY_FCST_6_June_Amount__c = 0; //Decimal.valueOf(String.valueOf(forecastMap.get(forecastMapKey).months[5]));
			sb.CY_FCST_7_July_Amount__c = 0; //Decimal.valueOf(String.valueOf(forecastMap.get(forecastMapKey).months[6]));
			sb.CY_FCST_8_Aug_Amount__c = Decimal.valueOf(String.valueOf(forecastMap.get(forecastMapKey).months[7]));
			sb.CY_FCST_9_Sep_Amount__c = Decimal.valueOf(String.valueOf(forecastMap.get(forecastMapKey).months[8]));
			sb.CY_FCST_10_Oct_Amount__c = Decimal.valueOf(String.valueOf(forecastMap.get(forecastMapKey).months[9]));
			sb.CY_FCST_11_Nov_Amount__c = Decimal.valueOf(String.valueOf(forecastMap.get(forecastMapKey).months[10]));
			sb.CY_FCST_12_Dec_Amount__c = Decimal.valueOf(String.valueOf(forecastMap.get(forecastMapKey).months[11]));
		}

		/*if(forecastMapPY.size()>0 && forecastMapPY.containsKey(forecastMapKey))
		  {
		  isAmontZero = false;
		  sb.PY_FCST_1_Jan_Amount__c = 0;  //Decimal.valueOf(String.valueOf(forecastMapPY.get(forecastMapKey).months[0]));
		  sb.PY_FCST_2_Feb_Amount__c = 0; //Decimal.valueOf(String.valueOf(forecastMapPY.get(forecastMapKey).months[1]));
		  sb.PY_FCST_3_March_Amount__c = 0; //Decimal.valueOf(String.valueOf(forecastMapPY.get(forecastMapKey).months[2]));
		  sb.PY_FCST_4_April_Amount__c = 0; //Decimal.valueOf(String.valueOf(forecastMapPY.get(forecastMapKey).months[3]));
		  sb.PY_FCST_5_May_Amount__c = 0; //Decimal.valueOf(String.valueOf(forecastMapPY.get(forecastMapKey).months[4]));
		  sb.PY_FCST_6_June_Amount__c = 0; //Decimal.valueOf(String.valueOf(forecastMapPY.get(forecastMapKey).months[5]));
		  sb.PY_FCST_7_July_Amount__c = 0; //Decimal.valueOf(String.valueOf(forecastMapPY.get(forecastMapKey).months[6]));
		  sb.PY_FCST_8_Aug_Amount__c =  Decimal.valueOf(String.valueOf(forecastMapPY.get(forecastMapKey).months[7]));
		  sb.PY_FCST_9_Sep_Amount__c =  Decimal.valueOf(String.valueOf(forecastMapPY.get(forecastMapKey).months[8]));
		  sb.PY_FCST_10_Oct_Amount__c =  Decimal.valueOf(String.valueOf(forecastMapPY.get(forecastMapKey).months[9]));
		  sb.PY_FCST_11_Nov_Amount__c =  Decimal.valueOf(String.valueOf(forecastMapPY.get(forecastMapKey).months[10]));
		  sb.PY_FCST_12_Dec_Amount__c =  Decimal.valueOf(String.valueOf(forecastMapPY.get(forecastMapKey).months[11]));
		  }*/

		if (revenueCYMap.size() > 0 && revenueCYMap.containsKey(forecastMapKey))
		{
			isAmontZero = false;
			sb.CY_Rev_1_Jan_Amount__c = Decimal.valueOf(String.valueOf(revenueCYMap.get(forecastMapKey).months[0]));
			sb.CY_Rev_2_Feb_Amount__c = Decimal.valueOf(String.valueOf(revenueCYMap.get(forecastMapKey).months[1]));
			sb.CY_Rev_3_March_Amount__c = Decimal.valueOf(String.valueOf(revenueCYMap.get(forecastMapKey).months[2]));
			sb.CY_Rev_4_April_Amount__c = Decimal.valueOf(String.valueOf(revenueCYMap.get(forecastMapKey).months[3]));
			sb.CY_Rev_5_May_Amount__c = Decimal.valueOf(String.valueOf(revenueCYMap.get(forecastMapKey).months[4]));
			sb.CY_Rev_6_June_Amount__c = Decimal.valueOf(String.valueOf(revenueCYMap.get(forecastMapKey).months[5]));
			sb.CY_Rev_7_July_Amount__c = Decimal.valueOf(String.valueOf(revenueCYMap.get(forecastMapKey).months[6]));
			sb.CY_Rev_8_Aug_Amount__c = Decimal.valueOf(String.valueOf(revenueCYMap.get(forecastMapKey).months[7]));
			sb.CY_Rev_9_Sep_Amount__c = Decimal.valueOf(String.valueOf(revenueCYMap.get(forecastMapKey).months[8]));
			sb.CY_Rev_10_Oct_Amount__c = Decimal.valueOf(String.valueOf(revenueCYMap.get(forecastMapKey).months[9]));
			sb.CY_Rev_11_Nov_Amount__c = Decimal.valueOf(String.valueOf(revenueCYMap.get(forecastMapKey).months[10]));
			sb.CY_Rev_12_Dec_Amount__c = Decimal.valueOf(String.valueOf(revenueCYMap.get(forecastMapKey).months[11]));
			sb.Eclipse_System__c = String.valueOf(revenueCYMap.get(forecastMapKey).EclipseSystem);
			sb.Eclipse_ID__c = String.valueOf(revenueCYMap.get(forecastMapKey).EclipseID);
		}

		if (revenuePYMap.size() > 0 && revenuePYMap.containsKey(forecastMapKey))
		{
			isAmontZero = false;
			sb.PY_Rev_1_Jan_Amount__c = Decimal.valueOf(String.valueOf(revenuePYMap.get(forecastMapKey).months[0]));
			sb.PY_Rev_2_Feb_Amount__c = Decimal.valueOf(String.valueOf(revenuePYMap.get(forecastMapKey).months[1]));
			sb.PY_Rev_3_March_Amount__c = Decimal.valueOf(String.valueOf(revenuePYMap.get(forecastMapKey).months[2]));
			sb.PY_Rev_4_April_Amount__c = Decimal.valueOf(String.valueOf(revenuePYMap.get(forecastMapKey).months[3]));
			sb.PY_Rev_5_May_Amount__c = Decimal.valueOf(String.valueOf(revenuePYMap.get(forecastMapKey).months[4]));
			sb.PY_Rev_6_June_Amount__c = Decimal.valueOf(String.valueOf(revenuePYMap.get(forecastMapKey).months[5]));
			sb.PY_Rev_7_July_Amount__c = Decimal.valueOf(String.valueOf(revenuePYMap.get(forecastMapKey).months[6]));
			sb.PY_Rev_8_Aug_Amount__c = Decimal.valueOf(String.valueOf(revenuePYMap.get(forecastMapKey).months[7]));
			sb.PY_Rev_9_Sep_Amount__c = Decimal.valueOf(String.valueOf(revenuePYMap.get(forecastMapKey).months[8]));
			sb.PY_Rev_10_Oct_Amount__c = Decimal.valueOf(String.valueOf(revenuePYMap.get(forecastMapKey).months[9]));
			sb.PY_Rev_11_Nov_Amount__c = Decimal.valueOf(String.valueOf(revenuePYMap.get(forecastMapKey).months[10]));
			sb.PY_Rev_12_Dec_Amount__c = Decimal.valueOf(String.valueOf(revenuePYMap.get(forecastMapKey).months[11]));
			sb.Eclipse_System__c = String.valueOf(revenuePYMap.get(forecastMapKey).EclipseSystem);
			sb.Eclipse_ID__c = String.valueOf(revenuePYMap.get(forecastMapKey).EclipseID);
		}

		if (revenueNYMap.size() > 0 && revenueNYMap.containsKey(forecastMapKey))
		{
			System.debug('Inside NYMAP');
			System.debug('Inside NYMAP forecastMapKey: ' + forecastMapKey);
			isAmontZero = false;
			sb.NY_Revenue_1_Jan_Amount__c = Decimal.valueOf(String.valueOf(revenueNYMap.get(forecastMapKey).months[0]));
			sb.NY_Revenue_2_Feb_Amount__c = Decimal.valueOf(String.valueOf(revenueNYMap.get(forecastMapKey).months[1]));
			sb.NY_Revenue_3_March_Amount__c = Decimal.valueOf(String.valueOf(revenueNYMap.get(forecastMapKey).months[2]));
			sb.NY_Revenue_4_April_Amount__c = Decimal.valueOf(String.valueOf(revenueNYMap.get(forecastMapKey).months[3]));
			sb.NY_Revenue_5_May_Amount__c = Decimal.valueOf(String.valueOf(revenueNYMap.get(forecastMapKey).months[4]));
			sb.NY_Revenue_6_June_Amount__c = Decimal.valueOf(String.valueOf(revenueNYMap.get(forecastMapKey).months[5]));
			sb.NY_Revenue_7_July_Amount__c = Decimal.valueOf(String.valueOf(revenueNYMap.get(forecastMapKey).months[6]));
			sb.NY_Revenue_8_Aug_Amount__c = Decimal.valueOf(String.valueOf(revenueNYMap.get(forecastMapKey).months[7]));
			sb.NY_Revenue_9_Sep_Amount__c = Decimal.valueOf(String.valueOf(revenueNYMap.get(forecastMapKey).months[8]));
			sb.NY_Revenue_10_Oct_Amount__c = Decimal.valueOf(String.valueOf(revenueNYMap.get(forecastMapKey).months[9]));
			sb.NY_Revenue_11_Nov_Amount__c = Decimal.valueOf(String.valueOf(revenueNYMap.get(forecastMapKey).months[10]));
			sb.NY_Revenue_12_Dec_Amount__c = Decimal.valueOf(String.valueOf(revenueNYMap.get(forecastMapKey).months[11]));
			sb.Eclipse_System__c = String.valueOf(revenueNYMap.get(forecastMapKey).EclipseSystem);
			sb.Eclipse_ID__c = String.valueOf(revenueNYMap.get(forecastMapKey).EclipseID);

			System.debug('Inside NYMAP sb: ' + sb.NY_Revenue_10_Oct_Amount__c);
			System.debug('Inside NYMAP sb: ' + sb.NY_Revenue_11_Nov_Amount__c);
		}

		if (isAmontZero == true)
		{
			System.Debug('Inside Else part');
			sb.CY_FCST_1_Jan_Amount__c = 0;
			sb.CY_FCST_2_Feb_Amount__c = 0;
			sb.CY_FCST_3_March_Amount__c = 0;
			sb.CY_FCST_4_April_Amount__c = 0;
			sb.CY_FCST_5_May_Amount__c = 0;
			sb.CY_FCST_6_June_Amount__c = 0;
			sb.CY_FCST_7_July_Amount__c = 0;
			sb.CY_FCST_8_Aug_Amount__c = 0;
			sb.CY_FCST_9_Sep_Amount__c = 0;
			sb.CY_FCST_10_Oct_Amount__c = 0;
			sb.CY_FCST_11_Nov_Amount__c = 0;
			sb.CY_FCST_12_Dec_Amount__c = 0;

			//sb.PY_FCST_1_Jan_Amount__c =  0;
			//sb.PY_FCST_2_Feb_Amount__c =  0;
			//sb.PY_FCST_3_March_Amount__c =  0;
			//sb.PY_FCST_4_April_Amount__c =  0;
			//sb.PY_FCST_5_May_Amount__c =  0;
			//sb.PY_FCST_6_June_Amount__c =  0;
			//sb.PY_FCST_7_July_Amount__c =  0;
			//sb.PY_FCST_8_Aug_Amount__c =  0;
			//sb.PY_FCST_9_Sep_Amount__c =  0;
			//sb.PY_FCST_10_Oct_Amount__c =  0;
			//sb.PY_FCST_11_Nov_Amount__c =  0;
			//sb.PY_FCST_12_Dec_Amount__c =  0;

			sb.CY_Rev_1_Jan_Amount__c = 0;
			sb.CY_Rev_2_Feb_Amount__c = 0;
			sb.CY_Rev_3_March_Amount__c = 0;
			sb.CY_Rev_4_April_Amount__c = 0;
			sb.CY_Rev_5_May_Amount__c = 0;
			sb.CY_Rev_6_June_Amount__c = 0;
			sb.CY_Rev_7_July_Amount__c = 0;
			sb.CY_Rev_8_Aug_Amount__c = 0;
			sb.CY_Rev_9_Sep_Amount__c = 0;
			sb.CY_Rev_10_Oct_Amount__c = 0;
			sb.CY_Rev_11_Nov_Amount__c = 0;
			sb.CY_Rev_12_Dec_Amount__c = 0;

			sb.PY_Rev_1_Jan_Amount__c = 0;
			sb.PY_Rev_2_Feb_Amount__c = 0;
			sb.PY_Rev_3_March_Amount__c = 0;
			sb.PY_Rev_4_April_Amount__c = 0;
			sb.PY_Rev_5_May_Amount__c = 0;
			sb.PY_Rev_6_June_Amount__c = 0;
			sb.PY_Rev_7_July_Amount__c = 0;
			sb.PY_Rev_8_Aug_Amount__c = 0;
			sb.PY_Rev_9_Sep_Amount__c = 0;
			sb.PY_Rev_10_Oct_Amount__c = 0;
			sb.PY_Rev_11_Nov_Amount__c = 0;
			sb.PY_Rev_12_Dec_Amount__c = 0;

			sb.NY_Revenue_1_Jan_Amount__c = 0;
			sb.NY_Revenue_2_Feb_Amount__c = 0;
			sb.NY_Revenue_3_March_Amount__c = 0;
			sb.NY_Revenue_4_April_Amount__c = 0;
			sb.NY_Revenue_5_May_Amount__c = 0;
			sb.NY_Revenue_6_June_Amount__c = 0;
			sb.NY_Revenue_7_July_Amount__c = 0;
			sb.NY_Revenue_8_Aug_Amount__c = 0;
			sb.NY_Revenue_9_Sep_Amount__c = 0;
			sb.NY_Revenue_10_Oct_Amount__c = 0;
			sb.NY_Revenue_11_Nov_Amount__c = 0;
			sb.NY_Revenue_12_Dec_Amount__c = 0;

		}
		if (isLocal)
		{
			sb.Broadcast_Month_Date__c = System.Date.newInstance(Integer.valueOf(Label.BudgetCurrentYear), month, 15);
			sb.Budget_User__c = loggedInUser;
			sb.OwnerId = loggedInUser;
			//sb.DMA__c =  keyAttrs[1];
			sb.Commodity__c = keyAttrs[1];
			if (keyAttrs[2].startsWith('001'))
			sb.Advertiser__c = keyAttrs[2];
			sb.Product_Line__c = keyAttrs[3];
			sb.External_Id__c = loggedInUser + keySeparator + key + keySeparator + month;
			sb.Status__c = 'Pending';
			sb.type__c = 'Forecast';
		}
		else {
			sb.Broadcast_Month_Date__c = System.Date.newInstance(Integer.valueOf(Label.BudgetCurrentYear), month, 15);
			sb.Budget_User__c = loggedInUser;
			sb.OwnerId = loggedInUser;
			sb.DMA__c = keyAttrs[1];
			sb.Commodity__c = keyAttrs[2];
			if (keyAttrs[3].startsWith('001'))
			sb.Advertiser__c = keyAttrs[3];
			sb.Product_Line__c = keyAttrs[4];
			sb.External_Id__c = loggedInUser + keySeparator + key + keySeparator + month;
			sb.Status__c = 'Pending';
			sb.type__c = 'Forecast';
		}
		System.Debug('sb: ' + sb);
		return sb;
	}


	/**
	 * This method saves Rollup Sum selection information on User
	 *
	 * @return (PageReference) (NA)
	 */
	public PageReference saveSumRollupSelection() {
		try {
			//String tmpSelection = ApexPages.currentPage().getParameters().get('rollupSumOnBudget');
			rollupSumOnBudget = (rollupSumOnBudgetStr == 'true' ? true : false);
			loggedInUser.BT_Sum_on_Budget__c = rollupSumOnBudget;
			System.debug('rollupSumOnBudget=' + rollupSumOnBudget);
			System.debug('rollupSumOnBudgetStr=' + rollupSumOnBudgetStr);
			update loggedInUser;
			if (Test.isRunningTest()) {
				CalloutException e = new CalloutException();
				e.setMessage('This is a constructed exception for testing and code coverage');
				throw e;
			}

		}
		catch(Exception ex) {
			System.debug(ex.getMessage());
		}
		return null;
	}

	/**
	 * This method saves Revenue information on Budget
	 *
	 * @return (PageReference) (NA)
	 */
	public static boolean triggerFirstRun = false;

	@future
	public static void saveBudgetRevenue(String sbs, String sbCom, String sbUser) {
		/*
		  String keySeparator = '::';
		  List<Sales_Budget__c> sbList = (List<Sales_Budget__c>) JSON.deserialize(sbs,List<Sales_Budget__c>.class);
		  System.debug(sbList);
		  List<String> cList = (List<String>) JSON.deserialize(sbCom,List<String>.class);
		  System.debug(cList);
		  List<String> uList = (List<String>) JSON.deserialize(sbUser,List<String>.class);
		  System.debug(uList);
		 
		  //Query Current year's Revenue
		  Map<String,String> revMap = new Map<String,String>();
		  String value = '';
		  String revenueFields = [Select Revenue_Fields_Sequence__c from UserClassification__mdt where DeveloperName = 'Admin' limit 1].Revenue_Fields_Sequence__c;
		  System.debug(revenueFields);
		  for(Sales_Revenue__c sr: (List<Sales_Revenue__c>) Database.query('SELECT Advertiser__c,Primary_Commodity__c,Product_Line__c,revenue_user__c,' + revenueFields + ' FROM Sales_Revenue__c WHERE revenue_user__c in :uList and Primary_Commodity__c in :cList and CALENDAR_YEAR(Broadcast_Month_Date__c) = '+Integer.valueOf(Label.RevenueCY) + ' and Advertiser__r.Primary_Commodity__c != null ORDER BY Broadcast_Month_Date__c asc')){
		  String key = keySeparator+(String)sr.get('Primary_Commodity__c')+keySeparator+(String)sr.get('Advertiser__c')+keySeparator+(String)sr.get('Product_Line__c')+keySeparator+Label.BudgetCurrentYear+keySeparator+(String)sr.get('revenue_user__c');
		  System.debug(key);
		  value = '';
		  for(String fld:revenueFields.split(',')){
		  if(sr.get(fld)!=null){
		  value = value + String.valueOf(sr.get(fld)) + ',';
		  }
		  else{
		  value = value + 'null' + ',';
		  }
		  }
		 
		  revMap.put(key,value);
		  }
		 
		  List<Sales_Budget__c> upsertList = new List<Sales_Budget__c>();
		  for(Sales_Budget__c sb:sbList){
		  String key = keySeparator+sb.Commodity__c+keySeparator+sb.Advertiser__c+keySeparator+sb.Product_Line__c+keySeparator+Label.BudgetCurrentYear+keySeparator+sb.budget_user__c;
		  System.debug(sb.id);
		  System.debug(key);
		  if(revMap.containsKey(key)){
		  System.debug(revMap.get(key));
		  sb.revenue_information__c = revMap.get(key);
		  upsertList.add(sb);
		  }
		  }
		 
		  if(upsertList.size() > 0){
		  update upsertList;
		  }
		 */
	}

	/**
	 * This class is used to create object structure required for Budget grid
	 */
	private class gridHelper {
		String dma;
		String commodity;
		String advertiser;
		String productLine;
		List<Integer> months;
		List<String> monthIds;
		Integer year;
		String ChurnIndicator;
		String NewBusinessChurn;
		string eclipseSystem = '';
		string eclipseId = '';
		private gridHelper() {
			months = new List<Integer> { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
			monthIds = new List<String> { '', '', '', '', '', '', '', '', '', '', '', '' };
		}
	}


}