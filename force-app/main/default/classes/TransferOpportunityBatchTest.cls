@IsTest
public class TransferOpportunityBatchTest {
    public static testmethod void testopportunity()
    {
        
        Account acc = TestUtil.getAccountRec();
        acc.primary_commodity__c =   'Auto Aftermarket';
        insert acc;
        
        User userAE = TestUtil.prepareUser();
        Profile objProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Master - Account Executive'];
        userAE.ProfileId = objProfile.Id;
        userAE.Username = 'testae@mands.com';
        userAE.Budget_type__c = 'Local';
        userAE.Budget_product_Lines__c = 'Linear/News/Sports;';
        userAE.rate_plan_status__c = 'Draft';
        userAE.Rate_Plan_Commit_Date__c =Date.newInstance(2019, 01, 10);
        userAE.Region__c='Texas';
        // userAE.HR_Name__c='ans';
        insert userAE;
        
        Profile pro2 = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        
        User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing 001', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = pro2.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser12424@testorg.com');
        
        Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
        att.Division__c = 'Central';
        att.Region__c = 'MidNorth';
        att.Status__c = 'Approved';
        att.Transfer_Effective_Date__c = Date.newInstance(2018, 01, 15);
        insert att;
        
        Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
        atm.Account__c = acc.Id;
        atm.Account_Transfer_Simulation__c = att.Id;
        atm.From_User__c = u2.id;
        atm.To_User__c = userAE.id;
        atm.External_ID__c = userAE.id+';;;'+acc.Id+';;;'+'2018Jan'+';;;'+userAE.id;
        insert atm;
        
        List<Admin_Tool_Status_Summary__c>adminToolSmry=new list<Admin_Tool_Status_Summary__c>();
        
        
        Admin_Tool_Status_Summary__c obj = new Admin_Tool_Status_Summary__c();
        obj.From_User_Id__c =u2.id;
        obj.To_User_Id__c = userAE.id;
        obj.Proposal_End_Date__c = String.valueOf(Date.today());
        obj.Job_Type__c = 'AE Transfer';
        obj.Transfer_Details__c = atm.Id; 
        insert obj;
        
        adminToolSmry.add(obj);
        //insert adminToolSmry;
        AccountConnection__c accConn = TestDataHelper.createAccountConnection(acc.Id);
        accConn.Tim_System__c = 'St. Louis Local';
        insert accConn; 
        

        
        List<Admin_Tool_Status_Detail__c> adminToolDetailsAccConn = new List<Admin_Tool_Status_Detail__c>();

        
        Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);
        // opp.ownerid=u2.id;
        insert opp;
        
        Proposal__c p = TestDataHelper.createProposal('Test Opportunity Proposal',opp.id, '00000', true);
        p.RecordTypeId = TestDataHelper.LinearRecTypeId;
        p.Start_Date__c = System.today();
        p.End_Date__c = System.today().addMonths(1);
        insert p;
        Admin_Tool_Status_Detail__c objAT = new Admin_Tool_Status_Detail__c();
        objAT.Admin_Tool_Status_Summary__c = obj.Id;
        objAT.Object_Type__c='Opportunity';
        objAT.Status__c='Not Started';
        objAT.AccountConnection__c=accConn.id;
        objAT.Id__c=opp.Id;
        //objAT.Error_Message__c='error';
        //objAT.Status__c='Success';
        
        insert objAT;
                adminToolDetailsAccConn.add(objAT);
        Map<String,Integer>mapOfBcthsize=new Map<String,Integer>();
        mapOfBcthsize.put('Account_Team_Batch_Size',200);
        mapOfBcthsize.put('Account_Connection_Batch_Size',200);
        mapOfBcthsize.put('Account_SAM_Mappings_Batch_Size',200);
        mapOfBcthsize.put('Revenue_Batch_Size',200);
        mapOfBcthsize.put('Budget_Batch_Size',200);
        mapOfBcthsize.put('NBUC_Batch_Size',200);
        
        String query = 'Select id,Id__c , Status__c,Error_Message__c, Admin_Tool_Status_Summary__r.To_User_ID__c,AccountConnection__c, Admin_Tool_Status_Summary__r.From_User_ID__c from Admin_Tool_Status_Detail__c where Object_Type__c = \'Opportunity\' and Status__c=\'Not Started\' and Admin_Tool_Status_Summary__r.Id in: admToolSummaryIDs';        
        try{
        System.RunAs(userAE)
        {
            Test.startTest();
            TransferOpportunityBatch ob=new TransferOpportunityBatch(query,adminToolSmry,mapOfBcthsize);
            ob.IsRetry=false;
            Database.executeBatch(ob);
            Test.stopTest();            
            
        }
        }catch(Exception ex){}
        }
    
    
    
}