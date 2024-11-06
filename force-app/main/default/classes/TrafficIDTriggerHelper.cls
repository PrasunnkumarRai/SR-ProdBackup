/*###########################################################################
# File..................: TrafficIDTriggerHelper
# Version...............: 1
# Created by............: Ankit Bhatia   
# Created Date..........: 10-Oct-2017
# Last Modified by......: Puneet Khosla
# Last Modified Date....: 16-Aug-2018
# Description...........: Trigger helper class for TrafficIDTrigger
# TAO Ref#..............: 
# Change Log:               
# 1. Puneet Khosla - 16-Aug-18 - Changes for SRSF-1051
#
############################################################################*/
public with sharing class TrafficIDTriggerHelper {
    
    public static void updateUserRecords(List<Traffic_Id_Element__c> trafficIDs)
    {
        Set<String> aeIDs = new Set<String>();
        Set<String> accTimIDs = new Set<String>();
        Set<String> agcTimIDs = new Set<String>();
        for(Traffic_Id_Element__c trfElem : trafficIDs)
        {
            System.debug('agcTimIDs ' + trfElem.AE_ID__c);
            if(String.isNotBlank(string.valueOf(trfElem.AE_ID__c)) && trfElem.Traffic_Type__c == 'User')
                aeIds.add(string.valueOf(Integer.valueof(trfElem.AE_ID__c))); // aeIds.add(string.valueOf(trfElem.AE_ID__c));
            System.debug('trfElem.Account_TIM_ID__c ' + trfElem.Account_TIM_ID__c);    
            if(String.isNotBlank(trfElem.Account_TIM_ID__c) && trfElem.Traffic_Type__c == 'Account' && trfElem.Account_Type__c == 'Advertiser')
                accTimIDs.add(trfElem.Account_TIM_ID__c);
            else if(String.isNotBlank(trfElem.Account_TIM_ID__c) && trfElem.Traffic_Type__c == 'Account' && trfElem.Account_Type__c == 'Agency')
                agcTimIDs.add(trfElem.Account_TIM_ID__c);
        }
        System.debug('agcTimIDs ' + agcTimIDs);
        System.debug('aeIds ' + aeIds);
        System.debug('accTimIDs ' + accTimIDs);
        //Map for user connection
        Map<String,UserConnection__c> userMap = new Map<String,UserConnection__c>();
        for(UserConnection__c userC :[SELECT ID, TIM_System__c, AE_Id__c, User__r.ID FROM UserConnection__c WHERE  AE_ID__c in : aeIds])
        {
            userMap.put(userC.AE_ID__c+userC.TIM_System__c,userC);
            
        }
        
        //Map for Advertiser Account Connection
        Map<String,AccountConnection__c> accMap = new Map<String,AccountConnection__c>();
        for(AccountConnection__c accCon :[SELECT ID, TIM_System__c, AE_Id__c,TIM_ID__c,AgencyTIMId__c, Account__r.Id FROM AccountConnection__c WHERE  (TIM_ID__c in : accTimIDs)])
        {
            accMap.put(accCon.TIM_ID__c +accCon.TIM_System__c,accCon);
        }
        
        //Map for Agency Account Connection
        Map<String,AccountConnection__c> agcMap = new Map<String,AccountConnection__c>();
        for(AccountConnection__c agcCon :[SELECT ID, TIM_System__c, AE_Id__c,TIM_ID__c,AgencyTIMId__c, Account__r.Id FROM AccountConnection__c WHERE (AgencyTIMId__c in : agcTimIDs AND TIM_ID__c = '')])
        {
            agcMap.put(agcCon.AgencyTIMId__c +agcCon.TIM_System__c,agcCon);
        }
        
        for(Traffic_Id_Element__c trfElem : trafficIDs)
        {
            
            if(trfElem.Traffic_Type__c  == 'User')
            {
                string ukey = string.valueOf(Integer.valueOf(trfElem.AE_ID__c))+trfElem.TIM_System__c;
                if(userMap.containsKey(ukey))
                {
                    UserConnection__c uConn = userMap.get(ukey);
                    //if(trfElem.User__c == null || trfElem.UserConnection__c == null)
                    //{
                    trfElem.User__c = uConn.User__r.Id;
                    trfElem.UserConnection__c = uConn.Id;
                    //}
                }
            }
            else if(trfElem.Account_Type__c == 'Advertiser' && trfElem.Traffic_Type__c  == 'Account')
            {
                string aKey = trfElem.Account_TIM_ID__c+trfElem.TIM_System__c;
                if(accMap.containsKey(aKey))
                {
                    AccountConnection__c aConn = accMap.get(aKey);
                    //if(trfElem.Account__c == null || trfElem.AccountConnection__c == null)
                    //{
                    trfElem.Account__c = aConn.Account__r.Id;
                    trfElem.AccountConnection__c = aConn.Id;
                    //}
                }
            }
            else if(trfElem.Account_Type__c == 'Agency' && trfElem.Traffic_Type__c  == 'Account')
            {
                string aKey = trfElem.Account_TIM_ID__c+trfElem.TIM_System__c;
                if(agcMap.containsKey(aKey))
                {
                    AccountConnection__c aConn = agcMap.get(aKey);
                    //if(trfElem.Account__c == null || trfElem.AccountConnection__c == null)
                    //{
                    trfElem.Account__c = aConn.Account__r.Id;
                    trfElem.AccountConnection__c = aConn.Id;
                    //}
                }
            }
        }
    
    }
}