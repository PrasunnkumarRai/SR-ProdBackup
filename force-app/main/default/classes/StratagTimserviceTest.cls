/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=false)
private class StratagTimserviceTest {

    static testMethod void testClassStructures() {
        
        try{
            insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
            List<UserConnection__c> connections = [SELECT Id, Name FROM UserConnection__c LIMIT 1];
            System.assert(connections.size() > 0);
        }catch(Exception ex){}        
        
        StratagTimservice.DeleteOrderResponse_element c1 = new StratagTimservice.DeleteOrderResponse_element();
        StratagTimservice.DeleteOrder_element c2 = new StratagTimservice.DeleteOrder_element();
        StratagTimservice.UndeleteOrderResponse_element c3 = new StratagTimservice.UndeleteOrderResponse_element();
        StratagTimservice.UndeleteOrder_element c4 = new StratagTimservice.UndeleteOrder_element();
        StratagTimservice.SaveEntitiesResponse_element c5 = new StratagTimservice.SaveEntitiesResponse_element();
        StratagTimservice.SaveEntities_element c6 = new StratagTimservice.SaveEntities_element();
        StratagTimservice.GetEntitiesResponse_element c7 = new StratagTimservice.GetEntitiesResponse_element();
        StratagTimservice.GetEntities_element c8 = new StratagTimservice.GetEntities_element();
        StratagTimservice.GetEstimateHeaderChanges_4_6Response_element c9 = new StratagTimservice.GetEstimateHeaderChanges_4_6Response_element();
        StratagTimservice.GetEstimateHeaderChanges_4_6_element c10 = new StratagTimservice.GetEstimateHeaderChanges_4_6_element();
        StratagTimservice.GetEstimateHeaders_4_6Response_element c11 = new StratagTimservice.GetEstimateHeaders_4_6Response_element();
        StratagTimservice.GetEstimateHeaders_4_6_element c12 = new StratagTimservice.GetEstimateHeaders_4_6_element();
        StratagTimservice.SaveEstimate_4_6Response_element c13 = new StratagTimservice.SaveEstimate_4_6Response_element();
        StratagTimservice.SaveEntities_4_2_element c14 = new StratagTimservice.SaveEntities_4_2_element();
        StratagTimservice.SaveEntities_4_2Response_element c15 = new StratagTimservice.SaveEntities_4_2Response_element();
        StratagTimservice.GetEntities_4_2Response_element c16 = new StratagTimservice.GetEntities_4_2Response_element();
        StratagTimservice.SAuthenticateResponse_element c17 = new StratagTimservice.SAuthenticateResponse_element();
        StratagTimservice.SAuthenticate_element c18 = new StratagTimservice.SAuthenticate_element();
        StratagTimservice.ArrayOfAnyType c19 = new StratagTimservice.ArrayOfAnyType();
        StratagTimservice.ChangeResult c20 = new StratagTimservice.ChangeResult();
        StratagTimservice.SurveyVersion c21 = new StratagTimservice.SurveyVersion();
        StratagTimservice.ArrayOfSurveyVersion c22 = new StratagTimservice.ArrayOfSurveyVersion();
        StratagTimservice.BroadcastValue c23 = new StratagTimservice.BroadcastValue();
        StratagTimservice.ArrayOfBroadcastValue c24 = new StratagTimservice.ArrayOfBroadcastValue();
        StratagTimservice.AAProduct c25 = new StratagTimservice.AAProduct();
        StratagTimservice.ArrayOfAAProduct c26 = new StratagTimservice.ArrayOfAAProduct();
        StratagTimservice.AAProductBreakdownPeriod c27 = new StratagTimservice.AAProductBreakdownPeriod();
        StratagTimservice.ArrayOfAAProductBreakdownPeriod c28 = new StratagTimservice.ArrayOfAAProductBreakdownPeriod();
        StratagTimservice.AAProductBreakdownBySyscode c29 = new StratagTimservice.AAProductBreakdownBySyscode();
        StratagTimservice.ArrayOfAAProductBreakdownBySyscode c30 = new StratagTimservice.ArrayOfAAProductBreakdownBySyscode();
        StratagTimservice.ScheduleItem_4_6 c31 = new StratagTimservice.ScheduleItem_4_6();
        StratagTimservice.ArrayOfScheduleItem_4_6 c32 = new StratagTimservice.ArrayOfScheduleItem_4_6();
        StratagTimservice.EstimateHeader_4_6 c33 = new StratagTimservice.EstimateHeader_4_6();
        StratagTimservice.ArrayOfEstimateHeader_4_6 c34 = new StratagTimservice.ArrayOfEstimateHeader_4_6();
        StratagTimservice.IDError c35 = new StratagTimservice.IDError();
        StratagTimservice.ArrayOfIDError c36 = new StratagTimservice.ArrayOfIDError();
        StratagTimservice.IDResult c37 = new StratagTimservice.IDResult();
        StratagTimservice.TrafficOptionEntity c38 = new StratagTimservice.TrafficOptionEntity();
        StratagTimservice.ArrayOfTrafficOptionEntity c39 = new StratagTimservice.ArrayOfTrafficOptionEntity();
        StratagTimservice.TrafficOption c40 = new StratagTimservice.TrafficOption();
        StratagTimservice.AAItem_4_0 c41 = new StratagTimservice.AAItem_4_0();
        StratagTimservice.ArrayOfAAItem_4_0 c42 = new StratagTimservice.ArrayOfAAItem_4_0();
        StratagTimservice.EDIInfo c43 = new StratagTimservice.EDIInfo();
        StratagTimservice.Daypart_4_0 c44 = new StratagTimservice.Daypart_4_0();
        StratagTimservice.ArrayOfDaypart_4_0 c45 = new StratagTimservice.ArrayOfDaypart_4_0();
        StratagTimservice.Station_4_0 c46 = new StratagTimservice.Station_4_0();
        StratagTimservice.ArrayOfStation_4_0 c47 = new StratagTimservice.ArrayOfStation_4_0();
        StratagTimservice.ArrayOfDecimal c48 = new StratagTimservice.ArrayOfDecimal();
        StratagTimservice.SysCode c49 = new StratagTimservice.SysCode();
        StratagTimservice.ArrayOfSysCode c50 = new StratagTimservice.ArrayOfSysCode();
        StratagTimservice.ExternalSourceApp c51 = new StratagTimservice.ExternalSourceApp();
        StratagTimservice.ArrayOfExternalSourceApp c52 = new StratagTimservice.ArrayOfExternalSourceApp();
        StratagTimservice.Survey_4_6 c53 = new StratagTimservice.Survey_4_6();
        StratagTimservice.ArrayOfSurvey_4_6 c54 = new StratagTimservice.ArrayOfSurvey_4_6();
        StratagTimservice.Address c55 = new StratagTimservice.Address();
        StratagTimservice.Estimate_4_6 c56 = new StratagTimservice.Estimate_4_6();
        StratagTimservice.SaveEstimate_4_6_element c57 = new StratagTimservice.SaveEstimate_4_6_element();
        StratagTimservice.RepFirm_3_2 c58 = new StratagTimservice.RepFirm_3_2();
        StratagTimservice.Demo_3_5 c59 = new StratagTimservice.Demo_3_5();
        StratagTimservice.ArrayOfDemo_3_5 c60 = new StratagTimservice.ArrayOfDemo_3_5();
        StratagTimservice.Advertiser_4_2 c61 = new StratagTimservice.Advertiser_4_2();
        StratagTimservice.ArrayOfAdvertiser_4_2 c62 = new StratagTimservice.ArrayOfAdvertiser_4_2();
        StratagTimservice.Agency_4_2 c63 = new StratagTimservice.Agency_4_2();
        StratagTimservice.ArrayOfAgency_4_2 c64 = new StratagTimservice.ArrayOfAgency_4_2();
        StratagTimservice.EntityResult c65 = new StratagTimservice.EntityResult();
        StratagTimservice.ArrayOfEntityResult c66 = new StratagTimservice.ArrayOfEntityResult();
        StratagTimservice.Zone_3_5 c67 = new StratagTimservice.Zone_3_5();
        StratagTimservice.ArrayOfZone_3_5 c68 = new StratagTimservice.ArrayOfZone_3_5();
        StratagTimservice.SpotType_3_5 c69 = new StratagTimservice.SpotType_3_5();
        StratagTimservice.ArrayOfSpotType_3_5 c70 = new StratagTimservice.ArrayOfSpotType_3_5();
        StratagTimservice.CopyGroup_3_5 c71 = new StratagTimservice.CopyGroup_3_5();
        StratagTimservice.ArrayOfCopyGroup_3_5 c72 = new StratagTimservice.ArrayOfCopyGroup_3_5();
        StratagTimservice.RevenueType_3_5 c73 = new StratagTimservice.RevenueType_3_5();
        StratagTimservice.ArrayOfRevenueType_3_5 c74 = new StratagTimservice.ArrayOfRevenueType_3_5();
        StratagTimservice.RepFirm_3_5 c75 = new StratagTimservice.RepFirm_3_5();
        StratagTimservice.ArrayOfRepFirm_3_5 c76 = new StratagTimservice.ArrayOfRepFirm_3_5();
        StratagTimservice.Reference4_3_5 c77 = new StratagTimservice.Reference4_3_5();
        StratagTimservice.ArrayOfReference4_3_5 c78 = new StratagTimservice.ArrayOfReference4_3_5();
        StratagTimservice.SaveAgency_element c79 = new StratagTimservice.SaveAgency_element();
        StratagTimservice.Reference3_3_5 c80 = new StratagTimservice.Reference3_3_5();
        StratagTimservice.ArrayOfReference3_3_5 c81 = new StratagTimservice.ArrayOfReference3_3_5();
        StratagTimservice.Reference2_3_5 c82 = new StratagTimservice.Reference2_3_5();
        StratagTimservice.ArrayOfReference2_3_5 c83 = new StratagTimservice.ArrayOfReference2_3_5();
        StratagTimservice.Reference1_3_5 c84 = new StratagTimservice.Reference1_3_5();
        StratagTimservice.ArrayOfReference1_3_5 c85 = new StratagTimservice.ArrayOfReference1_3_5();
        StratagTimservice.Product_3_5 c86 = new StratagTimservice.Product_3_5();
        StratagTimservice.ArrayOfProduct_3_5 c87 = new StratagTimservice.ArrayOfProduct_3_5();
        StratagTimservice.Network_3_5_TrafficIDElement c88 = new StratagTimservice.Network_3_5_TrafficIDElement();
        StratagTimservice.ArrayOfNetwork_3_5TrafficIDElement c89 = new StratagTimservice.ArrayOfNetwork_3_5TrafficIDElement();
        StratagTimservice.Network_3_5 c90 = new StratagTimservice.Network_3_5();
        StratagTimservice.ArrayOfNetwork_3_5 c91 = new StratagTimservice.ArrayOfNetwork_3_5();
        StratagTimservice.InventoryType_3_5 c92 = new StratagTimservice.InventoryType_3_5();
        StratagTimservice.ArrayOfInventoryType_3_5 c93 = new StratagTimservice.ArrayOfInventoryType_3_5();
        StratagTimservice.OrderType_3_5 c94 = new StratagTimservice.OrderType_3_5();
        StratagTimservice.IndustryCode_3_5 c95 = new StratagTimservice.IndustryCode_3_5();
        StratagTimservice.DaypartCode_3_5_TrafficIDElement c96 = new StratagTimservice.DaypartCode_3_5_TrafficIDElement();
        StratagTimservice.ArrayOfDaypartCode_3_5TrafficIDElement c97 = new StratagTimservice.ArrayOfDaypartCode_3_5TrafficIDElement();
        StratagTimservice.DaypartCode_3_5 c98 = new StratagTimservice.DaypartCode_3_5();
        StratagTimservice.Agency_3_5 c99 = new StratagTimservice.Agency_3_5();
        
        StratagTimservice.AeOffice_3_5 c100 = new StratagTimservice.AeOffice_3_5();
        StratagTimservice.ArrayOfAeOffice_3_5 c101 = new StratagTimservice.ArrayOfAeOffice_3_5();
        StratagTimservice.ArrayOfAgency_3_5 c102 = new StratagTimservice.ArrayOfAgency_3_5();
        StratagTimservice.ArrayOfAvailClass_3_5 c103 = new StratagTimservice.ArrayOfAvailClass_3_5();
        StratagTimservice.Commodity_3_5 c104 = new StratagTimservice.Commodity_3_5();
        StratagTimservice.Advertiser_3_5 c105 = new StratagTimservice.Advertiser_3_5();
        StratagTimservice.ArrayOfAdvertiser_3_5 c106 = new StratagTimservice.ArrayOfAdvertiser_3_5();
        StratagTimservice.ArrayOfCommodity_3_5 c107 = new StratagTimservice.ArrayOfCommodity_3_5();
        StratagTimservice.ArrayOfDaypartCode_3_5 c108 = new StratagTimservice.ArrayOfDaypartCode_3_5();
        StratagTimservice.ArrayOfIndustryCode_3_5 c109 = new StratagTimservice.ArrayOfIndustryCode_3_5();
        
        StratagTimservice.ArrayOfOrderType_3_5 c110 = new StratagTimservice.ArrayOfOrderType_3_5();
        StratagTimservice.Entities c111 = new StratagTimservice.Entities();
        StratagTimservice.ArrayOfAE_3_5 c112 = new StratagTimservice.ArrayOfAE_3_5();
        StratagTimservice.AE_3_5 c113 = new StratagTimservice.AE_3_5();
        StratagTimservice.Agency_3_2 c114 = new StratagTimservice.Agency_3_2();
        StratagTimservice.GetAgency_3_2Response_element c115 = new StratagTimservice.GetAgency_3_2Response_element();
        StratagTimservice.GetAgency_3_2_element c116 = new StratagTimservice.GetAgency_3_2_element();
        StratagTimservice.EntityIDsRequest c117 = new StratagTimservice.EntityIDsRequest();
        StratagTimservice.ArrayOfEntityIDsRequest c118 = new StratagTimservice.ArrayOfEntityIDsRequest();
        StratagTimservice.TrafficIDElement c119 = new StratagTimservice.TrafficIDElement();
        
        StratagTimservice.ArrayOfTrafficIDElement c120 = new StratagTimservice.ArrayOfTrafficIDElement();
        StratagTimservice.GetEntities_4_2_element c121 = new StratagTimservice.GetEntities_4_2_element();
        StratagTimservice.Agency c122 = new StratagTimservice.Agency();
        StratagTimservice.Login c123 = new StratagTimservice.Login();
        StratagTimservice.EstimateHeader_3_2 c124 = new StratagTimservice.EstimateHeader_3_2();
        StratagTimservice.ArrayOfEstimateHeader_3_2 c125 = new StratagTimservice.ArrayOfEstimateHeader_3_2();
        StratagTimservice.GetEstimateHeaders_3_2Response_element c126 = new StratagTimservice.GetEstimateHeaders_3_2Response_element();
        StratagTimservice.SaveAgencyResponse_element c127 = new StratagTimservice.SaveAgencyResponse_element();
        StratagTimservice.Entity c128 = new StratagTimservice.Entity();
        StratagTimservice.GetEstimateHeaders_3_2_element c129 = new StratagTimservice.GetEstimateHeaders_3_2_element();
        
        StratagTimservice.SaveRepFirm_3_2Response_element c130 = new StratagTimservice.SaveRepFirm_3_2Response_element();
        StratagTimservice.GetEstimateHeaderChanges_element c131 = new StratagTimservice.GetEstimateHeaderChanges_element();
        StratagTimservice.ArrayOfInt c132 = new StratagTimservice.ArrayOfInt();
        StratagTimservice.ArrayOfString c133 = new StratagTimservice.ArrayOfString();
        StratagTimservice.Result c134 = new StratagTimservice.Result();
        StratagTimservice.ServiceSoap c135 = new StratagTimservice.ServiceSoap();
        StratagTimservice.AvailClass_3_5 c136 = new StratagTimservice.AvailClass_3_5();
        
    }
    
