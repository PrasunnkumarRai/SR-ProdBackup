public class CampaignMemberTriggerHandler {

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public CampaignMemberTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnBeforeInsert(CampaignMember[] newCampaignMembers) {
        // SRSF-2235
        salesOfficeAllowedCheck(newCampaignMembers);
    }
    
    public void OnAfterInsert(CampaignMember[] newCampaignMembers) {

    }

    @future public static void OnAfterInsertAsync(Set<ID> newCampaignMemberIDs){

    }

    public void OnBeforeUpdate(CampaignMember[] oldCampaignMembers, CampaignMember[] updatedCampaignMembers, Map<ID, CampaignMember> CampaignMemberMap) {
        // SRSF-2235
        salesOfficeAllowedCheck(updatedCampaignMembers);
    }

    public void OnAfterUpdate(CampaignMember[] oldCampaignMembers, CampaignMember[] updatedCampaignMembers, Map<ID, CampaignMember> CampaignMemberMap){
    }

    @future public static void OnAfterUpdateAsync(Set<ID> updatedCampaignMemberIDs){

    }

    public void OnBeforeDelete(CampaignMember[] CampaignMembersToDelete, Map<ID, CampaignMember> CampaignMemberMap){

    }

    public void OnAfterDelete(CampaignMember[] deletedCampaignMembers, Map<ID, CampaignMember> CampaignMemberMap){

    }
 
    @future public static void OnAfterDeleteAsync(Set<ID> deletedCampaignMemberIDs){

    }

    public void OnUndelete(CampaignMember[] restoredCampaignMembers){

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
    
    
    // SRSF-2235
    public class CampaignMemberException extends Exception {}
    private void salesOfficeAllowedCheck(CampaignMember[] campaigns) {
        Id userId = UserInfo.getProfileId();
        String profileName = [Select Name from Profile where Id = :userId][0].Name;

        if(profileName == 'Master - Account Executive') {
            String userSalesOffice = [Select Sales_Office__c From User Where Id = :UserInfo.getUserId()][0].Sales_Office__c;
            map<string,Campaign> mapCam = new map<string,Campaign>();
            for(CampaignMember cm : campaigns) {
                mapCam.put(cm.CampaignId,null);
            }
            for(Campaign objCam : [select id,Name,Sales_Office_Allowed__c from Campaign where id in : mapCam.keyset()]){
                mapCam.put(objCam.Id,objCam);
            }
            for(CampaignMember cm : campaigns) {
                Boolean isSalesOfficeAllowed = false;
                Campaign objCam = mapCam.get(cm.CampaignId);
                String [] campaignSalesOfficesAllowed = (objCam.Sales_Office_Allowed__c == null ? '' : objCam.Sales_Office_Allowed__c).split(';');
                for(String campaignSalesOffice : campaignSalesOfficesAllowed) {
                    if(userSalesOffice == campaignSalesOffice || campaignSalesOffice=='All') {
                        isSalesOfficeAllowed = true;
                    }
                }
                if(!isSalesOfficeAllowed) {
                    //throw new CampaignMemberException('Due to Sales Office restrictions, you do not have permission to add a Lead to the Campaign.');
                    campaigns[0].addError('Due to Sales Office restrictions, you do not have permission to add a Lead/Contact to the Campaign.');
                }
            }
        }
    }
  
}