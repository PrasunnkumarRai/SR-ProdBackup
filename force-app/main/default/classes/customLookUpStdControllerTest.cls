@isTest(SeeAllData =false)
public class customLookUpStdControllerTest {
    @testSetup static void setup(){
        User usr = TestDataHelper.createUser(false);
        usr.Email = 'avangari@osidigital.com';
        insert usr;
        Account acc = TestDataHelper.createAcc('Test',null,null,null,null,null);
        insert acc;
        Opportunity opp = TestDataHelper.createopportunity(null,null,null,null,acc.Id);
        insert opp;  
        CNA__c cna = TestDataHelper.createCNR(acc.Id);
        insert cna;
    }
    public static testMethod void myUnitTest(){
         Test.startTest();
         Opportunity opp = [SELECT Id FROM Opportunity limit 1];
         List<SObject> sobjList = customLookUpStdController.fetchLookUpValues(opp.Id,'CNA__c','Test');
         Test.stopTest();
    }
}