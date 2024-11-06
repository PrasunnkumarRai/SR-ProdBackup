@isTest
private class ConfirmSaveAcctsInTimTest 
{

    static testMethod void CTPTest() 
    {
        
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        
        System.runAs(u){
        
            TestDataHelper.createTIMIntegrationCustomSettings();
            INSERT TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
            
            //Create an account
            Account acc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
            INSERT acc;
            
            //Create an opportunity on the above created account
            Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.Id);        
            INSERT opp;

            List<Opportunity> opplist = new List<Opportunity>();
            opplist.add(opp);
       
            ApexPages.currentPage().getParameters().put('OppId', opp.Id);
            ApexPages.currentPage().getParameters().put('isCTP','true');

            System.assertEquals(true,ApexPages.currentPage().getParameters().get('OppId')!=null);

            ApexPages.StandardSetController controller = new ApexPages.StandardSetController(opplist);
            
            Test.StartTest();        
            ConfirmSaveAcctsInTim cp = new ConfirmSaveAcctsInTim();
            cp.propCont = controller; 
            cp.checkAccountConnections();
            Test.StopTest();
        }
    }


    static testMethod void ProposalSCXUploadTest() 
    {
        User u = TestDataHelper.createSystemAdminUser(true);
        System.runAs(u){
           //Create an account
            Account acc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
            INSERT acc;
            
            //Create an opportunity on the above created account
            Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.Id);        
            INSERT opp;

            ApexPages.currentPage().getParameters().put('OppId', opp.Id);
            ApexPages.currentPage().getParameters().put('isCTP','false');
            ApexPages.currentPage().getParameters().put('isPolitical','false');

            System.assertEquals(true,ApexPages.currentPage().getParameters().get('OppId')!=null);

            Test.StartTest();
            ConfirmSaveAcctsInTim cp = new ConfirmSaveAcctsInTim(); 
            cp.checkAccountConnections();
            Test.StopTest();            
        }
    }
}