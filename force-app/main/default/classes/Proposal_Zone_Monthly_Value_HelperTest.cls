@isTest
private class Proposal_Zone_Monthly_Value_HelperTest {
	static opportunity opp;
	static proposal__c prop;

	static testMethod void helperMethod() {

		User u = TestDataHelper.getBoomiIntegrationUser();

		System.runAs(u) {

			Account acc = TestDataHelper.createAcc('Test Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');
			acc.RecordTypeId = TestDataHelper.agencyRecTypeId;
			acc.Last_Client_Linear_Scheduled_Date__c = Date.today().adddays(-1);
			insert acc;

			System.assert(acc != null);

			opp = TestDataHelper.createopportunity('Test Opportunity', System.today(), 'Planning', 'Pipeline', acc.ID);
			insert opp;

			System.assert(opp != null);

			prop = TestDataHelper.createProposal('Test Proposal', opp.id, '76877', True);
			prop.Advertiser__c = acc.Id;
			insert prop;

			System.assert(prop != null);

			List<Proposal__c> proposals = [SELECT Id, TIM_Id__c, Opportunity__c, RecordType.Name, Advertiser__c
			                               , Agency__c FROM Proposal__c WHERE ID = :prop.Id];
			List<Id> proposalIdList = new List<Id> ();
			for (Proposal__c pr : proposals) {
				proposalIdList.add(pr.Id);
			}

			Test.starttest();

			Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Proposal Zone', prop.Id);
			insert propZone;

			System.assert(propZone != null);

			propZone.Sys_Code__c = 'TestSys';
			update propZone;

			Syscode__c sysCode = new Syscode__c(Name = 'TestSys', Market__c = '301', Type__c = 'Linear', Zone__c = '102');
			insert sysCode;

			System.assert(sysCode != null);

			List<Proposal_Zone__c> propZoneList = [SELECT Id, TIM_Status__c, Pilot_Order_Status__c, Pilot_Proposal_ID__c FROM Proposal_Zone__c WHERE Id = :propZone.Id];

			Proposal_Zone_Monthly_Value__c propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value', acc.Id, propZone.Id);
			propZoneMonthly.Broadcast_Month_Date__c = System.today().addYears(1);
			propZoneMonthly.Schedule_Type__c = 'Linear';
			insert propZoneMonthly;

			System.assert(propZoneMonthly != null);

			List<Proposal_Zone_Monthly_Value__c> propZones = [SELECT Id, Name,Advertiser__c, Broadcast_Month_Date__c FROM Proposal_Zone_Monthly_Value__c
			                                                  WHERE Id = :propZoneMonthly.Id];

			List<Proposal_Zone_Monthly_Value__c> oldPropZones = new List<Proposal_Zone_Monthly_Value__c> ();
			oldPropZones.addAll(propZones);


			Map<Id, Proposal_Zone_Monthly_Value__c> propMap = new Map<Id, Proposal_Zone_Monthly_Value__c> ();

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

			//List<Group_Status__c> groupstatusList = [SELECT Id FROM Group_Status__c WHERE Id=:groupstatus.Id];
			//Test.stopTest();
			// Test.startTest();
			Proposal_Zone_Monthly_Value_Helper.afterInsert(propZones, propMap);
			Proposal_Zone_Monthly_Value_Helper.afterUpdate(propZones, propMap);
			//Proposal_Zone_Monthly_Value_Helper.refreshAmounts(proposalIdList);
			Proposal_Zone_Monthly_Value_Helper.afterDelete(propMap);


			opp.StageName = 'Closed Lost';
			opp.Loss_Reason__c = 'Lost to Competitor TV';
			update opp;

			List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE Id = :opp.Id];
			Set<Id> oppId = new Set<Id> ();
			for (Opportunity opp : oppList) {
				oppId.add(opp.Id);
			}

			Proposal_Zone_Monthly_Value_Helper.inactivateProposals(oppId);
			Proposal_Zone_Monthly_Value_Helper.proposalZoneBeforeInsertAndUpdate(propZoneList);
			delete oldPropZones;
			Test.stopTest();
		}

	}
}