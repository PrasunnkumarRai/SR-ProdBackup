global inherited sharing class AdminUtilityCommonHelperController {
	private final static Integer MAX_RESULTS = 5;

	@AuraEnabled(Cacheable = true)
	public static List<LookupSearchResult> getUsers(
	                                                String searchTerm,
	                                                List<String> selectedIds,
	                                                String searchType
	) {
		System.debug('searchType: ' + searchType);
		List<String> managerProfiles = new List<String> ();
		List<String> userProfiles = new List<String> ();
		List<String> supportProfiles = new List<String> ();
		supportProfiles.add('Master - Account Coordinator');
		List<UserClassification__mdt> Profiles = [SELECT Id, User_Profiles__c, Label FROM UserClassification__mdt LIMIT 1000];
		System.debug('Profiles ' + Profiles);
		for (UserClassification__mdt prof : Profiles)
		{
			if (!prof.Label.equalsIgnoreCase('Account Executive') && !prof.Label.equalsIgnoreCase('Support')
			    && !prof.Label.equalsIgnoreCase('System Administrator') && !prof.Label.equalsIgnoreCase('Finance')
			    && !prof.Label.equalsIgnoreCase('National Sales Manager'))
			{
				List<String> spltProfiles = prof.User_Profiles__c.split(',');

				for (String p : spltProfiles)
				{
					managerProfiles.add(p);
				}
			}

			else if (prof.Label.equalsIgnoreCase('Account Executive') || prof.Label.equalsIgnoreCase('National Sales Manager'))
			{
				List<String> spltProfiles = prof.User_Profiles__c.split(',');

				for (String p : spltProfiles)
				{
					userProfiles.add(p);
				}
			}

			else if (prof.Label.equalsIgnoreCase('Support'))
			{
				List<String> spltProfiles = prof.User_Profiles__c.split(',');

				for (String p : spltProfiles)
				{
					supportProfiles.add(p);
				}
			}
		}

		// Prepare query paramters
		searchTerm += '*';
		List<List<SObject>> searchResults;
		// Execute search query
		//System.debug('userProfiles@@' + allUserProfiles);
		if (searchType.equalsIgnoreCase('National'))
		{
			searchResults = [
			                 FIND :searchTerm
			                 IN NAME FIELDS
			                 RETURNING
			                 User(Id, Name, Email, Profile.Name, Manager.Name WHERE id NOT IN :selectedIds AND Budget_Type__c = 'National')
			                 LIMIT :MAX_RESULTS
			                ];
		}

		else if (searchType.equalsIgnoreCase('local'))
		{
			searchResults = [
			                 FIND :searchTerm
			                 IN NAME FIELDS
			                 RETURNING
			                 User(Id, Name, Email, Profile.Name, Manager.Name WHERE id NOT IN :selectedIds AND Budget_Type__c = 'Local')
			                 LIMIT :MAX_RESULTS
			                ];
		}

		else if (searchType.equalsIgnoreCase('User'))
		{
			searchResults = [
			                 FIND :searchTerm
			                 IN NAME FIELDS
			                 RETURNING
			                 User(Id, Name, Email, Profile.Name, Manager.Name WHERE id NOT IN :selectedIds AND Profile.Name IN :userProfiles)
			                 LIMIT :MAX_RESULTS
			                ];
		}
		else if (searchType.equalsIgnoreCase('AccountCreation'))
		{
			//Id profileId = userinfo.getProfileId();
			
			List<Profile> profileId = [Select Id, Name from Profile where Id = :userinfo.getProfileId() LIMIT 1];
			String profileName = profileId[0].Name;
			if (profileName == 'Master - Account Planner' || profileName == 'Master - Account Coordinator' || profileName == 'Master - Digital Planner' 
				|| profileName == 'Master - Interconnect Account Coordinator' || profileName == 'Master - Interconnect Account Executive' 
				|| profileName == 'Master - Interconnect Account Planner' || profileName == 'Master - Field Marketing' || profileName == 'Master - Sales Support Manager'
				|| profileName == 'Master - National Account Planner') {
				User loggedUser = [SELECT ID, Name, Profile.Name FROM User WHERE ID = :UserInfo.getUserId() LIMIT 1];
				Boolean isSupportProfileUser = false;
				if (supportProfiles.contains(loggedUser.Profile.Name)) {
					isSupportProfileUser = true;
				}

				//if (isSupportProfileUser) {
				Set<Id> userIds = new Set<Id> ();
				List<UserAccountTeamMember> uatm = [SELECT OwnerId, User.Name, UserId, TeamMemberRole FROM UserAccountTeamMember WHERE userId = :UserInfo.getUserId()];
				System.debug('uatm list size' + uatm.size());
				for (UserAccountTeamMember uid : uatm) {
					userIds.add(uid.OwnerId);
				}
				// searchResults = [
				//                  FIND :searchTerm
				//                  IN NAME FIELDS
				//                  RETURNING
				//                  User(Id, Name, Email, Profile.Name, Manager.Name WHERE ID IN :userIds AND Manager.Name != null AND Id NOT IN :selectedIds)
				//                  LIMIT :MAX_RESULTS
				//                 ];

				searchResults = [
				                 FIND :searchTerm
				                 IN NAME FIELDS
				                 RETURNING
				                 User(Id, Name, Email, Profile.Name, Manager.Name WHERE Manager.Name != null AND Id NOT IN :selectedIds)
				                 LIMIT :MAX_RESULTS
				                ];
			}
			else if (profileName == 'Master - Local Sales Manager' || profileName == 'Master - National Sales Manager') {
				User loggedUser = [SELECT ID, Name, Profile.Name FROM User WHERE ID = :UserInfo.getUserId() LIMIT 1];
				Boolean isSupportProfileUser = false;
				if (supportProfiles.contains(loggedUser.Profile.Name)) {
					isSupportProfileUser = true;
				}

				//if (isSupportProfileUser) {
				Set<Id> userIds = new Set<Id> ();
				searchResults = [
				                 FIND :searchTerm
				                 IN NAME FIELDS
				                 RETURNING
				                 User(Id, Name, Email, Profile.Name, Manager.Name WHERE IsActive = true AND(HR_Manager__c = :UserInfo.getUserId() OR Id = :UserInfo.getUserId()) AND Id NOT IN :selectedIds)
				                 LIMIT :MAX_RESULTS
				                ];
			}
			else if (profileName == 'Integration User' || profileName == 'System Administrator'|| profileName == 'Master - FBO' ) {
				User loggedUser = [SELECT ID, Name, Profile.Name FROM User WHERE ID = :UserInfo.getUserId() LIMIT 1];
				Boolean isSupportProfileUser = false;
				if (supportProfiles.contains(loggedUser.Profile.Name)) {
					isSupportProfileUser = true;
				}
				System.debug('searchTerm: '+searchTerm);
				System.debug('selectedIds: '+selectedIds);
				System.debug('MAX_RESULTS: '+MAX_RESULTS);

				searchResults = [
				                 FIND :searchTerm
				                 IN NAME FIELDS
				                 RETURNING
				                 User(Id, Name, Email, Profile.Name, Manager.Name WHERE Manager.Name != null AND Id NOT IN :selectedIds)
				                 LIMIT :MAX_RESULTS
				                ];
				System.debug('searchResults: '+searchResults);
			}
			else if (profileName == 'Master - Director of Sales' || profileName == 'Master - National Sales Director' || profileName == 'Master - Sales Leadership') {
				String DosId = UserInfo.getUserId();
				AdminUtilityCommonHelperController adminUtilityHelper = new AdminUtilityCommonHelperController();
				Map<String, String> getUserList = new Map<String, String> (adminUtilityHelper.getUserTeam(DosId));
				List<String> usersIds = new List<String> ();
				Set<String> userKeys = getUserList.keySet();
				for (String UId : userKeys) {
					usersIds.add(UId);
				}
				searchResults = [
				                 FIND :searchTerm
				                 IN NAME FIELDS
				                 RETURNING
				                 User(Id, Name, Email, Profile.Name, Manager.Name WHERE Id in :usersIds AND Id NOT IN :selectedIds)
				                 LIMIT :MAX_RESULTS
				                ];
			}
			else if (profileName == 'Master - Sales Support Manager' || profileName == 'Master - Interconnect Sales Manager') {
				User loggedUser = [SELECT ID, Name, Profile.Name FROM User WHERE ID = :UserInfo.getUserId() LIMIT 1];
				Boolean isSupportProfileUser = false;
				if (supportProfiles.contains(loggedUser.Profile.Name)) {
					isSupportProfileUser = true;
				}

				Set<Id> userIds = new Set<Id> ();
				List<UserAccountTeamMember> uatm = [SELECT OwnerId, User.Name, UserId, TeamMemberRole FROM UserAccountTeamMember WHERE UserId = :UserInfo.getUserId() AND Id NOT IN :selectedIds];
				for (UserAccountTeamMember uid : uatm) {
					userIds.add(uid.OwnerId);
				}
				searchResults = [
				                 FIND :searchTerm
				                 IN NAME FIELDS
				                 RETURNING
				                 User(Id, Name, Email, Profile.Name, Manager.Name WHERE Id in :userIds AND Manager.Name != null)
				                 LIMIT :MAX_RESULTS
				                ];
			}
			else if(profileName == 'Master - Account Executive'){
				searchResults = [
					FIND :searchTerm
					IN NAME FIELDS
					RETURNING
					User(Id, Name, Email, Profile.Name, Manager.Name WHERE Id =: UserInfo.getUserId())
					LIMIT :MAX_RESULTS
				   ];
			}
		}
		else if (searchType.equalsIgnoreCase('All User')){
			searchResults = [
				FIND :searchTerm
				IN NAME FIELDS
				RETURNING
				User(Id, Name, Email, Profile.Name, Manager.Name WHERE Profile.Name NOT IN ('Integration User','System Administrator',null)) 
				LIMIT :MAX_RESULTS
			   ];
		}
		else
		{
			System.debug('Inside else:'  + searchType);
			searchResults = [
			                 FIND :searchTerm
			                 IN NAME FIELDS
			                 RETURNING
			                 User(Id, Name, Email, Profile.Name, Manager.Name WHERE Profile.Name IN('Master - Local Sales Manager', 'Master - National Sales Manager', 'Master - Account Executive'))
			                 LIMIT :MAX_RESULTS
			                ];
		}

		// Prepare results
		List<LookupSearchResult> results = new List<LookupSearchResult> ();

		// Extract Accounts & convert them into LookupSearchResult
		String userIcon = 'standard:user';
		User[] users = ((List<User>) searchResults[0]);
		for (User user : users) {
			results.add(
			            new LookupSearchResult(
			                                   user.Id,
			                                   'User',
			                                   userIcon,
			                                   user.Name,
			                                   'Email : ' + user.Email + '\n' + ' | Profile : ' + user.Profile.Name + '\n' + ' | Manager : ' + user.Manager.Name
			)
			);
		}
		System.debug('results: '+results);
		return results;
	}


	public Map<String, String> getUserTeam(Id managerUserId)
	{
		User loggedInUser;
		Map<String, String> userMap = new Map<String, String> ();
		String loggedInUserRole;
		String loggedInBudgetView;
		List<String> userList = new List<String> ();

		loggedInUser = [Select id, name, profile.name, HR_Manager__c, HR_Manager__r.email, HR_Manager__r.name, Budget_Type__c, Budget_Product_Lines__c, Budget_DMA__c, HR_Level__c, BT_Sum_on_Budget__c
		                from User
		                where id = :managerUserId or name = :managerUserId limit 1];

		for (UserClassification__mdt uc :[Select id, DeveloperName, MasterLabel, user_profiles__c, Budget_View__c, Impersonate_Capability__c
		     from UserClassification__mdt LIMIT 1000]) {
			if (uc.user_profiles__c.contains(loggedInUser.profile.name)) {
				loggedInUserRole = uc.developername;
				loggedInBudgetView = uc.Budget_View__c;
				break;
			}
			else {
				loggedInUserRole = 'NA';
				loggedInBudgetView = 'NA';
			}
		}
		List<String> uList = new List<String> ();
		if (loggedInBudgetView == 'Manager' || loggedInBudgetView == 'Leadership')
		{
			List<User> users = [Select id, name, profile.name, HR_Manager__r.email, HR_Manager__r.name, Budget_Type__c, Budget_Product_Lines__c, HR_Level__c
			     from User
			     where hr_manager__c = :loggedInUser.id
			     order by name];
			for (User ru :users)
			{
				userList.add(ru.name);
				userMap.put(ru.id, ru.name);
				uList.add(ru.id);
				System.debug('usermap' + userMap);
				System.debug('userList' + userList);
			}
		}
		if (loggedInBudgetView == 'Leadership' || loggedInBudgetView == 'Executive') {

			List<String> nList = new List<String> ();
			Integer i = 0;
			Integer countI = 0;
			do {
				i = 0;
				nList = new List<String> ();
				for (User ru :[Select id, name, profile.name, HR_Manager__r.email, HR_Manager__r.name, Budget_Type__c, Budget_Product_Lines__c, HR_Level__c
				     from User
				     where HR_Manager__c in :uList
				     order by HR_Manager__r.name, name]) {
					if (userList.size() <= 998) {
						userList.add(ru.HR_Manager__r.name + ' -- ' + ru.name);
						userMap.put(ru.id, ru.name);
					}
					i++;
					nList.add(ru.id);
				}

				uList = new List<String> ();
				uList.addAll(nList);
				System.debug(uList);
				countI++;
			}
			while (i > 0);

			System.debug(countI);
		}
		userList.add(loggedInUser.name);
		userMap.put(loggedInUser.id, loggedInUser.name);
		System.debug('UserTeam: ' + userMap);
		System.debug('UserTeam Size: ' + userMap.size());
		return userMap;
	}


	//Test
	//Another Comment
	@AuraEnabled(Cacheable = false)
	public static String verifyQuery(String query) {
		try
		{
			System.debug('User Query: ' + query);
			Database.Query('SELECT Budget_User__c, Budget_User__r.Name, Advertiser__c, Amount__c, Broadcast_Month_Date__c FROM Sales_Budget__c WHERE ' + query + ' LIMIT 0');
			return 'True';
		}
		catch(QueryException ex)

		{
			system.debug('Error InitiateTransfer: ' + ex.getMessage());
			Log4SF.logMessage('AdminUtilityCommanHelperController', 'verifyQuery', ex.getMessage(), ex, UserInfo.getUserId(), query, '');
			return 'Exception';
		}
	}
}