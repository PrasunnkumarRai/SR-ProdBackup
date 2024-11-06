/*
* @Author               : M & S
* @Description          : Test Class for ItemsToApprove class
* @Date Of Creation     : 04-Sep-2017
* @Modified by          : 
* @Modified Date        : 15-Feb-2022
* @Modifiction History  : SRSF-3392 : Added Account Request, Trade pending Approvals 
*/
@isTest
public class ItemsToApproveTest {

    public static testMethod void AccountRequestToApprove() {

        User userAE = TestUtil.prepareUser();   
        userAE.Username = 'testae@mands.com';
        userAE.Email = 'testae@charter.com';
        userAE.Team_Role__c = 'Account Executive';
        userAE.Approving_Manager__c = UserInfo.getUserId();
            
        User userSalesManager = TestUtil.prepareUser();    
        userSalesManager.Username = 'testlsm@mands.com';
        userSalesManager.Email = 'testlsm@charter.com';
        userSalesManager.Team_Role__c = 'Sales Manager';
        userSalesManager.Approving_Manager__c = UserInfo.getUserId();
            
        INSERT new List<User>{userAE, userSalesManager};        
            
        Map<String, Id> mapRecordTypeId = new Map<String, Id>();
        for( RecordType accRT : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND ( DeveloperName='Agency_Account' OR DeveloperName='Advertiser_Account')]){
            mapRecordTypeId.put( accRT.DeveloperName, accRT.Id );
        }
            
        Account acc = new Account(Name='Test Ads Account', RecordTypeId=mapRecordTypeId.get('Advertiser_Account'), BillingStreet = '235 High St',
            BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
            BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
            ShippingPostalCode = '26505', ShippingCountry = 'USA', Legal_Entity_Name__c='Test Legal Name' );
            
        Account acc2 = new Account(Name='Test Agency Account', RecordTypeId=mapRecordTypeId.get('Agency_Account'), BillingStreet = '235 High St',
            BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
            BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
            ShippingPostalCode = '26505', ShippingCountry = 'USA' );
        
        INSERT new List<Account>{ acc, acc2 };
   
        Account_Request__c ar2;

        System.runAs( userSalesManager ){
            ar2 = new Account_Request__c();
            ar2.Advertiser_Agency_Rep_Firm__c = acc2.Id;
            ar2.RecordTypeId = AccountRequestUtils.teamMemberRequestRtId;
            ar2.Account_Executive__c = userAE.Id;
            INSERT ar2;
            System.debug('@@ar2 '+ar2);
        }

