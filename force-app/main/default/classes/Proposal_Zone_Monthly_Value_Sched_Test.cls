/*
###########################################################################
# File..................: Proposal_Zone_Monthly_Value_Sched_Test.cls
# Version...............: 
# Created by............: Anusha Pagidimarri 
# Created Date..........: 06-29-2017
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: Test class for Proposal_Zone_Monthly_Value_Scheduler
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/
@isTest(seeAllData=false)
private class Proposal_Zone_Monthly_Value_Sched_Test {

	static opportunity opp;
    static  proposal__c prop;

    static testMethod void testScheduler() {

    	User u = TestDataHelper.getBoomiIntegrationUser();
        
        System.runAs(u){
        
            Account acc = TestDataHelper.createAcc('Test Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                        
            acc.RecordTypeId = TestDataHelper.agencyRecTypeId;
            insert acc;

            System.assert(acc != null);
            
            opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',acc.ID);        
            insert opp;

            System.assert(opp != null);

            prop = TestDataHelper.createProposal('Test Proposal',opp.id,'76877',True);  
            insert prop;
            
            System.assert(prop != null);

            List<Proposal__c> proposals = [SELECT Id, TIM_Id__c,Opportunity__c, RecordType.Name, Advertiser__c
                                            ,Agency__c FROM Proposal__c WHERE ID=:prop.Id];
            List<Id> proposalIdList = new List<Id>();
            for (Proposal__c pr:proposals) {
                proposalIdList.add(pr.Id);
            }
            
            Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Proposal Zone',prop.Id);
            insert propZone;

            System.assert(propZone != null);

            propZone.Sys_Code__c = 'TestSys';
            update propZone;

            Syscode__c sysCode = new Syscode__c(Name = 'TestSys',Market__c='301',Type__c='Linear',Zone__c='102');
            insert sysCode;

            System.assert(sysCode != null);

            List<Proposal_Zone__c> propZoneList = [SELECT Id,TIM_Status__c FROM Proposal_Zone__c WHERE Id=:propZone.Id];

            Proposal_Zone_Monthly_Value__c propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value',acc.Id,propZone.Id);
            propZoneMonthly.IsActive__c = true;
            propZoneMonthly.Broadcast_Month_Date__c = date.today().addDays(-30);
            insert propZoneMonthly;

            System.assert(propZoneMonthly != null);

            List<Proposal_Zone_Monthly_Value__c> propZones = [SELECT Id, Name FROM Proposal_Zone_Monthly_Value__c
                                                            WHERE Id=:propZoneMonthly.Id];

            List<Proposal_Zone_Monthly_Value__c> oldPropZones = new List<Proposal_Zone_Monthly_Value__c>();
            oldPropZones.addAll(propZones);


            Map<Id,Proposal_Zone_Monthly_Value__c> propMap = new Map<Id,Proposal_Zone_Monthly_Value__c>();
            
            propMap.putAll(oldPropZones);

            propZones[0].Schedule_Type__c = 'Linear';
            propZones[0].Gross_Amount__c = 20;
            update propZones;

            Group__c gr = TestDataHelper.createGroup('Test Group');
            insert gr;

            Group_Status__c groupstatus = TestDataHelper.createGroupStatus('Test Group Status', gr.Id);
            groupstatus.Is_Active__c = true;
            groupstatus.Is_Entry__c = false;
            groupstatus.Is_Exit__c = true;
            groupstatus.Is_Rejection__c = false;
            insert groupstatus;

            Test.startTest();
	        DateTime r = DateTime.now();
	        String nextTime = String.valueOf(r.second()) + ' ' + String.valueOf(r.minute()) + ' ' + String.valueOf(r.hour() ) + ' * * ?'; 
	        String jobId = system.schedule('Test Proposal_Zone_Monthly_Value_Scheduler', nextTime, new Proposal_Zone_Monthly_Value_Scheduler());  
	        List<CronTrigger> ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
	        System.assertEquals(1, ct.size());
	        Test.stopTest();
        }

    }

}