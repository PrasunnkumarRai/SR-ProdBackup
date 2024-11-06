public class WaveForecastMatrixController {

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
    public String getSelUserRole { get; set; }
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
    public List<String> monthNames {get; set;}  // SRSF-3393 - removed transient
    public transient List<String> prodListForTotals {get; set;}
    public transient List<String> prodListForPoliticalTotals {get; set;}
    public transient List<String> prodListForTradeTotals {get; set;}

    // START: SRSF-4679
    public transient Map<String,List<Decimal>> amtMap{get; set;}
    public transient Map<String, List<String>> oppData {get; set;}
    public transient Map<String, List<Decimal>> performanceMap {get; set;}
    public transient Map<String, List<Decimal>> performanceMap1 {get; set;}
    public transient Map<String, List<Decimal>> totalsMap {get; set;}    
    public transient Map<String, List<Decimal>> politicalTotalsMap {get; set;}
    public transient Map<String, List<Decimal>> tradeTotalsMap {get; set;}
    public transient Map<String, List<Decimal>> newsTotalsMap {get; set;}
    public transient Map<String, List<Decimal>> quarterlyTotalsMap {get; set;}
    public transient Map<String, List<Decimal>> politicalQuarterlyTotalsMap {get; set;}
    public transient Map<String, List<Decimal>> tradeQuarterlyTotalsMap {get; set;} 
    public transient Map<String, List<String>> opportunityMap {get; set;}
    // END: SRSF-4679

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
    
    public transient Map<String, List<String>> newsRevAccDtls{get; set;} //SRSF-4022
    public transient Map<String,String> oppDetailsMap {get; set;}
    public transient Map<String, Decimal> oppNetAmtMap {get; set;}
    public transient String opportunityData{get;set;}
    public transient String oppDetails{get;set;}
    public transient String oppNetAmtData{get;set;}
    //END SRSF-2485
    public transient String newsRevAccs{get;set;}//SRSF-4022
    
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
    
    //Constants
    public static final String ROWTYPE_PENDING = 'Pending';
    public static final String ROWTYPE_PROJECTED = 'Projected';
    public static final String ROWTYPE_BUDGET = 'Budget';
    public static final String ROWTYPE_BOOKED = 'Booked';
    public static final String ROWTYPE_FORECAST_ADJUSTMENT = 'Forecast Adjustment'; //SRSF-4489
    // SRSF-1785 Changes Start : 10-06-2019  
    public static final String ROWTYPE_PENDING_PROJECTED = 'Pending + Projected';
    public static final String ROWTYPE_GAP = 'Gap to Budget'; // SRSF-4679 : Updated
    public static final String ROWTYPE_BOOKED_PENDING_PROJECTED_FORECAST_ADJUSTMENT = 'Booked + Pending + Projected + Forecast Adjustment'; //SRSF-4489
    // SRSF-2105
    public static final String ROWTYPE_NEWS_TARGET = 'News Target'; 
    public static final String ROWTYPE_NEWS_REVENUE = 'News Revenue';
    public static final String ROWTYPE_NEWS_REVENUE_TO_NEWS_TARGET = 'News To News Target';
    // SRSF-1785 Changes End : 10-06-2019  
    public static final String SYS_ADMIN_PROFILE = 'System Administrator';
    public static final String REGIONAL_FINANCE_PROFILE = 'Master - Regional Finance';

    // Default Constructor
    public WaveForecastMatrixController ()
    {
        globalParentChildUserMap = new Map<String,String>();
        prodType_Linear_Map = new Map<String, String>();
        childUserMap = new Map<String, User>();
        accGroupMap = new Map<String, List<productTypeWrapper>>();
        performanceMap = new Map<String,List<Decimal>>();     

        // START : SRSF-4679
        totalsMap = new Map<String,List<Decimal>>();        
        tradeTotalsMap = new Map<String,List<Decimal>>();
        politicalTotalsMap = new Map<String,List<Decimal>>();
        newsTotalsMap = new Map<String,List<Decimal>>();
        quarterlyTotalsMap= new Map<String,List<Decimal>>();
        politicalQuarterlyTotalsMap = new Map<String,List<Decimal>>();
        tradeQuarterlyTotalsMap = new Map<String,List<Decimal>>();        
        opportunityMap = new Map<String,List<String>>();
        // END : SRSF-4679

        performanceKeys = new Map<String,ForecastMatrix_Labels__mdt>();    
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
        sectionHeight = newsSectionHeight = 0;        
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

        productOptionList = new List<SelectOption>();
        productOptionList.add(new SelectOption('Linear', 'Core'));       
        productOptionList.add(new SelectOption('Political', 'Political'));
        productOptionList.add(new SelectOption('Trade', 'Trade'));

        // SRSF-3393 - Added RowType options
        rowTypeList = new List<SelectOption>();        
        rowTypeList.add(new SelectOption('All', 'All'));
        rowTypeList.add(new SelectOption('Booked', 'Booked'));
        rowTypeList.add(new SelectOption('Pending', 'Pending'));
        rowTypeList.add(new SelectOption('Projected', 'Projected'));

        String appliedProduct = chosenProduct != null && chosenProduct.equalsIgnoreCase('Linear') ? 'Core' : chosenProduct;            
        
        isProdTypePolitical = 'Political'.equalsIgnoreCase(chosenProduct) ? true : false;

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
        chosenSalesProbability = String.isBlank(chosenSalesProbability) ? 'All' : chosenSalesProbability;
        appliedFilters = ' Year = ' + chosenFiscalYear + ', User = ' + chosenUserName + ', Product Type = '+appliedProduct ;
      
        if(isNationalUser) {
            if(String.isNotBlank(chosenGlidoption)) { appliedFilters += ', GLID = ' + chosenGlidoption; } else if (glidList.size() > 0) {appliedFilters += ', GLID = All';} 
            if(String.isNotBlank(chosenDMAoption)) { appliedFilters += ', Budget DMA = ' + chosenDMAoption; } else if(budgetDMAList.size() > 0) { appliedFilters += ', Budget DMA = All'; }
        }    
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
    public void fetchsalesProbabilityOptions() 
    {
        availableSalesProb = new Set<String>();        
        Schema.DescribeFieldResult fieldResult = Opportunity.Sales_Probability__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple) 
        {
            salesProbabilityOptions.add(new SelectOption(f.getLabel(), f.getValue()));
            salesProbabilityPicklistValues.add(f.getValue());
            availableSalesProb.add(f.getValue());
        }
        if(checkSalesProbabilityOptions('100')) {
            salesProbabilityOptions.add(new SelectOption('100%', '100'));
            salesProbabilityPicklistValues.add('100');
        }
        if(checkSalesProbabilityOptions('0')) { salesProbabilityPicklistValues.add('0'); }
    }

    public Boolean checkSalesProbabilityOptions(String picklistValue) 
    {
        if(!availableSalesProb.contains(picklistValue)) {
            availableSalesProb.add(picklistValue);
            return true;
        }
        return false;
    }

    public PageReference getGridData() 
    {
        System.debug(' calling server method ');
        System.debug('$$$ chosenUser ::: ' +chosenUser);
        hasPolitical = hasTrade = hasNews = false;
        try 
        {
            if(childUserIds.size() == 0 && currentUser.UserRole.Name != null && System.label.AccountTeamRole.startsWith(currentUser.UserRole.Name)) 
            {
                childUserIds.add(chosenUser);
            }
            fetchBudgetData();  // For 'Budget' Records
            fetchAccountRelatedRevenueRecords(); // For 'Booked' Records
            fetchNewsTargetData(); //SRSF-2105
            if(!'Trade'.equalsIgnoreCase(chosenProduct)) 
            {                
                fetchProjectedProposalZoneMonthlyValues();  // For 'Projected' Records
                fetchAdjustOppBudgetPZMVs(); // SRSF - 4489 : Forecast Adjustment 
            }
            
            fetchPendingProposalZoneMonthlyValues();  // For 'Pending' Records
            
            if(!totalsMap.isEmpty()) 
            { 
                fetchPendingProjectedData(); // To show Pending+Projected Data : 10-06-2019
                fetchBookedPendingProjectedForecastAdjData (); // SRSF - 4489 : To show Booked+Pending+Projected+forecastAdj Data            
                fetchGapData (); // To show Budget-Booked data : 10-06-2019                
            }

            calculateQuarterlyTotals();
            if(forecastWrapMap != null && !forecastWrapMap.isEmpty()) { reArrangeAccGroupMap(); }
            System.debug(' ### prodListForTotals ::: ' +prodListForTotals + ' ### prodListForTradeTotals ::: ' + prodListForTradeTotals + ' #### prodListForPoliticalTotals ' +prodListForPoliticalTotals);
            System.debug(' ### totalsMap ::: ' +totalsMap);
            System.debug(' ### politicalTotalsMap ::: ' +politicalTotalsMap);

            if(!totalsMap.isEmpty()) 
            {
                calculateAllPerformancePercentage();
            }
            if(totalsMap != null)  displayTotalsTable = totalsMap.isEmpty() ? false : true ;
            if(performanceMap1 != null)  displayPerformanceTable = performanceMap1.isEmpty() ? false : true ;
            if(accGroupMap != null)  displayTable = accGroupMap.isEmpty() ? false : true ;
            loadSpinner = false; 
            // Start: SRSF-1785 Changes
            if(totalsMap != null && totalsMap.containsKey(ROWTYPE_BUDGET))
            {
                prodListForTotals.add(ROWTYPE_BUDGET);
            }

            if(totalsMap != null && totalsMap.containsKey(ROWTYPE_BOOKED))
            {
                prodListForTotals.add(ROWTYPE_BOOKED);
            }

            if(totalsMap != null && totalsMap.containsKey(ROWTYPE_GAP))
            {
                prodListForTotals.add(ROWTYPE_GAP);         
            }
            
            if(totalsMap != null && totalsMap.containsKey(ROWTYPE_PENDING_PROJECTED))
            {
                prodListForTotals.add(ROWTYPE_PENDING_PROJECTED);      
            } 
        
            // START : SRSF-4489
            if(totalsMap != null && totalsMap.containsKey(ROWTYPE_BOOKED_PENDING_PROJECTED_FORECAST_ADJUSTMENT))
            {
                prodListForTotals.add(ROWTYPE_BOOKED_PENDING_PROJECTED_FORECAST_ADJUSTMENT);          
            }
            // END : SRSF-4489
            
            if(totalsMap != null && totalsMap.containsKey(ROWTYPE_PENDING))
            {
                prodListForTotals.add(ROWTYPE_PENDING);
            }
            if(totalsMap != null && totalsMap.containsKey(ROWTYPE_PROJECTED))
            {
                prodListForTotals.add(ROWTYPE_PROJECTED);
            } 
            // End: SRSF-1785 Changes
            // START : SRSF-4489
            if(totalsMap != null && totalsMap.containsKey(ROWTYPE_FORECAST_ADJUSTMENT))
            {
                prodListForTotals.add(ROWTYPE_FORECAST_ADJUSTMENT);
            }            
            // END : SRSF-4489  
        }
        catch(Exception ex)
        {
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
        if(!CommonUtilities.isStringNullOrEmpty(profileName))
        {           
            custSuccessProfileList =  profileName.split(',');
        }
        System.debug('currentUser-->'+currentUser);
        System.debug('loggedInUser::'+loggedInUser);
        // END : SRSF-4421 
        options = new List<SelectOption>();
        options.add(new SelectOption('', 'Select a User'));       
        // If Sys Admin Profile then show list of all users
        if (loggedInUser.Profile.Name == SYS_ADMIN_PROFILE || loggedInUser.Profile.Name == REGIONAL_FINANCE_PROFILE)
        {
            for (User subUser : [SELECT Id, Name, Budget_DMA__c, Budget_Type__c FROM User WHERE UserRole.Id != NULL AND isActive = true AND( User.UserRole.Name Like 'AE%'  OR User.UserRole.Name Like 'LSM%' OR User.UserRole.Name Like 'NSM%') ORDER BY FirstName]){ //AND Designation__c NOT IN :filteredDesignation AND UserRole.ParentRoleID != NULL
                options.add(new SelectOption(subUser.Id , subUser.Name));
                childUserMap.put(subUser.Id, subUser);
            }
            if (currentUser != loggedInUser){ chosenUser = currentUser.Id; }
            else{ chosenUser = options[0].getValue(); }
        }else if (loggedInUser.Profile.Name == System.Label.BillingProfileName)
        {
            // If Finance profile then show only those users who report to same Manager 
            System.debug('loggedInUser.ManagerId::'+loggedInUser.ManagerId);           
            Set<Id> allRelatedUserIds = getAllSubUserIds(new Set<Id>{loggedInUser.ManagerId});
            allRelatedUserIds.remove(loggedInUser.Id);
            for (User subUser : [SELECT Id, Name, Budget_DMA__c, Budget_Type__c FROM User WHERE UserRole.Id != NULL  AND isActive = true AND Id IN:allRelatedUserIds ORDER BY firstname]) 
            {
                options.add(new SelectOption(subUser.Id , subUser.Name));
                childUserMap.put(subUser.Id, subUser);
            }
            if (currentUser != loggedInUser){ chosenUser = currentUser.Id; }
            else{ chosenUser = options[0].getValue(); }
        } 
        // START: SRSF-4421: show all Account Executives, Interconnect Account Executive
        else if(custSuccessProfileList.contains(loggedInUser.Profile.Name))
        {             
            String userListQry = 'SELECT Id, Name, Budget_DMA__c, Budget_Type__c FROM User WHERE isActive = TRUE AND ((Profile.Name IN (\'Master - Interconnect Account Executive\',\'Master - Account Executive\') AND Region__c =\''+ loggedInUser.Region__c +'\')';

            if (loggedInUser.Profile.Name == 'Master - Sales Support Manager')
            { 
                userListQry+=' OR (UserRole.ParentRoleID != NULL AND (ManagerId = \'' + loggedInUser.Id +'\' OR ManagerId = \'' + currentUser.Id+'\'))';
            } 
            userListQry+= ') ORDER BY FirstName';  
            System.debug('userListQry>>>>'+userListQry);

            options.add(new SelectOption(loggedInUser.Id , loggedInUser.Name)); 
            for (User subUser : Database.query(userListQry))
            {
                options.add(new SelectOption(subUser.Id , subUser.Name));
                childUserMap.put(subUser.Id, subUser);
            }      
            
            if (currentUser != loggedInUser){ chosenUser = currentUser.Id; }
            else{ chosenUser = options[0].getValue(); } 
        }
        // END : SRSF-4421
        else
        {
            // Show only those users which report to this user
            options.add(new SelectOption(loggedInUser.Id , loggedInUser.Name));
            for (User subUser : [SELECT Id, Name, Budget_DMA__c, Budget_Type__c FROM User WHERE UserRole.ParentRoleID != NULL AND (ManagerId = :loggedInUser.Id OR ManagerId = :currentUser.Id) AND isActive = true ORDER BY firstname])    //AND Designation__c NOT IN :filteredDesignation
            {  
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

    /*
        Method to recursively get the User Hierarchy for the selected user for which Budgets are being requested.
    */
    private Set<Id> getAllSubUserIds(Set<ID> userIds)
    {
        Set<ID> currentUserIds = new Set<ID>();
        Map<String,String> localParentChildUserMap = new Map<String,String>();
        // get all of the user underneath the passed user
        for(User usr :[select Id,ManagerId FROM User WHERE ManagerId IN :userIds AND isActive = true])  //AND Designation__c NOT IN :filteredDesignation AND UserRole.ParentRoleID != null
        { 
            currentUserIds.add(usr.Id);
            localParentChildUserMap.put(usr.Id,usr.ManagerId);
        }
        
        // go fetch some more users!
        if(currentUserIds.size() > 0) 
        {
            System.debug(' @@@ entered @@@ ');
            for (String userId : localParentChildUserMap.keySet())
            {
                String managerId = localParentChildUserMap.get(userId);
                System.debug('managerId::'+managerId);
                System.debug('get managerId::'+globalParentChildUserMap.get(managerId));
                // Map the user to the record against which the records will be aggregated for viewing
                if (globalParentChildUserMap != null && globalParentChildUserMap.containsKey(managerId) && globalParentChildUserMap.get(managerId) != null)
                {
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
    public List<SelectOption> getFiscalYear()
    {
        List<SelectOption> options = new List<SelectOption>();         
        Integer startYear = Date.today().year()-2;  // SRSF-2595
        Integer endYear =  startYear + 6;  // SRSF-2595
        for(Integer i = startYear; i < endYear; i++){
            options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        return options;
    }

    public void fetchBudgetData()
    { 
        //Start : SRSF-2104
        String budgetQuery = 'SELECT SUM(Amount__c) rAmt ,CALENDAR_MONTH(Broadcast_Month_Date__c) bMonth, product_line__C prod FROM Budget__c WHERE Account__r.RecordType.DeveloperName != \'Competitor_Account\' AND RecordType.DeveloperName!=\'NewsTarget\' AND Year__c =: chosenFiscalYear AND Amount__c != 0 '; //Added AND RecordType.DeveloperName!=\'NewsTarget\'
        
        budgetQuery+=  ' AND BudgetAE__c = :chosenUser';
        //End : SRSF-2104
        //START - SRSF-3757
        List<String> profileLst = new List<String>{'Master - Account Executive','Master - Interconnect Account Executive'};
    
        if(profileLst.contains([SELECT Id, Profile.Name FROM User WHERE Id = :chosenUser].Profile.Name))
        {
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
            prodListForTradeTotals.add(ROWTYPE_BUDGET);
            prodListForPoliticalTotals.add(ROWTYPE_BUDGET);
        }
    }

    // SRSF-1785 changes Start : 10-06-2019    

    public void fetchPendingProjectedData ()
    {
        Map<String,List<Decimal>> pendingTotalsMap = new Map<String,List<Decimal>>();
        Map<String,List<Decimal>> projectedTotalsMap = new Map<String,List<Decimal>>();       
       
        pendingTotalsMap = fetchDataByRowType (ROWTYPE_PENDING);
        projectedTotalsMap = fetchDataByRowType (ROWTYPE_PROJECTED);       
             
        List<Decimal> pendingProjMap = calculateProductwiseTotals (null, pendingTotalsMap, projectedTotalsMap, null);
        if(!totalsMap.containsKey(ROWTYPE_PENDING_PROJECTED)){
            totalsMap.put(ROWTYPE_PENDING_PROJECTED,pendingProjMap);            
        }
    }    

    // SRSF - 4489 : Added forecastAdjustment calculations
    public List<Decimal> calculateProductwiseTotals (Map<String, List<Decimal>> existingBookedRows, Map<String, List<Decimal>> existingPendingRows, Map<String, List<Decimal>> existingProjectedRows, Map<String, List<Decimal>> existingforecastAdjRows)
    {
        List<Decimal> totalAmounts = new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0,0};
        List<Decimal> bookedAmounts = new List<Decimal>();
        List<Decimal> pendingAmounts = new List<Decimal>();
        List<Decimal> projectedAmounts = new List<Decimal>();
        List<Decimal> forecastAdjAmounts = new List<Decimal>();
        try {
                if (existingBookedRows!=null){
                    bookedAmounts = existingBookedRows.get(ROWTYPE_BOOKED);
                }     
                if (existingPendingRows!=null){
                    pendingAmounts = existingPendingRows.get(ROWTYPE_PENDING);
                } 
                if (existingProjectedRows!=null){
                    projectedAmounts = existingProjectedRows.get(ROWTYPE_PROJECTED);
                }
                if (existingforecastAdjRows!=null){
                    forecastAdjAmounts = existingforecastAdjRows.get(ROWTYPE_FORECAST_ADJUSTMENT);
                }

                for(Integer i=0; i<=12; i++)
                {  
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
        catch(Exception ex) { System.debug('### Exception ::: ' + ex.getMessage() + ' ### line number ::: ' +ex.getLineNumber());  }
        return totalAmounts;
    }
    

    public Map<String,List<Decimal>> fetchDataByRowType (String rowType)
    {
        Map<String,List<Decimal>> dataMap = new Map<String,List<Decimal>>();
        if(totalsMap.containsKey(rowType)) 
        { 
            dataMap.put(rowType,totalsMap.get(rowType));
            System.debug('dataMap>>>>>'+dataMap);                     
        }
        return dataMap; 
    }

    public void fetchGapData ()
    {
        Map<String,List<Decimal>> budgetTotalsMap = new Map<String,List<Decimal>>();
        Map<String,List<Decimal>> bookedTotalsMap = new Map<String,List<Decimal>>(); 

        budgetTotalsMap = fetchDataByRowType (ROWTYPE_BUDGET);      
        bookedTotalsMap = fetchDataByRowType (ROWTYPE_BOOKED);

        if(totalsMap.containsKey(ROWTYPE_BOOKED) || totalsMap.containsKey(ROWTYPE_BUDGET))
        {
            List<Decimal> gaps = calculateGap(budgetTotalsMap, bookedTotalsMap);
            if(!totalsMap.containsKey(ROWTYPE_GAP))
            {
                totalsMap.put(ROWTYPE_GAP,gaps);
            }  
        }  
        System.debug('totalsMap!!!!!'+totalsMap);
    }


    public List<Decimal> calculateGap (Map<String, List<Decimal>> existingBudgetRows, Map<String, List<Decimal>> existingBookedRows)
    {
        List<Decimal> totalGapAmounts = new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0,0};
        List<Decimal> budgetAmounts = new List<Decimal>();
        List<Decimal> bookedAmounts = new List<Decimal>();
        try 
        {  
                if (existingBudgetRows!=null){
                    budgetAmounts = existingBudgetRows.get(ROWTYPE_BUDGET);
                }
                if (existingBookedRows!=null){
                    bookedAmounts = existingBookedRows.get(ROWTYPE_BOOKED);
                }              
                for(Integer i=0; i<=12; i++)
                {
                    if (budgetAmounts!=null && bookedAmounts!=null){
                        totalGapAmounts[i] += bookedAmounts[i]-budgetAmounts[i];
                    }
                    if (budgetAmounts==null && bookedAmounts!=null){
                        totalGapAmounts[i] += bookedAmounts[i];   // Treating Budget Amount as 0
                    } 
                    if (budgetAmounts!=null && bookedAmounts==null){
                        totalGapAmounts[i] += 0-budgetAmounts[i]; // Treating Booked Amount as 0
                    } 
                }          
            System.debug('### totalGapAmounts ::: ' + totalGapAmounts);
        }
        catch(Exception ex) { System.debug('### Exception ::: ' + ex.getMessage() + ' ### line number ::: ' +ex.getLineNumber());  }
        return totalGapAmounts;
    }
    
    // SRSF-1785 changes End : 10-06-2019    

    // To calculate Rowwise Totals specific to Account
    public List<Decimal> calculateTotalForTwoRows(Map<String, List<Decimal>> existingBudgetRows)
    {
        System.debug(' ### existingBudgetRows keyset ::: ' +existingBudgetRows.keySet());
        List<Decimal> totalRowAmounts = new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0,0};
        try {
            for(String prod : existingBudgetRows.keySet()) {
                System.debug('### existingBudgetRows.get(prod) ::: ' + existingBudgetRows.get(prod));
                List<Decimal> monthAmounts = existingBudgetRows.get(prod);
                for(Integer i=0; i<=12; i++) {
                    totalRowAmounts[i] += monthAmounts[i];
                }
            }
            System.debug('### totalRowAmounts ::: ' + totalRowAmounts);
        }
        catch(Exception ex) {
            System.debug('### Exception ::: ' + ex.getMessage() + ' ### line number ::: ' +ex.getLineNumber());
        }
        return totalRowAmounts;
    }

    // START : SRSF-3393 : To calculate Rowwise Totals specific to Account & RowType
    public List<Decimal> calculateRowwiseTotalForTwoRows(Map<String, List<Decimal>> existingBudgetRows, String rowType)
    {
        System.debug(' ### existingBudgetRows keyset ::: ' +existingBudgetRows.keySet());
        List<Decimal> totalRowAmounts = new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0,0};
        try 
        {
            for(String prod : existingBudgetRows.keySet())
            {
                System.debug('prod>>>>>'+prod);
                if (prod.contains(rowType))
                {
                    System.debug('### existingBudgetRows.get(prod) ::: ' + existingBudgetRows.get(prod));
                    List<Decimal> monthAmounts = existingBudgetRows.get(prod);
                    for(Integer i=0; i<=12; i++) {
                        totalRowAmounts[i] += monthAmounts[i];
                    }
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

    public void fetchAccountRelatedRevenueRecords()
    {       
        String avlRevenueType = availableRevenueTypeList != null && !availableRevenueTypeList.isEmpty() ? '(\'' + String.join(availableRevenueTypeList,'\',\'') + '\')' : '';     

        String query = 'SELECT Sum(Net_Projected_Amount__c) rAmt, Product_Line__c prod, Revenue_Type__c revType, CALENDAR_MONTH(Broadcast_Month_Date__c) bMonth, Advertiser__r.Name adv, Advertiser__c advId FROM Revenue__c WHERE Year__c =: chosenFiscalYear  AND Account_Executive__c != null AND Account_Executive__c =: chosenUser AND Broadcast_Month_Date__c != null ';
    
        // Updated to include Wide Orbit Revenues in Forecast Matrix    
        if(String.isNotBlank(avlRevenueType)) query += ' AND (Source__c=\'WO\' OR (Net_Projected_Amount__c > 0 AND Revenue_Type__c IN ' + avlRevenueType+'))';  // SRSF-2072 : 20-02-2020      
        System.debug(' $$$ chosenDMAoption ::: ' +chosenDMAoption);
        System.debug(' $$$ availableBudgetDMAvalues ::: ' +availableBudgetDMAvalues); 
        System.debug(' $$$ availableGlidvalues-1 ::: ' +availableGlidvalues);

         // Start: 22-08-2019
        System.debug(' $$$ chosenGlidoption ::: ' +chosenGlidoption);
        if(String.isNotBlank(chosenGlidoption))
        {

            if(String.isNotBlank(availableBudgetDMAvalues) && 'All'.equalsIgnoreCase(chosenDMAoption))
            {
                query += ' AND Budget_DMA__c IN ' + availableBudgetDMAvalues;
            }
            else
            {
                query += ' AND Budget_DMA__c =: chosenDMAoption';                 
            }
        } else if(String.isNotBlank(chosenGlidoption) && 'All'.equalsIgnoreCase(chosenGlidoption))
        {
            query += ' AND Budget_DMA__c IN ' + availableBudgetDMAvalues;
        }
        // End: 22-08-2019
        
        query += ' GROUP BY Advertiser__r.Name, Advertiser__c, Product_Line__c, Revenue_Type__c, CALENDAR_MONTH(Broadcast_Month_Date__c) ORDER BY Advertiser__r.Name';
        System.debug(' ### Query Used ::: ' +query);
        AggregateResult[] revenueList = Database.query(query);
        System.debug(' $$$ revenueList size ::: ' +revenueList.size());
        performWeightageCalculation = false;        
        if(revenueList.size() > 0)
        {
            hasPolitical = avlRevenueType.contains('Political') ? true : false;
            hasTrade = avlRevenueType.contains('Trade') ? true : false;
            try
            {
                calculateAggregateResultAccountWise(revenueList, ROWTYPE_BOOKED);
                calculateTotalsSection(revenueList, ROWTYPE_BOOKED);
               
                if(totalsMap.containsKey(ROWTYPE_BOOKED) || (hasPolitical && politicalTotalsMap.containsKey(ROWTYPE_BOOKED) || (hasTrade && tradeTotalsMap.containsKey(ROWTYPE_BOOKED))))
                {  
                    if(hasTrade) {                        
                        prodListForTradeTotals.add(ROWTYPE_BOOKED);
                    }
                    if(hasPolitical) {                        
                        prodListForPoliticalTotals.add(ROWTYPE_BOOKED);
                    }
                }
            }
            catch(Exception ex)
            {
                System.debug(' ### Exception ::: ' + ex.getMessage()  + ' ### Line Number :::: ' +ex.getLineNumber());                
            }
        }
    }

    public void fetchPendingProposalZoneMonthlyValues()
    {          
        // Code Changes for SRSF – 1165 – Code Starts
        List<String> recordTypeIdList = new List<String>();  
        
        recordTypeIdList.add(String.valueOf(UtilityClass.getRecordTypeID(new Proposal__c(),chosenProduct)));
        System.debug(' ### recordTypeIdList ::: ' +recordTypeIdList);
        // Code Changes for SRSF – 1165 – Code Ends
        System.debug(' $$$ chosenUser ::: ' +chosenUser + ' $$$ chosenFiscalYear ::: ' +chosenFiscalYear + ' $$$ selectedSalesProb ::: ' +selectedSalesProb);
      
        String query = 'SELECT CALENDAR_MONTH(Broadcast_Month_Date__c) bMonth';
        if(isCompanyModel){  query += ' ,Sum(Broadcast_Amount__c) rAmt';
        }else query += ' ,Sum(Net_Amount__c) rAmt, Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c salesProbability';

        if(isNationalUser) query +=  ' ,Proposal_Zone__r.Proposal__r.Opportunity__r.DMA__c dma';
    
        query += ' ,Schedule_Type__c prod, Advertiser__r.Name Adv, Advertiser__c advId, Proposal_Zone__r.Proposal__r.Opportunity__c oppId, Proposal_Zone__r.Proposal__r.Opportunity__r.Name oppName FROM Proposal_Zone_Monthly_Value__c WHERE Year__c =: chosenFiscalYear  AND Proposal_Zone__r.Proposal__r.RecordTypeId IN :recordTypeIdList AND Proposal_Zone__r.Proposal__r.Active__c = true  AND Proposal_Zone__r.Proposal__r.Opportunity__r.OwnerId =: chosenUser AND Broadcast_Month_Date__c != null AND Status_Type__c = :ROWTYPE_PENDING AND (Proposal_Zone__r.Proposal__r.Opportunity__r.isClosed= false  OR Proposal_Zone__r.Proposal__r.Opportunity__r.isWon = true )';

        if(isCompanyModel)
        {
            query += ' AND Broadcast_Amount__c > 0';
        }else query += ' AND Net_Amount__c > 0 AND Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c IN : selectedSalesProb'; 

        if(isNationalUser)
        {          
            if(String.isNotBlank(availableBudgetDMAvalues) && 'All'.equalsIgnoreCase(chosenDMAoption))
            {
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
        if(pendingResults.size() > 0)
        {
            hasPolitical = chosenProduct.equalsIgnoreCase('Political') ? true : false;
            hasTrade = chosenProduct.equalsIgnoreCase('Trade') ? true : false;
            try
            {
                calculateAggregateResultAccountWise(pendingResults, ROWTYPE_PENDING);
                calculateTotalsSection(pendingResults, ROWTYPE_PENDING);                
                
                if(totalsMap.containsKey(ROWTYPE_PENDING) || (hasPolitical && politicalTotalsMap.containsKey(ROWTYPE_PENDING) || (hasTrade && tradeTotalsMap.containsKey(ROWTYPE_PENDING))))
                {
                    if(hasTrade)
                    {                    
                        prodListForTradeTotals.add(ROWTYPE_PENDING);
                    }
                    if(hasPolitical)
                    {                
                        prodListForPoliticalTotals.add(ROWTYPE_PENDING);
                    }
                }
            }
            catch(Exception ex) {
                System.debug(' ### Exception ::: ' + ex.getMessage()  + ' ### Line Number :::: ' +ex.getLineNumber());                
            }
        }
    }

    public void fetchProjectedProposalZoneMonthlyValues()
    {        
        List<String> recordTypeIdList = new List<String>();  
        recordTypeIdList.add(String.valueOf(Schema.SObjectType.Proposal__c.getRecordTypeInfosByDeveloperName().get('Opportunity_Budget').getRecordTypeId()));    
        
        System.debug(' ### recordTypeIdList ### ' +recordTypeIdList);      

        String query = 'SELECT CALENDAR_MONTH(Broadcast_Month_Date__c) bMonth';
        if(isCompanyModel){  query += ' ,Sum(Broadcast_Amount__c) rAmt';
        } else query += ' ,Sum(Net_Amount__c) rAmt, Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c salesProbability';  

        if(isNationalUser) query +=  ' ,Proposal_Zone__r.Proposal__r.Opportunity__r.DMA__c dma';

        query += ' ,Schedule_Type__c prod, Advertiser__r.Name Adv, Advertiser__c advId,  Proposal_Zone__r.Proposal__r.Opportunity__c oppId, Proposal_Zone__r.Proposal__r.Opportunity__r.Name oppName FROM Proposal_Zone_Monthly_Value__c WHERE Year__c =: chosenFiscalYear AND Proposal_Zone__r.Proposal__r.RecordTypeId IN :recordTypeIdList AND Proposal_Zone__r.Proposal__r.Active__c = true AND Proposal_Zone__r.Proposal__r.Opportunity__r.OwnerId =: chosenUser AND (Proposal_Zone__r.Proposal__r.Opportunity__r.isClosed= false  OR Proposal_Zone__r.Proposal__r.Opportunity__r.isWon = true) AND Broadcast_Month_Date__c != null';

        if(isCompanyModel)
        { 
            query += ' AND Broadcast_Amount__c > 0';
        }
        else query += ' AND Net_Amount__c > 0 AND Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c IN : selectedSalesProb';

        if(isNationalUser)
        {          
            if(String.isNotBlank(availableBudgetDMAvalues) && 'All'.equalsIgnoreCase(chosenDMAoption))
            {
                query += ' AND Proposal_Zone__r.Proposal__r.Opportunity__r.DMA__c IN ' + availableBudgetDMAvalues;
            }
            else {
              query += ' AND Proposal_Zone__r.Proposal__r.Opportunity__r.DMA__c =: chosenDMAoption';
            }
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
        if(projectedResults.size() > 0)
        {
            hasPolitical = isProdTypePolitical ;
            try 
            {
                calculateAggregateResultAccountWise(projectedResults, ROWTYPE_PROJECTED);
                calculateTotalsSection(projectedResults, ROWTYPE_PROJECTED);

                if(totalsMap.containsKey(ROWTYPE_PROJECTED) || (hasPolitical && politicalTotalsMap.containsKey(ROWTYPE_PROJECTED) || (hasTrade && tradeTotalsMap.containsKey(ROWTYPE_PROJECTED))))
                { 
                    if(hasTrade) {
                        prodListForTradeTotals.add(ROWTYPE_PROJECTED);
                    }
                    if(hasPolitical) {                        
                        prodListForPoliticalTotals.add(ROWTYPE_PROJECTED);
                    }
                }
            }
            catch(Exception ex)
            {
                System.debug(' ### Exception ::: ' + ex.getMessage()  + ' ### Line Number :::: ' +ex.getLineNumber());                
            }
        }
    }

    public void calculateAggregateResultAccountWise(AggregateResult[] aggResList, String rowType)
    {
        Map<String,List<Decimal>> typeAmount = new Map<String,List<Decimal>>();      
        String comparingKey = '';
        Integer integerToConsider = 1;
        for( AggregateResult rev : aggResList) {
            // System.debug('rev ' +rev );
            accIdMap.put((String)rev.get('Adv'), (String)rev.get('advId'));
            string prodName = '';
            prodName = String.isBlank((String)rev.get('prod'))? 'Linear':(String)rev.get('prod');
            System.debug(' $$$$ prodName ::: ' +prodName );

            if('Yes'.equalsIgnoreCase(Label.displayLinearAsProductType) && prodName.containsIgnoreCase('Linear'))
            {
                if(prodType_Linear_Map.containsKey(prodName))
                {
                    prodName = prodType_Linear_Map.get(prodName);
                }
            }
            List<Decimal> amounts = new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0,0};

            Decimal monthValue = ('Yes'.equalsIgnoreCase(Label.FM_TotalSection_RoundOff)) ? ((Decimal)rev.get('rAmt')) : (((Decimal)rev.get('rAmt')).round(System.RoundingMode.HALF_UP));
            if(!isActual && performWeightageCalculation)
            {
               String probability = (String)rev.get('salesProbability');             
               monthValue = (monthValue*Integer.valueOf(probability))/100;
               System.debug(' $$$ after applying probability ::: ' +monthValue);
            }

            if(!typeAmount.containsKey((String)rev.get('Adv') + '_' + prodName + '_' + rowType))
            {
                amounts[Integer.valueOf(rev.get('bMonth'))-1] = monthValue;
            }
            else
            {               
                amounts = typeAmount.get((String)rev.get('Adv') + '_' + prodName + '_' + rowType);
                amounts[Integer.valueOf(rev.get('bMonth'))-1] = amounts[Integer.valueOf(rev.get('bMonth'))-1] + monthValue;
            }
            typeAmount.put((String)rev.get('Adv') + '_' + prodName + '_' + rowType,amounts);
            System.debug('$$$$$ amounts :::: ' +amounts );
        }
        System.debug('$$$$ typeAmount :::: ' +typeAmount );
        accProdTypesMap = new Map<String, Set<String>>();

        for(String str : typeAmount.keySet())
        {
            String[] keyList = str.split('_');
            if(String.isNotBlank(keyList[1]))    // Check to eliminate the records which doesn't have product type
            { 
                if(!accProdTypesMap.containsKey(keyList[0]))
                {
                    accProdTypesMap.put(keyList[0], new Set<String>{keyList[1]});
                }
                else
                {
                    accProdTypesMap.get(keyList[0]).add(keyList[1]);
                }
            }
        }
        System.debug('$$$ accProdTypesMap ::: ' +accProdTypesMap);

        for(String str : accProdTypesMap.keySet())
        {
            List<productTypeWrapper> productTypeWrapperList = new List<productTypeWrapper>();
            if(String.isNotBlank(str))
            {
                for(String prod : accProdTypesMap.get(str))
                {
                    String mapKey = str + '_' + prod + '_' + rowType;
                    List<Decimal> prodMonthAmountMap = new list<Decimal>();
                    if(typeAmount.containsKey(mapKey))
                    { 
                        prodMonthAmountMap = typeAmount.get(mapKey);
                    }

                    Map<Integer, Decimal> monthAmountMap = new Map<Integer, Decimal>();
                    for(Integer i =1; i <=prodMonthAmountMap.size(); i++) 
                    {
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

    public void populateForecastWrapperMap(String accName, String prodType, List<forecastWrapper> forecastWrpList) 
    {
        if(!forecastWrapMap.containsKey(accName + '_' + prodType))
        {
            forecastWrapMap.put(accName + '_' + prodType, forecastWrpList);
        }
        else
        {
            forecastWrapMap.get(accName + '_' + prodType).addAll(forecastWrpList);
        }
    }

    public void reArrangeAccGroupMap()
    {
        accGroupMap = new Map<String, List<productTypeWrapper>>();
        for(String str : forecastWrapMap.keySet())
        {
            String[] keyList = str.split('_');
            if(!accGroupMap.containsKey(keyList[0]))
            {
                if(accIdMap.containsKey(keyList[0]))
                {
                    accGroupMap.put(keyList[0], new List<productTypeWrapper>{new productTypeWrapper(keyList[1], forecastWrapMap.get(str), accIdMap.get(keyList[0]))});
                }
            }
            else
            {
                if(accIdMap.containsKey(keyList[0]))
                {
                    accGroupMap.get(keyList[0]).add(new productTypeWrapper(keyList[1], forecastWrapMap.get(str), accIdMap.get(keyList[0])));
                }
            }
        }
        for(String acc : accGroupMap.keySet())
        {
            List<productTypeWrapper> prodTypeWrapList = new List<productTypeWrapper>();
            prodTypeWrapList = accGroupMap.get(acc);
            Map<String, List<Decimal>> accProdRowTypeMap = new Map<String, List<Decimal>>();
            List<Decimal> accWiseTotalRow = new List<Decimal>();
            Decimal totalColAmount = 0.00;
            for(productTypeWrapper ptw : prodTypeWrapList)
            {
                for(forecastWrapper fcw : ptw.forecastWrpList_prod)
                {
                    List<Decimal> monthDecimals = new List<Decimal>(fcw.monthsData);
                    monthDecimals.add(fcw.totalRowAmount);
                    accProdRowTypeMap.put(ptw.prodType + '_' + fcw.rowType, monthDecimals);
                }
            }
            System.debug('accProdRowTypeMap >>>>>>>'+accProdRowTypeMap);
            accWiseTotalRow = calculateTotalForTwoRows(accProdRowTypeMap);
            System.debug('accWiseTotalRow >>>>>>>'+accWiseTotalRow);
            Map<Integer, Decimal> monthAmountMap = new Map<Integer, Decimal>();
            for(Integer i =1; i <=accWiseTotalRow.size(); i++)
            {
                monthAmountMap.put( i , accWiseTotalRow[i-1]);
            }

            List<forecastWrapper> budgetForecastWrpList = new List<forecastWrapper>();
            budgetForecastWrpList.add(new forecastWrapper('Total', monthAmountMap));
            populateForecastWrapperMap(acc,'Total',budgetForecastWrpList);

            accGroupMap.get(acc).add(new productTypeWrapper('Total', forecastWrapMap.get(acc+'_'+'Total'), accIdMap.get(acc)));
            System.debug(' $$$ accWiseTotalRow ::: ' + accWiseTotalRow);
        }
        // START : SRSF-3393               
           calculateTotalForEachRowType(ROWTYPE_BOOKED); 
           calculateTotalForEachRowType(ROWTYPE_PENDING); 
           calculateTotalForEachRowType(ROWTYPE_PROJECTED);     
        // END : SRSF-3393

        calculateQuarterlyTotalsAccountwise (accGroupMap, false, false); // 20-06-2019
        System.debug('$$$ accGroupMap ::: ' +accGroupMap.values());
    }

    // SRSF-3393 : populate accGroupMap with Rowwise Totals specific to Account & RowType
    public void calculateTotalForEachRowType (String rowType)
    {
        System.debug('inside calculateTotalForEachRowType>>>>');
        for(String acc : accGroupMap.keySet())
        {
            List<productTypeWrapper> prodTypeWrapList = new List<productTypeWrapper>();
            prodTypeWrapList = accGroupMap.get(acc);
            Map<String, List<Decimal>> accProdRowTypeMap = new Map<String, List<Decimal>>();
            
            for(productTypeWrapper ptw : prodTypeWrapList)
            {
                for(forecastWrapper fcw : ptw.forecastWrpList_prod)
                {
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

            for(Integer i =1; i <=accRowwiseTotalRow.size(); i++)
            {
                rowWiseMonthAmountMap.put( i , accRowwiseTotalRow[i-1]);
            }            

            List<forecastWrapper> forecastWrpListRowwise = new List<forecastWrapper>();       
            forecastWrpListRowwise.add(new forecastWrapper(rowType+'_Total', rowWiseMonthAmountMap));         
            populateForecastWrapperMap(acc,rowType+'_Total',forecastWrpListRowwise);            
            accGroupMap.get(acc).add(new productTypeWrapper(rowType+'_Total', forecastWrapMap.get(acc+'_'+rowType+'_Total'), accIdMap.get(acc))); 
        }
    }

    // Start : SRSF-1785 : 20-06-2019
    public void calculateQuarterlyTotalsAccountwise (Map<String, List<productTypeWrapper>> accountMapToCalculate, Boolean isPolitical, Boolean isTrade)
    {
        System.debug(' #### accountMapToCalculate :::: ' +accountMapToCalculate);
        if(accountMapToCalculate != null && !accountMapToCalculate.isEmpty())
        {
            for (String accName : accountMapToCalculate.keySet())
            {            
                for(productTypeWrapper ptw1 : accountMapToCalculate.get(accName))
                {
                    System.debug('ptw1 @@@@@@@@@@'+ptw1);
                    for(forecastWrapper fcw1 : ptw1.forecastWrpList_prod) 
                    {
                        List<Decimal> quarterlyTotalsAcctwise = new List<Decimal>();
                        System.debug('fcw1 @@@@@@@'+fcw1);
                        List<Decimal> monthDecimals = new List<Decimal>(fcw1.monthsData);                        
                        if(monthDecimals.size() > 0)
                        {                            
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

    public void calculateQuarterlyTotals() 
    {
        System.debug(' ---- hasPolitical ----- ' +hasPolitical + ' ------- hasTrade ------- '+hasTrade);
        if(!hasPolitical && !hasTrade && !totalsMap.isEmpty()) {
            calculateQuarterlyTotals(totalsMap, false, false);
        }
        if(hasPolitical && !hasTrade && !politicalTotalsMap.isEmpty()) {
            calculateQuarterlyTotals(politicalTotalsMap, true, false);
        }
        if(!hasPolitical && hasTrade && !tradeTotalsMap.isEmpty()) {
            calculateQuarterlyTotals(tradeTotalsMap, false, true);
        }
    }

    public void calculateQuarterlyTotals(Map<String, List<Decimal>> totalMapToCalculate, Boolean isPolitical, Boolean isTrade) 
    {
        System.debug(' #### totalMapToCalculate :::: ' +totalMapToCalculate + ' #### prodListForTotals :::: '+prodListForTotals + ' ### prodListForTradeTotals ::: ' + prodListForTradeTotals + ' #### prodListForPoliticalTotals ' +prodListForPoliticalTotals);
        
        Map<String, List<Decimal>> quarterTotalsMap = new Map<String, List<Decimal>>();
        if(totalMapToCalculate != null && !totalMapToCalculate.isEmpty()) 
        {
            for(String rowType : totalMapToCalculate.keySet()) 
            {
                List<Decimal> quarterlyTotal = new List<Decimal>();
                System.debug(' $$$ cpu limit ::: ' +limits.getCpuTime() + ' $$$ Max cpu time'+ Limits.getLimitCpuTime());
                List<Decimal> monthlyRow = new List<Decimal>(totalMapToCalculate.get(rowType));
                if(monthlyRow.size() > 0) 
                {                        
                    quarterlyTotal.add(monthlyRow[0] + monthlyRow[1] + monthlyRow[2]);
                    quarterlyTotal.add(monthlyRow[3] + monthlyRow[4] + monthlyRow[5]);
                    quarterlyTotal.add(monthlyRow[6] + monthlyRow[7] + monthlyRow[8]);
                    quarterlyTotal.add(monthlyRow[9] + monthlyRow[10] + monthlyRow[11]);
                }
                if(!quarterTotalsMap.containsKey(rowType)) 
                {
                    quarterTotalsMap.put(rowType, quarterlyTotal);
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

    public void calculateTotalsSection(AggregateResult[] aggResults, String rowType) 
    {
        amtMap = new Map<String, List<Decimal>> ();
        oppData = new Map<String,List<String>>(); //SRSF-2485              
        
        for(AggregateResult agr : aggResults) 
        {           
            Integer monthIndex = 2;
            Decimal monthValue = 0.00;
            String oppId, oppName, advertiserName, oppAccName, advId, advName, advAmt; //SRSF-2485, 4099 
            Decimal amt; 
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

            if(agr.get('rAmt')  != null) 
            {                           
                monthValue = ('Yes'.equalsIgnoreCase(Label.FM_TotalSection_RoundOff)) ? ((Decimal)agr.get('rAmt')) : (((Decimal)agr.get('rAmt')).round(System.RoundingMode.HALF_UP));

                if(!isActual && performWeightageCalculation) {
                   String probability = (String)agr.get('salesProbability');
                   System.debug(' $$$ probability ::: ' +probability + ' and month value ::: ' +monthValue + ' $$$ month Index ::: ' +monthIndex);
                   monthValue = (monthValue*Integer.valueOf(probability))/100;
                   System.debug(' $$$ after applying probability ::: ' +monthValue);
                }
            }
            
            if(!amtMap.containsKey(rowType)) 
            {
                List<Decimal> amtList = new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0,0};
                amtList.set(monthIndex-1, monthValue);
                amtList.set(12,monthValue); // To calculate Row Total
                amtMap.put(rowType, amtList);
                System.debug ('amtList-1>>>>>'+amtList);          

                if(rowType.equals(ROWTYPE_PENDING) || rowType.equals(ROWTYPE_PROJECTED))
                { 
                  List<String> oppIds = new List<String>{'','','','','','','','','','','','',''}; 
                   // oppData.put('Total',null);
                    oppIds.set(monthIndex-1, oppId);                
                    oppIds.set(12, '');//For Total
                    oppData.put(rowType, oppIds);
                }    
                //END : SRSF-2485
                //START SRSF-4022
                if(rowType.equals(ROWTYPE_NEWS_REVENUE))
                {
                    List<String> advIds = new List<String>{'','','','','','','','','','','','',''}; 
                    newsRevAccDtls.put('Total',null);
                    advIds.set(monthIndex-1, advId+'_'+advName.replaceAll('[\"\']', '')+'_'+advAmt);
                    advIds.set(12, '');//For Total
                    newsRevAccDtls.put(rowType, advIds);
                }
                //END : SRSF-4022 
            } 
            else 
            {
                List<Decimal> mapValue = amtMap.get(rowType);
                Decimal newMonthValue = mapValue.get(monthIndex-1) + monthValue;
                Decimal newRowTotal = mapValue.get(12) + monthValue;
                mapValue.set(monthIndex-1, newMonthValue);
                mapValue.set(12,newRowTotal); // To calculate Row Total
                amtMap.put(rowType, mapValue);                
                System.debug ('amtMap-1>>>>>'+amtMap);
                
                if(rowType.equals(ROWTYPE_PENDING) || rowType.equals(ROWTYPE_PROJECTED))
                {  
                    List<String> mapData = oppData.get(rowType); 
                    Integer index = monthIndex-1;
                    
                    if(!CommonUtilities.isStringNullOrEmpty(mapData.get(index)))
                    {                       
                        if(!mapData.get(index).contains(oppId)) 
                        {    
                            mapData.set(index, mapData.get(index)+'_'+oppId); 
                        } 
                    } else {
                        mapData.set(index, oppId); 
                    }                                                          
                    oppData.put(rowType, mapData);
                }
                System.debug('oppData-2>>>>>>>>'+oppData);
                if(rowType.equals(ROWTYPE_NEWS_REVENUE))
                { 
                    List<String> mapData = newsRevAccDtls.get(rowType); 
                    String allAdvrecs;
                    String accKey = advId+'_'+ advName.replaceAll('[\"\']', '')+'_'+advAmt;
                    if(String.isNotBlank(mapData.get(monthIndex-1)))
                    {
                       allAdvrecs =  mapData.get(monthIndex-1)+';;;'+accKey;
                    } else allAdvrecs = accKey;
                    mapData.set(monthIndex-1, allAdvrecs);
                    newsRevAccDtls.put(rowType, mapData); 
                }
            } 
            if(rowType.equals(ROWTYPE_PENDING) || rowType.equals(ROWTYPE_PROJECTED))
            {
                oppAccName = oppName+'||'+advertiserName;
                oppAccName = oppAccName.replaceAll('[\"\']', '');
                oppDetailsMap.put(oppId, oppAccName);
                String formNetAmtsKey =  oppId+'_'+rowType+'_'+monthIndex;
                if(!oppNetAmtMap.containsKey(formNetAmtsKey)){
                    oppNetAmtMap.put(formNetAmtsKey, monthValue);
                }
                else
                {
                    Decimal newamt = oppNetAmtMap.get(formNetAmtsKey) + monthValue; 
                    oppNetAmtMap.put(formNetAmtsKey, newamt); 
                }
                System.debug('formNetAmtsKey-->'+ formNetAmtsKey);
                System.debug('oppNetAmtMap--->'+ oppNetAmtMap);
                System.debug('Opportunity Details--->'+ oppDetailsMap);
            }     
        }
        System.debug('Opps data-->'+oppData);
        if(rowType.equals(ROWTYPE_NEWS_TARGET) || rowType.equals(ROWTYPE_NEWS_REVENUE)) 
        {            
            newsTotalsMap.put(rowType, amtMap.get(rowType));
        }
        else totalsMap.put(rowType, amtMap.get(rowType));
        //SRSF-2485 
        if(rowType.equals(ROWTYPE_PENDING) || rowType.equals(ROWTYPE_PROJECTED))
            opportunityMap.put(rowType, oppData.get(rowType));            
        //End SRSF-2485
        System.debug(' $$$ totalsMap1 ::: ' +totalsMap + ' $$$ hasPolitical ::: ' +hasPolitical + ' $$$ hasTrade ::: ' +hasTrade);
  
        if((hasPolitical || hasTrade)) 
        {            
            if(hasPolitical)
            {
                politicalTotalsMap.put(rowType, amtMap.get(rowType));
            }
            if(hasTrade)
            {
                tradeTotalsMap.put(rowType, amtMap.get(rowType));                
            }
        }
        System.debug('$$$ totalsMap:::'+totalsMap);                
        System.debug('$$$ tradeTotalsMap :::'+tradeTotalsMap);
        System.debug('$$$ politicalTotalsMap ::: ' +politicalTotalsMap);
        System.debug('$$$ newsTotalsMap ::: ' +newsTotalsMap);
        System.debug('$$$ opportunityMap-->'+opportunityMap);//SRSF-2485
    }
    
    public List<String> getPicklistValues() 
    {
        List<String> options = new List<String>();            
        Schema.DescribeFieldResult fieldResult = Proposal_Zone_Monthly_Value__c.Schedule_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
        for( Schema.PicklistEntry f : ple) 
        {
            options.add(f.getValue());
        }       
        return options;
    }
    
    public Map<String,ForecastMatrix_Labels__mdt> getPerformanceLabels() 
    {
        Map<String,ForecastMatrix_Labels__mdt> labelMap = new Map<String,ForecastMatrix_Labels__mdt>();
        List<ForecastMatrix_Labels__mdt> labelList=ForecastMatrix_Labels__mdt.getAll().values();

        for(ForecastMatrix_Labels__mdt label : labelList) 
        {
            if(label.isVisible__c)
            {
                labelMap.put(label.developername,label);
                performanceLabels.add(label.developername);
            }
        }
        System.debug('performanceLabels--->'+performanceLabels);
        return labelMap;
    }
    
    public void calculateAllPerformancePercentage() 
    {
        prodMonthAmountMap = new Map<String, List<Decimal>>();
        List<String> prodList = getPicklistValues();
        
        performanceMap1 = new Map<String,List<Decimal>>();
        Map<String, List<String>> amountProd = new Map<String, List<String>>(); 
        
        if(totalsMap.containsKey(ROWTYPE_BUDGET)) 
        {
            Boolean hasPending = false,hasBooked = false,hasProjected = false, hasForecastAdj = false;
                        
            // Booked to Budget Calculations
            Map<String,List<Decimal>> amountsBookedMap = new Map<String,List<Decimal>>();
                if(totalsMap.containsKey(ROWTYPE_BOOKED)) 
                {
                   hasBooked = true;

                    if(!performanceMap1.containsKey('BookedBudget')) 
                    {
                        List<Decimal> amtList = calculateBudgetPercentage(totalsMap.get(ROWTYPE_BOOKED),totalsMap.get(ROWTYPE_BUDGET)); 
                        performanceMap1.put('BookedBudget',amtList);
                    }                                     
                }   
                System.debug('performanceMap1>>>>'+performanceMap1);               
               
                // START : SRSF-4489
                //Booked + Pending + Projected + Forecast Adjustment / Budget
                System.debug('performanceMap1 str ' + performanceMap1);
                if(totalsMap.containsKey(ROWTYPE_PENDING)) {
                    hasPending = true;             
                }

                if(totalsMap.containsKey(ROWTYPE_PROJECTED)) {
                    hasProjected = true;             
                }
               
                if(totalsMap.containsKey(ROWTYPE_FORECAST_ADJUSTMENT)) { 
                    hasForecastAdj = true;                    
                }                
             
                if(hasPending || hasBooked || hasProjected || hasForecastAdj)
                { 

                    if(!totalsMap.containsKey(ROWTYPE_BOOKED_PENDING_PROJECTED_FORECAST_ADJUSTMENT))
                    {
                        fetchBookedPendingProjectedForecastAdjData();
                    }    
                    System.debug('bookedPendingProjForecastAdjMap>>>>'+totalsMap.get(ROWTYPE_BOOKED_PENDING_PROJECTED_FORECAST_ADJUSTMENT));

                    if(!performanceMap1.containsKey('BookedPendingProjectedForecastAdj'))
                    {
                        performanceMap1.put('BookedPendingProjectedForecastAdj',calculateBudgetPercentage(totalsMap.get(ROWTYPE_BOOKED_PENDING_PROJECTED_FORECAST_ADJUSTMENT),totalsMap.get(ROWTYPE_BUDGET)));
                    }
                }                
                System.debug('$$$ testing :::: ' + performanceMap1.get('BookedPendingProjectedForecastAdj'));
                // END : SRSF-4489
            }
        
        System.debug('### performanceLabels ::: '+performanceLabels);

        for(string str: performanceLabels) 
        {
            if(performanceMap1.containsKey(str))
            {
                performanceMap.put(str,performanceMap1.get(str));
            }
            else 
            {
                List<Decimal> amntList = new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0,0};
                performanceMap.put(str,amntList);
            }            
        }
        
        System.debug(' Performance Table keys '+performanceMap.keySet());
    }
     
    public List<Decimal> calculateBudgetPercentage(List<Decimal> deciLt1, List<Decimal> deciLt2) 
    {
        System.debug(' $$$ deciLt1 ::: ' +deciLt1 + ' $$$ deciLt2 ::: ' +deciLt2);         
        List<Decimal> bookedToBudgetprodMonthAmountMap = new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}; // 24-06-2019
        
        if(deciLt1 != null && deciLt2 != null) 
        {
            for(Integer i=0; i<=12; i++) 
            {
                if(deciLt2[i] > 0)  //  && i != 12
                { 
                    bookedToBudgetprodMonthAmountMap[i] = (deciLt1[i]/deciLt2[i])*100;

                    // Start: 24-06-2019     
                    if (deciLt2[0]>0 || deciLt2[1]>0 || deciLt2[2]>0)
                    {
                        bookedToBudgetprodMonthAmountMap[13] = ((deciLt1[0]+deciLt1[1]+deciLt1[2])/(deciLt2[0]+deciLt2[1]+deciLt2[2]))*100;     // Q1   
                    } else
                    {                         
                        bookedToBudgetprodMonthAmountMap[13] = 0; // Q1    
                    }  

                    if (deciLt2[3]>0 || deciLt2[4]>0 || deciLt2[5]>0)
                    {
                        bookedToBudgetprodMonthAmountMap[14] = ((deciLt1[3]+deciLt1[4]+deciLt1[5])/(deciLt2[3]+deciLt2[4]+deciLt2[5]))*100;     // Q2
                    } else
                    {                        
                        bookedToBudgetprodMonthAmountMap[14] = 0;     // Q2
                    } 

                    if (deciLt2[6]>0 || deciLt2[7]>0 || deciLt2[8]>0)
                    {
                        bookedToBudgetprodMonthAmountMap[15] = ((deciLt1[6]+deciLt1[7]+deciLt1[8])/(deciLt2[6]+deciLt2[7]+deciLt2[8]))*100;     // Q3
                    } else 
                    {                        
                        bookedToBudgetprodMonthAmountMap[15] = 0;     // Q3
                    }

                    if (deciLt2[9]>0 || deciLt2[10]>0 || deciLt2[11]>0)
                    {
                        bookedToBudgetprodMonthAmountMap[16] = ((deciLt1[9]+deciLt1[10]+deciLt1[11])/(deciLt2[9]+deciLt2[10]+deciLt2[11]))*100; // Q4
                    } else
                    {                       
                       bookedToBudgetprodMonthAmountMap[16] = 0; // Q4
                    }                    
                    // End: 24-06-2019
                }               
                else { bookedToBudgetprodMonthAmountMap[i] = 0; }
            }
        }        
        System.debug(' ##### bookedToBudgetprodMonthAmountMap :::: ' +bookedToBudgetprodMonthAmountMap);
        return bookedToBudgetprodMonthAmountMap;
    }


    // To get the GLID details of a Selected user
    public void fetchGLIDDetails()
    {
        String selectedUser = Apexpages.currentPage().getParameters().get('selectedUser');
        System.debug( ' $$$ ENETERED INTO GLID DETAILS & SELECTED USER ::::: ' +selectedUser);
        System.debug( ' $$$ chosenUser ::::: ' +chosenUser);                     
        GLIDoptions = new List<SelectOption>(); 
        budgetDMAoptions = new List<SelectOption>();
        glidList = new List<String>();      
        glidBudgetDMAMap = new Map<String, String>();

        if(String.isBlank(selectedUser)) { selectedUser = chosenUser; } 

        if(String.isNotBlank(selectedUser))
        {          
            List<GLIDMapping__c> glidMappingList = [SELECT Id, GLIDName__c, UserID__c, BudgetDMA__c, IsActive__c, UserID__r.Budget_Type__c FROM GLIDMapping__c WHERE UserID__c =: selectedUser AND IsActive__c=true];
            if(glidMappingList.Size()>0 && 'National'.equalsIgnoreCase(glidMappingList[0].UserID__r.Budget_Type__c))
            {
                isNationalUser = true;                
                GLIDoptions.add(new SelectOption('All', 'All')); 
                for(GLIDMapping__c usrGlid : glidMappingList)
                {                  
                    GLIDoptions.add(new SelectOption(usrGlid.GLIDName__c, usrGlid.GLIDName__c));                    
                    if(!glidBudgetDMAMap.containsKey(usrGlid.GLIDName__c))
                    {
                        glidList.add(usrGlid.GLIDName__c);
                        glidBudgetDMAMap.put(usrGlid.GLIDName__c, usrGlid.BudgetDMA__c);
                    }
                }                            
                System.debug('glidBudgetDMAMap>>>>>'+glidBudgetDMAMap);
            } else { isNationalUser = false; }            
        }
        return;
    }   

    // To get the budget DMA details of a selected user
    public void fetchBudgetDMAdetails()
    {      
        String selectedGlid = Apexpages.currentPage().getParameters().get('selectedGlid'); // GLID Change
        System.debug( ' $$$ ENETERED INTO BUDGET DMA DETAILS & SELECTED GLID ::::: ' +selectedGlid);
        budgetDMAoptions = new List<SelectOption>();
        budgetDMAList = new List<String>();
        String budgetDMAs=''; // GLID Change
        System.debug('chosenGlidoption>>>'+chosenGlidoption);
        if(String.isBlank(selectedGlid)) { selectedGlid = chosenGlidoption; } // GLID Change 

        if (String.isNotBlank(selectedGlid) && 'All'.equalsIgnoreCase(selectedGlid))
        {  
            if (String.isBlank(chosenDMAoption)){chosenDMAoption = 'All';}          
            
            for (String gld: glidList)
            {                
                if(String.isNotBlank(budgetDMAs)) { budgetDMAs = budgetDMAs + ';'+glidBudgetDMAMap.get(gld);} else {budgetDMAs = glidBudgetDMAMap.get(gld);}
            }    
        } else if(String.isNotBlank(selectedGlid) && !'All'.equalsIgnoreCase(selectedGlid))
        {
            budgetDMAs = glidBudgetDMAMap.get(selectedGlid); 
        }
        
        if(String.isNotBlank(budgetDMAs)) { budgetDMAList = budgetDMAs.split(';'); }

        if(budgetDMAList!= null && budgetDMAList.size() > 0)
        {
            budgetDMAoptions.add(new SelectOption('All', 'All'));
            for(String str : budgetDMAList)
            {
                budgetDMAoptions.add(new SelectOption(str, str));
            }
        }       
        System.debug(' $$$$ budgetDMAoptions :::: ' +budgetDMAoptions);
        return;
    }  
    // Start : SRSF-2105
    public void fetchNewsTargetData()
    {
        if(!hasTrade && !hasPolitical)
        {
            hasNews = true;
            performWeightageCalculation = false; 

            //NEWS REVENUE starts here        
            String avlRevenueType = availableRevenueTypeList != null && !availableRevenueTypeList.isEmpty() ? '(\'' + String.join(availableRevenueTypeList,'\',\'') + '\')' : '';
          
            String newsRevenue = 'SELECT Sum(Net_Projected_Amount__c) rAmt, Product_Line__c prod, Revenue_Type__c revType, CALENDAR_MONTH(Broadcast_Month_Date__c) bMonth, Advertiser__r.Name adv, Advertiser__c advId FROM Revenue__c WHERE Year__c =: chosenFiscalYear  AND Account_Executive__c != null AND Account_Executive__c =: chosenUser AND Broadcast_Month_Date__c != null AND IsNews__c=true ';
           
            if(String.isNotBlank(avlRevenueType)) 
                newsRevenue += ' AND Net_Projected_Amount__c > 0 AND Revenue_Type__c IN ' + avlRevenueType;  
       
            if(String.isNotBlank(chosenGlidoption))
            {
                if(String.isNotBlank(availableBudgetDMAvalues) && 'All'.equalsIgnoreCase(chosenDMAoption))
                    newsRevenue += ' AND Budget_DMA__c IN ' + availableBudgetDMAvalues;            
                else newsRevenue += ' AND Budget_DMA__c =: chosenDMAoption';
            }
            else if(String.isNotBlank(chosenGlidoption) && 'All'.equalsIgnoreCase(chosenGlidoption))
            {
                newsRevenue += ' AND Budget_DMA__c IN ' + availableBudgetDMAvalues;
            }    

            newsRevenue += ' GROUP BY Advertiser__r.Name, Advertiser__c, Product_Line__c, Revenue_Type__c, CALENDAR_MONTH(Broadcast_Month_Date__c) ORDER BY Advertiser__r.Name';

            System.debug(' ### News Revenue Query ::: ' +newsRevenue);
            AggregateResult[] newsRevenueList = Database.query(newsRevenue);
            System.debug(' $$$ News revenueList ::: ' +newsRevenueList);
           
            if(newsRevenueList.size() > 0)
            {
                try
                {
                    calculateTotalsSection(newsRevenueList, ROWTYPE_NEWS_REVENUE);
                }
                catch(Exception ex)
                {
                    System.debug('### Exception :::'+ex.getMessage()+' ### Line Number :::: ' +ex.getLineNumber());                    
                }
            }

            // NEWS TARGET Starts here
            String newsTargetbudget = 'SELECT SUM(Amount__c) rAmt ,CALENDAR_MONTH(Broadcast_Month_Date__c) bMonth, product_line__C prod FROM Budget__c WHERE Account__r.RecordType.DeveloperName != \'Competitor_Account\' AND Year__c =:chosenFiscalYear AND Amount__c != 0 AND RecordType.DeveloperName=\'NewsTarget\' AND Product_Line__c NOT IN (\'Political\',\'Trade\')'; 
           
            newsTargetbudget+=  ' AND BudgetAE__c = :chosenUser';

            if(isNationalUser)
            {          
                if(String.isNotBlank(availableBudgetDMAvalues) && 'All'.equalsIgnoreCase(chosenDMAoption))
                    newsTargetbudget += ' AND DMA__c IN ' + availableBudgetDMAvalues;
                else newsTargetbudget += ' AND DMA__c =: chosenDMAoption';
            }
            newsTargetbudget += ' Group BY Calendar_Month(Broadcast_Month_Date__c), Product_Line__c';

            AggregateResult[] newsTargetbudgetResults = Database.query(newsTargetbudget);
            System.debug(' $$$ News Target budgetResults ::: ' +newsTargetbudgetResults);            

            if(newsTargetbudgetResults.size() > 0)
            {
                try {
                    calculateTotalsSection(newsTargetbudgetResults, ROWTYPE_NEWS_TARGET);
                }
                catch(Exception ex) {
                    System.debug('### Exception :::'+ex.getMessage()+' ### Line Number :::: ' +ex.getLineNumber());                    
                }
            }

            // Calculate Quarterly values for NewsRevenue and NewsTarget
            if(newsTotalsMap != null && !newsTotalsMap.isEmpty())
            {
                for(String rowType : newsTotalsMap.keySet())
                {
                    System.debug(' $$$ cpu limit ::: ' +limits.getCpuTime() + ' $$$ Max cpu time'+ Limits.getLimitCpuTime());
                    List<Decimal> monthlyRow = new List<Decimal>(newsTotalsMap.get(rowType));
                    if(monthlyRow.size() > 0)
                    {
                       List<Decimal> quarterlyTotal =  newsTotalsMap.get(rowType);
                       quarterlyTotal.add(monthlyRow[0] + monthlyRow[1] + monthlyRow[2]);
                       quarterlyTotal.add(monthlyRow[3] + monthlyRow[4] + monthlyRow[5]);
                       quarterlyTotal.add(monthlyRow[6] + monthlyRow[7] + monthlyRow[8]);
                       quarterlyTotal.add(monthlyRow[9] + monthlyRow[10] + monthlyRow[11]);
                    }
                }
            }
            System.debug(' $$$ newsTotalsMap ::: ' +newsTotalsMap);

            // Calculate News To News Revenue
            if(newsTotalsMap != null && newsTotalsMap.size()>0 && newsTotalsMap.containsKey(ROWTYPE_NEWS_REVENUE) && newsTotalsMap.containsKey(ROWTYPE_NEWS_TARGET))
            {
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

    public void CalculateNewsToNewsRevenueData()
    {
        if(newsTotalsMap.size()>0)
        {
            List<Decimal> amountsNewsList = new List<Decimal>();
            if(newsTotalsMap.containsKey(ROWTYPE_NEWS_REVENUE))
            {               
                if(newsTotalsMap.containsKey(ROWTYPE_NEWS_TARGET))
                {
                    amountsNewsList = calculateBudgetPercentage(newsTotalsMap.get(ROWTYPE_NEWS_REVENUE),newsTotalsMap.get(ROWTYPE_NEWS_TARGET));
                }
            }
             newsTotalsMap.put(ROWTYPE_NEWS_REVENUE_TO_NEWS_TARGET,amountsNewsList);
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
    public void fetchAdjustOppBudgetPZMVs()
    {
        List<String> recordTypeIdList = new List<String>();  
        
        recordTypeIdList.add(String.valueOf(Schema.SObjectType.Proposal__c.getRecordTypeInfosByDeveloperName().get('Adjust_Opportunity_Budget').getRecordTypeId()));
    
        System.debug(' ### recordTypeIdList ### ' +recordTypeIdList);      

        String query = 'SELECT CALENDAR_MONTH(Broadcast_Month_Date__c) bMonth';
        if(isCompanyModel){  query += ' ,Sum(Broadcast_Amount__c) rAmt';
        }else query += ' ,Sum(Net_Amount__c) rAmt, Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c salesProbability';  

        if(isNationalUser) query +=  ' ,Proposal_Zone__r.Proposal__r.Opportunity__r.DMA__c dma';

        query += ' ,Schedule_Type__c prod, Advertiser__r.Name Adv, Advertiser__c advId,  Proposal_Zone__r.Proposal__r.Opportunity__c oppId, Proposal_Zone__r.Proposal__r.Opportunity__r.Name oppName FROM Proposal_Zone_Monthly_Value__c WHERE Year__c =: chosenFiscalYear AND Proposal_Zone__r.Proposal__r.RecordTypeId IN :recordTypeIdList AND Proposal_Zone__r.Proposal__r.Active__c = true AND Proposal_Zone__r.Proposal__r.Opportunity__r.Owner_For_Forecasting_Tool__c =: chosenUser AND (Proposal_Zone__r.Proposal__r.Opportunity__r.isClosed= false OR Proposal_Zone__r.Proposal__r.Opportunity__r.isWon = true) AND Broadcast_Month_Date__c != null';
        
        if(!isCompanyModel)
        {
            query += ' AND Proposal_Zone__r.Proposal__r.Opportunity__r.Sales_Probability__c IN : selectedSalesProb';
        }    
        if(isNationalUser)
        {          
            if(String.isNotBlank(availableBudgetDMAvalues) && 'All'.equalsIgnoreCase(chosenDMAoption))
            {
                query += ' AND Proposal_Zone__r.Proposal__r.Opportunity__r.DMA__c IN ' + availableBudgetDMAvalues;
            }
            else 
            {  
                query += ' AND Proposal_Zone__r.Proposal__r.Opportunity__r.DMA__c =: chosenDMAoption';
            }
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
        if(forecastAdjResults.size() > 0)
        {
            hasPolitical = isProdTypePolitical ;
            try
            {                
                calculateTotalsSection(forecastAdjResults, ROWTYPE_FORECAST_ADJUSTMENT);
            }
            catch(Exception ex)
            {
                System.debug(' ### Exception ::: ' + ex.getMessage()  + ' ### Line Number :::: ' +ex.getLineNumber());                
            }
        }
    }

    public void fetchBookedPendingProjectedForecastAdjData ()
    {
        Map<String,List<Decimal>> bookedTotalsMap = new Map<String,List<Decimal>>();
        Map<String,List<Decimal>> pendingTotalsMap = new Map<String,List<Decimal>>();
        Map<String,List<Decimal>> projectedTotalsMap = new Map<String,List<Decimal>>(); 
        Map<String,List<Decimal>> forecastAdjTotalsMap = new Map<String,List<Decimal>>();
      
        bookedTotalsMap = fetchDataByRowType (ROWTYPE_BOOKED);
        pendingTotalsMap = fetchDataByRowType (ROWTYPE_PENDING);
        projectedTotalsMap = fetchDataByRowType (ROWTYPE_PROJECTED);
        forecastAdjTotalsMap = fetchDataByRowType (ROWTYPE_FORECAST_ADJUSTMENT);

        List<Decimal> bookedPendingProjForecastAdjMap = calculateProductwiseTotals (bookedTotalsMap, pendingTotalsMap, projectedTotalsMap, forecastAdjTotalsMap);
        
        System.debug('bookedPendingProjForecastAdjMap>>>>'+bookedPendingProjForecastAdjMap);
       
        if(!totalsMap.containsKey(ROWTYPE_BOOKED_PENDING_PROJECTED_FORECAST_ADJUSTMENT))
        {
            totalsMap.put(ROWTYPE_BOOKED_PENDING_PROJECTED_FORECAST_ADJUSTMENT,bookedPendingProjForecastAdjMap);
        }          
    }
    // END : SRSF-4489     
}