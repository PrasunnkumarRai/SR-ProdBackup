public class BoomiHelper{
    
    public class SaveEntities_4_2Response_Z {
        public SaveEntities_4_2Response SaveEntities_4_2Response;
    }

    public class Messages {
        public String message;
    }

    public class SaveEntities_4_2Result {
        public List<EntityResult> EntityResult;
    }

    public class EntityResult {
        public String ID;
        public String HasErrors;
        public Messages Messages;
        public String EntityType;
    }

    public class SaveEntities_4_2Response {
        public SaveEntities_4_2Result SaveEntities_4_2Result;
    }
    
    public static SaveEntities_4_2Response_Z parse(String json) {
        return (SaveEntities_4_2Response_Z) System.JSON.deserialize(json, SaveEntities_4_2Response_Z.class);
    }
        
    public class SAuthenticate_element {
        public Integer UserID;
        public String UserPassword;
        public Integer AppID;        
    }
    
    public class Authenticate {
        public SAuthenticateResponse SAuthenticateResponse;
    }

    public class SAuthenticateResponse {
        public String SAuthenticateResult;
    }
    
    public static Authenticate parseAuthenticate(String json) {
        System.debug('@@json '+json);
        return (Authenticate) System.JSON.deserialize(json, Authenticate.class);
    }
    
    public class BoomiAccounts {
        public String SessionID;
        public SaveEntities_4_2 SaveEntities_4_2;
    }
    
    public class SaveEntities_4_2 {
        public BoomiHelper.Entities Entities;        
    }
    
    public class Entities {
        
        public BoomiHelper.ArrayOfAgency_4_2 AgencyList_4_2;
        public BoomiHelper.ArrayOfAdvertiser_4_2 AdvertiserList_4_2;
    }
    
    public class ArrayOfAdvertiser_4_2 {
        public BoomiHelper.Advertiser_4_2[] Advertiser_4_2;    
    }
    
    public class Advertiser_4_2 {
        public String MachsID;
        public String CrmID;
        public Integer AdvertiserID;
        public String AdvertiserName;
        public Integer AgencyID;
        public Integer ProductID;
        public String Address1;
        public String Address2;
        public String City;
        public String State;
        public String ZIP;
        public Decimal Discount;
        public String Contact;
        public String Phone;
        public Integer IndustryCodeID;
        public Integer CommodityID;
        public Boolean IsActive;
        public BoomiHelper.ArrayOfTrafficIDElement TrafficIDs;    
    }

    public class ArrayOfAgency_4_2 {
        public BoomiHelper.Agency_4_2[] Agency_4_2;        
    }

    public class Agency_4_2 {
        public String MachsID;
        public String CrmID;
        public Integer AgencyID;
        public String AgencyName;
        public String Address1;
        public String Address2;
        public String City;
        public String State;
        public String ZIP;
        public String Contact;
        public String Phone;
        public Decimal Discount;
        public String DDSAgencyCode;
        public String DDSAdjacencyCode;
        public Boolean IsActive;
        public BoomiHelper.ArrayOfTrafficIDElement TrafficIDs;        
    }
    
    public class TrafficIDElement {
        public Integer ExportSystemID;
        public String TrafficID;        
    }
    
    public class ArrayOfTrafficIDElement {
        public BoomiHelper.TrafficIDElement[] TrafficIDElement;        
    }
    
    public class UndeleteOrderElement{
        public String User;
        public String EstimateID;
        public String UserID;
    }
    
    public class UndeleteOrderRequest {
        public UndeleteOrderElement UndeleteOrder;      
    }
    
    public class DeleteOrderElement{
        public String User;
        public String EstimateID;
        public String UserID;
    }
    
    public class DeleteOrderRequest {
        public DeleteOrderElement DeleteOrder;      
    }
    
    public class importSCXChanges
    {
        public String SessionKey;
        public String FileContent;
        public String AEId;
        public String AgencyID;
        public String AdvertiserID;
        public String rateCardName;
    }
    
    public class saveAdvertiserPayload
    {
        public String User;
        public saveAdvertiser_4_2 advertiser;
    }
    public class saveAdvertiser_4_2 {
        public Integer AdvertiserID;
        public String AdvertiserName;
        public Integer AgencyID;
        public Integer ProductID;
        public String Address1;
        public String Address2;
        public String City;
        public String State;
        public String ZIP;
        public Decimal Discount;
        public String Contact;
        public String Phone;
        public Integer Commodity;
        public Boolean IsActive;
        public BoomiHelper.ArrayOfTrafficIDElement TrafficIDs;    
    }   

    public class saveAgencyPayload
    {
        public String SessionKey;
        public Agency_4_2 Agency;
    }
    public class saveAdvertiserMaster
    {
        public saveAdvertiserPayload SaveAdvertiser_3_2;
    }
    
    public class ProposalApprovalUpdatesRequest{        
        public ProposalApprovalUpdates ProposalApprovalUpdates;        
    }
    
    public class ProposalApprovalUpdates{       
        public List<ProposalApprovalPayload> ProposalApprovalUpdate;        
    }
    
    public class ProposalApprovalPayload{       
        public String UserID;
        public String SURVEY_ID;
        public String SysCode;
        public String FromStatusID;
        public String StatusID;
        public String ScheduleStatusUpdated;
        public String Note;
        public String ESTIMATE_ID;
    }    
    
    public class ProposalApprovalResponse {
        public ProposalApprovalResult ProposalApprovalUpdates;
    }

    public class ProposalApprovalUpdate {
        public Integer UserID;
        public Integer SURVEY_ID;
        public Integer SysCode;
        public Integer FromStatusID;
        public String ScheduleStatusUpdated;
        public String Note;
        public String ESTIMATE_ID;
        public Integer UpdateNumber;
        public String ResultStatus;
        public String Message;
        public Integer StatusID;
    }

    public class ProposalApprovalResult {
        public List<ProposalApprovalUpdate> ProposalApprovalUpdate;
    }

    
    public static ProposalApprovalResponse parseProposalResponse(String json) {
        return (ProposalApprovalResponse) System.JSON.deserialize(json, ProposalApprovalResponse.class);
    }
 
    public class BroadcastValues {
        public List<BroadcastValue> BroadcastValue;
    }

    public class ScheduleItem_4_6 {
        public String SysCodes;
        public String Zones;
        public String Markets;
        public BroadcastValues BroadcastValues;
        public String OrderStatus;
        public String ScheduleType;
    }

    public class ScheduleItems {
        public List<ScheduleItem_4_6> ScheduleItem_4_6;
    }

    public class BroadcastValue {
        public String YearMonth;
        public Integer TotalSpots;
        public Integer TotalCost;
    }

    public class SurveyVersion {
        public Integer SurveyID;
        public Integer VersionNumber;
    }

    public class GetEstimateHeaders_Result {
        public List<EstimateHeader> EstimateHeader;
    }

    public class SurveyVersions {
        public List<SurveyVersion> SurveyVersion;
    }

    public class RevenueType {
        public String ID;
        public String Description;
        public String isActive;
    }

    public class EstimateHeader {
        public Integer EstimateID;
        public String Description;
        public Integer AdvertiserID;
        public Integer AgencyID;
        public Integer ProductID;
        public String FlightStart;
        public String FlightEnd;
        public Integer Weeks;
        public Integer AEID;
        public String CreatedBy;
        public String EdiInvoice;
        public String ExternalOrderNo;
        public BroadcastValues BroadcastValues;
        public String Networks;
        public Integer NetworkCount;
        public String TrafficOrderNumber;
        public String IsDeleted;
        public SurveyVersions SurveyVersions;
        public ScheduleItems ScheduleItems;
        public RevenueType RevenueType;
        public String Status;
        public String Comments;
    }
    
    public class BoomiHelper1 {
        public GetEstimateHeaders_Result GetEstimateHeaders_Result;
    }
    
    public static BoomiHelper1 parseBoomiHelper1(String json) {
        return (BoomiHelper1) System.JSON.deserialize(json, BoomiHelper1.class);
    }
        
    public class EditEstimateHeaderRequest_Z {
        public EditEstimateHeaderRequest EditEstimateHeaderRequest;
    }

    public class EditEstimateHeaderRequest {
        public EditEstimateHeaderList EditEstimateHeaderList;
    }

    public class EditEstimateHeader_5_0 {
        public String EstimateID;
        public String AdvertiserID;
        public String AEID;
        public String AgencyID;
    }

    public class EditEstimateHeaderList {
        public List<EditEstimateHeader_5_0> EditEstimateHeader_5_0;
    }

    
    public static EditEstimateHeaderRequest_Z parseEditEstimateHeader(String json) {
        return (EditEstimateHeaderRequest_Z) System.JSON.deserialize(json, EditEstimateHeaderRequest_Z.class);
    }

    //code Added by Abhilash : 04-04-2018

    public static BoomiHelperCls parseEstimateHdrLsttJson(String json){
        return (BoomiHelperCls) System.JSON.deserialize(json, BoomiHelperCls.class);
    }

    public class BoomiHelperCls{
        public cls_EditHdrResponseList EditHdrResponseList;
        public cls_Response Response;
    }

    public class cls_EditHdrResponseList {
        public List<cls_EditEstimateHeader_5_0Response> EditEstimateHeader_5_0Response;
    }
    
    public class cls_EditEstimateHeader_5_0Response {
        public Integer EstimateID;
        public String AdvertiserID;
        public String AEID;
        public String success;  //false
        public cls_errors errors;
    }
    
    public class cls_errors {
        public List<cls_Error> error;
    }
    
    public class cls_Error {
        public String code; //soap:Server
        public String message;  //Server was unable to process request. ---> Error CL2: Invalid user/password
    }

    public class cls_Response {
        public String success;  //false
        public List<cls_ResponseError> error;
        public cls_metadata metadata;
        public cls_ReqParams requestParams; //SRSF-1252
    }

    public class cls_ResponseError {
        public String message;  //Failed to Authenticate. Please check credentials.
        public String cause;    // UserId is required
    }

    public class cls_metadata {
        public String executionId;  //execution-5b560bb0-9ecc-4434-a0b4-e34aacb517f8-2017.12.15
        public String processName;  //Authentication Provider (Continuation f_0)
        public String dt; //20171215 070916.461
        public String Systm;   //St. Louis Local
    }

    //SRSF-1252
    public class cls_ReqParams{
        public String ip1; // sessionid Like ebmlgjjqrx12wqke3ybkhr4z
        public String ip2; // EstimateID like 320578
        public String ip3; // UserID like 2
    }
    //code changes ends here
    
    // Code Changes for SRSF – 1160 – Code Starts
    public class TransferOwnership{
        public cls_TransferOwnershipReq TransferOwnership;
    }

    public class cls_TransferOwnershipReq {
        public String EstimateId;   //5
        public String UserId;   //5
        public String UserName; //5
    }

    public class TransferOwnershipResponse{
        public cls_Response Response;
    }

    public static TransferOwnershipResponse parseTransferOwnership(String json){
        return (TransferOwnershipResponse) System.JSON.deserialize(json, TransferOwnershipResponse.class);
    }
    // Code Changes for SRSF – 1160 – Code Ends
}