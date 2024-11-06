/*
###########################################################################
# File..................: ShowSeekerWebServiceHelper.cls
# Version...............: 1
# Created by............: Usharani   
# Created Date..........: 09-Dec-2019
# Last Modified by......: 
# Last Modified Date....: 
# Description...........: This class contains helper methods for WebService calls
# TAO Ref#..............: NA
# Test Class............: 
# Change Log............:               
#     Date           User       Requested By(Optional)   Description
# 09-Dec-2019     Usharani         Greg Rice             SRSF-1960 
# 10-Jun-2021     Usharani         Greg Rice             SRSF-2675 
#
############################################################################*/
public without sharing class ShowSeekerWebServiceHelper 
{  
  public Proposal__c proposal{get; set;}
  public Boolean isFrmSCXUpload{get; set;}
  public Boolean hasError{get; set;}
  public String responseMsg{get; set;}
  private Map<String,String> accResponseMap = new Map<String,String>();   
  public List<Opportunity> lstOpportunity;

  //Default Constructor
  public ShowSeekerWebServiceHelper() 
  {     
    isFrmSCXUpload = hasError = false;
    responseMsg = '';
    lstOpportunity = new List<Opportunity>();   
  }

  /**
  * @param endpoint
  * @param body
  * @return
  */
  public HttpResponse RestServicePostStub(String endpoint, String body, String tokenId)
  {
    System.debug('@@endpoint-->'+endpoint + '$$$ tokenId '+tokenId);
    System.debug('@@body--->'+body);

    Http h = new Http();
    HttpRequest req = new HttpRequest();
    HttpResponse res = new HttpResponse();
      
    req.setEndpoint('callout:ShowSeeker'+endpoint);     
    req.setMethod('POST');
    req.setHeader('Accept','application/json');
    req.setHeader('Content-Type','application/json; charset=UTF-8');
    req.setHeader('Accept-Language', 'en-CA');
    if(tokenId != NULL){
       req.setHeader('tokenId',tokenId);
    }  
    if(String.isNotBlank(Label.SetTimeOut)) {
       req.setTimeout(Integer.valueOf(Label.SetTimeOut));
    }
   
    req.setBody(body);
    System.debug('RestServicePostStub body---->'+body);

    try { 
        res = h.send(req);
        System.debug('@@response '+res); 
    } 
    catch(System.CalloutException ex) { 
      hasError=true;
      responseMsg = System.label.ShowSeekerAPIError;
      System.debug('Callout error: '+ ex);
      Log4SF.logMessage('ShowSeekerWebServiceHelper', 'RestServicePostStub method :'+ endpoint,responseMsg, ex, UserInfo.getUserId(),null,null);
      throw ex;
    }
  
    return res;
  }

  public String authenticate()
  {
    String sessionId;
    ShowSeekerHelper.SSAuthenticatePayload request = new ShowSeekerHelper.SSAuthenticatePayload();
    request.username = '{!$Credential.Username}';
    request.password = '{!$Credential.Password}';
    System.debug('@@ Authenticatiton req--->'+request);
    try
    {
      HttpResponse result = RestServicePostStub('/auth', JSON.serialize(request), NULL);
     
      if(result!=NULL && result.getStatus().equalsIgnoreCase('OK') && result.getStatusCode() == 200)
      {   
          System.debug('### result.getBody() ::: ' +result.getBody());  
          String responseBody = result.getBody();
          
          ShowSeekerHelper.SSAuthenticateResponse response = ShowSeekerHelper.parseAuthenticate(responseBody); 
          sessionId = response.tokenId;
          
          System.debug('@@sessionid---> '+sessionId);
      }
      else{
        hasError = true;
        ShowSeekerHelper.ShowSeekerErrorResponse errRepsonse = getErrorMessage(result);
        responseMsg = 'Authentication failed with : '+result.getStatusCode()+ ' : '+ result.getStatus() ;
        if(!CommonUtilities.isStringNullOrEmpty(errRepsonse.message))
          responseMsg += ' Due to :'+ errRepsonse.message;
          Log4SF.logMessage('ShowSeekerWebServiceHelper','authenticate', responseMsg,
                          UserInfo.getUserId(),NULL);
      }
    }
    catch(Exception ex){ 
      hasError = true;
      responseMsg = 'ShowSeeker Authentication failed due to : '+ex.getMessage();
      System.debug('authenticate Exception: ' + ex.getMessage() + ' ::: Line Number ::: ' +ex.getLineNumber());
      Log4SF.logMessage('ShowSeekerWebServiceHelper', 'authenticate', responseMsg, ex, UserInfo.getUserId(),NULL);                                   
      throw ex;
    }
    return sessionId;
  }

  /**
   * This method is used for creating proposals in Showseeker system
   * @param opp
   * @param recType
   * @return hashurl in success scenario
   */
  public String CreateProposal(String opportunityId, String recType)
  { 
    Map<Id,Account> acctMap;
    String tokenId;

    System.debug('CreateProposal method ::: Opportunity Id= '+opportunityId);
    System.debug('Is SCXupload  = '+isFrmSCXUpload);      
    System.debug('Record type ='+recType);
 
    // Get all details of Opportunity
    lstOpportunity = [SELECT Id, Name, OwnerId, Owner.UserName, Owner.Email, 
                      CloseDate, Flight_Start_Date__c, Flight_End_Date__c,
                      StageName, Amount, Agency_Account__c, Rep_Firm__c, 
                      AccountId, Discount_Percentage__c, Discount_Code__c, Bill_To_MS__c, Number_of_copies__c,
                      Invoice_Delivery_Method__c, Billing_Email__c, Billing_Type__c, Billing_Co_op__c,
                      Billing_Preference__c, Send_Zero_Invoices__c, Special_Billing_Instructions__c, Credit_Status__c, Billing_Change_Status__c, CoOp__c,Business_Classification__c, (SELECT Id, Start_Date__c, End_Date__c FROM Proposals__r WHERE RecordTypeId =: Label.Opportunity_Budget_RecordTypeId) FROM Opportunity WHERE Id=:opportunityId]; //SRSF-4604: Added Business_Classification__c

    System.debug('lstOpportunity >>>>>>>  '+lstOpportunity);
    // Get all Accounts associated to the Opportunity
    if(lstOpportunity.size() > 0) 
    {
      acctMap = getAllOppAccounts(lstOpportunity[0]);
      if(acctMap != NULL && acctMap.size() > 0)
      {
        //Check for opportunity accounts recordtypes
        responseMsg = verifyAccountRecordType(lstOpportunity[0],acctMap);
        if (responseMsg.startsWith('Error')){
            hasError = true;
        }
      }
      else{
        hasError = true;
        responseMsg = System.Label.No_Accounts_on_Opportunity;
      }
      System.debug('CreateProposal:verifyAccountRecordType Successfull!!!');
    }
    else {
      hasError = true;
      responseMsg = 'Opportunity '+System.Label.Record_not_found;
    } 

    if(!hasError) 
    {
      String rateCard = '';
      ShowSeekerHelper.ProposalRequestPayload propReq = mapProposalRequest(lstOpportunity[0], acctMap, rateCard);
      /*propReq.proposalId = null;  
      propReq.showSeekerId = null;*/
      propReq.proposalType = mapRecordType(recType); 
      // If Proposal creation through SCX upload, set isSCX as true
      propReq.isSCX = isFrmSCXUpload ? TRUE : FALSE;
      
      //Authenticate with ShowSeeker   
      try 
      { 
        tokenId = authenticate(); 
        if(tokenId != NULL && String.isNotBlank(tokenId) && !hasError) 
        { 
          System.debug('Create Proposal Payload ---->'+JSON.serialize(propReq));          
          
          HttpResponse result  = RestServicePostStub('/crm/startproposal', JSON.serialize(propReq),tokenId); 
                
          if(result!=NULL && result.getStatus().equalsIgnoreCase('OK') && result.getStatusCode() == 200)
          {   
              System.debug('### result.getBody() ::: ' +result.getBody());        
              String responseBody = result.getBody();  
              ShowSeekerHelper.ProposalResponsePayload response = ShowSeekerHelper.parseProposalResponse(responseBody); 
              responseMsg = response.link;              
              System.debug('ProposalResponsePayload --->' +response);
              System.debug('HASH URL --->' +responseMsg);
          }
          else{
            hasError = true;
            ShowSeekerHelper.ShowSeekerErrorResponse errRepsonse = getErrorMessage(result);
            responseMsg = 'Error while sending request to ShowSeeker : '+result.getStatusCode()+ ' : '+ result.getStatus() ;
            if(!CommonUtilities.isStringNullOrEmpty(errRepsonse.message))
              responseMsg += ' Due to :'+ errRepsonse.message;
              Log4SF.logMessage('ShowSeekerWebServiceHelper','CreateProposal', responseMsg,
                              UserInfo.getUserId(),opportunityId);
          }
        }
        else{
           responseMsg =System.Label.Invalid_SessionID;
        }
      }
      catch(CalloutException ex) {
          responseMsg = System.label.ShowSeekerAPIError;
          System.debug('Callout error: '+ ex);
          Log4SF.logMessage('ShowSeekerWebServiceHelper', 'RestServicePostStub'+ '/crm/startproposal',responseMsg, ex, UserInfo.getUserId(),opportunityId);
      }
      catch(Exception ex) {
          responseMsg = 'Exception occured during Create/Edit proposal : '+ex.getMessage();
          System.debug('UpsertProposal Exception: ' + ex.getMessage() + ' ::: Line Number ::: ' +ex.getLineNumber());
          Log4SF.logMessage('ShowSeekerWebServiceHelper', 'UpsertProposal', responseMsg, ex, UserInfo.getUserId(),opportunityId); 
      }
    }                 
      
    return responseMsg; 
  } 

  /**
   * Mapping all the opportunity accounts (advertiser,agency & repfirm) to showseeker request
   * @param acc
   * @return
   */
  private ShowSeekerHelper.ProposalRequestPayload mapProposalRequest(Opportunity opp, Map<Id,Account> acctMap, String rateCard)
  {  
    ShowSeekerHelper.ProposalRequestPayload propReq = new  ShowSeekerHelper.ProposalRequestPayload();
    ShowSeekerHelper.AccountDetails advertiserAcct, agencyAcct, repFirmAcct;     
    // Map account values to proposal request
    if(String.isNotBlank(opp.AccountId) && acctMap.get(opp.AccountId) != null) {
      advertiserAcct = mapAccountDetails(acctMap.get(opp.AccountId));
    }
    if(String.isNotBlank(opp.Agency_Account__c) && acctMap.get(opp.Agency_Account__c) != null) {
      agencyAcct = mapAccountDetails(acctMap.get(opp.Agency_Account__c));
    }
    if(String.isNotBlank(opp.Rep_Firm__c) && acctMap.get(opp.Rep_Firm__c) != null) {
      repFirmAcct = mapAccountDetails(acctMap.get(opp.Rep_Firm__c));
    }  
    // build request for Create Proposal 
    propReq.aeId = opp.OwnerId; 
    propReq.aeName = opp.Owner.UserName;     
    propReq.userId = UserInfo.getUserId();
    propReq.userName = UserInfo.getUserName();    
    propReq.advertiserAcc = advertiserAcct;  
    propReq.agencyAcc = agencyAcct;  
    propReq.repFirmAcc = repFirmAcct;  
    propReq.opportunity = mapOpportunityDetails(opp, rateCard);

    //Check Opportunity budget proposal exist for Opportunity, If exist send PZ, PZMV and proposal budget details in the payload
    System.debug('### OpportunityBudget ::: ' +opp.Proposals__r);
    if(opp.Proposals__r != null && opp.Proposals__r.size()>0){
      propReq.opportunityBudget = mapOpportunityBudgetData(opp.Proposals__r[0]);
    } 
    else propReq.opportunityBudget = null;

    return propReq;    
  } 

  /**
   * This method is used for verifying account record type for all the accounts exist on opportunity record
   * @param opp
   * @return Map<Id,Account> 
   */
  private Map<Id,Account> getAllOppAccounts(Opportunity opp)
  {
    Set<Id> accIds = new Set<Id>();
    Map<Id,Account> accountsMap; 

    if(opp.Agency_Account__c!= null) accIds.add(opp.Agency_Account__c);
    if(opp.Rep_Firm__c != null)      accIds.add(opp.Rep_Firm__c);
    if(opp.AccountId != null)        accIds.add(opp.AccountId);

    System.debug('Account Ids--->'+accIds); 
    if(accIds.size()>0) 
    {
      //Need to add Billing related parameters
      //, Bill_To_MS__c, Number_of_copies__c, Invoice_Delivery_Method__c, Billing_Email__c, Billing_Type__c, Billing_Co_op__c,  Billing_Preference__c, Send_Zero_Invoices__c, Special_Billing_Instructions__c, Credit_Status__c, Billing_Change_Status__c
      accountsMap = new Map<Id,Account>([SELECT Id, Name, RecordtypeId, RecordType.DeveloperName, Phone, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Agency__c,Discount_Percentage__c FROM Account WHERE Id IN :accIds]);          
      System.debug('accountsMap>>>>>>>>>>'+accountsMap);      
    }
    return accountsMap;
  }


    /**
     * This method is used for verifying account record type for all the accounts exist on opportunity record
     * @param opp
     * @param accountsMap
     * @return String
     */
    private String verifyAccountRecordType(Opportunity opp, Map<Id,Account> accountsMap){        
      
      String retString = 'Success';  

      System.debug('inside verifyAccountRecordType>>'+opp);

      if(opp.Rep_Firm__c!=null && accountsMap.containsKey(opp.Rep_Firm__c) && accountsMap.get(opp.Rep_Firm__c).Recordtype.DeveloperName != 'Rep_Firm'){ 
          Log4SF.logMessage('ShowSeekerWebServiceHelper', 'verifyAccountRecordType', 'Incorrect Rep Firm Record Type', UserInfo.getUserId(),opp.Id);
          
          retString = 'Error: '+System.Label.Incorrect_RecordType+ ' for Opportunity Rep Firm.';
      }
      else if(opp.Agency_Account__c !=null && accountsMap.containsKey(opp.Agency_Account__c) && (accountsMap.get(opp.Agency_Account__c).Recordtype.DeveloperName != 'Agency_Account' && accountsMap.get(opp.Agency_Account__c).Recordtype.DeveloperName !='In_House_Agency_Account') ){ // SRSF-3447: Added 'In House Agency Account' check
          Log4SF.logMessage('ShowSeekerWebServiceHelper', 'verifyAccountRecordType', 'Incorrect Agency Record Type', UserInfo.getUserId(),opp.Id);
          
          retString = 'Error: '+System.Label.Incorrect_RecordType+ ' for Opportunity Agency.';
      }
      
      return retString;
  }

  /**
   * Check Proposal Record type
   * @param recType
   * @return String
   */
  private String mapRecordType(String recType)
  { 
    String recordType = recType;
    if(NULL != recType && String.isNotBlank(recType))
    {
      if(recType.contains('_INV')){            
        recordType = Label.Inventory_RT;
      }
      else if(recType.contains('_PR')){
        recordType = Label.Political_RT;
      }
      else if(recType.contains('_TR')){
        recordType = Label.Trade_RT;
      }
      else if(recType.contains('_LR')){              
        recordType = Label.Linear_RT;
      }
    }
    System.debug('recordType-->'+recordType);

    return recordType;
  } 

  /**
   * Mapping all the opportunity accounts (advertiser,agency & repfirm) to showseeker request
   * @param acc
   * @return 
   */
  private ShowSeekerHelper.AccountDetails mapAccountDetails(Account acc){      
    
    ShowSeekerHelper.AccountDetails account = new ShowSeekerHelper.AccountDetails();  
    account.id = acc.Id;
    account.name = acc.Name;
    account.discountPercent = acc.Discount_Percentage__c;
    account.phone = acc.Phone;
    account.address = mapAccountAddress(acc); 
    //account.billingDetails = mapAccountBillingDetails(acc);
    System.debug('account>>>>>>'+account);
    return account;
  } 

  /**
   * Set Account Address to showseeker request
   * @param acc
   * @return
   */
  private ShowSeekerHelper.AccountAdress mapAccountAddress(Account acc) 
  {  
    String billingStr1 , billingStr2 = '';
    ShowSeekerHelper.AccountAdress acctAdr = new ShowSeekerHelper.AccountAdress(); 

    if(String.isNotBlank(acc.BillingStreet)){        
       if(acc.BillingStreet.length() > 50) {
          billingStr1 = acc.BillingStreet.substring(0,50);
          billingStr1 = billingStr1.substring(0,billingStr1.lastIndexOf(' '));
          billingStr2 = acc.BillingStreet.substring(acc.BillingStreet.indexOf(billingStr1),acc.BillingStreet.length());
        }
        else { 
          billingStr1 = acc.BillingStreet; 
        }
    } 
    acctAdr.street1 = billingStr1;
    acctAdr.street2 = billingStr2.length() > 50 ? billingStr2.substring(0,50):billingStr2;          
    acctAdr.city = acc.BillingCity; 
    acctAdr.state = acc.BillingState; 
    acctAdr.zipCode = acc.BillingPostalCode;
    acctAdr.country = acc.BillingCountry;
    System.debug('Account Address >>>>>>>  '+acctAdr);

    return acctAdr;
  }

  /**
  * Mapping all the opportunity accounts (advertiser,agency & repfirm) to showseeker request
  * @param acc
  * @return
  */
  private ShowSeekerHelper.Opportunity mapOpportunityDetails(Opportunity opp, String rateCard)
  { 
    ShowSeekerHelper.Opportunity opportunity = new ShowSeekerHelper.Opportunity(); 

    opportunity.id = opp.Id;
    opportunity.name = opp.Name;
    opportunity.presentationDate = opp.CloseDate;
    opportunity.startDate = opp.Flight_Start_Date__c;
    opportunity.endDate = opp.Flight_End_Date__c;
    opportunity.stageName = opp.StageName;
    opportunity.amount = opp.Amount;
    opportunity.discountPercent = opp.Discount_Percentage__c;
    opportunity.discountCode = opp.Discount_Code__c; // SRSF-4969
    opportunity.rateCardName = rateCard; 
    opportunity.coOp = opp.CoOp__c; 
    opportunity.businessClassification = opp.Business_Classification__c; //SRSF-4604
    opportunity.billingDetails = mapOppBillingDetails(opp);    
    
    return opportunity;
  } 

  private ShowSeekerHelper.BillingDetails mapOppBillingDetails(Opportunity opp) 
  {  
    ShowSeekerHelper.BillingDetails oppBillingDtls = new ShowSeekerHelper.BillingDetails(); 

    oppBillingDtls.billTo = opp.Bill_To_MS__c;
    oppBillingDtls.numberOfCopies = opp.Number_of_copies__c;
    oppBillingDtls.invoiceDeliveryMethod = opp.Invoice_Delivery_Method__c;
    oppBillingDtls.billingEmail = opp.Billing_Email__c;
    oppBillingDtls.billingType = opp.Billing_Type__c;
    oppBillingDtls.billingCoOp = opp.Billing_Co_op__c;
    oppBillingDtls.billingPreference = opp.Billing_Preference__c;
    oppBillingDtls.sendZeroInvoices = opp.Send_Zero_Invoices__c;
    oppBillingDtls.splBillingInstructions = opp.Special_Billing_Instructions__c;
    oppBillingDtls.creditStatus = opp.Credit_Status__c;
    oppBillingDtls.billingChangeStatus = opp.Billing_Change_Status__c;

    System.debug('opportunity Billing Details >>>>>>>  '+oppBillingDtls);
    return oppBillingDtls;
  }

  /**
   * Set Account Billing details to showseeker request
   * @param acc
   * @return
   */
 /* private ShowSeekerHelper.BillingDetails mapAccountBillingDetails(Account acc) 
  {  
    ShowSeekerHelper.BillingDetails acctBilling = new ShowSeekerHelper.BillingDetails(); 

    acctBilling.billTo = acc.Bill_To_MS__c;
    acctBilling.numberOfCopies = acc.Number_of_copies__c;
    acctBilling.invoiceDeliveryMethod = acc.Invoice_Delivery_Method__c;
    acctBilling.billingEmail = acc.Billing_Email__c;
    acctBilling.billingType = acc.Billing_Type__c;
    acctBilling.billingCoOp = acc.Billing_Co_op__c;
    acctBilling.billingPreference = acc.Billing_Preference__c;
    acctBilling.sendZeroInvoices = acc.Send_Zero_Invoices__c;
    acctBilling.splBillingInstructions = acc.Special_Billing_Instructions__c;
    acctBilling.creditStatus = acc.Credit_Status__c;
    acctBilling.billingChangeStatus = acc.Billing_Change_Status__c;

    return acctBilling;
  }*/

  /**
   * Mapping all the opportunity accounts (advertiser,agency & repfirm) to showseeker request
   * @param acc
   * @return
   */
  public ShowSeekerHelper.OpportunityBudget mapOpportunityBudgetData(Proposal__c prop)
  {  
    ShowSeekerHelper.OpportunityBudget oppBudgetProp= new ShowSeekerHelper.OpportunityBudget(); 
    oppBudgetProp.id =  prop.Id;
    oppBudgetProp.startDate =  prop.Start_Date__c;
    oppBudgetProp.endDate =  prop.End_Date__c;
    //Retrieve all Proposal zone and Zone Monthly values
    List<Proposal_Zone__c> proposalZones = [SELECT Id, Name, Zone_Type__c, (SELECT Id, Name, Broadcast_Month__c, Year__c, Gross_Amount__c, Status_Type__c FROM Proposal_Zones_Monthly_Values__r) FROM Proposal_Zone__c WHERE Proposal__c=:prop.Id];

    System.debug('Proposal Zones >>>> '+proposalZones);

    if(proposalZones.size()>0)
    {             
      oppBudgetProp.zones = mapOppBudgetPZData(proposalZones);          
    }
    else {
      oppBudgetProp.zones = null;
    }
    System.debug('Opp Budget Proposal >>>> '+oppBudgetProp);

    return oppBudgetProp;
  } 


  private List<ShowSeekerHelper.ProposalZones> mapOppBudgetPZData(List<Proposal_Zone__c> proposalZones)
  {
    List<ShowSeekerHelper.ProposalZones> propZones = new List<ShowSeekerHelper.ProposalZones>();

    for(Proposal_Zone__c propZone : proposalZones)
    {
      ShowSeekerHelper.ProposalZones zone = new ShowSeekerHelper.ProposalZones();
      zone.id = propZone.Id;
      zone.name = propZone.Name;
      zone.zoneType = propZone.Zone_Type__c;
     
      if(propZone.Proposal_Zones_Monthly_Values__r.size()>0)
      {
          zone.zoneValues = mapOppBudgetPZMVData(propZone);
      }
      else {
        zone.zoneValues = null;
      }
      propZones.add(zone);
    } 
    System.debug('Proposal Zones >>>>>>> '+propZones);

    return propZones;
  }

  private List<ShowSeekerHelper.ProposalZonesMonthlyValues> mapOppBudgetPZMVData(Proposal_Zone__c propZone)
  {
    List<ShowSeekerHelper.ProposalZonesMonthlyValues> propZoneValues = new List<ShowSeekerHelper.ProposalZonesMonthlyValues>();

    for(Proposal_Zone_Monthly_Value__c eachZoneVal : propZone.Proposal_Zones_Monthly_Values__r)
    {
      ShowSeekerHelper.ProposalZonesMonthlyValues zoneValue = new ShowSeekerHelper.ProposalZonesMonthlyValues();

      zoneValue.id = eachZoneVal.Id;
      zoneValue.name = eachZoneVal.Name;
      zoneValue.broadcastMonth = eachZoneVal.Broadcast_Month__c;
      zoneValue.broadcastYear = eachZoneVal.Year__c;
      zoneValue.grossAmount = eachZoneVal.Gross_Amount__c;
      zoneValue.scheduleType = eachZoneVal.Status_Type__c;
     
      propZoneValues.add(zoneValue);
    }
    System.debug('Proposal Zone Monthly Values >>>>>>> '+propZoneValues);

    return propZoneValues;
  }

  //This method is use to activate/deactivate proposals in Showseeker
  public Map<Id, ShowSeekerHelper.ProposalResponse> activateInactiveProposals(List<Proposal__c> proposals)
  {  
    Map<Id, ShowSeekerHelper.ProposalResponse> proposalMap = new Map<Id, ShowSeekerHelper.ProposalResponse>();
    Map<Integer, Id> mapProposalIdToSSID = new Map<Integer, Id>(); 
    try 
    { 
      System.debug('Proposals to activate/deactivate >>>>> '+proposals);

      if(proposals.size() > 0)
      { 
        for(Proposal__c prop : proposals) {          
          mapProposalIdToSSID.put(Integer.valueOf(prop.Pilot_Proposal_ID__c), prop.Id);
        }
        String tokenId = authenticate(); 
        if(tokenId != NULL && String.isNotBlank(tokenId) && !hasError) 
        {
          ShowSeekerHelper.ActivateInactivateProposalPayload request = mapProposalActiveInactiveRequest(proposals);

          String req = JSON.serialize(request);
          System.debug('Activate/Inactivate Proposals Payload ---->'+req);
     
          HttpResponse result = RestServicePostStub('/crm/archive', req, tokenId);
          System.debug('ActivateInactivateProposal Response --->' +result);
         
          if(result!=NULL && result.getStatus().equalsIgnoreCase('OK') && result.getStatusCode() == 200)
          {  
              System.debug('### result.getBody() ::: ' +result.getBody());  
              //Build Response
              mapProposalActiveInactiveResponse(result, proposalMap, mapProposalIdToSSID);
              responseMsg =System.Label.Request_sent_to_Showseeker;
          }
          else
          {           
            hasError = true;
            ShowSeekerHelper.ShowSeekerErrorResponse errRepsonse = getErrorMessage(result);
            responseMsg = 'Error while sending request to ShowSeeker : '+result.getStatusCode()+ ' : '+ result.getStatus() ;
            if(!CommonUtilities.isStringNullOrEmpty(errRepsonse.message))
              responseMsg += ' Due to :'+ errRepsonse.message;
              Log4SF.logMessage('ShowSeekerWebServiceHelper','activateInactiveProposal', responseMsg,
                              UserInfo.getUserId(),'NA');
          }                
        }
        else{
           hasError = true;
           responseMsg =System.Label.Invalid_SessionID;
        }       
      }
      else 
      {
        hasError = true;
        responseMsg =System.Label.NO_PROP_SELECTED;
      }
    }
    catch(CalloutException ex) {
      hasError = true;
      responseMsg = System.label.ShowSeekerAPIError;
      System.debug('Callout error: '+ ex);
      Log4SF.logMessage('ShowSeekerWebServiceHelper', 'activateInactiveProposal'+ '/crm/archive',responseMsg, ex, UserInfo.getUserId(),'NA');
    }
    catch(Exception ex) {
      hasError = true;
      responseMsg ='Exception during ActivateInactiveProposal: ' + ex.getMessage();
      System.debug(responseMsg);
      Log4SF.logMessage('ShowSeekerWebServiceHelper', 'activateInactiveProposal', ex.getMessage(), ex, UserInfo.getUserId(),'NA'); 
    }  
    return proposalMap;
  }  

  private ShowSeekerHelper.ActivateInactivateProposalPayload mapProposalActiveInactiveRequest(List<Proposal__c> proposals)      
  {
    ShowSeekerHelper.ActivateInactivateProposalPayload activeInactivePropReq = new  ShowSeekerHelper.ActivateInactivateProposalPayload();
    List<ShowSeekerHelper.Proposals> lstprop = new List<ShowSeekerHelper.Proposals>();

    for(Proposal__c eachProp : proposals)
    {
      ShowSeekerHelper.Proposals prop = new ShowSeekerHelper.Proposals();   
      prop.proposalId = eachProp.Pilot_Proposal_ID__c;
      prop.isActive = !eachProp.Active__c;
      lstprop.add(prop);        
    }
          
    activeInactivePropReq.userName = UserInfo.getUserName();  
    activeInactivePropReq.proposals = lstprop; 

    return activeInactivePropReq;
  } 


  private void mapProposalActiveInactiveResponse(HttpResponse result,  Map<Id, ShowSeekerHelper.ProposalResponse> proposalMap, Map<Integer, Id> mapProposalIdToSSID)      
  { 
   
    String responseBody = result.getBody();   
    ShowSeekerHelper.ActivateInactivateProposalResponse response = ShowSeekerHelper.parseActivateInactivatePropRes(responseBody);
    System.debug('### response ::: ' +response);
    // Based on SS response check isSuccess and isActive values and separate proposals
    for(ShowSeekerHelper.ProposalResponse eachProp : response.proposals){
        proposalMap.put(mapProposalIdToSSID.get(eachProp.proposalId), eachProp);
    } 
    System.debug('proposalMap --->'+ proposalMap);
  } 


  //  This method is use to update proposal in Showseeker
  public String editProposal(Proposal__c prop)
  {
    String tokenId = authenticate(); 
    if(tokenId != NULL && String.isNotBlank(tokenId)) 
    { 
      ShowSeekerHelper.EditProposalPayload request = mapEditProposalRequest(prop.Pilot_Proposal_ID__c);
      System.debug('Edit Proposal Payload ---->'+JSON.serialize(request));
      
      HttpResponse result  = RestServicePostStub('/crm/editproposal', JSON.serialize(request),tokenId); 

      if(result!=NULL && result.getStatus().equalsIgnoreCase('OK') && result.getStatusCode() == 200)
      {   
          System.debug('### result.getBody() ::: ' +result.getBody());        
          String responseBody = result.getBody();  
          ShowSeekerHelper.ProposalResponsePayload response = ShowSeekerHelper.parseProposalResponse(responseBody); 
          responseMsg = response.link;
          System.debug('Edit Proposal ResponsePayload --->' +response);
          System.debug('HASH URL --->' +responseMsg);
      }
      else
      {
        hasError = true;
        ShowSeekerHelper.ShowSeekerErrorResponse errRepsonse = getErrorMessage(result);
        responseMsg = 'Error while sending request to ShowSeeker : '+result.getStatusCode()+ ' : '+ result.getStatus() ;
        if(!CommonUtilities.isStringNullOrEmpty(errRepsonse.message))
          responseMsg += ' Due to :'+ errRepsonse.message;
          Log4SF.logMessage('ShowSeekerWebServiceHelper','EditProposal', responseMsg,
                          UserInfo.getUserId(), prop.Id);
      }
    }
    else{
        hasError = true;
        responseMsg =System.Label.Invalid_SessionID;
    }   
    return responseMsg;
  }

  private ShowSeekerHelper.EditProposalPayload mapEditProposalRequest(String showSeekerId)
  {
      ShowSeekerHelper.EditProposalPayload editPropReq = new ShowSeekerHelper.EditProposalPayload();
      editPropReq.proposalId = showSeekerId;
      editPropReq.userName = UserInfo.getUserName();  

      return editPropReq;
  } 

  private ShowSeekerHelper.ShowSeekerErrorResponse getErrorMessage(HttpResponse result)
  {
    String responseBody = result.getBody();  
    ShowSeekerHelper.ShowSeekerErrorResponse response = ShowSeekerHelper.parseSSErrorResponse(responseBody);
    System.debug('### response ::: ' +response);
    return response;
  }
}