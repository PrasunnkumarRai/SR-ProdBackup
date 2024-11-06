public class clonePlanningRequestController  {
    @AuraEnabled
    public static map<String, object> cloneThisPlanningRequest( String recordId ){
        Id RecordTypeId = Schema.SObjectType.Support_Request__c.getRecordTypeInfosByName().get('Planning Request').getRecordTypeId();
        System.debug('RecordTypeId' +RecordTypeId);
         Id userId = UserInfo.getUserId();
        map<String, object> data = new map<String, object>();
        map<String, object> defaultValues = new map<String, object>();
        Support_Request__c objSuppReq = [SELECT Id, Due_Date__c,Name,
                                Request_Description_Planning__c, OwnerId,Billing_Type__c,Campaign_Goals__c,Campaign_Needs__c,
                                Sales_Office__c, Division__c, Region__c, Rep_Firm__c, Agency__c,Advertiser__c,Opportunity__c,Opportunity__r.Name,
                                Budget_Type__c, Remove_Opportunity_Budget__c, Date_Time_Submitted__c, Date_Time_Completed__c, CNA_Link__c,
                                Products__c, Needed__c, Target_Linear_Audience__c, Target_Advanced_Audience__c, Zones__c, Current_Media_What_Works_For_them__c,
                                Programs__c, Posting__c,Posting_Requirements__c,Nielsen_Demographics__c,Source__c,Month_s__c,Goal_GRP__c,Goal_Impressions__c,
                                CPM__c,DMA__c,Account_Executive__c, Tier_Designation__c,SAM_Designation__c
                                FROM Support_Request__c 
                                WHERE Id=:recordId limit 1];
        DateTime dt = DateTime.now();
        String dateTimeStr = dt.format('MM/dd/yyyy');
        System.debug('todaysDate@@@'+ dateTimeStr);
       // DateTime todaysDate = System.today();
       // System.debug('todaysDate@@@'+ todaysDate);
		//String todaysDateStr = todaysDate.format('MM/dd/yyyy');
        String suppName = objSuppReq.Opportunity__r.Name + '-'+ dateTimeStr;
        System.debug('suppName@@@'+ suppName);
        data.put('entityApiName', 'Support_Request__c');
        data.put('recordTypeId', RecordTypeId);
        defaultValues.put('Name', suppName);
        defaultValues.put('Account_Executive__c', objSuppReq.Account_Executive__c );
        defaultValues.put('OwnerId', userId );
        defaultValues.put('Status__c', 'Draft' );
        defaultValues.put('Sales_Office__c', objSuppReq.Sales_Office__c );
        defaultValues.put('Division__c', objSuppReq.Division__c );
        defaultValues.put('Region__c', objSuppReq.Region__c );
        defaultValues.put('Advertiser__c', objSuppReq.Advertiser__c );
        defaultValues.put('Rep_Firm__c', objSuppReq.Rep_Firm__c );
        defaultValues.put('Agency__c', objSuppReq.Agency__c );
        defaultValues.put('Opportunity__c', objSuppReq.Opportunity__c );
        defaultValues.put('Budget_Type__c', objSuppReq.Budget_Type__c );
        defaultValues.put('Campaign_Needs__c', objSuppReq.Campaign_Needs__c );
        defaultValues.put('Campaign_Goals__c', objSuppReq.Campaign_Goals__c );
        defaultValues.put('Billing_Type__c', objSuppReq.Billing_Type__c );
        defaultValues.put('Remove_Opportunity_Budget__c', objSuppReq.Remove_Opportunity_Budget__c );
        defaultValues.put('Date_Time_Submitted__c', objSuppReq.Date_Time_Submitted__c );
        defaultValues.put('Date_Time_Completed__c', objSuppReq.Date_Time_Completed__c );
        defaultValues.put('CNA_Link__c', objSuppReq.CNA_Link__c );
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
        defaultValues.put('DMA__c', objSuppReq.DMA__c );
        defaultValues.put('Needed__c', objSuppReq.Needed__c );
        defaultValues.put('Tier_Designation__c', objSuppReq.Tier_Designation__c ); //SRSF-4944 
        if(System.label.SAMDesignationShutDown == 'FALSE'){
            defaultValues.put('SAM_Designation__c', objSuppReq.SAM_Designation__c ); //SRSF-3785
        }
        
        if( defaultValues.size() > 0 ){
            data.put( 'defaultFieldValues', defaultValues );
        }
        System.debug('data@@::' +data);
        return data;
        
	}
}