        Test.startTest();
            try{
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();// Create an approval request
                req1.setComments('Submitting request for approval.');
                req1.setNextApproverIds(new Id[] {Userinfo.getuserId()});
                req1.setObjectId(ar2.Id);            
                req1.setProcessDefinitionNameOrId('Acct_Request_Bad_debt_write_off_reques_4');
                req1.setSkipEntryCriteria(true);
                Approval.ProcessResult result = Approval.process(req1);
                
                System.assert(result.isSuccess());
        
                System.assertEquals('Pending', result.getInstanceStatus(), 
                                    'Instance Status'+result.getInstanceStatus());

                ItemsToApprove.getApprovalData();
                ItemstoApproveMobile.getApprovalData();
                LightningLookUpController.lookup('Name','User');// for user lookup
                LightningLookUpController.Result obj= new LightningLookUpController.Result('User',UserInfo.getUserId());
                ItemsToApprove.UpdateStatus('Rejected',ar2.Id,'Reject',UserInfo.getUserId()); // when rejected the Approval request 
                ItemsToApprove.UpdateStatus('Reassigned',ar2.Id,'Reassigned ',UserInfo.getUserId());               
                ItemsToApprove.ApprovalHistoryWrap aHW = new ItemsToApprove.ApprovalHistoryWrap(Date.today(), 'name', 'TargetObjId', 'actor','targetObjName','actorId','sObjName','RecType', 'sObjLabel', 'accId', 'accName','AcctExecutiveId','AcctExecutive','Status',1,'Department','Reason' );
               ItemstoApproveMobile.UpdateStatus('Rejected',ar2.Id,'Reject',UserInfo.getUserId()); // when rejected the Approval request 
                ItemstoApproveMobile.UpdateStatus('Reassigned',ar2.Id,'Reassigned ',UserInfo.getUserId());               
             ItemstoApproveMobile.getObjectData();
                //   ItemstoApproveMobile.ApprovalHistoryWrap aHWs = new ItemsToApprove.ApprovalHistoryWrap(Date.today(), 'name', 'TargetObjId', 'actor','targetObjName','actorId','sObjName','RecType', 'sObjLabel', 'accId', 'accName','AcctExecutiveId','AcctExecutive','Status' );
                Test.stopTest();
        }
        catch(Exception ex){}       
    }
    
    public static testMethod void TradeRecordToApprove() 
    {
        User userObj;
        Map<String, Id> mapRecordTypeId = new Map<String, Id>();
        for( RecordType accRT : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND ( DeveloperName='Agency_Account' OR DeveloperName='Advertiser_Account')]){
            mapRecordTypeId.put( accRT.DeveloperName, accRT.Id );
        }

        Account acc = TestDataHelper.createAcc('Test Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India'); 

        Account agencyRec = TestDataHelper.createAgency('Test Account','123 Wright Plaza','Omaha','NE','68130','USA'); 
            
        INSERT new List<Account>{ acc, agencyRec };

        Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.Id);        
        INSERT opp;

        Proposal__c prop = TestDataHelper.createProposal('Test Proposal',opp.Id,'76877',True);
        prop.Advertiser__c = acc.Id;   
        prop.Active__c = false;
        prop.ProposalExternalId__c='';
        prop.TIM_Status__c = 'Proposal';  
        prop.AE_ID__c = '309';        
        prop.Agency__c = agencyRec.Id;

        Proposal__c prop_trade = TestDataHelper.createProposal('Test Trade Proposal',opp.Id,'76877',True);
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Trade'];
        prop_trade.RecordTypeId = rt.Id; 
        prop_trade.Advertiser__c = acc.Id;   
        prop_trade.Active__c = false;
        prop_trade.ProposalExternalId__c='';
        prop_trade.TIM_Status__c = 'Proposal';  
        prop_trade.AE_ID__c = '309';        
        prop_trade.Agency__c = agencyRec.Id;

        INSERT new List<Proposal__c>{ prop, prop_trade}; 

        Trade__c trade = TestDataHelper.createTrade('Test Trade1',opp.Id, prop.Id); 
        trade.Account__c = acc.Id;             
        trade.Status__c = 'Draft';
        trade.Trade_Receipt_Value__c = 12000.00;  
        trade.Trade_Proposal__c = prop_trade.Id;
        INSERT trade;

        Trade_proposal__c tradeproposal = new Trade_proposal__c();
        tradeproposal.Proposal__c = prop_trade.Id;
        tradeproposal.Trade__c = trade.Id;            
        tradeproposal.Trade_Proposal_Account__c = trade.Account__c;
        tradeproposal.Type_of_Proposal__c = 'Trade';            

        Trade_proposal__c paidproposal = new Trade_proposal__c();
        paidproposal.Trade__c = trade.Id;            
        paidproposal.Trade_Proposal_Account__c = trade.Account__c;
        paidproposal.Type_of_Proposal__c = 'Paid';
        
        INSERT new List<Trade_proposal__c>{ tradeproposal, paidproposal};

        trade.Trade_Justification__c = 'Test';
        trade.Annual_Cash_Spend__c = 25000.00;
        trade.Status__c = 'New';
        UPDATE trade;

        User usr = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(usr) {
            userObj = TestUtil.prepareUser();
            userObj.Email='testae@charter.com';
            userObj.Approving_Manager__c = UserInfo.getUserId();    
            INSERT new List<User>{ userObj};
        }

        Test.startTest();           

            try{                
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval.');
                req1.setNextApproverIds(new Id[] {Userinfo.getuserId()});
                req1.setObjectId(trade.Id);                
                req1.setSubmitterId(userObj.Id);  // Submit on behalf of a specific submitter           
                req1.setProcessDefinitionNameOrId('Trades_10000_Approval_Process_v8');
                req1.setSkipEntryCriteria(true);
                Approval.ProcessResult result = Approval.process(req1);

                System.assert(result.isSuccess());        
                System.assertEquals('Pending', result.getInstanceStatus(), 
                                    'Instance Status'+result.getInstanceStatus());

                ItemsToApprove.getApprovalData();
                ItemstoApproveMobile.getApprovalData();
                LightningLookUpController.lookup('Name','User');// for user lookup
                LightningLookUpController.Result obj= new LightningLookUpController.Result('User',UserInfo.getUserId());
                ItemsToApprove.UpdateStatus('Approved',trade.Id,'Approve',UserInfo.getUserId()); // when Approved the Approval request 
                ItemsToApprove.UpdateStatus('Reassigned',trade.Id,'Reassigned ',UserInfo.getUserId());
                ItemsToApprove.ApprovalHistoryWrap aHW = new ItemsToApprove.ApprovalHistoryWrap(Date.today(), 'name', 'TargetObjId', 'actor','targetObjName','actorId','sObjName','RecType', 'sObjLabel', 'accId', 'accName','AcctExecutiveId','AcctExecutive','Status',1,'Department','Reason' );
               ItemstoApproveMobile.UpdateStatus('Approved',trade.Id,'Approve',UserInfo.getUserId());
                ItemstoApproveMobile.UpdateStatus('Reassigned',trade.Id,'Reassigned ',UserInfo.getUserId());
               // ItemstoApproveMobile.ApprovalHistoryWrap aHWs = new ItemsToApprove.ApprovalHistoryWrap(Date.today(), 'name', 'TargetObjId', 'actor','targetObjName','actorId','sObjName','RecType', 'sObjLabel', 'accId', 'accName','AcctExecutiveId','AcctExecutive','Status' );
                Test.stopTest();
            }
            catch(Exception ex){}            
    }

    public static testMethod void AcctTransferRecordToApprove() 
    {
        User userObj;
        Account_Transfer_Tool__c attApproval = new Account_Transfer_Tool__c();
        attApproval.Division__c = 'Central';
        attApproval.Region__c = 'MidNorth';
        attApproval.Status__c = 'New';       
        attApproval.Transfer_Effective_Date__c = Date.newInstance(2020, 01, 15);
        
        INSERT attApproval;

        User usr = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(usr) {
            userObj = TestUtil.prepareUser();
            userObj.Email='testae@charter.com';
            userObj.Approving_Manager__c = UserInfo.getUserId();    
            INSERT new List<User>{ userObj};
        }

        Test.startTest();           

        try{                
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setNextApproverIds(new Id[] {Userinfo.getuserId()});
            req1.setObjectId(attApproval.Id);                
            req1.setSubmitterId(userObj.Id);  // Submit on behalf of a specific submitter           
            req1.setProcessDefinitionNameOrId('Account_Transfer_Approval_Local_V5');
            req1.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req1);

            System.assert(result.isSuccess());        
            System.assertEquals('Pending', result.getInstanceStatus(), 
                                'Instance Status'+result.getInstanceStatus());

            ItemsToApprove.getApprovalData();               
        ItemstoApproveMobile.getApprovalData();
            Test.stopTest();
        }
        catch(Exception ex){}
    }

    // Created for SRSF-3844
    public static testMethod void AcctSAMMappingRecordToApprove() 
    {
        User userObj;
        User lsmUsr = TestDataHelper.createLSMUser(true);

        User usr = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Account acc = TestDataHelper.createAcc('Test Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India'); 
        INSERT acc;
        AccountTeamMember atm = TestUtil.getAccountTeamMemRec(acc.Id,usr.Id);
        INSERT atm;
        Account_SAM_Mapping__c asmApproval = new Account_SAM_Mapping__c();
        asmApproval.User__c = usr.Id;
        asmApproval.Account__c = acc.Id;
        asmApproval.Tier_Designation__c = 'Priority';
        asmApproval.Division__c = 'East';
        asmApproval.Region__c = 'MidNorth';
            
        INSERT asmApproval;
        
        System.runAs(usr) {
            userObj = TestUtil.prepareUser();
            userObj.Email='testae@charter.com';
            userObj.Approving_Manager__c = lsmUsr.Id;    
            INSERT new List<User>{ userObj};
        }

        Test.startTest();           

        try{
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.'); 
            req1.setObjectId(asmApproval.Id);                
            req1.setSubmitterId(userObj.Id);  // Submit on behalf of a specific submitter           
            req1.setProcessDefinitionNameOrId('ASM_Target_Conversion_Approval_Process');
            req1.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req1);

            System.assert(result.isSuccess());        
            System.assertEquals('Pending', result.getInstanceStatus(), 
                                'Instance Status'+result.getInstanceStatus());
            System.runAs(lsmUsr) {
                ItemsToApprove.getApprovalData();  
                ItemstoApproveMobile.getApprovalData();
            }
            Test.stopTest();
        }
        catch(Exception ex){}
    }
}