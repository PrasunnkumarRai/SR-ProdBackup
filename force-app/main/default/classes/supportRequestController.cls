public class supportRequestController {
    
    @AuraEnabled
    public static map<String, object> createPostPlanningSupportRequest( Id suppReq){
        Id RecordTypeId = Schema.SObjectType.Support_Request__c.getRecordTypeInfosByName().get('Post Planning Request').getRecordTypeId();
        Id userId = UserInfo.getUserId();
        map<String, object> data = new map<String, object>();
        map<String, object> defaultValues = new map<String, object>();
        Support_Request__c objSuppReq = [SELECT Id, Name, Assigned_To__c, Due_Date__c, DMA__c, Tier_Designation__c, SAM_Designation__c,
                                         Request_Description_Planning__c, OwnerId,Billing_Type__c,Campaign_Goals__c,Campaign_Needs__c,
                                         Sales_Office__c, Division__c, Region__c, Rep_Firm__c, Agency__c,Advertiser__c,Opportunity__c,Budget_Monthly__c,
                                         Flight_Start_Date__c,Flight_End_Date__c, Advanced_Budget_Monthly__c,Budget_Over_Campaign__c,Budget_Monthly_Over_Campaign__c, Linear_Budget_Monthly__c,
                                         Budget_Type__c, Remove_Opportunity_Budget__c, Date_Time_Submitted__c, Date_Time_Completed__c, CNA_Link__c, Multicultural__c,Linear_Budget_Over_Campaign__c,
                                         Products__c, Needed__c, Target_Linear_Audience__c, Target_Advanced_Audience__c, Zones__c, Current_Media_What_Works_For_them__c,
                                         Programs__c, Posting__c,Posting_Requirements__c,Nielsen_Demographics__c,Source__c,Month_s__c,Goal_GRP__c,Goal_Impressions__c,Freeform__c,
                                         CPM__c, Advanced_Budget_Over_Campaign__c,Account_Executive__c
                                         FROM Support_Request__c 
                                         WHERE Id=:suppReq limit 1];
        data.put('entityApiName', 'Support_Request__c');
        data.put('recordTypeId', RecordTypeId);
        defaultValues.put('Account_Executive__c', objSuppReq.Account_Executive__c );
        defaultValues.put('OwnerId', userId );
        defaultValues.put('Planning_Request__c', objSuppReq.Id );
        defaultValues.put('Status__c', 'Draft' );
        defaultValues.put('Sales_Office__c', objSuppReq.Sales_Office__c );
        defaultValues.put('Division__c', objSuppReq.Division__c );
        defaultValues.put('Region__c', objSuppReq.Region__c );
        defaultValues.put('Name', objSuppReq.Name );
        defaultValues.put('Advertiser__c', objSuppReq.Advertiser__c );
        defaultValues.put('Rep_Firm__c', objSuppReq.Rep_Firm__c );
        defaultValues.put('Agency__c', objSuppReq.Agency__c );
        defaultValues.put('Flight_Start_Date__c', objSuppReq.Flight_Start_Date__c );
        defaultValues.put('Flight_End_Date__c', objSuppReq.Flight_End_Date__c );
        defaultValues.put('Opportunity__c', objSuppReq.Opportunity__c );
        defaultValues.put('Budget_Monthly__c', objSuppReq.Budget_Monthly__c );
        defaultValues.put('Budget_Over_Campaign__c', objSuppReq.Budget_Over_Campaign__c );
        defaultValues.put('Advanced_Budget_Monthly__c', objSuppReq.Advanced_Budget_Monthly__c );
        defaultValues.put('Budget_Monthly_Over_Campaign__c', objSuppReq.Budget_Monthly_Over_Campaign__c );
        defaultValues.put('Linear_Budget_Monthly__c', objSuppReq.Linear_Budget_Monthly__c );
        defaultValues.put('Linear_Budget_Over_Campaign__c', objSuppReq.Linear_Budget_Over_Campaign__c );
        defaultValues.put('Budget_Type__c', objSuppReq.Budget_Type__c );
        defaultValues.put('Campaign_Needs__c', objSuppReq.Campaign_Needs__c );
        defaultValues.put('Campaign_Goals__c', objSuppReq.Campaign_Goals__c );
        defaultValues.put('Billing_Type__c', objSuppReq.Billing_Type__c );
        defaultValues.put('Remove_Opportunity_Budget__c', objSuppReq.Remove_Opportunity_Budget__c );
        defaultValues.put('Date_Time_Submitted__c', objSuppReq.Date_Time_Submitted__c );
        defaultValues.put('Date_Time_Completed__c', objSuppReq.Date_Time_Completed__c );
        defaultValues.put('CNA_Link__c', objSuppReq.CNA_Link__c );
        defaultValues.put('Multicultural__c', objSuppReq.Multicultural__c );
        defaultValues.put('Products__c', objSuppReq.Products__c );
        defaultValues.put('Target_Linear_Audience__c', objSuppReq.Target_Linear_Audience__c );
        defaultValues.put('Target_Advanced_Audience__c', objSuppReq.Target_Advanced_Audience__c );
        defaultValues.put('Zones__c', objSuppReq.Zones__c );
        defaultValues.put('Current_Media_What_Works_For_them__c', objSuppReq.Current_Media_What_Works_For_them__c );
        defaultValues.put('Programs__c', objSuppReq.Programs__c );
        defaultValues.put('Posting__c', objSuppReq.Posting__c );
        defaultValues.put('Posting_Requirements__c', objSuppReq.Posting_Requirements__c );
        defaultValues.put('Nielsen_Demographics__c', objSuppReq.Nielsen_Demographics__c );
        defaultValues.put('Source__c', objSuppReq.Source__c );
        defaultValues.put('Month_s__c', objSuppReq.Month_s__c );
        defaultValues.put('Goal_GRP__c', objSuppReq.Goal_GRP__c );
        defaultValues.put('Goal_Impressions__c', objSuppReq.Goal_Impressions__c );
        defaultValues.put('CPM__c', objSuppReq.CPM__c );
        defaultValues.put('Advanced_Budget_Over_Campaign__c', objSuppReq.Advanced_Budget_Over_Campaign__c );
        defaultValues.put('DMA__c', objSuppReq.DMA__c ); // SRSF-3785
        defaultValues.put('Tier_Designation__c', objSuppReq.Tier_Designation__c ); // SRSF-4944
        if(System.label.SAMDesignationShutDown == 'FALSE'){
            defaultValues.put('SAM_Designation__c', objSuppReq.SAM_Designation__c ); //SRSF-3785
        }
        
        if( defaultValues.size() > 0 ){
            data.put( 'defaultFieldValues', defaultValues );
        }
        System.debug('data::'+data);
        return data;
        
    }
    
    
}