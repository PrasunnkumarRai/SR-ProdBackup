public class AddOppTeamMembersBatch implements Database.Batchable < sObject > {
    private Set < String > accountIds;
    private Map<String,List<String>> mapOfUserAccount;
    private Map<Id,String> oppTeamRoles;
    // private Map < String, List < String >> mapForTeamRole;

    public AddOppTeamMembersBatch(Set <String> accountId, Map<String,List<String>> mapOfUserAccount, Map<Id,String> oppTeamRoleSet) {
        System.debug('accountId :::: ' + accountId);
        System.debug('mapOfUserAccount in batch :::: ' + mapOfUserAccount);
        System.debug('oppTeamRoleSet in batch :::: ' + oppTeamRoleSet);
        System.debug('mapOfUserAccount.keySet() ::: ' + mapOfUserAccount.keySet());
      
        this.accountIds = accountId;
        this.mapOfUserAccount = mapOfUserAccount; // Only user Ids
        this.oppTeamRoles = oppTeamRoleSet;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {

        String query = 'SELECT Id, AccountId FROM Opportunity WHERE AccountId IN :accountIds';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Opportunity> oppList) {
        List < OpportunityTeamMember > opportunityTeamMembersToAdd = new List < OpportunityTeamMember > ();
        for (Opportunity opp : oppList) {
            for (String userId : mapOfUserAccount.keySet()) {
                if(listContains(mapOfUserAccount.get(userId),opp.AccountId)){
                    OpportunityTeamMember newOTM = new OpportunityTeamMember();
                    newOTM.OpportunityId = opp.Id;
                    newOTM.UserId = userId;
                    newOTM.TeamMemberRole = this.oppTeamRoles.get(userId);
                    newOTM.OpportunityAccessLevel = 'Edit';
                    opportunityTeamMembersToAdd.add(newOTM);
                }
            }
        }

        if (!opportunityTeamMembersToAdd.isEmpty()) {
            Database.insert(opportunityTeamMembersToAdd, false);
        }
        //System.debug('opportunityTeamMembersToAdd ::::: ' + opportunityTeamMembersToAdd);
    }

    Boolean listContains(Object[] source, Object target) {
        return (new Set<Object>(source)).contains(target);
    }

    public void finish(Database.BatchableContext context) {
        // Optional: Add any post-processing logic here
    }
}