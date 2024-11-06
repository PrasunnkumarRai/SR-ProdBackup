global class TierUpdateAfterMerge implements Database.Batchable <SObject> {
    String trxnId;
    Map<String,Decimal> tierMapping;
  
    global TierUpdateAfterMerge(String trxnId) {
        this.trxnId = trxnId;
        List<Tier_Designation_Order__c> rawOrders = [SELECT Name, Tier_Order__c FROM Tier_Designation_Order__c];
        this.tierMapping = new Map<String,Decimal>();
        for (Tier_Designation_Order__c rawOrder : rawOrders) {
            tierMapping.put(rawOrder.Name, rawOrder.Tier_Order__c);
        }
    }

    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
            SELECT Account__c, Error_Description__c 
            FROM Account_Merge_Log__c 
            WHERE TransactionId__c =: trxnId
        ]); 
     
    }

   
    global void execute(Database.BatchableContext context, List<Account_Merge_Log__c> scope) {
        Set<String> accIds = new Set<String>();
        for (Account_Merge_Log__c log : scope) {
            if (log.Error_Description__c == NULL) {
                accIds.add(log.Account__c);
            }
        }
        System.debug('accIds@@@'+accIds);
        
        List<Account_SAM_Mapping__c> tiers = [SELECT Account__c, Tier_Designation__c, Tier_External_Id__c FROM Account_SAM_Mapping__c  WHERE Account__c IN :accIds AND Tier_Designation__c != NULL];
        Map<String, List<Account_SAM_Mapping__c>> accTierMap = new Map<String, List<Account_SAM_Mapping__c>>();
        for (Account_SAM_Mapping__c tier : tiers) {
            List<Account_SAM_Mapping__c> tierList = accTierMap.get(tier.Account__c);
            if (tierList == null) {
                tierList = new List<Account_SAM_Mapping__c>();
                accTierMap.put(tier.Account__c, tierList);
            }
            tierList.add(tier);
        }
        List<Account_SAM_Mapping__c> recordsToDelete = new List<Account_SAM_Mapping__c>();
        List<Account_SAM_Mapping__c> recordsToUpdate = new List<Account_SAM_Mapping__c>();
        for (String accId : accTierMap.keySet()) {
            List<Account_SAM_Mapping__c> tierDesignations = accTierMap.get(accId);
            Account_SAM_Mapping__c lowestTierRecord = tierDesignations[0];
            Decimal lowestOrder = tierMapping.get(lowestTierRecord.Tier_Designation__c);
            for (Account_SAM_Mapping__c record : tierDesignations) {
                Decimal currentOrder = tierMapping.get(record.Tier_Designation__c);
                if (currentOrder < lowestOrder) {
                    lowestTierRecord = record;
                    lowestOrder = currentOrder;
                }
            }
            for (Account_SAM_Mapping__c record : tierDesignations) {
                if (record.Id != lowestTierRecord.Id) {
                    recordsToDelete.add(record);
                }
            }
            if (lowestTierRecord.Tier_External_Id__c != accId + lowestTierRecord.Tier_Designation__c) {
                Account_SAM_Mapping__c updateTier = new Account_SAM_Mapping__c(Id = lowestTierRecord.Id, Tier_External_Id__c = accId + lowestTierRecord.Tier_Designation__c);
                recordsToUpdate.add(updateTier);
            }
        }
        
        if (!recordsToDelete.isEmpty()) {
            delete recordsToDelete;
        }
        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
    }

   
    global void finish(Database.BatchableContext context) {
       
    }
}