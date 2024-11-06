/*
###########################################################################
# File..................: SalesBudgetTriggerHelper.apxc
# Version...............: 1
# Created by............: Ankit Bhatia
# Created Date..........: 20-Dec-2021
# Last Modified by......:  
# Last Modified Date....: 
# Description...........: Populate Advertiser ID and commodity from Traffic Data on Sales Budget Inserts.
# TAO Ref#..............: 
# Change Log:               

############################################################################*/

public class SalesBudgetTriggerHelper  {

    //Helper variables    
    Map<String,Map<String,Id>> exportsystemUserMap  = new Map<String,Map<String,Id>> {};
    Map<String,Map<String,Id>> exportsystemAccMap  = new Map<String,Map<String,Id>> {};
    Map<String,Id> trafficIdUserMap  = new Map<String,Id> {};
    Map<String,Id> trafficIdAccMap  = new Map<String,Id> {};
    Map<String, String> trafficIdUser_AccMap = new Map<String, String>();
    Map<String,String> trafficEclipseSystemMap  = new Map<String,String>();
    Set<String> trafficIds = new Set<String>();
    Set<String> CustomerIds = new Set<String>();
    Set<String> trafficIDList = new Set<String>();
    Set<String> exportSystemName = new Set<String>();
    List<Eclipse_Traffic_Map__mdt> trafficEclipseList = new List<Eclipse_Traffic_Map__mdt>();
    Map<String,Boolean> userMap  = new Map<String,Boolean>();
    Set<String> changedRevenueIds = new Set<String>();
    Set<String> changedAEIds = new Set<String>();
    Set<String> changedAdvIds = new Set<String>();

public void isAfterInsert(List<Sales_Budget__c> sbList, Map<Id, Sales_Budget__c> newMap)
{
	//Get all Eclipse System Names and Traffic ID from Sales Budget records in current trigger context
    for(Sales_Budget__c sb: sbList){
        if(String.isNotBlank(sb.Eclipse_System__c))
            exportSystemName.add(sb.Eclipse_System__c);
        if(String.isNotBlank(sb.Eclipse_ID__c))
            trafficIDList.add(sb.Eclipse_ID__c);
	}



	for(Traffic_Id_Element__c trafficId : [SELECT Traffic_Id__c,Tim_System__c,Export_System_Id__c,Account__c,User__c,ExportSystem_Name__c, user__r.isActive, Traffic_Type__c  
                                               FROM Traffic_Id_Element__c 
                                               WHERE ExportSystem_Name__c IN : exportSystemName  AND (Traffic_ID__c IN : trafficIDList )
											    AND Traffic_Type__c = 'Account' ]){
            
            //Buid account Map
            if(trafficId.Account__c != null && trafficId.Traffic_Type__c == 'Account'){
                if(!trafficIdAccMap.containskey(trafficId.Traffic_Id__c.toUppercase()+trafficId.ExportSystem_Name__c.toUppercase()) )
                {
                    trafficIdAccMap.put(trafficId.Traffic_Id__c.toUppercase()+ trafficId.ExportSystem_Name__c.toUppercase(), trafficId.Account__c);
                    trafficIdUser_AccMap.put(trafficId.Traffic_Id__c.toUppercase()+ trafficId.ExportSystem_Name__c.toUppercase(), trafficId.Id);
                }
            }    
        }
	for(Sales_Budget__c sb: sbList){           
    //Populate revenue owner(active users only) and account executive fields
		if(!trafficIdAccMap.isEmpty())
		{
			boolean accountFound = false;                
				System.debug('sb.Eclipse_ID__c+sb.Eclipse_System__c: ' + sb.Eclipse_ID__c+sb.Eclipse_System__c);
				System.debug('Traffic : ' + trafficIdAccMap.containsKey(sb.Eclipse_ID__c.toUppercase()+sb.Eclipse_System__c.toUppercase()));
				if(String.isNotBlank(sb.Eclipse_ID__c) && !accountFound && sb.Advertiser__c == null)
				{
					if(trafficIdAccMap.containsKey(sb.Eclipse_ID__c.toUppercase()+sb.Eclipse_System__c.toUppercase()))
					{
						accountFound = true;
						sb.Advertiser__c = trafficIdAccMap.get(sb.Eclipse_ID__c.toUppercase()+sb.Eclipse_System__c.toUppercase());
						//if(sb.Account_Traffic_Id_Element__c==NULL) sb.Account_Traffic_Id_Element__c = trafficIdUser_AccMap.get(sb.Eclipse_ID__c.toUppercase()+sb.Eclipse_System__c.toUppercase());
					}
					else if(!trafficIdAccMap.containsKey(sb.Eclipse_ID__c.toUppercase()+sb.Eclipse_System__c.toUppercase()))
					{
						sb.addError('Account not found.');
					}
                            
					//if(changedsbenueIds.contains(sb.id)){
						changedAdvIds.add(sb.Advertiser__c);
					//}
				}
			}
		}
	}
            
}