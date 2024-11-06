public class findDuplicateAccountsController {
    Static List<Datacloud.MatchRecord> duplicateAccounts = new List<Datacloud.MatchRecord>();
    public static List<Datacloud.MatchRecord> finDuplicateAccounts(List<sObject> sobjList){
		system.debug('sobjList:: '+sobjList);        
        Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(sobjList);
        for (Datacloud.FindDuplicatesResult findDupeResult : results) {
          for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
            for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                duplicateAccounts.addAll(matchResult.getMatchRecords());
            }
          }
        }
        return duplicateAccounts;
    }
}