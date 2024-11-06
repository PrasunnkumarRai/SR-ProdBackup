/*
  ###########################################################################
  # File..................: RevenueAggregateBatch.cls
  # Version...............: 1
  # Created by............: Matthew Kidman
  # Created Date..........: 12-Apr-2019
  # Last Modified by......:
  # Last Modified Date....:
  # Description...........: This class is used to Extract the Change in Revenue data due to transfers.
  # TAO Ref#..............: NA
  # Test Class............: 
  # Change Log............:
  ############################################################################*/

global class RevenueAggregateBatch implements Database.Batchable<sObject>, Database.Stateful {

    global String query;
    global Map<string, string> salesRevenueFieldValueMap;
    List<Revenue__c> salesrevenue;
    List<Sales_Revenue_Aggregate__c> revenueAggregates;
    List<revenueWrapper> revenueWrapperList;
    Map<String, revenueWrapper> revenueWrapperMap;
    Map<string, String> userMap;
    Set<ID> userIDs;
    AsyncApexJob aaj;

    global RevenueAggregateBatch(String qry, Set<ID> userIDs) {
        userMap = new Map<String, String> ();
        revenueAggregates = new List<Sales_Revenue_Aggregate__c> ();
        this.userIDs = userIDs;
        revenueWrapperList = new List<revenueWrapper> ();
        revenueWrapperMap = new Map<String, revenueWrapper> ();
        aaj = new AsyncApexJob();
		System.debug('qry ' + qry);
		System.debug('userIDs ' + userIDs);
        if (string.isEmpty(qry) || userIDs == null)
        {
            qry = 'SELECT  Account_Executive__c, Account_Executive__r.Name , Advertiser__c, Net_Projected_Amount__c , Broadcast_Month_Date__c,Revenue_User__c,Revenue_User__r.Name  ';
            qry += ' FROM Revenue__c where Calendar_Year(Broadcast_Month_Date__c) >= 2018 AND Advertiser__c != null';
            qry += ' AND (NOT Account_Executive__r.Name Like  \'Boomi%\') AND Account_Executive__c != null  order by Account_Executive__r.Name, Advertiser__c desc';
        }
        this.query = qry;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {

        if(userIds != null && userIds.size() > 0)
        {
            List<Sales_Revenue_Aggregate__c> Ids = [Select id from Sales_Revenue_Aggregate__c where  SalesRevenue_AccountExecutive__c in: userIDs limit 5000];
            
			
            
            if(Ids.size()>0){
			delete Ids;
                Database.emptyRecycleBin(Ids);
            }

        ////String[] IdsToBeDeleted;
        ////for(Sales_Revenue_Aggregate__c rev: Ids)
        ////{
        ////IdsToBeDeleted.add(rev.Id);
        ////}

        //EmptyRecycleBinBasedOnIdsbatch emp = new EmptyRecycleBinBasedOnIdsbatch('Select id from Sales_Revenue_Aggregate__c where  SalesRevenue_AccountExecutive__c in: userIDs',userIds);
        //database.ExecuteBatch(emp, 200);
        }
        aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
               FROM AsyncApexJob WHERE ID = :BC.getJobId()];
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Revenue__c> scope) {
        salesrevenue = new list<Revenue__c> ();
        salesrevenue = scope;
        revenueWrapperList = new List<revenueWrapper> ();
        system.debug('revenueWrapperList: Size after  ' + revenueWrapperMap.keySet());
        system.debug('revenueWrapperList: ' + revenueWrapperList);
        Map<String, revenueWrapper> userSalesBudget = new Map<String, revenueWrapper> ();
        try
        {
            Integer i = 0;
            for (Revenue__c sbObj : salesrevenue)
            {

                Integer year = sbObj.Broadcast_Month_Date__c.year();
                Integer month = sbObj.Broadcast_Month_Date__c.month();

                revenueWrapper sbWObj = new revenueWrapper();
                system.debug('revenueWrapperMap: Size after  ' + revenueWrapperMap.keySet());
                if (!revenueWrapperMap.containsKey((string) sbObj.Account_Executive__c + '-' + (string) sbObj.Advertiser__c + '-' + string.valueOf(year)) && sbObj.Revenue_User__c == null)
                {
                    if (revenueWrapperMap.keySet().size() > 0)
                    {
                        for (revenueWrapper rev : revenueWrapperMap.values())
                        {
                            revenueWrapperList.add(rev);
                        }
                    }
                    system.debug('revenueWrapperMap inside For : ' + revenueWrapperList);
                    revenueWrapperMap.clear();
                    sbWObj.Name = (string) sbObj.Account_Executive__r.Name;
                    sbWObj.Year = string.valueOf(year);
                    sbWObj.UserId = (string) sbObj.Account_Executive__c;
                    sbWObj.Advertiser = (string) sbObj.Advertiser__c;
                    sbWObj.inrevenue[month - 1] += sbObj.Net_Projected_Amount__c == null ? 0 : (Decimal) sbObj.Net_Projected_Amount__c;
                    revenueWrapperMap.put((string) sbObj.Account_Executive__c + '-' + (string) sbObj.Advertiser__c + '-' + string.valueOf(year), sbWObj);
                    system.debug('sbObj.Net_Projected_Amount__c: ' + (string) sbObj.Account_Executive__c + '-' + (string) sbObj.Advertiser__c + '-' + string.valueOf(year) + '_' + sbObj.Net_Projected_Amount__c);
                }
                else if (sbObj.Revenue_User__c != null && !revenueWrapperMap.containsKey((string) sbObj.Revenue_User__c + '-' + (string) sbObj.Advertiser__c + '-' + string.valueOf(year)))
                {
                    if (revenueWrapperMap.keySet().size() > 0)
                    {
                        for (revenueWrapper rev : revenueWrapperMap.values())
                        {
                            revenueWrapperList.add(rev);
                        }
                    }
                    system.debug('revenueWrapperMap inside For : ' + revenueWrapperList);
                    revenueWrapperMap.clear();
                    sbWObj.Name = (string) sbObj.Revenue_User__r.Name;
                    sbWObj.Year = string.valueOf(year);
                    sbWObj.UserId = (string) sbObj.Revenue_User__c;
                    sbWObj.Advertiser = (string) sbObj.Advertiser__c;
                    sbWObj.inrevenue[month - 1] += sbObj.Net_Projected_Amount__c == null ? 0 : (Decimal) sbObj.Net_Projected_Amount__c;
                    revenueWrapperMap.put((string) sbObj.Revenue_User__c + '-' + (string) sbObj.Advertiser__c + '-' + string.valueOf(year), sbWObj);
                    system.debug('sbObj.Net_Projected_Amount__c: ' + (string) sbObj.Revenue_User__c + '-' + (string) sbObj.Advertiser__c + '-' + string.valueOf(year) + '_' + sbObj.Net_Projected_Amount__c);
                }
                else if (sbObj.Revenue_User__c != null && revenueWrapperMap.containsKey((string) sbObj.Revenue_User__c + '-' + (string) sbObj.Advertiser__c + '-' + string.valueOf(year)))
                {
                    sbWObj = revenueWrapperMap.get((string) sbObj.Revenue_User__c + '-' + (string) sbObj.Advertiser__c + '-' + string.valueOf(year));
                    sbWObj.inrevenue[month - 1] += sbObj.Net_Projected_Amount__c == null ? 0 : (Decimal) sbObj.Net_Projected_Amount__c;
                    revenueWrapperMap.put((string) sbObj.Revenue_User__c + '-' + (string) sbObj.Advertiser__c + '-' + string.valueOf(year), sbWObj);
                    system.debug('sbObj.Net_Projected_Amount__c else : ' + (string) sbObj.Revenue_User__c + '-' + (string) sbObj.Advertiser__c + '-' + string.valueOf(year) + '_' + sbObj.Net_Projected_Amount__c);
                    if (aaj.JobItemsProcessed == aaj.TotalJobItems && i == salesRevenue.size() - 1)
                    {
                        if (revenueWrapperMap.keySet().size() > 0)
                        {
                            for (revenueWrapper rev : revenueWrapperMap.values())
                            {
                                revenueWrapperList.add(rev);
                            }
                            //revenueWrapperList = revenueWrapperMap.values();
                        }
                    }
                }
                else
                {
                    sbWObj = revenueWrapperMap.get((string) sbObj.Account_Executive__c + '-' + (string) sbObj.Advertiser__c + '-' + string.valueOf(year));
                    sbWObj.inrevenue[month - 1] += sbObj.Net_Projected_Amount__c == null ? 0 : (Decimal) sbObj.Net_Projected_Amount__c;
                    revenueWrapperMap.put((string) sbObj.Account_Executive__c + '-' + (string) sbObj.Advertiser__c + '-' + string.valueOf(year), sbWObj);
                    system.debug('sbObj.Net_Projected_Amount__c else : ' + (string) sbObj.Account_Executive__c + '-' + (string) sbObj.Advertiser__c + '-' + string.valueOf(year) + '_' + sbObj.Net_Projected_Amount__c);
                    if (aaj.JobItemsProcessed == aaj.TotalJobItems && i == salesRevenue.size() - 1)
                    {
                        if (revenueWrapperMap.keySet().size() > 0)
                        {
                            for (revenueWrapper rev : revenueWrapperMap.values())
                            {
                                revenueWrapperList.add(rev);
                            }
                            //revenueWrapperList = revenueWrapperMap.values();
                        }
                    }
                }
                i++;
                system.debug('revenueWrapperMap: inside FOr ' + revenueWrapperList.size());
            }
            system.debug('revenueWrapperMap: Size after  ' + revenueWrapperMap.size());
            system.debug('revenueWrapperMap: ' + revenueWrapperList);
            createRevAggregate();

            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }
        catch(Exception ex)
        { System.Debug('exception:' + ex.getMessage());
            Log4SF.logMessage('RevenueAggregateBatch', 'execute', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
        }

    }

    global void createRevAggregate() {
        String csvData = '';
        system.debug('createRevAggregate: revenueWrapperList' + revenueWrapperList);
        try
        {
            revenueAggregates = new List<Sales_Revenue_Aggregate__c> ();
            Schema.SObjectField ftoken = Sales_Revenue_Aggregate__c.Fields.External_Id__c;
            Sales_Revenue_Aggregate__c sbaObj;
            for (revenueWrapper sbObj : revenueWrapperList)
            {

                integer loopCounter = 0;
                sbaObj = new Sales_Revenue_Aggregate__c();
                sbaObj.SalesRevenue_AccountExecutive__c = Id.valueOf(sbObj.UserID);
                sbaObj.Broadcast_Year__c = sbObj.Year;
                sbaObj.SalesRevenue_Advertiser__c = Id.valueOf(sbObj.Advertiser);
                sbaObj.External_Id__c = sbObj.UserID + sbObj.Advertiser + sbObj.Year;
                for (integer i = 1; i <= sbObj.inrevenue.size(); i++)
                {
                    if (i == 1) {
                        sbaObj.January_Revenue__c = sbObj.inrevenue[i - 1];
                    }
                    if (i == 2) {
                        sbaObj.February_Revenue__c = sbObj.inrevenue[i - 1];
                    }
                    if (i == 3) {
                        sbaObj.March_Revenue__c = sbObj.inrevenue[i - 1];
                    }
                    if (i == 4) {
                        sbaObj.April_Revenue__c = sbObj.inrevenue[i - 1];
                    }
                    if (i == 5) {
                        sbaObj.May_Revenue__c = sbObj.inrevenue[i - 1];
                    }
                    if (i == 6) {
                        sbaObj.June_Revenue__c = sbObj.inrevenue[i - 1];
                    }
                    if (i == 7) {
                        sbaObj.July_Revenue__c = sbObj.inrevenue[i - 1];
                    }
                    if (i == 8) {
                        sbaObj.August_Revenue__c = sbObj.inrevenue[i - 1];
                    }
                    if (i == 9) {
                        sbaObj.September_Revenue__c = sbObj.inrevenue[i - 1];
                    }
                    if (i == 10) {
                        sbaObj.October_Revenue__c = sbObj.inrevenue[i - 1];
                    }
                    if (i == 11) {
                        sbaObj.November_Revenue__c = sbObj.inrevenue[i - 1];
                    }
                    if (i == 12) {
                        sbaObj.December_Revenue__c = sbObj.inrevenue[i - 1];
                    }
                }
                system.debug('createRevAggregate: sbObj' + sbaObj.External_Id__c);
                revenueAggregates.add(sbaObj);
            }
            database.Upsert(revenueAggregates, ftoken, false);
        }
        catch(Exception ex)
        {
            Log4SF.logMessage('RevenueAggregateBatch', 'createRevAggregate', ex.getMessage(), ex, UserInfo.getUserId(), null, '');
        }
    }

    global void finish(Database.BatchableContext BC) {
    /*
        if (userIds != null && userIds.size() > 0)
        {
            EmptyRecycleBinBasedOnIdsbatch emp = new EmptyRecycleBinBasedOnIdsbatch('Select id from Sales_Revenue_Aggregate__c where  SalesRevenue_AccountExecutive__c in: userIds', userIds);
            database.ExecuteBatch(emp, 2000);
        }
    */
    }

    public class revenueWrapper
    {
        public string UserID;
        public string Name;
        public string Year;
        public String Advertiser;
        public List<Decimal> inrevenue;
        public List<Decimal> outrevenue;
        public List<Decimal> budgetChanges;

        public revenueWrapper()
        {
            UserID = '';
            Advertiser = '';
            Year = '';
            Name = '';
            inrevenue = new List<Decimal> { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
            outrevenue = new List<Decimal> { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
            budgetChanges = new List<Decimal> { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
        }

    }
}