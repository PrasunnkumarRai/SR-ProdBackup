@isTest
global class OMSHttpCalloutMock implements HttpCalloutMock {

    //private string json = '{"Digital_Campagin_ID":"a0822000000wX08AAE","Digital_Campagin_Name":"DC-0000080626","Record_Type":"012220000000KDAAA2","Record_Type_Name":"New Ads Everywhere","Status":"13 Revision Submitted to Digital Ops","Advertiser":"0014100000l79AnAAI","Advertiser_Name":"Cox Toyota / H&S Marketing","Agency":"0014100000l7C9IAAU","Agency_Name":"H&S Marketing","Rep_Firm":"","Rep_Firm_Name":"","Product_Type":"Default Ads Everywhere Campaign","DC_Unique_Record_ID":"a0822000000wX08","TIM_ID":"1278824","Campaign_Name":"Cox Toyota Ads E 2019 (December) - New Ads Everywhere","Campaign_Start_Date":"9/20/2019","Campaign_End_Date":"9/28/2019","Total_Impressions":34,"Gross_CPM":0.00,"Rate_Classification":"Paid","VAST_Tag":"No","AdsE_Platforms":"VOD (Set-top Box)","AdsE_Genres":"All Networks","Kids_Network_Exclusion":true,"Tune_In_Exclusions":false,"AdsE_Network":"Spectrum SportsNet Dodgers;Spectrum SportsNet Lakers;A&E Network;Adult Swim;AMC;American Heroes Channel;Animal Planet;BBC America;BET;Bravo;CBS News;CMT;CNBC;CNN;Comedy Central;Cooking Channel;Crime & Investigation;Destination America;Discovery Channel;Discovery Life;Disney Junior;DIY;E!;ESPN;ESPN App;Food Network;Fox Business;Fox News Channel;Fox Sports;FX;FXM;FXX;FYI;Golf Channel;Hallmark;Headline News;HGTV;History;Independent Film Channel;Investigation Discovery;Lifetime;Lifetime Movies;Logo;Military History Channel;MotorTrend;MSG [NY Only];MSNBC;MTV;MTV 2;Nat Geo Wild;National Geographic Channel;NBC News;NBC Sports;NESN [New England Only];Newsy;NFL Network;Nick at Nite;Ovation;OWN;Oxygen;Pac-12;Paramount;Pop TV;Root Sports;Science Channel;SNY;Spectrum News;Sundance Channel;Syfy;TBS;TCM;The CW;TLC;TNT;Travel Channel;truTV;TV Land;USA;VH1;Viceland;WE;YES Network;Spanish Networks","DMAs":"None","SalesPerson_ID":"00541000004MoWlAAK","SalesPerson_FName":"Valerie","SalesPerson_LName":"Schultz","SalesPerson_Email":"valerie.schultz@charter.com.invalid","Sales_Office":"Greensboro 2","Last_Modified_By":"00522000001NIFjAAO","Last_Modified_By_Name":"Jose Calicdan","Spectrum_Reach_Zones":"None","Congressional_Districts":"Alabama3","State":"None"}';
	//private string json = '{"DcId":"a0822000000wX08AAE","DigitalCampaignName":"DC-0000080626","DcRecordType":"012220000000KDAAA2","RecordTypeName":"New Ads Everywhere","Status":"13 Revision Submitted to Digital Ops","SfAdvertiserId":"0014100000l79AnAAI","AdvertiserName":"Cox Toyota / H&S Marketing","SfAgencyId":"0014100000l7C9IAAU","AgencyName":"H&S Marketing","RepFirmId":"","RepFirmName":"","ProductTypes":"Default Ads Everywhere Campaign","DCUniqueRecordId":"a0822000000wX08","TIMId":"1278824","CampaignName":"Cox Toyota Ads E 2019 (December) - New Ads Everywhere","CampaignStartDate":"9/20/2019","CampaignEndDate":"9/28/2019","TotalImpressions":34,"GrossCpmDollars":0.00,"RateClassifications":"Paid","VAST_Tag":"No","AdsePlatforms":"VOD (Set-top Box)","AdseGenres":"All Networks","KidsNetworkExclusion":true,"TuneInExclusions":false,"AdseNetworks":"Spectrum SportsNet Dodgers;Spectrum SportsNet Lakers;A&E Network;Adult Swim;AMC;American Heroes Channel;Animal Planet;BBC America;BET;Bravo;CBS News;CMT;CNBC;CNN;Comedy Central;Cooking Channel;Crime & Investigation;Destination America;Discovery Channel;Discovery Life;Disney Junior;DIY;E!;ESPN;ESPN App;Food Network;Fox Business;Fox News Channel;Fox Sports;FX;FXM;FXX;FYI;Golf Channel;Hallmark;Headline News;HGTV;History;Independent Film Channel;Investigation Discovery;Lifetime;Lifetime Movies;Logo;Military History Channel;MotorTrend;MSG [NY Only];MSNBC;MTV;MTV 2;Nat Geo Wild;National Geographic Channel;NBC News;NBC Sports;NESN [New England Only];Newsy;NFL Network;Nick at Nite;Ovation;OWN;Oxygen;Pac-12;Paramount;Pop TV;Root Sports;Science Channel;SNY;Spectrum News;Sundance Channel;Syfy;TBS;TCM;The CW;TLC;TNT;Travel Channel;truTV;TV Land;USA;VH1;Viceland;WE;YES Network;Spanish Networks","DMAs":"None","SalesPersonId":"00541000004MoWlAAK","SalesPersonFName":"Valerie","SalesPersonLName":"Schultz","SalesPersonEmail":"valerie.schultz@charter.com.invalid","SalesOffice":"Greensboro 2","LastModifiedBy":"00522000001NIFjAAO","LastModifiedByName":"Jose Calicdan","SpectrumReachZones":"None","CongressionalDistricts":"Alabama3","States":"None"}';
    private string json;  
    public Digital_Campaign__c obj;
    public OMSHttpCalloutMock(Id dcId){
        obj = [SELECT id,
               Name,
               RecordTypeId, RecordType.Name,
               Status__c,
               Advertiser__c, Advertiser__r.Name,
               Agency__c, Agency__r.Name,
               Rep_Firm_Text__c, Opportunity__r.Rep_Firm__c,
               Product_Type__c,
               Digital_Campaign_ID__c,
               TIM_ID__c,
               Campaign_Name__c,
               Campaign_Start_Date__c, Campaign_End_Date__c,
               Total_Impressions__c,
               Gross_CPM1__c,
               Gross_CPM__c,
               Rate_Classification__c,
               VAST_Tag__c,
               AdsE_Platform_s__c,
               Kids_Network_Exclusion__c,
               Tune_In_Exclusions__c,
               AdsE_Network__c,
               AdsE_Genre_s__c,
               DMAs__c,
               OwnerId, Owner.LastName, Owner.FirstName, Owner.Email,
               Sales_Office__c,
               LastModifiedById, LastModifiedBy.Name,
               CustomZipCode__c, Zip_Codes__c,
               State__c,
               Spectrum_Reach_Zones__c,
               Proposal__c,
               Opportunity__r.Enterprise_Account_Type__c,
               Proposal__r.TIM_System__c,
               Proposal__r.Traffic_Order_Number__c,
               Advertiser__r.Political_Account__c,
               Is_Freewheel_FF_OTT_Primary__c,
               Streaming_TV_Old_Process__c,
               Online_Legacy_Campaign__c,
               Operative_Sales_Order_Hyperlink__c,
               Device_Exclusions__c,
               (select id,Audience__c,Campaign_Start_Date__c,Campaign_End_Date__c,COST_Gross__c,CPM_Gross__c,
                Digital_Campaign__c,Error_Message__c,Geo_Target_Type__c,Impressions__c,Industry__c,
                Inventory_Resource_Type__c,Name,Line_Item_Id__c,Notes__c,SFDC_DC_Type__c
                from Inventory_Sources__r)
               FROM Digital_Campaign__c WHERE id =: dcId];
    }
    
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        json = OMSHelper.prepareJSONDataToOMS(this.obj);
        HttpResponse response = new HttpResponse();
        String omsApiKey = System.Label.OmsApiKey;
        response.setHeader('Content-Type', 'application/json');
        request.setHeader('OmsApiKey', omsApiKey);
        response.setBody(json);
        response.setStatusCode(200);
        return response; 
    }
}