@isTest(SeeAllData=true)
private class DuplicateJobControllerTest {
    
    @isTest
    static void testGetGroupedAccountDataFromExcel() {
        // Create test Account records
        Account acc1 = new Account(Name = 'Test Account 1');
        insert acc1;

        Account acc2 = new Account(Name = 'Test Account 2');
        insert acc2;
        
		Account acc3 = new Account(Name = 'Test Account 3');
        insert acc3;

        Account acc4 = new Account(Name = 'Test Account 4');
        insert acc4;

        // Create test data for the method
        List<Map<String, Object>> rawData = new List<Map<String, Object>>();
        Map<String, Object> dataMap = new Map<String, Object>{
            'id' => 0,
            'sfids' => new List<Object>{acc1.Id, acc2.Id}
        };
        rawData.add(dataMap);
        Map<String, Object> dataMap1 = new Map<String, Object>{
            'id' => 1,
            'sfids' => new List<Object>{acc3.Id, acc4.Id}
        };
		rawData.add(dataMap1);
        // Call the method to test
        DuplicateJobController.getGroupedAccountDataFromExcel(rawData);
    }
    
     @isTest
    static void testGetGroupedAccountDataFromExcel2() {
        // Create test Account records
        Account acc1 = new Account(Name = 'Test Account 1');
        insert acc1;

        Account acc2 = new Account(Name = 'Test Account 2');
        insert acc2;
        
		Account acc3 = new Account(Name = 'Test Account 3');
        insert acc3;

        Account acc4 = new Account(Name = 'Test Account 4');
        insert acc4;

        // Create test data for the method
        List<Map<String, Object>> rawData = new List<Map<String, Object>>();
        Map<String, Object> dataMap = new Map<String, Object>{
            'id' => 0,
            'sfids' => new List<Object>{acc1.Id, acc2.Id}
        };
        rawData.add(dataMap);
        Map<String, Object> dataMap1 = new Map<String, Object>{
            'id' => 1,
            'sfids' => new List<Object>{acc3.Id}
        };
		rawData.add(dataMap1);
        // Call the method to test
       DuplicateJobController.getGroupedAccountDataFromExcel(rawData);

 
    }
    
     @isTest
    static void testGetGroupedAccountDataFromExcel3() {
        // Create test Account records
        Account acc1 = new Account(Name = 'Test Account 1', Last_Client_Schedule_Date__c = Date.today());
        insert acc1;

        Account acc2 = new Account(Name = 'Test Account 2', Last_Client_Schedule_Date__c = Date.today().addDays(-1));
        insert acc2;
        
		Account acc3 = new Account(Name = 'Test Account 3', Last_Client_Schedule_Date__c = Date.today().addDays(-1));
        insert acc3;
      

        // Create test data for the method
        List<Map<String, Object>> rawData = new List<Map<String, Object>>();
        Map<String, Object> dataMap = new Map<String, Object>{
            'id' => 0,
            'sfids' => new List<Object>{acc1.Id, acc2.Id, acc3.Id}
        };
        rawData.add(dataMap);

        // Call the method to test
        DuplicateJobController.getGroupedAccountDataFromExcel(rawData);

    }
    
    @isTest
    static void testMergeDuplicates() {
        // Create test data
        Account acc1 = new Account(Name = 'Test Account 1');
        insert acc1;

        Account acc2 = new Account(Name = 'Test Account 2');
        insert acc2;

        String groupChangesString = '{"selectedId":"' + acc1.Id + '","childIds":["' + acc2.Id + '"],"Projected_Segment_Code__c":"C","Projected_Segment_Name__c":"Brick and Mortar Bargain Buyers","Complete_Billing_Address__c":"37048 US Hwy 27, Haines City, FL 33883, USA"}';
        // Call the method to test
        DuplicateJobController.mergeDuplicates(groupChangesString);
    }
    
