/**
    * 
    * @author    Vinay Chaturvedi
    */
   
public class SupportReq_LtngCntrl {
    
    public static Support_Request__c srObj;
    public static Opportunity objOppty;
    public static User usrProfileName;
    //This method is called from Submit to planning lightning component
    @AuraEnabled
    public static String updateToSubPlanning(String SupportReqId){
        if(srObj==null)
        srObj = [SELECT Id,Status__c, Opportunity__c, recordTypeId, Account_Executive__c,
                                    Sales_Office__c, Division__c, Region__c FROM Support_Request__c WHERE Id=:SupportReqId limit 1];
        
       
        if(objOppty==null)
        objOppty = [SELECT Id, OwnerId,(Select UserId, Id From OpportunityTeamMembers) FROM Opportunity WHERE Id=:srObj.Opportunity__c limit 1];
        if(isOpportunityTeamMember(objOppty)){
            //Update the status to "Submit to Planning"  
            srObj.Status__c ='Submitted to Planning';  
            update srObj;
            return 'true';  
        }
        
        return 'false';
        
    }
    
    
    //This method is called from Revision Needed Lightning component
    @AuraEnabled
    public static String updateToRevNeeded(String SupportReqId){
        
        if(srObj==null)
        srObj = [SELECT Id,Status__c, Opportunity__c, recordTypeId, Account_Executive__c,
                                    Sales_Office__c, Division__c, Region__c FROM Support_Request__c WHERE Id=:SupportReqId limit 1];
        
       
        if(objOppty==null)
        objOppty = [SELECT Id, OwnerId,(Select UserId, Id From OpportunityTeamMembers) FROM Opportunity WHERE Id=:srObj.Opportunity__c limit 1];
        if(isOpportunityTeamMember(objOppty)){
            //Update the status to "Revision Needed "  
            srObj.Status__c ='Revisions Needed';  
            update srObj;
            return 'true';  
        }
        
        return 'false';
        
    }
    
    private static Boolean isOpportunityTeamMember(Opportunity oppty) {
    if(usrProfileName==null)
        usrProfileName = [select u.Profile.Name, u.userRole.Name, u.Team_Role__c from User u where u.id = :Userinfo.getUserId()];
        
        //Get the profile names from custom label 
        String profileName = System.Label.supportReqProfiles;
        List<String> allProfileNames= new List<String>();
        if(profileName!=null)
         allProfileNames= profileName.split(',');
        Map<String,String> myProfileMap = new Map<String,String>();
        for(String eachPrf : allProfileNames){
           myProfileMap.put(eachPrf,eachPrf);
        }
        System.debug('#######'+myProfileMap.keyset()+'$$$$$$'+myProfileMap.containsKey(usrProfileName.Profile.Name));
        if(UserInfo.getUserId() == oppty.OwnerId || myProfileMap.containsKey(usrProfileName.Profile.Name) ) {
            return true;
        }
        if(oppty.OpportunityTeamMembers.size()>0){
            List<OpportunityTeamMember> myOppTeams = oppty.OpportunityTeamMembers;
            
            for( OpportunityTeamMember oppTeamObj : myOppTeams ){
                 if( UserInfo.getUserId() == oppTeamObj.UserId ) {
                     return true;
                 }                                          
             }
         }
        return false;
    }
}