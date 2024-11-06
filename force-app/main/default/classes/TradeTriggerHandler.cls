public class TradeTriggerHandler {

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public TradeTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnBeforeInsert(Trade__c[] newTrades) {
        updateTradeNumber(newTrades);
        updateTradeWithOwnerDetails(newTrades);    
        updateTradeOwner(newTrades);

    }
    
    public void OnAfterInsert(Trade__c[] newTrades) {
        //SyncplicitySRUtils.CreateSyncplicityFolders(new List<Id>(new Map<Id, Trade__c>(newTrades).keySet()));
    }

    @future public static void OnAfterInsertAsync(Set<ID> newTradeIDs){
        //Example usage
        //List<Trade__c> newTrades = [select Id, Name from Trade__c where Id IN :newTradeIDs];
    }

    public void OnBeforeUpdate(Trade__c[] oldTrades, Trade__c[] updatedTrades, Map<ID, Trade__c> TradeMap) {
        updateTradeWithOwnerDetails(updatedTrades);    
    }

    public void OnAfterUpdate(Trade__c[] oldTrades, Trade__c[] updatedTrades, Map<ID, Trade__c> TradeMap){
    }

    @future public static void OnAfterUpdateAsync(Set<ID> updatedTradeIDs){
        //List<Trade__c> updatedTrades = [select Id, Name from Trade__c where Id IN :updatedTradeIDs];
    }

    public void OnBeforeDelete(Trade__c[] TradesToDelete, Map<ID, Trade__c> TradeMap){

    }

    public void OnAfterDelete(Trade__c[] deletedTrades, Map<ID, Trade__c> TradeMap){

    }
 
    @future public static void OnAfterDeleteAsync(Set<ID> deletedTradeIDs){

    }

    public void OnUndelete(Trade__c[] restoredTrades){

    }

    public boolean IsTriggerContext{
    get{ return m_isExecuting;}
    }

    public boolean IsVisualforcePageContext{
    get{ return !IsTriggerContext;}
    }

    public boolean IsWebServiceContext{
    get{ return !IsTriggerContext;}
    }

    public boolean IsExecuteAnonymousContext{
    get{ return !IsTriggerContext;}
    }




// helper methods outside of main TriggerHandler pattern:

    public void updateTradeNumber(List<Trade__c> lstTrades){
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setTradeIds = new Set<Id>();
        
        System.debug('***lstTrades*****' + lstTrades);
        
        for(Trade__c objTrade : lstTrades){
            System.debug('***objTrade*****' + objTrade);
            setAccountIds.add(objTrade.Account__c);
            //setTradeIds.add(objTrade.id);
        }
        
        System.debug('***setAccountIds*****' + setAccountIds);
        
        Map<Id, Account> mapAccounts = new Map<Id, Account>([Select id, name  from Account where id IN: setAccountIds]);
        System.debug('***mapAccounts*****' + mapAccounts);
        
        List<AggregateResult> lstResult = [select Account__c, count(id)childTradeCount from Trade__c where Account__c!=null group by  Account__c];
        System.debug('***lstResult*****' + lstResult);
        
        Map<Id, Integer> mapAccountIdTradeCount = new Map<Id, Integer>();
        
        
        for (AggregateResult ar : lstResult)  
        {
            mapAccountIdTradeCount.put((id)ar.get('Account__c'), (Integer)ar.get('childTradeCount'));
            System.debug('***ar.Account__c*****' + ar.get('Account__c'));
            System.debug('***ar.get(childTradeCount)*****' + ar.get('childTradeCount'));
        }
        
        System.debug('***mapAccountIdTradeCount*****' + mapAccountIdTradeCount);
        
        for(Trade__c objTrade : lstTrades){
            System.debug('***objTrade*****' + objTrade);
            Integer index;
            if(mapAccountIdTradeCount != null && mapAccountIdTradeCount.size() > 0 && mapAccountIdTradeCount.keySet().contains(objTrade.Account__c))
            {
                index = mapAccountIdTradeCount.get(objTrade.Account__c)+1;
            }else{
                mapAccountIdTradeCount.put(objTrade.Account__c,0);
                index = 1;
            }
            if(mapAccounts != null && mapAccounts.size() > 0 && mapAccounts.keySet().contains(objTrade.Account__c)){
                String newName = mapAccounts.get(objTrade.Account__c).Name + '-TRADE-' + index;
                System.debug('***newName*****' + newName);
                mapAccountIdTradeCount.put(objTrade.Account__c, index);
                objTrade.Trade_Number__c = newName;
            }else{
                System.debug('***Account Not present with id *****' + objTrade.Account__c);
            }
            
        }
        System.debug('***mapAccountIdTradeCount*****' + mapAccountIdTradeCount);
    }
    
    public void updateTradeWithOwnerDetails(List<Trade__c> lstTrades){
        Set<Id> setOwnerIds = new Set<Id>();
        Set<Id> setTradeIds = new Set<Id>();
        
        System.debug('***lstTrades*****' + lstTrades);
        
        for(Trade__c objTrade : lstTrades){
            System.debug('***objTrade*****' + objTrade);
            setOwnerIds.add(objTrade.OwnerId);
        }
        
        System.debug('***setOwnerIds*****' + setOwnerIds);
        
        Map<Id, User> mapOwners = new Map<Id, User>([Select id, Sales_Office__c, Region__c, Division__c  from User where id IN: setOwnerIds]);
        System.debug('***mapOwners*****' + mapOwners);
        
        for(Trade__c objTrade : lstTrades){
            System.debug('***objTrade*****' + objTrade);
            if(mapOwners != null && mapOwners.size() > 0 && mapOwners.keySet().contains(objTrade.OwnerId)){
                System.debug('***mapOwners.get(objTrade.OwnerId)*****' + mapOwners.get(objTrade.OwnerId));
                objTrade.Region__c = mapOwners.get(objTrade.OwnerId).Region__c;
                objTrade.Division__c = mapOwners.get(objTrade.OwnerId).Division__c;
                objTrade.Sales_Office__c = mapOwners.get(objTrade.OwnerId).Sales_Office__c;
                System.debug('***objTrade*****' + objTrade);
            }
        }
    }
    
    public void updateTradeOwner(List<Trade__c> lstTrades){
        Set<Id> setOpptyIds = new Set<Id>();
        
        System.debug('***lstTrades*****' + lstTrades);
        
        for(Trade__c objTrade : lstTrades){
            System.debug('***objTrade*****' + objTrade);
            setOpptyIds.add(objTrade.Trade_Opportunity__c);
        }
        
        System.debug('***setOpptyIds*****' + setOpptyIds);
        
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>([Select id, OwnerId  from Opportunity where id IN: setOpptyIds]);
        System.debug('***mapOpportunity*****' + mapOpportunity);
        
        for(Trade__c objTrade : lstTrades){
            System.debug('***objTrade*****' + objTrade);
            if(objTrade.Trade_Opportunity__c != null && mapOpportunity != null && mapOpportunity.size() > 0 && mapOpportunity.keySet().contains(objTrade.Trade_Opportunity__c)){
                objTrade.OwnerId = mapOpportunity.get(objTrade.Trade_Opportunity__c).OwnerId;
            }
        }
    }
    

    public static list<Trade__c> updateUserWarning(Map<Id,trade__c> MapTrades){//Commentted for Simplicity
        // public static void updateUserWarning(Map<Id,trade__c> MapTrades){
           system.debug('--->'+MapTrades); 
      List<Trade__c> tradewarninglist = new List<Trade__c>();   
      List<Trade__c> tradewarninglistupdate = new List<Trade__c>();  
      //List<Trade__c> tradelist = [Select id,Status__c,Trade_Percent_of_Deal__c,Total_Deal_Revenue__c,Trade_Proposal_Value_Sum__c,Paid_Proposal_Value_Sum__c,Trade_Proposal__r.Has_Production_Services__c,Trade_Proposal__r.Has_Digital_Campaigns__c,warning__c from trade__c where id in: MapTrades.keyset()];          
      for(Trade__c td:MapTrades.values()){
       // if(td.Status__c == 'New' || td.Status__c == 'Draft' || td.Trade_Percent_of_Deal__c > 0.5 || (td.Total_Deal_Revenue__c < (( td.Trade_Proposal_Value_Sum__c + td.Paid_Proposal_Value_Sum__c ) * 0.5)) || td.Has_Production_service__c || td.Has_Digital_Campaign__c){
        tradewarninglist.add(td);
       // }     
      } 
      if(tradewarninglist.size() >0){
         List<Document> doclist = [SELECT Id,LastModifiedDate,Name FROM Document];
         string strOrgId = UserInfo.getOrganizationId();
         String Draft;
         String TradeDealRevenue;
         String TradeNotSubmitted;
         String warningHTML = '<html><body><div style="color: red;">';
         for(Document dc : doclist){
            if(dc.Name == 'Draft'){
               Draft = '/servlet/servlet.ImageServer?id=' + dc.Id + '&oid=' + strOrgId;            
            }
            if(dc.Name == 'TradeDealRevenue'){
               TradeDealRevenue = '/servlet/servlet.ImageServer?id=' + dc.Id + '&oid=' + strOrgId;            
            }
            if(dc.Name == 'TradeNotSubmitted'){
               TradeNotSubmitted = '/servlet/servlet.ImageServer?id=' + dc.Id + '&oid=' + strOrgId;            
            }        
         } 
         for(trade__c td:tradewarninglist){
               if(td.Status__c == 'New'){
                warningHTML += '<img alt="image" src=' +TradeNotSubmitted+ ' width="70px" height="70px"></img> '+ system.label.TradeNew;
               }
                if(td.Status__c == 'Draft' && td.Has_Production_service__c == true && td.Has_Digital_Campaign__c == true && td.Trade_Percent_of_Deal__c > 0.5 && (td.Total_Deal_Revenue__c<((td.Trade_Proposal_Value_Sum__c+td.Paid_Proposal_Value_Sum__c) * 0.5))){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+ system.label.Draft + ' </p><p> ' +system.label.TradeProductionServices+ ' </p><p> '+ system.label.TradeDigitalCampaign+' </p><p> '+system.label.TradePercentage +'</p><p>'+system.label.TradeDealRevenue+'</p>';
                }else if(td.Status__c == 'Draft' && td.Has_Production_service__c == true && td.Has_Digital_Campaign__c == true &&  td.Trade_Percent_of_Deal__c > 0.5){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+ system.label.Draft + ' </p><p> ' +system.label.TradeProductionServices+ ' </p><p> '+ system.label.TradeDigitalCampaign+' </p><p> '+system.label.TradePercentage+'</p>';
                }else if(td.Status__c == 'Draft' && td.Has_Production_service__c == true && td.Has_Digital_Campaign__c == true  && (td.Total_Deal_Revenue__c<((td.Trade_Proposal_Value_Sum__c+td.Paid_Proposal_Value_Sum__c) * 0.5))){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+ system.label.Draft + ' </p><p> ' +system.label.TradeProductionServices+ ' </p><p> '+ system.label.TradeDigitalCampaign+' </p><p> '+system.label.TradeDealRevenue+'</p>';
                }else if(td.Status__c == 'Draft' && td.Has_Production_service__c == true && td.Trade_Percent_of_Deal__c > 0.5 && (td.Total_Deal_Revenue__c<((td.Trade_Proposal_Value_Sum__c+td.Paid_Proposal_Value_Sum__c) * 0.5))){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+ system.label.Draft + ' </p><p> ' +system.label.TradeProductionServices+ ' </p><p> '+system.label.TradePercentage +'</p><p>'+system.label.TradeDealRevenue+'</p>';
                }else if(td.Status__c == 'Draft' && td.Has_Digital_Campaign__c == true && td.Trade_Percent_of_Deal__c > 0.5 && (td.Total_Deal_Revenue__c<((td.Trade_Proposal_Value_Sum__c+td.Paid_Proposal_Value_Sum__c) * 0.5))){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+ system.label.Draft + ' </p><p> '+ system.label.TradeDigitalCampaign+' </p><p> '+system.label.TradePercentage +'</p><p>'+system.label.TradeDealRevenue+'</p>';
                }else if(td.Has_Production_service__c == true && td.Has_Digital_Campaign__c == true && td.Trade_Percent_of_Deal__c > 0.5 && (td.Total_Deal_Revenue__c<((td.Trade_Proposal_Value_Sum__c+td.Paid_Proposal_Value_Sum__c) * 0.5))){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+system.label.TradeProductionServices+ ' </p><p> '+ system.label.TradeDigitalCampaign+' </p><p> '+system.label.TradePercentage + '</p><p>'+system.label.TradeDealRevenue+'</p>';
                }else if(td.Status__c == 'Draft' && td.Has_Production_service__c == true && td.Has_Digital_Campaign__c == true){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+ system.label.Draft + ' </p><p> ' +system.label.TradeProductionServices+ ' </p><p> '+ system.label.TradeDigitalCampaign+'</p>';
                }else if(td.Status__c == 'Draft' && td.Has_Production_service__c == true && td.Trade_Percent_of_Deal__c > 0.5){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+ system.label.Draft + ' </p><p> ' +system.label.TradeProductionServices+ ' </p><p> '+system.label.TradePercentage+'</p>';
                }else if(td.Status__c == 'Draft' && td.Has_Production_service__c == true && (td.Total_Deal_Revenue__c<((td.Trade_Proposal_Value_Sum__c+td.Paid_Proposal_Value_Sum__c) * 0.5))){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+ system.label.Draft + ' </p><p> ' +system.label.TradeProductionServices+ '</p><p> '+system.label.TradeDealRevenue+'</p>';
                }else if(td.Status__c == 'Draft' && td.Has_Digital_Campaign__c == true && td.Trade_Percent_of_Deal__c > 0.5){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+ system.label.Draft + ' </p><p>' + system.label.TradeDigitalCampaign+' </p><p> '+system.label.TradePercentage +'</p>';
                }else if(td.Status__c == 'Draft' && td.Has_Digital_Campaign__c == true && (td.Total_Deal_Revenue__c<((td.Trade_Proposal_Value_Sum__c+td.Paid_Proposal_Value_Sum__c) * 0.5))){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+ system.label.Draft + ' </p><p> ' + system.label.TradeDigitalCampaign+' </p><p> '+system.label.TradeDealRevenue+'</p>';
                }else if(td.Status__c == 'Draft' && td.Trade_Percent_of_Deal__c > 0.5 && (td.Total_Deal_Revenue__c<((td.Trade_Proposal_Value_Sum__c+td.Paid_Proposal_Value_Sum__c) * 0.5))){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+ system.label.Draft + ' </p><p> ' +system.label.TradePercentage +system.label.TradeDealRevenue+'</p>';
                }else if(td.Has_Production_service__c == true && td.Has_Digital_Campaign__c == true && td.Trade_Percent_of_Deal__c > 0.5){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+system.label.TradeProductionServices+ '</p><p> '+ system.label.TradeDigitalCampaign+' </p><p> '+system.label.TradePercentage +'</p>';
                }else if(td.Has_Production_service__c == true && td.Has_Digital_Campaign__c == true && (td.Total_Deal_Revenue__c<((td.Trade_Proposal_Value_Sum__c+td.Paid_Proposal_Value_Sum__c) * 0.5))){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+system.label.TradeProductionServices+ ' </p><p> '+ system.label.TradeDigitalCampaign+' </p><p> '+system.label.TradeDealRevenue+'</p>';
                }else if(td.Has_Production_service__c == true && td.Trade_Percent_of_Deal__c > 0.5 && (td.Total_Deal_Revenue__c<((td.Trade_Proposal_Value_Sum__c+td.Paid_Proposal_Value_Sum__c) * 0.5))){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img>'+system.label.TradeProductionServices+' </p><p>'+system.label.TradePercentage +'</p><p>'+system.label.TradeDealRevenue+'</p>';
                }else if(td.Has_Digital_Campaign__c == true && td.Trade_Percent_of_Deal__c > 0.5 && (td.Total_Deal_Revenue__c<((td.Trade_Proposal_Value_Sum__c+td.Paid_Proposal_Value_Sum__c) * 0.5))){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+ system.label.TradeDigitalCampaign+' </p><p> '+system.label.TradePercentage +'</p><p>'+system.label.TradeDealRevenue+'</p>';
                }else if(td.Status__c == 'Draft' && td.Has_Production_service__c == true){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+ system.label.Draft + ' </p><p> ' +system.label.TradeProductionServices+'</p>';
                }else if(td.Status__c == 'Draft' && td.Has_Digital_Campaign__c == true){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+ system.label.Draft +' </p><p> '+ system.label.TradeDigitalCampaign+'</p>';
                }else if(td.Status__c == 'Draft' && td.Trade_Percent_of_Deal__c > 0.5){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+ system.label.Draft + ' </p><p> ' +system.label.TradePercentage +'</p>';
                }else if(td.Status__c == 'Draft' && (td.Total_Deal_Revenue__c<((td.Trade_Proposal_Value_Sum__c+td.Paid_Proposal_Value_Sum__c) * 0.5))){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+ system.label.Draft + ' </p><p> ' +system.label.TradeDealRevenue+'</p>';
                }else if(td.Has_Production_service__c == true && td.Has_Digital_Campaign__c == true){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+system.label.TradeProductionServices+ ' </p><p> '+ system.label.TradeDigitalCampaign+'</p>';
                }else if(td.Has_Production_service__c == true && td.Trade_Percent_of_Deal__c > 0.5 ){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+system.label.TradeProductionServices+ ' </p><p> '+ system.label.TradePercentage +'</p>';
                }else if(td.Has_Production_service__c == true && (td.Total_Deal_Revenue__c<((td.Trade_Proposal_Value_Sum__c+td.Paid_Proposal_Value_Sum__c) * 0.5))){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+system.label.TradeProductionServices+ ' </p><p> '+ system.label.TradeDealRevenue+'</p>';
                }else if(td.Has_Digital_Campaign__c == true && td.Trade_Percent_of_Deal__c > 0.5){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+ system.label.TradeDigitalCampaign+' </p><p> '+system.label.TradePercentage +'</p>';
                }else if(td.Has_Digital_Campaign__c == true && (td.Total_Deal_Revenue__c<((td.Trade_Proposal_Value_Sum__c+td.Paid_Proposal_Value_Sum__c) * 0.5))){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+ system.label.TradeDigitalCampaign+' </p><p> '+system.label.TradeDealRevenue+'</p>';
                }else if(td.Trade_Percent_of_Deal__c > 0.5 && (td.Total_Deal_Revenue__c<((td.Trade_Proposal_Value_Sum__c+td.Paid_Proposal_Value_Sum__c) * 0.5))){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+system.label.TradePercentage +system.label.TradeDealRevenue+'</p>';
                }else if(td.Status__c == 'Draft'){
                             warningHTML += '<img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+system.label.Draft+'</br>';
                }else if(td.Has_Production_service__c == true){
                             warningHTML += '<img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+system.label.TradeProductionServices+'</br>';
                }else if(td.Has_Digital_Campaign__c == true){
                             warningHTML += '<img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+system.label.TradeDigitalCampaign+'</br>';
                }else if(td.Trade_Percent_of_Deal__c > 0.5){
                             warningHTML += '<img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+system.label.TradePercentage+'</br>';
                }else if((td.Total_Deal_Revenue__c<((td.Trade_Proposal_Value_Sum__c+td.Paid_Proposal_Value_Sum__c) * 0.5))){
                             warningHTML += '<p><img alt="image" src=' +Draft+ ' width="70px" height="70px"></img> '+system.label.TradeDealRevenue+'</p>';
                }
           
            warningHTML += '</div></body></html>';
            system.debug('warningHTML---->'+warningHTML);
            trade__c trd = MapTrades.get(td.id);
            trd.warning__c = warningHTML;
         }
      }
 
        return tradewarninglist;//commentted for Simplicity
    }
    
}