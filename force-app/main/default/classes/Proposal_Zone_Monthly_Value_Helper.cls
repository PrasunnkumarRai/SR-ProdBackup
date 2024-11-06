/*
  ###########################################################################
  # File..................: Proposal_Zone_Monthly_Value_Helper.cls
  # Version...............: 1
  # Created by............: Sanchit Singhal   
  # Created Date..........: 29-March-2017
  # Last Modified by......: Puneet Khosla
  # Last Modified Date....: 13-Jul-18
  # Description...........: This class contains helper methods for Proposal and Proposal Zone Monthly Value Triggers
  # TAO Ref#..............: NA
  # Change Log:               
  # 1. Puneet Khosla - 19-Jun-18 - Changes done under SRSF-1072
  # 2. Puneet Khosla - 13-Jul-18 - Changes done under SRSF-1150
  ############################################################################*/
public class Proposal_Zone_Monthly_Value_Helper {

    /*
      Method invoked after Insert event
     */
    public static void afterInsert(List<Proposal_Zone_Monthly_Value__c> newList, Map<Id, Proposal_Zone_Monthly_Value__c> oldMap) {
        //Set<String> lineKeys = new Set<String>();
        Set<Id> accIds = new Set<Id> ();
        for (Proposal_Zone_Monthly_Value__c schedule : newList) {
            //lineKeys.add(schedule.Schedule_Key__c);
            accIds.add(schedule.Advertiser__c);
        }
        //calculateForecastedAmount(lineKeys);
        updateLastScheduleDate(accIds);
    }


    /*
      Method invoked after Update event
     */
    public static void afterUpdate(List<Proposal_Zone_Monthly_Value__c> newList, Map<Id, Proposal_Zone_Monthly_Value__c> oldMap) {
        //Set<String> lineKeys = new Set<String>();
        Set<Id> accIds = new Set<Id> ();
        for (Proposal_Zone_Monthly_Value__c schedule : newList) {
            //if (schedule.Net_Amount__c != oldMap.get(schedule.Id).Net_Amount__c)
            //    lineKeys.add(schedule.Schedule_Key__c);
            Proposal_Zone_Monthly_Value__c oldSch = oldMap.get(schedule.id);

            if (oldSch == null ||
            (schedule.Broadcast_Month_Date__c != oldSch.Broadcast_Month_Date__c &&
             schedule.Net_Amount__c != oldSch.Net_Amount__c &&
             schedule.IsActive__c != oldSch.IsActive__c)
            )
            {
                accIds.add(schedule.Advertiser__c);
            }


        }
        //calculateForecastedAmount(lineKeys);
        updateLastScheduleDate(accIds);
    }


    /*
      Method invoked after Delete event
     */
    public static void afterDelete(Map<Id, Proposal_Zone_Monthly_Value__c> oldMap) {
        //Set<String> lineKeys = new Set<String>();
        List<Id> pzmvIdList = new List<Id> ();
        Set<Id> accIds = new Set<Id> ();
        for (Proposal_Zone_Monthly_Value__c schedule : oldMap.values()) {
            //lineKeys.add(schedule.Schedule_Key__c);
            pzmvIdList.add(schedule.Id);
            accIds.add(schedule.Advertiser__c);
        }
        //calculateForecastedAmount(lineKeys);
        updateLastScheduleDate(accIds);
        UtilityClass.emptyRecycleBin(pzmvIdList);
    }


    /*
      Method to refresh aggregated Amounts for User
     */
    public static void refreshAmounts(List<Id> proposals) {
        /*Set<String> lineKeys = new Set<String>();
          for (Proposal_Zone_Monthly_Value__c schedule : [SELECT Id,Schedule_Key__c FROM Proposal_Zone_Monthly_Value__c WHERE Proposal_Key_Index__c IN :proposals]){
          lineKeys.add(schedule.Schedule_Key__c);
          }*/
        //calculateForecastedAmount(lineKeys);
    }


