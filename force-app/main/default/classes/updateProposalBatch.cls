global class updateProposalBatch implements Database.Batchable<sObject> , Database.Stateful,Database.AllowsCallouts{
    public String query;
    public Admin_Tool_Status_Summary__c adminToolSummary;
    public Set<String> timSysNames;
    public Map<String,Proposal__c> mapOfProposalIds;
    public Map<String,Integer> mapOfBatchsizes;
    List<UserConnection__c> userConn = new List<UserConnection__c>();
    Map<String,String> mapOfTimAEIds = new Map<String,String>();
    Map<String,UserConnection__c> mapOfUserConn = new Map<String,UserConnection__c>();

    global updateProposalBatch(String query , Admin_Tool_Status_Summary__c adminToolSmry,Set<String> timSysNm,
        Map<String,Proposal__c> mapOfProps , Map<String,Integer> mapOfBcthsize) {
        this.query = query;
        this.adminToolSummary = adminToolSmry;
        this.timSysNames = timSysNm;
        this.mapOfProposalIds = mapOfProps;
        this.mapOfBatchsizes = mapOfBcthsize;
        userConn =  [SELECT Id,TIM_System__c,AE_Id__c,Username__c FROM UserConnection__c WHERE TIM_System__c IN:timSysNames AND User__c=:adminToolSummary.To_User_Id__c ORDER by lastModifiedDate asc];
        for (UserConnection__c usrCon : userConn) {
            mapOfUserConn.put(usrCon.TIM_System__c,usrCon);
        }
        System.debug('mapOfUserConn::::'+mapOfUserConn);
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Admin_Tool_Status_Detail__c> scope){

        Map<String,Admin_Tool_Status_Detail__c> propsalMap = new Map<String,Admin_Tool_Status_Detail__c>();
        Map<String,List<Proposal__c>> mapOfProposals = new Map<String,List<Proposal__c>>();
        List<Proposal__c> propList = new List<Proposal__c>();
        List<Proposal__c> proposalToUpdate = new List<Proposal__c>();

        for(Admin_Tool_Status_Detail__c adminStsDet : scope ){
            propsalMap.put(adminStsDet.Id__c , adminStsDet);
            if(mapOfProposalIds.containsKey(adminStsDet.Id__c))
                propList.add(mapOfProposalIds.get(adminStsDet.Id__c));

        }

        for(Proposal__c prop : propList){
            if(mapOfProposals.containsKey(prop.TIM_System__c))
                mapOfProposals.get(prop.TIM_System__c).add(prop);
            else
                mapOfProposals.put(prop.TIM_System__c, new List<Proposal__c>{prop});
        }

        for(String str : mapOfProposals.keySet()){
            if(mapOfUserConn.containsKey(str)){
                propsalMap = callBoomiService(mapOfProposals.get(str),mapOfUserConn.get(str),propsalMap);

                for(Admin_Tool_Status_Detail__c adminStsDet: propsalMap.values()) {
                    if(adminStsDet.Status__c == 'Success'){
                        Proposal__c prop = new Proposal__c(Id = adminStsDet.Id__c);
                        if(adminStsDet.Error_Message__c!=null)
                           prop.Active__c = false;
                        else
                           prop.AE_ID__c = mapOfUserConn.get(str).AE_Id__c;
                        proposalToUpdate.add(prop);
                    }
                }

            }
            else{
                for(Proposal__c prop : mapOfProposals.get(str)){
                    propsalMap.get(prop.Id).Status__c = 'Error';
                    propsalMap.get(prop.Id).Error_Message__c = 'No User Connection Exist';
                }
            }
        }
        try{
            if(proposalToUpdate.size()>0)
             Update proposalToUpdate;
             Update propsalMap.values();
        }
        catch(Exception exp){
            System.debug('Error while updating Admin Status Details records::'+exp.getMessage());
        }

    }

    global void finish(Database.BatchableContext BC) {

        String query = 'Select id,Id__c , Status__c,Error_Message__c from Admin_Tool_Status_Detail__c where Object_Type__c = \'Opportunity\' and Status__c=\'Not Started\' and Admin_Tool_Status_Summary__c =\''+adminToolSummary.Id+'\'';
        updateOpportunityBatch updateOppBatch = new updateOpportunityBatch(query,adminToolSummary ,mapOfBatchsizes);
        Id batchJobId = Database.executeBatch(updateOppBatch , mapOfBatchsizes.get('Opportunity_Batch_Size'));

    }

    global Map<String,Admin_Tool_Status_Detail__c> callBoomiService(List<Proposal__c> propList ,UserConnection__c userContn ,Map<String,Admin_Tool_Status_Detail__c> mapOfAdminStsDet){

        Integer cachesize = CacheManager.checkCacheSize(userContn.TIM_System__c);
        System.debug('Tim System Name in Batch:::'+userContn.TIM_System__c);
        System.debug('Cache size::'+cachesize);
        BoomiWebServiceHelper boomiSrvcHelper  = new BoomiWebServiceHelper(userContn);
        if(cachesize<=0){
            //CacheManager.refreshTIMCache(userContn.TIM_System__c);
            return boomiSrvcHelper.addErrMsgToProposals(propList,mapOfAdminStsDet,Label.Cache_Error_Message);
        }
        else{
            mapOfAdminStsDet = boomiSrvcHelper.editProposalAE(propList, userContn,mapOfAdminStsDet);
            return mapOfAdminStsDet;
        }
    }

}