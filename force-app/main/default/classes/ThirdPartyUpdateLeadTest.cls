@isTest
private class ThirdPartyUpdateLeadTest {
    
    @testSetup static void setup() {
        Map<String,Object> leadmap = new Map<String, Object>{'FirstName' => 'test','LastName'=>'Lead', 'Company'=>'TestCompany','status'=>'Qualified','Email'=>'test@test.com'};
        Lead testLead=TestDataHelper.createLead(leadmap,true);
    }

    static @isTest void testDoGet() {
        String response = ThirdPartyUpdateLead.doGet();
        System.assert(response != null);   
    }

    static @isTest void testDoPost() {
      List<Lead> leadToUpdate = [SELECT Id, FirstName, LastName, Company FROM Lead LIMIT 1];
      if(leadToUpdate.size() >0 ){
        leadToUpdate[0].LastName = 'Update Lead';
        ThirdPartyUpdateLead.ResponseCls response = ThirdPartyUpdateLead.doPost(leadToUpdate[0]);
        System.assert(response != null);   
      leadToUpdate[0].LastName = NULL;
        response = ThirdPartyUpdateLead.doPost(leadToUpdate[0]);
        leadToUpdate[0].LastName = 'Update Lead';
        leadToUpdate[0].Id = NULL;
        response = ThirdPartyUpdateLead.doPost(leadToUpdate[0]);
    }
    }

    static @isTest void testDoPost2() {
      List<Lead> leadToUpdate = [SELECT Id, FirstName, LastName, Company, Status FROM Lead LIMIT 1];
      if(leadToUpdate.size() >0 ){
        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(leadToUpdate[0].Id);  
        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel); 
        Database.LeadConvertResult lcr = Database.convertLead(lc);
         System.assert(lcr.isSuccess());
        leadToUpdate[0].LastName = 'Update Lead';
        ThirdPartyUpdateLead.ResponseCls response = ThirdPartyUpdateLead.doPost(leadToUpdate[0]);
        System.assert(response != null); 
    }
    }

    static @isTest void testDoPost3() {
      List<Lead> leadToUpdate = [SELECT Id, FirstName, LastName, Company, Status,Primary_Commodity__c,Commodity_Codes__c FROM Lead LIMIT 1];
      if(leadToUpdate.size() >0 ){        
        leadToUpdate[0].LastName = 'Update Lead';
        leadToUpdate[0].Primary_Commodity__c = 'Education';
        leadToUpdate[0].Commodity_Codes__c = 'EDUCAT -- Education';
        ThirdPartyUpdateLead.ResponseCls response = ThirdPartyUpdateLead.doPost(leadToUpdate[0]);
        System.assert(response != null); 
    }
    }

    static @isTest void testDoPost4() {
      List<Lead> leadToUpdate = [SELECT Id, FirstName, LastName, Company, Status,Primary_Commodity__c,Commodity_Codes__c FROM Lead LIMIT 1];
      if(leadToUpdate.size() >0 ){        
        leadToUpdate[0].LastName = 'Update Lead';
        leadToUpdate[0].Primary_Commodity__c = '';
        leadToUpdate[0].Commodity_Codes__c = 'test';
        ThirdPartyUpdateLead.ResponseCls response = ThirdPartyUpdateLead.doPost(leadToUpdate[0]);
        System.assert(response != null); 
    }
    }

    static @isTest void testDoPost5() {
      List<Lead> leadToUpdate = [SELECT Id, FirstName, LastName, Company, Status,Primary_Commodity__c,Commodity_Codes__c FROM Lead LIMIT 1];
      if(leadToUpdate.size() >0 ){        
        leadToUpdate[0].LastName = 'Update Lead';
        leadToUpdate[0].Primary_Commodity__c = 'Education';
        leadToUpdate[0].Commodity_Codes__c = 'test';
        ThirdPartyUpdateLead.ResponseCls response = ThirdPartyUpdateLead.doPost(leadToUpdate[0]);
        System.assert(response != null); 
    }
    }

}