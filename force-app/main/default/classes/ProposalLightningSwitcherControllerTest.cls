@isTest
private class ProposalLightningSwitcherControllerTest {
	static opportunity opp;
    static  proposal__c prop;
    
    static testMethod void redirectMethod() {
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
    	
		Account acc = TestDataHelper.createAcc('Test Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                        
        insert acc;
		System.debug('@@acc '+acc);
        
		System.runAs(u){
			opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
			insert opp;
			System.debug('@@opp '+opp);
		}
		
		ApexPages.currentPage().getParameters().put('Id',opp.Id);

		String id = ApexPages.currentPage().getParameters().get('Id');
        system.assertEquals(true,id!=null);

		ProposalLightningSwitcherController switchController = new ProposalLightningSwitcherController();
		switchController.redirect();


    }
}