    /*
      Method to update Last Scheduled Date on Account
     */
    private static void updateLastScheduleDate(Set<Id> accountsList) {
        Map<Id, Account> accountMap = new Map<Id, Account> ([SELECT Id, Last_Client_Schedule_Date__c FROM Account WHERE Id IN :accountsList]);
        AggregateResult[] lineResults = [SELECT MAX(End_Date__c) maxDate, Advertiser__c accId FROM Proposal__c WHERE Advertiser__c IN :accountsList GROUP BY Advertiser__c];
        if (null != lineResults && lineResults.size() > 0) {
            List<Account> updateList = new List<Account> ();
            for (AggregateResult ar : lineResults)
            {
                Id accountId = (Id) ar.get('accId');
                Date lastClientScheduleDate = (Date) ar.get('maxDate');
                Date currentDate = (accountMap.containsKey(accountId)) ? accountMap.get(accountId).Last_Client_Schedule_Date__c : Date.today();

                if (currentDate != lastClientScheduleDate)
                {
                    Account acc = new Account(Id = accountId, Last_Client_Schedule_Date__c = lastClientScheduleDate);
                    updateList.add(acc);
                }
            }
            if (updateList.size() > 0)
            update updateList;
        }
    }


    /*
      Method to calculate aggregated Amounts for User
     */
    //private static void calculateForecastedAmount(Set<String> lineKeys){
    /*Map<String,Forecast_Aggregation__c> forecastRecordsMap = new Map<String,Forecast_Aggregation__c>();
      Set<String> timRejectedStatuses = new Set<String>(System.Label.Rejected_TIM_Statuses.split(','));
      for (Forecast_Aggregation__c record : [SELECT Id,Forecast_Amount__c,Forecast_Key__c FROM Forecast_Aggregation__c WHERE Forecast_Key_Index__c IN :lineKeys]){
      //Reset the record amount
      record.Forecast_Amount__c = 0;
      forecastRecordsMap.put(record.Forecast_Key__c,record);
      }
      Set<String> closedlostStatus = new Set<String>(System.Label.Closed_Lost_Label.split(','));
      for (Proposal_Zone_Monthly_Value__c schedule : [SELECT Id,Schedule_Key__c,Opportunity__r.StageName,Proposal_Status__c,Net_Amount__c,Opportunity__c FROM Proposal_Zone_Monthly_Value__c WHERE Schedule_Key_Index__c IN :lineKeys AND Proposal_Active__c = true AND Opportunity__r.StageName NOT IN :closedlostStatus]){
      Forecast_Aggregation__c record = forecastRecordsMap.get(schedule.Schedule_Key__c);
      if (record == null){
      //Create a new record
      record = createNewAggregateRecord(schedule.Schedule_Key__c);
      forecastRecordsMap.put(schedule.Schedule_Key__c,record);
      }
      if (schedule.Opportunity__r.StageName == System.Label.Closed_Won_Label){
      // If opportunity is marked as Closed Won then amounts for Proposal having these statuses are not to be considered while aggregating amounts
      if (!timRejectedStatuses.contains(schedule.Proposal_Status__c)){
      record.Forecast_Amount__c += schedule.Net_Amount__c;
      }
      }else{
      record.Forecast_Amount__c += schedule.Net_Amount__c;
      }
      }
     
      if (forecastRecordsMap.values().size() > 0)
      upsert forecastRecordsMap.values();*/
    //}


    /*
      Method to create new Aggregation record
     
      private static Forecast_Aggregation__c createNewAggregateRecord(String key){
      Forecast_Aggregation__c aRecord = new Forecast_Aggregation__c();
      String accId = key.left(18);
      String aeId = key.mid(18,18);
      String month = key.mid(36,2);
      String year = key.right(4);
      aRecord.Account__c = accId;
      aRecord.Account_Executive__c = aeId;
      aRecord.Broadcast_Month_Date__c = Date.newInstance(Integer.valueOf(year),Integer.valueOf(month),15);
      aRecord.Forecast_Amount__c = 0;
      return aRecord;
      }*/


    /*
      Method invoked on before Insert event
     */
    public static void beforeInsert(List<Proposal_Zone_Monthly_Value__c> newList, Map<Id, Proposal_Zone_Monthly_Value__c> oldMap) {
        setLookups(newList);
        calculateNetAmount(newList);
        for (Proposal_Zone_Monthly_Value__c schedule : newList)
        {
            if (schedule.Broadcast_Month_Date__c != null)
            {
                schedule.Last_Broadcast_Date__c = getLastBroadcastDate(schedule.Broadcast_Month_Date__c);
            }
        }
    }


