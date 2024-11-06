/*
###########################################################################
# File..................: RevenueHelper.apxc
# Version...............: 1
# Created by............: Sanchit Singhal   
# Created Date..........: 29-May-2017
# Last Modified by......: Bhuvanasankar 
# Last Modified Date....: 27-Sep-18
# Description...........: Populate revenue owner and account executive references on Revenue Insert and Update
# TAO Ref#..............: 
# Change Log:               
# 1. Puneet Khosla - Changes for SRSF-1049
# 2. Bhuvanasankar - Changes for SRSF-1260
############################################################################*/
public class RevenueHelper {
    
    public static void updateUserAccountinRevenue(List<Revenue__c> revenueList, Map<Id,Revenue__c> oldRevenueMap) {
        
        //Helper variables    
        Map<String,Map<String,Id>> exportsystemUserMap  = new Map<String,Map<String,Id>> {};
        Map<String,Map<String,Id>> exportsystemAccMap  = new Map<String,Map<String,Id>> {};
        Map<String,Id> trafficIdUserMap  = new Map<String,Id> {};
        Map<String,Id> trafficIdAccMap  = new Map<String,Id> {};
        Map<String, String> trafficIdUser_AccMap = new Map<String, String>();
        Map<String,String> trafficEclipseSystemMap  = new Map<String,String>();
        Set<String> trafficIds = new Set<String>();
        Set<String> CustomerIds = new Set<String>();
        Set<String> trafficSystemName = new Set<String>();
        Set<String> exportSystemName = new Set<String>();
        List<Eclipse_Traffic_Map__mdt> trafficEclipseList = new List<Eclipse_Traffic_Map__mdt>();
        Map<String,Boolean> userMap  = new Map<String,Boolean>();
        Set<String> changedRevenueIds = new Set<String>();
        Set<String> changedAEIds = new Set<String>();
        Set<String> changedAdvIds = new Set<String>();
        //SRSF - 4059

        //Get all Eclipse System Names and AE Ids from Revenue records in current trigger context
        for(Revenue__c rev: revenueList){
            if(String.isNotBlank(rev.Eclipse_System__c))
                exportSystemName.add(rev.Eclipse_System__c);
            if(String.isNotBlank(rev.AE_Id__c))
                trafficIds.add(rev.AE_Id__c);
            if(String.isNotBlank(rev.Customer_Number__c))
                CustomerIds.add(rev.Customer_Number__c);
            
            //Collect all revenue ids in case of new revenue insers or changes to AE or Account info        
            if(oldRevenueMap!=null && oldRevenueMap.get(rev.Id)!=null){ 
                if(rev.Eclipse_System__c != oldRevenueMap.get(rev.Id).Eclipse_System__c ||
                   rev.AE_Id__c != oldRevenueMap.get(rev.Id).AE_Id__c ||
                   rev.Customer_Number__c != oldRevenueMap.get(rev.Id).Customer_Number__c){
                    changedRevenueIds.add(rev.Id);          
                }
            }
            else{
                changedRevenueIds.add(rev.Id);
            }               
        }
        
        //Compare the Revenue Eclipse System names with Custom Metadata and get the relevant Traffic System Names.
        trafficEclipseList = [SELECT Eclipse_System_Name__c, Traffic_System_Name__c FROM Eclipse_Traffic_Map__mdt LIMIT 1000];
        
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
           
        for(Traffic_Id_Element__c trafficId : [SELECT Traffic_Id__c,Tim_System__c,Export_System_Id__c,Account__c,User__c,ExportSystem_Name__c, user__r.isActive, Traffic_Type__c, Source_System__c   
                                               FROM Traffic_Id_Element__c 
                                               WHERE ExportSystem_Name__c IN : trafficSystemName  AND (Traffic_ID__c IN : CustomerIds ) AND Traffic_Type__c = 'Account' ]){
            
            //Build account Map
            if(trafficId.Account__c != null && trafficId.Traffic_Type__c == 'Account' ){
                if(!trafficIdAccMap.containskey(trafficId.Traffic_Id__c.toUppercase()+trafficId.ExportSystem_Name__c.toUppercase()) )
                {
                    trafficIdAccMap.put(trafficId.Traffic_Id__c.toUppercase()+ trafficId.ExportSystem_Name__c.toUppercase(), trafficId.Account__c);
                    trafficIdUser_AccMap.put(trafficId.Traffic_Id__c.toUppercase()+ trafficId.ExportSystem_Name__c.toUppercase(), trafficId.Id);
                    //SRSF - 4059 - Showseeker Traffic Data
                    if(String.isNotBlank( trafficId.Source_System__c) && trafficId.Source_System__c== 'ShowSeeker' && trafficId.User__c != null )
                    {
                        if(!trafficIdUserMap.containskey(trafficId.Traffic_ID__c.toUppercase()+trafficId.ExportSystem_Name__c.toUppercase()) )
                        {
                            trafficIdUserMap.put(trafficId.Traffic_Id__c.toUppercase()+ trafficId.ExportSystem_Name__c.toUppercase(), trafficId.User__c);                  
                            userMap.put(trafficId.User__c,trafficId.user__r.isActive);
                            trafficIdUser_AccMap.put(trafficId.Traffic_Id__c.toUppercase()+ trafficId.ExportSystem_Name__c.toUppercase(), trafficId.Id);
                        }
                        
                    }
                    System.debug('trafficIdUserMap : ' + trafficIdUserMap);
                    // Change end - SRSF - 4059 
                }   
            }    
        }
        for(Traffic_Id_Element__c trafficId : [SELECT Traffic_Id__c,Tim_System__c,Export_System_Id__c,Account__c,User__c,ExportSystem_Name__c, user__r.isActive, Traffic_Type__c  
                                               FROM Traffic_Id_Element__c 
                                               WHERE ExportSystem_Name__c IN : trafficSystemName  AND (Traffic_Id__c IN : trafficIds) AND Traffic_Type__c = 'User'])
        {
            //Build User Map
            if (trafficId.User__c != null && trafficId.Traffic_Type__c == 'User') 
            {
                if(!trafficIdUserMap.containskey(trafficId.Traffic_ID__c.toUppercase()+trafficId.ExportSystem_Name__c.toUppercase()) )
                {
                    trafficIdUserMap.put(trafficId.Traffic_ID__c.toUppercase() + trafficId.ExportSystem_Name__c.toUppercase(), trafficId.User__c);                  
                    userMap.put(trafficId.User__c,trafficId.user__r.isActive);
                    trafficIdUser_AccMap.put(trafficId.Traffic_Id__c.toUppercase()+ trafficId.ExportSystem_Name__c.toUppercase(), trafficId.Id);
                }
                else
                {
                    trafficIdUserMap.put(trafficId.Traffic_ID__c.toUppercase() + trafficId.ExportSystem_Name__c.toUppercase(), trafficId.User__c);
                    userMap.put(trafficId.User__c,trafficId.user__r.isActive);                  
                }
            }
        }
        
        System.debug('trafficIdAccMap: ' + trafficIdAccMap);
        
        Account acc = new Account();
        acc.ID = Label.Dummy_Revenue_Account;
        
        for(Revenue__c rev: revenueList){           
            //Populate revenue owner(active users only) and account executive fields
            if(!trafficIdUserMap.isEmpty() || !trafficIdAccMap.isEmpty())
            {
                boolean userFound = false;
                boolean accountFound = false;
                List<String> ecList = new List<String>();
                if(trafficEclipseSystemMap.containsKey(rev.Eclipse_System__c))
                {
                    if(trafficEclipseSystemMap.get(rev.Eclipse_System__c).indexOf(',') > 0)
                    {
                        ecList = trafficEclipseSystemMap.get(rev.Eclipse_System__c).split(',');
                    }
                    else
                        ecList.add(trafficEclipseSystemMap.get(rev.Eclipse_System__c));
                    
                    for(String sysName: ecList){
                        
                        if(String.isNotBlank(rev.AE_Id__c) && !userFound)
                        {
                            if(trafficIdUserMap.containsKey(rev.AE_Id__c.toUppercase()+sysName.toUppercase())){
                                rev.Account_Executive__c = trafficIdUserMap.get(rev.AE_Id__c.toUppercase()+sysName.toUppercase());
                                userFound = true;
                                //Assign Account Executive as Revenue owner if active, else assign Boomi Integration User as Revenue Owner
                                rev.ownerId = (userMap.get(rev.Account_Executive__c) == true)?trafficIdUserMap.get(rev.AE_Id__c.toUppercase()+sysName.toUppercase()):Label.BoomiUserId;
                                
                                if(rev.User_Traffic_Id_Element__c==NULL) rev.User_Traffic_Id_Element__c = trafficIdUser_AccMap.get(rev.AE_Id__c.toUppercase()+sysName.toUppercase());
                            }
                            else
                            {
                                rev.ownerId =rev.Account_Executive__c = Label.BoomiUserId;
                            }
                            System.debug('Showseeker User : ' + trafficIdUserMap.containsKey(rev.Customer_Number__c.toUppercase()+sysName.toUppercase()) +'__'+rev.ownerId);
                            if(trafficIdUserMap.containsKey(rev.Customer_Number__c.toUppercase()+sysName.toUppercase()) && rev.ownerId == Label.BoomiUserId)
                            {
                                rev.Account_Executive__c = trafficIdUserMap.get(rev.Customer_Number__c.toUppercase()+sysName.toUppercase());
                                userFound = true;
                                rev.ownerId = (userMap.get(rev.Account_Executive__c) == true)?trafficIdUserMap.get(rev.Customer_Number__c.toUppercase()+sysName.toUppercase()):Label.BoomiUserId;
                            }
                            
                            
                            //if(changedRevenueIds.contains(rev.id)){
                                changedAEIds.add(rev.Account_Executive__c);
                            //}
                        }
                        
                        System.debug('rev.Customer_Number__c+sysName: ' + rev.Customer_Number__c+sysName);
                        if(String.isNotBlank(rev.Customer_Number__c) && !accountFound)
                        {
                            if(trafficIdAccMap.containsKey(rev.Customer_Number__c.toUppercase()+sysName.toUppercase()))
                            {
                                accountFound = true;
                                rev.Advertiser__c = trafficIdAccMap.get(rev.Customer_Number__c.toUppercase()+sysName.toUppercase());
                                if(rev.Account_Traffic_Id_Element__c==NULL) rev.Account_Traffic_Id_Element__c = trafficIdUser_AccMap.get(rev.Customer_Number__c.toUppercase()+sysName.toUppercase());
                            }
                            else if(rev.Advertiser__c == null  || rev.Advertiser__c == acc.ID)
                            {
                                rev.Advertiser__c = acc.ID;
                            }
                            
                            //if(changedRevenueIds.contains(rev.id)){
                                changedAdvIds.add(rev.Advertiser__c);
                            //}
                        }
    
                        if(userFound && accountFound)
                            break;
                    }
                }
            }
        }
        
        try{
            //query Account Transfer Mapping object where From Users in Revenue AEs and Advertisers in Revenue Advertisers
            Map<String,String> atmMap = new Map<String,String>(); 
            for(Account_Transfer_Mapping__c atm: [SELECT From_User__c, To_User__c, Account__c FROM Account_Transfer_Mapping__c
                                                  WHERE (From_User__c IN :changedAEIds OR Account__c IN:changedAdvIds) 
                                                  AND Account_Transfer_Simulation__r.Status__c = 'Transfer Completed']){
                atmMap.put(String.valueOf(atm.From_User__c)+String.valueOf(atm.Account__c),atm.To_User__c);                                         
            }
            System.debug(atmMap);
            //update Revenue.Revenue_User to ATM.To_User, where Revenue.AE == ATM.From_User and Revenue.Advertisers == ATM.From_User        
            for(Revenue__c rev: revenueList){
            System.debug('rev' + rev);
            System.debug('atmMap' + atmMap.containsKey(String.valueOf(rev.Account_Executive__c)+String.valueOf(rev.Advertiser__c)) );
                if(atmMap.containsKey(String.valueOf(rev.Account_Executive__c)+String.valueOf(rev.Advertiser__c)) && rev.Revenue_User__c == null){
                    System.debug(rev);
                    rev.revenue_user__c = atmMap.get(String.valueOf(rev.Account_Executive__c)+String.valueOf(rev.Advertiser__c));
                
                }

            }
        }
        catch(Exception ex){
            Log4SF.logMessage('RevenueHelper', ' Account Transfer Mapping logic', ex.getMessage(),ex, UserInfo.getUserId(),null,'');
        }
    }       
}