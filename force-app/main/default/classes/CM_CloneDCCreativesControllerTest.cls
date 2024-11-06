/*
    Author : MAndS 
    Date   : Apr 04-2018
    Description : test class to cover CM_DigitalCampaign related classes
    Modification History : 
*/
@isTest
public class CM_CloneDCCreativesControllerTest {
  public testmethod static void CloneDCCreatives()
    {

    /* User userObj = TestUtil.prepareUser();
        userObj.Approving_Manager__c = UserInfo.getUserId();
        userObj.Division__c = 'Central';
       // insert userObj;
        system.debug(userObj.UserName); */
        Test.startTest();
       // System.runAs(userObj){
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
            insert objOpp;
                        
            Proposal__c objPro = TestUtil.getProposal(objAcc.Id,objOpp.Id);
            insert objPro;
            
          //  Test.startTest();
            list<Digital_Campaign__c> lstDC = new list<Digital_Campaign__c>();
            Digital_Campaign__c objDC = TestUtil.getDigitalCampaign(objAcc.Id,objOpp.Id,objPro.Id);
            objDC.status__c = '01 Draft Campaign';
            objDC.Bypass_Apex_Execution__c = true;
            
            lstDC.add(objDC);
           // String strRecId = [Select Id From RecordType where sobjecttype = 'Digital_Campaign__c' and name='Display'].Id;
            //Digital_Campaign__c objDC1 = TestUtil.getDigitalCampaign(objAcc.Id,objOpp.Id,objPro.Id);
           // objDC1.status__c = '01 Draft Campaign';
//            objDC1.Bypass_Apex_Execution__c = true;
           // objDC1.recordtypeid=null;
            //lstDC.add(objDC1);
           // insert objDC1;
           // System.Assert(objDC.Id==null);
            
            list<Digital_Creative__c> lstDCC = new list<Digital_Creative__c>();
            Digital_Creative__c objDCr = TestUtil.getDigitalCreative(objDC.Id);
            lstDCC.add(objDCr);
            Digital_Creative__c objDCr1 = TestUtil.getDigitalCreative(objDC.Id);
            objDCr1.Creative_Name__c = 'Name2';
            lstDCC.add(objDCr1);
            insert lstDCC;

            
            
            //Code coverage for CM_CloneDCCreativesController
           // CM_CloneDCCreativesController.getDigitalCampaign(objDC.Id);
            CM_CloneDCCreativesController.getDigitalCreatives(objDC,objAgencyAcc.Id);
            
            list<CM_DCCWrap> lstWrap = new list<CM_DCCWrap>();
            CM_DCCWrap objWrap = new CM_DCCWrap(true,objDCr,objDC,objDC);
            lstWrap.add(objWrap);
            String strRes = JSON.serialize(lstWrap);
            CM_CloneDCCreativesController.CreateCloneDigitalCreative(strRes,objDC.Id,objDC.Id);
            
            lstWrap = new list<CM_DCCWrap>();
            strRes = JSON.serialize(lstWrap);
            CM_CloneDCCreativesController.CreateCloneDigitalCreative(strRes,objDC.Id,objDC.Id);
            Test.stopTest();
       // }
    }
    
    public testmethod static void CM_DCLookupCntrl()
    {
   /* User userObj = TestUtil.prepareUser();
        userObj.Approving_Manager__c = UserInfo.getUserId();
        userObj.Division__c = 'Central';
       // insert userObj;*/
        
    //    System.runAs(userObj){
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
            insert objOpp;
            
            Test.startTest();
            OpportunityTradeController.createTrade(objOpp.Id);
            Proposal__c objPro = TestUtil.getProposal(objAcc.Id,objOpp.Id);
            insert objPro;
            
            Digital_Campaign__c objDC = TestUtil.getDigitalCampaign(objAcc.Id,objOpp.Id,objPro.Id);
            objDC.status__c = '01 Draft Campaign';
            objDC.Bypass_Apex_Execution__c = true;
            objDC.Campaign_End_Date__c = system.today();
            insert objDC;
            System.Assert(objDC.Id!=null);
          //  Digital_Campaign__c objDC1 = TestUtil.getDigitalCampaign(objAcc.Id,objOpp.Id,objPro.Id);
          //  objDC1.status__c = '01 Draft Campaign';
          //  insert objDC1;
            
            Digital_Creative__c objDCr = TestUtil.getDigitalCreative(objDC.Id);
            objDCr.Creative_End_Date__c = system.today();
            insert objDCr;
            
            //Code coverage for CM_DCLookupCntrl
            //CM_DCLookupCntrl.getTooltipInfo();
            Digital_Campaign__c[] reslstDC = CM_DCLookupCntrl.lookup('DC','Digital_Campaign__c',objDC.Id,objDC.Advertiser__c);
             String q =  'SELECT Id, Status__c, Record_Lock__c FROM Digital_Creative__c Where Creative_End_Date__c != null';
            DigitalCreativeUpdaterBatchScheduler testsche = new DigitalCreativeUpdaterBatchScheduler();
           
            String sch = '0 0 23 * * ?';
            system.schedule('Test status Check', sch, testsche );
           DigitalCreativeUpdaterBatchScheduler testsche1 = new DigitalCreativeUpdaterBatchScheduler(q,1);
           system.schedule('Test status Check1', sch, testsche1 );
            Test.stopTest();
        }
   // }
}