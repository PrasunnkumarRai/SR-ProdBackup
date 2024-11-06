/* 
    Customer/Project:   Spectrum Reach 
    Class name:          CNATriggerHandler
    Author/Date:        John King    5/17/2017
    Release:             TBD
    Related US:         264
    Purpose:            Provides handler methods for the CNA Trigger

  // This should be used in conjunction with the ApexTriggerComprehensive.trigger template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

*/

public with sharing class CNATriggerHandler {


  private boolean m_isExecuting = false;
  private integer BatchSize = 0;

  public CNATriggerHandler(boolean isExecuting, integer size){
    m_isExecuting = isExecuting;
    BatchSize = size;
  }

  public void OnBeforeInsert(CNA__c[] newCNAs){
  }

  public void OnAfterInsert(CNA__c[] newCNAs){
    //SyncplicitySRUtils.CreateSyncplicityFolders(new List<Id>(new Map<Id, CNA__c>(newCNAs).keySet()));
  }

  @future public static void OnAfterInsertAsync(Set<ID> newCNAIDs){
    //Example usage
    //List<CNA> newCNAs = [select Id, Name from CNA where Id IN :newCNAIDs];
  }

   public void UpdateAEDetails(CNA__c[] updatedCNAs){
         set<id> AEIDs = new set<id>();
     for(cna__c cna : updatedCNAs){
       if(!string.isempty(cna.Account_Executive__c)){
           AEIDs.add(cna.Account_Executive__c);
       }                  
     }
     map<id,user> AEMap = new map<id,user>([select id,region__c,division__c,sales_office__c from user where id in:AEIDs]);
      for(cna__c cna: updatedCNAs ){
       if(AEMap.containskey(cna.Account_Executive__c)){
           cna.region__c = AEMap.get(cna.Account_Executive__c).region__c;
           /*if(cna.region__c == 'Mountain' || cna.region__c=='Pacific')
                  cna.region__c = 'Big West';*/
           cna.sales_office__c = AEMap.get(cna.Account_Executive__c).sales_office__c;
           cna.division__c = AEMap.get(cna.Account_Executive__c).division__c;
       }    
      }
     }
     
  public void OnBeforeUpdate(CNA__c[] oldCNAs, CNA__c[] updatedCNAs, Map<ID, CNA__c> CNAMap){
    //Example Map usage
    //Map<ID, Contact> contacts = new Map<ID, Contact>( [select Id, FirstName, LastName, Email from Contact where CNAId IN :CNAMap.keySet()] );
  }

  public void OnAfterUpdate(CNA__c[] oldCNAs, CNA__c[] updatedCNAs, Map<ID, CNA__c> CNAMap){
    if (updatedCNAs.size() == 1) {  // this code is only needed as users update CNAs.  Not needed for batch or bulk operations
          setSession(updatedCNAs[0]);
      }

  }

  @future public static void OnAfterUpdateAsync(Set<ID> updatedCNAIDs){
    //List<CNA__c> updatedCNAs = [select Id, Name from CNA where Id IN :updatedCNAIDs];
  }

  public void OnBeforeDelete(CNA__c[] CNAsToDelete, Map<ID, CNA__c> CNAMap){

  }

  public void OnAfterDelete(CNA__c[] deletedCNAs, Map<ID, CNA__c> CNAMap){

  }

  @future public static void OnAfterDeleteAsync(Set<ID> deletedCNAIDs){

  }

  public void OnUndelete(CNA__c[] restoredCNAs){

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
  }
  
  private void setSession(CNA__c cna) {
      Long rightNow = Datetime.now().getTime();
      String cacheKey = 'local.CNAPartition.' + cna.Id;
      try {
        Cache.Session.put(cacheKey, rightNow, 300, Cache.Visibility.All, false);
      }
      catch(Exception ex){
        System.debug('Unable to save Cache to Session: ' + ex.getMessage());
        Log4SF.logMessage('CNATriggerHandler', 'setSession', 'Unable to save Cache to Session',ex,UserInfo.getUserId(), cna.Id);
     }
  }
}