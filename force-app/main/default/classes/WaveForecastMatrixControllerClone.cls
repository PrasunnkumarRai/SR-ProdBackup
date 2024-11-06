/* DO NOT DELETE THIS CONTROLLER. THIS IS THE BACKUP COPY FOR ORIGINAL WAVE FORECAST MATRIX REQUIREMENT*/
public class WaveForecastMatrixControllerClone {

    // Properties //
    public Integer sectionHeight {get; set;}
    public String chosenUser { get; set; }
    public String chosenDMAoption {get; set;}
    // Start: GLID Changes
    public String chosenGlidoption { get; set; } 
    public String availableBudgetDMAvalues{get; set;}  
    public String availableGlidvalues{get; set;}
    public Map<String, String> glidBudgetDMAMap {get; set;}
    public transient List<SelectOption> GLIDoptions {get; set;} 
    public List<String> glidList {get; set;}  
    // End: GLID Changes
    public String chosenUserName { get; set; }
    public String loggeduserId { get;set; }
    public String chosenFiscalYear{ get; set; }
    public String getSelUserRole { get; set; } // Not useful
    public String chosenProduct {get; set;}
    public String accNameparam {get; set;}
    public String appliedFilters {get; set;}
    public Boolean isActual {get; set;}
    public Boolean hasPoliticalData {get; set;}
    public Boolean hasTradeData {get; set;}
    public Boolean isNationalUser {get; set;}
    public transient Boolean displayTable {get; set;}
    public transient Boolean displayTotalsTable {get; set;}
    public transient Boolean displayPerformanceTable {get; set;}
    public transient Boolean loadSpinner {get; set;}
    public transient Boolean hasPolitical {get; set;}
    public transient Boolean hasTrade {get; set;}
    // public transient String linearFilter {get; set;}
    public transient String politicalFilter {get; set;}
    public transient String tradeFilter {get; set;}
    public transient List<SelectOption> options { get; set; }
    public transient List<SelectOption> productOptionList {get; set;}  
    public transient List<SelectOption> budgetDMAoptions {get; set;}
    public transient List<SelectOption> salesProbabilityOptions {get; set;}
    public transient List<String> selectedSalesProb {get; set;}
    public transient List<String> budgetDMAList {get; set;}
    public transient List<String> selectedSalesProbWithPercentage {get; set;}
    public transient List<String> performanceOrder {get; set;}
    public transient List<String> prodListForTotals {get; set;}
    public transient List<String> prodListForPoliticalTotals {get; set;}
    public transient List<String> prodListForTradeTotals {get; set;}
    public List<String> monthNames {get; set;}  // SRSF-3393 - removed transient
    public transient Map<String,List<Decimal>> typeAmnt{get; set;}
    public transient Map<String, Map<String, List<Decimal>>> totalsMap {get; set;}
    public transient Map<String, Map<String, List<Decimal>>> politicalTotalsMap {get; set;}
    public transient Map<String, Map<String, List<Decimal>>> tradeTotalsMap {get; set;}
    public transient Map<String, Map<String, List<Decimal>>> quarterlyTotalsMap {get; set;}
    public transient Map<String, Map<String, List<Decimal>>> politicalQuarterlyTotalsMap {get; set;}
    public transient Map<String, Map<String, List<Decimal>>> tradeQuarterlyTotalsMap {get; set;}
    public transient Map<String, Map<String, List<Decimal>>> performanceMap {get; set;}
    public transient Map<String, Map<String, List<Decimal>>> performanceMap1 {get; set;}
    public transient Map<String, List<forecastWrapper>> forecastWrapMap{get; set;}
    public transient Map<String, List<productTypeWrapper>> accGroupMap {get; set;}
    public transient Map<String, String> accIdMap {get; set;}
    // START: SRSF-3393
    public transient String accGroupMapJSON {get; set;}
    public transient List<SelectOption> rowTypeList {get; set;} 
    public transient String selectedRowType {get; set;}
    // END: SRSF-3393
    //Custom metadata created for Performane labels
    public List<String> performanceLabels {get; set;}
    public Map<String,ForecastMatrix_Labels__mdt> performanceKeys{get; set;}
    //SRSF-2485
    public transient Map<String, Map<String, List<String>>> opportunityMap {get; set;}
    public transient Map<String, List<String>> oppData{get; set;}
    public transient Map<String, List<String>> newsRevAccDtls{get; set;} //SRSF-4022
    public transient Map<String,String> oppDetailsMap {get; set;}
    public transient Map<String, Decimal> oppNetAmtMap {get; set;}
    public transient String opportunityData{get;set;}
    public transient String oppDetails{get;set;}
    public transient String oppNetAmtData{get;set;}
    //END SRSF-2485
    public transient String newsRevAccs{get;set;}//SRSF-4022

    // Wave Dashboard Properties
    public transient String wave_chosenProduct {get; set;}
    public transient String wave_dashboardId{get; set;}
    public transient String wave_SalesProbabailty {get; set;}
    public transient String wave_RevenueType {get; set;}
    public transient String wave_budgetDMA {get; set;} 
    public transient String wave_forecastCategory {get; set;}
    public transient String wave_isPolitical {get; set;}
    public transient String wave_productLine {get; set;}
    
    // Variables //
    public Boolean performWeightageCalculation = false;
    public Boolean isProdTypePolitical ;
    public String encryptedUser;
    public String encryptedYear;
    public String chosenSalesProbability = '';
    private User currentUser;
    private User loggedInUser;
    private Set<Id> childUserIds;
    private Set<String> filteredDesignation = new Set<String>{'Account Planner','Account Coordinator'};
    public List<String> availableRevenueTypeList = new List<String>();
    private List<String> salesProbabilityPicklistValues = new List<String>();
    public Map<String, User> childUserMap ;
    public Map<String,String> globalParentChildUserMap;
    public Map<String, String> prodType_Linear_Map;
    public Map<String, Set<String>> accProdTypesMap ;
    public Map<String, List<Decimal>> prodMonthAmountMap ;
    public Map<String, List<Decimal>> percentageBookToBudget;
    public Map<String, Revenue_Type_Mapping__c> revenueTypeSetting;
    public Boolean isCompanyModel {get; set;}
    public Boolean isLocalUser {get; set;}  

    public Integer newsSectionHeight {get; set;}
    public Boolean hasNewsData {get; set;}
    public transient Boolean hasNews {get; set;} 
    public transient List<String> prodListForNewsTotals {get; set;}
    public transient Map<String, Map<String, List<Decimal>>> newsTotalsMap {get; set;}  

    //Constants
    public static final String ROWTYPE_PENDING = 'Pending';
    public static final String ROWTYPE_PROJECTED = 'Projected';
    public static final String ROWTYPE_BUDGET = 'Budget';
    public static final String ROWTYPE_BOOKED = 'Booked';
    public static final String ROWTYPE_FORECAST_ADJUSTMENT = 'Forecast Adjustment'; //SRSF-4489
    // SRSF-1785 Changes Start : 10-06-2019  
    public static final String ROWTYPE_PENDING_PROJECTED = 'Pending + Projected'; 
//  public static final String ROWTYPE_BOOKED_PENDING_PROJECTED = 'Booked + Pending + Projected';
    public static final String ROWTYPE_GAP = 'GAP (Booked - Budget)';
    public static final String ROWTYPE_BOOKED_PENDING_PROJECTED_FORECAST_ADJUSTMENT = 'Booked + Pending + Projected + Forecast Adjustment'; //SRSF-4489
    // SRSF-2105
    public static final String ROWTYPE_NEWS_TARGET = 'News Target'; 
    public static final String ROWTYPE_NEWS_REVENUE = 'News Revenue';
    public static final String ROWTYPE_NEWS_REVENUE_TO_NEWS_TARGET = 'News To News Target';
    // SRSF-1785 Changes End : 10-06-2019  
    public static final String SYS_ADMIN_PROFILE = 'System Administrator';
    public static final String REGIONAL_FINANCE_PROFILE = 'Master - Regional Finance';

    // Default Constructor
    public WaveForecastMatrixControllerClone(){
        globalParentChildUserMap = new Map<String,String>();
        prodType_Linear_Map = new Map<String, String>();
        childUserMap = new Map<String, User>();
        accGroupMap = new Map<String, List<productTypeWrapper>>();
        totalsMap = new Map<String, Map<String,List<Decimal>>>();
        tradeTotalsMap = new Map<String, Map<String,List<Decimal>>>();
        politicalTotalsMap = new Map<String, Map<String,List<Decimal>>>();
        newsTotalsMap = new Map<String, Map<String,List<Decimal>>>();
        quarterlyTotalsMap = new Map<String, Map<String,List<Decimal>>>();
        politicalQuarterlyTotalsMap = new Map<String, Map<String,List<Decimal>>>();
        tradeQuarterlyTotalsMap = new Map<String, Map<String,List<Decimal>>>();
        performanceMap = new Map<String, Map<String,List<Decimal>>>();
        performanceKeys = new Map<String,ForecastMatrix_Labels__mdt>();
        opportunityMap = new Map<String, Map<String,List<String>>>();
        newsRevAccDtls = new Map<String,List<String>>(); //SRSF-4022
        oppDetailsMap = new Map<String,String>();
        oppNetAmtMap =  new Map<String, Decimal>();
        accIdMap = new Map<String, String>();
        prodListForTotals = new List<String>();
        prodListForTradeTotals = new List<String>();
        prodListForPoliticalTotals = new List<String>();
        prodListForNewsTotals = new List<String>();
        performanceOrder = new List<String>();
        monthNames = new List<String>{'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
        salesProbabilityOptions = new List<SelectOption>();
        loggeduserId = UserInfo.getUserId();         
        appliedFilters = '';
        selectedRowType = 'All'; //SRSF-3393 
        accGroupMapJSON = ''; //SRSF-3393
        wave_forecastCategory = wave_budgetDMA = wave_productLine = null;
        sectionHeight = newsSectionHeight = 0;
        // linearFilter = politicalFilter = tradeFilter = 'dummyValue';
        isNationalUser = false;
        isLocalUser = false;
        isCompanyModel = false;        
        selectedSalesProb = new List<String>();
        selectedSalesProbWithPercentage = new List<String>();
        chosenUser = ApexPages.currentPage().getParameters().get('userId');
        chosenFiscalYear = ApexPages.currentPage().getParameters().get('selYear');
        chosenProduct = ApexPages.currentPage().getParameters().get('selProduct');
        chosenSalesProbability = ApexPages.currentPage().getParameters().get('selSalesProb');
        chosenDMAoption = ApexPages.currentPage().getParameters().get('selectedDMAoption');
        chosenGlidoption = ApexPages.currentPage().getParameters().get('selectedGlidoption');  // GLID Change
        String actualOrWeight = ApexPages.currentPage().getParameters().get('selToggle');
        String companyModel = ApexPages.currentPage().getParameters().get('selCompModel');
        if(String.isBlank(actualOrWeight) || (actualOrWeight != null && 'undefined'.equalsIgnoreCase(actualOrWeight))){
            isActual = true;
        }
        else { isActual = Boolean.valueOf(actualOrWeight); }

        if(String.isBlank(companyModel) || (companyModel != null && 'undefined'.equalsIgnoreCase(companyModel))){
            isCompanyModel = false;
        } else { isCompanyModel = Boolean.valueOf(companyModel); }
        System.debug(' ### isCompanyModel :::: ' +isCompanyModel);
        // Wave dashboard Id
        wave_dashboardId = isActual ? Label.ActualWaveDashboardId : Label.WeightedWaveDashboardId;

        if(String.isBlank(chosenProduct)) { chosenProduct = 'Linear'; }
        System.debug(' ### chosenProduct :::: ' +chosenProduct);
        System.debug(' ### chosenSalesProbability ::: ' +chosenSalesProbability);
        fetchsalesProbabilityOptions();
        if(String.isNotBlank(chosenSalesProbability)) {
            for(String str : chosenSalesProbability.split(',')) {
                selectedSalesProbWithPercentage.add(str + '%'); // To make checkbox checked on UI
                selectedSalesProb.add(str);
            }
        }
        else { selectedSalesProb = new List<String>(salesProbabilityPicklistValues); }

        System.debug(' $$$ selectedSalesProb ::: ' +selectedSalesProb);

        wave_SalesProbabailty = '\'' + String.join(selectedSalesProb,'\',\'') + '\'';

        productOptionList = new List<SelectOption>();
        productOptionList.add(new SelectOption('Linear', 'Core'));
        // productOptionList.add(new SelectOption('Political & Trade', 'Political & Trade'));
        productOptionList.add(new SelectOption('Political', 'Political'));
        productOptionList.add(new SelectOption('Trade', 'Trade'));

        // SRSF-3393 - Added RowType options
        rowTypeList = new List<SelectOption>();        
        rowTypeList.add(new SelectOption('All', 'All'));
        rowTypeList.add(new SelectOption('Booked', 'Booked'));
        rowTypeList.add(new SelectOption('Pending', 'Pending'));
        rowTypeList.add(new SelectOption('Projected', 'Projected'));

        String appliedProduct = chosenProduct != null && chosenProduct.equalsIgnoreCase('Linear') ? 'Core' : chosenProduct;            
        // Dashboard filters
        /*if(chosenProduct.equalsIgnoreCase('Linear')) {
            linearFilter = politicalFilter = tradeFilter = 'Linear';
        }
        else {
            politicalFilter = 'Political';
            tradeFilter = 'Trade';
        }*/

        isProdTypePolitical = 'Political'.equalsIgnoreCase(chosenProduct) ? true : false;

        wave_isPolitical = '\'' + isProdTypePolitical + '\'';
        wave_chosenProduct = '\'' + chosenProduct + '\'';
        wave_productLine = chosenProduct.equalsIgnoreCase('Linear') ? null : wave_chosenProduct;
        revenueTypeSetting = Revenue_Type_Mapping__c.getAll();
        System.debug(' ### revenueTypeSetting  :::: ' +revenueTypeSetting);
        if(revenueTypeSetting!= null && !revenueTypeSetting.isEmpty() && revenueTypeSetting.containsKey(appliedProduct)) {
            String availableRevType = revenueTypeSetting.get(appliedProduct).Available_Revenue_Type__c;
            availableRevenueTypeList =  String.isNotBlank(availableRevType) ? availableRevType.Split(',') : new List<String>();
        }
        System.debug(' #### availableRevenueTypeList ::: '+availableRevenueTypeList);
        if(String.isNotBlank(Label.ProductTypeToDisplay)) {
            prodType_Linear_Map.put('Linear/News/Sports', Label.ProductTypeToDisplay);
            prodType_Linear_Map.put('Linear', Label.ProductTypeToDisplay);
        }
        /*Ankit - Changes for saving user preference in cookie*/
        try
        {
            Cookie userSelection = apexpages.currentPage().getCookies().get('userSelection');
            Cookie yearSelection = apexpages.currentPage().getCookies().get('yearSelection');
            Cookie loggedInUser = apexpages.currentPage().getCookies().get('loggedInUser');            
            if(loggedInUser == null) {
                loggedInUser = new Cookie('loggedInUser',UtilityClass.aes256Encryption(userinfo.getUserId(),true),null,-1,false);
                ApexPages.currentPage().setCookies(new Cookie[]{loggedInUser});
            }

            if (userSelection == null && String.isNotBlank(chosenUser)) {
                encryptedUser = UtilityClass.aes256Encryption(chosenUser,true);
                userSelection = new Cookie('userSelection',encryptedUser,null,-1,false);
                ApexPages.currentPage().setCookies(new Cookie[]{userSelection});
            } 
            else if(String.isBlank(chosenUser) && userInfo.getUserId() == UtilityClass.aes256Encryption(apexpages.currentPage().getCookies().get('loggedInUser').getValue(),false) ) {
            // If this isn't the first time the user is accessing the page
                chosenUser = UtilityClass.aes256Encryption(apexpages.currentPage().getCookies().get('userSelection').getValue(),false);
            }
            else if(chosenUser != userSelection.getValue()) {
                encryptedUser = UtilityClass.aes256Encryption(chosenUser,true);
                userSelection = new Cookie('userSelection',encryptedUser,null,-1,false);
                ApexPages.currentPage().setCookies(new Cookie[]{userSelection});
            }
            
            if (yearSelection == null && String.isNotBlank(chosenFiscalYear)) {
                encryptedYear = UtilityClass.aes256Encryption(chosenFiscalYear,true);
                yearSelection = new Cookie('yearSelection',encryptedYear,null,-1,false);
                ApexPages.currentPage().setCookies(new Cookie[]{yearSelection});
            } 
            else if(String.isBlank(chosenFiscalYear) && userInfo.getUserId() == UtilityClass.aes256Encryption(apexpages.currentPage().getCookies().get('loggedInUser').getValue(),false)) {
            // If this isn't the first time the user is accessing the page
              chosenFiscalYear= UtilityClass.aes256Encryption(apexpages.currentPage().getCookies().get('yearSelection').getValue(),false);
            }
            else if(chosenFiscalYear != yearSelection.getValue()) {
                encryptedYear = UtilityClass.aes256Encryption(chosenFiscalYear,true);
                yearSelection = new Cookie('yearSelection',encryptedYear,null,-1,false);
                ApexPages.currentPage().setCookies(new Cookie[]{yearSelection});
            }
            
        }
        catch(Exception ex) { System.debug('Cookie Exception ::' + ex.getMessage() +' at '+ex.getLineNumber());  }
        /*Ankit - Cookie based changes end here*/
        displayTable = false;
        displayPerformanceTable = false;
        displayTotalsTable = false;
        loadSpinner = true;
        forecastWrapMap = new Map<String, List<forecastWrapper>>();
        if (String.isBlank(chosenUser)){  chosenUser = loggeduserId;  }
        if (String.isBlank(chosenFiscalYear)){ chosenFiscalYear = String.valueOf(Date.today().year()); }

        currentUser = [SELECT Id, Name,UserRoleId,UserRole.Name,Region__c,Job_Share_User__c FROM User WHERE Id = :chosenUser LIMIT 1]; // SRSF-4421 : Added Region__c
        loggedInUser = [SELECT Id, Name,UserRoleId,UserRole.Name,Profile.Name,ManagerId,ProfileId, Region__c, Job_Share_User__c FROM User WHERE Id = :loggeduserId LIMIT 1]; // SRSF-4421 : Added Region__c
        
        if(currentUser != null) {
            System.debug('Job Share ' + currentUser.Job_Share_User__c);
            chosenUserName = currentUser.Name;
            if(currentUser.Job_Share_User__c != null && (null == ApexPages.currentPage().getParameters().get('userId') || currentUser.Id == ApexPages.currentPage().getParameters().get('userId'))) {
                currentUser = [SELECT Id, Name,UserRoleId,UserRole.Name FROM User WHERE Id = :currentUser.Job_Share_User__c LIMIT 1];
                chosenUser = currentUser.id;
                chosenUserName = currentUser.Name;
            }
            /*else if(currentUser.Job_Share_User__c != null && currentUser.Id == ApexPages.currentPage().getParameters().get('userId'))
            {
                currentUser = [SELECT Id, Name,UserRoleId,UserRole.Name FROM User WHERE Id = :currentUser.Job_Share_User__c LIMIT 1];
                chosenUser = currentUser.id;
                chosenUserName = currentUser.Name;
            }*/
        }
        else {
            System.debug('Job Share loggedInUser ' + loggedInUser.Job_Share_User__c);
            chosenUserName = loggedInUser.Name;
            if(loggedInUser.Job_Share_User__c != null && null == ApexPages.currentPage().getParameters().get('userId')) {
                currentUser = [SELECT Id, Name,UserRoleId,UserRole.Name FROM User WHERE Id = :loggedInUser.Job_Share_User__c LIMIT 1];
                chosenUser = currentUser.id;
                chosenUserName = currentUser.Name;
            }
            
        }
        
        getSelUserRole= chosenUser != null ? currentUser.UserRole.Name : loggedInUser.UserRole.Name ;
        boolean isSuperUser = SuperUserRoles__c.getAll().containsKey(loggedInUser.Profile.Name) ? true : false;

        getUsersList();
        childUserIds = new Set<Id>();
        performanceLabels  = new List<String>();
        performanceKeys = getPerformanceLabels();
        // Start: GLID Changes
        if(isNationalUser && String.isBlank(chosenGlidoption)) {chosenGlidoption='All';} 
        if(isNationalUser && String.isBlank(chosenDMAoption)) {chosenDMAoption='All';} 
        fetchGLIDdetails(); 
        // End: GLID Changes
        fetchBudgetDMAdetails();
        // Start: GLID Changes
        availableBudgetDMAvalues = budgetDMAList != null && !budgetDMAList.isEmpty() ? '(\'' + String.join(budgetDMAList,'\',\'') + '\')' : '';
        System.debug(' $$$availableBudgetDMAvalues ::: ' +availableBudgetDMAvalues); 
        availableGlidvalues = glidList != null && !glidList.isEmpty() ? '(\'' + String.join(glidList,'\',\'') + '\')' : '';
        System.debug(' $$$availableGlidvalues ::: ' +availableGlidvalues); 
        // End: GLID Changes
        getGridData();
        if(sectionHeight >= 9) { sectionHeight = 9 * 40; }
        else { sectionHeight = (sectionHeight+2)*40; }
        newsSectionHeight = ((newsTotalsMap.size() + 2)*40);
        hasPoliticalData = politicalTotalsMap.isEmpty() ? false : true;
        hasTradeData = tradeTotalsMap.isEmpty() ? false : true;
        hasNewsData = newsTotalsMap.isEmpty() ? false : true;
        System.debug(' ### hasPoliticalData ::::: ' +hasPoliticalData + ' ### hasTradeData ::: '+hasTradeData+ ' ### hasNewsData ::: '+hasNewsData);
        //calculateAllPerformancePercentage();
        chosenSalesProbability = String.isBlank(chosenSalesProbability) ? 'All' : chosenSalesProbability;
        appliedFilters = ' Year = ' + chosenFiscalYear + ', User = ' + chosenUserName + ', Product Type = '+appliedProduct ;
      /*if(String.isNotBlank(chosenDMAoption)) {  appliedFilters += ', Budget DMA = ' + chosenDMAoption; }
        else if(budgetDMAList.size() > 0) { appliedFilters += ', Budget DMA = All'; }
        */
        if(isNationalUser) {
            if(String.isNotBlank(chosenGlidoption)) { appliedFilters += ', GLID = ' + chosenGlidoption; } else if (glidList.size() > 0) {appliedFilters += ', GLID = All';} 
            if(String.isNotBlank(chosenDMAoption)) { appliedFilters += ', Budget DMA = ' + chosenDMAoption; } else if(budgetDMAList.size() > 0) { appliedFilters += ', Budget DMA = All'; }
        } 
    //  appliedFilters += ', Actual = ' + isActual + ', Sales probability = '+chosenSalesProbability;
        appliedFilters += ', Actual = ' + isActual;       
        if(isCompanyModel){
            appliedFilters += ', Company Model = ' + isCompanyModel;
        } else {
            appliedFilters += ', Sales probability = '+chosenSalesProbability;
        }
        //START SRSF-2485
        if(opportunityMap.size() > 0)
        {
            opportunityData = JSON.serialize(opportunityMap);   
            oppDetails = JSON.serialize(oppDetailsMap);   
            oppNetAmtData = JSON.serialize(oppNetAmtMap);      
        }
        //END SRSF-2485
        System.debug(' @@@ appliedFilters ::: ' +appliedFilters);
        System.debug(' ##### totalsMap ::::: ' +totalsMap.keySet());
        System.debug(' ##### newsTotalsMap ::::: ' +newsTotalsMap.keySet()); 

        accGroupMapjson = accGroupMap.Size()>0 ? formJSONForAccGroupMap (accGroupMap): NULL;  // SRSF-3393
        System.debug('accGroupMapjson>>>>>>>>'+accGroupMapjson);        
        //END SRSF-2485  
        // START: SRSF-4022
        if(newsRevAccDtls.size() > 0)
        {
            newsRevAccs = JSON.serialize(newsRevAccDtls); 
        }
        System.debug('newsRevAccs>>>>>>>>'+newsRevAccs);   
        // END: SRSF-4022
    }

    public Set<String> availableSalesProb;
    public void fetchsalesProbabilityOptions() {
        availableSalesProb = new Set<String>();
        // List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Opportunity.Sales_Probability__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple) {
            salesProbabilityOptions.add(new SelectOption(f.getLabel(), f.getValue()));
            salesProbabilityPicklistValues.add(f.getValue());
            availableSalesProb.add(f.getValue());
        }
        if(checkSalesProbabilityOptions('100')) {
            salesProbabilityOptions.add(new SelectOption('100%', '100'));
            salesProbabilityPicklistValues.add('100');
        }
        if(checkSalesProbabilityOptions('0')) { salesProbabilityPicklistValues.add('0'); }       
        // return options;
    }

