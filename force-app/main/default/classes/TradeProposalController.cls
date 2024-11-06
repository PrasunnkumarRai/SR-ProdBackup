public class TradeProposalController {
    
    @AuraEnabled
    public static map<String, object> createTradeProposal(String TradeId){
    system.debug('--->'+tradeId);
        map<String, object> data = new map<String, object>();
        map<String, object> defaultValues = new map<String, object>();
        String loggedinuser = Userinfo.getUserId();
        Trade__c objTrade = [SELECT Id, Account__c FROM Trade__c WHERE Id=:tradeId limit 1];
        system.debug('objTrade-->'+objTrade);
        data.put('entityApiName', 'Trade_proposal__c');       
        defaultValues.put('Trade__c', objTrade.Id );        
        if( objTrade.Account__c != null ){
            defaultValues.put('Trade_Proposal_Account__c', objTrade.Account__c);
        } 
        if( defaultValues.size() > 0 ){
            data.put( 'defaultFieldValues', defaultValues );
        }
        return data;
       
        //system.debug('output--->'+data);
        
    }
}