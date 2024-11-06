/*
###########################################################################
# Created by............: Sai Anuja
# Created Date..........: 26-June-2018
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This is test class for BatchOpportunityAmountMismatch
# Change Log:               
#

############################################################################*/


@isTest
private class BatchOpportunityAmountMismatchTest {
    static testMethod void testMethod1() { 

       	Account act = TestDataHelper.createAdvertiser('Test Adv',null,null,null,null,null);
       	insert act;

       	Opportunity opp = TestDataHelper.createopportunity(null,null,null,null,act.id);
       	opp.Amount = 100;
       	opp.Total_Forecast_Amount__c = 50;
       	insert opp;

       	Proposal__c prop = TestDataHelper.createProposal('Test prop',opp.id,null,true);
       	insert prop;

       	Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Prop Zone',prop.id);
       	insert propZone;

       	Proposal_Zone_Monthly_Value__c propZnMonVal = TestDataHelper.createProposalZoneMontly('Test Prop Zone Mon Val',act.id, propZone.id);
       	insert propZnMonVal;

       	Test.startTest();        
        BatchOpportunityAmountMismatch Btch = new BatchOpportunityAmountMismatch();
        ID batchProcessId = Database.executeBatch(Btch);  
        Test.stopTest();

        Opportunity oppUpdated = [SELECT id, name, Amount_Mismatch__c, Amount, Total_Gross_Amount__c, Total_Forecast_Amount__c, Projected_Gross_Amount__c FROM Opportunity LIMIT 1];

        System.assertEquals(oppUpdated.Total_Gross_Amount__c,oppUpdated.Amount);
        System.assertEquals(oppUpdated.Projected_Gross_Amount__c,oppUpdated.Total_Forecast_Amount__c);
    }

    static testMethod void ScheduleTest()
    {

        Test.startTest();    
        String CRON_EXP = String.valueOf(DateTime.now().addMinutes(2).format('s m H d M ? y'));
        System.debug('CRON_EXP>>>>'+CRON_EXP);
       	String jobId = System.schedule('Schedule Batch', CRON_EXP, new ScheduleOpportunityAmountMismatch());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];  
      	System.assertEquals(0, ct.TimesTriggered); 
       // System.assertNotEquals(String.valueOf(DateTime.now().addMinutes(2).format('yyyy-MM-dd HH:mm:ss')), String.valueOf(ct.NextFireTime));
      	Test.stopTest();
    }
}