    static testMethod void testGetEntities_4_2API() {
        Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
        StratagTimservice.ServiceSoap sts = new StratagTimservice.ServiceSoap();

        System.assert(sts != null);

        StratagTimservice.ArrayOfEntityIDsRequest obj = new StratagTimservice.ArrayOfEntityIDsRequest();
        sts.GetEntities_4_2(obj);
    }
    
    static testMethod void testGetEstimateHeaders_3_2API() {
        Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
        StratagTimservice.ServiceSoap sts = new StratagTimservice.ServiceSoap();

        System.assert(sts != null);

        StratagTimservice.ArrayOfInt EstimateID = new StratagTimservice.ArrayOfInt();
        sts.GetEstimateHeaders_3_2(EstimateID);
    }
    
    static testMethod void testSaveEstimate_4_6API() {
        Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
        StratagTimservice.ServiceSoap sts = new StratagTimservice.ServiceSoap();

        System.assert(sts != null);

        StratagTimservice.Estimate_4_6 obj1 = new StratagTimservice.Estimate_4_6();
        StratagTimservice.ArrayOfInt obj2 = new StratagTimservice.ArrayOfInt();
        sts.SaveEstimate_4_6(obj1, obj2);
    }
    
    static testMethod void testGetEntitiesAPI() {
        Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
        StratagTimservice.ServiceSoap sts = new StratagTimservice.ServiceSoap();

        System.assert(sts != null);

        StratagTimservice.ArrayOfEntityIDsRequest obj = new StratagTimservice.ArrayOfEntityIDsRequest();
        sts.GetEntities(obj);
    }
    
