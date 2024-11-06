public class AddAccTeamMemberBatch implements Database.Batchable < sObject > {
    private Set < String > accountIds;
    private Set < String > userIds;
    private Map<Id,String> atmTeamRoles;
    private Map < String, List < String >> dataforATM;
    // private Map < String, List < String >> mapForTeamRole;

    public AddAccTeamMemberBatch(Set < String > accountId, Map < String, List < String >> mapATMData, Map<Id,String> mapATMTeamRole) {
        System.debug('accountId in atm :::: ' + accountId);
        System.debug('mapATMData in batch :::: ' + mapATMData);
        System.debug('mapATMTeamRole in batch :::: ' + mapATMTeamRole);
        System.debug('mapData.keySet() in atm ::: ' + mapATMData.keySet());
      
      
        this.accountIds = accountId;
        this.userIds = mapATMData.keySet(); // Only user Ids
        this.atmTeamRoles = mapATMTeamRole;
        this.dataforATM = mapATMData;
        // this.mapForTeamRole = mapForTeamRoles;

    }

    public Database.QueryLocator start(Database.BatchableContext context) {

        String query = 'SELECT Id FROM Account WHERE Id IN :accountIds';
        return Database.getQueryLocator(query);
        
    }

    public void execute(Database.BatchableContext context, List < Account > accountList) {
       
        List < AccountTeamMember > accountTeamMemberList = new List < AccountTeamMember > ();
        for (Account acc : accountList) {
            for (String userId : dataforATM.keySet()) {
                if(listContains(dataforATM.get(userId),acc.Id)){
                    AccountTeamMember newATM = new AccountTeamMember();
                    newATM.AccountId = acc.Id;
                    newATM.UserId = userId;
                    newATM.TeamMemberRole = this.atmTeamRoles.get(userId);
                    newATM.AccountAccessLevel  = 'Edit';
                    accountTeamMemberList.add(newATM);
                }
            }
        }
        System.debug('accountList in atm::::: ' + accountList);
    
        if (!accountTeamMemberList.isEmpty()) {
            Database.insert(accountTeamMemberList, false);
         }
         System.debug('accountTeamMemberList in atm ::::: ' + accountTeamMemberList);
       
    }
    Boolean listContains(Object[] source, Object target) {
        return (new Set<Object>(source)).contains(target);
    }
   

    public void finish(Database.BatchableContext context) {
        // Optional: Add any post-processing logic here
    }
}