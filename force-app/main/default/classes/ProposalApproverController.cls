public without sharing class ProposalApproverController {

    public List<proSubmit> proList{get;set;}
    public List<proSubmit> proDetailList{get;set;}
    public List<proSubmit> proGroupList{get;set;}
    public Set<String> syscodeSet{get;set;}
    public String proId{get;set;}
    public boolean showComments{get;set;}
    public boolean showDetail{get;set;}
    public String error{get;set;}
    public String comments{get;set;}
    private User loggedInUser;
    public List<String> authorizedSysCodes;
    public List<Id> groupList;
    public List<Id> proposalIdList;
    public Map<String,Group_Status__c> groupStatusMap;
    public List<Proposal_Zone__c> zoneList{get;set;}
    public boolean isSuperUser;
    public boolean isLSMUser;
    
    public ProposalApproverController(){
        
        showDetail = true;
        loggedInUser = [SELECT Id, Name,UserRoleId,UserRole.Name,Profile.Name,ManagerId 
                        FROM User 
                        WHERE Id = :UserInfo.getUserId()];
        
        System.debug('@@loggedInUser '+loggedInUser.Name);
        List<User> delegateeUsers = new List<User>();
        try{
            delegateeUsers = [SELECT Id 
                              FROM User 
                              WHERE DelegatedApproverId = :UserInfo.getUserId()];
        }
        catch(Exception ex){
            System.debug('No Delegatee users found: ' + ex);
        }    
        delegateeUsers.add(loggedInUser);
        System.debug('delegateeUsersList: ' + delegateeUsers);
        
        List<User> subUsers = [SELECT Id 
                               FROM User 
                               WHERE UserRole.ParentRoleID != NULL AND 
                                     ManagerId in :delegateeUsers AND 
                                     UserRole.Name LIKE :System.label.AccountTeamRole+'%'];
        
        
        isSuperUser = loggedInUser.Profile.Name == 'Charter - Finance' || loggedInUser.Profile.Name == 'System Administrator' ? true : false;
        isLSMUser = loggedInUser.UserRole != null && loggedInUser.UserRole.Name.startsWith('LSM') ? true : false;
        
        //Get Authorized Syscodes for logged in user
        authorizedSysCodes = new List<String>();
        try{
            authorizedSysCodes = [Select User__c, Authorized_Syscodes__c from User_Approval_Zone__c where User__c =: loggedInUser.id limit 1].Authorized_Syscodes__c.split(',');
            System.debug('@@authorizedSysCodes '+authorizedSysCodes);
        }
        catch(Exception ex){
            System.debug('No authorizedSysCodes found: ' + ex);
        }
        
        //Get pending statuses for logged in user
        groupList = new List<Id>();
        groupStatusMap = new Map<String,Group_Status__c>();
        try{
            //Query on Group member to get all groups where logged in user exists
            for(Group_Member__c g:[Select Group__c
                                   from Group_Member__c 
                                   where User__c =: loggedInUser.id]){
                groupList.add(g.Group__c);              
            }
            
            //Query on all statuses with isEntry = true and isActive = true 
            for(Group_Status__c gs: [Select name, Approval_Status__r.Status_Id__c, Approval_Status__r.name, Rejection_Status__r.Status_Id__c, Rejection_Status__r.name, Status_Id__c
                                     from Group_Status__c 
                                     where Group__c in: groupList and 
                                           Is_Active__c = true and 
                                           Is_Entry__c = true]){
                groupStatusMap.put(gs.name, gs);                                
            }       
        }
        catch(Exception ex){
            System.debug('No pending statuses or groups found: ' + ex);
        }
        
        proList = new List<proSubmit>();
        proDetailList = new List<proSubmit>();
        proGroupList = new List<proSubmit>();
        syscodeSet = new Set<String>();
        proposalIdList = new List<Id>();
        Set<String> pSet = new Set<String>();
        //Display proposals in pending state, with logged in LSM user as owner and proposals owned by delegators' heirarchy
        try{ 
            if(isLSMUser){
                subUsers.add(loggedInUser);
                
                for(Proposal_Zone__c pz: [Select id, proposal__c
                                            from   Proposal_Zone__c
                                            where  name in: authorizedSysCodes and
                                                   TIM_Status__c in: groupStatusMap.keySet() and                                       
                                                   surveyid__c != null
                                            order by name
                                            limit 10000]){
                    pSet.add(pz.proposal__c);
                }                                            
                                
                for(Proposal__c p:[Select id, name, opportunity__r.owner.name, opportunity__r.account.name, net_amount__c, gross_amount__c, tim_id__c,
                                          Start_Date__c, End_Date__c,TIM_Status__c,Opportunity__r.owner.email,Opportunity__r.name,opportunity__c  
                                   from Proposal__c
                                   where TIM_Status__c in: groupStatusMap.keySet() and 
                                         opportunity__r.ownerid in:subUsers and
                                         id in: pSet
                                   limit 1000]){
                    proSubmit ps = new proSubmit();
                    ps.pro=p;
                    ps.showComments=false;
                    
                    proList.add(ps);
                    proposalIdList.add(p.id);            
                }
            }
            
            //Display all proposals in pending state, for Super User
            else if(isSuperUser){
                System.debug('@@authorizedSysCodes '+authorizedSysCodes);
                System.debug('@@groupStatusMap.keySet() '+groupStatusMap.keySet());
                for(Proposal_Zone__c pz: [Select id, proposal__c
                                            from  Proposal_Zone__c
                                            where name in: authorizedSysCodes and
                                                   TIM_Status__c in: groupStatusMap.keySet() and
                                                   surveyid__c != null
                                            order by name
                                            limit 10000]){

                    System.debug('@@pz.proposal__c '+pz.proposal__c);
                    
                    pSet.add(pz.proposal__c);
                }
                System.debug('@@groupStatusMap '+groupStatusMap);
                System.debug('@@groupStatusMap.keySet() '+groupStatusMap.keySet());
                for(Proposal__c p:[Select id, name, opportunity__r.owner.name, opportunity__r.account.name, net_amount__c, gross_amount__c, tim_id__c,
                                          Start_Date__c, End_Date__c,TIM_Status__c,Opportunity__r.owner.email,Opportunity__r.name,opportunity__c  
                                   from Proposal__c
                                   where TIM_Status__c in: groupStatusMap.keySet() and
                                         id in: pSet                          
                                   limit 1000]){
                    proSubmit ps = new proSubmit();
                    ps.pro=p;
                    ps.showComments=false;
                    
                    proList.add(ps);
                    proposalIdList.add(p.id);     
                }
            }
            
            //Display proposals in pending state, owned by delegators' heirarchy
            else{
                for(Proposal_Zone__c pz: [Select id, proposal__c
                            from   Proposal_Zone__c
                            where  name in: authorizedSysCodes and
                                   TIM_Status__c in: groupStatusMap.keySet() and
                                   surveyid__c != null
                            order by name
                            limit 10000]){
                    pSet.add(pz.proposal__c);
                }                                            


                System.debug('@@subUsers '+subUsers);
                for(Proposal__c p:[Select id, name, opportunity__r.owner.name, opportunity__r.account.name, net_amount__c, gross_amount__c, tim_id__c,
                                          Start_Date__c, End_Date__c,TIM_Status__c,Opportunity__r.owner.email,Opportunity__r.name,opportunity__c  
                                   from Proposal__c
                                   where TIM_Status__c in: groupStatusMap.keySet() and 
                                         opportunity__r.ownerid in:subUsers and
                                         id in: pSet
                                   limit 1000]){
                    proSubmit ps = new proSubmit();
                    ps.pro=p;
                    ps.showComments=false;
                    
                    proList.add(ps);
                    proposalIdList.add(p.id);            
                }
            }
        }
        catch(Exception ex){
            System.debug('No pending proposals found: ' + ex);
        }
    }
    
    public PageReference toggleView(){
        
        if(showDetail){
            showDetail = false;
        }
        else{
            showDetail = true;
        }
        
        return null;
    }
    
    
    public PageReference submit(){
        
        for(proSubmit p:proList){
            if(p.pro.Id==proId){
                p.showComments = true;
                p.error='';
            }
            else{
                p.showComments = false;
                p.error='';
            }
        }
        
        System.debug('proId: ' + proId);    
        return null;
    }
    
    public PageReference cancel(){
        
        for(proSubmit p:proList){
            if(p.pro.Id==proId){
                p.showComments = false;
                p.error='';
                System.debug('proId: ' + proId);
            }
        }
            
        return null;
    }
    
    public PageReference submitAll(){
        
        showComments = true;
        error='';
        
        return null;
    }
    
    public PageReference cancelAll(){
        
        showComments = false;
        error='';
        
        return null;
    }
    
    public PageReference approve(){
        
        System.debug('proId: ' + proId);
        Integer i=0;
        String result ='';
        
        BoomiWebServiceHelper bws = new BoomiWebServiceHelper();
        Map<String,String> retMap = new Map<String,String>();
          
        System.debug('proList: ' + proList);
        for(proSubmit p:proList){
            if(p.pro.Id==proId){
                if(isLSMUser){  
                    zonelist = [Select id, proposal__r.name, proposal__r.opportunity__r.owner.name, proposal__r.opportunity__r.account.name, net_amount__c, gross_amount__c, 
                                           proposal__r.tim_id__c,proposal__r.Start_Date__c, proposal__r.End_Date__c, proposal__r.TIM_Status__c,proposal__r.Opportunity__r.owner.email,
                                           proposal__r.Opportunity__r.name,proposal__r.opportunity__c, name, proposal__c, market__c,zone__c,TIM_Status__c, SurveyId__c  
                                    from   Proposal_Zone__c
                                    where  name in: authorizedSysCodes and
                                           TIM_Status__c in: groupStatusMap.keySet() and
                                           proposal__c =: proId and
                                           surveyid__c != null
                                    order by name];
                }
                else if(isSuperUser){  
                    zonelist = [Select id, proposal__r.name, proposal__r.opportunity__r.owner.name, proposal__r.opportunity__r.account.name, net_amount__c, gross_amount__c, 
                                           proposal__r.tim_id__c,proposal__r.Start_Date__c, proposal__r.End_Date__c, proposal__r.TIM_Status__c,proposal__r.Opportunity__r.owner.email,
                                           proposal__r.Opportunity__r.name,proposal__r.opportunity__c, name, proposal__c, market__c,zone__c,TIM_Status__c, SurveyId__c  
                                    from   Proposal_Zone__c
                                    where  TIM_Status__c in: groupStatusMap.keySet() and
                                           proposal__c =: proId and
                                           surveyid__c != null
                                    order by name];
                }
                retMap = bws.approveProposals(zonelist, proList.get(i).comments, groupStatusMap, 'Approve');
                break;
            }       
            i++;
        }
        System.debug('@@retMap '+retMap);
        if(!retMap.containsKey('Error')){
            System.debug('proList ' + proList);
            sendEmailNotification(proList.get(i).pro,'Approval',proList.get(i).comments,retMap);
            proList.remove(i);
        }
        else{
            proList.get(i).error= retMap.get('Error') ;
        }
        
        return null;
    }
    
    public PageReference reject(){
        System.debug('proId: ' + proId);
        Integer i=0;
        String result ='';
        
        BoomiWebServiceHelper bws = new BoomiWebServiceHelper();
        Map<String,String> retMap = new Map<String,String>();
          
        System.debug('proList: ' + proList);        
        for(proSubmit p:proList){
            if(p.pro.Id==proId){
                if(isLSMUser){  
                    zonelist = [Select id, proposal__r.name, proposal__r.opportunity__r.owner.name, proposal__r.opportunity__r.account.name, net_amount__c, gross_amount__c, 
                                           proposal__r.tim_id__c,proposal__r.Start_Date__c, proposal__r.End_Date__c, proposal__r.TIM_Status__c,proposal__r.Opportunity__r.owner.email,
                                           proposal__r.Opportunity__r.name,proposal__r.opportunity__c, name, proposal__c, market__c,zone__c,TIM_Status__c, SurveyId__c  
                                    from   Proposal_Zone__c
                                    where  name in: authorizedSysCodes and
                                           TIM_Status__c in: groupStatusMap.keySet() and
                                           proposal__c =: proId and
                                           surveyid__c != null
                                    order by name];
                }
                else if(isSuperUser){  
                    zonelist = [Select id, proposal__r.name, proposal__r.opportunity__r.owner.name, proposal__r.opportunity__r.account.name, net_amount__c, gross_amount__c, 
                                           proposal__r.tim_id__c,proposal__r.Start_Date__c, proposal__r.End_Date__c, proposal__r.TIM_Status__c,proposal__r.Opportunity__r.owner.email,
                                           proposal__r.Opportunity__r.name,proposal__r.opportunity__c, name, proposal__c, market__c,zone__c,TIM_Status__c, SurveyId__c  
                                    from   Proposal_Zone__c
                                    where  TIM_Status__c in: groupStatusMap.keySet() and
                                           proposal__c =: proId and
                                           surveyid__c != null
                                    order by name];
                }
               
                retMap = bws.approveProposals(zonelist, proList.get(i).comments, groupStatusMap, 'Approve');
                break;
            }       
            i++;
        }
        
        if(!retMap.containsKey('Error')){
            sendEmailNotification(proList.get(i).pro,'Approval',proList.get(i).comments,retMap);
            proList.remove(i);
        }
        else{
            proList.get(i).error= retMap.get('Error') ;
        }
        
        return null;
    }
    
    public PageReference approveAll(){
        
        System.debug('approveAll');
        Integer i=0;
        String result ='';
        
        BoomiWebServiceHelper bws = new BoomiWebServiceHelper();
        Map<String,String> retMap = new Map<String,String>();
        
        if(isLSMUser){  
            zonelist = [Select id, proposal__r.name, proposal__r.opportunity__r.owner.name, proposal__r.opportunity__r.account.name, net_amount__c, gross_amount__c, 
                                   proposal__r.tim_id__c,proposal__r.Start_Date__c, proposal__r.End_Date__c, proposal__r.TIM_Status__c,proposal__r.Opportunity__r.owner.email,
                                   proposal__r.Opportunity__r.name,proposal__r.opportunity__c, name, proposal__c, market__c,zone__c,TIM_Status__c, SurveyId__c  
                            from   Proposal_Zone__c
                            where  name in: authorizedSysCodes and
                                   TIM_Status__c in: groupStatusMap.keySet() and
                                   proposal__c in: proposalIdList and
                                   surveyid__c != null
                            order by name];
        }
        else if(isSuperUser){  
            zonelist = [Select id, proposal__r.name, proposal__r.opportunity__r.owner.name, proposal__r.opportunity__r.account.name, net_amount__c, gross_amount__c, 
                                   proposal__r.tim_id__c,proposal__r.Start_Date__c, proposal__r.End_Date__c, proposal__r.TIM_Status__c,proposal__r.Opportunity__r.owner.email,
                                   proposal__r.Opportunity__r.name,proposal__r.opportunity__c, name, proposal__c, market__c,zone__c,TIM_Status__c, SurveyId__c  
                            from   Proposal_Zone__c
                            where  TIM_Status__c in: groupStatusMap.keySet() and
                                   proposal__c in: proposalIdList and
                                   surveyid__c != null
                            order by name];
        }
        System.debug(zonelist);
        retMap = bws.approveProposals(zonelist, comments, groupStatusMap, 'Approve');
            
        if(!retMap.containsKey('Error')){
            sendMassEmailNotification('Approval',comments);
            proList.remove(i);
        }
        else{
            error= retMap.get('Error') ;
        }
        
        return null;
    }
    
    public PageReference rejectAll(){
        System.debug('rejectAll');
        String result ='';
        
        BoomiWebServiceHelper bws = new BoomiWebServiceHelper();
        Map<String,String> retMap = new Map<String,String>();
          
        if(isLSMUser){  
            zonelist = [Select id, proposal__r.name, proposal__r.opportunity__r.owner.name, proposal__r.opportunity__r.account.name, net_amount__c, gross_amount__c, 
                                   proposal__r.tim_id__c,proposal__r.Start_Date__c, proposal__r.End_Date__c, proposal__r.TIM_Status__c,proposal__r.Opportunity__r.owner.email,
                                   proposal__r.Opportunity__r.name,proposal__r.opportunity__c, name, proposal__c, market__c,zone__c,TIM_Status__c, SurveyId__c  
                            from   Proposal_Zone__c
                            where  name in: authorizedSysCodes and
                                   TIM_Status__c in: groupStatusMap.keySet() and
                                   proposal__c in: proposalIdList and
                                   surveyid__c != null
                            order by name];
        }
        else if(isSuperUser){  
            zonelist = [Select id, proposal__r.name, proposal__r.opportunity__r.owner.name, proposal__r.opportunity__r.account.name, net_amount__c, gross_amount__c, 
                                   proposal__r.tim_id__c,proposal__r.Start_Date__c, proposal__r.End_Date__c, proposal__r.TIM_Status__c,proposal__r.Opportunity__r.owner.email,
                                   proposal__r.Opportunity__r.name,proposal__r.opportunity__c, name, proposal__c, market__c,zone__c,TIM_Status__c, SurveyId__c  
                            from   Proposal_Zone__c
                            where  TIM_Status__c in: groupStatusMap.keySet() and
                                   proposal__c in: proposalIdList and
                                   surveyid__c != null
                            order by name];
        }
        retMap = bws.approveProposals(zonelist, comments, groupStatusMap, 'Reject');
    
        if(!retMap.containsKey('Error')){
            sendMassEmailNotification('Rejection',comments);        
        }
        else{
            error= retMap.get('Error') ;
        }
        
        return null;
    }

   
    public static void sendEmailNotification(Proposal__c pro, String context, String comments,Map<String,String> retMap){        
        System.debug('@@pro '+pro);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        System.debug('@@pro.Opportunity__r.owner.email '+pro.Opportunity__r.owner.email);
        String[] toAddresses = new String[] {pro.Opportunity__r.owner.email};
        System.debug('@@toAddresses '+toAddresses);
        mail.setToAddresses(toAddresses);
        
        if(context == 'Approval'){
            mail.setSubject('Proposal Approval Accepted for: ' + pro.name);
            mail.setPlainTextBody('Congratulations, your Proposal has been approved.\n' + 
                                  '\nOpportunity Name: ' + pro.Opportunity__r.name +
                                  '\nProposal Name: ' + pro.name +
                                  '\nNet Amount: ' + pro.net_amount__c +
                                  '\nAdvertiser Name: ' + pro.opportunity__r.account.name +
                                  '\n\nApprover Comments: ' + comments +
                                  '\n\nThank You');
        }
        
        if(context == 'Rejection'){
            mail.setSubject('Proposal Approval Not Accepted for: ' + pro.name);
            mail.setPlainTextBody('Your Proposal has not been approved.\n' + 
                                  '\nOpportunity Name: ' + pro.Opportunity__r.name +
                                  '\nProposal Name: ' + pro.name +
                                  '\nNet Amount: ' + pro.net_amount__c +
                                  '\nAdvertiser Name: ' + pro.opportunity__r.account.name +                               
                                  '\n\nApprover Comments: ' + comments +
                                  '\n\nPlease contact your manager for further instructions.');
        }
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public void sendMassEmailNotification(String context, String comments){   
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        for(proSubmit p:proList){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            System.debug('@@p.pro.Opportunity__r.owner.email '+p.pro.Opportunity__r.owner.email);
            String[] toAddresses = new String[] {p.pro.Opportunity__r.owner.email};
            mail.setToAddresses(toAddresses);
            
            if(context == 'Approval'){
                mail.setSubject('Proposal Approval Accepted for: ' + p.pro.name);
                mail.setPlainTextBody('Congratulations, your Proposal has been approved.\n' + 
                                      '\nOpportunity Name: ' + p.pro.Opportunity__r.name +
                                      '\nProposal Name: ' + p.pro.name +
                                      '\nNet Amount: ' + p.pro.net_amount__c +
                                      '\nAdvertiser Name: ' + p.pro.opportunity__r.account.name +
                                      '\n\nApprover Comments: ' + comments +
                                      '\n\nThank You');
            }
            
            if(context == 'Rejection'){
                mail.setSubject('Proposal Approval Not Accepted for: ' + p.pro.name);
                mail.setPlainTextBody('Your Proposal has not been approved.\n' + 
                                      '\nOpportunity Name: ' + p.pro.Opportunity__r.name +
                                      '\nProposal Name: ' + p.pro.name +
                                      '\nNet Amount: ' + p.pro.net_amount__c +
                                      '\nAdvertiser Name: ' + p.pro.opportunity__r.account.name +                               
                                      '\n\nApprover Comments: ' + comments +
                                      '\n\nPlease contact your manager for further instructions.');
            }
            
            mails.add(mail);
        }
        
        Messaging.sendEmail(mails);
    } 
    
    public class proSubmit{
        public Proposal__c pro{get;set;}
        public Boolean showComments{get;set;}
        public String error{get;set;}
        public String comments{get;set;}
    }
    
    public PageReference showProposalZones(){
        
        System.debug('proId: ' + proId);
        if(isLSMUser){  
            zonelist = [Select id, proposal__r.name, proposal__r.opportunity__r.owner.name, proposal__r.opportunity__r.account.name, net_amount__c, gross_amount__c, 
                                   proposal__r.tim_id__c,proposal__r.Start_Date__c, proposal__r.End_Date__c, proposal__r.TIM_Status__c,proposal__r.Opportunity__r.owner.email,
                                   proposal__r.Opportunity__r.name,proposal__r.opportunity__c, name, proposal__c, market__c,zone__c,TIM_Status__c, SurveyId__c  
                            from   Proposal_Zone__c
                            where  name in: authorizedSysCodes and
                                   TIM_Status__c in: groupStatusMap.keySet() and
                                   proposal__c =: proId and
                                   surveyid__c != null
                            order by name];
        }
        else if(isSuperUser){  
            zonelist = [Select id, proposal__r.name, proposal__r.opportunity__r.owner.name, proposal__r.opportunity__r.account.name, net_amount__c, gross_amount__c, 
                                   proposal__r.tim_id__c,proposal__r.Start_Date__c, proposal__r.End_Date__c, proposal__r.TIM_Status__c,proposal__r.Opportunity__r.owner.email,
                                   proposal__r.Opportunity__r.name,proposal__r.opportunity__c, name, proposal__c, market__c,zone__c,TIM_Status__c, SurveyId__c  
                            from   Proposal_Zone__c
                            where  TIM_Status__c in: groupStatusMap.keySet() and
                                   proposal__c =: proId and
                                   surveyid__c != null
                            order by name];
        }

        if(zoneList.size() == 0){
            zonelist.add(new Proposal_Zone__c(name='No pending proposal zones for selected Proposal.'));
        }
        
        return null;
    }

}