@isTest
public class SupportReq_LtngCntrlTest{
    static opportunity opp;
    static account acc;
    static Support_Request__c request;
    
    static testMethod void testMethod1() {
        
        List<User> u = [select Id, Name from User where IsActive = true AND Profile.Name = 'System Administrator' limit 2];
        System.debug('@@u Name '+u[0].Name+'######'+u[0].Name);
        acc = TestDataHelper.createAcc('Test Account', null, null, null, null, null);                        
        insert acc;
        System.assert(acc != null);
          Test.startTest();
        System.runAs(u[0]){
            opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),null,null,acc.ID);        
            insert opp;
            OpportunityTeamMember otm = new OpportunityTeamMember (OpportunityId = opp.id,UserId = u[1].id,OpportunityAccessLevel='Edit',TeamMemberRole = 'Sales Manager');
            insert otm;
            System.assert(opp != null);
            System.assert(opp != null);
            Id RecordTypeIdSR = Schema.SObjectType.Support_Request__c.getRecordTypeInfosByName().get('Planning Request').getRecordTypeId();
            request = TestDataHelper.createSupportrequest('Test Support Request', opp.Id, 2,null,null,System.today());
            request.Agency__c = acc.Id;
            request.Status__c='Draft';
            request.RecordTypeId=RecordTypeIdSR;
            request.Advertiser__c = acc.Id;
            insert request; 
            String finalRes=SupportReq_LtngCntrl.updateToSubPlanning(request.id);
            String finalRes1=SupportReq_LtngCntrl.updateToRevNeeded(request.id);
            
        }
        System.runAs(u[1]){
            String finalRes=SupportReq_LtngCntrl.updateToSubPlanning(request.id);
            String finalRes1=SupportReq_LtngCntrl.updateToRevNeeded(request.id);
        }
        Test.stopTest(); 
    }
    
     static testMethod void testMethod2() {
        
        List<User> u = [select Id, Name from User where IsActive = true AND Profile.Name = 'System Administrator' limit 2];
        System.debug('@@u Name '+u[0].Name+'######'+u[0].Name);
        acc = TestDataHelper.createAcc('Test Account', null, null, null, null, null);                        
        insert acc;
        System.assert(acc != null);
         Test.startTest();
        System.runAs(u[0]){
            opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),null,null,acc.ID);        
            insert opp;
            //OpportunityTeamMember otm = new OpportunityTeamMember (OpportunityId = opp.id,UserId = u[1].id,OpportunityAccessLevel='Edit',TeamMemberRole = 'Sales Manager');
           // insert otm;
            System.assert(opp != null);
            System.assert(opp != null);
            Id RecordTypeIdSR = Schema.SObjectType.Support_Request__c.getRecordTypeInfosByName().get('Planning Request').getRecordTypeId();
            request = TestDataHelper.createSupportrequest('Test Support Request', opp.Id, 2,null,null,System.today());
            request.Agency__c = acc.Id;
            request.Status__c='Draft';
            request.RecordTypeId=RecordTypeIdSR;
            request.Advertiser__c = acc.Id;
            insert request; 
            String finalRes=SupportReq_LtngCntrl.updateToSubPlanning(request.id);
            String finalRes1=SupportReq_LtngCntrl.updateToRevNeeded(request.id);
            
        }
        System.runAs(u[1]){
            String finalRes=SupportReq_LtngCntrl.updateToSubPlanning(request.id);
            String finalRes1=SupportReq_LtngCntrl.updateToRevNeeded(request.id);
        }
      Test.stopTest(); 
    }
}