public with sharing class LeadSearchController {
    @readonly
    @remoteaction
    @AuraEnabled(cacheable= true)    
    public static List<Zipcode_Mapping__c> getDMAList(string searchedDMA)
    { 
        try 
        {
            String str='';
            List<Zipcode_Mapping__c> dmaList = new List<Zipcode_Mapping__c>() ;
            str = searchedDMA+'%';
            dmaList = [Select ID, Name,Nielsen_DMA_Name__c from Zipcode_Mapping__c where Nielsen_DMA_Name__c != null AND Nielsen_DMA_Name__c like: str];
            return dmaList;
        }
        catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
        }
        
    }
    @readonly
    @remoteaction
    @AuraEnabled(cacheable= true)                                     
    public static List<Lead> getLeadDMAList(string searchedDMA)
    { 
        try 
        {
            String str='';
            List<Lead> leadList = new List<Lead>() ;
            List<String> leadOwnerList = new List<String>();
            string leadOwner = Label.LeadSearchOwner;
            if(leadOwner.indexOf(',') > 0)
            leadOwnerList = leadOwner.split(',');
            str = searchedDMA+'%';
            leadList = [Select ID, Primary_Advertising_Region_Text__c, Company, Name, Phone,LastModifiedDate from Lead where Primary_Advertising_Region_Text__c like :str AND isConverted = false and Owner.name in :leadOwnerList Order by LastModifiedDate Desc LIMIT 50000];
            return leadList;
        }
        catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
        }
        
    }
    @AuraEnabled(cacheable= true)                                     
    public static List<Lead> getFilterList(string filterData, string selectedDMA)
    { 
        try 
        {
            String str='';
            List<Lead> leadList = new List<Lead>() ;
            List<String> leadOwnerList = new List<String>();
            string leadOwner = Label.LeadSearchOwner;
            if(leadOwner.indexOf(',') > 0)
            leadOwnerList = leadOwner.split(',');
            str = filterData+'%';
            leadList = [Select ID, Primary_Advertising_Region_Text__c, Company, Name, Phone,LastModifiedDate from Lead where (Name like :str OR Phone like :str OR Company like :str) AND isConverted = false and Owner.name in :leadOwnerList AND Primary_Advertising_Region_Text__c = :selectedDMA Order by LastModifiedDate desc];
            return leadList;
        }
        catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
        }
        
    }
	@AuraEnabled(cacheable= true)   
	public static List<Lead_Search_Tool__mdt> getMetaData(){
		return Lead_Search_Tool__mdt.getAll().values();
	}
}