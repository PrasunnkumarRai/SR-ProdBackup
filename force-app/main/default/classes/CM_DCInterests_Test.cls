/*
    Author : MAndS 
    Date   : Sep 25-2020
    Description : test class to cover CM_DCInterests related classes
    Modification History : 
*/
@isTest
public class CM_DCInterests_Test {
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
        
        Interests__c objInt1 = new Interests__c();
        objInt1.Interest_Category__c = 'Automotive';
        objInt1.Interest_Sub_Category__c = 'Class';
        objInt1.Interest__c = 'Luxury';
        objInt1.Active__c = true;
        insert objInt1;
        Interests__c objInt2 = new Interests__c();
        objInt2.Interest_Category__c = 'Automotive';
        objInt2.Interest_Sub_Category__c = 'Class';
        objInt2.Interest__c = 'Exotic';
        objInt2.Active__c = true;
        insert objInt2;
        Interests__c objInt3 = new Interests__c();
        objInt3.Interest_Category__c = 'Automotive';
        objInt3.Interest_Sub_Category__c = 'Class';
        objInt3.Interest__c = 'Non-Luxury';
        objInt3.Active__c = true;
        insert objInt3;
        
        list<RecordType> lstDCRT = [select id from RecordType where name='Inventory Request - Addressable Display' and sobjecttype='Digital_Campaign__c'];
        if(lstDCRT!=null && !lstDCRT.isEmpty()){
            Digital_Campaign__c objDC = TestUtil.getDigitalCampaign(objAcc.Id,objOpp.Id,objPro.Id);
            objDC.Interest_Category__c = 'Automotive,Automotive,Automotive';
            objDC.Interest_Sub_Category__c = 'Class,Class,Class';
            objDC.Interest__c = 'Luxury,Exotic,Non-Luxury';
            //objDC.status__c = 'Plan Submitted';
            objDC.Bypass_Apex_Execution__c = true;
            objDC.RecordTypeId = lstDCRT[0].Id;
            insert objDC;
            System.Assert(objDC.Id!=null);
            Test.startTest();
            CM_DCInterests.PrepareData(objDC.Id);
            CM_DCInterests.fetchSubCategories('Automotive');
            CM_DCInterests.fetchCategoryOfSubcategories(new list<string>{'Automotive'});
            CM_DCInterests.fetchInterests('Automotive','Auto Ownership - Fuel Type');
            CM_DCInterests.saveData(objDC.Id,'Automotive,Political','Auto Ownership - Fuel Type,Voter Age','Electric,18-34');
            objDC.status__c = 'Plan Submitted';
            objDC.Data_Catalog__c = 'Test Data';
            objDC.Data_Catalog_Custom_Logic__c = '1';
            update objDC;
            Test.stopTest();
        }
    }
}