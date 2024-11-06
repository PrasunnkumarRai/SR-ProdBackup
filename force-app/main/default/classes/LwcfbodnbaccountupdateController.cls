public class LwcfbodnbaccountupdateController {
    public static string[] SelectedAccountIDs{get;set;}
    Public List<String> ids;
    Public Integer sizeOfAcc{get;set;}
    
    public LwcfbodnbaccountupdateController(ApexPages.StandardSetController listcontroller){
        SelectedAccountIDs = new string[]{};
        for(Account acc : (Account[])listcontroller.getSelected()){
            SelectedAccountIDs.add(acc.Id);
        }
         sizeOfAcc = SelectedAccountIDs.size();
         System.debug('SelectedAccountIDs in constructor: ' + SelectedAccountIDs);
         System.debug('sizeOfAcc in constructor: ' + sizeOfAcc);
    }


    @AuraEnabled
    public static List<Account> getAccountDetails(List<String> accountIds){
        System.debug(accountIds);
        Set<String> idOfAccList = new Set<String>();
        for(String str:accountIds){
            idOfAccList.add(str.trim());
        }
        
        List<Account> accountList = new List<Account>();
        accountList = [SELECT Id,Name,DunsNumber__c,BillingCity,BillingPostalCode,BillingCountry,BillingState,BillingStreet,ShippingCity,ShippingCountry,ShippingPostalCode, Phone,Primary_Commodity__c,
        ShippingState,ShippingStreet,Website,AnnualRevenue,NumberOfEmployees,RecordType.Name,Prospect_Account__c,(SELECT ID, D_B_account__r.Name,    D_B_account__r.D_B_Account_Name__c,D_B_account__r.Confidence_Code__c,D_B_account__r.DUNSNumber__c,D_B_account__r.PrimaryCityName__c,D_B_account__r.PrimaryCountryName__c,D_B_account__r.PrimaryStreetAddress__c,D_B_account__r.PrimaryStateProvinceName__c,D_B_account__r.PrimaryAddressPostalCode__c,D_B_account__r.WebAddress__c,D_B_account__r.RevenueTrendYear__c,D_B_account__r.TelephoneNumber__c,D_B_account__r.EmployeeCountTotal__c, D_B_account__r.YearStarted__c, D_B_account__r.mostSeniorPrincipals__c, D_B_account__r.Tradestyle_Name_1__c, D_B_account__r.TradestyleName2__c, D_B_account__r.TradestyleName3__c FROM D_B_Account_Junctions__r  where D_B_account__r.Confidence_Code__c >= 5 Order By D_B_account__r.Confidence_Code__c DESC LIMIT 2)  FROM Account WHERE Id IN :accountIds]; 
       return accountList;
    }

    @AuraEnabled
    public static String getAdvertiserAgencyRepFirm(String accountId){
        System.debug(accountId);
        return [SELECT Id, Advertiser_Agency_Rep_Firm__c FROM Account_Request__c WHERE Id =:accountId LIMIT 1].Advertiser_Agency_Rep_Firm__c;
    }

    @AuraEnabled
    public static string updateAccountDetails(List<Account> accToUpdate){
        try {
            update accToUpdate;
            return 'OK';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String mergeAccs(String parentAcc, List<String> childAccs){
        List<Account_Bulk_Merge__c> abmRecords = new List<Account_Bulk_Merge__c>();

        for (String childId : childAccs) {
            Account_Bulk_Merge__c abmRecord = new Account_Bulk_Merge__c();
            abmRecord.Parent_Account__c = parentAcc;
            abmRecord.Child_Account__c = childId;
            abmRecords.add(abmRecord);
        }
        try {
            Database.insert(abmRecords);
        } catch (DmlException e) {
            System.debug('Error inserting merge records: ' + e.getMessage());
        }
        AccountBulkMerge abm = new AccountBulkMerge();
        abm.isLandscaping = false;
        String jobId = Database.executeBatch(abm, Integer.valueOf(System.Label.AccountMergeBatchSize));
        return jobId;
    }

    @AuraEnabled
    public static String getBatchJobStatus(String batchJobId){
        AsyncApexJob job = [SELECT Status FROM AsyncApexJob WHERE Id = :batchJobId];
        System.debug('job.Status' + job.Status);
        return job.Status;
    }


//srsf-4922 start MAPPING Account and dnb Account in DnB Junction object
    @AuraEnabled
    public static void upsertDNBAccountJunctionDetails(List<DUNSDataModel> dnbAccJunctions, String accountId) {
        System.debug('dnbAccJunctions: ' + dnbAccJunctions);
        System.debug('accountId: ' + accountId);

        Set<String> dunsNumbers = new Set<String>();
        Map<String, String> dunsToDunsAccIdMap = new Map<String, String>();
        Set<String> dunsNumberExisting = new Set<String>();
        List<D_B_Account_Junction__c> dnbAccountJunctionsToInsert = new List<D_B_Account_Junction__c>();

        try {
            for (DUNSDataModel dnbAcc : dnbAccJunctions) {
                dunsNumbers.add(dnbAcc.DUN);
            }
            System.debug('dunsNumbers: ' + dunsNumbers);

            List<D_B_account__c> dnbAccounts = [SELECT Id, DUNSNumber__c FROM D_B_account__c WHERE DUNSNumber__c IN :dunsNumbers];
            for (D_B_account__c dnbAcc : dnbAccounts) {
                dunsToDunsAccIdMap.put(dnbAcc.DUNSNumber__c, dnbAcc.Id);
            }
            System.debug('dunsToDunsAccIdMap: ' + dunsToDunsAccIdMap);

            Account acc = [SELECT Id, (SELECT D_B_Account__c, D_B_Account__r.DUNSNumber__c FROM D_B_Account_Junctions__r) FROM Account WHERE Id = :accountId];
            for (D_B_Account_Junction__c dnbJunction : acc.D_B_Account_Junctions__r) {
                dunsNumberExisting.add(dnbJunction.D_B_Account__r.DUNSNumber__c);
            }
            System.debug('dunsNumberExisting: ' + dunsNumberExisting);

            for (DUNSDataModel dnbAcc : dnbAccJunctions) {
                String dunsId = dunsToDunsAccIdMap.get(dnbAcc.DUN);
                if (dunsId != null && !dunsNumberExisting.contains(dnbAcc.DUN)) {
                    D_B_Account_Junction__c dnbAccountJunction = new D_B_Account_Junction__c();
                    dnbAccountJunction.Account__c = accountId;
                    dnbAccountJunction.D_B_Account__c = dunsId;
                    dnbAccountJunctionsToInsert.add(dnbAccountJunction);
                }
            }
            System.debug('dnbAccountJunctionsToInsert: ' + dnbAccountJunctionsToInsert);

            if (!dnbAccountJunctionsToInsert.isEmpty()) {
                insert dnbAccountJunctionsToInsert;
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
//srsf-4922 end

//srsf-4922 checking logger info for merge failed
@AuraEnabled
public static Logger__c getLoggerInformation(String parentRecordId){
    try {
        String query = 'select id, Message__c from Logger__c where Record_Id__c like \'%' + parentRecordId + '%\' And CreatedDate = TODAY order by CreatedDate desc limit 1';
        List<Logger__c> mergeFailedLog = Database.query(query);
        if (mergeFailedLog.isEmpty()) {
            return null;
        } else {
            return mergeFailedLog[0];
        }
       
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}
//     @AuraEnabled
// public static void upsertDNBAccountJunctionDetails(List<DUNSDataModel> dnbAccJunctions, String accountId) {
//     System.debug('dnbAccJunctions' + dnbAccJunctions);
//     System.debug('accountId' + accountId);
//     List<String> dunsNumbers = new List<String>();
//     Map<String, String> dunsToDunsAccIdMap = new Map<String, String>();
//     List<D_B_Account_Junction__c> dnbAccountJunctionsToUpsert = new List<D_B_Account_Junction__c>();
    
//     try {
//         for (DUNSDataModel dnbAcc : dnbAccJunctions) {
//             dunsNumbers.add(dnbAcc.DUN);
//         }
        
//         List<D_B_account__c> dnbAccounts = [SELECT Id, DUNSNumber__c FROM D_B_account__c WHERE DUNSNumber__c IN :dunsNumbers];
//         for (D_B_account__c dnbAcc : dnbAccounts) {
//             dunsToDunsAccIdMap.put(dnbAcc.DUNSNumber__c, dnbAcc.Id);
//         }
//         System.debug('dunsToDunsAccIdMap:::' + dunsToDunsAccIdMap);
        
//         for (DUNSDataModel dnbAcc : dnbAccJunctions) {
//             // Check for existing junction records to prevent duplicates
//             List<D_B_Account_Junction__c> existingJunctions = [SELECT Id FROM D_B_Account_Junction__c 
//                                                                WHERE Account__c = :accountId 
//                                                                AND D_B_Account__c = :dunsToDunsAccIdMap.get(dnbAcc.DUN)];
            
//             if (existingJunctions.isEmpty()) {
//                 D_B_Account_Junction__c dnbAccountJunction = new D_B_Account_Junction__c();
//                 dnbAccountJunction.Account__c = accountId;
//                 dnbAccountJunction.D_B_Account__c = dunsToDunsAccIdMap.get(dnbAcc.DUN);
//                 dnbAccountJunctionsToUpsert.add(dnbAccountJunction);
//             }
//         }
        
//         if (!dnbAccountJunctionsToUpsert.isEmpty()) {
//             upsert dnbAccountJunctionsToUpsert;
//         }

//     } catch (Exception e) {
//         throw new AuraHandledException(e.getMessage());
//     }
// }


    public class DUNSDataModel {

		@AuraEnabled
		public String name { get; set; }

		@AuraEnabled
		public String Phone { get; set; }

		@AuraEnabled
		public String Address { get; set; }

		@AuraEnabled
		public String DUN { get; set; }

		@AuraEnabled
		public String ConfidenceCode { get; set; }

		@AuraEnabled
		public String mostSeniorPrincipals { get; set; }

		@AuraEnabled
		public String website { get; set; }
		@AuraEnabled
		public String outofBusiness { get; set; }

		@AuraEnabled
		public Decimal EmployeeCount { get; set; }

		@AuraEnabled
		public Decimal Revenue { get; set; }

		@AuraEnabled
		public String MailingAddress { get; set; }

		@AuraEnabled
		public String operatingStatus { get; set; }

		@AuraEnabled
		public String ErrorMessage { get; set; }

		@AuraEnabled
		public Boolean isDataError { get; set; }

		@AuraEnabled
		public String billingStreet { get; set; }

		@AuraEnabled
		public String billingState { get; set; }

		@AuraEnabled
		public String billingCity { get; set; }

		@AuraEnabled
		public String billingZipCode { get; set; }

		@AuraEnabled
		public String billingCountry { get; set; }
	}

    
}
// @AuraEnabled
//     public static List<Account> getAccountsInChild(String selectedAccId){
//     System.debug('what accountList are coming :::: ' + selectedAccId);
//     List<Account> accountList = new List<Account>();
//     accountList = [SELECT Id,Name,DunsNumber__c,BillingCity,BillingPostalCode,BillingCountry,BillingState,BillingStreet,ShippingCity,ShippingCountry,ShippingPostalCode, 
//     ShippingState,ShippingStreet,Website,AnnualRevenue,NumberOfEmployees,(SELECT ID, D_B_account__r.Name,    D_B_account__r.D_B_Account_Name__c,D_B_account__r.Confidence_Code__c,D_B_account__r.DUNSNumber__c,D_B_account__r.PrimaryCityName__c,D_B_account__r.PrimaryCountryName__c,D_B_account__r.PrimaryStreetAddress__c,D_B_account__r.PrimaryStateProvinceName__c,D_B_account__r.PrimaryAddressPostalCode__c,D_B_account__r.WebAddress__c,D_B_account__r.RevenueTrendYear__c,D_B_account__r.TelephoneNumber__c,D_B_account__r.EmployeeCountTotal__c FROM D_B_Account_Junctions__r Order By D_B_account__r.Confidence_Code__c DESC)  FROM Account WHERE Id =: selectedAccId]; 
//     System.debug('accountList are coming in child ::: ' + accountList);
//     System.debug('what accountList are coming from Account :: ' + accountList.size());
//     return accountList;
// }