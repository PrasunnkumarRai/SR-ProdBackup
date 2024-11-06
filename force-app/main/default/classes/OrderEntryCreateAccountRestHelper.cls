global with sharing class OrderEntryCreateAccountRestHelper {
    
    public class CreateAccountParams 
    {
        public string campaignId {get; set;}
        public NewAccountInfo newAccountInfo {get; set;}
        public List<UniqueMarkets> uniqueMarkets {get; set;}
    }

    public class UniqueMarkets
    {
        public string market {get; set;}
    }

    public class NewAccountInfo
    {
        public string accountName {get; set;}
        public string enterpriseAccountType {get; set;}
        public string accountStreet {get; set;}
        public string accountCity {get; set;}
        public string accountState {get; set;}
        public string accountCountry {get; set;}
        public string primaryCommodity {get; set;}
        public string commodityCode {get; set;}
    }

    global class ResponseWrapper{
        public boolean isError {get; set;}
        public string errorCode {get; set;}
        public integer statusCode {get; set;}
        public string accountName {get; set;}
        public string accountId {get; set;}
        public list<string> opportunityIds {get; set;}
        public ResponseWrapper(){
            isError= false;
            errorCode = '';
            statusCode = 200;
            opportunityIds = new list<string>();
        }
    }

    public static Order_Entry__mdt oppTeamCustomMDT;
    public static Boolean ThrowAccountException         = false;
    public static Boolean ThrowOpportunityException     = false;
    public static string testException                  = 'My DML EXCEPTION';
    public static string accountRecordTypeName          = 'Advertiser_Account';
    public static string oppShareRowCause               = 'Team';
    public static string oppEditAccess                  = 'Read/Write';
    public static string oppEditAccessCheck             = 'Edit';
    public static string defaultOppStage                = 'Planning/Proposal Creation';

    public static Id accountRecordTypeId = Schema.SObjectType.Account
        .getRecordTypeInfosByDeveloperName()
        .get(accountRecordTypeName).getRecordTypeId();

    public static ResponseWrapper createAccount(ResponseWrapper resWrap, CreateAccountParams params) {
                    
        Account accToInsert = new Account(
            Name                       = params.newAccountInfo.accountName,
            Enterprise_Account_Type__c = params.newAccountInfo.enterpriseAccountType,
            recordTypeId               = accountRecordTypeId,
            ShippingStreet             = params.newAccountInfo.accountStreet,
            ShippingCity               = params.newAccountInfo.accountCity,
            ShippingState              = params.newAccountInfo.accountState,
            ShippingCountry            = params.newAccountInfo.accountCountry,
            BillingStreet              = params.newAccountInfo.accountStreet, 
            BillingCity                = params.newAccountInfo.accountCity,
            BillingState               = params.newAccountInfo.accountState,
            BillingCountry             = params.newAccountInfo.accountCountry,
            Primary_Commodity__c       = params.newAccountInfo.primaryCommodity,
            Commodity_Codes__c         = params.newAccountInfo.commodityCode
            //TODO: fill in logic
        );

        try{
            if (Test.isRunningTest()){
                if (ThrowAccountException){
                    throw new DMLException(testException);
                }
            }
            Database.SaveResult accSR = Database.Insert(accToInsert);
            resWrap.accountId = accSR.getId();
            resWrap.accountName = accToInsert.Name;
        } catch (Exception e) {                       
            resWrap.isError = true;
            resWrap.errorCode = e.getMessage();
            resWrap.statusCode = 500;
        }

        return resWrap;
    }

    public static ResponseWrapper createOpportunities(
        string accountId, 
        string accountName, 
        ResponseWrapper resWrap, 
        CreateAccountParams params
    ){
        List<OpportunityTeamMember> oppTeam = new List<OpportunityTeamMember>();
        List<OpportunityShare> oppShareRecords = new List<OpportunityShare>();
        List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
        Map<Id, String> oppTeamAccess = new Map<Id,String>();
        List<Id> opportunityIds = new List<Id>();
        string oppName;
        List<Order_Entry__mdt> oppTeamCustomMDT = 
        [
            SELECT 
                UserId__c, 
                Role__c, 
                Category__c, 
                Access_Level__c 
            FROM Order_Entry__mdt
        ];
        string acctName = accountName != null ? accountName : resWrap.accountName;

        for(UniqueMarkets market : params.uniqueMarkets)
        {
            oppName = params.campaignId + ' ' + acctName + ' ' + market.market;

            Opportunity oppToInsert = new Opportunity(
                AccountId = accountId,  
                Name = oppName,
                StageName = defaultOppStage,
                CloseDate = System.today()
            );

            opportunitiesToInsert.add(oppToInsert);
        }

        try{
            if (Test.isRunningTest()){
                if (ThrowOpportunityException){
                    throw new DMLException(testException);
                }
            }
            Database.SaveResult[] oppSRList = Database.Insert(opportunitiesToInsert, true);
            for(Database.SaveResult save : oppSRList){
                resWrap.opportunityIds.add(save.getId());
            }
        } catch (Exception e) {
            resWrap.isError = true;
            resWrap.errorCode = e.getMessage();
            resWrap.statusCode = 500;
            system.debug(e.getMessage());
            return resWrap;
        }

        for(String oppId : resWrap.opportunityIds)
        {
            for(Order_Entry__mdt user : oppTeamCustomMDT){

                OpportunityTeamMember oppMember = new OpportunityTeamMember(
                    UserId = user.UserId__c,
                    opportunityId = oppId,
                    TeamMemberRole = user.Role__c
                );

                oppTeamAccess.put(user.UserId__c, user.Access_Level__c);

                oppTeam.add(oppMember);
            }
        }
        

        Database.SaveResult[] oppTeamSRList = Database.Insert(oppTeam, true);

        Set<ID> oppTeamIds = oppTeamAccess.keySet();

        oppShareRecords = [select Id, OpportunityAccessLevel, RowCause, UserOrGroupId from OpportunityShare where OpportunityId IN : opportunityIds and RowCause =: oppShareRowCause and UserOrGroupId IN : oppTeamIds];


        for (OpportunityShare OppShare : oppShareRecords){
            
            string userAccessLevel = oppTeamAccess.get(OppShare.UserOrGroupId);

            if(userAccessLevel == oppEditAccess){
                OppShare.OpportunityAccessLevel = oppEditAccessCheck;
            }
        }

        update oppShareRecords;

        return resWrap;
    }
}