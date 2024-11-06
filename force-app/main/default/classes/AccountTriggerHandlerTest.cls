@isTest
private class AccountTriggerHandlerTest {   

    public static Id advRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Advertiser_Account' AND SobjectType = 'Account' LIMIT 1].Id;
    public static Id agencyRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Agency_Account' AND SobjectType = 'Account' LIMIT 1].Id;    
    
    static testMethod void testMethod1() {      

        List<Account> accList =new List<Account>();
        Account acc = TestDataHelper.createAcc('Testing1 Account', null, null, null, null, null);
        acc.Spectrum_Reach_Preferred__c = true;        
        accList.add(acc);
        System.debug('@@acc ' + acc);

        /* START -- added for 'ChangeAccountOwner coverage' */
        UserConnection__c uc = TestDataHelper.createUserConnection(null, null, UserInfo.getUserId(), null, 'Blah');
        INSERT uc;

        Account acc2 = TestDataHelper.createAcc('Testing Account21', null, null, null, null, null);
        acc2.Spectrum_Reach_Preferred__c = true;
        acc2.Tim_System__c = 'St. Louis Local';
        acc2.OwnerId = UserInfo.getUserId();
        acc2.AE__c = 'Blah';        
        accList.add(acc2);
        Insert accList;
        /* END -- added for 'ChangeAccountOwner coverage' */

        List<Account> accs = [SELECT Name, Spectrum_Reach_Preferred__c, Billing_Change_Status__c, RecordTypeId,
                              ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode,
                              CreatedDate, TIM_System__c,Source__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(1, accs.size());
        System.debug('@@accs ' + accs);
        AccountTriggerHandler accTrigHandler = new AccountTriggerHandler(true, 1);

        //    AccountTriggerHandler.addUserToAcctTeam(accs);

        List<Account> oldaccs = new List<Account> ();
        oldaccs.addAll(accs);

        Map<Id, Account> accsMap = new Map<Id, Account> ();
        for (Account prSer : accs) {
            accsMap.put(prSer.Id, prSer);
            prSer.AE__c = 'Blah';
        }
        UPDATE accs;
        System.debug('@@accs after update ' + accs);

        AccountTriggerHandler accTrigger = new AccountTriggerHandler(true, 1);
        Boolean IsTriggerContext = accTrigger.IsTriggerContext;
        Boolean IsVisualforcePageContext = accTrigger.IsVisualforcePageContext;
        Boolean IsWebServiceContext = accTrigger.IsWebServiceContext;
        Boolean IsExecuteAnonymousContext = accTrigger.IsExecuteAnonymousContext;
        accTrigger.OnBeforeInsert(accs);
        //accTrigger.OnAfterInsert(accs);
        accTrigger.OnBeforeUpdate(accs, oldaccs, accsMap);
        //accTrigger.OnAfterUpdate(accs,oldaccs,accsMap);

        ChangeAccountOwner.populateUserConnectionMap(accs); // Added to get coverage  
        DELETE accs;
        UNDELETE accs;

        //Code Coverage for AccountTriggerHandler.cls added by John King on 07 Jul-17
        //Code Coverage improvements added by Brett Ballantyne on 04/12/18
    }

   static testMethod void clearDiscountPercentage () {
        
        List<Account> accountList = new List<Account>();
        List<Account> updatedacctList = new List<Account>();
        Account advAcc = TestDataHelper.createAdvertiser('Test Advertiser', 'KPHB', 'Hyderabad', 'Telangana', '500090', 'India');                        
        Account agencyAcc = TestDataHelper.createAgency('Test Agency', 'Manikonda', 'Hyderabad', 'Telangana', '500090', 'India');
        accountList.add(advAcc);       
        accountList.add(agencyAcc);        
        INSERT accountList;     
        AccountTriggerHandler.isFirstTime=TRUE;
        agencyAcc.RecordTypeId = AccountUtils.localAdvertiserAccountRtId;
        advAcc.RecordTypeId = AccountUtils.agencyAccountRtId;
        updatedacctList.add(advAcc);       
        updatedacctList.add(agencyAcc);
        UPDATE updatedacctList;
    }

    static testMethod void agencyRecTypeChangeCheckonAdv () {
        List<Account> accountList = new List<Account>();
        Account accAgency = TestDataHelper.createAgency('Test Agency Account2', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');
        Account accAdv = TestDataHelper.createAdvertiser('Test Adv Account2', 'KPHB', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');
        accAdv.Agency__c = accAgency.Id;
        accountList.add(accAdv);
        accountList.add(accAgency);        
        INSERT accountList;    
        
        //Update RecordType for Agency Account
        try{
            AccountTriggerHandler.isFirstTime=TRUE;
            accAgency.RecordTypeId = advRecTypeId;
            UPDATE accAgency;
        } catch (Exception e) {
            Boolean exceptionThrown =  e.getMessage().contains('Cannot convert the record type as it is having advertiser(s) associated with it') ? true : false;
            System.AssertEquals(exceptionThrown, true);                 
        }  
    }


    static testMethod void agencyRecTypeChangeCheckOnOpp () {       
        List<Account> accountList = new List<Account>();
        Account accAdv = TestDataHelper.createAdvertiser('Test Adv Account2', 'KPHB', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');
        Account accAgency = TestDataHelper.createAgency('Test Agency Account2', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');
        accountList.add(accAdv);
        accountList.add(accAgency);        
        INSERT accountList;
        
        Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',accAdv.ID);        
        opp.Agency_Account__c=accAgency.Id;
        INSERT opp;

        //Update RecordType for Agency Account
        try{
            AccountTriggerHandler.isFirstTime=TRUE;
            accAgency.RecordTypeId = advRecTypeId;
            UPDATE accAgency;
        } catch (Exception e) {
            Boolean exceptionThrown =  e.getMessage().contains('Cannot convert the record type as it is having Opportunities associated with it') ? true : false;
            System.AssertEquals(exceptionThrown, true);
        }   
    }

    static testMethod void repFirmRecTypeChangeCheckOnProp () {        
        List<Account> accountList = new List<Account>();
        Account accRepFirm = TestDataHelper.createRepFirm('Test RepFirm Account2', 'Manikonda', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');                     

        Account accAdv = TestDataHelper.createAdvertiser('Test Adv Account2', 'KPHB', 'Hyderabad', 'Andhra Pradesh', '500084', 'India');        
        accountList.add(accAdv);
        accountList.add(accRepFirm);        
        INSERT accountList;

        Opportunity opp = TestDataHelper.createopportunity('Test Opportunity',System.today(),'Planning','Pipeline',accAdv.ID);        
        INSERT opp;

        Proposal__c prop = TestDataHelper.createProposal('Test Proposal',opp.Id,'76877',True);
        prop.TIM_Status__c = 'Proposal';  
        prop.Rep_Firm__c = accRepFirm.Id;           
        INSERT prop;   

        //Update RecordType for RepFirm Account
        try{
            AccountTriggerHandler.isFirstTime=TRUE;
            accRepFirm.RecordTypeId = agencyRecTypeId;
            UPDATE accRepFirm;
        } catch (Exception e) {
            Boolean exceptionThrown =  e.getMessage().contains('Cannot convert the record type as it is having Proposals associated with it') ? true : false;
            System.AssertEquals(exceptionThrown, true);
        }
    }
}