    /*
      Method invoked on before Update event
     */
    public static void beforeUpdate(List<Proposal_Zone_Monthly_Value__c> newList, Map<Id, Proposal_Zone_Monthly_Value__c> oldMap) {
        setLookups(newList);
        calculateNetAmount(newList);

        for (Proposal_Zone_Monthly_Value__c schedule : newList)
        {
            Proposal_Zone_Monthly_Value__c oldSch = oldMap.get(schedule.Id);
            if (schedule.Broadcast_Month_Date__c != null && (schedule.Last_Broadcast_Date__c == null || oldSch == null || schedule.Broadcast_Month_Date__c != oldSch.Broadcast_Month_Date__c))
            {
                schedule.Last_Broadcast_Date__c = getLastBroadcastDate(schedule.Broadcast_Month_Date__c);
            }
        }
    }


    /*
      Method to calculate Net Amount from Gross Amount
     */
    private static void calculateNetAmount(List<Proposal_Zone_Monthly_Value__c> newList) {
        Map<String, ProposalYearlyDiscount__c> custSettMap = ProposalYearlyDiscount__c.getAll();

        try {
            for (Proposal_Zone_Monthly_Value__c pls : newList) {
                if (pls.Gross_Amount__c != null) {
                    /*if (pls.Proposal_Type__c != 'Opportunity Budget'){
                      Decimal agentDiscountValue = 0;
                      if(pls.opportunity_agency__c != null){
                      agentDiscountValue = pls.Gross_Amount__c/100 * Integer.valueOf(System.label.agentDiscount);
                      }
                     
                      Decimal repDiscountValue = 0;
                      if(pls.Opportunity_Rep_Firm__c != null){    
                      repDiscountValue = pls.Gross_Amount__c/100 * custSettMap.get(String.valueOf(Date.today().year())).discount__c;
                      }
                     
                      pls.Net_Amount__c = pls.Gross_Amount__c - agentDiscountValue - repDiscountValue;
                      }else{*/
                    /* Commented for SRSF-1945 changes : 25-10-2019    
                      Decimal agentDiscountValue = 0;
                      if(pls.opportunity_agency__c != null){
                      agentDiscountValue = pls.Gross_Amount__c/100 * pls.Opportunity_Agency_Discount__c;
                      }
                      pls.Net_of_Agency__c = pls.Gross_Amount__c - agentDiscountValue;
                      System.debug(agentDiscountValue);
                      Decimal repDiscountValue = 0;
                      if(pls.Opportunity_Rep_Firm__c != null){    
                      repDiscountValue = pls.Net_of_Agency__c/100 * pls.Opportunity_RepFirm_Discount__c;
                      }
                      //pls.Net_Amount__c = pls.Gross_Amount__c - agentDiscountValue - repDiscountValue;
                      pls.Net_Amount__c = pls.Net_of_Agency__c - repDiscountValue;
                      System.debug(pls.Net_Amount__c);
                     */
                    //}
                    //Start: SRSF-1945 changes : 25-10-2019
                    Decimal discountValue = 0;
                    if (pls.opportunity_agency__c != null && pls.Opportunity_Rep_Firm__c != null) { // If both Agency & Rep Firm Exists in Opportunity
                        if (pls.Opportunity_Agency_Discount__c >= pls.Opportunity_RepFirm_Discount__c) {
                            discountValue = pls.Gross_Amount__c / 100 * pls.Opportunity_Agency_Discount__c;
                        } else {
                            discountValue = pls.Gross_Amount__c / 100 * pls.Opportunity_RepFirm_Discount__c;
                        }
                    } else if (pls.opportunity_agency__c != null && pls.Opportunity_Rep_Firm__c == null) { // If only Agency exists & No Rep Firm Exists in Opportunity
                        discountValue = pls.Gross_Amount__c / 100 * pls.Opportunity_Agency_Discount__c;
                    } else if (pls.opportunity_agency__c == null && pls.Opportunity_Rep_Firm__c != null) { // If No Agency Exists & only Rep Firm Exists in Opportunity  
                        discountValue = pls.Gross_Amount__c / 100 * pls.Opportunity_RepFirm_Discount__c;
                    }
                    pls.Net_Amount__c = pls.Net_of_Agency__c = pls.Gross_Amount__c - discountValue;
                    System.debug('Net Amount>>>>>>' + pls.Net_Amount__c);
                    //End: SRSF-1945 changes : 25-10-2019
                }
            }
        }
        catch(Exception ex) {
            System.debug('Exception in calculateNetAmount: ' + ex + ex.getlinenumber());
        }
    }


