public class customLookUpController {
    static Database.SaveResult[] results;

    @AuraEnabled
    public Static List<Account> showAccounts(Id UserId){
        Set<Id> AccountIds  = new Set<Id>();
        for( AccountTeamMember atm : [select AccountId from AccountTeamMember where userId = :UserId]){
            AccountIds.add(atm.AccountId);
        }
        List<Account> accountList = [Select Id, Name,RecordType.Name,BillingStreet,BillingCity,BillingState,(Select id ,name,CloseDate,StageName from Opportunities) from Account where id in :AccountIds ORDER by Name ASC];
        System.debug('Account list Size:::'+accountList.size());
        return accountList;
    }

    @AuraEnabled
    public Static List<OppProposalWrapper> showOpportunities(List<String> AccountIds ,String oppCloseDate, Id oldUserId){
         System.debug('Closed Date:::'+oppCloseDate);
         oppCloseDate  =oppCloseDate.trim();
         List<String> strDate = oppCloseDate.split('-');
         if(strDate.size()>2){
           Integer myIntDate = integer.valueOf(strDate[2]);
           Integer myIntMonth = integer.valueOf(strDate[1]);
           Integer myIntYear = integer.valueOf(strDate[0]);
           Date clsdate = Date.newInstance(myIntYear, myIntMonth, myIntDate);
           List<Opportunity> oppList = [Select Id,AccountId,Account.Name,Name,StageName,CloseDate,(select id ,Name,Tim_ID__c,TIM_System__c,Advertiser__r.Id,End_Date__c,Advertiser__r.TIM_Account_ID__c,Current_Advertiser_Tim_Id__c,Agency__r.TIM_Account_ID__c,Current_Agency_Tim_Id__c from Proposals__r where Active__c = true AND RecordType.DeveloperName != 'Opportunity_Budget' AND (End_Date__c>=:clsdate OR End_Date__c=null)) FROM Opportunity where AccountId IN :AccountIds  and OwnerId=:oldUserId];
           
           Map<Id,List<Proposal__c>> mapOfPropsals = new Map<Id,List<Proposal__c>>();
           List<OppProposalWrapper> oppPropWrapList = new List<OppProposalWrapper>();

           for(Opportunity opp : oppList){
              if(opp.Proposals__r.size()>0){
                OppProposalWrapper opPropWrap = new OppProposalWrapper();
                opPropWrap.oppId = opp.Id;
                opPropWrap.oppName = opp.Name;
                opPropWrap.accId = opp.AccountId;
                opPropWrap.accName = opp.Account.Name;
                for(Proposal__c prop : opp.Proposals__r){
                    opPropWrap.proposalList.add(new proposalWrap(prop));
                }   
                oppPropWrapList.add(opPropWrap);
              }
           }
           System.debug('Proposal wrapper::'+oppPropWrapList);
           return oppPropWrapList;
        }

        return null;
    }

    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, Id UserId) {
        system.debug('ObjectName-->' + ObjectName);
        system.debug('searchKeyWord-->' + searchKeyWord);
        System.debug('UserId:::'+UserId);
        String searchKey = searchKeyWord + '%';
        system.debug('searchKey-->' + searchKey);
        List < sObject > returnList = new List < sObject > ();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey ';
        if(UserId!=null)
          sQuery+= 'and Id!=:UserId';  //sQuery+= 'and Id!=\''+UserId+'\'';    
        sQuery+= ' order by createdDate DESC limit 10';
        System.debug('query::'+sQuery);
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }

    @AuraEnabled
    public static Admin_Tool_Status_Summary__c returnAdminToolStatus(String adminStatusId){
        Admin_Tool_Status_Summary__c adminStatus = new Admin_Tool_Status_Summary__c();

        List<Admin_Tool_Status_Summary__c> adminStatusList = [ SELECT Id,
        Count_of_Proposal_Success__c,Count_of_Proposal_Error__c,
        Count_of_Opportunity_Success__c,Count_of_Opportunity_Error__c,
        Count_of_Activity_Success__c,Count_of_Activity_Error__c,
        Count_of_Account_Team_Success__c,Count_of_Account_Team_Error__c,
        Count_of_Account_Connection_Success__c,Count_of_Account_Connection_Error__c,Count_of_Records__c,
        Batch_Completed__c,of_completion__c,
        Total_Proposal_Count__c,Total_Opportunity_Count__c,Total_Account_Team_Count__c,Total_Account_Connection_Count__c,Total_Activity_Count__c 
        FROM Admin_Tool_Status_Summary__c WHERE Id =:adminStatusId];

        if(adminStatusList.size()>0)
          adminStatus = adminStatusList[0];
        return adminStatus;
    }

    @AuraEnabled
    public static String AEtransfer(String wrapperString , Id newUserId , Id oldUserId,List<String> AccountIds, String proposalEndDate){
      try{
        System.debug('AccountIds::::'+AccountIds);
        System.debug('wrapper String :::'+wrapperString);
        List<OppProposalWrapper> wrapperList = (List<OppProposalWrapper>)JSON.deserialize(wrapperString,List<OppProposalWrapper>.class);
        System.debug('wrapper  List:::'+wrapperList);

        //Integer countOfProposals = 0;
        Set<String> timSysNames = new Set<String>();
        Map<String,Proposal__c> mapOfPrpsl = new Map<String,Proposal__c>();
        Map<String,String> mapOfTimAEIds = new Map<String,String>();

        List<Admin_Tool_Status_Detail__c> adminDetailsRecords = new List<Admin_Tool_Status_Detail__c>();
        
        Admin_Tool_Status_Summary__c adminSummary = new Admin_Tool_Status_Summary__c();
        adminSummary.From_User_Id__c = String.valueOf(oldUserId);
        adminSummary.To_User_Id__c = String.valueOf(newUserId);
        adminSummary.Job_Type__c = 'AE Transfer';
        adminSummary.Proposal_End_Date__c = proposalEndDate.trim();
        adminSummary.Transfer_Details__c = System.Label.Account_Simulation_Sample_Record;
        insert adminSummary;
          
        for( OppProposalWrapper opp: wrapperList){
            if(opp.chckBx){
                adminDetailsRecords.add(new Admin_Tool_Status_Detail__c(Admin_Tool_Status_Summary__c = adminSummary.Id,Id__c = opp.oppId , Object_Type__c = 'Opportunity'));
                for( proposalWrap propWrap : opp.proposalList){
                    adminDetailsRecords.add(new Admin_Tool_Status_Detail__c(Admin_Tool_Status_Summary__c = adminSummary.Id,Id__c = propWrap.prop.Id,Tim_System__c = propWrap.prop.TIM_System__c, Object_Type__c = 'Proposal'));
                   // countOfProposals++;
                    timSysNames.add(propWrap.prop.TIM_System__c);
                    mapOfPrpsl.put(propWrap.prop.Id,propWrap.prop);
                }
            }
        }

        //Code for new Changes
          
        // For Account Ids
        for (String accId : AccountIds ) {
            adminDetailsRecords.add(new Admin_Tool_Status_Detail__c(Admin_Tool_Status_Summary__c = adminSummary.Id,Id__c = accId , Object_Type__c='Account Team')); 
        }

        //For Account connection records
        Map<String,String> oldUserAEIds = fecthUserConnections(oldUserId);
        Map<String,String> newUserAEIds = fecthUserConnections(newUserId);

        List<AccountConnection__c> accConnections = [Select Id,AE_Id__c,TIM_System__c
         From AccountConnection__c WHERE Account__c IN:AccountIds AND TIM_System__c IN:oldUserAEIds.keySet()
         AND AE_Id__c IN : oldUserAEIds.values()];
        for(AccountConnection__c accConn : accConnections){
            if(newUserAEIds.containsKey(accConn.TIM_System__c)){
              adminDetailsRecords.add(new Admin_Tool_Status_Detail__c(Admin_Tool_Status_Summary__c = adminSummary.Id,Id__c = accConn.Id, AccountConnection__c = accConn.Id, New_AE_Id_for_Account_Conn__c = newUserAEIds.get(accConn.TIM_System__c) ,Object_Type__c='Account Connection'));
            }
        }

/*        //For Task
        for(Task tsk : [SELECT Id, WhoId, WhatId ,OwnerId FROM Task where OwnerId =: oldUserId and IsClosed = False]){
            adminDetailsRecords.add(new Admin_Tool_Status_Detail__c(Admin_Tool_Status_Summary__c = adminSummary.Id,Id__c = tsk.Id,Object_Type__c='Activity'));
        }
*/
        if(adminDetailsRecords.size()>0)
            insert adminDetailsRecords;

        Map<String,Integer> mapOfBatchsizes = new Map<String,Integer>();
        for(AE_transfer_setting__mdt aeTransferSetting : [Select id,DeveloperName,BatchSize__c from AE_transfer_setting__mdt limit 50000]){
            mapOfBatchsizes.put(aeTransferSetting.DeveloperName, Integer.valueOf(aeTransferSetting.BatchSize__c));
        }

        if(mapOfBatchsizes.size()>0){
            String query = 'Select id,Id__c , Status__c,Error_Message__c from Admin_Tool_Status_Detail__c where Object_Type__c = \'Proposal\' and Status__c=\'Not Started\' and Admin_Tool_Status_Summary__c =\'' +adminSummary.Id+'\' order by Tim_System__c';
            updateProposalBatch updPrslBtch = new updateProposalBatch(query,adminSummary,timSysNames,mapOfPrpsl, mapOfBatchsizes);
            Id batchJobId = Database.executeBatch(updPrslBtch , mapOfBatchsizes.get('Proposal_Batch_Size'));
        }
        return adminSummary.Id;
      }
      catch(Exception exp){
        System.debug('Exception:::'+exp.getMessage()+' Line Number:::'+ exp.getLineNumber());
      }
      return null;
    }

    public Static void updateAdminSummary(Admin_Tool_Status_Summary__c adminToolSummary){
      try{
        adminToolSummary.Batch_Completed__c = TRUE;
        update adminToolSummary;

        // Code for sending email
        List<Admin_Tool_Status_Summary__c> userDetails = [Select Id,Name,Count_of_Proposal_Success__c,Count_of_Proposal_Error__c,
        Count_of_Opportunity_Success__c,Count_of_Opportunity_Error__c,
        Count_of_Account_Team_Success__c,Count_of_Account_Team_Error__c,
        Count_of_Account_Connection_Success__c,Count_of_Account_Connection_Error__c,
        Count_of_Activity_Success__c,Count_of_Activity_Error__c,
        Total_Proposal_Count__c,Total_Opportunity_Count__c,Total_Account_Team_Count__c,Total_Account_Connection_Count__c,Total_Activity_Count__c 
         FROM Admin_Tool_Status_Summary__c Where Id =:adminToolSummary.Id ];
/*
        if(userDetails.size()>0){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] { userDetails[0].Owner.Email};
            message.subject = 'AE Transfer Tool Details';
            String messageBody = '<html><body>Hi '+userDetails[0].Owner.Name+',<br/><br/> Following are the details of latest transfer and For more details, please review the summary record HERE: <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+adminToolSummary.id+'">'+userDetails[0].Name+'</a> <br/><br/><table><thead><tr><th>Object Name</th><th>Total Count</th><th>No of Success</th><th>No of Error</th></tr></thead>';
            messageBody+= '<tbody><tr><td>Proposal</td><td>'+userDetails[0].Total_Proposal_Count__c+'</td><td style="color:green;">'+userDetails[0].Count_of_Proposal_Success__c+'</td><td style="color:red;">'+userDetails[0].Count_of_Proposal_Error__c+'</td></tr>';
            messageBody+= '<tr><td>Opportunity</td><td>'+userDetails[0].Total_Opportunity_Count__c+'</td><td style="color:green;">'+userDetails[0].Count_of_Opportunity_Success__c+'</td><td style="color:red;">'+userDetails[0].Count_of_Opportunity_Error__c+'</td></tr>';
            messageBody+= '<tr><td>Account Team</td><td>'+userDetails[0].Total_Account_Team_Count__c+'</td><td style="color:green;">'+userDetails[0].Count_of_Account_Team_Success__c+'</td><td style="color:red;">'+userDetails[0].Count_of_Account_Team_Error__c+'</td></tr>';
            messageBody+= '<tr><td>Account Connection</td><td>'+userDetails[0].Total_Account_Connection_Count__c+'</td><td style="color:green;">'+userDetails[0].Count_of_Account_Connection_Success__c+'</td><td style="color:red;">'+userDetails[0].Count_of_Account_Connection_Error__c+'</td></tr>';
            messageBody+= '<tr><td>Activity Task</td><td>'+userDetails[0].Total_Activity_Count__c+'</td><td style="color:green;">'+userDetails[0].Count_of_Activity_Success__c+'</td><td style="color:red;">'+userDetails[0].Count_of_Activity_Error__c+'</td></tr>';
            messageBody+= '</tbody></table></body></html><br/><br/>Thanks';
            message.setHtmlBody(messageBody); 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        }
 */       
      }
      catch(Exception exp){
        System.debug('Error while updating Admin Summary:::'+exp.getMessage());
      }

    }

