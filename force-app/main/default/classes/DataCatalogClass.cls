public with sharing class DataCatalogClass {
    public List<AuraSelectOptions> DataCatalog {get; set;}
    public List<Data_Catalog__c> DataCatalogRecords {get; set;}
    public List<string> PoliticalDCA {get; set;}
    public List<string> RestrictedDCA {get; set;}
    public String recordTypeName {get; set;}
}