@IsTest
public class TransferProposalBatchTest {
    public static testmethod void testproposalbatch()
    {
        User thisUser=[Select ID,Name from User Where ID=:UserInfo.getUserId()];
        System.runAs (thisUser){
            //createAE user
			List<User> userList = new List<User>();
            User userAE=TestUtil.prepareUser();
            Profile objProfile=[Select Id,Name From Profile Where Name='Standard User'];
            userAE.ProfileId=objProfile.Id;
            userAE.HR_Manager__c=thisUser.ID;
            userAE.Username='testae@mands.com';
            userAE.Budget_Type__c='Local';
            userAE.Budget_Product_Lines__c='Linear/News/Sports';
            userAE.Firstname='Test';
            userAE.Lastname='User';
            userList.add( userAE);
            
            User userAE2=TestUtil.prepareUser();
            userAE2.ProfileId=objProfile.Id;
            userAE2.HR_Manager__c=thisUser.ID;
            userAE2.Username='testae2@mands.com';
            userAE2.Budget_Type__c='Local';
            userAE2.Budget_Product_Lines__c='Linear/News/Sports';
            userAE2.Firstname='Test';
            userAE2.Lastname='User2';
            userList.add( userAE2);
            
			insert userList;
            Account acc=TestUtil.getAccountRec();
            insert acc;
            
            Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
            att.Division__c = 'Central';
            att.Region__c = 'MidNorth';
            att.Status__c = 'Approved';
            att.Transfer_Effective_Date__c = Date.newInstance(2019, 01, 15);
            insert att;   
            
            
            
            Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
            atm.Account__c = acc.Id;
            atm.Account_Transfer_Simulation__c = att.Id;
            atm.From_User__c = userAE2.id;
            atm.To_User__c = userAE.Id;
            atm.External_ID__c = userAE2.id+';;;'+acc.Id+';;;'+'2019Jan'+';;;'+userAE.Id;
            insert atm;
            
            List<Admin_Tool_Status_Summary__c>adminToolSmry=new list<Admin_Tool_Status_Summary__c>();  
            Admin_Tool_Status_Summary__c obj=new Admin_Tool_Status_Summary__c();
            obj.From_User_Id__c=userAE2.id;
            obj.To_User_Id__c=userAE.Id;
            obj.Proposal_End_Date__c=String.valueOf(Date.today());
            obj.Job_Type__c='AE Transfer';
            obj.Transfer_Details__c=atm.id;
            adminToolSmry.add(obj);
            
            insert adminToolSmry;
            List<Opportunity> oppList = new List<Opportunity>();
            Opportunity opp1=new Opportunity();
            opp1.name='Test opp';
            opp1.OwnerId=userAE.Id;
            opp1.AccountId=acc.id;
            opp1.StageName='Closed Won';
            opp1.CloseDate=Date.newInstance(2019, 11, 18);
            oppList.add( opp1);

           
            
           Opportunity opp2=new Opportunity();
            opp2.name='Test opp1';
            opp2.OwnerId=userAE2.Id;
            opp2.AccountId=acc.id;
            opp2.StageName='Closed Won';
            opp2.CloseDate=Date.newInstance(2019, 11, 20);
            oppList.add( opp2);
            insert oppList;

			 List<Proposal__c> propList = new List<Proposal__c>();
            Proposal__c p2=new Proposal__c();
            p2.Name='Proposal';
            p2.Opportunity__c=opp1.id;
            p2.Active__c = false;
            p2.Start_Date__c = System.today();
            p2.End_Date__c = System.today().addMonths(1);
            p2.TIM_System__c='Orlando';
            p2.Current_Advertiser_Tim_Id__c='Current advertiser';
            p2.Current_Agency_Tim_Id__c='Current agency';
            propList.add( p2);

            Proposal__c p3=new Proposal__c();
            p3.Name='Proposal';
            p3.Opportunity__c=opp2.id;
            p3.Active__c = false;
            p3.Start_Date__c = System.today();
            p3.End_Date__c = System.today().addMonths(1);
            p3.TIM_System__c='Orlando';
            p3.Current_Advertiser_Tim_Id__c='Current advertiser';
            p3.Current_Agency_Tim_Id__c='Current agency';
            propList.add( p3);
            insert propList;
            /*
            //create Opportunity
            Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);
            opp.ownerid=userAE.Id;
            insert opp;
            
            
            //create Proposal
            Proposal__c p1 = TestDataHelper.createProposal('Test Opportunity Proposal',opp.id, '00000', true);
            p1.RecordTypeId = TestDataHelper.LinearRecTypeId;
            p1.Active__c = true;
            p1.Start_Date__c = System.today();
            p1.End_Date__c = System.today().addMonths(1);
            p1.TIM_System__c='Orlando';
            p1.Current_Advertiser_Tim_Id__c='Current advertiser';
            p1.Current_Agency_Tim_Id__c='Current agency';
            insert p1;
            
            */
            Admin_Tool_Status_Detail__c objAT = new Admin_Tool_Status_Detail__c();
            objAT.Admin_Tool_Status_Summary__c = obj.Id;
            objAT.Object_Type__c='Proposal';
            objAT.Status__c='Not Started';
            objAT.Id__c=p2.id;
            objAT.Error_Message__c='error';
            //objAT.Status__c='Success';
            insert objAT;
            
            Admin_Tool_Status_Detail__c objAT1 = new Admin_Tool_Status_Detail__c();
            objAT1.Admin_Tool_Status_Summary__c = obj.Id;
            objAT1.Object_Type__c='Proposal';
            objAT1.Status__c='Not Started';
            objAT1.Id__c=p2.id;
            objAT1.Error_Message__c='error';
            //objAT1.Status__c='Success';
            insert objAT1;
            /*
            Admin_Tool_Status_Detail__c objAT2 = new Admin_Tool_Status_Detail__c();
            objAT2.Admin_Tool_Status_Summary__c = obj.Id;
            objAT2.Object_Type__c='Proposal';
           objAT2.Status__c='Not Started';
            objAT2.Id__c=p3.id;
            objAT2.Error_Message__c='error';
            //objAT1.Status__c='Success';
            insert objAT2;
            */
            
            /*//create Opportunity
Opportunity opp1 = TestDataHelper.createopportunity('Test Opportunity1',System.today(),'Planning','Pipeline',acc.ID);
opp.ownerid=userAE.Id;
insert opp1;

//create Proposal
Proposal__c p2 = TestDataHelper.createProposal('Test Opportunity Proposal1',opp1.id, '00000', true);
p2.RecordTypeId = TestDataHelper.LinearRecTypeId;
p2.Active__c = true;
p2.Start_Date__c = System.today();
p2.End_Date__c = System.today().addMonths(1);
p2.TIM_System__c='West';
p2.Current_Advertiser_Tim_Id__c='Current advertiser';
p2.Current_Agency_Tim_Id__c='Current agency';
insert p2;*/
            
            
            
            
            
            //Create User Connection
            insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',userAE.id,'TIM','1');
            
            UserConnection__c u=new UserConnection__c();
            u.Username__c='SFDCUser1';
            u.TIM_System__c='Charlotte';
            u.User__c=userAE.id;
            u.External_System__c='TIM';
            u.AE_Id__c='2';
            insert u;
            
            String query = 'Select id,Id__c , Status__c,Error_Message__c, Admin_Tool_Status_Summary__r.Proposal_End_Date__c, Admin_Tool_Status_Summary__r.To_User_ID__c, Admin_Tool_Status_Summary__r.From_User_ID__c from Admin_Tool_Status_Detail__c where Object_Type__c = \'Proposal\' and Status__c=\'Not Started\' and Admin_Tool_Status_Summary__r.Id in: admToolSummaryIDs order by Tim_System__c';
            System.debug('adminToolSmry'+adminToolSmry+'....obj.id: '+obj.id);
            
            //updateProposalBatch updPrslBtch = new updateProposalBatch(query,adminSummary,timSysNames,mapOfPrpsl, mapOfBatchsizes);            
            //String query='select id ,Name,Tim_ID__c,TIM_System__c,Advertiser__r.Id,End_Date__c,Advertiser__r.TIM_Account_ID__c,Current_Advertiser_Tim_Id__c,Agency__r.TIM_Account_ID__c,Current_Agency_Tim_Id__c from Proposals__c';
            
            Map<string,integer>mapOfBcthsize=new map<string,integer>();
            mapOfBcthsize.put('Opportunity_Batch_Size',200);
            mapOfBcthsize.put('Account_Team_Batch_Size',200);
            mapOfBcthsize.put('Account_Connection_Batch_Size',200);
            mapOfBcthsize.put('Account_SAM_Mappings_Batch_Size',200);
            mapOfBcthsize.put('Revenue_Batch_Size',200);
            mapOfBcthsize.put('Budget_Batch_Size',200);
            mapOfBcthsize.put('NBUC_Batch_Size',200);
            
            Set<string>userset=new set<string>();
            userset.add(userAE.Id);
            userset.add(userAE2.id);
            
            System.debug('users'+userset);
            System.runAs (userAE){
                Test.StartTest();   
                TransferProposalBatch p=new TransferProposalBatch(query,adminToolSmry,mapOfBcthsize,userset);
                p.isRetry = true;
                Database.executeBatch(p);
                Test.stopTest();
            }
            
        }
    }
    
