/*
###########################################################################
# File..................: ProposalOpportunityBudgetController.cls
# Version...............: 1
# Created by............: Sanchit Singhal
# Created Date..........: 27-March-2017
# Last Modified by......: Puneet Khosla
# Last Modified Date....: 10-August-18
# Description...........: This class contains controller methods for ProposalOpportunityBudgetController visualforce page
# TAO Ref#..............: NA
# Change Log:               
# 1. Puneet Khosla - Changes for SRSF-936
# 2. Puneet Khosla - Changes for SRSF-1041
# 3. Bhuvanasankar - Changes for SRSF-1127
# 4. Puneet Khosla - Changes for SRSF-1242
# 5. Sridhar Aluru - Changes for SRSF-3116
############################################################################
*/
public without sharing class LightningProposalOpportunityBudgetCntrl {
    
    // Properties    
    public ID currentRecordId {get; set;}
    public Date startDate {get; set;}
    public Date endDate {get; set;}
    public Boolean isValidated {get; set;}
    public Boolean showConfirm {get; set;}
    public Boolean cacualteZoneMonthly {get; set;}
    public Decimal rowAmount {get; set;}
    public Decimal colAmount {get; set;}
    public String pageMsg {get; set;}
    public String CurrentYear {get; set;}
    public String SfInstance {get; set;}
    public String startDateString {get; set;}
    public String endDateString {get; set;}
    public String confirmMessage {get; set;}    
    public String scheduleString {get; set;}
    public String monthString {get; set;}
    public Account opptyAccount {get; set;}
    public Opportunity oppty {get; set;}
    public Proposal__c proposal {get; set;}
    public List<String> monthsToDisplay {get; set;}
    public List<String> monthsToDisplayWithYearList {get; set;}
    public List<String> scheduleTypeList {get; set;}
    public List<proposalZoneMonthlyWrapper> wrapList {get; set;}
    public Map<String, Decimal> currentDateMap {get; set;}
    public Map<String, Decimal> rowTotalMap {get; set;}
    public Map<String, Decimal> columnTotalMap {get; set;}
    public Map<String, Decimal> columnNetTotalMap {get; set;} // SRSF-2239
    public Map<String, Proposal_Zone_Monthly_Value__c> PZMVmap {get; set;}
    public Map<String, Decimal> propZoneMVmap {get; set;} // 19-Feb-2021
    public Map<String, Decimal> monthAmountMap {get; set;}
    public Map<String, Decimal> netAmountMap {get; set;}  // SRSF-2239    
    public Map<String, List<proposalZoneMonthlyWrapper>> wrapMap {get; set;}
    /*
    Changes in messages structure as described by Greg.
    */
    public Map<String,Map<String,String>> messageList {get; set;}
    public String optionSelected {get; set;}
    public Map<String,OppBudgetMessages__c> custSettMap = new Map<String,OppBudgetMessages__c>(); 
    public String dateLogic{get; set;}
    public String errorMsg{get; set;}
    public Boolean isFlatBill {get; set;}
    //Variables
    public Integer startMonth ;
    public Integer monthDif;
    public Integer endMonth ;
    public Integer startYear ;
    public Integer endYear ;
    public Integer monthDifference ;
    public Boolean isMergeProductLines = false;
    public Date selectedStartDate{set;get;} 
    public Date selectedEndDate ;
    public List<String> calendarMonths ;
    public List<String> sortOrder ;
    public List<String> productsToMerge = new List<String>();
    public Set<String> monthsToDisplayWithYearSet ;
    public Set<Proposal_Zone_Monthly_Value__c> availableMonthlyZoneValues ;
    public Map<String, String> custSettingMap ;
    public Map<String, String> sysCodeValueNameMapping;
    public Map<String, Proposal_Zone__c> proposalZoneMap ;

    // Constants
    public static final String PRODUCTLINE_RSN = 'RSN';
    public static final String PRODUCTLINE_SRNEWS = 'SRNews';
    public static final String PRODUCTLINE_LINEAR = 'Linear';
    public static final String PRODUCTLINE_LINEAR_NEWS_SPORTS = 'Linear/News/Sports';
    public static final String JANUARY_MONTH = 'January';

    // Constructor
    public LightningProposalOpportunityBudgetCntrl(Apexpages.standardcontroller cntrl) {

        Id opptyId = Apexpages.currentpage().getparameters().get('oppId');
        currentRecordId = Apexpages.currentpage().getparameters().get('id'); // Proposal ID
        oppty = [SELECT Id, Name, Accountid, Account.Name, Agency_Account__c, Rep_Firm__c, Agency_Account__r.Discount_Percentage__c, Rep_Firm__r.Discount_Percentage__c, 
        Number_Of_Manual_Proposal_Records__c, CloseDate, Flight_Start_Date__c, Flight_End_Date__c, Owner.Profile.Name,Owner.ProfileId, OwnerId, Owner.Name FROM Opportunity WHERE Id=:opptyId];
       
        User userDetails = [SELECT Id, Name, Profile.Name, Budget_Product_Lines__c FROM User WHERE Id =: oppty.OwnerId];    

        Budget_Product_Lines_Mapping__c defaultCS = Budget_Product_Lines_Mapping__c.getOrgDefaults();
        String defaultProductLines = defaultCS.Product_Lines__c;

        Budget_Product_Lines_Mapping__c profileBPL = Budget_Product_Lines_Mapping__c.getInstance(oppty.Owner.ProfileId);
        String profileProductLines = profileBPL.Product_Lines__c;

        startDateString = optionSelected = '';
        endDateString = '';
        confirmMessage = '';
        scheduleString = errorMsg = '';
        showConfirm = false;
        monthDif = 0;
        monthDifference = 0;
        cacualteZoneMonthly = false;
        isFlatBill = false;
        calendarMonths = new List<String>();
        scheduleTypeList = new List<String>();
        availableMonthlyZoneValues = new Set<Proposal_Zone_Monthly_Value__c>();        
        messageList = new Map<String,Map<String,String>>();
        custSettMap = OppBudgetMessages__c.getAll();
        rowTotalMap = new Map<String, Decimal>();
        PZMVmap = new Map<String, Proposal_Zone_Monthly_Value__c>();
        propZoneMVmap = new Map<String, Decimal>(); 
        proposalZoneMap = new Map<String, Proposal_Zone__c>();         

        if(String.isNotBlank(profileProductLines)) {
            scheduleTypeList.addAll(profileProductLines.split(','));
        }
        else if( String.isNotBlank(defaultProductLines)) {
            scheduleTypeList.addAll(defaultProductLines.split(','));
        }

        System.debug(' userDetails.Budget_Product_Lines__c ::: ' +userDetails.Budget_Product_Lines__c);
        if(userDetails.Budget_Product_Lines__c != null) {
            scheduleTypeList.addAll(new List<String>(userDetails.Budget_Product_Lines__c.split(';')));
        }
        
        Set<String> scheduleTypeSet = new Set<String>(scheduleTypeList);
        scheduleTypeList.clear();
        scheduleTypeList = new List<String>(scheduleTypeSet);
        System.debug(' ### scheduleTypeList ::: ' +scheduleTypeList);
        String calendarString = 'January,February,March,April,May,June,July,August,September,October,November,December';        
        calendarMonths = calendarString.split(',');
        //Extract current year
        if(String.valueOf(Date.today().month()).equalsIgnoreCase(JANUARY_MONTH))              
            CurrentYear = String.valueOf(Date.today().year()); 
        else
            CurrentYear = String.valueOf(Date.today().year()) + ' - ' + String.valueOf(Date.today().year()+1);
            
        isValidated = true;
        
        SfInstance = URL.getSalesforceBaseUrl().toExternalForm();    

        proposal = new Proposal__c();
        
        List<Proposal__c> propList = [SELECT Id,Name,Start_Date__c,End_Date__c,Opportunity__c FROM Proposal__c WHERE Opportunity__c =: oppty.Id AND RecordType.DeveloperName = 'Opportunity_Budget' LIMIT 1];

        if(propList.size() > 0)
        {
            proposal = propList[0];
            if(String.isEmpty(currentRecordId))
                currentRecordId = propList[0].Id;
            if(proposal.Start_Date__c == null){
                proposal.Start_Date__c = oppty.Flight_Start_Date__c == null?System.today():oppty.Flight_Start_Date__c;
            }

            if(proposal.End_Date__c == null){
                proposal.End_Date__c = oppty.Flight_End_Date__c == null?oppty.CloseDate :oppty.Flight_End_Date__c; 
            }
            selectedStartDate = startDate = proposal.Start_Date__c == null?System.today():proposal.Start_Date__c;
            selectedEndDate = endDate = proposal.End_Date__c== null?System.today():proposal.End_Date__c;
            startDateString = String.valueOf(startDate);
            endDateString = String.valueOf(endDate);
            System.debug('selectedStartDate1 ' + selectedStartDate + startDate);
            System.debug('selectedEndDate1 ' + selectedEndDate + endDate);
        }
        // To create new proposal
        else {
            try {
                String accName = oppty.Account.Name.length() > 40 ?oppty.Account.Name.subString(0,40):oppty.Account.Name;                
                Id recordTypeId = UtilityClass.getRecordTypeID(new Proposal__c(), 'Opportunity Budget');
                
                proposal.Name='Opportunity Budget ' + accName;
                proposal.RecordTypeId = recordTypeId;
                proposal.Opportunity__c = oppty.Id;
                proposal.Start_Date__c = startDate = oppty.Flight_Start_Date__c == null?System.today():oppty.Flight_Start_Date__c;
                proposal.End_Date__c = endDate = oppty.Flight_End_Date__c == null?System.today():oppty.Flight_End_Date__c;
                startDateString = String.valueOf(proposal.Start_Date__c);
                endDateString = String.valueOf(proposal.End_Date__c);
                //insert proposal;
            }
            catch(Exception ex) {
                System.debug('@@@ Exception ::: ' +ex.getMessage() + ' ::: line number ::: ' +ex.getLineNumber());
            }
        }
        try {
            customSettingValues();
            fetchProposalZones();
            calculateDateDifference();
        }
        catch(Exception ex) {
            System.debug('@@@ Exception ::: ' +ex.getMessage() + ' ::: line number ::: ' +ex.getLineNumber());
        }
    }

    // Validate the Opportunity Budget for the Opportunity.
    public pageReference validateProposals (){

        //Redirect to the Opp Budget if it already exists.
        if(oppty.Number_Of_Manual_Proposal_Records__c != 0 && proposal!= null && String.isEmpty(currentRecordId)){
            pageMsg = 'An Opportunity Budget already exists for this Opportunity.';
            isValidated = false;  
            return new PageReference('/apex/ProposalLightningEditSwitcher?id='+proposal.ID + '&oppId='+oppty.Id);
        }       
        return null;
    }
    
    
   /*Method to reset date and Grid*/
    public void resetGrid()
    {
        errorMsg = '';
        startDateString = String.valueOf(proposal.Start_Date__c);
        endDateString = String.valueOf(proposal.End_Date__c);
        
        startDate = proposal.Start_Date__c;
        endDate = proposal.End_Date__c;
        try {
            fetchProposalZones();
            calculateDateDifference();
        }
        catch(Exception ex) {
            System.debug('@@@ Exception ::: ' +ex.getMessage() + ' ::: line number ::: ' +ex.getLineNumber());
        }
    }
    /**  
    * @author               : Bhuvanasankar Das (OSI)
    * @date                 : 21-Dec-2017
    * @description          : This function is used to convert String into Date(YYYY-MM-DD)
    * @param inputDate      : String
    * @return               : Date
    */
    public Date formatDate(String inputDate) {
        if (inputDate.contains('/')) {
            String[] dateStr = inputDate.split('/');
            return Date.valueOf(dateStr[2]+'-'+dateStr[0]+'-'+dateStr[1]);
        }
        else {
            return Date.valueOf(inputDate);
        }
    }

    /**  
    * @author               : Bhuvanasankar Das (OSI)
    * @date                 : 21-Dec-2017
    * @description          : This function available proposal zone monthly values
    * @param                : No Params
    * @return               : void
    */
    public void calculateDateDifference() {

        if(String.isNotBlank(startDateString)) {
            selectedStartDate = formatDate(startDateString);
        }
        if(String.isNotBlank(endDateString)) {
            selectedEndDate = formatDate(endDateString);
        }
        System.debug('selectedStartDate ::: ' + selectedStartDate + ' startDate ::: '+ startDate);
        System.debug('selectedEndDate ::: ' + selectedEndDate + ' endDate ::: ' + endDate);

        Map<String,String> mapVal = new Map<String,String>();

        
        if(selectedStartDate != null && selectedEndDate != null){
          
          if(selectedStartDate > selectedEndDate) {         
            errorMsg = 'Start date should be less than end date.';
            return;
          }
          for(OppBudgetMessages__c obj :custSettMap.values())
          {
              mapVal.put(obj.OptionDetails__c,obj.MessageDetails__c);
          }
            monthDif = selectedStartDate.monthsBetween(selectedEndDate);
        }
       
        if(selectedStartDate != startDate && selectedEndDate != endDate && proposal.Id != null) 
        {
            errorMsg = Label.Opportunity_Budget_Error;
            System.debug('errorMsg' + errorMsg);
            showConfirm = false;
            return;
        }
        if(selectedStartDate != startDate && null != selectedStartDate ) {
            
            if(selectedStartDate > startDate) {
                System.debug('##### selectedStartDate > startDate');
                dateLogic = 'StrtAhead';
                Map<String,String> strMap = new Map<String,String>();
                strMap.put('ChangeEndDate',mapVal.get('ChangeEndDate'));
                strMap.put('RemoveB',mapVal.get('RemoveB'));
                messageList.put(dateLogic,strMap);
                showConfirm = true;
            }
            else if(selectedStartDate < startDate)
            {
                System.debug('##### selectedStartDate < startDate');
                dateLogic = 'StrtPulled';
                Map<String,String> strMap = new Map<String,String>();
                strMap.put('ReduceEndDate',mapVal.get('ReduceEndDate'));
                strMap.put('AddB',mapVal.get('AddB'));
                messageList.put(dateLogic,strMap);
                showConfirm = true;
            }
        }
        else if(selectedEndDate != endDate && null != selectedEndDate) {
            if(selectedEndDate > endDate) {
                System.debug('##### selectedEndDate > endDate');
                dateLogic = 'EndPulled';
                Map<String,String> strMap = new Map<String,String>();
                strMap.put('ChangeStartDate',mapVal.get('ChangeStartDate'));
                strMap.put('AddE',mapVal.get('AddE'));
                messageList.put(dateLogic,strMap);
                showConfirm = true;
            }
            if(selectedEndDate < endDate) {
                System.debug('##### selectedEndDate < endDate');
                showConfirm = true;
                Map<String,String> strMap = new Map<String,String>();
                strMap.put('ChangeStartDate',mapVal.get('ReduceStartDate'));
                strMap.put('RemoveE', mapVal.get('RemoveE'));
                messageList.put(dateLogic,strMap);
            }
        }
        else
            showConfirm = false;

        System.debug('startDateString>>>>'+startDateString+ '<<<<endDateString>>>>'+endDateString);        
        System.debug('### showConfirm' + showConfirm);      
        if(!showConfirm){
            populateMonthAmountMap();
        }
    }

    public void populateMonthAmountMap() {
        monthAmountMap = new Map<String, Decimal>();
        netAmountMap = new Map<String, Decimal>(); // SRSF-2239
        sortOrder = new List<String>();
        monthsToDisplay = new List<String>();
        monthsToDisplayWithYearSet = new Set<String>();
        monthsToDisplayWithYearList = new List<String>();
        // Dates to be adjusted based on the option selected
        System.debug('### selectedStartDate ' + selectedStartDate);
        System.debug('### selectedEndDate ' + selectedEndDate);
        System.debug('### startDate ' + startDate);
        System.debug('### endDate ' + endDate);
        if(selectedStartDate != null && selectedEndDate != null) {
            if(selectedStartDate != startDate)
            {
                startMonth = getBroadcast(selectedStartDate)?selectedStartDate.month()+1:selectedStartDate.month();
                System.debug('### startMonth ' + startMonth + '<<<<startDate>>>> ' + getBroadcast(selectedStartDate));                
                if(selectedStartDate > startDate && optionSelected == 'ChangeEndDate') { 
                    selectedEndDate = endDate = selectedEndDate.addMonths(startDate.monthsBetween(selectedStartDate));
                }
                else if(selectedStartDate < startDate && optionSelected == 'ReduceEndDate')
                    selectedEndDate = endDate = selectedEndDate.addMonths(startDate.monthsBetween(selectedStartDate));
                System.debug('$$$ selectedEndDate ' + selectedEndDate);    
                endDateString =  String.valueof(selectedEndDate.format()); 
                System.debug('### endDateString ' + endDateString);   
            }
            else
                startMonth = selectedStartDate.month();
                System.debug('$$$ startMonth ' + startMonth);
            if( selectedEndDate != endDate)
            { 
                endMonth = getBroadcast(selectedEndDate)?selectedEndDate.month()+1:selectedEndDate.month();
                System.debug('### endMonth ' + endMonth);
                if(selectedEndDate > endDate && optionSelected == 'ChangeStartDate')
                    selectedStartDate = startDate = selectedStartDate.addMonths(endDate.monthsBetween(selectedEndDate));
                else if(selectedEndDate < endDate && optionSelected == 'ReduceStartDate')
                    selectedStartDate = startDate = selectedStartDate.addMonths(endDate.monthsBetween(selectedEndDate));               
                startDateString =  String.valueof(selectedStartDate.format());
                System.debug('$$$ startDateString' + startDateString);
            }
            else
                endMonth = selectedEndDate.month();
                System.debug('$$$ endMonth ' + endMonth);
                startMonth = getBroadcast(selectedStartDate)?selectedStartDate.month()+1:selectedStartDate.month();
                endMonth = getBroadcast(selectedEndDate)?selectedEndDate.month()+1:selectedEndDate.month();
                startYear = selectedStartDate.year(); 
        }
        else
        {
            startDate = startDate == null?Date.today():startDate;
            endDate = endDate == null?Date.today()+1:endDate;
            startMonth = getBroadcast(startDate)?startDate.month()+1:startDate.month();
            endMonth = getBroadcast(endDate)?endDate.month()+1:endDate.month();           
            System.debug('--startDate-- ' + startDate + '--endDate-- ' + endDate);
            System.debug('--startMonth-- ' + startMonth + '--endMonth-- ' + endMonth);
        }
       
        startYear = selectedStartDate.year() == null?Date.today().year():selectedStartDate.year();
        endYear = selectedEndDate.year() == null?Date.today().year():selectedEndDate.year();
        System.debug('--startYear-- ' + startYear + '--endYear-- ' + endYear);   
        
        if(startMonth >= 13) 
        {
            startMonth = 1;
            startYear += 1;
        }
        if(endMonth >=13)
        {
            endMonth = 1;
            endYear +=1;
        }
        
        monthDifference = ((endYear - startYear) * 12) - (startMonth - endMonth);         
        System.debug('## startYear ' + startYear + '## endYear ' + endYear);        
        System.debug('## startMonth ' + startMonth + '## endMonth ' + endMonth); 
        System.debug('monthDifference' + monthDifference);

        //if(monthDifference<0 || monthDifference >=12) // Commented for SRSF-2504
        if(monthDifference<0 || monthDifference >=13) // Added for SRSF-2504
        {
            errorMsg = Label.Opportunity_Budget_Error;
            System.debug('errorMsg:' + errorMsg);
            return;
        }

        if(monthDifference != null) {
            for(Integer i=0; i<=monthDifference; i++) {
                System.debug('### startMonth : ' + startMonth);
                if(startMonth <= 12) {
                    monthsToDisplay.add(calendarMonths[startMonth-1]);
                    String key = String.valueOf(startMonth) + '_' + String.valueOf(startYear);
                    for (String str : scheduleTypeList) {
                        monthAmountMap.put(key+ '_' +str,0.00);
                        netAmountMap.put(key+ '_' +str,0.00); // SRSF-2239
                        sortOrder.add(key+ '_' +str);
                    }                  
                }
                startMonth++;
                if(startMonth == 13) {
                    startMonth = 1;
                    startYear += 1;
                }
            }
            System.debug('### monthsToDisplay ::: ' +monthsToDisplay);
        }
        fetchPZMValues();
    }
    /*
    This method checks if the date passed belongs to the broadcast calendar : 
    (A week in the calendar starts on a Monday and ends on a Sunday.
    If Sunday is not the last day of the month then the whole week is taken part of the next month)
    */
    public boolean getBroadcast(Date dt)
    {
        if(dt == null)
            dt = Date.today();
     
        Integer dtDay = dt.day();
     
        if(dtDay < 21)
            return false;
        else
        {   
            Integer numberOfDaysInMonth = Date.daysInMonth(dt.year(), dt.month());
            System.debug('numberOfDaysInMonth>>>>'+numberOfDaysInMonth);
            Date lastDate = Date.newInstance(dt.year(), dt.month(), numberOfDaysInMonth);
            System.debug('lastDate>>>>'+lastDate);
            DateTime lastDay = DateTime.newInstance(lastDate, Time.newInstance(12, 0, 0, 0));
            System.debug('lastDay>>>>'+lastDay);
            String lastDayWeekName = lastDay.format('EEE');
            Date lastSundayDate = lastDate;
            if('Mon'.equalsIgnoreCase(lastDayWeekName))
                lastSundayDate = lastDate.addDays(-1);
            else if('Tue'.equalsIgnoreCase(lastDayWeekName))
                lastSundayDate = lastDate.addDays(-2);
            else if('Wed'.equalsIgnoreCase(lastDayWeekName))
                lastSundayDate = lastDate.addDays(-3);
            else if('Thu'.equalsIgnoreCase(lastDayWeekName))
                lastSundayDate = lastDate.addDays(-4);
            else if('Fri'.equalsIgnoreCase(lastDayWeekName))
                lastSundayDate = lastDate.addDays(-5);
            else if('Sat'.equalsIgnoreCase(lastDayWeekName))
                lastSundayDate = lastDate.addDays(-6);
            System.debug('dt>>>>'+dt);
            System.debug('lastSundayDate>>>>'+lastSundayDate);

            if(dt > lastSundayDate)
                return true;
            else
                return false;
        }
    }


    /**  
    * @author               : Bhuvanasankar Das (OSI)
    * @date                 : 21-Dec-2017
    * @description          : This function is used to fetch Proposal Zone Monthly Values
    * @param                : 
    * @return               : 
    */
    public void fetchPZMValues(){
        System.debug('inside fetchPZMValues>>>>>>');

        columnTotalMap = new Map<String, Decimal>();        
        columnNetTotalMap = new Map<String, Decimal>(); // SRSF-2239
        List<Proposal_Zone_Monthly_Value__c> proposalZMList = [SELECT Id,Gross_Amount__c, Net_Amount__c, Broadcast_Month__c,Year__c,Proposal_Zone__r.Sys_Code__c,Broadcast_Month_Date__c,Schedule_Type__c  FROM Proposal_Zone_Monthly_Value__c WHERE Proposal_Key_Index__c =:currentRecordId ORDER BY Year__c,Broadcast_Month__c];
        
        for(Proposal_Zone_Monthly_Value__c prop : proposalZMList) {
            String halfMapKey = '';
            System.debug('optionSelected ' + optionSelected); 
            if(optionSelected == 'ChangeEndDate')
            {
                prop.Broadcast_Month_Date__c = prop.Broadcast_Month_Date__c.addMonths(startDate.monthsBetween(selectedStartDate)); 
                //halfMapKey = String.valueOf((prop.Broadcast_Month_Date__c).month() + startDate.monthsBetween(selectedStartDate)) + '_'  + prop.Year__c;
                System.debug('prop.Broadcast_Month_Date__c>>>>>>>'+prop.Broadcast_Month_Date__c);
            }
            else if (optionSelected == 'ChangeStartDate')
            {
                System.debug(endDate.monthsBetween(selectedEndDate)+ '_' + prop.Broadcast_Month_Date__c);
                prop.Broadcast_Month_Date__c = prop.Broadcast_Month_Date__c.addMonths(endDate.monthsBetween(selectedEndDate));
                System.debug(endDate.monthsBetween(selectedEndDate)+ ' ' + prop.Broadcast_Month_Date__c);
                //halfMapKey = String.valueOf((prop.Broadcast_Month_Date__c).month() + endDate.monthsBetween(selectedEndDate)) + '_'  + prop.Year__c;
                System.debug('prop.Broadcast_Month_Date__c#####'+prop.Broadcast_Month_Date__c);
            }

            halfMapKey = String.valueOf((prop.Broadcast_Month_Date__c).month()) + '_'  + String.valueOf(prop.Broadcast_Month_Date__c.year());
            System.debug('halfMapKey ' + halfMapKey);              
            String fullMapKey = halfMapKey + '_'  + prop.Schedule_Type__c;
            System.debug('fullMapKey:' + fullMapKey); 
            monthAmountMap.put(fullMapKey,Integer.valueOf(prop.Gross_Amount__c));
            netAmountMap.put(fullMapKey,Integer.valueOf(prop.Net_Amount__c)); // SRSF-2239
            availableMonthlyZoneValues.add(prop);
            PZMVmap.put(fullMapKey, prop);
        }

        wrapList = new List<proposalZoneMonthlyWrapper>();
        wrapMap = new Map<String, List<proposalZoneMonthlyWrapper>>();       
        System.debug('PZMVmap#####'+PZMVmap);
        System.debug('availableMonthlyZoneValues#####'+availableMonthlyZoneValues); 
        
        for(String s:sortOrder){
            System.debug('### sortOrder key ::: ' +s);
            System.debug('### monthAmountMap.get(s) key ::: ' +monthAmountMap.get(s));
            System.debug('### netAmountMap.get(s) key ::: ' +netAmountMap.get(s)); // SRSF-2239
            String[] splittedKey = s.split('_');
            System.debug('splittedKey>>>>'+splittedKey); // SRSF-2239
            //String halfKey = splittedKey[0] + '_' + splittedKey[1];
            // wrapList.add(new proposalZoneMonthlyWrapper(s,Integer.valueOf(monthAmountMap.get(s)),splittedKey[2])); //Commented by Sridhar 22-08-2020 // SRSF-2239
            wrapList.add(new proposalZoneMonthlyWrapper(s,Integer.valueOf(monthAmountMap.get(s)),Integer.valueOf(netAmountMap.get(s)), splittedKey[2])); // SRSF-2239
        }
        System.debug('wrapList#####'+wrapList);
        System.debug('wrapList JSON:'+JSON.serialize(wrapList));
        try{
            calculateEveryMonthTotal();
            displayValuesOnTable();
        }
        catch(Exception ex) {
            System.debug('@@@ Exception ::: ' +ex.getMessage() + ' ::: line number ::: ' +ex.getLineNumber());
        }
    }
   
    /**  
    * @author               : Bhuvanasankar Das (OSI)
    * @date                 : 21-Dec-2017
    * @description          : This function is used to calculate monthly total and schedule Type Total
    * @param                : no params
    * @return               : 
    */
    public void calculateEveryMonthTotal() {
        rowTotalMap = new Map<String, Decimal>();
        Integer finalTotalAmount = 0;
        Integer finalNetAmount = 0; // SRSF-2239
        System.debug('### wrapList ::: ' +wrapList);
        System.debug('### monthAmountMap ::: ' +monthAmountMap);
        
        for(proposalZoneMonthlyWrapper wrp : wrapList) {
            System.debug('### wrp.monthKey ::: ' +wrp.monthKey);
            Integer newValue = 0;
            Integer newNetValue = 0;  // SRSF-2239
            String[] splittedKey = (wrp.monthKey).split('_');
            String halfKey = splittedKey[0] + '_' + splittedKey[1];
            System.debug('halfKey>>>>>>'+halfKey);
            finalTotalAmount += Integer.valueOf(monthAmountMap.get(wrp.monthKey));
            finalNetAmount += Integer.valueOf(netAmountMap.get(wrp.monthKey)); // SRSF-2239 
            if(!monthsToDisplayWithYearSet.contains(halfKey)) {
                monthsToDisplayWithYearList.add(halfKey);
            }
            monthsToDisplayWithYearSet.add(halfKey);

            if(columnTotalMap.containsKey(halfKey)) {
                newValue = Integer.valueOf(columnTotalMap.get(halfKey)) + Integer.valueOf(monthAmountMap.get(wrp.monthKey));
            }
            else {
                newValue = Integer.valueOf(monthAmountMap.get(wrp.monthKey));
            }            

            // Start: SRSF-2239
            if(columnNetTotalMap.containsKey(halfKey)) {                                 
                newNetValue = Integer.valueOf(columnNetTotalMap.get(halfKey)) + Integer.valueOf(netAmountMap.get(wrp.monthKey));
            }
            else {
                newNetValue = Integer.valueOf(netAmountMap.get(wrp.monthKey));
            }
            System.debug('newNetValue>>>>'+newNetValue);
            // End: SRSF-2239
            
            columnTotalMap.put(halfKey, newValue); 
            columnNetTotalMap.put(halfKey, newNetValue); // SRSF-2239           
            Integer cellAmount = 0;           
            if(rowTotalMap.containsKey(wrp.scheduleType)) {
                cellAmount = Integer.valueOf(rowTotalMap.get(wrp.scheduleType)) + Integer.valueOf(wrp.monthAmount);
            }
            else {
                cellAmount = Integer.valueOf(wrp.monthAmount);
            }            
            rowTotalMap.put(wrp.scheduleType, cellAmount);             
        }
        
        if(!monthsToDisplayWithYearSet.contains('Final_Total')) {
            monthsToDisplayWithYearList.add('Final_Total');
            monthsToDisplayWithYearSet.add('Final_Total');
        }

        columnTotalMap.put('Final_Total', finalTotalAmount);  
        columnNetTotalMap.put('Final_Total', finalNetAmount);       
    }

    /**  
    * @author               : Bhuvanasankar Das (OSI)
    * @date                 : 21-Dec-2017
    * @description          : This function is used to display values on the table
    * @param                : no params
    * @return               : 
    */
    public void displayValuesOnTable() {
        System.debug('wrapList:' + JSON.serialize(wrapList));
        // To display values on the table 
        for(proposalZoneMonthlyWrapper wrp : wrapList) {
            if(wrapMap.containsKey(wrp.scheduleType)) {
                (wrapMap.get(wrp.scheduleType)).add(wrp);
            }
            else {
                wrapMap.put(wrp.scheduleType, new List<proposalZoneMonthlyWrapper>{wrp});
            }
        }
        try {
            //List<String> productsToMerge = new List<String>{'Linear','RSN','SRNews'};            
            if(isMergeProductLines) {
                mergeProductLines(productsToMerge, PRODUCTLINE_LINEAR_NEWS_SPORTS);
            }
        }
        catch(Exception ex) {
            System.debug('@@@ Exception ::: ' +ex.getMessage() + ' ::: line number ::: ' +ex.getLineNumber());
        }
    }

    /**  
    * @author               : Bhuvanasankar Das (OSI)
    * @date                 : 11-July-2018
    * @description          : This function is used to merge Product lines (SRSF-1127)
    * @param                : no params
    * @return               : 
    */    
    public void mergeProductLines(List<String> productsToBeMerge, String mergeProduct) {
        System.debug(' @@@ productsToBeMerge ::: ' +productsToBeMerge);
        System.debug(' @@@ mergeProduct ::: ' +mergeProduct);
        System.debug('wrapMap:' + JSON.serialize(wrapMap));
        List<proposalZoneMonthlyWrapper> mergeProductWrapList = new List<proposalZoneMonthlyWrapper>();
        if(wrapMap.containsKey(mergeProduct)) {
            mergeProductWrapList = wrapMap.get(mergeProduct);
        }

        if(productsToBeMerge.size() > 0) {
            Decimal totalRowAmount = 0.00;
            for(String str : productsToBeMerge) {
                if(wrapMap.containsKey(str)) {
                    List<proposalZoneMonthlyWrapper> tempWrapList = wrapMap.get(str);                    
                    for(Integer i=0; i<tempWrapList.size(); i++) {
                        mergeProductWrapList[i].monthAmount += tempWrapList[i].monthAmount;
                        totalRowAmount += tempWrapList[i].monthAmount;
                        wrapList.remove(wrapList.indexOf(tempWrapList[i]));
                    }
                    scheduleTypeList.remove(scheduleTypeList.indexOf(str));
                    wrapMap.remove(str);
                }
            }
            System.debug(' ### totalRowAmount ::: ' +totalRowAmount);
            rowTotalMap.put(mergeProduct, totalRowAmount);
            wrapMap.put(mergeProduct, mergeProductWrapList);
        }
    }

    public void fetchProposalZones() {
        List<String> existingScheduleTypeList = new List<String>();
        List<Proposal_Zone__c> propZoneList=[SELECT Id,Sys_Code__c FROM Proposal_Zone__c WHERE Proposal__c =: proposal.Id]; //AND Sys_Code__c=:proposalType
        for(Proposal_Zone__c pz : propZoneList) {
            if(String.isNotBlank(pz.Sys_Code__c)) {
                proposalZoneMap.put(pz.Sys_Code__c, pz);
                //sysCodeValueNameMapping
                if(sysCodeValueNameMapping.containsKey(pz.Sys_Code__c)) {
                    existingScheduleTypeList.add(sysCodeValueNameMapping.get(pz.Sys_Code__c));
                }
            }
        }
        System.debug(' ### existingScheduleTypeList ::: ' +existingScheduleTypeList);
        //START : SRSF-5238 change
        if(existingScheduleTypeList.contains(PRODUCTLINE_LINEAR)){
            Integer index = existingScheduleTypeList.indexOf(PRODUCTLINE_LINEAR);
            existingScheduleTypeList.remove(index);
            if(!existingScheduleTypeList.contains(PRODUCTLINE_LINEAR_NEWS_SPORTS)){
                existingScheduleTypeList.add(index, PRODUCTLINE_LINEAR_NEWS_SPORTS);
            }
        }
        System.debug(' ### existingScheduleTypeList modified::: ' +existingScheduleTypeList);
        //END : SRSF-5238 change
        scheduleTypeList.addAll(existingScheduleTypeList);
        Set<String> scheduleTypeSet = new Set<String>(scheduleTypeList);        

        if(scheduleTypeSet.contains(PRODUCTLINE_LINEAR)) {
            isMergeProductLines = true;
            productsToMerge.add(PRODUCTLINE_LINEAR);
            scheduleTypeSet.add(PRODUCTLINE_LINEAR_NEWS_SPORTS);            
        }
        if(scheduleTypeSet.contains(PRODUCTLINE_RSN)) {
            isMergeProductLines = true;
            productsToMerge.add(PRODUCTLINE_RSN);
            scheduleTypeSet.add(PRODUCTLINE_LINEAR_NEWS_SPORTS);            
        }
        if(scheduleTypeSet.contains(PRODUCTLINE_SRNEWS)) {
            isMergeProductLines = true;
            productsToMerge.add(PRODUCTLINE_SRNEWS);
            scheduleTypeSet.add(PRODUCTLINE_LINEAR_NEWS_SPORTS);            
        }
        scheduleTypeList.clear();
        scheduleTypeList = new List<String>(scheduleTypeSet);
        System.debug(' $$$ scheduleTypeList ::: ' +scheduleTypeList);
    }


    // Method used to count Number of Sunday's between Dates : SRSF-2505
    public Integer getTotalSundayInMonth(Date startDt, Date endDt){
        Integer numberDays = startDt.daysBetween(endDt);
        System.debug('numberDays>>'+numberDays);
        Integer numberOfWeeks = 0;        

        for(Integer i=0; i<=numberDays; i++){
            Date dt = startDt + i;  
            DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day()); 
            String todayDay = currDate.format('EEEE');
           
            if(todayDay =='Sunday') { 
                numberOfWeeks = numberOfWeeks + 1;  
            }
        }       
        System.debug('numberOfWeeks---->'+numberOfWeeks); // number of sundays 
       return numberOfWeeks;
    }

    public void splitRowTotal() {
        System.debug('isFlatBill--->>>>>> ' + isFlatBill); 
        System.debug('scheduleString--->>>>>> ' + scheduleString);
        System.debug('inside rowTotalMap>>>>>>>>>'+rowTotalMap);
        if(!isFlatBill && scheduleString.equalsignorecase('Digital')){
            splitDigitalRowTotal();
        }
        else {
            splitOtherRowTotal();
        }
    }

    /**  
    * @author               : Bhuvanasankar Das (OSI)
    * @date                 : 21-Dec-2017
    * @description          : This function is used to split the amount based on schedule type
    * @param                : no params
    * @return               : 
    */
    /* SRSF-2505: Commented existing method to add Weekwise Amount calculation 
     SRSF-4212 : Uncommented to spread dollars evenly across months for Digital product  */
    public void splitDigitalRowTotal() {
        System.debug('inside splitRowTotal>>>>>>>>>'+scheduleString);
        System.debug('inside wrapMap>>>>>>>>>'+wrapMap);        
        try {
            List<proposalZoneMonthlyWrapper> pzmWrpList = wrapMap.get(scheduleString);
            rowAmount = rowTotalMap.get(scheduleString);
            System.debug('rowAmount>>>>>>>>>'+rowAmount);
            if(rowAmount != null && pzmWrpList != null) {
                Decimal eachRowCellAmt = (rowAmount/pzmWrpList.size()).setScale(2);
                for(proposalZoneMonthlyWrapper pzm : pzmWrpList) {
                    pzm.monthAmount = Integer.valueOf(eachRowCellAmt);
                    System.debug('4>>>>>'+Integer.valueOf(eachRowCellAmt));
                }
                //calculateEveryMonthTotal();
                changeInCellAmount();
            }
        }
        catch(Exception ex) {
            System.debug(' ### Exception ::: ' +ex.getMessage() + ' ::: line number ::: ' +ex.getLineNumber());
        }   
    }
    // Added below method as part of SRSF-2505 and commented above
    public void splitOtherRowTotal() {
        try {
            System.debug('optionSelected - 3 >>>>>> ' + optionSelected); 
            System.debug('selectedStartDate >>>>>> ' + selectedStartDate); 
            System.debug('selectedEndDate >>>>>> ' + selectedEndDate);          
            Integer numberOfDays = selectedStartDate.daysBetween(selectedEndDate);              
            Integer noOfWeeks = getTotalSundayInMonth (selectedStartDate,selectedEndDate); 
            
            List<proposalZoneMonthlyWrapper> pzmWrpList = wrapMap.get(scheduleString);
            System.debug('pzmWrpList>>>>>>'+pzmWrpList);            

            DateTime currDate = DateTime.newInstance(selectedEndDate.year(), selectedEndDate.month(), selectedEndDate.day()); 
            String todayDay = currDate.format('EEEE');
           
            // SRSF-3116 : Added below if loop : 14-06-2021
            if(getBroadcast(selectedEndDate) || todayDay != 'Sunday') {
                System.debug('inside getBroadcast check>>>>>');
                noOfWeeks= noOfWeeks+1;
            }

            System.debug ('noOfWeeks - 3 >>>>>>>>>>'+noOfWeeks); 
            rowAmount = rowTotalMap.get(scheduleString);//SRSF-4212
            if(rowAmount != null && pzmWrpList != null) {
                Decimal weeklyAmt = (rowAmount/noOfWeeks).setScale(2);
                System.debug('weeklyAmt>>>>>'+weeklyAmt);
             
                for(proposalZoneMonthlyWrapper pzm : pzmWrpList) {
                    System.debug(''+pzm.monthKey);
                    String[] key = (pzm.monthKey).split('_');                   
                    System.debug('key>>>>>>'+key);
                    Integer numberOfWeeks;
                    if(selectedStartDate.month()==Integer.valueOf(key[0]) && selectedStartDate.year()==Integer.valueOf(key[1])) { 
                        System.debug('selectedStartDate >>>'+selectedStartDate);
                        Integer numberOfDaysInMonth = Date.daysInMonth(selectedStartDate.year(), selectedStartDate.month());
                        Date lastDt = Date.newInstance(selectedStartDate.year(), selectedStartDate.month(), numberOfDaysInMonth);                       

                        //SRSF-3116: Start: 11-06-2021                        
                        if (selectedEndDate <= lastDt) {                            
                            numberOfWeeks = getTotalSundayInMonth (selectedStartDate,selectedEndDate);
                            System.debug('numberOfWeeks-0 >>>>>'+numberOfWeeks);
                            if(todayDay != 'Sunday'){
                                if (!getBroadcast(selectedEndDate)){
                                    numberOfWeeks= numberOfWeeks + 1;
                                } 
                            } 
                        } else {                            
                            numberOfWeeks = getTotalSundayInMonth (selectedStartDate,lastDt);
                        }                        
                        // End: 11-06-2021
                        pzm.monthAmount = Integer.valueOf((weeklyAmt * numberOfWeeks));                        
                    } else if ( (Integer.valueOf(key[0])>selectedEndDate.month() && Integer.valueOf(key[1])==selectedEndDate.year()) ||
                                (Integer.valueOf(key[0])<selectedEndDate.month() && Integer.valueOf(key[1])>selectedEndDate.year())  // Added this line for SRSF:3253: 19-08-2021
                        ){
                        System.debug('selectedEndDate.month() is greater>>>'+selectedEndDate);
                        numberOfWeeks = 1;                        
                        pzm.monthAmount = Integer.valueOf((weeklyAmt * numberOfWeeks));                       
                    } else if (selectedEndDate.month()==Integer.valueOf(key[0]) && selectedEndDate.year()==Integer.valueOf(key[1])){ 
                        System.debug('selectedEndDate.month() is equal>>>'+selectedEndDate);
                        Date startDt = Date.newInstance(selectedEndDate.year(), selectedEndDate.month(), 01);
                        numberOfWeeks = getTotalSundayInMonth (startDt,selectedEndDate); 

                        // SRSF-3116: Added below if loop : 14-06-2021
                        if(todayDay != 'Sunday'){
                            if (!getBroadcast(selectedEndDate)){
                                numberOfWeeks= numberOfWeeks + 1;
                            } 
                        } 
                        // SRSF-3116: End
                        pzm.monthAmount = Integer.valueOf((weeklyAmt * numberOfWeeks));                       
                    } else {
                        Date startDt = Date.newInstance(Integer.valueOf(key[1]), Integer.valueOf(key[0]), 01);
                        Integer numberOfDaysInMonth = Date.daysInMonth(Integer.valueOf(key[1]), Integer.valueOf(key[0]));
                        Date lastDt = Date.newInstance(Integer.valueOf(key[1]), Integer.valueOf(key[0]), numberOfDaysInMonth);
                        System.debug('startDt>>> '+startDt + '<<<lastDt>>> '+lastDt);                        
                        numberOfWeeks = getTotalSundayInMonth (startDt,lastDt); 
                        System.debug('numberOfWeeks-4>>>>>'+numberOfWeeks);
                        pzm.monthAmount = Integer.valueOf((weeklyAmt * numberOfWeeks));
                        System.debug('month Amount-4>>>>>'+pzm.monthAmount);
                    }                   
                }               
                changeInCellAmount();
            }
        }
        catch(Exception ex) {
            System.debug(' ### Exception ::: ' +ex.getMessage() + ' ::: line number ::: ' +ex.getLineNumber());
        }   
    }

    /**  
    * @author               : Bhuvanasankar Das (OSI)
    * @date                 : 21-Dec-2017
    * @description          : This function is used to split the amount based on month
    * @param                : no params
    * @return               : 
    */
    public void splitColumnTotal() {
        System.debug('inside splitColumnTotal>>>>>>>>>');        
        try {
            if(colAmount != null) {
                Decimal colCellAmt = 0.00;
                colCellAmt = (colAmount/scheduleTypeList.size()).setScale(2);
                for(String str : scheduleTypeList) {
                    List<proposalZoneMonthlyWrapper> pzmWrpList = wrapMap.get(str);
                    if(pzmWrpList != null) {
                        for(proposalZoneMonthlyWrapper pzm : pzmWrpList) {
                            String[] key = (pzm.monthKey).split('_');
                            if((key[0]+'_'+key[1]).equalsIgnoreCase(monthString)) {
                                pzm.monthAmount = Integer.valueOf(colCellAmt);
                                System.debug('3>>>>>'+Integer.valueOf(colCellAmt));
                            }
                        }        
                    }
                }
                changeInCellAmount();
            }
        }
        catch(Exception ex) {
            System.debug(' ### Exception ::: ' +ex.getMessage() + ' ::: line number ::: ' +ex.getLineNumber());
        }
    }

    /**  
    * @author               : Bhuvanasankar Das (OSI)
    * @date                 : 21-Dec-2017
    * @description          : This function is used to recalculate rowTotal and column Total
    * @param                : no params
    * @return               : 
    */
    public void changeInCellAmount() {
        System.debug('inside changeInCellAmount>>>>>>>>>'+wrapList);
        // Start: SRSF-2239 : Get Discount Percentage from Opportunity
        Decimal discountValue = 0.0;                    
        if(oppty.Agency_Account__c != null && oppty.Rep_Firm__c != null){ // If both Agency & Rep Firm Exists in Opportunity
            if (oppty.Agency_Account__r.Discount_Percentage__c >= oppty.Rep_Firm__r.Discount_Percentage__c){
                discountValue = oppty.Agency_Account__r.Discount_Percentage__c;
            } else {
                discountValue = oppty.Rep_Firm__r.Discount_Percentage__c;
            }                      
        } else if(oppty.Agency_Account__c != null && oppty.Rep_Firm__c == null){ // If only Agency exists & No Rep Firm Exists in Opportunity
            discountValue = oppty.Agency_Account__r.Discount_Percentage__c;
        } else if(oppty.Agency_Account__c == null && oppty.Rep_Firm__c != null){   // If No Agency Exists & only Rep Firm Exists in Opportunity  
            discountValue = oppty.Rep_Firm__r.Discount_Percentage__c;
        }
        discountValue = discountValue != NULL ? discountValue : 0.0;        
        System.debug('discountValue>>>'+discountValue);     
        // End: SRSF-2239

        // To Calculate total based on schedule type
        for(String schType : scheduleTypeList) {
            List<proposalZoneMonthlyWrapper> pzmWrpList = wrapMap.get(schType);
            if(pzmWrpList != null) {
                Decimal totalRowAmount = 0.00;
                for(proposalZoneMonthlyWrapper pzm : pzmWrpList) {
                    totalRowAmount += pzm.monthAmount;
                }
                rowTotalMap.put(schType, totalRowAmount);
            }
        }
    
        columnTotalMap = new Map<String, Decimal>();    
        columnNetTotalMap = new Map<String, Decimal>(); // SRSF-2239 
        for(proposalZoneMonthlyWrapper wrp : wrapList) {
            String[] correctKey = wrp.monthKey.split('_');
            String correctMonthKey = correctKey[0] + '_' + correctKey[1]; 
            System.debug('correctMonthKey>>>>>'+correctMonthKey);           
            if(columnTotalMap.containsKey(correctMonthKey)) {
                Decimal newValue = 0.00;               
                newValue = columnTotalMap.get(correctMonthKey) + wrp.monthAmount; 
                System.debug('newValue >>>>>'+newValue);              
                columnTotalMap.put(correctMonthKey,newValue);
            }
            else {
                System.debug('monthAmount >>>>>'+wrp.monthAmount); 
                columnTotalMap.put(correctMonthKey, wrp.monthAmount);               
            }


            //Start: SRSF-2239 
            if(columnNetTotalMap.containsKey(correctMonthKey)) {                
                Decimal newNetValue = 0.00;
                System.debug('columnNetTotalMap correctMonthKey>>>'+columnNetTotalMap.get(correctMonthKey)); 
                System.debug('wrp.monthAmount>>>'+wrp.monthAmount); 
                newNetValue = columnNetTotalMap.get(correctMonthKey) + wrp.monthAmount-((wrp.monthAmount * discountValue)/100);
                System.debug('newNetValue>>>'+newNetValue); 
                columnNetTotalMap.put(correctMonthKey,newNetValue);
            }
            else {
                System.debug('1st time>>>>'+wrp.monthAmount);
                System.debug('1st time>>>>'+((wrp.monthAmount* discountValue)/100));
                System.debug('1st time>>>>'+(wrp.monthAmount-((wrp.monthAmount * discountValue)/100)));
                columnNetTotalMap.put(correctMonthKey, wrp.monthAmount-((wrp.monthAmount * discountValue)/100));
                System.debug('columnNetTotalMap >>>>'+columnNetTotalMap.get(correctMonthKey)); 
            }
            propZoneMVmap.put(wrp.monthKey,wrp.monthAmount-((wrp.monthAmount * discountValue)/100));
          //  wrp.netAmount=Integer.valueOf(wrp.monthAmount-((wrp.monthAmount * discountValue)/100)); // 18-Feb-2021
            //End: SRSF-2239            
        }

        Decimal finalTotalAmount = 0.00;
        Decimal finalNetAmount = 0.00; // SRSF-2239
        for(Decimal dr : rowTotalMap.values()) {
            finalTotalAmount += dr.setScale(2);
        }                       
        columnTotalMap.put('Final_Total', finalTotalAmount);
        finalNetAmount = finalTotalAmount-(finalTotalAmount /100 * discountValue); // SRSF-2239
        System.debug('finalNetAmount>>>'+finalNetAmount);        
          
        finalNetAmount = finalNetAmount.setScale(2);
        columnNetTotalMap.put('Final_Total', finalNetAmount);   // SRSF-2239
        System.debug('columnNetTotalMap @907>>>'+columnNetTotalMap);
    }

    // Need to think about save functionality(Both proposal zone and its monthly values).
    public void submitButton() {
        //saveData();
        try {
            calculateDateDifference();
        }
        catch(Exception ex) {
            System.debug('@@@ Exception ::: ' +ex.getMessage() + ' ::: line number ::: ' +ex.getLineNumber());
        }
    }

   public pageReference saveData(){
        //calculateDateDifference();
        //customSettingValues();
        System.debug('optionSelected ' + optionSelected);
        populateMonthAmountMap();
        return null;
    }


    public void customSettingValues() {
        custSettingMap = new Map<String, String>();
        sysCodeValueNameMapping = new Map<String, String>();
        Map<String,SysCodeManualProposalCreation__c> custSettMap = new Map<String,SysCodeManualProposalCreation__c>();
        custSettMap = SysCodeManualProposalCreation__c.getAll();

        for(SysCodeManualProposalCreation__c cs : custSettMap.values()) {
            custSettingMap.put(cs.Name__c, cs.Value__c);
            sysCodeValueNameMapping.put(cs.Value__c, cs.Name__c);
        }        
    }

    public pageReference save() {
        System.debug('inside SAVE>>>>>'+wrapList);
        try
        {
            if(!CommonUtilities.isListNullOrEmpty(wrapList) && wrapList.Size()>0){
                for(proposalZoneMonthlyWrapper pr : wrapList) {
                   // wrapperKeys.add(pr.monthKey); //SRSF-2165
                    /* Commented by Sridhar : Need to allow negative values SRSF-2484
                    if (pr.monthAmount < 0) {
                        String customErrorMsg = 'Amount on one of the month is less than 0. Please correct it out';
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,customErrorMsg));
                        return NULL;
                    }*/
                }
            }
          if(Proposal.Id == null)
          {
            proposal.Opportunity__c = oppty.Id;
          }
          proposal.Start_Date__c = selectedStartDate;
          proposal.End_Date__c = selectedEndDate;
          proposal.Name = ('Opportunity Budget '+oppty.Account.Name).left(79);
          upsert proposal;
        }
        catch(Exception ex)
        {
            System.debug('$$$ Exception ::: '+ex.getMessage());
        }
        
        System.debug('$$$ selectedStartDate ::: '+selectedStartDate);
        System.debug('$$$ selectedEndDate ::: ' +selectedEndDate);
        List<Proposal_Zone_Monthly_Value__c> updateList = new List<Proposal_Zone_Monthly_Value__c>();
        List<Proposal_Zone_Monthly_Value__c> insertList = new List<Proposal_Zone_Monthly_Value__c>();
        List<Proposal_Zone_Monthly_Value__c> deleteList = new List<Proposal_Zone_Monthly_Value__c>();
        List<Proposal_Zone__c> pZoneListToInsert = new List<Proposal_Zone__c>();
        Set<String> sysCodeSet = new Set<String>();
        System.debug('inside SAVE-wrapList>>>>>'+wrapList);
        if(!CommonUtilities.isListNullOrEmpty(wrapList) && wrapList.Size()>0){        
            for(proposalZoneMonthlyWrapper pr : wrapList)
            {
                if(!PZMVmap.containsKey(pr.monthKey) && pr.monthAmount != 0.00)
                {   
                    String sysCode = custSettingMap.get(pr.scheduleType);
                    if(!proposalZoneMap.containsKey(sysCode) && !sysCodeSet.contains(sysCode)) 
                    {
                        Proposal_Zone__c propZone = createProposalZone(sysCode, false);
                        sysCodeSet.add(sysCode);
                        pZoneListToInsert.add(propZone);
                    }
                }
            }
        }
        if(pZoneListToInsert.size() > 0)
        {
            insert pZoneListToInsert;
            for(Proposal_Zone__c propZone : pZoneListToInsert)
            {
                if(!proposalZoneMap.containsKey(propZone.Sys_Code__c))
                    proposalZoneMap.put(propZone.Sys_Code__c,propZone);
            }
        }
        if(!CommonUtilities.isListNullOrEmpty(wrapList) && wrapList.Size()>0){        
            for(proposalZoneMonthlyWrapper pr : wrapList) {
                Integer monthNumber = Integer.valueOf(((pr.monthKey).split('_'))[0]);
                Integer yearNumber = Integer.valueOf(((pr.monthKey).split('_'))[1]);
                if(PZMVmap.containsKey(pr.monthKey)) {
                    Proposal_Zone_Monthly_Value__c pzm = PZMVmap.get(pr.monthKey);
                    System.debug(' $$$ inside PZMVmap ::: ' + pzm+pr);
                     /*if((monthNumber >= selectedStartDate.month()   
                     && monthNumber <= selectedEndDate.month()
                     && yearNumber == selectedStartDate.year())  
                        || (monthNumber <= selectedEndDate.month() && yearNumber > selectedEndDate.year()))
                        {*/
                            availableMonthlyZoneValues.remove(pzm);
                           
                            if(monthAmountMap.get(pr.monthKey) != pr.monthAmount) {
                                pzm.Gross_Amount__c = pr.monthAmount;
                                updateList.add(pzm); 
                            }
                            // Sridhar : 16-02-2021 Added below block of code                           
                            if(netAmountMap.get(pr.monthKey) != pr.netAmount) {
                            //  pzm.Net_Amount__c = pr.netAmount; // Commented: 19-Feb-2021
                                pzm.Net_Amount__c = propZoneMVmap.get(pr.monthKey);
                                updateList.add(pzm); 
                            }
                            // updateList.add(pzm);  // Sridhar: 21-10-2020
                            //system.debug('updateList' + updateList);
                        //}
                        //else {
                        //    deleteList.add(pzm);
                        //}
                }
                else if(pr.monthAmount != 0.00) {
                    String sysCode = custSettingMap.get(pr.scheduleType);
                    Proposal_Zone_Monthly_Value__c newPZM = new Proposal_Zone_Monthly_Value__c();
                    String accName = oppty.Account.Name.length() > 40 ?oppty.Account.Name.subString(0,40):oppty.Account.Name;
                    newPZM.name = 'Monthly Value '+ accName;
                    newPZM.Advertiser__c = oppty.AccountId;//opptyAccount.id;
                    if(!proposalZoneMap.containsKey(sysCode)) {
                        Proposal_Zone__c propZone = createProposalZone(sysCode);
                        newPZM.Proposal_Zone__c = propZone.Id;
                        proposalZoneMap.put(propZone.Syscode__c,propZone);
                    }
                    else {
                        newPZM.Proposal_Zone__c = proposalZoneMap.get(sysCode).Id;
                    }
                    Date broadCastDate = Date.newInstance(yearNumber, monthNumber, 15);
                    //newPZM.Broadcast_Month_Date__c = selectedStartDate.addMonths(monthsNeedToBeAdded);
                    newPZM.Broadcast_Month_Date__c = broadCastDate ;
                    newPZM.Gross_Amount__c = pr.monthAmount;
                    newPZM.Schedule_Type__c = pr.scheduleType;
                    
                    insertList.add(newPZM);
                }
            }
        }
        System.debug('$$$ insertList ::: ' + insertList);
        System.debug('$$$ updateList ::: ' + updateList);
        try {
            if(updateList.size() > 0) {
                System.debug('$$$ updateList ::: ' +updateList);
                update updateList;
            }

            if(insertList.size() > 0) {
                System.debug('$$$ Inserting ::: ' +insertList);
                insert insertList;
            }
            System.debug('$$$ Deleting remaining availableMonthlyZoneValues ::: ' +availableMonthlyZoneValues);

            
            if(availableMonthlyZoneValues.size() > 0) {
                Map<string,Proposal_Zone_Monthly_Value__c> deletePZMMap = new  Map<string,Proposal_Zone_Monthly_Value__c>();
                for(Proposal_Zone_Monthly_Value__c pzmv : availableMonthlyZoneValues)
                {
                  deletePZMMap.put(String.valueOf(pzmv.Id),pzmv);
                }
                list<Proposal_Zone_Monthly_Value__c>  deletePZMList= new list<Proposal_Zone_Monthly_Value__c>();
                deletePZMList.addAll(deletePZMMap.values());
                System.debug('inside SAVE-deletePZMList>>>>>'+deletePZMList);
                delete deletePZMList;
            }
        }
        catch(Exception ex) {
            System.debug(' ### Exception ::: ' +ex.getMessage() + ' ::: line number ::: ' +ex.getLineNumber());
            System.debug('### cause ::: ' +ex.getCause());
        }
        //return null;
        return new PageReference('/' + oppty.Id);
    }

    public Proposal_Zone__c createProposalZone(String sysCode, boolean doInsert) {
        Proposal_Zone__c propZone = new Proposal_Zone__c();
        String accName = oppty.Account.Name.length() > 40 ?oppty.Account.Name.subString(0,40):oppty.Account.Name;
        propZone.name='Proposal line '+ accName;
        propZone.Proposal__c = proposal.id;
        propZone.Sys_Code__c = SysCode;
        
        if(doInsert)
            insert propZone;
        return propZone;
    }

    public Proposal_Zone__c createProposalZone(String sysCode) {
        Proposal_Zone__c propZone = createProposalZone(sysCode, true);
        return propZone;
    }

    public pageReference goBackToOpportunity() {
        return new PageReference('/' + oppty.Id);    
    }

    // Wrapper 1 (Proposal Zone Monthly Values)
    public class proposalZoneMonthlyWrapper {
        public String monthKey {get; set;}
        public Integer monthAmount {get; set;}
        public Integer netAmount {get; set;} // SRSF-2239
        public String scheduleType {get; set;}
        //public Decimal rowTotalAmount {get; set;}

        public  proposalZoneMonthlyWrapper() {}     

        public proposalZoneMonthlyWrapper(String monthKey, Integer monthAmount, Integer netAmount, String scheduleType) {
            this.monthKey = monthKey;
            this.monthAmount = monthAmount;
            this.netAmount = netAmount;
            this.scheduleType = scheduleType;
        }
    }
}