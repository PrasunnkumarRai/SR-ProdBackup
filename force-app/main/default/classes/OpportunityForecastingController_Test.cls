/*
    Author : MAndS 
    Date   : Jun 12-2017
    Description : test class to cover OpportunityForecastingController_Test related classes
    Modification History : 
*/
@isTest
public class OpportunityForecastingController_Test {
    public static string oppId;
    public testmethod static void PrepareKanbanView()
    {
        /*User userObj = TestUtil.prepareUser();
        userObj.Approving_Manager__c = UserInfo.getUserId();
        insert userObj;*/

        list<User> lstUser = [select id,Division__c from User where Profile.name = 'System Administrator' and IsActive=true limit 1];
        User userObj;
        if(lstUser!=null && !lstUser.isEmpty()){
            userObj = lstUser[0];
            userObj.Division__c = 'Central';
            update userObj;
        }
        else{
            userObj = TestUtil.prepareUser();
            userObj.Approving_Manager__c = UserInfo.getUserId();
            userObj.Division__c = 'Central';
            insert userObj;
        }
            
        System.runAs( userObj ){
            list<String> objFields = new list<String>();
            objFields.add('Id');
            objFields.add('Name');
            objFields.add('Amount');
            objFields.add('StageName');
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
            
            map<String, Id> mapRecordTypeId = new map<String, Id>();
            for( RecordType accRT : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account' AND ( DeveloperName='Agency_Account' OR DeveloperName='Advertiser_Account' )]){
                mapRecordTypeId.put( accRT.DeveloperName, accRT.Id );
            }
            Account AdsAccount = new Account(Name='Test Ads Account', RecordTypeId=mapRecordTypeId.get('Advertiser_Account'), BillingStreet = '235 High St',
                    BillingCity = 'Morgantown', BillingState = 'WV', BillingPostalCode = '26505',
                    BillingCountry = 'USA', ShippingStreet = '235 High St', ShippingCity = 'Morgantown', ShippingState = 'WV',
                    ShippingPostalCode = '26505', ShippingCountry = 'USA', Legal_Entity_Name__c='Test Legal Name' );
            insert AdsAccount;
        
            Opportunity objOpp = TestUtil.getOpportunityRec(objAgencyAcc.Id);
            objOpp.StageName = 'ClosedWon';
            objOpp.AccountId = AdsAccount.Id;
            objOpp.Total_Forecast_Amount__c = 100;
            insert objOpp;
            System.assertNotEquals(null,objOpp.Id);
            oppId = objOpp.Id;
            System.debug('objOpp--'+objOpp.Id);
            
            OpportunityTeamMember oppTeam = new OpportunityTeamMember();
            oppTeam.Userid = userObj.Id;
            oppTeam.OpportunityId = objOpp.Id;
            insert oppTeam;
            
            Proposal__c objPro = TestUtil.getProposal(objAcc.Id,objOpp.Id);
            insert objPro;
            
            Proposal_Zone__c objPZ = new Proposal_Zone__c();
            objPZ.Proposal__c = objPro.Id;
            insert objPZ;
            
            Proposal_Zone_Monthly_Value__c objPZMV = new Proposal_Zone_Monthly_Value__c();
            objPZMV.Proposal_Zone__c = objPZ.Id;
            objPZMV.Advertiser__c = objAcc.Id;
            insert objPZMV;
            
            Opportunity_Forecasting_Filter__c objOFF = new Opportunity_Forecasting_Filter__c();
            objOFF.Name = 'My Opportunities';
            objOFF.Visible_To_Me__c = true;
            objOFF.Scope__c = 'My Opportunities';
            insert objOFF;
            
            Opportunity_Forecasting_Filter__c objOFF1 = new Opportunity_Forecasting_Filter__c();
            objOFF1.Name = 'My Team';
            objOFF1.Visitble_To_My_Team__c = true;
            objOFF.Scope__c = 'My Team';
            insert objOFF1;
            
            Opportunity_Forecasting_Filter__c objOFF2 = new Opportunity_Forecasting_Filter__c();
            objOFF2.Name = 'All Opportunities';
            objOFF2.Visitble_To_My_Team__c = true;
            objOFF.Scope__c = 'All Opportunities';
            insert objOFF2;
            
            Opportunity_Forecasting_Filter_Values__c objOFFV = new Opportunity_Forecasting_Filter_Values__c();
         //   objOFFV.Opportunity_Scope__c = 'My Opportunities';
            objOFFV.Opportunity_Forecasting_Filter__c = objOFF.Id;
            objOFFV.API_Name__c = 'Name';
            objOFFV.Operator__c = 'not equals';
            objOFFV.Value__c = '';
            insert objOFFV;
            
            Opportunity_Forecasting_Filter_Values__c objOFFV1 = new Opportunity_Forecasting_Filter_Values__c();
            //objOFFV1.Opportunity_Scope__c = 'My Team';
            objOFFV1.Opportunity_Forecasting_Filter__c = objOFF1.Id;
            objOFFV1.API_Name__c = 'Name';
            objOFFV1.Operator__c = 'contanis';
            objOFFV1.Value__c = 'test';
            insert objOFFV1;
            
            Opportunity_Forecasting_Filter_Values__c objOFFV2 = new Opportunity_Forecasting_Filter_Values__c();
            //objOFFV1.Opportunity_Scope__c = 'My Team';
            objOFFV2.Opportunity_Forecasting_Filter__c = objOFF2.Id;
            objOFFV2.API_Name__c = 'Name';
            objOFFV1.Operator__c = 'not equal to';
            objOFFV1.Value__c = '';
            insert objOFFV2;

            Test.startTest();
            OpportunityForecastingController objOFC = new OpportunityForecastingController();
            try{
                OpportunityForecastingController.getKanbanWrapper('Opportunity', objFields, 'StageName', null, 'My Opportunities',true,null,false);
                OpportunityForecastingController.getKanbanWrapper('Opportunity', objFields, 'StageName', null, 'My Opportunities1',false,null,true);
                OpportunityForecastingController.getKanbanWrapper('Opportunity', objFields, 'StageName', ' name!=null ', 'My Opportunities1',false,null,true);
            }catch(Exception ex){}
            try{
                OpportunityForecastingController.createFilter('My Opportunities','All users can see this filter',false);
            }catch(Exception ex){}
            try{
                OpportunityForecastingController.changeCurrentListView('Opportunity', objFields, 'StageName', 'My Opportunities',false,false,null,false,'test');
            }catch(Exception ex){}
            try{
                OpportunityForecastingController.changeCurrentListView('Opportunity', objFields, 'StageName', 'My Opportunities',false,true,null,true,'test');
            }catch(Exception ex){}
            OpportunityForecastingController.getOpptyFields();
            OpportunityForecastingController.getListViewDevName('My Opportunities');
            OpportunityForecastingController.isCurrentUserAdmin();
            OpportunityForecastingController.formatDateTime('12/9/2020','DATE');
            
/*            OpportunityAPIFieldMapping__c objFMCS = new OpportunityAPIFieldMapping__c();
            objFMCS.Name = 'OPPORTUNITY.CLOSE_DATE';
            objFMCS.Opportunity_API_Name__c = 'CloseDate';
            insert objFMCS;*/
            //OpportunityForecastingController.sanitizeMetaDataNames('OPPORTUNITY.CLOSE_DATE');
            OpportunityForecastingController.fieldIsString('STRING');
            try{
                //OpportunityForecastingController.getUpdateStage(objOpp.Id,'StageName','Closed Lost','StageName','Closed Lost');
            }catch(Exception ex){}
            OpportunityForecastingController.getOpptyListViews();
            
            OpportunityForecastingController.saveFilterData('My Opportunities','My Opportunities',true,false,'All',false, null, 'Name', 'Name', 'contains', 'te', 'STRING','BillingStreet', 'BillingStreet', 'contains', 'Valley', 'STRING','BillingCity', 'BillingCity', 'contains', 'dallas', 'STRING');
            OpportunityForecastingController.saveFilterData('My Opportunities','My Team', false,true, 'Manager',false, null, 'Name', 'Name', 'contains', 'te', 'STRING','BillingStreet', 'BillingStreet', 'contains', 'Valley', 'STRING','BillingCity', 'BillingCity', 'contains', 'dallas', 'STRING');
            OpportunityForecastingController.saveFilterData('My Team',null, false,false,'Manager',false, null, 'Name', 'Name', 'contains', 'te', 'STRING','BillingStreet', 'BillingStreet', 'contains', 'Valley', 'STRING','BillingCity', 'BillingCity', 'contains', 'dallas', 'STRING');
            OpportunityForecastingController.saveFilterData('My Team',null, false,true,'Manager',false, null, 'Name', 'Name', 'contains', 'te', 'STRING','BillingStreet', 'BillingStreet', 'contains', 'Valley', 'STRING','BillingCity', 'BillingCity', 'contains', 'dallas', 'STRING');
            List<Opportunity_Forecasting_Filter__c> listViews = [select Id, Name, Visible_To_All_Users__c, Visible_To_List_of_Users__c, Visible_To_Me__c, Visitble_To_My_Team__c, User_List__c,Scope__c, 
                                                                (select Id, API_Name__c, Field_Data_Type__c, Field_Name__c, Operator__c, Value__c from Opportunity_Forecasting_Filter_Values__r)
                                                                from Opportunity_Forecasting_Filter__c limit 3];

          
            try{    
                if(listViews!=null && !listViews.isEmpty()){
                    OpportunityForecastingController.formatWhereClause(listViews[0]);
                    OpportunityForecastingController.formatWhereClause(listViews[1]);
                    OpportunityForecastingController.formatWhereClause(listViews[2]);
                    listViews[2].Scope__c = 'My Team';
                    OpportunityForecastingController.formatWhereClause(listViews[2]);
                    listViews[2].Scope__c = 'Manager';
                    listViews[2].User_List__c = userObj.Id;
                    OpportunityForecastingController.formatWhereClause(listViews[2]);
                }
            }catch(Exception ex){}
            OpportunityForecastingController.formatCSVList('One,Two','=',false);
            OpportunityForecastingController.formatCSVList('One,Two','=',true);
            OpportunityForecastingController.formatCSVList('Name','One,Two','=',false);
            OpportunityForecastingController.formatCSVList('Name','One,Two','=',true);
            for(integer i=1;i<=13;i++){ 
                if(i>9)
                    OpportunityForecastingController.getMonthCode(i+'');
                else
                    OpportunityForecastingController.getMonthCode('0'+i);
            }
            try{
                delete objOpp;
                OpportunityForecastingController.getKanbanWrapper('Opportunity', objFields, 'StageName', null, 'My Opportunities',false,null,true);
            }catch(Exception ex){}
            try{
                OpportunityForecastingController.deleteListView(listViews[0].Id,false);
                OpportunityForecastingController.deleteListView(listViews[0].Id,true);
            }catch(Exception ex){}
            try{
                OpportunityForecastingController.deleteListView(listViews[1].Id,false);
                OpportunityForecastingController.deleteListView(listViews[1].Id,true);
            }catch(Exception ex){}
            try{
                //OpportunityForecastingController.deleteListView(listViews[2].Id,false);
                //OpportunityForecastingController.deleteListView(listViews[2].Id,true);
            }catch(Exception ex){}
            try{
                OpportunityForecastingController.formatToSimpleDate(date.today());
            }catch(Exception ex){}
            try{
                OpportunityForecastingController.setSession(objOFF.Id);
                OpportunityForecastingController.getSession();
            }catch(Exception ex){}
            try{
                OpportunityForecastingController.formatSpecialDate('12 test test test');
                OpportunityForecastingController.getUpdateStage(objOFF.Id, 'Name', 'kanbanNewValue', 'lossReasonField', 'lossReason');
            }catch(Exception ex){}
 /*           try{
                List<OpportunityTeamMember> opptyTeams = new List<OpportunityTeamMember>();
                opptyTeams.add(oppTeam);
                ChangeOpptyOwner.insertOpptyTeam(opptyTeams);
                opptyTeams = new List<OpportunityTeamMember>();
                ChangeOpptyOwner.insertOpptyTeam(opptyTeams);
            }catch(Exception ex){}
*/        }
        test.StopTest();
    }
}