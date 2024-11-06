/*
    Author : MAndS 
    Date   : Jun 12-2017
    Description : test class to cover CM_DCClientRequestPlanControllerLegacy related classes
    Modification History : 
*/
@isTest
public class CM_DCClientRequestPlanLegacyTest {
    public testmethod static void Prepare_UpdateData()
    {
        Account objAcc = TestUtil.getAccountRec();
        insert objAcc;
        
        list<RecordType> lst = [select id from RecordType where name='Agency Account' and sobjecttype='Account'];
        if(lst!=null && !lst.isEmpty()){
            objAcc.RecordTypeId = lst[0].Id;
            objAcc.Last_Client_Schedule_Date__c = Date.today();
            update objAcc;
        }
        
        Account objAgencyAcc = TestUtil.getAgencyAccountRec();
        insert objAgencyAcc;
        
        Opportunity objOpp = TestUtil.getOpportunityRec(objAgencyAcc.Id);
        //objOpp.Total_Forecast_Amount__c = 10000;
        insert objOpp;
        
        Proposal__c objPro = TestUtil.getProposal(objAcc.Id,objOpp.Id);
        insert objPro;
        
        Digital_Campaign__c objDC = TestUtil.getDigitalCampaign(objAcc.Id,objOpp.Id,objPro.Id);
        objDC.Freewheel_O_O_Affiliate_Direct_Info__c = 'Freewheel – O&O/Affiliate/Direct:Ads Everywhere:Custom Nets:State:1:3:9';
        objDC.TTD_CTV_Info__c = 'TTD - CTV:Pre Roll Custom:Streaming TV:Zip:4:8:16';
        objDC.Freewheel_FF_OTT_Info__c = 'Freewheel - FF OTT:Ads Everywhere:Custom Nets:DMA:2:4:8';
        objDC.Freewheel_FF_TVE_Info__c = 'Freewheel – FF TVE:Ads Everywhere:Audience Segments:Zone:3:6:12';
        objDC.ClientRequestFormPlanDetails_Notes__c = 'Freewheel – O&O/Affiliate/Direct:notes1;Freewheel - FF OTT:notes2;Freewheel – FF TVE:notes3;TTD - CTV:notes4;';
        objDC.status__c = '01 Draft Campaign';
        objDC.Bypass_Apex_Execution__c = true;
        insert objDC;
        System.Assert(objDC.Id!=null);
        CM_DCClientRequestPlanControllerLegacy.PrepareData(objDC.Id);
        String strData = 'Freewheel – O&O/Affiliate/Direct:Ads Everywhere:Custom Nets:State:1:3:9;TTD - CTV:Pre Roll Custom:Streaming TV:Zip:4:8:16;Freewheel - FF OTT:Ads Everywhere:Custom Nets:DMA:2:4:8;Freewheel – FF TVE:Ads Everywhere:Audience Segments:Zone:3:6:12';
        String notes = 'Freewheel – O&O/Affiliate/Direct:notes1;Freewheel - FF OTT:notes2;Freewheel – FF TVE:notes3;TTD - CTV:notes4;';
        CM_DCClientRequestPlanControllerLegacy.UpdateData(objDC.Id,strData,notes,'TTD - CTV',true);
        strData = '';
        notes = '';
        CM_DCClientRequestPlanControllerLegacy.UpdateData(objDC.Id,strData,notes,'TTD - CTV',true);
    }
}