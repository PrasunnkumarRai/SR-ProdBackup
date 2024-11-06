public class OMS_ResponseClass {
    public string SalesOrderId {get; set;}
    public string Message {get; set;}
    //Added for StreamingTV
    public string SalesOrderUrl;
    public string ExceptionMessage;
    public Inventory_ResponseClass[] InventorySources;
    
    public class Inventory_ResponseClass {
        public string SourceName;
        public string LineItemIds;
    }
}