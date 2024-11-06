@IsTest(seeAllData=true)
public class BatchMergeTest {

    @isTest
    static void testBatchMerge() {
        List<DuplicateJobDefinition> djdList = [SELECT Id,LastModifiedDate FROM DuplicateJobDefinition WHERE SobjectType = 'Account' ORDER BY LastModifiedDate DESC];
        System.debug(djdList);
        DuplicateJob dj = null;
        for (DuplicateJobDefinition djd : djdList) {
            System.debug(djd.Id);
            List<DuplicateJob> djList = [SELECT Id from DuplicateJob where DuplicateJobDefinitionId =: djd.Id AND DuplicateJobStatus = 'Completed' ORDER BY StartDateTime DESC];
            System.debug(djList);
            if (djList.size() == 0) {
                continue;
            }
           	dj = djList[0];
        }
        
        BatchMerge batch = new BatchMerge(dj.Id,'Account','Advertiser_Account');

        // Execute the batch
        Test.startTest();
      	Database.executeBatch(batch, 200);
        Test.stopTest();
    }
}