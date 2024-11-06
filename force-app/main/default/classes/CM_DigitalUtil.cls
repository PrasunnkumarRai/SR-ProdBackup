/*
	Author 				 :  M & S
	Date   				 :  Jun 28-17
	Description 		 :  Supporting class for Digital Campaign object
							
	Modification History : 
*/
public class CM_DigitalUtil {
    
    public static final string strErrMsg = 'Error! The record is locked and can only be modified by Digital Operations or System Admins.';
    
    /*Need to Perevent Digital Campaign Record based on below criteria
    Sales_Cannot_Edit_Detail__c =True &&
	$Profile.Name <>'System Administrator' ||
	$Profile.Name <>'Master - Digital Operations)*/
    public static boolean isPreventRecordEdit(boolean isNotEditDetail){
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
		String strProflieName = PROFILE[0].Name;
		//boolean isResult = (isNotEditDetail && (strProflieName=='System Administrator'||strProflieName=='Master - Digital Operations'));
        boolean isResult = (isNotEditDetail && (strProflieName != 'System Administrator' && strProflieName != 'Master - Digital Operations' && strProflieName != 'Master - Digital Traffic'));
        return isResult;            
    }
}