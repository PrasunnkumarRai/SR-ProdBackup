public with sharing class AOSHelper {

    public class AuthenticationRequest {
        public String userId;
        public String password;
        public String apiKey;
    }

    public class AuthenticationResponse {
        public String apiKey;
        public List<String> services;
        public String token;
    }

    public class AccountRequest {
        public String id;
        public String recordType; //SRSF-5062
        public String mdmId;
        public String name;
        public Boolean active;
        public String creditStatus;       
        public List<String> platform;
    //  public Decimal discountRate;
        public CustomFieldValues customFieldValues;
        public List<PSMappings> psMappings;
    }

    public class PSMappings {
        public Boolean active;
        public String extId;
        public String externalValue;
        public String extName;
    }

    public class CustomFieldValues {
        public String agencytype;   
    }

    public class AccountResponse {
        public String salesforceId;        
        public String errorType;
        public String message;
    }
   

    public class DealRequest {
        public String id;
        public String planId;
        public String platform;
        public String orderTypeId;
        public String planName;
        public String planClassId;
    //  public Boolean inCompletePlan;    
        public String startDate;
        public String endDate;       
        public String discountProfileId;
        public List<DealAccountExecutives> accountExecutives;
        public List<DealAccountDetails> advertisers;
        public List<DealAccountDetails> agencies;
        public List<DealAccountDetails> otherAccounts; //SRSF-5062
        public List<Discounts> discounts; 
        public DealCustomFieldValues customFieldValues;
    }

    public class DealAccountExecutives {
        public String userName;
        public String startDate;
        public String endDate; 
    }

    public class DealAccountDetails {
        public String id;
        public String name;
        public String startDate;
        public String endDate; 
    }    

    public class DealCustomFieldValues { 
        public List<String> onlineproducttype2;
        public String producttype;
        public String sfproposalid;
        public String sfadvancedproposalid;
        public String proposalname;        
        /*public String spectrumdivision;
        public String region;
        public String salesoffice;*/
        public String divisionpicklist;
        public String regionpicklist;
        public String salesofficepicklist;        
        public Boolean political; 
        public String pilotproposalid;
        public String pilotid;
    //  public String pilotorderstatus;
        public String pilotorderstatuspicklist;
        public String trafficordernumber;
        public String trafficcustomerid;
        public Boolean coopcheck;
        public String opportunityid;
        public String opportunityname;
        public Boolean firstlookcheck;
        public String enterpriseaccounttype;
        public String advertisername;
        public String source;
        public String samdesignation;
    //  public String samdesignation2;//TODO:deploy to prod as 'samdesignation'
        public String tierdesignation;
        public String billingcalendar;
        public String discountcode;
    }

    public class Discounts {
        public String applyOn;
        public String discountName;
        public String discountType;
        public Decimal discountValue;
        public Integer sequenceNo;
    }

    public class DealResponse {        
        public String httpStatusCode;
        public List<String> errorMsg;
        public Response response;
    }    

    public class Response {
        public String id;
        public String planId;
        public PlanStatus planStatus;
    }

    public class PlanStatus {
        public String statusName;
    }

    public class EditPlanRequest {
        public String userName;
        public String pilotOrderId;
        public String pilotOrderStatus;
        public String trafficOrderNumber;
        public String trafficCustomerId;         
        public List<Plans> plans;
    }

    public class Plans {
        public Integer planId;        
    }
    
    public class ActivateDeactivateDeal{
        public String proposalId;
        public String dealId;
        public Boolean isActive;
    }

    public class ActivateDeactivateAOSDealRequest{
        public List<ActivateDeactivateDeal> plans;
    }
    
    public static AuthenticationResponse parseAuthenticationResponse(String json) {
        return (AuthenticationResponse) System.JSON.deserialize(json, AuthenticationResponse.class);
    }

    public static DealResponse parseDealResponse(String json) {
        return (DealResponse) System.JSON.deserialize(json, DealResponse.class);
    }
   
}