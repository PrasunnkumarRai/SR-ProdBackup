/*
	Author      : Madhusudhan
	Date        : 6th Nov- 2018
	Description : Adding URLs dynamically(Lightning Controller of HelpfulLinkToAE.cmp)
	Modification History :
*/
public class DynamicHelpLinkController {
	
    //Fetching the URL information in the pageload
    @auraEnabled
    public static list<Helpful_Link__c> getLinks( String strVisible){
        return [select id,Name, URL_Value__c,Visible_To__c from Helpful_Link__c where Visible_To__c='All' OR Visible_To__c=:strVisible order by Order_Of_Links__c limit 50000];
    }
}