    /*
      Method to set lookups on the Line schedule record
     */
    private static void setLookups(List<Proposal_Zone_Monthly_Value__c> newList) {
        Map<Id, Proposal_Zone_Monthly_Value__c> lookupList = new Map<Id, Proposal_Zone_Monthly_Value__c> ();
        for (Proposal_Zone_Monthly_Value__c pls : newList) {
            if (pls.Opportunity__c == null || pls.advertiser__c == null) {
                lookupList.put(pls.Proposal_Zone__c, pls);
            }
        }

        if (lookupList.size() > 0) {
            Map<Id, Proposal_Zone__c> plMap = new Map<Id, Proposal_Zone__c> ([SELECT Id, Proposal__r.Opportunity__c,
                                                                             Proposal__r.Opportunity__r.accountId, Proposal__c
                                                                             FROM Proposal_Zone__c
                                                                             WHERE Id IN :lookupList.keySet()]);

            for (Proposal_Zone_Monthly_Value__c lSch : newList) {
                if ((lSch.Opportunity__c == null || lSch.advertiser__c == null) &&
                    plMap.containsKey(lSch.Proposal_Zone__c))
                {
                    lSch.Opportunity__c = plMap.get(lSch.Proposal_Zone__c).Proposal__r.Opportunity__c;
                    lSch.advertiser__c = plMap.get(lSch.Proposal_Zone__c).Proposal__r.Opportunity__r.accountId;
                    lSch.Proposal_Key_Index__c = plMap.get(lSch.Proposal_Zone__c).Proposal__c;
                }
            }
        }
        setIndexFields(newList);
    }


    /*
      Method to set index field on record
     */
    private static void setIndexFields(List<Proposal_Zone_Monthly_Value__c> newList) {
        for (Proposal_Zone_Monthly_Value__c pls : newList) {
            pls.Schedule_Key_Index__c = pls.advertiser__c + pls.AE__c + pls.Broadcast_Month__c + pls.Year__c;
        }
    }

    /*
      Method to Inactivate all proposals for closed lost opportunities
     */
    public static void inactivateProposals(Set<Id> lostOppIdSet) {
        List<Proposal__c> proposlInactiveList = new List<Proposal__c> ();
        List<Proposal__c> timProposalInactiveList = new List<Proposal__c> ();
        for (Proposal__c prop :[SELECT Id, Active__c, TIM_Id__c FROM Proposal__c WHERE Opportunity__c IN :lostOppIdSet]) {
            prop.Active__c = false;
            proposlInactiveList.add(prop);

            if (String.isNotBlank(prop.TIM_Id__c)) {
                timProposalInactiveList.add(prop);
            }
        }

        if (proposlInactiveList.size() > 0) {
            update proposlInactiveList;
        }

        if (timProposalInactiveList.size() > 0) {
            if (
            (Limits.getFutureCalls() < Limits.getLimitFutureCalls())
            ) {
                deleteTIMProposals(lostOppIdSet);
            }
        }
    }

