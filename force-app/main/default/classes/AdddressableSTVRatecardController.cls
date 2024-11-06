/*
    Customer/Project:    Spectrum Reach 
    Class name:          AdddressableSTVRatecardController
    Author/Date:         M&S US - 05/20/2021
    Related US:          SRSF-3593
    Purpose:             Controller For AddressableSTV
  
*/
public class AdddressableSTVRatecardController {
    //
    //METHOD DESCRIPTION : Based on the recordtype, display the Data catalog records as options 
    
    @AuraEnabled (cacheable=true)
    public static string retrieveDisplayText(string recordType){
        String dataCatalogRTForSTVStr = System.Label.dataCatalogRTForSTV;
        List<String> dataCatalogRTForSTVList = new List<String>();
        dataCatalogRTForSTVList = dataCatalogRTForSTVStr.split(',');

           String dataCatalogRTForTIG =System.Label.dataCatalogRTforTIG;
            List<String> dataCatalogRTForTIGlst = new List<String>();
            dataCatalogRTForTIGlst=dataCatalogRTForTIG.split(',');
        String recordTypeName = Schema.SObjectType.Digital_Campaign__c.getRecordTypeInfosById().get(recordType).getName();
        DataCatalogClass dataCatalogClass = new DataCatalogClass();
        List<AuraSelectOptions> dataSelectedOptions = new List<AuraSelectOptions>();
        List<string> politicalDataCatalogs  = new List<string>();
        List<string> restrictedDataCatalogs  = new List<string>();
        List<Data_Catalog__c> dcaRecords = new List<Data_Catalog__c>();
        System.debug('recordTypeName'+recordTypeName);
        if(dataCatalogRTForSTVList.contains(recordTypeName)){
             dcaRecords =  [SELECT Id,Display_Text__c,Political__c,Restricted_Interest__c,CPM__c,Export_Key__c  FROM Data_Catalog__c WHERE isSTV__c = true AND isActive__c = true ORDER BY Display_Text__c ];
        }if(dataCatalogRTForTIGlst.contains(recordTypeName)){
             dcaRecords =  [SELECT Id,Display_Text__c,Political__c,Restricted_Interest__c,CPM__c,Export_Key__c  FROM Data_Catalog__c WHERE IsTig__c = true AND isActive__c = true ORDER BY Display_Text__c ];
        }
         if(!dataCatalogRTForSTVList.contains(recordTypeName) && !dataCatalogRTForTIGlst.contains(recordTypeName) ){
             dcaRecords =  [SELECT Id,Display_Text__c,Political__c,Restricted_Interest__c,CPM__c,Export_Key__c  FROM Data_Catalog__c WHERE isAddressableOnline__c = true AND isActive__c = true ORDER BY Display_Text__c ];
        }

        for(Data_Catalog__c dca : dcaRecords){
            dataSelectedOptions.add(new AuraSelectOptions(dca.Display_Text__c, dca.Display_Text__c));

            if(dca.Political__c){
                politicalDataCatalogs.add(dca.Display_Text__c);
            }

            if(dca.Restricted_Interest__c){
                restrictedDataCatalogs.add(dca.Display_Text__c);
            }
            
        }
        dataCatalogClass.DataCatalogRecords = dcaRecords;
        dataCatalogClass.DataCatalog = dataSelectedOptions;
        dataCatalogClass.PoliticalDCA = politicalDataCatalogs;
        dataCatalogClass.RestrictedDCA = restrictedDataCatalogs;
        dataCatalogClass.recordTypeName = recordTypeName;
        return JSON.serialize(dataCatalogClass);
    }

    @AuraEnabled (cacheable=true)
    //METHOD DESCRIPTION : Based on the Data Catalog Product Type value in Support Request(SupportRequestDataCatalog), display the Data catalog records as options
    
