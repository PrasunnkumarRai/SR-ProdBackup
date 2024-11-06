/*
###########################################################################
# File..................: TIMDashboardController.cls
# Version...............: 1
# Created by............: Sanchit Singhal
# Created Date..........: 07-July-2017
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This is the Controller used with "TIMDashboard" VF page 
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/

public with sharing class TIMDashboardController {
	
	public List<SelectOption> dataCenters{get;set;}
	public String endPoint{get;set;}
	public Map<String,UserConnection__c> uConMap;	
    private String userName;        
    private String passwd;	
    Map<String,TIMIntegration__c> custSettMap = new Map<String,TIMIntegration__c>();
    public String retUrl{get;set;}
    public String timServer;
	public String pageMsg{get;set;}
	   	
	public TIMDashboardController() {    
    	dataCenters = new List<SelectOption>();
    	pageMsg = '';
    	uConMap = new Map<String,UserConnection__c>();        
        for (UserConnection__c str:[Select AE_Id__c, TIM_System__c, Username__c,user__r.name
	                     from UserConnection__c
	                     where User__c=:UserInfo.getUserId() and Username__c != null and TIM_System__c != null] ){
    		dataCenters.add(new SelectOption(str.TIM_System__c,str.TIM_System__c));
    		uConMap.put(str.TIM_System__c,str);    		
    	}
    	
    	System.debug('@@dataCenters '+dataCenters);
    	if(dataCenters.size() > 0){
    		endPoint = dataCenters[0].getLabel();
    	}
    	
    	/*Values from Custom setting objects.*/
        custSettMap = TIMIntegration__c.getAll();

        // SRSF-2043 : Commented below method call here and called from VF page action method	
        // getTimURL(); SRSF-2043
        
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=EmulateIE8');
	}
	
	/**
     * This methods prepares the TIM url dunamically based on selected TIM Instance
     * 
     * @return (PageReference) (TIMDashboard page)
    */  
    public PageReference getTimURL(){  
        /*
        userName = custSettMap.get(endPoint).UserName__c;
        passwd = custSettMap.get(endPoint).Password__c;
        */
        timServer = custSettMap.get(endPoint).TIMServer__c;
        
        retUrl = '';
        try{            
            //Fetch logged in user's TIM credentials from Org Cache
            System.debug('Cache Key: ' + uConMap.get(endPoint).Username__c+endPoint);
            string timSystem = endPoint;

            if(timSystem.indexOf('.') > 0)
            {
            	timSystem = timSystem.replace('.','');
            	timSystem = timSystem.deleteWhitespace();
            }
            // SRSF-2043 Start : Self Heal Cache: 08-01-2020
            try{
                if(CacheManager.checkCacheSize(endPoint) <=0){ 
                    System.debug('Cache Size>>>>>>'+CacheManager.checkCacheSize(endPoint));   
                    if(Label.CacheAutoRefresh=='true'){
                        CacheManager.refreshTIMCache(endPoint);
                    }
                    Log4SF.logMessage('TIMDashboardController', 'TIM Dashboard', 'Refreshed All Cache', UserInfo.getUserId(), '');
                    return new PageReference('/apex/Proposal_Cache_Error?timSystem='+endPoint+'&retURL=/apex/TIMDashboard');
                }                 
            }
            catch(Exception ex){
                System.debug('refreshCache Callout error: '+ ex);
            }
            // SRSF-2043 End: Self Heal Cache: 08-01-2020 
            TIMUserAccess.User timuser = CacheManager.getTIMUser(uConMap.get(endPoint).Username__c+timSystem,timSystem);
            System.debug('Cache Hit: ' + timuser);
            
            if(String.isNotBlank(timUser.UP)){
                userName = timUser.UN; passwd = timUser.UP;  
            }
            else if(System.label.CacheFailSafe != 'true'){
                userName = ''; passwd = '';
            }
            else
            {
            	pageMsg = 'There is no Credentials saved for this Tim System. Please Contact your System Administrator.';
            }           
        }
        catch(Exception ex){
            System.debug('Error in getting Cache: ' + ex+ex.getLineNumber());
        }
        
        /*prepare base url with required parameters*/
        userName = userName != null ? userName : '';
        passwd = passwd != null ? passwd : '';
        retUrl = timServer + '/crmlogin.aspx?uname='+ userName + '&pwd='+ passwd
                           +'&redirect=crmopenorderstatus.aspx';
        
        System.debug('TIM URL: ' + retUrl);     
        return null;
    }
}