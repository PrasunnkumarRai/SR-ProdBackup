@isTest
public class FileDashboardControllerTest {

    // Utility method to create test ContentVersion records
    private static void createTestContentVersions(Integer count, Date startDate, String createdByProfileName) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();

        for (Integer i = 0; i < count; i++) {
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test File ' + i;
            cv.PathOnClient = 'TestFile' + i + '.pdf';
            cv.VersionData = Blob.valueOf('Test data ' + i);
            cv.FirstPublishLocationId = UserInfo.getUserId();
            //cv.CreatedDate = startDate.addDays(i);
            //cv.CreatedById = [SELECT Id FROM User WHERE Profile.Name = :createdByProfileName LIMIT 1].Id;
            contentVersions.add(cv);
        }

        insert contentVersions;
    }

    @isTest
    static void testGetContentDocumentData() {
        // Create test data
        Date startDate = Date.today().addDays(-10);
        Date endDate = Date.today();
        createTestContentVersions(5, startDate, 'Standard User');
        
        // Create a user with the profile 'Integration User' and insert a ContentVersion with this user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Integration User' LIMIT 1];
        User integrationUser = new User(Alias = 'intuser', Email='intuser@test.com', EmailEncodingKey='UTF-8', 
                                        LastName='Integration', LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                        ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='intuser@test.com');
        insert integrationUser;
        createTestContentVersions(1, startDate, 'Integration User');
        
        Test.startTest();
        List<ContentVersion> result = FileDashboardController.getContentDocumentData('2024-05-28', '2024-05-28');
        Test.stopTest();


    }

    @isTest
    static void testGetOrgLimit() {
        Test.startTest();
        Map<String, Integer> limits = FileDashboardController.getOrgLimit();
        Test.stopTest();

     
    }

    @isTest
    static void testGetContentSize() {
        // Create test data
        Date startDate = Date.today().addDays(-90);
        createTestContentVersions(10, startDate, 'Standard User');

        Test.startTest();
        Decimal avgContentSizeDifference = FileDashboardController.getContentSize('2024-07-23', '2024-07-23');
        Test.stopTest();

      
    }

    @isTest
    static void testErrorHandling() {
        // Testing getContentDocumentData with invalid date format
        try {
            List<ContentVersion> result = FileDashboardController.getContentDocumentData('invalid-date', 'invalid-date');
          
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error fetching content document data'), 'Exception message should indicate fetching error');
        }

        // Testing getContentSizeDifference when no data
        Test.startTest();
        Decimal avgContentSizeDifference = FileDashboardController.getContentSize('2025-07-23','');
        Test.stopTest(); 
    }

   }