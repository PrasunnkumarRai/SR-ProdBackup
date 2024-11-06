public class OpportunityTradeController {
    
    @AuraEnabled
    public static map<String, object> createTrade( Id opptyId){
        map<String, object> data = new map<String, object>();
        map<String, object> defaultValues = new map<String, object>();
        String loggedinuser = Userinfo.getUserId();
        Opportunity objOppty = [SELECT Id, AccountId, Account.Agency__c, Account.ShippingStreet, 
                                Account.ShippingCity, Account.ShippingState, OwnerId,
                                Owner.Sales_Office__c, Owner.Division__c, Owner.Region__c,(SELECT Id,OpportunityId,UserId FROM OpportunityTeamMembers where UserId =: loggedinuser) 
                                FROM Opportunity 
                                WHERE Id=:opptyId limit 1];
        system.debug('objOppty-->'+objOppty.OpportunityTeamMembers.size());
       if(objOppty.OpportunityTeamMembers.size() >0 || objOppty.OwnerId == loggedinuser){
        data.put('entityApiName', 'Trade__c');       
        defaultValues.put('Sales_Office__c', objOppty.Owner.Sales_Office__c );
        defaultValues.put('Division__c', objOppty.Owner.Division__c );
        defaultValues.put('Region__c', objOppty.Owner.Region__c );
        defaultValues.put('Trade_Opportunity__c', objOppty.Id );        
        if( objOppty.AccountId != null ){
            defaultValues.put('Account__c', objOppty.AccountId );
        } 
        if( defaultValues.size() > 0 ){
            data.put( 'defaultFieldValues', defaultValues );
        }
        return data;
       }else{
           data = null;
          return data;  
       }
        //system.debug('output--->'+data);
        
    }
}