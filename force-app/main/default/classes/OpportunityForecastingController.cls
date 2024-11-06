/*

    Customer/Project:   Spectrum Reach 
    Class name:
         OpportunityForecastingController
    Author/Date:        Brett Ballantyne    7/24/2017
    Release:
            Phase 2
    Related US:         
    Purpose:            Controller for the OpportunityForecasting Lightning Component
    Notes:              This was lifted and modified from https://github.com/sfdcbox/Kanban-Lightning-component/blob/master/README.md
    Modification History:
    SRSF-1530 Added pzmvLimitClause and Try/Catch to avoid exception on inner query. Backup Apex file is OpportunityForecastingController.20190103
*/

public with sharing class OpportunityForecastingController {
    public OpportunityForecastingController() {
        
    }

    @AuraEnabled
    public static Boolean isMobile() {
        return (UserInfo.getUIThemeDisplayed() == 'Theme4t');
    }

    /*  kanbanWrapper is the class that contains all data returned to the GUI for displaying the Opportunities
        on the Opportunity Pipeline kanban board.  It also contains data used by the GUI for pikclists, monetary
        totals, tooltips, etc.  Please see the documentation for the class at the the bottom of this file.

        getKanbanWrapper returns the populated kanbanWrapper class.  It is called from changeCurrentListView, which
        is called upon initialization of the GUI, and at other times (basically anytime you need to get new data)

        Inputs
        1. objName                  - not currently used.  Set to Opportunity in the method
        2. objFields                - not currently used
        3. kanbanField              - not currently used.  Set to 'StageName' in the method
        4. whereClause              - a formatted where clause.  This is constructed by changeCurrentListView and formats
                                      the fields and values contained in the filters for the current view
        5. filterName               - contains the Name or Id of the filter view 
        6. showOnlyMyOpportunities  - not currently used.  Set in the method based on the values in the current filter
        7. sortBy                   - the field name to sort by
        8. isSortDesc               - boolean to specify sort by descending values (true), or ascending values (false) 

    */
    @AuraEnabled
    public static kanbanWrapper getKanbanWrapper(String objName, String[] objFields, String kanbanField, String whereClause, 
                                                    String filterName, Boolean showOnlyMyOpportunities, String sortBy, Boolean isSortDesc) {
        system.debug(loggingLevel.WARN, '============>> in getKanbanWrapper, filterName = ' + filterName);
        system.debug(loggingLevel.WARN, '============>> in getKanbanWrapper, whereClause = ' + whereClause);
        // validStages contains the values of the stages for getting default probability, etc
        Set<String> validStages = new Set<String>{'Planning/Proposal Creation', 'Identification', 'Presentation/Negotiation', 'Out for Signature', 'Closed Won', 'Closed Lost', 'Closed Lost to Competitor'};
        // validQueryStages contains the set of stage names displayed in the GUI and hence queried on
        Set<String> validQueryStages = new Set<String>{'Identification', 'Planning/Proposal Creation', 'Presentation/Negotiation', 'Out for Signature', 'Closed Won'};
        // stageTotals is the map of stage names to the total forecasted amount - used to display totals at the top of each stage
        Map<String, Decimal> stageTotals = new Map<String, Decimal>();
        // pendingTotals is the map of stage names to the total pending amount - used to display totals at the top of each stage
        Map<String, Decimal> pendingTotals = new Map<String, Decimal>();
        // opptyCounts is a map of stage name to total count of opptys for that stage - used to display the count for each stage in the path component
        Map<String, Integer> opptyCounts = new Map<String, Integer>();
        List<Decimal> objectTotals = new List<Decimal>();           // not currently used
        // probMap is a map of stage name to the probability of closing for each oppty stage
        Map<String, Integer> probMap = new Map<String, Integer>();
        // recAccessMap is a map of oppty Ids to a boolean that determines whether the user has edit access to that record or not
        Map<String, Boolean> recAccessMap = new Map<String, Boolean>();
        // oppsEditableByUser is a list of Ids of opptys the user is on the oppty team of
        List<String> oppsEditableByUser = new List<String>();
        // oppsEditableSet is a unique set of opptys the user is on the oppty team of
        Set<String> oppsEditableSet = new Set<String>();

        String errorMessage = '';
        String toolTip, toolTipTitle;
        String netToolTip, netToolTip2;
        objName = 'Opportunity';
        kanbanField = 'StageName';
        List<String> lstPickvals=new List<String>();
        for (Schema.PicklistEntry a : Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(kanbanField).getDescribe().getPickListValues()) {
            String value = a.getValue();
            if (validStages.contains(value)) {
                if(value != 'Planning/Proposal Creation' && value != 'Closed Lost to Competitor') {
                    lstPickvals.add(value);
                }
            }           
        }
        System.debug(lstPickvals);

        // get filter (list view) data
         Opportunity_Forecasting_Filter__c currentFilter;
            String likeUser = '%' + UserInfo.getUserId() + '%';
            currentFilter = [select Id, Name, Scope__c, Visible_To_All_Users__c, Visible_To_List_of_Users__c, Visible_To_Me__c, Visitble_To_My_Team__c, User_List__c, OwnerId, 
                                (select Id, API_Name__c, Field_Data_Type__c, Field_Name__c, Operator__c, Value__c from Opportunity_Forecasting_Filter_Values__r)
                           //     from Opportunity_Forecasting_Filter__c where Name = :filterName AND(ownerId = :UserInfo.getUserId() only do this if we want to make filter names unique to users
                           //     however, this will require more thought and processing
                                from Opportunity_Forecasting_Filter__c where Id = :filterName OR Name = :filterName ]; 


        for (OpportunityStage os : [select ApiName, DefaultProbability from OpportunityStage where ApiName in :validStages]) {
            if(os.ApiName != 'Planning/Proposal Creation' && os.ApiName != 'Closed Lost to Competitor') {
                probMap.put(os.ApiName, os.DefaultProbability.intValue());
            }
        }
 
        String standardWhereClause ='';

               standardWhereClause += ' AND (NOT ((Pending_Gross_Amount__c = 0 OR Pending_Gross_Amount__c = null)';
                    standardWhereClause += ' AND (Total_Forecast_Amount__c = 0 OR Total_Forecast_Amount__c = NULL) ';

        if (whereClause == null || (whereClause != null && !whereClause.contains('STAGENAME'))) {
            system.debug(loggingLevel.WARN, '--------->> whereClause is NOT null and is: ' + whereClause);
                system.debug(loggingLevel.WARN, '----------------->> whereClause does NOT contain STAGENAME!');
                standardWhereClause += ' AND StageName = \'Closed Won\'))';
                standardWhereClause += ' AND (((StageName in (\'Closed Lost\', \'Closed Lost to Competitor\')) AND  Closed_Won_Lost_Date__c = LAST_N_DAYS:14) '; 
                standardWhereClause += ' OR (StageName in (';
                for (String stage : validQueryStages) {
                    standardWhereClause += '\'' + stage + '\', ';
                }         
        }

        standardWhereClause = standardWhereClause.removeEnd(', ') + '))) ';

        if (whereClause != null && whereClause != '') {
            if (whereClause == 'WHERE ') {
                standardWhereClause = standardWhereClause.removeStart(' AND');
            }
            whereClause += standardWhereClause;
        }
        else {
            whereClause = ' WHERE ' + standardWhereClause.removeStart(' AND');
        }

        System.debug(loggingLevel.WARN, '==============================>> whereClause = ' + whereClause);
        String query;
        String pzmvLimitClause = (System.Label.ProposalZoneMonthlyValuesCount.length() > 0)?System.Label.ProposalZoneMonthlyValuesCount:'900';
        if(!test.isRunningTest()){
            string orderBy = ' order by ';
            if (sortBy != null) {
                String sortDirection = (isSortDesc == true) ? ' DESC ' : ' ASC ';
                orderBy +=  sortBy + sortDirection;
            }
            System.debug(loggingLevel.WARN, '==============================>> CRA pzmvLimitClause = ' + pzmvLimitClause);
            query= 'select Id, Name, Loss_Reason__c, AccountId, Account.Name, StageName, Total_Forecast_Amount__c, HasOpenActivity, CloseDate, CreatedDate, Total_Closed_Amount__c, Owner.Name, ' +
                        'Probability, Sales_Probability__c, HIDDEN_BC_ToolTip__c, Pending_Gross_Amount__c, Projected_Gross_Amount__c, Closed_Gross_Amount__c, Closed_Won_Lost_Date__c, Flight_Start_Date__c, Flight_End_Date__c, ' +
                        '(select Id, Kanban_Currency__c, Net_Amount__c from Proposals__r where active__c = true), ' +
                        '(select Id, Name, Broadcast_Month__c, Gross_Amount__c, Proposal_Zone__c, Opportunity__c from Proposal_Zone_Monthly_Values__r order by Broadcast_Month__c limit ' + pzmvLimitClause + ') ' +
                        'From Opportunity ' + 
                        whereClause + orderBy + ' limit 200';

        }else{
            whereClause = '';
            query= 'select Id, Name,Loss_Reason__c, AccountId, Account.Name, StageName, Total_Forecast_Amount__c, HasOpenActivity, CloseDate, CreatedDate, Total_Closed_Amount__c, Owner.Name, ' +
                        'Probability, Sales_Probability__c, HIDDEN_BC_ToolTip__c, Pending_Gross_Amount__c, Projected_Gross_Amount__c, Closed_Gross_Amount__c, Closed_Won_Lost_Date__c, Flight_Start_Date__c, Flight_End_Date__c, ' +
                        '(select Id, Kanban_Currency__c, Net_Amount__c from Proposals__r), ' +
                        '(select Id, Name, Broadcast_Month__c, Gross_Amount__c, Proposal_Zone__c, Opportunity__c from Proposal_Zone_Monthly_Values__r order by Broadcast_Month__c limit 1) ' +
                        'From Opportunity limit 1';
        }
        System.debug(loggingLevel.WARN, '==============================>> query = ' + query);
        String countMe = 'select count() From Opportunity ' + whereClause  + ' limit 2001';
        //countMe = 'select count() From Opportunity ' + whereClause  + ' limit 2001';
        Integer oppCount;
        String oppCountStr;
        List<Opportunity> oppList;

        try {
                system.debug(loggingLevel.WARN, '====================>> countMe = ' + countMe);
            	System.debug('query::'+query);
                oppCount = Database.countQuery(countMe);
                oppCountStr = oppCount > 2000 ? '2,000+' : oppCount.format();   // if query count > 200, just display 2000+
                system.debug(loggingLevel.WARN, '============>> oppCount, oppCountStr = ' + oppcount + ', ' + oppCountStr);
                system.debug(loggingLevel.WARN, '----------------------->> before query');
                oppList = Database.query(query);
                system.debug(loggingLevel.WARN, '----------------------->> after query');
            } catch (Exception ex) {
                errorMessage = 'The following error has occurred: ' + ex.getMessage() + '  Please contact your system administrator.'; 
                return new kanbanWrapper(null, null, null, null, null, null, null, null, null, null, null, null, null, errorMessage, null, null, null);    
            }

        system.debug(loggingLevel.WARN, '----------->> oppList = ' + oppList);
        List<Id> oppIds = new List<Id>();
        boolean isCurrentUserAdminbool = isCurrentUserAdmin();
        for (Opportunity opp : oppList) {
            oppIds.add(opp.Id);
            if (opp.OwnerId == UserInfo.getUserId()) {
                oppsEditableSet.add(opp.Id);
            }
            // Add to oppsEditableSet is current user is System Administrator
            if (isCurrentUserAdminbool) {
                oppsEditableSet.add(opp.Id);
            }
        } 
        // Create the record access map
        for (UserRecordAccess ura : [select RecordId, HasEditAccess from UserRecordAccess where UserId = :UserInfo.getUserId() and RecordId in :oppIds]) {
            recAccessMap.put(ura.RecordId, ura.HasEditAccess);
        }

        // create the list for OTM access
        for (OpportunityTeamMember otm : [select OpportunityId, UserId from OpportunityTeamMember where OpportunityId in :oppIds and UserId = :UserInfo.getUserId() ]) {
            oppsEditableSet.add(otm.OpportunityId);           
        }
        oppsEditableByUser.addAll(oppsEditableSet);

        Set<Id> proposals = new Set<Id>();
        set<Id> propoosalZoneIds = new Set<Id>();
        try {
            for (Proposal__c prop : [select Id from Proposal__c where Opportunity__c in :oppIds]) {
                proposals.add(prop.Id);
            }
            for (Proposal_Zone__c pz : [select Id from Proposal_Zone__c where Proposal__c in :proposals]) {
                propoosalZoneIds.add(pz.Id);
            }            
        } catch (Exception ex) {
            system.debug(loggingLevel.WARN, 'The following error occured getting proposals or Proposal Zones in OpportunityForecastingController: ' + ex.getMessage());
        }

        system.debug(loggingLevel.WARN, '===================>> propoosalZoneIds.size =  ' + propoosalZoneIds.size());
        Map<Id, Proposal_Zone__c> pzMap = new Map<Id, Proposal_Zone__c>();
        if (propoosalZoneIds.size() > 0) {
            pzMap = new Map<Id, Proposal_Zone__c>([select Id, Status_Type__c from Proposal_Zone__c where Id in :propoosalZoneIds]);
        }
        system.debug(loggingLevel.WARN, '===================>> pzMap =  ' + pzMap);
        List<broadcastValuesWrapper> bcValuesWrapperList = new List<broadcastValuesWrapper>();
        for (Opportunity opp : oppList) {

            Decimal currentAmount = (opp.Total_Forecast_Amount__c == null) ? 0.0 : opp.Total_Forecast_Amount__c;
            Decimal currentPendingAmount = (opp.Pending_Gross_Amount__c == null) ? 0.0 : opp.Pending_Gross_Amount__c;

            String stageNameTemp = opp.StageName;
            if(stageNameTemp == 'Planning/Proposal Creation') { // group Planning/Proposal Creation stage with Identification
                stageNameTemp = 'Identification';
                opp.StageName = 'Identification';
            }
            if(stageNameTemp == 'Closed Lost to Competitor') { // group Closed Lost to Compentitor with 'Closed Lost' 
                stageNameTemp = 'Closed Lost';
                opp.StageName = 'Closed Lost';
            }
            Decimal totalAmountForStage = stageTotals.get(stageNameTemp);
            Decimal totalPendingForStage = pendingTotals.get(stageNameTemp);
            Integer opptyCountByStage = opptyCounts.get(stageNameTemp);
            if (totalAmountForStage == null) {
                stageTotals.put(stageNameTemp, currentAmount);
                pendingTotals.put(stageNameTemp, currentPendingAmount);
                opptyCounts.put(stageNameTemp, 1);
                //opptyCounts.put(stageNameTemp, 9);
            } else {
                stageTotals.put(stageNameTemp, totalAmountForStage + currentAmount);
                pendingTotals.put(stageNameTemp, totalPendingForStage + currentPendingAmount);
                opptyCounts.put(stageNameTemp, ++opptyCountByStage);
            }
            // fill out monthly broadcast totals
            broadcastValuesWrapper bcValuesWrapper = new broadcastValuesWrapper();
            Map<String, Decimal> broadcastGrossValues = new Map<String, Decimal>();
            Map<String, Decimal> broadcastNetValues = new Map<String, Decimal>();
            Map<String, Decimal> broadcastForecastValues = new Map<String, Decimal>();
            bcValuesWrapper.opptyId = opp.Id;
            //bcValuesWrapper.opptyId = opp.Name;
            bcValuesWrapper.broadcastMonthGrossValues = broadcastGrossValues;
            bcValuesWrapper.broadcastMonthNetValues = broadcastNetValues;
            bcValuesWrapper.broadcastMonthForecastValues = broadcastForecastValues;
  
            if (opp.Proposal_Zone_Monthly_Values__r.size() != Integer.valueOf(pzmvLimitClause)) {
            try {
                //system.debug(loggingLevel.WARN, '==========>> before for opp :' + opp);
                //system.debug(loggingLevel.WARN, '==========>> before for opp.Proposal_Zone_Monthly_Values__r.size() :' + opp.Proposal_Zone_Monthly_Values__r.size());
                for (Proposal_Zone_Monthly_Value__c pzm : opp.Proposal_Zone_Monthly_Values__r) {
                  
                    Proposal_Zone__c pz = pzMap.get(pzm.Proposal_Zone__c);
                    // system.debug(loggingLevel.WARN, '==========>> pzm.Proposal_Zone__c = ' + pzm.Proposal_Zone__c);
                    // system.debug(loggingLevel.WARN, '==========>> pz = ' + pz);
                    if (pz != null) {
                        Decimal curGrossBCAmount = (pzm.Gross_Amount__c == null) ? 0.0 : pzm.Gross_Amount__c;
                        // Gross amount is used for both Gross and Net - Gross and Net are determined by the Status Type on the proposal object 
                        // If you think that's weird, join the club - monthly club dues are high though...
                        String monthCode = getMonthCode(pzm.Broadcast_Month__c);
                        if (pz.Status_Type__c == 'ClosedWon') {
                            Decimal totalNetBCAmount = broadcastNetValues.get(monthCode);
                            if (totalNetBCAmount == null) {
                                broadcastNetValues.put(monthCode, curGrossBCAmount);
                            } else {
                                broadcastNetValues.put(monthCode, totalNetBCAmount + curGrossBCAmount);
                                //broadcastForecastValues.put(monthCode, 9.9);
                            }               

                        } else if (pz.Status_Type__c == 'Pending') {
                            Decimal totalGrossBCAmount = broadcastGrossValues.get(monthCode);
                          //  System.debug(loggingLevel.WARN, '=========>> totalGrossBCAmount = ' + totalGrossBCAmount);
                          //  System.debug(loggingLevel.WARN, '=========>> curGrossBCAmount = ' + curGrossBCAmount);
                            if (totalGrossBCAmount == null) {
                                broadcastGrossValues.put(monthCode, curGrossBCAmount);
                            } else {
                                broadcastGrossValues.put(monthCode, totalGrossBCAmount + curGrossBCAmount);
                            }
                        } else if (pz.Status_Type__c == null) {
                            Decimal totalForecastBCAmount = broadcastForecastValues.get(monthCode);
                           // System.debug(loggingLevel.WARN, '=========>> totalForecastBCAmount = ' + totalForecastBCAmount);
                           // System.debug(loggingLevel.WARN, '=========>> curGrossBCAmount = ' + curGrossBCAmount);
                            if (totalForecastBCAmount == null) {
                                broadcastForecastValues.put(monthCode, curGrossBCAmount);
                            } else {
                               broadcastForecastValues.put(monthCode, totalForecastBCAmount + curGrossBCAmount);
                            }
                        }
                    }               
                }
                system.debug(loggingLevel.WARN, '--------------->> after broadcastGrossValues = ' + broadcastGrossValues);
            } catch (Exception ex) {
                system.debug(loggingLevel.WARN, 'The following error occured getting proposals or Proposal Zones in OpportunityForecastingController: ' + ex.getMessage() + ' for Opportunity Neme:' + opp.Name + ' Id:' + opp.Id);
                //errorMessage = 'The following error has occurred: ' + ex.getMessage() + '.  Please contact your System Administrator.'; 
                //errorMessage = 'Please contact your System Administrator. Too many Proposal Monthly Values have been returned.'; 
                errorMessage = System.Label.TooMuchBroadcastDataExistsErrorMessage;
                return new kanbanWrapper(null, null, null, null, null, null, null, null, null, null, null, null, null, errorMessage, null, null, null); 
            } 
        }
            // build the toolTip HTML for the Proposal zone monthly values
            //system.debug(loggingLevel.WARN, 'CLARKA opp.PZMV_r ' + opp.Proposal_Zone_Monthly_Values__r.size()); 
            //system.debug(loggingLevel.WARN, 'CLARKA System.Label.PZMV ' + Integer.valueOf(System.Label.ProposalZoneMonthlyValuesCount)); 
            toolTip = '';
            List<String> args = new String[]{'0','number','#,###'};

            if (opp.Proposal_Zone_Monthly_Values__r.size() == Integer.valueOf(pzmvLimitClause)){
                system.debug(loggingLevel.WARN, '==========>> toolTipTitle inside equals :' );//+ opp.Proposal_Zone_Monthly_Values__r.size());
                toolTipTitle = 'Too much broadcast data exists for this Opportunity.<br/>';
            }
            else if (opp.Proposal_Zone_Monthly_Values__r.size() > 0){
                system.debug(loggingLevel.WARN, '==========>> toolTipTitle inside > 0 :' );//+ opp.Proposal_Zone_Monthly_Values__r.size());
                toolTipTitle='<div style="display:inline-block;vertical-align:middle;margin-right:5px;width:100%;" >'+
                                    '<span style="vertical-align:middle;">'+
                                    (opp.Flight_Start_Date__c != null || opp.Flight_End_Date__c != null ? '<span style="text-align: right; font-size: .85em; float: right"><center><b>Flight</b></center>'+ (opp.Flight_Start_Date__c != null ? '<em>Start: </em>'+formatToSimpleDate(opp.Flight_Start_Date__c)+'<br/>' : '') + (opp.Flight_End_Date__c != null ? '<em>End: </em>'+formatToSimpleDate(opp.Flight_End_Date__c) : '') + '</span>' : '')+
                                    '<span style="font-size: .85em">OPPORTUNITY</span><br/><strong>' + opp.Name + '</strong></span></div><br/><br/>';
            }
            else {
                system.debug(loggingLevel.WARN, '==========>> toolTipTitle inside else :' );//+ opp.Proposal_Zone_Monthly_Values__r.size());
                toolTipTitle=System.Label.NoBroadcastDataExists;
                toolTipTitle+='<br/>';
            }

            if (opp.Proposal_Zone_Monthly_Values__r.size() == Integer.valueOf(pzmvLimitClause)){
                system.debug(loggingLevel.WARN, '==========>> toolTip inside equals :' );//+ opp.Proposal_Zone_Monthly_Values__r.size());
                toolTip=System.Label.TooMuchBroadcastDataExists;
            }
            else if (opp.Proposal_Zone_Monthly_Values__r.size() > 0){
                system.debug(loggingLevel.WARN, '==========>> toolTip inside > 0 :' );//+ opp.Proposal_Zone_Monthly_Values__r.size());
                toolTip='<table  style="border-spacing:5px; border-collapse:separate;border-radius: 5px;"><em>Total <span>Pending</span> Spend by Broadcast Month</em><br/><div style="font-size: 1px; height: 1px; width: 100%; text-align: left; background-color: rgb(106,168,79);">&nbsp;</div><tr>';
            }
            else {
                system.debug(loggingLevel.WARN, '==========>> toolTip inside else :' );//+ opp.Proposal_Zone_Monthly_Values__r.size());
                toolTip=System.Label.NoBroadcastDataExists;
            }           
        
            netToolTip = '<table style="border-spacing:5px; border-collapse:separate;border-radius: 5px;">' + '<em>Total <span>Closed</span> Spend by Broadcast Month</em><br/><div style="font-size: 1px; height: 1px; width: 100%; text-align: left; background-color: rgb(0,0,0);">&nbsp;</div><tr>';
            netToolTip2 = '<table style="border-spacing:5px; border-collapse:separate;border-radius: 5px;">' + '<em>Total <span>Forecasted</span> Spend by Broadcast Month</em><br/><div style="font-size: 1px; height: 1px; width: 100%; text-align: left; background-color: rgb(250, 169,26);">&nbsp;</div><tr>';
            // populate broadcast month header row
            for (String key : broadcastNetValues.keySet()) {
                //netToolTip += '<th style="text-align:center;">' + key + '</th>';
            }
            for (String key : broadcastGrossValues.keySet()) {
               // toolTip += '<th style="text-align:center;" >' + key + '</th>';
             //   netToolTip2 += '<th style="text-align:center;" >' + key + '</th>';
            }
            if ((!toolTip.equals(System.Label.NoBroadcastDataExists)) && (!toolTip.equals(System.Label.TooMuchBroadcastDataExists))) {
//              toolTip += '</tr><tr>';
  //              netToolTip += '</tr><tr>';
    //            netToolTip2 += '</tr><tr>';
            }
            Integer counter = 0;
            Integer cols = 6;
            //List<String> args = new String[]{'0','number','#,###'};

            
            for (String key : broadcastNetValues.keySet()) {
                if((broadcastNetValues.get(key)).intValue() > 0) {
                    netToolTip += Math.mod(counter, cols) == 0 && counter != 0 ? '</tr><tr>' : '';
                    netToolTip += '<td style="text-align:center;font-size: .85em">'+key+'<br/><strong style="color: rgb(0,0,0);">$' + String.format((broadcastNetValues.get(key)).intValue().format(), args) + '</strong></td>';
                    //netToolTip += '<td style="text-align:center;font-size: .85em">'+key+'<br/><strong style="color: rgb(50,50,50);">$' + String.format((broadcastNetValues.get(key)).intValue().format(), args) + '</strong></td>';
                    counter++;
                }
            }
            counter = 0;
            for (String key : broadcastGrossValues.keySet()) {
                //toolTip += '<td style="align:center;">$' + (broadcastGrossValues.get(key)).intValue() + '</td>';
           //     system.debug(loggingLevel.WARN, '############### key(month) = ' + key);
           //     system.debug(loggingLevel.WARN, '############### broadcastGrossValues.get(key) = ' + broadcastGrossValues.get(key));
           //     system.debug(loggingLevel.WARN, '############### broadcastGrossValues.get(key).intValue() = ' + broadcastGrossValues.get(key).intValue());
                if((broadcastGrossValues.get(key)).intValue() > 0) {
                    toolTip += Math.mod(counter, cols) == 0 && counter != 0 ? '</tr><tr>' : '';
                    toolTip += '<td style="text-align:center; font-size: .85em">'+key+'<br/><strong style="color: rgb(106,168,79);"">$' + String.format((broadcastGrossValues.get(key)).intValue().format(), args) + '</strong></td>';
                    counter++;
                }
            }
            counter = 0;
            for (String key : broadcastForecastValues.keySet()) {
                //toolTip += '<td style="align:center;">$' + (broadcastForecastValues.get(key)).intValue() + '</td>';
           //     system.debug(loggingLevel.WARN, '############### key(month) = ' + key);
           //     system.debug(loggingLevel.WARN, '############### broadcastForecastValues.get(key) = ' + broadcastForecastValues.get(key));
           //     system.debug(loggingLevel.WARN, '############### broadcastForecastValues.get(key).intValue() = ' + broadcastForecastValues.get(key).intValue());
                if((broadcastForecastValues.get(key)).intValue() > 0) {
                    netToolTip2 += Math.mod(counter, cols) == 0 && counter != 0 ? '</tr><tr>' : '';
                    //netToolTip2 += '<td style="text-align:center; font-size: .85em">'+'XXX'+'<br/><strong style="color: rgb(1, 1,1);">$' + String.format((broadcastForecastValues.get(key)).intValue().format(), args) + '</strong></td>';
                    netToolTip2 += '<td style="text-align:center; font-size: .85em">'+key+'<br/><strong style="color: rgb(250, 169,26);">$' + String.format((broadcastForecastValues.get(key)).intValue().format(), args) + '</strong></td>';
                    counter++;
                }
            }
         //   system.debug(loggingLevel.WARN, '$$$$$$$$$$$$$$$$ toolTip = ' + toolTip);
            if ((!toolTip.equals(System.Label.NoBroadcastDataExists)) && (!toolTip.equals(System.Label.TooMuchBroadcastDataExists))) {
                toolTip += '</tr></table><br/>';
                netToolTip += '</tr></table>';
                netToolTip2 += '</tr></table><br/>';
                toolTip = toolTipTitle + netToolTip2  + toolTip +  netToolTip ;
            }



            opp.HIDDEN_BC_ToolTip__c = toolTip;
          //  system.debug(loggingLevel.WARN, '$$$$$$$$$$$$$$$$ opp.HIDDEN_BC_ToolTip__c = ' + opp.HIDDEN_BC_ToolTip__c);
            bcValuesWrapperList.add(bcValuesWrapper);
        }
        String visiString = '';
        if (currentFilter.Visible_To_All_Users__c) {
            visiString = 'All';
        } else if (currentFilter.Visible_To_List_of_Users__c) {
            visiString = 'Manager';     // hope this works, otherwise we'll need more complex logic
        } else if (currentFilter.Visible_To_Me__c) {
            visiString = 'Me';
        }
        List<filterRule> frList = new List<filterRule>();
        for (Opportunity_Forecasting_Filter_Values__c offv : currentFilter.Opportunity_Forecasting_Filter_Values__r) {
            filterRule fr = new filterRule();
            fr.value = offv.Value__c;
            fr.label = offv.Field_Name__c;
            fr.operator = offv.Operator__c;
            fr.ApiName = offv.API_Name__c;
            fr.dataType = offv.Field_Data_Type__c;
            frList.add(fr);
        }

        showOnlyMyOpportunities = currentFilter.Scope__c.equals('My Opportunities') || currentFilter.Scope__c.equals('Manager');
        return new kanbanWrapper(oppList, lstPickvals, stageTotals, pendingTotals, objectTotals, opptyCounts, bcValuesWrapperList, probMap, 
                                    visiString, showOnlyMyOpportunities, frList, recAccessMap, oppsEditableByUser, errorMessage, filterName, oppCount, oppCountStr);
    }
    @TestVisible private static String getMonthCode(String monthNum) {
        if(monthNum == null) {
            return null;
        }
        else if(monthNum == '01') {
            return 'JAN';
        }
        else if(monthNum == '02') {
            return 'FEB';
        }
        else if(monthNum == '03') {
            return 'MAR';
        }
        else if(monthNum == '04') {
            return 'APR';
        }
        else if(monthNum == '05') {
            return 'MAY';
        }
        else if(monthNum == '06') {
            return 'JUN';
        }
        else if(monthNum == '07') {
            return 'JUL';
        }
        else if(monthNum == '08') {
            return 'AUG';
        }
        else if(monthNum == '09') {
            return 'SEP';
        }
        else if(monthNum == '10') {
            return 'OCT';
        }
        else if(monthNum == '11') {
            return 'NOV';
        }
        else if(monthNum == '12') {
            return 'DEC';
        }
        else {
            return 'Unknown';
            //return monthNum;
        }

    }
      @AuraEnabled public static String deleteListView(String listViewId, Boolean isUserAdmin) {
        String errorMessage = '';
        Opportunity_Forecasting_Filter__c off = [Select Id, Name, Visible_To_All_Users__c, OwnerId from Opportunity_Forecasting_Filter__c WHERE Id = :listViewId];
        List<Opportunity_Forecasting_Filter_Values__c> existingoffvs = [select Id from Opportunity_Forecasting_Filter_Values__c where Opportunity_Forecasting_Filter__c = :off.Id AND API_Name__c != null];
        if((off.Name == 'All Opportunities' || off.Name == 'My Opportunities') && off.Visible_To_All_Users__c) {
            errorMessage = 'You are not able to delete global List View "'+off.Name+'"';
        }
        else if(!isUserAdmin && off.OwnerId != UserInfo.getUserId()){
            errorMessage = 'You do not have permission to delete List View "'+off.Name+'"';
        }
        else {
            delete existingoffvs;
            delete off;
            Opportunity_Forecasting_Filter__c off2 = [Select Id, Name, Visible_To_All_Users__c, OwnerId from Opportunity_Forecasting_Filter__c WHERE Name = 'My Opportunities'];
            setSession(off2.Id); // reset Session to My Opportunities
        }

        return errorMessage;
      }

      @AuraEnabled public static kanbanWrapper changeCurrentListView(String objName, String[] objFields, String kanbanField, String listViewId, 
                                                                        Boolean showOnlyMyOpportunities, Boolean checkListViewCache, String sortBy, Boolean isSortDesc, String nameFilter) {
        try {
            String lvId = listViewId;
            Id lvIdTemp = getSession();
            if(lvIdTemp != null && checkListViewCache) {//&& String.isBlank(nameFilter)
                lvId = lvIdTemp;
            }/*else if(!String.isBlank(nameFilter)){
                lvId = 'All Opportunities';
            }*/
            System.debug('lvId::'+lvId);
            Opportunity_Forecasting_Filter__c off = [select Id, Name, Scope__c, Visible_To_Me__c, Visitble_To_My_Team__c, Visible_To_List_of_Users__c, Visible_To_All_Users__c, User_List__c, OwnerId,
                                                        (select Id, API_Name__c, Field_Data_Type__c, Field_Name__c, Operator__c, Value__c 
                                                        from Opportunity_Forecasting_Filter_Values__r)
                                                    from Opportunity_Forecasting_Filter__c where (Id = :lvId OR Name = :lvId)];
            system.debug(loggingLevel.WARN, '----->> in changeCurrentListView, Scope__c = ' + off.Scope__c);
            system.debug(loggingLevel.WARN, '----->> in changeCurrentListView, showOnlyMyOpportunities = ' + showOnlyMyOpportunities);
            String whereClause = formatWhereClause(off);
            System.debug('whereClause::'+whereClause);
            if(!String.isBlank(whereClause) && !String.isBlank(nameFilter)){
                String oppNameLike = '\'%' + nameFilter  + '%\'';
                if(whereClause!= 'WHERE '){
                	whereClause+=' and (name like '+oppNameLike+' or Account.Name like '+oppNameLike+')';
                }else{
                    whereClause+=' (name like '+oppNameLike+' or Account.Name like '+oppNameLike+')';
                }
            }
            setSession(off.Id);
            system.debug(loggingLevel.WARN, '----->> in changeCurrentListView, sortBy = ' + sortBy);

            return getKanbanWrapper(objName, objFields, kanbanField, whereClause, off.Name, showOnlyMyOpportunities, sortBy, isSortDesc);
        }
        catch (Exception ex) { // SRSF-1530 
            system.debug(loggingLevel.WARN, 'The following error occured getting proposals or Proposal Zones in changeCurrentListView: ' + ex.getMessage());
            //errorMessage = 'The following error has occurred: ' + ex.getMessage() + '.  Please contact your System Administrator.'; 
            //String errorMessage = 'Please contact your System Administrator. Too many Proposal Monthly Values have been returned.'; 
            String errorMessage = System.Label.TooMuchBroadcastDataExistsErrorMessage;
            return new kanbanWrapper(null, null, null, null, null, null, null, null, null, null, null, null, null, errorMessage, null, null, null);    
        }

   }

    @TestVisible private static String formatWhereClause(Opportunity_Forecasting_Filter__c listView) {
        String whereClause = 'WHERE ';
        if (listView == null) return 'ERROR';
        if (listView.Opportunity_Forecasting_Filter_Values__r == null) return 'ERROR';      // I think this is the right thing to do...
        system.debug('' + ListView.Scope__c);
        system.debug('==============>> ListView.User_List__c = ' + ListView.User_List__c);
       system.debug('==============>> ListView.Scope__c = ' + ListView.Scope__c);
        if (ListView.Scope__c == 'My Team') {
            system.debug(loggingLevel.WARN, '--------->> in My Team');
             List<OpportunityTeamMember> otms = [select Id, OpportunityId from OpportunityTeamMember where UserId = :UserInfo.getUserId()];
            if (otms.size() > 0) {
                whereClause += ' Id in (';
                for (OpportunityTeamMember otm : otms) {
                    whereClause += '\'' + otm.OpportunityId + '\', ';
                }
                system.debug(loggingLevel.WARN, '----->> whereClause before removeEnd = -' + whereClause + '-');
                whereClause = whereClause.removeEnd(', ');
                system.debug(loggingLevel.WARN, '----->> whereClause after  removeEnd = -' + whereClause + '-');
                whereClause += ') ';
            }
        } else if (ListView.Scope__c == 'Manager' && listView.User_List__c != null && listView.User_List__c.length() > 0) {   
            system.debug(loggingLevel.WARN, '--------->> in Manager!!!');
            List<String> userList = listView.User_List__c.split(',');
            system.debug('==============>> userList = ' + userList);
            if (userList.size() > 0) {
                Integer index = 0;
                String currentUser = UserInfo.getUserId();
                String theOwner = ListView.OwnerId;
                Integer indexToRemove;
                for (String theUser : userList) {
                    if (currentUser == theOwner && theUser != currentUser) {
                        indexToRemove = index;
                    } else if (currentUser != theOwner && theUser == currentUser) {
                        indexToRemove = index;
                    }
                    index++;
                }
                if (indexToRemove != null)
                    userList.remove(indexToRemove);
                Map<Id, User> userIds = new Map<Id, User>([select Id, Name from User where Id in :userList]);
                system.debug('==============>> userIds = ' + userIds);
                if (userIds.size() > 0) {
                    whereClause += ' OwnerId in (';
                    for (Id ownerId : userIds.keySet()) {
                        whereClause += '\'' + ownerId + '\', ';
                    }
                    whereClause = whereClause.removeEnd(', ');
                    whereClause += ') ';
                }
            }
             
        } else if (ListView.Scope__c == 'My Opportunities') {
            system.debug(loggingLevel.WARN, '--------->> in My Opportunities');
            whereClause += 'OwnerId = \'' + UserInfo.getUserId() + '\' ';
        }

        for (Opportunity_Forecasting_Filter_Values__c filter : listView.Opportunity_Forecasting_Filter_Values__r ) {
            system.debug(loggingLevel.WARN, '==========>> filter = ' + filter);

            if (filter.API_Name__c != null) {           // if there's no field name, there'll be no filtering on fields
                system.debug(loggingLevel.WARN, '$$$$$$$$$$$$$$$$$$$$$----->> whereClause = -' + whereClause + '-');
                if (whereClause != 'WHERE ') {
                    system.debug(loggingLevel.WARN, '*****>> adding "AND" #1');
                    whereClause += ' AND ';
                }

                    if (!whereClause.endsWith('AND ') && whereClause != 'WHERE ') {
                        system.debug(loggingLevel.WARN, '*****>> adding "AND" #2');
                        whereClause += ' AND ';
                    }
                    String sanitizedFilterField = filter.API_Name__c;
                    // TODO: need to handle these cases...
    /*
                    if (sanitizedFilterField == 'OPPORTUNITY.CLOSED') {     // Closed requires special handling
                        if ((filter.value == '1' && filter.Operator__c == 'equals')
                                || (filter.value == '0' && filter.Operator__c == 'notEqual')) {      // Oppty is closed
                            whereClause += 'STAGENAME LIKE \'Closed%\' ';
                        } else if ((filter.value == '0' && filter.Operator__c == 'equals')
                                || (filter.value == '1' && filter.Operator__c == 'notEqual')) {    // Oppty is open
                            whereClause += '(NOT STAGENAME LIKE \'Closed%\') ';
                        }    
                    } else if (sanitizedFilterField == 'OPPORTUNITY.WON') {     // Won also requires special handling
                        if ((filter.value == '1' && filter.Operator__c == 'equals')
                                || (filter.value == '0' && filter.Operator__c == 'notEqual')) {      // Oppty is won
                            whereClause += '(STAGENAME = \'Closed Won\') ';
                        } else if ((filter.value == '0' && filter.Operator__c == 'equals')
                                || (filter.value == '1' && filter.Operator__c == 'notEqual')) {    // Oppty not won
                            whereClause += '(STAGENAME != \'Closed Won\') ';
                        }    
                    } */

                    // handle date/time formatting
                    String filterValue = filter.Value__c;
                    system.debug(loggingLevel.WARN, '=======>> filterValue = ' + filterValue);
                    system.debug(loggingLevel.WARN, '=======>> filter.Field_Data_Type__c = ' + filter.Field_Data_Type__c);
                    if (filter.Field_Data_Type__c != null) {
                        String dataType = filter.Field_Data_Type__c.toUpperCase();
                        if (filter.Field_Data_Type__c.startsWith('DATE')) { 
                            system.debug(loggingLevel.WARN, '==============>> formatting DATE!!!'); 
                            if (filterValue != null && filterValue.countMatches('/') == 2) {    
                                filterValue = formatDateTime(filtervalue, filter.Field_Data_Type__c);
                            } else {
                                filterValue = formatSpecialDate(filterValue);
                            }
                        }                        
                    }

                    system.debug(loggingLevel.WARN, '--->> whereClause before = ' + whereClause);
                    whereClause += sanitizedFilterField + ' ';
                    if (filter.Operator__c == '=' || filter.Operator__c == 'equals') {
                        if (fieldIsString(filter.Field_Data_Type__c)) {
                            if (filterValue.contains(',')) {    // comman delimited list (hopefully)
                                whereClause += formatCSVList(filterValue, filter.Operator__c, false) + ' ';
                            } else {
                                String escapedValue = String.escapeSingleQuotes(filtervalue);
                                whereClause += '= \'' + escapedValue + '\' ';
                            }                            
                        }
                        else {
                            whereClause += '= ' + filtervalue + ' ';
                        }
                    } else if (filter.Operator__c == '!=' || filter.Operator__c == 'not equal to') {
                        if (fieldIsString(filter.Field_Data_Type__c)) {
                            if (filterValue.contains(',')) {    // comman delimited list (hopefully)
                                whereClause += formatCSVList(filterValue, filter.Operator__c, true) + ' ';
                                } else {
                                    String escapedValue = String.escapeSingleQuotes(filtervalue);
                                    whereClause += '!= \'' + filtervalue + '\' ';
                                }                          
                            }
                        else
                            whereClause += '!= ' + filtervalue + ' ';
                    }  else if (filter.Operator__c == '<' || filter.Operator__c == 'less than') {
                        whereClause += '< ' + filtervalue + ' ';
                    } else if (filter.Operator__c == '>' || filter.Operator__c == 'greater than') {
                        whereClause += '> ' + filtervalue + ' ';
                    } else if (filter.Operator__c == '<=' || filter.Operator__c == 'less or equal') {
                        whereClause += '<= ' + filtervalue + ' ';
                    } else if (filter.Operator__c == '>=' || filter.Operator__c == 'greater or equal') {
                        whereClause += '>= ' + filtervalue;
                    } else if (filter.Operator__c == 'contains') {
                        system.debug(loggingLevel.WARN, '================>> in contains!');
                        if (fieldIsString(filter.Field_Data_Type__c)) {
                            if (filterValue.contains(',')) {    // comman delimited list (hopefully)
                                system.debug(loggingLevel.WARN, '***** whereClause before = -' + whereClause + '-');
                                whereClause = whereClause.removeEnd(' ' + sanitizedFilterField + ' ');
                                system.debug(loggingLevel.WARN, '***** whereClause after removeEnd = -' + whereClause + '-');
                                whereClause += formatCSVList(sanitizedFilterField, filterValue, filter.Operator__c, false) + ' ';
                                system.debug(loggingLevel.WARN, '************ whereClause after = -' + whereClause + '-');
                                } else {
                                    String escapedValue = String.escapeSingleQuotes(filtervalue);
                                    whereClause += 'LIKE \'%' + escapedValue + '%\' ';
                                }                          
                            }
                            else if(filter.Field_Data_Type__c == 'PICKLIST') {

                                // item1+item2+item3 ---->  api_name__c IN ('item1' , 'item2' , 'item3')
                                whereClause += ' IN (';
                                String [] picklistVals = filterValue.split('\\+');
                                Boolean justStarted = true;
                                for(String picklistVal : picklistVals) {
                                    if(!justStarted) {
                                        whereClause += ', ' ;
                                    }
                                    whereClause += '\''+picklistVal+'\'' ;
                                    justStarted = false;
                                }
                                whereClause += ') ';
                            }
                        else
                            whereClause += 'LIKE \'%' + filtervalue + '%\' ';
                    } else if (filter.Operator__c == 'does not contain') {
                        system.debug(loggingLevel.WARN, '================>> in contains!');
                        if (fieldIsString(filter.Field_Data_Type__c)) {
                            system.debug(loggingLevel.WARN, '***** whereClause before = -' + whereClause + '-');
                            whereClause = whereClause.removeEnd(' ' + sanitizedFilterField + ' ');
                            system.debug(loggingLevel.WARN, '***** whereClause after removeEnd = -' + whereClause + '-');
                            system.debug(loggingLevel.WARN, '##############################################');
                            if (filterValue.contains(',')) {    // comman delimited list (hopefully)
                                system.debug(loggingLevel.WARN, '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$');
                                whereClause += formatCSVList(sanitizedFilterField, filterValue, filter.Operator__c, true) + ' ';
                                system.debug(loggingLevel.WARN, '************ whereClause after = -' + whereClause + '-');
                                } else {
                               //     whereClause += ' NOT (' + sanitizedFilterField + ' LIKE \'%' + filtervalue + '%\') ';
                                    String escapedValue = String.escapeSingleQuotes(filtervalue);
                                    whereClause += ' (NOT ' + sanitizedFilterField + ' LIKE \'%' + escapedValue + '%\') ';
                                }                          
                            } 
                        
                    } else {
                        whereClause += filter.Operator__c + filtervalue;
                    }
                   system.debug(loggingLevel.WARN, '--->> whereClause after = ' + whereClause);
                }                
        }

        return whereClause;
    }

    @TestVisible private static String formatCSVList(String value, string operator, Boolean notFlag) {  // method for = and !=
        String retVal;
        List<String> valueList = value.split(',');
        if (!notFlag) {             // equals
            retVal = ' IN (\'';
        } else if (notFlag) {       // not equal
            retVal = ' NOT IN (\'';
        }
        for (String val : valueList) {
           retVal += val.trim() + '\', \''; 
        }
        retVal = retVal.removeEnd(', \'') + ') ';

        return retVal;
    }

    @TestVisible private static String formatCSVList(String apiName, String value, String operator, Boolean notFlag) {  // method for contains and not contains
        String retVal;
        List<String> valueList = value.split(',');
        if (!notFlag) {             // contains
            retVal = ' (' + apiName + ' LIKE \'%';
            for (String val : valueList) {
               retVal += val.trim() + '%\' OR ' + apiName + ' LIKE \'%'; 
            }
            if (!notFlag) {
                retVal = retVal.removeEnd('OR ' + apiName + ' LIKE \'%') + ') ';
            }
        } else if (notFlag) {       // does not contain - format like this: WHERE  (NOT FirstName LIKE '%ret%') AND (NOT FirstName LIKE '%aur%')
            retVal = ' (NOT ' + apiName + ' LIKE \'%';
            for (String val : valueList) {
                retVal += val + '%\') AND (NOT ' + apiName + ' LIKE \'%'; 
            }
            retVal = retVal.removeEnd('AND (NOT ' + apiName + ' LIKE \'%') + ' ';
            system.debug(loggingLevel.WARN, '%%%%%%%%%%% retVal = ' + retVal);
        } 

        return retVal;

    }

    @AuraEnabled public static Boolean isCurrentUserAdmin() {
        String adminProfiles = System.Label.Filter_View_Admin_Profiles;
        List<String> apList = adminProfiles.split(',');
        Set<String> apSet = new Set<String>();
        apSet.addAll(apList);
        system.debug(loggingLevel.WARN, '---------->> in isCurrentUserAdmin, apSet = ' + apSet);
        User usrProfileName = [select u.Profile.Name, u.userRole.Name, u.Team_Role__c from User u where u.id = :Userinfo.getUserId()];
        system.debug(loggingLevel.WARN, '---------->> in isCurrentUserAdmin, usrProfileName = ' + usrProfileName.Profile.Name);
        Boolean retVal = apSet.contains(usrProfileName.Profile.Name);
        system.debug(loggingLevel.WARN, '---------->> in isCurrentUserAdmin, retVal = ' + retVal);
      return (retVal);
  }

    @AuraEnabled public static kanbanWrapper createFilter(String filterName, String filterAudience, Boolean showMineOnly) {
        system.debug(loggingLevel.WARN, '=========>> in createFilter, filterName = ' + filterName);
        system.debug(loggingLevel.WARN, '=========>> in createFilter, visibility = ' + showMineOnly);
        system.debug(loggingLevel.WARN, '=========>> in createFilter, filterAudience = ' + filterAudience);
        if (filterName == null || filterName == '') return null;
        kanbanWrapper returnValue = new kanbanWrapper();
        Opportunity_Forecasting_Filter__c off = new Opportunity_Forecasting_Filter__c();
        off.Name = filterName;
        if (filterAudience != null && filterAudience == 'All') {
            off.Visible_To_All_Users__c = true;
        } else if (filterAudience != null && filterAudience == 'Manager') {
            off.Visible_To_List_of_Users__c = true;
            off.User_List__c = getManagerString();
        } else {
            off.Visible_To_Me__c = true;
        }
        if (!showMineOnly) {
            off.Scope__c = 'All Opportunities';
        } else {
            off.Scope__c = 'My Opportunities';
        }
        insert off;
        String whereClause = formatWhereClause(off);                                                                                                
        return returnValue;
    }

    @AuraEnabled public static List<filterFields> getOpptyFields() {
        system.debug(loggingLevel.WARN, '===========>> in getOpptyFields');
        List<filterFields> opptyFields = new List<filterFields>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get('Opportunity');
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        List<String> sortedList = new List<String>();
        List<String> labelList = new List<String>();
        for (String fieldName : fieldMap.keySet()) {
            labelList.add(fieldMap.get(fieldName).getDescribe().getLabel() + '~@#' + fieldMap.get(fieldName).getDescribe().getName());
        }
        labelList.sort();
        for (String field : labelList) {
            List<String> fieldToApi = field.split('~@#');
            if (fieldToApi != null && fieldToApi.size() > 1) {
                sortedList.add(fieldToApi[1]);
            }
        }

        for (String fieldName: sortedList) {
            if (fieldMap.get(fieldName).getDescribe().isAccessible() && fieldMap.get(fieldName).getDescribe().isFilterable()) {
                filterFields filterField = new filterFields();
                filterField.label = fieldMap.get(fieldName).getDescribe().getLabel();
                filterField.ApiName = fieldMap.get(fieldName).getDescribe().getName();
                filterField.dataType = fieldMap.get(fieldName).getDescribe().getType().name();
                opptyFields.add(filterField);           
            }

        }
        system.debug(loggingLevel.WARN, '=============>> opptyFields = ' + opptyFields);
        return opptyFields;
    }

    @TestVisible private static String getListViewDevName(String listViewId) {
        system.debug(loggingLevel.WARN, '--------------->> listViewId = ' + listViewId);
        List<ListView> lvList = [select Id, DeveloperName from ListView where SobjectType = 'Opportunity' and Id = :listViewId];
        system.debug(loggingLevel.WARN, '========>> lvList = ' + lvList);
        if (lvList.size() > 0)
            return 'Opportunity.' + lvList[0].DeveloperName;
        return 'Opportunity.MyOpportunities';   // default to my Opportunities list
    }

    @TestVisible private static String formatToSimpleDate(Date dateVar) {
        return (dateVar.month() < 10 ? '0': '') +  dateVar.month() + '/' + (dateVar.day() < 10 ? '0' : '') + dateVar.day() + '/' + dateVar.year();
    }

    @TestVisible private static String formatSpecialDate(String dtStr) {
        system.debug(loggingLevel.WARN, '-------->> in formatSpecialDate, dtStr = ' + dtStr);
        String fomrattedDT;
        if (dtStr == null) return 'ERROR: Badly formatted date string';
        if (dtStr.containsAny('0123456789')) {
            List<String> dateParts = dtStr.split(' ');
            if (dateParts.size() < 3) return 'ERROR: Badly formatted date string';
            fomrattedDT = dateParts[0] + '_N_' + dateParts[2] + ':' + dateParts[1];
        } else  {
            system.debug(loggingLevel.WARN, '-------->> in formatSpecialDate, fomrattedDT(0) = ' + fomrattedDT);
            fomrattedDT = dtStr.replaceAll(' ', '_');
        }
        system.debug(loggingLevel.WARN, '-------->> in formatSpecialDate(1), fomrattedDT = ' + fomrattedDT);
        return fomrattedDT;
    }

    @TestVisible private static String formatDateTime(String dtStr, String dataType) {
        String fomrattedDT;
        DateTime dt;
        List<String> dateParts = dtStr.split('/');
        
        system.debug(loggingLevel.WARN, '-------->> dateParts = ' + dateParts);

        dt = DateTime.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), 0, 0, 0);
        if (dataType == 'DATETIME')
            fomrattedDT = dt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        else
            fomrattedDT = dt.format('yyyy-MM-dd');
        system.debug(loggingLevel.WARN, '-------->> fomrattedDT = ' + fomrattedDT);
        return fomrattedDT;
    }

 /*   @TestVisible private static String sanitizeMetaDataNames(String MDName) {
        List<OpportunityAPIFieldMapping__c> nameList = OpportunityAPIFieldMapping__c.getAll().values();
        for (OpportunityAPIFieldMapping__c mapping : nameList) {
            if (mapping.Name == MDName)
                return mapping.Opportunity_API_Name__c;
        }
        return MDName;
    }
*/

    @TestVisible private static Boolean fieldIsString(String dataType) {
        if (dataType == null) return false;
        Set<String> stringDataTypes = new Set<String>{'REFERENCE', 'ID', 'STRING'};     // PICKLIST???
        if (stringDataTypes.contains(dataType))
            return true;
        return false;        
    }
