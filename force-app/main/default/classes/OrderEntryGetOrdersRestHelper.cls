global class OrderEntryGetOrdersRestHelper {

    public class DigitalCampaignParams 
    {
        public List<string> prefixIds {get; set;}
        public string fields {get; set;}
    }

    global class ResponseWrapper {
        public boolean isError {get; set;}
        public string errorCode {get; set;}
        public integer statusCode {get; set;}
        public List<Digital_Campaign__c> digitalCampaigns {get; set;}
        public ResponseWrapper(){
            isError= false;
            errorCode = '';
            statusCode = 200;
            digitalCampaigns = new list<Digital_Campaign__c>();
        }
    }

    public static ResponseWrapper getDigitalCampaigns(DigitalCampaignParams params, ResponseWrapper resWrap) 
    {
        List<string> prefixIds = params.prefixIds;
        string queryString = 'SELECT ' + params.fields + ' FROM Digital_Campaign__c WHERE Ampersand_Prefix__c IN :prefixIds'; 
        System.debug(queryString);
        try {
            List<Digital_Campaign__c> digitalCampaigns = Database.Query(queryString);
            resWrap.digitalCampaigns = digitalCampaigns;
        } catch (Exception e) {
            resWrap.isError    = true;
            resWrap.errorCode  = e.getMessage();
            resWrap.statusCode = 500;
        }

        return resWrap;
    }
}