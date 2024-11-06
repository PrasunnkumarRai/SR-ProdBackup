@isTest
private class ThirdPartyDigitalInvReqServicesTest 
{

  @testSetup static void setup() 
  {
    User usr = TestDataHelper.createUser(true);
    User adminUser = TestDataHelper.createSystemAdminUser(true);
    System.runAs(adminUser)
    {  test.startTest();
      Account acc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
      INSERT acc;

      System.assert(acc != null);

      Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.id);        
      INSERT opp;

      List<Proposal__c> propLst = new List<Proposal__c>();
      Proposal__c prop = TestDataHelper.createProposal('Test Proposal',opp.Id,'76878',TRUE); 
      prop.Advertiser__c = acc.Id; 
      prop.TIM_Status__c = 'Proposal';  

      Proposal__c prop2 = TestDataHelper.createProposal('Test Proposal2',opp.Id,'76879',FALSE); 
      prop2.Advertiser__c = acc.Id;   
      prop2.TIM_Status__c = 'Proposal'; 

      Proposal__c prop4 = TestDataHelper.createProposal('Test Proposal4',opp.Id,'76881',TRUE); 
      prop4.Advertiser__c = acc.Id;   
      prop4.TIM_Status__c = 'Proposal';  

      Id recTypId = Schema.SObjectType.Proposal__c.getRecordTypeInfosByDeveloperName().get('Opportunity_Budget').getRecordTypeId(); 
      Proposal__c prop3 = TestDataHelper.createProposal('Test Proposal3',opp.Id, NULL, TRUE); 
      prop3.Advertiser__c = acc.Id;   
      prop3.RecordTypeId = recTypId;
      propLst.add(prop);
      propLst.add(prop2);
      propLst.add(prop3);
      propLst.add(prop4);
      INSERT propLst;   

      Zipcode_Mapping__c objDZM = TestUtil.getDigitalZipcodeMapping();
      objDZM.Zip_List__c = '31010, 31015, 31512';
      INSERT objDZM; 

      List<Digital_Campaign__c> dcList = new  List<Digital_Campaign__c>();

      Digital_Campaign__c dc =  TestDataHelper.createDigitalCampaign('Test', String.valueOf(opp.Id), String.valueOf(prop.Id));
      dc.Total_Impressions__c = 1000;       
      dc.Desired_Budget__c = 35;
      //dc.Campaign_Start_Date__c = Date.newInstance(2020,03,10);
      //dc.Campaign_End_Date__c = Date.newInstance(2020,03,25);
      dc.Campaign_Start_Date__c = System.today();
      dc.Campaign_End_Date__c = System.today().addDays(14);
      dc.DMAs__c = objDZM.Nielsen_DMA_Name__c;
      dc.Spectrum_Reach_Zones__c = '';          
      dc.AdsE_Genre_s__c = 'All Networks';      
      dcList.add(dc);

      Digital_Campaign__c dc2 =  TestDataHelper.createDigitalCampaign('Test2', String.valueOf(opp.Id), String.valueOf(prop.Id));
      dc2.Total_Impressions__c = 1000;
      dc2.Desired_Budget__c = 35;
      //dc2.Campaign_Start_Date__c = Date.newInstance(2020,03,10);
      //dc2.Campaign_End_Date__c = Date.newInstance(2020,03,25);
      dc2.Campaign_Start_Date__c = System.today();
      dc2.Campaign_End_Date__c = System.today().addDays(14);
      dc2.DMAs__c = '';
      dc2.Spectrum_Reach_Zones__c = objDZM.SR_Zone_Name__c;
      dc2.AdsE_Genre_s__c = 'All Networks';      
      dcList.add(dc2);
        
      Digital_Campaign__c dc3 =  TestDataHelper.createDigitalCampaign('Test2', String.valueOf(opp.Id), String.valueOf(prop.Id));
      dc3.Total_Impressions__c = 1000;
      dc3.Desired_Budget__c = 35;
      //dc2.Campaign_Start_Date__c = Date.newInstance(2020,03,10);
      //dc2.Campaign_End_Date__c = Date.newInstance(2020,03,25);
      dc3.Campaign_Start_Date__c = System.today();
      dc3.Campaign_End_Date__c = System.today().addDays(14);
      dc3.DMAs__c = '';
      dc3.Spectrum_Reach_Zones__c = objDZM.SR_Zone_Name__c;
      dc3.AdsE_Genre_s__c = 'All Networks'; 
      dc3.Status__c= 'Draft Plan';
      dc3.Zip_Codes__c = '94022, 94024, 94025, 94027, 94028';
      dcList.add(dc3);

      INSERT dcList;

      List<Digital_Campaign_Fields__c> dirFields = new List<Digital_Campaign_Fields__c>();
      Digital_Campaign_Fields__c fld1 = new Digital_Campaign_Fields__c(Name='Campaign_Name__c');
      Digital_Campaign_Fields__c fld2 = new Digital_Campaign_Fields__c(Name='Campaign_Start_Date__c');
      Digital_Campaign_Fields__c fld3 = new Digital_Campaign_Fields__c(Name='Campaign_End_Date__c');
      dirFields.add(fld1);
      dirFields.add(fld2);
      dirFields.add(fld3);
      INSERT dirFields;
test.stopTest();
    }
  }


  static testMethod void testUpdateDIRwithCustomZipCode() 
  {
    List<Digital_Campaign__c> dcList = [SELECT Id, Campaign_Name__c,AdsE_Genre_s__c,Campaign_Start_Date__c,Campaign_End_Date__c,Desired_Budget__c,Opportunity__c,Status__c,Total_Impressions__c,Proposal__c FROM Digital_Campaign__c WHERE STATUS__C='draft plan' LIMIT 1]; 
   
   
    Test.startTest(); 
    //Update DIR
    ThirdPartyDigitalInvReqServices.IncomingRequestWrapper incmngWrpr = new ThirdPartyDigitalInvReqServices.IncomingRequestWrapper();         
    incmngWrpr.source = Label.Audience_Track;             
    incmngWrpr.userID = [SELECT Id FROM User WHERE lastname = 'Testing' LIMIT 1].Id;     
    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper dcWrprRecSttv = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper(); 
    dcWrprRecSttv.isDraftPlan = TRUE;
    dcWrprRecSttv.product = 'STTV';
    dcWrprRecSttv.digitalCampaign = new Digital_Campaign__c();
    dcWrprRecSttv.digitalCampaign.Proposal__c =dcList[0].Proposal__c;
    dcWrprRecSttv.digitalCampaign.Campaign_Name__c = dcList[0].Campaign_Name__c;
    dcWrprRecSttv.digitalCampaign.DMAs__c ='';
    dcWrprRecSttv.digitalCampaign.Spectrum_Reach_Zones__c ='';  
    dcWrprRecSttv.digitalCampaign.Product_Type__c='Default Ads Everywhere Campaign';
    dcWrprRecSttv.digitalCampaign.AdsE_Genre_s__c =dcList[0].AdsE_Genre_s__c; 
    dcWrprRecSttv.digitalCampaign.Desired_Budget__c =dcList[0].Desired_Budget__c;
    dcWrprRecSttv.digitalCampaign.Campaign_Start_Date__c =dcList[0].Campaign_Start_Date__c;
    dcWrprRecSttv.digitalCampaign.Campaign_End_Date__c =dcList[0].Campaign_End_Date__c;       
    dcWrprRecSttv.digitalCampaign.Opportunity__c = dcList[0].Opportunity__c;
    dcWrprRecSttv.digitalCampaign.Total_Impressions__c =dcList[0].Total_Impressions__c;  
    dcWrprRecSttv.digitalCampaign.AdsE_Platform_s__c ='All Platforms';
    dcWrprRecSttv.digitalCampaign.Gross_Campaign_Cost__c = 6000.00;   
    dcWrprRecSttv.digitalCampaign.Zip_Codes__c ='94022, 94024, 94025, 94027, 94028, 94025';     
    dcWrprRecSttv.digitalCampaign.Is_Expedite_Approved__c='TRUE';  // Added to meet Validation Rule Requirement     
    dcWrprRecSttv.digitalCampaign.Id = dcList[0].Id;  //UPDATE scenario

    List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper> dcWrapList = new List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper>{dcWrprRecSttv};
    incmngWrpr.digitalCampaignList = dcWrapList;        
    ThirdPartyDigitalInvReqServices.OutgoingResponseWrapper outWrpr = ThirdPartyDigitalInvReqServices.doPost(incmngWrpr);
    System.debug('outWrpr>>>>>'+outWrpr);           
    System.assertNotEquals(outWrpr.successDigitalCampaigns, null); 
    System.assert(outWrpr.isSuccess); 
    System.assertEquals(ThirdPartyDigitalInvReqServices.STATUS_SUCCESS, outWrpr.message);         
/*
    Digital_Campaign__c digitalCampaignRec = [SELECT Id, Zip_Codes__c, CustomZipCode__c FROM Digital_Campaign__c WHERE Id = :dcList[0].Id AND Source__c='Audience Track' LIMIT 1];
   
    System.assert(digitalCampaignRec.CustomZipCode__c); 
    System.assertEquals(digitalCampaignRec.Zip_Codes__c, '94022, 94024, 94025, 94027, 94028');*/
    Test.stopTest();
  }
  
    
  static testMethod void testUpdateDIRwithDMA() 
  {     
    List<Digital_Campaign__c> dcList = [SELECT Id, Campaign_Name__c,AdsE_Genre_s__c,Campaign_Start_Date__c,Campaign_End_Date__c,Desired_Budget__c,Opportunity__c,Status__c,Total_Impressions__c,Proposal__c FROM Digital_Campaign__c WHERE Status__c = 'Draft Plan']; 
     
    Test.startTest(); 
    //Update DIR
    ThirdPartyDigitalInvReqServices.IncomingRequestWrapper incmngWrpr = new ThirdPartyDigitalInvReqServices.IncomingRequestWrapper();         
    incmngWrpr.source = Label.Audience_Track;             
    incmngWrpr.userID = [SELECT Id FROM User WHERE lastname = 'Testing' LIMIT 1].Id;     
    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper dcWrprRecSttv = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper(); 
    dcWrprRecSttv.isDraftPlan = TRUE;
    dcWrprRecSttv.product = 'STTV';
    dcWrprRecSttv.digitalCampaign = new Digital_Campaign__c();
    dcWrprRecSttv.digitalCampaign.Proposal__c =dcList[0].Proposal__c;
    dcWrprRecSttv.digitalCampaign.Campaign_Name__c = dcList[0].Campaign_Name__c;
    dcWrprRecSttv.digitalCampaign.DMAs__c ='DMA1';
    dcWrprRecSttv.digitalCampaign.Spectrum_Reach_Zones__c ='';  
    dcWrprRecSttv.digitalCampaign.Product_Type__c='Default Ads Everywhere Campaign';
    dcWrprRecSttv.digitalCampaign.AdsE_Genre_s__c =dcList[0].AdsE_Genre_s__c; 
    dcWrprRecSttv.digitalCampaign.Desired_Budget__c =dcList[0].Desired_Budget__c;
    dcWrprRecSttv.digitalCampaign.Campaign_Start_Date__c =dcList[0].Campaign_Start_Date__c;
    dcWrprRecSttv.digitalCampaign.Campaign_End_Date__c =dcList[0].Campaign_End_Date__c;       
    dcWrprRecSttv.digitalCampaign.Opportunity__c = dcList[0].Opportunity__c;
    dcWrprRecSttv.digitalCampaign.Total_Impressions__c =dcList[0].Total_Impressions__c; 
    dcWrprRecSttv.digitalCampaign.AdsE_Platform_s__c ='All Platforms';
    dcWrprRecSttv.digitalCampaign.Gross_Campaign_Cost__c = 6000.00;    
    dcWrprRecSttv.digitalCampaign.Zip_Codes__c =''; 
    dcWrprRecSttv.digitalCampaign.Is_Expedite_Approved__c='TRUE'; // Added to meet Validation Rule Requirement     
    dcWrprRecSttv.digitalCampaign.Id = dcList[0].Id;  //UPDATE scenario

    List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper> dcWrapList = new List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper>{dcWrprRecSttv};
    incmngWrpr.digitalCampaignList = dcWrapList;        
    ThirdPartyDigitalInvReqServices.OutgoingResponseWrapper outWrpr = ThirdPartyDigitalInvReqServices.doPost(incmngWrpr);
    System.debug('outWrpr>>>>>'+outWrpr);           
    System.assertNotEquals(outWrpr.successDigitalCampaigns, null); 
    System.assert(outWrpr.isSuccess);
    System.assertEquals(ThirdPartyDigitalInvReqServices.STATUS_SUCCESS, outWrpr.message); 

    Digital_Campaign__c digitalCampaignRec = [SELECT Id, Zip_Codes__c, CustomZipCode__c FROM Digital_Campaign__c WHERE Id = :dcList[0].Id AND Source__c='Audience Track' LIMIT 1];
   
    System.assert(!digitalCampaignRec.CustomZipCode__c); 
    System.assertEquals(digitalCampaignRec.Zip_Codes__c, '31010, 31015, 31512');
    Test.stopTest();
  }
    
  
  static testMethod void testCreateAndGetDIR() 
  {
    List<Digital_Campaign__c> dcList = [SELECT Id, Campaign_Name__c, Opportunity__c, Proposal__c, Product_Type__c, Campaign_End_Date__c, Campaign_Start_Date__c, Total_Impressions__c,DMAs__c, Spectrum_Reach_Zones__c, Desired_Budget__c, AdsE_Genre_s__c FROM Digital_Campaign__c]; 
    System.assert(dcList.size()>0);

    List<Zipcode_Mapping__c> zcList = [SELECT Id, Nielsen_DMA_Name__c, SR_Zone_Name__c FROM Zipcode_Mapping__c LIMIT 1];
    System.assert(zcList.size()>0);
      
    Test.startTest();       
    //Create DIR service  
    ThirdPartyDigitalInvReqServices.IncomingRequestWrapper incmngWrpr = new ThirdPartyDigitalInvReqServices.IncomingRequestWrapper();         
    incmngWrpr.source = Label.Audience_Track;             
    incmngWrpr.userID = [SELECT Id FROM User WHERE lastname = 'Testing' LIMIT 1].Id;     
    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper dcWrprRecSttv = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper(); 
    dcWrprRecSttv.isDraftPlan = FALSE;
    dcWrprRecSttv.product = 'STTV';
    dcWrprRecSttv.digitalCampaign = new Digital_Campaign__c();
    dcWrprRecSttv.digitalCampaign.Proposal__c =dcList[0].Proposal__c;
    dcWrprRecSttv.digitalCampaign.Campaign_Name__c = dcList[0].Campaign_Name__c;
    dcWrprRecSttv.digitalCampaign.Product_Type__c='DMA Addressable';
    dcWrprRecSttv.digitalCampaign.AdsE_Genre_s__c =dcList[0].AdsE_Genre_s__c;
    dcWrprRecSttv.digitalCampaign.Spectrum_Reach_Zones__c =dcList[0].Spectrum_Reach_Zones__c;
    dcWrprRecSttv.digitalCampaign.DMAs__c =dcList[0].DMAs__c;      
    dcWrprRecSttv.digitalCampaign.Desired_Budget__c =dcList[0].Desired_Budget__c;
    dcWrprRecSttv.digitalCampaign.Campaign_Start_Date__c =dcList[0].Campaign_Start_Date__c;
    dcWrprRecSttv.digitalCampaign.Campaign_End_Date__c =dcList[0].Campaign_End_Date__c;
    dcWrprRecSttv.digitalCampaign.AdsE_Platform_s__c ='All Platforms';
    dcWrprRecSttv.digitalCampaign.Opportunity__c = dcList[0].Opportunity__c;
    dcWrprRecSttv.digitalCampaign.Total_Impressions__c =dcList[0].Total_Impressions__c; 
    dcWrprRecSttv.digitalCampaign.Gross_Campaign_Cost__c = 6000.00;

    dcWrprRecSttv.digitalCampaign.Zip_Codes__c ='';      

    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper dcWrprRecDisplay = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper(); 
    dcWrprRecDisplay.isDraftPlan = TRUE;
    dcWrprRecDisplay.product = 'Display';
    dcWrprRecDisplay.digitalCampaign = new Digital_Campaign__c();
    dcWrprRecDisplay.digitalCampaign.Proposal__c =dcList[0].Proposal__c;
    dcWrprRecDisplay.digitalCampaign.Campaign_Name__c = dcList[0].Campaign_Name__c;
    dcWrprRecDisplay.digitalCampaign.AudienceTrak_Proposal_ID__c = '12356';
    dcWrprRecDisplay.digitalCampaign.Campaign_Start_Date__c =dcList[0].Campaign_Start_Date__c;
    dcWrprRecDisplay.digitalCampaign.Campaign_End_Date__c =dcList[0].Campaign_End_Date__c;
    dcWrprRecDisplay.digitalCampaign.Total_Impressions__c =dcList[0].Total_Impressions__c; 
    dcWrprRecDisplay.digitalCampaign.Gross_Campaign_Cost__c = 6000.00;

    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper dcWrprRecPreroll = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper(); 
    dcWrprRecPreroll.isDraftPlan = TRUE;
    dcWrprRecPreroll.product = 'Pre_roll';
    dcWrprRecPreroll.digitalCampaign = new Digital_Campaign__c();
    dcWrprRecPreroll.digitalCampaign.Proposal__c =dcList[0].Proposal__c;
    dcWrprRecPreroll.digitalCampaign.Campaign_Name__c = dcList[0].Campaign_Name__c;
    dcWrprRecPreroll.digitalCampaign.AudienceTrak_Proposal_ID__c = '12357';
    dcWrprRecPreroll.digitalCampaign.Campaign_Start_Date__c =dcList[0].Campaign_Start_Date__c;
    dcWrprRecPreroll.digitalCampaign.Campaign_End_Date__c =dcList[0].Campaign_End_Date__c;
    dcWrprRecPreroll.digitalCampaign.Total_Impressions__c =dcList[0].Total_Impressions__c; 
    dcWrprRecPreroll.digitalCampaign.Gross_Campaign_Cost__c = 6000.00; 

    List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper> dcWrapList = new List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper>{dcWrprRecSttv,dcWrprRecDisplay,dcWrprRecPreroll};
    incmngWrpr.digitalCampaignList = dcWrapList;        
    ThirdPartyDigitalInvReqServices.OutgoingResponseWrapper outWrpr = ThirdPartyDigitalInvReqServices.doPost(incmngWrpr);
    System.debug('outWrpr>>>>>'+outWrpr);           
    System.assert(outWrpr.successDigitalCampaigns != null); 
    System.assert(outWrpr.isSuccess);

    //GET DIR service
    Id dirId = dcList[0].Id;    
    RestRequest req = new RestRequest();          
    req.requestURI = '/services/apexrest/SpectrumReachDIRServices/' + dirId;
    req.httpMethod = 'GET';
    RestContext.request = req;
    ThirdPartyDigitalInvReqServices.ResponseWrapper resp1=ThirdPartyDigitalInvReqServices.doGet();
    System.assert(resp1.isSuccess);
    Digital_Campaign__c digitalCampaignRec = [SELECT Id, Zip_Codes__c, CustomZipCode__c FROM Digital_Campaign__c WHERE Campaign_Name__c = :dcList[0].Campaign_Name__c AND Source__c='Audience Track' LIMIT 1];
    System.debug('digitalCampaignRec>>>'+digitalCampaignRec);
    System.assert(!digitalCampaignRec.CustomZipCode__c); 
    //System.assertEquals(digitalCampaignRec.Zip_Codes__c, '31010, 31015, 31512');
    
    Test.stopTest();
  }

  static testMethod void testGetDIRMandatoryRecId() 
  {     
    String recordId;
    RestRequest req = new RestRequest();          
    req.requestURI = '/services/apexrest/SpectrumReachDIRServices/' + recordId;
    req.httpMethod = 'GET';
    RestContext.request = req;
    Test.startTest();
    ThirdPartyDigitalInvReqServices.ResponseWrapper resp1=ThirdPartyDigitalInvReqServices.doGet();
    System.assert(!resp1.isSuccess);
    System.assertEquals(null, resp1.digitalCampaignData);   
    System.assertEquals(System.Label.Digital_Campaign_Id_Mandatory, resp1.message);
    Test.stopTest();
  }

  static testMethod void testGetDIRInvalidRecId() 
  {
    String recordId = '12345';
    RestRequest req = new RestRequest();          
    req.requestURI = '/services/apexrest/SpectrumReachDIRServices/' + recordId;
    req.httpMethod = 'GET';
    RestContext.request = req;
    Test.startTest();
    ThirdPartyDigitalInvReqServices.ResponseWrapper resp=ThirdPartyDigitalInvReqServices.doGet();
    System.assert(!resp.isSuccess);
    System.assertEquals(null, resp.digitalCampaignData);
    System.assertEquals(System.Label.No_Digital_Campaign_Error, resp.message);
    Test.stopTest();
  }


  static testMethod void testInvalidDMAToCreateDIR() 
  { 
    List<Digital_Campaign__c> dcList = [Select Id, Campaign_Name__c, Opportunity__c, Proposal__c, Product_Type__c, Campaign_End_Date__c, Campaign_Start_Date__c, Total_Impressions__c,AdsE_Genre_s__c, Desired_Budget__c FROM Digital_Campaign__c WHERE Campaign_Name__c = 'Test']; 
    System.assert(dcList.size()>0);

    List<Zipcode_Mapping__c> zcList = [SELECT Id, Nielsen_DMA_Name__c, SR_Zone_Name__c FROM Zipcode_Mapping__c LIMIT 1];
    System.assert(zcList.size()>0);
        
    Test.startTest(); 
    //Create DIR service
    ThirdPartyDigitalInvReqServices.IncomingRequestWrapper incmngWrpr = new ThirdPartyDigitalInvReqServices.IncomingRequestWrapper();         
    incmngWrpr.source = Label.Audience_Track;             
    incmngWrpr.userID = [SELECT Id FROM User WHERE lastname = 'Testing' LIMIT 1].Id;     
    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper dcWrprRecSttv = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper(); 
    dcWrprRecSttv.isDraftPlan = TRUE;
    dcWrprRecSttv.product = 'STTV';
    dcWrprRecSttv.digitalCampaign = new Digital_Campaign__c();
    dcWrprRecSttv.digitalCampaign.Proposal__c =dcList[0].Proposal__c;
    dcWrprRecSttv.digitalCampaign.Campaign_Name__c = dcList[0].Campaign_Name__c;
    dcWrprRecSttv.digitalCampaign.Product_Type__c='DMA Addressable';
    dcWrprRecSttv.digitalCampaign.AdsE_Genre_s__c =dcList[0].AdsE_Genre_s__c;
    dcWrprRecSttv.digitalCampaign.Spectrum_Reach_Zones__c ='';
    dcWrprRecSttv.digitalCampaign.DMAs__c = 'testDMA';     
    dcWrprRecSttv.digitalCampaign.Desired_Budget__c =dcList[0].Desired_Budget__c;
    dcWrprRecSttv.digitalCampaign.Campaign_Start_Date__c =dcList[0].Campaign_Start_Date__c;
    dcWrprRecSttv.digitalCampaign.Campaign_End_Date__c =dcList[0].Campaign_End_Date__c;
    dcWrprRecSttv.digitalCampaign.AdsE_Platform_s__c ='All Platforms';
    dcWrprRecSttv.digitalCampaign.Opportunity__c = dcList[0].Opportunity__c;
    dcWrprRecSttv.digitalCampaign.Total_Impressions__c =dcList[0].Total_Impressions__c;  
    dcWrprRecSttv.digitalCampaign.Gross_Campaign_Cost__c = 6000.00; 

    List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper> dcWrapList = new List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper>{dcWrprRecSttv};
    incmngWrpr.digitalCampaignList = dcWrapList;        
    ThirdPartyDigitalInvReqServices.OutgoingResponseWrapper outWrpr = ThirdPartyDigitalInvReqServices.doPost(incmngWrpr);
    System.debug('outWrpr>>>>>'+outWrpr);
    System.assert(outWrpr.successDigitalCampaigns == null);  
    System.assert(!outWrpr.isSuccess);      
    System.assertEquals(System.Label.DMA_Not_Found_ZipCode_Mapping+'testDMA', outWrpr.failedDigitalCampaigns.get(dcList[0].Campaign_Name__c));  // Sridhar commented
  //  System.assertEquals(System.Label.Required_Fields_missing_for_Digital_Campaign, outWrpr.failedDigitalCampaigns.get(dcList[0].Campaign_Name__c)); // Sridhar added
    Test.stopTest();   
  }

  static testMethod void testNoDataToCreateDIR() 
  {
    ThirdPartyDigitalInvReqServices.IncomingRequestWrapper incmngWrpr = new ThirdPartyDigitalInvReqServices.IncomingRequestWrapper(); 
    incmngWrpr.source = System.Label.Audience_Track;
    
    ThirdPartyDigitalInvReqServices.OutgoingResponseWrapper outWrpr = ThirdPartyDigitalInvReqServices.doPost(incmngWrpr); 
    System.assertEquals(outWrpr.successDigitalCampaigns, null);  
    System.assert(!outWrpr.isSuccess);      
    System.assertEquals('Failure', outWrpr.message);   
  }


  static testMethod void testInvalidSRZonesToCreateDIR() 
  {
    List<Digital_Campaign__c> dcList = [Select Id, Campaign_Name__c, Opportunity__c, Proposal__c, Product_Type__c, Campaign_End_Date__c, Campaign_Start_Date__c, Total_Impressions__c,AdsE_Genre_s__c, Desired_Budget__c FROM Digital_Campaign__c WHERE Campaign_Name__c = 'Test2'];  
    System.assert(dcList.size()>0);

    List<Zipcode_Mapping__c> zcList = [SELECT Id, Nielsen_DMA_Name__c, SR_Zone_Name__c FROM Zipcode_Mapping__c LIMIT 1];
    System.assert(zcList.size()>0);
      
    Test.startTest(); 
    //Create DIR service
    ThirdPartyDigitalInvReqServices.IncomingRequestWrapper incmngWrpr = new ThirdPartyDigitalInvReqServices.IncomingRequestWrapper();         
    incmngWrpr.source = Label.Audience_Track;             
    incmngWrpr.userID = [SELECT Id FROM User WHERE lastname = 'Testing' LIMIT 1].Id;     
    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper dcWrprRecSttv = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper(); 
    dcWrprRecSttv.isDraftPlan = TRUE;
    dcWrprRecSttv.product = 'STTV';
    dcWrprRecSttv.digitalCampaign = new Digital_Campaign__c();
    dcWrprRecSttv.digitalCampaign.Proposal__c =dcList[0].Proposal__c;
    dcWrprRecSttv.digitalCampaign.Campaign_Name__c = dcList[0].Campaign_Name__c;
    dcWrprRecSttv.digitalCampaign.Product_Type__c='DMA Addressable';
    dcWrprRecSttv.digitalCampaign.AdsE_Genre_s__c =dcList[0].AdsE_Genre_s__c;
    dcWrprRecSttv.digitalCampaign.Spectrum_Reach_Zones__c ='testZone';             
    dcWrprRecSttv.digitalCampaign.Desired_Budget__c =dcList[0].Desired_Budget__c;
    dcWrprRecSttv.digitalCampaign.Campaign_Start_Date__c =dcList[0].Campaign_Start_Date__c;
    dcWrprRecSttv.digitalCampaign.Campaign_End_Date__c =dcList[0].Campaign_End_Date__c;
    dcWrprRecSttv.digitalCampaign.AdsE_Platform_s__c ='All Platforms';
    dcWrprRecSttv.digitalCampaign.Opportunity__c = dcList[0].Opportunity__c;
    dcWrprRecSttv.digitalCampaign.Total_Impressions__c =dcList[0].Total_Impressions__c; 
    dcWrprRecSttv.digitalCampaign.Gross_Campaign_Cost__c = 6000.00;  
  
    List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper> dcWrapList = new List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper>{dcWrprRecSttv};
    incmngWrpr.digitalCampaignList = dcWrapList;        
    ThirdPartyDigitalInvReqServices.OutgoingResponseWrapper outWrpr = ThirdPartyDigitalInvReqServices.doPost(incmngWrpr);
    System.debug('outWrpr>>>>>'+outWrpr); 
    System.assertEquals(outWrpr.successDigitalCampaigns, null); 
    System.assert(!outWrpr.isSuccess);       
    System.assertEquals(System.Label.SRZone_Not_Found_In_ZipCode_Mapping+'testZone', outWrpr.failedDigitalCampaigns.get(dcList[0].Campaign_Name__c));  // Sridhar commented
  //  System.assertEquals(System.Label.Required_Fields_missing_for_Digital_Campaign, outWrpr.failedDigitalCampaigns.get(dcList[0].Campaign_Name__c)); // Sridhar added
    Test.stopTest(); 
  }

  static testMethod void testNoDataInZipCodeMapping() 
  {
    Test.startTest();
    List<Digital_Campaign__c> dcList = [Select Id, Campaign_Name__c, Opportunity__c, Proposal__c, Product_Type__c, Campaign_End_Date__c, Campaign_Start_Date__c, Total_Impressions__c,AdsE_Genre_s__c, Desired_Budget__c, Spectrum_Reach_Zones__c FROM Digital_Campaign__c WHERE Campaign_Name__c = 'Test2']; //Desired_CPM__c, 
    System.assert(dcList.size()>0);

    List<Zipcode_Mapping__c> zcList = [SELECT Id, Nielsen_DMA_Name__c, SR_Zone_Name__c FROM Zipcode_Mapping__c LIMIT 1];
    Database.delete(zcList);
    zcList = [SELECT Id FROM Zipcode_Mapping__c ];
    System.assertEquals(0, zcList.size());

  //  Test.startTest(); 
    //Create DIR service
    ThirdPartyDigitalInvReqServices.IncomingRequestWrapper incmngWrpr = new ThirdPartyDigitalInvReqServices.IncomingRequestWrapper();         
    incmngWrpr.source = Label.Audience_Track;             
    incmngWrpr.userID = [SELECT Id FROM User WHERE lastname = 'Testing' LIMIT 1].Id;     
    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper dcWrprRecSttv = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper(); 
    dcWrprRecSttv.isDraftPlan = TRUE;
    dcWrprRecSttv.product = 'STTV';
    dcWrprRecSttv.digitalCampaign = new Digital_Campaign__c();
    dcWrprRecSttv.digitalCampaign.Proposal__c =dcList[0].Proposal__c;
    dcWrprRecSttv.digitalCampaign.Campaign_Name__c = dcList[0].Campaign_Name__c;
    dcWrprRecSttv.digitalCampaign.Product_Type__c='DMA Addressable';
    dcWrprRecSttv.digitalCampaign.AdsE_Genre_s__c =dcList[0].AdsE_Genre_s__c;
    dcWrprRecSttv.digitalCampaign.Spectrum_Reach_Zones__c =dcList[0].Spectrum_Reach_Zones__c;            
    dcWrprRecSttv.digitalCampaign.Desired_Budget__c =dcList[0].Desired_Budget__c;
    dcWrprRecSttv.digitalCampaign.Campaign_Start_Date__c =dcList[0].Campaign_Start_Date__c;
    dcWrprRecSttv.digitalCampaign.Campaign_End_Date__c =dcList[0].Campaign_End_Date__c;        
    dcWrprRecSttv.digitalCampaign.Opportunity__c = dcList[0].Opportunity__c;
    dcWrprRecSttv.digitalCampaign.Total_Impressions__c =dcList[0].Total_Impressions__c; 
    dcWrprRecSttv.digitalCampaign.AdsE_Platform_s__c ='All Platforms';
    dcWrprRecSttv.digitalCampaign.Gross_Campaign_Cost__c = 6000.00;  
  
    List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper> dcWrapList = new List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper>{dcWrprRecSttv};
    incmngWrpr.digitalCampaignList = dcWrapList;        
    ThirdPartyDigitalInvReqServices.OutgoingResponseWrapper outWrpr = ThirdPartyDigitalInvReqServices.doPost(incmngWrpr);
    Test.stopTest();
    System.debug('outWrpr>>>>>'+outWrpr); 
    System.assertEquals(outWrpr.successDigitalCampaigns, null); 
    System.assert(!outWrpr.isSuccess);
    System.assertEquals(System.Label.No_data_found_in_ZipCode_Mapping, outWrpr.failedDigitalCampaigns.get(dcList[0].Campaign_Name__c));   
  }  

  static testMethod void testUpdateDIR() 
  { 
    Test.startTest();
    List<Digital_Campaign__c> dcList = [Select Id, Campaign_Name__c, Opportunity__c, Proposal__c, Product_Type__c, Campaign_End_Date__c, Campaign_Start_Date__c, Total_Impressions__c,AdsE_Genre_s__c, Desired_Budget__c, DMAs__c, Spectrum_Reach_Zones__c FROM Digital_Campaign__c WHERE Campaign_Name__c = 'Test']; 
    System.assert(dcList.size()>0);   

    List<Zipcode_Mapping__c> zcList = [SELECT Id, Nielsen_DMA_Name__c, SR_Zone_Name__c FROM Zipcode_Mapping__c LIMIT 1];

    System.assert(zcList.size()>0);

    //Create DIR service
    ThirdPartyDigitalInvReqServices.IncomingRequestWrapper incmngWrpr = new ThirdPartyDigitalInvReqServices.IncomingRequestWrapper();         
    incmngWrpr.source = Label.Audience_Track;             
    incmngWrpr.userID = [SELECT Id FROM User WHERE lastname = 'Testing' LIMIT 1].Id;     
    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper dcWrprRecSttv = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper(); 
    dcWrprRecSttv.isDraftPlan = TRUE;
    dcWrprRecSttv.product = 'STTV';
    dcWrprRecSttv.digitalCampaign = new Digital_Campaign__c();
    dcWrprRecSttv.digitalCampaign.Proposal__c =dcList[0].Proposal__c;
    dcWrprRecSttv.digitalCampaign.Campaign_Name__c = dcList[0].Campaign_Name__c;
    dcWrprRecSttv.digitalCampaign.Product_Type__c='DMA Addressable';
    dcWrprRecSttv.digitalCampaign.AdsE_Genre_s__c =dcList[0].AdsE_Genre_s__c;   
    dcWrprRecSttv.digitalCampaign.DMAs__c =dcList[0].DMAs__c;      
    dcWrprRecSttv.digitalCampaign.Desired_Budget__c =dcList[0].Desired_Budget__c;
    dcWrprRecSttv.digitalCampaign.Campaign_Start_Date__c =dcList[0].Campaign_Start_Date__c;
    dcWrprRecSttv.digitalCampaign.Campaign_End_Date__c =dcList[0].Campaign_End_Date__c;     
    dcWrprRecSttv.digitalCampaign.Opportunity__c = dcList[0].Opportunity__c;
    dcWrprRecSttv.digitalCampaign.Total_Impressions__c =dcList[0].Total_Impressions__c;
    dcWrprRecSttv.digitalCampaign.AdsE_Platform_s__c ='All Platforms';
    dcWrprRecSttv.digitalCampaign.Gross_Campaign_Cost__c = 6000.00;    
    dcWrprRecSttv.digitalCampaign.Zip_Codes__c ='';      

    List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper> dcWrapList = new List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper>{dcWrprRecSttv};
    incmngWrpr.digitalCampaignList = dcWrapList;        
    ThirdPartyDigitalInvReqServices.OutgoingResponseWrapper outWrpr = ThirdPartyDigitalInvReqServices.doPost(incmngWrpr);
    System.debug('outWrpr>>>>>'+outWrpr);           
    System.assert(outWrpr.successDigitalCampaigns != null); 
    System.assert(outWrpr.isSuccess);
    System.assertEquals(ThirdPartyDigitalInvReqServices.STATUS_SUCCESS, outWrpr.message); 

    //Update DIR        
    ThirdPartyDigitalInvReqServices.IncomingRequestWrapper incmngWrpr2 = new ThirdPartyDigitalInvReqServices.IncomingRequestWrapper();
    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper dcWrprRecSttv1 = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper();        
   
    dcWrprRecSttv1 = dcWrprRecSttv;  
    dcWrprRecSttv1.digitalCampaign.DMAs__c = '';
    dcWrprRecSttv1.digitalCampaign.Spectrum_Reach_Zones__c =zcList[0].SR_Zone_Name__c;
    List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper> dcWrapList1 = new List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper>{dcWrprRecSttv1};
    incmngWrpr2.digitalCampaignList = dcWrapList1;
    
    ThirdPartyDigitalInvReqServices.OutgoingResponseWrapper outWrpr2 = ThirdPartyDigitalInvReqServices.doPost(incmngWrpr2);  
    System.assertNotEquals(outWrpr2.successDigitalCampaigns, null);
    System.assert(outWrpr2.isSuccess);      
    System.assertEquals(ThirdPartyDigitalInvReqServices.STATUS_SUCCESS, outWrpr2.message);
    Test.stopTest();   
  }

  static testMethod void testDMAorSRZoneRqrdToUpdateDIR() 
  { 

    Test.startTest();
    List<Digital_Campaign__c> dcList = [Select Id, Campaign_Name__c, Opportunity__c, Proposal__c, Product_Type__c, Campaign_End_Date__c, Campaign_Start_Date__c, Total_Impressions__c,AdsE_Genre_s__c, Desired_Budget__c, DMAs__c, Spectrum_Reach_Zones__c FROM Digital_Campaign__c WHERE Campaign_Name__c = 'Test']; 
    System.assert(dcList.size()>0);   
     
    //Create DIR service
     ThirdPartyDigitalInvReqServices.IncomingRequestWrapper incmngWrpr = new ThirdPartyDigitalInvReqServices.IncomingRequestWrapper();         
    incmngWrpr.source = Label.Audience_Track;             
    incmngWrpr.userID = [SELECT Id FROM User WHERE lastname = 'Testing' LIMIT 1].Id;     
    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper dcWrprRecSttv = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper(); 
    dcWrprRecSttv.isDraftPlan = TRUE;
    dcWrprRecSttv.product = 'STTV';
    dcWrprRecSttv.digitalCampaign = new Digital_Campaign__c();
    dcWrprRecSttv.digitalCampaign.Proposal__c =dcList[0].Proposal__c;
    dcWrprRecSttv.digitalCampaign.Campaign_Name__c = dcList[0].Campaign_Name__c;
    dcWrprRecSttv.digitalCampaign.Product_Type__c='DMA Addressable';
    dcWrprRecSttv.digitalCampaign.AdsE_Genre_s__c =dcList[0].AdsE_Genre_s__c;   
    dcWrprRecSttv.digitalCampaign.DMAs__c =dcList[0].DMAs__c;      
    dcWrprRecSttv.digitalCampaign.Desired_Budget__c =dcList[0].Desired_Budget__c;
    dcWrprRecSttv.digitalCampaign.Campaign_Start_Date__c =dcList[0].Campaign_Start_Date__c;
    dcWrprRecSttv.digitalCampaign.Campaign_End_Date__c =dcList[0].Campaign_End_Date__c;     
    dcWrprRecSttv.digitalCampaign.Opportunity__c = dcList[0].Opportunity__c;
    dcWrprRecSttv.digitalCampaign.Total_Impressions__c =dcList[0].Total_Impressions__c;
    dcWrprRecSttv.digitalCampaign.AdsE_Platform_s__c ='All Platforms';
    dcWrprRecSttv.digitalCampaign.Gross_Campaign_Cost__c = 6000.00;     
    dcWrprRecSttv.digitalCampaign.Zip_Codes__c ='';      

    List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper> dcWrapList = new List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper>{dcWrprRecSttv};
    incmngWrpr.digitalCampaignList = dcWrapList;        
    ThirdPartyDigitalInvReqServices.OutgoingResponseWrapper outWrpr = ThirdPartyDigitalInvReqServices.doPost(incmngWrpr);
    System.debug('outWrpr>>>>>'+outWrpr);           
    System.assertNotEquals(outWrpr.successDigitalCampaigns, null); 
    System.assert(outWrpr.isSuccess);
    System.assertEquals(ThirdPartyDigitalInvReqServices.STATUS_SUCCESS, outWrpr.message);

    //Update DIR        
    ThirdPartyDigitalInvReqServices.IncomingRequestWrapper incmngWrpr2 = new ThirdPartyDigitalInvReqServices.IncomingRequestWrapper();             
    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper dcWrprRecSttv1 = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper(); 
    
    dcWrprRecSttv1 = dcWrprRecSttv;
    System.debug('digicampaignID>>>>>'+dcWrprRecSttv.digitalCampaign.Id);     
    dcWrprRecSttv1.digitalCampaign.Spectrum_Reach_Zones__c ='test SRZone';
    List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper> dcWrapList1 = new List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper>{dcWrprRecSttv1};
    incmngWrpr2.digitalCampaignList = dcWrapList1;
    
    ThirdPartyDigitalInvReqServices.OutgoingResponseWrapper outWrpr2 = ThirdPartyDigitalInvReqServices.doPost(incmngWrpr2);
    System.assert(outWrpr2.successDigitalCampaigns == null);  
    System.assert(!outWrpr2.isSuccess);      
    System.assertEquals(System.Label.SRZones_or_DMA_should_have_value, outWrpr2.failedDigitalCampaigns.get(dcList[0].Campaign_Name__c)); 
    Test.stopTest();
  }

  static testMethod void testDIRCannotBeReparented() 
  { 
    Test.startTest();
    List<Digital_Campaign__c> dcList = [Select Id, Campaign_Name__c, Opportunity__c, Proposal__c, Product_Type__c, Campaign_End_Date__c, Campaign_Start_Date__c, Total_Impressions__c,AdsE_Genre_s__c, Desired_Budget__c, DMAs__c FROM Digital_Campaign__c WHERE Campaign_Name__c = 'Test']; 
    System.assert(dcList.size()>0);
     
    //Create DIR service
    ThirdPartyDigitalInvReqServices.IncomingRequestWrapper incmngWrpr = new ThirdPartyDigitalInvReqServices.IncomingRequestWrapper();         
    incmngWrpr.source = Label.Audience_Track;             
    incmngWrpr.userID = [SELECT Id FROM User WHERE lastname = 'Testing' LIMIT 1].Id;     
    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper dcWrprRecSttv = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper(); 
    dcWrprRecSttv.isDraftPlan = TRUE;
    dcWrprRecSttv.product = 'STTV';
    dcWrprRecSttv.digitalCampaign = new Digital_Campaign__c();
    dcWrprRecSttv.digitalCampaign.Proposal__c =dcList[0].Proposal__c;
    dcWrprRecSttv.digitalCampaign.Campaign_Name__c = dcList[0].Campaign_Name__c;
    dcWrprRecSttv.digitalCampaign.Product_Type__c='DMA Addressable';
    dcWrprRecSttv.digitalCampaign.AdsE_Genre_s__c =dcList[0].AdsE_Genre_s__c;      
    dcWrprRecSttv.digitalCampaign.DMAs__c =dcList[0].DMAs__c;      
    dcWrprRecSttv.digitalCampaign.Desired_Budget__c =dcList[0].Desired_Budget__c;
    dcWrprRecSttv.digitalCampaign.Campaign_Start_Date__c =dcList[0].Campaign_Start_Date__c;
    dcWrprRecSttv.digitalCampaign.Campaign_End_Date__c =dcList[0].Campaign_End_Date__c;       
    dcWrprRecSttv.digitalCampaign.Opportunity__c = dcList[0].Opportunity__c;
    dcWrprRecSttv.digitalCampaign.Total_Impressions__c =dcList[0].Total_Impressions__c;  
    dcWrprRecSttv.digitalCampaign.AdsE_Platform_s__c ='All Platforms';
    dcWrprRecSttv.digitalCampaign.Gross_Campaign_Cost__c = 6000.00;   
    dcWrprRecSttv.digitalCampaign.Zip_Codes__c ='';      
   
    List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper> dcWrapList = new List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper>{dcWrprRecSttv};
    incmngWrpr.digitalCampaignList = dcWrapList;        
    ThirdPartyDigitalInvReqServices.OutgoingResponseWrapper outWrpr = ThirdPartyDigitalInvReqServices.doPost(incmngWrpr);
    System.debug('outWrpr>>>>>'+outWrpr);            
    System.assertNotEquals(outWrpr.successDigitalCampaigns, null); 
    System.assert(outWrpr.isSuccess);
    System.assertEquals(ThirdPartyDigitalInvReqServices.STATUS_SUCCESS, outWrpr.message);

    //Update DIR
    Id propId = [SELECT Id,Name FROM Proposal__c WHERE Active__c=TRUE AND Name='Test Proposal4' LIMIT 1].Id;
    ThirdPartyDigitalInvReqServices.IncomingRequestWrapper incmngWrpr2 = new ThirdPartyDigitalInvReqServices.IncomingRequestWrapper();             
    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper dcWrprRecSttv1 = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper();
        
    dcWrprRecSttv1 = dcWrprRecSttv;
    dcWrprRecSttv1.digitalCampaign.Proposal__c = propId;
    List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper> dcWrapList1 = new List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper>{dcWrprRecSttv1};
    incmngWrpr2.digitalCampaignList = dcWrapList1;
    
    ThirdPartyDigitalInvReqServices.OutgoingResponseWrapper outWrpr2 = ThirdPartyDigitalInvReqServices.doPost(incmngWrpr2);
    System.assert(outWrpr2.successDigitalCampaigns == null);  
    System.assert(!outWrpr2.isSuccess); 
    System.debug ('outWrpr2 615>>>>'+outWrpr2);
    System.debug ('failedDigitalCampaigns 616>>>>'+outWrpr2.failedDigitalCampaigns);
    System.assertEquals(System.Label.Digital_Campaign_cannot_be_Reparented_with_different_Proposal, outWrpr2.failedDigitalCampaigns.get(dcList[0].Campaign_Name__c)); 
    Test.stopTest();   
  }

  /*static testMethod void testAllowDIRUpdateInDraftPlanStatus()
  { 
    Test.startTest();
    List<Digital_Campaign__c> dcList = [Select Id, Campaign_Name__c, Opportunity__c, Proposal__c, Product_Type__c, Campaign_End_Date__c, Campaign_Start_Date__c, Total_Impressions__c,AdsE_Genre_s__c, Desired_Budget__c, DMAs__c, Spectrum_Reach_Zones__c FROM Digital_Campaign__c WHERE Campaign_Name__c = 'Test']; 
    System.assert(dcList.size()>0);   
     
    //Create DIR service
    ThirdPartyDigitalInvReqServices.IncomingRequestWrapper incmngWrpr = new ThirdPartyDigitalInvReqServices.IncomingRequestWrapper();         
    incmngWrpr.source = Label.Audience_Track;             
    incmngWrpr.userID = [SELECT Id FROM User WHERE lastname = 'Testing' LIMIT 1].Id;     
    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper dcWrprRecSttv = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper(); 
    dcWrprRecSttv.isDraftPlan = FALSE;
    dcWrprRecSttv.product = 'STTV';
    dcWrprRecSttv.digitalCampaign = new Digital_Campaign__c();
    dcWrprRecSttv.digitalCampaign.Proposal__c =dcList[0].Proposal__c;
    dcWrprRecSttv.digitalCampaign.Campaign_Name__c = dcList[0].Campaign_Name__c;
    dcWrprRecSttv.digitalCampaign.Product_Type__c='DMA Addressable';
    dcWrprRecSttv.digitalCampaign.AdsE_Genre_s__c =dcList[0].AdsE_Genre_s__c;      
    dcWrprRecSttv.digitalCampaign.DMAs__c =dcList[0].DMAs__c;      
    dcWrprRecSttv.digitalCampaign.Desired_Budget__c =dcList[0].Desired_Budget__c;
    dcWrprRecSttv.digitalCampaign.Campaign_Start_Date__c =dcList[0].Campaign_Start_Date__c;
    dcWrprRecSttv.digitalCampaign.Campaign_End_Date__c =dcList[0].Campaign_End_Date__c;       
    dcWrprRecSttv.digitalCampaign.Opportunity__c = dcList[0].Opportunity__c;
    dcWrprRecSttv.digitalCampaign.Total_Impressions__c =dcList[0].Total_Impressions__c;
    dcWrprRecSttv.digitalCampaign.AdsE_Platform_s__c ='All Platforms'; 
    dcWrprRecSttv.digitalCampaign.Gross_Campaign_Cost__c = 6000.00;    
    dcWrprRecSttv.digitalCampaign.Zip_Codes__c =''; 

    List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper> dcWrapList = new List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper>{dcWrprRecSttv};
    incmngWrpr.digitalCampaignList = dcWrapList;        
    ThirdPartyDigitalInvReqServices.OutgoingResponseWrapper outWrpr = ThirdPartyDigitalInvReqServices.doPost(incmngWrpr);          
    System.assertNotEquals(outWrpr.successDigitalCampaigns, null); 
    System.assert(outWrpr.isSuccess);      
    System.assertEquals(ThirdPartyDigitalInvReqServices.STATUS_SUCCESS, outWrpr.message); 

    //Update DIR
    ThirdPartyDigitalInvReqServices.IncomingRequestWrapper incmngWrpr2 = new ThirdPartyDigitalInvReqServices.IncomingRequestWrapper();             
    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper dcWrprRecSttv1 = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper();
   
    dcWrprRecSttv1 = dcWrprRecSttv;
    List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper> dcWrapList1 = new List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper>{dcWrprRecSttv1};
    incmngWrpr2.digitalCampaignList = dcWrapList1;        
    ThirdPartyDigitalInvReqServices.OutgoingResponseWrapper outWrpr2 = ThirdPartyDigitalInvReqServices.doPost(incmngWrpr2);
    System.assert(outWrpr2.successDigitalCampaigns == null);  
    System.assert(!outWrpr2.isSuccess); 
    System.assertEquals(System.Label.DCRecord_can_be_edited_in_Draft_Plan_Status, outWrpr2.failedDigitalCampaigns.get(dcList[0].Campaign_Name__c)); 
    Test.stopTest();   
  }*/

  static testMethod void testInvalidSource()
  {
    Test.startTest(); 
    ThirdPartyDigitalInvReqServices.IncomingRequestWrapper incmngWrpr = new ThirdPartyDigitalInvReqServices.IncomingRequestWrapper();         
    incmngWrpr.source = Label.Audience_App;             
    incmngWrpr.userID = [SELECT Id FROM User WHERE lastname = 'Testing' LIMIT 1].Id; 

    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper dcWrprRecSttv = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper(); 

    List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper> dcWrapList = new List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper>{dcWrprRecSttv};
    incmngWrpr.digitalCampaignList = dcWrapList;        
    ThirdPartyDigitalInvReqServices.OutgoingResponseWrapper outWrpr = ThirdPartyDigitalInvReqServices.doPost(incmngWrpr);
          
    System.assert(!outWrpr.isSuccess);   
    System.assertEquals(outWrpr.successDigitalCampaigns, null); 
    System.assertEquals(System.Label.Invalid_Source + System.Label.Audience_App, outWrpr.message); 
    Test.stopTest();  
  }


  static testMethod void testNegativeScenariosToCreateDIR() 
  { 
    Test.startTest();

    List<Digital_Campaign__c> dcList = [Select Id, Campaign_Name__c, Opportunity__c, Product_Type__c, Campaign_End_Date__c, Campaign_Start_Date__c, Total_Impressions__c,AdsE_Genre_s__c, Desired_Budget__c, Spectrum_Reach_Zones__c FROM Digital_Campaign__c WHERE Campaign_Name__c = 'Test2']; 
    System.assert(dcList.size()>0);

    Proposal__c prop = [SELECT Id FROM Proposal__c WHERE Name='Test Proposal3'];
    Id propId = [SELECT Id FROM Proposal__c WHERE Active__c=FALSE].Id;

    ThirdPartyDigitalInvReqServices.IncomingRequestWrapper incmngWrpr = new ThirdPartyDigitalInvReqServices.IncomingRequestWrapper();         
    incmngWrpr.source = Label.Audience_Track;             
    incmngWrpr.userID = [SELECT Id FROM User WHERE lastname = 'Testing' LIMIT 1].Id;     

    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper invalidProd = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper(); 
    invalidProd.isDraftPlan = TRUE;
    invalidProd.product = 'InvalidProduct';        
    invalidProd.digitalCampaign = new Digital_Campaign__c();        
    invalidProd.digitalCampaign.Campaign_Name__c = 'Test1';

    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper emptyProd = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper(); 
    emptyProd.isDraftPlan = TRUE;
    emptyProd.product = '';        
    emptyProd.digitalCampaign = new Digital_Campaign__c();        
    emptyProd.digitalCampaign.Campaign_Name__c = 'Test2';

    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper noProposal = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper(); 
    noProposal.isDraftPlan = TRUE;
    noProposal.product = 'Display';        
    noProposal.digitalCampaign = new Digital_Campaign__c();        
    noProposal.digitalCampaign.Campaign_Name__c = 'Test3';
    noProposal.digitalCampaign.Proposal__c = null;

    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper invalidSTTV = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper(); 
    invalidSTTV.isDraftPlan = TRUE;
    invalidSTTV.product = 'STTV';        
    invalidSTTV.digitalCampaign = new Digital_Campaign__c();        
    invalidSTTV.digitalCampaign.Campaign_Name__c = 'Test4';    
       
    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper dcForoppBudgetProp = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper(); 
    dcForoppBudgetProp.isDraftPlan = TRUE;
    dcForoppBudgetProp.product = 'STTV';
    dcForoppBudgetProp.digitalCampaign = new Digital_Campaign__c();
    dcForoppBudgetProp.digitalCampaign.Proposal__c =prop.Id;
    dcForoppBudgetProp.digitalCampaign.Campaign_Name__c = 'Test5';
    dcForoppBudgetProp.digitalCampaign.Product_Type__c='DMA Addressable';
    dcForoppBudgetProp.digitalCampaign.AdsE_Genre_s__c =dcList[0].AdsE_Genre_s__c;
    dcForoppBudgetProp.digitalCampaign.Spectrum_Reach_Zones__c =dcList[0].Spectrum_Reach_Zones__c;
    dcForoppBudgetProp.digitalCampaign.Desired_Budget__c =dcList[0].Desired_Budget__c;
    dcForoppBudgetProp.digitalCampaign.Campaign_Start_Date__c =dcList[0].Campaign_Start_Date__c;
    dcForoppBudgetProp.digitalCampaign.Campaign_End_Date__c =dcList[0].Campaign_End_Date__c;    
    dcForoppBudgetProp.digitalCampaign.Opportunity__c = dcList[0].Opportunity__c;
    dcForoppBudgetProp.digitalCampaign.Total_Impressions__c =dcList[0].Total_Impressions__c; 
    dcForoppBudgetProp.digitalCampaign.AdsE_Platform_s__c ='All Platforms';
    dcForoppBudgetProp.digitalCampaign.Gross_Campaign_Cost__c = 6000.00;    
    dcForoppBudgetProp.digitalCampaign.Zip_Codes__c =''; 
      
    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper inactiveProp = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper(); 
    inactiveProp.isDraftPlan = TRUE;
    inactiveProp.product = 'STTV';
    inactiveProp.digitalCampaign = new Digital_Campaign__c();
    inactiveProp.digitalCampaign.Proposal__c =propId;
    inactiveProp.digitalCampaign.Campaign_Name__c = 'Test6';
    inactiveProp.digitalCampaign.Product_Type__c='DMA Addressable';
    inactiveProp.digitalCampaign.AdsE_Genre_s__c =dcList[0].AdsE_Genre_s__c;
    inactiveProp.digitalCampaign.Spectrum_Reach_Zones__c =dcList[0].Spectrum_Reach_Zones__c;            
    inactiveProp.digitalCampaign.Desired_Budget__c =dcList[0].Desired_Budget__c;
    inactiveProp.digitalCampaign.Campaign_Start_Date__c =dcList[0].Campaign_Start_Date__c;
    inactiveProp.digitalCampaign.Campaign_End_Date__c =dcList[0].Campaign_End_Date__c;    
    inactiveProp.digitalCampaign.Opportunity__c = dcList[0].Opportunity__c;
    inactiveProp.digitalCampaign.Total_Impressions__c =dcList[0].Total_Impressions__c; 
    inactiveProp.digitalCampaign.AdsE_Platform_s__c ='All Platforms';
    inactiveProp.digitalCampaign.Gross_Campaign_Cost__c = 6000.00;    
    inactiveProp.digitalCampaign.Zip_Codes__c =''; 

    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper invalidProp = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper(); 
    invalidProp.isDraftPlan = TRUE;
    invalidProp.product = 'STTV';
    invalidProp.digitalCampaign = new Digital_Campaign__c();
    invalidProp.digitalCampaign.Proposal__c =Id.valueOf('a0O550000012345');
    invalidProp.digitalCampaign.Campaign_Name__c = 'Test7';
    invalidProp.digitalCampaign.Product_Type__c='DMA Addressable';
    invalidProp.digitalCampaign.AdsE_Genre_s__c =dcList[0].AdsE_Genre_s__c;
    invalidProp.digitalCampaign.Spectrum_Reach_Zones__c =dcList[0].Spectrum_Reach_Zones__c;           
    invalidProp.digitalCampaign.Desired_Budget__c =dcList[0].Desired_Budget__c;
    invalidProp.digitalCampaign.Campaign_Start_Date__c =dcList[0].Campaign_Start_Date__c;
    invalidProp.digitalCampaign.Campaign_End_Date__c =dcList[0].Campaign_End_Date__c;    
    invalidProp.digitalCampaign.Opportunity__c = dcList[0].Opportunity__c;
    invalidProp.digitalCampaign.Total_Impressions__c =dcList[0].Total_Impressions__c; 
    invalidProp.digitalCampaign.AdsE_Platform_s__c ='All Platforms';
    invalidProp.digitalCampaign.Gross_Campaign_Cost__c = 6000.00;     
    invalidProp.digitalCampaign.Zip_Codes__c =''; 

    List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper> dcWrapList = new List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper>{ invalidProd, emptyProd, noProposal, invalidSTTV, invalidProp, dcForoppBudgetProp, inactiveProp};
    incmngWrpr.digitalCampaignList = dcWrapList;     

    ThirdPartyDigitalInvReqServices.OutgoingResponseWrapper outWrpr = ThirdPartyDigitalInvReqServices.doPost(incmngWrpr);
    System.assert(outWrpr.successDigitalCampaigns == null);  
    System.assert(!outWrpr.isSuccess);        
    System.assertEquals(System.Label.Invalid_Product_for_Digital_Campaign, outWrpr.failedDigitalCampaigns.get('Test1')); 
    System.assertEquals(System.Label.Product_is_mandatory_for_Digital_Campaign, outWrpr.failedDigitalCampaigns.get('Test2')); 
    System.assertEquals(System.Label.Required_Fields_missing_for_Digital_Campaign, outWrpr.failedDigitalCampaigns.get('Test3')); 
    System.assertEquals(System.Label.Required_Fields_missing_for_Digital_Campaign, outWrpr.failedDigitalCampaigns.get('Test4')); 
    System.assertEquals(System.Label.DC_cannot_be_created_for_an_Opp_Budget, outWrpr.failedDigitalCampaigns.get('Test5')); 
    System.assertEquals(System.Label.DC_cannot_be_created_for_an_Inactive_Proposal, outWrpr.failedDigitalCampaigns.get('Test6')); 
    System.assertEquals(System.Label.Invalid_Proposal, outWrpr.failedDigitalCampaigns.get('Test7')); 

    Test.stopTest();
  }

  static testMethod void testPartialSuccessToCreateDIR() 
  { 
    List<Digital_Campaign__c> dcList = [SELECT Id, Campaign_Name__c, Proposal__c, Campaign_End_Date__c, Campaign_Start_Date__c, Total_Impressions__c FROM Digital_Campaign__c LIMIT 1]; 
    System.assert(dcList.size()>0);

    Test.startTest();
    ThirdPartyDigitalInvReqServices.IncomingRequestWrapper incmngWrpr = new ThirdPartyDigitalInvReqServices.IncomingRequestWrapper();         
    incmngWrpr.source = Label.Audience_Track;             
    incmngWrpr.userID = [SELECT Id FROM User WHERE lastname = 'Testing' LIMIT 1].Id;  

    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper dcWrprRecPreroll = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper(); 
    dcWrprRecPreroll.isDraftPlan = TRUE;
    dcWrprRecPreroll.product = 'Pre_roll';
    dcWrprRecPreroll.digitalCampaign = new Digital_Campaign__c();
    dcWrprRecPreroll.digitalCampaign.Proposal__c =dcList[0].Proposal__c;
    dcWrprRecPreroll.digitalCampaign.Campaign_Name__c = dcList[0].Campaign_Name__c;
    dcWrprRecPreroll.digitalCampaign.AudienceTrak_Proposal_ID__c = '12357';
    dcWrprRecPreroll.digitalCampaign.Campaign_Start_Date__c =dcList[0].Campaign_Start_Date__c;
    dcWrprRecPreroll.digitalCampaign.Campaign_End_Date__c =dcList[0].Campaign_End_Date__c;
    dcWrprRecPreroll.digitalCampaign.Total_Impressions__c =dcList[0].Total_Impressions__c; 
    dcWrprRecPreroll.digitalCampaign.Gross_Campaign_Cost__c = 6000.00;    

    ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper dcWrprRecDisplay = new ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper(); 
    dcWrprRecDisplay.isDraftPlan = TRUE;
    dcWrprRecDisplay.product = 'Display';
    dcWrprRecDisplay.digitalCampaign = new Digital_Campaign__c();
    dcWrprRecDisplay.digitalCampaign.Proposal__c =dcList[0].Proposal__c;
    dcWrprRecDisplay.digitalCampaign.Campaign_Name__c = '';
    dcWrprRecDisplay.digitalCampaign.AudienceTrak_Proposal_ID__c = '12356';
    dcWrprRecDisplay.digitalCampaign.Campaign_Start_Date__c =dcList[0].Campaign_Start_Date__c;
    dcWrprRecDisplay.digitalCampaign.Campaign_End_Date__c =dcList[0].Campaign_End_Date__c;
    dcWrprRecDisplay.digitalCampaign.Total_Impressions__c =dcList[0].Total_Impressions__c; 
    dcWrprRecDisplay.digitalCampaign.Gross_Campaign_Cost__c = 6000.00;

    List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper> dcWrapList = new List<ThirdPartyDigitalInvReqServices.DigitalCampaignWrapper>{dcWrprRecDisplay, dcWrprRecPreroll};
    incmngWrpr.digitalCampaignList = dcWrapList;     

    ThirdPartyDigitalInvReqServices.OutgoingResponseWrapper outWrpr = ThirdPartyDigitalInvReqServices.doPost(incmngWrpr); 
    System.assertNotEquals(outWrpr.successDigitalCampaigns, null);  
    System.assertNotEquals(outWrpr.failedDigitalCampaigns, null);  
    System.assert(outWrpr.isSuccess);
    System.assertEquals(outWrpr.message, 'Partial Success'); 
    Test.stopTest();
  }


}