/*
    private static Boolean fieldIsString(String MDName) {
        List<OpportunityAPIFieldMapping__c> nameList = OpportunityAPIFieldMapping__c.getAll().values();
        for (OpportunityAPIFieldMapping__c mapping : nameList) {
            if (mapping.Name == MDName && mapping.isString__c == true)
                return true;
        }
        return false;        
    }
*/    
    @AuraEnabled
    public static String getUpdateStage(Id recId, String kanbanField, String kanbanNewValue, String lossReasonField, String lossReason) {
        SObject o1 = recId.getSObjectType().newSObject(recId);
        // check kanbanNewValue and set to "Closed Lost" if kanbanNewValue == "Closed Lost From Competitor"
        if (lossReason != null && lossReason != '' && lossReason != '--None--') {
            o1.put(lossReasonField, lossReason);
        }
        o1.put(kanbanField,kanbanNewValue);
        update o1;
        return 'Success';
    }

    @AuraEnabled public static Map<String, Opportunity_Forecasting_Filter__c> getOpptyListViews() {
        String likeUser = '%' + UserInfo.getUserId() + '%';
        Map<String, Opportunity_Forecasting_Filter__c> userListViews = new Map<String, Opportunity_Forecasting_Filter__c>();
        List<Opportunity_Forecasting_Filter__c> listViews = [select Id, Name, Visible_To_All_Users__c, Visible_To_List_of_Users__c, Visible_To_Me__c, Visitble_To_My_Team__c, User_List__c, OwnerId,
                                                                (select Id, API_Name__c, Field_Data_Type__c, Field_Name__c, Operator__c, Value__c from Opportunity_Forecasting_Filter_Values__r)
                                                                from Opportunity_Forecasting_Filter__c where (ownerId = :UserInfo.getUserId() 
                                                                                                                OR Visible_To_All_Users__c = true
                                                                                                                OR (Visible_To_List_of_Users__c = true AND User_List__c like :likeUser))
                                                                                                                ORDER BY Name];

        for (Opportunity_Forecasting_Filter__c listView : listViews)
        {
            System.debug(loggingLevel.WARN, 'List View Name  = ' + listView.Id);
            System.debug(loggingLevel.WARN, 'List View Label = ' + listView.Name);
            userListViews.put(listView.Id, listView);
        }
        return userListViews;
    }

    @AuraEnabled public static kanbanWrapper saveFilterData(String filterName, String filterChangedName, Boolean isNew, Boolean isClone,
                                                            String filterAudience, Boolean showOnlyMyOpportunities, String userList, 
                                                            String apiName1, String label1, String operator1, String value1, String dataType1,
                                                            String apiName2, String label2,  String operator2, String value2, String dataType2,
                                                            String apiName3, String label3,  String operator3, String value3, String dataType3) {

        system.debug(loggingLevel.WARN, '*********************** in saveFilterData!!!');
        system.debug(loggingLevel.WARN, '--->> filterName = ' + filterName);
        system.debug(loggingLevel.WARN, '--->> filterChangedName = ' + filterChangedName);
        system.debug(loggingLevel.WARN, '------------------------->> filterAudience = ' + filterAudience);
        system.debug(loggingLevel.WARN, '--->> showOnlyMyOpportunities = ' + showOnlyMyOpportunities);
        kanbanWrapper returnValue = new kanbanWrapper();    // this is only used for error messages
        Opportunity_Forecasting_Filter__c clonedFilter;
        Id filterId;
        String massagedFilterName;
        String managerAndMe = '';
        if (filterName == null || filterName == '') {
                returnValue.errorMessage =  'ERROR: Filter Name null or blank';
                return returnValue;
        }
        if (filterAudience != null) {
            if (filterAudience == 'All') {
                if (!isCurrentUserAdmin()) {
                    system.debug(loggingLevel.WARN, '--->> User is not an admin!!!');
                    returnValue.errorMessage = 'ERROR: Only Admin users can create filter views visible to all users.';
                    return returnValue;
                } else if (filterAudience == 'Manager' && isNew) {
                managerAndMe = getManagerString();
                } else if (filterAudience == 'Me' && filterName == 'My Opportunities' && !isNew) {
                    returnValue.errorMessage = 'ERROR: The "My Opportunities" filter cannot be overwritten.';
                    return returnValue;
                }
            }
        }

        system.debug(loggingLevel.WARN, '--->> Doing the query to see if the filter exists...');
        List<Opportunity_Forecasting_Filter__c> offList = [select Id, Name, Scope__c, Visible_To_All_Users__c, Visible_To_List_of_Users__c, Visible_To_Me__c, Visitble_To_My_Team__c, User_List__c, OwnerId 
                                                            from Opportunity_Forecasting_Filter__c where name = :filterName];

        if (isNew) {
            system.debug(loggingLevel.WARN, '--->> in isNew...');
            if (offList.size() > 0) {
                returnValue.errorMessage =  'ERROR: Duplicate filter view name.  Please rename or edit the exiting filter view.';
                return returnValue;
            } else {
                system.debug(loggingLevel.WARN, '--->> calling createFilter');
                return createFilter(filterName, filterAudience, true);
            }
        }
        
        Opportunity_Forecasting_Filter__c off = offList[0];

        // clear existing visibility and User List (SRSF-375)
        off.Visible_To_All_Users__c = false; 
        off.Visible_To_List_of_Users__c = false; 
        off.Visible_To_Me__c = false;     
        off.User_List__c = '';

        // update visibility (audience)
        if (filterAudience == 'All') {
            off.Visible_To_All_Users__c = true;
        } else if (filterAudience == 'Manager') {
            off.Visible_To_List_of_Users__c = true;
            off.User_List__c = getManagerString();
        } else {        // default to visibility only to me
            off.Visible_To_Me__c = true;
        }

        off.Scope__c = showOnlyMyOpportunities ? 'My Opportunities' : 'All Opportunities';

       if (!isNew && filterChangedName != null && filterChangedName != '' && filterChangedName != filterName) {
            off.Name = filterChangedName;
            List<Opportunity_Forecasting_Filter__c> offList2 = [select Id from Opportunity_Forecasting_Filter__c where name = :filterChangedName];

            if (offList2.size() > 0) {
            returnValue.errorMessage =  'ERROR: Duplicate filter view name.  Please rename or edit the exiting filter view.';
            return returnValue;
            }
        }
        try {
            if (!isClone) {
                upsert off;
                filterId = off.Id;
                massagedFilterName = off.Name;
            } else {
                clonedFilter = off.clone(false, true, false, false);
                clonedFilter.Name = filterChangedName;
                massagedFilterName = clonedFilter.Name;
                clonedFilter.ownerId = UserInfo.getUserId();
                insert clonedFilter;
                filterId = clonedFilter.Id;
                system.debug(loggingLevel.WARN, '====================>> clonedFilter = ' + clonedFilter);
            }
        } catch (Exception ex) {
            returnValue.errorMessage = 'ERROR occured updating filter: ' + ex.getMessage();
            return returnValue;
        }

        List<Opportunity_Forecasting_Filter_Values__c> existingoffvs = [select Id from Opportunity_Forecasting_Filter_Values__c where Opportunity_Forecasting_Filter__c = :off.Id AND API_Name__c != null];
        if (existingoffvs.size() > 0 && !isClone) {
            try {
               delete existingoffvs; 
               } catch (Exception ex) {
                    returnValue.errorMessage =  'ERROR occured removing old filter values: ' + ex.getMessage();
                    return returnValue;
               }
        } 
        system.debug(loggingLevel.WARN, '=========>> apiName1 = ' + apiName1);
        system.debug(loggingLevel.WARN, '=========>> operator1 = ' + operator1);
        system.debug(loggingLevel.WARN, '=========>> value1 = ' + value1);
        system.debug(loggingLevel.WARN, '=========>> dataType1 = ' + dataType1);
        system.debug(loggingLevel.WARN, '=========>> filterAudience = ' + filterAudience);
        system.debug(loggingLevel.WARN, '=========>> apiName2 = ' + apiName2);
        system.debug(loggingLevel.WARN, '=========>> operator2 = ' + operator2);
        system.debug(loggingLevel.WARN, '=========>> value2 = ' + value2);
        system.debug(loggingLevel.WARN, '=========>> dataType2 = ' + dataType2);
        system.debug(loggingLevel.WARN, '=========>> filterAudience = ' + filterAudience);
        system.debug(loggingLevel.WARN, '=========>> apiName3 = ' + apiName3);
        system.debug(loggingLevel.WARN, '=========>> operator3 = ' + operator3);
        system.debug(loggingLevel.WARN, '=========>> value3 = ' + value3);
        system.debug(loggingLevel.WARN, '=========>> dataType3 = ' + dataType3);
        system.debug(loggingLevel.WARN, '=========>> filterAudience = ' + filterAudience);
        List<Opportunity_Forecasting_Filter_Values__c> offvList = new List<Opportunity_Forecasting_Filter_Values__c>();
        if (apiName1 <> null && apiName1 != '') {
            Opportunity_Forecasting_Filter_Values__c offv = new Opportunity_Forecasting_Filter_Values__c();
            offv.API_Name__c = apiName1;
            offv.Field_Name__c = label1;
            offv.Operator__c = operator1;
            offv.Value__c = value1;
            offv.Field_Data_Type__c = dataType1;
            offv.Opportunity_Forecasting_Filter__c = filterId;
            offvList.add(offv);
        }
        if (apiName2 <> null && apiName2 != '') {
            Opportunity_Forecasting_Filter_Values__c offv = new Opportunity_Forecasting_Filter_Values__c();
            offv.API_Name__c = apiName2;
            offv.Field_Name__c = label2;
            offv.Operator__c = operator2;
            offv.Value__c = value2;
            offv.Field_Data_Type__c = dataType2;
            offv.Opportunity_Forecasting_Filter__c = filterId;
            offvList.add(offv);
        }
        if (apiName3 <> null && apiName3 != '') {
            Opportunity_Forecasting_Filter_Values__c offv = new Opportunity_Forecasting_Filter_Values__c();
            offv.API_Name__c = apiName3;
            offv.Field_Name__c = label3;
            offv.Operator__c = operator3;
            offv.Value__c = value3;
            offv.Field_Data_Type__c = dataType3;
            offv.Opportunity_Forecasting_Filter__c = filterId;
            offvList.add(offv);
        }
        if (offvList.size() > 0) {
            try {
                system.debug(loggingLevel.WARN, '------------>> offvList = ' + offvList);
                upsert offvList;
            }  catch (Exception ex) {
                returnValue.errorMessage = 'ERROR occured inserting new filter values: ' + ex.getMessage();
                return returnValue;
           }      
        }
            return new kanbanWrapper();
    }

    @TestVisible private static String getManagerString() {
        Id managerId = Id.ValueOf(UserInfo.getUserId());
        system.debug('--------------->> UserInfo.getUserId()' + UserInfo.getUserId());
        system.debug('--------------->> managerId' + managerId);
        String managerAndMe = UserInfo.getUserId();
        User curUser = [select Id, Name, Approving_Manager__c from User where Id = :managerId];
        if (curUser.Approving_Manager__c != null) {
            system.debug(loggingLevel.WARN, '------------>> curUser.Approving_Manger__c = ' + curUser.Approving_Manager__c);
            User manager = [select Id, Name from User where Id = :curUser.Approving_Manager__c];
            if (manager.Name != null && manager.Name != '')
                managerAndMe +=  ',' + curUser.Approving_Manager__c;
        } 
        return managerAndMe;
    }

    @TestVisible private static List<String> getPickListValues(String whichPL) {
        List<String> pickListVals;
        if (whichPL == null || whichPL == '')
            return pickListVals;
        pickListVals = new List<String>();
        for (Schema.PicklistEntry ple : Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().get(whichPL).getDescribe().getPickListValues()) {
            pickListVals.add(ple.getValue());
        }
        return pickListVals;
    } 

    @TestVisible private static List<String> getOpptyRecordTypes() {
        List<String> recTypeList = new List<String>();
        Schema.DescribeSObjectResult R = Opportunity.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> rtList = R.getRecordTypeInfos();
        for (Schema.RecordTypeInfo rt : rtList ) {
            if (rt.isAvailable())
                recTypeList.add(rt.getName());
        }
        return recTypeList;
    }


    // remember User's "Last List View" for up to 30 minutes
    @TestVisible private static void setSession(Id oppFilterID) {
        String cacheKey = 'local.CNAPartition.' + userinfo.getUserId() + 'listView';
        Cache.Session.put(cacheKey, oppFilterID, 30*60, Cache.Visibility.All, false);
    }

    @TestVisible private static Id getSession() {
        String cacheKey = 'local.CNAPartition.' + userinfo.getUserId() + 'listView';
        if(Cache.Session.contains(cacheKey)) {
            return (Id)Cache.Session.get(cacheKey);
        }
        else {
            return null;
        }
  }

    public class ListViewFilter {
        @AuraEnabled public String field;
        @AuraEnabled public String operation;
        @AuraEnabled public String value;
    }

    public class filterFields {
        @AuraEnabled public String label;
        @AuraEnabled public String ApiName;
        @AuraEnabled public String dataType;
    }

    public class filterRule {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String operator;
        @AuraEnabled public String ApiName;
        @AuraEnabled public String dataType;
    }

    public class OpptyListView {
        @AuraEnabled public String listViewName;
        @AuraEnabled public ListViewFilter[] listViewFilters;
    }
    
    public class broadcastValuesWrapper {
        @AuraEnabled public Id OpptyId;
        @AuraEnabled public Map<String, Decimal> broadcastMonthGrossValues;
        @AuraEnabled public Map<String, Decimal> broadcastMonthForecastValues;
        @AuraEnabled public Map<String, Decimal> broadcastMonthNetValues;
    }
    
    public class kanbanWrapper{
        @AuraEnabled public List<sObject>                  records {get;set;}                  // the opportunity records
        @AuraEnabled public List<String>                   pickVals {get;set;}                 // List of opportunity stages to be displayed
        @AuraEnabled public Map<String, Decimal>           stageTotals {get;set;}              // map of stage name to total amount for the opptys in that stage
        @AuraEnabled public Map<String, Decimal>           pendingTotals {get;set;}            // map of stage names to pending amount total for the opptys in that stage
        @AuraEnabled public List<Decimal>                  objTotals {get;set;}                // not currently used
        @AuraEnabled public Map<String, Integer>           opptyCounts {get;set;}              // map of stage names to count of opptys for that stage
        @AuraEnabled public List<broadcastValuesWrapper>   broadcastMonthValues {get;set;}     // List of broadcast monthly values - not currently used by the GUI, consider removing
        @AuraEnabled public Map<String, Integer>           probabilityMap {get;set;}           // map of stage name to the probability of closing for each oppty stage  
                                                                                        // may want to remove the probability map in the future due to SRSF-1131    
        @AuraEnabled public String                         filterVisibility {get;set;}         // visibility of the filter. Valid values are All, Manager, or Me
        @AuraEnabled public Boolean                        showOnlyMyOpportunities {get;set;}  // whether to show all opptys or my opptys.  My opptys includes visibility of Me or Manager, which means the view is available to the user and the users manager
        @AuraEnabled public List<filterRule>               filterRules {get;set;}              // List of filterRules associated with this list view         
        @AuraEnabled public String                         errorMessage {get;set;}             // an error message to display to the user
        @AuraEnabled public String                         listViewName {get;set;}             // the list view name
        @AuraEnabled public Map<String, Boolean>           recordAccessMap {get;set;}          // map of oppty Ids to a boolean that determines whether the user has edit access to that record or not
        @AuraEnabled public List<String>                   oppsEditableByUser {get;set;}       // list of Ids of opptys the user is on the oppty team of
        @AuraEnabled public List<String>                   PickList_BillTo {get;set;}          // all PickList_* fields are the picklist values for that field
        @AuraEnabled public List<String>                   PickList_Type {get;set;}
        @AuraEnabled public List<String>                   PickList_RecordType {get;set;}
        @AuraEnabled public List<String>                   PickList_Owner_Sales_Office {get;set;}
        @AuraEnabled public List<String>                   PickList_Region {get;set;}
        @AuraEnabled public List<String>                   PickList_Division {get;set;}
        @AuraEnabled public Integer                        numOppsReturned  {get;set;}         // the count of opptys returned to the GUI
        @AuraEnabled public Integer                        numOppsFound  {get;set;}            // the total count the query would return if not limited to 200
        @AuraEnabled public String                         numOppsFoundStr  {get;set;}         // the string to display to the user of how many opptys were found.  If over 2000, will just contain 2000+
        @AuraEnabled public List<String>                   PickList_LossReason {get;set;}

        
        public kanbanWrapper(List<sObject> recs, List<String> pVals, Map<String, Decimal> pStageTots, Map<String, Decimal> pPendingTots, 
                                List<Decimal> OobjTotals, Map<String, Integer> oppCounts, 
                                List<broadcastValuesWrapper> pBcastValues, Map<String, Integer>pProbMap, 
                                String fVisibilty, Boolean fShowOnlyMyOpportunities, List<filterRule> fRules, 
                                Map<String, Boolean> pRecAccessMap, List<String> budgAccess, String err, String lvName,
                                Integer pnumOppsFound, String pnumOppsFoundStr){
            this.listViewName = lvName;     // the name of the list view
            this.records = recs;            
            this.pickVals = pVals;          
            this.stageTotals = pStageTots;  
            this.pendingTotals = pPendingTots;  
            if (this.stageTotals != null)
                this.objTotals = pStageTots.values();
            this.opptyCounts = oppCounts;       
            this.broadcastMonthValues = pBcastValues;
            this.probabilityMap = pProbMap;
            this.filterVisibility = fVisibilty;
            this.showOnlyMyOpportunities = fShowOnlyMyOpportunities;
            this.filterRules = fRules;
            this.recordAccessMap = pRecAccessMap;
            this.oppsEditableByUser = budgAccess;
            this.errorMessage = err;
            this.PickList_BillTo = getPickListValues('Bill_To__c');
            this.PickList_Type   = getPickListValues('Type');
            this.PickList_Owner_Sales_Office = getPickListValues('Owner_Sales_Office__c');
            this.PickList_Region = getPickListValues('Owner_Region__c');
            this.PickList_Division = getPickListValues('Owner_Division__c');
            this.PickList_RecordType = getOpptyRecordTypes();
            this.PickList_LossReason = getPickListValues('Loss_Reason__c');

            this.numOppsReturned = (recs != null) ? recs.size() : 0;
            this.numOppsFound = pnumOppsFound;
            this.numOppsFoundStr = pnumOppsFoundStr;
        }

        public kanbanWrapper(){}
    }

}