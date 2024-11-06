global class InactiveProposalsBatch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts{
    public String query;
    public Map<String,UserConnection__c> userConnMap = new Map<String,UserConnection__c>();
    public Boolean sendEmailFlag = FALSE;
    public Integer countOfErrPrpsls = 0;
    public List<String> timIds = new List<String>();
    public List<String> errorLog = new List<String>();
    
    global InactiveProposalsBatch(String queryStr , Map<String,UserConnection__c> usrConMap) {
        this.query = queryStr;
        this.userConnMap = usrConMap;        
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Proposal__c> scope) 
    {
        System.debug('scope-------->'+scope);        
        List<Proposal_Zone__c> propZonesToDelete = new List<Proposal_Zone__c>();
        List<Proposal__c> proplsToUpdate = new List<Proposal__c>();
        countOfErrPrpsls = 0;
        errorLog = new List<String>();

        Map<String,List<Proposal__c>> timSysPropMap = new Map<String,List<Proposal__c>>();
        Map<Id,List<Proposal_Zone__c>> propZonesMap = new Map<Id,List<Proposal_Zone__c>>();
        List<Logger__c> lgrRcrdsToInsert = new List<Logger__c>();

        for(Proposal__c prop : scope){
            if(prop.Recordtype.DeveloperName!='Opportunity_Budget' && prop.TIM_System__c!=NULL){
                if(timSysPropMap.containsKey(prop.TIM_System__c)){
                    timSysPropMap.get(prop.TIM_System__c).add(prop);
                }
                else{
                    timSysPropMap.put(prop.TIM_System__c, new List<Proposal__c>{prop});
                }
                if(prop.Proposal_Zones__r.size() > 0){
                    List<Proposal_Zone__c> propZonesList = new List<Proposal_Zone__c>();
                    propZonesList.addAll(prop.Proposal_Zones__r);
                    propZonesMap.put(prop.Id, propZonesList);
                }
            }
            else{
                proplsToUpdate.add(new Proposal__c(Id = prop.Id , Active__c = FALSE));
                if(prop.Proposal_Zones__r.size() > 0)
                propZonesToDelete.addAll(prop.Proposal_Zones__r); 
            }
        }

        System.debug('propZonesMap:::'+propZonesMap);
        System.debug('timSysPropMap :::'+timSysPropMap);

        for(String str : timSysPropMap.keySet()){
            UserConnection__c userConnect = userConnMap.containsKey(str) ? userConnMap.get(str) : userConnMap.values()[0];
            BoomiWebServiceHelper boomiHelpr = new BoomiWebServiceHelper(userConnect);
            BoomiWebServiceHelper.inactiveActiveVar = TRUE;
            Map<String,HTTPResponse> retMap = boomiHelpr.InActivateProposals(timSysPropMap.get(str));

            System.debug('return value::'+retMap+'  and ::'+propZonesMap);
            Integer cnt = 0;
            for(String propid : retMap.keySet()){
                if(retMap.get(propid).getStatusCode()== 200){
                    BoomiHelper.TransferOwnershipResponse  esthdr = BoomiHelper.parseTransferOwnership(retMap.get(propid).getBody());
                    if(esthdr!=NULL){
                        if(esthdr.Response!=null){
                            if(esthdr.Response.success.equalsIgnoreCase('true')){
                                proplsToUpdate.add(new Proposal__c(Id = propid , Active__c = FALSE));
                                if(propZonesMap.containsKey(propid)){
                                    propZonesToDelete.addAll(propZonesMap.get(propid));
                                }
                                cnt++;
                            }
                            else if (esthdr.Response.success.equalsIgnoreCase('false') && esthdr.Response.error.size()>0 ){
                                for( BoomiHelper.cls_ResponseError clsResErr : esthdr.Response.error){
                                   if(clsResErr.message.containsIgnoreCase('Failed to Delete Order.')){
                                        sendEmailFlag = TRUE;
                                        countOfErrPrpsls++;
                                        errorLog.add(clsResErr.message);
                                    }
                                }
                                if(esthdr.Response.requestParams!=NULL) timIds.add(esthdr.Response.requestParams.ip2);
                            }
                        }
                    }
                }
            }
            if(timSysPropMap.get(str).size() != cnt){
               lgrRcrdsToInsert.add(Log4SF.populateLog('InactiveProposalsBatch', 'InActivateProposals', timSysPropMap.get(str).size()-cnt+' Proposals Not deleted in tim while changing Opportunity stage to closed .',null, 'INFO', UserInfo.getUserId(),'NA' ,''));
            }
        }

        try{
          if(lgrRcrdsToInsert.size()>0)              
            insert lgrRcrdsToInsert;
          if(proplsToUpdate.size()>0){
             Update proplsToUpdate;
          }
          if(propZonesToDelete.size()>0){
             Delete propZonesToDelete;
          }
        }
        catch(Exception e){
            System.debug('Error while Updating proposal or deleting proposal zones:::'+e.getMessage()+' Line No:'+e.getLineNumber());
        }

    }

    global void finish(Database.BatchableContext BC) {
        if(sendEmailFlag){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setSubject(Label.InActiveProposalBatchSubject);
            String errMesg = String.format(Label.InActiveProposalBatchErrorMessage, new List<String> {String.valueOf(countOfErrPrpsls) , String.join(timIds,',')});
            message.setPlainTextBody(errMesg + '\n' + String.join(errorLog,'\n'));          
            message.setToAddresses(EmailHelper.getDevTeamEmails());         
            Messaging.sendEmail( new Messaging.SingleEmailMessage[] { message } );
        }
    }
}