/*
    Author : MAndS 
    Date   : Jun 12-2017
    Description : test class to cover CM_DigitalCampaign related classes
    Modification History : 
*/
@isTest
public class CM_DCClientRequestPlanController_Test {
    @TestSetup static void testSetUp()
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
       objAgencyAcc.name = 'Testing Account 1';
        insert objAgencyAcc;
        
        Opportunity objOpp = TestUtil.getOpportunityRec(objAgencyAcc.Id);
        insert objOpp;
        
        Proposal__c objPro = TestUtil.getProposal(objAcc.Id,objOpp.Id);
        insert objPro;
        List<Digital_Campaign__c> lstDigCam = new List<Digital_Campaign__c>();
        Digital_Campaign__c objDC = TestUtil.getDigitalCampaign(objAcc.Id,objOpp.Id,objPro.Id);
        objDC.Source__c = 'Audience Track';
        objDC.Gross_Campaign_Cost__c = 1000;
        objDC.Total_Impressions__c = 100;
        objDC.Freewheel_O_O_Affiliate_Direct_Info__c = 'Freewheel-O&O/Affiliate/Direct:Ads Everywhere:Custom Nets:State:1:3:9';
        objDC.TTD_CTV_Info__c = 'TTD-CTV:Pre Roll Custom:Streaming TV:Zip:4:8:16';
        objDC.Freewheel_FF_OTT_Info__c = 'Freewheel-FF OTT:Ads Everywhere:Custom Nets:DMA:2:4:8';
        objDC.Freewheel_FF_TVE_Info__c = 'Freewheel-FF TVE:Ads Everywhere:Audience Segments:Zone:3:6:12';
        objDC.ClientRequestFormPlanDetails_Notes__c = 'Freewheel-O&O/Affiliate/Direct:notes1;Freewheel - FF OTT:notes2;Freewheel-FF TVE:notes3;TTD-CTV:notes4;';
        objDC.status__c = '01 Draft Campaign';
        objDC.Bypass_Apex_Execution__c = true;
        objDC.AdsE_Platform_s__c = 'VOD (Set-top Box)';
        objDC.AdsE_Network__c = 'ESPN';
        lstDigCam.add(objDC);
       
        
        Digital_Campaign__c objDC1 = TestUtil.getDigitalCampaign(objAcc.Id,objOpp.Id,objPro.Id);
        objDC1.Source__c = 'SPP';
        objDC1.Gross_Campaign_Cost__c = 1001;
        objDC1.Total_Impressions__c = 100;
        objDC1.Freewheel_O_O_Affiliate_Direct_Info__c = 'Freewheel-O&O/Affiliate/Direct:Ads Everywhere:Custom Nets:State:1:3:9';
        objDC1.TTD_CTV_Info__c = 'TTD-CTV:Pre Roll Custom:Streaming TV:Zip:4:8:16';
        objDC1.Freewheel_FF_OTT_Info__c = 'Freewheel-FF OTT:Ads Everywhere:Custom Nets:DMA:2:4:8';
        objDC1.Freewheel_FF_TVE_Info__c = 'Freewheel-FF TVE:Ads Everywhere:Audience Segments:Zone:3:6:12';
        objDC1.ClientRequestFormPlanDetails_Notes__c = 'Freewheel-O&O/Affiliate/Direct:notes1;Freewheel - FF OTT:notes2;Freewheel-FF TVE:notes3;TTD-CTV:notes4;';
        objDC1.status__c = '01 Draft Campaign';
        objDC1.Bypass_Apex_Execution__c = true;
        objDC1.AdsE_Platform_s__c = 'VOD (Set-top Box)';
        objDC1.AdsE_Network__c = 'ESPN1';
        lstDigCam.add(objDC1);
        insert lstDigCam;   
    }
    
    @isTest
    public static void prepareDataTestForEmptyIS(){
        
        List<Digital_Campaign__c> lstDigCam = [Select id,Source__c,Gross_Campaign_Cost__c,Total_Impressions__c,Campaign_Start_Date__c,Campaign_End_Date__c,
                                                Freewheel_O_O_Affiliate_Direct_Info__c,TTD_CTV_Info__c,Freewheel_FF_OTT_Info__c,
                                                Freewheel_FF_TVE_Info__c,ClientRequestFormPlanDetails_Notes__c,status__c,Bypass_Apex_Execution__c,
                                                AdsE_Platform_s__c,AdsE_Network__c from Digital_Campaign__c where Source__c='SPP'];
        System.debug('lstDigCam::'+lstDigCam);
        CM_DCClientRequestPlanController.PrepareData(lstDigCam[0].id);
       
	}
    
    @isTest
    public static void prepareDataTestForMorethen6IS(){
        List<Digital_Campaign__c> lstDigCam = [Select id,Source__c,Gross_Campaign_Cost__c,Total_Impressions__c,Campaign_Start_Date__c,Campaign_End_Date__c,
                                                Freewheel_O_O_Affiliate_Direct_Info__c,TTD_CTV_Info__c,Freewheel_FF_OTT_Info__c,
                                                Freewheel_FF_TVE_Info__c,ClientRequestFormPlanDetails_Notes__c,status__c,Bypass_Apex_Execution__c,
                                                AdsE_Platform_s__c,AdsE_Network__c from Digital_Campaign__c where Source__c='Audience Track'];
        System.debug('lstDigCam::'+lstDigCam);
        
        list<Inventory_Source__c> lstIS = insertInventorySource(lstDigCam[0],7);
        CM_DCClientRequestPlanController.PrepareData(lstDigCam[0].id);   
	}
    
    @isTest
    public static void prepareDataTestFor4IS(){
        List<Digital_Campaign__c> lstDigCam = [Select id,Source__c,Gross_Campaign_Cost__c,Total_Impressions__c,Campaign_Start_Date__c,Campaign_End_Date__c,
                                                Freewheel_O_O_Affiliate_Direct_Info__c,TTD_CTV_Info__c,Freewheel_FF_OTT_Info__c,
                                                Freewheel_FF_TVE_Info__c,ClientRequestFormPlanDetails_Notes__c,status__c,Bypass_Apex_Execution__c,
                                                AdsE_Platform_s__c,AdsE_Network__c from Digital_Campaign__c where Source__c='Audience Track'];
        System.debug('lstDigCam::'+lstDigCam);
        
        list<Inventory_Source__c> lstIS = insertInventorySource(lstDigCam[0],4);
        CM_DCClientRequestPlanController.PrepareData(lstDigCam[0].id);   
	}
    
    
    @isTest
    public static void prepareDataTestFor5IS(){
        List<Digital_Campaign__c> lstDigCam = [Select id,Source__c,Gross_Campaign_Cost__c,Total_Impressions__c,Campaign_Start_Date__c,Campaign_End_Date__c,
                                                Freewheel_O_O_Affiliate_Direct_Info__c,TTD_CTV_Info__c,Freewheel_FF_OTT_Info__c,
                                                Freewheel_FF_TVE_Info__c,ClientRequestFormPlanDetails_Notes__c,status__c,Bypass_Apex_Execution__c,
                                                AdsE_Platform_s__c,AdsE_Network__c from Digital_Campaign__c where Source__c='Audience Track'];
        System.debug('lstDigCam::'+lstDigCam);
        
        list<Inventory_Source__c> lstIS = insertInventorySource(lstDigCam[0],5);
        CM_DCClientRequestPlanController.PrepareData(lstDigCam[0].id);   
	}
    
    @isTest
    public static void randomMethodTest(){
        
        CM_DCClientRequestPlanController.getOptions();
        CM_DCClientRequestPlanController.getExclusionsPickListValues();
        
        Set<String> setDCNames = new Set<String>();
        setDCNames.add('data catlog test1');
        CM_DCClientRequestPlanController.isActiveInterestedCatalog('data catalog test1',setDCNames);                              
    }
    
    
    @isTest
    public static void updateDataTest(){
        InventorySource_Platform_Validation__c objCS = new InventorySource_Platform_Validation__c();
        objCS.Name = '1';
        objCS.Platform_Combinations__c = 'All Platforms';
        insert objCS;
        
        List<Digital_Campaign__c> lstDigCam = [Select id,Source__c,Gross_Campaign_Cost__c,Total_Impressions__c,Campaign_End_Date__c,Campaign_Start_Date__c,
                                                Freewheel_O_O_Affiliate_Direct_Info__c,TTD_CTV_Info__c,Freewheel_FF_OTT_Info__c,
                                                Freewheel_FF_TVE_Info__c,ClientRequestFormPlanDetails_Notes__c,status__c,Bypass_Apex_Execution__c,
                                                AdsE_Platform_s__c,AdsE_Network__c from Digital_Campaign__c Limit 1];


        list<Inventory_Source__c> lstIS = insertInventorySource(lstDigCam[0],6);

        CM_DCClientRequestPlanController.ResultWrap objWrap = CM_DCClientRequestPlanController.PrepareData(lstDigCam[0].Id);
        String JSONString = JSON.serialize(objWrap.lstPlanRecords);
        objWrap.lstPlanRecords = new list<CM_DCClientRequestPlanController.PlanDetailsWrap>();
        JSONString = JSON.serialize(objWrap.lstPlanRecords);
        CM_DCClientRequestPlanController.UpdateData(lstDigCam[0].Id,JSONString,4,10,200,true);                                 
    }
    
    
    private static list<Inventory_Source__c> insertInventorySource(Digital_Campaign__c dc,Integer count){
        list<Inventory_Source__c> lstIS = new list<Inventory_Source__c>();     
        for(integer i=0;i<count;i++){
            Inventory_Source__c objDef = new Inventory_Source__c();
            objDef.Digital_Campaign__c = dc.Id;
            objDef.Campaign_Start_Date__c = dc.Campaign_Start_Date__c;
            objDef.Campaign_End_Date__c = dc.Campaign_End_Date__c;
            objDef.Inventory_Resource_Type__c = 'Freewheel-O&O/Affiliate/Direct';
            objDef.SFDC_DC_Type__c = 'Ads Everywhere';
            lstIS.add(objDef);
        }  
        insert lstIS;
        return lstIS;
    }
 }