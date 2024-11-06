/*
###########################################################################
# File..................: SalesRevenueTriggerHelper.apxc
# Version...............: 1
# Created by............: Ashok Aggarwal   
# Created Date..........: 18-June-2018
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: Populate revenue owner and account executive references on Sales Revenue Insert and Update
# TAO Ref#..............: 
# Change Log:               
############################################################################*/
public class SalesRevenueTriggerHelper {
	public static void mapDMAGLID(List<Sales_Revenue__c> revenueList)
	{
		
		List<DMA_Glid_Mapping__c> dmaMapping = [Select ID,DMA__c,Glid__c from DMA_Glid_Mapping__c];
		Map<string,DMA_Glid_Mapping__c> dmaGlidMap = new Map<string,DMA_Glid_Mapping__c>();
		for(DMA_Glid_Mapping__c dma : dmaMapping)
		{
		   dmaGlidMap.put(dma.Dma__c,dma);
		}
		for(Sales_Revenue__c sr: revenueList)
		{
			if(dmaGlidMap.containsKey(sr.DMA__c) && sr.DMA__c != dmaGlidMap.get(sr.DMA__c).Glid__c)
				sr.DMA__c = dmaGlidMap.get(sr.DMA__c).Glid__c;
		}
		//Update srList;
		//List<AggregateResult> ar = [Select Count(ID) from User where Budget_DMA__c in: dmaGlidMap.keySet() ];
		//system.debug(srList.size());
	}
	public static void updateUserAccountinRevenue(List<Sales_Revenue__c> revenueList) {
		
		//Helper variables    
    	Map<String,Map<string,Id>> exportsystemUserMap  = New Map<String,Map<string,Id>> {};
    	Map<String,Map<string,Id>> exportsystemAccMap  = New Map<String,Map<string,Id>> {};
	    Map<String,Id> trafficIdUserMap  = New Map<String,Id> {};
	    Map<String,Id> trafficIdAccMap  = New Map<String,Id> {};	    
	    Map<String,String> trafficEclipseSystemMap  = New Map<String,String>();
	    Set<String> trafficIds = new Set<String>();
	    Set<String> CustomerIds = new Set<String>();
	    Set<String> trafficSystemName = new Set<String>();
	    Set<String> exportSystemName = new Set<String>();
	    List<Eclipse_Traffic_Map__mdt> trafficEclipseList = new List<Eclipse_Traffic_Map__mdt>();
	    Map<String,Boolean> userMap  = New Map<String,Boolean>();
	    
	    //Get all Eclipse System Names and AE Ids from Revenue records in current trigger context
	    for(Sales_Revenue__c rev: revenueList){
	    	if(String.isNotBlank(rev.Eclipse_System__c))
	    		exportSystemName.add(rev.Eclipse_System__c);
	    		
	    	if(String.isNotBlank(rev.AE_Id__c))
	    		trafficIds.add(rev.AE_Id__c);
	    		
	    	if(String.isNotBlank(rev.Customer_Number__c))
	    		CustomerIds.add(rev.Customer_Number__c);	    	
	    }
	    
	    //Get Custom Metadata for Traffic System Names
	    trafficEclipseList = [Select Eclipse_System_Name__c,Traffic_System_Name__c from Eclipse_Traffic_Map__mdt];
	    
	    for(Eclipse_Traffic_Map__mdt trf: trafficEclipseList){
	    	trafficSystemName.add(trf.Traffic_System_Name__c);
	    	if(!trafficEclipseSystemMap.containskey(trf.Eclipse_System_Name__c))
            {
	    		trafficEclipseSystemMap.put(trf.Eclipse_System_Name__c,trf.Traffic_System_Name__c);
            }
            else{
            	trafficEclipseSystemMap.put(trf.Eclipse_System_Name__c,trafficEclipseSystemMap.get(trf.Eclipse_System_Name__c)+',' +trf.Traffic_System_Name__c);
            }
	    }
 		
 		System.debug('trafficEclipseSystemMap: ' + trafficEclipseSystemMap);
 		
 		//Buid account Map   
	    for(Traffic_Id_Element__c trafficId : [SELECT Traffic_Id__c,Tim_System__c,Export_System_Id__c,Account__c,User__c,ExportSystem_Name__c, user__r.isActive, Traffic_Type__c  
	    									   FROM Traffic_Id_Element__c 
	    									   where ExportSystem_Name__c in: trafficSystemName  AND (Traffic_ID__c in : CustomerIds ) AND Traffic_Type__c = 'Account' ]){
	        
	        
	        if(trafficId.Account__c != null && trafficId.Traffic_Type__c == 'Account'){
	            if(!trafficIdAccMap.containskey(trafficId.Traffic_Id__c.toUppercase()+trafficId.ExportSystem_Name__c.toUppercase()) )
	            {
	                trafficIdAccMap.put(trafficId.Traffic_Id__c.toUppercase()+ trafficId.ExportSystem_Name__c.toUppercase(), trafficId.Account__c);
	            }
	        }    
	    }
	    
	    //Build User Map
	    for(Traffic_Id_Element__c trafficId : [SELECT Traffic_Id__c,Tim_System__c,Export_System_Id__c,Account__c,User__c,ExportSystem_Name__c, user__r.isActive, Traffic_Type__c  
	    									   FROM Traffic_Id_Element__c 
	    									   where Traffic_Id__c in : trafficIds AND Traffic_Type__c = 'User' and user__c != null])
	  	{
	  		if (trafficId.User__c != null && trafficId.Traffic_Type__c == 'User') 
	        {
	            if(!trafficIdUserMap.containskey(trafficId.Traffic_ID__c.toUppercase()) )
	            {
	                trafficIdUserMap.put(trafficId.Traffic_ID__c.toUppercase(), trafficId.User__c);	                
	                userMap.put(trafficId.User__c,trafficId.user__r.isActive);
	            }
	            else
	            {
	            	trafficIdUserMap.put(trafficId.Traffic_ID__c.toUppercase(), trafficId.User__c);
	            	userMap.put(trafficId.User__c,trafficId.user__r.isActive);	                
	            }
	        }
	    }
	    
	    System.debug('trafficIdAccMap: ' + trafficIdAccMap);
	    
	    Account acc = new Account();
	    acc.ID = Label.Dummy_Revenue_Account;
	    
	    for(Sales_Revenue__c rev: revenueList){	    	
	    	//Populate revenue owner(active users only) and account executive fields
    		if(!trafficIdUserMap.isEmpty() || !trafficIdAccMap.isEmpty())
	        {
	            boolean userFound = false;
	            boolean accountFound = false;
	            if(String.isNotBlank(rev.AE_Id__c) && !userFound)
	            {
		            if(trafficIdUserMap.containsKey(rev.AE_Id__c.toUppercase())){
			            //rev.Revenue_User__c = trafficIdUserMap.get(rev.AE_Id__c.toUppercase());
			            userFound = true;
			            //Assign Account Executive as Revenue owner if active, else assign Boomi Integration User as Revenue Owner
			            rev.ownerId = (userMap.get(rev.Revenue_User__c) == true)?trafficIdUserMap.get(rev.AE_Id__c.toUppercase()):Label.BoomiUserId;
		            }
	            }
	            
	            if(trafficEclipseSystemMap.containsKey(rev.Eclipse_System__c)){
		            for(String sysName: trafficEclipseSystemMap.get(rev.Eclipse_System__c).split(',')){
			            System.debug('rev.Customer_Number__c+sysName: ' + rev.Customer_Number__c+sysName);
			            if(String.isNotBlank(rev.Customer_Number__c) && !accountFound)
			            {
				            if(trafficIdAccMap.containsKey(rev.Customer_Number__c.toUppercase()+sysName.toUppercase()))
			        		{
			        			accountFound = true;
			        			rev.Advertiser__c = trafficIdAccMap.get(rev.Customer_Number__c.toUppercase()+sysName.toUppercase());
			        		}
			        		else if(rev.Advertiser__c == null  || rev.Advertiser__c == acc.ID)
			        		{
			        			rev.Advertiser__c = acc.ID;
			        		}
			            }
	
			            if(accountFound)
			            	break;
		        	}
	            }
	        }
	        
	        //Map Sales Revenue user for National Teams
	        /*
			if(rev.product_line__c.contains(Label.BudgetNationalProductIdentifier)){
            	if(SalesRevenueNationalTeams__c.getAll().containsKey(rev.team_name__c)){
            		rev.Revenue_User__c = SalesRevenueNationalTeams__c.getAll().get(rev.team_name__c).Revenue_User__c;
	            	rev.ownerId = SalesRevenueNationalTeams__c.getAll().get(rev.team_name__c).Revenue_User__c;
            	}
            }
			*/
	    }
    }	    
}