    static testMethod void testSaveEntitiesAPI() {
        Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
        StratagTimservice.ServiceSoap sts = new StratagTimservice.ServiceSoap();

        System.assert(sts != null);

        StratagTimservice.Entities obj = new StratagTimservice.Entities();
        sts.SaveEntities(obj);
    }
    
    static testMethod void testUndeleteOrderAPI() {
        Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
        StratagTimservice.ServiceSoap sts = new StratagTimservice.ServiceSoap();

        System.assert(sts != null);

        Integer obj1 = 0;
        sts.UndeleteOrder(obj1,obj1);
    }
    
    static testMethod void testSaveAgencyAPI() {
        Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
        StratagTimservice.ServiceSoap sts = new StratagTimservice.ServiceSoap();

        System.assert(sts != null);

        StratagTimservice.Agency obj = new StratagTimservice.Agency();
        sts.SaveAgency(obj);
    }
    
    static testMethod void testGetAgency_3_2API() {
        Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
        StratagTimservice.ServiceSoap sts = new StratagTimservice.ServiceSoap();

        System.assert(sts != null);

        Integer obj1 = 0;
        Boolean obj2 = false;
        sts.GetAgency_3_2(obj1, obj2);
    }
    
    static testMethod void testSetEstimateStatus_4_4API() {
        Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
        StratagTimservice.ServiceSoap sts = new StratagTimservice.ServiceSoap();

        System.assert(sts != null);

        Integer obj1 = 0;
        String obj2 = '1';
        Integer obj3 = 0;
        sts.SetEstimateStatus_4_4(obj1, obj2, obj3);
    }
    
