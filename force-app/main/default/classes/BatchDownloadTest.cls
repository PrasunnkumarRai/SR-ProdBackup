@IsTest(SeeAllData=true)
public class BatchDownloadTest {

    @isTest
    static void testBatchDownload() {
        DuplicateJobDefinition djd = [SELECT Id,LastModifiedDate FROM DuplicateJobDefinition WHERE SobjectType = 'Account' ORDER BY LastModifiedDate DESC LIMIT 1][0];
        DuplicateJob dj = [SELECT Id from DuplicateJob where DuplicateJobDefinitionId =: djd.Id LIMIT 1][0];
    

        BatchDownload batch = new BatchDownload(dj.Id, 'Account', 'Agency_Account');

        Test.startTest();
        Database.executeBatch(batch, 100);
        Test.stopTest();
    }
}