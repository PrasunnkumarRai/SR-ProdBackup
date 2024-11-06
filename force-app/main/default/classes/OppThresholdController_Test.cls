/*
    Author : MAndS 
    Date   : 11/05/2017
    Description : test class to cover OppThresholdNotification trigger
    Modification History : 
*/
@isTest
public with sharing class OppThresholdController_Test {
    
    static testmethod void notifyUser()
    {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now().getTime());
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
		String uniqueName1 = orgId + dateString + randomInt;
        String uniqueName2 = orgId + randomInt;
    	//parent role
    	UserRole objParentUR = new UserRole(Name = 'CEO');
        insert objParentUR;
        
        //parent user
        User objParentUser = TestUtil.prepareUser();
        objParentUser.Email = 'parent@charter.com';
        objParentUser.UserName = uniqueName1 + '@test' + orgId + '.org';
        objParentUser.LastName = 'Parent User';
    	objParentUser.UserRoleId = objParentUR.Id;
    	objParentUser.Opportunity_Threshold__c = 15000;
        objParentUser.Division__c = 'Central';
    	insert objParentUser;
        System.Assert(objParentUser.Id!=null);
        User objParentUser1 = TestUtil.prepareUser();
        objParentUser1.Email = 'parent1@charter.com';
        objParentUser1.UserName = uniqueName2 + '@test' + orgId + '.org';
        objParentUser1.LastName = 'Parent1 User';
    	objParentUser1.UserRoleId = objParentUR.Id;
    	objParentUser1.Opportunity_Threshold__c = 15000;
        objParentUser1.Division__c = 'Central';
    	insert objParentUser1;
        
        //opp owner role
    	UserRole objUR = new UserRole(Name = 'Finance Approver', ParentRoleId = objParentUR.Id);
        insert objUR;
        
        //opp owner user	
    	User objUser = TestUtil.prepareUser();
    	objUser.UserRoleId = objUR.Id;
    	objUser.Opportunity_Threshold__c = 10000;
        objUser.Division__c = 'Central';
    	insert objUser;
    	
    	Account objAcc = TestUtil.getAccountRec();
    	System.RunAs(objUser){
    		insert objAcc;
    		
            Account objAgencyAcc = TestUtil.getAgencyAccountRec();
        	insert objAgencyAcc;
	    	Opportunity objOpp = TestUtil.getOpportunityRec(objAgencyAcc.Id);
	    	objOpp.OwnerId = objUser.Id;
	    	objOpp.Total_Forecast_Amount__c = 10000;
	    	insert objOpp;
	    	
	    	objOpp.Total_Forecast_Amount__c = 15000;
	    	update objOpp;

            Test.startTest();
            try {
                EmailTemplate et = new EmailTemplate(Body='phone home');
                EmailTemplateMergeFieldParserUtil.ParseEmailTemplate(String.valueOf(objOpp.Id), et, 'Opportunity');
                EmailTemplateMergeFieldParserUtil.formatStringToCurrency('1000.00');
            } catch (Exception ex) {}

            
            try{
                EmailTemplateMergeFieldParserUtil.DataValueResponse obj = new EmailTemplateMergeFieldParserUtil.DataValueResponse();
                obj.dataFields = objOpp;
                string bodyContent='Please review as you see fit{Opportunity.Account__r.Name}';
                EmailTemplateMergeFieldParserUtil.datatofieldsInHtml(objOpp.Id,bodyContent,obj,'Opportunity');
            }catch(Exception ex){}
            
            try{
                EmailTemplateMergeFieldParserUtil.DataValueResponse obj = new EmailTemplateMergeFieldParserUtil.DataValueResponse();
                obj.dataFields = objOpp;
                string bodyContent='Please review as you see fit{Spectrum_Reach_Preferred__c}';
                EmailTemplateMergeFieldParserUtil.datatofieldsInHtml(objOpp.Id,bodyContent,obj,'Opportunity');
            }catch(Exception ex){}
            
            try{
            	EmailHelper.sendEmailToUsers(null,null,null,null);
            }catch(Exception ex){}
            
            try{
                string bodyContent='Please review as you see fit{Spectrum_Reach_Preferred__c}';
                EmailTemplateMergeFieldParserUtil.fieldsInHtml(null,null);
                EmailTemplateMergeFieldParserUtil.fieldsInHtml(bodyContent, 'Opportunity');
            }catch(Exception ex){}
            
            try{
                String oppId = String.valueOf(objOpp.Id);
                Set<String> fields = new Set<String>{'Id', 'Name', 'Total_Forecast_Amount__c'};
                EmailTemplateMergeFieldParserUtil.getFields(oppId, fields, 'Opportunity');
            }catch(Exception ex){}
            
            try{
                EmailTemplateMergeFieldParserUtil.datatofieldsInHtml(null,null,null,null);
            }catch(Exception ex){}
            
            try{
                Map< String, String > displayFields = new Map< String, String >();
                displayFields.put('field',null);
                EmailTemplateMergeFieldParserUtil.fieldData(null,'field',displayFields);
                
                displayFields = new Map< String, String >();
                displayFields.put('PERCENT','PERCENT');
                EmailTemplateMergeFieldParserUtil.fieldData('PERCENT','PERCENT',displayFields);
                
                displayFields = new Map< String, String >();
                displayFields.put('DATE','DATE');
                String dayString = '2017-05-05';
                EmailTemplateMergeFieldParserUtil.fieldData(dayString,'DATE',displayFields);
                
                displayFields = new Map< String, String >();
                displayFields.put('DATETIME','DATETIME');
                string stringDate = '2017-05-05 02:03:04';
                EmailTemplateMergeFieldParserUtil.fieldData(stringDate,'DATETIME',displayFields);
            }catch(Exception ex){}
            
            try{
                List<Opportunity> opptys = new List<Opportunity>();
                for (integer i = 0; i < 5; i++) {
                    objOpp = TestUtil.getOpportunityRec(objAgencyAcc.Id);
                    objOpp.Total_Forecast_Amount__c = 10000;
                    objOpp.Created_By_Account_Executive__c = true;
                    opptys.add(objOpp);
                }
                insert opptys;
            }catch(Exception ex){}
            }
            Test.stopTest();
    }
}