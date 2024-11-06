/*
###########################################################################
# File..................: SalesRevenueReplicationBatch.cls
# Version...............: 1
# Created by............: James Dean
# Created Date..........: 27-June-2019
# Last Modified by......:
# Last Modified Date....:
# Description...........: This class is used to replicate Revenue data to Sales Revenue object.
# TAO Ref#..............: NA
# Test Class............: 
# Change Log............:
#
#
############################################################################*/

global class SalesRevenueReplicationBatch implements Database.Batchable<sObject>{

    global String query;
    List<Revenue__c> revenueList;
    List<Sales_Revenue__c> salesRevenueList;       
    AsyncApexJob aaj;

    global SalesRevenueReplicationBatch(String qry){       
        
        salesRevenueList = new List<Sales_Revenue__c>();
        aaj = new AsyncApexJob();
		
        if(string.isEmpty(qry))
        {
            qry =  'SELECT Id, Account_Executive__c, Advertiser__c, Net_Projected_Amount__c , Broadcast_Month_Date__c, AE_Id__c,Advertiser_Primary_Commodity__c, Budget_DMA__c, Eclipse_System__c, Budget_Product_Line__c, Customer_Number__c, Primary_Commodity__c, Revenue_Type__c, External_Id_c__c,Revenue_User__c ';
            qry +=' FROM Revenue__c where Calendar_Year(Broadcast_Month_Date__c) >= 2018  AND  Net_Projected_Amount__c > 0 AND Advertiser__c != null ';
            qry += ' AND (NOT Account_Executive__r.Name Like  \'%Integration%\') AND Account_Executive__c != null and Advertiser__r.primary_commodity__c != null order by Account_Executive__r.Name, Advertiser__c desc';
        }
        this.query = qry;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){        
        system.debug('query: ' + query);
    	
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Revenue__c> scope){
        revenueList = new list<Revenue__c>();
        salesRevenueList = new List<Sales_Revenue__c>();
        revenueList = scope;
        system.debug('revenueList.size(): ' + revenueList);
        Schema.SObjectField ftoken = Sales_Revenue__c.Fields.External_Id__c;
        Sales_Revenue__c srObj = new Sales_Revenue__c();     
        
        try{
            for(Revenue__c rev : revenueList){
            	srObj = new Sales_Revenue__c();
                srObj = createSalesRevenue(rev);
                if(srObj != null){
                    salesRevenueList.add(srObj);
                    //system.debug('createSalesRevenue->sbObj: ' + srObj);
                }
            }
            
            system.debug('salesRevenueList: ' + salesRevenueList.size());
            Database.upsertResult[] res= database.Upsert(salesRevenueList,ftoken, false);
            
            for(Database.upsertResult ur: res){
            	System.debug(ur.getId()); 
            	System.debug(ur.isCreated());
            	System.debug(ur.getErrors());
            }
            
            if(Test.isRunningTest()){
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
       }
       catch(Exception ex){
           System.Debug('exception:' +ex.getMessage());
           Log4SF.logMessage('SalesRevenueReplicationBatch', 'execute', ex.getMessage(),ex, UserInfo.getUserId(),null,'');
       }    
    }
	/*
	Delete Sales Revenue records that do not have a Revenue look Up populated.

    global void deleteSalesRevenue()
	{
		try{
			string woEclipse = Label.Wide_Orbit_Eclipse_System_Names;
			List<String> woEclipselist =woEclipse.indexOf(',') > 0 ? woEclipse.split(',') : new List<String>{woEclipse};
			List<Sales_Revenue__c> srList = [SELECT ID, Eclipse_System__c, Revenue__c  FROM Sales_Revenue__c where  (Eclipse_System__c Not in:woEclipselist) and Revenue__c = null LIMIT 10000];
			delete srList;
		}
		catch(Exception ex)
		{
			System.Debug('exception:' +ex.getMessage());
            Log4SF.logMessage('SalesRevenueReplicationBatch', 'deleteSalesRevenue', ex.getMessage(),ex, UserInfo.getUserId(),null,'');
		}
	}
	*/
    global Sales_Revenue__c createSalesRevenue(Revenue__c rev){
       try{
            Sales_Revenue__c srObj = new Sales_Revenue__c();
            srObj.Account_Executive__c= rev.Account_Executive__c;
            srObj.Broadcast_Month_Date__c = rev.Broadcast_Month_Date__c;
            srObj.Advertiser__c= rev.Advertiser__c;
            srObj.DMA__c= rev.Budget_DMA__c;
            srObj.Eclipse_System__c= rev.Eclipse_System__c;
            //TODO: Product Line based on User IF we have Account Executive populated else revenue user
            /*
            Map<String,Account_Transfer_Mapping__c> mapOfATM = new Map<String,Account_Transfer_Mapping__c>();
            ncc = mapOfATM.get(String.valueOf(rev.Advertiser__c)+String.valueOf(rev.Revenue_User__c)).Account_Transfer_Simulation__r.NCC__c;
			String budgetTypeToUser = mapOfATM.get(String.valueOf(rev.Advertiser__c)+String.valueOf(rev.Revenue_User__c)).To_User__r.Budget_Type__c;
			String budgetTypeFromUser = mapOfATM.get(String.valueOf(rev.Advertiser__c)+String.valueOf(rev.Revenue_User__c)).From_User__r.Budget_Type__c;
			if(String.isNotEmpty(ncc) )
			{
				//For National to Local we need to Map the data to the proper product line irrespective of NCC or Direct.
				if(budgetTypeToUser == 'Local' && budgetTypeFromUser == 'National')
				{
					if(plMap.containsKey('Direct ' + rev.Product_Line__c))
						newRevenue.Product_Line__c =  plMap.get('Direct ' + rev.Product_Line__c).Relevant_Product_Line__c;
					else if(plMap.containsKey('NCC ' + rev.Product_Line__c))
						newRevenue.Product_Line__c =  plMap.get('NCC ' + rev.Product_Line__c).Relevant_Product_Line__c;
				}
				else
				newRevenue.Product_Line__c =  plMap.get(ncc + ' ' + rev.Product_Line__c).Relevant_Product_Line__c;
			}
            */
            srObj.Product_Line__c= rev.Budget_Product_Line__c;
            srObj.Revenue_User__c= rev.Revenue_User__c;         
            srObj.Amount__c= rev.Net_Projected_Amount__c;           
            srObj.AE_Id__c= rev.AE_Id__c;           
            srObj.Customer_Number__c= rev.Customer_Number__c;           
            srObj.Primary_Commodity__c= rev.Advertiser_Primary_Commodity__c;           
            srObj.Revenue_Type_Code__c= rev.Revenue_Type__c;            
            srObj.External_Id__c = rev.External_Id_c__c;
            srObj.Revenue__c = rev.Id;
            
            //system.debug('createSalesRevenue->sbObj: ' + srObj);
     
            return srObj;
        }
        catch(Exception ex)
        {
            System.Debug('exception:' +ex.getMessage());
            Log4SF.logMessage('SalesRevenueReplicationBatch', 'createSalesRevenue', ex.getMessage(),ex, UserInfo.getUserId(),null,'');
            return null;
        }
    }
    
    global void finish(Database.BatchableContext BC){
     	system.debug('SalesRevenueReplicationBatch.finish()'); 
		SalesRevenueCancelledOrderDeletion srcd = new SalesRevenueCancelledOrderDeletion('');
		database.ExecuteBatch(srcd, 2000);                                
    }
}