     @isTest
    static void testMergeAllDuplicates() {
        // Create test data
        Account acc1 = new Account(Name = 'Test Account 1');
        insert acc1;

        Account acc2 = new Account(Name = 'Test Account 2');
        insert acc2;
        
        // Account acc3 = new Account(Name = 'Test Account 3');
        // insert acc3;

        // Account acc4 = new Account(Name = 'Test Account 4');
        // insert acc4;
		List<String> listOfString = new List<String>();
        
        String groupChangesString = '{"selectedId":"' + acc1.Id + '","childIds":["' + acc2.Id + '"],"Projected_Segment_Code__c":"C","Projected_Segment_Name__c":"Brick and Mortar Bargain Buyers","Complete_Billing_Address__c":"37048 US Hwy 27, Haines City, FL 33883, USA"}';
        listOfString.add(groupChangesString);
        String s = DuplicateJobController.getSObjectType(acc1.Id);


        DuplicateJobController.mergeAllDuplicates(listOfString);
        
    }
    
    @isTest
    static void testGetGroupedAccountData() {
        DuplicateJob dj = [SELECT Id,DuplicateJobDefinition.SobjectType, DuplicateJobDefinitionId, DuplicateJobStatus from DuplicateJob where DuplicateJobDefinition.SobjectType = 'Account' AND DuplicateJobStatus= 'Completed' LIMIT 1][0];
  
        List<DuplicateJobController.GroupedAccount> result = DuplicateJobController.getGroupedAccountData(dj.Id, 100, null, 'Account', 'Agency_Account');
        List<DuplicateJobController.ObjectMetadataWrapper> l = DuplicateJobController.getObjectAndReqdRecordType();
        
        Map<String,String> m =  DuplicateJobController.getDuplicateJobDetails(dj.Id);
        
        List<Map<String,String>> lm = DuplicateJobController.getComboboxOptions('Traffic_Id_Element__c');
        
        
        Traffic_Id_Element__c tide1 = new Traffic_Id_Element__c();
        insert tide1;
        
        Traffic_Id_Element__c tide2 = new Traffic_Id_Element__c();
        insert tide2;
        
        String groupChangesString = '{"selectedId":"' + tide1.Id + '","childIds":["' + tide2.Id + '"]}';
        // Call the method to test
        DuplicateJobController.mergeDuplicateTrafficIdElements(groupChangesString);
        
        Traffic_Id_Element__c tide3 = new Traffic_Id_Element__c();
        insert tide3;
        
        Traffic_Id_Element__c tide4 = new Traffic_Id_Element__c();
        insert tide4;
        
    List<String> ll = new List<String>();
        ll.add( '{"selectedId":"' + tide3.Id + '","childIds":["' + tide4.Id + '"]}');
        DuplicateJobController.mergeAllDuplicateTrafficIdElements(ll);
        
        Map<String, String> fieldLabels = DuplicateJobController.getFieldSetLabels('CI_Fields', 'Account');
        
        Account acc1 = new Account(Name='Test Account 1');
    Account acc2 = new Account(Name='Test Account 2');
    insert new List<Account>{acc1, acc2};
    
  
    List<String> accountIds = new List<String>{acc1.Id, acc2.Id};

   	 DuplicateJobController.updateMergedAccounts(accountIds);
        
         List<Not_Merged_Ids_for_Landscaping__mdt> ids = DuplicateJobController.getNotMergedIds();
        
         Map<String, String> fieldsForUI = DuplicateJobController.getTrafficIdFieldsForUI();
        
        List<Map<String, String>> jfkd =  DuplicateJobController.getRecordTypeMap('Account');
        
        List<String> jfkdfd =  DuplicateJobController.getDuplicateJobStatus();
        
        List<Landscaping_UI_Fields_Metadata__mdt> p = DuplicateJobController.getUIFields('Account', 'Agency_Account');

        AggregateResult x = DuplicateJobController.getJobDetails();
       
       DuplicateJobController.runJobAgain(dj.DuplicateJobDefinitionId);
        
        String hgdh = DuplicateJobController.getCurrentDateTime();
        DuplicateJobController.sendDownloadEmail(dj.Id, 'Account', 'Agency_Account');
        
        List<String> uyfi = DuplicateJobController.findNextParentId(dj.Id);
    }

}