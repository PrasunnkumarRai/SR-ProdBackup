global class InactivePilotProposalsBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts 
{
    public String query;
    public Boolean sendEmailFlag = FALSE;
    public List<String> failedPropIds = new List<String>();

    global InactivePilotProposalsBatch(String queryStr) {
        this.query = queryStr;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Proposal__c> scope) 
    {
        List<Proposal__c> pilotProposals = new List<Proposal__c>();
        List<Proposal__c> proplsToUpdate = new List<Proposal__c>();
        ShowSeekerWebServiceHelper ssHelper = new ShowSeekerWebServiceHelper();
        List<Logger__c> lgrRcrdsToInsert = new List<Logger__c>();
        Set<String> propIds = new Set<String>();

        System.debug('scope-------->'+scope);
        for(Proposal__c prop : scope)
        {
            propIds.add(prop.Pilot_Proposal_ID__c);
            if(prop.Proposal_Zones__r != NULL && prop.Proposal_Zones__r.size() > 0){
                pilotProposals.add(prop);
            }
        }

        Map<Id, ShowSeekerHelper.ProposalResponse> response = ssHelper.activateInactiveProposals(pilotProposals);
        Integer cnt = 0;
        System.debug('response>>>>'+response);
        if(response !=NULL && response.size() > 0) 
        {
            for(Id propId : response.keySet())
            {
                if(response.get(propId).isSuccess){
                    proplsToUpdate.add(new Proposal__c(Id = propId, Active__c = FALSE));
                }
                else{
                   cnt++;
                   failedPropIds.add(propId);                   
                }
            }
        } 
        else {
          cnt++;
          failedPropIds.addAll(propIds);  
        }

        if(cnt>0){
           sendEmailFlag = TRUE; 
           lgrRcrdsToInsert.add(Log4SF.populateLog('InactiveProposalsBatch', 'InActivateProposals', cnt+' Proposals Not deleted in Pilot while changing Opportunity stage to closed .',null, 'INFO', UserInfo.getUserId(),'NA' ,''));
        }

        try{
          if(lgrRcrdsToInsert.size()>0)              
            INSERT lgrRcrdsToInsert;
          if(proplsToUpdate.size()>0){
            UPDATE proplsToUpdate;
          }
        }
        catch(Exception e){
            System.debug('Error while Updating proposal or deleting proposal zones:::'+e.getMessage()+' Line No:'+e.getLineNumber());
        }
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        if(sendEmailFlag){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setSubject(Label.InActiveProposalBatchSubject);
            String errMesg = String.format(Label.InActivePilotProposalBatchErrorMessage, new List<String> {String.valueOf(failedPropIds.size()) , String.join(failedPropIds,',')});
            message.setPlainTextBody('Failed to Delete Proposal/Order.'+'::'+errMesg);          
            message.setToAddresses(EmailHelper.getDevTeamEmails());         
            Messaging.sendEmail( new Messaging.SingleEmailMessage[] { message } );
        }
    }
}