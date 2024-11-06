/*
###########################################################################
# File..................: ProposalNewSyncTriggerHandler.cls
# Version...............: 1
# Created by............: Sanchit Singhal   
# Created Date..........: 06-February-2018
# Last Modified by......: Sanchit Singhal
# Last Modified Date....:  
# Description...........: This class contains helper methods for ProposalNewSync Trigger
# TAO Ref#..............: NA
# Test Class............: ProposalNewSyncTriggerHandlerTest
# Change Log............:               
#
#
############################################################################*/

public with sharing class ProposalNewSyncTriggerHandler {
  private boolean m_isExecuting = false;
  private integer BatchSize = 0;

  public ProposalNewSyncTriggerHandler(boolean isExecuting, integer size){
    m_isExecuting = isExecuting;
    BatchSize = size;
  }

  public void OnBeforeInsert(ProposalNewSync__c[] newProposalNewSyncs){  	
  	checkDuplicateProposal(newProposalNewSyncs);      
  }

  /*public void OnAfterInsert(ProposalNewSync__c[] newProposalNewSyncs){      
  }

  public static void OnAfterInsertAsync(Set<ID> newProposalNewSyncIDs){    
  }*/

  public void OnBeforeUpdate(ProposalNewSync__c[] oldProposalNewSyncs, ProposalNewSync__c[] updatedProposalNewSyncs, Map<ID, ProposalNewSync__c> ProposalNewSyncMap){
  	checkDuplicateProposal(updatedProposalNewSyncs);
  }

  /*public void OnAfterUpdate(ProposalNewSync__c[] oldProposalNewSyncs, ProposalNewSync__c[] updatedProposalNewSyncs, Map<ID, ProposalNewSync__c> ProposalNewSyncMap){
  }

  public static void OnAfterUpdateAsync(Set<ID> updatedProposalNewSyncIDs){
  }

  public void OnBeforeDelete(ProposalNewSync__c[] ProposalNewSyncsToDelete, Map<ID, ProposalNewSync__c> ProposalNewSyncMap){

  }

  public void OnAfterDelete(ProposalNewSync__c[] deletedProposalNewSyncs, Map<ID, ProposalNewSync__c> ProposalNewSyncMap){

  }

  public static void OnAfterDeleteAsync(Set<ID> deletedProposalNewSyncIDs){

  }

  public void OnUndelete(ProposalNewSync__c[] restoredProposalNewSyncs){

  }

  public boolean IsTriggerContext{
    get{ return m_isExecuting;}
  }

  public boolean IsVisualforcePageContext{
    get{ return !IsTriggerContext;}
  }

  public boolean IsWebServiceContext{
    get{ return !IsTriggerContext;}
  }

  public boolean IsExecuteAnonymousContext{
    get{ return !IsTriggerContext;}
  }*/
  
  public void checkDuplicateProposal(ProposalNewSync__c[] newProposalNewSyncs){
  	
  	try{
        List<String> estimateList = new List<String>();
        for(ProposalNewSync__c pns: newProposalNewSyncs){
            if(String.isNotBlank(pns.ProposalNewSyncExternalId__c)){estimateList.add(pns.ProposalNewSyncExternalId__c);}
        }
        
        Map<String,Proposal__c> proposalMap = new Map<String,Proposal__c>();
        for (Proposal__c pr:[Select ProposalExternalId__c  from Proposal__c where ProposalExternalId__c in :estimateList]){
            proposalMap.put(pr.ProposalExternalId__c,pr);
        }
        
        for(ProposalNewSync__c pns: newProposalNewSyncs){
            if(proposalMap!=null && proposalMap.containsKey(pns.ProposalNewSyncExternalId__c)){pns.addError(Label.ProposalNewSyncDuplicateError);}
        }
    }
    catch(Exception ex){
        System.debug('Exception in Proposal New Sync duplicate check: ' + ex + ex.getLineNumber());
    } 	
  }


}