    @future(callout = true)
    public static void deleteTIMProposals(Set<Id> lostOppIdSet) {

        List<Proposal__c> timProposalInactiveList = new List<Proposal__c> ();
        for (Proposal__c prop :[SELECT Id, TIM_Id__c FROM Proposal__c WHERE Opportunity__c IN :lostOppIdSet]) {
            if (String.isNotBlank(prop.TIM_Id__c)) {
                timProposalInactiveList.add(prop);
            }
        }

        /*CM_TimWebServiceHelper timHelper = new CM_TimWebServiceHelper();
          if(!Test.isRunningTest()){
          Map<String,String> retMap = timHelper.InActivateProposals(timProposalInactiveList);
          System.debug(retMap);
          }*/
    }
    public static void proposalZoneBeforeInsertAndUpdate(List<Proposal_Zone__c> newList) {
        Map<String, String> groupStatusMap = new Map<String, String> ();
        for (Group_Status__c gs :[SELECT Status_Type__c, Name FROM Group_Status__c LIMIT 500]) {
            groupStatusMap.put(gs.Name, gs.status_type__c);
        }

        for (Proposal_Zone__c pz : newList) {
            if (CommonUtilities.isStringNullOrEmpty(pz.TIM_Status__c) && CommonUtilities.isStringNullOrEmpty(pz.Pilot_Order_Status__c) && !CommonUtilities.isStringNullOrEmpty(pz.Pilot_Proposal_ID__c)) {  //SRSF-4189 : Added IF Loop
                pz.Status_Type__c = 'Pending';                
            } else {          
                pz.Status_Type__c = pz.Pilot_Order_Status__c!=NULL ? groupStatusMap.get(pz.Pilot_Order_Status__c) : groupStatusMap.get(pz.TIM_Status__c); // Added : SRSF-3929
            }
            System.debug('PZ Status Type>>>>>'+pz.Status_Type__c);       
           // pz.Status_Type__c = groupStatusMap.get(pz.tim_status__c); // Commented : SRSF-3929
        }
    }

    public static void updateOpportuityStage(List<Proposal_Zone__c> newList, Map<Id, Proposal_Zone__c> oldMap) {

        Set<Id> proposalIdSet = new Set<Id> ();
        Map<Id, Proposal_Zone__c> pzMap = new Map<Id, Proposal_Zone__c> ();
        for (Proposal_Zone__c pz : newList) {
            try {
                if ((oldMap == null) || (pz.tim_status__c != oldMap.get(pz.Id).tim_status__c) ||
                    (pz.Pilot_Order_Status__c != oldMap.get(pz.Id).Pilot_Order_Status__c)) { // SRSF-3929 : Added 'Pilot Order Status' check
                    pzMap.put(pz.Id, pz);
                }
                // Changes done by Bhuvan on 13-June-2018(START)
                if (pz.Status_Type__c == 'ClosedWon') {
                    proposalIdSet.add(pz.Proposal__c);
                }
                // Changes done by Bhuvan on 13-June-2018(END)
            }
            catch(Exception ex) {
                System.debug('Exception in proposal zone status' + ex);
            }
        }
        // Changes done by Bhuvan on 13-June-2018(START)
        /*Id recordTypeId = UtilityClass.getRecordTypeID(new Proposal__c(), 'Political');
         
          List<Proposal__c> proposalsToUpdate = new List<Proposal__c>();
          if(proposalIdSet.size() > 0) {
          List<Proposal__c> propList = [SELECT Id, Name, RecordType.Name, RecordType.DeveloperName FROM Proposal__c WHERE Id IN : proposalIdSet AND RecordType.Name = 'Inventory' AND Opportunity__r.PoliticalOpportunity__c = true];
          for(Proposal__c prop : propList) {
          prop.RecordTypeId = recordTypeId;
          proposalsToUpdate.add(prop);
          }
          }
         
          if(proposalsToUpdate.size() > 0) {
          update proposalsToUpdate;
          }*/
        // Changes done by Bhuvan on 13-June-2018(END)
        if (pzMap.size() > 0) {
            Set<String> groupStatusSet = new Set<String> ();
            for (Group_Status__c gs :[SELECT Name FROM Group_Status__c WHERE Is_Closed_Won__c = true]) {
                groupStatusSet.add(gs.Name);
            }

            Set<Id> oppIds = new Set<Id> ();
            for (Proposal_Zone__c pz : pzMap.values()) {
                if (groupStatusSet.contains(pz.Pilot_Order_Status__c) || groupStatusSet.contains(pz.tim_status__c)) { // SRSF-3929 : Added 'Pilot Order Status' check
                    if (!oppIds.contains(pz.Opportunity_Id__c)) {
                        oppIds.add(pz.Opportunity_Id__c);
                    }
                }
            }

            if (oppIds.size() > 0) {
                List<Opportunity> oppList = [SELECT Id, StageName
                                             FROM Opportunity
                                             WHERE StageName != 'Closed Won'
                                             AND Id IN :oppIds
                                            ];
                List<Opportunity> oppUpdateList = new List<Opportunity> ();
                for (Opportunity opp : oppList)
                {
                    opp.StageName = 'Closed Won';
                    oppUpdateList.add(opp);
                }
                if (oppUpdateList.size() > 0)
                UPDATE oppUpdateList;
            }
        }
    }