    static testMethod void testImportSCX_4_2API() {
        Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
        StratagTimservice.ServiceSoap sts = new StratagTimservice.ServiceSoap();

        System.assert(sts != null);

        String obj2 = '1';
        sts.ImportSCX_4_2(obj2);
    }
    
    static testMethod void testGetEstimateHeaders_4_6API() {
        Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
        StratagTimservice.ServiceSoap sts = new StratagTimservice.ServiceSoap();

        System.assert(sts != null);

        StratagTimservice.ArrayOfInt aoi = new StratagTimservice.ArrayOfInt();
        sts.GetEstimateHeaders_4_6(aoi);
    }
    
    static testMethod void testGetEstimateHeaderChanges_4_6API() {
        Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
        StratagTimservice.ServiceSoap sts = new StratagTimservice.ServiceSoap();

        System.assert(sts != null);

        Integer obj1 = 1;
        sts.GetEstimateHeaderChanges_4_6(obj1);
    }
    static testMethod void testDeleteOrderAPI() {
        Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
        StratagTimservice.ServiceSoap sts = new StratagTimservice.ServiceSoap();

        System.assert(sts != null);

        Integer obj1 = 1;
        sts.DeleteOrder(obj1,obj1);
    }
     
    /*@isTest(SeeAllData=false)
    static void testActivateProposalsHelper() {
        
        User u = [select Id, Name from User where Name = 'Boomi Integration User'];
        System.debug('@@u Name '+u.Name);
        
        System.runAs(u){
            
            insert TestDataHelper.createUserConnection('St. Louis Local','SFDCUser',UserInfo.getUserId(),'TIM','1');
            
            Account acc=TestDataHelper.createAdvertiser('Advertiser Account Stratag','123 Wright Plaza Stratag', 'Omaha', 'NE', '68130', 'USA');                        
            insert acc;
             
            Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
            insert opp;
               
            Proposal__c prop=TestDataHelper.createProposal('Test Opportunity Proposal',opp.id, '00000', true);              
            insert prop;
           
            List<Proposal__c> propList =[select id,tim_id__c,name from proposal__c where id=:prop.id];
            
            Test.setMock(WebServiceMock.class, new StratagTimService_Mock());
            TimWebServiceHelper sts = new TimWebServiceHelper();
            
            Test.startTest();
            sts.activateProposals(propList);
            Test.stopTest();
        }
    }*/
}