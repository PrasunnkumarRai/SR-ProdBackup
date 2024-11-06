global without sharing class BudgetingToolAdjustOppBudgetController {
    public User loggedInUser {
        get;
        set;
    }
    public String loggedInUserBudgetType {
        get;
        set;
    }
    public String loggedInBudgetView {
        get;
        set;
    }
    public String loggedInUserProductLines {
        get;
        set;
    }
    public Boolean loggedInUserImpersonate {
        get;
        set;
    }
    public transient String gridDef {
        get;
        set;
    }
    public transient String jsonData {
        get;
        set;
    }
    public transient String jsonString {
        get;
        set;
    }
    public List < String > userList {
        get;
        set;
    }
    public Map < String, String > userListNameMap {
        get;
        set;
    }
    public Map < String, String > userMap {
        get;
        set;
    }
    public static String alertMessage {
        get;
        set;
    }
    public static String userParam {
        get;
        set;
    }
    public static String impParam {
        get;
        set;
    }
    public String totalsLabel {
        get;
        set;
    }
    public String pendingLabel {
        get;
        set;
    }
    public String projectedLabel {
        get;
        set;
    }
    public String Q3FCSTLabel {
        get;
        set;
    }
    public String PrevYearOTBLabel {
        get;
        set;
    }
    public String totalsPrevYearOTBLabel {
        get;
        set;
    }
    public String CurrYearOTBLabel {
        get;
        set;
    }
    public String TotalsCurrYearOTBLabel {
        get;
        set;
    }
    public String ChurnYearLabel {
        get;
        set;
    }
    public String NewBusinessLabel {
        get;
        set;
    }
    public String NewBusinessYearLabel {
        get;
        set;
    }
    public String TotalsNewBusinessLabel {
        get;
        set;
    }
    public Boolean rollupSumOnBudget {
        get;
        set;
    }
    public String lastYear {
        get;
        set;
    }
    public String nextYear {
        get;
        set;
    }
    public String salesProbSelected {
        get;
        set;
    }
    public String selectedYear {
        get;
        set;
    }
    public String currentYear {
        get;
        set;
    }
    public String selecteYear {
        get;
        set;
    }
    public String loggedUserId {
        get;
        set;
    }
    public String loggedUserProfile {
        get;
        set;
    }
    public enum Month {
        Jan,
        Feb,
        Mar,
        Apr,
        May,
        Jun,
        Jul,
        Aug,
        Sep,
        Oct,
        Nov,
        Dec
    }
    transient BudgetingToolModel tgm;
    Map < Id, Account > accMap;
    Map < String, String > teamMap;
    transient Map < String, gridHelper > budgetKeys = new Map < String, gridHelper > ();
    transient Set < Id > advertiserIdList = new Set < Id > ();
    transient Map < String, gridHelper > revenuePYMap = new Map < String, gridHelper > ();
    transient Map < String, gridHelper > revenueCYMap = new Map < String, gridHelper > ();
    transient Map < String, gridHelper > forecastMap = new Map < String, gridHelper > ();
    transient Map < String, gridHelper > projectedMap = new Map < String, gridHelper > ();
    transient Map < String, gridHelper > oppBudgetAdjMap = new Map < String, gridHelper > ();
    transient Map < String, gridHelper > nbucOppBudgetAdjMap = new Map < String, gridHelper > ();
    transient public static String keySeparator = '::';
	String[] ForecastingToolProfilesForAdmin;
    /**
     * Constructor.
     *
     * @param  (none) (NA)
     * @return (none) (NA)
     */
    public BudgetingToolAdjustOppBudgetController() {
        loggedUserId = UserInfo.getUserId();
        userParam = UserInfo.getUserId();
        impParam = UserInfo.getUserId();
        salesProbSelected = '100';
		ForecastingToolProfilesForAdmin = Label.ForecastingToolProfilesForAdmin.split(',');
        if (ApexPages.currentPage() != null) {
            userParam = ApexPages.currentPage().getParameters().get('userparam');
            userParam = String.escapeSingleQuotes(String.isBlank(userParam) ? UserInfo.getUserId() : userParam);
            impParam = ApexPages.currentPage().getParameters().get('impparam');
            impParam = String.escapeSingleQuotes(String.isBlank(impParam) ? UserInfo.getUserId() : impParam);
            selecteYear = ApexPages.currentPage().getParameters().get('selecteyear');
        }
        Schema.DescribeFieldResult fieldResult = Opportunity.Sales_Probability__c.getDescribe();
        List < Schema.PicklistEntry > picklistValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: picklistValues) {
            if (salesProbSelected != '') {
                salesProbSelected += ',';
            }
            salesProbSelected += p.getValue();
        }
        currentYear = String.valueOf(Date.today().year());
        nextYear = String.valueOf(Date.today().year() + 1);
        if (selecteYear == '' || selecteYear == null) {
            selecteYear = currentYear;
        }
        lastYear = String.valueOf(Integer.valueof(selecteYear) - 1);
        selectedYear = currentYear;
        totalsLabel = 'TOTALS';
        pendingLabel = 'Pending';
        projectedLabel = 'Projected';
        PrevYearOTBLabel = lastYear + ' ' + 'OTB';
        totalsPrevYearOTBLabel = lastYear + ' ' + 'Total OTB';
        CurrYearOTBLabel = String.valueOf(Integer.valueof(selecteYear)) + ' ' + 'OTB';
        TotalsCurrYearOTBLabel = selecteYear + ' ' + 'Total OTB';
        ChurnYearLabel = selecteYear + ' ' + 'Unknown Churn';
        NewBusinessLabel = 'New Business/ Unknown Churn';
        NewBusinessYearLabel = selecteYear + ' ' + 'New Business';
        TotalsNewBusinessLabel = selecteYear + ' ' + 'Total New Business';
        rollupSumOnBudget = true;
        alertMessage = '';
        userList = new List < String > ();
        userListNameMap = new Map < String, String > ();
        userMap = new Map < String, String > ();
        accMap = new Map < Id, Account > ();

        if (selecteYear != null) {
            selectedYear = String.escapeSingleQuotes(String.isBlank(selecteYear) ? '' : selecteYear);
        } else {
            selectedYear = currentYear;
        }
        if (String.isNotBlank(userParam) && String.isNotBlank(impparam)) {
            buildUserContext(String.escapeSingleQuotes(String.isBlank(userParam) ? '' : userParam), String.escapeSingleQuotes(String.isBlank(impparam) ? '' : impparam));
        } else {
            buildUserContext(UserInfo.getUserId(), UserInfo.getUserId());
        }
        if ((loggedInUserBudgetType == 'Local' || loggedInUserBudgetType == 'Local Special') && String.isBlank(loggedInUserProductLines) && loggedInBudgetView == 'Executive') {
            alertMessage = 'Please contact your system administrator for creating Budget profile.';
        } else {
            alertMessage = '';
            showAEGrid();
        }
    }

    /**
     * This method builds the logged in user's context for grid methods
     *
     * @param  (none) (NA)
     * @return (void) (NA)
     */
    public void buildUserContext(String prmuserid, String impUserId) {
        System.debug('selected/primaryuser : DOS/secondaryuser = ' + prmuserid + ' : ' + impUserId);
        List < String > uList = new List < String > ();

        Map<Id, User> users = new Map<Id, User>([SELECT Id, Name, Profile.Name, HR_Manager__c, HR_Manager__r.Email, HR_Manager__r.Name, Budget_Type__c, Budget_Product_Lines__c, Budget_DMA__c, HR_Level__c, BT_Sum_on_Budget__c, Forecasting_Tool_Account_Limit__c 
                                                    FROM User WHERE Id IN :new List<String>{prmUserId, impUserId}]);
        User impUserDetail = users.get(impUserId);
        loggedInUser = users.get(prmUserId);
        processUserDetails(impUserDetail, loggedInUser);

        List<UserClassification__mdt> userClassifications = [SELECT Id, DeveloperName, MasterLabel, User_Profiles__c, Budget_View__c, Impersonate_Capability__c FROM UserClassification__mdt];
        processUserClassifications(userClassifications, loggedInUser.Profile.Name);

        processUsersByBudgetView(loggedInBudgetView, loggedInUser.Id, uList);

        userList.add(loggedInUser.name);
        teamMap = new Map < String, String > (userMap);
        teamMap.put(Label.BudgetNewBusinessAcountId, 'New Business/Unknown Churn');
        userListNameMap.put(loggedInUser.name, loggedInUser.id);
        userMap.put(loggedInUser.id, loggedInUser.name);
    }

    private void processUserDetails(User impUserDetail, User loggedInUser) {
        userMap.put(impUserDetail.id, impUserDetail.name);
        userMap.put(loggedInUser.id, loggedInUser.name);
        loggedUserProfile = loggedInUser.profile.name;
        loggedInUserBudgetType = impUserDetail.Budget_Type__c;
        loggedInUserProductLines = impUserDetail.Budget_Product_Lines__c;
        rollupSumOnBudget = impUserDetail.BT_Sum_on_Budget__c;
    }

    private void processUserClassifications(List<UserClassification__mdt> uclassifications, String profileName) {
        for (UserClassification__mdt uc:uclassifications) {
            if (uc.user_profiles__c.contains(profileName)) {
                loggedInBudgetView = uc.Budget_View__c;
                loggedInUserImpersonate = uc.Impersonate_Capability__c;
                break;
            } else {
                loggedInBudgetView = 'NA';
            }
        }
    }

    private void processUsersByBudgetView(String budgetView, Id loggedInUserId, List < String > uList) {
        switch on budgetView {
            when 'Leadership' {
                processManagerView(loggedInUserId, uList);
                processLeadershipView(loggedInUserId, uList);
            }
            when 'Admin' {
                processAdminView(uList);
            }
        }
    }

    private void processManagerView(Id loggedInUserId, List<String> uList) {
        for (User ru: [Select id, name, profile.name, HR_Manager__r.email, HR_Manager__r.name, Budget_Type__c, Budget_Product_Lines__c, HR_Level__c
                from User
                where hr_manager__c =: loggedInUser.id
                order by name
            ]) {
            userList.add(ru.name);
            userListNameMap.put(ru.name, ru.id);
            userMap.put(ru.id, ru.name);
            uList.add(ru.id);
            System.debug('usermap' + userMap);
            System.debug('userList' + userList);
        }
    }
    
    private void processLeadershipView(Id loggedInUserId, List<String> uList) {    
        List < String > nList = new List < String > ();
        Integer i = 0;
        Integer countI = 0;
        do {
            i = 0;
            nList = new List < String > ();
            for (User ru: [Select id, name, profile.name, HR_Manager__r.email, HR_Manager__r.name, Budget_Type__c, Budget_Product_Lines__c, HR_Level__c
                    from User
                    where HR_Manager__c in: uList
                    order by HR_Manager__r.name, name
                ]) {
                if (userList.size() <= 998) {
                    userList.add(ru.HR_Manager__r.name + ' -- ' + ru.name);
                    userListNameMap.put(ru.HR_Manager__r.name + ' -- ' + ru.name, ru.id);
                    userMap.put(ru.id, ru.name);
                }
                i++;
                nList.add(ru.id);
            }

            uList = new List < String > ();
            uList.addAll(nList);
            System.debug(uList);
            countI++;
        }
        while (i > 0);

        System.debug(countI);
    }
    
    private void processAdminView(List<String> uList) {
        for (User adminU: [Select id, name, profile.name,
                HR_Manager__r.email, HR_Manager__r.name, Budget_Type__c, Budget_Product_Lines__c, HR_Level__c
                from User where profile.name IN :ForecastingToolProfilesForAdmin
                and IsActive = true
            ]) {
            userList.add(adminU.name);
            userListNameMap.put(adminU.name, adminU.id);
            userMap.put(adminU.id, adminU.name);
            uList.add(adminU.id);
            System.debug('usermap' + userMap);
            System.debug('userList' + userList);
        }
    }

    /**
     * This method builds JSON for grid metadata and data rows for an AE user
     *
     * @param  (none) (NA)
     * @return (pageReference) (returns control back to grid page)
     */
    public pageReference showAEGrid() {
        System.debug('salesProbSelected: ' + salesProbSelected);
        tgm = buildAETreeData();
        String rollupFormulaStr = 'sum()';
        // String jsStr = '<script>Grids.HandleChange = function(Grid, Row, Col) { alert(\'hi: \'+ Col)}</script>';
        gridDef = '';
        gridDef = '<Grid ><Panel Visible=\'0\'/><Cfg MaxVScroll=\'500\' ExactSize=\'0\' ExportFormat=\'xlsx\' ExportName=\'BudgetReport\' ExportType=\'Outline,Indent,FixedRows,StyleRows,StyleCols,Size,ForceBorder,TextType,Strings,TreeGrid\' ExportCols =\'0\' CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' Deleting=\'0\' ChildPaging=\'2\' StandardFilter=\'3\' Levels=\'2\' Expanded=\'0\' FormulaRelative=\'1\' NoHScroll=\'1\' NoVScroll=\'1\' Code=\'STREFSXJSLTIED\' MainCol=\'Account\' Delete=\'0\' FullId=\'1\' Dragging =\'0\' Dropping=\'0\' Adding=\'0\'/><Cols><C CanExport=\'1\' Name=\'Account\' TextStyle=\'1\' Width=\'360\' CanEdit=\'0\' CanSort=\'0\'/></Cols>< Fixed=\'1\' id=\'id\' AccountLevels=\'2\' AccountTextStyle=\'2\' AChecked=\' \' Account =\' Advertiser | Account Executive\' AccountCanEdit=\'0\' ChurnIndicator=\'Churn Indicator\'/>';
        gridDef += '<Def><D Name=\'t\' CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' Calculated=\'1\' Format=\'#\' TotalFormat=\'$#,##0;($#,##0)\' Q1Format=\'$#,##0;($#,##0)\' Q2Format=\'$#,##0;($#,##0)\' Q3Format=\'$#,##0;($#,##0)\' Q4Format=\'$#,##0;($#,##0)\' JanFormat=\'$#,##0;($#,##0)\' FebFormat=\'$#,##0;($#,##0)\' MarFormat=\'$#,##0;($#,##0)\' AprFormat=\'$#,##0;($#,##0)\' MayFormat=\'$#,##0;($#,##0)\' JunFormat=\'$#,##0;($#,##0)\' JulFormat=\'$#,##0;($#,##0)\' AugFormat=\'$#,##0;($#,##0)\' SepFormat=\'$#,##0;($#,##0)\' OctFormat=\'$#,##0;($#,##0)\' NovFormat=\'$#,##0;($#,##0)\' DecFormat=\'$#,##0;($#,##0)\' ';
        gridDef += 'JanFormula=\'' + rollupFormulaStr + '\'  FebFormula=\'' + rollupFormulaStr + '\'  MarFormula=\'' + rollupFormulaStr + '\'  AprFormula=\'' + rollupFormulaStr + '\'  MayFormula=\'' + rollupFormulaStr + '\'  JunFormula=\'' + rollupFormulaStr + '\'  JulFormula=\'' + rollupFormulaStr + '\'  AugFormula=\'' + rollupFormulaStr + '\'  SepFormula=\'' + rollupFormulaStr + '\'  OctFormula=\'' + rollupFormulaStr + '\'  NovFormula=\'' + rollupFormulaStr + '\'  DecFormula=\'' + rollupFormulaStr + '\' ';
        gridDef += ' Recalc=\'256\' R.CanFilter = \'0\' Node.CanFilter = \'1\'/>';
        gridDef += '<D Name=\'tot\' CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' Calculated=\'1\' Format=\'#\' TotalFormat=\'$#,##0;($#,##0)\' Q1Format=\'$#,##0;($#,##0)\' Q2Format=\'$#,##0;($#,##0)\' Q3Format=\'$#,##0;($#,##0)\' Q4Format=\'$#,##0;($#,##0)\' JanFormat=\'$#,##0;($#,##0)\' FebFormat=\'$#,##0;($#,##0)\' MarFormat=\'$#,##0;($#,##0)\' AprFormat=\'$#,##0;($#,##0)\' MayFormat=\'$#,##0;($#,##0)\' JunFormat=\'$#,##0;($#,##0)\' JulFormat=\'$#,##0;($#,##0)\' AugFormat=\'$#,##0;($#,##0)\' SepFormat=\'$#,##0;($#,##0)\' OctFormat=\'$#,##0;($#,##0)\' NovFormat=\'$#,##0;($#,##0)\' DecFormat=\'$#,##0;($#,##0)\' ';
        gridDef += fmtTotalFormula('Jan') + fmtTotalFormula('Feb') + fmtTotalFormula('Mar') + fmtTotalFormula('Apr') + fmtTotalFormula('May') + fmtTotalFormula('Jun') + fmtTotalFormula('Jul') + fmtTotalFormula('Aug') + fmtTotalFormula('Sep') + fmtTotalFormula('Oct') + fmtTotalFormula('Nov') + fmtTotalFormula('Dec');
        gridDef += ' Recalc=\'256\' R.CanFilter = \'0\' Node.CanFilter = \'1\'/>';
        gridDef += '<D Name=\'totp\' CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' Calculated=\'1\' Format=\'#\' TotalFormat=\'0%\' Q1Format=\'0%\' Q2Format=\'0%\' Q3Format=\'0%\' Q4Format=\'0%\' JanFormat=\'0%\' FebFormat=\'0%\' MarFormat=\'0%\' AprFormat=\'0%\' MayFormat=\'0%\' JunFormat=\'0%\' JulFormat=\'0%\' AugFormat=\'0%\' SepFormat=\'0%\' OctFormat=\'0%\' NovFormat=\'0%\' DecFormat=\'0%\' Q1Format=\'0%\' Q2Format=\'0%\' Q3Format=\'0%\' Q4Format=\'0%\' TotalFormat=\'0%\' ';
        // gridDef += fmtTotalFormula('Jan') + fmtTotalFormula('Feb') + fmtTotalFormula('Mar') + fmtTotalFormula('Apr') + fmtTotalFormula('May') + fmtTotalFormula('Jun') + fmtTotalFormula('Jul') + fmtTotalFormula('Aug') + fmtTotalFormula('Sep') + fmtTotalFormula('Oct') + fmtTotalFormula('Nov') + fmtTotalFormula('Dec');
        // gridDef += fmtTotalFormula('Total') + fmtTotalFormula('Q1') + fmtTotalFormula('Q2') + fmtTotalFormula('Q3') + fmtTotalFormula('Q4');
        gridDef += ' Recalc=\'256\' R.CanFilter = \'0\' Node.CanFilter = \'1\'/>';
        gridDef += '<D Name=\'prod\' CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' Calculated=\'1\' Format=\'#\' TotalFormat=\'$#,##0;($#,##0)\' Q1Format=\'$#,##0;($#,##0)\' Q2Format=\'$#,##0;($#,##0)\' Q3Format=\'$#,##0;($#,##0)\' Q4Format=\'$#,##0;($#,##0)\' JanFormat=\'$#,##0;($#,##0)\' FebFormat=\'$#,##0;($#,##0)\' MarFormat=\'$#,##0;($#,##0)\' AprFormat=\'$#,##0;($#,##0)\' MayFormat=\'$#,##0;($#,##0)\' JunFormat=\'$#,##0;($#,##0)\' JulFormat=\'$#,##0;($#,##0)\' AugFormat=\'$#,##0;($#,##0)\' SepFormat=\'$#,##0;($#,##0)\' OctFormat=\'$#,##0;($#,##0)\' NovFormat=\'$#,##0;($#,##0)\' DecFormat=\'$#,##0;($#,##0)\' ';
        gridDef += formatMonthRollupFormula('Jan') + formatMonthRollupFormula('Feb') + formatMonthRollupFormula('Mar') + formatMonthRollupFormula('Apr') + formatMonthRollupFormula('May') + formatMonthRollupFormula('Jun') + formatMonthRollupFormula('Jul') + formatMonthRollupFormula('Aug') + formatMonthRollupFormula('Sep') + formatMonthRollupFormula('Oct') + formatMonthRollupFormula('Nov') + formatMonthRollupFormula('Dec');
        gridDef += ' Recalc=\'256\' R.CanFilter = \'0\' Node.CanFilter = \'1\'/>';
        gridDef += formatDef('ldollar');
        gridDef += formatDef('lneg');
        gridDef += formatDef('lpct');
        gridDef += formatDef('lplain');
        gridDef += formatDef('loppbudAdj');
        gridDef += '<D Name=\'fcst\' CalcOrder=\'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec,Q1,Q2,Q3,Q4,Total\' Calculated=\'1\' Format=\'#\' TotalFormat=\'$#,##0;($#,##0)\' Q1Format=\'$#,##0;($#,##0)\' Q2Format=\'$#,##0;($#,##0)\' Q3Format=\'$#,##0;($#,##0)\' Q4Format=\'$#,##0;($#,##0)\' JanFormat=\'$#,##0;($#,##0)\' FebFormat=\'$#,##0;($#,##0)\' MarFormat=\'$#,##0;($#,##0)\' AprFormat=\'$#,##0;($#,##0)\' MayFormat=\'$#,##0;($#,##0)\' JunFormat=\'$#,##0;($#,##0)\' JulFormat=\'$#,##0;($#,##0)\' AugFormat=\'$#,##0;($#,##0)\' SepFormat=\'$#,##0;($#,##0)\' OctFormat=\'$#,##0;($#,##0)\' NovFormat=\'$#,##0;($#,##0)\' DecFormat=\'$#,##0;($#,##0)\' ';
        // gridDef += formatMonthRollupFormula('Jan', Q3FCSTLabel) + formatMonthRollupFormula('Feb', Q3FCSTLabel) + formatMonthRollupFormula('Mar', Q3FCSTLabel) + formatMonthRollupFormula('Apr', Q3FCSTLabel) + formatMonthRollupFormula('May', Q3FCSTLabel) + formatMonthRollupFormula('Jun', Q3FCSTLabel) + formatMonthRollupFormula('Jul', Q3FCSTLabel) + formatMonthRollupFormula('Aug', Q3FCSTLabel) + formatMonthRollupFormula('Sep', Q3FCSTLabel) + formatMonthRollupFormula('Oct', Q3FCSTLabel) + formatMonthRollupFormula('Nov', Q3FCSTLabel) + formatMonthRollupFormula('Dec', Q3FCSTLabel);
        gridDef += ' Recalc=\'256\' R.CanFilter = \'0\' Node.CanFilter = \'1\'/>';
        gridDef += '<D Name=\'R\' Recalc=\'256\' DefParent=\'Node\'/><D Name=\'Node\' Recalc=\'256\' DefEmpty=\'R\' Color=\'#EFE\'/></Def>';
        gridDef += '<Toolbar Cells=\'ExpandAll,CollapseAll,Export,Columns,Cfg\' Scales=\'0\' Debug=\'\' Help=\'0\' Export=\'1\'  /><Head><Filter AccountCaseSensitive=\'0\' AccountRange=\'1\' AccountButton=\'\' AccountDefaults=\'|*FilterOff|*RowsAll\' Expanded=\'3\' OnFilterFinish=\'Grid.ExpandAll();\'/></Head><Solid></Solid></Grid>';

        jsonData = '';
        jsonData = System.JSON.serialize(tgm);
        jsonData = jsonData.substring(1, jsonData.length());
        System.debug('jsonData' + jsonData);
        String jsonHeader = '{Cols: [{ Name:\'Jan\', Type:\'Float\',Format:\'#\',CanSort:\'0\',CanEdit:\'0\',CanEmpty:\'1\',Width:\'110\',CanHide:\'1\', Visible:' + hideShowCol(1) + '},{ Name:\'Feb\', Type:\'Float\',Format:\'#\',CanSort:\'0\',CanEdit:\'0\',CanEmpty:\'1\',Width:\'110\',CanHide:\'1\', Visible:' + hideShowCol(2) + '},{ Name:\'Mar\',Type:\'Float\',Format:\'#\',CanSort:\'0\',CanEdit:\'0\',CanEmpty:\'1\',Width:\'110\',CanHide:\'1\', Visible:' + hideShowCol(3) + '},{ Name:\'Apr\', Type:\'Float\',Format:\'#\' ,CanSort:\'0\',CanEdit:\'0\',CanEmpty:\'1\',Width:\'110\',CanHide:\'1\', Visible:' + hideShowCol(4) + '},{ Name:\'May\', Type:\'Float\',Format:\'#\',CanSort:\'0\',CanEdit:\'0\',CanEmpty:\'1\',Width:\'110\',CanHide:\'1\', Visible:' + hideShowCol(5) + '},{ Name:\'Jun\',Type:\'Float\',Format:\'#\',CanSort:\'0\',CanEdit:\'0\',CanEmpty:\'1\',Width:\'110\',CanHide:\'1\', Visible:' + hideShowCol(6) + '},{ Name:\'Jul\', Type:\'Float\',Format:\'#\' ,CanSort:\'0\',CanEdit:\'0\',CanEmpty:\'1\',Width:\'110\',CanHide:\'1\', Visible:' + hideShowCol(7) + '},{ Name:\'Aug\', Type:\'Float\',Format:\'#\',CanSort:\'0\',CanEdit:\'0\',CanEmpty:\'1\',Width:\'110\',CanHide:\'1\', Visible:' + hideShowCol(8) + '},{ Name:\'Sep\',Type:\'Float\',Format:\'#\',CanSort:\'0\',CanEdit:\'0\',CanEmpty:\'1\',Width:\'110\',CanHide:\'1\', Visible:' + hideShowCol(9) + '},{ Name:\'Oct\', Type:\'Float\',Format:\'#\' ,CanSort:\'0\',CanEdit:\'0\',CanEmpty:\'1\',Width:\'110\',CanHide:\'1\', Visible:' + hideShowCol(10) + '},{ Name:\'Nov\', Type:\'Float\',Format:\'#\',CanSort:\'0\',CanEdit:\'0\',CanEmpty:\'1\',Width:\'110\',CanHide:\'1\', Visible:' + hideShowCol(11) + '},{ Name:\'Dec\',Type:\'Float\',Format:\'#\',CanSort:\'0\',CanEdit:\'0\',CanEmpty:\'1\',Width:\'110\',CanHide:\'1\', Visible:' + hideShowCol(12) + '},{ Name:\'Total\',Type:\'Float\', Formula:\'(isNaN(parseFloat(Jan))?0:parseFloat(Jan))+(isNaN(parseFloat(Feb))?0:parseFloat(Feb))+(isNaN(parseFloat(Mar))?0:parseFloat(Mar))+(isNaN(parseFloat(Apr))?0:parseFloat(Apr))+(isNaN(parseFloat(May))?0:parseFloat(May))+(isNaN(parseFloat(Jun))?0:parseFloat(Jun))+(isNaN(parseFloat(Jul))?0:parseFloat(Jul))+(isNaN(parseFloat(Aug))?0:parseFloat(Aug))+(isNaN(parseFloat(Sep))?0:parseFloat(Sep))+(isNaN(parseFloat(Oct))?0:parseFloat(Oct))+(isNaN(parseFloat(Nov))?0:parseFloat(Nov))+(isNaN(parseFloat(Dec))?0:parseFloat(Dec))\',CanSort:\'0\',CanEdit:\'0\',Width:\'110\',Format:\'$#,##0;($#,##0)\',Color:\'#f4f4f4\'}],';
        jsonString = '';
        jsonString = jsonHeader + jsonData.replace('"', '\'');
        return null;
    }

    private Integer hideShowCol(Integer month) {
        Integer currMonth = Datetime.now().month();
        if(month<=Math.Mod(currMonth+3,12)){
            return 1;
        }
        else{
            return 0;
        }
        // if (month < currMonth) {
        //     return 0;
        // } else {
        //     return 1;
        // }
    }

    /**
     * This method builds JSON for grid data rows for an AE user
     *
     * @param  (none) (NA)
     * @return (BudgetingToolModel) (budget grid data model instance with AE rows)
     */
    public BudgetingToolModel buildAETreeData() {
        queryAETreeData();
        BudgetingToolModel objtgm = new BudgetingToolModel();

        List < BudgetingToolModel.Body > tgmbList = new List < BudgetingToolModel.Body > ();
        List < BudgetingToolModel.Items_Pro > tgmiAccList = new List < BudgetingToolModel.Items_Pro > ();
        List < BudgetingToolModel.Items_Pro > tgmiProList = new List < BudgetingToolModel.Items_Pro > ();
        List < BudgetingToolModel.Items_Led > tgmiLedList = new List < BudgetingToolModel.Items_Led > ();
        List < Integer > blankMonths = new List < Integer > {0,0,0,0,0,0,0,0,0,0,0,0};
        Map < String, List < BudgetingToolModel.Items_Pro >> accBMap = new Map < String, List < BudgetingToolModel.Items_Pro >> ();
        accMap = new Map < Id, Account > ();
        setBTModelHeaders(tgmbList, tgmiAccList);
        
        System.debug('advertiserIdList ' + advertiserIdList);

        for (Account acc: [Select id, name from account where id in: advertiserIdList]) {
            acc.name = acc.name.replace('\'', '');
            acc.name = acc.name.replace('\"', '');
            accMap.put(acc.id, acc);
        }
        system.debug('budgetKeys size: ' +budgetKeys.size());
        for (String s: budgetKeys.keySet()) {
            tgmiLedList.add(AddLed(PrevYearOTBLabel, 'c', 0, (revenuePYMap.get(s) != null ? revenuePYMap.get(s).months : blankMonths), '', s + keySeparator + 'RevenuePY', ''));
            tgmiLedList.add(AddLed(CurrYearOTBLabel, 'c', 0, (revenueCYMap.get(s) != null ? revenueCYMap.get(s).months : blankMonths), '', s + keySeparator + 'RevenueCY', ''));
            tgmiLedList.add(AddLed(pendingLabel, 'c', 1, (forecastMap.get(s) != null ? forecastMap.get(s).months : blankMonths), '', s + keySeparator + 'OppBudgetPending', ''));
            tgmiLedList.add(AddLed(projectedLabel, 'c', 1, (projectedMap.get(s) != null ? projectedMap.get(s).months : blankMonths), '', s + keySeparator + 'OppBudgetProjected', ''));
            //if (loggedInBudgetView != 'Leadership' && impParam != userParam) {
                tgmiLedList.add(AddLed('+/- Forecast Adjustment', 'c', 1, oppBudgetAdjMap.get(s) != null ? oppBudgetAdjMap.get(s).months : blankMonths, '', s + keySeparator + 'OppBudgetAdj', ''));
            //}

            tgmiProList.add(AddProduct(budgetKeys.get(s).ProductLine, tgmiLedList));
            tgmiLedList = new List < BudgetingToolModel.Items_Led > ();
            // tgmiLedList.clear();

            String advertiserKey = budgetKeys.get(s).Advertiser;
            Boolean shouldUpdateAccBMap = (loggedInBudgetView == 'Leadership' && impParam == userParam) == true ? teamMap.containsKey(advertiserKey) : (accMap.get(advertiserKey) != null);
            if (shouldUpdateAccBMap) {
                updateAccBMap(advertiserKey, tgmiProList, accBMap);
            }
            tgmiProList = new List < BudgetingToolModel.Items_Pro > ();
            // tgmiProList.clear();
        }

        if (loggedInBudgetView == 'Leadership' && impParam == userParam) {
            tgmiProList = new List < BudgetingToolModel.Items_Pro > ();
            System.debug('loggedInUser.Budget_Product_Lines__c.split :::' + loggedInUser.Budget_Product_Lines__c.split(';'));
            for (String pLine: loggedInUser.Budget_Product_Lines__c.split(';')) {
                tgmiLedList = new List < BudgetingToolModel.Items_Led > ();
                String key = keySeparator + Label.BudgetNewBusinessAcountId + keySeparator + pLine + keySeparator + Label.BudgetCurrentYear;
                if (nbucOppBudgetAdjMap.containsKey(key)) {
                    tgmiLedList.add(AddLed('+/- Forecast Adjustment', 'c', 1, nbucOppBudgetAdjMap.get(key).months, '', keySeparator + Label.BudgetNewBusinessAcountId + keySeparator + pLine + keySeparator + 'NBUCOppBudgetAdj', ''));
                } else {
                    tgmiLedList.add(AddLed('+/- Forecast Adjustment', 'c', 1, blankMonths, '', keySeparator + Label.BudgetNewBusinessAcountId + keySeparator + pLine + keySeparator + 'NBUCOppBudgetAdj', ''));
                }
                tgmiProList.add(AddProduct(pLine, tgmiLedList));
            }
            accBMap.put(Label.BudgetNewBusinessAcountId, tgmiProList);
        }
        for (String s: accBMap.keyset()) {
            if (loggedInBudgetView == 'Leadership' && impParam == userParam) {
                tgmbList.add(AddAccount(teamMap.get(s), accBMap.get(s)));
            } else {
                tgmbList.add(AddAccount(accMap.get(s).Name, accBMap.get(s)));
            }
        }

        objtgm.body = new List < List < BudgetingToolModel.Body >> ();
        objtgm.body.add(tgmbList);
        return objtgm;
    }

    private void setBTModelHeaders(List < BudgetingToolModel.Body > tgmbList, List < BudgetingToolModel.Items_Pro > tgmiAccList){
        BudgetingToolModel.Items_Pro tgmiAccTmp = new BudgetingToolModel.Items_Pro();

        tgmiAccTmp = new BudgetingToolModel.Items_Pro();
        tgmiAccTmp.Account = totalsPrevYearOTBLabel;
        tgmiAccTmp.Def = 'tot';
        tgmiAccList.add(tgmiAccTmp);

        tgmiAccTmp = new BudgetingToolModel.Items_Pro();
        tgmiAccTmp.Account = TotalsCurrYearOTBLabel;
        tgmiAccTmp.Def = 'tot';
        tgmiAccList.add(tgmiAccTmp);

        tgmiAccTmp = new BudgetingToolModel.Items_Pro();
        tgmiAccTmp.Account = 'Total Pending';
        tgmiAccTmp.Def = 'tot';
        tgmiAccList.add(tgmiAccTmp);

        tgmiAccTmp = new BudgetingToolModel.Items_Pro();
        tgmiAccTmp.Account = 'Total Projected';
        tgmiAccTmp.Def = 'tot';
        tgmiAccList.add(tgmiAccTmp);

        tgmiAccTmp = new BudgetingToolModel.Items_Pro();
        tgmiAccTmp.Account = 'Total +/- Forecast Adjustment';
        tgmiAccTmp.Def = 'tot';
        tgmiAccList.add(tgmiAccTmp);

        BudgetingToolModel.Body commTmp = new BudgetingToolModel.Body();
        commTmp.Account = totalsLabel;
        commTmp.Def = '';
        commTmp.Items = tgmiAccList;
        tgmbList.add(commTmp);
    }

    private void updateAccBMap(String advertiserKey, List<BudgetingToolModel.Items_Pro> tgmiProList, Map < String, List < BudgetingToolModel.Items_Pro >> accBMap) {
        if (accBMap.containsKey(advertiserKey)) {
            accBMap.get(advertiserKey).addAll(tgmiProList);
        } else {
            accBMap.put(advertiserKey, tgmiProList);
        }
    }
    

    /**
     * This method queries Salesforce objects required for grid data rows, for an AE user
     *
     * @param  (none) (NA)
     * @return (void) (NA)
     */
    public void queryAETreeData() {
        try {
            List < Revenue_Aggregate__c > pyLeadershipRevenues;
            List < Revenue_Aggregate__c > cyLeadershipRevenues;
            List < PZMV_Aggregate__c > pyLeadershipPZMV;
            initializeMaps();
            GridHelper rh = new GridHelper();
            queryAEAccTeamData(rh);
            string key;
            System.debug('loggedInBudgetView :::: ' + loggedInBudgetView);
            if (loggedInBudgetView == 'Leadership' && impParam == userParam) {
                processLSMAndDOSData(rh,pyLeadershipRevenues,cyLeadershipRevenues,pyLeadershipPZMV,key);
            } else {
                //Query Previous year's Revenue
                for (AggregateResult pyRev: [SELECT Advertiser__c, sum(Net_Projected_Amount__c) amount, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year
                        FROM Revenue__c
                        WHERE Account_Executive__c =: impParam 
                        AND (Source__c='WO' OR (Net_Projected_Amount__c > 0 AND Revenue_Type__c IN ('Core','National Core'))) AND
                        CALENDAR_YEAR(Broadcast_Month_Date__c) =: Integer.valueof(selectedYear) - 1 
                        group by Advertiser__r.Name, Advertiser__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c)
                        order by Advertiser__r.Name, Advertiser__c, min(Product_Line_Sequence__c) asc
                    ]) {
                    key = keySeparator + (String) pyRev.get('Advertiser__c') + keySeparator + (String) pyRev.get('Product_Line__c') + keySeparator + Label.BudgetCurrentYear;
                    alignPYRevenues(rh, key, (String) pyRev.get('Product_Line__c'), (String) pyRev.get('Advertiser__c'), (Integer) pyRev.get('year'), (Integer) pyRev.get('mon'), Integer.valueOf((Decimal) pyRev.get('amount')));
                }

                //Query Current year's Revenue
                for (AggregateResult cyRev: [SELECT Advertiser__c, sum(Net_Projected_Amount__c) amount, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year
                        FROM Revenue__c
                        WHERE Account_Executive__c =: impParam   AND (Source__c='WO' OR (Net_Projected_Amount__c > 0 AND Revenue_Type__c IN ('Core','National Core')))
                        AND CALENDAR_YEAR(Broadcast_Month_Date__c) =: Integer.valueof(selectedYear)
                        group by Advertiser__r.Name, Advertiser__c, Product_Line__c, CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c)
                        order by Advertiser__r.Name, Advertiser__c, min(Product_Line_Sequence__c) asc
                    ]) {
                    key = keySeparator + (String) cyRev.get('Advertiser__c') + keySeparator + (String) cyRev.get('Product_Line__c') + keySeparator + Label.BudgetCurrentYear;
                    alignCYRevenues(rh, key, (String) cyRev.get('Product_Line__c'), (String) cyRev.get('Advertiser__c'), (Integer) cyRev.get('year'), (Integer) cyRev.get('mon'),
		             (Decimal) cyRev.get('amount'));
                }

                //Query Current year's Forecast
                //Pending Dollars
                for (PZMV_Aggregate__c pzmv: [SELECT AccountId__c, Amount__c, PrimaryCommodity__c, SysCode__c, Month__c, Year__c, RecordType__c, Product_Line__c
                        FROM PZMV_Aggregate__c
                        WHERE OwnerId__c =: impParam and
                        RecordType__c = 'Linear'
                        and
                        ProposalZoneStatus__c = 'Pending'
                        and
                        ProposalActive__c = true and
                        Year__c =: Integer.valueof(selectedYear)
                        AND(ProposalOppIsClosed__c = false OR ProposalOppIsWon__c = true)
                        AND Amount__c > 0
                        AND SalesProbability__c IN: salesProbSelected.split(',')
                        AND AccountId__c in: advertiserIdList
                    ]) {
                    System.debug('pzmv ' + pzmv);
                    String productLine = pzmv.Product_Line__c;
                    key = keySeparator + pzmv.AccountId__c + keySeparator + productLine + keySeparator + Label.BudgetCurrentYear;
                    rh = new GridHelper();
                    rh.commodity = pzmv.PrimaryCommodity__c;
                    rh.Advertiser = pzmv.AccountId__c;
                    rh.ProductLine = productLine;
                    rh.year = (Integer) pzmv.Year__c;

                    if (forecastMap.containsKey(key)) {
                        forecastMap.get(key).months[(Integer) pzmv.Month__c - 1] += (Decimal) pzmv.Amount__c;
                        rh.months = forecastMap.get(key).months;
                    } else {
                        rh.months[(Integer) pzmv.Month__c - 1] += (Decimal) pzmv.Amount__c;
                    }
                    forecastMap.put(key, rh);
                    budgetKeys.put(key, rh);
                    advertiserIdList.add((Id) pzmv.AccountId__c);
                }

                //Query Current year's Forecast
                //Projected Dollars
                for (PZMV_Aggregate__c pzmv: [SELECT AccountId__c, Amount__c, PrimaryCommodity__c, SysCode__c, Month__c, Year__c, RecordType__c, Product_Line__c
                        FROM PZMV_Aggregate__c
                        WHERE OwnerId__c =: impParam and
                        RecordType__c = 'Opportunity Budget'
                        and
                        ProposalActive__c = true and
                        Year__c =: Integer.valueof(selectedYear)
                        AND(ProposalOppIsClosed__c = false OR ProposalOppIsWon__c = true)
                        AND Amount__c > 0
                        AND SalesProbability__c IN: salesProbSelected.split(',')
                        AND AccountId__c in: advertiserIdList
                    ]) {
                    key = keySeparator + pzmv.AccountId__c + keySeparator + pzmv.Product_Line__c + keySeparator + Label.BudgetCurrentYear;
                    rh = new GridHelper();
                    rh.commodity = pzmv.PrimaryCommodity__c;
                    rh.Advertiser = pzmv.AccountId__c;
                    rh.ProductLine = pzmv.Product_Line__c;
                    rh.year = (Integer) pzmv.Year__c;

                    if (projectedMap.containsKey(key)) {
                        projectedMap.get(key).months[(Integer) pzmv.Month__c - 1] += (Decimal) pzmv.Amount__c;
                        rh.months = projectedMap.get(key).months;
                    } else {
                        rh.months[(Integer) pzmv.Month__c - 1] += (Decimal) pzmv.Amount__c;
                    }
                    projectedMap.put(key, rh);
                    budgetKeys.put(key, rh);
                    advertiserIdList.add((Id) pzmv.AccountId__c);
                }

                //Forecast Adjusted Dollars
                List < AggregateResult > adjustedForecastAE = new List < AggregateResult > ();
                for (AggregateResult pzmv: [SELECT proposal_zone__r.proposal__r.opportunity__r.Account_For_Forecasting_Tool__c accountId, sum(Net_Amount__c) amount, Schedule_Type__c,
                        proposal_zone__r.proposal__r.opportunity__r.account.Primary_Commodity__c cc,
                        CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year,
                        proposal_zone__r.proposal__r.recordtype.name PropRecType
                        FROM Proposal_Zone_Monthly_Value__c
                        WHERE proposal_zone__r.proposal__r.opportunity__r.Owner_For_Forecasting_Tool__c =: impParam
                        AND proposal_zone__r.proposal__r.opportunity__r.accountId =: Label.BudgetNewBusinessAcountId
                        AND proposal_zone__r.proposal__r.recordtype.name = 'Adjust Opportunity Budget'
                        AND proposal_zone__r.proposal__r.Active__c = true
                        AND Year__c =: selectedYear
                        AND Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c IN: salesProbSelected.split(',')
                        AND proposal_zone__r.proposal__r.opportunity__r.Account_For_Forecasting_Tool__c IN: advertiserIdList
                        group by proposal_zone__r.proposal__r.opportunity__r.Account_For_Forecasting_Tool__c, proposal_zone__r.proposal__r.opportunity__r.account.Primary_Commodity__c,
                        CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c),
                        proposal_zone__r.proposal__r.recordtype.name, Schedule_Type__c
                    ]) {
                    String productLine;
                    if (pzmv.get('Schedule_Type__c') == 'Linear') {
                        productLine = 'Linear/News/Sports';
                    } else if (pzmv.get('Schedule_Type__c') == 'Digital') {
                        productLine = 'Digital';
                    } else if (pzmv.get('Schedule_Type__c') == 'Production') {
                        productLine = 'Production';
                    }
                    key = keySeparator + (String) pzmv.get('accountId') + keySeparator + productLine + keySeparator + Label.BudgetCurrentYear;
                    rh = new GridHelper();
                    rh.commodity = (String) pzmv.get('cc');
                    rh.Advertiser = (String) pzmv.get('accountId');
                    rh.ProductLine = productLine;
                    rh.year = (Integer) pzmv.get('year');

                    if (oppBudgetAdjMap.containsKey(key)) {
                        oppBudgetAdjMap.get(key).months[(Integer) pzmv.get('mon') - 1] += (Decimal) pzmv.get('amount');
                        rh.months = oppBudgetAdjMap.get(key).months;
                    } else {
                        rh.months[(Integer) pzmv.get('mon') - 1] += (Decimal) pzmv.get('amount');
                    }
                    oppBudgetAdjMap.put(key, rh);
                    budgetKeys.put(key, rh);
                    advertiserIdList.add((Id) pzmv.get('accountId'));
                }
            }
            SYSTEM.DEBUG('@@@@ revenueCYMap' + revenueCYMap);
            SYSTEM.DEBUG('@@@@ revenuePYMap' + revenuePYMap);
            SYSTEM.DEBUG('@@@@ forecastMap' + forecastMap);
            SYSTEM.DEBUG('@@@@ projectedMap: ' + projectedMap);
            SYSTEM.DEBUG('@@@@ oppBudgetAdjMap: ' + oppBudgetAdjMap);
            SYSTEM.DEBUG('@@@@ nbucOppBudgetAdjMap: ' + nbucOppBudgetAdjMap);
        } catch (Exception ex) {
            System.debug('Exception:::: ' + ex.getMessage());
            System.debug('Exception:::: ' + ex.getLineNumber());
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            system.debug('Exception at line 1638: ' + ex.getMessage() + ' at Line: ' + ex.getLineNumber());
            //create new mail message
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {
                'shubham.gupta@mandsconsulting.com'
            });
            mail.setSubject('Developer script exception from New Spectrum Reach : BudgetingToolNSMGridController : SaveNationalForecast : ');
            mail.setPlainTextBody(ex.getMessage() + ex.getLineNumber());
            //send mail
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                mail
            });
        }
    }

    private void initializeMaps() {
        budgetKeys = new Map < String, gridHelper > ();
        revenuePYMap = new Map < String, gridHelper > ();
        revenueCYMap = new Map < String, gridHelper > ();
        forecastMap = new Map < String, gridHelper > ();
        projectedMap = new Map < String, gridHelper > ();
        oppBudgetAdjMap = new Map < String, gridHelper > ();
        nbucOppBudgetAdjMap = new Map < String, gridHelper > ();
        if (budgetKeys == null || budgetKeys.size() == 0) {
            budgetKeys = new Map < String, gridHelper > ();
        }
        advertiserIdList = new Set < Id > ();
    }

    private void processLSMAndDOSData(GridHelper rh, List < Revenue_Aggregate__c > pyLeadershipRevenues, List < Revenue_Aggregate__c > cyLeadershipRevenues, List < PZMV_Aggregate__c > pyLeadershipPZMV, String key) {
         
        //Query Previous year's Revenue for the Leadership AE's
        String initialRevQuery = 'SELECT Total_Amount__c, Product_Line__c, Broadcast_Month__c, Year__c, Account_Executive__c, Account_Executive_Name__c FROM Revenue_Aggregate__c WHERE {0} AND {1}';
        Integer intPyYear = Integer.valueof(selectedYear)-1;
        Integer intCyYear = Integer.valueof(selectedYear);
        List<String> splitSalesProbSelected = salesProbSelected.split(',');
        String pyRevQuery = String.format(initialRevQuery, new String[] { loggedUserProfile == 'Master - Director of Sales'?'DOS__c = :loggedUserId': 'LSM__c = :loggedUserId', 'Year__c = :intPyYear'});
        system.debug('pyRevQuery:: '+pyRevQuery);
        pyLeadershipRevenues = Database.query(pyRevQuery);
        
        System.debug('@@pyLeadershipRevenues:: ' + pyLeadershipRevenues);
        for (Revenue_Aggregate__c pyRev: pyLeadershipRevenues) {
            key = keySeparator + pyRev.Account_Executive__c + keySeparator + pyRev.Product_Line__c + keySeparator + Label.BudgetCurrentYear;
            alignPYRevenues(rh, key, pyRev.Product_Line__c, pyRev.Account_Executive__c , (Integer) pyRev.Year__c, (Integer) pyRev.Broadcast_Month__c, (Integer) pyRev.Total_Amount__c);
        }

        //Query Current year's Revenue for the Leadership AE's
        String cyRevQuery = String.format(initialRevQuery, new String[] { loggedUserProfile == 'Master - Director of Sales'?'DOS__c = :loggedUserId': 'LSM__c = :loggedUserId', 'Year__c = :intCyYear'});
        cyLeadershipRevenues = Database.query(cyRevQuery);
        for (Revenue_Aggregate__c cyRev: cyLeadershipRevenues) {
            key = keySeparator + cyRev.Account_Executive__c + keySeparator + cyRev.Product_Line__c + keySeparator + Label.BudgetCurrentYear;
            alignCYRevenues(rh, key, cyRev.Product_Line__c, cyRev.Account_Executive__c, (Integer) cyRev.Year__c, (Integer) cyRev.Broadcast_Month__c, (Decimal) cyRev.Total_Amount__c);
        }

        String pyLeadershipPZMVQuery='';
        //Query Current year's Forecast for the Leadership AE's
        //Pending Dollars
        String pendingInitialQuery = 'SELECT OwnerId__c, Amount__c, PrimaryCommodity__c, SysCode__c, Month__c, Year__c, RecordType__c, Product_Line__c FROM PZMV_Aggregate__c WHERE {0}  AND RecordType__c = \'Linear\' AND ProposalZoneStatus__c = \'Pending\' AND ProposalActive__c = true  AND Year__c =: intCyYear AND (ProposalOppIsClosed__c = false OR ProposalOppIsWon__c = true) AND Amount__c > 0 AND SalesProbability__c IN: splitSalesProbSelected';
        pyLeadershipPZMVQuery = String.format(pendingInitialQuery, new String[] { loggedUserProfile == 'Master - Director of Sales'?'DOS__c =: loggedUserId': 'LSM__c =: loggedUserId'});
        pyLeadershipPZMV = Database.query(pyLeadershipPZMVQuery);
        System.debug('pyLeadershipPZMV ::: ' + pyLeadershipPZMV);
        for (PZMV_Aggregate__c pzmv: pyLeadershipPZMV) {
            System.debug('pzmv ' + pzmv);
            key = keySeparator + pzmv.OwnerId__c + keySeparator + pzmv.Product_Line__c + keySeparator + Label.BudgetCurrentYear;
            alignCYPendingPZMV(rh, key, pzmv);
        }

        //Query Current year's Forecast for the Leadership AE's
        //Projected Dollars
        String projectedInitialQuery = 'SELECT OwnerId__c, Amount__c, PrimaryCommodity__c, SysCode__c, Month__c, Year__c, RecordType__c, Product_Line__c FROM PZMV_Aggregate__c WHERE {0}  AND RecordType__c = \'Opportunity Budget\' AND ProposalActive__c = true  AND Year__c =: intCyYear AND(ProposalOppIsClosed__c = false OR ProposalOppIsWon__c = true) AND Amount__c > 0 AND SalesProbability__c IN: splitSalesProbSelected';
        pyLeadershipPZMVQuery = String.format(projectedInitialQuery, new String[] { loggedUserProfile == 'Master - Director of Sales'?'DOS__c =: loggedUserId': 'LSM__c =: loggedUserId'});
        pyLeadershipPZMV = Database.query(pyLeadershipPZMVQuery);
        System.debug('pyLeadershipPZMV second ::: ' + pyLeadershipPZMV);
        for (PZMV_Aggregate__c pzmv: pyLeadershipPZMV) {
            key = keySeparator + pzmv.OwnerId__c + keySeparator + pzmv.Product_Line__c + keySeparator + Label.BudgetCurrentYear;
            alignCYProjectedPZMV(rh, key, pzmv);
        }

        //Forecast Adjusted Dollars for the Leadership AE's
        String adjustedInitialQuery = 'SELECT OwnerId__c, Amount__c, PrimaryCommodity__c, SysCode__c, Month__c, Year__c, RecordType__c, Product_Line__c FROM PZMV_Aggregate__c WHERE {0}  AND RecordType__c = \'Adjust Opportunity Budget\' AND Year__c =: intCyYear AND Amount__c > 0 AND SalesProbability__c IN: splitSalesProbSelected';
        pyLeadershipPZMVQuery = String.format(adjustedInitialQuery, new String[] { loggedUserProfile == 'Master - Director of Sales'?'DOS__c =: loggedUserId': 'LSM__c =: loggedUserId'});
        pyLeadershipPZMV = Database.query(pyLeadershipPZMVQuery);
        for (PZMV_Aggregate__c pzmv: pyLeadershipPZMV) {
            key = keySeparator + pzmv.OwnerId__c + keySeparator + pzmv.Product_Line__c + keySeparator + Label.BudgetCurrentYear;
            alignCYAdjustedPZMV(rh, key, pzmv);
        }

        //Forecast Adjusted Dollars Parked in NB/UC Account for the Leadership
        List < AggregateResult > nbucPZMV = [SELECT proposal_zone__r.proposal__r.opportunity__r.accountId accountId, sum(Net_Amount__c) amount, Schedule_Type__c,
            proposal_zone__r.proposal__r.opportunity__r.account.Primary_Commodity__c cc,
            CALENDAR_MONTH(Broadcast_Month_Date__c) mon, CALENDAR_YEAR(Broadcast_Month_Date__c) year,
            proposal_zone__r.proposal__r.recordtype.name PropRecType FROM Proposal_Zone_Monthly_Value__c
            WHERE proposal_zone__r.proposal__r.opportunity__r.Owner_For_Forecasting_Tool__c =: loggedUserId
            AND proposal_zone__r.proposal__r.recordtype.name = 'Adjust Opportunity Budget'
            AND proposal_zone__r.proposal__r.Active__c = true AND Year__c =: selectedYear
            AND Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c IN: salesProbSelected.split(',')
            AND proposal_zone__r.proposal__r.opportunity__r.accountId =: Label.BudgetNewBusinessAcountId
            group by proposal_zone__r.proposal__r.opportunity__r.accountId, proposal_zone__r.proposal__r.opportunity__r.account.Primary_Commodity__c,
            CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c),
            proposal_zone__r.proposal__r.recordtype.name, Schedule_Type__c
        ];
        for (AggregateResult pzmv: nbucPZMV) {
            String productLine;
            if (pzmv.get('Schedule_Type__c') == 'Linear') {
                productLine = 'Linear/News/Sports';
            } else if (pzmv.get('Schedule_Type__c') == 'Digital') {
                productLine = 'Digital';
            } else if (pzmv.get('Schedule_Type__c') == 'Production') {
                productLine = 'Production';
            }
            key = keySeparator + (String) pzmv.get('accountId') + keySeparator + productLine + keySeparator + Label.BudgetCurrentYear;
            alignNBUCAdjustedPZMV(rh, key, pzmv, productLine);
        }
    }

    private void alignNBUCAdjustedPZMV(GridHelper rh, String key, AggregateResult pzmv, String productLine) {
        rh = new GridHelper();
        rh.commodity = (String) pzmv.get('cc');
        rh.Advertiser = (String) pzmv.get('accountId');
        rh.ProductLine = productLine;
        rh.year = (Integer) pzmv.get('year');

        if (nbucOppBudgetAdjMap.containsKey(key)) {
            nbucOppBudgetAdjMap.get(key).months[(Integer) pzmv.get('mon') - 1] += (Decimal) pzmv.get('amount');
            rh.months = nbucOppBudgetAdjMap.get(key).months;
        } else {
            rh.months[(Integer) pzmv.get('mon') - 1] += (Decimal) pzmv.get('amount');
        }
        nbucOppBudgetAdjMap.put(key, rh);
        budgetKeys.put(key, rh);
    }

    private void alignCYAdjustedPZMV(GridHelper rh, String key, PZMV_Aggregate__c pzmv) {
        rh = new GridHelper();
        rh.commodity = pzmv.PrimaryCommodity__c;
        rh.Advertiser = pzmv.OwnerId__c;
        rh.ProductLine = pzmv.Product_Line__c;
        rh.year = (Integer) pzmv.Year__c;

        if (oppBudgetAdjMap.containsKey(key)) {
            oppBudgetAdjMap.get(key).months[(Integer) pzmv.Month__c - 1] += (Decimal) pzmv.Amount__c;
            rh.months = oppBudgetAdjMap.get(key).months;
        } else {
            rh.months[(Integer) pzmv.Month__c - 1] += (Decimal) pzmv.Amount__c;
        }
        oppBudgetAdjMap.put(key, rh);
        budgetKeys.put(key, rh);
    }

    private void alignCYProjectedPZMV(GridHelper rh, String key, PZMV_Aggregate__c pzmv) {
        rh = new GridHelper();
        rh.commodity = pzmv.PrimaryCommodity__c;
        rh.Advertiser = pzmv.OwnerId__c;
        rh.ProductLine = pzmv.Product_Line__c;
        rh.year = (Integer) pzmv.Year__c;

        if (projectedMap.containsKey(key)) {
            projectedMap.get(key).months[(Integer) pzmv.Month__c - 1] += (Decimal) pzmv.Amount__c;
            rh.months = projectedMap.get(key).months;
        } else {
            rh.months[(Integer) pzmv.Month__c - 1] += (Decimal) pzmv.Amount__c;
        }
        projectedMap.put(key, rh);
        budgetKeys.put(key, rh);
    }

    private void alignCYPendingPZMV(GridHelper rh, String key, PZMV_Aggregate__c pzmv) {
        rh = new GridHelper();
        rh.commodity = pzmv.PrimaryCommodity__c;
        rh.Advertiser = pzmv.OwnerId__c;
        rh.ProductLine = pzmv.Product_Line__c;
        rh.year = (Integer) pzmv.Year__c;

        if (forecastMap.containsKey(key)) {
            forecastMap.get(key).months[(Integer) pzmv.Month__c - 1] += (Decimal) pzmv.Amount__c;
            rh.months = forecastMap.get(key).months;
        } else {
            rh.months[(Integer) pzmv.Month__c - 1] += (Decimal) pzmv.Amount__c;
        }
        forecastMap.put(key, rh);
        budgetKeys.put(key, rh);
    }

    @TestVisible
    private void alignPYRevenues(GridHelper rh, String key, String Product_Line, String Advertiser, Integer Year, Integer Broadcast_Month, Integer Total_Amount) {
        try {
            rh = new gridHelper();
            rh.Advertiser = Advertiser;
            rh.ProductLine = Product_Line;
            rh.year = Year;
            if (revenuePYMap.containsKey(key)) {
                revenuePYMap.get(key).months[Broadcast_Month - 1] = revenuePYMap.get(key).months[Broadcast_Month - 1] + Total_Amount;
                rh.months = revenuePYMap.get(key).months;
            } else {
                rh.months[Broadcast_Month - 1] = rh.months[Broadcast_Month - 1] + Total_Amount;
            }
            revenuePYMap.put(key, rh);
            budgetKeys.put(key, rh);
            if (loggedInBudgetView == 'Executive') {
                advertiserIdList.add((Id) Advertiser);
            }
        } catch (Exception ex) {
            System.debug('Exception:: @@  ' + ex.getMessage());
            System.debug('Exception:: @@  ' + ex.getLineNumber());
        }
    }

    @TestVisible
    private void alignCYRevenues(GridHelper rh, String key, String Product_Line, String Advertiser, Integer Year, Integer Broadcast_Month, Decimal Total_Amount) {
        try {
                rh = new gridHelper();
                rh.Advertiser = Advertiser;
                rh.ProductLine = Product_Line;
                rh.year = Year;
                if (revenueCYMap.containsKey(key)) {
                    revenueCYMap.get(key).months[Broadcast_Month - 1] = revenueCYMap.get(key).months[Broadcast_Month - 1] + Total_Amount;
                    rh.months = revenueCYMap.get(key).months;
                } else {
                    rh.months[Broadcast_Month - 1] = rh.months[Broadcast_Month - 1] + Total_Amount;
                }
                revenueCYMap.put(key, rh);
                budgetKeys.put(key, rh);
                if (loggedInBudgetView == 'Executive') {
                    advertiserIdList.add((Id) Advertiser);
                }
        } catch (Exception ex) {
            System.debug('Exception:: @@  ' + ex.getMessage());
            System.debug('Exception:: @@  ' + ex.getLineNumber());
        }
    }

    public void queryAEAccTeamData(GridHelper rh) {
        List < AccountTeamMemberComparator > sortedTeamMembers = new List < AccountTeamMemberComparator > ();
        String atmQuery='';
        if(!Test.isRunningTest()){
            atmQuery = 'SELECT TeamMemberRole, accountid, account.name, account.Primary_Commodity__c ' +
                'FROM AccountTeamMember ' +
                'WHERE UserId = :impParam ' +
                'AND account.Primary_Commodity__c != null ' +
                'AND account.Political_Account__c = false ' +
                ' ORDER BY account.LastActivityDate DESC LIMIT ' + loggedInUser.Forecasting_Tool_Account_Limit__c;
    	}
    	else{
        	atmQuery = 'SELECT TeamMemberRole, accountid, account.name, account.Primary_Commodity__c ' +
                'FROM AccountTeamMember ' +
                'WHERE UserId = :impParam ' +
                'AND account.Primary_Commodity__c != null ' +
                'AND account.Political_Account__c = false ' +
                ' ORDER BY account.LastActivityDate DESC LIMIT ' + loggedInUser.Forecasting_Tool_Account_Limit__c;
    	}
        List < AccountTeamMember > acTeamMember = Database.query(atmQuery);
        SYSTEM.DEBUG('impParam:: '+impParam);
        for (AccountTeamMember atm: acTeamMember) {
            sortedTeamMembers.add(new AccountTeamMemberComparator(atm));
        }
        sortedTeamMembers.sort();

        for (AccountTeamMemberComparator atm: sortedTeamMembers) {
            for (String pl: loggedInUserProductLines.split(';')) {
                String key = keySeparator + atm.teamMember.accountId + keySeparator + pl + keySeparator + Label.BudgetCurrentYear;
                rh = new gridHelper();
                rh.commodity = atm.teamMember.account.Primary_Commodity__c;
                rh.Advertiser = atm.teamMember.accountId;
                rh.ProductLine = pl;
                rh.year = Integer.valueOf(Label.BudgetCurrentYear);
                budgetKeys.put(key, rh);
            }
            advertiserIdList.add(atm.teamMember.accountId);
        }
        advertiserIdList.add(Label.BudgetNewBusinessAcountId);
        System.debug('advertiserIdList: ' + advertiserIdList.size());

    }

    @RemoteAction
    global static String saveAdjustedForecast(string forecastAdjData, string selectedUserId) {
        System.debug('forecastAdjData:: ' + forecastAdjData);
        System.debug('selectedUserId:: ' + selectedUserId);
        RecordType adjOppBudRecordType = [SELECT ID, NAME FROM RecordType WHERE DEVELOPERNAME = 'Adjust_Opportunity_Budget'
            LIMIT 1
        ];
        system.debug('forecastAdjData:: ' + forecastAdjData);
        List < AdjustedForecastModel > parsedforecastAdjData = AdjustedForecastModel.parse(forecastAdjData);
        system.debug('parsedforecastAdjData:: ' + parsedforecastAdjData);
        Map < String, List < AdjustedForecastModel >> mapForecastAdjData = new Map < String, List < AdjustedForecastModel >> ();

        for (AdjustedForecastModel data: parsedforecastAdjData) {
            if (mapForecastAdjData.containsKey(data.accountId)) {
                mapForecastAdjData.get(data.accountId).add(data);
            } else {
                mapForecastAdjData.put(data.accountId, new List < AdjustedForecastModel > {
                    data
                });
            }
        }

        List < Opportunity > oppList = new List < Opportunity > ();
        List < Proposal__c > proposalList = new List < Proposal__c > ();
        List < Proposal_Zone__c > pzList = new List < Proposal_Zone__c > ();
        List < Proposal_Zone_Monthly_Value__c > pzmvList = new List < Proposal_Zone_Monthly_Value__c > ();

        User u = [Select Id From User Where Name = 'B Integration User'];

        RecordType rt = [Select Id, Name, DeveloperName From RecordType Where DeveloperName = 'Forecasting_Tool_Opportunity'];

        for (String accId: mapForecastAdjData.keySet()) {
            Opportunity dummyOpp = new Opportunity();
            dummyOpp.Name = 'Opportunity For Forecast Adjustment' + '::' + selectedUserId;
            dummyOpp.StageName = 'Identification';
            dummyOpp.Sales_Probability__c = '10';
            dummyOpp.AccountId = Label.BudgetNewBusinessAcountId;
            dummyOpp.CloseDate = System.Date.today();
            dummyOpp.OpportunityExternalId__c = accId + ':' + selectedUserId;
            dummyOpp.OwnerId = u.Id;
            dummyOpp.RecordTypeId = rt.Id;
            dummyOpp.Account_For_Forecasting_Tool__c = accId;
            dummyOpp.Owner_For_Forecasting_Tool__c = selectedUserId;
            oppList.add(dummyOpp);

            Proposal__c adjOppBudProp = new Proposal__c();
            adjOppBudProp.Opportunity__r = new Opportunity(OpportunityExternalId__c = dummyOpp.OpportunityExternalId__c);
            adjOppBudProp.ProposalExternalId__c = accId + ':' + selectedUserId;
            adjOppBudProp.Start_Date__c = System.Date.newInstance(2024, 1, 1);
            adjOppBudProp.End_Date__c = System.Date.newInstance(2024, 12, 31);
            adjOppBudProp.Name = ('Forecast Adjustment Opportunity Budget');
            adjOppBudProp.RecordTypeId = adjOppBudRecordType.Id;
            proposalList.add(adjOppBudProp);

            Proposal_Zone__c propZone = new Proposal_Zone__c();
            propZone.PZ_ExternalID__c = accId + ':' + selectedUserId;
            propZone.Proposal__r = new Proposal__c(ProposalExternalId__c = adjOppBudProp.ProposalExternalId__c);
            propZone.name = 'Proposal line Forecast Adjustment';
            pzList.add(propZone);

            for (AdjustedForecastModel obj: mapForecastAdjData.get(accId)) {
                Proposal_Zone_Monthly_Value__c newPZM = new Proposal_Zone_Monthly_Value__c();
                newPZM.name = 'Monthly Value Forecast Adjustment';
                newPZM.Advertiser__c = accId;
                newPZM.Proposal_Zone__r = new Proposal_Zone__c(PZ_ExternalID__c = propZone.PZ_ExternalID__c);
                Integer monthValue = CheckMonth(obj.monthKey);
                Date broadCastDate = Date.newInstance(2024, monthValue, 15);
                newPZM.Broadcast_Month_Date__c = broadCastDate;
                newPZM.Gross_Amount__c = obj.monthAmount;
                if (obj.scheduleType == 'Linear/News/Sports') {  newPZM.Schedule_Type__c = 'Linear';
                } else if (obj.scheduleType == 'Digital') {  newPZM.Schedule_Type__c = 'Digital';
                } else if (obj.scheduleType == 'Production') {  newPZM.Schedule_Type__c = 'Production';
                }
                newPZM.PZMV_ExternalID__c = obj.monthKey + ':' + accId + ':' + selectedUserId + ':' + newPZM.Schedule_Type__c;
                pzmvList.add(newPZM);
            }
        }

        Schema.SObjectField f1 = Opportunity.Fields.OpportunityExternalId__c;
        Schema.SObjectField f2 = Proposal__c.Fields.ProposalExternalId__c;
        Schema.SObjectField f3 = Proposal_Zone__c.Fields.PZ_ExternalID__c;
        Schema.SObjectField f4 = Proposal_Zone_Monthly_Value__c.Fields.PZMV_ExternalID__c;

        List < SObject > listData = new List < Sobject > ();
        listData.addAll(oppList);
        listData.addAll(proposalList);
        listData.addAll(pzList);
        listData.addAll(pzmvList);

        System.debug('opplist before upsert ' + oppList);
        System.debug('f1 is ::: ' + f1);
        Database.UpsertResult[] oppResults = Database.upsert(oppList, f1);
        Database.UpsertResult[] propResults = Database.upsert(proposalList, f2);
        Database.UpsertResult[] pzResults = Database.upsert(pzList, f3);
        Database.UpsertResult[] pzmvResults = Database.upsert(pzmvList, f4);

        // Database.UpsertResult [] results = Database.upsert(listData);
        // Insert oppList;
        // Insert proposalList;
        // Insert pzList;
        // Insert pzmvList;

        return 'Forecast Adjustment Saved';
    }
    @TestVisible
    private String fmtTotalFormula(String mon) {
        return mon + 'Formula=\'fcst(Grid,Row,Col)\' ';
    }
    @TestVisible
    private String formatMonthRollupFormula(String mon) {
        return mon + 'Formula=\'rollitup(Grid,Row,Col)\' ';
    }
    // @TestVisible
    // private String formatMonthRollupFormula(String mon, String account) {
    //     return mon + 'Formula=\'rollitup(Grid,Row,Col)\' ';
    // }
    @TestVisible
    private String formatDef(String t) {
        String retStr = '';
        String maskStr = '', canEditStr = '', typeStr = '', formatStr = '$#,##0;($#,##0)', messageStr = '', formulaStr = '', onChangeStr = '';
        String[] months = new String[] {
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec'
        };

        retStr += '<D Name=\'' + t + '\' ';

        if (t == 'lplain') {
            messageStr = '';
            maskStr = '';
            canEditStr = '';
            typeStr = 'Float';
        } else if (t == 'ldollar') {
            messageStr = 'Please enter a valid dollar amount';
            maskStr = '^[0-9]{0,3}(?:,?[0-9]{3})*[\\.]{0,1}[0-9]{0,2}$';
            canEditStr = '0';
            typeStr = 'Float'; // formatStr = '';
            formatStr = '<span style=&quot;color:#000;font-size:1.05em&quot;>$#,##0;($#,##0)</span>';
            //retStr += 'Growth%CanEdit=\'1\' ChurnIndicatorCanEdit=\'1\' OnChange=\'Grids.C(Grid,Row,Col)\' ';
        } else if (t == 'lneg') {
            messageStr = 'Please enter a value of 0 or less';
            maskStr = '^(-[0-9]+|[0]{0,1})$';
            canEditStr = '0';
            typeStr = 'Float'; //formatStr = '';
            formatStr = '<span style=&quot;color:#000;font-size:1.05em&quot;>$#,##0;($#,##0)</span>';
            //retStr += 'OnChange=\'Grids.C(Grid,Row,Col)\' ';
        } else if (t == 'lpct') {
            messageStr = 'Please enter an integer from 0 to 100';
            maskStr = '^[1-9][0-9]?$|^100$';
            canEditStr = '';
            typeStr = '';
            formatStr = '0%';
            formulaStr = 'getyoy(Grid,Row,Col)';
            retStr += ' Q1Format=\'0%\' Q2Format=\'0%\' Q3Format=\'0%\' Q4Format=\'0%\' TotalFormat=\'0%\' ';
            retStr += ' TotalFormula=\'' + formulaStr + '\' Q1Formula=\'' + formulaStr + '\' Q2Formula=\'' + formulaStr + '\' Q3Formula=\'' + formulaStr + '\' Q4Formula=\'' + formulaStr + '\' Calculated=\'1\' ';
        } else if (t == 'loppbudAdj') {
            messageStr = 'Please enter a valid dollar amount';
            maskStr = '^(-)?[0-9]{0,3}(?:,?[0-9]{3})*[\\.]{0,1}[0-9]{0,2}$';
            canEditStr = '1';
            typeStr = 'Float'; // formatStr = '';
            formatStr = '<span style=&quot;color:#000;font-size:1.05em&quot;>$#,##0;($#,##0)</span>';
            // retStr += 'OnAfterSave=\'Grids.OnAfterSave(Grid,Row,Col)\' ';
        }

        for (String m: months) {
            if (messageStr != '') {
                retStr += m + 'ResultMessage=\'' + messageStr + '\' ';
            }
            if (maskStr != '') {
                retStr += m + 'ResultMask=\'' + maskStr + '\' ';
            }
            if (canEditStr != '') {
                retStr += m + 'CanEdit=\'' + canEditStr + '\' ';
            }
            if (formatStr != '') {
                retStr += m + 'Format=\'' + formatStr + '\' ';
            }
            if (formulaStr != '') {
                retStr += m + 'Formula=\'' + formulaStr + '\' ';
            }
        }

        retStr += ' Recalc=\'256\' R.CanFilter = \'0\' Node.CanFilter = \'1\'/>';

        return retStr;
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
    @TestVisible
    private BudgetingToolModel.Items_Led AddLed(String LedName, String format, Integer ReadOnly, List < Decimal > months, String formula, String id, String churnIndicator) {
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

        tgmiLed.Def = formatDef(LedName, format);
        system.debug('tgmiLed ' + tgmiLed);
        return tgmiLed;
    }

    /**
     * Helper to format and choose Def for item (removing logic from Model, adding generic Labels)
     *
     * @param  (String AccountName) (NA)
     * @param  (String format) (NA)
     * @return (String) (NA)
     */
    @TestVisible
    private String formatDef(String AccountName, String format) {
        String defTmp = 'lplain';

        if (AccountName == ChurnYearLabel) { defTmp = 'lneg';
        } else if (AccountName == pendingLabel || AccountName == NewBusinessYearLabel) {
            defTmp = 'ldollar';
        } else if (AccountName == projectedLabel || AccountName == NewBusinessYearLabel) {
            defTmp = 'ldollar';
        } else if (AccountName == '+/- Forecast Adjustment') {
            defTmp = 'loppbudAdj';
        } else if (format == 'p') { defTmp = 'lpct';
        }

        return defTmp;
    }

    /**
     * Helper method to add products, cut down on repeated code during dev iterations
     *
     * @param  (String ProductName) (NA)
     * @param  (List<BudgetingToolModel.Items_Led> tgmiLedList) (NA)
     * @return (BudgetingToolModel.Items_Pro) (NA)
     */
    @TestVisible
    private BudgetingToolModel.Items_Pro AddProduct(String ProductName, List < BudgetingToolModel.Items_Led > tgmiLedList) {
        BudgetingToolModel.Items_Pro tgmiPro = new BudgetingToolModel.Items_Pro();
        tgmiPro.Account = ProductName;
        tgmiPro.items = tgmiLedList;
        tgmiPro.Def = 'prod';
        return tgmiPro;
    }

    /**
     * Helper method to add products, cut down on repeated code during dev iterations
     *
     * @param  (String ProductName) (NA)
     * @param  (List<BudgetingToolModel.Items_Led> tgmiLedList) (NA)
     * @return (BudgetingToolModel.Items_Pro) (NA)
     */
    @TestVisible
    private BudgetingToolModel.Body AddAccount(String AccName, List < BudgetingToolModel.Items_Pro > tgmiLedList) {
        BudgetingToolModel.Body tgmiAcc = new BudgetingToolModel.Body();
        tgmiAcc.Account = AccName;
        tgmiAcc.items = tgmiLedList;
        return tgmiAcc;
    }
    @TestVisible
    private static Integer CheckMonth(String monthName) {
        for (Month mon: Month.values()) {
            if (mon.name() == monthName) {
                return mon.ordinal() + 1;
            }
        }
        return 0;
    }

    /**
     * This class is used to create object structure required for Budget grid
     */
    @TestVisible
    private class gridHelper {
        String dma;
        String commodity;
        String advertiser;
        String productLine;
        List < Decimal > months;
        List < String > monthIds;
        Integer year;
        String ChurnIndicator;
        String NewBusinessChurn;
        string eclipseSystem = '';
        string eclipseId = '';
        @TestVisible
        private gridHelper() {
            months = new List < Decimal > {
                0.00,
                0.00,
                0.00,
                0.00,
                0.00,
                0.00,
                0.00,
                0.00,
                0.00,
                0.00,
                0.00,
                0.00
            };
            monthIds = new List < String > {
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                ''
            };
        }
    }

    public class AccountTeamMemberComparator implements Comparable {
        public AccountTeamMember teamMember;

        public AccountTeamMemberComparator(AccountTeamMember tm) {
            this.teamMember = tm;
        }

        public Integer compareTo(Object obj) {
            AccountTeamMemberComparator other = (AccountTeamMemberComparator) obj;
            return teamMember.Account.Name.compareTo(other.teamMember.Account.Name);
        }
    }

}