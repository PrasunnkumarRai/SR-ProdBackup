/*
    Author : MAndS 
    Date   : Jun 12-2017
    Description : test class to cover CM_DigitalCampaign related classes
    Modification History : 
*/
@isTest
public class CM_DCFlightDatesController_Test {
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
        objDC.Flight_Dates_Backend__c = '07/24/2018:07/30/2018;07/28/2018:07/31/2018;';
        objDC.status__c = '01 Draft Campaign';
        objDC.Bypass_Apex_Execution__c = true;
        insert objDC;
        System.Assert(objDC.Id!=null);
        CM_DCFlightDatesController.PrepareData(objDC.Id);
        CM_DCFlightDatesController.UpdateData(objDC.Id,'07/25/2018:07/31/2018;08/28/2018:08/31/2018;');
    }
}