@isTest
private class ProposalActiveInactiveControllerTest 
{
    static Account acc;
    public static Opportunity opp;
    static Proposal__c prop;    
    static ProposalActiveInactiveController obj;
    static List<Proposal__c> propList;
    static String proposalId;
    public static Id linearRecTypeId;
    public static Id tradeRecTypeId;
    public static Id politicalRecTypeId;
    public static Id inventoryRecTypeId;
    public static Id advancedProposalRecTypeId;
    public static Map<String,Id> recordSobjectMap;
     
    static testMethod void prepareTestData() { 
    
        TestDataHelper.createTIMIntegrationCustomSettings();
        
        User u = [SELECT Id, Name FROM User WHERE Name = 'Boomi Integration User' AND Id =: Label.BoomiUserId];
        linearRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Linear' AND SobjectType = 'Proposal__c'].Id;
        tradeRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Trade' AND SobjectType = 'Proposal__c'].Id;
        inventoryRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Inventory' AND SobjectType = 'Proposal__c'].Id;
        politicalRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Political' AND SobjectType = 'Proposal__c'].Id;
        advancedProposalRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Advanced_Proposal' AND SobjectType = 'Proposal__c'].Id;
        UserConnection__c userConn = TestDataHelper.createUserConnection(null, null, u.Id, null, null);
        System.runAs(u){
            //insert userConn;
            acc = TestDataHelper.createAcc('Test Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');
            acc.Political_Account__c = true;                        
            INSERT acc;
            
            opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.Id);        
            INSERT opp; 

            Proposal__c prop1 = TestDataHelper.createProposal('InActive Proposal',opp.Id,'76877',false);
            prop1.TIM_System__c = 'St. Louis Local';               
            INSERT prop1;
            proposalId = prop1.Id;

            Proposal__c prop2 = TestDataHelper.createProposal('Active Proposal',opp.Id,'76887',true);
            prop2.TIM_System__c = 'St. Louis Local';               
            INSERT prop2;

            Proposal__c prop3 = TestDataHelper.createProposal('Active Advanced Proposal',opp.Id,'',true);
            prop3.RecordTypeId = advancedProposalRecTypeId; 
            prop3.AOS_Deal_Id__c = '6000239';
            prop3.AOS_Deal_Status__c = 'Draft Plan';              
            INSERT prop3;

            propList =[SELECT Id, Opportunity__c FROM Proposal__c WHERE Opportunity__c = :opp.Id];  
            System.assertEquals(3, propList.size());  
        }
        UserConnection__c connection = TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');   
            //insert connection;

        List<UserConnection__c> userConnectionList = new List<UserConnection__c>();

        userConnectionList.add(userConn);
        userConnectionList.add(connection);
        insert userConnectionList;

