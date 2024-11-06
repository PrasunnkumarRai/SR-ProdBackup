/*
 * This class is written to get the Account Executives for the Planner / CoOrdinators 
 * and need to send in the response to Boomi
*/

@RestResource(urlMapping='/ThirdPartyGetAEs')
global with sharing class ThirdPartyGetAEs {    

    @HttpGet
    global static String doGet() {
        return 'ThirdPartyGetAEs API is Alive!';
    }

    @HttpPost
    global static AEListWrapper doPost(String userID, String source) {
    	System.debug(' ### userID ::: ' +userID);      
        System.debug(' ### source ::: ' +source);

        List<String> profilesLst = ((System.Label.ThirdParty_AE_Profiles).split(','));
        Set<String> profiles = new Set<String>(profilesLst);
       // System.debug('profiles ::::'+profiles);

        Map<String,Object> mapOfThirdPartyLog = new Map<String, Object>{'User__c' =>userID,'API_Name__c' => 'ThirdPartyGetAEs','Source__c' => source };
        Third_Party_Logger__c thirdPartyLogger = Log4SF.createThirdPartyLogger(mapOfThirdPartyLog,FALSE , new Third_Party_Logger__c());
       	
        String errMesg;
       	AEListWrapper response = new AEListWrapper();             			
		
        if(String.isBlank(userID)) {
            errMesg = String.format(System.Label.UserID_Not_esist, new List<String> {userID});
            System.debug(errMesg);
            thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure', 'Error_Message__c' =>errMesg} ,TRUE ,thirdPartyLogger);
            response = new AEListWrapper(FALSE,errMesg, NULL, NULL);
        }
        else if(String.isBlank(source) || source == null || source.equals('SPP')) {
            errMesg = System.Label.Invalid_Source;
            System.debug(errMesg);
            thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure', 'Error_Message__c' =>errMesg} ,TRUE ,thirdPartyLogger);
            response = new AEListWrapper(FALSE,errMesg, NULL, NULL);
        }
        else {

            // Check Whether requested user is allowwed or not
            List<User> reqUser = [SELECT Id, Profile.Name FROM User WHERE Id = :userID AND isActive = TRUE AND Profile.Name NOT IN :profiles];
           // System.debug('reqUser--->'+reqUser);
           if(reqUser.size() > 0){ 
                String usrAccType = (reqUser[0].Profile.Name == 'Master - Local Sales Manager' ? 'Seller' : 'Sale Support');
                Set<ID> userIDs = new Set<ID>();
                List<AccountExecutives> aeList = new List<AccountExecutives>();
                List<UserAccountTeamMember> uamList = [SELECT Id,OwnerId, OpportunityAccessLevel,TeamMemberRole,UserId FROM UserAccountTeamMember
                      WHERE UserId = : userID ];

        		if(uamList.Size()>0){
        			for(UserAccountTeamMember uam : uamList){
        				userIDs.add (uam.OwnerId);
        			}
        			List<User> usrList = [SELECT Id, Name, Email FROM User WHERE Id IN :userIDs AND isActive = true];
        			            
                    for(User usr : usrList){            	
                        aeList.add(new AccountExecutives(usr.Name,usr.Email));
                    }                               
                	response = new AEListWrapper(TRUE, 'Success',usrAccType,aeList);
        		}
                else{
                    errMesg = System.Label.AE_Not_Found+userID;
                    System.debug(errMesg);
                    thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure', 'Error_Message__c' =>errMesg} ,TRUE ,thirdPartyLogger);
                    response = new AEListWrapper(FALSE,errMesg,usrAccType, NULL);
                }
            } 
            else{
                errMesg = System.Label.User_Not_Allowed+userID;
                System.debug(errMesg);
                thirdPartyLogger = Log4SF.createThirdPartyLogger(new Map<String, Object>{'Status__c' => 'Failure', 'Error_Message__c' =>errMesg} ,TRUE ,thirdPartyLogger);
                response = new AEListWrapper(FALSE,errMesg,'Seller', NULL);
            }
        }
        return response;        
    }    

    global class AEListWrapper {
		global boolean isSuccess;
	    global String message;
        global String userAccountType;
	    global List<AccountExecutives> acctExecutives;

	    global AEListWrapper(){}

	    global AEListWrapper(boolean success, String msg, String userAcctType, List<AccountExecutives> resultList) {
	    	isSuccess = success;
	    	message = msg;
            userAccountType = userAcctType;
	    	acctExecutives = resultList;
	    }
	}

    global class AccountExecutives {        
        global String Name;
        global String Email;

        global AccountExecutives(){}

        global AccountExecutives (String usrName, String emailAddress) {
            Name = usrName;
            Email = emailAddress;            
        }
    }
}