/*
###########################################################################
# File..................: CreateShowSeekerProposalTest.cls
# Version...............: 1
# Created by............: Usharani   
# Created Date..........: 10-June-2020
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: Test class to get coverage for CreateShowSeekerProposal.cls
# TAO Ref#..............: NA
# Change Log:               
#
############################################################################*/
@isTest
private class CreateShowSeekerProposalTest 
{
    @testSetup
    static void prepareTestData() 
    {
        User user = TestDataHelper.createSystemAdminUser(false);
        user.ShowSeeker_User__c = true;
        INSERT user;
        System.debug(' ### user ::: ' +user.Id);
        System.runAs(user)
        {
            List<Account> accList = new List<Account>();
            Id repFirmRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Rep_Firm' AND SobjectType = 'Account' LIMIT 1].Id;
            Id agencyRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Agency_Account' AND SobjectType = 'Account' LIMIT 1].Id;
            //Create an account
            Account acc=TestDataHelper.createAdvertiser('Test Advertiser Account','123 Wright Plaza', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');
            accList.add(acc);
            System.assert(acc != null);

            Account politicalAcc = TestDataHelper.createAdvertiser('Test Advertiser Account','123 Wright Plaza', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');
            politicalAcc.Commodity_Codes__c = 'POLITICL -- Local- Republican';
            politicalAcc.Primary_Commodity__c = 'Political';
            accList.add(politicalAcc);
            System.assert(politicalAcc != null);

            //insert agency;
            Account agencyAcc = TestDataHelper.createAgency('Test Agency Account', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');
            accList.add(agencyAcc);

            // Insert RepFirm
            Account repFirmAcc = TestDataHelper.createAcc('RepFirm Account', 'Ameerpet', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                        
            repFirmAcc.RecordTypeId = repFirmRecTypeId;
            accList.add(repFirmAcc);

            INSERT accList;

            Id agencyId = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Agency_Account' LIMIT 1].Id;
            Id repFirmId = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Rep_Firm' LIMIT 1].Id;
            Id advertiserId = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Advertiser_Account' AND Political_Account__c = false LIMIT 1].Id;
            Account politicalAdvertiser = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Advertiser_Account' AND Political_Account__c = true LIMIT 1];
            Id politicalAdvertiserId = politicalAdvertiser.Id;

            //Create an opportunity
            List<Opportunity> oppList = new List<Opportunity>();
            Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',advertiserId);
            opp.Agency_Account__c = agencyId;
            opp.OwnerId = user.Id;       
            oppList.add(opp);

            Opportunity opp1 = TestDataHelper.createopportunity('Test Opportunity1',System.today(),'Planning','Pipeline',politicalAdvertiserId);
            opp1.Rep_Firm__c=repFirmAcc.Id;
            opp1.Agency_Account__c = agencyId;
            opp1.OwnerId = user.Id;       
            oppList.add(opp1);

            INSERT oppList;

            Proposal__c p  = new Proposal__c();            
            p = TestDataHelper.createProposal('Test Opportunity Proposal',opp.Id, '00000', true);
            p.RecordTypeId = TestDataHelper.oppBudgetRecTypeId;
            INSERT p;
            
            Proposal_Zone__c propZone = TestDataHelper.createProposalZone('Test Proposal Zone',p.Id);
            INSERT propZone;   
            
            Proposal_Zone_Monthly_Value__c propZoneMonthly = new Proposal_Zone_Monthly_Value__c();
            propZoneMonthly = TestDataHelper.createProposalZoneMontly('Test Proposal Zone Monthly Value',acc.Id, propZone.Id);
            propZoneMonthly.Schedule_Type__c = 'Linear';
            propZoneMonthly.Proposal_Key_Index__c = p.Id;
            propZoneMonthly.Broadcast_Month_Date__c = System.today().adddays(1);
            propZoneMonthly.gross_Amount__c = 100.00;
            
            INSERT propZoneMonthly;  

            System.debug(' ### opp Owner ::: ' +opp.OwnerId + ' ### opp agency ::: ' +opp.Agency_Account__c);
            System.assert(opp != null);
        }
    }

    static testMethod void testCreateProposalUsingSCXUpload() 
    {
        User u = [SELECT Id, Name, ShowSeeker_User__c FROM User WHERE Email = 'adminUser123@charter.com' LIMIT 1];
        System.runAs(u)
        {
            Test.StartTest();
            Opportunity opp = [SELECT Id, Name, Agency_Account__c, OwnerId, (SELECT Id FROM Proposals__r WHERE RecordTypeId = :TestDataHelper.oppBudgetRecTypeId) FROM Opportunity WHERE Name = 'Test Opportunity' AND PoliticalOpportunity__c = false LIMIT 1];

            System.debug(' #### opp :::: ' +opp);
          
            Test.setCurrentPage(Page.CreateShowSeekerProposal);
            ApexPages.currentPage().getParameters().put('OppId', opp.Id);
            ApexPages.currentPage().getParameters().put('recType','_LR');
            ApexPages.currentPage().getParameters().put('isSCX', 'true');

            System.assertEquals(true,ApexPages.currentPage().getParameters().get('OppId')!=null);
          
            Test.setMock(HttpCalloutMock.class, new ShowSeekerWebServiceMock(200));
      
            CreateShowSeekerProposal propController = new CreateShowSeekerProposal();
           // Test.StartTest();
            propController.execute();
            System.assertEquals('', propController.pageMsg);
            System.assertEquals('https://spectrumreach.showseeker.com/123456789', propController.response);
            //Remove Opportunity budget
            System.assertEquals(1, opp.Proposals__r.size());
            propController.deleteOpportunityBudget();
            Opportunity opp2 = [SELECT Id,(SELECT Id FROM Proposals__r WHERE RecordTypeId = :TestDataHelper.oppBudgetRecTypeId) FROM Opportunity WHERE Name = 'Test Opportunity' AND PoliticalOpportunity__c = false LIMIT 1];
            System.assertEquals(0, opp2.Proposals__r.size());
            Test.StopTest();
        }
    }

     static testMethod void testCreateProposalUsingCTP() 
    {
        User u = [SELECT Id, Name, ShowSeeker_User__c FROM User WHERE Email = 'adminUser123@charter.com' LIMIT 1];
        System.runAs(u)
        {
            Opportunity opp = [SELECT Id, Name, Agency_Account__c, OwnerId FROM Opportunity WHERE Name = 'Test Opportunity1' AND PoliticalOpportunity__c = true LIMIT 1];
            System.debug(' #### opp :::: ' +opp);
          
            Test.setCurrentPage(Page.CreateShowSeekerProposal);
            ApexPages.currentPage().getParameters().put('OppId', opp.Id);
            ApexPages.currentPage().getParameters().put('isSCX', 'false');

            System.assertEquals(true,ApexPages.currentPage().getParameters().get('OppId')!=null);
          
            Test.setMock(HttpCalloutMock.class, new ShowSeekerWebServiceMock(200));
      
            CreateShowSeekerProposal propController = new CreateShowSeekerProposal();
            Test.StartTest();
            propController.execute();
            System.assertEquals('', propController.pageMsg);
            System.assertEquals('https://spectrumreach.showseeker.com/123456789', propController.response);
            Test.StopTest();
        }
    }

    static testMethod void testCreateProposalFailed() 
    {
        User u = [SELECT Id, Name, ShowSeeker_User__c FROM User WHERE Email = 'adminUser123@charter.com' LIMIT 1];
        System.runAs(u)
        {
            Opportunity opp = [SELECT Id, Name, Agency_Account__c, OwnerId FROM Opportunity WHERE Name = 'Test Opportunity' AND PoliticalOpportunity__c = false LIMIT 1];

            System.debug(' #### opp :::: ' +opp);
          
            Test.setCurrentPage(Page.CreateShowSeekerProposal);
            ApexPages.currentPage().getParameters().put('OppId', opp.Id);
            ApexPages.currentPage().getParameters().put('recType','_LR');
            ApexPages.currentPage().getParameters().put('isSCX', 'true');

            System.assertEquals(true,ApexPages.currentPage().getParameters().get('OppId')!=null);
          
            Test.setMock(HttpCalloutMock.class, new ShowSeekerWebServiceMock(400));
      
            CreateShowSeekerProposal propController = new CreateShowSeekerProposal();
            Test.StartTest();
            propController.execute();
            String errorMsg = propController.response;
            System.assert(errorMsg.contains('Unable to find user'));
            Test.StopTest();
        }
    }
}