    public Boolean checkSalesProbabilityOptions(String picklistValue) {
        if(!availableSalesProb.contains(picklistValue)) {
            availableSalesProb.add(picklistValue);
            return true;
        }
        return false;
    }

    public PageReference getGridData() {
        System.debug(' calling server method ');
        System.debug('$$$ chosenUser ::: ' +chosenUser);
        hasPolitical = hasTrade = hasNews = false;
        try {
            if(childUserIds.size() == 0 && currentUser.UserRole.Name != null && System.label.AccountTeamRole.startsWith(currentUser.UserRole.Name)) {
                childUserIds.add(chosenUser);
            }
            fetchBudgetData();  // For 'Budget' Records
            fetchAccountRelatedRevenueRecords(); // For 'Booked' Records
            fetchNewsTargetData(); //SRSF-2105
            if(!'Trade'.equalsIgnoreCase(chosenProduct)) {
                wave_forecastCategory = '\'' + 'Opportunity_Budget' + '\'';
                fetchProjectedProposalZoneMonthlyValues();  // For 'Projected' Records
                fetchAdjustOppBudgetPZMVs(); // SRSF - 4489 : Forecast Adjustment 
            }
            else { wave_forecastCategory = '\'' + 'Trade' + '\''; }

            // if(!'Political & Trade'.equalsIgnoreCase(chosenProduct)) { // Condition Added by Bhuvan on 07-Aug-2018
                fetchPendingProposalZoneMonthlyValues();  // For 'Pending' Records
            // } 
            if(!totalsMap.isEmpty()) { 
                fetchPendingProjectedData(); // To show Pending+Projected Data : 10-06-2019
                fetchBookedPendingProjectedForecastAdjData (); // SRSF - 4489
            //  fetchBookedPendingProjectedData(); // To show Booked+Pending+Projected Data : 10-06-2019
                fetchGapData (); // To show Budget-Booked data : 10-06-2019                
            }

            calculateQuarterlyTotals();
            if(forecastWrapMap != null && !forecastWrapMap.isEmpty()) { reArrangeAccGroupMap(); }
            System.debug(' ### prodListForTotals ::: ' +prodListForTotals + ' ### prodListForTradeTotals ::: ' + prodListForTradeTotals + ' #### prodListForPoliticalTotals ' +prodListForPoliticalTotals);
            System.debug(' ### totalsMap ::: ' +totalsMap + ' and keyset is :::: ' +totalsMap.keySet());
            System.debug(' ### politicalTotalsMap :::  ' +politicalTotalsMap);

            if(!totalsMap.isEmpty()) { //calculatePerformancePercentage();
                calculateAllPerformancePercentage();
            }
            if(totalsMap != null)  displayTotalsTable = totalsMap.isEmpty() ? false : true ;
            if(performanceMap1 != null)  displayPerformanceTable = performanceMap1.isEmpty() ? false : true ;
            if(accGroupMap != null)  displayTable = accGroupMap.isEmpty() ? false : true ;
            loadSpinner = false; 
            // Start: SRSF-1785 Changes
            if(totalsMap != null && totalsMap.containsKey(ROWTYPE_BUDGET)) {
                prodListForTotals.add(ROWTYPE_BUDGET);
            }

            if(totalsMap != null && totalsMap.containsKey(ROWTYPE_BOOKED)) {
                prodListForTotals.add(ROWTYPE_BOOKED);
            }
            
            if(totalsMap != null && totalsMap.containsKey(ROWTYPE_PENDING_PROJECTED)) {
                prodListForTotals.add(ROWTYPE_PENDING_PROJECTED);      
            } 

            /*if(totalsMap != null && totalsMap.containsKey(ROWTYPE_BOOKED_PENDING_PROJECTED)) {
                prodListForTotals.add(ROWTYPE_BOOKED_PENDING_PROJECTED);          
            }*/
            // START : SRSF-4489
            if(totalsMap != null && totalsMap.containsKey(ROWTYPE_BOOKED_PENDING_PROJECTED_FORECAST_ADJUSTMENT)) {
                prodListForTotals.add(ROWTYPE_BOOKED_PENDING_PROJECTED_FORECAST_ADJUSTMENT);          
            }
            // END : SRSF-4489
            if(totalsMap != null && totalsMap.containsKey(ROWTYPE_GAP)) {
                prodListForTotals.add(ROWTYPE_GAP);         
            }  
            
            if(totalsMap != null && totalsMap.containsKey(ROWTYPE_PENDING)) {
                prodListForTotals.add(ROWTYPE_PENDING);
            }
            if(totalsMap != null && totalsMap.containsKey(ROWTYPE_PROJECTED)) {
                prodListForTotals.add(ROWTYPE_PROJECTED);
            } 
            // End: SRSF-1785 Changes
            // START : SRSF-4489
            if(totalsMap != null && totalsMap.containsKey(ROWTYPE_FORECAST_ADJUSTMENT)) {
                prodListForTotals.add(ROWTYPE_FORECAST_ADJUSTMENT);
            }            
            // END : SRSF-4489  
        }
        catch(Exception ex) {
            System.debug(' ### Exception ::: ' + ex.getMessage()  + ' ### Line Number :::: ' +ex.getLineNumber());            
        }
        return null;
    }
    /*
        Method to retun a list of users for which Budgets can be entered/viewed. It returns based on logged in and selected user.
    */
    public List<SelectOption> getUsersList()
    {
        // START : SRSF-4421
        List<String> custSuccessProfileList=new List<String>();
        String profileName = System.Label.Customer_Success_Profiles;
        if(!CommonUtilities.isStringNullOrEmpty(profileName)){           
            custSuccessProfileList =  profileName.split(',');
        }
        System.debug('currentUser-->'+currentUser);
        System.debug('loggedInUser::'+loggedInUser);
        // END : SRSF-4421 
        options = new List<SelectOption>();
        options.add(new SelectOption('', 'Select a User'));       
        // If Sys Admin Profile then show list of all users
        if (loggedInUser.Profile.Name == SYS_ADMIN_PROFILE || loggedInUser.Profile.Name == REGIONAL_FINANCE_PROFILE){
            // Integer i = 0;
            for (User subUser : [SELECT Id, Name, Budget_DMA__c, Budget_Type__c FROM User WHERE UserRole.Id != NULL AND isActive = true AND( User.UserRole.Name Like 'AE%'  OR User.UserRole.Name Like 'LSM%' OR User.UserRole.Name Like 'NSM%') ORDER BY FirstName]){ //AND Designation__c NOT IN :filteredDesignation AND UserRole.ParentRoleID != NULL
                options.add(new SelectOption(subUser.Id , subUser.Name));
                childUserMap.put(subUser.Id, subUser);
            }
            if (currentUser != loggedInUser){ chosenUser = currentUser.Id; }
            else{ chosenUser = options[0].getValue(); }
        }else if (loggedInUser.Profile.Name == System.Label.BillingProfileName){
            // If Finance profile then show only those users who report to same Manager 
            System.debug('loggedInUser.ManagerId::'+loggedInUser.ManagerId);           
            Set<Id> allRelatedUserIds = getAllSubUserIds(new Set<Id>{loggedInUser.ManagerId});
            allRelatedUserIds.remove(loggedInUser.Id);
            for (User subUser : [SELECT Id, Name, Budget_DMA__c, Budget_Type__c FROM User WHERE UserRole.Id != NULL  AND isActive = true AND Id IN:allRelatedUserIds ORDER BY firstname]) {
                options.add(new SelectOption(subUser.Id , subUser.Name));
                childUserMap.put(subUser.Id, subUser);
            }
            if (currentUser != loggedInUser){ chosenUser = currentUser.Id; }
            else{ chosenUser = options[0].getValue(); }
        } 
        // START: SRSF-4421: show all Account Executives, Interconnect Account Executive
        else if(custSuccessProfileList.contains(loggedInUser.Profile.Name))
        {             
            /*String userListQry = 'SELECT Id, Name, Budget_DMA__c, Budget_Type__c FROM User WHERE isActive = TRUE AND (Profile.Name IN (\'Master - Interconnect Account Executive\',\'Master - Account Executive\')';*/
            String userListQry = 'SELECT Id, Name, Budget_DMA__c, Budget_Type__c FROM User WHERE isActive = TRUE AND ((Profile.Name IN (\'Master - Interconnect Account Executive\',\'Master - Account Executive\') AND Region__c =\''+ loggedInUser.Region__c +'\')';

            if (loggedInUser.Profile.Name == 'Master - Sales Support Manager'){ 
                userListQry+=' OR (UserRole.ParentRoleID != NULL AND (ManagerId = \'' + loggedInUser.Id +'\' OR ManagerId = \'' + currentUser.Id+'\'))';
            } 
            userListQry+= ') ORDER BY FirstName';  
            System.debug('userListQry>>>>'+userListQry);

            options.add(new SelectOption(loggedInUser.Id , loggedInUser.Name)); 
            for (User subUser : Database.query(userListQry)){
                options.add(new SelectOption(subUser.Id , subUser.Name));
                childUserMap.put(subUser.Id, subUser);
            }      
            
            if (currentUser != loggedInUser){ chosenUser = currentUser.Id; }
            else{ chosenUser = options[0].getValue(); } 
        }
        // END : SRSF-4421
        else{
            // Show only those users which report to this user
            options.add(new SelectOption(loggedInUser.Id , loggedInUser.Name));
            for (User subUser : [SELECT Id, Name, Budget_DMA__c, Budget_Type__c FROM User WHERE UserRole.ParentRoleID != NULL AND (ManagerId = :loggedInUser.Id OR ManagerId = :currentUser.Id) AND isActive = true ORDER BY firstname]){ //AND Designation__c NOT IN :filteredDesignation 
                options.add(new SelectOption(subUser.Id , subUser.Name));
                childUserMap.put(subUser.Id, subUser);
            }
            boolean currentUserFound = false;
            for(SelectOption sel : options){
                if(String.isNotEmpty(sel.getValue())) {
                    if (sel.getValue() == currentUser.Id)  currentUserFound = true;
                }
            }

            if (!currentUserFound)  options.add(new SelectOption(currentUser.Id , currentUser.Name));
            chosenUser = currentUser.Id;
        }
        return options;
    }    

    // Commented by bhuvan on 23-Oct-2018 as we are not using this method
    /*public void fetchChildUserIds() {
        if (currentUser.UserRole.Name != null && !System.label.AccountTeamRole.startsWith(currentUser.UserRole.Name)){            
            // Get the first level of reportee's 
            for (User reportee : [SELECT Id,ManagerId,Name,UserRole.ParentRoleId, UserRole.Id FROM User WHERE UserRole.ParentRoleId != NULL AND ManagerId = :currentUser.Id ORDER BY FirstName] ){
                //highestUserMap.put(reportee.Id,reportee.Id);
                globalParentChildUserMap.put(reportee.Id,reportee.Id);
                childUserIds.add(reportee.Id);

            }
            childUserIds.addAll(getAllSubUserIds(childUserIds));
        }
    }*/

    /*
        Method to recursively get the User Hierarchy for the selected user for which Budgets are being requested.
    */
    private Set<Id> getAllSubUserIds(Set<ID> userIds){
        Set<ID> currentUserIds = new Set<ID>();
        Map<String,String> localParentChildUserMap = new Map<String,String>();
        // get all of the user underneath the passed user
        for(User usr :[select Id,ManagerId FROM User WHERE ManagerId IN :userIds AND isActive = true]) { //AND Designation__c NOT IN :filteredDesignation AND UserRole.ParentRoleID != null
            currentUserIds.add(usr.Id);
            localParentChildUserMap.put(usr.Id,usr.ManagerId);
        }
        
        // go fetch some more users!
        if(currentUserIds.size() > 0) {
            System.debug(' @@@ entered @@@ ');
            for (String userId : localParentChildUserMap.keySet()){
                String managerId = localParentChildUserMap.get(userId);
                System.debug('managerId::'+managerId);
                System.debug('get managerId::'+globalParentChildUserMap.get(managerId));
                // Map the user to the record against which the records will be aggregated for viewing
                if (globalParentChildUserMap != null && globalParentChildUserMap.containsKey(managerId) && globalParentChildUserMap.get(managerId) != null){
                    globalParentChildUserMap.put(userId,globalParentChildUserMap.get(managerId));
                }
            }
            currentUserIds.addAll(getAllSubUserIds(currentUserIds));
        }
        return currentUserIds;
    }

