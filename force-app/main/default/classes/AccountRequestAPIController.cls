global without sharing class AccountRequestAPIController {
	public static Integer counter = 1;
	public static Account_Request__c searchCriteria;

	@AuraEnabled
	public static wrapDetails getResult(Account_Request__c details) {
		searchCriteria = details;
		System.debug('details' + details);
		List<Account> acc = new List<Account> ();
		Map<Id, Account> MapAccountScore3 = new Map<Id, Account> ();
		Map<Id, Account> MapAccountScore7 = new Map<Id, Account> ();
		Map<Id, Account> FinalAccountMap = new Map<Id, Account> ();
		Map<Id, Lead> FinalLeadMap = new Map<Id, Lead> ();
		Map<Id, Contact> FinalContactMap = new Map<Id, Contact> ();
		List<Account> acc2 = new List<Account> ();
		List<Lead> leads = new List<Lead> ();
		List<Contact> con = new List<Contact> ();
		wrapDetails w = new wrapDetails();
		w.accountsList = new List<Account> ();
		w.leadsList = new List<Lead> ();
		w.contactList = new List<Contact> ();
		System.debug('details.Billing_Street__c: ' + details.Billing_Street__c);
		String accountName = '%' + details.Account_Name__c + '%';
		String searchAccountName = details.Account_Name__c;
		String billStreet = '%' + details.Billing_Street__c + '%';
		String billCity = details.Billing_City__c;
		String billCountry = details.Billing_Country__c;
		String billState = details.Billing_State_Province__c;
		String postalCode = details.Billing_Zip_Postal_Code__c;
		String recordtypeId = details.RecordType__c;
		String recordName = details.RecordType__c;
		System.debug('RecordType ' + recordtypeId);
		System.debug('Account Name ' + accountName);
        String[] states = System.Label.Handle_State.split(',');
        System.debug('States Array:'+ states);
        for(Integer i = 0;i< states.size();i++){
            if(details.Billing_Country__c == states[i]){
                billCountry = 'US';
            	System.debug('@@@States Array:'+ states[i]);
             	System.debug('@@@States Array:'+ billCountry);
            }         	
        }
        if(recordtypeId==null){
            List<RecordType> AdvRecordTypeId = [SELECT ID, NAME, Description,DeveloperName FROM RecordType WHERE DeveloperName = 'Advertiser_Account'];
            recordtypeId = AdvRecordTypeId[0].Id;
        }
		List<List<Account>> accNameList = new List<List<Account>> ();
		Map<ID, Account> accNameMap = new Map<ID, Account> ();
		accNameList = [FIND :searchAccountName IN NAME FIELDS RETURNING Account(Id, name, Phone, DunsNumber__c, RecordTypeId, Primary_Commodity__c,
		                                                                        Commodity_Codes__c, Account_Record_Type_Name__c, BillingAddress,
		                                                                        BillingCity, BillingState, BillingStreet, BillingPostalCode
		                                                                        WHERE RecordTypeId = :recordtypeId) LIMIT 10];
		System.debug('accNameList ' + accNameList);
		for (List<Account> accList : accNameList) {
			for (Account a : accList) {
				accNameMap.put(a.Id, a);
			}
		}
		//Map<ID, Account> accNameMap = new Map<ID, Account>([FIND :accountName IN NAME FIELDS RETURNING Account(Id, name, Phone, DunsNumber__c, RecordTypeId, Primary_Commodity__c, Commodity_Codes__c, Account_Record_Type_Name__c, BillingAddress WHERE RecordTypeId = :recordtypeId ORDER BY Name ASC) LIMIT 100]);
		System.debug('accNameMap: ' + accNameMap);
        System.debug('@@@@billCountry: ' + billCountry);
		Map<Id, Account> accAddressMap = new Map<Id, Account> ();
		if ((!String.isNotEmpty(details.Billing_Street__c) || !String.isNotBlank(details.Billing_Street__c)) || (!String.isNotEmpty(details.Billing_Zip_Postal_Code__c) || !String.isNotBlank(details.Billing_Zip_Postal_Code__c))) {
			accAddressMap = new Map<Id, Account> ([select Id, name, DunsNumber__c, Phone, Owner.Name, Account_Record_Type_Name__c, RecordTypeId,
			                                      Commodity_Codes__c, Primary_Commodity__c, BillingAddress, BillingCity, BillingState, BillingStreet,
			                                      BillingPostalCode
			                                      from Account
			                                      where BillingCity LIKE :billCity AND RecordTypeId = :recordtypeId
			                                      AND BillingCountry LIKE :billCountry AND BillingState LIKE :billState LIMIT 10]);
		}

		else {
			accAddressMap = new Map<Id, Account> ([select Id, name, DunsNumber__c, Phone, Owner.Name, Account_Record_Type_Name__c, RecordTypeId,
			                                      Commodity_Codes__c, Primary_Commodity__c, BillingAddress, BillingCity, BillingState, BillingStreet,
			                                      BillingPostalCode
			                                      from Account
			                                      where RecordTypeId = :recordtypeId
			                                      AND(BillingStreet LIKE :billStreet
			                                          OR(BillingCity LIKE :billCity AND BillingCountry LIKE :billCountry AND BillingState LIKE :billState
			                                             AND BillingPostalCode = :postalCode))
			                                      LIMIT 10]);
		}
        system.debug('accAddressMap: '+accAddressMap);

		//Map<ID, Lead> leadNameMap = new Map<ID, Lead> ([select Id, Name, Company, Phone, Owner.Name, Address from lead where Name Like :accountName LIMIT 100]);
		List<List<Lead>> leadNameList = new List<List<Lead>> ();
		Map<ID, Lead> leadNameMap = new Map<ID, Lead> ();
		leadNameList = [FIND :searchAccountName IN NAME FIELDS RETURNING lead(Id, Name, Company, Phone, Owner.Name, Address) LIMIT 10];
		for (List<Lead> leadList : leadNameList) {
			for (Lead l : leadList) {
				leadNameMap.put(l.Id, l);
			}
		}
		Map<Id, Lead> leadAddressMap = new Map<Id, Lead> ();
		if ((!String.isNotEmpty(details.Billing_Street__c) || !String.isNotBlank(details.Billing_Street__c)) || (!String.isNotEmpty(details.Billing_Zip_Postal_Code__c) || !String.isNotBlank(details.Billing_Zip_Postal_Code__c))) {
			leadAddressMap = new Map<Id, Lead> ([select Id, Name, Company, Phone, Owner.Name, Address
			                                    from lead
			                                    where City LIKE :billCity AND
			                                    Country LIKE :billCountry AND
			                                    State LIKE :billState LIMIT 10]);
		}
		else {
			leadAddressMap = new Map<Id, Lead> ([select Id, Name, Company, Phone, Owner.Name, Address
			                                    from lead
			                                    where(City LIKE :billCity AND
			                                          Country LIKE :billCountry AND
			                                          State LIKE :billState AND PostalCode = :postalCode) OR Street LIKE :billStreet LIMIT 10]);


		}
		Map<ID, Contact> contactNameMap = new Map<ID, Contact> ([select Id, Name, Phone, Owner.Name, MailingAddress
		                                                        from Contact
		                                                        where Name Like :accountName LIMIT 10]);
		Map<Id, Contact> contactAddressMap = new Map<Id, Contact> ();
		if ((!String.isNotEmpty(details.Billing_Street__c) || !String.isNotBlank(details.Billing_Street__c)) || (!String.isNotEmpty(details.Billing_Zip_Postal_Code__c) || !String.isNotBlank(details.Billing_Zip_Postal_Code__c))) {
			contactAddressMap = new Map<Id, Contact> ([select Id, Name, Phone, Owner.Name, MailingAddress
			                                          from Contact
			                                          where MailingCity LIKE :billCity AND
			                                          MailingCountry LIKE :billCountry AND
			                                          MailingState LIKE :billState LIMIT 10]);

		}
		else {
			contactAddressMap = new Map<Id, Contact> ([select Id, Name, Phone, Owner.Name, MailingAddress
			                                          from Contact
			                                          where(MailingCity LIKE :billCity AND MailingCountry LIKE :billCountry AND MailingState LIKE :billState
			                                                AND MailingPostalCode = :postalCode) OR MailingStreet LIKE :billStreet LIMIT 10]);
		}
		List<Account> accNameFinal = accNameMap.values();
		System.debug('accNameFinal ' + accNameFinal.size());
		List<Account> accAdddressFinal = accAddressMap.values();
		System.debug('accAdddressFinal ' + accAdddressFinal.size());
		List<Lead> leadNameFinal = leadNameMap.values();
		List<Lead> leadAddressFinal = leadAddressMap.values();
		List<Contact> contactNameFinal = contactNameMap.values();
		List<Contact> contactAddressFinal = contactAddressMap.values();

		w.accountsList.addAll(accNameFinal);
		w.accountsList.addAll(accAdddressFinal);
		w.leadsList.addAll(leadNameFinal);
		w.leadsList.addAll(leadAddressFinal);
		w.contactList.addAll(contactNameFinal);
		w.contactList.addAll(contactAddressFinal);

		/*for (Integer count = 0; count< 20; count++) {
		  if (accNameFinal.size() - 1 >= count) {
		  w.accountsList.add(accNameFinal.get(count));
		  //Account a = new Account(Name = 'Test');
		  //accAdddressFinal.add(0, a);
		  }
		  else if (accAddressMap.size() - 1 >= count) {
		  w.accountsList.add(accAdddressFinal.get(count));
		  }
		 
		  if (leadNameFinal.size() - 1 >= count) {
		  w.leadsList.add(leadNameFinal.get(count));
		  Lead l = new Lead(LastName = 'Test Lead', Company = 'Test Lead Company');
		  leadAddressFinal.add(0, l);
		  }
		  else if (leadAddressFinal.size() - 1 >= count) {
		  w.leadsList.add(leadAddressFinal.get(count));
		  }
		 
		  if (contactNameFinal.size() - 1 >= count) {
		  w.contactList.add(contactNameFinal.get(count));
		  Contact c = new Contact(LastName = 'Contact Test');
		  contactAddressFinal.add(0, c);
		  }
		  else if (contactAddressFinal.size() - 1 >= count) {
		  w.contactList.add(contactAddressFinal.get(count));
		  }
		  }*/
		for (Account a : w.accountsList) {
			System.debug('@@a: ' + a);
			if (a.Name.equalsIgnoreCase(AccountRequestAPIController.searchCriteria.Account_Name__c)
			    && a.BillingCity != null && a.BillingState != null && a.BillingPostalCode != null
			    && a.BillingCity.equalsIgnoreCase(AccountRequestAPIController.searchCriteria.Billing_City__c)
			    && a.BillingState.equalsIgnoreCase(AccountRequestAPIController.searchCriteria.Billing_State_Province__c)
			    && a.BillingPostalCode.equalsIgnoreCase(AccountRequestAPIController.searchCriteria.Billing_Zip_Postal_Code__c)) {
				System.debug('a.Name: ' + a.Name);
				System.debug('Priority: 0');
				a.Sort_Priority__c = 0; //Highest Priority
			}
			else if (a.Name.startsWithIgnoreCase(AccountRequestAPIController.searchCriteria.Account_Name__c)
			         && a.BillingCity != null && a.BillingState != null && a.BillingPostalCode != null
			         && a.BillingCity.equalsIgnoreCase(AccountRequestAPIController.searchCriteria.Billing_City__c)
			         && a.BillingState.equalsIgnoreCase(AccountRequestAPIController.searchCriteria.Billing_State_Province__c)
			         && a.BillingPostalCode.equalsIgnoreCase(AccountRequestAPIController.searchCriteria.Billing_Zip_Postal_Code__c)) {
				System.debug('a.Name: ' + a.Name);
				System.debug('Priority: 1');
				a.Sort_Priority__c = 1;
			}
			else if (a.Name.containsIgnoreCase(AccountRequestAPIController.searchCriteria.Account_Name__c)
			         && a.BillingCity != null && a.BillingState != null && a.BillingPostalCode != null
			         && a.BillingCity.equalsIgnoreCase(AccountRequestAPIController.searchCriteria.Billing_City__c)
			         && a.BillingState.equalsIgnoreCase(AccountRequestAPIController.searchCriteria.Billing_State_Province__c)
			         && a.BillingPostalCode.equalsIgnoreCase(AccountRequestAPIController.searchCriteria.Billing_Zip_Postal_Code__c)) {
				a.Sort_Priority__c = 2;
			}
			else if (a.Name.equalsIgnoreCase(AccountRequestAPIController.searchCriteria.Account_Name__c)
			         && a.BillingCity != null && a.BillingState != null
			         && a.BillingCity.equalsIgnoreCase(AccountRequestAPIController.searchCriteria.Billing_City__c)
			         && a.BillingState.equalsIgnoreCase(AccountRequestAPIController.searchCriteria.Billing_State_Province__c)) {
				a.Sort_Priority__c = 3;
			}
			else if (a.Name.startsWithIgnoreCase(AccountRequestAPIController.searchCriteria.Account_Name__c) && a.BillingAddress != null
			         && a.BillingCity != null && a.BillingState != null
			         && a.BillingCity.equalsIgnoreCase(AccountRequestAPIController.searchCriteria.Billing_City__c)
			         && a.BillingState.equalsIgnoreCase(AccountRequestAPIController.searchCriteria.Billing_State_Province__c)) {
				a.Sort_Priority__c = 4;
			}
			else if (a.Name.containsIgnoreCase(AccountRequestAPIController.searchCriteria.Account_Name__c)
			         && a.BillingCity != null && a.BillingState != null
			         && a.BillingCity.equalsIgnoreCase(AccountRequestAPIController.searchCriteria.Billing_City__c)
			         && a.BillingState.equalsIgnoreCase(AccountRequestAPIController.searchCriteria.Billing_State_Province__c)) {
				a.Sort_Priority__c = 5;
			}
			else if (a.Name.equalsIgnoreCase(AccountRequestAPIController.searchCriteria.Account_Name__c)
			         && a.BillingCity != null
			         && a.BillingCity.equalsIgnoreCase(AccountRequestAPIController.searchCriteria.Billing_City__c)) {
				a.Sort_Priority__c = 6;
			}
			else if (a.Name.startsWithIgnoreCase(AccountRequestAPIController.searchCriteria.Account_Name__c)
			         && a.BillingCity != null
			         && a.BillingCity.equalsIgnoreCase(AccountRequestAPIController.searchCriteria.Billing_City__c)) {
				a.Sort_Priority__c = 7;
			}
			else if (a.Name.containsIgnoreCase(AccountRequestAPIController.searchCriteria.Account_Name__c)
			         && a.BillingCity != null
			         && a.BillingCity.equalsIgnoreCase(AccountRequestAPIController.searchCriteria.Billing_City__c)) {
				a.Sort_Priority__c = 8;
			}
			else if (a.Name.equalsIgnoreCase(AccountRequestAPIController.searchCriteria.Account_Name__c)) {
				a.Sort_Priority__c = 9;
			}
			else if (a.Name.startsWithIgnoreCase(AccountRequestAPIController.searchCriteria.Account_Name__c)) {
				a.Sort_Priority__c = 10;
			}
			else if (a.Name.containsIgnoreCase(AccountRequestAPIController.searchCriteria.Account_Name__c)) {
				a.Sort_Priority__c = 11;
			}
			else {
				a.Sort_Priority__c = 12;
			}
		}

		List<AccountWrapper> accountWrappers = new List<AccountWrapper> ();
		for (Account a : w.accountsList) {
			accountWrappers.add(new AccountWrapper(a));
		}
		accountWrappers.sort();
		w.accountsList.clear();
		Integer length = accountWrappers.size() >= 10 ? 10 : accountWrappers.size();
		for (Integer i = 0; i<length; i++) {
			w.accountsList.add(accountWrappers.get(i).account);
		}
		System.debug('accountWrappers: ' + accountWrappers);
		System.debug('Logged in user: ' + UserInfo.getUserId());
		return w;
	}

	@AuraEnabled(Cacheable = false)
	public static List<DUNSDataModel> getDnBData(Account_Request__c details) {
		System.debug('@@details: ' + details);
		DateTime now3 = System.now();
		System.debug('Method start ' + now3);
		Organization org = [Select Id, Name, IsSandbox from Organization LIMIT 1];
		String baseUrl =  (org.IsSandbox == false? Label.DnBBoomiBaseURL: Label.DnBBoomiSandboxBaseURL)+'Invoke_DnB/';
		// String baseUrl = 'http://3.227.174.198:9090/ws/rest/DnB/Invoke_DnB';
		System.debug('@@baseurl' + baseUrl);
        
        //Changes made as per ticket SRSF-3659, when user searches for United States, or USA 'US' will be in the searching parameter. 
		String billCountry =  details.Billing_Country__c;
        String[] states = System.Label.Handle_State.split(',');
        System.debug('States Array:'+ states);
        System.debug('States Array:'+ states.size());
        
        for(Integer i = 0;i< states.size();i++){
            if(details.Billing_Country__c.trim() == states[i].trim()){
              billCountry = 'US';   	  
            }
        }
        System.debug('@@@billCountry: '+ billCountry);
		HttpRequest httpRequest = new HttpRequest();
		httpRequest.setEndpoint(baseUrl);
		httpRequest.setMethod('GET');
		httpRequest.setHeader('Accept', '*/*');
		httpRequest.setHeader('DnBAuthorization', Label.DnBAuth);
		// httpRequest.setHeader('Authorization', Label.BoomiUserDnBProcess);
		if (org.IsSandbox == false) {
			httpRequest.setHeader('Authorization', Label.BoomiUserDnBProcess);	
		}
		else {
			httpRequest.setHeader('Authorization', Label.BoomiUserDnBSandbox);	
		}
		httpRequest.setHeader('CountryISOAlpha2Code', billCountry.replace(' ', '%20').replace('\r\n', '%20'));
		httpRequest.setHeader('name', details.Account_Name__c.replace(' ', '%20').replace('\r\n', '%20').replace('/POL','').replace('POL/',''));
		if (String.isNotBlank(details.Phone__c) && String.isNotEmpty(details.Phone__c)) {
			httpRequest.setHeader('telephoneNumber', details.Phone__c.replace(' ', '%20').replace('\r\n', '%20'));
		}
		if (String.isBlank(details.Billing_Street__c) || String.isEmpty(details.Billing_Street__c)) {
			details.Billing_Street__c = ' ';
		}
		else
		{
			httpRequest.setHeader('streetAddressLine1', details.Billing_Street__c.replace(' ', '%20').replace('\n', '%20').replace('\r\n', '%20'));
		}
		if (String.isBlank(details.Billing_Zip_Postal_Code__c) || String.isEmpty(details.Billing_Zip_Postal_Code__c)) {
			details.Billing_Zip_Postal_Code__c = '';
			httpRequest.setHeader('postalCode', details.Billing_Zip_Postal_Code__c);
		}
		else
		{
			httpRequest.setHeader('postalCode', details.Billing_Zip_Postal_Code__c.replace(' ', '%20').replace('\r\n', '%20'));
		}
		System.debug('Street----------------' + details.Billing_Street__c + '@@--');
		httpRequest.setHeader('addressLocality', details.Billing_City__c.replace(' ', '%20').replace('\r\n', '%20'));
		httpRequest.setHeader('addressRegion', details.Billing_State_Province__c.replace(' ', '%20').replace('\r\n', '%20'));
		httpRequest.setTimeout(120000);
		String dnbResponse = null;
		DnBIDRModel dnbData = new DnBIDRModel();
		DnBResponseErrorController dnbError = new DnBResponseErrorController();
		List<DUNSDataModel> dnbDataList = new List<DUNSDataModel> ();
		List<D_B_account__c> dnbRecList = new List<D_B_account__c> ();
		List<D_B_Account_Junction__c> dnbJunList = new List<D_B_Account_Junction__c> ();
		List<String> dandbextenalid = new List<String> ();
		List<String> lstDunsNumber = new List<String> ();
		try {
			System.debug('Label.useDnBStaticJSON' + Label.useDnBStaticJSON);
			Http http = new Http();
			System.debug('httpRequest ' + httpRequest);
			System.debug('body  ' + httpRequest.getBody());
			HttpResponse httpResponse = http.send(httpRequest);
			System.debug('@@dnbResponse: ' + httpResponse);
			DateTime now = System.now();
			System.debug('Boomi complte ' + now);
			if (httpResponse.getStatusCode() == 200)
			{
			Map<String, DandBErrorCode__mdt> errorMap = new Map<String, DandBErrorCode__mdt>();
		List<DandBErrorCode__mdt> metadataResult = [Select 	Description__c,	errorCode__c,HTTPStatusCode__c,IsDataError__c, ErrorMessage__c from DandBErrorCode__mdt];
		for(DandBErrorCode__mdt metaObj: metadataResult){
		errorMap.put(metaObj.errorCode__c,metaObj);
		System.debug('errorList' + metadataResult);
}
				dnbResponse = httpResponse.getBody();
				System.debug('@@dnbResponse: ' + dnbResponse);
				dnbError = DnBResponseErrorController.parse(dnbResponse);
				System.debug('@@fault: ' + dnbError);
				System.debug('Dnb errorr: ' + dnbError.error);
				if(dnbError.error!=null && errorMap.containsKey( dnbError.error.errorCode)){
					dnbError.error.errorMessage = (errorMap.get(dnbError.error.errorCode).ErrorMessage__c ==null || errorMap.get(dnbError.error.errorCode).ErrorMessage__c =='') ? errorMap.get(dnbError.error.errorCode).Description__c : errorMap.get(dnbError.error.errorCode).ErrorMessage__c;
					dnbError.error.isDataError = errorMap.get(dnbError.error.errorCode).IsDataError__c;
				}

				if (dnbError.fault != null && String.isNotEmpty(dnbError.fault.detail.errorcode))
				{
					if (counter == 1)
					{
						System.debug('@@counter: ' + counter);
						dnbAuthenticateController.callDnBAuth();
						counter = 2;
						DUNSDataModel errorDetail = new DUNSDataModel();
						errorDetail.ErrorMessage = 'DnB authentication token expired. We have regenerated the token. Please search again';
						Log4SF.logMessage('AccountRequestAPIController', 'getDnBData', '', UserInfo.getUserId(), '');
						dnbDataList.add(errorDetail);
						return dnbDataList;
					}
					else
					{
						System.debug('@@@@counter ' + counter);
						Log4SF.logMessage('AccountRequestAPIController', 'DnB is down', 'DnB Authentication Failed', UserInfo.getUserId(), '');
						List<String> emailAddresses = new List<String> { 'sf.sr.ashok@mandsconsulting.com', 'greg.rice@charter.com' };
					}

				}
				else if (dnbError.error != null && String.isNotEmpty(dnbError.error.errorCode))
				{
					DUNSDataModel errorDetail = new DUNSDataModel();
					if (dnbError.error.errorCode == '00004' || dnbError.error.errorCode == '00040') {
						System.debug('Dnb error code @@@@@@');
						dnbAuthenticateController.callDnBAuth();
						errorDetail.ErrorMessage = 'DnB authentication token expired. We have regenerated the token. Please search again';
					}
					else {
						errorDetail.ErrorMessage = dnbError.error.errorMessage;
						errorDetail.isDataError = dnbError.error.isDataError;
					}
					 //system.debug('The Region provided in the request is invalid. Please check the documentation for valid values and retry the request.' + errorDetail.ErrorMessage);

					Log4SF.logMessage('AccountRequestAPIController', 'getDnBData', 
										dnbError.error.errorCode + ' ' + dnbError.error.errorMessage + '\n' +
										'Search Criteria:' + '\n' + 
										'Name: ' + httpRequest.getHeader('name') + '\n' +
										'City: ' + httpRequest.getHeader('addressLocality') + '\n' +
										'State: '+ httpRequest.getHeader('addressRegion') + '\n' +
										'Country: '+ httpRequest.getHeader('CountryISOAlpha2Code') + '\n' +
										'ZipCode: '+httpRequest.getHeader('postalCode') + '\n' +
										'Street: ' +httpRequest.getHeader('streetAddressLine1') + '\n' +
										'Phone: ' +httpRequest.getHeader('telephoneNumber') ,
										UserInfo.getUserId(), '');
					dnbDataList.add(errorDetail);
					return dnbDataList;
				}

				dnbData = DnBIDRModel.parse(dnbResponse);
				System.debug('@@dnbData: ' + dnbData);
				processDnBData(dnbData, dnbRecList, lstDunsNumber);

			}
			else {
				System.debug('@@CalloutException: ' + httpResponse.getBody());
				Log4SF.logMessage('AccountRequestAPIController', 'getDnBData', 'CallOut exception' + ' ' + httpResponse.getBody(), UserInfo.getUserId(), '');
				throw new CalloutException(httpResponse.getBody());
			}

			enrichDnBData(lstDunsNumber, dnbRecList, dnbDataList);

			System.debug('@@dnbRecList@@@' + dnbRecList);
			upsert dnbRecList DUNSNumber__c;
			System.debug('@@dnbDataList: ' + dnbDataList);
			return dnbDataList;
		}
		catch(Exception ex) {
			Log4SF.logMessage('AccountRequestAPIController', 'getDnBData', ex.getLineNumber() + ' ' + ex.getMessage(), UserInfo.getUserId(), '');
			throw ex;
		}
	}

	private static void processDnBData(DnBIDRModel dnbData, List<D_B_account__c> dnbRecList, List<String> lstDunsNumber) {
		System.debug('dnbData' + dnbData);
		System.debug('dnbRecList' + dnbRecList);
		System.debug('lstDunsNumber' + lstDunsNumber);

		for (DnBIDRModel.MatchCandidates item : dnbData.matchCandidates) {
			System.debug('item' + item);
			System.debug('dnbData.matchCandidates' + dnbData.matchCandidates);
			D_B_account__c dbacc = new D_B_account__c();
			
			if (item.organization.primaryName!=null && item.organization.primaryName.length()> 80) {
				dbacc.Name = item.organization.primaryName.substring(0, 80);
				dbacc.D_B_Account_Name__c = item.organization.primaryName;
			}
			else {
				if (item.organization.primaryName!=null){
				dbacc.Name = item.organization.primaryName;
				}
				dbacc.D_B_Account_Name__c = dbacc.Name;
			}
			dbacc.DUNSNumber__c = item.organization.duns;
			dbacc.Confidence_Code__c = item.matchQualityInformation.confidenceCode;
			if (item.organization.telephone != null && item.organization.telephone.size() > 0) {
				dbacc.TelephoneNumber__c = item.organization.telephone[0].telephoneNumber;
			}
			System.debug('DnB State: ' + item.organization.primaryAddress);
			dbacc.PrimaryCountryName__c = item.organization.primaryAddress.addressCountry.isoAlpha2Code;
			System.debug('item.organization ' + item.organization);
			System.debug('item.organization.primaryAddress ' + item.organization.primaryAddress);
			System.debug('iitem.organization.primaryAddress.addressRegion ' + item.organization.primaryAddress.addressRegion);
			if (item.organization.primaryAddress.addressRegion != null)
			dbacc.PrimaryStateProvinceName__c = item.organization.primaryAddress.addressRegion.abbreviatedName;
			else {
				dbacc.PrimaryStateProvinceName__c = 'NA';
			}
			dbacc.PrimaryCityName__c = item.organization.primaryAddress.addressLocality.name;
			dbacc.PrimaryAddressPostalCode__c = item.organization.primaryAddress.postalCode;
			if (item.organization.corporateLinkage != null) {
				System.debug('@@@item@' + item.organization.corporateLinkage);
				if (item.organization.corporateLinkage.familytreeRolesPlayed != null && item.organization.corporateLinkage.familytreeRolesPlayed.size() > 0) {
					dbacc.SubsidiaryIndicator__c = String.valueOf(item.organization.corporateLinkage.familytreeRolesPlayed[0].dnbCode); }
			}
			if (item.organization.mostSeniorPrincipals != null && item.organization.mostSeniorPrincipals.size() > 0) {

				dbacc.mostSeniorPrincipals__c = item.organization.mostSeniorPrincipals[0].fullname;
			}
			if (item.organization.primaryAddress.streetAddress != null) {
				dbacc.PrimaryStreetAddress__c = item.organization.primaryAddress.streetAddress.line1;
			}

			dnbRecList.add(dbacc);
			lstDunsNumber.add(item.organization.duns);
		}
	}

	private static void enrichDnBData(List<String> DunsList, List<D_B_account__c> dnbRecList, List<DUNSDataModel> dnbDataList) {
		System.debug('@@DunsList: ' + DunsList);

		String dnbResponse = null;
		DnBCSSResponseModel dnbEnrichData = new DnBCSSResponseModel();

		DnB_CCS_Request_Model body = new DnB_CCS_Request_Model();
		body.dunsList = DunsList;
		body.pageNumber = 1;
		body.pageSize = 50;
		Organization org = [Select Id, Name, IsSandbox from Organization LIMIT 1];
		String baseUrl =  (org.IsSandbox == false? Label.DnBBoomiBaseURL: Label.DnBBoomiSandboxBaseURL)+'Invoke_DnB_CSS/';
		// String baseUrl = 'http://3.227.174.198:9090/ws/rest/DnB/Invoke_DnB_CSS';
		HttpRequest httpRequest = new HttpRequest();
		httpRequest.setEndpoint(baseUrl);
		httpRequest.setMethod('POST');
		httpRequest.setHeader('Accept', 'application/json');
		httpRequest.setHeader('Content-type', 'application/json; charset=UTF-8');
		httpRequest.setHeader('DnBAuthorization', Label.DnBAuth);
		// httpRequest.setHeader('Authorization', Label.BoomiUserDnBProcess);
		if (org.IsSandbox == false) {
			httpRequest.setHeader('Authorization', Label.BoomiUserDnBProcess);	
		}
		else {
			httpRequest.setHeader('Authorization', Label.BoomiUserDnBSandbox);	
		}
		httpRequest.setTimeout(120000);
		httpRequest.setBody(JSON.serialize(body, true));

		try {
			Http http = new Http();
			System.debug('httpRequest ' + httpRequest);
			HttpResponse httpResponse = http.send(httpRequest);

			if (httpResponse.getStatusCode() == 200) {
				dnbResponse = httpResponse.getBody();
				System.debug('@@dnbResponse: ' + dnbResponse);

				dnbEnrichData = DnBCSSResponseModel.parse(dnbResponse);
				System.debug('@@dnbEnrichData: ' + dnbEnrichData);
				processEnrichData(dnbEnrichData, dnbRecList, dnbDataList);

			}

			else {
				//if (Label.useDnBStaticJSON == 'true') {
				//DnbCSSJson obj = new DnbCSSJson();
				//dnbEnrichData = DnBCSSResponseModel.parse(obj.strDnbCSSJson);
				//processEnrichData(dnbEnrichData, dnbRecList, dnbDataList);
				//}
				//else {
				System.debug('@@CalloutException: ' + httpResponse.getBody());
				//throw new CalloutException(httpResponse.getBody());
				//}


			}
		}
		catch(Exception ex) {
			Log4SF.logMessage('AccountRequestAPIController', 'enrichDnBData', ex.getLineNumber() + ' ' + ex.getMessage(), UserInfo.getUserId(), '');
			throw ex;
		}
	}


	private static void processEnrichData(DnBCSSResponseModel dnbEnrichData, List<D_B_account__c> dnbRecList, List<DUNSDataModel> dnbDataList) {
		try {
			System.debug('dnbEnrichData@@' + dnbEnrichData.searchCandidates);
			for (DnBCSSResponseModel.SearchCandidates item : dnbEnrichData.searchCandidates) {
				System.debug(' dnbRecList@@' + dnbRecList);
				for (D_B_account__c dnbAccRec : dnbRecList) {
					System.debug('dnbAccRec.DUNSNumber__c' + dnbAccRec.DUNSNumber__c);
					System.debug('item.organization.duns@@@ ' + item.organization.duns);

					DUNSDataModel dbData = new DUNSDataModel();
					dbData.DUN = dnbAccRec.DUNSNumber__c;
					dbData.ConfidenceCode = String.valueOf(dnbAccRec.Confidence_Code__c);
					dbData.name = dnbAccRec.Name;

					dbData.Phone = dnbAccRec.TelephoneNumber__c;

					dbData.Address = dnbAccRec.PrimaryStreetAddress__c + ' '
					+ dnbAccRec.PrimaryCityName__c + ' '
					+ dnbAccRec.PrimaryStateProvinceName__c + ' '
					+ dnbAccRec.PrimaryAddressPostalCode__c + ' '
					+ dnbAccRec.PrimaryCountryName__c;

					dbData.billingCity= dnbAccRec.PrimaryCityName__c;
					dbData.billingCountry=dnbAccRec.PrimaryCountryName__c;
					dbData.billingState=dnbAccRec.PrimaryStateProvinceName__c;
					dbData.billingStreet= dnbAccRec.PrimaryStreetAddress__c;
					dbData.billingZipCode=dnbAccRec.PrimaryAddressPostalCode__c;

					System.debug('dnbAccRec.MailingStateName__c: ' + dnbAccRec.MailingStateName__c);
					dbData.MailingAddress = dnbAccRec.MailingAddress1__c == null ? '' : dnbAccRec.MailingAddress1__c +
					dnbAccRec.MailingAddressCity__c == null ? '' : dnbAccRec.MailingAddressCity__c +
					dnbAccRec.MailingStateName__c == null ? '' : dnbAccRec.MailingStateName__c +
					dnbAccRec.MailingAddressPostalCode__c == null ? '' : dnbAccRec.MailingAddressPostalCode__c +
					dnbAccRec.MailingCountryCode_ISO__c == null ? '' : dnbAccRec.MailingCountryCode_ISO__c;
					System.debug('dbData.MailingAddress: ' + dbData.MailingAddress);

					System.debug('@@@dnbAccRec.MailingCountryCode_ISO__c2@@ ' + dnbAccRec.MailingCountryCode_ISO__c);
					dbData.outofBusiness = dnbAccRec.EmployeeCountTotal__c + ' ';

					if (dnbAccRec.DUNSNumber__c == item.organization.duns) {

						dbData.website = item.organization.domain;
						dbData.operatingStatus = String.valueOf(item.organization.dunsControlStatus.isOutOfBusiness);
						system.debug('@@dbData.operatingStatus' + dbData.operatingStatus);

						if (item.organization.numberOfEmployees != null && item.organization.numberOfEmployees.size() > 0) {
							dnbAccRec.EmployeeCountTotal__c = item.organization.numberOfEmployees[0].value;
						}
						dnbAccRec.WebAddress__c = item.organization.domain;
						if (item.organization.financials != null && item.organization.financials.size() > 0) {
							dnbAccRec.RevenueTrendYear__c = item.organization.financials[0].yearlyRevenue[0].value; }
						dnbAccRec.OutofBusinessIndicator__c = String.valueOf(item.organization.dunsControlStatus.isOutOfBusiness);
						if (item.organization.tradeStyleNames != null && item.organization.tradeStyleNames.size() > 0) {
							Integer count = 0;
							for (DnBCSSResponseModel.TradeStyleNames tsn : item.organization.tradeStyleNames) {
								if (count == 0) {
									dnbAccRec.Tradestyle_Name_1__c = item.organization.tradeStyleNames[0].name;
								}
								if (count == 1) {
									dnbAccRec.TradestyleName2__c = item.organization.tradeStyleNames[1].name;
								}
								if (count == 2) {
									dnbAccRec.TradestyleName3__c = item.organization.tradeStyleNames[2].name;
								}
								count++;
							}
						}
						dnbAccRec.SIC4Code1__c = item.organization.primaryIndustryCodes[0].usSicV4;
						dnbAccRec.SIC4Code1Description__c = item.organization.primaryIndustryCodes[0].usSicV4Description;
						if (item.organization.primaryAddress != null) {
							if (item.organization.primaryAddress.streetAddress != null) {
								dnbAccRec.PrimaryAddress1__c = item.organization.primaryAddress.streetAddress.line1;
							}
							else {
								dnbAccRec.PrimaryAddress1__c = 'NA';
							}
							dnbAccRec.PrimaryLatitude__c = item.organization.primaryAddress.latitude;
							dnbAccRec.PrimaryLongitude__c = item.organization.primaryAddress.longitude;
						}
						else {
							dnbAccRec.PrimaryAddress1__c = 'NA';
						}
						dnbAccRec.OutofBusinessIndicator__c = String.valueOf(item.organization.dunsControlStatus.isOutOfBusiness);
						dnbAccRec.MarketabilityIndicator__c = String.valueOf(item.organization.dunsControlStatus.isMarketable);
						dnbAccRec.DelistedIndicator__c = String.valueOf(item.organization.dunsControlStatus.isDelisted);
						dnbAccRec.Fortune1000Rank__c = String.valueOf(item.organization.isFortune1000Listed);
						dnbAccRec.ImporterExporterIndicator__c = String.valueOf(item.organization.isImporter);
						if (item.organization.registrationNumbers != null && item.organization.registrationNumbers.size() > 0)
						{
							dnbAccRec.USTaxID__c = item.organization.registrationNumbers[0].registrationNumber;
							dnbAccRec.LegalStructureDescription__c = item.organization.registrationNumbers[0].typeDescription;
						}

						if (item.organization.numberOfEmployees != null) {
							dnbAccRec.EmployeeCountTotalReliabilityDescription__c = item.organization.numberOfEmployees[0].reliabilityDescription;
						}
						if (item.organization.mailingAddress != null) {
							dnbAccRec.Mailing_Address_Country_Region_Code__c = item.organization.mailingAddress.addressCountry.name;
							dnbAccRec.MailingAddressCity__c = item.organization.mailingAddress.addressLocality.name;
							dnbAccRec.MailingCountryCode_ISO__c = item.organization.mailingAddress.addressCountry.isoAlpha2Code;
							dnbAccRec.MailingStateName__c = item.organization.mailingAddress.addressRegion.name;
							dnbAccRec.MailingAddressStateAbbrev_ISO__c = item.organization.mailingAddress.addressRegion.abbreviatedName;
							dnbAccRec.MailingAddress1__c = item.organization.mailingAddress.streetAddress.line1;
							dnbAccRec.MailingAddressPostalCode__c = item.organization.mailingAddress.postalCode;
						}
						dnbAccRec.DelistedIndicator__c = String.valueOf(item.organization.dunsControlStatus.isDelisted);
						System.debug('@@MailingCountryCode_ISO__c' + dnbAccRec.MailingCountryCode_ISO__c);

						if (item.organization.numberOfEmployees != null) {
							dnbAccRec.EmployeeCountHereReliabilityCode__c = item.organization.numberOfEmployees[0].reliabilityDescription;
							dnbAccRec.EmployeeCountHere__c = item.organization.numberOfEmployees[0].value; }
					}
					System.debug('@@dbData ' + dbData);
					dnbDataList.add(dbData);
				}
			}


		}
		catch(Exception ex) {
			Log4SF.logMessage('AccountRequestAPIController', 'processEnrichData', ex.getLineNumber() + ' ' + ex.getMessage(), UserInfo.getUserId(), '');
			throw ex;
		}
	}

	@AuraEnabled
	public static string recordtypeID() {
		String Id;
		Id RecordTypeId = Schema.SObjectType.Account_Request__c.getrecordtypeinfosbydevelopername().get('Create_new_account').getRecordTypeId();
		System.debug(RecordTypeId);
		return RecordTypeId;
	}

	// public class wrapJuctionData {
	// 	@AuraEnabled
	// 	public String DUNS { get; set; }

	// 	@AuraEnabled
	// 	public Integer ConfidenceCode { get; set; }
	// }

	public class wrapDetails {
		@AuraEnabled
		public List<Contact> contactList { get; set; }

		@AuraEnabled
		public List<Account> accountsList { get; set; }

		@AuraEnabled
		public List<Lead> leadsList { get; set; }

		@AuraEnabled
		public List<AccountWrapper> accountsListWrapper { get; set; }
	}

	public class AccountWrapper implements Comparable {
		public Account account { get; set; }
		public Decimal sortPriority { get; set; }

		public AccountWrapper(Account a) {
			account = a;
			sortPriority = a.Sort_Priority__c;
		}

		public Integer compareTo(Object compareTo) {
			AccountWrapper otherAccount = (AccountWrapper) compareTo;

			if (sortPriority == otherAccount.sortPriority) {
				return 0;
			} else if (sortPriority > otherAccount.sortPriority) {
				return 1;
			} else {
				return - 1;
			}
		}
	}

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

	@AuraEnabled
	public static List<Contact> getContactDetails(String accountId) {
		Contact contactId = new Contact();
		list<Contact> contactIDRelated = new List<Contact> ();
		contactIDRelated = [Select id from Contact where AccountId = :accountId];
		DateTime now4 = System.now();
		System.debug('now 4 ' + now4);
		if (contactIDRelated != null) {
			return contactIDRelated;
		}
		else {
			return null;
		}
	}
	@AuraEnabled
	public static List<account> getdandbaccountsalesforce(string dunNum) {
		list<account> lstacc = [Select Id, Name, Phone, Owner.name, BillingAddress, Primary_Commodity__c,
		                        Commodity_Codes__c, Account_Record_Type_Name__c, Website, DunsNumber__c,
		(select contact.name, contact.phone, contact.Contact_Status__c, contact.Advertiser_Contact_Type__c, contact.MailingAddress
		 , contact.Title from AccountContactRelations)
		                        , Active__c, Agency__c from account where DunsNumber__c = :dunNum];
		if (lstacc != null && lstacc.size() > 0) {
			System.debug('lastacc --->' + lstacc);
			return lstacc;
		}
		return null;
	}

	@AuraEnabled
	public static List<D_B_account__c> getdandbAddress(string dunNum) {
		List<D_B_account__c> dnbAddress = new List<D_B_account__c> ();
		dnbAddress = [Select Id, PrimaryStreetAddress__c, PrimaryStateProvinceName__c, PrimaryCityName__c, PrimaryCountryName__c, PrimaryAddressPostalCode__c from D_B_account__c Where DUNSNumber__c = :dunNum LIMIT 1];
		return dnbAddress;
	}

	@AuraEnabled
	public static String setdnbJunctionData(Map<String, String> mapDnBConfidence, String AccountId) {
		System.debug('mapDnBConfidence: '+mapDnBConfidence);
		List<String> DUNNS = new List<String>(mapDnBConfidence.keySet());
		if (DUNNS != null && DUNNS.size() > 0) {
			List<D_B_Account_Junction__c> existingDnBJunctionData = [SELECT ID, D_B_account__r.DUNSNumber__c
			                                                         FROM D_B_Account_Junction__c WHERE Account__c = :AccountId
			                                                         AND D_B_account__r.DUNSNumber__c IN :DUNNS];
			if (existingDnBJunctionData != null && DUNNS.size() == existingDnBJunctionData.size()) {
				return 'Account already linked with these DnB Accounts';
			}

			else {
				if (existingDnBJunctionData != null) {
					for (D_B_Account_Junction__c item : existingDnBJunctionData) {
						if (DUNNS.contains(item.D_B_account__r.DUNSNumber__c)) {
							DUNNS = (List<String>) AccountRequestAPIController.removeAll(DUNNS, item.D_B_account__r.DUNSNumber__c);
						}
					}
				}
				List<D_B_Account_Junction__c> dnbJunList = new List<D_B_Account_Junction__c> ();
				List<D_B_account__c> DUNNSList = [Select id, DUNSNumber__c from D_B_account__c where DUNSNumber__c In :DUNNS];
				for (D_B_account__c dbAcc : DUNNSList) {
					D_B_Account_Junction__c dbJunObj = new D_B_Account_Junction__c();
					dbJunObj.D_B_account__c = dbAcc.Id;
					dbJunObj.Account__c = AccountId;
					dbJunObj.Confidence_Code__c = Decimal.valueOf(mapDnBConfidence.get(dbAcc.DUNSNumber__c));
					dnbJunList.add(dbJunObj);
				}
				System.debug('dnbJunList: ' + dnbJunList);
				if (dnbJunList.size() > 0) {
					insert dnbJunList;
				}
				System.debug('dnbJunList:  ---> 2   ' + dnbJunList);
			}
		}
		return 'Ok';
	}

	public static List<Object> removeAll(List<Object> target, Object toRemove) {
		for (Integer i = target.size() - 1; i >= 0; i--) {
			if (target[i].equals(toRemove)) {
				target.remove(i);
			}
		}
		return target;
	}

	@AuraEnabled(Cacheable = true)
	public static List<LookupSearchResult> getAccountList(String searchTerm,
	                                                      List<String> selectedIds,
	                                                      String searchType) {
		System.debug('accData@@@@@@@@@@' + searchTerm);

		//String acc =: '%accData%';
		List<Account> accountList = new List<Account> ();
		accountList = [Select id, name, RecordType.Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account where Name LIKE :'%' + searchTerm + '%' AND RecordType.Name IN ('In House Agency Account', 'Agency Account')];

		String accountIcon = 'standard:account';
		List<LookupSearchResult> results = new List<LookupSearchResult> ();

		for (Account account : accountList) {
			results.add(
			            new LookupSearchResult(
			                                   account.Id,
			                                   'Account',
			                                   accountIcon,
			                                   account.Name,
			                                   'Address: ' + account.BillingStreet + ' ' + account.BillingCity + ' ' + account.BillingState + ' ' + account.BillingCountry + ' ' + account.BillingPostalCode)
			);

		}
		System.debug('Lookup results are: ' + results);
		return results;
	}

	@AuraEnabled(Cacheable = false)
	public static List<LookupSearchResult> getAccountListFinance(String searchTerm,
	                                                             List<String> selectedIds,
	                                                             String searchType) {
		System.debug('accData@@@@@@@@@@' + searchTerm);

		//String acc =: '%accData%';
		List<Account> accountList = new List<Account> ();
		accountList = [Select id, name, RecordType.Name, BillingAddress from Account where Name LIKE :'%' + searchTerm + '%' AND RecordType.Name IN ('Agency Account', 'In House Agency Account')];

		String accountIcon = 'standard:account';
		List<LookupSearchResult> results = new List<LookupSearchResult> ();

		for (Account account : accountList) {
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

	@AuraEnabled(Cacheable = true)
	public static Lead getLeadDetails(String LeadId) {
		Lead leadDetails = new Lead();
		if (LeadId != null) {
			leadDetails = [Select Id, name, Owner.Name, OwnerId, Primary_Commodity__c, Company, city, PostalCode, State, Street, Country, Commodity_Codes__c, FirstName,LastName,Email from Lead where Id = :LeadId];
			return leadDetails;
		}
		return null;
	}

	@AuraEnabled
	public static Lead updateLeads(Lead leads) {
		System.debug('Lead Information ' + leads);
		if (leads != null) {
			update leads;
		}
		return null;
	}
	
    /*@AuraEnabled(Cacheable = true)
	public static List<Account> getdetails(string userId) {
		List<Account> entities = new List<Account> ();
		entities = [SELECT Id, name, Primary_Commodity__c, DUNSNumber__c, Account_Record_Type_Name__c, Commodity_Codes__c From Account where id = '0015500001FInW9AAL'];

		return entities;
	}*/

	@AuraEnabled
	public static String accountDetails(String accountId) {
		System.debug('Account Id--------------------' + accountId);
		Account acc = new Account();
		String accountName;
		acc = [Select Id, Name from Account where Id = :accountId LIMIT 1];
		System.debug('acc@@@@@@ ' + acc);
		accountName = acc.Name;
		System.debug('acc.name ----------------' + acc.Name);
		return accountName;
	}

	@AuraEnabled
	public static string convertLead(Lead objLead, string strSelectedAccount, boolean doNotCreateOppty, string strOppName, string strOwnerId)
	{
		objLead.Status = 'Converted';
		system.debug('===========>> in convertLead!!!');
		string strAccId;
		string strError = '';
		Boolean createAccount = false;
		System.debug('Lead ' + objLead);
		System.debug('Selected Accounts  ' + strSelectedAccount);
		System.debug('doNotCreateOppty  ' + doNotCreateOppty);
		System.debug('Opportunity Name ' + strOppName);
		System.debug('strOwnerId    ' + strOwnerId);

		try {
			//to prevent any workflows or approval processes from firing
			Lead objLeadToUpdate = new Lead();
			if (objLead != null)
			{
				objLeadToUpdate = [SELECT Id, Status, OwnerId, Name, FirstName, LastName, Email, Company, Owner.Name, Street, City, State, Country, PostalCode, Commodity_Codes__c
				                   FROM Lead WHERE Id = :objLead.Id];
				objLeadToUpdate.Exclude_Flows__c = true;
				if (objLeadToUpdate.Commodity_Codes__c == null) {
					//strError = 'You must set Commodity Codes on the Lead before converting.';
					//throw new AuraHandledException(strError);
					//throw new System.DmlException('You must set Commodity Codes on the Lead before converting.');

					Account acc = new Account();
					acc = [Select id, Name, Primary_Commodity__c, Commodity_Codes__c from Account where id = :strSelectedAccount];
					objLeadToUpdate.Primary_Commodity__c = acc.Primary_Commodity__c;
					objLeadToUpdate.Commodity_Codes__c = acc.Commodity_Codes__c;
					//objLeadToUpdate.Owner = UserInfo.getUserId();
					System.debug('Primary Commodity----------' + objLeadToUpdate.Primary_Commodity__c);
					System.debug('Secondary Commodity----------' + objLeadToUpdate.Commodity_Codes__c);

				}
				Database.SaveResult acc = Database.update(objLeadToUpdate, false);
				System.debug('acc: ' + acc);
				for (Database.Error err : acc.getErrors()) {
					strError += err.getMessage() + '</br>';
				}
				if (!acc.isSuccess())
				throw new System.DmlException(strError);
			}

			//if user selects to create new account
			if (strSelectedAccount == 'NEW')
			{
				system.debug('--------------objLead------------------' + objLeadToUpdate);
				Account objAccount = new Account();
				objAccount.Name = objLeadToUpdate.Company;
				objAccount.BillingStreet = objLeadToUpdate.Street;
				objAccount.BillingCity = objLeadToUpdate.City;
				objAccount.BillingState = objLeadToUpdate.State;
				objAccount.BillingCountry = objLeadToUpdate.Country;
				objAccount.BillingPostalCode = objLeadToUpdate.PostalCode;
				objAccount.Skip_Address_Validation__c = true;

				Database.DMLOptions dml = new Database.DMLOptions();
				dml.DuplicateRuleHeader.AllowSave = true;
				Database.SaveResult acc = Database.insert(objAccount, dml);
				for (Database.Error err : acc.getErrors())
				strError += err.getMessage() + '</br>';
				system.debug(loggingLevel.WARN, '$$$$$$$$$$$---->> strError = ' + strError);
				if (!acc.isSuccess())
				throw new System.DmlException(strError);
				strSelectedAccount = acc.getId();
				system.debug(loggingLevel.WARN, '$$$$$$$$$$$---->> acc = ' + acc);
				system.debug(loggingLevel.WARN, '$$$$$$$$$$$---->> strSelectedAccount = ' + strSelectedAccount);
				createAccount = true;
			}

			// This is the lead convert object that will convert the lead 
			Database.LeadConvert objLeadConvert = new database.LeadConvert();

			system.debug(loggingLevel.WARN, '===========>> strSelectedAccount = ' + strSelectedAccount);

			objLeadConvert.setLeadId(objLead.Id); //set lead ID   
			objLeadConvert.setAccountId(strSelectedAccount);
			objLeadConvert.setConvertedStatus(objLead.Status); //set the lead convert status
			objLeadConvert.setDoNotCreateOpportunity(doNotCreateOppty); //set the variable to create or not create an opportunity
			system.debug('--------------strError------------------' + strError);
			system.debug('===========================>> oppty name = ' + strOppName);
			objLeadConvert.setOpportunityName(((doNotCreateOppty) ? null : strOppName)); //set the Opportunity name
			system.debug('--------------strError------------------' + strError);
			objLeadConvert.setOwnerId(strOwnerId); //set the owner id
			system.debug('objLeadConvert --> ' + objLeadConvert);

			//convert the lead

			Database.DMLOptions dml = new Database.DMLOptions();
			dml.DuplicateRuleHeader.AllowSave = true;
			Database.LeadConvertResult leadConvertResult = Database.convertLead(objLeadConvert, dml);
			system.debug(loggingLevel.WARN, '=============>> leadConvertResult = ' + leadConvertResult);
			for (Database.Error err : leadConvertResult.getErrors()) {
				//Commentted by Madhusudhan to handle System.TypeCast Exception on 14 Jun-17
				//Datacloud.DuplicateResult dupRes = ((Database.DuplicateError) err).getDuplicateResult();
				//System.debug(LoggingLevel.WARN, '===============>> duplicate error rule = ' + dupRes.getDuplicateRule());
				strError += err.getMessage() + '</br>';
				//system.debug('--------------strError------------------'+ strError);
			}
			system.debug('--------------strError------------------' + strError);
			if (!leadConvertResult.isSuccess())

			throw new System.DmlException(strError);

			system.debug('--------------strError------------------' + strError);
			system.debug('%%%%%%%%%%%%%%%--->> leadConvertResult = ' + leadConvertResult);
			// if the lead converting was a success 
			if (leadConvertResult.isSuccess())
			//// BAB    strAccId = strSelectedAccount;
			////     if (!createAccount)
			////         strAccId = strSelectedAccount;
			////     else
			strAccId = leadConvertResult.getAccountId();
		}
		catch(exception ex)
		{
			Log4SF.logMessage('AccountRequestAPIController', 'convertLead', ex.getLineNumber() + ' ' + ex.getMessage(), UserInfo.getUserId(), '');
			system.debug('Exception..' + ex + ' Line Number: ' + ex.getLineNumber());
			throw new AuraHandledException(strError);
		}
		return strAccId;
	}
	@AuraEnabled(cacheable = true)
	public static List<Account_Creation_States__mdt> findStateRecords(String selectedStateName) {
		System.debug('stateCode' + selectedStateName);
		List<Account_Creation_States__mdt> metaQuery = [SELECT Id, country__c from Account_Creation_States__mdt WHERE State_Code__c = :selectedStateName];
		System.debug('metaQuery' + metaQuery);
		return metaQuery;

	}

	@AuraEnabled
	public static String duplicateContactNameCheck(String contactName) {
		System.debug('Contact Name ' + contactName);
		try {
			String nameReturn;
			List<Contact> duplicateName = [Select Id, Name from Contact Where Name = :contactName LIMIT 1];
			if (duplicateName.size() > 0) {
				nameReturn = 'Duplicate Name';
			}
			else {
				nameReturn = 'null';
			}

			return nameReturn;
		}
		catch(Exception e) {
			System.debug('Error: ' + e.getMessage() + 'Error Line Number: ' + e.getLineNumber());
			throw e;
		}
	}

	@AuraEnabled
	public static String duplicateContactEmailCheck(String contactEmail,String accountId) {
		System.debug('Contact Email ' + contactEmail);
		try {
			String emailReturn;
			List<Contact> duplicateEmail = [Select Id, Email from Contact Where Email = :contactEmail LIMIT 1];
			if (duplicateEmail != null && duplicateEmail.size() > 0) { 
                AccountContactRelation AccountConNew = new AccountContactRelation();
                AccountConNew.AccountId = accountId;
                AccountConNew.ContactId = duplicateEmail[0].Id;
                insert AccountConNew;
                return String.valueOf(duplicateEmail[0].Id);
			}
			return 'null';
		}
		catch(Exception e) {
			System.debug('Error: ' + e.getMessage() + 'Error Line Number: ' + e.getLineNumber());
			throw e;
		}
	}
    
    

	@AuraEnabled
	public static void submitForApproval(String AccountRequestId)
	{
		System.debug('AccountRequestId:' + AccountRequestId);
		Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		req1.setComments('Submitting Account request for approval');
		req1.setObjectId(AccountRequestId);
		Approval.ProcessResult result = Approval.process(req1);
		System.debug('Approval result:' + result);
		String UserId = UserInfo.getUserId();
		System.debug('Enter Step 1');
	}

	@AuraEnabled
    public static RecordType getRecordType(String recordTypeId){
        RecordType recordTypeList = new RecordType();
        if(String.isNotBlank(recordTypeId) && String.isNotEmpty(recordTypeId)){
            recordTypeList = [SELECT ID, NAME, DeveloperName  FROM RecordType WHERE ID =: recordTypeId];
            system.debug('recordTypeList ' + recordTypeList);
        }
        return recordTypeList;
    }

	@AuraEnabled
    public static User getUserDetail(String userId){
        User userDetails = new User();
        if(String.isNotBlank(userId) && String.isNotEmpty(userId)){
            userDetails = [SELECT ID, NAME, Budget_Type__c, Profile.Name FROM User WHERE ID =: userId LIMIT 1];
            system.debug('userDetails ' + userDetails);
        }
        return userDetails;
    }
}