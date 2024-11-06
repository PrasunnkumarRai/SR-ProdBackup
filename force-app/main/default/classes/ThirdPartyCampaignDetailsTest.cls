/*
###########################################################################
# File..................: ThirdPartyCampaignDetailstest.cls
# Version...............: 1
# Created by............: Amita Mishra
# Created Date..........: 8-Jan-2019
# Last Modified by......: Amita Mishra
# Last Modified Date....: 9-Jan-2019
############################################################################*/
@isTest
private class ThirdPartyCampaignDetailsTest {
    @testSetup static void setup() {
        
        Campaign testCampaign = new Campaign(Name='testcamping', IsActive=true);
        insert testCampaign;
        
        Contact con = TestDataHelper.createContact('testLast',null,null,null);
        insert con;
        
        Map<String,Object> Leadmap = new Map<String, Object>{'FirstName' => 'test1','LastName'=>'last1', 'Company'=>'osi.com','status'=>'New'};
            Lead testLead=TestDataHelper.createLead(Leadmap,true);
        
        CampaignMember cammember = new CampaignMember(Status = 'Completed',CampaignId = testCampaign.Id,Leadid = testLead.Id);
        insert cammember;
    }
    static testMethod void testDoGet() {
        String response = ThirdPartyCampaignDetails.doGet();
        System.assert(response != null);   
    }
    
    static testMethod void testDoPost() {
        Contact testCon= [SELECT Id, Name FROM Contact LIMIT 1];
        CampaignMember CampaignLst = [SELECT Id, Leadid FROM CampaignMember LIMIT 1];
        System.debug('testLead--->'+CampaignLst.Leadid); 
        ThirdPartyCampaignDetails.ResponseCls response1 = ThirdPartyCampaignDetails.doPost(CampaignLst.Leadid);
        ThirdPartyCampaignDetails.ResponseCls response2 = ThirdPartyCampaignDetails.doPost(null);
        ThirdPartyCampaignDetails.ResponseCls response3 = ThirdPartyCampaignDetails.doPost(testCon.ID);
        
        System.debug('response1::'+response1);
        System.assert(response1 != null);     
    }
}