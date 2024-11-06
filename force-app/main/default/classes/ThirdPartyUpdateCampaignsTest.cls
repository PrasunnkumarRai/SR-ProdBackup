/*
###########################################################################
# File..................: ThirdPartyUpdateCampaignsTest.cls
# Version...............: 1
# Created by............: Amita Mishra
# Created Date..........: 8-Jan-2019
# Last Modified by......: Amita Mishra
# Last Modified Date....: 9-Jan-2019
############################################################################*/
@isTest
private class ThirdPartyUpdateCampaignsTest {

    @testSetup static void setup() {
        Map<String,Object> Leadmap = new Map<String, Object>{'FirstName' => 'test1','LastName'=>'last1', 'Company'=>'osi.com','status'=>'New'};
            Lead testLead=TestDataHelper.createLead(Leadmap,true);
        
        Contact testcontact = new Contact(FirstName='test', LastName='last', Email='test@test.com');
        insert testcontact;
        system.debug('testcontact-->'+testcontact);
        
        Campaign testCampaign = new Campaign(name='testcamping', IsActive=true);
        insert testCampaign;
        system.debug('testCampaign-->'+testCampaign);

        CampaignMember cammember = new CampaignMember(Status = 'Completed',CampaignId = testCampaign.Id,leadid = testLead.id);
        insert cammember;

    }

    static testMethod void testDoGet() {
        String response = ThirdPartyUpdateCampaigns.doGet();
        System.assert(response != null);   
    }

    static testMethod void testDoPost() {
    	Lead testLead= [SELECT Id,Name FROM Lead Limit 1];
        Contact testContact= [SELECT Id,Name FROM Contact Limit 1];
    	List<String> CampaignIdlst = new List<String> ();
    	List<Campaign> CampaignLst = [select id from Campaign Limit 1];
    	for(Campaign obj:CampaignLst){
    		CampaignIdlst.add(obj.id);
    	}

    	ThirdPartyUpdateCampaigns.IncomingSPPRequestWrapper incomingObj = new ThirdPartyUpdateCampaigns.IncomingSPPRequestWrapper();
        incomingObj.leadIdOrContId=testLead.id;
        incomingObj.campaignIds=CampaignIdlst;
        
        ThirdPartyUpdateCampaigns.IncomingSPPRequestWrapper incomingObj1 = new ThirdPartyUpdateCampaigns.IncomingSPPRequestWrapper();
        incomingObj1.leadIdOrContId=null;
        //incomingObj1.isLeadId=true;
        incomingObj.campaignIds=CampaignIdlst;
        
        ThirdPartyUpdateCampaigns.IncomingSPPRequestWrapper incomingObj2 = new ThirdPartyUpdateCampaigns.IncomingSPPRequestWrapper();
        incomingObj2.leadIdOrContId=testContact.id;
        incomingObj2.campaignIds=CampaignIdlst;
        
        ThirdPartyUpdateCampaigns.ResponseCls response1 = ThirdPartyUpdateCampaigns.doPost(incomingObj);
        ThirdPartyUpdateCampaigns.ResponseCls response2 = ThirdPartyUpdateCampaigns.doPost(incomingObj1);       
        ThirdPartyUpdateCampaigns.ResponseCls response3 = ThirdPartyUpdateCampaigns.doPost(incomingObj2);        
        System.debug('response1::'+response1);

    }

    static testMethod void testDoPost1() {
        Lead testLead= [SELECT Id,Name FROM Lead Limit 1];
        Contact testContact= [SELECT Id,Name FROM Contact Limit 1];
        List<String> CampaignIdlst = new List<String> ();
        List<Campaign> CampaignLst = [select id from Campaign Limit 1];
        for(Campaign obj:CampaignLst){
            CampaignIdlst.add(obj.id);
        }

        CampaignMember cammember= [SELECT Id FROM CampaignMember Limit 1];
        delete cammember;

        ThirdPartyUpdateCampaigns.IncomingSPPRequestWrapper incomingObj = new ThirdPartyUpdateCampaigns.IncomingSPPRequestWrapper();
        incomingObj.leadIdOrContId=testLead.id;
        incomingObj.campaignIds=CampaignIdlst;

        ThirdPartyUpdateCampaigns.ResponseCls response1 = ThirdPartyUpdateCampaigns.doPost(incomingObj);
        System.debug('response1::'+response1);
    }

}