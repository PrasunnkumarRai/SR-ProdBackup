public class OpportunityRequestsActionController {
    @AuraEnabled
    public static map<String, object> createCNARequest( Id opptyId ){
        map<String, object> data = new map<String, object>();
        map<String, object> defaultValues = new map<String, object>();
        String loggedinuser = Userinfo.getUserId();
        Opportunity objOppty = [SELECT Id, AccountId, Account.Agency__c, Account.ShippingStreet, 
                                Account.ShippingCity, Account.ShippingState, OwnerId,
                                Owner.Sales_Office__c, Owner.Division__c, Owner.Region__c,(SELECT Id,OpportunityId,UserId FROM OpportunityTeamMembers where UserId =: loggedinuser) 
                                FROM Opportunity 
                                WHERE Id=:opptyId limit 1];
       if(objOppty.OpportunityTeamMembers.size() >0 || objOppty.OwnerId == loggedinuser){
        data.put('entityApiName', 'CNA__c');       
        defaultValues.put('Opportunity__c', objOppty.Id );
        defaultValues.put('Account_Executive__c', objOppty.OwnerId );
        defaultValues.put('Sales_Office__c', objOppty.Owner.Sales_Office__c );
        defaultValues.put('Division__c', objOppty.Owner.Division__c );
        defaultValues.put('Region__c', objOppty.Owner.Region__c );
        
        if( objOppty.AccountId != null ){
            defaultValues.put('Account__c', objOppty.AccountId );
            
            String location = objOppty.Account.ShippingStreet != null ? objOppty.Account.ShippingStreet+', ' : '';
            location += objOppty.Account.ShippingCity != null ? objOppty.Account.ShippingCity+', ' : '';
            location += objOppty.Account.ShippingState != null ? objOppty.Account.ShippingState+', ' : '';
            location = location.EndsWith(', ') ? location.subStringBeforeLast(', ') : location; 
            defaultValues.put('Location__c', location );
            
        }
        if( objOppty.Account.Agency__c != null ){
            defaultValues.put('Agency__c', objOppty.Account.Agency__c );
        }
        
        if( defaultValues.size() > 0 ){
            data.put( 'defaultFieldValues', defaultValues );
        }
        
        return data;
         }else{
             data = null;
             return data;
         }
    }
}