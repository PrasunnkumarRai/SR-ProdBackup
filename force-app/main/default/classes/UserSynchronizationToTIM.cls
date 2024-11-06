/*
###########################################################################
# File..................: UserSynchronizationToTim.cls
# Version...............: 1
# Created by............: Ankit Bhatia   
# Created Date..........: 15-May-2017
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This class contains methods for User Synchronization to TIM page
# Change Log:               
#
#
############################################################################*/
public with sharing class UserSynchronizationToTIM {
    public User currentUser{get;set;}
    public String selectedAE{get;set;}
    public List<timAEWrapper> timAEList{get;set;}
    public List<timAEWrapper> timAEListComplete;
    public List<timAEWrapper> timAEListTemp;
    public List<string> strTimList{get; set;}
    public Map<Integer,StratagTimservice.AE_3_5> aeMap;
    // the soql without the order and limit
    private String soql {get;set;}
    public Boolean isUserCon{get; set;}
    public string selectedAEID{get; set;}
    public string selectedTim{get; set;}
    public string userConID{get; set;}
    public String userInput{get;set;}
    public String pageMsg{get;set;}
    public static String pageResponse{get;set;}
    public AEList AEList;
    // the collection of contacts to display
    public List<Contact> contacts {get;set;}
    //public List<UserConnection__c> userConList;
    
    public Integer page = 0;    // init page
    public Integer pageSize = 15;
    public Integer defaultPageSize = 5;


public UserSynchronizationToTIM(ApexPages.StandardController std){
	//property/variables initialization
    selectedAE = selectedTim = '';
    contacts = new List<Contact>();
    currentUser = (User) std.getRecord();
    System.debug('@@currentUser '+currentUser);
    isUserCon= true;
    pageMsg = 'Primary User Connection already exists.';
    userConID = '';
    strTimList = new List<String>();
    userInput = '';
    try{
        /*Duplicate Check Deprecated
        List<UserConnection__c> userConList = [Select ID, Name, Tim_System__c from UserConnection__c where User__c =: currentUser.Id and AE_Id__c != null and Is_Primary__c = true LIMIT 1];
        System.debug('@@userConList '+userConList);
        if(userConList.size() > 0)
        {
            isUserCon = false;
            pageMsg += userConList[0].Name;
            userConID = userConList[0].ID;
        }
        else
        {
            List<TIMIntegration__c> tiv = TIMIntegration__c.getall().values();
            AEList = new AEList();
            for(TIMIntegration__c i: tiv){
                strTimList.add(i.name);
            }
            timListAE();
        }*/
        List<TIMIntegration__c> tiv = TIMIntegration__c.getall().values();
        AEList = new AEList();
        for(TIMIntegration__c i: tiv){
            strTimList.add(i.name);
        }
        timListAE();   
    }
    catch(exception ex)
    {
        pageMsg = ex.getMessage();
    }
}

 /*public PageReference timList(){
       TimWebServiceHelper tws = new TimWebServiceHelper();
         aeMap = tws.getAllEntities();
        
        List<SelectOption> timAESortList = new List<SelectOption>();
        
        for(Integer i: aeMap.keyset()){
            timAESortList.add(new SelectOption(aeMap.get(i).AeName, String.valueOf(i)));
        }
        
        timAESortList.sort();
        List<timAEWrapper> timObj = new List<timAEWrapper>();
        
        for(SelectOption i: timAESortList){
            timObj.add(new timAEWrapper(i.getValue(),i.getLabel()));
        }
        timAEList = timListAE();
    return null;
}*/

 	/**
     * This methods is used to search for AE based on the text entered in the VF page. 
     * 
     * @return (void) (NA)
    */
	public void searchList()
	{
	    if(String.isNotBlank(userInput) &&  timAEList.size() > 0)
	    {
	        userInput = userInput.replaceAll('[0-9]', ''); 
	        System.debug('@@@ userInput' + userInput + timAEListComplete.size());
	
	        timAEListTemp = new List<timAEWrapper>();
	        for (Integer i = (timAEListComplete.size()-1) ; i >= 0 ; i--){
	            String s = timAEListComplete[i].AEName;
	            //system.debug('@@@ timUser' + s + s.StartsWith(userInput));
	            if(s.StartsWith(userInput)){
	                timAEListTemp.add(new timAEWrapper(timAEListComplete[i].AeName,timAEListComplete[i].TimID));
	            }
	            
	        } 
	        timAEList = timAEListTemp;
	        system.debug('@@@ timAEList' + timAEList);
	    }
	    else if(String.isBlank(userInput))
	    timListAE();
	}
	/**
     * This methods is used to get the AE values from TIM and wrap them up in the wrapper class to be displayed on the VF page.
     * 
     * @return (void) (NA)
    */
	public void timListAE()
	{
        BoomiWebServiceHelper boomi = new BoomiWebServiceHelper();
        convertJSON json  =  parse(boomi.syncAeToTim().getBody());
        System.debug('@@json ' +json);
        System.debug('@@@ json.AEList.AE_3_5.size()' + json.AEList.AE_3_5.size());
        if(json.AEList.AE_3_5.size() > 0)
        {
            timAEList = new List<timAEWrapper>();
            timAEListComplete = new List<timAEWrapper>();
            timAEListTemp = new List<timAEWrapper>();
            AEList = json.AEList;
            for(integer i =0; i<AEList.AE_3_5.size(); i ++)
            {
                if(i < 1000)
                timAEList.add(new timAEWrapper(AEList.AE_3_5[i].AEName,AEList.AE_3_5[i].AEID));
                timAEListComplete.add(new timAEWrapper(AEList.AE_3_5[i].AEName,AEList.AE_3_5[i].AEID));
                timAEListTemp.add(new timAEWrapper(AEList.AE_3_5[i].AEName,AEList.AE_3_5[i].AEID));
            }
            system.debug('@@@ userInput2' + timAEList.size() + timAEListComplete.size());
        }
   // }
	    //return timAEList;
	}
/*public PageReference saveAEId(){
    
    currentUser.TIM_AE_ID__c = selectedAE;
    update currentUser;
    
    List<Traffic_Id_Element__c> trafficList = new List<Traffic_Id_Element__c>();
    try{
        
        try{
            delete [Select id from Traffic_Id_Element__c where User =:currentUser.id];
        }
        catch(Exception ex){
            System.debug('Exception in delete User Traffic Info Sync: ' + ex);
        }
        
        for(StratagTimservice.TrafficIDElement i: aeMap.get(Integer.valueOf(selectedAE)).TrafficIDs.TrafficIDElement){
            trafficList.add(new Traffic_Id_Element__c(User__c=currentUser.id,
                                                      Export_System_Id__c=String.valueOf(i.ExportSystemID),
                                                      Traffic_Id__c=i.TrafficID));
        }
        
        System.debug('trafficList: ' + trafficList);
        insert trafficList;
    }
    catch(Exception ex){
        System.debug('Exception in User Traffic Info Sync: ' + ex);
    }
    
    return new PageReference('/apex/CM_UserSynchronizationToTIM?id=' + currentUser.id);
}
*/
public PageReference close(){   
    return new PageReference('/' + currentUser.id + '?noredirect=1');
}

/*public static String syncUserTraffic(String userQuery){
    
    //Verify user Query input
    if(String.isBlank(userQuery)){
        userQuery = 'Select id, TIM_AE_ID__c from User where TIM_AE_ID__c != \'\'';
    }
    System.debug('userQuery: ' + userQuery);
    
    //Populate TIM AE map
    CM_TimWebServiceHelper tws = new CM_TimWebServiceHelper();
    Map<Integer,StratagTimservice.AE_3_5> aeTrafficMap = tws.getAllEntities();
    
    //Delete existing Traffic Id records
    try{
        delete [Select id from Traffic_Id_Element__c WHERE User__c != null];
    }
    catch(Exception ex){
        System.debug('Exception in delete User Traffic Info Sync: ' + ex);
    }
    
    //Populate new Traffic Id records
    List<Traffic_Id_Element__c> trafficList = new List<Traffic_Id_Element__c>();
    
    for(sObject s:Database.query(userQuery)){       
        User u = (User) s;
        if(!String.isBlank(u.TIM_AE_ID__c)){
            for(StratagTimservice.TrafficIDElement i: aeTrafficMap.get(Integer.valueOf(u.TIM_AE_ID__c)).TrafficIDs.TrafficIDElement){
                trafficList.add(new Traffic_Id_Element__c(User__c=u.id,
                                                          Export_System_Id__c=String.valueOf(i.ExportSystemID),
                                                          Traffic_Id__c=i.TrafficID));
            }
        }               
    }
    
    //Insert new Traffic Id records
    if(trafficList.size() > 0){ 
        System.debug('trafficList: ' + trafficList);
        insert trafficList;
    }
    
    return 'Success';
}
*/
	public Class timAEWrapper
	{
	    public string AEName{get; set;}
	    public string TimId {get; set;}
	    public timAEWrapper(string ae, string tim)
	    {
	        AEName = ae;
	        TimId = tim;
	    }
	}

	/**
     * This methods is called from the VF page to sync the user connection selected with the current user.
     * 
     * @return (string) (pageMsg)
    */
    @RemoteAction
    public static string syncUser(string selectedAEID, string selectedTim,string userId )
    {
        User userDet = [Select ID, Name from User where Id =: userId];
        string pageMsg;
        try{
            UserConnection__c userCon = new UserConnection__c();
            if(String.isNotBlank(selectedAEID) && String.isNotBlank(selectedTim) )
            {
                userCon.AE_Id__c = selectedAEID;
                userCon.User__c = userDet.Id;
                userCon.TIM_System__c = selectedTim;
                userCon.External_System__c = 'TIM';
                insert userCon;
            }
            if(userCon.ID != null)
                pageMsg = 'Success-' + userCon.Id;
        }
        catch(exception ex)
        {
            pageMsg = ex.getMessage();
        }
        return pageMsg;
    }
    /**
     * This methods is called from the VF page once the User Connection is synced 
     * then we have to create the Traffic Elements for the user based on the data recieved from TIM in Salesforce.
     * 
     * @return (void) (NA)
    */
    public void doNothing()
    {
        try
        {
            system.debug('@@@ pageMsg' + pageMsg);  
            List<Traffic_Id_Element__c> trafficElemList =  new List<Traffic_Id_Element__c>();
            if(String.isNotBlank(selectedAEID) && AEList.AE_3_5.size()>0)
            {
                Traffic_Id_Element__c trafficElem =  new Traffic_Id_Element__c();
                for(AE_3_5 ae:AEList.AE_3_5)
                {
                    System.debug('@@selectedAEID '+selectedAEID);
                    System.debug('@@ae.TrafficIDs.TrafficIDElement.size() '+ae.TrafficIDs.TrafficIDElement.size());
                    if(ae.AEID == selectedAEID && ae.TrafficIDs.TrafficIDElement.size()>0)
                    {
                        for(TrafficIDElement trElem : ae.TrafficIDs.TrafficIDElement)
                        {
                            trafficElem =  new Traffic_Id_Element__c();
                            trafficElem.Export_System_Id__c = trElem.ExportSystemID;
                            trafficElem.Traffic_Id__c = trElem.TrafficID;
                            trafficElem.User__c = currentUser.Id;
                            trafficElemList.add(trafficElem);
                        }
                    }
                }
                if(trafficElemList.size()>0)
                    insert trafficElemList;
            }
        }
        catch(Exception ex)
        {
            pageMsg  = ex.getMessage();
        }
    }
    
    public class convertJSON {
        public AEList AEList;
    }

    public class AEList {
        public List<AE_3_5> AE_3_5;
    }

    public class AE_3_5 {
        public String AeID;
        public String AeName;
        public String AeOfficeID;
        public String Alias;
        public String IsActive;
        public TrafficIDs TrafficIDs;
    }

    public class TrafficIDElement {
        public String ExportSystemID;
        public String TrafficID;
    }

    public class TrafficIDs {
        public List<TrafficIDElement> TrafficIDElement;
    }

    
    public static convertJSON parse(String json) {
        return (convertJSON) System.JSON.deserialize(json, convertJSON.class);
    }

}