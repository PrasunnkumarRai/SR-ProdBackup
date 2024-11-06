//Checking for AccountTeamMember related to the Account 
public class AECheckForAccountTeam {
	@AuraEnabled
    public static ResponseData checkAccExeInAccTeam( string aeId ){
        ResponseData objRD = new ResponseData();
        boolean isAEOnAccTeam = false;
        Account_Request__c objAR = [select id,Advertiser_Agency_Rep_Firm__c,Account_Executive__c,Account_Executive__r.Sales_Office__c from Account_Request__c where id=:aeId];
        if(objAR.Advertiser_Agency_Rep_Firm__c!=null){
            string strSO = objAR.Account_Executive__r.Sales_Office__c;
            list<AccountTeamMember> lstTM = [select Id, AccountId from AccountTeamMember 
                                                WHERE AccountId =: objAR.Advertiser_Agency_Rep_Firm__c and TeamMemberRole ='Account Executive'
                                            	and User.Sales_Office__c=:strSO];
            isAEOnAccTeam = (lstTM!=null && !lstTM.isEmpty());
            objRD.isAEOnAccTeam = isAEOnAccTeam;
            objRD.strSO = objAR.Account_Executive__r.Sales_Office__c;
        }
        return objRD;
    }
    
    public class ResponseData{
    	@AuraEnabled public Boolean isAEOnAccTeam{get;set;}
    	@AuraEnabled public string strSO{get;set;}
    }
}