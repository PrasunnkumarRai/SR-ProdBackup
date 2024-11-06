/*
###########################################################################
# File..................: ShowSeekerHelper.cls
# Version...............: 1
# Created by............: Usharani   
# Created Date..........: 09-Dec-2019
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This class contains request/reponse fields for SS WebService calls
# TAO Ref#..............: NA
# Test Class............: 
# Change Log............:               
#     Date           User       Requested By(Optional)   Description
# 09-Dec-2019     Usharani         Greg Rice             SRSF-1960 
# 10-Jun-2021     Usharani         Greg Rice             SRSF-2675 
############################################################################*/
public with sharing class ShowSeekerHelper {

    public class SSAuthenticatePayload {
        public String username;
        public String password;
    }   
   
    public class ProposalRequestPayload {
        public String aeId;
        public String aeName;       
        public String userId;
        public String userName;        
      /*public String proposalId;
        public String showSeekerId;*/
        public String proposalType;
        public Boolean isSCX;       
        public Opportunity opportunity;
        public AccountDetails advertiserAcc;
        public AccountDetails agencyAcc;
        public AccountDetails repFirmAcc;
        public OpportunityBudget opportunityBudget;
    }

    public class EditProposalPayload {
        public String userName;
        public String proposalId;        
    }

    public class ActivateInactivateProposalPayload {
        public String userName;        
        public List<Proposals> proposals;
    }

    public class Opportunity {      
        public String id;
        public String name;
        public Date presentationDate;
        public Date startDate;
        public Date endDate;
        public String stageName;
        public Decimal amount;
        public Decimal discountPercent;
        public String discountCode; // SRSF-4969
        public String rateCardName;
        public Boolean coOp;
        public String businessClassification;// SRSF-4604
        public BillingDetails billingDetails;
    }

    public class AccountDetails {
        public String id;
        public String name;
        public Decimal discountPercent;
        public String phone;
        public AccountAdress address;
    }

    public class AccountAdress {
        public String street1;
        public String street2;
        public String city;
        public String state;
        public String country;
        public String zipCode;
    }

    public class BillingDetails {
        public String billTo;
        public String numberOfCopies;
        public String invoiceDeliveryMethod;
        public String billingEmail;
        public String billingType;
        public String billingCoOp;
        public String billingPreference;
        public String sendZeroInvoices;
        public String splBillingInstructions;
        public String creditStatus;
        public String billingChangeStatus;
    }

    public class OpportunityBudget {
       public String id;
       public Date startDate;
       public Date endDate;
       public List<ProposalZones> zones;
    }

    public class ProposalZones {
       public String id;
       public String name;
       public String zoneType;
       public List<ProposalZonesMonthlyValues> zoneValues;      
    }
    
    public class ProposalZonesMonthlyValues {
      public String id;
      public String name;
      public String broadcastMonth;
      public String broadcastYear;
      public Decimal grossAmount;
      public String scheduleType;      
    }

    public class Proposals{
        public String proposalId;
        public Boolean isActive;
    }

    public class SSAuthenticateResponse {
        public String tokenId;
    }

    public class ProposalResponsePayload {
        public String proposalId;
        public String link;
        public String errorType;
        public String message;
    }

    public class ActivateInactivateProposalResponse {
        public List<ProposalResponse> proposals;
    }

    public class ProposalResponse {
        public Integer proposalId;
        public Boolean isActive;
        public Boolean isSuccess;
    }

    public class ShowSeekerErrorResponse {
        public String error;
        public String message;
    }

    public static SSAuthenticateResponse parseAuthenticate(String json) {
        return (SSAuthenticateResponse) System.JSON.deserialize(json, SSAuthenticateResponse.class);
    }

    public static ProposalResponsePayload parseProposalResponse(String json) {
        return (ProposalResponsePayload) System.JSON.deserialize(json, ProposalResponsePayload.class);
    }

    public static ActivateInactivateProposalResponse parseActivateInactivatePropRes(String json) {
        return (ActivateInactivateProposalResponse) System.JSON.deserialize(json, ActivateInactivateProposalResponse.class);
    }

    public static ShowSeekerErrorResponse parseSSErrorResponse(String json) {
        return (ShowSeekerErrorResponse) System.JSON.deserialize(json, ShowSeekerErrorResponse.class);
    }    
}