    /* Populate Syscode lookup based on Sys_Code__c text field on Proposal Zone insert and update. */
    public static void populateSyscode(List<Proposal_Zone__c> newList) {
        Map<String, Syscode__c> propalZoneSyscodeMap = new Map<String, Syscode__c> ();
        for (Proposal_Zone__c pz : newList) {
            System.debug('pz--Sys_Code__c' + pz.Sys_Code__c);
            System.debug('pz--Sys_Code__c' + pz.Proposal__c);
            if (pz.Sys_Code__c != null) {

                propalZoneSyscodeMap.put(pz.Sys_Code__c, null);
            }
        }
        for (Syscode__c sc :[SELECT Id, Name, Market__c, Zone__c, Type__c, Eclipse_System__c FROM Syscode__c WHERE Name IN :propalZoneSyscodeMap.keySet()]) {
            try {
                if (propalZoneSyscodeMap.containsKey(sc.Name)) {
                    propalZoneSyscodeMap.put(sc.Name, sc);
                }
            } catch(Exception e) {
                System.debug('Exception ' + e.getMessage());
            }
        }
        for (Proposal_Zone__c pz : newList) {
            try {
                if (pz.Sys_Code__c != null) {
                    if (propalZoneSyscodeMap.containsKey(pz.Sys_Code__c)) {
                        pz.Syscode__c = propalZoneSyscodeMap.get(pz.Sys_Code__c).Id;
                        pz.Market__c = propalZoneSyscodeMap.get(pz.Sys_Code__c).Market__c;
                        pz.Zone__c = propalZoneSyscodeMap.get(pz.Sys_Code__c).Zone__c;
                        pz.Zone_Type__c = propalZoneSyscodeMap.get(pz.Sys_Code__c).Type__c;
                        pz.Eclipse_System__c = propalZoneSyscodeMap.get(pz.Sys_Code__c).Eclipse_System__c;
                    }
                }
            }
            catch(Exception e) {
                System.debug('Exception ' + e);
            }
        }
    }

    public static void ProposalZoneDelete(Map<Id, Proposal_Zone__c> oldMap)
    {
        List<Id> pzIdsDeleted = new List<Id> ();
        pzIdsDeleted.addAll(oldMap.keyset());
        UtilityClass.emptyRecycleBin(pzIdsDeleted);
    }

    public static Date getLastBroadcastDate(Date dt)
    {

        //date brd=  Date.newInstance(2019, 12, 15); 

        Integer numberOfDaysInMonth = Date.daysInMonth(dt.year(), dt.month());
        Date lastDate = Date.newInstance(dt.year(), dt.month(), numberOfDaysInMonth);
        DateTime lastDay = DateTime.newInstance(lastDate, Time.newInstance(12, 0, 0, 0));
        String lastDayWeekName = lastDay.format('EEE');
        Date lastSundayDate = lastDate;
        if ('Mon'.equalsIgnoreCase(lastDayWeekName))
        lastSundayDate = lastDate.addDays(- 1);
        else if ('Tue'.equalsIgnoreCase(lastDayWeekName))
        lastSundayDate = lastDate.addDays(- 2);
        else if ('Wed'.equalsIgnoreCase(lastDayWeekName))
        lastSundayDate = lastDate.addDays(- 3);
        else if ('Thu'.equalsIgnoreCase(lastDayWeekName))
        lastSundayDate = lastDate.addDays(- 4);
        else if ('Fri'.equalsIgnoreCase(lastDayWeekName))
        lastSundayDate = lastDate.addDays(- 5);
        else if ('Sat'.equalsIgnoreCase(lastDayWeekName))
        lastSundayDate = lastDate.addDays(- 6);
        return lastSundayDate;
    }
}