@isTest
private class LeadTriggerHandlerTest {
    static testMethod void testMethod1() {
        
        Lead lead = TestUtil.getLeadRec();
        lead.PostalCode = null;
        lead.FirstName = 'Lead First';
        insert lead;
        
        List<Lead> leads = [SELECT Name FROM Lead WHERE ID=:lead.Id];
        System.debug('@@leads '+leads);

        List<Lead> oldleads = new List<Lead>();
        oldleads.addAll(leads);

        Map<ID, Lead> leadsMap = new Map<ID, Lead>();
        for (Lead prSer:leads) {
        	leadsMap.put(prSer.Id, prSer);
        	prSer.Company = 'Test Competitor';
        }
        update leads;
        System.debug('@@leads after update '+leads);

        LeadTriggerHandler leadTrigger = new LeadTriggerHandler(true,1);
        Boolean IsTriggerContext = leadTrigger.IsTriggerContext;
        Boolean IsVisualforcePageContext = leadTrigger.IsVisualforcePageContext;
        Boolean IsWebServiceContext = leadTrigger.IsWebServiceContext;
        Boolean IsExecuteAnonymousContext = leadTrigger.IsExecuteAnonymousContext;
        leadTrigger.OnBeforeInsert(leads);
        leadTrigger.OnAfterInsert(leads);
        leadTrigger.OnBeforeUpdate(leads,oldleads,leadsMap);
        leadTrigger.OnAfterUpdate(leads,oldleads,leadsMap);

        delete leads;
        undelete leads;

        //Code Coverage for LeadTriggerHandler.cls added by John King on 12 Jul-17
        
    }
    
}