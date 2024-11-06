@isTest
private class FileEnhanceControllerTest {

    @testSetup static void setup() {
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        ContentDistribution cd = new ContentDistribution();
        cd.Name = cv.Title;
        cd.ContentVersionId = cv.Id;
        cd.PreferencesAllowViewInBrowser = true;
        cd.PreferencesLinkLatestVersion = true;
        cd.PreferencesNotifyOnVisit = false;
        cd.PreferencesPasswordRequired = false;
        cd.PreferencesAllowOriginalDownload = true;
        insert cd;    
    }

    @isTest
    static void testUploadFile() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test File',
            PathOnClient = '/testfile.txt',
            VersionData = Blob.valueOf('Test file content')
        );
        insert testContentVersion;
        String fileName = 'testfile.txt';
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test file content'));
        Id recordId = testAccount.Id;
        String title = 'Test File';
        Id contentDocumentId = testContentVersion.ContentDocumentId; 
        Test.startTest();
        String result = FileEnhanceController.uploadFile(fileName, base64Data, recordId, title, contentDocumentId);
        Test.stopTest();
        ContentVersion updatedContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id];
        System.assertNotEquals(null, updatedContentVersion.ContentDocumentId);
    }

   @isTest
   public static void testShowData() {
        String testSearchKey = 'TestSearch';
        Account acc = new Account(Name = 'TesNbAbhay');
        insert acc;

        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test File 1';
        cv1.FirstPublishLocationId = acc.Id;
        cv1.PathOnClient = 'dummy-file.pdf';
        cv1.VersionData = Blob.valueOf('This is a sample file content.');
        insert cv1;
       
        ContentVersion cv2 = new ContentVersion();
        cv2.Title = 'Another File';
        cv2.FirstPublishLocationId = acc.Id;
        cv2.PathOnClient = 'dummy-file1.pdf';
        cv2.VersionData = Blob.valueOf('This is a sample file content222.');
        insert cv2;
        FileEnhanceController.showData(acc.Id, 'logo');
        FileEnhanceController.showData(acc.Id, '');
    }

    @isTest
    static void testGetUserEmail() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User user = new User(alias = 'standt', email = 'standarduser123@charter.com',
        emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
        localesidkey = 'en_US', profileid = p.Id, isActive = true,
        timezonesidkey = 'America/Los_Angeles', username = 'standarduser123@testorgosius.com');
        insert user;
        User returnedUser = FileEnhanceController.getUserEmail('Test%', user.Id);
        System.assertEquals(user.Id, returnedUser.Id, 'User Id does not match');
        System.assertEquals(user.Email, returnedUser.Email, 'Email does not match');
    }

    @isTest
    static void testGetRelatedFilesByRecordId() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'Test.txt',
            VersionData = Blob.valueOf('Test content')
        );
        insert testContentVersion;
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id].ContentDocumentId;
        ContentDocumentLink testLink = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = testAccount.Id
        );
        insert testLink;
        Map<Id, String> result = FileEnhanceController.getRelatedFilesByRecordId(testAccount.Id, testContentVersion.Id);
        System.assertEquals(1, result.size(), 'Expected one result');
        System.assertEquals(testContentVersion.Title, result.get(contentDocumentId), 'Unexpected title');
    }

   @isTest
    static void testSendDocumentLinkEmail() {
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'test.txt',
            VersionData = Blob.valueOf('Test content'),
            IsMajorVersion = true
        );
        insert testContentVersion;
        ContentDocument testContentDocument = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :testContentVersion.Id];
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User user = new User(alias = 'standt', email = 'standarduser123@charter.com',
        emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
        localesidkey = 'en_US', profileid = p.Id, isActive = true,
        timezonesidkey = 'America/Los_Angeles', username = 'standarduser123@testorgosius.com');
        insert user;
        ContentDocumentLink testLink = new ContentDocumentLink(
            ContentDocumentId = testContentDocument.Id,
            LinkedEntityId = user.Id,
            ShareType = 'C'
        );
        insert testLink;
        System.runAs(user) {
            User currentUser = [SELECT Name,email FROM User WHERE Id = :UserInfo.getUserId()];
            String contentDocumentId = testContentDocument.Id;
            String recipientEmail = 'recipient@example.com'; // Replace with a valid recipient email
            String senderName = currentUser.Name;
            String senderEmail = currentUser.email;
            String access = 'V';
            Test.startTest();
            //FileEnhanceController.sendDocumentLinkEmail(contentDocumentId, recipientEmail, senderName, senderEmail, access);
            Test.stopTest();
            List<EmailMessage> sentEmails = [SELECT Id, ToAddress, Subject FROM EmailMessage];
            //System.assertEquals(1, sentEmails.size());
           // System.assertEquals(recipientEmail, sentEmails[0].ToAddress);
           // System.assertEquals(senderName + ' has shared a file you can edit on Chatter', sentEmails[0].Subject);
        } 
    }
    
  @isTest
