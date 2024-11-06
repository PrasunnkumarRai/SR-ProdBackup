@IsTest private class LeadConversion_Test  {
    private static testMethod void testLeadConvert() {
        Account agency = TestDataHelper.createAgency('WidgetsRUs', null, null, null, null, null);
        insert agency;
        system.assertNotEquals(agency, null);

    //    Contact myContact = TestDataHelper.createContact('Jones', agency.Id, 'rJones@somePlace.com', null);
        
        Lead myLead = new Lead(agency__c = agency.Id, LastName='Farble', firstName = 'Arley', Company = 
'WidgetsRUs', status = 'Converted');
      //  Lead.Commodity_Codes__c = 'ADV_MKG -- Marketing';
       // SObjectType.Lead.Fields.Commodity_Codes__c.PicklistValues[0].getValue();
        insert myLead;

        Opportunity myOppty = TestDataHelper.createopportunity(null, null, null, null, agency.Id);

        ApexPages.StandardController sc = new ApexPages.StandardController(myLead);
        LeadConversionCC leadConv = new LeadConversionCC(sc);
        PageReference pageRef = Page.LeadConversion;
        pageRef.getParameters().put('id', String.valueOf(myLead.Id));
        Test.setCurrentPage(pageRef);


        try {
            leadConv.convertLead();
        } catch (Exception ex) {
            system.debug('--->> lead conversion in LeadConversion_Test failed: ' + ex.getMessage());
        }

        leadConv.objOpportunity = myOppty;

        leadConv.getChangedAccount();
        leadConv.getLookedUpAccount();


        List<SelectOption> leadOpts = leadConv.LeadStatus;
        List<SelectOption> taskOpts = leadConv.TaskStatus;
        List<SelectOption> priorityOpts = leadConv.TaskPriority;
        system.debug('------->> leadOpts = ' + leadOpts);
        leadConv.strSelectedAccount = String.valueOf(agency.Id);

        leadConv.sendOwnerEmail = true;
        leadConv.doNotCreateOppty = false;
        try {
            leadConv.convertLead();
        } catch (Exception ex) {
            system.debug('--->> lead conversion in LeadConversion_Test failed: ' + ex.getMessage());
        }
        leadConv.PrintError('Error');
        List<Database.Error> lde = new List<Database.Error>();
        leadConv.PrintErrors(lde);


        leadConv.getChangedAccount();
        LeadConversionLCCC.getLeadDetails(myLead.Id);
   //     LeadConversionLCCC.getLeadStatus();
     //   LeadConversionLCCC.getAccounts(myLead);
        LeadConversionLCCC.getLookedUpAccount(String.valueOf(agency.Id));
        LeadConversionLCCC.getRecordOwnerTeamRole(UserInfo.getUserId());
        LeadConversionLCCC.getRecordOwnerProfileName(UserInfo.getUserId());
        try {
            LeadConversionLCCC.convertLead(myLead, String.valueOf(agency.Id), false,
                                             'someOppName', String.valueOf(UserInfo.getUserId()));
        } catch (Exception ex) {
            system.debug('--->> lead conversion (CCC1) in LeadConversion_Test failed: ' + ex.getMessage());
        }
        try {
            LeadConversionLCCC.convertLead(myLead, 'NEW', true,
                                             'someOppName', String.valueOf(UserInfo.getUserId()));
        } catch (Exception ex) {
            system.debug('--->> lead conversion (CCC2) in LeadConversion_Test failed: ' + ex.getMessage());
        }
		try {
            mylead.Primary_Commodity__c='Political';
            mylead.Commodity_Codes__c= 'POLITICL -- Governor- Independent';
            update mylead;
            LeadConversionLCCC.convertLead(myLead, 'NEW', true,
                                             'someOppName', String.valueOf(UserInfo.getUserId()));
        } catch (Exception ex) {
            system.debug('--->> lead conversion (CCC2) in LeadConversion_Test failed: ' + ex.getMessage());
        }

     }
}