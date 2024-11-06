public with sharing class terminatedUserController {
    @AuraEnabled
    public static void removeUserFromPermissionSets(String userId) {
        System.debug('UserId-->' + userId);
        List < PermissionSetAssignment > permissionSets = [SELECT Id, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId =: userId AND PermissionSet.IsOwnedByProfile = false];
        System.debug('PermissionSets-->' + permissionSets);
        List < PermissionSetAssignment > assignmentsToRemove = new List < PermissionSetAssignment > ();

        for (PermissionSetAssignment assignment: permissionSets) {
            assignmentsToRemove.add(assignment);
        }
        if(!assignmentsToRemove.isEmpty()){
        delete assignmentsToRemove;
        }
    }

    @AuraEnabled
    public static List < User > checkApprovingManager(String userId){
        System.debug('User ID in checkApprovingManager==>'+userId);
        List < User > ALLuser = [Select Id,Name, IsActive,Approving_Manager__c from User where Approving_Manager__c =: UserId AND IsActive=true];
        return ALLuser;
    }


    

    /*@AuraEnabled
     public static void removeUserFromPublicGroup(String userId) {
      System.debug('UserId in removeUserFromPersonalGroup Method => ' + userId);
        List<Group> publicgroup = [SELECT Id, Name, Type FROM Group WHERE Type = 'Public' AND Id IN (SELECT GroupId FROM GroupMember WHERE UserOrGroupId = :userId)];
        System.debug('Private Group List==>'+publicgroup);
        
        List<GroupMember> groupMembers = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId = :userId AND GroupId IN :publicgroup];
       System.debug('groupMembers List==>'+groupMembers);
        
        if (!publicgroup.isEmpty()) {
            for (GroupMember memberToRemove : groupMembers) {
                for (Group grp : publicgroup) {
                    if (memberToRemove.GroupId == grp.Id) {
                        delete memberToRemove;
                        System.debug('User ' + userId + ' removed from group ' + grp.Name);
                        break;
                    }
                }
            }
        } else {
            System.debug('User ' + userId + ' is not a member of any private group');
        }
    }*/

    /*@AuraEnabled
     public static void removeUserFromPrivateGroups(String userId) {
      System.debug('UserId in removeUserFromPersonalGroup Method => ' + userId);
        List<Group> privateGroups = [SELECT Id, Name, Type FROM Group WHERE Type = 'Private' AND Id IN (SELECT GroupId FROM GroupMember WHERE UserOrGroupId = :userId)];
        System.debug('Private Group List==>'+privateGroups);
        
        List<GroupMember> groupMembers = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId = :userId AND GroupId IN :privateGroups];
        System.debug('groupMembers List==>'+groupMembers);
        
        if (!privateGroups.isEmpty()) {
            for (GroupMember memberToRemove : groupMembers) {
                for (Group grp : privateGroups) {
                    if (memberToRemove.GroupId == grp.Id) {
                        delete memberToRemove;
                        System.debug('User ' + userId + ' removed from group ' + grp.Name);
                        break;
                    }
                }
            }
        } else {
            System.debug('User ' + userId + ' is not a member of any private group');
        }
    }*/


    @AuraEnabled
    public static void removeUserFromQueueMembership(String userId) {
        System.debug('UserID in removeUserFromQueueMembership Method => ' + userId);

        List < GroupMember > queueMembershipDetails = [
            SELECT Id
            FROM GroupMember
            WHERE UserOrGroupId =: userId
            AND Group.Type = 'Queue'
        ];

        if (!queueMembershipDetails.isEmpty()) {
            delete queueMembershipDetails;
        }
    }


    @AuraEnabled
    public static void removeUserFromOpportunityTeam(String userId) {
        System.debug('UserID in removeUserFromOpportunityTeam Method => ' + userId);

        List < OpportunityTeamMember > oppTeamDetails = [
            SELECT Id
            FROM OpportunityTeamMember
            WHERE UserId =: userId
            AND TeamMemberRole <> null
        ];

        if (!oppTeamDetails.isEmpty()) {
            delete oppTeamDetails;
        }
    }


    @AuraEnabled
    public static void removeUserFromaccountTeam(String userId) {
        System.debug('UserID in removeUserFromOpportunityTeam Method => ' + userId);

        List < AccountTeamMember > accTeamDetails = [
            SELECT Id
            FROM AccountTeamMember
            WHERE UserId =: userId
            AND TeamMemberRole <> null
        ];

        if (!accTeamDetails.isEmpty()) {
            delete accTeamDetails;
        }
    }



    @AuraEnabled
    public static void changeTaskStatusToCompletedForUser(String userId) {
        System.debug('UserID in changeTaskStatusToCompletedForUser Method => ' + userId);

        List < Task > tasks = [
            SELECT Id, Status
            FROM Task
            WHERE OwnerId =: userId OR WhoId =: userId
        ];

        for (Task task: tasks) {
            task.Status = 'Completed';
        }
        if(!tasks.isEmpty()){
        update tasks;
        }
    }


    @AuraEnabled
    public static List < Event > eventDetails(String UserId) {
        System.debug('UserID in eventDetails method==>' + UserID);
        List < Event > events = [SELECT Id, Subject, WhatId, WhoId FROM Event WHERE OwnerId =: UserID OR WhoId =: UserID];
        System.debug('events==>' + events);
        return events;
    }

   
    // @AuraEnabled
    // public static void removeUserFromAllCaseTeams(String userId) {
    //     List<CaseTeamMember> caseTeamMembers = [SELECT Id FROM CaseTeamMember WHERE MemberId = :userId];
    //     List<CaseTeamMember> caseTeamMembersToDelete = new List<CaseTeamMember>();
    //     for (CaseTeamMember caseTeamMember : caseTeamMembers) {
    //         caseTeamMembersToDelete.add(caseTeamMember);
    //     }
    //     delete caseTeamMembersToDelete;
    // }


    // @AuraEnabled
    // public static void removeUserFromAllAdHocCaseTeams(String userId) {
    //     List<CaseTeamMember> caseTeamMembers = [SELECT Id FROM CaseTeamMember WHERE MemberId = :userId AND TeamRoleId = null];
    //     List<CaseTeamMember> caseTeamMembersToDelete = new List<CaseTeamMember>();
    //     for (CaseTeamMember caseTeamMember : caseTeamMembers) {
    //         caseTeamMembersToDelete.add(caseTeamMember);
    //     }
    //     delete caseTeamMembersToDelete;
    // }
    @AuraEnabled
    public static void removeApprovingManager(String userId){
        System.debug('User ID in checkApprovingManager==>'+userId);
        List < User > ALLuser = [Select Id,Name, IsActive,Approving_Manager__c from User where Approving_Manager__c =: UserId AND IsActive=true];
        List < User > lstUsers = new List < User > ();
        for(User us: ALLuser){
            us.Approving_Manager__c=null;
            lstUsers.add(us);
            update lstUsers;
        }
    }

    @AuraEnabled
    public static void deactivateUser(String UserId) {
        List < User > users = [Select Id, IsActive from User where Id =: UserId];
        List < User > lstUsers = new List < User > ();
        //if(!Test.isRunningTest()){
        for (User u: users)
        {
            u.IsActive = false;
            lstUsers.add(u);
       // }
        update lstUsers;
    }
    }

    @AuraEnabled
    public static void removePermissionSetLicense(String userId){
        List<PermissionSetLicenseAssign> permissionLicense= [SELECT Id From PermissionSetLicenseAssign where AssigneeId=: userId];
        List<PermissionSetLicenseAssign> toDelete= new List<PermissionSetLicenseAssign>();
        for(PermissionSetLicenseAssign p: permissionLicense){
            toDelete.add(p);
        }
        delete permissionLicense;
        
    }
}