@isTest
private class AccountSAMMappingTriggerHandlerTest {
    static testMethod void testMethod1(){
        test.startTest();
        User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Account acc = TestDataHelper.createAcc('Test Account', null, null, null, null, null);
        insert acc;
        AccountTeamMember atm = TestUtil.getAccountTeamMemRec(acc.Id, thisUser.Id);
        System.runAs(thisUser) {
			Account_SAM_Mapping__c asm = new Account_SAM_Mapping__c(Account__c = acc.Id, User__c = thisUser.Id );
            insert asm;
            
            Account_SAM_Mapping__c objASM = [SELECT Id, Division__c FROM Account_SAM_Mapping__c WHERE Id = :asm.Id ];
            objASM.Division__c = 'Central';
            update objASM;
        
    	}
        test.stopTest();
    }
    
    static testMethod void testMethod2(){
        User thisUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        Account acc = TestDataHelper.createAcc('Test Account', null, null, null, null, null);
        insert acc;
        AccountTeamMember atm = TestUtil.getAccountTeamMemRec(acc.Id, thisUser.Id);
        Account_SAM_Mapping__c asm = new Account_SAM_Mapping__c(Account__c = acc.Id, User__c = thisUser.Id );
        insert asm;
        
        Account_SAM_Mapping__c objASM = [SELECT Id, Division__c FROM Account_SAM_Mapping__c WHERE Id = :asm.Id ];
        objASM.Division__c = 'Central';
        update objASM;
        
        List<Account_SAM_Mapping__c> asmList = new List<Account_SAM_Mapping__c>();
        asmList.add(asm);

        test.startTest();
        AccountSAMMappingTriggerHandler.populateDivisionData(asmList);
        test.stopTest();


    }

}