@isTest
private class ThirdPartyConvertLeadTest {
/*    @testSetup static void setup() {
        Map<String,Object> Leadmap = new Map<String, Object>{'FirstName' => 'test1','LastName'=>'last1', 'Company'=>'osi.com','status'=>'Qualified','Email'=>'test@test.com'};
            Lead testLead=TestDataHelper.createLead(Leadmap,true);

        Campaign testCampaign = new Campaign(name='testcamping', IsActive=true);
        insert testCampaign;
        system.debug('testCampaign-->'+testCampaign);
    }*/

    static testMethod void testDoGet() {
        String response = ThirdPartyConvertLead.doGet();
        System.assert(response != null);   
    }

    static testMethod void testDoPost() {

        User usr = TestDataHelper.createUser(false);
        usr.LastName = 'SPP';
        usr.UserPermissionsMarketingUser = true;
        insert usr;

        System.runAs(usr){  

        Map<String,Object> Leadmap = new Map<String, Object>{'FirstName' => 'test1','LastName'=>'last1', 'Company'=>'osi.com','status'=>'Qualified','Email'=>'test@test.com','Street'=>'PO BOX 1252','City'=>'MOREHEAD CITY','PostalCode'=>'28557','State'=>'NC','Country'=>'US'};
            Lead testLead=TestDataHelper.createLead(Leadmap,true);
            

        Campaign testCampaign = new Campaign(Name='testcamping', IsActive=true);
        insert testCampaign;
        System.debug('testCampaign-->'+testCampaign);
        List<Lead> leadList= [SELECT Id,Name,OwnerId FROM Lead LIMIT 1];

        List<String> CampaignIdlst = new List<String> ();
        List<Campaign> CampaignLst = [SELECT Id FROM Campaign LIMIT 1];
        for(Campaign obj:CampaignLst){
            CampaignIdlst.add(obj.Id);
        }

        ThirdPartyConvertLead.IncomingRequestWrapper incomingObj = new ThirdPartyConvertLead.IncomingRequestWrapper(String.valueOf(leadList[0].OwnerId),String.valueOf(leadList[0].Id),CampaignIdlst);

        ThirdPartyConvertLead.IncomingRequestWrapper incomingObj2 = new ThirdPartyConvertLead.IncomingRequestWrapper(String.valueOf(UserInfo.getUserId()),String.valueOf(leadList[0].Id),CampaignIdlst);

        leadList[0].Id = NULL;
        ThirdPartyConvertLead.IncomingRequestWrapper incomingObj3 = new ThirdPartyConvertLead.IncomingRequestWrapper(String.valueOf(leadList[0].OwnerId),String.valueOf(leadList[0].Id),CampaignIdlst);
         
        ThirdPartyConvertLead.IncomingRequestWrapper incomingObj1 = new ThirdPartyConvertLead.IncomingRequestWrapper(null,null,null);
        //incomingObj.leadId=null;
        //incomingObj.campaignIdList=CampaignIdlst;
        
        
        ThirdPartyConvertLead.ResponseWrapper response1 = ThirdPartyConvertLead.doPost(incomingObj);
        ThirdPartyConvertLead.ResponseWrapper response2 = ThirdPartyConvertLead.doPost(incomingObj1);
        ThirdPartyConvertLead.ResponseWrapper response3 = ThirdPartyConvertLead.doPost(incomingObj2);
        ThirdPartyConvertLead.ResponseWrapper response4 = ThirdPartyConvertLead.doPost(incomingObj3);

        System.assert(response1 != null);   
        System.debug('response1::'+response1);
        }
    } 

     static testMethod void testDoPostNegative() {

        User usr = TestDataHelper.createUser(false);
        usr.LastName = 'SPP';
        usr.UserPermissionsMarketingUser = true;
        insert usr;

        System.runAs(usr){  

        Map<String,Object> Leadmap = new Map<String, Object>{'FirstName' => 'test1','LastName'=>'last1', 'Company'=>'osi.com','status'=>'Qualified','Email'=>'test@test.com','City'=>'MOREHEAD CITY','PostalCode'=>'28557','State'=>'NC','Country'=>'US'};
        Lead testLead=TestDataHelper.createLead(Leadmap,true);

        List<Lead> leadList= [SELECT Id,Name,OwnerId,Street,City,State,PostalCode,Country FROM Lead LIMIT 1];

        ThirdPartyConvertLead.IncomingRequestWrapper incomingObj = new ThirdPartyConvertLead.IncomingRequestWrapper(String.valueOf(leadList[0].OwnerId),String.valueOf(leadList[0].Id),null);
              
        ThirdPartyConvertLead.ResponseWrapper res= ThirdPartyConvertLead.doPost(incomingObj);

        System.assert(res != null);   
        System.debug('res::'+res);
        }
    }   
}