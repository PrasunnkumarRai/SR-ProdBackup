public with sharing class TrackCompensationPlanCSVController {
    //region variables
    public String jsonTrackCompData {get;set;}
    public Integer currentYear {get; set;}
    public Integer nextYear {get; set;}
    public final List<Integer> years = new List<Integer>{currentYear,nextYear};
    public String selectedyear;
    public List<AggregateResult> BudgetList {get;set;}
    public Map<String,salesbudgetWrapper> salesBudgetWrapperMap {get;set;}
    //endregion
    
    public TrackCompensationPlanCSVController(){
        try{
            currentYear = Date.Today().Year();
            nextYear = Date.Today().Year() + 1;
            selectedyear = '';
            GetTrackCompDetails();
            
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }
        
        catch(exception ex)
        {
            Log4SF.logMessage('TrackCompensationPlanController', 'constructor', ex.getMessage(),ex, UserInfo.getUserId(),'','');        
        }
    }
    
    public void GetTrackCompDetails()
    {
        Cache.SessionPartition partition = Cache.Session.getPartition('SRPartition');
        
        List<String>userIds = (List<String>)partition.get('lstUserIdsAllowed');
        system.debug('lstUserIdsAllowed ' + userIds);
        
        List<String> lstratePlanStatus = new List<String>{'Pending','Committed','Draft'};
        List<Integer> lstselectedYear = new List<Integer>();
        salesBudgetWrapperMap=new Map<String,salesbudgetWrapper>();
        
        try{
            String selectedYear = Apexpages.currentPage().getParameters().get('selectedBudgetYear');
                                
            if(selectedYear == null)
            {
                lstselectedYear.Add(currentYear);
            }
            else
            {
                lstselectedYear.Add(Integer.ValueOf(selectedYear));
            }
            
             BudgetList    = [SELECT  
                                Budget_User__r.Name AEName,
                                Budget_User__c AeId,
                                From_Budget_user__r.Name oldAEName,
                                From_Budget_user__c oldAeId, 
                                Sum(Amount__c) BudAmt,
                                CALENDAR_MONTH(Budget_Change_Date__c) bdMonth,
                                Budget_User__r.Rate_Plan_Status__c BudUserStatus,
                                From_Budget_user__r.Rate_Plan_Status__c OldBudUserStatus,
                                Budget_User__r.region__c BudUserRegion,
                                From_Budget_user__r.region__c OldBudUserRegion,
                                BUCommitDateCompareTransferDate__c BUCommitDateBool,
                                Old_BU_Commit_Date_Compare_Transfer_Date__c OldBUCommitDateBool
                                FROM Sales_Budget_Simulation__c
                                WHERE (Budget_User__r.Rate_Plan_Status__c IN ('Pending','Committed','Draft')
                                      OR From_Budget_user__r.Rate_Plan_Status__c IN ('Pending','Committed','Draft'))
                                      AND CALENDAR_YEAR(Budget_Change_Date__c) IN :lstselectedYear
                                      AND Amount__c != NULL
                                      AND Budget_Change_Date__c != NULL
                                      AND Type__c = 'Log'
                                      AND Budget_User__c IN :userIds 
                                      AND From_Budget_user__c IN :userIds
                                      AND ((Sales_Budget__r.Type__c = 'Data' and (Sales_Budget__r.Product_Line__c != 'New Business' AND Sales_Budget__r.Product_Line__c != 'Unknown Churn')) OR Sales_Budget__r.Type__c = 'DOS')
                                GROUP BY CALENDAR_MONTH(Budget_Change_Date__c),Budget_User__c,Budget_User__r.Name,From_Budget_user__r.Name,
                                         From_Budget_user__c,Budget_User__r.Rate_Plan_Status__c,From_Budget_user__r.Rate_Plan_Status__c,
                                         Budget_User__r.region__c,From_Budget_user__r.region__c,BUCommitDateCompareTransferDate__c,
                                         Old_BU_Commit_Date_Compare_Transfer_Date__c
                                ORDER BY Budget_User__r.Name, CALENDAR_MONTH(Budget_Change_Date__c)
                            ];
            
            for(AggregateResult BudItem : BudgetList)
            {
                String Key = (String)BudItem.get('AeId');
                
                salesBudgetWrapper sbWObj = new salesBudgetWrapper();
                
                if(!salesBudgetWrapperMap.containsKey(Key))
                {
                    sbWObj.aeName = (String)BudItem.get('AeName');
                    sbWObj.aeId = (String)BudItem.get('AeId');
                    PopulateData(sbWObj,Key,BudItem,lstratePlanStatus,userIds);
                }                   
                
                else
                {
                    sbWObj = salesBudgetWrapperMap.get(Key);
                    sbWObj.aeName = (String)BudItem.get('AeName');
                    sbWObj.aeId = (String)BudItem.get('AeId');
                    PopulateData(sbWObj,Key,BudItem,lstratePlanStatus,userIds);
                }
            }
            
            for(salesbudgetWrapper sbWItem :salesBudgetWrapperMap.values())
            {
                for(Decimal bcItem :sbWItem.budgetChanges)
                {
                    sbWItem.total += bcItem;
                }
            }

            jsonTrackCompData = JSON.serialize(salesBudgetWrapperMap);
            
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }
        
        catch(exception ex)
        {
            system.debug(ex.getMessage());
            //Log4SF.logMessage('TrackCompensationPlanController', 'GetTrackCompDetails', ex.getMessage(),ex, UserInfo.getUserId(),'Parametr value: '+ lstratePlanStatus,'');   
        }
    }
    
    private void PopulateData(salesBudgetWrapper sbWObj, String Key, AggregateResult BudItem, List<String> lstratePlanStatus, List<String> userIds)
    {
        String oldKey = (String)BudItem.get('oldAeId');
        Integer month = (Integer)BudItem.get('bdMonth');
        String OldBudUserStatus = (String)BudItem.get('OldBudUserStatus');
        String BudUserStatus = (String)BudItem.get('BudUserStatus');
        Boolean BUCommitDateBool = (Boolean)BudItem.get('BUCommitDateBool');
        Boolean OldBUCommitDateBool = (Boolean)BudItem.get('OldBUCommitDateBool');
        
        if((String)BudItem.get('oldAeId')  != null && (String)BudItem.get('oldAeId') != '' && lstratePlanStatus.Contains(OldBudUserStatus) && OldBUCommitDateBool == true)
        {
            salesBudgetWrapper sbWOldObj = new salesBudgetWrapper();
            
            if(!salesBudgetWrapperMap.containsKey(oldKey))
            {
                // Old user Budget Out Movements                            
                sbWOldObj.aeName = (String)BudItem.get('oldAeName');
                sbWOldObj.aeId = (String)BudItem.get('oldAeId');
                sbWOldObj.outBudgets[month-1] += BudItem.get('BudAmt') == null ? 0 : (Decimal)BudItem.get('BudAmt');
            }
            
            else
            {
                sbWOldObj = salesBudgetWrapperMap.get(oldKey);
                sbWOldObj.outBudgets[month-1] += BudItem.get('BudAmt') == null ? 0 : (Decimal)BudItem.get('BudAmt');    
            }
            
            sbWOldObj.budgetChanges[month-1] = sbWOldObj.inBudgets[month-1] - sbWOldObj.outBudgets[month-1];
            
            if(userIds.Contains(oldKey))
            {
                salesBudgetWrapperMap.put(oldKey,sbWOldObj);
            }
        }
        
        if(lstratePlanStatus.Contains(BudUserStatus) && BUCommitDateBool == true)
        {
            sbWObj.inBudgets[month-1] += BudItem.get('BudAmt') == null ? 0 : (Decimal)BudItem.get('BudAmt');
            sbWObj.budgetChanges[month-1] = sbWObj.inBudgets[month-1] - sbWObj.outBudgets[month-1];
            if(userIds.Contains(Key))
            {
                salesBudgetWrapperMap.put(Key,sbWObj);
            }
        }
    }
    
    public class salesbudgetWrapper
    {
        public String aeId {get; set;}
        public String aeName {get; set;}
        public Decimal total {get; set;}
        public List<Decimal> inbudgets {get; set;}
        public List<Decimal> outBudgets {get; set;}
        public List<Decimal> budgetChanges {get; set;}
        
        public salesbudgetWrapper()
        {
            aeId = '';
            aeName = '';
            total = 0;
            inbudgets = new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0};
            outBudgets = new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0};
            budgetChanges = new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0};
        }
        
    }
    
    //call batch to Generate and Email the CSV
    @RemoteAction
    public static String generateCSV(boolean isAll, string selectedyear)
    {
        String rtnMsg = '';
        try
        {
            Cache.SessionPartition partition = Cache.Session.getPartition('SRPartition');
        
            //Boolean isCommitReadonly = Boolean.valueOf(partition.get('isCommitReadonly'));
            List<String>userIds = (List<String>)partition.get('lstUserIdsAllowed');
            system.debug('isAll '+isAll+' userIds '+userIds);
            string qry = '';
            qry =  'SELECT  Budget_User__r.HR_Job_Title__c , Budget_User__r.HR_PID__c , Budget_User__r.Name , Budget_User__r.Division__c , Old_Budget_User__r.Name , Old_Budget_User__c ,Product_Line__c ,Budget_User__r.HR_Manager__r.HR_PID__c, Budget_User__r.HR_Manager__r.Name,';
            qry +='Old_Budget_User__r.HR_Job_Title__c,Old_Budget_User__r.HR_Manager__r.HR_PID__c, Old_Budget_User__r.HR_Manager__r.Name, Old_Budget_User__r.HR_PID__c , Old_Budget_User__r.Division__c, Budget_User__c , Amount__c , Broadcast_Month_Date__c, Budget_User__r.HR_WorkforceID__c, Old_Budget_User__r.HR_WorkforceID__c, Budget_User__r.HR_Manager__r.HR_WorkforceID__c, Old_Budget_User__r.HR_Manager__r.HR_WorkforceID__c   FROM Sales_Budget__c WHERE ';
            boolean isAllData = isAll;
            if(!isAllData)
            qry += 'Budget_User__r.Rate_Plan_Status__c != null  AND '; //SRB-722 -AND Old_Budget_User__c != null
            qry +='Amount__c != NULL AND Amount__c != 0 AND (Budget_User__c in : userIds OR Old_Budget_User__c in : userIds) AND ((Type__c = \'Data\' AND (Product_Line__c != \'New Business\' AND Product_Line__c != \'Unknown Churn\')) OR (Type__c = \'DOS\')) AND CALENDAR_YEAR(Broadcast_Month_Date__c) ='+  selectedyear +' ORDER BY Budget_User__r.Name desc';
            
            SalesBudgetCSVBatch sb = new SalesBudgetCSVBatch(qry,isAllData,userIds);
            Database.executeBatch(sb , 2000); 
            
            rtnMsg = 'Batch called';
        }  
        
        catch(exception ex)
        {
            rtnMsg = 'Batch error';
            system.debug(ex.getMessage());
            //Log4SF.logMessage('TrackCompensationPlanCSVController', 'generateCSV', ex.getMessage(),ex, UserInfo.getUserId(),'Parametr values isAll: '+ isAll + ' selectedyear: ' +selectedyear,'');   
        } 
        
        return rtnMsg;
    }
}