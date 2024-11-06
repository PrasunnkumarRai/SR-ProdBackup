/*
  ###########################################################################
  # File..................: AdminUtility.cls
  # Version...............: 1
  # Created by............: Matthew Kidman
  # Created Date..........: 5-Mar-2019
  # Last Modified by......:
  # Last Modified Date....:
  # Description...........: This class is used to execute few of the admin related scripts.
  # TAO Ref#..............: NA
  # Test Class............: 
  # Change Log............:
  #
  #
  ############################################################################*/
global inherited sharing class AdminUtility implements Callable {

	public final String LOGIN_DOMAIN = 'test'; //other options: test, prerellogin.pre

	public String username { get { return UserInfo.getUsername(); } }
	public transient String password { get; set; }
	public string optionSelected { get; set; }
	public string year { get; set; }
	public string month { get; set; }
	public Sales_Budget__c userSelected { get; set; }
	public AdminUtility()
	{

	}

	// Dispatch actual methods
	@AuraEnabled(Cacheable = false)
	public static Object call(String action, Map<String, Object> args) {

		AdminUtilityCommonHelperController obj = new AdminUtilityCommonHelperController();

		System.debug('Call method called from LWC.');
		System.debug('Call method called from LWC action: ' + action);
		System.debug('Call method called from LWC args: ' + args);

		switch on action {
			when 'salesbudgetaggregate' {
				String strUserIds = (String) args.get('userID');
				List<String> lstUserIds = strUserIds.split(',');
				Set<String> strSetUserIds = new Set<String> (lstUserIds);
				Set<Id> userIds = (Set<Id>) JSON.deserialize(JSON.serialize(strSetUserIds), Set<Id>.class);

				if (((String) args.get('SelectedUserType')).Equals('Manager'))
				{
					Map<String, String> userTeamMap = new Map<String, String> ();
					for (string userId : userIds) {
						userTeamMap = obj.getUserTeam(userId);
						userIds.addAll((Set<Id>) JSON.deserialize(JSON.serialize(userTeamMap.keySet()), Set<Id>.class));
					}
				}
				System.debug('Call method called from LWC userIds: ' + userIds);

				executeSalesBudgetAggAdmin((String) args.get('query'), userIds, Boolean.valueOf(args.get('isRetry')));
				return 'Sales Budget Aggregate batch has been called successfully. User will be notified by Email.';
			}
			//START SRSF-3681
			/*when 'financeBudgetLoad' {

				executeFinanceDataLoad();
				return 'Finance Budget Load Executed Successfully';
				
			}*/
			//END SRSF-3681
            when 'usersalesbudgetaggregate'{
             	String strUserIds = (String) args.get('userID');
				List<String> lstUserIds = strUserIds.split(',');
				Set<String> strSetUserIds = new Set<String> (lstUserIds);  
                ID jobID = System.enqueueJob(new UserBudgetAggQueuebleJob(new List<String> (lstUserIds)));
                System.debug('Job Id '+ jobID);
                return 'Budget data batch has been called successfully.';
            }
			when 'removeusersalesbudget' {
				String strUserIds = (String) args.get('userID');
				List<String> lstUserIds = strUserIds.split(',');
				Set<String> strSetUserIds = new Set<String> (lstUserIds);
				Set<Id> userIds = (Set<Id>) JSON.deserialize(JSON.serialize(strSetUserIds), Set<Id>.class);

				if (((String) args.get('SelectedUserType')).Equals('Manager'))
				{
					Map<String, String> userTeamMap = new Map<String, String> ();
					for (string userId : userIds) {
						userTeamMap = obj.getUserTeam(userId);
						userIds.addAll((Set<Id>) JSON.deserialize(JSON.serialize(userTeamMap.keySet()), Set<Id>.class));
					}
				}
				System.debug('Call method called from LWC userIds: ' + userIds);

				removeUserSalesBudget(Integer.valueOf(args.get('Year')), Integer.valueOf(args.get('FromMonth')), Integer.valueOf(args.get('ToMonth')), userIds);
				return 'Sales Budget(s) has been deleted successfully for the selected user(s).';
			}
			when 'revenueaggregate' {
				String strUserIds = (String) args.get('userID');
				List<String> lstUserIds = strUserIds.split(',');
				Set<String> strSetUserIds = new Set<String> (lstUserIds);
				Set<Id> userIds = (Set<Id>) JSON.deserialize(JSON.serialize(strSetUserIds), Set<Id>.class);

				if (((String) args.get('SelectedUserType')).Equals('Manager'))
				{
					Map<String, String> userTeamMap = new Map<String, String> ();
					for (string userId : userIds) {
						userTeamMap = obj.getUserTeam(userId);
						userIds.addAll((Set<Id>) JSON.deserialize(JSON.serialize(userTeamMap.keySet()), Set<Id>.class));
					}
				}
				System.debug('Call method called from LWC userIds: ' + userIds);

				executeRevenueAgg((String) args.get('query'), userIds);
				return 'Revenue Aggregate batch has been called successfully. User will be notified by Email.';
			}
			when 'budgetfinalapprovalmasssubmission' {
				String strUserIds = (String) args.get('userID');
				List<String> lstUserIds = strUserIds.split(',');
				Set<String> strSetUserIds = new Set<String> (lstUserIds);
				Set<Id> userIds = (Set<Id>) JSON.deserialize(JSON.serialize(strSetUserIds), Set<Id>.class);
				System.debug('Call method called from LWC userIds: ' + userIds);

				massBudgetApproval(userIds);
				return 'Budget has been approved successfully.';
			}
			when 'budgetaggregate' {
				String strUserIds = (String) args.get('userID');
				List<String> lstUserIds = strUserIds.split(',');
				Set<String> strSetUserIds = new Set<String> (lstUserIds);
				Set<Id> userIds = (Set<Id>) JSON.deserialize(JSON.serialize(strSetUserIds), Set<Id>.class);

				if (((String) args.get('SelectedUserType')).Equals('Manager'))
				{
					Map<String, String> userTeamMap = new Map<String, String> ();
					for (string userId : userIds) {
						userTeamMap = obj.getUserTeam(userId);
						userIds.addAll((Set<Id>) JSON.deserialize(JSON.serialize(userTeamMap.keySet()), Set<Id>.class));
					}
				}
				System.debug('Call method called from LWC userIds: ' + userIds);

				budgetAggregate(userIds);
				return 'Budget Aggregate batch has been called successfully. User will be notified by Email.';
			}
			when 'undoforecastautomation' {
				String strUserId = (String) args.get('userID');
				System.debug('Call method called from LWC userIds: ' + strUserId);

				return deleteOpportunityFromUserOwner(strUserId);
			}
			when 'setuserpassword' {
				String strUserId = (String) args.get('userID');
				String NewPassword = (String) args.get('NewPassword');
				Boolean isValidPassword = Pattern.matches('((?=.*[a-z])(?=.*\\d)(?=.*[A-Z])(?=.*[@#$%!]).{8,40})', NewPassword);
				if (isValidPassword)
				{
					System.debug('Call method called from LWC userIds: ' + strUserId);
					System.debug('password @@@@:' + NewPassword);
					if (!Test.isRunningTest())
					return SetNewPassword(strUserId, NewPassword);

					else {
						return null;
					}
				}
				else {
					return 'Error;Invalid Password.Your password must include numbers, uppercase and lowercase letters, and at least one of these special characters.';
				}

			}
			//START : SRSF-2143
			when 'supportrequestsync' {
				String msg;
				Map<Id, String> supportReqRec = new Map<Id, String> ();
				Set<ID> supportReqIds = new Set<ID> ();
				System.debug('SupportRequest Call method called from LWC');
				for (Support_Request__c sr :[SELECT Id FROM Support_Request__c WHERE Integrated_with_IMN__c = FALSE AND IMN_Sync_Status__c = 'Error']) {
					supportReqRec.put(sr.Id, null);
					supportReqIds.add(sr.ID);
				}
				if (supportReqRec.size() > 0) {
					SupportRequestTriggerHandler.sendSupportRequestToIMN(supportReqIds, true);
					//	Database.executeBatch(new sendSupportRequest(supportReqRec, true), 1000);
					System.debug('SupportRequest records--->' + supportReqRec);
					msg = System.label.Resend_Support_Request_Success_Message;
				}
				else msg = System.label.Resend_Support_Request_Warning_Message;
				return msg;
			}
			when 'productionservicesync' {
				String msg;
				Map<Id, String> productionSerRec = new Map<Id, String> ();
				Set<ID> prodServID = new Set<ID> ();
				System.debug('ProductionService Call method called from LWC');
				for (Production_Service__c ps :[SELECT Id FROM Production_Service__c WHERE Integrated_with_IMN__c = FALSE AND IMN_Sync_Status__c = 'Error' AND(Linear_Order_Status__c = 'Complete - Billing Submitted' OR Digital_Order_Status__c = 'Complete - Billing Submitted')]) {
					productionSerRec.put(ps.Id, null);
					prodServID.add(ps.Id);
				}
				if (productionSerRec.size() > 0) {
					ProductionServiceTriggerHandler.sendProductionServToIMN(prodServID, true);
					//	Database.executeBatch(new sendProductionService(productionSerRec, true), 1000);
					System.debug('ProductionService records--->' + productionSerRec);
					msg = System.label.Resend_Production_Service_Success_Message;
				}
				else msg = System.label.Resend_Production_Service_Warning_Message;
				return msg;
			}
			when 'salesbudgetreport' {
				List<AggregateResult> sbrLogger = [SELECT MAX(CreatedDate) MaxCreatedDate FROM Logger__c
				                                   WHERE Class__c = 'AdminUtility' AND Method__c = 'salesbudgetreport'];
				System.debug('sbrLogger '+sbrLogger);
				if (sbrLogger != null && sbrLogger.size() > 0 && sbrLogger[0].get('MaxCreatedDate') != null) {
					Datetime MaxCreatedDate = ((Datetime) sbrLogger[0].get('MaxCreatedDate'));
					Long dt1Long = MaxCreatedDate.getTime();
					Long dt2Long = DateTime.now().getTime();
					Long milliseconds = dt2Long - dt1Long;
					Long seconds = milliseconds / 1000;
					Long minutes = seconds / 60;
					if (minutes <= 60) {
						return 'Sales budget report last executed on: ' + ((Datetime) sbrLogger[0].get('MaxCreatedDate')).format('MM/dd/yyyy hh:mm:ss a') + '. Sales Budget report can be fetched only once in an hour.';
					}
				}
				String processId = (String) args.get('processId');
				String boomiAtomId = (String) args.get('boomiAtomId');
				executeBoomiProcess(processId, boomiAtomId);
				Log4SF.logMessage('AdminUtility', 'salesbudgetreport', 'Sales Budget Report Executed from Apex', UserInfo.getUserId(), '');
				return 'The process has been initiated. Sales budget report will shortly be available in the syncplicity folder.';
			}
			//END : SRSF-2143
			when 'TotalLocalSponsorship'{
				System.debug('@@TotalLocalSponsorship');
				SponsorshipAdminUtilityController objSAUC = new SponsorshipAdminUtilityController();
				System.debug('selectedDataLoadDate'+args.get('selectedDataLoadDate'));
				String strDate = (String) args.get('selectedDataLoadDate');
				Date selectedDate = Date.valueOf(strDate);
				Datetime selectedDateTime = selectedDate.addDays(1);
				if (args.get('selectedDataLoadDate')==null) {
					objSAUC.createTotalLocalSponsorships(Datetime.now().date());	
				}
				else{
					objSAUC.createTotalLocalSponsorships(selectedDateTime.date());
				}
				return 'Sposorship generated succesfully';
			}
			when 'TotalNationalSponsorship'{
				System.debug('@@TotalNationalSponsorship');
				SponsorshipAdminUtilityController objSAUC = new SponsorshipAdminUtilityController();
				String strDate = (String) args.get('selectedDataLoadDate');
				Date selectedDate = Date.valueOf(strDate);
				Datetime selectedDateTime = selectedDate.addDays(1);
				if (args.get('selectedDataLoadDate')==null) {
					objSAUC.createTotalNationalSponsorships(Datetime.now().date());
				}
				else{
					objSAUC.createTotalNationalSponsorships(selectedDateTime.date());
				}
				return 'Sposorship generated succesfully';
			}
			when 'SoldNationalSponsorship'{
				System.debug('@@SoldNationalSponsorship');
				SponsorshipAdminUtilityController objSAUC = new SponsorshipAdminUtilityController();
				String strDate = (String) args.get('selectedDataLoadDate');
				Date selectedDate = Date.valueOf(strDate);
				Datetime selectedDateTime = selectedDate.addDays(1);
				if (args.get('selectedDataLoadDate')==null){
					objSAUC.createSoldNationalSponsorships(Datetime.now().date());
				}
				else{
					objSAUC.createSoldNationalSponsorships(selectedDateTime.date());
				}
				return 'Sposorship generated succesfully';
			}
			when 'SoldLocalSponsorship'{
				System.debug('@@SoldLocalSponsorship');
				SponsorshipAdminUtilityController objSAUC = new SponsorshipAdminUtilityController();
				String strDate = (String) args.get('selectedDataLoadDate');
				Date selectedDate = Date.valueOf(strDate);
				Datetime selectedDateTime = selectedDate.addDays(1);
				if (args.get('selectedDataLoadDate')==null){
					objSAUC.createSoldLocalSponsorships(Datetime.now().date());
				}
				else{
					objSAUC.createSoldLocalSponsorships(selectedDateTime.date());
				}
				return 'Sposorship generated succesfully';
			}
			when else {
				throw new ExtensionMalformedCallException('Method not implemented');
			}
		}
	}

	public class ExtensionMalformedCallException extends Exception { }

	//START SRSF-3681
	/*public static Integer executeFinanceDataLoad(){
		String processId= 'e1135adf-3638-4603-bcee-cefbc8dd0319';
		String boomiAtomId = 'e49f353b-286f-42ad-9df7-b8d93a5d490d';

		Http h = new Http();
		HttpRequest req = new HttpRequest();
		HttpResponse res;
		req.setEndpoint('callout:Boomi_SRS_Account/executeProcess');
		req.setMethod('POST');
		req.setHeader('Content-type', 'application/xml; charset=UTF-8');
		req.setTimeout(120000);
		String reqBody = '<ProcessExecutionRequest processId="' + processId + '" atomId="' + boomiAtomId + '" xmlns="http://api.platform.boomi.com/"></ProcessExecutionRequest>';
		req.setBody(reqBody);
		System.debug(req.getEndpoint());
		try {
			res = h.send(req);
			return res.getStatusCode();
		}
		catch(System.CalloutException e) {
			System.debug('refreshCache Callout error: ' + e + e.getLineNumber());
			return 0;
		}

	}*/
	//END SRSF-3681

	public static void executeSalesBudgetAggAdmin(string query, Set<Id> userID, Boolean isRetry)
	{
		if (String.isEmpty(query))
		{
			query = 'SELECT  Budget_User__c  , Budget_User__r.Name , Advertiser__c, Amount__c , Broadcast_Month_Date__c  FROM Sales_Budget__c ';
			query += 'where  (Type__c = \'Data\' and (Product_Line__c != \'New Business\' AND Product_Line__c != \'Unknown Churn\')) and Budget_User__c in : userIDs  order by Budget_User__r.Name,Advertiser__c desc';
		}
		System.debug('Call method called from LWC: userID: ' + userID);
		System.debug('Call method called from LWC: query: ' + query);
		System.debug('Call method called from LWC: isRetry: ' + isRetry);
		SalesBudgetAggregatebatch srb = new SalesBudgetAggregatebatch(query, userID, isRetry);
		srb.sendEmail = true;
		database.ExecuteBatch(srb, 2000);
	}

	public void executeSalesBudgetAgg(string query, Set<Id> userID, Boolean isRetry)
	{
		if (String.isEmpty(query))
		{
			query = 'SELECT  Budget_User__c  , Budget_User__r.Name , Advertiser__c, Amount__c , Broadcast_Month_Date__c  FROM Sales_Budget__c ';
			query += 'where  (Type__c = \'Data\' and (Product_Line__c != \'New Business\' AND Product_Line__c != \'Unknown Churn\')) and Budget_User__c in : userIDs  order by Budget_User__r.Name,Advertiser__c desc';
		}
		System.debug('Call method called from LWC: userID: ' + userID);
		System.debug('Call method called from LWC: query: ' + query);
		System.debug('Call method called from LWC: isRetry: ' + isRetry);
		SalesBudgetAggregatebatch srb = new SalesBudgetAggregatebatch(query, userID, isRetry);
		srb.sendEmail = true;
		database.ExecuteBatch(srb, 2000);
	}

	public static void budgetAggregate(Set<Id> userID) {

		String qry = '';
		qry = 'SELECT Budget_User__c,Budget_User__r.Budget_Type__c, Budget_User__r.Name , Type__c,Amount__c,DMA__c ,Broadcast_Month_Date__c,Product_Line__c FROM Sales_Budget__c ';
		qry += ' where ((Type__c = \'Data\' and (Product_Line__c != \'New Business\' AND Product_Line__c != \'Unknown Churn\')) OR Type__c = \'DOS\') ';
		qry += 'AND Calendar_Year(Broadcast_Month_Date__c) =' + System.Label.currentYear + ' AND Product_Line__c != null AND Amount__c != 0 and Budget_User__c =:userIDs order by Budget_User__c,Product_Line__c,Type__c desc';
		//To run the script for all Users just remove the "qry" parameter from the below call. **This will run for a while and might slow down the system because of the number of batches.
		BudgetAggregateBatch brb = new BudgetAggregateBatch(qry, userID, false);
		database.executeBatch(brb, 2000);

	}

	public static void massBudgetApproval(Set<Id> userID)
	{
		//Please change user id in the where clause to right approver
		List<Sales_Budget__c> sbList = new List<Sales_Budget__c> ();
		List<Sales_Budget_Approval__c> sbaList = new List<Sales_Budget_Approval__c> ();
		Sales_Budget__c sb = new Sales_Budget__c();
		system.debug('Sales Budget Approval :' + [Select id, Status__c
		             From Sales_Budget_Approval__c]);
		for (Sales_Budget_Approval__c sba :[Select id, Status__c, Sales_Budget__r.budget_user__r.name, Sales_Budget__r.Status__c, Sales_Budget__c
		     From Sales_Budget_Approval__c
		     Where Approver__c in :userID
		     and Sales_Budget__r.Status__c = 'Forecast Intermediate Approval' and Status__c != 'Forecast Approved']) {
			sb = new Sales_Budget__c();
			sb.id = sba.Sales_Budget__c;
			sb.Status__c = 'Final Approval';
			sbList.add(sb);

			sba.Status__c = 'Approved';
			sbaList.add(sba);
		}

		if (sbList.size() > 0) {
			System.debug(sbaList);
			System.debug(sbList);
			update sbaList;
			update sbList;
		}
	}

	public static void executeRevenueAgg(string query, Set<Id> userID)
	{
		if (String.isEmpty(query))
		{
			query = 'SELECT  Account_Executive__c, Account_Executive__r.Name , Advertiser__c, Net_Projected_Amount__c , Broadcast_Month_Date__c,Revenue_User__c,Revenue_User__r.Name ';
			query += ' FROM Revenue__c where  (Account_Executive__c in : userIDs OR Revenue_User__c in : userIDs ) AND Advertiser__c != null order by Account_Executive__r.Name, Advertiser__c  desc';
		}
		System.debug('Call method called from LWC: userID: ' + userID);
		System.debug('Call method called from LWC: query: ' + query);
		RevenueAggregateBatch srb = new RevenueAggregateBatch(query, userID);
		database.ExecuteBatch(srb, 2000);
	}

	public static void removeUserSalesBudget(Integer Year, Integer FromMonth, Integer ToMonth, Set<Id> userID)
	{
		if (userID != null && userID.size() > 0 && Year != 0)
		{
			list<Sales_Budget__c> sbList = [Select ID from Sales_Budget__c where Budget_User__c In :userId AND CALENDAR_YEAR(Broadcast_Month_Date__c) = :Year];
			if (sbList.size() > 0)
			delete sbList;
			list<Budget__c> bList = [Select ID from Budget__c where BudgetAE__c In :userId AND CALENDAR_YEAR(Broadcast_Month_Date__c) = :Year and Comments__c = 'Aggregate'];
			if (bList.size() > 0)
			delete bList;
		}
	}

	@Future
	public static void initiateSBAggregate(string userID)
	{
		try
		{
			if (String.isNotBlank(userID))
			{
				System.debug('user ID ' + userID);
				Set<ID> userIDs = new Set<ID> ();
				for (string usrID : userID.split(';'))
				{
					userIDs.add(Id.valueOf(usrID));
				}

				string query = 'SELECT  Budget_User__c  , Budget_User__r.Name , Advertiser__c, Amount__c , Broadcast_Month_Date__c  FROM Sales_Budget__c ';
				query += 'where  (Type__c = \'Data\' and (Product_Line__c != \'New Business\' AND Product_Line__c != \'Unknown Churn\')) and Budget_User__c in : userIDs  order by Budget_User__r.Name,Advertiser__c desc';
				SalesBudgetAggregatebatch srb = new SalesBudgetAggregatebatch('', userIDs, false);
				List<Sales_Budget__c> sbList = Database.query(query);
				srb.createSBWrapper(sbList);
				System.debug('srb ' + srb);
			}
		}
		catch(Exception ex)
		{
			Log4SF.logMessage('AdminUtility', 'initiateSBAggregate', ex.getMessage(), ex, UserInfo.getUserId(), userId, '');
		}
	}

	public void removeUserSalesBudget()
	{
		if (String.isNotBlank(userSelected.Budget_User__c) && String.isNotBlank(year))
		{
			Integer calYear = Integer.valueOf(year);
			system.debug('userSelected.Budget_User__c: ' + userSelected.Budget_User__c);
			system.debug('calYear: ' + calYear);

			list<Sales_Budget__c> sbList = [Select ID from Sales_Budget__c where Budget_User__c = :userSelected.Budget_User__c AND CALENDAR_YEAR(Broadcast_Month_Date__c) = :calYear];
			if (sbList.size() > 0)
			delete sbList;
		}
	}

	public static String buildSoapLogin(String username, String password) {
		XmlStreamWriter w = new XmlStreamWriter();
		w.writeStartElement('', 'login', 'urn:partner.soap.sforce.com');
		w.writeNamespace('', 'urn:partner.soap.sforce.com');
		w.writeStartElement('', 'username', 'urn:partner.soap.sforce.com');
		w.writeCharacters(username);
		w.writeEndElement();
		w.writeStartElement('', 'password', 'urn:partner.soap.sforce.com');
		w.writeCharacters(password);
		w.writeEndElement();
		w.writeEndElement();

		String xmlOutput =
		'<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Body>'
		+ w.getXmlString()
		+ '</Body></Envelope>';
		w.close();
		system.debug('xmlOutput: ' + xmlOutput);
		return xmlOutput;
	}

	@AuraEnabled(Cacheable = false)
	public static String verifyUserPassword(string password, string domain_name) {
		System.debug('verifyUserPassword');
		String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(sfdcBaseURL + '/services/Soap/u/22.0');
		request.setMethod('POST');
		request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
		request.setHeader('SOAPAction', '""');
		request.setBody(buildSoapLogin(UserInfo.getUsername(), password));

		//basically if there is a loginResponse element, then login succeeded; else there
		//  would be soap fault element after body
		system.debug('Soap Response: ' + (new Http()).send(request).getBodyDocument().getRootElement()
		             .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/'));

		final Boolean verified = (new Http()).send(request).getBodyDocument().getRootElement()
		.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
		.getChildElement('loginResponse', 'urn:partner.soap.sforce.com') != null;

		if (verified)
		{
			User usr = [Select ID, Run_Admin_Scripts__c from User where ID = :UserInfo.getUserID()];
			if (usr.Run_Admin_Scripts__c == true)
			return 'Success;Login Authenticated.';

			else
			return 'Error;Login Authentication failed. Please contact your System Administrator.';
		}
		else
		return 'Error;Login Authentication failed. Please contact your System Administrator.';
	}

	@AuraEnabled(Cacheable = true)
	public static List<MTAdminUtilityScriptAndParams__mdt> getScripts()
	{
		List<String> customPermission = new List<String> ();

		If (FeatureManagement.checkPermission('removeusersalesbudget'))
		customPermission.add('removeusersalesbudget');
		If (FeatureManagement.checkPermission('revenueaggregate'))
		customPermission.add('revenueaggregate');
		If (FeatureManagement.checkPermission('salesbudgetaggregate'))
		customPermission.add('salesbudgetaggregate');
	If(FeatureManagement.checkPermission('TerminatedUserDeactivation'))
		customPermission.add('TerminatedUserDeactivation');
		If (FeatureManagement.checkPermission('budgetfinalapprovalmasssubmission'))
		customPermission.add('budgetfinalapprovalmasssubmission');
		If (FeatureManagement.checkPermission('undoforecastautomation'))
		customPermission.add('undoforecastautomation');
		If (FeatureManagement.checkPermission('budgetaggregate'))
		customPermission.add('budgetaggregate');
		If (FeatureManagement.checkPermission('setuserpassword'))
		customPermission.add('setuserpassword');
		If (FeatureManagement.checkPermission('supportrequestsync'))
		customPermission.add('supportrequestsync');
		If (FeatureManagement.checkPermission('productionservicesync'))
		customPermission.add('productionservicesync');
		If (FeatureManagement.checkPermission('salesbudgetreport'))
		customPermission.add('salesbudgetreport');
		If (FeatureManagement.checkPermission('rejectforecast'))
		customPermission.add('rejectforecast');
		If (FeatureManagement.checkPermission('forecastsubmission'))
		customPermission.add('forecastsubmission');
        If (FeatureManagement.checkPermission('usersalesbudgetaggregate'))
		customPermission.add('usersalesbudgetaggregate');
		If (FeatureManagement.checkPermission('TotalLocalSponsorship'))
		customPermission.add('TotalLocalSponsorship');
		If (FeatureManagement.checkPermission('SoldLocalSponsorship'))
		customPermission.add('SoldLocalSponsorship');
		If (FeatureManagement.checkPermission('TotalNationalSponsorship'))
		customPermission.add('TotalNationalSponsorship');
		If (FeatureManagement.checkPermission('SoldNationalSponsorship'))
		customPermission.add('SoldNationalSponsorship');
		If (FeatureManagement.checkPermission('financeBudgetLoad'))
		customPermission.add('financeBudgetLoad');
        
         System.debug('User sales Budget '+ FeatureManagement.checkPermission('usersalesbudgetaggregate'));
		 System.debug('forecastsubmission '+ FeatureManagement.checkPermission('forecastsubmission'));
		 System.debug('financeBudgetLoad '+ FeatureManagement.checkPermission('financeBudgetLoad'));

		List<MTAdminUtilityScriptAndParams__mdt> scripts = [SELECT Id, NumberofParams__c, Script_Name__c, Script_Key__c
		                                                    FROM MTAdminUtilityScriptAndParams__mdt WHERE Script_Key__c IN :customPermission ORDER BY Script_Name__c];
		return scripts;
	}

	@AuraEnabled(Cacheable = true)
	public static String SBReportLastExecution()
	{
		List<AggregateResult> sbrLogger = [SELECT MAX(CreatedDate) MaxCreatedDate FROM Logger__c
		                                   WHERE Class__c = 'AdminUtility' AND Method__c = 'salesbudgetreport'];
		if (sbrLogger != null && sbrLogger.size() > 0 && sbrLogger[0].get('MaxCreatedDate') != null) {
			return 'Last execution time from apex: ' + ((Datetime) sbrLogger[0].get('MaxCreatedDate')).format('MM/dd/yyyy hh:mm:ss a') + '. Sales Budget report can be fetched only once in an hour.';
		}

		else {
			return 'Not executed';
		}
	}

	@AuraEnabled(Cacheable = true)
	public static List<Account_Transfer_Tool__c> getAllNewAXT()
	{
		String userId = UserInfo.getUserId();
		List<Account_Transfer_Tool__c> lstNewAXT = [SELECT ID, Name FROM Account_Transfer_Tool__c WHERE status__C = 'New' AND OwnerId = :userId];
		return lstNewAXT;
	}
	@AuraEnabled(Cacheable = true)
	public static string SetNewPassword(string strUserId, string NewPassword) {
		System.debug('newpassword@@@' + Newpassword);
		String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
		String restAPIURL = sfdcURL + '/services/data/v47.0/sobjects/User/' + strUserId + '/password';
		String sessionId = getSessionId();
		System.debug('sessionId:@@' + sessionId);
		System.debug('@@@@@' + restAPIURL);
		HttpRequest httpRequest = new HttpRequest();
		httpRequest.setMethod('POST');
		httpRequest.setHeader('Authorization', 'OAuth ' + sessionId);
		httpRequest.setHeader('Authorization', 'Bearer ' + sessionId);
		httpRequest.setHeader('Content-Type', 'application/json;charset=UTF-8');
		httpRequest.setEndpoint(restAPIURL);
		httpRequest.setBody('{"NewPassword" : "' + NewPassword + '"}');
		system.debug('pass@@: ' + '{"NewPassword" : "' + NewPassword + '"}');
		Http http = new Http();
		HttpResponse httpResponse = http.send(httpRequest);
		if (httpResponse.getStatusCode() == 204) {
			return 'Password Change Successful';
		} else {
			System.debug('httpResponse.getStatusCode(): ' + httpResponse.getStatusCode());
			System.debug(' httpResponse ' + httpResponse.getBody());
			return 'Password Change Unsuccessful';
		}
	}

	public static String deleteOpportunityFromUserOwner(string userID) {
		List<opportunity> oppProposalDataList = [SELECT Id, (SELECT Id, RecordType.DeveloperName FROM Proposals__r
		                                                     WHERE RecordType.DeveloperName NOT IN('Inventory', 'Linear', 'Political', 'Trade'))
		                                         FROM opportunity WHERE Source__c = 'Forecast Automation' and OwnerId = :userID];

		for (Integer i = (oppProposalDataList.size() - 1); i >= 0; i--)
		{
			opportunity oppProposalData = oppProposalDataList[i];
			if (oppProposalData.Proposals__r.size() == 0) {
				oppProposalDataList.remove(i);
			}
		}
		delete oppProposalDataList;
		delete[SELECT Id FROM Budget_Automation__c WHERE Budget_User__c = : userID and Budget_Year__c = : Decimal.valueOf(Label.Forecast_Automation_Year)];
		return 'Forecasted Data Undo successful.';
	}
	@AuraEnabled(Cacheable = true)
	public static String getSessionId() {
		try {
			System.debug('Page Content: ' + Page.SessionIdForLWC.getContent().toString());
			String strSessionDetails = Page.SessionIdForLWC.getContent().toString();
			String SessionId = strSessionDetails.split('<body>') [1].split('<script>') [0].trim();
			System.debug('SessionId After Split: ' + SessionId);
			return SessionId;
		}
		catch(exception ex) {
			return null;
		}

	}

	public static void executeBoomiProcess(String processId, String boomiAtomId)
	{
		//String processId = '4e7f276c-a537-4e9e-a371-ad734fee3980';
		//String boomiAtomId = '6b3f9f1a-d2b4-4d90-8706-94db2d036d14';
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		HttpResponse res;
		req.setEndpoint('callout:Boomi/executeProcess');
		req.setMethod('POST');
		req.setHeader('Content-type', 'application/xml; charset=UTF-8');
		req.setTimeout(120000);
		String reqBody = '<ProcessExecutionRequest processId="' + processId + '" atomId="' + boomiAtomId + '" xmlns="http://api.platform.boomi.com/"></ProcessExecutionRequest>';
		req.setBody(reqBody);
		try {
			res = h.send(req);
		}
		catch(System.CalloutException e) {
			System.debug('refreshCache Callout error: ' + e + e.getLineNumber());
		}
	}

	/*
	  public static void remoteAccess(String processName){
	  String boomiAtomId = '';
	 
	  try{
	  Map<String,Remote_Access_process__c> custSettMap = new Map<String,Remote_Access_process__c>();
	  custSettMap = Remote_Access_process__c.getAll();
	  System.debug('@@custSettMap '+custSettMap);	        
	  Remote_Access_process__c ti = custSettMap.get(processName);
	 
	  if(String.isNotBlank(ti.Boomi_Atom_Id__c)){
	  boomiAtomId = ti.Boomi_Atom_Id__c;		    	
	  System.debug('TIM System: '+ti.name);        
	  // Instantiate a new http object
	  Http h = new Http();
	  // Instantiate a new HTTP request, specify the method (POST) as well as the endpoint
	  HttpRequest req = new HttpRequest();
	  HttpResponse res ;
	  req.setEndpoint('callout:Boomi/executeProcess');
	  req.setMethod('POST');
	  req.setHeader('Content-type','application/xml; charset=UTF-8');
	  req.setTimeout(120000);
	  //Set request format
	  String reqBody = '<ProcessExecutionRequest processId="'+ System.label.BoomiCacheProcessId +'" atomId="'+ boomiAtomId +'" xmlns="http://api.platform.boomi.com/"></ProcessExecutionRequest>';
	  req.setBody(reqBody);
	  try {
	  res = h.send(req);
	  }
	  catch(System.CalloutException e) {
	  System.debug('refreshSingleCache Callout error: '+ e);
	  }
	  }	        
	  }
	  catch(Exception e) {
	  System.debug('refreshSingleCache error: '+ e + e.getLineNumber());
	  }
	 
	 
	 
	  }*/
	/*
	  global void createSBUpdateEvent(List<Sales_Budget__c> sbList)
	  {
	  List<SalesBudget_Aggregate_User__e> eventlist = new List<SalesBudget_Aggregate_User__e>();
	  for(Sales_Budget__c sb : sbList)
	  {
	  SalesBudget_Aggregate_User__e sbae = new SalesBudget_Aggregate_User__e(User_ID__c = sb.Budget_User__c);
	  eventlist.add(sbae);
	  }
	 
	  // Call method to publish events
	  List<Database.SaveResult> results = EventBus.publish(eventlist);
	 
	  // Inspect publishing result for each event
	  for (Database.SaveResult sr : results) {
	  if (sr.isSuccess()) {
	  System.debug('Successfully published event.');
	  } else {
	  for(Database.Error err : sr.getErrors()) {
	  System.debug('Error returned: ' +
	  err.getStatusCode() +
	  ' - ' +
	  err.getMessage());
	  }
	  }       
	  }
	  }
	 */
	@AuraEnabled(Cacheable = false)
	public static String submitforecast(String USerid, Map<String, Object> args) {
		System.debug('@@sy' + args);
		if (((String) args.get('SelectedUserType')).Equals('Manager'))
		{
			BudgetingToolController.impparam = USerid;
			BudgetingToolController btc = new BudgetingToolController();
			System.debug('@@btc.userMap.keySet()' + btc.userMap.keySet());
			BudgetingToolMassResubmission bt = new BudgetingToolMassResubmission('AdminUtility', btc.userMap);
			if(!Test.isRunningTest()){
			Database.executeBatch(bt, 1);
			return 'Forecast submimission batch has been Initiated';
			}
			return'Forecast submimission batch has been Initiated';
		}

		else {

			BudgetingToolController.impparam = USerid;
			System.debug('USerid ' + USerid);
			//Execute forecast submission
			BudgetingToolController btc = new BudgetingToolController();
			btc.submitForecast();
			return 'Forecast Submitted For The Selected User';
		}
	}
	@AuraEnabled(Cacheable = false)
	public static String rejectForecast(String userid) {
		System.debug('userid' + userid);
		list<Sales_Budget__c> sbList = [select id from Sales_Budget__c where Type__c = 'workflow' and Budget_User__c = :userid and CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.BudgetCurrentYear)];
		System.debug('sbList ' + sbList);
		if (sbList != null && sbList.size() > 0) {
			//BudgetingToolController.rejectForecast(sbList[0].id, 'Forecast Rejected From Admin Utility Tool by ' + UserInfo.getUserId());
			sbList[0].status__c = 'Forecast Rejected';
			System.debug('sblist@@' + sbList);
			update sbList;
			return 'Forecast Data Has Been Rejected For The Selected User';
		}
		else {
			return 'No workflow Record Found For Selected User';
		}
	}
	@AuraEnabled(Cacheable = false)
	public static String rejectForecastManager(String userid) {
		System.debug('userid' + userid);
		BudgetingToolController.impparam = USerid;
		BudgetingToolController btc = new BudgetingToolController();
		System.debug('@@btc.userMap.keySet()' + btc.userMap.keySet());

		list<Sales_Budget__c> sbList = [select id from Sales_Budget__c where Type__c = 'workflow' and Budget_User__c In :btc.userMap.keySet() and CALENDAR_YEAR(Broadcast_Month_Date__c) = :Integer.valueOf(Label.BudgetCurrentYear)];
		System.debug('sbList ' + sbList);
		if (sbList != null && sbList.size() > 0) {
			for (Sales_Budget__c sb : sbList) {

				sb.status__c = 'Forecast Rejected';
				System.debug('sblist@@' + sbList);

			}
			update sbList;
			return 'Forecast Data Has Been Rejected For The Selected User';

		}
		else {
			return 'No workflow Record Found For Selected User';
		}
	}

}