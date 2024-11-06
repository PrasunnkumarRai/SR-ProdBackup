/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-14-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global without sharing class AccountRequestFinanceAPIController {

  @AuraEnabled
  public static Account getNewAccount(String AccountId) {
    Account accId = new Account();
    accId = [Select Id, Name, DunsNumber__c, Primary_Commodity__c, Active__c, RecordType.Name, Account_Record_Type_Name__c, Agency__c, Count_of_Opportunities__c, Commodity_Codes__c, BillingAddress, BillingStreet, BillingCountry, BillingCity, BillingState, BillingPostalCode, Website, Phone from Account WHERE id =: AccountId];
    return accId;
  }

  @AuraEnabled
  public static D_B_account__c getDnBAccount(String DnBAccountId) {
    D_B_account__c accAddress = new D_B_account__c();
    accAddress = [Select Id, PrimaryAddress1__c, PrimaryStreetAddress__c, PrimaryCityName__c, PrimaryStateProvinceName__c, PrimaryAddressPostalCode__c, PrimaryCountryName__c
      from D_B_account__c WHERE id =: DnBAccountId
    ];
    return accAddress;
  }

  @AuraEnabled
  public static List < Account > getSFAccount(Account detail) {
    System.debug('detail ' + detail);
    System.debug('detail ' + detail.BillingStreet);
    System.debug('detail ' + detail.RecordType.Name);
    System.debug('detail ' + detail.Primary_Commodity__c);
    List < Account > accSf = new List < Account > ();
    Map < Id, Account > FinalAccountMap = new Map < Id, Account > ();
		List<Account> dupList = new List<Account>();
		Map < Id, Account > accNameMap = new Map < Id, Account > ();
    String accountName = detail.Name;
    Integer spaceIndex = accountName.indexOf(',');
    String firstWord;

    if (spaceIndex != -1) {
      firstWord = accountName.substring(0, spaceIndex);
    } else {
      firstWord = accountName;
    }
    List < List < Account >> searchResults = [FIND: firstWord
      IN NAME FIELDS
      RETURNING Account(Id, Name, Phone, DunsNumber__c, RecordTypeId, Primary_Commodity__c, Commodity_Codes__c, Account_Record_Type_Name__c, BillingAddress, Website,Prospect_Account__c WHERE Id !=: detail.Id AND RecordType.Name =: detail.RecordType.Name AND Primary_Commodity__c =: detail.Primary_Commodity__c ORDER BY Name ASC)
    ];

    // Iterate through search results
    for (List < Account > accounts: searchResults) {
      for (Account acc: accounts) {
        accNameMap.put(acc.Id, acc);
      }
    }
    

    Account acct = new Account(name=accountName, Primary_Commodity__c = detail.Primary_Commodity__c, Website = detail.Website);
    List<Account> acctList = new List<Account>();
    acctList.add(acct);
    for (Datacloud.MatchRecord matchRecord :findDuplicateAccountsController.finDuplicateAccounts(acctList)){
        system.debug(matchRecord.getRecord());
        Account duplicateAccount = (Account)matchRecord.getRecord();
        if(detail.Id!=duplicateAccount.Id){
           dupList.add(duplicateAccount);
        }
    }

		if (!dupList.isEmpty()) {
			List<Account> duplicateRecords = [SELECT Id, Name, Phone, DunsNumber__c, RecordTypeId, Primary_Commodity__c, Commodity_Codes__c, Account_Record_Type_Name__c, BillingAddress, Website,Prospect_Account__c  FROM Account WHERE Id IN :dupList];
			for (Account duplicateRecord : duplicateRecords) {
					if(duplicateRecord.RecordTypeId.equals(detail.RecordTypeId) ){
						accNameMap.put(duplicateRecord.Id, duplicateRecord);
					}
			}
	} else {
			System.debug('No duplicate records found.');
	}
    
      
    system.debug('accNameMap@@@@  ' + accNameMap);
    // Map<ID, Account> accNameMap = new Map<ID, Account> ([select Id, name, Phone, DunsNumber__c, RecordTypeId, Primary_Commodity__c, Commodity_Codes__c, Account_Record_Type_Name__c, BillingAddress, Website from Account where Name Like :accountName AND Id != :detail.Id
    //                                                     AND RecordType.Name = :detail.RecordType.Name Order By Name ASC]);
    Map < Id, Account > accAddressMap = new Map < Id, Account > ();
    if ((!String.isNotEmpty(detail.BillingStreet) || !String.isNotBlank(detail.BillingStreet)) || (!String.isNotEmpty(detail.BillingPostalCode) || !String.isNotBlank(detail.BillingPostalCode))) {
      accAddressMap = new Map < Id, Account > ([select Id, name, DunsNumber__c, Phone, Owner.Name, Account_Record_Type_Name__c, RecordTypeId, Commodity_Codes__c, Primary_Commodity__c, BillingAddress, Website,Prospect_Account__c from Account where Id !=: detail.Id AND BillingCity LIKE: detail.BillingCity AND RecordType.Name =: detail.RecordType.Name AND BillingCountry LIKE: detail.BillingCountry AND BillingState LIKE: detail.BillingState LIMIT 100]);
    } else {
      accAddressMap = new Map < Id, Account > ([select Id, name, DunsNumber__c, Phone, Owner.Name, Account_Record_Type_Name__c, RecordTypeId, Commodity_Codes__c, Primary_Commodity__c, BillingAddress, Website,Prospect_Account__c from Account where Id !=: detail.Id
        AND RecordType.Name =: detail.RecordType.Name AND(BillingStreet LIKE: detail.BillingStreet OR(BillingCity LIKE: detail.BillingCity AND BillingCountry LIKE: detail.BillingCountry AND BillingState LIKE: detail.BillingState AND BillingPostalCode =: detail.BillingPostalCode)) LIMIT 100
      ]);
    }

    System.debug('accNameMap:' + accNameMap);
    System.debug('accAddressMap:' + accAddressMap);

    Map < Id, Account > uniqueaccNameMap = accNameMap.deepClone();
    Map < Id, Account > uniqueaccAddressMap = accAddressMap.deepClone();
    uniqueaccNameMap.keySet().retainAll(uniqueaccAddressMap.keySet());
    uniqueaccAddressMap.keySet().retainAll(uniqueaccNameMap.keySet());
    accNameMap.keySet().removeAll(uniqueaccNameMap.keySet());
    accAddressMap.keySet().removeAll(uniqueaccAddressMap.keySet());
    FinalAccountMap.putAll(accNameMap);
    FinalAccountMap.putAll(uniqueaccNameMap);

    return FinalAccountMap.values();
  }

  @AuraEnabled
  public static List < D_B_Account_Junction__c > getAccDbJuncData(String AccountId) {
    System.debug('AccountId: ' + AccountId);
    List < D_B_Account_Junction__c > dbJunc = new List < D_B_Account_Junction__c > ();
    dbJunc = [Select Account__r.Id, Account__r.Name, Account__r.Phone, Account__r.BillingAddress, Account__r.DunsNumber__c, Account__r.Website, Account__r.Primary_Commodity__c, Account__r.Commodity_Codes__c, Account__r.Active__c, Account__r.Agency__c, Account__r.Account_Record_Type_Name__c, D_B_account__r.Name, D_B_account__r.TelephoneNumber__c, D_B_account__r.MailingAddressCity__c, D_B_account__r.DUNSNumber__c, D_B_account__r.MailingAddress1__c, D_B_account__r.MailingAddressPostalCode__c, D_B_account__r.MailingStateName__c, D_B_account__r.Mailing_Address_Country_Region_Code__c, D_B_account__r.Id, D_B_account__r.WebAddress__c, D_B_account__r.Confidence_Code__c, D_B_account__r.PrimaryAddress1__c, D_B_account__r.PrimaryStreetAddress2__c, D_B_account__r.PrimaryCityName__c, D_B_account__r.PrimaryAddressCountryRegion_Code__c, D_B_account__r.PrimaryCountryName__c, D_B_account__r.PrimaryAddressPostalCode__c, D_B_account__r.PrimaryStateProvinceName__c
      from D_B_Account_Junction__c where Account__r.Id =: AccountId
    ];
    //System.debug('dbJunc' + dbJunc[0].Account__r.Name); 
    return dbJunc;

  }

  @AuraEnabled
  public static Account updateAccountInfo(Account acc) {
    System.debug('acc@@ ' + acc.Id);
    if (acc != null) {
      Account updatedacc = new Account();
      updatedacc = [Select Id, Name, DunsNumber__c, Website, BillingAddress, Phone, Agency__r.Name, Credit_Status__c, Billing_Change_Status__c, Bill_To__c, Number_of_copies__c, Billing_Co_op__c, Billing_Preference__c, Send_Zero_Invoices__c, Billing_Type__c, Invoice_Delivery_Method__c, Billing_Email__c, Special_Billing_Instructions__c FROM Account WHERE Id =: acc.Id];
      System.debug('updatedacc@@@@@' + updatedacc);
      return updatedacc;
    }
    return null;
  }

  @AuraEnabled
  public static Account updateAccount(Account acc) {
    System.debug('acc@@ ' + acc.Name);
    if (acc != null) {
      //Account accInfo = new Account();
      //accInfo.Id = acc.Id;
      //accInfo.Name = acc.Name;
      //accInfo.Website = acc.Website;
      ////accInfo.BillingAddress = acc.BillingAddress;
      //accInfo.DunsNumber = acc.Dunns;
      //accInfo.Phone = acc.Phone;
      //accInfo.Credit_Status__c = acc.Credit_Status__c;
      ////accInfo.Mailing_Address__c = acc.MailingAddress;
      //accInfo.Bill_To__c = acc.BillTo;
      //accInfo.Number_of_copies__c = acc.NumberOfCopies;
      //accInfo.Invoice_Delivery_Method__c = InvoiceDelivery;
      //accInfo.Billing_Email__c = acc.BillingEmail;
      //accInfo.Special_Billing_Instructions__c = acc.SpecialInstriuctions;
      //accInfo.Billing_Preference__c = acc.BillingPreference;
      //accInfo.Send_Zero_Invoices__c = acc.SendZero;
      //accInfo.Billing_Type__c = acc.BillingType;
      //System.debug('acc Info @@@@@@@@@' + acc.Id);
      //System.debug('acc Info Name @@@@@@@@@' + acc.Name);
      update acc;
      Account accId = new Account();
      accId = [select Id FROM Account WHERE Id =: acc.Id];
      return accId;
    }
    return null;
  }

  @AuraEnabled
  public static Account_Request__c mergeAccount(String ParentId, String ChildId, String AccountRequestId) {
    RecordType mergeRecType = [SELECT ID, NAME, DeveloperName FROM RecordType WHERE DeveloperName = 'Account_Merge_Request'
      LIMIT 1
    ];
    Account_Request__c parentAccountDetail = [SELECT ID, Account_Executive__c FROM Account_Request__c WHERE ID =: AccountRequestId LIMIT 1];
    Account_Request__c mergingRequest = new Account_Request__c();
    mergingRequest.Duplicate_Account__c = ChildId;
    mergingRequest.Advertiser_Agency_Rep_Firm__c = ParentId;
    mergingRequest.RecordTypeId = mergeRecType.Id;
    mergingRequest.Account_Executive__c = parentAccountDetail.Account_Executive__c; //005410000036Ph4AAE
    mergingRequest.OwnerId = parentAccountDetail.Account_Executive__c;
    System.debug('Account_Executive__c: ' + mergingRequest);
    insert mergingRequest;
    System.debug('Parent Id: ' + ParentId);
    System.debug('Child Id: ' + ChildId);
    System.debug('request Id: ' + mergingRequest.Id);
    Id req;
    req = mergingRequest.Id;
    Account_Request__c reqId = new Account_Request__c();
    reqId = [Select id FROM Account_Request__c where Id =: req];
    System.debug('Account Merge Request Id:' + reqId);
    return reqId;
  }

  @AuraEnabled(Cacheable = true)
  public static List < LookupSearchResult > getAccountList(String searchTerm,
    List < String > selectedIds,
    String searchType) {
    System.debug('accData@@@@@@@@@@' + searchTerm);

    //String acc =: '%accData%';
    List < Account > accountList = new List < Account > ();
    accountList = [Select id, name, RecordType.Name from Account where Name LIKE: '%' + searchTerm + '%'
      AND RecordType.Name = 'Agency Account'
    ];

    String accountIcon = 'standard:account';
    List < LookupSearchResult > results = new List < LookupSearchResult > ();

    for (Account account: accountList) {
      results.add(
        new LookupSearchResult(
          account.Id,
          'Account',
          accountIcon,
          account.Name,
          account.RecordType.Name)
      );

    }
    System.debug('Lookup results are: ' + results);
    return results;
  }

  @AuraEnabled
  public static String accountActivate(String accounId) {
    System.debug('accountId' + accounId);
    Account acc = new Account();
    Account acc2 = new Account();
    Account_Request__c accountReq = new Account_Request__c();
    acc.Id = accounId;
    System.debug('acc.Id' + acc.Id);
    acc.Active__c = true;
    acc2 = [Select name, (Select id, name, Status__c from Account_Requests__r) from Account where id =: accounId];
    System.debug('acc2' + acc2.Account_Requests__r[0].Id);
    accountReq.Id = acc2.Account_Requests__r[0].Id;
    //accountReq.Status__c = 'Approved';
    update acc;
    update accountReq;
    System.debug('acc2' + acc2.Account_Requests__r[0].Status__c);
    System.debug('acc ' + acc);
    return 'Account Active';
  }

  @AuraEnabled(Cacheable = true)
  public Static Account getRecordType(String recordtypeName) {
    System.debug('recordType@@@@@@@' + recordtypeName);
    if (recordtypeName != null) {
      Account acc = new Account();
      acc = [select Id, Name, RecordTypeId FROM Account Where RecordType.Name =: recordtypeName LIMIT 1];
      System.debug('acc@@@@@@' + acc);
      return acc;
    }
    return null;
  }

  @AuraEnabled
  public Static List < Traffic_Id_Element__c > getTrafficIds(String selectedaccId) {
    List < Traffic_Id_Element__c > Trafficid = new List < Traffic_Id_Element__c > ();
    // Tid = new Traffic_Id_Element__c();
    List < Traffic_Id_Element__c > Tid = [select Traffic_Id__c, ExportSystem_Name__c from Traffic_Id_Element__c where Account__c =: selectedaccId];
    if (Tid != null && Tid.size() > 0) {
      return Tid;
    }
    return Trafficid;
  }

  @AuraEnabled
  public Static void alertAE(String accountId, List < String > updatedFields) {
    String temp = updatedFields.toString();
    String text = temp.subString(1, temp.length() - 1);
    System.debug('Updated fields ' + text);
    Account updatedAccount = [SELECT ID, CreatedById FROM Account WHERE ID =: accountId LIMIT 1];
    Messaging.CustomNotification notification = new Messaging.CustomNotification();
    notification.setBody('The following information have been updated: ' + text);
    notification.setTitle('Account Information has been updated');
    CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Account_Details_Update_Notification'];
    notification.setNotificationTypeId(type.id);
    System.debug('Account Id' + accountId);
    notification.setTargetId(accountId); // target object id
    notification.send(new Set < String > {
      updatedAccount.CreatedById
    });

    System.debug('Notification sent');
  }

  @AuraEnabled
  public static Account_Request__c getAeAddressDetails(String accountId) {
    Account_Request__c accId = new Account_Request__c();
    accId = [Select Id, Name, City__c, State__c, Country__c, Postal_Code__c, Street__c from Account_Request__c WHERE id =: accountId];
    return accId;
  }

}