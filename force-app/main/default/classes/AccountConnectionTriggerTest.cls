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
@isTest(seeAllData= false)
private class AccountConnectionTriggerTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        User u = TestDataHelper.getBoomiIntegrationUser();

         AccountConnection__c connection2;
         AccountConnection__c connectionR;

        System.runAs(u){
        	//Agency Insertion
			Account acc = TestDataHelper.createAcc('TestAccount','9212 Pett Street','Camaillo','CA','912345','USA');
			acc.RecordTypeID = TestDataHelper.agencyRecTypeId;
			insert acc;
			//Rep Firm Insertion
			Account accR = TestDataHelper.createAcc('TestAccount1','92 Petit Street','Caillo','CA','9345','USA');
			accR.RecordTypeID = TestDataHelper.repFirmRecTypeId;
			insert accR;
			//Advertiser Insertion
			Account acc2 = TestDataHelper.createAcc('TestAccount2','9212 Pet St','Camarillo','CA','96112','USA');
			acc2.RecordTypeID = TestDataHelper.advRecTypeId;
			insert acc2;
			
			//Agency Account Connection
            AccountConnection__c connection = TestDataHelper.createAccountConnection(acc.ID); 
            connection.AgencyTimID__c  = '123';
            insert connection;
            AccountConnection__c connection3 = TestDataHelper.createAccountConnection(acc.ID);  
			connection3.AgencyTimID__c  = ''; 
            insert connection3;
			AccountConnection__c connection4 = TestDataHelper.createAccountConnection(acc.ID);  
			connection4.AgencyTimID__c  = '0'; 
            insert connection4;
			
			//Rep Firm Account Connection
            connectionR = TestDataHelper.createAccountConnection(accR.ID); 
            connectionR.AgencyTimID__c  = '1234';
            insert connectionR;
            AccountConnection__c connectionR1 = TestDataHelper.createAccountConnection(accR.ID);  
			connectionR1.AgencyTimID__c  = ''; 
            insert connectionR1;
			AccountConnection__c connectionR2 = TestDataHelper.createAccountConnection(accR.ID);  
			connectionR2.AgencyTimID__c  = '0'; 
            insert connectionR2;
            
            //Advertiser Account Connection
            connection2 = TestDataHelper.createAccountConnection(acc2.ID);
            connection2.Tim_ID__c  = 'Test';   
            insert connection2;
			AccountConnection__c connection5 = TestDataHelper.createAccountConnection(acc2.ID);
            connection5.Tim_ID__c  = '';   
            insert connection5;
            
	 		List<AccountConnection__c> accConList =[Select  TIM_ID__c, TIM_System__c, Account__c,AgencyTimId__c,Account_Record_Type__c  
                                                    FROM AccountConnection__c
                                                    WHERE Account__c =:acc.Id];

            System.assertEquals(3, accConList.size());                                        
            AccountConnectionTriggerHelper helper = new AccountConnectionTriggerHelper();
            //helper.afterInsert(accConList);
            
        }

        update connection2;
        update connectionR;
        
    }
}