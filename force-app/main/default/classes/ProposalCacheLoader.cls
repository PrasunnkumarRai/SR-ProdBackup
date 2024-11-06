/*
###########################################################################
# File..................: ProposalCacheLoader.cls
# Version...............: 1
# Created by............: Ankit Bhatia   
# Created Date..........: 30-October-2017
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This class contains controller methods for Cache Loader Page.
# TAO Ref#..............: NA
# Change Log:               
#
#
############################################################################*/

public with sharing class ProposalCacheLoader {
	
	public string timSystem;
	public string oppID;
	public string retURL{get; set;}
	public Boolean isRedirect{get; set;}
	public string pageMsg{get; set;}
		
	public ProposalCacheLoader() {
		pageMsg = '';
		isRedirect = false;
		timSystem = ApexPages.currentPage().getParameters().get('timSystem');
		oppID = ApexPages.currentPage().getParameters().get('oppID');
		retURL = ApexPages.currentPage().getParameters().get('retURL');
	   /* if(CacheManager.checkCacheSize(timSystem) <=0){
                CacheManager.refreshAllCache();
                isRedirect = true;
	    }*/ 
	}
	
	public PageReference redirect()	{
	    if(CacheManager.checkCacheSize(timSystem) <=0){
	        //CacheManager.refreshAllCache();
	        isRedirect = false;
	        List<String> params = new List<String>{ ' for '+ userInfo.getUserName()};
	        pageMsg = String.format(System.Label.Cache_Load_Error ,params);
	    }
	    else isRedirect = true;
	    
		if(isRedirect) return new PageReference(retURL);
		else return null; 		
	}
	
    public PageReference backToOpp() {
    	return new PageReference('/'+oppID);
    }

    public void checkCacheExist() {
    	if(!isRedirect && timSystem!=NULL){
			if(CacheManager.checkCacheSize(timSystem)>0) { 
		        isRedirect = true;
			}
		}		
	    System.debug('checkCacheExist --->'+isRedirect);
	}
}