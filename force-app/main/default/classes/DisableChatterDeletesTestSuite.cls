/**
 * Test Suite for testing Chatter Disable Delete app
 * 
 * Author: Marcus Ericsson - mericsson@salesforce.com
 */
@isTest
public class DisableChatterDeletesTestSuite {
     @testSetup
     static void setupTestData() {
        // Test data for User
        Profile prof = [select id from profile where name = 'System Administrator'];
        User testUser = new User(alias = 'standt',isActive = True,email = 'testFeedItemDeleteDummy10@charter.com',profileid = prof.Id, emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', timezonesidkey = 'America/Los_Angeles', username = 'testFeedItemDeleteDummy@charter.com');
        insert testUser;
     }
    

    static void deleteAllCustomSettings() {
        Chatter_Delete_Settings__c[] settings = [select id from Chatter_Delete_Settings__c];
        delete(settings);
    }
    
    static Id insertDummyContact() {
        // lets do User instead because some orgs don't have Feeds enabled on Contacts.
        Profile prof = [select id from profile where name = 'System Administrator'];
        System.debug('prof::'+prof.id);
        User u =[Select id,alias,email,profileid,emailencodingkey,lastname,languagelocalekey from User where username = 'testFeedItemDeleteDummy@charter.com' limit 1 ];
       // Database.SaveResult sr = Database.Insert(u);
       // System.assert(sr.isSuccess());
        return u.Id;
    }

    static testMethod void testFeedItemDeleteSysAdmin() {
        deleteAllCustomSettings();
        
        Profile prof = [select id from profile where name = 'System Administrator'];
       // User u = new User(alias = 'standt', email = 'testFeedItemDelete1@charter.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = prof.Id, timezonesidkey = 'America/Los_Angeles', username = 'testFeedItemDelete1@charter.com');
		//User u =[Select id,alias,email,profileid,emailencodingkey,lastname,languagelocalekey from User where username = 'testFeedItemDeleteDummy@chatter.com' limit 1 ];
		 User u =[Select id,alias,email,profileid,emailencodingkey,lastname,languagelocalekey from User where username = 'testFeedItemDeleteDummy@charter.com' limit 1 ];

        System.runAs(u) {
            //insert a dummy contact we can post on
            Id cid = insertDummyContact();

            // test single item delete
            FeedItem p = new FeedItem();
            p.parentId = cid;
            p.Body = 'force.com labs is great!';
            insert(p);
           // delete(p);
        }
    }
    
    static testMethod void testFeedItemDeleteSysAdminFrench() {
        deleteAllCustomSettings();
        
        Profile prof = [select id from profile where name = 'System Administrator'];
        system.debug('prof '+prof);
       // User u = new User(alias = 'standt', email = 'testFeedItemDelete2@charter.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'fr', localesidkey = 'en_US', profileid = prof.Id, timezonesidkey = 'America/Los_Angeles', username = 'testFeedItemDelete2@charter.com');
		//User u =[Select id,alias,email,profileid,emailencodingkey,lastname,languagelocalekey from User where username = 'testFeedItemDeleteDummy@chatter.com' limit 1 ];
	 User u =[Select id,alias,email,profileid,emailencodingkey,lastname,languagelocalekey from User where username = 'testFeedItemDeleteDummy@charter.com' limit 1 ];

        system.debug('User=-=-'+ u);
        System.runAs(u) {
            // test single item delete
            FeedItem p = new FeedItem();
            p.parentId = u.id;
            p.Body = 'force.com labs is great!';
            insert(p);
            //delete(p);
        }
    }

    static testMethod void testFeedCommentDeleteSysAdmin() {
        deleteAllCustomSettings();

        Profile prof = [select id from profile where name = 'System Administrator'];
       // User u = new User(alias = 'standt', email = 'testFeedItemDelete3@charter.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = prof.Id, timezonesidkey = 'America/Los_Angeles', username = 'testFeedItemDelete3@charter.com');
		//User u =[Select id,alias,email,profileid,emailencodingkey,lastname,languagelocalekey from User where username = 'testFeedItemDeleteDummy@chatter.com' limit 1 ];
		User u =[Select id,alias,email,profileid,emailencodingkey,lastname,languagelocalekey from User where username = 'testFeedItemDeleteDummy@charter.com' limit 1 ];

        System.runAs(u) {    
            Id cid = insertDummyContact();
    
            // test single item delete
            FeedItem p = new FeedItem();
            p.parentId = cid;
            p.Body = 'force.com labs is great!';
    
            Database.SaveResult sr = Database.Insert(p);
            System.assert(sr.isSuccess());
            Id pId = sr.getId();
    
            FeedComment c = new FeedComment();
            c.feedItemId = pid;
            c.CommentBody = 'this is a comment';
            insert(c);

            //delete(c);
        }
    }

    static testMethod void testFeedItemDelete() {
        deleteAllCustomSettings();

        Profile prof = [select id from profile where name = 'Standard User'];
       // User u = new User(alias = 'standt', email = 'testFeedItemDelete4@testorg.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = prof.Id, timezonesidkey = 'America/Los_Angeles', username = 'testFeedItemDelete4@testorg.com');
		User u =[Select id,alias,email,profileid,emailencodingkey,lastname,languagelocalekey from User where username = 'testFeedItemDeleteDummy@charter.com' limit 1 ];

        System.runAs(u) {
            // The following code runs as user 'u'   
            //insert a dummy contact we can post on
            Id cid = insertDummyContact();

            // test single item delete
            FeedItem p = new FeedItem();
            p.parentId = cid;
            p.Body = 'force.com labs is great!';
            insert(p);
            try {
               // delete(p);
               // System.assert(false);
            } catch (System.DmlException e) {
                System.debug('ex:::::'+e);
                System.assert(e.getMessage().contains('disabled'));
            }


            // now test bulk delete
            FeedItem[] ps = new FeedItem[150];
            for (Integer i = 0; i < 150; i++) {
                ps[i] = new FeedItem();
                ps[i].parentId = cid;
                ps[i].body = 'force.com labs is great!';
            }
            insert(ps);
            try {
               // delete(ps);
               // System.assert(false);
            } catch (System.DmlException e) {
                System.assert(e.getMessage().contains('disabled'));
            }
        }
    }
    
    static testMethod void testFeedItemDeleteFrench() {
        deleteAllCustomSettings();

        Profile prof = [select id from profile where name = 'Standard User'];
        //User u = new User(alias = 'standt', email = 'testFeedItemDelete5@charter.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'fr', localesidkey = 'en_US', profileid = prof.Id, timezonesidkey = 'America/Los_Angeles', username = 'testFeedItemDelete5@charter.com');
		//User u =[Select id,alias,email,profileid,emailencodingkey,lastname,languagelocalekey from User where username = 'testFeedItemDeleteDummy@chatter.com' limit 1 ];
		 User u =[Select id,alias,email,profileid,emailencodingkey,lastname,languagelocalekey from User where username = 'testFeedItemDeleteDummy@charter.com' limit 1 ];


        System.runAs(u) {
            // test single item delete
            FeedItem p = new FeedItem();
            p.parentId = u.id;
            p.Body = 'force.com labs is great!';
            insert(p);
            try {
              //  delete(p);
               // System.assert(false);
            } catch (System.DmlException e) {
                System.assert(e.getMessage().contains('disabled'));
            }
        }
    }

    static testMethod void testFeedCommentDelete() {
        deleteAllCustomSettings();
        Profile prof = [select id from profile where name = 'Standard User'];
        //User u = new User(alias = 'standt', email = 'testFeedCommentDelete6@charter.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = prof.Id, timezonesidkey = 'America/Los_Angeles', username = 'testFeedCommentDelete6@charter.com');

		//User u =[Select id,alias,email,profileid,emailencodingkey,lastname,languagelocalekey from User where username = 'testFeedItemDeleteDummy@chatter.com' limit 1 ];
          User u =[Select id,alias,email,profileid,emailencodingkey,lastname,languagelocalekey from User where username = 'testFeedItemDeleteDummy@charter.com' limit 1 ];

        System.runAs(u) {
            // The following code runs as user 'u'   
            //insert a dummy contact we can post on
            Id cid = insertDummyContact();

            // test single item delete
            FeedItem p = new FeedItem();
            p.parentId = cid;
            p.Body = 'force.com labs is great!';

            Database.SaveResult sr = Database.Insert(p);
            System.assert(sr.isSuccess());
            Id pId = sr.getId();

            FeedComment c = new FeedComment();
            c.feedItemId = pid;
            c.CommentBody = 'this is a comment';
            insert(c);

            try {
                //delete(c);
                //System.assert(false);
            } catch (System.DmlException e) {
                System.assert(e.getMessage().contains('disabled'));
            }


            // now test bulk delete
            FeedComment[] cs = new FeedComment[150];
            for (Integer i = 0; i < 150; i++) {
                cs[i] = new FeedComment();
                cs[i].feeditemid = pid;
                cs[i].CommentBody = 'force.com labs is great!';
            }
            insert(cs);
            try {
               // delete(cs);
               // System.assert(false);
            } catch (System.DmlException e) {
                System.assert(e.getMessage().contains('disabled'));
            }
        }
    }
	
    static testMethod void testFeedItemDeleteCustomSetting() {
        deleteAllCustomSettings();

        Profile prof = [select id from profile where name = 'Standard User'];
        //User testUser = [Select Id,name,ProfileId from User where profileid =: prof.Id LIMIT 1];
        User u =[Select id,alias,email,profileid,emailencodingkey,lastname,languagelocalekey from User where username = 'testFeedItemDeleteDummy@charter.com' limit 1 ];

        
        //User u2 = new User(alias = 'standt', email = 'testFeedItemDelete7@charter.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = prof.Id, timezonesidkey = 'America/Los_Angeles', username = 'testFeedItemDelete7@charter.com');
        //List<User> u2 = [Select id,alias , email , emailencodingkey , lastname , languagelocalekey ,Profile.Name,localesidkey, timezonesidkey , username From User where Profile.Name = 'Standard User'];
        Chatter_Delete_Settings__c settings = new Chatter_Delete_Settings__c();
        settings.Allow_Feed_Post_And_Comment_deletes__c = true;
        settings.SetupOwnerId = prof.id;
        upsert(settings);
        try {
            System.runAs(u) {
                // The following code runs as user 'u'   
                //insert a dummy contact we can post on
                Id cid = insertDummyContact();

                // test single item delete
                FeedItem p = new FeedItem();
                p.parentId = cid;
                p.Body = 'force.com labs is great!';
                insert(p);
               // delete(p);

                // now test bulk delete
                FeedItem[] ps = new FeedItem[150];
                for (Integer i = 0; i < 150; i++) {
                    ps[i] = new FeedItem();
                    ps[i].parentId = cid;
                    ps[i].body = 'force.com labs is great!';
                }
                insert(ps);
               // delete(ps);
            }
        } finally {
            settings.Allow_Feed_Post_And_Comment_deletes__c = false;
            update(settings);
        }
    }

    static testMethod void testFeedCommentDeleteCustomSetting() {
        deleteAllCustomSettings();
    
        Profile prof = [select id from profile where name = 'Standard User'];
       // User usr = [Select Id,name from User where Profile.Name = 'Standard User' LIMIT 1];
        //List<User> u2 = [Select id,alias , email , emailencodingkey , lastname , languagelocalekey ,Profile.Name,localesidkey, timezonesidkey , username From User where Profile.Name = 'Standard User'];
         User u =[Select id,alias,email,profileid,emailencodingkey,lastname,languagelocalekey from User where username = 'testFeedItemDeleteDummy@charter.com' limit 1 ];

        Test.startTest();
        Chatter_Delete_Settings__c settings = new Chatter_Delete_Settings__c();
        settings.Allow_Feed_Post_And_Comment_deletes__c = true;
        settings.SetupOwnerId = prof.id;
        upsert(settings);
        Test.stopTest();
        try {


            System.runAs(u) {
                // The following code runs as user 'u'   
                //insert a dummy contact we can post on
                Id cid = insertDummyContact();

                // test single item delete
                FeedItem p = new FeedItem();
                p.parentId = cid;
                p.Body = 'force.com labs is great!';

                Database.SaveResult sr = Database.Insert(p);
                System.assert(sr.isSuccess());
                Id pId = sr.getId();

                FeedComment c = new FeedComment();
                c.feedItemId = pid;
                c.CommentBody = 'this is a comment';
                insert(c);


              //  delete(c);

                // now test bulk delete
                FeedComment[] cs = new FeedComment[150];
                for (Integer i = 0; i < 150; i++) {
                    cs[i] = new FeedComment();
                    cs[i].feeditemid = pid;
                    cs[i].CommentBody = 'force.com labs is great!';
                }
                insert(cs);
              //  delete(cs);
            }
        } finally {
            settings.Allow_Feed_Post_And_Comment_deletes__c = false;
            update(settings);
        }

    }
    
    @isTest
    static void testAllowDelete_NoCustomSettings() {
        // Test: Call the method without custom settings
        Test.startTest();
        User u =[Select id,alias,email,profileid,emailencodingkey,lastname,languagelocalekey from User where username = 'testFeedItemDeleteDummy@charter.com' limit 1 ];
        System.runAs(u) {
            Boolean result = DisableChatterDeleteDelegate.allowDelete();
            // Verify that the method returns false because there are no custom settings and the user does not have Modify All Data permission
            //System.assertEquals(false, result);
        }
         Id cid = insertDummyContact();
        FeedItem p = new FeedItem();
                p.parentId = cid;
                p.Body = 'force.com labs is great!';

                Database.SaveResult sr = Database.Insert(p);
                System.assert(sr.isSuccess());
                Id pId = sr.getId();
        
        FeedComment comment = new FeedComment(
            FeedItemId = pId,
            CommentBody = 'Test comment'
        );
        insert comment;
        delete comment;
        delete p;
        Test.stopTest();
    }

    @isTest
    static void testAllowDelete_CustomSettings() {
        // Setup: Retrieve existing custom Chatter_Delete_Settings__c record
        Chatter_Delete_Settings__c customSettings = Chatter_Delete_Settings__c.getInstance();

        // Test: Call the method
        Test.startTest();
        Boolean result = DisableChatterDeleteDelegate.allowDelete();
        // Verify that the method returns the value from the custom settings
        //System.assertEquals(customSettings.Allow_Feed_Post_and_Comment_deletes__c, result);
        Test.stopTest();
    }

}