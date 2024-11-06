/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AccountBulkMergeControllerTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        User newUser = TestDataHelper.createUser(true);
       // User newAdminUser = TestDataHelper.createSystemAdminUser(true);
        
        //System.runAs(u){
     //   System.runAs(newAdminUser){
        
    	Account parentAcc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA'); 
        Account parentAcc1=TestDataHelper.createAdvertiser('Rep Firm','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA'); 
        Account parentAcc2=TestDataHelper.createAdvertiser('Agency Account_child','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA');                        
        //acc.MergeAccount__c = parentAcc.id;
        insert parentAcc;
        insert parentAcc1;
        insert parentAcc2; 
        
        System.assert(parentAcc != null);
        
        //Create child account
        Account childAcc = TestDataHelper.createAdvertiser('Advertisers Account_child','1233 Wright Plazas', 'Omahas', 'NEs', '68120', 'USA');
        
        Account childAcc1 = TestDataHelper.createAgency('Agency Account_child','124 Wright Plaza Child', 'Omaha', 'NW', '68131', 'USA');                                            
        Account childAcc2 = TestDataHelper.createAgency('Rep Firm','124 Wright Plaza', 'Omaha', 'NW', '68131', 'USA'); 
        childAcc.MergeAccount__c = parentAcc.id;
        insert childAcc;
        insert childAcc1;
        insert childAcc2;   
        
        Test.startTest();
         List<Account_Bulk_Merge__c> abmcd=new List<Account_Bulk_Merge__c>();
        Account_Bulk_Merge__c abm = new Account_Bulk_Merge__c();
        abm.Child_Account__c = childAcc.Id;
        abm.Parent_Account__c = parentAcc1.Id;
        abmcd.add(abm);
        insert abmcd;
        List<Account_Bulk_Merge__c> abmcd1=new List<Account_Bulk_Merge__c>();
        Account_Bulk_Merge__c abm1 = new Account_Bulk_Merge__c();
        abm.Child_Account__c = childAcc1.Id;
        abm.Parent_Account__c = parentAcc.Id;
        abmcd.add(abm1);
        insert abmcd1;
        List<Account_Bulk_Merge__c> abmcd2=new List<Account_Bulk_Merge__c>();
        Account_Bulk_Merge__c abm2 = new Account_Bulk_Merge__c();
        abm.Child_Account__c = childAcc2.Id;
        abm.Parent_Account__c = parentAcc1.Id;
        abmcd.add(abm2);
        insert abmcd2;
Account_Transfer_Tool__c att=new Account_Transfer_Tool__c();
att.Status__c = 'Transfer in Progress';
insert att;
        List<Account_Transfer_Mapping__c> atmls= new List<Account_Transfer_Mapping__c>();
          Account_Transfer_Mapping__c  ATM=new Account_Transfer_Mapping__c();
ATM.Account__c=childAcc.Id;
ATM.Account_Transfer_Simulation__c=att.Id;
//ATM.Account_Transfer_Simulation__r.Status__c='Transfer in Progress';
        atmls.add(ATM);	
Insert atmls;
        AccountBulkMergeController abmc = new AccountBulkMergeController();
        abmc.getBulkAccountMerge();
        abmc.batchExecute();
        AccountBulkMerge  anm=new AccountBulkMerge();
        // anm.checkOppOwnerIsActive(abmcd);
        // anm.checkOppOwnerIsActive(abmcd1);
        // anm.checkOppOwnerIsActive(abmcd2);
//  anm.checkAccTransfer(abmcd);   
   anm.createAccountMergeLog(abmcd1);
        Test.stoptest();
        }
   // }
 static testMethod void myUnitTest1() {
        // TO DO: implement unit test
        User newUser = TestDataHelper.createUser(true);
       // User newAdminUser = TestDataHelper.createSystemAdminUser(true);
        
        //System.runAs(u){
     //   System.runAs(newAdminUser){
        
    	Account parentAcc=TestDataHelper.createAdvertiser('Advertiser Account','123 Wright Plaza', 'Omaha', 'NE', '68130', 'USA'); 
       
        //acc.MergeAccount__c = parentAcc.id;
        insert parentAcc;
              
        System.assert(parentAcc != null);
        
        //Create child account
        Account childAcc = TestDataHelper.createAdvertiser('Advertisers Account_child','1233 Wright Plazas', 'Omahas', 'NEs', '68120', 'USA');
        
        Account childAcc1 = TestDataHelper.createAgency('Agency Account_child','124 Wright Plaza Child', 'Omaha', 'NW', '68131', 'USA');                                            
        Account childAcc2 = TestDataHelper.createAgency('Rep Firm','124 Wright Plaza', 'Omaha', 'NW', '68131', 'USA'); 
        childAcc.MergeAccount__c = parentAcc.id;
        insert childAcc;
        insert childAcc1;
        insert childAcc2;   
        
        Test.startTest();
         List<Account_Bulk_Merge__c> abmcd=new List<Account_Bulk_Merge__c>();
        Account_Bulk_Merge__c abm = new Account_Bulk_Merge__c();
        abm.Child_Account__c = childAcc.Id;
        abm.Parent_Account__c = parentAcc.Id;
        abmcd.add(abm);
        insert abmcd;
        List<Account_Bulk_Merge__c> abmcd1=new List<Account_Bulk_Merge__c>();
        Account_Bulk_Merge__c abm1 = new Account_Bulk_Merge__c();
        abm.Child_Account__c = childAcc1.Id;
        abm.Parent_Account__c = parentAcc.Id;
        abmcd.add(abm1);
        insert abmcd1;
        List<Account_Bulk_Merge__c> abmcd2=new List<Account_Bulk_Merge__c>();
        Account_Bulk_Merge__c abm2 = new Account_Bulk_Merge__c();
        abm.Child_Account__c = childAcc2.Id;
        abm.Parent_Account__c = parentAcc.Id;
        abmcd.add(abm2);
        insert abmcd2;

        AccountBulkMergeController abmc = new AccountBulkMergeController();
        abmc.getBulkAccountMerge();
        abmc.batchExecute();
        AccountBulkMerge  anm=new AccountBulkMerge();
        // anm.checkOppOwnerIsActive(abmcd);
      
 
        Test.stoptest();
        }
}