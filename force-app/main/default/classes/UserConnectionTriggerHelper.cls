/*
###########################################################################
# File..................: UserConnectionTriggerHelper.cls
# Version...............: 1
# Created by............: Ankit Bhatia   
# Created Date..........: 15-May-2017
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This class will be called from trigger on User Connection object whnever a record is inserted.
# Change Log:               
#
#
############################################################################*/
public with sharing class UserConnectionTriggerHelper {

public List<UserConnection__c> userConList;
public Map<ID,List<UserConnection__c>> userConMap;
public Set<ID> userList ; 
    public UserConnectionTriggerHelper()
    {
        userList = new Set<ID>();
        userConList = new List<UserConnection__c>();
        userConMap = new Map<ID,List<UserConnection__c>>();
    }
    /**
     * This method is used to query the User Connection for the current user and based on the AE ID  and TIm System.
     * 
     * @return (Map<ID,List<UserConnection__c>>) (userConMap)
    */
    public Map<ID,List<UserConnection__c>> getUserConnection(UserConnection__c[] userCons)
    {
        try{
        
        for (UserConnection__c user : userCons) {
            userList.add(user.User__c);
        }
        userConList = [Select ID,Name,User__c,AE_Id__c,TIM_System__c,Is_Primary__c from UserConnection__c where User__c in :userList];
        for(UserConnection__c userCon : userCons)
        {
            //if AE Id IS NOT blank on new user connection record, look for duplicate user connection with matching user
            if(String.isNotBlank(userCon.AE_Id__c)){ 
                for(UserConnection__c uCon : userConList)
                {
                    if(userCon.User__c == uCon.User__c && userCon.TIM_System__c == uCon.TIM_System__c && userCon.Is_Primary__c == true && uCon.Is_Primary__c == true){
                        userCon.addError('You already have a Primary User Connection Record. '+ uCon.Name);
                    }
                }
            }
            //if AE Id IS blank on new user connection record, look for duplicate user connection with matching user and tim system
            /*else if(String.isBlank(userCon.AE_Id__c)){ 
                for(UserConnection__c uCon : userConList)
                {
                    if(userCon.User__c == uCon.User__c && userCon.TIM_System__c == uCon.TIM_System__c )
                    userCon.addError('You already have a User Connection Record. '+ uCon.Name);
                }
            }*/
            
        }
            
         /*
         List<UserConnection__c> usercList = new List<UserConnection__c>();
            if(userConMap.size() == 0)
            {
                
                usercList.add(userCon);
                userConMap.put(userCon.User__r.ID,usercList);
            }
            else
            {
                usercList = new List<UserConnection__c>();
                usercList.add(userCon);
                if(userConMap.containsKey(userCon.User__r.ID) == false)
                    userConMap.put(userCon.User__r.ID,usercList);
                else
                {
                    usercList = userConMap.get(userCon.User__r.ID);
                    usercList.add(userCon);
                    userConMap.put(userCon.User__r.ID,usercList);
                }
            }
         */   
        }
        catch(exception ex)
        {
            system.debug('Error' + ex.getMessage());
        }
        return userConMap;
    }
    
}