     public static testmethod void testproposalbatchelseifaeprop(){
        User thisUser=[Select ID,Name from User Where ID=:UserInfo.getUserId()];
        System.runAs (thisUser){
            //createAE user
            User userAE=TestUtil.prepareUser();
            Profile objProfile=[Select Id,Name From Profile Where Name='Standard User'];
            userAE.ProfileId=objProfile.Id;
            userAE.HR_Manager__c=thisUser.ID;
            userAE.Username='testae@mands.com';
            userAE.Budget_Type__c='Local';
            userAE.Budget_Product_Lines__c='Linear/News/Sports';
            userAE.Firstname='Test';
            userAE.Lastname='User';
            insert userAE;
            
            User userAE2=TestUtil.prepareUser();
            userAE2.ProfileId=objProfile.Id;
            userAE2.HR_Manager__c=thisUser.ID;
            userAE2.Username='testae2@mands.com';
            userAE2.Budget_Type__c='Local';
            userAE2.Budget_Product_Lines__c='Linear/News/Sports';
            userAE2.Firstname='Test';
            userAE2.Lastname='User2';
            insert userAE2;
            
            Account acc=TestUtil.getAccountRec();
            insert acc;
            
            Account_Transfer_Tool__c att = new Account_Transfer_Tool__c();
            att.Division__c = 'Central';
            att.Region__c = 'MidNorth';
            att.Status__c = 'Approved';
            att.Transfer_Effective_Date__c = Date.newInstance(2019, 01, 15);
            insert att;   
            
            
            
            Account_Transfer_Mapping__c atm = new Account_Transfer_Mapping__c();
            atm.Account__c = acc.Id;
            atm.Account_Transfer_Simulation__c = att.Id;
            atm.From_User__c = userAE2.id;
            atm.To_User__c = userAE.Id;
            atm.External_ID__c = userAE2.id+';;;'+acc.Id+';;;'+'2019Jan'+';;;'+userAE.Id;
            insert atm;
            
            List<Admin_Tool_Status_Summary__c>adminToolSmry=new list<Admin_Tool_Status_Summary__c>();  
            Admin_Tool_Status_Summary__c obj=new Admin_Tool_Status_Summary__c();
            obj.From_User_Id__c=userAE2.id;
            obj.To_User_Id__c=userAE.Id;
            obj.Proposal_End_Date__c=String.valueOf(Date.today());
            obj.Job_Type__c='AE Transfer';
            obj.Transfer_Details__c=atm.id;
            adminToolSmry.add(obj);
            
            insert adminToolSmry;
            
                       List<Opportunity> oppList = new List<Opportunity>();
            Opportunity opp1=new Opportunity();
            opp1.name='Test opp';
            opp1.OwnerId=userAE.Id;
            opp1.AccountId=acc.id;
            opp1.StageName='Closed Won';
            opp1.CloseDate=Date.newInstance(2019, 11, 18);
            oppList.add( opp1);

           
            
           Opportunity opp2=new Opportunity();
            opp2.name='Test opp1';
            opp2.OwnerId=userAE2.Id;
            opp2.AccountId=acc.id;
            opp2.StageName='Closed Won';
            opp2.CloseDate=Date.newInstance(2019, 11, 20);
            oppList.add( opp2);
            insert oppList;

			 List<Proposal__c> propList = new List<Proposal__c>();
            Proposal__c p2=new Proposal__c();
            p2.Name='Proposal';
            p2.Opportunity__c=opp1.id;
            p2.Active__c = true;
            p2.Start_Date__c = System.today();
            p2.End_Date__c = System.today().addMonths(1);
            p2.TIM_System__c='Charlotte';
            p2.Current_Advertiser_Tim_Id__c='Current advertiser';
            p2.Current_Agency_Tim_Id__c='Current agency';
            propList.add( p2);

            Proposal__c p3=new Proposal__c();
            p3.Name='Proposal';
            p3.Opportunity__c=opp2.id;
            p3.Active__c = true;
            p3.Start_Date__c = System.today();
            p3.End_Date__c = System.today().addMonths(1);
            p3.TIM_System__c='Charlotte';
            p3.Current_Advertiser_Tim_Id__c='Current advertiser';
            p3.Current_Agency_Tim_Id__c='Current agency';
            propList.add( p3);
            insert propList;
            
			/*
            
            //create Opportunity
            Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);
            opp.ownerid=userAE.Id;
            insert opp;
            
            
            //create Proposal
            Proposal__c p1 = TestDataHelper.createProposal('Test Opportunity Proposal',opp.id, '00000', true);
            p1.RecordTypeId = TestDataHelper.LinearRecTypeId;
            p1.Active__c = true;
            p1.Start_Date__c = System.today();
            p1.End_Date__c = System.today().addMonths(1);
            p1.TIM_System__c='Charlotte';
            p1.Current_Advertiser_Tim_Id__c='Current advertiser';
            p1.Current_Agency_Tim_Id__c='Current agency';
            insert p1;
            */
            
            Admin_Tool_Status_Detail__c objAT = new Admin_Tool_Status_Detail__c();
            objAT.Admin_Tool_Status_Summary__c = obj.Id;
            objAT.Object_Type__c='Proposal';
            objAT.Status__c='Not Started';
            objAT.Id__c=p2.id;
            objAT.Error_Message__c='error';
            //objAT.Status__c='Success';
            insert objAT;
            
            Admin_Tool_Status_Detail__c objAT1 = new Admin_Tool_Status_Detail__c();
            objAT1.Admin_Tool_Status_Summary__c = obj.Id;
            objAT1.Object_Type__c='Proposal';
            objAT1.Status__c='Not Started';
            objAT1.Id__c=p3.id;
            objAT1.Error_Message__c='error';
            //objAT1.Status__c='Success';
            insert objAT1;
            /*
            Admin_Tool_Status_Detail__c objAT2 = new Admin_Tool_Status_Detail__c();
            objAT2.Admin_Tool_Status_Summary__c = obj.Id;
            objAT2.Object_Type__c='Proposal';
           objAT2.Status__c='Not Started';
            objAT2.Id__c=p3.id;
            objAT2.Error_Message__c='error';
            //objAT1.Status__c='Success';
            insert objAT2;
            
            
            //create Opportunity
Opportunity opp1 = TestDataHelper.createopportunity('Test Opportunity1',System.today(),'Planning','Pipeline',acc.ID);
opp.ownerid=userAE.Id;
insert opp1;

//create Proposal
Proposal__c p2 = TestDataHelper.createProposal('Test Opportunity Proposal1',opp1.id, '00000', true);
p2.RecordTypeId = TestDataHelper.LinearRecTypeId;
p2.Active__c = true;
p2.Start_Date__c = System.today();
p2.End_Date__c = System.today().addMonths(1);
p2.TIM_System__c='West';
p2.Current_Advertiser_Tim_Id__c='Current advertiser';
p2.Current_Agency_Tim_Id__c='Current agency';
insert p2;*/
            
            
            
            
            
            //Create User Connection
            insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',userAE.id,'TIM','1');
            
            UserConnection__c u=new UserConnection__c();
            u.Username__c='SFDCUser1';
            u.TIM_System__c='Charlotte';
            u.User__c=userAE.id;
            u.External_System__c='TIM';
            u.AE_Id__c='2';
            insert u;
            
            String query = 'Select id,Id__c , Status__c,Error_Message__c, Admin_Tool_Status_Summary__r.Proposal_End_Date__c, Admin_Tool_Status_Summary__r.To_User_ID__c, Admin_Tool_Status_Summary__r.From_User_ID__c from Admin_Tool_Status_Detail__c where Object_Type__c = \'Proposal\' and Status__c=\'Not Started\' and Admin_Tool_Status_Summary__r.Id in: admToolSummaryIDs order by Tim_System__c';
            System.debug('adminToolSmry'+adminToolSmry+'....obj.id: '+obj.id);
            
            //updateProposalBatch updPrslBtch = new updateProposalBatch(query,adminSummary,timSysNames,mapOfPrpsl, mapOfBatchsizes);            
            //String query='select id ,Name,Tim_ID__c,TIM_System__c,Advertiser__r.Id,End_Date__c,Advertiser__r.TIM_Account_ID__c,Current_Advertiser_Tim_Id__c,Agency__r.TIM_Account_ID__c,Current_Agency_Tim_Id__c from Proposals__c';
            
            Map<string,integer>mapOfBcthsize=new map<string,integer>();
            mapOfBcthsize.put('Opportunity_Batch_Size',200);
            mapOfBcthsize.put('Account_Team_Batch_Size',200);
            mapOfBcthsize.put('Account_Connection_Batch_Size',200);
            mapOfBcthsize.put('Account_SAM_Mappings_Batch_Size',200);
            mapOfBcthsize.put('Revenue_Batch_Size',200);
            mapOfBcthsize.put('Budget_Batch_Size',200);
            mapOfBcthsize.put('NBUC_Batch_Size',200);
            
            Set<string>userset=new set<string>();
            userset.add(userAE.Id);
            userset.add(userAE2.id);
            
            System.debug('users'+userset);
            System.runAs (userAE){
                Test.StartTest();   
                TransferProposalBatch p=new TransferProposalBatch(query,adminToolSmry,mapOfBcthsize,userset);
 				p.isRetry = true;
                Database.executeBatch(p);
							//TransferProposalBatch trf = new TransferProposalBatch('',null,null,null);
			AccountTransferSchedule ats = new AccountTransferSchedule(p);
String sch = '20 30 8 10 2 ?';
String jobID = system.schedule('Merge Job', sch, ats);
                Test.stopTest();
            }
            
        }
    }
    
    
}