    /*
        Method to retun a list of years for which Budgets can be entered/viewed. It returns CurrYear -1 - CurrYear+5 as option in dropdown.
    */
    public List<SelectOption> getFiscalYear(){
        List<SelectOption> options = new List<SelectOption>();         
        Integer startYear = Date.today().year()-2;  // SRSF-2595
        Integer endYear =  startYear + 6;  // SRSF-2595
        for(Integer i = startYear; i < endYear; i++){
            options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        return options;
    }

    public void fetchBudgetData() {
        // typeAmnt = new Map<String,List<Decimal>>(); 
       //Start : SRSF-2081   Comment below query and added new one
      /* Commented as part of SRSF-2104
      String budgetQuery = 'SELECT SUM(Amount__c) rAmt ,CALENDAR_MONTH(Broadcast_Month_Date__c) bMonth, product_line__C prod FROM Budget__c WHERE Account__r.RecordType.Name != \'Competitor Account\' AND BudgetAE__c = :chosenUser AND Year__c =: chosenFiscalYear AND Amount__c != 0 ';*/ // replaced Amount__c > 0 with Amount__c != 0

       /* String budgetQuery = 'SELECT SUM(Amount__c) rAmt ,CALENDAR_MONTH(Broadcast_Month_Date__c) bMonth, Product_Line__c prod FROM Sales_Budget__c WHERE Advertiser__r.RecordType.Name != \'Competitor Account\' AND Budget_User__c = :chosenUser AND Year__c =: chosenFiscalYear AND Amount__c > 0 AND Type__c NOT IN (\'Workflow\', \'Forecast\')';*/
        // End : SRSF-2081
        // if('Political & Trade'.equalsIgnoreCase(chosenProduct))
            // budgetQuery+= ' AND Product_Line__c IN (\'Political\',\'Trade\') ';
      
        //Start : SRSF-2104
        String budgetQuery = 'SELECT SUM(Amount__c) rAmt ,CALENDAR_MONTH(Broadcast_Month_Date__c) bMonth, product_line__C prod FROM Budget__c WHERE Account__r.RecordType.DeveloperName != \'Competitor_Account\' AND RecordType.DeveloperName!=\'NewsTarget\' AND Year__c =: chosenFiscalYear AND Amount__c != 0 '; //Added AND RecordType.DeveloperName!=\'NewsTarget\'
        /* // START : Commented for SRSF-3756
        if('Master - Local Sales Manager'.equalsIgnoreCase([SELECT Id, Profile.Name FROM User WHERE Id = :chosenUser].Profile.Name)) isLocalUser = true;

        if(isLocalUser){
            Map<Id,User> aeUsersMap = new Map<ID, User>([SELECT Id, Name FROM User WHERE HR_Manager__c= :chosenUser AND Profile.Name = 'Master - Account Executive' AND IsActive = TRUE]);
            if(aeUsersMap.size()>0) {
                Set<Id> aeUserIds = aeUsersMap.keySet();
                System.debug(' $$$ aeUserIds ::: ' +aeUserIds);
                budgetQuery+=  ' AND BudgetAE__c IN :aeUserIds';
            }    
        } 
        else 
        // END : Commented for SRSF-3756  */
        budgetQuery+=  ' AND BudgetAE__c = :chosenUser';
        //End : SRSF-2104
        //START - SRSF-3757
        List<String> profileLst = new List<String>{'Master - Account Executive','Master - Interconnect Account Executive'};
    
        if(profileLst.contains([SELECT Id, Profile.Name FROM User WHERE Id = :chosenUser].Profile.Name)){
            budgetQuery+=  ' AND AE_Budget_Interval__c = TRUE';
        }
        //END - SRSF-3757        
        if(('Political'.equalsIgnoreCase(chosenProduct) || 'Trade'.equalsIgnoreCase(chosenProduct)))
            budgetQuery+= ' AND Product_Line__c =: chosenProduct ';
        else
            budgetQuery+= ' AND Product_Line__c NOT IN (\'Political\',\'Trade\') ';
        // Start : SRSF-2072
        if(isNationalUser) {          
            if(String.isNotBlank(availableBudgetDMAvalues) && 'All'.equalsIgnoreCase(chosenDMAoption)){
                budgetQuery += ' AND DMA__c IN ' + availableBudgetDMAvalues;
            } 
            else { budgetQuery += ' AND DMA__c =: chosenDMAoption'; }
         }
         //End : SRSF-2072
        budgetQuery += ' Group BY Calendar_Month(Broadcast_Month_Date__c), Product_Line__c';
        AggregateResult[] budgetResults = Database.query(budgetQuery);
        System.debug(' $$$ budgetResults ::: ' +budgetResults);
        performWeightageCalculation = false;
        if(budgetResults.size() > 0) {
            calculateTotalsSection(budgetResults, ROWTYPE_BUDGET);
          //  prodListForTotals.add(ROWTYPE_BUDGET); // Commented : SRSF-1785
            prodListForTradeTotals.add(ROWTYPE_BUDGET);
            prodListForPoliticalTotals.add(ROWTYPE_BUDGET);
        }
        /*else {
            prodListForTotals.remove(3);
        }*/
        if(totalsMap != null && totalsMap.containsKey(ROWTYPE_BUDGET)) {
            Map<String,List<Decimal>> existingBudgetRows = totalsMap.get(ROWTYPE_BUDGET);
            List<Decimal> totalRowAmounts = calculateTotalForTwoRows(existingBudgetRows); // Calculate total row for each individual row type (like Pending, Booked, Budget.) in totals section.
            existingBudgetRows.put('Total', totalRowAmounts);
            totalsMap.put(ROWTYPE_BUDGET, existingBudgetRows);
            sectionHeight += existingBudgetRows.size();
        }
    }

    // SRSF-1785 changes Start : 10-06-2019

    public Map<String,List<Decimal>> fetchDataByRowType (String rowType, Set<String> prodSet){
        Map<String,List<Decimal>> dataMap = new Map<String,List<Decimal>>();
        if(totalsMap.containsKey(rowType)) {
            for(String str : totalsMap.get(rowType).keySet()){ 
                prodSet.add(str);
                if(totalsMap.get(rowType).containsKey(str)) {
                    dataMap.put(str,totalsMap.get(rowType).get(str));
                    System.debug('dataMap>>>>>'+dataMap);
                }
            }
        }
        return dataMap; 
    }

    public void fetchPendingProjectedData () {
        Map<String,List<Decimal>> pendingTotalsMap = new Map<String,List<Decimal>>();
        Map<String,List<Decimal>> projectedTotalsMap = new Map<String,List<Decimal>>();       
        Set<String> prodSet = new Set<String>();

        pendingTotalsMap = fetchDataByRowType (ROWTYPE_PENDING, prodSet);
        projectedTotalsMap = fetchDataByRowType (ROWTYPE_PROJECTED, prodSet);       

        for (String str : prodSet){        
            List<Decimal> pendingProjMap = calculateProductwiseTotals (null, pendingTotalsMap, projectedTotalsMap, null, str);
            Map<String,List<Decimal>> pendingProjRows = new Map<String,List<Decimal>> (); 
            System.debug('pendingProjRows>>>>>'+pendingProjRows);
            pendingProjRows.put(str, pendingProjMap);
            if(totalsMap.containsKey(ROWTYPE_PENDING_PROJECTED)){
                totalsMap.get(ROWTYPE_PENDING_PROJECTED).put(str, pendingProjMap);
            } else {
                totalsMap.put(ROWTYPE_PENDING_PROJECTED,pendingProjRows);
            }   
        }  
    }

    /*public void fetchBookedPendingProjectedData () {
        Map<String,List<Decimal>> bookedTotalsMap = new Map<String,List<Decimal>>();
        Map<String,List<Decimal>> pendingTotalsMap = new Map<String,List<Decimal>>();
        Map<String,List<Decimal>> projectedTotalsMap = new Map<String,List<Decimal>>(); 
        Set<String> prodSet = new Set<String>(); 
        bookedTotalsMap = fetchDataByRowType (ROWTYPE_BOOKED, prodSet);
        pendingTotalsMap = fetchDataByRowType (ROWTYPE_PENDING, prodSet);
        projectedTotalsMap = fetchDataByRowType (ROWTYPE_PROJECTED, prodSet);
        
        for (String str : prodSet){   
            List<Decimal> bookedPendingProjMap = calculateProductwiseTotals (bookedTotalsMap, pendingTotalsMap, projectedTotalsMap, null, str);
            Map<String,List<Decimal>> bookedPendingProjRows = new Map<String,List<Decimal>> (); 
            bookedPendingProjRows.put(str, bookedPendingProjMap);
            System.debug('bookedPendingProjRows>>>>>'+bookedPendingProjRows);
            if(totalsMap.containsKey(ROWTYPE_BOOKED_PENDING_PROJECTED)){
                totalsMap.get(ROWTYPE_BOOKED_PENDING_PROJECTED).put(str, bookedPendingProjMap);
            } else {
                totalsMap.put(ROWTYPE_BOOKED_PENDING_PROJECTED,bookedPendingProjRows);
            }   
        }
    }*/

    // SRSF - 4489 : Added forecastAdjustment calculations
    public List<Decimal> calculateProductwiseTotals (Map<String, List<Decimal>> existingBookedRows, Map<String, List<Decimal>> existingPendingRows, Map<String, List<Decimal>> existingProjectedRows, Map<String, List<Decimal>> existingforecastAdjRows, String prod) {
        List<Decimal> totalAmounts = new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0,0};
        List<Decimal> bookedAmounts = new List<Decimal>();
        List<Decimal> pendingAmounts = new List<Decimal>();
        List<Decimal> projectedAmounts = new List<Decimal>();
        List<Decimal> forecastAdjAmounts = new List<Decimal>();
        try {
                if (existingBookedRows!=null){bookedAmounts = existingBookedRows.get(prod);}     
                if (existingPendingRows!=null){pendingAmounts = existingPendingRows.get(prod);} 
                if (existingProjectedRows!=null){projectedAmounts = existingProjectedRows.get(prod);}
                if (existingforecastAdjRows!=null){forecastAdjAmounts = existingforecastAdjRows.get(prod);}                         
                for(Integer i=0; i<=12; i++) {  
                   if (bookedAmounts!=null && !bookedAmounts.isEmpty()){             
                    totalAmounts[i] += bookedAmounts[i];
                   } 
                   if (pendingAmounts!=null && !pendingAmounts.isEmpty()) {
                    totalAmounts[i] += pendingAmounts[i];
                   }  
                   if (projectedAmounts!=null && !projectedAmounts.isEmpty()){
                    totalAmounts[i] += projectedAmounts[i];
                   }
                   if (forecastAdjAmounts!=null && !forecastAdjAmounts.isEmpty()){
                    totalAmounts[i] += forecastAdjAmounts[i];
                   }
               }
            System.debug('### totalAmounts ::: ' + totalAmounts);
        }
        catch(Exception ex) { system.debug('### Exception ::: ' + ex.getMessage() + ' ### line number ::: ' +ex.getLineNumber());  }
        return totalAmounts;
    }
    

    public void fetchGapData () {
        Map<String,List<Decimal>> budgetTotalsMap = new Map<String,List<Decimal>>();
        Map<String,List<Decimal>> bookedTotalsMap = new Map<String,List<Decimal>>(); 
        Set<String> prodSet = new Set<String>(); 

        budgetTotalsMap = fetchDataByRowType (ROWTYPE_BUDGET, prodSet);      
        bookedTotalsMap = fetchDataByRowType (ROWTYPE_BOOKED, prodSet);
        
        for(String str : prodSet){ 
            List<Decimal> gaps = calculateGap (budgetTotalsMap, bookedTotalsMap, str);
            Map<String,List<Decimal>> gapRows = new Map<String,List<Decimal>> (); 
            gapRows.put(str, gaps);
            if(totalsMap.containsKey(ROWTYPE_GAP)){ totalsMap.get(ROWTYPE_GAP).put(str, gaps);} 
            else { totalsMap.put(ROWTYPE_GAP,gapRows); }    
            System.debug('totalsMap!!!!!'+totalsMap);
        } 
    }


