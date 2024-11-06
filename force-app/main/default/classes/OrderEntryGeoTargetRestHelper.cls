global class OrderEntryGeoTargetRestHelper {
    public List<string> StateList {get;set;}
    public List<string> DMAList {get; set;}
    public List<string> ZoneList {get; set;}
    public List<string> CongressList {get; set;}

    private static list<string> getStates() {
        List<String> stateList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Digital_Campaign__c.State__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            stateList.add(pickListVal.getValue());
        }     
        return stateList;
    }

    private static list<string> getDMA(){
        List<string> dmaList = new List<string>();
        dmaList.add('None');
        dmaList.add('All DMAs');
        for(Zipcode_Mapping__c dzm: [
            SELECT 
                id, 
                Nielsen_DMA_Name__c 
            FROM Zipcode_Mapping__c 
            WHERE Nielsen_DMA_Name__c != null
            ORDER by Nielsen_DMA_Name__c
        ])
        {
            dmaList.add(dzm.Nielsen_DMA_Name__c);
        }
        
        return dmaList;
    }

    private static list<string> getZones(){
        List<string> zoneList = new List<string>();
        zoneList.add('None');
        for(Zipcode_Mapping__c dzm: [
            SELECT 
                id, 
                SR_Zone_Name__c 
            FROM Zipcode_Mapping__c 
            WHERE RecordType.DeveloperName='SR_Zone' 
            AND SR_Zone_Name__c != null 
            AND Is_Active__c = true
            ORDER by SR_Zone_Name__c
        ])
        {
            zoneList.add(dzm.SR_Zone_Name__c);
        }
        return zoneList;
    }

    private static list<string> getCongressionals(){
        List<string> congressList = new List<string>();
        congressList.add('None');
        for(Zipcode_Mapping__c dzm: [
            SELECT 
                id, 
                Congressional_District_Name__c 
            FROM Zipcode_Mapping__c 
            WHERE Congressional_District_Name__c != null
            ORDER by Congressional_District_Name__c
        ]){
            congressList.add(dzm.Congressional_District_Name__c);
        }
        return congressList;
    }

    public OrderEntryGeoTargetRestHelper() {
        StateList = getStates();
        DMAList = getDMA();
        ZoneList = getZones();
        CongressList = getCongressionals();
    }
}