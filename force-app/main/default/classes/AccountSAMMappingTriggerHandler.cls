public with sharing class AccountSAMMappingTriggerHandler {
    public set<id> setOnAccountTeam;
    
    public void OnBeforeInsert(Account_SAM_Mapping__c[] accountSAMMappings){
        try{
            set<id> setOnAccountTeam = getAccountIdFromAcccountTeamMember(accountSAMMappings);
            //populateDivisionData(accountSAMMappings);
            for(Account_SAM_Mapping__c sam : accountSAMMappings){
                if(sam.User__c != null){
                    if(sam.Source__c == 'DnB' || (setOnAccountTeam.contains(sam.Account__c) && sam.Source__c != 'DnB')  || sam.Source__c == 'DataLoad'){
                        //populateDivisionData(accountSAMMappings);
                    }
                    else{
                        sam.addError('You are not allowed to create a Account SAM Mapping as you are not present in the Account Team Member list.' );
                    } 
                }
                else{
                    //sam.addError('User field cannot be empty.'); Commented regarding Tier Designation change SRSF-4944
                }
            } 
        }catch(Exception ex){
            Log4SF.logMessage('AccountSAMMappingTriggerHandler','OnBeforeInsert',ex.getMessage(),ex,UserInfo.getUserId(),'');

        }
              
    }
    
    public void OnBeforeUpdate(Account_SAM_Mapping__c[] accountSAMMappings){
        try{
		set<id> setOnAccountTeam = getAccountIdFromAcccountTeamMember(accountSAMMappings);
        for(Account_SAM_Mapping__c sam : accountSAMMappings){
            if(setOnAccountTeam.contains(sam.Account__c)){
            	//populateDivisionData(accountSAMMappings);
            }
            else{
                sam.addError('You are not allowed to create a Account SAM Mapping as you are not present in the Account Team Member list.' );
            }
        }
        }catch(Exception ex){
            Log4SF.logMessage('AccountSAMMappingTriggerHandler','OnBeforeUpdate',ex.getMessage(),ex,UserInfo.getUserId(),'');
        }
        
    }
    
    public static void populateDivisionData(list<Account_SAM_Mapping__c> newAccountSAMMapping){
        List<Id> userIds = new List<Id> ();
	   //Populate User Text and Owner field with user field value, this is required to support SF Matching Rules
        for (Account_SAM_Mapping__c sam : newAccountSAMMapping) {
            sam.User_Text__c = sam.User__c;
            //sam.ownerId = sam.User__c; Commented regarding Tier Designation change SRSF-4944
            sam.ownerId = UserInfo.getUserId();
            userIds.add(sam.User__c);
        }
    
        Map<Id, User> userMap = new Map<Id, User> ([Select id, region__c, sales_office__c, division__c from User where id in :userIds]);
        system.debug('userMap '+userMap);
        Id asmId;
        Id userId;
        for (Account_SAM_Mapping__c asm : newAccountSAMMapping) {
            try { 
                asmId = asm.Id;
                userId = asm.User__c;
                asm.region__c = userMap.get(asm.User__c).region__c;
                asm.sales_office__c = userMap.get(asm.User__c).sales_office__c;
                asm.division__c = userMap.get(asm.User__c).division__c;
            }
            catch(Exception ex) {
                Log4SF.logMessage('AccountSAMMappingTrigger', 'Before Insert/Update', ex.getMessage(), ex, userInfo.getUserId(), 'asmId: ' + asmId, ' -- ' + 'userId: ' + userId);
            }
        }
    }
    
    public static Set<id> getAccountIdFromAcccountTeamMember(list<Account_SAM_Mapping__c> newAccountSAMMapping){
        try{
            set<Id> setAccountToSAM = new set<Id>();
            Set<Id> AccountIds = new Set<Id>();
            Set<Id> UserIds = new Set<Id>();
            for (Account_SAM_Mapping__c sam : newAccountSAMMapping) {
                // if (mapAccSAMAccountIds.containsKey(sam.User__c)) {
                //     mapAccSAMAccountIds.get(sam.User__c).add(sam.Account__c);
                // }
                // else {
                //     List<Id> accounts = new List<Id>();
                //     accounts.add(sam.Account__c);
                //     mapAccSAMAccountIds.put(sam.User__c, accounts);
                // }
                AccountIds.add(sam.Account__c);
                UserIds.add(sam.User__c);
            }
            for (AccountTeamMember atm : [select Id, AccountId, UserId from AccountTeamMember 
                                            where AccountId in : AccountIds]) {
                                            //and UserId in : UserIds
                                                system.debug('@@atm: '+atm);
                setAccountToSAM.add(atm.AccountId);
            }
            return setAccountToSAM;
        }catch(Exception ex){
            Log4SF.logMessage('AccountSAMMappingTriggerHandler','getAccountIdFromAcccountTeamMember',ex.getMessage(),ex,UserInfo.getUserId(),'');
            return null;
        }
        
    }
}