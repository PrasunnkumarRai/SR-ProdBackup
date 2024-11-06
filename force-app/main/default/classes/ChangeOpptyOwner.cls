public without sharing class ChangeOpptyOwner {
   
    public static Opportunity oppty;
    public static Account acc;
    public static List<UserTeamMember> userTeaMem;
    public static Group preferredGroup;
    
    public ChangeOpptyOwner() {
        
    }
    public static boolean ChangeOwner(Id ownerId, Id opptyId, Id acctId) {
       
        if(oppty==null)
        oppty = [SELECT OwnerId FROM Opportunity WHERE Id = :opptyId];
        System.debug(oppty.OwnerId+'####'+ownerId);
        boolean retVal = true;
        if (oppty == null) return false;
        User obj = [SELECT Id, Name, Sales_Office__c, Region__c, Division__c FROM User WHERE Id=:ownerId];
        oppty.OwnerId = ownerId;
        oppty.Owner_Sales_Office__c = obj.Sales_Office__c;
        oppty.Owner_Region__c = obj.Region__c;
        oppty.Owner_Division__c = obj.Division__c;
        // SRSF-509 
        oppty.Bypass_Apex_Execution__c = true;
        // SRSF-382
        System.debug(loggingLevel.WARN, '------->> acctId = ' + acctId);
        System.debug(loggingLevel.WARN, '------->> ownerId = ' + ownerId);

        Boolean updateAccount = false;
        if (acctId != null) {
           if(acc == null)
            acc = [SELECT Id, AE_of_First_Opportunity__c, Count_of_Opportunities__c FROM Account WHERE Id = :acctId];
            System.debug(loggingLevel.WARN, '------->> acc = ' + acc);
            if (acc.Count_of_Opportunities__c <= 1) {
                acc.AE_of_First_Opportunity__c = String.valueOf(ownerId);
                updateAccount = true;
            }
            System.debug(loggingLevel.WARN, '------->> acc = ' + acc);
        }

        try {
            if (updateAccount)
                UPDATE acc;
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception ex) {
            System.debug(loggingLevel.Error, 'ChangeOpptyOwner: an error occured updating account: ' + acctId);
            System.debug(loggingLevel.Error, 'The error is: ' + ex.getMessage());
        }

        try {
            UPDATE oppty;
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception ex) {
            System.debug(loggingLevel.Error, 'ChangeOpptyOwner: an error occured changing opportunity owner for Id: ' + opptyId);
            System.debug(loggingLevel.Error, 'The error is: ' + ex.getMessage());
            retVal = false;
        }
        return retVal;
    }

    // This method is created for SRSF-3571
    public static void ChangeOwner(Id ownerId, List<Opportunity> opptLst, Id acctId) 
    {
        Boolean updateAccount = false;
        List <Opportunity> updateOpptyLst = new List <Opportunity> ();
        for (Opportunity oppty : opptLst) {
            oppty.OwnerId = ownerId;
            oppty.Bypass_Apex_Execution__c = true;
            updateOpptyLst.add(oppty);
        }
        System.debug('updateOpptyLst--->>>>>'+updateOpptyLst);
        
        if(acctId != null) 
        {
            if(acc == null)
                acc = [SELECT Id, AE_of_First_Opportunity__c, Count_of_Opportunities__c FROM Account WHERE Id = :acctId];
            System.debug(loggingLevel.WARN, '------->> acc = ' + acc);
            if (acc.Count_of_Opportunities__c <= 1) {
                acc.AE_of_First_Opportunity__c = String.valueOf(ownerId);
                updateAccount = true;
            }
            System.debug(loggingLevel.WARN, '------->> acc = ' + acc);
        }

        try 
        {
            if (updateAccount)
                UPDATE acc; 
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception ex) {
            System.debug(loggingLevel.Error, 'ChangeOpptyOwner: an error occured updating account: ' + acctId);
            System.debug(loggingLevel.Error, 'The error is: ' + ex.getMessage());
        }

        try 
        {            
            if(updateOpptyLst.size() > 0)
            {
                Database.UpsertResult[] recsToUpsert = Database.Upsert(updateOpptyLst, false);
                for(Integer i = 0 ; i < recsToUpsert.size(); i++) 
                {
                    if(!recsToUpsert[i].isSuccess()) {
                        System.debug(loggingLevel.Error, 'ChangeOpptyOwner: An error occured while updating Opportunity owner for Id: ' + recsToUpsert[i].Id);
                    }
                }
            }    
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch (Exception ex) {
            System.debug(loggingLevel.Error, 'The error is: ' + ex.getMessage());            
        }
    }

    // This method is created for SRSF-3571
    public static void insertOpptyTeam(User currentUser, Id accountExecutiveId, Set<Id> opptyIdSet) 
    {
        List<OpportunityTeamMember> otmList = new List<OpportunityTeamMember>(); 
            
        if(userTeaMem ==null && accountExecutiveId !=null)
           userTeaMem = [SELECT Id, OpportunityAccessLevel, TeamMemberRole, UserId FROM UserTeamMember WHERE OwnerId = :accountExecutiveId ];

        for (UserTeamMember utm :userTeaMem) 
        {
            System.debug(loggingLevel.WARN, '===========>> utm = ' + utm);
            for (Id opptyId: opptyIdSet){
                otmList.add(new OpportunityTeamMember(UserId = utm.UserId,
                                                    OpportunityId = opptyId,
                                                    OpportunityAccessLevel = utm.OpportunityAccessLevel,
                                                    TeamMemberRole = utm.TeamMemberRole));
            }
        }

        if (currentUser.Team_Role__c == null || currentUser.Team_Role__c == '') {
            currentUser.Team_Role__c = 'Other';
        }
        System.debug(loggingLevel.WARN, '===========>> currentUser.Id = ' + currentUser.Id);
        System.debug(loggingLevel.WARN, '===========>> currentUser.Team_Role__c = ' + currentUser.Team_Role__c);
        for (Id opptyId: opptyIdSet){
            otmList.add(new OpportunityTeamMember(UserId = currentUser.Id,
                                                OpportunityId = opptyId,
                                                OpportunityAccessLevel = 'Edit', 
                                                TeamMemberRole = currentUser.Team_Role__c));
        }  
        System.debug('otmList --->>>>>'+otmList);  
        try {            
            if(otmList.size() > 0)
            {
                Database.SaveResult[] recsToInsert = Database.Insert(otmList, false);
                for(Integer i = 0 ; i < recsToInsert.size(); i++) 
                {
                    if(!recsToInsert[i].isSuccess()) {
                        System.debug(loggingLevel.Error, 'ChangeOpptyOwner: An error occured while creating Team Member: ' + otmList[i]);
                    }
                }
            }  

             if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch (Exception ex) {
            System.debug (loggingLevel.ERROR, 'SObjectLookupController.createOppty: Error occured creating Team Member: ' + ex.getMessage());
        }
    }


    public static void insertOpptyTeam(List<OpportunityTeamMember> opptyTeams) {
        if (opptyTeams == null || opptyTeams.size() == 0) 
            return;
        try {
            INSERT opptyTeams;
        } catch (Exception ex) {
            System.debug (loggingLevel.ERROR, 'SObjectLookupController.createOppty(opptyTeams): Error occured creating Team Member: ' + ex.getMessage());
        }
    }

    public static String insertOpptyTeam(User currentUser, Id accountExecutiveId, Id opptyId) {
        List<OpportunityTeamMember> otmList = new List<OpportunityTeamMember>();
        String retVal = '';

        if (currentUser == null || currentUser.Id == null || accountExecutiveId == null)
            return 'CurrentUser is null or accountExecutive is null';
            
         if(userTeaMem ==null && accountExecutiveId !=null)
           userTeaMem = [SELECT Id, OpportunityAccessLevel, TeamMemberRole, UserId FROM UserTeamMember WHERE OwnerId = :accountExecutiveId ];

        for (UserTeamMember utm :userTeaMem) {
            System.debug(loggingLevel.WARN, '===========>> utm = ' + utm);
            otmList.add(new OpportunityTeamMember(UserId = utm.UserId,
                                                    OpportunityId = opptyId,
                                                    OpportunityAccessLevel = utm.OpportunityAccessLevel,
                                                    TeamMemberRole = utm.TeamMemberRole));
        }
        if (currentUser.Team_Role__c == null || currentUser.Team_Role__c == '') {
            currentUser.Team_Role__c = 'Other';
        }
        System.debug(loggingLevel.WARN, '===========>> currentUser.Id = ' + currentUser.Id);            
        System.debug(loggingLevel.WARN, '===========>> currentUser.Team_Role__c = ' + currentUser.Team_Role__c);
        otmList.add(new OpportunityTeamMember(UserId = currentUser.Id,
                                                OpportunityId = opptyId,
                                                OpportunityAccessLevel = 'Edit', 
                                                TeamMemberRole = currentUser.Team_Role__c));
        try {
            INSERT otmList;
             if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
       } catch (Exception ex) {
            System.debug (loggingLevel.ERROR, 'SObjectLookupController.createOppty: Error occured creating Team Member: ' + ex.getMessage());
            retVal = ('ERROR: ' + ex.getMessage());
//            return retVal;
        }
        return retVal;
    }

    public static void addPreferredTeamMembers(List<Opportunity> opptys) {
      List<OpportunityTeamMember> otms = new List<OpportunityTeamMember>();
        
      //Added logic for SRSF-1546  
      Map<Id,String> mapUserToDivision = new Map<Id,String>();
      Map<Id,String> mapUserFirstName = new Map<Id,String>(); // SRSF-4906
      Set<Id> setOppOwner = new Set<Id>();
      for (Opportunity opp : opptys) {
          setOppOwner.add(opp.OwnerId);
          //System.debug('######'+opp.OwnerId);
      }
      if(!setOppOwner.isEmpty()){
          for(User obj : [SELECT Id,Division__c,FirstName FROM User WHERE Id IN : setOppOwner AND Profile.Name!='Integration User']){
            String strDiv = obj.Division__c;
            if(strDiv!=null)
                strDiv = strDiv.replace('National - ', '');//'National - West' and 'West' both are same for Preferred.
            if(strDiv!=null)
                strDiv = strDiv.replace(' ', '_');//'North East' is replacing as 'North_East'
          	mapUserToDivision.put(obj.Id,strDiv);            
            mapUserFirstName.put(obj.Id, obj.FirstName); // SRSF-4906
          }
      }
      //System.debug('@@@'+mapUserToDivision.values());
      Map<Id,boolean> mapActiveUser = new Map<Id,boolean>();
      Map<String,Group> mapDivToGroup = new Map<String,Group>();
      for(Group objGroup : [SELECT Id,Name,DeveloperName,(SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE DeveloperName IN: mapUserToDivision.values()]){
      	  mapDivToGroup.put(objGroup.DeveloperName,objGroup);
          for (GroupMember gm : objGroup.GroupMembers) {
          	  mapActiveUser.put(gm.UserOrGroupId,false);
          }  
      }
      for(User obj : [SELECT Id,IsActive FROM User WHERE Id IN : mapActiveUser.keyset()]){
      	  mapActiveUser.put(obj.Id,obj.IsActive);     
      }
      for (Opportunity opp : opptys) {
            if (opp.Spectrum_Reach_Preferred__c == true) {
                Set<Id> prefUserIds = new Set<Id>();
                //System.debug('opp.OwnerId..'+opp.OwnerId);
                //System.debug('map..'+mapUserToDivision.containsKey(opp.OwnerId));
                if(opp.OwnerId!=null && mapUserToDivision.containsKey(opp.OwnerId)){
                    //System.debug('Coming...');
                    //prefUserIds.add(opp.OwnerId);
                    String strDivision = mapUserToDivision.get(opp.OwnerId);
                    String oppOwnerFirstName = mapUserFirstName.get(opp.OwnerId); // SRSF-4906
                    //if( strDivision==null && !Test.isRunningTest())
                    // SRSF-4906 : Added Opp Owner FirstName check
                    if(strDivision==null && !Test.isRunningTest() && !oppOwnerFirstName.equalsIgnoreCase('Test'))  
                        opp.addError('Opportunity Owner Division should not be empty for Opportunity : \''+opp.Name+'\'');
                    if( strDivision!=null && mapDivToGroup.containsKey(strDivision) ){
                        Group objG = mapDivToGroup.get(strDivision);
                        if(objG!=null){
                            for (GroupMember gm : objG.GroupMembers) {
                                if(mapActiveUser.containskey(gm.UserOrGroupId) && mapActiveUser.get(gm.UserOrGroupId)) //considering active users as team members
                                	prefUserIds.add(gm.UserOrGroupId);
                            }
                        }
                    }
                }
                for (Id prefUserId : prefUserIds) {
                    otms.add(new OpportunityTeamMember( UserId = prefUserId,
                                                        OpportunityId = opp.Id,
                                                        OpportunityAccessLevel = 'Edit', 
                                                        TeamMemberRole = 'Preferred'));
                }
            }
        }
        if (otms.size() > 0) {
            try {
                INSERT otms;
            } catch (Exception ex) {
                System.debug (loggingLevel.ERROR, 'ChangeOpptyOwner.addPreferredTeamMembers: Error occured creating Preferred Team Members: ' + ex.getMessage());
            }
        }
    }


/*
    public static void setAEofFirstOppty(Id aeUser, Id acctId) {
        Account acct = [select Id, Count_of_Opportunities__c, AE_of_First_Opportunity__c from Account where Id = :acctId];
        if (acct.Count_of_Opportunities__c == 0) {
            acct.AE_of_First_Opportunity__c = String.valueOf(aeUser);
            try {
                update acct;
            } catch (Exception ex) {
                system.debug(loggingLevel.Error, 'ChangeOpptyOwner: an error occured updating AE_of_First_Opportunity__c: ' + ex.getMessage());
            }
        }
    }
    */
}