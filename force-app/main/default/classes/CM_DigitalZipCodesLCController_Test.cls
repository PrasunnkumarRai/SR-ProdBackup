/*
    Author : MAndS 
    Date   : Jun 12-2017
    Description : test class to cover CM_DigitalCampaign related classes
    Modification History : 
*/
@isTest
public class CM_DigitalZipCodesLCController_Test {
    public testmethod static void AddZipCodes()
    {
        /*User userObj = TestUtil.prepareUser();
        userObj.Approving_Manager__c = UserInfo.getUserId();
        //userObj.Division__c = 'West';
        //userObj.Region__c = 'IL';
        //userObj.Sales_Office__c = 'Appleton';
        insert userObj;*/
        
        //System.runAs(userObj)
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
               objDC.status__c = '01 Draft Campaign';
               objDC.CoOp__c = true;
               objDC.Bypass_Apex_Execution__c = true;
            insert objDC;
            System.Assert(objDC.Id!=null);
            
            Test.startTest();
            //Code Coverage for CM_DigitalAddAddressesLCController
            CM_DigitalAddAddressesLCController.PrepareData(objDC.Id); 
            CM_DigitalAddAddressesLCController.insertAddress(objDC.Id,'street','city','state','234' ,'type','121',true);
            CM_DigitalAddAddressesLCController.deleteAddressCC(objDC.Id,0);
            try{
                CM_DigitalAddAddressesLCController.PrepareData(null);
            }catch(Exception ex){}
            try{
                CM_DigitalAddAddressesLCController.insertAddress(null,'street','city','state','234' ,'type','121',false);
            }catch(Exception ex){}
            try{
                CM_DigitalAddAddressesLCController.deleteAddressCC(null,2);
            }catch(Exception ex){}
            
            //Code Coverage for CM_DigitalAudienceInterestsLCController
            Contextuals__c obj = new Contextuals__c();
            obj.Name = 'Test1';
            obj.label__c = 'Test1';
            insert obj;
            
            DigA_Audience_Interest__c objDAI = new DigA_Audience_Interest__c();
            objDAI.Name = 'DAI';
            objDAI.Interest__c = 'DAI';
       // 6/21     objDAI.Is_Active__c = true;
            insert objDAI;
            
            CM_DigitalAudienceInterestsLCController.PrepareData(objDC.Id);
            CM_DigitalAudienceInterestsLCController.updateAudData(objDC.Id,'test1','test2');
            try{
                objDC.Sales_Cannot_Edit_Status__c = true;
                update objDC;
                CM_DigitalAudienceInterestsLCController.PrepareData(null);
            }catch(Exception ex){}
            try{
                CM_DigitalAudienceInterestsLCController.updateAudData(null,null,null);
            }catch(Exception ex){}
            CM_DigAZoneLCController.PrepareData(objDC.Id);
            
            //Code Coverage for CM_DigitalZipCodesLCController
            Zipcode_Mapping__c objDZM = TestUtil.getDigitalZipcodeMapping();
            objDZM.Is_Active__c = true;
            insert objDZM;
            System.Assert(objDZM.Id!=null);
            
            lst = [select id from RecordType where name='SR Zone' and sobjecttype='Zipcode_Mapping__c'];
			if(lst!=null && !lst.isEmpty()){
				Zipcode_Mapping__c objDZM1 = TestUtil.getDigitalZipcodeMapping();
				objDZM1.RecordTypeId = lst[0].Id;
				objDZM1.Is_Active__c = true;
				objDZM1.SR_Zone_Name__c = 'Test_1';
				insert objDZM1;
			}
            
            CM_DigitalZipCodesLCController.PrepareData(objDC.Id);
            list<string> lst1 = CM_DigitalZipCodesLCController.getCongressionals();
            String str1 = '';
            for(string str : lst1){
                str1+=';';
            }
            list<string> lst2 = CM_DigitalZipCodesLCController.getDMA();
            String str2 = '';
            for(string str : lst2){
                str2+=';';
            }
            list<string> lst3 = CM_DigitalZipCodesLCController.getZones();
            String str3 = '';
            for(string str : lst3){
                str3+=';';
            }
            list<string> lst4;// = CM_DigitalZipCodesLCController.getDigAZones();
            CM_DigitalZipCodesLCController.insertZipCodes(objDC.Id,str1,str2,str3,'12345');
            try{
                CM_DigitalZipCodesLCController.insertZipCodes(null,null,null,null,null);
            }catch(Exception ex){}
            Test.stopTest();
            try{
               // objDC.Congressional_Districts__c = 'Cng1';
                objDC.DigA_Zone_Zip_Codes__c = 'DigA1';
                objDC.DMAs__c = 'DMA1';
                objDC.Spectrum_Reach_Zones__c = 'Zone1';
                //update objDC;
                //CM_DigitalZipCodesLCController.insertZipCodes(objDC.Id,'Cng1','DMA1','Zone1','12345');
            }catch(Exception ex){}
        }
    }
    
    public testmethod static void AddZipCodesNew()
    {
        list<User> LstuserObj = [select id from User where (Profile.Name != 'System Administrator' AND Profile.Name != 'Master - Digital Operations' AND Profile.Name != 'Master - Digital Traffic') and IsActive=true];
        if(LstuserObj!=null && !LstuserObj.isEmpty()){
            User userObj = LstuserObj[0];
            
            //System.runAs( userObj )
            {
                Account objAcc = TestUtil.getAccountRec();
                insert objAcc;
                
                list<RecordType> lst = [select id from RecordType where name='Agency Account' and sobjecttype='Account'];
                if(lst!=null && !lst.isEmpty()){
                    objAcc.RecordTypeId = lst[0].Id;
                    objAcc.Last_Client_Schedule_Date__c = Date.today();
            /// 6/21        update objAcc;
                }
                
               Account objAgencyAcc = TestUtil.getAgencyAccountRec();
                insert objAgencyAcc;
                
                Opportunity objOpp = TestUtil.getOpportunityRec(objAgencyAcc.Id);
                //objOpp.Total_Forecast_Amount__c = 10000;
                insert objOpp;
                
                
                Proposal__c objPro = TestUtil.getProposal(objAcc.Id,objOpp.Id);
                insert objPro;
                
                Digital_Campaign__c objDC = TestUtil.getDigitalCampaign(objAcc.Id,objOpp.Id,objPro.Id);
                objDC.status__c = '01 Draft Campaign';
                objDC.Bypass_Apex_Execution__c = true;
                insert objDC;
                System.Assert(objDC.Id!=null);
                
                
                //Code Coverage for CM_DigitalAddAddressesLCController
                CM_DigitalAddAddressesLCController.PrepareData(objDC.Id); 
                
                //Code Coverage for CM_DigitalAudienceInterestsLCController
                Contextuals__c obj = new Contextuals__c();
                obj.Name = 'Test1';
                obj.label__c = 'Test1';
                insert obj;
                
                DigA_Audience_Interest__c objDAI = new DigA_Audience_Interest__c();
                objDAI.Name = 'DAI';
                objDAI.Interest__c = 'DAI';
        // 6/21        objDAI.Is_Active__c = true;
                insert objDAI;
                Test.startTest();
                try{
                    CM_DigitalAudienceInterestsLCController.PrepareData(objDC.Id);
                    CM_DigitalAudienceInterestsLCController.updateAudData(objDC.Id,'test1','test2');
                }catch(Exception ex){}
                //Code Coverage for CM_DigitalZipCodesLCController
                
                lst = [select id from RecordType where name='DigA Zone' and sobjecttype='Zipcode_Mapping__c'];
				System.Assert(lst!=null);
                list<Zipcode_Mapping__c> lstZM = new list<Zipcode_Mapping__c>();
                Zipcode_Mapping__c objDZM = TestUtil.getDigitalZipcodeMapping();
                if(lst!=null && !lst.isEmpty()){
					objDZM.RecordTypeId = lst[0].Id;
					objDZM.Is_Active__c = true;
					objDZM.DigA_Zone__c = 'DigA1';
                    lstZM.add(objDZM);
                    
                    Zipcode_Mapping__c objDZM1 = TestUtil.getDigitalZipcodeMapping();
                    objDZM1.RecordTypeId = lst[0].Id;
					objDZM1.Is_Active__c = false;
					objDZM1.DigA_Zone__c = 'DigA1';
                    lstZM.add(objDZM1);
					insert lstZM;
				}
                
                lst = [select id from RecordType where name='SR Zone' and sobjecttype='Zipcode_Mapping__c'];
				if(lst!=null && !lst.isEmpty()){
					Zipcode_Mapping__c objDZM1 = TestUtil.getDigitalZipcodeMapping();
					objDZM1.RecordTypeId = lst[0].Id;
					objDZM1.Is_Active__c = true;
					objDZM1.SR_Zone_Name__c = 'Test_1';
					insert objDZM1;
				}
                
                CM_DigitalZipCodesLCController.PrepareData(objDC.Id);
                try{
                    CM_DigitalZipCodesLCController.insertZipCodes(null,null,null,null,null);
                }catch(Exception ex){}
                
                try{
                  //  objDC.Congressional_Districts__c = 'Cng1';
                    objDC.DigA_Zone_Zip_Codes__c = 'DigA1';
                    objDC.DMAs__c = 'DMA1';
                    objDC.Spectrum_Reach_Zones__c = 'Zone1';
                    update objDC;
                    
                    objDZM.DigA_Zone__c = 'DigA1';
                    update objDZM;
                    
                    CM_DigitalZipCodesLCController.insertZipCodes(objDC.Id,'Cng1','DMA1','Zone1','12345');
                }catch(Exception ex){}
                
                //Code Coverage for CM_DigAZoneLCController
                CM_DigAZoneLCController.PrepareData(objDC.Id);
                list<string> lst4 = CM_DigAZoneLCController.getDigAZones();
                CM_DigAZoneLCController.insertZipCodes(objDC.Id,'DigA1');
                CM_DigAZoneLCController.insertZipCodes(objDC.Id,'None');
                Test.stopTest();
/*  
    SRSF-979 -- removing b/c causing 101 SOQL error -- if coverage needed, must be in separate test method
              //Code coverage for CloneDigitalCampaignController
                Digital_Creative__c objDCr = TestUtil.getDigitalCreative(objDC.Id);
                insert objDCr;
                try{
                    CloneDigitalCampaignController.cloneThisDigitalCampaign(objDC.Id);
                }catch(Exception ex){}
                CloneDigitalCampaignController.getCreatableFieldsSOQL('Digital_Campaign__c','Name!=null');
                
                try{
                    OpportunityTeamMember oppTeam = new OpportunityTeamMember();
                    oppTeam.Userid = Userinfo.getuserid();
                    oppTeam.OpportunityId = objOpp.Id;
                    insert oppTeam;
                    List<OpportunityTeamMember> opptyTeams = new List<OpportunityTeamMember>();
                    opptyTeams.add(oppTeam);
                    ChangeOpptyOwner.insertOpptyTeam(opptyTeams);
                    opptyTeams = new List<OpportunityTeamMember>();
                    ChangeOpptyOwner.insertOpptyTeam(opptyTeams);
            }catch(Exception ex){}*/

            }
        }
    }
}