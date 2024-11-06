global with sharing class OrderEntryCreateInventoryItemsRestHelper {

    public class SFInventoryItemRequestModel
    {
        public List<OrderInventoryItemModel> orderInventoryItems { get; set;}
    }

    public class OrderInventoryItemModel 
    {
        public string orderId { get; set;}
        public List<SFInventoryModel> inventoryItems { get; set; }
    }

    public class SFInventoryModel
    {
       
        public string salesforceId { get; set; }
        public string startDate { get; set; }
        public string endDate { get; set; }
        public Decimal grossCPM { get; set; }
        public Decimal grossCost { get; set; } 
        public Decimal impressions { get; set; } 
        public string exclusions { get; set; } 
        public string inventoryResourceType { get; set; } 
        public string orderId { get;set; }

    }

    public class InvenotryItemResponseInfo
    {
        public string Id { get; set; }
        public string orderSFId { get; set; }
        public string resourceType {get;set;}
    }

    global class ResponseWrapperCreateInventoryItems
    {
        public boolean isError {get; set;}
        public string errorCode {get; set;} 
        public Integer statusCode {get; set;}
        public list<InvenotryItemResponseInfo> inventoryItemInfo {get; set;}
        public ResponseWrapperCreateInventoryItems(){
            isError= false;
            errorCode = '';
            statusCode = 200;
        }
    }


    public static boolean ThrowInventoryItemException   = false;
    public static string testException                  = 'My DML EXCEPTION';

    public static ResponseWrapperCreateInventoryItems createInventoryItems(ResponseWrapperCreateInventoryItems resWrap, SFInventoryItemRequestModel params) {
        
        List<Inventory_Source__c> inventoryItemList                 = new List<Inventory_Source__c>();
        List<InvenotryItemResponseInfo> invItemResponseInfoList     = new List<InvenotryItemResponseInfo>();
        InvenotryItemResponseInfo inventoryItemInfo                 = null;
        List<Digital_Campaign__c> dcList                            = new List<Digital_Campaign__c>();

        for(OrderInventoryItemModel currOrderInventoryItem : params.orderInventoryItems)
        {
            Decimal totalCost = 0;
            
            for(SFInventoryModel currInventoryModel : currOrderInventoryItem.inventoryItems)
            {
                
                Inventory_Source__c currSource = new Inventory_Source__c (
                    Campaign_End_Date__c       = Date.valueOf(currInventoryModel.endDate),
                    Campaign_Start_Date__c     = Date.valueOf(currInventoryModel.startDate),
                    COST_Gross__c              = currInventoryModel.grossCost,
                    CPM_Gross__c               = currInventoryModel.grossCPM,
                    Exclusions__c              = currInventoryModel.exclusions,
                    Impressions__c             = currInventoryModel.impressions,
                    Inventory_Resource_Type__c = currInventoryModel.inventoryResourceType,
                    Digital_Campaign__c        = currInventoryModel.orderId
                    
                );

                if(currInventoryModel.grossCost != null)
                    totalCost += currInventoryModel.grossCost;

                if(currInventoryModel.salesforceId != null)
                    currSource.Id = currInventoryModel.salesforceId;
                inventoryItemList.add(currSource);
            }  
            
            Digital_Campaign__c dcToUpdate = new Digital_Campaign__c(
                Id = currOrderInventoryItem.orderId
            );

            if(totalCost != 0)
                dcToUpdate.Gross_Campaign_Cost__c = totalCost;


            dcList.add(dcToUpdate);
        }
      
        try {
            if(Test.isRunningTest()){
                if(ThrowInventoryItemException){
                    throw new DMLException(testException);
                }
            }

            Database.upsertResult[] invItemSRList = Database.Upsert(inventoryItemList, true);
            Database.upsertResult[] dcSRList = Database.Upsert(dcList, true);
            
            for(Inventory_Source__c currItem : inventoryItemList) {
                inventoryItemInfo                              = new InvenotryItemResponseInfo();
                inventoryItemInfo.Id                           = currItem.Id;
                inventoryItemInfo.orderSFId                    = currItem.Digital_Campaign__c;
                inventoryItemInfo.resourceType                 = currItem.Inventory_Resource_Type__c;
                invItemResponseInfoList.add(inventoryItemInfo);
            }
            resWrap.inventoryItemInfo = invItemResponseInfoList;
        } catch (Exception e) {
            resWrap.isError    = true;
            resWrap.errorCode  = e.getMessage();
            resWrap.statusCode = 500;
        }

        return resWrap;
    }
}