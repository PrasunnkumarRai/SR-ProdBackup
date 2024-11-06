public class AccountCNARequestActionController {
    @AuraEnabled
    public static map<String, object> createCNARequest( Id AccId ){
        map<String, object> data = new map<String, object>();
        map<String, object> defaultValues = new map<String, object>();
        String loggedinuser = Userinfo.getUserId();
        Account objAcc = [SELECT Id, Agency__c, ShippingStreet, 
                                ShippingCity, ShippingState, OwnerId,
                                Owner.Sales_Office__c, Owner.Division__c, Owner.Region__c, (SELECT Id,AccountId,UserId FROM AccountTeamMembers where UserId =: loggedinuser) 
                                FROM Account 
                                WHERE Id=:AccId limit 1];
        User u = [SELECT Id,Sales_Office__c, Division__c, Region__c FROM User WHERE Id=:userinfo.getuserid() limit 1];
                    
     /*   defaultValues.put('Account_Executive__c', objAcc.OwnerId );
        defaultValues.put('Sales_Office__c', objAcc.Owner.Sales_Office__c );
        defaultValues.put('Division__c', objAcc.Owner.Division__c );
        defaultValues.put('Region__c', objAcc.Owner.Region__c  */
        if(objAcc.AccountTeamMembers.size() >0 || objAcc.OwnerId == loggedinuser){
         data.put('entityApiName', 'CNA__c');
        defaultValues.put('Account_Executive__c', userinfo.getuserid() );
        defaultValues.put('Sales_Office__c', u.Sales_Office__c );
        defaultValues.put('Division__c', u.Division__c );
        defaultValues.put('Region__c', u.Region__c );
        if( objAcc.Id != null ){
            defaultValues.put('Account__c', objAcc.Id );
            
            String location = objAcc.ShippingStreet != null ? objAcc.ShippingStreet+', ' : '';
            location += objAcc.ShippingCity != null ? objAcc.ShippingCity+', ' : '';
            location += objAcc.ShippingState != null ? objAcc.ShippingState+', ' : '';
            location = location.EndsWith(', ') ? location.subStringBeforeLast(', ') : location; 
            defaultValues.put('Location__c', location );
            
        }
        if( objAcc.Agency__c != null ){
            defaultValues.put('Agency__c', objAcc.Agency__c );
        }
        
        if( defaultValues.size() > 0 ){
            data.put( 'defaultFieldValues', defaultValues );
        }
        }else{
            data = null;
        }
        return data;
    }
}