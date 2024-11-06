// created by amita mishra 
// for coverage of InactiveProposalsBatch
@isTest
private class InactiveProposalsBatch_test {
    @TestSetup 
    Static void createData(){
        Account acc = TestDataHelper.createAcc('Test Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                        
        INSERT acc;
        List<Opportunity> oppToInsert = new List<Opportunity>();

        Opportunity opp= TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.Id);
        opp.StageName = 'Closed Lost';
        opp.Loss_Reason__c = 'Lost to No Decision/Unresponsive';
        oppToInsert.add(opp);
        oppToInsert.add(TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.Id));

        Opportunity pilotOpp= TestDataHelper.createopportunity('Pilot Opportunity',System.today(),'Planning','Pipeline',acc.Id);
        oppToInsert.add(pilotOpp);
        INSERT oppToInsert;
        
        User loggedInUser = [SELECT Id, Name,UserRoleId,UserRole.Name,Profile.Name,ManagerId FROM User WHERE Id = :UserInfo.getUserId()];
        // boomiUser = TestDataHelper.getBoomiIntegrationUser();
        System.debug('User name::'+loggedInUser);
        List<Proposal__c> propToInsert = new List<Proposal__c>();
        for(Integer i = 1 ;i<=2 ;i++){
            Proposal__c prop = TestDataHelper.createProposal('Test Proposal'+i,opp.Id,'76877'+i,True); 
            prop.TIM_Status__c = 'Test group status'; 
            prop.TIM_System__c='St. Louis Local';
            propToInsert.add(prop);
        }
        Proposal__c prop = TestDataHelper.createProposal('Test Proposal',opp.Id,'76877',True);        
        List<Recordtype> recordTypeId = [SELECT Id FROM Recordtype WHERE DeveloperName = 'Opportunity_Budget' LIMIT 1];
        if(recordTypeId.size()>0) prop.RecordTypeId = recordTypeId[0].Id;
        propToInsert.add(prop);  

        Proposal__c pilotProp = TestDataHelper.createProposal('Pilot Proposal',pilotOpp.Id,null,True);
        pilotProp.TIM_Id__c = NULL;   
        pilotProp.TIM_Status__c = NULL;      
        pilotProp.Pilot_Proposal_ID__c = '12345';      
        propToInsert.add(pilotProp);

        Proposal__c pilotProp2=TestDataHelper.createProposal('PilotPropBudget',pilotOpp.Id,null,True);
        if(recordTypeId.size()>0) pilotProp2.RecordTypeId = recordTypeId[0].Id;       
        propToInsert.add(pilotProp2);
        INSERT propToInsert;
        
        List<Proposal_Zone__c> propZonesToInsert = new List<Proposal_Zone__c>();
        for( Proposal__c proposl : propToInsert){
            Proposal_Zone__c prop_zone = TestDataHelper.createProposalZone('Test Proposal', proposl.Id);
            propZonesToInsert.add(prop_zone);
        }

        INSERT propZonesToInsert;

        UserConnection__c connection = TestDataHelper.createUserConnection('St. Louis Local', 'SFDCUser',UserInfo.getUserId(),'','1');
        INSERT connection; 

        //Create TIMIntegration__c Data
        TestDataHelper.createTIMIntegrationCustomSettings();
        
        String timSystem = 'StLouisLocal';
        String partitionName = 'local.TIMAccess';
        Cache.OrgPartition newpart = new Cache.OrgPartition(partitionName);

        Map<String,TIMUserAccess.User> timuserMap = new Map<String,TIMUserAccess.User>();

        timuserMap.put('St. Louis Local', CacheManager.getTIMUser(connection.Username__c+timSystem,timSystem));

        newpart.put('StLouisLocal', timuserMap);
    }

    static testMethod void testMethodPositive() {
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());       
        List<Opportunity> opplist = [SELECT Id, StageName FROM Opportunity LIMIT 10];
        for(Opportunity obj: opplist){
            obj.StageName = 'Closed Lost';
            obj.Loss_Reason__c = 'Lost to No Decision/Unresponsive';
        }
        UPDATE oppList;
        Test.stopTest();
    }

    static testMethod void testMethodneagtive() {
        Test.startTest(); 
        Account acc = TestDataHelper.createAcc('Test Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                        
        INSERT acc;
        Opportunity opp= TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.Id);
        INSERT opp;
        
        User loggedInUser = [SELECT Id, Name,UserRoleId,UserRole.Name,Profile.Name,ManagerId FROM User WHERE Id = :UserInfo.getUserId()];
        System.debug('User name::'+loggedInUser);
        Proposal__c prop = TestDataHelper.createProposal('Test Proposal',opp.Id,'76877',True); 
        INSERT prop;
        
        Proposal_Zone__c prop_zone = TestDataHelper.createProposalZone('Test1 Proposal', prop.Id);
        INSERT prop_zone;
        
        List<Opportunity> opplist = [SELECT Id, StageName FROM Opportunity LIMIT 10];
        for(Opportunity obj: opplist){
            obj.StageName = 'Closed Lost';
            obj.Loss_Reason__c = 'Lost to No Decision/Unresponsive';
        }
        UPDATE oppList;       
        Test.stopTest();
    }   

    
    @isTest 
    static void testInactiveProposalsBatch() {
        Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());  
        List<Id> lisOfIds = new List<Id>();
        for(Opportunity opp : [SELECT Id FROM Opportunity WHERE IsClosed = true AND IsWon = false]){
            lisOfIds.add(opp.Id);
        }
        List<UserConnection__c> userConnectionList = [SELECT Id,TIM_System__c,AE_Id__c,User__c,Username__c FROM UserConnection__c WHERE User__c=:UserInfo.getUserId() AND TIM_System__c!=NULL ORDER BY Createddate];
        Map<String,UserConnection__c> userConnMap = new Map<String,UserConnection__c>();
        for(UserConnection__c userConn : userConnectionList){
            userConnMap.put(userConn.TIM_System__c,userConn);
        }
        System.debug('userConnMap:::'+userConnMap);
        String queryStr = 'SELECT Id,Active__c,TIM_System__c,Recordtype.DeveloperName,TIM_Id__c,(Select Id from Proposal_Zones__r) FROM Proposal__c WHERE Active__c = TRUE AND Opportunity__c  IN ' + '(\'' + String.join(lisOfIds,'\',\'') + '\')';
        Integer batchSize = String.isNotBlank(Label.InactiveProposalsBatch_Size)? Integer.valueOf(Label.InactiveProposalsBatch_Size) : 5;
        Test.startTest();
        InactiveProposalsBatch propBatch = new InactiveProposalsBatch(queryStr ,userConnMap);
        propBatch.sendEmailFlag = TRUE;
        Id jobId = Database.executeBatch(propBatch,batchSize);
        BoomiHelper.BoomiHelperCls  boomihlprcls = BoomiHelper.parseEstimateHdrLsttJson('{"EditHdrResponseList" : {"EditEstimateHeader_5_0Response" : [{"success" : "false","errors" : {"error" : [{"message" : "Message: [soap:Server] Server was unable to process request. ---> Error CL3: user must call Authenticate. Session has expired. ; Details:  ; Code:"}]}}]}}');
        Test.stopTest();
    }    
}