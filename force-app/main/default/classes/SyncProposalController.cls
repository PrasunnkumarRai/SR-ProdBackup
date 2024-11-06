public with sharing class SyncProposalController {
  /*Variable to hold Proposal Record Id on click of Sync Proposal Button */
  public String propsalId;
  /*Variable to hold Opportunity Object records */
  public static List<Opportunity> opp {get;set;}
  /*Variable to hold proposal Object records */
  public static List<Proposal__c> proposal;    
  /*Variable to hold UserConnection Object records */
  public static List<UserConnection__c> oppAE;  

  /* Constructor for the controller class. */ 
  public SyncProposalController(ApexPages.StandardController controller){     
    propsalId = ApexPages.currentPage().getParameters().get('id');
    
  }

  /* Mtehod being called from VF page Action method 
     to create proposal line items on proposal*/
  public PageReference syncProposals(){
    System.debug('propsalId::'+propsalId);

    proposal = [select id,TIM_Id__c,Opportunity__c, recordType.name,Advertiser__c,Agency__c,tim_system__c,opportunity__r.ownerId,opportunity__r.owner.name,Bad_Sync__c
                    from Proposal__c
                    where Id =: propsalId];            
    
    opp = [select id,OwnerId,owner.name from Opportunity where id=:proposal[0].Opportunity__c];
    
    if(opp.size() > 0){
      /*Get the Opp AE User Connections*/
          oppAE = [Select AE_Id__c, TIM_System__c, Username__c,user__r.name
                  from UserConnection__c
                  where User__c=:opp[0].ownerId and AE_Id__c != null and Is_Primary__c = true];
                  System.debug('oppAE::'+oppAE);
          
      if(oppAE.size() > 0){
            BoomiWebServiceHelper bws = new BoomiWebServiceHelper();       
            String returnValue = bws.syncProposalLineItems(proposal[0],oppAE[0]);
           /*  if(returnValue.equalsIgnoreCase('Success') && proposal[0].Bad_Sync__c){ Proposal__c prop = new Proposal__c(Id = propsalId, Bad_Sync__c = FALSE);Update prop;}   */  
           // SRSF-1784 : Updating bad sync to false
           if(returnValue.equalsIgnoreCase('Success')){ 
               Proposal__c prop = new Proposal__c(Id = propsalId,Sync_Pending__c = TRUE,Sync_Pending_Since__c=System.now()); // SRSF-1779 : Updating sync pending to true
               if(proposal[0].Bad_Sync__c) prop.Bad_Sync__c = FALSE;
               Update prop;
            }     
            System.debug('returnValue::'+returnValue);
        }
    }
      return new PageReference('/'+propsalId); 
  }  
  
  public static String returnValue;

  @AuraEnabled
  public static ResultWrapper syncProposal(String propsalId){

    System.debug('propsalId::'+propsalId);
    ResultWrapper resultWrap = new ResultWrapper();

    proposal = [select id,TIM_Id__c,Opportunity__c,recordType.name,Advertiser__c,Agency__c,tim_system__c,opportunity__r.ownerId,opportunity__r.owner.name,Bad_Sync__c
                    from Proposal__c
                    where Id =: propsalId];            
    
    if(proposal != NULL && proposal.size()>0 ){
          oppAE = [Select AE_Id__c, TIM_System__c, Username__c,user__r.name
                  from UserConnection__c
                  where User__c=:proposal[0].Opportunity__r.ownerId and AE_Id__c != null and Is_Primary__c = true];
                  System.debug('oppAE::'+oppAE);
          
      if(oppAE.size() > 0){
        Integer cachesize = CacheManager.checkCacheSize(oppAE[0].TIM_System__c);
            if(cachesize<=0){
                resultWrap.message = label.Cache_Error_Message;
            resultWrap.messageType = 'error';
            }
            else{
              BoomiWebServiceHelper bws = new BoomiWebServiceHelper();
              //BoomiWebServiceHelper.isFrmSynPropBtn = TRUE;     
              returnValue = bws.syncProposalLineItems(proposal[0],oppAE[0]);          
              if(returnValue.equalsIgnoreCase('Success')){
                  Proposal__c prop = new Proposal__c(Id = propsalId,Sync_Pending__c = TRUE,Sync_Pending_Since__c=System.now()); // SRSF-1779 : Updating sync pending to true
               if(proposal[0].Bad_Sync__c) prop.Bad_Sync__c = FALSE; // RSF-1011, New Change requested : 21-05-2019 
          Update prop;
              resultWrap.message = Label.Sync_Proposal_Success_message; resultWrap.messageType = 'success';
              }
              else{
              resultWrap.message = label.Sync_Proposal_Error_message;
              resultWrap.messageType = 'error';
              }
            }
        }
        else{
          resultWrap.message = Label.No_User_Connection_Error;
          resultWrap.messageType = 'error';
        }
    }
    return resultWrap;
  }


  public class ResultWrapper{
    @AuraEnabled public String message;
    @AuraEnabled public String messageType;
  }

}