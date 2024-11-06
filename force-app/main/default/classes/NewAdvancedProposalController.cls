public with sharing class NewAdvancedProposalController
{    
    @AuraEnabled
    public static Map<String, Object> fetchProposalData(Id proposalId)
    {
        System.debug('pilotPropId>>>>'+proposalId);

        Map<String, Object> data = new Map<String, Object>();
        Map<String, Object> defaultValues = new Map<String, Object>(); 
    
        Proposal__c prop = [SELECT Id, Name, Active__c, Order_Type__c, Start_Date__c, End_date__c, Opportunity__r.StageName, Advertiser__c, Advertiser__r.AOS_Account_Id__c, Agency__c, Agency__r.AOS_Account_Id__c, Rep_Firm__c,Rep_Firm__r.AOS_Account_Id__c, (SELECT Id FROM Proposal_Zones__r WHERE Zone_Type__c='Digital') FROM Proposal__c WHERE Id=:proposalId LIMIT 1];

        data.put('entityApiName', 'Proposal__c');
        defaultValues.put('Name', prop.Name);
        defaultValues.put('Start_Date__c', prop.Start_Date__c);
        defaultValues.put('End_Date__c', prop.End_Date__c);        
        defaultValues.put('Active__c', prop.Active__c);
        defaultValues.put('Order_Type__c', prop.Order_Type__c);
        defaultValues.put('StageName', prop.Opportunity__r.StageName);
        defaultValues.put('Advertiser__c', prop.Advertiser__c);
        defaultValues.put('Agency__c', prop.Agency__c);
        defaultValues.put('Rep_Firm__c', prop.Rep_Firm__c);
        defaultValues.put('Adv_AOSAccId', prop.Advertiser__r.AOS_Account_Id__c);
        defaultValues.put('Agency_AOSAccId', prop.Agency__r.AOS_Account_Id__c);
        defaultValues.put('Repfirm_AOSAccId', prop.Rep_Firm__r.AOS_Account_Id__c);
        defaultValues.put('DigitalPropsCnt', prop.Proposal_Zones__r.size());
        
        if( defaultValues.size() > 0 ){
            data.put('defaultFieldValues', defaultValues);
        }
        return data;
    }    

    @AuraEnabled
    public static Proposal__c createAdvancedProposal(Id pilotPropId, String orderType, String productType, String advPropName, Date startDt, Date endDt)
    {
        System.debug('pilotPropId>>>>'+pilotPropId);
        System.debug('orderType>>>>'+orderType);
        System.debug('product Type>>>>'+productType);
        System.debug('advPropName>>>>'+advPropName);
        System.debug('startDt>>>>'+startDt);
        System.debug('endDt>>>>'+endDt);
            
        Set<Id> propIds = new Set<Id>();
        Proposal__c advProp;    

        try {
            Proposal__c prop = [SELECT Id, Name, Advertiser__c, Agency__c, Advertiser__r.Political_Account__c, Opportunity__r.OwnerId, Sales_Office__c, Division__c, Region__c, Rep_Firm__c, Start_Date__c, End_Date__c, Opportunity__c, Opportunity__r.Billing_Type__c, Eclipse_Customer_ID__c, Traffic_Order_Number__c FROM Proposal__c WHERE Id=:pilotPropId LIMIT 1]; 
            
            advProp = new Proposal__c();
        //  advProp.RecordTypeId = ProposalUtils.advancedProposalRtId;
            advProp.RecordTypeId = prop.Advertiser__r.Political_Account__c ? ProposalUtils.advancedPoliticalRtId : ProposalUtils.advancedProposalRtId; //SRSF-4907
            advProp.Order_Type__c = orderType;
            advProp.Product_Type__c = productType;
            advProp.Name = advPropName;
            advProp.Pilot_Proposal__c = prop.Id;
            advProp.Opportunity__c = prop.Opportunity__c;
            advProp.Proposal_Owner__c = prop.Opportunity__r.OwnerId;
            advProp.Sales_Office__c = prop.Sales_Office__c;
            advProp.Division__c = prop.Division__c; 
            advProp.Region__c = prop.Region__c;        
            advProp.Eclipse_Customer_ID__c = prop.Eclipse_Customer_ID__c;        
            advProp.Traffic_Order_Number__c = prop.Traffic_Order_Number__c;

            advProp.Advertiser__c = (prop.Advertiser__c != null) ? prop.Advertiser__c : null; 
            advProp.Agency__c = (prop.Agency__c != null) ? prop.Agency__c : null; 
            advProp.Rep_Firm__c = (prop.Rep_Firm__c != null) ? prop.Rep_Firm__c : null; 

            advProp.Start_Date__c = (startDt != NULL)? startDt : prop.Start_Date__c;
            advProp.End_Date__c = (endDt != NULL)? endDt : prop.End_Date__c;

            INSERT advProp; 
                        
        } catch (Exception e){
            System.debug('Exception thrown: '+ e); 
            throw new AuraException(e.getMessage());
        }  
        return advProp;         
    }

    @AuraEnabled
    public static List<String> getPicklistValues(String dependentfieldName, String controllingFieldValue) {
        System.debug ('dependentfieldName>>>>'+dependentfieldName);
        System.debug ('controllingFieldValue>>>>'+controllingFieldValue);
        List<String> options = new List<String>();
        if (!CommonUtilities.isStringNullOrEmpty(dependentfieldName) && !CommonUtilities.isStringNullOrEmpty(controllingFieldValue)){
            Map<String, List<String>> dependentPLmap = PicklistFieldController.getDependentPicklistValues(new Proposal__c(),'Order_Type__c',dependentfieldName);
            System.debug('dependentPLmap>>>>>'+dependentPLmap);    
            options.addAll(dependentPLmap.get(controllingFieldValue));
            System.debug ('PicklistValues>>>>'+options);
        }    
        return options;
    }    
}