    public List<Decimal> calculateGap (Map<String, List<Decimal>> existingBudgetRows, Map<String, List<Decimal>> existingBookedRows, String prod) {
        List<Decimal> totalGapAmounts = new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0,0};
        List<Decimal> budgetAmounts = new List<Decimal>();
        List<Decimal> bookedAmounts = new List<Decimal>();
        try {  
                if (existingBudgetRows!=null){budgetAmounts = existingBudgetRows.get(prod);}
                if (existingBookedRows!=null){bookedAmounts = existingBookedRows.get(prod);}              
                for(Integer i=0; i<=12; i++) {
                    if (budgetAmounts!=null && bookedAmounts!=null){ totalGapAmounts[i] += bookedAmounts[i]-budgetAmounts[i]; }
                    if (budgetAmounts==null && bookedAmounts!=null){ totalGapAmounts[i] += bookedAmounts[i]; } // Treating Budget Amount as 0
                    if (budgetAmounts!=null && bookedAmounts==null){  totalGapAmounts[i] += 0-budgetAmounts[i]; } // Treating Booked Amount as 0
                }          
            System.debug('### totalGapAmounts ::: ' + totalGapAmounts);
        }
        catch(Exception ex) { system.debug('### Exception ::: ' + ex.getMessage() + ' ### line number ::: ' +ex.getLineNumber());  }
        return totalGapAmounts;
    }
    
    // SRSF-1785 changes End : 10-06-2019    

    // To calculate Rowwise Totals specific to Account
    public List<Decimal> calculateTotalForTwoRows(Map<String, List<Decimal>> existingBudgetRows) {
        System.debug(' ### existingBudgetRows keyset ::: ' +existingBudgetRows.keySet());
        List<Decimal> totalRowAmounts = new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0,0};
        try {
            for(String prod : existingBudgetRows.keySet()) {
                System.debug('### existingBudgetRows.get(prod) ::: ' + existingBudgetRows.get(prod));
                List<Decimal> monthAmounts = existingBudgetRows.get(prod);
                for(Integer i=0; i<=12; i++) { totalRowAmounts[i] += monthAmounts[i]; }
            }
            System.debug('### totalRowAmounts ::: ' + totalRowAmounts);
        }
        catch(Exception ex) {
            System.debug('### Exception ::: ' + ex.getMessage() + ' ### line number ::: ' +ex.getLineNumber());
        }
        return totalRowAmounts;
    }

    // START : SRSF-3393 : To calculate Rowwise Totals specific to Account & RowType
    public List<Decimal> calculateRowwiseTotalForTwoRows(Map<String, List<Decimal>> existingBudgetRows, String rowType) {
        System.debug(' ### existingBudgetRows keyset ::: ' +existingBudgetRows.keySet());
        List<Decimal> totalRowAmounts = new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0,0};
        try {
            for(String prod : existingBudgetRows.keySet()) {
                System.debug('prod>>>>>'+prod);
                if (prod.contains(rowType)){
                    System.debug('### existingBudgetRows.get(prod) ::: ' + existingBudgetRows.get(prod));
                    List<Decimal> monthAmounts = existingBudgetRows.get(prod);
                    for(Integer i=0; i<=12; i++) { totalRowAmounts[i] += monthAmounts[i]; }
                }        
            }
            System.debug('### totalRowAmounts ::: ' + totalRowAmounts);
        }
        catch(Exception ex) {
            System.debug('### Exception ::: ' + ex.getMessage() + ' ### line number ::: ' +ex.getLineNumber());
        }
        return totalRowAmounts;
    }
    // END : SRSF-3393

    public void fetchAccountRelatedRevenueRecords() {
        // typeAmnt = new Map<String,List<Decimal>>();
        String avlRevenueType = availableRevenueTypeList != null && !availableRevenueTypeList.isEmpty() ? '(\'' + String.join(availableRevenueTypeList,'\',\'') + '\')' : '';

     // Commented below line: 23-08-2019
     // String availableBudgetDMAvalues = budgetDMAList != null && !budgetDMAList.isEmpty() ? '(\'' + String.join(budgetDMAList,'\',\'') + '\')' : '';

        wave_RevenueType = String.isNotBlank(avlRevenueType) ? (avlRevenueType.removeEnd(')')).removeStart('(') : '';
        wave_budgetDMA = String.isNotBlank(availableBudgetDMAvalues) ? (availableBudgetDMAvalues.removeEnd(')')).removeStart('(') : '';

        System.debug(' ### wave_RevenueType ::: ' +wave_RevenueType + ' ### avlRevenueType ::: ' +avlRevenueType + ' ### wave_budgetDMA ::: ' +wave_budgetDMA + ' ### availableBudgetDMAvalues ::: ' +availableBudgetDMAvalues);
        // Code Changes for SRSF – 1165 – Code Starts
        // String aliasChosenProduct = 'Linear'.equalsIgnoreCase(chosenProduct) ? 'Core' : chosenProduct;
    //  String query = 'SELECT Sum(Net_Projected_Amount__c) rAmt, Product_Line__c prod, Revenue_Type__c revType, CALENDAR_MONTH(Broadcast_Month_Date__c) bMonth, Advertiser__r.Name adv, Advertiser__c advId FROM Revenue__c WHERE Year__c =: chosenFiscalYear  AND Account_Executive__c != null AND Account_Executive__c =: chosenUser AND Net_Projected_Amount__c > 0  AND Broadcast_Month_Date__c != null '; // Comment on 20-02-2020
        String query = 'SELECT Sum(Net_Projected_Amount__c) rAmt, Product_Line__c prod, Revenue_Type__c revType, CALENDAR_MONTH(Broadcast_Month_Date__c) bMonth, Advertiser__r.Name adv, Advertiser__c advId FROM Revenue__c WHERE Year__c =: chosenFiscalYear  AND Account_Executive__c != null AND Account_Executive__c =: chosenUser AND Broadcast_Month_Date__c != null ';
        // Product_Line__c prod
        /*if('Political & Trade'.equalsIgnoreCase(chosenProduct))
            query+= ' AND Product_Line__c IN (\'Political\',\'Trade\') ';
        else
            query+= ' AND Product_Line__c NOT IN (\'Political\',\'Trade\') ';*/
    //  if(String.isNotBlank(avlRevenueType)) query += ' AND Revenue_Type__c IN ' + avlRevenueType;    
        // Updated to include Wide Orbit Revenues in Forecast Matrix    
        if(String.isNotBlank(avlRevenueType)) query += ' AND (Source__c=\'WO\' OR (Net_Projected_Amount__c > 0 AND Revenue_Type__c IN ' + avlRevenueType+'))';  // SRSF-2072 : 20-02-2020      
        // query += ' AND Revenue_Type__c LIKE \'%' + aliasChosenProduct + '%\'';
        System.debug(' $$$ chosenDMAoption ::: ' +chosenDMAoption);
        System.debug(' $$$ availableBudgetDMAvalues ::: ' +availableBudgetDMAvalues); 
        System.debug(' $$$ availableGlidvalues-1 ::: ' +availableGlidvalues);

         // Start: 22-08-2019
        System.debug(' $$$ chosenGlidoption ::: ' +chosenGlidoption);
        if(String.isNotBlank(chosenGlidoption)) {

            if(String.isNotBlank(availableBudgetDMAvalues) && 'All'.equalsIgnoreCase(chosenDMAoption)){
                query += ' AND Budget_DMA__c IN ' + availableBudgetDMAvalues;
            }
            else {
                query += ' AND Budget_DMA__c =: chosenDMAoption';
                wave_budgetDMA = '\'' + chosenDMAoption + '\'';   
            }
        } else if(String.isNotBlank(chosenGlidoption) && 'All'.equalsIgnoreCase(chosenGlidoption)){
            query += ' AND Budget_DMA__c IN ' + availableBudgetDMAvalues;
        }

        // End: 22-08-2019
        /* // Commented by Sridhar: 22-08-2019
        if(String.isNotBlank(chosenDMAoption)) {
            if(String.isNotBlank(availableBudgetDMAvalues) && 'All'.equalsIgnoreCase(chosenDMAoption)){
                query += ' AND Budget_DMA__c IN ' + availableBudgetDMAvalues;
            }
            else {
                query += ' AND Budget_DMA__c =: chosenDMAoption';
                wave_budgetDMA = '\'' + chosenDMAoption + '\'';   
            }
        }
        */
        query += ' GROUP BY Advertiser__r.Name, Advertiser__c, Product_Line__c, Revenue_Type__c, CALENDAR_MONTH(Broadcast_Month_Date__c) ORDER BY Advertiser__r.Name';
        System.debug(' ### Query Used ::: ' +query);
        AggregateResult[] revenueList = Database.query(query);
        System.debug(' $$$ revenueList size ::: ' +revenueList.size());
        performWeightageCalculation = false;
        // Code Changes for SRSF – 1165 – Code ends
        if(revenueList.size() > 0) {
            hasPolitical = avlRevenueType.contains('Political') ? true : false;
            hasTrade = avlRevenueType.contains('Trade') ? true : false;
            try {
                calculateAggregateResultAccountWise(revenueList, ROWTYPE_BOOKED);
                calculateTotalsSection(revenueList, ROWTYPE_BOOKED);
                if(totalsMap.containsKey(ROWTYPE_BOOKED) || (hasPolitical && politicalTotalsMap.containsKey(ROWTYPE_BOOKED) || (hasTrade && tradeTotalsMap.containsKey(ROWTYPE_BOOKED)))) {
                    /*Map<String,List<Decimal>> existingBudgetRows = totalsMap.get(ROWTYPE_BOOKED);
                    List<Decimal> totalRowAmounts = calculateTotalForTwoRows(existingBudgetRows);
                    existingBudgetRows.put('Total', totalRowAmounts);
                    totalsMap.put(ROWTYPE_BOOKED, existingBudgetRows);
                    sectionHeight += existingBudgetRows.size();
                    prodListForTotals.add(ROWTYPE_BOOKED);*/

                    Map<String,List<Decimal>> existingBudgetRows = new Map<String,List<Decimal>>();
                    if(!hasPolitical && !hasTrade) { existingBudgetRows = totalsMap.get(ROWTYPE_BOOKED); }
                    if(hasTrade) { existingBudgetRows = tradeTotalsMap.get(ROWTYPE_BOOKED); }
                    if(hasPolitical) { existingBudgetRows = politicalTotalsMap.get(ROWTYPE_BOOKED); }
                    List<Decimal> totalRowAmounts = calculateTotalForTwoRows(existingBudgetRows);
                    existingBudgetRows.put('Total', totalRowAmounts);
                    if(!hasPolitical && !hasTrade) {
                        totalsMap.put(ROWTYPE_BOOKED, existingBudgetRows);
                       // prodListForTotals.add(ROWTYPE_BOOKED); // Commented: SRSF-1785
                    }
                    if(hasTrade) {
                        tradeTotalsMap.put(ROWTYPE_BOOKED, existingBudgetRows);
                        prodListForTradeTotals.add(ROWTYPE_BOOKED);
                    }
                    if(hasPolitical) {
                        politicalTotalsMap.put(ROWTYPE_BOOKED, existingBudgetRows);
                        prodListForPoliticalTotals.add(ROWTYPE_BOOKED);
                    }
                    sectionHeight += existingBudgetRows.size();
                }
            }
            catch(Exception ex) {
                System.debug(' ### Exception ::: ' + ex.getMessage()  + ' ### Line Number :::: ' +ex.getLineNumber());                
            }
        }
    }

    public void fetchPendingProposalZoneMonthlyValues() {
        // typeAmnt = new Map<String,List<Decimal>>();     
        // Code Changes for SRSF – 1165 – Code Starts
        List<String> recordTypeIdList = new List<String>();
  
        /*if( 'Political & Trade'.equalsIgnoreCase(chosenProduct)) {
            recordTypeIdList.add(String.valueOf(UtilityClass.getRecordTypeID(new Proposal__c(),'Political')));
            recordTypeIdList.add(String.valueOf(UtilityClass.getRecordTypeID(new Proposal__c(),'Trade')));
        }
        else {
            recordTypeIdList.add(String.valueOf(UtilityClass.getRecordTypeID(new Proposal__c(),'Linear')));
        }*/
        recordTypeIdList.add(String.valueOf(UtilityClass.getRecordTypeID(new Proposal__c(),chosenProduct)));
        System.debug(' ### recordTypeIdList ::: ' +recordTypeIdList);
        // Code Changes for SRSF – 1165 – Code Ends
        System.debug(' $$$ chosenUser ::: ' +chosenUser + ' $$$ chosenFiscalYear ::: ' +chosenFiscalYear + ' $$$ selectedSalesProb ::: ' +selectedSalesProb);
      
       /* Commented by 13-Aug-2019
       AggregateResult[] pendingResults = [SELECT CALENDAR_MONTH(Broadcast_Month_Date__c) bMonth ,Sum(Net_Amount__c) rAmt ,Schedule_Type__c prod, Advertiser__r.Name Adv, Advertiser__c advId, Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c salesProbability FROM Proposal_Zone_Monthly_Value__c WHERE Year__c =: chosenFiscalYear  AND Proposal_Zone__r.Proposal__r.RecordTypeId IN :recordTypeIdList AND Proposal_Zone__r.Proposal__r.Active__c = true  AND Proposal_Zone__r.Proposal__r.Opportunity__r.OwnerId =: chosenUser AND Broadcast_Month_Date__c != null AND Status_Type__c = :ROWTYPE_PENDING AND (Proposal_Zone__r.Proposal__r.Opportunity__r.isClosed= false  OR Proposal_Zone__r.Proposal__r.Opportunity__r.isWon = true ) AND Net_Amount__c > 0 AND Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c IN : selectedSalesProb GROUP BY Advertiser__c, Advertiser__r.Name,Schedule_Type__c, CALENDAR_MONTH(Broadcast_Month_Date__c), Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c ORDER BY Advertiser__r.Name ASC]; */

        String query = 'SELECT CALENDAR_MONTH(Broadcast_Month_Date__c) bMonth';
        if(isCompanyModel){  query += ' ,Sum(Broadcast_Amount__c) rAmt';
        }else query += ' ,Sum(Net_Amount__c) rAmt, Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c salesProbability';

        if(isNationalUser) query +=  ' ,Proposal_Zone__r.Proposal__r.Opportunity__r.DMA__c dma';
    
        query += ' ,Schedule_Type__c prod, Advertiser__r.Name Adv, Advertiser__c advId, Proposal_Zone__r.Proposal__r.Opportunity__c oppId, Proposal_Zone__r.Proposal__r.Opportunity__r.Name oppName FROM Proposal_Zone_Monthly_Value__c WHERE Year__c =: chosenFiscalYear  AND Proposal_Zone__r.Proposal__r.RecordTypeId IN :recordTypeIdList AND Proposal_Zone__r.Proposal__r.Active__c = true  AND Proposal_Zone__r.Proposal__r.Opportunity__r.OwnerId =: chosenUser AND Broadcast_Month_Date__c != null AND Status_Type__c = :ROWTYPE_PENDING AND (Proposal_Zone__r.Proposal__r.Opportunity__r.isClosed= false  OR Proposal_Zone__r.Proposal__r.Opportunity__r.isWon = true )';

        if(isCompanyModel){
            query += ' AND Broadcast_Amount__c > 0';
        }else query += ' AND Net_Amount__c > 0 AND Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c IN : selectedSalesProb'; 

        if(isNationalUser) {
          //  String availableBudgetDMAvalues = budgetDMAList != null && !budgetDMAList.isEmpty() ? '(\'' + String.join(budgetDMAList,'\',\'') + '\')' : '';
            if(String.isNotBlank(availableBudgetDMAvalues) && 'All'.equalsIgnoreCase(chosenDMAoption)){
                query += ' AND Proposal_Zone__r.Proposal__r.Opportunity__r.DMA__c IN ' + availableBudgetDMAvalues;
            }
            else { query += ' AND Proposal_Zone__r.Proposal__r.Opportunity__r.DMA__c =: chosenDMAoption'; }
        }
        query +=' GROUP BY Advertiser__c, Advertiser__r.Name,Schedule_Type__c, CALENDAR_MONTH(Broadcast_Month_Date__c), Proposal_Zone__r.Proposal__r.Opportunity__c, Proposal_Zone__r.Proposal__r.Opportunity__r.Name';

        if(!isCompanyModel) query += ', Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c';
        if(isNationalUser) query +=  ' ,Proposal_Zone__r.Proposal__r.Opportunity__r.DMA__c';

        query += ' ORDER BY Advertiser__r.Name ASC';

        AggregateResult[] pendingResults = Database.query(query);
        
        System.debug('### pendingResults size ::: ' +pendingResults + ' $$$$ size :::: ' +pendingResults.size()); 
        performWeightageCalculation = true;
        if(pendingResults.size() > 0) {
            hasPolitical = chosenProduct.equalsIgnoreCase('Political') ? true : false;
            hasTrade = chosenProduct.equalsIgnoreCase('Trade') ? true : false;
            try {
                calculateAggregateResultAccountWise(pendingResults, ROWTYPE_PENDING);
                calculateTotalsSection(pendingResults, ROWTYPE_PENDING);
                if(totalsMap.containsKey(ROWTYPE_PENDING) || (hasPolitical && politicalTotalsMap.containsKey(ROWTYPE_PENDING) || (hasTrade && tradeTotalsMap.containsKey(ROWTYPE_PENDING)))) {
                    Map<String,List<Decimal>> existingBudgetRows = new Map<String,List<Decimal>>();
                    if(!hasPolitical && !hasTrade) { existingBudgetRows = totalsMap.get(ROWTYPE_PENDING); }
                    if(hasTrade) { existingBudgetRows = tradeTotalsMap.get(ROWTYPE_PENDING); }
                    if(hasPolitical) { existingBudgetRows = politicalTotalsMap.get(ROWTYPE_PENDING); }
                    List<Decimal> totalRowAmounts = calculateTotalForTwoRows(existingBudgetRows);
                    existingBudgetRows.put('Total', totalRowAmounts);
                    if(!hasPolitical && !hasTrade) {
                        totalsMap.put(ROWTYPE_PENDING, existingBudgetRows);
                       // prodListForTotals.add(ROWTYPE_PENDING); // Commented: SRSF-1785
                    }
                    if(hasTrade) {
                        tradeTotalsMap.put(ROWTYPE_PENDING, existingBudgetRows);
                        prodListForTradeTotals.add(ROWTYPE_PENDING);
                    }
                    if(hasPolitical) {
                        politicalTotalsMap.put(ROWTYPE_PENDING, existingBudgetRows);
                        prodListForPoliticalTotals.add(ROWTYPE_PENDING);
                    }
                    sectionHeight += existingBudgetRows.size();
                }
                System.debug(' ### tradeTotalsMap :::: ' +tradeTotalsMap + ' ### hasTrade ::: ' + hasTrade + ' ### ');
            }
            catch(Exception ex) {
                System.debug(' ### Exception ::: ' + ex.getMessage()  + ' ### Line Number :::: ' +ex.getLineNumber());                
            }
        }
    }

    public void fetchProjectedProposalZoneMonthlyValues() {
        // typeAmnt = new Map<String,List<Decimal>>();
        List<String> recordTypeIdList = new List<String>();
  
        /*if( 'Political & Trade'.equalsIgnoreCase(chosenProduct)) {
            recordTypeIdList.add(String.valueOf(UtilityClass.getRecordTypeID(new Proposal__c(),'Political')));
            recordTypeIdList.add(String.valueOf(UtilityClass.getRecordTypeID(new Proposal__c(),'Trade')));
            //rt = [SELECT Id FROM RecordType WHERE DeveloperName IN ('Political','Trade') AND SObjectType = 'Proposal__c'];
        }*/
        // else {
            /*recordTypeIdList.add(String.valueOf(UtilityClass.getRecordTypeID(new Proposal__c(),'Opportunity Budget')));*/
            recordTypeIdList.add(String.valueOf(Schema.SObjectType.Proposal__c.getRecordTypeInfosByDeveloperName().get('Opportunity_Budget').getRecordTypeId()));
        // }
         
        // System.debug(' ### recordTypeIdList ::: ' +recordTypeIdList);
        System.debug(' ### wave_forecastCategory ::: ' +wave_forecastCategory);
        /*Commeneted by Usha - 13-Aug-2019

        AggregateResult[] projectedResults = [SELECT CALENDAR_MONTH(Broadcast_Month_Date__c) bMonth ,Sum(Net_Amount__c) rAmt ,Schedule_Type__c prod, Advertiser__r.Name Adv, Advertiser__c advId, Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c salesProbability FROM Proposal_Zone_Monthly_Value__c WHERE Year__c =: chosenFiscalYear AND Proposal_Zone__r.Proposal__r.RecordTypeId IN :recordTypeIdList AND Proposal_Zone__r.Proposal__r.Active__c = true AND Proposal_Zone__r.Proposal__r.Opportunity__r.OwnerId =: chosenUser AND (Proposal_Zone__r.Proposal__r.Opportunity__r.isClosed= false  OR Proposal_Zone__r.Proposal__r.Opportunity__r.isWon = true) AND Broadcast_Month_Date__c != null AND Net_Amount__c > 0 AND Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c IN : selectedSalesProb AND Proposal_Zone__r.Proposal__r.Opportunity__r.Account.Political_Account__c =: isProdTypePolitical GROUP BY Advertiser__c, Advertiser__r.Name,Schedule_Type__c, CALENDAR_MONTH(Broadcast_Month_Date__c), Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c ORDER BY Advertiser__r.Name,CALENDAR_MONTH(Broadcast_Month_Date__c) ASC];*/
        System.debug(' ### recordTypeIdList ### ' +recordTypeIdList);      

        String query = 'SELECT CALENDAR_MONTH(Broadcast_Month_Date__c) bMonth';
        if(isCompanyModel){  query += ' ,Sum(Broadcast_Amount__c) rAmt';
        }else query += ' ,Sum(Net_Amount__c) rAmt, Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c salesProbability';  

        if(isNationalUser) query +=  ' ,Proposal_Zone__r.Proposal__r.Opportunity__r.DMA__c dma';

        query += ' ,Schedule_Type__c prod, Advertiser__r.Name Adv, Advertiser__c advId,  Proposal_Zone__r.Proposal__r.Opportunity__c oppId, Proposal_Zone__r.Proposal__r.Opportunity__r.Name oppName FROM Proposal_Zone_Monthly_Value__c WHERE Year__c =: chosenFiscalYear AND Proposal_Zone__r.Proposal__r.RecordTypeId IN :recordTypeIdList AND Proposal_Zone__r.Proposal__r.Active__c = true AND Proposal_Zone__r.Proposal__r.Opportunity__r.OwnerId =: chosenUser AND (Proposal_Zone__r.Proposal__r.Opportunity__r.isClosed= false  OR Proposal_Zone__r.Proposal__r.Opportunity__r.isWon = true) AND Broadcast_Month_Date__c != null';

        if(isCompanyModel){ query += ' AND Broadcast_Amount__c > 0';
        }else query += ' AND Net_Amount__c > 0 AND Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c IN : selectedSalesProb';

        if(isNationalUser) {
          //  String availableBudgetDMAvalues = budgetDMAList != null && !budgetDMAList.isEmpty() ? '(\'' + String.join(budgetDMAList,'\',\'') + '\')' : '';
            if(String.isNotBlank(availableBudgetDMAvalues) && 'All'.equalsIgnoreCase(chosenDMAoption)){
                query += ' AND Proposal_Zone__r.Proposal__r.Opportunity__r.DMA__c IN ' + availableBudgetDMAvalues;
            }
            else {  query += ' AND Proposal_Zone__r.Proposal__r.Opportunity__r.DMA__c =: chosenDMAoption'; }
        }

        query += ' AND Proposal_Zone__r.Proposal__r.Opportunity__r.Account.Political_Account__c =: isProdTypePolitical GROUP BY Advertiser__c, Advertiser__r.Name,Schedule_Type__c, CALENDAR_MONTH(Broadcast_Month_Date__c), Proposal_Zone__r.Proposal__r.Opportunity__c, Proposal_Zone__r.Proposal__r.Opportunity__r.Name';
        
        if(!isCompanyModel) query += ', Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c';
        if(isNationalUser) query +=  ' ,Proposal_Zone__r.Proposal__r.Opportunity__r.DMA__c';

        query += ' ORDER BY Advertiser__r.Name,CALENDAR_MONTH(Broadcast_Month_Date__c) ASC';

        System.debug('### projected query::: ' +query);
        AggregateResult[] projectedResults = Database.query(query);
        System.debug(' ### projectedResults ::: ' +projectedResults);
        System.debug(' ### projectedResults size ::: ' +projectedResults.size());
        performWeightageCalculation = true;
        if(projectedResults.size() > 0) {
            hasPolitical = isProdTypePolitical ;
            try {
                calculateAggregateResultAccountWise(projectedResults, ROWTYPE_PROJECTED);
                calculateTotalsSection(projectedResults, ROWTYPE_PROJECTED);
                if(totalsMap.containsKey(ROWTYPE_PROJECTED) || (hasPolitical && politicalTotalsMap.containsKey(ROWTYPE_PROJECTED) || (hasTrade && tradeTotalsMap.containsKey(ROWTYPE_PROJECTED)))) {
                    Map<String,List<Decimal>> existingOppBudgetRows = new Map<String,List<Decimal>>();
                    
                    existingOppBudgetRows = hasPolitical ? politicalTotalsMap.get(ROWTYPE_PROJECTED) : totalsMap.get(ROWTYPE_PROJECTED);
                
                    List<Decimal> totalRowAmounts = calculateTotalForTwoRows(existingOppBudgetRows);
                    
                    existingOppBudgetRows.put('Total', totalRowAmounts);
                    if(!hasPolitical) {
                        totalsMap.put(ROWTYPE_PROJECTED, existingOppBudgetRows);
                        //prodListForTotals.add(ROWTYPE_PROJECTED); // Commented: SRSF-1785
                    }
                    if(hasPolitical) {
                        politicalTotalsMap.put(ROWTYPE_PROJECTED, existingOppBudgetRows);
                        prodListForPoliticalTotals.add(ROWTYPE_PROJECTED);
                    }
                    sectionHeight += existingOppBudgetRows.size();
                }
            }
            catch(Exception ex) {
                System.debug(' ### Exception ::: ' + ex.getMessage()  + ' ### Line Number :::: ' +ex.getLineNumber());                
            }
        }
    }

    public void calculateAggregateResultAccountWise(AggregateResult[] aggResList, String rowType) {
        Map<String,List<Decimal>> typeAmount = new Map<String,List<Decimal>>();      
        String comparingKey = '';
        Integer integerToConsider = 1;
        for( AggregateResult rev : aggResList) {
            // System.debug('rev ' +rev );
            accIdMap.put((String)rev.get('Adv'), (String)rev.get('advId'));
            string prodName = '';
            prodName = String.isBlank((String)rev.get('prod'))? 'Linear':(String)rev.get('prod');
            System.debug(' $$$$ prodName ::: ' +prodName );

            if('Yes'.equalsIgnoreCase(Label.displayLinearAsProductType) && prodName.containsIgnoreCase('Linear')) {
                if(prodType_Linear_Map.containsKey(prodName)) {
                    prodName = prodType_Linear_Map.get(prodName);
                }
            }
            List<Decimal> amounts = new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0,0};

            Decimal monthValue = ('Yes'.equalsIgnoreCase(Label.FM_TotalSection_RoundOff)) ? ((Decimal)rev.get('rAmt')) : (((Decimal)rev.get('rAmt')).round(System.RoundingMode.HALF_UP));
            if(!isActual && performWeightageCalculation) {
               String probability = (String)rev.get('salesProbability');
               // System.debug(' $$$ probability ::: ' +probability + ' and month value ::: ' +monthValue + ' $$$ month Index ::: ' +monthIndex);
               monthValue = (monthValue*Integer.valueOf(probability))/100;
               System.debug(' $$$ after applying probability ::: ' +monthValue);
            }

            if(!typeAmount.containsKey((String)rev.get('Adv') + '_' + prodName + '_' + rowType)) {              
                // amounts[Integer.valueOf(rev.get('bMonth'))-1] = ((Decimal)rev.get('rAmt'));                
                amounts[Integer.valueOf(rev.get('bMonth'))-1] = monthValue;
            }
            else {
                //amounts = new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0,0};
                amounts = typeAmount.get((String)rev.get('Adv') + '_' + prodName + '_' + rowType);
                // System.debug('amounts ' +amounts );
                // amounts[Integer.valueOf(rev.get('bMonth'))-1] = amounts[Integer.valueOf(rev.get('bMonth'))] + ((Decimal)rev.get('rAmt'));
                amounts[Integer.valueOf(rev.get('bMonth'))-1] = amounts[Integer.valueOf(rev.get('bMonth'))-1] + monthValue;
            }
            typeAmount.put((String)rev.get('Adv') + '_' + prodName + '_' + rowType,amounts);
            System.debug('$$$$$ amounts :::: ' +amounts );
        }
        System.debug('$$$$ typeAmount :::: ' +typeAmount );
        accProdTypesMap = new Map<String, Set<String>>();

        for(String str : typeAmount.keySet()) {
            String[] keyList = str.split('_');
            if(String.isNotBlank(keyList[1])) { // Check to eliminate the records which doesn't have product type
                if(!accProdTypesMap.containsKey(keyList[0])) {
                    accProdTypesMap.put(keyList[0], new Set<String>{keyList[1]});
                }
                else {
                    accProdTypesMap.get(keyList[0]).add(keyList[1]);
                }
            }
        }
        System.debug('$$$ accProdTypesMap ::: ' +accProdTypesMap);

        for(String str : accProdTypesMap.keySet()) {
            List<productTypeWrapper> productTypeWrapperList = new List<productTypeWrapper>();
            if(String.isNotBlank(str)) {
                for(String prod : accProdTypesMap.get(str)) {
                    String mapKey = str + '_' + prod + '_' + rowType;
                    List<Decimal> prodMonthAmountMap = new list<Decimal>();
                    if(typeAmount.containsKey(mapKey)) { prodMonthAmountMap = typeAmount.get(mapKey); }

                    Map<Integer, Decimal> monthAmountMap = new Map<Integer, Decimal>();
                    for(Integer i =1; i <=prodMonthAmountMap.size(); i++) {
                        monthAmountMap.put( i , prodMonthAmountMap[i-1]);
                    }

                    List<forecastWrapper> budgetForecastWrpList = new List<forecastWrapper>();
                    budgetForecastWrpList.add(new forecastWrapper(rowType, monthAmountMap));
                    populateForecastWrapperMap(str,prod,budgetForecastWrpList);
                }
            }
        }
        System.debug('$$$ forecastWrapMap ::: ' +forecastWrapMap);
    }

    public void populateForecastWrapperMap(String accName, String prodType, List<forecastWrapper> forecastWrpList) {
        if(!forecastWrapMap.containsKey(accName + '_' + prodType)) {
            forecastWrapMap.put(accName + '_' + prodType, forecastWrpList);
        }
        else {
            forecastWrapMap.get(accName + '_' + prodType).addAll(forecastWrpList);
        }
    }

    public void reArrangeAccGroupMap() {
        accGroupMap = new Map<String, List<productTypeWrapper>>();
        for(String str : forecastWrapMap.keySet()) {
            String[] keyList = str.split('_');
            if(!accGroupMap.containsKey(keyList[0])) {
                if(accIdMap.containsKey(keyList[0])) {
                    accGroupMap.put(keyList[0], new List<productTypeWrapper>{new productTypeWrapper(keyList[1], forecastWrapMap.get(str), accIdMap.get(keyList[0]))});
                }
            }
            else {
                if(accIdMap.containsKey(keyList[0])) {
                    accGroupMap.get(keyList[0]).add(new productTypeWrapper(keyList[1], forecastWrapMap.get(str), accIdMap.get(keyList[0])));
                }
            }
        }
        for(String acc : accGroupMap.keySet()) {
            List<productTypeWrapper> prodTypeWrapList = new List<productTypeWrapper>();
            prodTypeWrapList = accGroupMap.get(acc);
            Map<String, List<Decimal>> accProdRowTypeMap = new Map<String, List<Decimal>>();
            List<Decimal> accWiseTotalRow = new List<Decimal>();
            Decimal totalColAmount = 0.00;
            for(productTypeWrapper ptw : prodTypeWrapList) {
                for(forecastWrapper fcw : ptw.forecastWrpList_prod) {
                    List<Decimal> monthDecimals = new List<Decimal>(fcw.monthsData);
                    monthDecimals.add(fcw.totalRowAmount);
                    accProdRowTypeMap.put(ptw.prodType + '_' + fcw.rowType, monthDecimals);
                }
            }
            System.debug('accProdRowTypeMap >>>>>>>'+accProdRowTypeMap);
            accWiseTotalRow = calculateTotalForTwoRows(accProdRowTypeMap);
            System.debug('accWiseTotalRow >>>>>>>'+accWiseTotalRow);
            Map<Integer, Decimal> monthAmountMap = new Map<Integer, Decimal>();
            for(Integer i =1; i <=accWiseTotalRow.size(); i++) {
                monthAmountMap.put( i , accWiseTotalRow[i-1]);
            }

            List<forecastWrapper> budgetForecastWrpList = new List<forecastWrapper>();
            budgetForecastWrpList.add(new forecastWrapper('Total', monthAmountMap));
            populateForecastWrapperMap(acc,'Total',budgetForecastWrpList);

            accGroupMap.get(acc).add(new productTypeWrapper('Total', forecastWrapMap.get(acc+'_'+'Total'), accIdMap.get(acc)));
            System.debug(' $$$ accWiseTotalRow ::: ' + accWiseTotalRow);
        }
        // START : SRSF-3393               
           calculateTotalForEachRowType (ROWTYPE_BOOKED); 
           calculateTotalForEachRowType (ROWTYPE_PENDING); 
           calculateTotalForEachRowType (ROWTYPE_PROJECTED);     
        // END : SRSF-3393

        calculateQuarterlyTotalsAccountwise (accGroupMap, false, false); // 20-06-2019
        System.debug('$$$ accGroupMap ::: ' +accGroupMap.values());
    }

    // SRSF-3393 : populate accGroupMap with Rowwise Totals specific to Account & RowType
    public void calculateTotalForEachRowType (String rowType) {
        System.debug('inside calculateTotalForEachRowType>>>>');
        for(String acc : accGroupMap.keySet()) {
            List<productTypeWrapper> prodTypeWrapList = new List<productTypeWrapper>();
            prodTypeWrapList = accGroupMap.get(acc);
            Map<String, List<Decimal>> accProdRowTypeMap = new Map<String, List<Decimal>>();           
            
            for(productTypeWrapper ptw : prodTypeWrapList) {
                for(forecastWrapper fcw : ptw.forecastWrpList_prod) {
                    List<Decimal> monthDecimals = new List<Decimal>(fcw.monthsData);
                    monthDecimals.add(fcw.totalRowAmount);
                    accProdRowTypeMap.put(ptw.prodType + '_' + fcw.rowType, monthDecimals);
                }
            }
            System.debug('accProdRowTypeMap >>>>>>>'+accProdRowTypeMap);
            List<Decimal> accRowwiseTotalRow = new List<Decimal>();
   
            accRowwiseTotalRow = calculateRowwiseTotalForTwoRows (accProdRowTypeMap, rowType);        
            System.debug('accRowwiseTotalRow >>>>>>>'+accRowwiseTotalRow);
            Map<Integer, Decimal> rowWiseMonthAmountMap = new Map<Integer, Decimal>();            

            for(Integer i =1; i <=accRowwiseTotalRow.size(); i++) {
                rowWiseMonthAmountMap.put( i , accRowwiseTotalRow[i-1]);
            }            

            List<forecastWrapper> forecastWrpListRowwise = new List<forecastWrapper>();       
            forecastWrpListRowwise.add(new forecastWrapper(rowType+'_Total', rowWiseMonthAmountMap));         
            populateForecastWrapperMap(acc,rowType+'_Total',forecastWrpListRowwise);            
            accGroupMap.get(acc).add(new productTypeWrapper(rowType+'_Total', forecastWrapMap.get(acc+'_'+rowType+'_Total'), accIdMap.get(acc))); 
        }
    }

    // Start : SRSF-1785 : 20-06-2019
    public void calculateQuarterlyTotalsAccountwise (Map<String, List<productTypeWrapper>> accountMapToCalculate, Boolean isPolitical, Boolean isTrade) {
        System.debug(' #### accountMapToCalculate :::: ' +accountMapToCalculate);
        if(accountMapToCalculate != null && !accountMapToCalculate.isEmpty()) {
            for (String accName : accountMapToCalculate.keySet()){            
                for(productTypeWrapper ptw1 : accountMapToCalculate.get(accName)) {
                    System.debug('ptw1 @@@@@@@@@@'+ptw1);
                    for(forecastWrapper fcw1 : ptw1.forecastWrpList_prod) {
                        List<Decimal> quarterlyTotalsAcctwise = new List<Decimal>();
                        System.debug('fcw1 @@@@@@@'+fcw1);
                        List<Decimal> monthDecimals = new List<Decimal>(fcw1.monthsData);                        
                        if(monthDecimals.size() > 0){                            
                            quarterlyTotalsAcctwise.add(monthDecimals[0] + monthDecimals[1] + monthDecimals[2]);
                            quarterlyTotalsAcctwise.add(monthDecimals[3] + monthDecimals[4] + monthDecimals[5]);
                            quarterlyTotalsAcctwise.add(monthDecimals[6] + monthDecimals[7] + monthDecimals[8]);
                            quarterlyTotalsAcctwise.add(monthDecimals[9] + monthDecimals[10] + monthDecimals[11]);
                        }                        
                        fcw1.quarterlyTotalsAcctwise =quarterlyTotalsAcctwise;
                    }
                    
                }
            }
        }
    }    
    // End : SRSF-1785 : 20-06-2019

    public void calculateQuarterlyTotals() {
        System.debug(' ---- hasPolitical ----- ' +hasPolitical + ' ------- hasTrade ------- '+hasTrade);
        if(!hasPolitical && !hasTrade && !totalsMap.isEmpty()) { calculateQuarterlyTotals(totalsMap, false, false); }
        if(hasPolitical && !hasTrade && !politicalTotalsMap.isEmpty()) { calculateQuarterlyTotals(politicalTotalsMap, true, false); }
        if(!hasPolitical && hasTrade && !tradeTotalsMap.isEmpty()) { calculateQuarterlyTotals(tradeTotalsMap, false, true); }
    }

    public void calculateQuarterlyTotals(Map<String, Map<String, List<Decimal>>> totalMapToCalculate, Boolean isPolitical, Boolean isTrade) {
        System.debug(' #### totalMapToCalculate :::: ' +totalMapToCalculate + ' #### prodListForTotals :::: '+prodListForTotals + ' ### prodListForTradeTotals ::: ' + prodListForTradeTotals + ' #### prodListForPoliticalTotals ' +prodListForPoliticalTotals);
        Map<String, Map<String, List<Decimal>>> quarterTotalsMap = new Map<String, Map<String, List<Decimal>>>();
        if(totalMapToCalculate != null && !totalMapToCalculate.isEmpty()) {
            for(String rowType : totalMapToCalculate.keySet()) {                
                for(String prodType : totalMapToCalculate.get(rowType).keyset()) {
                    List<Decimal> quarterlyTotal = new List<Decimal>();
                    Map<String, List<Decimal>> innerMap = new Map<String, List<Decimal>>();                    
                    System.debug(' $$$ cpu limit ::: ' +limits.getCpuTime() + ' $$$ Max cpu time'+ Limits.getLimitCpuTime());
                    List<Decimal> monthlyRow = new List<Decimal>(totalMapToCalculate.get(rowType).get(prodType));
                    if(monthlyRow.size() > 0) {
                        /*for(Integer i=0 ; i < monthlyRow.size()-1; i+3) {
                            quarterlyTotal.add(monthlyRow[i] + monthlyRow[i+1] + monthlyRow[i+2]);
                        }*/
                        quarterlyTotal.add(monthlyRow[0] + monthlyRow[1] + monthlyRow[2]);
                        quarterlyTotal.add(monthlyRow[3] + monthlyRow[4] + monthlyRow[5]);
                        quarterlyTotal.add(monthlyRow[6] + monthlyRow[7] + monthlyRow[8]);
                        quarterlyTotal.add(monthlyRow[9] + monthlyRow[10] + monthlyRow[11]);
                    }
                   
                    if(quarterTotalsMap.containsKey(rowType)) {
                        Map<String, List<Decimal>> existingRows = new Map<String, List<Decimal>>();
                        existingRows = quarterTotalsMap.get(rowType);
                        existingRows.put(prodType, quarterlyTotal);
                        innerMap = existingRows;
                    }
                    else { innerMap.put(prodType, quarterlyTotal); }
                    quarterTotalsMap.put(rowType, innerMap);
                }
            }
        }
        if(!isPolitical && !isTrade) { quarterlyTotalsMap = quarterTotalsMap; }
        if(isPolitical && !isTrade) { politicalQuarterlyTotalsMap = quarterTotalsMap; }
        if(!isPolitical && isTrade) { tradeQuarterlyTotalsMap = quarterTotalsMap; }
        System.debug(' ### quarterTotalsMap ::: ' +quarterTotalsMap);
        System.debug(' ### politicalQuarterlyTotalsMap ::: ' +politicalQuarterlyTotalsMap);
        System.debug(' ### tradeQuarterlyTotalsMap ::: ' +tradeQuarterlyTotalsMap);
    }

    public void calculateTotalsSection(AggregateResult[] aggResults, String rowType) {
        typeAmnt = new Map<String,List<Decimal>>();
        oppData = new Map<String,List<String>>(); //SRSF-2485        
        for(AggregateResult agr : aggResults) {
            String mapKey = '';
            Integer monthIndex = 2;
            Decimal monthValue = 0.00;
            String oppId, oppName, advertiserName, oppAccName, advId, advName, advAmt; //SRSF-2485, 4099
            Decimal amt;
            /*if(agr.get('prod') != null)
                mapKey = String.valueOf(agr.get('prod'));
            else
                mapKey = 'Linear';*/
            if(rowType.equals(ROWTYPE_NEWS_TARGET) || rowType.equals(ROWTYPE_NEWS_REVENUE)) mapKey = 'News';
            else mapKey = String.isBlank((String)agr.get('prod'))? 'Linear':(String)agr.get('prod'); // mapKey is nothing but product type column in totals section......
            System.debug(' $$$ mapKey :::: ' +mapKey + ' ##### (String)agr.get() :::: '+(String)agr.get('prod'));
            if('Yes'.equalsIgnoreCase(Label.displayLinearAsProductType) && mapKey.containsIgnoreCase('Linear')) {
                if(prodType_Linear_Map.containsKey(mapKey)) {
                    mapKey = prodType_Linear_Map.get(mapKey);
                }
            }
            /*String revenueType = '';
            if(ROWTYPE_BOOKED.equalsIgnoreCase(rowType)) {
                revenueType = (String)agr.get('revType');
            }
            */
            /*if('Political'.equalsIgnoreCase(mapKey))
                hasPolitical = true;
            if('Trade'.equalsIgnoreCase(mapKey))
                hasTrade = true;*/ 

            /*if('Political'.equalsIgnoreCase(mapKey) || ('Political'.containsIgnoreCase(revenueType) && ROWTYPE_BOOKED.equalsIgnoreCase(rowType))){
                hasPolitical = true;
            }
            if('Trade'.equalsIgnoreCase(mapKey) || ('Trade'.containsIgnoreCase(revenueType) && ROWTYPE_BOOKED.equalsIgnoreCase(rowType))){
                hasTrade = true;   
            }*/
            //Start : SRSF-2485
            if(rowType.equals(ROWTYPE_PENDING) || rowType.equals(ROWTYPE_PROJECTED))
            { 
                if(agr.get('oppId') != NULL ) oppId = (String)agr.get('oppId'); 
                if(agr.get('oppName') != NULL ) oppName = (String)agr.get('oppName'); 
                if(agr.get('Adv') != NULL ) advertiserName = (String)agr.get('Adv'); 
            }
            //End : SRSF-2485

            //Start : SRSF-4022
            if(rowType.equals(ROWTYPE_NEWS_REVENUE))
            { 
                if(agr.get('advId') != NULL ) advId = (String)agr.get('advId'); 
                if(agr.get('adv') != NULL ) advName = (String)agr.get('adv'); 
                if(agr.get('rAmt') != NULL ) amt = (Decimal)agr.get('rAmt'); 
                if(amt != NULL ) advAmt = String.valueOf(amt); 

            }
            //End : SRSF-4022

            if(agr.get('bMonth')  != null) monthIndex= Integer.valueOf(agr.get('bMonth'));
            if(agr.get('rAmt')  != null) {
                //IB : SRSF - 1059
                //monthValue = ((Decimal)agr.get('rAmt')).round(System.RoundingMode.HALF_UP);
                monthValue = ('Yes'.equalsIgnoreCase(Label.FM_TotalSection_RoundOff)) ? ((Decimal)agr.get('rAmt')) : (((Decimal)agr.get('rAmt')).round(System.RoundingMode.HALF_UP));

                if(!isActual && performWeightageCalculation) {
                   String probability = (String)agr.get('salesProbability');
                   System.debug(' $$$ probability ::: ' +probability + ' and month value ::: ' +monthValue + ' $$$ month Index ::: ' +monthIndex);
                   monthValue = (monthValue*Integer.valueOf(probability))/100;
                   System.debug(' $$$ after applying probability ::: ' +monthValue);
                }
            }
            
            if(!typeAmnt.containsKey(mapKey)) {
                List<Decimal> amtList = new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0,0};
                amtList.set(monthIndex-1, monthValue);
                amtList.set(12,monthValue); // To calculate Row Total
                typeAmnt.put(mapKey, amtList);
                //START SRSF-2485
                if(rowType.equals(ROWTYPE_PENDING) || rowType.equals(ROWTYPE_PROJECTED))
                { 
                    List<String> oppIds = new List<String>{'','','','','','','','','','','','',''}; 
                    oppData.put('Total',null);
                    oppIds.set(monthIndex-1, oppId);                
                    oppIds.set(12, '');//For Total
                    oppData.put(mapKey, oppIds);
                }    
                //END : SRSF-2485
                //START SRSF-4022
                if(rowType.equals(ROWTYPE_NEWS_REVENUE))
                {
                    List<String> advIds = new List<String>{'','','','','','','','','','','','',''}; 
                    newsRevAccDtls.put('Total',null);
                    advIds.set(monthIndex-1, advId+'_'+advName.replaceAll('[\"\']', '')+'_'+advAmt);
                    advIds.set(12, '');//For Total
                    newsRevAccDtls.put(mapKey, advIds);
                }    
                //END : SRSF-4022
            }
            else {
                List<Decimal> mapValue = typeAmnt.get(mapKey); // mapValue is equal to amount List (Row) in totals section
                Decimal newMonthValue = mapValue.get(monthIndex-1) + monthValue;
                Decimal newRowTotal = mapValue.get(12) + monthValue;
                mapValue.set(monthIndex-1, newMonthValue);
                mapValue.set(12,newRowTotal); // To calculate Row Total
                typeAmnt.put(mapKey, mapValue);
                //SRSF-2485
                if(rowType.equals(ROWTYPE_PENDING) || rowType.equals(ROWTYPE_PROJECTED))
                { 
                    List<String> mapData = oppData.get(mapKey); 
                    String allOpprecs;
                    if(String.isNotBlank(mapData.get(monthIndex-1))){
                       allOpprecs =  mapData.get(monthIndex-1)+'_'+oppId;
                    } else allOpprecs = oppId;
                    mapData.set(monthIndex-1, allOpprecs);
                    oppData.put(mapKey, mapData); 
                }    
                //END SRSF-2485
                //SRSF-4022
                if(rowType.equals(ROWTYPE_NEWS_REVENUE))
                { 
                    List<String> mapData = newsRevAccDtls.get(mapKey); 
                    String allAdvrecs;
                    String accKey = advId+'_'+ advName.replaceAll('[\"\']', '')+'_'+advAmt;
                    if(String.isNotBlank(mapData.get(monthIndex-1))){
                       allAdvrecs =  mapData.get(monthIndex-1)+';;;'+accKey;
                    } else allAdvrecs = accKey;
                    mapData.set(monthIndex-1, allAdvrecs);
                    newsRevAccDtls.put(mapKey, mapData); 
                }    
                //END SRSF-4022

            }
            //SRSF-2485
            if(rowType.equals(ROWTYPE_PENDING) || rowType.equals(ROWTYPE_PROJECTED))
            {
                oppAccName = oppName+'||'+advertiserName;
                oppAccName = oppAccName.replaceAll('[\"\']', '');
                oppDetailsMap.put(oppId, oppAccName);
                String formNetAmtsKey =  oppId+'_'+rowType+'_'+mapKey+'_'+monthIndex;
                if(!oppNetAmtMap.containsKey(formNetAmtsKey)){
                    oppNetAmtMap.put(formNetAmtsKey, monthValue);                    
                    //oppNetAmtMap.put(formNetAmtsKey, monthValue.setScale(2)); // Added setScale (2) to show 2 decimal places
                }
                else{
                    Decimal newamt = oppNetAmtMap.get(formNetAmtsKey) + monthValue; 
                    oppNetAmtMap.put(formNetAmtsKey, newamt); 
                    //oppNetAmtMap.put(formNetAmtsKey, newamt.setScale(2));  // Added setScale (2) to show 2 decimal places
                }
                System.debug('formNetAmtsKey-->'+ formNetAmtsKey);
                System.debug('oppNetAmtMap--->'+ oppNetAmtMap);
                System.debug('Opportunity Details--->'+ oppDetailsMap);
            }
            //END SRSF-2485
        }
        System.debug('Opps data-->'+oppData);
        if(rowType.equals(ROWTYPE_NEWS_TARGET) || rowType.equals(ROWTYPE_NEWS_REVENUE))  
            newsTotalsMap.put(rowType, typeAmnt);
        else totalsMap.put(rowType, typeAmnt);
        //SRSF-2485 
        if(rowType.equals(ROWTYPE_PENDING) || rowType.equals(ROWTYPE_PROJECTED))
            opportunityMap.put(rowType, oppData); 
        //End SRSF-2485
        System.debug(' $$$ totalsMap ::: ' +totalsMap + ' $$$ hasPolitical ::: ' +hasPolitical + ' $$$ hasTrade ::: ' +hasTrade);
        System.debug(' $$$ typeAmnt.keySet() :::: ' +typeAmnt.keySet());
        // Changes START by bhuvan on 03-Aug-2018
        if((hasPolitical || hasTrade)) { // ROWTYPE_PROJECTED.equalsIgnoreCase(rowType) && 
            totalsMap.remove(rowType);
            Map<String,List<Decimal>> specialTypeAmnt = new Map<String,List<Decimal>>();
            for(String str : typeAmnt.keySet()) {
                System.debug(' $$$$$$$$$$$$ rowType ::::::: ' +rowType + ' ###### str :::::: ' +str + ' $$$$$$ hasPolitical ::::: ' +hasPolitical + ' ###### hasTrade :::::::: ' +hasTrade + ' $$$$$$ politicalTotalsMap :::::: ' +politicalTotalsMap + ' $$$$$$$$$$ specialTypeAmnt :::::::::: ' +specialTypeAmnt);
                if(hasPolitical){// if('Political'.equalsIgnoreCase(str)) {
                    specialTypeAmnt.put(str, typeAmnt.get(str));
                    politicalTotalsMap.put(rowType, specialTypeAmnt);
                }
                if(hasTrade){// if('Trade'.equalsIgnoreCase(str)) {
                    specialTypeAmnt.put('1'+str, typeAmnt.get(str));
                    tradeTotalsMap.put(rowType, specialTypeAmnt);
                }
            }
        }
        // Changes END by bhuvan
        // System.debug(' #### prodListForTotals ::: ' +prodListForTotals + ' ### prodListForTradeTotals ::: ' + prodListForTradeTotals + ' #### prodListForPoliticalTotals ' +prodListForPoliticalTotals);
        System.debug('$$$ tradeTotalsMap :::'+tradeTotalsMap);
        System.debug('$$$ politicalTotalsMap ::: ' +politicalTotalsMap);
        System.debug('$$$ newsTotalsMap ::: ' +newsTotalsMap);
        System.debug('$$$ opportunityMap-->'+opportunityMap);//SRSF-2485
    }
    
    public List<String> getPicklistValues() {
        List<String> options = new List<String>();            
        Schema.DescribeFieldResult fieldResult = Proposal_Zone_Monthly_Value__c.Schedule_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
        for( Schema.PicklistEntry f : ple) {
            options.add(f.getValue());
        }       
        return options;
    }
    
    public Map<String,ForecastMatrix_Labels__mdt> getPerformanceLabels() {
        Map<String,ForecastMatrix_Labels__mdt> labelMap = new Map<String,ForecastMatrix_Labels__mdt>();
        Map<String,ForecastMatrix_Labels__mdt> labelList = new Map<String,ForecastMatrix_Labels__mdt>([Select DeveloperName,Order__c,Performance_Label__c,isVisible__c  from ForecastMatrix_Labels__mdt where isVisible__c = true ORDER BY Order__c desc]);
        for(ForecastMatrix_Labels__mdt label : labelList.values()) {
            labelMap.put(label.developername,label);
            performanceLabels.add(label.developername);
        }
        
        return labelMap;
    }
    
    public void calculateAllPerformancePercentage() {
        prodMonthAmountMap = new Map<String, List<Decimal>>();
        List<String> prodList = getPicklistValues();
        
        performanceMap1 = new Map<String,Map<String,List<Decimal>>>();
        Map<String, List<String>> amountProd = new Map<String, List<String>>(); 
        
        if(totalsMap.containsKey(ROWTYPE_BUDGET)) {

            Map<String, List<Decimal>> amountsProdMap ;
            Map<String, List<Decimal>> amountsMap = new Map<String, List<Decimal>>();
            System.debug(' #### totalsMap.get(ROWTYPE_BUDGET).keySet() ::::: ' +totalsMap.get(ROWTYPE_BUDGET).keySet());
            for(String str : totalsMap.get(ROWTYPE_BUDGET).keySet()) {
                Boolean hasPending = false,hasBooked = false,hasProjected = false, hasForecastAdj = false;
                amountsProdMap = new Map<String, List<Decimal>>();
                // Booked to Budget Calculations
                Map<String,List<Decimal>> amountsBookedMap = new Map<String,List<Decimal>>();
                if(totalsMap.containsKey(ROWTYPE_BOOKED)) {
                    System.debug(' #### totalsMap.get(ROWTYPE_BOOKED).keyset() :::: ' +totalsMap.get(ROWTYPE_BOOKED).keyset() + ' ### str ### ' +str);
                    if(totalsMap.get(ROWTYPE_BOOKED).containsKey(str)) {
                        amountsBookedMap.put(str,totalsMap.get(ROWTYPE_BOOKED).get(str));
                        amountsProdMap.put(ROWTYPE_BOOKED + str,totalsMap.get(ROWTYPE_BOOKED).get(str));
                        System.debug('Booked amountsProdMap ' + str + amountsBookedMap + ' ### str ### ' +str);
                        hasBooked = true;
                        //amountsProdMap.put(ROWTYPE_PENDING + str,totalsMap.get(ROWTYPE_PENDING).get(str));
                        if(!performanceMap1.containsKey('BookedBudget')) {
                            Map<String, List<Decimal>> testMap = calculateBudgetPercentage(totalsMap.get(ROWTYPE_BOOKED).get(str),totalsMap.get(ROWTYPE_BUDGET).get(str),str); 
                            performanceMap1.put('BookedBudget',testMap);
                        }
                        else {
                            amountsMap = performanceMap1.get('BookedBudget');
                            Map<String, List<Decimal>> testMap = calculateBudgetPercentage(totalsMap.get(ROWTYPE_BOOKED).get(str),totalsMap.get(ROWTYPE_BUDGET).get(str),str); 
                            if(testMap.containsKey(str)) {
                                System.debug('testMap '+testMap + ' - ' + str);
                                System.debug('amountsMap '+amountsMap + ' - ' + str);
                                amountsMap.put(str,testMap.get(str));
                            }
                            
                            performanceMap1.put('BookedBudget',amountsMap);
                        }
                        System.debug('performanceMap1 '+performanceMap1.get('BookedBudget').keySet() + ' - ' + str);
                    }
                }   
                System.debug('amountsProdMap Booked ' + str +amountsProdMap);
                //Booked + Pending / Budget  
                Map<String,List<Decimal>> amountsPendingMap = new Map<String,List<Decimal>>();
                //amountsProdMap = new Map<String, List<Decimal>>();
                Map<String,List<Decimal>> amountsProjectedMap = new Map<String,List<Decimal>>();
                amountsMap =  new Map<String,List<Decimal>>();
                if(totalsMap.containsKey(ROWTYPE_PENDING)) {
                    System.debug(' ##### totalsMap.get(ROWTYPE_PENDING).keyset() ::: ' +totalsMap.get(ROWTYPE_PENDING).keyset() + ' ### str ### ' +str);
                    /*String productToValidate = '';
                    productToValidate = 'Linear/News/Sports'.containsIgnoreCase(str) ? 'Linear/News/Sports' : str;*/
                    
                    if(totalsMap.get(ROWTYPE_PENDING).containsKey(str)) {
                        hasPending = true;
                        amountsPendingMap.put(str,totalsMap.get(ROWTYPE_PENDING).get(str));
                        amountsProdMap.put(ROWTYPE_PENDING + str,totalsMap.get(ROWTYPE_PENDING).get(str));
                    }
                }
                amountsMap =  new Map<String,List<Decimal>>();
                System.debug('amountsProdMap ' + str +amountsProdMap +hasBooked +   hasPending);
                //Booked + Pending Total - For each Product Type
                if(hasBooked && hasPending)  {
                    System.debug('amountsProdMap BP' + str +amountsProdMap);
                    amountsMap.put(str,calculateTotalForTwoRows(amountsProdMap));
                    amountsProdMap.clear();
                    amountsProdMap = amountsMap;
                }
                else if(hasBooked) {
                    if ('Yes'.equalsIgnoreCase(Label.FM_Bo_Pe_Pro_Discrepency)) amountsProdMap.clear();
                    amountsProdMap.put(str,totalsMap.get(ROWTYPE_BOOKED).get(str));
                    System.debug(' ### amountsProdMap hasBooked :::: ' +amountsProdMap);
                }
                else if(hasPending) {
                    if ('Yes'.equalsIgnoreCase(Label.FM_Pending_Discrepency)) amountsProdMap.clear();
                    amountsProdMap.put(str,totalsMap.get(ROWTYPE_PENDING).get(str));
                    System.debug(' ### amountsProdMap hasPending :::: ' +amountsProdMap);
                }            

                System.debug('amountsProdMap Booked + Pending / Budget1' +amountsProdMap.get(str));       
                System.debug('amountsProdMap Booked + Pending / Budget' + hasBooked +amountsProdMap + hasPending);  
                
                if(hasPending || hasBooked) {
                    if(!performanceMap1.containsKey('BookedPending') && amountsProdMap.size() > 0)
                            performanceMap1.put('BookedPending',calculateBudgetPercentage(amountsProdMap.get(str),totalsMap.get(ROWTYPE_BUDGET).get(str),str));
                    else {   
                        System.debug('performanceMap1 str ' + str +performanceMap1);
                        amountsMap = performanceMap1.get('BookedPending');
                        List<Decimal> amountList = calculateBudgetPercentage(amountsProdMap.get(str),totalsMap.get(ROWTYPE_BUDGET).get(str),str).get(str);
                        amountsMap.put(str,amountList);
                        performanceMap1.put('BookedPending',amountsMap);
                    }
                }

                //Booked + Projected + Pending / Budget
                System.debug('performanceMap1 str ' + str +performanceMap1);
                amountsMap = new Map<String, List<Decimal>>();
                System.debug('### amountsProdMap Start ::: ' + amountsProdMap ); 
                if(totalsMap.containsKey(ROWTYPE_PROJECTED)) {
                    System.debug(' ##### totalsMap.get(ROWTYPE_PROJECTED).keyset() ::: ' +totalsMap.get(ROWTYPE_PROJECTED).keyset() + ' $$$$$$$$$$ product type to check :::::::: '+str);

                    String productToValidate = '';
                    productToValidate = 'Linear'.containsIgnoreCase(str) ? 'Linear/News/Sports' : str;
                    
                    if(totalsMap.get(ROWTYPE_PROJECTED).containsKey(productToValidate)) {
                        System.debug(' #### entered into condition with str ::::: ' +productToValidate);
                        String productToMapKey = 'Linear'.containsIgnoreCase(productToValidate) && 'Yes'.equalsIgnoreCase(Label.LinearProductTypeUpdated) ? 'Linear' : str;
                        hasProjected = true;
                        amountsProdMap.put(ROWTYPE_PROJECTED + productToMapKey,totalsMap.get(ROWTYPE_PROJECTED).get(productToValidate));
                        amountsProjectedMap.put(ROWTYPE_PROJECTED+productToMapKey,totalsMap.get(ROWTYPE_PROJECTED).get(productToValidate));
                    }
                }
                System.debug(' ### amountsProdMap END ::: ' +amountsProdMap);
                if(amountsProdMap.containsKey(str)) { //amountsMap = amountsProdMap; //amountsProdMap.remove(str);
                }
                if(amountsProdMap.size() > 1) {
                    amountsMap.put(str,calculateTotalForTwoRows(amountsProdMap));
                    amountsProdMap.clear();
                    amountsProdMap = amountsMap;
                    System.debug(' @@@@ amountsProdMap ::: ' + amountsProdMap);
                }
                else if(amountsProdMap.size() <= 1) {
                    if(amountsProdMap.containsKey(str) == false && hasProjected) {
                        amountsProdMap.put( str,totalsMap.get(ROWTYPE_PROJECTED).get(str));
                    }
                }   
                System.debug('$$$$ amountsProdMap Updated :::: ' + str +amountsProdMap );      
                if(hasPending || hasBooked || hasProjected) {   
                    if(!performanceMap1.containsKey('BookedPendingProjected'))
                        performanceMap1.put('BookedPendingProjected',calculateBudgetPercentage(amountsProdMap.get(str),totalsMap.get(ROWTYPE_BUDGET).get(str),str));
                    else {
                        amountsMap = performanceMap1.get('BookedPendingProjected');
                        List<Decimal> amountList = calculateBudgetPercentage(amountsProdMap.get(str),totalsMap.get(ROWTYPE_BUDGET).get(str),str).get(str);
                        amountsMap.put(str,amountList);
                        performanceMap1.put('BookedPendingProjected',amountsMap);
                    }
                }                 
                System.debug('$$$ testing :::: ' + str +performanceMap1);



                // START : SRSF-4489
                //Booked + Pending + Projected + Forecast Adjustment / Budget
                System.debug('performanceMap1 str ' + str +performanceMap1);
                amountsMap = new Map<String, List<Decimal>>();
                System.debug('### amountsProdMap Start ::: ' + amountsProdMap ); 
                if(totalsMap.containsKey(ROWTYPE_FORECAST_ADJUSTMENT)) {
                    System.debug(' ##### totalsMap.get(ROWTYPE_FORECAST_ADJUSTMENT).keyset() ::: ' +totalsMap.get(ROWTYPE_FORECAST_ADJUSTMENT).keyset() + ' $$$$$$$$$$ product type to check :::::::: '+str);

                    String productToValidate = '';
                    productToValidate = 'Linear'.containsIgnoreCase(str) ? 'Linear/News/Sports' : str;
                    
                    if(totalsMap.get(ROWTYPE_FORECAST_ADJUSTMENT).containsKey(productToValidate)) {
                        System.debug(' #### entered into condition with str ::::: ' +productToValidate);
                        String productToMapKey = 'Linear'.containsIgnoreCase(productToValidate) && 'Yes'.equalsIgnoreCase(Label.LinearProductTypeUpdated) ? 'Linear' : str;
                        hasForecastAdj = true;
                        amountsProdMap.put(ROWTYPE_FORECAST_ADJUSTMENT + productToMapKey,totalsMap.get(ROWTYPE_FORECAST_ADJUSTMENT).get(productToValidate));
                        amountsProjectedMap.put(ROWTYPE_FORECAST_ADJUSTMENT+productToMapKey,totalsMap.get(ROWTYPE_FORECAST_ADJUSTMENT).get(productToValidate));
                    }
                }
                System.debug(' ### amountsProdMap END ::: ' +amountsProdMap);
                if(amountsProdMap.containsKey(str)) { //amountsMap = amountsProdMap; //amountsProdMap.remove(str);
                }
                if(amountsProdMap.size() > 1) {
                    amountsMap.put(str,calculateTotalForTwoRows(amountsProdMap));
                    amountsProdMap.clear();
                    amountsProdMap = amountsMap;
                    System.debug(' @@@@ amountsProdMap ::: ' + amountsProdMap);
                }
                else if(amountsProdMap.size() <= 1) {
                    if(amountsProdMap.containsKey(str) == false && hasForecastAdj) {
                        amountsProdMap.put( str,totalsMap.get(ROWTYPE_FORECAST_ADJUSTMENT).get(str));
                    }
                }   
                System.debug('$$$$ amountsProdMap Updated :::: ' + str +amountsProdMap );      
                if(hasPending || hasBooked || hasProjected || hasForecastAdj) {   
                    if(!performanceMap1.containsKey('BookedPendingProjectedForecastAdj'))
                        performanceMap1.put('BookedPendingProjectedForecastAdj',calculateBudgetPercentage(amountsProdMap.get(str),totalsMap.get(ROWTYPE_BUDGET).get(str),str));
                    else {
                        amountsMap = performanceMap1.get('BookedPendingProjectedForecastAdj');
                        List<Decimal> amountList = calculateBudgetPercentage(amountsProdMap.get(str),totalsMap.get(ROWTYPE_BUDGET).get(str),str).get(str);
                        amountsMap.put(str,amountList);
                        performanceMap1.put('BookedPendingProjectedForecastAdj',amountsMap);
                    }
                }                 
                System.debug('$$$ testing :::: ' + str +performanceMap1);

                // END : SRSF-4489

            }
        }
        System.debug('### performanceLabels ::: '+performanceLabels);

        for(string str: performanceLabels) {
            if(performanceMap1.containsKey(str)){
                performanceMap.put(str,performanceMap1.get(str));
            }
            else {
                List<Decimal> amntList = new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0,0};
                Map<String,List<Decimal>> mapstr = new Map<String,List<Decimal>>();
                mapstr.put('Total',amntList);
                performanceMap.put(str,mapstr);
            }            
        }
        //Booked To Budget Map<String,Map<String,List<Decimal>>>
        System.debug(' Performance Table keys '+performanceMap.keySet());
    }
     
    public Map<String,List<Decimal>> calculateBudgetPercentage(List<Decimal> deciLt1, List<Decimal> deciLt2, String prodType) {
        System.debug(' $$$ deciLt1 ::: ' +deciLt1 + ' $$$ deciLt2 ::: ' +deciLt2 + ' $$$ prodType ::: '+prodType);
        Map<String, List<Decimal>> percentageBudget = new Map<String, List<Decimal>>();        
    //  List<Decimal> bookedToBudgetprodMonthAmountMap = new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0,0}; // Commented by Sridhar: 24-06-2019
        List<Decimal> bookedToBudgetprodMonthAmountMap = new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}; // 24-06-2019
        // Decimal lastValue = 0.00;
        if(deciLt1 != null && deciLt2 != null) {
            for(Integer i=0; i<=12; i++) {
                if(deciLt2[i] > 0) { //  && i != 12
                    bookedToBudgetprodMonthAmountMap[i] = (deciLt1[i]/deciLt2[i])*100;

                    // Start: 24-06-2019     
                    if (deciLt2[0]>0 || deciLt2[1]>0 || deciLt2[2]>0){
                        bookedToBudgetprodMonthAmountMap[13] = ((deciLt1[0]+deciLt1[1]+deciLt1[2])/(deciLt2[0]+deciLt2[1]+deciLt2[2]))*100;     // Q1   
                    } else{
                        //bookedToBudgetprodMonthAmountMap[13] = deciLt1[0]+deciLt1[1]+deciLt1[2];  // Q1  
                        bookedToBudgetprodMonthAmountMap[13] = 0; // Q1    
                    }  

                    if (deciLt2[3]>0 || deciLt2[4]>0 || deciLt2[5]>0){
                        bookedToBudgetprodMonthAmountMap[14] = ((deciLt1[3]+deciLt1[4]+deciLt1[5])/(deciLt2[3]+deciLt2[4]+deciLt2[5]))*100;     // Q2
                    } else{
                        //bookedToBudgetprodMonthAmountMap[14] = deciLt1[3]+deciLt1[4]+deciLt1[5];     // Q2
                        bookedToBudgetprodMonthAmountMap[14] = 0;     // Q2
                    } 

                    if (deciLt2[6]>0 || deciLt2[7]>0 || deciLt2[8]>0){
                        bookedToBudgetprodMonthAmountMap[15] = ((deciLt1[6]+deciLt1[7]+deciLt1[8])/(deciLt2[6]+deciLt2[7]+deciLt2[8]))*100;     // Q3
                    } else {
                        //bookedToBudgetprodMonthAmountMap[15] = deciLt1[6]+deciLt1[7]+deciLt1[8];     // Q3
                        bookedToBudgetprodMonthAmountMap[15] = 0;     // Q3
                    }

                    if (deciLt2[9]>0 || deciLt2[10]>0 || deciLt2[11]>0){
                        bookedToBudgetprodMonthAmountMap[16] = ((deciLt1[9]+deciLt1[10]+deciLt1[11])/(deciLt2[9]+deciLt2[10]+deciLt2[11]))*100; // Q4
                    } else{
                       // bookedToBudgetprodMonthAmountMap[16] = deciLt1[9]+deciLt1[10]+deciLt1[11]; // Q4
                       bookedToBudgetprodMonthAmountMap[16] = 0; // Q4
                    }                    
                    // End: 24-06-2019

                    // lastValue += bookedToBudgetprodMonthAmountMap[i];
                    // bookedToBudgetprodMonthAmountMap[i] = (bookedLinear[i]).divide(budgetLinear[i],2);
                } 
                /*else if(i != 12) {
                    bookedToBudgetprodMonthAmountMap[i] = 0;
                }
                else if(i == 12) {
                    lastValue = lastValue/12;
                    bookedToBudgetprodMonthAmountMap[i] = lastValue;
                }*/
                else { bookedToBudgetprodMonthAmountMap[i] = 0; }
            }
        }
        percentageBudget.put(prodType, bookedToBudgetprodMonthAmountMap);
        System.debug(' ##### bookedToBudgetprodMonthAmountMap :::: ' +bookedToBudgetprodMonthAmountMap);
        return percentageBudget;
    }


    // To get the GLID details of a Selected user
    public void fetchGLIDDetails() {
        String selectedUser = Apexpages.currentPage().getParameters().get('selectedUser');
        System.debug( ' $$$ ENETERED INTO GLID DETAILS & SELECTED USER ::::: ' +selectedUser);
        System.debug( ' $$$ chosenUser ::::: ' +chosenUser);                     
        GLIDoptions = new List<SelectOption>(); 
        budgetDMAoptions = new List<SelectOption>();
        glidList = new List<String>();      
        glidBudgetDMAMap = new Map<String, String>();       
      if(String.isBlank(selectedUser)) { selectedUser = chosenUser; }               
        if(String.isNotBlank(selectedUser)) {          
            List<GLIDMapping__c> glidMappingList = [SELECT Id, GLIDName__c, UserID__c, BudgetDMA__c, IsActive__c, UserID__r.Budget_Type__c FROM GLIDMapping__c WHERE UserID__c =: selectedUser AND IsActive__c=true];
            if(glidMappingList.Size()>0 && 'National'.equalsIgnoreCase(glidMappingList[0].UserID__r.Budget_Type__c)) {
                isNationalUser = true;                
                GLIDoptions.add(new SelectOption('All', 'All')); 
                for(GLIDMapping__c usrGlid : glidMappingList){                  
                    GLIDoptions.add(new SelectOption(usrGlid.GLIDName__c, usrGlid.GLIDName__c));                    
                    if(!glidBudgetDMAMap.containsKey(usrGlid.GLIDName__c)){
                        glidList.add(usrGlid.GLIDName__c);
                        glidBudgetDMAMap.put(usrGlid.GLIDName__c, usrGlid.BudgetDMA__c);
                    }
                }                            
                System.debug('glidBudgetDMAMap>>>>>'+glidBudgetDMAMap); 
                //fetchBudgetDMAdetails();              
            } else { isNationalUser = false; }            
        }
        return;
    }   

    // To get the budget DMA details of a selected user
    public void fetchBudgetDMAdetails() {
      // String selectedUser = Apexpages.currentPage().getParameters().get('selectedUser');
        String selectedGlid = Apexpages.currentPage().getParameters().get('selectedGlid'); // GLID Change
        System.debug( ' $$$ ENETERED INTO BUDGET DMA DETAILS & SELECTED GLID ::::: ' +selectedGlid);
        budgetDMAoptions = new List<SelectOption>();
        budgetDMAList = new List<String>();
        String budgetDMAs=''; // GLID Change
        System.debug('chosenGlidoption>>>'+chosenGlidoption);
        if(String.isBlank(selectedGlid)) { selectedGlid = chosenGlidoption; } // GLID Change 
        
       /* Comment by Sridhar : 28-08-2019
       if(String.isBlank(selectedUser)) { selectedUser = chosenUser; }        
        if(String.isNotBlank(selectedUser)) { // && childUserMap.containsKey(selectedUser)
            User selectedUserDetails = [SELECT Id, Name, Budget_DMA__c, Budget_Type__c FROM User WHERE Id =: selectedUser];
            System.debug(' @@@ selectedUserDetails ::: ' +selectedUserDetails);
            if('National'.equalsIgnoreCase(selectedUserDetails.Budget_Type__c)) {
                isNationalUser = true;
                String chosenBudgetDMAValues = selectedUserDetails.Budget_DMA__c;
                if(String.IsNotBlank(chosenBudgetDMAValues)) {
                    budgetDMAList = chosenBudgetDMAValues.split(';');
                    if(budgetDMAList!= null && budgetDMAList.size() > 0) {
                        budgetDMAoptions.add(new SelectOption('All', 'All'));
                    }
                    for(String str : budgetDMAList) {
                        budgetDMAoptions.add(new SelectOption(str, str));
                    }
                }
            }
            else { isNationalUser = false; }
            System.debug(' $$$$ budgetDMAoptions :::: ' +budgetDMAoptions);
        }*/

        if (String.isNotBlank(selectedGlid) && 'All'.equalsIgnoreCase(selectedGlid)){  
            if (String.isBlank(chosenDMAoption)){chosenDMAoption = 'All';}          
            
            for (String gld: glidList){                
                if(String.isNotBlank(budgetDMAs)) { budgetDMAs = budgetDMAs + ';'+glidBudgetDMAMap.get(gld);} else {budgetDMAs = glidBudgetDMAMap.get(gld);}
            }    
        } else if(String.isNotBlank(selectedGlid) && !'All'.equalsIgnoreCase(selectedGlid)) {
            budgetDMAs = glidBudgetDMAMap.get(selectedGlid); 
        } /*else { isNationalUser = false; } */
        
        if(String.isNotBlank(budgetDMAs)) { budgetDMAList = budgetDMAs.split(';'); }

        if(budgetDMAList!= null && budgetDMAList.size() > 0) {
            budgetDMAoptions.add(new SelectOption('All', 'All'));
            for(String str : budgetDMAList) {
                budgetDMAoptions.add(new SelectOption(str, str));
            }
        }
       // else { isNationalUser = false; }
        System.debug(' $$$$ budgetDMAoptions :::: ' +budgetDMAoptions);
        return;
    }  
    // Start : SRSF-2105
    public void fetchNewsTargetData(){
        if(!hasTrade && !hasPolitical) {
            hasNews = true;
            performWeightageCalculation = false;      
            /*Map<String, List<Decimal>> noDataMap = new Map<String, List<Decimal>>();
            noDataMap.put('News', new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0});    
            */
            //NEWS REVENUE starts here        
            String avlRevenueType = availableRevenueTypeList != null && !availableRevenueTypeList.isEmpty() ? '(\'' + String.join(availableRevenueTypeList,'\',\'') + '\')' : '';
          
            String newsRevenue = 'SELECT Sum(Net_Projected_Amount__c) rAmt, Product_Line__c prod, Revenue_Type__c revType, CALENDAR_MONTH(Broadcast_Month_Date__c) bMonth, Advertiser__r.Name adv, Advertiser__c advId FROM Revenue__c WHERE Year__c =: chosenFiscalYear  AND Account_Executive__c != null AND Account_Executive__c =: chosenUser AND Broadcast_Month_Date__c != null AND IsNews__c=true ';
           
            if(String.isNotBlank(avlRevenueType)) 
                newsRevenue += ' AND Net_Projected_Amount__c > 0 AND Revenue_Type__c IN ' + avlRevenueType;  
       
            if(String.isNotBlank(chosenGlidoption)) {
                if(String.isNotBlank(availableBudgetDMAvalues) && 'All'.equalsIgnoreCase(chosenDMAoption))
                    newsRevenue += ' AND Budget_DMA__c IN ' + availableBudgetDMAvalues;            
                else newsRevenue += ' AND Budget_DMA__c =: chosenDMAoption';
            }
            else if(String.isNotBlank(chosenGlidoption) && 'All'.equalsIgnoreCase(chosenGlidoption)){
                newsRevenue += ' AND Budget_DMA__c IN ' + availableBudgetDMAvalues;
            }    

            newsRevenue += ' GROUP BY Advertiser__r.Name, Advertiser__c, Product_Line__c, Revenue_Type__c, CALENDAR_MONTH(Broadcast_Month_Date__c) ORDER BY Advertiser__r.Name';

            System.debug(' ### News Revenue Query ::: ' +newsRevenue);
            AggregateResult[] newsRevenueList = Database.query(newsRevenue);
            System.debug(' $$$ News revenueList ::: ' +newsRevenueList);
           
            if(newsRevenueList.size() > 0) {
                try {
                    calculateTotalsSection(newsRevenueList, ROWTYPE_NEWS_REVENUE);
                }
                catch(Exception ex) {
                    System.debug('### Exception :::'+ex.getMessage()+' ### Line Number :::: ' +ex.getLineNumber());                    
                }
            }

            // NEWS TARGET Starts here
            String newsTargetbudget = 'SELECT SUM(Amount__c) rAmt ,CALENDAR_MONTH(Broadcast_Month_Date__c) bMonth, product_line__C prod FROM Budget__c WHERE Account__r.RecordType.DeveloperName != \'Competitor_Account\' AND Year__c =:chosenFiscalYear AND Amount__c != 0 AND RecordType.DeveloperName=\'NewsTarget\' AND Product_Line__c NOT IN (\'Political\',\'Trade\')'; 
            /*  // START : Commented for SRSF-3756   
            if('Master - Local Sales Manager'.equalsIgnoreCase([SELECT Id, Profile.Name FROM User WHERE Id = :chosenUser].Profile.Name)) isLocalUser = true;

            if(isLocalUser){
                Map<Id,User> aeUsersMap = new Map<ID, User>([SELECT Id, Name FROM User WHERE HR_Manager__c= :chosenUser AND Profile.Name = 'Master - Account Executive' AND IsActive = TRUE]);
                if(aeUsersMap.size()>0) {
                    Set<Id> aeUserIds = aeUsersMap.keySet();
                    System.debug(' $$$ aeUserIds ::: ' +aeUserIds);
                    newsTargetbudget+=  ' AND BudgetAE__c IN :aeUserIds';
                }    
            } 
            else 
            // END : Commented for SRSF-3756  */
            newsTargetbudget+=  ' AND BudgetAE__c = :chosenUser';

            if(isNationalUser) {          
                if(String.isNotBlank(availableBudgetDMAvalues) && 'All'.equalsIgnoreCase(chosenDMAoption))
                    newsTargetbudget += ' AND DMA__c IN ' + availableBudgetDMAvalues;
                else newsTargetbudget += ' AND DMA__c =: chosenDMAoption';
            }
            newsTargetbudget += ' Group BY Calendar_Month(Broadcast_Month_Date__c), Product_Line__c';

            AggregateResult[] newsTargetbudgetResults = Database.query(newsTargetbudget);
            System.debug(' $$$ News Target budgetResults ::: ' +newsTargetbudgetResults);            

            if(newsTargetbudgetResults.size() > 0) {
                try {
                    calculateTotalsSection(newsTargetbudgetResults, ROWTYPE_NEWS_TARGET);
                }
                catch(Exception ex) {
                    System.debug('### Exception :::'+ex.getMessage()+' ### Line Number :::: ' +ex.getLineNumber());                    
                }
            }

            // Calculate Quarterly values for NewsRevenue and NewsTarget
            if(newsTotalsMap != null && !newsTotalsMap.isEmpty()) {
                for(String rowType : newsTotalsMap.keySet()) {                    
                    for(String prodType : newsTotalsMap.get(rowType).keyset()) {                
                        System.debug(' $$$ cpu limit ::: ' +limits.getCpuTime() + ' $$$ Max cpu time'+ Limits.getLimitCpuTime());
                        List<Decimal> monthlyRow = new List<Decimal>(newsTotalsMap.get(rowType).get(prodType));
                        if(monthlyRow.size() > 0) {
                           List<Decimal> quarterlyTotal =  newsTotalsMap.get(rowType).get(prodType);
                           quarterlyTotal.add(monthlyRow[0] + monthlyRow[1] + monthlyRow[2]);
                           quarterlyTotal.add(monthlyRow[3] + monthlyRow[4] + monthlyRow[5]);
                           quarterlyTotal.add(monthlyRow[6] + monthlyRow[7] + monthlyRow[8]);
                           quarterlyTotal.add(monthlyRow[9] + monthlyRow[10] + monthlyRow[11]);
                        }  
                    }
                }
            }
            System.debug(' $$$ newsTotalsMap ::: ' +newsTotalsMap);
            // Calculate News To News Revenue
            if(newsTotalsMap != null && newsTotalsMap.size()>0 && newsTotalsMap.containsKey(ROWTYPE_NEWS_REVENUE) && newsTotalsMap.containsKey(ROWTYPE_NEWS_TARGET)) {
                CalculateNewsToNewsRevenueData();                
            }
            if(newsTotalsMap != null && newsTotalsMap.containsKey(ROWTYPE_NEWS_REVENUE))
                prodListForNewsTotals.add(ROWTYPE_NEWS_REVENUE);
            if(newsTotalsMap != null && newsTotalsMap.containsKey(ROWTYPE_NEWS_TARGET))
                prodListForNewsTotals.add(ROWTYPE_NEWS_TARGET);
            if(newsTotalsMap != null && newsTotalsMap.containsKey(ROWTYPE_NEWS_REVENUE_TO_NEWS_TARGET)) {
                prodListForNewsTotals.add(ROWTYPE_NEWS_REVENUE_TO_NEWS_TARGET);
            }
            System.debug(' ### prodListForNewsTotals ::: ' +prodListForNewsTotals);
        }
    } 

    public void CalculateNewsToNewsRevenueData(){
        if(newsTotalsMap.size()>0){
            Map<String, List<Decimal>> amountsNewsMap = new Map<String, List<Decimal>>();
            if(newsTotalsMap.containsKey(ROWTYPE_NEWS_REVENUE)){
                for(String str : newsTotalsMap.get(ROWTYPE_NEWS_REVENUE).keySet()){
                    if(newsTotalsMap.containsKey(ROWTYPE_NEWS_TARGET)){ 
                        if(newsTotalsMap.get(ROWTYPE_NEWS_TARGET).containsKey(str)) {
                            amountsNewsMap = calculateBudgetPercentage(newsTotalsMap.get(ROWTYPE_NEWS_REVENUE).get(str),newsTotalsMap.get(ROWTYPE_NEWS_TARGET).get(str),str);
                        }
                    }
                }
            }
             newsTotalsMap.put(ROWTYPE_NEWS_REVENUE_TO_NEWS_TARGET,amountsNewsMap);
        }
        System.debug('CalculateNewsToNewsRevenueData newsTotalsMap--->'+newsTotalsMap);
    }
    // End : SRSF-2105 

    // New Wrapper Class
    public class forecastWrapper {

        public transient String rowType {set; get;} // Booked, Pending, Projected
        public List<Decimal> monthsData {get; set;}
        public List<Decimal> quarterlyTotalsAcctwise {get; set;} // 20-06-2019
        public Decimal totalRowAmount {get; set;}  

        public forecastWrapper() {} 

        public forecastWrapper(String rowTyp, Map<Integer, Decimal> monthAmountMap) {
            //monthsData = new List<Decimal>();
            if(monthAmountMap != null && String.isNotBlank(rowTyp)) {
                this.rowType = rowTyp;
                monthsData = new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0};
                quarterlyTotalsAcctwise = new List<Decimal>{0,0,0,0}; // 20-06-2019
                totalRowAmount = 0;
                if(!monthAmountMap.isEmpty()) {
                    for(Integer i=1; i<=12; i++) {
                        if(monthAmountMap.containsKey(i)) {
                            monthsData[i-1] = monthAmountMap.get(i);
                            totalRowAmount += monthAmountMap.get(i) == null?0:monthAmountMap.get(i);
                        }
                        else { monthsData[i-1] = 0.00; }
                    }
                }
            }
        }
    }

    public class productTypeWrapper {
        public transient String Accid {set; get;}
        public transient String prodType {set; get;}
        public transient List<forecastWrapper> forecastWrpList_prod {set; get;}
        public transient Integer forecastWrpSize {get; set;}
        public productTypeWrapper() {
            forecastWrpList_prod = new List<forecastWrapper>();
        }
        public productTypeWrapper(String prodType, List<forecastWrapper> forecastWrpList, String Accid) {
            if(!String.isNotBlank(prodType)) {  this.prodType = ''; }
            else { this.prodType = prodType; }
            if(!String.isNotBlank(Accid)){ this.Accid = ''; }
            else { this.Accid = Accid; }
            this.forecastWrpList_prod = forecastWrpList;
            forecastWrpSize = forecastWrpList.size();
        }
    }

    // SRSF-3393 : Created to convert JSON string to Map and pass to accGroupMap, which is transient
    public class forecastWrapper_2 {
        public String rowType; // Booked, Pending, Projected
        public List<Decimal> monthsData;
        public List<Decimal> quarterlyTotalsAcctwise;// 20-06-2019
        public Decimal totalRowAmount; 
    }

    // SRSF-3393 : Created to convert JSON string to Map and pass to accGroupMap, which is transient
    public class productTypeWrapper_2 {
        public String Accid;
        public String prodType;
        public List<forecastWrapper_2> forecastWrpList_prod;
        public Integer forecastWrpSize; 
    }

    // SRSF-3393 : To generate a JSON String from accGroupMap as it is transient and not holds data after page load
    public String formJSONForAccGroupMap(Map<String, List<productTypeWrapper>> accGroupdata) {
        String jsonStr='';
        try{    
            jsonStr='{';        
            for (String str : accGroupdata.keySet()) 
            { 
                System.debug('str inside formJSONForAccGroupMap>>>'+str);                       
                jsonStr += '"'+str.replace( '\\', '\\\\' )+'":[';    
                for(productTypeWrapper pr :  accGroupdata.get(str))
                {  
                    jsonStr+= '{"prodType":"'+pr.prodType+'","forecastWrpSize":'+pr.forecastWrpSize;
                    jsonStr+=',"forecastWrpList_prod":[';

                    for(forecastWrapper fwrap : pr.forecastWrpList_prod)
                    {                    
                       jsonStr+='{"totalRowAmount":'+fwrap.totalRowAmount+',"rowType":"'+fwrap.rowType;
                       jsonStr+='","quarterlyTotalsAcctwise":[';               
                       for (Decimal decQtly :fwrap.quarterlyTotalsAcctwise) {
                        jsonStr+= decQtly+','; 
                       }
                       jsonStr= jsonStr.endsWith(',') ? jsonStr.left(jsonStr.length()-1) : jsonStr;
                       jsonStr+='],"monthsData":[';
                       for (Decimal dec :fwrap.monthsData) {
                        jsonStr+= dec+','; 
                       }
                       jsonStr= jsonStr.endsWith(',') ? jsonStr.left(jsonStr.length()-1) : jsonStr ;
                        
                       jsonStr+=']},';                
                    }  
                    jsonStr= jsonStr.endsWith(',') ? jsonStr.left(jsonStr.length()-1) : jsonStr ; 
                    jsonStr+='],"Accid":"'+pr.Accid+'"},';            
                }                        
                jsonStr= jsonStr.endsWith(',') ? jsonStr.left(jsonStr.length()-1) : jsonStr ;
                jsonStr+='],'; 
            }
            jsonStr= jsonStr.endsWith(',') ? jsonStr.left(jsonStr.length()-1) : jsonStr ;
            jsonStr+='}';
        } 
        catch(Exception ex) {
            System.debug(' ### Exception ::: ' + ex.getMessage()  + ' ### Line Number :::: ' +ex.getLineNumber());            
        }    
        return jsonStr;
    }

    // SRSF-3393 : To Deserialize JSON String and populate into accGroupMap
    public void populateAcctsDataOnRowTypeSelection () {         
        System.debug('selectedRowType-->'+selectedRowType);      
        System.debug('accGroupMapjson inside populateSelectedRowType>>>'+accGroupMapjson);      
            
        Map<String, List<productTypeWrapper_2>> accGroupMap2 = (Map<String, List<productTypeWrapper_2>>) JSON.deserialize(accGroupMapjson, Map<String, List<productTypeWrapper_2>>.class);
        System.debug('$$$ inside populateAcctsDataOnRowTypeSelection accGroupMap2::: ' + accGroupMap2);
        accGroupMap = new Map<String, List<productTypeWrapper>>();
    
      for (String str : accGroupMap2.keySet()) 
      { 
        List<productTypeWrapper>  prList = new List<productTypeWrapper>();      
        for(productTypeWrapper_2 pr :  accGroupMap2.get(str))
        {       
            List<forecastWrapper> fwrap = new List<forecastWrapper>();    
            for(forecastWrapper_2 fw2 : pr.forecastWrpList_prod){ 
                if(fw2.rowType.contains(selectedRowType) || (selectedRowType=='All' && !fw2.rowType.contains('_'))){
                    forecastWrapper obj = new forecastWrapper(); 
                    obj.rowType = fw2.rowType.contains('_') ? 'Total' : fw2.rowType;
                    obj.monthsData = fw2.monthsData ;
                    obj.quarterlyTotalsAcctwise = fw2.quarterlyTotalsAcctwise ;
                    obj.totalRowAmount = fw2.totalRowAmount ;
                    fwrap.add(obj);
                }    
            }
            if(fwrap.size()>0){
                pr.prodType = pr.prodType.contains('_') ? 'Total': pr.prodType;
                prList.add(new productTypeWrapper(pr.prodType, fwrap, pr.Accid)); 
            }    
        }        
        if(prList.Size()>1){
            accGroupMap.put(str,prList);
        }       
      }
      displayTable = accGroupMap.Size()>0 ? true : false;        
    System.debug('$$$ Reconstructed accGroupMap::: ' + accGroupMap);
    }


    // START : SRSF-4489
    public void fetchAdjustOppBudgetPZMVs() {
        List<String> recordTypeIdList = new List<String>();  
        
        recordTypeIdList.add(String.valueOf(Schema.SObjectType.Proposal__c.getRecordTypeInfosByDeveloperName().get('Adjust_Opportunity_Budget').getRecordTypeId()));
       
        System.debug(' ### wave_forecastCategory ::: ' +wave_forecastCategory);        
        System.debug(' ### recordTypeIdList ### ' +recordTypeIdList);      

        String query = 'SELECT CALENDAR_MONTH(Broadcast_Month_Date__c) bMonth';
        if(isCompanyModel){  query += ' ,Sum(Broadcast_Amount__c) rAmt';
        }else query += ' ,Sum(Net_Amount__c) rAmt, Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c salesProbability';  

        if(isNationalUser) query +=  ' ,Proposal_Zone__r.Proposal__r.Opportunity__r.DMA__c dma';

        query += ' ,Schedule_Type__c prod, Advertiser__r.Name Adv, Advertiser__c advId,  Proposal_Zone__r.Proposal__r.Opportunity__c oppId, Proposal_Zone__r.Proposal__r.Opportunity__r.Name oppName FROM Proposal_Zone_Monthly_Value__c WHERE Year__c =: chosenFiscalYear AND Proposal_Zone__r.Proposal__r.RecordTypeId IN :recordTypeIdList AND Proposal_Zone__r.Proposal__r.Active__c = true AND Proposal_Zone__r.Proposal__r.Opportunity__r.Owner_For_Forecasting_Tool__c =: chosenUser AND (Proposal_Zone__r.Proposal__r.Opportunity__r.isClosed= false OR Proposal_Zone__r.Proposal__r.Opportunity__r.isWon = true) AND Broadcast_Month_Date__c != null';

        // Commented below code as part of request to show -ve values for Forecast Adjustment Tool
        /*if(isCompanyModel){ query += ' AND Broadcast_Amount__c > 0';
        }else query += ' AND Net_Amount__c > 0 AND Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c IN : selectedSalesProb';*/
        if(!isCompanyModel){
            query += ' AND Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c IN : selectedSalesProb';
        }    
        if(isNationalUser) {          
            if(String.isNotBlank(availableBudgetDMAvalues) && 'All'.equalsIgnoreCase(chosenDMAoption)){
                query += ' AND Proposal_Zone__r.Proposal__r.Opportunity__r.DMA__c IN ' + availableBudgetDMAvalues;
            }
            else {  query += ' AND Proposal_Zone__r.Proposal__r.Opportunity__r.DMA__c =: chosenDMAoption'; }
        }

        query += ' AND Proposal_Zone__r.Proposal__r.Opportunity__r.Account.Political_Account__c =: isProdTypePolitical GROUP BY Advertiser__c, Advertiser__r.Name,Schedule_Type__c, CALENDAR_MONTH(Broadcast_Month_Date__c), Proposal_Zone__r.Proposal__r.Opportunity__c, Proposal_Zone__r.Proposal__r.Opportunity__r.Name';
        
        if(!isCompanyModel) query += ', Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c';
        if(isNationalUser) query +=  ' ,Proposal_Zone__r.Proposal__r.Opportunity__r.DMA__c';

        query += ' ORDER BY Advertiser__r.Name,CALENDAR_MONTH(Broadcast_Month_Date__c) ASC';

        System.debug('### forecast adjustment query::: ' +query);
        AggregateResult[] forecastAdjResults = Database.query(query);
        System.debug(' ### forecast adjustment Results ::: ' +forecastAdjResults);
    System.debug(' ### forecast adjustment Results size ::: ' +forecastAdjResults.size());
        performWeightageCalculation = true;
        if(forecastAdjResults.size() > 0) {
            hasPolitical = isProdTypePolitical ;
            try {
                //calculateAggregateResultAccountWise(projectedResults, ROWTYPE_PROJECTED);
                calculateTotalsSection(forecastAdjResults, ROWTYPE_FORECAST_ADJUSTMENT);
                if(totalsMap.containsKey(ROWTYPE_FORECAST_ADJUSTMENT) || (hasPolitical && politicalTotalsMap.containsKey(ROWTYPE_FORECAST_ADJUSTMENT) || (hasTrade && tradeTotalsMap.containsKey(ROWTYPE_FORECAST_ADJUSTMENT)))) {
                    Map<String,List<Decimal>> existingforecastAdjRows = new Map<String,List<Decimal>>();
                    
                    existingforecastAdjRows = hasPolitical ? politicalTotalsMap.get(ROWTYPE_FORECAST_ADJUSTMENT) : totalsMap.get(ROWTYPE_FORECAST_ADJUSTMENT);
                
                    List<Decimal> totalRowAmounts = calculateTotalForTwoRows(existingforecastAdjRows);
                    
                    existingforecastAdjRows.put('Total', totalRowAmounts);
                    if(!hasPolitical) {
                        totalsMap.put(ROWTYPE_FORECAST_ADJUSTMENT, existingforecastAdjRows);
                    }
                    if(hasPolitical) {
                        politicalTotalsMap.put(ROWTYPE_FORECAST_ADJUSTMENT, existingforecastAdjRows);
                        prodListForPoliticalTotals.add(ROWTYPE_FORECAST_ADJUSTMENT);
                    }
                    sectionHeight += existingforecastAdjRows.size();
                }
            }
            catch(Exception ex) {
                System.debug(' ### Exception ::: ' + ex.getMessage()  + ' ### Line Number :::: ' +ex.getLineNumber());                
            }
        }
    }

    public void fetchBookedPendingProjectedForecastAdjData () {
        Map<String,List<Decimal>> bookedTotalsMap = new Map<String,List<Decimal>>();
        Map<String,List<Decimal>> pendingTotalsMap = new Map<String,List<Decimal>>();
        Map<String,List<Decimal>> projectedTotalsMap = new Map<String,List<Decimal>>(); 
        Map<String,List<Decimal>> forecastAdjTotalsMap = new Map<String,List<Decimal>>();
        Set<String> prodSet = new Set<String>(); 
        bookedTotalsMap = fetchDataByRowType (ROWTYPE_BOOKED, prodSet);
        pendingTotalsMap = fetchDataByRowType (ROWTYPE_PENDING, prodSet);
        projectedTotalsMap = fetchDataByRowType (ROWTYPE_PROJECTED, prodSet);
        forecastAdjTotalsMap = fetchDataByRowType (ROWTYPE_FORECAST_ADJUSTMENT, prodSet);
        
        for (String str : prodSet){   
            List<Decimal> bookedPendingProjForecastAdjMap = calculateProductwiseTotals (bookedTotalsMap, pendingTotalsMap, projectedTotalsMap, forecastAdjTotalsMap, str);
            Map<String,List<Decimal>> bookedPendingProjForecastAdjRow = new Map<String,List<Decimal>> (); 
            bookedPendingProjForecastAdjRow.put(str, bookedPendingProjForecastAdjMap);
            System.debug('bookedPendingProjForecastAdjRow>>>>>'+bookedPendingProjForecastAdjRow);
            if(totalsMap.containsKey(ROWTYPE_BOOKED_PENDING_PROJECTED_FORECAST_ADJUSTMENT)){
                totalsMap.get(ROWTYPE_BOOKED_PENDING_PROJECTED_FORECAST_ADJUSTMENT).put(str, bookedPendingProjForecastAdjMap);
            } else {
                totalsMap.put(ROWTYPE_BOOKED_PENDING_PROJECTED_FORECAST_ADJUSTMENT,bookedPendingProjForecastAdjRow);
            }   
        }
    }
    // END : SRSF-4489
}