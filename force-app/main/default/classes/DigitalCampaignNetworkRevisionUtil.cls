public class DigitalCampaignNetworkRevisionUtil {

    @InvocableMethod(label='Revided Network Changes' description='Revised networks')
    public static void networkChanges(List<Id> ids) {
      
        try{
            
            for(ID id : ids){
                System.debug('DC Network Process Builder ' + id);
            }
                    
            List<Digital_Campaign__c> dcList = getDigitalCampaigns(ids);
                
            for(Digital_Campaign__c dc : dcList){
                deltaChanges(dc);
            }
                
            if (Schema.sObjectType.Digital_Campaign__c.isUpdateable()){
                update dcList;
            }else{
                System.debug('User does have permission to update the Digital Campaign Table');
            }
                  
        }catch(exception ex){         
            System.debug('Error Line Number' + ex.getLineNumber() + ':' + + ex.getMessage());  
        }

      }
      
      @TestVisible
      private static List<Digital_Campaign__c> getDigitalCampaigns(List<Id> ids){

        List<Digital_Campaign__c> dcList = [SELECT id, AdsE_Network__c, AdsE_Network_PriorValues__c, Adse_Network_History__c FROM Digital_Campaign__c WHERE Id IN :ids WITH SECURITY_ENFORCED];        
    
        return dcList;
      }

      @TestVisible
      private static void deltaChanges(Digital_Campaign__c dc){

            List<string> priorValueLst   = new List<string>();
            List<string> currentValueLst = new List<string>();

            if (dc.AdsE_Network_PriorValues__c != null){
                priorValueLst = dc.AdsE_Network_PriorValues__c.split(';');
            }

            if (dc.AdsE_Network__c != null){
                currentValueLst = dc.AdsE_Network__c.split(';');
            }

            Set<String> priorValueSet   = new Set<String>(priorValueLst);
            Set<String> currentValueSet = new Set<String>(currentValueLst);
            
            List<string> removedNetworksLst = new List<string>();
            List<string> addedNetworksLst = new List<string>();
    
 
            for(string network : priorValueSet){
                System.Debug('Prior' + network);  
        
                if (!currentValueSet.contains(network)){
                    System.Debug('Network Remove ' + network); 
                    removedNetworksLst.add(network);
                }
            } 
    
    
            for(string network : currentValueSet){
                System.Debug('Current ' + network);  
       
                if (!priorValueSet.contains(network)){
                    System.Debug('Network Added ' + network); 
                    addedNetworksLst.add(network);
                }
       
            } 
                   
            String history = '';
    
            if (addedNetworksLst.size() > 0){
                history = 'Added: ' + String.join(addedNetworksLst, ',');         
            }
                  
            if (removedNetworksLst.size() > 0){
                string removeNetworks = String.join(removedNetworksLst, ',');
                
                if (history == ''){
                   history = 'Remove: ' + removeNetworks;  
                }else{
                   history += ' || Remove: ' + removeNetworks;   
                }  
            }
            
            dc.Adse_Network_History__c = history.left(255);
      }
}