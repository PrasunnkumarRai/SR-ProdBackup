/*
    Author : MAndS 
    Date   : Apr 04-2018
    Description : Lightning component Apex controller to search a specified SObject for a specific string
    Modification History : 
*/
public class CM_DCLookupCntrl {
	
    /**
     * Aura enabled method to Provide Tooltip Information
    */
    /*@AuraEnabled
    public static string getTooltipInfo(){
        return 'You may only clone Creatives from Campaigns that meet the following criteria: <br />1. Of related products (Video to Video, Display to Display) <br />2. Related to the same Advertiser. <br />3. Status not in 39 Cancelled, 99 Campaign Completed, 98 Cancellation Complete, 00 Rejected.';
    }*/
    
    /**
     * Aura enabled method to search a specified SObject for a specific string
     */
    @AuraEnabled
    public static Digital_Campaign__c[] lookup(String searchString, String sObjectAPIName, String strFromDCId, String accId)
    {
        // Sanitze the input
        String sanitizedSearchString = String.escapeSingleQuotes(searchString);
        String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);
		// Build our SOQL query
        String searchQ = 'SELECT Id,Name,Campaign_Name__c,Advertiser__c,Advertiser__r.Name,Status__c,RecordType.Name from '+sObjectAPIName +' where Advertiser__c=\''+accId+'\' and (Campaign_Name__c LIKE \'%'+searchString+'%\' OR Name LIKE \'%'+searchString+'%\')';//Id!=\''+strFromDCId+'\' and
        // Execute the Query
        List<Digital_Campaign__c> dcList = Database.query(searchQ);
        System.debug('dcList-->'+dcList);
        return dcList;
    }       
}