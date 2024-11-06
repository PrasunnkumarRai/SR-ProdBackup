/*
  Author          :  Jose, Madhusudhan
  Date            :  Sep 05-19
  Description      :  Helper class for OMS_NetworkExController             
  Modification History : 
*/
public  class GeographyTargetClass {
    
    public List<AuraSelectOptions> DMAList {get; set;}
    public List<AuraSelectOptions> ZoneList {get; set;}
    public List<AuraSelectOptions> CongressList {get; set;}
    public List<AuraSelectOptions> TimezoneList {get; set;}
    public Boolean isDMAVisible {get; set;}
    public Boolean isZoneVisible {get; set;}
    public Boolean isTimeZoneVisible {get; set;}
    public Boolean isCongressVisible {get; set;}
    public string DMAHelpText {get; set;}
    public string ZoneHelpText {get; set;}
    public string CongressHelpText {get; set;}
    public Boolean isNotSSPRecordType {get; set;}
    public Boolean isLockRecord {get; set;}
   public Boolean isNotAddressableDisplayPreroll {get; set;}

    

   public static list<string> getDMA(Digital_Campaign__c dcRecord){
       List<string> dmaOcl = new List<string>();
       list<Zipcode_Mapping__c> lstZM = new list<Zipcode_Mapping__c>();
       //Added by Madhusudhan on 18th-Jul -> Ensure that the "United States" is added as a second entry in DMA picklist
       if(dcRecord.RecordType.DeveloperName != 'Addressable_TV'){//Added by Madhusudhan on Sep18-18 for SRSF-1281
           dmaOcl.add('None');
           dmaOcl.add('All DMAs');
           for(Zipcode_Mapping__c dzm: [Select id, Nielsen_DMA_Name__c 
                                            from Zipcode_Mapping__c 
                                            where Nielsen_DMA_Name__c != null
                                            order by Nielsen_DMA_Name__c]){
             dmaOcl.add(dzm.Nielsen_DMA_Name__c);
         }
       }else{
           for(Zipcode_Mapping__c dzm: [Select id, Nielsen_DMA_Name__c 
                                                from Zipcode_Mapping__c 
                                                where Nielsen_DMA_Name__c != null and Is_AddressableTV_Recordtype__c=true
                                                order by Nielsen_DMA_Name__c]){
               dmaOcl.add(dzm.Nielsen_DMA_Name__c);
           }
       }
       return dmaOcl;
   }

   public static list<string> getZones(){
       List<string> srOcl = new List<string>();
       srOcl.add('None');
       for(Zipcode_Mapping__c dzm: [Select id, SR_Zone_Name__c 
                                            from Zipcode_Mapping__c 
                                            where RecordType.DeveloperName='SR_Zone' and SR_Zone_Name__c != null and Is_Active__c=true
                                            order by SR_Zone_Name__c]){
           srOcl.add(dzm.SR_Zone_Name__c);
       }
       return srOcl;
   }

 /*  public static list<string> getCongressionals(){
       List<string> conOcl = new List<string>();
       conOcl.add('None');
       for(Zipcode_Mapping__c dzm: [Select id, Congressional_District_Name__c 
                                            from Zipcode_Mapping__c 
                                            where Congressional_District_Name__c != null
                                            order by Congressional_District_Name__c]){
           conOcl.add(dzm.Congressional_District_Name__c);
       }
       return conOcl;
   }*/
   
   public static list<string> getTimeZones(){
       List<string> conOcl = new List<string>();
       conOcl.add('None');
       Schema.DescribeFieldResult fieldDescription = Zipcode_Mapping__c.Time_Zones__c.getDescribe();
       // Get picklist values from field description
       for (Schema.PicklistEntry entry : fieldDescription.getPicklistValues()) {
           conOcl.add(entry.getValue());
       }
       System.debug('conOcl::'+conOcl);
       return conOcl;
   }

}