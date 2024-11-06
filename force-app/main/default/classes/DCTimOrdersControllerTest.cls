/*
	Author 				 :  M & S
	Date   				 :  Mar 10-2020
	Description 		 :  Test class for DCTimOrdersController
	Modification History : 
*/
@isTest
public class DCTimOrdersControllerTest {
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
        list<TIM_Orders__c> lstTIM = new list<TIM_Orders__c>();
        TIM_Orders__c objTIM = new TIM_Orders__c();
        objTIM.Name = 'SRCA';
        objTIM.Is_Active__c	= true;
        lstTIM.add(objTIM);
        
        TIM_Orders__c objTIM1 = new TIM_Orders__c();
        objTIM1.Name = 'SRFL';
        objTIM1.Is_Active__c	= true;
        lstTIM.add(objTIM1);
        insert lstTIM;
        
        objDC.TIM_Orders_Backend__c = 'SRCA:1234;SRFL:2345;';
        objDC.status__c = '01 Draft Campaign';
        objDC.Bypass_Apex_Execution__c = true;
        insert objDC;
        System.Assert(objDC.Id!=null);
        DCTimOrdersController.getTrafficSystemData();
        DCTimOrdersController.PrepareData(objDC.Id);
        DCTimOrdersController.UpdateData(objDC.Id,'SRCA:1234;SRFL:2346;');
    }
}