        System.assert(userConnectionList != null);
    }


    static testMethod void testPoliticalProposals() 
    {
        prepareTestData();
        recordSobjectMap = new Map<String,Id>();
        List<RecordType> recordTypes =[SELECT Id, SObjectType FROM RecordType WHERE DeveloperName='Political'];
        for(RecordType recType : recordTypes) {
            if(recType.SobjectType.contains('Opportunity')){
                recordSobjectMap.put('Opportunity',recType.Id);
            }
            if(recType.SobjectType.contains('Account')){
                recordSobjectMap.put('Account',recType.Id);
            }
            if(recType.SobjectType.contains('Proposal__C')){
                recordSobjectMap.put('Proposal__c',recType.Id);
            }
        }
        System.debug(' @@@@ acc ::: ' +acc);
        acc.RecordTypeId = recordSobjectMap.get('Account');
        UPDATE acc;
        opp.RecordTypeId = recordSobjectMap.get('Opportunity');
        UPDATE opp;  

        System.assert(opp != null);  
    }


    static testMethod void proposalActiveInactiveCtrlTest_ActiveCheck() {
        
        prepareTestData();
        Test.startTest();
        Proposal__c prop = [SELECT Id, Name, Active__c, RecordType.DeveloperName, RecordTypeId FROM Proposal__c WHERE Name = 'InActive Proposal'];        
        prop.Active__c=true;
        prop.RecordTypeId = linearRecTypeId;
        UPDATE prop;
        proposalId = prop.Id;
        List<Proposal__c> propList1= new List<Proposal__c>();

        PageReference proposalPage = Page.ProposalActiveInactive;
        Test.setCurrentPage(proposalPage);

        ApexPages.currentPage().getParameters().put('Id',opp.Id);

        String oppId = ApexPages.currentPage().getParameters().get('Id');
        System.assertEquals(true,oppId!=null);

        ApexPages.StandardSetController sc1 = new ApexPages.StandardSetController(propList1);
        sc1.setSelected(propList1);
        obj = new ProposalActiveInactiveController(sc1);
        propList =[SELECT Id, Name, RecordType.Name, RecordType.DeveloperName, Active__c, TIM_System__c FROM Proposal__c WHERE Id = :prop.Id];
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(propList);
        sc.setSelected(propList);

        obj = new ProposalActiveInactiveController(sc);
        obj.getheaderRecTypeLst();
        
        obj.proposalRecordId = proposalId;
        obj.getrecordTypeLst();
        
        obj.selectedActiveInactiveChck = proposalId;
        ProposalActiveInactiveController.ProposaldisplayWrapper  propDisWrap = new ProposalActiveInactiveController.ProposaldisplayWrapper();
        propDisWrap.propObj = propList[0];
        propDisWrap.isSelected = true;
        propDisWrap.isActive = false;
        propDisWrap.isActivechanged = true;
        obj.isSelectAll = true;
        propDisWrap.showPicklist = true;
        obj.populateUpdateStatus(propDisWrap, NULL);
        obj.selectedAllRecordType = Label.Trade_RT;
        propDisWrap.selectedrecordType = Label.Inventory_RT;
        obj.selectedProposalId = proposalId;
       
        obj.fetchRecordTypeList();
        obj.setSelectAll();
        obj.singleSelection();
        obj.checkActiveInactive();
        obj.isSelectAllActiveDeactive = false;
        obj.setSelectActiveDeactive();
        obj.setRecordTypeName();
        obj.setForAllRecordTypeName();
        obj.updateProposals();        
        
        obj.GoBackToOpportunity();
        Test.stopTest();       
    }


    static testMethod void proposalActiveInactiveCtrlTest_InactiveCheck() {
        
        prepareTestData();
        Test.startTest();        
        Proposal__c proposal = [SELECT Id, Active__c, RecordTypeId FROM Proposal__c LIMIT 1];

        proposal.Active__c=false;
        proposal.RecordTypeId = tradeRecTypeId;
        UPDATE proposal;

        propList =[SELECT Id, RecordType.Name, Active__c FROM Proposal__c LIMIT 1];

        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(propList);
        sc.setSelected(propList);

        ApexPages.currentPage().getParameters().put('Id',opp.Id);

        String oppId = ApexPages.currentPage().getParameters().get('Id');
        System.assertEquals(true,oppId!=null);

        obj = new ProposalActiveInactiveController(sc);
        obj.getheaderRecTypeLst();
       
        obj.proposalRecordId = proposal.Id;
        obj.getrecordTypeLst();
        obj.selectedActiveInactiveChck = proposal.Id;
        ProposalActiveInactiveController.ProposaldisplayWrapper  propDisWrap = new ProposalActiveInactiveController.ProposaldisplayWrapper();
        propDisWrap.propObj = propList[0];
        propDisWrap.isActive = true;
        obj.isSelectAll = true;
        propDisWrap.isActivechanged = true;
        propDisWrap.showPicklist = false;
        
        obj.fetchRecordTypeList();
        obj.setForAllRecordTypeName();
        propDisWrap.isSelected = true;
        obj.singleSelection();
        obj.selectedAllRecordType = Label.Trade_RT;
        propDisWrap.selectedrecordType = Label.Inventory_RT;
        obj.selectedProposalId = proposalId;
    
        obj.setSelectAll();
        obj.checkActiveInactive();
        obj.isSelectAllActiveDeactive = true;
        obj.setSelectActiveDeactive();
        
        obj.setRecordTypeName();
        obj.updateProposals();    
        obj.GoBackToOpportunity();
        Test.stopTest();      
    }


    static testMethod void proposalActiveInactiveCtrlTest_politicalCheck() {
        
        testPoliticalProposals(); 
        Test.startTest(); 
        Proposal__c prop = [SELECT Id, Name, Active__c, RecordTypeId FROM Proposal__c WHERE Name = 'InActive Proposal']; 
        prop.RecordTypeId = recordSobjectMap.get('Proposal__c');      
        prop.Active__c=true;
       
        UPDATE prop;
        proposalId = prop.Id;

        propList =[SELECT Id ,RecordType.Name , Active__c FROM Proposal__c WHERE Id = :prop.Id];

        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(propList);
        sc.setSelected(propList);
        System.debug('propList'+propList);

        ApexPages.currentPage().getParameters().put('Id',opp.Id);

        String oppId = ApexPages.currentPage().getParameters().get('Id');
        System.assertEquals(true,oppId!=null);

        obj = new ProposalActiveInactiveController(sc);
        obj.oppRecordType = true;
        obj.getheaderRecTypeLst();
        
        obj.proposalRecordId = proposalId;
        obj.getrecordTypeLst();
        obj.selectedActiveInactiveChck = proposalId;
        ProposalActiveInactiveController.ProposaldisplayWrapper  propDisWrap = new ProposalActiveInactiveController.ProposaldisplayWrapper();
        propDisWrap.isSelected = true;        
        
        obj.fetchRecordTypeList();
        obj.selectedAllRecordType = Label.Political_RT;
        propDisWrap.selectedrecordType = Label.Inventory_RT;
        obj.selectedProposalId = proposalId;
       
        obj.setForAllRecordTypeName();
        propDisWrap.selectedrecordType = Label.Inventory_RT;
        obj.setRecordTypeName();
        obj.updateProposals();
        
        
        obj.GoBackToOpportunity();
        Test.stopTest();        
    }


    static testMethod void proposalActiveInactiveCtrlTest_notseletedCheck() {
        
        prepareTestData();    
        Test.startTest();    
        Proposal__c prop = [SELECT Id, Name, Active__c, RecordTypeId FROM Proposal__c WHERE Name = 'InActive Proposal']; 
        prop.Active__c=false;
        prop.RecordTypeId = inventoryRecTypeId;
        UPDATE prop;
        proposalId = prop.Id;

        propList =[SELECT Id, RecordType.Name, RecordType.DeveloperName, Active__c FROM Proposal__c WHERE Id = :prop.Id];

        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(propList);
        sc.setSelected(propList);

        ApexPages.currentPage().getParameters().put('Id',opp.Id);

        String oppId = ApexPages.currentPage().getParameters().get('Id');
        System.assertEquals(true,oppId!=null);

        obj = new ProposalActiveInactiveController(sc);
        obj.getheaderRecTypeLst();
       
        obj.proposalRecordId = proposalId;
        obj.getrecordTypeLst();
        obj.selectedActiveInactiveChck = proposalId;
        ProposalActiveInactiveController.ProposaldisplayWrapper  propDisWrap = new ProposalActiveInactiveController.ProposaldisplayWrapper();
        propDisWrap.isSelected = false;
        
        obj.isSelectAll = false;
        
        obj.fetchRecordTypeList();
        obj.selectedAllRecordType = Label.Trade_RT;
        propDisWrap.selectedrecordType = Label.Inventory_RT;
        obj.selectedProposalId = proposalId;
        propDisWrap.isActive = true;
        propDisWrap.isSelected = false;
        
        obj.setSelectAll();
        obj.singleSelection();
        obj.checkActiveInactive();
        obj.isSelectAllActiveDeactive = true;
        obj.setSelectActiveDeactive();
        obj.setForAllRecordTypeName();
        obj.setRecordTypeName();
        obj.updateProposals();
        
        obj.GoBackToOpportunity(); 
        Test.stopTest();       
    }

    static testMethod void proposalActiveInactiveCtrlTest_poltical() {
        
        prepareTestData();        
        Test.startTest();
        Proposal__c prop = [SELECT Id, Name, Active__c, RecordTypeId FROM Proposal__c WHERE Name = 'InActive Proposal']; 
        prop.RecordTypeId = politicalRecTypeId;
        UPDATE prop;
        proposalId = prop.Id;

        propList =[SELECT Id ,RecordType.Name , Active__c FROM Proposal__c WHERE Id = :prop.Id];

        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(propList);
        sc.setSelected(propList);

        ApexPages.currentPage().getParameters().put('Id',opp.Id);

        String oppId = ApexPages.currentPage().getParameters().get('Id');
        System.assertEquals(true,oppId!=null);

        obj = new ProposalActiveInactiveController(sc);
        obj.getheaderRecTypeLst();
       
        UserConnection__c loggedInUser = [SELECT AE_Id__c, TIM_System__c, Username__c
                            FROM UserConnection__c
                            WHERE User__c=: UserInfo.getUserId() AND TIM_System__c ='St. Louis Local' LIMIT 1];
            
        String timSystem = 'StLouisLocal';
        String partitionName = 'local.TIMAccess';
        Cache.OrgPartition newpart = new Cache.OrgPartition(partitionName);

        Map<String,TIMUserAccess.User> timuserMap = new Map<String,TIMUserAccess.User>();

        timuserMap.put('St. Louis Local', CacheManager.getTIMUser(loggedInUser.Username__c+timSystem,timSystem));

        newpart.put('StLouisLocal', timuserMap);
        
        obj.proposalRecordId = proposalId;
        obj.getrecordTypeLst();
        obj.selectedActiveInactiveChck = proposalId;
        ProposalActiveInactiveController.ProposaldisplayWrapper  propDisWrap = new ProposalActiveInactiveController.ProposaldisplayWrapper();
        propDisWrap.isSelected = false;
        
        obj.isSelectAll = false;
        
        obj.fetchRecordTypeList();
        obj.selectedAllRecordType = Label.Trade_RT;
        propDisWrap.selectedrecordType = Label.Inventory_RT;
        obj.selectedProposalId = proposalId;
        propDisWrap.isActive = false;
        propDisWrap.isSelected = false;
       
        obj.setSelectAll();
        obj.singleSelection();
        obj.checkActiveInactive();
        obj.isSelectAllActiveDeactive = true;
        obj.setSelectActiveDeactive();
        obj.setForAllRecordTypeName();
        obj.setRecordTypeName();
        obj.updateProposals();
        
        obj.GoBackToOpportunity();
        Test.stopTest();       
    }

    
    static testMethod void proposalActiveInactiveCtrlTest_TradeCheck() {
        
        testPoliticalProposals(); 
        Test.startTest(); 
        RecordType recType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Proposal__c' AND DeveloperName = 'Trade'];
        Proposal__c prop = [SELECT Id, Name, Active__c, RecordTypeId FROM Proposal__c WHERE Name = 'InActive Proposal']; 
        prop.RecordTypeId = recType != null ? recType.ID : politicalRecTypeId;      
        prop.Active__c=true;
        UPDATE prop;
        proposalId = prop.Id;

        propList =[SELECT Id, RecordType.Name, Active__c FROM Proposal__c LIMIT 1];

        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(propList);
        sc.setSelected(propList);

        ApexPages.currentPage().getParameters().put('Id',opp.Id);

        String oppId = ApexPages.currentPage().getParameters().get('Id');
        System.assertEquals(true,oppId!=null);

        obj = new ProposalActiveInactiveController(sc);
        obj.getheaderRecTypeLst();
        UserConnection__c loggedInUser = [SELECT AE_Id__c, TIM_System__c, Username__c
                            FROM UserConnection__c
                            WHERE User__c=: UserInfo.getUserId() AND TIM_System__c ='St. Louis Local' LIMIT 1];
            
        String timSystem = 'StLouisLocal';
        String partitionName = 'local.TIMAccess';
        Cache.OrgPartition newpart = new Cache.OrgPartition(partitionName);

        Map<String,TIMUserAccess.User> timuserMap = new Map<String,TIMUserAccess.User>();

        timuserMap.put('St. Louis Local', CacheManager.getTIMUser(loggedInUser.Username__c+timSystem,timSystem));

        newpart.put('StLouisLocal', timuserMap);
        obj.getrecordTypeLst();
        obj.isSelectAll = true;       
        obj.fetchRecordTypeList();
        obj.selectedAllRecordType = Label.Trade_RT;
        
        obj.setSelectAll();
        obj.checkActiveInactive();
        obj.isSelectAllActiveDeactive = true;
        obj.setSelectActiveDeactive();
        obj.setForAllRecordTypeName();
        obj.setRecordTypeName();
        obj.updateProposals();
        
        obj.GoBackToOpportunity();
    }  


    static void prepareTestDataForShowSeeker() 
    {     
        //Creating ShowSeeker User
        User u = TestDataHelper.createSystemAdminUser(FALSE);
        u.ShowSeeker_User__c=true;
        INSERT u; 

        linearRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Linear' AND SobjectType = 'Proposal__c'].Id;
        tradeRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Trade' AND SobjectType = 'Proposal__c'].Id;
        inventoryRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Inventory' AND SobjectType = 'Proposal__c'].Id;
        politicalRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Political' AND SobjectType = 'Proposal__c'].Id;

        System.runAs(u)
        {
            acc = TestDataHelper.createAcc('Test Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');
            acc.Political_Account__c = true;                        
            INSERT acc;
            
            opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.Id); 
            opp.OwnerId = u.Id;       
            INSERT opp; 

            Proposal__c prop1 = TestDataHelper.createProposal('InActive Proposal',opp.Id,'',TRUE);
            prop1.RecordTypeId = linearRecTypeId;           
            prop1.Pilot_Proposal_ID__c = '12345';           
            INSERT prop1;
            proposalId = prop1.Id;

            Proposal__c prop2 = TestDataHelper.createProposal('Active Proposal',opp.Id,'',FALSE);
            prop1.Active__c=true;
            prop1.RecordTypeId = inventoryRecTypeId;           
            prop1.Pilot_Proposal_ID__c = '67890';
            INSERT prop2;

            propList =[SELECT Id, Opportunity__c FROM Proposal__c WHERE Opportunity__c = :opp.Id];  
            System.assertEquals(2, propList.size()); 
        }
    }


    static testMethod void testPropActiveInactiveForSS_ActiveCheck() 
    {
        prepareTestDataForShowSeeker();

        Proposal__c prop = [SELECT Id, Name, Active__c, RecordTypeId, RecordType.DeveloperName, Pilot_Proposal_ID__c FROM Proposal__c WHERE Name = 'InActive Proposal'];  
        proposalId = prop.Id;
        List<Proposal__c> propList1= new List<Proposal__c>();

        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new ShowSeekerWebServiceMock(200));

        PageReference proposalPage = Page.ProposalActiveInactive;
        Test.setCurrentPage(proposalPage);
        ApexPages.currentPage().getParameters().put('Id',opp.Id);
        String oppId = ApexPages.currentPage().getParameters().get('Id');
        System.assertEquals(true,oppId!=null);

        ApexPages.StandardSetController sc1 = new ApexPages.StandardSetController(propList1);
        sc1.setSelected(propList1);
        obj = new ProposalActiveInactiveController(sc1);
        propList =[SELECT Id, RecordType.Name, RecordType.DeveloperName, Active__c, Pilot_Proposal_ID__c FROM Proposal__c WHERE Id = :prop.Id];
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(propList);
        sc.setSelected(propList);

        obj = new ProposalActiveInactiveController(sc);
        obj.getheaderRecTypeLst();
        
        obj.proposalRecordId = proposalId;
        obj.getrecordTypeLst();

        obj.selectedActiveInactiveChck = proposalId;
        ProposalActiveInactiveController.ProposaldisplayWrapper  propDisWrap = new ProposalActiveInactiveController.ProposaldisplayWrapper();
        propDisWrap.propObj = propList[0];
        propDisWrap.isSelected = true;
        propDisWrap.isActive = false;
        propDisWrap.isActivechanged = true;
        obj.isSelectAll = true;
        propDisWrap.showPicklist = true;
        obj.populateUpdateStatus(propDisWrap, NULL);
        obj.selectedAllRecordType = Label.Trade_RT;
        propDisWrap.selectedrecordType = Label.Inventory_RT;
        obj.selectedProposalId = proposalId;
       
        obj.fetchRecordTypeList();
        obj.setSelectAll();
        obj.singleSelection();
        obj.checkActiveInactive();
        obj.isSelectAllActiveDeactive = false;
        obj.setSelectActiveDeactive();
        obj.setRecordTypeName();
        obj.setForAllRecordTypeName();
        obj.updateProposals();
        obj.GoBackToOpportunity();

        Test.StopTest();
    }


     static testMethod void testPropActiveInactiveFailedForSS() 
    {        
        prepareTestDataForShowSeeker();

        Proposal__c prop = [SELECT Id, Name, Active__c, RecordTypeId, Pilot_Proposal_ID__c FROM Proposal__c WHERE Name = 'InActive Proposal'];  
        proposalId = prop.Id;
        List<Proposal__c> propList1= new List<Proposal__c>();

        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new ShowSeekerWebServiceMock(400));

        PageReference proposalPage = Page.ProposalActiveInactive;
        Test.setCurrentPage(proposalPage);
        ApexPages.currentPage().getParameters().put('Id',opp.Id);
        String oppId = ApexPages.currentPage().getParameters().get('Id');
        System.assertEquals(true,oppId!=null);

        ApexPages.StandardSetController sc1 = new ApexPages.StandardSetController(propList1);
        sc1.setSelected(propList1);
        obj = new ProposalActiveInactiveController(sc1);
        propList =[SELECT Id, RecordType.Name, RecordType.DeveloperName, Active__c, Pilot_Proposal_ID__c FROM Proposal__c WHERE Id = :prop.Id];
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(propList);
        sc.setSelected(propList);

        obj = new ProposalActiveInactiveController(sc);
        obj.getheaderRecTypeLst();
        
        obj.proposalRecordId = proposalId;
        obj.getrecordTypeLst();

        obj.selectedActiveInactiveChck = proposalId;
        ProposalActiveInactiveController.ProposaldisplayWrapper  propDisWrap = new ProposalActiveInactiveController.ProposaldisplayWrapper();
        propDisWrap.propObj = propList[0];
        propDisWrap.isSelected = true;
        propDisWrap.isActive = false;
        propDisWrap.isActivechanged = true;
        obj.isSelectAll = true;
        propDisWrap.showPicklist = true;
        obj.populateUpdateStatus(propDisWrap, NULL);
        obj.selectedAllRecordType = Label.Trade_RT;
        propDisWrap.selectedrecordType = Label.Inventory_RT;
        obj.selectedProposalId = proposalId;
       
        obj.fetchRecordTypeList();
        obj.setSelectAll();
        obj.singleSelection();
        obj.checkActiveInactive();
        obj.isSelectAllActiveDeactive = false;
        obj.setSelectActiveDeactive();
        obj.setRecordTypeName();
        obj.setForAllRecordTypeName();
        obj.updateProposals();
        obj.GoBackToOpportunity();

        Test.StopTest();
    }
    static testMethod void testPropActiveInactiveForAOSDeal() 
    {
        prepareTestData();
        Proposal__c prop = [SELECT Id, Name, RecordType.Name, RecordType.DeveloperName, AOS_Deal_Id__c, AOS_Deal_Status__c, Active__c, RecordTypeId, Pilot_Proposal_ID__c FROM Proposal__c WHERE Name = 'Active Advanced Proposal'];  
        proposalId = prop.Id;
        List<Proposal__c> propList1= new List<Proposal__c>();

        Test.StartTest();

        PageReference proposalPage = Page.ProposalActiveInactive;
        Test.setCurrentPage(proposalPage);
        ApexPages.currentPage().getParameters().put('Id',opp.Id);
        String oppId = ApexPages.currentPage().getParameters().get('Id');
        System.assertEquals(true,oppId!=null);

        ApexPages.StandardSetController sc1 = new ApexPages.StandardSetController(propList1);
        sc1.setSelected(propList1);
        obj = new ProposalActiveInactiveController(sc1);
        propList =[SELECT Id, RecordType.Name, RecordType.DeveloperName, AOS_Deal_Id__c, AOS_Deal_Status__c, Active__c, Pilot_Proposal_ID__c FROM Proposal__c WHERE Id = :prop.Id];
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(propList);
        sc.setSelected(propList);

        obj = new ProposalActiveInactiveController(sc);
        obj.getheaderRecTypeLst();
        
        obj.proposalRecordId = proposalId;
        obj.getrecordTypeLst();

        obj.selectedActiveInactiveChck = proposalId;
        ProposalActiveInactiveController.ProposaldisplayWrapper  propDisWrap = new ProposalActiveInactiveController.ProposaldisplayWrapper();
        propDisWrap.propObj = propList[0];
        propDisWrap.isSelected = true;
        propDisWrap.isActive = false;
        propDisWrap.isActivechanged = true;
        obj.isSelectAll = false;
        propDisWrap.showPicklist = false;
        obj.selectedAllRecordType = '';
        propDisWrap.selectedrecordType = propList[0].RecordType.Name;
        propDisWrap.recordtypename = propList[0].RecordType.Name;
        propDisWrap.recTypeDevName = propList[0].RecordType.DeveloperName;
        obj.selectedProposalId = proposalId;
        obj.populateUpdateStatus(propDisWrap, 'REQUEST SENT');
        obj.updateProposals();
        obj.GoBackToOpportunity();

        Test.StopTest();
    }
}