    public static string retrieveDisplayTextBySR(string supportReq){
        DataCatalogClass dataCatalogClass = new DataCatalogClass();
        List<AuraSelectOptions> dataSelectedOptions = new List<AuraSelectOptions>();
        List<string> politicalDataCatalogs  = new List<string>();
        List<string> restrictedDataCatalogs  = new List<string>();
        List<Data_Catalog__c> dcaRecords = new List<Data_Catalog__c>();
        if(supportReq == 'Streaming TV'){
             dcaRecords =  [SELECT Id,Display_Text__c,Political__c,Restricted_Interest__c,CPM__c  FROM Data_Catalog__c WHERE isSTV__c = true AND isActive__c = true ORDER BY Display_Text__c ];
        }
        else if(supportReq == 'Addressable Online'){
             dcaRecords =  [SELECT Id,Display_Text__c,Political__c,Restricted_Interest__c,CPM__c  FROM Data_Catalog__c WHERE isAddressableOnline__c = true AND isActive__c = true ORDER BY Display_Text__c ];
        }

        for(Data_Catalog__c dca : dcaRecords){
            dataSelectedOptions.add(new AuraSelectOptions(dca.Display_Text__c, dca.Display_Text__c));

            if(dca.Political__c){
                politicalDataCatalogs.add(dca.Display_Text__c);
            }

            if(dca.Restricted_Interest__c){
                restrictedDataCatalogs.add(dca.Display_Text__c);
            }
            
        }
        dataCatalogClass.DataCatalogRecords = dcaRecords;
        dataCatalogClass.DataCatalog = dataSelectedOptions;
        dataCatalogClass.PoliticalDCA = politicalDataCatalogs;
        dataCatalogClass.RestrictedDCA = restrictedDataCatalogs;
        return JSON.serialize(dataCatalogClass);
    }

  
    @AuraEnabled   
    public static void getDayAndTimeData(String jsonData,String recordId){ 
      
        try {
            List<Object> dlist = (List<Object>) JSON.deserializeUntyped(jsonData);
            System.debug('dlist: ' + dlist);
            System.debug('recordId'+recordId);
            System.debug('jsonData ::: ' + jsonData);
            String dayOfWeek;
        List<string> lsstr= new List<string> ();
 string allstring;



            
            List<String> my_listStr = new List<String>();
           for (Object obj : dlist) {
                System.debug('obj: ' + obj);
                Map<String,Object> data = (Map<String,Object>)obj;
                 lsstr.add(String.valueOf(obj)); 
          allstring = string.join(lsstr,',');
             
      
}
            system.debug('lsstr'+lsstr);
  system.debug('allstring'+allstring);
            string s2= jsonData.replace('{', ' ').replace('[', ' ').replace(']', ' ').replace('"', ' ');
            string dayweek= s2.replace('}', ' ');

string fieldval= dayweek.replace('(', ' ');
string DayTime= fieldval.replace(')', ' ');
 system.debug('DayTime'+DayTime);
list<Digital_Campaign__c> lstdc=new list<Digital_Campaign__c>();
list<Digital_Campaign__c> DC=[SELECT id, Day_of_Week__c FROM Digital_Campaign__c WHERE Id = :recordId];
            for(Digital_Campaign__c dcval:DC){
                if(jsonData == 'empty'){
                    dcval.Day_of_Week__c='';
                }else{
                    dcval.Day_of_Week__c=DayTime;
                }
              lstdc.add(dcval);
                
            }
update lstdc;
        } catch (Exception e) {
              
        }
    }
   
    //SRSF-4328
    @AuraEnabled
    public static void updateDataCatalogValues(string dcval,string Id){
        system.debug('dcval'+ dcval);
        List <Digital_Campaign__c> DcList = new List <Digital_Campaign__c>();
        DcList=[Select id, Data_Catalog__c,Data_Catalog_Custom_Logic__c, Data_Catalog_For_Groups__c, Selected_Data_Catalog_Id__c, Export_Key_Logic__c, Addressable_Rate_Card_CPM__c  FROM Digital_Campaign__c WHERE Id = :Id];
    
        for (Digital_Campaign__c dc : DcList) {
            dc.Data_Catalog__c = dcval;
            dc.Data_Catalog_Custom_Logic__c = dcval;
            dc.Export_Key_Logic__c = dcval;
            
        }

        update DcList;
        
    }
    
}