public class ProposalUtils 
{
    public static Map<String, Schema.RecordTypeInfo> recordTypeInfoMap{
        get{
            if (recordTypeInfoMap == null)
            {
                recordTypeInfoMap = new map<String,Schema.RecordTypeInfo>();
                recordTypeInfoMap = Proposal__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
            }
            return recordTypeInfoMap;
        }
        set;
    }
    
    public static Id linearRtId  = recordTypeInfoMap.get('Linear').getRecordTypeId();
    public static Id inventoryRtId  = recordTypeInfoMap.get('Inventory').getRecordTypeId();
    public static Id politicalRtId  = recordTypeInfoMap.get('Political').getRecordTypeId();
    public static Id tradeRtId  = recordTypeInfoMap.get('Trade').getRecordTypeId();
    public static Id oppBudgetRtId  = recordTypeInfoMap.get('Opportunity_Budget').getRecordTypeId();
    public static Id adjustOppBudgetRtId  = recordTypeInfoMap.get('Adjust_Opportunity_Budget').getRecordTypeId();
    public static Id advancedProposalRtId  = recordTypeInfoMap.get('Advanced_Proposal').getRecordTypeId();
    public static Id advancedPoliticalRtId  = recordTypeInfoMap.get('Advanced_Political').getRecordTypeId(); //SRSF-4907
    public static Id advancedTradeRtId  = recordTypeInfoMap.get('Advanced_Trade').getRecordTypeId(); //SRSF-4907
    
}