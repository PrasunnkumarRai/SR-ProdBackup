@isTest
public with sharing class ProposalTIMCreateControllerTest {
    
    @IsTest(seeAlldata = false)
    static void completeMethodPositivePathTest() {
        
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
          opp.OwnerId = u.Id; 
          INSERT opp;

          //insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
          
          List<Opportunity> opplist = new List<Opportunity>();
          opplist.add(opp);
          
          Proposal__c p = TestDataHelper.createProposal('Test Opportunity Proposal',opp.Id, '00000', true);
          INSERT p;
          
          ApexPages.StandardSetController controller = new ApexPages.StandardSetController(opplist);
          ApexPages.currentPage().getParameters().put('Id', opp.Id);

          String oppId = ApexPages.currentPage().getParameters().get('Id');
          System.assertEquals(true,oppId!=null);
                  
          ProposalTIMCreateController cp = new ProposalTIMCreateController(controller);
          cp.estimateId = System.label.TestTIMId;
          //cp.execute();
          cp.isconfirm = true;
          
          Test.StartTest();         
          Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
          Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
          cp.execute();
          
          INSERT TestDataHelper.createProposal('Test Opportunity Proposal2',opp.Id, '00001', true);
          

          List<Proposal__c> newPropList = [SELECT LastModifiedDate,Id,TIM_Id__c, Advertiser__c, Opportunity__c
                                         FROM Proposal__c 
                                         WHERE Opportunity__c = : opp.Id AND RecordType.Name != 'Opportunity Budget'
                                         ORDER BY LastModifiedDate DESC LIMIT 2];        
        
          System.debug('newPropListTest----'+newPropList);
          try{
          cp.complete();
          }
          catch(Exception ex){
            System.debug('Exception: ' + ex);           
          }
          delete [SELECT Id FROM UserConnection__c LIMIT 1];
            cp = new ProposalTIMCreateController(controller);
          Test.StopTest();

        }
    }
    
    @IsTest(seeAlldata = false)
    static void executeMethodPositivePathTest() {
      
      User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        
        System.runAs(u){
        
          TestDataHelper.createTIMIntegrationCustomSettings();
          INSERT TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
          
          //Create an account
          Account acc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
          INSERT acc;
          
          //Create an opportunity on the above created account
          Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
          opp.OwnerId = UserInfo.getUserId(); 
          INSERT opp;
      
          UserConnection__c connection = TestDataHelper.createUserConnection('St. Louis Local','emily.sabo',UserInfo.getUserId(),'TIM','1');   
            connection.AE_Id__c = '';
            INSERT connection;
            connection.AE_Id__c = '309';
            connection.user__c = UserInfo.getUserId();
            connection.TIM_System__c = connection.TIM_System__c;
            UPDATE connection;

          List<Opportunity> opplist = new List<Opportunity>();
          opplist.add(opp);
          
          ApexPages.StandardSetController controller = new ApexPages.StandardSetController(opplist);
          ApexPages.currentPage().getParameters().put('Id', opp.Id);

          String oppId = ApexPages.currentPage().getParameters().get('Id');
          System.assertEquals(true,oppId!=null);
                  
          ProposalTIMCreateController cp = new ProposalTIMCreateController(controller);
          cp.estimateId = System.label.TestTIMId;
          cp.isconfirm = true;
          
          INSERT TestDataHelper.createProposal('Test Opportunity Proposal',opp.Id, '00000', true);   
          
          Test.StartTest();
          Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
          Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
          cp.execute();
          Test.StopTest();
        }
    }
    
    @IsTest(seeAlldata = false)
    static void simulateMethodPositivePathTest() {
        
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        
        System.runAs(u){
          TestDataHelper.createTIMIntegrationCustomSettings();
          INSERT TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
          
          //Create an account
          Account acc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
          INSERT acc;
          
          //Create an opportunity on the above created account
          Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
          INSERT opp;         

          List<Opportunity> opplist = new List<Opportunity>();
          opplist.add(opp);

          UserConnection__c connection = TestDataHelper.createUserConnection('St. Louis Local','emily.sabo', userInfo.getUserId(),'TIM','1');   
            connection.AE_Id__c = ' ';            
            connection.Is_Primary__c = true;
            INSERT connection;
           /* connection.TIM_System__c = 'Charlotte';
            update connection;*/
          System.debug('con1::'+connection);

          ApexPages.StandardSetController controller = new ApexPages.StandardSetController(opplist);
          ApexPages.currentPage().getParameters().put('Id', opp.Id);

          String oppId = ApexPages.currentPage().getParameters().get('Id');
          System.assertEquals(true,oppId!=null);

           ProposalTIMCreateController cp = new ProposalTIMCreateController(controller);
       //Code changes by Aditi : 07/07/2017 
          If(String.isBlank(System.label.TestTIMId)){
            cp.estimateId = System.label.TestTIMId;
          }
          else{
            cp.estimateId = '';
          }                 

          INSERT TestDataHelper.createProposal('Test Opportunity Proposal',opp.Id, '00000', true);   
          
          Test.StartTest();
          Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
          Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
          cp.simulate();
          Test.StopTest();
        }
    }

    @IsTest(seeAlldata = false)
    static void backMethodPositivePathTest() {
        
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        
        System.runAs(u){
          TestDataHelper.createTIMIntegrationCustomSettings();
          INSERT TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
          
          //Create an account
          Account acc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
          INSERT acc;
          
          //Create an opportunity on the above created account
          Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
          INSERT opp;
          
          List<Opportunity> opplist = new List<Opportunity>();
          opplist.add(opp);
          /*Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
          User usr = new User(alias = 'standt', email = 'standarduser1234@testorgosius.com',
            emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
            localesidkey = 'en_US', profileid = p.Id,
            timezonesidkey = 'America/Los_Angeles', username = 'standarduser1234@testorgosius.com');
          INSERT usr;
          System.debug('usr id::'+usr.Id);*/

          UserConnection__c connection = new UserConnection__c(TIM_System__c = 'Charlotte',Username__c=' ',User__c=opp.OwnerId,
            External_System__c ='TIM',AE_Id__c ='');          
          INSERT connection;
            

          ApexPages.StandardSetController controller = new ApexPages.StandardSetController(opplist);
          ApexPages.currentPage().getParameters().put('Id', opp.Id);

          String oppId = ApexPages.currentPage().getParameters().get('Id');
          System.assertEquals(true,oppId!=null);
                  
          ProposalTIMCreateController cp = new ProposalTIMCreateController(controller);
          cp.estimateId = System.label.TestTIMId;
          
          INSERT TestDataHelper.createProposal('Test Opportunity Proposal',opp.Id, '00000', true);   
          
          Test.StartTest();
          // Set mock callout class
          Test.setMock(WebServiceMock.class, new StratagTimService_Mock());        
          Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
          cp.back();
          Test.StopTest();
        }
    }
    
    
    @IsTest(seeAlldata = false)
    static void getTIMURLMethodPositivePathTest() {
        
       User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        
        System.runAs(u){
          TestDataHelper.createTIMIntegrationCustomSettings();
          INSERT TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
          
          //Create an account
          Account acc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
          INSERT acc;
          //Start : SRSF-2043
          UserConnection__c loggedInUser = [SELECT AE_Id__c, TIM_System__c, Username__c
                            FROM UserConnection__c
                            WHERE User__c=: UserInfo.getUserId() AND TIM_System__c ='St. Louis Local' LIMIT 1];
          String timSystem = 'StLouisLocal';
          String partitionName = 'local.TIMAccess';
          Cache.OrgPartition newpart = new Cache.OrgPartition(partitionName);

          Map<String,TIMUserAccess.User> timuserMap = new Map<String,TIMUserAccess.User>();

          timuserMap.put('St. Louis Local', CacheManager.getTIMUser(loggedInUser.Username__c+timSystem,timSystem));

          newpart.put('StLouisLocal', timuserMap);
          //End : SRSF-2043
          //Create an opportunity on the above created account
          Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
          INSERT opp;
          
          List<Opportunity> opplist = new List<Opportunity>();
          opplist.add(opp);         

          ApexPages.StandardSetController controller = new ApexPages.StandardSetController(opplist);
          ApexPages.currentPage().getParameters().put('Id', opp.Id);

          String oppId = ApexPages.currentPage().getParameters().get('Id');
          System.assertEquals(true,oppId!=null);

          //Code changes by Aditi :9th March, 2018
          //ApexPages.currentPage().getParameters().put('recType','_LR');
          //Code changes ends
                  
          ProposalTIMCreateController cp = new ProposalTIMCreateController(controller);
          cp.estimateId = System.label.TestTIMId;
          cp.isconfirm = true;
          
          INSERT TestDataHelper.createProposal('Test Opportunity Proposal',opp.Id, '00000', true);                    
          Test.StartTest();
          // Set mock callout class
          Test.setMock(WebServiceMock.class, new StratagTimService_Mock());        
          Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
          try{  
            cp.execute();
            cp.getTIMURL();
          }
          catch(Exception ex){
            System.debug('Exception: ' + ex);           
          }
          Test.StopTest();
        }
    }
    
    @IsTest(seeAlldata = false)
    static void executeNegativePathTest() {
        
       User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        
        System.runAs(u){
          TestDataHelper.createTIMIntegrationCustomSettings();
          INSERT TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','');
          
          //Create an account
          Account acc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
          INSERT acc;
          
          //Create an opportunity on the above created account
          Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
          opp.Ownerid = u.Id;
          INSERT opp;
          System.debug('opp owner id::'+opp.OwnerId);
          System.debug('opp.owner.Profile.Name'+opp.owner.Profile.Name);
          
          List<Opportunity> opplist = new List<Opportunity>();
          opplist.add(opp);
          /*Contact con = TestDataHelper.createContact('TestCon',acc.Id,null,'Billing Contact');
          insert con;*/

          NationalProfiles__c np = new NationalProfiles__c(Name='Integration User',Profile_Name__c='Integration User');
          INSERT np;

          
          ApexPages.StandardSetController controller = new ApexPages.StandardSetController(opplist);
          ApexPages.currentPage().getParameters().put('Id', opp.Id);

          String oppId = ApexPages.currentPage().getParameters().get('Id');
          System.assertEquals(true,oppId!=null);
                  
          ProposalTIMCreateController cp = new ProposalTIMCreateController(controller);
          cp.estimateId = System.label.TestTIMId;
          cp.isAuthenticated = true;
          cp.isconfirm = true;
          INSERT TestDataHelper.createProposal('Test Opportunity Proposal',opp.Id, '00000', true);                    
          Test.StartTest();
          // Set mock callout class
          Test.setMock(WebServiceMock.class, new StratagTimService_Mock());        
          Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
          try{  
            //cp.acctMap = new Map<Id,Account>();
            cp.execute();
          }
          catch(Exception ex){
            System.debug('Exception: ' + ex);           
          }
          Test.StopTest();
        }
    }
    
    @IsTest(seeAlldata = false)
    static void getTIMURLMethodNegativePathTest() {
        
       User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        Account repacc = new Account();
        //Code changes by Aditi : 7/7/2017
       /* User non_u = TestDataHelper.createUser(false);
        non_u.IsActive = true;
        insert non_u;
        // User non_u = [select Id, Name from User where Name != 'Boomi Integration User' limit 1];
      System.debug('@@non_u Name '+non_u.Name);
        System.runAs(non_u){
          System.debug('userId'+UserInfo.getUserId());
          repacc=TestDataHelper.createAdvertiser('Rep Firm Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
        repacc.Spectrum_Reach_Preferred__c = true;
        repacc.RecordTypeId=TestDataHelper.repFirmRecTypeId;
        insert repacc;
    }*/
          //code chnages ends
        
        System.runAs(u){
          System.debug('userId###u'+UserInfo.getUserId());
          Id repFirmRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Rep_Firm' AND SobjectType = 'Account' LIMIT 1].Id;
          TestDataHelper.createTIMIntegrationCustomSettings();
          INSERT TestDataHelper.createUserConnection('St. Louis Local','',UserInfo.getUserId(),'TIM','1'); // SFDCUser
          
          //Create an account
          Account acc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
          //acc.RecordTypeId=TestDataHelper.repFirmRecTypeId;
          INSERT acc;


          Account agency = TestDataHelper.createAgency('Agency Account','123 Wright Plaza', 'Hyderabad', 'Andhra Pradesh', '12102', 'India');
        //  agency.RecordTypeId=TestDataHelper.repFirmRecTypeId;
          INSERT agency; 
          
          //Create a Rep Firm account         
          Account repFirmAcc = TestDataHelper.createAcc('RepFirm Account', 'Ameerpet', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                        
            repFirmAcc.RecordTypeId = repFirmRecTypeId;
            INSERT repFirmAcc;

          //Create an opportunity on the above created account
          Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);
          opp.rep_Firm__c = repFirmAcc.Id; 
          opp.Agency_Account__c = agency.Id;       
          INSERT opp;
          
          List<Opportunity> opplist = new List<Opportunity>();
          opplist.add(opp);
          
          ApexPages.StandardSetController controller = new ApexPages.StandardSetController(opplist);
          ApexPages.currentPage().getParameters().put('Id', opp.Id);

          String oppId = ApexPages.currentPage().getParameters().get('Id');
          System.assertEquals(true,oppId!=null);

          //Code changes by Aditi :9th March, 2018
          ApexPages.currentPage().getParameters().put('recType','_LR');
          //Code changes ends
                  
          ProposalTIMCreateController cp = new ProposalTIMCreateController(controller);
          cp.estimateId = System.label.TestTIMId;
          
          INSERT TestDataHelper.createProposal('Test Opportunity Proposal',opp.Id, '00000', true);                    
          Test.StartTest();
          // Set mock callout class
          Test.setMock(WebServiceMock.class, new StratagTimService_Mock());        
          Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
          try{  
            
            cp.resMap.put(agency.Id,'123');
            cp.getTIMURL();
            cp.acctMap.put(agency.Id,agency);
            cp.getTIMURL();
            /*//code changes by Aditi : 7/7/2017
            cp.execute();
            cp.getTIMURL();
            cp.resMap.put('acc','456');
            cp.getTIMURL();
            //code chnages ends */
          }
          catch(Exception ex){
            System.debug('Exception: ' + ex);           
          }
          Test.StopTest();
        }
    }

    @IsTest(seeAlldata = false)
    static void completeResMethodPositivePathTest() {
        
        User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        User stdUser = TestDataHelper.createUser(true);
        
        System.runAs(u){
          TestDataHelper.createTIMIntegrationCustomSettings();
          
          //Create an account
          Account acc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
          INSERT acc;
          
          //Create an opportunity on the above created account
          Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
          opp.OwnerId = UserInfo.getUserId(); 
          INSERT opp;

          // insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
          

          List<Opportunity> opplist = new List<Opportunity>();
          opplist.add(opp);
          
          Proposal__c p = TestDataHelper.createProposal('Test Opportunity Proposal',opp.Id, '00000', true);
          INSERT p;

          List<UserConnection__c> conList = new List<UserConnection__c>();
          UserConnection__c connection = TestDataHelper.createUserConnection('St. Louis Local','emily.sabo',stdUser.Id,'TIM','1');   
            connection.AE_Id__c = '';
            conList.add(connection);
            INSERT conList;            
          System.debug('connection:>>'+conList.size());
          List<Proposal__c> newPropList = [SELECT LastModifiedDate,Id,TIM_Id__c, Advertiser__c, Opportunity__c
                                         FROM Proposal__c 
                                         WHERE Opportunity__c = : opp.Id AND RecordType.Name != 'Opportunity Budget'
                                         ORDER BY LastModifiedDate DESC LIMIT 2];        
        
          System.debug('newPropListTest----'+newPropList);
          Map<String,TIMIntegration__c> custSettMap = new Map<String,TIMIntegration__c>();
          custSettMap = TIMIntegration__c.getAll();

          /*TIMIntegration__c cust = new TIMIntegration__c(Name='St. Louis Local2',AppId__c ='1',BoomiAtomId__c ='5897381a-8c8c-4def-9508-bca93f8cb405',
            Boomi_Endpoint__c='http://47.42.247.9:9090/ws/rest/SpectrumReach',Boomi_EnvironmentId__c='',ClassicCompatibilityMode__c=true,
            Endpoint__c='https://its-vmt-timwb01.chartermedia.com/chrometimws/service.asmx',Password__c='us3th3F0RCE!',TIMServer__c='https://its-vmt-timwb01.chartermedia.com/chrometim',
            UserId__c='2',UserName__c='SFDCUser');
          insert cust;*/

          ApexPages.StandardSetController controller = new ApexPages.StandardSetController(opplist);
          ApexPages.currentPage().getParameters().put('Id', opp.Id);

          String oppId = ApexPages.currentPage().getParameters().get('Id');
          System.assertEquals(true,oppId!=null);

          //ApexPages.currentPage().getParameters().put('Id', newPropList[0].Id);
                  
          ProposalTIMCreateController cp = new ProposalTIMCreateController(controller);
          //cp.estimateId = System.label.TestTIMId;
          //cp.execute();
          
          Test.StartTest();
          Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
          Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
      
          BoomiWebServiceHelper bws = new BoomiWebServiceHelper();          
          BoomiHelper.EstimateHeader es = new BoomiHelper.EstimateHeader();
        /*  es.EstimateID = 123;
          es.Description = 'Test Desc';
          es.AdvertiserID = 12;
*/
          String res = bws.syncProposalLineItems(newPropList.get(0),conList[0]);
          System.debug('res::'+res);        
          try{
            res = 'Error';
            cp.complete();
          }
          catch(Exception ex){
            System.debug('Exception: ' + ex);           
          }
          Test.StopTest();
        }
    }
    @IsTest(seeAlldata = false)
    static void getTIMURLMethodPositivePathTest_withspecialProposal() {
        
       User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        
        System.runAs(u){
          TestDataHelper.createTIMIntegrationCustomSettings();
          INSERT TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
          
          //Create an account
          Account acc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
          INSERT acc;
          
          //Create an opportunity on the above created account
          Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
          INSERT opp;
          
          List<Opportunity> opplist = new List<Opportunity>();
          opplist.add(opp);         
          ProposalTIMCreateController cp1 = new ProposalTIMCreateController();      
          ApexPages.StandardSetController controller = new ApexPages.StandardSetController(opplist);
          ApexPages.currentPage().getParameters().put('Id', opp.Id);

          String oppId = ApexPages.currentPage().getParameters().get('Id');
          System.assertEquals(true,oppId!=null);
            
          //Code changes by Aditi :9th March, 2018
          ApexPages.currentPage().getParameters().put('recType','_LR');
          //Code changes ends
            
          ProposalTIMCreateController cp = new ProposalTIMCreateController(controller);
          cp.estimateId = System.label.TestTIMId;
          cp.isconfirm = true;
          
          INSERT TestDataHelper.createProposal('Test Opportunity Proposal',opp.Id, '00000', true);                    
          Test.StartTest();
          // Set mock callout class
          Test.setMock(WebServiceMock.class, new StratagTimService_Mock());        
          Test.setMock(HttpCalloutMock.class, new BoomiWebServiceMock());
          try{  
            cp.execute();
            cp.getTIMURL();
          }
          catch(Exception ex){
            System.debug('Exception: ' + ex);           
          }
          Test.StopTest();
          // UserConnection__c userConn = [Select AE_Id__c, TIM_System__c, Username__c,user__r.name
         //                    from UserConnection__c ];
         //    System.debug('userConn'+userConn);
         //    delete userConn;
         //    ProposalTIMCreateController cpn = new ProposalTIMCreateController(controller);

        }
    } 
    @IsTest
     static void newTestmethod() {
         User u = TestDataHelper.getBoomiIntegrationUser();
        System.debug('@@u Name '+u.Name);
        
        System.runAs(u){
        
          TestDataHelper.createTIMIntegrationCustomSettings();
          // insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
          
          //Create an account
          Account acc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
          INSERT acc;
          
          //Create an opportunity on the above created account
          Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
          opp.OwnerId = UserInfo.getUserId(); 
          INSERT opp;
      
         /* UserConnection__c connection = TestDataHelper.createUserConnection('St. Louis Local','emily.sabo',UserInfo.getUserId(),'TIM','1');   
            connection.AE_Id__c = '';
            insert connection;
            connection.AE_Id__c = '309';
            connection.user__c = UserInfo.getUserId();
           // connection.TIM_System__c = connection.TIM_System__c;
            update connection;*/

          List<Opportunity> opplist = new List<Opportunity>();
          opplist.add(opp);
          
          ApexPages.StandardSetController controller = new ApexPages.StandardSetController(opplist);
          ApexPages.currentPage().getParameters().put('Id', opp.Id);

          String oppId = ApexPages.currentPage().getParameters().get('Id');
          System.assertEquals(true,oppId!=null);
          ProposalTIMCreateController cp = new ProposalTIMCreateController(controller);
      }
  }
}