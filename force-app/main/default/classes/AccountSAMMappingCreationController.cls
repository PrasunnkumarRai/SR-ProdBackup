public with sharing class AccountSAMMappingCreationController {

    /*
	public String accId { get; set; }
	public String sd { get; set; }
	public User loggedInUser { get; set; }
    public String loggedInUserProfileName { get; set; }
	public boolean showAlert { get; set; }
    public boolean showErrorMessage { get; set; }
	*/


	// public AccountSAMMappingCreationController() {
	// 	System.debug(ApexPages.currentPage().getParameters().get('accId'));
	// 	System.debug(ApexPages.currentPage().getParameters().get('sd'));
	// 	showAlert = false;
    //     showErrorMessage = false;
	// 	//Get URL paramaters from List buttons
	// 	accId = ApexPages.currentPage().getParameters().get('accId');
	// 	sd = ApexPages.currentPage().getParameters().get('sd');


	// 	//Query logged in user details
	// 	loggedInUser = [Select id, region__c, sales_office__c, division__c
	// 	                from User
	// 	                where id = :UserInfo.getUserId()];
        
    //     loggedInUserProfileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()].Name;
        
    //     AccountTeamMember [] atm = [Select  Id, AccountId, UserId 
	// 		                                        from AccountTeamMember
	// 		                                        where UserId = :UserInfo.getUserId() and AccountId = :accId limit 1];
    //     if(loggedInUserProfileName == 'Master - Account Executive' && atm.size() == 0){
    //         showErrorMessage = true;
    //     }
        
	// 	if (sd == 'target') {
	// 		List<Account_SAM_Mapping__c> asmList = [Select Account__r.name, SAM_Designation__c
	// 		                                        from Account_SAM_Mapping__c
	// 		                                        where user__c = :UserInfo.getUserId() and
	// 		                                        SAM_Designation__c = 'Target'];

	// 		//If existing Target SAM Designation is Target exceeds max SAM Mapping records, allow user to delete existing ones
	// 		if (asmList.size() > Integer.valueOf(Label.SAMDesignationMaxTargetCount)) {
	// 			showAlert = true;
	// 			//PageReference prListView = new PageReference('/lightning/o/Account_SAM_Mapping__c/list?filterName='+Label.MyTargetsListView);
	// 			//return prListView;
	// 		}
	// 	}
	// }

	/*@AuraEnabled
	public static string validateForErrors(String accId, String sd){
		try {
			String errorMessage='';
			//Query logged in user details
			User loggedInUserDetails = [Select id, region__c, sales_office__c, division__c, Profile.Name, ProfileId from User where id = :UserInfo.getUserId() LIMIT 1];
			
			List<AccountTeamMember> atms = [Select  Id, AccountId, UserId from AccountTeamMember where UserId = :UserInfo.getUserId() and AccountId = :accId];
														
			if(loggedInUserDetails.Profile.Name == 'Master - Account Executive' && (atms == null || atms.size()==0)){
				errorMessage = 'You are not allowed to create a Account SAM Mapping as you are not present in the Account Team Member list.';
			}
			return errorMessage;

		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage() + ' ::LineNumber::'+ e.getLineNumber());
		}
	}*/

	@AuraEnabled
	public static Account_SAM_Mapping__c upsertASM(String accId, String sd){
		try {
				//Query logged in user details
				User loggedInUserDetails = [Select id, region__c, sales_office__c, division__c, Profile.Name, ProfileId from User where id = :UserInfo.getUserId() LIMIT 1];

				//Query for existing Account SAM Mapping
				List<Account_SAM_Mapping__c> asm = [Select id, Account__r.name, SAM_Designation__c
											from Account_SAM_Mapping__c
											where account__c = :accId and
											user__c = :UserInfo.getUserId()];

				//If existing Account SAM Mapping found, update to new SAM Designation
				if (asm != null && asm.size()>0) {
					asm[0].SAM_Designation__c = sd;
					asm[0].region__c = loggedInUserDetails.region__c;
					asm[0].sales_office__c = loggedInUserDetails.sales_office__c;
					asm[0].division__c = loggedInUserDetails.division__c;
					asm[0].ownerId = loggedInUserDetails.id;
					update asm[0];
					return asm[0];
				}

				//If no existing Account SAM Mapping exists, insert with new SAM Designation
				else {
					Account_SAM_Mapping__c newAsm = new Account_SAM_Mapping__c(account__c = accId, user__c = UserInfo.getUserId(),
																			SAM_Designation__c = sd, region__c = loggedInUserDetails.region__c,
																			sales_office__c = loggedInUserDetails.sales_office__c,
																			division__c = loggedInUserDetails.division__c,
																			ownerId = loggedInUserDetails.id);
					insert newAsm;
					return newAsm;
				}
			
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage() + ' ::LineNumber::'+ e.getLineNumber());
		}
	}

    //Obsolete Code.
	/*
	public PageReference upsertAccountSAMMapping() {
		try {
			System.debug('Checking Upsert Call');
			//If SAM Designation is Target, check for max SAM Mapping records
			if (showAlert)
			{
				PageReference prListView = new PageReference('/lightning/o/Account_SAM_Mapping__c/list?filterName=' + Label.MyTargetsListView);
				return prListView;
				//return '/lightning/o/Account_SAM_Mapping__c/list?filterName=' + Label.MyTargetsListView;
			}
            
            if (showErrorMessage){
                PageReference pr = new PageReference('/lightning/r/' + accId + '/related/Account_SAM_Mappings__r/view');
                pr.setRedirect(true);
                return pr;
				//return '/lightning/r/' + accId + '/related/Account_SAM_Mappings__r/view';
            }

			//Query for existing Account SAM Mapping
			Account_SAM_Mapping__c asm = [Select id, Account__r.name, SAM_Designation__c
			                              from Account_SAM_Mapping__c
			                              where account__c = :accId and
			                              user__c = :UserInfo.getUserId() limit 1];

			//If existing Account SAM Mapping found, update to new SAM Designation
			if (asm.id != null) {
				asm.SAM_Designation__c = sd;
				asm.region__c = loggedInUser.region__c;
				asm.sales_office__c = loggedInUser.sales_office__c;
				asm.division__c = loggedInUser.division__c;
				asm.ownerId = loggedInUser.id;
				update asm;
			}

			//If no existing Account SAM Mapping exists, insert with new SAM Designation
			else {
				Account_SAM_Mapping__c newAsm = new Account_SAM_Mapping__c(account__c = accId, user__c = UserInfo.getUserId(),
				                                                           SAM_Designation__c = sd, region__c = loggedInUser.region__c,
				                                                           sales_office__c = loggedInUser.sales_office__c,
				                                                           division__c = loggedInUser.division__c,
				                                                           ownerId = loggedInUser.id);
				insert newAsm;
			}
		}
		catch(Exception ex) {
			Log4SF.logMessage('AccountSAMMappingCreationController', 'upsertAccountSAMMapping', ex.getMessage(), ex, UserInfo.getUserId(), '', '');
			try {
				Account_SAM_Mapping__c asm = new Account_SAM_Mapping__c(account__c = accId, user__c = UserInfo.getUserId(),
				                                                        SAM_Designation__c = sd, region__c = loggedInUser.region__c,
				                                                        sales_office__c = loggedInUser.sales_office__c,
				                                                        division__c = loggedInUser.division__c,
				                                                        ownerId = loggedInUser.id);
				insert asm;
			}
			catch(Exception ex1) {
				Log4SF.logMessage('AccountSAMMappingCreationController', 'upsertAccountSAMMapping catch block', ex1.getMessage(), ex1, UserInfo.getUserId(), '', '');
			}
		}

		// //PageReference pr = new PageReference(Label.SalesforceLightningInstanceRecordId+accId+'/related/Account_SAM_Mappings__r/view');
		PageReference pr = new PageReference('/lightning/r/' + accId + '/related/Account_SAM_Mappings__r/view');
		pr.setRedirect(true);
		return pr;
		//return '/lightning/r/' + accId + '/related/Account_SAM_Mappings__r/view';
	}*/

}