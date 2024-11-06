@IsTest
public class terminatedUserControllerTest {
    @IsTest
    static void testGetDMAList(){
        
        String UserId = UserInfo.getUserId();//'00541000003nqT2AAI';
        System.debug('userId in first ::: ' + UserId);
        User userObj = TestDataHelper.createUser(true);
        System.debug('userObj Id :::: ' + userObj.Id);
        
        PermissionSet testPermissionSet = new PermissionSet();
        testPermissionSet.Label = 'testLabel';
        testPermissionSet.Name = 'testName';
        insert testPermissionSet;
        
        PermissionSetAssignment testAssignment = new PermissionSetAssignment();
        testAssignment.AssigneeId = userObj.Id;
        testAssignment.PermissionSetId = testPermissionSet.Id;
        insert testAssignment;
        
        terminatedUserController.removeUserFromPermissionSets(userObj.Id);
    }
    /*@IsTest
    static void testGremoveUserFromPublicGroup(){
        
        String UserId = UserInfo.getUserId();//'00541000003nqT2AAI';
        System.debug('userId in first ::: ' + UserId);
        User userObj = TestDataHelper.createUser(true);
        System.debug('userObj Id :::: ' + userObj.Id);
        
        PermissionSet testPermissionSet = new PermissionSet();
        testPermissionSet.Label = 'testLabel';
        testPermissionSet.Name = 'testName';
        insert testPermissionSet;
        
        PermissionSetAssignment testAssignment = new PermissionSetAssignment();
        testAssignment.AssigneeId = userObj.Id;
        testAssignment.PermissionSetId = testPermissionSet.Id;
        insert testAssignment;
        
     //   String p = 'Public';
        
        Group grObj = new Group();
        grObj.Name = 'testGName';
       // grObj.Type = P;
        insert grObj;
        
        GroupMember grmObj = new GroupMember();
        grmObj.UserOrGroupId = userObj.Id;
        grmObj.GroupId = grObj.Id;
        insert grmObj;
        
        
        
        terminatedUserController.removeUserFromPublicGroup(userObj.Id);
    }*/
  /*  @IsTest
    static void testremoveUserFromPrivateGroups(){
        
        String UserId = UserInfo.getUserId();//'00541000003nqT2AAI';
        System.debug('userId in first ::: ' + UserId);
        User userObj = TestDataHelper.createUser(true);
        System.debug('userObj Id :::: ' + userObj.Id);
        
        PermissionSet testPermissionSet = new PermissionSet();
        testPermissionSet.Label = 'testLabel';
        testPermissionSet.Name = 'testName';
        insert testPermissionSet;
        
        PermissionSetAssignment testAssignment = new PermissionSetAssignment();
        testAssignment.AssigneeId = userObj.Id;
        testAssignment.PermissionSetId = testPermissionSet.Id;
        insert testAssignment;
        
        Group grObj = new Group();
        grObj.Name = 'testGName';
      //  grObj.Type = 'Public';
        insert grObj;
        
        GroupMember grmObj = new GroupMember();
        grmObj.UserOrGroupId = userObj.Id;
        grmObj.GroupId = grObj.Id;
        insert grmObj;
        
        
        terminatedUserController.removeUserFromPrivateGroups(userObj.Id);
    }*/
    
    
    @IsTest
    static void testremoveUserFromQueueMembership(){
        
        String UserId = UserInfo.getUserId();//'00541000003nqT2AAI';
        System.debug('userId in first ::: ' + UserId);
        User userObj = TestDataHelper.createUser(true);
        System.debug('userObj Id :::: ' + userObj.Id);
        
        PermissionSet testPermissionSet = new PermissionSet();
        testPermissionSet.Label = 'testLabel';
        testPermissionSet.Name = 'testName';
        insert testPermissionSet;
        
        PermissionSetAssignment testAssignment = new PermissionSetAssignment();
        testAssignment.AssigneeId = userObj.Id;
        testAssignment.PermissionSetId = testPermissionSet.Id;
        insert testAssignment;
        
         Group grObj = new Group();
        grObj.Name = 'testGName';
        grObj.Type = 'Queue';
        insert grObj;
        
        GroupMember grmObj = new GroupMember();
        grmObj.UserOrGroupId = userObj.Id;
        grmObj.GroupId = grObj.Id;
        insert grmObj;
        
        
        terminatedUserController.removeUserFromQueueMembership(userObj.Id);
    }
    @IsTest
    static void testremoveUserFromOpportunityTeam(){
        
        String UserId = UserInfo.getUserId();//'00541000003nqT2AAI';
        System.debug('userId in first ::: ' + UserId);
        User userObj = TestDataHelper.createUser(true);
        System.debug('userObj Id :::: ' + userObj.Id);
        
        PermissionSet testPermissionSet = new PermissionSet();
        testPermissionSet.Label = 'testLabel';
        testPermissionSet.Name = 'testName';
        insert testPermissionSet;
        
        PermissionSetAssignment testAssignment = new PermissionSetAssignment();
        testAssignment.AssigneeId = userObj.Id;
        testAssignment.PermissionSetId = testPermissionSet.Id;
        insert testAssignment;
        
        /*OpportunityTeamMember optM = new OpportunityTeamMember();
        optM.UserId = userObj.Id;
        optM.TeamMemberRole = 'Planner';
        insert optM;*/
        
        
        
        terminatedUserController.removeUserFromOpportunityTeam(userObj.Id);
    }
    @IsTest
    static void testchangeTaskStatusToCompletedForUser(){
        
        String UserId = UserInfo.getUserId();//'00541000003nqT2AAI';
        System.debug('userId in first ::: ' + UserId);
        User userObj = TestDataHelper.createUser(true);
        System.debug('userObj Id :::: ' + userObj.Id);
        
        PermissionSet testPermissionSet = new PermissionSet();
        testPermissionSet.Label = 'testLabel';
        testPermissionSet.Name = 'testName';
        insert testPermissionSet;
        
        PermissionSetAssignment testAssignment = new PermissionSetAssignment();
        testAssignment.AssigneeId = userObj.Id;
        testAssignment.PermissionSetId = testPermissionSet.Id;
        insert testAssignment;
        
        /*Task tObj = new Task();
        tObj.Status = 'Completed';
        tObj.OwnerId = userObj.Id;
        insert tObj;*/
        
        
        terminatedUserController.changeTaskStatusToCompletedForUser(userObj.Id);
    }
    
