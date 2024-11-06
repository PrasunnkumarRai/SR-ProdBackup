@isTest
public class DuplicateManagementTest {

    @testsetup
    static void createOneAccountRecord(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {

            Account acc = new Account(name = 'TestAccount', phone='9898787878');
            insert acc;

            EmailTemplate e = new EmailTemplate (developerName = 'Duplicate_Record_Created', FolderId = UserInfo.getUserId(), TemplateType= 'text', Name = 'Duplicate Record Created'); // plus any other fields that you want to set
            insert e;
        }

    }

    public static testMethod void testFirstSituation(){
        DuplicateRule dR = [select id from DuplicateRule where DeveloperName = 'Custom_Account_Name' LIMIT 1];
        DuplicateRecordSet dupRS = new DuplicateRecordSet(DuplicateRuleId = dR.id);
        insert dupRS;

        Test.startTest();
        Account acc = new Account(name = 'TestAccount', phone='9898787878');
        Database.DMLOptions insertDML = new Database.DMLOptions(); 
        insertDML.DuplicateRuleHeader.AllowSave = true; 
        Database.SaveResult sr = Database.insert(acc, insertDML);
        DuplicateRecordItem dup = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId=acc.id);
        insert dup;
        update dup;
        Test.stopTest();

    }
}