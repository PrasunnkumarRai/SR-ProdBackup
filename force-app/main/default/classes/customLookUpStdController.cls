public class customLookUpStdController {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String recordId, String ObjectName, String searchKeyWord) {
        system.debug('ObjectName-->' + ObjectName);
        system.debug('recordId-->' + recordId);
        system.debug('searchKeyWord-->' + searchKeyWord);
       // system.debug('advertiserID-->' + advertiserID);
        
        String searchKey = searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();
      	
        //String oppSQuesry = 'select Account__r.Id from Opportunity where Id =: recordId';
        Opportunity opp =[select Account.id from Opportunity where Id =: recordId];
        String AccId = opp.AccountId;
        System.debug('AccId' +AccId);
        //Database.query(oppSQuesry);
               
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select id, Name, Account__r.Id, Opportunity__r.Id, Account__r.Name  from ' +ObjectName + ' where Opportunity__r.Id =: recordId OR Account__r.Id =: AccId OR Account__r.Name like: searchKey OR Name LIKE: searchKey  order by createdDate DESC limit 5';
        System.debug('sQuery' + sQuery);
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    
}