/*    public static void updateAllActivities(Id oldUserId, Id newUserId ,List<Admin_Tool_Status_Detail__c> adminToolDetailsRecords){

        Map<String,Admin_Tool_Status_Detail__c> mapOfTasks = new Map<String,Admin_Tool_Status_Detail__c>();

        for(Admin_Tool_Status_Detail__c adminToolDetail : adminToolDetailsRecords){
            mapOfTasks.put(adminToolDetail.Id__c, adminToolDetail);
        }

        List<Task> taskList = [SELECT Id, WhoId, WhatId ,OwnerId FROM Task where Id in : mapOfTasks.keySet() ];

        for(Task taskObj : taskList){
            taskObj.OwnerId = newUserId;
        }
       
        results = Database.Update(taskList,true);
        
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                mapOfTasks.get(sr.getId()).Status__c = 'Success';
            }
            else{
              for(Database.Error err : sr.getErrors()) {
                  mapOfTasks.get(sr.getId()).Status__c = 'Error';
                  mapOfTasks.get(sr.getId()).Error_Message__c = err.getMessage();
              }
            }
        }

        Update mapOfTasks.values();
    }*/

    public static void updateOpportunities(Id oldUserId, Id newUserId , List<Admin_Tool_Status_Detail__c> adminToolDetailsRecords){

        Map<String,Admin_Tool_Status_Detail__c> mapOfOpportunity = new Map<String,Admin_Tool_Status_Detail__c>();

        for(Admin_Tool_Status_Detail__c adminToolDetail : adminToolDetailsRecords){
            mapOfOpportunity.put(adminToolDetail.Id__c, adminToolDetail);
        }

        List<Opportunity> oppList = [Select id, OwnerId from Opportunity where OwnerId =:oldUserId and Id IN:mapOfOpportunity.keySet()];
        for(Opportunity oppObj : oppList){
            oppObj.OwnerId = newUserId;
        }
        results = Database.Update(oppList,true);

        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                mapOfOpportunity.get(sr.getId()).Status__c = 'Success';
            }
            else{
              for(Database.Error err : sr.getErrors()) {
                mapOfOpportunity.get(sr.getId()).Status__c = 'Error';
                mapOfOpportunity.get(sr.getId()).Error_Message__c = err.getMessage();
              }        
            }
        }

        Update mapOfOpportunity.values();
    }

    public static void updateAccountTeam(Id oldUserId, Id newUserId , List<Admin_Tool_Status_Detail__c> adminToolDetailsRecords){
       
        Map<String,Admin_Tool_Status_Detail__c> mapOfAccTeams = new Map<String,Admin_Tool_Status_Detail__c>();

        for(Admin_Tool_Status_Detail__c adminToolDetail : adminToolDetailsRecords){
            mapOfAccTeams.put(adminToolDetail.Id__c, adminToolDetail);
        }

        List<AccountTeamMember> accTmMbrs = [SELECT Id,UserId,AccountId ,TeamMemberRole,AccountAccessLevel,OpportunityAccessLevel,CaseAccessLevel,ContactAccessLevel from AccountTeamMember WHERE userId = :oldUserId and AccountId in :mapOfAccTeams.keySet()];
        List<AccountTeamMember> newAccTmMbrs = new List<AccountTeamMember>();
        List<AccountTeamMember> accTmMbrsToDelete = new List<AccountTeamMember>();
        Map<Id,AccountTeamMember> oldAccTmMbr = new Map<Id,AccountTeamMember>();

        for(AccountTeamMember atm : accTmMbrs){
            AccountTeamMember newAccTm = new AccountTeamMember();
            newAccTm = atm.clone(false, true, true, false);
            newAccTm.AccountId = atm.AccountId;
            newAccTm.UserId = newUserId;
            newAccTm.AccountAccessLevel = 'Edit';
            newAccTm.CaseAccessLevel = 'Edit';
            newAccTm.ContactAccessLevel  = 'Edit';
            newAccTm.OpportunityAccessLevel = 'Edit';
            newAccTmMbrs.add(newAccTm);
            oldAccTmMbr.put(atm.AccountId,atm);
        }

        List<Database.UpsertResult> results = Database.upsert(newAccTmMbrs,true);

        for(Integer i=0; i < results.size(); i++){
          if(results[i].isSuccess()){
                if(mapOfAccTeams.containsKey(newAccTmMbrs[i].AccountId))
                    mapOfAccTeams.get(newAccTmMbrs[i].AccountId).Status__c = 'Success';
                if(oldAccTmMbr.containsKey(newAccTmMbrs[i].AccountId))
                    accTmMbrsToDelete.add(oldAccTmMbr.get(newAccTmMbrs[i].AccountId));
            }
            else{
              for(Database.Error err : results[i].getErrors()) {
                if(mapOfAccTeams.containsKey(newAccTmMbrs[i].AccountId)){
                    mapOfAccTeams.get(newAccTmMbrs[i].AccountId).Status__c = 'Error';
                    mapOfAccTeams.get(newAccTmMbrs[i].AccountId).Error_Message__c = err.getMessage();
                }
              }        
            }
        }

        if(accTmMbrsToDelete.size()>0)
            List<Database.DeleteResult> deleteResults = Database.delete(accTmMbrsToDelete,true);
        Update mapOfAccTeams.values();
    } 

    public static void updateAccountConnections(List<Admin_Tool_Status_Detail__c> adminToolDetailsAccConn){

        List<AccountConnection__c> accConnections = new List<AccountConnection__c>();
        Map<String,Admin_Tool_Status_Detail__c> mapOfAccConntn = new Map<String,Admin_Tool_Status_Detail__c>();

        for ( Admin_Tool_Status_Detail__c admindet:  adminToolDetailsAccConn ) {
             AccountConnection__c accConn = new AccountConnection__c();
             accConn.Id = admindet.AccountConnection__c;
             accConn.AE_Id__c = admindet.New_AE_Id_for_Account_Conn__c;
             accConnections.add(accConn);
             mapOfAccConntn.put(admindet.Id__c, admindet);
        }

        results = Database.Update(accConnections,true);

        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                mapOfAccConntn.get(sr.getId()).Status__c = 'Success';
            }
            else{
              for(Database.Error err : sr.getErrors()) {
                  mapOfAccConntn.get(sr.getId()).Status__c = 'Error';
                  mapOfAccConntn.get(sr.getId()).Error_Message__c = err.getMessage();
              }        
            }
        }

        Update mapOfAccConntn.values();

    }    
    
    public static Map<String,String> fecthUserConnections(Id userId){
        Map<String,String> timAEIds = new Map<String,String>();
        for(UserConnection__c usrCon :  [SELECT Id,TIM_System__c,AE_Id__c FROM UserConnection__c WHERE User__c=:userId order by lastModifiedDate asc]){
           timAEIds.put(usrCon.TIM_System__c, usrCon.AE_Id__c);
        }
        return timAEIds;
    }
    
    //Wrappper class
    public class OppProposalWrapper{

        @AuraEnabled 
        public Boolean chckBx = false;        
        @AuraEnabled 
        public Id oppId;
        @AuraEnabled 
        public Id accId;
        @AuraEnabled 
        public String oppName;
        @AuraEnabled
        public String accName;
        @AuraEnabled
        public List<proposalWrap> proposalList;

        public OppProposalWrapper(){
            proposalList = new List<proposalWrap>();
        }

    }

    public class proposalWrap{
        @AuraEnabled
        public Proposal__c prop;
        @AuraEnabled
        public String status = 'Not Transferred';
        @AuraEnabled
        public String stsClr = 'black';

        public proposalWrap(Proposal__c propRcrd){
            prop = propRcrd;
        }

    }    
}