    @IsTest
    static void testeventDetails(){
        
        String UserId = UserInfo.getUserId();//'00541000003nqT2AAI';
        System.debug('userId in first ::: ' + UserId);
        User userObj = TestDataHelper.createUser(true);
        System.debug('userObj Id :::: ' + userObj.Id);
        
        PermissionSet testPermissionSet = new PermissionSet();
        testPermissionSet.Label = 'testLabel';
        testPermissionSet.Name = 'testName';
        insert testPermissionSet;
        
        PermissionSetAssignment testAssignment = new PermissionSetAssignment();
        testAssignment.AssigneeId = userObj.Id;
        testAssignment.PermissionSetId = testPermissionSet.Id;
        insert testAssignment;
        
        
        terminatedUserController.eventDetails(userObj.Id);
    }
    @IsTest
    static void testdeactivateUser(){
        
        String UserId = UserInfo.getUserId();//'00541000003nqT2AAI';
        System.debug('userId in first ::: ' + UserId);
        User userObj = TestDataHelper.createUser(true);
        System.debug('userObj Id :::: ' + userObj.Id);
        
        PermissionSet testPermissionSet = new PermissionSet();
        testPermissionSet.Label = 'testLabel';
        testPermissionSet.Name = 'testName';
        insert testPermissionSet;
        
        PermissionSetAssignment testAssignment = new PermissionSetAssignment();
        testAssignment.AssigneeId = userObj.Id;
        testAssignment.PermissionSetId = testPermissionSet.Id;
        insert testAssignment;
        
        
        terminatedUserController.deactivateUser(userObj.Id);
    }
    
    @IsTest
    static void testremoveUserFromaccountTeam(){
        
        String UserId = UserInfo.getUserId();//'00541000003nqT2AAI';
        System.debug('userId in first ::: ' + UserId);
        User userObj = TestDataHelper.createUser(true);
        System.debug('userObj Id :::: ' + userObj.Id);
        
        PermissionSet testPermissionSet = new PermissionSet();
        testPermissionSet.Label = 'testLabel';
        testPermissionSet.Name = 'testName';
        insert testPermissionSet;
        
        PermissionSetAssignment testAssignment = new PermissionSetAssignment();
        testAssignment.AssigneeId = userObj.Id;
        testAssignment.PermissionSetId = testPermissionSet.Id;
        insert testAssignment;
        
        
        terminatedUserController.removeUserFromaccountTeam(userObj.Id);
    }
    
}