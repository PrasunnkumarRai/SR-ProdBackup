/* 
    Customer/Project:   Spectrum Reach 
    Class name:          LeadTriggerHandler
    Author/Date:        John King    5/31/2017
    Release:             TBD
    Purpose:            Provides handler methods for the Lead Trigger
    Modifications:      Brett Ballantyne  SRSF-904 (add Owner Division, Region, and Sales Office)
                        3/20/2018

  // This should be used in conjunction with the ApexTriggerComprehensive.trigger template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

*/

public with sharing class LeadTriggerHandler {
  // This should be used in conjunction with the ApexTriggerComprehensive.trigger template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx
  private boolean m_isExecuting = false;
  private integer BatchSize = 0;

  public LeadTriggerHandler(boolean isExecuting, integer size){
    m_isExecuting = isExecuting;
    BatchSize = size;
  }

  public void OnBeforeInsert(Lead[] newLeads){
    //update DMA:
    String lZip = null;
    List<List<SObject>> searchList;
    Set<String> zipSet = new Set<String>();
    String searchQuery;
        
    if(newLeads!= null && newLeads.size()>0){
        User currentUser = [select Id, Name, Sales_Office__c, Region__c, Division__c from User where Id = :UserInfo.getUserId()];
        for(Lead getLead: newLeads){
          /*// SRSF-904 Below fields are currently implemented as formula fields getting values from User
          getLead.Owner_Sales_Office__c = currentUser.Sales_Office__c;
          getLead.Owner_Region__c = currentUser.Region__c;
          getLead.Owner_Division__c = currentUser.Division__c;
          // end SRSF-904*/

          lZip = getLead.postalcode;
        
          system.debug('=====================>> Lead Zip = '+ lZip);
          if(lZip != null){
            zipSet.add(lZip);
            // should refactor this code to move the SOSL out of the for loop
        /*    searchList = [FIND :lZip IN ALL FIELDS RETURNING Zipcode_Mapping__c (Id,Name,Zip_List__c WHERE RecordType.Name = 'Nielsen DMA')];
            system.debug('=====================>> searchList = '+ searchList);  
            if(searchList != null && searchList.size() > 0 && searchList.get(0).size() > 0){
              for(Lead setLead: newLeads){
                  if(setLead.Zipcode_Mapping__c == null) {
                    setLead.Zipcode_Mapping__c = searchList[0][0].Id;
                  }
              }
            } */
    
        }
      }
      if (zipSet.size() > 0) {
        List<String> zipList = new List<String>();
        zipList.addAll(zipSet);
        searchQuery = String.join(zipList, ' OR ');
        searchList = [FIND :searchQuery IN ALL FIELDS RETURNING Zipcode_Mapping__c (Id,Name,Zip_List__c WHERE RecordType.Name = 'Nielsen DMA')];
        system.debug('=====================>> searchList = '+ searchList);  
        if(searchList != null && searchList.size() > 0 && searchList.get(0).size() > 0){
          for(Lead setLead: newLeads){
              if(setLead.Zipcode_Mapping__c == null) {
                setLead.Zipcode_Mapping__c = searchList[0][0].Id;
              }
          }
        }
      }

    }
  }

  public void OnAfterInsert(Lead[] newLeads){

  }

  @future public static void OnAfterInsertAsync(Set<ID> newLeadIDs){
    //Example usage
    //List<Lead> newLeads = [select Id, Name from Lead where Id IN :newLeadIDs];
  }

  public void OnBeforeUpdate(Lead[] oldLeads, Lead[] updatedLeads, Map<ID, Lead> LeadMap){
    //Example Map usage
    //Map<ID, Contact> contacts = new Map<ID, Contact>( [select Id, FirstName, LastName, Email from Contact where LeadId IN :LeadMap.keySet()] );
      // SRSF-904 CRA removed comments commenting out to do the SOSL error fix
      Set<Id> leadOwnerSet = new Set<Id>();
      for (Lead l : updatedLeads) {
          leadOwnerSet.add(l.OwnerId);
      }

      Map<Id, User> userMap = new Map<Id, User>([select Id, Sales_Office__c, Region__c, Division__c from User where Id in :leadOwnerSet]);
     // User currentUser = [select Id, Name, Sales_Office__c, Region__c, Division__c from User where Id = :UserInfo.getUserId()];
      for(Lead l : updatedLeads) {
          User owner = userMap.get(l.OwnerId);
          if (owner != null) {
              l.Owner_Sales_Office__c = userMap.get(l.OwnerId).Sales_Office__c;
              l.Owner_Region__c = userMap.get(l.OwnerId).Region__c;
              /*if(l.Owner_Region__c == 'Mountain' || l.Owner_Region__c=='Pacific')
                  l.Owner_Region__c = 'Big West';*/
              l.Owner_Division__c = userMap.get(l.OwnerId).Division__c;
          }     
      }
      // end SRSF-904

  }

  public void OnAfterUpdate(Lead[] oldLeads, Lead[] updatedLeads, Map<ID, Lead> LeadMap){

  }

  @future public static void OnAfterUpdateAsync(Set<ID> updatedLeadIDs){
    //List<Lead> updatedLeads = [select Id, Name from Lead where Id IN :updatedLeadIDs];
  }

  public void OnBeforeDelete(Lead[] LeadsToDelete, Map<ID, Lead> LeadMap){

  }

  public void OnAfterDelete(Lead[] deletedLeads, Map<ID, Lead> LeadMap){

  }

  @future public static void OnAfterDeleteAsync(Set<ID> deletedLeadIDs){

  }

  public void OnUndelete(Lead[] restoredLeads){

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
}