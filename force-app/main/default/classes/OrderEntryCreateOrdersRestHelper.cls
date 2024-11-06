global with sharing class OrderEntryCreateOrdersRestHelper {

    public class SFSendProposalOrders
    {
        public List<SFOrderModel> proposalOrders { get; set; }
    }

    public class ProposalInfo
    {
        public string id {get; set;}
        public string name {get; set;}
    }

    public class SFOrderModel
    {
        public string campaignName { get; set; }
        public string salesforceId { get; set; }
        public string market { get; set; }
        public string proposalId { get; set; }
        public string publisher { get; set; }
        public string prefixId { get; set; }
        public string placementName { get; set; }
        public string targeting { get; set; }
        public string startdate { get; set; }
        public string enddate { get; set; }
        public Decimal impressionUnits { get; set; }
        public Decimal grossCPM { get; set; }
        public Decimal grossInvestment { get; set; }
        public Decimal netCPM { get; set; }
        public Decimal netInvestment { get; set; }
        public string networks { get; set; }
        public string excludedNetworks { get; set; }
        public string platforms {get; set;}
        public boolean vastTag { get; set; }
        public boolean preemptable { get; set; }
        public string frequencyCap { get; set; }
        public string states { get; set; }
        public string dma { get; set; }
        public string zones { get; set; }
        public string congressionalDistricts { get; set; }
        public string zipCodes { get; set; }
        public Boolean customZipCode { get; set; }
        public Boolean kidsNetworkExclusion { get; set; }
        public Boolean tuneInExclusion { get; set; }
        public Boolean newsExclusion { get; set; }
        public Boolean yieldExcludeOverride {get; set;}
        public string genres { get; set; }
        public string productType { get; set; }
        public string notes { get; set; }
        public string flightDates { get; set; }
        public string hpo { get; set; }
        public Boolean liveInTelecast { get; set; }
        public Boolean retargeting { get; set; }
        public Boolean hpoCustomNetAudience { get; set; }
        public Boolean iso { get; set; }
        public string advancedCustomization { get; set; }
        public string deviceExclusions { get; set; }
        public string dataCatalog { get; set; }
        public string dataCatalogExportKeyLogic { get; set; }
        public string dataCatalogCustomLogic { get; set; }
        public string audienceProfile { get; set; }
        public string timeZones { get; set; }
    }

    public class CampaignInfo
    {
        public string Id {get; set;}
        public string prefixId {get; set;}
    }
    global class ResponseWrapperCreateOrders
    {
        public boolean isError {get; set;}
        public string errorCode {get; set;}
        public Integer statusCode {get; set;}
        public list<CampaignInfo> campaignInfo {get; set;}
        public List<ProposalInfo> proposalInfo {get; set;}
        public ResponseWrapperCreateOrders(){
            isError= false;
            errorCode = '';
            statusCode = 200;
        }
    }


    public static boolean ThrowDigitalCampaignException = false;
    public static string testException                  = 'My DML EXCEPTION';
    public static string dcRecordTypeName               = 'Inventory_Request_New_Ads_Everywhere';
    public static string digitalCampaignStatusDefault   = 'Draft Plan';
    public static string digitalCampaignPlatformDefault = 'All Platforms';

    public static Id dcRecordTypeId = Schema.SObjectType.Digital_Campaign__c
        .getRecordTypeInfosByDeveloperName()
        .get(dcRecordTypeName).getRecordTypeId();

    public static ResponseWrapperCreateOrders createDigitalCampaigns(ResponseWrapperCreateOrders resWrap, SFSendProposalOrders params) {
        
        List<Digital_Campaign__c> dcList        = new List<Digital_Campaign__c>();
        List<Id> proposalIds                    = new List<Id>();
        Map<Id, Proposal__c> proposalMap        = new Map<Id, Proposal__c>();
        List<ProposalInfo> proposalInfoList     = new List<ProposalInfo>();
        List<CampaignInfo> campaignInfoList     = new List<CampaignInfo>();
        ProposalInfo proposalInfo               = null;
        CampaignInfo campaignInfo               = null;


        for(SFOrderModel proposalOrder : params.proposalOrders)
        {
            proposalIds.add(proposalOrder.proposalId);
        }

        for(Proposal__c proposal : [
            Select
                Id, 
                Name, 
                Opportunity__r.Id, 
                Opportunity__r.AccountId 
            FROM Proposal__c 
            WHERE Id In : proposalIds
        ])
        {
            proposalMap.put(proposal.Id, proposal);

            proposalInfo      = new ProposalInfo();
            proposalInfo.id   = proposal.Id;
            proposalInfo.name = proposal.Name;

            proposalInfoList.add(proposalInfo);
        }

        for(SFOrderModel order : params.proposalOrders)
        {
            Proposal__c currentProposal = proposalMap.get(order.proposalId); 

            Digital_Campaign__c currentDC = new Digital_Campaign__c(
                Proposal__c                   = order.proposalId,
                Opportunity__c                = currentProposal.Opportunity__r.Id,
                recordTypeId                  = dcRecordTypeId,
                Advertiser__c                 = currentProposal.Opportunity__r.AccountId,
                Campaign_Name__c              = order.campaignName,
                Campaign_Start_Date__c        = Date.valueOf(order.startdate),
                Campaign_End_Date__c          = Date.valueOf(order.enddate),
                Total_Impressions__c          = order.impressionUnits,
                Gross_CPM__c                  = order.grossCPM,
                Gross_Campaign_Cost__c        = order.grossInvestment,
                Desired_Budget__c             = order.grossInvestment,
                Status__c                     = digitalCampaignStatusDefault,
                Ampersand_Prefix__c           = order.prefixId,
                AdsE_Network__c               = order.networks,
                Exclude_Networks__c           = order.excludedNetworks,
                State__c                      = order.states,
                DMAs__c                       = order.dma,
                Spectrum_Reach_Zones__c       = order.zones,
                News_Network_Exclusions__c    = order.newsExclusion,
                Congressional_Districts__c    = order.congressionalDistricts,
                Zip_Codes__c                  = order.zipCodes,
                AdsE_Genre_s__c               = order.genres,
                Tune_In_Exclusions__c         = order.tuneInExclusion,
                Kids_Network_Exclusion__c     = order.kidsNetworkExclusion,
                CustomZipCode__c              = order.customZipCode,
                Yield_Exclude_override__c     = order.yieldExcludeOverride,
                Campaign_Notes__c             = order.notes,
                Flight_Dates_Backend__c       = order.flightDates,
                HPO__c                        = order.hpo,
                HPO_Custom_Net_Audience__c    = order.hpoCustomNetAudience,
                Live_In_Telecast__c           = order.liveInTelecast,
                Retargeting__c                = order.retargeting,
                Advanced_Customizations__c    = order.advancedCustomization,
                Device_Exclusions__c          = order.deviceExclusions,
                Data_Catalog__c               = order.dataCatalog,
                Export_Key_Logic__c           = order.dataCatalogExportKeyLogic,
                Data_Catalog_Custom_Logic__c  = order.dataCatalogCustomLogic,
                Audience_Profile__c           = order.audienceProfile
            ); 

            if(order.frequencyCap != null)
                currentDC.Frequency_Cap__c = order.frequencyCap;
            if(order.platforms != null)
                currentDC.AdsE_Platform_s__c = order.platforms;
            else
                currentDC.AdsE_Platform_s__c = digitalCampaignPlatformDefault;
            if(order.vastTag != null)
                currentDC.VAST_Tag__c = order.vastTag ? 'Yes' : 'No';
            if(order.preemptable != null)
                currentDC.Preemptable__c = order.preemptable;
            if(order.salesforceId != null)
                currentDC.Id = order.salesforceId; 
            if(order.productType != null)
                currentDC.Product_Type__c = order.productType;
            if(order.iso != null) 
                currentDC.ISO_Ignore_Restrictions__c = order.iso;
            if(order.timeZones != null)
                currentDC.Time_Zones__c = order.timeZones;
            
            dcList.add(currentDC);
        }

        try {
            if(Test.isRunningTest()){
                if(ThrowDigitalCampaignException){
                    throw new DMLException(testException);
                }
            }
            Database.upsertResult[] orderSRList = Database.Upsert(dcList, true);
            
            for(Digital_Campaign__c dc : dcList) {
                campaignInfo          = new CampaignInfo();
                campaignInfo.Id       = dc.Id;
                campaignInfo.prefixId = dc.Ampersand_Prefix__c;
                campaignInfoList.add(campaignInfo);
            }
            resWrap.campaignInfo = campaignInfoList;
            resWrap.proposalInfo = proposalInfoList; 
        } catch (Exception e) {
            resWrap.isError    = true;
            resWrap.errorCode  = e.getMessage();
            resWrap.statusCode = 500;
        }

        return resWrap;
    }
}