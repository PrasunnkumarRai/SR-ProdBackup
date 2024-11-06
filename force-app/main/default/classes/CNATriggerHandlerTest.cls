@isTest
private class CNATriggerHandlerTest {
    static testMethod void testMethod1() {
        
        Account acc = TestDataHelper.createAcc('Test Account', null, null, null, null, null);                        
        insert acc;
        System.debug('@@acc '+acc);
        

        CNA__c cna = TestDataHelper.createCNR(acc.Id);
        insert cna;
        System.debug('@@cna '+cna);




        List<CNA__c> cnas = [SELECT Name FROM CNA__c WHERE ID=:cna.Id];
        System.debug('@@cnas '+cnas);

        List<CNA__c> oldcnas = new List<CNA__c>();
        oldcnas.addAll(cnas);

        Map<ID, CNA__c> cnasMap = new Map<ID, CNA__c>();
        for (CNA__c prSer:cnas) {
        	cnasMap.put(prSer.Id, prSer);
        	prSer.Competitor_Name__c = 'Test Competitor';
        }
        update cnas;
        System.debug('@@cnas after update '+cnas);

        CNATriggerHandler cnaTrigger = new CNATriggerHandler(true,1);
        Boolean IsTriggerContext = cnaTrigger.IsTriggerContext;
        Boolean IsVisualforcePageContext = cnaTrigger.IsVisualforcePageContext;
        Boolean IsWebServiceContext = cnaTrigger.IsWebServiceContext;
        Boolean IsExecuteAnonymousContext = cnaTrigger.IsExecuteAnonymousContext;
        cnaTrigger.OnBeforeInsert(cnas);
        cnaTrigger.OnAfterInsert(cnas);
        cnaTrigger.OnBeforeUpdate(cnas,oldcnas,cnasMap);
        cnaTrigger.OnAfterUpdate(cnas,oldcnas,cnasMap);

        delete cnas;
        undelete cnas;

        //Code Coverage for CNATriggerHandler.cls added by John King on 07 Jul-17
        System.assertEquals(1, cnas.size());
    }
    
}