static void testGeneratePublicLink() {
    ContentVersion cv = new ContentVersion(
        Title = 'Test Content',
        PathOnClient = 'test.txt',
        VersionData = Blob.valueOf('Test data')
    );
    insert cv;
    List<String> contentVersionIds = new List<String>{cv.Id};
    String emailSubject = 'Test Email Subject';
    String emails = 'test1@example.com,test2@example.com';
    String messageToSend = 'Test message';
    Test.startTest();
    List<ContentDistribution> result = FileEnhanceController.generatePublicLink(
        contentVersionIds,
        emails,
        messageToSend,
        28,
        false,
        true
    );
    Test.stopTest();

    // Now query both PreferencesAllowViewInBrowser and PreferencesPasswordRequired fields
    result = [SELECT Id, PreferencesAllowViewInBrowser, PreferencesPasswordRequired FROM ContentDistribution WHERE Id IN :result];

    System.assertNotEquals(null, result);
    System.assertEquals(1, result.size()); 
    ContentDistribution createdDistribution = result[0];
    System.assertEquals(true, createdDistribution.PreferencesAllowViewInBrowser);
   // System.assertEquals(true, createdDistribution.PreferencesPasswordRequired);
    delete result;
}


    @isTest
    public static void getExternalViewerInfoTest(){
        //Get Content Version
        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion ];
        System.assertEquals(cvList.size(), 1);
        
        //Get Content Documents
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assertEquals(cdList.size(), 1);
        
        FileEnhanceController.getExternalViewerInfo(cdList[0].id);
    }

    @isTest
    static void testFindRecords() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        List<sObject> result = FileEnhanceController.findRecords('Test', 'Account');
        System.assertEquals(1, result.size());
        System.assertEquals(testAccount.Id, result[0].get('Id'));
        System.assertEquals(testAccount.Name, result[0].get('Name'));
    }
    
    @isTest
    static void testUpdateExternalFileShareSettings() {
        // Mock the metadata deployment result
        //Test.setMock(MetadataServiceMock.class, new MetadataServiceMock());
        //Test.startTest();
        //FileEnhanceController.updateExternalFileShareSettings(true, false, 30);
    
        //Metadata mData = new Metadata();
        
        //Test.stopTest();
//        mData.DeployCallback callback = mData.getLastCallback();
    
    }
    
     @isTest
    static void testHandleDelete() {
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        FileEnhanceController.handleDelete(cdList[0].Id);
        //FileEnhanceController.executeFilesAdminUtilityBatch(True,True,9,True);

      //  List<ContentDocument> deletedContent = [SELECT Id FROM ContentDocument WHERE Id = :cv.ContentDocumentId];
        //System.assertEquals(0, deletedContent.size(), 'ContentDocument should be deleted');
    }
    
    @isTest
    static void testCreateConDocLink() {
        Profile directorOfSalesProfile = [SELECT Id FROM Profile WHERE Name = 'Master - Director of Sales' LIMIT 1];
          User usObj1 = new User(
            FirstName = 'trew',
            LastName = 'test',
            ProfileId = directorOfSalesProfile.Id,
            Username = 't@charter.com',
            Email = 't@charter.com',    
            Alias = 'puser',                     
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
            );
        
        insert usObj1;
        
        Profile directorOfSalesProfile1 = [SELECT Id FROM Profile WHERE Name = 'Master - Director of Sales' LIMIT 1];
          User usObj2 = new User(
            FirstName = 'trew',
            LastName = 'test',
            ProfileId = directorOfSalesProfile1.Id,
            Username = 't1@charter.com',
            Email = 't1@charter.com',    
            Alias = 'puser',                     
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
            );
        
        insert usObj2;
        
        Profile directorOfSalesProfile2 = [SELECT Id FROM Profile WHERE Name = 'Master - Director of Sales' LIMIT 1];
          User usObj3 = new User(
            FirstName = 'trew',
            LastName = 'test',
            ProfileId = directorOfSalesProfile2.Id,
            Username = 't2@charter.com',
            Email = 't2@charter.com',    
            Alias = 'puser',                     
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
            );
        
        insert usObj3;
        
        
        
       /* ContentVersion cv = new ContentVersion();
        cv.Title = 'T';
        cv.PathOnClient = 'Tpath';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv; */
        
        
        List<String> uIdList = new List<String>{usObj1.Id,usObj2.Id,usObj3.Id};

            System.debug('udIdList ::: ' + uIdList);
        
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        FileEnhanceController.createConDocLink(uIdList,cdList[0].Id,'V');
        //Test.stopTest();

    }
    
    
}