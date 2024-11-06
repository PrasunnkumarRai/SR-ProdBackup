public class ListManagementController {
    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled(Cacheable = false)
    public static String getAccountDMAs(integer index, List < String > AccountIDs, List < String > DMAs, Integer pageSize) {
        try{
             //integer blockSize = Integer.valueOf(System.label.ListManagementControllerBlockSize);
        Integer blockSize = pageSize;
        String jsonDT = '';
        List < Account > resultsDMA = new List < Account > ();
        List < Integer > resultsCount = new List < Integer > ();
        List < String > includesList = new List < String > ();
        integer IntValqueryStringCount = 0;
        String queryStringCount;
        if (AccountIDs != null && AccountIDs.size() > 0) {
            resultsDMA = Database.Query('SELECT Id,Name,Open_DMAs__c FROM Account WHERE ID IN :AccountIDs ORDER BY NAME LIMIT :blockSize OFFSET :index');
            queryStringCount = 'SELECT count() FROM Account WHERE ID IN :AccountIDs LIMIT :blockSize OFFSET :index';
            IntValqueryStringCount = Database.countQuery(queryStringCount);
        }
        if (DMAs != null && DMAs.size() > 0) {
            for (string dma: DMAs) {
                dma = '\'' + dma + '\'';
                system.debug('dma: ' + dma);
                includesList.add(dma);
            }

            String queryString = 'SELECT Id,Name,Open_DMAs__c FROM Account WHERE Open_DMAs__c INCLUDES(';
            for (String includeValue: includesList) {
                queryString += includeValue + ',';
            }
            queryString = queryString.removeEnd(',') + ') AND ID NOT IN: AccountIDs ORDER BY Name LIMIT :blockSize OFFSET :index';
            resultsDMA.addAll((List < Account > ) Database.query(queryString));

            queryStringCount = 'SELECT count() FROM Account WHERE Open_DMAs__c INCLUDES(';
            for (String includeValue: includesList) {
                queryStringCount += includeValue + ',';
            }
            queryStringCount = queryStringCount.removeEnd(',') + ') OR ID IN: AccountIDs ';
            IntValqueryStringCount = Database.countQuery(queryStringCount);
        }

        AccountDTWrapper objDT = new AccountDTWrapper();
        objDT.accounts = resultsDMA;
        objDT.totalRecords = IntValqueryStringCount;
        jsonDT = JSON.serialize(objDT);
        System.debug('resultsDMA.size() ' + resultsDMA.size());
        System.debug('jsonDT ' + jsonDT);
        return jsonDT;
        }catch(Exception ex){
            Log4SF.logMessage('ListManagementController','getAccountDMAs',ex.getMessage(),ex,UserInfo.getUserId(),'');
            return null;
        }
       
    }

    @AuraEnabled(Cacheable = false)
    public static List < Account > getAccountDetails(List < String > accountIds) {
        try {
            return [SELECT Id, Name, Open_DMAs__c FROM Account WHERE Id IN: accountIds];
        } catch (Exception e) {
            Log4SF.logMessage('ListManagementController','getAccountDetails',e.getMessage(),e,UserInfo.getUserId(),'');
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable = true)
    public static List < LookupSearchResult > getAccounts(String searchTerm, List < String > selectedIds, List < String > selectedIAEds) {
        System.debug('searchTerm ' + searchTerm);
        System.debug('selectedIds ' + selectedIds);
        System.debug('selectedIAEds ' + selectedIAEds);
        try{
            String accSearchKey = searchTerm;
        accSearchKey += '*';
        List < List < SObject >> searchResults;
        List < String > accountTeamMemberAccounts = new List < String > ();
        if (selectedIAEds != null && selectedIAEds.size() > 0) {
            for (AccountTeamMember atm: [SELECT ID, AccountId, UserId FROM AccountTeamMember WHERE UserId IN: selectedIAEds]) {
                accountTeamMemberAccounts.add(atm.AccountId);
            }
            searchResults = [
                FIND: accSearchKey
                IN NAME FIELDS
                RETURNING
                Account(Id, Name, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode WHERE id NOT IN: selectedIds AND id IN: accountTeamMemberAccounts)
                LIMIT: MAX_RESULTS
            ];
        } else {
            searchResults = [
                FIND: accSearchKey
                IN NAME FIELDS
                RETURNING
                Account(Id, Name, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode WHERE id NOT IN: selectedIds)
                LIMIT: MAX_RESULTS
            ];
        }
        System.debug('searchResults ' + searchResults);
        List < LookupSearchResult > results = new List < LookupSearchResult > ();
        String accIcon = 'standard:account';
        Account[] accounts = ((List < Account > ) searchResults[0]);
        for (Account acc: accounts) {
            results.add(
                new LookupSearchResult(
                    acc.Id,
                    'Account',
                    accIcon,
                    acc.Name,
                    acc.BillingStreet + ' ' + acc.BillingCity + ' ' + acc.BillingState + ' ' + acc.BillingPostalCode + ' ' + acc.BillingCountry
                )
            );
        }
        System.debug('results ' + results);
        return results;
        }catch(Exception ex){
            Log4SF.logMessage('ListManagementController','getAccounts',ex.getMessage(),ex,UserInfo.getUserId(),'');
            return null;
        }
       
        
    }

    @AuraEnabled
    public static List < LookupSearchResult > getDMAValues(String searchTerm, List < String > selectedIds) {
        System.debug('searchTerm ' + searchTerm);
        System.debug('selectedIds ' + selectedIds);
        try{
            List < String > DmaValues = new List < String > ();
        for (Schema.PicklistEntry pickVal: Opportunity.DMA__c.getDescribe().getPicklistValues()) {
            System.debug('pickVal: ' + pickVal);
            if (pickVal.getValue().toLowerCase().contains(searchTerm.toLowerCase()) && pickVal.isActive() && !selectedIds.contains(pickVal.getValue())) {
                DmaValues.add(pickVal.getValue());
            }
        }
        System.debug('DmaValues::' + DmaValues);
        List < LookupSearchResult > results = new List < LookupSearchResult > ();
        String accIcon = 'standard:account';
        for (String dma: DmaValues) {
            results.add(new LookupSearchResult(dma, '', '', dma, ''));
        }
        System.debug('results ' + results);
        return results;
        }catch(Exception ex){
            Log4SF.logMessage('ListManagementController','getDMAValues',ex.getMessage(),ex,UserInfo.getUserId(),'');
            return null;
        }
        
    }

    @AuraEnabled(Cacheable = false)
    public static List < map < String, Object >> getAccountTeamMembers(List < String > accIds, List < String > aeIds) {
        System.debug('accIds list:::' + accIds);
        System.debug('aeIds list:::' + aeIds);
        try{
            map < String, object > data = new map < String, object > ();
            String atmInformation;
            list < map < String, Object >> atmList = new list < map < String, Object >> ();
            List < AccountTeamMember > atms;
            List < Id > atmUsers = new List < Id > ();
            List < Id > atmAccounts = new List < Id > ();
            Map < string, User > mapUser = new Map < string, User > ();
            Map < String, List < Sales_Budget__c >> sbMap = new Map < String, List < Sales_Budget__c >> ();
            Map < String, List < Revenue__c >> revMap = new Map < String, List < Revenue__c >> ();
            Map < Id, List < Account_Transfer_Mapping__c >> axtMap = new Map < Id, List < Account_Transfer_Mapping__c >> ();
            Map < String, List < Account_SAM_Mapping__c >> samMap = new Map < String, List < Account_SAM_Mapping__c >> ();
            Map < String, List < Account_Trends__c >> accTrendsMap = new Map < String, List < Account_Trends__c >> ();
            Integer currentBudgetYear = Integer.valueof(Label.BudgetCurrentYear) - 1;
    
            if (accIds != null && accIds.size() > 0 && aeIds != null && aeIds.size() > 0) {
                atms = [SELECT Id, UserId, Title, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel, AccountId, User.Name, Account.Name,
                    Account.Open_DMAs__c, Account.RecordType.Name
                    FROM AccountTeamMember WHERE TeamMemberRole != 'Interim AE'
                    AND AccountId IN: accIds AND UserId IN: aeIds order by Account.Name asc
                ];
            } else if (accIds != null && accIds.size() > 0) {
                atms = [SELECT Id, UserId, Title, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel, AccountId, User.Name, Account.Name,
                    Account.Open_DMAs__c, Account.RecordType.Name
                    FROM AccountTeamMember WHERE TeamMemberRole != 'Interim AE'
                    AND AccountId IN: accIds order by Account.Name asc
                ];
            } else if (aeIds != null && aeIds.size() > 0) {
                atms = [SELECT Id, UserId, Title, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel, AccountId, User.Name, Account.Name,
                    Account.Open_DMAs__c, Account.RecordType.Name
                    FROM AccountTeamMember WHERE TeamMemberRole != 'Interim AE'
                    AND UserId IN: aeIds order by Account.Name asc
                ];
            }
            System.debug('AccountTeamMember list Size:::' + atms.size());
    
            for (AccountTeamMember atm: atms) {
                atmUsers.add(atm.UserId);
                atmAccounts.add(atm.AccountId);
            }
            if (!atmUsers.isEmpty()) {
                for (User objUser: [SELECT Id, Name, Sales_Office__c, Division__c, Region__c FROM User WHERE Id in: atmUsers]) {
                    mapUser.put(objUser.Id, objUser);
                }
            }
    
            //Revenue
            for (Revenue__c rev: [Select Id, Account_Executive__c, Name, Advertiser__c, Advertiser__r.Name, Account_Executive__r.Name, Net_Actual_Amount__c, Broadcast_Month_Date__c
                    from Revenue__c
                    where Account_Executive__c in: atmUsers and advertiser__c IN: atmAccounts and Net_Actual_Amount__c > 0 And IsNews__c = false
                    and(CALENDAR_YEAR(Broadcast_Month_Date__c) =: currentBudgetYear OR CALENDAR_YEAR(Broadcast_Month_Date__c) =: currentBudgetYear + 1) limit 45000
                ]) {
                if (revMap.containsKey(rev.advertiser__c + ':' + rev.Account_Executive__c)) {
                    revMap.get(rev.advertiser__c + ':' + rev.Account_Executive__c).add(rev);
                } else {
                    revMap.put(rev.advertiser__c + ':' + rev.Account_Executive__c, new List < Revenue__c > {
                        rev
                    });
                }
            }
    
            //Account Team Member
            for (Account_Transfer_Mapping__c item: [Select Id, Name, From_User__c, From_User__r.Name, To_User__c, To_User__r.Name, Account__c, Account__r.Name, Account_Transfer_Simulation__r.Name, Account_Transfer_Simulation__r.Status__c, Transfer_Effective_Date__c
                    from Account_Transfer_Mapping__c where(From_User__c in: atmUsers Or To_User__c in: atmUsers) and Account__c IN: atmAccounts and Account_Transfer_Simulation__r.Status__c NOT IN('Transfer Completed', 'Denied') limit 45000
                ]) {
                if (axtMap.containsKey(item.Account__c)) {
                    axtMap.get(item.Account__c).add(item);
                } else {
                    axtMap.put(item.Account__c, new List < Account_Transfer_Mapping__c > {
                        item
                    });
                }
            }

            System.debug('ATM records::'+ atmAccounts.size());
            //Tier Mapping
            for (Account_SAM_Mapping__c samDes: [SELECT Id, User__c, Account__c, Tier_Designation__c
                    From Account_SAM_Mapping__c
                    WHERE Account__c in: atmAccounts 
                ]) {
                string key = samDes.Account__c;
                if (samMap.containsKey(key)) {
                    samMap.get(key).add(samDes);
                } else {
                    samMap.put(key, new List < Account_SAM_Mapping__c > {
                        samDes
                    });
                }
            }
    
            //Account Health Indicator
            for (Account_Trends__c accTrend: [SELECT Id, Account__c, Account_Health__c, AccountExecutive__c, Name, Total_Net_Actual_Revenue__c, PY_Total_Net_Actual_Revenue__c, AccountExecutive__r.Name, Account__r.Name
                    From Account_Trends__c
                    WHERE AccountExecutive__c in: atmUsers And Account__c in: atmAccounts
                ]) { //AND CreatedDate = This_Year And CreatedDate = This_Month
                string key = accTrend.AccountExecutive__c + ':' + accTrend.Account__c;
                if (accTrendsMap.containsKey(key)) {
                    accTrendsMap.get(key).add(accTrend);
                } else {
                    accTrendsMap.put(key, new List < Account_Trends__c > {
                        accTrend
                    });
                }
            }
    
            for (AccountTeamMember atm: atms) {
                System.debug('atm: ' + atm);
                map < String, object > accTeamMemData = new map < String, object > ();
                User u = mapUser.get(atm.UserId);
                atmInformation = atm.AccountId + ':::' + atm.UserId;
                accTeamMemData.put('Name', atm.User.Name);
                accTeamMemData.put('UserId', atm.UserId);
                accTeamMemData.put('TeamMemberRole', atm.TeamMemberRole);
                accTeamMemData.put('OpenDMAs', atm.Account.Open_DMAs__c);
                accTeamMemData.put('AccountAccessLevel', atm.AccountAccessLevel);
                accTeamMemData.put('OpportunityAccessLevel', atm.OpportunityAccessLevel);
                accTeamMemData.put('atmId', atm.Id);
                accTeamMemData.put('atmAccountId', atm.AccountId);
                accTeamMemData.put('atmInformation', atmInformation);
                accTeamMemData.put('HasAccountTrend', String.valueOf(accTrendsMap.containsKey(atm.UserId + ':' + atm.AccountId)).toUpperCase());
                accTeamMemData.put('AccountTrendRecords', accTrendsMap.containsKey(atm.UserId + ':' + atm.AccountId) == true ? accTrendsMap.get(atm.UserId + ':' + atm.AccountId) : new List < Account_Trends__c > ());
                accTeamMemData.put('HasPendingSalesBudget', String.valueOf(sbMap.containsKey(atm.AccountId + ':' + atm.UserId)).toUpperCase());
                accTeamMemData.put('HasPendingAxt', String.valueOf(axtMap.containsKey(atm.AccountId)).toUpperCase());
                accTeamMemData.put('AXTRecords', axtMap.containsKey(atm.AccountId) == true ? axtMap.get(atm.AccountId) : new List < Account_Transfer_Mapping__c > ());
                accTeamMemData.put('SBRecords', sbMap.containsKey(atm.AccountId + ':' + atm.UserId) == true ? sbMap.get(atm.AccountId + ':' + atm.UserId) : new List < Sales_Budget__c > ());
                accTeamMemData.put('AccountName', atm.Account.Name);
                accTeamMemData.put('AccountRecType', atm.Account.RecordType.Name);
                accTeamMemData.put('AccountId', atm.AccountId);
                accTeamMemData.put('TierDesignation', samMap.containsKey(atm.AccountId) == true ? samMap.get(atm.AccountId) : new List < Account_SAM_Mapping__c > ());
                accTeamMemData.put('HasRevenue', String.valueOf(revMap.containsKey(atm.AccountId + ':' + atm.UserId)).toUpperCase());
                accTeamMemData.put('RevenueRecords', revMap.containsKey(atm.AccountId + ':' + atm.UserId) == true ? revMap.get(atm.AccountId + ':' + atm.UserId) : new List < Revenue__c > ());
                atmList.add(accTeamMemData);
            }
            System.debug(atmList);
            return atmList;
        }catch(Exception ex){
            Log4SF.logMessage('ListManagementController','getAccountTeamMembers',ex.getMessage(),ex,UserInfo.getUserId(),'');
            return null;
        }
       
    }

    @AuraEnabled
    public static string deleteAccountTeamMembers(List < Object > records) {
        System.debug('record: ' + records);
        try{
            List < Accountteammember > acctmDeleteList = new List < Accountteammember > ();
        List < Account_SAM_Mapping__c > samDeleteList = new List < Account_SAM_Mapping__c > ();
        set < String > userIds = new set < String > ();
        set < String > atmAccountIds = new set < String > ();
        set < String > atmIds = new set < String > ();
        set < String > samIds = new set < String > ();

        for (object rec: records) {
            Map < Object, Object > data = (Map < Object, Object > ) rec;
            System.debug('data: ' + data);
            wrapperClass recobj = new wrapperClass(data.get('userId'), data.get('accountId'), data.get('samId'), data.get('atmId'));
            System.debug('recobj: ' + recobj);
            if (String.isNotEmpty(recobj.userId) && String.isNotBlank(recobj.userId)) {
                userIds.add(recobj.userId);
            }
            if (String.isNotEmpty(recobj.accountId) && String.isNotBlank(recobj.accountId)) {
                atmAccountIds.add(recobj.accountId);
            }
            if (String.isNotEmpty(recobj.atmId) && String.isNotBlank(recobj.atmId)) {
                atmIds.add(recobj.atmId);
                Accountteammember atmRec = new Accountteammember();
                atmRec.Id = recobj.atmId;
                acctmDeleteList.add(atmRec);
            }
            if (String.isNotEmpty(recobj.samId) && String.isNotBlank(recobj.samId)) {
                samIds.add(recobj.samId);
                Account_SAM_Mapping__c samRec = new Account_SAM_Mapping__c();
                samRec.Id = recobj.samId;
                samDeleteList.add(samRec);
            }
        }
        System.debug('userIds ' + userIds);
        System.debug('atmAccountIds ' + atmAccountIds);
        System.debug('atmIds ' + atmIds);
        System.debug('samIds ' + samIds);
        System.debug('acctmDeleteList ' + acctmDeleteList);
        System.debug('samDeleteList ' + samDeleteList);

        Savepoint spAtmDelete = Database.setSavepoint();
        try {
            if (acctmDeleteList.size() > 0) {
                System.debug('Inside delete acctmDeleteList' + acctmDeleteList.size());
                Map < String, Object > inputs = new Map < String, Object > ();
                inputs.put('AccountTeamMember', acctmDeleteList);
                Flow.Interview.Remove_User_From_Account_Team flow1 = new Flow.Interview.Remove_User_From_Account_Team(inputs);
                flow1.start();
                //delete acctmDeleteList;
            }

            if (samDeleteList.size() > 0) {
                System.debug('Inside delete samDeleteList' + samDeleteList.size());
                delete samDeleteList;
            }
        } catch (Exception e) {
            Database.rollback(spAtmDelete);
            System.debug('********** Rollback Error Deleting Records: ' + e + ' Line Number: ' + e.getLineNumber());
            return e.getMessage();
        }
        return 'Success';
        }catch(Exception ex){
            Log4SF.logMessage('ListManagementController','deleteAccountTeamMembers',ex.getMessage(),ex,UserInfo.getUserId(),'');
            return null;
        }
        
    }

       @AuraEnabled
    public static List<Account> updateOpenDMAs(List<Account> accounts) {
        if (accounts == null || accounts.isEmpty()) {
            throw new AuraHandledException('Account list cannot be null or empty.');
        }
        try {
            system.debug('accounts: ' + accounts);
            update accounts;
            return accounts;
        } catch (Exception e) {
            Log4SF.logMessage('ListManagementController', 'updateOpenDMAs', e.getMessage(), e, UserInfo.getUserId(), '');
            throw new AuraHandledException(e.getMessage());
        }
    }


    public class wrapperClass {
        public String userId;
        public String accountId;
        public String atmId;
        public String samId;
        wrapperClass(object userId, object accountId, object samId, object atmId) {
            this.userId = (string) userId;
            this.accountId = (string) accountId;
            this.atmId = (string) atmId;
            this.samId = (string) samId;
        }
    }

    public class AccountDTWrapper {
        public List < Account > accounts {
            get;
            set;
        }
        public Integer totalRecords {
            get;
            set;
        }
    }
}