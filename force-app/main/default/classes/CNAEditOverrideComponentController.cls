public class CNAEditOverrideComponentController {
    @AuraEnabled
    public static String checkAccountTeamMember( Id recordId ){
        System.debug('-----> recordId: '+recordId);
        String cacheKey = 'local.CNAPartition.' + recordId;
        Boolean doQuery = true;
        Boolean cnaIsCached = false;
        Long rightNow = Datetime.now().getTime();
        String LoggedINUser = Userinfo.getuserId();
        if (Cache.Session.contains(cacheKey)) {
            system.debug('=========>> num seconds = ' + ((rightNow - (Long) Cache.Session.get(cacheKey)) / 1000));
            doQuery = (((rightNow - (Long) Cache.Session.get(cacheKey)) / 1000)  < 5) ? false : true;
            cnaIsCached = true;
          //  Cache.Session.remove(cacheKey);
        }
        if (doQuery) {
            CNA__c cnaObj = [SELECT Id, Account__c,Opportunity__c,Opportunity__r.OwnerId FROM CNA__c WHERE Id=:recordId limit 1];
            if(checkForRecordOwner(cnaObj)){
                return 'true';
            }
            
            if(cnaobj.opportunity__c != null){
                if(checkForOpportunityTeamMember(cnaobj,LoggedINUser)){
                	return 'true';
                }else{
                    return 'oppfalse';
                }
               /* for( OpportunityTeamMember oppTeamObj : [Select a.UserId, a.Id, a.OpportunityId From OpportunityTeamMember a 
                                                 WHERE OpportunityId =: cnaObj.Opportunity__c]){
                        if( UserInfo.getUserId() == oppTeamObj.UserId ){
                            return 'true';
                        }else{
                            return 'oppfalse';
                        }                                          
                } */
            }else{
                if(checkForAccountTeamMember(cnaobj,LoggedINUser)){
                	return 'true';
                }else{
                    return 'oppfalse';
                }
              /*  for( AccountTeamMember accTeamObj : [Select a.UserId, a.Id, a.AccountId From AccountTeamMember a 
                                                 WHERE AccountId =: cnaObj.Account__c]){
                        if( UserInfo.getUserId() == accTeamObj.UserId ){
                            return 'true';
                        }else{
                            return 'accfalse';
                        }                                          
                } */
            }
        } else if (cnaIsCached) {
            return 'Record exists in cache';
        }
        return 'false';  
    }
    
    /*
    	Date        : Jul 26- 2018
    	Method Name : checkForRecordOwner
		Description : Checks the loggedin user and recordowner
    */
    public static boolean checkForRecordOwner(CNA__c cnaObj){
        boolean isFlag = false;
        if(cnaObj.Opportunity__r.OwnerId == Userinfo.getUserId())
                isFlag = true;
        return isFlag;
    }
    
    /*
    	Date        : Jul 26- 2018
    	Method Name : checkForOpportunityTeamMember
		Description : Checks the loggedin user in OpportunityTeamMember
    */
    public static boolean checkForOpportunityTeamMember(CNA__c cnaObj,Id loggedUser){
        boolean isFlag = false;
        List<OpportunityTeamMember>  OppTeam = [Select a.UserId, a.Id, a.OpportunityId From OpportunityTeamMember a 
                                                 WHERE OpportunityId =: cnaObj.Opportunity__c and a.userId =:loggedUser];
        if(OppTeam.size()>0)
            isFlag = true;
        return isFlag;
    }

	/*
    	Date        : Jul 26- 2018
    	Method Name : checkForAccountTeamMember
		Description : Checks the loggedin user in checkForAccountTeamMember
    */
    public static boolean checkForAccountTeamMember(CNA__c cnaObj,Id loggedUser){
        boolean isFlag = false;
        List<AccountTeamMember>  AppTeam = [Select a.UserId, a.Id, a.AccountId From AccountTeamMember a 
                                                 WHERE AccountId =: cnaObj.Account__c and a.userId =:loggedUser];
        if(AppTeam.size()>0)
            isFlag = true;
        return isFlag;
    }
}