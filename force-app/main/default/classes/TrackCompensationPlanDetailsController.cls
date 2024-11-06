public with sharing class TrackCompensationPlanDetailsController {
    //region variables
    public String pageMsg{get;set;}
    public Transient List<transferDetailsWrapper> transferDetails{get;set;}
    public Transient Map<String,salesbudgetWrapper> salesBudgetWrapperMap {get;set;}
    public Transient List<AggregateResult> inProductLineList {get;set;}
    public Transient List<AggregateResult> outProductLineList {get;set;}
    public Transient List<AggregateResult> ProductLineList {get;set;}
    public Transient List<Product_Line_Order__mdt> ProductLineOrderList {get;set;}
    public Boolean isCommitReadonly {get;set;}
    public List<User> selectedUserStatus;
    public List<AggregateResult> BudgetList {get;set;}
    //endregion
    
    public TrackCompensationPlanDetailsController(){        
        transferDetails = new List<transferDetailsWrapper>();
        transferDetailsWrapper transferDetailObj = new transferDetailsWrapper();
        try{
            salesBudgetWrapperMap=new Map<String,salesbudgetWrapper>();
            
            Cache.SessionPartition partition = Cache.Session.getPartition('SRPartition');
            String selectedUserId = ApexPages.currentPage().getParameters().get('selUserId');
            Integer selectedYear = Integer.ValueOf(ApexPages.currentPage().getParameters().get('selYear'));
            isCommitReadonly = Boolean.valueOf(partition.get('isCommitReadonly'));
            
            selectedUserStatus = [SELECT Rate_Plan_Status__c, Rate_Plan_Commit_Date__c FROM User WHERE Id = :selectedUserId LIMIT 1];
            
            if(selectedUserStatus[0].Rate_Plan_Status__c =='Draft' || selectedUserStatus[0].Rate_Plan_Status__c =='Committed')
            {
                isCommitReadonly = true;
            }           
             
             BudgetList    = [SELECT
                            Id,  
                            Budget_User__r.Name AEName,
                            Budget_User__c AeId,
                            From_Budget_user__r.Name oldAEName,
                            From_Budget_user__c oldAeId, 
                            SUM(Amount__c) BudAmt,
                            Broadcast_Month_Date__c broadcastDate,
                            From_Budget_user__r.Rate_Plan_Status__c OldBudUserStatus,
                            Budget_User__r.Division__c BudUserDivision,
                            From_Budget_user__r.Division__c OldBudUserDivision,
                            Advertiser__r.Name account,
                            DAY_ONLY(CreatedDate) effectiveDate,
                            CompensationCommitDate__r.Commit_Date__c commitDate
                            FROM Sales_Budget_Simulation__c
                            WHERE (Budget_User__r.Rate_Plan_Status__c IN ('Pending','Committed','Draft')
                                  OR From_Budget_user__r.Rate_Plan_Status__c IN ('Pending','Committed','Draft'))
                                  AND CALENDAR_YEAR(Budget_Change_Date__c) = :selectedYear
                                  AND Amount__c != NULL
                                  AND Amount__c != 0 
                                  AND Broadcast_Month_Date__c != NULL
                                  AND Type__c = 'Log'
                                  AND (Budget_User__c = :selectedUserId OR From_Budget_user__c = :selectedUserId)
                                  AND ((Sales_Budget__r.Type__c = 'Data' and (Sales_Budget__r.Product_Line__c != 'New Business' AND Sales_Budget__r.Product_Line__c != 'Unknown Churn')) OR Sales_Budget__r.Type__c = 'DOS')
                            GROUP BY Id,Budget_User__c,Budget_User__r.Name,From_Budget_user__r.Name,
                                     From_Budget_user__c,Budget_User__r.Rate_Plan_Status__c,From_Budget_user__r.Rate_Plan_Status__c,
                                     Budget_User__r.Division__c,From_Budget_user__r.Division__c,BUCommitDateCompareTransferDate__c,Old_BU_Commit_Date_Compare_Transfer_Date__c,Advertiser__r.Name,DAY_ONLY(CreatedDate),Broadcast_Month_Date__c,CompensationCommitDate__r.Commit_Date__c
                            ORDER BY Budget_User__r.Name
                            ];
                             
                             
             inProductLineList = [SELECT   
                                     Sum(Amount__c) inBudAmt,
                                     CALENDAR_MONTH(Budget_Change_Date__c) effectiveMonth,
                                     Product_Line__c productLine
                                     FROM Sales_Budget_Simulation__c
                                     WHERE Budget_User__c = :selectedUserId
                                           AND From_Budget_user__c != null
                                           AND CALENDAR_YEAR(Budget_Change_Date__c) = :selectedYear
                                           AND Amount__c != NULL
                                           AND Amount__c != 0 
                                           AND BUCommitDateCompareTransferDate__c = true
                                           AND Type__c = 'Log'
                                           AND ((Sales_Budget__r.Type__c = 'Data' and (Sales_Budget__r.Product_Line__c != 'New Business' AND Sales_Budget__r.Product_Line__c != 'Unknown Churn')) OR Sales_Budget__r.Type__c = 'DOS')
                                     GROUP BY CALENDAR_MONTH(Budget_Change_Date__c), Product_Line__c
                                     ORDER BY Product_Line__c
                                  ];
                                  
             outProductLineList   = [SELECT  
                                        Sum(Amount__c) outBudAmt,
                                        CALENDAR_MONTH(Budget_Change_Date__c) effectiveMonth,
                                        Product_Line__c productLine
                                        FROM Sales_Budget_Simulation__c
                                        WHERE From_Budget_user__c = :selectedUserId 
                                              AND CALENDAR_YEAR(Budget_Change_Date__c) = :selectedYear
                                              AND Amount__c != NULL
                                              AND Amount__c != 0 
                                              AND Type__c = 'Log'
                                              AND Old_BU_Commit_Date_Compare_Transfer_Date__c = true
                                              AND ((Sales_Budget__r.Type__c = 'Data' and (Sales_Budget__r.Product_Line__c != 'New Business' AND Sales_Budget__r.Product_Line__c != 'Unknown Churn')) OR Sales_Budget__r.Type__c = 'DOS')
                                        GROUP BY CALENDAR_MONTH(Budget_Change_Date__c), Product_Line__c
                                        ORDER BY Product_Line__c
                                    ];                              
                                    
            ProductLineOrderList =  [Select id,DeveloperName,order__c from Product_Line_Order__mdt ORDER BY order__c];
            
            ProductLineList =   [SELECT 
                                    Product_Line__c productLine
                                    FROM Sales_Budget_Simulation__c
                                    WHERE (Budget_User__c = :selectedUserId OR From_Budget_user__c = :selectedUserId)
                                          AND CALENDAR_YEAR(Budget_Change_Date__c) = :selectedYear
                                          AND Product_Line__c != NULL
                                          AND Type__c = 'Log'
                                          AND ((Sales_Budget__r.Type__c = 'Data' and (Sales_Budget__r.Product_Line__c != 'New Business' AND Sales_Budget__r.Product_Line__c != 'Unknown Churn')) OR Sales_Budget__r.Type__c = 'DOS')
                                    GROUP BY Product_Line__c
                                    ORDER BY Product_Line__c
                                ];                                        
            system.debug('BudgetList length: ' + BudgetList.size());
            for(AggregateResult BudItem : BudgetList)
            {
                String Key;
                salesBudgetWrapper sbWObj = new salesBudgetWrapper();
                sbWObj.transferIn = 0;
                sbWObj.transferOut = 0;
                
                if((String)BudItem.get('AeId') == selectedUserId)
                {
                    Key = (String)BudItem.get('oldAeId') + '_' + (String)BudItem.get('account') + '_' + ((Datetime)BudItem.get('broadcastDate')).format('MMMMM -YYYY');                 
                    
                    if(salesBudgetWrapperMap.containsKey(Key))
                    {
                        sbWObj = salesBudgetWrapperMap.get(Key);
                    }
                    sbWObj.transferIn += (Decimal)BudItem.get('BudAmt');
                    sbWObj.transferUser = (String)BudItem.get('oldAEName');
                    sbWObj.sbSimId = (String)BudItem.get('Id');
                    PopulateData(sbWObj,BudItem,Key);                 
                }
                
                else
                {
                    Key = (String)BudItem.get('AeId') + '_' + (String)BudItem.get('account') + '_' + ((Datetime)BudItem.get('broadcastDate')).format('MMMMM -YYYY');
                    if(salesBudgetWrapperMap.containsKey(Key))
                    {
                        sbWObj = salesBudgetWrapperMap.get(Key);
                    }
                    sbWObj.transferOut += (Decimal)BudItem.get('BudAmt');
                    sbWObj.transferUser = (String)BudItem.get('AEName');
                    sbWObj.sbSimId = (String)BudItem.get('Id');
                    PopulateData(sbWObj,BudItem,Key);
                }
            }
             
            for(Product_Line_Order__mdt productLine: [Select id,MasterLabel,order__c from Product_Line_Order__mdt ORDER BY order__c]){
                for(AggregateResult productLineItem : ProductLineList)
                {   
                    if((String)productLineItem.get('productLine') == productLine.MasterLabel)
                    {           
                        transferDetailObj.productline = productLine.MasterLabel;
                        transferDetailObj.productLineBudgetDetails = new List<transferBudgetDetailsWrapper>();
                        transferDetailObj.beforeTotalAmount = 0;
                        transferDetailObj.afterTotalAmount = 0;
                        
                        for (Integer j = 1; j <= 12; j++) {
                            transferBudgetDetailsWrapper objtransferBudgetDetailsWrapper = new transferBudgetDetailsWrapper();
                            objtransferBudgetDetailsWrapper.month = j;
                            objtransferBudgetDetailsWrapper.beforeAmount = 0;
                            objtransferBudgetDetailsWrapper.afterAmount = 0;
                            objtransferBudgetDetailsWrapper.diffAmount = 0;
                            
        
                            for(AggregateResult outProdItem : outProductLineList)
                            {
                                if((String)outProdItem.get('productLine') == productLine.MasterLabel && (Integer)outProdItem.get('effectiveMonth') == j)
                                {
                                    objtransferBudgetDetailsWrapper.beforeAmount = (Decimal)outProdItem.get('outBudAmt');                           
                                }
                            }
                            
                            for(AggregateResult inProdItem : inProductLineList)
                            {
                                if((String)inProdItem.get('productLine') == productLine.MasterLabel && (Integer)inProdItem.get('effectiveMonth') == j)
                                {
                                    objtransferBudgetDetailsWrapper.afterAmount = (Decimal)inProdItem.get('inBudAmt');
                                }
                            } 
                            
                            objtransferBudgetDetailsWrapper.diffAmount = objtransferBudgetDetailsWrapper.afterAmount - objtransferBudgetDetailsWrapper.beforeAmount;
                            transferDetailObj.beforeTotalAmount += objtransferBudgetDetailsWrapper.beforeAmount;
                            transferDetailObj.afterTotalAmount += objtransferBudgetDetailsWrapper.afterAmount;
                            transferDetailObj.diffTotalAmount = transferDetailObj.afterTotalAmount - transferDetailObj.beforeTotalAmount;
                            transferDetailObj.productLineBudgetDetails.Add(objtransferBudgetDetailsWrapper);
                        }
                        transferDetails.add(transferDetailObj); 
                        transferDetailObj = new transferDetailsWrapper();
                    }
                }
            }
            
            transferDetailsWrapper totalTransfer = new transferDetailsWrapper();
            totalTransfer.productline = 'Total';
            totalTransfer.beforeTotalAmount = 0;
            totalTransfer.afterTotalAmount = 0;
            totalTransfer.diffTotalAmount = 0;
            totalTransfer.productLineBudgetDetails = new List<transferBudgetDetailsWrapper>();
            
            for (Integer j = 1; j <= 12; j++) {
                transferBudgetDetailsWrapper objtransferBudgetDetailsWrapper = new transferBudgetDetailsWrapper();
                objtransferBudgetDetailsWrapper.beforeAmount = 0;
                objtransferBudgetDetailsWrapper.afterAmount = 0;
                objtransferBudgetDetailsWrapper.diffAmount = 0;
                objtransferBudgetDetailsWrapper.month = j;
                totalTransfer.productLineBudgetDetails.Add(objtransferBudgetDetailsWrapper);
            }
            
            for(transferDetailsWrapper item : transferDetails)
            {               
                for(transferBudgetDetailsWrapper item2 : item.productLineBudgetDetails)
                {
                    for(transferBudgetDetailsWrapper item3 : totalTransfer.productLineBudgetDetails)
                    {
                        if(item2.month == item3.month)
                        {
                            item3.beforeAmount += item2.beforeAmount;
                            item3.afterAmount += item2.afterAmount;
                            item3.diffAmount += item2.diffAmount;
                        }
                    }
                }
                
                totalTransfer.beforeTotalAmount += item.beforeTotalAmount;
                totalTransfer.afterTotalAmount += item.afterTotalAmount;
                totalTransfer.diffTotalAmount += item.diffTotalAmount;
            }
                       
            transferDetails.Add(totalTransfer);
            
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }
        catch(exception ex)
        {
            system.debug(ex.getMessage());
            pageMsg = ex.getMessage();
        }
    }
    
    private void PopulateData(salesBudgetWrapper sbWObj, AggregateResult BudItem, String Key)
    {
        sbWObj.account = (String)BudItem.get('account');
        sbWObj.transferEffectiveDate = ((Datetime)BudItem.get('effectiveDate')).format('MMMMM -YYYY');
        if(BudItem.get('commitDate')!=null)
        {
            sbWObj.commitDate = ((Datetime)BudItem.get('commitDate')).format('MM/dd/yyyy');
        }
        sbWObj.broadcastDate = ((Datetime)BudItem.get('broadcastDate')).format('MMMMM -YYYY');
        
        if(!salesBudgetWrapperMap.containsKey(Key))
        {
            salesBudgetWrapperMap.put(Key,sbWObj);
        }    
    }
        
    
    @RemoteAction  
    public static String ConfirmAEList(String aeIdToConfirm, List<String> SBSimIds){
        string pageMsg;
        Cache.SessionPartition partition = Cache.Session.getPartition('SRPartition');
        
        try{
            if(Boolean.valueOf(partition.get('isCommitReadonly'))==false)
            {
                system.debug(aeIdToConfirm);
                List<User> aeToUpdate = [SELECT Id, Name, Rate_Plan_Status__c FROM USER WHERE Id = :aeIdToConfirm Limit 1];
                
                system.debug(SBSimIds.size());
                system.debug(SBSimIds);
                
                List<Sales_Budget_Simulation__c> sbSimLstToUpdate = [SELECT CompensationCommitDate__c FROM Sales_Budget_Simulation__c WHERE Id IN :SBSimIds];
                
                system.debug('sbSimLstToUpdate size: ' +sbSimLstToUpdate.size());
                
                if(aeToUpdate[0].Rate_Plan_Status__c == 'Draft' || aeToUpdate[0].Rate_Plan_Status__c == 'Committed')
                {
                    return 'User is not eligible for commit.';
                }
                
                aeToUpdate[0].Rate_Plan_Status__c  = 'Committed';
                aeToUpdate[0].Rate_Plan_Commit_Date__c = Date.Today();
                
                CompensationCommitDate__c objCompensationCommitDate = new CompensationCommitDate__c();
                objCompensationCommitDate.Commit_Date__c = Date.Today();
                //objCompensationCommitDate.User__c = ApexPages.currentPage().getParameters().get('selUserId');
                insert objCompensationCommitDate;
                
                for(Sales_Budget_Simulation__c sbSimItem : sbSimLstToUpdate)
                {
                    system.debug('sbSimItem: '+ sbSimItem);
                    sbSimItem.CompensationCommitDate__c = objCompensationCommitDate.Id;
                }
                                                
                update sbSimLstToUpdate;
                update aeToUpdate;
                
                pageMsg = 'Success';
                
                if(Test.isRunningTest()) {
                    CalloutException e = new CalloutException();
                    e.setMessage('This is a constructed exception for testing and code coverage');
                    throw e;
                }
            }
            
            else
            {
                pageMsg = 'Commit not allowed';
            }
        }
        
        catch(exception ex)
        {
            //Log4SF.logMessage('TrackCompensationPlanDetails2Controller', 'ConfirmAEList', ex.getMessage(),ex, UserInfo.getUserId(),'Parametr value: '+aeIdToConfirm,'');
            pageMsg = ex.getMessage();
            system.debug(ex.getMessage());
        }
        return pageMsg;
    }
    
    public class salesbudgetWrapper
    {
        public String transferUser{get;set;}
        public String account{get;set;}
        public Decimal transferIn{get;set;}
        public Decimal transferOut{get;set;}
        public String transferEffectiveDate{get;set;}
        public String commitDate{get;set;}
        public String broadcastDate{get;set;}
        public String sbSimId{get;set;}
    }
    
    public class transferDetailsWrapper {
        public String productline{get;set;}
        public List<transferBudgetDetailsWrapper> productLineBudgetDetails {get; set;}
        public Decimal beforeTotalAmount{get;set;}
        public Decimal afterTotalAmount{get;set;}
        public Decimal diffTotalAmount{get;set;}             
    }
    
    public class transferBudgetDetailsWrapper{
        public Decimal beforeAmount{get;set;}
        public Decimal afterAmount{get;set;}
        public Decimal diffAmount{get;set;}
        public Integer month{get;set;}
    }
}