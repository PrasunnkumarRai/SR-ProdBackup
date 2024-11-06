public class NewAccountSAMMappingController {
    @AuraEnabled
    public static map<String, object> createAccountSAMMapping(Id accountValue){
        System.debug('accountValue'+ accountValue);
        map<String, object> data = new map<String, object>();
        map<String, object> defaultValues = new map<String, object>();
        Id userId = UserInfo.getUserId();
        data.put('entityApiName', 'Account_SAM_Mapping__c');
        defaultValues.put('OwnerId', userId );
        defaultValues.put('Account__c', accountValue );
        //Boolean isOnAccountTeam = isAccountTeamMember(accID);

        if( defaultValues.size() > 0 ){
            data.put( 'defaultFieldValues', defaultValues );
        }
        System.debug('data'+data);
        return data;
    }
   /* private static Boolean isAccountTeamMember(String accID) {
        for( AccountTeamMember accTeamObj : [Select UserId, Id From AccountTeamMember WHERE Account.Id =: accID]){
                if( UserInfo.getUserId() == accTeamObj.UserId ) {
                    return true;
                }                                          
            }
            return false;
    }*/
    
    @AuraEnabled(cacheable=true)
    public static string checkCountForTargetAndExtra(string samDesignation, string user){
        String val;
         System.debug('samDesignation' +samDesignation );
         List<Account_SAM_Mapping__c> asmList = new List<Account_SAM_Mapping__c>();
        if(System.label.SAMDesignationShutDown == 'FALSE'){
            asmList=  [Select Account__r.name, SAM_Designation__c from Account_SAM_Mapping__c  where SAM_Designation__c =:samDesignation];
            System.debug('asmList' + asmList);
        }
        return val;
    } 
}