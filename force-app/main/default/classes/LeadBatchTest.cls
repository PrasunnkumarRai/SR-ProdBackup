@isTest(SeeAllData=false)
public class LeadBatchTest {

    static void prepareTestData() {

        User usr = TestDataHelper.createSystemAdminUser(true);
        User u = TestDataHelper.createUser(false);
        u.ManagerId = usr.Id;
        insert u;

        system.debug('manger::'+u);

        System.runAs(u){
            Group gr = New Group();
            gr.Name = 'Test grp';
            gr.Type = 'Queue';
            insert gr;

            GroupMember groupMember = new GroupMember();
            groupMember.GroupId = gr.id;
            groupMember.UserOrGroupId = UserInfo.getUserId();
            insert groupMember;

            Lead ObjLead = new Lead();
            ObjLead = new lead();
            ObjLead.Company='Test Co';
            ObjLead.FirstName='Arley';
            ObjLead.LastName='Miyan';
            ObjLead.Email = 'testing@test.com';
            ObjLead.Phone = '3039723552';
            //ObjLead.Commodity_Codes__c = 'ADV_MKG -- Public Service Annoucement';
            ObjLead.Status = 'New';
            ObjLead.OwnerId = UserInfo.getUserId(); 
            insert ObjLead;

            system.debug('lead::'+ObjLead.Owner_Manager__c);
        }
    }

    public static testmethod void LeadBatchTest(){
        prepareTestData();
        test.starttest();
        LeadBatch lb1 = new LeadBatch();
        string chron = '0 0 23 * * ?';
        system.schedule('Test Schedule', chron, lb1);
        test.stoptest();
    } 

}