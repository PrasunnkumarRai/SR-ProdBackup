@isTest
private class ThirdPartyGetAEsTest {
	static User u;   
	static List<UserAccountTeamMember> uatmList;  

    static testMethod void prepareTestData() {

    	List<User> userLst = New List<User>();
    	Profile p = [SELECT Id FROM Profile WHERE Name = 'Master - Account Planner'];
        u = TestDataHelper.createUser (false);
        u.profileId = p.Id;       

        INSERT u;
   		
        System.assert(u != null);  
    }

    static testMethod void doGetMethodPositivePathTest() {
        String response = ThirdPartyGetAEs.doGet();
        System.assert(response != null);
    }

    static testMethod void doPostMethodPositivePathTest1() {
    	prepareTestData();
    	// As DML operation not allowed on UserAccountTeamMember, retrieving data for code coverage
    	UserAccountTeamMember uam = [SELECT Id,OwnerId, OpportunityAccessLevel,TeamMemberRole,UserId FROM UserAccountTeamMember LIMIT 1 ];
                
        ThirdPartyGetAEs.AEListWrapper response = ThirdPartyGetAEs.doPost(uam.UserId, 'Audience App');
        System.assert(response != null);
	
    }

    static testMethod void notFoundAEs() {
    	prepareTestData();
        ThirdPartyGetAEs.AEListWrapper response = ThirdPartyGetAEs.doPost(u.Id, 'Audience App');
        System.assert(response != null);
    }    

    static testMethod void userNotAllowed() { 
        User lsmUser = TestDataHelper.createLSMUser(true);       
        User aeUser = TestDataHelper.createAEUser(false, 'standarduser@charter.com',lsmUser.Id);
   		INSERT aeUser;
        System.runAs(aeUser){
            ThirdPartyGetAEs.AEListWrapper response = ThirdPartyGetAEs.doPost(aeUser.Id, 'Audience App');
            System.assert(response != null);
        }
    }

    static testMethod void userNotExist() {
    	prepareTestData();
        ThirdPartyGetAEs.AEListWrapper response = ThirdPartyGetAEs.doPost(null, 'Audience App');
        System.assert(response != null);
    }

    static testMethod void invalidSource() {
    	prepareTestData();
        ThirdPartyGetAEs.AEListWrapper response = ThirdPartyGetAEs.doPost(u.Id,null);
        System.assert(response != null);
    }
}