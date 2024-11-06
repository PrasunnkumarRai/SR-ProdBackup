/*
	Author      : Madhusudhan
	Date        : 6th Nov- 2018
	Description : test class to cover DynamicHelpLinkController related classes
    Modification History : 
*/
@isTest
public class DynamicHelpLinkController_Test {
    
    @IsTest
	static void accountBillingPositivePathTest() {
        Helpful_Link__c obj = new Helpful_Link__c();
        obj.Name='AE';
        obj.URL_Value__c = 'https://www.google.com/';
        obj.Visible_To__c = 'AE';
        insert obj;
        DynamicHelpLinkController.getLinks(obj.Visible_To__c);
    }
}