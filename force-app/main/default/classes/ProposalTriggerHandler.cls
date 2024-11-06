/*

Customer/Project:   Spectrum Reach 
Class name:
ProposalTriggerHandler
Author/Date:        John King    5/16/2017
Release:
TBD
Related US:         264, 558 (6/8/17)
Purpose:            Provides handler methods for the Proposal Trigger
Modifications:      2/28/2018 - Brett Ballantyne - SRSF-874

// This should be used in conjunction with the ApexTriggerComprehensive.trigger template
// The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

*/

public with sharing class ProposalTriggerHandler {
    
    public static boolean isPropTrendRecordAlreadyInserted = false;
    public static Boolean isFirstTimeExecuting = true; // SRSF-4822
    private boolean m_isExecuting = false;
    private Integer BatchSize = 0;
    public List<Proposal__c> proposals;
    public Set<String> proposalWonStatuses = new Set<String> ();
    public List<Id> advPropRTIds = new List<Id>();
    
    public ProposalTriggerHandler(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
        proposals = new List<Proposal__c> ();
        // Code change start: SRSF-1911       
        List<Group_Status__c> propWonStatus = [SELECT ID, Approval_Status__r.Name, Name, Rejection_Status__r.Name, Status_Type__c FROM Group_Status__c WHERE is_Closed_Won__c = true AND Is_Active__c = TRUE];
        for (Group_Status__c grpStatus : propWonStatus)
        {
            proposalWonStatuses.add(grpStatus.Name);
        }
        // Code change End: SRSF-1911
        advPropRTIds.add(Proposalutils.advancedProposalRtId);
        advPropRTIds.add(Proposalutils.advancedPoliticalRtId);
        advPropRTIds.add(Proposalutils.advancedTradeRtId);    
    }
    
    public void OnBeforeInsert(Proposal__c[] newProposals) {
        proposals.addAll(newProposals);
        
        //Update Opportunity Owner Info on proposal records
        Set<String> aeIDs = new Set<String> ();
        Set<Id> oppIds = new Set<Id> ();
        for (Proposal__c pro : newProposals) {
            if (pro.opportunity__c != null) {
                oppIds.add(pro.opportunity__c);
            }
            //Populate Proposal External Id
            if (String.isBlank(pro.ProposalExternalId__c) && String.isNotBlank(pro.TIM_Id__c) && String.isNotBlank(pro.TIM_system__c)) {
                pro.ProposalExternalId__c = pro.TIM_Id__c + ' ' + pro.TIM_system__c;
            }
            //Get Proposal AE ID
            if (pro.AE_ID__c != null)
            {
                aeIDs.add(pro.AE_ID__c);
            }
        }
        //Map of User Connection with AE ID and Tim System
        Map<String, userconnection__c> ucMap = new Map<String, userconnection__c> ();
        for (userconnection__c uc :[SELECT user__c, ae_id__c, TIM_System__c FROM userconnection__c WHERE ae_id__c IN :aeIDs]) {
            ucMap.put(uc.ae_id__c + uc.TIM_System__c, uc);
        }
        
        if (oppIds.size() > 0) {
            Map<Id, opportunity> oppMap;
            oppMap = new Map<Id, opportunity> ([SELECT Id, Owner.division__c, Owner.region__c, Owner.sales_office__c FROM Opportunity WHERE Id IN :oppIds]);
            
            for (Proposal__c pro : newProposals) {
                if (oppMap != null && oppMap.get(pro.opportunity__c) != null) {
                    pro.division__c = oppMap.get(pro.opportunity__c).Owner.division__c;
                    pro.region__c = oppMap.get(pro.opportunity__c).Owner.region__c;
                    pro.sales_office__c = oppMap.get(pro.opportunity__c).Owner.sales_office__c;
                }
                if (ucMap != null && ucMap.containsKey(pro.AE_Id__c + pro.TIM_System__c) && String.isNotBlank(pro.AE_Id__c)) {
                    pro.Proposal_Owner__c = ucMap.get(pro.AE_Id__c + pro.TIM_System__c).user__c;
                }
                // Code Changes for SRSF – 1274 – Code Starts
                if (pro.Political_Proposal__c && pro.Pilot_Proposal__c==NULL)//SRSF-5061 : Added Pilot Proposal NULL check
                    pro.RecordTypeId = ProposalUtils.politicalRtId;
                // Code Changes for SRSF – 1274 – Code ends
                // START: Code changes for SRSF-1730 
                if (pro.Proposal_Closed__c) pro.Proposal_Closed_Date__c = System.now();
                // END: SRSF-1730 
            }
            copyAgencyFiledToRepFirm();
        }
    }
    
    
    // SRSF-874 
    /* Commented code changes as part of SRSF-1730 
private void updateFirstContractedAirDate(List<Proposal__c> props, Map<Id, Proposal__c> propMap) {
List<Account> accountsToUpdate = new List<Account>();
for (Proposal__c pro : [select Proposal_Closed__c, Opportunity__c, Opportunity__r.AccountId, 
Opportunity__r.Account.First_Contracted_Air_Date__c 
from Proposal__c 
where Id in :props]) {
if (pro.Proposal_Closed__c == true && pro.Opportunity__c != null && pro.Opportunity__r.AccountId != null) {
System.debug('--------------->> if passed, pro = ' + pro);
if (pro.Opportunity__r.Account.First_Contracted_Air_Date__c == null ||
(pro.Opportunity__r.Account.First_Contracted_Air_Date__c > Date.today())) {
Date airDate = propMap.get(pro.Id).Start_Date__c;
System.debug('--------------->> setting First_Contracted_Air_Date__c to: ' + airDate);
pro.Opportunity__r.Account.First_Contracted_Air_Date__c = airDate;
accountsToUpdate.add(pro.Opportunity__r.Account);
}
}
}
if (accountsToUpdate.size() > 0) {
try {
update accountsToUpdate;
} catch (Exception ex) {
Log4SF.logMessage('ProposalTriggerHandler', 'beforeInsert', 'Error updating accounts First_Contracted_Air_Date__c: ' + ex.getMessage(), UserInfo.getUserId(),'Error','');
}
}  
} END - code changes of SRSF-1730 */
    
    //Code Added by Srikanth on 13 Dec 17
    //Changes for the Boomi User to switch the Agency/RepFirm to the appropiate fields.
    
    // Add changes by Amita Mishra for allow this trigger to all the user
    
    public void copyAgencyFiledToRepFirm() {
        System.debug('UserInfo.getUserName::' + UserInfo.getUserName());
        System.debug('Label.BoomiUser::' + Label.BoomiUser);
        //if(UserInfo.getUserName() == Label.BoomiUser)
        // {      
        List<Id> prpAccountIds = new List<Id> ();
        for (Proposal__c prp : proposals) {
            if (String.isNotBlank(prp.Agency__c))
                prpAccountIds.add(prp.Agency__c);
            else if (String.isNotBlank(prp.Rep_Firm__c))
                prpAccountIds.add(prp.Rep_Firm__c);
        }
        Map<ID, Account> accMap = new Map<ID, Account> ([SELECT Id, Name, OwnerId, RecordTypeId FROM Account WHERE Id IN :prpAccountIds]);
        
        for (Proposal__c prp : proposals)
        {
            if (String.isNotBlank(prp.Agency__c))
            {
                if (accMap.containsKey(prp.Agency__c))
                {
                    if (accMap.get(prp.Agency__c).RecordTypeId == AccountUtils.repFirmRtId)
                    {
                        prp.Rep_Firm__c = prp.Agency__c;
                        prp.Agency__c = null;
                    }                    
                }
            }
            else if (String.isNotBlank(prp.Rep_Firm__c))
            {
                if (accMap.containsKey(prp.Rep_Firm__c))
                {
                    if (accMap.get(prp.Rep_Firm__c).RecordTypeId == AccountUtils.agencyAccountRtId)
                    {
                        prp.Agency__c = prp.Rep_Firm__c;
                        prp.Rep_Firm__c = null;
                    }                    
                }
            }
        }
        //}
    }
    //Code changes end by Srikanth
    
    public void OnAfterInsert(Proposal__c[] newProposals, Map<ID, Proposal__c> ProposalMap) {
        //SyncplicitySRUtils.CreateSyncplicityFolders(new List<Id> (new Map<Id, Proposal__c> (newProposals).keySet()));
        // updateFirstContractedAirDate(newProposals, ProposalMap); Commented as part of SRSF-1730

        //START SRSF-4341 & 4342 : Create AOS Account if not exist when an account is created
        System.debug('OnAfterInsert--->' + ProposalMap);
        Set<Id> accIDs = new Set<Id> ();
        for(Proposal__c prop : ProposalMap.values())
        {
            if(advPropRTIds.contains(prop.recordTypeId))
            {
                if(prop.Advertiser__c != NULL)
                    accIDs.add(prop.Advertiser__c);
                if(prop.Rep_Firm__c != NULL)
                    accIDs.add(prop.Rep_Firm__c);
                if(prop.Agency__c != NULL)
                    accIDs.add(prop.Agency__c);
            }
        }

        System.debug('accIDs--->' + accIDs);

        if(accIDs.size()>0)
        {            
            Map<Id, Account> accs = new Map<Id, Account>([SELECT Id, Credit_Status__c FROM Account WHERE Id IN :accIDs AND AOS_Account_Id__c = NULL]); //SRSF-5137 : Removed 'Credit Status' Check
            System.debug('accs--->' + accs);

            if(accs.size()>0)
            {   
                Set<Id> sendAccsToAOS = New Set<Id>();
                sendAccsToAOS.addAll(accs.keySet());
                System.debug('sendAccsToAOS--->' + sendAccsToAOS);   

                AOSWebServiceHelper.sendReqToUpsertAOSAccount(sendAccsToAOS);
            }
        }
        //END SRSF-4341 & 4342
    }
    
    @future public static void OnAfterInsertAsync(Set<ID> newProposalIDs) {
        //Example usage
        //List<Proposal> newProposals = [select Id, Name from Proposal where Id IN :newProposalIDs];
    }
    
    //public void OnBeforeUpdate(Proposal__c[] oldProposals, Proposal__c[] updatedProposals, Map<ID, Proposal__c> ProposalMap){
    public void OnBeforeUpdate(Proposal__c[] oldProposals, Proposal__c[] updatedProposals, Map<ID, Proposal__c> oldProposalMap, Map<ID, Proposal__c> ProposalMap) {
        //Example Map usage
        //Map<ID, Contact> contacts = new Map<ID, Contact>( [select Id, FirstName, LastName, Email from Contact where ProposalId IN :ProposalMap.keySet()] ); 
        
        Id linearRecordTypeId = Schema.SObjectType.Proposal__c.getRecordTypeInfosByDeveloperName().get('Linear').getRecordTypeId();
        Id invRecordTypeId = Schema.SObjectType.Proposal__c.getRecordTypeInfosByDeveloperName().get('Inventory').getRecordTypeId();
        //Get Proposal AE ID
        Set<String> aeIDs = new Set<String> ();
        Set<Proposal__c> propList = new Set<Proposal__c> ();
        for (Proposal__c pro : oldProposals)
        {
            if (pro.AE_ID__c != null && ProposalMap.get(pro.Id).AE_ID__c != pro.AE_ID__c)
            {
                aeIDs.add(ProposalMap.get(pro.Id).AE_ID__c);
                propList.add(ProposalMap.get(pro.Id));
            }
            // START: Code changes for SRSF-1731
            if (ProposalMap.get(pro.Id).RecordTypeId == invRecordTypeId && ProposalMap.get(pro.Id).TIM_Status__c != 'Proposal' && ProposalMap.get(pro.Id).TIM_Status__c != null)
                ProposalMap.get(pro.Id).RecordTypeId = linearRecordTypeId;
            // END: SRSF-1731
            // START: Code changes for SRSF-1730
            if (pro.Proposal_Closed__c != ProposalMap.get(pro.Id).Proposal_Closed__c && ProposalMap.get(pro.Id).Proposal_Closed__c)
                ProposalMap.get(pro.Id).Proposal_Closed_Date__c = System.now();
            // END: SRSF-1730
        }
        
        //Map of User Connection with AE ID and Tim System
        Map<String, userconnection__c> ucMap = new Map<String, userconnection__c> ();
        for (userconnection__c uc :[SELECT user__c, ae_id__c, TIM_System__c FROM userconnection__c WHERE ae_id__c IN :aeIDs]) {
            ucMap.put(uc.ae_id__c + uc.TIM_System__c, uc);
        }
        for (Proposal__c pro : propList) {
            if (ucMap != null && ucMap.containsKey(pro.AE_Id__c + pro.TIM_System__c) && String.isNotBlank(pro.AE_Id__c)) {
                pro.Proposal_Owner__c = ucMap.get(pro.AE_Id__c + pro.TIM_System__c).user__c;
            }
        }
        
        // Code Changes for SRSF – 1274 – Code Starts
        for (Proposal__c pro : updatedProposals) {
            if (pro.Political_Proposal__c && pro.Pilot_Proposal__c==NULL) //SRSF-5061 : Added Pilot Proposal NULL check
                pro.RecordTypeId = ProposalUtils.politicalRtId;
        }
        // Code Changes for SRSF – 1274 – Code ends
        
        // SRSF-1911 Code Changes Start: Proposal: Add Eclipse customer number and Eclipse system name for exported orders 
        System.debug('proposalWonStatuses>>>>>' + proposalWonStatuses);
        Set<String> advtim = new Set<String> ();
        List<Proposal__c> updtprop = new List<Proposal__c> ();
        
        for (Integer i = 0; i<updatedProposals.size(); i++) {
            if (oldProposalMap.get(updatedProposals[i].Id).TIM_Status__c<> updatedProposals[i].TIM_Status__c &&
                proposalWonStatuses.contains(updatedProposals[i].TIM_Status__c)
                && updatedProposals[i].Current_Advertiser_Tim_Id__c != null) {
                    advtim.add(updatedProposals[i].Current_Advertiser_Tim_Id__c);
                    updtprop.add(updatedProposals[i]);
                }
        }
        
        List<Traffic_Id_Element__c> tidLst = [SELECT Id, Account_TIM_ID__c, TIM_System__c, ExportSystem_Name__c, Traffic_Id__c FROM Traffic_Id_Element__c WHERE Account_TIM_ID__c IN :advtim];
        for (Proposal__c pro : updtprop) {
            pro.Eclipse_Customer_ID__c = '';
            
            try {
                if (tidLst.Size()> 0) {
                    for (Traffic_Id_Element__c tld : tidLst) {
                        string trafficData = ' | ' + tld.ExportSystem_Name__c + ' - ' + tld.Traffic_Id__c;
                        if (tld.TIM_System__c == pro.TIM_System__c && tld.Account_TIM_ID__c == pro.Current_Advertiser_Tim_Id__c) {
                            if (pro.Eclipse_Customer_ID__c == null || pro.Eclipse_Customer_ID__c == '') {
                                pro.Eclipse_Customer_ID__c = tld.ExportSystem_Name__c + ' - ' + tld.Traffic_Id__c;
                            } else if(pro.Eclipse_Customer_ID__c.length() <= 255 && (pro.Eclipse_Customer_ID__c + trafficData).length() <= 255) {
                                pro.Eclipse_Customer_ID__c += trafficData;
                            }
                        }
                    }
                } else {
                    pro.Eclipse_Customer_ID__c = '';
                }
            }
            Catch(Exception ex)
            {
                System.debug('Exception ex ' + ex.getMessage());
            }
        }
        
        // SRSF-1911 Code Changes End
        
        
        // updateFirstContractedAirDate(updatedProposals, ProposalMap);
        if (NULL != updatedProposals && !updatedProposals.isEmpty()) {
            proposals.addAll(updatedProposals);
            copyAgencyFiledToRepFirm();
        }
    }
    
    public void OnAfterUpdate(Proposal__c[] oldProposals, Proposal__c[] updatedProposals, Map<ID, Proposal__c> ProposalMap) {
        List<Id> proposalList = new List<Id> ();
        Set<Id> opportunities = new Set<Id> ();
        Map<String, String> oppStatusMap = new Map<String, String> ();
        //TODO: Pick Proposal Status Mappings from Group Status custom object (Manager Approval, Credit Approval fields for account mappings)
        Map<String, String> timOppStatusMap = new Map<String, String> { 'Submitted to Sales Management' => System.Label.Submitted_For_Approval, 'Submitted to Billing' => System.Label.Manager_Approval, 'Submitted to Traffic' => System.Label.Billing_Approval, 'Approved by Traffic' => System.Label.Closed_Won_Label, 'Revision Accepted by Traffic' => System.Label.Closed_Won_Label, 'Traffic Updates Accepted' => System.Label.Closed_Won_Label };
            /* // Commented to avoid Code duplication
Set<String> proposalWonStatuses = new Set<String>();
List<Group_Status__c> propWonStatus = [Select ID,Approval_Status__r.Name,Name, Rejection_Status__r.Name,Status_Type__c from Group_Status__c where is_Closed_Won__c = true AND Is_Active__c = TRUE];
for(Group_Status__c grpStatus : propWonStatus)
{
proposalWonStatuses.add(grpStatus.Name); 
}*/
            
            
            /* Commented as part of SRSF-1730
for (Proposal__c prop : oldProposals){
if(prop.Proposal_Closed__c != true && proposalMap.get(prop.id).Proposal_Closed__c == true){
updateFirstContractedAirDate(updatedProposals, ProposalMap);
}
}*/
            
            //{'Approved by Traffic','Revision Accepted by Traffic','Traffic Updates Accepted'};
            List<Account> accountList = new List<Account> ();
        Map<Id, Account> accountMap = new Map<Id, Account> ();
        //Get Account and Credit Status from the custom metadata.
        List<Account_Status_Updates__mdt> accountStatusList = new List<Account_Status_Updates__mdt> ();
        accountStatusList = [SELECT New_Status__c, Old_Status__c, Status_Type__c FROM Account_Status_Updates__mdt LIMIT 49999];
        
        Set<String> accntStatus = new Set<String> ();
        Set<String> accntCreditStatus = new Set<String> ();
        Map<String, String> statusMap = new Map<String, String> ();
        try {
            for (Account_Status_Updates__mdt status : accountStatusList)
            {
                if (status.Status_Type__c == 'Credit Status')
                {
                    accntCreditStatus.add(status.Old_Status__c);
                    
                }
                else if (status.Status_Type__c == 'Approval Status')
                    accntStatus.add(status.Old_Status__c);
                statusMap.put(status.Status_Type__c + status.Old_Status__c, status.New_Status__c);
            }
        }
        catch(Exception ex)
        {
            System.debug('Exception in retrieving status from custom setting. Error: ' + ex + ex.getLineNumber());
        }
        
        Set<String> proposalsToConsider = new Set<String> ();
        
        for (Proposal__c prop : updatedProposals) {
            //If a proposal is marked active when earlier it was marked as inactive
            // for (Proposal__c oldProp : oldProposals){
            // if(oldProp.Id == prop.Id) {
            System.debug(proposalWonStatuses);
            //Update Account status based on Proposal Won statusesprop.TIM_Status__c != oldProp.TIM_Status__c &&
            if (proposalWonStatuses.contains(prop.TIM_Status__c) || proposalWonStatuses.contains(prop.Pilot_Order_Status__c)) // SRSF-3921 : Added Pilot_Order_Status__c condition
            {
                proposalsToConsider.add(prop.Id);
                
                if (accountMap.get(prop.Advertiser__c) == null)
                {
                    //only add Account if it isn't already in List/Map
                    //Account Status Check - If status is part of the Custom setting then override.
                    //Account Credit Status Check - If status is part of the Custom setting then override.
                    System.debug(accntCreditStatus);
                    System.debug(accntStatus);
                    System.debug(prop.Account_Credit_Status__c);
                    System.debug(prop.Account_Status__c);
                    if (accntCreditStatus.contains(prop.Account_Credit_Status__c) && accntStatus.contains(prop.Account_Status__c))
                        accountMap.put(prop.Advertiser__c, new Account(Id = prop.Advertiser__c, Approval_Status__c = statusMap.get('Approval Status' + prop.Account_Status__c), Credit_Status__c = statusMap.get('Credit Status' + prop.Account_Credit_Status__c)));
                    else if (!accntCreditStatus.contains(prop.Account_Credit_Status__c) && accntStatus.contains(prop.Account_Status__c))
                        accountMap.put(prop.Advertiser__c, new Account(Id = prop.Advertiser__c, Approval_Status__c = statusMap.get('Approval Status' + prop.Account_Status__c)));
                    else if (accntCreditStatus.contains(prop.Account_Credit_Status__c) && !accntStatus.contains(prop.Account_Status__c))
                        accountMap.put(prop.Advertiser__c, new Account(Id = prop.Advertiser__c, Credit_Status__c = statusMap.get('Credit Status' + prop.Account_Credit_Status__c)));
                    
                    if (accountMap.get(prop.Advertiser__c) != null) {
                        accountList.add(accountMap.get(prop.Advertiser__c));
                    }
                    opportunities.add(prop.Opportunity__c);
                    oppStatusMap.put(prop.Opportunity__c, 'Closed Won');
                }
                //accountList.add(new Account(id=prop.Advertiser__c,Approval_Status__c='Approved',Credit_Status__c='Current/Has Credit Terms'));
            }
            
            /*Deprecated: Proposal Zone Monthly Value recacilaution is not required 
if (prop.Active__c && !oldProp.Active__c){
proposalList.add(prop.Id);
}
// If a proposal is marked inactive when earlier it was marked as active
else if (!prop.Active__c && oldProp.Active__c){
proposalList.add(prop.Id);
}
/*
else if (prop.TIM_Status__c != oldProp.TIM_Status__c){
//if (timStatuses.contains(prop.TIM_Status__c))
/*opportunities.add(prop.Opportunity__c);
proposalList.add(prop.Id);
String oppStatus = System.Label.Opportunity_Negotiation_Label;
if (prop.TIM_Status__c != 'Proposal' && null == oppStatusMap.get(prop.Opportunity__c)){
oppStatusMap.put(prop.Opportunity__c,oppStatus);
}
if (null != timOppStatusMap.get(prop.TIM_Status__c)){                        
oppStatusMap.put(prop.Opportunity__c,timOppStatusMap.get(prop.TIM_Status__c));                    
}*/
            //}
            // }
            // }
        }
        // Set opportunities marked as Closed Won if not already when the Proposal Status changes to a appropriate Closed Won Status in Group Status
        if (opportunities.size() > 0) {
            try {
                List<Opportunity> opps = new List<Opportunity> ();
                Set<Id> oppIds = new Set<Id> ();
                for (Opportunity opp :[SELECT Id, StageName FROM Opportunity WHERE Id IN :opportunities]) {
                    System.debug('@@oppStatusMap.get(opp.Id) ' + oppStatusMap.get(opp.Id));
                    System.debug('@@oppStatusMap.get(opp.Id).left(2) ' + oppStatusMap.get(opp.Id).left(2));
                    System.debug('@@opp.stageName' + opp.stageName);
                    System.debug('@@opp.stageName.left(2) ' + opp.stageName.left(2));
                    if (oppStatusMap.get(opp.Id) != null) {
                        if (!oppIds.contains(opp.id)) {
                            opp.stageName = oppStatusMap.get(opp.Id);
                            opps.add(opp);
                            oppIds.add(opp.id);
                        }
                    }
                }
                if (opps != null && opps.size() > 0) {
                    Trigger_Static.allowStageNameChange = true;
                    update opps;
                }
            }
            catch(Exception ex) {
                System.debug('Exception in opp status mapping. Error: ' + ex + ex.getLineNumber());
            }
        }
        
        if (accountList.size() > 0) {
            Trigger_Static.allowStageNameChange = true;
            if (!Test.isRunningTest()) {
                try {
                    update accountList;
                }
                catch(Exception ex) {
                    System.debug('Error while updating Accounts in Proposal After Update: ' + ex);
                    Log4SF.logMessage('ProposalTriggerHandler', 'OnAfterUpdate', 'Account Update Error', ex, UserInfo.getUserId(), 'NA', '');
                }
            }
        }
        
        /*Deprecated: Proposal Zone Monthly Value recacilaution is not required
// Now recalculate the amount based on Proposal State or Status changes
if(proposalList != null && proposalList.size() > 0){
Proposal_Zone_Monthly_Value_Helper.refreshAmounts(proposalList);
}*/
        
        
        // Code changes for SRSF-1527 START
        // public static void createOrUpdateInitialOrderedMonthlyValues(Map<Id, Proposal_Zone_Monthly_Value__c> newMap) {
        
        
        List<Initial_Ordered_Monthly_Value__c> initialOrder_toBeCreate = new List<Initial_Ordered_Monthly_Value__c> ();
        Map<String, Boolean> existingIOMVmap = new Map<String, Boolean> ();
        if (proposalsToConsider.size() > 0) {
            List<Initial_Ordered_Monthly_Value__c> existingIOMV = new List<Initial_Ordered_Monthly_Value__c> ();
            existingIOMV = [SELECT Id, Name, Proposal__r.Id FROM Initial_Ordered_Monthly_Value__c WHERE Proposal__r.Id IN :proposalsToConsider];
            for (Initial_Ordered_Monthly_Value__c iomv : existingIOMV) {
                existingIOMVmap.put(iomv.Proposal__r.Id, true);
                proposalsToConsider.remove(iomv.Proposal__r.Id);
            }
            List<AggregateResult> proposalZoneMonthlyValuesResult = new List<AggregateResult> ();
            
            if (proposalsToConsider != null && !proposalsToConsider.isEmpty()) {
                
                proposalZoneMonthlyValuesResult = [SELECT Broadcast_Month_Date__c broadCastDate, Sum(Net_Amount__c) netAmt, Sum(Gross_Amount__c) grossAmt, Proposal_zone__r.Proposal__r.Id propId FROM Proposal_Zone_Monthly_Value__c WHERE Broadcast_Month_Date__c != null AND Net_Amount__c > 0 AND Proposal_zone__r.Proposal__r.Id IN :proposalsToConsider AND Proposal_zone__r.Proposal__c != null GROUP BY Broadcast_Month_Date__c, CALENDAR_MONTH(Broadcast_Month_Date__c), CALENDAR_YEAR(Broadcast_Month_Date__c), Proposal_zone__r.Proposal__r.Id ORDER BY Proposal_zone__r.Proposal__r.Id, CALENDAR_MONTH(Broadcast_Month_Date__c) ASC];
            }
            
            if (proposalZoneMonthlyValuesResult != null && proposalZoneMonthlyValuesResult.size() > 0) {
                
                for (AggregateResult agrResult : proposalZoneMonthlyValuesResult) {
                    String proposalId = (String) agrResult.get('propId');
                    
                    String propTimStatus = proposalMap.get(proposalId).TIM_Status__C;
                    String propPilotStatus = proposalMap.get(proposalId).Pilot_Order_Status__c; // SRSF-3921
                    System.debug(' ### proposalWonStatuses ::: ' + proposalWonStatuses + ' @@@ propTimStatus ::: ' + propTimStatus);            
                    
                    // SRSF-3921 : Added Pilot Prop Status Check
                    if (((existingIOMVmap != null && !existingIOMVmap.containsKey(proposalId)) || existingIOMVmap.size() == 0) && proposalWonStatuses != null && ((String.isNotBlank(propTimStatus) &&  proposalWonStatuses.contains(propTimStatus)) || (String.isNotBlank(propPilotStatus) &&  proposalWonStatuses.contains(propPilotStatus)))) {
                        Date broadcastMonthDate = (Date) agrResult.get('broadCastDate');
                        String initialOrderName = proposalId + '_' + broadcastMonthDate.month() + '_' + broadcastMonthDate.year();
                        String propStatus = String.isNotBlank(propPilotStatus) ? propPilotStatus : propTimStatus;
                        initialOrder_toBeCreate.add(new Initial_Ordered_Monthly_Value__c(Proposal__c = Id.valueOf(proposalId), Broadcast_Month_Date__c = (Date) agrResult.get('broadCastDate'), Gross_Amount__c = (Decimal) agrResult.get('grossAmt'), Net_Amount__c = (Decimal) agrResult.get('netAmt'), Name = initialOrderName + '_' + propStatus, Initial_Ordered_Name__c = initialOrderName));
                    }
                    /*else {
if(proposalWonStatuses == null) {
System.debug(' ### No Closed Won - Group Statuses ### ');
}
System.debug(' $$$ Proposal TIM Status is not yet reached to Traffic Updates Accepted and the current value is ' + propTimStatus);
}*/
                    
                }
            }
        }
        
        System.debug(' ### initialOrder_toBeCreate ::: ' + initialOrder_toBeCreate.size());
        if (initialOrder_toBeCreate != null && initialOrder_toBeCreate.size() > 0) {
            Database.SaveResult[] initialOrderResult = Database.insert(initialOrder_toBeCreate, false);
        }
        // }
        // Code changes for SRSF-1527 END   
    }
    
    //IB: START ** Commenting the Big object code for now as it is failing because of issues at Salesforce end
    /*
private static void processPropTrends(String oldPropList, String newPropMap, boolean is_Insert) {
try {
List<Proposal__c> propList = (List<Proposal__c>) JSON.deserialize(oldPropList, List<Proposal__c>.class);
//(if(is_Insert) {
//    trackProposalTrends(propList, NULL, true);
//}
//else {
if (!is_Insert) {
System.debug('newPropMap : ' + newPropMap);
Map<Id, Proposal__c> propMap_New = (Map<Id, Proposal__c>) JSON.deserialize(newPropMap, Map<Id, Proposal__c>.class);
trackProposalTrends(propList, propMap_New, false);
}
}
catch(Exception ex) {
Log4SF.logMessage('ProposalTriggerHandler', 'trackProposalTrends', 'Proposal Trend Big Object Error', ex, UserInfo.getUserId(), 'NA');
}
}

// track fields updates in Big Object
private static void trackProposalTrends(list<Proposal__c> lstOldProposals, map<Id, Proposal__c> mapNewProposals, boolean isInsert) {
BigObjectSettings__c propTrendBO = BigObjectSettings__c.getInstance('ProposalTrend__b');
System.debug('propTrendBO : ' + propTrendBO);
System.debug('isPropTrendRecordAlreadyInserted : ' + isPropTrendRecordAlreadyInserted);
if (Test.isRunningTest()) isPropTrendRecordAlreadyInserted = false;
if (NULL != propTrendBO && propTrendBO.IsActive__c && !isPropTrendRecordAlreadyInserted) {
list<ProposalTrend__b> lstProposalTrends = new list<ProposalTrend__b> ();
Integer rollingCount = Integer.valueOf(propTrendBO.Rolling_Index__c);
for (Proposal__c oldProp : lstOldProposals) {
Proposal__c prop = (NULL != mapNewProposals) ? mapNewProposals.get(oldProp.Id) : NULL;
if (isInsert || prop == NULL) prop = oldProp;
ProposalTrend__b pTrend = new ProposalTrend__b(Proposal__c = prop.Id, Snapshot_Date_Time__c = System.now(), Proposal_Trend_Name__c = prop.Name, ProposalExternalId__c = prop.ProposalExternalId__c, TIM_System__c = prop.TIM_System__c);
System.debug('oldProp : ' + oldProp);
System.debug('prop : ' + prop);
if (isInsert || (!isInsert && NULL != prop && ((prop.Gross_Amount__c != oldProp.Gross_Amount__c) || (prop.Net_Amount__c != oldProp.Net_Amount__c) || (prop.TIM_Status__c != oldProp.TIM_Status__c)))) {
pTrend.Gross_Amount__c = prop.Gross_Amount__c;
pTrend.Net_Amount__c = prop.Net_Amount__c;
pTrend.TIM_Status__c = prop.TIM_Status__c;
pTrend.Gross_Amount_Currency__c = String.format(System.Label.BO_GrossAmount, new List<String> { '$' + pTrend.Gross_Amount__c });
pTrend.Net_Amount_Currency__c = String.format(System.Label.BO_NetAmount, new List<String> { '$' + pTrend.Net_Amount__c });
System.debug('BO pTrend ---> ' + pTrend);
lstProposalTrends.add(pTrend);
isPropTrendRecordAlreadyInserted = true;
rollingCount++;
pTrend.Rolling_Index__c = rollingCount;
if (Integer.valueOf(propTrendBO.Threshold_Index__c) <= rollingCount) rollingCount = 0;
}
}

if (!lstProposalTrends.isEmpty()) {
//insertProposalTrends(JSON.serialize(lstProposalTrends)); 
insertProposalTrends(lstProposalTrends, rollingCount, propTrendBO.Id);
}
}
}

private static void insertProposalTrends(List<ProposalTrend__b> propTrendRecords, Integer newRollingIndex, Id customSettingId) {
list<Database.saveResult> results = NULL;
if (!Test.isRunningTest()) results = Database.insertImmediate(propTrendRecords);
boolean incrementRollingIndex = true;
if (NULL != results) {
for (Database.saveResult saveRes : results) {
if (!saveRes.isSuccess()) {
incrementRollingIndex = false;
break;
}
}
}
if (incrementRollingIndex) {
BigObjectSettings__c setting_BO = new BigObjectSettings__c(Id = customSettingId);
setting_BO.Rolling_Index__c = newRollingIndex;
update setting_BO;
}
}*/
    //IB: END ** Commenting the Big object code for now as it is failing because of issues at Salesforce end*/
    
    @future public static void OnAfterUpdateAsync(String oldPropList, String newPropMap, boolean is_Insert) {
        //List<Proposal__c> updatedProposals = [select Id, Name from Proposal where Id IN :updatedProposalIDs];
        //IB: START ** Commenting the Big object code for now as it is failing because of issues at Salesforce end
        //SRSF-3867
        //processPropTrends(oldPropList, newPropMap, is_Insert);
        //IB: END ** Commenting the Big object code for now as it is failing because of issues at Salesforce end*/
    }
    
    public void OnBeforeDelete(Proposal__c[] ProposalsToDelete, Map<ID, Proposal__c> ProposalMap) {
        
    }
    
    public void OnAfterDelete(Proposal__c[] deletedProposals, Map<ID, Proposal__c> ProposalMap) {
        
    }
    
    @future public static void OnAfterDeleteAsync(Set<ID> deletedProposalIDs) {
        
    }
    
    public void OnUndelete(Proposal__c[] restoredProposals) {
        
    }
    
    public boolean IsTriggerContext {
        get { return m_isExecuting; }
    }
    
    public boolean IsVisualforcePageContext {
        get { return !IsTriggerContext; }
    }
    
    public boolean IsWebServiceContext {
        get { return !IsTriggerContext; }
    }
    
    public boolean IsExecuteAnonymousContext {
        get { return !IsTriggerContext; }
    }

    //SRSF-4822 : Added this method to updated Advanced Proposals when a Pilot Proposal is updated
    public void updateAdvancedPropOnPilotPropUpdate(Proposal__c[] oldProposals, Map<ID, Proposal__c> proposalMap)
    {
        System.debug('Inside updateAdvProposalsOnPilotUpdate--->');

        Map<Id, Proposal__c> pilotPropsMap = new Map<Id, Proposal__c> ();
        List<Proposal__c> propToUpdate = new List<Proposal__c>();

        for(Proposal__c oldProp : oldProposals)
        {
            Proposal__c updatedProp = proposalMap.get(oldProp.Id);

            if(updatedProp.Pilot_Proposal_ID__c != NULL 
            && (oldProp.Advertiser__c != updatedProp.Advertiser__c
            || oldProp.Agency__c != updatedProp.Agency__c
            || oldProp.Rep_Firm__c != updatedProp.Rep_Firm__c
            || oldProp.Opportunity__c != updatedProp.Opportunity__c
            || oldProp.Proposal_Owner__c != updatedProp.Proposal_Owner__c
            || oldProp.Traffic_Order_Number__c != updatedProp.Traffic_Order_Number__c
            || oldProp.Eclipse_Customer_ID__c != updatedProp.Eclipse_Customer_ID__c
            || oldProp.Division__c != updatedProp.Division__c
            || oldProp.Region__c != updatedProp.Region__c
            || oldProp.Sales_office__c != updatedProp.Sales_office__c))
            {
                pilotPropsMap.put(updatedProp.Id, updatedProp);
            }
        }

        System.debug('proposalsMap>>>>>>>>>>'+pilotPropsMap.Size());

        if(pilotPropsMap.Size() > 0) 
        {            
            List<Proposal__c> advPropsToUpdate = new List<Proposal__c>([SELECT Id, Pilot_Proposal__c,Advertiser__c, Agency__c, Rep_Firm__c, Opportunity__c, Proposal_Owner__c, Traffic_Order_Number__c, Eclipse_Customer_ID__c, Division__c, Region__c, Sales_office__c FROM Proposal__c WHERE Pilot_Proposal__c IN :pilotPropsMap.keySet() AND RecordTypeId IN :advPropRTIds]);

            System.debug('Advanced Proposals to be updated --->'+advPropsToUpdate.size());

            if(advPropsToUpdate.Size() > 0) 
            {
                for(Proposal__c advProp : advPropsToUpdate)
                {
                    Proposal__c prop = pilotPropsMap.get(advProp.Pilot_Proposal__c);
                    if(prop!=NULL)
                    {    
                        advProp.Advertiser__c = prop.Advertiser__c;
                        advProp.Agency__c = prop.Agency__c;
                        advProp.Rep_Firm__c = prop.Rep_Firm__c;
                        advProp.Opportunity__c = prop.Opportunity__c;
                        advProp.Proposal_Owner__c = prop.Proposal_Owner__c;
                        advProp.Traffic_Order_Number__c = prop.Traffic_Order_Number__c;
                        advProp.Eclipse_Customer_ID__c = prop.Eclipse_Customer_ID__c;
                        advProp.Division__c = prop.Division__c;
                        advProp.Region__c = prop.Region__c;
                        advProp.Sales_office__c = prop.Sales_office__c;

                        propToUpdate.add(advProp);
                    }    
                }
            } 
        } 
        System.debug ('propToUpdate>>>>>>'+propToUpdate.Size());
        
        if(propToUpdate.Size()>0)
        {            
            ProposalTriggerHandler.isFirstTimeExecuting = FALSE;
            UPDATE propToUpdate;            
        }                    
    }

    //SRSF-4778 : Added this method to update deals when a pilot proposal updated
    public void updateDealsOnPilotUpdate(Proposal__c[] oldProposals, Map<ID, Proposal__c> ProposalMap) 
    {
        System.debug('Inside updateDealsOnPilotUpdate--->'+ProposalMap);

        Set<Id> proposalIds = new Set<Id> ();
        for(Proposal__c oldProp : oldProposals)
        {            
            Proposal__c updatedProp = ProposalMap.get(oldProp.Id);

            if(updatedProp.Pilot_Proposal_ID__c != NULL 
            && (oldProp.Pilot_Order_ID__c != updatedProp.Pilot_Order_ID__c
            || oldProp.Pilot_Order_Status__c != updatedProp.Pilot_Order_Status__c
            || oldProp.Traffic_Order_Number__c != updatedProp.Traffic_Order_Number__c
            || oldProp.Eclipse_Customer_ID__c != updatedProp.Eclipse_Customer_ID__c
            || oldProp.Division__c != updatedProp.Division__c
            || oldProp.Region__c != updatedProp.Region__c
            || oldProp.Sales_office__c != updatedProp.Sales_office__c))
            {
                proposalIds.add(updatedProp.Id);
            }
        }
        System.debug('Pilot Proposals--->'+proposalIds);

        if(proposalIds.size()>0)
        {            
            Map<Id, Proposal__c> advProps = new Map<Id, Proposal__c>([SELECT Id FROM Proposal__c WHERE Pilot_Proposal__c IN :proposalIds AND AOS_Deal_Id__c != NULL AND RecordTypeId IN :advPropRTIds]); 
            System.debug('Advanced Proposals--->'+advProps.size());

            if(advProps.size()>0)
            {
                System.debug('Send request to update AOS Deals --->'+advProps);
                AOSWebServiceHelper.sendReqToUpdateAOSDeal(advProps.keySet());
            }
        }
    }

    //SRSF-5061 : AOS - Advanced Proposal Name Uniqueness
    // Commented below logic on request dated 09/30/2024
    /*public void updateDealsOnAdvPropUpdate(Proposal__c[] oldProposals, Map<ID, Proposal__c> ProposalMap) 
    {
        System.debug('Inside updateDealsOnAdvPropUpdate--->'+ProposalMap);        
        Set<Id> proposalIds = new Set<Id> ();
        
        for(Proposal__c oldProp : oldProposals)
        {            
            Proposal__c updatedProp = ProposalMap.get(oldProp.Id); 
            System.debug('Updated Prop Name>>>>'+updatedProp.Name); 
            
            if(updatedProp.AOS_Deal_Id__c != NULL && oldProp.Name != updatedProp.Name               
                && advPropRTIds.contains(updatedProp.RecordTypeId) && 
                   !String.valueOf(UserInfo.getUserId()).containsIgnoreCase(Label.BoomiUserId))            
            {
                proposalIds.add(updatedProp.Id);
            }
        }
        System.debug('Advanced Proposals--->'+proposalIds);

        if(proposalIds.size()>0) 
        {            
            AOSWebServiceHelper.sendReqToUpdateAOSDeal(proposalIds);            
        }
    }*/
}